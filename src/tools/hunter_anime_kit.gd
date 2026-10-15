extends Control
## Drawing kit for the hunter concept sheet: cel-shaded primitives, anime eyes and strand hair.
## Coordinates are figure units (feet at 0, up is negative), mapped to the panel by p().

const INK := Color("#1A0B33")
const LASH := Color("#2A1238")
const SKIN := Color("#FFE1CF")
const SKIN_SH := Color("#F3AE9C")
const PINK := Color("#FF5FA2")
const VIOLET := Color("#6C5CE7")
const GOLD := Color("#FFD36E")
const NAVY := Color("#2A1B4D")
const WHITE := Color("#F5EFFF")
const SHADE_TINT := Color("#5B3A9E")
const HIP_Y := -110.0
const LEG_STRETCH := 1.3
const BODY_SLIM := 0.9
## [root_x, root_y, ctrl_x, ctrl_y, tip_x, tip_y, width] relative to head centre; drawn in this order.
const BANG_LOCKS := [
	[-4, -46, -44, -30, -44, 14, 30],
	[14, -46, 46, -28, 44, 12, 28],
	[0, -48, -34, -26, -30, 6, 30],
	[12, -48, 36, -24, 31, 8, 28],
	[4, -48, -20, -22, -16, 12, 28],
	[10, -48, 22, -22, 17, 4, 28],
	[7, -48, -4, -20, 0, 9, 26],
]

var o := Vector2.ZERO
var s := 1.6
var ow := 2.4


## Legs are stretched below the hip and the body slimmed below the neck for anime proportions.
func p(x: float, y: float) -> Vector2:
	var yy: float = y * LEG_STRETCH if y > HIP_Y else y + HIP_Y * (LEG_STRETCH - 1.0)
	var xx: float = x * lerpf(1.0, BODY_SLIM, smoothstep(-192.0, -176.0, y))
	return o + Vector2(xx, yy) * s


