extends PanelContainer

## Basarim acilinca ekranin ustunde beliren bildirim.
## 3 saniye gosterir, fade ile kaybolur.
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

@onready var name_label: Label = $Margin/VBox/NameLabel
@onready var reward_label: Label = $Margin/VBox/RewardLabel


func _ready() -> void:
	_apply_theme()


func _apply_theme() -> void:
	ThemeHelper.make_panel(self, ThemeHelper.p("success"), ThemeHelper.p("bg_panel"))
	ThemeHelper.style_label(name_label, ThemeHelper.p("success"), 15)
	ThemeHelper.style_label(reward_label, ThemeHelper.p("warning"), 13)


func show_achievement(ach_name: String, reward_cp: int) -> void:
	name_label.text = "BASARIM: %s" % ach_name
	reward_label.text = "+%d CP" % reward_cp
	modulate.a = 0.0
	# Fade in
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.3)
	tw.tween_interval(3.0)
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	tw.tween_callback(queue_free)
