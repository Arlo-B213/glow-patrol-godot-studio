extends HFlowContainer
## Small accessory picker for the Pets Den (Story 033): one button per entry of
## GameState.PET_ACCESSORIES plus "None". Tapping an unlocked one wears it, tapping a
## locked one buys it (stars) and wears it. Rules live in GameState (equip/buy_accessory).

## Emitted after the worn accessory or star balance changed.
signal changed

var _pet_id := ""


func _init() -> void:
	add_theme_constant_override("h_separation", 8)
	add_theme_constant_override("v_separation", 8)


## Shows the choices for pet `pet_id` and returns self.
func setup(pet_id: String) -> HFlowContainer:
	_pet_id = pet_id
	if is_inside_tree():
		_rebuild()
	return self


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	var gs: Node = get_node("/root/GameState")
	var worn: String = gs.pet_accessory(_pet_id)
	add_child(_make("None", "", worn == ""))
	for d in gs.PET_ACCESSORIES:
		var id: String = d["id"]
		var open: bool = gs.accessory_unlocked(_pet_id, id)
		var label: String = d["name"] if open else "%s  %d" % [d["name"], int(d["cost"])]
		add_child(_make(label, id, worn == id, open))


func _make(label: String, id: String, on: bool, open: bool = true) -> Button:
	var b := Button.new()
	b.text = label
	b.toggle_mode = true
	b.button_pressed = on
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(0, 52)
	b.modulate = Color.WHITE if open else Color(1, 1, 1, 0.75)
	b.pressed.connect(_pick.bind(id))
	return b


func _pick(id: String) -> void:
	var gs: Node = get_node("/root/GameState")
	if id != "" and not gs.accessory_unlocked(_pet_id, id):
		if not gs.buy_accessory(_pet_id, id):
			get_node("/root/Toast").show_message("Need %d Star Points" % int(gs.accessory_def(id)["cost"]))
			_rebuild()
			return
	gs.equip_accessory(_pet_id, id)
	_rebuild()
	changed.emit()
