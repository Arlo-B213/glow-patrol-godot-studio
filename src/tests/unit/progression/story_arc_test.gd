extends GdUnitTestSuite
## Story chapters unlock with Alley Brawl / Zap Patrol wins (story_arc.gd).

const Arc := preload("res://scripts/story_arc.gd")


func test_no_chapters_at_zero_wins() -> void:
	assert_int(Arc.unlocked_count(0)).is_equal(0)


func test_first_chapter_at_one_win() -> void:
	assert_int(Arc.unlocked_count(1)).is_equal(1)


func test_all_chapters_at_nine_wins() -> void:
	assert_int(Arc.unlocked_count(9)).is_equal(Arc.CHAPTERS.size())


func test_wins_to_next_from_zero() -> void:
	assert_int(Arc.wins_to_next(0)).is_equal(1)


func test_no_wins_needed_when_finished() -> void:
	assert_int(Arc.wins_to_next(99)).is_equal(0)
