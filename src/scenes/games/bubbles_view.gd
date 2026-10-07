extends Control
## Glow Bubbles (Story 028): a bubble-pop shooter. Aim the glow cannon (drag + release, tap, A/D or
## arrows + Space), snap orbs onto a hex grid, match 3+ to pop, orphans fall, the ceiling creeps down
## after a few misses. Stage 1..8, procedurally seeded; the run ends when orbs cross the deadline
## line or stage 8 is cleared.
## API: `signal finished(score, earned)` emitted exactly once; earned = GameState.payout_for(score).
## The hub saves; this view never calls earn_points/save_game. `advance(dt)` is public for tests.

signal finished(score: int, earned: int)

const Grid := preload("res://scenes/games/bubbles_grid.gd")
const Art := preload("res://scenes/games/bubbles_art.gd")
const Kit := preload("res://scenes/games/game_kit.gd")
const Hunter := preload("res://scripts/hunter_art.gd")
const GS := preload("res://scripts/game_state.gd")

enum State { AIM, FLYING, CLEAR, OVER }

const MAX_STAGE := 8
const MAX_ROWS := 11  ## rows that fit above the deadline line
const STEP := 1.0 / 120.0  ## fixed physics step (s)
const SPEED_R := 34.0  ## shot speed in orb radii per second (step < r/2: no tunnelling)
const MIN_ANGLE := 0.2
const AIM_KEY_SPEED := 1.6
const PTS_POP := 10
const PTS_DROP := 20
const PTS_STAGE := 100
const COMBO_CAP := 4
const BASE_MISSES := 7
const MIN_MISSES := 3
const SPECIAL_CHANCE := 0.06
const POP_TIME := 0.3
const SHAKE_TIME := 0.18
const END_DELAY := 2.0

## Set before adding to the tree for a reproducible run (0 = random).
var seed_base := 0
var state: int = State.AIM
var grid := Grid.new()
var stage := 0
var score := 0
var combo := 0
var misses := 0
var misses_limit := BASE_MISSES
var aim := PI * 0.5
var loaded := 0
var next_orb := 0
var proj_pos := Vector2.ZERO
var proj_dir := Vector2.UP
var proj_kind := 0
var won := false

var _rng := RandomNumberGenerator.new()
var _acc := 0.0
var _clock := 0.0
var _shake := 0.0
var _cheer := 0.0
var _grid_dy := 0.0
var _banner := ""
var _banner_t := 0.0
var _end_t := 0.0
var _done := false
var _aiming := false
var _pops: Array = []
var _falls: Array = []
var _guide := PackedVector2Array()
var _guide_end := Vector2.ZERO
var _guide_key := Vector2(-1.0, -1.0)
var _u := 1.0
var _r := 30.0
var _ox := 0.0
var _top := 0.0
var _cannon := Vector2.ZERO
var _deadline := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_rng.seed = seed_base if seed_base != 0 else int(Time.get_ticks_usec())
	if seed_base == 0:
		seed_base = int(_rng.randi() % 100000) + 1
	_layout()
	_start_stage(1)


func _process(delta: float) -> void:
	advance(delta)
	queue_redraw()


## Whole-game tick (also used by tests to fast-forward).
func advance(dt: float) -> void:
	dt = minf(dt, 0.1)
	_clock += dt
	_shake = maxf(0.0, _shake - dt)
	_cheer = maxf(0.0, _cheer - dt)
	_banner_t = maxf(0.0, _banner_t - dt)
	_grid_dy = move_toward(_grid_dy, 0.0, _r * Grid.ROW_H * 4.0 * dt) if not Kit.calm() else 0.0
	_tick_fx(dt)
	match state:
		State.AIM:
			_keyboard_aim(dt)
		State.FLYING:
			_acc += dt
			while _acc >= STEP and state == State.FLYING:
				_acc -= STEP
				_step_shot()
		State.CLEAR:
			_end_t -= dt
			if _end_t <= 0.0:
				_start_stage(stage + 1)
		State.OVER:
			_end_t -= dt
			if _end_t <= 0.0:
				_finish()


## Fires the loaded orb along the current aim (no-op unless aiming).
func fire() -> void:
	if state != State.AIM or _done:
		return
	_layout()
	proj_kind = loaded
	proj_pos = _cannon
	proj_dir = Vector2(cos(aim), -sin(aim))
	loaded = -1
	_acc = 0.0
	state = State.FLYING
	Snd.play("whoosh")


