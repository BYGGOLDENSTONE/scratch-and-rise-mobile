extends PanelContainer

## Bilet kontrolcusu. ScratchArea ornekleri olusturur, tamamlanmayi takip eder.
## Tier'a gore neon renk/border uygulanir.

signal ticket_completed(symbols: Array)
signal celebration_finished

const ScratchAreaScene := preload("res://scenes/ticket/ScratchArea.tscn")
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")
const CollectionRef := preload("res://scripts/systems/collection_system.gd")

var ticket_type: String = "paper"
var symbols: Array = []
var scratched_count: int = 0
var total_areas: int = 0
var is_complete: bool = false
var _scratch_areas: Array = []
var _celebration_overlay: Node2D = null
var _celebration_container: VBoxContainer = null

@onready var ticket_header: Label = $VBox/TicketHeader
@onready var grid: GridContainer = $VBox/GridContainer
@onready var ticket_footer: Label = $VBox/TicketFooter
@onready var status_label: Label = $VBox/StatusLabel


func setup(type: String, symbol_override: String = "") -> void:
	ticket_type = type
	var config: Dictionary = TicketData.TICKET_CONFIGS.get(type, TicketData.TICKET_CONFIGS["paper"])

	# Tier'a gore bilet stilini uygula
	_apply_ticket_style(type)

	# Header
	ticket_header.text = "%s - %d Coin" % [config["name"], config["price"]]
	var tier_color: Color = ThemeHelper.get_tier_color(type)
	ticket_header.add_theme_color_override("font_color", tier_color)
	ticket_header.add_theme_font_size_override("font_size", 16)

	# Grid ayarlari
	var cols: int = config["columns"]
	grid.columns = cols
	total_areas = config["area_count"]
	scratched_count = 0
	is_complete = false
	_scratch_areas.clear()

	# Dinamik boyutlandirma: 5 sutun icin alanlari kucult
	var rows: int = ceili(float(total_areas) / float(cols))
	var area_w: int = 100 if cols <= 4 else 65
	var area_h: int = 80 if cols <= 4 else 60
	var ticket_w: int = cols * area_w + (cols - 1) * 6 + 24
	var ticket_h: int = rows * area_h + (rows - 1) * 6 + 80
	get_parent().custom_minimum_size = Vector2(0, 0)  # serbest birak
	custom_minimum_size = Vector2(ticket_w, ticket_h)

	# Semboller (override varsa tum alanlari ayni sembolle doldur)
	if symbol_override != "":
		symbols = []
		for i in total_areas:
			symbols.append(symbol_override)
	else:
		symbols = TicketData.get_random_symbols(type)

	# ScratchArea'lari olustur
	for i in total_areas:
		var area: Control = ScratchAreaScene.instantiate()
		area.custom_minimum_size = Vector2(area_w, area_h)
		grid.add_child(area)
		area.setup(i, symbols[i])
		area.area_scratched.connect(_on_area_scratched)
		_scratch_areas.append(area)

	# Footer & status
	ticket_footer.text = "Kazi ve eslesmeleri bul!"
	ThemeHelper.style_label(ticket_footer, ThemeHelper.p("text_secondary"), 13)
	status_label.visible = false

	print("[Ticket] %s olusturuldu, %d alan, %dx%d grid" % [config["name"], total_areas, cols, rows])


func _apply_ticket_style(type: String) -> void:
	var tier_color: Color = ThemeHelper.get_tier_color(type)
	var tier_bg: Color = ThemeHelper.get_tier_bg(type)

	var style := StyleBoxFlat.new()
	style.bg_color = tier_bg
	style.border_color = Color(tier_color.r, tier_color.g, tier_color.b, 0.6)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 12.0
	style.content_margin_top = 8.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 8.0
	add_theme_stylebox_override("panel", style)


func _on_area_scratched(_area_index: int) -> void:
	scratched_count += 1
	if scratched_count >= total_areas:
		_complete()


func _complete() -> void:
	if is_complete:
		return
	is_complete = true
	ticket_completed.emit(symbols)
	print("[Ticket] Tamamlandi! Semboller: ", symbols)


