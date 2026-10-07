extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Hair for the idol hunter (Story 032): gradient masses, strand highlights, side-swept
## fringe with a parting, and tails that lag the head (secondary motion via `sway`).
## Styles: bob, twintails (both selectable in game) plus ponytail, which the art already
## supports and only needs a GameState.HAIRSTYLES entry. All polygons are simple.

const Shade := preload("res://scripts/hunter_shade.gd")
const PINK := Color("#FF5FA2")

## Front fringe edge, right to left, relative to the head centre (units of k). Tips stay above the brows.
const FRINGE := [Vector2(24.5, 9.0), Vector2(21.5, -1.5), Vector2(18.0, -8.0), Vector2(14.0, -3.0), Vector2(10.0, -9.0),
	Vector2(5.5, -3.5), Vector2(1.0, -10.0), Vector2(-3.0, -13.0), Vector2(-6.0, -4.0), Vector2(-10.0, -9.5),
	Vector2(-14.0, -3.0), Vector2(-18.0, -8.0), Vector2(-21.5, -1.5), Vector2(-24.5, 9.0)]


## Fills `pts` with a vertical gradient from `top` (at `y0`) to `bot` (at `y1`).
static func grad(ci: CanvasItem, pts: PackedVector2Array, top: Color, bot: Color, y0: float, y1: float) -> void:
	var cols := PackedColorArray()
	var span: float = maxf(y1 - y0, 0.001)
	for p in pts:
		cols.append(top.lerp(bot, clampf((p.y - y0) / span, 0.0, 1.0)))
	FD.gpoly(ci, pts, cols)


static func _closed(pts: PackedVector2Array) -> PackedVector2Array:
	var c := PackedVector2Array(pts)
	c.append(pts[0])
	return c


## A hanging lock/tail from `root` along `dir` (unit), `length` long and `width` wide at the root.
## `sway` bends the lower part sideways (lagging the head), `unit` scales line widths.
static func tail(ci: CanvasItem, root: Vector2, dir: Vector2, length: float, width: float, sway: float, unit: float, hair: Color, alpha: float, curl: float = 0.0) -> Vector2:
	var perp: Vector2 = dir.orthogonal()
	var n: int = 9
	var spine: Array[Vector2] = []
	var widths: Array[float] = []
	for i in range(n):
		var t: float = float(i) / float(n - 1)
		spine.append(root + dir * length * t + perp * (sway * t * t * 1.3 + sin(t * PI) * curl) * unit)
		widths.append(width * (1.0 - 0.88 * pow(t, 1.4)) * (1.0 + 0.22 * sin(t * PI)))
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	for i in range(n):
		var tan: Vector2 = (spine[mini(i + 1, n - 1)] - spine[maxi(i - 1, 0)]).normalized()
		var pn: Vector2 = tan.orthogonal()
		left.append(spine[i] + pn * widths[i] * 0.5)
		right.append(spine[i] - pn * widths[i] * 0.5)
	var poly := PackedVector2Array(left)
	for i in range(n - 1, -1, -1):
		poly.append(right[i])
	var base: Color = Shade.fade(hair, alpha)
	var dark: Color = Shade.fade(Shade.darken(hair, 0.4), alpha)
	var cols := PackedColorArray()
	for i in range(n):
		cols.append(base.lerp(dark, float(i) / float(n - 1) * 0.7).lerp(Shade.fade(Shade.lighten(hair, 0.2), alpha), 0.35))
	for i in range(n - 1, -1, -1):
		cols.append(base.lerp(dark, float(i) / float(n - 1) * 0.7).lerp(dark, 0.3))
	FD.gpoly(ci, poly, cols)
	var edge: Color = Shade.ink(base)
	var ow: float = maxf(1.0, 1.1 * unit)
	FD.polyline(ci, left, edge, ow, true)
	FD.polyline(ci, right, edge, ow, true)
	var hl := PackedVector2Array()
	var hl2 := PackedVector2Array()
	for i in range(1, n - 3):
		hl.append(spine[i].lerp(left[i], 0.45))
		hl2.append(spine[i].lerp(right[i], 0.4))
	FD.polyline(ci, hl, Shade.fade(Shade.lighten(hair, 0.55), 0.8 * alpha), maxf(1.0, 1.7 * unit), true)
	FD.polyline(ci, hl2, Shade.fade(dark, 0.55), maxf(1.0, 0.9 * unit), true)
	return spine[n - 1]


