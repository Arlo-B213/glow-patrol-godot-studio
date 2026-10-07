extends RefCounted
## Sparkfox for PetArt. A cheeky fox with cream cheek ruffs, whiskers, swishing ears and a
## bushy lagging tail with a lantern-glow tip. Baby: big head, one small tail. Child: glow
## collar and ear-tip glow. Adult: two fanned tails, chest ruff, ear flames, forehead star.

const Shade := preload("res://scripts/hunter_shade.gd")
const Face := preload("res://scripts/pet_art_face.gd")
const CREAM := Color("#FFF0DC")


## One bushy tail: lagging chain with a cream, glowing tip.
static func _tail(ci: CanvasItem, p: Dictionary, base: Vector2, ang: float, size: float, col: Color,
		glow: Color, lag_off: float) -> void:
	var pts := PetArt.chain(ci, p, base, ang, 8.5 * size, [5.5 * size, 9.0 * size, 9.5 * size, 7.0 * size, 3.0 * size], col, 0.55, 0.8 + lag_off, 0.12, 3.0)
	var tip: Vector2 = pts[4]
	var mid: Vector2 = pts[3]
	PetArt.cel(ci, p, (tip.x + mid.x) * 0.5 + 2.0, (tip.y + mid.y) * 0.5, 6.0 * size, 5.0 * size, CREAM, ang, 14, false)
	PetArt.glow(ci, p, tip.x + 2.0, tip.y, 3.4 * size, glow)
	for i in 3:
		var at: Vector2 = pts[i + 1]
		PetArt.strands(ci, p, at + Vector2(0, -4), Vector2(0.2, -1), 3, 3.0, 1.0, Shade.fade(PetArt.light_of(col), 0.6))


static func _ear(ci: CanvasItem, p: Dictionary, side: float, size: float, col: Color, glow: Color) -> void:
	var lagr: float = float(p["vel"]) * 0.12 * side
	var sway: float = sin(float(p["t"]) * 2.1 + side) * 0.05 if p["anim"] else 0.0
	var rot := lagr + sway
	var pts: Array = []
	for v in [Vector2(side * 25.0, -50.0), Vector2(side * 24.0 + side * 3.0 * rot * 10.0, -50.0 - 28.0 * size), Vector2(side * 6.0, -61.0)]:
		pts.append(v)
	PetArt.cel_poly(ci, p, pts, col)
	var inner: Array = [Vector2(side * 21.5, -55.0), Vector2(side * 21.0 + side * 2.0 * rot * 10.0, -55.0 - 15.0 * size), Vector2(side * 11.5, -60.0)]
	ci.draw_colored_polygon(PetArt.poly(p, inner), Color("#FFB3C7"))
	var tipv: Vector2 = pts[1]
	ci.draw_colored_polygon(PetArt.poly(p, [tipv, tipv + Vector2(-side * 3.0, 6.0), tipv + Vector2(-side * 7.2, 3.6)]), PetArt.ol_of(col))
	PetArt.strands(ci, p, Vector2(side * 14.0, -61.0), Vector2(side * 0.2, 0.0) + Vector2(0, 1), 3, 4.0, 1.0, Shade.fade(CREAM, 0.9))
	if glow.a > 0.0:
		PetArt.glow(ci, p, tipv.x, tipv.y - 1.0, 2.0, glow)


