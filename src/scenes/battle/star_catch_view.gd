extends Control
const FD := preload("res://scripts/fast_draw.gd")
## Star Catch mini-game (Story 027, Alley Brawl standard): the hunter (with their pet beside
## them) holds a lantern basket and catches falling stars on a dusk sky. Golden stars make every
## catch count double for a few seconds, magnet stars pull stars in, Gloomlings cost 3 points and
## break the combo. Drag anywhere (the hero eases toward the finger), hold the round buttons, or
## use A/D / arrows. Rules, 40 s timer and payout (GameState.payout_for) are unchanged.
## Emits `finished(score, earned)` exactly once; the hub saves best score and points.

signal finished(score: int, earned: int)

const Kit := preload("res://scenes/games/game_kit.gd")
const CatchInputScript := preload("res://scenes/battle/catch_input.gd")
const CatchArt := preload("res://scenes/battle/catch_art.gd")
const GameStateScript := preload("res://scripts/game_state.gd")

## Tuning knobs (all px values are at 480px width and scaled by `u`).
const CATCH_TIME := 40.0
const GOLDEN_TIME := 6.0
const MAGNET_TIME := 5.0
const GLOOM_PENALTY := 3
const HERO_ACCEL := 2400.0
const HERO_MAX_SPEED := 520.0
const HERO_FOLLOW_GAIN := 9.0
const MAGNET_RANGE := 230.0
const COMBO_STEP := 5
const NEAR_MISS := 78.0
const MAX_PARTICLES := 140
const ITEM_COLORS := [Color("#52E8C6"), Color("#8E7CFF"), Color("#FF8B5E"), Color("#FFD36E")]

var items: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var popups: Array[Dictionary] = []
var score := 0
var combo := 0
var best_combo := 0
var time_left := CATCH_TIME
var running := true
var golden_t := 0.0
var magnet_t := 0.0

var hx := -1.0
var hv := 0.0
var facing := 1
var u := 1.0

var _clock := 0.0
var _spawn_accum := 0.0
var _hurt_t := -1.0
var _glow := 0.0
var _cheer := 0.0
var _flash := 0.0
var _pet_x := -1.0
var _look: Dictionary = {}
var _ctl: Control = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var gs: Node = get_node_or_null("/root/GameState")
	_look = gs.hunter_look() if gs != null else {"outfit": Color("#8E7CFF"), "outfit_style": "track", "hair": Color("#2A1B4D"), "glow": Color("#52E8C6"), "hairstyle": "twintails"}
	_ctl = CatchInputScript.new()
	add_child(_ctl)


func _geo() -> Dictionary:
	u = clampf(size.x / 480.0, 1.0, 2.0)
	var hs: float = 0.8 * u
	var gy: float = size.y - 150.0 * u
	return {"hs": hs, "ground": gy, "basket_y": gy - CatchArt.BASKET_UP * hs, "half": 36.0 * hs}


func _process(delta: float) -> void:
	if not running or size.x < 10.0:
		return
	delta = minf(delta, 0.1)
	var g: Dictionary = _geo()
	_clock += delta
	if hx < 0.0:
		hx = size.x * 0.5
		_pet_x = hx - 90.0 * u
	_move_hero(delta)
	_tick_timers(delta)
	_spawn(delta)
	_update_items(delta, g)
	_update_fx(delta)
	if time_left <= 0.0:
		_end()
	queue_redraw()
	_ctl.queue_redraw()


