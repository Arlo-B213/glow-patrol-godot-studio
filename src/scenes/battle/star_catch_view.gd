extends Control
## Star Catch mini-game: move a basket left/right to catch falling stars
## and dodge Gloomlings (catching one costs points).

signal finished(score: int, earned: int)

const CATCH_TIME := 40
const ITEM_COLORS := [Color("#52E8C6"), Color("#8E7CFF"), Color("#FF8B5E"), Color("#FFD36E")]
const BASKET_HALF_WIDTH := 34.0
const BASKET_MARGIN := 28.0
const BASKET_MOVE_SPEED := 4.0

@onready var score_label: Label = %ScoreLabel
@onready var time_label: Label = %TimeLabel
@onready var countdown_timer: Timer = %CountdownTimer
@onready var left_button: Button = %LeftButton
@onready var right_button: Button = %RightButton
@onready var toast: Node = get_node("/root/Toast")

var items: Array = []
var particles: Array = []
var score := 0
var combo := 0
var time_left := float(CATCH_TIME)
var running := true
var basket_x := 0.0
var key_left := false
var key_right := false
var flash_timer := 0
var spawn_accum := 0.0
var basket_y := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	score_label.text = "Score 0"
	time_label.text = "%ds" % CATCH_TIME
	countdown_timer.wait_time = 1.0
	countdown_timer.timeout.connect(_on_second_tick)
	countdown_timer.start()
	left_button.button_down.connect(func(): key_left = true)
	left_button.button_up.connect(func(): key_left = false)
	right_button.button_down.connect(func(): key_right = true)
	right_button.button_up.connect(func(): key_right = false)


func _process(delta: float) -> void:
	if not running:
		return
	if basket_x == 0.0:
		basket_x = size.x / 2.0
	basket_y = size.y - 100.0  # sits above the 52px ◀ ▶ controls row

	if key_left:
		basket_x -= BASKET_MOVE_SPEED
	if key_right:
		basket_x += BASKET_MOVE_SPEED
	basket_x = clamp(basket_x, BASKET_MARGIN, size.x - BASKET_MARGIN)

	spawn_accum += delta
	var interval: float = max(0.36, 0.78 - (float(CATCH_TIME) - time_left) * 0.01)
	if spawn_accum > interval:
		_spawn_item()
		spawn_accum = 0.0

	for i in range(items.size() - 1, -1, -1):
		var it: Dictionary = items[i]
		it["pos"].y += it["speed"]

		var caught: bool = abs(it["pos"].x - basket_x) < 34.0 and it["pos"].y > basket_y - 18.0 and it["pos"].y < basket_y + 18.0
		if caught:
			if it["type"] == "star":
				combo += 1
				score += 1 + int(combo / 5)
				Snd.play("star", 0.06)
				_spawn_particles(it["pos"], Color("#FFC15E"))
			else:
				combo = 0
				score = max(0, score - 3)
				flash_timer = 14
				_spawn_particles(it["pos"], Color("#8E7CFF"))
			score_label.text = "Score %d" % score
			items.remove_at(i)
			continue

		if it["pos"].y - it["r"] > size.y:
			if it["type"] == "star":
				combo = 0
			items.remove_at(i)
		else:
			items[i] = it

	for i in range(particles.size() - 1, -1, -1):
		var p: Dictionary = particles[i]
		p["pos"] += p["vel"]
		p["vel"].y += 0.12
		p["life"] -= 1
		if p["life"] <= 0:
			particles.remove_at(i)
		else:
			particles[i] = p

	if flash_timer > 0:
		flash_timer -= 1

	queue_redraw()


func _spawn_item() -> void:
	var is_star: bool = randf() < 0.7
	items.append({
		"pos": Vector2(24.0 + randf() * max(1.0, size.x - 48.0), -16.0),
		"r": 13.0 if is_star else 22.0,
		"type": "star" if is_star else "gloomling",
		"color": ITEM_COLORS[randi() % ITEM_COLORS.size()],
		"speed": 1.4 + randf() * 1.2 + min(1.6, (float(CATCH_TIME) - time_left) / 20.0),
	})


func _spawn_particles(pos: Vector2, color: Color) -> void:
	for i in range(8):
		var ang: float = randf() * TAU
		particles.append({
			"pos": pos,
			"vel": Vector2(cos(ang) * 3.0, sin(ang) * 3.0),
			"life": 18,
			"color": color,
		})


func _on_second_tick() -> void:
	if not running:
		return
	time_left -= 1.0
	time_label.text = "%ds" % int(time_left)
	if time_left <= 0:
		_end_catch()


func _end_catch() -> void:
	running = false
	countdown_timer.stop()
	var earned: int = preload("res://scripts/game_state.gd").payout_for(score)
	finished.emit(score, earned)


func _draw_star(center: Vector2, r: float, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(10):
		var rad: float = r if i % 2 == 0 else r * 0.45
		var ang: float = PI / 5.0 * i - PI / 2.0
		points.append(center + Vector2(cos(ang) * rad, sin(ang) * rad))
	draw_colored_polygon(points, color)


func _draw() -> void:
	if flash_timer > 0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 0.37, 0.635, 0.12))

	for it in items:
		if it["type"] == "star":
			_draw_star(it["pos"], it["r"], Color("#FFC15E"))
		else:
			draw_circle(it["pos"], it["r"], it["color"])

	draw_rect(Rect2(basket_x - 26.0, basket_y - 20.0, 52.0, 40.0), Color("#6C5CE7"))

	for p in particles:
		var a: float = clampf(float(p["life"]) / 18.0, 0.0, 1.0)
		var col: Color = p["color"]
		col.a = a
		draw_circle(p["pos"], 3.0, col)
