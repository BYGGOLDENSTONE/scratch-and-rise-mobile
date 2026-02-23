extends PanelContainer

## Bilet kontrolcusu. ScratchArea ornekleri olusturur, tamamlanmayi takip eder.
## Tier'a gore neon renk/border uygulanir.

signal ticket_completed(symbols: Array)

const ScratchAreaScene := preload("res://scenes/ticket/ScratchArea.tscn")
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

var ticket_type: String = "paper"
var symbols: Array = []
var scratched_count: int = 0
var total_areas: int = 0
var is_complete: bool = false
var _scratch_areas: Array = []

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
	status_label.text = "Tamamlandi!"
	ThemeHelper.style_label(status_label, ThemeHelper.p("success"), 14)
	status_label.visible = true
	ticket_footer.visible = false

	# Eslesen sembolleri bul ve pulse animasyonu oynat
	_highlight_matches()

	ticket_completed.emit(symbols)
	print("[Ticket] Tamamlandi! Semboller: ", symbols)


func _highlight_matches() -> void:
	# Sembol sayimlarini bul
	var counts := {}
	for s in symbols:
		counts[s] = counts.get(s, 0) + 1

	# 3+ eslesenleri bul
	var matching_symbols := []
	for s in counts:
		if counts[s] >= 3:
			matching_symbols.append(s)

	# Eslesen alanlarda glow animasyonu
	for area in _scratch_areas:
		if area.symbol_type in matching_symbols:
			area.play_match_glow()


func get_ticket_type() -> String:
	return ticket_type
