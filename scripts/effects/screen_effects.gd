extends CanvasLayer

## Ekran efektleri: shake, flash, konfeti, coin ucma.
## Autoload olarak kullanilir.

var _flash_rect: ColorRect
var _coin_fly_container: Control
var _confetti_particles: GPUParticles2D
var _shake_tween: Tween


func _ready() -> void:
	layer = 90
	_setup_flash()
	_setup_coin_fly_container()
	_setup_confetti()
	print("[ScreenEffects] Initialized")


## --- FLASH ---
func _setup_flash() -> void:
	_flash_rect = ColorRect.new()
	_flash_rect.color = Color(1, 1, 1, 0)
	_flash_rect.anchors_preset = Control.PRESET_FULL_RECT
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash_rect)


func flash_screen(color: Color = Color.WHITE, duration: float = 0.3) -> void:
	_flash_rect.color = Color(color.r, color.g, color.b, 0.7)
	var tw := create_tween()
	tw.tween_property(_flash_rect, "color:a", 0.0, duration).set_ease(Tween.EASE_OUT)


## --- SCREEN SHAKE ---
func screen_shake(intensity: float = 8.0, duration: float = 0.3) -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var camera := viewport.get_camera_2d()
	# Kamera yoksa root node'u salla
	if camera:
		_shake_node(camera, "offset", Vector2.ZERO, intensity, duration)
	else:
		var root := get_tree().current_scene
		if root:
			_shake_node(root, "position", root.position, intensity, duration)


func _shake_node(node: Node, property: String, original: Vector2, intensity: float, duration: float) -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	_shake_tween = create_tween()
	var steps := int(duration / 0.03)
	for i in steps:
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		_shake_tween.tween_property(node, property, original + offset, 0.03)
	_shake_tween.tween_property(node, property, original, 0.03)


## --- COIN UCMA ---
func _setup_coin_fly_container() -> void:
	_coin_fly_container = Control.new()
	_coin_fly_container.anchors_preset = Control.PRESET_FULL_RECT
	_coin_fly_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_coin_fly_container)


func coin_fly(amount: int, from_pos: Vector2) -> void:
	var label := Label.new()
	label.text = "+%s" % GameState.format_number(amount)
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = from_pos - Vector2(40, 20)
	label.z_index = 100
	_coin_fly_container.add_child(label)

	# Yukari ucarak kaybolma
	var tw := create_tween().set_parallel(true)
	tw.tween_property(label, "position:y", label.position.y - 120, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(label, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_IN).set_delay(0.3)
	tw.tween_property(label, "scale", Vector2(1.3, 1.3), 0.15).set_ease(Tween.EASE_OUT)
	tw.chain().tween_callback(label.queue_free)


## --- KONFETI ---
func _setup_confetti() -> void:
	_confetti_particles = GPUParticles2D.new()
	_confetti_particles.emitting = false
	_confetti_particles.one_shot = true
	_confetti_particles.amount = 60
	_confetti_particles.lifetime = 1.5
	_confetti_particles.position = Vector2(360, 200)
	_confetti_particles.z_index = 100

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 60.0
	mat.initial_velocity_min = 200.0
	mat.initial_velocity_max = 500.0
	mat.gravity = Vector3(0, 400, 0)
	mat.angular_velocity_min = -180.0
	mat.angular_velocity_max = 180.0
	mat.scale_min = 3.0
	mat.scale_max = 6.0
	mat.color = Color(1, 0.85, 0.1)
	# Renk rastgelesi
	var color_ramp := GradientTexture1D.new()
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.3, 0.3))
	gradient.add_point(0.25, Color(1.0, 0.85, 0.1))
	gradient.add_point(0.5, Color(0.3, 1.0, 0.5))
	gradient.add_point(0.75, Color(0.3, 0.5, 1.0))
	gradient.set_color(1, Color(1.0, 0.3, 1.0))
	color_ramp.gradient = gradient
	mat.color_initial_ramp = color_ramp

	_confetti_particles.process_material = mat
	add_child(_confetti_particles)


func play_confetti() -> void:
	_confetti_particles.restart()
	_confetti_particles.emitting = true


## --- JACKPOT EFEKTI (flash + shake + konfeti) ---
func jackpot_effect() -> void:
	flash_screen(Color(1, 0.85, 0.1), 0.5)
	screen_shake(12.0, 0.4)
	play_confetti()


## --- BUYUK KAZANC EFEKTI (shake + flash) ---
func big_win_effect() -> void:
	flash_screen(Color(0.3, 1.0, 0.5), 0.3)
	screen_shake(6.0, 0.25)


## --- YOLO EFEKTI (x50) ---
func yolo_effect() -> void:
	flash_screen(Color(1.0, 0.1, 0.1), 0.6)
	screen_shake(16.0, 0.5)
	play_confetti()
	# Ekstra: YOLO yazisi
	var yolo_label := Label.new()
	yolo_label.text = "YOLO x50!"
	yolo_label.add_theme_font_size_override("font_size", 48)
	yolo_label.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1))
	yolo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	yolo_label.anchors_preset = Control.PRESET_CENTER
	yolo_label.z_index = 100
	_coin_fly_container.add_child(yolo_label)
	yolo_label.pivot_offset = yolo_label.size / 2
	yolo_label.scale = Vector2(0.3, 0.3)

	var tw := create_tween()
	tw.tween_property(yolo_label, "scale", Vector2(1.5, 1.5), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_interval(0.8)
	tw.tween_property(yolo_label, "modulate:a", 0.0, 0.4)
	tw.tween_callback(yolo_label.queue_free)


## --- SINERJI EFEKTI ---
func synergy_effect() -> void:
	flash_screen(Color(0.5, 0.3, 1.0), 0.3)
	screen_shake(5.0, 0.2)
