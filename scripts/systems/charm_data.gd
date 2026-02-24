class_name CharmData
extends RefCounted

## Tum charm tanimlari. GDD'deki degerler.
## Kategoriler: basic (ucuz, erken oyun), key (bilet acma), power (pahali, gec oyun)

const CHARMS := {
	# --- Temel Charm'lar ---
	"sans_tokasi": {
		"name": "Sans Tokasi",
		"description": "Eslesme odulu +%{value}",
		"cost": 3,
		"max_level": 20,
		"category": "basic",
		"effect_per_level": 10,
	},
	"zengin_baslangic": {
		"name": "Zengin Baslangic",
		"description": "Baslangic parasi +{value} coin",
		"cost": 5,
		"max_level": 10,
		"category": "basic",
		"effect_per_level": 10,
	},
	"keskin_goz": {
		"name": "Keskin Goz",
		"description": "3'lu eslesme sansi +%{value}",
		"cost": 3,
		"max_level": 15,
		"category": "basic",
		"effect_per_level": 5,
	},
	"hizli_parmak": {
		"name": "Hizli Parmak",
		"description": "Kazima hizi +%{value}",
		"cost": 2,
		"max_level": 10,
		"category": "basic",
		"effect_per_level": 10,
	},
	# --- Orta Charm'lar ---
	"sansli_yildiz": {
		"name": "Sansli Yildiz",
		"description": "Ozel sembol sansi +%{value}",
		"cost": 8,
		"max_level": 5,
		"category": "mid",
		"effect_per_level": 4,
	},
	"ikinci_sans": {
		"name": "Ikinci Sans",
		"description": "Eslesme yoksa tekrar cekme %{value}",
		"cost": 12,
		"max_level": 5,
		"category": "mid",
		"effect_per_level": 10,
	},
	"hazine_avcisi": {
		"name": "Hazine Avcisi",
		"description": "Koleksiyon dusme sansi +%{value}",
		"cost": 10,
		"max_level": 5,
		"category": "mid",
		"effect_per_level": 20,
	},
	"cifte_sans": {
		"name": "Cifte Sans",
		"description": "4+ eslesmede ekstra +%{value} coin",
		"cost": 8,
		"max_level": 5,
		"category": "mid",
		"effect_per_level": 8,
	},
	"miknatis": {
		"name": "Miknatis",
		"description": "Sinerji sansi +%{value}",
		"cost": 12,
		"max_level": 5,
		"category": "mid",
		"effect_per_level": 6,
	},
	"erken_kus": {
		"name": "Erken Kus",
		"description": "Ilk bilet %{value} indirimli",
		"cost": 6,
		"max_level": 10,
		"category": "mid",
		"effect_per_level": 15,
	},
	"sans_carki": {
		"name": "Sans Carki",
		"description": "Her 5. bilette bonus olay +%{value}",
		"cost": 15,
		"max_level": 3,
		"category": "mid",
		"effect_per_level": 10,
	},
	"koleksiyoncu_ruhu": {
		"name": "Koleksiyoncu Ruhu",
		"description": "Koleksiyon dusunce +{value} CP",
		"cost": 10,
		"max_level": 5,
		"category": "mid",
		"effect_per_level": 1,
	},
	"combo_ustasi": {
		"name": "Combo Ustasi",
		"description": "Ardisik eslesme bonusu +%{value}",
		"cost": 15,
		"max_level": 5,
		"category": "mid",
		"effect_per_level": 5,
	},
	"dayaniklilik": {
		"name": "Dayaniklilik",
		"description": "Enerji yenilenme hizi +%{value}",
		"cost": 10,
		"max_level": 3,
		"category": "mid",
		"effect_per_level": 15,
	},
	"son_hamle": {
		"name": "Son Hamle",
		"description": "Coin < 20 ise bedava Paper bilet (tur basi {value}x)",
		"cost": 20,
		"max_level": 3,
		"category": "mid",
		"effect_per_level": 1,
	},
	# --- Guclu Charm'lar ---
	"joker_miknatisi": {
		"name": "Joker Miknatisi",
		"description": "Joker sembol sansi +%{value}",
		"cost": 10,
		"max_level": 5,
		"category": "power",
		"effect_per_level": 3,
	},
	"carpan_gucu": {
		"name": "Carpan Gucu",
		"description": "Carpan sembol sansi +%{value}",
		"cost": 15,
		"max_level": 5,
		"category": "power",
		"effect_per_level": 2,
	},
	"enerji_deposu": {
		"name": "Enerji Deposu",
		"description": "Max enerji +{value}",
		"cost": 20,
		"max_level": 3,
		"category": "power",
		"effect_per_level": 1,
	},
	"sinerji_radari": {
		"name": "Sinerji Radari",
		"description": "Sinerji sansi +%{value}",
		"cost": 10,
		"max_level": 10,
		"category": "power",
		"effect_per_level": 5,
	},
	"altinparmak": {
		"name": "Altinparmak",
		"description": "Tum oduller +%{value}",
		"cost": 25,
		"max_level": 10,
		"category": "power",
		"effect_per_level": 15,
	},
	"kral_dokunusu": {
		"name": "Kral Dokunusu",
		"description": "4+ eslesme odulu x{value}",
		"cost": 50,
		"max_level": 3,
		"category": "power",
		"effect_per_level": 2,
	},
	"yolo": {
		"name": "YOLO",
		"description": "%1 sansla odul x50",
		"cost": 40,
		"max_level": 1,
		"category": "power",
		"effect_per_level": 1,
	},
	"mega_baslangic": {
		"name": "Mega Baslangic",
		"description": "Baslangic parasi +{value} coin",
		"cost": 30,
		"max_level": 5,
		"category": "power",
		"effect_per_level": 50,
	},
}

## Charm gosterim sirasi
const CHARM_ORDER := [
	# Temel
	"sans_tokasi", "zengin_baslangic", "keskin_goz", "hizli_parmak",
	# Orta
	"sansli_yildiz", "ikinci_sans", "hazine_avcisi", "cifte_sans",
	"miknatis", "erken_kus", "sans_carki", "koleksiyoncu_ruhu",
	"combo_ustasi", "dayaniklilik", "son_hamle",
	# Guclu
	"joker_miknatisi", "carpan_gucu", "enerji_deposu", "sinerji_radari",
	"altinparmak", "kral_dokunusu", "yolo", "mega_baslangic",
]


static func get_charm(id: String) -> Dictionary:
	return CHARMS.get(id, {})


static func get_effect_text(id: String, level: int) -> String:
	var charm: Dictionary = CHARMS.get(id, {})
	if charm.is_empty():
		return ""
	var desc: String = charm["description"]
	if "{value}" in desc:
		var total_value: int = charm["effect_per_level"] * max(level, 1)
		return desc.replace("{value}", str(total_value))
	return desc
