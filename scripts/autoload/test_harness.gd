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
	var center := btn.get_global_rect().get_center()
	await _sim_click(center)
	return {"clicked_button": str(btn.name), "at": [center.x, center.y]}


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
	await get_tree().process_frame
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	if img == null:
		return {"error": "Viewport yakalanamadi"}
	img.save_png(_screenshot_path)
	return {"saved": _screenshot_path}


# ────────────────────────────────────────────
# Input Simulasyonu
# ────────────────────────────────────────────

func _sim_click(pos: Vector2) -> void:
	var vp := get_viewport()
	# Button down
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = pos
	down.global_position = pos
	vp.push_input(down)
	await get_tree().process_frame
	# Button up
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = pos
	up.global_position = pos
	vp.push_input(up)


func _sim_drag(from: Vector2, to: Vector2, steps: int) -> void:
	var vp := get_viewport()
	# Press
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = from
	down.global_position = from
	vp.push_input(down)
	await get_tree().process_frame
	# Move
	for i in range(steps):
		var t := float(i + 1) / float(steps)
		var pos := from.lerp(to, t)
		var motion := InputEventMouseMotion.new()
		motion.position = pos
		motion.global_position = pos
		vp.push_input(motion)
		await get_tree().process_frame
	# Release
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
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
