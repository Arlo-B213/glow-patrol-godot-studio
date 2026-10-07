class_name StickerPage
extends Control
## Sticker collection sub-view: a grid of badges; locked ones are grey with a hint.

signal closed

var _gs: Node


## Builds the page for `game_state`.
func setup(game_state: Node) -> StickerPage:
	_gs = game_state
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 12)
	add_child(root)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	root.add_child(head)
	var back := Button.new()
	back.text = "Back"
	back.theme_type_variation = "SecondaryButton"
	back.custom_minimum_size = Vector2(110, 56)
	back.focus_mode = Control.FOCUS_NONE
	back.pressed.connect(func(): Snd.play("tap"); closed.emit())
	head.add_child(back)
	var title := Label.new()
	title.text = "Stickers  %d/%d" % [(_gs.stickers as Array).size(), Stickers.STICKERS.size()]
	title.theme_type_variation = "Title"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)
	for s in Stickers.STICKERS:
		grid.add_child(_cell(s, (_gs.stickers as Array).has(s["id"])))
	return self


func _cell(s: Dictionary, earned: bool) -> Control:
	var panel := PanelContainer.new()
	panel.theme_type_variation = "CardPanel" if earned else "CardPanelLocked"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size.y = 190
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box)
	var badge := StickerBadge.new().setup(s["icon"], s["color"], earned)
	badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(badge)
	var name_l := Label.new()
	name_l.text = String(s["name"]) if earned else "Mystery sticker"
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_l.theme_type_variation = "Heading" if earned else "Muted"
	name_l.add_theme_font_size_override("font_size", UiTheme.BODY)
	box.add_child(name_l)
	var hint := Label.new()
	hint.text = "Earned!" if earned else String(s["hint"])
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.theme_type_variation = "Caption"
	box.add_child(hint)
	return panel
