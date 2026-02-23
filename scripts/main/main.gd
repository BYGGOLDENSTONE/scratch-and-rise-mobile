extends Node2D

## Ana oyun sahnesi. Portrait layout.
## Bilet alani, ust bar, alt panel.
## Enerji labelina 5 kez tikla -> Debug Panel

const TicketScene := preload("res://scenes/ticket/Ticket.tscn")
const MatchResultScene := preload("res://scenes/ui/MatchResult.tscn")
const DebugPanelScene := preload("res://scenes/debug/DebugPanel.tscn")
const SynergyRef := preload("res://scripts/systems/synergy_system.gd")
const CollectionRef := preload("res://scripts/systems/collection_system.gd")
const EventRef := preload("res://scripts/systems/event_system.gd")
const AchievementRef := preload("res://scripts/systems/achievement_system.gd")
const AchievementToastScene := preload("res://scenes/ui/AchievementToast.tscn")
const EventBannerScene := preload("res://scenes/ui/EventBanner.tscn")
const GoldenTicketScene := preload("res://scenes/ui/GoldenTicketPopup.tscn")

@onready var coin_label: Label = %CoinLabel
@onready var energy_label: Label = %EnergyLabel
@onready var ticket_count_label: Label = %TicketCountLabel
@onready var ticket_area: CenterContainer = %TicketArea
@onready var ticket_placeholder: Label = %TicketPlaceholder
@onready var bilet_secimi: HBoxContainer = %BiletSecimi
@onready var warning_label: Label = %WarningLabel

var current_ticket: PanelContainer = null
var match_result_popup: PanelContainer = null
var tickets_scratched: int = 0
var _debug_tap_count: int = 0
var _debug_last_tap_time: float = 0.0
var _debug_panel: Control = null
var _ticket_buttons: Dictionary = {}  # { "paper": Button, ... }
var _last_symbols: Array = []
var _last_match_data: Dictionary = {}
var _golden_ticket_popup: PanelContainer = null


func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.energy_changed.connect(_on_energy_changed)
	GameState.round_ended.connect(_on_round_ended)
	energy_label.mouse_filter = Control.MOUSE_FILTER_STOP
	energy_label.gui_input.connect(_on_debug_tap_input)
	_build_ticket_buttons()
	_update_ui()
	_update_ticket_buttons()
	print("[Main] Game screen ready")


func _build_ticket_buttons() -> void:
	# Sahne'deki mevcut butonlari temizle
	for child in bilet_secimi.get_children():
		child.queue_free()
	_ticket_buttons.clear()

	# Her bilet turu icin buton olustur
	for t_type in TicketData.TICKET_ORDER:
		var config: Dictionary = TicketData.TICKET_CONFIGS[t_type]
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_ticket_buy.bind(t_type))
		bilet_secimi.add_child(btn)
		_ticket_buttons[t_type] = btn


func _update_ui() -> void:
	coin_label.text = "Coin: %s" % GameState.format_number(GameState.coins)
	energy_label.text = "Enerji: %d/%d" % [GameState.energy, GameState.get_max_energy()]
	ticket_count_label.text = "Bilet: %d" % tickets_scratched


func _on_coins_changed(_new_amount: int) -> void:
	coin_label.text = "Coin: %s" % GameState.format_number(GameState.coins)
	_update_ticket_buttons()


func _on_energy_changed(_new_amount: int) -> void:
	energy_label.text = "Enerji: %d/%d" % [GameState.energy, GameState.get_max_energy()]


func _on_round_ended(_total_earned: int) -> void:
	# Tur sonu basarim kontrolu
	var context := {"round_end": true}
	var new_achievements: Array = AchievementRef.check_achievements(context)
	for ach_id in new_achievements:
		_unlock_achievement(ach_id)
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://scenes/screens/RoundEnd.tscn")


func _on_back_pressed() -> void:
	if GameState.in_round:
		GameState.end_round()
	else:
		get_tree().change_scene_to_file("res://scenes/screens/MainMenu.tscn")


