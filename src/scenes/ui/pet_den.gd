class_name PetDen
extends Control
const FD := preload("res://scripts/fast_draw.gd")
## Cosy code-drawn room for the Pets screen: lit wall and floor, a window with a sky that
## follows the system clock (sun by day, moon and stars at night), plush bed, food bowl
## that fills and empties with hunger, ball, little lantern, rug and soft shadows. The
## static room is drawn once per change (child `_room`); only floating dust motes and
## hearts are redrawn per frame (child `_fx`), and they freeze under reduced motion.

const Shade := preload("res://scripts/hunter_shade.gd")
const WALL := Color("#2A1B52")
const WALL_LOW := Color("#3B2A6B")
const FLOOR := Color("#4A3170")
const FLOOR_LINE := Color("#3B2A6B")
const RUG := Color("#FF5FA2")
const GLOW := Color("#FFC15E")

## The pet shown in the den; set up with `pet_view.pet(species, stage)`.
var pet_view := PetView.new()
## 0..1 how full the bowl looks.
var bowl_fill := 0.8:
	set(v):
		bowl_fill = clampf(v, 0.0, 1.0)
		if _room != null:
			_room.queue_redraw()
## Hour 0..23 used for the window; -1 follows the system clock.
var hour_override := -1:
	set(v):
		hour_override = v
		if _room != null:
			_room.queue_redraw()

var _room: Control
var _fx: Control
var _t := 0.0


func _init() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = Vector2(0, 360)
	_room = Control.new()
	_room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_room.draw.connect(_draw_room)
	add_child(_room)
	add_child(pet_view)
	_fx = Control.new()
	_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx.draw.connect(_draw_fx)
	add_child(_fx)


func _ready() -> void:
	set_process(UiMotion.enabled())


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		var side := minf(size.x * 0.62, size.y * 0.9)
		pet_view.size = Vector2(side, side)
		pet_view.position = Vector2((size.x - side) * 0.5, size.y * 0.97 - side * 0.93)
		_room.size = size
		_fx.size = size
		_room.queue_redraw()
		_fx.queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	_fx.queue_redraw()


func _hour() -> int:
	if hour_override >= 0:
		return hour_override
	return int(Time.get_time_dict_from_system()["hour"])


## 0 = full night, 1 = full day (dawn 5-7 and dusk 18-20 blend).
func _daylight() -> float:
	var h := float(_hour())
	if h >= 7.0 and h < 18.0:
		return 1.0
	if h >= 5.0 and h < 7.0:
		return (h - 5.0) / 2.0
	if h >= 18.0 and h < 20.0:
		return 1.0 - (h - 18.0) / 2.0
	return 0.0


