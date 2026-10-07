class_name PetView
extends Control
## A pet drawn by PetArt that fills this control's rect. Idle breathing, blinking and
## tail/gill motion only run while visible and while motion is allowed
## (GameState.reduce_motion). `react("eat" | "pet" | "grow" | "hop" | "spin")` plays a
## one-shot reaction (PetArt draws the hearts, crumbs or evolution flash); under reduced
## motion reactions are skipped (the happy face still shows briefly).

## Emitted when the pet is tapped (the Pets screen uses it for petting).
signal tapped

var species := "xolo"
var stage := 1
## PetArt.MOOD_* (face); a temporary happy mood after a reaction overrides it.
var mood := PetArt.MOOD_NORMAL
var flip := 1.0
## Accessory id to show; "-" = the pet's saved one (default), "" = none.
var accessory := "-"
## 0..1 hatch progress, brightens the egg's cracks.
var progress := 0.0
## Where the eyes look (-1..1 each axis), e.g. toward the bowl.
var look := Vector2.ZERO

var _t := 0.0
var _bounce := 0.0
var _react := ""
var _react_t := 0.0
var _happy_until := 0.0
var _bounce_tween: Tween


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	_update_processing()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_update_processing()


func _update_processing() -> void:
	set_process(is_visible_in_tree() and UiMotion.enabled())


## Sets which pet to show and returns self for chaining.
func pet(new_species: String, new_stage: int) -> PetView:
	species = new_species
	stage = clampi(new_stage, 0, 3)
	queue_redraw()
	return self


func set_mood(new_mood: int) -> void:
	mood = new_mood
	queue_redraw()


## One-shot reaction: "eat", "pet", "grow", "hop" or "spin".
func react(kind: String) -> void:
	_happy_until = _now() + 2.2
	if not UiMotion.enabled():
		queue_redraw()
		if is_inside_tree():
			get_tree().create_timer(2.3).timeout.connect(queue_redraw)
		return
	_react = kind
	_react_t = 0.0
	match kind:
		"eat": _hop(0.5, 2)
		"grow": _hop(0.6, 1)
		"spin": _hop(0.9, 1)
		_: _hop(0.45, 1)
	set_process(true)


func _hop(duration: float, times: int) -> void:
	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()
	if not is_inside_tree():
		return
	_bounce_tween = create_tween()
	for i in times:
		_bounce_tween.tween_method(func(v: float) -> void: _bounce = v, 0.0, 1.0, duration / float(times))
	_bounce_tween.tween_callback(func() -> void: _bounce = 0.0)


func _now() -> float:
	return float(Time.get_ticks_msec()) / 1000.0


func _process(delta: float) -> void:
	_t += delta
	if _react != "":
		_react_t += delta
		if _react_t > float(PetArt.REACT_LEN.get(_react, 1.0)):
			_react = ""
	queue_redraw()
	if not UiMotion.enabled():
		set_process(false)


func _gui_input(event: InputEvent) -> void:
	var press := event is InputEventMouseButton and (event as InputEventMouseButton).pressed \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	if press or (event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed):
		tapped.emit()


func _draw() -> void:
	var animate := UiMotion.enabled()
	var shown := mood
	if _now() < _happy_until and shown != PetArt.MOOD_SLEEPY:
		shown = PetArt.MOOD_HAPPY
	var ex := {"prog": progress, "look": look}
	if accessory != "-":
		ex["acc"] = accessory
	if _react != "":
		ex["react"] = _react
		ex["rt"] = _react_t
	PetArt.draw(self, species, stage, Rect2(Vector2.ZERO, size), _t, animate, shown, _bounce, flip, ex)
