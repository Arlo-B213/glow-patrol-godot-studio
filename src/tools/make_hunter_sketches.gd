extends SceneTree
## Renders the hunter design-direction sheet. Run windowed (it needs a renderer):
##   godot --path src --windowed -s res://tools/make_hunter_sketches.gd
## Writes design/art/concepts/hunter/round2-sheet.png plus one PNG per direction.

const SketchArt := preload("res://tools/hunter_sketch_art.gd")
const NAMES := ["round2-a-stage-star", "round2-b-night-patrol", "round2-c-gloom-breaker"]


func _init() -> void:
	await process_frame
	var sz: Vector2 = SketchArt.sheet_size()
	var vp := SubViewport.new()
	vp.size = Vector2i(sz)
	vp.msaa_2d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var art: Control = SketchArt.new()
	art.size = sz
	vp.add_child(art)
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var img: Image = vp.get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	var out_dir: String = ProjectSettings.globalize_path("res://").path_join("../design/art/concepts/hunter")
	DirAccess.make_dir_recursive_absolute(out_dir)
	print("saved sheet err=", img.save_png(out_dir.path_join("round2-sheet.png")))
	for i in NAMES.size():
		var r: Rect2 = SketchArt.panel_rect(i)
		var crop: Image = img.get_region(Rect2i(r))
		print("saved ", NAMES[i], " err=", crop.save_png(out_dir.path_join(NAMES[i] + ".png")))
	var heads := Image.create(3 * 480, 480, false, Image.FORMAT_RGBA8)
	for i in NAMES.size():
		var r: Rect2 = SketchArt.panel_rect(i)
		var head_img: Image = img.get_region(Rect2i(int(r.position.x + r.size.x * 0.5 - 120.0), 160, 240, 240))
		head_img.resize(480, 480, Image.INTERPOLATE_LANCZOS)
		heads.blit_rect(head_img, Rect2i(0, 0, 480, 480), Vector2i(i * 480, 0))
	print("saved heads err=", heads.save_png(out_dir.path_join("round2-heads.png")))
	quit()
