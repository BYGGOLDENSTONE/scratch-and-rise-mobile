extends Node

## Oyun durumunu tutan global autoload.
## Mobil: tur bazlı, enerji sistemi, charm puanları.

const CharmDataRef := preload("res://scripts/systems/charm_data.gd")
const CollectionRef := preload("res://scripts/systems/collection_system.gd")

# --- Sinyaller ---
signal coins_changed(new_amount: int)
signal energy_changed(new_amount: int)
signal charm_points_changed(new_amount: int)
signal round_started()
signal round_ended(total_earned: int)
signal achievement_unlocked(id: String)
signal event_triggered(id: String, data: Dictionary)
signal theme_changed(theme_id: int)

# --- Kullanici Ayarlari ---
var user_theme: int = 0  # 0 = dark, 1 = light

# --- Tur İçi (her tur sıfırlanır) ---
var coins: int = 0:
	set(value):
		coins = max(value, 0)
		coins_changed.emit(coins)

var in_round: bool = false

# --- Kalıcı Veriler ---
var charm_points: int = 0:
	set(value):
		charm_points = max(value, 0)
		charm_points_changed.emit(charm_points)

var charms: Dictionary = {}  # { "charm_id": level }

var total_coins_earned: int = 0
var total_rounds_played: int = 0
var best_round_coins: int = 0
var last_round_earnings: int = 0

# --- Koleksiyon & Sinerji ---
var collected_pieces: Dictionary = {}  # { "set_id": ["piece1", "piece2"] }
var discovered_synergies: Array = []   # ["meyve_kokteyli", "gece_gokyuzu", ...]

# --- İstatistikler (Kalıcı) ---
var stats: Dictionary = {
	"total_tickets": 0,
	"total_matches": 0,
	"total_jackpots": 0,
	"total_synergies_found": 0,
	"best_streak": 0,
	"ticket_types_played": [],
	"total_special_symbols": 0,
	"loss_streak": 0,
}

# --- Başarımlar (Kalıcı) ---
var unlocked_achievements: Array = []  # ["ilk_kazima", "ilk_eslesme", ...]

# --- Günlük Görevler ---
var daily_quests: Array = []  # [{"id", "progress", "target", "completed"}]
var daily_quest_date: String = ""  # "YYYY-MM-DD" formatinda
var daily_bonus_claimed: bool = false

# --- Son Hamle state ---
var _son_hamle_used: int = 0  # Bu turda kac kez kullanildi

# --- Tur İçi Olay & İstatistik ---
var round_stats: Dictionary = {}
var active_events: Dictionary = {}  # { "bull_run": remaining_count, ... }
var _tickets_since_golden: int = 0
var _joker_rain_active: bool = false
var _mega_ticket_active: bool = false
var _free_ticket_active: bool = false
var _current_match_streak: int = 0

# --- Enerji Sistemi ---
const BASE_MAX_ENERGY: int = 5
const ENERGY_REGEN_SECONDS: float = 600.0  # 10 dakika

var energy: int = BASE_MAX_ENERGY:
	set(value):
		energy = clampi(value, 0, get_max_energy())
		energy_changed.emit(energy)

var _energy_regen_accumulator: float = 0.0


const ThemeHelperRef := preload("res://scripts/ui/theme_helper.gd")

func _ready() -> void:
	_apply_saved_theme()
	print("[GameState] Initialized — Mobile")


## Tema degistir ve kaydet
func set_user_theme(theme_id: int) -> void:
	user_theme = theme_id
	_apply_saved_theme()
	theme_changed.emit(theme_id)
	SaveManager.save_game()


## Kaydedilmis temayi ThemeHelper'a uygula
func _apply_saved_theme() -> void:
	ThemeHelperRef.set_theme(
		ThemeHelperRef.ThemeMode.DARK if user_theme == 0 else ThemeHelperRef.ThemeMode.LIGHT
	)
	RenderingServer.set_default_clear_color(ThemeHelperRef.p("bg_main"))


func _process(delta: float) -> void:
	var max_e := get_max_energy()
	if energy >= max_e:
		_energy_regen_accumulator = 0.0
		return
	_energy_regen_accumulator += delta
	var regen_time := get_energy_regen_time()
	while _energy_regen_accumulator >= regen_time and energy < max_e:
		_energy_regen_accumulator -= regen_time
		energy += 1


## Enerji yenilenme suresi (Dayaniklilik charm + Uzay Kasifi koleksiyon bonusu)
func get_energy_regen_time() -> float:
	var base := ENERGY_REGEN_SECONDS
	var dayaniklilik_level: int = get_charm_level("dayaniklilik")
	var speed_bonus: float = dayaniklilik_level * 0.15
	speed_bonus += CollectionRef.get_energy_regen_bonus()
	return base / (1.0 + speed_bonus)


## Max enerji (baz + enerji_deposu charm bonusu)
func get_max_energy() -> int:
	return BASE_MAX_ENERGY + get_charm_level("enerji_deposu")


