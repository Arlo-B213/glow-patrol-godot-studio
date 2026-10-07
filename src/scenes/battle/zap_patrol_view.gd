extends Control
const FD := preload("res://scripts/fast_draw.gd")
## Zap Patrol mini-game (Story 027, Alley Brawl standard): tap the floating Gloomlings on the
## neon rooftops before they drift off-screen. The Grumble King shows up partway through and
## takes 5 hits (+15). Rules, 45 s timer and payout (GameState.payout_for) are unchanged; the
## hunter's weapon fires a glowing bolt from the rooftop at every tap and its charge orb fills
## with the combo. Emits `finished(score, earned)` exactly once; the hub saves best + points.

signal finished(score: int, earned: int)

const Kit := preload("res://scenes/games/game_kit.gd")
const ZapArt := preload("res://scenes/battle/zap_art.gd")
const HunterArt := preload("res://scripts/hunter_art.gd")
const GameStateScript := preload("res://scripts/game_state.gd")

## Tuning knobs (px values are at 480px width and scaled by `u`).
const BATTLE_TIME := 45.0
const BOSS_HEALTH := 5
const BOSS_APPEAR_AT := 20.0
const BOSS_DEFEAT_BONUS := 15
const COMBO_STEP := 5
const DEMON_COLORS := [Color("#52E8C6"), Color("#8E7CFF"), Color("#FF8B5E"), Color("#FFD36E")]

var demons: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var bolts: Array[Dictionary] = []
var ripples: Array[Dictionary] = []
var popups: Array[Dictionary] = []
var boss: Dictionary = {}
var score := 0
var combo := 0
var time_left := BATTLE_TIME
var running := true
var boss_spawned := false
## Weapon reach multiplier read once at start (GameState.weapon_reach()); widens the tap radius.
var reach := 1.0
var u := 1.0

var _clock := 0.0
var _spawn_accum := 0.0
var _boss_flash := 0.0
var _boss_age := 0
var _punch := 0.0
var _facing := 1
var _banner := ""
var _banner_t := 0.0
var _cheer := 0.0
var _shake := 0.0
var _bolt_id := 0
var _look: Dictionary = {}
var _weapon_col := UiTheme.TEAL


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var gs: Node = get_node_or_null("/root/GameState")
	if gs != null:
		reach = gs.weapon_reach()
		_look = gs.hunter_look()
	else:
		_look = {"outfit": Color("#8E7CFF"), "outfit_style": "track", "hair": Color("#2A1B4D"), "glow": Color("#52E8C6"), "hairstyle": "twintails"}
	_weapon_col = _look.get("glow", UiTheme.TEAL)
	_say("Tap the Gloomlings!")


func _say(txt: String) -> void:
	_banner = txt
	_banner_t = 2.2


func _hero_pos() -> Vector2:
	return Vector2(size.x * 0.5, ZapArt.roof_y(size, u) + 30.0 * u)


func _process(delta: float) -> void:
	if not running or size.x < 10.0:
		return
	delta = minf(delta, 0.1)
	u = clampf(size.x / 480.0, 1.0, 2.0)
	_clock += delta
	time_left -= delta
	_punch = maxf(0.0, _punch - delta)
	_boss_flash = maxf(0.0, _boss_flash - delta)
	_banner_t = maxf(0.0, _banner_t - delta)
	_cheer = maxf(0.0, _cheer - delta)
	_shake = maxf(0.0, _shake - delta * 4.0)
	_spawn(delta)
	_move_enemies(delta)
	_update_fx(delta)
	if time_left <= 0.0:
		_end()
	queue_redraw()


func _spawn(delta: float) -> void:
	_spawn_accum += delta
	var elapsed: float = BATTLE_TIME - time_left
	if _spawn_accum > maxf(0.42, 0.95 - elapsed * 0.014):
		_spawn_accum = 0.0
		debug_add_demon(-1.0)
	if not boss_spawned and elapsed >= BOSS_APPEAR_AT:
		boss_spawned = true
		boss = {"pos": Vector2(size.x * 0.5, size.y + 60.0 * u), "r": 50.0 * u, "speed": 18.0 * u, "health": BOSS_HEALTH, "wobble": randf() * TAU}
		_say("The Grumble King appears!")
		Snd.play("boss_hit", 0.02)


