extends RefCounted

## Neon Casino tema yardimcisi.
## Static fonksiyonlar — autoload degil.

# --- RENKLER ---
const BG_DARK := Color(0.06, 0.04, 0.10)
const BG_PANEL := Color(0.10, 0.07, 0.16)
const BG_CARD := Color(0.12, 0.09, 0.20)

const NEON_GREEN := Color(0.2, 1.0, 0.4)
const NEON_GOLD := Color(1.0, 0.85, 0.1)
const NEON_CYAN := Color(0.2, 0.9, 1.0)
const NEON_PINK := Color(1.0, 0.3, 0.6)
const NEON_PURPLE := Color(0.7, 0.3, 1.0)
const NEON_RED := Color(1.0, 0.2, 0.2)

const TEXT_WHITE := Color(0.95, 0.95, 0.95)
const TEXT_DIM := Color(0.55, 0.50, 0.65)
const TEXT_MUTED := Color(0.4, 0.35, 0.5)

# Bilet tier renkleri
const TIER_COLORS := {
	"paper": Color(0.6, 0.58, 0.55),
	"bronze": Color(0.72, 0.45, 0.20),
	"silver": Color(0.75, 0.78, 0.82),
	"gold": Color(1.0, 0.82, 0.15),
	"platinum": Color(0.65, 0.35, 1.0),
}

const TIER_BG_COLORS := {
	"paper": Color(0.18, 0.17, 0.16),
	"bronze": Color(0.20, 0.14, 0.08),
	"silver": Color(0.18, 0.19, 0.22),
	"gold": Color(0.22, 0.18, 0.06),
	"platinum": Color(0.14, 0.08, 0.22),
}


## Neon glow'lu buton stili olustur
static func make_neon_button(btn: Button, color: Color = NEON_GREEN, font_size: int = 16) -> void:
	# Normal
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(color.r * 0.15, color.g * 0.15, color.b * 0.15, 0.9)
	normal.border_color = color
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	normal.content_margin_left = 12.0
	normal.content_margin_right = 12.0
	normal.content_margin_top = 8.0
	normal.content_margin_bottom = 8.0
	btn.add_theme_stylebox_override("normal", normal)

	# Hover
	var hover := normal.duplicate()
	hover.bg_color = Color(color.r * 0.25, color.g * 0.25, color.b * 0.25, 0.95)
	hover.border_color = Color(color.r, color.g, color.b, 1.0)
	btn.add_theme_stylebox_override("hover", hover)

	# Pressed
	var pressed := normal.duplicate()
	pressed.bg_color = Color(color.r * 0.35, color.g * 0.35, color.b * 0.35, 1.0)
	btn.add_theme_stylebox_override("pressed", pressed)

	# Disabled
	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.08, 0.06, 0.10, 0.7)
	disabled.border_color = Color(0.3, 0.25, 0.35, 0.5)
	btn.add_theme_stylebox_override("disabled", disabled)

	# Font renkleri
	btn.add_theme_color_override("font_color", color)
	btn.add_theme_color_override("font_hover_color", Color(color.r, color.g, color.b, 1.0))
	btn.add_theme_color_override("font_pressed_color", TEXT_WHITE)
	btn.add_theme_color_override("font_disabled_color", TEXT_MUTED)
	btn.add_theme_font_size_override("font_size", font_size)


## Neon panel stili olustur
static func make_neon_panel(panel: PanelContainer, border_color: Color = NEON_GREEN, bg: Color = BG_PANEL) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Color(border_color.r, border_color.g, border_color.b, 0.6)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override("panel", style)


## Neon baslik label'i
static func style_title_label(label: Label, color: Color = NEON_GOLD, size: int = 32) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", size)


## Normal label stili
static func style_label(label: Label, color: Color = TEXT_WHITE, size: int = 16) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", size)


## Neon glow'lu kart/item paneli
static func make_card_panel(panel: PanelContainer, border_color: Color = NEON_CYAN) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = BG_CARD
	style.border_color = Color(border_color.r, border_color.g, border_color.b, 0.4)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", style)


## Bilet tier rengini dondur
static func get_tier_color(tier: String) -> Color:
	return TIER_COLORS.get(tier, NEON_GREEN)


## Bilet tier arka plan rengini dondur
static func get_tier_bg(tier: String) -> Color:
	return TIER_BG_COLORS.get(tier, BG_PANEL)


## Arka plan ColorRect'ini renklendir
static func style_background(bg: ColorRect) -> void:
	bg.color = BG_DARK


## Top bar panelini stillendir
static func style_top_bar(panel: PanelContainer) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.06, 0.14, 0.95)
	style.border_color = Color(NEON_GREEN.r, NEON_GREEN.g, NEON_GREEN.b, 0.3)
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
	label.add_theme_color_override("font_color", NEON_RED)
	label.add_theme_font_size_override("font_size", 18)
