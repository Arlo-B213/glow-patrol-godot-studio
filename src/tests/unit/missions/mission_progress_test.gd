extends GdUnitTestSuite
## Finishing a Lounge mission counts it, raises affection, and survives a save round trip.

const GS := preload("res://scripts/game_state.gd")
const M := preload("res://scripts/lounge_missions.gd")


func _fresh() -> Node:
	var gs: Node = auto_free(GS.new())
	gs.persist_saves = false
	return gs


func test_win_counts_and_raises_affection() -> void:
	var gs := _fresh()
	var gained: int = gs.record_mission("bridge-1", true)
	assert_int(gained).is_equal(M.AFFECTION_WIN)
	assert_int(int(gs.mission_done["bridge-1"])).is_equal(1)
	assert_int(int(gs.affection["hae"])).is_equal(M.AFFECTION_WIN)


func test_loss_counts_and_raises_affection_less() -> void:
	var gs := _fresh()
	var gained: int = gs.record_mission("steps-1", false)
	assert_int(gained).is_equal(M.AFFECTION_LOSS)
	assert_int(int(gs.affection["bit"])).is_equal(M.AFFECTION_LOSS)


func test_unknown_mission_changes_nothing() -> void:
	var gs := _fresh()
	assert_int(gs.record_mission("no-such-mission", true)).is_equal(0)
	assert_bool(gs.mission_done.is_empty()).is_true()


func test_mission_progress_survives_round_trip() -> void:
	var src := _fresh()
	src.record_mission("garden-1", true)
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(src.to_save_dict()))
	var dst := _fresh()
	dst.apply_save_dict(parsed)
	assert_int(int(dst.mission_done["garden-1"])).is_equal(1)
	assert_int(int(dst.affection["nun"])).is_equal(M.AFFECTION_WIN)
