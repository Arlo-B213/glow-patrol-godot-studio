extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Outfit bodies for the idol hunter (Story 007, detail pass Story 015). Each of the 8 styles
## has a side-view version (battle pose) and a front-view version (portrait). Everything is
## drawn with CanvasItem draw_* calls; `look["outfit"]` is the main colour, accents are derived.
## Styles track / sequin / armor / robe live here; hanbok / tailcoat / cape / galaxy are in
## hunter_outfits_b.gd. Drawing helpers (outline, two-tone shading) are in hunter_outfit_kit.gd.
##
## Both entry points take an origin `o` and a scale `s` and draw in figure units, so the
## body footprint matches the original jacket (side: x +-17, y -74..-40; front: x +-27,
## y -52..-22). Legs and boots are drawn by HunterArt beforehand; skirts may cover them.

const K := preload("res://scripts/hunter_outfit_kit.gd")
const B := preload("res://scripts/hunter_outfits_b.gd")
const D := preload("res://scripts/hunter_outfit_detail.gd")

## Style ids understood by draw_side / draw_front (unknown ids fall back to "track").
const STYLES: Array[String] = ["track", "sequin", "armor", "robe", "hanbok", "tailcoat", "cape", "galaxy"]


static func _norm(style: String) -> String:
	return style if STYLES.has(style) else "track"


