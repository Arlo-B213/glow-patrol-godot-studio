class_name BreakerPreviewPage
extends Control
## Full-screen host for the 3D Gloom Breaker preview, opened from the debug-only row in Settings.
## The 3D scene renders into a SubViewport, so it can sit inside the 2D game UI. Back closes it.

signal closed

const PREVIEW_SCENE := preload("res://scenes/preview/breaker_3d_preview.tscn")


## Builds the page: the 3D view filling the screen, and a Back button on top.
func setup() -> BreakerPreviewPage:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var holder := SubViewportContainer.new()
	holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.stretch = true
	var view := SubViewport.new()
	view.own_world_3d = true
	view.transparent_bg = false
	holder.add_child(view)
	view.add_child(PREVIEW_SCENE.instantiate())
	add_child(holder)
	var back := Button.new()
	back.text = "Back"
	back.theme_type_variation = "SecondaryButton"
	back.position = Vector2(24, 24)
	back.pressed.connect(func(): closed.emit())
	add_child(back)
	return self
