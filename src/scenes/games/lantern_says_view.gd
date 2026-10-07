extends Control
## Lantern Says mini-game (Story 026, Alley Brawl standard): four big glowing lanterns light up in
## a pattern with a distinct tone each; repeat it back. The pattern grows by one every round.
## Forgiving rule: 3 hearts; a wrong tap costs a heart and replays the same pattern.
## API: `signal finished(score, earned)` emitted exactly once; score = rounds completed,
## earned = max(5, rounds * 3) (same as the old games_screen formula; the hub saves/pays).

signal finished(score: int, earned: int)

const Kit := preload("res://scenes/games/game_kit.gd")
const Scenery := preload("res://scenes/games/lantern_scenery.gd")

enum State { WATCH, TURN, CORRECT, MISTAKE, OVER }

const COLORS := [Color("#FFC15E"), Color("#52E8C6"), Color("#FF5FA2"), Color("#8E7CFF")]
const SOUNDS := ["tap", "coin", "star", "chapter"]
const KEYS := [KEY_UP, KEY_RIGHT, KEY_DOWN, KEY_LEFT]
const START_HEARTS := 3
const STEP_START := 0.62  ## seconds per pattern step in round 1
const STEP_MIN := 0.36
const STEP_SPEEDUP := 0.02
const LEAD_IN := 0.9
const CORRECT_PAUSE := 0.8
const MISTAKE_PAUSE := 1.2
const OVER_PAUSE := 1.3
const MIN_PAYOUT := 5
const PAYOUT_PER_ROUND := 3

## Fixed seed for tests (-1 = random).
var seed_value := -1
var state: int = State.WATCH
var sequence: Array = []
var hearts := START_HEARTS
var rounds_done := 0
var streak := 0
var input_i := 0
var lit: Array = [0.0, 0.0, 0.0, 0.0]
var cheer := 0.0

var _rng := RandomNumberGenerator.new()
var _st := 0.0
var _watch_i := -1
var _anim := 0.0
var _emitted := false
var _flash_t := 0.0
var _flash_col := Color.WHITE
var _popups: Array = []
var _u := 1.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if seed_value >= 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()
	Snd.music("games")
	_next_round()


func _process(delta: float) -> void:
	advance(delta)
	queue_redraw()


## Seconds each pattern step lasts at the current pattern length.
func step_len() -> float:
	return maxf(STEP_MIN, STEP_START - STEP_SPEEDUP * float(sequence.size() - 1))


## Advances the simulation by `dt` seconds.
func advance(dt: float) -> void:
	dt = minf(dt, 0.1)
	_anim += dt
	for i in 4:
		lit[i] = maxf(0.0, float(lit[i]) - dt * 2.6)
	cheer = maxf(0.0, cheer - dt * 0.7)
	_flash_t = maxf(0.0, _flash_t - dt * 2.5)
	for p in _popups:
		p["age"] = float(p["age"]) + dt
	_popups = _popups.filter(func(p: Dictionary) -> bool: return float(p["age"]) < 1.0)
	_st += dt
	match state:
		State.WATCH:
			_advance_watch()
		State.CORRECT:
			if _st >= CORRECT_PAUSE:
				_next_round()
		State.MISTAKE:
			if _st >= MISTAKE_PAUSE:
				_begin_watch()
		State.OVER:
			if _st >= OVER_PAUSE and not _emitted:
				_emitted = true
				finished.emit(rounds_done, maxi(MIN_PAYOUT, rounds_done * PAYOUT_PER_ROUND))


func _advance_watch() -> void:
	if _st < 0.0:
		return
	var idx: int = int(floor(_st / step_len()))
	while _watch_i < idx and _watch_i < sequence.size():
		_watch_i += 1
		if _watch_i < sequence.size():
			_light(int(sequence[_watch_i]))
	if _watch_i >= sequence.size() and _st >= float(sequence.size()) * step_len():
		state = State.TURN
		input_i = 0
		_st = 0.0
		Snd.play("whoosh")


func _light(i: int) -> void:
	lit[i] = 1.0
	Snd.play(SOUNDS[i])


func _next_round() -> void:
	sequence.append(_rng.randi() % 4)
	_begin_watch()


func _begin_watch() -> void:
	state = State.WATCH
	_st = -LEAD_IN
	_watch_i = -1
	input_i = 0


## Player taps lantern `i` (0 top, 1 right, 2 bottom, 3 left). Ignored unless it is the player's turn.
func press_lantern(i: int) -> void:
	if state != State.TURN:
		return
	_light(i)
	var c := _centers()[i] as Vector2
	if int(sequence[input_i]) == i:
		input_i += 1
		if input_i == sequence.size():
			_round_won(c)
		return
	hearts -= 1
	streak = 0
	_flash_t = 1.0
	_flash_col = Color("#FF5577")
	Snd.play("error")
	_popup("Oops!", Color("#FF8FA8"), c)
	_st = 0.0
	if hearts <= 0:
		state = State.OVER
		Snd.play("lose")
	else:
		state = State.MISTAKE


func _round_won(c: Vector2) -> void:
	rounds_done += 1
	streak += 1
	state = State.CORRECT
	_st = 0.0
	cheer = 1.0
	_flash_t = 0.6
	_flash_col = UiTheme.GOLD
	_popup("Round %d!" % rounds_done, UiTheme.GOLD, Vector2(size.x * 0.5, size.y * 0.5))
	Snd.play("correct")
	Kit.burst(self, get_global_transform() * c)
	if streak >= 3 and streak % 3 == 0:
		Snd.play("high_five")
		Kit.burst(self, get_global_transform() * Vector2(size.x * 0.5, size.y * 0.5))