func pts(arr: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(0, arr.size(), 2):
		out.append(p(arr[i], arr[i + 1]))
	return out


func line_col(fill: Color) -> Color:
	return fill.darkened(0.62).lerp(INK, 0.35)


func shade_col(fill: Color) -> Color:
	return fill.lerp(SHADE_TINT, 0.3).darkened(0.12)


func _fill(q: PackedVector2Array, col: Color) -> void:
	if q.size() < 3:
		return
	var area := 0.0
	for i in q.size():
		area += q[i].cross(q[(i + 1) % q.size()])
	if absf(area) > 2.0:
		draw_colored_polygon(q, col)


func _fill_in(q: PackedVector2Array, col: Color, clip: PackedVector2Array) -> void:
	if clip.is_empty():
		_fill(q, col)
		return
	for part in Geometry2D.intersect_polygons(q, clip):
		_fill(part, col)


## Filled shape with two-tone cel shading (light from top-left) and a coloured outline.
func shape(q: PackedVector2Array, fill: Color, line: bool = true, lit: bool = true) -> void:
	_fill(q, fill)
	if not line:
		return
	var bb := Rect2(q[0], Vector2.ZERO)
	for v in q:
		bb = bb.expand(v)
	var d: float = minf(6.0 * s, minf(bb.size.x, bb.size.y) * 0.22)
	for part in Geometry2D.clip_polygons(q, Transform2D(0.0, Vector2(-d * 0.7, -d)) * q):
		_fill(part, shade_col(fill))
	if lit:
		for part in Geometry2D.clip_polygons(q, Transform2D(0.0, Vector2(d * 0.3, d * 0.4)) * q):
			_fill(part, Color(fill.lightened(0.5), 0.35))
	var c := q.duplicate()
	c.append(q[0])
	draw_polyline(c, line_col(fill), ow, true)


func poly(arr: Array, fill: Color, line: bool = true) -> void:
	shape(pts(arr), fill, line)


func ell(cx: float, cy: float, rx: float, ry: float, n: int = 32) -> PackedVector2Array:
	var out := PackedVector2Array()
	for k in n:
		var a: float = TAU * float(k) / float(n)
		out.append(p(cx + cos(a) * rx, cy + sin(a) * ry))
	return out


func blob(cx: float, cy: float, rx: float, ry: float, fill: Color, line: bool = true) -> void:
	shape(ell(cx, cy, rx, ry), fill, line)


func mirror(arr: Array) -> Array:
	var out: Array = arr.duplicate()
	for i in range(0, out.size(), 2):
		out[i] = -float(out[i])
	return out


func line(arr: Array, col: Color, w: float) -> void:
	draw_polyline(pts(arr), col, w * s, true)


## A tube through the points (sleeves, legs) with an outline and a cel shadow down one side.
func limb(arr: Array, w: float, fill: Color) -> void:
	var q := pts(arr)
	var ww: float = w * s
	for pass_i in 2:
		var col: Color = line_col(fill) if pass_i == 0 else fill
		var width: float = ww + 2.0 * ow if pass_i == 0 else ww
		for i in q.size():
			draw_circle(q[i], width * 0.5, col, true, -1.0, true)
			if i > 0:
				draw_line(q[i - 1], q[i], col, width, true)
	for i in range(1, q.size()):
		var n := (q[i] - q[i - 1]).orthogonal().normalized()
		if n.x + n.y < 0.0:
			n = -n
		var a := q[i - 1] + n * ww * 0.3
		var b := q[i] + n * ww * 0.3
		draw_line(a, b, shade_col(fill), ww * 0.38, true)
		draw_circle(b, ww * 0.19, shade_col(fill), true, -1.0, true)


func glow(cx: float, cy: float, r: float, col: Color) -> void:
	for k in 7:
		draw_circle(p(cx, cy), r * s * (1.0 - float(k) * 0.13), Color(col, 0.07), true, -1.0, true)


func stick(ax: float, ay: float, bx: float, by: float, w: float, col: Color) -> void:
	var a := p(ax, ay)
	var b := p(bx, by)
	for k in 5:
		draw_line(a, b, Color(col, 0.08), (w + 30.0 - float(k) * 6.0) * s, true)
	draw_line(a, b, line_col(col), w * s + 2.0 * ow, true)
	draw_line(a, b, col, w * s, true)
	draw_line(a.lerp(b, 0.25), b.lerp(a, 0.04), Color(1, 1, 1, 0.9), w * 0.35 * s, true)
	var grip := a.lerp(b, 0.22)
	draw_line(a, grip, INK, (w + 3.0) * s + 2.0 * ow, true)
	draw_line(a, grip, NAVY.lightened(0.15), (w + 3.0) * s, true)
	glow(bx, by, 26.0, col)


## Tapered glowing bat: thin grip at (ax, ay), fat rounded barrel at (bx, by).
func bat(ax: float, ay: float, bx: float, by: float, col: Color) -> void:
	var a := Vector2(ax, ay)
	var b := Vector2(bx, by)
	var n := (b - a).orthogonal().normalized()
	for k in 5:
		draw_line(p(ax, ay).lerp(p(bx, by), 0.3), p(bx, by), Color(col, 0.08), (40.0 - float(k) * 6.0) * s, true)
	var arr: Array = []
	for v in [a + n * 3.5, a.lerp(b, 0.35) + n * 4.5, b + n * 9.5, b - n * 9.5, a.lerp(b, 0.35) - n * 4.5, a - n * 3.5]:
		arr.append_array([v.x, v.y])
	poly(arr, col)
	blob(bx, by, 9.5, 9.5, col)
	var m := a.lerp(b, 0.4)
	line([m.x + n.x * 1.5, m.y + n.y * 1.5, bx + n.x * 4.0, by + n.y * 4.0], Color(1, 1, 1, 0.85), 3.0)
	var g := a.lerp(b, 0.2)
	limb([ax, ay, g.x, g.y], 8, NAVY)
	glow(bx, by, 30.0, col)


func star(cx: float, cy: float, ro: float, ri: float, col: Color) -> void:
	var arr: Array = []
	for k in 10:
		var a: float = -PI * 0.5 + PI * float(k) / 5.0
		var r: float = ro if k % 2 == 0 else ri
		arr.append_array([cx + cos(a) * r, cy + sin(a) * r])
	poly(arr, col)


# ---------- anime head ----------

func face_shape(cx: float, cy: float) -> PackedVector2Array:
	var arr: Array = []
	for k in 48:
		var a: float = PI + TAU * float(k) / 48.0
		var sy: float = sin(a)
		if sy < 0.0:
			arr.append_array([cx + cos(a) * 40.0, cy - 2.0 + sy * 42.0])
		else:
			var taper: float = 1.0 - 0.32 * pow(sy, 3.0)
			arr.append_array([cx + cos(a) * 40.0 * taper, cy - 2.0 + sy * 49.0])
	return pts(arr)


func head(cx: float, cy: float) -> void:
	shape(face_shape(cx, cy), SKIN)


## Hair mass behind the face, hanging to bottom (relative to head centre).
func back_hair(cx: float, cy: float, col: Color, bottom: float, r: float = 47.0) -> void:
	var arr: Array = []
	for k in 17:
		var a: float = PI + PI * float(k) / 16.0
		arr.append_array([cx + cos(a) * r, cy - 4.0 + sin(a) * r])
	arr.append_array([cx + r + 1.0, cy + bottom * 0.5, cx + r - 6.0, cy + bottom, cx + 24, cy + bottom - 8.0,
		cx - 24, cy + bottom - 8.0, cx - r + 6.0, cy + bottom, cx - r - 1.0, cy + bottom * 0.5])
	poly(arr, col)


## A tapered, curved lock of hair along a quadratic curve, in figure units.
func lock_arr(root: Vector2, ctrl: Vector2, tip: Vector2, w: float) -> Array:
	var left: Array = []
	var right: Array = []
	for k in 9:
		var t: float = float(k) / 8.0
		var b: Vector2 = root * (1.0 - t) * (1.0 - t) + ctrl * 2.0 * t * (1.0 - t) + tip * t * t
		var tan_v: Vector2 = ((ctrl - root) * (1.0 - t) + (tip - ctrl) * t).normalized()
		var n := tan_v.orthogonal()
		var half: float = w * 0.5 * pow(1.0 - t, 0.9)
		left.append_array([b.x + n.x * half, b.y + n.y * half])
		if k < 8:
			right.push_front(b.y - n.y * half)
			right.push_front(b.x - n.x * half)
	return left + right


func hair_lock(root: Vector2, ctrl: Vector2, tip: Vector2, w: float, col: Color) -> void:
	shape(pts(lock_arr(root, ctrl, tip, w)), col, true, false)
	var a := root.lerp(ctrl, 0.5)
	var b := ctrl.lerp(tip, 0.45)
	line([a.x - 3.0, a.y, b.x - 3.0, b.y], Color(col.darkened(0.3), 0.6), 1.3)


func side_lock(cx: float, cy: float, col: Color, length: float) -> void:
	hair_lock(Vector2(cx - 36, cy - 16), Vector2(cx - 47, cy + 12), Vector2(cx - 40, cy + length), 15, col)
	hair_lock(Vector2(cx + 36, cy - 16), Vector2(cx + 47, cy + 12), Vector2(cx + 40, cy + length), 15, col)


## Crown cap, strand bangs (with their shadow on the forehead), angel-ring shine and optional ahoge.
func hair_front(cx: float, cy: float, col: Color, sweep: float = 0.0, ahoge: bool = true) -> void:
	var face_poly := face_shape(cx, cy)
	var locks: Array = []
	for L in BANG_LOCKS:
		locks.append([Vector2(cx + L[0], cy + L[1]), Vector2(cx + L[2] + sweep * 0.5, cy + L[3]),
			Vector2(cx + L[4] + sweep, cy + L[5]), float(L[6])])
	for L in locks:
		var shadow := lock_arr(L[0] + Vector2(2, 7), L[1] + Vector2(2, 7), L[2] + Vector2(2, 7), L[3])
		for part in Geometry2D.intersect_polygons(face_poly, pts(shadow)):
			_fill(part, SKIN_SH)
	var cap: Array = []
	for k in 17:
		var a: float = PI + PI * float(k) / 16.0
		cap.append_array([cx + cos(a) * 46.0, cy - 6.0 + sin(a) * 47.0])
	shape(pts(cap), col, true, false)
	for L in locks:
		hair_lock(L[0], L[1], L[2], L[3], col)
	var top: Array = []
	var bottom: Array = []
	for k in 13:
		var a: float = deg_to_rad(210.0 + 120.0 * float(k) / 12.0)
		top.append_array([cx + cos(a) * 37.0, cy - 6.0 + sin(a) * 37.0])
		var rb: float = 32.0 if k % 2 == 0 else 29.5
		bottom.push_front(cy - 6.0 + sin(a) * rb)
		bottom.push_front(cx + cos(a) * rb)
	var shine := Color.from_hsv(col.h, col.s * 0.75, minf(1.0, col.v + 0.4))
	_fill(pts(top + bottom), Color(shine, 0.9))
	if ahoge:
		hair_lock(Vector2(cx + 2, cy - 48), Vector2(cx + 20, cy - 82), Vector2(cx - 8, cy - 74), 9, col)


func eye(ex: float, ey: float, side: float, iris: Color, mode: String) -> void:
	if mode == "wink":
		line([ex - side * 11, ey + 1, ex, ey - 6, ex + side * 11, ey + 1], LASH, 3.2)
		line([ex + side * 10, ey, ex + side * 15, ey - 3], LASH, 1.8)
		return
	var clip := PackedVector2Array()
	if mode == "fierce":
		clip = pts([ex - side * 16, ey - 4, ex + side * 16, ey - 11, ex + side * 16, ey + 20, ex - side * 16, ey + 20])
	_fill_in(ell(ex, ey, 11, 13.5), Color.WHITE, clip)
	var ip := ell(ex, ey + 1.5, 8.5, 12.0)
	var parts: Array = [ip] if clip.is_empty() else Geometry2D.intersect_polygons(ip, clip)
	for part in parts:
		var cols := PackedColorArray()
		for v in part:
			var t: float = clampf((v.y - p(ex, ey - 10.5).y) / (24.0 * s), 0.0, 1.0)
			cols.append(iris.darkened(0.55).lerp(iris.lightened(0.3), t))
		draw_polygon(part, cols)
	if clip.is_empty():
		var ring := ip.duplicate()
		ring.append(ip[0])
		draw_polyline(ring, iris.darkened(0.6), 1.2 * s, true)
	_fill_in(ell(ex, ey + 0.5, 4.0, 6.0), iris.darkened(0.75), clip)
	_fill_in(ell(ex, ey + 8.0, 5.5, 3.0), Color(iris.lightened(0.6), 0.7), clip)
	_fill_in(ell(ex, ey - 9.0, 10.0, 3.0), Color(SHADE_TINT, 0.25), clip)
	_fill_in(ell(ex - 3.5, ey - 3.0 if mode == "fierce" else ey - 5.0, 3.6, 4.6), Color.WHITE, clip)
	_fill_in(ell(ex + 3.8, ey + 6.0, 1.7, 1.7), Color.WHITE, clip)
	if mode == "fierce":
		line([ex - side * 12, ey - 4, ex + side * 12, ey - 10, ex + side * 16, ey - 14], LASH, 3.4)
	else:
		line([ex - side * 12, ey - 3, ex - side * 6, ey - 11, ex + side * 3, ey - 13.5, ex + side * 11, ey - 9, ex + side * 16, ey - 13], LASH, 3.4)
		line([ex + side * 4, ey - 13, ex + side * 11, ey - 9.5], LASH, 4.6)
		line([ex + side * 12, ey - 8, ex + side * 17, ey - 7], LASH, 1.8)
		line([ex - side * 8, ey - 17, ex + side * 8, ey - 17.5], SKIN_SH.darkened(0.1), 1.2)
	line([ex + side * 3, ey + 13.5, ex + side * 10, ey + 10], LASH, 1.3)


func face(cx: float, cy: float, expr: String, iris: Color, brow: Color) -> void:
	for side in [-1.0, 1.0]:
		_fill(ell(cx + side * 25, cy + 24, 10, 5), Color(PINK, 0.28))
		for k in 3:
			var bx: float = cx + side * 25 + float(k - 1) * 4.5
			line([bx - 1.5, cy + 26, bx + 1.5, cy + 21], Color(PINK.darkened(0.1), 0.7), 1.1)
	for side in [-1.0, 1.0]:
		var ex: float = cx + side * 17.0
		var ey: float = cy + 11.0
		eye(ex, ey, side, iris, "wink" if expr == "wink" and side > 0.0 else ("fierce" if expr == "fierce" else "open"))
		if expr == "fierce":
			line([ex - side * 8, ey - 18, ex + side * 9, ey - 25], brow, 2.2)
		else:
			line([ex - side * 8, ey - 23, ex, ey - 25.5, ex + side * 9, ey - 24], brow, 1.8)
	line([cx + 1.5, cy + 25, cx + 2.5, cy + 27.5], SKIN_SH.darkened(0.2), 1.3)
	match expr:
		"wink":
			poly([cx - 6, cy + 32, cx + 6, cy + 32, cx + 3, cy + 37, cx - 3, cy + 37], Color("#A3264F"), false)
			_fill(ell(cx, cy + 35.5, 3.0, 1.4), Color("#FF8FB0"))
		"fierce":
			line([cx - 4, cy + 34, cx + 2, cy + 34, cx + 6, cy + 31], LASH, 1.8)
		_:
			line([cx - 4.5, cy + 33, cx, cy + 35, cx + 4.5, cy + 33], LASH, 1.8)