func _move_hero(delta: float) -> void:
	var axis: float = _ctl.read_axis()
	var want := 0.0
	var tx: float = _ctl.drag_target()
	if axis != 0.0:
		want = axis * HERO_MAX_SPEED * u
	elif tx >= 0.0:
		want = clampf((tx - hx) * HERO_FOLLOW_GAIN, -HERO_MAX_SPEED * u, HERO_MAX_SPEED * u)
	hv = move_toward(hv, want, HERO_ACCEL * u * delta * (1.0 if want != 0.0 else 1.3))
	hx += hv * delta
	var margin: float = 34.0 * u
	if hx < margin or hx > size.x - margin:
		hx = clampf(hx, margin, size.x - margin)
		hv = 0.0
	if absf(hv) > 20.0:
		facing = 1 if hv > 0.0 else -1
	_pet_x = lerpf(_pet_x, clampf(hx - float(facing) * 84.0 * u, 30.0 * u, size.x - 30.0 * u), minf(1.0, 3.0 * delta))


func _tick_timers(delta: float) -> void:
	time_left -= delta
	golden_t = maxf(0.0, golden_t - delta)
	magnet_t = maxf(0.0, magnet_t - delta)
	_glow = maxf(0.0, _glow - delta * 3.0)
	_cheer = maxf(0.0, _cheer - delta)
	_flash = maxf(0.0, _flash - delta * 3.0)
	if _hurt_t >= 0.0:
		_hurt_t += delta
		if _hurt_t > 0.3:
			_hurt_t = -1.0


func _spawn(delta: float) -> void:
	_spawn_accum += delta
	var elapsed: float = CATCH_TIME - time_left
	var interval: float = maxf(0.36, 0.78 - elapsed * 0.01)
	if _spawn_accum < interval:
		return
	_spawn_accum = 0.0
	var roll: float = randf()
	var kind := "star"
	if roll < 0.06 and elapsed > 4.0:
		kind = "golden"
	elif roll < 0.10 and elapsed > 8.0 and magnet_t <= 0.0:
		kind = "magnet"
	elif roll > 0.72:
		kind = "gloom"
	var r: float = (22.0 if kind == "gloom" else 14.0) * u
	var spd: float = (84.0 + randf() * 72.0 + minf(96.0, elapsed * 4.8)) * u
	debug_add_item(kind, Vector2(r + randf() * maxf(1.0, size.x - 2.0 * r), -r), spd)


## Adds one falling item (also used by tests). `kind`: star, golden, magnet or gloom.
func debug_add_item(kind: String, pos: Vector2, spd: float = 120.0) -> void:
	items.append({
		"pos": pos, "prev": pos.y, "kind": kind, "r": (22.0 if kind == "gloom" else 14.0) * u, "speed": spd,
		"color": ITEM_COLORS[randi() % ITEM_COLORS.size()], "rot": randf() * TAU, "age": randi() % 100, "passed": false,
	})


func _update_items(delta: float, g: Dictionary) -> void:
	var by: float = g["basket_y"]
	var half: float = g["half"]
	for i in range(items.size() - 1, -1, -1):
		var it: Dictionary = items[i]
		var p: Vector2 = it["pos"]
		it["prev"] = p.y
		p.y += float(it["speed"]) * delta
		it["rot"] = float(it["rot"]) + delta * 2.0
		it["age"] = int(it["age"]) + 1
		var kind: String = it["kind"]
		if magnet_t > 0.0 and kind == "star" and p.y > 0.0 and absf(p.x - hx) < MAGNET_RANGE * u and p.y < by:
			p.x += (hx - p.x) * minf(1.0, 4.0 * delta)
		it["pos"] = p
		var r: float = it["r"]
		var dx: float = absf(p.x - hx)
		if not it["passed"] and p.y >= by - 14.0 * u and float(it["prev"]) < by + 14.0 * u and dx < half + r * 0.5:
			_catch(it)
			items.remove_at(i)
			continue
		if not it["passed"] and p.y > by + 14.0 * u:
			it["passed"] = true
			_missed(it, dx, half)
		if p.y - r > float(g["ground"]):
			items.remove_at(i)


