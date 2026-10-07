extends RefCounted
## Xolo (axolotl-like xocoatl) for PetArt, stages baby / child / adult. Feathery gill fronds
## and the tail lag behind the body; the baby is a chibi head on a tiny body, the child gets
## glow beads and a forehead gem, the adult a gill crest, dorsal fins and floating glow orbs.

const Shade := preload("res://scripts/hunter_shade.gd")
const Face := preload("res://scripts/pet_art_face.gd")


## One gill frond: tapered stem, barbs that fan out, glowing tip. `ang` is the rest angle.
static func _frond(ci: CanvasItem, p: Dictionary, base: Vector2, ang: float, length: float, col: Color,
		lag: float, glow_tip: bool) -> void:
	var tip_col := Shade.lighten(col, 0.5)
	var pts := PetArt.chain(ci, p, base, ang, length / 3.0, [3.2, 2.7, 2.1, 1.5], col, 0.5, lag, 0.0, 2.6, tip_col)
	for j in 3:
		var at: Vector2 = pts[j + 1]
		var a := ang + 0.4 * sin(float(p["t"]) * 2.6 - lag * float(j + 1)) if p["anim"] else ang
		for sgn in [-1.0, 1.0]:
			var side := Vector2(cos(a + sgn * 1.0), sin(a + sgn * 1.0)) * (length * (0.3 - 0.06 * float(j)))
			PetArt.tube(ci, p, at, at + side, 1.7, 0.8, Shade.lighten(col, 0.18 * float(j + 1)))
	var tip: Vector2 = pts[3]
	if glow_tip:
		PetArt.glow(ci, p, tip.x, tip.y, 2.6, Color("#FFE08A"))
	else:
		ci.draw_circle(PetArt.q(p, tip.x, tip.y), 2.4 * float(p["k"]), tip_col)


