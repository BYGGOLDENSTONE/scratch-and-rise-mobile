extends PanelContainer

## Ayarlar popup'u — tema degistirme, save sifirlama.
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

signal popup_closed

@onready var close_btn: Button = %CloseBtn
@onready var reset_btn: Button = %ResetBtn
@onready var theme_btn: Button = %ThemeToggleBtn

var _confirm_reset: bool = false


func _ready() -> void:
	close_btn.pressed.connect(_on_close)
	reset_btn.pressed.connect(_on_reset)
	theme_btn.pressed.connect(_on_theme_toggle)
	_apply_theme()
	_update_theme_btn_text()
	# Giris animasyonu
	var panel: PanelContainer = $CenterBox/Panel
	panel.pivot_offset = panel.size / 2
	panel.scale = Vector2(0.8, 0.8)
	panel.modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(panel, "modulate:a", 1.0, 0.2)


func _apply_theme() -> void:
	var panel: PanelContainer = $CenterBox/Panel
	ThemeHelper.make_panel(panel, ThemeHelper.p("info"), ThemeHelper.p("bg_panel"))
	var title: Label = $CenterBox/Panel/VBox/Title
	ThemeHelper.style_title(title, ThemeHelper.p("info"), 24)
	ThemeHelper.make_button(close_btn, ThemeHelper.p("success"), 18)
	ThemeHelper.make_button(reset_btn, ThemeHelper.p("danger"), 14)
	ThemeHelper.make_button(theme_btn, ThemeHelper.p("primary"), 16)
	$BG.color = Color(0, 0, 0, 0.7)


func _update_theme_btn_text() -> void:
	if GameState.user_theme == 0:
		theme_btn.text = "Tema: Karanlik"
	else:
		theme_btn.text = "Tema: Aydinlik"


func _on_theme_toggle() -> void:
	var new_theme := 1 if GameState.user_theme == 0 else 0
	GameState.set_user_theme(new_theme)
	_apply_theme()
	_update_theme_btn_text()


func _on_close() -> void:
	popup_closed.emit()
	queue_free()


func _on_reset() -> void:
	if not _confirm_reset:
		_confirm_reset = true
		reset_btn.text = "Emin misin? Tekrar bas"
		# 3 saniye sonra geri al
		var tw := create_tween()
		tw.tween_interval(3.0)
		tw.tween_callback(func():
			_confirm_reset = false
			if is_instance_valid(reset_btn):
				reset_btn.text = "Save Sifirla"
		)
	else:
		# Save sifirla
		var dir := DirAccess.open("user://")
		if dir:
			if dir.file_exists("save_main.json"):
				dir.remove("save_main.json")
			if dir.file_exists("save_backup.json"):
				dir.remove("save_backup.json")
		# GameState sifirla
		GameState.charm_points = 0
		GameState.charms = {}
		GameState.energy = GameState.BASE_MAX_ENERGY
		GameState.total_coins_earned = 0
		GameState.total_rounds_played = 0
		GameState.best_round_coins = 0
		GameState.collected_pieces = {}
		GameState.discovered_synergies = []
		GameState.stats = {
			"total_tickets": 0,
			"total_matches": 0,
			"total_jackpots": 0,
			"total_synergies_found": 0,
			"best_streak": 0,
		}
		GameState.unlocked_achievements = []
		print("[Settings] Save sifirlandi!")
		popup_closed.emit()
		queue_free()
		SceneTransition.change_scene("res://scenes/screens/MainMenu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close()
		get_viewport().set_input_as_handled()
