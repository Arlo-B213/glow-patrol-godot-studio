class_name UiCards
extends RefCounted
## Shared card builders for hub, intro and result screens (Story 013).
## Everything is styled through UiTheme variations (ModeCard, CardPanel,
## PrimaryButton, SecondaryButton, Title, Heading, Muted, Caption).


## Rounded dark tile with a coloured border/glow and a centred UiIcon.
static func icon_tile(icon: String, color: Color, tile_px: int = 64) -> PanelContainer:
	var tile := PanelContainer.new()
	tile.custom_minimum_size = Vector2(tile_px, tile_px)
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := UiTheme.box(UiTheme.BG.lerp(color, 0.16), color, 2, int(tile_px * 0.28), 0, 0, 0)
	sb.shadow_size = 8
	sb.shadow_color = Color(color.r, color.g, color.b, 0.3)
	sb.shadow_offset = Vector2.ZERO
	tile.add_theme_stylebox_override("panel", sb)
	var ic := UiIcon.new().setup(icon, color, tile_px * 0.62)
	ic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tile.add_child(ic)
	return tile


static func _label(text: String, variation: String, align: int = HORIZONTAL_ALIGNMENT_LEFT,
		color: Variant = null, wrap: bool = false) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.theme_type_variation = variation
	lbl.horizontal_alignment = align as HorizontalAlignment
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if color != null:
		lbl.add_theme_color_override("font_color", color as Color)
	if wrap:
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return lbl


## Builds the icon tile + text (+ chevron) layout inside an existing Button and
## gives it the ModeCard look. `compact` uses a smaller tile and caption text.
static func fill_card(btn: Button, icon: String, icon_color: Color, title: String, desc: String,
		best_text: String, compact: bool = false) -> void:
	btn.text = ""
	btn.theme_type_variation = "ModeCard"
	btn.focus_mode = Control.FOCUS_NONE
	btn.toggle_mode = false
	btn.custom_minimum_size.y = maxf(btn.custom_minimum_size.y, 96.0 if compact else 104.0)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8 if compact else 10)
	btn.add_child(margin)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10 if compact else 14)
	margin.add_child(row)
	row.add_child(icon_tile(icon, icon_color, 52 if compact else 64))
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)
	col.add_child(_label(title, "Heading", HORIZONTAL_ALIGNMENT_LEFT, null, true))
	col.add_child(_label(desc, "Caption" if compact else "Muted", HORIZONTAL_ALIGNMENT_LEFT, null, true))
	if best_text != "":
		col.add_child(_label(best_text, "Caption", HORIZONTAL_ALIGNMENT_LEFT, UiTheme.GOLD))
	if not compact:
		var chev := UiIcon.new().setup("forward", UiTheme.TEXT_MUTED, 20)
		chev.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(chev)


## Large tap-target mode card: icon tile, title, left-aligned description,
## gold best-score caption and a chevron. Calls `on_pressed` when tapped.
static func mode_card(icon: String, icon_color: Color, title: String, desc: String,
		best_text: String, on_pressed: Callable) -> Button:
	var btn := Button.new()
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fill_card(btn, icon, icon_color, title, desc, best_text)
	btn.pressed.connect(on_pressed)
	return btn


## Full-rect holder whose single CardPanel hugs its content at the top.
## `box_out` receives the VBoxContainer to fill.
static func _shell(box_out: Array) -> Control:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var outer := VBoxContainer.new()
	outer.set_anchors_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("separation", 0)
	root.add_child(outer)
	var gap := Control.new()
	gap.custom_minimum_size.y = 16
	outer.add_child(gap)
	var panel := PanelContainer.new()
	panel.theme_type_variation = "CardPanel"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	panel.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)
	box_out.append(vbox)
	return root


static func _hero(vbox: VBoxContainer, icon: String, color: Color) -> void:
	var tile := icon_tile(icon, color, 104)
	tile.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(tile)


static func _buttons(vbox: VBoxContainer, primary_text: String, on_primary: Callable,
		secondary_text: String, on_secondary: Callable) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 4
	vbox.add_child(spacer)
	var primary := Button.new()
	primary.text = primary_text
	primary.theme_type_variation = "PrimaryButton"
	primary.focus_mode = Control.FOCUS_NONE
	primary.custom_minimum_size.y = 56
	primary.pressed.connect(on_primary)
	vbox.add_child(primary)
	var secondary := Button.new()
	secondary.text = secondary_text
	secondary.theme_type_variation = "SecondaryButton"
	secondary.focus_mode = Control.FOCUS_NONE
	secondary.custom_minimum_size.y = 56
	secondary.pressed.connect(on_secondary)
	vbox.add_child(secondary)


## Pre-game intro card sized to its content, centred near the top.
static func intro_card(hero_icon: String, hero_color: Color, eyebrow: String, heading: String,
		body: String, best_text: String, primary_text: String, on_primary: Callable,
		secondary_text: String, on_secondary: Callable) -> Control:
	var out: Array = []
	var root := _shell(out)
	var vbox: VBoxContainer = out[0]
	_hero(vbox, hero_icon, hero_color)
	var c := HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_label(eyebrow, "Caption", c, UiTheme.GOLD))
	vbox.add_child(_label(heading, "Title", c, null, true))
	vbox.add_child(_label(body, "Muted", c, null, true))
	if best_text != "":
		vbox.add_child(_label(best_text, "Caption", c, UiTheme.GOLD))
	_buttons(vbox, primary_text, on_primary, secondary_text, on_secondary)
	return root


## Result card: hero star, heading, score line and big earned-stars readout.
static func result_card(hero_icon: String, heading: String, score_text: String, stars_earned: int,
		primary_text: String, on_primary: Callable, secondary_text: String,
		on_secondary: Callable) -> Control:
	var out: Array = []
	var root := _shell(out)
	var vbox: VBoxContainer = out[0]
	_hero(vbox, hero_icon, UiTheme.GOLD)
	var c := HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_label(heading, "Title", c, null, true))
	vbox.add_child(_label(score_text, "Muted", c, null, true))
	var stars := HBoxContainer.new()
	stars.alignment = BoxContainer.ALIGNMENT_CENTER
	stars.add_theme_constant_override("separation", 8)
	stars.add_child(UiIcon.new().setup("star", UiTheme.GOLD, 40))
	var num := _label("+%d" % stars_earned, "Title", c, UiTheme.GOLD)
	num.add_theme_font_size_override("font_size", 36)
	stars.add_child(num)
	vbox.add_child(stars)
	_buttons(vbox, primary_text, on_primary, secondary_text, on_secondary)
	return root