func _on_ticket_buy(type: String) -> void:
	if current_ticket != null:
		return
	var config: Dictionary = TicketData.TICKET_CONFIGS.get(type, TicketData.TICKET_CONFIGS["paper"])
	var price: int = config["price"]

	# Bedava bilet kontrolu
	var is_free := false
	if GameState._free_ticket_active:
		is_free = true
		GameState._free_ticket_active = false
		print("[Main] Bedava bilet kullanildi!")
	else:
		if not GameState.spend_coins(price):
			print("[Main] Coin yetersiz!")
			_show_warning("Coin yetersiz!")
			return

	# Placeholder'i gizle, bilet olustur
	ticket_placeholder.visible = false
	current_ticket = TicketScene.instantiate()
	ticket_area.add_child(current_ticket)

	# Joker Yagmuru: tum semboller joker
	var symbol_override := ""
	if GameState._joker_rain_active:
		symbol_override = "joker"
		GameState._joker_rain_active = false
		print("[Main] Joker Yagmuru aktif! Tum semboller Joker!")

	current_ticket.setup(type, symbol_override)
	current_ticket.ticket_completed.connect(_on_ticket_completed)
	_update_ticket_buttons()
	if is_free:
		print("[Main] %s (UCRETSIZ), kalan: %d" % [config["name"], GameState.coins])
	else:
		print("[Main] %s satin alindi (%d coin), kalan: %d" % [config["name"], price, GameState.coins])


func _on_ticket_completed(symbols: Array) -> void:
	print("[Main] Bilet tamamlandi! Semboller: ", symbols)
	_last_symbols = symbols

	# Eslesme kontrolu
	var ticket_type: String = "paper"
	if current_ticket and current_ticket.has_method("get_ticket_type"):
		ticket_type = current_ticket.get_ticket_type()
	var match_data: Dictionary = MatchSystem.check_match(symbols, ticket_type)

	# Mega Bilet override: garanti jackpot
	if GameState._mega_ticket_active:
		GameState._mega_ticket_active = false
		if not match_data["has_match"] or match_data["tier"] != "jackpot":
			var price: int = TicketData.TICKET_CONFIGS.get(ticket_type, TicketData.TICKET_CONFIGS["paper"])["price"]
			match_data["has_match"] = true
			match_data["best_count"] = 5
			match_data["multiplier"] = randi_range(20, 100)
			match_data["tier"] = "jackpot"
			match_data["reward"] = price * match_data["multiplier"]
			print("[Main] MEGA BILET! Garanti jackpot!")

	# Sinerji kontrolu
	var synergies: Array = SynergyRef.check_synergies(symbols)
	match_data["synergies"] = synergies
	match_data["new_synergies"] = []

	# Sinerji kesfedilmemisse kaydet
	for syn in synergies:
		if GameState.discover_synergy(syn["id"]):
			match_data["new_synergies"].append(syn["id"])
			GameState.stats["total_synergies_found"] += 1

	# En yuksek sinerji carpanini bul
	var synergy_mult := 1
	for syn in synergies:
		if syn["multiplier"] > synergy_mult:
			synergy_mult = syn["multiplier"]
	match_data["synergy_multiplier"] = synergy_mult

	# Charm bonuslarini uygula ve coin ekle
	if match_data["has_match"]:
		var reward: int = _apply_charm_bonuses(match_data["reward"], match_data)
		# Sinerji carpanini uygula
		if synergy_mult > 1:
			reward *= synergy_mult
			print("[Main] Sinerji! x%d carpan" % synergy_mult)
		# Bull Run: x2 carpan
		var bull_remaining: int = GameState.active_events.get("bull_run", 0)
		if bull_remaining > 0:
			reward *= 2
			GameState.active_events["bull_run"] = bull_remaining - 1
			print("[Main] Bull Run! x2 carpan (kalan: %d)" % (bull_remaining - 1))
		match_data["reward"] = reward
		GameState.add_coins(reward)
		print("[Main] Eslesme! +", reward, " coin")
	else:
		print("[Main] Eslesme yok")

	# --- Stats guncelle ---
	GameState.stats["total_tickets"] += 1
	GameState.round_stats["tickets"] = GameState.round_stats.get("tickets", 0) + 1
	if match_data["has_match"]:
		GameState.stats["total_matches"] += 1
		GameState.round_stats["matches"] = GameState.round_stats.get("matches", 0) + 1
		GameState.round_stats["coins_earned"] = GameState.round_stats.get("coins_earned", 0) + match_data["reward"]
		GameState._current_match_streak += 1
		if GameState._current_match_streak > GameState.stats["best_streak"]:
			GameState.stats["best_streak"] = GameState._current_match_streak
		if match_data["tier"] == "jackpot":
			GameState.stats["total_jackpots"] += 1
			GameState.round_stats["jackpots"] = GameState.round_stats.get("jackpots", 0) + 1
	else:
		GameState._current_match_streak = 0
	if synergies.size() > 0:
		GameState.round_stats["synergies"] = GameState.round_stats.get("synergies", 0) + synergies.size()

	# Koleksiyon parcasi dusme kontrolu
	var drop: Dictionary = CollectionRef.roll_collection_drop(ticket_type)
	match_data["collection_drop"] = drop
	match_data["set_completed"] = ""
	if not drop.is_empty():
		GameState.add_collection_piece(drop["set_id"], drop["piece_id"])
		print("[Main] Koleksiyon parcasi dustu: %s / %s" % [drop["set_id"], drop["piece_id"]])
		if CollectionRef.is_set_complete(drop["set_id"]):
			match_data["set_completed"] = drop["set_id"]
			print("[Main] SET TAMAMLANDI: ", drop["set_id"])

	_last_match_data = match_data
	# Sonuc popup'ini goster
	_show_match_result(match_data)


