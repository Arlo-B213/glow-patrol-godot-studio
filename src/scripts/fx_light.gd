extends RefCounted
## Shared code-drawn lighting toolkit (Story 034). Every helper draws onto any CanvasItem inside
## its _draw(). Glows use ONE cached radial-gradient mesh (a single draw_mesh call, tinted via
## modulate) so a halo costs about the same as one circle. `t` is seconds of ambient animation;
## callers pass 0.0 for a static look and FxLight.time(t) does that automatically for
## GameState.reduce_motion. Nothing here allocates per frame beyond tiny packed arrays.

const SEGS := 24
## Radial falloff of the glow mesh: [radius fraction, alpha] rings from centre to rim.
const FALLOFF := [[0.0, 1.0], [0.3, 0.62], [0.62, 0.22], [1.0, 0.0]]

static var _disc: ArrayMesh
static var _add_mat: CanvasItemMaterial


## True when decorative motion should be off (GameState.reduce_motion), null-safe.
static func calm() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	var gs: Node = tree.root.get_node_or_null("GameState") if tree else null
	return gs != null and bool(gs.get("reduce_motion"))


## `t` unchanged normally, 0.0 when reduce motion is on (use for every ambient animation).
static func time(t: float) -> float:
	return 0.0 if calm() else t


## Shared additive-blend material: assign to a node's `material` to make its whole draw glow.
static func additive_material() -> CanvasItemMaterial:
	if _add_mat == null:
		_add_mat = CanvasItemMaterial.new()
		_add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _add_mat


static func _glow_mesh() -> ArrayMesh:
	if _disc != null:
		return _disc
	var verts := PackedVector2Array()
	var cols := PackedColorArray()
	var idx := PackedInt32Array()
	var rings: int = FALLOFF.size()
	verts.append(Vector2.ZERO)
	cols.append(Color(1, 1, 1, float(FALLOFF[0][1])))
	for r in range(1, rings):
		for k in SEGS:
			var a: float = TAU * float(k) / float(SEGS)
			verts.append(Vector2(cos(a), sin(a)) * float(FALLOFF[r][0]))
			cols.append(Color(1, 1, 1, float(FALLOFF[r][1])))
	for k in SEGS:
		idx.append_array([0, 1 + k, 1 + (k + 1) % SEGS])
	for r in range(1, rings - 1):
		var a0: int = 1 + (r - 1) * SEGS
		var a1: int = 1 + r * SEGS
		for k in SEGS:
			var k2: int = (k + 1) % SEGS
			idx.append_array([a0 + k, a1 + k, a1 + k2, a0 + k, a1 + k2, a0 + k2])
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_COLOR] = cols
	arrays[Mesh.ARRAY_INDEX] = idx
	_disc = ArrayMesh.new()
	_disc.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return _disc


## Soft glow halo: bright centre fading to nothing at radius `r`. Elliptical via `ry` (0 = round).
static func halo(ci: CanvasItem, c: Vector2, r: float, col: Color, strength: float = 1.0, ry: float = 0.0) -> void:
	if r <= 0.5 or strength <= 0.01:
		return
	var xf := Transform2D(Vector2(r, 0.0), Vector2(0.0, r if ry <= 0.0 else ry), c)
	ci.draw_mesh(_glow_mesh(), null, xf, Color(col.r, col.g, col.b, col.a * clampf(strength, 0.0, 1.0)))


## Halo with a hot core: wide soft glow plus a small near-white centre (lamps, neon bulbs, stars).
static func bloom(ci: CanvasItem, c: Vector2, r: float, col: Color, strength: float = 1.0) -> void:
	halo(ci, c, r, col, strength * 0.8)
	halo(ci, c, r * 0.38, Color.WHITE.lerp(col, 0.25), strength * 0.9)


## Flat pool of light on the ground (wide ellipse), e.g. under a lamp or lantern.
static func light_pool(ci: CanvasItem, c: Vector2, rx: float, col: Color, strength: float = 1.0, squash: float = 0.22) -> void:
	halo(ci, c, rx, col, strength, rx * squash)


## Light shaft / god ray from `origin` pointing at `angle` (radians), widening to `spread` px at
## `length`. Brightest at the source, fading to zero. `sway` wobbles the angle with time.
static func shaft(ci: CanvasItem, origin: Vector2, angle: float, length: float, spread: float, col: Color, strength: float = 0.2, t: float = 0.0, seed_v: float = 0.0) -> void:
	var a: float = angle + (sin(t * 0.5 + seed_v) * 0.04 if t != 0.0 else 0.0)
	var dir := Vector2(cos(a), sin(a))
	var side := Vector2(-dir.y, dir.x)
	var narrow: float = spread * 0.08
	var far: Vector2 = origin + dir * length
	var pts := PackedVector2Array([origin + side * narrow, origin - side * narrow, far - side * spread * 0.5, far + side * spread * 0.5])
	var hot := Color(col.r, col.g, col.b, col.a * strength)
	var cold := Color(col.r, col.g, col.b, 0.0)
	ci.draw_polygon(pts, PackedColorArray([hot, hot, cold, cold]))


