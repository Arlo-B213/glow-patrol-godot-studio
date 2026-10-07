extends Control
## Mini-Games hub: Rhythm Tap, Memory Match, Star Catch, Lantern Says.

## Memory Match faces: UiIcon names tinted with the parallel MEM_COLORS entry.
const MEM_ICONS := ["star", "heart", "lantern", "zap", "music", "catch"]
const MEM_COLORS := [UiTheme.GOLD, UiTheme.ACCENT, UiTheme.VIOLET, UiTheme.TEAL, UiTheme.ACCENT, UiTheme.GOLD]
const LANTERN_COLORS := [UiTheme.GOLD, UiTheme.TEAL, UiTheme.ACCENT, UiTheme.VIOLET]

@onready var game_state: Node = get_node("/root/GameState")
@onready var toast: Node = get_node("/root/Toast")
@onready var content: Control = %Content


func _ready() -> void:
	render_hub()


func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()


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
	title.text = "Pick a Game"
	title.theme_type_variation = "Heading"
	vbox.add_child(title)

	vbox.add_child(UiCards.mode_card("music", UiTheme.ACCENT, "Rhythm Tap", "Hit the beat in four lanes.", "Best %d" % int(game_state.best_scores.get("rhythm", 0)), _on_rhythm_pressed))
	vbox.add_child(UiCards.mode_card("cards", UiTheme.TEAL, "Memory Match", "Find every matching pair.", _memory_best_text(), _on_memory_pressed))
	vbox.add_child(UiCards.mode_card("catch", UiTheme.GOLD, "Star Catch", "Move to catch stars, dodge Gloomlings.", "Best %d" % int(game_state.best_scores.get("catch", 0)), _on_catch_pressed))
	vbox.add_child(UiCards.mode_card("lantern", UiTheme.VIOLET, "Lantern Says", "Watch the pattern, repeat it back.", "Best round %d" % int(game_state.best_scores.get("lantern", 0)), _on_lantern_pressed))


func _memory_best_text() -> String:
	var best: int = int(game_state.best_scores.get("memory", 0))
	if best <= 0:
		return "Fewest moves: —"
	return "Fewest moves: %d" % best


func _build_intro(icon: String, color: Color, eyebrow: String, heading: String, body: String,
		best_text: String, start_text: String, on_start: Callable) -> void:
	_clear_content()
	content.add_child(UiCards.intro_card(icon, color, eyebrow, heading, body, best_text,
		start_text, on_start, "Back", render_hub))


func _build_result(heading: String, body_text: String, on_again: Callable, on_done: Callable,
		earned: int = 0) -> void:
	_clear_content()
	Snd.play("win")
	content.add_child(UiCards.result_card("star", heading, body_text, earned,
		"Play Again", on_again, "Back to Mini-Games", on_done))


## Shows the Rhythm Tap intro; "Start" launches the game.
func _on_rhythm_pressed() -> void:
	_build_intro(
		"music", UiTheme.ACCENT,
		"Rhythm Tap",
		"Hit the Beat",
		"Notes fall down four lanes. Tap the matching lane button as each note crosses the line. Perfect timing scores more.",
		"Best %d" % int(game_state.best_scores.get("rhythm", 0)),
		"Start",
		_start_rhythm_game
	)


## Shows the Star Catch intro; "Start" launches the game.
func _on_catch_pressed() -> void:
	_build_intro(
		"catch", UiTheme.GOLD,
		"Star Catch",
		"Catch the Stars",
		"Hold the arrows to move your basket. Catch stars, dodge Gloomlings, and chain catches for a combo. You have 40 seconds.",
		"Best %d" % int(game_state.best_scores.get("catch", 0)),
		"Start",
		_start_catch_game
	)


# ---------------- Rhythm Tap ----------------

