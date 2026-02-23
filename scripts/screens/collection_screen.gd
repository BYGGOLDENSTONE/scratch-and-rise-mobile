extends Control

## Koleksiyon ekrani. Set'ler, parcalar ve bonuslar.
const CollectionRef := preload("res://scripts/systems/collection_system.gd")

@onready var collection_list: VBoxContainer = %CollectionList
@onready var back_btn: Button = %BackBtn


func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	_build_collection_list()
	print("[CollectionScreen] Ready")


func _build_collection_list() -> void:
	for set_id in CollectionRef.SET_ORDER:
		var set_data: Dictionary = CollectionRef.get_set(set_id)
		if set_data.is_empty():
			continue
		_add_set_card(set_id, set_data)


func _add_set_card(set_id: String, set_data: Dictionary) -> void:
	var is_complete: bool = CollectionRef.is_set_complete(set_id)

	# Ana kart
	var card := PanelContainer.new()
	card.custom_minimum_size.y = 100

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	# Set ismi
	var name_label := Label.new()
	name_label.text = set_data["name"]
	if is_complete:
		name_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	vbox.add_child(name_label)

	# Parcalar satiri
	var pieces_hbox := HBoxContainer.new()
	pieces_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(pieces_hbox)

	var pieces: Array = set_data["pieces"]
	var piece_names: Dictionary = set_data["piece_names"]
	for piece_id in pieces:
		var has_piece: bool = GameState.has_collection_piece(set_id, piece_id)
		var piece_label := Label.new()
		piece_label.text = piece_names.get(piece_id, piece_id)
		piece_label.add_theme_font_size_override("font_size", 12)
		if has_piece:
			piece_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.3))
		else:
			piece_label.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
		pieces_hbox.add_child(piece_label)

	# Bonus bilgisi
	var bonus_label := Label.new()
	bonus_label.add_theme_font_size_override("font_size", 12)
	if is_complete:
		bonus_label.text = "TAMAMLANDI! %s" % set_data["bonus_text"]
		bonus_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	else:
		var collected_count := 0
		for p_id in pieces:
			if GameState.has_collection_piece(set_id, p_id):
				collected_count += 1
		bonus_label.text = "%d / %d — Bonus: %s" % [collected_count, pieces.size(), set_data["bonus_text"]]
		bonus_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(bonus_label)

	collection_list.add_child(card)


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/screens/MainMenu.tscn")
