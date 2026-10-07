extends RefCounted
## Alley Brawl world data and follow camera (Story 025). The world is WORLD_SCREENS view-widths
## wide and split into three districts, each with a palette. Encounter zones (3 waves + the
## boss) and secret spots are placed along it. All positions below are in view widths (S, the
## view's pixel width); multiply by `view_w` to get world pixels. Tune everything here.

const WORLD_SCREENS := 3.5
const START := 0.35

## Districts: name, start/end (view widths), palette. `moon` is the moon's strength (0..1).
const DISTRICTS := [
	{"name": "Noodle Row", "from": 0.0, "to": 1.3, "sky_top": Color("#1B0F2E"), "sky_bot": Color("#4A2238"),
		"far": Color("#2A1636"), "mid": Color("#3A1F3D"), "floor": Color("#2A1620"), "floor_line": Color("#FFB35E"),
		"a": Color("#FFB35E"), "b": Color("#FF6B4A"), "moon": 0.0},
	{"name": "Neon Crossing", "from": 1.3, "to": 2.4, "sky_top": Color("#0E0B2E"), "sky_bot": Color("#2A1650"),
		"far": Color("#1A1244"), "mid": Color("#241A5A"), "floor": Color("#150E33"), "floor_line": Color("#52E8C6"),
		"a": Color("#FF5FA2"), "b": Color("#52E8C6"), "moon": 0.0},
	{"name": "Lantern Bridge", "from": 2.4, "to": 3.5, "sky_top": Color("#071538"), "sky_bot": Color("#1F3C78"),
		"far": Color("#0E2252"), "mid": Color("#14306A"), "floor": Color("#16213F"), "floor_line": Color("#BFD9FF"),
		"a": Color("#FFD36E"), "b": Color("#8EC8FF"), "moon": 1.0},
]
## Width of the blend between two districts (view widths).
const BLEND := 0.3

## Encounter zones in order: waves 1..3 then the boss. `center` is where the camera locks
## (arena = one screen wide), `trigger` is the world x (view widths) that starts the fight.
const ZONES := [
	{"center": 1.0, "trigger": 0.8},
	{"center": 1.8, "trigger": 1.55},
	{"center": 2.4, "trigger": 2.15},
	{"center": 3.0, "trigger": 2.75},
]

## Secret spots (view widths): walk to them for a star burst, once per run.
const SECRETS := [
	{"x": 0.62, "kind": "cart"},
	{"x": 1.62, "kind": "ledge"},
	{"x": 2.78, "kind": "lamp"},
]
const SECRET_RADIUS_PX := 36.0
const SECRET_SCORE := 2

## Movement tuning (px per frame at u = 1, 60 Hz).
const MAX_SPEED := 3.7
const ACCEL := 0.32
const DECEL := 0.5
const BLOCK_SPEED_MULT := 0.6
const PUNCH_LUNGE := 1.5
## Guard meter tuning: full 100, drain per frame while blocking, regen per frame, cost per blocked hit.
const GUARD_MAX := 100.0
const GUARD_DRAIN := 0.4
const GUARD_REGEN := 0.7
const GUARD_HIT_COST := 6.0
const GUARD_BREAK_FRAMES := 60
const GUARD_AFTER_BREAK := 35.0
const PERFECT_BLOCK_FRAMES := 8
const PERFECT_STUN_FRAMES := 45

## Camera tuning: look-ahead (px at u=1), deadzone, smoothing per frame.
const LOOK_AHEAD := 70.0
const DEADZONE := 30.0
const FOLLOW := 0.12
const LOCK_FOLLOW := 0.1

var cam_x := 0.0
var look := 0.0
## World x the camera is locked to while a zone is active, or -1.0 when free.
var lock_x := -1.0


## World width in pixels for a view `view_w` pixels wide.
static func world_w(view_w: float) -> float:
	return view_w * WORLD_SCREENS


## World x of zone `i`'s trigger / camera lock position (left edge of the arena) in pixels.
static func zone_trigger_px(i: int, view_w: float) -> float:
	return float(ZONES[i]["trigger"]) * view_w


static func zone_lock_px(i: int, view_w: float) -> float:
	return clampf(float(ZONES[i]["center"]) * view_w - view_w * 0.5, 0.0, view_w * (WORLD_SCREENS - 1.0))


## District index (0..2) containing world pixel x.
static func district_at(x: float, view_w: float) -> int:
	var s: float = x / maxf(view_w, 1.0)
	for i in DISTRICTS.size():
		if s < float(DISTRICTS[i]["to"]):
			return i
	return DISTRICTS.size() - 1


## Palette at world pixel x: the district palette, cross-faded near district borders.
static func palette_at(x: float, view_w: float) -> Dictionary:
	var s: float = x / maxf(view_w, 1.0)
	var i: int = district_at(x, view_w)
	var cur: Dictionary = DISTRICTS[i]
	var out: Dictionary = cur.duplicate()
	var nxt: Dictionary = {}
	var t := 0.0
	if i + 1 < DISTRICTS.size() and s > float(cur["to"]) - BLEND * 0.5:
		nxt = DISTRICTS[i + 1]
		t = clampf((s - (float(cur["to"]) - BLEND * 0.5)) / BLEND, 0.0, 1.0)
	elif i > 0 and s < float(cur["from"]) + BLEND * 0.5:
		nxt = DISTRICTS[i - 1]
		t = clampf(((float(cur["from"]) + BLEND * 0.5) - s) / BLEND, 0.0, 1.0)
	if nxt.is_empty():
		return out
	t = t * 0.5
	for k in ["sky_top", "sky_bot", "far", "mid", "floor", "floor_line", "a", "b"]:
		out[k] = (cur[k] as Color).lerp(nxt[k], t)
	out["moon"] = lerpf(float(cur["moon"]), float(nxt["moon"]), t)
	return out


## Places the camera instantly (zone start or boss debug start).
func snap(player_x: float, view_w: float) -> void:
	cam_x = clampf(player_x - view_w * 0.5, 0.0, view_w * (WORLD_SCREENS - 1.0))


## One 60 Hz camera step: follow with look-ahead and a deadzone, or glide to the zone lock.
func step(player_x: float, facing: int, view_w: float, u: float) -> void:
	var max_cam: float = view_w * (WORLD_SCREENS - 1.0)
	if lock_x >= 0.0:
		cam_x = lerpf(cam_x, lock_x, LOCK_FOLLOW)
		if absf(cam_x - lock_x) < 0.5:
			cam_x = lock_x
		return
	look = lerpf(look, float(facing) * LOOK_AHEAD * u, 0.05)
	var target: float = player_x + look - view_w * 0.5
	if absf(target - cam_x) < DEADZONE * u:
		target = cam_x
	cam_x = clampf(lerpf(cam_x, target, FOLLOW), 0.0, max_cam)
