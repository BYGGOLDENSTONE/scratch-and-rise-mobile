extends PanelContainer

## Basarim acilinca ekranin ustunde beliren gosterisli bildirim.
## Slide-in + bounce animasyonu, konfeti, ekran flash, rarity rengi.
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")
const AchievementRef := preload("res://scripts/systems/achievement_system.gd")

@onready var rarity_strip: ColorRect = $Margin/HBox/RarityStrip
@onready var name_label: Label = $Margin/HBox/Info/NameLabel
@onready var desc_label: Label = $Margin/HBox/Info/DescLabel
@onready var reward_label: Label = $Margin/HBox/RewardLabel


func _ready() -> void:
	modulate.a = 0.0


func show_achievement(ach_name: String, reward_cp: int, rarity: String = "common") -> void:
	var rarity_color: Color = AchievementRef.RARITY_COLORS.get(rarity, AchievementRef.RARITY_COLORS["common"])

	# --- Stiller ---
	var border_color := Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.7)
	ThemeHelper.make_panel(self, border_color, ThemeHelper.p("bg_panel"))
	ThemeHelper.style_label(name_label, ThemeHelper.p("text_primary"), 18)
	ThemeHelper.style_label(desc_label, rarity_color, 13)
	ThemeHelper.style_label(reward_label, ThemeHelper.p("warning"), 22)

	# --- Icerik ---
	name_label.text = ach_name
	desc_label.text = AchievementRef.RARITY_NAMES.get(rarity, "Yaygin") + " Basarim!"
	reward_label.text = "+%d CP" % reward_cp
	rarity_strip.color = rarity_color

	# --- Ekran efektleri ---
	if ScreenEffects:
		ScreenEffects.flash_screen(rarity_color, 0.35)
		ScreenEffects.play_mini_confetti(Vector2(360, 80))
		ScreenEffects.vibrate_light()
		# Epik+ basarimlar icin ekstra efektler
		if rarity == "epic" or rarity == "legendary":
			ScreenEffects.screen_shake(5.0, 0.2)
		if rarity == "legendary":
			ScreenEffects.play_confetti()
			ScreenEffects.edge_flash(rarity_color)

	# --- Slide-in animasyonu ---
	var start_top := -100.0
	var target_top := 20.0
	var height := 90.0
	offset_top = start_top
	offset_bottom = start_top + height
	modulate.a = 0.0

	# Scale bounce baslangiç
	pivot_offset = Vector2(210, 45) # Yaklasik merkez (420/2, 90/2)
	scale = Vector2(0.85, 0.85)

	var tw := create_tween()
	# Fase 1: Slide-in + fade-in + scale bounce (paralel)
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.2)
	tw.tween_property(self, "offset_top", target_top, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "offset_bottom", target_top + height, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.45).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

	# Fase 2: Shimmer pulse (rarity strip parlar)
	tw.chain().set_parallel(false)
	tw.tween_method(_pulse_strip.bind(rarity_color), 0.0, 1.0, 0.8)

	# Fase 3: Bekleme
	tw.tween_interval(2.5)

	# Fase 4: Slide-out + fade-out
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 0.0, 0.35)
	tw.tween_property(self, "offset_top", start_top, 0.35).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "offset_bottom", start_top + height, 0.35).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

	tw.chain().tween_callback(queue_free)

	# --- CP odul ucma efekti (bagimsiz tween) ---
	_spawn_cp_fly(reward_cp)


func _pulse_strip(t: float, base_color: Color) -> void:
	var pulse := sin(t * PI * 4.0) * 0.3 + 0.7
	rarity_strip.color = Color(
		base_color.r * pulse + (1.0 - pulse) * 1.0,
		base_color.g * pulse + (1.0 - pulse) * 1.0,
		base_color.b * pulse + (1.0 - pulse) * 1.0,
		1.0
	)


func _spawn_cp_fly(cp: int) -> void:
	var fly_label := Label.new()
	fly_label.text = "+%d CP" % cp
	fly_label.add_theme_font_size_override("font_size", 26)
	if ThemeHelper.is_dark():
		fly_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1))
		fly_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	else:
		fly_label.add_theme_color_override("font_color", Color(0.72, 0.55, 0.0))
		fly_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.3))
	fly_label.add_theme_constant_override("shadow_offset_x", 2)
	fly_label.add_theme_constant_override("shadow_offset_y", 2)
	fly_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fly_label.z_index = 110
	fly_label.modulate.a = 0.0
	add_child(fly_label)

	# Pozisyon: toast'un altinda, merkezde
	fly_label.position = Vector2(130, 85)

	var tw := create_tween()
	tw.set_parallel(true)
	# 0.5s sonra gozukmeye basla (slide-in bitince)
	tw.tween_property(fly_label, "modulate:a", 1.0, 0.2).set_delay(0.5)
	tw.tween_property(fly_label, "position:y", 45.0, 0.6).set_delay(0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(fly_label, "scale", Vector2(1.3, 1.3), 0.15).set_delay(0.5).set_ease(Tween.EASE_OUT)
	tw.tween_property(fly_label, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.65).set_ease(Tween.EASE_IN_OUT)
	# Fade out
	tw.tween_property(fly_label, "modulate:a", 0.0, 0.4).set_delay(1.8)
	tw.chain().tween_callback(fly_label.queue_free)