func get_ticket_type() -> String:
	return ticket_type


## --- Kutlama Animasyon Sistemi ---

## Kutlama animasyonunu baslat (main.gd'den cagirilir)
func play_celebration(match_data: Dictionary) -> void:
	ticket_footer.visible = false
	status_label.visible = false

	if match_data["has_match"]:
		_play_match_celebration(match_data)
	else:
		_play_no_match()


func _play_match_celebration(match_data: Dictionary) -> void:
	var best_symbol: String = match_data["best_symbol"]
	var sym_color: Color = TicketData.get_color(best_symbol)

	# Overlay olustur (combo popup + cizgiler icin)
	_celebration_overlay = Node2D.new()
	_celebration_overlay.z_index = 10
	add_child(_celebration_overlay)

	# Eslesmeyenleri hemen soluktur
	for area in _scratch_areas:
		if area.symbol_type != best_symbol:
			area.dim()

	# Eslesen alanlari topla
	var matched_areas := []
	for area in _scratch_areas:
		if area.symbol_type == best_symbol:
			matched_areas.append(area)

	# === FAZ 1: BAM BAM BAM! Tek tek patlat ===
	var combo := 0
	for area in matched_areas:
		combo += 1
		var intensity := 0.7 + combo * 0.3  # 1.0 → 1.3 → 1.6 → 1.9...

		# Sembol SLAM! (z_index arttir ki sonraki hep ustte olsun)
		area.z_index = combo
		area.play_slam_pop(intensity)

		# Escalating screen shake + vibration
		ScreenEffects.vibrate_heavy()
		ScreenEffects.screen_shake(3.0 + combo * 3.0, 0.12)

		# Combo popup: "x1" "x1" "x1!!" (carpan gosterimi)
		_show_combo_pop(combo, matched_areas.size(), area, match_data["multiplier"])

		# Sonraki pop icin bekle (son pop icin bekleme)
		if combo < matched_areas.size():
			await get_tree().create_timer(0.22).timeout
			if not is_inside_tree():
				return

	# 4+ eslesme: final slam!
	if matched_areas.size() >= 4:
		ScreenEffects.screen_shake(14.0, 0.35)
		ScreenEffects.flash_screen(sym_color, 0.3)

	# === FAZ 2: Odul gosterimi (kisa bekleme sonrasi) ===
	await get_tree().create_timer(0.5).timeout
	if not is_inside_tree():
		return
	_show_reward_on_ticket(match_data)


