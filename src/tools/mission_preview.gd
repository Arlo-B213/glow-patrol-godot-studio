extends SceneTree
## Captures the Lounge map and a Lounge mission with its quiz card open, for visual review. Run windowed:
##   godot --windowed --path src -s res://tools/mission_preview.gd -- <out_dir>

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
	await _settle()
	main.content_area.get_child(0).render_sub("lounge")
	await _shot(out_dir, "lounge-map")
	main.start_mission(LoungeMissions.by_id("bridge-1"))
	await _settle()
	var view: Node = main.content_area.get_child(0)
	view._zone_cleared()
	await _shot(out_dir, "lounge-mission-quiz")
	main._show_mission_result(LoungeMissions.by_id("bridge-1"), 34, 6, true, 6)
	await _shot(out_dir, "mission-result")
	quit()


func _settle() -> void:
	for f in range(90):
		await process_frame


func _shot(out_dir: String, name: String) -> void:
	await _settle()
	await RenderingServer.frame_post_draw
	print("saved ", name, " err=", root.get_texture().get_image().save_png(out_dir.path_join("%s.png" % name)))
