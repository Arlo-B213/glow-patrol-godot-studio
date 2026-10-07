extends Control
## Battle Arena hub: Zap Patrol (tap game) and Alley Brawl (beat-'em-up, WIP).

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

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 14)
	content.add_child(vbox)

	var title := Label.new()
	title.text = "Pick a Patrol"
	title.theme_type_variation = "Heading"
	vbox.add_child(title)

	vbox.add_child(UiCards.mode_card("zap", UiTheme.GOLD, "Zap Patrol", "Tap Gloomlings before they float away.", "Best %d" % int(game_state.best_scores.get("battle", 0)), _on_zap_card_pressed))
	vbox.add_child(UiCards.mode_card("fist", UiTheme.ACCENT, "Alley Brawl", "Walk up and punch - a beat-'em-up patrol.", "Best %d" % int(game_state.best_scores.get("brawl", 0)), _on_brawl_card_pressed))
	var arc := preload("res://scripts/story_arc.gd")
	var done: int = arc.unlocked_count(int(game_state.story_wins))
	vbox.add_child(UiCards.mode_card("star", UiTheme.TEAL, arc.TITLE, "Clear patrols to unlock the next chapter.", "Chapter %d/%d" % [done, arc.CHAPTERS.size()], render_story))


func _build_intro(icon: String, color: Color, eyebrow: String, heading: String, body: String,
		best_text: String, start_text: String, on_start: Callable) -> void:
	_clear_content()
	content.add_child(UiCards.intro_card(icon, color, eyebrow, heading, body, best_text,
		start_text, on_start, "Back", render_hub))


func _on_zap_card_pressed() -> void:
	_build_intro(
		"zap", UiTheme.GOLD,
		"Zap Patrol",
		"Zap the Gloomlings",
		"Tap the little shadow blobs before they reach the top. Watch out — the Grumble King shows up partway through and takes five hits!",
		"Best score: %d" % int(game_state.best_scores.get("battle", 0)),
		"Start Patrol",
		_start_zap_game
	)


func _on_brawl_card_pressed() -> void:
	_build_intro(
		"fist", UiTheme.ACCENT,
		"Alley Brawl",
		"Walk up and zap 'em",
		"Walk through three glowing districts, punch Gloomlings and hold Block to stop their bumps. Clear 3 waves, then take down the boss. Drag to move, or use A/D, J and K. You've got 3 hearts.",
		"Best score: %d" % int(game_state.best_scores.get("brawl", 0)),
		"Start Brawl",
		_start_brawl_game
	)


func _start_zap_game() -> void:
	_clear_content()
	var view := preload("res://scenes/battle/zap_patrol_view.tscn").instantiate()
	content.add_child(view)
	view.finished.connect(_on_zap_finished)


func _on_zap_finished(score: int, earned: int) -> void:
	if score > int(game_state.best_scores.get("battle", 0)):
		game_state.best_scores["battle"] = score
	game_state.earn_points(earned)
	_build_result("Patrol Complete!", score, earned, _start_zap_game, render_hub, score > 0)


## Launches the Alley Brawl view and listens for its result.
func _start_brawl_game() -> void:
	_clear_content()
	var view := preload("res://scenes/battle/alley_brawl_view.tscn").instantiate()
	content.add_child(view)
	view.finished.connect(_on_brawl_finished)


## Saves the best score, pays out once, and shows the shared result screen.
func _on_brawl_finished(score: int, earned: int, won: bool) -> void:
	if score > int(game_state.best_scores.get("brawl", 0)):
		game_state.best_scores["brawl"] = score
	game_state.earn_points(earned)
	var heading: String = "Alley Cleared!" if won else "Brawl Over"
	_build_result(heading, score, earned, _start_brawl_game, render_hub, won)


func _build_result(heading: String, score: int, earned: int, on_again: Callable, on_done: Callable, cleared: bool = false, counts_for_story: bool = true) -> void:
	_clear_content()
	Snd.play("win" if cleared else "lose")
	content.add_child(UiCards.result_card("star", heading, "Score %d" % score, earned,
		"Patrol Again" if counts_for_story else "Try Again", on_again, "Back to Battle Menu" if counts_for_story else "Back to Story", on_done))
	if cleared and counts_for_story:
		for ch in game_state.record_battle_win():
			toast.show_message("Story: %s" % ch["title"])
			var outfit: Dictionary = StoryRewards.outfit_for_title(String(ch["title"]))
			if not outfit.is_empty():
				toast.show_message("New outfit: %s" % outfit["name"])


## Story arc screen (Story 004/020): chapters, plus the finale button once chapter 5 is open.
func render_story() -> void:
	_clear_content()
	content.add_child(StoryPanel.create(game_state, render_hub, _start_finale))


## Launches Alley Brawl straight into the Grumble King (finale option on the brawl view).
func _start_finale() -> void:
	_clear_content()
	var view := preload("res://scenes/battle/alley_brawl_view.tscn").instantiate()
	view.finale = true
	content.add_child(view)
	view.finished.connect(_on_finale_finished)


## Finale result: a win pays the one-time Lantern Hero rewards (replays pay nothing extra);
## a loss only offers another try, with no penalty beyond the normal run payout.
func _on_finale_finished(score: int, earned: int, won: bool) -> void:
	if score > int(game_state.best_scores.get("brawl", 0)):
		game_state.best_scores["brawl"] = score
	game_state.earn_points(earned)
	if not won:
		_build_result("Try Again?", score, earned, _start_finale, render_story, false, false)
		return
	var rewards: Dictionary = StoryRewards.grant_finale(game_state)
	if rewards.is_empty():
		_build_result("Finale Cleared!", score, earned, _start_finale, render_story, true, false)
		return
	_clear_content()
	content.add_child(FinaleWinCard.create(rewards, render_story))
