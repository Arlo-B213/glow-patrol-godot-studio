extends Control
## Reusable front-facing portrait of the idol hunter. Draws the player's equipped look
## (GameState.hunter_look()) through HunterArt, scaled to fill the control's rect.
## Tall controls show the full body, squarer ones head-and-torso.

const HunterArt := preload("res://scripts/hunter_art.gd")
const HunterMotion := preload("res://scripts/hunter_motion.gd")
const HunterHero := preload("res://scripts/hunter_hero.gd")

## Idle animation (blink, breathing, sway, glow pulse). Only costs frames while the
## portrait is visible in the tree and motion is allowed; closet cards turn it off.
@export var idle_bob: bool = true

## Hero mode: draws the stage backdrop with the full-body hunter (HunterHero) instead of
## the plain portrait. Animates through `idle_bob` like the normal portrait.
var hero: bool = false:
	set(v):
		hero = v
		queue_redraw()

var _look_override: Dictionary = {}
var _time: float = 0.0
## The Gloom Breaker's full-body walk sprite (exported by SpriteCast), created on first use in hero mode
## and hidden for other outfits.
const WALK_BREAKER := preload("res://assets/walk_sprites/breaker/breaker.tscn")
const WALK_BREAKER_SCRIPT := preload("res://assets/walk_sprites/breaker/breaker.gd")
var _walk: Node2D


func _init() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	_update_processing()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_update_processing()


func _update_processing() -> void:
	set_process(idle_bob and is_visible_in_tree() and HunterMotion.motion_on())


func _process(delta: float) -> void:
	if not HunterMotion.motion_on():
		# Reduced motion: settle on the still pose and stop processing.
		_time = 0.0
		set_process(false)
		queue_redraw()
		return
	_time += delta
	queue_redraw()


## Redraws from the current GameState look. Call after equipping an item or changing
## the reduce-motion setting (re-checks whether to animate).
func refresh() -> void:
	_update_processing()
	queue_redraw()


## Shows an arbitrary look (see GameState.hunter_look() for the keys) instead of the
## equipped one, without touching GameState. Pass an empty dictionary to go back.
func set_look(look: Dictionary) -> void:
	_look_override = look
	queue_redraw()


func _draw() -> void:
	var look: Dictionary = _look_override
	if look.is_empty():
		var gs: Node = get_node_or_null("/root/GameState")
		if gs == null:
			return
		look = gs.hunter_look()
	var t: float = _time if idle_bob else 0.0
	if hero:
		_draw_hero_look(look, t)
		return
	HunterArt.draw_portrait(self, Rect2(Vector2.ZERO, size), look, t)


## Hero mode: the stage backdrop, then the figure. The Gloom Breaker is its full-body walk sprite
## laid over the backdrop; every other outfit keeps the code-drawn figure.
func _draw_hero_look(look: Dictionary, t: float) -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var breaker: bool = String(look.get("outfit_style", "")) == "breaker"
	HunterHero.draw_hero(self, rect, look, t, idle_bob, not breaker)
	if not breaker:
		if _walk != null:
			_walk.visible = false
		return
	if _walk == null:
		_walk = WALK_BREAKER.instantiate()
		add_child(_walk)
		_walk.call("play", "idle", "south")
	_walk.visible = true
	_fit_walk(HunterHero.figure_rect(rect))
	if not HunterMotion.motion_on():
		(_walk.get_node("Body") as AnimatedSprite2D).stop()


## Scales the walk sprite so its whole frame fits the figure area, with the feet on the area's base.
func _fit_walk(fig: Rect2) -> void:
	var body := _walk.get_node("Body") as AnimatedSprite2D
	var frame_h := float(body.sprite_frames.get_frame_texture(&"idle_south", 0).get_height())
	var s := fig.size.y / frame_h
	var feet_from_top: float = -WALK_BREAKER_SCRIPT.OFFSETS[&"idle_south"][0].y
	_walk.scale = Vector2(s, s)
	_walk.position = Vector2(fig.get_center().x, fig.position.y + feet_from_top * s)
