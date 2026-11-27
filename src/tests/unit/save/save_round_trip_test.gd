extends GdUnitTestSuite
## Save dictionary round trips, mirroring save_game/load_game without touching user:// (Story 051 AC-1).

const GS := preload("res://scripts/game_state.gd")


func _fresh() -> Node:
	var gs: Node = auto_free(GS.new())
	gs.persist_saves = false
	return gs


func test_progress_survives_round_trip() -> void:
	var src := _fresh()
	src.tutorial_done = true
	src.streak = 4
	src.last_login_date = "2026-10-12"
	src.stickers = ["first_zap", "combo_10"]
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(src.to_save_dict()))
	var dst := _fresh()
	dst.apply_save_dict(parsed)
	assert_bool(dst.tutorial_done).is_true()
	assert_int(dst.streak).is_equal(4)
	assert_str(dst.last_login_date).is_equal("2026-10-12")
	assert_array(dst.stickers).is_equal(["first_zap", "combo_10"])


func test_settings_survive_round_trip() -> void:
	var src := _fresh()
	src.haptics_on = false
	src.colour_palette = "deutan"
	src.dyslexia_font = true
	src.reduce_motion = true
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(src.to_save_dict()))
	var dst := _fresh()
	dst.apply_save_dict(parsed)
	assert_bool(dst.haptics_on).is_false()
	assert_str(dst.colour_palette).is_equal("deutan")
	assert_bool(dst.dyslexia_font).is_true()
	assert_bool(dst.reduce_motion).is_true()


func test_unknown_palette_falls_back_to_off() -> void:
	var src := _fresh()
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(src.to_save_dict()))
	parsed["colour_palette"] = "rainbow"
	var dst := _fresh()
	dst.apply_save_dict(parsed)
	assert_str(dst.colour_palette).is_equal("off")
