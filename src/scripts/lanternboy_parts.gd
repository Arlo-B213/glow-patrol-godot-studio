extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Shared building blocks for the Lanternboy portraits (Story 009, upgraded in Story 032):
## chibi face with expressions and rich eyes, gradient hair, mouths, glowing lanterns, moths.
## Everything is drawn in the 100 x 130 design space set up by LanternboyArt, onto a CanvasItem
## from its _draw(). All polygons are simple.
##
## Per-draw state lives in the static vars below; LanternboyArt.draw() sets them before drawing
## (single-threaded draw code, so this stays deterministic).

const S := preload("res://scripts/hunter_shade.gd")
const Expr := preload("res://scripts/hunter_expr.gd")
const Hair := preload("res://scripts/hunter_hair.gd")
const OW := 1.2
const MOUTH := Color("#8A3A45")
const NO_RIM := Color(0.0, 0.0, 0.0, 0.0)

## Expression id for the face (see hunter_expr.gd), eye closure 0..1, hair/cloth sway, iris
## gaze offset (-1..1) and the lantern rim light colour + side (-1 left, 1 right, 0 below).
static var expr: String = "neutral"
static var closed: float = 0.0
static var sway: float = 0.0
static var gaze: Vector2 = Vector2.ZERO
static var rim: Color = NO_RIM
static var rim_dir: float = 1.0
## Per-boy brow personality: x = extra raise, y = extra tilt (+ angrier, - gentler).
static var brow_bias: Vector2 = Vector2.ZERO


## Shorthand for a design-space point.
static func v(x: float, y: float) -> Vector2:
	return Vector2(x, y)


## Hair piece: gradient fill (light top, dark bottom), outline and optional highlight strokes
## (`strokes` = Array of PackedVector2Array or Array[Vector2]).
static func hair(ci: CanvasItem, pts: Array, col: Color, strokes: Array = []) -> void:
	var poly := PackedVector2Array(pts)
	var lo: float = poly[0].y
	var hi: float = poly[0].y
	for p in poly:
		lo = minf(lo, p.y)
		hi = maxf(hi, p.y)
	Hair.grad(ci, poly, S.lighten(col, 0.16), S.darken(col, 0.32), lo, hi)
	var closed_poly := PackedVector2Array(poly)
	closed_poly.append(poly[0])
	FD.polyline(ci, closed_poly, S.ink(col), OW, true)
	for st in strokes:
		FD.polyline(ci, PackedVector2Array(st), S.fade(S.lighten(col, 0.6), 0.85), 1.8, true)


## Chibi head: ears, gradient face with lantern rim light, expressive eyes (blink aware),
## brows and blush. `iris` is the eye colour, `blush` the cheek alpha, `look` a small iris offset.
## `blink` forces the eyes shut (in addition to the `closed` amount).
static func face(ci: CanvasItem, c: Vector2, blink: bool, iris: Color, blush: float = 0.35,
		look: Vector2 = Vector2.ZERO) -> void:
	var skin: Color = S.SKIN
	var e: Dictionary = Expr.params(expr)
	S.circle(ci, c + v(-23, 3), 4.2, skin, OW, S.ink(skin))
	S.circle(ci, c + v(23, 3), 4.2, skin, OW, S.ink(skin))
	var pts := S.ellipse(c, 23.0, 21.0, 28)
	var cols := PackedColorArray()
	for p in pts:
		var t: float = clampf((p.y - (c.y - 21.0)) / 42.0, 0.0, 1.0)
		cols.append(S.SKIN_LIGHT.lerp(skin, clampf(t * 2.0, 0.0, 1.0)).lerp(S.SKIN_SHADOW, clampf(t * 1.5 - 0.5, 0.0, 1.0)))
	FD.gpoly(ci, pts, cols)
	var outline := PackedVector2Array(pts)
	outline.append(pts[0])
	FD.polyline(ci, outline, S.ink(skin), OW, true)
	if rim.a > 0.0:
		var centre: Vector2 = c + v(rim_dir * 20.0, 4.0 if rim_dir != 0.0 else 22.0)
		for piece in Geometry2D.intersect_polygons(pts, S.ellipse(centre, 16.0, 14.0, 20)):
			FD.poly(ci, piece, S.fade(rim, 0.2))
		var a0: float = -0.9 if rim_dir > 0.0 else (PI + 0.9 if rim_dir < 0.0 else 0.6)
		FD.arc(ci, c, 22.0, a0, a0 + (1.9 if rim_dir >= 0.0 else -1.9), 12, S.fade(S.lighten(rim, 0.5), 0.8), 1.8, true)
	var b: float = float(e["blush"]) * blush / 0.35
	var cl: float = 1.0 if blink else closed
	for sx in [-1.0, 1.0]:
		Expr.blush(ci, c + v(sx * 14.5, 11.0), 4.2, clampf(b, 0.0, 1.6), 1.0)
		_eye(ci, c + v(sx * 10.0, 3.0), cl, iris, look + gaze, sx, e)
		var bp := e.duplicate()
		bp["raise"] = float(e["raise"]) + brow_bias.x
		bp["tilt"] = float(e["tilt"]) + brow_bias.y
		Expr.brow(ci, c + v(sx * 10.0, -9.0), 1.45, sx, S.fade(S.darken(S.INK, 0.0), 0.8), bp, 1.2)


