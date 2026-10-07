class_name PetArt
extends RefCounted
## Code-drawn pets (Story 024, upgraded in Story 033): shared drawing context, cel-shading
## helpers, aura and shadow. Species bodies live in pet_art_<species>.gd, faces in
## pet_art_face.gd, eggs in pet_art_egg.gd, accessories in pet_art_acc.gd and effects in
## pet_art_fx.gd. Everything is authored in a 100x100 design box whose ground line is
## y = 92; `draw()` fits that box into any rect.
##
## Drawing language: dark-tinted outlines (thicker underneath), 3-tone cel shading
## (shadow / base / highlight), an accent rim light, a soft aura. Every polygon is SIMPLE
## (ellipses, capsules, star-convex shapes) so triangulation never silently fails.

const Shade := preload("res://scripts/hunter_shade.gd")
const Species := preload("res://scripts/pet_art_species.gd")
const Egg := preload("res://scripts/pet_art_egg.gd")
const Acc := preload("res://scripts/pet_art_acc.gd")
const Fx := preload("res://scripts/pet_art_fx.gd")

const MOOD_NORMAL := 0
const MOOD_HAPPY := 1
const MOOD_SLEEPY := 2
const MOOD_EATING := 3
const MOOD_EXCITED := 4
const MOOD_SHY := 5
const MOOD_SURPRISED := 6
## Body scale per stage [egg, baby, child, adult].
const STAGE_SCALE := [1.12, 0.72, 0.86, 0.94]
const GROUND_Y := 92.0
## One-shot reaction lengths in seconds (PetView plays them, PetArt draws them).
const REACT_LEN := {"eat": 1.7, "pet": 1.9, "grow": 2.3, "hop": 0.6, "spin": 0.9, "attack": 0.35}


## Draws a pet of `species` at `stage` (0 egg .. 3 adult) filling `rect`.
## `t` is seconds of animation time, `animate` false gives a still pose (reduce motion),
## `mood` is MOOD_*, `bounce` 0..1 is the progress of a one-shot hop, `flip` -1 mirrors it.
## `extra` (all optional): "acc" accessory id ("" = none; absent = the owned pet's equipped
## one), "react" ("eat", "pet", "grow", "hop", "spin", "attack") with "rt" seconds elapsed,
## "look" Vector2 eye direction, "prog" 0..1 hatch progress (egg cracks), "ready" bool.
static func draw(ci: CanvasItem, species: String, stage: int, rect: Rect2, t: float,
		animate: bool, mood: int = MOOD_NORMAL, bounce: float = 0.0, flip: float = 1.0,
		extra: Dictionary = {}) -> void:
	var s: float = minf(rect.size.x, rect.size.y) / 100.0
	if s <= 0.0:
		return
	var fl: float = flip if absf(flip) > 0.01 else 1.0
	var react: String = str(extra.get("react", "")) if animate else ""
	var rt: float = float(extra.get("rt", 0.0))
	var xs := 1.0
	if react == "spin":
		var cs := cos(clampf(rt / 0.9, 0.0, 1.0) * TAU)
		xs = cs if absf(cs) > 0.14 else (0.14 if cs >= 0.0 else -0.14)
	var def := _def(species)
	var c := rect.get_center()
	ci.draw_set_transform(Vector2(c.x - 50.0 * s * fl * xs, c.y - 50.0 * s), 0.0, Vector2(s * fl * xs, s))
	var tt: float = t if animate else 0.0
	stage = clampi(stage, 0, 3)
	var md := mood
	match react:
		"eat": md = MOOD_EATING
		"pet": md = MOOD_HAPPY
		"grow", "spin", "attack": md = MOOD_EXCITED
		"hop":
			if md == MOOD_NORMAL:
				md = MOOD_HAPPY
	var look: Vector2 = extra.get("look", Vector2.ZERO)
	if animate:
		look += Vector2(sin(tt * 0.7) * 0.3, sin(tt * 0.5) * 0.12)
	var b: float = clampf(bounce, 0.0, 1.0)
	var hop: float = sin(b * PI)
	var vel: float = cos(b * PI) if (b > 0.0 and b < 1.0) else 0.0
	var p := {
		"k": float(STAGE_SCALE[stage]), "stage": stage, "t": tt, "anim": animate, "mood": md,
		"col": def.get("color", Color("#FFC2B8")), "accent": def.get("accent", Color("#FF6FA8")),
		"blink": animate and (fmod(tt, 3.6) < 0.14 or fmod(tt + 1.7, 5.3) < 0.12), "rot": 0.0,
		"sy": 1.0, "lift": hop * 12.0, "vel": vel, "look": look, "react": react, "rt": rt,
		"wag": sin(tt * 3.2) * 0.5 if animate else 0.0, "o": Vector2(50.0, GROUND_Y),
		"prog": float(extra.get("prog", 0.0)),
	}
	var sy := 1.0
	if animate:
		sy += sin(tt * 2.2) * 0.02
	sy = (sy + 0.06 * vel) * (1.0 - 0.04 * hop)
	p["sy"] = sy
	if react == "pet":
		p["rot"] = sin(tt * 55.0) * 0.012
	elif react == "attack":
		p["rot"] = sin(clampf(rt / 0.35, 0.0, 1.0) * PI) * 0.2
	_default_anchors(p)
	_aura(ci, p)
	_shadow(ci, p)
	if stage == 0:
		Egg.draw(ci, species, p)
	else:
		Species.draw_species(ci, species, p)
		var acc: String = str(extra["acc"]) if extra.has("acc") else _equipped(species)
		if acc != "":
			p["acc_col"] = _acc_color(acc)
			Acc.draw(ci, p, acc)
	Fx.mood(ci, p)
	if react != "":
		Fx.react(ci, p)
	if bool(extra.get("ready", false)) and animate:
		Fx.ready(ci, p)
	ci.draw_set_transform_matrix(Transform2D.IDENTITY)


