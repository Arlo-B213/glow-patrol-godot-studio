extends Control
## Alley Brawl mini-game: a scrolling beat-'em-up. Walk right through three districts, clear three
## Gloomling encounter zones (the camera locks to each arena), then defeat the boss at the far end.
## Story 025 added the world/camera (brawl_world.gd), scenery (brawl_scenery.gd, brawl_props.gd),
## controls (brawl_controls.gd), HUD (brawl_hud.gd), actor drawing (brawl_actors.gd) and the block
## mechanic with its guard meter. Story 036 split the fight into modules this view wires together:
## lane depth (brawl_lanes.gd), hunter movement/combo/hurt (brawl_player.gd), enemy AI (brawl_ai.gd,
## driven by brawl_combat.gd), the boss (brawl_boss.gd), pickups (brawl_pickups.gd) and hit-stop,
## shake, sparks and popups (brawl_fx.gd). Movement, hit distances and speeds keep their `u` scaling.
##
## Debug builds only (never active in an exported release build), launch args after `--`:
##   --brawl-boss             skip the 3 waves and start at the boss zone
##   --brawl-boss=hydra       same, but force the Hiccup Hydra (or =king); without it the boss
##                            kind alternates per run (see brawl_enemies.gd)
##   --brawl-boss-health=N    start the boss with N health (default BRAWL_BOSS_HEALTH)

signal finished(score: int, earned: int, won: bool)

const BRAWL_WAVES := 3
const BRAWL_HEARTS := 3
const BRAWL_BOSS_HEALTH := 8
## Story finale (Story 020): the Grumble King starts with a little more health, no pre-waves.
const FINALE_BOSS_HEALTH := 12
const ENEMY_COLORS := [Color("#52E8C6"), Color("#8E7CFF"), Color("#FF8B5E"), Color("#FFD36E")]

## Gameplay distances/speeds were tuned for a 480px-wide field; everything measured in pixels is
## multiplied by `u` (field width / REF_WIDTH) so combat stays consistent on a wider screen.
const REF_WIDTH := 480.0
const MAX_LAYOUT_SCALE := 2.0
## Where the floor line sits, as a fraction of the view height (hunter in the vertical middle).
const GROUND_FRACTION := 0.58
const HIT_FRAMES := 8
const DYING_FRAMES := 18
const BOSS_FLASH_FRAMES := 6
## Pixels of travel (at u = 1) per full walk cycle, and how fast the walk blends in/out per frame.
const STRIDE_PX := 56.0
const WALK_BLEND_RATE := 0.14
const STEP := 1.0 / 60.0

const World := preload("res://scenes/battle/brawl_world.gd")
const Scenery := preload("res://scenes/battle/brawl_scenery.gd")
const Combat := preload("res://scenes/battle/brawl_combat.gd")
const Player := preload("res://scenes/battle/brawl_player.gd")
const Lanes := preload("res://scenes/battle/brawl_lanes.gd")
const Boss := preload("res://scenes/battle/brawl_boss.gd")
const Pickups := preload("res://scenes/battle/brawl_pickups.gd")
const Fx := preload("res://scenes/battle/brawl_fx.gd")
const Actors := preload("res://scenes/battle/brawl_actors.gd")
const Controls := preload("res://scenes/battle/brawl_controls.gd")
const Hud := preload("res://scenes/battle/brawl_hud.gd")
const BrawlEnemies := preload("res://scripts/brawl_enemies.gd")
const BlinkerArt := preload("res://scenes/battle/brawl_art_enemies.gd")
const PetCompanion := preload("res://scenes/battle/pet_companion.gd")

const DEBUG_BOSS_ARG := "--brawl-boss"
const DEBUG_BOSS_KIND_ARG := "--brawl-boss="
const DEBUG_BOSS_HEALTH_ARG := "--brawl-boss-health="

@onready var toast: Node = get_node("/root/Toast")
@onready var game_state: Node = get_node("/root/GameState")

## Equipped outfit/hair/weapon colours for the hunter, read once at start.
var look: Dictionary = {}
## Weapon reach multiplier read once at start (GameState.weapon_reach()).
var reach: float = 1.0
var anim_t := 0
## Active-pet sidekick (null when no hatched pet); see pet_companion.gd.
var companion: RefCounted = null
var world := World.new()
var hud: Control
var controls: Control

var running := true
var ended := false
var score := 0
var hearts := BRAWL_HEARTS
var wave_num := 1
var boss_phase := false
## Index of the next encounter zone (0..2 waves, 3 boss, 4 = all done) and whether one is active.
var zone_i := 0
var in_fight := false
var secrets_found: Array = [false, false, false]

