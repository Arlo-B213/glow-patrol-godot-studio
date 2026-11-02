class_name Haptics
extends RefCounted
## Phone vibration for key moments (Story 040). Each event maps to a pulse length in milliseconds.
## `enabled` mirrors the Settings toggle (GameState keeps it in sync). The vibration call is `sink`, so
## tests can count pulses. Input.vibrate_handheld has no effect off Android, iOS and Web, so calls are
## always safe.

const DURATIONS := {"enemy_hit": 25, "sp_burst": 60, "zap_strike": 40}
## Star Points granted at once that count as a burst.
const SP_BURST_MIN := 10

static var enabled := true
static var sink: Callable = Callable(Haptics, "_vibrate")


## Pulses for `event` if haptics are on. Returns the pulse length sent (0 when nothing was sent).
static func pulse(event: String) -> int:
	if not enabled or not DURATIONS.has(event):
		return 0
	var ms: int = DURATIONS[event]
	sink.call(ms)
	return ms


static func _vibrate(ms: int) -> void:
	Input.vibrate_handheld(ms)
