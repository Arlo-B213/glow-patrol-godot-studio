extends RefCounted
## Pose maths for the idol hunter animation (Story 016): blink, breathing, sway, 4-pose
## walk cycle, punch phases, hurt knockback and glow pulse. VISUAL ONLY: nothing here
## feeds back into gameplay. All functions are pure and deterministic from time/frames.

const CYCLE := 24.0
const BLINK_PERIOD := 4.0
const BLINK_LEN := 0.12
const HURT_FRAMES := 14
const REST_ANG := 1.1


## True when animation may play (GameState.reduce_motion is false). Static-safe lookup.
static func motion_on() -> bool:
	var loop := Engine.get_main_loop()
	if loop is SceneTree:
		var gs: Node = (loop as SceneTree).root.get_node_or_null("GameState")
		if gs != null:
			return not bool(gs.get("reduce_motion"))
	return true


## Eye closure 0 (open) .. 1 (closed) at `sec` seconds. One ~0.12 s blink per 4 s window,
## the start jittering by a hash of the window so intervals run roughly 3-5 s.
static func blink(sec: float) -> float:
	var idx: int = floori(sec / BLINK_PERIOD)
	var h: float = fposmod(sin(float(idx) * 12.9898 + 4.1) * 43758.5453, 1.0)
	var d: float = (fposmod(sec, BLINK_PERIOD) - (1.5 + h)) / BLINK_LEN
	if d < 0.0 or d >= 1.0:
		return 0.0
	return clampf(sin(d * PI) * 1.5, 0.0, 1.0)


## Lightens a colour toward pink-white by `amt` (0..1) for the hurt flash.
static func flash(c: Color, amt: float) -> Color:
	if amt <= 0.0:
		return c
	return c.lerp(Color(1.0, 0.85, 0.92, c.a), amt * 0.6)


static func _key4(p: float, a: float, b: float, c: float, d: float) -> float:
	var q: float = fposmod(p, 1.0) * 4.0
	var i: int = int(q)
	var k: float = smoothstep(0.0, 1.0, q - float(i))
	var v: Array = [a, b, c, d]
	return lerpf(float(v[i % 4]), float(v[(i + 1) % 4]), k)


## One leg at cycle phase `p` (0..1): Vector2(forward offset, lift) in figure units.
## Stance (0..0.5): contact -> down -> passing, foot planted sliding back. Swing
## (0.5..1): up pose, knee/boot lifts and the foot reaches forward to the next contact.
static func leg_pose(p: float) -> Vector2:
	p = fposmod(p, 1.0)
	if p < 0.5:
		return Vector2(lerpf(9.0, -9.0, p / 0.5), 0.0)
	var q: float = (p - 0.5) / 0.5
	return Vector2(lerpf(-9.0, 9.0, smoothstep(0.0, 1.0, q)), sin(q * PI) * 7.0)


## Side-view pose for one frame. Keys: bob, breath, head_dy, lean (forward units, multiply
## by facing), foot_a / foot_b (Vector2 forward,lift for side -1 / +1), stance_x, spread,
## back_arm (rad forward of down), ang (stick arm angle), trail (draw swing arc), hurt (0..1),
## blink, sway, pulse, pulse_a, tw.
## `walk_phase` (>= 0) is the stride phase in cycles, driven by distance travelled, and
## `walk_blend` (0..1) eases between idle and walking so starting/stopping never snaps.
## A negative `walk_phase` keeps the older time-driven cycle (`moving` = full blend).
## `guard` (0..1) raises the glowstick upright across the body and leans back (Story 025 block pose).
static func side_pose(anim_t: int, moving: bool, punch_active: int, hurt_t: int, animate: bool, walk_phase: float = -1.0, walk_blend: float = 1.0, guard: float = 0.0) -> Dictionary:
	var t: float = float(anim_t)
	var ps := {"bob": 0.0, "breath": 0.0, "head_dy": 0.0, "lean": 0.0, "foot_a": Vector2.ZERO, "foot_b": Vector2.ZERO,
		"stance_x": 7.0, "spread": 0.0, "back_arm": 0.04, "ang": REST_ANG, "trail": false, "hurt": 0.0,
		"blink": 0.0, "sway": 0.0, "pulse": 1.0, "pulse_a": 1.0, "tw": 0.0}
	var ang: float = REST_ANG
	var lean: float = 0.0
	if punch_active > 0:
		var e: float = float(10 - punch_active)
		if not animate:
			ang = lerpf(-1.3, 0.35, e / 10.0)
			ps["trail"] = true
		elif e < 2.0:
			ang = lerpf(REST_ANG, -1.75, e / 2.0)
			lean = lerpf(0.0, -2.5, e / 2.0)
		elif e < 7.0:
			var k: float = 1.0 - pow(1.0 - (e - 2.0) / 5.0, 2.0)
			ang = lerpf(-1.75, 0.45, k)
			lean = lerpf(-2.5, 2.5, k)
			ps["trail"] = true
		else:
			var k2: float = (e - 7.0) / 3.0
			ang = lerpf(0.45, 1.0, k2)
			lean = lerpf(2.5, 0.0, k2)
			ps["trail"] = k2 < 0.4
	if animate:
		var sec: float = t / 60.0
		var breath: float = (sin(t * 0.07) * 0.5 + 0.5) * 1.3
		ps["breath"] = breath
		ps["head_dy"] = -breath * 0.9 + sin(t * 0.07 - 0.7) * 0.4
		ps["blink"] = blink(sec)
		var amp: float = 3.1 if moving else 1.8
		ps["sway"] = sin(t * 0.16 - 0.8) * amp
		ps["pulse"] = 1.0 + 0.08 * sin(t * 0.13)
		ps["pulse_a"] = 1.0 + 0.25 * sin(t * 0.13)
		ps["tw"] = t * 0.1
		var wb: float = walk_blend if walk_phase >= 0.0 else (1.0 if moving else 0.0)
		if wb > 0.001:
			var ph: float = walk_phase if walk_phase >= 0.0 else t / CYCLE
			var a: Vector2 = leg_pose(ph)
			var b: Vector2 = leg_pose(ph + 0.5)
			ps["foot_a"] = a * wb
			ps["foot_b"] = b * wb
			ps["stance_x"] = lerpf(7.0, 3.0, wb)
			ps["bob"] = _key4(ph * 2.0, 0.5, -1.5, 3.0, 1.5) * wb
			ps["back_arm"] = lerpf(0.04, b.x / 9.0 * 0.9, wb)
			ps["sway"] = float(ps["sway"]) * lerpf(1.0, 1.6, wb)
			lean += wb
			if punch_active <= 0:
				ang = REST_ANG + a.x / 9.0 * 0.22 * wb
	var hurt: float = 0.0
	if animate and hurt_t >= 0 and hurt_t < HURT_FRAMES:
		hurt = 1.0 - float(hurt_t) / float(HURT_FRAMES)
		lean = lerpf(lean, -7.0, hurt)
		ang = lerpf(ang, -0.4, hurt)
		ps["back_arm"] = lerpf(float(ps["back_arm"]), -1.0, hurt)
		ps["spread"] = 4.0 * hurt
		ps["blink"] = 1.0
		ps["trail"] = false
	if guard > 0.0:
		ang = lerpf(ang, -1.3, guard)
		lean = lerpf(lean, -1.2, guard)
		ps["back_arm"] = lerpf(float(ps["back_arm"]), 0.5, guard)
		ps["trail"] = false
	ps["hurt"] = hurt
	ps["lean"] = lean
	ps["ang"] = ang
	return ps
