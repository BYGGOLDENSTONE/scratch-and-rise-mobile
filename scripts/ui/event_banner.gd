extends PanelContainer

## Olay duyuru banner'i. Ekranin ustunden kayarak girer, 2 saniye gosterir.
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

@onready var event_label: Label = $Margin/VBox/EventLabel
@onready var desc_label: Label = $Margin/VBox/DescLabel


func _ready() -> void:
	_apply_theme()


func _apply_theme() -> void:
	ThemeHelper.make_neon_panel(self, ThemeHelper.NEON_GOLD, ThemeHelper.BG_PANEL)
	ThemeHelper.style_label(event_label, ThemeHelper.NEON_GOLD, 18)
	ThemeHelper.style_label(desc_label, ThemeHelper.TEXT_WHITE, 13)


func show_event(event_name: String, description: String) -> void:
	event_label.text = event_name
	desc_label.text = description
	# Yukari kaydir (ekran disi)
	position.y = -100
	modulate.a = 1.0
	var tw := create_tween()
	tw.tween_property(self, "position:y", 20.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_interval(2.0)
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	tw.tween_callback(queue_free)
