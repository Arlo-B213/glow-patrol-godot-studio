extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Eggs for PetArt (Story 033): a cel-shaded egg with a species pattern, glowing cracks
## that brighten with hatch progress (p["prog"]), a tiny constant wobble and a bigger
## wobble every few seconds, plus twinkles.

const Shade := preload("res://scripts/hunter_shade.gd")


static func draw(ci: CanvasItem, species: String, p: Dictionary) -> void:
	var t: float = p["t"]
	var k: float = p["k"]
	var col: Color = p["col"]
	var acc: Color = p["accent"]
	var prog: float = p["prog"]
	if p["anim"]:
		var big := 0.0
		if fmod(t, 4.0) < 0.8:
			big = sin(t * 18.0) * 0.13 * (1.0 - fmod(t, 4.0) / 0.8)
		p["rot"] = sin(t * 2.3) * 0.025 + big
	var pts: Array = []
	for i in 30:
		var a := TAU * float(i) / 30.0
		var narrow := 1.0 - 0.14 * (-sin(a))
		pts.append(Vector2(cos(a) * 20.0 * narrow, -29.0 + sin(a) * 28.0))
	PetArt.set_head(p, 0.0, -29.0, 20.0, 28.0)
	p["a_mouth"] = Vector2(0.0, -26.0)
	# Inner glow halo seen through the shell.
	FD.circle(ci, PetArt.q(p, 0.0, -29.0), 26.0 * k, Shade.fade(acc, 0.18))
	PetArt.cel_poly(ci, p, pts, col, true)
	_pattern(ci, species, p, col, acc)
	_cracks(ci, p, acc, prog)
	# Glossy window highlight.
	FD.poly(ci, PetArt.ell(p, -8.0, -44.0, 3.2, 6.0, 0.35, 12), Color(1.0, 1.0, 1.0, 0.55))
	FD.circle(ci, PetArt.q(p, -4.0, -53.0), 1.4 * k, Color(1.0, 1.0, 1.0, 0.8))
	for i in 3:
		var ph: float = fmod(t * 0.8 + float(i) * 0.33, 1.0) if p["anim"] else 0.4
		var an := float(i) * 2.2 + 0.5
		PetArt.star4(ci, PetArt.q(p, cos(an) * 28.0, -30.0 + sin(an) * 30.0), (2.0 + 2.6 * sin(ph * PI)) * k,
			Shade.fade(Shade.lighten(acc, 0.55), sin(ph * PI)))


static func _pattern(ci: CanvasItem, species: String, p: Dictionary, col: Color, acc: Color) -> void:
	var k: float = p["k"]
	var pa := Shade.fade(acc, 0.88)
	match species:
		"xolo":
			for sp in [Vector3(-9, -36, 3.4), Vector3(8, -41, 2.6), Vector3(3, -22, 3.8), Vector3(-10, -20, 2.4),
					Vector3(12, -29, 2.2), Vector3(-3, -30, 1.8)]:
				FD.circle(ci, PetArt.q(p, sp.x, sp.y), sp.z * k, pa)
				FD.circle(ci, PetArt.q(p, sp.x - 0.8, sp.y - 0.9), sp.z * k * 0.35, Color(1, 1, 1, 0.5))
		"puff":
			for row in 2:
				var zig := PackedVector2Array()
				for i in 8:
					zig.append(PetArt.q(p, -17.0 + float(i) * 4.9, -22.0 - float(row) * 12.0 + (4.0 if i % 2 == 0 else -4.0)))
				FD.polyline(ci, zig, pa, PetArt.lw(p, 2.2), true)
			FD.circle(ci, PetArt.q(p, 0.0, -48.0), 2.6 * k, pa)
		"moonbun":
			FD.circle(ci, PetArt.q(p, 0.0, -29.0), 9.0 * k, Shade.lighten(acc, 0.45))
			FD.circle(ci, PetArt.q(p, 3.6, -31.0), 8.0 * k, col)
			for sp in [Vector2(9, -42), Vector2(-11, -24), Vector2(10, -18)]:
				PetArt.star4(ci, PetArt.q(p, sp.x, sp.y), 3.2 * k, Shade.fade(Shade.lighten(acc, 0.5), 0.95))
		"inkydrake":
			for row in 4:
				for i in 4 + (row % 2):
					var x := -12.0 + float(i) * 7.0 + (0.0 if row % 2 == 1 else 3.5)
					var y := -48.0 + float(row) * 9.5
					if absf(x) < (11.0 if row == 0 or row == 3 else 16.0):
						FD.arc(ci, PetArt.q(p, x, y), 3.4 * k, 0.1, PI - 0.1, 6, pa, PetArt.lw(p, 1.3), true)
		_:
			var flame := PackedVector2Array([PetArt.q(p, -4, -17), PetArt.q(p, 4, -17), PetArt.q(p, 7, -30),
				PetArt.q(p, 1, -43), PetArt.q(p, -6, -30)])
			FD.poly(ci, flame, pa)
			FD.poly(ci, PetArt.ell(p, 0.5, -26.0, 2.2, 5.0, 0.0, 10), Color(1, 1, 0.85, 0.7))


## Glowing hatch cracks; more of them as `prog` rises.
static func _cracks(ci: CanvasItem, p: Dictionary, acc: Color, prog: float) -> void:
	var t: float = p["t"]
	var pulse := 0.65 + 0.35 * sin(t * 2.6) if p["anim"] else 0.8
	var inten := (0.5 + 0.5 * prog) * pulse
	var paths: Array = [[Vector2(-3, -54), Vector2(1, -47), Vector2(-4, -41), Vector2(2, -35)]]
	if prog > 0.3:
		paths.append([Vector2(2, -35), Vector2(8, -31), Vector2(6, -24)])
	if prog > 0.6:
		paths.append([Vector2(-4, -41), Vector2(-11, -38), Vector2(-14, -31)])
	if prog > 0.85:
		paths.append([Vector2(2, -35), Vector2(-3, -29), Vector2(-7, -22)])
	for path in paths:
		var line := PackedVector2Array()
		for v in path:
			line.append(PetArt.q(p, (v as Vector2).x, (v as Vector2).y))
		FD.polyline(ci, line, Shade.fade(acc, 0.28 * inten), PetArt.lw(p, 5.0), true)
		FD.polyline(ci, line, Shade.fade(Shade.lighten(acc, 0.35), 0.8 * inten), PetArt.lw(p, 2.2), true)
		FD.polyline(ci, line, Color(1.0, 1.0, 0.95, 0.95 * inten), PetArt.lw(p, 0.9), true)
