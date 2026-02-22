extends Node

## Oyun durumunu tutan global autoload.
## Mobil: tur bazlı, enerji sistemi, charm puanları.

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

# --- Enerji Sistemi ---
const MAX_ENERGY: int = 5
const ENERGY_REGEN_SECONDS: float = 600.0  # 10 dakika

var energy: int = MAX_ENERGY:
	set(value):
		energy = clampi(value, 0, MAX_ENERGY)
		energy_changed.emit(energy)

var _energy_regen_accumulator: float = 0.0

# --- Kalıcı Veriler ---
var charm_points: int = 0:
	set(value):
		charm_points = max(value, 0)
		charm_points_changed.emit(charm_points)

var charms: Dictionary = {}  # { "charm_id": level }

var total_coins_earned: int = 0
var total_rounds_played: int = 0
var best_round_coins: int = 0


func _ready() -> void:
	print("[GameState] Initialized — Mobile")


func _process(delta: float) -> void:
	if energy >= MAX_ENERGY:
		_energy_regen_accumulator = 0.0
		return
	_energy_regen_accumulator += delta
	while _energy_regen_accumulator >= ENERGY_REGEN_SECONDS and energy < MAX_ENERGY:
		_energy_regen_accumulator -= ENERGY_REGEN_SECONDS
		energy += 1


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
	var bonus: int = charms.get("starting_coins", 0) * 10
	return base + bonus


## Coin'den charm puanı hesapla
func calc_charm_from_coins(earned: int) -> int:
	return int(earned / 100.0)


## Charm seviyesini al
func get_charm_level(charm_id: String) -> int:
	return charms.get(charm_id, 0)


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
