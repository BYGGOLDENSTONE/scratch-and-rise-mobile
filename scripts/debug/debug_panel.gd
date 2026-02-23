extends Control

## Gizli debug paneli. Basliga 5 kez tiklayinca acilir.
## Save sifirlama, coin/enerji/charm ekleme, tur bitirme.

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
	# Tum Biletleri Ac butonu (dinamik, sahne duzenlemesiz)
	var unlock_btn := Button.new()
	unlock_btn.text = "Tum Biletleri Ac"
	unlock_btn.pressed.connect(_on_unlock_all_tickets)
	# EndRoundBtn'den once ekle
	var parent_container: Container = end_round_btn.get_parent()
	parent_container.add_child(unlock_btn)
	parent_container.move_child(unlock_btn, end_round_btn.get_index())
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


func _on_close() -> void:
	panel_closed.emit()
	queue_free()
