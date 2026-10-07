extends RefCounted
## Procedural art for Zap Patrol (Story 027): floating neon signs, a rooftop edge, floating
## Gloomling demons (bobbing + blinking), zap bolts and ripples. Every function draws onto a
## CanvasItem from its _draw(); `t` is animation seconds (0 = still pose when reduced motion).

const Kit := preload("res://scenes/games/game_kit.gd")
const BrawlArt := preload("res://scenes/battle/brawl_art.gd")
const INK := Color("#1A0B33")
const SIGNS := ["ZAP", "OPEN", "GLOW", "CAFE"]


static func _ellipse(c: Vector2, rx: float, ry: float, n: int = 20) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a: float = TAU * float(i) / float(n)
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


## Ground line (y of the rooftop surface) for a view of `size`.
static func roof_y(size: Vector2, u: float) -> float:
	return size.y - 46.0 * u


## Floating neon signs drifting gently above the skyline.
static func signs(ci: CanvasItem, size: Vector2, t: float, u: float) -> void:
	var cols: Array[Color] = [UiTheme.ACCENT, UiTheme.TEAL, UiTheme.GOLD, UiTheme.VIOLET]
	for i in SIGNS.size():
		var base := Vector2(size.x * (0.14 + 0.24 * float(i)), size.y * (0.2 + 0.1 * float(i % 2)))
		var p: Vector2 = base + Vector2(sin(t * 0.6 + float(i) * 2.0) * 6.0 * u, sin(t * 0.9 + float(i)) * 8.0 * u)
		var flick: float = 1.0 if t == 0.0 else (0.75 + 0.25 * sin(t * 3.0 + float(i) * 1.9))
		if t > 0.0 and fposmod(t * 0.4 + float(i) * 0.37, 5.0) < 0.12:
			flick = 0.35
		var r := Rect2(p - Vector2(34.0, 13.0) * u, Vector2(68.0, 26.0) * u)
		ci.draw_rect(r.grow(5.0 * u), Color(cols[i], 0.10 * flick))
		Kit.pill(ci, r, Color(INK, 0.55))
		Kit.text(ci, SIGNS[i], r, 14.0 * u, Color(cols[i].lightened(0.3), flick))
		ci.draw_line(Vector2(p.x - 18.0 * u, r.end.y), Vector2(p.x - 18.0 * u, r.end.y + 10.0 * u), Color(1, 1, 1, 0.2), 1.5 * u)
		ci.draw_line(Vector2(p.x + 18.0 * u, r.end.y), Vector2(p.x + 18.0 * u, r.end.y + 10.0 * u), Color(1, 1, 1, 0.2), 1.5 * u)


## Dark rooftop strip along the bottom with chimneys and a glowing mint edge.
static func rooftop(ci: CanvasItem, size: Vector2, t: float, u: float) -> void:
	var y: float = roof_y(size, u)
	ci.draw_rect(Rect2(0.0, y, size.x, size.y - y), Color("#0A1F2B"))
	for i in 5:
		var x: float = size.x * (0.1 + 0.2 * float(i))
		ci.draw_rect(Rect2(x, y - (14.0 + float(i % 3) * 6.0) * u, 18.0 * u, (14.0 + float(i % 3) * 6.0) * u + 2.0), Color("#0A1F2B"))
	for k in 5:
		ci.draw_rect(Rect2(0.0, y - float(k) * 4.0 * u, size.x, 4.0 * u), Color(UiTheme.TEAL, 0.07 * (1.0 - float(k) / 5.0)))
	var pulse: float = 0.7 if t == 0.0 else 0.6 + 0.3 * sin(t * 2.0)
	ci.draw_rect(Rect2(0.0, y, size.x, 3.0 * u), Color(UiTheme.TEAL, pulse))


