class_name Stickers
extends RefCounted
## Sticker collection (Story 022): data table, condition checks and badge drawing.
## Conditions use only existing GameState fields and are cheap to re-check.

## id, name, icon (UiIcon name), color, kind + n (see `_met`), hint shown while locked.
const STICKERS := [
	{"id": "first_win", "name": "First Patrol", "icon": "battle", "color": Color("#FF5FA2"), "kind": "story_wins", "n": 1, "hint": "Win your first battle"},
	{"id": "high_fives", "name": "High Fives", "icon": "friendship", "color": Color("#FFC15E"), "kind": "affection_total", "n": 20, "hint": "Hang out with the Lanternboys a few times"},
	{"id": "first_pet", "name": "Hatchling", "icon": "paw", "color": Color("#52E8C6"), "kind": "pet_stage", "n": 1, "hint": "Hatch your first pet"},
	{"id": "pet_pal", "name": "Pet Pal", "icon": "heart", "color": Color("#FF5FA2"), "kind": "pets_owned", "n": 2, "hint": "Adopt two pets"},
	{"id": "stars_100", "name": "Star Collector", "icon": "star", "color": Color("#FFC15E"), "kind": "total_earned", "n": 100, "hint": "Earn 100 stars in total"},
	{"id": "stars_300", "name": "Star Hoarder", "icon": "star", "color": Color("#8E7CFF"), "kind": "total_earned", "n": 300, "hint": "Earn 300 stars in total"},
	{"id": "level_3", "name": "Rising Trainee", "icon": "level", "color": Color("#52E8C6"), "kind": "level", "n": 3, "hint": "Reach level 3"},
	{"id": "level_6", "name": "Bright Hunter", "icon": "level", "color": Color("#FF5FA2"), "kind": "level", "n": 6, "hint": "Reach level 6"},
	{"id": "streak_3", "name": "Glow Streak", "icon": "lantern", "color": Color("#FFC15E"), "kind": "streak", "n": 3, "hint": "Visit 3 days in a row"},
	{"id": "quiz_perfect", "name": "Quiz Whiz", "icon": "study", "color": Color("#8E7CFF"), "kind": "quiz_perfect", "n": 1, "hint": "Get every answer right in a lesson"},
	{"id": "chapter_3", "name": "Story Fan", "icon": "reading", "color": Color("#52E8C6"), "kind": "story_claimed", "n": 3, "hint": "Reach chapter 3 of the story"},
	{"id": "outfits_3", "name": "Fashion Star", "icon": "outfit", "color": Color("#FF5FA2"), "kind": "outfits", "n": 3, "hint": "Collect 3 outfits"},
	{"id": "game_play", "name": "Game Time", "icon": "music", "color": Color("#52E8C6"), "kind": "games_played", "n": 3, "hint": "Try 3 different mini-games"},
]

## Questions per study round, used for the "perfect quiz" test (matches study_screen).
const QUIZ_LENGTH := {"study_math": 8, "study_grammar": 5, "study_reading": 3}
const GAME_KEYS := ["rhythm", "memory", "catch", "lantern", "brawl", "battle"]


## True when sticker condition (kind, n) holds for `gs` (a GameState or look-alike).
static func _met(kind: String, n: int, gs: Object) -> bool:
	match kind:
		"story_wins":
			return int(gs.get("story_wins")) >= n
		"story_claimed":
			return int(gs.get("story_claimed")) >= n
		"total_earned":
			return int(gs.get("total_earned")) >= n
		"level":
			return int(gs.call("level_for_xp", int(gs.get("total_earned")))) >= n
		"streak":
			return int(gs.get("streak")) >= n
		"outfits":
			return (gs.get("unlocked_outfits") as Array).size() >= n
		"pets_owned":
			return (gs.get("owned_pets") as Dictionary).size() >= n
		"affection_total":
			var t := 0
			for v in (gs.get("affection") as Dictionary).values():
				t += int(v)
			return t >= n
		"pet_stage":
			for id in (gs.get("owned_pets") as Dictionary).keys():
				if int(gs.call("pet_stage", id)) >= n:
					return true
			return false
		"quiz_perfect":
			var best: Dictionary = gs.get("best_scores")
			for key in QUIZ_LENGTH.keys():
				if int(best.get(key, 0)) >= int(QUIZ_LENGTH[key]):
					return true
			return false
		"games_played":
			var played := 0
			for key in GAME_KEYS:
				if int((gs.get("best_scores") as Dictionary).get(key, 0)) > 0:
					played += 1
			return played >= n
	return false


## Ids of every sticker whose condition holds right now (earned or not). Pure.
static func met_ids(gs: Object) -> Array:
	var out: Array = []
	for s in STICKERS:
		if _met(String(s["kind"]), int(s["n"]), gs):
			out.append(s["id"])
	return out


## Awards newly met stickers: appends to gs.stickers, saves, and returns the new sticker
## dictionaries (empty when nothing changed). Cheap enough to call on any event.
static func check(gs: Object) -> Array:
	var have: Array = gs.get("stickers")
	var fresh: Array = []
	for s in STICKERS:
		if have.has(s["id"]):
			continue
		if _met(String(s["kind"]), int(s["n"]), gs):
			have.append(s["id"])
			fresh.append(s)
	if not fresh.is_empty():
		gs.call("save_game")
	return fresh
