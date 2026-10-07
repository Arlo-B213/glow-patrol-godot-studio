extends Control
## Pets screen (Story 024): a Den with the active pet (feed, pet, switch) and a Pet Shop
## to adopt eggs. Pure display: all care rules live in GameState (feed_pet, pet_pet...).

const SUB_DEN := "den"
const SUB_SHOP := "shop"
const BTN_H := 60.0
const AccPicker := preload("res://scenes/ui/pet_acc_picker.gd")

@onready var game_state: Node = get_node("/root/GameState")
@onready var toast: Node = get_node("/root/Toast")

var current_sub := SUB_DEN
var _sub_buttons: Dictionary = {}
var _content: VBoxContainer
var _ui: Dictionary = {}      ## Live den widgets: den, name, stage, status, growth, ...
var _overlay: Control


func _ready() -> void:
	game_state.refresh_pet_needs()
	Snd.music("pets")
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 12)
	add_child(root)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	root.add_child(tabs)
	for pair in [[SUB_DEN, "Den"], [SUB_SHOP, "Pet Shop"]]:
		var b := Button.new()
		b.text = pair[1]
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(0, BTN_H - 4.0)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(render_sub.bind(pair[0]))
		tabs.add_child(b)
		_sub_buttons[pair[0]] = b
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 12)
	scroll.add_child(_content)
	game_state.pet_stage_changed.connect(_on_stage_changed)
	render_sub(SUB_DEN)


func _exit_tree() -> void:
	if game_state != null and game_state.pet_stage_changed.is_connected(_on_stage_changed):
		game_state.pet_stage_changed.disconnect(_on_stage_changed)


## Shows the Den or the Pet Shop.
func render_sub(key: String) -> void:
	current_sub = key
	for k in _sub_buttons.keys():
		(_sub_buttons[k] as Button).button_pressed = (k == key)
	for child in _content.get_children():
		child.queue_free()
	_ui = {}
	if key == SUB_SHOP:
		_build_shop()
	else:
		_build_den()


# ---------------------------------------------------------------- helpers

