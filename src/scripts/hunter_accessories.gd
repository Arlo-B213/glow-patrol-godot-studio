extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Headwear and face accessories for the idol hunter, drawn by HunterArt in both the
## side-view battle pose and the front-facing portrait. Every function draws onto a
## CanvasItem and must be called from its _draw(). Ids match GameState.HEADWEAR and
## GameState.FACE_ACC; "none" (or any unknown id) draws nothing.

const INK := Color("#1A0B33")
const GOLD := Color("#FFD36E")
const PINK := Color("#FF5FA2")
const PETALS := [Color("#FF8FBF"), Color("#FFFFFF"), Color("#C9B8FF")]
const LEAF := Color("#52C98E")
const FRECKLE := Color("#B9714F")
const BLUSH := Color(1.0, 0.35, 0.5)


static func _c(col: Color, a: float) -> Color:
	return Color(col.r, col.g, col.b, col.a * a)


static func _pt(origin: Vector2, k: float, x: float, y: float) -> Vector2:
	return origin + Vector2(x, y) * k


## Filled polygon with a thin dark outline so pieces read against similar hair colours.
static func _poly(ci: CanvasItem, pts: PackedVector2Array, fill: Color, outline: Color, width: float) -> void:
	FD.poly(ci, pts, fill)
	var closed := PackedVector2Array(pts)
	closed.append(pts[0])
	FD.polyline(ci, closed, outline, width)


