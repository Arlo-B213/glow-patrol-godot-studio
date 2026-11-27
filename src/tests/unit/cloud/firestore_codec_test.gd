extends GdUnitTestSuite
## Firestore value encoding: plain Godot values to and from the typed JSON Firestore's REST API uses.

const FirestoreCodec := preload("res://scripts/cloud/firestore_codec.gd")


func test_encode_string_field_writes_string_value() -> void:
	# Arrange
	var data := {"name": "Hae"}

	# Act
	var doc: Dictionary = FirestoreCodec.encode(data)

	# Assert
	assert_bool(doc.has("fields")).is_true()
	assert_str(doc["fields"]["name"]["stringValue"]).is_equal("Hae")


func test_encode_int_field_writes_integer_value_as_string() -> void:
	# Arrange: Firestore sends 64-bit integers as strings in JSON
	var data := {"stars": 478}

	# Act
	var doc: Dictionary = FirestoreCodec.encode(data)

	# Assert
	assert_str(doc["fields"]["stars"]["integerValue"]).is_equal("478")


func test_encode_bool_and_double_fields_write_their_types() -> void:
	# Arrange
	var data := {"on": true, "ratio": 0.75}

	# Act
	var doc: Dictionary = FirestoreCodec.encode(data)

	# Assert
	assert_bool(doc["fields"]["on"]["booleanValue"]).is_true()
	assert_float(doc["fields"]["ratio"]["doubleValue"]).is_equal(0.75)


func test_encode_nested_map_and_array_write_map_and_array_values() -> void:
	# Arrange
	var data := {"look": {"outfit": "breaker"}, "pets": ["sparkfox", "moonbun"]}

	# Act
	var doc: Dictionary = FirestoreCodec.encode(data)

	# Assert
	assert_str(doc["fields"]["look"]["mapValue"]["fields"]["outfit"]["stringValue"]).is_equal("breaker")
	var pets: Array = doc["fields"]["pets"]["arrayValue"]["values"]
	assert_int(pets.size()).is_equal(2)
	assert_str(pets[1]["stringValue"]).is_equal("moonbun")


func test_decode_round_trip_returns_the_original_values() -> void:
	# Arrange
	var data := {"name": "Juno", "stars": 468, "on": false, "ratio": 0.5, "pets": ["xolo"]}

	# Act
	var back: Dictionary = FirestoreCodec.decode(FirestoreCodec.encode(data))

	# Assert
	assert_str(back["name"]).is_equal("Juno")
	assert_int(back["stars"]).is_equal(468)
	assert_bool(back["on"]).is_false()
	assert_float(back["ratio"]).is_equal(0.5)
	assert_str(back["pets"][0]).is_equal("xolo")


func test_decode_document_without_fields_returns_empty_dictionary() -> void:
	# Arrange
	var doc := {"name": "projects/x/databases/(default)/documents/players/a"}

	# Act
	var back: Dictionary = FirestoreCodec.decode(doc)

	# Assert
	assert_dict(back).is_empty()
