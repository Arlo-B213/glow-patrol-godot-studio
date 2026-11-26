class_name ChapterQuiz
extends Control
## Chapter quiz (saga v2): a chapter's reading questions, one at a time, on the Lounge mission
## question card (MissionQuiz). Right answers count; PASS_NEEDED of them finish the chapter.
## Emits finished(passed) from the result card. A fail can be retried from the story screen.

signal finished(passed: bool)

const PASS_NEEDED := 2

var _questions: Array = []
var _boy_name := ""
var _index := 0
var _right := 0
var _slot: CenterContainer


## Quiz for `questions` (StudyQuestions.round_for) asked by `boy_name`.
static func create(questions: Array, boy_name: String) -> ChapterQuiz:
	var q := ChapterQuiz.new()
	q._questions = questions
	q._boy_name = boy_name
	return q


## True when `right` answers pass the chapter.
static func passed(right: int) -> bool:
	return right >= PASS_NEEDED


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_slot = CenterContainer.new()
	_slot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_slot)
	if _questions.is_empty():
		_show_result()
	else:
		_show_question()


func _show_question() -> void:
	_clear()
	var card := MissionQuiz.new().setup(_questions[_index], _boy_name)
	card.done.connect(_on_answered)
	_slot.add_child(card)


func _on_answered(correct: bool) -> void:
	if correct:
		_right += 1
	_index += 1
	if _index >= _questions.size():
		_show_result()
	else:
		_show_question()


func _show_result() -> void:
	_clear()
	var card := PanelContainer.new()
	card.theme_type_variation = "CardPanel"
	card.custom_minimum_size = Vector2(320, 0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	card.add_child(box)
	var head := Label.new()
	head.text = "Chapter passed!" if passed(_right) else "Almost there!"
	head.theme_type_variation = "Heading"
	box.add_child(head)
	var score := Label.new()
	score.text = "You got %d of %d right. %d needed to pass." % [_right, _questions.size(), PASS_NEEDED]
	score.theme_type_variation = "Muted"
	score.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(score)
	var btn := Button.new()
	btn.text = "Finish" if passed(_right) else "Back to the story"
	btn.theme_type_variation = "PrimaryButton"
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size.y = 56
	btn.pressed.connect(func(): finished.emit(passed(_right)))
	box.add_child(btn)
	_slot.add_child(card)


func _clear() -> void:
	for child in _slot.get_children():
		child.queue_free()
