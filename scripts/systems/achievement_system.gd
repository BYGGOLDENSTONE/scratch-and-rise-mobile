extends RefCounted

## Basarim sistemi. 19 basarim (5 erken + 5 orta + 5 gec + 4 gizli).
## Her basarim CP odulu verir.

const ACHIEVEMENTS := {
	# --- Erken Oyun ---
	"ilk_kazima": {
		"name": "Ilk Kazima",
		"description": "1 bilet tamamla",
		"category": "early",
		"reward_cp": 2,
		"check_type": "stat_gte",
		"stat_key": "total_tickets",
		"target": 1,
	},
	"ilk_eslesme": {
		"name": "Ilk Eslesme",
		"description": "Ilk eslesmeni bul",
		"category": "early",
		"reward_cp": 3,
		"check_type": "stat_gte",
		"stat_key": "total_matches",
		"target": 1,
	},
	"kucuk_adimlar": {
		"name": "Kucuk Adimlar",
		"description": "100 toplam coin kazan",
		"category": "early",
		"reward_cp": 5,
		"check_type": "total_coins_gte",
		"target": 100,
	},
	"sinerji_avcisi": {
		"name": "Sinerji Avcisi",
		"description": "Ilk sinerjiyi kesfet",
		"category": "early",
		"reward_cp": 5,
		"check_type": "stat_gte",
		"stat_key": "total_synergies_found",
		"target": 1,
	},
	"seri_kazici": {
		"name": "Seri Kazici",
		"description": "Bir turda 10 bilet kazi",
		"category": "early",
		"reward_cp": 3,
		"check_type": "round_stat_gte",
		"stat_key": "tickets",
		"target": 10,
	},
	# --- Orta Oyun ---
	"gumus_kazici": {
		"name": "Gumus Kazici",
		"description": "Gumus bilet ac",
		"category": "mid",
		"reward_cp": 5,
		"check_type": "charm_unlocked",
		"charm_id": "gumus_anahtar",
	},
	"altin_avci": {
		"name": "Altin Avci",
		"description": "Altin bilet ac",
		"category": "mid",
		"reward_cp": 10,
		"check_type": "charm_unlocked",
		"charm_id": "altin_anahtar",
	},
	"jackpot": {
		"name": "Jackpot!",
		"description": "Ilk jackpot'u vur",
		"category": "mid",
		"reward_cp": 10,
		"check_type": "stat_gte",
		"stat_key": "total_jackpots",
		"target": 1,
	},
	"koleksiyoncu": {
		"name": "Koleksiyoncu",
		"description": "Ilk koleksiyon setini tamamla",
		"category": "mid",
		"reward_cp": 10,
		"check_type": "any_set_complete",
	},
	"zengin_tur": {
		"name": "Zengin Tur",
		"description": "Bir turda 500+ coin kazan",
		"category": "mid",
		"reward_cp": 8,
		"check_type": "round_stat_gte",
		"stat_key": "coins_earned",
		"target": 500,
	},
	# --- Gec Oyun ---
	"platin_seri": {
		"name": "Platin Seri",
		"description": "Platin bilet ac",
		"category": "late",
		"reward_cp": 15,
		"check_type": "charm_unlocked",
		"charm_id": "platin_anahtar",
	},
	"combo_master": {
		"name": "Combo Master",
		"description": "5 farkli sinerji kesfet",
		"category": "late",
		"reward_cp": 15,
		"check_type": "synergies_discovered_gte",
		"target": 5,
	},
	"milyoner": {
		"name": "Milyoner",
		"description": "Bir turda 1000+ coin kazan",
		"category": "late",
		"reward_cp": 20,
		"check_type": "round_stat_gte",
		"stat_key": "coins_earned",
		"target": 1000,
	},
	"tam_set": {
		"name": "Tam Set",
		"description": "Tum koleksiyonlari tamamla",
		"category": "late",
		"reward_cp": 30,
		"check_type": "all_sets_complete",
	},
	"charm_ustasi": {
		"name": "Charm Ustasi",
		"description": "50 charm seviyesi topla",
		"category": "late",
		"reward_cp": 20,
		"check_type": "total_charm_levels_gte",
		"target": 50,
	},
	# --- Gizli Basarimlar ---
	"joker_ustasi": {
		"name": "???",
		"real_name": "Joker Ustasi",
		"description": "???",
		"real_description": "3x Joker ayni bilette",
		"category": "hidden",
		"reward_cp": 15,
		"check_type": "hidden_triple_joker",
	},
	"seri_eslesme": {
		"name": "???",
		"real_name": "Seri Eslesme",
		"description": "???",
		"real_description": "Ardisik 5 bilet eslesme",
		"category": "hidden",
		"reward_cp": 10,
		"check_type": "hidden_match_streak",
		"target": 5,
	},
	"cift_sinerji": {
		"name": "???",
		"real_name": "Cift Sinerji",
		"description": "???",
		"real_description": "Tek bilette 2 sinerji",
		"category": "hidden",
		"reward_cp": 20,
		"check_type": "hidden_double_synergy",
	},
	"sifirdan_zirveye": {
		"name": "???",
		"real_name": "Sifirdan Zirveye",
		"description": "???",
		"real_description": "0 coin baslangic + 500+ coin bitir",
		"category": "hidden",
		"reward_cp": 25,
		"check_type": "hidden_zero_to_hero",
	},
}

