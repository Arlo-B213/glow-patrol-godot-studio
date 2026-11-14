extends GdUnitTestSuite
## The outfit catalogue must have unique ids (saves refer to outfits by id).

const GS := preload("res://scripts/game_state.gd")


func test_outfit_ids_are_unique() -> void:
	var seen := {}
	for o in GS.OUTFITS:
		assert_bool(seen.has(o["id"])).is_false()
		seen[o["id"]] = true