## Carpan popup: sembolun ustunde "x1" "x1" "x1!!" seklinde (kumar tarzi)
func _show_combo_pop(combo: int, total: int, area: Control, multiplier: int) -> void:
	var pop := Label.new()
	if combo == total:
		pop.text = "x%d!!" % multiplier
	else:
		pop.text = "x%d" % multiplier
	pop.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var font_size := 18 + combo * 5  # Giderek buyuyen: 23, 28, 33...
	pop.add_theme_font_size_override("font_size", font_size)
	pop.add_theme_color_override("font_color", Color.WHITE)
	pop.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	pop.add_theme_constant_override("shadow_offset_x", 2)
	pop.add_theme_constant_override("shadow_offset_y", 2)

	# Sembolun ustune konumlandir
	var center: Vector2 = area.global_position - global_position + area.size / 2.0
	pop.position = center - Vector2(15, 35)

	_celebration_overlay.add_child(pop)

	# Pop-up + yukari ucarak kaybol
	pop.scale = Vector2(0.2, 0.2)
	pop.pivot_offset = Vector2(15, 15)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(pop, "scale", Vector2(1.4, 1.4), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(pop, "position:y", pop.position.y - 30, 0.5).set_ease(Tween.EASE_OUT)
	tw.tween_property(pop, "modulate:a", 0.0, 0.3).set_delay(0.25)
	tw.chain().tween_callback(pop.queue_free)


func _play_no_match() -> void:
	for area in _scratch_areas:
		area.dim()

	status_label.text = "Eslesme yok..."
	ThemeHelper.style_label(status_label, ThemeHelper.p("text_secondary"), 16)
	status_label.visible = true

	await get_tree().create_timer(1.5).timeout
	if not is_inside_tree():
		return
	_cleanup_celebration()
	celebration_finished.emit()


func _show_reward_on_ticket(match_data: Dictionary) -> void:
	_celebration_container = VBoxContainer.new()
	_celebration_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_celebration_container.add_theme_constant_override("separation", 4)
	$VBox.add_child(_celebration_container)

	# Baslik (tier'a gore)
	var title_lbl := Label.new()
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var tier: String = match_data["tier"]
	match tier:
		"jackpot":
			title_lbl.text = "JACKPOT!"
			ThemeHelper.style_title(title_lbl, ThemeHelper.p("warning"), 26)
		"big":
			title_lbl.text = "BUYUK ESLESME!"
			ThemeHelper.style_title(title_lbl, ThemeHelper.p("success"), 22)
		_:
			title_lbl.text = "ESLESME!"
			ThemeHelper.style_title(title_lbl, ThemeHelper.p("primary"), 20)
	_celebration_container.add_child(title_lbl)

	# Detay
	var detail_lbl := Label.new()
	detail_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var symbol_name: String = TicketData.get_display_name(match_data["best_symbol"])
	var detail_text := "%s x%d = x%d carpan" % [symbol_name, match_data["best_count"], match_data["multiplier"]]

	var synergies: Array = match_data.get("synergies", [])
	var new_synergies: Array = match_data.get("new_synergies", [])
	if not synergies.is_empty():
		for syn in synergies:
			if syn["id"] in new_synergies:
				detail_text += "\nYENI SINERJI: %s! x%d" % [syn["name"], syn["multiplier"]]
			else:
				detail_text += "\nSINERJI: %s! x%d" % [syn["name"], syn["multiplier"]]
		if not new_synergies.is_empty():
			title_lbl.text = "SINERJI KESFEDILDI!"

	var drop: Dictionary = match_data.get("collection_drop", {})
	if not drop.is_empty():
		var piece_name: String = CollectionRef.get_piece_name(drop["set_id"], drop["piece_id"])
		var set_name: String = CollectionRef.get_set(drop["set_id"]).get("name", "")
		detail_text += "\nKoleksiyon: %s (%s)" % [piece_name, set_name]
		if match_data.get("set_completed", "") != "":
			detail_text += "\nSET TAMAMLANDI!"

	detail_lbl.text = detail_text
	ThemeHelper.style_label(detail_lbl, ThemeHelper.p("text_primary"), 12)
	_celebration_container.add_child(detail_lbl)

	# Odul
	var reward_lbl := Label.new()
	reward_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_lbl.text = "+%s Coin!" % GameState.format_number(match_data["reward"])
	_celebration_container.add_child(reward_lbl)

	# Odul buyume animasyonu (font size)
	reward_lbl.add_theme_font_size_override("font_size", 10)
	ThemeHelper.style_label(reward_lbl, ThemeHelper.p("success"), 10)
	var tw := create_tween()
	tw.tween_method(func(s: float):
		reward_lbl.add_theme_font_size_override("font_size", int(s))
	, 10.0, 22.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# DEVAM butonu
	var btn := Button.new()
	btn.text = "DEVAM"
	btn.custom_minimum_size = Vector2(0, 36)
	ThemeHelper.make_button(btn, ThemeHelper.p("success"), 16)
	btn.pressed.connect(func():
		_cleanup_celebration()
		celebration_finished.emit()
	)
	_celebration_container.add_child(btn)

	# Giris animasyonu
	_celebration_container.modulate.a = 0.0
	var tw2 := create_tween()
	tw2.tween_property(_celebration_container, "modulate:a", 1.0, 0.3)


func _cleanup_celebration() -> void:
	if _celebration_overlay:
		_celebration_overlay.queue_free()
		_celebration_overlay = null
	if _celebration_container:
		_celebration_container.queue_free()
		_celebration_container = null
	for area in _scratch_areas:
		area.reset_celebration()
