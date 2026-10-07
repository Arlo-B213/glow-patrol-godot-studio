extends RefCounted
## Code-drawn chibi portraits of the three Lanternboys (Story 009, upgraded in Story 032):
## Hae (leader, big lantern), Bit (dancer, headphones) and Nun (quiet one, moths). Same outline,
## 3-tone shading, gradient hair, rich eyes and lantern rim light as the hunter art. Characters
## are drawn in a 100 x 130 design space that is mapped uniformly into the target rect: tall
## rects show the full body, squarer ones crop to the head and torso (clip_contents).

const S := preload("res://scripts/hunter_shade.gd")
const P := preload("res://scripts/lanternboy_parts.gd")
const Cast := preload("res://scripts/lanternboy_cast.gd")
const NunArt := preload("res://scripts/lanternboy_nun.gd")
const Expr := preload("res://scripts/hunter_expr.gd")

const FULL_W := 100.0
const FULL_H := 130.0
const CROP := 90.0


## Draws `boy_id` ("hae" | "bit" | "nun") into `rect` of `ci`. `t` is seconds for idle
## motion (blink, bob, breathing, hair sway, glow pulse, moths); it is ignored when `animate`
## is false or reduced motion is on. `bounce` (0..1) lifts the figure for the high-five
## reaction. `expression` (hunter_expr.gd ids, "" = the boy's neutral face) changes the face and
## `look_at` (-1..1 per axis) moves the irises, e.g. toward a tapped point in a dialogue close-up.
static func draw(ci: CanvasItem, boy_id: String, rect: Rect2, t: float = 0.0,
		animate: bool = true, bounce: float = 0.0, expression: String = "", look_at: Vector2 = Vector2.ZERO) -> void:
	var anim: bool = animate and _motion_on()
	var tt: float = t if anim else 0.0
	var aspect: float = rect.size.y / maxf(rect.size.x, 1.0)
	var s: float
	var origin: Vector2
	if aspect < 1.15:
		s = minf(rect.size.x, rect.size.y) / CROP
		origin = rect.position + (rect.size - Vector2(CROP, CROP) * s) * 0.5 - Vector2(5.0, 6.0) * s
	else:
		s = minf(rect.size.x / FULL_W, rect.size.y / FULL_H)
		origin = rect.position + (rect.size - Vector2(FULL_W, FULL_H) * s) * 0.5
	origin.y -= bounce * 8.0 * s
	var bob: float = sin(tt * 2.2) * 1.0 if anim else 0.0
	origin.y += bob * s
	var breath: float = 1.0 + (0.012 * sin(tt * 2.0) if anim else 0.0)
	origin.y += FULL_H * s * (1.0 - breath) * 0.95
	var tilt: float = 0.0
	if boy_id == "bit":
		tilt = 0.09 + (sin(tt * 4.0) * 0.045 if anim else 0.0)
	var pivot := Vector2(50.0, 125.0) * s
	var rot := Transform2D(tilt, Vector2.ZERO)
	ci.draw_set_transform(origin + pivot - rot * pivot, tilt, Vector2(s, s * breath))
	var late: float = 0.7 if boy_id == "nun" else 0.0
	P.expr = expression if Expr.TABLE.has(expression) else ("happy" if bounce > 0.3 else "neutral")
	P.closed = _blink(tt + late) if anim else 0.0
	P.sway = sin(tt * 1.7 - 0.6) * 1.8 + sin(tt * 3.1) * 0.6 if anim else 0.0
	var drift := Vector2(sin(tt * 0.6), cos(tt * 0.45) * 0.4) * 0.35 if anim else Vector2.ZERO
	P.gaze = look_at + drift
	var pulse: float = 0.5 + 0.5 * sin(tt * 3.0) if anim else 0.5
	match boy_id:
		"hae":
			Cast.hae(ci, pulse)
		"bit":
			Cast.bit(ci, tt, anim, pulse)
		"nun":
			NunArt.nun(ci, tt, anim, pulse)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	P.expr = "neutral"
	P.gaze = Vector2.ZERO
	P.closed = 0.0
	P.sway = 0.0


## Smooth blink amount 0..1: a ~0.2 s blink every 3.6 s.
static func _blink(t: float) -> float:
	var d: float = fmod(t, 3.6) - 3.4
	if d < 0.0:
		return 0.0
	return clampf(sin(d / 0.2 * PI) * 1.4, 0.0, 1.0)


static func _motion_on() -> bool:
	var loop := Engine.get_main_loop()
	if loop is SceneTree:
		var gs: Node = (loop as SceneTree).root.get_node_or_null("GameState")
		if gs != null:
			return not bool(gs.get("reduce_motion"))
	return true
