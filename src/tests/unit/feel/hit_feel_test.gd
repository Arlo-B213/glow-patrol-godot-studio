extends GdUnitTestSuite
## Hit pause and screen shake tuning, and their stacking rules (Story 036).

const Fx := preload("res://scenes/battle/brawl_fx.gd")
const FEEL_PATH := "res://scenes/battle/brawl_hit_feel.tres"


## Minimal stand-in for the Alley Brawl view: only the fields brawl_fx.gd touches.
class FakeView:
	var feel: Resource
	var reduce := false
	var u := 1.0
	var hitstop := 0
	var shake := 0.0
	var shake_t := 0
	var sparks: Array = []
	var popups: Array = []
	func calm() -> bool:
		return reduce


var feel: Resource


func before() -> void:
	feel = load(FEEL_PATH)


func test_feel_resource_exists() -> void:
	assert_object(feel).is_not_null()


func test_hit_pause_lasts_60_to_80_ms() -> void:
	var ms: float = feel.pause_frames(false) * 1000.0 / 60.0
	assert_float(ms).is_between(60.0, 80.0)


func test_reduce_motion_pause_is_short() -> void:
	var calm_ms: float = feel.pause_frames(true) * 1000.0 / 60.0
	assert_float(calm_ms).is_greater(0.0)
	assert_float(calm_ms).is_less_equal(40.0)


func test_shake_grows_with_damage() -> void:
	assert_float(feel.shake_px(2, false)).is_greater(feel.shake_px(1, false))


func test_shake_is_capped() -> void:
	assert_float(feel.shake_px(99, false)).is_equal(feel.shake_max)


func test_reduce_motion_turns_shake_off() -> void:
	assert_float(feel.shake_px(2, true)).is_equal(0.0)


func test_shake_settles_in_about_point_one_five_seconds() -> void:
	var shake_s: float = feel.shake_frames() / 60.0
	assert_float(absf(shake_s - 0.15)).is_less(0.02)


func test_three_hits_in_one_frame_do_not_stack() -> void:
	var v := FakeView.new()
	v.feel = feel
	for i in 3:
		Fx.hit_feedback(v, 1)
	assert_int(v.hitstop).is_equal(feel.pause_frames(false))
	assert_float(v.shake).is_equal(feel.shake_px(1, false))


func test_shake_returns_to_rest() -> void:
	var v := FakeView.new()
	v.feel = feel
	Fx.hit_feedback(v, 1)
	for i in feel.shake_frames():
		Fx.update(v)
	assert_float(v.shake).is_equal(0.0)
	assert_int(v.shake_t).is_equal(0)


func test_reduce_motion_has_no_shake_and_short_pause() -> void:
	var c := FakeView.new()
	c.feel = feel
	c.reduce = true
	Fx.hit_feedback(c, 2)
	assert_float(c.shake).is_equal(0.0)
	assert_int(c.hitstop).is_equal(feel.pause_frames(true))
