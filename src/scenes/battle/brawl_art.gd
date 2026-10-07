extends RefCounted
## Procedural enemy art for Alley Brawl: the Gloomlings and the Grumble King (the idol
## hunter lives in res://scripts/hunter_art.gd). Every function draws onto a CanvasItem
## and must be called from its _draw(). `u` is the view's layout scale; all sizes below are in 480px-field pixels.

const SKIN := Color("#FFD9C2")
const INK := Color("#1A0B33")
const BLACKOUT := Color("#0A0418")
const GOLD := Color("#FFD36E")
const PINK := Color("#FF5FA2")
const Extra := preload("res://scenes/battle/brawl_art_enemies.gd")
const Hydra := preload("res://scenes/battle/brawl_art_hydra.gd")


static func _c(col: Color, a: float) -> Color:
	return Color(col.r, col.g, col.b, col.a * a)


static func _ellipse(center: Vector2, rx: float, ry: float, points: int = 20) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(points):
		var a: float = TAU * float(i) / float(points)
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


## Draws one enemy by `type_id` (see brawl_enemies.gd). `fx` keys, all optional: flash (0..1 white
## tint), sq (vertical squash, 1 = none), alpha (0..1 fade), hp (health left, for Mossback).
static func draw_enemy(ci: CanvasItem, type_id: String, x: float, ground_y: float, s: float, color: Color, age: int, toward: float, u: float, fx: Dictionary = {}) -> void:
	match type_id:
		"blinker":
			Extra.draw_blinker(ci, x, ground_y, s, color, age, toward, u, fx)
		"mossback":
			Extra.draw_mossback(ci, x, ground_y, s, color, age, toward, u, fx)
		_:
			draw_gloomling(ci, x, ground_y, s, color, age, toward, u, fx)


## A Gloomling: a horned shadow blob with a coloured rim and glowing eyes. `toward` is
## -1 or 1, the side the player is on, so the pupils track them. `fx`: see draw_enemy.
static func draw_gloomling(ci: CanvasItem, x: float, ground_y: float, s: float, color: Color, age: int, toward: float, u: float, fx: Dictionary = {}) -> void:
	var t: float = float(age)
	var flash: float = float(fx.get("flash", 0.0))
	var al: float = float(fx.get("alpha", 1.0))
	var sq: float = float(fx.get("sq", 1.0))
	var hop: float = absf(sin(t * 0.18)) * 5.0 * u
	var squash: float = (1.0 + sin(t * 0.36) * 0.05) * sq
	var c := Vector2(x, ground_y - s * 0.5 * sq - hop)
	var body: Color = color.lerp(Color("#150C2B"), 0.62).lerp(Color.WHITE, flash)
	var horn: Color = color.lerp(Color.WHITE, flash)
	var sx: float = 1.0 / sq

	ci.draw_circle(c, s * 0.62, _c(color, 0.16 * al))
	for side in [-1.0, 1.0]:
		ci.draw_circle(c + Vector2(side * s * 0.2 * sx, s * 0.42 * sq), s * 0.12, _c(body, al))
		ci.draw_colored_polygon(PackedVector2Array([
			c + Vector2(side * s * 0.12, -s * 0.44 * squash),
			c + Vector2(side * s * 0.36, -s * 0.40 * squash),
			c + Vector2(side * s * 0.32, -s * 0.84 * squash),
		]), _c(horn, al))
	ci.draw_colored_polygon(_ellipse(c, s * 0.5 * squash, s * 0.5 / squash, 26), _c(body, al))
	ci.draw_arc(c, s * 0.5, 0.0, TAU, 28, _c(color.lerp(Color.WHITE, flash), 0.9 * al), 2.0 * u)
	for side in [-1.0, 1.0]:
		var eye: Vector2 = c + Vector2(side * s * 0.19, -s * 0.06)
		ci.draw_circle(eye, s * 0.11, _c(Color("#FFF7D6"), al))
		ci.draw_circle(eye + Vector2(toward * s * 0.04, s * 0.01), s * 0.055, _c(INK, al))
		ci.draw_line(eye + Vector2(side * s * 0.13, -s * 0.17), eye + Vector2(-side * s * 0.09, -s * 0.09), _c(BLACKOUT, al), 2.0 * u)
	var mouth := PackedVector2Array()
	for i in range(7):
		mouth.append(c + Vector2(-s * 0.16 + float(i) * s * 0.0533, s * 0.2 + (s * 0.04 if i % 2 == 0 else -s * 0.02)))
	ci.draw_polyline(mouth, _c(BLACKOUT, al), 2.0 * u)
	for side in [-1.0, 1.0]:
		var fang: Vector2 = c + Vector2(side * s * 0.08, s * 0.2)
		ci.draw_colored_polygon(PackedVector2Array([fang + Vector2(-s * 0.03, 0.0), fang + Vector2(s * 0.03, 0.0), fang + Vector2(0.0, s * 0.09)]), _c(Color.WHITE, al))


