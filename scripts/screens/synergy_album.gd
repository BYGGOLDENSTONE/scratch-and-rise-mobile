extends Control

## Sinerji albumu ekrani. Kesfedilen ve kesfedilmemis sinerjileri gosterir.
const SynergyRef := preload("res://scripts/systems/synergy_system.gd")
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

@onready var count_label: Label = %CountLabel
@onready var synergy_list: VBoxContainer = %SynergyList
@onready var back_btn: Button = %BackBtn


func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	_apply_theme()
	_build_synergy_list()
	print("[SynergyAlbum] Ready")


func _apply_theme() -> void:
	$Background.color = ThemeHelper.p("bg_main")
	var title: Label = $VBox/TopBar/Title
	ThemeHelper.style_title(title, ThemeHelper.p("secondary"), 26)
	ThemeHelper.style_label(count_label, ThemeHelper.p("text_secondary"), 17)
	ThemeHelper.make_button(back_btn, ThemeHelper.p("danger"), 17)


func _build_synergy_list() -> void:
	var discovered_count := 0
	var total_count: int = SynergyRef.SYNERGY_ORDER.size()

	for synergy_id in SynergyRef.SYNERGY_ORDER:
		var synergy: Dictionary = SynergyRef.get_synergy(synergy_id)
		if synergy.is_empty():
			continue

		var discovered: bool = GameState.is_synergy_discovered(synergy_id)
		if discovered:
			discovered_count += 1

		_add_synergy_item(synergy_id, synergy, discovered)

	count_label.text = "%d / %d Kesfedildi" % [discovered_count, total_count]


func _add_synergy_item(synergy_id: String, synergy: Dictionary, discovered: bool) -> void:
	var is_hidden: bool = synergy.get("hidden", false)

	var item := PanelContainer.new()
	item.custom_minimum_size.y = 70
	var border_color := ThemeHelper.p("secondary") if discovered else ThemeHelper.p("text_muted")
	ThemeHelper.make_card(item, border_color)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	item.add_child(margin)

	var vbox := VBoxContainer.new()
	margin.add_child(vbox)

	var name_label := Label.new()
	var desc_label := Label.new()

	if discovered:
		var display_name: String = synergy["name"]
		if is_hidden:
			display_name = synergy["name"]
		name_label.text = "%s  x%d" % [display_name, synergy["multiplier"]]
		ThemeHelper.style_label(name_label, ThemeHelper.p("success"), 17)
		desc_label.text = synergy.get("condition_text", "")
		ThemeHelper.style_label(desc_label, ThemeHelper.p("text_primary"), 13)
	else:
		if is_hidden:
			name_label.text = "???"
			desc_label.text = "Gizli sinerji"
		else:
			name_label.text = "%s  x%d" % [synergy["name"], synergy["multiplier"]]
			desc_label.text = "Henuz kesfedilmedi"
		ThemeHelper.style_label(name_label, ThemeHelper.p("text_muted"), 17)
		ThemeHelper.style_label(desc_label, ThemeHelper.p("text_muted"), 13)

	vbox.add_child(name_label)
	vbox.add_child(desc_label)
	synergy_list.add_child(item)


func _on_back() -> void:
	SceneTransition.change_scene("res://scenes/screens/MainMenu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()
		get_viewport().set_input_as_handled()
