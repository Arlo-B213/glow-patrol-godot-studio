class_name BitRigData
extends RefCounted
## Rig and animation data for Bit, built from the approved art cut into parts.
## Pivots are in source-canvas pixels (1024 x 1024). Bones are listed parent first.
## Track keys are evenly spaced over one animation. Looping animations wrap; one-shot
## animations hold their last key. "rot" is degrees; "dx" and "dy" are canvas pixels.


## Bone tree: name, parent (empty for top level), pivot in canvas pixels, part image and z order.
static func rig() -> Dictionary:
	return {
		"id": "bit",
		"canvas": 1024,
		"bones": [
			{"name": "body", "parent": "", "pivot": [540, 680], "part": "body", "z": 0},
			{"name": "head", "parent": "body", "pivot": [520, 470], "part": "head", "z": 1},
			{"name": "arm_back", "parent": "body", "pivot": [380, 600], "part": "arm_back", "z": 1},
			{"name": "arm_front", "parent": "body", "pivot": [640, 660], "part": "arm_front", "z": 2},
			{"name": "stick", "parent": "arm_front", "pivot": [600, 760], "part": "stick", "z": -1},
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
				"arm_back": {"rot": [0, 2, 0, -2]},
			},
		},
		"walk": {
			"duration": 0.6,
			"loop": true,
			"tracks": {
				"body": {"dy": [0, -4, 0]},
				"arm_back": {"rot": [-6, 6, -6]},
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