## A floating Gloomling demon at `p` (radius `r`): bobs, blinks, flashes white when `flash` > 0.
static func demon(ci: CanvasItem, p: Vector2, r: float, col: Color, t: float, seed_v: float, flash: float = 0.0) -> void:
	var bob: float = 0.0 if t == 0.0 else sin(t * 2.4 + seed_v) * r * 0.1
	var c: Vector2 = p + Vector2(0.0, bob)
	var body: Color = col.lerp(Color("#150C2B"), 0.6).lerp(Color.WHITE, flash)
	var rim: Color = col.lerp(Color.WHITE, flash)
	ci.draw_circle(c, r * 1.35, Color(col, 0.16))
	for i in 3:
		var f: float = float(i)
		var w: float = 0.0 if t == 0.0 else sin(t * 3.0 + seed_v + f * 1.4) * r * 0.12
		ci.draw_circle(c + Vector2((f - 1.0) * r * 0.42 + w, r * 0.82 + f * 0.0), r * 0.17, body)
	for side in [-1.0, 1.0]:
		ci.draw_colored_polygon(PackedVector2Array([c + Vector2(side * r * 0.22, -r * 0.7), c + Vector2(side * r * 0.62, -r * 0.55), c + Vector2(side * r * 0.52, -r * 1.12)]), rim)
	var pts: PackedVector2Array = _ellipse(c, r, r * 0.9, 22)
	ci.draw_colored_polygon(pts, body)
	ci.draw_polyline(pts + PackedVector2Array([pts[0]]), Color(rim, 0.85), maxf(1.5, r * 0.07), true)
	var blink: bool = t > 0.0 and fposmod(t * 0.7 + seed_v, 3.0) < 0.14
	for side in [-1.0, 1.0]:
		var e: Vector2 = c + Vector2(side * r * 0.36, -r * 0.12)
		if blink:
			ci.draw_line(e + Vector2(-r * 0.2, 0.0), e + Vector2(r * 0.2, 0.0), Color("#F1EAFF"), maxf(1.5, r * 0.07), true)
		else:
			ci.draw_circle(e, r * 0.23, Color("#F1EAFF"))
			ci.draw_circle(e + Vector2(0.0, r * 0.03), r * 0.11, INK)
	ci.draw_arc(c + Vector2(0.0, r * 0.28), r * 0.22, 0.15, PI - 0.15, 8, Color("#F1EAFF"), maxf(1.5, r * 0.06), true)


## The Grumble King (Alley Brawl art) floating at `p` with radius `r`.
static func boss(ci: CanvasItem, p: Vector2, r: float, flash: bool, age: int, u: float) -> void:
	var s: float = r * 2.2
	BrawlArt.draw_boss_kind(ci, "king", p.x, p.y + s * 0.5, s, flash, age, 0.0, u)


## A jagged lightning bolt between `a` and `b`; `k` 1 -> 0 fades it, `col` is the weapon glow.
static func bolt(ci: CanvasItem, a: Vector2, b: Vector2, k: float, col: Color, width: float, seed_v: int) -> void:
	var pts := PackedVector2Array([a])
	var d: Vector2 = b - a
	var nrm: Vector2 = d.orthogonal().normalized()
	var segs := 7
	for i in range(1, segs):
		var f: float = float(i) / float(segs)
		var off: float = sin(float(seed_v * 31 + i * 17)) * d.length() * 0.05
		pts.append(a + d * f + nrm * off)
	pts.append(b)
	ci.draw_polyline(pts, Color(col, 0.28 * k), width * 3.2, true)
	ci.draw_polyline(pts, Color(col.lightened(0.3), 0.8 * k), width * 1.5, true)
	ci.draw_polyline(pts, Color(1, 1, 1, k), width * 0.6, true)


## Expanding tap ripple; `k` 0 -> 1 over its life. `hit` = bright, else a dim "miss" ring.
static func ripple(ci: CanvasItem, p: Vector2, radius: float, k: float, col: Color, hit: bool) -> void:
	var c: Color = col if hit else Color(UiTheme.TEXT_MUTED, 0.8)
	ci.draw_arc(p, radius * (0.4 + k * 0.9), 0.0, TAU, 28, Color(c, (1.0 - k) * (0.9 if hit else 0.5)), 3.5 * (1.0 - k) + 1.0, true)
	if hit:
		ci.draw_circle(p, radius * 0.35 * (1.0 - k), Color(1, 1, 1, 0.5 * (1.0 - k)))