static func _star_points(center: Vector2, r_out: float, r_in: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(10):
		var a: float = -PI / 2.0 + TAU * float(i) / 10.0
		var r: float = r_out if i % 2 == 0 else r_in
		pts.append(center + Vector2(cos(a) * r, sin(a) * r))
	return pts


static func _star(ci: CanvasItem, center: Vector2, r: float, fill: Color, outline: Color, width: float) -> void:
	_poly(ci, _star_points(center, r, r * 0.45), fill, outline, width)


static func _bow(ci: CanvasItem, c: Vector2, k: float, wing: float, alpha: float) -> void:
	var edge: Color = _c(PINK.lerp(INK, 0.55), alpha)
	var fill: Color = _c(PINK, alpha)
	for side in [-1.0, 1.0]:
		_poly(ci, PackedVector2Array([
			c,
			c + Vector2(side * wing, -wing * 0.55) * k,
			c + Vector2(side * wing * 1.05, wing * 0.1) * k,
			c + Vector2(side * wing, wing * 0.6) * k,
		]), fill, edge, maxf(1.0, 0.18 * wing * k))
	FD.circle(ci, c, wing * 0.3 * k, _c(PINK.lerp(Color.WHITE, 0.35), alpha))
	FD.arc(ci, c, wing * 0.3 * k, 0.0, TAU, 12, edge, maxf(1.0, 0.14 * wing * k))


static func _flower(ci: CanvasItem, c: Vector2, r: float, tint: Color, alpha: float) -> void:
	for i in range(5):
		var a: float = TAU * float(i) / 5.0 - PI / 2.0
		FD.circle(ci, c + Vector2(cos(a), sin(a)) * r * 0.62, r * 0.46, _c(tint, alpha))
	FD.circle(ci, c, r * 0.4, _c(GOLD, alpha))


static func _ring_of_flowers(ci: CanvasItem, center: Vector2, radius: float, a0: float, a1: float, count: int, r: float, alpha: float) -> void:
	for i in range(count - 1):
		var mid: float = lerpf(a0, a1, (float(i) + 0.5) / float(count - 1))
		var lp: Vector2 = center + Vector2(cos(mid), sin(mid)) * radius
		FD.circle(ci, lp, r * 0.55, _c(LEAF, alpha))
	for i in range(count):
		var a: float = lerpf(a0, a1, float(i) / float(count - 1))
		var p: Vector2 = center + Vector2(cos(a), sin(a)) * radius
		_flower(ci, p, r, PETALS[i % PETALS.size()], alpha)


static func _cat_ear(ci: CanvasItem, pts: PackedVector2Array, inner: PackedVector2Array, hair: Color, alpha: float, width: float) -> void:
	_poly(ci, pts, _c(hair, alpha), _c(hair.lerp(INK, 0.5), alpha), width)
	FD.poly(ci, inner, _c(Color("#FF9CC4"), alpha))


# ---------------- Side view (battle pose) ----------------

## Headwear on the side-view head. `head` is the face centre, `u` the layout scale,
## `f` the facing (-1 or 1).
static func draw_headwear_side(ci: CanvasItem, id: String, head: Vector2, u: float, f: float, hair: Color, alpha: float) -> void:
	var w: float = maxf(1.0, 1.1 * u)
	match id:
		"bow":
			_bow(ci, _pt(head, u, -f * 6.0, -15.0), u, 8.0, alpha)
		"star-clip":
			_star(ci, _pt(head, u, f * 3.0, -16.5), 5.0 * u, _c(GOLD, alpha), _c(Color("#B8860B"), alpha), w)
		"flower-crown":
			_ring_of_flowers(ci, _pt(head, u, 0.0, -1.0), 15.0 * u, PI * 1.08, PI * 1.92, 5, 3.4 * u, alpha)
		"cat-ears":
			for side in [-1.0, 1.0]:
				var pts := PackedVector2Array([
					_pt(head, u, side * 13.0, -7.0), _pt(head, u, side * 11.5, -25.0), _pt(head, u, side * 2.0, -13.5),
				])
				var inner := PackedVector2Array([
					_pt(head, u, side * 11.0, -10.0), _pt(head, u, side * 10.5, -20.0), _pt(head, u, side * 5.0, -13.5),
				])
				_cat_ear(ci, pts, inner, hair, alpha, w)


## Face accessory on the side-view face; eye and cheek positions mirror HunterArt.
static func draw_face_side(ci: CanvasItem, id: String, head: Vector2, u: float, f: float, alpha: float) -> void:
	match id:
		"blush":
			for side in [-1.0, 1.0]:
				FD.circle(ci, _pt(head, u, f * 4.0 + side * 7.5, 6.0), 3.3 * u, _c(BLUSH, 0.7 * alpha))
		"glasses":
			var gold: Color = _c(GOLD, alpha)
			for side in [-1.0, 1.0]:
				var e: Vector2 = _pt(head, u, f * 4.0 + side * 4.5, 1.0)
				var pts: PackedVector2Array = _star_points(e, 5.2 * u, 3.0 * u)
				FD.poly(ci, pts, _c(Color.WHITE, 0.2 * alpha))
				pts.append(pts[0])
				FD.polyline(ci, pts, gold, maxf(1.0, 1.1 * u))
			ci.draw_line(_pt(head, u, f * 4.0 - 0.6, 0.8), _pt(head, u, f * 4.0 + 0.6, 0.8), gold, maxf(1.0, 1.1 * u))
		"freckles":
			for side in [-1.0, 1.0]:
				var c: Vector2 = _pt(head, u, f * 4.0 + side * 7.5, 5.0)
				for d in [Vector2(-1.8, -0.4), Vector2(0.4, -1.4), Vector2(1.6, 0.6), Vector2(-0.3, 1.5)]:
					FD.circle(ci, c + d * u, 0.65 * u, _c(FRECKLE, alpha))


# ---------------- Front view (portrait) ----------------
# Portrait head: face radius 24 around `head`, `k` pixels per figure unit.

## Headwear on the front-facing head.
static func draw_headwear_front(ci: CanvasItem, id: String, head: Vector2, k: float, hair: Color, alpha: float) -> void:
	var w: float = maxf(1.0, 1.0 * k)
	match id:
		"bow":
			_bow(ci, _pt(head, k, 13.0, -27.0), k, 13.0, alpha)
		"star-clip":
			_star(ci, _pt(head, k, 15.0, -19.0), 8.0 * k, _c(GOLD, alpha), _c(Color("#B8860B"), alpha), w)
		"flower-crown":
			_ring_of_flowers(ci, _pt(head, k, 0.0, -1.0), 26.5 * k, PI * 1.02, PI * 1.98, 7, 5.6 * k, alpha)
		"cat-ears":
			for side in [-1.0, 1.0]:
				var pts := PackedVector2Array([
					_pt(head, k, side * 25.0, -10.0), _pt(head, k, side * 20.0, -43.0), _pt(head, k, side * 5.0, -27.0),
				])
				var inner := PackedVector2Array([
					_pt(head, k, side * 22.0, -16.0), _pt(head, k, side * 19.0, -36.0), _pt(head, k, side * 9.0, -27.0),
				])
				_cat_ear(ci, pts, inner, hair, alpha, w)


## Face accessory on the front-facing face. Eyes sit at (+-9.5, 3), cheeks at (+-15, 10).
static func draw_face_front(ci: CanvasItem, id: String, head: Vector2, k: float, alpha: float) -> void:
	match id:
		"blush":
			for side in [-1.0, 1.0]:
				FD.circle(ci, _pt(head, k, side * 15.0, 10.5), 6.0 * k, _c(BLUSH, 0.65 * alpha))
		"glasses":
			var gold: Color = _c(GOLD, alpha)
			var lw: float = maxf(1.0, 1.5 * k)
			for side in [-1.0, 1.0]:
				var pts: PackedVector2Array = _star_points(_pt(head, k, side * 9.5, 3.0), 9.0 * k, 5.2 * k)
				FD.poly(ci, pts, _c(Color.WHITE, 0.2 * alpha))
				pts.append(pts[0])
				FD.polyline(ci, pts, gold, lw)
			ci.draw_line(_pt(head, k, -1.5, 1.5), _pt(head, k, 1.5, 1.5), gold, lw)
			for side in [-1.0, 1.0]:
				ci.draw_line(_pt(head, k, side * 18.0, 1.5), _pt(head, k, side * 24.0, -1.0), gold, lw)
		"freckles":
			for side in [-1.0, 1.0]:
				var c: Vector2 = _pt(head, k, side * 15.0, 9.0)
				for d in [Vector2(-3.5, -1.0), Vector2(0.0, -3.0), Vector2(3.5, -0.5), Vector2(-1.5, 2.5), Vector2(2.0, 3.0)]:
					FD.circle(ci, c + d * k, 1.15 * k, _c(FRECKLE, alpha))
