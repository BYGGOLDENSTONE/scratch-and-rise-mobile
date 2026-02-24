extends Control

## Tek kazima alani. Dokunmayla kapak acilir, sembol belirir.
## Metalik shader kapak + dissolve efekti.

const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

signal area_scratched(area_index: int)

var area_index: int = -1
var symbol_type: String = ""
var is_scratched: bool = false

@onready var cover_panel: Panel = $CoverPanel
@onready var cover_label: Label = $CoverPanel/CoverLabel
@onready var symbol_panel: Panel = $SymbolPanel
@onready var symbol_label: Label = $SymbolPanel/SymbolLabel

var _cover_shader_mat: ShaderMaterial


func setup(idx: int, symbol: String) -> void:
	area_index = idx
	symbol_type = symbol
	is_scratched = false

	# Sembol bilgilerini ayarla
	symbol_label.text = TicketData.get_display_name(symbol)
	var color: Color = TicketData.get_color(symbol)

	# Sembol panelini renklendir
	var style := StyleBoxFlat.new()
	if ThemeHelper.is_dark():
		style.bg_color = Color(color.r * 0.20, color.g * 0.20, color.b * 0.20, 0.9)
	else:
		style.bg_color = Color(color.r * 0.08 + 0.90, color.g * 0.08 + 0.90, color.b * 0.08 + 0.90, 1.0)
	style.border_color = Color(color.r, color.g, color.b, ThemeHelper.pf("border_alpha") + 0.15)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	symbol_panel.add_theme_stylebox_override("panel", style)

	# Sembol label stili: parlak, kalin
	symbol_label.add_theme_color_override("font_color", color)
	symbol_label.add_theme_font_size_override("font_size", 16)

	# Metalik kapak shader
	_setup_cover_shader()

	# Kapak label gizle (shader metal goruntu veriyor)
	cover_label.text = ""

	# Baslangic durumu: kapak gorunur, sembol gizli
	cover_panel.visible = true
	cover_panel.modulate.a = 1.0
	symbol_panel.visible = false
	symbol_panel.modulate.a = 0.0
	symbol_panel.scale = Vector2(0.5, 0.5)


func _setup_cover_shader() -> void:
	var shader := load("res://assets/shaders/scratch_cover.gdshader") as Shader
	if shader == null:
		return
	_cover_shader_mat = ShaderMaterial.new()
	_cover_shader_mat.shader = shader
	_cover_shader_mat.set_shader_parameter("reveal", 0.0)
	_cover_shader_mat.set_shader_parameter("base_color", Color(0.50, 0.50, 0.55, 1.0))
	_cover_shader_mat.set_shader_parameter("shine_color", Color(0.72, 0.72, 0.78, 1.0))
	_cover_shader_mat.set_shader_parameter("edge_glow_color", ThemeHelper.p("success"))
	cover_panel.material = _cover_shader_mat


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

	# Particles & Haptics for Juice
	ScreenEffects.vibrate_light()
	ScreenEffects.play_scratch_particles(global_position + (size / 2.0))

	# Hizli Parmak charm: animasyon hizi artisi
	var speed_mult := 1.0 + GameState.get_charm_level("hizli_parmak") * 0.1
	var fade_dur := 0.3 / speed_mult
	var appear_dur := 0.35 / speed_mult

	var tween := create_tween()
	tween.set_parallel(true)

	# Shader dissolve animasyonu (varsa)
	if _cover_shader_mat:
		tween.tween_method(_set_cover_reveal, 0.0, 1.0, fade_dur).set_ease(Tween.EASE_IN)
	else:
		tween.tween_property(cover_panel, "modulate:a", 0.0, fade_dur)

	# Sembol belirme
	tween.tween_property(symbol_panel, "modulate:a", 1.0, appear_dur)
	tween.tween_property(symbol_panel, "scale", Vector2.ONE, appear_dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.chain().tween_callback(func():
		cover_panel.visible = false
		area_scratched.emit(area_index)
	)


func _set_cover_reveal(value: float) -> void:
	if _cover_shader_mat:
		_cover_shader_mat.set_shader_parameter("reveal", value)


## Eslesen sembol pulse animasyonu (bilet tamamlaninca cagrilir)
func play_match_glow() -> void:
	if not is_scratched:
		return
	ScreenEffects.vibrate_heavy()
	
	symbol_panel.pivot_offset = symbol_panel.size / 2.0
	var tw := create_tween()
	tw.set_loops(2)
	# Daha abartili bir patlama hissi (scale 1.15 -> 1.25, rotasyon)
	tw.tween_property(symbol_panel, "scale", Vector2(1.25, 1.25), 0.15).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(symbol_panel, "rotation_degrees", 5.0, 0.15).set_ease(Tween.EASE_OUT)
	
	tw.tween_property(symbol_panel, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(symbol_panel, "rotation_degrees", 0.0, 0.15).set_ease(Tween.EASE_IN)


## Dopamin slam: sembol BAM! diye patlar
## intensity arttikca efekt sertlesir (combo escalation)
func play_slam_pop(intensity: float = 1.0) -> void:
	if not is_scratched:
		return

	symbol_panel.pivot_offset = symbol_panel.size / 2.0
	var color: Color = TicketData.get_color(symbol_type)

	# Isikli border + artan shadow glow
	var style: StyleBoxFlat = symbol_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		style.border_color = Color(color.r, color.g, color.b, 0.95)
		style.set_border_width_all(3)
		style.shadow_color = Color(color.r, color.g, color.b, 0.6)
		style.shadow_size = int(6 + intensity * 4)
		symbol_panel.add_theme_stylebox_override("panel", style)

	# Label flash: anlik beyaz, sonra sembol rengine don
	symbol_label.add_theme_color_override("font_color", Color.WHITE)

	# SLAM! Hizli buyutme + rotation punch
	var slam_scale := 1.5 + (intensity - 1.0) * 0.15
	var final_scale := 1.08 + (intensity - 1.0) * 0.04  # Kucuk kal, yan yana overlap olmasin
	var rot := randf_range(-10.0, 10.0) * intensity

	var tw := create_tween()
	tw.tween_property(symbol_panel, "scale", Vector2(slam_scale, slam_scale), 0.06).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(symbol_panel, "rotation_degrees", rot, 0.06)
	tw.tween_property(symbol_panel, "scale", Vector2(final_scale, final_scale), 0.14).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tw.parallel().tween_property(symbol_panel, "rotation_degrees", 0.0, 0.14)
	tw.tween_callback(func(): symbol_label.add_theme_color_override("font_color", color))


## Eslesmeyenleri soluktur (%30 alpha)
func dim() -> void:
	if not is_scratched:
		return
	var tw := create_tween()
	tw.tween_property(symbol_panel, "modulate:a", 0.3, 0.3)


## Kutlama sonrasi normal haline dondur
func reset_celebration() -> void:
	symbol_panel.pivot_offset = symbol_panel.size / 2.0
	symbol_panel.scale = Vector2.ONE
	symbol_panel.modulate.a = 1.0
	symbol_panel.rotation_degrees = 0.0
