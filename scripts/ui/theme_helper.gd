extends RefCounted

## Premium tema sistemi — Light/Dark palet destegi.
## Static fonksiyonlar — autoload degil, preload ile kullanilir.

enum ThemeMode { DARK, LIGHT }

static var current_theme: ThemeMode = ThemeMode.DARK

# --- DARK PALET ---
const DARK_PALETTE := {
	"bg_main": Color(0.08, 0.08, 0.11),         # Yumusak koyu — goz yormayan
	"bg_panel": Color(0.12, 0.12, 0.16),        # Panel ayrimini belirginlestir
	"bg_card": Color(0.15, 0.15, 0.20),         # Kartlar belirgin
	"primary": Color(0.35, 0.55, 0.95),         # Yumusak mavi — daha okunur
	"secondary": Color(0.55, 0.30, 0.80),       # Yumusak mor — goz yormaz
	"success": Color(0.25, 0.78, 0.50),         # Soft yesil — parlak ama rahat
	"warning": Color(0.95, 0.78, 0.25),         # Sicak altin — goz dostu
	"danger": Color(0.95, 0.35, 0.40),          # Yumusak kirmizi
	"info": Color(0.20, 0.75, 0.88),            # Soft camgobeği — neon degil
	"text_primary": Color(0.92, 0.93, 0.96),
	"text_secondary": Color(0.62, 0.63, 0.68),
	"text_muted": Color(0.42, 0.42, 0.48),
	"topbar_bg": Color(0.10, 0.10, 0.14, 0.96),
	"topbar_border_alpha": 0.25,
	"border_alpha": 0.30,
	# Kart arka planlarinda belirgin tint
	"tier_bg_paper": Color(0.13, 0.13, 0.15),
	"tier_bg_bronze": Color(0.16, 0.12, 0.08),
	"tier_bg_silver": Color(0.14, 0.16, 0.19),
	"tier_bg_gold": Color(0.18, 0.16, 0.08),
	"tier_bg_platinum": Color(0.16, 0.12, 0.22),
}

# --- LIGHT PALET ---
const LIGHT_PALETTE := {
	"bg_main": Color(0.94, 0.95, 0.97),         # Hafif soguk gri — temiz
	"bg_panel": Color(0.99, 0.99, 1.0),         # Beyaza yakin — panel ayrim
	"bg_card": Color(0.91, 0.92, 0.95),         # Belirgin kart arka plan
	"primary": Color(0.20, 0.40, 0.85),         # Koyu mavi — okunur
	"secondary": Color(0.45, 0.15, 0.70),       # Koyu mor — kontrast iyi
	"success": Color(0.12, 0.62, 0.35),         # Koyu yesil — acik bg'de okunur
	"warning": Color(0.82, 0.58, 0.0),          # Koyu altin — beyazda kontrast
	"danger": Color(0.82, 0.18, 0.25),          # Koyu kirmizi
	"info": Color(0.08, 0.55, 0.72),            # Koyu camgobeği — okunur
	"text_primary": Color(0.12, 0.12, 0.15),
	"text_secondary": Color(0.38, 0.38, 0.42),
	"text_muted": Color(0.58, 0.58, 0.62),
	"topbar_bg": Color(0.99, 0.99, 1.0, 0.96),
	"topbar_border_alpha": 0.18,
	"border_alpha": 0.28,
	# Light mode icin belirgin arka plan tabanları
	"tier_bg_paper": Color(0.88, 0.88, 0.90),
	"tier_bg_bronze": Color(0.95, 0.90, 0.84),
	"tier_bg_silver": Color(0.90, 0.91, 0.94),
	"tier_bg_gold": Color(0.96, 0.93, 0.82),
	"tier_bg_platinum": Color(0.92, 0.88, 0.96),
}

# Bilet tier aksanlari (tema-bagimsiz)
const TIER_COLORS := {
	"paper": Color(0.60, 0.60, 0.65),     # Daha nötr gri
	"bronze": Color(0.85, 0.55, 0.25),    # Daha parlak bakır
	"silver": Color(0.75, 0.80, 0.85),    # Daha mavi-buzlu gümüş
	"gold": Color(1.0, 0.82, 0.10),       # Daha canlı, klasik casino altını
	"platinum": Color(0.70, 0.40, 1.0),   # Yoğun, doymuş platin moru
}


## Aktif paletten renk al
static func p(key: String) -> Color:
	var palette: Dictionary = DARK_PALETTE if current_theme == ThemeMode.DARK else LIGHT_PALETTE
	var val = palette.get(key)
	if val is Color:
		return val
	return Color.MAGENTA


## Aktif paletten float deger al (alpha vb.)
static func pf(key: String) -> float:
	var palette: Dictionary = DARK_PALETTE if current_theme == ThemeMode.DARK else LIGHT_PALETTE
	return float(palette.get(key, 1.0))


## Tema degistir
static func set_theme(theme: ThemeMode) -> void:
	current_theme = theme


## Karanlik tema mi?
static func is_dark() -> bool:
	return current_theme == ThemeMode.DARK


# =======================================================
#  STIL FONKSIYONLARI
# =======================================================


