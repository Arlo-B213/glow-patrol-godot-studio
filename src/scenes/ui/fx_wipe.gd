extends Control
## One-shot glow wipe for screen transitions (Story 034): a bright slanted band with a soft
## glow sweeps left to right across the content in ~0.3 s, then frees itself.

const FxLight := preload("res://scripts/fx_light.gd")

var progress := 0.0


## Plays a wipe over `parent` (no-op when motion is reduced).
static func play(parent: Control) -> void:
	if FxLight.calm() or not parent.is_inside_tree():
		return
	var w: Control = (load("res://scenes/ui/fx_wipe.gd") as GDScript).new()
	parent.add_child(w)
	var tw := w.create_tween()
	tw.tween_property(w, "progress", 1.0, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(w.queue_free)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _process(_d: float) -> void:
	queue_redraw()


func _draw() -> void:
	if size.x < 8.0:
		return
	var x: float = -120.0 + (size.x + 240.0) * progress
	var a: float = sin(progress * PI)
	var slant := 60.0
	var col := UiTheme.ACCENT.lightened(0.2)
	FxLight.halo(self, Vector2(x, size.y * 0.5), size.y * 0.5, col, 0.45 * a, size.y * 0.55)
	draw_colored_polygon(PackedVector2Array([Vector2(x - 14 + slant, 0), Vector2(x + 14 + slant, 0), Vector2(x + 14 - slant, size.y), Vector2(x - 14 - slant, size.y)]), Color(1, 1, 1, 0.35 * a))
