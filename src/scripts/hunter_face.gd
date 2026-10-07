extends RefCounted
## Head, hair and face detail for the idol hunter (Story 015), side-view (`_side`) and
## front (`_front`). Head geometry matches the original art so HunterAccessories still
## aligns: side head radius 13 * u, front head radius 24 * k, eyes at the same centres.

const Shade := preload("res://scripts/hunter_shade.gd")

const PINK := Color("#FF5FA2")
const LIP := Color("#E0607A")
const BROWN := Color("#7A4A2E")
## Front fringe edge, right to left (figure units relative to the head centre).
const FRINGE := [Vector2(23.0, 2.0), Vector2(17.0, -5.0), Vector2(12.0, -12.0), Vector2(5.5, -5.0), Vector2(0.0, -9.0),
	Vector2(-5.5, -5.0), Vector2(-12.0, -12.0), Vector2(-17.0, -5.0), Vector2(-23.0, 2.0)]


## Iris colour: a warm brown tinted by the hair colour.
static func iris_color(hair: Color) -> Color:
	var c: Color = BROWN.lerp(hair, 0.35)
	c.a = 1.0
	return c


## One eye centred at `c`, drawn at scale `s` (front: k, side: 0.6 * u). `outward` is -1/1:
## the direction of the outer corner (lash flick).
static func eye(ci: CanvasItem, c: Vector2, s: float, outward: float, iris: Color, alpha: float, closed: float = 0.0) -> void:
	var dark: Color = Shade.fade(Shade.INK, alpha)
	if closed >= 0.4:
		# Closed eye: a downward-curved lash line plus the outer flick.
		var arc := PackedVector2Array()
		for i in range(7):
			var a: float = PI * float(i) / 6.0
			arc.append(c + Vector2(cos(a) * 4.9 * s, 1.0 * s + sin(a) * 2.6 * s))
		ci.draw_polyline(arc, dark, maxf(1.0, 1.9 * s))
		ci.draw_line(c + Vector2(outward * 4.9 * s, 1.0 * s), c + Vector2(outward * 7.2 * s, -1.2 * s), dark, maxf(1.0, 1.3 * s))
		return
	ci.draw_colored_polygon(Shade.ellipse(c, 4.7 * s, 5.9 * s, 16), dark)
	var ic: Color = Shade.fade(iris, alpha)
	ci.draw_colored_polygon(Shade.ellipse(c + Vector2(0.0, 0.5 * s), 3.9 * s, 5.0 * s, 16), ic)
	ci.draw_colored_polygon(Shade.ellipse(c + Vector2(0.0, 2.6 * s), 2.9 * s, 2.0 * s, 12), Shade.fade(Shade.lighten(iris, 0.4), 0.85 * alpha))
	ci.draw_colored_polygon(Shade.ellipse(c + Vector2(0.0, 0.3 * s), 1.9 * s, 2.7 * s, 12), dark)
	ci.draw_circle(c + Vector2(1.4, -2.0) * s, 1.5 * s, Shade.fade(Color.WHITE, alpha))
	ci.draw_circle(c + Vector2(-1.3, 2.0) * s, 0.75 * s, Shade.fade(Color.WHITE, alpha))
	var lash := PackedVector2Array()
	for i in range(7):
		var a: float = PI + PI * float(i) / 6.0
		lash.append(c + Vector2(cos(a) * 4.9 * s, sin(a) * 6.1 * s + 0.4 * s))
	var lw: float = maxf(1.0, 1.7 * s)
	ci.draw_polyline(lash, dark, lw)
	ci.draw_line(c + Vector2(outward * 4.7 * s, -0.4 * s), c + Vector2(outward * 7.2 * s, -2.4 * s), dark, maxf(1.0, 1.3 * s))


# ---------------- Side view ----------------

