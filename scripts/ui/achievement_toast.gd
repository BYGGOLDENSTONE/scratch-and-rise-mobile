extends PanelContainer

## Basarim acilinca ekranin ustunde beliren bildirim.
## 3 saniye gosterir, fade ile kaybolur.

@onready var name_label: Label = $Margin/VBox/NameLabel
@onready var reward_label: Label = $Margin/VBox/RewardLabel


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
