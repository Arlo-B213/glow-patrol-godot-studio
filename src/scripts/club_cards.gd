class_name ClubCards
extends RefCounted
## Card builders for the Clubhouse screen (Story 013): item cards with
## normal / equipped / locked states, colour chips, section headers and the
## Lounge friendship rows and dialogue view. Styled through UiTheme variations.

const STATE_NORMAL := "normal"
const STATE_EQUIPPED := "equipped"
const STATE_LOCKED := "locked"


static func _label(text: String, variation: String, align: int = HORIZONTAL_ALIGNMENT_CENTER,
		wrap: bool = true) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.theme_type_variation = variation
	lbl.horizontal_alignment = align as HorizontalAlignment
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if wrap:
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return lbl


## Rounded colour chip with a soft light border.
static func color_chip(color: Color, px: int = 36) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(px, px)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	chip.add_theme_stylebox_override("panel", UiTheme.box(color,
		Color(UiTheme.TEXT.r, UiTheme.TEXT.g, UiTheme.TEXT.b, 0.35), 2, int(px * 0.3), 0, 0, 0))
	return chip


## Small pill badge: "EQUIPPED" with a star on a teal fill.
static func equipped_badge() -> PanelContainer:
	var pill := PanelContainer.new()
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pill.add_theme_stylebox_override("panel", UiTheme.box(UiTheme.TEAL, UiTheme.TEAL.lightened(0.3), 1, 12, 8, 2, 2))
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 4)
	pill.add_child(row)
	var ic := UiIcon.new().setup("star", UiTheme.TEXT_ON_ACCENT, 14)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(ic)
	var lbl := _label("EQUIPPED", "Caption", HORIZONTAL_ALIGNMENT_CENTER, false)
	lbl.add_theme_color_override("font_color", UiTheme.TEXT_ON_ACCENT)  # special: dark text on teal pill
	row.add_child(lbl)
	return pill


## Lock-style price chip: star icon + cost.
static func price_chip(cost: int) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	chip.add_theme_stylebox_override("panel", UiTheme.box(UiTheme.BG, UiTheme.LOCKED, 1, 12, 8, 2, 2))
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 4)
	chip.add_child(row)
	var ic := UiIcon.new().setup("star", UiTheme.GOLD, 16)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(ic)
	var lbl := _label(str(cost), "Caption", HORIZONTAL_ALIGNMENT_CENTER, false)
	lbl.add_theme_color_override("font_color", UiTheme.GOLD)  # special: price text
	row.add_child(lbl)
	return chip


## Card variation name for an item state.
static func panel_variation(state: String) -> String:
	match state:
		STATE_EQUIPPED:
			return "CardPanelEquipped"
		STATE_LOCKED:
			return "CardPanelLocked"
	return "CardPanel"


## Selectable item card: thumbnail, name and a state line (EQUIPPED badge,
## price chip, or idle caption). A transparent button overlays the card.
static func item_card(thumb: Control, title: String, state: String, cost: int,
		idle_text: String, min_h: int, on_pressed: Callable) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = panel_variation(state)
	card.custom_minimum_size = Vector2(0, maxi(min_h, 96))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 4)
	card.add_child(col)
	if thumb != null:
		thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var cc := CenterContainer.new()
		cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cc.add_child(thumb)
		col.add_child(cc)
	col.add_child(_label(title, "Muted" if state == STATE_LOCKED else "Label"))
	match state:
		STATE_EQUIPPED:
			col.add_child(equipped_badge())
		STATE_LOCKED:
			col.add_child(price_chip(cost))
		_:
			col.add_child(_label(idle_text, "Caption"))
	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.flat = true
	var empty := StyleBoxEmpty.new()
	for sname in ["normal", "hover", "pressed", "focus", "disabled"]:
		btn.add_theme_stylebox_override(sname, empty)
	btn.pressed.connect(on_pressed)
	card.add_child(btn)
	return card


## Heading with a small coloured accent bar to its left.
static func section_header(text: String, color: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var bar := PanelContainer.new()
	bar.custom_minimum_size = Vector2(5, 22)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.add_theme_stylebox_override("panel", UiTheme.box(color, Color(0, 0, 0, 0), 0, 3, 0, 0, 0))
	row.add_child(bar)
	row.add_child(_label(text, "Heading", HORIZONTAL_ALIGNMENT_LEFT, false))
	return row


## Friendship meter row: heart icon, ProgressBar, percentage. The bar and
## percentage label are stored as meta "bar" / "pct".
static func friend_meter(value: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 6)
	var heart := UiIcon.new().setup("heart", UiTheme.ACCENT, 16)
	heart.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(heart)
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.value = value
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 10)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(bar)
	var pct := _label("%d%%" % value, "Caption", HORIZONTAL_ALIGNMENT_RIGHT, false)
	pct.custom_minimum_size.x = 40
	row.add_child(pct)
	row.set_meta("bar", bar)
	row.set_meta("pct", pct)
	return row


