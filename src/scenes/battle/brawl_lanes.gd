extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Alley Brawl depth lanes (Story 036). The street is a "play band" below the horizon: every actor
## has a world x AND a depth `d` (0 = far edge, 1 = near edge). Depth maps to screen y and to a
## draw scale (further = smaller and higher); the camera still scrolls sideways only. `v` is the
## AlleyBrawlView, which caches `lane_top` / `lane_h` (px) every frame from `top_y` / `height`.

## Band start below the horizon and band height, as fractions of the view height (~27%).
const BAND_OFFSET := 0.05
const BAND_HEIGHT := 0.27
## Draw scale at the far edge (the near edge is 1.0).
const SCALE_FAR := 0.86
const START_D := 0.55


## Screen y of the band's far edge for a view `h` tall whose horizon is at `ground_y`.
static func top_y(ground_y: float, h: float) -> float:
	return ground_y + h * BAND_OFFSET


## Band height in pixels for a view `h` tall.
static func height(h: float) -> float:
	return h * BAND_HEIGHT


## Screen y of the feet at depth `d`.
static func feet_y(v: Variant, d: float) -> float:
	return v.lane_top + clampf(d, 0.0, 1.0) * v.lane_h


## Draw scale at depth `d` (0.86 far .. 1.0 near).
static func scale_at(d: float) -> float:
	return lerpf(SCALE_FAR, 1.0, clampf(d, 0.0, 1.0))


## Depth distance between two depths in pixels.
static func dy_px(v: Variant, d1: float, d2: float) -> float:
	return absf(d1 - d2) * v.lane_h


## Soft drop shadow under an actor: `w` is the shadow width in px; far shadows are darker.
static func shadow(ci: CanvasItem, x: float, fy: float, w: float, d: float, strength: float = 1.0) -> void:
	var a: float = lerpf(0.5, 0.34, clampf(d, 0.0, 1.0)) * strength
	FD.ellipse(ci, Vector2(x, fy + 1.0), w * 0.62, w * 0.2, Color(0, 0, 0, a * 0.45))
	FD.ellipse(ci, Vector2(x, fy + 1.0), w * 0.46, w * 0.14, Color(0, 0, 0, a))


## Elliptical outline (telegraph rings).
static func ring(ci: CanvasItem, c: Vector2, rx: float, ry: float, col: Color, width: float) -> void:
	var pts := PackedVector2Array()
	for k in 25:
		var a: float = TAU * float(k) / 24.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	FD.polyline(ci, pts, col, width)
