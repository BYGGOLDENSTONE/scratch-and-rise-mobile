extends Node2D

## Ana oyun sahnesi. Portrait layout.
## Bilet alani, ust bar, alt panel.
## Enerji labelina 5 kez tikla -> Debug Panel

const TicketScene := preload("res://scenes/ticket/Ticket.tscn")
const DebugPanelScene := preload("res://scenes/debug/DebugPanel.tscn")
const SynergyRef := preload("res://scripts/systems/synergy_system.gd")
const CollectionRef := preload("res://scripts/systems/collection_system.gd")
const EventRef := preload("res://scripts/systems/event_system.gd")
const AchievementRef := preload("res://scripts/systems/achievement_system.gd")
const AchievementToastScene := preload("res://scenes/ui/AchievementToast.tscn")
const EventBannerScene := preload("res://scenes/ui/EventBanner.tscn")
const GoldenTicketScene := preload("res://scenes/ui/GoldenTicketPopup.tscn")
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")

@onready var coin_label: Label = %CoinLabel
@onready var energy_label: Label = %EnergyLabel
@onready var ticket_count_label: Label = %TicketCountLabel
@onready var ticket_area: CenterContainer = %TicketArea
@onready var ticket_placeholder: Label = %TicketPlaceholder
@onready var bilet_secimi: HBoxContainer = %BiletSecimi
@onready var warning_label: Label = %WarningLabel
@onready var energy_timer_label: Label = %EnergyTimerLabel

var current_ticket: PanelContainer = null
var tickets_scratched: int = 0
var _debug_tap_count: int = 0
var _debug_last_tap_time: float = 0.0
var _debug_panel: Control = null
var _ticket_buttons: Dictionary = {}  # { "paper": Button, ... }
var _last_symbols: Array = []
var _last_match_data: Dictionary = {}
var _golden_ticket_popup: PanelContainer = null
var _yolo_triggered: bool = false
var _selected_ticket_type: String = ""  # Son secilen bilet turu (otomatik tekrar icin)
var _ticket_paid: bool = false  # Mevcut bilet icin coin odendi mi
var _pending_ticket_price: int = 0  # Ilk kazimada cekilecek fiyat (0 = bedava/odendi)
var _coin_delta_label: Label = null  # Coin yaninda +/- gosterimi


func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.energy_changed.connect(_on_energy_changed)
	GameState.round_ended.connect(_on_round_ended)
	GameState.theme_changed.connect(func(_t): _apply_theme())
	energy_label.mouse_filter = Control.MOUSE_FILTER_STOP
	energy_label.gui_input.connect(_on_debug_tap_input)
	_apply_theme()
	_build_ticket_buttons()
	_update_ui()
	_update_ticket_buttons()
	print("[Main] Game screen ready")


func _apply_theme() -> void:
	$Background.color = ThemeHelper.p("bg_main")
	var top_bar: PanelContainer = get_node("UILayer/UIRoot/VBox/TopBar")
	ThemeHelper.style_top_bar(top_bar)
	ThemeHelper.style_label(coin_label, ThemeHelper.p("warning"), 32)
	ThemeHelper.style_label(ticket_count_label, ThemeHelper.p("text_primary"), 28)
	ThemeHelper.style_label(energy_label, ThemeHelper.p("success"), 28)
	ThemeHelper.style_label(energy_timer_label, ThemeHelper.p("text_secondary"), 20)
	ThemeHelper.style_label(ticket_placeholder, ThemeHelper.p("text_secondary"), 16)
	ThemeHelper.style_warning(warning_label)
	var charm_btn: Button = get_node("UILayer/UIRoot/VBox/BottomPanel/ActionButtons/CharmBtn")
	var koleksiyon_btn: Button = get_node("UILayer/UIRoot/VBox/BottomPanel/ActionButtons/KoleksiyonBtn")
	var back_btn: Button = get_node("UILayer/UIRoot/VBox/BottomPanel/ActionButtons/BackBtn")
	ThemeHelper.make_button(charm_btn, ThemeHelper.p("info"), 24)
	ThemeHelper.make_button(koleksiyon_btn, ThemeHelper.p("success"), 24)
	ThemeHelper.make_button(back_btn, ThemeHelper.p("danger"), 24)


func _process(_delta: float) -> void:
	if GameState.energy < GameState.get_max_energy():
		var remaining: float = GameState.ENERGY_REGEN_SECONDS - GameState._energy_regen_accumulator
		var mins: int = int(remaining) / 60
		var secs: int = int(remaining) % 60
		energy_timer_label.text = "%d:%02d" % [mins, secs]
		energy_timer_label.visible = true
	else:
		energy_timer_label.visible = false


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
		ThemeHelper.make_button(btn, ThemeHelper.get_tier_color(t_type), 22)
		bilet_secimi.add_child(btn)
		_ticket_buttons[t_type] = btn


func _update_ui() -> void:
	coin_label.text = "Coin: %s" % GameState.format_number(GameState.coins)
	energy_label.text = "Enerji: %d/%d" % [GameState.energy, GameState.get_max_energy()]
	ticket_count_label.text = "Bilet: %d" % tickets_scratched