static func draw(ci: CanvasItem, p: Dictionary) -> void:
	var col: Color = p["col"]
	var glow: Color = p["accent"]
	var stage: int = p["stage"]
	var wag: float = p["wag"]
	var k: float = p["k"]
	var hs: float = [0.0, 1.1, 1.04, 1.0][stage]
	var bs: float = [0.0, 0.82, 0.94, 1.0][stage]
	var dark := col.darkened(0.22)
	# Tails first (behind).
	var tsz: float = [0.0, 0.8, 0.95, 1.1][stage]
	if stage >= 3:
		_tail(ci, p, Vector2(10.0, -16.0), -1.35 + wag * 0.1, tsz * 0.9, col, glow, 0.6)
	_tail(ci, p, Vector2(11.0 * bs, -13.0), -0.5 + wag * 0.12, tsz, col, glow, 0.0)
	# Legs and haunches.
	for sx in [-10.0, 10.0]:
		var lx: float = sx * bs
		PetArt.cel(ci, p, lx, -5.0, 6.4, 5.6, dark, 0.0, 14, false)
		for j in 3:
			ci.draw_line(PetArt.q(p, lx + (float(j) - 1.0) * 2.2, -1.2), PetArt.q(p, lx + (float(j) - 1.0) * 2.2, -3.6),
				PetArt.ol_of(dark), PetArt.lw(p, 0.9), true)
	PetArt.cel(ci, p, 0.0, -20.0, 17.0 * bs, 16.0 * bs, col)
	ci.draw_colored_polygon(PetArt.ell(p, 0.0, -17.0, 9.5 * bs, 11.0 * bs, 0.0, 16), CREAM)
	PetArt.strands(ci, p, Vector2(-5, -26), Vector2(0.15, 1.0), 5, 4.0, 1.6, Shade.fade(PetArt.shade_of(CREAM), 0.8))
	PetArt.speckles(ci, p, [Vector2(-12, -24), Vector2(12, -22), Vector2(-9, -12)], 1.0, Shade.fade(dark, 0.7))
	if stage >= 3:
		# Chest ruff.
		var ruff: Array = [Vector2(-9, -30)]
		for i in 5:
			ruff.append(Vector2(-8.0 + float(i) * 4.0 + 2.0, -22.0 - float(i % 2) * 3.0 + 3.0))
		ruff.append(Vector2(9, -30))
		PetArt.cel_poly(ci, p, ruff, CREAM)
	# Ears, then head.
	var ear_size: float = [0.0, 0.78, 0.9, 1.04][stage]
	var ear_glow: Color = glow if stage >= 2 else Color(0, 0, 0, 0)
	for side in [-1.0, 1.0]:
		_ear(ci, p, side, ear_size, col, ear_glow)
	PetArt.cel(ci, p, 0.0, -44.0, 25.0 * hs, 18.0 * hs, col)
	PetArt.set_head(p, 0.0, -44.0, 25.0 * hs, 18.0 * hs)
	for side in [-1.0, 1.0]:
		var ruff2: Array = [Vector2(side * 22.0 * hs, -47.0), Vector2(side * 35.0 * hs, -40.0), Vector2(side * 28.0 * hs, -37.0),
			Vector2(side * 33.0 * hs, -31.0), Vector2(side * 19.0 * hs, -32.0)]
		PetArt.cel_poly(ci, p, ruff2, CREAM)
	# Forehead mark and muzzle.
	var mark: Array = [Vector2(0, -61), Vector2(3.4, -55), Vector2(0, -50), Vector2(-3.4, -55)]
	ci.draw_colored_polygon(PetArt.poly(p, mark), Shade.fade(glow, 0.9))
	PetArt.cel(ci, p, 0.0, -37.0, 9.5, 6.8, CREAM, 0.0, 16, false)
	ci.draw_colored_polygon(PetArt.poly(p, [Vector2(-2.6, -41.5), Vector2(2.6, -41.5), Vector2(0, -38.2)]), Face.INK)
	ci.draw_circle(PetArt.q(p, -0.8, -40.8), 0.7 * k, Color(1, 1, 1, 0.8))
	for side in [-1.0, 1.0]:
		for j in 3:
			var wy: float = -38.0 + (float(j) - 1.0) * 2.6
			ci.draw_line(PetArt.q(p, side * 11.0, wy), PetArt.q(p, side * (21.0 + float(j) * 0.8), wy + (float(j) - 1.0) * 2.4),
				Shade.fade(Face.INK, 0.55), 0.8, true)
	Face.eyes(ci, p, -47.0, 10.5 * hs, 5.2)
	Face.cheeks(ci, p, 17.0 * hs, -39.0, 4.0)
	Face.mouth(ci, p, 0.0, -34.2, 7.5)
	p["a_eye"] = Vector2(0.0, -47.0)
	p["a_eyedx"] = 10.5 * hs
	p["a_eyer"] = 5.2
	p["a_neck"] = Vector2(0.0, -27.5)
	p["a_nw"] = 12.0
	p["a_mouth"] = Vector2(0.0, -34.2)
	if stage >= 2:
		# Child: glow collar with a gem.
		var band := PackedVector2Array()
		for i in 9:
			var a := PI * 0.1 + PI * 0.8 * float(i) / 8.0
			band.append(PetArt.q(p, cos(a) * 11.0, -28.5 + sin(a) * 3.2))
		ci.draw_polyline(band, PetArt.ol_of(glow), PetArt.lw(p, 3.8), true)
		ci.draw_polyline(band, glow, PetArt.lw(p, 2.4), true)
		PetArt.glow(ci, p, 0.0, -25.0, 2.4, Color("#52E8C6"))
	if stage >= 3:
		PetArt.glow(ci, p, 0.0, -54.5, 1.5, Color("#FFFFFF"))
