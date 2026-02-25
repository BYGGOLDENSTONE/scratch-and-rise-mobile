extends CanvasLayer

## Sahne gecis animasyonu. Fade in/out.

var _overlay: ColorRect


func _ready() -> void:
	layer = 100
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.anchors_preset = Control.PRESET_FULL_RECT
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)
	print("[SceneTransition] Initialized")


## Fade ile sahne degistir
func change_scene(path: String, duration: float = 0.3) -> void:
	SoundManager.play("scene_swoosh")
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.tween_property(_overlay, "color:a", 1.0, duration)
	tw.tween_callback(func():
		get_tree().change_scene_to_file(path)
	)
	tw.tween_property(_overlay, "color:a", 0.0, duration)
	tw.tween_callback(func():
		_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)
