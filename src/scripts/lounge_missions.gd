class_name LoungeMissions
extends RefCounted
## Lounge missions (data): each Lanternboy has a place on the clubhouse map and missions there.
## A mission is an Alley Brawl run that pauses for Study Hall questions after the waves listed in
## `quiz_after_waves` (1-based). `needs_affection` gates it behind friendship. Rewards: Star Points
## through GameState.payout_for, and affection (+6 on a win, +2 on a loss). Values are data, not code.

const MISSIONS := [
	{"id": "bridge-1", "boy": "hae", "place": "Lantern Bridge", "title": "Bridge Patrol", "grade": 2,
		"subjects": ["math"], "quiz_after_waves": [1, 2], "needs_affection": 0},
	{"id": "bridge-2", "boy": "hae", "place": "Lantern Bridge", "title": "Night Shift", "grade": 4,
		"subjects": ["math", "grammar"], "quiz_after_waves": [1, 3], "needs_affection": 5},
	{"id": "steps-1", "boy": "bit", "place": "Dance Steps", "title": "Warm-Up Routine", "grade": 3,
		"subjects": ["reading"], "quiz_after_waves": [1], "needs_affection": 0},
	{"id": "steps-2", "boy": "bit", "place": "Dance Steps", "title": "Showcase", "grade": 5,
		"subjects": ["grammar", "reading"], "quiz_after_waves": [1, 2, 3], "needs_affection": 5},
	{"id": "garden-1", "boy": "nun", "place": "Moth Garden", "title": "Lantern Count", "grade": 1,
		"subjects": ["math"], "quiz_after_waves": [1, 2], "needs_affection": 0},
	{"id": "garden-2", "boy": "nun", "place": "Moth Garden", "title": "Storytime", "grade": 4,
		"subjects": ["reading"], "quiz_after_waves": [2, 3], "needs_affection": 5},
]

const PLACES := {"hae": "Lantern Bridge", "bit": "Dance Steps", "nun": "Moth Garden"}
const AFFECTION_WIN := 6
const AFFECTION_LOSS := 2
## Extra Star Points per correct quiz answer in a mission, on top of the capped brawl payout.
const STARS_PER_CORRECT := 1


## Every mission for one Lanternboy, in listed order.
static func for_boy(boy_id: String) -> Array:
	var out: Array = []
	for m in MISSIONS:
		if m["boy"] == boy_id:
			out.append(m)
	return out


## The mission with this id, or an empty dictionary.
static func by_id(mission_id: String) -> Dictionary:
	for m in MISSIONS:
		if m["id"] == mission_id:
			return m
	return {}


## Whether the player's affection for the boy is high enough to start the mission.
static func is_open(mission: Dictionary, affection: int) -> bool:
	return affection >= int(mission["needs_affection"])


## Affection gained for finishing a mission.
static func affection_reward(won: bool) -> int:
	return AFFECTION_WIN if won else AFFECTION_LOSS
