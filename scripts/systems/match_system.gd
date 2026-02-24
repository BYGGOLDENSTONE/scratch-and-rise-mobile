class_name MatchSystem
extends RefCounted

## Eslesme kontrolu ve odul hesaplama.
## base_reward sistemi: odul = base_reward x carpan (base_reward < fiyat = dogal kayip)
##   3 ayni sembol = normal eslesme (genelde zarar)
##   4 ayni sembol = buyuk eslesme (kar sansi)
##   5+ ayni sembol = JACKPOT (buyuk kar)

## Bilet bazli carpan aralik tablosu: [min, max]
## Odul = base_reward x carpan (base_reward << price = gercek kazi kazan riski)
const MULTIPLIER_RANGES := {
	"paper": {
		"normal": [1, 3],    # 5 x1-3 = 5-15 (break even ile kucuk kar)
		"big": [3, 5],       # 5 x3-5 = 15-25 (iyi kar)
		"jackpot": [8, 15],  # 5 x8-15 = 40-75 (buyuk kar)
	},
	"bronze": {
		"normal": [2, 3],    # 10 x2-3 = 20-30 (kayip 5 ile kucuk kar)
		"big": [4, 7],       # 10 x4-7 = 40-70 (iyi kar)
		"jackpot": [10, 20], # 10 x10-20 = 100-200 (buyuk kar)
	},
	"silver": {
		"normal": [1, 2],    # 20 x1-2 = 20-40 (kayip 80-60)
		"big": [4, 8],       # 20 x4-8 = 80-160 (kayip 20 ile kar 60)
		"jackpot": [12, 25], # 20 x12-25 = 240-500 (kar 140-400)
	},
	"gold": {
		"normal": [1, 3],    # 40 x1-3 = 40-120 (kayip 460-380)
		"big": [5, 12],      # 40 x5-12 = 200-480 (kayip 300 ile sifir)
		"jackpot": [15, 40], # 40 x15-40 = 600-1600 (kar 100-1100)
	},
	"platinum": {
		"normal": [1, 3],    # 200 x1-3 = 200-600 (kayip 2300-1900)
		"big": [8, 20],      # 200 x8-20 = 1600-4000 (kayip 900 ile kar 1500)
		"jackpot": [30, 80], # 200 x30-80 = 6000-16000 (kar 3500-13500)
	},
	"diamond_tier": {
		"normal": [1, 3],     # 450 x1-3 = 450-1350 (kayip 6150-6050)
		"big": [10, 25],      # 450 x10-25 = 4500-11250 (kayip 3000 ile kar 3750)
		"jackpot": [40, 100], # 450 x40-100 = 18000-45000 (kar 10500-37500)
	},
	"emerald_tier": {
		"normal": [1, 3],      # 1000 x1-3 = 1000-3000 (kayip 19000-17000)
		"big": [12, 30],       # 1000 x12-30 = 12000-30000 (kayip 8000 ile kar 10000)
		"jackpot": [50, 130],  # 1000 x50-130 = 50000-130000 (kar 30000-110000)
	},
	"ruby_tier": {
		"normal": [1, 3],      # 2000 x1-3 = 2000-6000 (kayip 48000-44000)
		"big": [15, 40],       # 2000 x15-40 = 30000-80000 (kayip 20000 ile kar 30000)
		"jackpot": [60, 170],  # 2000 x60-170 = 120000-340000 (kar 70000-290000)
	},
	"obsidian": {
		"normal": [1, 3],      # 4000 x1-3 = 4000-12000 (kayip 121000-113000)
		"big": [20, 50],       # 4000 x20-50 = 80000-200000 (kayip 45000 ile kar 75000)
		"jackpot": [80, 220],  # 4000 x80-220 = 320000-880000 (kar 195000-755000)
	},
	"legendary": {
		"normal": [1, 3],       # 7500 x1-3 = 7500-22500 (kayip 292500-277500)
		"big": [25, 60],        # 7500 x25-60 = 187500-450000 (kayip 112500 ile kar 150000)
		"jackpot": [100, 300],  # 7500 x100-300 = 750000-2250000 (kar 450000-1950000)
	},
}


## Eslesme sonucunu dondurur (Joker/x2/Bomba destegi dahil)
## { "has_match": bool, "best_symbol": String, "best_count": int,
##   "reward": int, "multiplier": int, "tier": String,
##   "has_x2": bool, "has_bomb": bool, "joker_count": int }
static func check_match(symbols: Array, ticket_type: String) -> Dictionary:
	var config: Dictionary = TicketData.TICKET_CONFIGS.get(ticket_type, TicketData.TICKET_CONFIGS["paper"])
	var base_reward: int = config.get("base_reward", config["price"])

	# Sembolleri say
	var counts := {}
	for s in symbols:
		counts[s] = counts.get(s, 0) + 1

	# Ozel sembolleri ayir
	var joker_count: int = counts.get("joker", 0)
	var has_x2: bool = counts.has("x2_multiplier")
	var has_bomb: bool = counts.has("bomb")
	counts.erase("joker")
	counts.erase("x2_multiplier")
	counts.erase("bomb")

	# En cok tekrar eden normal sembolu bul
	var best_symbol := ""
	var best_count := 0
	for s in counts:
		if counts[s] > best_count:
			best_count = counts[s]
			best_symbol = s

	# Joker: en iyi sembole eklenir (wildcard)
	best_count += joker_count
	if best_symbol == "" and joker_count > 0:
		best_symbol = "joker"

	# Bomba: eslesme varsa +1 bonus
	if has_bomb and best_count >= 3:
		best_count += 1

	# Eslesme kontrolu
	if best_count < 3:
		return {
			"has_match": false,
			"best_symbol": best_symbol if best_symbol != "" else (symbols[0] if symbols.size() > 0 else ""),
			"best_count": best_count,
			"reward": 0,
			"multiplier": 0,
			"tier": "none",
			"has_x2": has_x2,
			"has_bomb": has_bomb,
			"joker_count": joker_count,
		}

	# Carpan ve tier hesapla (bilet bazli)
	var multiplier: int = 0
	var tier: String = ""
	var ranges: Dictionary = MULTIPLIER_RANGES.get(ticket_type, MULTIPLIER_RANGES["paper"])

	if best_count >= 5:
		tier = "jackpot"
		multiplier = randi_range(ranges["jackpot"][0], ranges["jackpot"][1])
	elif best_count == 4:
		tier = "big"
		multiplier = randi_range(ranges["big"][0], ranges["big"][1])
	else:
		tier = "normal"
		multiplier = randi_range(ranges["normal"][0], ranges["normal"][1])

	var reward: int = base_reward * multiplier

	# x2 Carpan sembolu: odulu ikiye katlar
	if has_x2:
		reward *= 2

	return {
		"has_match": true,
		"best_symbol": best_symbol,
		"best_count": best_count,
		"reward": reward,
		"multiplier": multiplier,
		"tier": tier,
		"has_x2": has_x2,
		"has_bomb": has_bomb,
		"joker_count": joker_count,
	}
