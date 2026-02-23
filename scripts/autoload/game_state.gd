extends Node

## Oyun durumunu tutan global autoload.
## Mobil: tur bazlı, enerji sistemi, charm puanları.

const CharmDataRef := preload("res://scripts/systems/charm_data.gd")

# --- Sinyaller ---
signal coins_changed(new_amount: int)
signal energy_changed(new_amount: int)
signal charm_points_changed(new_amount: int)
signal round_started()
signal round_ended(total_earned: int)

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

# --- Enerji Sistemi ---
const BASE_MAX_ENERGY: int = 5
const ENERGY_REGEN_SECONDS: float = 600.0  # 10 dakika

var energy: int = BASE_MAX_ENERGY:
	set(value):
		energy = clampi(value, 0, get_max_energy())
		energy_changed.emit(energy)

var _energy_regen_accumulator: float = 0.0


func _ready() -> void:
	print("[GameState] Initialized — Mobile")


func _process(delta: float) -> void:
	var max_e := get_max_energy()
	if energy >= max_e:
		_energy_regen_accumulator = 0.0
		return
	_energy_regen_accumulator += delta
	while _energy_regen_accumulator >= ENERGY_REGEN_SECONDS and energy < max_e:
		_energy_regen_accumulator -= ENERGY_REGEN_SECONDS
		energy += 1


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


## Başlangıç coin: 50 + charm bonusları
func get_starting_coins() -> int:
	var base := 50
	var bonus: int = get_charm_level("zengin_baslangic") * 10
	var mega_bonus: int = get_charm_level("mega_baslangic") * 50
	return base + bonus + mega_bonus


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
