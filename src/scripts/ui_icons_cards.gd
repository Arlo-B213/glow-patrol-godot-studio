class_name UiIconsCards
extends RefCounted
## Illustrated icons for mode cards and hub tiles (Story 013): game modes,
## study subjects, lounge, closet and stage. Same language as UiIcons:
## unit coordinates, bold fills, `tint` as the main colour. Polygons are
## simple (non-self-intersecting) so triangulation never fails.

const K := preload("res://scripts/ui_icon_kit.gd")


## Pushes a four-point sparkle made of two strokes.
static func _spark(ci: CanvasItem, r: Rect2, x: float, y: float, s: float, col: Color) -> void:
	var w := K.sw(r) * 0.5
	K.line(ci, r, Vector2(x, y - s), Vector2(x, y + s), col, w)
	K.line(ci, r, Vector2(x - s, y), Vector2(x + s, y), col, w)


## Zap Patrol: lightning bolt with sparks.
static func draw_zap(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var bolt: Array = [
		Vector2(0.62, 0.04), Vector2(0.2, 0.54), Vector2(0.46, 0.54), Vector2(0.36, 0.96),
		Vector2(0.8, 0.4), Vector2(0.54, 0.4), Vector2(0.7, 0.04),
	]
	K.poly(ci, r, bolt, tint, K.sw(r) * 0.5)
	K.poly(ci, r, [Vector2(0.58, 0.14), Vector2(0.4, 0.46), Vector2(0.5, 0.46)], K.light(tint), 0.0)
	_spark(ci, r, 0.14, 0.22, 0.07, UiTheme.TEAL)
	_spark(ci, r, 0.88, 0.76, 0.07, UiTheme.TEAL)


## Alley Brawl: clenched fist.
static func draw_fist(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var d := K.dark(tint)
	K.poly(ci, r, [Vector2(0.28, 0.66), Vector2(0.74, 0.66), Vector2(0.7, 0.94), Vector2(0.3, 0.94)],
		tint.lerp(UiTheme.BG, 0.35), K.sw(r) * 0.3)
	K.poly(ci, r, [Vector2(0.14, 0.3), Vector2(0.86, 0.3), Vector2(0.86, 0.7), Vector2(0.14, 0.7)],
		tint, K.sw(r) * 0.4)
	for i in 4:
		K.circ(ci, r, 0.26 + i * 0.16, 0.3, 0.12, tint)
	for x in [0.34, 0.5, 0.66]:
		K.line(ci, r, Vector2(x, 0.3), Vector2(x, 0.5), d, K.sw(r) * 0.4)
	K.circ(ci, r, 0.2, 0.64, 0.13, K.light(tint).lerp(tint, 0.5))
	K.arc(ci, r, 0.22, 0.6, 0.1, PI * 0.9, PI * 1.9, d, K.sw(r) * 0.4)


## Rhythm Tap: beamed pair of notes.
static func draw_music(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var w := K.sw(r) * 0.9
	K.line(ci, r, Vector2(0.38, 0.72), Vector2(0.38, 0.2), tint, w)
	K.line(ci, r, Vector2(0.8, 0.64), Vector2(0.8, 0.12), tint, w)
	K.poly(ci, r, [Vector2(0.38, 0.12), Vector2(0.8, 0.04), Vector2(0.8, 0.26), Vector2(0.38, 0.34)],
		tint, K.sw(r) * 0.3)
	K.circ(ci, r, 0.27, 0.76, 0.15, tint)
	K.circ(ci, r, 0.69, 0.68, 0.15, tint)
	K.circ(ci, r, 0.23, 0.72, 0.04, K.light(tint))
	K.circ(ci, r, 0.65, 0.64, 0.04, K.light(tint))


## Memory Match: two tilted cards, the front one showing a star.
static func draw_cards(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var back: Array = [Vector2(0.06, 0.24), Vector2(0.5, 0.12), Vector2(0.68, 0.76), Vector2(0.24, 0.88)]
	K.poly(ci, r, back, tint.lerp(UiTheme.BG, 0.45), K.sw(r) * 0.5)
	K.polyline(ci, r, [Vector2(0.2, 0.3), Vector2(0.46, 0.23), Vector2(0.56, 0.66), Vector2(0.3, 0.73)],
		tint, K.sw(r) * 0.3)
	var front: Array = [Vector2(0.36, 0.14), Vector2(0.86, 0.14), Vector2(0.86, 0.88), Vector2(0.36, 0.88)]
	K.poly(ci, r, front, tint, K.sw(r) * 0.5)
	var pts: Array = []
	for i in 10:
		var ang := -PI * 0.5 + i * PI / 5.0
		var rad := 0.2 if i % 2 == 0 else 0.09
		pts.append(Vector2(0.61 + cos(ang) * rad, 0.52 + sin(ang) * rad))
	K.poly(ci, r, pts, UiTheme.GOLD, K.sw(r) * 0.3)


## Star Catch: basket with a falling star.
static func draw_catch(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var pts: Array = []
	for i in 10:
		var ang := -PI * 0.5 + i * PI / 5.0
		var rad := 0.26 if i % 2 == 0 else 0.12
		pts.append(Vector2(0.5 + cos(ang) * rad, 0.27 + sin(ang) * rad))
	K.poly(ci, r, pts, UiTheme.GOLD, K.sw(r) * 0.4)
	K.poly(ci, r, [Vector2(0.14, 0.54), Vector2(0.86, 0.54), Vector2(0.72, 0.94), Vector2(0.28, 0.94)],
		tint, K.sw(r) * 0.5)
	var d := K.dark(tint)
	K.line(ci, r, Vector2(0.36, 0.62), Vector2(0.4, 0.88), d, K.sw(r) * 0.4)
	K.line(ci, r, Vector2(0.5, 0.62), Vector2(0.5, 0.88), d, K.sw(r) * 0.4)
	K.line(ci, r, Vector2(0.64, 0.62), Vector2(0.6, 0.88), d, K.sw(r) * 0.4)
	K.line(ci, r, Vector2(0.1, 0.54), Vector2(0.9, 0.54), K.light(tint), K.sw(r) * 0.8)


## Lantern Says: paper lantern with a glowing core.
static func draw_lantern(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var w := K.sw(r)
	K.arc(ci, r, 0.5, 0.12, 0.12, PI, PI * 2.0, tint, w * 0.6)
	var body: Array = [
		Vector2(0.3, 0.2), Vector2(0.7, 0.2), Vector2(0.86, 0.5),
		Vector2(0.7, 0.8), Vector2(0.3, 0.8), Vector2(0.14, 0.5),
	]
	K.poly(ci, r, body, tint, w * 0.5)
	K.poly(ci, r, [Vector2(0.34, 0.1), Vector2(0.66, 0.1), Vector2(0.64, 0.22), Vector2(0.36, 0.22)],
		K.dark(tint).lerp(tint, 0.3), w * 0.3)
	K.poly(ci, r, [Vector2(0.36, 0.8), Vector2(0.64, 0.8), Vector2(0.62, 0.9), Vector2(0.38, 0.9)],
		K.dark(tint).lerp(tint, 0.3), w * 0.3)
	K.circ(ci, r, 0.5, 0.5, 0.15, K.light(tint))
	K.line(ci, r, Vector2(0.38, 0.22), Vector2(0.28, 0.78), K.dark(tint), w * 0.4)
	K.line(ci, r, Vector2(0.62, 0.22), Vector2(0.72, 0.78), K.dark(tint), w * 0.4)
	K.line(ci, r, Vector2(0.5, 0.9), Vector2(0.5, 0.98), tint, w * 0.5)


## Math: plus and divide signs.
static func draw_math(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var w := K.sw(r) * 1.3
	K.line(ci, r, Vector2(0.28, 0.1), Vector2(0.28, 0.46), tint, w)
	K.line(ci, r, Vector2(0.1, 0.28), Vector2(0.46, 0.28), tint, w)
	K.line(ci, r, Vector2(0.56, 0.28), Vector2(0.9, 0.28), UiTheme.GOLD, w)
	K.line(ci, r, Vector2(0.1, 0.74), Vector2(0.46, 0.74), UiTheme.GOLD, w)
	K.line(ci, r, Vector2(0.56, 0.74), Vector2(0.9, 0.74), tint, w * 0.8)
	K.circ(ci, r, 0.73, 0.58, 0.06, tint)
	K.circ(ci, r, 0.73, 0.9, 0.06, tint)


## Grammar: letter A with a pencil-line underline.
static func draw_grammar(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var w := K.sw(r) * 1.3
	K.polyline(ci, r, [Vector2(0.18, 0.74), Vector2(0.5, 0.08), Vector2(0.82, 0.74)], tint, w)
	K.line(ci, r, Vector2(0.31, 0.5), Vector2(0.69, 0.5), tint, w * 0.8)
	K.line(ci, r, Vector2(0.1, 0.9), Vector2(0.9, 0.9), UiTheme.GOLD, K.sw(r) * 0.8)


## Reading: open book with a sparkle above.
static func draw_reading(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var w := K.sw(r) * 0.35
	K.poly(ci, r, [Vector2(0.05, 0.3), Vector2(0.48, 0.4), Vector2(0.48, 0.92), Vector2(0.05, 0.82)],
		tint, K.sw(r) * 0.4)
	K.poly(ci, r, [Vector2(0.52, 0.4), Vector2(0.95, 0.3), Vector2(0.95, 0.82), Vector2(0.52, 0.92)],
		K.light(tint).lerp(tint, 0.5), K.sw(r) * 0.4)
	var d := K.dark(tint)
	for i in 3:
		var y := 0.52 + i * 0.12
		K.line(ci, r, Vector2(0.14, y - 0.03), Vector2(0.4, y + 0.02), d, w)
		K.line(ci, r, Vector2(0.6, y + 0.02), Vector2(0.86, y - 0.03), d, w)
	_spark(ci, r, 0.5, 0.16, 0.12, UiTheme.GOLD)


## Lounge: two overlapping speech bubbles.
static func draw_lounge(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var b2: Array = [
		Vector2(0.38, 0.4), Vector2(0.94, 0.4), Vector2(0.94, 0.8), Vector2(0.86, 0.8),
		Vector2(0.88, 0.95), Vector2(0.72, 0.8), Vector2(0.38, 0.8),
	]
	K.poly(ci, r, b2, UiTheme.GOLD.lerp(tint, 0.3), K.sw(r) * 0.5)
	var b1: Array = [
		Vector2(0.06, 0.1), Vector2(0.64, 0.1), Vector2(0.64, 0.54), Vector2(0.32, 0.54),
		Vector2(0.16, 0.7), Vector2(0.18, 0.54), Vector2(0.06, 0.54),
	]
	K.poly(ci, r, b1, tint, K.sw(r) * 0.5)
	for i in 3:
		K.circ(ci, r, 0.2 + i * 0.15, 0.32, 0.045, K.dark(tint))


## Closet: jacket on a hanger.
static func draw_closet(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var w := K.sw(r)
	var jacket: Array = [
		Vector2(0.36, 0.36), Vector2(0.5, 0.46), Vector2(0.64, 0.36), Vector2(0.9, 0.5),
		Vector2(0.82, 0.92), Vector2(0.18, 0.92), Vector2(0.1, 0.5),
	]
	K.poly(ci, r, jacket, tint, w * 0.5)
	K.line(ci, r, Vector2(0.5, 0.46), Vector2(0.5, 0.92), K.dark(tint), w * 0.4)
	K.line(ci, r, Vector2(0.36, 0.36), Vector2(0.5, 0.46), K.light(tint), w * 0.5)
	K.line(ci, r, Vector2(0.64, 0.36), Vector2(0.5, 0.46), K.light(tint), w * 0.5)
	K.circ(ci, r, 0.58, 0.62, 0.025, K.dark(tint))
	K.circ(ci, r, 0.58, 0.76, 0.025, K.dark(tint))
	K.arc(ci, r, 0.5, 0.17, 0.1, PI * 0.55, PI * 2.25, UiTheme.GOLD, w * 0.8)
	K.line(ci, r, Vector2(0.5, 0.27), Vector2(0.5, 0.38), UiTheme.GOLD, w * 0.8)


## Stage: microphone on a stand with spotlight sparks.
static func draw_stage(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var w := K.sw(r)
	K.arc(ci, r, 0.5, 0.46, 0.25, 0.0, PI, tint, w * 0.7)
	K.poly(ci, r, [Vector2(0.4, 0.46), Vector2(0.6, 0.46), Vector2(0.56, 0.72), Vector2(0.44, 0.72)],
		K.light(tint).lerp(tint, 0.5), w * 0.3)
	K.circ(ci, r, 0.5, 0.28, 0.17, tint)
	K.line(ci, r, Vector2(0.36, 0.24), Vector2(0.64, 0.24), K.dark(tint), w * 0.35)
	K.line(ci, r, Vector2(0.36, 0.32), Vector2(0.64, 0.32), K.dark(tint), w * 0.35)
	K.line(ci, r, Vector2(0.5, 0.72), Vector2(0.5, 0.9), tint, w * 0.8)
	K.line(ci, r, Vector2(0.28, 0.92), Vector2(0.72, 0.92), tint, w)
	_spark(ci, r, 0.14, 0.14, 0.08, UiTheme.GOLD)
	_spark(ci, r, 0.88, 0.2, 0.06, UiTheme.GOLD)
