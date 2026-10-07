class_name UiMotion
extends RefCounted
## Static motion helpers (Story 014). Every helper checks `enabled()` at call time
## and jumps straight to the final state when reduced motion is on.

const PRESS_SCALE := 0.96
const PRESS_DIM := 0.88


## True when animations may play (GameState.reduce_motion is false).
static func enabled() -> bool:
	var loop := Engine.get_main_loop()
	if loop is SceneTree:
		var gs: Node = (loop as SceneTree).root.get_node_or_null("GameState")
		if gs != null:
			return not bool(gs.get("reduce_motion"))
	return true


static func _kill_meta(node: Object, key: String) -> void:
	if node.has_meta(key):
		var t = node.get_meta(key)
		if t is Tween and (t as Tween).is_valid():
			(t as Tween).kill()
		node.remove_meta(key)


## Counts `label.text` from `from_v` to `to_v`. Returns the Tween, or null when
## the text was set immediately.
static func count_up(label: Label, from_v: int, to_v: int, duration: float = 0.5) -> Tween:
	_kill_meta(label, "_mo_count")
	if not enabled() or from_v == to_v or not label.is_inside_tree():
		label.text = "%d" % to_v
		return null
	var tw := label.create_tween()
	label.set_meta("_mo_count", tw)
	tw.tween_method(func(v: float) -> void: label.text = "%d" % roundi(v),
		float(from_v), float(to_v), duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void: label.text = "%d" % to_v)
	return tw


## Quick scale pop 1.0 -> peak -> 1.0 around the control's centre.
static func pop(c: Control, peak: float = 1.12, duration: float = 0.18) -> Tween:
	_kill_meta(c, "_mo_pop")
	c.scale = Vector2.ONE
	if not enabled() or not c.is_inside_tree():
		return null
	c.pivot_offset = c.size * 0.5
	var tw := c.create_tween()
	c.set_meta("_mo_pop", tw)
	tw.tween_property(c, "scale", Vector2.ONE * peak, duration * 0.45).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "scale", Vector2.ONE, duration * 0.55).set_ease(Tween.EASE_IN_OUT)
	return tw


## Fades `c` in from transparent while sliding it up `distance` px. Returns the
## Tween (kill it to cancel) or null when motion is off. Never touches input state.
static func fade_slide_in(c: Control, distance: float = 12.0, duration: float = 0.18) -> Tween:
	if not enabled() or not c.is_inside_tree():
		return null
	c.modulate.a = 0.0
	c.position.y = distance
	var tw := c.create_tween().set_parallel(true)
	tw.tween_property(c, "modulate:a", 1.0, duration).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "position:y", 0.0, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	return tw


## Connects a scale 0.96 + slight dim feedback to a button's button_down/up.
## Safe to call more than once; toggle state and theme styles are untouched.
static func wire_press_feedback(btn: BaseButton) -> void:
	if btn.has_meta("_mo_wired"):
		return
	btn.set_meta("_mo_wired", true)
	btn.button_down.connect(_on_press_down.bind(btn))
	btn.button_up.connect(_on_press_up.bind(btn))


static func _on_press_down(btn: BaseButton) -> void:
	if not enabled() or not btn.is_inside_tree():
		return
	_kill_meta(btn, "_mo_press")
	if not btn.has_meta("_mo_base"):
		btn.set_meta("_mo_base", btn.modulate)
	var base: Color = btn.get_meta("_mo_base")
	btn.pivot_offset = btn.size * 0.5
	var tw := btn.create_tween().set_parallel(true)
	btn.set_meta("_mo_press", tw)
	tw.tween_property(btn, "scale", Vector2.ONE * PRESS_SCALE, 0.06)
	tw.tween_property(btn, "modulate", Color(base.r * PRESS_DIM, base.g * PRESS_DIM, base.b * PRESS_DIM, base.a), 0.06)


static func _on_press_up(btn: BaseButton) -> void:
	if not is_instance_valid(btn):
		return
	_kill_meta(btn, "_mo_press")
	var base: Color = btn.get_meta("_mo_base", btn.modulate)
	if btn.has_meta("_mo_base"):
		btn.remove_meta("_mo_base")
	if not enabled() or not btn.is_inside_tree():
		btn.scale = Vector2.ONE
		btn.modulate = base
		return
	var tw := btn.create_tween().set_parallel(true)
	btn.set_meta("_mo_press", tw)
	tw.tween_property(btn, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "modulate", base, 0.1)


## Floating "+N" with a star icon that rises ~40 px and fades over ~0.9 s, then frees
## itself. `global_pos` is the top-left start. Returns null when motion is off.
static func float_text(parent: Control, global_pos: Vector2, amount: int) -> Control:
	if not enabled() or not parent.is_inside_tree():
		return null
	var box := HBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 4)
	var icon := UiIcon.new().setup("star", UiTheme.GOLD, 22)
	box.add_child(icon)
	var label := Label.new()
	label.text = "+%d" % amount
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", UiTheme.GOLD)
	label.add_theme_font_size_override("font_size", 22)
	box.add_child(label)
	parent.add_child(box)
	box.position = parent.get_global_transform().affine_inverse() * global_pos
	var tw := box.create_tween().set_parallel(true)
	tw.tween_property(box, "position:y", box.position.y + 34.0, 0.9)  # drifts down, away from the counter.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(box, "modulate:a", 0.0, 0.9).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(box.queue_free)
	return box
