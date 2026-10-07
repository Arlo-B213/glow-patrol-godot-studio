extends RefCounted
## Code-drawn chibi portraits of the three Lanternboys (Story 009): Hae (leader, big
## lantern), Bit (dancer, headphones) and Nun (quiet one, moths). Same outline + two-tone
## style as the hunter art. Characters are drawn in a 100 x 130 design space that is mapped
## uniformly into the target rect: tall rects show the full body, squarer ones crop to the
## head and torso (the caller should clip_contents).

const S := preload("res://scripts/hunter_shade.gd")
const P := preload("res://scripts/lanternboy_parts.gd")
const OW := 1.2
const GOLD := Color("#FFC15E")
const CORAL := Color("#FF8B5E")
const SOFT := Color("#FFE08A")

const FULL_W := 100.0
const FULL_H := 130.0
const CROP := 90.0


## Draws `boy_id` ("hae" | "bit" | "nun") into `rect` of `ci`. `t` is seconds for idle
## motion (blink, bob, glow pulse, moths); it is ignored when `animate` is false or reduced
## motion is on. `bounce` (0..1) lifts the figure for the high-five reaction.
static func draw(ci: CanvasItem, boy_id: String, rect: Rect2, t: float = 0.0,
		animate: bool = true, bounce: float = 0.0) -> void:
	var anim: bool = animate and _motion_on()
	var tt: float = t if anim else 0.0
	var aspect: float = rect.size.y / maxf(rect.size.x, 1.0)
	var s: float
	var origin: Vector2
	if aspect < 1.15:
		s = minf(rect.size.x, rect.size.y) / CROP
		origin = rect.position + (rect.size - Vector2(CROP, CROP) * s) * 0.5 - Vector2(5.0, 6.0) * s
	else:
		s = minf(rect.size.x / FULL_W, rect.size.y / FULL_H)
		origin = rect.position + (rect.size - Vector2(FULL_W, FULL_H) * s) * 0.5
	origin.y -= bounce * 8.0 * s
	var bob: float = sin(tt * 2.2) * 1.0 if anim else 0.0
	origin.y += bob * s
	var tilt: float = 0.0
	if boy_id == "bit":
		tilt = 0.09 + (sin(tt * 4.0) * 0.045 if anim else 0.0)
	var pivot := Vector2(50.0, 125.0) * s
	var rot := Transform2D(tilt, Vector2.ZERO)
	ci.draw_set_transform(origin + pivot - rot * pivot, tilt, Vector2(s, s))
	var blink: bool = anim and fmod(tt + (0.7 if boy_id == "nun" else 0.0), 3.6) > 3.45
	var pulse: float = 0.5 + 0.5 * sin(tt * 3.0) if anim else 0.5
	match boy_id:
		"hae":
			_hae(ci, blink, pulse)
		"bit":
			_bit(ci, tt, anim, blink, pulse)
		"nun":
			_nun(ci, tt, anim, blink, pulse)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _motion_on() -> bool:
	var loop := Engine.get_main_loop()
	if loop is SceneTree:
		var gs: Node = (loop as SceneTree).root.get_node_or_null("GameState")
		if gs != null:
			return not bool(gs.get("reduce_motion"))
	return true


static func _torso(ci: CanvasItem, pts: Array, col: Color) -> void:
	S.fill(ci, pts, col, OW, S.ink(col))
	S.shade_band(ci, pts, col, -1.0, 5.0)


