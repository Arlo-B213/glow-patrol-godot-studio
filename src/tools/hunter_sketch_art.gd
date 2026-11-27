extends "res://tools/hunter_anime_kit.gd"
## Hunter design directions, anime pass, drawn front-on side by side for the author to choose from.
## Standalone concept art: nothing in the game uses it. Rendered by tools/make_hunter_sketches.gd.

const PANEL_W := 480.0
const PANEL_H := 760.0
const HEADER := 70.0
const GAP := 16.0


static func sheet_size() -> Vector2:
	return Vector2(GAP + 3.0 * (PANEL_W + GAP), HEADER + PANEL_H + GAP)


static func panel_rect(i: int) -> Rect2:
	return Rect2(GAP + float(i) * (PANEL_W + GAP), HEADER, PANEL_W, PANEL_H)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#120726"))
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(24, 46), "Glow Patrol  -  hunter design directions, round 2 (anime pass)", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, WHITE)
	var panels: Array = [
		["A  STAGE STAR", "idol jacket, high ponytail, star wand, wink", PINK, _stage_star],
		["B  NIGHT PATROL", "oversized hoodie, cotton-candy buns, glow bat", GOLD, _night_patrol],
		["C  GLOOM BREAKER", "armour plates, cape, sharp bob, twin light-sticks", VIOLET.lightened(0.35), _gloom_breaker],
	]
	for i in panels.size():
		var r: Rect2 = panel_rect(i)
		var accent: Color = panels[i][2]
		_panel_bg(r, accent, i)
		o = Vector2(r.position.x + PANEL_W * 0.5, r.end.y - 96.0)
		_fill(ell(0, 3, 64, 11), Color(0, 0, 0, 0.4))
		(panels[i][3] as Callable).call()
		draw_string(font, Vector2(r.position.x + 22, r.end.y - 52), panels[i][0], HORIZONTAL_ALIGNMENT_LEFT, -1, 28, accent)
		draw_string(font, Vector2(r.position.x + 22, r.end.y - 20), panels[i][1], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(WHITE, 0.8))


func _panel_bg(r: Rect2, accent: Color, seed_i: int) -> void:
	var corners := PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	draw_polygon(corners, PackedColorArray([NAVY, NAVY, Color("#140A2C"), Color("#140A2C")]))
	var c := Vector2(r.position.x + PANEL_W * 0.5, r.position.y + PANEL_H * 0.42)
	for k in 8:
		draw_circle(c, 230.0 - float(k) * 26.0, Color(accent, 0.035), true, -1.0, true)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77 + seed_i
	for k in 26:
		var sp := Vector2(rng.randf_range(r.position.x + 10, r.end.x - 10), rng.randf_range(r.position.y + 10, r.end.y - 140))
		draw_circle(sp, rng.randf_range(0.8, 2.2), Color(WHITE, rng.randf_range(0.25, 0.7)), true, -1.0, true)


# ---------- A: Stage Star ----------

func _stage_star() -> void:
	var hair := Color("#4A2585")
	var hx := 0.0
	var hy := -240.0
	hair_lock(Vector2(hx + 22, hy - 50), Vector2(hx + 96, hy - 86), Vector2(hx + 102, hy + 20), 30, hair)
	hair_lock(Vector2(hx + 20, hy - 46), Vector2(hx + 76, hy - 50), Vector2(hx + 82, hy + 88), 26, hair)
	hair_lock(Vector2(hx + 24, hy - 52), Vector2(hx + 112, hy - 62), Vector2(hx + 120, hy + 52), 18, hair)
	for side in [-1.0, 1.0]:
		limb([side * 12, -100, side * 15, -16], 15, SKIN)
		limb([side * 14.4, -58, side * 15, -18], 16.5, WHITE)
		line([side * 6.5, -54, side * 22.5, -54], PINK, 3.0)
		var boot: Array = [-27, -28, -5, -28, -3, -8, 0, 0, -33, 0, -31, -10]
		var sole: Array = [-35, -1, 1, -1, 1, 6, -35, 6]
		poly(boot if side < 0.0 else mirror(boot), PINK)
		poly(sole if side < 0.0 else mirror(sole), WHITE)
		blob(side * 16, -19, 4.5, 3.5, GOLD)
	limb([-32, -176, -54, -148, -35, -124], 14, PINK)
	blob(-38, -128, 8, 5, WHITE)
	blob(-33, -121, 6.5, 6.5, SKIN)
	poly([-25, -130, 25, -130, 46, -86, -46, -86], VIOLET)
	for x in [-30.0, -15.0, 0.0, 15.0, 30.0]:
		line([x * 0.55, -128, x, -88], Color(INK, 0.45), 1.2)
	line([-44, -91, 44, -91], GOLD, 2.5)
	limb([0, -198, 0, -180], 12, SKIN)
	_fill(ell(0, -193, 8, 3.5), SKIN_SH)
	poly([-26, -182, 26, -182, 22, -128, -22, -128], WHITE)
	star(0, -158, 10, 4.5, GOLD)
	poly([-24, -136, 24, -136, 24, -126, -24, -126], NAVY)
	blob(0, -131, 5, 4, GOLD)
	var jacket: Array = [-35, -183, -6, -187, -14, -160, -16, -146, -34, -143]
	poly(jacket, PINK)
	poly(mirror(jacket), PINK)
	poly([-6, -187, -16, -176, -12, -170], GOLD)
	poly([6, -187, 16, -176, 12, -170], GOLD)
	blob(-36, -178, 11, 8, GOLD)
	stick(51, -244, 55, -322, 6, GOLD)
	star(55, -336, 22, 10, GOLD)
	line([55, -322, 74, -300, 68, -276, 84, -258], PINK, 3.0)
	line([55, -322, 38, -296, 46, -272], VIOLET.lightened(0.3), 3.0)
	limb([32, -176, 55, -208, 51, -238], 14, PINK)
	blob(36, -178, 11, 8, GOLD)
	blob(52, -238, 8, 5, WHITE)
	blob(51, -247, 7.5, 7.5, SKIN)
	back_hair(hx, hy, hair, 24.0)
	head(hx, hy)
	side_lock(hx, hy, hair, 52.0)
	hair_front(hx, hy, hair, 0.0, true)
	blob(hx + 21, hy - 47, 7, 5, PINK)
	star(hx - 30, hy - 30, 9, 4, GOLD)
	face(hx, hy, "wink", PINK, hair.darkened(0.3))
	line([hx - 40, hy + 4, hx - 38, hy + 26, hx - 22, hy + 34], INK, 1.8)
	blob(hx - 21, hy + 34, 3, 3, NAVY)


