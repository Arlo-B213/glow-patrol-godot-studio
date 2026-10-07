extends Control
## Clubhouse screen: Closet / Style / Weapons / Lounge sub-tabs.
## Mirrors the web version's renderClubhouse()/renderCloset().
## Card visuals live in res://scripts/club_cards.gd (ClubCards).

const HunterPortrait := preload("res://scenes/ui/hunter_portrait.gd")
## Height of the live preview at the top of the Closet and Style tabs.
const PREVIEW_HEIGHT := 340.0
const PREVIEW_WIDTH := 260.0

@onready var game_state: Node = get_node("/root/GameState")
@onready var toast: Node = get_node("/root/Toast")

@onready var sub_content: VBoxContainer = %SubContent
@onready var sub_tabs: Dictionary = {
	"closet": %SubTabCloset,
	"style": %SubTabStyle,
	"weapons": %SubTabWeapons,
	"lounge": %SubTabLounge,
}

var current_sub := "closet"
var _lounge_line_index: Dictionary = {"hae": 0, "bit": 0, "nun": 0}


func _ready() -> void:
	for key in sub_tabs.keys():
		var btn: Button = sub_tabs[key]
		btn.pressed.connect(_on_sub_tab_pressed.bind(key))
	render_sub("closet")


func _on_sub_tab_pressed(key: String) -> void:
	render_sub(key)


func render_sub(key: String) -> void:
	current_sub = key
	for name_key in sub_tabs.keys():
		var btn: Button = sub_tabs[name_key]
		btn.button_pressed = (name_key == key)

	for child in sub_content.get_children():
		child.queue_free()

	match key:
		"closet":
			render_closet()
		"style":
			render_style()
		"weapons":
			render_weapons()
		"lounge":
			render_lounge()


