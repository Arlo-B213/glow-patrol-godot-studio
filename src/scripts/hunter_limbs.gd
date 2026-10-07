extends RefCounted
## Legs, boots, arms and hands of the idol hunter (Story 015, upgraded in Story 032), both
## side-view and front. Limbs are tapered with elbows/knees, boots have cuffs, toe caps and glow
## piping, hands show fingers (relaxed) or a wrapped grip. Every function draws onto a CanvasItem
## from its _draw(). `alpha` is the view alpha.

const Shade := preload("res://scripts/hunter_shade.gd")

const LEG := Color("#2A1B4D")
const SOLE := Color("#160A2B")
const NO_RIM := Color(0.0, 0.0, 0.0, 0.0)


## Side-view leg, hip to foot: tapered trouser with a knee bend, seam and glow piping.
static func leg_side(ci: CanvasItem, hip: Vector2, foot: Vector2, u: float, alpha: float, rim: Color = NO_RIM) -> void:
	var col: Color = Shade.fade(Shade.lighten(LEG, 0.08), alpha)
	var ow: float = maxf(1.0, 1.0 * u)
	var d: Vector2 = foot - hip
	var perp: Vector2 = d.orthogonal().normalized()
	var knee: Vector2 = hip + d * 0.5 + perp * (3.0 * u if perp.x > 0.0 else -3.0 * u) * 0.6
	var ankle: Vector2 = foot - Vector2(0.0, 1.0) * u
	Shade.taper(ci, hip, knee, 10.5 * u, 8.6 * u, col, ow, -1.0, rim)
	Shade.taper(ci, knee, ankle, 8.6 * u, 7.0 * u, col, ow, -1.0, rim)
	ci.draw_circle(knee, 4.2 * u, col)
	ci.draw_line(knee + Vector2(-3.0, 0.5) * u, knee + Vector2(3.0, 0.5) * u, Shade.fade(Shade.darken(col, 0.45), 0.55), maxf(1.0, 0.8 * u))
	ci.draw_line(hip.lerp(knee, 0.2) + Vector2(0.0, 0.0), ankle.lerp(knee, 0.2), Shade.fade(Color("#FFF2FF"), 0.18 * alpha), maxf(1.0, 0.8 * u))


## Side-view boot at `foot`, toe pointing toward `f` (-1 or 1): shaft, cuff, toe cap, laces, sole.
static func boot_side(ci: CanvasItem, foot: Vector2, u: float, f: float, glow: Color, alpha: float) -> void:
	var col: Color = Shade.fade(glow, alpha)
	var ow: float = maxf(1.0, 1.0 * u)
	var pts := _boot_pts(foot, u, f, [Vector2(-5.0, -10.0), Vector2(3.8, -10.0), Vector2(4.4, -4.0), Vector2(8.0, -2.0), Vector2(9.2, 1.5), Vector2(9.2, 4.0), Vector2(-6.8, 4.0), Vector2(-6.8, -3.0)])
	Shade.fill(ci, pts, col, ow, Shade.ink(col))
	Shade.shade_band(ci, pts, col, -f)
	var cuff := _boot_pts(foot, u, f, [Vector2(-5.2, -10.2), Vector2(4.0, -10.2), Vector2(4.1, -7.4), Vector2(-5.2, -7.4)])
	Shade.fill(ci, cuff, Shade.fade(Shade.lighten(glow, 0.5), alpha), maxf(1.0, 0.7 * u), Shade.ink(col))
	var cap := _boot_pts(foot, u, f, [Vector2(5.0, -1.8), Vector2(8.2, -1.2), Vector2(9.0, 1.5), Vector2(9.0, 2.6), Vector2(4.6, 2.6)])
	ci.draw_colored_polygon(cap, Shade.fade(Shade.darken(glow, 0.25), 0.8 * alpha))
	var sole := _boot_pts(foot, u, f, [Vector2(-6.8, 2.6), Vector2(9.2, 2.6), Vector2(9.2, 4.2), Vector2(-6.8, 4.2)])
	ci.draw_colored_polygon(sole, Shade.fade(SOLE, alpha))
	ci.draw_colored_polygon(_boot_pts(foot, u, f, [Vector2(-6.8, 4.2), Vector2(-3.0, 4.2), Vector2(-3.0, 5.4), Vector2(-6.8, 5.4)]), Shade.fade(SOLE, alpha))
	for i in range(3):
		var lx: float = -2.0 + 2.2 * float(i)
		ci.draw_line(foot + Vector2(f * (lx + 2.0), -5.5 + 1.0 * float(i)) * u, foot + Vector2(f * (lx + 3.6), -4.6 + 1.0 * float(i)) * u, Shade.fade(Color.WHITE, 0.7 * alpha), maxf(1.0, 0.7 * u))
	ci.draw_line(foot + Vector2(f * (-4.0 + 2.0), -1.0) * u, foot + Vector2(f * (6.0 + 2.0), -0.4) * u, Shade.fade(Shade.lighten(glow, 0.6), 0.85 * alpha), maxf(1.0, 1.0 * u))
	ci.draw_circle(foot + Vector2(f * (-1.0 + 2.0), -8.8) * u, 0.9 * u, Shade.fade(Color("#FFD36E"), alpha))


