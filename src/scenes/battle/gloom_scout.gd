extends RefCounted
## The Blinker (Story 031): a lanky hopping gloom scout with spiky hair, one huge glowing monocle eye,
## a tiny second eye, a streaming scarf and springy bent legs. It only travels during the air part of
## its hop (`airborne`), which the combat code shares.

const Kit := preload("res://scenes/battle/gloom_kit.gd")
const Face := preload("res://scenes/battle/gloom_face.gd")
const Gear := preload("res://scenes/battle/gloom_gear.gd")
const Shade := preload("res://scripts/hunter_shade.gd")
const HOP_CYCLE := 36
const HOP_AIR := 22


## True while a Blinker is in the air part of its hop.
static func airborne(age: int) -> bool:
	return age % HOP_CYCLE < HOP_AIR


## Draws one Blinker; returns the draw-call count. See Kit.make_rig for `fx`.
static func draw(ci: CanvasItem, x: float, ground_y: float, s: float, color: Color, age: int, toward: float, u: float, fx: Dictionary = {}) -> int:
	var r: Kit.Rig = Kit.make_rig(ci, x, ground_y, s * 1.12, color, age, toward, u, fx)
	var skin: Color = Shade.lighten(color.lerp(Color("#162A5C"), 0.72), 0.06)
	var jacket: Color = color.lerp(Color("#10224A"), 0.58)
	var hair: Color = color.lerp(Color.WHITE, 0.12)
	var pants := Color("#1B2147")
	var ph: int = age % HOP_CYCLE
	var lift: float = 0.0
	var sag: float = 0.0
	if r.calm:
		pass
	elif ph < HOP_AIR:
		lift = sin(float(ph) / float(HOP_AIR) * PI) * 12.0
	else:
		sag = sin(float(ph - HOP_AIR) / float(HOP_CYCLE - HOP_AIR) * PI) * 9.0
	Kit.floor_shadow(r, 20.0 - lift * 0.5)
	var shift: float = sag - lift
	r.o.y += shift * r.ky
	Kit.aura(r, -70.0, 64.0, 0.15)
	# Springy legs: bent at the knee, folded when crouching.
	for sd in [-1.0, 1.0]:
		var side: float = sd
		var hip := Vector2(side * 6.0, -40.0)
		var foot := Vector2(side * 9.0, -lift * 0.4 - shift - 2.0)
		var mid: Vector2 = hip.lerp(foot, 0.5) + Vector2(side * (7.0 + sag * 0.9), 0.0)
		r.limb(hip, mid, 6.5, pants)
		r.limb(mid, foot, 6.0, pants)
		r.ell(foot.x + side * 2.0, foot.y + 1.5, 7.5, 3.6, Color("#16123A"), false)
		r.disc(foot.x + side * 2.0, foot.y + 4.0, 2.6, Color(r.glow, 0.55))
	r.o.x += (r.near * 3.0 + r.strike * 7.0 - r.flash * 5.0) * r.dir * r.kx
	# Torso: slim jacket with a glowing zip, hem and belt.
	r.poly([Vector2(-11, -72), Vector2(11, -72), Vector2(12, -38), Vector2(-12, -38)], jacket)
	Gear.trim(r, Vector2(0, -70), Vector2(0, -40), 1.1)
	Gear.trim(r, Vector2(-12, -46), Vector2(12, -46), 1.0)
	r.disc(-6, -62, 1.6, Shade.lighten(r.glow, 0.5))
	# Streaming scarf (behind the head).
	Gear.scarf(r, 0.0, -74.0, 11.0, Color("#FF5FA2"), 20.0 + (0.0 if r.calm else sin(r.t * 0.2) * 3.0))
	# Long thin arms: swing while hopping, wave up when airborne.
	for sd in [-1.0, 1.0]:
		var side2: float = sd
		var raise: float = 0.25 + Kit.swing(r, side2, 0.0) + (0.9 if lift > 3.0 else 0.0) + r.near * 0.4
		if r.air:
			raise = 2.3
		Kit.arm(r, side2, Vector2(side2 * 11.0, -68.0), 27.0, 6.0, jacket, skin, raise, 4.2)
	# Head with tall spiky hair, big monocle eye and a tiny second eye.
	var hy: float = -91.0
	Gear.spikes(r, 0.0, hy, 19.0, 17.0, 5, 24.0, hair)
	Gear.ears(r, 0.0, hy + 2.0, 19.0, 17.0, skin, color.lerp(Color("#FF8FB8"), 0.4))
	r.ell(0.0, hy + 2.0, 18.0, 16.5, skin, true)
	Gear.spikes(r, 0.0, hy + 1.0, 18.0, 16.0, 4, 7.0, hair)
	Face.draw(r, 0.0, hy + 3.0, 18.0, 16.0, r.mood, {"skin": skin, "big_side": 1.0, "eye_scale": 1.1, "brow": Shade.darken(hair, 0.55), "nose": 0.8})
	return r.n
