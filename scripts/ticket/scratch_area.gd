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
var _glow_rect: ColorRect = null
var _glow_shader_mat: ShaderMaterial = null
var _glow_pulse_tween: Tween = null


func setup(idx: int, symbol: String) -> void:
	area_index = idx
	symbol_type = symbol
	is_scratched = false

	# Sembol bilgilerini ayarla
	symbol_label.text = TicketData.get_display_name(symbol)
	var color: Color = TicketData.get_color(symbol)

	# Sembol panelini renklendir — belirgin ve okunur
	var style := StyleBoxFlat.new()
	if ThemeHelper.is_dark():
		style.bg_color = Color(color.r * 0.18 + 0.05, color.g * 0.18 + 0.05, color.b * 0.18 + 0.05, 0.92)
	else:
		# Light modda daha doygun tint — sembol kartlari belirgin ayrisir
		style.bg_color = Color(color.r * 0.15 + 0.82, color.g * 0.15 + 0.82, color.b * 0.15 + 0.82, 1.0)
	style.border_color = Color(color.r, color.g, color.b, ThemeHelper.pf("border_alpha") + 0.22)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	symbol_panel.add_theme_stylebox_override("panel", style)

	# Sembol label stili: parlak, kalin (alan boyutuna oranli)
	# Light modda koyulastirilmis font rengi (parlak renkler acik bg'de okunamaz)
	var font_color: Color = color if ThemeHelper.is_dark() else Color(color.r * 0.5, color.g * 0.5, color.b * 0.5)
	symbol_label.add_theme_color_override("font_color", font_color)
	var font_sz: int = clampi(int(min(custom_minimum_size.x, custom_minimum_size.y) * 0.18), 14, 32)
	symbol_label.add_theme_font_size_override("font_size", font_sz)

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

	# Radial glow (slam pop icin)
	_create_glow_node()


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


func _create_glow_node() -> void:
	if _glow_rect:
		_glow_rect.queue_free()
	_glow_rect = ColorRect.new()
	_glow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow_rect.visible = false

	# Alan boyutunun 2.5 kati (genis, yaygın hale)
	var glow_size := size * 2.5
	_glow_rect.size = glow_size
	_glow_rect.position = (size - glow_size) / 2.0

	# Radial gradient shader (genis merkez + yumusak kenar)
	var shader := Shader.new()
	shader.code = """shader_type canvas_item;
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 0.8);
void fragment() {
	float dist = distance(UV, vec2(0.5));
	float alpha = smoothstep(0.5, 0.05, dist) * glow_color.a;
	COLOR = vec4(glow_color.rgb, alpha);
}
"""
	_glow_shader_mat = ShaderMaterial.new()
	_glow_shader_mat.shader = shader
	_glow_rect.material = _glow_shader_mat

	add_child(_glow_rect)
	move_child(_glow_rect, 0)


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

	# Soft border + hafif shadow glow
	var style: StyleBoxFlat = symbol_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		if ThemeHelper.is_dark():
			style.border_color = Color(color.r, color.g, color.b, 0.80)
			style.shadow_color = Color(color.r, color.g, color.b, 0.35)
			style.shadow_size = int(5 + intensity * 3)
		else:
			# Light modda koyulastirilmis border + guclu golge
			style.border_color = Color(color.r * 0.7, color.g * 0.7, color.b * 0.7, 0.90)
			style.shadow_color = Color(color.r * 0.5, color.g * 0.5, color.b * 0.5, 0.50)
			style.shadow_size = int(6 + intensity * 4)
		style.set_border_width_all(2)
		symbol_panel.add_theme_stylebox_override("panel", style)

	# Label flash: anlik beyaz, sonra sembol rengine don
	symbol_label.add_theme_color_override("font_color", Color.WHITE)

	# Radial glow patlamasi + kalici nefes alan isik
	if _glow_rect and _glow_shader_mat:
		_glow_rect.visible = true
		var glow_col: Color
		var persist_alpha: float
		if ThemeHelper.is_dark():
			_glow_rect.modulate.a = 0.55
			glow_col = Color(color.r, color.g, color.b, 0.4)
			persist_alpha = 0.20
		else:
			_glow_rect.modulate.a = 0.65
			glow_col = Color(color.r * 0.6, color.g * 0.6, color.b * 0.6, 0.5)
			persist_alpha = 0.28
		_glow_shader_mat.set_shader_parameter("glow_color", glow_col)
		_glow_rect.scale = Vector2(0.3, 0.3)
		_glow_rect.pivot_offset = _glow_rect.size / 2.0
		var glow_tw := create_tween()
		var glow_target_scale := 1.0 + intensity * 0.25
		glow_tw.tween_property(_glow_rect, "scale", Vector2(glow_target_scale, glow_target_scale), 0.2).set_ease(Tween.EASE_OUT)
		glow_tw.tween_property(_glow_rect, "modulate:a", persist_alpha, 0.35).set_delay(0.1)
		glow_tw.tween_callback(_start_persistent_glow.bind(persist_alpha))

	# Soft slam: hafif buyutme + minimal rotasyon
	var slam_scale := 1.30 + (intensity - 1.0) * 0.10
	var final_scale := 1.05 + (intensity - 1.0) * 0.03
	var rot := randf_range(-6.0, 6.0) * intensity

	var tw := create_tween()
	tw.tween_property(symbol_panel, "scale", Vector2(slam_scale, slam_scale), 0.06).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(symbol_panel, "rotation_degrees", rot, 0.06)
	tw.tween_property(symbol_panel, "scale", Vector2(final_scale, final_scale), 0.14).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tw.parallel().tween_property(symbol_panel, "rotation_degrees", 0.0, 0.14)
	var _slam_font_color: Color = color if ThemeHelper.is_dark() else Color(color.r * 0.5, color.g * 0.5, color.b * 0.5)
	tw.tween_callback(func(): symbol_label.add_theme_color_override("font_color", _slam_font_color))