## Swaps the loaded and next orbs.
func swap_orbs() -> void:
	if state != State.AIM or loaded < 0:
		return
	var t: int = loaded
	loaded = next_orb
	next_orb = t
	_guide_key = Vector2(-1.0, -1.0)
	Snd.play("tap")


func _gs() -> Node:
	return get_node_or_null("/root/GameState")


func _layout() -> void:
	_u = clampf(size.x / 480.0, 1.0, 2.0)
	_cannon = Vector2(size.x * 0.5, size.y - 118.0 * _u)
	_top = 104.0 * _u
	_r = minf(size.x / 19.4, (_cannon.y - _top) / (float(MAX_ROWS) * Grid.ROW_H + 0.4 + 3.0))
	_ox = (size.x - 19.0 * _r) * 0.5
	_deadline = _top + (float(MAX_ROWS) * Grid.ROW_H + 0.4) * _r


func _start_stage(s: int) -> void:
	stage = s
	_layout()
	var cols: int = 4 if s <= 1 else 5
	grid.generate(seed_base + s * 7919, mini(5 + s / 2, MAX_ROWS - 4), cols)
	misses = 0
	misses_limit = maxi(MIN_MISSES, BASE_MISSES - (s - 1))
	combo = 0
	_falls.clear()
	_pops.clear()
	loaded = _roll()
	next_orb = _roll()
	state = State.AIM
	_guide_key = Vector2(-1.0, -1.0)
	_banner = "Stage %d" % s
	_banner_t = 1.6
	if s > 1:
		Snd.play("chapter")


func _roll() -> int:
	if stage >= 2 and _rng.randf() < SPECIAL_CHANCE:
		return Grid.SPECIAL_RAINBOW if _rng.randf() < 0.5 else Grid.SPECIAL_BOMB
	var cols: Array[int] = grid.colors_present()
	if cols.is_empty():
		return 0
	return cols[_rng.randi() % cols.size()]


## Replaces queued colours that are no longer on the grid so a shot can always match.
func _fix_queue() -> void:
	var cols: Array[int] = grid.colors_present()
	if cols.is_empty():
		return
	if loaded < Grid.SPECIAL_RAINBOW and not cols.has(loaded):
		loaded = cols[_rng.randi() % cols.size()]
	if next_orb < Grid.SPECIAL_RAINBOW and not cols.has(next_orb):
		next_orb = cols[_rng.randi() % cols.size()]


func _keyboard_aim(dt: float) -> void:
	var d := 0.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		d += 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		d -= 1.0
	if d != 0.0:
		aim = clampf(aim + d * AIM_KEY_SPEED * dt, MIN_ANGLE, PI - MIN_ANGLE)


func _step_shot() -> void:
	proj_pos += proj_dir * _r * SPEED_R * STEP
	if proj_pos.x - _r < _ox:
		proj_pos.x = 2.0 * (_ox + _r) - proj_pos.x
		proj_dir.x = absf(proj_dir.x)
	elif proj_pos.x + _r > _ox + 19.0 * _r:
		proj_pos.x = 2.0 * (_ox + 19.0 * _r - _r) - proj_pos.x
		proj_dir.x = -absf(proj_dir.x)
	var local: Vector2 = proj_pos - Vector2(_ox, _top + _grid_dy)
	if grid.hit_test(local, _r):
		_land(local)


func _cell_view(c: Vector2i) -> Vector2:
	return grid.cell_pos(c.x, c.y, _r) + Vector2(_ox, _top + _grid_dy)


func _land(local: Vector2) -> void:
	var cell: Vector2i = grid.snap_cell(local, _r)
	var kind: int = proj_kind
	if kind == Grid.SPECIAL_RAINBOW:
		kind = _rainbow_color(cell)
	grid.set_cell(cell.x, cell.y, kind)
	var removed: Array[Vector2i] = []
	if proj_kind == Grid.SPECIAL_BOMB:
		removed = grid.bomb_area(cell.x, cell.y)
	else:
		var m: Array[Vector2i] = grid.find_match(cell.x, cell.y)
		if m.size() >= 3:
			removed = m
	if removed.is_empty():
		combo = 0
		misses += 1
		Snd.play("hit")
		if misses >= misses_limit:
			misses = 0
			grid.add_row_top(_rng, 4 if stage <= 1 else 5)
			_grid_dy = -_r * Grid.ROW_H
			_shake = SHAKE_TIME
			Snd.play("whoosh")
	else:
		_resolve_pops(removed)
	_fix_queue()
	loaded = next_orb
	next_orb = _roll()
	_fix_queue()
	_guide_key = Vector2(-1.0, -1.0)
	_after_shot()


