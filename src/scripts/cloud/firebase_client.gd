class_name FirebaseClient
extends Node
## Talks to Firebase over its REST API: anonymous sign-in, then reading and writing Firestore
## documents. Requests run through an HTTPRequest child, so the game never blocks on the network.

signal signed_in(user_id: String)
signal request_failed(message: String)
signal document_loaded(path: String, data: Dictionary)
signal document_saved(path: String)
signal document_exists(path: String)

var user_id: String = ""
var _id_token: String = ""
var _http: HTTPRequest
var _busy: bool = false
var _pending: Callable


func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)


## JSON body for an anonymous sign-up. The reply carries an id token and the new user's id.
static func sign_up_body() -> Dictionary:
	return {"returnSecureToken": true}


## Full URL of a Firestore document, or "" for an empty path.
static func document_url(path: String) -> String:
	if path.strip_edges() == "":
		return ""
	return FirebaseConfig.documents_url() + "/" + path


## Creates an anonymous player account. Emits `signed_in` or `request_failed`.
func sign_in_anonymously() -> void:
	if not FirebaseConfig.is_configured():
		request_failed.emit("Firebase is not configured: paste the API key in firebase_config.gd")
		return
	_send(FirebaseConfig.sign_up_url(), HTTPClient.METHOD_POST, sign_up_body(), _on_signed_up)


## Loads a document. Emits `document_loaded` with the decoded fields.
func get_document(path: String) -> void:
	var url := document_url(path)
	if url == "":
		request_failed.emit("Empty document path")
		return
	_send(url, HTTPClient.METHOD_GET, {}, func(code: int, body: Dictionary) -> void:
		if code == 404:
			document_loaded.emit(path, {})
		elif code == 200:
			document_loaded.emit(path, FirestoreCodec.decode(body)))


## Creates a document with a chosen ID, only if that ID is free. Emits `document_saved` on success
## or `document_exists` when the ID is already taken (used for friend codes, which must be unique).
func create_document(collection: String, doc_id: String, data: Dictionary) -> void:
	var url := create_url(collection, doc_id)
	if url == "":
		request_failed.emit("Empty collection or ID")
		return
	var path := collection + "/" + doc_id
	_send(url, HTTPClient.METHOD_POST, FirestoreCodec.encode(data), func(code: int, _body: Dictionary) -> void:
		if code == 200:
			document_saved.emit(path)
		elif code == 409:
			document_exists.emit(path)
		else:
			request_failed.emit("Create failed (%d)" % code))


## URL that creates `doc_id` in `collection`, or "" when either is empty.
static func create_url(collection: String, doc_id: String) -> String:
	if collection.strip_edges() == "" or doc_id.strip_edges() == "":
		return ""
	return FirebaseConfig.documents_url() + "/" + collection + "?documentId=" + doc_id


## Writes a document, replacing its fields. Emits `document_saved`.
func set_document(path: String, data: Dictionary) -> void:
	var url := document_url(path)
	if url == "":
		request_failed.emit("Empty document path")
		return
	_send(url, HTTPClient.METHOD_PATCH, FirestoreCodec.encode(data), func(code: int, _body: Dictionary) -> void:
		if code == 200:
			document_saved.emit(path))


func _on_signed_up(code: int, body: Dictionary) -> void:
	if code != 200:
		request_failed.emit("Sign-in failed (%d)" % code)
		return
	user_id = String(body.get("localId", ""))
	_id_token = String(body.get("idToken", ""))
	signed_in.emit(user_id)


func _send(url: String, method: int, payload: Variant, done: Callable) -> void:
	if _busy:
		request_failed.emit("A request is already running")
		return
	_busy = true
	_pending = done
	var headers := PackedStringArray(["Content-Type: application/json"])
	if _id_token != "":
		headers.append("Authorization: Bearer " + _id_token)
	var body := JSON.stringify(payload) if not (payload is Dictionary and payload.is_empty()) else ""
	var err := _http.request(url, headers, method, body)
	if err != OK:
		_busy = false
		request_failed.emit("Could not start the request (%d)" % err)


func _on_request_completed(result: int, code: int, _headers: PackedStringArray, raw: PackedByteArray) -> void:
	_busy = false
	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit("Network error (%d)" % result)
		return
	var parsed: Variant = JSON.parse_string(raw.get_string_from_utf8())
	var body: Dictionary = parsed if parsed is Dictionary else {}
	_pending.call(code, body)
