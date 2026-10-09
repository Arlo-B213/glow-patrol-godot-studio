extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Alley Brawl boss (Story 025, lane patterns in Story 036). The boss has world x AND lane depth and
## uses well-telegraphed patterns instead of touch damage: LANE CHARGE (lines up with the hunter's
## lane, a red stripe warns, then dashes along it), GROUND SLAM (it rears up, a red ring warns, then
## a shockwave sweeps both ways across ALL lanes: block it or stay out of range) and, for the
## Hiccup Hydra, a LANE SNEEZE (a blob flies along the telegraphed lane; change lane to dodge).
## Modes: walk, tele_charge, charge, tele_slam, slam, tele_sneeze, recover. The finisher interrupts
## a telegraph. `v` is the AlleyBrawlView; the boss dictionary lives in `v.boss`.

const World := preload("res://scenes/battle/brawl_world.gd")
const Lanes := preload("res://scenes/battle/brawl_lanes.gd")
const Combat := preload("res://scenes/battle/brawl_combat.gd")
const Fx := preload("res://scenes/battle/brawl_fx.gd")

const STRIPE_HALF := 28.0
const SNEEZE_LIFE := 150


## New boss dictionary of `kind` entering at world x.
static func make(v: Variant, kind: String, x: float) -> Dictionary:
	return {"x": x, "y": 0.5, "health": v.boss_max_health, "bump_cooldown": 0, "last_hit_id": -1, "age": 0, "kind": kind,
		"stun": 0, "mode": "walk", "mt": 0, "next_t": 110, "dir": 1.0, "wave": 0.0, "done": false, "proj": []}


## True while the boss is winding up (the art shows the wind-up pose).
static func is_telegraph(b: Dictionary) -> bool:
	return String(b["mode"]).begins_with("tele_")


## One 60 Hz tick: punch hits, patterns, sneeze blobs and the hit-flash decay.
static func update(v: Variant) -> void:
	if v.boss.is_empty():
		return
	var b: Dictionary = v.boss
	b["age"] = int(b["age"]) + 1
	_punch(v, b)
	if v.boss.is_empty():
		return
	_projectiles(v, b)
	if int(b["stun"]) > 0:
		b["stun"] -= 1
	else:
		_ai(v, b)
	if int(b["bump_cooldown"]) > 0:
		b["bump_cooldown"] -= 1
	if v.boss_hit_flash > 0:
		v.boss_hit_flash -= 1
	v.boss_recoil *= 0.82


static func _punch(v: Variant, b: Dictionary) -> void:
	if v.punch_active <= 0 or int(b["last_hit_id"]) == v.punch_id:
		return
	if not Combat.in_punch_box(v, float(b["x"]), float(b["y"]), World.BOSS_REACH * v.reach, World.BOSS_DEPTH_TOL):
		return
	b["last_hit_id"] = v.punch_id
	var fin: bool = v.punch_step == 2
	b["health"] = int(b["health"]) - 1
	Snd.play("boss_hit", 0.05)
	v.boss_hit_flash = v.BOSS_FLASH_FRAMES
	v.boss_recoil = v.away(float(b["x"]), v.player_x) * (16.0 if fin else 10.0) * v.u
	var at := Vector2(float(b["x"]), Lanes.feet_y(v, float(b["y"])) - 50.0 * v.u)
	v.spawn_particles(at, Color("#7C3AED"))
	Fx.spark(v, at, Color("#FFD36E"), true)
	Fx.hit_stop(v, World.HITSTOP_BOSS)
	v.register_combo_hit(at + Vector2(0.0, -60.0 * v.u))
	if fin:
		Fx.shake_screen(v, World.SHAKE_FINISHER)
		if String(b["mode"]) != "slam":
			b["mode"] = "recover"
			b["mt"] = int(World.BOSS_RECOVER * 0.6)
	if int(b["health"]) <= 0:
		v.spawn_particles(at, Color("#FF5FA2"))
		v.score += 30
		v.boss = {}
		v.end_brawl(true)


static func _bounds(v: Variant) -> Vector2:
	var lx: float = v.world.lock_x if v.world.lock_x >= 0.0 else v.cam_x()
	return Vector2(lx + 40.0 * v.u, lx + v.size.x - 40.0 * v.u)


