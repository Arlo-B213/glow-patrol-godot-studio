extends SceneTree
## Headless logic smoke test: pure functions only, never touches the save.
## Run: godot --headless --path src -s ../tests/smoke/logic_smoke.gd   (exit 0 = pass)

const GS := preload("res://scripts/game_state.gd")
const Arc := preload("res://scripts/story_arc.gd")
const Daily := preload("res://scripts/daily_rewards.gd")

var fails := 0


func check(cond: bool, label: String) -> void:
	if cond:
		print("ok   ", label)
	else:
		fails += 1
		print("FAIL ", label)


func _init() -> void:
	check(GS.payout_for(0) == GS.PAYOUT_MIN, "payout floor")
	check(GS.payout_for(999) == GS.PAYOUT_MAX, "payout cap")
	check(GS.payout_for(25) == 25, "payout passthrough")
	check(Arc.unlocked_count(0) == 0, "no chapters at 0 wins")
	check(Arc.unlocked_count(1) == 1, "chapter 1 at 1 win")
	check(Arc.unlocked_count(9) == Arc.CHAPTERS.size(), "all chapters at 9 wins")
	check(Arc.wins_to_next(0) == 1, "wins to next from 0")
	check(Arc.wins_to_next(99) == 0, "no wins needed when finished")
	check(Daily.daily_bonus_for(1) == 10, "daily bonus day 1")
	check(Daily.daily_bonus_for(2) == 12, "daily bonus day 2")
	check(Daily.daily_bonus_for(99) == Daily.daily_bonus_for(50), "daily bonus capped")
	check(Daily.next_streak("2026-10-06", "2026-10-07", 3) == 4, "streak continues next day")
	check(Daily.next_streak("2026-10-01", "2026-10-07", 3) == 1, "streak resets after a gap")
	check(Daily.next_streak("2026-09-30", "2026-10-01", 2) == 3, "streak across month end")
	var ids := {}
	for o in GS.OUTFITS:
		check(not ids.has(o["id"]), "unique outfit id " + String(o["id"]))
		ids[o["id"]] = true
	_check_save_round_trip()
	print("DONE fails=", fails)
	quit(1 if fails > 0 else 0)


## In-memory JSON round trip, mirroring save_game/load_game without touching user://.
func _check_save_round_trip() -> void:
	var src = GS.new()
	src.persist_saves = false
	src.tutorial_done = true
	src.streak = 4
	src.last_login_date = "2026-10-12"
	src.stickers = ["first_zap", "combo_10"]
	var parsed = JSON.parse_string(JSON.stringify(src.to_save_dict()))
	var dst = GS.new()
	dst.persist_saves = false
	dst.apply_save_dict(parsed)
	check(dst.tutorial_done == true, "save keeps tutorial_done")
	check(dst.streak == 4, "save keeps streak")
	check(dst.last_login_date == "2026-10-12", "save keeps last_login_date")
	check(dst.stickers == ["first_zap", "combo_10"], "save keeps stickers")
	src.free()
	dst.free()
