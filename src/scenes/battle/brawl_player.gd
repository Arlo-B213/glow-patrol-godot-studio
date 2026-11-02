extends RefCounted
## Alley Brawl hunter logic (Story 025, lanes/combo/Second Wind in Story 036), split out of the view.
## 2-axis movement across the street band (depth is slower than sideways), the block + guard meter,
## the 3-hit punch chain with input buffering and auto-facing, and the once-per-run Second Wind.
## `v` is the AlleyBrawlView; every function runs once per 60 Hz tick and mutates its public state.

const World := preload("res://scenes/battle/brawl_world.gd")
const Lanes := preload("res://scenes/battle/brawl_lanes.gd")
const Fx := preload("res://scenes/battle/brawl_fx.gd")


## One tick of player state: block/guard, movement (x and depth), timers, buffered punch.
static func update(v: Variant) -> void:
	var can_block: bool = v.controls.poll_block() and v.guard_break_t == 0 and v.punch_active == 0 and not v.ended
	if can_block and not v.blocking:
		v.block_age = 0
	elif can_block:
		v.block_age += 1
	v.blocking = can_block
	if v.blocking:
		v.guard -= World.GUARD_DRAIN
		if v.guard <= 0.0:
			v.break_guard()
	elif v.guard_break_t > 0:
		v.guard_break_t -= 1
		if v.guard_break_t == 0:
			v.guard = World.GUARD_AFTER_BREAK
	else:
		v.guard = minf(World.GUARD_MAX, v.guard + World.GUARD_REGEN)
	v.block_t = move_toward(v.block_t, 1.0 if v.blocking else 0.0, 0.25)

	var u: float = v.u
	var mv: Vector2 = v.controls.read_move() if not v.ended else Vector2.ZERO
	mv = mv.limit_length(1.0)
	var mult: float = World.BLOCK_SPEED_MULT if v.blocking else 1.0
	var tx: float = mv.x * World.MAX_SPEED * u * mult
	var ty: float = mv.y * World.MAX_SPEED * u * mult * World.DEPTH_MULT
	v.player_vx = _approach(v.player_vx, tx, u)
	v.player_vy = _approach(v.player_vy, ty, u * World.DEPTH_MULT)
	if absf(mv.x) > 0.05:
		v.player_facing = 1 if mv.x > 0.0 else -1
	var lunge: float = float(v.player_facing) * World.PUNCH_LUNGE * u if v.punch_active > 6 else 0.0
	v.player_x += v.player_vx + lunge
	v.player_y += v.player_vy / v.lane_h
	if v.player_y < 0.0 or v.player_y > 1.0:
		v.player_y = clampf(v.player_y, 0.0, 1.0)
		v.player_vy = 0.0
	var b: Vector2 = v.bounds()
	if v.player_x < b.x or v.player_x > b.y:
		v.player_x = clampf(v.player_x, b.x, b.y)
		v.player_vx = 0.0
	var moved: float = Vector2(v.player_vx, v.player_vy).length()
	v.walk_phase = fposmod(v.walk_phase + moved / (v.STRIDE_PX * u), 1.0)
	v.walk_blend = move_toward(v.walk_blend, 1.0 if moved > 0.4 * u else 0.0, v.WALK_BLEND_RATE)
	if v.player_invincible > 0:
		v.player_invincible -= 1
	if v.wind_t > 0:
		v.wind_t -= 1
	if v.punch_cooldown > 0:
		v.punch_cooldown -= 1
	if v.punch_active > 0:
		v.punch_active -= 1
	if v.combo_window > 0:
		v.combo_window -= 1
	if v.combo_timer > 0:
		v.combo_timer -= 1
		if v.combo_timer == 0:
			v.combo_count = 0
	if v.punch_buffer > 0:
		v.punch_buffer -= 1
		if v.punch_cooldown == 0 and not v.blocking:
			v.punch_buffer = 0
			start_punch(v)


