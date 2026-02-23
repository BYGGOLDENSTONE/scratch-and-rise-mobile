extends PanelContainer

## Eslesme sonuc popup'i.
const CollectionRef := preload("res://scripts/systems/collection_system.gd")
const ThemeHelper := preload("res://scripts/ui/theme_helper.gd")
## Eslesme varsa sembol, carpan, toplam coin gosterir.
## Eslesme yoksa "Eslesme yok" gosterir.
## DEVAM butonuyla kapanir.

signal result_dismissed

@onready var title_label: Label = %TitleLabel
@onready var detail_label: Label = %DetailLabel
@onready var reward_label: Label = %RewardLabel
@onready var continue_btn: Button = %ContinueBtn


func _ready() -> void:
	continue_btn.pressed.connect(_on_continue_pressed)
	_apply_theme()


func _apply_theme() -> void:
	var panel: PanelContainer = $CenterBox/Panel
	ThemeHelper.make_panel(panel, ThemeHelper.p("warning"), ThemeHelper.p("bg_panel"))
	ThemeHelper.style_title(title_label, ThemeHelper.p("warning"), 28)
	ThemeHelper.style_label(detail_label, ThemeHelper.p("text_primary"), 16)
	ThemeHelper.make_button(continue_btn, ThemeHelper.p("success"), 18)


func show_result(match_data: Dictionary) -> void:
	if match_data["has_match"]:
		var symbol_name: String = TicketData.get_display_name(match_data["best_symbol"])
		var count: int = match_data["best_count"]
		var reward: int = match_data["reward"]
		var multiplier: int = match_data["multiplier"]
		var tier: String = match_data["tier"]

		# Tier'a gore baslik
		match tier:
			"jackpot":
				title_label.text = "JACKPOT!"
				ThemeHelper.style_title(title_label, ThemeHelper.p("warning"), 32)
			"big":
				title_label.text = "BUYUK ESLESME!"
				ThemeHelper.style_title(title_label, ThemeHelper.p("success"), 28)
			_:
				title_label.text = "ESLESME!"

		var detail_text := "%s x%d = x%d carpan" % [symbol_name, count, multiplier]

		# Sinerji bilgisi
		var synergies: Array = match_data.get("synergies", [])
		var new_synergies: Array = match_data.get("new_synergies", [])
		var synergy_mult: int = match_data.get("synergy_multiplier", 1)

		if not synergies.is_empty():
			for syn in synergies:
				var syn_name: String = syn["name"]
				if syn["id"] in new_synergies:
					detail_text += "\nYENI SINERJI: %s! x%d" % [syn_name, syn["multiplier"]]
				else:
					detail_text += "\nSINERJI: %s! x%d" % [syn_name, syn["multiplier"]]

			# Yeni sinerji kesfedildiyse basligi degistir
			if not new_synergies.is_empty():
				title_label.text = "SINERJI KESFEDILDI!"

		detail_label.text = detail_text
		reward_label.text = "+%s Coin!" % GameState.format_number(reward)
		ThemeHelper.style_label(reward_label, ThemeHelper.p("success"), 24)
	else:
		title_label.text = "Eslesme yok..."
		ThemeHelper.style_title(title_label, ThemeHelper.p("text_secondary"), 24)
		detail_label.text = "3 ayni sembol bulunamadi"
		reward_label.text = "0 Coin"
		ThemeHelper.style_label(reward_label, ThemeHelper.p("text_muted"), 20)

	# Koleksiyon parcasi dustu mu?
	var drop: Dictionary = match_data.get("collection_drop", {})
	if not drop.is_empty():
		var piece_name: String = CollectionRef.get_piece_name(drop["set_id"], drop["piece_id"])
		var set_name: String = CollectionRef.get_set(drop["set_id"]).get("name", "")
		var drop_text := "\nKoleksiyon: %s (%s)" % [piece_name, set_name]
		var set_completed: String = match_data.get("set_completed", "")
		if set_completed != "":
			drop_text += "\nSET TAMAMLANDI!"
		detail_label.text += drop_text

	visible = true
	# Giris animasyonu: panel scale + fade
	var panel: PanelContainer = $CenterBox/Panel
	panel.pivot_offset = panel.size / 2
	panel.scale = Vector2(0.7, 0.7)
	panel.modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(panel, "modulate:a", 1.0, 0.2)
	print("[MatchResult] Sonuc: ", match_data)


func _on_continue_pressed() -> void:
	visible = false
	result_dismissed.emit()
