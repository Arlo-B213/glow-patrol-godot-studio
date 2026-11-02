extends GdUnitTestSuite
## Finishing a Lounge mission pays the stars, counts the mission, raises affection and returns to the Club
## on the Lounge tab.

const MAIN := preload("res://scenes/main.tscn")


func test_finished_mission_pays_and_returns_to_lounge() -> void:
	var gs: Node = get_node("/root/GameState")
	gs.persist_saves = false
	gs.tutorial_done = true
	var stars_before: int = gs.star_points
	var main: Node = auto_free(MAIN.instantiate())
	add_child(main)
	await get_tree().process_frame
	main.start_mission(LoungeMissions.by_id("steps-1"))
	var view: Control = main.content_area.get_children().back()
	view.end_brawl(true)
	await get_tree().process_frame
	assert_int(int(gs.mission_done["steps-1"])).is_equal(1)
	assert_int(int(gs.affection["bit"])).is_greater(0)
	assert_int(gs.star_points).is_greater(stars_before)
	assert_bool(gs.open_lounge_on_club).is_false()
	assert_str(main.current_screen_name).is_equal("club")
