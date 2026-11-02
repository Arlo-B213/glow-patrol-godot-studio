extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Shared lighting for the drawn characters: one key light direction (from the upper left, the
## same side the shading helpers assume) and soft contact shadows under feet. Drawing code calls
## these from its _draw(), so every character sits on the ground the same way.

## Side the key light comes from: -1 = left, 1 = right.
const KEY_SIDE := -1.0
const SHADOW_TINT := Color(0.05, 0.0, 0.15)


## Soft contact shadow centred at `c`, half-width `rx`, half-height `ry`. Three stacked ellipses
## give a feathered edge; `strength` (0..1) scales the darkness.
static func contact_shadow(ci: CanvasItem, c: Vector2, rx: float, ry: float, strength: float = 1.0) -> void:
	for layer in [[1.0, 0.14], [0.78, 0.18], [0.52, 0.22]]:
		var pts := PackedVector2Array()
		for i in 20:
			var a: float = TAU * float(i) / 20.0
			pts.append(c + Vector2(cos(a) * rx * float(layer[0]), sin(a) * ry * float(layer[0])))
		FD.poly(ci, pts, Color(SHADOW_TINT, float(layer[1]) * strength))
