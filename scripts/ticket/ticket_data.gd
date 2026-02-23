class_name TicketData
extends RefCounted

## Bilet turleri, sembol tanimlari, rastgele sembol uretimi.

const SYMBOL_NAMES := {
	"cherry": "Kiraz",
	"lemon": "Limon",
	"grape": "Uzum",
}

const SYMBOL_COLORS := {
	"cherry": Color(0.9, 0.15, 0.2),
	"lemon": Color(0.95, 0.85, 0.1),
	"grape": Color(0.55, 0.2, 0.75),
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
}


## Rastgele sembol dizisi dondurur
static func get_random_symbols(type: String) -> Array:
	var config: Dictionary = TICKET_CONFIGS.get(type, TICKET_CONFIGS["paper"])
	var pool: Array = config["symbol_pool"]
	var count: int = config["area_count"]
	var symbols: Array = []
	for i in count:
		symbols.append(pool[randi() % pool.size()])
	return symbols


static func get_display_name(symbol_id: String) -> String:
	return SYMBOL_NAMES.get(symbol_id, symbol_id)


static func get_color(symbol_id: String) -> Color:
	return SYMBOL_COLORS.get(symbol_id, Color.WHITE)
