extends RefCounted
## Draws the moving things of Alley Brawl in world space (Story 025, split out of the view):
## Gloomlings, defeat puffs, the boss and its health bar, the pet, the hunter with the block
## shield and dizzy stars, hit particles and rings. `v` is the AlleyBrawlView; it is read-only
## here. Everything is offset by the camera and culled to the visible range.

const BrawlArt := preload("res://scenes/battle/brawl_art.gd")
const BrawlEnemies := preload("res://scripts/brawl_enemies.gd")
const HunterArt := preload("res://scripts/hunter_art.gd")
const HUNTER_ART_SCALE := 1.25


static func _on_screen(x: float, v: Variant, pad: float) -> bool:
	return x > v.cam_x() - pad and x < v.cam_x() + v.size.x + pad


## Draws all actors. The canvas transform is set to the camera offset for the duration.
static func draw(v: Variant) -> void:
	var u: float = v.u
	var cam: Vector2 = Vector2(-v.cam_x(), 0.0)
	v.draw_set_transform(cam)
	var calm: bool = v.calm()
	for e in v.enemies:
		if not _on_screen(float(e["x"]), v, 120.0 * u):
			continue
		var pop: float = minf(1.0, float(e["age"]) / 14.0)
		var s: float = float(e["r"]) * u * 2.1 * (0.45 + 0.55 * (pop * (2.0 - pop)))
		var toward: float = 1.0 if v.player_x > float(e["x"]) else -1.0
		var hp: float = float(e["hit_t"]) / float(v.HIT_FRAMES)
		var edx: float = absf(v.player_x - float(e["x"]))
		var still: bool = int(e["hit_t"]) > 0 or int(e.get("stun", 0)) > 0
		var fx := {
			"flash": hp, "hp": e["health"], "sq": 1.0 if calm else 1.0 - 0.22 * sin((1.0 - hp) * PI) * minf(1.0, hp * 8.0),
			"walk": 0.0 if still else 1.0, "stun": int(e.get("stun", 0)) > 0, "near": clampf(1.0 - edx / (90.0 * u), 0.0, 1.0),
			"strike": clampf((float(e["bump_cooldown"]) - 42.0) / 8.0, 0.0, 1.0),
		}
		BrawlArt.draw_enemy(v, e["type"], e["x"], v.ground_y, s, e["color"], int(e["age"]), toward, u, fx)
		if int(e.get("stun", 0)) > 0:
			_stars(v, Vector2(e["x"], v.ground_y - s * 1.4), u, calm, 0.7)

	for d in v.dying:
		var p: float = float(d["t"]) / float(v.DYING_FRAMES)
		var ds: float = float(d["r"]) * u * 2.1
		var flash_p: float = clampf(1.0 - float(d["t"]) / 5.0, 0.0, 1.0)
		var fade: float = clampf(1.0 - (float(d["t"]) - 4.0) / 12.0, 0.0, 1.0)
		var fxd := {"flash": maxf(flash_p, 0.5 * fade), "alpha": fade, "hp": 0, "dying": p, "walk": 0.0, "sq": 1.0 - 0.2 * sin(minf(p * 3.0, 1.0) * PI)}
		BrawlArt.draw_enemy(v, d["type"], d["x"], v.ground_y, ds * (1.0 - 0.3 * p), d["color"], int(d["age"]), float(d["toward"]), u, fxd)
		BrawlArt.Extra.draw_puff(v, Vector2(d["x"], v.ground_y - ds * 0.4), ds * 0.45, p, d["color"], u)

	if not v.boss.is_empty():
		_boss(v, cam, calm)
	if v.companion != null:
		v.companion.draw(v, v.ground_y, u, v.player_facing)
	_hunter(v, calm)
	for p in v.particles:
		var col: Color = p["color"]
		col.a = clampf(float(p["life"]) / 20.0, 0.0, 1.0)
		v.draw_circle(p["pos"], 3.0 * u, col)
	for r in v.rings:
		var k: float = float(r["t"]) / 14.0
		var rc: Color = r["color"]
		rc.a = 1.0 - k
		v.draw_arc(r["pos"], (10.0 + 30.0 * k) * u, 0.0, TAU, 20, rc, 3.0 * u, true)
	v.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _boss(v: Variant, cam: Vector2, calm: bool) -> void:
	var u: float = v.u
	var boss: Dictionary = v.boss
	var pop: float = minf(1.0, float(boss.get("age", 20)) / 20.0)
	var s: float = 100.0 * u * (0.5 + 0.5 * (pop * (2.0 - pop)))
	var toward: float = 1.0 if v.player_x > float(boss["x"]) else -1.0
	var bx: float = float(boss["x"]) + v.boss_recoil
	var bsq: float = 1.0
	if not calm and v.boss_hit_flash > 0:
		bsq = 1.0 - 0.14 * sin((1.0 - float(v.boss_hit_flash) / float(v.BOSS_FLASH_FRAMES)) * PI)
	v.draw_set_transform(cam + Vector2(bx, v.ground_y), 0.0, Vector2(1.0 / bsq, bsq))
	var bdx: float = absf(v.player_x - float(boss["x"]))
	var bfx := {
		"hpf": float(boss["health"]) / float(maxi(1, v.boss_max_health)), "stun": int(boss.get("stun", 0)) > 0,
		"near": clampf(1.0 - bdx / (130.0 * u), 0.0, 1.0), "strike": clampf((float(boss.get("bump_cooldown", 0)) - 46.0) / 14.0, 0.0, 1.0),
		"walk": 0.0 if int(boss.get("stun", 0)) > 0 else 1.0,
	}
	BrawlArt.draw_boss_kind(v, String(boss.get("kind", "king")), 0.0, 0.0, s, v.boss_hit_flash > 0, int(boss.get("age", 0)), toward, u, bfx)
	v.draw_set_transform(cam)
	if int(boss.get("stun", 0)) > 0:
		_stars(v, Vector2(bx, v.ground_y - s * 1.35), u, calm, 1.2)
	var bar_w := 140.0 * u
	var bar_x: float = bx - bar_w / 2.0
	var bar_y: float = v.ground_y - s * 1.45 - 24.0 * u
	v.draw_rect(Rect2(bar_x, bar_y, bar_w, 9.0 * u), Color(1.0, 1.0, 1.0, 0.15))
	v.draw_rect(Rect2(bar_x, bar_y, bar_w * (float(boss["health"]) / float(v.boss_max_health)), 9.0 * u), Color("#FF5FA2"))
	v.draw_string(ThemeDB.fallback_font, Vector2(bar_x, bar_y - 8.0 * u), String(BrawlEnemies.BOSS_NAMES[String(boss.get("kind", "king"))]), HORIZONTAL_ALIGNMENT_LEFT, bar_w, int(11.0 * u), Color("#F5EFFF"))


