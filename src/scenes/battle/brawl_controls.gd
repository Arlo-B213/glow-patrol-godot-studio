extends Control
## Alley Brawl touch/keyboard controls (Story 025). Covers the whole view but ignores the GUI
## mouse filter and reads raw input so several fingers work at once (hold move + press punch).
##   - Move: drag anywhere in the lower-left area (a virtual slider with a drawn thumb), hold the
##     round left/right arrow buttons, or use A/D / arrow keys.
##   - Punch: big round button, or J / Space.   Block (hold): round shield button, or K / Shift.
## Pointers are tracked by id (touch index, or -1 for the desktop mouse; emulated mouse events from
## touch are ignored so a finger is never counted twice). The view reads `read_axis()` and
## `block_held` each frame and listens for `punch_pressed`.

signal punch_pressed

const MOUSE_ID := -1
const STICK_RADIUS := 52.0
const STICK_DEADZONE := 0.12

## Set by the view for the guard ring on the block button (0..1) and the broken state.
var guard_ratio := 1.0
var guard_broken := false
var block_held := false
## When false (finished/paused) input is ignored.
var active := true

var _pointers := {}
var _stick_origin := Vector2.ZERO
var _stick_pos := Vector2.ZERO
var _stick_id := -2
var _used_stick := false
var _u := 1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## Current movement input, -1 (left) .. 1 (right): the strongest of stick, buttons and keys.
func read_axis() -> float:
	var a := 0.0
	if _stick_id != -2:
		var dx: float = (_stick_pos.x - _stick_origin.x) / (STICK_RADIUS * _u)
		var m: float = clampf(absf(dx), 0.0, 1.0)
		if m > STICK_DEADZONE:
			a = signf(dx) * (m - STICK_DEADZONE) / (1.0 - STICK_DEADZONE)
	var digital := 0.0
	if _held("left") or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		digital -= 1.0
	if _held("right") or Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		digital += 1.0
	return digital if absf(digital) > absf(a) else a


## Refreshes `block_held` (block button or K / Shift); call once per frame before reading it.
func poll_block() -> bool:
	block_held = active and (_held("block") or Input.is_physical_key_pressed(KEY_K) or Input.is_physical_key_pressed(KEY_SHIFT))
	return block_held


func _held(role: String) -> bool:
	return _pointers.values().has(role)


# --- layout (local coordinates; recomputed from the current size) ---

func _layout() -> Dictionary:
	_u = clampf(size.x / 480.0, 1.0, 2.0)
	var u := _u
	var rp: float = maxf(34.0, 41.0 * u)
	var rb: float = maxf(32.0, 33.0 * u)
	var ra: float = maxf(32.0, 30.0 * u)
	var punch := Vector2(size.x - rp - 24.0 * u, size.y - rp - 34.0 * u)
	var block := Vector2(punch.x - rp - rb - 14.0 * u, punch.y + rp * 0.25)
	var left := Vector2(24.0 * u + ra, size.y - ra - 34.0 * u)
	var right := Vector2(left.x + 2.0 * ra + 14.0 * u, left.y)
	return {"punch": [punch, rp], "block": [block, rb], "left": [left, ra], "right": [right, ra]}


func _role_at(p: Vector2) -> String:
	var lay: Dictionary = _layout()
	for role in ["punch", "block", "left", "right"]:
		var d: Array = lay[role]
		if p.distance_to(d[0]) <= float(d[1]) + 8.0 * _u:
			return role
	if p.x < size.x * 0.55 and p.y > size.y * 0.4:
		return "stick"
	return ""


# --- input ---

func _input(event: InputEvent) -> void:
	if not active or not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		_pointer(st.index, _local(st.position), st.pressed)
	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		_drag(sd.index, _local(sd.position))
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.device != InputEvent.DEVICE_ID_EMULATION:
			_pointer(MOUSE_ID, _local(mb.position), mb.pressed)
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if mm.device != InputEvent.DEVICE_ID_EMULATION and _pointers.has(MOUSE_ID):
			_drag(MOUSE_ID, _local(mm.position))
	elif event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and not k.echo and (k.physical_keycode == KEY_J or k.physical_keycode == KEY_SPACE):
			punch_pressed.emit()


