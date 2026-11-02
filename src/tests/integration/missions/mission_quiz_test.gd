extends GdUnitTestSuite
## A Lounge mission pauses the Alley Brawl run for a quiz after the chosen wave, and a right answer
## heals and scores while a wrong one costs a heart.

const VIEW := preload("res://scenes/battle/alley_brawl_view.tscn")


func _view_with_mission(mission: Dictionary) -> Control:
	var gs: Node = get_node("/root/GameState")
	gs.persist_saves = false
	var view: Control = VIEW.instantiate()
	view.mission = mission
	view.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(view)
	return view


func test_quiz_opens_after_chosen_wave_and_right_answer_helps() -> void:
	var view := _view_with_mission({"id": "test", "boy": "hae", "grade": 1, "subjects": ["math"], "quiz_after_waves": [1]})
	await get_tree().process_frame
	view.hearts = 1
	view._zone_cleared()
	assert_object(view.quiz_card).is_not_null()
	view._on_quiz_done(true)
	assert_object(view.quiz_card).is_null()
	assert_int(view.hearts).is_equal(2)
	view.queue_free()


func test_wrong_answer_costs_a_heart() -> void:
	var view := _view_with_mission({"id": "test", "boy": "bit", "grade": 3, "subjects": ["reading"], "quiz_after_waves": [1]})
	await get_tree().process_frame
	var before: int = view.hearts
	view._zone_cleared()
	view._on_quiz_done(false)
	assert_int(view.hearts).is_equal(before - 1)
	view.queue_free()


func test_no_quiz_for_a_normal_brawl() -> void:
	var view := _view_with_mission({})
	await get_tree().process_frame
	view._zone_cleared()
	assert_object(view.quiz_card).is_null()
	view.queue_free()


func test_correct_answers_add_stars_on_finish() -> void:
	var view := _view_with_mission({"id": "test", "boy": "nun", "grade": 1, "subjects": ["math"], "quiz_after_waves": [1]})
	await get_tree().process_frame
	view._zone_cleared()
	view._on_quiz_done(true)
	var paid: Array = []
	view.finished.connect(func(_s: int, earned: int, _w: bool): paid.append(earned))
	view.end_brawl(true)
	var gs: Node = get_node("/root/GameState")
	assert_int(paid[0]).is_equal(gs.payout_for(view.score) + LoungeMissions.STARS_PER_CORRECT)
	view.queue_free()
