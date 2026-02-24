class_name TicketData
extends RefCounted

## Bilet turleri, sembol tanimlari, rastgele sembol uretimi.

const CharmDataRef := preload("res://scripts/systems/charm_data.gd")
const SynergyRef := preload("res://scripts/systems/synergy_system.gd")

const SYMBOL_NAMES := {
	"cherry": "Kiraz",
	"lemon": "Limon",
	"grape": "Uzum",
	"star": "Yildiz",
	"moon": "Ay",
	"clover": "Yonca",
	"bell": "Zil",
	"diamond": "Elmas",
	"heart": "Kalp",
	"seven": "7",
	"crown": "Tac",
	"horseshoe": "Nal",
	"phoenix": "Anka",
	"dragon": "Ejderha",
	"dice": "Zar",
	# Ozel semboller
	"joker": "Joker",
	"x2_multiplier": "x2",
	"bomb": "Bomba",
}

const SYMBOL_COLORS := {
	"cherry": Color(0.9, 0.15, 0.2),
	"lemon": Color(0.95, 0.85, 0.1),
	"grape": Color(0.55, 0.2, 0.75),
	"star": Color(1.0, 0.84, 0.0),
	"moon": Color(0.75, 0.75, 0.9),
	"clover": Color(0.15, 0.75, 0.3),
	"bell": Color(0.95, 0.8, 0.15),
	"diamond": Color(0.3, 0.85, 0.95),
	"heart": Color(0.95, 0.3, 0.5),
	"seven": Color(0.9, 0.1, 0.1),
	"crown": Color(1.0, 0.7, 0.0),
	"horseshoe": Color(0.65, 0.45, 0.2),
	"phoenix": Color(1.0, 0.45, 0.1),
	"dragon": Color(0.2, 0.8, 0.3),
	"dice": Color(0.85, 0.85, 0.9),
	# Ozel semboller
	"joker": Color(0.9, 0.2, 0.9),
	"x2_multiplier": Color(0.1, 0.95, 0.5),
	"bomb": Color(1.0, 0.5, 0.1),
}

## Her bilet turu icin config: isim, fiyat, odul tabani, alan sayisi, kolon, sembol havuzu
## base_reward << price = dogal kayip orani (bilet buyudukce risk CIDDDI artar)
## Gercek kazi kazan modeli: cogu bilet kayip, sadece jackpot kar ettirir
const TICKET_CONFIGS := {
	"paper": {
		"name": "Kagit",
		"price": 5,
		"base_reward": 5,       # x1 = break even, guvenli baslangic
		"area_count": 6,
		"columns": 3,
		"symbol_pool": ["cherry", "lemon", "grape", "star", "moon"],
	},
	"bronze": {
		"name": "Bronz",
		"price": 25,
		"base_reward": 10,      # x1 = kayip 15 (%60)
		"area_count": 8,
		"columns": 4,
		"symbol_pool": ["cherry", "lemon", "grape", "star", "moon", "clover", "bell"],
	},
	"silver": {
		"name": "Gumus",
		"price": 100,
		"base_reward": 20,      # x1 = kayip 80 (%80)
		"area_count": 9,
		"columns": 3,
		"symbol_pool": ["cherry", "lemon", "grape", "star", "moon", "clover", "bell", "diamond", "heart"],
	},
	"gold": {
		"name": "Altin",
		"price": 500,
		"base_reward": 40,      # x1 = kayip 460 (%92)
		"area_count": 10,
		"columns": 5,
		"symbol_pool": ["cherry", "lemon", "grape", "star", "moon", "clover", "bell", "diamond", "heart", "seven", "crown", "horseshoe"],
	},
	"platinum": {
		"name": "Platin",
		"price": 2500,
		"base_reward": 80,      # x1 = kayip 2420 (%97)
		"area_count": 12,
		"columns": 4,
		"symbol_pool": ["cherry", "lemon", "grape", "star", "moon", "clover", "bell", "diamond", "heart", "seven", "crown", "horseshoe", "phoenix", "dragon", "dice"],
	},
}

