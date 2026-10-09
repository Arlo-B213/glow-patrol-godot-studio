extends RefCounted
## Alley Brawl combat helpers (Story 025, lanes and combo in Story 036): enemy updates, the lane-aware
## punch box (x AND depth), hit resolution with knock-down and drops, block handling and the pet's
## zap. `v` is the AlleyBrawlView; these functions run once per 60 Hz tick (companion: per frame)
## and mutate its public state. Boss logic lives in brawl_boss.gd.

const World := preload("res://scenes/battle/brawl_world.gd")
const Lanes := preload("res://scenes/battle/brawl_lanes.gd")
const Ai := preload("res://scenes/battle/brawl_ai.gd")
const Fx := preload("res://scenes/battle/brawl_fx.gd")
const Pickups := preload("res://scenes/battle/brawl_pickups.gd")


## True when a target at (x, depth d) is inside the hunter's punch box (forward reach, a little
## behind, and a generous depth tolerance). `wide` is the reach multiplier of the target type.
static func in_punch_box(v: Variant, x: float, d: float, reach_px: float, tol_px: float) -> bool:
	var fwd: float = (x - v.player_x) * float(v.player_facing)
	var r: float = reach_px * v.u * (1.15 if v.punch_step == 2 else 1.0)
	return fwd > -World.PUNCH_BACK * v.u and fwd < r and Lanes.dy_px(v, d, v.player_y) < tol_px * v.u


static func update_enemies(v: Variant) -> void:
	Ai.assign_attackers(v)
	for i in range(v.enemies.size() - 1, -1, -1):
		var e: Dictionary = v.enemies[i]
		Ai.step(v, e)
		if v.punch_active > 0 and int(e["hit_punch_id"]) != v.punch_id and String(e["mode"]) != "down" \
				and in_punch_box(v, float(e["x"]), float(e["y"]), World.PUNCH_REACH * v.reach, World.PUNCH_DEPTH_TOL):
			e["hit_punch_id"] = v.punch_id
			Snd.play("punch", 0.06)
			var fin: bool = v.punch_step == 2
			var s: float = Lanes.scale_at(float(e["y"]))
			Fx.spark(v, Vector2(e["x"], Lanes.feet_y(v, float(e["y"])) - 32.0 * v.u * s), e["color"], fin)
			v.spawn_particles(Vector2(e["x"], Lanes.feet_y(v, float(e["y"])) - 24.0 * v.u * s), e["color"])
			v.register_combo_hit(Vector2(e["x"], Lanes.feet_y(v, float(e["y"])) - 70.0 * v.u * s))
			if fin:
				Fx.hit_stop(v, World.HITSTOP_FINISHER)
				Fx.shake_screen(v, World.SHAKE_FINISHER)
			v.hit_enemy(i, false, v.player_x, fin)


## Resolves an enemy's strike on the hunter: blocked (kick-back, perfect block stuns) or a hurt.
static func enemy_bump(v: Variant, e: Dictionary) -> void:
	var res: int = try_block(v, float(e["x"]))
	if res == 0:
		v.hurt_player(float(e["x"]))
	else:
		e["kb"] = v.away(float(e["x"]), v.player_x) * 6.0 * v.u
		if res == 2:
			e["stun"] = World.PERFECT_STUN_FRAMES


## Tries to block a hit coming from world x `from_x`. Returns 0 = not blocked, 1 = blocked, 2 = perfect
## block (block pressed within PERFECT_BLOCK_FRAMES before the hit: stuns the attacker, +1 score).
static func try_block(v: Variant, from_x: float) -> int:
	if not v.blocking or v.away(from_x, v.player_x) != float(v.player_facing):
		return 0
	Snd.play("tap")
	var s: float = Lanes.scale_at(v.player_y)
	var at := Vector2(v.player_x + float(v.player_facing) * 34.0 * v.u * s, Lanes.feet_y(v, v.player_y) - 72.0 * v.u * s)
	var perfect: bool = v.block_age <= World.PERFECT_BLOCK_FRAMES
	v.spawn_particles(at, Color("#7FF3FF") if not perfect else Color("#FFD36E"))
	v.rings.append({"pos": at, "t": 0, "color": Color("#BFFAFF") if not perfect else Color("#FFE9A0")})
	v.guard -= World.GUARD_HIT_COST
	if v.guard <= 0.0:
		v.break_guard()
	if perfect:
		v.score += 1
		Fx.popup(v, "Perfect!", at + Vector2(0, -26.0 * v.u), Color("#FFE9A0"), 18.0)
		return 2
	return 1


## The pet zaps the nearest Gloomling within range (2D distance) or chips the boss.
static func update_companion(v: Variant) -> void:
	if v.ended or not v.companion.zap_ready():
		return
	var cfy: float = Lanes.feet_y(v, v.companion.d)
	var from: Vector2 = v.companion.muzzle(cfy, v.u * Lanes.scale_at(v.companion.d))
	var best := -1
	var best_d := INF
	var range_px: float = 300.0 * v.u
	for i in v.enemies.size():
		var ex: float = float(v.enemies[i]["x"])
		var d: float = absf(ex - v.companion.x) + absf(float(v.enemies[i]["y"]) - v.companion.d) * v.lane_h * 1.5
		if ex > v.cam_x() - 10.0 * v.u and ex < v.cam_x() + v.size.x + 10.0 * v.u and d < best_d and d < range_px:
			best = i
			best_d = d
	var boss_d: float = INF
	if not v.boss.is_empty():
		boss_d = absf(float(v.boss["x"]) - v.companion.x) + absf(float(v.boss["y"]) - v.companion.d) * v.lane_h * 1.5
	if not v.boss.is_empty() and boss_d < best_d:
		var chip: int = mini(int(v.companion.boss_chip), int(v.boss["health"]) - 1)
		if chip > 0:
			v.boss["health"] = int(v.boss["health"]) - chip
			v.boss_hit_flash = 4
			v.boss_recoil = v.away(v.boss["x"], v.companion.x) * 4.0 * v.u
			var at := Vector2(v.boss["x"], Lanes.feet_y(v, float(v.boss["y"])) - 40.0 * v.u)
			v.spawn_particles(at, Color("#FFD36E"))
			v.companion.consume_zap(at, from)
		return
	if best >= 0:
		var e: Dictionary = v.enemies[best]
		var at2 := Vector2(e["x"], Lanes.feet_y(v, float(e["y"])) - 24.0 * v.u)
		v.spawn_particles(at2, e["color"])
		v.companion.consume_zap(at2, from)
		v.hit_enemy(best, true, v.companion.x, false)
