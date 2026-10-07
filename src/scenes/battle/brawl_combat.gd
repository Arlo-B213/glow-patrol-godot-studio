extends RefCounted
## Alley Brawl combat helpers (Story 025, split out of the view): enemy/boss movement, hit and bump
## resolution, block handling and the pet's zap. `v` is the AlleyBrawlView; these functions are
## called once per 60 Hz tick (companion: once per frame) and mutate its public state.

const World := preload("res://scenes/battle/brawl_world.gd")
const BrawlEnemies := preload("res://scripts/brawl_enemies.gd")
const BlinkerArt := preload("res://scenes/battle/brawl_art_enemies.gd")


static func update_enemies(v: Variant) -> void:
	for i in range(v.enemies.size() - 1, -1, -1):
		var e: Dictionary = v.enemies[i]
		e["age"] += 1
		var step: float = float(e["speed"]) * v.u
		if e["type"] == "blinker":
			step *= 1.64 if BlinkerArt.blinker_airborne(int(e["age"])) else 0.0
		if int(e["hit_t"]) > 0:
			e["hit_t"] -= 1
			step = 0.0
		if int(e.get("stun", 0)) > 0:
			e["stun"] -= 1
			step = 0.0
		e["x"] += (-1.0 if v.player_x < e["x"] else 1.0) * step + float(e["kb"])
		e["kb"] = float(e["kb"]) * 0.8
		if e["bump_cooldown"] > 0:
			e["bump_cooldown"] -= 1
		var dx: float = e["x"] - v.player_x
		var dx_sign: int = -1 if dx < 0 else 1
		if v.punch_active > 0 and int(e["hit_punch_id"]) != v.punch_id and dx_sign == v.player_facing and abs(dx) < 46.0 * v.u * v.reach:
			e["hit_punch_id"] = v.punch_id
			Snd.play("punch", 0.06)
			v._spawn_particles(Vector2(e["x"], v.ground_y - 24.0 * v.u), e["color"])
			v._hit_enemy(i, false, v.player_x)
			continue
		if abs(dx) < 28.0 * v.u and int(e["bump_cooldown"]) <= 0 and int(e["hit_t"]) <= 0 and int(e.get("stun", 0)) <= 0:
			e["bump_cooldown"] = 50
			var res: int = try_block(v, e["x"])
			if res == 0:
				v._hurt_player(e["x"])
			else:
				e["kb"] = v._away(e["x"], v.player_x) * 6.0 * v.u
				if res == 2:
					e["stun"] = World.PERFECT_STUN_FRAMES


static func update_boss(v: Variant) -> void:
	if v.boss.is_empty():
		return
	v.boss["age"] = int(v.boss.get("age", 0)) + 1
	if int(v.boss.get("stun", 0)) > 0:
		v.boss["stun"] -= 1
	else:
		v.boss["x"] += (-1.0 if v.player_x < v.boss["x"] else 1.0) * 0.8 * v.u
	var bdx: float = v.boss["x"] - v.player_x
	var bdx_sign: int = -1 if bdx < 0 else 1
	if v.punch_active > 0 and bdx_sign == v.player_facing and abs(bdx) < 58.0 * v.u * v.reach:
		if int(v.boss["last_hit_id"]) != v.punch_id:
			v.boss["last_hit_id"] = v.punch_id
			v.boss["health"] -= 1
			Snd.play("boss_hit", 0.05)
			v.boss_hit_flash = v.BOSS_FLASH_FRAMES
			v.boss_recoil = v._away(v.boss["x"], v.player_x) * 10.0 * v.u
			v._spawn_particles(Vector2(v.boss["x"], v.ground_y - 40.0 * v.u), Color("#7C3AED"))
			if int(v.boss["health"]) <= 0:
				v._spawn_particles(Vector2(v.boss["x"], v.ground_y - 40.0 * v.u), Color("#FF5FA2"))
				v.score += 30
				v.boss = {}
				v._end_brawl(true)
				return
	elif abs(bdx) < 40.0 * v.u and int(v.boss.get("bump_cooldown", 0)) <= 0 and int(v.boss.get("stun", 0)) <= 0:
		v.boss["bump_cooldown"] = 60
		var res: int = try_block(v, v.boss["x"])
		if res == 0:
			v._hurt_player(v.boss["x"])
		else:
			v.boss_recoil = v._away(v.boss["x"], v.player_x) * 8.0 * v.u
			if res == 2:
				v.boss["stun"] = World.PERFECT_STUN_FRAMES
	if not v.boss.is_empty() and int(v.boss.get("bump_cooldown", 0)) > 0:
		v.boss["bump_cooldown"] = int(v.boss["bump_cooldown"]) - 1
	if v.boss_hit_flash > 0:
		v.boss_hit_flash -= 1
	v.boss_recoil *= 0.82


static func try_block(v: Variant, from_x: float) -> int:
	if not v.blocking or v._away(from_x, v.player_x) != float(v.player_facing):
		return 0
	Snd.play("tap")
	var at := Vector2(v.player_x + float(v.player_facing) * 34.0 * v.u, v.ground_y - 72.0 * v.u)
	var perfect: bool = v.block_age <= World.PERFECT_BLOCK_FRAMES
	v._spawn_particles(at, Color("#7FF3FF") if not perfect else Color("#FFD36E"))
	v.rings.append({"pos": at, "t": 0, "color": Color("#BFFAFF") if not perfect else Color("#FFE9A0")})
	v.guard -= World.GUARD_HIT_COST
	if v.guard <= 0.0:
		v._break_guard()
	if perfect:
		v.score += 1
		return 2
	return 1


static func update_companion(v: Variant) -> void:
	if v.ended or not v.companion.zap_ready():
		return
	var from: Vector2 = v.companion.muzzle(v.ground_y, v.u)
	var best := -1
	var best_d := INF
	for i in v.enemies.size():
		var ex: float = float(v.enemies[i]["x"])
		var d: float = absf(ex - v.companion.x)
		if ex > v.cam_x() - 10.0 * v.u and ex < v.cam_x() + v.size.x + 10.0 * v.u and d < best_d:
			best = i
			best_d = d
	var boss_d: float = absf(float(v.boss["x"]) - v.companion.x) if not v.boss.is_empty() else INF
	if not v.boss.is_empty() and boss_d < best_d:
		var chip: int = mini(int(v.companion.boss_chip), int(v.boss["health"]) - 1)
		if chip > 0:
			v.boss["health"] = int(v.boss["health"]) - chip
			v.boss_hit_flash = 4
			v.boss_recoil = v._away(v.boss["x"], v.companion.x) * 4.0 * v.u
			var at := Vector2(v.boss["x"], v.ground_y - 40.0 * v.u)
			v._spawn_particles(at, Color("#FFD36E"))
			v.companion.consume_zap(at, from)
		return
	if best >= 0:
		var e: Dictionary = v.enemies[best]
		var at := Vector2(e["x"], v.ground_y - 24.0 * v.u)
		v._spawn_particles(at, e["color"])
		v.companion.consume_zap(at, from)
		v._hit_enemy(best, true, v.companion.x)
