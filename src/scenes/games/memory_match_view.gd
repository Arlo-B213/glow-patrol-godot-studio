extends Control
## Memory Match mini-game (Story 027, extracted from games_screen.gd): 6 pairs on a lantern-lit
## board. Flip two cards per move; a match stays up, a mismatch flips back after 0.65 s. Cards
## peek for a second at the start as a gentle hint. Score is the number of moves (lower is better,
## best_scores["memory"] keeps the fewest); points earned = max(5, min(30, 30 - moves)) as before.
## Emits `finished(moves, earned)` exactly once (a short celebration after the last pair); the hub
## decides the best and calls earn_points. This view never touches GameState saves.

signal finished(score: int, earned: int)

const Kit := preload("res://scenes/games/game_kit.gd")
const Art := preload("res://scenes/games/memory_art.gd")

## Tuning knobs.
const COLS := 3
const ROWS := 4
const MISMATCH_DELAY := 0.65
const DEAL_TIME := 0.5
const PEEK_TIME := 1.1
const FLIP_SPEED := 5.5
const CELEBRATE_TIME := 1.0

enum Phase { DEAL, PEEK, PLAY, RESOLVE, DONE }

## Number of moves made (a move = two cards flipped); the hub compares it with the best.
var moves := 0
var pairs := 0
var phase: Phase = Phase.DEAL
## Card ids per slot (index into Art.ICONS), and per-card runtime state.
var deck: Array[int] = []
var flip: Array[float] = []
var up: Array[bool] = []
var matched: Array[bool] = []
var u := 1.0

var _clock := 0.0
var _phase_t := 0.0
var _first := -1
var _second := -1
var _best := 0
var _cheer := 0.0
var _shake := 0.0
var _done_emitted := false
var _hint := "Peek at the cards!"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var gs: Node = get_node_or_null("/root/GameState")
	if gs != null:
		_best = int(gs.best_scores.get("memory", 0))
	var ids: Array[int] = []
	for i in Art.ICONS.size():
		ids.append(i)
		ids.append(i)
	ids.shuffle()
	deck = ids
	for i in deck.size():
		flip.append(0.0)
		up.append(false)
		matched.append(false)
	Snd.play("whoosh", 0.02)


## Points earned for finishing in `m` moves (unchanged rule from the old hub game).
static func earned_for(m: int) -> int:
	return maxi(5, mini(30, 30 - m))


## Card rectangles (local px) for the current size; also returns the board panel as "board".
func layout() -> Dictionary:
	u = clampf(size.x / 480.0, 1.0, 2.0)
	var board := Rect2(14.0 * u, 78.0 * u, size.x - 28.0 * u, size.y - 78.0 * u - 84.0 * u)
	var pad: float = 14.0 * u
	var gap: float = 10.0 * u
	var cw: float = (board.size.x - 2.0 * pad - gap * float(COLS - 1)) / float(COLS)
	var ch: float = minf((board.size.y - 2.0 * pad - gap * float(ROWS - 1)) / float(ROWS), cw * 1.3)
	var total_h: float = ch * float(ROWS) + gap * float(ROWS - 1)
	var y0: float = board.position.y + (board.size.y - total_h) * 0.5
	var rects: Array[Rect2] = []
	for i in COLS * ROWS:
		rects.append(Rect2(board.position.x + pad + float(i % COLS) * (cw + gap), y0 + float(i / COLS) * (ch + gap), cw, ch))
	board.position.y = y0 - pad
	board.size.y = total_h + 2.0 * pad
	return {"board": board, "cards": rects}


func _process(delta: float) -> void:
	if size.x < 10.0:
		return
	delta = minf(delta, 0.1)
	var calm: bool = Kit.calm()
	_clock += delta
	_phase_t += delta
	_cheer = maxf(0.0, _cheer - delta)
	_shake = maxf(0.0, _shake - delta * 3.0)
	for i in flip.size():
		var target: float = 1.0 if up[i] else 0.0
		flip[i] = target if calm else move_toward(flip[i], target, FLIP_SPEED * delta)
	match phase:
		Phase.DEAL:
			if _phase_t >= DEAL_TIME:
				_set_all_up(true)
				_go(Phase.PEEK)
		Phase.PEEK:
			if _phase_t >= PEEK_TIME:
				_set_all_up(false)
				_hint = "Find the pairs!"
				_go(Phase.PLAY)
		Phase.RESOLVE:
			if _phase_t >= MISMATCH_DELAY:
				_resolve()
		Phase.DONE:
			if _phase_t >= CELEBRATE_TIME and not _done_emitted:
				_done_emitted = true
				finished.emit(moves, earned_for(moves))
	queue_redraw()


