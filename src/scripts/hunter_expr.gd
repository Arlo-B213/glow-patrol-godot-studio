extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Expression system + rich anime eyes/brows/mouths shared by the hunter (front and side
## views) and, through `params()`, by the Lanternboys (Story 032).
##
## Expression ids: neutral, happy, cheer, determined, hurt, surprised, shy, sleepy. Unknown
## ids fall back to neutral. Every draw function takes a figure-unit scale `s` and draws onto
## a CanvasItem from its _draw(). All polygons are simple.

const Shade := preload("res://scripts/hunter_shade.gd")

const IDS: Array[String] = ["neutral", "happy", "cheer", "determined", "hurt", "surprised", "shy", "sleepy"]
const LIP := Color("#E0607A")
const MOUTH_IN := Color("#8A2F45")
const TONGUE := Color("#FF8E9C")
const TEAR := Color("#BDEBFF")

## open = eye height 0..1.2, shape = open|arch|closed, pupil = pupil scale, raise/tilt = brow
## lift and inner-end slope (+ = angry, - = worried), blush 0..1, tear 0..1, gaze = iris offset.
const TABLE := {
	"neutral": {"open": 1.0, "shape": "open", "pupil": 1.0, "raise": 0.0, "tilt": 0.0, "mouth": "smile_small", "blush": 0.35, "tear": 0.0, "gaze": Vector2.ZERO},
	"happy": {"open": 0.92, "shape": "open", "pupil": 1.1, "raise": 0.8, "tilt": -0.2, "mouth": "smile", "blush": 0.55, "tear": 0.0, "gaze": Vector2.ZERO},
	"cheer": {"open": 1.0, "shape": "arch", "pupil": 1.0, "raise": 1.4, "tilt": -0.3, "mouth": "open_big", "blush": 0.7, "tear": 0.0, "gaze": Vector2.ZERO},
	"determined": {"open": 0.85, "shape": "open", "pupil": 0.85, "raise": -0.4, "tilt": 1.6, "mouth": "set", "blush": 0.2, "tear": 0.0, "gaze": Vector2(0.0, -0.2)},
	"hurt": {"open": 0.9, "shape": "closed", "pupil": 1.0, "raise": 0.6, "tilt": -1.8, "mouth": "wobble", "blush": 0.15, "tear": 1.0, "gaze": Vector2.ZERO},
	"surprised": {"open": 1.18, "shape": "open", "pupil": 0.6, "raise": 2.4, "tilt": -0.2, "mouth": "o", "blush": 0.3, "tear": 0.0, "gaze": Vector2.ZERO},
	"shy": {"open": 0.82, "shape": "open", "pupil": 1.1, "raise": 0.4, "tilt": -1.0, "mouth": "tiny", "blush": 1.0, "tear": 0.5, "gaze": Vector2(0.35, 0.35)},
	"sleepy": {"open": 0.36, "shape": "open", "pupil": 1.0, "raise": -0.6, "tilt": -0.4, "mouth": "flat", "blush": 0.3, "tear": 0.0, "gaze": Vector2(0.0, 0.3)},
}


## The parameter dictionary of `expr` (neutral when unknown).
static func params(expr: String) -> Dictionary:
	return TABLE.get(expr, TABLE["neutral"])


## Iris colour: a warm brown tinted by the hair colour.
static func iris_color(hair: Color) -> Color:
	var c: Color = Color("#7A4A2E").lerp(hair, 0.35)
	c.a = 1.0
	return c


## One eye centred at `c` at scale `s`. `outward` is -1/1 (side of the outer corner), `e` the
## expression params, `closed` 0..1 the blink amount and `gaze` a unit-ish iris offset.
static func eye(ci: CanvasItem, c: Vector2, s: float, outward: float, iris: Color, alpha: float, e: Dictionary, closed: float = 0.0, gaze: Vector2 = Vector2.ZERO) -> void:
	var dark: Color = Shade.fade(Shade.INK, alpha)
	var shape: String = String(e["shape"])
	var open: float = float(e["open"]) * (1.0 - closed * 0.92)
	var lw: float = maxf(1.0, 1.9 * s)
	if shape == "arch" and closed < 0.5:
		var arc := PackedVector2Array()
		for i in range(9):
			var a: float = PI * float(i) / 8.0
			arc.append(c + Vector2(-cos(a) * 5.2 * s, 1.6 * s - sin(a) * 3.8 * s))
		FD.polyline(ci, arc, dark, lw * 1.15, true)
		ci.draw_line(c + Vector2(outward * 5.2 * s, 1.6 * s), c + Vector2(outward * 7.4 * s, 0.2 * s), dark, maxf(1.0, 1.3 * s))
		FD.circle(ci, c + Vector2(0.0, -0.4 * s), 0.7 * s, Shade.fade(Color.WHITE, 0.7 * alpha))
		return
	if shape == "closed" or open * 6.4 * s < 1.7 * s:
		var line := PackedVector2Array()
		for i in range(8):
			var a: float = PI * float(i) / 7.0
			line.append(c + Vector2(cos(a) * 5.0 * s, 0.8 * s + sin(a) * 2.2 * s))
		FD.polyline(ci, line, dark, lw, true)
		ci.draw_line(c + Vector2(outward * 5.0 * s, 0.8 * s), c + Vector2(outward * 7.4 * s, -1.4 * s), dark, maxf(1.0, 1.3 * s))
		for j in range(2):
			var bx: float = outward * (1.0 + 1.6 * float(j)) * s
			ci.draw_line(c + Vector2(bx, 2.9 * s), c + Vector2(bx + outward * 0.5 * s, 4.1 * s), Shade.fade(dark, 0.7), maxf(1.0, 0.9 * s))
		_tear(ci, c, s, float(e["tear"]), alpha)
		return
	var rx: float = 5.0 * s
	var ry: float = 6.4 * s * open
	FD.poly(ci, Shade.ellipse(c, rx + 0.5 * s, ry + 0.5 * s, 18), dark)
	var off := Vector2(clampf(gaze.x, -1.0, 1.0) * 1.1 * s, clampf(gaze.y, -1.0, 1.0) * 1.2 * s * minf(open, 1.0))
	var ir: float = ry * 0.9
	var ipts := Shade.ellipse(c + off + Vector2(0.0, 0.4 * s), rx * 0.82, ir, 18)
	var icols := PackedColorArray()
	var top: Color = Shade.fade(Shade.darken(iris, 0.5), alpha)
	var bot: Color = Shade.fade(Shade.lighten(iris, 0.5), alpha)
	for p in ipts:
		var t: float = clampf((p.y - (c.y + off.y - ir)) / (2.0 * ir), 0.0, 1.0)
		icols.append(top.lerp(Shade.fade(iris, alpha), clampf(t * 2.0, 0.0, 1.0)).lerp(bot, clampf(t * 2.0 - 1.0, 0.0, 1.0)))
	FD.gpoly(ci, ipts, icols)
	FD.arc(ci, c + off + Vector2(0.0, 0.4 * s), rx * 0.82, 0.0, TAU, 18, Shade.fade(Shade.darken(iris, 0.6), 0.8 * alpha), maxf(1.0, 0.7 * s), true)
	var pr: float = float(e["pupil"])
	FD.poly(ci, Shade.ellipse(c + off + Vector2(0.0, 0.3 * s), 1.9 * s * pr, 2.9 * s * pr * minf(open, 1.0), 12), dark)
	FD.circle(ci, c + off + Vector2(1.5, -2.2 * minf(open, 1.0)) * s, 1.55 * s, Shade.fade(Color.WHITE, alpha))
	FD.circle(ci, c + off + Vector2(-1.4, 2.2 * minf(open, 1.0)) * s, 0.8 * s, Shade.fade(Color.WHITE, 0.9 * alpha))
	if s >= 0.9:
		FD.circle(ci, c + off + Vector2(0.2, 0.8) * s, 0.4 * s, Shade.fade(Color.WHITE, 0.7 * alpha))
	# Upper lash arc, crease, outer flick and mini lashes.
	var lash := PackedVector2Array()
	for i in range(8):
		var a: float = PI + PI * float(i) / 7.0
		lash.append(c + Vector2(cos(a) * (rx + 0.3 * s), sin(a) * (ry + 0.3 * s) + 0.4 * s))
	FD.polyline(ci, lash, dark, lw * 1.2, true)
	ci.draw_line(c + Vector2(outward * (rx + 0.2 * s), -0.4 * s), c + Vector2(outward * 7.6 * s, -2.8 * s * minf(open, 1.0)), dark, maxf(1.0, 1.4 * s))
	ci.draw_line(c + Vector2(outward * 4.0 * s, -ry * 0.8), c + Vector2(outward * 6.0 * s, -ry - 1.4 * s), Shade.fade(dark, 0.75), maxf(1.0, 0.9 * s))
	if s >= 0.9:
		var crease := PackedVector2Array([c + Vector2(-outward * 3.6 * s, -ry - 1.6 * s), c + Vector2(0.0, -ry - 2.3 * s), c + Vector2(outward * 4.0 * s, -ry - 1.0 * s)])
		FD.polyline(ci, crease, Shade.fade(Shade.SKIN_SHADOW, 0.7 * alpha), maxf(1.0, 0.8 * s))
	ci.draw_line(c + Vector2(-2.0 * s, ry + 0.8 * s), c + Vector2(2.0 * s, ry + 0.8 * s), Shade.fade(dark, 0.35), maxf(1.0, 0.8 * s))
	_tear(ci, c + Vector2(0.0, ry - 5.4 * s), s, float(e["tear"]), alpha)


static func _tear(ci: CanvasItem, c: Vector2, s: float, amt: float, alpha: float) -> void:
	if amt <= 0.0:
		return
	var line := PackedVector2Array()
	for i in range(6):
		var a: float = PI * (0.12 + 0.76 * float(i) / 5.0)
		line.append(c + Vector2(cos(a) * 4.6 * s, 5.4 * s + sin(a) * 1.8 * s))
	FD.polyline(ci, line, Shade.fade(TEAR, 0.65 * alpha * amt), maxf(1.0, 1.1 * s), true)
	if amt >= 0.9:
		var d: Vector2 = c + Vector2(-1.0 * s, 8.0 * s)
		FD.poly(ci, PackedVector2Array([d + Vector2(0.0, -2.6 * s), d + Vector2(1.4 * s, 0.0), d + Vector2(0.0, 1.6 * s), d + Vector2(-1.4 * s, 0.0)]), Shade.fade(TEAR, 0.9 * alpha))


## Eyebrow centred at `c` for the eye on `side` (-1 left, 1 right); inner end is toward x = 0.
static func brow(ci: CanvasItem, c: Vector2, s: float, side: float, col: Color, e: Dictionary, w: float = 1.5) -> void:
	var raise: float = float(e["raise"])
	var tilt: float = float(e["tilt"])
	var inner := c + Vector2(-side * 4.2, tilt * 1.3 - raise * 0.6) * s
	var mid := c + Vector2(0.0, -1.5 - raise * 0.9) * s
	var outer := c + Vector2(side * 4.4, 0.4 - raise * 0.8 - tilt * 0.9) * s
	FD.polyline(ci, PackedVector2Array([inner, mid, outer]), col, maxf(1.0, w * s), true)


## Cheek blush: soft double disc, plus short slash marks when the blush is strong.
static func blush(ci: CanvasItem, c: Vector2, r: float, amt: float, alpha: float) -> void:
	var col := Color(1.0, 0.42, 0.58)
	FD.circle(ci, c, r * 1.25, Shade.fade(col, 0.16 * amt * alpha))
	FD.circle(ci, c, r * 0.9, Shade.fade(col, 0.34 * amt * alpha))
	if amt >= 0.9:
		for i in range(3):
			var x: float = (float(i) - 1.0) * r * 0.55
			ci.draw_line(c + Vector2(x - r * 0.15, r * 0.35), c + Vector2(x + r * 0.2, -r * 0.3), Shade.fade(Color("#FF3F7F"), 0.6 * alpha), maxf(1.0, r * 0.14))


## Mouth shape `kind` (see TABLE) centred at `p` at scale `s`.
static func mouth(ci: CanvasItem, p: Vector2, s: float, kind: String, alpha: float) -> void:
	var ink: Color = Shade.fade(Shade.INK, alpha)
	var w: float = maxf(1.0, 1.5 * s)
	match kind:
		"smile":
			FD.arc(ci, p + Vector2(0.0, -0.6 * s), 5.4 * s, PI * 0.12, PI * 0.88, 10, ink, w, true)
			ci.draw_line(p + Vector2(-5.2 * s, 0.2 * s), p + Vector2(-5.9 * s, -0.9 * s), ink, maxf(1.0, 1.0 * s))
			ci.draw_line(p + Vector2(5.2 * s, 0.2 * s), p + Vector2(5.9 * s, -0.9 * s), ink, maxf(1.0, 1.0 * s))
			ci.draw_line(p + Vector2(-1.3 * s, 5.0 * s), p + Vector2(1.3 * s, 5.0 * s), Shade.fade(LIP, 0.8 * alpha), maxf(1.0, 1.0 * s))
		"open_big":
			var pts := PackedVector2Array()
			for i in range(11):
				var a: float = PI * float(i) / 10.0
				pts.append(p + Vector2(cos(a) * 6.2 * s, sin(a) * 6.4 * s))
			Shade.fill(ci, pts, Shade.fade(MOUTH_IN, alpha), maxf(1.0, 1.2 * s), ink)
			FD.poly(ci, Shade.ellipse(p + Vector2(0.0, 4.4 * s), 3.4 * s, 1.7 * s, 10), Shade.fade(TONGUE, alpha))
			FD.poly(ci, PackedVector2Array([p + Vector2(-4.8 * s, 0.4 * s), p + Vector2(4.8 * s, 0.4 * s), p + Vector2(4.4 * s, 2.0 * s), p + Vector2(-4.4 * s, 2.0 * s)]), Shade.fade(Color.WHITE, 0.95 * alpha))
		"set":
			FD.polyline(ci, PackedVector2Array([p + Vector2(-3.6 * s, 0.4 * s), p + Vector2(0.0, 1.2 * s), p + Vector2(3.8 * s, -0.4 * s)]), ink, w, true)
		"wobble":
			var z := PackedVector2Array()
			for i in range(6):
				z.append(p + Vector2((float(i) - 2.5) * 1.6 * s, (1.0 if i % 2 == 0 else -0.6) * s))
			FD.polyline(ci, z, ink, maxf(1.0, 1.3 * s), true)
		"o":
			Shade.fill(ci, Shade.ellipse(p + Vector2(0.0, 1.0 * s), 2.5 * s, 3.2 * s, 12), Shade.fade(MOUTH_IN, alpha), maxf(1.0, 1.1 * s), ink)
			FD.circle(ci, p + Vector2(-0.7 * s, 0.2 * s), 0.7 * s, Shade.fade(TONGUE, alpha))
		"tiny":
			FD.arc(ci, p + Vector2(0.0, 0.4 * s), 2.2 * s, PI * 0.15, PI * 0.85, 6, ink, maxf(1.0, 1.2 * s), true)
		"flat":
			ci.draw_line(p + Vector2(-2.2 * s, 1.0 * s), p + Vector2(2.2 * s, 1.0 * s), ink, maxf(1.0, 1.2 * s))
		_:
			FD.arc(ci, p, 4.2 * s, PI * 0.2, PI * 0.8, 8, ink, w, true)
			ci.draw_line(p + Vector2(-1.4 * s, 5.0 * s), p + Vector2(1.4 * s, 5.0 * s), Shade.fade(LIP, 0.85 * alpha), maxf(1.0, 1.1 * s))


## Face features for the FRONT head at `head` (radius 24 * k): blush, brows, eyes, nose, mouth.
## `gaze` nudges the irises, `closed` is the blink amount 0..1.
static func front(ci: CanvasItem, head: Vector2, k: float, hair: Color, alpha: float, expr: String, closed: float = 0.0, gaze: Vector2 = Vector2.ZERO) -> void:
	var e: Dictionary = params(expr)
	var iris: Color = iris_color(hair)
	var browc: Color = Shade.fade(Shade.darken(hair, 0.35), alpha)
	var g: Vector2 = (e["gaze"] as Vector2) + gaze
	for side in [-1.0, 1.0]:
		blush(ci, head + Vector2(side * 15.5, 10.5) * k, 4.2 * k, float(e["blush"]), alpha)
		eye(ci, head + Vector2(side * 9.5, 3.0) * k, k * 1.08, side, iris, alpha, e, closed, g)
		brow(ci, head + Vector2(side * 10.0, -6.2) * k, k, side, browc, e, 1.6)
	FD.circle(ci, head + Vector2(0.0, 8.6) * k, 0.9 * k, Shade.fade(Shade.darken(Shade.SKIN_SHADOW, 0.3), 0.9 * alpha))
	FD.circle(ci, head + Vector2(-0.3, 8.0) * k, 0.45 * k, Shade.fade(Shade.SKIN_LIGHT, alpha))
	mouth(ci, head + Vector2(0.0, 13.4) * k, k * 0.9, String(e["mouth"]), alpha)


## Face features for the SIDE head at `head` (radius 13 * u) facing `f`.
static func side(ci: CanvasItem, head: Vector2, u: float, f: float, hair: Color, alpha: float, expr: String, closed: float = 0.0) -> void:
	var e: Dictionary = params(expr)
	var iris: Color = iris_color(hair)
	var browc: Color = Shade.fade(Shade.darken(hair, 0.35), alpha)
	for sd in [-1.0, 1.0]:
		var ec: Vector2 = head + Vector2(f * 4.0 + sd * 4.5, 1.0) * u
		eye(ci, ec, 0.62 * u, sd, iris, alpha, e, closed, Vector2(f * 0.5, 0.0))
		brow(ci, ec + Vector2(0.0, -4.6 * u), 0.62 * u, sd, browc, e, 1.4)
		blush(ci, head + Vector2(f * 4.0 + sd * 7.5, 6.0) * u, 2.4 * u, float(e["blush"]) * 0.9, alpha)
	FD.polyline(ci, PackedVector2Array([head + Vector2(f * 12.2, 3.0) * u, head + Vector2(f * 13.8, 5.0) * u, head + Vector2(f * 12.0, 5.8) * u]), Shade.fade(Shade.darken(Shade.SKIN_SHADOW, 0.3), 0.8 * alpha), maxf(1.0, 0.8 * u))
	mouth(ci, head + Vector2(f * 6.5, 8.2) * u, 0.5 * u, String(e["mouth"]), alpha)