func _local(p: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * p


func _pointer(id: int, p: Vector2, pressed: bool) -> void:
	if not pressed:
		if _pointers.has(id):
			_pointers.erase(id)
			if id == _stick_id:
				_stick_id = -2
		queue_redraw()
		return
	if _pointers.has(id) or not Rect2(Vector2.ZERO, size).has_point(p):
		return
	var role: String = _role_at(p)
	if role == "":
		return
	_pointers[id] = role
	if role == "punch":
		punch_pressed.emit()
	elif role == "stick" and _stick_id == -2:
		_stick_id = id
		_stick_origin = p
		_stick_pos = p
		_used_stick = true
	queue_redraw()


func _drag(id: int, p: Vector2) -> void:
	if id == _stick_id:
		_stick_pos = p
		queue_redraw()


# --- drawing ---

func _draw() -> void:
	var lay: Dictionary = _layout()
	var u := _u
	if _stick_id != -2:
		var off: Vector2 = (_stick_pos - _stick_origin).limit_length(STICK_RADIUS * u)
		draw_circle(_stick_origin, STICK_RADIUS * u, Color(UiTheme.PANEL, 0.35))
		draw_arc(_stick_origin, STICK_RADIUS * u, 0.0, TAU, 40, Color(UiTheme.TEXT, 0.35), 3.0 * u, true)
		draw_circle(_stick_origin + Vector2(off.x, 0.0), 26.0 * u, Color(UiTheme.VIOLET, 0.85))
		draw_arc(_stick_origin + Vector2(off.x, 0.0), 26.0 * u, 0.0, TAU, 28, Color(UiTheme.TEXT, 0.8), 2.5 * u, true)
	elif not _used_stick:
		var hint := Vector2(size.x * 0.28, size.y - 190.0 * u)
		draw_arc(hint, STICK_RADIUS * u, 0.0, TAU, 40, Color(UiTheme.TEXT, 0.22), 3.0 * u, true)
		draw_circle(hint, 22.0 * u, Color(UiTheme.VIOLET, 0.3))
		draw_string(ThemeDB.fallback_font, hint + Vector2(-90.0 * u, -STICK_RADIUS * u - 8.0 * u), "drag to move", HORIZONTAL_ALIGNMENT_CENTER, 180.0 * u, int(14.0 * u), Color(UiTheme.TEXT, 0.5))
	_round_button(lay["left"], "left", UiTheme.PANEL_LIGHT, "back", UiTheme.TEXT)
	_round_button(lay["right"], "right", UiTheme.PANEL_LIGHT, "forward", UiTheme.TEXT)
	_round_button(lay["punch"], "punch", UiTheme.ACCENT, "fist", UiTheme.TEXT_ON_ACCENT, "PUNCH")
	_round_button(lay["block"], "block", UiTheme.TEAL, "shield", UiTheme.TEXT_ON_ACCENT, "BLOCK", guard_broken)


func _round_button(d: Array, role: String, col: Color, icon: String, ink: Color, caption: String = "", dim: bool = false) -> void:
	var c: Vector2 = d[0]
	var r: float = d[1]
	var down: bool = _held(role)
	var rr: float = r * (0.94 if down else 1.0)
	var fill: Color = col.lerp(Color.WHITE, 0.18) if down else col
	if dim:
		fill = fill.lerp(UiTheme.LOCKED, 0.65)
	draw_circle(c + Vector2(0, 3.0 * _u), rr, Color(0, 0, 0, 0.35))
	draw_circle(c, rr, Color(fill, 0.92))
	draw_arc(c, rr - 2.0 * _u, 0.0, TAU, 36, Color(1, 1, 1, 0.5), 2.5 * _u, true)
	var ir := Rect2(c - Vector2(rr, rr) * 0.55, Vector2(rr, rr) * 1.1)
	if icon == "shield":
		_shield(c, rr * 0.5, ink)
	else:
		UiIcons.draw(self, icon, ir, ink)
	if role == "block":
		draw_arc(c, rr + 5.0 * _u, -PI * 0.5, -PI * 0.5 + TAU * clampf(guard_ratio, 0.0, 1.0), 40, Color(UiTheme.GOLD, 0.9), 4.0 * _u, true)
	if caption != "":
		draw_string(ThemeDB.fallback_font, c + Vector2(-r, -r - 8.0 * _u), caption, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, int(13.0 * _u), Color(UiTheme.TEXT, 0.8))


func _shield(c: Vector2, s: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([c + Vector2(-s, -s), c + Vector2(s, -s), c + Vector2(s, s * 0.2), c + Vector2(0, s * 1.1), c + Vector2(-s, s * 0.2)]), col)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-s * 0.55, -s * 0.6), c + Vector2(s * 0.55, -s * 0.6), c + Vector2(s * 0.55, s * 0.1), c + Vector2(0, s * 0.62), c + Vector2(-s * 0.55, s * 0.1)]), Color(1, 1, 1, 0.35))