## Side-view outfit body. `o` = feet origin shifted up by the bob, `s` = layout scale,
## `f` = facing (+1/-1), `sway` = cloth sway, `tw` = animation time for twinkles.
static func draw_side(ci: CanvasItem, style: String, o: Vector2, s: float, f: float, sway: float, moving: bool, outfit: Color, tw: float, alpha: float) -> void:
	var st: String = _norm(style)
	if st in ["hanbok", "tailcoat", "cape", "galaxy"]:
		B.draw_side(ci, st, o, s, f, sway, moving, outfit, tw, alpha)
		D.side(ci, st, o, s, f, sway, outfit, tw, alpha)
		return
	var lt: Color = K.c(outfit.lerp(Color.WHITE, 0.4), alpha)
	var dk: Color = K.c(outfit.lerp(K.INK, 0.45), alpha)
	var m: Color = K.c(outfit, alpha)
	var gold: Color = K.c(K.GOLD, alpha)
	var wh: Color = K.c(Color.WHITE, alpha)
	var run: float = 8.0 if moving else 0.0
	var torso: Array = K.TORSO_S
	match st:
		"sequin":
			K.part(ci, o, s, [Vector2(-f * 8, -50), Vector2(-f * 8, -38), Vector2(-f * (18.0 + run), -34 + sway)], dk)
			K.part(ci, o, s, torso, m)
			K.pl(ci, o, s, [Vector2(-15, -46), Vector2(15, -46), Vector2(19, -37), Vector2(-19, -37)], lt)
			K.stitch(ci, o, s, Vector2(-16, -41), Vector2(16, -41), K.c(gold, 0.8), 7)
			K.ln(ci, o, s, Vector2(-14, -73), Vector2(14, -73), gold, 1.4)
			K.star(ci, o, s, Vector2(f * 7, -73), 7.0, gold)
			K.star(ci, o, s, Vector2(-f * 8, -73), 5.0, gold)
			for p in [Vector2(-6, -64), Vector2(5, -58), Vector2(-3, -50), Vector2(8, -68)]:
				K.glint(ci, o, s, p, 3.5, tw, p.x, wh)
			for p in [Vector2(-10, -58), Vector2(9, -62), Vector2(1, -66), Vector2(11, -52), Vector2(-9, -50), Vector2(-1, -56)]:
				K.dot(ci, o, s, p, 1.1, K.c(gold, 0.9))
				K.dot(ci, o, s, p + Vector2(-0.3, -0.3), 0.45, wh)
			K.rc(ci, o, s, Vector2(-13, -47), Vector2(26, 3), gold)
		"armor":
			K.part(ci, o, s, [Vector2(-f * 10, -48), Vector2(-f * 10, -36), Vector2(-f * (22.0 + run), -34 + sway)], dk)
			K.part(ci, o, s, torso, dk)
			K.part(ci, o, s, [Vector2(-14, -72), Vector2(14, -72), Vector2(11, -50), Vector2(-11, -50)], m)
			K.ln(ci, o, s, Vector2(-12, -62), Vector2(12, -62), lt, 2.0)
			K.ln(ci, o, s, Vector2(f * 3, -72), Vector2(f * 3, -50), lt, 2.0)
			K.ln(ci, o, s, Vector2(-13, -71), Vector2(13, -71), K.c(wh, 0.8), 1.0)
			K.ln(ci, o, s, Vector2(-13.5, -70), Vector2(-10.5, -51), K.c(wh, 0.6), 1.0)
			for p in [Vector2(-10, -67), Vector2(10, -67), Vector2(-9, -55), Vector2(9, -55)]:
				K.bead(ci, o, s, p, 1.3, gold)
			K.rc(ci, o, s, Vector2(-13, -48), Vector2(26, 5), dk)
			K.bead(ci, o, s, Vector2(f * 3, -45.5), 3.0, gold)
			K.pl(ci, o, s, [Vector2(-12, -43), Vector2(0, -43), Vector2(-2, -34), Vector2(-11, -34)], m)
			K.pl(ci, o, s, [Vector2(0, -43), Vector2(12, -43), Vector2(11, -34), Vector2(2, -34)], m)
			K.ln(ci, o, s, Vector2(-11.5, -42), Vector2(-1, -42), lt, 1.0)
			K.ln(ci, o, s, Vector2(1, -42), Vector2(11.5, -42), lt, 1.0)
			var pc := Vector2(f * 7, -72)
			K.part(ci, o, s, K.ell(pc, 11.0, 7.0), m)
			FD.arc(ci, o + pc * s, 9.0 * s, PI, TAU, 10, lt, maxf(1.0, 2.0 * s))
			K.bead(ci, o, s, pc + Vector2(0, 1), 1.5, gold)
		"robe":
			var hem: float = -f * sway * 0.8
			K.part(ci, o, s, [Vector2(-17, -74), Vector2(17, -74), Vector2(19, -44), Vector2(23 + hem, -18), Vector2(-23 + hem, -18), Vector2(-19, -44)], m)
			K.ln(ci, o, s, Vector2(-8, -44), Vector2(-11 + hem, -22), K.c(K.INK, 0.25 * alpha), 1.4)
			K.ln(ci, o, s, Vector2(8, -44), Vector2(11 + hem, -22), K.c(K.INK, 0.25 * alpha), 1.4)
			K.pl(ci, o, s, [Vector2(-22.4 + hem, -22), Vector2(22.4 + hem, -22), Vector2(23 + hem, -18), Vector2(-23 + hem, -18)], lt)
			for x in range(-18, 19, 9):
				K.dot(ci, o, s, Vector2(float(x) + hem, -20), 1.2, gold)
			K.pl(ci, o, s, [Vector2(f * 3, -74), Vector2(f * 9, -74), Vector2(f * 7, -44), Vector2(f * 1, -44)], dk)
			K.ln(ci, o, s, Vector2(f * 3, -74), Vector2(f * 1, -44), K.c(lt, 0.8), 1.0)
			K.rc(ci, o, s, Vector2(-17, -52), Vector2(34, 6), gold)
			K.stitch(ci, o, s, Vector2(-16, -49), Vector2(16, -49), dk, 7)
			K.pl(ci, o, s, [Vector2(-f * 14, -48), Vector2(-f * 20, -34 + sway), Vector2(-f * 16, -30 + sway), Vector2(-f * 11, -46)], gold)
			K.bead(ci, o, s, Vector2(-f * 13, -49), 3.0, gold)
			K.lantern(ci, o + Vector2(-f * 4, -32) * s, s, gold, dk)
		_:
			K.part(ci, o, s, [Vector2(-f * 8, -52), Vector2(-f * 8, -36), Vector2(-f * (24.0 + run), -28 + sway)], dk)
			K.part(ci, o, s, torso, m)
			K.ln(ci, o, s, Vector2(f * 3 - 1.5, -74), Vector2(f * 3 - 1.5, -41), dk, 1.0)
			K.ln(ci, o, s, Vector2(f * 3, -74), Vector2(f * 3, -41), lt, 3.0)
			K.pl(ci, o, s, [Vector2(f * 2, -68), Vector2(f * 4, -68), Vector2(f * 4, -62), Vector2(f * 2, -62)], gold)
			K.ln(ci, o, s, Vector2(-f * 12, -72), Vector2(-f * 10, -44), lt, 1.5)
			K.ln(ci, o, s, Vector2(-f * 14, -72), Vector2(-f * 12, -44), K.c(dk, 0.6), 1.0)
			K.pl(ci, o, s, [Vector2(f * 6, -52), Vector2(f * 14, -52), Vector2(f * 13, -46), Vector2(f * 7, -46)], dk)
			K.stitch(ci, o, s, Vector2(f * 6, -51), Vector2(f * 14, -51), lt, 3)
			K.pl(ci, o, s, [Vector2(-f * 2, -77), Vector2(f * 10, -77), Vector2(f * 9, -72), Vector2(-f * 1, -72)], lt)
			K.rc(ci, o, s, Vector2(-13, -45), Vector2(26, 4), gold)
			K.ln(ci, o, s, Vector2(-12.5, -42), Vector2(12.5, -42), K.c(dk, 0.8), 1.0)
	D.side(ci, st, o, s, f, sway, outfit, tw, alpha)