func _rainbow_color(cell: Vector2i) -> int:
	var counts := {}
	for n in grid.neighbors(cell.x, cell.y):
		var v: int = grid.get_cell(n.x, n.y)
		if v >= 0 and v < Grid.SPECIAL_RAINBOW:
			counts[v] = int(counts.get(v, 0)) + 1
	var best := -1
	for k in counts.keys():
		if best < 0 or int(counts[k]) > int(counts[best]):
			best = int(k)
	if best >= 0:
		return best
	var cols: Array[int] = grid.colors_present()
	return cols[0] if not cols.is_empty() else 0


func _resolve_pops(removed: Array[Vector2i]) -> void:
	var calm: bool = Kit.calm()
	var centre := Vector2.ZERO
	for p in removed:
		var v: Vector2 = _cell_view(p)
		centre += v
		if not calm:
			_pops.append({"p": v, "c": grid.get_cell(p.x, p.y), "t": 0.0})
	centre /= float(removed.size())
	grid.remove_cells(removed)
	var orphans: Array[Vector2i] = grid.find_orphans()
	for p in orphans:
		if not calm:
			_falls.append({"p": _cell_view(p), "v": Vector2(_rng.randf_range(-60.0, 60.0) * _u, -_rng.randf_range(0.0, 220.0) * _u), "c": grid.get_cell(p.x, p.y)})
	grid.remove_cells(orphans)
	combo += 1
	misses = 0
	score += (removed.size() * PTS_POP + orphans.size() * PTS_DROP) * mini(combo, COMBO_CAP)
	Snd.play("coin", 0.15)
	if not orphans.is_empty():
		Snd.play("star")
	_shake = 0.0 if calm else SHAKE_TIME * 0.6
	Kit.burst(self, global_position + centre)
	if combo >= 2:
		_cheer = 1.2
		Snd.play("high_five" if combo >= 3 else "eat")


func _after_shot() -> void:
	if grid.count() == 0:
		score += PTS_STAGE
		if stage >= MAX_STAGE:
			won = true
			_end_game("All stages clear!", "win")
		else:
			state = State.CLEAR
			_end_t = 1.7
			_banner = "Stage clear!  +%d" % PTS_STAGE
			_banner_t = 1.7
			_cheer = 1.5
			Snd.play("level_up")
		return
	var lr: int = grid.lowest_row()
	if lr >= 0 and grid.cell_pos(lr, 0, _r).y + _r > _deadline - _top + 0.01:
		_end_game("Game over", "lose")
		return
	state = State.AIM


func _end_game(text: String, sfx: String) -> void:
	state = State.OVER
	_end_t = END_DELAY
	_banner = text
	_banner_t = END_DELAY
	Snd.play(sfx)


func _finish() -> void:
	if _done:
		return
	_done = true
	finished.emit(score, GS.payout_for(score))


func _tick_fx(dt: float) -> void:
	for pop in _pops:
		pop["t"] = float(pop["t"]) + dt
	_pops = _pops.filter(func(p: Dictionary) -> bool: return float(p["t"]) < POP_TIME)
	for f in _falls:
		f["v"] = (f["v"] as Vector2) + Vector2(0.0, _r * 62.0 * dt)
		f["p"] = (f["p"] as Vector2) + (f["v"] as Vector2) * dt
	_falls = _falls.filter(func(f: Dictionary) -> bool: return (f["p"] as Vector2).y < size.y + _r * 2.0)


# --- input ---

func _gui_input(ev: InputEvent) -> void:
	if state != State.AIM:
		return
	if ev is InputEventMouseButton and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb := ev as InputEventMouseButton
		if mb.pressed:
			if mb.position.distance_to(_next_pos()) <= maxf(_r * 1.4, 30.0 * _u):
				swap_orbs()
			elif mb.position.y < _cannon.y - _r:
				_aiming = true
				_aim_at(mb.position)
		elif _aiming:
			_aiming = false
			if mb.position.y < _cannon.y - _r * 0.5:
				_aim_at(mb.position)
				fire()
	elif ev is InputEventMouseMotion and _aiming:
		_aim_at((ev as InputEventMouseMotion).position)