func _draw_room() -> void:
	var w := size.x
	var h := size.y
	var day := _daylight()
	var floor_y := h * 0.62
	var dim := lerpf(0.0, 0.0, day)
	var wall_hi := WALL.lerp(Color("#5A3F9A"), day * 0.55)
	var wall_lo := WALL_LOW.lerp(Color("#7A58B8"), day * 0.55)
	FD.gpoly(_room, PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, floor_y), Vector2(0, floor_y)]),
		PackedColorArray([wall_hi, wall_hi, wall_lo, wall_lo]))
	# Wallpaper stars.
	for i in 14:
		var sp := Vector2(w * fposmod(float(i) * 0.37 + 0.06, 1.0), h * (0.06 + 0.5 * fposmod(float(i) * 0.61, 1.0)))
		FD.circle(_room, sp, 1.6, Color(1, 1, 1, 0.12))
	_room.draw_rect(Rect2(0, floor_y - 6.0, w, 6.0), Color(FLOOR_LINE, 0.9))
	# Floor boards.
	_room.draw_rect(Rect2(0, floor_y, w, h - floor_y), FLOOR.lerp(Color("#6A4A98"), day * 0.4))
	_room.draw_line(Vector2(0, floor_y), Vector2(w, floor_y), FLOOR_LINE, 4.0)
	for i in 5:
		var y := floor_y + (h - floor_y) * float(i + 1) / 5.0
		_room.draw_line(Vector2(0, y), Vector2(w, y), Color(FLOOR_LINE, 0.55), 2.0)
	_draw_window(Vector2(w * 0.2, h * 0.24), h * 0.17, day)
	# Window light cast on the floor.
	var beam := Color(1.0, 0.92, 0.65, 0.12 * day) if day > 0.3 else Color(0.7, 0.8, 1.0, 0.08 * (1.0 - day))
	FD.poly(_room, PackedVector2Array([Vector2(w * 0.08, floor_y), Vector2(w * 0.3, floor_y),
		Vector2(w * 0.5, h * 0.95), Vector2(w * 0.22, h * 0.95)]), beam)
	# Lamp glow behind the pet, rug and shadows.
	FD.circle(_room, Vector2(w * 0.5, floor_y - h * 0.12), h * 0.46, Color(GLOW, 0.07))
	FD.circle(_room, Vector2(w * 0.5, floor_y - h * 0.12), h * 0.3, Color(GLOW, 0.07))
	_ellipse(Vector2(w * 0.5, h * 0.87), w * 0.38, h * 0.085, Color(RUG, 0.9))
	_ellipse(Vector2(w * 0.5, h * 0.87), w * 0.3, h * 0.062, Color(RUG.lightened(0.3), 0.7))
	_ellipse(Vector2(w * 0.5, h * 0.87), w * 0.2, h * 0.04, Color(RUG, 0.55))
	_draw_bed(Vector2(w * 0.13, h * 0.84), h * 0.14)
	_draw_bowl(Vector2(w * 0.87, h * 0.88), h * 0.1)
	_draw_ball(Vector2(w * 0.74, h * 0.935), h * 0.036)
	_draw_lantern(Vector2(w * 0.93, h * 0.52))
	# Hanging fairy-light string.
	var prev := Vector2(w * 0.04, h * 0.03)
	for i in 9:
		var f := float(i + 1) / 9.0
		var pos := Vector2(w * (0.04 + 0.92 * f), h * (0.03 + 0.06 * sin(f * PI)))
		_room.draw_line(prev, pos, Color("#3B2A6B"), 2.0)
		var lc: Color = [GLOW, RUG, Color("#52E8C6")][i % 3]
		FD.circle(_room, pos + Vector2(0, 6), 9.0, Color(lc, 0.14))
		FD.circle(_room, pos + Vector2(0, 6), 4.0, Color(lc, 0.95))
		prev = pos
	if dim > 0.0:
		_room.draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, dim))


func _ellipse(c: Vector2, rx: float, ry: float, col: Color) -> void:
	FD.poly(_room, Shade.ellipse(c, rx, ry, 28), col)


