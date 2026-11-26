extends GdUnitTestSuite
## Player profile: what a friend can see of a player, and the look round trip through plain text.

const PlayerProfile := preload("res://scripts/cloud/player_profile.gd")


func _sample_look() -> Dictionary:
	return {
		"outfit": Color("#6C5CE7"),
		"outfit_style": "breaker",
		"hair": Color("#2A1F55"),
		"glow": Color("#FF5FA2"),
		"weapon": "stick",
		"hairstyle": "bob",
		"headwear": "lightning-streak",
		"face_acc": "none",
	}


func test_look_to_plain_writes_colours_as_hex_text() -> void:
	# Arrange
	var look := _sample_look()

	# Act
	var plain: Dictionary = PlayerProfile.look_to_plain(look)

	# Assert
	assert_str(plain["outfit"]).is_equal("#6c5ce7")
	assert_str(plain["glow"]).is_equal("#ff5fa2")
	assert_str(plain["outfit_style"]).is_equal("breaker")


func test_look_round_trip_restores_the_same_colours_and_text() -> void:
	# Arrange
	var look := _sample_look()

	# Act
	var back: Dictionary = PlayerProfile.look_from_plain(PlayerProfile.look_to_plain(look))

	# Assert
	assert_bool(back["outfit"] is Color).is_true()
	assert_bool((back["outfit"] as Color).is_equal_approx(Color("#6C5CE7"))).is_true()
	assert_str(back["hairstyle"]).is_equal("bob")


func test_build_profile_contains_name_friend_code_pet_and_look() -> void:
	# Arrange / Act
	var profile: Dictionary = PlayerProfile.build("Mia", _sample_look(), "moonbun", "ABCDEF")

	# Assert
	assert_str(profile["name"]).is_equal("Mia")
	assert_str(profile["friend_code"]).is_equal("ABCDEF")
	assert_str(profile["pet"]).is_equal("moonbun")
	assert_dict(profile["look"]).is_not_empty()


func test_build_profile_trims_and_limits_the_name_to_twelve_characters() -> void:
	# Arrange
	var long_name := "   Abcdefghijklmnop   "

	# Act
	var profile: Dictionary = PlayerProfile.build(long_name, _sample_look(), "", "ABCDEF")

	# Assert
	assert_str(profile["name"]).is_equal("Abcdefghijkl")