static func _ai(v: Variant, b: Dictionary) -> void:
	var u: float = v.u
	var px: float = v.player_x
	var dyp: float = (v.player_y - float(b["y"])) * v.lane_h
	match String(b["mode"]):
		"walk":
			var spd: float = World.BOSS_WALK_SPEED * u
			if absf(px - float(b["x"])) > 70.0 * u:
				b["x"] += clampf(px - float(b["x"]), -spd, spd)
			b["y"] = clampf(float(b["y"]) + clampf(dyp, -spd * 0.55, spd * 0.55) / v.lane_h, 0.02, 0.98)
			var on_screen: bool = float(b["x"]) < v.cam_x() + v.size.x - 60.0 * u
			if on_screen and int(b["age"]) > 50:
				b["next_t"] = int(b["next_t"]) - 1
				if int(b["next_t"]) <= 0:
					_choose(v, b)
		"tele_charge", "tele_sneeze":
			b["mt"] = int(b["mt"]) - 1
			b["dir"] = 1.0 if px > float(b["x"]) else -1.0
			var track: float = 0.6 if int(b["mt"]) > 14 else 0.0
			b["y"] = clampf(float(b["y"]) + clampf(dyp, -9.0 * u, 9.0 * u) / v.lane_h * track, 0.02, 0.98)
			if int(b["mt"]) <= 0:
				if String(b["mode"]) == "tele_charge":
					b["mode"] = "charge"
					b["mt"] = World.BOSS_CHARGE_FRAMES
					b["done"] = false
					b["bump_cooldown"] = 60
					Snd.play("whoosh")
				else:
					(b["proj"] as Array).append({"x": float(b["x"]) + float(b["dir"]) * 40.0 * u, "y": float(b["y"]), "dir": float(b["dir"]), "life": SNEEZE_LIFE})
					Snd.play("whoosh")
					b["bump_cooldown"] = 60
					b["mode"] = "recover"
					b["mt"] = 46
		"charge":
			b["x"] += float(b["dir"]) * World.BOSS_CHARGE_SPEED * u
			b["mt"] = int(b["mt"]) - 1
			if not bool(b["done"]) and absf(px - float(b["x"])) < 46.0 * u and absf(dyp) < (STRIPE_HALF + 4.0) * u:
				b["done"] = true
				var res: int = Combat.try_block(v, float(b["x"]))
				if res == 0:
					v.hurt_player(float(b["x"]))
				elif res == 2:
					b["stun"] = World.PERFECT_STUN_FRAMES
					b["mode"] = "recover"
					b["mt"] = World.BOSS_RECOVER
			var bd: Vector2 = _bounds(v)
			if float(b["x"]) < bd.x or float(b["x"]) > bd.y or int(b["mt"]) <= 0:
				b["x"] = clampf(float(b["x"]), bd.x, bd.y)
				if String(b["mode"]) == "charge":
					b["mode"] = "recover"
					b["mt"] = World.BOSS_RECOVER
		"tele_slam":
			b["mt"] = int(b["mt"]) - 1
			if int(b["mt"]) <= 0:
				b["mode"] = "slam"
				b["wave"] = 0.0
				b["done"] = false
				b["bump_cooldown"] = 60
				Snd.play("boss_hit")
				Fx.shake_screen(v, World.SHAKE_SLAM)
		"slam":
			b["wave"] = float(b["wave"]) + World.BOSS_WAVE_SPEED * u
			if not bool(b["done"]) and absf(absf(px - float(b["x"])) - float(b["wave"])) < 20.0 * u:
				b["done"] = true
				var res2: int = Combat.try_block(v, float(b["x"]))
				if res2 == 0:
					v.hurt_player(float(b["x"]))
				elif res2 == 2:
					b["stun"] = World.PERFECT_STUN_FRAMES
			if float(b["wave"]) > World.BOSS_WAVE_RANGE * u:
				b["mode"] = "recover"
				b["mt"] = World.BOSS_RECOVER
		"recover":
			b["mt"] = int(b["mt"]) - 1
			if int(b["mt"]) <= 0:
				b["mode"] = "walk"
				b["next_t"] = 80 + randi() % 60


## Picks the next pattern: slam when the hunter is close, charge (king) or sneeze (hydra) from afar.
static func _choose(v: Variant, b: Dictionary) -> void:
	var near: bool = absf(v.player_x - float(b["x"])) < 150.0 * v.u
	var r: float = randf()
	var pick := "slam"
	if String(b["kind"]) == "hydra":
		if near:
			pick = "slam" if r < 0.5 else "sneeze"
		else:
			pick = "sneeze" if r < 0.7 else ("charge" if r < 0.85 else "slam")
	elif near:
		pick = "slam" if r < 0.65 else "charge"
	else:
		pick = "charge" if r < 0.65 else "slam"
	b["dir"] = 1.0 if v.player_x > float(b["x"]) else -1.0
	match pick:
		"charge":
			b["mode"] = "tele_charge"
			b["mt"] = World.BOSS_TELE_CHARGE
		"sneeze":
			b["mode"] = "tele_sneeze"
			b["mt"] = World.BOSS_TELE_SNEEZE
		_:
			b["mode"] = "tele_slam"
			b["mt"] = World.BOSS_TELE_SLAM
	Snd.play("error")


