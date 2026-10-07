class_name TopBar
extends RefCounted
## Builds and updates the top-bar pieces: star pill, level badge with XP ring and
## the motion toggle. Re-parents the scene's existing PointsLabel/LevelLabel.

var pill: PanelContainer
var badge: HBoxContainer
var ring: XpRing
var motion_button: Button

var _gs: Node
var _points_label: Label
var _level_label: Label
var _motion_icon: UiIcon
var _shown_points := 0


func _init(game_state: Node, bar: HBoxContainer, points_label: Label,
		level_label: Label, sound_button: Button) -> void:
	_gs = game_state
	_points_label = points_label
	_level_label = level_label
	_build(bar, sound_button)


func _build(bar: HBoxContainer, sound_button: Button) -> void:
	pill = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTheme.PANEL
	sb.set_border_width_all(2)
	sb.border_color = UiTheme.GOLD
	sb.set_corner_radius_all(999)
	sb.content_margin_left = 10
	sb.content_margin_right = 14
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	pill.add_theme_stylebox_override("panel", sb)
	pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var pbox := HBoxContainer.new()
	pbox.add_theme_constant_override("separation", 6)
	pill.add_child(pbox)
	bar.add_child(pill)
	pbox.add_child(UiIcon.new().setup("star", UiTheme.GOLD, 24))
	_points_label.reparent(pbox, false)
	_points_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	badge = HBoxContainer.new()
	badge.add_theme_constant_override("separation", 6)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.add_child(badge)
	ring = XpRing.new()
	badge.add_child(ring)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.add_child(center)
	center.add_child(UiIcon.new().setup("level", UiTheme.VIOLET, 22))
	_level_label.reparent(badge, false)
	_level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	motion_button = Button.new()
	motion_button.theme_type_variation = "SecondaryButton"
	motion_button.custom_minimum_size = Vector2(56, 56)
	motion_button.focus_mode = Control.FOCUS_NONE
	bar.add_child(motion_button)
	bar.move_child(motion_button, sound_button.get_index())
	var mc := CenterContainer.new()
	mc.set_anchors_preset(Control.PRESET_FULL_RECT)
	mc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	motion_button.add_child(mc)
	_motion_icon = UiIcon.new().setup("motion_on", UiTheme.TEXT, 28)
	mc.add_child(_motion_icon)
	motion_button.pressed.connect(_on_motion_pressed)
	update_motion_button()


## Sets every readout directly (no animation).
func refresh() -> void:
	_shown_points = _gs.star_points
	_points_label.text = "%d" % _shown_points
	_update_level(false)


## Animates the counter to the new total and updates level label / XP ring.
func on_points_changed(total: int) -> void:
	UiMotion.count_up(_points_label, _shown_points, total)
	_shown_points = total
	_update_level(true)


## Updates the level label and XP ring (animated ring) from GameState.
func refresh_level() -> void:
	_update_level(true)


## Level badge centre in global coordinates (for the celebration burst).
func badge_center() -> Vector2:
	return ring.get_global_rect().get_center()


## Global top-left of the spot just below the star pill (for "+N" pops).
func pill_pop_origin() -> Vector2:
	var r := pill.get_global_rect()
	return Vector2(r.position.x + r.size.x * 0.1, r.end.y + 2.0)  # just below the pill so the pop never covers the counter


## Syncs the motion button's icon and tooltip with GameState.reduce_motion.
func update_motion_button() -> void:
	var reduced: bool = _gs.reduce_motion
	motion_button.tooltip_text = "Motion: Reduced" if reduced else "Motion: On"
	_motion_icon.set_icon("motion_off" if reduced else "motion_on")
	_motion_icon.set_tint(UiTheme.TEXT_MUTED if reduced else UiTheme.TEXT)


func _on_motion_pressed() -> void:
	_gs.set_reduce_motion(not _gs.reduce_motion)
	update_motion_button()


func _update_level(animate: bool) -> void:
	var xp: int = _gs.total_earned
	_level_label.text = "Lv.%d" % _gs.level_for_xp(xp)
	var frac := float(xp % _gs.XP_PER_LEVEL) / float(_gs.XP_PER_LEVEL)
	if animate:
		ring.set_progress(frac)
	else:
		ring.progress = frac
