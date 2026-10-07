extends Control
## Zap Patrol mini-game: tap falling Gloomlings before they float off-screen.
## A boss (Grumble King) appears partway through and takes 5 hits.

signal finished(score: int, earned: int)

const BATTLE_TIME := 45
const BOSS_HEALTH := 5
const BOSS_APPEAR_AT := 20.0
const DEMON_COLORS := [Color("#52E8C6"), Color("#8E7CFF"), Color("#FF8B5E"), Color("#FFD36E")]

@onready var score_label: Label = %ScoreLabel
@onready var time_label: Label = %TimeLabel
@onready var countdown_timer: Timer = %CountdownTimer
@onready var toast: Node = get_node("/root/Toast")

var demons: Array = []
var particles: Array = []
var boss: Dictionary = {}
var score := 0
var combo := 0
var time_left := float(BATTLE_TIME)
var running := true
## Weapon reach multiplier read once at start (GameState.weapon_reach()); widens the tap radius.
var reach: float = 1.0
var boss_spawned := false
var boss_flash := 0
var spawn_accum := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	reach = get_node("/root/GameState").weapon_reach()
	score_label.text = "Score 0"
	time_label.text = "%ds" % BATTLE_TIME
	countdown_timer.wait_time = 1.0
	countdown_timer.timeout.connect(_on_second_tick)
	countdown_timer.start()


func _process(delta: float) -> void:
	if not running:
		return
	spawn_accum += delta
	var interval: float = max(0.42, 0.95 - (float(BATTLE_TIME) - time_left) * 0.014)
	if spawn_accum > interval:
		_spawn_demon()
		spawn_accum = 0.0

	if not boss_spawned and (float(BATTLE_TIME) - time_left) >= BOSS_APPEAR_AT:
		_spawn_boss()
		boss_spawned = true

	for i in range(demons.size() - 1, -1, -1):
		var d: Dictionary = demons[i]
		d["wobble"] += 0.05
		d["pos"].y -= d["speed"]
		d["pos"].x += sin(d["wobble"]) * 0.6
		if d["pos"].y < -d["r"]:
			demons.remove_at(i)
			combo = 0
		else:
			demons[i] = d

	if not boss.is_empty():
		boss["wobble"] += 0.04
		boss["pos"].y -= boss["speed"]
		boss["pos"].x += sin(boss["wobble"]) * 0.4
		boss["pos"].x = clamp(boss["pos"].x, boss["r"], size.x - boss["r"])
		if boss["pos"].y < -boss["r"] - 30.0:
			toast.show_message("The Grumble King slipped away...")
			boss = {}

	for i in range(particles.size() - 1, -1, -1):
		var p: Dictionary = particles[i]
		p["pos"] += p["vel"]
		p["vel"].y += 0.12
		p["life"] -= 1
		if p["life"] <= 0:
			particles.remove_at(i)
		else:
			particles[i] = p

	if boss_flash > 0:
		boss_flash -= 1

	queue_redraw()


func _spawn_demon() -> void:
	var r: float = 20.0 + randf() * 14.0
	demons.append({
		"pos": Vector2(r + randf() * max(1.0, size.x - 2.0 * r), size.y + r),
		"r": r,
		"speed": 0.55 + randf() * 0.6 + min(1.2, time_left / 60.0),
		"color": DEMON_COLORS[randi() % DEMON_COLORS.size()],
		"wobble": randf() * TAU,
	})


func _spawn_boss() -> void:
	boss = {
		"pos": Vector2(size.x / 2.0, size.y + 60.0),
		"r": 46.0,
		"speed": 0.3,
		"health": BOSS_HEALTH,
		"wobble": randf() * TAU,
	}
	toast.show_message("The Grumble King appears!")


func _spawn_particles(pos: Vector2, color: Color) -> void:
	for i in range(10):
		var ang: float = randf() * TAU
		particles.append({
			"pos": pos,
			"vel": Vector2(cos(ang) * 3.0, sin(ang) * 3.0),
			"life": 22,
			"color": color,
		})


func _on_second_tick() -> void:
	if not running:
		return
	time_left -= 1.0
	time_label.text = "%ds" % int(time_left)
	if time_left <= 0:
		_end_battle()


func _gui_input(event: InputEvent) -> void:
	if not running:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_tap(event.position)


func _handle_tap(pos: Vector2) -> void:
	if not boss.is_empty():
		var bd: Vector2 = pos - boss["pos"]
		if bd.length_squared() <= boss["r"] * boss["r"] * 1.3 * reach * reach:
			boss["health"] -= 1
			Snd.play("boss_hit", 0.05)
			boss_flash = 6
			_spawn_particles(boss["pos"], Color("#7C3AED"))
			if boss["health"] <= 0:
				_spawn_particles(boss["pos"], Color("#FF5FA2"))
				_spawn_particles(boss["pos"], Color("#FFC15E"))
				score += 15
				score_label.text = "Score %d" % score
				toast.show_message("Grumble King defeated! +15")
				boss = {}
			return

	for i in range(demons.size() - 1, -1, -1):
		var d: Dictionary = demons[i]
		var dd: Vector2 = pos - d["pos"]
		if dd.length_squared() <= d["r"] * d["r"] * 1.4 * reach * reach:
			_spawn_particles(d["pos"], d["color"])
			demons.remove_at(i)
			combo += 1
			Snd.play("enemy_defeat", 0.08)
			score += 1 + int(combo / 5)
			score_label.text = "Score %d" % score
			break


func _end_battle() -> void:
	running = false
	countdown_timer.stop()
	var earned: int = preload("res://scripts/game_state.gd").payout_for(score)
	finished.emit(score, earned)


func _draw() -> void:
	for d in demons:
		draw_circle(d["pos"], d["r"], d["color"])
	if not boss.is_empty():
		var boss_color: Color = Color("#FFFFFF") if boss_flash > 0 else Color("#7C3AED")
		draw_circle(boss["pos"], boss["r"], boss_color)
		var bar_w := 120.0
		var bar_x: float = boss["pos"].x - bar_w / 2.0
		var bar_y: float = boss["pos"].y - boss["r"] - 30.0
		draw_rect(Rect2(bar_x, bar_y, bar_w, 10.0), Color(1.0, 1.0, 1.0, 0.15))
		draw_rect(Rect2(bar_x, bar_y, bar_w * (float(boss["health"]) / float(BOSS_HEALTH)), 10.0), Color("#FF5FA2"))
		draw_string(ThemeDB.fallback_font, Vector2(bar_x, bar_y - 8.0), "GRUMBLE KING", HORIZONTAL_ALIGNMENT_LEFT, bar_w, 11, Color("#F5EFFF"))
	for p in particles:
		var a: float = clampf(float(p["life"]) / 22.0, 0.0, 1.0)
		var col: Color = p["color"]
		col.a = a
		draw_circle(p["pos"], 3.0, col)
