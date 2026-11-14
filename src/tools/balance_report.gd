extends SceneTree
## Prints the economy numbers from GameState and DailyRewards so design/balance.md can be checked
## against the code. Read-only; never touches the save. Run headless:
##   godot --headless --path src -s res://tools/balance_report.gd

const GS := preload("res://scripts/game_state.gd")
const Daily := preload("res://scripts/daily_rewards.gd")


func _init() -> void:
	var outfit_total := 0
	for o in GS.OUTFITS:
		outfit_total += int(o["cost"])
	var weapon_total := 0
	for w in GS.WEAPONS:
		weapon_total += int(w["cost"])
	print("outfits: n=%d total=%d min=%d max=%d" % [GS.OUTFITS.size(), outfit_total,
		_min_cost(GS.OUTFITS), _max_cost(GS.OUTFITS)])
	print("weapons: n=%d total=%d min=%d max=%d" % [GS.WEAPONS.size(), weapon_total,
		_min_cost(GS.WEAPONS), _max_cost(GS.WEAPONS)])
	print("pets: n=%d" % GS.PETS.size())
	print("payout: min=%d max=%d  examples score 0/5/16/25/99 -> %d %d %d %d %d" % [
		GS.PAYOUT_MIN, GS.PAYOUT_MAX, GS.payout_for(0), GS.payout_for(5), GS.payout_for(16),
		GS.payout_for(25), GS.payout_for(99)])
	var bonus_line := ""
	for d in [1, 2, 3, 5, 7, 10, 14, 30, 50, 99]:
		bonus_line += " d%d=%d" % [d, Daily.daily_bonus_for(d)]
	print("daily bonus:" + bonus_line)
	print("daily bonus cap=%d (doc suggests 20)" % Daily.daily_bonus_for(99))
	print("doc claims: shop outfits 870 + weapons 510 = 1380; code outfits %d + weapons %d = %d" % [
		outfit_total, weapon_total, outfit_total + weapon_total])
	print("DONE")
	quit()


func _min_cost(list: Array) -> int:
	var m := 1 << 30
	for x in list:
		if int(x["cost"]) > 0:
			m = mini(m, int(x["cost"]))
	return m


func _max_cost(list: Array) -> int:
	var m := 0
	for x in list:
		m = maxi(m, int(x["cost"]))
	return m
