extends GdUnitTestSuite
## Haptics dispatcher (Story 040): events map to durations, the toggle silences them, and the vibration
## call is injected so no device is needed.

const H := preload("res://scripts/haptics.gd")
const GS := preload("res://scripts/game_state.gd")

var sent: Array = []
var _old_sink: Callable
var _old_enabled := true


func _record(ms: int) -> void:
	sent.append(ms)


func before_test() -> void:
	_old_sink = H.sink
	_old_enabled = H.enabled
	H.sink = Callable(self, "_record")
	H.enabled = true
	sent.clear()


func after_test() -> void:
	H.sink = _old_sink
	H.enabled = _old_enabled


func test_each_event_sends_its_duration() -> void:
	assert_int(H.pulse("enemy_hit")).is_equal(H.DURATIONS["enemy_hit"])
	assert_int(H.pulse("zap_strike")).is_equal(H.DURATIONS["zap_strike"])
	assert_array(sent).is_equal([H.DURATIONS["enemy_hit"], H.DURATIONS["zap_strike"]])


func test_toggle_off_sends_nothing() -> void:
	H.enabled = false
	assert_int(H.pulse("enemy_hit")).is_equal(0)
	assert_bool(sent.is_empty()).is_true()


func test_unknown_event_sends_nothing() -> void:
	assert_int(H.pulse("no_such_event")).is_equal(0)
	assert_bool(sent.is_empty()).is_true()


func test_big_star_grant_pulses_but_small_does_not() -> void:
	var gs: Node = auto_free(GS.new())
	gs.persist_saves = false
	gs.earn_points(H.SP_BURST_MIN - 1)
	assert_bool(sent.is_empty()).is_true()
	gs.earn_points(H.SP_BURST_MIN)
	assert_array(sent).is_equal([H.DURATIONS["sp_burst"]])


func test_reduce_motion_turns_haptics_off() -> void:
	var gs: Node = auto_free(GS.new())
	gs.persist_saves = false
	gs.set_haptics(true)
	gs.set_reduce_motion(true)
	assert_bool(gs.haptics_on).is_false()
	assert_bool(H.enabled).is_false()


func test_default_sink_is_safe_off_device() -> void:
	H.sink = Callable(H, "_vibrate")
	assert_int(H.pulse("enemy_hit")).is_equal(H.DURATIONS["enemy_hit"])
