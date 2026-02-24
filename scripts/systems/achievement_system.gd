extends RefCounted

## Basarim sistemi. 60 basarim (10 erken + 15 orta + 22 gec + 13 gizli).
## Her basarim CP odulu ve nadir seviyesi (rarity) verir.

const RARITY_COLORS := {
	"common": Color(0.65, 0.65, 0.70),
	"uncommon": Color(0.25, 0.80, 0.45),
	"rare": Color(0.30, 0.55, 1.0),
	"epic": Color(0.70, 0.30, 0.90),
	"legendary": Color(1.0, 0.78, 0.15),
}

const RARITY_NAMES := {
	"common": "Yaygin",
	"uncommon": "Sira Disi",
	"rare": "Nadir",
	"epic": "Epik",
	"legendary": "Efsanevi",
}

const ACHIEVEMENTS := {
	# =============================================
	# --- ERKEN OYUN (10) ---
	# =============================================
	"ilk_kazima": {
		"name": "Ilk Kazima",
		"description": "1 bilet tamamla",
		"category": "early",
		"rarity": "common",
		"reward_cp": 2,
		"check_type": "stat_gte",
		"stat_key": "total_tickets",
		"target": 1,
	},
	"ilk_eslesme": {
		"name": "Ilk Eslesme",
		"description": "Ilk eslesmeni bul",
		"category": "early",
		"rarity": "common",
		"reward_cp": 3,
		"check_type": "stat_gte",
		"stat_key": "total_matches",
		"target": 1,
	},
	"on_bilet": {
		"name": "Isinma Turu",
		"description": "10 bilet tamamla",
		"category": "early",
		"rarity": "common",
		"reward_cp": 3,
		"check_type": "stat_gte",
		"stat_key": "total_tickets",
		"target": 10,
	},
	"kucuk_adimlar": {
		"name": "Kucuk Adimlar",
		"description": "100 toplam coin kazan",
		"category": "early",
		"rarity": "common",
		"reward_cp": 5,
		"check_type": "total_coins_gte",
		"target": 100,
	},
	"sinerji_avcisi": {
		"name": "Sinerji Avcisi",
		"description": "Ilk sinerjiyi kesfet",
		"category": "early",
		"rarity": "common",
		"reward_cp": 5,
		"check_type": "stat_gte",
		"stat_key": "total_synergies_found",
		"target": 1,
	},
	"seri_kazici": {
		"name": "Seri Kazici",
		"description": "Bir turda 10 bilet kazi",
		"category": "early",
		"rarity": "common",
		"reward_cp": 3,
		"check_type": "round_stat_gte",
		"stat_key": "tickets",
		"target": 10,
	},
	"ilk_joker": {
		"name": "Ilk Joker",
		"description": "Bir bilette Joker sembol bul",
		"category": "early",
		"rarity": "common",
		"reward_cp": 3,
		"check_type": "special_symbol_found",
		"symbol": "joker",
	},
	"ilk_bomba": {
		"name": "Ilk Bomba",
		"description": "Bir bilette Bomba sembol bul",
		"category": "early",
		"rarity": "common",
		"reward_cp": 3,
		"check_type": "special_symbol_found",
		"symbol": "bomb",
	},
	"bes_farkli_bilet": {
		"name": "Bes Farkli",
		"description": "5 farkli bilet turunde oyna",
		"category": "early",
		"rarity": "common",
		"reward_cp": 5,
		"check_type": "ticket_types_played_gte",
		"target": 5,
	},
	"elli_bilet": {
		"name": "Kazi Ustasi",
		"description": "Toplam 50 bilet kazi",
		"category": "early",
		"rarity": "common",
		"reward_cp": 5,
		"check_type": "stat_gte",
		"stat_key": "total_tickets",
		"target": 50,
	},

	# =============================================
	# --- ORTA OYUN (15) ---
	# =============================================
	"bronz_kazici": {
		"name": "Bronz Avci",
		"description": "Bronze bilette eslesme bul",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 5,
		"check_type": "ticket_tier_match",
		"tier": "bronze",
	},
	"gumus_kazici": {
		"name": "Gumus Kazici",
		"description": "Gumus bilette eslesme bul",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 5,
		"check_type": "ticket_tier_match",
		"tier": "silver",
	},
	"altin_avci": {
		"name": "Altin Avci",
		"description": "Altin bilette eslesme bul",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 10,
		"check_type": "ticket_tier_match",
		"tier": "gold",
	},
	"jackpot": {
		"name": "Jackpot!",
		"description": "Ilk jackpot'u vur",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 10,
		"check_type": "stat_gte",
		"stat_key": "total_jackpots",
		"target": 1,
	},
	"bes_jackpot": {
		"name": "Jackpot Avcisi",
		"description": "5 jackpot vur",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 8,
		"check_type": "stat_gte",
		"stat_key": "total_jackpots",
		"target": 5,
	},
	"koleksiyoncu": {
		"name": "Koleksiyoncu",
		"description": "Ilk koleksiyon setini tamamla",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 10,
		"check_type": "any_set_complete",
	},
	"zengin_tur": {
		"name": "Zengin Tur",
		"description": "Bir turda 500+ coin kazan",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 8,
		"check_type": "round_stat_gte",
		"stat_key": "coins_earned",
		"target": 500,
	},
	"uc_sinerji": {
		"name": "Sinerji Koleksiyoncusu",
		"description": "3 farkli sinerji kesfet",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 8,
		"check_type": "synergies_discovered_gte",
		"target": 3,
	},
	"on_koleksiyon": {
		"name": "Parca Avcisi",
		"description": "10 koleksiyon parcasi topla",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 8,
		"check_type": "total_pieces_gte",
		"target": 10,
	},
	"yirmi_koleksiyon": {
		"name": "Parca Ustasi",
		"description": "20 koleksiyon parcasi topla",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 10,
		"check_type": "total_pieces_gte",
		"target": 20,
	},
	"bin_coin": {
		"name": "Bin Coin",
		"description": "Toplam 1000 coin kazan",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 10,
		"check_type": "total_coins_gte",
		"target": 1000,
	},
	"bes_bin_coin": {
		"name": "Bes Bin",
		"description": "Toplam 5000 coin kazan",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 10,
		"check_type": "total_coins_gte",
		"target": 5000,
	},
	"gold_oyna": {
		"name": "Altin Ates",
		"description": "Gold bilette jackpot vur",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 12,
		"check_type": "ticket_tier_jackpot",
		"tier": "gold",
	},
	"yuz_bilet": {
		"name": "Kazi Baronu",
		"description": "Toplam 100 bilet kazi",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 10,
		"check_type": "stat_gte",
		"stat_key": "total_tickets",
		"target": 100,
	},
	"iki_set": {
		"name": "Set Koleksiyoncusu",
		"description": "2 koleksiyon seti tamamla",
		"category": "mid",
		"rarity": "uncommon",
		"reward_cp": 10,
		"check_type": "sets_complete_gte",
		"target": 2,
	},

	# =============================================
	# --- GEC OYUN (22) ---
	# =============================================
	"platin_seri": {
		"name": "Platin Seri",
		"description": "Platin bilette eslesme bul",
		"category": "late",
		"rarity": "rare",
		"reward_cp": 15,
		"check_type": "ticket_tier_match",
		"tier": "platinum",
	},
	"diamond_kazici": {
		"name": "Elmas Avci",
		"description": "Diamond bilette eslesme bul",
		"category": "late",
		"rarity": "rare",
		"reward_cp": 15,
		"check_type": "ticket_tier_match",
		"tier": "diamond_tier",
	},
	"emerald_kazici": {
		"name": "Zumrut Avci",
		"description": "Emerald bilette eslesme bul",
		"category": "late",
		"rarity": "rare",
		"reward_cp": 18,
		"check_type": "ticket_tier_match",
		"tier": "emerald_tier",
	},
	"ruby_kazici": {
		"name": "Yakut Avci",
		"description": "Ruby bilette eslesme bul",
		"category": "late",
		"rarity": "epic",
		"reward_cp": 20,
		"check_type": "ticket_tier_match",
		"tier": "ruby_tier",
	},
	"obsidian_kazici": {
		"name": "Obsidyen Avci",
		"description": "Obsidian bilette eslesme bul",
		"category": "late",
		"rarity": "epic",
		"reward_cp": 22,
		"check_type": "ticket_tier_match",
		"tier": "obsidian",
	},
	"legendary_kazici": {
		"name": "Efsane Avci",
		"description": "Legendary bilette eslesme bul",
		"category": "late",
		"rarity": "legendary",
		"reward_cp": 25,
		"check_type": "ticket_tier_match",
		"tier": "legendary",
	},
	"combo_master": {
		"name": "Combo Master",
		"description": "5 farkli sinerji kesfet",
		"category": "late",
		"rarity": "rare",
		"reward_cp": 15,
		"check_type": "synergies_discovered_gte",
		"target": 5,
	},
	"milyoner": {
		"name": "Milyoner",
		"description": "Bir turda 1000+ coin kazan",
		"category": "late",
		"rarity": "rare",
		"reward_cp": 20,
		"check_type": "round_stat_gte",
		"stat_key": "coins_earned",
		"target": 1000,
	},
	"tam_set": {
		"name": "Tam Set",
		"description": "Tum koleksiyonlari tamamla",
		"category": "late",
		"rarity": "epic",
		"reward_cp": 30,
		"check_type": "all_sets_complete",
	},
	"charm_ustasi": {
		"name": "Charm Ustasi",
		"description": "50 charm seviyesi topla",
		"category": "late",
		"rarity": "rare",
		"reward_cp": 20,
		"check_type": "total_charm_levels_gte",
		"target": 50,
	},
	"tum_sinerjiler": {
		"name": "Sinerji Ustasi",
		"description": "Tum sinerjileri kesfet",
		"category": "late",
		"rarity": "epic",
		"reward_cp": 25,
		"check_type": "all_synergies_discovered",
	},
	"elli_jackpot": {
		"name": "Jackpot Krali",
		"description": "Toplam 50 jackpot vur",
		"category": "late",
		"rarity": "rare",
		"reward_cp": 20,
		"check_type": "stat_gte",
		"stat_key": "total_jackpots",
		"target": 50,
	},
	"on_bin_coin": {
		"name": "Zengin",
		"description": "Toplam 10000 coin kazan",
		"category": "late",
		"rarity": "rare",
		"reward_cp": 20,
		"check_type": "total_coins_gte",
		"target": 10000,
	},
	"tum_charmlar": {
		"name": "Charm Gurusu",
		"description": "En az 15 charm satin al",
		"category": "late",
		"rarity": "epic",
		"reward_cp": 25,
		"check_type": "total_charms_owned_gte",
		"target": 15,
	},
	"yuz_bin_coin": {
		"name": "Yuz Bin",
		"description": "Toplam 100K coin kazan",
		"category": "late",
		"rarity": "rare",
		"reward_cp": 20,
		"check_type": "total_coins_gte",
		"target": 100000,
	},
	"bes_yuz_bilet": {
		"name": "Bilet Baronu",
		"description": "Toplam 500 bilet kazi",
		"category": "late",
		"rarity": "rare",
		"reward_cp": 20,
		"check_type": "stat_gte",
		"stat_key": "total_tickets",
		"target": 500,
	},
	"bin_bilet": {
		"name": "Bilet Imparatoru",
		"description": "Toplam 1000 bilet kazi",
		"category": "late",
		"rarity": "epic",
		"reward_cp": 25,
		"check_type": "stat_gte",
		"stat_key": "total_tickets",
		"target": 1000,
	},
	"yuz_jackpot": {
		"name": "Jackpot Imparatoru",
		"description": "Toplam 100 jackpot vur",
		"category": "late",
		"rarity": "epic",
		"reward_cp": 25,
		"check_type": "stat_gte",
		"stat_key": "total_jackpots",
		"target": 100,
	},
	"on_charm": {
		"name": "Charm Koleksiyonu",
		"description": "10 charm satin al",
		"category": "late",
		"rarity": "rare",
		"reward_cp": 12,
		"check_type": "total_charms_owned_gte",
		"target": 10,
	},
	"dort_set": {
		"name": "Set Ustasi",
		"description": "4 koleksiyon seti tamamla",
		"category": "late",
		"rarity": "rare",
		"reward_cp": 15,
		"check_type": "sets_complete_gte",
		"target": 4,
	},
	"diamond_jackpot": {
		"name": "Elmas Jackpot",
		"description": "Diamond bilette jackpot vur",
		"category": "late",
		"rarity": "epic",
		"reward_cp": 20,
		"check_type": "ticket_tier_jackpot",
		"tier": "diamond_tier",
	},
	"legendary_jackpot": {
		"name": "Efsane Jackpot",
		"description": "Legendary bilette jackpot vur",
		"category": "late",
		"rarity": "legendary",
		"reward_cp": 30,
		"check_type": "ticket_tier_jackpot",
		"tier": "legendary",
	},

	# =============================================
	# --- GIZLI BASARIMLAR (13) ---
	# =============================================
	"joker_ustasi": {
		"name": "???",
		"real_name": "Joker Ustasi",
		"description": "???",
		"real_description": "Tek bilette 3+ Joker bul",
		"category": "hidden",
		"rarity": "epic",
		"reward_cp": 15,
		"check_type": "hidden_joker_count",
		"target": 3,
	},
	"seri_eslesme": {
		"name": "???",
		"real_name": "Seri Eslesme",
		"description": "???",
		"real_description": "Ardisik 5 bilet eslesme",
		"category": "hidden",
		"rarity": "rare",
		"reward_cp": 10,
		"check_type": "hidden_match_streak",
		"target": 5,
	},
	"cift_sinerji": {
		"name": "???",
		"real_name": "Cift Sinerji",
		"description": "???",
		"real_description": "Tek bilette 2 sinerji bul",
		"category": "hidden",
		"rarity": "epic",
		"reward_cp": 20,
		"check_type": "hidden_double_synergy",
	},
	"sifirdan_zirveye": {
		"name": "???",
		"real_name": "Sifirdan Zirveye",
		"description": "???",
		"real_description": "Bonus olmadan baslayip 500+ coin bitir",
		"category": "hidden",
		"rarity": "epic",
		"reward_cp": 25,
		"check_type": "hidden_zero_to_hero",
	},
	"joker_cilginligi": {
		"name": "???",
		"real_name": "Joker Cilginligi",
		"description": "???",
		"real_description": "Tek bilette 4+ Joker bul",
		"category": "hidden",
		"rarity": "epic",
		"reward_cp": 18,
		"check_type": "hidden_joker_count",
		"target": 4,
	},
	"bomba_zinciri": {
		"name": "???",
		"real_name": "Bomba Zinciri",
		"description": "???",
		"real_description": "Bomba + Jackpot ayni bilet",
		"category": "hidden",
		"rarity": "epic",
		"reward_cp": 20,
		"check_type": "hidden_bomb_jackpot",
	},
	"sanssiz_sansli": {
		"name": "???",
		"real_name": "Sanssiz Sansli",
		"description": "???",
		"real_description": "5 ust uste eslesme yok, sonra jackpot",
		"category": "hidden",
		"rarity": "epic",
		"reward_cp": 25,
		"check_type": "hidden_unlucky_lucky",
	},
	"mukemmel_tur": {
		"name": "???",
		"real_name": "Mukemmel Tur",
		"description": "???",
		"real_description": "1 turda tum biletlerde eslesme bul",
		"category": "hidden",
		"rarity": "legendary",
		"reward_cp": 30,
		"check_type": "hidden_perfect_round",
	},
	"bes_joker": {
		"name": "???",
		"real_name": "Joker Festivali",
		"description": "???",
		"real_description": "Tek bilette 5+ Joker bul",
		"category": "hidden",
		"rarity": "legendary",
		"reward_cp": 25,
		"check_type": "hidden_joker_count",
		"target": 5,
	},
	"uc_sinerji_tek": {
		"name": "???",
		"real_name": "Uclu Sinerji",
		"description": "???",
		"real_description": "Tek bilette 3+ sinerji bul",
		"category": "hidden",
		"rarity": "legendary",
		"reward_cp": 25,
		"check_type": "hidden_triple_synergy",
	},
	"on_seri": {
		"name": "???",
		"real_name": "Durdurulamaz",
		"description": "???",
		"real_description": "Ardisik 10 bilet eslesme",
		"category": "hidden",
		"rarity": "epic",
		"reward_cp": 20,
		"check_type": "hidden_match_streak",
		"target": 10,
	},
	"zengin_tur_buyuk": {
		"name": "???",
		"real_name": "Kral Midas",
		"description": "???",
		"real_description": "Bir turda 10K+ coin kazan",
		"category": "hidden",
		"rarity": "legendary",
		"reward_cp": 25,
		"check_type": "hidden_rich_round",
		"target": 10000,
	},
	"ilk_bilet_jackpot": {
		"name": "???",
		"real_name": "Yeni Baslayanin Sansi",
		"description": "???",
		"real_description": "Turun ilk biletinde jackpot vur",
		"category": "hidden",
		"rarity": "epic",
		"reward_cp": 20,
		"check_type": "hidden_first_ticket_jackpot",
	},
}

