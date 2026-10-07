extends RefCounted
## Near-ground props for Alley Brawl (Story 025): crates, lampposts, steam vents, a noodle cart,
## a bicycle, barrels, benches and light-reflecting puddles, plus the twinkle that hints at a
## secret spot. Positions are in view widths (S) along the world; drawn at parallax 1.0 and
## culled to the screen. `t` = 0.0 means static (reduce motion).

const World := preload("res://scenes/battle/brawl_world.gd")

const PROPS := [
	{"x": 0.12, "k": "lamp"}, {"x": 0.45, "k": "cart"}, {"x": 0.62, "k": "crate"}, {"x": 0.88, "k": "barrel"},
	{"x": 1.12, "k": "vent"}, {"x": 1.24, "k": "puddle"}, {"x": 1.4, "k": "lamp"}, {"x": 1.5, "k": "bike"},
	{"x": 1.64, "k": "crate"}, {"x": 1.78, "k": "puddle"}, {"x": 2.02, "k": "vent"}, {"x": 2.12, "k": "lamp"},
	{"x": 2.32, "k": "bench"}, {"x": 2.58, "k": "puddle"}, {"x": 2.78, "k": "lamp"}, {"x": 3.02, "k": "puddle"},
	{"x": 3.22, "k": "lamp"}, {"x": 3.4, "k": "barrel"}, {"x": 0.34, "k": "puddle"}, {"x": 0.98, "k": "puddle"},
]


static func _c(col: Color, a: float) -> Color:
	return Color(col.r, col.g, col.b, col.a * a)


## Draws every prop that is on screen, then the secret twinkles for spots not yet found.
static func draw(ci: CanvasItem, cam_x: float, size: Vector2, ground_y: float, u: float, t: float, found: Array) -> void:
	var pal: Dictionary = World.palette_at(cam_x + size.x * 0.5, size.x)
	for p in PROPS:
		var x: float = float(p["x"]) * size.x - cam_x
		if x < -90.0 * u or x > size.x + 90.0 * u:
			continue
		var base := Vector2(x, ground_y - 4.0 * u)
		match String(p["k"]):
			"lamp": _lamp(ci, base, u, pal)
			"cart": _cart(ci, base, u, t, pal)
			"crate": _crate(ci, base, u)
			"barrel": _barrel(ci, base, u)
			"vent": _vent(ci, base, u, t)
			"bike": _bike(ci, base, u, pal)
			"bench": _bench(ci, base, u)
			"puddle": _puddle(ci, Vector2(x, ground_y + 38.0 * u), u, t, pal)
	for i in World.SECRETS.size():
		if i < found.size() and bool(found[i]):
			continue
		var s: Dictionary = World.SECRETS[i]
		var sx: float = float(s["x"]) * size.x - cam_x
		if sx < -20.0 * u or sx > size.x + 20.0 * u:
			continue
		var dy: float = 150.0 if String(s["kind"]) == "ledge" else (68.0 if String(s["kind"]) == "lamp" else 40.0)
		var pulse: float = 1.0 if t == 0.0 else 0.6 + 0.4 * sin(t * 4.0 + float(i))
		_glint(ci, Vector2(sx, ground_y - dy * u), 9.0 * u * pulse, Color("#FFE9A0"))


