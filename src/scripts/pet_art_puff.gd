extends RefCounted
## Puff (fluffy glow-moth) for PetArt. A scalloped fur ball with translucent veined wings
## that flutter with a lag between the pairs, feathery glowing antennae and a chest tuft.
## Baby: tiny wings. Child: spotted wings and a collar tuft. Adult: four wings, a crest,
## trailing glow dust.

const Shade := preload("res://scripts/hunter_shade.gd")
const Face := preload("res://scripts/pet_art_face.gd")


## One wing: a rotated ellipse rooted at the body with a lit core, veins and glow spots.
static func _wing(ci: CanvasItem, p: Dictionary, side: float, base: Vector2, ang: float, rx: float, ry: float,
		col: Color, spots: bool) -> void:
	var dir := Vector2(cos(ang), sin(ang))
	var c := base + dir * rx * 0.92
	var rot := ang
	var k: float = p["k"]
	ci.draw_colored_polygon(PetArt.ell(p, c.x, c.y, rx * 1.1, ry * 1.12, rot, 22), Shade.fade(col, 0.2))
	var outer := PetArt.ell(p, c.x, c.y, rx, ry, rot, 24)
	ci.draw_colored_polygon(outer, Shade.fade(PetArt.shade_of(col), 0.82))
	ci.draw_colored_polygon(PetArt.ell(p, c.x - dir.x * 0.5, c.y - 1.0, rx * 0.88, ry * 0.8, rot, 22), Shade.fade(col, 0.82))
	ci.draw_colored_polygon(PetArt.ell(p, c.x + dir.x * rx * 0.1, c.y - ry * 0.15, rx * 0.5, ry * 0.4, rot, 16),
		Shade.fade(Shade.lighten(col, 0.6), 0.55))
	for j in 3:
		var fa := (float(j) - 1.0) * 0.62
		var end := c + Vector2(cos(fa) * rx * 0.92, sin(fa) * ry * 0.92).rotated(rot)
		ci.draw_line(PetArt.q(p, base.x, base.y), PetArt.q(p, end.x, end.y), Shade.fade(PetArt.ol_of(col), 0.35), 0.8, true)
	if spots:
		for j in 3:
			var sp := c + Vector2(cos(ang + (float(j) - 1.0) * 0.55), sin(ang + (float(j) - 1.0) * 0.55)) * rx * 0.62
			ci.draw_circle(PetArt.q(p, sp.x, sp.y), (1.9 - float(j % 2) * 0.5) * k, Color(1, 1, 1, 0.75))
	var closed := PackedVector2Array(outer)
	closed.append(outer[0])
	ci.draw_polyline(closed, Shade.fade(PetArt.ol_of(col), 0.85), PetArt.lw(p, 1.3), true)


