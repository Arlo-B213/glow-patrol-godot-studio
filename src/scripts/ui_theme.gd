class_name UiTheme
extends RefCounted
## Central palette, type scale and Theme builder for Glowstick Patrol.
## Built-in font only, StyleBoxFlat only (Compatibility renderer friendly).
## Change ACCENT / ACCENT_DARK here and buttons, tabs and bars follow.

# --- Palette (defined once) ---
const BG := Color("#130D2B")
const PANEL := Color("#2C2050")
const PANEL_LIGHT := Color("#3F3070")
const ACCENT := Color("#FF5FA2")
const ACCENT_DARK := Color("#D93F85")
const GOLD := Color("#FFC15E")
const TEAL := Color("#52E8C6")
const VIOLET := Color("#8E7CFF")
const TEXT := Color("#F5EFFF")
const TEXT_MUTED := Color("#B9A9E0")
const TEXT_ON_ACCENT := Color("#2A0A18")
const LOCKED := Color("#6E6490")

# --- Type scale (px at 720x1280) ---
const TITLE := 24
const HEADING := 18
const BODY := 14
const CAPTION := 12

const RADIUS := 14
const MIN_TOUCH := 56  ## minimum tappable height (px) for buttons and cards (Story 022)
const BUTTON_PAD_V := 15  ## vertical content margin -> buttons >= 48 px tall


## Raises a button's minimum height to MIN_TOUCH (opt out with meta "no_touch_min").
static func ensure_touch(btn: Button) -> void:
	if is_instance_valid(btn) and not btn.has_meta("no_touch_min") 			and btn.custom_minimum_size.y < MIN_TOUCH:
		btn.custom_minimum_size.y = MIN_TOUCH


## Builds the shared Theme with all type variations.
static func build() -> Theme:
	var t := Theme.new()
	t.default_font_size = BODY
	_build_labels(t)
	_build_buttons(t)
	_build_panels(t)
	_build_bars(t)
	return t