## Draws the boss of `kind` ("king" or "hydra"); see brawl_enemies.gd BOSS_KINDS.
static func draw_boss_kind(ci: CanvasItem, kind: String, x: float, ground_y: float, s: float, flash: bool, age: int, toward: float, u: float) -> void:
	if kind == "hydra":
		Hydra.draw(ci, x, ground_y, s, flash, age, toward, u)
	else:
		draw_boss(ci, x, ground_y, s, flash, age, toward, u)


## The Grumble King: a hulking crowned shadow with a pulsing pink aura.
static func draw_boss(ci: CanvasItem, x: float, ground_y: float, s: float, flash: bool, age: int, toward: float, u: float) -> void:
	var t: float = float(age)
	var hop: float = absf(sin(t * 0.09)) * 4.0 * u
	var c := Vector2(x, ground_y - s * 0.5 - hop)
	var body: Color = Color.WHITE if flash else Color("#2D1060")
	var pulse: float = 1.0 + sin(t * 0.12) * 0.04

	ci.draw_circle(c, s * 0.66 * pulse, Color(1.0, 0.37, 0.64, 0.14))
	for side in [-1.0, 1.0]:
		ci.draw_colored_polygon(PackedVector2Array([
			c + Vector2(side * s * 0.30, -s * 0.34),
			c + Vector2(side * s * 0.50, -s * 0.30),
			c + Vector2(side * s * 0.56, -s * 0.72),
		]), Color("#7C3AED"))
		ci.draw_circle(c + Vector2(side * s * 0.22, s * 0.44), s * 0.14, body)
	ci.draw_colored_polygon(_ellipse(c, s * 0.5, s * 0.5, 30), body)
	ci.draw_arc(c, s * 0.5, 0.0, TAU, 32, PINK, 3.0 * u)

	# Crown.
	var cb: float = c.y - s * 0.44
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(c.x - s * 0.30, cb), Vector2(c.x - s * 0.30, cb - s * 0.20), Vector2(c.x - s * 0.15, cb - s * 0.08),
		Vector2(c.x, cb - s * 0.26), Vector2(c.x + s * 0.15, cb - s * 0.08), Vector2(c.x + s * 0.30, cb - s * 0.20),
		Vector2(c.x + s * 0.30, cb),
	]), GOLD)
	ci.draw_circle(Vector2(c.x, cb - s * 0.06), s * 0.035, PINK)

	for side in [-1.0, 1.0]:
		var eye: Vector2 = c + Vector2(side * s * 0.2, -s * 0.08)
		ci.draw_circle(eye, s * 0.11, PINK)
		ci.draw_circle(eye + Vector2(toward * s * 0.04, 0.0), s * 0.05, Color("#FFF7D6"))
		ci.draw_line(eye + Vector2(side * s * 0.15, -s * 0.15), eye + Vector2(-side * s * 0.1, -s * 0.07), BLACKOUT, 3.0 * u)
	var jaw_y: float = c.y + s * 0.2
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(c.x - s * 0.26, jaw_y), Vector2(c.x + s * 0.26, jaw_y),
		Vector2(c.x + s * 0.2, jaw_y + s * 0.15), Vector2(c.x - s * 0.2, jaw_y + s * 0.15),
	]), BLACKOUT)
	for i in range(5):
		var tx: float = c.x - s * 0.2 + float(i) * s * 0.1
		ci.draw_colored_polygon(PackedVector2Array([Vector2(tx - s * 0.035, jaw_y), Vector2(tx + s * 0.035, jaw_y), Vector2(tx, jaw_y + s * 0.07)]), Color.WHITE)