static func _projectiles(v: Variant, b: Dictionary) -> void:
	var list: Array = b["proj"]
	for i in range(list.size() - 1, -1, -1):
		var p: Dictionary = list[i]
		p["x"] = float(p["x"]) + float(p["dir"]) * World.BOSS_SNEEZE_SPEED * v.u
		p["life"] = int(p["life"]) - 1
		var dyp: float = (v.player_y - float(p["y"])) * v.lane_h
		var hit := false
		if absf(v.player_x - float(p["x"])) < 22.0 * v.u and absf(dyp) < 26.0 * v.u and not v.ended:
			hit = true
			if Combat.try_block(v, float(p["x"])) == 0:
				v.hurt_player(float(p["x"]))
		var bd: Vector2 = _bounds(v)
		if hit or int(p["life"]) <= 0 or float(p["x"]) < bd.x - 60.0 * v.u or float(p["x"]) > bd.y + 60.0 * v.u:
			list.remove_at(i)


## Vertical lift of the boss body (px) while rearing up for the slam.
static func lift(v: Variant, b: Dictionary) -> float:
	if String(b["mode"]) == "tele_slam":
		return sin(minf(1.0, (1.0 - float(b["mt"]) / float(World.BOSS_TELE_SLAM)) * 1.4) * PI * 0.5) * 16.0 * v.u
	return 0.0


## Ground telegraphs, shockwave and sneeze blobs (drawn before the actors, camera transform set).
static func draw_floor(v: Variant) -> void:
	if v.boss.is_empty():
		return
	var b: Dictionary = v.boss
	var u: float = v.u
	var fy: float = Lanes.feet_y(v, float(b["y"]))
	var blink: float = 1.0 if v.calm() else (0.7 + 0.3 * float(int(v.anim_t / 4) % 2))
	var red := Color(1.0, 0.25, 0.3)
	match String(b["mode"]):
		"tele_charge", "tele_sneeze":
			var d: float = float(b["dir"])
			var half: float = STRIPE_HALF * u * Lanes.scale_at(float(b["y"]))
			var x0: float = float(b["x"])
			var len_px: float = v.size.x * 0.9
			var rect := Rect2(minf(x0, x0 + d * len_px), fy - half, len_px, half * 2.0)
			v.draw_rect(rect, Color(red, 0.2 * blink))
			v.draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 3.0 * u), Color(red, 0.7 * blink))
			v.draw_rect(Rect2(rect.position.x, rect.end.y - 3.0 * u, rect.size.x, 3.0 * u), Color(red, 0.7 * blink))
			for k in 6:
				var ax: float = x0 + d * (70.0 + 70.0 * float(k)) * u
				FD.poly(v, PackedVector2Array([Vector2(ax, fy - half * 0.6), Vector2(ax + d * 22.0 * u, fy), Vector2(ax, fy + half * 0.6)]), Color(1.0, 0.5, 0.4, 0.5 * blink))
		"tele_slam":
			var k2: float = 1.0 - float(b["mt"]) / float(World.BOSS_TELE_SLAM)
			var cy: float = v.lane_top + v.lane_h * 0.5
			var rx: float = World.BOSS_WAVE_RANGE * u
			FD.ellipse(v, Vector2(float(b["x"]), cy), rx, v.lane_h * 0.55, Color(red, 0.1 * blink))
			Lanes.ring(v, Vector2(float(b["x"]), cy), rx, v.lane_h * 0.55, Color(red, 0.6 * blink), 3.0 * u)
			Lanes.ring(v, Vector2(float(b["x"]), cy), rx * k2, v.lane_h * 0.55 * k2, Color(1.0, 0.8, 0.6, 0.6), 3.0 * u)
		"slam":
			var w: float = float(b["wave"])
			var fade: float = clampf(1.0 - w / (World.BOSS_WAVE_RANGE * u), 0.15, 1.0)
			for side in [-1.0, 1.0]:
				var wx: float = float(b["x"]) + float(side) * w
				v.draw_rect(Rect2(wx - 14.0 * u, v.lane_top - 14.0 * u, 28.0 * u, v.lane_h + 28.0 * u), Color(1.0, 0.75, 0.3, 0.35 * fade))
				v.draw_rect(Rect2(wx - 5.0 * u, v.lane_top - 14.0 * u, 10.0 * u, v.lane_h + 28.0 * u), Color(1.0, 0.97, 0.8, 0.9 * fade))
	for p in b["proj"]:
		var s: float = Lanes.scale_at(float(p["y"]))
		var pf: float = Lanes.feet_y(v, float(p["y"]))
		Lanes.shadow(v, float(p["x"]), pf, 26.0 * u * s, float(p["y"]))
		var c := Vector2(float(p["x"]), pf - 36.0 * u * s)
		FD.circle(v, c - Vector2(float(p["dir"]) * 16.0 * u, 0.0), 11.0 * u * s, Color(0.5, 1.0, 0.8, 0.3))
		FD.circle(v, c, 17.0 * u * s, Color(0.4, 0.95, 0.75, 0.35))
		FD.circle(v, c, 12.0 * u * s, Color("#7DFFD4"))
		FD.circle(v, c + Vector2(-3.0, -3.0) * u * s, 4.0 * u * s, Color(1, 1, 1, 0.8))