func _draw_window(c: Vector2, r: float, day: float) -> void:
	var sky_top := Color("#0E0A2A").lerp(Color("#5FB4FF"), day)
	var sky_low := Color("#2B1B5E").lerp(Color("#BFE6FF"), day)
	if day > 0.0 and day < 1.0:
		sky_low = sky_low.lerp(Color("#FF9A6E"), sin(day * PI) * 0.7)
	var frame := Rect2(c - Vector2(r, r * 1.15), Vector2(r * 2.0, r * 2.3))
	_room.draw_rect(frame.grow(5.0), Color("#1A0B33"))
	_room.draw_rect(frame.grow(3.0), Color("#8E7CFF").darkened(0.2))
	FD.gpoly(_room, PackedVector2Array([frame.position, frame.position + Vector2(frame.size.x, 0),
		frame.end, frame.position + Vector2(0, frame.size.y)]), PackedColorArray([sky_top, sky_top, sky_low, sky_low]))
	if day < 0.7:
		var a := 1.0 - day / 0.7
		for s in [Vector2(-0.6, -0.8), Vector2(-0.1, -0.4), Vector2(0.6, -0.9), Vector2(0.4, 0.2), Vector2(-0.5, 0.5), Vector2(0.1, 0.8)]:
			FD.circle(_room, c + Vector2(s.x * r, s.y * r * 1.1), 2.2, Color(1, 1, 0.9, a))
		var mc := c + Vector2(r * 0.25, -r * 0.3)
		FD.circle(_room, mc, r * 0.62, Color("#FFE9A8", 0.12 * a))
		FD.circle(_room, mc, r * 0.4, Color("#FFE9A8", a))
		FD.circle(_room, mc + Vector2(r * 0.17, -r * 0.08), r * 0.34, sky_top.lerp(sky_low, 0.3))
	if day > 0.3:
		var sc := c + Vector2(-r * 0.3, -r * 0.45)
		FD.circle(_room, sc, r * 0.8, Color("#FFF2B0", 0.18 * day))
		FD.circle(_room, sc, r * 0.5, Color("#FFF2B0", 0.35 * day))
		FD.circle(_room, sc, r * 0.32, Color("#FFE680", day))
		for rays in 8:
			var an := TAU * float(rays) / 8.0
			_room.draw_line(sc + Vector2(cos(an), sin(an)) * r * 0.42, sc + Vector2(cos(an), sin(an)) * r * 0.62, Color("#FFE680", 0.6 * day), 2.0)
	# Rooftop silhouettes and cross bars.
	_room.draw_rect(Rect2(frame.position.x, frame.end.y - r * 0.28, frame.size.x, r * 0.28), Color("#1A0B33", 0.6))
	_room.draw_line(Vector2(c.x, frame.position.y), Vector2(c.x, frame.end.y), Color("#8E7CFF").darkened(0.2), 4.0)
	_room.draw_line(Vector2(frame.position.x, c.y), Vector2(frame.end.x, c.y), Color("#8E7CFF").darkened(0.2), 4.0)
	_ellipse(c + Vector2(0, r * 1.3), r * 1.3, r * 0.16, Color(0, 0, 0, 0.18))


func _draw_bed(c: Vector2, r: float) -> void:
	_ellipse(c + Vector2(0, r * 0.45), r * 1.6, r * 0.25, Color(0, 0, 0, 0.28))
	_ellipse(c + Vector2(0, r * 0.15), r * 1.5, r * 0.58, Color("#8E7CFF").darkened(0.45))
	_ellipse(c, r * 1.42, r * 0.52, Color("#8E7CFF").darkened(0.1))
	_ellipse(c + Vector2(0, -r * 0.06), r * 1.2, r * 0.4, Color("#B7A8FF"))
	_ellipse(c + Vector2(0, -r * 0.1), r * 0.95, r * 0.3, Color("#FFC2D8"))
	_ellipse(c + Vector2(-r * 0.2, -r * 0.18), r * 0.5, r * 0.12, Color("#FFE4EE", 0.8))
	FD.circle(_room, c + Vector2(r * 0.55, -r * 0.2), r * 0.2, Color("#FFD36E"))


func _draw_bowl(c: Vector2, r: float) -> void:
	_ellipse(c + Vector2(0, r * 0.55), r * 1.15, r * 0.24, Color(0, 0, 0, 0.3))
	var rim := Shade.ellipse(c + Vector2(0, -r * 0.1), r, r * 0.32, 20)
	FD.poly(_room, PackedVector2Array([c + Vector2(-r, -r * 0.1), c + Vector2(r, -r * 0.1),
		c + Vector2(r * 0.7, r * 0.5), c + Vector2(-r * 0.7, r * 0.5)]), Color("#C23C7E"))
	_ellipse(c + Vector2(0, r * 0.5), r * 0.7, r * 0.18, Color("#C23C7E"))
	FD.poly(_room, rim, Color("#FF5FA2").lightened(0.25))
	FD.poly(_room, Shade.ellipse(c + Vector2(0, -r * 0.08), r * 0.82, r * 0.24, 18), Color("#7A1F4E"))
	if bowl_fill > 0.05:
		var rise := bowl_fill * r * 0.2
		FD.poly(_room, Shade.ellipse(c + Vector2(0, -r * 0.1 - rise * 0.5), r * 0.8, r * 0.22, 18), Color("#FFC15E"))
		for i in 5:
			var hx := c.x + (float(i) - 2.0) * r * 0.32
			FD.circle(_room, Vector2(hx, c.y - r * (0.18 + 0.08 * float(i % 2)) - rise), r * 0.13 * (0.6 + 0.4 * bowl_fill), Color("#FFD9A0"))
	_room.draw_line(c + Vector2(-r * 0.6, r * 0.2), c + Vector2(-r * 0.45, r * 0.42), Color(1, 1, 1, 0.3), 2.0)


