extends RefCounted
## Shared shading helpers for the idol hunter art (Story 015): soft outlines, two-tone
## shading and colour utilities. All functions draw onto a CanvasItem and must be called
## from its _draw(). Colours passed in should already carry the view alpha.
##
## Every polygon handed to these helpers must be SIMPLE (non self-intersecting), otherwise
## Godot silently fails with "Invalid polygon data, triangulation failed".

const SKIN := Color("#FFD9C2")
const SKIN_SHADOW := Color("#EDA894")
const SKIN_LIGHT := Color("#FFF0E4")
const INK := Color("#1A0B33")
const OUTLINE_ALPHA := 0.7
const MIN_PIECE_AREA := 0.4


## `col` with its alpha multiplied by `a`.
static func fade(col: Color, a: float) -> Color:
	return Color(col.r, col.g, col.b, col.a * a)


## `col` mixed toward white by `amount` (0..1), alpha kept.
static func lighten(col: Color, amount: float) -> Color:
	return col.lerp(Color(1.0, 1.0, 1.0, col.a), clampf(amount, 0.0, 1.0))


## `col` mixed toward a deep purple by `amount` (0..1), alpha kept.
static func darken(col: Color, amount: float) -> Color:
	return col.lerp(Color(0.1, 0.04, 0.2, col.a), clampf(amount, 0.0, 1.0))


## A good outline colour for a fill: darker and desaturated (a soft light rim for very dark
## fills so they still read on the dark battle backdrop), about 0.7 of the fill's alpha.
static func ink(col: Color) -> Color:
	var out: Color
	if col.get_luminance() < 0.16:
		out = col.lerp(Color(0.72, 0.62, 1.0), 0.4)
	else:
		out = col.lerp(Color(0.1, 0.04, 0.2), 0.6)
	out.s *= 0.8
	out.a = col.a * OUTLINE_ALPHA
	return out


## Ellipse polygon (simple, convex), `points` vertices.
static func ellipse(center: Vector2, rx: float, ry: float, points: int = 20) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(points):
		var a: float = TAU * float(i) / float(points)
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


## Capsule polygon (convex) from `a` to `b` with radius `r`.
static func capsule(a: Vector2, b: Vector2, r: float, seg: int = 7) -> PackedVector2Array:
	var d: float = (b - a).angle() if a != b else 0.0
	var pts := PackedVector2Array()
	for i in range(seg + 1):
		var an: float = d - PI * 0.5 + PI * float(i) / float(seg)
		pts.append(b + Vector2(cos(an), sin(an)) * r)
	for i in range(seg + 1):
		var an: float = d + PI * 0.5 + PI * float(i) / float(seg)
		pts.append(a + Vector2(cos(an), sin(an)) * r)
	return pts


## Tapered capsule (convex): radius `ra` at `a` and `rb` at `b`, `seg` points per end cap.
static func taper_pts(a: Vector2, b: Vector2, ra: float, rb: float, seg: int = 6) -> PackedVector2Array:
	var d: float = (b - a).angle() if a != b else 0.0
	var pts := PackedVector2Array()
	for i in range(seg + 1):
		var an: float = d - PI * 0.5 + PI * float(i) / float(seg)
		pts.append(b + Vector2(cos(an), sin(an)) * rb)
	for i in range(seg + 1):
		var an: float = d + PI * 0.5 + PI * float(i) / float(seg)
		pts.append(a + Vector2(cos(an), sin(an)) * ra)
	return pts


## Tapered limb of widths `wa` -> `wb` with outline, a 3-tone body (base, shadow stripe,
## highlight stripe) and an optional rim light `rim` (alpha 0 = none) on the lit side.
static func taper(ci: CanvasItem, a: Vector2, b: Vector2, wa: float, wb: float, col: Color, outline_w: float, light_side: float = -1.0, rim: Color = Color(0, 0, 0, 0)) -> void:
	ci.draw_colored_polygon(taper_pts(a, b, wa * 0.5 + outline_w, wb * 0.5 + outline_w), ink(col))
	ci.draw_colored_polygon(taper_pts(a, b, wa * 0.5, wb * 0.5), col)
	var n: Vector2 = (b - a).orthogonal().normalized()
	if n.x * light_side < 0.0 or (absf(n.x) < 0.01 and n.y > 0.0):
		n = -n
	ci.draw_line(a + n * wa * 0.24, b + n * wb * 0.24, fade(lighten(col, 0.35), 0.6), maxf(1.0, wb * 0.2))
	ci.draw_line(a - n * wa * 0.3, b - n * wb * 0.3, fade(darken(col, 0.3), 0.45), maxf(1.0, wb * 0.28))
	if rim.a > 0.0:
		ci.draw_line(a + n * wa * 0.46, b + n * wb * 0.46, rim, maxf(1.0, wb * 0.12), true)