## Hair behind the head (back layer, twintails or bob locks and strands). `head` is the face
## centre, `f` the facing, `sway` the idle sway.
static func hair_back_side(ci: CanvasItem, head: Vector2, u: float, f: float, sway: float, hair: Color, twin: bool, alpha: float) -> void:
	var back: Color = Shade.fade(Shade.darken(hair, 0.2), alpha)
	var edge: Color = Shade.ink(back)
	var w: float = maxf(1.0, 1.0 * u)
	var strand: Color = Shade.fade(Shade.darken(hair, 0.4), 0.55 * alpha)
	if twin:
		for side in [-1.0, 1.0]:
			var root: Vector2 = head + Vector2(side * 11.0, -4.0) * u
			var tip: Vector2 = root + Vector2(side * 9.0 - f * 4.0 + sway * side * 0.6, 32.0) * u
			var pts := PackedVector2Array([root + Vector2(-5.0, -3.0) * u, root + Vector2(5.0, -3.0) * u, tip])
			Shade.fill(ci, pts, back, w, edge)
			Shade.shade_band(ci, pts, back, -1.0)
			ci.draw_line(root + Vector2(-1.5, 0.0) * u, tip.lerp(root, 0.12), strand, maxf(1.0, 0.8 * u))
			ci.draw_line(root + Vector2(2.0, 0.0) * u, tip.lerp(root, 0.2), strand, maxf(1.0, 0.8 * u))
			Shade.circle(ci, root, 4.0 * u, Shade.fade(PINK, alpha), w, Shade.ink(Shade.fade(PINK, alpha)))
			ci.draw_circle(root + Vector2(-1.2, -1.2) * u, 1.2 * u, Shade.fade(Shade.lighten(PINK, 0.6), 0.8 * alpha))
	else:
		var bc: Vector2 = head + Vector2(-f * 2.0 + sway * 0.2, 4.0) * u
		var pts: PackedVector2Array = Shade.ellipse(bc, 16.0 * u, 16.0 * u, 24)
		Shade.fill(ci, pts, back, w, edge)
		Shade.shade_band(ci, pts, back, -1.0)
		ci.draw_line(head + Vector2(-f * 14.5, -1.0) * u, head + Vector2(-f * 15.5, 9.0) * u, strand, maxf(1.0, 0.8 * u))
		ci.draw_line(head + Vector2(-f * 11.0, 8.0) * u, head + Vector2(-f * 13.0, 15.0) * u, strand, maxf(1.0, 0.8 * u))
		for side in [-1.0, 1.0]:
			var lock: Vector2 = head + Vector2(side * 13.0, 12.0) * u
			var lp := PackedVector2Array([lock + Vector2(-4.0, 0.0) * u, lock + Vector2(4.0, 0.0) * u, lock + Vector2(side * 2.0 + sway * 0.4, 14.0) * u])
			Shade.fill(ci, lp, back, w, edge)
			ci.draw_line(lock + Vector2(0.0, 1.0) * u, lock + Vector2(side * 1.5, 11.0) * u, strand, maxf(1.0, 0.7 * u))


## Side-view head: neck, skin, crown, fringe and the face (eyes, brows, nose, mouth, cheeks).
static func face_side(ci: CanvasItem, head: Vector2, u: float, f: float, hair: Color, alpha: float, blink: float = 0.0, wince: bool = false) -> void:
	var skin: Color = Shade.fade(Shade.SKIN, alpha)
	var w: float = maxf(1.0, 1.0 * u)
	var shadow: Color = Shade.fade(Shade.SKIN_SHADOW, alpha)
	# Neck.
	var neck := PackedVector2Array([head + Vector2(-3.5, 8.0) * u, head + Vector2(3.5, 8.0) * u, head + Vector2(3.5, 15.0) * u, head + Vector2(-3.5, 15.0) * u])
	Shade.fill(ci, neck, shadow, w, Shade.ink(skin))
	var pts: PackedVector2Array = Shade.ellipse(head, 13.0 * u, 13.0 * u, 24)
	Shade.fill(ci, pts, skin, w, Shade.ink(skin))
	Shade.shade_band(ci, pts, skin, f)
	ci.draw_arc(head, 12.0 * u, PI * 0.2, PI * 0.8, 8, Shade.fade(Shade.SKIN_SHADOW, 0.5 * alpha), maxf(1.0, 1.6 * u))
	# Crown (thick arc), its outline and highlight, then the fringe wedge.
	var hc: Color = Shade.fade(hair, alpha)
	var cc: Vector2 = head + Vector2(0.0, -1.0) * u
	ci.draw_arc(cc, 16.2 * u, PI * 1.02, PI * 1.98, 20, Shade.ink(hc), w)
	ci.draw_arc(cc, 8.8 * u, PI * 1.02, PI * 1.98, 20, Shade.ink(hc), w)
	ci.draw_arc(cc, 12.5 * u, PI * 1.02, PI * 1.98, 20, hc, 7.0 * u)
	ci.draw_arc(cc, 14.0 * u, PI * 1.2, PI * 1.65, 10, Shade.fade(Shade.lighten(hair, 0.45), 0.75 * alpha), maxf(1.0, 2.0 * u))
	var fr := PackedVector2Array([head + Vector2(-f * 2.0, -13.0) * u, head + Vector2(f * 13.0, -3.0) * u, head + Vector2(f * 4.0, -3.0) * u])
	Shade.fill(ci, fr, hc, w, Shade.ink(hc))
	var st: Color = Shade.fade(Shade.darken(hair, 0.4), 0.55 * alpha)
	ci.draw_line(head + Vector2(f * 0.0, -11.5) * u, head + Vector2(f * 8.0, -4.2) * u, st, maxf(1.0, 0.7 * u))
	ci.draw_line(head + Vector2(f * 3.0, -11.5) * u, head + Vector2(f * 10.5, -3.8) * u, st, maxf(1.0, 0.7 * u))
	ci.draw_line(head + Vector2(-f * 6.0, -11.0) * u, head + Vector2(-f * 8.5, -4.0) * u, st, maxf(1.0, 0.7 * u))
	# Eyes, brows, nose, mouth, cheeks.
	var iris: Color = iris_color(hair)
	var brow: Color = Shade.fade(Shade.darken(hair, 0.35), alpha)
	for side in [-1.0, 1.0]:
		var ec: Vector2 = head + Vector2(f * 4.0 + side * 4.5, 1.0) * u
		eye(ci, ec, 0.6 * u, side, iris, alpha, blink)
		ci.draw_polyline(PackedVector2Array([ec + Vector2(-2.6, -4.4) * u, ec + Vector2(0.0, -5.4) * u, ec + Vector2(2.6, -4.4) * u]), brow, maxf(1.0, 0.9 * u))
		ci.draw_circle(head + Vector2(f * 4.0 + side * 7.5, 6.0) * u, 2.4 * u, Color(1.0, 0.45, 0.6, 0.35 * alpha))
	ci.draw_polyline(PackedVector2Array([head + Vector2(f * 12.2, 3.0) * u, head + Vector2(f * 13.8, 5.0) * u, head + Vector2(f * 12.0, 5.8) * u]), Shade.fade(Shade.darken(Shade.SKIN_SHADOW, 0.3), 0.8 * alpha), maxf(1.0, 0.8 * u))
	var mc: Vector2 = head + Vector2(f * 6.5, 8.6) * u
	if wince:
		ci.draw_arc(mc + Vector2(0.0, 2.6) * u, 2.4 * u, PI * 1.15, PI * 1.85, 6, Shade.fade(Shade.INK, alpha), maxf(1.0, 0.9 * u))
		return
	ci.draw_arc(mc, 2.4 * u, PI * 0.15, PI * 0.85, 6, Shade.fade(Shade.INK, alpha), maxf(1.0, 0.9 * u))
	ci.draw_line(mc + Vector2(-0.9, 3.2) * u, mc + Vector2(0.9, 3.2) * u, Shade.fade(LIP, 0.8 * alpha), maxf(1.0, 0.8 * u))


