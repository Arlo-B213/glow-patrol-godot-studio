extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Alley Brawl pickups (Story 036): defeated enemies sometimes drop a heart (restores 1) or a star
## coin (+2 score). Walk over them to collect; they drift toward the hunter when close (magnet)
## and fade away after PICKUP_LIFE ticks. Pickups live on the view as `pickups` dictionaries
## {kind, x, y (lane depth), h (height above ground px), vh, t}.

const World := preload("res://scenes/battle/brawl_world.gd")
const Lanes := preload("res://scenes/battle/brawl_lanes.gd")
const Fx := preload("res://scenes/battle/brawl_fx.gd")


## Rolls the drop for an enemy defeated at (x, depth d). `roll` is 0..1 (injectable for tests).
static func drop(v: Variant, x: float, d: float, roll: float = -1.0) -> void:
	var r: float = randf() if roll < 0.0 else roll
	var kind := ""
	if r < World.DROP_HEART:
		kind = "heart"
	elif r < World.DROP_HEART + World.DROP_COIN:
		kind = "coin"
	if kind != "":
		v.pickups.append({"kind": kind, "x": x, "y": d, "h": 0.0, "vh": 4.0, "t": 0})


## One tick: pop physics, magnet and collection.
static func update(v: Variant) -> void:
	var u: float = v.u
	for i in range(v.pickups.size() - 1, -1, -1):
		var p: Dictionary = v.pickups[i]
		p["t"] += 1
		p["vh"] = float(p["vh"]) - 0.35
		p["h"] = maxf(0.0, float(p["h"]) + float(p["vh"]) * u)
		if float(p["h"]) <= 0.0 and float(p["vh"]) < 0.0:
			p["vh"] = -float(p["vh"]) * 0.45 if float(p["vh"]) < -1.2 else 0.0
		var dx: float = v.player_x - float(p["x"])
		var dyp: float = (v.player_y - float(p["y"])) * v.lane_h
		var dist: float = sqrt(dx * dx + dyp * dyp)
		if int(p["t"]) > 14 and dist < World.MAGNET_RANGE * u and not v.ended:
			var pull: float = (1.2 + 3.2 * (1.0 - dist / (World.MAGNET_RANGE * u))) * u
			p["x"] = float(p["x"]) + dx / maxf(dist, 1.0) * minf(pull, dist)
			p["y"] = float(p["y"]) + dyp / maxf(dist, 1.0) * minf(pull, dist) / v.lane_h
		if absf(dx) < 24.0 * u and absf(dyp) < 24.0 * u and int(p["t"]) > 10 and not v.ended:
			_collect(v, p)
			v.pickups.remove_at(i)
		elif int(p["t"]) > World.PICKUP_LIFE:
			v.pickups.remove_at(i)


static func _collect(v: Variant, p: Dictionary) -> void:
	var at := Vector2(float(p["x"]), Lanes.feet_y(v, float(p["y"])) - 50.0 * v.u)
	if String(p["kind"]) == "heart":
		if v.hearts < v.BRAWL_HEARTS:
			v.hearts += 1
			Fx.popup(v, "+1 heart", at, Color("#FF7FB0"), 17.0)
		else:
			v.score += 3
			Fx.popup(v, "+3", at, Color("#FFD36E"), 17.0)
		Snd.play("eat")
	else:
		v.score += World.COIN_SCORE
		Fx.popup(v, "+%d" % World.COIN_SCORE, at, Color("#FFD36E"), 17.0)
		Snd.play("coin")
	v.spawn_particles(at, Color("#FFE9A0"))


## Draws one pickup (feet at its lane); called from the depth-sorted actor pass.
static func draw_one(v: Variant, p: Dictionary) -> void:
	var u: float = v.u * Lanes.scale_at(float(p["y"]))
	var fy: float = Lanes.feet_y(v, float(p["y"]))
	var x: float = float(p["x"])
	var left: int = World.PICKUP_LIFE - int(p["t"])
	if left < 120 and int(left / 6) % 2 == 0:
		return
	Lanes.shadow(v, x, fy, 22.0 * u, float(p["y"]), 0.8)
	var bob: float = 0.0 if v.calm() else sin(float(v.anim_t) * 0.15 + x) * 2.0 * u
	var c := Vector2(x, fy - 14.0 * u - float(p["h"]) - bob)
	if String(p["kind"]) == "heart":
		FD.circle(v, c, 15.0 * u, Color(1.0, 0.45, 0.65, 0.22))
		FD.circle(v, c + Vector2(-4.5, -3.0) * u, 5.5 * u, Color("#FF4F86"))
		FD.circle(v, c + Vector2(4.5, -3.0) * u, 5.5 * u, Color("#FF4F86"))
		FD.poly(v, PackedVector2Array([c + Vector2(-9.6, -1.0) * u, c + Vector2(9.6, -1.0) * u, c + Vector2(0.0, 10.0) * u]), Color("#FF4F86"))
		FD.circle(v, c + Vector2(-5.0, -5.0) * u, 1.8 * u, Color(1, 1, 1, 0.7))
	else:
		FD.circle(v, c, 14.0 * u, Color(1.0, 0.85, 0.35, 0.22))
		FD.circle(v, c, 9.0 * u, Color("#FFC94A"))
		FD.circle(v, c, 6.0 * u, Color("#FFE58A"))
		var pts := PackedVector2Array()
		for k in 10:
			var a: float = TAU * float(k) / 10.0 - PI * 0.5
			pts.append(c + Vector2(cos(a), sin(a)) * (4.2 if k % 2 == 0 else 1.8) * u)
		FD.poly(v, pts, Color("#FFAE2B"))
