extends SceneTree
## Bot playtest of Alley Brawl: a simple policy walks toward the nearest foe (or the boss) in both
## lane depth and x, and punches when in reach. Runs seeded full runs (three waves, then the boss)
## and prints outcomes so difficulty and pacing can be checked without a human. Never touches the
## save. Run headless:
##   godot --headless --path src -s res://tools/brawl_bot_playtest.gd -- <runs>

const VIEW := preload("res://scenes/battle/alley_brawl_view.tscn")
const Player := preload("res://scenes/battle/brawl_player.gd")
const World := preload("res://scenes/battle/brawl_world.gd")
const BOT_CONTROLS := preload("res://tools/brawl_bot_controls.gd")
const MAX_FRAMES := 30000


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var runs: int = int(args[0]) if args.size() > 0 else 5
	var mission_id: String = args[1] if args.size() > 1 else ""
	await process_frame
	var gs: Node = root.get_node("GameState")
	gs.persist_saves = false
	gs.tutorial_done = true
	var wins := 0
	for r in runs:
		seed(1000 + r)
		var view: Control = VIEW.instantiate()
		view.mission = LoungeMissions.by_id(mission_id)
		view.set_anchors_preset(Control.PRESET_FULL_RECT)
		root.add_child(view)
		await process_frame
		view.controls.set_script(BOT_CONTROLS)
		var punches := 0
		var quizzes := 0
		var outcome := "timeout"
		var won_flag := [false]
		view.finished.connect(func(_s: int, _e: int, w: bool): won_flag[0] = w)
		var f := 0
		while f < MAX_FRAMES:
			await process_frame
			f += 1
			if view.quiz_card != null:
				view._on_quiz_done(randf() < 0.8)
				quizzes += 1
				continue
			if view.ended:
				outcome = "won" if won_flag[0] else "lost"
				break
			var goal: Vector2 = _goal(view)
			var dx: float = goal.x - view.player_x
			var dy: float = goal.y - view.player_y
			var mx: float = 0.0 if absf(dx) < 40.0 * view.u else signf(dx)
			var my: float = 0.0 if absf(dy) < 0.05 else signf(dy)
			view.controls.move = Vector2(mx, my)
			var near: bool = absf(dx) < World.PUNCH_REACH * view.u * 0.9 and absf(dy) < 0.05
			if near and view.punch_cooldown <= 0:
				Player.trigger_punch(view)
				punches += 1
		if outcome == "timeout":
			for e in view.enemies:
				print("  left enemy x=%.0f y=%.2f mode=%s" % [float(e["x"]), float(e["y"]), String(e["mode"])])
			print("  player_x=%.0f player_y=%.2f lock_x=%.0f cam_x=%.0f queue=%d zone=%d" % [view.player_x, view.player_y, view.world.lock_x, view.cam_x(), view.spawn_queue.size(), view.zone_i])
		print("run %d seed=%d outcome=%s frames=%d score=%d hearts=%d punches=%d quizzes=%d zone=%d boss_left=%s" % [
			r, 1000 + r, outcome, f, view.score, view.hearts, punches, quizzes, view.zone_i,
			str(not view.boss.is_empty())])
		if won_flag[0]:
			wins += 1
		view.free()
		await process_frame
	print("wins %d / %d" % [wins, runs])
	print("DONE")
	quit()


## The bot's goal: the boss when it is out, otherwise the nearest living foe (x and lane depth).
func _goal(view: Control) -> Vector2:
	if not view.boss.is_empty():
		return Vector2(float(view.boss["x"]), float(view.boss["y"]))
	var best := INF
	var goal := Vector2(view.player_x, view.player_y)
	for e in view.enemies:
		if String(e["mode"]) == "down":
			continue
		var d: float = absf(float(e["x"]) - view.player_x) + absf(float(e["y"]) - view.player_y) * view.lane_h * 1.5
		if d < best:
			best = d
			goal = Vector2(float(e["x"]), float(e["y"]))
	if best == INF:
		var z: int = mini(view.zone_i, World.ZONES.size() - 1)
		return Vector2(World.zone_trigger_px(z, view.size.x) + 10.0 * view.u, view.player_y)
	return goal
