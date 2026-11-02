extends GdUnitTestSuite
## Lounge mission data is well formed and matches the Lanternboys and the question subjects.

const M := preload("res://scripts/lounge_missions.gd")
const GS := preload("res://scripts/game_state.gd")
const SUBJECTS := ["math", "grammar", "reading"]


func test_mission_ids_are_unique() -> void:
	var seen := {}
	for m in M.MISSIONS:
		assert_bool(seen.has(m["id"])).is_false()
		seen[m["id"]] = true


func test_every_mission_is_well_formed() -> void:
	var boy_ids := []
	for boy in GS.LANTERNBOYS:
		boy_ids.append(boy["id"])
	for m in M.MISSIONS:
		assert_bool(boy_ids.has(m["boy"])).is_true()
		assert_int(int(m["grade"])).is_between(1, 5)
		assert_int(int(m["needs_affection"])).is_greater_equal(0)
		assert_bool(m["subjects"].is_empty()).is_false()
		for s in m["subjects"]:
			assert_bool(SUBJECTS.has(s)).is_true()
		for w in m["quiz_after_waves"]:
			assert_int(int(w)).is_between(1, 3)


func test_every_boy_has_a_place_and_missions() -> void:
	for boy in GS.LANTERNBOYS:
		assert_bool(M.PLACES.has(boy["id"])).is_true()
		assert_bool(M.for_boy(boy["id"]).is_empty()).is_false()


func test_missions_open_by_friendship() -> void:
	var first: Dictionary = M.by_id("bridge-1")
	var locked: Dictionary = M.by_id("bridge-2")
	assert_bool(M.is_open(first, 0)).is_true()
	assert_bool(M.is_open(locked, 0)).is_false()
	assert_bool(M.is_open(locked, int(locked["needs_affection"]))).is_true()


func test_affection_reward_is_bigger_for_a_win() -> void:
	assert_int(M.affection_reward(true)).is_greater(M.affection_reward(false))
	assert_int(M.affection_reward(false)).is_greater(0)
