class_name BrawlBreakerRig
extends RefCounted
## Draws the player hunter in Alley Brawl with the Gloom Breaker rig when that outfit is worn.
## The rig is a CharacterRig child of the brawl view, placed at the hunter's feet every frame.
## Other outfits keep the code-drawn HunterArt, so their outfit and hair customisation still works.

const CharacterRig := preload("res://scripts/rigs/character_rig.gd")
const BreakerRigData := preload("res://scripts/rigs/breaker_rig_data.gd")

const NODE_NAME := "BreakerRig"
## Rig pixels to brawl pixels per unit of hunter scale. Tuned against the code hunter's height.
const FIGURE_SCALE := 0.11
## Added to every bone's z so the rig draws above the brawl view's own drawing.
const DRAW_BASE := 10


## True when the look wears the Gloom Breaker outfit (the one the rig matches).
static func is_breaker(look: Dictionary) -> bool:
	return String(look.get("outfit_style", "")) == "breaker"


## Negative z_index draws under the host's own _draw, which hides the back parts (cape, back
## hair, legs) behind the floor. Each bone gets an absolute draw order, lifted above the host and
## keeping the rig's back-to-front order.
static func _lift_draw_order(rig: CharacterRig) -> void:
	for bone: Dictionary in BreakerRigData.rig()["bones"]:
		var node: Node2D = rig.find_child(String(bone["name"]), true, false) as Node2D
		if node == null:
			continue
		node.z_as_relative = false
		node.z_index = int(bone.get("z", 0)) + DRAW_BASE


## Places and animates the breaker rig under `host` for this frame. `x` and `feet_y` are the
## hunter's feet point, `u_eff` the same scale HunterArt uses (u * HUNTER_ART_SCALE * sc).
## Animation restarts only when the state changes, because CharacterRig.play resets its clock.
static func sync(host: Node, x: float, feet_y: float, u_eff: float, facing: int, alpha: float, moving: bool, punch_active: int, hurt_t: int) -> void:
	var rig: CharacterRig = host.get_node_or_null(NODE_NAME) as CharacterRig
	if rig == null:
		rig = CharacterRig.new()
		rig.name = NODE_NAME
		rig.setup(BreakerRigData.rig(), BreakerRigData.animations())
		host.add_child(rig)
		_lift_draw_order(rig)
		rig.play("idle")
	var s: float = u_eff * FIGURE_SCALE
	var f: float = float(facing)
	# Canvas point (512, 1024) is the feet, so the rig's origin is offset to put it on (x, feet_y).
	rig.scale = Vector2(s * f, s)
	rig.position = Vector2(x, feet_y) - Vector2(512.0 * s * f, 1024.0 * s)
	rig.modulate = Color(1.0, 1.0, 1.0, alpha)
	rig.visible = true
	var want: String = "idle"
	if punch_active > 0:
		want = "attack"
	elif hurt_t >= 0:
		want = "hurt"
	elif moving:
		want = "walk"
	if rig.current() != want:
		rig.play(want)
