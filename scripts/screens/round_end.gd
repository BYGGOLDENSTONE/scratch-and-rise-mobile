extends Control

## Tur bitti ekranı. İstatistik, charm puanı, reklam butonu.

@onready var earned_label: Label = %EarnedLabel
@onready var charm_earned_label: Label = %CharmEarnedLabel
@onready var total_charm_label: Label = %TotalCharmLabel
@onready var energy_label: Label = %EnergyLabel

var _round_earnings: int = 0


func _ready() -> void:
	_round_earnings = GameState.last_round_earnings
	_update_ui()
	print("[RoundEnd] Ready")


func _update_ui() -> void:
	earned_label.text = "Kazanilan: %s coin" % GameState.format_number(_round_earnings)
	var charm_earned := GameState.calc_charm_from_coins(_round_earnings)
	charm_earned_label.text = "+%d Charm Puani" % charm_earned
	total_charm_label.text = "Toplam Charm: %s" % GameState.format_number(GameState.charm_points)
	energy_label.text = "Enerji: %d / %d" % [GameState.energy, GameState.get_max_energy()]


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/screens/MainMenu.tscn")


func _on_watch_ad_pressed() -> void:
	AdManager.show_rewarded_video(_on_ad_completed)


func _on_ad_completed() -> void:
	# Bonus: %50 ekstra charm
	var bonus := GameState.calc_charm_from_coins(_round_earnings) / 2
	if bonus < 1:
		bonus = 1
	GameState.charm_points += bonus
	_update_ui()
	print("[RoundEnd] Ad bonus: +", bonus, " charm")