## Front-view outfit body for the portrait. `o` = feet origin (bob already applied),
## `s` = portrait scale k, `tw` = seconds for twinkles and cloth sway.
static func draw_front(ci: CanvasItem, style: String, o: Vector2, s: float, outfit: Color, tw: float, alpha: float) -> void:
	var st: String = _norm(style)
	if st in ["hanbok", "tailcoat", "cape", "galaxy"]:
		B.draw_front(ci, st, o, s, outfit, tw, alpha)
		D.front(ci, st, o, s, outfit, tw, alpha)
		return
	var lt: Color = K.c(outfit.lerp(Color.WHITE, 0.4), alpha)
	var dk: Color = K.c(outfit.lerp(K.INK, 0.45), alpha)
	var m: Color = K.c(outfit, alpha)
	var gold: Color = K.c(K.GOLD, alpha)
	var wh: Color = K.c(Color.WHITE, alpha)
	var sw: float = sin(tw * 2.0) * 2.0
	var torso: Array = K.TORSO_F
	match st:
		"sequin":
			K.part(ci, o, s, torso, m)
			K.pl(ci, o, s, [Vector2(-22, -30), Vector2(22, -30), Vector2(27, -20), Vector2(-27, -20)], lt)
			K.stitch(ci, o, s, Vector2(-24, -25), Vector2(24, -25), K.c(gold, 0.8), 9)
			K.pl(ci, o, s, [Vector2(-9, -52), Vector2(9, -52), Vector2(0, -38)], dk)
			K.ln(ci, o, s, Vector2(-9, -52), Vector2(0, -38), gold, 1.6)
			K.ln(ci, o, s, Vector2(9, -52), Vector2(0, -38), gold, 1.6)
			K.star(ci, o, s, Vector2(-26, -51), 9.0, gold)
			K.star(ci, o, s, Vector2(26, -51), 9.0, gold)
			for p in [Vector2(-14, -44), Vector2(13, -41), Vector2(-5, -33), Vector2(8, -48), Vector2(-17, -26), Vector2(16, -25)]:
				K.glint(ci, o, s, p, 4.5, tw * 3.0, p.x * 0.7, wh)
			for p in [Vector2(-19, -40), Vector2(-9, -47), Vector2(0, -30), Vector2(6, -38), Vector2(18, -35), Vector2(-12, -34), Vector2(14, -46), Vector2(2, -45)]:
				K.dot(ci, o, s, p, 1.5, K.c(gold, 0.9))
				K.dot(ci, o, s, p + Vector2(-0.5, -0.5), 0.6, wh)
			K.glint(ci, o, s, Vector2(-1, -48), 2.6, tw * 3.0, 3.0, wh)
			K.rc(ci, o, s, Vector2(-23, -32), Vector2(46, 3), gold)
		"armor":
			K.part(ci, o, s, torso, dk)
			K.part(ci, o, s, [Vector2(-22, -50), Vector2(-1.5, -50), Vector2(-1.5, -33), Vector2(-17, -33)], m)
			K.part(ci, o, s, [Vector2(1.5, -50), Vector2(22, -50), Vector2(17, -33), Vector2(1.5, -33)], m, 1.0)
			K.ln(ci, o, s, Vector2(-18, -42), Vector2(-3, -42), lt, 1.8)
			K.ln(ci, o, s, Vector2(3, -42), Vector2(18, -42), lt, 1.8)
			K.ln(ci, o, s, Vector2(-21, -49), Vector2(-2.5, -49), wh, 1.0)
			K.ln(ci, o, s, Vector2(2.5, -49), Vector2(21, -49), wh, 1.0)
			for p in [Vector2(-19, -47), Vector2(19, -47), Vector2(-5, -36), Vector2(5, -36)]:
				K.bead(ci, o, s, p, 1.5, gold)
			K.rc(ci, o, s, Vector2(-21, -32), Vector2(42, 6), dk)
			K.stitch(ci, o, s, Vector2(-20, -29), Vector2(-6, -29), lt, 4)
			K.stitch(ci, o, s, Vector2(6, -29), Vector2(20, -29), lt, 4)
			K.bead(ci, o, s, Vector2(0, -29), 4.2, gold)
			K.bead(ci, o, s, Vector2(0, -29), 1.8, dk)
			K.part(ci, o, s, [Vector2(-21, -26), Vector2(-3, -26), Vector2(-5, -17), Vector2(-19, -17)], m)
			K.part(ci, o, s, [Vector2(3, -26), Vector2(21, -26), Vector2(19, -17), Vector2(5, -17)], m, 1.0)
			for side in [-1.0, 1.0]:
				var pc := Vector2(side * 27, -50)
				K.part(ci, o, s, K.ell(pc, 12.0, 8.0), m, side)
				FD.arc(ci, o + pc * s, 10.0 * s, PI, TAU, 10, lt, maxf(1.0, 2.0 * s))
				K.bead(ci, o, s, pc + Vector2(0, 1), 2.0, gold)
		"robe":
			K.part(ci, o, s, [Vector2(-27, -52), Vector2(27, -52), Vector2(24, -22), Vector2(34 + sw, 0), Vector2(-34 + sw, 0), Vector2(-24, -22)], m)
			for x in [-14.0, 14.0]:
				K.ln(ci, o, s, Vector2(x * 1.4, -22), Vector2(x * 2.0 + sw, -6), K.c(K.INK, 0.22 * alpha), 1.6)
			K.pl(ci, o, s, [Vector2(-33.6 + sw, -5), Vector2(33.6 + sw, -5), Vector2(34 + sw, 0), Vector2(-34 + sw, 0)], lt)
			for x in range(-28, 29, 8):
				K.dot(ci, o, s, Vector2(float(x) + sw, -2.5), 1.4, gold)
			K.pl(ci, o, s, [Vector2(-10, -52), Vector2(-4, -52), Vector2(8, -30), Vector2(2, -30)], dk)
			K.pl(ci, o, s, [Vector2(10, -52), Vector2(4, -52), Vector2(-8, -30), Vector2(-2, -30)], dk)
			K.ln(ci, o, s, Vector2(-10, -52), Vector2(2, -30), gold, 1.0)
			K.ln(ci, o, s, Vector2(10, -52), Vector2(-2, -30), gold, 1.0)
			K.rc(ci, o, s, Vector2(-25, -32), Vector2(50, 8), gold)
			K.stitch(ci, o, s, Vector2(-24, -28), Vector2(24, -28), dk, 9)
			K.pl(ci, o, s, [Vector2(0, -28), Vector2(-7, -14 + sw * 0.5), Vector2(-3, -12 + sw * 0.5)], gold)
			K.pl(ci, o, s, [Vector2(0, -28), Vector2(7, -16 + sw * 0.5), Vector2(3, -13 + sw * 0.5)], gold)
			K.bead(ci, o, s, Vector2(0, -28), 3.4, gold)
			K.lantern(ci, o + Vector2(-17, -14) * s, s * 1.2, gold, dk)
			K.lantern(ci, o + Vector2(17, -14) * s, s * 1.2, gold, dk)
		_:
			K.part(ci, o, s, torso, m)
			K.pl(ci, o, s, [Vector2(-12, -53), Vector2(-1, -53), Vector2(-2, -46), Vector2(-9, -47)], lt)
			K.pl(ci, o, s, [Vector2(12, -53), Vector2(1, -53), Vector2(2, -46), Vector2(9, -47)], lt)
			K.ln(ci, o, s, Vector2(-1.5, -52), Vector2(-1.5, -22), dk, 1.0)
			K.ln(ci, o, s, Vector2(0, -52), Vector2(0, -22), lt, 3.0)
			K.pl(ci, o, s, [Vector2(-1.5, -50), Vector2(1.5, -50), Vector2(1.5, -43), Vector2(-1.5, -43)], gold)
			K.ln(ci, o, s, Vector2(-22, -50), Vector2(-18, -24), lt, 2.5)
			K.ln(ci, o, s, Vector2(22, -50), Vector2(18, -24), lt, 2.5)
			K.ln(ci, o, s, Vector2(-24.5, -50), Vector2(-20.5, -24), K.c(dk, 0.7), 1.0)
			K.ln(ci, o, s, Vector2(24.5, -50), Vector2(20.5, -24), K.c(dk, 0.7), 1.0)
			K.pl(ci, o, s, [Vector2(-17, -40), Vector2(-7, -40), Vector2(-8, -33), Vector2(-16, -33)], dk)
			K.pl(ci, o, s, [Vector2(17, -40), Vector2(7, -40), Vector2(8, -33), Vector2(16, -33)], dk)
			K.stitch(ci, o, s, Vector2(-16.5, -39), Vector2(-7.5, -39), lt, 3)
			K.stitch(ci, o, s, Vector2(16.5, -39), Vector2(7.5, -39), lt, 3)
			K.rc(ci, o, s, Vector2(-21, -29), Vector2(42, 5), gold)
			K.ln(ci, o, s, Vector2(-20, -23), Vector2(20, -23), K.c(dk, 0.8), 1.0)
	D.front(ci, st, o, s, outfit, tw, alpha)
