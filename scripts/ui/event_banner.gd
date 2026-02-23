extends PanelContainer

## Olay duyuru banner'i. Ekranin ustunden kayarak girer, 2 saniye gosterir.

@onready var event_label: Label = $Margin/VBox/EventLabel
@onready var desc_label: Label = $Margin/VBox/DescLabel


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
