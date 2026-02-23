extends Control

## Gizli debug paneli. Basliga 5 kez tiklayinca acilir.
## Save sifirlama, coin/enerji/charm ekleme, tur bitirme.
const SynergyRef := preload("res://scripts/systems/synergy_system.gd")
const CollectionRef := preload("res://scripts/systems/collection_system.gd")
const EventRef := preload("res://scripts/systems/event_system.gd")
const AchievementRef := preload("res://scripts/systems/achievement_system.gd")

signal panel_closed()

@onready var reset_btn: Button = %ResetSaveBtn
@onready var energy_btn: Button = %FillEnergyBtn
@onready var charm10_btn: Button = %AddCharm10Btn
@onready var charm100_btn: Button = %AddCharm100Btn
@onready var coin100_btn: Button = %AddCoin100Btn
@onready var coin1000_btn: Button = %AddCoin1000Btn
@onready var end_round_btn: Button = %EndRoundBtn
@onready var close_btn: Button = %CloseBtn
@onready var info_label: Label = %InfoLabel


func _ready() -> void:
	reset_btn.pressed.connect(_on_reset_save)
	energy_btn.pressed.connect(_on_fill_energy)
	charm10_btn.pressed.connect(_on_add_charm.bind(10))
	charm100_btn.pressed.connect(_on_add_charm.bind(100))
	coin100_btn.pressed.connect(_on_add_coin.bind(100))
	coin1000_btn.pressed.connect(_on_add_coin.bind(1000))
	end_round_btn.pressed.connect(_on_end_round)
	close_btn.pressed.connect(_on_close)
	# Dinamik butonlar (sahne duzenlemesiz)
	var parent_container: Container = end_round_btn.get_parent()

	var unlock_btn := Button.new()
	unlock_btn.text = "Tum Biletleri Ac"
	unlock_btn.pressed.connect(_on_unlock_all_tickets)
	parent_container.add_child(unlock_btn)
	parent_container.move_child(unlock_btn, end_round_btn.get_index())

	var syn_btn := Button.new()
	syn_btn.text = "Sinerji Kesfet"
	syn_btn.pressed.connect(_on_discover_synergy)
	parent_container.add_child(syn_btn)
	parent_container.move_child(syn_btn, end_round_btn.get_index())

	var col_btn := Button.new()
	col_btn.text = "Koleksiyon Ekle"
	col_btn.pressed.connect(_on_add_collection)
	parent_container.add_child(col_btn)
	parent_container.move_child(col_btn, end_round_btn.get_index())

	var col_all_btn := Button.new()
	col_all_btn.text = "Tum Koleksiyonlari Tamamla"
	col_all_btn.pressed.connect(_on_complete_all_collections)
	parent_container.add_child(col_all_btn)
	parent_container.move_child(col_all_btn, end_round_btn.get_index())

	# M8: Olay ve basarim butonlari
	var bull_btn := Button.new()
	bull_btn.text = "Olay: Bull Run"
	bull_btn.pressed.connect(_on_trigger_bull_run)
	parent_container.add_child(bull_btn)
	parent_container.move_child(bull_btn, end_round_btn.get_index())

	var golden_btn := Button.new()
	golden_btn.text = "Olay: Altin Bilet"
	golden_btn.pressed.connect(_on_trigger_golden_ticket)
	parent_container.add_child(golden_btn)
	parent_container.move_child(golden_btn, end_round_btn.get_index())

	var ach_btn := Button.new()
	ach_btn.text = "Basarim Ac"
	ach_btn.pressed.connect(_on_unlock_achievement)
	parent_container.add_child(ach_btn)
	parent_container.move_child(ach_btn, end_round_btn.get_index())

	var ach_all_btn := Button.new()
	ach_all_btn.text = "Tum Basarimlari Ac"
	ach_all_btn.pressed.connect(_on_unlock_all_achievements)
	parent_container.add_child(ach_all_btn)
	parent_container.move_child(ach_all_btn, end_round_btn.get_index())

	_update_context()
	print("[Debug] Panel acildi")


func _update_context() -> void:
	var in_round := GameState.in_round
	coin100_btn.disabled = not in_round
	coin1000_btn.disabled = not in_round
	end_round_btn.disabled = not in_round
	_update_info()


func _update_info() -> void:
	var unlocked_list: Array = []
	for t_type in TicketData.TICKET_ORDER:
		if TicketData.is_ticket_unlocked(t_type):
			unlocked_list.append(TicketData.TICKET_CONFIGS[t_type]["name"])
	var unlocked_text: String = ", ".join(unlocked_list) if unlocked_list.size() > 0 else "Yok"
	info_label.text = "Coin: %s | Enerji: %d/%d\nCharm: %s | Tur: %s\nAcik biletler: %s" % [
		GameState.format_number(GameState.coins),
		GameState.energy, GameState.get_max_energy(),
		GameState.format_number(GameState.charm_points),
		"Aktif" if GameState.in_round else "Yok",
		unlocked_text,
	]


