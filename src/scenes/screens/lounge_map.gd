class_name LoungeMap
extends VBoxContainer

## Lounge map: one place per Lanternboy (LoungeMissions.PLACES). Each place shows the boy, friendship,
## the missions there (locked until friendship is high enough), and a Talk button for the dialogue.
## Emits `mission_requested` with the chosen mission, or `talk_requested` with the boy id.

const EnvBackdrop := preload("res://scenes/ui/env_backdrop.gd")

signal mission_requested(mission: Dictionary)
signal talk_requested(boy_id: String)

var _game_state: Node

## Builds the map for `game_state`. Returns self for chaining.
func setup(game_state: Node) -> LoungeMap:
	_game_state = game_state
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 12)
	for boy in game_state.LANTERNBOYS:
		add_child(_place_card(boy))
	return self

func _place_card(boy: Dictionary) -> PanelContainer:
	var boy_id: String = boy["id"]
	var affection: int = int(_game_state.affection.get(boy_id, 0))
	var card := PanelContainer.new()
	card.theme_type_variation = "CardPanel"
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	card.add_child(box)
	box.add_child(_banner(boy_id))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	box.add_child(top)
	top.add_child(ClubCards.portrait_tile(boy_id, Color(boy["color"]), Vector2(72, 72), 16))
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(text)
	text.add_child(_label(String(LoungeMissions.PLACES.get(boy_id, "")), "Heading"))
	text.add_child(_label("%s - %s" % [boy["name"], boy["role"]], "Muted"))
	text.add_child(ClubCards.friend_meter(affection))
	for mission in LoungeMissions.for_boy(boy_id):
		box.add_child(_mission_button(mission, affection))
	var talk := Button.new()
	talk.text = "Talk to %s" % boy["name"]
	talk.theme_type_variation = "SecondaryButton"
	talk.focus_mode = Control.FOCUS_NONE
	talk.custom_minimum_size = Vector2(0, 52)
	talk.pressed.connect(func(): talk_requested.emit(boy_id))
	box.add_child(talk)
	return card

func _mission_button(mission: Dictionary, affection: int) -> Button:
	var open: bool = LoungeMissions.is_open(mission, affection)
	var best: int = int(_game_state.mission_best.get(mission["id"], 0))
	var subjects: String = ", ".join(PackedStringArray(mission["subjects"]))
	var btn := Button.new()
	btn.theme_type_variation = "SecondaryButton"
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(0, 56)
	btn.disabled = not open
	if open:
		btn.text = "%s - Grade %d (%s)%s" % [mission["title"], mission["grade"], subjects,
			"  Best %d" % best if best > 0 else ""]
		btn.pressed.connect(func(): mission_requested.emit(mission))
	else:
		btn.text = "%s - locked until friendship %d" % [mission["title"], int(mission["needs_affection"])]
	return btn

## Backdrop strip for a place, in the theme of the place (bridge, dance floor, garden).
func _banner(boy_id: String) -> Control:
	var banner: Control = EnvBackdrop.new()
	banner.set_theme_name(String(LoungeMissions.PLACE_THEMES.get(boy_id, "club")))
	banner.custom_minimum_size = Vector2(0, 80)
	return banner

func _label(text: String, variation: String) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l