var u: float = 1.0
var player_x := 0.0
var player_vx := 0.0
## Lane depth, 0 (back) .. 1 (front), and its velocity; see brawl_lanes.gd.
var player_y: float = Lanes.START_D
var player_vy := 0.0
var player_facing := 1
var player_invincible := 0
var ground_y := 0.0
## Lane band top/height in px, refreshed on layout (Lanes.top_y / Lanes.height).
var lane_top := 0.0
var lane_h := 0.0

var punch_active := 0
var punch_cooldown := 0
var punch_id := 0
## Combo: `punch_step` is the next jab/jab/finisher index, `combo_window` the frames left to chain,
## `punch_buffer` a queued tap; `combo_count`/`combo_timer` drive the "N hits!" counter.
var punch_step := 0
var combo_window := 0
var punch_buffer := 0
var combo_count := 0
var combo_timer := 0
## Second Wind (once per run): `wind_t` counts down the comeback glow.
var second_wind_used := false
var wind_t := 0
## Block state: `block_t` eases 0..1 for the pose/shield, `block_age` counts frames since the press.
var blocking := false
var block_t := 0.0
var block_age := 999
var guard := World.GUARD_MAX
var guard_break_t := 0

var enemies: Array = []
var boss: Dictionary = {}
var boss_hit_flash := 0
var boss_max_health: int = BRAWL_BOSS_HEALTH
var debug_skip_to_boss := false
var boss_kind_forced := ""
## Set before add_child: skip the waves and fight the forced Grumble King with FINALE_BOSS_HEALTH.
var finale := false
## Visual-only horizontal recoil of the boss after a hit (px, decays).
var boss_recoil := 0.0
## Defeated enemies playing their flash + puff, see _update_dying.
var dying: Array = []
## Walk cycle phase (cycles, advanced by distance travelled) and blend (0 idle .. 1 walking).
var walk_phase := 0.0
var walk_blend := 0.0

## Heart/coin drops (brawl_pickups.gd), and the brawl_fx.gd state: hit-stop frames, shake strength
## and ticks left, this frame's shake offset, sparks and popups. `feel` holds the pause/shake tuning.
var pickups: Array = []
var feel: Resource = preload("res://scenes/battle/brawl_hit_feel.tres")
var hitstop := 0
var shake := 0.0
var shake_t := 0
var shake_off := Vector2.ZERO
var sparks: Array = []
var popups: Array = []

var spawn_queue: Array = []
var spawn_timer := 0
var particles: Array = []
var rings: Array = []

var _laid_out := false
var _view_w := 0.0
var _acc := 0.0
var _clock := 0.0
var _district := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	hud = Hud.new()
	add_child(hud)
	controls = Controls.new()
	add_child(controls)
	controls.punch_pressed.connect(_on_punch)
	look = game_state.hunter_look()
	reach = game_state.weapon_reach()
	companion = PetCompanion.create(game_state)
	_apply_debug_args()
	if finale:
		debug_skip_to_boss = true
		boss_kind_forced = "king"
		boss_max_health = FINALE_BOSS_HEALTH


## World camera x (left edge of the visible world, px).
func cam_x() -> float:
	return world.cam_x


## True when reduce motion is on: ambient and flashy effects stay still.
func calm() -> bool:
	return bool(game_state.get("reduce_motion"))


func _process(delta: float) -> void:
	if not running or size.x < 8.0:
		return
	u = clampf(size.x / REF_WIDTH, 1.0, MAX_LAYOUT_SCALE)
	ground_y = size.y * GROUND_FRACTION
	lane_top = Lanes.top_y(ground_y, size.y)
	lane_h = Lanes.height(size.y)
	if not _laid_out:
		_first_layout()
	elif absf(size.x - _view_w) > 1.0:
		_rescale(size.x / _view_w)
	if companion != null:
		var moving: bool = absf(player_vx) > 0.1
		companion.update(delta, player_x, player_facing, moving, u, player_y)
		Combat.update_companion(self)
	_clock += delta
	_acc = minf(_acc + delta, STEP * 4.0)
	while _acc >= STEP and running:
		_acc -= STEP
		if hitstop > 0:
			# Hit-stop freezes the fight for a few frames; effects keep settling.
			hitstop -= 1
			Fx.update(self)
		else:
			_tick()
	var shake_k: float = float(shake_t) / float(feel.shake_frames())
	shake_off = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * shake_k if shake_t > 0 else Vector2.ZERO
	_sync_ui()
	queue_redraw()