static func draw(ci: CanvasItem, p: Dictionary) -> void:
	var t: float = p["t"]
	var col: Color = p["col"]
	var gill: Color = p["accent"]
	var stage: int = p["stage"]
	var wag: float = p["wag"]
	var k: float = p["k"]
	var belly := Shade.lighten(col, 0.45)
	var hs: float = [0.0, 1.14, 1.05, 1.0][stage]
	var bs: float = [0.0, 0.8, 0.94, 1.0][stage]
	var hy := -46.0 if stage > 1 else -40.0
	var anim: bool = p["anim"]
	# Adult floating glow orbs, behind everything.
	if stage >= 3:
		for i in 3:
			var ph: float = t * 0.8 + float(i) * 2.1 if anim else float(i) * 2.1
			PetArt.glow(ci, p, -34.0 + float(i) * 34.0, -20.0 + sin(ph) * 5.0 - float(i % 2) * 22.0, 1.8, Color("#FFE08A"))
	# Tail with dorsal fin: lagging chain.
	var tl: float = [0.0, 20.0, 27.0, 34.0][stage]
	var tb := Vector2(12.0 * bs, -12.0)
	var tpts := PetArt.chain(ci, p, tb, 0.18, tl / 4.0, [6.5 * bs, 5.5 * bs, 4.2 * bs, 3.0 * bs, 1.6], col, 0.5, 0.9, 0.0, 3.2)
	if stage >= 2:
		var up: Array = []
		var lo: Array = []
		for i in range(0, 5):
			var f := float(i) / 4.0
			var tp: Vector2 = tpts[i]
			up.append(tp + Vector2(0.0, -(6.5 * bs) * (1.0 - f * 0.7) - 6.0 * (1.0 - f * 0.5)))
			lo.push_front(tp + Vector2(0.0, -(5.0 * bs) * (1.0 - f * 0.6)))
		PetArt.cel_poly(ci, p, up + lo, Shade.lighten(gill, 0.3))
	var tip: Vector2 = tpts[4]
	PetArt.cel(ci, p, tip.x + 3.0, tip.y, 8.0 * bs + 2.0, 4.6, Shade.lighten(gill, 0.35), 0.15, 16, false)
	# Gills behind the head: lagging fronds, more and longer with age.
	var per_side: int = [0, 2, 3, 4][stage]
	var len_scale: float = [0.0, 0.8, 1.0, 1.2][stage]
	for side in [-1.0, 1.0]:
		for i in per_side:
			var base := Vector2(side * 22.0 * hs, hy - 2.0 + float(i) * 5.5 - float(per_side - 3) * 2.0)
			var a: float = lerpf(-1.0, 0.18, float(i) / float(maxi(1, per_side - 1)))
			var ang: float = a if side > 0.0 else PI - a
			_frond(ci, p, base, ang, (17.0 + float(i % 2) * 3.0) * len_scale, gill, side * 0.8 + float(i) * 0.5, stage >= 2)
	# Legs: stubby with toes and claws.
	for sx in [-14.0, 14.0]:
		var lx: float = sx * bs
		PetArt.cel(ci, p, lx, -5.0, 7.6, 5.2, col.darkened(0.04), 0.0, 16, false)
		for j in 3:
			var tx: float = lx + (float(j) - 1.0) * 3.8
			ci.draw_circle(PetArt.q(p, tx, -1.4), 1.8 * k, PetArt.shade_of(col))
			ci.draw_circle(PetArt.q(p, tx - 0.3, -1.8), 1.2 * k, belly)
	# Body with belly, ribs and speckles.
	PetArt.cel(ci, p, 0.0, -21.0, 21.0 * bs, 17.0 * bs, col)
	ci.draw_colored_polygon(PetArt.ell(p, 0.0, -17.0, 12.0 * bs, 10.0 * bs, 0.0, 18), Shade.fade(belly, 0.9))
	for j in 3:
		ci.draw_arc(PetArt.q(p, 0.0, -22.0 + float(j) * 4.0), (8.0 - float(j)) * bs * k, PI * 0.2, PI * 0.8, 8,
			Shade.fade(PetArt.shade_of(belly), 0.6), 1.0, true)
	PetArt.speckles(ci, p, [Vector2(-12, -27), Vector2(-8, -31), Vector2(10, -29), Vector2(14, -23), Vector2(6, -33)],
		1.4, Shade.fade(PetArt.shade_of(col), 0.9))
	# Head.
	PetArt.cel(ci, p, 0.0, hy, 27.0 * hs, 20.0 * hs, col)
	PetArt.set_head(p, 0.0, hy, 27.0 * hs, 20.0 * hs)
	PetArt.speckles(ci, p, [Vector2(-18, hy - 9), Vector2(-14, hy - 13), Vector2(17, hy - 10), Vector2(21, hy - 4), Vector2(0, hy - 16)],
		1.3, Shade.fade(PetArt.shade_of(col), 0.9))
	PetArt.strands(ci, p, Vector2(-6, hy - 17), Vector2(-0.3, -1.0), 4, 3.2, 0.9, Shade.fade(PetArt.light_of(col), 0.8))
	var ey: float = hy - 3.5
	Face.eyes(ci, p, ey, 11.5 * hs, 5.6)
	Face.cheeks(ci, p, 19.0 * hs, ey + 8.0, 4.6)
	Face.mouth(ci, p, 0.0, ey + 8.5, 12.0, true)
	ci.draw_circle(PetArt.q(p, -2.2, ey + 4.5), 0.7 * k, PetArt.shade_of(col))
	ci.draw_circle(PetArt.q(p, 2.2, ey + 4.5), 0.7 * k, PetArt.shade_of(col))
	p["a_eye"] = Vector2(0.0, ey)
	p["a_eyedx"] = 11.5 * hs
	p["a_eyer"] = 5.6
	p["a_neck"] = Vector2(0.0, hy + 18.0 * hs)
	p["a_nw"] = 15.0 * bs
	p["a_mouth"] = Vector2(0.0, ey + 8.5)
	if stage >= 2:
		# Child: forehead gem and glow beads.
		var gy: float = hy - 12.0 * hs
		PetArt.glow(ci, p, 0.0, gy, 2.0, Color("#FF9AD0"))
	if stage >= 3:
		# Adult: majestic gill crest plus cheek fins.
		for i in 3:
			var x := -9.0 + float(i) * 9.0
			var top: float = hy - 22.0 * hs - (5.0 if i == 1 else 0.0)
			var lagx: float = sin(t * 2.4 - float(i)) * 1.5 if anim else 0.0
			PetArt.tube(ci, p, Vector2(x, hy - 16.0 * hs), Vector2(x * 1.15 + lagx, top), 2.4, 1.3, gill)
			PetArt.glow(ci, p, x * 1.15 + lagx, top - 1.0, 2.4, Color("#FFE08A"))
