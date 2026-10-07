extends Control
## Rhythm Tap mini-game (Story 026, Alley Brawl standard): notes fall down four lanes as glowing
## orbs; tap the round pad (or D/F/J/K) when an orb reaches the hit line. Perfect = 3, Good = 1,
## every 10 combo triggers a FEVER (bonus + harder backdrop pulse). Code-drawn, delta-time driven.
## API: `signal finished(score, earned)` emitted exactly once; earned = payout_for(round(score/3)).

signal finished(score: int, earned: int)

const Kit := preload("res://scenes/games/game_kit.gd")
const Stage := preload("res://scenes/games/rhythm_stage.gd")

const LANE_COLORS := [Color("#FF5FA2"), Color("#FFC15E"), Color("#52E8C6"), Color("#8E7CFF")]
const LANE_KEYS := ["D", "F", "J", "K"]
const TOTAL_NOTES := 26
const NOTE_INTERVAL := 0.62  ## seconds between notes (also the beat length)
const FIRST_NOTE := 1.4  ## song time of the first note
const FALL_TIME := 1.6  ## seconds an orb takes to fall to the hit line
const COUNT_IN := 3.0  ## seconds of 3-2-1 before song time 0
const PERFECT_WIN := 0.085
const GOOD_WIN := 0.2
const PERFECT_PTS := 3
const GOOD_PTS := 1
const FEVER_EVERY := 10
const FEVER_BONUS := 2
const FEVER_TIME := 1.5
const END_TAIL := 0.9

## Fixed seed for tests (-1 = random chart).
var chart_seed := -1
var score := 0
var combo := 0
var best_combo := 0
var song_t := -COUNT_IN
var notes: Array = []  ## {lane:int, t:float, done:bool}
var running := true
var pad_glow: Array = [0.0, 0.0, 0.0, 0.0]
var fever_t := 0.0
var flash_t := 0.0
var flash_col := Color.WHITE
var cheer := 0.0

var _done := false
var _anim := 0.0
var _popups: Array = []  ## {text, col, pos, age}
var _pointers := {}  ## pointer id -> lane
var _keys_down := {}
var _last_count := 99
var _u := 1.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng := RandomNumberGenerator.new()
	if chart_seed >= 0:
		rng.seed = chart_seed
	else:
		rng.randomize()
	for i in TOTAL_NOTES:
		notes.append({"lane": rng.randi() % 4, "t": FIRST_NOTE + float(i) * NOTE_INTERVAL, "done": false})
	Snd.music("games")


func _process(delta: float) -> void:
	advance(delta)
	queue_redraw()


## Advances the simulation by `dt` seconds (clamped so a hitch cannot skip notes).
func advance(dt: float) -> void:
	dt = minf(dt, 0.1)
	_anim += dt
	for i in 4:
		pad_glow[i] = maxf(0.0, float(pad_glow[i]) - dt * 4.0)
	fever_t = maxf(0.0, fever_t - dt)
	flash_t = maxf(0.0, flash_t - dt * 3.0)
	cheer = maxf(0.0, cheer - dt * 0.8)
	for p in _popups:
		p["age"] = float(p["age"]) + dt
	_popups = _popups.filter(func(p: Dictionary) -> bool: return float(p["age"]) < 0.8)
	if not running:
		return
	song_t += dt
	if song_t < 0.0:
		var c: int = int(ceil(-song_t))
		if c != _last_count:
			_last_count = c
			Snd.play("tap")
	elif _last_count != 0:
		_last_count = 0
		Snd.play("whoosh")
	var all_done := true
	for n in notes:
		if bool(n["done"]):
			continue
		all_done = false
		if song_t - float(n["t"]) > GOOD_WIN:
			n["done"] = true
			_judge_miss(int(n["lane"]))
	if all_done and song_t > float(notes[notes.size() - 1]["t"]) + END_TAIL:
		_end()


## Presses `lane` (0..3): judges the closest note in the window.
func press_lane(lane: int) -> void:
	pad_glow[lane] = 1.0
	if not running or song_t < -0.4:
		Snd.play("tap")
		return
	var best := -1
	var best_d := 9999.0
	for i in notes.size():
		var n: Dictionary = notes[i]
		if bool(n["done"]) or int(n["lane"]) != lane:
			continue
		var d: float = absf(song_t - float(n["t"]))
		if d < best_d:
			best_d = d
			best = i
	if best == -1 or best_d > GOOD_WIN:
		Snd.play("tap")
		return
	notes[best]["done"] = true
	var perfect: bool = best_d <= PERFECT_WIN
	combo += 1
	best_combo = maxi(best_combo, combo)
	score += PERFECT_PTS if perfect else GOOD_PTS
	var pos := _lane_center(lane, _layout()["target_y"])
	_popup("Perfect!" if perfect else "Good", Color("#FFE27A") if perfect else UiTheme.TEAL, pos)
	Snd.play("star" if perfect else "tap", 0.05)
	if perfect:
		Kit.burst(self, get_global_transform() * pos)
		flash_col = LANE_COLORS[lane]
		flash_t = 0.5
	if combo % FEVER_EVERY == 0:
		fever_t = FEVER_TIME
		score += FEVER_BONUS
		cheer = 1.0
		_popup("FEVER! +%d" % FEVER_BONUS, UiTheme.ACCENT, Vector2(size.x * 0.5, size.y * 0.3))
		Snd.play("level_up")
		Kit.burst(self, get_global_transform() * Vector2(size.x * 0.5, size.y * 0.4))


