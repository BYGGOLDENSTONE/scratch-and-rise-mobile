extends Control

## Tur bitti ekranı. İstatistik, charm puanı, reklam butonu.

@onready var earned_label: Label = %EarnedLabel
@onready var charm_earned_label: Label = %CharmEarnedLabel
@onready var total_charm_label: Label = %TotalCharmLabel
@onready var energy_label: Label = %EnergyLabel
@onready var tickets_label: Label = %TicketsLabel
@onready var matches_label: Label = %MatchesLabel
@onready var synergies_label: Label = %SynergiesLabel
@onready var jackpots_label: Label = %JackpotsLabel

var _round_earnings: int = 0


@onready var vbox: VBoxContainer = $VBox


func _ready() -> void:
	_round_earnings = GameState.last_round_earnings
	_update_ui()
	# Giris animasyonu: slide down + fade
	vbox.modulate.a = 0.0
	vbox.position.y -= 40
	var tw := create_tween().set_parallel(true)
	tw.tween_property(vbox, "modulate:a", 1.0, 0.3)
	tw.tween_property(vbox, "position:y", vbox.position.y + 40, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	print("[RoundEnd] Ready")


func _update_ui() -> void:
	earned_label.text = "Kazanilan: %s coin" % GameState.format_number(_round_earnings)
	var charm_earned := GameState.calc_charm_from_coins(_round_earnings)
	charm_earned_label.text = "+%d Charm Puani" % charm_earned
	total_charm_label.text = "Toplam Charm: %s" % GameState.format_number(GameState.charm_points)
	energy_label.text = "Enerji: %d / %d" % [GameState.energy, GameState.get_max_energy()]
	# Tur istatistikleri
	var rs: Dictionary = GameState.round_stats
	tickets_label.text = "Bilet: %d" % rs.get("tickets", 0)
	matches_label.text = "Eslesme: %d" % rs.get("matches", 0)
	synergies_label.text = "Sinerji: %d" % rs.get("synergies", 0)
	jackpots_label.text = "Jackpot: %d" % rs.get("jackpots", 0)
	# Charm kazanma pulse animasyonu
	if charm_earned > 0:
		charm_earned_label.pivot_offset = charm_earned_label.size / 2
		charm_earned_label.scale = Vector2(0.5, 0.5)
		var tw := create_tween()
		tw.tween_interval(0.5)
		tw.tween_property(charm_earned_label, "scale", Vector2(1.3, 1.3), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tw.tween_property(charm_earned_label, "scale", Vector2.ONE, 0.15)


func _on_menu_pressed() -> void:
	SceneTransition.change_scene("res://scenes/screens/MainMenu.tscn")


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
