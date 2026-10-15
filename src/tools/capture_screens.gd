extends SceneTree
## Boots the real app with saving disabled and screenshots chosen tabs. Run windowed:
##   godot --path src --windowed -s res://tools/capture_screens.gd -- <out_dir> <tab> [<tab> ...]
## Tabs are main.gd SCREEN_PATHS keys (home, club, battle, games, study, pets), or a res:// scene
## path, which is opened full-screen on top of the app (later scenes stack over earlier ones).


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var out_dir: String = args[0]
	await process_frame
	var gs: Node = root.get_node("GameState")
	gs.persist_saves = false
	gs.tutorial_done = true
	gs.last_login_date = Time.get_date_string_from_system()
	var main: Node = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	for i in range(1, args.size()):
		var name: String = args[i]
		if name.begins_with("res://"):
			var view: Control = (load(name) as PackedScene).instantiate()
			view.set_anchors_preset(Control.PRESET_FULL_RECT)
			main.add_child(view)
			name = name.get_file().get_basename()
		else:
			main.set_screen(name)
		for f in range(90):
			await process_frame
		await RenderingServer.frame_post_draw
		var img: Image = root.get_texture().get_image()
		print("saved ", name, " err=", img.save_png(out_dir.path_join("screen-%s.png" % name)))
	quit()
