extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Shared toolkit for the "gloom" enemy and boss art (Story 031). A `Rig` wraps one character draw:
## it maps local units (100 = the enemy size `s`, y up is negative, feet at y = 0, +x = towards the
## hunter) to canvas pixels and draws outlined, three-tone shaded parts. Limb helpers (legs, arms)
## and the pose maths (walk phase, breathing, wind-up) live here too. Every function draws onto a
## CanvasItem from its _draw(). All polygons handed to the canvas are simple (non self-crossing).

const Shade := preload("res://scripts/hunter_shade.gd")
const INK := Color("#1A0B33")
const BLACKOUT := Color("#0A0418")
const EYE_WHITE := Color("#F6F2FF")
const TOOTH := Color("#FFFDF2")
const TONGUE := Color("#FF6E9C")

## Facial expressions (see gloom_face.gd). Bosses add SLEEPY, GIGGLE, SNEEZE, ROAR and GRUMP.
enum Mood { IDLE, ANGRY, HURT, STUNNED, DYING, SMILE, SLEEPY, GIGGLE, SNEEZE, ROAR, GRUMP }


## True when the player turned on reduce motion (null-safe: false if the autoload is missing).
static func calm() -> bool:
	var loop: MainLoop = Engine.get_main_loop()
	if loop is SceneTree:
		var gs: Node = (loop as SceneTree).root.get_node_or_null("GameState")
		if gs != null:
			return bool(gs.get("reduce_motion"))
	return false


## Picks the expression from the `fx` dictionary (explicit `mood` wins).
static func mood_from(fx: Dictionary, flash: float) -> int:
	if fx.has("mood"):
		return int(fx["mood"])
	if fx.has("dying"):
		return Mood.DYING if float(fx["dying"]) < 0.28 else Mood.SMILE
	if flash > 0.3:
		return Mood.HURT
	if bool(fx.get("stun", false)):
		return Mood.STUNNED
	if float(fx.get("near", 0.0)) > 0.45 or float(fx.get("strike", 0.0)) > 0.0:
		return Mood.ANGRY
	return Mood.IDLE


## Builds a rig for one character. `fx` keys (all optional): flash, alpha, sq, hp, walk (0..1 walk
## blend), near (0..1 how close the hunter is), strike (0..1 just bumped), stun (bool), dying (0..1),
## air (bool, dangling pose), mood (Mood override).
static func make_rig(ci: CanvasItem, x: float, ground_y: float, s: float, color: Color, age: int, toward: float, u: float, fx: Dictionary) -> Rig:
	var r := Rig.new()
	r.ci = ci
	r.o = Vector2(x, ground_y)
	r.k = s / 100.0
	var sq: float = clampf(float(fx.get("sq", 1.0)), 0.5, 1.5)
	r.kx = r.k * (1.0 + (1.0 / sq - 1.0) * 0.6)
	r.ky = r.k * sq
	r.dir = -1.0 if toward < 0.0 else 1.0
	r.look = minf(1.0, absf(toward))
	r.u = u
	r.ow = clampf(s * 0.03, 1.1, 3.2)
	r.glow = Shade.lighten(color, 0.2)
	r.base = color
	r.flash = clampf(float(fx.get("flash", 0.0)), 0.0, 1.0)
	r.al = clampf(float(fx.get("alpha", 1.0)), 0.0, 1.0)
	r.calm = calm()
	r.t = 0.0 if r.calm else float(age)
	r.ph = r.t * 0.24
	r.walk = 0.0 if r.calm else float(fx.get("walk", 1.0))
	r.air = bool(fx.get("air", false))
	r.near = float(fx.get("near", 0.0))
	r.strike = 0.0 if r.calm else float(fx.get("strike", 0.0))
	r.hp = int(fx.get("hp", 2))
	r.mood = mood_from(fx, r.flash)
	r.blink = (not r.calm) and age % 97 < 5 and r.mood == Mood.IDLE
	r.breath = sin(r.t * 0.11) * 0.5 + 0.5
	r.detail = s >= 110.0
	return r


## Legs from the hips: walk cycle (alternating lift and stride), or dangling when `r.air`.
## `knee` > 0 bends each leg outward at the knee. Returns nothing; feet end at y = 0.
static func legs(r: Rig, hip_y: float, spread: float, w: float, col: Color, shoe: Color, foot_rx: float, foot_ry: float, stride: float, lift: float, knee: float = 0.0) -> void:
	for side in [-1.0, 1.0]:
		var sd: float = side
		var phs: float = r.ph + (0.0 if sd < 0.0 else PI)
		var sw: float = cos(phs) * stride * r.walk
		var lf: float = maxf(0.0, sin(phs)) * lift * r.walk
		var hip := Vector2(sd * spread, hip_y)
		var foot := Vector2(sd * spread * 1.08 + sw, -lf - foot_ry * 0.5)
		if r.air:
			var dang: float = 0.0 if r.calm else sin(r.t * 0.2 + sd * 1.3) * stride * 0.5
			foot = Vector2(sd * spread * 0.9 + dang, hip_y - hip_y * 0.8)
		if knee > 0.0:
			var mid: Vector2 = hip.lerp(foot, 0.5) + Vector2(sd * knee, 0.0)
			r.limb(hip, mid, w, col)
			r.limb(mid, foot, w * 0.92, col)
		else:
			r.limb(hip, foot, w, col)
		r.ell(foot.x + sd * foot_rx * 0.25, foot.y + foot_ry * 0.3, foot_rx, foot_ry, shoe, false)


