extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Costume detail pass for the idol hunter outfits (Story 032): shoulder caps, collars,
## skirt/coat flare, pockets, trims, embroidery, chains and a cel sheen drawn after the base
## garment of hunter_outfits.gd / hunter_outfits_b.gd. Figure units, same origin and scale as
## those files. All polygons are simple.

const K := preload("res://scripts/hunter_outfit_kit.gd")


static func _scallop(x0: float, x1: float, y_top: float, y_bot: float, flare: float, n: int, dip: float) -> Array:
	var pts: Array = [Vector2(x0 + 1.0, y_top), Vector2(x1 - 1.0, y_top), Vector2(x1 + flare, y_bot - dip)]
	for i in range(n, -1, -1):
		var t: float = float(i) / float(n)
		pts.append(Vector2(lerpf(x0 - flare, x1 + flare, t), y_bot + (dip if i % 2 == 0 else 0.0) - dip * 0.5))
	return pts


## Front-view detail for `style`; `outfit` is the main colour, `tw` seconds for twinkles.
static func front(ci: CanvasItem, style: String, o: Vector2, s: float, outfit: Color, tw: float, alpha: float) -> void:
	var lt: Color = K.c(outfit.lerp(Color.WHITE, 0.45), alpha)
	var dk: Color = K.c(outfit.lerp(K.INK, 0.45), alpha)
	var m: Color = K.c(outfit, alpha)
	var gold: Color = K.c(K.GOLD, alpha)
	var wh: Color = K.c(Color.WHITE, alpha)
	var sw: float = sin(tw * 2.0) * 2.0
	var long_skirt: bool = style in ["robe", "hanbok", "cape"]
	if not long_skirt:
		K.sheen(ci, o, s, K.TORSO_F, alpha)
	for sd in [-1.0, 1.0]:
		K.ln(ci, o, s, Vector2(sd * 27.0, -44.0), Vector2(sd * 19.8, -27.0), K.c(lt, 0.7), 1.1)
		if style != "armor":
			K.part(ci, o, s, K.ell(Vector2(sd * 25.5, -47.5), 5.5, 6.5), m)
			K.ln(ci, o, s, Vector2(sd * 22.0, -51.5), Vector2(sd * 28.0, -49.0), K.c(wh, 0.5), 1.0)
	match style:
		"sequin":
			K.part(ci, o, s, _scallop(-21.0, 21.0, -26.0, -9.0, 8.0, 8, 3.0), dk)
			K.part(ci, o, s, _scallop(-19.0, 19.0, -26.0, -14.0, 6.0, 6, 2.5), m)
			for i in range(7):
				var x: float = -21.0 + float(i) * 7.0
				K.dot(ci, o, s, Vector2(x, -17.0 + (i % 2) * 3.0), 1.1, gold)
				K.dot(ci, o, s, Vector2(x + 0.6, -17.6 + (i % 2) * 3.0), 0.4, wh)
			K.glint(ci, o, s, Vector2(-14, -15), 3.5, tw * 3.0, 1.0, wh)
			K.glint(ci, o, s, Vector2(13, -18), 3.0, tw * 3.0, 2.5, wh)
			K.rc(ci, o, s, Vector2(-21, -29), Vector2(42, 4), gold)
		"armor":
			K.pl(ci, o, s, [Vector2(-10, -54), Vector2(10, -54), Vector2(7, -48.5), Vector2(-7, -48.5)], K.c(outfit.lerp(Color.WHITE, 0.25), alpha))
			K.star(ci, o, s, Vector2(0, -41.5), 5.5, gold)
			K.bead(ci, o, s, Vector2(0, -41.5), 1.6, dk)
		"robe":
			for row in range(2):
				for i in range(8):
					var cx: float = -30.0 + float(i) * 8.6 + (4.3 if row == 1 else 0.0) + sw
					FD.arc(ci, o + Vector2(cx, -15.0 + float(row) * 5.0) * s, 4.4 * s, PI, TAU, 8, K.c(gold, 0.85), maxf(1.0, 0.9 * s))
			K.ln(ci, o, s, Vector2(-9, -53.5), Vector2(0, -50), K.c(lt, 0.8), 1.2)
			K.ln(ci, o, s, Vector2(9, -53.5), Vector2(0, -50), K.c(lt, 0.8), 1.2)
		"hanbok":
			for i in range(4):
				var fx: float = -24.0 + float(i) * 16.0 + sw
				for j in range(5):
					var a: float = TAU * float(j) / 5.0
					K.dot(ci, o, s, Vector2(fx, -17.0) + Vector2(cos(a), sin(a)) * 2.1, 1.3, K.c(K.PINK, alpha))
				K.dot(ci, o, s, Vector2(fx, -17.0), 1.1, gold)
			K.ln(ci, o, s, Vector2(-23, -33), Vector2(23, -33), K.c(wh, 0.6), 1.2)
		"tailcoat":
			for sd in [-1.0, 1.0]:
				K.rc(ci, o, s, Vector2(sd * 24.0 - 5.0, -54.5), Vector2(10, 3.2), gold)
				for j in range(4):
					K.ln(ci, o, s, Vector2(sd * 24.0 - 3.6 + float(j) * 2.4, -51.3), Vector2(sd * 24.0 - 3.6 + float(j) * 2.4, -47.8), gold, 0.9)
			K.pl(ci, o, s, [Vector2(-21, -36), Vector2(-12, -36), Vector2(-12.5, -31), Vector2(-20.5, -31)], dk)
			K.ln(ci, o, s, Vector2(-21, -35), Vector2(-12, -35), gold, 0.9)
			var chain := PackedVector2Array()
			for i in range(7):
				var t: float = float(i) / 6.0
				chain.append(o + Vector2(lerpf(-8.0, 8.0, t), -36.0 + sin(t * PI) * 4.0) * s)
			FD.polyline(ci, chain, gold, maxf(1.0, 0.9 * s))
			K.part(ci, o, s, K.ell(Vector2(0, -53), 9.5, 3.4), dk)
		"cape":
			for i in range(11):
				var x: float = -25.0 + float(i) * 5.0
				K.dot(ci, o, s, Vector2(x, -51.0 + sin(float(i) / 10.0 * PI) * 2.0), 3.0, wh)
				K.dot(ci, o, s, Vector2(x - 0.6, -51.8 + sin(float(i) / 10.0 * PI) * 2.0), 1.1, K.c(lt, 0.7))
			var ch := PackedVector2Array()
			for i in range(9):
				var t: float = float(i) / 8.0
				ch.append(o + Vector2(lerpf(-24.0, 24.0, t), -50.0 + sin(t * PI) * 7.0) * s)
			FD.polyline(ci, ch, gold, maxf(1.0, 1.1 * s))
			for x in [-30.0, -16.0, 16.0, 30.0]:
				K.dot(ci, o, s, Vector2(x * 1.15 + sw, -12.0), 1.4, gold)
		"galaxy":
			K.flat(ci, o, s, K.ell(Vector2(8, -42), 16.0, 9.0), K.c(Color("#B58CFF"), alpha * 0.28))
			K.flat(ci, o, s, K.ell(Vector2(-10, -32), 12.0, 7.0), K.c(Color("#FF5FA2"), alpha * 0.22))
			K.star(ci, o, s, Vector2(0, -26.5), 4.2, gold)
			K.ln(ci, o, s, Vector2(-24, -48), Vector2(24, -30), K.c(gold, 0.6), 1.0)
			K.part(ci, o, s, K.ell(Vector2(0, -53), 9.5, 3.4), dk)
		_:
			K.part(ci, o, s, [Vector2(-22, -25), Vector2(22, -25), Vector2(27, -15), Vector2(14, -12.5), Vector2(0, -14.5), Vector2(-14, -12.5), Vector2(-27, -15)], dk)
			K.ln(ci, o, s, Vector2(-25, -17), Vector2(25, -17), lt, 1.4)
			K.stitch(ci, o, s, Vector2(-24, -14.5), Vector2(24, -14.5), K.c(wh, 0.7), 8)
			K.part(ci, o, s, K.ell(Vector2(0, -53), 10.0, 3.6), lt)
			K.lantern(ci, o + Vector2(14.5, -44.0) * s, s * 0.55, gold, dk)
			K.bead(ci, o, s, Vector2(0, -47), 1.2, gold)
			K.rc(ci, o, s, Vector2(-21, -29), Vector2(42, 5), gold)
			K.bead(ci, o, s, Vector2(0, -26.5), 2.4, K.c(K.PINK, alpha))