static func _scrunchie(ci: CanvasItem, p: Vector2, r: float, alpha: float, w: float) -> void:
	var sc: Color = Shade.fade(PINK, alpha)
	Shade.circle(ci, p, r, sc, w, Shade.ink(sc))
	FD.arc(ci, p, r * 0.6, PI * 1.1, PI * 1.9, 6, Shade.fade(Shade.lighten(PINK, 0.65), 0.85 * alpha), maxf(1.0, r * 0.3))
	FD.circle(ci, p + Vector2(-r * 0.3, -r * 0.35), r * 0.22, Shade.fade(Color.WHITE, 0.8 * alpha))


# ---------------- Front view ----------------

## Hair behind the front head. `style` bob | twintails | ponytail; `sway` lags the head.
static func back_front(ci: CanvasItem, head: Vector2, k: float, hair: Color, style: String, alpha: float, sway: float = 0.0) -> void:
	var w: float = maxf(1.0, 1.3 * k)
	var base: Color = Shade.fade(Shade.darken(hair, 0.12), alpha)
	var dark: Color = Shade.fade(Shade.darken(hair, 0.45), alpha)
	match style:
		"twintails":
			for side in [-1.0, 1.0]:
				var root: Vector2 = head + Vector2(side * 24.0, -8.0) * k
				var dir := Vector2(side * 0.28, 0.96).normalized()
				tail(ci, root, dir, 50.0 * k, 15.0 * k, sway * side * 1.2 + side * 2.0, k, hair, alpha, side * 3.0)
				_scrunchie(ci, root, 5.6 * k, alpha, w)
		"ponytail":
			var proot: Vector2 = head + Vector2(17.0, -20.0) * k
			tail(ci, proot, Vector2(0.55, 0.83).normalized(), 56.0 * k, 17.0 * k, sway * 1.4 + 4.0, k, hair, alpha, 4.0)
			_back_mass(ci, head, k, base, dark, sway, 0.55, w)
			_scrunchie(ci, proot, 5.2 * k, alpha, w)
		_:
			_back_mass(ci, head, k, base, dark, sway, 1.0, w)


static func _back_mass(ci: CanvasItem, head: Vector2, k: float, base: Color, dark: Color, sway: float, len_mul: float, w: float) -> void:
	var pts := PackedVector2Array()
	for i in range(13):
		var a: float = PI + PI * float(i) / 12.0
		pts.append(head + Vector2(cos(a) * 27.5, -1.0 + sin(a) * 27.5) * k)
	var tips: Array = [[28.5, 14.0], [28.0, 25.0], [24.0, 32.0], [19.0, 27.0], [13.0, 33.0], [7.0, 27.0], [0.0, 32.0], [-7.0, 27.0], [-13.0, 33.0], [-19.0, 27.0], [-24.0, 32.0], [-28.0, 25.0], [-28.5, 14.0]]
	for tp in tips:
		var ty: float = float(tp[1])
		var lag: float = clampf((ty - 8.0) / 25.0, 0.0, 1.0)
		pts.append(head + Vector2(float(tp[0]) + sway * lag * 1.5, 6.0 + (ty - 6.0) * len_mul) * k)
	grad(ci, pts, base.lerp(Color.WHITE, 0.08), dark, head.y - 28.0 * k, head.y + 34.0 * k)
	FD.polyline(ci, _closed(pts), Shade.ink(base), w, true)
	var hl: Color = Shade.fade(Shade.lighten(base, 0.45), 0.5 * base.a)
	for side in [-1.0, 1.0]:
		var line := PackedVector2Array()
		for j in range(6):
			var t: float = float(j) / 5.0
			line.append(head + Vector2(side * (24.5 + 1.5 * t) + sway * t * t * 1.4, 6.0 + 22.0 * t * len_mul) * k)
		FD.polyline(ci, line, hl, maxf(1.0, 1.8 * k), true)


