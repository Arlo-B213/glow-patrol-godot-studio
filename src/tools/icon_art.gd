extends Control
## Draws the Glowstick Patrol app icon (rounded square, glow, hunter bust, sparkles).
## Used by make_icon.gd; the hunter comes from the shared HunterArt so the icon matches the game.

const HunterArt := preload("res://scripts/hunter_art.gd")

const BG_TOP := Color("#2A1457")
const BG_MID := Color("#6A2B94")
const BG_BOTTOM := Color("#FF5FA2")
const GOLD := Color("#FFC15E")
const TEAL := Color("#52E8C6")
const WHITE := Color("#F5EFFF")


## The fixed look used for the icon (independent of the player's save).
static func icon_look() -> Dictionary:
	return {
		"outfit": Color("#FF5FA2"),
		"outfit_style": "sequin",
		"hair": Color("#FFC15E"),
		"glow": GOLD,
		"hairstyle": "twintails",
		"headwear": "star-clip",
		"face_acc": "none",
	}


func _draw() -> void:
	var s: float = minf(size.x, size.y)
	var r: float = s * 0.22
	_draw_background(s, r)
	_draw_glow(s)
	# Hunter bust crop in a square rect, slightly low so the face and the glowstick fill the frame.
	var rect := Rect2(s * 0.06, s * 0.14, s * 0.88, s * 0.92)
	HunterArt.draw_portrait(self, rect, icon_look(), 0.0, 1.0, false)
	_draw_sparkles(s)
	_draw_rim(s, r)


func _rounded_points(s: float, r: float, inset: float = 0.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var corners := [
		[Vector2(s - r - inset, r + inset), -PI * 0.5],
		[Vector2(s - r - inset, s - r - inset), 0.0],
		[Vector2(r + inset, s - r - inset), PI * 0.5],
		[Vector2(r + inset, r + inset), PI],
	]
	var rr: float = r
	for c in corners:
		var center: Vector2 = c[0]
		var a0: float = c[1]
		for i in range(11):
			var a: float = a0 + (PI * 0.5) * float(i) / 10.0
			pts.append(center + Vector2(cos(a), sin(a)) * rr)
	return pts


func _draw_background(s: float, r: float) -> void:
	var pts := _rounded_points(s, r)
	var cols := PackedColorArray()
	for p in pts:
		var t: float = clampf(p.y / s, 0.0, 1.0)
		var c: Color = BG_TOP.lerp(BG_MID, minf(t * 2.0, 1.0))
		if t > 0.5:
			c = BG_MID.lerp(BG_BOTTOM, (t - 0.5) * 2.0)
		cols.append(c)
	draw_polygon(pts, cols)


func _draw_glow(s: float) -> void:
	var c := Vector2(s * 0.5, s * 0.46)
	for i in range(8):
		var rad: float = s * (0.46 - float(i) * 0.04)
		draw_circle(c, rad, Color(GOLD.r, GOLD.g, GOLD.b, 0.06))
	# Soft spotlight beams from the top.
	draw_colored_polygon(PackedVector2Array([Vector2(s * 0.38, 0.0), Vector2(s * 0.62, 0.0), Vector2(s * 0.86, s), Vector2(s * 0.14, s)]), Color(1.0, 0.95, 0.8, 0.07))


func _four_point_star(c: Vector2, rad: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(8):
		var a: float = -PI * 0.5 + float(i) * PI * 0.25
		var rr: float = rad if i % 2 == 0 else rad * 0.32
		pts.append(c + Vector2(cos(a), sin(a)) * rr)
	return pts


func _draw_sparkles(s: float) -> void:
	var spots := [
		[Vector2(0.14, 0.22), 0.07, GOLD],
		[Vector2(0.86, 0.14), 0.09, WHITE],
		[Vector2(0.9, 0.5), 0.05, TEAL],
		[Vector2(0.1, 0.62), 0.05, WHITE],
		[Vector2(0.78, 0.82), 0.06, GOLD],
	]
	for sp in spots:
		draw_colored_polygon(_four_point_star(Vector2(sp[0]) * s, float(sp[1]) * s), sp[2])


func _draw_rim(s: float, r: float) -> void:
	var pts := _rounded_points(s, r, s * 0.012)
	pts.append(pts[0])
	draw_polyline(pts, Color(1.0, 1.0, 1.0, 0.35), maxf(2.0, s * 0.016), true)
