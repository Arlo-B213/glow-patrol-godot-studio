extends Control
## App shell: topbar (points/level) + tab bar + screen swapping.
## Mirrors the web version's setScreen()/refreshTopbar(). Motion: Story 014.

const SCREEN_PATHS := {
	"home": "res://scenes/screens/hq_screen.tscn",
	"club": "res://scenes/screens/club_screen.tscn",
	"battle": "res://scenes/screens/battle_screen.tscn",
	"games": "res://scenes/screens/games_screen.tscn",
	"study": "res://scenes/screens/study_screen.tscn",
	"pets": "res://scenes/screens/pets_screen.tscn",
}

## Tab name -> [icon name, label text].
const TAB_VISUALS := {
	"home": ["home", "HQ"],
	"club": ["club", "Club"],
	"battle": ["battle", "Battle"],
	"games": ["games", "Games"],
	"study": ["study", "Study"],
	"pets": ["paw", "Pets"],
}

const TAB_HEIGHT := 68
const TAB_ICON_PX := 28

@onready var game_state: Node = get_node("/root/GameState")
@onready var content_area: Control = $Layout/ContentMargin/ContentArea
@onready var points_label: Label = $Layout/TopBarMargin/TopBar/PointsLabel
@onready var level_label: Label = $Layout/TopBarMargin/TopBar/LevelLabel
@onready var sound_button: Button = $Layout/TopBarMargin/TopBar/SoundButton

@onready var tab_buttons: Dictionary = {
	"home": $Layout/TabBarMargin/TabBar/TabHome,
	"club": $Layout/TabBarMargin/TabBar/TabClub,
	"battle": $Layout/TabBarMargin/TabBar/TabBattle,
	"games": $Layout/TabBarMargin/TabBar/TabGames,
	"study": $Layout/TabBarMargin/TabBar/TabStudy,
	"pets": $Layout/TabBarMargin/TabBar/TabPets,
}

var current_screen_name := ""

## Tab name -> {"icon": UiIcon, "label": Label, "box": Control}.
var _tab_parts: Dictionary = {}
var _tab_was_selected: Dictionary = {}
var _tabs_ready := false
var _sound_icon: UiIcon
var _top: TopBar
var _screen_tween: Tween


func _ready() -> void:
	theme = UiTheme.build()
	get_tree().node_added.connect(_on_node_added)
	sound_button.theme_type_variation = "SecondaryButton"
	sound_button.custom_minimum_size = Vector2(56, 56)
	points_label.theme_type_variation = "Heading"
	level_label.theme_type_variation = "Muted"
	_build_sound_icon()
	_top = TopBar.new(game_state, $Layout/TopBarMargin/TopBar, points_label, level_label, sound_button)
	for screen_name in tab_buttons.keys():
		var btn: Button = tab_buttons[screen_name]
		btn.theme_type_variation = "TabButton"
		btn.custom_minimum_size.y = TAB_HEIGHT
		btn.pressed.connect(_on_tab_pressed.bind(screen_name))
		btn.toggled.connect(func(_on: bool): _refresh_tab_visuals())
		_build_tab_content(screen_name, btn)
	_refresh_tab_visuals()
	_tabs_ready = true
	sound_button.pressed.connect(_on_sound_pressed)
	game_state.points_changed.connect(_top.on_points_changed)
	game_state.points_earned.connect(_on_points_earned)
	game_state.leveled_up.connect(_on_leveled_up)
	game_state.points_changed.connect(func(_v): _check_stickers())
	game_state.leveled_up.connect(func(_l): _check_stickers())
	game_state.pet_changed.connect(func(_id): _check_stickers())
	game_state.pet_stage_changed.connect(func(_id, _s): _check_stickers())
	refresh_topbar()
	_update_sound_button()
	_wire_existing_buttons(self)
	set_screen("home")
	_startup_flow.call_deferred()


## Wires press feedback on buttons added later anywhere in the tree.
func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		UiMotion.wire_press_feedback(node as BaseButton)
	if node is Button:
		# Deferred so the creator's own size assignments land first.
		UiTheme.ensure_touch.call_deferred(node as Button)


func _wire_existing_buttons(root: Node) -> void:
	for child in root.get_children():
		if child is BaseButton:
			UiMotion.wire_press_feedback(child as BaseButton)
		if child is Button:
			UiTheme.ensure_touch(child as Button)
		_wire_existing_buttons(child)


## Replaces the button text with an icon stacked above a caption label.
func _build_tab_content(screen_name: String, btn: Button) -> void:
	var visuals: Array = TAB_VISUALS[screen_name]
	btn.text = ""
	btn.tooltip_text = visuals[1]
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 2)
	btn.add_child(box)
	var icon := UiIcon.new().setup(visuals[0], UiTheme.TEXT_MUTED, TAB_ICON_PX)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(icon)
	var label := Label.new()
	label.text = visuals[1]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", UiTheme.CAPTION)
	box.add_child(label)
	_tab_parts[screen_name] = {"icon": icon, "label": label, "box": box}