## Launches the Rhythm Tap view and listens for its result.
func _start_rhythm_game() -> void:
	_clear_content()
	var view := preload("res://scenes/battle/rhythm_tap_view.tscn").instantiate()
	content.add_child(view)
	view.finished.connect(_on_rhythm_finished)


## Saves the best score, pays out once, and shows the shared result screen.
func _on_rhythm_finished(score: int, earned: int) -> void:
	if score > int(game_state.best_scores.get("rhythm", 0)):
		game_state.best_scores["rhythm"] = score
	game_state.earn_points(earned)
	_build_result(
		"Song Complete!",
		"Score %d" % score,
		_start_rhythm_game,
		render_hub,
		earned
	)


# ---------------- Star Catch ----------------

## Launches the Star Catch view and listens for its result.
func _start_catch_game() -> void:
	_clear_content()
	var view := preload("res://scenes/battle/star_catch_view.tscn").instantiate()
	content.add_child(view)
	view.finished.connect(_on_catch_finished)


## Saves the best score, pays out once, and shows the shared result screen.
func _on_catch_finished(score: int, earned: int) -> void:
	if score > int(game_state.best_scores.get("catch", 0)):
		game_state.best_scores["catch"] = score
	game_state.earn_points(earned)
	_build_result(
		"Time's Up!",
		"Score %d" % score,
		_start_catch_game,
		render_hub,
		earned
	)


func _on_memory_pressed() -> void:
	_build_intro(
		"cards", UiTheme.TEAL,
		"Memory Match",
		"Find the Pairs",
		"Flip two cards at a time. Match every pair in as few moves as you can.",
		_memory_best_text(),
		"Deal Cards",
		_start_memory_game
	)


# ---------------- Memory Match ----------------

var _mem_grid: GridContainer = null
var _mem_moves := 0
var _mem_pairs := 0
var _mem_flipped: Array = []
var _mem_lock := false
var _mem_moves_label: Label = null
var _mem_pairs_label: Label = null


func _start_memory_game() -> void:
	_clear_content()
	_mem_moves = 0
	_mem_pairs = 0
	_mem_flipped = []
	_mem_lock = false

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 12)
	content.add_child(vbox)

	var hud := HBoxContainer.new()
	vbox.add_child(hud)
	_mem_moves_label = Label.new()
	_mem_moves_label.text = "Moves 0"
	hud.add_child(_mem_moves_label)
	var hud_spacer := Control.new()
	hud_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.add_child(hud_spacer)
	_mem_pairs_label = Label.new()
	_mem_pairs_label.text = "Pairs 0/%d" % MEM_ICONS.size()
	hud.add_child(_mem_pairs_label)

	_mem_grid = GridContainer.new()
	_mem_grid.columns = 3
	_mem_grid.add_theme_constant_override("h_separation", 10)
	_mem_grid.add_theme_constant_override("v_separation", 10)
	vbox.add_child(_mem_grid)

	var deck: Array = []
	for icon in MEM_ICONS:
		deck.append(icon)
		deck.append(icon)
	deck.shuffle()

	for icon in deck:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 90)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.focus_mode = Control.FOCUS_NONE
		btn.set_meta("icon", icon)
		btn.set_meta("flipped", false)
		btn.set_meta("matched", false)
		btn.pressed.connect(_on_memory_card_pressed.bind(btn))
		_mem_grid.add_child(btn)
		_mem_show_face(btn, false)


