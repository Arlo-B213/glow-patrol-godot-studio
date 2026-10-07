class_name SparkleBurst
extends Control
const FD := preload("res://scripts/fast_draw.gd")
## One-shot burst of ~24 diamond sparkles in palette colours. Frees itself after
## ~1 s. Never intercepts input. Not spawned at all when motion is disabled.

const COUNT := 24
const LIFETIME := 1.0
const GRAVITY := 140.0

var _age := 0.0
var _parts: Array[Dictionary] = []


## Spawns a burst under `parent` centred on `global_center`; null if motion is off.
static func spawn(parent: Control, global_center: Vector2) -> SparkleBurst:
	if not UiMotion.enabled() or not parent.is_inside_tree():
		return null
	var burst := SparkleBurst.new()
	burst.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(burst)
	burst.position = parent.get_global_transform().affine_inverse() * global_center
	return burst


func _ready() -> void:
	var colors: Array[Color] = [UiTheme.GOLD, UiTheme.ACCENT, UiTheme.TEAL, UiTheme.VIOLET]
	for i in COUNT:
		var ang := TAU * float(i) / COUNT + randf_range(-0.15, 0.15)
		var speed := randf_range(70.0, 170.0)
		_parts.append({
			"pos": Vector2.ZERO,
			"vel": Vector2(cos(ang), sin(ang)) * speed,
			"size": randf_range(3.0, 7.0),
			"color": colors[i % colors.size()],
		})


func _process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME:
		queue_free()
		return
	for p in _parts:
		var vel: Vector2 = p["vel"]
		vel.y += GRAVITY * delta
		p["vel"] = vel
		p["pos"] = (p["pos"] as Vector2) + vel * delta
	queue_redraw()


func _draw() -> void:
	var fade := 1.0 - _age / LIFETIME
	for p in _parts:
		var c: Color = p["color"]
		c.a = fade
		var s: float = (p["size"] as float) * (0.6 + 0.4 * fade)
		var o: Vector2 = p["pos"]
		FD.poly(self, PackedVector2Array([
			o + Vector2(0, -s * 1.5), o + Vector2(s, 0), o + Vector2(0, s * 1.5), o + Vector2(-s, 0),
		]), c)
