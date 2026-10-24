extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Draws the moving things of Alley Brawl in world space (Story 025, depth lanes in Story 036):
## Gloomlings (with their wind-up "!" and knock-down), defeat puffs, the boss and its health bar, the
## pet, the hunter with the block shield, pickups, hit particles, sparks and popups. Everything is
## depth-sorted by lane (further = higher, smaller, darker shadow) with a drop shadow under each
## actor. `v` is the AlleyBrawlView; it is read-only here. Offscreen actors are culled.

const BrawlArt := preload("res://scenes/battle/brawl_art.gd")
const BrawlEnemies := preload("res://scripts/brawl_enemies.gd")
const HunterArt := preload("res://scripts/hunter_art.gd")
const Lanes := preload("res://scenes/battle/brawl_lanes.gd")
const World := preload("res://scenes/battle/brawl_world.gd")
const Boss := preload("res://scenes/battle/brawl_boss.gd")
const Pickups := preload("res://scenes/battle/brawl_pickups.gd")
const Fx := preload("res://scenes/battle/brawl_fx.gd")
const HUNTER_ART_SCALE := 1.25

const K_ENEMY := 0
const K_DYING := 1
const K_BOSS := 2
const K_PET := 3
const K_HUNTER := 4
const K_PICKUP := 5


static func _on_screen(x: float, v: Variant, pad: float) -> bool:
	return x > v.cam_x() - pad and x < v.cam_x() + v.size.x + pad


## Draws all actors. The canvas transform is set to the camera offset (plus screen shake).
static func draw(v: Variant) -> void:
	var u: float = v.u
	var cam: Vector2 = Vector2(-v.cam_x(), 0.0) + v.shake_off
	v.draw_set_transform(cam)
	var calm: bool = v.calm()
	Boss.draw_floor(v)
	var items: Array = []
	for i in v.enemies.size():
		var e: Dictionary = v.enemies[i]
		if _on_screen(float(e["x"]), v, 120.0 * u):
			items.append([Lanes.feet_y(v, float(e["y"])), K_ENEMY, i])
	for i in v.dying.size():
		var d: Dictionary = v.dying[i]
		if _on_screen(float(d["x"]), v, 120.0 * u):
			items.append([Lanes.feet_y(v, float(d["y"])), K_DYING, i])
	for i in v.pickups.size():
		var p: Dictionary = v.pickups[i]
		if _on_screen(float(p["x"]), v, 40.0 * u):
			items.append([Lanes.feet_y(v, float(p["y"])), K_PICKUP, i])
	if not v.boss.is_empty():
		items.append([Lanes.feet_y(v, float(v.boss["y"])), K_BOSS, 0])
	if v.companion != null:
		items.append([Lanes.feet_y(v, v.companion.d), K_PET, 0])
	items.append([Lanes.feet_y(v, v.player_y) + 0.01, K_HUNTER, 0])
	items.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	for it in items:
		match int(it[1]):
			K_ENEMY: _enemy(v, v.enemies[int(it[2])], cam, calm)
			K_DYING: _dying(v, v.dying[int(it[2])])
			K_PICKUP: Pickups.draw_one(v, v.pickups[int(it[2])])
			K_BOSS: _boss(v, cam, calm)
			K_PET:
				var pd: float = v.companion.d
				var psc: float = Lanes.scale_at(pd)
				Lanes.shadow(v, v.companion.x, Lanes.feet_y(v, pd), 44.0 * u * psc, pd)
				v.companion.draw(v, Lanes.feet_y(v, pd), u * psc, v.player_facing, cam)
			_: _hunter(v, calm)
	for p in v.particles:
		var col: Color = p["color"]
		col.a = clampf(float(p["life"]) / 20.0, 0.0, 1.0)
		FD.circle(v, p["pos"], 3.0 * u, col)
	for r in v.rings:
		var k: float = float(r["t"]) / 14.0
		var rc: Color = r["color"]
		rc.a = 1.0 - k
		FD.arc(v, r["pos"], (10.0 + 30.0 * k) * u, 0.0, TAU, 20, rc, 3.0 * u, true)
	Fx.draw(v)
	v.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _enemy(v: Variant, e: Dictionary, cam: Vector2, calm: bool) -> void:
	var u: float = v.u
	var sc: float = Lanes.scale_at(float(e["y"]))
	var fy: float = Lanes.feet_y(v, float(e["y"]))
	var pop: float = minf(1.0, float(e["age"]) / 14.0)
	var s: float = float(e["r"]) * u * 2.1 * sc * (0.45 + 0.55 * (pop * (2.0 - pop)))
	var toward: float = 1.0 if v.player_x > float(e["x"]) else -1.0
	var hp: float = float(e["hit_t"]) / float(v.HIT_FRAMES)
	var edx: float = absf(v.player_x - float(e["x"]))
	var mode: String = String(e["mode"])
	var still: bool = int(e["hit_t"]) > 0 or int(e["stun"]) > 0 or mode != "move"
	var winding: bool = mode == "windup"
	var flash: float = hp
	if winding:
		var pulse: float = 0.5 if calm else 0.5 + 0.5 * sin(float(e["mt"]) * 1.1)
		flash = maxf(flash, 0.2 + 0.4 * pulse * (1.0 - float(e["mt"]) / float(maxi(1, int(e["mt0"])))))
	var fx := {
		"flash": flash, "hp": e["health"], "sq": 1.0 if calm else 1.0 - 0.22 * sin((1.0 - hp) * PI) * minf(1.0, hp * 8.0),
		"walk": 0.0 if still else 1.0, "stun": int(e["stun"]) > 0, "near": 1.0 if winding or mode == "strike" else clampf(1.0 - edx / (90.0 * u), 0.0, 1.0),
		"strike": clampf((float(e["bump_cooldown"]) - 42.0) / 8.0, 0.0, 1.0),
	}
	Lanes.shadow(v, float(e["x"]), fy, s * 0.85, float(e["y"]), 1.0 if mode != "down" else 1.3)
	if mode == "down":
		var el: int = World.DOWN_FRAMES - int(e["mt"])
		var kk: float = 1.0
		if el < World.DOWN_FALL:
			kk = float(el) / float(World.DOWN_FALL)
		elif int(e["mt"]) < World.DOWN_GETUP:
			kk = float(e["mt"]) / float(World.DOWN_GETUP)
		fx["walk"] = 0.0
		fx["flash"] = maxf(flash, 0.25 * kk)
		v.draw_set_transform(cam + Vector2(float(e["x"]), fy), float(e.get("kd", 1.0)) * 1.45 * kk, Vector2.ONE)
		BrawlArt.draw_enemy(v, e["type"], 0.0, 0.0, s, e["color"], int(e["age"]), toward, u, fx)
		v.draw_set_transform(cam)
		return
	BrawlArt.draw_enemy(v, e["type"], e["x"], fy, s, e["color"], int(e["age"]), toward, u, fx)
	if int(e["stun"]) > 0:
		_stars(v, Vector2(e["x"], fy - s * 1.4), u, calm, 0.7)
	if winding:
		_alert(v, Vector2(float(e["x"]), fy - s * 1.55), u * sc)