## Darkened screen edges. `strength` 0..1 is the alpha at the very edge; `depth` is px of falloff.
static func vignette(ci: CanvasItem, rect: Rect2, strength: float = 0.5, depth: float = 0.0, col: Color = Color(0.03, 0.0, 0.1)) -> void:
	_edges(ci, rect, Color(col.r, col.g, col.b, strength), depth if depth > 0.0 else minf(rect.size.x, rect.size.y) * 0.32)


## Neon glow hugging the screen edges, optionally pulsing with `t`.
static func edge_glow(ci: CanvasItem, rect: Rect2, col: Color, strength: float = 0.3, depth: float = 36.0, t: float = 0.0) -> void:
	var pulse: float = 1.0 if t == 0.0 else 0.75 + 0.25 * sin(t * 1.6)
	_edges(ci, rect, Color(col.r, col.g, col.b, strength * pulse), depth)


static func _edges(ci: CanvasItem, r: Rect2, edge: Color, d: float) -> void:
	var clear := Color(edge.r, edge.g, edge.b, 0.0)
	var p := r.position
	var e := r.end
	ci.draw_polygon(PackedVector2Array([p, Vector2(e.x, p.y), Vector2(e.x, p.y + d), Vector2(p.x, p.y + d)]), PackedColorArray([edge, edge, clear, clear]))
	ci.draw_polygon(PackedVector2Array([Vector2(p.x, e.y), Vector2(e.x, e.y), Vector2(e.x, e.y - d), Vector2(p.x, e.y - d)]), PackedColorArray([edge, edge, clear, clear]))
	ci.draw_polygon(PackedVector2Array([p, Vector2(p.x + d, p.y), Vector2(p.x + d, e.y), Vector2(p.x, e.y)]), PackedColorArray([edge, clear, clear, edge]))
	ci.draw_polygon(PackedVector2Array([Vector2(e.x, p.y), Vector2(e.x - d, p.y), Vector2(e.x - d, e.y), e]), PackedColorArray([edge, clear, clear, edge]))


## Vertical two-colour gradient filling `rect` (one polygon).
static func gradient_rect(ci: CanvasItem, rect: Rect2, top: Color, bottom: Color) -> void:
	var p := rect.position
	var e := rect.end
	ci.draw_polygon(PackedVector2Array([p, Vector2(e.x, p.y), e, Vector2(p.x, e.y)]), PackedColorArray([top, top, bottom, bottom]))


## Soft horizontal band (fog / haze): transparent at both edges of `h`, `col` in the middle.
static func fog_band(ci: CanvasItem, x0: float, x1: float, y: float, h: float, col: Color) -> void:
	var clear := Color(col.r, col.g, col.b, 0.0)
	var mid: float = y + h * 0.5
	ci.draw_polygon(PackedVector2Array([Vector2(x0, y), Vector2(x1, y), Vector2(x1, mid), Vector2(x0, mid)]), PackedColorArray([clear, clear, col, col]))
	ci.draw_polygon(PackedVector2Array([Vector2(x0, mid), Vector2(x1, mid), Vector2(x1, y + h), Vector2(x0, y + h)]), PackedColorArray([col, col, clear, clear]))


## Floating bokeh dust motes drifting upward inside `rect` (stateless; `count` capped at 40).
static func motes(ci: CanvasItem, rect: Rect2, t: float, count: int, col: Color, size: float = 3.0, seed_v: int = 0) -> void:
	var n: int = mini(count, 40)
	for i in n:
		var h1: float = _h(i, seed_v)
		var h2: float = _h(i, seed_v + 17)
		var h3: float = _h(i, seed_v + 41)
		var x: float = rect.position.x + fposmod(h1 * rect.size.x + sin(t * 0.4 + h2 * 9.0) * 14.0, rect.size.x)
		var y: float = rect.position.y + fposmod(h2 * rect.size.y - t * (6.0 + h3 * 10.0), rect.size.y)
		var tw: float = 0.55 if t == 0.0 else 0.5 + 0.5 * sin(t * (0.8 + h3) + float(i))
		var s: float = size * (0.6 + h3)
		halo(ci, Vector2(x, y), s * 3.2, col, 0.35 * tw)
		ci.draw_circle(Vector2(x, y), s * 0.45, Color(col.r, col.g, col.b, col.a * (0.4 + 0.5 * tw)))