## Front hair cap with side-swept fringe, parting, gradient and strand highlights.
static func cap_front(ci: CanvasItem, head: Vector2, k: float, hair: Color, alpha: float) -> void:
	var w: float = maxf(1.0, 1.3 * k)
	var cap := PackedVector2Array()
	for i in range(17):
		var a: float = PI + PI * float(i) / 16.0
		cap.append(head + (Vector2(0.0, -1.0) + Vector2(cos(a), sin(a)) * 25.5) * k)
	for p in FRINGE:
		cap.append(head + (p as Vector2) * k)
	var hc: Color = Shade.fade(hair, alpha)
	grad(ci, cap, Shade.fade(Shade.lighten(hair, 0.18), alpha), Shade.fade(Shade.darken(hair, 0.3), alpha), head.y - 26.0 * k, head.y + 9.0 * k)
	FD.polyline(ci, _closed(cap), Shade.ink(hc), w, true)
	var lit: Color = Shade.fade(Shade.lighten(hair, 0.5), 0.8 * alpha)
	FD.arc(ci, head + Vector2(0.0, -1.0) * k, 20.5 * k, PI * 1.1, PI * 1.58, 12, lit, maxf(1.0, 3.4 * k), true)
	FD.arc(ci, head + Vector2(0.0, -1.0) * k, 17.5 * k, PI * 1.16, PI * 1.5, 10, Shade.fade(Shade.lighten(hair, 0.7), 0.5 * alpha), maxf(1.0, 1.4 * k), true)
	var st: Color = Shade.fade(Shade.darken(hair, 0.5), 0.5 * alpha)
	var sw: float = maxf(1.0, 0.9 * k)
	for s in [[Vector2(-3.0, -24.0), Vector2(-3.0, -13.0)], [Vector2(-3.0, -13.0), Vector2(-7.5, -5.0)], [Vector2(7.0, -22.5), Vector2(10.0, -10.0)],
			[Vector2(-12.0, -21.0), Vector2(-12.0, -11.0)], [Vector2(15.0, -17.0), Vector2(18.0, -9.0)], [Vector2(-19.0, -14.0), Vector2(-21.5, -3.0)], [Vector2(20.0, -12.0), Vector2(22.5, 2.0)]]:
		ci.draw_line(head + (s[0] as Vector2) * k, head + (s[1] as Vector2) * k, st, sw)
	ci.draw_line(head + Vector2(-3.0, -24.5) * k, head + Vector2(-3.0, -13.5) * k, Shade.fade(Shade.SKIN_SHADOW, 0.55 * alpha), maxf(1.0, 0.8 * k))


# ---------------- Side view ----------------