## One arm: `raise` is the angle from hanging (0) through sideways (PI/2) to straight up (PI).
## Returns the hand position in local units so callers can attach items.
static func arm(r: Rig, side: float, shoulder: Vector2, length: float, w: float, sleeve: Color, hand_col: Color, raise: float, hand_r: float) -> Vector2:
	var hand := shoulder + Vector2(side * sin(raise) * length, cos(raise) * length)
	r.limb(shoulder, hand, w, sleeve)
	r.circ(hand.x, hand.y, hand_r, hand_col, true)
	if r.detail:
		r.circ(hand.x - side * hand_r * 0.15, hand.y - hand_r * 0.25, hand_r * 0.3, Shade.lighten(hand_col, 0.45), false, 0.6)
	return hand


## Arm swing offset (radians) for `side`, opposite to the legs; wind-up and strike lift both fists.
static func swing(r: Rig, side: float, amount: float) -> float:
	var sw: float = sin(r.ph + (PI if side < 0.0 else 0.0)) * amount * r.walk
	return sw + r.near * 0.5 + r.strike * 0.9


## Soft aura behind the character: two translucent discs in the enemy colour.
static func aura(r: Rig, cy: float, rad: float, a: float) -> void:
	var pulse: float = 1.0 if r.calm else 1.0 + sin(r.t * 0.12) * 0.04
	r.disc(0.0, cy, rad * pulse, Color(r.base, a * (0.55 if r.detail else 1.0)))
	if r.detail:
		r.disc(0.0, cy, rad * 0.72 * pulse, Color(r.base, a))


## Soft dark floor shadow under the feet.
static func floor_shadow(r: Rig, rx: float) -> void:
	FD.poly(r.ci, Shade.ellipse(r.o + Vector2(0.0, r.ky * 0.5), rx * r.kx, rx * 0.16 * r.ky, 16), Color(0.03, 0.0, 0.08, 0.4 * r.al))
	r.n += 1


## Dizzy stars orbiting local point (x, y) (static under reduce motion).
static func dizzy(r: Rig, x: float, y: float, rad: float) -> void:
	for i in 3:
		var a: float = (0.0 if r.calm else r.t * 0.14) + TAU * float(i) / 3.0
		FD.circle(r.ci, r.p(x + cos(a) * rad, y + sin(a) * rad * 0.28), 2.6 * r.k * 0.55 + 1.0, r.c(Color("#FFE27A")))
		r.n += 1


