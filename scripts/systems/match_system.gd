class_name MatchSystem
extends RefCounted

## Eslesme kontrolu ve odul hesaplama.
## Bilet bazli carpan sistemi:
##   3 ayni sembol = eslesme (genelde x1 = paranı geri al)
##   4 ayni sembol = buyuk eslesme (bilete gore x1-8)
##   5+ ayni sembol = JACKPOT (bilete gore x3-50)

## Bilet bazli carpan aralik tablosu: [min, max]
const MULTIPLIER_RANGES := {
	"paper": {
		"normal": [1, 1],    # 3 eslesme: x1 (paranı geri al)
		"big": [1, 2],       # 4 eslesme: x1-2
		"jackpot": [3, 5],   # 5+ eslesme: x3-5
	},
	"bronze": {
		"normal": [1, 1],    # 3 eslesme: x1
		"big": [2, 3],       # 4 eslesme: x2-3
		"jackpot": [5, 10],  # 5+ eslesme: x5-10
	},
	"silver": {
		"normal": [1, 1],    # 3 eslesme: x1
		"big": [2, 4],       # 4 eslesme: x2-4
		"jackpot": [8, 15],  # 5+ eslesme: x8-15
	},
	"gold": {
		"normal": [1, 1],    # 3 eslesme: x1
		"big": [3, 5],       # 4 eslesme: x3-5
		"jackpot": [10, 25], # 5+ eslesme: x10-25
	},
	"platinum": {
		"normal": [1, 1],    # 3 eslesme: x1
		"big": [3, 8],       # 4 eslesme: x3-8
		"jackpot": [15, 50], # 5+ eslesme: x15-50
	},
}


## Eslesme sonucunu dondurur
## { "has_match": bool, "best_symbol": String, "best_count": int,
##   "reward": int, "multiplier": int, "tier": String }
static func check_match(symbols: Array, ticket_type: String) -> Dictionary:
	var price: int = TicketData.TICKET_CONFIGS.get(ticket_type, TicketData.TICKET_CONFIGS["paper"])["price"]

	# Sembolleri say
	var counts := {}
	for s in symbols:
		counts[s] = counts.get(s, 0) + 1

	# En cok tekrar eden sembolu bul
	var best_symbol := ""
	var best_count := 0
	for s in counts:
		if counts[s] > best_count:
			best_count = counts[s]
			best_symbol = s

	# Eslesme kontrolu
	if best_count < 3:
		return {
			"has_match": false,
			"best_symbol": best_symbol,
			"best_count": best_count,
			"reward": 0,
			"multiplier": 0,
			"tier": "none",
		}

	# Carpan ve tier hesapla (bilet bazli)
	var multiplier: int = 0
	var tier: String = ""
	var ranges: Dictionary = MULTIPLIER_RANGES.get(ticket_type, MULTIPLIER_RANGES["paper"])

	if best_count >= 5:
		tier = "jackpot"
		multiplier = randi_range(ranges["jackpot"][0], ranges["jackpot"][1])
	elif best_count == 4:
		tier = "big"
		multiplier = randi_range(ranges["big"][0], ranges["big"][1])
	else:
		tier = "normal"
		multiplier = randi_range(ranges["normal"][0], ranges["normal"][1])

	var reward: int = price * multiplier

	return {
		"has_match": true,
		"best_symbol": best_symbol,
		"best_count": best_count,
		"reward": reward,
		"multiplier": multiplier,
		"tier": tier,
	}
