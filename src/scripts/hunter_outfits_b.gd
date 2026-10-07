extends RefCounted
## Second half of the hunter outfits (Story 015): hanbok, tailcoat, cape and galaxy, side
## and front views. Called from hunter_outfits.gd; same footprint and animation inputs.

const K := preload("res://scripts/hunter_outfit_kit.gd")


## Side view of hanbok / tailcoat / cape / galaxy (anything else is ignored).
static func draw_side(ci: CanvasItem, style: String, o: Vector2, s: float, f: float, sway: float, moving: bool, outfit: Color, tw: float, alpha: float) -> void:
	var lt: Color = K.c(outfit.lerp(Color.WHITE, 0.4), alpha)
	var dk: Color = K.c(outfit.lerp(K.INK, 0.45), alpha)
	var m: Color = K.c(outfit, alpha)
	var gold: Color = K.c(K.GOLD, alpha)
	var wh: Color = K.c(Color.WHITE, alpha)
	var ik: Color = K.c(K.INK, alpha)
	var run: float = 8.0 if moving else 0.0
	var torso: Array = [Vector2(-17, -74), Vector2(17, -74), Vector2(13, -40), Vector2(-13, -40)]
	match style:
		"hanbok":
			var sk: Color = K.c(outfit.lerp(Color.WHITE, 0.18), alpha)
			var sw: float = -f * sway * 0.6
			K.part(ci, o, s, [Vector2(-12, -54), Vector2(12, -54), Vector2(20 + sw, -17), Vector2(-20 + sw, -17)], sk)
			K.ln(ci, o, s, Vector2(-5, -54), Vector2(-9 + sw, -17), dk, 1.3)
			K.ln(ci, o, s, Vector2(5, -54), Vector2(9 + sw, -17), dk, 1.3)
			K.ln(ci, o, s, Vector2(0, -54), Vector2(sw, -17), K.c(lt, 0.7), 1.2)
			K.pl(ci, o, s, [Vector2(-19.2 + sw, -21), Vector2(19.2 + sw, -21), Vector2(20 + sw, -17), Vector2(-20 + sw, -17)], lt)
			for x in [-12.0, -4.0, 4.0, 12.0]:
				K.dot(ci, o, s, Vector2(x + sw, -19), 1.0, dk)
			K.part(ci, o, s, [Vector2(-16, -74), Vector2(16, -74), Vector2(14, -54), Vector2(-14, -54)], m)
			K.stitch(ci, o, s, Vector2(-f * 12, -72), Vector2(-f * 11, -56), lt, 4)
			K.pl(ci, o, s, [Vector2(f * 2, -74), Vector2(f * 9, -74), Vector2(f * 3, -58)], lt)
			K.ln(ci, o, s, Vector2(f * 9, -74), Vector2(f * 3, -58), dk, 1.2)
			K.ln(ci, o, s, Vector2(f * 5.5, -74), Vector2(f * 1, -62), K.c(dk, 0.7), 1.0)
			K.rc(ci, o, s, Vector2(-14, -58), Vector2(28, 3), dk)
			var pk: Color = K.c(K.PINK, alpha)
			K.pl(ci, o, s, [Vector2(f * 2, -62), Vector2(-f * 8, -68 + sway * 0.5), Vector2(-f * 8, -57 + sway * 0.5)], pk)
			K.pl(ci, o, s, [Vector2(f * 2, -62), Vector2(f * 1, -58), Vector2(-f * 8, -50 + sway), Vector2(-f * 9, -54 + sway)], pk)
			K.bead(ci, o, s, Vector2(f * 2, -60.5), 2.2, pk)
		"tailcoat":
			var tl: float = 28.0 + run
			K.part(ci, o, s, [Vector2(-f * 6, -54), Vector2(-f * 10, -34), Vector2(-f * tl, -20 + sway), Vector2(-f * (tl - 8), -38 + sway * 0.5)], dk)
			K.pl(ci, o, s, [Vector2(-f * 8, -54), Vector2(-f * 8, -30), Vector2(-f * (tl - 6), -23 + sway)], m)
			K.ln(ci, o, s, Vector2(-f * 9, -44), Vector2(-f * (tl - 8), -26 + sway * 0.9), K.c(lt, 0.6), 1.0)
			K.part(ci, o, s, torso, m)
			K.pl(ci, o, s, [Vector2(f * 3, -74), Vector2(f * 12, -74), Vector2(f * 2, -52)], dk)
			K.ln(ci, o, s, Vector2(f * 12, -74), Vector2(f * 2, -52), lt, 1.8)
			K.pl(ci, o, s, [Vector2(-f * 2, -77), Vector2(f * 5, -77), Vector2(f * 5, -73), Vector2(-f * 2, -73)], dk)
			K.pl(ci, o, s, [Vector2(-f * 4, -60), Vector2(-f * 10, -60), Vector2(-f * 7, -65)], wh)
			K.ln(ci, o, s, Vector2(-13, -41), Vector2(13, -41), gold, 2.0)
			K.stitch(ci, o, s, Vector2(-f * 13, -72), Vector2(-f * 12, -44), lt, 4)
			for y in [-62.0, -54.0, -46.0]:
				K.bead(ci, o, s, Vector2(f * 1, y), 1.9, ik)
		"cape":
			var cl: float = 26.0 + run
			var e0 := Vector2(-f * (cl - 4), -22 + sway)
			var e1 := Vector2(-f * (cl + 6), -34 + sway * 1.4)
			K.part(ci, o, s, [Vector2(-f * 4, -76), Vector2(f * 4, -74), e0, e1], dk)
			K.ln(ci, o, s, Vector2(-f * 5, -70), Vector2(-f * (cl - 2), -30 + sway), lt, 1.5)
			K.ln(ci, o, s, Vector2(-f * 5, -62), Vector2(-f * (cl + 3), -33 + sway * 1.3), K.c(K.INK, 0.35 * alpha), 1.2)
			K.ln(ci, o, s, e0, e1, gold, 1.5)
			K.part(ci, o, s, torso, m)
			K.ln(ci, o, s, Vector2(f * 3, -74), Vector2(f * 3, -41), lt, 3.0)
			K.rc(ci, o, s, Vector2(-13, -45), Vector2(26, 4), gold)
			K.stitch(ci, o, s, Vector2(-12, -43), Vector2(12, -43), dk, 6)
			K.bead(ci, o, s, Vector2(f * 2, -74), 3.5, gold)
			K.bead(ci, o, s, Vector2(f * 2, -74), 1.5, K.c(K.PINK, alpha))
		_:
			var sp: Color = K.c(outfit.lerp(K.INK, 0.7), alpha)
			K.part(ci, o, s, [Vector2(-f * 8, -52), Vector2(-f * 8, -38), Vector2(-f * (18.0 + run), -34 + sway)], K.c(outfit.lerp(K.INK, 0.85), alpha))
			K.part(ci, o, s, torso, sp)
			K.flat(ci, o, s, K.ell(Vector2(-6, -60), 9.0, 6.0), K.c(outfit, alpha * 0.16))
			K.flat(ci, o, s, K.ell(Vector2(7, -48), 7.0, 5.0), K.c(lt, alpha * 0.14))
			K.ln(ci, o, s, Vector2(-16, -73), Vector2(16, -73), K.c(lt, 0.7), 1.2)
			K.ln(ci, o, s, Vector2(-f * 13, -70), Vector2(-f * 11, -44), K.c(outfit, alpha * 0.5), 1.0)
			var pts: Array = [Vector2(-8, -68), Vector2(0, -60), Vector2(8, -64), Vector2(5, -52), Vector2(-4, -48)]
			for i in range(pts.size() - 1):
				K.ln(ci, o, s, pts[i], pts[i + 1], K.c(outfit, alpha * 0.3), 3.0)
				K.ln(ci, o, s, pts[i], pts[i + 1], K.c(outfit, alpha * 0.85), 1.2)
			for p in pts:
				K.dot(ci, o, s, p, 3.4, K.c(outfit, alpha * 0.3))
				K.dot(ci, o, s, p, 1.8, wh)
			K.glint(ci, o, s, Vector2(10, -48), 4.0, tw, 0.0, lt)
			K.glint(ci, o, s, Vector2(-11, -58), 3.0, tw, 2.0, gold)
			K.glint(ci, o, s, Vector2(3, -70), 2.4, tw, 4.0, wh)
			K.rc(ci, o, s, Vector2(-13, -42), Vector2(26, 3), m)


