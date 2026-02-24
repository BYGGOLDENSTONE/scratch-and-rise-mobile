extends Control

## Basarim ekrani. Kategorilere gore listeleme.
const AchievementRef := preload("res://scripts/systems/achievement_system.gd")
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

@onready var achievement_list: VBoxContainer = %AchievementList
@onready var back_btn: Button = %BackBtn
@onready var counter_label: Label = %CounterLabel


func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	_apply_theme()
	_build_list()
	_update_counter()
	print("[AchievementScreen] Ready")


func _apply_theme() -> void:
	$Background.color = ThemeHelper.p("bg_main")
	var title: Label = $VBox/TopBar/Title
	ThemeHelper.style_title(title, ThemeHelper.p("warning"), 26)
	ThemeHelper.style_label(counter_label, ThemeHelper.p("text_secondary"), 17)
	ThemeHelper.make_button(back_btn, ThemeHelper.p("danger"), 17)


func _update_counter() -> void:
	var total: int = AchievementRef.ACHIEVEMENT_ORDER.size()
	var unlocked: int = GameState.unlocked_achievements.size()
	counter_label.text = "%d / %d" % [unlocked, total]


func _build_list() -> void:
	var current_category := ""

	for ach_id in AchievementRef.ACHIEVEMENT_ORDER:
		var ach: Dictionary = AchievementRef.get_achievement(ach_id)
		if ach.is_empty():
			continue

		# Kategori basligini ekle
		var category: String = ach["category"]
		if category != current_category:
			current_category = category
			_add_section_header(category)

		_add_achievement_item(ach_id, ach)


func _add_section_header(category: String) -> void:
	var sep := HSeparator.new()
	achievement_list.add_child(sep)

	var header := Label.new()
	header.text = AchievementRef.CATEGORY_NAMES.get(category, category.to_upper())
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ThemeHelper.style_label(header, ThemeHelper.p("warning"), 16)
	achievement_list.add_child(header)


func _add_achievement_item(ach_id: String, ach: Dictionary) -> void:
	var is_unlocked: bool = ach_id in GameState.unlocked_achievements

	# Ana kart
	var card := PanelContainer.new()
	card.custom_minimum_size.y = 70
	var card_color := ThemeHelper.p("success") if is_unlocked else ThemeHelper.p("text_muted")
	ThemeHelper.make_card(card, card_color)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	card.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(hbox)

	# Sol: bilgi
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	# Basarim ismi
	var name_label := Label.new()
	name_label.text = AchievementRef.get_display_name(ach_id)
	if is_unlocked:
		ThemeHelper.style_label(name_label, ThemeHelper.p("success"), 16)
	else:
		ThemeHelper.style_label(name_label, ThemeHelper.p("text_muted"), 16)
	info_vbox.add_child(name_label)

	# Aciklama
	var desc_label := Label.new()
	desc_label.text = AchievementRef.get_display_description(ach_id)
	ThemeHelper.style_label(desc_label, ThemeHelper.p("text_secondary"), 13)
	info_vbox.add_child(desc_label)

	# Sag: odul
	var reward_label := Label.new()
	reward_label.custom_minimum_size.x = 60
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if is_unlocked:
		reward_label.text = "+%d CP" % ach["reward_cp"]
		ThemeHelper.style_label(reward_label, ThemeHelper.p("success"), 16)
	else:
		reward_label.text = "%d CP" % ach["reward_cp"]
		ThemeHelper.style_label(reward_label, ThemeHelper.p("text_muted"), 16)
	hbox.add_child(reward_label)

	achievement_list.add_child(card)


func _on_back() -> void:
	if GameState.in_round:
		SceneTransition.change_scene("res://scenes/main/Main.tscn")
	else:
		SceneTransition.change_scene("res://scenes/screens/MainMenu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()
		get_viewport().set_input_as_handled()