static func _def(species: String) -> Dictionary:
	var gs := _gs()
	if gs != null:
		return gs.pet_def(species)
	return {}


static func _gs() -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree:
		return (loop as SceneTree).root.get_node_or_null("GameState")
	return null


static func _equipped(species: String) -> String:
	var gs := _gs()
	if gs == null:
		return ""
	var owned: Dictionary = gs.get("owned_pets")
	if owned.has(species):
		return str((owned[species] as Dictionary).get("acc", ""))
	return ""


static func _acc_color(id: String) -> Color:
	var gs := _gs()
	if gs != null:
		return gs.accessory_def(id).get("color", Color("#FFD36E"))
	return Color("#FFD36E")


static func _default_anchors(p: Dictionary) -> void:
	set_head(p, 0.0, -44.0, 24.0, 19.0)
	p["a_eye"] = Vector2(0.0, -46.0)
	p["a_eyedx"] = 11.0
	p["a_eyer"] = 5.0
	p["a_neck"] = Vector2(0.0, -28.0)
	p["a_nw"] = 14.0
	p["a_mouth"] = Vector2(0.0, -38.0)


## Records the head ellipse (pet space) that accessories and effects attach to.
static func set_head(p: Dictionary, cx: float, cy: float, rx: float, ry: float) -> void:
	p["a_hc"] = Vector2(cx, cy)
	p["a_hrx"] = rx
	p["a_hry"] = ry
	p["a_head"] = Vector2(cx, cy - ry)


# ---------------------------------------------------------------- transforms and shapes

## Pet-space (ground centre = 0,0; y up is negative) to design-box point.
static func q(p: Dictionary, x: float, y: float) -> Vector2:
	var v := Vector2(x, y * float(p["sy"]))
	var r: float = p["rot"]
	if r != 0.0:
		v = v.rotated(r)
	return (p["o"] as Vector2) + v * float(p["k"]) + Vector2(0.0, -float(p["lift"]))


