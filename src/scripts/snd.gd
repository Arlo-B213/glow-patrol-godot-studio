class_name Snd
extends RefCounted
## Safe one-line access to the Sfx autoload (works even when the autoload is absent, e.g. in -s test scripts).


## Plays a sound effect by id (see sfx.gd); silently does nothing without the autoload.
static func play(sfx_name: String, jitter: float = 0.0) -> void:
	var s: Node = _sfx()
	if s:
		s.play(sfx_name, jitter)


## Starts a music track by id.
static func music(track: String) -> void:
	var s: Node = _sfx()
	if s:
		s.play_music(track)


## Re-applies the Sound on/off setting.
static func refresh() -> void:
	var s: Node = _sfx()
	if s:
		s.refresh()


static func _sfx() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.root.get_node_or_null("Sfx") if tree else null
