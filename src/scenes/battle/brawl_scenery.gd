extends RefCounted
## Alley Brawl scenery (Story 025): sky, moon, far skyline (parallax 0.3), mid row of shopfronts or
## bridge water (parallax 0.6), the floor, then props (brawl_props.gd) and drifting fireflies.
## Everything is drawn in screen space from `cam_x` and culled to the visible range. `t` is
## seconds for ambient motion; pass 0.0 for a static scene (reduce motion). `u` is the layout scale.

const World := preload("res://scenes/battle/brawl_world.gd")
const Props := preload("res://scenes/battle/brawl_props.gd")

const FAR_PARALLAX := 0.3
const MID_PARALLAX := 0.6
const FIREFLIES := 16


## Deterministic 0..1 hash of `i` (so buildings and shops look the same every frame).
static func hash01(i: int, salt: int = 0) -> float:
	return fposmod(sin(float(i) * 12.9898 + float(salt) * 78.233) * 43758.5453, 1.0)


static func _c(col: Color, a: float) -> Color:
	return Color(col.r, col.g, col.b, col.a * a)


## Draws the whole background (everything behind the actors).
static func draw_back(ci: CanvasItem, cam_x: float, size: Vector2, ground_y: float, u: float, t: float, found: Array) -> void:
	var pal: Dictionary = World.palette_at(cam_x + size.x * 0.5, size.x)
	var top: Color = pal["sky_top"]
	var bot: Color = pal["sky_bot"]
	ci.draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x, ground_y), Vector2(0, ground_y)]),
		PackedColorArray([top, top, bot, bot]))
	_stars(ci, cam_x, size, ground_y, u, t)
	_moon(ci, cam_x, size, ground_y, u, float(pal["moon"]))
	_skyline(ci, cam_x, size, ground_y, u, pal)
	_mid_row(ci, cam_x, size, ground_y, u, t)
	_floor(ci, cam_x, size, ground_y, u, pal)
	Props.draw(ci, cam_x, size, ground_y, u, t, found)


static func _stars(ci: CanvasItem, cam_x: float, size: Vector2, ground_y: float, u: float, t: float) -> void:
	for i in 14:
		var x: float = fposmod(hash01(i, 3) * size.x * 1.4 - cam_x * 0.05, size.x * 1.4) - size.x * 0.2
		var y: float = ground_y * 0.08 + hash01(i, 4) * ground_y * 0.3
		var tw: float = 0.55 + 0.35 * sin(t * 1.3 + float(i) * 2.1)
		ci.draw_circle(Vector2(x, y), (1.4 + hash01(i, 5)) * u, Color(1.0, 0.97, 0.85, 0.5 * tw))


static func _moon(ci: CanvasItem, cam_x: float, size: Vector2, ground_y: float, u: float, strength: float) -> void:
	if strength < 0.02:
		return
	var c := Vector2(size.x * 0.74 - cam_x * 0.04, ground_y * 0.3)
	ci.draw_circle(c, 78.0 * u, Color(0.75, 0.85, 1.0, 0.07 * strength))
	ci.draw_circle(c, 56.0 * u, Color(0.8, 0.9, 1.0, 0.12 * strength))
	ci.draw_circle(c, 40.0 * u, Color(0.93, 0.96, 1.0, 0.95 * strength))
	ci.draw_circle(c + Vector2(-12.0, -8.0) * u, 8.0 * u, Color(0.78, 0.84, 0.95, 0.5 * strength))
	ci.draw_circle(c + Vector2(14.0, 12.0) * u, 5.0 * u, Color(0.78, 0.84, 0.95, 0.5 * strength))


static func _skyline(ci: CanvasItem, cam_x: float, size: Vector2, ground_y: float, u: float, pal: Dictionary) -> void:
	var slot: float = 104.0 * u
	var off: float = cam_x * FAR_PARALLAX
	var first: int = int(floor(off / slot))
	var last: int = int(floor((off + size.x) / slot))
	var body: Color = pal["far"]
	var win: Color = pal["a"]
	var win2: Color = pal["b"]
	for i in range(first, last + 1):
		var x: float = float(i) * slot - off
		var h: float = ground_y * (0.26 + 0.3 * hash01(i, 1))
		var w: float = slot - 5.0 * u
		ci.draw_rect(Rect2(x, ground_y - h, w, h), body)
		if hash01(i, 2) > 0.6:
			ci.draw_rect(Rect2(x + w * 0.3, ground_y - h - 14.0 * u, w * 0.4, 14.0 * u), body)
		var rows: int = int(h / (30.0 * u))
		for r in rows:
			for c in 3:
				if hash01(i * 31 + r * 7 + c, 9) < 0.5:
					continue
				var col: Color = win if hash01(i + r, c) > 0.35 else win2
				ci.draw_rect(Rect2(x + 10.0 * u + float(c) * 26.0 * u, ground_y - h + 10.0 * u + float(r) * 30.0 * u, 9.0 * u, 13.0 * u), _c(col, 0.62))


