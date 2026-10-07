extends RefCounted
## Shared building blocks for the Lanternboy portraits (Story 009): chibi face, mouths,
## glowing lanterns and moths. Everything is drawn in the 100 x 130 design space set up by
## LanternboyArt, onto a CanvasItem from its _draw(). All polygons are simple.

const S := preload("res://scripts/hunter_shade.gd")
const OW := 1.2
const MOUTH := Color("#8A3A45")


## Shorthand for a design-space point.
static func v(x: float, y: float) -> Vector2:
	return Vector2(x, y)


## Chibi head: ears, face with two-tone shading, big eyes (blink aware) and blush.
## `iris` is the eye colour, `blush` the cheek alpha, `look` a small iris offset.
static func face(ci: CanvasItem, c: Vector2, blink: bool, iris: Color, blush: float = 0.35,
		look: Vector2 = Vector2.ZERO) -> void:
	var skin: Color = S.SKIN
	S.circle(ci, c + v(-23, 3), 4.2, skin, OW, S.ink(skin))
	S.circle(ci, c + v(23, 3), 4.2, skin, OW, S.ink(skin))
	var pts := S.ellipse(c, 23.0, 21.0, 28)
	S.fill(ci, pts, skin, OW, S.ink(skin))
	S.shade_band(ci, pts, skin, -1.0, 4.0)
	for sx in [-1.0, 1.0]:
		ci.draw_circle(c + v(sx * 14.5, 11.0), 4.0, Color(1.0, 0.45, 0.5, blush))
		_eye(ci, c + v(sx * 10.0, 3.0), blink, iris, look, sx)


static func _eye(ci: CanvasItem, e: Vector2, blink: bool, iris: Color, look: Vector2, side: float) -> void:
	if blink:
		ci.draw_arc(e + v(0, -1), 5.6, 0.2, PI - 0.2, 10, S.INK, 1.8, true)
		return
	S.fill(ci, S.ellipse(e, 6.2, 7.4, 18), Color(1, 1, 1, 0.97), 0.9, S.ink(Color(0.9, 0.85, 0.95)))
	var ie := e + look
	ci.draw_colored_polygon(S.ellipse(ie, 4.8, 6.0, 16), iris)
	ci.draw_colored_polygon(S.ellipse(ie + v(0, -2.6), 4.6, 2.6, 12), S.fade(S.darken(iris, 0.45), 0.8))
	ci.draw_circle(ie + v(0, 0.6), 2.5, S.INK)
	ci.draw_circle(ie + v(-1.7, -2.4), 1.8, Color(1, 1, 1, 0.95))
	ci.draw_circle(ie + v(1.8, 2.6), 0.9, Color(1, 1, 1, 0.8))
	ci.draw_arc(e + v(0, -0.6), 6.5, PI * 1.08, PI * 1.92, 10, S.INK, 2.2, true)
	ci.draw_line(e + v(side * 6.2, -2.4), e + v(side * 8.6, -4.2), S.INK, 1.5)


## Mouth at `p`: "smile", "smirk", "grin" (open, energetic) or "shy" (tiny).
static func mouth(ci: CanvasItem, p: Vector2, kind: String) -> void:
	match kind:
		"grin":
			var pts := PackedVector2Array()
			for i in range(11):
				var a: float = PI * float(i) / 10.0
				pts.append(p + v(cos(a) * 7.0, sin(a) * 6.0))
			S.fill(ci, pts, MOUTH, 1.0, S.ink(MOUTH))
			ci.draw_colored_polygon(S.ellipse(p + v(0, 4.2), 3.6, 1.8, 10), Color("#FF8E9C"))
			ci.draw_line(p + v(-6.5, 0), p + v(6.5, 0), Color(1, 1, 1, 0.9), 1.6)
		"smirk":
			ci.draw_arc(p + v(1, 0), 4.6, 0.2, PI - 0.5, 10, MOUTH, 1.7, true)
		"shy":
			ci.draw_arc(p, 2.4, 0.3, PI - 0.3, 8, MOUTH, 1.4, true)
		_:
			ci.draw_arc(p, 4.6, 0.25, PI - 0.25, 10, MOUTH, 1.7, true)