func render_placeholder(text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.theme_type_variation = "Muted"
	sub_content.add_child(lbl)


## Adds a live hunter preview at the top of the current tab. The tabs re-render after
## every equip, so a fresh portrait always shows the new look.
func _add_preview() -> void:
	var portrait: Control = HunterPortrait.new()
	portrait.hero = true
	portrait.custom_minimum_size = Vector2(PREVIEW_WIDTH, PREVIEW_HEIGHT)
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	sub_content.add_child(portrait)


func _new_grid() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	sub_content.add_child(grid)
	return grid


func _item_state(unlocked: bool, equipped: bool) -> String:
	if not unlocked:
		return ClubCards.STATE_LOCKED
	return ClubCards.STATE_EQUIPPED if equipped else ClubCards.STATE_NORMAL


func render_closet() -> void:
	_add_preview()
	var grid := _new_grid()
	for outfit in game_state.all_outfits():
		var outfit_id: String = outfit["id"]
		var unlocked: bool = game_state.unlocked_outfits.has(outfit_id)
		var equipped: bool = game_state.equipped_outfit == outfit_id

		var card_look: Dictionary = game_state.hunter_look()
		card_look["outfit"] = outfit["outfit"]
		card_look["outfit_style"] = String(outfit.get("style", "track"))
		var mini: Control = HunterPortrait.new()
		mini.idle_bob = false
		mini.custom_minimum_size = Vector2(48, 60)
		mini.set_look(card_look)
		if not unlocked:
			mini.modulate = Color(1, 1, 1, 0.75)

		grid.add_child(ClubCards.item_card(mini, outfit["name"], _item_state(unlocked, equipped),
			int(outfit["cost"]), "Tap to wear", 130, _on_outfit_pressed.bind(outfit_id)))


func _on_outfit_pressed(outfit_id: String) -> void:
	var outfit: Dictionary = game_state.outfit_by_id(outfit_id)
	var unlocked: bool = game_state.unlocked_outfits.has(outfit_id)
	if unlocked:
		game_state.equipped_outfit = outfit_id
		game_state.save_game()
		render_sub("closet")
	elif game_state.spend_points(int(outfit["cost"])):
		game_state.unlocked_outfits.append(outfit_id)
		game_state.equipped_outfit = outfit_id
		game_state.save_game()
		Snd.play("chapter")
		toast.show_message("Unlocked %s!" % outfit["name"])
		render_sub("closet")
	else:
		var need: int = int(outfit["cost"]) - game_state.star_points
		Snd.play("error")
		toast.show_message("Need %d more Star Points" % need)


func render_weapons() -> void:
	var grid := _new_grid()
	for weapon in game_state.WEAPONS:
		var weapon_id: String = weapon["id"]
		var unlocked: bool = game_state.unlocked_weapons.has(weapon_id)
		var equipped: bool = game_state.equipped_weapon == weapon_id
		grid.add_child(ClubCards.item_card(WeaponThumb.new().setup(String(weapon.get("style", "stick")), weapon["glow"]), "%s
%s" % [weapon["name"], weapon["blurb"]],
			_item_state(unlocked, equipped), int(weapon["cost"]), "Tap to wield", 130,
			_on_weapon_pressed.bind(weapon_id)))


func _on_weapon_pressed(weapon_id: String) -> void:
	var weapon: Dictionary = game_state.weapon_by_id(weapon_id)
	var unlocked: bool = game_state.unlocked_weapons.has(weapon_id)
	if unlocked:
		game_state.equipped_weapon = weapon_id
		game_state.save_game()
		render_sub("weapons")
	elif game_state.spend_points(int(weapon["cost"])):
		game_state.unlocked_weapons.append(weapon_id)
		game_state.equipped_weapon = weapon_id
		game_state.save_game()
		Snd.play("chapter")
		toast.show_message("Unlocked %s!" % weapon["name"])
		render_sub("weapons")
	else:
		var need: int = int(weapon["cost"]) - game_state.star_points
		Snd.play("error")
		toast.show_message("Need %d more Star Points" % need)


func render_lounge() -> void:
	for boy in game_state.LANTERNBOYS:
		var boy_id: String = boy["id"]
		var affection: int = int(game_state.affection.get(boy_id, 0))
		sub_content.add_child(ClubCards.lounge_row(boy, affection, _on_boy_pressed.bind(boy_id)))


func _on_boy_pressed(boy_id: String) -> void:
	open_dialogue(boy_id)


func open_dialogue(boy_id: String) -> void:
	for child in sub_content.get_children():
		child.queue_free()

	var boy: Dictionary = game_state.lanternboy_by_id(boy_id)
	var lines: Array = boy["lines"]
	var idx: int = int(_lounge_line_index.get(boy_id, 0)) % lines.size()
	var refs: Dictionary = {}
	# Lambdas capture `refs` by reference (Dictionary), so merge fills it after the build.
	refs.merge(ClubCards.dialogue_view(sub_content, boy, str(lines[idx]),
		int(game_state.affection.get(boy_id, 0)),
		func(): render_sub("lounge"),
		func():
			refs["portrait"].bounce()
			_on_high_five_pressed(boy_id, refs["line"], refs["meter"]),
		_scene_button_text(boy_id), _on_scene_button.bind(boy_id)))


## Label of the Lounge 'Story scene' button: "" when the boy has no unlocked scene yet.
func _scene_button_text(boy_id: String) -> String:
	if not ArcScenes.new_scene(game_state, boy_id).is_empty():
		return "Story scene (new!)"
	return "Story scenes" if not ArcScenes.unlocked_for(game_state, boy_id).is_empty() else ""


## A new scene opens straight away; otherwise the replay list opens.
func _on_scene_button(boy_id: String) -> void:
	var fresh: Dictionary = ArcScenes.new_scene(game_state, boy_id)
	if fresh.is_empty():
		open_scene_list(boy_id)
	else:
		open_scene(boy_id, str(fresh["id"]))


## Replay list: one 56 px button per scene; locked ones show the friendship needed.
func open_scene_list(boy_id: String) -> void:
	for child in sub_content.get_children():
		child.queue_free()
	var head := Label.new()
	head.text = "%s - Story scenes" % game_state.lanternboy_by_id(boy_id)["name"]
	head.theme_type_variation = "Heading"
	sub_content.add_child(head)
	for s in ArcScenes.scenes_for(boy_id):
		var btn := Button.new()
		btn.theme_type_variation = "SecondaryButton"
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size.y = 56
		if ArcScenes.is_unlocked(game_state, s):
			btn.text = String(s["title"])
			btn.pressed.connect(open_scene.bind(boy_id, str(s["id"])))
		else:
			btn.text = "Locked - friendship %d%%" % int(s["affection"])
			btn.disabled = true
		sub_content.add_child(btn)
	var back := Button.new()
	back.text = "Back"
	back.theme_type_variation = "SecondaryButton"
	back.focus_mode = Control.FOCUS_NONE
	back.custom_minimum_size.y = 48
	back.pressed.connect(open_dialogue.bind(boy_id))
	sub_content.add_child(back)


## Plays a scene; the first view pays ArcScenes.FIRST_VIEW_STARS once and plays the chapter sound.
func open_scene(boy_id: String, scene_id: String) -> void:
	var scene: Dictionary = ArcScenes.by_id(scene_id)
	if scene.is_empty() or not ArcScenes.is_unlocked(game_state, scene):
		open_dialogue(boy_id)
		return
	for child in sub_content.get_children():
		child.queue_free()
	if ArcScenes.mark_seen(game_state, scene):
		Snd.play("chapter")
		toast.show_message("Story scene: +%d Star Points" % ArcScenes.FIRST_VIEW_STARS)
	sub_content.add_child(ArcSceneView.create(game_state.lanternboy_by_id(boy_id), scene, open_dialogue.bind(boy_id)))


func _style_unlocked_list(category: String) -> Array:
	match category:
		"hairstyle":
			return game_state.unlocked_hairstyles
		"haircolor":
			return game_state.unlocked_hair_colors
		"headwear":
			return game_state.unlocked_headwear
		"faceacc":
			return game_state.unlocked_face_acc
	return []


func _style_equipped_id(category: String) -> String:
	match category:
		"hairstyle":
			return game_state.hairstyle
		"haircolor":
			return game_state.hair_color
		"headwear":
			return game_state.headwear
		"faceacc":
			return game_state.face_acc
	return ""


func _style_list(category: String) -> Array:
	match category:
		"hairstyle":
			return game_state.HAIRSTYLES
		"haircolor":
			return game_state.HAIR_COLORS
		"headwear":
			return game_state.HEADWEAR
		"faceacc":
			return game_state.FACE_ACC
	return []


func _set_style_equipped(category: String, item_id: String) -> void:
	match category:
		"hairstyle":
			game_state.hairstyle = item_id
		"haircolor":
			game_state.hair_color = item_id
		"headwear":
			game_state.headwear = item_id
		"faceacc":
			game_state.face_acc = item_id


func render_style() -> void:
	_add_preview()
	_build_style_section("Hairstyle", "hairstyle", UiTheme.ACCENT)
	_build_style_section("Hair Color", "haircolor", UiTheme.GOLD)
	_build_style_section("Headwear", "headwear", UiTheme.TEAL)
	_build_style_section("Face Accessory", "faceacc", UiTheme.VIOLET)


func _build_style_section(title: String, category: String, accent: Color) -> void:
	sub_content.add_child(ClubCards.section_header(title, accent))
	var grid := _new_grid()
	var unlocked_list: Array = _style_unlocked_list(category)
	var equipped_id: String = _style_equipped_id(category)

	for item in _style_list(category):
		var item_id: String = item["id"]
		var unlocked: bool = unlocked_list.has(item_id)
		var equipped: bool = equipped_id == item_id
		var chip: Control = null
		if item.has("hex"):
			chip = ClubCards.color_chip(Color(item["hex"]), 34)
		grid.add_child(ClubCards.item_card(chip, item["name"], _item_state(unlocked, equipped),
			int(item["cost"]), "Tap to wear", 96, _on_style_item_pressed.bind(category, item_id)))


func _on_style_item_pressed(category: String, item_id: String) -> void:
	var list: Array = _style_list(category)
	var item: Dictionary = game_state.style_item_by_id(list, item_id)
	var unlocked_list: Array = _style_unlocked_list(category)

	if unlocked_list.has(item_id):
		_set_style_equipped(category, item_id)
		game_state.save_game()
		render_sub("style")
	elif game_state.spend_points(int(item["cost"])):
		unlocked_list.append(item_id)
		_set_style_equipped(category, item_id)
		game_state.save_game()
		Snd.play("chapter")
		toast.show_message("Unlocked %s!" % item["name"])
		render_sub("style")
	else:
		var need: int = int(item["cost"]) - game_state.star_points
		Snd.play("error")
		toast.show_message("Need %d more Star Points" % need)


func _on_high_five_pressed(boy_id: String, line_lbl: Label, meter: HBoxContainer) -> void:
	var boy: Dictionary = game_state.lanternboy_by_id(boy_id)
	var lines: Array = boy["lines"]
	_lounge_line_index[boy_id] = (int(_lounge_line_index.get(boy_id, 0)) + 1) % lines.size()
	line_lbl.text = "\"%s\"" % lines[_lounge_line_index[boy_id]]
	var current: int = int(game_state.affection.get(boy_id, 0))
	if current < 100:
		game_state.affection[boy_id] = min(100, current + 4 + (randi() % 5))
		game_state.earn_points(2)
		Snd.play("high_five")
		ClubCards.set_meter(meter, int(game_state.affection[boy_id]))
		toast.show_message("+2 Star Points")
