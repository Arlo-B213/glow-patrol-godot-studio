extends RefCounted
## Procedural art for the newer Gloomling variants (Story 021): the hopping one-eyed Blinker, the
## bulky mossy Mossback, and the defeat puff. Called from brawl_art.gd's draw_enemy; every function
## draws onto a CanvasItem from its _draw(). `fx` keys: flash, sq, alpha, hp (see brawl_art.gd).

const INK := Color("#1A0B33")
const BLACKOUT := Color("#0A0418")
const HOP_CYCLE := 36
const HOP_AIR := 22


static func _c(col: Color, a: float) -> Color:
	return Color(col.r, col.g, col.b, col.a * a)


static func _ellipse(center: Vector2, rx: float, ry: float, points: int = 20) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(points):
		var a: float = TAU * float(i) / float(points)
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


## True while a Blinker is in the air part of its hop (it only travels then); shared with the view.
static func blinker_airborne(age: int) -> bool:
	return age % HOP_CYCLE < HOP_AIR


## Blinker: a small fuzzy ball with one huge blinking eye, a tuft of spikes and springy legs.
static func draw_blinker(ci: CanvasItem, x: float, ground_y: float, s: float, color: Color, age: int, toward: float, u: float, fx: Dictionary = {}) -> void:
	var flash: float = float(fx.get("flash", 0.0))
	var al: float = float(fx.get("alpha", 1.0))
	var sq: float = float(fx.get("sq", 1.0))
	var ph: int = age % HOP_CYCLE
	var lift: float = 0.0
	var stretch: float = 1.0
	if ph < HOP_AIR:
		lift = sin(float(ph) / float(HOP_AIR) * PI) * 16.0 * u
		stretch = 1.0 + sin(float(ph) / float(HOP_AIR) * PI) * 0.14
	else:
		stretch = 1.0 - sin(float(ph - HOP_AIR) / float(HOP_CYCLE - HOP_AIR) * PI) * 0.18
	stretch *= sq
	var r: float = s * 0.5
	var c := Vector2(x, ground_y - r * stretch - s * 0.12 - lift)
	var body: Color = color.lerp(Color("#0E1B3A"), 0.55).lerp(Color.WHITE, flash)
	var rim: Color = color.lerp(Color.WHITE, flash)

	ci.draw_circle(c, r * 1.25, _c(color, 0.15 * al))
	# Springy legs: a zig-zag from the body down to the floor (squeezed when crouching).
	var foot_y: float = ground_y - lift * 0.15
	for side in [-1.0, 1.0]:
		var top: Vector2 = c + Vector2(side * r * 0.35, r * 0.7 * stretch)
		var low := Vector2(top.x + side * r * 0.08, foot_y)
		var mid: Vector2 = top.lerp(low, 0.5) + Vector2(side * r * 0.22, 0.0)
		ci.draw_polyline(PackedVector2Array([top, mid, low]), _c(rim, 0.95 * al), 2.2 * u)
		ci.draw_circle(low, r * 0.14, _c(body, al))
	# Spiky tuft: three small triangles.
	for i in range(3):
		var tx: float = c.x + (float(i) - 1.0) * r * 0.42
		var th: float = r * (0.62 if i == 1 else 0.48)
		ci.draw_colored_polygon(PackedVector2Array([
			Vector2(tx - r * 0.17, c.y - r * 0.82 * stretch), Vector2(tx + r * 0.17, c.y - r * 0.82 * stretch), Vector2(tx, c.y - r * 0.82 * stretch - th),
		]), _c(rim, al))
	ci.draw_colored_polygon(_ellipse(c, r / sqrt(stretch), r * stretch, 22), _c(body, al))
	ci.draw_arc(c, r, 0.0, TAU, 24, _c(rim, 0.9 * al), 2.0 * u)
	# The big eye, with a lid that blinks every ~1.5 s.
	var eye: Vector2 = c + Vector2(0.0, -r * 0.08)
	var er: float = r * 0.52
	ci.draw_circle(eye, er, _c(Color("#F4FFFF"), al))
	ci.draw_circle(eye + Vector2(toward * er * 0.32, 0.0), er * 0.46, _c(rim.lerp(INK, 0.35), al))
	ci.draw_circle(eye + Vector2(toward * er * 0.38, 0.0), er * 0.22, _c(BLACKOUT, al))
	ci.draw_circle(eye + Vector2(toward * er * 0.22, -er * 0.18), er * 0.1, _c(Color.WHITE, al))
	if age % 90 < 6:
		ci.draw_colored_polygon(_ellipse(eye, er * 1.02, er * 1.02, 18), _c(body, al))
		ci.draw_line(eye + Vector2(-er * 0.8, 0.0), eye + Vector2(er * 0.8, 0.0), _c(BLACKOUT, al), 2.0 * u)
	ci.draw_line(eye + Vector2(-er * 0.9, -er * 1.1), eye + Vector2(er * 0.8, -er * 0.8), _c(BLACKOUT, al), 2.0 * u)


