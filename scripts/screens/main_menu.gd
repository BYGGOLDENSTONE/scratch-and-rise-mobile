extends Control

## Ana menü ekranı. Enerji göstergesi, OYNA butonu.

@onready var energy_label: Label = %EnergyLabel
@onready var charm_label: Label = %CharmLabel
@onready var play_button: Button = %PlayButton
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	SaveManager.load_game()
	GameState.energy_changed.connect(_on_energy_changed)
	_update_ui()
	print("[MainMenu] Ready — Energy: ", GameState.energy)


func _update_ui() -> void:
	energy_label.text = "Enerji: %d / %d" % [GameState.energy, GameState.MAX_ENERGY]
	charm_label.text = "Charm: %s" % GameState.format_number(GameState.charm_points)
	play_button.disabled = GameState.energy <= 0
	if GameState.energy <= 0:
		status_label.text = "Enerji bekleniyor..."
		status_label.visible = true
	else:
		status_label.visible = false


func _on_energy_changed(_new_amount: int) -> void:
	_update_ui()


func _on_play_pressed() -> void:
	if GameState.start_round():
		get_tree().change_scene_to_file("res://scenes/main/Main.tscn")
