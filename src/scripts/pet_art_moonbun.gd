extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Moonbun (round moon-rabbit) for PetArt. Long glowing ears that swing and trail behind
## hops, a pompom tail, big bunny feet and a crescent forehead mark. Baby: short floppy ears.
## Child: longer ears and a moon pendant. Adult: very long ears with star tips, a crescent
## moon halo behind the head and drifting moon dust.

const Shade := preload("res://scripts/hunter_shade.gd")
const Face := preload("res://scripts/pet_art_face.gd")


## Thin crescent (opening right) as a simple polygon around `c`, outer radius `r`.
static func crescent(c: Vector2, r: float, a0: float, a1: float, bite: float) -> Array:
	var pts: Array = []
	for i in 13:
		var a := lerpf(a0, a1, float(i) / 12.0)
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	for i in 13:
		var a2 := lerpf(a1, a0, float(i) / 12.0)
		pts.append(c + Vector2(bite, 0.0) + Vector2(cos(a2), sin(a2)) * r * 0.78)
	return pts


static func draw(ci: CanvasItem, p: Dictionary) -> void:
	var t: float = p["t"]
	var col: Color = p["col"]
	var acc: Color = p["accent"]
	var stage: int = p["stage"]
	var k: float = p["k"]
	var anim: bool = p["anim"]
	var hs: float = [0.0, 1.12, 1.05, 1.0][stage]
	var bs: float = [0.0, 0.8, 0.94, 1.0][stage]
	var hy := -45.0
	var moon := Shade.lighten(acc, 0.55)
	# Adult crescent halo behind the head.
	if stage >= 3:
		var halo := crescent(Vector2(0, hy - 2.0), 35.0, PI * 1.08, PI * 1.92, 0.0)
		FD.poly(ci, PetArt.poly(p, halo), Shade.fade(moon, 0.22))
		var cres := crescent(Vector2(0, hy - 4.0), 32.0, PI * 1.12, PI * 1.88, 0.0)
		FD.poly(ci, PetArt.poly(p, cres), Shade.fade(Shade.lighten(acc, 0.7), 0.85))
	# Pompom tail.
	var tw: float = sin(t * 3.0) * 1.0 if anim else 0.0
	PetArt.cel(ci, p, 17.0 * bs + tw * 0.4, -12.0, 6.6, 6.2, Shade.lighten(col, 0.25), 0.0, 14, false)
	PetArt.strands(ci, p, Vector2(17.0 * bs, -16), Vector2(0.3, -1), 4, 3.0, 1.4, Shade.fade(Color.WHITE, 0.8))
	# Ears (behind the head): lagging 3-segment chains with glowing inner ear.
	var ear_len: float = [0.0, 13.0, 23.0, 31.0][stage]
	for side in [-1.0, 1.0]:
		var droop: float = 0.55 if stage == 1 else (0.14 if stage == 2 else 0.06)
		var a0: float = -PI * 0.5 + side * (0.22 + droop * 0.4)
		var pts := PetArt.chain(ci, p, Vector2(side * 10.5 * hs, hy - 14.0 * hs), a0, ear_len / 3.0,
			[5.0, 6.2, 5.6, 3.2], col, 0.5, 0.9, side * droop * 0.5, 2.2)
		for i in range(1, 3):
			PetArt.tube(ci, p, pts[i - 1].lerp(pts[i], 0.2), pts[i].lerp(pts[i + 1], 0.2) if i < 3 else pts[i], 3.2, 3.6,
				Shade.lighten(acc, 0.35) if i == 1 else Shade.lighten(acc, 0.5))
		var tip: Vector2 = pts[3]
		if stage >= 2:
			PetArt.glow(ci, p, tip.x, tip.y, 1.8 + float(stage - 2) * 0.8, moon)
		if stage >= 3:
			PetArt.star4(ci, PetArt.q(p, tip.x, tip.y - 5.0), 3.6 * k, Shade.fade(Color.WHITE, 0.9))
	# Big bunny feet.
	for sx in [-11.0, 11.0]:
		PetArt.cel(ci, p, sx * bs, -4.5, 8.4, 5.0, col.darkened(0.03), 0.0, 16, false)
		for j in 3:
			ci.draw_line(PetArt.q(p, sx * bs + (float(j) - 1.0) * 3.0, -1.6), PetArt.q(p, sx * bs + (float(j) - 1.0) * 3.0, -4.4),
				PetArt.ol_of(col), PetArt.lw(p, 0.9), true)
		FD.poly(ci, PetArt.ell(p, sx * bs, -2.5, 3.4, 1.8, 0.0, 10), Shade.fade(Shade.lighten(Color("#FF9FC0"), 0.2), 0.8))
	# Body, belly, fluff.
	PetArt.cel(ci, p, 0.0, -21.0, 20.0 * bs, 18.0 * bs, col)
	FD.poly(ci, PetArt.ell(p, 0.0, -17.0, 12.0 * bs, 11.0 * bs, 0.0, 18), Shade.fade(Color.WHITE, 0.75))
	PetArt.strands(ci, p, Vector2(-6, -27), Vector2(0.1, 1.0), 5, 4.0, 1.8, Shade.fade(PetArt.shade_of(col), 0.7))
	for sx in [-1.0, 1.0]:
		PetArt.cel(ci, p, sx * 13.0 * bs, -14.0, 5.0, 6.4, col, 0.2 * sx, 12, false)
	# Head.
	PetArt.cel(ci, p, 0.0, hy, 26.0 * hs, 21.0 * hs, col)
	PetArt.set_head(p, 0.0, hy, 26.0 * hs, 21.0 * hs)
	PetArt.strands(ci, p, Vector2(-7, hy - 18), Vector2(-0.2, -1.0), 4, 3.2, 1.0, Shade.fade(Color.WHITE, 0.8))
	# Crescent mark.
	var mk := crescent(Vector2(0, hy - 13.0 * hs), 3.8, PI * 0.62, PI * 1.38, 2.0)
	FD.poly(ci, PetArt.poly(p, mk), Shade.fade(acc, 0.95))
	# Puffy cheeks, muzzle, nose.
	for sx in [-1.0, 1.0]:
		PetArt.cel(ci, p, sx * 15.0 * hs, hy + 7.0, 8.0, 6.0, Shade.lighten(col, 0.2), 0.0, 14, false)
	var ey: float = hy - 2.5
	Face.eyes(ci, p, ey, 11.0 * hs, 5.6)
	Face.cheeks(ci, p, 18.0 * hs, ey + 8.5, 4.4)
	FD.poly(ci, PetArt.poly(p, [Vector2(-2.3, ey + 6.0), Vector2(2.3, ey + 6.0), Vector2(0, ey + 8.6)]), Color("#FF7FA8"))
	ci.draw_line(PetArt.q(p, 0, ey + 8.4), PetArt.q(p, 0, ey + 10.4), Face.INK, PetArt.lw(p, 1.0), true)
	Face.mouth(ci, p, 0.0, ey + 12.0, 8.5)
	for sx in [-1.0, 1.0]:
		for j in 2:
			ci.draw_line(PetArt.q(p, sx * 9.0, ey + 9.0 + float(j) * 1.6), PetArt.q(p, sx * 20.0, ey + 8.0 + float(j) * 3.6),
				Shade.fade(Face.INK, 0.45), 0.8, true)
	p["a_eye"] = Vector2(0.0, ey)
	p["a_eyedx"] = 11.0 * hs
	p["a_eyer"] = 5.6
	p["a_neck"] = Vector2(0.0, hy + 19.0 * hs)
	p["a_nw"] = 14.0
	p["a_mouth"] = Vector2(0.0, ey + 12.0)
	if stage >= 2:
		# Child: moon pendant on a glow string.
		var str_pts := PackedVector2Array()
		for i in 9:
			var a := PI * 0.12 + PI * 0.76 * float(i) / 8.0
			str_pts.append(PetArt.q(p, cos(a) * 12.0, -28.0 + sin(a) * 3.5))
		FD.polyline(ci, str_pts, Shade.fade(PetArt.ol_of(acc), 0.9), 1.4, true)
		var pc := Vector2(0, -22.0)
		FD.poly(ci, PetArt.poly(p, crescent(pc, 4.2, -PI * 0.5, PI * 0.5, -2.2)),
			Shade.lighten(acc, 0.35))
	if stage >= 3:
		for i in 4:
			var ph: float = fmod(t * 0.4 + float(i) * 0.25, 1.0) if anim else float(i) * 0.25
			var side := -1.0 if i % 2 == 0 else 1.0
			PetArt.star4(ci, PetArt.q(p, side * (32.0 + sin(ph * 6.0) * 3.0), -20.0 - ph * 46.0), (2.2 + 2.0 * sin(ph * PI)) * k,
				Shade.fade(moon, sin(ph * PI)))
