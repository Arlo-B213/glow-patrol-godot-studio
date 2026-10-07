extends RefCounted
## Alley Brawl enemy data (Story 021): the Gloomling variants and the boss kinds. Pure data and
## small helpers; the view owns combat. Tune speed/health/score/size/weights here.
##
## `weights` is the spawn weight per wave (index 0 = wave 1; later waves reuse the last entry), so
## wave 1 is Gloomlings only. `speed` = base px/frame at 480px width (+ random 0..`speed_var`).
## `score` is points for a punch defeat (a pet zap gives score/2, minimum 1); payouts still go
## through GameState.payout_for, which caps them.

const ENEMY_TYPES := {
	"gloomling": {"speed": 1.1, "speed_var": 0.5, "health": 1, "score": 2, "size": 26.0, "weights": [10, 8, 6], "color": null},
	"blinker": {"speed": 1.5, "speed_var": 0.35, "health": 1, "score": 3, "size": 17.0, "weights": [0, 3, 4], "color": Color("#6FE7FF")},
	"mossback": {"speed": 0.7, "speed_var": 0.15, "health": 2, "score": 4, "size": 34.0, "weights": [0, 1, 3], "color": Color("#7BC96F")},
}

const BOSS_KINDS := ["king", "hydra"]
const BOSS_NAMES := {"king": "GRUMBLE KING", "hydra": "HICCUP HYDRA"}
const BOSS_INTROS := {"king": "The Grumble King blocks the alley!", "hydra": "The Hiccup Hydra hiccups into the alley!"}

## Boss runs started this session; alternates the boss kind (king first). Session-only on purpose.
static var boss_runs := 0


## Picks an enemy type id for `wave` (1-based) from the spawn weights; `roll` is 0..1.
static func pick_type(wave: int, roll: float) -> String:
	var total := 0.0
	for id in ENEMY_TYPES:
		total += _weight(id, wave)
	var acc := 0.0
	var target: float = clampf(roll, 0.0, 0.9999) * total
	for id in ENEMY_TYPES:
		acc += _weight(id, wave)
		if target < acc:
			return id
	return "gloomling"


static func _weight(id: String, wave: int) -> float:
	var w: Array = ENEMY_TYPES[id]["weights"]
	return float(w[clampi(wave - 1, 0, w.size() - 1)])


## Boss kind for the next boss fight: alternates per run unless `forced` is a valid kind.
static func next_boss_kind(forced: String = "") -> String:
	if BOSS_KINDS.has(forced):
		return forced
	var kind: String = BOSS_KINDS[boss_runs % BOSS_KINDS.size()]
	boss_runs += 1
	return kind


## Starting enemy dictionary. `fallback_color` is used for types without a fixed colour.
static func make(id: String, x: float, fallback_color: Color, speed_roll: float) -> Dictionary:
	var d: Dictionary = ENEMY_TYPES[id]
	var col: Color = fallback_color if d["color"] == null else d["color"]
	return {
		"type": id, "x": x, "r": float(d["size"]), "speed": float(d["speed"]) + speed_roll * float(d["speed_var"]),
		"health": int(d["health"]), "score": int(d["score"]), "color": col,
		"hit_punch_id": -1, "bump_cooldown": 0, "age": 0, "hit_t": 0, "kb": 0.0,
	}
