extends SceneTree
## Plays the Alley Brawl boss fight, punches whenever the boss is in reach, and saves frames: a
## start frame, one frame during the boss's first telegraph, and the final frame. Run windowed:
##   godot --windowed --path src -s res://tools/brawl_preview.gd -- <out_dir> [--brawl-boss]

const VIEW := preload("res://scenes/battle/alley_brawl_view.tscn")
const Player := preload("res://scenes/battle/brawl_player.gd")
const World := preload("res://scenes/battle/brawl_world.gd")
const Boss := preload("res://scenes/battle/brawl_boss.gd")

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var out_dir: String = args[0]
	await process_frame
	var gs: Node = root.get_node("GameState")
	gs.persist_saves = false
	gs.tutorial_done = true
	var view: Control = VIEW.instantiate()
	view.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(view)
	var punches := 0
	var last_health := -1
	var shot_tele := false
	for f in range(600):
		await process_frame
		if not view.boss.is_empty():
			var bx: float = float(view.boss["x"])
			if absf(bx - view.player_x) < World.BOSS_REACH * view.u and view.punch_cooldown <= 0:
				Player.trigger_punch(view)
				punches += 1
			var hp: int = int(view.boss["health"])
			if hp != last_health:
				print("f", f, " boss health ", hp, " punches ", punches)
				last_health = hp
			if not shot_tele and Boss.is_telegraph(view.boss):
				shot_tele = true
				await RenderingServer.frame_post_draw
				print("saved telegraph err=", root.get_texture().get_image().save_png(out_dir.path_join("play-telegraph.png")))
		if f == 0 or f == 599:
			await RenderingServer.frame_post_draw
			print("saved f", f, " err=", root.get_texture().get_image().save_png(out_dir.path_join("play-f%03d.png" % f)))
	print("done punches=", punches, " boss_health=", last_health, " telegraph_shot=", shot_tele)
	quit()