func _show_match_result(match_data: Dictionary) -> void:
	match_result_popup = MatchResultScene.instantiate()
	get_node("UILayer").add_child(match_result_popup)
	match_result_popup.show_result(match_data)
	match_result_popup.result_dismissed.connect(_on_match_result_dismissed)


func _on_match_result_dismissed() -> void:
	if match_result_popup:
		match_result_popup.queue_free()
		match_result_popup = null
	tickets_scratched += 1
	GameState._tickets_since_golden += 1
	ticket_count_label.text = "Bilet: %d" % tickets_scratched

	# Basarim kontrolu
	var context := {
		"symbols": _last_symbols,
		"match_data": _last_match_data,
		"synergies": _last_match_data.get("synergies", []),
	}
	var new_achievements: Array = AchievementRef.check_achievements(context)
	for ach_id in new_achievements:
		_unlock_achievement(ach_id)

	# Olay kontrolu
	var event_id: String = EventRef.roll_event(tickets_scratched, GameState._tickets_since_golden)
	if event_id != "":
		_trigger_event(event_id)

	_remove_current_ticket()


func _remove_current_ticket() -> void:
	if current_ticket != null:
		current_ticket.queue_free()
		current_ticket = null
	ticket_placeholder.visible = true
	_update_ticket_buttons()

	# Coin yetersizse turu otomatik bitir
	var cheapest_price: int = TicketData.get_cheapest_unlocked_price()
	if GameState.coins < cheapest_price and GameState.in_round:
		print("[Main] Coin bitti, tur otomatik bitiyor!")
		GameState.end_round()


func _update_ticket_buttons() -> void:
	for t_type in TicketData.TICKET_ORDER:
		var btn: Button = _ticket_buttons.get(t_type)
		if btn == null:
			continue
		var config: Dictionary = TicketData.TICKET_CONFIGS[t_type]
		var unlocked: bool = TicketData.is_ticket_unlocked(t_type)

		if not unlocked:
			btn.text = "%s\nKilitli" % config["name"]
			btn.disabled = true
		else:
			btn.text = "%s\n%d C" % [config["name"], config["price"]]
			btn.disabled = (current_ticket != null) or (GameState.coins < config["price"])


func _show_warning(text: String) -> void:
	warning_label.text = text
	warning_label.visible = true
	warning_label.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.0)
	tw.tween_property(warning_label, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func(): warning_label.visible = false)