static func _approach(cur: float, target: float, u: float) -> float:
	var speeding_up: bool = absf(target) > absf(cur) and (signf(target) == signf(cur) or cur == 0.0)
	return move_toward(cur, target, (World.ACCEL if speeding_up else World.DECEL) * u)


## Punch button: starts the next hit of the chain, or buffers the press while on cooldown.
static func trigger_punch(v: Variant) -> void:
	if v.ended or v.blocking or not v.running:
		return
	if v.punch_cooldown > 0:
		v.punch_buffer = World.PUNCH_BUFFER
		return
	start_punch(v)


## Starts the next punch of the 3-hit chain (punch, punch, finisher) and auto-faces the nearest foe.
static func start_punch(v: Variant) -> void:
	v.punch_step = (v.punch_step + 1) % 3 if v.combo_window > 0 else 0
	auto_face(v)
	v.punch_id += 1
	Snd.play("whoosh", 0.06)
	v.punch_active = 10
	v.punch_cooldown = int(World.COMBO_COOLDOWN[v.punch_step])
	v.combo_window = v.punch_cooldown + World.COMBO_WINDOW


## Turns the hunter toward the nearest enemy/boss within AUTO_FACE_RANGE (depth counts extra).
static func auto_face(v: Variant) -> void:
	var best := INF
	var tx := 0.0
	for e in v.enemies:
		if String(e["mode"]) == "down":
			continue
		var d: float = absf(float(e["x"]) - v.player_x) + absf(float(e["y"]) - v.player_y) * v.lane_h * 1.5
		if d < best:
			best = d
			tx = float(e["x"])
	if not v.boss.is_empty():
		var bd: float = absf(float(v.boss["x"]) - v.player_x) + absf(float(v.boss["y"]) - v.player_y) * v.lane_h * 1.5
		if bd < best:
			best = bd
			tx = float(v.boss["x"])
	if best < World.AUTO_FACE_RANGE * v.u and absf(tx - v.player_x) > 2.0:
		v.player_facing = 1 if tx > v.player_x else -1


## Hurts the hunter (knock-back away from `from_x`). At 0 hearts the first time in a run, Second Wind
## restores hearts and grants brief invulnerability; otherwise the brawl ends.
static func hurt(v: Variant, from_x: float) -> void:
	if v.player_invincible > 0 or v.ended:
		return
	v.hearts -= 1
	v.player_invincible = 55
	Snd.play("hit")
	var bd: Vector2 = v.bounds()
	v.player_x = clampf(v.player_x + (-26.0 * v.u if v.player_x < from_x else 26.0 * v.u), bd.x, bd.y)
	if v.hearts <= 0:
		if not v.second_wind_used:
			second_wind(v)
		else:
			v.end_brawl(false)


## One-time revive: +SECOND_WIND_HEARTS hearts, long invulnerability, flashy popup.
static func second_wind(v: Variant) -> void:
	v.second_wind_used = true
	v.hearts = World.SECOND_WIND_HEARTS
	v.player_invincible = World.SECOND_WIND_INVULN
	v.wind_t = World.SECOND_WIND_INVULN
	v.guard = World.GUARD_MAX
	v.guard_break_t = 0
	var at := Vector2(v.player_x, Lanes.feet_y(v, v.player_y) - 150.0 * v.u)
	Fx.popup(v, "SECOND WIND!", at, Color("#FFE9A0"), 26.0, 90)
	Fx.spark(v, at + Vector2(0.0, 60.0 * v.u), Color("#FFD36E"), true)
	v.spawn_particles(at + Vector2(0.0, 60.0 * v.u), Color("#FFE9A0"))
	v.spawn_particles(at + Vector2(0.0, 60.0 * v.u), Color("#FF9EC8"))
	v.rings.append({"pos": at + Vector2(0.0, 60.0 * v.u), "t": 0, "color": Color("#FFE9A0")})
	Snd.play("level_up")
	v.toast.show_message("Second Wind! Keep going!")
