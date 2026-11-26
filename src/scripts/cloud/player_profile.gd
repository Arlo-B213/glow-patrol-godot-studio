class_name PlayerProfile
extends RefCounted
## What a friend can see of a player: a display name, the hunter's look, the pet, and the friend
## code. Colours are saved as hex text, since Firestore stores plain values.

const NAME_LIMIT := 12
## Keys of the hunter look that hold a Color (see GameState.base_look).
const COLOR_KEYS := ["outfit", "hair", "glow"]


## The profile document for a player. The name is trimmed and cut to NAME_LIMIT characters.
static func build(display_name: String, look: Dictionary, pet_id: String, friend_code: String) -> Dictionary:
	var name_text := display_name.strip_edges().substr(0, NAME_LIMIT)
	return {
		"name": name_text,
		"friend_code": friend_code,
		"pet": pet_id,
		"look": look_to_plain(look),
	}


## Hunter look -> plain values, with each colour written as "#rrggbb".
static func look_to_plain(look: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for key in look:
		var value: Variant = look[key]
		if value is Color:
			out[key] = "#" + (value as Color).to_html(false)
		else:
			out[key] = value
	return out


## Plain values -> hunter look, turning the colour keys back into Color.
static func look_from_plain(plain: Dictionary) -> Dictionary:
	var out: Dictionary = plain.duplicate()
	for key in COLOR_KEYS:
		if out.has(key) and out[key] is String:
			out[key] = Color(out[key])
	return out
