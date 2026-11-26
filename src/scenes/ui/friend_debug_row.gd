class_name FriendDebugRow
extends RefCounted
## Debug-only Settings panel for friend codes: makes this player's code and profile, and looks up a
## code that is typed in. Each step waits for the one before it, since the client runs one request at a time.

const MAX_TRIES := 5

var _gs: Node
var _client: FirebaseClient
var _mine: Label
var _status: Label
var _entry: LineEdit
var _code: String = ""
var _tries: int = 0
var _rng := RandomNumberGenerator.new()


## Builds the panel under `host` (the Settings page) and returns it for the list to show.
func build(gs: Node, host: Node) -> Control:
	_gs = gs
	_rng.randomize()
	var panel := PanelContainer.new()
	panel.theme_type_variation = "CardPanel"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	var title := Label.new()
	title.text = "Friend code"
	title.theme_type_variation = "Heading"
	box.add_child(title)
	var hint := Label.new()
	hint.text = "Make your code, then look up a friend's. Debug builds only."
	hint.theme_type_variation = "Caption"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hint)
	_mine = Label.new()
	_mine.text = "No code yet"
	_mine.theme_type_variation = "Caption"
	box.add_child(_mine)
	_status = Label.new()
	_status.theme_type_variation = "Caption"
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_status)
	_entry = LineEdit.new()
	_entry.placeholder_text = "Friend code"
	_entry.custom_minimum_size = Vector2(0, 56)
	box.add_child(_entry)
	var make := _button("Make my code")
	make.pressed.connect(_on_make_pressed)
	box.add_child(make)
	var find := _button("Find friend")
	find.pressed.connect(_on_find_pressed)
	box.add_child(find)
	_client = FirebaseClient.new()
	host.add_child(_client)
	_client.signed_in.connect(_on_signed_in)
	_client.document_exists.connect(_on_document_exists)
	_client.document_saved.connect(_on_document_saved)
	_client.document_loaded.connect(_on_document_loaded)
	_client.request_failed.connect(_on_request_failed)
	return panel


func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.theme_type_variation = "SecondaryButton"
	b.custom_minimum_size = Vector2(0, 56)
	return b


func _on_make_pressed() -> void:
	_tries = 0
	_status.text = "Signing in..."
	_client.sign_in_anonymously()


func _on_signed_in(uid: String) -> void:
	_claim(uid)


## Tries to claim a random code for `uid`. A taken code (409) is retried with a new one.
func _claim(uid: String) -> void:
	_code = FriendCode.generate(_rng)
	_tries += 1
	_client.create_document("friendCodes", _code, {"uid": uid})


func _on_document_exists(_path: String) -> void:
	if _tries < MAX_TRIES:
		_claim(_client.user_id)
	else:
		_status.text = "Could not find a free code, try again."


func _on_document_saved(path: String) -> void:
	if path.begins_with("friendCodes/"):
		var profile := PlayerProfile.build("Player", _gs.base_look(), String(_gs.active_pet), _code)
		_client.set_document("players/" + _client.user_id, profile)
	else:
		_mine.text = "Your code: " + _code
		_status.text = "Profile saved."


func _on_find_pressed() -> void:
	var typed := FriendCode.normalize(_entry.text)
	if not FriendCode.is_valid(typed):
		_status.text = "Codes are 6 letters or numbers."
		return
	_status.text = "Looking up " + typed + "..."
	_client.get_document("friendCodes/" + typed)


func _on_document_loaded(path: String, data: Dictionary) -> void:
	if path.begins_with("friendCodes/"):
		if data.is_empty():
			_status.text = "No friend has that code."
		else:
			_client.get_document("players/" + String(data.get("uid", "")))
	elif data.is_empty():
		_status.text = "That friend has no profile yet."
	else:
		_status.text = "Friend: %s, pet: %s" % [data.get("name", "?"), data.get("pet", "none")]


func _on_request_failed(message: String) -> void:
	_status.text = "Failed: " + message