## Eyebrow line from `a` to `b`.
static func brow(ci: CanvasItem, a: Vector2, b: Vector2, col: Color) -> void:
	ci.draw_line(a, b, col, 1.8, true)


## Glowing lantern centred at `pos` with body width `s`. Gold frame, warm core, soft halo.
## `pulse` (0..1) brightens the glow.
static func lantern(ci: CanvasItem, pos: Vector2, s: float, accent: Color, pulse: float) -> void:
	var w: float = s * 0.5
	var h: float = s * 0.7
	for i in range(3):
		var r: float = s * (1.7 - 0.45 * float(i))
		ci.draw_circle(pos, r, S.fade(accent, 0.05 + 0.04 * pulse + 0.03 * float(i)))
	var frame: Color = S.darken(accent, 0.15)
	ci.draw_arc(pos + v(0, -h - s * 0.12), s * 0.28, PI, TAU, 10, frame, maxf(1.2, s * 0.07), true)
	S.fill(ci, [pos + v(-w * 0.7, -h - s * 0.14), pos + v(w * 0.7, -h - s * 0.14),
		pos + v(w * 1.05, -h + s * 0.04), pos + v(-w * 1.05, -h + s * 0.04)], frame, 0.8, S.ink(frame))
	var body := S.ellipse(pos, w, h, 18)
	S.fill(ci, body, S.fade(S.lighten(accent, 0.55), 0.9), 0.0, frame)
	ci.draw_colored_polygon(S.ellipse(pos, w * 0.62, h * 0.66, 14),
		S.fade(S.lighten(accent, 0.8), 0.7 + 0.3 * pulse))
	ci.draw_circle(pos, w * 0.3, Color(1, 1, 0.92, 0.7 + 0.3 * pulse))
	var closed := PackedVector2Array(S.ellipse(pos, w * 0.5, h, 14))
	closed.append(closed[0])
	ci.draw_polyline(closed, frame, maxf(0.9, s * 0.05), true)
	var outer := PackedVector2Array(body)
	outer.append(outer[0])
	ci.draw_polyline(outer, frame, maxf(1.0, s * 0.07), true)
	S.fill(ci, [pos + v(-w * 0.6, h), pos + v(w * 0.6, h),
		pos + v(w * 0.4, h + s * 0.16), pos + v(-w * 0.4, h + s * 0.16)], frame, 0.8, S.ink(frame))


## A tiny moth at `pos`; `flap` (0..1) opens/closes the wings.
static func moth(ci: CanvasItem, pos: Vector2, size: float, flap: float, col: Color) -> void:
	var wing: float = size * (0.45 + 0.55 * flap)
	for sx in [-1.0, 1.0]:
		var wc: Vector2 = pos + v(sx * size * 0.55 * (0.5 + 0.5 * flap), -size * 0.1)
		S.fill(ci, S.ellipse(wc, wing * 0.8, size * 0.55, 10), S.fade(col, 0.92), 0.7, S.ink(col))
	ci.draw_colored_polygon(S.ellipse(pos + v(0, size * 0.1), size * 0.16, size * 0.5, 8), S.darken(col, 0.5))
	ci.draw_line(pos + v(0, -size * 0.35), pos + v(-size * 0.25, -size * 0.7), S.darken(col, 0.5), 0.7)
	ci.draw_line(pos + v(0, -size * 0.35), pos + v(size * 0.25, -size * 0.7), S.darken(col, 0.5), 0.7)


## Hand circle with outline.
static func hand(ci: CanvasItem, p: Vector2, r: float = 4.0) -> void:
	S.circle(ci, p, r, S.SKIN, OW, S.ink(S.SKIN))


## Rounded shoe.
static func shoe(ci: CanvasItem, p: Vector2, col: Color) -> void:
	S.fill(ci, S.ellipse(p, 6.2, 3.4, 12), col, OW, S.ink(col))