static func _mid_row(ci: CanvasItem, cam_x: float, size: Vector2, ground_y: float, u: float, t: float) -> void:
	var slot: float = 156.0 * u
	var off: float = cam_x * MID_PARALLAX
	var first: int = int(floor(off / slot))
	var last: int = int(floor((off + size.x) / slot))
	for i in range(first, last + 1):
		var x: float = float(i) * slot - off
		var pal: Dictionary = World.palette_at(x + slot * 0.5 + cam_x, size.x)
		match World.district_at(x + slot * 0.5 + cam_x, size.x):
			0: _noodle_shop(ci, x, slot, ground_y, u, t, i, pal)
			1: _neon_shop(ci, x, slot, ground_y, u, t, i, pal)
			_: _bridge_bay(ci, x, slot, ground_y, u, t, i, pal)
	var moon: float = float(World.palette_at(cam_x + size.x * 0.5, size.x)["moon"])
	if moon > 0.05:
		var mx: float = size.x * 0.74 - cam_x * 0.04
		for k in 5:
			var w: float = (46.0 - float(k) * 7.0) * u
			var wob: float = sin(t * 1.5 + float(k)) * 4.0 * u
			ci.draw_rect(Rect2(mx - w * 0.5 + wob, ground_y - 84.0 * u + float(k) * 9.0 * u, w, 2.5 * u), Color(0.93, 0.96, 1.0, 0.35 * moon))


static func _noodle_shop(ci: CanvasItem, x: float, slot: float, ground_y: float, u: float, t: float, i: int, pal: Dictionary) -> void:
	var w: float = slot - 8.0 * u
	var h: float = (118.0 + 46.0 * hash01(i, 11)) * u
	var top: float = ground_y - h
	var warm: Color = pal["a"]
	var awn: Color = pal["b"]
	ci.draw_rect(Rect2(x, top, w, h), pal["mid"])
	ci.draw_rect(Rect2(x, top, w, 6.0 * u), _c(warm, 0.35))
	var wy: float = ground_y - 78.0 * u
	ci.draw_rect(Rect2(x + 12.0 * u, wy, w - 24.0 * u, 52.0 * u), _c(warm, 0.78))
	ci.draw_rect(Rect2(x + 12.0 * u, wy + 24.0 * u, w - 24.0 * u, 3.0 * u), _c(Color("#4A2238"), 0.7))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(x - 6.0 * u, wy), Vector2(x + w + 6.0 * u, wy), Vector2(x + w, wy - 18.0 * u), Vector2(x, wy - 18.0 * u)]), awn)
	for s in 5:
		if s % 2 == 0:
			ci.draw_rect(Rect2(x + float(s) * (w / 5.0), wy - 18.0 * u, w / 5.0, 18.0 * u), _c(Color.WHITE, 0.22))
	var sway: float = sin(t * 1.6 + float(i)) * 3.5 * u
	var lx: float = x + w * (0.25 if hash01(i, 12) > 0.5 else 0.75)
	ci.draw_line(Vector2(lx, wy), Vector2(lx + sway * 0.5, wy + 14.0 * u), Color("#3B2A2A"), 1.5 * u)
	ci.draw_circle(Vector2(lx + sway, wy + 22.0 * u), 12.0 * u, _c(warm, 0.18))
	ci.draw_circle(Vector2(lx + sway, wy + 22.0 * u), 7.0 * u, _c(awn, 0.95))
	ci.draw_rect(Rect2(x + w * 0.2, top + 16.0 * u, w * 0.6, 14.0 * u), _c(awn, 0.85))
	ci.draw_rect(Rect2(x + w * 0.2 + 4.0 * u, top + 20.0 * u, w * 0.6 - 8.0 * u, 6.0 * u), _c(Color("#FFF3D0"), 0.85))


static func _neon_shop(ci: CanvasItem, x: float, slot: float, ground_y: float, u: float, t: float, i: int, pal: Dictionary) -> void:
	var w: float = slot - 8.0 * u
	var h: float = (130.0 + 56.0 * hash01(i, 13)) * u
	var top: float = ground_y - h
	var pink: Color = pal["a"]
	var teal: Color = pal["b"]
	var neon: Color = pink if hash01(i, 14) > 0.45 else teal
	var flick: float = 1.0 if t == 0.0 else 0.82 + 0.18 * sin(t * 5.0 + float(i) * 3.0)
	ci.draw_rect(Rect2(x, top, w, h), pal["mid"])
	var sign_r := Rect2(x + 16.0 * u, top + 18.0 * u, w - 32.0 * u, 34.0 * u)
	ci.draw_rect(sign_r.grow(6.0 * u), _c(neon, 0.14 * flick))
	ci.draw_rect(sign_r, _c(neon, 0.95 * flick), false, 3.0 * u)
	var zig := PackedVector2Array()
	for k in 5:
		zig.append(Vector2(sign_r.position.x + 12.0 * u + float(k) * (sign_r.size.x - 24.0 * u) / 4.0, sign_r.position.y + (10.0 if k % 2 == 0 else 24.0) * u))
	ci.draw_polyline(zig, _c(teal if neon == pink else pink, 0.9 * flick), 2.5 * u)
	for r in 2:
		for c in 2:
			if hash01(i * 5 + r * 2 + c, 15) > 0.35:
				ci.draw_rect(Rect2(x + 18.0 * u + float(c) * (w * 0.45), top + 66.0 * u + float(r) * 30.0 * u, w * 0.28, 18.0 * u), _c(neon, 0.45))
	ci.draw_rect(Rect2(x + w * 0.38, ground_y - 46.0 * u, w * 0.24, 46.0 * u), _c(neon, 0.28))


