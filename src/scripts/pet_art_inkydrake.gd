extends RefCounted
## Inkydrake (tiny teal dragon) for PetArt. Soft translucent wing-fins that flap with a lag
## per finger, a curling spade-tipped tail, horns, head frills, belly plates and ink-spot
## markings. Baby: stub horns and tiny fins. Child: capped horns, bigger fins. Adult: large
## glowing fins, head crest, ink swirl markings and floating ink bubbles.

const Shade := preload("res://scripts/hunter_shade.gd")
const Face := preload("res://scripts/pet_art_face.gd")
const PLATE := Color("#E6FFF4")


## One soft wing-fin: three fingers and a scalloped membrane, flapping with lag.
static func _fin(ci: CanvasItem, p: Dictionary, side: float, base: Vector2, ws: float, col: Color, glow_veins: bool) -> void:
	var t: float = p["t"]
	var anim: bool = p["anim"]
	var tips_a := [-1.15, -0.6, -0.08]
	var tips_l := [24.0, 29.0, 22.0]
	var tips: Array = []
	for i in 3:
		var fl: float = sin(t * 5.0 - float(i) * 0.5) * 0.22 if anim else 0.0
		var a: float = float(tips_a[i]) + fl - float(p["vel"]) * 0.2
		var aa: float = a if side > 0.0 else PI - a
		tips.append(base + Vector2(cos(aa), sin(aa)) * float(tips_l[i]) * ws)
	var pts: Array = [base + Vector2(0.0, -2.0), tips[0]]
	for i in 2:
		var mid: Vector2 = (tips[i] as Vector2).lerp(tips[i + 1], 0.5)
		pts.append(base.lerp(mid, 0.62))
		pts.append(tips[i + 1])
	pts.append(base + Vector2(side * 2.0, 6.0))
	var poly := PetArt.poly(p, pts)
	ci.draw_colored_polygon(poly, Shade.fade(PetArt.shade_of(col), 0.82))
	var inner: Array = []
	for v in pts:
		inner.append(base + ((v as Vector2) - base) * 0.84 + Vector2(0, -0.6))
	ci.draw_colored_polygon(PetArt.poly(p, inner), Shade.fade(col, 0.82))
	var closed := PackedVector2Array(poly)
	closed.append(poly[0])
	ci.draw_polyline(closed, Shade.fade(PetArt.ol_of(col), 0.9), PetArt.lw(p, 1.3), true)
	for i in 3:
		var vc := Shade.fade(Shade.lighten(col, 0.7), 0.9) if glow_veins else Shade.fade(PetArt.ol_of(col), 0.55)
		ci.draw_line(PetArt.q(p, base.x, base.y), PetArt.q(p, (tips[i] as Vector2).x, (tips[i] as Vector2).y), vc, PetArt.lw(p, 1.0), true)


