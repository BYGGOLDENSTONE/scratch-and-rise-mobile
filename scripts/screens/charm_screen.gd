extends Control

## Charm ekrani. Charm listesi, satin alma, seviye yukseltme.

const CharmDataRef := preload("res://scripts/systems/charm_data.gd")
const AchievementRef := preload("res://scripts/systems/achievement_system.gd")
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

@onready var gem_label: Label = %GemLabel
@onready var charm_list: VBoxContainer = %CharmList
@onready var back_btn: Button = %BackBtn


func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	GameState.gems_changed.connect(_on_gems_changed)
	GameState.locale_changed.connect(func(_l): _update_texts(); _rebuild_list(); _update_gems())
	_apply_theme()
	_update_texts()
	_build_charm_list()
	_update_gems()
	print("[CharmScreen] Ready — Gem: ", GameState.gems)


func _update_texts() -> void:
	var title: Label = $VBox/TopBar/Title
	title.text = tr("CHARM_EKRANI")
	back_btn.text = tr("GERI")


func _apply_theme() -> void:
	$Background.color = ThemeHelper.p("bg_main")
	var title: Label = $VBox/TopBar/Title
	ThemeHelper.style_title(title, ThemeHelper.p("info"), 26)
	ThemeHelper.style_label(gem_label, ThemeHelper.p("warning"), 20)
	ThemeHelper.make_button(back_btn, ThemeHelper.p("danger"), 17)


func _update_gems() -> void:
	gem_label.text = tr("GEM_FMT") % GameState.format_number(GameState.gems)


func _on_gems_changed(_new_amount: int) -> void:
	_update_gems()


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
	var label_keys := {
		"basic": "TEMEL_CHARMLAR",
		"mid": "ORTA_CHARMLAR",
		"power": "GUCLU_CHARMLAR",
	}

	var sep := HSeparator.new()
	charm_list.add_child(sep)

	var header := Label.new()
	var key: String = label_keys.get(category, "")
	header.text = tr(key) if key != "" else category.to_upper()
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ThemeHelper.style_label(header, ThemeHelper.p("warning"), 16)
	charm_list.add_child(header)


func _add_charm_item(charm_id: String, charm: Dictionary) -> void:
	var level: int = GameState.get_charm_level(charm_id)
	var max_level: int = charm["max_level"]
	var cost: int = charm["cost"]

	# Ana konteyner
	var item := PanelContainer.new()
	item.custom_minimum_size.y = 70
	var item_color := ThemeHelper.p("info") if level > 0 else ThemeHelper.p("text_secondary")
	ThemeHelper.make_card(item, item_color)

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
	var charm_display_name: String = tr("CHARM_NAME_" + charm_id.to_upper())
	if level > 0 and max_level > 1:
		name_label.text = "%s  Lv.%d" % [charm_display_name, level]
	elif level > 0 and max_level == 1:
		name_label.text = "%s  %s" % [charm_display_name, tr("AKTIF")]
	else:
		name_label.text = charm_display_name
	ThemeHelper.style_label(name_label, ThemeHelper.p("text_primary"), 16)
	info_vbox.add_child(name_label)

	# Efekt aciklamasi
	var desc_label := Label.new()
	desc_label.text = CharmDataRef.get_effect_text(charm_id, level)
	ThemeHelper.style_label(desc_label, ThemeHelper.p("text_secondary"), 13)
	info_vbox.add_child(desc_label)

	# Sag: buton
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(110, 40)

	if level >= max_level:
		btn.text = tr("MAX")
		btn.disabled = true
	elif level > 0:
		btn.text = tr("CHARM_UP_FMT") % cost
		btn.disabled = GameState.gems < cost
	else:
		btn.text = tr("CHARM_AL_FMT") % cost
		btn.disabled = GameState.gems < cost

	ThemeHelper.make_button(btn, ThemeHelper.p("success"), 14)
	btn.pressed.connect(_on_charm_buy.bind(charm_id))
	hbox.add_child(btn)

	charm_list.add_child(item)


func _on_charm_buy(charm_id: String) -> void:
	if GameState.buy_charm(charm_id):
		SoundManager.play("charm_buy")
		# Basarim kontrolu (anahtar charm'lar ve charm ustasi)
		var context := {}
		var new_achievements: Array = AchievementRef.check_achievements(context)
		for ach_id in new_achievements:
			if ach_id not in GameState.unlocked_achievements:
				GameState.unlocked_achievements.append(ach_id)
				var ach: Dictionary = AchievementRef.get_achievement(ach_id)
				var reward_gem: int = ach.get("reward_gem", 0)
				GameState.gems += reward_gem
				var display_name: String = ach.get("real_name", ach.get("name", ach_id))
				print("[CharmScreen] Basarim acildi: %s (+%d Gem)" % [display_name, reward_gem])
				GameState.achievement_unlocked.emit(ach_id)
				SaveManager.save_game()
		_rebuild_list()


func _rebuild_list() -> void:
	for child in charm_list.get_children():
		charm_list.remove_child(child)
		child.queue_free()
	_build_charm_list()


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
