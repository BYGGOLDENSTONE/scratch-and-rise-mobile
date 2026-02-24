extends CanvasLayer

## Ekran efektleri: shake, flash, konfeti, coin ucma.
## Autoload olarak kullanilir.

var _flash_rect: ColorRect
var _coin_fly_container: Control
var _confetti_particles: GPUParticles2D
var _mini_confetti: GPUParticles2D
var _shake_tween: Tween

# Pool for scratch particles
var _scratch_particles_pool: Array[GPUParticles2D] = []

var _edge_left: ColorRect
var _edge_right: ColorRect

func _ready() -> void:
	layer = 90
	_setup_flash()
	_setup_coin_fly_container()
	_setup_confetti()
	_setup_mini_confetti()
	_setup_scratch_particles()
	_setup_edge_lights()
	print("[ScreenEffects] Initialized")

## --- HAPTICS / VIBRATION ---
func vibrate_light() -> void:
	Input.vibrate_handheld(20) # 20ms quick buzz for scratching/minor taps

func vibrate_heavy() -> void:
	Input.vibrate_handheld(60) # 60ms solid vibration for matches/wins



## --- FLASH ---
func _setup_flash() -> void:
	_flash_rect = ColorRect.new()
	_flash_rect.color = Color(1, 1, 1, 0)
	_flash_rect.anchors_preset = Control.PRESET_FULL_RECT
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash_rect)


func flash_screen(color: Color = Color.WHITE, duration: float = 0.3) -> void:
	_flash_rect.color = Color(color.r, color.g, color.b, 0.35)
	var tw := create_tween()
	tw.tween_property(_flash_rect, "color:a", 0.0, duration).set_ease(Tween.EASE_OUT)


## --- SCREEN SHAKE ---
func screen_shake(intensity: float = 8.0, duration: float = 0.20) -> void:
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
		node.set(property, original)
		
	_shake_tween = create_tween()
	var steps := int(duration / 0.02) # Faster shake cycles
	for i in steps:
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		_shake_tween.tween_property(node, property, original + offset, 0.02)
		intensity *= 0.85 # Decay the shake quickly
	_shake_tween.tween_property(node, property, original, 0.02)


## --- SCREEN PUNCH (yonlu itme) ---
func screen_punch(direction: Vector2, intensity: float = 8.0, duration: float = 0.15) -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var camera := viewport.get_camera_2d()
	var node: Node = null
	var property: String
	var original: Vector2

	if camera:
		node = camera
		property = "offset"
		original = Vector2.ZERO
	else:
		var root := get_tree().current_scene
		if root:
			node = root
			property = "position"
			original = root.position

	if node == null:
		return

	var punch_offset := direction.normalized() * intensity

	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
		node.set(property, original)

	_shake_tween = create_tween()
	# Hizli ileri itme
	_shake_tween.tween_property(node, property, original + punch_offset, duration * 0.25).set_ease(Tween.EASE_OUT)
	# Geri sekmeli overshoot
	_shake_tween.tween_property(node, property, original - punch_offset * 0.35, duration * 0.4).set_ease(Tween.EASE_IN_OUT)
	# Orijinal pozisyona yerles
	_shake_tween.tween_property(node, property, original, duration * 0.35).set_ease(Tween.EASE_IN)


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
	_confetti_particles.lifetime = 1.3
	_confetti_particles.position = Vector2(360, 200)
	_confetti_particles.z_index = 100

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 75.0
	mat.initial_velocity_min = 200.0
	mat.initial_velocity_max = 450.0
	mat.gravity = Vector3(0, 350, 0)
	mat.angular_velocity_min = -120.0
	mat.angular_velocity_max = 120.0
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


## --- MINI KONFETI ---
func _setup_mini_confetti() -> void:
	_mini_confetti = GPUParticles2D.new()
	_mini_confetti.emitting = false
	_mini_confetti.one_shot = true
	_mini_confetti.amount = 25
	_mini_confetti.lifetime = 0.8
	_mini_confetti.z_index = 100

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 45.0
	mat.initial_velocity_min = 120.0
	mat.initial_velocity_max = 300.0
	mat.gravity = Vector3(0, 400, 0)
	mat.angular_velocity_min = -180.0
	mat.angular_velocity_max = 180.0
	mat.scale_min = 2.0
	mat.scale_max = 4.0

	var color_ramp := GradientTexture1D.new()
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.3, 0.3))
	gradient.add_point(0.25, Color(1.0, 0.85, 0.1))
	gradient.add_point(0.5, Color(0.3, 1.0, 0.5))
	gradient.add_point(0.75, Color(0.3, 0.5, 1.0))
	gradient.set_color(1, Color(1.0, 0.3, 1.0))
	color_ramp.gradient = gradient
	mat.color_initial_ramp = color_ramp

	_mini_confetti.process_material = mat
	add_child(_mini_confetti)


func play_mini_confetti(pos: Vector2 = Vector2(360, 400)) -> void:
	_mini_confetti.position = pos
	_mini_confetti.restart()
	_mini_confetti.emitting = true