static func _eye(ci: CanvasItem, e: Vector2, shut: float, iris: Color, look: Vector2, side: float, ep: Dictionary) -> void:
	var shape: String = String(ep["shape"])
	var open: float = float(ep["open"]) * (1.0 - shut * 0.93)
	if shape == "arch" and shut < 0.5:
		FD.polyline(ci, PackedVector2Array([e + v(-6, 2), e + v(-3.5, -2.2), e + v(0, -3.6), e + v(3.5, -2.2), e + v(6, 2)]), S.INK, 2.2, true)
		ci.draw_line(e + v(side * 6, 2), e + v(side * 8.4, 0.2), S.INK, 1.5)
		return
	if shape == "closed" or open * 7.4 < 2.0:
		FD.arc(ci, e + v(0, -1), 5.6, 0.2, PI - 0.2, 10, S.INK, 1.9, true)
		ci.draw_line(e + v(side * 5.6, 0.6), e + v(side * 8.0, -1.4), S.INK, 1.4)
		if float(ep["tear"]) > 0.0:
			FD.arc(ci, e + v(0, 1), 5.0, 0.4, PI - 0.4, 8, S.fade(Expr.TEAR, 0.7), 1.2, true)
		return
	var ry: float = 7.4 * open
	S.fill(ci, S.ellipse(e, 6.2, ry, 18), Color(1, 1, 1, 0.97), 0.9, S.ink(Color(0.9, 0.85, 0.95)))
	var ie: Vector2 = e + v(clampf(look.x, -1.0, 1.0) * 1.5, clampf(look.y, -1.0, 1.0) * 1.5 * minf(open, 1.0))
	var ipts := S.ellipse(ie, 4.8, 6.0 * open, 16)
	var cols := PackedColorArray()
	for p in ipts:
		var t: float = clampf((p.y - (ie.y - 6.0 * open)) / maxf(12.0 * open, 0.01), 0.0, 1.0)
		cols.append(S.darken(iris, 0.5).lerp(iris, clampf(t * 2.0, 0.0, 1.0)).lerp(S.lighten(iris, 0.5), clampf(t * 2.0 - 1.0, 0.0, 1.0)))
	FD.gpoly(ci, ipts, cols)
	FD.arc(ci, ie, 4.8, 0.0, TAU, 16, S.fade(S.darken(iris, 0.6), 0.8), 0.8, true)
	var pr: float = float(ep["pupil"])
	FD.poly(ci, S.ellipse(ie + v(0, 0.6), 2.5 * pr, 2.7 * pr * minf(open, 1.0), 12), S.INK)
	FD.circle(ci, ie + v(-1.7, -2.4 * minf(open, 1.0)), 1.8, Color(1, 1, 1, 0.95))
	FD.circle(ci, ie + v(1.8, 2.6 * minf(open, 1.0)), 0.9, Color(1, 1, 1, 0.8))
	FD.arc(ci, e + v(0, -0.6), 6.5, PI * 1.08, PI * 1.92, 10, S.INK, 2.4, true)
	ci.draw_line(e + v(side * 6.2, -2.4), e + v(side * 8.8, -4.6 * minf(open, 1.0)), S.INK, 1.6)
	ci.draw_line(e + v(side * 5.2, -4.6 * minf(open, 1.0)), e + v(side * 7.2, -6.4 * minf(open, 1.0)), S.fade(S.INK, 0.7), 1.1)
	FD.arc(ci, e + v(0, -ry - 1.6), 5.2, PI * 1.15, PI * 1.85, 8, S.fade(S.SKIN_SHADOW, 0.7), 0.9, true)
	ci.draw_line(e + v(-2.4, ry + 0.8), e + v(2.4, ry + 0.8), S.fade(S.INK, 0.35), 0.9)
	if float(ep["tear"]) > 0.0:
		FD.arc(ci, e + v(0, 1.5), 5.4, 0.5, PI - 0.5, 8, S.fade(Expr.TEAR, 0.6 * float(ep["tear"])), 1.2, true)


