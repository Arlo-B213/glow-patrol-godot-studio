extends RefCounted
## Procedural art for Star Catch (Story 027): stars (normal / golden / magnet), falling-star
## streaks, the glowing ground, the hunter holding a lantern basket, and Gloomling hazards (the
## Alley Brawl enemy art). Every function draws onto a CanvasItem from its _draw().

const BrawlArt := preload("res://scenes/battle/brawl_art.gd")
const HunterArt := preload("res://scripts/hunter_art.gd")

## Basket centre height above the hero's feet, in hero-scale units (multiply by the hero scale).
const BASKET_UP := 128.0
const GOLD := Color("#FFD36E")
const STAR_COL := Color("#FFC15E")


## A five-point star (simple 10-vertex polygon) with a soft glow; `golden` adds a bright halo.
static func star(ci: CanvasItem, c: Vector2, r: float, col: Color, rot: float, golden: bool = false) -> void:
	ci.draw_circle(c, r * (2.3 if golden else 1.8), Color(col, 0.22 if golden else 0.14))
	var pts := PackedVector2Array()
	for i in 10:
		var rad: float = r if i % 2 == 0 else r * 0.45
		var a: float = PI / 5.0 * float(i) - PI * 0.5 + rot
		pts.append(c + Vector2(cos(a), sin(a)) * rad)
	ci.draw_colored_polygon(pts, col)
	ci.draw_circle(c, r * 0.32, Color(1, 1, 1, 0.75))


## A magnet bonus: a teal disc with a white horseshoe and red/blue poles.
static func magnet(ci: CanvasItem, c: Vector2, r: float, t: float) -> void:
	ci.draw_circle(c, r * (1.8 + 0.12 * sin(t * 6.0)), Color(UiTheme.TEAL, 0.18))
	ci.draw_circle(c, r, UiTheme.TEAL)
	ci.draw_arc(c + Vector2(0.0, -r * 0.05), r * 0.5, 0.0, PI, 14, Color.WHITE, r * 0.3, true)
	ci.draw_rect(Rect2(c.x - r * 0.65, c.y - r * 0.55, r * 0.3, r * 0.5), UiTheme.ACCENT)
	ci.draw_rect(Rect2(c.x + r * 0.35, c.y - r * 0.55, r * 0.3, r * 0.5), UiTheme.VIOLET)


## Fading streak above a falling item at `p` (speed in px/s gives the length).
static func trail(ci: CanvasItem, p: Vector2, r: float, col: Color, speed: float) -> void:
	var len: float = clampf(speed * 0.22, 14.0, 60.0)
	for i in 4:
		var f: float = float(i) / 4.0
		var a := p + Vector2(-f * len * 0.22, -f * len)
		var b := p + Vector2(-(f + 0.25) * len * 0.22, -(f + 0.25) * len)
		ci.draw_line(a, b, Color(col, 0.5 * (1.0 - f)), maxf(1.5, r * 0.9 * (1.0 - f)), true)


## Ambient falling-star streaks in the sky (static when t == 0).
static func ambient(ci: CanvasItem, size: Vector2, t: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 909
	for i in 9:
		var x0: float = rng.randf() * size.x
		var y0: float = rng.randf() * size.y * 0.7
		var sp: float = 70.0 + rng.randf() * 90.0
		var p := Vector2(fposmod(x0 - t * sp * 0.25, size.x + 60.0) - 30.0, fposmod(y0 + t * sp, size.y * 0.8 + 80.0) - 40.0)
		for k in 5:
			var f: float = float(k) / 5.0
			ci.draw_circle(p + Vector2(f * 10.0, -f * 36.0), 2.4 * (1.0 - f) + 0.6, Color(1.0, 0.94, 0.8, 0.5 * (1.0 - f)))


## Glowing ground strip from `ground_y` down, with pulsing glow dots along the edge.
static func ground(ci: CanvasItem, size: Vector2, ground_y: float, t: float, u: float) -> void:
	for i in 7:
		var f: float = float(i) / 7.0
		ci.draw_rect(Rect2(0.0, ground_y - float(i) * 5.0 * u, size.x, 5.0 * u), Color(GOLD, 0.16 * (1.0 - f)))
	ci.draw_rect(Rect2(0.0, ground_y, size.x, size.y - ground_y), Color(0.12, 0.05, 0.25, 0.92))
	ci.draw_rect(Rect2(0.0, ground_y, size.x, 3.0 * u), Color(GOLD, 0.75))
	var n: int = int(size.x / (46.0 * u)) + 1
	for i in n:
		var pulse: float = 0.5 + 0.5 * sin(t * 2.2 + float(i) * 1.3)
		var c := Vector2(float(i) * 46.0 * u + 12.0 * u, ground_y + 14.0 * u)
		ci.draw_circle(c, 6.0 * u, Color(GOLD, 0.10 + 0.12 * pulse))
		ci.draw_circle(c, 2.2 * u, Color(GOLD, 0.45 + 0.4 * pulse))


## Hunter with a lantern basket held overhead. `glow` 0..1 flashes the basket after a catch;
## `hurt_t` is frames since a Gloomling bump (-1 = none). `hs` is the hero scale.
static func hero(ci: CanvasItem, x: float, ground_y: float, hs: float, look: Dictionary, facing: int, anim_t: int, moving: bool, hurt_t: int, glow: float, still: bool) -> void:
	HunterArt.draw_hunter(ci, x, ground_y, hs, facing, anim_t, moving, 1.0, 0, look, hurt_t, not still)
	var c := Vector2(x, ground_y - BASKET_UP * hs)
	var w: float = 34.0 * hs
	var gl: Color = look.get("glow", UiTheme.TEAL)
	ci.draw_circle(c + Vector2(0.0, -4.0 * hs), w * (1.5 + glow * 0.6), Color(gl, 0.14 + 0.2 * glow))
	var pts := PackedVector2Array()
	for i in 13:
		var a: float = PI * float(i) / 12.0
		pts.append(c + Vector2(cos(a) * w, sin(a) * w * 0.62 - 6.0 * hs))
	ci.draw_colored_polygon(pts, Color("#6C5CE7").lerp(Color.WHITE, glow * 0.5))
	ci.draw_arc(c + Vector2(0.0, -6.0 * hs), w, 0.0, PI, 14, Color(1, 1, 1, 0.7), 2.5 * hs, true)
	ci.draw_rect(Rect2(c.x - w, c.y - 9.0 * hs, w * 2.0, 5.0 * hs), Color(gl, 0.95))


## A Gloomling hazard centred at `p` with radius `r` (uses the Alley Brawl art).
static func gloomling(ci: CanvasItem, p: Vector2, r: float, col: Color, age: int, u: float) -> void:
	BrawlArt.draw_gloomling(ci, p.x, p.y + r, r * 2.0, col, age, 0.0, u, {})
