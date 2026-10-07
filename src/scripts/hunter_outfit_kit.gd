extends RefCounted
## Drawing kit shared by the outfit files (Story 015): figure-unit polygons with a soft
## outline, two-tone shaded garment pieces, stitching and small bead / star / glint details.
## All functions draw onto a CanvasItem inside its _draw(). `o` = origin, `s` = scale.
## Every polygon must be SIMPLE (non self-intersecting).

const Shade := preload("res://scripts/hunter_shade.gd")

const GOLD := Color("#FFD36E")
const INK := Color("#1A0B33")
const PINK := Color("#FF5FA2")


## `col` with alpha multiplied by `a`.
static func c(col: Color, a: float) -> Color:
	return Color(col.r, col.g, col.b, col.a * a)


static func _pts(o: Vector2, s: float, pts) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(o + (p as Vector2) * s)
	return out


## Filled polygon with a soft outline.
static func pl(ci: CanvasItem, o: Vector2, s: float, pts, col: Color) -> void:
	Shade.fill(ci, _pts(o, s, pts), col, maxf(1.0, 0.8 * s), Shade.ink(col))


## Filled polygon, no outline.
static func flat(ci: CanvasItem, o: Vector2, s: float, pts, col: Color) -> void:
	ci.draw_colored_polygon(_pts(o, s, pts), col)


## Big garment piece: outline, then a shadow crescent and a highlight (`light` -1 = from left).
static func part(ci: CanvasItem, o: Vector2, s: float, pts, col: Color, light: float = -1.0) -> void:
	var poly := _pts(o, s, pts)
	Shade.fill(ci, poly, col, maxf(1.0, 0.9 * s), Shade.ink(col))
	Shade.shade_band(ci, poly, col, light)


## Axis-aligned rectangle with outline.
static func rc(ci: CanvasItem, o: Vector2, s: float, pos: Vector2, sz: Vector2, col: Color) -> void:
	pl(ci, o, s, [pos, pos + Vector2(sz.x, 0), pos + sz, pos + Vector2(0, sz.y)], col)


static func ln(ci: CanvasItem, o: Vector2, s: float, a: Vector2, b: Vector2, col: Color, w: float) -> void:
	ci.draw_line(o + a * s, o + b * s, col, maxf(1.0, w * s))


## Dashed stitching line from `a` to `b` with `n` dashes.
static func stitch(ci: CanvasItem, o: Vector2, s: float, a: Vector2, b: Vector2, col: Color, n: int = 5) -> void:
	for i in range(n):
		var t0: float = (float(i) + 0.15) / float(n)
		var t1: float = (float(i) + 0.65) / float(n)
		ci.draw_line(o + a.lerp(b, t0) * s, o + a.lerp(b, t1) * s, col, maxf(1.0, 0.7 * s))


## Plain dot.
static func dot(ci: CanvasItem, o: Vector2, s: float, p: Vector2, r: float, col: Color) -> void:
	ci.draw_circle(o + p * s, r * s, col)


## Button / rivet: outlined disc with a small highlight dot.
static func bead(ci: CanvasItem, o: Vector2, s: float, p: Vector2, r: float, col: Color) -> void:
	Shade.circle(ci, o + p * s, r * s, col, maxf(1.0, 0.7 * s), Shade.ink(col))
	ci.draw_circle(o + (p + Vector2(-r * 0.3, -r * 0.3)) * s, maxf(0.6, r * 0.3 * s), Color(1, 1, 1, 0.75 * col.a))


## Ellipse points in figure units.
static func ell(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
	return Shade.ellipse(center, rx, ry, 14)


## Five-point star with outline.
static func star(ci: CanvasItem, o: Vector2, s: float, ctr: Vector2, r: float, col: Color) -> void:
	var pts: Array = []
	for i in range(10):
		var a: float = -PI * 0.5 + TAU * float(i) / 10.0
		pts.append(ctr + Vector2(cos(a), sin(a)) * (r if i % 2 == 0 else r * 0.45))
	pl(ci, o, s, pts, col)


## Four-point glint that twinkles with `tw`.
static func glint(ci: CanvasItem, o: Vector2, s: float, ctr: Vector2, r: float, tw: float, phase: float, col: Color) -> void:
	var rr: float = r * (0.55 + 0.45 * sin(tw + phase))
	flat(ci, o, s, [ctr + Vector2(0, -rr), ctr + Vector2(rr * 0.3, -rr * 0.3), ctr + Vector2(rr, 0), ctr + Vector2(rr * 0.3, rr * 0.3),
		ctr + Vector2(0, rr), ctr + Vector2(-rr * 0.3, rr * 0.3), ctr + Vector2(-rr, 0), ctr + Vector2(-rr * 0.3, -rr * 0.3)], col)


## Small paper lantern motif centred on `ctr`.
static func lantern(ci: CanvasItem, ctr: Vector2, s: float, body: Color, line: Color) -> void:
	var poly := PackedVector2Array()
	for p in ell(Vector2.ZERO, 5.0, 6.5):
		poly.append(ctr + p * s)
	Shade.fill(ci, poly, body, 1.0, Shade.ink(body))
	var w: float = maxf(1.0, 0.8 * s)
	ci.draw_line(ctr + Vector2(0, -8) * s, ctr + Vector2(0, -6) * s, line, maxf(1.0, s))
	ci.draw_line(ctr + Vector2(-2.5, -5) * s, ctr + Vector2(-2.5, 5) * s, line, w)
	ci.draw_line(ctr + Vector2(2.5, -5) * s, ctr + Vector2(2.5, 5) * s, line, w)
	ci.draw_line(ctr + Vector2(0, 6.5) * s, ctr + Vector2(0, 10) * s, line, maxf(1.0, s))


## Shaped torso silhouettes (Story 032): rounded shoulders, waist cinch, hip flare.
const TORSO_F: Array = [Vector2(-23, -53), Vector2(23, -53), Vector2(27.5, -49), Vector2(27, -41), Vector2(22, -33), Vector2(19.5, -26),
	Vector2(22, -22), Vector2(-22, -22), Vector2(-19.5, -26), Vector2(-22, -33), Vector2(-27, -41), Vector2(-27.5, -49)]
const TORSO_S: Array = [Vector2(-14, -75), Vector2(14, -75), Vector2(17, -71), Vector2(16, -62), Vector2(12.5, -52), Vector2(11, -46),
	Vector2(14, -40), Vector2(-14, -40), Vector2(-11, -46), Vector2(-12.5, -52), Vector2(-16, -62), Vector2(-17, -71)]


## Vertical sheen over a polygon of figure points: light at the top-left fading to shade.
static func sheen(ci: CanvasItem, o: Vector2, s: float, pts: Array, a: float) -> void:
	var poly := _pts(o, s, pts)
	var cols := PackedColorArray()
	for p in pts:
		var v: Vector2 = p
		var t: float = clampf((v.y + 75.0) / 55.0 + (v.x + 28.0) / 140.0, 0.0, 1.0)
		cols.append(Color(1, 1, 1, 0.2 * a * (1.0 - t)).lerp(Color(0.1, 0.04, 0.2, 0.28 * a), t))
	ci.draw_polygon(poly, cols)
