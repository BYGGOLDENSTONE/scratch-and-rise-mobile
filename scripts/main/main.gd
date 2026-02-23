extends Node2D

## Ana oyun sahnesi. Portrait layout.
## Bilet alani, ust bar, alt panel.

const TicketScene := preload("res://scenes/ticket/Ticket.tscn")
const MatchResultScene := preload("res://scenes/ui/MatchResult.tscn")

@onready var coin_label: Label = %CoinLabel
@onready var energy_label: Label = %EnergyLabel
@onready var ticket_area: CenterContainer = %TicketArea
@onready var ticket_placeholder: Label = %TicketPlaceholder
@onready var kagit_btn: Button = %Btn1

var current_ticket: PanelContainer = null
var match_result_popup: PanelContainer = null


func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.energy_changed.connect(_on_energy_changed)
	GameState.round_ended.connect(_on_round_ended)
	kagit_btn.pressed.connect(_on_kagit_pressed)
	_update_ui()
	_update_ticket_buttons()
	print("[Main] Game screen ready")


func _update_ui() -> void:
	coin_label.text = "Coin: %s" % GameState.format_number(GameState.coins)
	energy_label.text = "Enerji: %d/%d" % [GameState.energy, GameState.MAX_ENERGY]


func _on_coins_changed(_new_amount: int) -> void:
	coin_label.text = "Coin: %s" % GameState.format_number(GameState.coins)
	_update_ticket_buttons()


func _on_energy_changed(_new_amount: int) -> void:
	energy_label.text = "Enerji: %d/%d" % [GameState.energy, GameState.MAX_ENERGY]


func _on_round_ended(_total_earned: int) -> void:
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://scenes/screens/RoundEnd.tscn")


func _on_back_pressed() -> void:
	if GameState.in_round:
		GameState.end_round()
	else:
		get_tree().change_scene_to_file("res://scenes/screens/MainMenu.tscn")


func _on_kagit_pressed() -> void:
	if current_ticket != null:
		return
	var price: int = TicketData.TICKET_CONFIGS["paper"]["price"]
	if not GameState.spend_coins(price):
		print("[Main] Coin yetersiz!")
		return

	# Placeholder'i gizle, bilet olustur
	ticket_placeholder.visible = false
	current_ticket = TicketScene.instantiate()
	ticket_area.add_child(current_ticket)
	current_ticket.setup("paper")
	current_ticket.ticket_completed.connect(_on_ticket_completed)
	_update_ticket_buttons()
	print("[Main] Bilet satin alindi, kalan coin: ", GameState.coins)


func _on_ticket_completed(symbols: Array) -> void:
	print("[Main] Bilet tamamlandi! Semboller: ", symbols)

	# Eslesme kontrolu
	var ticket_type: String = "paper"
	if current_ticket and current_ticket.has_method("get_ticket_type"):
		ticket_type = current_ticket.get_ticket_type()
	var match_data: Dictionary = MatchSystem.check_match(symbols, ticket_type)

	# Coin ekle (eslesme varsa)
	if match_data["has_match"]:
		GameState.add_coins(match_data["reward"])
		print("[Main] Eslesme! +", match_data["reward"], " coin")
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
	_remove_current_ticket()


func _remove_current_ticket() -> void:
	if current_ticket != null:
		current_ticket.queue_free()
		current_ticket = null
	ticket_placeholder.visible = true
	_update_ticket_buttons()

	# Coin yetersizse turu otomatik bitir
	var cheapest_price: int = TicketData.TICKET_CONFIGS["paper"]["price"]
	if GameState.coins < cheapest_price and GameState.in_round:
		print("[Main] Coin bitti, tur otomatik bitiyor!")
		GameState.end_round()


func _update_ticket_buttons() -> void:
	var price: int = TicketData.TICKET_CONFIGS["paper"]["price"]
	kagit_btn.disabled = (current_ticket != null) or (GameState.coins < price)
