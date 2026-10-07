extends Control
## Decorative overlay for buttons/cards/tabs (Story 034). Mode "gloss" = soft top highlight,
## "shine" = gloss + an animated sheen sweep every few seconds (primary buttons),
## "tab" = glowing halo + underline when `lit` (active tab). Mouse-transparent, ~15 fps redraw,
## static under reduce motion. Attach with FxShine.attach(control, mode).

const FxLight := preload("res://scripts/fx_light.gd")

var mode := "gloss"
var lit := false
var radius := 12.0
var _t := 0.0
var _acc := 0.0
var _phase := 0.0


## Adds (or returns the existing) overlay to `host`.
static func attach(host: Control, m: String = "gloss", corner: float = 12.0) -> Control:
	var existing: Node = host.get_node_or_null("FxShine")
	if existing != null:
		return existing as Control
	var s: Control = (load("res://scenes/ui/fx_shine.gd") as GDScript).new()
	s.name = "FxShine"
	s.mode = m
	s.radius = corner
	host.add_child(s)
	return s


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_phase = float(get_instance_id() % 97) * 0.05
	set_process(mode != "gloss")


## Sets the lit state (tab mode) and redraws.
func set_lit(on: bool) -> void:
	lit = on
	queue_redraw()


func _process(delta: float) -> void:
	if FxLight.calm() or not is_visible_in_tree():
		return
	_t += delta
	_acc += delta
	if _acc >= 1.0 / 15.0 and (mode == "tab" and lit or mode == "shine"):
		_acc = 0.0
		queue_redraw()


func _draw() -> void:
	if size.x < 8.0 or size.y < 8.0:
		return
	var r := Rect2(Vector2(3, 3), size - Vector2(6, 6))
	if mode == "tab":
		if lit:
			var pulse: float = 0.85 + 0.15 * sin(FxLight.time(_t) * 3.0)
			FxLight.halo(self, Vector2(size.x * 0.5, size.y * 0.4), size.x * 0.55, UiTheme.ACCENT, 0.45 * pulse, size.y * 0.5)
			draw_rect(Rect2(size.x * 0.25, size.y - 5.0, size.x * 0.5, 3.0), Color(UiTheme.ACCENT.lightened(0.3), 0.95))
			FxLight.halo(self, Vector2(size.x * 0.5, size.y - 4.0), size.x * 0.4, UiTheme.ACCENT, 0.5 * pulse, 8.0)
		return
	FxLight.gradient_rect(self, Rect2(r.position, Vector2(r.size.x, r.size.y * 0.5)), Color(1, 1, 1, 0.14), Color(1, 1, 1, 0.0))
	if mode == "shine":
		var cycle := 3.4
		var p: float = fposmod(FxLight.time(_t) + _phase, cycle) / cycle * 1.6
		if p < 1.0 and not FxLight.calm():
			FxLight.sheen(self, r, p, 0.3)