func _on_reset_save() -> void:
	GameState.charm_points = 0
	GameState.charms = {}
	GameState.energy = GameState.get_max_energy()
	GameState.total_coins_earned = 0
	GameState.total_rounds_played = 0
	GameState.best_round_coins = 0
	GameState.coins = 0
	GameState.in_round = false
	GameState.collected_pieces = {}
	GameState.discovered_synergies = []
	GameState.stats = {
		"total_tickets": 0,
		"total_matches": 0,
		"total_jackpots": 0,
		"total_synergies_found": 0,
		"best_streak": 0,
	}
	GameState.unlocked_achievements = []
	GameState.round_stats = {}
	GameState.active_events = {}
	GameState._tickets_since_golden = 0
	GameState._joker_rain_active = false
	GameState._mega_ticket_active = false
	GameState._free_ticket_active = false
	GameState._current_match_streak = 0
	SaveManager.save_game()
	print("[Debug] Save sifirlandi!")
	_update_context()


func _on_fill_energy() -> void:
	GameState.energy = GameState.get_max_energy()
	print("[Debug] Enerji dolduruldu: ", GameState.energy)
	_update_info()


func _on_add_charm(amount: int) -> void:
	GameState.charm_points += amount
	print("[Debug] +", amount, " charm. Toplam: ", GameState.charm_points)
	_update_info()


func _on_add_coin(amount: int) -> void:
	GameState.add_coins(amount)
	print("[Debug] +", amount, " coin. Toplam: ", GameState.coins)
	_update_info()


func _on_unlock_all_tickets() -> void:
	GameState.total_coins_earned = maxi(GameState.total_coins_earned, 500)
	for key_charm in ["gumus_anahtar", "altin_anahtar", "platin_anahtar"]:
		if GameState.get_charm_level(key_charm) < 1:
			GameState.charms[key_charm] = 1
	SaveManager.save_game()
	print("[Debug] Tum biletler acildi!")
	_update_info()


func _on_end_round() -> void:
	if GameState.in_round:
		GameState.end_round()
		print("[Debug] Tur bitirildi!")
	_update_context()


func _on_discover_synergy() -> void:
	# Kesfedilmemis bir sinerji bul ve kesfet
	for syn_id in SynergyRef.SYNERGY_ORDER:
		if not GameState.is_synergy_discovered(syn_id):
			GameState.discover_synergy(syn_id)
			var syn: Dictionary = SynergyRef.get_synergy(syn_id)
			print("[Debug] Sinerji kesfedildi: %s" % syn.get("name", syn_id))
			_update_info()
			return
	print("[Debug] Tum sinerjiler zaten kesfedilmis!")


func _on_add_collection() -> void:
	# Toplanmamis bir parca bul ve ekle
	for set_id in CollectionRef.SET_ORDER:
		var set_data: Dictionary = CollectionRef.get_set(set_id)
		for piece_id in set_data["pieces"]:
			if not GameState.has_collection_piece(set_id, piece_id):
				GameState.add_collection_piece(set_id, piece_id)
				var piece_name: String = CollectionRef.get_piece_name(set_id, piece_id)
				print("[Debug] Koleksiyon eklendi: %s / %s" % [set_data["name"], piece_name])
				_update_info()
				return
	print("[Debug] Tum koleksiyonlar zaten tamamlanmis!")


func _on_complete_all_collections() -> void:
	for set_id in CollectionRef.SET_ORDER:
		var set_data: Dictionary = CollectionRef.get_set(set_id)
		for piece_id in set_data["pieces"]:
			if not GameState.has_collection_piece(set_id, piece_id):
				GameState.add_collection_piece(set_id, piece_id)
	SaveManager.save_game()
	print("[Debug] Tum koleksiyonlar tamamlandi!")
	_update_info()


func _on_trigger_bull_run() -> void:
	GameState.active_events["bull_run"] = 3
	GameState.event_triggered.emit("bull_run", EventRef.get_event("bull_run"))
	print("[Debug] Bull Run tetiklendi! Sonraki 3 bilet x2")
	_update_info()


func _on_trigger_golden_ticket() -> void:
	GameState._free_ticket_active = true
	GameState.event_triggered.emit("golden_ticket", EventRef.get_event("golden_ticket"))
	print("[Debug] Altin bilet! Sonraki bilet ucretsiz")
	_update_info()


func _on_unlock_achievement() -> void:
	for ach_id in AchievementRef.ACHIEVEMENT_ORDER:
		if ach_id not in GameState.unlocked_achievements:
			GameState.unlocked_achievements.append(ach_id)
			var ach: Dictionary = AchievementRef.get_achievement(ach_id)
			var reward_cp: int = ach.get("reward_cp", 0)
			GameState.charm_points += reward_cp
			var display_name: String = ach.get("real_name", ach.get("name", ach_id))
			print("[Debug] Basarim acildi: %s (+%d CP)" % [display_name, reward_cp])
			GameState.achievement_unlocked.emit(ach_id)
			SaveManager.save_game()
			_update_info()
			return
	print("[Debug] Tum basarimlar zaten acilmis!")


func _on_unlock_all_achievements() -> void:
	for ach_id in AchievementRef.ACHIEVEMENT_ORDER:
		if ach_id not in GameState.unlocked_achievements:
			GameState.unlocked_achievements.append(ach_id)
			var ach: Dictionary = AchievementRef.get_achievement(ach_id)
			GameState.charm_points += ach.get("reward_cp", 0)
	SaveManager.save_game()
	print("[Debug] Tum basarimlar acildi!")
	_update_info()


func _on_close() -> void:
	panel_closed.emit()
	queue_free()
