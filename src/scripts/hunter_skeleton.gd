extends RefCounted
## Named joints for the side-view idol hunter. Turns a pose dictionary (from hunter_motion.gd)
## into canvas positions for every joint the drawing needs, in one place. Pure maths: no
## drawing happens here, so the same numbers can drive the battle view and, later, a node rig.
## Coordinates are canvas pixels. `base` is the feet point, `u` the layout scale, `f` the facing
## (+1 or -1). `les` is the side-view leg extra (HunterArt.LEG_EXTRA_SIDE).


## Joint positions for one side-view frame. Keys: hip_a, hip_b, foot_a, foot_b, body, head,
## shoulder, back_shoulder, back_hand, hand, aim (unit vector of the glowstick arm).
static func side_joints(base: Vector2, u: float, f: float, ps: Dictionary, lean: float, bob: float, breath: float, les: float) -> Dictionary:
	var hurt: float = float(ps["hurt"])
	var stance_x: float = float(ps["stance_x"])
	var spread: float = float(ps["spread"])
	var fa: Vector2 = ps["foot_a"]
	var fb: Vector2 = ps["foot_b"]
	var ang: float = float(ps["ang"])
	var ba: float = float(ps["back_arm"])

	var back_sh: Vector2 = base + Vector2(-f * 4.0 + lean * 0.85, -68.0 - les - bob - breath) * u
	var shoulder: Vector2 = base + Vector2(f * 7.0 + lean * 0.85, -70.0 - les - bob - breath) * u
	var aim := Vector2(f * cos(ang), sin(ang))

	return {
		"hip_a": base + Vector2(-6.0, -40.0 - les - bob) * u,
		"hip_b": base + Vector2(6.0, -40.0 - les - bob) * u,
		"foot_a": base + Vector2(-(stance_x + spread) + f * fa.x, -4.0 - fa.y) * u,
		"foot_b": base + Vector2((stance_x + spread) + f * fb.x, -4.0 - fb.y) * u,
		"body": base + Vector2(lean * 0.6, -les - bob - breath * 0.4) * u,
		"head": base + Vector2(f * 2.0 + lean - f * 2.0 * hurt, -88.0 - les - bob + float(ps["head_dy"]) + 1.5 * hurt) * u,
		"shoulder": shoulder,
		"back_shoulder": back_sh,
		"back_hand": back_sh + Vector2(f * sin(ba), cos(ba)) * 20.0 * u,
		"hand": shoulder + aim * 24.0 * u,
		"aim": aim,
	}
