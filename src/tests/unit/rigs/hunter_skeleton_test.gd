extends GdUnitTestSuite
## Side-view hunter joints: geometry checks on the named skeleton (hunter_skeleton.gd).

const Skel := preload("res://scripts/hunter_skeleton.gd")

const BASE := Vector2(300, 600)
const U := 1.0


func _rest_pose() -> Dictionary:
	return {"hurt": 0.0, "stance_x": 7.0, "spread": 0.0, "foot_a": Vector2.ZERO,
		"foot_b": Vector2.ZERO, "ang": 1.1, "back_arm": 0.04, "head_dy": 0.0}


func test_head_sits_above_body_at_rest() -> void:
	# Arrange / Act
	var j := Skel.side_joints(BASE, U, 1.0, _rest_pose(), 0.0, 0.0, 0.0, 9.0)
	# Assert
	assert_float((j["head"] as Vector2).y).is_less((j["body"] as Vector2).y)


func test_facing_left_mirrors_horizontal_joints() -> void:
	# Arrange / Act
	var right := Skel.side_joints(BASE, U, 1.0, _rest_pose(), 0.0, 0.0, 0.0, 9.0)
	var left := Skel.side_joints(BASE, U, -1.0, _rest_pose(), 0.0, 0.0, 0.0, 9.0)
	# Assert: the shoulder and head sit mirrored about the feet point
	var dx_right: float = (right["shoulder"] as Vector2).x - BASE.x
	var dx_left: float = (left["shoulder"] as Vector2).x - BASE.x
	assert_float(dx_left).is_equal_approx(-dx_right, 0.001)
	var hx_right: float = (right["head"] as Vector2).x - BASE.x
	var hx_left: float = (left["head"] as Vector2).x - BASE.x
	assert_float(hx_left).is_equal_approx(-hx_right, 0.001)


func test_hand_is_one_arm_length_from_shoulder() -> void:
	# Arrange / Act
	var j := Skel.side_joints(BASE, U, 1.0, _rest_pose(), 0.0, 0.0, 0.0, 9.0)
	# Assert
	var reach: float = (j["hand"] as Vector2).distance_to(j["shoulder"] as Vector2)
	assert_float(reach).is_equal_approx(24.0 * U, 0.001)


func test_planted_feet_sit_on_the_ground_line() -> void:
	# Arrange / Act
	var j := Skel.side_joints(BASE, U, 1.0, _rest_pose(), 0.0, 0.0, 0.0, 9.0)
	# Assert: with no lift both feet sit 4 units above the base line
	assert_float((j["foot_a"] as Vector2).y).is_equal_approx(BASE.y - 4.0 * U, 0.001)
	assert_float((j["foot_b"] as Vector2).y).is_equal_approx(BASE.y - 4.0 * U, 0.001)