# ---------------- Front view ----------------

## Hair behind the front head (bob mass and locks, or twintails with scrunchies).
static func hair_back_front(ci: CanvasItem, head: Vector2, k: float, hair: Color, twin: bool, alpha: float, sway: float = 0.0) -> void:
	var back: Color = Shade.fade(Shade.darken(hair, 0.2), alpha)
	var edge: Color = Shade.ink(back)
	var w: float = maxf(1.0, 1.3 * k)
	var strand: Color = Shade.fade(Shade.darken(hair, 0.4), 0.55 * alpha)
	var sw: float = maxf(1.0, 0.9 * k)
	if twin:
		for side in [-1.0, 1.0]:
			var root: Vector2 = head + Vector2(side * 25.0, -6.0) * k
			var tip: Vector2 = root + Vector2(side * 10.0 + sway * 1.6, 46.0) * k
			var pts := PackedVector2Array([root + Vector2(-7.0, -3.0) * k, root + Vector2(7.0, -3.0) * k, tip])
			Shade.fill(ci, pts, back, w, edge)
			Shade.shade_band(ci, pts, back, -1.0)
			ci.draw_line(root + Vector2(-2.5, 2.0) * k, tip.lerp(root, 0.1) + Vector2(-side * 1.0, 0.0) * k, strand, sw)
			ci.draw_line(root + Vector2(2.5, 2.0) * k, tip.lerp(root, 0.12) + Vector2(side * 0.5, 0.0) * k, strand, sw)
			ci.draw_line(root + Vector2(0.0, 6.0) * k, tip.lerp(root, 0.3), strand, sw)
			var sc: Color = Shade.fade(PINK, alpha)
			Shade.circle(ci, root, 5.5 * k, sc, w, Shade.ink(sc))
			ci.draw_circle(root + Vector2(-1.8, -1.8) * k, 1.8 * k, Shade.fade(Shade.lighten(PINK, 0.6), 0.8 * alpha))
	else:
		var pts: PackedVector2Array = Shade.ellipse(head + Vector2(0.0, 5.0) * k, 28.0 * k, 28.0 * k, 28)
		Shade.fill(ci, pts, back, w, edge)
		Shade.shade_band(ci, pts, back, -1.0)
		ci.draw_line(head + Vector2(-26.0, 4.0) * k, head + Vector2(-27.5, 20.0) * k, strand, sw)
		ci.draw_line(head + Vector2(26.0, 6.0) * k, head + Vector2(27.0, 21.0) * k, strand, sw)
		for side in [-1.0, 1.0]:
			var lock: Vector2 = head + Vector2(side * 24.0, 16.0) * k
			var lp := PackedVector2Array([lock + Vector2(-6.0, 0.0) * k, lock + Vector2(6.0, 0.0) * k, lock + Vector2(side * 3.0 + sway, 18.0) * k])
			Shade.fill(ci, lp, back, w, edge)
			ci.draw_line(lock + Vector2(0.0, 1.0) * k, lock + Vector2(side * 2.0, 15.0) * k, strand, sw)


