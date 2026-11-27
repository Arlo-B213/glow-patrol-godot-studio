class_name PearlRigData
extends RefCounted
## Rig and animation data for Pearl, built from the approved art cut into parts.
## Pivots are in source-canvas pixels (1024 x 1024). Bones are listed parent first.
## Track keys are evenly spaced over one animation. Looping animations wrap; one-shot
## animations hold their last key. "rot" is degrees; "dx" and "dy" are canvas pixels.


## Bone tree: name, parent (empty for top level), pivot in canvas pixels, part image and z order.
static func rig() -> Dictionary:
	return {
		"id": "pearl",
		"canvas": 1024,
		"bones": [
			{"name": "body", "parent": "", "pivot": [520, 680], "part": "body", "z": 0},
			{"name": "head", "parent": "body", "pivot": [500, 410], "part": "head", "z": 1},
			{"name": "hair_back", "parent": "head", "pivot": [500, 410], "part": "hair_back", "z": -2},
			{"name": "arm_front", "parent": "body", "pivot": [600, 540], "part": "arm_front", "z": 2},
			{"name": "stick", "parent": "arm_front", "pivot": [380, 760], "part": "stick", "z": -1},
		],
	}


## Animation table: name -> {duration, loop, tracks}. Tracks map bone name -> channel -> keys.
static func animations() -> Dictionary:
	return {
		"idle": {
			"duration": 3.0,
			"loop": true,
			"tracks": {
				"body": {"dy": [0, -4, 0]},
				"head": {"rot": [0, 1.5, 0, -1.5]},
				"arm_front": {"rot": [0, 1.5, 0, -1.5]},
			},
		},
		"walk": {
			"duration": 0.6,
			"loop": true,
			"tracks": {
				"body": {"dy": [0, -4, 0]},
				"arm_front": {"rot": [4, -4, 4]},
			},
		},
		"cheer": {
			"duration": 1.0,
			"loop": true,
			"tracks": {
				"body": {"dy": [0, -10, 0]},
				"head": {"rot": [-4, 4, -4]},
				"arm_front": {"rot": [-40, -55, -40]},
			},
		},
		"hurt": {
			"duration": 0.6,
			"loop": false,
			"tracks": {
				"body": {"dx": [0, -10, 5, 0]},
				"head": {"rot": [0, -12, 6, 0]},
			},
		},
		"attack": {
			"duration": 0.5,
			"loop": false,
			"tracks": {
				"arm_front": {"rot": [0, 30, -4, 0]},
			},
		},
	}