## Hae: neat swept dark hair, gold-trimmed long coat with high collar, the biggest lantern.
static func _hae(ci: CanvasItem, blink: bool, pulse: float) -> void:
	var coat := Color("#38325F")
	var trouser := Color("#24213F")
	var hair := Color("#2E2342")
	var c := P.v(50, 40)
	S.limb(ci, P.v(42, 108), P.v(41, 122), 8.0, trouser, OW)
	S.limb(ci, P.v(58, 108), P.v(59, 122), 8.0, trouser, OW)
	P.shoe(ci, P.v(40, 125), Color("#5B3B2E"))
	P.shoe(ci, P.v(60, 125), Color("#5B3B2E"))
	S.limb(ci, P.v(33, 69), P.v(28, 91), 8.5, coat, OW)
	P.hand(ci, P.v(28, 94))
	ci.draw_colored_polygon(PackedVector2Array([P.v(45, 54), P.v(55, 54), P.v(55, 66), P.v(45, 66)]), S.SKIN_SHADOW)
	_torso(ci, [P.v(32, 64), P.v(68, 64), P.v(73, 113), P.v(27, 113)], coat)
	ci.draw_line(P.v(50, 70), P.v(50, 113), GOLD, 1.6)
	ci.draw_line(P.v(27.5, 111), P.v(72.5, 111), GOLD, 2.2)
	for by in [80.0, 90.0, 100.0]:
		ci.draw_circle(P.v(46, by), 1.3, GOLD)
	ci.draw_line(P.v(31, 90), P.v(36, 90), GOLD, 2.0)
	# face, hair
	P.face(ci, c, blink, Color("#C98A3A"), 0.3)
	P.mouth(ci, c + P.v(0, 13), "smirk")
	P.brow(ci, c + P.v(-15, -6), c + P.v(-5, -8), S.darken(hair, 0.2))
	P.brow(ci, c + P.v(5, -8), c + P.v(15, -7), S.darken(hair, 0.2))
	var fringe := [P.v(26, 41), P.v(27, 28), P.v(34, 18), P.v(50, 14), P.v(66, 18), P.v(75, 30),
		P.v(74, 41), P.v(68, 31), P.v(58, 26), P.v(46, 29), P.v(36, 34), P.v(31, 44)]
	S.fill(ci, fringe, hair, OW, S.ink(hair))
	S.fill(ci, [P.v(58, 16), P.v(74, 10), P.v(76, 22), P.v(66, 22)], hair, OW, S.ink(hair))
	ci.draw_polyline(PackedVector2Array([P.v(33, 24), P.v(44, 18), P.v(57, 18), P.v(68, 14)]),
		S.lighten(hair, 0.5), 2.4, true)
	# collar flaps (high collar)
	for sx in [-1.0, 1.0]:
		var flap := [P.v(50 + sx * 16, 58), P.v(50 + sx * 4, 60), P.v(50, 73), P.v(50 + sx * 12, 69)]
		S.fill(ci, flap, S.lighten(coat, 0.1), OW, GOLD)
	# lantern arm and the biggest lantern
	S.limb(ci, P.v(67, 69), P.v(73, 79), 8.5, coat, OW)
	ci.draw_line(P.v(69, 76), P.v(76, 81), GOLD, 2.0)
	P.lantern(ci, P.v(77, 106), 26.0, GOLD, pulse)
	P.hand(ci, P.v(74, 80))


## Bit: spiky rust hair, headphones, loose striped jacket, mid-dance with a wrist glow-light.
static func _bit(ci: CanvasItem, t: float, anim: bool, blink: bool, pulse: float) -> void:
	var jacket := CORAL
	var pants := Color("#2F5E73")
	var hair := Color("#B5532E")
	var c := P.v(50, 40)
	var wave: float = sin(t * 5.0) * 3.0 if anim else 0.0
	S.limb(ci, P.v(43, 108), P.v(34, 122), 8.0, pants, OW)
	S.limb(ci, P.v(57, 108), P.v(68, 120), 8.0, pants, OW)
	P.shoe(ci, P.v(32, 125), Color("#F4F0FF"))
	P.shoe(ci, P.v(71, 123), Color("#F4F0FF"))
	S.limb(ci, P.v(68, 70), P.v(80, 92), 9.5, jacket, OW)
	P.hand(ci, P.v(81, 95))
	ci.draw_colored_polygon(PackedVector2Array([P.v(45, 54), P.v(55, 54), P.v(55, 66), P.v(45, 66)]), S.SKIN_SHADOW)
	_torso(ci, [P.v(30, 64), P.v(70, 64), P.v(77, 111), P.v(23, 111)], jacket)
	ci.draw_line(P.v(50, 66), P.v(50, 111), S.darken(jacket, 0.5), 1.4)
	for sx in [-1.0, 1.0]:
		ci.draw_line(P.v(50 + sx * 15, 66), P.v(50 + sx * 21, 110), Color("#FFF6E8"), 2.6)
	ci.draw_line(P.v(23.5, 109), P.v(76.5, 109), S.darken(jacket, 0.35), 2.2)
	P.face(ci, c, blink, Color("#3E9AA8"), 0.4)
	P.mouth(ci, c + P.v(0, 12), "grin")
	P.brow(ci, c + P.v(-15, -8), c + P.v(-5, -6), S.darken(hair, 0.25))
	P.brow(ci, c + P.v(5, -6), c + P.v(15, -9), S.darken(hair, 0.25))
	var spikes := [P.v(27, 44), P.v(22, 28), P.v(33, 26), P.v(30, 10), P.v(42, 20), P.v(48, 6),
		P.v(55, 19), P.v(66, 9), P.v(66, 22), P.v(78, 24), P.v(72, 34), P.v(75, 45),
		P.v(68, 34), P.v(58, 28), P.v(46, 31), P.v(36, 36), P.v(31, 46)]
	S.fill(ci, spikes, hair, OW, S.ink(hair))
	ci.draw_polyline(PackedVector2Array([P.v(36, 22), P.v(42, 14), P.v(48, 12)]), S.lighten(hair, 0.45), 2.0, true)
	# headphones on the ears
	ci.draw_arc(c + P.v(0, -1), 26.0, PI * 1.02, PI * 1.98, 16, Color("#2A1F44"), 3.4, true)
	for sx in [-1.0, 1.0]:
		var ear := c + P.v(sx * 25.0, 4.0)
		S.fill(ci, S.ellipse(ear, 5.0, 7.0, 14), Color("#2A1F44"), OW, S.ink(Color("#2A1F44")))
		ci.draw_circle(ear, 2.2, S.fade(CORAL, 0.9))
	# raised arm with the wrist glow-light
	var hand_p := P.v(14 + wave, 46)
	S.limb(ci, P.v(31, 70), P.v(19 + wave * 0.6, 56), 9.5, jacket, OW)
	ci.draw_line(P.v(24 + wave * 0.4, 62), P.v(19 + wave * 0.6, 58), Color("#FFF6E8"), 2.6)
	P.hand(ci, hand_p)
	var wrist := P.v(18 + wave * 0.6, 56)
	ci.draw_line(wrist, wrist + P.v(-3, 7), Color("#2A1F44"), 1.2)
	P.lantern(ci, wrist + P.v(-4, 13), 9.0, CORAL, pulse)