func _go(p: Phase) -> void:
	phase = p
	_phase_t = 0.0


func _set_all_up(on: bool) -> void:
	for i in up.size():
		if not matched[i]:
			up[i] = on
	Snd.play("tap" if on else "whoosh", 0.03)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var rects: Array = layout()["cards"]
		for i in rects.size():
			if (rects[i] as Rect2).has_point(event.position):
				press_card(i)
				return


## Flips card `i` face-up if the game allows it (same rules as the old hub game).
func press_card(i: int) -> void:
	if phase != Phase.PLAY or i < 0 or i >= deck.size() or up[i] or matched[i]:
		return
	up[i] = true
	Snd.play("tap", 0.04)
	if _first < 0:
		_first = i
		return
	_second = i
	moves += 1
	_go(Phase.RESOLVE)


func _resolve() -> void:
	var rects: Array = layout()["cards"]
	if deck[_first] == deck[_second]:
		matched[_first] = true
		matched[_second] = true
		pairs += 1
		_cheer = 1.2
		Snd.play("correct", 0.03)
		for k in [_first, _second]:
			Kit.burst(self, global_position + (rects[k] as Rect2).get_center())
		if pairs == Art.ICONS.size():
			_hint = "All matched!"
			Snd.play("win")
			_go(Phase.DONE)
			_first = -1
			_second = -1
			return
	else:
		up[_first] = false
		up[_second] = false
		_shake = 1.0
		Snd.play("wrong", 0.03)
	_first = -1
	_second = -1
	_go(Phase.PLAY)


func _draw() -> void:
	var calm: bool = Kit.calm()
	var t: float = 0.0 if calm else _clock
	Kit.draw_backdrop(self, size, "lantern", t, 0.0 if calm else _clock * 4.0)
	var lay: Dictionary = layout()
	Art.board(self, lay["board"], t, u)
	Art.hanging_lantern(self, size.x * 0.5, 44.0 * u, t, u)
	var rects: Array = lay["cards"]
	for i in rects.size():
		_draw_card(i, rects[i], t, calm)
	_draw_hud()
	Kit.pet_cheer(self, Vector2(size.x - 60.0 * u, size.y - 6.0 * u), 58.0 * u, t, 0.0 if calm else _cheer)
	Kit.text(self, _hint, Rect2(0.0, size.y - 66.0 * u, size.x, 40.0 * u), 18.0 * u, Color(UiTheme.TEXT, 0.9))


func _draw_card(i: int, r: Rect2, t: float, calm: bool) -> void:
	var f: float = flip[i]
	var appear: float = 1.0 if calm else clampf((_clock - float(i) * 0.04) / 0.25, 0.0, 1.0)
	var sx: float = absf(cos(f * PI))
	var lift: float = 1.0 + (0.0 if calm else 0.06 * sin(f * PI))
	var c: Vector2 = r.get_center()
	if _shake > 0.0 and not calm and not matched[i] and (i == _first or up[i]):
		c.x += sin(_clock * 60.0) * 4.0 * u * _shake
	var w: float = maxf(2.0, r.size.x * sx * appear)
	var h: float = r.size.y * lift * appear
	var cr := Rect2(c - Vector2(w, h) * 0.5, Vector2(w, h))
	ci_card(cr, i, f > 0.5, t)


func ci_card(cr: Rect2, i: int, face: bool, t: float) -> void:
	if face:
		Art.card_face(self, cr, deck[i], matched[i], t, float(i))
	else:
		Art.card_back(self, cr, t, float(i))


func _draw_hud() -> void:
	var m: float = 12.0 * u
	var mr := Rect2(m, m, 112.0 * u, 28.0 * u)
	Kit.pill(self, mr, Color(UiTheme.PANEL, 0.85))
	Kit.text(self, "Moves %d" % moves, mr, 14.0 * u, UiTheme.TEXT)
	var br := Rect2(m, m + 34.0 * u, 112.0 * u, 28.0 * u)
	Kit.pill(self, br, Color(UiTheme.PANEL_LIGHT, 0.9))
	Kit.text(self, "Best %s" % (str(_best) if _best > 0 else "-"), br, 14.0 * u, UiTheme.TEXT)
	var pr := Rect2(size.x - 112.0 * u - m, m, 112.0 * u, 28.0 * u)
	Kit.pill(self, pr, Color(UiTheme.ACCENT_DARK if pairs == Art.ICONS.size() else UiTheme.PANEL, 0.88))
	Kit.text(self, "Pairs %d/%d" % [pairs, Art.ICONS.size()], pr, 14.0 * u, UiTheme.TEXT)
