extends RefCounted
## Loads the approved character art from res://assets/art/characters/<id>/<expression>.png.
## Returns null when a file is missing, so callers fall back to the code-drawn art.
## Textures load through ResourceLoader (they are imported at export) and are cached per path.

const ROOT := "res://assets/art/characters"

static var _cache: Dictionary = {}


## Path of the image for a character id and expression, e.g. ("hae", "neutral").
static func path_for(id: String, expression: String = "neutral") -> String:
	return "%s/%s/%s.png" % [ROOT, id, expression]


## Texture for a character and expression, or null when no approved image exists.
static func texture(id: String, expression: String = "neutral") -> Texture2D:
	var path := path_for(id, expression)
	if _cache.has(path):
		return _cache[path]
	var tex: Texture2D = null
	# Exported builds ship imported textures, not the source PNG, so load through ResourceLoader.
	if ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	_cache[path] = tex
	return tex


## Clears the cache (tests use this so each run starts clean).
static func clear_cache() -> void:
	_cache.clear()