func _first_layout() -> void:
	_laid_out = true
	_view_w = size.x
	player_x = World.START * size.x
	world.snap(player_x, size.x)
	if debug_skip_to_boss:
		debug_skip_to_boss = false
		wave_num = BRAWL_WAVES
		zone_i = 3
		player_x = World.zone_trigger_px(3, size.x) + 4.0 * u
		world.cam_x = World.zone_lock_px(3, size.x)


## Window/layout width changed: keep everything at the same place along the world.
func _rescale(k: float) -> void:
	_view_w = size.x
	player_x *= k
	world.cam_x *= k
	if world.lock_x >= 0.0:
		world.lock_x *= k
	for e in enemies:
		e["x"] = float(e["x"]) * k
	if not boss.is_empty():
		boss["x"] = float(boss["x"]) * k
	if companion != null:
		companion.x *= k


## One fixed 60 Hz simulation step.
func _tick() -> void:
	anim_t += 1
	Player.update(self)
	if not ended and not in_fight and zone_i < World.ZONES.size() and player_x >= World.zone_trigger_px(zone_i, size.x):
		_enter_zone(zone_i)
	if in_fight and not boss_phase and not ended:
		if spawn_queue.size() > 0:
			spawn_timer -= 1
			if spawn_timer <= 0:
				_spawn_enemy(spawn_queue.pop_front())
				spawn_timer = 55
		elif enemies.is_empty():
			_zone_cleared()
	Combat.update_enemies(self)
	_update_dying()
	if not boss.is_empty():
		Boss.update(self)
	Pickups.update(self)
	_update_secrets()
	world.step(player_x, player_facing, size.x, u)
	_update_fx()
	Fx.update(self)
	var d: int = World.district_at(player_x, size.x)
	if d != _district:
		_district = d
		toast.show_message(String(World.DISTRICTS[d]["name"]))


## Walkable x range: the locked fight screen, else the whole street (px).
func bounds() -> Vector2:
	if world.lock_x >= 0.0:
		return Vector2(world.lock_x + 24.0 * u, world.lock_x + size.x - 24.0 * u)
	return Vector2(24.0 * u, World.world_w(size.x) - 24.0 * u)


## Guard ran dry: drop the block and stagger (called by brawl_player.gd).
func break_guard() -> void:
	guard = 0.0
	guard_break_t = World.GUARD_BREAK_FRAMES
	blocking = false
	Snd.play("error")


func _enter_zone(i: int) -> void:
	in_fight = true
	world.lock_x = World.zone_lock_px(i, size.x)
	spawn_timer = 20
	if i < BRAWL_WAVES:
		wave_num = i + 1
		_queue_wave(wave_num)
	else:
		_spawn_boss()


func _zone_cleared() -> void:
	in_fight = false
	world.lock_x = -1.0
	zone_i += 1
	toast.show_message("Wave cleared! Keep going!")


## Reads the debug-only launch args. Does nothing in an exported release build.
func _apply_debug_args() -> void:
	if not OS.is_debug_build():
		return
	for arg in OS.get_cmdline_user_args():
		if arg == DEBUG_BOSS_ARG:
			debug_skip_to_boss = true
		elif arg.begins_with(DEBUG_BOSS_KIND_ARG):
			debug_skip_to_boss = true
			boss_kind_forced = arg.trim_prefix(DEBUG_BOSS_KIND_ARG)
		elif arg.begins_with(DEBUG_BOSS_HEALTH_ARG):
			boss_max_health = maxi(1, int(arg.trim_prefix(DEBUG_BOSS_HEALTH_ARG)))


func _queue_wave(n: int) -> void:
	spawn_queue = []
	for i in range(3 + n):
		spawn_queue.append("left" if randf() < 0.5 else "right")


func _spawn_boss() -> void:
	boss_phase = true
	var kind: String = BrawlEnemies.next_boss_kind(boss_kind_forced)
	var lx: float = world.lock_x if world.lock_x >= 0.0 else cam_x()
	boss = Boss.make(self, kind, lx + size.x + 40.0 * u)
	toast.show_message(String(BrawlEnemies.BOSS_INTROS[kind]))


func _spawn_enemy(side: String) -> void:
	var id: String = BrawlEnemies.pick_type(wave_num, randf())
	var lx: float = world.lock_x if world.lock_x >= 0.0 else cam_x()
	var x: float = lx - 20.0 * u if side == "left" else lx + size.x + 20.0 * u
	enemies.append(BrawlEnemies.make(id, x, ENEMY_COLORS[randi() % ENEMY_COLORS.size()], randf(), randf_range(0.15, 0.85)))


## -1 or 1: the side of `other_x` that `x` is on (for knock-back directions).
func away(x: float, other_x: float) -> float:
	return -1.0 if x < other_x else 1.0


