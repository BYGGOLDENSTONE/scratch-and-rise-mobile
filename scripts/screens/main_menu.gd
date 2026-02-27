extends Control

## Ana menü ekranı. Enerji göstergesi, yenilenme sayacı, OYNA butonu.
## Basliga 5 kez tikla -> Debug Panel

const DebugPanelScene := preload("res://scenes/debug/DebugPanel.tscn")
const SettingsPopupScene := preload("res://scenes/ui/SettingsPopup.tscn")
const DailyLoginPopupScene := preload("res://scenes/ui/DailyLoginPopup.tscn")
const DailyLoginRef := preload("res://scripts/systems/daily_login.gd")
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

@onready var energy_label: Label = %EnergyLabel
@onready var charm_label: Label = %CharmLabel
@onready var play_button: Button = %PlayButton
@onready var status_label: Label = %StatusLabel
@onready var title_label: Label = $VBox/Title
@onready var charm_btn: Button = $VBox/BottomButtons/CharmBtn
@onready var sinerji_btn: Button = $VBox/BottomButtons/SynerjiBtn
@onready var koleksiyon_btn: Button = $VBox/BottomButtons/KoleksiyonBtn
@onready var basarim_btn: Button = $VBox/BottomButtons/BasarimBtn
@onready var gorevler_btn: Button = $VBox/BottomButtons/GorevlerBtn
@onready var ayarlar_btn: Button = $VBox/BottomButtons/AyarlarBtn

var _debug_tap_count: int = 0
var _debug_last_tap_time: float = 0.0
var _debug_panel: Control = null
var _settings_popup: PanelContainer = null
var _login_popup: PanelContainer = null


func _ready() -> void:
	SaveManager.load_game()
	GameState.energy_changed.connect(_on_energy_changed)
	title_label.mouse_filter = Control.MOUSE_FILTER_STOP
	title_label.gui_input.connect(_on_title_input)
	charm_btn.pressed.connect(_on_charm_pressed)
	sinerji_btn.pressed.connect(_on_sinerji_pressed)
	koleksiyon_btn.pressed.connect(_on_koleksiyon_pressed)
	basarim_btn.pressed.connect(_on_basarim_pressed)
	gorevler_btn.pressed.connect(_on_gorevler_pressed)
	GameState.theme_changed.connect(func(_t): _apply_theme())
	GameState.locale_changed.connect(func(_l): _update_texts())
	_apply_theme()
	_update_texts()
	_update_ui()
	_check_daily_login()
	print("[MainMenu] Ready — Energy: ", GameState.energy)


func _apply_theme() -> void:
	$Background.color = ThemeHelper.p("bg_main")
	ThemeHelper.style_title(title_label, ThemeHelper.p("warning"), 38)
	var subtitle: Label = $VBox/Subtitle
	ThemeHelper.style_label(subtitle, ThemeHelper.p("text_secondary"), 20)
	ThemeHelper.style_label(energy_label, ThemeHelper.p("success"), 22)
	ThemeHelper.style_label(charm_label, ThemeHelper.p("info"), 22)
	ThemeHelper.style_label(status_label, ThemeHelper.p("text_muted"), 15)
	ThemeHelper.make_button(play_button, ThemeHelper.p("warning"), 30)
	ThemeHelper.make_button(charm_btn, ThemeHelper.p("info"), 15)
	ThemeHelper.make_button(sinerji_btn, ThemeHelper.p("secondary"), 15)
	ThemeHelper.make_button(koleksiyon_btn, ThemeHelper.p("success"), 15)
	ThemeHelper.make_button(basarim_btn, ThemeHelper.p("warning"), 15)
	ThemeHelper.make_button(gorevler_btn, ThemeHelper.p("secondary"), 15)
	ThemeHelper.make_button(ayarlar_btn, ThemeHelper.p("text_secondary"), 15)