## Adds a demon at x (a negative x picks a random lane); also used by tests.
func debug_add_demon(x: float) -> void:
	var r: float = (20.0 + randf() * 14.0) * u
	var px: float = x if x >= 0.0 else r + randf() * maxf(1.0, size.x - 2.0 * r)
	demons.append({
		"pos": Vector2(px, size.y + r), "r": r, "speed": (33.0 + randf() * 36.0 + minf(72.0, time_left * 1.2)) * u,
		"color": DEMON_COLORS[randi() % DEMON_COLORS.size()], "wobble": randf() * TAU, "seed": randf() * 20.0, "flash": 0.0,
	})


func _move_enemies(delta: float) -> void:
	for i in range(demons.size() - 1, -1, -1):
		var d: Dictionary = demons[i]
		d["wobble"] = float(d["wobble"]) + 3.0 * delta
		var p: Vector2 = d["pos"]
		p.y -= float(d["speed"]) * delta
		p.x += sin(float(d["wobble"])) * 36.0 * u * delta
		d["pos"] = p
		if p.y < -float(d["r"]):
			demons.remove_at(i)
			combo = 0
	if boss.is_empty():
		return
	_boss_age += 1
	boss["wobble"] = float(boss["wobble"]) + 2.4 * delta
	var bp: Vector2 = boss["pos"]
	bp.y -= float(boss["speed"]) * delta
	bp.x = clampf(bp.x + sin(float(boss["wobble"])) * 24.0 * u * delta, float(boss["r"]), size.x - float(boss["r"]))
	boss["pos"] = bp
	if bp.y < -float(boss["r"]) - 30.0 * u:
		_say("The Grumble King slipped away...")
		boss = {}


func _gui_input(event: InputEvent) -> void:
	if not running:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap(event.position)


## Handles one tap at local `pos`: boss first, then the topmost demon; otherwise a gentle miss.
func tap(pos: Vector2) -> void:
	if not running:
		return
	_punch = 0.2
	var tip: Vector2 = _tip()
	_facing = 1 if pos.x >= _hero_pos().x else -1
	var hit := false
	if not boss.is_empty():
		var bd: Vector2 = pos - (boss["pos"] as Vector2)
		var br: float = boss["r"]
		if bd.length_squared() <= br * br * 1.3 * reach * reach:
			hit = true
			_hit_boss(pos)
	if not hit:
		for i in range(demons.size() - 1, -1, -1):
			var d: Dictionary = demons[i]
			var dr: float = d["r"]
			if pos.distance_squared_to(d["pos"]) <= dr * dr * 1.4 * reach * reach:
				_hit_demon(i, pos)
				hit = true
				break
	_bolt_id += 1
	bolts.append({"a": tip, "b": pos, "t": 0.0, "id": _bolt_id, "w": 2.0 + float(combo % COMBO_STEP) * 0.5, "hit": hit})
	ripples.append({"pos": pos, "t": 0.0, "hit": hit})
	if not hit:
		Snd.play("whoosh", 0.05)
		_popup(pos + Vector2(0.0, -18.0 * u), "Miss", UiTheme.TEXT_MUTED)


func _hit_demon(i: int, pos: Vector2) -> void:
	var d: Dictionary = demons[i]
	var p: Vector2 = d["pos"]
	_sparks(p, d["color"], 12)
	demons.remove_at(i)
	combo += 1
	var gain: int = 1 + combo / COMBO_STEP
	score += gain
	Snd.play("enemy_defeat", 0.08)
	_popup(p, "+%d" % gain, UiTheme.GOLD)
	if combo % COMBO_STEP == 0:
		_cheer = 1.2
		Snd.play("high_five", 0.03)
		_popup(p + Vector2(0.0, -34.0 * u), "Combo x%d!" % combo, UiTheme.TEXT)
		Kit.burst(self, global_position + p)


