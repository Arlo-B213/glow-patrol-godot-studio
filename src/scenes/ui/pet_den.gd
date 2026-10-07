class_name PetDen
extends Control
## Cosy code-drawn room for the Pets screen: glow-lit wall and floor, moon window, rug,
## bed, bowl and toys, with the active pet (a PetView) in the middle.

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
		queue_redraw()


func _init() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = Vector2(0, 360)
	add_child(pet_view)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		var side := minf(size.x * 0.62, size.y * 0.9)
		pet_view.size = Vector2(side, side)
		pet_view.position = Vector2((size.x - side) * 0.5, size.y * 0.97 - side * 0.93)
		queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	var floor_y := h * 0.62
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, floor_y), Vector2(0, floor_y)]),
		PackedColorArray([WALL, WALL, WALL_LOW, WALL_LOW]))
	# Floor boards.
	draw_rect(Rect2(0, floor_y, w, h - floor_y), FLOOR)
	draw_line(Vector2(0, floor_y), Vector2(w, floor_y), FLOOR_LINE, 4.0)
	for i in 5:
		var y := floor_y + (h - floor_y) * float(i + 1) / 5.0
		draw_line(Vector2(0, y), Vector2(w, y), Color(FLOOR_LINE, 0.55), 2.0)
	# Soft lamp glow on the wall and rug under the pet.
	draw_circle(Vector2(w * 0.5, floor_y - h * 0.12), h * 0.46, Color(GLOW, 0.07))
	draw_circle(Vector2(w * 0.5, floor_y - h * 0.12), h * 0.3, Color(GLOW, 0.07))
	_ellipse(Vector2(w * 0.5, h * 0.86), w * 0.36, h * 0.08, Color(RUG, 0.85))
	_ellipse(Vector2(w * 0.5, h * 0.86), w * 0.28, h * 0.055, Color(RUG.lightened(0.3), 0.6))
	_draw_window(Vector2(w * 0.17, h * 0.2), h * 0.16)
	_draw_bed(Vector2(w * 0.12, h * 0.84), h * 0.14)
	_draw_bowl(Vector2(w * 0.86, h * 0.88), h * 0.1)
	# Toys: ball and star cushion.
	draw_circle(Vector2(w * 0.74, h * 0.93), h * 0.035, Color("#52E8C6"))
	draw_arc(Vector2(w * 0.74, h * 0.93), h * 0.035, 0.0, TAU, 16, Color("#1A0B33", 0.5), 1.5, true)
	# Hanging fairy-light string.
	var prev := Vector2(w * 0.04, h * 0.03)
	for i in 9:
		var f := float(i + 1) / 9.0
		var pos := Vector2(w * (0.04 + 0.92 * f), h * (0.03 + 0.06 * sin(f * PI)))
		draw_line(prev, pos, Color("#3B2A6B"), 2.0)
		draw_circle(pos + Vector2(0, 6), 4.0, Color([GLOW, RUG, Color("#52E8C6")][i % 3], 0.95))
		prev = pos


func _ellipse(c: Vector2, rx: float, ry: float, col: Color) -> void:
	draw_colored_polygon(Shade.ellipse(c, rx, ry, 28), col)


func _draw_window(c: Vector2, r: float) -> void:
	draw_circle(c, r * 1.15, Color("#1A0B33"))
	draw_circle(c, r, Color("#120B2E"))
	draw_circle(c + Vector2(r * 0.15, -r * 0.1), r * 0.45, Color("#FFE9A8"))
	draw_circle(c + Vector2(r * 0.35, -r * 0.2), r * 0.4, Color("#120B2E"))
	for s in [Vector2(-0.5, -0.4), Vector2(-0.2, 0.5), Vector2(0.55, 0.35)]:
		draw_circle(c + s * r, 2.0, Color.WHITE)
	draw_arc(c, r * 1.15, 0.0, TAU, 28, Color("#FFC15E", 0.7), 3.0, true)


func _draw_bed(c: Vector2, r: float) -> void:
	_ellipse(c + Vector2(0, r * 0.15), r * 1.5, r * 0.55, Color("#8E7CFF").darkened(0.35))
	_ellipse(c, r * 1.4, r * 0.5, Color("#8E7CFF"))
	_ellipse(c + Vector2(0, -r * 0.05), r * 0.95, r * 0.3, Color("#FFC2D8"))


func _draw_bowl(c: Vector2, r: float) -> void:
	var rim := Shade.ellipse(c + Vector2(0, -r * 0.1), r, r * 0.32, 20)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-r, -r * 0.1), c + Vector2(r, -r * 0.1),
		c + Vector2(r * 0.7, r * 0.5), c + Vector2(-r * 0.7, r * 0.5)]), Color("#FF5FA2"))
	draw_colored_polygon(rim, Color("#FF5FA2").lightened(0.25))
	if bowl_fill > 0.05:
		draw_colored_polygon(Shade.ellipse(c + Vector2(0, -r * 0.14), r * 0.82, r * 0.22, 18), Color("#FFC15E"))
		for i in 4:
			draw_circle(c + Vector2((float(i) - 1.5) * r * 0.4, -r * (0.3 + 0.08 * (i % 2)) * bowl_fill), r * 0.12, Color("#FFD9A0"))
