class_name DailyPopup
extends Control
const FD := preload("res://scripts/fast_draw.gd")
## "Daily Glow Bonus!" card (Story 022): streak flames, the star bonus and a Claim button.
## The bonus is paid by DailyRewards.claim, which cannot pay twice on one date.

## Emitted after the bonus was claimed (before the popup frees itself).
signal claimed(bonus: int)

const FLAMES_SHOWN := 7

var _gs: Node
var _info: Dictionary = {}


## Flame icons in a row: the first `lit` glow, the rest are dim outlines.
class FlameRow extends Control:
	var lit := 1

	func _init() -> void:
		custom_minimum_size = Vector2(0, 56)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var slot := size.x / float(FLAMES_SHOWN)
		for i in FLAMES_SHOWN:
			var c := Vector2(slot * (i + 0.5), size.y * 0.5)
			var on := i < lit
			var col := UiTheme.GOLD if on else UiTheme.LOCKED
			var h := 22.0
			var pts := PackedVector2Array([c + Vector2(0, -h), c + Vector2(h * 0.55, -h * 0.2),
				c + Vector2(h * 0.7, h * 0.35), c + Vector2(h * 0.35, h * 0.85),
				c + Vector2(-h * 0.35, h * 0.85), c + Vector2(-h * 0.7, h * 0.35),
				c + Vector2(-h * 0.5, -h * 0.25), c + Vector2(-h * 0.15, -h * 0.05)])
			FD.poly(self, pts, col.darkened(0.15) if on else col.darkened(0.4))
			if on:
				var inner := PackedVector2Array([c + Vector2(0, -h * 0.2), c + Vector2(h * 0.35, h * 0.35),
					c + Vector2(h * 0.2, h * 0.7), c + Vector2(-h * 0.2, h * 0.7), c + Vector2(-h * 0.35, h * 0.35)])
				FD.poly(self, inner, Color("#FFF1B8"))


## Builds the popup for `game_state` and a pending bonus from DailyRewards.pending().
func setup(game_state: Node, info: Dictionary) -> DailyPopup:
	_gs = game_state
	_info = info
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0.04, 0.02, 0.1, 0.78)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var card := PanelContainer.new()
	card.theme_type_variation = "CardPanel"
	card.custom_minimum_size = Vector2(560, 0)
	center.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	card.add_child(box)
	box.add_child(_label("Daily Glow Bonus!", "Title", 32, UiTheme.GOLD))
	var flames := FlameRow.new()
	flames.lit = mini(int(info["streak"]), FLAMES_SHOWN)
	box.add_child(flames)
	var streak := int(info["streak"])
	box.add_child(_label("Day %d in a row!" % streak if streak > 1 else "Welcome back, hunter!", "Heading", 22))
	var stars := HBoxContainer.new()
	stars.alignment = BoxContainer.ALIGNMENT_CENTER
	stars.add_theme_constant_override("separation", 8)
	stars.add_child(UiIcon.new().setup("star", UiTheme.GOLD, 44))
	var bonus_lbl := _label("+%d" % int(info["bonus"]), "Title", 40, UiTheme.GOLD)
	bonus_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	stars.add_child(bonus_lbl)
	box.add_child(stars)
	box.add_child(_label("Come back tomorrow for an even bigger glow!", "Muted", 16))
	var btn := Button.new()
	btn.text = "Claim!"
	btn.theme_type_variation = "PrimaryButton"
	btn.custom_minimum_size.y = 64
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(claim)
	box.add_child(btn)
	return self


## Pays the bonus (once) and closes the popup.
func claim() -> void:
	if DailyRewards.claim(_gs, _info):
		Snd.play("coin")
		SparkleBurst.spawn(get_parent() as Control, get_viewport_rect().size / 2.0)
		claimed.emit(int(_info["bonus"]))
	queue_free()


func _label(text: String, variation: String, font_px: int, color: Variant = null) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	l.add_theme_font_size_override("font_size", font_px)
	if color != null:
		l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l