## Draws a memory card either face-down (styled back with a "?" mark) or
## face-up (rounded tile with the coloured UiIcon).
func _mem_show_face(btn: Button, face_up: bool) -> void:
	var old: Node = btn.get_node_or_null("Face")
	if old != null:
		btn.remove_child(old)
		old.queue_free()
	var sb: StyleBoxFlat
	var mark: Control
	if face_up:
		var color: Color = MEM_COLORS[MEM_ICONS.find(btn.get_meta("icon"))]
		sb = UiTheme.box(UiTheme.BG.lerp(color, 0.16), color, 2, UiTheme.RADIUS, 0, 0, 0)
		mark = UiIcon.new().setup(btn.get_meta("icon"), color, 44)
	else:
		sb = UiTheme.box(UiTheme.PANEL, UiTheme.PANEL_LIGHT, 2, UiTheme.RADIUS, 0, 0, 0, 3)
		var q := Label.new()
		q.text = "?"
		q.theme_type_variation = "Title"
		q.add_theme_color_override("font_color", UiTheme.VIOLET)  # special: card-back mark
		mark = q
	for sname in ["normal", "hover", "pressed", "focus", "disabled"]:
		btn.add_theme_stylebox_override(sname, sb)
	var cc := CenterContainer.new()
	cc.name = "Face"
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cc.add_child(mark)
	btn.add_child(cc)


func _on_memory_card_pressed(btn: Button) -> void:
	if _mem_lock or btn.get_meta("flipped") or btn.get_meta("matched"):
		return
	btn.set_meta("flipped", true)
	_mem_show_face(btn, true)
	_mem_flipped.append(btn)

	if _mem_flipped.size() == 2:
		_mem_moves += 1
		_mem_moves_label.text = "Moves %d" % _mem_moves
		_mem_lock = true
		await get_tree().create_timer(0.65).timeout
		var a: Button = _mem_flipped[0]
		var b: Button = _mem_flipped[1]
		if a.get_meta("icon") == b.get_meta("icon"):
			a.set_meta("matched", true)
			b.set_meta("matched", true)
			_mem_pairs += 1
			_mem_pairs_label.text = "Pairs %d/%d" % [_mem_pairs, MEM_ICONS.size()]
			if _mem_pairs == MEM_ICONS.size():
				_finish_memory()
		else:
			a.set_meta("flipped", false)
			b.set_meta("flipped", false)
			_mem_show_face(a, false)
			_mem_show_face(b, false)
		_mem_flipped = []
		_mem_lock = false


func _finish_memory() -> void:
	var earned: int = max(5, min(30, 30 - _mem_moves))
	game_state.earn_points(earned)
	var best: int = int(game_state.best_scores.get("memory", 0))
	if best <= 0 or _mem_moves < best:
		game_state.best_scores["memory"] = _mem_moves
	_build_result(
		"All Matched!",
		"Moves %d" % _mem_moves,
		_start_memory_game,
		render_hub,
		earned
	)


# ---------------- Lantern Says ----------------

var _ls_sequence: Array = []
var _ls_player_index := 0
var _ls_accepting := false
var _ls_ended := false
var _ls_buttons: Array = []
var _ls_status_label: Label = null
var _ls_round_label: Label = null


func _on_lantern_pressed() -> void:
	_build_intro(
		"lantern", UiTheme.VIOLET,
		"Lantern Says",
		"Watch, then Repeat",
		"The lanterns light up in a pattern. Tap them back in the same order — the pattern grows by one each round.",
		"Best round: %d" % int(game_state.best_scores.get("lantern", 0)),
		"Start",
		_start_lantern_game
	)


