extends SceneTree
## Captures the Clubhouse tabs (Closet, Lounge) and a Lanternboy dialogue for visual review. Run windowed:
##   godot --windowed --path src -s res://tools/club_preview.gd -- <out_dir>

func _init() -> void:
	var out_dir: String = OS.get_cmdline_user_args()[0]
	await process_frame
	var gs: Node = root.get_node("GameState")
	gs.persist_saves = false
	gs.tutorial_done = true
	gs.last_login_date = Time.get_date_string_from_system()
	var main: Node = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	main.set_screen("club")
	await _shot(out_dir, "club-closet")
	var club: Node = main.content_area.get_child(0)
	club.render_sub("lounge")
	await _shot(out_dir, "club-lounge")
	club.open_dialogue("hae")
	await _shot(out_dir, "club-dialogue-hae")
	quit()


func _shot(out_dir: String, name: String) -> void:
	for f in range(90):
		await process_frame
	await RenderingServer.frame_post_draw
	print("saved ", name, " err=", root.get_texture().get_image().save_png(out_dir.path_join("%s.png" % name)))
