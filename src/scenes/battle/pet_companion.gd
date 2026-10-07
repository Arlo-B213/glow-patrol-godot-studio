extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Alley Brawl sidekick (Story 024): the active pet trails the hunter, bobs, and every few
## seconds is ready to "zap" a Gloomling for a tiny assist. Zap strength and timing are data
## (GameState.PETS zap_every / zap_boss) and it can never finish the boss on its own.
## The view owns combat: it calls `consume_zap()` only after it actually applied a zap.

var pet_id := ""
var species := ""
var stage := 1
var boss_chip := 0
var x := 0.0

var _every := 8.0
var _timer := 0.0
var _ready_to_zap := false
var _t := 0.0
var _moving := 0.0
var _spark_from := Vector2.ZERO
var _spark_to := Vector2.ZERO
var _spark_life := 0.0
var _spark_col := Color.WHITE
var _started := false


## Companion for the active pet, or null when no hatched pet is available.
static func create(gs: Node) -> RefCounted:
	var id: String = gs.active_pet_id()
	if id == "" or int(gs.pet_stage(id)) < 1:
		return null
	var zap: Dictionary = gs.pet_zap(id)
	var c := new()
	c.pet_id = id
	c.species = id
	c.stage = int(gs.pet_stage(id))
	c._every = float(zap["every"])
	c.boss_chip = int(zap["boss"])
	c._spark_col = gs.pet_def(id).get("accent", Color("#FFD36E"))
	return c


## Advances follow/bob/zap timers. `u` is the view's layout scale.
func update(delta: float, player_x: float, facing: int, moving: bool, u: float) -> void:
	_t += delta
	var want := player_x - float(facing) * 46.0 * u
	if not _started:
		x = want
		_started = true
	var before := x
	x = lerpf(x, want, clampf(delta * 4.0, 0.0, 1.0))
	_moving = lerpf(_moving, 1.0 if (moving or absf(x - before) > 0.2) else 0.0, clampf(delta * 6.0, 0.0, 1.0))
	if _every > 0.0 and not _ready_to_zap:
		_timer += delta
		if _timer >= _every:
			_ready_to_zap = true
	_spark_life = maxf(0.0, _spark_life - delta)


func zap_ready() -> bool:
	return _ready_to_zap


## Resets the zap timer and shows a spark from the pet to `target`.
func consume_zap(target: Vector2, from: Vector2) -> void:
	_ready_to_zap = false
	_timer = 0.0
	_spark_from = from
	_spark_to = target
	_spark_life = 0.35


## Where the pet's sparks start (above its back), for the view to aim from.
func muzzle(ground_y: float, u: float) -> Vector2:
	return Vector2(x, ground_y - 30.0 * u)


## Draws the pet and any spark on `ci`; `facing` is the hunter's facing (the pet mirrors it).
func draw(ci: CanvasItem, ground_y: float, u: float, facing: int) -> void:
	var side := 64.0 * u
	var rect := Rect2(Vector2(x - side * 0.5, ground_y + 4.0 * u - side * 0.92), Vector2(side, side))
	var hop := 0.0
	if UiMotion.enabled():
		hop = absf(sin(_t * (9.0 if _moving > 0.3 else 3.0))) * (0.3 if _moving > 0.3 else 0.12)
	var mood: int = PetArt.MOOD_HAPPY if _spark_life > 0.0 else PetArt.MOOD_NORMAL
	var ex := {"ready": _ready_to_zap}
	if _spark_life > 0.0:
		# Attack: lunge toward the target with a lean and a determined face.
		ex["react"] = "attack"
		ex["rt"] = 0.35 - _spark_life
		rect.position.x += float(facing) * sin((1.0 - _spark_life / 0.35) * PI) * 10.0 * u
	elif _moving > 0.3:
		mood = PetArt.MOOD_EXCITED
	PetArt.draw(ci, species, stage, rect, _t, UiMotion.enabled(), mood, hop, -float(facing), ex)
	if _spark_life > 0.0:
		_draw_spark(ci, u)


func _draw_spark(ci: CanvasItem, u: float) -> void:
	var f := _spark_life / 0.35
	var pts := PackedVector2Array()
	for i in 6:
		var k := float(i) / 5.0
		var jitter := 0.0 if (i == 0 or i == 5) else sin(float(i) * 9.1 + _t * 40.0) * 7.0 * u
		pts.append(_spark_from.lerp(_spark_to, k) + Vector2(0.0, jitter))
	FD.polyline(ci, pts, Color(_spark_col, 0.45 * f), 7.0 * u, true)
	FD.polyline(ci, pts, Color(1.0, 1.0, 0.9, f), 2.4 * u, true)
	FD.circle(ci, _spark_to, 9.0 * u * f, Color(_spark_col, 0.6 * f))
