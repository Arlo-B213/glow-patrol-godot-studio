extends Control
## Word Scramble (Story 029): 8 grade-appropriate words per round. Letter tiles sit scrambled in a
## tray; tap a tile to send it to the next answer slot, tap a slot tile to return it, drag tiles, or
## type letters. Hint (reveals the next letter, -5 points), Shuffle, a gentle timer ring per word
## (running out reveals the word and resets the streak), streak + speed bonus scoring.
## API: `signal finished(score, earned)` emitted exactly once; earned = GameState.payout_for(score).
## The hub saves; this view never calls earn_points/save_game. `advance(dt)` is public for tests.

signal finished(score: int, earned: int)

const Words := preload("res://scenes/games/scramble_words.gd")
const Kit := preload("res://scenes/games/game_kit.gd")
const GS := preload("res://scripts/game_state.gd")

enum State { PLAY, CORRECT, WRONG, REVEAL, DONE }

const PTS_BASE := 10
const PTS_SPEED := 10  ## extra points for answering instantly, scaled by time left
const PTS_STREAK := 2  ## per previous correct word in the streak
const STREAK_CAP := 5
const HINT_COST := 5
const CORRECT_TIME := 1.3
const WRONG_TIME := 0.6
const REVEAL_TIME := 2.0

## 0 = read GameState.grade; tests may set 1-5 before adding to the tree. `seed_base` 0 = random.
var grade_override := 0
var seed_base := 0
var state: int = State.PLAY
var score := 0
var streak := 0
var idx := 0
var word := ""
var clue := ""
var time_left := 0.0
var time_total := 50.0
var hints_used := 0
var words_correct := 0
var slots: Array[int] = []
var tiles: Array = []  ## {ch, pos, slot, home, locked}

var _round: Array = []
var _rng := RandomNumberGenerator.new()
var _clock := 0.0
var _state_t := 0.0
var _cheer := 0.0
var _done := false
var _float := ""
var _float_t := 0.0
var _last_sec := -1
var _drag := -1
var _drag_off := Vector2.ZERO
var _press := Vector2.ZERO
var _moved := false
var _btn := ""
var _u := 1.0
var _ts := 58.0
var _gap := 8.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_rng.seed = seed_base if seed_base != 0 else int(Time.get_ticks_usec())
	var g: int = grade_override
	if g == 0:
		var gs: Node = get_node_or_null("/root/GameState")
		g = int(gs.get("grade")) if gs != null else 3
	grade_override = clampi(g, 1, 5)
	time_total = Words.time_for(grade_override)
	_round = Words.pick_round(grade_override, _rng)
	_layout()
	_load_word(0)


func _process(delta: float) -> void:
	advance(delta)
	queue_redraw()


## Whole-game tick (also used by tests to fast-forward).
func advance(dt: float) -> void:
	dt = minf(dt, 0.1)
	_clock += dt
	_cheer = maxf(0.0, _cheer - dt)
	_float_t = maxf(0.0, _float_t - dt)
	_layout()
	_glide(dt)
	match state:
		State.PLAY:
			time_left = maxf(0.0, time_left - dt)
			var sec: int = int(ceil(time_left))
			if sec != _last_sec:
				_last_sec = sec
				if sec <= 5 and sec > 0:
					Snd.play("tap")
			if time_left <= 0.0:
				_time_up()
		State.CORRECT, State.REVEAL, State.WRONG:
			_state_t -= dt
			if _state_t <= 0.0:
				if state == State.WRONG:
					_return_all()
					state = State.PLAY
				else:
					_next_word()


# --- layout ---

func _layout() -> void:
	_u = clampf(size.x / 480.0, 1.0, 2.0)
	_ts = 58.0 * _u
	_gap = 8.0 * _u


func _per_row() -> int:
	return maxi(1, int((size.x - 24.0 * _u) / (_ts + _gap)))


func _row_len() -> int:
	var n: int = word.length()
	var rows_n: int = int(ceil(float(n) / float(_per_row())))
	return int(ceil(float(n) / float(maxi(1, rows_n))))


func _answer_y() -> float:
	return 238.0 * _u


func _tray_y() -> float:
	var rows_n: int = int(ceil(float(word.length()) / float(_row_len())))
	return _answer_y() + float(rows_n) * (_ts + _gap) + 62.0 * _u


func _grid_pos(i: int, y0: float) -> Vector2:
	var rl: int = _row_len()
	var row: int = i / rl
	var col: int = i % rl
	var cnt: int = mini(rl, word.length() - row * rl)
	return Vector2(size.x * 0.5 + (float(col) - float(cnt - 1) * 0.5) * (_ts + _gap), y0 + float(row) * (_ts + _gap) + _ts * 0.5)


