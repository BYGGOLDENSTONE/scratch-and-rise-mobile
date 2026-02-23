extends Control

## Gizli debug paneli. Basliga 5 kez tiklayinca acilir.
## Save sifirlama, coin/enerji/charm ekleme, tur bitirme.
const SynergyRef := preload("res://scripts/systems/synergy_system.gd")
const CollectionRef := preload("res://scripts/systems/collection_system.gd")

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


func _on_close() -> void:
	panel_closed.emit()
	queue_free()
