class_name BrawlWalkSprite
extends RefCounted
## Draws the Gloom Breaker in Alley Brawl with her exported walk sprite (walking east or west, idle when
## still). The sprite's origin is the point between her feet, so it is placed at the hunter's feet point.

const WALK_SCENE := preload("res://assets/walk_sprites/breaker/breaker.tscn")
const NODE_NAME := "WalkSprite"
## Sprite pixels (256 px tall frames) to brawl pixels per unit of hunter scale, so her height matches the old rig.
const SCALE_PER_UNIT := 0.44


## Sprite scale for a brawl hunter unit `u_eff` (the same value the hunter drawing uses).
static func scale_for(u_eff: float) -> float:
	return u_eff * SCALE_PER_UNIT


## The [animation, facing] to play: walking or idle, facing east when she faces right, else west.
static func animation_for(moving: bool, facing: int) -> Array:
	return ["walk" if moving else "idle", "east" if facing >= 0 else "west"]


## Places and animates the walk sprite under `host` for this frame. Restarts only when the animation changes.
static func sync(host: Node, x: float, feet_y: float, u_eff: float, facing: int, alpha: float, moving: bool) -> void:
	var node := host.get_node_or_null(NODE_NAME) as Node2D
	if node == null:
		node = WALK_SCENE.instantiate() as Node2D
		node.name = NODE_NAME
		host.add_child(node)
	var s: float = scale_for(u_eff)
	node.position = Vector2(x, feet_y)
	node.scale = Vector2(s, s)
	node.modulate = Color(1.0, 1.0, 1.0, alpha)
	node.visible = true
	var anim: Array = animation_for(moving, facing)
	node.call("play", anim[0], anim[1])