## Red "!" bubble that warns of an incoming enemy strike.
static func _alert(v: Variant, c: Vector2, u: float) -> void:
	FD.circle(v, c, 11.0 * u, Color(1.0, 0.2, 0.28, 0.95))
	FD.circle(v, c, 11.0 * u, Color(1, 1, 1, 0.9), false, 2.0 * u)
	v.draw_rect(Rect2(c.x - 1.8 * u, c.y - 6.5 * u, 3.6 * u, 8.0 * u), Color.WHITE)
	v.draw_rect(Rect2(c.x - 1.8 * u, c.y + 3.5 * u, 3.6 * u, 3.4 * u), Color.WHITE)


static func _dying(v: Variant, d: Dictionary) -> void:
	var u: float = v.u
	var fy: float = Lanes.feet_y(v, float(d["y"]))
	var ds: float = float(d["r"]) * u * 2.1 * Lanes.scale_at(float(d["y"]))
	var p: float = float(d["t"]) / float(v.DYING_FRAMES)
	var flash_p: float = clampf(1.0 - float(d["t"]) / 5.0, 0.0, 1.0)
	var fade: float = clampf(1.0 - (float(d["t"]) - 4.0) / 12.0, 0.0, 1.0)
	var fxd := {"flash": maxf(flash_p, 0.5 * fade), "alpha": fade, "hp": 0, "dying": p, "walk": 0.0, "sq": 1.0 - 0.2 * sin(minf(p * 3.0, 1.0) * PI)}
	Lanes.shadow(v, float(d["x"]), fy, ds * 0.85, float(d["y"]), fade)
	BrawlArt.draw_enemy(v, d["type"], d["x"], fy, ds * (1.0 - 0.3 * p), d["color"], int(d["age"]), float(d["toward"]), u, fxd)
	BrawlArt.Extra.draw_puff(v, Vector2(d["x"], fy - ds * 0.4), ds * 0.45, p, d["color"], u)


