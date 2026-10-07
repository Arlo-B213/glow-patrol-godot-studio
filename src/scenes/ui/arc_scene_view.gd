class_name ArcSceneView
extends VBoxContainer
## One Lanternboy arc scene (Story 020): portrait, title and the scene lines one at a time with
## a Next button (last line: Done). Replays look identical; paying the first-view reward is the
## caller's job (ArcScenes.mark_seen). Build with ArcSceneView.create(boy, scene, on_close).

var _boy: Dictionary
var _scene: Dictionary
var _on_close: Callable
var _index := 0
var _line: Label
var _next: Button
var _dots: Label


## Creates the view; `on_close` is called after the last line.
static func create(boy: Dictionary, scene: Dictionary, on_close: Callable) -> ArcSceneView:
	var v := ArcSceneView.new()
	v._boy = boy
	v._scene = scene
	v._on_close = on_close
	return v


func _ready() -> void:
	add_theme_constant_override("separation", 10)
	var stage := ClubCards.portrait_tile(String(_boy["id"]), Color(_boy["color"]), Vector2(220, 260), 22)
	stage.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(stage)
	var eyebrow := Label.new()
	eyebrow.text = "%s - Story scene" % _boy["name"]
	eyebrow.theme_type_variation = "Caption"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(eyebrow)
	var title := Label.new()
	title.text = String(_scene["title"])
	title.theme_type_variation = "Heading"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var bubble := PanelContainer.new()
	bubble.theme_type_variation = "CardPanel"
	bubble.custom_minimum_size.y = 130
	add_child(bubble)
	_line = Label.new()
	_line.theme_type_variation = "Heading"
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line.add_theme_font_size_override("font_size", UiTheme.BODY + 2)
	bubble.add_child(_line)
	_dots = Label.new()
	_dots.theme_type_variation = "Caption"
	_dots.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_dots)
	_next = Button.new()
	_next.theme_type_variation = "PrimaryButton"
	_next.focus_mode = Control.FOCUS_NONE
	_next.custom_minimum_size.y = 56
	_next.pressed.connect(_advance)
	add_child(_next)
	_show_line()


func _show_line() -> void:
	var lines: Array = _scene["lines"]
	_line.text = "\"%s\"" % lines[_index]
	_dots.text = "%d / %d" % [_index + 1, lines.size()]
	_next.text = "Done" if _index >= lines.size() - 1 else "Next"


func _advance() -> void:
	if _index >= (_scene["lines"] as Array).size() - 1:
		_on_close.call()
		return
	_index += 1
	_show_line()