func _slot_pos(i: int) -> Vector2:
	return _grid_pos(i, _answer_y())


func _home_pos(i: int) -> Vector2:
	return _grid_pos(i, _tray_y())


func _target(t: Dictionary) -> Vector2:
	return _slot_pos(int(t["slot"])) if int(t["slot"]) >= 0 else _home_pos(int(t["home"]))


func _btn_rect(role: String) -> Rect2:
	var w: float = 140.0 * _u
	var h: float = 60.0 * _u
	var x: float = size.x * 0.5 - w - 8.0 * _u if role == "hint" else size.x * 0.5 + 8.0 * _u
	return Rect2(x, size.y - 124.0 * _u, w, h)


func _glide(dt: float) -> void:
	for i in tiles.size():
		var t: Dictionary = tiles[i]
		if i == _drag and _moved:
			continue
		var tgt: Vector2 = _target(t)
		if Kit.calm():
			t["pos"] = tgt
		else:
			t["pos"] = (t["pos"] as Vector2).lerp(tgt, minf(1.0, 18.0 * dt))


# --- round flow ---

func _load_word(i: int) -> void:
	idx = i
	var entry: Array = _round[i]
	word = String(entry[0])
	clue = String(entry[1])
	var shuffled: String = Words.scramble(word, _rng)
	tiles.clear()
	slots.clear()
	for k in word.length():
		slots.append(-1)
		tiles.append({"ch": shuffled[k], "pos": Vector2(size.x * 0.5, _tray_y() - 40.0 * _u), "slot": -1, "home": k, "locked": false})
	time_left = time_total
	_last_sec = int(ceil(time_left))
	hints_used = 0
	_drag = -1
	_btn = ""
	state = State.PLAY
	if i > 0:
		Snd.play("whoosh")


func _next_word() -> void:
	if idx + 1 >= _round.size():
		_finish()
	else:
		_load_word(idx + 1)


func _finish() -> void:
	if _done:
		return
	_done = true
	state = State.DONE
	Snd.play("win")
	finished.emit(score, GS.payout_for(score))


func _time_up() -> void:
	streak = 0
	state = State.REVEAL
	_state_t = REVEAL_TIME
	_float = "Time's up! It was %s" % word.to_upper()
	_float_t = REVEAL_TIME
	for tl in tiles:
		tl["locked"] = false
	_return_all()
	var used := {}
	for s in word.length():
		for t in tiles.size():
			if not used.has(t) and String(tiles[t]["ch"]) == word[s]:
				used[t] = true
				_set_slot(t, s)
				tiles[t]["locked"] = true
				break
	Snd.play("error")


func _check_full() -> void:
	if slots.has(-1):
		return
	var s := ""
	for k in slots:
		s += String(tiles[k]["ch"])
	if s == word:
		var ratio: float = time_left / time_total
		var pts: int = PTS_BASE + int(round(float(PTS_SPEED) * ratio)) + PTS_STREAK * mini(streak, STREAK_CAP)
		score += pts
		streak += 1
		words_correct += 1
		state = State.CORRECT
		_state_t = CORRECT_TIME
		_cheer = CORRECT_TIME
		_float = "+%d" % pts
		_float_t = CORRECT_TIME
		for t in tiles:
			t["locked"] = true
		Snd.play("correct")
		Kit.burst(self, global_position + Vector2(size.x * 0.5, _answer_y() + _ts * 0.5))
	else:
		state = State.WRONG
		_state_t = WRONG_TIME
		Snd.play("wrong")


# --- tile moves ---

func _set_slot(t: int, s: int) -> void:
	if int(tiles[t]["slot"]) >= 0:
		slots[int(tiles[t]["slot"])] = -1
	tiles[t]["slot"] = s
	if s >= 0:
		slots[s] = t


func _return_all() -> void:
	for i in tiles.size():
		if not bool(tiles[i]["locked"]):
			_set_slot(i, -1)


## Tap behaviour: tray tile -> next empty slot, answer tile -> back to the tray.
func tap_tile(t: int) -> void:
	if state != State.PLAY or bool(tiles[t]["locked"]):
		return
	if int(tiles[t]["slot"]) >= 0:
		_set_slot(t, -1)
		Snd.play("back")
		return
	var empty: int = slots.find(-1)
	if empty >= 0:
		_set_slot(t, empty)
		Snd.play("tap")
		_check_full()


## Keyboard: places the first matching tray tile (letters a-z).
func type_letter(ch: String) -> void:
	if state != State.PLAY:
		return
	for i in tiles.size():
		if int(tiles[i]["slot"]) < 0 and String(tiles[i]["ch"]) == ch.to_lower():
			tap_tile(i)
			return
	Snd.play("error")