## One drawing context; see the file header. Local units, 100 = enemy size.
class Rig extends RefCounted:
	var ci: CanvasItem
	var o: Vector2
	var k: float = 1.0
	var kx: float = 1.0
	var ky: float = 1.0
	var dir: float = 1.0
	var look: float = 1.0
	var u: float = 1.0
	var ow: float = 1.5
	var glow: Color = Color.WHITE
	var base: Color = Color.WHITE
	var flash: float = 0.0
	var al: float = 1.0
	var calm: bool = false
	var t: float = 0.0
	var ph: float = 0.0
	var walk: float = 1.0
	var air: bool = false
	var near: float = 0.0
	var strike: float = 0.0
	var hp: int = 2
	var mood: int = 0
	var blink: bool = false
	var breath: float = 0.0
	## Full shading (crescents, highlights, glows) only at larger sizes; small ones stay cheap and bold.
	var detail: bool = true
	## Number of canvas draw calls issued so far (for performance budgeting).
	var n: int = 0

	## Local -> canvas position.
	func p(x: float, y: float) -> Vector2:
		return o + Vector2(x * dir * kx, y * ky)

	func pv(v: Vector2) -> Vector2:
		return p(v.x, v.y)

	## Applies the hit flash and fade to `col`.
	func c(col: Color) -> Color:
		var out: Color = col.lerp(Color.WHITE, flash * 0.6)
		out.a = col.a * al
		return out

	func ink(col: Color) -> Color:
		return c(Shade.ink(col))

	## Stroke width in pixels for `units` local units (never thinner than a hairline).
	func w(units: float) -> float:
		return maxf(1.1, units * k)

	func disc(x: float, y: float, rad: float, col: Color) -> void:
		FD.circle(ci, p(x, y), rad * k, c(col))
		n += 1

	## Filled circle with an optional outline and an alpha multiplier.
	func circ(x: float, y: float, rad: float, col: Color, outline: bool = true, alpha: float = 1.0) -> void:
		var cc: Color = c(col)
		cc.a *= alpha
		FD.circle(ci, p(x, y), rad * k, cc)
		n += 1
		if outline and (detail or rad * k > 6.0):
			FD.arc(ci, p(x, y), rad * k, 0.0, TAU, 10, ink(col), ow, detail)
			n += 1

	## Ellipse with outline and (when `shade`) a shadow crescent, a highlight and a rim light.
	func ell(x: float, y: float, rx: float, ry: float, col: Color, shade: bool = true, outline: bool = true) -> void:
		var ctr: Vector2 = p(x, y)
		var wx: float = rx * kx
		var wy: float = ry * ky
		var pts := PackedVector2Array()
		for i in 14:
			var a: float = TAU * float(i) / 14.0
			pts.append(ctr + Vector2(cos(a) * wx, sin(a) * wy))
		FD.poly(ci, pts, c(col))
		n += 1
		if outline and (detail or wx > 7.0):
			var closed := PackedVector2Array(pts)
			closed.append(pts[0])
			FD.polyline(ci, closed, ink(col), ow, detail)
			n += 1
		if shade and detail and wx > 2.5 and wy > 2.5:
			_shade_ellipse(ctr, wx, wy, col)

	func _shade_ellipse(ctr: Vector2, wx: float, wy: float, col: Color) -> void:
		var crescent := PackedVector2Array()
		var rim := PackedVector2Array()
		var shift := Vector2(-wx * 0.16, -wy * 0.12)
		for i in 9:
			var a: float = -0.5 + 2.5 * float(i) / 8.0
			var v := Vector2(cos(a) * wx, sin(a) * wy)
			crescent.append(ctr + v)
			rim.append(ctr + v)
		for i in 9:
			var a2: float = 2.0 - 2.5 * float(i) / 8.0
			crescent.append(ctr + shift + Vector2(cos(a2) * wx * 0.93, sin(a2) * wy * 0.93))
		FD.poly(ci, crescent, c(Shade.fade(Shade.darken(col, 0.3), 0.6)))
		FD.polyline(ci, rim, c(Shade.fade(glow, 0.75)), maxf(1.0, ow * 0.8), true)
		var hl := PackedVector2Array()
		for i in 10:
			var a3: float = TAU * float(i) / 10.0
			hl.append(ctr + Vector2(-wx * 0.34, -wy * 0.42) + Vector2(cos(a3) * wx * 0.28, sin(a3) * wy * 0.17))
		FD.poly(ci, hl, c(Shade.fade(Shade.lighten(col, 0.5), 0.55)))
		n += 3

	## Simple polygon in local units, with outline and an optional lit edge line.
	func poly(pts: Array, col: Color, outline: bool = true) -> void:
		var wp := PackedVector2Array()
		for v in pts:
			wp.append(pv(v as Vector2))
		if wp.size() < 3:
			return
		FD.poly(ci, wp, c(col))
		n += 1
		if outline and (detail or _span(wp) > 14.0):
			var closed := PackedVector2Array(wp)
			closed.append(wp[0])
			FD.polyline(ci, closed, ink(col), ow, detail)
			n += 1

	func _span(wp: PackedVector2Array) -> float:
		var lo: float = wp[0].x
		var hi: float = lo
		for v in wp:
			lo = minf(lo, v.x)
			hi = maxf(hi, v.x)
		return hi - lo

	## Outlined limb capsule between two local points (with lit and shadow stripes).
	func limb(a: Vector2, b: Vector2, wid: float, col: Color) -> void:
		if detail:
			Shade.limb(ci, pv(a), pv(b), wid * k, c(col), ow * 0.8, -1.0)
			n += 4
			return
		if wid * k > 5.0:
			FD.poly(ci, Shade.capsule(pv(a), pv(b), wid * k * 0.5 + ow * 0.7, 3), ink(col))
			n += 1
		FD.poly(ci, Shade.capsule(pv(a), pv(b), wid * k * 0.5, 3), c(col))
		n += 1

	## Plain line in local units.
	func line(a: Vector2, b: Vector2, wid: float, col: Color) -> void:
		ci.draw_line(pv(a), pv(b), c(col), maxf(1.0, wid * k), true)
		n += 1

	func polyline(pts: Array, wid: float, col: Color) -> void:
		var wp := PackedVector2Array()
		for v in pts:
			wp.append(pv(v as Vector2))
		FD.polyline(ci, wp, c(col), maxf(1.0, wid * k), true)
		n += 1

	## Arc around a local centre (angles in canvas space: 0 = right, PI/2 = down).
	func arc(x: float, y: float, rad: float, a0: float, a1: float, wid: float, col: Color) -> void:
		FD.arc(ci, p(x, y), rad * k, a0, a1, 10, c(col), maxf(1.0, wid * k), true)
		n += 1