func _draw_ball(c: Vector2, r: float) -> void:
	_ellipse(c + Vector2(0, r * 0.9), r * 1.2, r * 0.3, Color(0, 0, 0, 0.3))
	FD.circle(_room, c, r, Color("#52E8C6"))
	FD.arc(_room, c, r * 0.7, -0.6, 1.8, 10, Color("#FFFFFF", 0.7), 2.0, true)
	FD.arc(_room, c, r * 0.7, 2.6, 4.4, 10, Color("#FF5FA2"), 2.0, true)
	FD.arc(_room, c, r, 0.0, TAU, 18, Color("#1A0B33", 0.55), 1.6, true)
	FD.circle(_room, c + Vector2(-r * 0.35, -r * 0.4), r * 0.22, Color(1, 1, 1, 0.8))


func _draw_lantern(c: Vector2) -> void:
	var r := size.y * 0.04
	_room.draw_line(c + Vector2(0, -r * 3.0), c + Vector2(0, -r * 1.2), Color("#3B2A6B"), 2.0)
	FD.circle(_room, c, r * 3.0, Color(GLOW, 0.1))
	FD.circle(_room, c, r * 2.0, Color(GLOW, 0.14))
	FD.poly(_room, Shade.ellipse(c, r * 0.9, r * 1.2, 16), Color("#FF8A4C"))
	FD.poly(_room, Shade.ellipse(c, r * 0.6, r * 0.9, 16), Color("#FFE08A"))
	_room.draw_rect(Rect2(c.x - r * 0.5, c.y - r * 1.35, r, r * 0.3), Color("#3B2A6B"))
	_room.draw_rect(Rect2(c.x - r * 0.5, c.y + r * 1.05, r, r * 0.3), Color("#3B2A6B"))


## Dust motes and tiny sparkles floating through the window light and lamp glow.
func _draw_fx() -> void:
	var w := size.x
	var h := size.y
	var day := _daylight()
	for i in 16:
		var f := float(i)
		var x := w * (0.1 + 0.8 * fposmod(f * 0.173 + sin(_t * 0.18 + f) * 0.04, 1.0))
		var y := h * (0.12 + 0.6 * fposmod(f * 0.311 - _t * 0.012 * (1.0 + fposmod(f, 3.0)), 1.0))
		var a := 0.18 + 0.2 * sin(_t * 0.9 + f * 1.7)
		var col := Color(1.0, 0.95, 0.75, a) if (day > 0.3 or i % 2 == 0) else Color(0.8, 0.85, 1.0, a)
		FD.circle(_fx, Vector2(x, y), 1.4 + float(i % 3) * 0.6, col)
	# Lantern flicker.
	var fl := 0.5 + 0.5 * sin(_t * 7.0) * sin(_t * 3.1)
	FD.circle(_fx, Vector2(w * 0.93, h * 0.52), h * 0.05, Color(GLOW, 0.1 * fl))
	# Little drifting hearts when the pet is happy.
	if pet_view.mood == PetArt.MOOD_HAPPY:
		for i in 3:
			var ph := fposmod(_t * 0.25 + float(i) / 3.0, 1.0)
			PetArt.heart(_fx, Vector2(w * (0.3 + 0.2 * float(i)) + sin(ph * 5.0) * 8.0, h * (0.5 - ph * 0.3)), 5.0, Color(1, 0.45, 0.65, 0.5 * (1.0 - ph)))
