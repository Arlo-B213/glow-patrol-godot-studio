class_name RigLibrary
extends RefCounted
## Which characters have an animated rig, and a portrait builder that plays their idle.
## Add a character by giving it rig and animation data and a branch in _data().


static func has_rig(id: String) -> bool:
	return not _data(id).is_empty()


## Rig and animation data for a character id, or an empty array when it has none.
static func _data(id: String) -> Array:
	if id == "hae":
		return [HaeRigData.rig(), HaeRigData.animations()]
	if id == "nun":
		return [NunRigData.rig(), NunRigData.animations()]
	if id == "bit":
		return [BitRigData.rig(), BitRigData.animations()]
	if id == "juno":
		return [JunoRigData.rig(), JunoRigData.animations()]
	if id == "pearl":
		return [PearlRigData.rig(), PearlRigData.animations()]
	if id == "breaker":
		return [BreakerRigData.rig(), BreakerRigData.animations()]
	return []


## A clipped square holding the character's rig, scaled to fit px, playing idle.
static func portrait(id: String, px: Vector2) -> Control:
	var holder := Control.new()
	holder.custom_minimum_size = px
	holder.clip_contents = true
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var data := _data(id)
	if data.is_empty():
		return holder
	var rig := CharacterRig.new()
	rig.setup(data[0], data[1])
	var canvas: float = float(data[0]["canvas"])
	rig.scale = Vector2.ONE * (minf(px.x, px.y) / canvas)
	holder.add_child(rig)
	rig.play("idle")
	return holder
