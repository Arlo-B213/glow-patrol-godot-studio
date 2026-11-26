class_name FirestoreCodec
extends RefCounted
## Converts plain Godot dictionaries to and from Firestore's typed REST JSON.
## Supports String, bool, int, float, Array and Dictionary values. Integers travel as strings,
## as Firestore's REST API sends 64-bit integers that way.


## Plain dictionary -> a Firestore document body: {"fields": {name: typed value, ...}}.
static func encode(data: Dictionary) -> Dictionary:
	var fields: Dictionary = {}
	for key in data:
		fields[String(key)] = _encode_value(data[key])
	return {"fields": fields}


## Firestore document body -> plain dictionary. A body without "fields" gives an empty dictionary.
static func decode(doc: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	var fields: Dictionary = doc.get("fields", {})
	for key in fields:
		out[key] = _decode_value(fields[key])
	return out


static func _encode_value(value: Variant) -> Dictionary:
	match typeof(value):
		TYPE_BOOL:
			return {"booleanValue": value}
		TYPE_INT:
			return {"integerValue": str(value)}
		TYPE_FLOAT:
			return {"doubleValue": value}
		TYPE_ARRAY:
			var items: Array = []
			for item in value:
				items.append(_encode_value(item))
			return {"arrayValue": {"values": items}}
		TYPE_DICTIONARY:
			return {"mapValue": encode(value)}
		_:
			return {"stringValue": str(value)}


static func _decode_value(node: Dictionary) -> Variant:
	if node.has("stringValue"):
		return String(node["stringValue"])
	if node.has("booleanValue"):
		return bool(node["booleanValue"])
	if node.has("integerValue"):
		return int(String(node["integerValue"]))
	if node.has("doubleValue"):
		return float(node["doubleValue"])
	if node.has("arrayValue"):
		var out: Array = []
		for item in node["arrayValue"].get("values", []):
			out.append(_decode_value(item))
		return out
	if node.has("mapValue"):
		return decode(node["mapValue"])
	return null
