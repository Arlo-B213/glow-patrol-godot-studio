extends RefCounted
## The Mossback (Story 031): a hulking gloom brute with a mossy shell cloak, mushrooms on its
## shoulders, big fists and a grumpy human-like face sunk between its shoulders. Takes two punches;
## with `fx.hp` <= 1 the right-hand mushroom has been knocked off.

const Kit := preload("res://scenes/battle/gloom_kit.gd")
const Face := preload("res://scenes/battle/gloom_face.gd")
const Gear := preload("res://scenes/battle/gloom_gear.gd")
const Shade := preload("res://scripts/hunter_shade.gd")


## Draws one Mossback; returns the draw-call count. See Kit.make_rig for `fx`.
static func draw(ci: CanvasItem, x: float, ground_y: float, s: float, color: Color, age: int, toward: float, u: float, fx: Dictionary = {}) -> int:
	var r: Kit.Rig = Kit.make_rig(ci, x, ground_y, s * 0.98, color, age, toward, u, fx)
	var moss: Color = color.lerp(Color("#1F4A2A"), 0.2)
	var moss_dark: Color = moss.lerp(Color("#10281A"), 0.45)
	var skin: Color = Color("#5B4A86").lerp(color, 0.1)
	var tunic: Color = Color("#3B2E63")
	var pants := Color("#2A2048")
	var plod: float = absf(sin(r.ph * 0.5)) * r.walk
	Kit.aura(r, -52.0, 74.0, 0.14)
	Kit.floor_shadow(r, 40.0)
	Kit.legs(r, -26.0, 19.0, 18.0, pants, Color("#1D1636"), 14.0, 6.5, 5.0, 4.0)
	r.o.y -= plod * 3.0 * r.ky
	r.o.x += (r.near * 3.0 + r.strike * 7.0 - r.flash * 5.0) * r.dir * r.kx
	# Mossy shell dome behind the shoulders.
	r.ell(0.0, -66.0, 47.0, 36.0, moss_dark, true)
	for lp in [Vector2(-34, -92), Vector2(-14, -100), Vector2(8, -102), Vector2(28, -96), Vector2(42, -82), Vector2(-44, -76)]:
		var v: Vector2 = lp
		r.circ(v.x, v.y, 7.5, moss, true)
	# Barrel torso with a pale belly.
	r.ell(0.0, -48.0, 36.0, 29.0, tunic, true)
	r.ell(0.0, -42.0, 22.0, 17.0, Shade.lighten(tunic, 0.14), false, false)
	Gear.trim(r, Vector2(-26, -34), Vector2(26, -34), 1.4)
	r.circ(0.0, -34.0, 4.0, Color("#FFD36E"), true)
	# Heavy arms with big fists; wind up overhead when the hunter is close, slam on a bump.
	for sd in [-1.0, 1.0]:
		var side: float = sd
		var raise: float = 0.2 + Kit.swing(r, side, 0.25)
		if r.air:
			raise = 2.3
		Kit.arm(r, side, Vector2(side * 36.0, -62.0), 33.0, 15.0, tunic, skin, raise, 11.5)
	# Head: small and low, with moss hair and a grumpy face.
	var hy: float = -84.0
	r.ell(0.0, hy, 23.0, 20.0, skin, true)
	for i in 5:
		var fx2: float = -18.0 + float(i) * 9.0
		r.circ(fx2, hy - 17.0 - (3.0 if i % 2 == 1 else 0.0), 7.0, moss, true)
	var mood: int = Kit.Mood.GRUMP if r.mood == Kit.Mood.IDLE else r.mood
	Face.draw(r, 0.0, hy + 2.0, 23.0, 19.0, mood, {"skin": skin, "eye": Color("#FFE27A"), "brow": moss_dark, "brow_w": 1.7, "nose": 1.7, "eye_scale": 0.9, "fang": false})
	# Shoulder moss and mushrooms (the right-hand one falls off after the first punch).
	r.circ(-40.0, -70.0, 8.0, moss, true)
	r.circ(40.0, -70.0, 8.0, moss, true)
	Gear.mushroom(r, -38.0, -80.0, 15.0, Color("#FF7A8A"))
	if r.hp >= 2:
		Gear.mushroom(r, 38.0, -80.0, 17.0, Color("#FF9A5A"))
	else:
		r.ell(38.0, -80.0, 3.0, 2.0, Color("#F6EBD9"), false, false)
	return r.n