func _catch(it: Dictionary) -> void:
	var p: Vector2 = it["pos"]
	match String(it["kind"]):
		"gloom":
			combo = 0
			score = maxi(0, score - GLOOM_PENALTY)
			_hurt_t = 0.0
			_flash = 1.0
			Snd.play("hit", 0.05)
			_popup(p, "-%d" % GLOOM_PENALTY, UiTheme.ACCENT)
			_sparks(p, Color("#8E7CFF"), 10)
		"magnet":
			magnet_t = MAGNET_TIME
			_glow = 1.0
			Snd.play("coin", 0.03)
			_popup(p, "Magnet!", UiTheme.TEAL)
			_sparks(p, UiTheme.TEAL, 10)
		_:
			if it["kind"] == "golden":
				golden_t = GOLDEN_TIME
				Snd.play("coin", 0.03)
				_popup(p + Vector2(0.0, -26.0 * u), "Golden x2!", UiTheme.GOLD)
			combo += 1
			best_combo = maxi(best_combo, combo)
			var gain: int = (1 + combo / COMBO_STEP) * (2 if golden_t > 0.0 else 1)
			score += gain
			_glow = 1.0
			Snd.play("star", 0.06)
			_popup(p, "+%d" % gain, UiTheme.GOLD)
			_sparks(p, CatchArt.STAR_COL, 8)
			if combo % COMBO_STEP == 0:
				_cheer = 1.2
				Snd.play("high_five", 0.03)
				_popup(Vector2(hx, p.y - 40.0 * u), "Combo x%d!" % combo, UiTheme.TEXT)
				Kit.burst(self, global_position + Vector2(hx, p.y))


func _missed(it: Dictionary, dx: float, half: float) -> void:
	var kind: String = it["kind"]
	if kind == "gloom":
		if dx < half + NEAR_MISS * u:
			Snd.play("whoosh", 0.05)
			_popup(it["pos"], "Phew!", UiTheme.TEAL)
		return
	if kind != "magnet":
		combo = 0
	if dx < half + NEAR_MISS * u:
		_popup(it["pos"], "So close!", UiTheme.TEXT_MUTED)


func _popup(p: Vector2, txt: String, col: Color) -> void:
	popups.append({"pos": p, "text": txt, "col": col, "t": 0.0})


func _sparks(p: Vector2, col: Color, n: int) -> void:
	if Kit.calm():
		return
	for i in n:
		var a: float = randf() * TAU
		var sp: float = (80.0 + randf() * 120.0) * u
		if particles.size() < MAX_PARTICLES:
			particles.append({"pos": p, "vel": Vector2(cos(a), sin(a)) * sp, "t": 0.0, "color": col})


func _update_fx(delta: float) -> void:
	for i in range(particles.size() - 1, -1, -1):
		var q: Dictionary = particles[i]
		q["t"] = float(q["t"]) + delta
		q["pos"] = (q["pos"] as Vector2) + (q["vel"] as Vector2) * delta
		q["vel"] = (q["vel"] as Vector2) + Vector2(0.0, 380.0 * u * delta)
		if float(q["t"]) > 0.5:
			particles.remove_at(i)
	for i in range(popups.size() - 1, -1, -1):
		popups[i]["t"] = float(popups[i]["t"]) + delta
		if float(popups[i]["t"]) > 0.9:
			popups.remove_at(i)


func _end() -> void:
	running = false
	_ctl.active = false
	Snd.play("win" if score > 0 else "lose")
	finished.emit(score, GameStateScript.payout_for(score))