## Mouth at `p`: "smile", "smirk", "grin" (open, energetic) or "shy" (tiny). When the active
## expression is not neutral the expression's own mouth shape wins.
static func mouth(ci: CanvasItem, p: Vector2, kind: String) -> void:
	if expr != "neutral":
		Expr.mouth(ci, p + v(0, 1), 0.95, String(Expr.params(expr)["mouth"]), 1.0)
		return
	match kind:
		"grin":
			var pts := PackedVector2Array()
			for i in range(11):
				var a: float = PI * float(i) / 10.0
				pts.append(p + v(cos(a) * 7.0, sin(a) * 6.0))
			S.fill(ci, pts, MOUTH, 1.0, S.ink(MOUTH))
			FD.poly(ci, S.ellipse(p + v(0, 4.2), 3.6, 1.8, 10), Color("#FF8E9C"))
			ci.draw_line(p + v(-6.5, 0), p + v(6.5, 0), Color(1, 1, 1, 0.9), 1.6)
		"smirk":
			FD.arc(ci, p + v(1, 0), 4.6, 0.2, PI - 0.5, 10, MOUTH, 1.7, true)
			ci.draw_line(p + v(5.4, 2.2), p + v(6.4, 1.0), MOUTH, 1.2)
		"shy":
			FD.arc(ci, p, 2.4, 0.3, PI - 0.3, 8, MOUTH, 1.4, true)
		_:
			FD.arc(ci, p, 4.6, 0.25, PI - 0.25, 10, MOUTH, 1.7, true)


## Eyebrow line from `a` to `b` (legacy; faces draw their own expressive brows now).
static func brow(ci: CanvasItem, a: Vector2, b: Vector2, col: Color) -> void:
	pass


## Glowing lantern centred at `pos` with body width `s`. Gold frame, warm core, soft halo.
## `pulse` (0..1) brightens the glow.
static func lantern(ci: CanvasItem, pos: Vector2, s: float, accent: Color, pulse: float) -> void:
	var w: float = s * 0.5
	var h: float = s * 0.7
	for i in range(4):
		var r: float = s * (2.0 - 0.4 * float(i))
		FD.circle(ci, pos, r, S.fade(accent, 0.04 + 0.035 * pulse + 0.025 * float(i)))
	var frame: Color = S.darken(accent, 0.15)
	FD.arc(ci, pos + v(0, -h - s * 0.12), s * 0.28, PI, TAU, 10, frame, maxf(1.2, s * 0.07), true)
	S.fill(ci, [pos + v(-w * 0.7, -h - s * 0.14), pos + v(w * 0.7, -h - s * 0.14),
		pos + v(w * 1.05, -h + s * 0.04), pos + v(-w * 1.05, -h + s * 0.04)], frame, 0.8, S.ink(frame))
	var body := S.ellipse(pos, w, h, 18)
	S.fill(ci, body, S.fade(S.lighten(accent, 0.55), 0.9), 0.0, frame)
	FD.poly(ci, S.ellipse(pos, w * 0.62, h * 0.66, 14),
		S.fade(S.lighten(accent, 0.8), 0.7 + 0.3 * pulse))
	FD.circle(ci, pos, w * 0.3, Color(1, 1, 0.92, 0.7 + 0.3 * pulse))
	var closed_pts := PackedVector2Array(S.ellipse(pos, w * 0.5, h, 14))
	closed_pts.append(closed_pts[0])
	FD.polyline(ci, closed_pts, frame, maxf(0.9, s * 0.05), true)
	var outer := PackedVector2Array(body)
	outer.append(outer[0])
	FD.polyline(ci, outer, frame, maxf(1.0, s * 0.07), true)
	FD.polyline(ci, PackedVector2Array([pos + v(-w * 0.62, -h * 0.5), pos + v(-w * 0.8, 0), pos + v(-w * 0.62, h * 0.5)]), S.fade(Color.WHITE, 0.6), maxf(1.0, s * 0.06), true)
	S.fill(ci, [pos + v(-w * 0.6, h), pos + v(w * 0.6, h),
		pos + v(w * 0.4, h + s * 0.16), pos + v(-w * 0.4, h + s * 0.16)], frame, 0.8, S.ink(frame))
	for i in range(3):
		ci.draw_line(pos + v((float(i) - 1.0) * w * 0.35, h + s * 0.16), pos + v((float(i) - 1.0) * w * 0.5 + sway * 0.1, h + s * (0.4 + 0.06 * float(i))), S.fade(frame, 0.8), 0.9, true)


