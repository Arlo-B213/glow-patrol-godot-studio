class_name FinaleWinCard
extends Control
const FD := preload("res://scripts/fast_draw.gd")
## "Lantern Hero!" celebration card (Story 020): code-drawn glow rays behind the hunter hero
## portrait, repeating sparkle bursts, the title and the rewards list. Build with
## FinaleWinCard.create(rewards, on_done); `rewards` is StoryRewards.grant_finale()'s result.

const HunterPortrait := preload("res://scenes/ui/hunter_portrait.gd")
const RAY_COUNT := 14
const BURST_EVERY := 1.4

var _rewards: Dictionary = {}
var _on_done: Callable
var _t := 0.0
var _burst_clock := 0.0
var _portrait: Control


## Creates a full-rect card. `on_done` is called by the Continue button.
static func create(rewards: Dictionary, on_done: Callable) -> FinaleWinCard:
	var card := FinaleWinCard.new()
	card._rewards = rewards
	card._on_done = on_done
	return card


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 8)
	add_child(col)
	_portrait = HunterPortrait.new()
	_portrait.hero = true
	_portrait.custom_minimum_size = Vector2(200, 250)
	_portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(_portrait)
	col.add_child(_label("Lantern Hero!", "Title", UiTheme.GOLD))
	col.add_child(_label("Every lamp on the street is glowing again.", "Muted", null))
	for line in reward_lines(_rewards):
		col.add_child(_label(line, "Heading", null))
	var btn := Button.new()
	btn.text = "Continue"
	btn.theme_type_variation = "PrimaryButton"
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(0, 56)
	btn.pressed.connect(_on_done)
	col.add_child(btn)
	_burst.call_deferred()
	Snd.play("win")


## Text lines for a grant_finale() result (also used by checks).
static func reward_lines(rewards: Dictionary) -> Array:
	var out: Array = ["+%d Star Points" % int(rewards.get("stars", 0))]
	if String(rewards.get("outfit", "")) != "":
		out.append("New outfit: %s" % rewards["outfit"])
	if String(rewards.get("egg", "")) != "":
		out.append("A free %s egg!" % rewards["egg"])
	return out


func _label(text: String, variation: String, color) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if color != null:
		l.add_theme_color_override("font_color", color)
	return l


func _burst() -> void:
	if not is_inside_tree() or _portrait == null:
		return
	var c: Vector2 = _portrait.global_position + _portrait.size * 0.5
	for off in [Vector2(-70, -60), Vector2(70, -40), Vector2(0, 40)]:
		SparkleBurst.spawn(self, c + off)


func _process(delta: float) -> void:
	_t += delta
	_burst_clock += delta
	if _burst_clock >= BURST_EVERY:
		_burst_clock = 0.0
		_burst()
	queue_redraw()


func _draw() -> void:
	if _portrait == null:
		return
	var c: Vector2 = _portrait.global_position - global_position + _portrait.size * 0.5
	var spin: float = 0.0 if UiMotion.enabled() == false else _t * 0.15
	var reach: float = maxf(size.x, size.y)
	for i in RAY_COUNT:
		var a := TAU * float(i) / RAY_COUNT + spin
		var w := TAU / RAY_COUNT * 0.32
		FD.poly(self, PackedVector2Array([c,
			c + Vector2(cos(a - w), sin(a - w)) * reach, c + Vector2(cos(a + w), sin(a + w)) * reach]),
			Color(UiTheme.GOLD.r, UiTheme.GOLD.g, UiTheme.GOLD.b, 0.08))
