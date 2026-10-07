extends RefCounted
## Lantern Says scenery (Story 026): night garden / rooftop backdrop with hanging lanterns,
## fireflies and a hedge, plus the big glowing lantern drawing. Pure drawing helpers.

const Kit := preload("res://scenes/games/game_kit.gd")


## Whole backdrop. `t` is animation seconds (0 when calm); `glow` 0..1 warms the sky when a lantern lights.
static func draw(ci: CanvasItem, size: Vector2, t: float, glow: float) -> void:
	Kit.draw_backdrop(ci, size, "lantern", t, 0.0)
	_hanging(ci, size, t)
	_hedge(ci, size)
	_fireflies(ci, size, t)
	if glow > 0.0:
		ci.draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 0.75, 0.35, 0.05 * glow))


static func _hanging(ci: CanvasItem, size: Vector2, t: float) -> void:
	var n := 6
	for i in n:
		var x: float = size.x * (0.08 + 0.84 * float(i) / float(n - 1))
		var len: float = size.y * (0.05 + 0.05 * float((i * 5) % 3))
		var sway: float = sin(t * 0.9 + float(i) * 1.3) * 5.0
		var p := Vector2(x + sway, len)
		ci.draw_line(Vector2(x, 0.0), p - Vector2(0, 8), Color(1, 1, 1, 0.18), 1.5, true)
		ci.draw_circle(p, 16.0, Color(UiTheme.GOLD, 0.10))
		var sb: StyleBoxFlat = UiTheme.box(Color(UiTheme.GOLD, 0.55), Color(1, 1, 1, 0.25), 1, 8, 0, 0, 0)
		sb.draw(ci.get_canvas_item(), Rect2(p - Vector2(8, 8), Vector2(16, 20)))


static func _hedge(ci: CanvasItem, size: Vector2) -> void:
	var base: float = size.y
	ci.draw_rect(Rect2(0.0, base - size.y * 0.06, size.x, size.y * 0.06), Color("#0B1530"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var x := 0.0
	while x < size.x + 40.0:
		var r: float = 18.0 + rng.randf() * 22.0
		ci.draw_circle(Vector2(x, base - size.y * 0.06), r, Color("#0B1530"))
		x += r * 1.3


static func _fireflies(ci: CanvasItem, size: Vector2, t: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 777
	for i in 16:
		var bx: float = rng.randf() * size.x
		var by: float = size.y * (0.3 + rng.randf() * 0.6)
		var ph: float = rng.randf() * TAU
		var p := Vector2(bx + sin(t * 0.6 + ph) * 26.0, by + cos(t * 0.8 + ph) * 18.0)
		var blink: float = 0.35 + 0.65 * (0.5 + 0.5 * sin(t * 2.2 + ph * 3.0))
		if t == 0.0:
			blink = 0.7
		ci.draw_circle(p, 7.0, Color(0.85, 1.0, 0.5, 0.10 * blink))
		ci.draw_circle(p, 2.2, Color(0.9, 1.0, 0.6, 0.85 * blink))


## One big lantern at `c` with body radius `r`. `lit` 0..1 is how brightly it glows.
static func draw_lantern(ci: CanvasItem, c: Vector2, r: float, col: Color, lit: float, hang_to_y: float) -> void:
	ci.draw_line(Vector2(c.x, hang_to_y), Vector2(c.x, c.y - r * 1.15), Color(1, 1, 1, 0.22), 2.0, true)
	if lit > 0.0:
		ci.draw_circle(c, r * 2.0, Color(col, 0.10 * lit))
		ci.draw_circle(c, r * 1.5, Color(col, 0.16 * lit))
	var body := Rect2(c.x - r * 0.85, c.y - r * 0.95, r * 1.7, r * 1.9)
	var fill: Color = Color(col, 0.28).lerp(Color(col, 0.95), lit)
	var sb: StyleBoxFlat = UiTheme.box(fill, Color(1, 1, 1, 0.4 + 0.4 * lit), 3, int(r * 0.7), 0, 0, 0)
	sb.draw(ci.get_canvas_item(), body)
	var capc := Color(UiTheme.PANEL_LIGHT).lerp(col, 0.25)
	ci.draw_rect(Rect2(c.x - r * 0.5, c.y - r * 1.12, r * 1.0, r * 0.2), capc)
	ci.draw_rect(Rect2(c.x - r * 0.5, c.y + r * 0.92, r * 1.0, r * 0.2), capc)
	for k in [-0.45, 0.0, 0.45]:
		ci.draw_line(Vector2(c.x + r * k, c.y - r * 0.8), Vector2(c.x + r * k, c.y + r * 0.8), Color(0, 0, 0, 0.18), 2.0, true)
	ci.draw_circle(c, r * (0.28 + 0.2 * lit), Color(1.0, 0.97, 0.85, 0.35 + 0.6 * lit))
	ci.draw_line(Vector2(c.x - r * 0.15, c.y + r * 1.12), Vector2(c.x - r * 0.15, c.y + r * 1.5), Color(col, 0.8), 3.0, true)
	ci.draw_line(Vector2(c.x + r * 0.15, c.y + r * 1.12), Vector2(c.x + r * 0.15, c.y + r * 1.4), Color(col, 0.8), 3.0, true)