static func _glint(ci: CanvasItem, c: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for k in 8:
		var a: float = TAU * float(k) / 8.0 - PI * 0.5
		var rr: float = r if k % 2 == 0 else r * 0.3
		pts.append(c + Vector2(cos(a), sin(a)) * rr)
	ci.draw_colored_polygon(pts, col)
	ci.draw_circle(c, r * 1.5, _c(col, 0.18))


static func _lamp(ci: CanvasItem, b: Vector2, u: float, pal: Dictionary) -> void:
	var warm: Color = pal["a"]
	ci.draw_rect(Rect2(b.x - 3.0 * u, b.y - 150.0 * u, 6.0 * u, 150.0 * u), Color("#1A1236"))
	ci.draw_rect(Rect2(b.x - 9.0 * u, b.y - 6.0 * u, 18.0 * u, 6.0 * u), Color("#1A1236"))
	ci.draw_circle(b + Vector2(0, -158.0 * u), 34.0 * u, _c(warm, 0.1))
	ci.draw_circle(b + Vector2(0, -158.0 * u), 20.0 * u, _c(warm, 0.2))
	ci.draw_rect(Rect2(b.x - 8.0 * u, b.y - 168.0 * u, 16.0 * u, 20.0 * u), _c(warm, 0.95))
	ci.draw_colored_polygon(PackedVector2Array([b + Vector2(-11.0, -168.0) * u, b + Vector2(11.0, -168.0) * u, b + Vector2(0.0, -178.0) * u]), Color("#1A1236"))


static func _cart(ci: CanvasItem, b: Vector2, u: float, t: float, pal: Dictionary) -> void:
	ci.draw_rect(Rect2(b.x - 44.0 * u, b.y - 52.0 * u, 88.0 * u, 36.0 * u), Color("#5A2A2A"))
	ci.draw_rect(Rect2(b.x - 44.0 * u, b.y - 52.0 * u, 88.0 * u, 6.0 * u), Color("#FFB35E"))
	ci.draw_colored_polygon(PackedVector2Array([b + Vector2(-52.0, -92.0) * u, b + Vector2(52.0, -92.0) * u, b + Vector2(44.0, -70.0) * u, b + Vector2(-44.0, -70.0) * u]), pal["b"])
	ci.draw_rect(Rect2(b.x - 40.0 * u, b.y - 70.0 * u, 3.0 * u, 18.0 * u), Color("#3B2A2A"))
	ci.draw_rect(Rect2(b.x + 37.0 * u, b.y - 70.0 * u, 3.0 * u, 18.0 * u), Color("#3B2A2A"))
	ci.draw_circle(b + Vector2(0, -60.0) * u, 8.0 * u, _c(pal["a"], 0.35))
	ci.draw_circle(b + Vector2(-26.0, -4.0) * u, 11.0 * u, Color("#2A1A1A"))
	ci.draw_circle(b + Vector2(26.0, -4.0) * u, 11.0 * u, Color("#2A1A1A"))
	for k in 3:
		var rise: float = 0.0 if t == 0.0 else fposmod(t * 0.6 + float(k) * 0.33, 1.0)
		ci.draw_circle(b + Vector2(-8.0 + float(k) * 8.0, -98.0 - 26.0 * rise - float(k) * 6.0) * u, (6.0 + 5.0 * rise) * u, Color(1, 1, 1, 0.22 * (1.0 - rise)))


static func _crate(ci: CanvasItem, b: Vector2, u: float) -> void:
	var r := Rect2(b.x - 30.0 * u, b.y - 56.0 * u, 60.0 * u, 56.0 * u)
	ci.draw_rect(r, Color("#6B4A2E"))
	ci.draw_rect(r, Color("#3A2616"), false, 3.0 * u)
	ci.draw_line(r.position, r.position + r.size, Color("#3A2616"), 3.0 * u)
	ci.draw_line(r.position + Vector2(r.size.x, 0), r.position + Vector2(0, r.size.y), Color("#3A2616"), 3.0 * u)
	var r2 := Rect2(b.x + 4.0 * u, b.y - 86.0 * u, 34.0 * u, 30.0 * u)
	ci.draw_rect(r2, Color("#7B5636"))
	ci.draw_rect(r2, Color("#3A2616"), false, 2.5 * u)


static func _barrel(ci: CanvasItem, b: Vector2, u: float) -> void:
	ci.draw_rect(Rect2(b.x - 20.0 * u, b.y - 52.0 * u, 40.0 * u, 52.0 * u), Color("#3F5A7A"))
	for y in [-42.0, -12.0]:
		ci.draw_rect(Rect2(b.x - 20.0 * u, b.y + y * u, 40.0 * u, 4.0 * u), Color("#1E2E44"))
	ci.draw_rect(Rect2(b.x - 20.0 * u, b.y - 52.0 * u, 40.0 * u, 5.0 * u), Color("#9CC0E8"))


static func _vent(ci: CanvasItem, b: Vector2, u: float, t: float) -> void:
	ci.draw_rect(Rect2(b.x - 22.0 * u, b.y - 14.0 * u, 44.0 * u, 14.0 * u), Color("#2A2250"))
	for k in 4:
		ci.draw_rect(Rect2(b.x - 18.0 * u + float(k) * 10.0 * u, b.y - 11.0 * u, 5.0 * u, 8.0 * u), Color("#0C0720"))
	for k in 4:
		var rise: float = 0.35 + float(k) * 0.15 if t == 0.0 else fposmod(t * 0.5 + float(k) * 0.25, 1.0)
		ci.draw_circle(b + Vector2(sin(rise * 5.0 + float(k)) * 6.0, -18.0 - 70.0 * rise) * u, (8.0 + 12.0 * rise) * u, Color(1, 1, 1, 0.26 * (1.0 - rise)))


static func _bike(ci: CanvasItem, b: Vector2, u: float, pal: Dictionary) -> void:
	var col: Color = pal["b"]
	for dx in [-24.0, 24.0]:
		ci.draw_arc(b + Vector2(dx, -18.0) * u, 17.0 * u, 0.0, TAU, 20, Color("#1A1236"), 3.0 * u)
	ci.draw_polyline(PackedVector2Array([b + Vector2(-24, -18) * u, b + Vector2(-6, -44) * u, b + Vector2(16, -44) * u, b + Vector2(24, -18) * u]), col, 3.0 * u)
	ci.draw_line(b + Vector2(-6, -44) * u, b + Vector2(0, -18) * u, col, 3.0 * u)
	ci.draw_line(b + Vector2(16, -44) * u, b + Vector2(12, -56) * u, col, 3.0 * u)
	ci.draw_rect(Rect2(b.x - 14.0 * u, b.y - 50.0 * u, 16.0 * u, 5.0 * u), Color("#1A1236"))


static func _bench(ci: CanvasItem, b: Vector2, u: float) -> void:
	ci.draw_rect(Rect2(b.x - 36.0 * u, b.y - 28.0 * u, 72.0 * u, 7.0 * u), Color("#5B3F6B"))
	ci.draw_rect(Rect2(b.x - 36.0 * u, b.y - 50.0 * u, 72.0 * u, 6.0 * u), Color("#5B3F6B"))
	for dx in [-30.0, 26.0]:
		ci.draw_rect(Rect2(b.x + dx * u, b.y - 50.0 * u, 5.0 * u, 50.0 * u), Color("#2A1A44"))


static func _puddle(ci: CanvasItem, c: Vector2, u: float, t: float, pal: Dictionary) -> void:
	var rx: float = 46.0 * u
	var ry: float = 9.0 * u
	var pts := PackedVector2Array()
	for k in 18:
		var a: float = TAU * float(k) / 18.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	ci.draw_colored_polygon(pts, Color(0.1, 0.12, 0.3, 0.7))
	var shimmer: float = 0.0 if t == 0.0 else sin(t * 1.8 + c.x * 0.01) * 5.0 * u
	ci.draw_rect(Rect2(c.x - 14.0 * u + shimmer, c.y - 2.5 * u, 28.0 * u, 3.0 * u), _c(pal["a"], 0.65))
	ci.draw_rect(Rect2(c.x - 26.0 * u - shimmer, c.y + 2.0 * u, 18.0 * u, 2.0 * u), _c(pal["b"], 0.55))
