extends SceneTree
## Renders the five gloom enemies at idle and angry moods, for before/after review of gloom face
## art. Run windowed (it needs a renderer):
##   godot --path src --windowed -s res://tools/gloom_preview.gd -- <output.png>

const Imp := preload("res://scenes/battle/gloom_imp.gd")
const Scout := preload("res://scenes/battle/gloom_scout.gd")
const Brute := preload("res://scenes/battle/gloom_brute.gd")
const King := preload("res://scenes/battle/gloom_king.gd")
const Hydra := preload("res://scenes/battle/gloom_hydra.gd")
const W := 1500
const H := 620


class Sheet extends Control:
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#1E1238"))
		for row in 2:
			var idle: Dictionary = {} if row == 0 else {"near": 0.9}
			var y: float = 280.0 + float(row) * 300.0
			Imp.draw(self, 130.0, y, 150.0, Color("#7B5CFF"), 40, 1.0, 1.0, idle)
			Scout.draw(self, 380.0, y, 150.0, Color("#52E8C6"), 40, 1.0, 1.0, idle)
			Brute.draw(self, 640.0, y, 150.0, Color("#FF5FA2"), 40, 1.0, 1.0, idle)
			King.draw(self, 920.0, y, 150.0, 40, 1.0, 1.0, idle)
			Hydra.draw(self, 1250.0, y, 150.0, 40, 1.0, 1.0, idle)


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "user://gloom_preview.png"
	await process_frame
	var vp := SubViewport.new()
	vp.size = Vector2i(W, H)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var sheet := Sheet.new()
	sheet.size = Vector2(W, H)
	vp.add_child(sheet)
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var img: Image = vp.get_texture().get_image()
	print("saved err=", img.save_png(out))
	quit()
