class_name BreakerModelView
extends Control
## The Gloom Breaker as a transparent 3D model inside a 2D layout (HQ hero card, Club previews).
## It renders into its own SubViewport, so it can sit over the code-drawn backdrop. Mouse input
## passes through to the controls underneath.

const PREVIEW_SCENE := preload("res://scenes/preview/breaker_3d_preview.tscn")

var _view: SubViewport
var _model: Node3D


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	var holder := SubViewportContainer.new()
	holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.stretch = true
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_view = SubViewport.new()
	_view.own_world_3d = true
	_view.transparent_bg = true

	holder.add_child(_view)
	add_child(holder)
	_model = PREVIEW_SCENE.instantiate()
	_model.set("transparent", true)
	_view.add_child(_model)


## Freeze on one angle (degrees) when `angle` >= 0, or sweep the full turn when it is -1.
func set_angle(angle: float) -> void:
	_model.set("angle_override", angle)
