extends Node2D

## Ana oyun sahnesi. Portrait layout.
## Bilet alani, ust bar, alt panel.
## Enerji labelina 5 kez tikla -> Debug Panel

const TicketScene := preload("res://scenes/ticket/Ticket.tscn")
const MatchResultScene := preload("res://scenes/ui/MatchResult.tscn")
const DebugPanelScene := preload("res://scenes/debug/DebugPanel.tscn")

@onready var coin_label: Label = %CoinLabel
@onready var energy_label: Label = %EnergyLabel
@onready var ticket_count_label: Label = %TicketCountLabel
@onready var ticket_area: CenterContainer = %TicketArea
@onready var ticket_placeholder: Label = %TicketPlaceholder
@onready var bilet_secimi: HBoxContainer = %BiletSecimi
@onready var warning_label: Label = %WarningLabel

var current_ticket: PanelContainer = null
var match_result_popup: PanelContainer = null
var tickets_scratched: int = 0
var _debug_tap_count: int = 0
var _debug_last_tap_time: float = 0.0
var _debug_panel: Control = null
var _ticket_buttons: Dictionary = {}  # { "paper": Button, ... }


func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.energy_changed.connect(_on_energy_changed)
	GameState.round_ended.connect(_on_round_ended)
	energy_label.mouse_filter = Control.MOUSE_FILTER_STOP
	energy_label.gui_input.connect(_on_debug_tap_input)
	_build_ticket_buttons()
	_update_ui()
	_update_ticket_buttons()
	print("[Main] Game screen ready")


func _build_ticket_buttons() -> void:
	# Sahne'deki mevcut butonlari temizle
	for child in bilet_secimi.get_children():
		child.queue_free()
	_ticket_buttons.clear()

	# Her bilet turu icin buton olustur
	for t_type in TicketData.TICKET_ORDER:
		var config: Dictionary = TicketData.TICKET_CONFIGS[t_type]
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_ticket_buy.bind(t_type))
		bilet_secimi.add_child(btn)
		_ticket_buttons[t_type] = btn


func _update_ui() -> void:
	coin_label.text = "Coin: %s" % GameState.format_number(GameState.coins)
	energy_label.text = "Enerji: %d/%d" % [GameState.energy, GameState.get_max_energy()]
	ticket_count_label.text = "Bilet: %d" % tickets_scratched


func _on_coins_changed(_new_amount: int) -> void:
	coin_label.text = "Coin: %s" % GameState.format_number(GameState.coins)
	_update_ticket_buttons()


func _on_energy_changed(_new_amount: int) -> void:
	energy_label.text = "Enerji: %d/%d" % [GameState.energy, GameState.get_max_energy()]


func _on_round_ended(_total_earned: int) -> void:
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://scenes/screens/RoundEnd.tscn")


func _on_back_pressed() -> void:
	if GameState.in_round:
		GameState.end_round()
	else:
		get_tree().change_scene_to_file("res://scenes/screens/MainMenu.tscn")


func _on_ticket_buy(type: String) -> void:
	if current_ticket != null:
		return
	var config: Dictionary = TicketData.TICKET_CONFIGS.get(type, TicketData.TICKET_CONFIGS["paper"])
	var price: int = config["price"]
	if not GameState.spend_coins(price):
		print("[Main] Coin yetersiz!")
		_show_warning("Coin yetersiz!")
		return

	# Placeholder'i gizle, bilet olustur
	ticket_placeholder.visible = false
	current_ticket = TicketScene.instantiate()
	ticket_area.add_child(current_ticket)
	current_ticket.setup(type)
	current_ticket.ticket_completed.connect(_on_ticket_completed)
	_update_ticket_buttons()
	print("[Main] %s satin alindi (%d coin), kalan: %d" % [config["name"], price, GameState.coins])


