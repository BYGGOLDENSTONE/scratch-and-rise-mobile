extends PanelContainer

## Eslesme sonuc popup'i.
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
			"big":
				title_label.text = "BUYUK ESLESME!"
			_:
				title_label.text = "ESLESME!"

		detail_label.text = "%s x%d = x%d carpan" % [symbol_name, count, multiplier]
		reward_label.text = "+%s Coin!" % GameState.format_number(reward)
		reward_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.3))
	else:
		title_label.text = "Eslesme yok..."
		detail_label.text = "3 ayni sembol bulunamadi"
		reward_label.text = "0 Coin"
		reward_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))

	visible = true
	print("[MatchResult] Sonuc: ", match_data)


func _on_continue_pressed() -> void:
	visible = false
	result_dismissed.emit()
