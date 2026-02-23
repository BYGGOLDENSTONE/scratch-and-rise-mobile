extends PanelContainer

## Bilet kontrolcusu. ScratchArea ornekleri olusturur, tamamlanmayi takip eder.

signal ticket_completed(symbols: Array)

const ScratchAreaScene := preload("res://scenes/ticket/ScratchArea.tscn")

var ticket_type: String = "paper"
var symbols: Array = []
var scratched_count: int = 0
var total_areas: int = 0
var is_complete: bool = false

@onready var ticket_header: Label = $VBox/TicketHeader
@onready var grid: GridContainer = $VBox/GridContainer
@onready var ticket_footer: Label = $VBox/TicketFooter
@onready var status_label: Label = $VBox/StatusLabel


func setup(type: String, symbol_override: String = "") -> void:
	ticket_type = type
	var config: Dictionary = TicketData.TICKET_CONFIGS.get(type, TicketData.TICKET_CONFIGS["paper"])

	# Header
	ticket_header.text = "%s - %d Coin" % [config["name"], config["price"]]

	# Grid ayarlari
	var cols: int = config["columns"]
	grid.columns = cols
	total_areas = config["area_count"]
	scratched_count = 0
	is_complete = false

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

	# Footer & status
	ticket_footer.text = "Kazi ve eslesmeleri bul!"
	status_label.visible = false

	print("[Ticket] %s olusturuldu, %d alan, %dx%d grid" % [config["name"], total_areas, cols, rows])


func _on_area_scratched(_area_index: int) -> void:
	scratched_count += 1
	if scratched_count >= total_areas:
		_complete()


func _complete() -> void:
	if is_complete:
		return
	is_complete = true
	status_label.text = "Tamamlandi!"
	status_label.visible = true
	ticket_footer.visible = false
	ticket_completed.emit(symbols)
	print("[Ticket] Tamamlandi! Semboller: ", symbols)


func get_ticket_type() -> String:
	return ticket_type
