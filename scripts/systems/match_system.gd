class_name MatchSystem
extends RefCounted

## Eslesme kontrolu ve odul hesaplama.
## GDD kurallari:
##   3 ayni sembol = eslesme (bilet fiyati x 1-5)
##   4 ayni sembol = buyuk eslesme (bilet fiyati x 5-20)
##   5+ ayni sembol = JACKPOT (bilet fiyati x 20-100)


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

	# Carpan ve tier hesapla
	var multiplier: int = 0
	var tier: String = ""

	if best_count >= 5:
		# JACKPOT: x20-100
		multiplier = randi_range(20, 100)
		tier = "jackpot"
	elif best_count == 4:
		# Buyuk eslesme: x5-20
		multiplier = randi_range(5, 20)
		tier = "big"
	else:
		# Normal eslesme (3): x1-5
		multiplier = randi_range(1, 5)
		tier = "normal"

	var reward: int = price * multiplier

	return {
		"has_match": true,
		"best_symbol": best_symbol,
		"best_count": best_count,
		"reward": reward,
		"multiplier": multiplier,
		"tier": tier,
	}