## Front head: neck shadow, skin, hair cap with fringe, strands, eyes, brows, nose, mouth, cheeks.
static func face_front(ci: CanvasItem, head: Vector2, k: float, hair: Color, alpha: float, blink: float = 0.0) -> void:
	var skin: Color = Shade.fade(Shade.SKIN, alpha)
	var w: float = maxf(1.0, 1.3 * k)
	ci.draw_colored_polygon(Shade.ellipse(head + Vector2(0.0, 22.0) * k, 8.0 * k, 6.0 * k, 12), Shade.fade(Shade.SKIN_SHADOW, alpha))
	var pts: PackedVector2Array = Shade.ellipse(head, 24.0 * k, 24.0 * k, 32)
	Shade.fill(ci, pts, skin, w, Shade.ink(skin))
	Shade.shade_band(ci, pts, skin, -1.0)
	ci.draw_arc(head, 22.5 * k, PI * 0.22, PI * 0.78, 10, Shade.fade(Shade.SKIN_SHADOW, 0.55 * alpha), maxf(1.0, 2.2 * k))
	# Hair cap and fringe.
	var hc: Color = Shade.fade(hair, alpha)
	var cap := PackedVector2Array()
	for i in range(17):
		var a: float = PI + PI * float(i) / 16.0
		cap.append(head + (Vector2(0.0, -1.0) + Vector2(cos(a), sin(a)) * 25.5) * k)
	for p in FRINGE:
		var fp: Vector2 = p
		cap.append(head + fp * k)
	Shade.fill(ci, cap, hc, w, Shade.ink(hc))
	Shade.shade_band(ci, cap, hc, -1.0)
	ci.draw_arc(head + Vector2(0.0, -1.0) * k, 19.5 * k, PI * 1.12, PI * 1.55, 12, Shade.fade(Shade.lighten(hair, 0.45), 0.8 * alpha), maxf(1.0, 3.2 * k))
	var st: Color = Shade.fade(Shade.darken(hair, 0.4), 0.55 * alpha)
	var sw: float = maxf(1.0, 0.9 * k)
	for s in [[Vector2(-12.0, -21.0), Vector2(-12.0, -13.5)], [Vector2(0.5, -24.0), Vector2(0.5, -11.0)], [Vector2(12.0, -21.0), Vector2(12.0, -13.5)],
			[Vector2(-19.0, -14.0), Vector2(-21.0, -5.0)], [Vector2(19.0, -14.0), Vector2(21.0, -5.0)]]:
		var s0: Vector2 = s[0]
		var s1: Vector2 = s[1]
		ci.draw_line(head + s0 * k, head + s1 * k, st, sw)
	# Face: brows, eyes, nose, mouth, cheeks.
	var iris: Color = iris_color(hair)
	var brow: Color = Shade.fade(Shade.darken(hair, 0.35), alpha)
	for side in [-1.0, 1.0]:
		var ec: Vector2 = head + Vector2(side * 9.5, 3.0) * k
		eye(ci, ec, k, side, iris, alpha, blink)
		ci.draw_polyline(PackedVector2Array([head + Vector2(side * 5.5, -5.2) * k, head + Vector2(side * 10.0, -6.6) * k, head + Vector2(side * 14.0, -5.2) * k]), brow, maxf(1.0, 1.5 * k))
		ci.draw_circle(head + Vector2(side * 15.0, 10.5) * k, 4.0 * k, Color(1.0, 0.45, 0.6, 0.35 * alpha))
	ci.draw_circle(head + Vector2(0.0, 8.6) * k, 0.9 * k, Shade.fade(Shade.darken(Shade.SKIN_SHADOW, 0.3), 0.9 * alpha))
	ci.draw_circle(head + Vector2(-0.3, 8.0) * k, 0.45 * k, Shade.fade(Shade.SKIN_LIGHT, alpha))
	ci.draw_arc(head + Vector2(0.0, 10.0) * k, 4.2 * k, PI * 0.2, PI * 0.8, 8, Shade.fade(Shade.INK, alpha), maxf(1.0, 1.5 * k))
	ci.draw_line(head + Vector2(-1.4, 15.0) * k, head + Vector2(1.4, 15.0) * k, Shade.fade(LIP, 0.85 * alpha), maxf(1.0, 1.1 * k))
