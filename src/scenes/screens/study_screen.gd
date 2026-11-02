extends Control
## Study Hall: Math, Grammar, and Reading quizzes by grade (1-5).
## Correct answers earn Star Points toward outfits and weapons.

const QUIZ_ROUND_LENGTH := StudyQuestions.ROUND_LENGTH

@onready var game_state: Node = get_node("/root/GameState")
@onready var toast: Node = get_node("/root/Toast")
@onready var content: Control = %Content

var _quiz_subject := ""
var _quiz_questions: Array = []
var _quiz_index := 0
var _quiz_correct := 0
var _quiz_earned := 0


func _ready() -> void:
	render_hub()


func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()


func _subject_label(subject: String) -> String:
	match subject:
		"math":
			return "Math"
		"grammar":
			return "Grammar"
		"reading":
			return "Reading"
	return subject


func render_hub() -> void:
	_clear_content()

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 14)
	scroll.add_child(vbox)

	var title := Label.new()
	title.text = "Trainee Lessons"
	title.theme_type_variation = "Heading"
	vbox.add_child(title)

	var pick := Label.new()
	pick.text = "Pick your grade"
	pick.theme_type_variation = "Heading"
	vbox.add_child(pick)
	var pills := HBoxContainer.new()
	pills.add_theme_constant_override("separation", 8)
	vbox.add_child(pills)
	for g in range(1, 6):
		var selected: bool = g == int(game_state.grade)
		var pill := Button.new()
		pill.text = "%d" % g
		pill.tooltip_text = "Grade %d" % g
		pill.theme_type_variation = "PrimaryButton" if selected else "SecondaryButton"
		pill.add_theme_font_size_override("font_size", 26)
		pill.focus_mode = Control.FOCUS_NONE
		pill.custom_minimum_size = Vector2(0, 64)
		pill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pill.pressed.connect(_on_grade_pressed.bind(g))
		pills.add_child(pill)
	var grade_note := Label.new()
	grade_note.text = "Grade %d questions" % int(game_state.grade)
	grade_note.theme_type_variation = "Caption"
	vbox.add_child(grade_note)

	var hint := Label.new()
	hint.text = "Correct answers earn Star Points toward new outfits and battle weapons."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.theme_type_variation = "Muted"
	vbox.add_child(hint)

	vbox.add_child(UiCards.mode_card("math", UiTheme.TEAL, "Math", "Add, subtract, multiply, divide.", "Best %d/%d" % [int(game_state.best_scores.get("study_math", 0)), QUIZ_ROUND_LENGTH["math"]], _on_subject_pressed.bind("math")))
	vbox.add_child(UiCards.mode_card("grammar", UiTheme.ACCENT, "Grammar", "Nouns, verbs, tricky sentences.", "Best %d/%d" % [int(game_state.best_scores.get("study_grammar", 0)), QUIZ_ROUND_LENGTH["grammar"]], _on_subject_pressed.bind("grammar")))
	vbox.add_child(UiCards.mode_card("reading", UiTheme.VIOLET, "Reading", "Short stories, then a question.", "Best %d/%d" % [int(game_state.best_scores.get("study_reading", 0)), QUIZ_ROUND_LENGTH["reading"]], _on_subject_pressed.bind("reading")))


func _on_grade_pressed(g: int) -> void:
	game_state.grade = g
	game_state.save_game()
	render_hub()


func _on_subject_pressed(subject: String) -> void:
	_run_quiz(subject)


func _run_quiz(subject: String) -> void:
	_quiz_subject = subject
	_quiz_questions = StudyQuestions.round_for(subject, game_state.grade)
	_quiz_index = 0
	_quiz_correct = 0
	_quiz_earned = 0
	_render_question()