func _on_coins_changed(_new_amount: int) -> void:
	var old_text := coin_label.text
	coin_label.text = "Coin: %s" % GameState.format_number(GameState.coins)
	_update_ticket_buttons()
	# Coin degisim animasyonu: pulse + renk
	if coin_label.text != old_text:
		coin_label.pivot_offset = coin_label.size / 2
		var tw := create_tween()
		tw.tween_property(coin_label, "scale", Vector2(1.2, 1.2), 0.1)
		tw.tween_property(coin_label, "scale", Vector2.ONE, 0.15)


func _on_energy_changed(_new_amount: int) -> void:
	energy_label.text = "Enerji: %d/%d" % [GameState.energy, GameState.get_max_energy()]


func _on_round_ended(_total_earned: int) -> void:
	# Tur sonu basarim kontrolu
	var context := {"round_end": true}
	var new_achievements: Array = AchievementRef.check_achievements(context)
	for ach_id in new_achievements:
		_unlock_achievement(ach_id)
	SaveManager.save_game()
	SceneTransition.change_scene("res://scenes/screens/RoundEnd.tscn")


func _on_back_pressed() -> void:
	if GameState.in_round:
		GameState.end_round()
	else:
		SceneTransition.change_scene("res://scenes/screens/MainMenu.tscn")


func _on_ticket_buy(type: String) -> void:
	# Kazimadan degistirme: mevcut bilet var ama kazilmamis → ucretsiz degistir
	if current_ticket != null:
		if current_ticket.has_started_scratching:
			return  # Kazima basladiysa degistirilemez
		# Kazilmamis bilet: sil, yeni turu sec (coin henuz cekilmemis)
		current_ticket.queue_free()
		current_ticket = null
		print("[Main] Bilet degistirildi (kazilmamis, ucret alinmadi)")
		_create_ticket(type, true)  # is_swap = true
		return

	var config: Dictionary = TicketData.TICKET_CONFIGS.get(type, TicketData.TICKET_CONFIGS["paper"])
	var price: int = config["price"]

	# Bedava bilet kontrolu
	var is_free := false
	if GameState._free_ticket_active:
		is_free = true
		GameState._free_ticket_active = false
		_pending_ticket_price = 0
		print("[Main] Bedava bilet kullanildi!")
	else:
		# Coin yeterliligi kontrol et (henuz cekme, ilk kazimada cekilecek)
		if GameState.coins < price:
			print("[Main] Coin yetersiz!")
			_show_warning("Coin yetersiz!")
			return
		_pending_ticket_price = price

	_selected_ticket_type = type
	_ticket_paid = false
	_create_ticket(type, false)
	if is_free:
		print("[Main] %s (UCRETSIZ)" % config["name"])
	else:
		print("[Main] %s secildi (%d coin, kazimada cekilecek)" % [config["name"], price])


func _create_ticket(type: String, is_swap: bool) -> void:
	# Placeholder'i gizle, bilet olustur
	ticket_placeholder.visible = false
	current_ticket = TicketScene.instantiate()
	ticket_area.add_child(current_ticket)

	# Joker Yagmuru: tum semboller joker
	var symbol_override := ""
	if GameState._joker_rain_active and not is_swap:
		symbol_override = "joker"
		GameState._joker_rain_active = false
		print("[Main] Joker Yagmuru aktif! Tum semboller Joker!")

	# Swap durumunda yeni biletin fiyatini guncelle
	if is_swap:
		var config: Dictionary = TicketData.TICKET_CONFIGS.get(type, TicketData.TICKET_CONFIGS["paper"])
		_pending_ticket_price = config["price"]

	_selected_ticket_type = type
	current_ticket.setup(type, symbol_override)
	current_ticket.ticket_completed.connect(_on_ticket_completed)
	# Ilk kazima olayinda coin cek + butonlari kilitle
	for area in current_ticket._scratch_areas:
		area.area_scratched.connect(_on_first_scratch, CONNECT_ONE_SHOT)
	_update_ticket_buttons()


func _on_first_scratch(_area_index: int) -> void:
	# Ilk kazimada coin cek
	if not _ticket_paid and _pending_ticket_price > 0:
		GameState.spend_coins(_pending_ticket_price)
		_show_coin_delta(-_pending_ticket_price)
		print("[Main] Bilet ucreti cekildi: -%d coin" % _pending_ticket_price)
		_ticket_paid = true
		_pending_ticket_price = 0
	elif not _ticket_paid:
		_ticket_paid = true  # Bedava bilet
	# Kazima basladiginda butonlari kilitle (degistirme artik yapilamaz)
	_update_ticket_buttons()


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
			var jackpot_range: Array = MatchSystem.MULTIPLIER_RANGES.get(ticket_type, MatchSystem.MULTIPLIER_RANGES["paper"])["jackpot"]
			match_data["has_match"] = true
			match_data["best_count"] = 5
			match_data["multiplier"] = randi_range(jackpot_range[0], jackpot_range[1])
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
		_show_coin_delta(reward)
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

	# Gorsel efektler
	_play_match_effects(match_data)

	# Kutlama animasyonu (bilet uzerinde)
	current_ticket.celebration_finished.connect(_on_match_result_dismissed, CONNECT_ONE_SHOT)
	current_ticket.play_celebration(match_data)


