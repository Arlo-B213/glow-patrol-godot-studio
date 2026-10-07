extends RefCounted
## Species bodies for PetArt (Story 024): Xolo (axolotl-like), Puff (glow-moth) and
## Sparkfox. Each draws in pet space (ground centre 0,0, up is negative) for stages
## baby..adult from the shared context `p` built by PetArt.draw. Simple polygons only.

const Shade := preload("res://scripts/hunter_shade.gd")


static func draw_species(ci: CanvasItem, species: String, p: Dictionary) -> void:
	match species:
		"xolo": _xolo(ci, p)
		"puff": _puff(ci, p)
		"sparkfox": _fox(ci, p)
		_: _puff(ci, p)


# ---------------------------------------------------------------- Xolo

## One feathery gill frond: capsule stem, two side feathers and a glowing tip.
static func _frond(ci: CanvasItem, p: Dictionary, base: Vector2, ang: float, length: float, col: Color) -> void:
	var dir := Vector2(cos(ang), sin(ang))
	var tip := base + dir * length
	PetArt.limb(ci, p, base, tip, 3.0, col)
	for f in [0.45, 0.72]:
		var at: Vector2 = base + dir * length * f
		var side := Vector2(cos(ang - 0.7), sin(ang - 0.7)) * length * 0.32
		PetArt.limb(ci, p, at, at + side, 2.0, col)
	var c := PetArt.q(p, tip.x, tip.y)
	ci.draw_circle(c, 3.6 * float(p["k"]), Shade.lighten(col, 0.45))


static func _xolo(ci: CanvasItem, p: Dictionary) -> void:
	var t: float = p["t"]
	var col: Color = p["col"]
	var gill: Color = p["accent"]
	var belly := Shade.lighten(col, 0.4)
	var stage: int = p["stage"]
	var wag: float = p["wag"]
	# Tail with a soft fin.
	var tail_a := 0.15 + wag * 0.3
	var tb := Vector2(14.0, -13.0)
	var tt := tb + Vector2(cos(tail_a), sin(tail_a)) * 30.0
	PetArt.limb(ci, p, tb, tt, 6.5, col)
	PetArt.blob(ci, PetArt.ell(p, tt.x + 3.0, tt.y - 1.0, 9.0, 5.0, tail_a), Shade.lighten(gill, 0.35), false)
	# Gills (3 per side) behind the head.
	var scale_len := 0.85 + 0.15 * float(stage)
	for side in [-1.0, 1.0]:
		for i in 3:
			var base := Vector2(side * 21.0, -50.0 + float(i) * 6.0)
			var a: float = [-0.95, -0.4, 0.15][i] + sin(t * 3.0 + float(i) * 0.9 + side) * 0.1
			var ang: float = a if side > 0.0 else PI - a
			_frond(ci, p, base, ang, (18.0 + float(i % 2) * 3.0) * scale_len, gill)
	# Legs and body.
	for sx in [-15.0, 15.0]:
		PetArt.blob(ci, PetArt.ell(p, sx, -4.5, 7.5, 5.0), col.darkened(0.06), false)
	PetArt.blob(ci, PetArt.ell(p, 0.0, -22.0, 21.0, 18.0), col)
	ci.draw_colored_polygon(PetArt.ell(p, 0.0, -18.0, 12.0, 11.0), belly)
	# Head.
	PetArt.blob(ci, PetArt.ell(p, 0.0, -46.0, 27.0, 20.0), col)
	PetArt.eye(ci, p, -11.5, -49.0, 5.4)
	PetArt.eye(ci, p, 11.5, -49.0, 5.4)
	PetArt.blush(ci, p, -19.0, -41.0, 4.6)
	PetArt.blush(ci, p, 19.0, -41.0, 4.6)
	PetArt.mouth(ci, p, 0.0, -41.0, 11.0)
	if stage >= 3:
		# Tiny glow crown of gills on top of the head.
		for i in 3:
			var x := -9.0 + float(i) * 9.0
			var top := -62.0 - (4.0 if i == 1 else 0.0)
			PetArt.limb(ci, p, Vector2(x, -58.0), Vector2(x * 1.1, top), 2.2, gill)
			PetArt.glow(ci, p, x * 1.1, top - 1.0, 2.6, Color("#FFE08A"))


# ---------------------------------------------------------------- Puff

static func _wing(ci: CanvasItem, p: Dictionary, side: float, size: float, col: Color) -> void:
	var flap: float = (sin(float(p["t"]) * 6.0) * 0.18) if p["anim"] else 0.0
	var rot: float = side * (0.55 + flap)
	var c := Vector2(side * (24.0 + size * 0.5), -44.0)
	PetArt.blob(ci, PetArt.ell(p, c.x, c.y, size, size * 0.62, rot), Shade.fade(col, 0.9), false)
	ci.draw_colored_polygon(PetArt.ell(p, c.x, c.y, size * 0.55, size * 0.3, rot), Shade.fade(Shade.lighten(col, 0.55), 0.6))


