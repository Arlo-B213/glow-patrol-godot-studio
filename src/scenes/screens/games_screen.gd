extends Control
## Mini-Games hub (Stories 026-030): a data-driven list of games. Each game view is a Control with
## `signal finished(score, earned)`; the hub shows the intro card, saves the best score, pays out
## once and shows the shared result screen.

## One entry per game. `lower_better` games (Memory Match: fewest moves) keep the smallest score.
const GAMES := [
	{"id": "rhythm", "icon": "music", "color": "ACCENT", "title": "Rhythm Tap", "desc": "Hit the beat in four lanes.",
		"heading": "Hit the Beat", "body": "Notes fall down four lanes. Tap the matching pad as each note crosses the line. Perfect timing scores more, and a 10 combo starts a FEVER!",
		"view": "res://scenes/battle/rhythm_tap_view.tscn", "done": "Song Complete!", "unit": "Best %d"},
	{"id": "memory", "icon": "cards", "color": "TEAL", "title": "Memory Match", "desc": "Find every matching pair.",
		"heading": "Match the Pairs", "body": "Flip two cards at a time and find every matching pair in as few moves as you can.",
		"view": "res://scenes/games/memory_match_view.gd", "done": "All Matched!", "unit": "Fewest moves: %d", "lower_better": true},
	{"id": "catch", "icon": "catch", "color": "GOLD", "title": "Star Catch", "desc": "Move to catch stars, dodge Gloomlings.",
		"heading": "Catch the Stars", "body": "Drag or use the arrows to move. Catch stars, dodge Gloomlings and chain catches for a combo. You have 40 seconds.",
		"view": "res://scenes/battle/star_catch_view.tscn", "done": "Time's Up!", "unit": "Best %d"},
	{"id": "lantern", "icon": "lantern", "color": "VIOLET", "title": "Lantern Says", "desc": "Watch the pattern, repeat it back.",
		"heading": "Watch, Then Repeat", "body": "Watch the lanterns light up, then tap them in the same order. Every round adds one more. You have three hearts.",
		"view": "res://scenes/games/lantern_says_view.gd", "done": "Pattern Broken!", "unit": "Best round %d"},
	{"id": "bubbles", "icon": "star", "color": "ACCENT", "title": "Glow Bubbles", "desc": "Aim, fire and pop the glowing orbs.",
		"heading": "Pop the Orbs", "body": "Drag to aim and let go to fire. Match 3 or more orbs of the same shape to pop them. Cut a cluster loose and it all falls! Don't let them reach the line.",
		"view": "res://scenes/games/bubbles_view.gd", "done": "Great Popping!", "unit": "Best %d"},
	{"id": "scramble", "icon": "reading", "color": "GOLD", "title": "Word Scramble", "desc": "Unscramble the letters to spell the word.",
		"heading": "Unscramble It", "body": "Tap the letters in the right order to spell the word. Use the clue, ask for a hint, or shuffle. Faster answers and streaks score more.",
		"view": "res://scenes/games/scramble_view.gd", "done": "Word Whiz!", "unit": "Best %d"},
]

@onready var game_state: Node = get_node("/root/GameState")
@onready var content: Control = %Content


func _ready() -> void:
	Snd.music("games")
	render_hub()


func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()


## The game table entry with `id`, or an empty Dictionary.
func _game(id: String) -> Dictionary:
	for g in GAMES:
		if g["id"] == id:
			return g
	return {}


## Accent colour for a game card.
func _col(g: Dictionary) -> Color:
	match String(g["color"]):
		"TEAL":
			return UiTheme.TEAL
		"GOLD":
			return UiTheme.GOLD
		"VIOLET":
			return UiTheme.VIOLET
	return UiTheme.ACCENT


func _best_text(g: Dictionary) -> String:
	var best: int = int(game_state.best_scores.get(g["id"], 0))
	if bool(g.get("lower_better", false)) and best <= 0:
		return "Fewest moves: —"
	return String(g["unit"]) % best


func render_hub() -> void:
	_clear_content()
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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
	for g in GAMES:
		vbox.add_child(UiCards.mode_card(g["icon"], _col(g), g["title"], g["desc"], _best_text(g), _show_intro.bind(g["id"])))


## Intro card for a game; "Start" launches it.
func _show_intro(id: String) -> void:
	var g: Dictionary = _game(id)
	_clear_content()
	content.add_child(UiCards.intro_card(g["icon"], _col(g), g["title"], g["heading"], g["body"],
		_best_text(g), "Start", _start_game.bind(id), "Back", render_hub))


## Creates the game's view (scene or script), adds it and listens for the result.
func _start_game(id: String) -> void:
	var g: Dictionary = _game(id)
	_clear_content()
	var res: Resource = load(g["view"])
	var view: Control = res.instantiate() if res is PackedScene else res.new()
	content.add_child(view)
	view.finished.connect(_on_game_finished.bind(id))


## Saves the best score, pays out once, and shows the shared result screen.
func _on_game_finished(score: int, earned: int, id: String) -> void:
	var g: Dictionary = _game(id)
	var best: int = int(game_state.best_scores.get(id, 0))
	if bool(g.get("lower_better", false)):
		if best <= 0 or score < best:
			game_state.best_scores[id] = score
	elif score > best:
		game_state.best_scores[id] = score
	game_state.earn_points(earned)
	game_state.save_game()
	var body: String = "Moves %d" % score if bool(g.get("lower_better", false)) else "Score %d" % score
	if id == "lantern":
		body = "You cleared %d %s" % [score, "round" if score == 1 else "rounds"]
	_clear_content()
	Snd.play("win")
	content.add_child(UiCards.result_card("star", g["done"], body, earned,
		"Play Again", _start_game.bind(id), "Back to Mini-Games", render_hub))