# ---------- B: Night Patrol ----------

func _night_patrol() -> void:
	var hair := Color("#FF9BCB")
	var hx := 0.0
	var hy := -240.0
	poly([-14, -192, -42, -200, -74, -190, -104, -198, -98, -174, -72, -168, -42, -176, -18, -174], GOLD)
	line([-58, -194, -58, -172], Color(PINK, 0.9), 2.5)
	line([-84, -192, -82, -172], Color(PINK, 0.9), 2.5)
	for side in [-1.0, 1.0]:
		limb([side * 13, -96, side * 16, -18], 15, SKIN)
		var shoe: Array = [-27, -32, -6, -32, -4, -12, 3, -7, 3, 1, -33, 1, -31, -12]
		poly(shoe if side < 0.0 else mirror(shoe), WHITE)
		var toe: Array = [-6, -8, 3, -7, 3, 1, -12, 1]
		poly(toe if side < 0.0 else mirror(toe), PINK)
		line([side * 11, -26, side * 21, -26], PINK, 2.0)
		line([side * 11, -20, side * 21, -20], PINK, 2.0)
	poly([-29, -118, 29, -118, 31, -86, 3, -86, 0, -96, -3, -86, -31, -86], NAVY.lightened(0.1))
	limb([-38, -176, -68, -170, -62, -204], 19, VIOLET)
	blob(-63, -200, 11, 7, VIOLET.lightened(0.15))
	limb([-66, -216, -72, -236], 4.2, SKIN)
	limb([-59, -217, -56, -238], 4.2, SKIN)
	blob(-63, -212, 7.5, 7.5, SKIN)
	blob(0, -186, 46, 16, VIOLET.darkened(0.25))
	limb([0, -198, 0, -182], 12, SKIN)
	_fill(ell(0, -193, 8, 3.5), SKIN_SH)
	poly([-40, -184, 40, -184, 47, -150, 47, -104, -47, -104, -47, -150], VIOLET)
	poly([-44, -106, 44, -106, 43, -94, -43, -94], VIOLET.darkened(0.2))
	poly([-22, -134, 22, -134, 29, -110, -29, -110], VIOLET.darkened(0.08))
	line([-7, -182, -9, -158], WHITE, 2.0)
	line([7, -182, 9, -158], WHITE, 2.0)
	glow(-24, -160, 22, GOLD)
	blob(-24, -160, 9, 10, GOLD)
	_fill(pts([-28, -164, -20, -164, -20, -156, -28, -156]), NAVY.lightened(0.2))
	line([-24, -172, -24, -169], INK, 2.0)
	poly([-27, -192, 27, -192, 29, -176, -29, -176], GOLD)
	poly([-20, -177, -8, -177, -10, -150, -22, -153], GOLD)
	line([-21, -164, -9, -163], PINK, 2.0)
	blob(-15, -178, 8, 7, GOLD)
	limb([38, -176, 56, -148, 55, -124], 19, VIOLET)
	blob(55, -128, 11, 7, VIOLET.lightened(0.15))
	bat(55, -118, 112, -20, PINK)
	blob(55, -118, 7.5, 7.5, SKIN)
	for side in [-1.0, 1.0]:
		blob(hx + side * 36, hy - 44, 20, 19, hair)
		draw_arc(p(hx + side * 36 - 4, hy - 48), 11.0 * s, 3.4, 5.6, 10, hair.darkened(0.25), 1.6 * s, true)
		draw_arc(p(hx + side * 36, hy - 44), 15.0 * s, 0.4, 2.4, 10, hair.darkened(0.25), 1.6 * s, true)
	back_hair(hx, hy, hair, 12.0)
	head(hx, hy)
	side_lock(hx, hy, hair, 32.0)
	hair_front(hx, hy, hair, 0.0, true)
	for side in [-1.0, 1.0]:
		blob(hx + side * 27, hy - 30, 8, 5, PINK)
	face(hx, hy, "smile", Color("#FFA62B"), hair.darkened(0.35))
	poly([hx + 22, hy + 25, hx + 33, hy + 21, hx + 35, hy + 27, hx + 24, hy + 31], WHITE)
	line([hx + 27, hy + 24, hx + 29, hy + 28], Color(INK, 0.4), 1.1)