func _play_match_effects(match_data: Dictionary) -> void:
	if not match_data["has_match"]:
		return

	var reward: int = match_data["reward"]
	var tier: String = match_data["tier"]
	var synergies: Array = match_data.get("synergies", [])

	# Coin ucma efekti (bilet alaninin ortasindan)
	var fly_pos := Vector2(360, 500)
	ScreenEffects.coin_fly(reward, fly_pos)

	# YOLO efekti
	if _yolo_triggered:
		_yolo_triggered = false
		ScreenEffects.yolo_effect()
	elif tier == "jackpot":
		ScreenEffects.jackpot_effect()
	elif tier == "big":
		ScreenEffects.big_win_effect()

	# Sinerji efekti
	if not synergies.is_empty():
		ScreenEffects.synergy_effect()


func _on_match_result_dismissed() -> void:
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
	_ticket_paid = false
	ticket_placeholder.visible = true
	_update_ticket_buttons()

	# Coin yetersizse turu otomatik bitir
	var cheapest_price: int = TicketData.get_cheapest_unlocked_price()
	if GameState.coins < cheapest_price and GameState.in_round:
		print("[Main] Coin bitti, tur otomatik bitiyor!")
		GameState.end_round()
		return

	# Otomatik bilet: son secilen tur icin coin yetiyorsa otomatik al
	if _selected_ticket_type != "" and GameState.in_round:
		var config: Dictionary = TicketData.TICKET_CONFIGS.get(_selected_ticket_type, {})
		var price: int = config.get("price", 0)
		if TicketData.is_ticket_unlocked(_selected_ticket_type) and GameState.coins >= price:
			# Kisa gecikme ile otomatik bilet al (UX icin)
			get_tree().create_timer(0.75).timeout.connect(func():
				if current_ticket == null and GameState.in_round:
					_on_ticket_buy(_selected_ticket_type)
			)


func _update_ticket_buttons() -> void:
	# Kazimadan once butonlar aktif (degistirme icin), kazima basladiysa kilitli
	var can_swap: bool = current_ticket != null and not current_ticket.has_started_scratching
	for t_type in TicketData.TICKET_ORDER:
		var btn: Button = _ticket_buttons.get(t_type)
		if btn == null:
			continue
		var config: Dictionary = TicketData.TICKET_CONFIGS[t_type]
		var unlocked: bool = TicketData.is_ticket_unlocked(t_type)

		if not unlocked:
			btn.text = "%s\nKilitli" % config["name"]
			btn.disabled = true
		elif can_swap:
			# Kazimadan degistirme: tum acik biletler secilir (ucret alinmayacak)
			btn.text = "%s\n%d C" % [config["name"], config["price"]]
			btn.disabled = (t_type == _selected_ticket_type)  # Zaten secili olani devre disi birak
		else:
			btn.text = "%s\n%d C" % [config["name"], config["price"]]
			btn.disabled = (current_ticket != null and current_ticket.has_started_scratching) or (GameState.coins < config["price"])


func _show_coin_delta(amount: int) -> void:
	# Onceki delta label varsa temizle
	if _coin_delta_label and is_instance_valid(_coin_delta_label):
		_coin_delta_label.queue_free()

	_coin_delta_label = Label.new()
	_coin_delta_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_coin_delta_label.z_index = 50

	if amount >= 0:
		_coin_delta_label.text = "+%s" % GameState.format_number(amount)
		_coin_delta_label.add_theme_color_override("font_color", Color(0.1, 1.0, 0.3))
	else:
		_coin_delta_label.text = "%s" % GameState.format_number(amount)
		_coin_delta_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))

	_coin_delta_label.add_theme_font_size_override("font_size", 28)
	_coin_delta_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	_coin_delta_label.add_theme_constant_override("shadow_offset_x", 2)
	_coin_delta_label.add_theme_constant_override("shadow_offset_y", 2)

	# Coin label'in altina overlay olarak konumlandir
	get_node("UILayer").add_child(_coin_delta_label)
	# Coin label'in global pozisyonunu kullan — altina yerlestir
	_coin_delta_label.position = Vector2(coin_label.global_position.x, coin_label.global_position.y + coin_label.size.y + 4)
	_coin_delta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_coin_delta_label.custom_minimum_size = Vector2(coin_label.size.x, 0)

	# Animasyon: belir → yukari kayarak kaybol
	_coin_delta_label.modulate.a = 1.0
	_coin_delta_label.pivot_offset = Vector2(coin_label.size.x / 2.0, 14)
	_coin_delta_label.scale = Vector2(0.5, 0.5)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_coin_delta_label, "scale", Vector2(1.3, 1.3), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.chain().tween_interval(2.5)
	tw.chain().tween_property(_coin_delta_label, "modulate:a", 0.0, 0.6)
	tw.chain().tween_callback(func():
		if is_instance_valid(_coin_delta_label):
			_coin_delta_label.queue_free()
			_coin_delta_label = null
	)


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
			_yolo_triggered = true
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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()


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
