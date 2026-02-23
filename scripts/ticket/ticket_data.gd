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
	"diamond": "Elmas",
	"heart": "Kalp",
	"seven": "7",
	"crown": "Tac",
	"phoenix": "Anka",
	"dragon": "Ejderha",
}

const SYMBOL_COLORS := {
	"cherry": Color(0.9, 0.15, 0.2),
	"lemon": Color(0.95, 0.85, 0.1),
	"grape": Color(0.55, 0.2, 0.75),
	"star": Color(1.0, 0.84, 0.0),
	"moon": Color(0.75, 0.75, 0.9),
	"diamond": Color(0.3, 0.85, 0.95),
	"heart": Color(0.95, 0.3, 0.5),
	"seven": Color(0.9, 0.1, 0.1),
	"crown": Color(1.0, 0.7, 0.0),
	"phoenix": Color(1.0, 0.45, 0.1),
	"dragon": Color(0.2, 0.8, 0.3),
}

## Her bilet turu icin config: isim, fiyat, alan sayisi, kolon, sembol havuzu
const TICKET_CONFIGS := {
	"paper": {
		"name": "Kagit Bilet",
		"price": 5,
		"area_count": 6,
		"columns": 3,
		"symbol_pool": ["cherry", "lemon", "grape"],
	},
	"bronze": {
		"name": "Bronz Bilet",
		"price": 15,
		"area_count": 8,
		"columns": 4,
		"symbol_pool": ["cherry", "lemon", "grape", "star", "moon"],
	},
	"silver": {
		"name": "Gumus Bilet",
		"price": 40,
		"area_count": 9,
		"columns": 3,
		"symbol_pool": ["cherry", "lemon", "grape", "star", "moon", "diamond", "heart"],
	},
	"gold": {
		"name": "Altin Bilet",
		"price": 100,
		"area_count": 10,
		"columns": 5,
		"symbol_pool": ["cherry", "lemon", "grape", "star", "moon", "diamond", "heart", "seven", "crown"],
	},
	"platinum": {
		"name": "Platin Bilet",
		"price": 250,
		"area_count": 12,
		"columns": 4,
		"symbol_pool": ["cherry", "lemon", "grape", "star", "moon", "diamond", "heart", "seven", "crown", "phoenix", "dragon"],
	},
}

## Bilet siralamasi (UI'da gosterim icin)
const TICKET_ORDER := ["paper", "bronze", "silver", "gold", "platinum"]

## Acilma kosullari
const UNLOCK_CONDITIONS := {
	"paper": {"type": "none"},
	"bronze": {"type": "total_coins", "amount": 500},
	"silver": {"type": "charm", "charm_id": "gumus_anahtar"},
	"gold": {"type": "charm", "charm_id": "altin_anahtar"},
	"platinum": {"type": "charm", "charm_id": "platin_anahtar"},
}


## Bilet acik mi kontrol
static func is_ticket_unlocked(ticket_type: String) -> bool:
	var cond: Dictionary = UNLOCK_CONDITIONS.get(ticket_type, {"type": "none"})
	match cond["type"]:
		"none":
			return true
		"total_coins":
			return GameState.total_coins_earned >= cond["amount"]
		"charm":
			return GameState.get_charm_level(cond["charm_id"]) > 0
	return false


## Kilitli bilet icin aciklama metni
static func get_unlock_text(ticket_type: String) -> String:
	var cond: Dictionary = UNLOCK_CONDITIONS.get(ticket_type, {"type": "none"})
	match cond["type"]:
		"total_coins":
			return "%s toplam coin" % GameState.format_number(cond["amount"])
		"charm":
			var charm_info: Dictionary = CharmDataRef.CHARMS.get(cond["charm_id"], {})
			var charm_name: String = charm_info.get("name", cond["charm_id"])
			return "%s gerekli" % charm_name
	return ""


## En ucuz acik bilet fiyati (tur bitirme kontrolu icin)
static func get_cheapest_unlocked_price() -> int:
	var cheapest := 999999
	for t_type in TICKET_ORDER:
		if is_ticket_unlocked(t_type):
			var price: int = TICKET_CONFIGS[t_type]["price"]
			if price < cheapest:
				cheapest = price
	return cheapest


## Rastgele sembol dizisi dondurur (Sinerji Radari charm etkisi dahil)
static func get_random_symbols(type: String) -> Array:
	var config: Dictionary = TICKET_CONFIGS.get(type, TICKET_CONFIGS["paper"])
	var pool: Array = config["symbol_pool"]
	var count: int = config["area_count"]
	var symbols: Array = []

	# Sinerji Radari charm etkisi: sinerji yonlendirme sansi
	var radar_level: int = GameState.get_charm_level("sinerji_radari")
	var nudge_chance: float = radar_level * 0.05
	var nudge_symbols: Array = []

	if radar_level > 0 and randf() < nudge_chance:
		nudge_symbols = SynergyRef.get_synergy_nudge_symbols(pool)

	# Nudge sembollerini yerlestir (varsa)
	for ns in nudge_symbols:
		if symbols.size() < count:
			symbols.append(ns)

	# Kalan alanlari rastgele doldur
	while symbols.size() < count:
		symbols.append(pool[randi() % pool.size()])

	# Sirayi karistir (nudge sembolleri belli olmasin)
	symbols.shuffle()
	return symbols


static func get_display_name(symbol_id: String) -> String:
	return SYMBOL_NAMES.get(symbol_id, symbol_id)


static func get_color(symbol_id: String) -> Color:
	return SYMBOL_COLORS.get(symbol_id, Color.WHITE)
