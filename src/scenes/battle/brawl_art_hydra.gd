extends RefCounted
## The Hiccup Hydra's entry point (Story 021, redrawn in Story 031 by gloom_hydra.gd). Kept so older
## callers still work: `draw` forwards to the humanoid three-headed version.

const Body := preload("res://scenes/battle/gloom_hydra.gd")
const SNEEZE_CYCLE := Body.SNEEZE_CYCLE
const SNEEZE_LEN := Body.SNEEZE_LEN


## 0..1 progress of the current sneeze (0 = not sneezing), from the boss age.
static func sneeze_progress(age: int) -> float:
	return Body.sneeze_progress(age)


## Draws the Hydra; `flash` whitens it. Extras may be passed in `fx` (see gloom_hydra.gd).
static func draw(ci: CanvasItem, x: float, ground_y: float, s: float, flash: bool, age: int, toward: float, u: float, fx: Dictionary = {}) -> void:
	var f: Dictionary = fx.duplicate()
	if flash and not f.has("flash"):
		f["flash"] = 0.55
	Body.draw(ci, x, ground_y, s, age, toward, u, f)
