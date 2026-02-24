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
		"description": "Gumus bilette eslesme bul",
		"category": "mid",
		"reward_cp": 5,
		"check_type": "ticket_tier_match",
		"tier": "silver",
	},
	"altin_avci": {
		"name": "Altin Avci",
		"description": "Altin bilette eslesme bul",
		"category": "mid",
		"reward_cp": 10,
		"check_type": "ticket_tier_match",
		"tier": "gold",
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
		"description": "Platin bilette eslesme bul",
		"category": "late",
		"reward_cp": 15,
		"check_type": "ticket_tier_match",
		"tier": "platinum",
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
	# --- Yeni Erken ---
	"ilk_joker": {
		"name": "Ilk Joker",
		"description": "Bir bilette Joker sembol bul",
		"category": "early",
		"reward_cp": 3,
		"check_type": "special_symbol_found",
		"symbol": "joker",
	},
	"ilk_bomba": {
		"name": "Ilk Bomba",
		"description": "Bir bilette Bomba sembol bul",
		"category": "early",
		"reward_cp": 3,
		"check_type": "special_symbol_found",
		"symbol": "bomb",
	},
	"bes_farkli_bilet": {
		"name": "Bes Farkli",
		"description": "5 farkli bilet turunde oyna",
		"category": "early",
		"reward_cp": 5,
		"check_type": "ticket_types_played_gte",
		"target": 5,
	},
	"elli_bilet": {
		"name": "Kazi Ustasi",
		"description": "Toplam 50 bilet kazi",
		"category": "early",
		"reward_cp": 5,
		"check_type": "stat_gte",
		"stat_key": "total_tickets",
		"target": 50,
	},
	# --- Yeni Orta ---
	"uc_sinerji": {
		"name": "Sinerji Koleksiyoncusu",
		"description": "3 farkli sinerji kesfet",
		"category": "mid",
		"reward_cp": 8,
		"check_type": "synergies_discovered_gte",
		"target": 3,
	},
	"on_koleksiyon": {
		"name": "Parca Avcisi",
		"description": "10 koleksiyon parcasi topla",
		"category": "mid",
		"reward_cp": 8,
		"check_type": "total_pieces_gte",
		"target": 10,
	},
	"bin_coin": {
		"name": "Bin Coin",
		"description": "Toplam 1000 coin kazan",
		"category": "mid",
		"reward_cp": 10,
		"check_type": "total_coins_gte",
		"target": 1000,
	},
	"gold_oyna": {
		"name": "Altin Ates",
		"description": "Gold bilette jackpot vur",
		"category": "mid",
		"reward_cp": 12,
		"check_type": "ticket_tier_jackpot",
		"tier": "gold",
	},
	# --- Yeni Gec ---
	"tum_sinerjiler": {
		"name": "Sinerji Ustasi",
		"description": "Tum sinerjileri kesfet",
		"category": "late",
		"reward_cp": 25,
		"check_type": "all_synergies_discovered",
	},
	"elli_jackpot": {
		"name": "Jackpot Krali",
		"description": "Toplam 50 jackpot vur",
		"category": "late",
		"reward_cp": 20,
		"check_type": "stat_gte",
		"stat_key": "total_jackpots",
		"target": 50,
	},
	"on_bin_coin": {
		"name": "Zengin",
		"description": "Toplam 10000 coin kazan",
		"category": "late",
		"reward_cp": 20,
		"check_type": "total_coins_gte",
		"target": 10000,
	},
	"tum_charmlar": {
		"name": "Charm Koleksiyoncusu",
		"description": "En az 15 charm satin al",
		"category": "late",
		"reward_cp": 25,
		"check_type": "total_charms_owned_gte",
		"target": 15,
	},
	# --- Yeni Gizli ---
	"joker_cilginligi": {
		"name": "???",
		"real_name": "Joker Cilginligi",
		"description": "???",
		"real_description": "Tek bilette 3+ Joker",
		"category": "hidden",
		"reward_cp": 15,
		"check_type": "hidden_triple_joker",
	},
	"bomba_zinciri": {
		"name": "???",
		"real_name": "Bomba Zinciri",
		"description": "???",
		"real_description": "Bomba + Jackpot ayni bilet",
		"category": "hidden",
		"reward_cp": 20,
		"check_type": "hidden_bomb_jackpot",
	},
	"sanssiz_sansli": {
		"name": "???",
		"real_name": "Sanssiz Sansli",
		"description": "???",
		"real_description": "5 ust uste eslesme yok, sonra jackpot",
		"category": "hidden",
		"reward_cp": 25,
		"check_type": "hidden_unlucky_lucky",
	},
	"mukemmel_tur": {
		"name": "???",
		"real_name": "Mukemmel Tur",
		"description": "???",
		"real_description": "1 turda tum biletlerde eslesme bul",
		"category": "hidden",
		"reward_cp": 30,
		"check_type": "hidden_perfect_round",
	},
	# --- Gizli Basarimlar (Orijinal) ---
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
	"ilk_joker", "ilk_bomba", "bes_farkli_bilet", "elli_bilet",
	# Orta
	"gumus_kazici", "altin_avci", "jackpot", "koleksiyoncu", "zengin_tur",
	"uc_sinerji", "on_koleksiyon", "bin_coin", "gold_oyna",
	# Gec
	"platin_seri", "combo_master", "milyoner", "tam_set", "charm_ustasi",
	"tum_sinerjiler", "elli_jackpot", "on_bin_coin", "tum_charmlar",
	# Gizli
	"joker_ustasi", "seri_eslesme", "cift_sinerji", "sifirdan_zirveye",
	"joker_cilginligi", "bomba_zinciri", "sanssiz_sansli", "mukemmel_tur",
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
			# --- Yeni check type'lar ---
			"ticket_tier_match":
				var match_data: Dictionary = context.get("match_data", {})
				var tier: String = ach.get("tier", "")
				unlocked = match_data.get("has_match", false) and context.get("ticket_type", "") == tier
			"ticket_tier_jackpot":
				var match_data: Dictionary = context.get("match_data", {})
				var tier: String = ach.get("tier", "")
				unlocked = match_data.get("tier", "") == "jackpot" and context.get("ticket_type", "") == tier
			"special_symbol_found":
				var symbols: Array = context.get("symbols", [])
				unlocked = ach.get("symbol", "") in symbols
			"ticket_types_played_gte":
				var played: Array = GameState.stats.get("ticket_types_played", [])
				unlocked = played.size() >= ach["target"]
			"total_pieces_gte":
				var total := 0
				for pieces in GameState.collected_pieces.values():
					total += pieces.size()
				unlocked = total >= ach["target"]
			"all_synergies_discovered":
				var SynergyRef := preload("res://scripts/systems/synergy_system.gd")
				unlocked = GameState.discovered_synergies.size() >= SynergyRef.SYNERGY_ORDER.size()
			"total_charms_owned_gte":
				unlocked = GameState.charms.size() >= ach["target"]
			"hidden_bomb_jackpot":
				var match_data: Dictionary = context.get("match_data", {})
				unlocked = match_data.get("has_bomb", false) and match_data.get("tier", "") == "jackpot"
			"hidden_unlucky_lucky":
				# 5 ust uste eslesme yoktu, simdi jackpot (streak -5'ten 0'a dusmus + jackpot)
				var match_data: Dictionary = context.get("match_data", {})
				unlocked = context.get("was_on_loss_streak", false) and match_data.get("tier", "") == "jackpot"
			"hidden_perfect_round":
				if context.get("round_end", false):
					var rt: int = GameState.round_stats.get("tickets", 0)
					var rm: int = GameState.round_stats.get("matches", 0)
					unlocked = rt >= 5 and rm == rt  # Tum biletlerde eslesme + en az 5 bilet

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
