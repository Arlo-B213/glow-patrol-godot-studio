extends SceneTree
## Headless check that a punch landed in reach hurts the Alley Brawl boss and triggers hit feedback
## (hit pause or shake). Runs the real view for a bounded number of frames, punching only when the
## boss is in reach. Never touches the save.
## Run: godot --headless --path src -s ../tests/smoke/brawl_punch_smoke.gd   (exit 0 = pass)

const VIEW := preload("res://scenes/battle/alley_brawl_view.tscn")
const Player := preload("res://scenes/battle/brawl_player.gd")
const World := preload("res://scenes/battle/brawl_world.gd")
const MAX_FRAMES := 900

var fails := 0


func check(cond: bool, label: String) -> void:
	if cond:
		print("ok   ", label)
	else:
		fails += 1
		print("FAIL ", label)


func _init() -> void:
	await process_frame
	var gs: Node = root.get_node("GameState")
	gs.persist_saves = false
	gs.tutorial_done = true
	gs.reduce_motion = false
	var view: Control = VIEW.instantiate()
	view.debug_skip_to_boss = true
	view.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(view)
	var start_health := -1
	var punches := 0
	var saw_feedback := false
	var end_health := -1
	for f in MAX_FRAMES:
		await process_frame
		if view.boss.is_empty():
			continue
		if start_health < 0:
			start_health = int(view.boss["health"])
		var in_reach: bool = absf(float(view.boss["x"]) - view.player_x) < World.BOSS_REACH * view.u
		if in_reach and view.punch_cooldown <= 0:
			Player.trigger_punch(view)
			punches += 1
		if int(view.hitstop) > 0 or float(view.shake) > 0.0:
			saw_feedback = true
		end_health = int(view.boss["health"])
		if end_health <= start_health - 2:
			break
	check(start_health > 0, "boss spawns with health (%d)" % start_health)
	check(punches > 0, "hunter throws a punch in reach (punches=%d)" % punches)
	check(end_health >= 0 and end_health < start_health, "a landed punch lowers boss health (%d -> %d)" % [start_health, end_health])
	check(saw_feedback, "a landed punch triggers hit pause or shake")
	view.free()
	print("DONE fails=", fails)
	quit(1 if fails > 0 else 0)
