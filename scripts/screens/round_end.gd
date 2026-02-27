extends Control

## Tur bitti ekranı. İstatistik, charm puanı, reklam butonu.
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

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
	GameState.locale_changed.connect(func(_l): _update_ui())
	_apply_theme()
	_update_ui()
	# Giris animasyonu: slide down + fade
	vbox.modulate.a = 0.0
	vbox.position.y -= 40
	var tw := create_tween().set_parallel(true)
	tw.tween_property(vbox, "modulate:a", 1.0, 0.3)
	tw.tween_property(vbox, "position:y", vbox.position.y + 40, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	print("[RoundEnd] Ready")


func _apply_theme() -> void:
	$Background.color = ThemeHelper.p("bg_main")
	var title: Label = $VBox/Title
	ThemeHelper.style_title(title, ThemeHelper.p("warning"), 32)
	ThemeHelper.style_label(earned_label, ThemeHelper.p("warning"), 22)
	ThemeHelper.style_label(charm_earned_label, ThemeHelper.p("info"), 20)
	ThemeHelper.style_label(total_charm_label, ThemeHelper.p("text_secondary"), 16)
	ThemeHelper.style_label(energy_label, ThemeHelper.p("success"), 16)
	ThemeHelper.style_label(tickets_label, ThemeHelper.p("text_primary"), 14)
	ThemeHelper.style_label(matches_label, ThemeHelper.p("text_primary"), 14)
	ThemeHelper.style_label(synergies_label, ThemeHelper.p("text_primary"), 14)
	ThemeHelper.style_label(jackpots_label, ThemeHelper.p("text_primary"), 14)
	var play_again_btn: Button = $VBox/PlayAgainButton
	var menu_btn: Button = $VBox/MenuButton
	var ad_btn: Button = $VBox/WatchAdButton
	ThemeHelper.make_button(play_again_btn, ThemeHelper.p("primary"), 26)
	ThemeHelper.make_button(menu_btn, ThemeHelper.p("warning"), 20)
	ThemeHelper.make_button(ad_btn, ThemeHelper.p("success"), 16)
	# Enerji yoksa tekrar oyna butonu devre disi
	if GameState.energy <= 0:
		play_again_btn.text = tr("ENERJI_YOK")
		play_again_btn.disabled = true


func _update_ui() -> void:
	# Buton yazilari
	var title: Label = $VBox/Title
	title.text = tr("TUR_BITTI")
	var play_again_btn: Button = $VBox/PlayAgainButton
	var menu_btn: Button = $VBox/MenuButton
	var ad_btn: Button = $VBox/WatchAdButton
	play_again_btn.text = tr("TEKRAR_OYNA")
	menu_btn.text = tr("ANA_MENU")
	ad_btn.text = tr("REKLAM_IZLE")
	if GameState.energy <= 0:
		play_again_btn.text = tr("ENERJI_YOK")
	earned_label.text = tr("KAZANILAN_FMT") % GameState.format_number(_round_earnings)
	var gems_earned: int = GameState.last_round_gems
	charm_earned_label.text = tr("GEM_KAZANILAN_FMT") % str(gems_earned)
	total_charm_label.text = tr("TOPLAM_GEM_FMT") % GameState.format_number(GameState.gems)
	energy_label.text = tr("ENERJI_BEKLE_FMT") % [GameState.energy, GameState.get_max_energy()]
	# Tur istatistikleri
	var rs: Dictionary = GameState.round_stats
	tickets_label.text = tr("BILET_STAT_FMT") % rs.get("tickets", 0)
	matches_label.text = tr("ESLESME_STAT_FMT") % rs.get("matches", 0)
	synergies_label.text = tr("SINERJI_STAT_FMT") % rs.get("synergies", 0)
	jackpots_label.text = tr("JACKPOT_STAT_FMT") % rs.get("jackpots", 0)
	# Charm kazanma pulse animasyonu
	if gems_earned > 0:
		charm_earned_label.pivot_offset = charm_earned_label.size / 2
		charm_earned_label.scale = Vector2(0.5, 0.5)
		var tw := create_tween()
		tw.tween_interval(0.5)
		tw.tween_property(charm_earned_label, "scale", Vector2(1.3, 1.3), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tw.tween_property(charm_earned_label, "scale", Vector2.ONE, 0.15)


func _on_play_again_pressed() -> void:
	SoundManager.play("ui_tap")
	if GameState.energy <= 0:
		return
	if GameState.start_round():
		SceneTransition.change_scene("res://scenes/main/Main.tscn")


func _on_menu_pressed() -> void:
	SoundManager.play("ui_back")
	SceneTransition.change_scene("res://scenes/screens/MainMenu.tscn")


func _on_watch_ad_pressed() -> void:
	AdManager.show_rewarded_video(_on_ad_completed)


func _on_ad_completed() -> void:
	# Bonus: %50 ekstra gem
	var bonus: int = maxi(int(GameState.last_round_gems * 0.5), 1)
	GameState.gems += bonus
	_update_ui()
	print("[RoundEnd] Ad bonus: +", bonus, " Gem")