func _draw() -> void:
	var calm: bool = Kit.calm()
	var t: float = 0.0 if calm else _clock
	Kit.draw_backdrop(self, size, "dusk", t, 0.0 if calm else _clock * 6.0)
	if not calm:
		CatchArt.ambient(self, size, t)
	var g: Dictionary = _geo()
	var gy: float = g["ground"]
	CatchArt.ground(self, size, gy, t, u)
	for it in items:
		_draw_item(it, t)
	var hurt: int = int(_hurt_t * 60.0) if _hurt_t >= 0.0 else -1
	CatchArt.hero(self, maxf(hx, 0.0), gy, g["hs"], _look, facing, int(_clock * 60.0), absf(hv) > 25.0 * u, hurt, _glow, calm)
	Kit.pet_cheer(self, Vector2(_pet_x, gy + 6.0 * u), 54.0 * u, t, 0.0 if calm else _cheer)
	for q in particles:
		FD.circle(self, q["pos"], 3.0 * u, Color(q["color"], 1.0 - float(q["t"]) * 2.0))
	for pp in popups:
		var f: float = float(pp["t"]) / 0.9
		var pos: Vector2 = pp["pos"] + Vector2(-60.0 * u, (0.0 if calm else -f * 40.0 * u))
		var col: Color = pp["col"]
		draw_string_outline(ThemeDB.fallback_font, pos, pp["text"], HORIZONTAL_ALIGNMENT_CENTER, 120.0 * u, int(20.0 * u), 5, Color(0.1, 0.03, 0.2, 1.0 - f))
		draw_string(ThemeDB.fallback_font, pos, pp["text"], HORIZONTAL_ALIGNMENT_CENTER, 120.0 * u, int(20.0 * u), Color(col, 1.0 - f))
	if _flash > 0.0 and not calm:
		draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 0.37, 0.635, 0.16 * _flash))
	_draw_hud(calm)


func _draw_item(it: Dictionary, t: float) -> void:
	var p: Vector2 = it["pos"]
	var r: float = it["r"]
	match String(it["kind"]):
		"gloom":
			CatchArt.gloomling(self, p, r, it["color"], it["age"], u)
		"magnet":
			CatchArt.trail(self, p, r, UiTheme.TEAL, it["speed"])
			CatchArt.magnet(self, p, r, t)
		"golden":
			CatchArt.trail(self, p, r, CatchArt.GOLD, it["speed"])
			CatchArt.star(self, p, r * 1.3, CatchArt.GOLD, it["rot"] if t > 0.0 else 0.0, true)
		_:
			CatchArt.trail(self, p, r, CatchArt.STAR_COL, it["speed"])
			CatchArt.star(self, p, r, CatchArt.STAR_COL, it["rot"] if t > 0.0 else 0.0)


func _draw_hud(calm: bool) -> void:
	var m: float = 12.0 * u
	var cr := Rect2(m, m, 138.0 * u, 28.0 * u)
	Kit.pill(self, cr, Color(UiTheme.ACCENT_DARK if combo >= COMBO_STEP else UiTheme.PANEL, 0.88))
	Kit.text(self, "Combo x%d" % combo, cr, 14.0 * u, UiTheme.TEXT)
	var bar := Rect2(m + 6.0 * u, m + 32.0 * u, 126.0 * u, 8.0 * u)
	draw_rect(bar, Color(0, 0, 0, 0.45))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * float(combo % COMBO_STEP) / float(COMBO_STEP), bar.size.y)), UiTheme.GOLD)
	draw_rect(bar, Color(1, 1, 1, 0.35), false, 1.5 * u)
	var sub := ""
	if golden_t > 0.0:
		sub = "Gold x2 %ds" % ceili(golden_t)
	elif magnet_t > 0.0:
		sub = "Magnet %ds" % ceili(magnet_t)
	Kit.score_pills(self, size, u, score, sub, sub != "")
	var secs: int = maxi(0, ceili(time_left))
	Kit.timer_ring(self, Vector2(size.x * 0.5 + 10.0 * u, m + 26.0 * u), 26.0 * u, time_left / CATCH_TIME, str(secs), secs <= 5)
	if not _ctl.used and _clock < 8.0:
		var pulse: float = 0.7 if calm else 0.6 + 0.4 * sin(_clock * 4.0)
		Kit.text(self, "Drag anywhere to move", Rect2(0.0, size.y * 0.42, size.x, 30.0 * u), 20.0 * u, Color(UiTheme.TEXT, pulse))