# ---------- C: Gloom Breaker ----------

func _gloom_breaker() -> void:
	var hair := Color("#2A1F55")
	var hx := 0.0
	var hy := -240.0
	poly([-34, -184, 34, -184, 58, -120, 78, -58, 40, -72, 0, -62, -40, -72, -78, -58, -58, -120], PINK)
	for side in [-1.0, 1.0]:
		limb([side * 13, -100, side * 24, -56, side * 30, -16], 14, NAVY.lightened(0.22))
		blob(side * 24, -58, 8.5, 7.5, VIOLET)
		var boot: Array = [-40, -40, -20, -40, -18, -10, -13, 1, -46, 1, -44, -12]
		poly(boot if side < 0.0 else mirror(boot), VIOLET)
		line([side * 40, -36, side * 20, -36], GOLD, 2.5)
		line([side * 45, 3, side * 13, 3], PINK, 2.5)
	poly([-26, -182, 26, -182, 21, -130, 25, -100, -25, -100, -21, -130], NAVY.lightened(0.12))
	poly([-24, -134, 24, -134, 25, -122, -25, -122], NAVY.darkened(0.2))
	poly([0, -136, 6, -128, 0, -120, -6, -128], GOLD)
	var tasset: Array = [-25, -122, -6, -122, -8, -98, -27, -102]
	poly(tasset, VIOLET)
	poly(mirror(tasset), VIOLET)
	limb([0, -198, 0, -180], 12, SKIN)
	_fill(ell(0, -193, 8, 3.5), SKIN_SH)
	var plate: Array = [-25, -181, 25, -181, 27, -160, 14, -142, 0, -138, -14, -142, -27, -160]
	poly(plate, VIOLET)
	var trim := pts(plate)
	var mid := p(0, -162)
	for i in trim.size():
		trim[i] = trim[i].lerp(mid, 0.12)
	trim.append(trim[0])
	draw_polyline(trim, GOLD, 2.0 * s, true)
	glow(0, -160, 16, PINK)
	poly([0, -168, 6, -160, 0, -151, -6, -160], PINK)
	for side in [-1.0, 1.0]:
		limb([side * 32, -176, side * 54, -160, side * 62, -142], 13, NAVY.lightened(0.12))
		stick(side * 62, -138, side * 118, -252, 6, PINK if side > 0.0 else Color("#8FE3FF"))
		blob(side * 62, -138, 8, 8, NAVY.lightened(0.25))
		line([side * 57, -142, side * 67, -138], GOLD, 2.0)
		var pad: Array = [-24, -190, -46, -186, -56, -166, -36, -168]
		poly(pad if side < 0.0 else mirror(pad), VIOLET)
		var edge: Array = [-26, -186, -44, -182, -52, -168]
		line(edge if side < 0.0 else mirror(edge), GOLD, 2.0)
	back_hair(hx, hy, hair, 40.0, 54.0)
	head(hx, hy)
	side_lock(hx, hy, hair, 46.0)
	hair_front(hx, hy, hair, -9.0, false)
	hair_lock(Vector2(hx - 12, hy - 46), Vector2(hx - 26, hy - 20), Vector2(hx - 28, hy + 8), 12, PINK)
	face(hx, hy, "fierce", VIOLET.lightened(0.35), hair)
	line([hx - 30, hy + 27, hx - 22, hy + 24], PINK, 2.0)
	line([hx - 29, hy + 31, hx - 21, hy + 28], PINK, 2.0)
	poly([hx + 30, hy - 40, hx + 40, hy - 40, hx + 33, hy - 30, hx + 41, hy - 30, hx + 28, hy - 16, hx + 32, hy - 27, hx + 25, hy - 27], GOLD)
