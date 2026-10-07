extends RefCounted
## Glow effects for the idol hunter (Story 032): soft aura, rim-light strokes, four-point
## sparkles, the fever ring and weapon light trails. Pure drawing helpers; every polygon is
## simple. Call from a CanvasItem's _draw().

const Shade := preload("res://scripts/hunter_shade.gd")


## Soft elliptical aura of `col` centred at `c`, 4 stacked layers; `pulse` ~1.0 breathes it.
static func aura(ci: CanvasItem, c: Vector2, rx: float, ry: float, col: Color, alpha: float, pulse: float = 1.0, strength: float = 1.0) -> void:
	for i in range(4):
		var f: float = float(i) / 3.0
		var a: float = (0.05 + 0.035 * f) * strength * alpha
		ci.draw_colored_polygon(Shade.ellipse(c, rx * pulse * (1.0 - 0.22 * f), ry * pulse * (1.0 - 0.22 * f), 20), Color(col.r, col.g, col.b, a))


## Four-point sparkle star (simple polygon) of radius `r` at `p`.
static func sparkle(ci: CanvasItem, p: Vector2, r: float, col: Color) -> void:
	var q: float = r * 0.24
	ci.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -r), p + Vector2(q, -q), p + Vector2(r, 0), p + Vector2(q, q),
		p + Vector2(0, r), p + Vector2(-q, q), p + Vector2(-r, 0), p + Vector2(-q, -q)]), col)


## Fever sparkle ring: `n` sparkles orbiting `c` plus rising specks. `t` is seconds (0 = still).
static func fever(ci: CanvasItem, c: Vector2, rx: float, ry: float, glow: Color, t: float, unit: float, alpha: float) -> void:
	var n: int = 7
	for i in range(n):
		var a: float = t * 1.4 + TAU * float(i) / float(n)
		var p: Vector2 = c + Vector2(cos(a) * rx, sin(a) * ry * 0.8 - 6.0 * unit)
		var tw: float = 0.55 + 0.45 * sin(t * 5.0 + float(i) * 1.7)
		var col: Color = Shade.lighten(glow, 0.5 + 0.3 * float(i % 2))
		sparkle(ci, p, 4.2 * unit * (0.6 + tw), Shade.fade(col, 0.85 * alpha))
	for j in range(5):
		var ph: float = fposmod(t * 0.55 + float(j) * 0.2, 1.0)
		var sx: float = c.x + (float(j) - 2.0) * rx * 0.34 + sin(t * 2.0 + float(j)) * 3.0 * unit
		ci.draw_circle(Vector2(sx, c.y + ry * 0.9 - ph * ry * 1.8), (1.0 + float(j % 2)) * unit, Shade.fade(Shade.lighten(glow, 0.7), (1.0 - ph) * 0.8 * alpha))


## Light trail along `pts` (oldest first): tapering, fading strokes in `col`.
static func trail(ci: CanvasItem, pts: Array, col: Color, w: float, alpha: float) -> void:
	var n: int = pts.size()
	for i in range(n - 1):
		var f: float = float(i + 1) / float(n)
		ci.draw_line(pts[i], pts[i + 1], Shade.fade(col, 0.5 * f * alpha), maxf(1.0, w * f), true)
		ci.draw_line(pts[i], pts[i + 1], Shade.fade(Shade.lighten(col, 0.7), 0.5 * f * alpha), maxf(1.0, w * f * 0.35), true)


## Gentle idle trail for a held glowstick: a short curve drifting behind `tip` (opposite `drift`).
static func idle_trail(ci: CanvasItem, tip: Vector2, drift: Vector2, col: Color, w: float, t: float, alpha: float) -> void:
	var pts: Array = []
	for i in range(6):
		var f: float = float(5 - i) / 5.0
		pts.append(tip - drift * f * 1.0 + Vector2(sin(t * 3.0 + f * 3.0), cos(t * 2.4 + f * 2.0)) * f * w * 0.6)
	trail(ci, pts, col, w, alpha)


## A rim-light stroke from `a` to `b` in the glow colour.
static func rim(ci: CanvasItem, a: Vector2, b: Vector2, glow: Color, w: float, alpha: float) -> void:
	ci.draw_line(a, b, Shade.fade(Shade.lighten(glow, 0.45), 0.6 * alpha), maxf(1.0, w), true)