static func _boot_pts(foot: Vector2, u: float, f: float, local: Array) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var order: Array = local if f > 0.0 else local.duplicate()
	for p in order:
		var lp: Vector2 = p
		pts.append(foot + Vector2(f * (lp.x + 2.0), lp.y) * u)
	if f < 0.0:
		pts.reverse()
	return pts


## Front-view leg and boot, centred at x `side * 9..10`, in figure space scaled by `k`.
static func leg_front(ci: CanvasItem, origin: Vector2, up: Vector2, side: float, k: float, outfit: Color, glow: Color, alpha: float, spread: float = 0.0, shorten: float = 0.0) -> void:
	var col: Color = Shade.fade(outfit.lerp(Shade.INK, 0.45), alpha)
	var top: Vector2 = origin + Vector2(side * 8.5, -25.0 + shorten) * k + up * 0.5
	var bot: Vector2 = origin + Vector2(side * (9.5 + spread), -9.0) * k
	var rim: Color = Shade.fade(Shade.lighten(glow, 0.3), 0.55 * alpha)
	Shade.taper(ci, top, bot, 14.0 * k, 9.0 * k, col, maxf(1.0, 1.1 * k), -1.0, rim if side < 0.0 else NO_RIM)
	ci.draw_line(top + Vector2(side * 5.2, 2.0) * k, bot + Vector2(side * 3.4, 0.0), Shade.fade(glow, 0.7 * alpha), maxf(1.0, 1.0 * k))
	var bc: Vector2 = origin + Vector2(side * (10.0 + spread), 0.0) * k
	var bcol: Color = Shade.fade(glow, alpha)
	var pts := PackedVector2Array([
		bc + Vector2(-6.0, -11.0) * k, bc + Vector2(6.0, -11.0) * k, bc + Vector2(7.5, -4.0) * k, bc + Vector2(9.5, -1.5) * k,
		bc + Vector2(10.0, 1.0) * k, bc + Vector2(-10.0, 1.0) * k, bc + Vector2(-9.5, -1.5) * k, bc + Vector2(-7.5, -4.0) * k,
	])
	Shade.fill(ci, pts, bcol, maxf(1.0, 1.1 * k), Shade.ink(bcol))
	Shade.shade_band(ci, pts, bcol, -1.0)
	ci.draw_colored_polygon(PackedVector2Array([bc + Vector2(-9.8, -1.2) * k, bc + Vector2(9.8, -1.2) * k, bc + Vector2(10.0, 1.0) * k, bc + Vector2(-10.0, 1.0) * k]), Shade.fade(SOLE, alpha))
	Shade.fill(ci, PackedVector2Array([bc + Vector2(-6.4, -11.2) * k, bc + Vector2(6.4, -11.2) * k, bc + Vector2(6.8, -8.2) * k, bc + Vector2(-6.8, -8.2) * k]), Shade.fade(Shade.lighten(glow, 0.5), alpha), maxf(1.0, 0.8 * k), Shade.ink(bcol))
	ci.draw_colored_polygon(Shade.ellipse(bc + Vector2(0.0, -3.4) * k, 4.8 * k, 2.4 * k, 10), Shade.fade(Shade.darken(glow, 0.25), 0.7 * alpha))
	ci.draw_line(bc + Vector2(-7.0, -5.6) * k, bc + Vector2(7.0, -5.6) * k, Shade.fade(Shade.lighten(glow, 0.55), 0.85 * alpha), maxf(1.0, 1.1 * k))
	ci.draw_circle(bc + Vector2(0.0, -9.7) * k, 1.0 * k, Shade.fade(Color("#FFD36E"), alpha))


