extends RefCounted
## Head and face of the idol hunter (Story 015, upgraded in Story 032), side view (`_side`) and
## front (`_front`). Head geometry matches the original art so HunterAccessories still
## aligns: side head radius 13 * u, front head radius 24 * k, eyes at the same centres.
## Hair lives in hunter_hair.gd and the expression system in hunter_expr.gd.

const Shade := preload("res://scripts/hunter_shade.gd")
const Expr := preload("res://scripts/hunter_expr.gd")
const Hair := preload("res://scripts/hunter_hair.gd")

const NO_RIM := Color(0.0, 0.0, 0.0, 0.0)


## Iris colour: a warm brown tinted by the hair colour.
static func iris_color(hair: Color) -> Color:
	return Expr.iris_color(hair)


## Legacy single eye (neutral expression); kept for old callers.
static func eye(ci: CanvasItem, c: Vector2, s: float, outward: float, iris: Color, alpha: float, closed: float = 0.0) -> void:
	Expr.eye(ci, c, s, outward, iris, alpha, Expr.params("neutral"), closed)


## Face-shaped polygon: a round head with a slightly narrower chin.
static func _head_pts(c: Vector2, r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n):
		var a: float = TAU * float(i) / float(n)
		var sa: float = maxf(sin(a), 0.0)
		pts.append(c + Vector2(cos(a) * r * (1.0 - 0.17 * sa * sa), sin(a) * r * (1.0 + 0.04 * sa)))
	return pts


## Skin gradient (light top, shadow bottom) with a rim light on the glow side.
static func _skin(ci: CanvasItem, pts: PackedVector2Array, c: Vector2, r: float, alpha: float, w: float, glow: Color, rim_dir: float) -> void:
	var cols := PackedColorArray()
	var lit: Color = Shade.fade(Shade.SKIN_LIGHT.lerp(Shade.SKIN, 0.55), alpha)
	var mid: Color = Shade.fade(Shade.SKIN, alpha)
	var low: Color = Shade.fade(Shade.SKIN.lerp(Shade.SKIN_SHADOW, 0.55), alpha)
	for p in pts:
		var t: float = clampf((p.y - (c.y - r)) / (2.0 * r), 0.0, 1.0)
		cols.append(lit.lerp(mid, clampf(t * 2.2, 0.0, 1.0)).lerp(low, clampf(t * 1.6 - 0.6, 0.0, 1.0)))
	ci.draw_polygon(pts, cols)
	var closed := PackedVector2Array(pts)
	closed.append(pts[0])
	ci.draw_polyline(closed, Shade.ink(Shade.fade(Shade.SKIN, alpha)), w, true)
	if glow.a > 0.0:
		var a0: float = -PI * 0.42 if rim_dir > 0.0 else PI * 1.42
		ci.draw_arc(c, r - w * 0.7, a0 - 0.1, a0 + PI * 0.55 * (1.0 if rim_dir > 0.0 else -1.0), 12, Shade.fade(Shade.lighten(glow, 0.4), 0.7 * alpha), maxf(1.0, w * 1.1), true)


# ---------------- Side view ----------------

## Hair behind the head (back layer). `twin` selects twintails; `style` (optional) overrides it
## with bob | twintails | ponytail. `sway` is the cloth/hair sway.
static func hair_back_side(ci: CanvasItem, head: Vector2, u: float, f: float, sway: float, hair: Color, twin: bool, alpha: float, style: String = "") -> void:
	Hair.back_side(ci, head, u, f, sway, hair, style if style != "" else ("twintails" if twin else "bob"), alpha)


## Side-view head: neck, skin, crown, fringe and the face. `expr` is an expression id; `wince`
## forces "hurt". `glow` (alpha > 0) adds a rim light on the cheek.
static func face_side(ci: CanvasItem, head: Vector2, u: float, f: float, hair: Color, alpha: float, blink: float = 0.0, wince: bool = false, expr: String = "neutral", glow: Color = NO_RIM) -> void:
	var skin: Color = Shade.fade(Shade.SKIN, alpha)
	var w: float = maxf(1.0, 1.0 * u)
	var shadow: Color = Shade.fade(Shade.SKIN_SHADOW, alpha)
	var neck := PackedVector2Array([head + Vector2(-3.4, 8.0) * u, head + Vector2(3.4, 8.0) * u, head + Vector2(4.2, 15.5) * u, head + Vector2(-4.2, 15.5) * u])
	Shade.fill(ci, neck, shadow, w, Shade.ink(skin))
	var pts: PackedVector2Array = _head_pts(head, 13.0, 24)
	for i in range(pts.size()):
		pts[i] = head + (pts[i] - head) * u
	_skin(ci, pts, head, 13.0 * u, alpha, w, glow, float(f))
	ci.draw_arc(head, 12.0 * u, PI * 0.2, PI * 0.8, 8, Shade.fade(Shade.SKIN_SHADOW, 0.5 * alpha), maxf(1.0, 1.6 * u))
	Hair.cap_side(ci, head, u, f, hair, alpha)
	Expr.side(ci, head, u, f, hair, alpha, "hurt" if wince else expr, blink)


# ---------------- Front view ----------------

## Hair behind the front head (bob mass or tails with scrunchies). `twin` selects twintails;
## `style` (optional) overrides it with bob | twintails | ponytail.
static func hair_back_front(ci: CanvasItem, head: Vector2, k: float, hair: Color, twin: bool, alpha: float, sway: float = 0.0, style: String = "") -> void:
	Hair.back_front(ci, head, k, hair, style if style != "" else ("twintails" if twin else "bob"), alpha, sway)


## Front head: neck, skin, hair cap with fringe, strands, eyes, brows, nose, mouth, cheeks.
## `blink` 0..1 closes the eyes, `expr` is an expression id, `gaze` nudges the irises and `glow`
## (alpha > 0) adds a rim light down the viewer's left cheek.
static func face_front(ci: CanvasItem, head: Vector2, k: float, hair: Color, alpha: float, blink: float = 0.0, expr: String = "neutral", gaze: Vector2 = Vector2.ZERO, glow: Color = NO_RIM) -> void:
	var w: float = maxf(1.0, 1.3 * k)
	var neck := PackedVector2Array([head + Vector2(-5.5, 17.0) * k, head + Vector2(5.5, 17.0) * k, head + Vector2(7.0, 28.0) * k, head + Vector2(-7.0, 28.0) * k])
	Shade.fill(ci, neck, Shade.fade(Shade.SKIN_SHADOW, alpha), maxf(1.0, w * 0.8), Shade.ink(Shade.fade(Shade.SKIN, alpha)))
	var pts: PackedVector2Array = _head_pts(head, 24.0 * k, 32)
	_skin(ci, pts, head, 24.0 * k, alpha, w, glow, -1.0)
	ci.draw_arc(head, 22.5 * k, PI * 0.22, PI * 0.78, 10, Shade.fade(Shade.SKIN_SHADOW, 0.5 * alpha), maxf(1.0, 2.2 * k))
	Hair.cap_front(ci, head, k, hair, alpha)
	Expr.front(ci, head, k, hair, alpha, expr, blink, gaze)