func _on_title_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var now := Time.get_ticks_msec() / 1000.0
		if now - _debug_last_tap_time > 2.0:
			_debug_tap_count = 0
		_debug_last_tap_time = now
		_debug_tap_count += 1
		if _debug_tap_count >= 5:
			_debug_tap_count = 0
			_open_debug_panel()


func _open_debug_panel() -> void:
	if _debug_panel != null:
		return
	_debug_panel = DebugPanelScene.instantiate()
	add_child(_debug_panel)
	_debug_panel.panel_closed.connect(_on_debug_closed)


func _on_debug_closed() -> void:
	_debug_panel = null
	_update_ui()


func _process(_delta: float) -> void:
	# Enerji tam degilse geri sayim goster
	if GameState.energy < GameState.get_max_energy():
		var remaining: float = GameState.ENERGY_REGEN_SECONDS - GameState._energy_regen_accumulator
		var mins: int = int(remaining) / 60
		var secs: int = int(remaining) % 60
		status_label.text = tr("ENERJI_TIMER_FMT") % [mins, secs]
		status_label.visible = true
	else:
		status_label.visible = false


func _update_ui() -> void:
	energy_label.text = tr("ENERJI_BEKLE_FMT") % [GameState.energy, GameState.get_max_energy()]
	charm_label.text = tr("GEM_FMT") % GameState.format_number(GameState.gems)
	play_button.disabled = GameState.energy <= 0


func _update_texts() -> void:
	title_label.text = tr("SCRATCH_AND_RISE")
	var subtitle: Label = $VBox/Subtitle
	subtitle.text = tr("KAZI_KAZAN_YUKSEL")
	play_button.text = tr("OYNA")
	charm_btn.text = tr("CHARM_BTN")
	sinerji_btn.text = tr("SINERJI_BTN")
	koleksiyon_btn.text = tr("KOLEKSIYON_BTN")
	basarim_btn.text = tr("BASARIM_BTN")
	gorevler_btn.text = tr("GOREVLER_BTN")
	ayarlar_btn.text = tr("AYARLAR")
	_update_ui()


func _on_energy_changed(_new_amount: int) -> void:
	_update_ui()


func _on_play_pressed() -> void:
	SoundManager.play("ui_tap")
	if GameState.start_round():
		SceneTransition.change_scene("res://scenes/main/Main.tscn")


func _on_charm_pressed() -> void:
	SoundManager.play("ui_tap")
	SceneTransition.change_scene("res://scenes/screens/CharmScreen.tscn")


func _on_sinerji_pressed() -> void:
	SoundManager.play("ui_tap")
	SceneTransition.change_scene("res://scenes/screens/SynergyAlbum.tscn")


func _on_koleksiyon_pressed() -> void:
	SoundManager.play("ui_tap")
	SceneTransition.change_scene("res://scenes/screens/CollectionScreen.tscn")


func _on_basarim_pressed() -> void:
	SoundManager.play("ui_tap")
	SceneTransition.change_scene("res://scenes/screens/AchievementScreen.tscn")


func _on_gorevler_pressed() -> void:
	SoundManager.play("ui_tap")
	SceneTransition.change_scene("res://scenes/screens/DailyQuestScreen.tscn")


func _on_ayarlar_pressed() -> void:
	if _settings_popup != null:
		return
	SoundManager.play("popup_open")
	_settings_popup = SettingsPopupScene.instantiate()
	add_child(_settings_popup)
	_settings_popup.popup_closed.connect(func(): _settings_popup = null)


func _check_daily_login() -> void:
	var reward_day: int = DailyLoginRef.check_login()
	if reward_day > 0:
		_show_daily_login_popup(reward_day)


func _show_daily_login_popup(reward_day: int) -> void:
	if _login_popup != null:
		return
	SoundManager.play("popup_open")
	_login_popup = DailyLoginPopupScene.instantiate()
	_login_popup.setup(reward_day)
	add_child(_login_popup)
	_login_popup.popup_closed.connect(func():
		_login_popup = null
		_update_ui()
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
		get_viewport().set_input_as_handled()
