extends Control
## Star Catch controls (Story 027): drag anywhere to steer (the hero eases toward the finger),
## or hold the two round left/right buttons, or use A/D / arrow keys. Covers the whole view but
## ignores the GUI mouse filter and reads raw input, so several fingers work at once. Pointers are
## tracked by id (touch index, or -1 for the desktop mouse; emulated mouse events from touch are
## ignored so a finger is never counted twice). The view polls `read_axis()` / `drag_target()`.

const MOUSE_ID := -1
const BUTTON_R := 36.0

## When false (finished) input is ignored.
var active := true
## Set true once the player has used any control (hides the "drag to move" hint).
var used := false

var _pointers := {}
var _drag_x := 0.0
var _drag_id := -2
var _u := 1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## Button/keyboard direction, -1 (left) .. 1 (right), 0 when nothing is held.
func read_axis() -> float:
	var a := 0.0
	if _held("left") or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		a -= 1.0
	if _held("right") or Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		a += 1.0
	if a != 0.0:
		used = true
	return a


## Local x the finger is dragging to, or -1.0 while no drag is active.
func drag_target() -> float:
	return _drag_x if _drag_id != -2 else -1.0


## Test helper: starts/moves/stops a drag at local x without a real pointer.
func fake_drag(x: float, on: bool) -> void:
	_drag_id = MOUSE_ID if on else -2
	_drag_x = x
	used = used or on


func _held(role: String) -> bool:
	return _pointers.values().has(role)


## Button centres (local coords) and radius for the current size.
func button_layout() -> Dictionary:
	_u = clampf(size.x / 480.0, 1.0, 2.0)
	var r: float = BUTTON_R * _u
	var y: float = size.y - r - 18.0 * _u
	return {"left": Vector2(20.0 * _u + r, y), "right": Vector2(size.x - 20.0 * _u - r, y), "r": r}


func _role_at(p: Vector2) -> String:
	var lay: Dictionary = button_layout()
	var r: float = float(lay["r"]) + 10.0 * _u
	for role in ["left", "right"]:
		if p.distance_to(lay[role]) <= r:
			return role
	return "drag"


func _input(event: InputEvent) -> void:
	if not active or not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		_pointer(st.index, _local(st.position), st.pressed)
	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		_move(sd.index, _local(sd.position))
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.device != InputEvent.DEVICE_ID_EMULATION:
			_pointer(MOUSE_ID, _local(mb.position), mb.pressed)
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if mm.device != InputEvent.DEVICE_ID_EMULATION:
			_move(MOUSE_ID, _local(mm.position))


func _local(p: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * p


func _pointer(id: int, p: Vector2, pressed: bool) -> void:
	if not pressed:
		_pointers.erase(id)
		if id == _drag_id:
			_drag_id = -2
		queue_redraw()
		return
	if _pointers.has(id) or not Rect2(Vector2.ZERO, size).has_point(p):
		return
	var role: String = _role_at(p)
	_pointers[id] = role
	used = true
	if role == "drag":
		_drag_id = id
		_drag_x = p.x
	queue_redraw()


func _move(id: int, p: Vector2) -> void:
	if id == _drag_id:
		_drag_x = p.x


func _draw() -> void:
	var lay: Dictionary = button_layout()
	var r: float = lay["r"]
	for role in ["left", "right"]:
		var c: Vector2 = lay[role]
		var down: bool = _held(role) or (role == "left" and Input.is_physical_key_pressed(KEY_A)) or (role == "right" and Input.is_physical_key_pressed(KEY_D))
		var rr: float = r * (0.94 if down else 1.0)
		var fill: Color = UiTheme.PANEL_LIGHT.lerp(Color.WHITE, 0.18) if down else UiTheme.PANEL_LIGHT
		draw_circle(c + Vector2(0.0, 3.0 * _u), rr, Color(0, 0, 0, 0.35))
		draw_circle(c, rr, Color(fill, 0.92))
		draw_arc(c, rr - 2.0 * _u, 0.0, TAU, 36, Color(1, 1, 1, 0.5), 2.5 * _u, true)
		UiIcons.draw(self, "back" if role == "left" else "forward", Rect2(c - Vector2(rr, rr) * 0.55, Vector2(rr, rr) * 1.1), UiTheme.TEXT)
	if _drag_id != -2:
		var y: float = size.y - r * 2.0 - 40.0 * _u
		draw_circle(Vector2(_drag_x, y), 20.0 * _u, Color(UiTheme.VIOLET, 0.35))
		draw_arc(Vector2(_drag_x, y), 20.0 * _u, 0.0, TAU, 28, Color(UiTheme.TEXT, 0.6), 2.5 * _u, true)
