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
	# Rastgele pozisyon: biletin ustu/alti, panellerin arasi
	_randomize_position()
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.3)


func _randomize_position() -> void:
	# Bilet alani: ~160px (top bar) ile ~(viewport - 300px) (bottom panel) arasi
	var vp_size := get_viewport_rect().size
	var top_zone_min := 170.0  # Top bar altindaki alan
	var top_zone_max := 280.0  # Bilet baslamadan once
	var bottom_zone_min := vp_size.y - 360.0  # Bilet bittikten sonra
	var bottom_zone_max := vp_size.y - 310.0  # Bottom panel baslamadan once
	# Rastgele ust veya alt bolge sec
	var target_y: float
	if randf() < 0.5:
		target_y = randf_range(top_zone_min, top_zone_max)
	else:
		target_y = randf_range(bottom_zone_min, bottom_zone_max)
	# Yatay: hafif rastgele kayma
	var target_x: float = randf_range(vp_size.x * 0.1, vp_size.x * 0.9 - size.x)
	# Anchor'lari sifirla ve mutlak pozisyon kullan
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 0.0
	anchor_bottom = 0.0
	position = Vector2(target_x, target_y)


func _apply_theme() -> void:
	ThemeHelper.make_panel(self, ThemeHelper.p("warning"), ThemeHelper.p("bg_panel"))
	ThemeHelper.style_title(title_label, ThemeHelper.p("warning"), 22)
	ThemeHelper.style_label(timer_label, ThemeHelper.p("danger"), 16)
	ThemeHelper.make_button(catch_btn, ThemeHelper.p("warning"), 18)


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
	timer_label.text = "Bu bilet bedava!"
	catch_btn.visible = false
	var tw := create_tween()
	tw.tween_interval(1.5)
	tw.tween_property(self, "modulate:a", 0.0, 0.3)
	tw.tween_callback(queue_free)