## Mossback: a heavy, sleepy-eyed blob with a mossy mound and mushrooms on its back. Takes two punches;
## with `fx.hp` <= 1 one of its mushrooms has been knocked off.
static func draw_mossback(ci: CanvasItem, x: float, ground_y: float, s: float, color: Color, age: int, toward: float, u: float, fx: Dictionary = {}) -> void:
	var t: float = float(age)
	var flash: float = float(fx.get("flash", 0.0))
	var al: float = float(fx.get("alpha", 1.0))
	var sq: float = float(fx.get("sq", 1.0))
	var hp: int = int(fx.get("hp", 2))
	var plod: float = absf(sin(t * 0.07))
	var rx: float = s * 0.58 * (1.0 + plod * 0.03) / sq
	var ry: float = s * 0.42 * sq
	var c := Vector2(x, ground_y - ry - s * 0.08 - plod * 2.0 * u)
	var body: Color = Color("#4A3B6B").lerp(Color.WHITE, flash)
	var moss: Color = color.lerp(Color.WHITE, flash)
	var moss_dark: Color = moss.lerp(Color("#10281A"), 0.4)

	ci.draw_circle(c, s * 0.72, _c(moss, 0.12 * al))
	# Stubby feet.
	for side in [-1.0, 1.0]:
		ci.draw_colored_polygon(_ellipse(Vector2(c.x + side * rx * 0.5, ground_y - s * 0.05), s * 0.17, s * 0.07, 12), _c(body.lerp(INK, 0.4), al))
	ci.draw_colored_polygon(_ellipse(c, rx, ry, 28), _c(body, al))
	# Mossy mound over the back half: lumpy circles along the top.
	var lumps := [Vector2(-0.46, -0.42), Vector2(-0.2, -0.6), Vector2(0.08, -0.66), Vector2(0.34, -0.56), Vector2(0.54, -0.34), Vector2(-0.58, -0.2)]
	for lp in lumps:
		var v: Vector2 = lp
		ci.draw_circle(c + Vector2(v.x * rx * 1.7, v.y * ry * 1.35), s * 0.17, _c(moss_dark, al))
	for lp in lumps:
		var v2: Vector2 = lp
		ci.draw_circle(c + Vector2(v2.x * rx * 1.7 - s * 0.02, v2.y * ry * 1.35 - s * 0.03), s * 0.12, _c(moss, al))
	# Mushrooms (the right-hand one falls off after the first punch).
	var shrooms: Array = [Vector2(-0.2, -0.78)]
	if hp >= 2:
		shrooms.append(Vector2(0.3, -0.7))
	for sp in shrooms:
		var base: Vector2 = c + Vector2((sp as Vector2).x * rx * 1.7, (sp as Vector2).y * ry * 1.35)
		var wob: float = sin(t * 0.1 + base.x) * s * 0.01
		ci.draw_line(base, base + Vector2(wob, -s * 0.12), _c(Color("#F6EBD9"), al), s * 0.06)
		ci.draw_colored_polygon(_ellipse(base + Vector2(wob, -s * 0.14), s * 0.12, s * 0.07, 14), _c(Color("#FF7A8A").lerp(Color.WHITE, flash), al))
		ci.draw_circle(base + Vector2(wob - s * 0.04, -s * 0.15), s * 0.016, _c(Color.WHITE, al))
		ci.draw_circle(base + Vector2(wob + s * 0.04, -s * 0.13), s * 0.016, _c(Color.WHITE, al))
	# Face: heavy-lidded eyes that watch the hunter, brow and an underbite with one tooth.
	for side in [-1.0, 1.0]:
		var eye: Vector2 = c + Vector2(side * rx * 0.34 + toward * s * 0.04, -ry * 0.05)
		ci.draw_circle(eye, s * 0.085, _c(Color("#FFF7D6"), al))
		ci.draw_circle(eye + Vector2(toward * s * 0.03, s * 0.01), s * 0.04, _c(INK, al))
		ci.draw_colored_polygon(PackedVector2Array([
			eye + Vector2(-s * 0.1, -s * 0.1), eye + Vector2(s * 0.1, -s * 0.1), eye + Vector2(s * 0.1, -s * 0.02), eye + Vector2(-s * 0.1, -s * 0.02),
		]), _c(body, al))
		ci.draw_line(eye + Vector2(-s * 0.1, -s * 0.02), eye + Vector2(s * 0.1, -s * 0.02), _c(BLACKOUT, al), 2.0 * u)
	var jaw: Vector2 = c + Vector2(0.0, ry * 0.42)
	ci.draw_colored_polygon(PackedVector2Array([
		jaw + Vector2(-rx * 0.45, -s * 0.03), jaw + Vector2(rx * 0.45, -s * 0.03), jaw + Vector2(rx * 0.36, s * 0.1), jaw + Vector2(-rx * 0.36, s * 0.1),
	]), _c(BLACKOUT, al))
	ci.draw_colored_polygon(PackedVector2Array([
		jaw + Vector2(-s * 0.05, s * 0.1), jaw + Vector2(s * 0.05, s * 0.1), jaw + Vector2(s * 0.03, -s * 0.03), jaw + Vector2(-s * 0.03, -s * 0.03),
	]), _c(Color.WHITE, al))


## A soft defeat puff: `p` runs 0..1; circles drift outward, shrink and fade.
static func draw_puff(ci: CanvasItem, pos: Vector2, r: float, p: float, color: Color, u: float) -> void:
	var fade: float = 1.0 - p
	ci.draw_circle(pos, r * (0.5 + p * 0.9), _c(Color.WHITE.lerp(color, 0.5), 0.3 * fade))
	for i in range(7):
		var a: float = TAU * float(i) / 7.0 + 0.4
		var d: float = r * (0.3 + p * 1.1)
		ci.draw_circle(pos + Vector2(cos(a) * d, sin(a) * d * 0.8 - p * 8.0 * u), r * 0.28 * (1.0 - p * 0.6), _c(Color("#F1EAFF").lerp(color, 0.35), 0.8 * fade))