static func _hunter(v: Variant, calm: bool) -> void:
	var u: float = v.u
	var alpha: float = 1.0
	if v.player_invincible > 0 and int(v.player_invincible / 4) % 2 == 0:
		alpha = 0.35
	var hurt_t: int = (55 - v.player_invincible) if (v.player_invincible > 0 and v.player_invincible > 41) else -1
	HunterArt.draw_hunter(v, v.player_x, v.ground_y, u * HUNTER_ART_SCALE, v.player_facing, v.anim_t, v.walk_blend > 0.5, alpha, v.punch_active, v.look, hurt_t, true, v.walk_phase, v.walk_blend, v.block_t)
	if v.block_t > 0.05:
		var f: float = float(v.player_facing)
		var c := Vector2(v.player_x + f * 22.0 * u, v.ground_y - 74.0 * u)
		var a0: float = -1.15 if f > 0.0 else PI - 1.15
		var glow := Color("#7FF3FF")
		var pulse: float = 1.0 if calm else 0.85 + 0.15 * sin(float(v.anim_t) * 0.4)
		v.draw_arc(c, 58.0 * u, a0, a0 + 2.3, 18, Color(glow, 0.22 * v.block_t * pulse), 14.0 * u, true)
		v.draw_arc(c, 58.0 * u, a0, a0 + 2.3, 18, Color(glow, 0.95 * v.block_t), 4.0 * u, true)
		v.draw_arc(c, 52.0 * u, a0 + 0.2, a0 + 2.1, 14, Color(1, 1, 1, 0.45 * v.block_t), 2.0 * u, true)
	if v.guard_break_t > 0:
		_stars(v, Vector2(v.player_x, v.ground_y - 150.0 * u), u, calm, 1.0)


## Three small gold stars circling `c` (static when reduce motion is on).
static func _stars(v: Variant, c: Vector2, u: float, calm: bool, scale: float) -> void:
	var spin: float = 0.0 if calm else float(v.anim_t) * 0.12
	for i in 3:
		var a: float = spin + TAU * float(i) / 3.0
		var p: Vector2 = c + Vector2(cos(a) * 22.0 * u * scale, sin(a) * 6.0 * u)
		v.draw_circle(p, 6.0 * u * scale, Color("#FFD36E", 0.3))
		v.draw_circle(p, 3.2 * u * scale, Color("#FFF3B0"))