## Filled simple polygon plus a closed soft outline of width `outline_w`.
static func fill(ci: CanvasItem, pts, col: Color, outline_w: float, outline_col: Color) -> void:
	var poly := PackedVector2Array(pts)
	if poly.size() < 3:
		return
	ci.draw_colored_polygon(poly, col)
	if outline_w > 0.0:
		var closed := PackedVector2Array(poly)
		closed.append(poly[0])
		ci.draw_polyline(closed, outline_col, outline_w, true)


## Filled circle plus an arc outline.
static func circle(ci: CanvasItem, center: Vector2, r: float, col: Color, outline_w: float, outline_col: Color) -> void:
	ci.draw_circle(center, r, col)
	if outline_w > 0.0:
		ci.draw_arc(center, r, 0.0, TAU, 24, outline_col, outline_w, true)


## Limb: a capsule from `a` to `b` of width `w` with outline, a lit stripe on the
## `light_side` (-1 left, 1 right) and a shadow stripe on the other.
static func limb(ci: CanvasItem, a: Vector2, b: Vector2, w: float, col: Color, outline_w: float, light_side: float = -1.0) -> void:
	ci.draw_colored_polygon(capsule(a, b, w * 0.5 + outline_w), ink(col))
	ci.draw_colored_polygon(capsule(a, b, w * 0.5), col)
	var n: Vector2 = (b - a).orthogonal().normalized()
	if n.x * light_side < 0.0 or (absf(n.x) < 0.01 and n.y > 0.0):
		n = -n
	ci.draw_line(a + n * w * 0.24, b + n * w * 0.24, fade(lighten(col, 0.35), 0.6), maxf(1.0, w * 0.2))
	ci.draw_line(a - n * w * 0.3, b - n * w * 0.3, fade(darken(col, 0.3), 0.45), maxf(1.0, w * 0.28))


## Two-tone overlay on a simple polygon already filled with `col`: a darker crescent on
## the side away from the light and a lighter crescent highlight on the lit side.
## `light_side` is -1 (light from the left) or 1 (from the right); light also comes from above.
static func shade_band(ci: CanvasItem, pts, col: Color, light_side: float, depth: float = -1.0) -> void:
	var poly := PackedVector2Array(pts)
	if poly.size() < 3:
		return
	var lo := poly[0]
	var hi := poly[0]
	for p in poly:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	var size: Vector2 = hi - lo
	var d: float = depth if depth > 0.0 else minf(size.x, size.y * 1.5) * 0.2
	var ldir: Vector2 = Vector2(light_side, -0.4).normalized() * d
	_draw_pieces(ci, Geometry2D.clip_polygons(poly, _shift(poly, ldir)), fade(darken(col, 0.25), 0.55))
	var c: Vector2 = (lo + hi) * 0.5
	var inner := PackedVector2Array()
	for p in poly:
		inner.append(c + (p - c) * 0.8)
	_draw_pieces(ci, Geometry2D.clip_polygons(inner, _shift(inner, -ldir * 0.6)), fade(lighten(col, 0.4), 0.5))


static func _shift(poly: PackedVector2Array, by: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(p + by)
	return out


static func _draw_pieces(ci: CanvasItem, pieces: Array, col: Color) -> void:
	for piece in pieces:
		var poly: PackedVector2Array = piece
		if poly.size() < 3:
			continue
		var area: float = 0.0
		for i in range(poly.size()):
			var q: Vector2 = poly[(i + 1) % poly.size()]
			area += poly[i].x * q.y - q.x * poly[i].y
		if absf(area) * 0.5 < MIN_PIECE_AREA:
			continue
		ci.draw_colored_polygon(poly, col)