const ACHIEVEMENT_ORDER := [
	# Erken
	"ilk_kazima", "ilk_eslesme", "kucuk_adimlar", "sinerji_avcisi", "seri_kazici",
	# Orta
	"gumus_kazici", "altin_avci", "jackpot", "koleksiyoncu", "zengin_tur",
	# Gec
	"platin_seri", "combo_master", "milyoner", "tam_set", "charm_ustasi",
	# Gizli
	"joker_ustasi", "seri_eslesme", "cift_sinerji", "sifirdan_zirveye",
]

const CATEGORY_NAMES := {
	"early": "ERKEN OYUN",
	"mid": "ORTA OYUN",
	"late": "GEC OYUN",
	"hidden": "GIZLI",
}

const CollectionRef := preload("res://scripts/systems/collection_system.gd")


## Yeni acilan basarimlari kontrol eder.
## context: { "symbols", "match_data", "synergies", "round_end" ... }
## Doner: Yeni acilan basarim ID'lerinin listesi
static func check_achievements(context: Dictionary) -> Array:
	var newly_unlocked: Array = []

	for ach_id in ACHIEVEMENT_ORDER:
		# Zaten acilmissa atla
		if ach_id in GameState.unlocked_achievements:
			continue

		var ach: Dictionary = ACHIEVEMENTS[ach_id]
		var unlocked := false

		match ach["check_type"]:
			"stat_gte":
				var val: int = GameState.stats.get(ach["stat_key"], 0)
				unlocked = val >= ach["target"]
			"round_stat_gte":
				var val: int = GameState.round_stats.get(ach["stat_key"], 0)
				unlocked = val >= ach["target"]
			"total_coins_gte":
				unlocked = GameState.total_coins_earned >= ach["target"]
			"charm_unlocked":
				unlocked = GameState.get_charm_level(ach["charm_id"]) > 0
			"any_set_complete":
				for set_id in CollectionRef.SET_ORDER:
					if CollectionRef.is_set_complete(set_id):
						unlocked = true
						break
			"all_sets_complete":
				unlocked = true
				for set_id in CollectionRef.SET_ORDER:
					if not CollectionRef.is_set_complete(set_id):
						unlocked = false
						break
			"synergies_discovered_gte":
				unlocked = GameState.discovered_synergies.size() >= ach["target"]
			"total_charm_levels_gte":
				unlocked = GameState.get_total_charm_levels() >= ach["target"]
			"hidden_triple_joker":
				var symbols: Array = context.get("symbols", [])
				var joker_count := 0
				for s in symbols:
					if s == "joker":
						joker_count += 1
				unlocked = joker_count >= 3
			"hidden_match_streak":
				unlocked = GameState._current_match_streak >= ach["target"]
			"hidden_double_synergy":
				var synergies: Array = context.get("synergies", [])
				unlocked = synergies.size() >= 2
			"hidden_zero_to_hero":
				if context.get("round_end", false):
					var starting: int = GameState.get_starting_coins()
					unlocked = starting == 50 and GameState.get_total_charm_levels() == 0 and GameState.coins >= 500

		if unlocked:
			newly_unlocked.append(ach_id)

	return newly_unlocked


## Basarim bilgisini getir
static func get_achievement(ach_id: String) -> Dictionary:
	return ACHIEVEMENTS.get(ach_id, {})


## Basarim gosterim ismini getir (gizli basarimlar icin kontrol)
static func get_display_name(ach_id: String) -> String:
	var ach: Dictionary = ACHIEVEMENTS.get(ach_id, {})
	if ach.is_empty():
		return ach_id
	var is_unlocked: bool = ach_id in GameState.unlocked_achievements
	if ach.get("category", "") == "hidden" and not is_unlocked:
		return "???"
	return ach.get("real_name", ach.get("name", ach_id))


## Basarim gosterim aciklamasi
static func get_display_description(ach_id: String) -> String:
	var ach: Dictionary = ACHIEVEMENTS.get(ach_id, {})
	if ach.is_empty():
		return ""
	var is_unlocked: bool = ach_id in GameState.unlocked_achievements
	if ach.get("category", "") == "hidden" and not is_unlocked:
		return "???"
	return ach.get("real_description", ach.get("description", ""))
