extends RefCounted
## Compatibility shim for the newer Gloomling variants (Story 021, redrawn in Story 031): the hopping
## Blinker and bulky Mossback now live in gloom_scout.gd / gloom_brute.gd. This file keeps the old
## entry points, the hop timing used by the combat code, and the defeat puff.

const Scout := preload("res://scenes/battle/gloom_scout.gd")
const Brute := preload("res://scenes/battle/gloom_brute.gd")
const HOP_CYCLE := Scout.HOP_CYCLE
const HOP_AIR := Scout.HOP_AIR


static func _c(col: Color, a: float) -> Color:
	return Color(col.r, col.g, col.b, col.a * a)


## True while a Blinker is in the air part of its hop; shared with the view.
static func blinker_airborne(age: int) -> bool:
	return Scout.airborne(age)


## Blinker: forwards to gloom_scout.gd. `fx` keys: see brawl_art.gd draw_enemy.
static func draw_blinker(ci: CanvasItem, x: float, ground_y: float, s: float, color: Color, age: int, toward: float, u: float, fx: Dictionary = {}) -> void:
	Scout.draw(ci, x, ground_y, s, color, age, toward, u, fx)


## Mossback: forwards to gloom_brute.gd. `fx.hp` <= 1 means a mushroom was knocked off.
static func draw_mossback(ci: CanvasItem, x: float, ground_y: float, s: float, color: Color, age: int, toward: float, u: float, fx: Dictionary = {}) -> void:
	Brute.draw(ci, x, ground_y, s, color, age, toward, u, fx)


## A soft defeat puff: `p` runs 0..1; circles drift outward, shrink and fade, with a few sparkles.
static func draw_puff(ci: CanvasItem, pos: Vector2, r: float, p: float, color: Color, u: float) -> void:
	var fade: float = 1.0 - p
	ci.draw_circle(pos, r * (0.5 + p * 0.9), _c(Color.WHITE.lerp(color, 0.5), 0.3 * fade))
	for i in range(7):
		var a: float = TAU * float(i) / 7.0 + 0.4
		var d: float = r * (0.3 + p * 1.1)
		ci.draw_circle(pos + Vector2(cos(a) * d, sin(a) * d * 0.8 - p * 8.0 * u), r * 0.28 * (1.0 - p * 0.6), _c(Color("#F1EAFF").lerp(color, 0.35), 0.8 * fade))
	for i in range(4):
		var a2: float = TAU * float(i) / 4.0 + 0.9 + p * 2.0
		var c: Vector2 = pos + Vector2(cos(a2), sin(a2) * 0.8) * r * (0.6 + p * 1.2)
		var sr: float = r * 0.22 * fade
		ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -sr), c + Vector2(sr * 0.3, -sr * 0.3), c + Vector2(sr, 0), c + Vector2(sr * 0.3, sr * 0.3), c + Vector2(0, sr), c + Vector2(-sr * 0.3, sr * 0.3), c + Vector2(-sr, 0), c + Vector2(-sr * 0.3, -sr * 0.3)]), _c(Color("#FFE27A"), 0.9 * fade))
