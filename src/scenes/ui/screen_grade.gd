class_name ScreenGrade
extends ColorRect
## Full-screen vignette overlay (src/shaders/screen_grade.gdshader). Decorative only: it ignores
## the mouse so every button underneath still works. Attach once to the main screen with attach().

const SHADER := preload("res://shaders/screen_grade.gdshader")


## Adds the overlay to `host` and keeps it on top of the host's other children.
static func attach(host: Control) -> ScreenGrade:
	var grade := ScreenGrade.new()
	host.add_child(grade)
	host.move_child(grade, host.get_child_count() - 1)
	return grade


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color.WHITE
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	material = mat