func _backspace() -> void:
	for s in range(slots.size() - 1, -1, -1):
		if slots[s] >= 0 and not bool(tiles[slots[s]]["locked"]):
			tap_tile(slots[s])
			return


## Reveals the next letter that is missing or wrong, locks it in place, costs HINT_COST points.
func use_hint() -> void:
	if state != State.PLAY:
		return
	for s in word.length():
		var cur: int = slots[s]
		if cur >= 0 and String(tiles[cur]["ch"]) == word[s]:
			continue
		var src := -1
		for t in tiles.size():
			if String(tiles[t]["ch"]) == word[s] and not bool(tiles[t]["locked"]) and (src < 0 or int(tiles[t]["slot"]) < 0):
				src = t
		if src < 0:
			return
		if cur >= 0:
			_set_slot(cur, -1)
		_set_slot(src, s)
		tiles[src]["locked"] = true
		score = maxi(0, score - HINT_COST)
		hints_used += 1
		Snd.play("star")
		_check_full()
		return


## Re-deals the letters still in the tray.
func shuffle_tray() -> void:
	if state != State.PLAY:
		return
	var free: Array[int] = []
	var homes: Array[int] = []
	for i in tiles.size():
		if int(tiles[i]["slot"]) < 0:
			free.append(i)
			homes.append(int(tiles[i]["home"]))
	for i in range(homes.size() - 1, 0, -1):
		var j: int = _rng.randi() % (i + 1)
		var tmp: int = homes[i]
		homes[i] = homes[j]
		homes[j] = tmp
	for k in free.size():
		tiles[free[k]]["home"] = homes[k]
	Snd.play("whoosh")


# --- input ---

func _tile_at(p: Vector2) -> int:
	for i in range(tiles.size() - 1, -1, -1):
		if Rect2((tiles[i]["pos"] as Vector2) - Vector2(_ts, _ts) * 0.5, Vector2(_ts, _ts)).has_point(p):
			return i
	return -1


func _gui_input(ev: InputEvent) -> void:
	if state != State.PLAY:
		return
	if ev is InputEventMouseButton and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb := ev as InputEventMouseButton
		if mb.pressed:
			_btn = ""
			for role in ["hint", "shuffle"]:
				if _btn_rect(role).has_point(mb.position):
					_btn = role
			var t: int = _tile_at(mb.position) if _btn == "" else -1
			if t >= 0 and not bool(tiles[t]["locked"]):
				_drag = t
				_press = mb.position
				_drag_off = (tiles[t]["pos"] as Vector2) - mb.position
				_moved = false
		else:
			_release(mb.position)
	elif ev is InputEventMouseMotion and _drag >= 0:
		var mp: Vector2 = (ev as InputEventMouseMotion).position
		if not _moved and mp.distance_to(_press) > 10.0 * _u:
			_moved = true
		if _moved:
			tiles[_drag]["pos"] = mp + _drag_off


func _release(p: Vector2) -> void:
	if _btn != "":
		if _btn_rect(_btn).has_point(p):
			if _btn == "hint":
				use_hint()
			else:
				shuffle_tray()
		_btn = ""
		return
	if _drag < 0:
		return
	var t: int = _drag
	_drag = -1
	if not _moved:
		tap_tile(t)
		return
	_moved = false
	var best := -1
	var best_d: float = _ts * 0.8
	for s in word.length():
		var d: float = _slot_pos(s).distance_to(tiles[t]["pos"])
		if d < best_d:
			best_d = d
			best = s
	if best < 0:
		_set_slot(t, -1)
		Snd.play("back")
		return
	var other: int = slots[best]
	if other >= 0 and bool(tiles[other]["locked"]):
		return
	var from: int = int(tiles[t]["slot"])
	_set_slot(t, -1)
	if other >= 0:
		_set_slot(other, from)
	_set_slot(t, best)
	Snd.play("tap")
	_check_full()


func _input(ev: InputEvent) -> void:
	if not (ev is InputEventKey) or not is_visible_in_tree():
		return
	var k := ev as InputEventKey
	if not k.pressed or k.echo:
		return
	if k.physical_keycode == KEY_BACKSPACE:
		_backspace()
	elif k.unicode >= 65 and k.unicode <= 122:
		type_letter(char(k.unicode))


# --- drawing ---

func _box(r: Rect2, fill: Color, border: Color, bw: int = 2, shadow: int = 0) -> void:
	UiTheme.box(fill, border, bw, int(14.0 * _u), 0, 0, 0, shadow).draw(get_canvas_item(), r)


