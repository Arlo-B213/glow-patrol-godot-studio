extends RefCounted
## Shared procedural art for the idol hunter, used by Alley Brawl (side-view battle pose)
## and by the HQ / Clubhouse portrait. Every function draws onto a CanvasItem and must
## be called from its _draw(). Animation maths lives in hunter_motion.gd (Story 016).
##
## `look` is the dictionary built by GameState.hunter_look(): outfit, hair, glow (Color),
## hairstyle, headwear, face_acc (String). headwear/face_acc may be absent ("none").

const Accessories := preload("res://scripts/hunter_accessories.gd")
const Outfits := preload("res://scripts/hunter_outfits.gd")
const Shade := preload("res://scripts/hunter_shade.gd")
const Limbs := preload("res://scripts/hunter_limbs.gd")
const Face := preload("res://scripts/hunter_face.gd")
const Motion := preload("res://scripts/hunter_motion.gd")
const Weapons := preload("res://scripts/hunter_weapons.gd")

const SKIN := Color("#FFD9C2")
const INK := Color("#1A0B33")
const GOLD := Color("#FFD36E")
const PINK := Color("#FF5FA2")
const BOOT_LEGS := Color("#2A1B4D")
const STICK := Color("#F5EFFF")

## Portrait figure space: origin at the feet, x centred, y up is negative. All values in figure units.
const P_WIDTH := 110.0
const P_TOP := -124.0
const P_BOTTOM_FULL := 2.0
const P_BOTTOM_BUST := -16.0
## Rects at least this much taller than wide get the full-body portrait, others head-and-torso.
const P_FULL_BODY_ASPECT := 1.2
const P_HEAD_Y := -78.0
const P_HEAD_R := 24.0


static func _c(col: Color, a: float) -> Color:
	return Color(col.r, col.g, col.b, col.a * a)


static func _ellipse(center: Vector2, rx: float, ry: float, points: int = 20) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(points):
		var a: float = TAU * float(i) / float(points)
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


