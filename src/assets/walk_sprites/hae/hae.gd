extends Node2D
## hae, written by SpriteCast's export.py. The node's position is the point between the feet (on a seat: where the body rests).
##   play("walk", "south-east")      facings: south, south-east, east, north-east, north, north-west, west, south-west
## A facing the set has no drawing for (a set made with "facings": 4 has the diagonals only, "cardinal" the cardinals) shows the nearest one it
## has; between two as near (east, between south-east and north-east; south-east, between south and east) the one shown last stays, so walking straight across does not flicker;
## with none shown yet, the one turned more toward the viewer.
## Each animation has its own frame size, so the Body's, the Shadow's and the Effect's offsets are set per animation, from the table below.
## Effect: what a swing leaves in the air (water, flame, leaves ...), over the body; it runs at its own pace beside the body's frames.

const OFFSETS := {   # animation: [body offset, shadow offset, effect offset] from the feet, px
	&"walk_south": [Vector2(-115.9, -225.8), Vector2(-127.9, -115.80000000000001), Vector2(-115.9, -225.8)],
	&"idle_south": [Vector2(-115.9, -225.8), Vector2(-126.9, -115.80000000000001), Vector2(-115.9, -225.8)],
	&"walk_south_east": [Vector2(-115.9, -225.8), Vector2(-130.9, -117.80000000000001), Vector2(-115.9, -225.8)],
	&"idle_south_east": [Vector2(-115.9, -225.8), Vector2(-126.9, -117.80000000000001), Vector2(-115.9, -225.8)],
	&"walk_east": [Vector2(-115.9, -225.8), Vector2(-146.9, -110.80000000000001), Vector2(-115.9, -225.8)],
	&"idle_east": [Vector2(-115.9, -225.8), Vector2(-140.9, -111.80000000000001), Vector2(-115.9, -225.8)],
	&"walk_north_east": [Vector2(-115.9, -225.8), Vector2(-148.9, -108.80000000000001), Vector2(-115.9, -225.8)],
	&"idle_north_east": [Vector2(-115.9, -225.8), Vector2(-146.9, -114.80000000000001), Vector2(-115.9, -225.8)],
	&"walk_north": [Vector2(-115.9, -225.8), Vector2(-132.9, -107.80000000000001), Vector2(-115.9, -225.8)],
	&"idle_north": [Vector2(-115.9, -225.8), Vector2(-136.9, -115.80000000000001), Vector2(-115.9, -225.8)],
	&"walk_north_west": [Vector2(-115.9, -225.8), Vector2(-127.9, -108.80000000000001), Vector2(-115.9, -225.8)],
	&"idle_north_west": [Vector2(-115.9, -225.8), Vector2(-137.9, -114.80000000000001), Vector2(-115.9, -225.8)],
	&"walk_west": [Vector2(-115.9, -225.8), Vector2(-122.9, -108.80000000000001), Vector2(-115.9, -225.8)],
	&"idle_west": [Vector2(-115.9, -225.8), Vector2(-137.9, -108.80000000000001), Vector2(-115.9, -225.8)],
	&"walk_south_west": [Vector2(-115.9, -225.8), Vector2(-127.9, -108.80000000000001), Vector2(-115.9, -225.8)],
	&"idle_south_west": [Vector2(-115.9, -225.8), Vector2(-136.9, -109.80000000000001), Vector2(-115.9, -225.8)],
}

@onready var body: AnimatedSprite2D = $Body
@onready var shadow: AnimatedSprite2D = $Shadow
@onready var effect: AnimatedSprite2D = $Effect

func _ready() -> void:
	body.frame_changed.connect(func(): shadow.frame = body.frame)
	play_named(&"idle_south")

const FACINGS := ["south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west"]
var facing_shown := ""

func has(action: String, facing: String) -> bool:
	return OFFSETS.has(StringName((action + "_" + facing).replace("-", "_")))

## the facing drawn for this action nearest to the one asked for (itself when it is drawn)
func nearest(action: String, facing: String) -> String:
	if has(action, facing):
		return facing
	var i := FACINGS.find(facing)
	var best := ""
	var best_d := 99
	for j in FACINGS.size():
		if not has(action, FACINGS[j]):
			continue
		var dd: int = abs(i - j)
		dd = min(dd, 8 - dd)
		# between two as near: the one shown last, else the one turned more toward the viewer (west: south-west)
		if dd < best_d or (dd == best_d and best != facing_shown and (FACINGS[j] == facing_shown or min(j, 8 - j) < min(FACINGS.find(best), 8 - FACINGS.find(best)))):
			best = FACINGS[j]
			best_d = dd
	return best

func play(action: String, facing: String, restart := false) -> void:
	var f := nearest(action, facing)
	if f == "":
		return
	facing_shown = f
	play_named(StringName((action + "_" + f).replace("-", "_")), restart)

func play_named(anim: StringName, restart := false) -> void:
	if not OFFSETS.has(anim) or (body.animation == anim and body.is_playing() and not restart):
		return
	body.offset = OFFSETS[anim][0]
	shadow.offset = OFFSETS[anim][1]
	shadow.visible = shadow.sprite_frames.get_frame_count(anim) > 0
	shadow.animation = anim
	effect.offset = OFFSETS[anim][2]
	effect.visible = effect.sprite_frames.get_frame_count(anim) > 0
	body.play(anim)
	body.frame = 0
	shadow.frame = 0
	if effect.visible:
		effect.play(anim)
		effect.frame = 0