func _draw() -> void:
	_layout()
	var calm: bool = Kit.calm()
	var t: float = 0.0 if calm else _clock
	Kit.draw_backdrop(self, size, "lantern" if idx % 2 == 0 else "dusk", t)
	var m: float = 12.0 * _u
	var wr := Rect2(m, m, 112.0 * _u, 28.0 * _u)
	Kit.pill(self, wr, Color(UiTheme.PANEL, 0.85))
	Kit.text(self, "Word %d/%d" % [mini(idx + 1, _round.size()), _round.size()], wr, 14.0 * _u, UiTheme.TEXT)
	Kit.score_pills(self, size, _u, score, "Streak %d" % streak, streak >= 2)
	var ratio: float = time_left / time_total
	Kit.timer_ring(self, Vector2(size.x * 0.5, 86.0 * _u), 34.0 * _u, ratio, str(int(ceil(time_left))), time_left <= 10.0)
	var cr := Rect2(m * 1.5, 130.0 * _u, size.x - m * 3.0, 84.0 * _u)
	_box(cr, Color(UiTheme.PANEL, 0.82), Color(1, 1, 1, 0.18))
	draw_multiline_string(ThemeDB.fallback_font, cr.position + Vector2(10.0 * _u, 30.0 * _u), clue, HORIZONTAL_ALIGNMENT_CENTER, cr.size.x - 20.0 * _u, int(18.0 * _u), 3, UiTheme.TEXT)
	Kit.text(self, "Unscramble the letters", Rect2(0.0, _answer_y() - 26.0 * _u, size.x, 20.0 * _u), 12.0 * _u, Color(UiTheme.TEXT, 0.6))
	for s in word.length():
		var c: Vector2 = _slot_pos(s)
		_box(Rect2(c - Vector2(_ts, _ts) * 0.5, Vector2(_ts, _ts)), Color(0, 0, 0, 0.3), Color(1, 1, 1, 0.25))
	for i in tiles.size():
		if i != _drag:
			_draw_tile(i, t)
	if _drag >= 0:
		_draw_tile(_drag, t)
	var by: float = _tray_y() + float(int(ceil(float(word.length()) / float(_row_len())))) * (_ts + _gap) + 6.0 * _u
	if _float_t > 0.0:
		var fr := Rect2(size.x * 0.5 - 170.0 * _u, by, 340.0 * _u, 40.0 * _u)
		Kit.pill(self, fr, Color(UiTheme.PANEL, 0.9))
		Kit.text(self, _float, fr, 20.0 * _u, UiTheme.GOLD)
	_draw_button("hint", "Hint  -%d" % HINT_COST, UiTheme.GOLD)
	_draw_button("shuffle", "Shuffle", UiTheme.VIOLET)
	Kit.pet_cheer(self, Vector2(size.x - 52.0 * _u, size.y - 24.0 * _u), 84.0 * _u, t, 1.0 if _cheer > 0.0 else 0.0)


func _draw_tile(i: int, t: float) -> void:
	var tile: Dictionary = tiles[i]
	var p: Vector2 = tile["pos"]
	var in_slot: bool = int(tile["slot"]) >= 0
	var fill: Color = UiTheme.PANEL_LIGHT.lightened(0.15)
	var border: Color = Color(1, 1, 1, 0.5)
	if state == State.CORRECT:
		fill = UiTheme.GOLD
		border = Color.WHITE
		if not Kit.calm():
			p.y -= absf(sin(t * 10.0 - float(i) * 0.7)) * 14.0 * _u * clampf(_state_t / CORRECT_TIME * 1.6, 0.0, 1.0)
		draw_circle(p, _ts * 0.68, Color(UiTheme.GOLD, 0.22))
	elif state == State.WRONG and in_slot:
		border = Color("#FF5F6D")
		if not Kit.calm():
			p.x += sin(t * 60.0) * 6.0 * _u * (_state_t / WRONG_TIME)
	elif bool(tile["locked"]):
		fill = UiTheme.TEAL.darkened(0.25)
		border = UiTheme.TEAL
	elif i == _drag and _moved:
		fill = UiTheme.VIOLET
	var r := Rect2(p - Vector2(_ts, _ts) * 0.5, Vector2(_ts, _ts))
	_box(r, fill, border, 3, 4)
	var ink: Color = UiTheme.TEXT_ON_ACCENT if state == State.CORRECT else UiTheme.TEXT
	Kit.text(self, String(tile["ch"]).to_upper(), r, _ts * 0.58, ink)


func _draw_button(role: String, label: String, col: Color) -> void:
	var r: Rect2 = _btn_rect(role)
	var down: bool = _btn == role
	var enabled: bool = state == State.PLAY
	var fill: Color = col.darkened(0.15 if not down else 0.0)
	if not enabled:
		fill = fill.lerp(UiTheme.LOCKED, 0.6)
	_box(r, fill, Color(1, 1, 1, 0.5), 3, 4)
	Kit.text(self, label, r, 20.0 * _u, UiTheme.TEXT_ON_ACCENT)
