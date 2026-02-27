extends Control

## Basarim ekrani. Kategorilere gore listeleme + ilerleme cubugu + nadir gosterimi.
const AchievementRef := preload("res://scripts/systems/achievement_system.gd")
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

@onready var achievement_list: VBoxContainer = %AchievementList
@onready var back_btn: Button = %BackBtn
@onready var counter_label: Label = %CounterLabel


func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	GameState.locale_changed.connect(func(_l): _update_texts(); _rebuild_all())
	_apply_theme()
	_update_texts()
	_build_header()
	_build_list()
	print("[AchievementScreen] Ready — %d basarim" % AchievementRef.ACHIEVEMENT_ORDER.size())


func _update_texts() -> void:
	var title: Label = $VBox/TopBar/Title
	title.text = tr("BASARIMLAR_EKRANI")
	back_btn.text = tr("GERI")


func _apply_theme() -> void:
	$Background.color = ThemeHelper.p("bg_main")
	var title: Label = $VBox/TopBar/Title
	ThemeHelper.style_title(title, ThemeHelper.p("warning"), 26)
	ThemeHelper.style_label(counter_label, ThemeHelper.p("text_secondary"), 17)
	ThemeHelper.make_button(back_btn, ThemeHelper.p("danger"), 17)


## Ust kisimda toplam ilerleme cubugu
func _build_header() -> void:
	var total: int = AchievementRef.ACHIEVEMENT_ORDER.size()
	var unlocked: int = GameState.unlocked_achievements.size()
	counter_label.text = "%d / %d" % [unlocked, total]

	# Ilerleme cubugu
	var progress_bar := _create_progress_bar(unlocked, total, ThemeHelper.p("warning"))
	# TopBar'in altina ekle (achievement_list'in basina)
	achievement_list.add_child(progress_bar)

	# Bosluk
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 8
	achievement_list.add_child(spacer)


func _build_list() -> void:
	var current_category := ""

	for ach_id in AchievementRef.ACHIEVEMENT_ORDER:
		var ach: Dictionary = AchievementRef.get_achievement(ach_id)
		if ach.is_empty():
			continue

		var category: String = ach["category"]
		if category != current_category:
			current_category = category
			_add_section_header(category)

		_add_achievement_item(ach_id, ach)


func _add_section_header(category: String) -> void:
	# Bosluk
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 6
	achievement_list.add_child(spacer)

	# Kategori header + ilerleme
	var header_box := HBoxContainer.new()
	header_box.custom_minimum_size.y = 36
	achievement_list.add_child(header_box)

	var header := Label.new()
	header.text = AchievementRef.CATEGORY_NAMES.get(category, category.to_upper())
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ThemeHelper.style_label(header, ThemeHelper.p("warning"), 16)
	header_box.add_child(header)

	# Kategori ilerleme
	var counts: Dictionary = AchievementRef.get_category_counts(category)
	var count_label := Label.new()
	count_label.text = "%d/%d" % [counts["unlocked"], counts["total"]]
	ThemeHelper.style_label(count_label, ThemeHelper.p("text_secondary"), 14)
	header_box.add_child(count_label)

	# Kategori ilerleme cubugu
	var cat_color: Color
	match category:
		"early": cat_color = AchievementRef.RARITY_COLORS["common"]
		"mid": cat_color = AchievementRef.RARITY_COLORS["uncommon"]
		"late": cat_color = AchievementRef.RARITY_COLORS["rare"]
		"hidden": cat_color = AchievementRef.RARITY_COLORS["epic"]
		_: cat_color = ThemeHelper.p("primary")

	var progress := _create_progress_bar(counts["unlocked"], counts["total"], cat_color)
	achievement_list.add_child(progress)


func _add_achievement_item(ach_id: String, ach: Dictionary) -> void:
	var is_unlocked: bool = ach_id in GameState.unlocked_achievements
	var rarity: String = ach.get("rarity", "common")
	var rarity_color: Color = AchievementRef.RARITY_COLORS.get(rarity, AchievementRef.RARITY_COLORS["common"])

	# Ana kart
	var card := PanelContainer.new()
	card.custom_minimum_size.y = 76
	if is_unlocked:
		ThemeHelper.make_card(card, rarity_color)
	else:
		ThemeHelper.make_card(card, ThemeHelper.p("text_muted"))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	card.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 8)
	margin.add_child(hbox)

	# Sol: rarity strip (5px)
	var strip := ColorRect.new()
	strip.custom_minimum_size = Vector2(5, 0)
	strip.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if is_unlocked:
		strip.color = rarity_color
	else:
		strip.color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.25)
	hbox.add_child(strip)

	# Orta: bilgi
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(info_vbox)

	# Basarim ismi
	var name_label := Label.new()
	name_label.text = AchievementRef.get_display_name(ach_id)
	if is_unlocked:
		ThemeHelper.style_label(name_label, ThemeHelper.p("text_primary"), 16)
	else:
		ThemeHelper.style_label(name_label, ThemeHelper.p("text_muted"), 16)
	info_vbox.add_child(name_label)

	# Aciklama
	var desc_label := Label.new()
	desc_label.text = AchievementRef.get_display_description(ach_id)
	ThemeHelper.style_label(desc_label, ThemeHelper.p("text_secondary"), 12)
	info_vbox.add_child(desc_label)

	# Rarity etiketi (sadece acilmissa)
	if is_unlocked:
		var rarity_label := Label.new()
		rarity_label.text = AchievementRef.RARITY_NAMES.get(rarity, "")
		ThemeHelper.style_label(rarity_label, rarity_color, 11)
		info_vbox.add_child(rarity_label)

	# Sag: odul
	var reward_box := VBoxContainer.new()
	reward_box.custom_minimum_size.x = 60
	reward_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(reward_box)

	var reward_label := Label.new()
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if is_unlocked:
		reward_label.text = tr("GEM_ODUL_FMT") % ach["reward_gem"]
		ThemeHelper.style_label(reward_label, ThemeHelper.p("warning"), 17)
	else:
		reward_label.text = "%d Gem" % ach["reward_gem"]
		ThemeHelper.style_label(reward_label, ThemeHelper.p("text_muted"), 15)
	reward_box.add_child(reward_label)

	achievement_list.add_child(card)


## Ilerleme cubugu olustur
func _create_progress_bar(current: int, total: int, color: Color) -> Control:
	var bar := Control.new()
	bar.custom_minimum_size = Vector2(0, 10)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Arka plan
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = ThemeHelper.p("bg_card")
	bar.add_child(bg)

	# Dolu kisim (yuzdesel)
	if total > 0 and current > 0:
		var fill := ColorRect.new()
		fill.anchor_right = clampf(float(current) / float(total), 0.0, 1.0)
		fill.anchor_bottom = 1.0
		fill.color = color
		bar.add_child(fill)

	return bar


func _rebuild_all() -> void:
	for child in achievement_list.get_children():
		child.queue_free()
	_build_header()
	_build_list()


func _on_back() -> void:
	SoundManager.play("ui_back")
	if GameState.in_round:
		SceneTransition.change_scene("res://scenes/main/Main.tscn")
	else:
		SceneTransition.change_scene("res://scenes/screens/MainMenu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()
		get_viewport().set_input_as_handled()
