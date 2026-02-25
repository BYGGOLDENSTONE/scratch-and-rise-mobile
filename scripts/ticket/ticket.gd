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
var _drag_active: bool = false
var has_started_scratching: bool = false
var _celebration_dismissed: bool = false
var input_blocked: bool = false  # Popup acikken input engelle

@onready var ticket_header: Label = $VBox/TicketHeader
@onready var grid: GridContainer = $VBox/GridContainer
@onready var ticket_footer: Label = $VBox/TicketFooter
@onready var status_label: Label = $VBox/StatusLabel


func setup(type: String, symbol_override: String = "") -> void:
	ticket_type = type
	var config: Dictionary = TicketData.TICKET_CONFIGS.get(type, TicketData.TICKET_CONFIGS["paper"])

	# Tier'a gore bilet stilini uygula
	_apply_ticket_style(type)

	# Header — light modda koyulastirilmis tier rengi
	ticket_header.text = "%s - %d Coin" % [config["name"], config["price"]]
	var tier_color: Color = ThemeHelper.get_tier_color(type)
	if not ThemeHelper.is_dark():
		tier_color = Color(tier_color.r * 0.55, tier_color.g * 0.55, tier_color.b * 0.55)
	ticket_header.add_theme_color_override("font_color", tier_color)
	ticket_header.add_theme_font_size_override("font_size", 16)

	# Grid ayarlari
	var cols: int = config["columns"]
	grid.columns = cols
	total_areas = config["area_count"]
	scratched_count = 0
	is_complete = false
	_scratch_areas.clear()

	# Dinamik boyutlandirma: viewport oranli
	var rows: int = ceili(float(total_areas) / float(cols))
	var vp_size := get_viewport_rect().size
	var avail_w: int = int(vp_size.x) - 40  # 20px margin her iki taraf
	var avail_h: int = int(vp_size.y * 0.42)  # Ekranin %42'si bilete (ust/alt paneller buyuk)
	var area_w: int = clampi((avail_w - (cols - 1) * 6 - 24) / cols, 65, 200)
	var area_h: int = clampi((avail_h - (rows - 1) * 6 - 80) / rows, 60, 160)
	var ticket_w: int = cols * area_w + (cols - 1) * 6 + 24
	var ticket_h: int = rows * area_h + (rows - 1) * 6 + 80
	get_parent().custom_minimum_size = Vector2(0, 0)  # serbest birak
	custom_minimum_size = Vector2(ticket_w, ticket_h)

	# Buyuk bilette header fontunu artir
	if area_w >= 120:
		ticket_header.add_theme_font_size_override("font_size", 18)

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
	var border_alpha := 0.6 if ThemeHelper.is_dark() else 0.75
	var bc: Color = tier_color if ThemeHelper.is_dark() else Color(tier_color.r * 0.6, tier_color.g * 0.6, tier_color.b * 0.6)
	style.border_color = Color(bc.r, bc.g, bc.b, border_alpha)
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


## --- Surukleyerek Kazima ---

func _input(event: InputEvent) -> void:
	if input_blocked:
		return
	# Kutlama gorunurken dokunma → hemen gecis (hizli oyuncu icin)
	if is_complete and not _celebration_dismissed and _celebration_container != null:
		var is_touch := false
		if event is InputEventMouseButton and event.pressed:
			is_touch = true
		elif event is InputEventScreenTouch and event.pressed:
			is_touch = true
		if is_touch:
			_dismiss_celebration()
			return
	if is_complete:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_drag_active = true
				_try_scratch_at(event.global_position)
			else:
				_drag_active = false
	elif event is InputEventMouseMotion:
		if _drag_active:
			_try_scratch_at(event.global_position)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_drag_active = true
			_try_scratch_at(event.position)
		else:
			_drag_active = false
	elif event is InputEventScreenDrag:
		if _drag_active:
			_try_scratch_at(event.position)


func _try_scratch_at(global_pos: Vector2) -> void:
	for area in _scratch_areas:
		if area.is_scratched:
			continue
		if area.get_global_rect().has_point(global_pos):
			area.scratch()


