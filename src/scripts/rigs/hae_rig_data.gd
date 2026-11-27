class_name HaeRigData
extends RefCounted
## Rig and animation data for Hae, built from the approved art cut into parts.
## Pivots are in source-canvas pixels (1024 x 1024). Bones are listed parent first.
## Track keys are evenly spaced over one animation. Looping animations wrap; one-shot
## animations hold their last key. "rot" is degrees; "dx" and "dy" are canvas pixels.


## Bone tree: name, parent (empty for top level), pivot in canvas pixels, part image and z order.
static func rig() -> Dictionary:
	return {
		"id": "hae",
		"canvas": 1024,
		"bones": [
			{"name": "body", "parent": "", "pivot": [512, 512], "part": "torso", "z": 0},
			{"name": "arm_back_right", "parent": "body", "pivot": [650, 540], "part": "arm_back_right", "z": -1},
			{"name": "arm_front_left", "parent": "body", "pivot": [345, 560], "part": "arm_front_left", "z": 2},
			{"name": "scepter", "parent": "arm_front_left", "pivot": [300, 690], "part": "scepter", "z": -1},
			{"name": "head", "parent": "body", "pivot": [520, 430], "part": "head", "z": 1},
			{"name": "hair_back", "parent": "head", "pivot": [520, 430], "part": "hair_back", "z": -2},
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
				"arm_back_right": {"rot": [0, -2, 0, 2]},
				"arm_front_left": {"rot": [0, 1.5, 0, -1.5]},
			},
		},
		"walk": {
			"duration": 0.8,
			"loop": true,
			"tracks": {
				"body": {"dy": [0, -3, 0]},
				"arm_back_right": {"rot": [-10, 10, -10]},
				"arm_front_left": {"rot": [10, -10, 10]},
			},
		},
		"cheer": {
			"duration": 1.2,
			"loop": true,
			"tracks": {
				"body": {"dy": [0, -10, 0]},
				"head": {"rot": [-3, 3, -3]},
				"arm_back_right": {"rot": [-50, -60, -50]},
				"arm_front_left": {"rot": [-35, -45, -35]},
			},
		},
		"hurt": {
			"duration": 0.6,
			"loop": false,
			"tracks": {
				"body": {"dx": [0, -10, 5, 0]},
				"head": {"rot": [0, -12, 6, 0]},
				"arm_back_right": {"rot": [0, 8, 0]},
			},
		},
		"attack": {
			"duration": 0.6,
			"loop": false,
			"tracks": {
				"body": {"dx": [0, 6, 0]},
				"arm_front_left": {"rot": [0, 30, -5, 0]},
			},
		},
	}
