class_name UiIcon
extends Control
## Square, centred control that draws one UiIcons icon in a tint colour.
## Scales with its rect (smaller side wins). Never intercepts the mouse.

## Name of the icon to draw (see UiIcons.ICON_NAMES).
@export var icon_name: String = "star":
	set(value):
		icon_name = value
		queue_redraw()

## Main colour of the icon.
@export var tint: Color = Color.WHITE:
	set(value):
		tint = value
		queue_redraw()


func _init() -> void:
	custom_minimum_size = Vector2(32, 32)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Switches the drawn icon.
func set_icon(new_name: String) -> void:
	icon_name = new_name


## Recolours the icon.
func set_tint(color: Color) -> void:
	tint = color


## Convenience: sets name, tint and a square minimum size in one call.
func setup(new_name: String, color: Color, px: float = 32.0) -> UiIcon:
	custom_minimum_size = Vector2(px, px)
	icon_name = new_name
	tint = color
	return self


func _draw() -> void:
	UiIcons.draw(self, icon_name, Rect2(Vector2.ZERO, size), tint)
