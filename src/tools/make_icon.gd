extends SceneTree
## Regenerates the app icon PNGs. Run windowed (it needs a renderer):
##   godot --path src --windowed -s res://tools/make_icon.gd
## Writes src/icon.png (256 px, the project icon), icon_512.png and the smaller sizes.

const IconArt := preload("res://tools/icon_art.gd")
const SIZES := [512, 256, 128, 64, 32, 16]
const OUT_DIR := "res://"


func _init() -> void:
	await process_frame
	await process_frame
	var vp := SubViewport.new()
	vp.size = Vector2i(512, 512)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var art: Control = IconArt.new()
	art.size = Vector2(512, 512)
	vp.add_child(art)
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var base: Image = vp.get_texture().get_image()
	base.convert(Image.FORMAT_RGBA8)
	for sz in SIZES:
		var img: Image = base.duplicate()
		if sz != 512:
			img.resize(sz, sz, Image.INTERPOLATE_LANCZOS)
		var name: String = "icon_%d.png" % sz
		if sz == 256:
			name = "icon.png"
		var path: String = OUT_DIR + name
		var err: int = img.save_png(path)
		print("saved ", path, " err=", err)
	# A 256 copy with the numbered name too, so the set is complete.
	var img256: Image = base.duplicate()
	img256.resize(256, 256, Image.INTERPOLATE_LANCZOS)
	img256.save_png(OUT_DIR + "icon_256.png")
	quit()
