extends RefCounted

## Sinerji tanimlari ve kontrol mantigi.
## Ayni bilette belirli sembol kombinasyonlari cikarsa bonus tetiklenir.

const SYNERGIES := {
	"meyve_kokteyli": {
		"name": "Meyve Kokteyli",
		"condition_text": "Kiraz + Limon + Uzum",
		"multiplier": 3,
		"check_type": "all_present",
		"required_symbols": ["cherry", "lemon", "grape"],
	},
	"gece_gokyuzu": {
		"name": "Gece Gokyuzu",
		"condition_text": "Yildiz + Ay",
		"multiplier": 4,
		"check_type": "all_present",
		"required_symbols": ["star", "moon"],
	},
	"lucky_seven": {
		"name": "Lucky Seven",
		"condition_text": "7 x3",
		"multiplier": 10,
		"check_type": "symbol_count",
		"required_symbol": "seven",
		"required_count": 3,
	},
	"kraliyet": {
		"name": "Kraliyet",
		"condition_text": "Tac + Elmas",
		"multiplier": 5,
		"check_type": "all_present",
		"required_symbols": ["crown", "diamond"],
	},
	"ejderha_atesi": {
		"name": "Ejderha Atesi",
		"condition_text": "Ejderha + Anka",
		"multiplier": 8,
		"check_type": "all_present",
		"required_symbols": ["dragon", "phoenix"],
	},
	"full_house": {
		"name": "Full House",
		"condition_text": "Tum alanlar ayni sembol",
		"multiplier": 25,
		"check_type": "all_same",
	},
	"gokkusagi": {
		"name": "Gokkusagi",
		"condition_text": "5+ farkli sembol",
		"multiplier": 5,
		"check_type": "unique_count",
		"required_count": 5,
	},
	"meyve_festivali": {
		"name": "???",
		"condition_text": "???",
		"multiplier": 15,
		"check_type": "custom_meyve_festivali",
		"hidden": true,
	},
}

## Gosterim sirasi
const SYNERGY_ORDER := [
	"meyve_kokteyli", "gece_gokyuzu", "lucky_seven", "kraliyet",
	"ejderha_atesi", "full_house", "gokkusagi", "meyve_festivali",
]


## Biletteki sembolleri kontrol eder, bulunan tum sinerjileri doner.
static func check_synergies(symbols: Array) -> Array:
	var found: Array = []

	# Sembol sayilarini hesapla
	var counts := {}
	for s in symbols:
		counts[s] = counts.get(s, 0) + 1
	var unique_count: int = counts.size()

	for synergy_id in SYNERGY_ORDER:
		var synergy: Dictionary = SYNERGIES[synergy_id]
		var matched := false

		match synergy["check_type"]:
			"all_present":
				matched = true
				for req_symbol in synergy["required_symbols"]:
					if not counts.has(req_symbol):
						matched = false
						break
			"symbol_count":
				var req_sym: String = synergy["required_symbol"]
				var req_count: int = synergy["required_count"]
				matched = counts.get(req_sym, 0) >= req_count
			"all_same":
				matched = unique_count == 1 and symbols.size() > 0
			"unique_count":
				matched = unique_count >= synergy["required_count"]
			"custom_meyve_festivali":
				# Gizli sinerji: cherry x3 + lemon x3 (6 meyve)
				matched = counts.get("cherry", 0) >= 3 and counts.get("lemon", 0) >= 3

		if matched:
			found.append({
				"id": synergy_id,
				"name": synergy["name"],
				"multiplier": synergy["multiplier"],
				"condition_text": synergy["condition_text"],
				"hidden": synergy.get("hidden", false),
			})

	return found


## Sinerji bilgisini getir
static func get_synergy(synergy_id: String) -> Dictionary:
	return SYNERGIES.get(synergy_id, {})


## Sinerji Radari charm etkisi icin: sinerjiye uygun sembolleri yerlestir
## Doner: eklenmesi gereken semboller (bos array = etki yok)
static func get_synergy_nudge_symbols(pool: Array) -> Array:
	# Havuzda mumkun olan sinerjileri bul
	var possible: Array = []

	for synergy_id in SYNERGY_ORDER:
		var synergy: Dictionary = SYNERGIES[synergy_id]
		if synergy.get("hidden", false):
			continue

		match synergy["check_type"]:
			"all_present":
				var all_in_pool := true
				for req_sym in synergy["required_symbols"]:
					if req_sym not in pool:
						all_in_pool = false
						break
				if all_in_pool:
					possible.append(synergy["required_symbols"])
			"symbol_count":
				if synergy["required_symbol"] in pool:
					var arr: Array = []
					for i in synergy["required_count"]:
						arr.append(synergy["required_symbol"])
					possible.append(arr)

	if possible.is_empty():
		return []

	# Rastgele bir sinerji sec ve gerekli sembolleri don
	return possible[randi() % possible.size()]