func _input(ev: InputEvent) -> void:
	if ev is InputEventKey and (ev as InputEventKey).pressed and not (ev as InputEventKey).echo and is_visible_in_tree():
		var k := ev as InputEventKey
		if k.physical_keycode == KEY_SPACE or k.physical_keycode == KEY_ENTER:
			fire()
			get_viewport().set_input_as_handled()
		elif k.physical_keycode == KEY_S or k.physical_keycode == KEY_DOWN:
			swap_orbs()


func _aim_at(p: Vector2) -> void:
	var v: Vector2 = p - _cannon
	if v.y > -4.0:
		return
	aim = clampf(atan2(-v.y, v.x), MIN_ANGLE, PI - MIN_ANGLE)


func _next_pos() -> Vector2:
	return _cannon + Vector2(-112.0 * _u, 22.0 * _u)


## Aim-guide polyline in view space: dots along the shot path with up to a few wall bounces.
func _trace() -> void:
	_guide.clear()
	var p: Vector2 = _cannon
	var d := Vector2(cos(aim), -sin(aim))
	var step: float = _r * 0.5
	for i in 320:
		p += d * step
		if p.x - _r < _ox:
			p.x = 2.0 * (_ox + _r) - p.x
			d.x = absf(d.x)
		elif p.x + _r > _ox + 19.0 * _r:
			p.x = 2.0 * (_ox + 18.0 * _r) - p.x
			d.x = -absf(d.x)
		if grid.hit_test(p - Vector2(_ox, _top), _r):
			break
		if i % 3 == 2:
			_guide.append(p)
	_guide_end = p


# --- drawing ---

func _draw() -> void:
	_layout()
	var t: float = 0.0 if Kit.calm() else _clock
	Kit.draw_backdrop(self, size, "neon" if stage % 2 == 1 else "mint", t)
	var off := Vector2.ZERO
	if _shake > 0.0 and not Kit.calm():
		off = Vector2(sin(_clock * 130.0), cos(_clock * 97.0)) * 4.0 * _u * (_shake / SHAKE_TIME)
	draw_set_transform(off)
	_draw_field(t)
	for pop in _pops:
		var f: float = float(pop["t"]) / POP_TIME
		Art.draw_orb(self, pop["p"], _r * (1.0 + 0.5 * f), int(pop["c"]), t, 1.0 - f)
		draw_arc(pop["p"], _r * (1.0 + 1.2 * f), 0.0, TAU, 20, Color(1, 1, 1, 0.7 * (1.0 - f)), 2.5, true)
	for fl in _falls:
		Art.draw_orb(self, fl["p"], _r, int(fl["c"]), t)
	_draw_launcher(t)
	draw_set_transform(Vector2.ZERO)
	_draw_hud(t)


func _draw_field(t: float) -> void:
	var w: float = 19.0 * _r
	var fr := Rect2(_ox - 4.0, _top - 8.0 * _u, w + 8.0, _deadline - _top + 12.0 * _u)
	draw_rect(fr, Color(0, 0, 0, 0.26))
	draw_rect(fr, Color(1, 1, 1, 0.16), false, 2.0)
	draw_rect(Rect2(_ox - 4.0, _top - 8.0 * _u, w + 8.0, 8.0 * _u), Color(UiTheme.ACCENT, 0.85))
	for r in grid.rows.size():
		for c in grid.cols_in_row(r):
			var v: int = grid.get_cell(r, c)
			if v != Grid.EMPTY:
				var wob: float = 0.0 if Kit.calm() else sin(t * 2.4 + float(r * 3 + c)) * 0.6
				Art.draw_orb(self, _cell_view(Vector2i(r, c)) + Vector2(0.0, wob), _r, v, t)
	# deadline
	var danger: bool = misses_limit - misses <= 1
	var dl := Color("#FF5F6D", 0.55 + (0.3 if danger else 0.0))
	var x: float = _ox
	while x < _ox + w:
		draw_line(Vector2(x, _deadline), Vector2(minf(x + 14.0 * _u, _ox + w), _deadline), dl, 3.0)
		x += 24.0 * _u
	if state == State.AIM or state == State.FLYING:
		if state == State.AIM:
			_draw_guide()
	if state == State.FLYING:
		Art.draw_orb(self, proj_pos, _r, proj_kind, t)


func _draw_guide() -> void:
	if _guide_key != Vector2(aim, float(loaded)):
		_trace()
		_guide_key = Vector2(aim, float(loaded))
	var col: Color = Color.WHITE if loaded >= Grid.SPECIAL_RAINBOW else Art.COLORS[clampi(loaded, 0, 4)].lightened(0.35)
	for i in _guide.size():
		draw_circle(_guide[i], _r * 0.16, Color(col, 0.85 - 0.5 * float(i) / float(maxi(1, _guide.size()))))
	draw_arc(_guide_end, _r * 0.95, 0.0, TAU, 24, Color(col, 0.55), 2.0, true)


