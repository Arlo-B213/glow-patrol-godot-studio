extends RefCounted
## Clothing and head gear shared by the gloom characters (Story 031): hoods, horns, ears, spiky hair,
## tails, scarves, mushrooms, shell lumps and sleepy "Z"s. Every function takes a `Kit.Rig` and local
## units (see gloom_kit.gd); all polygons are simple.

const Kit := preload("res://scenes/battle/gloom_kit.gd")
const Shade := preload("res://scripts/hunter_shade.gd")


## A hood behind the head: a big rounded shape plus a darker inside, drawn BEFORE the head.
static func hood_back(r: Kit.Rig, cx: float, cy: float, hw: float, hh: float, col: Color) -> void:
	r.ell(cx - hw * 0.05, cy - hh * 0.1, hw * 1.2, hh * 1.18, col, true)


## The hood's front rim over the forehead and cheeks, drawn AFTER the head and before the face.
static func hood_rim(r: Kit.Rig, cx: float, cy: float, hw: float, hh: float, col: Color) -> void:
	r.ci.draw_arc(r.p(cx, cy), hw * 1.06 * r.k, PI * 1.03, PI * 1.97, 16, r.c(Shade.darken(col, 0.15)), hh * 0.34 * r.k, true)
	r.ci.draw_arc(r.p(cx, cy), hw * 1.2 * r.k, PI * 1.03, PI * 1.97, 10, r.ink(col), r.ow, r.detail)
	r.n += 2
	if r.detail:
		r.ci.draw_arc(r.p(cx, cy), hw * 0.95 * r.k, PI * 1.12, PI * 1.5, 8, r.c(Shade.fade(Shade.lighten(col, 0.4), 0.6)), maxf(1.0, hh * 0.08 * r.k), true)
		r.n += 1


## Two curved horns poking up from the top of the head with glowing tips.
static func horns(r: Kit.Rig, cx: float, cy: float, hw: float, hh: float, len: float, col: Color, tip: Color) -> void:
	for side in [-1.0, 1.0]:
		var sd: float = side
		var bx: float = cx + sd * hw * 0.55
		var by: float = cy - hh * 0.8
		r.poly([Vector2(bx - sd * hw * 0.28, by + hh * 0.1), Vector2(bx + sd * hw * 0.3, by + hh * 0.05), Vector2(bx + sd * hw * 0.55, by - len * 0.5), Vector2(bx + sd * hw * 0.42, by - len)], col, true)
		r.disc(bx + sd * hw * 0.42, by - len * 0.92, hw * 0.1, tip)


## Pointy elf-like ears sticking out sideways at head height.
static func ears(r: Kit.Rig, cx: float, cy: float, hw: float, hh: float, col: Color, inner: Color) -> void:
	for side in [-1.0, 1.0]:
		var sd: float = side
		var bx: float = cx + sd * hw * 0.92
		r.poly([Vector2(bx, cy - hh * 0.3), Vector2(bx + sd * hw * 0.6, cy - hh * 0.75), Vector2(bx + sd * hw * 0.05, cy + hh * 0.15)], col, true)
		if r.detail:
			r.poly([Vector2(bx + sd * hw * 0.1, cy - hh * 0.22), Vector2(bx + sd * hw * 0.42, cy - hh * 0.55), Vector2(bx + sd * hw * 0.08, cy + hh * 0.02)], inner, false)


## A spiky hair fringe across the top of the head; `n` spikes, `len` tall, wobble when moving.
static func spikes(r: Kit.Rig, cx: float, cy: float, hw: float, hh: float, n: int, len: float, col: Color) -> void:
	var pts: Array = [Vector2(cx - hw * 0.95, cy - hh * 0.35)]
	for i in n:
		var f0: float = float(i) / float(n)
		var f1: float = (float(i) + 1.0) / float(n)
		var wob: float = 0.0 if r.calm else sin(r.t * 0.12 + float(i) * 1.7) * len * 0.07
		var lh: float = len * (1.0 if i % 2 == 0 else 0.72)
		pts.append(Vector2(cx - hw * 0.95 + 1.9 * hw * (f0 + f1) * 0.5 + wob, cy - hh * 0.85 - lh))
		pts.append(Vector2(cx - hw * 0.95 + 1.9 * hw * f1, cy - hh * 0.62))
	pts.append(Vector2(cx + hw * 0.95, cy - hh * 0.35))
	r.poly(pts, col, true)


