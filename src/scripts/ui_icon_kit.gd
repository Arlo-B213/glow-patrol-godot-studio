class_name UiIconKit
extends RefCounted
## Drawing helpers shared by the UI icon set. All icon geometry is authored in
## unit coordinates (0..1 across a square rect) so icons scale cleanly.

## Line weight as a fraction of the icon side; shared by every icon.
const STROKE := 0.085
const MIN_STROKE := 2.0


## Stroke width in pixels for a given icon rect.
static func sw(r: Rect2) -> float:
	return maxf(MIN_STROKE, r.size.x * STROKE)


## Converts unit coordinates to a point inside the rect.
static func p(r: Rect2, x: float, y: float) -> Vector2:
	return r.position + Vector2(x, y) * r.size


## Lighter companion colour derived from the tint.
static func light(tint: Color) -> Color:
	return tint.lerp(Color.WHITE, 0.5)


## Dark detail colour derived from the tint (for cut-outs on a filled shape).
static func dark(tint: Color) -> Color:
	return tint.lerp(UiTheme.BG, 0.78)


## Draws a line between unit points with round caps.
static func line(ci: CanvasItem, r: Rect2, a: Vector2, b: Vector2, col: Color, w: float) -> void:
	var pa := p(r, a.x, a.y)
	var pb := p(r, b.x, b.y)
	ci.draw_line(pa, pb, col, w, true)
	ci.draw_circle(pa, w * 0.5, col)
	ci.draw_circle(pb, w * 0.5, col)


## Draws an open polyline through unit points with round joints and caps.
static func polyline(ci: CanvasItem, r: Rect2, pts: Array, col: Color, w: float) -> void:
	var out := PackedVector2Array()
	for q in pts:
		out.append(p(r, q.x, q.y))
	ci.draw_polyline(out, col, w, true)
	for v in out:
		ci.draw_circle(v, w * 0.5, col)


## Fills a simple polygon given in unit points and softens its corners with a
## same-colour outline stroke of the given width.
static func poly(ci: CanvasItem, r: Rect2, pts: Array, col: Color, round_w: float = 0.0) -> void:
	var out := PackedVector2Array()
	for q in pts:
		out.append(p(r, q.x, q.y))
	ci.draw_colored_polygon(out, col)
	if round_w > 0.0:
		var closed := out.duplicate()
		closed.append(out[0])
		ci.draw_polyline(closed, col, round_w, true)
		for v in out:
			ci.draw_circle(v, round_w * 0.5, col)


## Filled circle at unit coordinates with a unit-size radius.
static func circ(ci: CanvasItem, r: Rect2, x: float, y: float, rad: float, col: Color) -> void:
	ci.draw_circle(p(r, x, y), rad * r.size.x, col, true)


## Arc stroke at unit coordinates (angles in radians, clockwise on screen).
static func arc(ci: CanvasItem, r: Rect2, x: float, y: float, rad: float,
		a0: float, a1: float, col: Color, w: float) -> void:
	ci.draw_arc(p(r, x, y), rad * r.size.x, a0, a1, 24, col, w, true)


## Filled heart centred at unit (cx, cy), `s` = width in unit size.
static func heart(ci: CanvasItem, r: Rect2, cx: float, cy: float, s: float, col: Color) -> void:
	circ(ci, r, cx - 0.2 * s, cy - 0.12 * s, 0.22 * s, col)
	circ(ci, r, cx + 0.2 * s, cy - 0.12 * s, 0.22 * s, col)
	# The polygon's top edge sits at the lobes' centres so the notch between them stays visible.
	var pts: Array = [
		Vector2(cx - 0.42 * s, cy - 0.12 * s), Vector2(cx + 0.42 * s, cy - 0.12 * s),
		Vector2(cx, cy + 0.46 * s),
	]
	poly(ci, r, pts, col, 0.0)
