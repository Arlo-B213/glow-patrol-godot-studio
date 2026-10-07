extends Node
## Audio engine (Story 018). Autoload name: `Sfx`. All sound is synthesized in code.
## Honors GameState.sound_on (read live, plus refresh() for immediate stop/restart).

const POOL_SIZE := 8
const SFX_RATE := 16000
const SFX_PEAK := 0.6
const SFX_DB := -3.0
const MUSIC_DB := -14.0
const FADE_S := 0.5
const SILENT_DB := -60.0

## Milliseconds spent generating all SFX at _ready (for measurement).
var gen_ms: float = 0.0

var _sfx: Dictionary = {}
var _music: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _pool_next: int = 0
var _mus: Array[AudioStreamPlayer] = []
var _mus_cur: int = 0
var _playing_track: String = ""
var _wanted_track: String = ""
var _tweens: Array = [null, null]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.volume_db = SFX_DB
		add_child(p)
		_pool.append(p)
	for i in 2:
		var m := AudioStreamPlayer.new()
		m.volume_db = SILENT_DB
		add_child(m)
		_mus.append(m)
	var t0: int = Time.get_ticks_usec()
	for id in SfxSynth.RECIPES.keys():
		_sfx[id] = SfxSynth.render_sfx(id, SFX_RATE, SFX_PEAK)
	gen_ms = float(Time.get_ticks_usec() - t0) / 1000.0
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.points_earned.connect(_on_points_earned)
		gs.leveled_up.connect(func(_lv: int): play("level_up"))


var _last_coin_ms: int = 0


func _on_points_earned(_amount: int) -> void:
	# Throttle so a burst of awards is one chime, not a machine gun.
	var now: int = Time.get_ticks_msec()
	if now - _last_coin_ms > 150:
		_last_coin_ms = now
		play("coin")


## Whether sound is currently enabled (GameState.sound_on, default true if absent).
func is_sound_on() -> bool:
	var gs: Node = get_node_or_null("/root/GameState")
	if gs == null:
		return true
	var v: Variant = gs.get("sound_on")
	return true if v == null else bool(v)


## Play a sound effect by id (tap, back, punch, hit, enemy_defeat, boss_hit, star, coin,
## level_up, high_five, chapter, win, lose, eat, pet_happy, grow, error, whoosh,
## correct, wrong). `pitch_jitter` randomizes pitch by +/- that fraction. Unknown ids ignored.
func play(sfx_name: String, pitch_jitter: float = 0.0) -> void:
	if not is_sound_on() or _pool.is_empty() or not _sfx.has(sfx_name):
		return
	var p: AudioStreamPlayer = null
	for i in POOL_SIZE:
		var c: AudioStreamPlayer = _pool[(_pool_next + i) % POOL_SIZE]
		if not c.playing:
			p = c
			_pool_next = (_pool_next + i + 1) % POOL_SIZE
			break
	if p == null:  # all busy: steal the next one round-robin
		p = _pool[_pool_next]
		_pool_next = (_pool_next + 1) % POOL_SIZE
	p.stream = _sfx[sfx_name]
	p.pitch_scale = 1.0 + (randf_range(-pitch_jitter, pitch_jitter) if pitch_jitter > 0.0 else 0.0)
	p.play()


## Start a looping music track (hq, battle, games, study, club, pets, story, win) with a
## cross-fade. Does nothing if that track is already playing. Generated lazily on first use.
func play_music(track: String) -> void:
	if not MusicTracks.has_track(track):
		return
	_wanted_track = track
	if not is_sound_on() or _mus.is_empty():
		return
	if track == _playing_track and _mus[_mus_cur].playing:
		return
	if not _music.has(track):
		_music[track] = MusicTracks.render(track)
	var old: int = _mus_cur
	_mus_cur = 1 - _mus_cur
	_playing_track = track
	var nw: AudioStreamPlayer = _mus[_mus_cur]
	_kill_tween(_mus_cur)
	nw.stream = _music[track]
	nw.volume_db = SILENT_DB
	nw.play()
	_fade(_mus_cur, MUSIC_DB, false)
	_fade(old, SILENT_DB, true)


## Fade out and stop the current music; remembers nothing to restart.
func stop_music() -> void:
	_wanted_track = ""
	_playing_track = ""
	for i in _mus.size():
		_fade(i, SILENT_DB, true)


## Call when the Sound toggle changes: silences everything when off, restarts music when on.
func refresh() -> void:
	if not is_sound_on():
		_playing_track = ""
		for i in 2:
			_kill_tween(i)
			if i < _mus.size():
				_mus[i].stop()
		for p in _pool:
			p.stop()
	elif _wanted_track != "":
		var t: String = _wanted_track
		_playing_track = ""
		play_music(t)


func _fade(idx: int, to_db: float, stop_after: bool) -> void:
	var pl: AudioStreamPlayer = _mus[idx]
	if not pl.playing:
		return
	_kill_tween(idx)
	var tw: Tween = create_tween()
	tw.tween_property(pl, "volume_db", to_db, FADE_S)
	if stop_after:
		tw.tween_callback(pl.stop)
	_tweens[idx] = tw


func _kill_tween(idx: int) -> void:
	var tw: Variant = _tweens[idx]
	if tw != null and (tw as Tween).is_valid():
		(tw as Tween).kill()
	_tweens[idx] = null