static func draw(ci: CanvasItem, p: Dictionary) -> void:
	var t: float = p["t"]
	var col: Color = p["col"]
	var acc: Color = p["accent"]
	var stage: int = p["stage"]
	var k: float = p["k"]
	var anim: bool = p["anim"]
	var wing_r: float = [0.0, 10.0, 15.0, 19.0][stage]
	var flap: float = sin(t * 6.0) * 0.2 if anim else 0.0
	var flap2: float = sin(t * 6.0 - 0.9) * 0.2 if anim else 0.0
	var hop_lag: float = float(p["vel"]) * 0.25
	# Wings (behind the body).
	for side in [-1.0, 1.0]:
		var up: float = -0.62 + flap - hop_lag
		var a: float = up if side > 0.0 else PI - up
		if stage >= 3:
			var lo: float = 0.55 + flap2 - hop_lag
			_wing(ci, p, side, Vector2(side * 19.0, -30.0), lo if side > 0.0 else PI - lo, 11.0, 7.5, Shade.lighten(acc, 0.1), false)
		_wing(ci, p, side, Vector2(side * 20.0, -42.0), a, wing_r, wing_r * 0.62, acc, stage >= 2)
	# Antennae: lagging chains with feathers and glowing tips.
	for side in [-1.0, 1.0]:
		var a0: float = (-1.2 if side > 0.0 else PI + 1.2)
		var pts := PetArt.chain(ci, p, Vector2(side * 8.0, -57.0), a0, 5.5 + float(stage), [1.8, 1.5, 1.1], Shade.darken(col, 0.2),
			0.5, 1.0, side * 0.1, 3.0)
		var tp: Vector2 = pts[2]
		if stage >= 2:
			for sgn in [-1.0, 1.0]:
				PetArt.tube(ci, p, pts[1], pts[1] + Vector2(sgn * 4.5, -2.0), 1.2, 0.5, Shade.lighten(acc, 0.3))
		PetArt.glow(ci, p, tp.x, tp.y, 2.7 + float(stage) * 0.3, acc)
	for sx in [-10.0, 10.0]:
		PetArt.cel(ci, p, sx, -4.0, 6.8, 4.6, Shade.darken(col, 0.15), 0.0, 14, false)
		PetArt.strands(ci, p, Vector2(sx, -4.0), Vector2(0, 1), 3, 4.0, 1.0, Shade.fade(PetArt.light_of(col), 0.7))
	# Fuzzy round body: star-convex scalloped outline.
	var fuzz: Array = []
	var ph: float = t * 1.5 if anim else 0.0
	for i in 56:
		var an := TAU * float(i) / 56.0
		var r := 27.0 + 2.6 * sin(an * 14.0 + ph)
		fuzz.append(Vector2(cos(an) * r, -33.0 + sin(an) * r * 0.95))
	PetArt.cel_poly(ci, p, fuzz, col, true)
	ci.draw_colored_polygon(PetArt.ell(p, 0.0, -25.0, 15.0, 11.5, 0.0, 18), Shade.fade(Shade.lighten(acc, 0.55), 0.55))
	# Fluff strands and chest tuft.
	PetArt.strands(ci, p, Vector2(-10, -50), Vector2(-0.35, -1), 5, 4.0, 1.4, Shade.fade(PetArt.light_of(col), 0.85))
	PetArt.strands(ci, p, Vector2(0, -13), Vector2(0, 1), 5, 4.0, 1.5, Shade.fade(Shade.lighten(acc, 0.6), 0.8), 1.1)
	PetArt.speckles(ci, p, [Vector2(-16, -22), Vector2(15, -20), Vector2(-20, -34), Vector2(19, -37)], 1.1, Shade.fade(Shade.lighten(acc, 0.4), 0.8))
	PetArt.set_head(p, 0.0, -38.0, 24.0, 20.0)
	Face.eyes(ci, p, -37.0, 10.0, 6.2)
	Face.cheeks(ci, p, 17.0, -29.0, 4.5)
	Face.mouth(ci, p, 0.0, -29.5, 9.0)
	p["a_eye"] = Vector2(0.0, -37.0)
	p["a_eyedx"] = 10.0
	p["a_eyer"] = 6.2
	p["a_neck"] = Vector2(0.0, -17.0)
	p["a_nw"] = 17.0
	p["a_mouth"] = Vector2(0.0, -29.5)
	p["a_head"] = Vector2(0.0, -58.0)
	if stage >= 2:
		# Child: glow gem between the antennae.
		PetArt.glow(ci, p, 0.0, -51.0, 1.8, Color("#FFE08A"))
	if stage >= 3:
		# Adult: star-burst crest plus trailing dust.
		var star := PackedVector2Array()
		for i in 12:
			var an := -PI * 0.5 + TAU * float(i) / 12.0
			var r: float = 9.0 if i % 2 == 0 else 3.6
			star.append(PetArt.q(p, cos(an) * r, -59.0 + sin(an) * r))
		ci.draw_colored_polygon(star, Shade.fade(Shade.lighten(acc, 0.35), 0.95))
		ci.draw_polyline(PackedVector2Array([star[0], star[2], star[4], star[6], star[8], star[10], star[0]]), Shade.fade(PetArt.ol_of(acc), 0.6), 1.0, true)
		for i in 5:
			var d: float = fmod(t * 0.5 + float(i) * 0.2, 1.0) if anim else float(i) * 0.2
			var side := -1.0 if i % 2 == 0 else 1.0
			ci.draw_circle(PetArt.q(p, side * (26.0 + d * 12.0), -50.0 + d * 30.0), (1.6 - d) * k + 0.3, Shade.fade(Shade.lighten(acc, 0.5), 1.0 - d))