## The idol hunter in the side-view battle pose. `punch_active` counts 10 -> 0 while the
## glowstick swings. `u` is the view's layout scale (480px-field pixels). `hurt_t` is the
## frames since a hit (0..13 draws the knockback pose, -1 = not hurt). `animate` = false
## (or reduced motion on) draws a still pose with only the two-pose punch swing. `guard` (0..1)
## draws the block pose (glowstick held upright across the body).
static func draw_hunter(ci: CanvasItem, x: float, ground_y: float, u: float, facing: int, anim_t: int, moving: bool, alpha: float, punch_active: int, look: Dictionary, hurt_t: int = -1, animate: bool = true, walk_phase: float = -1.0, walk_blend: float = 1.0, guard: float = 0.0) -> void:
	var f: float = float(facing)
	var ps: Dictionary = Motion.side_pose(anim_t, moving, punch_active, hurt_t, animate and Motion.motion_on(), walk_phase, walk_blend, guard)
	var base := Vector2(x, ground_y)
	var bob: float = ps["bob"]
	var breath: float = ps["breath"]
	var hurt: float = ps["hurt"]
	var lean: float = float(ps["lean"]) * f
	var sway: float = ps["sway"]
	var outfit: Color = Motion.flash(look["outfit"], hurt)
	var hair: Color = Motion.flash(look["hair"], hurt)
	var glow: Color = look["glow"]
	var headwear: String = String(look.get("headwear", "none"))
	var face_acc: String = String(look.get("face_acc", "none"))

	ci.draw_colored_polygon(_ellipse(base + Vector2(0, -1) * u, 26.0 * u, 5.0 * u), Color(0, 0, 0, 0.35 * alpha))

	# Legs and boots (4-pose walk cycle: contact, down, passing, up).
	for side in [-1.0, 1.0]:
		var fp: Vector2 = ps["foot_b"] if side > 0.0 else ps["foot_a"]
		var hip: Vector2 = base + Vector2(side * 6.0, -40.0 - bob) * u
		var foot: Vector2 = base + Vector2(side * (float(ps["stance_x"]) + float(ps["spread"])) + f * fp.x, -4.0 - fp.y) * u
		Limbs.leg_side(ci, hip, foot, u, alpha)
		Limbs.boot_side(ci, foot, u, f, glow, alpha)

	# Free (back) arm swings opposite the front leg, behind the body.
	var back_sh: Vector2 = base + Vector2(-f * 4.0 + lean * 0.85, -68.0 - bob - breath) * u
	var ba: float = ps["back_arm"]
	var back_hand: Vector2 = back_sh + Vector2(f * sin(ba), cos(ba)) * 20.0 * u
	Limbs.arm(ci, back_sh, back_hand, 6.0 * u, Shade.darken(outfit, 0.25), alpha)
	Limbs.hand(ci, back_hand, Vector2(f * sin(ba), cos(ba)), 3.6 * u, alpha)

	# Coat tail streaming behind, then the jacket.
	Outfits.draw_side(ci, String(look.get("outfit_style", "track")), base + Vector2(lean * 0.6, -bob - breath * 0.4) * u, u, f, sway, moving, outfit, ps["tw"], alpha)

	# Hair behind the head, then the face.
	var head: Vector2 = base + Vector2(f * 2.0 + lean - f * 2.0 * hurt, -88.0 - bob + float(ps["head_dy"]) + 1.5 * hurt) * u
	Face.hair_back_side(ci, head, u, f, sway, hair, String(look["hairstyle"]) == "twintails", alpha)
	Face.face_side(ci, head, u, f, hair, alpha, ps["blink"], hurt > 0.15)

	# The gold hair clip gives way to any headwear so the two never collide.
	if headwear == "none":
		ci.draw_circle(head + Vector2(-f * 10.0, -9.0) * u, 3.0 * u, _c(GOLD, alpha))
	Accessories.draw_face_side(ci, face_acc, head, u, f, alpha)
	Accessories.draw_headwear_side(ci, headwear, head, u, f, hair, alpha)

	# Front arm and glowstick; the swing sweeps from raised-back to forward.
	var shoulder: Vector2 = base + Vector2(f * 7.0 + lean * 0.85, -70.0 - bob - breath) * u
	var ang: float = ps["ang"]
	var dir := Vector2(f * cos(ang), sin(ang))
	var hand: Vector2 = shoulder + dir * 24.0 * u
	Limbs.arm(ci, shoulder, hand, 7.0 * u, outfit, alpha)
	Weapons.draw(ci, String(look.get("weapon", "stick")), hand, dir, 36.0 * u, 4.0 * u, glow, alpha, float(ps["pulse"]), float(ps["pulse_a"]))
	Limbs.hand(ci, hand, dir, 4.2 * u, alpha)
	if punch_active > 0 and bool(ps["trail"]):
		var a_start: float = -1.3 if f > 0.0 else PI + 1.3
		var a_end: float = ang if f > 0.0 else PI - ang
		ci.draw_arc(shoulder, 54.0 * u, minf(a_start, a_end), maxf(a_start, a_end), 14, _c(glow, 0.5 * alpha), 6.0 * u)
	if hurt > 0.0:
		var tint := Color(1.0, 0.85, 0.92, 0.42 * hurt * alpha)
		ci.draw_colored_polygon(_ellipse(base + Vector2(lean * 0.6, -54.0 - bob) * u, 14.0 * u, 22.0 * u, 16), tint)
		ci.draw_colored_polygon(_ellipse(head, 13.0 * u, 13.0 * u, 16), tint)


