extends RefCounted
## Nun for the Lanternboy portraits (Story 032 upgrade): long silver hair over one eye, knit
## cardigan, a swaying oversized scarf, and the lantern he holds lighting his face from below
## while moths circle it. Design space 100 x 130.

const S := preload("res://scripts/hunter_shade.gd")
const P := preload("res://scripts/lanternboy_parts.gd")
const Cast := preload("res://scripts/lanternboy_cast.gd")
const OW := 1.2
const SOFT := Color("#FFE08A")


## Draws Nun. `t` seconds, `anim` false = still pose, `pulse` 0..1 lantern glow.
static func nun(ci: CanvasItem, t: float, anim: bool, pulse: float) -> void:
	var hair := Color("#D5DAE8")
	var cardigan := SOFT
	var scarf := Color("#6FC7C0")
	var pants := Color("#4F6B73")
	var c := P.v(50, 40)
	var sw: float = P.sway
	P.rim = SOFT
	P.rim_dir = 0.0
	P.brow_bias = Vector2(-0.2, -0.7)
	var back := [P.v(24, 38), P.v(27, 20), P.v(50, 12), P.v(73, 20), P.v(76, 38), P.v(80 + sw * 0.6, 76),
		P.v(72, 86), P.v(28, 86), P.v(20 + sw * 0.6, 76)]
	P.hair(ci, back, S.darken(hair, 0.12))
	S.taper(ci, P.v(43, 106), P.v(43, 121), 10.0, 7.6, pants, OW)
	S.taper(ci, P.v(57, 106), P.v(57, 121), 10.0, 7.6, pants, OW)
	P.shoe(ci, P.v(42, 125), Color("#7A5A48"))
	P.shoe(ci, P.v(58, 125), Color("#7A5A48"))
	var body: Array = [P.v(35, 64), P.v(65, 64), P.v(70, 74), P.v(68, 90), P.v(73, 112), P.v(27, 112), P.v(32, 90), P.v(30, 74)]
	Cast.torso(ci, body, cardigan)
	for i in range(5):
		var yy: float = 78.0 + float(i) * 7.0
		ci.draw_line(P.v(36, yy), P.v(46, yy + 3), S.fade(S.darken(cardigan, 0.3), 0.5), 1.0)
		ci.draw_line(P.v(54, yy + 3), P.v(64, yy), S.fade(S.darken(cardigan, 0.3), 0.5), 1.0)
	ci.draw_line(P.v(50, 70), P.v(50, 112), S.darken(cardigan, 0.4), 1.4)
	for by in [78.0, 90.0, 102.0]:
		S.circle(ci, P.v(53, by), 1.5, Color("#7A5A48"), 0.6, S.ink(Color("#7A5A48")))
	S.fill(ci, [P.v(58, 96), P.v(67, 96), P.v(67.5, 104), P.v(58.5, 104)], S.darken(cardigan, 0.12), 0.9, S.ink(cardigan))
	ci.draw_line(P.v(27.5, 110), P.v(72.5, 110), S.darken(cardigan, 0.25), 3.0)
	P.cast_light(ci, body, P.v(50, 94), SOFT, pulse, P.v(31, 90), P.v(33, 110))
	P.face(ci, c + P.v(0, 1), false, Color("#4FB0A8"), 0.5, P.v(0, 0.8))
	P.mouth(ci, c + P.v(1, 13), "shy")
	var fringe := [P.v(25, 42), P.v(26, 26), P.v(38, 16), P.v(60, 16), P.v(73, 27), P.v(75, 42),
		P.v(69, 33), P.v(60, 30), P.v(54, 34), P.v(46 + sw * 0.3, 42), P.v(41 + sw * 0.5, 48), P.v(34, 47), P.v(30 + sw * 0.4, 52)]
	P.hair(ci, fringe, hair, [[P.v(32, 24), P.v(42, 18), P.v(56, 18)], [P.v(48, 34), P.v(44, 42)]])
	for sx in [-1.0, 1.0]:
		P.hair(ci, [P.v(50 + sx * 25, 40), P.v(50 + sx * 29, 44), P.v(50 + sx * 28 + sw * 0.6, 72), P.v(50 + sx * 22 + sw * 0.6, 70)], hair, [[P.v(50 + sx * 26, 46), P.v(50 + sx * 26 + sw * 0.3, 64)]])
	# oversized scarf with a swinging tail
	var ring := S.ellipse(P.v(50, 64), 21.0, 7.0, 18)
	S.fill(ci, ring, scarf, OW, S.ink(scarf))
	S.shade_band(ci, ring, scarf, -1.0, 3.0)
	for i in range(5):
		ci.draw_line(P.v(32.0 + float(i) * 8.0, 60.5), P.v(33.0 + float(i) * 8.0, 68.0), S.fade(S.lighten(scarf, 0.5), 0.6), 1.0)
	var tail := [P.v(57, 66), P.v(67, 70), P.v(69 + sw * 0.9, 92), P.v(59 + sw * 0.9, 89)]
	S.fill(ci, tail, scarf, OW, S.ink(scarf))
	S.shade_band(ci, tail, scarf, -1.0, 3.0)
	for i in range(3):
		ci.draw_line(P.v(60.0 + float(i) * 3.0 + sw * 0.9, 89.0 + float(i) * 0.6), P.v(60.0 + float(i) * 3.0 + sw * 1.1, 94.0), S.darken(scarf, 0.2), 1.2)
	var lc := P.v(50, 92)
	S.taper(ci, P.v(34, 70), P.v(44, 93), 10.5, 8.0, cardigan, OW)
	S.taper(ci, P.v(66, 70), P.v(56, 93), 10.5, 8.0, cardigan, OW)
	P.lantern(ci, lc, 12.0, SOFT, pulse)
	P.hand(ci, P.v(44.5, 94), 3.6)
	P.hand(ci, P.v(55.5, 94), 3.6)
	for k in range(3):
		var a: float = (t * 1.3 if anim else 0.4) + float(k) * TAU / 3.0
		var mp: Vector2 = lc + P.v(cos(a) * 25.0, sin(a) * 11.0 - 6.0)
		var flap: float = 0.5 + 0.5 * sin(t * 14.0 + float(k) * 2.0) if anim else 0.8
		P.moth(ci, mp, 5.5, flap, Color("#F2E9D8"))