func _start_lantern_game() -> void:
	_clear_content()
	_ls_sequence = []
	_ls_player_index = 0
	_ls_accepting = false
	_ls_ended = false
	_ls_buttons = []

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 12)
	content.add_child(vbox)

	var hud := HBoxContainer.new()
	vbox.add_child(hud)
	_ls_round_label = Label.new()
	_ls_round_label.text = "Round 0"
	hud.add_child(_ls_round_label)
	var hud_spacer := Control.new()
	hud_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.add_child(hud_spacer)
	var best_label := Label.new()
	best_label.text = "Best %d" % int(game_state.best_scores.get("lantern", 0))
	best_label.add_theme_color_override("font_color", UiTheme.GOLD)  # special: best score
	hud.add_child(best_label)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	vbox.add_child(grid)

	for i in range(4):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 130)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.focus_mode = Control.FOCUS_NONE
		btn.disabled = true
		var lc: Color = LANTERN_COLORS[i]
		var style := UiTheme.box(Color(lc.r, lc.g, lc.b, 0.35), lc, 2, 18, 0, 0, 0)
		for sname in ["normal", "hover", "pressed", "focus", "disabled"]:
			btn.add_theme_stylebox_override(sname, style)
		var cc := CenterContainer.new()
		cc.set_anchors_preset(Control.PRESET_FULL_RECT)
		cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var lic := UiIcon.new().setup("lantern", lc, 64)
		lic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cc.add_child(lic)
		btn.add_child(cc)
		btn.set_meta("lantern_index", i)
		btn.set_meta("base_style", style)
		btn.pressed.connect(_on_lantern_button_pressed.bind(i))
		grid.add_child(btn)
		_ls_buttons.append(btn)

	_ls_status_label = Label.new()
	_ls_status_label.text = "Get ready..."
	_ls_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ls_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ls_status_label.theme_type_variation = "Muted"
	vbox.add_child(_ls_status_label)

	_lantern_next_round()


func _lantern_set_disabled(disabled: bool) -> void:
	for btn in _ls_buttons:
		btn.disabled = disabled


func _lantern_flash(i: int, dur: float) -> void:
	var btn: Button = _ls_buttons[i]
	var flash_style: StyleBoxFlat = btn.get_meta("base_style").duplicate()
	flash_style.bg_color.a = 1.0
	btn.add_theme_stylebox_override("normal", flash_style)
	btn.add_theme_stylebox_override("disabled", flash_style)
	await get_tree().create_timer(dur).timeout
	if not is_instance_valid(btn):
		return
	var base_style: StyleBoxFlat = btn.get_meta("base_style")
	btn.add_theme_stylebox_override("normal", base_style)
	btn.add_theme_stylebox_override("disabled", base_style)


func _lantern_play_sequence() -> void:
	await get_tree().create_timer(0.4).timeout
	for i in range(_ls_sequence.size()):
		if _ls_ended:
			return
		_lantern_flash(_ls_sequence[i], 0.42)
		await get_tree().create_timer(0.6).timeout
	if _ls_ended:
		return
	_ls_accepting = true
	_lantern_set_disabled(false)
	_ls_status_label.text = "Your turn — repeat it!"


func _lantern_next_round() -> void:
	_ls_sequence.append(randi() % 4)
	_ls_round_label.text = "Round %d" % _ls_sequence.size()
	_ls_player_index = 0
	_ls_accepting = false
	_lantern_set_disabled(true)
	_ls_status_label.text = "Watch the pattern..."
	_lantern_play_sequence()


func _on_lantern_button_pressed(i: int) -> void:
	if not _ls_accepting or _ls_ended:
		return
	_lantern_flash(i, 0.22)
	if _ls_sequence[_ls_player_index] == i:
		_ls_player_index += 1
		if _ls_player_index == _ls_sequence.size():
			_ls_accepting = false
			_lantern_set_disabled(true)
			_ls_status_label.text = "Nice! Next pattern..."
			await get_tree().create_timer(0.7).timeout
			if not _ls_ended:
				_lantern_next_round()
	else:
		_ls_accepting = false
		_lantern_set_disabled(true)
		_end_lantern_game()


func _end_lantern_game() -> void:
	_ls_ended = true
	var rounds_cleared: int = _ls_sequence.size() - 1
	var earned: int = max(5, rounds_cleared * 3)
	game_state.earn_points(earned)
	if rounds_cleared > int(game_state.best_scores.get("lantern", 0)):
		game_state.best_scores["lantern"] = rounds_cleared
	var round_word: String = "round" if rounds_cleared == 1 else "rounds"
	_build_result(
		"Pattern Broken!",
		"You cleared %d %s" % [rounds_cleared, round_word],
		_start_lantern_game,
		render_hub,
		earned
	)