func _on_ticket_completed(symbols: Array) -> void:
	print("[Main] Bilet tamamlandi! Semboller: ", symbols)

	# Eslesme kontrolu
	var ticket_type: String = "paper"
	if current_ticket and current_ticket.has_method("get_ticket_type"):
		ticket_type = current_ticket.get_ticket_type()
	var match_data: Dictionary = MatchSystem.check_match(symbols, ticket_type)

	# Charm bonuslarini uygula ve coin ekle
	if match_data["has_match"]:
		var reward: int = _apply_charm_bonuses(match_data["reward"], match_data)
		match_data["reward"] = reward
		GameState.add_coins(reward)
		print("[Main] Eslesme! +", reward, " coin")
	else:
		print("[Main] Eslesme yok")

	# Sonuc popup'ini goster
	_show_match_result(match_data)


func _show_match_result(match_data: Dictionary) -> void:
	match_result_popup = MatchResultScene.instantiate()
	get_node("UILayer").add_child(match_result_popup)
	match_result_popup.show_result(match_data)
	match_result_popup.result_dismissed.connect(_on_match_result_dismissed)


func _on_match_result_dismissed() -> void:
	if match_result_popup:
		match_result_popup.queue_free()
		match_result_popup = null
	tickets_scratched += 1
	ticket_count_label.text = "Bilet: %d" % tickets_scratched
	_remove_current_ticket()


func _remove_current_ticket() -> void:
	if current_ticket != null:
		current_ticket.queue_free()
		current_ticket = null
	ticket_placeholder.visible = true
	_update_ticket_buttons()

	# Coin yetersizse turu otomatik bitir
	var cheapest_price: int = TicketData.get_cheapest_unlocked_price()
	if GameState.coins < cheapest_price and GameState.in_round:
		print("[Main] Coin bitti, tur otomatik bitiyor!")
		GameState.end_round()


func _update_ticket_buttons() -> void:
	for t_type in TicketData.TICKET_ORDER:
		var btn: Button = _ticket_buttons.get(t_type)
		if btn == null:
			continue
		var config: Dictionary = TicketData.TICKET_CONFIGS[t_type]
		var unlocked: bool = TicketData.is_ticket_unlocked(t_type)

		if not unlocked:
			btn.text = "%s\nKilitli" % config["name"]
			btn.disabled = true
		else:
			btn.text = "%s\n%d C" % [config["name"], config["price"]]
			btn.disabled = (current_ticket != null) or (GameState.coins < config["price"])


func _show_warning(text: String) -> void:
	warning_label.text = text
	warning_label.visible = true
	warning_label.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.0)
	tw.tween_property(warning_label, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func(): warning_label.visible = false)


func _apply_charm_bonuses(base_reward: int, match_data: Dictionary) -> int:
	var bonus_mult := 1.0

	# Sans Tokasi: +10% eslesme odulu per level
	bonus_mult += GameState.get_charm_level("sans_tokasi") * 0.10

	# Altinparmak: +15% tum oduller per level
	bonus_mult += GameState.get_charm_level("altinparmak") * 0.15

	# Kral Dokunusu: 4+ eslesme odulu x(level+1)
	if match_data["best_count"] >= 4:
		var kral_level := GameState.get_charm_level("kral_dokunusu")
		if kral_level > 0:
			bonus_mult *= (1 + kral_level)

	var reward := int(base_reward * bonus_mult)

	# YOLO: %1 sansla odul x50
	if GameState.get_charm_level("yolo") > 0:
		if randf() < 0.01:
			reward *= 50
			print("[Main] YOLO! x50!")

	return reward


func _on_debug_tap_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var now := Time.get_ticks_msec() / 1000.0
		if now - _debug_last_tap_time > 2.0:
			_debug_tap_count = 0
		_debug_last_tap_time = now
		_debug_tap_count += 1
		if _debug_tap_count >= 5:
			_debug_tap_count = 0
			_open_debug_panel()


func _open_debug_panel() -> void:
	if _debug_panel != null:
		return
	_debug_panel = DebugPanelScene.instantiate()
	get_node("UILayer").add_child(_debug_panel)
	_debug_panel.panel_closed.connect(_on_debug_closed)


func _on_debug_closed() -> void:
	_debug_panel = null
	_update_ui()
	_update_ticket_buttons()