func _label(text: String, variation: String = "", wrap: bool = false, align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	if variation != "":
		l.theme_type_variation = variation
	l.horizontal_alignment = align as HorizontalAlignment
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


func _button(text: String, variation: String, on_press: Callable, height: float = BTN_H) -> Button:
	var b := Button.new()
	b.text = text
	b.theme_type_variation = variation
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(0, height)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(on_press)
	return b


func _card(variation: String = "CardPanel") -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = variation
	_content.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	return box


func _bar(color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = 100.0
	bar.custom_minimum_size = Vector2(0, 18)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.add_theme_stylebox_override("fill", UiTheme.box(color, color.lightened(0.3), 1, 10, 0, 0, 0))
	return bar


func _meter_row(icon: String, color: Color, caption: String) -> ProgressBar:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(UiIcon.new().setup(icon, color, 30))
	var cap := _label(caption, "Caption")
	cap.custom_minimum_size.x = 64
	row.add_child(cap)
	var bar := _bar(color)
	row.add_child(bar)
	(_ui["meters"] as Control).add_child(row)
	return bar


func _set_bar(bar: ProgressBar, value: float) -> void:
	if UiMotion.enabled() and bar.is_inside_tree():
		bar.create_tween().tween_property(bar, "value", value, 0.3).set_ease(Tween.EASE_OUT)
	else:
		bar.value = value


func _pet_name(id: String) -> String:
	return str(game_state.owned_pets[id].get("name", game_state.pet_def(id).get("name", "Pet")))


# ---------------------------------------------------------------- den

func _build_den() -> void:
	var id: String = game_state.active_pet_id()
	if id == "":
		var box := _card()
		box.add_child(_label("No pet yet!", "Title", true, HORIZONTAL_ALIGNMENT_CENTER))
		box.add_child(_label("Adopt an egg in the Pet Shop and it will hatch into a buddy who fights beside you.",
			"Muted", true, HORIZONTAL_ALIGNMENT_CENTER))
		box.add_child(_button("Visit the Pet Shop", "PrimaryButton", render_sub.bind(SUB_SHOP)))
		return
	var den := PetDen.new()
	den.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_child(den)
	den.pet_view.tapped.connect(_on_pet_pressed)
	_ui["den"] = den
	var box := _card()
	var head := HBoxContainer.new()
	box.add_child(head)
	_ui["name"] = _label("", "Title")
	head.add_child(_ui["name"])
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(sp)
	_ui["stage"] = _label("", "Heading")
	(_ui["stage"] as Label).add_theme_color_override("font_color", UiTheme.GOLD)
	head.add_child(_ui["stage"])
	_ui["status"] = _label("", "Muted", true)
	box.add_child(_ui["status"])
	var grow_row := HBoxContainer.new()
	grow_row.add_theme_constant_override("separation", 10)
	grow_row.add_child(UiIcon.new().setup("star", UiTheme.GOLD, 30))
	var gcap := _label("Growth", "Caption")
	gcap.custom_minimum_size.x = 64
	grow_row.add_child(gcap)
	_ui["growth"] = _bar(UiTheme.GOLD)
	grow_row.add_child(_ui["growth"])
	box.add_child(grow_row)
	_ui["growth_note"] = _label("", "Caption", true)
	box.add_child(_ui["growth_note"])
	var meters := VBoxContainer.new()
	meters.add_theme_constant_override("separation", 8)
	box.add_child(meters)
	_ui["meters"] = meters
	_ui["tummy"] = _meter_row("bowl", UiTheme.TEAL, "Tummy")
	_ui["joy"] = _meter_row("heart", UiTheme.ACCENT, "Happy")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	_ui["feed"] = _button("", "PrimaryButton", _on_feed_pressed)
	row.add_child(_ui["feed"])
	row.add_child(_button("Pet", "SecondaryButton", _on_pet_pressed))
	box.add_child(_button("Switch pet", "SecondaryButton", _open_picker, BTN_H - 4.0))
	var picker: HFlowContainer = AccPicker.new().setup(id)
	box.add_child(picker)
	picker.changed.connect(den.pet_view.queue_redraw)
	box.move_child(picker, box.get_child_count() - 2)
	_refresh_den(true)


## Updates every den widget from GameState (`instant` skips the bar tweens).
func _refresh_den(instant: bool = false) -> void:
	var id: String = game_state.active_pet_id()
	if id == "" or not _ui.has("den"):
		return
	var stage: int = game_state.pet_stage(id)
	var pet: Dictionary = game_state.owned_pets[id]
	var den: PetDen = _ui["den"]
	den.pet_view.pet(id, stage)
	den.pet_view.set_mood(game_state.pet_mood(id))
	den.pet_view.progress = game_state.pet_progress(id) if stage == 0 else 0.0
	den.pet_view.accessory = "-"
	den.bowl_fill = float(pet["hunger"]) / 100.0
	(_ui["name"] as Label).text = _pet_name(id)
	(_ui["stage"] as Label).text = game_state.PET_STAGE_NAMES[stage]
	(_ui["status"] as Label).text = "%s %s" % [_pet_name(id), game_state.pet_status_text(id)]
	var next: float = game_state.pet_next_threshold(id)
	(_ui["growth_note"] as Label).text = "Fully grown - what a star!" if next < 0.0 else \
		"%d of %d care points to become a %s" % [int(float(pet["growth"])), int(next), game_state.PET_STAGE_NAMES[stage + 1]]
	for pair in [["growth", game_state.pet_progress(id) * 100.0], ["tummy", float(pet["hunger"])],
			["joy", float(pet["happiness"])]]:
		var bar: ProgressBar = _ui[pair[0]]
		if instant:
			bar.value = pair[1]
		else:
			_set_bar(bar, pair[1])
	(_ui["feed"] as Button).text = "Feed   ⭐ %d" % game_state.PET_FEED_COST


func _on_feed_pressed() -> void:
	var id: String = game_state.active_pet_id()
	if id == "" or not _ui.has("den"):
		return
	match game_state.can_feed(id):
		"full":
			Snd.play("error")
			toast.show_message("%s is full right now!" % _pet_name(id))
			return
		"stars":
			toast.show_message("Need %d Star Points for a snack" % game_state.PET_FEED_COST)
			return
	if game_state.feed_pet(id):
		Snd.play("eat")
		(_ui["den"] as PetDen).pet_view.react("eat")
		_refresh_den()


func _on_pet_pressed() -> void:
	var id: String = game_state.active_pet_id()
	if id == "" or not _ui.has("den"):
		return
	if game_state.pet_pet(id):
		Snd.play("pet_happy")
		(_ui["den"] as PetDen).pet_view.react("pet")
		_refresh_den()
	else:
		(_ui["status"] as Label).text = "%s is enjoying the cuddles" % _pet_name(id)


func _open_picker() -> void:
	if game_state.owned_pets.size() < 2:
		toast.show_message("Adopt more eggs in the Pet Shop!")
		return
	for child in _content.get_children():
		child.queue_free()
	_ui = {}
	_content.add_child(_label("Pick your buddy", "Title", true, HORIZONTAL_ALIGNMENT_CENTER))
	for id in game_state.owned_pets.keys():
		_add_pet_card(id, true)
	_content.add_child(_button("Back to the Den", "SecondaryButton", render_sub.bind(SUB_DEN)))


# ---------------------------------------------------------------- shop

func _build_shop() -> void:
	_content.add_child(_label("Pick an egg to adopt. Care for it and watch it grow!", "Muted", true))
	for def in game_state.PETS:
		_add_pet_card(def["id"], false)


## One species/pet card: portrait, name, blurb and its action button.
func _add_pet_card(id: String, picker: bool) -> void:
	var def: Dictionary = game_state.pet_def(id)
	var owned: bool = game_state.has_pet(id)
	var active: bool = game_state.active_pet_id() == id
	var box := _card("CardPanelEquipped" if active else ("CardPanelLocked" if not owned else "CardPanel"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	box.add_child(row)
	var view := PetView.new()
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.custom_minimum_size = Vector2(120, 120)
	view.pet(id, game_state.pet_stage(id) if owned else 0)
	row.add_child(view)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", 6)
	row.add_child(col)
	col.add_child(_label(def["name"], "Heading"))
	if owned:
		var st: String = game_state.PET_STAGE_NAMES[game_state.pet_stage(id)]
		col.add_child(_label("%s - %s" % [_pet_name(id), st], "Caption"))
	else:
		col.add_child(_label(def["blurb"], "Muted", true))
	var btn: Button
	if owned and active:
		btn = _button("Your buddy", "SecondaryButton", func() -> void: pass)
		btn.disabled = true
	elif owned:
		btn = _button("Choose", "SecondaryButton", _on_choose.bind(id))
	else:
		btn = _button("Adopt   ⭐ %d" % int(def["cost"]), "PrimaryButton", _on_adopt.bind(id))
	col.add_child(btn)


func _on_choose(id: String) -> void:
	game_state.set_active_pet(id)
	render_sub(SUB_DEN)


func _on_adopt(id: String) -> void:
	var def: Dictionary = game_state.pet_def(id)
	if game_state.adopt_pet(id):
		toast.show_message("%s joined your patrol!" % def["name"])
		render_sub(SUB_DEN if game_state.active_pet_id() == id else SUB_SHOP)
	else:
		toast.show_message("Need %d more Star Points" % maxi(1, int(def["cost"]) - game_state.star_points))


# ---------------------------------------------------------------- celebration

func _on_stage_changed(id: String, stage: int) -> void:
	if is_instance_valid(_overlay):
		_overlay.queue_free()
	_overlay = Control.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.01, 0.1, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.theme_type_variation = "CardPanelEquipped"
	panel.custom_minimum_size = Vector2(560, 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	var nm := _pet_name(id)
	var stage_name: String = game_state.PET_STAGE_NAMES[stage]
	box.add_child(_label("Hooray!", "Title", true, HORIZONTAL_ALIGNMENT_CENTER))
	var view := PetView.new()
	view.custom_minimum_size = Vector2(300, 300)
	view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	view.pet(id, stage)
	view.set_mood(PetArt.MOOD_HAPPY)
	box.add_child(view)
	var msg := "%s hatched!" % nm if stage == 1 else "%s grew up!" % nm
	box.add_child(_label(msg, "Heading", true, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label("%s is now a %s." % [nm, stage_name], "Muted", true, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_button("Yay!", "PrimaryButton", func() -> void: _overlay.queue_free()))
	Snd.play("grow")
	view.react.call_deferred("grow")
	_refresh_den(true)