static func _boss(v: Variant, cam: Vector2, calm: bool) -> void:
	var u: float = v.u
	var boss: Dictionary = v.boss
	var sc: float = Lanes.scale_at(float(boss["y"]))
	var fy: float = Lanes.feet_y(v, float(boss["y"]))
	var pop: float = minf(1.0, float(boss.get("age", 20)) / 20.0)
	var s: float = 100.0 * u * sc * (0.5 + 0.5 * (pop * (2.0 - pop)))
	var toward: float = 1.0 if v.player_x > float(boss["x"]) else -1.0
	var bx: float = float(boss["x"]) + v.boss_recoil
	var bsq: float = 1.0
	if not calm and v.boss_hit_flash > 0:
		bsq = 1.0 - 0.14 * sin((1.0 - float(v.boss_hit_flash) / float(v.BOSS_FLASH_FRAMES)) * PI)
	Lanes.shadow(v, bx, fy, s * 0.95, float(boss["y"]))
	var tele: bool = Boss.is_telegraph(boss)
	var mode: String = String(boss["mode"])
	v.draw_set_transform(cam + Vector2(bx, fy - Boss.lift(v, boss)), 0.0, Vector2(1.0 / bsq, bsq))
	var bdx: float = absf(v.player_x - float(boss["x"]))
	var bfx := {
		"hpf": float(boss["health"]) / float(maxi(1, v.boss_max_health)), "stun": int(boss["stun"]) > 0,
		"near": 1.0 if tele else clampf(1.0 - bdx / (130.0 * u), 0.0, 1.0),
		"strike": 1.0 if (mode == "charge" or mode == "slam") else clampf((float(boss["bump_cooldown"]) - 46.0) / 14.0, 0.0, 1.0),
		"walk": 0.0 if (int(boss["stun"]) > 0 or mode == "recover" or tele) else 1.0,
	}
	if tele and not calm and int(v.anim_t / 3) % 2 == 0:
		bfx["flash"] = 0.3
	BrawlArt.draw_boss_kind(v, String(boss.get("kind", "king")), 0.0, 0.0, s, v.boss_hit_flash > 0, int(boss.get("age", 0)), toward, u, bfx)
	v.draw_set_transform(cam)
	if int(boss["stun"]) > 0 or mode == "recover":
		_stars(v, Vector2(bx, fy - s * 1.35), u, calm, 1.2)
	if tele:
		_alert(v, Vector2(bx, fy - s * 1.55), u * 1.4)
	var bar_w := 140.0 * u
	var bar_x: float = bx - bar_w / 2.0
	var bar_y: float = fy - s * 1.45 - 24.0 * u
	v.draw_rect(Rect2(bar_x, bar_y, bar_w, 9.0 * u), Color(1.0, 1.0, 1.0, 0.15))
	v.draw_rect(Rect2(bar_x, bar_y, bar_w * (float(boss["health"]) / float(v.boss_max_health)), 9.0 * u), Color("#FF5FA2"))
	v.draw_string(ThemeDB.fallback_font, Vector2(bar_x, bar_y - 8.0 * u), String(BrawlEnemies.BOSS_NAMES[String(boss.get("kind", "king"))]), HORIZONTAL_ALIGNMENT_LEFT, bar_w, int(11.0 * u), Color("#F5EFFF"))


static func _hunter(v: Variant, calm: bool) -> void:
	var u: float = v.u
	var sc: float = Lanes.scale_at(v.player_y)
	var fy: float = Lanes.feet_y(v, v.player_y)
	var alpha: float = 1.0
	if v.player_invincible > 0 and int(v.player_invincible / 4) % 2 == 0:
		alpha = 0.35
	var hurt_t: int = (55 - v.player_invincible) if (v.player_invincible > 0 and v.player_invincible > 41 and v.player_invincible < 56) else -1
	Lanes.shadow(v, v.player_x, fy, 52.0 * u * sc, v.player_y)
	HunterArt.draw_hunter(v, v.player_x, fy, u * HUNTER_ART_SCALE * sc, v.player_facing, v.anim_t, v.walk_blend > 0.5, alpha, v.punch_active, v.look, hurt_t, true, v.walk_phase, v.walk_blend, v.block_t)
	if v.block_t > 0.05:
		var f: float = float(v.player_facing)
		var c := Vector2(v.player_x + f * 22.0 * u * sc, fy - 74.0 * u * sc)
		var a0: float = -1.15 if f > 0.0 else PI - 1.15
		var glow := Color("#7FF3FF")
		var pulse: float = 1.0 if calm else 0.85 + 0.15 * sin(float(v.anim_t) * 0.4)
		FD.arc(v, c, 58.0 * u * sc, a0, a0 + 2.3, 18, Color(glow, 0.22 * v.block_t * pulse), 14.0 * u, true)
		FD.arc(v, c, 58.0 * u * sc, a0, a0 + 2.3, 18, Color(glow, 0.95 * v.block_t), 4.0 * u, true)
		FD.arc(v, c, 52.0 * u * sc, a0 + 0.2, a0 + 2.1, 14, Color(1, 1, 1, 0.45 * v.block_t), 2.0 * u, true)
	if v.guard_break_t > 0:
		_stars(v, Vector2(v.player_x, fy - 150.0 * u * sc), u, calm, 1.0)
	if v.wind_t > 0:
		var k: float = float(v.wind_t) / float(World.SECOND_WIND_INVULN)
		FD.circle(v, Vector2(v.player_x, fy - 60.0 * u * sc), (70.0 + 30.0 * (1.0 - k)) * u * sc, Color(1.0, 0.9, 0.5, 0.28 * minf(1.0, k * 3.0)))


## Three small gold stars circling `c` (static when reduce motion is on).
static func _stars(v: Variant, c: Vector2, u: float, calm: bool, scale: float) -> void:
	var spin: float = 0.0 if calm else float(v.anim_t) * 0.12
	for i in 3:
		var a: float = spin + TAU * float(i) / 3.0
		var p: Vector2 = c + Vector2(cos(a) * 22.0 * u * scale, sin(a) * 6.0 * u)
		FD.circle(v, p, 6.0 * u * scale, Color("#FFD36E", 0.3))
		FD.circle(v, p, 3.2 * u * scale, Color("#FFF3B0"))