## Recolours every tab's icon/label from its pressed state; pops a newly selected tab.
func _refresh_tab_visuals() -> void:
	for screen_name in _tab_parts.keys():
		var btn: Button = tab_buttons[screen_name]
		var parts: Dictionary = _tab_parts[screen_name]
		var selected := btn.button_pressed
		(parts["icon"] as UiIcon).set_tint(UiTheme.ACCENT if selected else UiTheme.TEXT_MUTED)
		(parts["label"] as Label).add_theme_color_override(
			"font_color", UiTheme.TEXT if selected else UiTheme.TEXT_MUTED)
		if _tabs_ready and selected and not _tab_was_selected.get(screen_name, false):
			UiMotion.pop(parts["box"] as Control)
		_tab_was_selected[screen_name] = selected


## Puts the speaker icon inside the sound button.
func _build_sound_icon() -> void:
	sound_button.text = ""
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sound_button.add_child(center)
	_sound_icon = UiIcon.new().setup("sound_on", UiTheme.TEXT, 28)
	center.add_child(_sound_icon)


const SCREEN_MUSIC := {"hq": "hq", "club": "club", "battle": "battle", "games": "games", "study": "study", "pets": "pets"}


func _on_tab_pressed(screen_name: String) -> void:
	Snd.play("tap")
	set_screen(screen_name)


func _on_sound_pressed() -> void:
	game_state.sound_on = not game_state.sound_on
	game_state.save_game()
	Snd.refresh()
	Snd.play("tap")
	_update_sound_button()


func _update_sound_button() -> void:
	var on: bool = game_state.sound_on
	sound_button.tooltip_text = "Sound On" if on else "Sound Off"
	_sound_icon.set_icon("sound_on" if on else "sound_off")
	_sound_icon.set_tint(UiTheme.TEXT if on else UiTheme.TEXT_MUTED)


func _on_points_earned(amount: int) -> void:
	UiMotion.float_text(self, _top.pill_pop_origin(), amount)


func _on_leveled_up(new_level: int) -> void:
	_top.refresh_level()
	SparkleBurst.spawn(self, _top.badge_center())
	get_node("/root/Toast").show_message("Level %d!" % new_level)


## Swaps the content screen; the new screen fades/slides in (<= 200 ms) when motion is on.
func set_screen(screen_name: String) -> void:
	current_screen_name = screen_name
	Snd.music(SCREEN_MUSIC.get(screen_name, "hq"))
	for name_key in tab_buttons.keys():
		var btn: Button = tab_buttons[name_key]
		btn.button_pressed = (name_key == screen_name)

	if _screen_tween != null and _screen_tween.is_valid():
		_screen_tween.kill()
	_screen_tween = null
	for child in content_area.get_children():
		child.queue_free()

	var path: String = SCREEN_PATHS.get(screen_name, "")
	if path == "":
		return
	var packed: PackedScene = load(path)
	if packed == null:
		return
	_check_stickers()
	var instance: Control = packed.instantiate()
	instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	content_area.add_child(instance)
	_screen_tween = UiMotion.fade_slide_in(instance)

	# Screens that expose a screen_requested signal can navigate other tabs
	# (e.g. HQ's nav cards). "club_lounge" opens the club tab; deeper
	# sub-navigation (opening the Lounge sub-tab specifically) is handled
	# once the club screen itself is built out.
	if instance.has_signal("screen_requested"):
		instance.screen_requested.connect(_on_child_screen_requested)


func _on_child_screen_requested(requested: String) -> void:
	if requested == "stickers":
		_open_stickers()
	elif requested == "tutorial":
		show_tutorial()
	elif requested == "club_lounge":
		set_screen("club")
	else:
		set_screen(requested)


func refresh_topbar() -> void:
	_top.refresh()


# ---------------- Onboarding, daily bonus, stickers (Story 022) ----------------

## Runs after the first frame: tutorial (first launch only), then the daily bonus.
func _startup_flow() -> void:
	await get_tree().process_frame
	if not game_state.tutorial_done:
		var tour := show_tutorial()
		await tour.finished
	show_daily_bonus()
	_check_stickers()


## Instances the tutorial over everything and marks it done when it ends.
func show_tutorial() -> TutorialOverlay:
	var tour := TutorialOverlay.new()
	var rects := {}
	for key in tab_buttons.keys():
		rects[key] = (tab_buttons[key] as Control).get_global_rect()
	add_child(tour)
	tour.start(rects)
	tour.finished.connect(func(_skipped: bool):
		game_state.tutorial_done = true
		game_state.save_game())
	return tour


## Shows the Daily Glow Bonus popup if today's bonus is unclaimed. Returns it or null.
func show_daily_bonus(today: String = "") -> DailyPopup:
	var info := DailyRewards.pending(game_state, today)
	if info.is_empty():
		return null
	var popup := DailyPopup.new().setup(game_state, info)
	popup.claimed.connect(func(_b: int): _check_stickers())
	add_child(popup)
	return popup


## Awards any newly met stickers with a toast each.
func _check_stickers() -> void:
	for s in Stickers.check(game_state):
		Snd.play("chapter")
		get_node("/root/Toast").show_message("New sticker: %s!" % s["name"])


## Replaces the content area with the sticker collection; Back returns to HQ.
func _open_stickers() -> void:
	for child in content_area.get_children():
		child.queue_free()
	var page := StickerPage.new().setup(game_state)
	page.closed.connect(func(): set_screen("home"))
	content_area.add_child(page)
