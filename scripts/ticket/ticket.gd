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


func setup(type: String) -> void:
	ticket_type = type
	var config: Dictionary = TicketData.TICKET_CONFIGS.get(type, TicketData.TICKET_CONFIGS["paper"])

	# Header
	ticket_header.text = "%s - %d Coin" % [config["name"], config["price"]]

	# Grid ayarlari
	grid.columns = config["columns"]
	total_areas = config["area_count"]
	scratched_count = 0
	is_complete = false

	# Semboller
	symbols = TicketData.get_random_symbols(type)

	# ScratchArea'lari olustur
	for i in total_areas:
		var area: Control = ScratchAreaScene.instantiate()
		grid.add_child(area)
		area.setup(i, symbols[i])
		area.area_scratched.connect(_on_area_scratched)

	# Footer & status
	ticket_footer.text = "Kazi ve eslesmeleri bul!"
	status_label.visible = false

	print("[Ticket] %s olusturuldu, %d alan" % [config["name"], total_areas])


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