func _hit_boss(_pos: Vector2) -> void:
	boss["health"] = int(boss["health"]) - 1
	_boss_flash = 0.12
	_shake = 1.0
	Snd.play("boss_hit", 0.05)
	var bp: Vector2 = boss["pos"]
	_sparks(bp, Color("#7C3AED"), 10)
	if int(boss["health"]) <= 0:
		_sparks(bp, UiTheme.ACCENT, 14)
		_sparks(bp, UiTheme.GOLD, 14)
		score += BOSS_DEFEAT_BONUS
		_say("Grumble King defeated! +%d" % BOSS_DEFEAT_BONUS)
		_popup(bp, "+%d" % BOSS_DEFEAT_BONUS, UiTheme.GOLD)
		Snd.play("level_up")
		_cheer = 2.0
		Kit.burst(self, global_position + bp)
		boss = {}


func _popup(p: Vector2, txt: String, col: Color) -> void:
	popups.append({"pos": p, "text": txt, "col": col, "t": 0.0})


func _sparks(p: Vector2, col: Color, n: int) -> void:
	if Kit.calm():
		return
	for i in n:
		var a: float = randf() * TAU
		if particles.size() < 140:
			particles.append({"pos": p, "vel": Vector2(cos(a), sin(a)) * (90.0 + randf() * 150.0) * u, "t": 0.0, "color": col})


func _update_fx(delta: float) -> void:
	for pair in [[bolts, 0.18], [ripples, 0.4], [popups, 0.9]]:
		var arr: Array = pair[0]
		for i in range(arr.size() - 1, -1, -1):
			var e: Dictionary = arr[i]
			e["t"] = float(e["t"]) + delta
			if float(e["t"]) > float(pair[1]):
				arr.remove_at(i)
	for i in range(particles.size() - 1, -1, -1):
		var q: Dictionary = particles[i]
		q["t"] = float(q["t"]) + delta
		q["pos"] = (q["pos"] as Vector2) + (q["vel"] as Vector2) * delta
		q["vel"] = (q["vel"] as Vector2) + Vector2(0.0, 360.0 * u * delta)
		if float(q["t"]) > 0.55:
			particles.remove_at(i)


func _end() -> void:
	running = false
	Snd.play("win" if score > 0 else "lose")
	finished.emit(score, GameStateScript.payout_for(score))


func _tip() -> Vector2:
	var h: Vector2 = _hero_pos()
	return h + Vector2(float(_facing) * 42.0 * u, -92.0 * u)


func _draw() -> void:
	var calm: bool = Kit.calm()
	var t: float = 0.0 if calm else _clock
	var off := Vector2.ZERO if calm else Vector2(sin(_clock * 90.0), cos(_clock * 77.0)) * 4.0 * u * _shake
	Kit.draw_backdrop(self, size, "mint", t, 0.0 if calm else _clock * 10.0)
	ZapArt.signs(self, size, t, u)
	draw_set_transform(off)
	for d in demons:
		ZapArt.demon(self, d["pos"], d["r"], d["color"], t, d["seed"])
	if not boss.is_empty():
		ZapArt.boss(self, boss["pos"], boss["r"], _boss_flash > 0.0, 0 if calm else _boss_age, u)
		_draw_boss_bar()
	draw_set_transform(Vector2.ZERO)
	ZapArt.rooftop(self, size, t, u)
	_draw_hero(calm, t)
	for b in bolts:
		var k: float = 1.0 - float(b["t"]) / 0.18
		ZapArt.bolt(self, b["a"], b["b"], k, _weapon_col, float(b["w"]) * u, int(b["id"]))
	for rp in ripples:
		ZapArt.ripple(self, rp["pos"], 30.0 * u * reach, float(rp["t"]) / 0.4, _weapon_col, bool(rp["hit"]))
	for q in particles:
		FD.circle(self, q["pos"], 3.0 * u, Color(q["color"], 1.0 - float(q["t"]) * 1.8))
	_draw_popups(calm)
	_draw_hud()