## Bilet siralamasi (UI'da gosterim icin)
const TICKET_ORDER := ["paper", "bronze", "silver", "gold", "platinum"]

## Tum biletler bastan acik — oyuncu parasina gore risk alir
static func is_ticket_unlocked(_ticket_type: String) -> bool:
	return true


## Kilitli bilet yok artik
static func get_unlock_text(_ticket_type: String) -> String:
	return ""


## Ozel sembol dusme sanslari (tier bazli, her slot icin bagimsiz)
const SPECIAL_SYMBOL_CHANCES := {
	"paper": {},
	"bronze": {},
	"silver": {"joker": 0.05},
	"gold": {"joker": 0.06, "x2_multiplier": 0.04},
	"platinum": {"joker": 0.07, "x2_multiplier": 0.05, "bomb": 0.04},
}


## En ucuz acik bilet fiyati (tur bitirme kontrolu icin)
static func get_cheapest_unlocked_price() -> int:
	var cheapest := 999999
	for t_type in TICKET_ORDER:
		if is_ticket_unlocked(t_type):
			var price: int = TICKET_CONFIGS[t_type]["price"]
			if price < cheapest:
				cheapest = price
	return cheapest


## Rastgele sembol dizisi dondurur (Sinerji Radari + Ozel Semboller dahil)
static func get_random_symbols(type: String) -> Array:
	var config: Dictionary = TICKET_CONFIGS.get(type, TICKET_CONFIGS["paper"])
	var pool: Array = config["symbol_pool"]
	var count: int = config["area_count"]
	var symbols: Array = []

	# Sinerji Radari charm etkisi: sinerji yonlendirme sansi
	var radar_level: int = GameState.get_charm_level("sinerji_radari")
	var miknatis_level: int = GameState.get_charm_level("miknatis")
	var nudge_chance: float = (radar_level + miknatis_level) * 0.05
	var nudge_symbols: Array = []

	if nudge_chance > 0 and randf() < nudge_chance:
		nudge_symbols = SynergyRef.get_synergy_nudge_symbols(pool)

	# Nudge sembollerini yerlestir (varsa)
	for ns in nudge_symbols:
		if symbols.size() < count:
			symbols.append(ns)

	# Kalan alanlari rastgele doldur
	while symbols.size() < count:
		symbols.append(pool[randi() % pool.size()])

	# Ozel sembol yerlestirme (Silver+ biletlerde)
	var special_chances: Dictionary = SPECIAL_SYMBOL_CHANCES.get(type, {})
	if not special_chances.is_empty():
		var joker_bonus: float = GameState.get_charm_level("joker_miknatisi") * 0.03
		var x2_bonus: float = GameState.get_charm_level("carpan_gucu") * 0.02
		var star_bonus: float = GameState.get_charm_level("sansli_yildiz") * 0.04
		var special_placed := {}
		var total_specials := 0
		var max_specials := 2

		for i in range(symbols.size()):
			if total_specials >= max_specials:
				break
			for special_id in ["bomb", "x2_multiplier", "joker"]:
				if special_placed.get(special_id, 0) >= 1:
					continue
				var base_chance: float = special_chances.get(special_id, 0.0)
				if base_chance <= 0:
					continue
				var charm_add := star_bonus
				match special_id:
					"joker": charm_add += joker_bonus
					"x2_multiplier": charm_add += x2_bonus
				if randf() < base_chance + charm_add:
					symbols[i] = special_id
					special_placed[special_id] = special_placed.get(special_id, 0) + 1
					total_specials += 1
					break

	# Sirayi karistir
	symbols.shuffle()
	return symbols


static func get_display_name(symbol_id: String) -> String:
	return SYMBOL_NAMES.get(symbol_id, symbol_id)


static func get_color(symbol_id: String) -> Color:
	return SYMBOL_COLORS.get(symbol_id, Color.WHITE)