## Updates a meter made by friend_meter.
static func set_meter(meter: HBoxContainer, value: int) -> void:
	(meter.get_meta("bar") as ProgressBar).value = value
	(meter.get_meta("pct") as Label).text = "%d%%" % value


## Lounge list row card for one Lanternboy.
static func lounge_row(boy: Dictionary, affection: int, on_pressed: Callable) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = "CardPanel"
	card.custom_minimum_size = Vector2(0, 88)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)
	var tile := portrait_tile(String(boy["id"]), Color(boy["color"]), Vector2(72, 72), 16)
	tile.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(tile)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)
	col.add_child(_label(boy["name"], "Heading", HORIZONTAL_ALIGNMENT_LEFT, false))
	col.add_child(_label(boy["role"], "Muted", HORIZONTAL_ALIGNMENT_LEFT))
	col.add_child(friend_meter(affection))
	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.flat = true
	var empty := StyleBoxEmpty.new()
	for sname in ["normal", "hover", "pressed", "focus", "disabled"]:
		btn.add_theme_stylebox_override(sname, empty)
	btn.pressed.connect(on_pressed)
	card.add_child(btn)
	return card


## Builds the Lanternboy dialogue card into `parent`. Returns
## {"line": Label, "meter": HBoxContainer} for the high-five handler.
static func dialogue_view(parent: Control, boy: Dictionary, line: String, affection: int,
		on_back: Callable, on_five: Callable, scene_text: String = "", on_scene: Callable = Callable()) -> Dictionary:
	var stage := portrait_tile(String(boy["id"]), Color(boy["color"]), Vector2(220, 260), 22)
	stage.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	parent.add_child(stage)
	parent.add_child(_label(boy["name"], "Heading"))
	parent.add_child(_label(boy["role"], "Muted"))
	var bubble := PanelContainer.new()
	bubble.theme_type_variation = "CardPanel"
	parent.add_child(bubble)
	var line_lbl := _label("\"%s\"" % line, "Heading")
	line_lbl.add_theme_font_size_override("font_size", UiTheme.BODY + 2)
	bubble.add_child(line_lbl)
	var meter := friend_meter(affection)
	parent.add_child(meter)
	var five := Button.new()
	five.text = "High five"
	five.theme_type_variation = "PrimaryButton"
	five.focus_mode = Control.FOCUS_NONE
	five.custom_minimum_size.y = 56
	five.pressed.connect(on_five)
	parent.add_child(five)
	if scene_text != "":
		var scene := Button.new()
		scene.text = scene_text
		scene.theme_type_variation = "SecondaryButton"
		scene.focus_mode = Control.FOCUS_NONE
		scene.custom_minimum_size.y = 56
		scene.pressed.connect(on_scene)
		parent.add_child(scene)
	var back := Button.new()
	back.text = "Back"
	back.theme_type_variation = "SecondaryButton"
	back.focus_mode = Control.FOCUS_NONE
	back.custom_minimum_size.y = 48
	back.pressed.connect(on_back)
	parent.add_child(back)
	return {"line": line_lbl, "meter": meter, "portrait": stage.get_child(0)}


## Dark rounded tile with an accent border/glow holding a LanternboyPortrait (clipped).
static func portrait_tile(boy_id: String, accent: Color, px: Vector2, radius: int = 16) -> PanelContainer:
	var tile := PanelContainer.new()
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.clip_contents = true
	tile.custom_minimum_size = px
	var sb: StyleBox = UiTheme.box(Color(0.09, 0.05, 0.17), accent, 2, radius, 0, 0, 0)
	if sb is StyleBoxFlat:
		(sb as StyleBoxFlat).shadow_color = Color(accent.r, accent.g, accent.b, 0.3)
		(sb as StyleBoxFlat).shadow_size = 8
	tile.add_theme_stylebox_override("panel", sb)
	tile.add_child(LanternboyPortrait.new().setup(boy_id, px.x, px.y))
	return tile
