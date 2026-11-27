extends GdUnitTestSuite
## Firebase client request building: the sign-up body and the document URLs. No network in these tests.

const FirebaseClient := preload("res://scripts/cloud/firebase_client.gd")


func test_sign_up_body_asks_for_a_secure_token() -> void:
	# Arrange / Act
	var body: Dictionary = FirebaseClient.sign_up_body()

	# Assert
	assert_bool(body["returnSecureToken"]).is_true()


func test_document_url_appends_collection_and_id_to_documents_root() -> void:
	# Arrange
	var path := "players/abc123"

	# Act
	var url: String = FirebaseClient.document_url(path)

	# Assert
	assert_str(url).ends_with("/documents/players/abc123")


func test_create_url_puts_document_id_in_query_on_collection() -> void:
	# Arrange / Act
	var url: String = FirebaseClient.create_url("friendCodes", "ABCDEF")

	# Assert
	assert_str(url).ends_with("/documents/friendCodes?documentId=ABCDEF")


func test_create_url_rejects_empty_id_by_returning_empty_string() -> void:
	# Arrange / Act
	var url: String = FirebaseClient.create_url("friendCodes", "")

	# Assert
	assert_str(url).is_empty()


func test_document_url_rejects_empty_path_by_returning_empty_string() -> void:
	# Arrange / Act
	var url: String = FirebaseClient.document_url("")

	# Assert
	assert_str(url).is_empty()
