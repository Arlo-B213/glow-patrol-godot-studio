class_name PetArt
extends RefCounted
## Code-drawn pets (Story 024): shared drawing context, eggs, faces and mood effects.
## Species bodies live in pet_art_species.gd. Everything is authored in a 100x100 design
## box whose ground line is y = 92; `draw()` fits that box into any rect.
##
## Every polygon is SIMPLE (ellipses, capsules, triangles, star-convex shapes) so Godot's
## triangulation never silently fails.

const Shade := preload("res://scripts/hunter_shade.gd")
const Species := preload("res://scripts/pet_art_species.gd")

const MOOD_NORMAL := 0
const MOOD_HAPPY := 1
const MOOD_SLEEPY := 2
## Body scale per stage [egg, baby, child, adult].
const STAGE_SCALE := [1.15, 0.62, 0.82, 1.0]
const GROUND_Y := 92.0


## Draws a pet of `species` at `stage` (0 egg .. 3 adult) filling `rect`.
## `t` is seconds of animation time, `animate` false gives a still pose (reduce motion),
## `mood` is MOOD_*, `bounce` 0..1 is the progress of a one-shot hop, `flip` -1 mirrors it.
static func draw(ci: CanvasItem, species: String, stage: int, rect: Rect2, t: float,
		animate: bool, mood: int = MOOD_NORMAL, bounce: float = 0.0, flip: float = 1.0) -> void:
	var s: float = minf(rect.size.x, rect.size.y) / 100.0
	if s <= 0.0:
		return
	var def := _def(species)
	var c := rect.get_center()
	ci.draw_set_transform(Vector2(c.x - 50.0 * s * flip, c.y - 50.0 * s), 0.0, Vector2(s * flip, s))
	var tt: float = t if animate else 0.0
	stage = clampi(stage, 0, 3)
	var p := {
		"k": float(STAGE_SCALE[stage]), "stage": stage, "t": tt, "anim": animate, "mood": mood,
		"col": def.get("color", Color("#FFC2B8")), "accent": def.get("accent", Color("#FF6FA8")),
		"blink": animate and fmod(tt, 3.6) < 0.14, "rot": 0.0, "sy": 1.0, "lift": 0.0,
		"wag": sin(tt * 3.2) * 0.5 if animate else 0.0,
	}
	if animate:
		p["sy"] = 1.0 + sin(tt * 2.2) * 0.02
	var hop: float = sin(clampf(bounce, 0.0, 1.0) * PI)
	p["lift"] = hop * 12.0
	p["sy"] = float(p["sy"]) * (1.0 - 0.06 * hop)
	p["o"] = Vector2(50.0, GROUND_Y)
	_shadow(ci, p)
	if stage == 0:
		_egg(ci, species, p)
	else:
		Species.draw_species(ci, species, p)
	_mood_effects(ci, p)
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


## Filled, outlined, two-tone shaded blob.
static func blob(ci: CanvasItem, poly: PackedVector2Array, col: Color, shade: bool = true,
		ow: float = 1.4) -> void:
	Shade.fill(ci, poly, col, ow, Shade.ink(col))
	if shade:
		Shade.shade_band(ci, poly, col, -1.0)


## Capsule between two pet-space points (radius in pet-space units), outlined.
static func limb(ci: CanvasItem, p: Dictionary, a: Vector2, b: Vector2, r: float, col: Color) -> void:
	var k: float = p["k"]
	var poly := Shade.capsule(q(p, a.x, a.y), q(p, b.x, b.y), r * k)
	Shade.fill(ci, poly, col, 1.2, Shade.ink(col))


## Soft glow dot (halo + core) at a pet-space point.
static func glow(ci: CanvasItem, p: Dictionary, x: float, y: float, r: float, col: Color) -> void:
	var c := q(p, x, y)
	var k: float = p["k"]
	var pulse: float = 1.0 + (sin(float(p["t"]) * 4.0) * 0.08 if p["anim"] else 0.0)
	ci.draw_circle(c, r * k * 2.1 * pulse, Shade.fade(col, 0.2))
	ci.draw_circle(c, r * k * 1.4 * pulse, Shade.fade(col, 0.35))
	ci.draw_circle(c, r * k, Shade.lighten(col, 0.35))


## Big shiny eye. Honours blink, happy (^ ^) and sleepy (half-lid) moods.
static func eye(ci: CanvasItem, p: Dictionary, x: float, y: float, r: float) -> void:
	var k: float = p["k"]
	var c := q(p, x, y)
	var rr: float = r * k * (1.0 + 0.1 * (3 - int(p["stage"])))
	var ink := Shade.INK
	var mood: int = p["mood"]
	if mood == MOOD_HAPPY:
		ci.draw_arc(c + Vector2(0.0, rr * 0.45), rr * 0.9, PI * 1.12, PI * 1.88, 10, ink, maxf(1.4, rr * 0.4), true)
		return
	if mood == MOOD_SLEEPY or bool(p["blink"]):
		ci.draw_arc(c - Vector2(0.0, rr * 0.2), rr * 0.9, PI * 0.12, PI * 0.88, 10, ink, maxf(1.4, rr * 0.4), true)
		return
	ci.draw_circle(c, rr, ink)
	ci.draw_circle(c + Vector2(rr * 0.05, rr * 0.2), rr * 0.62, Color("#3B2A6B"))
	ci.draw_circle(c + Vector2(-rr * 0.32, -rr * 0.34), rr * 0.36, Color.WHITE)
	ci.draw_circle(c + Vector2(rr * 0.3, rr * 0.34), rr * 0.17, Color(1.0, 1.0, 1.0, 0.85))


