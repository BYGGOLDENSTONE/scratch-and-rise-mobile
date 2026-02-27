extends Node

## Kayıt/yükleme sistemi. JSON tabanlı.
## Mobil: gem, charm, koleksiyon, istatistik, enerji kaydeder.
## Tur içi coin kaydedilmez (geçici).

const SAVE_PATH := "user://save_main.json"
const BACKUP_PATH := "user://save_backup.json"


func _ready() -> void:
	print("[SaveManager] Initialized — Mobile")


## Oyun kaydet (her tur sonunda otomatik çağrılır)
func save_game() -> void:
	var data := {
		"gems": GameState.gems,
		"charms": GameState.charms,
		"energy": GameState.energy,
		"total_coins_earned": GameState.total_coins_earned,
		"total_rounds_played": GameState.total_rounds_played,
		"best_round_coins": GameState.best_round_coins,
		"collected_pieces": GameState.collected_pieces,
		"discovered_synergies": GameState.discovered_synergies,
		"stats": GameState.stats,
		"unlocked_achievements": GameState.unlocked_achievements,
		"user_theme": GameState.user_theme,
		"sfx_enabled": SoundManager.sfx_enabled,
		"daily_quests": GameState.daily_quests,
		"daily_quest_date": GameState.daily_quest_date,
		"daily_bonus_claimed": GameState.daily_bonus_claimed,
		"login_streak": GameState.login_streak,
		"last_login_date": GameState.last_login_date,
		"login_reward_claimed": GameState.login_reward_claimed,
		"user_locale": GameState.user_locale,
		"gem_claimed_tiers": GameState.gem_claimed_tiers,
		"timestamp": Time.get_unix_time_from_system(),
	}
	# Mevcut save'i backup'a kopyala
	if FileAccess.file_exists(SAVE_PATH):
		var existing := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if existing:
			var backup := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
			if backup:
				backup.store_string(existing.get_as_text())
	# Yeni save yaz
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		print("[SaveManager] Game saved")


## Oyun yükle
func load_game() -> bool:
	var path := SAVE_PATH
	if not FileAccess.file_exists(path):
		path = BACKUP_PATH
		if not FileAccess.file_exists(path):
			print("[SaveManager] No save file found")
			return false
		print("[SaveManager] Main save missing, loading backup")

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return false

	var json := JSON.new()
	var result := json.parse(file.get_as_text())
	if result != OK:
		print("[SaveManager] Failed to parse save: ", json.get_error_message())
		return false

	var data: Dictionary = json.data
	GameState.gems = int(data.get("gems", data.get("charm_points", 0)))
	GameState.charms = data.get("charms", {})
	GameState.total_coins_earned = int(data.get("total_coins_earned", 0))
	GameState.total_rounds_played = int(data.get("total_rounds_played", 0))
	GameState.best_round_coins = int(data.get("best_round_coins", 0))
	GameState.collected_pieces = data.get("collected_pieces", {})
	GameState.discovered_synergies = data.get("discovered_synergies", [])

	# Stats ve basarimlar
	var saved_stats: Dictionary = data.get("stats", {})
	GameState.stats = {
		"total_tickets": int(saved_stats.get("total_tickets", 0)),
		"total_matches": int(saved_stats.get("total_matches", 0)),
		"total_jackpots": int(saved_stats.get("total_jackpots", 0)),
		"total_synergies_found": int(saved_stats.get("total_synergies_found", 0)),
		"best_streak": int(saved_stats.get("best_streak", 0)),
		"ticket_types_played": saved_stats.get("ticket_types_played", []),
		"total_special_symbols": int(saved_stats.get("total_special_symbols", 0)),
		"loss_streak": int(saved_stats.get("loss_streak", 0)),
	}
	GameState.unlocked_achievements = data.get("unlocked_achievements", [])

	# Gunluk gorevler
	GameState.daily_quests = data.get("daily_quests", [])
	GameState.daily_quest_date = data.get("daily_quest_date", "")
	GameState.daily_bonus_claimed = data.get("daily_bonus_claimed", false)

	# Gunluk giris
	GameState.login_streak = int(data.get("login_streak", 0))
	GameState.last_login_date = data.get("last_login_date", "")
	GameState.login_reward_claimed = data.get("login_reward_claimed", false)

	# Gem claimed tiers
	GameState.gem_claimed_tiers = data.get("gem_claimed_tiers", [])

	# Tema tercihi
	GameState.user_theme = int(data.get("user_theme", 0))
	var loaded_locale: String = data.get("user_locale", "tr")
	if loaded_locale not in GameState.SUPPORTED_LOCALES:
		loaded_locale = "tr"
	GameState.user_locale = loaded_locale
	GameState._apply_saved_theme()

	# Ses tercihi
	SoundManager.sfx_enabled = data.get("sfx_enabled", true)

	# Enerji yenilenme hesabı (dayanıklılık charm etkisi dahil)
	var saved_energy: int = int(data.get("energy", GameState.BASE_MAX_ENERGY))
	var saved_time: float = data.get("timestamp", 0.0)
	var max_e: int = GameState.get_max_energy()
	if saved_time > 0.0 and saved_energy < max_e:
		var elapsed := Time.get_unix_time_from_system() - saved_time
		var regen_time: float = GameState.get_energy_regen_time()
		var regen_count := int(elapsed / regen_time)
		saved_energy = mini(saved_energy + regen_count, max_e)
	GameState.energy = saved_energy

	print("[SaveManager] Game loaded from ", path)
	return true


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		print("[SaveManager] Emergency save on quit")
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()
		print("[SaveManager] Save on app pause")
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		save_game()
		print("[SaveManager] Save on focus out")
