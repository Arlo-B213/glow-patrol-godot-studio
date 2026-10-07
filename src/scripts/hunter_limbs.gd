extends RefCounted
## Legs, boots, arms and hands of the idol hunter (Story 015), both side-view and front.
## Every function draws onto a CanvasItem from its _draw(). `alpha` is the view alpha.

const Shade := preload("res://scripts/hunter_shade.gd")

const LEG := Color("#2A1B4D")
const SOLE := Color("#160A2B")


## Side-view leg, hip to foot, trousers with outline and shading.
static func leg_side(ci: CanvasItem, hip: Vector2, foot: Vector2, u: float, alpha: float) -> void:
	var col: Color = Shade.fade(Shade.lighten(LEG, 0.08), alpha)
	Shade.limb(ci, hip, foot, 9.0 * u, col, maxf(1.0, 1.0 * u), -1.0)
	# Knee seam.
	var knee: Vector2 = hip.lerp(foot, 0.5)
	ci.draw_line(knee + Vector2(-3.0, 0.0) * u, knee + Vector2(3.0, 0.0) * u, Shade.fade(Shade.darken(col, 0.4), 0.5), maxf(1.0, 0.8 * u))


## Side-view boot at `foot`, toe pointing toward `f` (-1 or 1), with sole and trim.
static func boot_side(ci: CanvasItem, foot: Vector2, u: float, f: float, glow: Color, alpha: float) -> void:
	var col: Color = Shade.fade(glow, alpha)
	var pts := _boot_pts(foot, u, f, [Vector2(-6.0, -3.0), Vector2(2.0, -3.0), Vector2(5.5, -0.5), Vector2(7.0, 2.5), Vector2(7.0, 4.0), Vector2(-6.0, 4.0)])
	Shade.fill(ci, pts, col, maxf(1.0, 1.0 * u), Shade.ink(col))
	Shade.shade_band(ci, pts, col, -f)
	var sole := _boot_pts(foot, u, f, [Vector2(-6.0, 2.3), Vector2(7.0, 2.3), Vector2(7.0, 4.0), Vector2(-6.0, 4.0)])
	ci.draw_colored_polygon(sole, Shade.fade(SOLE, alpha))
	var a: Vector2 = foot + Vector2(f * (-5.8 + 2.0), -1.5) * u
	var b: Vector2 = foot + Vector2(f * (3.2 + 2.0), -1.5) * u
	ci.draw_line(a, b, Shade.fade(Shade.lighten(glow, 0.55), 0.85 * alpha), maxf(1.0, 1.1 * u))


static func _boot_pts(foot: Vector2, u: float, f: float, local: Array) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for p in local:
		var lp: Vector2 = p
		pts.append(foot + Vector2(f * (lp.x + 2.0), lp.y) * u)
	return pts


## Front-view leg and boot, centred at x `side * 9..10`, in figure space scaled by `k`.
static func leg_front(ci: CanvasItem, origin: Vector2, up: Vector2, side: float, k: float, outfit: Color, glow: Color, alpha: float) -> void:
	var col: Color = Shade.fade(outfit.lerp(Shade.INK, 0.45), alpha)
	var top: Vector2 = origin + Vector2(side * 9.0, -24.0) * k + up * 0.5
	var bot: Vector2 = origin + Vector2(side * 10.0, -5.0) * k
	Shade.limb(ci, top, bot, 12.0 * k, col, maxf(1.0, 1.1 * k), -1.0)
	var bc: Vector2 = origin + Vector2(side * 10.0, 0.0) * k
	var bcol: Color = Shade.fade(glow, alpha)
	var pts := PackedVector2Array([
		bc + Vector2(-7.5, -8.0) * k, bc + Vector2(7.5, -8.0) * k, bc + Vector2(8.5, -2.0) * k,
		bc + Vector2(9.5, 1.0) * k, bc + Vector2(-9.5, 1.0) * k, bc + Vector2(-8.5, -2.0) * k,
	])
	Shade.fill(ci, pts, bcol, maxf(1.0, 1.1 * k), Shade.ink(bcol))
	Shade.shade_band(ci, pts, bcol, -1.0)
	ci.draw_colored_polygon(PackedVector2Array([bc + Vector2(-9.2, -1.6) * k, bc + Vector2(9.2, -1.6) * k, bc + Vector2(9.5, 1.0) * k, bc + Vector2(-9.5, 1.0) * k]), Shade.fade(SOLE, alpha))
	ci.draw_line(bc + Vector2(-7.2, -5.6) * k, bc + Vector2(7.2, -5.6) * k, Shade.fade(Shade.lighten(glow, 0.55), 0.85 * alpha), maxf(1.0, 1.2 * k))


## Sleeve/arm from `a` to `b` with a lighter cuff at the wrist.
static func arm(ci: CanvasItem, a: Vector2, b: Vector2, w: float, outfit: Color, alpha: float) -> void:
	var col: Color = Shade.fade(outfit.lerp(Color.WHITE, 0.2), alpha)
	Shade.limb(ci, a, b, w, col, maxf(1.0, w * 0.13), -1.0)
	var d: Vector2 = (b - a).normalized()
	var cuff: Color = Shade.lighten(col, 0.3)
	Shade.limb(ci, b - d * w * 0.55, b - d * w * 0.3, w * 1.05, cuff, maxf(1.0, w * 0.1), -1.0)


## A bare hand/fist at `c` with finger strokes and a thumb. `dir` is the glowstick direction
## (unit); pass Vector2.DOWN for a relaxed open hand.
static func hand(ci: CanvasItem, c: Vector2, dir: Vector2, r: float, alpha: float) -> void:
	var skin: Color = Shade.fade(Shade.SKIN, alpha)
	var pts: PackedVector2Array = Shade.ellipse(c, r, r, 14)
	Shade.fill(ci, pts, skin, maxf(1.0, r * 0.22), Shade.ink(skin))
	Shade.shade_band(ci, pts, skin, -1.0)
	var perp: Vector2 = dir.orthogonal()
	var gap: Color = Shade.fade(Shade.darken(Shade.SKIN_SHADOW, 0.25), 0.85 * alpha)
	var lw: float = maxf(1.0, r * 0.2)
	for i in range(3):
		var p: Vector2 = c + dir * (float(i) - 1.0) * r * 0.55
		ci.draw_line(p - perp * r * 0.7, p + perp * r * 0.7, gap, lw)
	var thumb: Vector2 = c + dir * r * 0.55 + perp * r * 0.85
	var tp: PackedVector2Array = Shade.ellipse(thumb, r * 0.42, r * 0.42, 8)
	Shade.fill(ci, tp, Shade.fade(Shade.SKIN_LIGHT, alpha), maxf(1.0, r * 0.16), Shade.ink(skin))
