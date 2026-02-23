extends RefCounted

## Rastgele olay sistemi. Tur icinde bilet sonrasi tetiklenir.
## Olaylar: Altin Bilet, Bull Run, Bedava Bilet, Joker Yagmuru, Mega Bilet

const EVENTS := {
	"golden_ticket": {
		"name": "Altin Bilet",
		"description": "Parlak bir bilet belirdi! Yakala!",
		"type": "popup",  # Ozel popup gosterilir
	},
	"bull_run": {
		"name": "BULL RUN!",
		"description": "Sonraki 3 bilet odulleri x2!",
		"type": "banner",
		"duration": 3,  # 3 bilet boyunca aktif
	},
	"free_ticket": {
		"name": "Bedava Bilet!",
		"description": "Sonraki bilet ucretsiz!",
		"type": "banner",
	},
	"joker_rain": {
		"name": "Joker Yagmuru!",
		"description": "Sonraki bilette tum semboller Joker!",
		"type": "banner",
	},
	"mega_ticket": {
		"name": "MEGA BILET!",
		"description": "Sonraki bilet garanti jackpot!",
		"type": "banner",
	},
}

const EVENT_ORDER := ["golden_ticket", "bull_run", "free_ticket", "joker_rain", "mega_ticket"]


## Her bilet sonrasi olay kontrolu yapar.
## tickets_in_round: turda kazilan bilet sayisi
## tickets_since_golden: son altin biletten bu yana gecen bilet
## Doner: olay id'si (String) veya bos string
static func roll_event(tickets_in_round: int, tickets_since_golden: int) -> String:
	# Mega Bilet: %0.5
	if randf() < 0.005:
		return "mega_ticket"

	# Joker Yagmuru: %1
	if randf() < 0.01:
		return "joker_rain"

	# Bull Run: %3
	if randf() < 0.03:
		return "bull_run"

	# Bedava Bilet: Her 10. bilette %20 sans
	if tickets_in_round > 0 and tickets_in_round % 10 == 0:
		if randf() < 0.20:
			return "free_ticket"

	# Altin Bilet: 5-8 bilet sonra artan sans
	if tickets_since_golden >= 5:
		# 5. bilette %15, her bilet +5%, 8. bilette %30, 12+ bilette %50
		var golden_chance: float = 0.15 + (tickets_since_golden - 5) * 0.05
		golden_chance = minf(golden_chance, 0.50)
		if randf() < golden_chance:
			return "golden_ticket"

	return ""


## Olay bilgisi getir
static func get_event(event_id: String) -> Dictionary:
	return EVENTS.get(event_id, {})