func _draw_launcher(t: float) -> void:
	var d := Vector2(cos(aim), -sin(aim))
	var n := Vector2(-d.y, d.x)
	var w: float = _r * 0.55
	var tip: Vector2 = _cannon + d * _r * 2.2
	draw_colored_polygon(PackedVector2Array([_cannon + n * w, tip + n * w * 0.8, tip - n * w * 0.8, _cannon - n * w]), UiTheme.VIOLET)
	draw_colored_polygon(PackedVector2Array([tip - d * _r * 0.5 + n * w * 0.85, tip + n * w * 0.8, tip - n * w * 0.8, tip - d * _r * 0.5 - n * w * 0.85]), UiTheme.TEAL)
	draw_circle(_cannon + Vector2(0.0, 4.0), _r * 1.55, Color(0, 0, 0, 0.35))
	draw_circle(_cannon, _r * 1.5, UiTheme.PANEL_LIGHT)
	draw_arc(_cannon, _r * 1.5, 0.0, TAU, 36, Color(1, 1, 1, 0.45), 3.0, true)
	if loaded >= 0 and state != State.FLYING:
		Art.draw_orb(self, _cannon, _r, loaded, t)
	# next orb (tap to swap)
	var np: Vector2 = _next_pos()
	draw_circle(np, _r * 1.15, Color(UiTheme.PANEL, 0.7))
	draw_arc(np, _r * 1.15, 0.0, TAU, 28, Color(1, 1, 1, 0.3), 2.0, true)
	if next_orb >= 0:
		Art.draw_orb(self, np, _r * 0.8, next_orb, t)
	Kit.text(self, "NEXT - tap to swap", Rect2(np + Vector2(-70.0 * _u, _r * 1.2), Vector2(140.0 * _u, 20.0 * _u)), 11.0 * _u, Color(UiTheme.TEXT, 0.75))
	# the hunter and the pet cheer the player on
	var gs: Node = _gs()
	if gs != null:
		Hunter.draw_portrait(self, Rect2(10.0 * _u, size.y - 112.0 * _u, 84.0 * _u, 84.0 * _u), gs.hunter_look(), t, 1.0, not Kit.calm())
	Kit.pet_cheer(self, Vector2(size.x - 56.0 * _u, size.y - 30.0 * _u), 84.0 * _u, t, 1.0 if _cheer > 0.0 else 0.0)


func _draw_hud(_t: float) -> void:
	var m: float = 12.0 * _u
	var sr := Rect2(m, m, 112.0 * _u, 28.0 * _u)
	Kit.pill(self, sr, Color(UiTheme.PANEL, 0.85))
	Kit.text(self, "Stage %d/%d" % [stage, MAX_STAGE], sr, 14.0 * _u, UiTheme.TEXT)
	Kit.score_pills(self, size, _u, score, "Combo x%d" % maxi(1, mini(combo, COMBO_CAP)), combo >= 2)
	# ceiling warning bar: one pip per miss until the ceiling drops
	var w: float = 19.0 * _r
	var by: float = _top - 30.0 * _u
	var pw: float = w / float(misses_limit)
	var hot: bool = misses_limit - misses <= 1
	for i in misses_limit:
		var pr := Rect2(_ox + float(i) * pw + 2.0, by, pw - 4.0, 9.0 * _u)
		var filled: bool = i < misses
		var fc: Color = Color("#FF5F6D") if (hot and filled) else (UiTheme.GOLD if filled else Color(1, 1, 1, 0.18))
		draw_rect(pr, fc)
	var msg: String = "Ceiling drops next miss!" if hot else "Ceiling drops in %d misses" % (misses_limit - misses)
	Kit.text(self, msg, Rect2(_ox, by - 22.0 * _u, w, 18.0 * _u), 12.0 * _u, Color("#FF9AA5") if hot else Color(UiTheme.TEXT, 0.75))
	if _banner_t > 0.0:
		var br := Rect2(size.x * 0.5 - 150.0 * _u, _top + 6.0 * _r * Grid.ROW_H, 300.0 * _u, 52.0 * _u)
		Kit.pill(self, br, Color(UiTheme.PANEL, 0.92))
		Kit.text(self, _banner, br, 22.0 * _u, UiTheme.GOLD)
