class_name CharacterRig
extends Node2D
## Plays a rigged character. Each part is a Sprite2D on a bone tree, and each animation is
## a set of keyed tracks (rotation, and position offsets) applied to the bones every frame.
## Rig and animation data are plain dictionaries, see HaeRigData for the format.

signal animation_finished(anim_name: String)

const PART_ROOT := "res://assets/art/characters"

var _bones: Dictionary = {}   # bone name -> Node2D
var _pivots: Dictionary = {}  # bone name -> Vector2 pivot (canvas pixels)
var _rest: Dictionary = {}    # bone name -> Vector2 rest local position
var _anims: Dictionary = {}
var _current: String = ""
var _time: float = 0.0
var _done: bool = false


## Returns the list of problems in rig data, empty when it is valid.
static func validate(rig: Dictionary, anims: Dictionary) -> PackedStringArray:
	var problems := PackedStringArray()
	var names := {}
	for bone: Dictionary in rig["bones"]:
		var n: String = bone["name"]
		if names.has(n):
			problems.append("duplicate bone %s" % n)
		var parent: String = bone["parent"]
		if parent != "" and not names.has(parent):
			problems.append("bone %s listed before its parent %s" % [n, parent])
		names[n] = true
	for anim_name: String in anims:
		var anim: Dictionary = anims[anim_name]
		if float(anim["duration"]) <= 0.0:
			problems.append("%s has no duration" % anim_name)
		for bone_name: String in anim["tracks"]:
			if not names.has(bone_name):
				problems.append("%s animates unknown bone %s" % [anim_name, bone_name])
			var channels: Dictionary = anim["tracks"][bone_name]
			for channel: String in channels:
				if not ["rot", "dx", "dy"].has(channel):
					problems.append("%s/%s has unknown channel %s" % [anim_name, bone_name, channel])
				if (channels[channel] as Array).is_empty():
					problems.append("%s/%s/%s has no keys" % [anim_name, bone_name, channel])
	return problems


## Builds the bone tree from rig data and loads each part from the character's folder.
func setup(rig: Dictionary, anims: Dictionary) -> void:
	_anims = anims
	var char_id: String = rig["id"]
	for bone: Dictionary in rig["bones"]:
		var name: String = bone["name"]
		var pivot := _vec(bone["pivot"])
		var parent_name: String = bone["parent"]
		var parent_node: Node2D = self
		var parent_pivot := Vector2.ZERO
		if parent_name != "":
			parent_node = _bones[parent_name]
			parent_pivot = _pivots[parent_name]
		var node := Node2D.new()
		node.name = name
		node.z_index = int(bone.get("z", 0))
		parent_node.add_child(node)
		node.position = pivot - parent_pivot
		_bones[name] = node
		_pivots[name] = pivot
		_rest[name] = node.position
		if bone.has("part"):
			var sprite := Sprite2D.new()
			sprite.texture = load("%s/%s/parts/%s.png" % [PART_ROOT, char_id, bone["part"]]) as Texture2D
			sprite.centered = false
			# Canvas origin sits at the bone's pivot, so rotation happens at the joint.
			sprite.position = -pivot
			node.add_child(sprite)


## Starts an animation from its first frame. Unknown names are ignored.
func play(anim_name: String) -> void:
	if not _anims.has(anim_name):
		return
	_current = anim_name
	_time = 0.0
	_done = false
	_apply_pose()


## Name of the animation playing now, or an empty string.
func current() -> String:
	return _current


## Bone names in the rig, for tests and debugging.
func bone_names() -> PackedStringArray:
	return PackedStringArray(_bones.keys())


func _process(delta: float) -> void:
	if _current == "" or _done:
		return
	_time += delta
	var anim: Dictionary = _anims[_current]
	var duration: float = anim["duration"]
	if not bool(anim["loop"]) and _time >= duration:
		_done = true
		_time = duration
		_apply_pose()
		animation_finished.emit(_current)
		return
	_apply_pose()


func _apply_pose() -> void:
	var anim: Dictionary = _anims[_current]
	var duration: float = anim["duration"]
	var loop: bool = anim["loop"]
	var u := fmod(_time, duration) / duration if loop else minf(_time / duration, 1.0)
	for name: String in _bones:
		_bones[name].rotation_degrees = 0.0
		_bones[name].position = _rest[name]
	var tracks: Dictionary = anim["tracks"]
	for bone_name: String in tracks:
		var bone: Node2D = _bones[bone_name]
		var channels: Dictionary = tracks[bone_name]
		if channels.has("rot"):
			bone.rotation_degrees = _sample(channels["rot"], u, loop)
		var offset := Vector2(
			_sample(channels["dx"], u, loop) if channels.has("dx") else 0.0,
			_sample(channels["dy"], u, loop) if channels.has("dy") else 0.0)
		bone.position = _rest[bone_name] + offset


## Value at normalised time u (0..1) for evenly spaced keys, smoothstep between keys.
static func _sample(vals: Array, u: float, loop: bool) -> float:
	var n := vals.size()
	if n == 1:
		return float(vals[0])
	var segs := n if loop else n - 1
	var f := clampf(u, 0.0, 1.0) * segs
	var i := mini(int(floor(f)), segs - 1)
	var frac := f - float(i)
	frac = frac * frac * (3.0 - 2.0 * frac)
	return lerpf(float(vals[i % n]), float(vals[(i + 1) % n]), frac)


static func _vec(p: Array) -> Vector2:
	return Vector2(float(p[0]), float(p[1]))
