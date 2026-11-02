extends SceneTree
## Renders the three Lanternboys full-length and as close-up faces in a few expressions, for
## before/after review of portrait art. Run windowed (it needs a renderer):
##   godot --path src --windowed -s res://tools/lanternboy_preview.gd -- <output.png> [hop]

const LanternboyArt := preload("res://scripts/lanternboy_art.gd")
const W := 1200
const H := 900
const BOYS := ["hae", "bit", "nun"]
const EXPRS := ["", "happy", "surprised", "shy"]


class Sheet extends Control:
	var hops := false

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#1E1238"))
		if hops:
			# High-five hop for each Lanternboy: bounce 0, 0.5 and 1 (stretch on the way up).
			for i in BOYS.size():
				for j in 3:
					LanternboyArt.draw(self, BOYS[i], Rect2(20 + j * 380, 20 + i * 290, 300, 270), 0.0, false, [0.0, 0.5, 1.0][j])
			return
		for i in BOYS.size():
			LanternboyArt.draw(self, BOYS[i], Rect2(20 + i * 390, 20, 370, 470), 0.0, false)
		for i in BOYS.size():
			for j in EXPRS.size():
				LanternboyArt.draw(self, BOYS[i], Rect2(20 + j * 292, 520 + i * 120, 116, 116), 0.0, false, 0.0, EXPRS[j])


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "user://lanternboy_preview.png"
	await process_frame
	var vp := SubViewport.new()
	vp.size = Vector2i(W, H)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var sheet := Sheet.new()
	sheet.hops = args.size() > 1 and args[1] == "hop"
	sheet.size = Vector2(W, H)
	vp.add_child(sheet)
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var img: Image = vp.get_texture().get_image()
	print("saved err=", img.save_png(out))
	quit()