func _popup(text: String, col: Color, pos: Vector2) -> void:
	_popups.append({"text": text, "col": col, "pos": pos, "age": 0.0})


# --- layout / input ---

func _layout() -> Dictionary:
	_u = clampf(size.x / 480.0, 1.0, 2.0)
	var r: float = minf(size.x * 0.15, size.y * 0.085)
	return {"r": r, "d": r * 1.75, "c": Vector2(size.x * 0.5, size.y * 0.52)}


func _centers() -> Array:
	var lay: Dictionary = _layout()
	var c: Vector2 = lay["c"]
	var d: float = lay["d"]
	return [c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var p := Vector2(-1, -1)
	if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
		p = _local((event as InputEventScreenTouch).position)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and mb.device != InputEvent.DEVICE_ID_EMULATION:
			p = _local(mb.position)
	elif event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and not k.echo and KEYS.has(k.physical_keycode):
			press_lantern(KEYS.find(k.physical_keycode))
		return
	if p.x < 0.0:
		return
	var r: float = _layout()["r"]
	var cs: Array = _centers()
	for i in 4:
		if p.distance_to(cs[i]) <= r * 1.25:
			press_lantern(i)
			return


func _local(p: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * p


# --- drawing ---

func _draw() -> void:
	var calm: bool = Kit.calm()
	var t: float = 0.0 if calm else _anim
	var u := _u
	var glow: float = 0.0
	for v in lit:
		glow = maxf(glow, float(v))
	Scenery.draw(self, size, t, glow)
	var r: float = _layout()["r"]
	var cs: Array = _centers()
	for i in 4:
		var bob: float = 0.0 if calm else sin(t * 1.4 + float(i) * 1.6) * 3.0
		var c: Vector2 = (cs[i] as Vector2) + Vector2(0, bob)
		Scenery.draw_lantern(self, c, r, COLORS[i], clampf(float(lit[i]), 0.0, 1.0), c.y - r * 1.9)
	_draw_hud(u)
	for p in _popups:
		var k: float = float(p["age"])
		var rise: float = 0.0 if calm else -50.0 * u * k
		var pr := Rect2((p["pos"] as Vector2) + Vector2(-110.0 * u, -90.0 * u + rise), Vector2(220.0 * u, 40.0 * u))
		Kit.text(self, String(p["text"]), pr, 28.0 * u, Color(p["col"], 1.0 - k * 0.8))
	if _flash_t > 0.0:
		for i in 5:
			var w: float = 4.0 + float(i) * 7.0
			var fc := Color(_flash_col, _flash_t * 0.5 * (1.0 - float(i) / 5.0))
			draw_rect(Rect2(0.0, 0.0, size.x, w), fc)
			draw_rect(Rect2(0.0, size.y - w, size.x, w), fc)
			draw_rect(Rect2(0.0, 0.0, w, size.y), fc)
			draw_rect(Rect2(size.x - w, 0.0, w, size.y), fc)
	Kit.pet_cheer(self, Vector2(52.0 * u, size.y - 10.0 * u), 64.0 * u, t, cheer)


func _draw_hud(u: float) -> void:
	var m: float = 12.0 * u
	var hr: Rect2 = Kit.hearts(self, Vector2(m, m), hearts, START_HEARTS, u)
	var rr := Rect2(size.x * 0.5 - 60.0 * u, m, 120.0 * u, hr.size.y)
	Kit.pill(self, rr, Color(UiTheme.PANEL, 0.85))
	Kit.text(self, "Round %d" % sequence.size(), rr, 16.0 * u, UiTheme.GOLD)
	Kit.score_pills(self, size, u, rounds_done, "Streak %d" % streak, streak >= 3)
	var banner := "Watch..."
	var bcol: Color = UiTheme.PANEL_LIGHT
	match state:
		State.TURN:
			banner = "Your turn!"
			bcol = UiTheme.TEAL.darkened(0.45)
		State.CORRECT:
			banner = "Nice!"
			bcol = UiTheme.GOLD.darkened(0.4)
		State.MISTAKE:
			banner = "Watch again..."
			bcol = UiTheme.ACCENT_DARK
		State.OVER:
			banner = "Pattern broken"
			bcol = UiTheme.ACCENT_DARK
	var br := Rect2(size.x * 0.5 - 120.0 * u, hr.end.y + 14.0 * u, 240.0 * u, 44.0 * u)
	Kit.pill(self, br, Color(bcol, 0.92))
	Kit.text(self, banner, br, 22.0 * u, UiTheme.TEXT)
	var n: int = sequence.size()
	var dot: float = minf(14.0 * u, (br.size.x + 60.0 * u) / float(maxi(n, 1)) * 0.6)
	var x0: float = size.x * 0.5 - float(n) * dot * 1.5 * 0.5 + dot * 0.75
	for i in n:
		var done: bool = (state == State.TURN or state == State.CORRECT) and i < input_i
		var dc := Color(UiTheme.GOLD, 0.95) if done else Color(1, 1, 1, 0.3)
		draw_circle(Vector2(x0 + float(i) * dot * 1.5, br.end.y + 16.0 * u), dot * 0.5, dc)
