extends RefCounted
## The Grumble King (Story 031): a regal, grumpy giant with a crown, bushy brows and beard, a
## flowing cape and big hands, one holding a cracked glowing lantern. Cool angry-but-sad face.
## Extras via `fx`: hpf (health fraction, <= 0.34 = enraged: red eyes, steam, cracked crown),
## intro (true while striking the entrance pose), stun, near, plus the usual flash/alpha.

const Kit := preload("res://scenes/battle/gloom_kit.gd")
const Face := preload("res://scenes/battle/gloom_face.gd")
const Gear := preload("res://scenes/battle/gloom_gear.gd")
const Shade := preload("res://scripts/hunter_shade.gd")
const GOLD := Color("#FFD36E")
const GOLD_DARK := Color("#C98F2A")
const PINK := Color("#FF5FA2")
const INTRO_FRAMES := 60


## Draws the king standing on `ground_y` with size `s`; returns the draw-call count.
static func draw(ci: CanvasItem, x: float, ground_y: float, s: float, age: int, toward: float, u: float, fx: Dictionary = {}) -> int:
	var hpf: float = float(fx.get("hpf", 1.0))
	var enraged: bool = hpf <= 0.34
	var intro: bool = age < INTRO_FRAMES and not Kit.calm()
	var accent: Color = Color("#FF5A3C") if enraged else PINK
	var rfx: Dictionary = fx.duplicate()
	if intro and age >= 14 and not rfx.has("dying"):
		rfx["mood"] = Kit.Mood.ROAR
	elif enraged and not rfx.has("dying") and float(rfx.get("flash", 0.0)) <= 0.3 and not bool(rfx.get("stun", false)):
		rfx["mood"] = Kit.Mood.ANGRY
	var r: Kit.Rig = Kit.make_rig(ci, x, ground_y, s * 0.98, accent, age, toward, u, rfx)
	r.ph *= 0.7
	var skin := Color("#6F5BA8")
	var robe := Color("#3B1A72")
	var cape := Color("#8A2A7E")
	var beard := Color("#CFC8E6")
	Kit.aura(r, -70.0, 92.0 if enraged else 84.0, 0.17 if enraged else 0.14)
	Kit.floor_shadow(r, 52.0)
	# Cape: a big flowing shape behind the whole body, hem rippling.
	var rip: float = 0.0 if r.calm else r.t * 0.1
	var c0: float = sin(rip) * 3.0
	var c1: float = sin(rip + 1.4) * 3.0
	r.poly([
		Vector2(-30, -92), Vector2(30, -92), Vector2(50, -12 + c0), Vector2(32, -4 + c1), Vector2(14, -12 - c0),
		Vector2(-4, -3 + c1), Vector2(-20, -12 + c0), Vector2(-34, -4 - c1), Vector2(-52, -12 - c0),
	], cape)
	r.poly([Vector2(-22, -88), Vector2(22, -88), Vector2(34, -22), Vector2(-34, -22)], Shade.darken(cape, 0.35), false)
	Kit.legs(r, -32.0, 16.0, 17.0, Color("#2A1250"), Color("#1A0B33"), 15.0, 7.0, 5.0, 4.0)
	var plod: float = absf(sin(r.ph * 0.6)) * r.walk
	var lunge: float = (r.near * 3.0 + r.strike * 8.0 - r.flash * 6.0) * 0.8
	r.o.y -= (plod * 2.5 + r.breath * 1.2) * r.ky
	r.o.x += lunge * r.dir * r.kx
	# Robe and armour: wide shoulders, gold belt, glowing chest gem.
	r.poly([Vector2(-36, -88), Vector2(36, -88), Vector2(31, -30), Vector2(-31, -30)], robe)
	r.poly([Vector2(-31, -46), Vector2(31, -46), Vector2(30, -38), Vector2(-30, -38)], GOLD_DARK, true)
	r.circ(0.0, -42.0, 5.5, GOLD, true)
	var gem: float = 1.0 if r.calm else 0.75 + 0.25 * sin(r.t * 0.14)
	r.disc(0.0, -66.0, 12.0 * gem, Color(accent, 0.28))
	r.circ(0.0, -66.0, 5.0, accent.lerp(Color.WHITE, 0.25), true)
	Gear.trim(r, Vector2(-26, -34), Vector2(26, -34), 1.2)
	# Arms: lantern hand on the far side, fist on the near side. Entrance pose throws both up.
	var f_in: float = clampf(float(age) / float(INTRO_FRAMES), 0.0, 1.0)
	var fist_raise: float = 0.2 + Kit.swing(r, 1.0, 0.18)
	var lan_raise: float = 0.55 + Kit.swing(r, -1.0, 0.1) * 0.5
	if intro:
		fist_raise = lerpf(2.5, fist_raise, f_in * f_in)
		lan_raise = lerpf(2.5, lan_raise, f_in * f_in)
	Kit.arm(r, 1.0, Vector2(41.0, -80.0), 36.0, 16.0, robe, skin, fist_raise, 12.0)
	var h0: Vector2 = Kit.arm(r, -1.0, Vector2(-41.0, -80.0), 36.0, 16.0, robe, skin, lan_raise, 12.0)
	_lantern(r, h0, accent)
	# Pauldrons.
	for sd in [-1.0, 1.0]:
		r.ell(float(sd) * 40.0, -86.0, 14.0, 9.0, GOLD, true)
		r.poly([Vector2(float(sd) * 36.0, -92.0), Vector2(float(sd) * 42.0, -92.0), Vector2(float(sd) * 39.0, -105.0)], GOLD_DARK, true)
	# Head: skin, hair tufts, ears, beard, then the face and crown.
	var hy: float = -108.0
	var hw := 29.0
	var hh := 26.0
	Gear.ears(r, 0.0, hy + 4.0, hw, hh, skin, accent.lerp(skin, 0.5))
	for sd in [-1.0, 1.0]:
		r.poly([Vector2(float(sd) * 24.0, hy - 14.0), Vector2(float(sd) * 38.0, hy - 6.0), Vector2(float(sd) * 33.0, hy + 14.0), Vector2(float(sd) * 22.0, hy + 4.0)], Color("#D9D2EE"), true)
	r.ell(0.0, hy, hw * 0.9, hh * 0.95, skin, true)
	r.poly([
		Vector2(-26, hy + 2), Vector2(-25, hy + 16), Vector2(-17, hy + 32), Vector2(-7, hy + 38), Vector2(0, hy + 46), Vector2(7, hy + 38),
		Vector2(17, hy + 32), Vector2(25, hy + 16), Vector2(26, hy + 2), Vector2(20, hy + 12), Vector2(8, hy + 14), Vector2(0, hy + 11),
		Vector2(-8, hy + 14), Vector2(-20, hy + 12),
	], beard, true)
	var mood: int = Kit.Mood.GRUMP if r.mood == Kit.Mood.IDLE else r.mood
	Face.draw(r, 0.0, hy + 2.0, hw * 0.9, hh * 0.88, mood, {"skin": skin, "eye": accent.lerp(Color.WHITE, 0.15), "brow": Color("#E4DEF5"), "brow_w": 2.1, "nose": 1.5, "blush": 0.0, "fang": false})
	if mood == Kit.Mood.GRUMP:
		r.ell(-12.0, hy + 14.0, 2.4, 3.6, Color("#BFEFFF"), false, false)
	_crown(r, hy - hh * 0.78, accent, enraged)
	if enraged and not r.calm:
		for sd in [-1.0, 1.0]:
			var ph: float = fposmod(r.t * 0.03 + (0.5 if sd < 0.0 else 0.0), 1.0)
			r.disc(float(sd) * 34.0, hy - 6.0 - ph * 26.0, 5.0 * (1.0 - ph * 0.5), Color(1, 1, 1, 0.45 * (1.0 - ph)))
	return r.n


