extends PanelContainer

## Gunluk giris odulu popup'u. 7 gunluk takvim gosterir.
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")
const DailyLoginRef := preload("res://scripts/systems/daily_login.gd")

signal popup_closed

var _current_day: int = 0  # Bugun odul alinacak gun (0 = odul yok)


func _ready() -> void:
	_apply_theme()
	_build_ui()
	# Giris animasyonu
	var panel: PanelContainer = $CenterBox/Panel
	panel.pivot_offset = panel.size / 2
	panel.scale = Vector2(0.8, 0.8)
	panel.modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(panel, "modulate:a", 1.0, 0.2)


func setup(reward_day: int) -> void:
	_current_day = reward_day


func _apply_theme() -> void:
	var panel: PanelContainer = $CenterBox/Panel
	ThemeHelper.make_panel(panel, ThemeHelper.p("warning"), ThemeHelper.p("bg_panel"))
	$BG.color = Color(0, 0, 0, 0.7)


func _build_ui() -> void:
	var vbox: VBoxContainer = $CenterBox/Panel/VBox
	# Baslik
	var title: Label = $CenterBox/Panel/VBox/Title
	ThemeHelper.style_title(title, ThemeHelper.p("warning"), 22)
	title.text = tr("GUNLUK_GIRIS")

	# Streak bilgisi
	var streak_label: Label = $CenterBox/Panel/VBox/StreakLabel
	ThemeHelper.style_label(streak_label, ThemeHelper.p("text_secondary"), 15)
	streak_label.text = tr("ARDISIK_GIRIS_FMT") % GameState.login_streak

	# 7 gunluk grid
	var grid: GridContainer = $CenterBox/Panel/VBox/DayGrid
	for child in grid.get_children():
		child.queue_free()

	for i in range(7):
		var day_num: int = i + 1
		var reward: Dictionary = DailyLoginRef.LOGIN_REWARDS[i]
		var card := _create_day_card(day_num, reward)
		grid.add_child(card)

	# Topla butonu
	var claim_btn: Button = $CenterBox/Panel/VBox/ClaimBtn
	if _current_day > 0 and not GameState.login_reward_claimed:
		claim_btn.text = tr("ODULU_TOPLA")
		claim_btn.disabled = false
		ThemeHelper.make_button(claim_btn, ThemeHelper.p("success"), 20)
	else:
		claim_btn.text = tr("TAMAM")
		claim_btn.disabled = false
		ThemeHelper.make_button(claim_btn, ThemeHelper.p("primary"), 20)
	claim_btn.pressed.connect(_on_claim)


func _create_day_card(day: int, reward: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(85, 80)

	var is_today: bool = (day == _current_day and not GameState.login_reward_claimed)
	var is_past: bool = (day < GameState.login_streak) or (day == GameState.login_streak and GameState.login_reward_claimed)
	var is_future: bool = not is_today and not is_past

	if is_today:
		ThemeHelper.make_card(card, ThemeHelper.p("warning"))
	elif is_past:
		ThemeHelper.make_card(card, ThemeHelper.p("success"))
	else:
		ThemeHelper.make_card(card, ThemeHelper.p("text_muted"))

	var inner_vbox := VBoxContainer.new()
	inner_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	inner_vbox.add_theme_constant_override("separation", 2)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	margin.add_child(inner_vbox)
	card.add_child(margin)

	# Gun numarasi
	var day_label := Label.new()
	day_label.text = tr("GUN_FMT") % day
	day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ThemeHelper.style_label(day_label, ThemeHelper.p("text_primary"), 12)
	inner_vbox.add_child(day_label)

	# Odul ikonu / text
	var reward_label := Label.new()
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_label.autowrap_mode = TextServer.AUTOWRAP_WORD

	match reward["type"]:
		"energy":
			reward_label.text = "+%d E" % reward["amount"]
			ThemeHelper.style_label(reward_label, ThemeHelper.p("success"), 14)
		"gem":
			reward_label.text = "+%d G" % reward["amount"]
			ThemeHelper.style_label(reward_label, ThemeHelper.p("info"), 14)
		"collection":
			reward_label.text = tr("PARCA")
			ThemeHelper.style_label(reward_label, ThemeHelper.p("secondary"), 13)
		"gem_and_collection":
			reward_label.text = "+%dG\n+Parca" % reward["amount"]
			ThemeHelper.style_label(reward_label, ThemeHelper.p("warning"), 12)
	inner_vbox.add_child(reward_label)

	# Durum
	if is_past:
		var check := Label.new()
		check.text = "OK"
		check.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ThemeHelper.style_label(check, ThemeHelper.p("success"), 11)
		inner_vbox.add_child(check)

	return card


func _on_claim() -> void:
	if _current_day > 0 and not GameState.login_reward_claimed:
		SoundManager.play("coin_gain")
		DailyLoginRef.claim_reward()
	else:
		SoundManager.play("popup_close")
	popup_closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_claim()
		get_viewport().set_input_as_handled()