func _judge_miss(lane: int) -> void:
	combo = 0
	_popup("Miss", Color("#FF8FA8"), _lane_center(lane, _layout()["target_y"]))
	Snd.play("wrong")


func _popup(text: String, col: Color, pos: Vector2) -> void:
	_popups.append({"text": text, "col": col, "pos": pos, "age": 0.0})


func _end() -> void:
	if _done:
		return
	_done = true
	running = false
	var earned: int = preload("res://scripts/game_state.gd").payout_for(int(round(score / 3.0)))
	finished.emit(score, earned)


# --- layout ---

func _layout() -> Dictionary:
	_u = clampf(size.x / 480.0, 1.0, 2.0)
	var lane_w: float = size.x / 4.0
	var r: float = clampf(lane_w * 0.38, 28.0, 72.0)
	var pad_cy: float = size.y - r - 20.0 * _u
	return {"lane_w": lane_w, "pad_r": r, "pad_cy": pad_cy, "target_y": pad_cy - r - 16.0 * _u}


func _lane_center(lane: int, y: float) -> Vector2:
	return Vector2((float(lane) + 0.5) * size.x / 4.0, y)


func _note_y(n: Dictionary, target_y: float) -> float:
	var speed: float = (target_y + 30.0) / FALL_TIME
	return target_y + (song_t - float(n["t"])) * speed


# --- input ---

func _input(event: InputEvent) -> void:
	if not running or not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		_pointer(st.index, _local(st.position), st.pressed)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.device != InputEvent.DEVICE_ID_EMULATION:
			_pointer(-1, _local(mb.position), mb.pressed)
	elif event is InputEventKey:
		var k := event as InputEventKey
		var idx: int = [KEY_D, KEY_F, KEY_J, KEY_K].find(k.physical_keycode)
		if idx != -1 and not k.echo:
			if k.pressed:
				press_lane(idx)
			_keys_down[idx] = k.pressed