## Rosy cheek patch.
static func blush(ci: CanvasItem, p: Dictionary, x: float, y: float, r: float) -> void:
	ci.draw_colored_polygon(ell(p, x, y, r, r * 0.65, 0.0, 12), Color(1.0, 0.45, 0.62, 0.45))


## Small smile (or a tiny "o" when sleepy) at a pet-space point, `w` wide.
static func mouth(ci: CanvasItem, p: Dictionary, x: float, y: float, w: float) -> void:
	var k: float = p["k"]
	var c := q(p, x, y)
	if int(p["mood"]) == MOOD_SLEEPY:
		ci.draw_circle(c, w * 0.12 * k, Shade.INK)
	elif int(p["mood"]) == MOOD_HAPPY:
		ci.draw_colored_polygon(ell(p, x, y + 1.0, w * 0.4, w * 0.3, 0.0, 12), Shade.INK)
	else:
		ci.draw_arc(c - Vector2(0.0, w * 0.2 * k), w * 0.4 * k, PI * 0.18, PI * 0.82, 10, Shade.INK, 1.4, true)


static func _shadow(ci: CanvasItem, p: Dictionary) -> void:
	var k: float = p["k"]
	var squish: float = 1.0 - float(p["lift"]) * 0.012
	var c: Vector2 = (p["o"] as Vector2) + Vector2(0.0, 2.0)
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * float(i) / 20.0
		pts.append(c + Vector2(cos(a) * 30.0 * k * squish, sin(a) * 5.0 * k))
	ci.draw_colored_polygon(pts, Color(0.0, 0.0, 0.0, 0.28))


## Patterned egg that wobbles every few seconds.
static func _egg(ci: CanvasItem, species: String, p: Dictionary) -> void:
	var t: float = p["t"]
	if p["anim"] and fmod(t, 4.0) < 0.7:
		p["rot"] = sin(t * 18.0) * 0.12 * (1.0 - fmod(t, 4.0) / 0.7)
	var col: Color = p["col"]
	var acc: Color = p["accent"]
	var pts := PackedVector2Array()
	for i in 28:
		var a := TAU * float(i) / 28.0
		var narrow := 1.0 - 0.13 * (-sin(a))
		pts.append(q(p, cos(a) * 19.0 * narrow, -28.0 + sin(a) * 27.0))
	blob(ci, pts, col)
	var k: float = p["k"]
	match species:
		"xolo":
			for sp in [Vector2(-8, -36), Vector2(7, -42), Vector2(2, -22), Vector2(-9, -20), Vector2(11, -28)]:
				ci.draw_circle(q(p, sp.x, sp.y), 3.2 * k, Shade.fade(acc, 0.85))
		"puff":
			var zig := PackedVector2Array()
			for i in 7:
				zig.append(q(p, -17.0 + i * 5.7, -30.0 + (5.0 if i % 2 == 0 else -5.0)))
			ci.draw_polyline(zig, acc, 2.4, true)
			ci.draw_circle(q(p, 0.0, -44.0), 2.4 * k, Shade.fade(acc, 0.85))
		_:
			var flame := PackedVector2Array([q(p, -4, -17), q(p, 4, -17), q(p, 7, -30), q(p, 1, -42), q(p, -6, -30)])
			ci.draw_colored_polygon(flame, Shade.fade(acc, 0.9))
	ci.draw_circle(q(p, -8.0, -42.0), 3.0 * k, Color(1.0, 1.0, 1.0, 0.5))


## Hearts for a happy pet, floating "z" for a sleepy one.
static func _mood_effects(ci: CanvasItem, p: Dictionary) -> void:
	var mood: int = p["mood"]
	var k: float = p["k"]
	var t: float = p["t"]
	var top: float = -62.0 if int(p["stage"]) > 0 else -64.0
	if mood == MOOD_HAPPY:
		for i in 3:
			var ph: float = fmod(t * 0.6 + float(i) / 3.0, 1.0) if p["anim"] else float(i) / 3.0
			var at := Vector2(-20.0 + i * 20.0 + sin(ph * 6.0 + i) * 3.0, top * k - ph * 14.0)
			var h := (p["o"] as Vector2) + at * 1.0 + Vector2(0.0, -float(p["lift"]) + 8.0)
			var a: float = 0.9 * (1.0 - ph) if p["anim"] else 0.9
			var sz := 3.6 - float(i % 2)
			ci.draw_circle(h + Vector2(-sz * 0.5, 0.0), sz * 0.62, Color(1.0, 0.4, 0.64, a))
			ci.draw_circle(h + Vector2(sz * 0.5, 0.0), sz * 0.62, Color(1.0, 0.4, 0.64, a))
			ci.draw_colored_polygon(PackedVector2Array([h + Vector2(-sz * 1.05, 0.5), h + Vector2(sz * 1.05, 0.5),
				h + Vector2(0.0, sz * 1.5)]), Color(1.0, 0.4, 0.64, a))
	elif mood == MOOD_SLEEPY:
		var font := ThemeDB.fallback_font
		for i in 2:
			var ph: float = fmod(t * 0.35 + float(i) * 0.5, 1.0) if p["anim"] else 0.3 + 0.4 * float(i)
			var at := (p["o"] as Vector2) + Vector2(22.0 + i * 8.0 + ph * 4.0, top * k * 0.8 - ph * 12.0)
			ci.draw_string(font, at, "z", HORIZONTAL_ALIGNMENT_LEFT, -1, int(10 + i * 4),
				Color(0.85, 0.8, 1.0, 0.85 * (1.0 - ph * 0.6)))
