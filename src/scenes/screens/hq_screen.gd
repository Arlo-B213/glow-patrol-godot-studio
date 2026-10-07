extends Control
## HQ / home screen — mirrors the web version's renderHome().

signal screen_requested(screen_name: String)

const FORECASTS := [
	"Tonight's forecast: light fog, three Gloomlings spotted near the noodle cart.",
	"Clear skies. The Lanternboys say it's a good night for an encore.",
	"Static in the air — Grumbles are extra grumpy tonight. Warm up your zap.",
	"Moth migration overhead. Nun says that means good luck for hunters.",
	"Quiet streets, loud stars. Perfect night to hang out at the clubhouse.",
	"Storm clouds rolling in from the east — patrol in pairs tonight.",
	"The alley cats are on edge. Something's brewing near the arcade.",
]

const HunterPortrait := preload("res://scenes/ui/hunter_portrait.gd")

@onready var game_state: Node = get_node("/root/GameState")
@onready var forecast_label: Label = %ForecastLabel
@onready var level_label: Label = %LevelLabel
@onready var xp_amount_label: Label = %XpAmountLabel
@onready var xp_bar: ProgressBar = %XpBar
@onready var stat_points: Label = %StatPoints
@onready var stat_outfits: Label = %StatOutfits
@onready var stat_friend: Label = %StatFriend
@onready var avatar_panel: PanelContainer = %AvatarPanel
@onready var nav_club: Button = %NavClub
@onready var nav_battle: Button = %NavBattle
@onready var nav_games: Button = %NavGames
@onready var nav_lounge: Button = %NavLounge
@onready var nav_study: Button = %NavStudy


var _portrait: Control


func _ready() -> void:
	_portrait = HunterPortrait.new()
	_portrait.hero = true
	_portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	avatar_panel.add_child(_portrait)
	avatar_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	avatar_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	# Hero card: the level/XP block and stat tiles move into the column beside the hero.
	var column: Control = $VBox/HeroRow/GreetingVBox
	for node_name in ["XPPanel", "StatRow"]:
		var n: Node = get_node("VBox/" + node_name)
		n.reparent(column, false)
	_add_stat_icon(stat_points, "star", UiTheme.GOLD)
	_add_stat_icon(stat_outfits, "outfit", UiTheme.ACCENT)
	_add_stat_icon(stat_friend, "friendship", UiTheme.ACCENT)
	_style_nav(nav_club, "closet", UiTheme.VIOLET, "Clubhouse", "Change outfits, hang out with the boys.")
	_style_nav(nav_battle, "zap", UiTheme.GOLD, "Battle Arena", "Zap Gloomlings before they reach the stage.")
	_style_nav(nav_games, "music", UiTheme.TEAL, "Mini-Games", "Rhythm, Memory, Star Catch, Lantern Says.")
	_style_nav(nav_lounge, "lounge", UiTheme.ACCENT, "Lounge", "Say hi to Hae, Bit and Nun.")
	_style_nav(nav_study, "reading", UiTheme.GOLD, "Study Hall", "Math, grammar and reading for Star Points.", false)
	nav_club.pressed.connect(func(): screen_requested.emit("club"))
	nav_battle.pressed.connect(func(): screen_requested.emit("battle"))
	nav_games.pressed.connect(func(): screen_requested.emit("games"))
	nav_lounge.pressed.connect(func(): screen_requested.emit("club_lounge"))
	nav_study.pressed.connect(func(): screen_requested.emit("study"))
	_add_help_row()
	game_state.points_changed.connect(func(_v): refresh())
	refresh()


## Adds the "How to play" (replays the tutorial) and "Stickers" buttons under the nav cards.
func _add_help_row() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	$VBox.add_child(row)
	for spec in [["How to play", "tutorial"], ["Stickers", "stickers"]]:
		var b := Button.new()
		b.text = spec[0]
		b.theme_type_variation = "SecondaryButton"
		b.custom_minimum_size.y = 56
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(func(): Snd.play("tap"); screen_requested.emit(spec[1]))
		row.add_child(b)


## Gives a nav button the shared card look (icon tile + title + description).
func _style_nav(btn: Button, icon_name: String, tint: Color, title: String, desc: String,
		compact: bool = true) -> void:
	btn.custom_minimum_size.y = 96 if compact else 88
	UiCards.fill_card(btn, icon_name, tint, title, desc, "", compact)


## Puts a UiIcon above a stat tile's value label.
func _add_stat_icon(value_label: Label, icon_name: String, tint: Color) -> void:
	var icon := UiIcon.new().setup(icon_name, tint, 32)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var box := value_label.get_parent()
	box.add_child(icon)
	box.move_child(icon, 0)


func refresh() -> void:
	var day_index: int = int(Time.get_date_dict_from_system().get("day", 1)) % FORECASTS.size()
	forecast_label.text = FORECASTS[day_index]

	var level: int = game_state.level_for_xp(game_state.total_earned)
	var into_level: int = game_state.total_earned % game_state.XP_PER_LEVEL
	level_label.text = "Trainee Level %d" % level
	xp_amount_label.text = "%d/%d XP" % [into_level, game_state.XP_PER_LEVEL]
	xp_bar.value = into_level

	stat_points.text = str(game_state.star_points)
	stat_outfits.text = "%d/%d" % [game_state.unlocked_outfits.size(), game_state.all_outfits().size()]
	var total_affection := 0
	for v in game_state.affection.values():
		total_affection += v
	var pct := int(round(float(total_affection) / (3.0 * 100.0) * 100.0))
	stat_friend.text = "%d%%" % pct

	_portrait.refresh()
