extends Control

## Basarim ekrani. Kategorilere gore listeleme.
const AchievementRef := preload("res://scripts/systems/achievement_system.gd")

@onready var achievement_list: VBoxContainer = %AchievementList
@onready var back_btn: Button = %BackBtn
@onready var counter_label: Label = %CounterLabel


func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	_build_list()
	_update_counter()
	print("[AchievementScreen] Ready")


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
	header.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	achievement_list.add_child(header)


func _add_achievement_item(ach_id: String, ach: Dictionary) -> void:
	var is_unlocked: bool = ach_id in GameState.unlocked_achievements

	# Ana kart
	var card := PanelContainer.new()
	card.custom_minimum_size.y = 70

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
		name_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.3))
	else:
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	info_vbox.add_child(name_label)

	# Aciklama
	var desc_label := Label.new()
	desc_label.text = AchievementRef.get_display_description(ach_id)
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	info_vbox.add_child(desc_label)

	# Sag: odul
	var reward_label := Label.new()
	reward_label.custom_minimum_size.x = 60
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if is_unlocked:
		reward_label.text = "+%d CP" % ach["reward_cp"]
		reward_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.3))
	else:
		reward_label.text = "%d CP" % ach["reward_cp"]
		reward_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	hbox.add_child(reward_label)

	achievement_list.add_child(card)


func _on_back() -> void:
	SceneTransition.change_scene("res://scenes/screens/MainMenu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()
		get_viewport().set_input_as_handled()
