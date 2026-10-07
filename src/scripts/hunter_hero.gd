extends RefCounted
## Stage backdrop + full-body hunter ("hero portrait") used on the HQ card and the Club
## preview. Everything is code-drawn (no shaders) and every polygon is simple/convex or a
## simple star so triangulation never fails.

const HunterArt := preload("res://scripts/hunter_art.gd")
const HunterMotion := preload("res://scripts/hunter_motion.gd")

## Sparkle layout: x fraction, y fraction, size fraction, twinkle speed, palette index.
const SPARKLES := [
	[0.12, 0.10, 1.0, 1.7, 0], [0.86, 0.14, 0.8, 2.3, 1], [0.22, 0.30, 0.6, 2.9, 2],
	[0.80, 0.34, 1.1, 1.3, 3], [0.08, 0.52, 0.8, 2.1, 1], [0.92, 0.55, 0.6, 3.1, 0],
	[0.18, 0.74, 1.0, 1.9, 3], [0.84, 0.76, 0.7, 2.6, 2], [0.50, 0.05, 0.6, 2.2, 0],
	[0.34, 0.18, 0.5, 3.3, 1],
]
const BG_TOP := Color("#2A1250")
const BG_BOTTOM := Color("#0F0626")
const SPOT_WARM := Color("#FFE3A8")


## Draws the stage and the full-body hunter inside `rect` (in `ci` canvas pixels).
## `t` is seconds for the idle animation; `animate` = false (or reduced motion) gives a still.
static func draw_hero(ci: CanvasItem, rect: Rect2, look: Dictionary, t: float = 0.0, animate: bool = true) -> void:
	if rect.size.x <= 8.0 or rect.size.y <= 8.0:
		return
	var live: bool = animate and t != 0.0 and HunterMotion.motion_on()
	var tt: float = t if live else 0.0
	var glow: Color = Color(look.get("glow", UiTheme.ACCENT))
	var outfit: Color = Color(look.get("outfit", UiTheme.ACCENT))
	var halo_col: Color = glow.lerp(outfit, 0.35)
	var w: float = rect.size.x
	var h: float = rect.size.y
	var cx: float = rect.position.x + w * 0.5
	var floor_y: float = rect.position.y + h * 0.90

	_draw_backdrop(ci, rect, tt, live)
	_draw_spotlight(ci, rect, cx, floor_y, tt, live)
	_draw_halo(ci, Vector2(cx, rect.position.y + h * 0.50), minf(w, h) * 0.46, halo_col, tt, live)
	_draw_floor(ci, Vector2(cx, floor_y), w * 0.36, h * 0.05, glow)
	_draw_sparkles(ci, rect, tt, live)

	var inner_h: float = h * 0.82
	# Keep the inner rect tall and narrow so draw_portrait always picks the full-body framing
	# (it crops to the bust when the rect is squarer than about 1:1.2).
	var inner_w: float = minf(w, inner_h * 0.66)
	var inner := Rect2(rect.position.x + (w - inner_w) * 0.5, rect.position.y + h * 0.04, inner_w, inner_h)
	HunterArt.draw_portrait(ci, inner, look, t, 1.0, animate)


static func _draw_backdrop(ci: CanvasItem, rect: Rect2, t: float, live: bool) -> void:
	var r: float = minf(22.0, minf(rect.size.x, rect.size.y) * 0.08)
	var sb := StyleBoxFlat.new()
	sb.bg_color = BG_TOP.lerp(BG_BOTTOM, 0.45)
	sb.set_corner_radius_all(int(r))
	sb.border_color = UiTheme.VIOLET.darkened(0.2)
	sb.set_border_width_all(2)
	ci.draw_style_box(sb, rect)
	# Vertical gradient band (kept clear of the rounded corners).
	var y0: float = rect.position.y + r
	var y1: float = rect.end.y - r
	var pts := PackedVector2Array([
		Vector2(rect.position.x + 2.0, y0), Vector2(rect.end.x - 2.0, y0),
		Vector2(rect.end.x - 2.0, y1), Vector2(rect.position.x + 2.0, y1)])
	var top_c: Color = BG_TOP.lerp(BG_BOTTOM, 0.25)
	var bot_c: Color = BG_BOTTOM
	ci.draw_polygon(pts, PackedColorArray([top_c, top_c, bot_c, bot_c]))