## Hair behind the side-view head; tails/locks trail opposite the facing and lag with `sway`.
static func back_side(ci: CanvasItem, head: Vector2, u: float, f: float, sway: float, hair: Color, style: String, alpha: float) -> void:
	var w: float = maxf(1.0, 1.0 * u)
	var base: Color = Shade.fade(Shade.darken(hair, 0.12), alpha)
	var dark: Color = Shade.fade(Shade.darken(hair, 0.45), alpha)
	if style == "twintails":
		for side in [-1.0, 1.0]:
			var root: Vector2 = head + Vector2(side * 10.0 - f * 2.0, -4.0) * u
			tail(ci, root, Vector2(side * 0.15 - f * 0.25, 0.95).normalized(), 33.0 * u, 10.5 * u, sway * 0.9 - f * 3.0 + side * 1.0, u, hair, alpha, side * 2.0)
			_scrunchie(ci, root, 4.0 * u, alpha, w)
		return
	if style == "ponytail":
		var proot: Vector2 = head + Vector2(-f * 9.0, -8.0) * u
		tail(ci, proot, Vector2(-f * 0.7, 0.72).normalized(), 38.0 * u, 11.0 * u, -f * (sway * 0.9 + 3.0), u, hair, alpha, 3.0)
		_scrunchie(ci, proot, 3.8 * u, alpha, w)
	var pts := PackedVector2Array()
	var bc: Vector2 = head + Vector2(-f * 2.0, 3.0) * u
	for i in range(24):
		var a: float = TAU * float(i) / 24.0
		var sa: float = sin(a)
		var low: float = maxf(sa, 0.0)
		pts.append(bc + Vector2(cos(a) * 16.0 + sway * 0.5 * low * low * 1.6 - f * low * 2.0, sa * 16.0 + low * low * 5.0) * u)
	grad(ci, pts, base.lerp(Color.WHITE, 0.06), dark, head.y - 14.0 * u, head.y + 24.0 * u)
	FD.polyline(ci, _closed(pts), Shade.ink(base), w, true)
	var hl: Color = Shade.fade(Shade.lighten(base, 0.45), 0.5 * base.a)
	ci.draw_line(head + Vector2(-f * 14.5, -1.0) * u, head + Vector2(-f * 15.5 + sway * 0.2, 12.0) * u, hl, maxf(1.0, 1.4 * u))
	ci.draw_line(head + Vector2(-f * 11.0, 8.0) * u, head + Vector2(-f * 12.5 + sway * 0.3, 18.0) * u, Shade.fade(dark, 0.6), maxf(1.0, 0.8 * u))
	if style != "ponytail":
		for side in [-1.0, 1.0]:
			var lock: Vector2 = head + Vector2(side * 12.5, 11.0) * u
			tail(ci, lock, Vector2(side * 0.1, 1.0), 17.0 * u, 7.0 * u, sway * 0.5, u, hair, alpha)


## Side-view crown, swept fringe and highlights (drawn over the face skin).
static func cap_side(ci: CanvasItem, head: Vector2, u: float, f: float, hair: Color, alpha: float) -> void:
	var w: float = maxf(1.0, 1.0 * u)
	var hc: Color = Shade.fade(hair, alpha)
	var cc: Vector2 = head + Vector2(0.0, -1.0) * u
	FD.arc(ci, cc, 16.2 * u, PI * 1.02, PI * 1.98, 20, Shade.ink(hc), w)
	FD.arc(ci, cc, 8.8 * u, PI * 1.02, PI * 1.98, 20, Shade.ink(hc), w)
	FD.arc(ci, cc, 12.5 * u, PI * 1.02, PI * 1.98, 20, Shade.fade(Shade.darken(hair, 0.15), alpha), 7.0 * u)
	FD.arc(ci, cc, 13.8 * u, PI * 1.02, PI * 1.98, 20, hc, 4.0 * u)
	FD.arc(ci, cc, 14.0 * u, PI * 1.2, PI * 1.65, 10, Shade.fade(Shade.lighten(hair, 0.55), 0.8 * alpha), maxf(1.0, 2.2 * u))
	var fr := PackedVector2Array([head + Vector2(-f * 3.0, -13.0) * u, head + Vector2(f * 8.0, -11.0) * u, head + Vector2(f * 13.5, -2.0) * u,
		head + Vector2(f * 9.0, -6.0) * u, head + Vector2(f * 5.0, -2.0) * u, head + Vector2(f * 2.5, -6.0) * u, head + Vector2(-f * 2.0, -3.0) * u])
	grad(ci, fr, Shade.fade(Shade.lighten(hair, 0.15), alpha), Shade.fade(Shade.darken(hair, 0.3), alpha), head.y - 13.0 * u, head.y - 2.0 * u)
	FD.polyline(ci, _closed(fr), Shade.ink(hc), w, true)
	var st: Color = Shade.fade(Shade.darken(hair, 0.5), 0.5 * alpha)
	ci.draw_line(head + Vector2(f * 1.0, -11.5) * u, head + Vector2(f * 8.5, -4.5) * u, st, maxf(1.0, 0.7 * u))
	ci.draw_line(head + Vector2(f * 4.0, -11.0) * u, head + Vector2(f * 11.0, -4.0) * u, st, maxf(1.0, 0.7 * u))
	ci.draw_line(head + Vector2(-f * 6.0, -11.0) * u, head + Vector2(-f * 8.5, -4.0) * u, st, maxf(1.0, 0.7 * u))