## Ellipse polygon in pet space, optionally rotated by `rot` around its own centre.
static func ell(p: Dictionary, cx: float, cy: float, rx: float, ry: float, rot: float = 0.0,
		n: int = 22) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n:
		var a := TAU * float(i) / float(n)
		var v := Vector2(cos(a) * rx, sin(a) * ry).rotated(rot)
		out.append(q(p, cx + v.x, cy + v.y))
	return out


## Pet-space point list to a design-box polygon.
static func poly(p: Dictionary, pts: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for v in pts:
		out.append(q(p, (v as Vector2).x, (v as Vector2).y))
	return out


## Line width that stays sensible across stage scales.
static func lw(p: Dictionary, w: float) -> float:
	return w * (0.55 + 0.45 * float(p["k"]))


# ---------------------------------------------------------------- tones

## Dark, violet-tinted outline colour for a fill.
static func ol_of(c: Color) -> Color:
	return Color(c.r * 0.28 + 0.07, c.g * 0.18 + 0.03, c.b * 0.34 + 0.15, 0.96)


## Shadow tone (cool violet shift).
static func shade_of(c: Color) -> Color:
	return Color(c.r * 0.72 + 0.04, c.g * 0.6 + 0.02, c.b * 0.82 + 0.1, c.a)


## Highlight tone (warm).
static func light_of(c: Color) -> Color:
	return c.lerp(Color(1.0, 0.97, 0.9, c.a), 0.45)


static func rim_of(p: Dictionary) -> Color:
	return Shade.fade(Shade.lighten(p["accent"], 0.55), 0.8)


# ---------------------------------------------------------------- cel-shaded primitives

## Outlined 3-tone ellipse: shadow base, lit mid tone shifted up-left, highlight, rim light.
static func cel(ci: CanvasItem, p: Dictionary, cx: float, cy: float, rx: float, ry: float,
		col: Color, rot: float = 0.0, n: int = 24, rim: bool = true) -> void:
	var outer := ell(p, cx, cy, rx, ry, rot, n)
	ci.draw_colored_polygon(outer, shade_of(col))
	ci.draw_colored_polygon(ell(p, cx - rx * 0.07, cy - ry * 0.1, rx * 0.9, ry * 0.88, rot, n), col)
	ci.draw_colored_polygon(ell(p, cx - rx * 0.22, cy - ry * 0.46, rx * 0.4, ry * 0.15, rot - 0.25, 12),
		Shade.fade(light_of(col), 0.75))
	_outline(ci, p, outer, col, rim, n)


static func _outline(ci: CanvasItem, p: Dictionary, outer: PackedVector2Array, col: Color,
		rim: bool, n: int) -> void:
	var ol := ol_of(col)
	var closed := PackedVector2Array(outer)
	closed.append(outer[0])
	ci.draw_polyline(closed, ol, lw(p, 1.2), true)
	var low := PackedVector2Array()
	for i in range(int(n * 0.06), int(n * 0.46) + 1):
		low.append(outer[i % n])
	if low.size() > 1:
		ci.draw_polyline(low, ol, lw(p, 2.5), true)
	if rim:
		var rl := PackedVector2Array()
		var cen := Vector2.ZERO
		for v in outer:
			cen += v
		cen /= float(n)
		for i in range(int(n * 0.03), int(n * 0.3) + 1):
			rl.append(cen + (outer[i % n] - cen) * 0.93)
		if rl.size() > 1:
			ci.draw_polyline(rl, rim_of(p), lw(p, 1.3), true)


## Outlined 3-tone polygon given in pet space (must be simple and star-shaped around its centroid).
static func cel_poly(ci: CanvasItem, p: Dictionary, pts: Array, col: Color, rim: bool = false) -> void:
	var cen := Vector2.ZERO
	for v in pts:
		cen += v
	cen /= float(pts.size())
	var inner: Array = []
	for v in pts:
		inner.append(cen + ((v as Vector2) - cen) * 0.78 + Vector2(-0.9, -1.3))
	var outer := poly(p, pts)
	ci.draw_colored_polygon(outer, shade_of(col))
	ci.draw_colored_polygon(poly(p, inner), col)
	var closed := PackedVector2Array(outer)
	closed.append(outer[0])
	ci.draw_polyline(closed, ol_of(col), lw(p, 1.4), true)
	if rim and outer.size() > 2:
		ci.draw_polyline(PackedVector2Array([outer[1], outer[2]]), rim_of(p), lw(p, 1.2), true)


## Tapered capsule polygon in design-box space (convex).
static func taper_poly(a: Vector2, b: Vector2, r0: float, r1: float, seg: int = 6) -> PackedVector2Array:
	var d: float = (b - a).angle() if a != b else 0.0
	if a.distance_to(b) < absf(r0 - r1) * 1.05:
		r1 = r0
	var pts := PackedVector2Array()
	for i in seg + 1:
		var an: float = d - PI * 0.5 + PI * float(i) / float(seg)
		pts.append(b + Vector2(cos(an), sin(an)) * r1)
	for i in seg + 1:
		var an: float = d + PI * 0.5 + PI * float(i) / float(seg)
		pts.append(a + Vector2(cos(an), sin(an)) * r0)
	return pts


## Outlined tapered limb between two pet-space points (radii in pet units), 3-tone.
static func tube(ci: CanvasItem, p: Dictionary, a: Vector2, b: Vector2, r0: float, r1: float,
		col: Color) -> void:
	var k: float = p["k"]
	var qa := q(p, a.x, a.y)
	var qb := q(p, b.x, b.y)
	var ow := lw(p, 1.1)
	ci.draw_colored_polygon(taper_poly(qa, qb, r0 * k + ow, r1 * k + ow), ol_of(col))
	ci.draw_colored_polygon(taper_poly(qa, qb, r0 * k, r1 * k), shade_of(col))
	var sh := Vector2(-0.2, -0.28) * minf(r0, r1) * k
	ci.draw_colored_polygon(taper_poly(qa + sh, qb + sh, r0 * k * 0.8, r1 * k * 0.78), col)


## A chain of tapered segments that curls and lags behind the body (tails, gills, ears,
## antennae). `sway` is the swing amplitude in radians, `lag` the phase delay per segment.
## Returns the pet-space joint points (n + 1 of them). `radii` holds n + 1 radii.
static func chain(ci: CanvasItem, p: Dictionary, base: Vector2, ang: float, seg_len: float,
		radii: Array, col: Color, sway: float, lag: float, curl: float = 0.0, speed: float = 3.0,
		col_end: Color = Color(0, 0, 0, 0)) -> Array[Vector2]:
	var n: int = radii.size() - 1
	var t: float = p["t"]
	var pts: Array[Vector2] = [base]
	var a := ang
	for i in n:
		var sw := 0.0
		if bool(p["anim"]):
			sw = sin(t * speed - lag * float(i + 1)) * sway * float(i + 1) / float(n)
		a += curl + sw * 0.9 + float(p["vel"]) * -0.05 * float(i + 1)
		pts.append(pts[i] + Vector2(cos(a), sin(a)) * seg_len)
	var k: float = p["k"]
	var ow := lw(p, 1.1)
	for i in n:
		ci.draw_colored_polygon(taper_poly(q(p, pts[i].x, pts[i].y), q(p, pts[i + 1].x, pts[i + 1].y),
			float(radii[i]) * k + ow, float(radii[i + 1]) * k + ow), ol_of(col))
	for i in n:
		var c2 := col
		if col_end.a > 0.0:
			c2 = col.lerp(col_end, float(i) / float(maxi(1, n - 1)))
		var qa := q(p, pts[i].x, pts[i].y)
		var qb := q(p, pts[i + 1].x, pts[i + 1].y)
		ci.draw_colored_polygon(taper_poly(qa, qb, float(radii[i]) * k, float(radii[i + 1]) * k), shade_of(c2))
		var sh := Vector2(-0.2, -0.3) * float(radii[i]) * k
		ci.draw_colored_polygon(taper_poly(qa + sh, qb + sh, float(radii[i]) * k * 0.78,
			float(radii[i + 1]) * k * 0.74), c2)
	return pts


## Short fur/feather strands: `count` lines from `from` along `dir`, fanned by `spread`.
static func strands(ci: CanvasItem, p: Dictionary, from: Vector2, dir: Vector2, count: int,
		length: float, spread: float, col: Color, width: float = 0.9) -> void:
	for i in count:
		var f := (float(i) / float(maxi(1, count - 1)) - 0.5) * spread
		var d := dir.rotated(f)
		var a := q(p, from.x, from.y) + Vector2(f * 6.0, 0.0) * float(p["k"])
		ci.draw_line(a, a + d * length * float(p["k"]), col, lw(p, width), true)


## Speckle dots (pet-space positions) in a colour.
static func speckles(ci: CanvasItem, p: Dictionary, pts: Array, r: float, col: Color) -> void:
	for v in pts:
		ci.draw_circle(q(p, (v as Vector2).x, (v as Vector2).y), r * float(p["k"]), col)


## Soft glow dot (halo + core + white centre) at a pet-space point.
static func glow(ci: CanvasItem, p: Dictionary, x: float, y: float, r: float, col: Color) -> void:
	var c := q(p, x, y)
	var k: float = p["k"]
	var pulse: float = 1.0 + (sin(float(p["t"]) * 4.0 + x) * 0.1 if p["anim"] else 0.0)
	ci.draw_circle(c, r * k * 2.4 * pulse, Shade.fade(col, 0.16))
	ci.draw_circle(c, r * k * 1.6 * pulse, Shade.fade(col, 0.32))
	ci.draw_circle(c, r * k, Shade.lighten(col, 0.4))
	ci.draw_circle(c, r * k * 0.45, Color(1.0, 1.0, 1.0, 0.9))


## Four-point sparkle star at a design-box point.
static func star4(ci: CanvasItem, c: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 8:
		var an := -PI * 0.5 + TAU * float(i) / 8.0
		var rr := r if i % 2 == 0 else r * 0.3
		pts.append(c + Vector2(cos(an), sin(an)) * rr)
	ci.draw_colored_polygon(pts, col)


## Heart at a design-box point (`sz` is half-width).
static func heart(ci: CanvasItem, c: Vector2, sz: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * float(i) / 20.0
		var x := 16.0 * pow(sin(a), 3.0)
		var y := -(13.0 * cos(a) - 5.0 * cos(2.0 * a) - 2.0 * cos(3.0 * a) - cos(4.0 * a))
		pts.append(c + Vector2(x, y) * sz / 16.0)
	ci.draw_colored_polygon(pts, col)


# ---------------------------------------------------------------- ambience

static func _shadow(ci: CanvasItem, p: Dictionary) -> void:
	var k: float = p["k"]
	var squish: float = 1.0 - float(p["lift"]) * 0.014
	var c: Vector2 = (p["o"] as Vector2) + Vector2(0.0, 2.0)
	for pair in [[1.0, 0.16], [0.78, 0.18], [0.55, 0.2]]:
		var pts := PackedVector2Array()
		for i in 20:
			var a := TAU * float(i) / 20.0
			pts.append(c + Vector2(cos(a) * 32.0 * k * squish * float(pair[0]), sin(a) * 5.5 * k * float(pair[0])))
		ci.draw_colored_polygon(pts, Color(0.05, 0.0, 0.15, float(pair[1])))


static func _aura(ci: CanvasItem, p: Dictionary) -> void:
	var stage: int = p["stage"]
	var acc: Color = p["accent"]
	var k: float = p["k"]
	var pulse: float = 1.0 + (sin(float(p["t"]) * 1.6) * 0.05 if p["anim"] else 0.0)
	var base: float = [26.0, 24.0, 30.0, 38.0][stage]
	var c: Vector2 = (p["o"] as Vector2) + Vector2(0.0, -34.0 * k - float(p["lift"]))
	for i in 4:
		var f := float(i) / 3.0
		ci.draw_circle(c, (base + 20.0 * (1.0 - f)) * k * pulse * 1.05, Shade.fade(acc, 0.045 + 0.025 * f))