## Nun: long silver hair over one eye, soft knit cardigan and scarf, moths round his lantern.
static func _nun(ci: CanvasItem, t: float, anim: bool, blink: bool, pulse: float) -> void:
	var hair := Color("#D5DAE8")
	var cardigan := SOFT
	var scarf := Color("#6FC7C0")
	var pants := Color("#4F6B73")
	var c := P.v(50, 40)
	var back := [P.v(24, 38), P.v(27, 20), P.v(50, 12), P.v(73, 20), P.v(76, 38), P.v(80, 76),
		P.v(72, 84), P.v(28, 84), P.v(20, 76)]
	S.fill(ci, back, S.darken(hair, 0.12), OW, S.ink(hair))
	S.limb(ci, P.v(43, 108), P.v(43, 122), 8.0, pants, OW)
	S.limb(ci, P.v(57, 108), P.v(57, 122), 8.0, pants, OW)
	P.shoe(ci, P.v(42, 125), Color("#7A5A48"))
	P.shoe(ci, P.v(58, 125), Color("#7A5A48"))
	_torso(ci, [P.v(33, 64), P.v(67, 64), P.v(72, 112), P.v(28, 112)], cardigan)
	for i in range(5):
		var yy: float = 78.0 + float(i) * 7.0
		ci.draw_line(P.v(36, yy), P.v(46, yy + 3), S.fade(S.darken(cardigan, 0.3), 0.5), 1.0)
		ci.draw_line(P.v(54, yy + 3), P.v(64, yy), S.fade(S.darken(cardigan, 0.3), 0.5), 1.0)
	ci.draw_line(P.v(50, 70), P.v(50, 112), S.darken(cardigan, 0.4), 1.4)
	P.face(ci, c + P.v(0, 1), blink, Color("#4FB0A8"), 0.5, P.v(0, 0.8))
	P.mouth(ci, c + P.v(1, 13), "shy")
	var fringe := [P.v(25, 42), P.v(26, 26), P.v(38, 16), P.v(60, 16), P.v(73, 27), P.v(75, 42),
		P.v(69, 33), P.v(60, 30), P.v(54, 34), P.v(46, 42), P.v(41, 48), P.v(34, 47), P.v(30, 52)]
	S.fill(ci, fringe, hair, OW, S.ink(hair))
	ci.draw_polyline(PackedVector2Array([P.v(32, 24), P.v(42, 18), P.v(56, 18)]), Color(1, 1, 1, 0.8), 2.2, true)
	for sx in [-1.0, 1.0]:
		S.fill(ci, [P.v(50 + sx * 25, 40), P.v(50 + sx * 29, 44), P.v(50 + sx * 28, 70), P.v(50 + sx * 22, 70)],
			hair, OW, S.ink(hair))
	# oversized scarf
	S.fill(ci, S.ellipse(P.v(50, 64), 21.0, 7.0, 18), scarf, OW, S.ink(scarf))
	S.shade_band(ci, S.ellipse(P.v(50, 64), 21.0, 7.0, 18), scarf, -1.0, 3.0)
	S.fill(ci, [P.v(57, 66), P.v(67, 70), P.v(69, 92), P.v(59, 89)], scarf, OW, S.ink(scarf))
	# arms hold the lantern, moths circle it
	var lc := P.v(50, 92)
	S.limb(ci, P.v(34, 70), P.v(44, 93), 9.5, cardigan, OW)
	S.limb(ci, P.v(66, 70), P.v(56, 93), 9.5, cardigan, OW)
	P.lantern(ci, lc, 12.0, SOFT, pulse)
	P.hand(ci, P.v(44.5, 94), 3.6)
	P.hand(ci, P.v(55.5, 94), 3.6)
	for k in range(3):
		var a: float = (t * 1.3 if anim else 0.4) + float(k) * TAU / 3.0
		var mp: Vector2 = lc + P.v(cos(a) * 25.0, sin(a) * 11.0 - 6.0)
		var flap: float = 0.5 + 0.5 * sin(t * 14.0 + float(k) * 2.0) if anim else 0.8
		P.moth(ci, mp, 5.5, flap, Color("#F2E9D8"))