func _update_secrets() -> void:
	for i in World.SECRETS.size():
		if secrets_found[i] or absf(player_x - float(World.SECRETS[i]["x"]) * size.x) > World.SECRET_RADIUS_PX * u:
			continue
		secrets_found[i] = true
		score += World.SECRET_SCORE
		Snd.play("star")
		var at := Vector2(player_x, ground_y - 90.0 * u)
		spawn_particles(at, Color("#FFE9A0"))
		spawn_particles(at, Color("#FF9EC8"))
		rings.append({"pos": at, "t": 0, "color": Color("#FFE9A0")})
		toast.show_message("Secret spot! +%d" % World.SECRET_SCORE)


func _update_fx() -> void:
	for i in range(particles.size() - 1, -1, -1):
		var p: Dictionary = particles[i]
		p["pos"] += p["vel"]
		p["vel"].y += 0.12
		p["life"] -= 1
		if p["life"] <= 0:
			particles.remove_at(i)
	for i in range(rings.size() - 1, -1, -1):
		rings[i]["t"] += 1
		if int(rings[i]["t"]) >= 14:
			rings.remove_at(i)


## Applies one hit to enemies[i] (punch or pet zap). Survivors flash and recoil, and a combo
## `finisher` knocks them down; defeated enemies score, may drop a pickup, and move to `dying`.
## Returns true when the enemy was defeated.
func hit_enemy(i: int, by_pet: bool, from_x: float, finisher: bool = false) -> bool:
	var e: Dictionary = enemies[i]
	e["health"] = int(e["health"]) - (2 if finisher else 1)
	e["hit_t"] = HIT_FRAMES
	e["kb"] = 0.0 if calm() else away(e["x"], from_x) * (9.0 if finisher else 5.0 if int(e["health"]) > 0 else 4.0) * u
	if int(e["health"]) > 0:
		if finisher:
			e["mode"] = "down"
			e["mt"] = World.DOWN_FRAMES
		return false
	var pts: int = int(e["score"])
	score += maxi(1, pts / 2) if by_pet else pts
	dying.append({"type": e["type"], "x": e["x"], "y": e["y"], "r": e["r"], "color": e["color"], "age": e["age"],
		"kb": e["kb"], "t": 0, "toward": 1.0 if player_x > float(e["x"]) else -1.0})
	Pickups.drop(self, float(e["x"]), float(e["y"]))
	enemies.remove_at(i)
	return true


## Counts a landed punch toward the combo; from 2 hits on, pops "N hits!" at `pos`.
func register_combo_hit(pos: Vector2) -> void:
	combo_count += 1
	combo_timer = World.COMBO_RESET
	if combo_count >= 2:
		Fx.popup(self, "%d hits!" % combo_count, pos, Color("#FFE9A0"), 16.0 + minf(combo_count, 8) * 2.0)


func _update_dying() -> void:
	for i in range(dying.size() - 1, -1, -1):
		var d: Dictionary = dying[i]
		d["t"] += 1
		d["x"] += float(d["kb"])
		d["kb"] = float(d["kb"]) * 0.8
		if int(d["t"]) >= DYING_FRAMES:
			dying.remove_at(i)


## Bursts ten particles of `color` from `pos`.
func spawn_particles(pos: Vector2, color: Color) -> void:
	for i in range(10):
		var ang: float = randf() * TAU
		particles.append({"pos": pos, "vel": Vector2(cos(ang) * 3.0, sin(ang) * 3.0) * u, "life": 20, "color": color})


## Applies the pet's zap when ready: the nearest on-screen Gloomling is zapped away (+1 score) or
## the boss loses a little health (never its last point, so the pet cannot win the fight alone).
func _on_punch() -> void:
	if running:
		Player.trigger_punch(self)


## A strike from `from_x` landed (blocks are resolved by brawl_combat.gd first).
func hurt_player(from_x: float) -> void:
	Player.hurt(self, from_x)


## Ends the run once: banks the heart bonus and emits `finished`.
func end_brawl(won: bool) -> void:
	if ended:
		return
	ended = true
	running = false
	controls.active = false
	_sync_ui()
	var heart_bonus: int = hearts * 5
	score += heart_bonus
	var earned: int = preload("res://scripts/game_state.gd").payout_for(score)
	finished.emit(score, earned, won)


## Pushes the current state into the HUD and controls.
func _sync_ui() -> void:
	hud.sync_from(self, controls)


func _draw() -> void:
	var t: float = 0.0 if calm() else _clock
	Scenery.draw_back(self, cam_x(), size, ground_y, u, t, secrets_found)
	Actors.draw(self)
	Scenery.draw_fore(self, cam_x(), size, ground_y, u, t)
