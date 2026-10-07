extends RefCounted
## Code-drawn art for Glow Bubbles (Story 028): glowing orbs with a colour-blind-friendly shape
## inside (heart, star, leaf, moon, bolt), plus rainbow and bomb specials. Circles and simple
## (non-self-crossing) polygons only.

const Grid := preload("res://scenes/games/bubbles_grid.gd")
const COLORS: Array[Color] = [Color("#FF5FA2"), Color("#FFC15E"), Color("#3FD9A6"), Color("#9B86FF"), Color("#4FB6FF")]
const ICONS: Array[String] = ["heart", "star", "leaf", "moon", "bolt"]

static var _shapes := {}


## Unit-size (radius 1) outline of an icon, centred on the origin.
static func shape(icon: String) -> PackedVector2Array:
	if _shapes.has(icon):
		return _shapes[icon]
	var pts := PackedVector2Array()
	match icon:
		"star":
			for i in 10:
				var a: float = -PI * 0.5 + float(i) * PI / 5.0
				var rr: float = 1.0 if i % 2 == 0 else 0.45
				pts.append(Vector2(cos(a), sin(a)) * rr)
		"heart":
			for i in 28:
				var t: float = float(i) / 28.0 * TAU
				var x: float = 16.0 * pow(sin(t), 3.0)
				var y: float = -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t))
				pts.append(Vector2(x, y + 1.5) / 16.5)
		"moon":
			for i in 13:
				var a: float = deg_to_rad(50.0 + float(i) * 260.0 / 12.0)
				pts.append(Vector2(cos(a), sin(a)) * 1.05 - Vector2(0.15, 0.0))
			for i in 13:
				var a2: float = deg_to_rad(284.2 - float(i) * 208.4 / 12.0)
				pts.append(Vector2(0.45 + cos(a2) * 0.79, sin(a2) * 0.79) * 1.05 - Vector2(0.15, 0.0))
		"bolt":
			pts = PackedVector2Array([Vector2(0.25, -1.0), Vector2(-0.65, 0.12), Vector2(-0.08, 0.12), Vector2(-0.3, 1.0), Vector2(0.65, -0.18), Vector2(0.08, -0.18)])
		_:  # leaf: a lens shape
			for i in 9:
				var f: float = float(i) / 8.0
				pts.append(Vector2(-0.8 + 1.6 * f, -sin(f * PI) * 0.62))
			for i in range(7, 0, -1):
				var f2: float = float(i) / 8.0
				pts.append(Vector2(-0.8 + 1.6 * f2, sin(f2 * PI) * 0.62))
	_shapes[icon] = pts
	return pts


## Draws one orb of kind `kind` (0..4 colours, 5 rainbow, 6 bomb) centred at `c` with radius `r`.
## `t` animates the shine and the special orbs (pass 0 when calm).
static func draw_orb(ci: CanvasItem, c: Vector2, r: float, kind: int, t: float = 0.0, alpha: float = 1.0) -> void:
	if kind == Grid.SPECIAL_RAINBOW:
		_rainbow(ci, c, r, t, alpha)
		return
	if kind == Grid.SPECIAL_BOMB:
		_bomb(ci, c, r, t, alpha)
		return
	var col: Color = COLORS[clampi(kind, 0, COLORS.size() - 1)]
	ci.draw_circle(c, r * 1.12, Color(col, 0.16 * alpha))
	ci.draw_circle(c, r * 0.94, Color(col.darkened(0.35), alpha))
	ci.draw_circle(c + Vector2(0.0, -r * 0.04), r * 0.84, Color(col, alpha))
	ci.draw_circle(c + Vector2(-r * 0.3, -r * 0.34), r * 0.2, Color(1, 1, 1, 0.42 * alpha))
	_icon(ci, c + Vector2(0.0, r * 0.05), r * 0.5, ICONS[clampi(kind, 0, ICONS.size() - 1)], Color(1, 1, 1, 0.88 * alpha))


static func _icon(ci: CanvasItem, c: Vector2, s: float, icon: String, col: Color) -> void:
	var base: PackedVector2Array = shape(icon)
	var pts := PackedVector2Array()
	for p in base:
		pts.append(c + p * s)
	ci.draw_colored_polygon(pts, col)


static func _rainbow(ci: CanvasItem, c: Vector2, r: float, t: float, alpha: float) -> void:
	ci.draw_circle(c, r * 1.12, Color(1, 1, 1, 0.14 * alpha))
	for i in 5:
		var a0: float = t * 1.5 + float(i) * TAU / 5.0
		ci.draw_arc(c, r * 0.62, a0, a0 + TAU / 5.0 + 0.04, 8, Color(COLORS[i], alpha), r * 0.62, true)
	ci.draw_arc(c, r * 0.93, 0.0, TAU, 28, Color(1, 1, 1, 0.9 * alpha), 2.5, true)
	ci.draw_circle(c, r * 0.22, Color(1, 1, 1, 0.9 * alpha))


static func _bomb(ci: CanvasItem, c: Vector2, r: float, t: float, alpha: float) -> void:
	ci.draw_circle(c, r * 1.12, Color(1.0, 0.45, 0.2, 0.18 * alpha))
	ci.draw_circle(c, r * 0.94, Color("#1B1233", alpha))
	ci.draw_circle(c, r * 0.8, Color("#3A2A66", alpha))
	ci.draw_circle(c + Vector2(-r * 0.3, -r * 0.3), r * 0.18, Color(1, 1, 1, 0.35 * alpha))
	ci.draw_arc(c, r * 0.94, 0.0, TAU, 28, Color("#FF9A4D", 0.9 * alpha), 2.5, true)
	var spark: float = 0.6 + 0.4 * sin(t * 14.0)
	var tip: Vector2 = c + Vector2(r * 0.2, -r * 0.95)
	ci.draw_line(c + Vector2(0.0, -r * 0.7), tip, Color("#FFC15E", alpha), 2.5)
	ci.draw_circle(tip, r * 0.2 * spark + 2.0, Color("#FF5FA2", alpha))
	ci.draw_circle(tip, r * 0.1, Color(1, 1, 1, alpha))
	_icon(ci, c + Vector2(0.0, r * 0.1), r * 0.36, "star", Color("#FFC15E", 0.9 * alpha))
