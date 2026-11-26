class_name SettingsPage
extends Control
## Settings sub-view (Story 051). Reduce motion and haptics work now; the dyslexia font and colour palettes are listed
## but disabled until their owning stories (044, 045) ship.

signal closed
## Emitted by the debug-only "3D preview" row, to open the Gloom Breaker 3D preview.
signal preview_requested

const PALETTE_LABELS := {"off": "Off", "protan": "Protan", "deutan": "Deutan", "tritan": "Tritan"}

var _gs: Node
## Keeps the debug friend-code panel's signal handlers alive while the page exists.
var _friend: FriendDebugRow


## Builds the page for `game_state`.
func setup(game_state: Node) -> SettingsPage:
	_gs = game_state
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 12)
	add_child(root)
	root.add_child(_header())
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 10)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.add_child(list)
	root.add_child(scroll)
	list.add_child(_section("Comfort"))
	list.add_child(_toggle_row("Reduce motion", "Animations jump straight to their end state.",
			_gs.reduce_motion, true, _on_reduce_motion))
	list.add_child(_toggle_row("Haptic feedback", "Phone vibration on hits, star bursts and zap strikes.",
			_gs.haptics_on, true, _on_haptics))
	list.add_child(_section("Coming soon"))
	list.add_child(_toggle_row("Dyslexia-friendly font", "Easier letter shapes for reading. Story 044.",
			_gs.dyslexia_font, false, Callable()))
	list.add_child(_palette_row())
	if OS.is_debug_build():
		list.add_child(_section("Debug"))
		list.add_child(_preview_row())
		list.add_child(_cloud_test_row())
		_friend = FriendDebugRow.new()
		list.add_child(_friend.build(_gs, self))
	return self


## Debug builds only: a row whose button opens the 3D Gloom Breaker preview.
func _preview_row() -> Control:
	var parts := _row_box("3D preview", "Gloom Breaker as extruded 3D slabs. Debug builds only.", true)
	var open := Button.new()
	open.text = "Open"
	open.theme_type_variation = "SecondaryButton"
	open.custom_minimum_size = Vector2(120, 56)
	open.pressed.connect(func(): preview_requested.emit())
	(parts[1] as HBoxContainer).add_child(open)
	return parts[0]


## Debug builds only: signs in to Firebase anonymously, writes one test profile and reads it back.
func _cloud_test_row() -> Control:
	var parts := _row_box("Cloud test", "Firebase sign-in, save and load. Debug builds only.", true)
	var status := Label.new()
	status.text = "Not run yet"
	status.theme_type_variation = "Caption"
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var client := FirebaseClient.new()
	add_child(client)
	client.signed_in.connect(func(uid: String): client.set_document("players/" + uid, {"name": "debug", "stars": 1}))
	client.document_saved.connect(func(path: String): status.text = "Saved " + path + ", loading...")
	client.document_saved.connect(func(path: String): client.get_document(path))
	client.document_loaded.connect(func(path: String, data: Dictionary): status.text = "Loaded " + path + ": " + str(data))
	client.request_failed.connect(func(message: String): status.text = "Failed: " + message)
	var run := Button.new()
	run.text = "Test"
	run.theme_type_variation = "SecondaryButton"
	run.custom_minimum_size = Vector2(120, 56)
	run.pressed.connect(func(): status.text = "Signing in..."; client.sign_in_anonymously())
	(parts[1] as HBoxContainer).add_child(run)
	(parts[1] as HBoxContainer).get_child(0).add_child(status)
	return parts[0]



func _header() -> Control:
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	var back := Button.new()
	back.text = "Back"
	back.theme_type_variation = "SecondaryButton"
	back.custom_minimum_size = Vector2(110, 56)
	back.focus_mode = Control.FOCUS_NONE
	back.pressed.connect(func(): Snd.play("tap"); closed.emit())
	head.add_child(back)
	var title := Label.new()
	title.text = "Settings"
	title.theme_type_variation = "Title"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(title)
	return head


func _section(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = "Heading"
	return l


func _row_box(title: String, hint: String, enabled: bool) -> Array:
	var panel := PanelContainer.new()
	panel.theme_type_variation = "CardPanel" if enabled else "CardPanelLocked"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text)
	var t := Label.new()
	t.text = title
	t.theme_type_variation = "Heading" if enabled else "Muted"
	text.add_child(t)
	var h := Label.new()
	h.text = hint
	h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	h.theme_type_variation = "Caption"
	text.add_child(h)
	return [panel, row]


func _toggle_row(title: String, hint: String, on: bool, enabled: bool, on_change: Callable) -> Control:
	var parts := _row_box(title, hint, enabled)
	var sw := CheckButton.new()
	sw.button_pressed = on
	sw.disabled = not enabled
	sw.focus_mode = Control.FOCUS_NONE
	sw.custom_minimum_size = Vector2(120, 56)
	if enabled:
		sw.toggled.connect(func(v: bool): on_change.call(v))
	(parts[1] as HBoxContainer).add_child(sw)
	return parts[0]


func _palette_row() -> Control:
	var parts := _row_box("Colour palette", "Colour-blind safe glow colours. Story 045.", false)
	var pick := OptionButton.new()
	pick.disabled = true
	pick.focus_mode = Control.FOCUS_NONE
	pick.custom_minimum_size = Vector2(160, 56)
	for i in _gs.COLOUR_PALETTES.size():
		var id: String = _gs.COLOUR_PALETTES[i]
		pick.add_item(PALETTE_LABELS[id], i)
		if id == _gs.colour_palette:
			pick.select(i)
	(parts[1] as HBoxContainer).add_child(pick)
	return parts[0]


func _on_haptics(v: bool) -> void:
	Snd.play("tap")
	_gs.set_haptics(v)


func _on_reduce_motion(v: bool) -> void:
	Snd.play("tap")
	_gs.set_reduce_motion(v)