## Premium buton stili — belirgin, okunur, soft
static func make_button(btn: Button, accent: Color = Color.TRANSPARENT, font_size: int = 16) -> void:
	if accent == Color.TRANSPARENT:
		accent = p("primary")

	var border_a := pf("border_alpha")

	# Normal — belirgin arka plan (light modda daha guclu tint)
	var normal := StyleBoxFlat.new()
	if is_dark():
		normal.bg_color = Color(accent.r * 0.15 + 0.04, accent.g * 0.15 + 0.04, accent.b * 0.15 + 0.04, 0.90)
	else:
		normal.bg_color = Color(accent.r * 0.18 + 0.78, accent.g * 0.18 + 0.78, accent.b * 0.18 + 0.78, 1.0)
	normal.border_color = Color(accent.r, accent.g, accent.b, border_a + 0.25)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(12)
	normal.content_margin_left = 14.0
	normal.content_margin_right = 14.0
	normal.content_margin_top = 10.0
	normal.content_margin_bottom = 10.0
	btn.add_theme_stylebox_override("normal", normal)

	# Hover — daha parlak
	var hover := normal.duplicate()
	if is_dark():
		hover.bg_color = Color(accent.r * 0.22 + 0.05, accent.g * 0.22 + 0.05, accent.b * 0.22 + 0.05, 0.93)
	else:
		hover.bg_color = Color(accent.r * 0.22 + 0.74, accent.g * 0.22 + 0.74, accent.b * 0.22 + 0.74, 1.0)
	hover.border_color = Color(accent.r, accent.g, accent.b, border_a + 0.35)
	btn.add_theme_stylebox_override("hover", hover)

	# Pressed — en parlak
	var pressed := normal.duplicate()
	if is_dark():
		pressed.bg_color = Color(accent.r * 0.30 + 0.06, accent.g * 0.30 + 0.06, accent.b * 0.30 + 0.06, 0.96)
	else:
		pressed.bg_color = Color(accent.r * 0.28 + 0.68, accent.g * 0.28 + 0.68, accent.b * 0.28 + 0.68, 1.0)
	btn.add_theme_stylebox_override("pressed", pressed)

	# Disabled
	var disabled := StyleBoxFlat.new()
	disabled.bg_color = Color(p("bg_panel").r, p("bg_panel").g, p("bg_panel").b, 0.6)
	disabled.border_color = Color(p("text_muted").r, p("text_muted").g, p("text_muted").b, 0.15)
	disabled.set_border_width_all(1)
	disabled.set_corner_radius_all(12)
	disabled.content_margin_left = 14.0
	disabled.content_margin_right = 14.0
	disabled.content_margin_top = 10.0
	disabled.content_margin_bottom = 10.0
	btn.add_theme_stylebox_override("disabled", disabled)

	# Font renkleri
	btn.add_theme_color_override("font_color", accent)
	btn.add_theme_color_override("font_hover_color", accent)
	btn.add_theme_color_override("font_pressed_color", p("text_primary"))
	btn.add_theme_color_override("font_disabled_color", p("text_muted"))
	btn.add_theme_font_size_override("font_size", font_size)


## Premium panel stili — belirgin ayrim
static func make_panel(panel: PanelContainer, border_color: Color = Color.TRANSPARENT, bg: Color = Color.TRANSPARENT) -> void:
	if border_color == Color.TRANSPARENT:
		border_color = p("primary")
	if bg == Color.TRANSPARENT:
		bg = p("bg_panel")

	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Color(border_color.r, border_color.g, border_color.b, pf("border_alpha") + 0.10)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	panel.add_theme_stylebox_override("panel", style)


## Baslik label stili
static func style_title(label: Label, color: Color = Color.TRANSPARENT, size: int = 32) -> void:
	if color == Color.TRANSPARENT:
		color = p("warning")
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", size)


## Normal label stili
static func style_label(label: Label, color: Color = Color.TRANSPARENT, size: int = 16) -> void:
	if color == Color.TRANSPARENT:
		color = p("text_primary")
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", size)


## Kart/item paneli stili — okunur border
static func make_card(panel: PanelContainer, border_color: Color = Color.TRANSPARENT) -> void:
	if border_color == Color.TRANSPARENT:
		border_color = p("info")

	var style := StyleBoxFlat.new()
	style.bg_color = p("bg_card")
	style.border_color = Color(border_color.r, border_color.g, border_color.b, pf("border_alpha") + 0.10)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override("panel", style)


## Bilet tier rengini dondur
static func get_tier_color(tier: String) -> Color:
	return TIER_COLORS.get(tier, p("success"))


## Bilet tier arka plan rengini dondur
static func get_tier_bg(tier: String) -> Color:
	return p("tier_bg_" + tier)


## Arka plan ColorRect stillendir
static func style_background(bg: ColorRect) -> void:
	bg.color = p("bg_main")


## Top bar paneli stillendir — soft alt golge
static func style_top_bar(panel: PanelContainer) -> void:
	var accent := p("primary")
	var style := StyleBoxFlat.new()
	style.bg_color = p("topbar_bg")
	style.border_color = Color(accent.r, accent.g, accent.b, pf("topbar_border_alpha") + 0.08)
	style.border_width_bottom = 2
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	style.content_margin_left = 20.0
	style.content_margin_right = 20.0
	style.content_margin_top = 16.0
	style.content_margin_bottom = 16.0
	# Soft golge efekti
	style.shadow_color = Color(0, 0, 0, 0.12 if is_dark() else 0.06)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 3)
	panel.add_theme_stylebox_override("panel", style)


## Warning label stili
static func style_warning(label: Label) -> void:
	label.add_theme_color_override("font_color", p("danger"))
	label.add_theme_font_size_override("font_size", 18)