## Tur başlat — enerji yeterliyse
func start_round() -> bool:
	if energy <= 0:
		print("[GameState] Enerji yetersiz!")
		return false
	if in_round:
		print("[GameState] Zaten turda!")
		return false
	energy -= 1
	coins = get_starting_coins()
	in_round = true
	total_rounds_played += 1
	# Tur ici state'leri sifirla
	round_stats = {
		"tickets": 0,
		"matches": 0,
		"jackpots": 0,
		"synergies": 0,
		"coins_earned": 0,
	}
	active_events = {}
	_tickets_since_golden = 0
	_joker_rain_active = false
	_mega_ticket_active = false
	_free_ticket_active = false
	_current_match_streak = 0
	_son_hamle_used = 0
	round_started.emit()
	print("[GameState] Tur başladı — Başlangıç coin: ", coins)
	return true


## Tur bitir — charm puanı hesapla
func end_round() -> void:
	if not in_round:
		return
	in_round = false
	var earned := coins
	last_round_earnings = earned
	total_coins_earned += earned
	if earned > best_round_coins:
		best_round_coins = earned
	var charm_earned := calc_charm_from_coins(earned)
	charm_points += charm_earned
	round_ended.emit(earned)
	print("[GameState] Tur bitti — Kazanılan: ", earned, " Charm: ", charm_earned)
	coins = 0


func add_coins(amount: int) -> void:
	coins += amount


func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false


## Başlangıç coin: 50 + charm bonusları + koleksiyon bonusu
func get_starting_coins() -> int:
	var base := 50
	var bonus: int = get_charm_level("zengin_baslangic") * 10
	var mega_bonus: int = get_charm_level("mega_baslangic") * 50
	var col_bonus: int = CollectionRef.get_starting_coins_bonus()
	return base + bonus + mega_bonus + col_bonus


## Coin'den charm puanı hesapla
func calc_charm_from_coins(earned: int) -> int:
	return int(earned / 100.0)


## Charm seviyesini al
func get_charm_level(charm_id: String) -> int:
	return charms.get(charm_id, 0)


## Charm satın al / seviye yükselt
func buy_charm(charm_id: String) -> bool:
	var charm_info: Dictionary = CharmDataRef.get_charm(charm_id)
	if charm_info.is_empty():
		print("[GameState] Charm bulunamadi: ", charm_id)
		return false

	var current_level: int = get_charm_level(charm_id)
	var max_level: int = charm_info["max_level"]
	if current_level >= max_level:
		print("[GameState] Charm max seviyede: ", charm_id)
		return false

	var cost: int = charm_info["cost"]
	if charm_points < cost:
		print("[GameState] Charm puani yetersiz: ", charm_points, " < ", cost)
		return false

	charm_points -= cost
	charms[charm_id] = current_level + 1
	SaveManager.save_game()
	print("[GameState] Charm alindi: ", charm_id, " -> Lv.", current_level + 1)
	return true


## Koleksiyon parcasi ekle
func add_collection_piece(set_id: String, piece_id: String) -> void:
	if not collected_pieces.has(set_id):
		collected_pieces[set_id] = []
	if piece_id not in collected_pieces[set_id]:
		collected_pieces[set_id].append(piece_id)
		SaveManager.save_game()
		print("[GameState] Koleksiyon parcasi eklendi: %s / %s" % [set_id, piece_id])


## Koleksiyon parcasi var mi kontrol
func has_collection_piece(set_id: String, piece_id: String) -> bool:
	if not collected_pieces.has(set_id):
		return false
	return piece_id in collected_pieces[set_id]


## Set tamamlandi mi kontrol
func is_set_complete(set_id: String) -> bool:
	return CollectionRef.is_set_complete(set_id)


## Sinerji kesfet
func discover_synergy(synergy_id: String) -> bool:
	if synergy_id in discovered_synergies:
		return false
	discovered_synergies.append(synergy_id)
	SaveManager.save_game()
	print("[GameState] Sinerji kesfedildi: ", synergy_id)
	return true


## Sinerji kesfedilmis mi
func is_synergy_discovered(synergy_id: String) -> bool:
	return synergy_id in discovered_synergies


## Toplam charm seviyesi (tum charm'larin seviyelerinin toplami)
func get_total_charm_levels() -> int:
	var total := 0
	for level in charms.values():
		total += int(level)
	return total


## Büyük sayıları okunabilir formata çevir
func format_number(n: int) -> String:
	var thresholds := [
		[1_000_000_000_000_000_000, "Qi"],
		[1_000_000_000_000_000, "Qa"],
		[1_000_000_000_000, "T"],
		[1_000_000_000, "B"],
		[1_000_000, "M"],
		[1_000, "K"],
	]
	for entry in thresholds:
		if n >= entry[0]:
			return "%.1f%s" % [float(n) / float(entry[0]), entry[1]]
	return str(n)
