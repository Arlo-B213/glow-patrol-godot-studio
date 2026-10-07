extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Hae and Bit for the Lanternboy portraits (Story 009, upgraded in Story 032): shaped
## garments, tapered limbs, gradient hair with strand highlights, lantern rim light.
## Design space 100 x 130; called from LanternboyArt.draw(). Nun lives in lanternboy_nun.gd.

const S := preload("res://scripts/hunter_shade.gd")
const P := preload("res://scripts/lanternboy_parts.gd")
const OW := 1.2
const GOLD := Color("#FFC15E")
const CORAL := Color("#FF8B5E")
const CREAM := Color("#FFF6E8")


## Garment polygon with outline, 3-tone shading and a soft sheen.
static func torso(ci: CanvasItem, pts: Array, col: Color) -> void:
	S.fill(ci, pts, col, OW, S.ink(col))
	S.shade_band(ci, pts, col, -1.0, 5.0)


## Hae: neat swept dark hair, gold-trimmed long coat with high collar, the biggest lantern.
static func hae(ci: CanvasItem, pulse: float) -> void:
	var coat := Color("#38325F")
	var trouser := Color("#24213F")
	var hair := Color("#2E2342")
	var c := P.v(50, 40)
	var sw: float = P.sway
	P.rim = GOLD
	P.rim_dir = 1.0
	P.brow_bias = Vector2(0.0, 0.8)
	S.taper(ci, P.v(42, 106), P.v(41, 121), 10.0, 7.6, trouser, OW)
	S.taper(ci, P.v(58, 106), P.v(59, 121), 10.0, 7.6, trouser, OW)
	P.shoe(ci, P.v(40, 125), Color("#5B3B2E"))
	P.shoe(ci, P.v(60, 125), Color("#5B3B2E"))
	S.taper(ci, P.v(33, 69), P.v(28, 91), 9.5, 7.6, coat, OW)
	S.limb(ci, P.v(28.4, 88.4), P.v(28, 91), 8.6, GOLD, 0.8)
	P.hand(ci, P.v(28, 94))
	FD.poly(ci, PackedVector2Array([P.v(45, 54), P.v(55, 54), P.v(56, 67), P.v(44, 67)]), S.SKIN_SHADOW)
	var body: Array = [P.v(35, 64), P.v(65, 64), P.v(70, 72), P.v(68, 86), P.v(64, 97), P.v(74, 113), P.v(26, 113), P.v(36, 97), P.v(32, 86), P.v(30, 72)]
	torso(ci, body, coat)
	P.cast_light(ci, body, P.v(77, 104), GOLD, pulse, P.v(69.5, 72), P.v(73.5, 112))
	ci.draw_line(P.v(50, 70), P.v(50, 113), GOLD, 1.6)
	ci.draw_line(P.v(26.5, 111), P.v(73.5, 111), GOLD, 2.2)
	ci.draw_line(P.v(32, 78), P.v(36.5, 97), S.fade(GOLD, 0.7), 1.0)
	S.fill(ci, [P.v(36, 94.5), P.v(64, 94.5), P.v(64, 99), P.v(36, 99)], S.darken(coat, 0.4), 0.8, GOLD)
	S.fill(ci, S.ellipse(P.v(50, 96.8), 3.4, 2.6, 10), GOLD, 0.8, S.ink(GOLD))
	for sx in [-1.0, 1.0]:
		S.fill(ci, [P.v(50 + sx * 8, 101), P.v(50 + sx * 17, 101), P.v(50 + sx * 17.5, 106), P.v(50 + sx * 8.5, 106)], S.lighten(coat, 0.06), 0.9, GOLD)
		S.fill(ci, S.ellipse(P.v(50 + sx * 30.5, 66.5), 5.0, 2.8, 10), GOLD, 0.8, S.ink(GOLD))
		for j in range(3):
			ci.draw_line(P.v(50 + sx * (27.0 + 2.5 * float(j)), 68.5), P.v(50 + sx * (27.0 + 2.5 * float(j)), 72.0), GOLD, 0.9)
	for by in [76.0, 84.0, 92.0]:
		S.circle(ci, P.v(46, by), 1.4, GOLD, 0.6, S.ink(GOLD))
	ci.draw_line(P.v(31, 90), P.v(36, 90), GOLD, 2.0)
	P.face(ci, c, false, Color("#C98A3A"), 0.3)
	P.mouth(ci, c + P.v(0, 13), "smirk")
	var tip: float = sw * 0.6
	var fringe := [P.v(26, 41), P.v(27, 28), P.v(34, 18), P.v(50, 14), P.v(66, 18), P.v(75, 30),
		P.v(74 + tip, 43), P.v(68, 31), P.v(58, 26), P.v(46 + tip * 0.3, 31), P.v(36, 34), P.v(30 + tip * 0.5, 46)]
	P.hair(ci, fringe, hair, [[P.v(33, 24), P.v(44, 18), P.v(57, 18), P.v(68, 14)], [P.v(30, 33), P.v(33, 24)]])
	P.hair(ci, [P.v(58, 16), P.v(74 + tip * 0.3, 8), P.v(77 + tip * 0.5, 21), P.v(66, 22)], hair, [[P.v(60, 17), P.v(72, 11)]])
	ci.draw_line(P.v(50, 15), P.v(50 + sw * 0.4, 6), S.darken(hair, 0.1), 1.4, true)
	for sx in [-1.0, 1.0]:
		var flap := [P.v(50 + sx * 16, 58), P.v(50 + sx * 4, 60), P.v(50, 73), P.v(50 + sx * 12, 69)]
		S.fill(ci, flap, S.lighten(coat, 0.1), OW, GOLD)
		ci.draw_line(P.v(50 + sx * 14, 60), P.v(50 + sx * 5, 63), S.fade(GOLD, 0.8), 1.0)
	S.taper(ci, P.v(67, 69), P.v(73, 79), 9.5, 7.8, coat, OW)
	ci.draw_line(P.v(69, 76), P.v(76, 81), GOLD, 2.2)
	P.lantern(ci, P.v(77, 106), 26.0, GOLD, pulse)
	P.hand(ci, P.v(74, 80))
	ci.draw_line(P.v(74, 83), P.v(77, 91), S.fade(GOLD, 0.9), 1.0)