## The idol hunter facing the viewer, scaled to fit `rect` (canvas pixels of `ci`). Rects
## much taller than wide get the full body, others a head-and-torso crop. `t` is seconds
## for the idle animation (0.0 = a still, open-eyed neutral pose, used by the cheap closet
## cards). `animate` = false (or reduced motion on) also forces the still pose. Call from
## the CanvasItem's _draw().
static func draw_portrait(ci: CanvasItem, rect: Rect2, look: Dictionary, t: float = 0.0, alpha: float = 1.0, animate: bool = true) -> void:
	if rect.size.x <= 1.0 or rect.size.y <= 1.0:
		return
	var full: bool = rect.size.y >= rect.size.x * P_FULL_BODY_ASPECT
	var bottom: float = P_BOTTOM_FULL if full else P_BOTTOM_BUST
	var k: float = minf(rect.size.x / P_WIDTH, rect.size.y / (bottom - P_TOP))
	var origin := Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + rect.size.y * 0.5 - (P_TOP + bottom) * 0.5 * k)
	var live: bool = animate and t != 0.0 and Motion.motion_on()
	var bob: float = sin(t * 2.2) * 1.5 * k if live else 0.0
	var breath: float = (sin(t * 1.9) * 0.5 + 0.5) * 1.3 * k if live else 0.0
	var hsway: float = sin(t * 1.6 - 0.7) * 1.6 if live else 0.0
	var blink: float = Motion.blink(t) if live else 0.0
	var pulse: float = 1.0 + 0.08 * sin(t * 2.4) if live else 1.0
	var pulse_a: float = 1.0 + 0.25 * sin(t * 2.4) if live else 1.0

	var outfit: Color = look["outfit"]
	var hair: Color = look["hair"]
	var glow: Color = look["glow"]
	var twin: bool = String(look["hairstyle"]) == "twintails"
	var headwear: String = String(look.get("headwear", "none"))
	var face_acc: String = String(look.get("face_acc", "none"))
	var up := Vector2(0.0, -bob)
	var rise := Vector2(0.0, -breath)
	var head: Vector2 = origin + Vector2(0.0, P_HEAD_Y) * k + up + rise * 0.8

	if full:
		for side in [-1.0, 1.0]:
			Limbs.leg_front(ci, origin, up, side, k, outfit, glow, alpha)

	# Jacket, centre seam, belt.
	Outfits.draw_front(ci, String(look.get("outfit_style", "track")), origin + up + rise * 0.4, k, outfit, t if live else 0.0, alpha)

	# Hair behind the head, then the face.
	Face.hair_back_front(ci, head, k, hair, twin, alpha, hsway)
	Face.face_front(ci, head, k, hair, alpha, blink)

	if headwear == "none":
		ci.draw_circle(head + Vector2(-16.0, -17.0) * k, 3.8 * k, _c(GOLD, alpha))
	Accessories.draw_face_front(ci, face_acc, head, k, alpha)
	Accessories.draw_headwear_front(ci, headwear, head, k, hair, alpha)

	# Arms, with the glowstick raised on the viewer's right.
	var arm_up: Vector2 = up + rise
	Limbs.arm(ci, origin + Vector2(-26.0, -48.0) * k + arm_up, origin + Vector2(-33.0, -30.0) * k + arm_up * 0.6, 9.0 * k, outfit, alpha)
	Limbs.hand(ci, origin + Vector2(-33.0, -28.0) * k + arm_up * 0.6, Vector2.DOWN, 5.0 * k, alpha)
	var hand: Vector2 = origin + Vector2(34.0, -36.0) * k + arm_up * 0.6
	var tip: Vector2 = origin + Vector2(42.0, -74.0) * k + arm_up * 0.6
	var sdir: Vector2 = (tip - hand).normalized()
	Limbs.arm(ci, origin + Vector2(26.0, -48.0) * k + arm_up, hand, 9.0 * k, outfit, alpha)
	Weapons.draw(ci, String(look.get("weapon", "stick")), hand, sdir, (tip - hand).length() + 6.0 * k, 4.5 * k, glow, alpha, pulse, pulse_a)
	Limbs.hand(ci, hand, sdir, 5.0 * k, alpha)
