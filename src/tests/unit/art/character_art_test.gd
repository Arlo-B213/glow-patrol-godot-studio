extends GdUnitTestSuite
## Approved character art lookup: approved ids resolve to a texture, unknown ids fall back to null.

const CharacterArt := preload("res://scripts/character_art.gd")


func before_test() -> void:
	CharacterArt.clear_cache()


func test_approved_hae_neutral_resolves_to_texture() -> void:
	# Arrange
	var id := "hae"
	# Act
	var tex: Texture2D = CharacterArt.texture(id, "neutral")
	# Assert
	assert_object(tex).is_not_null()


func test_unknown_character_falls_back_to_null() -> void:
	# Arrange
	var id := "not_a_real_character"
	# Act
	var tex: Texture2D = CharacterArt.texture(id, "neutral")
	# Assert
	assert_object(tex).is_null()


func test_missing_expression_falls_back_to_null() -> void:
	# Arrange
	var id := "hae"
	var expression := "not_an_expression"
	# Act
	var tex: Texture2D = CharacterArt.texture(id, expression)
	# Assert
	assert_object(tex).is_null()


func test_path_for_builds_the_asset_path() -> void:
	# Arrange / Act
	var path := CharacterArt.path_for("pearl", "happy")
	# Assert
	assert_str(path).is_equal("res://assets/art/characters/pearl/happy.png")
