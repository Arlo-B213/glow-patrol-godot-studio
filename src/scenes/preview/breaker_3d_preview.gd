extends Node3D
## 3D preview of the Gloom Breaker. Each full-body view is extruded into a slab by
## tools/batch_extrude.gd. The camera-facing slab swaps to the matching view as the character
## turns, so the sprite art is shown from its own angles, with real shadows and lights.
## Set `angle_override` (degrees) to freeze on one angle; leave it at -1 to sweep.

const MESH_DIR := "res://assets/meshes_25d/"
const TEX_DIR := "res://assets/art/characters/breaker/views/"
const SWEEP_SECONDS := 12.0
## Sway of the slab around its facing, so the extrusion depth reads from the camera.
const SWAY_DEGREES := 12.0

## Angle (degrees) -> view name and whether the view is mirrored to face the other way.
const VIEWS := [
	{"from": 0.0, "view": "gb-front", "mirror": false},
	{"from": 22.5, "view": "gb-three-quarter", "mirror": false},
	{"from": 67.5, "view": "gb-side", "mirror": false},
	{"from": 112.5, "view": "gb-back", "mirror": false},
	{"from": 247.5, "view": "gb-side", "mirror": true},
	{"from": 292.5, "view": "gb-three-quarter", "mirror": true},
]

@export var angle_override: float = -1.0
## Set before the node enters the tree. Transparent mode clears the sky and drops the floor, so the
## model can sit over a 2D backdrop (the HQ hero card and the Club previews).
var transparent: bool = false

var _slab: MeshInstance3D
var _current: String = ""
var _mirrored: bool = false
var _elapsed: float = 0.0


func _ready() -> void:
	_build_stage()
	_slab = MeshInstance3D.new()
	_slab.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(_slab)
	_show(0.0)


func _process(delta: float) -> void:
	_elapsed += delta
	var angle: float = angle_override if angle_override >= 0.0 else fmod(_elapsed / SWEEP_SECONDS * 360.0, 360.0)
	_show(angle)


## Picks the view for `angle` and applies it, with a small sway around the facing.
func _show(angle: float) -> void:
	var pick: Dictionary = _pick(angle)
	if pick["view"] != _current or pick["mirror"] != _mirrored:
		_current = pick["view"]
		_mirrored = pick["mirror"]
		_slab.mesh = load(MESH_DIR + _current + ".tres")
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = load(TEX_DIR + _current + ".png")
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		mat.alpha_scissor_threshold = 0.5
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		_slab.set_surface_override_material(0, mat)
		_slab.set_surface_override_material(1, mat)
	var sway: float = sin(angle * PI / 180.0) * SWAY_DEGREES
	_slab.rotation_degrees = Vector3(0.0, sway, 0.0)
	_slab.scale = Vector3(-1.0 if _mirrored else 1.0, 1.0, 1.0)


## The view whose start angle is the last one at or below `angle`, wrapping at 360.
func _pick(angle: float) -> Dictionary:
	var chosen: Dictionary = VIEWS[0]
	for entry: Dictionary in VIEWS:
		if angle >= float(entry["from"]):
			chosen = entry
	return chosen


func _build_stage() -> void:
	var cam := Camera3D.new()
	cam.position = Vector3(0.0, 0.0, 22.0)
	cam.fov = 40.0
	add_child(cam)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45.0, 30.0, 0.0)
	sun.shadow_enabled = true
	add_child(sun)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_CLEAR_COLOR if transparent else Environment.BG_COLOR
	env.environment.background_color = Color("#1a0b33")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.6, 0.55, 0.7)
	add_child(env)
	if transparent:
		return
	var floor_mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(30.0, 30.0)
	floor_mi.mesh = plane
	floor_mi.position = Vector3(0.0, -5.2, 0.0)
	var fmat := StandardMaterial3D.new()
	fmat.albedo_color = Color("#2a1f55")
	floor_mi.set_surface_override_material(0, fmat)
	add_child(floor_mi)
