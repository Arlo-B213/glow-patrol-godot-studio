extends GdUnitTestSuite
## Friend codes: generation, checking and tidying what a player types in.

const FriendCode := preload("res://scripts/cloud/friend_code.gd")


func test_generate_returns_six_characters_from_the_code_alphabet() -> void:
	# Arrange
	var rng := RandomNumberGenerator.new()
	rng.seed = 7

	# Act
	var code: String = FriendCode.generate(rng)

	# Assert
	assert_int(code.length()).is_equal(FriendCode.LENGTH)
	assert_bool(FriendCode.is_valid(code)).is_true()


func test_generate_with_same_seed_returns_same_code() -> void:
	# Arrange
	var a := RandomNumberGenerator.new()
	a.seed = 42
	var b := RandomNumberGenerator.new()
	b.seed = 42

	# Act / Assert
	assert_str(FriendCode.generate(a)).is_equal(FriendCode.generate(b))


func test_alphabet_leaves_out_look_alike_characters() -> void:
	# Arrange / Act
	var alphabet: String = FriendCode.ALPHABET

	# Assert: 0, O, 1, I and L are easy to confuse when read aloud
	for ch in ["0", "O", "1", "I", "L"]:
		assert_bool(alphabet.contains(ch)).is_false()


func test_is_valid_rejects_wrong_length() -> void:
	# Arrange / Act / Assert
	assert_bool(FriendCode.is_valid("ABCDE")).is_false()
	assert_bool(FriendCode.is_valid("ABCDEFG")).is_false()


func test_is_valid_rejects_characters_outside_the_alphabet() -> void:
	# Arrange / Act / Assert
	assert_bool(FriendCode.is_valid("ABC0EF")).is_false()


func test_normalize_trims_spaces_and_uppercases() -> void:
	# Arrange
	var typed := "  ab cd-ef "

	# Act
	var code: String = FriendCode.normalize(typed)

	# Assert
	assert_str(code).is_equal("ABCDEF")
