extends RefCounted
## The Hiccup Hydra (Story 031): three humanoid kid heads and torsos fused into one fluffy teal body,
## each with its own personality: an angry spiky-haired one, a sleepy one in a nightcap and a giggly
## one with pigtails. Every ~2.5 s one head sneezes sparkles (purely visual) and the body hiccups.
## Extras via `fx`: hpf (health fraction, <= 0.34 wakes the sleepy head up), plus flash/stun/dying.

const Kit := preload("res://scenes/battle/gloom_kit.gd")
const Face := preload("res://scenes/battle/gloom_face.gd")
const Gear := preload("res://scenes/battle/gloom_gear.gd")
const Shade := preload("res://scripts/hunter_shade.gd")
const SNEEZE_CYCLE := 150
const SNEEZE_LEN := 26
const INTRO_FRAMES := 60
const SKIN := Color("#FFC7D6")
const BODY := Color("#2FC6A8")
const FLUFF := Color("#7FF0D4")
const UNITS := [
	{"x": -40.0, "hy": -100.0, "hw": 21.0, "tw": 14.0, "shirt": Color("#E8742F"), "hair": Color("#FF6A3C"), "eye": Color("#FFB347"), "mood": 1},
	{"x": 0.0, "hy": -124.0, "hw": 25.0, "tw": 18.0, "shirt": Color("#7C6AE8"), "hair": Color("#C9B8FF"), "eye": Color("#C9A8FF"), "mood": 6},
	{"x": 40.0, "hy": -100.0, "hw": 21.0, "tw": 14.0, "shirt": Color("#E85BA0"), "hair": Color("#FF5FA2"), "eye": Color("#FF9EC8"), "mood": 7},
]


## 0..1 progress of the current sneeze (0 = not sneezing), from the boss age.
static func sneeze_progress(age: int) -> float:
	var ph: int = age % SNEEZE_CYCLE
	var start: int = SNEEZE_CYCLE - SNEEZE_LEN
	return 0.0 if ph < start else float(ph - start + 1) / float(SNEEZE_LEN)


## Draws the Hydra standing on `ground_y` with size `s`; returns the draw-call count.
static func draw(ci: CanvasItem, x: float, ground_y: float, s: float, age: int, toward: float, u: float, fx: Dictionary = {}) -> int:
	var hpf: float = float(fx.get("hpf", 1.0))
	var r: Kit.Rig = Kit.make_rig(ci, x, ground_y, s * 0.92, Color("#7FF0D4"), age, toward, u, fx)
	var intro: bool = age < INTRO_FRAMES and not r.calm
	var sneeze: float = 0.0 if r.calm else sneeze_progress(age)
	var sneezer: int = (age / SNEEZE_CYCLE) % 3
	var hic: float = 0.0 if r.calm else pow(maxf(0.0, sin(r.t * 0.09 + 1.0)), 8.0)
	Kit.aura(r, -62.0, 92.0, 0.15)
	Kit.floor_shadow(r, 56.0)
	Kit.legs(r, -22.0, 25.0, 22.0, BODY.lerp(Color("#103A33"), 0.3), Color("#146354"), 18.0, 8.0, 4.0, 3.0)
	r.o.y -= (absf(sin(r.t * 0.1)) * 2.5 + hic * 4.0 + r.breath * 1.5) * r.ky
	r.o.x += (r.near * 3.0 + r.strike * 6.0 - r.flash * 5.0) * r.dir * r.kx
	# Torsos: sides first, the big middle one last so it overlaps them.
	for i in [0, 2, 1]:
		var d: Dictionary = UNITS[i]
		var hx: float = float(d["x"])
		var tw: float = float(d["tw"])
		var shirt: Color = d["shirt"]
		r.poly([Vector2(hx - tw, float(d["hy"]) + 20.0), Vector2(hx + tw, float(d["hy"]) + 20.0), Vector2(hx + tw * 1.15, -46.0), Vector2(hx - tw * 1.15, -46.0)], shirt)
		Gear.trim(r, Vector2(hx, float(d["hy"]) + 24.0), Vector2(hx, -52.0), 1.0)
	# Fluffy shared body over the torso bottoms.
	for k in 6:
		var a: float = TAU * float(k) / 6.0 + 0.2
		var bump: float = 1.0 + (0.0 if r.calm else sin(r.t * 0.05 + float(k) * 1.7) * 0.04)
		r.circ(cos(a) * 52.0, -38.0 + sin(a) * 26.0, 12.0 * bump, FLUFF, false)
	r.ell(0.0, -38.0, 52.0, 28.0, BODY, true)
	r.ell(0.0, -30.0, 32.0, 17.0, BODY.lightened(0.18), false, false)
	# Arms: side units wave outward, the middle one holds both up; cheering in the intro.
	var arms: Array = [[-1.0, -40.0, 0.7], [1.0, 40.0, 0.7], [-1.0, -14.0, 0.3], [1.0, 14.0, 0.3]]
	for ai in arms.size():
		var ar: Array = arms[ai]
		var side: float = float(ar[0])
		var base_r: float = float(ar[2]) + Kit.swing(r, side, 0.2) * (1.0 if ai < 2 else 0.5)
		if intro:
			base_r = lerpf(2.6, base_r, pow(clampf(float(age) / float(INTRO_FRAMES), 0.0, 1.0), 2.0))
		var shirt2: Color = UNITS[0 if ai % 2 == 0 and ai < 2 else (2 if ai == 1 else 1)]["shirt"]
		Kit.arm(r, side, Vector2(float(ar[1]) + side * (14.0 if ai < 2 else 4.0), -78.0 if ai < 2 else -92.0), 24.0, 9.0, shirt2, SKIN, base_r, 6.0)
	# Heads, sides first.
	for i in [0, 2, 1]:
		_head(r, i, sneezer, sneeze, hpf, toward)
	if sneeze > 0.0:
		_sparkles(r, sneezer, s, sneeze)
	return r.n


