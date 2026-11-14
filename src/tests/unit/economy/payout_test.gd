extends GdUnitTestSuite
## Stars paid per Alley Brawl / Zap Patrol run (design/balance.md, Story 019).

const GS := preload("res://scripts/game_state.gd")


func test_payout_floor() -> void:
	assert_int(GS.payout_for(0)).is_equal(GS.PAYOUT_MIN)


func test_payout_cap() -> void:
	assert_int(GS.payout_for(999)).is_equal(GS.PAYOUT_MAX)


func test_payout_passes_through_in_range() -> void:
	assert_int(GS.payout_for(25)).is_equal(25)


func test_payout_examples_from_balance_doc() -> void:
	assert_int(GS.payout_for(5)).is_equal(10)
	assert_int(GS.payout_for(16)).is_equal(16)
	assert_int(GS.payout_for(99)).is_equal(40)
