extends RefCounted
## Cheap replacements for CanvasItem draw calls (Story 035). Measured on the dev machine:
## draw_circle / draw_arc / draw_polyline / draw_colored_polygon / draw_polygon each cost ~30 us
## (the renderer builds a buffer per call), while draw_mesh / draw_primitive / draw_line /
## draw_multiline / draw_rect cost 3-7 us. These helpers have the same argument order as the
## CanvasItem methods (plus the target `ci` first) and look the same, but use the cheap calls.

const THICK := 4.0
static var stat := {}
static func _s(k: String) -> void:
	stat[k] = int(stat.get(k, 0)) + 1


static var _discs: Array = []
static var _uv0 := PackedVector2Array()


static func _disc_mesh(r: float) -> ArrayMesh:
	var i: int = 0 if r < 6.0 else (1 if r < 26.0 else 2)
	if _discs.is_empty():
		_discs.resize(3)
	if _discs[i] != null:
		return _discs[i]
	var segs: int = [10, 18, 32][i]
	var v := PackedVector2Array([Vector2.ZERO])
	var idx := PackedInt32Array()
	for k in segs:
		var a: float = TAU * float(k) / float(segs)
		v.append(Vector2(cos(a), sin(a)))
		idx.append_array([0, 1 + k, 1 + (k + 1) % segs])
	var arr: Array = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = v
	arr[Mesh.ARRAY_INDEX] = idx
	var m := ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	_discs[i] = m
	return m


## Filled ellipse (rx, ry) at `c`.
static func ellipse(ci: CanvasItem, c: Vector2, rx: float, ry: float, col: Color) -> void:
	if rx <= 0.05 or ry <= 0.05:
		return
	ci.draw_mesh(_disc_mesh(maxf(rx, ry)), null, Transform2D(Vector2(rx, 0.0), Vector2(0.0, ry), c), col)


## Same as CanvasItem.draw_circle.
static func circle(ci: CanvasItem, c: Vector2, r: float, col: Color, filled: bool = true, width: float = -1.0, aa: bool = false) -> void:
	if not filled:
		arc(ci, c, r, 0.0, TAU, 24, col, width, aa)
		return
	if r <= 0.05:
		return
	ci.draw_mesh(_disc_mesh(r), null, Transform2D(Vector2(r, 0.0), Vector2(0.0, r), c), col)


## Same as CanvasItem.draw_arc; thin arcs become multiline segments.
static func arc(ci: CanvasItem, c: Vector2, r: float, a0: float, a1: float, n: int, col: Color, width: float = -1.0, aa: bool = false) -> void:
	if width > 16.0:
		_s('arc_thick')
		ci.draw_arc(c, r, a0, a1, n, col, width, aa)
		return
	var segs: int = clampi(mini(n, 4 + int(r * 0.35)), 6, 40)
	if width > THICK:
		segs = clampi(int(ceil(absf(a1 - a0) / 0.2)), segs, 40)
	var pts := PackedVector2Array()
	pts.resize(segs * 2)
	var prev := c + Vector2(cos(a0), sin(a0)) * r
	for k in range(1, segs + 1):
		var a: float = a0 + (a1 - a0) * float(k) / float(segs)
		var p := c + Vector2(cos(a), sin(a)) * r
		pts[(k - 1) * 2] = prev
		pts[(k - 1) * 2 + 1] = p
		prev = p
	ci.draw_multiline(pts, col, maxf(width, 1.0), aa)


## Same as CanvasItem.draw_polyline; thin lines become multiline segments.
static func polyline(ci: CanvasItem, pts: PackedVector2Array, col: Color, width: float = -1.0, aa: bool = false) -> void:
	var n: int = pts.size()
	if n < 2:
		return
	if width > 10.0:
		_s('pl_thick')
		ci.draw_polyline(pts, col, width, aa)
		return
	var seg := PackedVector2Array()
	seg.resize((n - 1) * 2)
	for k in n - 1:
		var a := pts[k]
		var b := pts[k + 1]
		if n <= 9 and width > 1.2:
			# Angular shapes: lengthen each segment a little so corners have no notch.
			var d: Vector2 = (b - a).normalized() * width * 0.4
			a -= d
			b += d
		seg[k * 2] = a
		seg[k * 2 + 1] = b
	ci.draw_multiline(seg, col, maxf(width, 1.0), aa)


static func _convex(p: PackedVector2Array) -> bool:
	var n: int = p.size()
	var sign_v: float = 0.0
	for i in n:
		var cr: float = (p[(i + 1) % n] - p[i]).cross(p[(i + 2) % n] - p[(i + 1) % n])
		if absf(cr) < 0.0001:
			continue
		if sign_v == 0.0:
			sign_v = cr
		elif sign_v * cr < 0.0:
			return false
	return true


## Same as CanvasItem.draw_colored_polygon; convex polygons are drawn as quads (no triangulation).
static func poly(ci: CanvasItem, pts: PackedVector2Array, col: Color, uvs: PackedVector2Array = PackedVector2Array(), tex: Texture2D = null) -> void:
	var n: int = pts.size()
	if n < 3:
		return
	if tex != null or uvs.size() > 0 or n > 40 or (n > 4 and not _convex(pts)):
		_s('poly_fb')
		ci.draw_colored_polygon(pts, col, uvs, tex)
		return
	if n == 3:
		ci.draw_primitive(pts, PackedColorArray([col, col, col]), _uv0)
		return
	if n == 4:
		ci.draw_primitive(pts, PackedColorArray([col, col, col, col]), _uv0)
		return
	var cols := PackedColorArray([col, col, col, col])
	var i: int = 1
	while i < n - 1:
		var q := PackedVector2Array([pts[0], pts[i], pts[i + 1], pts[mini(i + 2, n - 1)]])
		if i + 2 > n - 1:
			ci.draw_primitive(PackedVector2Array([pts[0], pts[i], pts[i + 1]]), cols, _uv0)
		else:
			ci.draw_primitive(q, cols, _uv0)
		i += 2


## Same as CanvasItem.draw_polygon (per-vertex colours); quads and triangles use draw_primitive.
static func gpoly(ci: CanvasItem, pts: PackedVector2Array, cols: PackedColorArray) -> void:
	var n: int = pts.size()
	if (n == 3 or n == 4) and cols.size() == n:
		ci.draw_primitive(pts, cols, _uv0)
	else:
		_s('gpoly_fb')
		ci.draw_polygon(pts, cols)