## Cracked lantern swinging from `hand`, glow flickering in `accent`.
static func _lantern(r: Kit.Rig, hand: Vector2, accent: Color) -> void:
	var sw: float = 0.0 if r.calm else sin(r.t * 0.08) * 2.0
	var top: Vector2 = hand + Vector2(sw * 0.3, 6.0)
	var c: Vector2 = top + Vector2(sw, 20.0)
	var fl: float = 1.0 if r.calm else 0.8 + 0.2 * sin(r.t * 0.31)
	r.line(top, c + Vector2(0, -9.0), 1.1, Color("#2A1B52"))
	r.disc(c.x, c.y, 20.0 * fl, Color(accent, 0.2))
	r.poly([c + Vector2(-8, -9), c + Vector2(8, -9), c + Vector2(10, 4), c + Vector2(5, 11), c + Vector2(-5, 11), c + Vector2(-10, 4)], Color("#FFE6A8"), true)
	r.disc(c.x, c.y + 1.0, 5.0 * fl, Color("#FFF7D6"))
	r.polyline([c + Vector2(-2, -9), c + Vector2(1, -3), c + Vector2(-3, 2), c + Vector2(2, 8), c + Vector2(0, 11)], 1.3, Kit.BLACKOUT)
	r.poly([c + Vector2(-9, -11), c + Vector2(9, -11), c + Vector2(6, -8), c + Vector2(-6, -8)], GOLD_DARK, true)


## Five-point gold crown whose base sits at local y = `base`; cracked when `enraged`.
static func _crown(r: Kit.Rig, base: float, accent: Color, enraged: bool) -> void:
	var tilt: float = 0.0 if r.calm else sin(r.t * 0.05) * 1.0
	r.poly([
		Vector2(-23 + tilt, base), Vector2(-25 + tilt, base - 22), Vector2(-14 + tilt, base - 11), Vector2(-8 + tilt, base - 28),
		Vector2(0 + tilt, base - 13), Vector2(8 + tilt, base - 28), Vector2(14 + tilt, base - 11), Vector2(25 + tilt, base - 22), Vector2(23 + tilt, base),
	], GOLD, true)
	r.poly([Vector2(-23 + tilt, base), Vector2(23 + tilt, base), Vector2(23 + tilt, base - 6), Vector2(-23 + tilt, base - 6)], GOLD_DARK, false)
	r.circ(0.0 + tilt, base - 3.0, 3.6, accent, true)
	for sd in [-1.0, 1.0]:
		r.circ(float(sd) * 16.0 + tilt, base - 3.0, 2.4, Color("#7FF3FF"), false)
		r.disc(float(sd) * 25.0 + tilt, base - 23.0, 2.6, Color.WHITE)
	if enraged:
		r.polyline([Vector2(4 + tilt, base - 14), Vector2(1 + tilt, base - 8), Vector2(5 + tilt, base - 2)], 1.5, Kit.BLACKOUT)
