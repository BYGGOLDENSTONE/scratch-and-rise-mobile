extends PanelContainer

## Altin bilet popup'u. 5 saniyelik geri sayim + YAKALA butonu.
## Dokunursa: ucretsiz bilet hakki. Zaman dolarsa: kaybolur.
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

signal golden_ticket_caught()
signal golden_ticket_missed()

@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var timer_label: Label = $Margin/VBox/TimerLabel
@onready var catch_btn: Button = $Margin/VBox/CatchBtn

var _time_remaining: float = 5.0
var _active: bool = true


func _ready() -> void:
	catch_btn.pressed.connect(_on_catch)
	_apply_theme()
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.3)


func _apply_theme() -> void:
	ThemeHelper.make_neon_panel(self, ThemeHelper.NEON_GOLD, ThemeHelper.BG_PANEL)
	ThemeHelper.style_title_label(title_label, ThemeHelper.NEON_GOLD, 22)
	ThemeHelper.style_label(timer_label, ThemeHelper.NEON_RED, 16)
	ThemeHelper.make_neon_button(catch_btn, ThemeHelper.NEON_GOLD, 18)


func _process(delta: float) -> void:
	if not _active:
		return
	_time_remaining -= delta
	if _time_remaining <= 0:
		_active = false
		golden_ticket_missed.emit()
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 0.3)
		tw.tween_callback(queue_free)
		return
	timer_label.text = "%.1f saniye" % _time_remaining


func _on_catch() -> void:
	if not _active:
		return
	_active = false
	golden_ticket_caught.emit()
	title_label.text = "YAKALADIN!"
	timer_label.text = "Sonraki bilet ucretsiz!"
	catch_btn.visible = false
	var tw := create_tween()
	tw.tween_interval(1.5)
	tw.tween_property(self, "modulate:a", 0.0, 0.3)
	tw.tween_callback(queue_free)
