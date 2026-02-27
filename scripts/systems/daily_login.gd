extends RefCounted

## Gunluk giris odulu sistemi. 7 gunluk ardisik giris dongusu.
## 1 gun atlarsa streak sifirlanir, 7'den sonra 1'e doner.

const CollectionRef := preload("res://scripts/systems/collection_system.gd")

# 7 gunluk odul tablosu
const LOGIN_REWARDS := [
	{"day": 1, "type": "energy", "amount": 1, "description": "+1 Enerji"},
	{"day": 2, "type": "gem", "amount": 2, "description": "+2 Gem"},
	{"day": 3, "type": "collection", "amount": 1, "description": "Koleksiyon Parcasi"},
	{"day": 4, "type": "energy", "amount": 2, "description": "+2 Enerji"},
	{"day": 5, "type": "gem", "amount": 5, "description": "+5 Gem"},
	{"day": 6, "type": "energy", "amount": 3, "description": "+3 Enerji"},
	{"day": 7, "type": "gem_and_collection", "amount": 15, "description": "+15 Gem + Koleksiyon"},
]


## Giris kontrolu yap. Doner: odul varsa gun numarasi (1-7), yoksa 0
static func check_login() -> int:
	var today := _get_today_string()

	# Bugun zaten giris yaptiysa odul yok
	if GameState.last_login_date == today:
		return 0

	var yesterday := _get_yesterday_string()

	# Streak kontrolu
	if GameState.last_login_date == yesterday:
		# Ardisik giris — streak devam
		GameState.login_streak += 1
		if GameState.login_streak > 7:
			GameState.login_streak = 1
	elif GameState.last_login_date == "":
		# Ilk giris
		GameState.login_streak = 1
	else:
		# 1+ gun atlanmis — streak sifirla
		GameState.login_streak = 1

	GameState.last_login_date = today
	GameState.login_reward_claimed = false
	SaveManager.save_game()
	return GameState.login_streak


## Odulu ver
static func claim_reward() -> Dictionary:
	if GameState.login_reward_claimed:
		return {}

	var day: int = GameState.login_streak
	if day < 1 or day > 7:
		return {}

	var reward: Dictionary = LOGIN_REWARDS[day - 1]
	GameState.login_reward_claimed = true

	match reward["type"]:
		"energy":
			GameState.energy += reward["amount"]
		"gem":
			GameState.gems += reward["amount"]
		"collection":
			_give_random_collection_piece()
		"gem_and_collection":
			GameState.gems += reward["amount"]
			_give_random_collection_piece()

	SaveManager.save_game()
	print("[DailyLogin] Gun %d odulu verildi: %s" % [day, reward["description"]])
	return reward


## Rastgele koleksiyon parcasi ver
static func _give_random_collection_piece() -> void:
	# Toplanmamis parcalar arasindan rastgele sec
	var available: Array = []
	for set_id in CollectionRef.SET_ORDER:
		var set_data: Dictionary = CollectionRef.get_set(set_id)
		for piece_id in set_data["pieces"]:
			if not GameState.has_collection_piece(set_id, piece_id):
				available.append({"set_id": set_id, "piece_id": piece_id})

	if available.is_empty():
		# Tum parcalar toplanmis — 3 gem ver
		GameState.gems += 3
		print("[DailyLogin] Tum parcalar toplanmis, +3 Gem yerine")
		return

	available.shuffle()
	var pick: Dictionary = available[0]
	GameState.add_collection_piece(pick["set_id"], pick["piece_id"])
	print("[DailyLogin] Koleksiyon parcasi: %s / %s" % [pick["set_id"], pick["piece_id"]])


## Bugunun tarihini al
static func _get_today_string() -> String:
	var dt := Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d" % [dt["year"], dt["month"], dt["day"]]


## Dunun tarihini al
static func _get_yesterday_string() -> String:
	var unix := Time.get_unix_time_from_system() - 86400.0
	var dt := Time.get_datetime_dict_from_unix_time(int(unix))
	return "%04d-%02d-%02d" % [dt["year"], dt["month"], dt["day"]]


## Odul bilgilerini al (UI icin)
static func get_rewards_display() -> Array:
	return LOGIN_REWARDS


## Bugunun streak'ini al
static func get_current_streak() -> int:
	return GameState.login_streak
