extends RefCounted
## Alley Brawl enemy AI (Story 036), one call per enemy per 60 Hz tick. Enemies move in x AND lane
## depth. Only MAX_ATTACKERS of them "go for" the hunter at a time (the nearest ready ones, see
## `assign_attackers`); the rest circle at a distance and shuffle between lanes. An attacker must
## line up in depth, then telegraphs (`windup`, flashing + "!") for ~0.4 s, strikes, and rests
## (`bump_cooldown`). Modes: move, windup, strike, down (knocked down, then gets up).
## Personality: gloomling shuffles straight in; blinker hops and picks a new lane on each hop;
## mossback is slow, wide and slow to wind up. Pure movement/state; damage goes through Combat.

const World := preload("res://scenes/battle/brawl_world.gd")
const Combat := preload("res://scenes/battle/brawl_combat.gd")
const BlinkerArt := preload("res://scenes/battle/brawl_art_enemies.gd")


## Marks the nearest ready enemies as `eager` so that at most MAX_ATTACKERS act at once.
static func assign_attackers(v: Variant) -> void:
	var busy := 0
	for e in v.enemies:
		e["eager"] = false
		var m: String = String(e["mode"])
		if m == "windup" or m == "strike":
			e["eager"] = true
			busy += 1
	for n in World.MAX_ATTACKERS - busy:
		var best: Dictionary = {}
		var best_d := INF
		for e in v.enemies:
			if bool(e["eager"]) or String(e["mode"]) != "move" or int(e["bump_cooldown"]) > 0:
				continue
			var d: float = absf(float(e["x"]) - v.player_x) + absf(float(e["y"]) - v.player_y) * v.lane_h * 1.5
			if d < best_d:
				best_d = d
				best = e
		if not best.is_empty():
			best["eager"] = true


## Advances enemy `e` one tick (movement, mode timers, starting and resolving its bump).
static func step(v: Variant, e: Dictionary) -> void:
	e["age"] += 1
	if int(e["bump_cooldown"]) > 0:
		e["bump_cooldown"] -= 1
	var u: float = v.u
	var stunned: bool = int(e["stun"]) > 0
	if stunned:
		e["stun"] -= 1
	e["x"] += float(e["kb"])
	e["kb"] = float(e["kb"]) * 0.8
	var mode: String = String(e["mode"])
	if mode == "down":
		e["mt"] -= 1
		if int(e["mt"]) <= 0:
			e["mode"] = "move"
			e["bump_cooldown"] = maxi(int(e["bump_cooldown"]), 30)
		return
	if int(e["hit_t"]) > 0:
		e["hit_t"] -= 1
		if mode != "move":
			e["mode"] = "move"
			e["bump_cooldown"] = maxi(int(e["bump_cooldown"]), 28)
		return
	if stunned:
		return
	var dx: float = v.player_x - float(e["x"])
	var dyp: float = (v.player_y - float(e["y"])) * v.lane_h
	e["side"] = -1.0 if dx > 0.0 else 1.0
	if mode == "windup":
		e["mt"] -= 1
		if int(e["mt"]) <= 0:
			e["mode"] = "strike"
			e["mt"] = World.ENEMY_STRIKE
			e["bump_cooldown"] = World.ENEMY_RECOVER
			var reach: float = (float(e["range"]) + 8.0) * u
			if absf(dx) < reach and absf(dyp) < (float(e["tol"]) + 4.0) * u:
				Combat.enemy_bump(v, e)
			e["kb"] = signf(dx) * 3.0 * u
		return
	if mode == "strike":
		e["mt"] -= 1
		if int(e["mt"]) <= 0:
			e["mode"] = "move"
		return
	_move(v, e, dx, dyp)
	dx = v.player_x - float(e["x"])
	dyp = (v.player_y - float(e["y"])) * v.lane_h
	if bool(e["eager"]) and int(e["bump_cooldown"]) <= 0 and absf(dx) < float(e["range"]) * u and absf(dyp) < float(e["tol"]) * u and not v.ended:
		e["mode"] = "windup"
		e["mt"] = int(e["windup"])
		e["mt0"] = int(e["windup"])


static func _move(v: Variant, e: Dictionary, dx: float, dyp: float) -> void:
	var u: float = v.u
	var spd: float = float(e["speed"]) * u
	var typ: String = String(e["type"])
	var tx: float = v.player_x
	var td: float = v.player_y
	if not bool(e["eager"]):
		# Wait/circle: hover at a distance on our own side, lazily changing lane.
		e["oy_t"] -= 1
		if int(e["oy_t"]) <= 0:
			e["oy_t"] = 70 + randi() % 80
			e["oy"] = clampf(v.player_y + randf_range(-0.45, 0.45), 0.02, 0.98)
		tx = v.player_x + float(e["side"]) * float(e["ox"]) * u
		td = float(e["oy"])
		spd *= 0.7
	if typ == "blinker":
		var air: bool = BlinkerArt.blinker_airborne(int(e["age"]))
		if air and not bool(e["air"]):
			e["lane"] = clampf(td + (randf_range(-0.3, 0.3) if randf() < 0.4 else 0.0), 0.02, 0.98)
		e["air"] = air
		td = float(e["lane"])
		spd *= 1.64 if air else 0.0
	var stop: float = 6.0 * u if not bool(e["eager"]) else 10.0 * u
	var mx: float = clampf(tx - float(e["x"]), -spd, spd)
	if absf(tx - float(e["x"])) < stop:
		mx = 0.0
	e["x"] += mx
	var sy: float = spd * World.ENEMY_DEPTH_MULT * float(e["depth"])
	var my: float = clampf((td - float(e["y"])) * v.lane_h, -sy, sy)
	if absf((td - float(e["y"])) * v.lane_h) < 4.0 * u:
		my = 0.0
	e["y"] = clampf(float(e["y"]) + my / v.lane_h, 0.0, 1.0)
	# Soft separation so enemies do not stack on one spot.
	for o in v.enemies:
		if o == e:
			continue
		var ox: float = float(e["x"]) - float(o["x"])
		if absf(ox) < 22.0 * u and absf(float(e["y"]) - float(o["y"])) * v.lane_h < 14.0 * u:
			e["x"] += (1.0 if ox >= 0.0 else -1.0) * 0.6 * u
			e["y"] = clampf(float(e["y"]) + (0.004 if float(e["y"]) >= float(o["y"]) else -0.004), 0.0, 1.0)
