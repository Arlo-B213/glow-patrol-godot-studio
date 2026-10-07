extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Rhythm Tap stage scenery (Story 026): the 'neon' GameKit backdrop plus sweeping spotlights,
## a beat-pulsing floor glow and glowing screen edges. Pure drawing helpers, no state.

const Kit := preload("res://scenes/games/game_kit.gd")


## Draws the whole stage. `t` animation seconds (0 when calm), `beat` 0..1 pulse on each beat,
## `fever` 0..1 extra intensity, `floor_y` top of the floor glow.
static func draw(ci: CanvasItem, size: Vector2, t: float, beat: float, fever: float, floor_y: float, calm: bool) -> void:
	Kit.draw_backdrop(ci, size, "neon", t, 0.0 if calm else t * 14.0)
	_spotlights(ci, size, t, beat, fever, calm)
	_floor(ci, size, beat, fever, floor_y)
	_edges(ci, size, beat, fever)


static func _spotlights(ci: CanvasItem, size: Vector2, t: float, beat: float, fever: float, calm: bool) -> void:
	var cols: Array = [Color("#FF5FA2"), Color("#52E8C6"), Color("#8E7CFF"), Color("#FFC15E")]
	var n := 4
	for i in n:
		var ox: float = size.x * (0.12 + 0.76 * float(i) / float(n - 1))
		var ang: float = 0.0
		if calm:
			ang = (float(i) - 1.5) * 0.18
		else:
			ang = sin(t * (0.7 + 0.15 * float(i)) + float(i) * 1.9) * 0.55
		var dir := Vector2(sin(ang), cos(ang))
		var perp := Vector2(dir.y, -dir.x)
		var o := Vector2(ox, -6.0)
		var far: Vector2 = o + dir * size.y * 0.95
		var hw: float = size.x * (0.10 + 0.05 * fever)
		var a: float = 0.07 + 0.07 * beat + 0.10 * fever
		FD.poly(ci, PackedVector2Array([o - perp * 5.0, o + perp * 5.0, far + perp * hw, far - perp * hw]), Color(cols[i], a))
		FD.circle(ci, o + Vector2(0, 8), 7.0, Color(cols[i], 0.7))


static func _floor(ci: CanvasItem, size: Vector2, beat: float, fever: float, floor_y: float) -> void:
	var bands := 8
	var h: float = maxf(10.0, size.y - floor_y)
	for i in bands:
		var f: float = float(i) / float(bands)
		var a: float = (0.05 + 0.14 * beat + 0.12 * fever) * (0.4 + f)
		ci.draw_rect(Rect2(0.0, floor_y + h * f, size.x, h / float(bands) + 1.0), Color(UiTheme.ACCENT, a))
	ci.draw_rect(Rect2(0.0, floor_y, size.x, 3.0), Color(UiTheme.TEXT, 0.25 + 0.4 * beat))


static func _edges(ci: CanvasItem, size: Vector2, beat: float, fever: float) -> void:
	var strength: float = 0.10 + 0.22 * beat + 0.35 * fever
	for i in 7:
		var w: float = 6.0 + float(i) * 7.0
		var a: float = strength * (1.0 - float(i) / 7.0) * 0.6
		ci.draw_rect(Rect2(0.0, 0.0, w, size.y), Color(UiTheme.VIOLET, a))
		ci.draw_rect(Rect2(size.x - w, 0.0, w, size.y), Color(UiTheme.VIOLET, a))