func _draw_hero(calm: bool, t: float) -> void:
	var h: Vector2 = _hero_pos()
	var hs: float = 0.8 * u
	var punch_frames: int = int(_punch * 50.0)
	HunterArt.draw_hunter(self, h.x, h.y, hs, _facing, int(_clock * 60.0), false, 1.0, punch_frames, _look, -1, not calm)
	var charge: float = float(combo % COMBO_STEP) / float(COMBO_STEP)
	var tip: Vector2 = _tip()
	var pulse: float = 0.0 if calm else 0.5 + 0.5 * sin(t * 6.0)
	FD.circle(self, tip, (7.0 + charge * 12.0 + pulse * 2.0) * u, Color(_weapon_col, 0.22 + 0.25 * charge))
	FD.circle(self, tip, (3.0 + charge * 4.0) * u, Color(_weapon_col.lightened(0.4), 0.9))
	Kit.pet_cheer(self, h + Vector2(-100.0 * u, 18.0 * u), 54.0 * u, t, 0.0 if calm else _cheer)


func _draw_boss_bar() -> void:
	var bp: Vector2 = boss["pos"]
	var w: float = 130.0 * u
	var r := Rect2(bp.x - w * 0.5, maxf(8.0 * u, bp.y - float(boss["r"]) - 38.0 * u), w, 12.0 * u)
	Kit.text(self, "GRUMBLE KING", Rect2(r.position + Vector2(0.0, -16.0 * u), Vector2(w, 14.0 * u)), 12.0 * u, UiTheme.TEXT)
	draw_rect(r.grow(2.0 * u), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(r.position, Vector2(w * float(boss["health"]) / float(BOSS_HEALTH), r.size.y)), UiTheme.ACCENT)
	draw_rect(r.grow(2.0 * u), Color(1, 1, 1, 0.4), false, 1.5 * u)


func _draw_popups(calm: bool) -> void:
	for pp in popups:
		var f: float = float(pp["t"]) / 0.9
		var pos: Vector2 = pp["pos"] + Vector2(-60.0 * u, 0.0 if calm else -f * 40.0 * u)
		var col: Color = pp["col"]
		draw_string_outline(ThemeDB.fallback_font, pos, pp["text"], HORIZONTAL_ALIGNMENT_CENTER, 120.0 * u, int(20.0 * u), 5, Color(0.1, 0.03, 0.2, 1.0 - f))
		draw_string(ThemeDB.fallback_font, pos, pp["text"], HORIZONTAL_ALIGNMENT_CENTER, 120.0 * u, int(20.0 * u), Color(col, 1.0 - f))
	if _banner_t > 0.0:
		var br := Rect2(size.x * 0.5 - 150.0 * u, size.y * 0.15, 300.0 * u, 34.0 * u)
		Kit.pill(self, br, Color(UiTheme.PANEL, 0.85 * minf(1.0, _banner_t)))
		Kit.text(self, _banner, br, 16.0 * u, Color(UiTheme.TEXT, minf(1.0, _banner_t)))


func _draw_hud() -> void:
	var m: float = 12.0 * u
	var cr := Rect2(m, m, 138.0 * u, 28.0 * u)
	Kit.pill(self, cr, Color(UiTheme.ACCENT_DARK if combo >= COMBO_STEP else UiTheme.PANEL, 0.88))
	Kit.text(self, "Combo x%d" % combo, cr, 14.0 * u, UiTheme.TEXT)
	var bar := Rect2(m + 6.0 * u, m + 32.0 * u, 126.0 * u, 8.0 * u)
	draw_rect(bar, Color(0, 0, 0, 0.45))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * float(combo % COMBO_STEP) / float(COMBO_STEP), bar.size.y)), UiTheme.TEAL)
	draw_rect(bar, Color(1, 1, 1, 0.35), false, 1.5 * u)
	Kit.score_pills(self, size, u, score, "Boss!" if not boss.is_empty() else "", not boss.is_empty())
	var secs: int = maxi(0, ceili(time_left))
	Kit.timer_ring(self, Vector2(size.x * 0.5 + 10.0 * u, m + 26.0 * u), 26.0 * u, time_left / BATTLE_TIME, str(secs), secs <= 5)