static func _bridge_bay(ci: CanvasItem, x: float, slot: float, ground_y: float, u: float, t: float, i: int, pal: Dictionary) -> void:
	var water: Color = (pal["mid"] as Color).lerp(pal["b"], 0.22)
	ci.draw_rect(Rect2(x, ground_y - 96.0 * u, slot + 1.0, 64.0 * u), water)
	for k in 3:
		var wob: float = sin(t * 1.2 + float(i + k) * 1.9) * 6.0 * u
		ci.draw_rect(Rect2(x + 14.0 * u + wob + float(k) * 40.0 * u, ground_y - 84.0 * u + float(k) * 14.0 * u, 26.0 * u, 2.0 * u), _c(pal["b"], 0.5))
	ci.draw_rect(Rect2(x, ground_y - 36.0 * u, slot + 1.0, 4.0 * u), _c(pal["floor_line"], 0.8))
	for p in 4:
		ci.draw_rect(Rect2(x + float(p) * slot * 0.25, ground_y - 34.0 * u, 4.0 * u, 30.0 * u), _c(pal["floor_line"], 0.55))
	if hash01(i, 16) > 0.55:
		var lx: float = x + slot * 0.5
		var sway: float = sin(t * 1.3 + float(i)) * 4.0 * u
		ci.draw_line(Vector2(lx, ground_y - 170.0 * u), Vector2(lx + sway, ground_y - 138.0 * u), Color("#3B2A6B"), 2.0 * u)
		ci.draw_circle(Vector2(lx + sway, ground_y - 126.0 * u), 22.0 * u, _c(pal["a"], 0.15))
		ci.draw_circle(Vector2(lx + sway, ground_y - 126.0 * u), 12.0 * u, _c(pal["a"], 0.95))


static func _floor(ci: CanvasItem, cam_x: float, size: Vector2, ground_y: float, u: float, pal: Dictionary) -> void:
	ci.draw_rect(Rect2(0.0, ground_y, size.x, size.y - ground_y), pal["floor"])
	ci.draw_line(Vector2(0.0, ground_y), Vector2(size.x, ground_y), pal["floor_line"], 3.0 * u)
	var step: float = 120.0 * u
	var first: int = int(floor(cam_x / step))
	var last: int = int(floor((cam_x + size.x) / step))
	var lane_y: float = ground_y + (size.y - ground_y) * 0.16
	for i in range(first, last + 1):
		var x: float = float(i) * step - cam_x
		ci.draw_line(Vector2(x, ground_y), Vector2(x - 40.0 * u, lane_y * 1.0 + 60.0 * u), _c(pal["floor_line"], 0.18), 2.0 * u)
		ci.draw_rect(Rect2(x + 20.0 * u, lane_y, 46.0 * u, 3.0 * u), _c(pal["floor_line"], 0.3))


## Drifting glowmoths/fireflies in front of the action (static when `t` is 0.0).
static func draw_fore(ci: CanvasItem, cam_x: float, size: Vector2, ground_y: float, u: float, t: float) -> void:
	var pal: Dictionary = World.palette_at(cam_x + size.x * 0.5, size.x)
	var span: float = size.x * 1.5
	for i in FIREFLIES:
		var x: float = fposmod(hash01(i, 21) * span - cam_x * 0.85 + sin(t * 0.7 + float(i)) * 22.0 * u, span) - size.x * 0.25
		if x < -10.0 or x > size.x + 10.0:
			continue
		var y: float = ground_y * (0.3 + 0.62 * hash01(i, 22)) + sin(t * 0.9 + float(i) * 1.7) * 14.0 * u
		var a: float = 0.6 + 0.4 * sin(t * 2.2 + float(i) * 2.7)
		var col: Color = pal["a"] if i % 2 == 0 else pal["b"]
		ci.draw_circle(Vector2(x, y), 7.0 * u, _c(col, 0.14 * a))
		ci.draw_circle(Vector2(x, y), 2.4 * u, _c(Color.WHITE.lerp(col, 0.3), 0.9 * a))
