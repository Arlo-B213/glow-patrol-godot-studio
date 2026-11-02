class_name MissionQuiz
extends PanelContainer
## Quiz break inside a Lounge mission: one Study Hall question on a card over the brawl. The fight
## is paused while it is open. Pressing Continue emits `done(correct)`.

signal done(correct: bool)

var _question: Dictionary = {}
var _answered := false
var _correct := false
var _feedback: Label
var _continue: Button


## Builds the card for `question` (from StudyQuestions) and names the boy who asked for help.
func setup(question: Dictionary, boy_name: String) -> MissionQuiz:
	_question = question
	custom_minimum_size = Vector2(320, 0)
	theme_type_variation = "CardPanel"
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	add_child(box)
	var head := Label.new()
	head.text = "%s needs your help!" % boy_name
	head.theme_type_variation = "Heading"
	head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(head)
	var prompt := Label.new()
	prompt.text = _prompt_text(question)
	prompt.theme_type_variation = "Heading"
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(prompt)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)
	for choice in question["choices"]:
		var btn := Button.new()
		btn.text = String(choice)
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(140, 56)
		btn.pressed.connect(_on_choice.bind(String(choice), btn))
		grid.add_child(btn)
	_feedback = Label.new()
	_feedback.theme_type_variation = "Caption"
	_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_feedback)
	_continue = Button.new()
	_continue.text = "Continue"
	_continue.focus_mode = Control.FOCUS_NONE
	_continue.custom_minimum_size = Vector2(0, 56)
	_continue.visible = false
	_continue.pressed.connect(func(): done.emit(_correct))
	box.add_child(_continue)
	return self


## The question text, or the passage's question when the item has a passage.
static func _prompt_text(question: Dictionary) -> String:
	if question.has("passage"):
		return "%s\n\n%s" % [question["passage"], question["q"]]
	return String(question["q"])


func _on_choice(choice: String, btn: Button) -> void:
	if _answered:
		return
	_answered = true
	_correct = choice == String(_question["answer"])
	btn.modulate = Color("#52E8C6") if _correct else Color("#FF5FA2")
	_feedback.text = "Right! Your help lights up the lantern." if _correct \
		else "Not quite. The answer was %s." % _question["answer"]
	_continue.visible = true