static func _draw_spotlight(ci: CanvasItem, rect: Rect2, cx: float, floor_y: float, t: float, live: bool) -> void:
	var pulse: float = 0.5 + 0.5 * sin(t * 0.9) if live else 0.5
	var a: float = 0.16 + 0.07 * pulse
	var top_y: float = rect.position.y + 3.0
	var tw: float = rect.size.x * 0.08
	var bw: float = rect.size.x * (0.40 + 0.04 * pulse)
	var warm_top := Color(SPOT_WARM.r, SPOT_WARM.g, SPOT_WARM.b, a * 1.6)
	var warm_bot := Color(SPOT_WARM.r, SPOT_WARM.g, SPOT_WARM.b, a * 0.25)
	var pts := PackedVector2Array([
		Vector2(cx - tw, top_y), Vector2(cx + tw, top_y),
		Vector2(cx + bw, floor_y), Vector2(cx - bw, floor_y)])
	ci.draw_polygon(pts, PackedColorArray([warm_top, warm_top, warm_bot, warm_bot]))
	# Narrower bright core.
	var core := PackedVector2Array([
		Vector2(cx - tw * 0.5, top_y), Vector2(cx + tw * 0.5, top_y),
		Vector2(cx + bw * 0.5, floor_y), Vector2(cx - bw * 0.5, floor_y)])
	var core_top := Color(1.0, 0.97, 0.88, a * 1.2)
	var core_bot := Color(1.0, 0.97, 0.88, 0.0)
	ci.draw_polygon(core, PackedColorArray([core_top, core_top, core_bot, core_bot]))


static func _draw_halo(ci: CanvasItem, c: Vector2, radius: float, col: Color, t: float, live: bool) -> void:
	var pulse: float = 1.0 + 0.05 * sin(t * 1.4) if live else 1.0
	for i in 7:
		var f: float = float(i) / 6.0
		var rr: float = radius * pulse * (1.0 - f * 0.75)
		ci.draw_circle(c, rr, Color(col.r, col.g, col.b, 0.07 + 0.03 * f))
	ci.draw_arc(c, radius * pulse * 0.9, 0.0, TAU, 48, Color(col.r, col.g, col.b, 0.35), 2.0)


static func _ellipse(c: Vector2, rx: float, ry: float, n: int = 40) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a: float = TAU * float(i) / float(n)
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


static func _draw_floor(ci: CanvasItem, c: Vector2, rx: float, ry: float, glow: Color) -> void:
	ci.draw_colored_polygon(_ellipse(c + Vector2(0.0, ry * 0.5), rx * 1.08, ry * 1.2), Color(0.0, 0.0, 0.0, 0.35))
	ci.draw_colored_polygon(_ellipse(c, rx, ry), Color("#3A1C6B"))
	ci.draw_colored_polygon(_ellipse(c, rx * 0.72, ry * 0.7), Color("#4D2A8A"))
	var rim := _ellipse(c, rx, ry, 48)
	rim.append(rim[0])
	ci.draw_polyline(rim, Color(glow.r, glow.g, glow.b, 0.9), 2.5, true)
	var inner_rim := _ellipse(c, rx * 0.72, ry * 0.7, 40)
	inner_rim.append(inner_rim[0])
	ci.draw_polyline(inner_rim, Color(glow.r, glow.g, glow.b, 0.35), 1.5, true)


static func _draw_sparkles(ci: CanvasItem, rect: Rect2, t: float, live: bool) -> void:
	var palette: Array[Color] = [UiTheme.GOLD, UiTheme.TEAL, UiTheme.ACCENT, UiTheme.VIOLET]
	var base: float = minf(rect.size.x, rect.size.y) * 0.035
	for s in SPARKLES:
		var tw: float = 0.5 + 0.5 * sin(t * float(s[3]) + float(s[0]) * 20.0) if live else 0.75
		var size: float = base * float(s[2]) * (0.55 + 0.6 * tw)
		var col: Color = palette[int(s[4])]
		col.a = 0.35 + 0.6 * tw
		var p := Vector2(rect.position.x + rect.size.x * float(s[0]), rect.position.y + rect.size.y * float(s[1]))
		_star(ci, p, size, col)


static func _star(ci: CanvasItem, c: Vector2, r: float, col: Color) -> void:
	var k: float = r * 0.22
	var pts := PackedVector2Array([
		c + Vector2(0, -r), c + Vector2(k, -k), c + Vector2(r, 0), c + Vector2(k, k),
		c + Vector2(0, r), c + Vector2(-k, k), c + Vector2(-r, 0), c + Vector2(-k, -k)])
	ci.draw_colored_polygon(pts, col)