func _apply_charm_bonuses(base_reward: int, match_data: Dictionary) -> int:
	var bonus_mult := 1.0

	# Sans Tokasi: +10% eslesme odulu per level
	bonus_mult += GameState.get_charm_level("sans_tokasi") * 0.10

	# Altinparmak: +15% tum oduller per level
	bonus_mult += GameState.get_charm_level("altinparmak") * 0.15

	# Koleksiyon bonuslari
	bonus_mult += CollectionRef.get_match_reward_bonus()
	bonus_mult += CollectionRef.get_all_rewards_bonus()

	# Jackpot bonusu (sadece jackpot tier'da)
	if match_data["tier"] == "jackpot":
		bonus_mult += CollectionRef.get_jackpot_bonus()

	# Kral Dokunusu: 4+ eslesme odulu x(level+1)
	if match_data["best_count"] >= 4:
		var kral_level := GameState.get_charm_level("kral_dokunusu")
		if kral_level > 0:
			bonus_mult *= (1 + kral_level)

	var reward := int(base_reward * bonus_mult)

	# YOLO: %1 sansla odul x50
	if GameState.get_charm_level("yolo") > 0:
		if randf() < 0.01:
			reward *= 50
			print("[Main] YOLO! x50!")

	return reward


## Olay tetikle
func _trigger_event(event_id: String) -> void:
	var event_data: Dictionary = EventRef.get_event(event_id)
	if event_data.is_empty():
		return
	print("[Main] Olay tetiklendi: %s" % event_id)
	GameState.event_triggered.emit(event_id, event_data)

	match event_id:
		"golden_ticket":
			GameState._tickets_since_golden = 0
			_show_golden_ticket_popup()
		"bull_run":
			GameState.active_events["bull_run"] = event_data.get("duration", 3)
			_show_event_banner(event_data["name"], event_data["description"])
		"free_ticket":
			GameState._free_ticket_active = true
			_show_event_banner(event_data["name"], event_data["description"])
		"joker_rain":
			GameState._joker_rain_active = true
			_show_event_banner(event_data["name"], event_data["description"])
		"mega_ticket":
			GameState._mega_ticket_active = true
			_show_event_banner(event_data["name"], event_data["description"])


## Basarim ac
func _unlock_achievement(ach_id: String) -> void:
	if ach_id in GameState.unlocked_achievements:
		return
	var ach: Dictionary = AchievementRef.get_achievement(ach_id)
	if ach.is_empty():
		return
	GameState.unlocked_achievements.append(ach_id)
	var reward_cp: int = ach.get("reward_cp", 0)
	GameState.charm_points += reward_cp
	GameState.achievement_unlocked.emit(ach_id)
	var display_name: String = ach.get("real_name", ach.get("name", ach_id))
	print("[Main] Basarim acildi: %s (+%d CP)" % [display_name, reward_cp])
	_show_achievement_toast(display_name, reward_cp)
	SaveManager.save_game()


## Basarim toast'u goster
func _show_achievement_toast(ach_name: String, reward_cp: int) -> void:
	var toast := AchievementToastScene.instantiate()
	get_node("UILayer").add_child(toast)
	toast.show_achievement(ach_name, reward_cp)


## Olay banner'i goster
func _show_event_banner(event_name: String, description: String) -> void:
	var banner := EventBannerScene.instantiate()
	get_node("UILayer").add_child(banner)
	banner.show_event(event_name, description)


## Altin bilet popup'u goster
func _show_golden_ticket_popup() -> void:
	if _golden_ticket_popup != null:
		return
	_golden_ticket_popup = GoldenTicketScene.instantiate()
	get_node("UILayer").add_child(_golden_ticket_popup)
	_golden_ticket_popup.golden_ticket_caught.connect(_on_golden_caught)
	_golden_ticket_popup.golden_ticket_missed.connect(_on_golden_missed)


func _on_golden_caught() -> void:
	GameState._free_ticket_active = true
	print("[Main] Altin bilet yakalandi! Sonraki bilet ucretsiz!")
	_golden_ticket_popup = null


func _on_golden_missed() -> void:
	print("[Main] Altin bilet kacti!")
	_golden_ticket_popup = null


func _on_debug_tap_input(event: InputEvent) -> void:
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
	get_node("UILayer").add_child(_debug_panel)
	_debug_panel.panel_closed.connect(_on_debug_closed)


func _on_debug_closed() -> void:
	_debug_panel = null
	_update_ui()
	_update_ticket_buttons()
