extends Node

## Test Harness — Dosya-bazli otomasyon protokolu.
## _test_command.json okur, komutu calistirir, _test_state.json yazar.
## Release build'de devre disi.

const POLL_INTERVAL := 0.5

var _project_dir := ""
var _cmd_path := ""
var _state_path := ""
var _screenshot_path := ""
var _poll_timer := 0.0
var _enabled := false
var _busy := false
var _waiting := false
var _wait_remaining := 0.0
var _pending_id := ""


func _ready() -> void:
	if OS.has_feature("release"):
		print("[TestHarness] Release build — devre disi")
		set_process(false)
		return
	_project_dir = ProjectSettings.globalize_path("res://")
	_cmd_path = _project_dir.path_join("_test_command.json")
	_state_path = _project_dir.path_join("_test_state.json")
	_screenshot_path = _project_dir.path_join("_test_screenshot.png")
	_enabled = true
	print("[TestHarness] Baslatildi — %s" % _cmd_path)


func _process(delta: float) -> void:
	if not _enabled or _busy:
		return
	if _waiting:
		_wait_remaining -= delta
		if _wait_remaining <= 0.0:
			_waiting = false
			_write_state({"waited": true})
		return
	_poll_timer += delta
	if _poll_timer < POLL_INTERVAL:
		return
	_poll_timer = 0.0
	_check_command()


