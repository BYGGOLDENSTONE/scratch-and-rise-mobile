extends RefCounted

## Koleksiyon sistemi. Biletlerden parca duser, set tamamlama = kalici bonus.

const COLLECTION_SETS := {
	"meyve": {
		"name": "Meyve Seti",
		"pieces": ["cherry_col", "lemon_col", "grape_col", "watermelon_col"],
		"piece_names": {
			"cherry_col": "Kiraz",
			"lemon_col": "Limon",
			"grape_col": "Uzum",
			"watermelon_col": "Karpuz",
		},
		"bonus_type": "match_reward",
		"bonus_value": 0.15,
		"bonus_text": "Eslesme odulu +%15",
	},
	"degerli_taslar": {
		"name": "Degerli Taslar",
		"pieces": ["ruby_col", "emerald_col", "sapphire_col", "diamond_col"],
		"piece_names": {
			"ruby_col": "Yakut",
			"emerald_col": "Zumrut",
			"sapphire_col": "Safir",
			"diamond_col": "Elmas",
		},
		"bonus_type": "special_symbol",
		"bonus_value": 0.20,
		"bonus_text": "Ozel sembol sansi +%20",
	},
	"sansli_7ler": {
		"name": "Sansli 7'ler",
		"pieces": ["seven_red", "seven_blue", "seven_green", "seven_gold"],
		"piece_names": {
			"seven_red": "Kirmizi 7",
			"seven_blue": "Mavi 7",
			"seven_green": "Yesil 7",
			"seven_gold": "Altin 7",
		},
		"bonus_type": "jackpot_reward",
		"bonus_value": 0.25,
		"bonus_text": "Jackpot odulu +%25",
	},
	"kripto": {
		"name": "Kripto Seti",
		"pieces": ["bitcoin_col", "ethereum_col", "doge_col", "rocket_col"],
		"piece_names": {
			"bitcoin_col": "Bitcoin",
			"ethereum_col": "Ethereum",
			"doge_col": "Doge",
			"rocket_col": "Rocket",
		},
		"bonus_type": "starting_coins",
		"bonus_value": 25,
		"bonus_text": "Baslangic parasi +25",
	},
	"kozmik": {
		"name": "Kozmik Set",
		"pieces": ["star_col", "moon_col", "sun_col", "galaxy_col"],
		"piece_names": {
			"star_col": "Yildiz",
			"moon_col": "Ay",
			"sun_col": "Gunes",
			"galaxy_col": "Galaksi",
		},
		"bonus_type": "all_rewards",
		"bonus_value": 0.20,
		"bonus_text": "Tum oduller +%20",
	},
	"meme_lords": {
		"name": "Meme Lords",
		"pieces": ["doge_meme", "pepe_col", "moon_emoji", "lambo_col"],
		"piece_names": {
			"doge_meme": "Doge",
			"pepe_col": "Pepe",
			"moon_emoji": "Moon",
			"lambo_col": "Lambo",
		},
		"bonus_type": "golden_ticket",
		"bonus_value": 0.25,
		"bonus_text": "Altin bilet sansi +%25",
	},
}

const SET_ORDER := ["meyve", "degerli_taslar", "sansli_7ler", "kripto", "kozmik", "meme_lords"]

## Bilet turune gore dusme sanslari
const DROP_CHANCES := {
	"paper": 0.03,
	"bronze": 0.05,
	"silver": 0.08,
	"gold": 0.12,
	"platinum": 0.18,
}


## Bilet tamamlaninca koleksiyon parcasi dusme kontrolu.
## Doner: { "set_id": String, "piece_id": String } veya bos Dictionary
static func roll_collection_drop(ticket_type: String) -> Dictionary:
	var chance: float = DROP_CHANCES.get(ticket_type, 0.03)
	if randf() > chance:
		return {}

	# Henuz toplanmamis parcalardan rastgele birini sec
	var available: Array = []
	for set_id in SET_ORDER:
		var set_data: Dictionary = COLLECTION_SETS[set_id]
		for piece_id in set_data["pieces"]:
			if not GameState.has_collection_piece(set_id, piece_id):
				available.append({"set_id": set_id, "piece_id": piece_id})

	if available.is_empty():
		return {}

	return available[randi() % available.size()]


## Set tamamlandi mi kontrol
static func is_set_complete(set_id: String) -> bool:
	var set_data: Dictionary = COLLECTION_SETS.get(set_id, {})
	if set_data.is_empty():
		return false
	for piece_id in set_data["pieces"]:
		if not GameState.has_collection_piece(set_id, piece_id):
			return false
	return true


## Tamamlanan setlerin toplam eslesme odulu carpani
static func get_match_reward_bonus() -> float:
	var bonus := 0.0
	for set_id in SET_ORDER:
		if is_set_complete(set_id):
			var set_data: Dictionary = COLLECTION_SETS[set_id]
			if set_data["bonus_type"] == "match_reward":
				bonus += set_data["bonus_value"]
	return bonus


## Tamamlanan setlerin toplam "tum oduller" carpani
static func get_all_rewards_bonus() -> float:
	var bonus := 0.0
	for set_id in SET_ORDER:
		if is_set_complete(set_id):
			var set_data: Dictionary = COLLECTION_SETS[set_id]
			if set_data["bonus_type"] == "all_rewards":
				bonus += set_data["bonus_value"]
	return bonus


## Tamamlanan setlerin jackpot odulu carpani
static func get_jackpot_bonus() -> float:
	var bonus := 0.0
	for set_id in SET_ORDER:
		if is_set_complete(set_id):
			var set_data: Dictionary = COLLECTION_SETS[set_id]
			if set_data["bonus_type"] == "jackpot_reward":
				bonus += set_data["bonus_value"]
	return bonus


## Tamamlanan setlerin baslangic coin bonusu
static func get_starting_coins_bonus() -> int:
	var bonus := 0
	for set_id in SET_ORDER:
		if is_set_complete(set_id):
			var set_data: Dictionary = COLLECTION_SETS[set_id]
			if set_data["bonus_type"] == "starting_coins":
				bonus += int(set_data["bonus_value"])
	return bonus


## Parca ismini getir
static func get_piece_name(set_id: String, piece_id: String) -> String:
	var set_data: Dictionary = COLLECTION_SETS.get(set_id, {})
	if set_data.is_empty():
		return piece_id
	return set_data["piece_names"].get(piece_id, piece_id)


## Set bilgisini getir
static func get_set(set_id: String) -> Dictionary:
	return COLLECTION_SETS.get(set_id, {})
