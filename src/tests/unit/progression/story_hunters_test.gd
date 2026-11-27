extends GdUnitTestSuite
## Fellow hunters (StoryHunters): locked until chapter 5 is finished, then playable through
## GameState.hunter_look().

const GameStateScript := preload("res://scripts/game_state.gd")
const BrawlMoves := preload("res://scenes/battle/brawl_moves.gd")

var _states: Array = []


func after_test() -> void:
	for gs in _states:
		gs.free()
	_states.clear()


func _fresh_state() -> Object:
	var gs: Object = GameStateScript.new()
	gs.persist_saves = false
	_states.append(gs)
	return gs


## Finishes every chapter in order, meeting each trigger first.
func _finish_act_one(gs: Object) -> void:
	gs.lounge_visited = true
	gs.story_wins = 5
	gs.affection = {"hae": 100, "bit": 100, "nun": 100}
	for ch in StoryArc.CHAPTERS:
		gs.complete_chapter(String(ch["id"]))


func test_you_are_always_unlocked() -> void:
	assert_bool(StoryHunters.unlocked(_fresh_state(), "glow")).is_true()


func test_juno_is_locked_at_the_start() -> void:
	var gs := _fresh_state()
	assert_bool(StoryHunters.unlocked(gs, "juno")).is_false()
	assert_bool(gs.set_active_hunter("juno")).is_false()
	assert_str(gs.active_hunter).is_equal("glow")


func test_juno_unlocks_when_chapter_five_is_finished() -> void:
	var gs := _fresh_state()
	_finish_act_one(gs)
	assert_bool(StoryHunters.unlocked(gs, "juno")).is_true()
	assert_bool(gs.set_active_hunter("juno")).is_true()


func test_active_juno_changes_the_hunter_look() -> void:
	var gs := _fresh_state()
	_finish_act_one(gs)
	gs.set_active_hunter("juno")
	assert_object(gs.hunter_look()["outfit"]).is_equal(StoryHunters.look("juno")["outfit"])


func test_base_look_ignores_the_fellow_hunter_pick() -> void:
	var gs := _fresh_state()
	_finish_act_one(gs)
	gs.set_active_hunter("juno")
	assert_object(gs.base_look()["outfit"]).is_not_equal(StoryHunters.look("juno")["outfit"])


func test_hint_names_chapter_five() -> void:
	assert_str(StoryHunters.hint("juno")).contains("Stage Light")


func test_bit_unlocks_after_chapter_two() -> void:
	var gs := _fresh_state()
	gs.chapters_done = ["ch1_missing_lantern", "ch2_dancing_clue"]
	assert_bool(StoryHunters.unlocked(gs, "bit")).is_true()
	assert_bool(StoryHunters.unlocked(gs, "hae")).is_false()


func test_hae_and_nun_unlock_at_their_chapters() -> void:
	var gs := _fresh_state()
	gs.chapters_done = ["ch1_missing_lantern", "ch2_dancing_clue", "ch3_rooftop_promise"]
	assert_bool(StoryHunters.unlocked(gs, "hae")).is_true()
	assert_bool(StoryHunters.unlocked(gs, "nun")).is_false()
	gs.chapters_done.append("ch4_moths_said")
	assert_bool(StoryHunters.unlocked(gs, "nun")).is_true()


func test_each_lanternboy_has_one_move() -> void:
	assert_str(String(StoryHunters.move_of("hae")["id"])).is_equal("lantern_swing")
	assert_str(String(StoryHunters.move_of("bit")["id"])).is_equal("encore_spin")
	assert_str(String(StoryHunters.move_of("nun")["id"])).is_equal("moth_ward")
	assert_bool(StoryHunters.move_of("juno").is_empty()).is_true()
	assert_bool(StoryHunters.move_of("glow").is_empty()).is_true()


func test_hint_for_hae_names_chapter_three() -> void:
	assert_str(StoryHunters.hint("hae")).contains("chapter 3")
	assert_str(StoryHunters.hint("hae")).contains("Rooftop Promise")


func test_move_ready_ratio_runs_from_full_to_empty() -> void:
	assert_float(BrawlMoves.ready_ratio(0)).is_equal(1.0)
	assert_float(BrawlMoves.ready_ratio(BrawlMoves.COOLDOWN)).is_equal(0.0)


func test_pearl_unlocks_after_chapter_eleven() -> void:
	var gs := _fresh_state()
	gs.chapters_done = ["ch10_tower_gate"]
	assert_bool(StoryHunters.unlocked(gs, "pearl")).is_false()
	gs.chapters_done.append("ch11_grumble_stairs")
	assert_bool(StoryHunters.unlocked(gs, "pearl")).is_true()
	assert_bool(StoryHunters.move_of("pearl").is_empty()).is_true()
