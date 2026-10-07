extends CanvasLayer
## Global toast notifications, mirroring the web version's showToast().

var _label: Label
var _timer: Timer
var _panel_ref: PanelContainer
var _icon: Control


## Toast pill style: soft pink glow border + shadow.
func _glow_box(sb: StyleBoxFlat) -> StyleBoxFlat:
	sb.set_border_width_all(2)
	sb.border_color = UiTheme.ACCENT
	sb.shadow_color = Color(UiTheme.ACCENT, 0.5)
	sb.shadow_size = 10
	sb.anti_aliasing = true
	return sb


func _ready() -> void:
	layer = 100
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	margin.add_theme_constant_override("margin_bottom", 110)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(center)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#F5EFFF")
	sb.corner_radius_top_left = 999
	sb.corner_radius_top_right = 999
	sb.corner_radius_bottom_left = 999
	sb.corner_radius_bottom_right = 999
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 9
	sb.content_margin_bottom = 9
	panel.add_theme_stylebox_override("panel", sb)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(panel)

	panel.add_theme_stylebox_override("panel", _glow_box(sb))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(row)
	_icon = UiIcon.new().setup("star", UiTheme.ACCENT_DARK, 20)
	row.add_child(_icon)
	_label = Label.new()
	_label.add_theme_color_override("font_color", Color("#150E2B"))
	_label.add_theme_font_size_override("font_size", 14)
	row.add_child(_label)

	panel.visible = false
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = 1.8
	_timer.timeout.connect(func(): panel.visible = false)
	add_child(_timer)

	_panel_ref = panel


func show_message(text: String) -> void:
	_label.text = text
	_panel_ref.visible = true
	_timer.start()
	UiMotion.pop(_panel_ref, 1.1, 0.22)
	if _icon != null and UiMotion.enabled():
		UiMotion.pop(_icon, 1.5, 0.35)
