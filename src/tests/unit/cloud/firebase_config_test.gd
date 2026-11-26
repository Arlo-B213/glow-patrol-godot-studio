extends GdUnitTestSuite
## Firebase config: the endpoints the game calls, and whether cloud features are switched on.

const FirebaseConfig := preload("res://scripts/cloud/firebase_config.gd")


func test_documents_url_contains_project_id_and_firestore_path() -> void:
	# Arrange / Act
	var url: String = FirebaseConfig.documents_url()

	# Assert
	assert_str(url).contains(FirebaseConfig.PROJECT_ID)
	assert_str(url).starts_with("https://firestore.googleapis.com/v1/projects/")
	assert_str(url).ends_with("/databases/(default)/documents")


func test_sign_up_url_uses_identity_toolkit_endpoint() -> void:
	# Arrange / Act
	var url: String = FirebaseConfig.sign_up_url()

	# Assert
	assert_str(url).starts_with("https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=")


func test_is_configured_is_false_while_api_key_is_empty() -> void:
	# Arrange: the key is pasted in by hand, so an empty key means cloud features stay off
	var key_now: String = FirebaseConfig.WEB_API_KEY

	# Act
	var configured: bool = FirebaseConfig.is_configured()

	# Assert
	if key_now == "":
		assert_bool(configured).is_false()
	else:
		assert_bool(configured).is_true()