## Ozel sembol slam: joker/bomba icin farkli glow + pulse border
func play_special_slam_pop(intensity: float = 1.0) -> void:
	if not is_scratched:
		return

	symbol_panel.pivot_offset = symbol_panel.size / 2.0
	var color: Color = TicketData.get_color(symbol_type)

	# Parlak kesikli border (ozel sembol oldugunu belli et)
	var style: StyleBoxFlat = symbol_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		if ThemeHelper.is_dark():
			style.border_color = Color(color.r, color.g, color.b, 0.95)
			style.shadow_color = Color(color.r, color.g, color.b, 0.6)
			style.shadow_size = int(8 + intensity * 4)
		else:
			# Light modda koyulastirilmis ozel border + guclu golge
			style.border_color = Color(color.r * 0.65, color.g * 0.65, color.b * 0.65, 0.95)
			style.shadow_color = Color(color.r * 0.4, color.g * 0.4, color.b * 0.4, 0.65)
			style.shadow_size = int(10 + intensity * 5)
		style.set_border_width_all(3)
		symbol_panel.add_theme_stylebox_override("panel", style)

	symbol_label.add_theme_color_override("font_color", Color.WHITE)

	# Radial glow — ozel sembol kalici parlama
	if _glow_rect and _glow_shader_mat:
		_glow_rect.visible = true
		var persist_alpha: float
		if ThemeHelper.is_dark():
			_glow_rect.modulate.a = 0.65
			_glow_shader_mat.set_shader_parameter("glow_color", Color(color.r, color.g, color.b, 0.50))
			persist_alpha = 0.28
		else:
			_glow_rect.modulate.a = 0.75
			_glow_shader_mat.set_shader_parameter("glow_color", Color(color.r * 0.6, color.g * 0.6, color.b * 0.6, 0.55))
			persist_alpha = 0.35
		_glow_rect.scale = Vector2(0.3, 0.3)
		_glow_rect.pivot_offset = _glow_rect.size / 2.0
		var glow_tw := create_tween()
		var glow_target := 1.3 + intensity * 0.25
		glow_tw.tween_property(_glow_rect, "scale", Vector2(glow_target, glow_target), 0.2).set_ease(Tween.EASE_OUT)
		glow_tw.tween_property(_glow_rect, "modulate:a", persist_alpha, 0.4).set_delay(0.15)
		glow_tw.tween_callback(_start_persistent_glow.bind(persist_alpha))

	# Farkli animasyon: hizli double-bounce (ozel hissettir)
	var slam_scale := 1.4 + (intensity - 1.0) * 0.12
	var tw := create_tween()
	tw.tween_property(symbol_panel, "scale", Vector2(slam_scale, slam_scale), 0.05).set_ease(Tween.EASE_OUT)
	tw.tween_property(symbol_panel, "scale", Vector2(0.9, 0.9), 0.06)
	tw.tween_property(symbol_panel, "scale", Vector2(1.15, 1.15), 0.08).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	var _special_font_color: Color = color if ThemeHelper.is_dark() else Color(color.r * 0.5, color.g * 0.5, color.b * 0.5)
	tw.tween_callback(func(): symbol_label.add_theme_color_override("font_color", _special_font_color))


## Kalici nefes alan glow animasyonu (kutlama boyunca devam eder)
func _start_persistent_glow(base_alpha: float) -> void:
	if _glow_pulse_tween and _glow_pulse_tween.is_valid():
		_glow_pulse_tween.kill()
	_glow_pulse_tween = create_tween().set_loops()
	_glow_pulse_tween.tween_property(_glow_rect, "modulate:a", base_alpha * 1.3, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_glow_pulse_tween.tween_property(_glow_rect, "modulate:a", base_alpha * 0.7, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


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
	if _glow_pulse_tween and _glow_pulse_tween.is_valid():
		_glow_pulse_tween.kill()
		_glow_pulse_tween = null
	if _glow_rect:
		_glow_rect.visible = false
		_glow_rect.modulate.a = 1.0
