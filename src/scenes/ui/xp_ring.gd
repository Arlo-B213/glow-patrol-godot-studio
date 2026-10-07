class_name XpRing
extends Control
## Circular XP progress ring: dim full circle plus an ACCENT arc for the progress.
## Hosts a centred child (the level icon) supplied by the caller.

const THICKNESS := 4.0

var progress := 0.0:
	set(value):
		progress = clampf(value, 0.0, 1.0)
		queue_redraw()
var _tween: Tween


func _init() -> void:
	custom_minimum_size = Vector2(40, 40)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Sets the fill (0..1), tweening when motion is enabled.
func set_progress(p: float, duration: float = 0.4) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if not UiMotion.enabled() or not is_inside_tree():
		progress = p
		return
	_tween = create_tween()
	_tween.tween_property(self, "progress", clampf(p, 0.0, 1.0), duration).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.5 - THICKNESS * 0.5
	draw_arc(center, radius, 0.0, TAU, 48, UiTheme.PANEL_LIGHT, THICKNESS, true)
	if progress > 0.001:
		draw_arc(center, radius, -PI * 0.5, -PI * 0.5 + TAU * progress, 48, UiTheme.ACCENT, THICKNESS, true)