func _render_question() -> void:
	_clear_content()
	var length: int = QUIZ_ROUND_LENGTH[_quiz_subject]
	var item: Dictionary = _quiz_questions[_quiz_index]
	var choices: Array = (item["choices"] as Array).duplicate()
	choices.shuffle()

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	content.add_child(vbox)

	var hud := HBoxContainer.new()
	hud.add_theme_constant_override("separation", 8)
	vbox.add_child(hud)
	var subj_icon := UiIcon.new().setup(_quiz_subject, UiTheme.TEXT_MUTED, 20)
	subj_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hud.add_child(subj_icon)
	var hud_label := Label.new()
	hud_label.text = "%s - Grade %d" % [_subject_label(_quiz_subject), game_state.grade]
	hud_label.theme_type_variation = "Caption"
	hud.add_child(hud_label)
	var hud_spacer := Control.new()
	hud_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.add_child(hud_spacer)
	var q_count_label := Label.new()
	q_count_label.text = "Question %d/%d" % [_quiz_index + 1, length]
	q_count_label.theme_type_variation = "Caption"
	hud.add_child(q_count_label)

	var progress := ProgressBar.new()
	progress.min_value = 0
	progress.max_value = length
	progress.value = _quiz_index + 1
	progress.show_percentage = false
	progress.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(progress)

	var card := PanelContainer.new()
	card.theme_type_variation = "CardPanel"
	vbox.add_child(card)

	var card_vbox := VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 10)
	card.add_child(card_vbox)

	if item.has("passage"):
		var passage_lbl := Label.new()
		passage_lbl.text = item["passage"]
		passage_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		passage_lbl.theme_type_variation = "Muted"
		card_vbox.add_child(passage_lbl)

	var q_lbl := Label.new()
	q_lbl.text = item["q"]
	q_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	q_lbl.theme_type_variation = "Title" if not item.has("passage") and str(item["q"]).length() < 30 else "Heading"
	card_vbox.add_child(q_lbl)

	for choice_text in choices:
		var cbtn := Button.new()
		cbtn.text = str(choice_text)
		cbtn.theme_type_variation = "SecondaryButton"
		cbtn.focus_mode = Control.FOCUS_NONE
		cbtn.custom_minimum_size = Vector2(0, 56)
		cbtn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		# Lighter than the card so answers read as buttons.
		var cstyle := UiTheme.box(UiTheme.PANEL_LIGHT, Color(UiTheme.TEXT.r, UiTheme.TEXT.g, UiTheme.TEXT.b, 0.3), 2, UiTheme.RADIUS, 14, 10, 10)
		for sname in ["normal", "hover", "pressed", "focus", "disabled"]:
			cbtn.add_theme_stylebox_override(sname, cstyle)
		cbtn.set_meta("base_style", cstyle)
		cbtn.pressed.connect(_on_choice_pressed.bind(cbtn, str(choice_text), str(item["answer"]), card_vbox))
		card_vbox.add_child(cbtn)


func _on_choice_pressed(picked_btn: Button, picked: String, correct_answer: String, card_vbox: VBoxContainer) -> void:
	for child in card_vbox.get_children():
		if child is Button:
			var b: Button = child
			b.disabled = true
			var base_style: StyleBoxFlat = b.get_meta("base_style")
			var result_style: StyleBoxFlat = base_style.duplicate()
			if b.text == correct_answer:
				result_style.bg_color = UiTheme.BG.lerp(UiTheme.TEAL, 0.35)
				result_style.border_color = UiTheme.TEAL
			elif b.text == picked and picked != correct_answer:
				result_style.bg_color = UiTheme.BG.lerp(UiTheme.ACCENT, 0.35)
				result_style.border_color = UiTheme.ACCENT
			b.add_theme_stylebox_override("normal", result_style)
			b.add_theme_stylebox_override("disabled", result_style)

	var is_correct: bool = picked == correct_answer
	var feedback := HBoxContainer.new()
	feedback.add_theme_constant_override("separation", 8)
	var feedback_lbl := Label.new()
	feedback_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	feedback_lbl.theme_type_variation = "Heading"
	var fb_icon: UiIcon
	if is_correct:
		_quiz_correct += 1
		Snd.play("correct")
		game_state.earn_points(3)
		_quiz_earned += 3
		feedback_lbl.text = "Correct! +3"
		feedback_lbl.add_theme_color_override("font_color", UiTheme.TEAL)  # special: feedback colour
		fb_icon = UiIcon.new().setup("star", UiTheme.GOLD, 24)
	else:
		Snd.play("wrong")
		feedback_lbl.text = "Not quite - the answer is \"%s\"." % correct_answer
		feedback_lbl.add_theme_color_override("font_color", UiTheme.ACCENT)  # special: feedback colour
		fb_icon = UiIcon.new().setup("close", UiTheme.ACCENT, 24)
	fb_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	feedback.add_child(fb_icon)
	feedback.add_child(feedback_lbl)
	card_vbox.add_child(feedback)

	var length: int = QUIZ_ROUND_LENGTH[_quiz_subject]
	var next_btn := Button.new()
	next_btn.text = "Next Question" if _quiz_index < length - 1 else "See Results"
	next_btn.focus_mode = Control.FOCUS_NONE
	next_btn.custom_minimum_size = Vector2(0, 56)
	next_btn.theme_type_variation = "PrimaryButton"
	next_btn.pressed.connect(_on_next_question_pressed)
	card_vbox.add_child(next_btn)


func _on_next_question_pressed() -> void:
	_quiz_index += 1
	var length: int = QUIZ_ROUND_LENGTH[_quiz_subject]
	if _quiz_index < length:
		_render_question()
	else:
		_finish_quiz()


func _finish_quiz() -> void:
	var length: int = QUIZ_ROUND_LENGTH[_quiz_subject]
	var key: String = "study_%s" % _quiz_subject
	if _quiz_correct > int(game_state.best_scores.get(key, 0)):
		game_state.best_scores[key] = _quiz_correct
		game_state.save_game()

	_clear_content()
	content.add_child(UiCards.result_card("star", "Nice work!",
		"You got %d/%d correct" % [_quiz_correct, length], _quiz_earned,
		"Study Again", _run_quiz.bind(_quiz_subject), "Back to Study Hall", render_hub))