func _check_command() -> void:
	if not FileAccess.file_exists(_cmd_path):
		return
	var f := FileAccess.open(_cmd_path, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	DirAccess.remove_absolute(_cmd_path)

	var json := JSON.new()
	if json.parse(text) != OK:
		push_warning("[TestHarness] JSON parse hatasi: %s" % json.get_error_message())
		return
	var cmd: Dictionary = json.data
	if not cmd.has("command"):
		push_warning("[TestHarness] 'command' alani eksik")
		return
	_pending_id = str(cmd.get("id", ""))
	_busy = true
	print("[TestHarness] > %s (id:%s)" % [cmd["command"], _pending_id])
	_run_command(cmd)


func _run_command(cmd: Dictionary) -> void:
	var result := {}
	match cmd["command"]:
		"state":
			result = {"ok": true}
		"click":
			var pos := Vector2(cmd.get("x", 0), cmd.get("y", 0))
			await _sim_click(pos)
			result = {"clicked": [pos.x, pos.y]}
		"drag":
			var from := Vector2(cmd.get("from_x", 0), cmd.get("from_y", 0))
			var to := Vector2(cmd.get("to_x", 0), cmd.get("to_y", 0))
			var steps: int = cmd.get("steps", 10)
			await _sim_drag(from, to, steps)
			result = {"dragged": true, "from": [from.x, from.y], "to": [to.x, to.y]}
		"click_button":
			result = await _cmd_click_button(cmd)
		"scratch_all":
			result = await _cmd_scratch_all(cmd)
		"screenshot":
			result = await _cmd_screenshot()
		"wait":
			_waiting = true
			_wait_remaining = float(cmd.get("seconds", 1.0))
			_busy = false
			return
		"change_scene":
			result = await _cmd_change_scene(cmd)
		"set_theme":
			result = _cmd_set_theme(cmd)
		"set_coins":
			var amount: int = cmd.get("amount", 100)
			GameState.coins = amount
			GameState.coins_changed.emit(amount)
			result = {"coins": GameState.coins}
		"set_energy":
			var amount: int = cmd.get("amount", 5)
			GameState.energy = amount
			GameState.energy_changed.emit(amount)
			result = {"energy": GameState.energy}
		"list_buttons":
			result = _cmd_list_buttons()
		_:
			result = {"error": "Bilinmeyen komut: %s" % cmd["command"]}
	_write_state(result)
	_busy = false


# ────────────────────────────────────────────
# Komut Implementasyonlari
# ────────────────────────────────────────────

func _cmd_click_button(cmd: Dictionary) -> Dictionary:
	var btn_name: String = cmd.get("name", "")
	var btn_text: String = cmd.get("text", "")
	var btn := _find_button(btn_name, btn_text)
	if btn == null:
		return {"error": "Buton bulunamadi", "name": btn_name, "text": btn_text}
	if not btn.is_visible_in_tree():
		return {"error": "Buton gorunur degil", "name": str(btn.name)}
	if btn.disabled:
		return {"error": "Buton devre disi", "name": str(btn.name)}
	var btn_name_str := str(btn.name)
	# Dogrudan pressed sinyali gonder — en guvenilir yontem
	btn.emit_signal("pressed")
	print("[TestHarness] Buton pressed: %s" % btn_name_str)
	# SceneTransition fade suresi (0.3s fade out + 0.3s fade in + marj)
	await get_tree().create_timer(0.8).timeout
	return {"clicked_button": btn_name_str}


func _cmd_scratch_all(cmd: Dictionary) -> Dictionary:
	var delay: float = cmd.get("delay", 0.15)
	var main_node = _get_main_node()
	if main_node == null:
		return {"error": "Oyun ekraninda degil"}
	var ticket = main_node.current_ticket
	if ticket == null:
		return {"error": "Aktif bilet yok"}
	var areas: Array = ticket._scratch_areas
	if areas.is_empty():
		return {"error": "Kazima alani yok"}
	var count := 0
	for area in areas:
		if area.is_scratched:
			continue
		area.scratch()
		count += 1
		if delay > 0:
			await get_tree().create_timer(delay).timeout
	# Animasyonlar + ticket_completed sinyali icin bekle
	await get_tree().create_timer(1.0).timeout
	return {"scratched": count, "total": areas.size()}


func _cmd_screenshot() -> Dictionary:
	# Birden fazla frame bekle — animasyonlar tamamlansin
	for i in 4:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	if img == null:
		return {"error": "Viewport yakalanamadi"}
	img.save_png(_screenshot_path)
	return {"saved": _screenshot_path}


func _cmd_change_scene(cmd: Dictionary) -> Dictionary:
	var scene_path: String = cmd.get("path", "")
	# Kisa isimlerle sahne gecisi
	var aliases := {
		"main_menu": "res://scenes/screens/MainMenu.tscn",
		"menu": "res://scenes/screens/MainMenu.tscn",
		"game": "res://scenes/main/Main.tscn",
		"charm": "res://scenes/screens/CharmScreen.tscn",
		"synergy": "res://scenes/screens/SynergyAlbum.tscn",
		"collection": "res://scenes/screens/CollectionScreen.tscn",
		"achievement": "res://scenes/screens/AchievementScreen.tscn",
	}
	if scene_path in aliases:
		scene_path = aliases[scene_path]
	if scene_path == "":
		return {"error": "path gerekli", "aliases": aliases.keys()}
	if not ResourceLoader.exists(scene_path):
		return {"error": "Sahne bulunamadi: %s" % scene_path, "aliases": aliases.keys()}
	# game sahnesine gecerken round baslat
	if scene_path == "res://scenes/main/Main.tscn" and not GameState.in_round:
		GameState.start_round()
	get_tree().change_scene_to_file(scene_path)
	print("[TestHarness] Sahne degistirildi: %s" % scene_path)
	# Sahne yuklenene kadar bekle
	await get_tree().create_timer(0.5).timeout
	return {"changed_to": scene_path}


func _cmd_set_theme(cmd: Dictionary) -> Dictionary:
	var theme_id: int = cmd.get("theme", 0)  # 0=dark, 1=light
	GameState.set_user_theme(theme_id)
	var name := "dark" if theme_id == 0 else "light"
	print("[TestHarness] Tema degistirildi: %s" % name)
	return {"theme": name}


func _cmd_list_buttons() -> Dictionary:
	var buttons := []
	_collect_buttons(get_tree().root, buttons)
	return {"buttons": buttons}


func _collect_buttons(node: Node, out: Array) -> void:
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return
	if node is Button:
		var b := node as Button
		out.append({
			"name": str(b.name),
			"text": b.text,
			"disabled": b.disabled,
			"visible": b.is_visible_in_tree(),
			"rect": _r2a(b.get_global_rect()),
		})
	elif node is BaseButton:
		var bb := node as BaseButton
		out.append({
			"name": str(bb.name),
			"disabled": bb.disabled,
			"visible": bb.is_visible_in_tree(),
			"rect": _r2a(bb.get_global_rect()),
		})
	for child in node.get_children():
		_collect_buttons(child, out)


# ────────────────────────────────────────────
# Input Simulasyonu
# ────────────────────────────────────────────

func _sim_click(pos: Vector2) -> void:
	var vp := get_viewport()
	# Button down — button_mask eklendi
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.button_mask = MOUSE_BUTTON_MASK_LEFT
	down.position = pos
	down.global_position = pos
	vp.push_input(down)
	await get_tree().process_frame
	await get_tree().process_frame
	# Button up
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.button_mask = 0
	up.position = pos
	up.global_position = pos
	vp.push_input(up)
	await get_tree().process_frame


func _sim_drag(from: Vector2, to: Vector2, steps: int) -> void:
	var vp := get_viewport()
	# Press
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.button_mask = MOUSE_BUTTON_MASK_LEFT
	down.position = from
	down.global_position = from
	vp.push_input(down)
	await get_tree().process_frame
	# Move
	for i in range(steps):
		var t := float(i + 1) / float(steps)
		var pos := from.lerp(to, t)
		var motion := InputEventMouseMotion.new()
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		motion.position = pos
		motion.global_position = pos
		vp.push_input(motion)
		await get_tree().process_frame
	# Release
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.button_mask = 0
	up.position = to
	up.global_position = to
	vp.push_input(up)


# ────────────────────────────────────────────
# Buton Bulma
# ────────────────────────────────────────────

func _find_button(btn_name: String, btn_text: String) -> BaseButton:
	return _find_btn_r(get_tree().root, btn_name, btn_text)


func _find_btn_r(node: Node, btn_name: String, btn_text: String) -> BaseButton:
	if node is BaseButton and (node as BaseButton).is_visible_in_tree():
		var name_ok := (btn_name == "" or str(node.name) == btn_name)
		var text_ok := true
		if btn_text != "":
			text_ok = node is Button and btn_text in (node as Button).text
		if (btn_name != "" or btn_text != "") and name_ok and text_ok:
			return node as BaseButton
	for child in node.get_children():
		var found := _find_btn_r(child, btn_name, btn_text)
		if found != null:
			return found
	return null


# ────────────────────────────────────────────
# Ana Sahne Erisimi
# ────────────────────────────────────────────

func _get_main_node():
	var scene := get_tree().current_scene
	if scene and "current_ticket" in scene:
		return scene
	return null


# ────────────────────────────────────────────
# State Export
# ────────────────────────────────────────────

func _write_state(result: Dictionary) -> void:
	var state := {
		"id": _pending_id,
		"ts": Time.get_unix_time_from_system(),
		"scene": _get_scene_path(),
		"game_state": _export_game_state(),
		"ui_elements": _export_ui(),
		"result": result,
	}
	var f := FileAccess.open(_state_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(state, "\t"))
		f.close()
	print("[TestHarness] State yazildi (id:%s)" % _pending_id)


func _get_scene_path() -> String:
	var s := get_tree().current_scene
	if s == null:
		return "null"
	return s.scene_file_path if s.scene_file_path != "" else str(s.name)


func _export_game_state() -> Dictionary:
	var gs := {
		"coins": GameState.coins,
		"energy": GameState.energy,
		"max_energy": GameState.get_max_energy(),
		"charm_points": GameState.charm_points,
		"in_round": GameState.in_round,
		"total_coins_earned": GameState.total_coins_earned,
		"total_rounds_played": GameState.total_rounds_played,
		"best_round_coins": GameState.best_round_coins,
		"charms": GameState.charms.duplicate(),
		"stats": GameState.stats.duplicate(),
		"round_stats": GameState.round_stats.duplicate(),
		"active_events": GameState.active_events.duplicate(),
		"collected_pieces": GameState.collected_pieces.duplicate(),
		"discovered_synergies": GameState.discovered_synergies.duplicate(),
		"unlocked_achievements": GameState.unlocked_achievements.duplicate(),
	}
	# Bilet bilgisi (oyun ekranindaysa)
	var main = _get_main_node()
	if main:
		var ticket = main.current_ticket
		gs["has_ticket"] = ticket != null
		if ticket:
			gs["ticket_type"] = ticket.ticket_type
			gs["ticket_scratched"] = ticket.scratched_count
			gs["ticket_total"] = ticket.total_areas
			gs["ticket_complete"] = ticket.is_complete
	return gs


func _export_ui() -> Array:
	var out := []
	_walk_ui(get_tree().root, out)
	return out


func _walk_ui(node: Node, out: Array) -> void:
	# Gorunmeyen CanvasItem dallarini kes
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return
	# Tip bazli toplama
	if node is Button:
		var b := node as Button
		out.append({
			"type": "Button",
			"name": str(b.name),
			"text": b.text,
			"disabled": b.disabled,
			"rect": _r2a(b.get_global_rect()),
		})
	elif node is Label:
		var l := node as Label
		if l.text != "":
			out.append({
				"type": "Label",
				"name": str(l.name),
				"text": l.text,
				"rect": _r2a(l.get_global_rect()),
			})
	elif node is BaseButton:
		var bb := node as BaseButton
		out.append({
			"type": "BaseButton",
			"name": str(bb.name),
			"disabled": bb.disabled,
			"rect": _r2a(bb.get_global_rect()),
		})
	# Cocuklari tara
	for child in node.get_children():
		_walk_ui(child, out)


func _r2a(r: Rect2) -> Array:
	return [r.position.x, r.position.y, r.size.x, r.size.y]