## Subtle film grain: a few faint specks that reshuffle ~8 times a second (static when t = 0).
static func grain(ci: CanvasItem, rect: Rect2, t: float, count: int = 36, alpha: float = 0.06) -> void:
	var frame: int = int(t * 8.0)
	for i in mini(count, 60):
		var x: float = rect.position.x + _h(i, frame) * rect.size.x
		var y: float = rect.position.y + _h(i, frame + 977) * rect.size.y
		ci.draw_rect(Rect2(x, y, 1.5, 1.5), Color(1, 1, 1, alpha * (0.4 + _h(i, frame + 5))))


## Expanding shockwave ring; `p` is progress 0..1 (fades as it grows).
static func shock_ring(ci: CanvasItem, c: Vector2, max_r: float, col: Color, p: float, width: float = 5.0) -> void:
	if p <= 0.0 or p >= 1.0:
		return
	var e: float = 1.0 - pow(1.0 - p, 3.0)
	var a: float = (1.0 - p)
	ci.draw_arc(c, max_r * e, 0.0, TAU, 28, Color(col.r, col.g, col.b, col.a * a * 0.9), width * (1.0 - p * 0.6), true)
	ci.draw_arc(c, max_r * e * 0.82, 0.0, TAU, 24, Color(col.r, col.g, col.b, col.a * a * 0.3), width * 2.2 * (1.0 - p), true)


## Impact flash: bright burst star + halo; `p` progress 0..1.
static func impact_flash(ci: CanvasItem, c: Vector2, r: float, col: Color, p: float) -> void:
	if p <= 0.0 or p >= 1.0:
		return
	var a: float = 1.0 - p
	halo(ci, c, r * (0.6 + p), col, a)
	var pts := PackedVector2Array()
	for k in 8:
		var ang: float = TAU * float(k) / 8.0 + p * 0.6
		var rr: float = r * (0.9 if k % 2 == 0 else 0.28) * (1.0 - p * 0.5)
		pts.append(c + Vector2(cos(ang), sin(ang)) * rr)
	ci.draw_colored_polygon(pts, Color(1, 1, 1, 0.9 * a))


## Tapered glowing trail through `pts` (oldest first), fading toward the tail.
static func trail(ci: CanvasItem, pts: PackedVector2Array, col: Color, width: float = 6.0) -> void:
	var n: int = pts.size()
	for i in range(1, n):
		var f: float = float(i) / float(n - 1)
		ci.draw_line(pts[i - 1], pts[i], Color(col.r, col.g, col.b, col.a * f * 0.85), width * f, true)


## Wet-road reflection streak under a light at `x`: a vertical shimmering column from `y`.
static func reflection(ci: CanvasItem, x: float, y: float, length: float, w: float, col: Color, strength: float, t: float = 0.0) -> void:
	var steps: int = 5
	for k in steps:
		var f: float = float(k) / float(steps)
		var sh: float = sin(t * 2.0 + f * 7.0 + x * 0.05) * w * 0.25 if t != 0.0 else 0.0
		var ww: float = w * (1.0 - f * 0.45)
		ci.draw_rect(Rect2(x - ww * 0.5 + sh, y + f * length, ww, length / float(steps) * 0.7), Color(col.r, col.g, col.b, col.a * strength * (1.0 - f)))


## Soft diagonal sheen sweep across `rect` (button shine): `p` 0..1 moves left to right.
static func sheen(ci: CanvasItem, rect: Rect2, p: float, strength: float = 0.28) -> void:
	var w: float = rect.size.y * 1.1
	var x: float = rect.position.x - w + (rect.size.x + w * 2.0) * p
	var slant: float = rect.size.y * 0.45
	var lo: float = maxf(x, rect.position.x)
	var hi: float = minf(x + w, rect.end.x)
	if hi <= lo:
		return
	var c := Color(1, 1, 1, strength * sin(clampf(p, 0.0, 1.0) * PI))
	var b := Vector2(0, rect.end.y)
	var tp := Vector2(0, rect.position.y)
	var a: float = maxf(slant - (x - lo), 0.0)
	var pts := PackedVector2Array([tp + Vector2(maxf(lo, x + slant), 0), tp + Vector2(minf(hi, x + w + slant), 0), b + Vector2(minf(hi, x + w), 0), b + Vector2(maxf(lo, x), 0)])
	if a >= 0.0 and pts[0].x < pts[1].x and pts[3].x < pts[2].x:
		ci.draw_colored_polygon(pts, c)


## Deterministic 0..1 hash of (i, salt).
static func _h(i: int, salt: int) -> float:
	return fposmod(sin(float(i) * 12.9898 + float(salt) * 78.233) * 43758.5453, 1.0)


## Public alias of the hash for callers that build their own layouts.
static func hash01(i: int, salt: int = 0) -> float:
	return _h(i, salt)
