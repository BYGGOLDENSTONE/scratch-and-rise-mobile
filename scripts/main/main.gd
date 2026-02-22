extends Node2D

## Ana oyun sahnesi. Portrait layout.
## Bilet alanı, üst bar, alt panel.

@onready var coin_label: Label = %CoinLabel
@onready var energy_label: Label = %EnergyLabel
@onready var ticket_placeholder: Label = %TicketPlaceholder


func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.energy_changed.connect(_on_energy_changed)
	GameState.round_ended.connect(_on_round_ended)
	_update_ui()
	print("[Main] Game screen ready")


func _update_ui() -> void:
	coin_label.text = "Coin: %s" % GameState.format_number(GameState.coins)
	energy_label.text = "Enerji: %d/%d" % [GameState.energy, GameState.MAX_ENERGY]


func _on_coins_changed(_new_amount: int) -> void:
	coin_label.text = "Coin: %s" % GameState.format_number(GameState.coins)


func _on_energy_changed(_new_amount: int) -> void:
	energy_label.text = "Enerji: %d/%d" % [GameState.energy, GameState.MAX_ENERGY]


func _on_round_ended(_total_earned: int) -> void:
	# Tur bitti ekranına geç
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://scenes/screens/RoundEnd.tscn")


func _on_back_pressed() -> void:
	if GameState.in_round:
		GameState.end_round()
	else:
		get_tree().change_scene_to_file("res://scenes/screens/MainMenu.tscn")
