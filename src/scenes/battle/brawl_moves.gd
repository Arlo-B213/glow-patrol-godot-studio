extends RefCounted
## Lanternboy moves (Phase 3): one special attack per boy, fired from the MOVE button and then
## on a cooldown. The view passes itself in (duck-typed, like brawl_combat.gd) and the moves reuse
## its hit routine. The ids and captions live in StoryHunters.HUNTERS.

const World := preload("res://scenes/battle/brawl_world.gd")
const Lanes := preload("res://scenes/battle/brawl_lanes.gd")

## Frames until a move is ready again (the fight ticks at 60 per second).
const COOLDOWN := 300
const SWING_REACH := 120.0   ## px in front of the hunter, scaled by weapon reach
const SPIN_RADIUS := 110.0   ## px all round, scaled by weapon reach
const WARD_RANGE := 180.0    ## px for the ward's zap
const BOSS_CHIP := 1
const LANE_TOL := 40.0


## Ready fraction 0..1 for the MOVE button ring (1 = ready).
static func ready_ratio(cooldown: int) -> float:
	return 1.0 - clampf(float(cooldown) / float(COOLDOWN), 0.0, 1.0)


## Fires the view's move when it is ready and the fight is live.
static func trigger(v: Variant) -> void:
	if v.ended or not v.running or v.blocking or v.move_id == "" or v.move_cooldown > 0:
		return
	match v.move_id:
		"lantern_swing":
			_swing(v)
		"encore_spin":
			_spin(v)
		"moth_ward":
			_ward(v)
		_:
			return
	v.move_cooldown = COOLDOWN
	v.spawn_particles(Vector2(v.player_x, Lanes.feet_y(v, v.player_y) - 40.0 * v.u), Color("#FFD36E"))


## Lantern Swing (Hae): a long sweep in front, on the hunter's lane.
static func _swing(v: Variant) -> void:
	var reach_px: float = SWING_REACH * v.reach * v.u
	for i in range(v.enemies.size() - 1, -1, -1):
		var fwd: float = (float(v.enemies[i]["x"]) - v.player_x) * float(v.player_facing)
		if fwd > -World.PUNCH_BACK * v.u and fwd < reach_px and _same_lane(v, v.enemies[i]):
			v.hit_enemy(i, false, v.player_x, false)
	_chip_boss(v, reach_px)


## Encore Spin (Bit): hits everything close by, on either side.
static func _spin(v: Variant) -> void:
	var r: float = SPIN_RADIUS * v.reach * v.u
	for i in range(v.enemies.size() - 1, -1, -1):
		if absf(float(v.enemies[i]["x"]) - v.player_x) < r and _same_lane(v, v.enemies[i]):
			v.hit_enemy(i, false, v.player_x, false)
	_chip_boss(v, r)


## Moth Ward (Nun): one heart back (up to the cap) and a zap at the nearest Gloomling.
static func _ward(v: Variant) -> void:
	v.hearts = mini(int(v.hearts) + 1, int(v.max_hearts))
	v._sync_ui()
	var best := -1
	var best_dx: float = WARD_RANGE * v.u
	for i in v.enemies.size():
		var dx: float = absf(float(v.enemies[i]["x"]) - v.player_x)
		if dx < best_dx:
			best = i
			best_dx = dx
	if best >= 0:
		v.hit_enemy(best, false, v.player_x, false)


static func _same_lane(v: Variant, e: Dictionary) -> bool:
	return Lanes.dy_px(v, float(e["y"]), v.player_y) < LANE_TOL * v.u


## Chips the boss by BOSS_CHIP when it stands inside `range_px` (never finishes it off).
static func _chip_boss(v: Variant, range_px: float) -> void:
	if v.boss.is_empty() or absf(float(v.boss["x"]) - v.player_x) >= range_px:
		return
	var chip: int = mini(BOSS_CHIP, int(v.boss["health"]) - 1)
	if chip <= 0:
		return
	v.boss["health"] = int(v.boss["health"]) - chip
	v.boss_hit_flash = 4
	v.boss_recoil = v.away(v.boss["x"], v.player_x) * 4.0 * v.u
	v.spawn_particles(Vector2(v.boss["x"], Lanes.feet_y(v, float(v.boss["y"])) - 40.0 * v.u), Color("#FFD36E"))
