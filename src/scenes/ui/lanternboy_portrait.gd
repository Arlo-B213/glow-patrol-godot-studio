class_name LanternboyPortrait
extends Control
## Control that draws one Lanternboy ("hae" | "bit" | "nun") through LanternboyArt, with an
## idle animation (blink, bob, glow pulse, moths) and a short high-five bounce.
## Processing only runs while visible and motion is allowed.

const Art := preload("res://scripts/lanternboy_art.gd")

## Which Lanternboy to draw.
var boy_id: String = "hae":
	set(v):
		boy_id = v
		queue_redraw()

var _t: float = 0.0
var _bounce: float = 0.0:
	set(v):
		_bounce = v
		queue_redraw()
var _tween: Tween = null


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	_update_processing()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_update_processing()


## Configures the portrait and returns it, e.g. `LanternboyPortrait.new().setup("hae", 72, 72)`.
func setup(new_boy_id: String, px_w: float, px_h: float) -> LanternboyPortrait:
	boy_id = new_boy_id
	custom_minimum_size = Vector2(px_w, px_h)
	return self


func _update_processing() -> void:
	set_process(is_visible_in_tree() and UiMotion.enabled())


func _process(delta: float) -> void:
	if not UiMotion.enabled():
		_t = 0.0
		set_process(false)
		queue_redraw()
		return
	_t += delta
	queue_redraw()


## Short (0.32 s) hop with a sparkle burst for the high-five reaction. Skipped when
## reduced motion is on.
func bounce() -> void:
	if not UiMotion.enabled() or not is_inside_tree():
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_bounce = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "_bounce", 1.0, 0.13).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self, "_bounce", 0.0, 0.19).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	var host: Control = get_tree().current_scene as Control
	SparkleBurst.spawn(host if host != null else self, global_position + size * 0.5)


func _draw() -> void:
	Art.draw(self, boy_id, Rect2(Vector2.ZERO, size), _t, true, _bounce)
