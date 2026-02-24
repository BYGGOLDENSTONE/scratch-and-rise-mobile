extends RefCounted

## Premium tema sistemi — Light/Dark palet destegi.
## Static fonksiyonlar — autoload degil, preload ile kullanilir.

enum ThemeMode { DARK, LIGHT }

static var current_theme: ThemeMode = ThemeMode.DARK

# --- DARK PALET ---
const DARK_PALETTE := {
	"bg_main": Color(0.05, 0.05, 0.08),         # Daha derin, zengin bir siyah/mor
	"bg_panel": Color(0.09, 0.09, 0.13),        # Ince ayrım
	"bg_card": Color(0.12, 0.12, 0.17),         # Kartlar için asalet
	"primary": Color(0.20, 0.40, 0.95),         # Canlı ve güven veren Casino Mavisi
	"secondary": Color(0.60, 0.15, 0.85),       # Asil Mor
	"success": Color(0.15, 0.85, 0.45),         # Zıplayan, taze yeşil (kazanç hissi)
	"warning": Color(1.0, 0.80, 0.15),          # Altın Sarısı
	"danger": Color(1.0, 0.25, 0.35),           # YOLO/Uyarı Kırmızısı
	"info": Color(0.0, 0.85, 0.95),             # Neon Camgöbeği
	"text_primary": Color(0.98, 0.98, 1.0),
	"text_secondary": Color(0.70, 0.70, 0.75),
	"text_muted": Color(0.45, 0.45, 0.50),
	"topbar_bg": Color(0.07, 0.07, 0.10, 0.95),
	"topbar_border_alpha": 0.3,
	"border_alpha": 0.35,
	# Kart arka planlarında çok hafif tint 
	"tier_bg_paper": Color(0.10, 0.10, 0.11),
	"tier_bg_bronze": Color(0.14, 0.09, 0.05),
	"tier_bg_silver": Color(0.12, 0.14, 0.16),
	"tier_bg_gold": Color(0.16, 0.13, 0.04),
	"tier_bg_platinum": Color(0.14, 0.08, 0.18),
}

# --- LIGHT PALET ---
const LIGHT_PALETTE := {
	"bg_main": Color(0.95, 0.96, 0.98),         # Temiz, ferah 
	"bg_panel": Color(1.0, 1.0, 1.0),
	"bg_card": Color(0.92, 0.94, 0.97),         
	"primary": Color(0.15, 0.35, 0.90),         # Parlak mavi
	"secondary": Color(0.50, 0.10, 0.80),
	"success": Color(0.10, 0.75, 0.35),
	"warning": Color(0.95, 0.65, 0.0),
	"danger": Color(0.90, 0.15, 0.25),
	"info": Color(0.05, 0.70, 0.85),
	"text_primary": Color(0.10, 0.10, 0.12),
	"text_secondary": Color(0.40, 0.40, 0.45),
	"text_muted": Color(0.65, 0.65, 0.70),
	"topbar_bg": Color(1.0, 1.0, 1.0, 0.95),
	"topbar_border_alpha": 0.15,
	"border_alpha": 0.20,
	# Light mode için yumuşak arka plan tabanları
	"tier_bg_paper": Color(0.90, 0.90, 0.92),
	"tier_bg_bronze": Color(0.97, 0.92, 0.86),
	"tier_bg_silver": Color(0.92, 0.93, 0.96),
	"tier_bg_gold": Color(0.98, 0.96, 0.85),
	"tier_bg_platinum": Color(0.94, 0.90, 0.98),
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


## Premium buton stili
static func make_button(btn: Button, accent: Color = Color.TRANSPARENT, font_size: int = 16) -> void:
	if accent == Color.TRANSPARENT:
		accent = p("primary")

	var bg_base := p("bg_card")
	var border_a := pf("border_alpha")

	# Normal
	var normal := StyleBoxFlat.new()
	if is_dark():
		normal.bg_color = Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.12, 0.85)
	else:
		normal.bg_color = Color(accent.r * 0.06 + 0.92, accent.g * 0.06 + 0.92, accent.b * 0.06 + 0.92, 1.0)
	normal.border_color = Color(accent.r, accent.g, accent.b, border_a + 0.15)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 12.0
	normal.content_margin_right = 12.0
	normal.content_margin_top = 8.0
	normal.content_margin_bottom = 8.0
	btn.add_theme_stylebox_override("normal", normal)

	# Hover
	var hover := normal.duplicate()
	if is_dark():
		hover.bg_color = Color(accent.r * 0.18, accent.g * 0.18, accent.b * 0.18, 0.9)
	else:
		hover.bg_color = Color(accent.r * 0.10 + 0.88, accent.g * 0.10 + 0.88, accent.b * 0.10 + 0.88, 1.0)
	hover.border_color = Color(accent.r, accent.g, accent.b, border_a + 0.25)
	btn.add_theme_stylebox_override("hover", hover)

	# Pressed
	var pressed := normal.duplicate()
	if is_dark():
		pressed.bg_color = Color(accent.r * 0.25, accent.g * 0.25, accent.b * 0.25, 0.95)
	else:
		pressed.bg_color = Color(accent.r * 0.15 + 0.82, accent.g * 0.15 + 0.82, accent.b * 0.15 + 0.82, 1.0)
	btn.add_theme_stylebox_override("pressed", pressed)

	# Disabled
	var disabled := StyleBoxFlat.new()
	disabled.bg_color = Color(p("bg_panel").r, p("bg_panel").g, p("bg_panel").b, 0.7)
	disabled.border_color = Color(p("text_muted").r, p("text_muted").g, p("text_muted").b, 0.2)
	disabled.set_border_width_all(1)
	disabled.set_corner_radius_all(10)
	disabled.content_margin_left = 12.0
	disabled.content_margin_right = 12.0
	disabled.content_margin_top = 8.0
	disabled.content_margin_bottom = 8.0
	btn.add_theme_stylebox_override("disabled", disabled)

	# Font renkleri
	btn.add_theme_color_override("font_color", accent)
	btn.add_theme_color_override("font_hover_color", accent)
	btn.add_theme_color_override("font_pressed_color", p("text_primary"))
	btn.add_theme_color_override("font_disabled_color", p("text_muted"))
	btn.add_theme_font_size_override("font_size", font_size)


## Premium panel stili
static func make_panel(panel: PanelContainer, border_color: Color = Color.TRANSPARENT, bg: Color = Color.TRANSPARENT) -> void:
	if border_color == Color.TRANSPARENT:
		border_color = p("primary")
	if bg == Color.TRANSPARENT:
		bg = p("bg_panel")

	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Color(border_color.r, border_color.g, border_color.b, pf("border_alpha"))
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
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


## Kart/item paneli stili
static func make_card(panel: PanelContainer, border_color: Color = Color.TRANSPARENT) -> void:
	if border_color == Color.TRANSPARENT:
		border_color = p("info")

	var style := StyleBoxFlat.new()
	style.bg_color = p("bg_card")
	style.border_color = Color(border_color.r, border_color.g, border_color.b, pf("border_alpha"))
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
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


## Top bar paneli stillendir
static func style_top_bar(panel: PanelContainer) -> void:
	var accent := p("primary")
	var style := StyleBoxFlat.new()
	style.bg_color = p("topbar_bg")
	style.border_color = Color(accent.r, accent.g, accent.b, pf("topbar_border_alpha"))
	style.border_width_bottom = 1
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	panel.add_theme_stylebox_override("panel", style)


## Warning label stili
static func style_warning(label: Label) -> void:
	label.add_theme_color_override("font_color", p("danger"))
	label.add_theme_font_size_override("font_size", 18)
