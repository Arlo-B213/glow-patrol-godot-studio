extends GdUnitTestSuite
## Daily login bonus and streak rules (Story 022).

const Daily := preload("res://scripts/daily_rewards.gd")


func test_daily_bonus_day_one() -> void:
	assert_int(Daily.daily_bonus_for(1)).is_equal(10)


func test_daily_bonus_day_two() -> void:
	assert_int(Daily.daily_bonus_for(2)).is_equal(12)


func test_daily_bonus_is_capped() -> void:
	assert_int(Daily.daily_bonus_for(99)).is_equal(Daily.daily_bonus_for(50))
	assert_int(Daily.daily_bonus_for(99)).is_equal(20)


func test_streak_continues_next_day() -> void:
	assert_int(Daily.next_streak("2026-10-06", "2026-10-07", 3)).is_equal(4)


func test_streak_resets_after_gap() -> void:
	assert_int(Daily.next_streak("2026-10-01", "2026-10-07", 3)).is_equal(1)


func test_streak_crosses_month_end() -> void:
	assert_int(Daily.next_streak("2026-09-30", "2026-10-01", 2)).is_equal(3)