const ACHIEVEMENT_ORDER := [
	# Erken (10)
	"ilk_kazima", "ilk_eslesme", "on_bilet", "kucuk_adimlar", "sinerji_avcisi",
	"seri_kazici", "ilk_joker", "ilk_bomba", "bes_farkli_bilet", "elli_bilet",
	# Orta (15)
	"bronz_kazici", "gumus_kazici", "altin_avci", "jackpot", "bes_jackpot",
	"koleksiyoncu", "zengin_tur", "uc_sinerji", "on_koleksiyon", "yirmi_koleksiyon",
	"bin_coin", "bes_bin_coin", "gold_oyna", "yuz_bilet", "iki_set",
	# Gec (22)
	"platin_seri", "diamond_kazici", "emerald_kazici", "ruby_kazici", "obsidian_kazici",
	"legendary_kazici", "combo_master", "milyoner", "tam_set", "charm_ustasi",
	"tum_sinerjiler", "elli_jackpot", "on_bin_coin", "tum_charmlar", "yuz_bin_coin",
	"bes_yuz_bilet", "bin_bilet", "yuz_jackpot", "on_charm", "dort_set",
	"diamond_jackpot", "legendary_jackpot",
	# Gizli (13)
	"joker_ustasi", "seri_eslesme", "cift_sinerji", "sifirdan_zirveye",
	"joker_cilginligi", "bomba_zinciri", "sanssiz_sansli", "mukemmel_tur",
	"bes_joker", "uc_sinerji_tek", "on_seri", "zengin_tur_buyuk", "ilk_bilet_jackpot",
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
			"sets_complete_gte":
				var complete_count := 0
				for set_id in CollectionRef.SET_ORDER:
					if CollectionRef.is_set_complete(set_id):
						complete_count += 1
				unlocked = complete_count >= ach["target"]
			"synergies_discovered_gte":
				unlocked = GameState.discovered_synergies.size() >= ach["target"]
			"total_charm_levels_gte":
				unlocked = GameState.get_total_charm_levels() >= ach["target"]
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
			# --- Gizli basarim kontrolleri ---
			"hidden_joker_count":
				var symbols: Array = context.get("symbols", [])
				var joker_count := 0
				for s in symbols:
					if s == "joker":
						joker_count += 1
				unlocked = joker_count >= ach.get("target", 3)
			"hidden_match_streak":
				unlocked = GameState._current_match_streak >= ach["target"]
			"hidden_double_synergy":
				var synergies: Array = context.get("synergies", [])
				unlocked = synergies.size() >= 2
			"hidden_triple_synergy":
				var synergies: Array = context.get("synergies", [])
				unlocked = synergies.size() >= 3
			"hidden_zero_to_hero":
				if context.get("round_end", false):
					var starting: int = GameState.get_starting_coins()
					unlocked = starting <= 20 and GameState.coins >= 500
			"hidden_bomb_jackpot":
				var match_data: Dictionary = context.get("match_data", {})
				unlocked = match_data.get("has_bomb", false) and match_data.get("tier", "") == "jackpot"
			"hidden_unlucky_lucky":
				var match_data: Dictionary = context.get("match_data", {})
				unlocked = context.get("was_on_loss_streak", false) and match_data.get("tier", "") == "jackpot"
			"hidden_perfect_round":
				if context.get("round_end", false):
					var rt: int = GameState.round_stats.get("tickets", 0)
					var rm: int = GameState.round_stats.get("matches", 0)
					unlocked = rt >= 5 and rm == rt
			"hidden_rich_round":
				if context.get("round_end", false):
					var coins: int = GameState.round_stats.get("coins_earned", 0)
					unlocked = coins >= ach.get("target", 10000)
			"hidden_first_ticket_jackpot":
				var match_data: Dictionary = context.get("match_data", {})
				unlocked = GameState.round_stats.get("tickets", 0) == 1 and match_data.get("tier", "") == "jackpot"

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


## Basarimin nadir rengi
static func get_rarity_color(ach_id: String) -> Color:
	var ach: Dictionary = ACHIEVEMENTS.get(ach_id, {})
	var rarity: String = ach.get("rarity", "common")
	return RARITY_COLORS.get(rarity, RARITY_COLORS["common"])


## Kategori basarim sayisi
static func get_category_counts(category: String) -> Dictionary:
	var total := 0
	var unlocked := 0
	for ach_id in ACHIEVEMENT_ORDER:
		var ach: Dictionary = ACHIEVEMENTS.get(ach_id, {})
		if ach.get("category", "") == category:
			total += 1
			if ach_id in GameState.unlocked_achievements:
				unlocked += 1
	return {"total": total, "unlocked": unlocked}