## Bit: spiky rust hair, headphones, loose striped jacket, mid-dance with a wrist glow-light.
static func bit(ci: CanvasItem, t: float, anim: bool, pulse: float) -> void:
	var jacket := CORAL
	var pants := Color("#2F5E73")
	var hair := Color("#B5532E")
	var c := P.v(50, 40)
	var wave: float = sin(t * 5.0) * 3.0 if anim else 0.0
	var sw: float = P.sway
	P.rim = CORAL
	P.rim_dir = -1.0
	P.brow_bias = Vector2(0.5, -0.2)
	S.taper(ci, P.v(43, 106), P.v(34, 122), 10.0, 7.6, pants, OW)
	S.taper(ci, P.v(57, 106), P.v(68, 120), 10.0, 7.6, pants, OW)
	P.shoe(ci, P.v(32, 125), Color("#F4F0FF"))
	P.shoe(ci, P.v(71, 123), Color("#F4F0FF"))
	S.taper(ci, P.v(68, 70), P.v(80, 92), 10.5, 8.2, jacket, OW)
	ci.draw_line(P.v(74, 80), P.v(75, 82.5), CREAM, 2.6)
	P.hand(ci, P.v(81, 95))
	FD.poly(ci, PackedVector2Array([P.v(45, 54), P.v(55, 54), P.v(56, 67), P.v(44, 67)]), S.SKIN_SHADOW)
	var body: Array = [P.v(33, 64), P.v(67, 64), P.v(72, 72), P.v(73, 90), P.v(77, 111), P.v(23, 111), P.v(27, 90), P.v(28, 72)]
	torso(ci, body, jacket)
	P.cast_light(ci, body, P.v(14, 70), CORAL, pulse, P.v(28.5, 72), P.v(27, 100))
	ci.draw_line(P.v(50, 66), P.v(50, 111), S.darken(jacket, 0.5), 1.4)
	for sx in [-1.0, 1.0]:
		ci.draw_line(P.v(50 + sx * 15, 66), P.v(50 + sx * 21, 110), CREAM, 2.6)
		ci.draw_line(P.v(50 + sx * 18.5, 66), P.v(50 + sx * 24.5, 110), S.fade(CREAM, 0.7), 1.0)
		S.fill(ci, [P.v(50 + sx * 6, 92), P.v(50 + sx * 13, 92), P.v(50 + sx * 13, 99), P.v(50 + sx * 6, 99)], S.darken(jacket, 0.15), 0.9, S.ink(jacket))
	ci.draw_line(P.v(23.5, 109), P.v(76.5, 109), S.darken(jacket, 0.35), 2.2)
	S.fill(ci, S.ellipse(P.v(36, 80), 4.6, 4.6, 10), CREAM, 0.8, S.ink(jacket))
	FD.circle(ci, P.v(36, 80), 1.6, CORAL)
	P.face(ci, c, false, Color("#3E9AA8"), 0.4)
	P.mouth(ci, c + P.v(0, 12), "grin")
	var f: float = sw * 0.7
	var spikes := [P.v(27, 44), P.v(21 + f, 28), P.v(33, 26), P.v(29 + f, 9), P.v(42, 20), P.v(48 + f * 0.6, 5),
		P.v(55, 19), P.v(66 + f * 0.5, 8), P.v(66, 22), P.v(79 + f * 0.8, 24), P.v(72, 34), P.v(75, 45),
		P.v(68, 34), P.v(58, 28), P.v(46, 31), P.v(36, 36), P.v(31, 46)]
	P.hair(ci, spikes, hair, [[P.v(36, 22), P.v(42, 14), P.v(48, 11)], [P.v(58, 22), P.v(64, 15), P.v(67, 11)], [P.v(30, 40), P.v(28, 31)]])
	FD.arc(ci, c + P.v(0, -1), 26.0, PI * 1.02, PI * 1.98, 16, Color("#2A1F44"), 3.4, true)
	FD.arc(ci, c + P.v(0, -3), 24.0, PI * 1.2, PI * 1.5, 8, S.fade(Color("#8A78C8"), 0.7), 1.2, true)
	for sx in [-1.0, 1.0]:
		var ear := c + P.v(sx * 25.0, 4.0)
		S.fill(ci, S.ellipse(ear, 5.0, 7.0, 14), Color("#2A1F44"), OW, S.ink(Color("#2A1F44")))
		FD.circle(ci, ear, 3.0, S.fade(CORAL, 0.5 + 0.3 * pulse))
		FD.circle(ci, ear, 1.8, S.fade(S.lighten(CORAL, 0.5), 0.95))
	var hand_p := P.v(14 + wave, 46)
	S.taper(ci, P.v(31, 70), P.v(19 + wave * 0.6, 56), 10.5, 8.2, jacket, OW)
	ci.draw_line(P.v(24 + wave * 0.4, 62), P.v(19 + wave * 0.6, 58), CREAM, 2.6)
	P.hand(ci, hand_p)
	var wrist := P.v(18 + wave * 0.6, 56)
	ci.draw_line(wrist, wrist + P.v(-3, 7), Color("#2A1F44"), 1.2)
	P.lantern(ci, wrist + P.v(-4, 13), 9.0, CORAL, pulse)
