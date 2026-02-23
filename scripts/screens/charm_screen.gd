extends Control

## Charm ekrani. Charm listesi, satin alma, seviye yukseltme.

const CharmDataRef := preload("res://scripts/systems/charm_data.gd")
const AchievementRef := preload("res://scripts/systems/achievement_system.gd")
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

@onready var cp_label: Label = %CPLabel
@onready var charm_list: VBoxContainer = %CharmList
@onready var back_btn: Button = %BackBtn


func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	GameState.charm_points_changed.connect(_on_cp_changed)
	_apply_theme()
	_build_charm_list()
	_update_cp()
	print("[CharmScreen] Ready — CP: ", GameState.charm_points)


func _apply_theme() -> void:
	$Background.color = ThemeHelper.BG_DARK
	var title: Label = $VBox/TopBar/Title
	ThemeHelper.style_title_label(title, ThemeHelper.NEON_CYAN, 24)
	ThemeHelper.style_label(cp_label, ThemeHelper.NEON_GOLD, 18)
	ThemeHelper.make_neon_button(back_btn, ThemeHelper.NEON_RED, 16)


func _update_cp() -> void:
	cp_label.text = "%s CP" % GameState.format_number(GameState.charm_points)


func _on_cp_changed(_new_amount: int) -> void:
	_update_cp()


func _build_charm_list() -> void:
	var current_category := ""

	for charm_id in CharmDataRef.CHARM_ORDER:
		var charm: Dictionary = CharmDataRef.get_charm(charm_id)
		if charm.is_empty():
			continue

		# Kategori basligini ekle
		var category: String = charm["category"]
		if category != current_category:
			current_category = category
			_add_section_header(category)

		# Charm satirini ekle
		_add_charm_item(charm_id, charm)


func _add_section_header(category: String) -> void:
	var labels := {
		"basic": "TEMEL CHARM'LAR",
		"key": "ANAHTAR CHARM'LAR",
		"power": "GUCLU CHARM'LAR",
	}

	var sep := HSeparator.new()
	charm_list.add_child(sep)

	var header := Label.new()
	header.text = labels.get(category, category.to_upper())
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ThemeHelper.style_label(header, ThemeHelper.NEON_GOLD, 16)
	charm_list.add_child(header)


func _add_charm_item(charm_id: String, charm: Dictionary) -> void:
	var level: int = GameState.get_charm_level(charm_id)
	var max_level: int = charm["max_level"]
	var cost: int = charm["cost"]

	# Ana konteyner
	var item := PanelContainer.new()
	item.custom_minimum_size.y = 70
	var item_color := ThemeHelper.NEON_CYAN if level > 0 else ThemeHelper.TEXT_DIM
	ThemeHelper.make_card_panel(item, item_color)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	item.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(hbox)

	# Sol: bilgi
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	# Isim + seviye
	var name_label := Label.new()
	if level > 0 and max_level > 1:
		name_label.text = "%s  Lv.%d" % [charm["name"], level]
	elif level > 0 and max_level == 1:
		name_label.text = "%s  AKTIF" % charm["name"]
	else:
		name_label.text = charm["name"]
	ThemeHelper.style_label(name_label, ThemeHelper.TEXT_WHITE, 15)
	info_vbox.add_child(name_label)

	# Efekt aciklamasi
	var desc_label := Label.new()
	desc_label.text = CharmDataRef.get_effect_text(charm_id, level)
	ThemeHelper.style_label(desc_label, ThemeHelper.TEXT_DIM, 12)
	info_vbox.add_child(desc_label)

	# Sag: buton
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(110, 40)

	if level >= max_level:
		btn.text = "MAX"
		btn.disabled = true
	elif level > 0:
		btn.text = "+  %d CP" % cost
		btn.disabled = GameState.charm_points < cost
	else:
		btn.text = "AL  %d CP" % cost
		btn.disabled = GameState.charm_points < cost

	ThemeHelper.make_neon_button(btn, ThemeHelper.NEON_GREEN, 13)
	btn.pressed.connect(_on_charm_buy.bind(charm_id))
	hbox.add_child(btn)

	charm_list.add_child(item)


func _on_charm_buy(charm_id: String) -> void:
	if GameState.buy_charm(charm_id):
		# Basarim kontrolu (anahtar charm'lar ve charm ustasi)
		var context := {}
		var new_achievements: Array = AchievementRef.check_achievements(context)
		for ach_id in new_achievements:
			if ach_id not in GameState.unlocked_achievements:
				GameState.unlocked_achievements.append(ach_id)
				var ach: Dictionary = AchievementRef.get_achievement(ach_id)
				var reward_cp: int = ach.get("reward_cp", 0)
				GameState.charm_points += reward_cp
				var display_name: String = ach.get("real_name", ach.get("name", ach_id))
				print("[CharmScreen] Basarim acildi: %s (+%d CP)" % [display_name, reward_cp])
				GameState.achievement_unlocked.emit(ach_id)
				SaveManager.save_game()
		_rebuild_list()


func _rebuild_list() -> void:
	for child in charm_list.get_children():
		charm_list.remove_child(child)
		child.queue_free()
	_build_charm_list()


func _on_back() -> void:
	SceneTransition.change_scene("res://scenes/screens/MainMenu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()
		get_viewport().set_input_as_handled()