## Front view of hanbok / tailcoat / cape / galaxy (anything else is ignored).
static func draw_front(ci: CanvasItem, style: String, o: Vector2, s: float, outfit: Color, tw: float, alpha: float) -> void:
	var lt: Color = K.c(outfit.lerp(Color.WHITE, 0.4), alpha)
	var dk: Color = K.c(outfit.lerp(K.INK, 0.45), alpha)
	var m: Color = K.c(outfit, alpha)
	var gold: Color = K.c(K.GOLD, alpha)
	var wh: Color = K.c(Color.WHITE, alpha)
	var ik: Color = K.c(K.INK, alpha)
	var sw: float = sin(tw * 2.0) * 2.0
	var torso: Array = [Vector2(-27, -52), Vector2(27, -52), Vector2(21, -22), Vector2(-21, -22)]
	match style:
		"hanbok":
			var sk: Color = K.c(outfit.lerp(Color.WHITE, 0.18), alpha)
			var pk: Color = K.c(K.PINK, alpha)
			K.part(ci, o, s, [Vector2(-21, -32), Vector2(21, -32), Vector2(36 + sw, 0), Vector2(-36 + sw, 0)], sk)
			for x in [-12.0, -4.0, 4.0, 12.0]:
				K.ln(ci, o, s, Vector2(x * 0.7, -32), Vector2(x * 1.6 + sw, 0), dk, 1.2)
			for x in [-8.0, 0.0, 8.0]:
				K.ln(ci, o, s, Vector2(x * 0.7, -32), Vector2(x * 1.6 + sw, 0), K.c(lt, 0.6), 1.0)
			K.pl(ci, o, s, [Vector2(-34.5 + sw, -5), Vector2(34.5 + sw, -5), Vector2(36 + sw, 0), Vector2(-36 + sw, 0)], lt)
			for x in range(-30, 31, 10):
				K.dot(ci, o, s, Vector2(float(x) + sw, -2.5), 1.3, dk)
			K.part(ci, o, s, [Vector2(-27, -52), Vector2(27, -52), Vector2(23, -32), Vector2(-23, -32)], m)
			K.pl(ci, o, s, [Vector2(-12, -52), Vector2(-3, -52), Vector2(12, -36), Vector2(3, -36)], lt)
			K.pl(ci, o, s, [Vector2(12, -52), Vector2(3, -52), Vector2(-12, -36), Vector2(-3, -36)], lt)
			K.ln(ci, o, s, Vector2(-12, -52), Vector2(3, -36), dk, 1.2)
			K.ln(ci, o, s, Vector2(12, -52), Vector2(-3, -36), dk, 1.2)
			K.stitch(ci, o, s, Vector2(-25, -50), Vector2(-22, -37), lt, 4)
			K.stitch(ci, o, s, Vector2(25, -50), Vector2(22, -37), lt, 4)
			K.rc(ci, o, s, Vector2(-23, -36), Vector2(46, 4), dk)
			K.pl(ci, o, s, [Vector2(0, -41), Vector2(-14, -49), Vector2(-14, -35)], pk)
			K.pl(ci, o, s, [Vector2(0, -41), Vector2(14, -49), Vector2(14, -35)], pk)
			K.pl(ci, o, s, [Vector2(-2, -40), Vector2(-7, -22 + sw * 0.5), Vector2(-3, -22 + sw * 0.5)], pk)
			K.pl(ci, o, s, [Vector2(2, -40), Vector2(7, -22 + sw * 0.5), Vector2(3, -22 + sw * 0.5)], pk)
			K.bead(ci, o, s, Vector2(0, -41), 3.2, gold)
		"tailcoat":
			K.part(ci, o, s, [Vector2(-21, -26), Vector2(-3, -26), Vector2(-5 + sw * 0.3, -2), Vector2(-27 + sw * 0.3, -4)], dk)
			K.part(ci, o, s, [Vector2(3, -26), Vector2(21, -26), Vector2(27 + sw * 0.3, -4), Vector2(5 + sw * 0.3, -2)], dk)
			K.ln(ci, o, s, Vector2(-24 + sw * 0.3, -4), Vector2(-5 + sw * 0.3, -2), gold, 1.5)
			K.ln(ci, o, s, Vector2(24 + sw * 0.3, -4), Vector2(5 + sw * 0.3, -2), gold, 1.5)
			K.part(ci, o, s, torso, m)
			K.pl(ci, o, s, [Vector2(-5, -52), Vector2(5, -52), Vector2(0, -38)], wh)
			K.part(ci, o, s, [Vector2(-27, -52), Vector2(-9, -52), Vector2(2, -26), Vector2(-9, -24), Vector2(-21, -22)], dk)
			K.part(ci, o, s, [Vector2(27, -52), Vector2(9, -52), Vector2(-2, -26), Vector2(9, -24), Vector2(21, -22)], dk, 1.0)
			K.ln(ci, o, s, Vector2(-9, -52), Vector2(2, -26), lt, 2.0)
			K.ln(ci, o, s, Vector2(9, -52), Vector2(-2, -26), lt, 2.0)
			K.stitch(ci, o, s, Vector2(-24, -50), Vector2(-14, -28), lt, 5)
			K.stitch(ci, o, s, Vector2(24, -50), Vector2(14, -28), lt, 5)
			K.pl(ci, o, s, [Vector2(13, -40), Vector2(21, -40), Vector2(19, -45), Vector2(17, -43), Vector2(15, -45)], wh)
			for y in [-42.0, -34.0]:
				K.bead(ci, o, s, Vector2(0, y), 2.4, ik)
			K.ln(ci, o, s, Vector2(-21, -22), Vector2(21, -22), gold, 2.5)
		"cape":
			K.part(ci, o, s, [Vector2(-27, -54), Vector2(27, -54), Vector2(42 + sw, -6), Vector2(-42 + sw, -6)], dk)
			for x in [-20.0, -9.0, 9.0, 20.0]:
				K.ln(ci, o, s, Vector2(x * 0.8, -50), Vector2(x * 1.8 + sw, -8), K.c(K.INK, 0.3 * alpha), 1.4)
			K.ln(ci, o, s, Vector2(-34 + sw * 0.5, -8), Vector2(34 + sw * 0.5, -8), gold, 2.0)
			K.part(ci, o, s, torso, m)
			K.ln(ci, o, s, Vector2(0, -52), Vector2(0, -22), lt, 3.0)
			K.stitch(ci, o, s, Vector2(-24, -48), Vector2(-19, -24), lt, 5)
			K.stitch(ci, o, s, Vector2(24, -48), Vector2(19, -24), lt, 5)
			K.rc(ci, o, s, Vector2(-21, -29), Vector2(42, 5), gold)
			K.bead(ci, o, s, Vector2(0, -26.5), 3.0, m)
			K.ln(ci, o, s, Vector2(-24, -51), Vector2(24, -51), gold, 2.0)
			K.ln(ci, o, s, Vector2(-24, -48), Vector2(0, -45), K.c(gold, 0.7), 1.0)
			K.ln(ci, o, s, Vector2(24, -48), Vector2(0, -45), K.c(gold, 0.7), 1.0)
			K.bead(ci, o, s, Vector2(-24, -51), 4.0, gold)
			K.bead(ci, o, s, Vector2(24, -51), 4.0, gold)
		_:
			K.part(ci, o, s, torso, K.c(outfit.lerp(K.INK, 0.7), alpha))
			K.flat(ci, o, s, K.ell(Vector2(-10, -40), 14.0, 8.0), K.c(outfit, alpha * 0.16))
			K.flat(ci, o, s, K.ell(Vector2(12, -34), 11.0, 7.0), K.c(lt, alpha * 0.13))
			K.ln(ci, o, s, Vector2(-26, -51), Vector2(26, -51), K.c(lt, 0.7), 1.4)
			K.ln(ci, o, s, Vector2(-20, -50), Vector2(-17, -24), K.c(outfit, alpha * 0.45), 1.2)
			K.ln(ci, o, s, Vector2(20, -50), Vector2(17, -24), K.c(outfit, alpha * 0.45), 1.2)
			var pts: Array = [Vector2(-18, -46), Vector2(-8, -38), Vector2(4, -44), Vector2(14, -34), Vector2(8, -26)]
			for i in range(pts.size() - 1):
				K.ln(ci, o, s, pts[i], pts[i + 1], K.c(outfit, alpha * 0.3), 4.0)
				K.ln(ci, o, s, pts[i], pts[i + 1], K.c(outfit, alpha * 0.85), 1.4)
			for p in pts:
				K.dot(ci, o, s, p, 4.4, K.c(outfit, alpha * 0.3))
				K.dot(ci, o, s, p, 2.2, wh)
			K.glint(ci, o, s, Vector2(18, -46), 6.0, tw * 3.0, 0.0, lt)
			K.glint(ci, o, s, Vector2(-16, -30), 5.0, tw * 3.0, 2.0, gold)
			K.glint(ci, o, s, Vector2(2, -52), 4.0, tw * 3.0, 4.0, wh)
			K.glint(ci, o, s, Vector2(-6, -26), 3.0, tw * 3.0, 1.0, wh)
			K.rc(ci, o, s, Vector2(-21, -27), Vector2(42, 4), m)
