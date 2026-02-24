extends RefCounted

## Gunluk gorev sistemi. Her gun 3 rastgele gorev, tamamlayinca bonus CP.

## Gorev sablonlari: { id, name, description, target, reward_cp, category, check_type, ... }
const QUEST_TEMPLATES := [
	# Kolay gorevler (reward: 2 CP)
	{"id": "kazi_5", "name": "Gunluk Kazici", "description": "5 bilet kazi", "target": 5, "reward_cp": 2, "category": "easy", "check_type": "tickets"},
	{"id": "eslesme_3", "name": "Eslesme Avcisi", "description": "3 eslesme bul", "target": 3, "reward_cp": 2, "category": "easy", "check_type": "matches"},
	{"id": "coin_100", "name": "Coin Toplama", "description": "100 coin kazan", "target": 100, "reward_cp": 2, "category": "easy", "check_type": "coins_earned"},
	{"id": "tur_1", "name": "Gunluk Tur", "description": "1 tur oyna", "target": 1, "reward_cp": 2, "category": "easy", "check_type": "rounds"},
	# Orta gorevler (reward: 3 CP)
	{"id": "sinerji_1", "name": "Sinerji Bul", "description": "1 sinerji tetikle", "target": 1, "reward_cp": 3, "category": "medium", "check_type": "synergies"},
	{"id": "kazi_15", "name": "Kazi Maratonu", "description": "15 bilet kazi", "target": 15, "reward_cp": 3, "category": "medium", "check_type": "tickets"},
	{"id": "jackpot_1", "name": "Jackpot Pesinde", "description": "1 jackpot vur", "target": 1, "reward_cp": 3, "category": "medium", "check_type": "jackpots"},
	{"id": "streak_3", "name": "Seri Yakalayici", "description": "3 ardisik eslesme", "target": 3, "reward_cp": 3, "category": "medium", "check_type": "streak"},
	{"id": "koleksiyon_1", "name": "Parca Avcisi", "description": "1 koleksiyon parcasi bul", "target": 1, "reward_cp": 3, "category": "medium", "check_type": "collection_drops"},
	# Zor gorevler (reward: 5 CP)
	{"id": "gold_oyna", "name": "Altin Cesareti", "description": "Gold bilet oyna", "target": 1, "reward_cp": 5, "category": "hard", "check_type": "gold_ticket"},
	{"id": "coin_500", "name": "Buyuk Kazanc", "description": "500 coin kazan", "target": 500, "reward_cp": 5, "category": "hard", "check_type": "coins_earned"},
	{"id": "eslesme_10", "name": "Eslesme Ustasi", "description": "10 eslesme bul", "target": 10, "reward_cp": 5, "category": "hard", "check_type": "matches"},
	{"id": "platin_oyna", "name": "Platin Cesaret", "description": "Platinum bilet oyna", "target": 1, "reward_cp": 5, "category": "hard", "check_type": "platinum_ticket"},
]

const DAILY_BONUS_CP := 5  # 3/3 tamamlayinca ekstra bonus


## Gunluk gorevleri kontrol et, gerekirse yenile
static func check_and_refresh_quests() -> void:
	var today: String = _get_today_string()
	if GameState.daily_quest_date != today:
		_generate_daily_quests()
		GameState.daily_quest_date = today
		GameState.daily_bonus_claimed = false
		SaveManager.save_game()
		print("[DailyQuest] Yeni gunluk gorevler olusturuldu: ", today)


## Bugunun tarihini al
static func _get_today_string() -> String:
	var dt := Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d" % [dt["year"], dt["month"], dt["day"]]


## 3 rastgele gorev sec (1 kolay, 1 orta, 1 zor)
static func _generate_daily_quests() -> void:
	var easy: Array = []
	var medium: Array = []
	var hard: Array = []

	for t in QUEST_TEMPLATES:
		match t["category"]:
			"easy": easy.append(t)
			"medium": medium.append(t)
			"hard": hard.append(t)

	easy.shuffle()
	medium.shuffle()
	hard.shuffle()

	GameState.daily_quests = []
	if easy.size() > 0:
		GameState.daily_quests.append(_make_quest(easy[0]))
	if medium.size() > 0:
		GameState.daily_quests.append(_make_quest(medium[0]))
	if hard.size() > 0:
		GameState.daily_quests.append(_make_quest(hard[0]))


## Gorev verisi olustur
static func _make_quest(template: Dictionary) -> Dictionary:
	return {
		"id": template["id"],
		"name": template["name"],
		"description": template["description"],
		"target": template["target"],
		"reward_cp": template["reward_cp"],
		"check_type": template["check_type"],
		"progress": 0,
		"completed": false,
		"reward_claimed": false,
	}


## Gorev ilerlemesini guncelle (bilet sonrasi cagirilir)
## context: { "tickets": 1, "matches": 0/1, "jackpots": 0/1, "coins_earned": int,
##            "synergies": int, "streak": int, "collection_drops": 0/1,
##            "ticket_type": String, "rounds": 0/1 }
static func update_progress(context: Dictionary) -> Array:
	var newly_completed: Array = []

	for quest in GameState.daily_quests:
		if quest["completed"]:
			continue

		var added := 0
		match quest["check_type"]:
			"tickets":
				added = context.get("tickets", 0)
			"matches":
				added = context.get("matches", 0)
			"coins_earned":
				added = context.get("coins_earned", 0)
			"rounds":
				added = context.get("rounds", 0)
			"synergies":
				added = context.get("synergies", 0)
			"jackpots":
				added = context.get("jackpots", 0)
			"streak":
				# Streak en yuksek degeri al
				var streak_val: int = context.get("streak", 0)
				if streak_val > quest["progress"]:
					quest["progress"] = streak_val
					if quest["progress"] >= quest["target"]:
						quest["completed"] = true
						newly_completed.append(quest)
					continue
			"collection_drops":
				added = context.get("collection_drops", 0)
			"gold_ticket":
				if context.get("ticket_type", "") == "gold":
					added = 1
			"platinum_ticket":
				if context.get("ticket_type", "") == "platinum":
					added = 1

		if added > 0:
			quest["progress"] += added
			if quest["progress"] >= quest["target"]:
				quest["completed"] = true
				newly_completed.append(quest)

	return newly_completed


## Gorev odulunu topla
static func claim_quest_reward(quest_index: int) -> int:
	if quest_index < 0 or quest_index >= GameState.daily_quests.size():
		return 0
	var quest: Dictionary = GameState.daily_quests[quest_index]
	if not quest["completed"] or quest["reward_claimed"]:
		return 0
	quest["reward_claimed"] = true
	GameState.charm_points += quest["reward_cp"]
	SaveManager.save_game()
	return quest["reward_cp"]


## Tum gorevler tamamlandi mi
static func all_quests_completed() -> bool:
	for quest in GameState.daily_quests:
		if not quest["completed"]:
			return false
	return GameState.daily_quests.size() >= 3


## Gunluk bonusu topla (3/3 tamamlandiysa)
static func claim_daily_bonus() -> int:
	if not all_quests_completed() or GameState.daily_bonus_claimed:
		return 0
	GameState.daily_bonus_claimed = true
	GameState.charm_points += DAILY_BONUS_CP
	SaveManager.save_game()
	return DAILY_BONUS_CP


## Gorev bilgilerini goster icin
static func get_quest_display() -> Array:
	return GameState.daily_quests
