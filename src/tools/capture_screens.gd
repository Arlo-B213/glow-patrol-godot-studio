extends SceneTree
## Boots the real app with saving disabled and screenshots chosen tabs. Run windowed:
##   godot --path src --windowed -s res://tools/capture_screens.gd -- <out_dir> <tab> [<tab> ...]
## Tabs are main.gd SCREEN_PATHS keys (home, club, battle, games, study, pets).


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
		main.set_screen(args[i])
		for f in range(90):
			await process_frame
		await RenderingServer.frame_post_draw
		var img: Image = root.get_texture().get_image()
		print("saved ", args[i], " err=", img.save_png(out_dir.path_join("screen-%s.png" % args[i])))
	quit()