## A swishing tail with a spade tip, drawn BEHIND the body from local (x, y).
static func tail(r: Kit.Rig, x: float, y: float, len: float, col: Color, tip: Color) -> void:
	var pts: Array = []
	var wag: float = 0.0 if r.calm else sin(r.t * 0.2)
	for i in 6:
		var f: float = float(i) / 5.0
		pts.append(Vector2(x - f * len * 0.8, y - sin(f * 2.4 + wag) * len * 0.3 - f * len * 0.25))
	if r.detail:
		r.polyline(pts, 4.5, Shade.ink(col))
	r.polyline(pts, 3.0, col)
	var e: Vector2 = pts[5]
	r.poly([e + Vector2(-2.0, -1.0), e + Vector2(5.0, -6.0), e + Vector2(7.0, 3.0), e + Vector2(0.0, 4.0)], tip, true)


## A scarf wrapped at the neck with a tail streaming behind (flutters when moving).
static func scarf(r: Kit.Rig, cx: float, cy: float, hw: float, col: Color, trail: float) -> void:
	var fl: float = 0.0 if r.calm else sin(r.t * 0.25) * 3.0
	r.poly([Vector2(cx - hw, cy - 3.0), Vector2(cx + hw, cy - 3.0), Vector2(cx + hw * 0.85, cy + 5.0), Vector2(cx - hw * 0.85, cy + 5.0)], col, true)
	r.poly([Vector2(cx - hw * 0.8, cy), Vector2(cx - hw * 0.8 - trail, cy + 2.0 + fl), Vector2(cx - hw * 0.8 - trail * 1.1, cy + 8.0 + fl), Vector2(cx - hw * 0.6, cy + 6.0)], Shade.darken(col, 0.2), true)


## A glowing mushroom with a spotted cap, `size` local units across.
static func mushroom(r: Kit.Rig, x: float, y: float, size: float, cap: Color) -> void:
	var sway: float = 0.0 if r.calm else sin(r.t * 0.1 + x) * size * 0.08
	r.line(Vector2(x, y), Vector2(x + sway, y - size * 0.7), size * 0.28, Color("#F6EBD9"))
	var top := Vector2(x + sway, y - size * 0.75)
	r.disc(top.x, top.y, size * 0.8, Color(cap, 0.18))
	r.ell(top.x, top.y, size * 0.55, size * 0.34, cap, true)
	r.disc(top.x - size * 0.2, top.y - size * 0.06, size * 0.08, Color.WHITE)
	r.disc(top.x + size * 0.18, top.y + size * 0.02, size * 0.07, Color.WHITE)


## A little "Z" for a sleeping head; `phase` 0..1 floats it up and fades it.
static func zzz(r: Kit.Rig, x: float, y: float, size: float, phase: float) -> void:
	var a: float = 1.0 - phase
	var o := Vector2(x + phase * size, y - phase * size * 2.0)
	r.polyline([o + Vector2(-size, -size), o + Vector2(size, -size), o + Vector2(-size, size), o + Vector2(size, size)], 1.8, Color(0.9, 0.9, 1.0, a))


## Glow-in-the-dark trim line (zip, stripe, belt) in the enemy colour.
static func trim(r: Kit.Rig, a: Vector2, b: Vector2, wid: float) -> void:
	if r.detail:
		r.line(a, b, wid * 2.2, Color(r.glow, 0.3))
	r.line(a, b, wid, Shade.lighten(r.glow, 0.3))