## Creates a rounded StyleBoxFlat with optional border and shadow.
static func box(bg: Color, border: Color = Color(0, 0, 0, 0), border_w: int = 0,
		radius: int = RADIUS, pad_h: int = 14, pad_top: int = BUTTON_PAD_V,
		pad_bottom: int = BUTTON_PAD_V, shadow: int = 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	sb.set_border_width_all(border_w)
	sb.border_color = border
	sb.content_margin_left = pad_h
	sb.content_margin_right = pad_h
	sb.content_margin_top = pad_top
	sb.content_margin_bottom = pad_bottom
	sb.anti_aliasing = true
	if shadow > 0:
		sb.shadow_size = shadow
		sb.shadow_color = Color(0.02, 0.0, 0.08, 0.3)
		sb.shadow_size = shadow + 3
		sb.shadow_offset = Vector2(0, 3)
	return sb


static func _focus_box(radius: int = RADIUS) -> StyleBoxFlat:
	var sb := box(Color(0, 0, 0, 0), GOLD, 2, radius, 14, BUTTON_PAD_V, BUTTON_PAD_V)
	sb.draw_center = false
	return sb


static func _set_label_variation(t: Theme, vname: String, size: int, color: Color) -> void:
	t.add_type(vname)
	t.set_type_variation(vname, &"Label")
	t.set_font_size("font_size", vname, size)
	t.set_color("font_color", vname, color)


static func _build_labels(t: Theme) -> void:
	t.set_color("font_color", "Label", TEXT)
	t.set_font_size("font_size", "Label", BODY)
	_set_label_variation(t, "Title", TITLE, TEXT)
	_set_label_variation(t, "Heading", HEADING, TEXT)
	_set_label_variation(t, "Caption", CAPTION, TEXT_MUTED)
	_set_label_variation(t, "Muted", BODY, TEXT_MUTED)


static func _apply_button_states(t: Theme, vname: String, normal: StyleBox, hover: StyleBox,
		pressed: StyleBox, disabled: StyleBox, colors: Dictionary, size: int) -> void:
	t.set_stylebox("normal", vname, normal)
	t.set_stylebox("hover", vname, hover)
	t.set_stylebox("pressed", vname, pressed)
	t.set_stylebox("hover_pressed", vname, pressed)
	t.set_stylebox("disabled", vname, disabled)
	t.set_stylebox("focus", vname, _focus_box())
	t.set_font_size("font_size", vname, size)
	for key in colors.keys():
		t.set_color(key, vname, colors[key])


static func _color_set(normal: Color, hover: Color, pressed: Color, disabled: Color) -> Dictionary:
	return {
		"font_color": normal, "font_hover_color": hover, "font_pressed_color": pressed,
		"font_hover_pressed_color": pressed, "font_focus_color": normal,
		"font_disabled_color": disabled,
	}


static func _build_buttons(t: Theme) -> void:
	# Base "Button" = secondary look.
	var sec_n := box(PANEL, PANEL_LIGHT, 2, RADIUS, 14, BUTTON_PAD_V, BUTTON_PAD_V, 3)
	var sec_h := box(PANEL.lightened(0.12), VIOLET, 2, RADIUS, 14, BUTTON_PAD_V, BUTTON_PAD_V, 3)
	var sec_p := box(PANEL.darkened(0.2), VIOLET, 2, RADIUS, 14, BUTTON_PAD_V + 1, BUTTON_PAD_V - 1)
	var sec_d := box(PANEL.darkened(0.25), PANEL, 2, RADIUS, 14, BUTTON_PAD_V, BUTTON_PAD_V)
	var sec_colors := _color_set(TEXT, TEXT, TEXT, LOCKED)
	_apply_button_states(t, "Button", sec_n, sec_h, sec_p, sec_d, sec_colors, BODY)
	t.add_type("SecondaryButton")
	t.set_type_variation("SecondaryButton", &"Button")
	_apply_button_states(t, "SecondaryButton", sec_n, sec_h, sec_p, sec_d, sec_colors, BODY)

	# Primary (pink accent, dark text, lighter border = top highlight).
	var hi := ACCENT.lightened(0.35)
	var pri_n := box(ACCENT, hi, 2, RADIUS, 18, BUTTON_PAD_V, BUTTON_PAD_V, 4)
	pri_n.shadow_color = Color(ACCENT, 0.42)
	pri_n.shadow_size = 9
	var pri_h := box(ACCENT.lightened(0.12), hi, 2, RADIUS, 18, BUTTON_PAD_V, BUTTON_PAD_V, 4)
	pri_h.shadow_color = Color(ACCENT, 0.6)
	pri_h.shadow_size = 12
	var pri_p := box(ACCENT_DARK, ACCENT, 2, RADIUS, 18, BUTTON_PAD_V + 1, BUTTON_PAD_V - 1)
	var gray_pink := ACCENT.lerp(LOCKED, 0.75)
	var pri_d := box(gray_pink.darkened(0.3), LOCKED, 2, RADIUS, 18, BUTTON_PAD_V, BUTTON_PAD_V)
	t.add_type("PrimaryButton")
	t.set_type_variation("PrimaryButton", &"Button")
	_apply_button_states(t, "PrimaryButton", pri_n, pri_h, pri_p, pri_d,
		_color_set(TEXT_ON_ACCENT, TEXT_ON_ACCENT, TEXT_ON_ACCENT, TEXT_MUTED), HEADING)

	# Tab: flat dark; `pressed` = SELECTED (accent tint + accent border, text in TEXT).
	var tab_n := box(BG.lightened(0.05), Color(0, 0, 0, 0), 0, 10, 4, 12, 12)
	var tab_h := box(PANEL, Color(0, 0, 0, 0), 0, 10, 4, 12, 12)
	var sel := box(ACCENT.darkened(0.55), ACCENT, 2, 10, 4, 12, 12, 3)
	sel.border_width_bottom = 4
	sel.shadow_color = Color(ACCENT, 0.5)
	sel.shadow_size = 10
	sel.shadow_offset = Vector2(0, 0)
	var tab_d := box(BG, Color(0, 0, 0, 0), 0, 10, 4, 12, 12)
	t.add_type("TabButton")
	t.set_type_variation("TabButton", &"Button")
	_apply_button_states(t, "TabButton", tab_n, tab_h, sel, tab_d,
		_color_set(TEXT_MUTED, TEXT, TEXT, LOCKED), BODY)
	t.set_stylebox("focus", "TabButton", _focus_box(10))

	# ModeCard: large tappable card (icon tile + text built inside by UiCards).
	var mc_n := box(PANEL, PANEL_LIGHT, 2, 18, 12, 12, 12, 4)
	var mc_h := box(PANEL.lightened(0.1), VIOLET, 2, 18, 12, 12, 12, 5)
	var mc_p := box(PANEL.darkened(0.2), ACCENT, 2, 18, 12, 12, 12)
	var mc_d := box(PANEL.darkened(0.3), LOCKED.darkened(0.3), 1, 18, 12, 12, 12)
	t.add_type("ModeCard")
	t.set_type_variation("ModeCard", &"Button")
	_apply_button_states(t, "ModeCard", mc_n, mc_h, mc_p, mc_d,
		_color_set(TEXT, TEXT, TEXT, LOCKED), BODY)
	t.set_stylebox("focus", "ModeCard", _focus_box(18))


static func _panel_variation(t: Theme, vname: String, sb: StyleBox) -> void:
	t.add_type(vname)
	t.set_type_variation(vname, &"PanelContainer")
	t.set_stylebox("panel", vname, sb)


static func _build_panels(t: Theme) -> void:
	var card := box(PANEL, PANEL_LIGHT, 2, 18, 14, 14, 14, 4)
	card.border_color = PANEL_LIGHT.lightened(0.12)
	_panel_variation(t, "CardPanel", card)
	_panel_variation(t, "CardPanelEquipped", box(PANEL.lightened(0.05), TEAL, 2, 18, 14, 14, 14, 6))
	_panel_variation(t, "CardPanelLocked", box(PANEL.darkened(0.3), LOCKED.darkened(0.3), 1, 18, 14, 14, 14))
	t.set_stylebox("panel", "PanelContainer", box(PANEL, PANEL_LIGHT, 1, 18, 14, 14, 14))


static func _build_bars(t: Theme) -> void:
	t.set_stylebox("background", "ProgressBar", box(BG.darkened(0.2), PANEL_LIGHT, 1, 10, 0, 0, 0))
	var fill := box(ACCENT, ACCENT.lightened(0.45), 2, 10, 0, 0, 0)
	fill.border_width_bottom = 0
	fill.shadow_color = Color(ACCENT, 0.5)
	fill.shadow_size = 6
	fill.shadow_offset = Vector2.ZERO
	t.set_stylebox("fill", "ProgressBar", fill)
	t.set_color("font_color", "ProgressBar", TEXT)
	t.set_font_size("font_size", "ProgressBar", CAPTION)

	var track := box(BG.darkened(0.2), Color(0, 0, 0, 0), 0, 8, 0, 0, 0)
	var grab := box(VIOLET.darkened(0.2), Color(0, 0, 0, 0), 0, 8, 0, 0, 0)
	var grab_h := box(VIOLET, Color(0, 0, 0, 0), 0, 8, 0, 0, 0)
	var grab_p := box(ACCENT, Color(0, 0, 0, 0), 0, 8, 0, 0, 0)
	for bar in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox("scroll", bar, track)
		t.set_stylebox("scroll_focus", bar, track)
		t.set_stylebox("grabber", bar, grab)
		t.set_stylebox("grabber_highlight", bar, grab_h)
		t.set_stylebox("grabber_pressed", bar, grab_p)
	t.set_stylebox("panel", "ScrollContainer", StyleBoxEmpty.new())
