extends Control

## Gunluk gorevler ekrani. 3 gorev + bonus odul.
const DailyQuestRef := preload("res://scripts/systems/daily_quest_system.gd")
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

@onready var quest_list: VBoxContainer = %QuestList
@onready var back_btn: Button = %BackBtn
@onready var bonus_btn: Button = %BonusBtn


func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	bonus_btn.pressed.connect(_on_bonus)
	DailyQuestRef.check_and_refresh_quests()
	GameState.locale_changed.connect(func(_l): _update_texts(); _build_list(); _update_bonus_btn())
	_apply_theme()
	_update_texts()
	_build_list()
	_update_bonus_btn()
	print("[DailyQuestScreen] Ready")


func _update_texts() -> void:
	var title: Label = $VBox/TopBar/Title
	title.text = tr("GUNLUK_GOREVLER")
	back_btn.text = tr("GERI")


func _apply_theme() -> void:
	$Background.color = ThemeHelper.p("bg_main")
	var title: Label = $VBox/TopBar/Title
	ThemeHelper.style_title(title, ThemeHelper.p("warning"), 26)
	ThemeHelper.make_button(back_btn, ThemeHelper.p("danger"), 17)


func _build_list() -> void:
	for child in quest_list.get_children():
		child.queue_free()

	var quests: Array = DailyQuestRef.get_quest_display()
	for i in range(quests.size()):
		var quest: Dictionary = quests[i]
		_add_quest_card(i, quest)


func _add_quest_card(index: int, quest: Dictionary) -> void:
	var is_completed: bool = quest.get("completed", false)
	var is_claimed: bool = quest.get("reward_claimed", false)

	var card := PanelContainer.new()
	card.custom_minimum_size.y = 90

	if is_claimed:
		ThemeHelper.make_card(card, ThemeHelper.p("success"))
	elif is_completed:
		ThemeHelper.make_card(card, ThemeHelper.p("warning"))
	else:
		ThemeHelper.make_card(card, ThemeHelper.p("text_secondary"))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 10)
	margin.add_child(hbox)

	# Sol: gorev bilgisi
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)

	var name_label := Label.new()
	name_label.text = quest.get("name", tr("GOREV"))
	ThemeHelper.style_label(name_label, ThemeHelper.p("text_primary"), 16)
	info_vbox.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = quest.get("description", "")
	ThemeHelper.style_label(desc_label, ThemeHelper.p("text_secondary"), 13)
	info_vbox.add_child(desc_label)

	# Ilerleme cubugu
	var progress: int = quest.get("progress", 0)
	var target: int = quest.get("target", 1)
	var progress_hbox := HBoxContainer.new()
	progress_hbox.add_theme_constant_override("separation", 6)
	info_vbox.add_child(progress_hbox)

	var bar_bg := Control.new()
	bar_bg.custom_minimum_size = Vector2(120, 8)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_hbox.add_child(bar_bg)

	var bg_rect := ColorRect.new()
	bg_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_rect.color = ThemeHelper.p("bg_card")
	bar_bg.add_child(bg_rect)

	if progress > 0 and target > 0:
		var fill := ColorRect.new()
		fill.anchor_right = clampf(float(progress) / float(target), 0.0, 1.0)
		fill.anchor_bottom = 1.0
		fill.color = ThemeHelper.p("success") if is_completed else ThemeHelper.p("primary")
		bar_bg.add_child(fill)

	var progress_label := Label.new()
	progress_label.text = "%d/%d" % [mini(progress, target), target]
	ThemeHelper.style_label(progress_label, ThemeHelper.p("text_secondary"), 12)
	progress_hbox.add_child(progress_label)

	# Sag: odul + buton
	var right_vbox := VBoxContainer.new()
	right_vbox.custom_minimum_size.x = 90
	right_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(right_vbox)

	# Odul text
	var reward_text := ""
	var gem_r: int = quest.get("reward_gem", 0)
	var energy_r: int = quest.get("reward_energy", 0)
	if gem_r > 0:
		reward_text += tr("GEM_ODUL_FMT") % gem_r
	if energy_r > 0:
		if reward_text != "":
			reward_text += "\n"
		reward_text += tr("ENERJI_ODUL_FMT") % energy_r

	var reward_label := Label.new()
	reward_label.text = reward_text
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ThemeHelper.style_label(reward_label, ThemeHelper.p("info"), 14)
	right_vbox.add_child(reward_label)

	if is_completed and not is_claimed:
		var claim_btn := Button.new()
		claim_btn.text = tr("TOPLA")
		claim_btn.custom_minimum_size = Vector2(80, 32)
		ThemeHelper.make_button(claim_btn, ThemeHelper.p("success"), 14)
		claim_btn.pressed.connect(_on_claim_quest.bind(index))
		right_vbox.add_child(claim_btn)
	elif is_claimed:
		var done_label := Label.new()
		done_label.text = tr("TOPLANDI")
		done_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ThemeHelper.style_label(done_label, ThemeHelper.p("success"), 13)
		right_vbox.add_child(done_label)

	quest_list.add_child(card)


func _on_claim_quest(index: int) -> void:
	var result: Dictionary = DailyQuestRef.claim_quest_reward(index)
	if not result.is_empty():
		SoundManager.play("coin_gain")
		_build_list()
		_update_bonus_btn()


func _update_bonus_btn() -> void:
	var all_done: bool = DailyQuestRef.all_quests_completed()
	var all_claimed := true
	for quest in GameState.daily_quests:
		if quest.get("completed", false) and not quest.get("reward_claimed", false):
			all_claimed = false
			break

	if all_done and all_claimed and not GameState.daily_bonus_claimed:
		bonus_btn.text = tr("BONUS_TOPLA_FMT") % DailyQuestRef.DAILY_BONUS_GEM
		bonus_btn.disabled = false
		ThemeHelper.make_button(bonus_btn, ThemeHelper.p("warning"), 20)
	elif GameState.daily_bonus_claimed:
		bonus_btn.text = tr("BONUS_TOPLANDI")
		bonus_btn.disabled = true
		ThemeHelper.make_button(bonus_btn, ThemeHelper.p("text_muted"), 18)
	else:
		var completed_count := 0
		for quest in GameState.daily_quests:
			if quest.get("completed", false):
				completed_count += 1
		bonus_btn.text = tr("BONUS_FMT") % completed_count
		bonus_btn.disabled = true
		ThemeHelper.make_button(bonus_btn, ThemeHelper.p("text_muted"), 16)


func _on_bonus() -> void:
	var bonus: int = DailyQuestRef.claim_daily_bonus()
	if bonus > 0:
		SoundManager.play("big_win")
		_update_bonus_btn()


func _on_back() -> void:
	SoundManager.play("ui_back")
	SceneTransition.change_scene("res://scenes/screens/MainMenu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()
		get_viewport().set_input_as_handled()