static func draw(ci: CanvasItem, p: Dictionary) -> void:
	var t: float = p["t"]
	var col: Color = p["col"]
	var acc: Color = p["accent"]
	var stage: int = p["stage"]
	var k: float = p["k"]
	var anim: bool = p["anim"]
	var hs: float = [0.0, 1.14, 1.06, 1.0][stage]
	var bs: float = [0.0, 0.8, 0.94, 1.0][stage]
	var ws: float = [0.0, 0.5, 0.75, 1.0][stage]
	var dark := PetArt.shade_of(col)
	var pale := PLATE
	# Wing-fins behind the body.
	for side in [-1.0, 1.0]:
		_fin(ci, p, side, Vector2(side * 16.0 * bs, -32.0), ws, acc, stage >= 3)
	# Curling tail with a spade tip.
	var tpts := PetArt.chain(ci, p, Vector2(11.0 * bs, -12.0), 0.1, 6.0 + 1.5 * float(stage),
		[6.0 * bs, 5.4 * bs, 4.5 * bs, 3.6, 2.6, 1.4], col, 0.7, 0.8, -0.2, 2.8)
	var tp: Vector2 = tpts[5]
	var tdir: Vector2 = (tp - tpts[4]).normalized()
	var perp := tdir.orthogonal()
	var spade: Array = [tp + tdir * 8.0, tp + perp * 4.2 + tdir * 2.0, tp - tdir * 1.0, tp - perp * 4.2 + tdir * 2.0]
	PetArt.cel_poly(ci, p, spade, acc)
	# Feet with claws.
	for sx in [-10.0, 10.0]:
		var lx: float = sx * bs
		PetArt.cel(ci, p, lx, -4.8, 6.6, 5.0, col.darkened(0.04), 0.0, 14, false)
		for j in 3:
			var cx: float = lx + (float(j) - 1.0) * 3.0
			ci.draw_colored_polygon(PetArt.poly(p, [Vector2(cx - 1.1, -1.8), Vector2(cx + 1.1, -1.8), Vector2(cx, 0.4)]), pale)
	# Body: belly plates and ink markings.
	PetArt.cel(ci, p, 0.0, -21.0, 19.0 * bs, 17.0 * bs, col)
	ci.draw_colored_polygon(PetArt.ell(p, 0.0, -17.0, 11.0 * bs, 11.5 * bs, 0.0, 18), pale)
	for j in 4:
		ci.draw_arc(PetArt.q(p, 0.0, -25.0 + float(j) * 3.4), (9.0 - float(j) * 0.6) * bs * k, PI * 0.12, PI * 0.88, 8,
			Shade.fade(PetArt.shade_of(pale), 0.85), 1.0, true)
	PetArt.speckles(ci, p, [Vector2(-13, -26), Vector2(-9, -30), Vector2(12, -27), Vector2(15, -21), Vector2(-15, -19)],
		1.5, Shade.fade(Shade.darken(col, 0.45), 0.8))
	if stage >= 3:
		var sw := PackedVector2Array()
		for i in 14:
			var a := float(i) * 0.5
			sw.append(PetArt.q(p, -14.0 + cos(a) * (1.0 + a * 0.55), -16.0 + sin(a) * (1.0 + a * 0.55)))
		ci.draw_polyline(sw, Shade.fade(acc, 0.9), PetArt.lw(p, 1.3), true)
	# Horns.
	var horn: float = [0.0, 5.0, 10.0, 15.0][stage]
	for side in [-1.0, 1.0]:
		var sway: float = sin(t * 2.0 + side) * 0.8 if anim else 0.0
		var hb := Vector2(side * 11.5 * hs, -60.0 * (0.99 if stage > 1 else 1.0) + (4.0 if stage == 1 else 0.0))
		var ht := hb + Vector2(side * (3.5 + horn * 0.3), -horn - 2.0)
		PetArt.tube(ci, p, hb, ht, 3.0, 0.9, pale)
		if stage >= 2:
			PetArt.glow(ci, p, ht.x + sway * 0.2, ht.y, 1.5, acc)
	# Head with frills, snout and face.
	for side in [-1.0, 1.0]:
		var fr: float = sin(t * 3.0 - 1.0 + side) * 1.3 if anim else 0.0
		var f: Array = [Vector2(side * 22.0 * hs, -50.0), Vector2(side * (32.0 + fr) * hs, -57.0), Vector2(side * 27.0 * hs, -49.5),
			Vector2(side * (34.0 + fr) * hs, -46.0), Vector2(side * 26.0 * hs, -43.0), Vector2(side * 21.0 * hs, -41.0)]
		PetArt.cel_poly(ci, p, f, Shade.lighten(acc, 0.1))
	PetArt.cel(ci, p, 0.0, -44.0, 24.0 * hs, 19.0 * hs, col)
	PetArt.set_head(p, 0.0, -44.0, 24.0 * hs, 19.0 * hs)
	if stage >= 3:
		for i in 3:
			var cx: float = -7.0 + float(i) * 7.0
			var top: float = -62.0 - (4.0 if i == 1 else 0.0)
			PetArt.cel_poly(ci, p, [Vector2(cx - 3.0, -58.0), Vector2(cx, top - 3.0), Vector2(cx + 3.0, -58.0)], acc)
	PetArt.speckles(ci, p, [Vector2(-15, -55), Vector2(-11, -58), Vector2(14, -56), Vector2(18, -52)], 1.3, Shade.fade(Shade.darken(col, 0.45), 0.8))
	PetArt.cel(ci, p, 0.0, -37.0, 10.5 * hs, 7.6 * hs, Shade.lighten(col, 0.3), 0.0, 16, false)
	for sx in [-1.0, 1.0]:
		ci.draw_circle(PetArt.q(p, sx * 3.4, -39.5), 0.85 * k, Face.INK)
		ci.draw_circle(PetArt.q(p, sx * 3.6, -39.8), 0.35 * k, Color(1, 1, 1, 0.8))
	Face.eyes(ci, p, -47.0, 11.0 * hs, 5.4)
	Face.cheeks(ci, p, 17.5 * hs, -38.5, 4.2)
	Face.mouth(ci, p, 0.0, -34.2, 8.5)
	p["a_eye"] = Vector2(0.0, -47.0)
	p["a_eyedx"] = 11.0 * hs
	p["a_eyer"] = 5.4
	p["a_neck"] = Vector2(0.0, -26.5)
	p["a_nw"] = 12.0
	p["a_mouth"] = Vector2(0.0, -34.2)
	if stage >= 3:
		for i in 3:
			var ph: float = fmod(t * 0.35 + float(i) * 0.33, 1.0) if anim else float(i) * 0.33
			var bp := PetArt.q(p, 28.0 + float(i) * 4.0 + sin(ph * 5.0) * 2.0, -20.0 - ph * 38.0)
			ci.draw_arc(bp, (2.6 + float(i)) * k, 0.0, TAU, 12, Shade.fade(Shade.lighten(acc, 0.4), 1.0 - ph), 1.1, true)
			ci.draw_circle(bp + Vector2(-0.7, -0.7) * k, 0.7 * k, Color(1, 1, 1, 0.8 * (1.0 - ph)))
