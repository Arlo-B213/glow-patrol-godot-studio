class_name PetView
extends Control
## A pet drawn by PetArt that fills this control's rect. Idle breathing, blinking and
## wagging only run while visible and while motion is allowed (GameState.reduce_motion).
## `react("eat" | "pet" | "grow")` plays a one-shot hop plus hearts or sparkles; under
## reduced motion the reactions are skipped (the happy face still shows briefly).

## Emitted when the pet is tapped (the Pets screen uses it for petting).
signal tapped

var species := "xolo"
var stage := 1
## PetArt.MOOD_* (face); a temporary happy mood after petting overrides it.
var mood := PetArt.MOOD_NORMAL
var flip := 1.0

var _t := 0.0
var _bounce := 0.0
var _hearts: Array[Dictionary] = []
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


## One-shot reaction: "eat" (hop + sparkles), "pet" (hop + hearts), "grow" (big hop + sparkles).
func react(kind: String) -> void:
	_happy_until = _now() + 2.2
	if not UiMotion.enabled():
		queue_redraw()
		if is_inside_tree():
			get_tree().create_timer(2.3).timeout.connect(queue_redraw)
		return
	_hop(0.5 if kind == "eat" else 0.45, 2 if kind == "eat" else 1)
	match kind:
		"pet":
			for i in 5:
				_hearts.append({"pos": Vector2(randf_range(-0.2, 0.2), 0.0), "age": -float(i) * 0.12,
					"drift": randf_range(-0.12, 0.12)})
		"eat", "grow":
			if is_inside_tree():
				SparkleBurst.spawn(self, global_position + size * Vector2(0.5, 0.4))
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
	for i in range(_hearts.size() - 1, -1, -1):
		_hearts[i]["age"] += delta
		if _hearts[i]["age"] > 1.2:
			_hearts.remove_at(i)
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
	if _now() < _happy_until:
		shown = PetArt.MOOD_HAPPY
	PetArt.draw(self, species, stage, Rect2(Vector2.ZERO, size), _t, animate, shown, _bounce, flip)
	for h in _hearts:
		var age: float = h["age"]
		if age < 0.0:
			continue
		var c := Vector2(size.x * (0.5 + float(h["pos"].x) + float(h["drift"]) * age * 2.0), size.y * (0.4 - age * 0.3))
		var r := size.x * 0.035
		var col := Color(1.0, 0.4, 0.64, clampf(1.2 - age, 0.0, 1.0))
		draw_circle(c + Vector2(-r * 0.8, 0.0), r, col)
		draw_circle(c + Vector2(r * 0.8, 0.0), r, col)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 1.75, r * 0.2), c + Vector2(r * 1.75, r * 0.2),
			c + Vector2(0.0, r * 2.4)]), col)
