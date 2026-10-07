extends Control
## Rhythm Tap mini-game: notes fall down four lanes — tap the matching
## lane button when a note crosses the target line.

signal finished(score: int, earned: int)

const LANE_COLORS := [Color("#FF5FA2"), Color("#FFC15E"), Color("#52E8C6"), Color("#8E7CFF")]
const NOTE_SPEED := 192.0
const TOTAL_NOTES := 26
const NOTE_INTERVAL_MS := 620
const FIRST_NOTE_MS := 900

@onready var score_label: Label = %ScoreLabel
@onready var judge_label: Label = %JudgeLabel
@onready var lane_buttons: Array = [%LaneD, %LaneF, %LaneJ, %LaneK]

var chart: Array = []
var notes: Array = []
var elapsed_ms := 0.0
var target_y := 0.0
var score := 0
var running := true


func _ready() -> void:
	for i in range(TOTAL_NOTES):
		chart.append({"lane": randi() % 4, "t": FIRST_NOTE_MS + i * NOTE_INTERVAL_MS})
	score_label.text = "Score 0"
	judge_label.text = "Get ready…"
	for i in range(4):
		lane_buttons[i].button_down.connect(_try_hit.bind(i))


func _process(delta: float) -> void:
	if not running:
		return
	elapsed_ms += delta * 1000.0
	target_y = size.y - 60.0

	while chart.size() > 0 and chart[0]["t"] <= elapsed_ms:
		var c: Dictionary = chart.pop_front()
		notes.append({"lane": c["lane"], "y": -20.0})

	for i in range(notes.size() - 1, -1, -1):
		var n: Dictionary = notes[i]
		n["y"] += NOTE_SPEED * delta
		if n["y"] - target_y > 40.0:
			notes.remove_at(i)
			judge_label.text = "Miss"
		else:
			notes[i] = n

	if chart.is_empty() and notes.is_empty():
		_end_rhythm()
		return

	queue_redraw()


func _try_hit(lane: int) -> void:
	if not running:
		return
	var best: int = -1
	var best_dist: float = 9999.0
	for i in range(notes.size()):
		var n: Dictionary = notes[i]
		if int(n["lane"]) != lane:
			continue
		var dist: float = abs(n["y"] - target_y)
		if dist < best_dist:
			best_dist = dist
			best = i
	if best != -1 and best_dist < 46.0:
		notes.remove_at(best)
		var gained: int = 3 if best_dist < 16.0 else 1
		score += gained
		Snd.play("star" if gained == 3 else "tap", 0.05)
		score_label.text = "Score %d" % score
		judge_label.text = "Perfect!" if gained == 3 else "Good"
	else:
		judge_label.text = "Miss"


func _end_rhythm() -> void:
	running = false
	var earned: int = preload("res://scripts/game_state.gd").payout_for(int(round(score / 3.0)))
	finished.emit(score, earned)


func _draw() -> void:
	var lane_w: float = size.x / 4.0
	for l in range(4):
		draw_rect(Rect2(l * lane_w, 0.0, lane_w - 4.0, size.y), Color(1.0, 1.0, 1.0, 0.04))
	draw_rect(Rect2(0.0, target_y, size.x, 3.0), Color(0.961, 0.937, 1.0, 0.5))

	for n in notes:
		var lane: int = int(n["lane"])
		var cx: float = lane * lane_w + lane_w / 2.0
		var note_w: float = lane_w * 0.72
		draw_rect(Rect2(cx - note_w / 2.0, n["y"] - 12.0, note_w, 24.0), LANE_COLORS[lane])
