extends SceneTree
## Headless parse check: loads every game script under res:// and fails on any that does not
## compile (parse errors, missing functions on preloaded scripts, broken preloads). Third-party
## addons/ and the editor cache are skipped. Never touches the save.
## Run: godot --headless --path src -s ../tests/smoke/parse_smoke.gd   (exit 0 = pass)

const SKIP_DIRS := ["res://.godot", "res://addons"]

var fails := 0
var checked := 0


func _init() -> void:
	for path in _scripts("res://"):
		checked += 1
		var script: Script = load(path)
		if script == null or not script.can_instantiate():
			fails += 1
			print("FAIL ", path)
	print("checked ", checked, " scripts")
	if checked == 0:
		fails += 1
		print("FAIL no scripts found")
	print("DONE fails=", fails)
	quit(1 if fails > 0 else 0)


## Every .gd file under `dir`, depth-first, skipping SKIP_DIRS.
func _scripts(dir: String) -> PackedStringArray:
	var out := PackedStringArray()
	for sub in DirAccess.get_directories_at(dir):
		var child := dir.path_join(sub)
		if not SKIP_DIRS.has(child):
			out.append_array(_scripts(child))
	for f in DirAccess.get_files_at(dir):
		if f.get_extension() == "gd":
			out.append(dir.path_join(f))
	return out