## Sleeve/arm from `a` to `b` with an elbow bend, tapered, plus a lighter cuff at the wrist.
## `bend` is the elbow offset as a fraction of arm length (0 = straight).
static func arm(ci: CanvasItem, a: Vector2, b: Vector2, w: float, outfit: Color, alpha: float, bend: float = 0.1, rim: Color = NO_RIM) -> void:
	var col: Color = Shade.fade(outfit.lerp(Color.WHITE, 0.2), alpha)
	var d: Vector2 = b - a
	var perp: Vector2 = d.orthogonal().normalized()
	if perp.y < 0.0:
		perp = -perp
	var elbow: Vector2 = a + d * 0.5 + perp * d.length() * bend
	var ow: float = maxf(1.0, w * 0.13)
	Shade.taper(ci, a, elbow, w, w * 0.86, col, ow, -1.0, rim)
	Shade.taper(ci, elbow, b, w * 0.86, w * 0.72, col, ow, -1.0, rim)
	ci.draw_circle(elbow, w * 0.42, col)
	var dn: Vector2 = (b - elbow).normalized()
	var cuff: Color = Shade.lighten(col, 0.3)
	Shade.limb(ci, b - dn * w * 0.55, b - dn * w * 0.3, w * 0.9, cuff, maxf(1.0, w * 0.1), -1.0)


## A bare hand at `c`. `dir` is the glowstick direction (unit) when `grip` is true: four
## knuckle bumps wrap the stick and the thumb lies on top. With `grip` false the hand hangs
## open along `dir` (pass Vector2.DOWN) with four fingers and a thumb.
static func hand(ci: CanvasItem, c: Vector2, dir: Vector2, r: float, alpha: float, grip: bool = true) -> void:
	var skin: Color = Shade.fade(Shade.SKIN, alpha)
	var ink: Color = Shade.ink(skin)
	var lw: float = maxf(1.0, r * 0.2)
	var perp: Vector2 = dir.orthogonal()
	var gap: Color = Shade.fade(Shade.darken(Shade.SKIN_SHADOW, 0.25), 0.85 * alpha)
	if grip:
		Shade.fill(ci, Shade.ellipse(c, r * 0.95, r * 0.8, 14), skin, lw, ink)
		for i in range(4):
			var fp: Vector2 = c + dir * (float(i) - 1.5) * r * 0.5 + perp * r * 0.34
			Shade.fill(ci, Shade.ellipse(fp, r * 0.42, r * 0.3, 8), Shade.fade(Shade.SKIN_LIGHT.lerp(Shade.SKIN, 0.5), alpha), maxf(1.0, r * 0.12), ink)
		var tp: Vector2 = c - dir * r * 0.5 - perp * r * 0.3
		Shade.fill(ci, Shade.ellipse(tp, r * 0.5, r * 0.34, 8), Shade.fade(Shade.SKIN_LIGHT, alpha), maxf(1.0, r * 0.14), ink)
		ci.draw_line(c - dir * r * 0.9 + perp * r * 0.1, c + dir * r * 0.9 + perp * r * 0.1, gap, maxf(1.0, r * 0.12))
		return
	Shade.fill(ci, Shade.ellipse(c, r * 0.9, r * 0.85, 14), skin, lw, ink)
	for i in range(4):
		var ang: float = (float(i) - 1.5) * 0.3
		var fd: Vector2 = dir.rotated(ang)
		var base: Vector2 = c + fd * r * 0.55
		Shade.fill(ci, Shade.capsule(base, base + fd * r * (0.85 if i != 0 and i != 3 else 0.7), r * 0.21, 4), skin, maxf(1.0, r * 0.12), ink)
	var th: Vector2 = c + dir.rotated(-0.9) * r * 0.65
	Shade.fill(ci, Shade.capsule(th, th + dir.rotated(-0.5) * r * 0.55, r * 0.24, 4), Shade.fade(Shade.SKIN_LIGHT, alpha), maxf(1.0, r * 0.12), ink)
