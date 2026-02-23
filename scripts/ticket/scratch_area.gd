extends Control

## Tek kazima alani. Dokunmayla kapak acilir, sembol belirir.

signal area_scratched(area_index: int)

var area_index: int = -1
var symbol_type: String = ""
var is_scratched: bool = false

@onready var cover_panel: Panel = $CoverPanel
@onready var cover_label: Label = $CoverPanel/CoverLabel
@onready var symbol_panel: Panel = $SymbolPanel
@onready var symbol_label: Label = $SymbolPanel/SymbolLabel


func setup(idx: int, symbol: String) -> void:
	area_index = idx
	symbol_type = symbol
	is_scratched = false

	# Sembol bilgilerini ayarla
	symbol_label.text = TicketData.get_display_name(symbol)
	var color: Color = TicketData.get_color(symbol)

	# Sembol panelini renklendir
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	symbol_panel.add_theme_stylebox_override("panel", style)

	# Baslangic durumu: kapak gorunur, sembol gizli
	cover_panel.visible = true
	cover_panel.modulate.a = 1.0
	symbol_panel.visible = false
	symbol_panel.modulate.a = 0.0
	symbol_panel.scale = Vector2(0.5, 0.5)


func _gui_input(event: InputEvent) -> void:
	if is_scratched:
		return

	var should_scratch := false

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			should_scratch = true
	elif event is InputEventScreenTouch:
		if event.pressed:
			should_scratch = true

	if should_scratch:
		scratch()
		accept_event()


func scratch() -> void:
	if is_scratched:
		return
	is_scratched = true

	# Sembol panelini gorunur yap
	symbol_panel.visible = true
	symbol_panel.pivot_offset = symbol_panel.size / 2.0

	# Hizli Parmak charm: animasyon hizi artisi
	var speed_mult := 1.0 + GameState.get_charm_level("hizli_parmak") * 0.1
	var fade_dur := 0.2 / speed_mult
	var appear_dur := 0.3 / speed_mult

	# Kapak kaybolma animasyonu
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(cover_panel, "modulate:a", 0.0, fade_dur)
	tween.tween_property(symbol_panel, "modulate:a", 1.0, appear_dur)
	tween.tween_property(symbol_panel, "scale", Vector2.ONE, appear_dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.chain().tween_callback(func():
		cover_panel.visible = false
		area_scratched.emit(area_index)
	)
