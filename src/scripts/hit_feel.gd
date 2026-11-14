extends Resource
## Hit feel tuning for Alley Brawl (Story 036): the hit pause and screen shake on every landed hit.
## Values live in res://scenes/battle/brawl_hit_feel.tres; tune them there, not in code.
##   pause:  frames = round(ms / 1000 * 60); reduce motion caps ms at `calm_pause_ms`.
##   shake:  px (at u = 1) = min(shake_per_damage * damage, shake_max); 0 with reduce motion.
##           It eases from full strength to rest over `shake_time` seconds.

const TICKS_PER_SECOND := 60.0

## Freeze of attacker and target on a landed hit, in milliseconds (story asks ~60-80 ms).
@export var pause_ms := 70.0
## Longest pause allowed when reduce motion is on (story asks at most 40 ms).
@export var calm_pause_ms := 40.0
## Shake strength per point of damage and its cap, in px at layout scale u = 1.
@export var shake_per_damage := 2.5
@export var shake_max := 6.0
## How long a shake takes to settle back to rest, in seconds.
@export var shake_time := 0.15
## The boss ground-slam shockwave shake (not a hit, so it ignores damage), px at u = 1.
@export var slam_shake := 7.0


## Hit pause length in 60 Hz ticks; `calm` is reduce motion.
func pause_frames(calm: bool) -> int:
	var ms: float = minf(pause_ms, calm_pause_ms) if calm else pause_ms
	return maxi(0, roundi(ms / 1000.0 * TICKS_PER_SECOND))


## Shake strength in px (u = 1) for a hit of `damage`; 0 when `calm` (reduce motion).
func shake_px(damage: int, calm: bool) -> float:
	if calm:
		return 0.0
	return minf(shake_per_damage * float(maxi(damage, 0)), shake_max)


## Shake duration in 60 Hz ticks.
func shake_frames() -> int:
	return maxi(1, roundi(shake_time * TICKS_PER_SECOND))