static func _puff(ci: CanvasItem, p: Dictionary) -> void:
	var t: float = p["t"]
	var col: Color = p["col"]
	var acc: Color = p["accent"]
	var stage: int = p["stage"]
	var wing_size := 11.0 + 5.0 * float(stage)
	for side in [-1.0, 1.0]:
		_wing(ci, p, side, wing_size, acc)
		if stage >= 3:
			var c := Vector2(side * 26.0, -26.0)
			PetArt.blob(ci, PetArt.ell(p, c.x, c.y, 9.0, 6.0, side * -0.5), Shade.fade(acc, 0.8), false)
		# Antennae with glowing tips.
		var wob: float = sin(t * 3.0 + side) * 2.0 if p["anim"] else 0.0
		var a := Vector2(side * 8.0, -58.0)
		var b := Vector2(side * (15.0 + wob * 0.5), -75.0)
		PetArt.limb(ci, p, a, b, 1.6, Shade.darken(col, 0.2))
		PetArt.glow(ci, p, b.x, b.y, 3.2, acc)
	for sx in [-10.0, 10.0]:
		PetArt.blob(ci, PetArt.ell(p, sx, -4.0, 6.5, 4.5), Shade.darken(col, 0.15), false)
	# Fuzzy round body: star-convex scalloped outline.
	var fuzz := PackedVector2Array()
	for i in 56:
		var an := TAU * float(i) / 56.0
		var r := 27.0 + 2.6 * sin(an * 14.0 + (t * 1.5 if p["anim"] else 0.0))
		fuzz.append(PetArt.q(p, cos(an) * r, -33.0 + sin(an) * r * 0.95))
	PetArt.blob(ci, fuzz, col)
	ci.draw_colored_polygon(PetArt.ell(p, 0.0, -26.0, 14.0, 11.0), Shade.fade(Shade.lighten(acc, 0.5), 0.55))
	PetArt.eye(ci, p, -10.0, -37.0, 6.0)
	PetArt.eye(ci, p, 10.0, -37.0, 6.0)
	PetArt.blush(ci, p, -17.0, -29.0, 4.4)
	PetArt.blush(ci, p, 17.0, -29.0, 4.4)
	PetArt.mouth(ci, p, 0.0, -30.0, 9.0)
	if stage >= 3:
		var star := PackedVector2Array()
		for i in 8:
			var an := -PI * 0.5 + TAU * float(i) / 8.0
			var r := 6.0 if i % 2 == 0 else 2.4
			star.append(PetArt.q(p, cos(an) * r, -52.0 + sin(an) * r))
		ci.draw_colored_polygon(star, Shade.lighten(acc, 0.4))


# ---------------------------------------------------------------- Sparkfox

static func _tri(ci: CanvasItem, p: Dictionary, pts: Array, col: Color, outline: bool = true) -> void:
	var poly := PackedVector2Array()
	for v in pts:
		poly.append(PetArt.q(p, v.x, v.y))
	if outline:
		Shade.fill(ci, poly, col, 1.3, Shade.ink(col))
	else:
		ci.draw_colored_polygon(poly, col)


static func _fox(ci: CanvasItem, p: Dictionary) -> void:
	var col: Color = p["col"]
	var glow: Color = p["accent"]
	var cream := Color("#FFF0DC")
	var stage: int = p["stage"]
	var wag: float = p["wag"]
	# Big tail with a lantern-glow tip.
	var tr := -0.95 + wag * 0.3
	var tc := Vector2(30.0, -24.0)
	PetArt.blob(ci, PetArt.ell(p, tc.x, tc.y, 19.0 + stage * 1.5, 9.5, tr), col)
	var tip := tc + Vector2(cos(tr), sin(tr)) * (17.0 + stage * 1.5)
	PetArt.glow(ci, p, tip.x, tip.y, 4.0 + stage * 0.8, glow)
	# Back feet, body, belly, front paws.
	for sx in [-10.0, 10.0]:
		PetArt.blob(ci, PetArt.ell(p, sx, -5.0, 6.0, 5.5), col.darkened(0.2), false)
	PetArt.blob(ci, PetArt.ell(p, 0.0, -20.0, 17.0, 16.0), col)
	ci.draw_colored_polygon(PetArt.ell(p, 0.0, -17.0, 9.0, 11.0), cream)
	# Ears (outer + inner), then head.
	for side in [-1.0, 1.0]:
		_tri(ci, p, [Vector2(side * 25.0, -50.0), Vector2(side * 22.0, -77.0), Vector2(side * 6.0, -60.0)], col)
		_tri(ci, p, [Vector2(side * 21.0, -56.0), Vector2(side * 20.0, -69.0), Vector2(side * 11.0, -60.0)],
			Color("#FFB3C7"), false)
	PetArt.blob(ci, PetArt.ell(p, 0.0, -44.0, 25.0, 18.0), col)
	for side in [-1.0, 1.0]:
		_tri(ci, p, [Vector2(side * 22.0, -46.0), Vector2(side * 33.0, -36.0), Vector2(side * 16.0, -33.0)], cream)
	PetArt.blob(ci, PetArt.ell(p, 0.0, -37.0, 9.0, 6.5), cream, false)
	ci.draw_circle(PetArt.q(p, 0.0, -40.0), 2.4 * float(p["k"]), Shade.INK)
	PetArt.eye(ci, p, -10.5, -47.0, 5.0)
	PetArt.eye(ci, p, 10.5, -47.0, 5.0)
	PetArt.blush(ci, p, -17.0, -38.0, 4.0)
	PetArt.blush(ci, p, 17.0, -38.0, 4.0)
	PetArt.mouth(ci, p, 0.0, -34.0, 7.0)
	if stage >= 2:
		# Glow collar with a gem.
		PetArt.limb(ci, p, Vector2(-10.0, -28.0), Vector2(10.0, -28.0), 2.2, glow)
		PetArt.glow(ci, p, 0.0, -26.0, 2.6, Color("#52E8C6"))
	if stage >= 3:
		PetArt.glow(ci, p, -22.0, -75.0, 2.2, glow)
		PetArt.glow(ci, p, 22.0, -75.0, 2.2, glow)