static func _head(r: Kit.Rig, i: int, sneezer: int, sneeze: float, hpf: float, toward: float) -> void:
	var d: Dictionary = UNITS[i]
	var hw: float = float(d["hw"])
	var hh: float = hw * 0.92
	var hair: Color = d["hair"]
	var wob: float = 0.0 if r.calm else sin(r.t * 0.07 + float(i) * 2.1)
	var hx: float = float(d["x"]) + wob * 1.5
	var hy: float = float(d["hy"]) + (absf(wob) * 0.8 if i == 1 else 0.0)
	var is_sneezer: bool = i == sneezer and sneeze > 0.0
	var mood: int = int(d["mood"])
	var lid_force: float = 0.0
	var forced: bool = r.mood in [Kit.Mood.HURT, Kit.Mood.STUNNED, Kit.Mood.DYING, Kit.Mood.SMILE]
	if forced:
		mood = r.mood
	elif is_sneezer:
		mood = Kit.Mood.SNEEZE
		var back: float = sin(sneeze * PI)
		hy -= back * 5.0 if sneeze < 0.5 else -back * 4.0
		hx += (-back * 3.0 if sneeze < 0.5 else back * 6.0) * 1.0
	elif i == 1 and hpf <= 0.34:
		mood = Kit.Mood.ANGRY
	elif r.near > 0.45 and i != 1:
		mood = Kit.Mood.ANGRY
	var spec := {"skin": SKIN, "eye": d["eye"], "brow": Shade.darken(hair, 0.35), "eye_scale": 1.05, "fang": i == 0, "lid": lid_force}
	if i == 0:
		Gear.spikes(r, hx, hy, hw, hh, 5, 16.0, hair)
	elif i == 2:
		for sd in [-1.0, 1.0]:
			var px: float = hx + float(sd) * hw * 1.0
			var sway: float = 0.0 if r.calm else sin(r.t * 0.12 + float(sd)) * 3.0
			r.ell(px + float(sd) * 4.0 + sway, hy + hh * 0.5, 7.0, 13.0, hair, true)
			r.circ(px, hy + hh * 0.05, 3.0, Color("#FFD36E"), true)
	r.ell(hx, hy, hw, hh, SKIN, i == 1)
	if i == 1:
		var tip: float = 0.0 if r.calm else sin(r.t * 0.06) * 5.0
		r.poly([Vector2(hx - hw * 1.02, hy - hh * 0.3), Vector2(hx + hw * 1.02, hy - hh * 0.3), Vector2(hx + hw * 0.7, hy - hh * 0.95), Vector2(hx + hw * 0.1 + tip, hy - hh * 1.5), Vector2(hx - hw * 0.5, hy - hh * 1.0)], hair, true)
		r.circ(hx + hw * 0.1 + tip, hy - hh * 1.55, 5.0, Color.WHITE, true)
		r.poly([Vector2(hx - hw * 1.05, hy - hh * 0.38), Vector2(hx + hw * 1.05, hy - hh * 0.38), Vector2(hx + hw * 1.0, hy - hh * 0.2), Vector2(hx - hw * 1.0, hy - hh * 0.2)], Color("#FFFFFF"), true)
		if mood == Kit.Mood.SLEEPY and not r.calm:
			Gear.zzz(r, hx + hw * 1.1, hy - hh * 0.6, 3.5, fposmod(r.t * 0.012, 1.0))
	Face.draw(r, hx, hy + 2.0, hw, hh * 0.95, mood, spec)
	if i == 0 and mood == Kit.Mood.ANGRY and not r.calm and hpf <= 0.5:
		var ph: float = fposmod(r.t * 0.03, 1.0)
		r.disc(hx + hw * 1.05, hy - hh * 0.2 - ph * 14.0, 4.0 * (1.0 - ph * 0.5), Color(1, 1, 1, 0.5 * (1.0 - ph)))
	if toward == 0.0:
		return


## 4-point sparkle star (8 vertices, simple).
static func _star(c: Vector2, rad: float, rot: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(8):
		var a: float = rot + TAU * float(i) / 8.0
		var rr: float = rad if i % 2 == 0 else rad * 0.38
		pts.append(c + Vector2(cos(a) * rr, sin(a) * rr))
	return pts


static func _sparkles(r: Kit.Rig, sneezer: int, s: float, p: float) -> void:
	var d: Dictionary = UNITS[sneezer]
	var from: Vector2 = r.p(float(d["x"]) + 12.0, float(d["hy"]) + 16.0)
	var cols := [Color("#FFD36E"), Color("#FF5FA2"), Color("#7FF0D4"), Color.WHITE]
	for k in range(9):
		var a: float = (float(k) / 8.0 - 0.5) * 1.5 + (0.45 if r.dir > 0.0 else PI - 0.45)
		var dist: float = s * (0.15 + p * (0.5 + 0.09 * float(k % 3)))
		var pos: Vector2 = from + Vector2(cos(a) * dist, sin(a) * dist * 0.7 + p * p * s * 0.12)
		var col: Color = cols[k % 4]
		col.a = 1.0 - p * 0.7
		r.ci.draw_colored_polygon(_star(pos, s * (0.05 + 0.015 * float(k % 2)) * (1.2 - p * 0.5), p * 3.0 + float(k)), col)
		r.n += 1
