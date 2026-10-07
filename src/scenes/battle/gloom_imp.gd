extends RefCounted
## The Gloomling (Story 031): a small shadow imp kid in a tattered hoodie, with horns peeking out of
## the hood, pointy ears, a spade tail and big glowing eyes. Walks, breathes, lunges and reacts to
## hits via the `fx` dictionary (see Kit.make_rig). Also used (small) by Star Catch and Zap Patrol.

const Kit := preload("res://scenes/battle/gloom_kit.gd")
const Face := preload("res://scenes/battle/gloom_face.gd")
const Gear := preload("res://scenes/battle/gloom_gear.gd")
const Shade := preload("res://scripts/hunter_shade.gd")


## Draws one Gloomling standing on `ground_y` (feet) with size `s`; returns the draw-call count.
static func draw(ci: CanvasItem, x: float, ground_y: float, s: float, color: Color, age: int, toward: float, u: float, fx: Dictionary = {}) -> int:
	var r: Kit.Rig = Kit.make_rig(ci, x, ground_y, s, color, age, toward, u, fx)
	var skin: Color = Shade.lighten(color.lerp(Color("#2A1858"), 0.66), 0.08)
	var hood: Color = color.lerp(Color("#241048"), 0.6)
	var pants := Color("#2C1D55")
	var shoe := Color("#1A1236")
	Kit.aura(r, -50.0, 68.0, 0.16)
	Kit.floor_shadow(r, 24.0)
	Gear.tail(r, -8.0, -28.0, 30.0, skin, color)
	Kit.legs(r, -24.0, 8.0, 9.0, pants, shoe, 8.5, 4.5, 6.0, 7.0)
	if r.detail:
		for sd in [-1.0, 1.0]:
			r.disc(float(sd) * 8.6, -1.2, 3.0, Color(r.glow, 0.5))
	# Upper body: breathing bob, lunge forward on wind-up / bump, rock back when hit.
	var bob: float = (-absf(sin(r.ph)) * 2.6 * r.walk) - r.breath * 1.2
	r.o.y += bob * r.ky
	r.o.x += (r.near * 3.0 + r.strike * 8.0 - r.flash * 5.0) * r.dir * r.kx
	# Torso: hoodie with a tattered zig-zag hem.
	r.poly([
		Vector2(-14, -57), Vector2(14, -57), Vector2(18, -24), Vector2(13, -20), Vector2(8, -25), Vector2(3, -20),
		Vector2(-3, -25), Vector2(-8, -20), Vector2(-13, -25), Vector2(-18, -24),
	], hood)
	if r.detail:
		r.poly([Vector2(-9, -32), Vector2(9, -32), Vector2(11, -26), Vector2(-11, -26)], Shade.darken(hood, 0.2), false)
	Gear.trim(r, Vector2(0, -54), Vector2(0, -34), 1.2)
	if r.detail:
		r.disc(-4.5, -44, 1.8, Shade.lighten(r.glow, 0.5))
		r.disc(4.5, -44, 1.8, Shade.lighten(r.glow, 0.5))
	# Arms (behind the head, in front of the torso).
	for sd in [-1.0, 1.0]:
		var side: float = sd
		var raise: float = 0.4 + Kit.swing(r, side, 0.55)
		if r.air:
			raise = 2.4 + (0.0 if r.calm else sin(r.t * 0.3 + side) * 0.3)
		Kit.arm(r, side, Vector2(side * 15.0, -52.0), 20.0, 8.0, hood, skin, raise, 5.0)
	# Head: hood, ears, horns, face.
	var hy: float = -80.0
	var tilt: float = 0.0 if r.calm else sin(r.t * 0.11) * 1.0
	Gear.hood_back(r, tilt, hy, 25.0, 22.0, hood)
	Gear.ears(r, tilt, hy + 2.0, 25.0, 22.0, skin, color.lerp(Color("#FF8FB8"), 0.5))
	Gear.horns(r, tilt, hy, 25.0, 22.0, 15.0, skin.lerp(Color.WHITE, 0.15), Shade.lighten(r.glow, 0.5))
	r.ell(tilt, hy + 2.0, 22.0, 20.0, skin, true)
	Gear.hood_rim(r, tilt, hy + 2.0, 23.0, 20.0, hood)
	Face.draw(r, tilt, hy + 3.0, 22.0, 19.0, r.mood, {"skin": skin, "eye_scale": 1.15, "brow": Shade.darken(skin, 0.7)})
	return r.n
