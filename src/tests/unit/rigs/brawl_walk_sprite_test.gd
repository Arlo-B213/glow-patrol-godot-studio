extends GdUnitTestSuite
## Brawl walk sprite: scale from the brawl's hunter scale, and the animation chosen for a state and facing.

const BrawlWalkSprite := preload("res://scripts/rigs/brawl_walk_sprite.gd")


func test_scale_for_brawl_unit_is_point_four_four_of_it() -> void:
	# Arrange / Act
	var s: float = BrawlWalkSprite.scale_for(10.0)

	# Assert
	assert_float(s).is_equal_approx(4.4, 0.0001)


func test_animation_for_moving_facing_right_is_walk_east() -> void:
	# Arrange / Act
	var anim: Array = BrawlWalkSprite.animation_for(true, 1)

	# Assert
	assert_str(anim[0]).is_equal("walk")
	assert_str(anim[1]).is_equal("east")


func test_animation_for_still_facing_left_is_idle_west() -> void:
	# Arrange / Act
	var anim: Array = BrawlWalkSprite.animation_for(false, -1)

	# Assert
	assert_str(anim[0]).is_equal("idle")
	assert_str(anim[1]).is_equal("west")
