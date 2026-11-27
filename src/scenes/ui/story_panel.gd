class_name StoryPanel
extends ScrollContainer
## Story screen body (Story 004/020): progress bar, the chapter cards and the finale button.
## Build with StoryPanel.create(game_state, on_back, on_finale). Chapter 5 offers
## "Face the Grumble King" (before the finale is won) or "Replay finale" plus a
## "Story complete!" banner (after).

var _gs: Node
var _on_back: Callable
var _on_finale: Callable
var _on_quiz: Callable


## `gs` is the GameState node; `on_finale` starts the finale patrol.
static func create(gs: Node, on_back: Callable, on_finale: Callable, on_quiz: Callable = Callable()) -> StoryPanel:
	var p := StoryPanel.new()
	p._gs = gs
	p._on_back = on_back
	p._on_finale = on_finale
	p._on_quiz = on_quiz
	return p


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 12)
	add_child(vbox)
	var title := Label.new()
	title.text = StoryArc.TITLE
	title.theme_type_variation = "Heading"
	vbox.add_child(title)
	var claimed: int = int(_gs.story_claimed)
	var chapters := StoryArc.CHAPTERS
	var bar := ProgressBar.new()
	bar.max_value = chapters.size()
	bar.value = claimed
	bar.show_percentage = false
	bar.custom_minimum_size.y = 14
	vbox.add_child(bar)
	if _gs.finale_done:
		var done := Label.new()
		done.text = "Story complete! You are a Lantern Hero."
		done.theme_type_variation = "Heading"
		done.add_theme_color_override("font_color", UiTheme.GOLD)
		done.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(done)
	for i in chapters.size():
		vbox.add_child(_chapter_card(i, chapters[i], claimed))
	if _gs.finale_done:
		vbox.add_child(_text_card("Epilogue", StoryArc.FINALE_TEXT))
	var back := Button.new()
	back.text = "Back"
	back.theme_type_variation = "SecondaryButton"
	back.focus_mode = Control.FOCUS_NONE
	back.custom_minimum_size.y = 48
	back.pressed.connect(_on_back)
	vbox.add_child(back)


func _text_card(head_text: String, body_text: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = "CardPanel"
	var col := VBoxContainer.new()
	card.add_child(col)
	var head := Label.new()
	head.text = head_text
	head.theme_type_variation = "Heading"
	head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(head)
	var body := Label.new()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.theme_type_variation = "Muted"
	body.text = body_text
	col.add_child(body)
	return card


func _chapter_card(i: int, ch: Dictionary, claimed: int) -> PanelContainer:
	var open: bool = i < claimed
	var card := _text_card("Chapter %d: %s" % [i + 1, ch["title"] if open else "???"],
		StoryArc.text_of(ch) if open else StoryArc.trigger_hint(ch))
	if open:
		var col := card.get_child(0) as VBoxContainer
		if _gs.chapter_done(String(ch["id"])):
			var finished := Label.new()
			finished.text = "Chapter finished!"
			finished.theme_type_variation = "Muted"
			col.add_child(finished)
		else:
			var quiz_btn := Button.new()
			quiz_btn.text = "Take the chapter quiz"
			quiz_btn.theme_type_variation = "PrimaryButton"
			quiz_btn.focus_mode = Control.FOCUS_NONE
			quiz_btn.custom_minimum_size.y = 56
			quiz_btn.pressed.connect(_on_quiz.bind(i))
			col.add_child(quiz_btn)
	if i == StoryArc.CHAPTERS.size() - 1 and open:
		var btn := Button.new()
		btn.text = "Replay finale" if _gs.finale_done else "Face the Grumble King"
		btn.theme_type_variation = "SecondaryButton" if _gs.finale_done else "PrimaryButton"
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size.y = 56
		btn.pressed.connect(_on_finale)
		(card.get_child(0) as VBoxContainer).add_child(btn)
	return card
