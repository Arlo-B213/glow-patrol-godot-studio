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
		HunterHero.draw_hero(self, Rect2(Vector2.ZERO, size), look, t, idle_bob)
		return
	HunterArt.draw_portrait(self, Rect2(Vector2.ZERO, size), look, t)
