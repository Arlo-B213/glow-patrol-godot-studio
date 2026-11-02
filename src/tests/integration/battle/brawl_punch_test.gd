extends GdUnitTestSuite
## A punch in reach lowers the Alley Brawl boss and triggers hit feedback (hit pause or shake).
## Runs the real view for a bounded number of frames, punching only when the boss is in reach.

const VIEW := preload("res://scenes/battle/alley_brawl_view.tscn")
const Player := preload("res://scenes/battle/brawl_player.gd")
const World := preload("res://scenes/battle/brawl_world.gd")
const MAX_FRAMES := 900


func test_landed_punch_hurts_boss_with_feedback() -> void:
	var gs: Node = get_node("/root/GameState")
	gs.persist_saves = false
	gs.tutorial_done = true
	gs.reduce_motion = false
	var view: Control = VIEW.instantiate()
	view.debug_skip_to_boss = true
	view.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(view)
	var start_health := -1
	var punches := 0
	var saw_feedback := false
	var end_health := -1
	for f in MAX_FRAMES:
		await get_tree().process_frame
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
	assert_int(start_health).is_greater(0)
	assert_int(punches).is_greater(0)
	assert_int(end_health).is_less(start_health)
	assert_bool(saw_feedback).is_true()
	view.queue_free()
