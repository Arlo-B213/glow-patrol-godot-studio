extends SceneTree
## Renders every pet species at adult stage and a baby of each, for before/after review of pet
## art. Run windowed (it needs a renderer):
##   godot --path src --windowed -s res://tools/pet_preview.gd -- <output.png>

const PetArt := preload("res://scripts/pet_art.gd")
const W := 1500
const H := 800
const SPECIES := ["xolo", "puff", "sparkfox", "moonbun", "inkydrake"]


class Sheet extends Control:
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#1E1238"))
		for i in SPECIES.size():
			PetArt.draw(self, SPECIES[i], 3, Rect2(10 + i * 300, 10, 290, 290), 0.0, false)
			PetArt.draw(self, SPECIES[i], 1, Rect2(10 + i * 300, 330, 290, 290), 0.0, false)
			PetArt.draw(self, SPECIES[i], 1, Rect2(10 + i * 300, 620, 130, 130), 0.0, false, PetArt.MOOD_HAPPY)


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "user://pet_preview.png"
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