## Side-view detail for `style`; `f` facing, `sway` cloth sway.
static func side(ci: CanvasItem, style: String, o: Vector2, s: float, f: float, sway: float, outfit: Color, tw: float, alpha: float) -> void:
	var lt: Color = K.c(outfit.lerp(Color.WHITE, 0.45), alpha)
	var dk: Color = K.c(outfit.lerp(K.INK, 0.45), alpha)
	var m: Color = K.c(outfit, alpha)
	var gold: Color = K.c(K.GOLD, alpha)
	var wh: Color = K.c(Color.WHITE, alpha)
	if style != "robe" and style != "hanbok":
		K.sheen(ci, o, s, K.TORSO_S, alpha)
	K.part(ci, o, s, K.ell(Vector2(f * 1.0, -75.0), 8.0, 2.8), lt if style != "galaxy" else dk)
	K.ln(ci, o, s, Vector2(-f * 15.5, -68.0), Vector2(-f * 11.5, -46.0), K.c(lt, 0.6), 1.0)
	match style:
		"sequin":
			K.part(ci, o, s, _scallop(-12.0, 12.0, -41.0, -29.0, 6.0, 6, 2.5), dk)
			K.part(ci, o, s, _scallop(-11.0, 11.0, -41.0, -34.0, 4.0, 5, 2.0), m)
			for i in range(5):
				K.dot(ci, o, s, Vector2(-10.0 + float(i) * 5.0, -33.0 + (i % 2) * 2.0), 0.9, gold)
		"armor":
			K.pl(ci, o, s, [Vector2(f * 2, -40), Vector2(f * 13, -40), Vector2(f * 12, -32), Vector2(f * 3, -32)], dk)
			K.ln(ci, o, s, Vector2(f * 2.5, -37), Vector2(f * 12.5, -37), lt, 1.0)
			K.star(ci, o, s, Vector2(f * 5, -60), 3.2, gold)
		"tailcoat":
			K.rc(ci, o, s, Vector2(-f * 4 - 4, -75.5), Vector2(8, 2.4), gold)
			K.ln(ci, o, s, Vector2(f * 3, -41), Vector2(f * 8, -36), gold, 1.0)
		"cape":
			for i in range(5):
				K.dot(ci, o, s, Vector2(-f * 9.0 + f * float(i) * 4.0, -74.0), 2.4, wh)
		"galaxy":
			K.flat(ci, o, s, K.ell(Vector2(3, -56), 10.0, 7.0), K.c(Color("#B58CFF"), alpha * 0.28))
			K.star(ci, o, s, Vector2(f * 2, -42.5), 2.8, gold)
		"robe", "hanbok":
			K.ln(ci, o, s, Vector2(-f * 14, -30), Vector2(f * 14, -30), K.c(gold, 0.8), 1.0)
		_:
			K.part(ci, o, s, [Vector2(-13.5, -41), Vector2(13.5, -41), Vector2(17.5, -33), Vector2(-17.5, -33)], dk)
			K.ln(ci, o, s, Vector2(-16, -34.5), Vector2(16, -34.5), lt, 1.2)
			K.pl(ci, o, s, [Vector2(f * 3, -56), Vector2(f * 10, -56), Vector2(f * 9.5, -50), Vector2(f * 3.5, -50)], dk)
			K.stitch(ci, o, s, Vector2(f * 3.5, -55), Vector2(f * 9.5, -55), lt, 3)
			K.rc(ci, o, s, Vector2(-13, -45), Vector2(26, 4), gold)
