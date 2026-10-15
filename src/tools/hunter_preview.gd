extends SceneTree
## Renders the in-game hunter in a spread of looks, expressions and the side view, for
## before/after review of art changes. Run windowed (it needs a renderer):
##   godot --path src --windowed -s res://tools/hunter_preview.gd -- <output.png>

const HunterArt := preload("res://scripts/hunter_art.gd")
const W := 1500
const H := 1240
const LOOKS := [
	{"outfit": Color("#6C5CE7"), "outfit_style": "track", "hair": Color("#3B2A6B"), "glow": Color("#FFC15E"), "weapon": "stick", "hairstyle": "bob", "headwear": "none", "face_acc": "none"},
	{"outfit": Color("#FF5FA2"), "outfit_style": "sequin", "hair": Color("#B93B6B"), "glow": Color("#52E8C6"), "weapon": "comet", "hairstyle": "twintails", "headwear": "bow", "face_acc": "blush"},
	{"outfit": Color("#52E8C6"), "outfit_style": "armor", "hair": Color("#FFC15E"), "glow": Color("#8E7CFF"), "weapon": "rod", "hairstyle": "bob", "headwear": "cat-ears", "face_acc": "glasses"},
	{"outfit": Color("#8E7CFF"), "outfit_style": "hanbok", "hair": Color("#101033"), "glow": Color("#FF5FA2"), "weapon": "scepter", "hairstyle": "ponytail", "headwear": "star-clip", "face_acc": "freckles"},
	{"outfit": Color("#FFD36E"), "outfit_style": "tailcoat", "hair": Color("#52E8C6"), "glow": Color("#FFC15E"), "weapon": "stick", "hairstyle": "twintails", "headwear": "flower-crown", "face_acc": "none"},
]
const EXPRS := ["neutral", "happy", "cheer", "determined", "hurt", "surprised", "shy", "sleepy"]


class Sheet extends Control:
	var heads := false
	var poses := false

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#1E1238"))
		if heads:
			for i in 3:
				var look: Dictionary = LOOKS[[0, 1, 3][i]].duplicate()
				look["expression"] = ["neutral", "happy", "determined"][i]
				HunterArt.draw_portrait(self, Rect2(i * 500, -60, 500, 600), look)
			for i in 3:
				HunterArt.draw_hunter(self, 250 + i * 500, 1500, 9.0, 1, 0, false, 1.0, 0, LOOKS[[0, 1, 3][i]], -1, false)
			return
		if poses:
			var ids: Array = ["idle", "cheer", "victory", "sit", "fever"]
			for i in ids.size():
				var look: Dictionary = LOOKS[i].duplicate()
				look["pose"] = ids[i]
				HunterArt.draw_portrait(self, Rect2(20 + i * 296, 20, 270, 520), look, 0.4)
				HunterArt.draw_portrait(self, Rect2(20 + i * 296, 600, 120, 120), look, 0.4)
			return
		var font: Font = ThemeDB.fallback_font
		for i in LOOKS.size():
			HunterArt.draw_portrait(self, Rect2(20 + i * 296, 20, 270, 520), LOOKS[i])
		for i in EXPRS.size():
			var look: Dictionary = LOOKS[0].duplicate()
			look["expression"] = EXPRS[i]
			HunterArt.draw_portrait(self, Rect2(20 + i * 184, 570, 170, 170), look)
			draw_string(font, Vector2(30 + i * 184, 760), EXPRS[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 1, 1, 0.7))
		for i in LOOKS.size():
			HunterArt.draw_hunter(self, 150 + i * 296, 1120, 2.6, 1 if i % 2 == 0 else -1, 0, false, 1.0, 0, LOOKS[i], -1, false)
		for i in 3:
			var look: Dictionary = LOOKS[i].duplicate()
			look["expression"] = ["happy", "cheer", "surprised"][i]
			HunterArt.draw_portrait(self, Rect2(20 + i * 296, 790, 60, 60), look)


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "user://hunter_preview.png"
	var heads: bool = args.size() > 1 and args[1] == "heads"
	await process_frame
	var vp := SubViewport.new()
	vp.size = Vector2i(W, H)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var sheet := Sheet.new()
	sheet.heads = heads
	sheet.poses = args.size() > 1 and args[1] == "poses"
	sheet.size = Vector2(W, H)
	vp.add_child(sheet)
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var img: Image = vp.get_texture().get_image()
	print("saved err=", img.save_png(out))
	quit()