## --- SCRATCH PARTICLES ---
func _setup_scratch_particles() -> void:
	for i in range(5): # Create a small pool of 5 emitters
		var p := GPUParticles2D.new()
		p.emitting = false
		p.one_shot = true
		p.amount = 20
		p.lifetime = 0.5
		p.explosiveness = 0.9
		p.z_index = 80
		
		var mat := ParticleProcessMaterial.new()
		mat.direction = Vector3(0, -1, 0)
		mat.spread = 120.0
		mat.initial_velocity_min = 120.0
		mat.initial_velocity_max = 300.0
		mat.gravity = Vector3(0, 500, 0)
		mat.scale_min = 2.0
		mat.scale_max = 5.0
		mat.color = Color(0.88, 0.80, 0.60, 0.85) # Soft metalik altin
		
		var alpha_ramp := GradientTexture1D.new()
		var gradient := Gradient.new()
		gradient.set_color(0, Color(1.0, 0.95, 0.8, 1))
		gradient.set_color(1, Color(0.9, 0.8, 0.5, 0))
		alpha_ramp.gradient = gradient
		mat.color_ramp = alpha_ramp
		
		p.process_material = mat
		add_child(p)
		_scratch_particles_pool.append(p)

func play_scratch_particles(pos: Vector2) -> void:
	for p in _scratch_particles_pool:
		if not p.emitting:
			p.position = pos
			p.restart()
			p.emitting = true
			return

## --- JACKPOT EFEKTI ---
func jackpot_effect() -> void:
	vibrate_heavy()
	flash_screen(Color(0.95, 0.82, 0.2), 0.45)
	screen_shake(12.0, 0.35)
	play_confetti()
	edge_flash(Color(0.95, 0.82, 0.2))
	# Ikinci mini konfeti dalgasi
	get_tree().create_timer(0.4).timeout.connect(func():
		play_mini_confetti(Vector2(360, 500))
	)


## --- BUYUK KAZANC EFEKTI ---
func big_win_effect() -> void:
	vibrate_heavy()
	flash_screen(Color(0.25, 0.85, 0.45), 0.3)
	screen_shake(7.0, 0.25)
	play_mini_confetti(Vector2(360, 450))


## --- YOLO EFEKTI (x50) ---
func yolo_effect() -> void:
	vibrate_heavy()
	flash_screen(Color(0.95, 0.25, 0.25), 0.5)
	screen_shake(15.0, 0.4)
	play_confetti()
	edge_flash(Color(0.95, 0.25, 0.25))
	
	var yolo_label := Label.new()
	yolo_label.text = "YOLO x50!"
	yolo_label.add_theme_font_size_override("font_size", 64)
	yolo_label.add_theme_color_override("font_color", Color(0.95, 0.25, 0.25))
	# Add a shadow for better visibility
	yolo_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	yolo_label.add_theme_constant_override("shadow_offset_x", 3)
	yolo_label.add_theme_constant_override("shadow_offset_y", 3)
	
	yolo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	yolo_label.anchors_preset = Control.PRESET_CENTER
	yolo_label.z_index = 100
	_coin_fly_container.add_child(yolo_label)
	# Center pivot properly
	yolo_label.position -= yolo_label.get_minimum_size() / 2.0
	yolo_label.pivot_offset = yolo_label.get_minimum_size() / 2.0
	yolo_label.scale = Vector2(0.2, 0.2)

	var tw := create_tween()
	tw.tween_property(yolo_label, "scale", Vector2(1.5, 1.5), 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_interval(0.8)
	tw.tween_property(yolo_label, "modulate:a", 0.0, 0.4)
	tw.tween_property(yolo_label, "scale", Vector2(2.0, 2.0), 0.4).set_ease(Tween.EASE_IN).set_delay(-0.4)
	tw.tween_callback(yolo_label.queue_free)


## --- SINERJI EFEKTI ---
func synergy_effect() -> void:
	vibrate_heavy()
	flash_screen(Color(0.55, 0.30, 0.85), 0.30)
	screen_shake(6.0, 0.20)


## --- KENAR ISIGI ---
func _setup_edge_lights() -> void:
	_edge_left = ColorRect.new()
	_edge_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_edge_left.color = Color(1, 1, 1, 0)
	_edge_left.anchor_top = 0.0
	_edge_left.anchor_bottom = 1.0
	_edge_left.anchor_left = 0.0
	_edge_left.anchor_right = 0.0
	_edge_left.offset_right = 24.0
	add_child(_edge_left)

	_edge_right = ColorRect.new()
	_edge_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_edge_right.color = Color(1, 1, 1, 0)
	_edge_right.anchor_top = 0.0
	_edge_right.anchor_bottom = 1.0
	_edge_right.anchor_left = 1.0
	_edge_right.anchor_right = 1.0
	_edge_right.offset_left = -24.0
	add_child(_edge_right)


func edge_flash(color: Color) -> void:
	var c := Color(color.r, color.g, color.b, 0.40)
	_edge_left.color = c
	_edge_right.color = c
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_edge_left, "color:a", 0.0, 0.65).set_ease(Tween.EASE_OUT)
	tw.tween_property(_edge_right, "color:a", 0.0, 0.65).set_ease(Tween.EASE_OUT)

