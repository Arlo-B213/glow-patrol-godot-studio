class_name FirebaseConfig
extends RefCounted
## Public Firebase settings for the game. They identify the project and are not secrets: who can
## read or write data is decided by the security rules in Firebase, not by hiding these values.

## The Firebase project ID (google-services.json: project_info.project_id).
const PROJECT_ID := "mimis-game"
## The web API key (google-services.json: client[0].api_key[0].current_key). Left empty until pasted.
const WEB_API_KEY := "AIzaSyA2kAmDFRfZAd5xivgb7ZVGDD-oNVj1bQk"

const FIRESTORE_ROOT := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents"
const SIGN_UP_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"


## Base URL for Firestore documents in this project.
static func documents_url() -> String:
	return FIRESTORE_ROOT % PROJECT_ID


## Anonymous sign-up endpoint, with the API key in the query as Firebase expects.
static func sign_up_url() -> String:
	return SIGN_UP_URL % WEB_API_KEY


## True once the API key has been pasted in; the cloud features stay off until then.
static func is_configured() -> bool:
	return WEB_API_KEY != "" and PROJECT_ID != ""
