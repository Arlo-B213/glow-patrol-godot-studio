class_name WeaponThumb
extends Control
## Small drawn weapon thumbnail for the Club Weapons tab (Story 008): the weapon drawn
## diagonally in a rounded dark tile. Set `style` and `glow`, or call setup().

const Weapons := preload("res://scripts/hunter_weapons.gd")

var style: String = "stick":
	set(value):
		style = value
		queue_redraw()
var glow: Color = Color.WHITE:
	set(value):
		glow = value
		queue_redraw()


func _init() -> void:
	custom_minimum_size = Vector2(56, 56)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	clip_contents = true


## Sets style id and glow colour; returns self for chaining.
func setup(weapon_style: String, weapon_glow: Color, px: float = 56.0) -> WeaponThumb:
	custom_minimum_size = Vector2(px, px)
	style = weapon_style
	glow = weapon_glow
	return self


func _draw() -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("#1A0B33")
	box.border_color = Color(glow.r, glow.g, glow.b, 0.45)
	box.set_border_width_all(2)
	box.set_corner_radius_all(int(size.x * 0.28))
	draw_style_box(box, Rect2(Vector2.ZERO, size))
	var s: float = size.x / 56.0
	var dir := Vector2(1.0, -1.0).normalized()
	var u: float = 1.1 * s
	var start := Vector2(10.0, 44.0) * s
	Weapons.draw(self, style, start + dir * Weapons.GRIP * u, dir, 36.0 * u, 4.0 * u, glow, 1.0, 1.0, 1.0)