func _on_area_scratched(_area_index: int) -> void:
	scratched_count += 1
	if not has_started_scratching:
		has_started_scratching = true
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
	_celebration_dismissed = false
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

	# Eslesen alanlari topla (joker + bomba dahil)
	var matched_areas := []
	for area in _scratch_areas:
		if area.symbol_type == best_symbol or area.symbol_type == "joker" or (area.symbol_type == "bomb" and match_data.get("has_bomb", false)):
			matched_areas.append(area)

	# Eslesmeyenleri hemen soluktur
	for area in _scratch_areas:
		if area not in matched_areas:
			area.dim()

	# === FAZ 1: BAM BAM BAM! Tek tek patlat ===
	# Once normal semboller, sonra ozel semboller (joker/bomba sonda parlak giris)
	var normal_areas := []
	var special_areas := []
	for area in matched_areas:
		if area.symbol_type == "joker" or area.symbol_type == "bomb":
			special_areas.append(area)
		else:
			normal_areas.append(area)
	var ordered_areas: Array = normal_areas + special_areas

	var punch_dirs := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	var combo := 0
	for area in ordered_areas:
		combo += 1
		var intensity := 0.7 + combo * 0.3

		area.z_index = combo
		var is_special: bool = area.symbol_type == "joker" or area.symbol_type == "bomb"
		if is_special:
			area.play_special_slam_pop(intensity)
		else:
			area.play_slam_pop(intensity)

		ScreenEffects.vibrate_heavy()
		var punch_dir: Vector2 = punch_dirs[(combo - 1) % punch_dirs.size()]
		ScreenEffects.screen_punch(punch_dir, 2.0 + combo * 1.5, 0.12)

		# Popup: normal semboller "x1", joker → "JOKER!", bomba → "BOMBA +1!"
		if area.symbol_type == "joker":
			var jcolor: Color = TicketData.get_color("joker")
			if not ThemeHelper.is_dark():
				jcolor = Color(jcolor.r * 0.65, jcolor.g * 0.65, jcolor.b * 0.65)
			_show_special_pop(area, "JOKER!", jcolor)
		elif area.symbol_type == "bomb":
			var bcolor: Color = TicketData.get_color("bomb")
			if not ThemeHelper.is_dark():
				bcolor = Color(bcolor.r * 0.65, bcolor.g * 0.65, bcolor.b * 0.65)
			_show_special_pop(area, "BOMBA +1!", bcolor)
		else:
			_show_combo_pop(combo, ordered_areas.size(), area, match_data["multiplier"])

		if combo < ordered_areas.size():
			await get_tree().create_timer(0.22).timeout
			if not is_inside_tree():
				return

	# 4+ eslesme: soft final slam + mini konfeti
	if matched_areas.size() >= 4:
		ScreenEffects.screen_shake(9.0, 0.28)
		ScreenEffects.flash_screen(sym_color, 0.3)
		var ticket_center := global_position + size / 2.0
		ScreenEffects.play_mini_confetti(ticket_center)

	# === FAZ 2: Odul gosterimi (kisa bekleme sonrasi) ===
	await get_tree().create_timer(0.5).timeout
	if not is_inside_tree():
		return
	_show_reward_on_ticket(match_data)


## Ozel sembol popup: "JOKER!" veya "BOMBA +1!" sembolun ustunde renkli gosterim
func _show_special_pop(area: Control, text: String, color: Color) -> void:
	var pop := Label.new()
	pop.text = text
	pop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pop.add_theme_font_size_override("font_size", 20)
	pop.add_theme_color_override("font_color", color)
	if ThemeHelper.is_dark():
		pop.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	else:
		pop.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	pop.add_theme_constant_override("shadow_offset_x", 2)
	pop.add_theme_constant_override("shadow_offset_y", 2)

	var center: Vector2 = area.global_position - global_position + area.size / 2.0
	pop.position = center - Vector2(25, 35)
	_celebration_overlay.add_child(pop)

	pop.scale = Vector2(0.2, 0.2)
	pop.pivot_offset = Vector2(25, 15)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(pop, "scale", Vector2(1.5, 1.5), 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(pop, "position:y", pop.position.y - 35, 0.5).set_ease(Tween.EASE_OUT)
	tw.tween_property(pop, "modulate:a", 0.0, 0.3).set_delay(0.3)
	tw.chain().tween_callback(pop.queue_free)


## Carpan popup: sembolun ustunde "x1" "x1" "x1!!" seklinde (kumar tarzi)
func _show_combo_pop(combo: int, total: int, area: Control, multiplier: int) -> void:
	var pop := Label.new()
	if combo == total:
		pop.text = "x%d!!" % multiplier
	else:
		pop.text = "x%d" % multiplier
	pop.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var font_size := 16 + combo * 4  # Soft artis: 20, 24, 28...
	pop.add_theme_font_size_override("font_size", font_size)
	if ThemeHelper.is_dark():
		pop.add_theme_color_override("font_color", Color.WHITE)
		pop.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	else:
		# Light modda koyu metin + daha belirgin golge
		pop.add_theme_color_override("font_color", Color(0.15, 0.15, 0.2))
		pop.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
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

	# Giris animasyonu
	_celebration_container.modulate.a = 0.0
	var tw2 := create_tween()
	tw2.tween_property(_celebration_container, "modulate:a", 1.0, 0.3)

	# Otomatik gecis timer (tier'a gore bekleme suresi)
	var wait_time: float
	match tier:
		"jackpot": wait_time = 2.5
		"big": wait_time = 2.0
		_: wait_time = 1.5
	get_tree().create_timer(wait_time).timeout.connect(_dismiss_celebration)


func _dismiss_celebration() -> void:
	if _celebration_dismissed:
		return
	_celebration_dismissed = true
	_cleanup_celebration()
	celebration_finished.emit()


func _cleanup_celebration() -> void:
	if _celebration_overlay:
		_celebration_overlay.queue_free()
		_celebration_overlay = null
	if _celebration_container:
		_celebration_container.queue_free()
		_celebration_container = null
	for area in _scratch_areas:
		area.reset_celebration()
