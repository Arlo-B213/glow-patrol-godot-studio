class_name TutorialOverlay
extends Control
const FD := preload("res://scripts/fast_draw.gd")
## First-run walkthrough (Story 022): dimmed screen, a spotlight ring and bobbing arrow
## on the relevant tab, a friendly card with Next / Skip. Skippable at any step.
## Usage: add under Main, then `start({"home": Rect2, ...})` with global tab rects.

## Emitted once when the player finishes or skips; `skipped` is true for Skip.
signal finished(skipped: bool)

## Each step: title, text and the tab keys to spotlight (rects are merged).
const STEPS := [
	{"title": "Welcome to HQ!", "text": "This is your home base. See your stars, your level and your hunter here. Tap HQ any time to come back.", "tabs": ["home"]},
	{"title": "Battle!", "text": "Tap Battle to zap the sleepy Gloomlings with your glowstick. Win to earn stars and unlock the story.", "tabs": ["battle"]},
	{"title": "The Club", "text": "Visit the Club to try on outfits and hang out with Hae, Bit and Nun. They love high fives!", "tabs": ["club"]},
	{"title": "Games and Study", "text": "Games has fun mini-games. Study has quizzes where right answers give you stars. Pick your grade there!", "tabs": ["games", "study"]},
	{"title": "Pets!", "text": "Adopt a glow pet in Pets. Feed it and give it pats and watch it grow. You are all set - have fun!", "tabs": ["pets"]},
]
const BUTTON_H := 56
const DIM := Color(0.04, 0.02, 0.1, 0.78)

var _rects: Dictionary = {}
var _step := 0
var _time := 0.0
var _card: PanelContainer
var _title: Label
var _body: Label
var _count: Label
var _next: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_card()
	_show_step()


## Starts at step 0 with global tab rects keyed by tab name ("home", "battle", ...).
func start(tab_rects: Dictionary) -> void:
	_rects = tab_rects
	_step = 0
	if is_node_ready():
		_show_step()


## Number of steps (for tests).
func step_count() -> int:
	return STEPS.size()


## Index of the step now showing.
func current_step() -> int:
	return _step


## Moves on; finishes after the last step.
func next() -> void:
	Snd.play("tap")
	if _step >= STEPS.size() - 1:
		finished.emit(false)
		queue_free()
		return
	_step += 1
	_show_step()


## Ends the tour right away.
func skip() -> void:
	Snd.play("tap")
	finished.emit(true)
	queue_free()


func _build_card() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_bottom", 260)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(center)
	_card = PanelContainer.new()
	_card.theme_type_variation = "CardPanel"
	_card.custom_minimum_size = Vector2(560, 0)
	center.add_child(_card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	_card.add_child(box)
	_count = Label.new()
	_count.theme_type_variation = "Caption"
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_count)
	_title = Label.new()
	_title.theme_type_variation = "Title"
	_title.add_theme_font_size_override("font_size", 32)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_title)
	_body = Label.new()
	_body.add_theme_font_size_override("font_size", 20)
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_body)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	var skip_btn := Button.new()
	skip_btn.text = "Skip"
	skip_btn.theme_type_variation = "SecondaryButton"
	skip_btn.custom_minimum_size = Vector2(150, BUTTON_H)
	skip_btn.focus_mode = Control.FOCUS_NONE
	skip_btn.pressed.connect(skip)
	row.add_child(skip_btn)
	_next = Button.new()
	_next.theme_type_variation = "PrimaryButton"
	_next.custom_minimum_size = Vector2(150, BUTTON_H)
	_next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_next.focus_mode = Control.FOCUS_NONE
	_next.pressed.connect(next)
	row.add_child(_next)


func _show_step() -> void:
	var s: Dictionary = STEPS[_step]
	_title.text = s["title"]
	_body.text = s["text"]
	_count.text = "%d of %d" % [_step + 1, STEPS.size()]
	_next.text = "Let's go!" if _step == STEPS.size() - 1 else "Next"
	queue_redraw()


func _process(delta: float) -> void:
	if UiMotion.enabled():
		_time += delta
		queue_redraw()


## Union of the spotlighted tab rects (local coordinates), or an empty Rect2.
func _spot_rect() -> Rect2:
	var out := Rect2()
	var first := true
	var inv := get_global_transform().affine_inverse()
	for key in STEPS[_step]["tabs"]:
		if not _rects.has(key):
			continue
		var r: Rect2 = _rects[key]
		var local := Rect2(inv * r.position, r.size)
		out = local if first else out.merge(local)
		first = false
	return out


func _draw() -> void:
	var spot := _spot_rect()
	if spot.size == Vector2.ZERO:
		draw_rect(Rect2(Vector2.ZERO, size), DIM)
		return
	var hole := spot.grow(6.0)
	draw_rect(Rect2(0, 0, size.x, hole.position.y), DIM)
	draw_rect(Rect2(0, hole.end.y, size.x, size.y - hole.end.y), DIM)
	draw_rect(Rect2(0, hole.position.y, hole.position.x, hole.size.y), DIM)
	draw_rect(Rect2(hole.end.x, hole.position.y, size.x - hole.end.x, hole.size.y), DIM)
	draw_rect(hole, UiTheme.GOLD, false, 4.0, true)
	var bob := sin(_time * 5.0) * 8.0 if UiMotion.enabled() else 0.0
	var tip := Vector2(hole.get_center().x, hole.position.y - 10.0 + bob)
	var arrow := PackedVector2Array([tip, tip + Vector2(-26, -34), tip + Vector2(-10, -34),
		tip + Vector2(-10, -64), tip + Vector2(10, -64), tip + Vector2(10, -34), tip + Vector2(26, -34)])
	FD.poly(self, arrow, UiTheme.GOLD)
