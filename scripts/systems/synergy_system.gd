extends RefCounted

## Sinerji tanimlari ve kontrol mantigi.
## Ayni bilette belirli sembol kombinasyonlari cikarsa bonus tetiklenir.

const SYNERGIES := {
	"meyve_kokteyli": {
		"name": "Meyve Kokteyli",
		"condition_text": "Kiraz + Limon + Uzum",
		"multiplier": 2,
		"check_type": "all_present",
		"required_symbols": ["cherry", "lemon", "grape"],
	},
	"gece_gokyuzu": {
		"name": "Gece Gokyuzu",
		"condition_text": "Yildiz + Ay",
		"multiplier": 2,
		"check_type": "all_present",
		"required_symbols": ["star", "moon"],
	},
	"lucky_seven": {
		"name": "Lucky Seven",
		"condition_text": "7 x3",
		"multiplier": 5,
		"check_type": "symbol_count",
		"required_symbol": "seven",
		"required_count": 3,
	},
	"kraliyet": {
		"name": "Kraliyet",
		"condition_text": "Tac + Elmas",
		"multiplier": 3,
		"check_type": "all_present",
		"required_symbols": ["crown", "diamond"],
	},
	"ejderha_atesi": {
		"name": "Ejderha Atesi",
		"condition_text": "Ejderha + Anka",
		"multiplier": 4,
		"check_type": "all_present",
		"required_symbols": ["dragon", "phoenix"],
	},
	"full_house": {
		"name": "Full House",
		"condition_text": "Tum alanlar ayni sembol",
		"multiplier": 10,
		"check_type": "all_same",
	},
	"gokkusagi": {
		"name": "Gokkusagi",
		"condition_text": "5+ farkli sembol",
		"multiplier": 2,
		"check_type": "unique_count",
		"required_count": 5,
	},
	"meyve_festivali": {
		"name": "???",
		"condition_text": "???",
		"multiplier": 5,
		"check_type": "custom_meyve_festivali",
		"hidden": true,
	},
	# --- Yeni Sinerjiler ---
	"joker_partisi": {
		"name": "Joker Partisi",
		"condition_text": "2+ Joker",
		"multiplier": 3,
		"check_type": "special_count",
		"required_symbol": "joker",
		"required_count": 2,
	},
	"bomba_firtinasi": {
		"name": "Bomba Firtinasi",
		"condition_text": "Bomba + 4-eslesme",
		"multiplier": 4,
		"check_type": "custom_bomba_firtinasi",
	},
	"tas_koleksiyonu": {
		"name": "Tas Koleksiyonu",
		"condition_text": "Elmas + Kalp + Tac",
		"multiplier": 3,
		"check_type": "all_present",
		"required_symbols": ["diamond", "heart", "crown"],
	},
	"kozmik_guc": {
		"name": "Kozmik Guc",
		"condition_text": "Yildiz + Ay + Anka",
		"multiplier": 4,
		"check_type": "all_present",
		"required_symbols": ["star", "moon", "phoenix"],
	},
	"kripto_madenci": {
		"name": "Kripto Madenci",
		"condition_text": "3+ ayni + x2 sembol",
		"multiplier": 5,
		"check_type": "custom_kripto_madenci",
	},
	"cicek_bahcesi": {
		"name": "Cicek Bahcesi",
		"condition_text": "Kiraz + Limon + Uzum + Yildiz",
		"multiplier": 3,
		"check_type": "all_present",
		"required_symbols": ["cherry", "lemon", "grape", "star"],
	},
	"efsane": {
		"name": "???",
		"condition_text": "???",
		"multiplier": 6,
		"check_type": "all_present",
		"required_symbols": ["dragon", "phoenix", "crown"],
		"hidden": true,
	},
}

## Gosterim sirasi
const SYNERGY_ORDER := [
	"meyve_kokteyli", "gece_gokyuzu", "lucky_seven", "kraliyet",
	"ejderha_atesi", "full_house", "gokkusagi",
	"joker_partisi", "bomba_firtinasi", "tas_koleksiyonu",
	"kozmik_guc", "kripto_madenci", "cicek_bahcesi",
	"meyve_festivali", "efsane",
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
			"special_count":
				var req_sym: String = synergy["required_symbol"]
				var req_count: int = synergy["required_count"]
				matched = counts.get(req_sym, 0) >= req_count
			"all_same":
				# Joker haric tum semboller ayni mi (joker wildcard oldugu icin)
				var non_special := {}
				for s in symbols:
					if s != "joker" and s != "x2_multiplier" and s != "bomb":
						non_special[s] = true
				matched = non_special.size() <= 1 and symbols.size() > 0
			"unique_count":
				matched = unique_count >= synergy["required_count"]
			"custom_meyve_festivali":
				matched = counts.get("cherry", 0) >= 3 and counts.get("lemon", 0) >= 3
			"custom_bomba_firtinasi":
				# Bomba + herhangi bir sembolden 4+ eslesme
				if counts.has("bomb"):
					for s in counts:
						if s != "bomb" and s != "joker" and s != "x2_multiplier":
							var effective: int = counts[s] + counts.get("joker", 0)
							if effective >= 4:
								matched = true
								break
			"custom_kripto_madenci":
				# x2 sembol + herhangi 3+ ayni sembol
				if counts.has("x2_multiplier"):
					for s in counts:
						if s != "x2_multiplier" and s != "joker" and s != "bomb":
							if counts[s] >= 3:
								matched = true
								break

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
