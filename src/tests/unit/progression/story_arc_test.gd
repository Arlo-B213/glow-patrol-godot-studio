extends GdUnitTestSuite
## The Dimming Streets (act 1): chapter order, triggers, card text, the quiz gate, and the claim
## engine (GameState.check_story). Persistence is off so the real save file is never touched.

const Arc := preload("res://scripts/story_arc.gd")
const GameStateScript := preload("res://scripts/game_state.gd")
const ChapterQuizScript := preload("res://scenes/ui/chapter_quiz.gd")

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


func test_eleven_chapters_through_act_three_opener() -> void:
	assert_int(Arc.CHAPTERS.size()).is_equal(11)


func test_chapter_six_waits_for_chapter_five() -> void:
	var gs := _fresh_state()
	assert_bool(Arc.trigger_met(Arc.CHAPTERS[5], gs)).is_false()
	gs.chapters_done.append("ch5_stage_light")
	assert_bool(Arc.trigger_met(Arc.CHAPTERS[5], gs)).is_true()


func test_chapter_ids_are_unique() -> void:
	var seen: Dictionary = {}
	for ch in Arc.CHAPTERS:
		assert_bool(seen.has(ch["id"])).is_false()
		seen[ch["id"]] = true


func test_every_line_fits_the_dialogue_box() -> void:
	for ch in Arc.CHAPTERS:
		for line in ch["lines"]:
			assert_int(String(line).length()).is_less_equal(120)


func test_quiz_grades_are_within_one_to_five() -> void:
	for ch in Arc.CHAPTERS:
		assert_int(int(ch["quiz_grade"])).is_between(1, 5)


func test_each_chapter_quiz_has_three_reading_questions() -> void:
	for ch in Arc.CHAPTERS:
		assert_int(StudyQuestions.round_for("reading", int(ch["quiz_grade"])).size()).is_equal(3)


func test_quiz_passes_with_two_right_answers() -> void:
	assert_bool(ChapterQuizScript.passed(1)).is_false()
	assert_bool(ChapterQuizScript.passed(2)).is_true()


func test_chapter_one_needs_a_lounge_visit() -> void:
	var gs := _fresh_state()
	assert_bool(Arc.trigger_met(Arc.CHAPTERS[0], gs)).is_false()
	gs.lounge_visited = true
	assert_bool(Arc.trigger_met(Arc.CHAPTERS[0], gs)).is_true()


func test_brawl_trigger_counts_wins() -> void:
	var gs := _fresh_state()
	gs.story_wins = 0
	assert_bool(Arc.trigger_met(Arc.CHAPTERS[1], gs)).is_false()
	gs.story_wins = 1
	assert_bool(Arc.trigger_met(Arc.CHAPTERS[1], gs)).is_true()


func test_affection_trigger_uses_that_boys_friendship() -> void:
	var gs := _fresh_state()
	gs.affection["hae"] = 20
	assert_bool(Arc.trigger_met(Arc.CHAPTERS[2], gs)).is_true()
	assert_bool(Arc.trigger_met(Arc.CHAPTERS[3], gs)).is_false()


func test_card_text_joins_the_lines() -> void:
	var text := Arc.text_of(Arc.CHAPTERS[0])
	assert_str(text).contains("Look at this, patrol.")
	assert_str(text).contains("Pudding Lane.")


func test_hint_names_the_trigger() -> void:
	assert_str(Arc.trigger_hint(Arc.CHAPTERS[0])).contains("Lounge")
	assert_str(Arc.trigger_hint(Arc.CHAPTERS[2])).contains("Hae")


func test_nothing_claimed_at_start() -> void:
	var gs := _fresh_state()
	assert_array(gs.check_story(true)).is_empty()
	assert_int(gs.story_claimed).is_equal(0)


func test_first_chapter_claims_on_lounge_visit_and_pays_once() -> void:
	var gs := _fresh_state()
	var stars_before: int = gs.star_points
	var fresh: Array = gs.mark_lounge_visit()
	assert_int(fresh.size()).is_equal(1)
	assert_int(gs.star_points).is_equal(stars_before + Arc.REWARD_PER_CHAPTER)
	assert_array(gs.mark_lounge_visit()).is_empty()


func test_chapter_two_waits_for_chapter_one_quiz() -> void:
	var gs := _fresh_state()
	gs.mark_lounge_visit()
	assert_array(gs.record_battle_win()).is_empty()
	var fresh: Array = gs.complete_chapter("ch1_missing_lantern")
	assert_int(fresh.size()).is_equal(1)
	assert_str(String(fresh[0]["id"])).is_equal("ch2_dancing_clue")


func test_completing_a_chapter_twice_pays_nothing() -> void:
	var gs := _fresh_state()
	gs.mark_lounge_visit()
	gs.complete_chapter("ch1_missing_lantern")
	var stars: int = gs.star_points
	assert_array(gs.complete_chapter("ch1_missing_lantern")).is_empty()
	assert_int(gs.star_points).is_equal(stars)


func test_old_save_migrates_without_repeat_payouts() -> void:
	var gs := _fresh_state()
	var stars_before: int = gs.star_points
	gs.apply_save_dict({"story_wins": 3, "story_claimed": 2, "affection": {"hae": 0, "bit": 0, "nun": 0}})
	assert_bool(gs.lounge_visited).is_true()
	assert_int(gs.story_claimed).is_equal(2)
	assert_int(gs.chapters_done.size()).is_equal(2)
	assert_int(gs.star_points).is_equal(stars_before)