func _local(p: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * p


func _pointer(id: int, p: Vector2, pressed: bool) -> void:
	if not pressed:
		_pointers.erase(id)
		return
	if not Rect2(Vector2.ZERO, size).has_point(p) or p.y < size.y * 0.3:
		return
	var lane: int = clampi(int(p.x / (size.x / 4.0)), 0, 3)
	_pointers[id] = lane
	press_lane(lane)


# --- drawing ---

func _draw() -> void:
	var lay: Dictionary = _layout()
	var u := _u
	var calm: bool = Kit.calm()
	var t: float = 0.0 if calm else _anim
	var beat: float = 0.3
	if not calm:
		beat = pow(1.0 - fposmod(song_t, NOTE_INTERVAL) / NOTE_INTERVAL, 3.0)
	var fever: float = clampf(fever_t / FEVER_TIME, 0.0, 1.0)
	Stage.draw(self, size, t, beat, fever, float(lay["target_y"]), calm)
	_draw_lanes(lay, fever)
	_draw_notes(lay)
	_draw_pads(lay)
	_draw_hud(u, fever)
	for p in _popups:
		var k: float = float(p["age"]) / 0.8
		var rise: float = 0.0 if calm else -40.0 * u * k
		var pr := Rect2((p["pos"] as Vector2) + Vector2(-90.0 * u, -70.0 * u + rise), Vector2(180.0 * u, 36.0 * u))
		Kit.text(self, String(p["text"]), pr, 24.0 * u, Color(p["col"], 1.0 - k * 0.7))
	if flash_t > 0.0:
		_edge_flash()
	_draw_count_in(u)
	Kit.pet_cheer(self, Vector2(56.0 * u, 150.0 * u + 56.0 * u), 56.0 * u, t, cheer)


func _draw_lanes(lay: Dictionary, fever: float) -> void:
	var lw: float = lay["lane_w"]
	var ty: float = lay["target_y"]
	for l in 4:
		var c: Color = LANE_COLORS[l]
		draw_rect(Rect2(float(l) * lw + 3.0, 0.0, lw - 6.0, size.y), Color(c, 0.05 + 0.10 * float(pad_glow[l])))
		draw_rect(Rect2(float(l) * lw + lw * 0.5 - 1.5, 0.0, 3.0, ty), Color(c, 0.10))
		if float(pad_glow[l]) > 0.0:
			draw_rect(Rect2(float(l) * lw + 3.0, ty - 30.0, lw - 6.0, 36.0), Color(c, 0.45 * float(pad_glow[l])))
	var line_a: float = 0.55 + 0.4 * fever
	draw_rect(Rect2(0.0, ty - 2.0, size.x, 4.0), Color(UiTheme.TEXT, line_a))
	draw_rect(Rect2(0.0, ty - 7.0, size.x, 14.0), Color(UiTheme.TEXT, 0.10 + 0.2 * fever))


func _draw_notes(lay: Dictionary) -> void:
	var ty: float = lay["target_y"]
	var rad: float = minf(float(lay["lane_w"]) * 0.28, 34.0 * _u)
	for n in notes:
		if bool(n["done"]):
			continue
		var y: float = _note_y(n, ty)
		if y < -rad * 2.0:
			continue
		var lane: int = int(n["lane"])
		var c: Color = LANE_COLORS[lane]
		var p: Vector2 = _lane_center(lane, y)
		draw_colored_polygon(PackedVector2Array([p + Vector2(-rad * 0.8, 0.0), p + Vector2(rad * 0.8, 0.0), p + Vector2(0.0, -rad * 3.2)]), Color(c, 0.22))
		draw_circle(p, rad * 1.5, Color(c, 0.14))
		draw_circle(p, rad * 1.15, Color(c, 0.25))
		draw_circle(p, rad, c)
		draw_circle(p - Vector2(rad * 0.25, rad * 0.3), rad * 0.45, Color(1, 1, 1, 0.55))
		draw_arc(p, rad, 0.0, TAU, 28, Color(1, 1, 1, 0.8), 2.0 * _u, true)


func _draw_pads(lay: Dictionary) -> void:
	var r: float = lay["pad_r"]
	var cy: float = lay["pad_cy"]
	for l in 4:
		var c: Color = LANE_COLORS[l]
		var g: float = float(pad_glow[l])
		var p := _lane_center(l, cy)
		var rr: float = r * (1.0 - 0.06 * g)
		draw_circle(p + Vector2(0, 3.0 * _u), rr, Color(0, 0, 0, 0.35))
		if g > 0.0:
			draw_circle(p, rr + 14.0 * _u * g, Color(c, 0.25 * g))
		draw_circle(p, rr, Color(c.lerp(Color.WHITE, 0.35 * g), 0.92))
		draw_arc(p, rr - 2.0 * _u, 0.0, TAU, 36, Color(1, 1, 1, 0.5), 2.5 * _u, true)
		Kit.text(self, LANE_KEYS[l], Rect2(p - Vector2(rr, rr), Vector2(rr, rr) * 2.0), rr * 0.7, UiTheme.TEXT_ON_ACCENT)


func _draw_hud(u: float, fever: float) -> void:
	var m: float = 12.0 * u
	var pw: float = 112.0 * u
	var bar := Rect2(m, m, size.x - pw - 3.0 * m, 28.0 * u)
	Kit.pill(self, bar, Color(UiTheme.PANEL, 0.85))
	var prog: float = clampf((song_t + 0.0) / (float(notes[notes.size() - 1]["t"]) + END_TAIL), 0.0, 1.0)
	var inner := Rect2(bar.position + Vector2(10.0 * u, 9.0 * u), Vector2(bar.size.x - 20.0 * u, bar.size.y - 18.0 * u))
	draw_rect(inner, Color(0, 0, 0, 0.4))
	draw_rect(Rect2(inner.position, Vector2(inner.size.x * prog, inner.size.y)), UiTheme.ACCENT if fever > 0.0 else UiTheme.TEAL)
	draw_rect(inner, Color(1, 1, 1, 0.3), false, 1.5)
	Kit.score_pills(self, size, u, score, "Combo %d" % combo, fever > 0.0)
	if combo >= 2:
		var cr := Rect2(size.x * 0.5 - 100.0 * u, 70.0 * u, 200.0 * u, 50.0 * u)
		Kit.text(self, "%d" % combo, cr, (44.0 + 8.0 * fever) * u, Color(UiTheme.GOLD, 0.9))
	if fever > 0.0:
		Kit.text(self, "FEVER!", Rect2(size.x * 0.5 - 100.0 * u, 118.0 * u, 200.0 * u, 30.0 * u), 24.0 * u, UiTheme.ACCENT)


func _edge_flash() -> void:
	var a: float = flash_t * 0.5
	for i in 5:
		var w: float = 4.0 + float(i) * 6.0
		var c := Color(flash_col, a * (1.0 - float(i) / 5.0))
		draw_rect(Rect2(0.0, 0.0, size.x, w), c)
		draw_rect(Rect2(0.0, size.y - w, size.x, w), c)


func _draw_count_in(u: float) -> void:
	if song_t >= 0.5 or not running:
		return
	var txt := "GO!"
	if song_t < 0.0:
		txt = str(int(ceil(-song_t)))
	var frac: float = fposmod(-song_t, 1.0) if song_t < 0.0 else 0.0
	var px: float = (90.0 + (0.0 if Kit.calm() else 40.0 * frac)) * u
	Kit.text(self, txt, Rect2(0.0, size.y * 0.3, size.x, 120.0 * u), px, Color(UiTheme.TEXT, 0.95 if song_t < 0.0 else clampf((0.5 - song_t) * 2.0, 0.0, 1.0)))
