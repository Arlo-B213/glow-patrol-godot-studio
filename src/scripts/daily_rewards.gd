class_name DailyRewards
extends RefCounted
## Daily Glow Bonus and streak (Story 022). Pure date maths plus a thin claim step.
## Never punishing: missing days only resets the streak counter, stars are kept.

const BASE_BONUS := 10          ## stars on a streak of 1
const STREAK_STEP := 2          ## extra stars per streak day beyond the first
const MAX_STREAK_STEPS := 5     ## cap on the extra steps (so the max bonus is 20)


## Stars granted for a daily claim on `streak` (>= 1): 10 + 2 * min(streak - 1, 5).
static func daily_bonus_for(streak: int) -> int:
	return BASE_BONUS + STREAK_STEP * mini(maxi(streak - 1, 0), MAX_STREAK_STEPS)


## Whole days from date string `a` to `b` ("YYYY-MM-DD"); 0 when either is invalid.
static func days_between(a: String, b: String) -> int:
	if a.length() < 10 or b.length() < 10:
		return 0
	var ua := Time.get_unix_time_from_datetime_string(a.substr(0, 10) + "T12:00:00")
	var ub := Time.get_unix_time_from_datetime_string(b.substr(0, 10) + "T12:00:00")
	return int(round(float(ub - ua) / 86400.0))


## Streak that a claim on `today` would have: +1 when `last_date` was yesterday,
## otherwise 1 (first ever claim, or a gap). Same-day returns the current streak.
static func next_streak(last_date: String, today: String, streak: int) -> int:
	if last_date == "":
		return 1
	var gap := days_between(last_date, today)
	if gap <= 0:
		return maxi(streak, 1)
	return maxi(streak, 0) + 1 if gap == 1 else 1


## True when a bonus is waiting for `today` (nothing was claimed today yet).
static func is_due(last_date: String, today: String) -> bool:
	return last_date != today


## Describes the pending bonus {"streak": int, "bonus": int}, or {} when already claimed today.
static func pending(gs: Object, today: String = "") -> Dictionary:
	var day := today if today != "" else Time.get_date_string_from_system()
	if not is_due(str(gs.get("last_login_date")), day):
		return {}
	var s := next_streak(str(gs.get("last_login_date")), day, int(gs.get("streak")))
	return {"streak": s, "bonus": daily_bonus_for(s), "date": day}


## Grants a pending bonus (from `pending`) once: updates date/streak and stars.
## Returns false when it was already claimed (so it can never pay twice a day).
static func claim(gs: Object, info: Dictionary) -> bool:
	if info.is_empty() or str(gs.get("last_login_date")) == str(info["date"]):
		return false
	gs.set("last_login_date", str(info["date"]))
	gs.set("streak", int(info["streak"]))
	gs.call("earn_points", int(info["bonus"]))
	gs.call("save_game")
	return true