## Warm lantern light cast on a clothing polygon `pts` from the lantern at `lp`: a soft glow
## disc clipped to the garment plus a thin rim stroke along the edge `a` -> `b` facing the light.
static func cast_light(ci: CanvasItem, pts: Array, lp: Vector2, accent: Color, pulse: float, a: Vector2, b: Vector2) -> void:
	var poly := PackedVector2Array(pts)
	for piece in Geometry2D.intersect_polygons(poly, S.ellipse(lp, 22.0, 22.0, 20)):
		FD.poly(ci, piece, S.fade(accent, 0.13 + 0.07 * pulse))
	ci.draw_line(a, b, S.fade(S.lighten(accent, 0.5), 0.7), 1.5, true)


## A tiny moth at `pos`; `flap` (0..1) opens/closes the wings.
static func moth(ci: CanvasItem, pos: Vector2, size: float, flap: float, col: Color) -> void:
	var wing: float = size * (0.45 + 0.55 * flap)
	for sx in [-1.0, 1.0]:
		var wc: Vector2 = pos + v(sx * size * 0.55 * (0.5 + 0.5 * flap), -size * 0.1)
		S.fill(ci, S.ellipse(wc, wing * 0.8, size * 0.55, 10), S.fade(col, 0.92), 0.7, S.ink(col))
		FD.circle(ci, wc, size * 0.14, S.fade(S.darken(col, 0.3), 0.6))
	FD.poly(ci, S.ellipse(pos + v(0, size * 0.1), size * 0.16, size * 0.5, 8), S.darken(col, 0.5))
	ci.draw_line(pos + v(0, -size * 0.35), pos + v(-size * 0.25, -size * 0.7), S.darken(col, 0.5), 0.7)
	ci.draw_line(pos + v(0, -size * 0.35), pos + v(size * 0.25, -size * 0.7), S.darken(col, 0.5), 0.7)


## Hand: palm with four finger bumps and a thumb, outlined.
static func hand(ci: CanvasItem, p: Vector2, r: float = 4.0) -> void:
	S.circle(ci, p, r, S.SKIN, OW, S.ink(S.SKIN))
	for i in range(3):
		FD.circle(ci, p + v((float(i) - 1.0) * r * 0.55, r * 0.55), r * 0.3, S.SKIN_LIGHT)
		FD.arc(ci, p + v((float(i) - 1.0) * r * 0.55, r * 0.55), r * 0.3, 0.0, PI, 5, S.fade(S.ink(S.SKIN), 0.8), 0.7, true)
	S.fill(ci, S.ellipse(p + v(-r * 0.8, -r * 0.2), r * 0.38, r * 0.3, 8), S.SKIN_LIGHT, 0.7, S.ink(S.SKIN))


## Shoe with sole and highlight.
static func shoe(ci: CanvasItem, p: Vector2, col: Color) -> void:
	S.fill(ci, S.ellipse(p, 6.6, 3.6, 12), col, OW, S.ink(col))
	ci.draw_line(p + v(-5.6, 1.6), p + v(5.6, 1.6), S.fade(Color("#F4F0FF"), 0.85), 1.4)
	FD.arc(ci, p + v(1, -0.6), 3.4, PI * 1.15, PI * 1.85, 6, S.fade(S.lighten(col, 0.55), 0.8), 1.1, true)
