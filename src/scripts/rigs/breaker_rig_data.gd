class_name BreakerRigData
extends RefCounted
## Rig and animation data for the Gloom Breaker hunter, built from the upgraded render cut into
## parts (design/art/pipeline/gloom-breaker-parts). Pivots are in source-canvas pixels (1024 x 1024).
## Bones are listed parent first. Track keys are evenly spaced over one animation. Looping
## animations wrap; one-shot animations hold their last key. "rot" is degrees; "dx" and "dy" are
## canvas pixels.


## Bone tree: name, parent (empty for top level), pivot in canvas pixels, part image and z order.
static func rig() -> Dictionary:
	return {
		"id": "breaker",
		"canvas": 1024,
		"bones": [
			{"name": "body", "parent": "", "pivot": [512, 560], "part": "body", "z": 0},
			{"name": "cape", "parent": "body", "pivot": [512, 280], "part": "cape", "z": -3},
			{"name": "leg_a", "parent": "body", "pivot": [430, 620], "part": "leg_a", "z": -1},
			{"name": "boot_a", "parent": "leg_a", "pivot": [415, 760], "part": "boot_a", "z": 0},
			{"name": "leg_b", "parent": "body", "pivot": [600, 620], "part": "leg_b", "z": -1},
			{"name": "boot_b", "parent": "leg_b", "pivot": [610, 760], "part": "boot_b", "z": 0},
			{"name": "head", "parent": "body", "pivot": [512, 245], "part": "head", "z": 1},
			{"name": "hair_back", "parent": "head", "pivot": [512, 245], "part": "hair_back", "z": -2},
			{"name": "arm_a", "parent": "body", "pivot": [395, 285], "part": "arm_a", "z": 2},
			{"name": "stick_a", "parent": "arm_a", "pivot": [300, 420], "part": "stick_a", "z": 3},
			{"name": "arm_b", "parent": "body", "pivot": [630, 285], "part": "arm_b", "z": 2},
			{"name": "stick_b", "parent": "arm_b", "pivot": [724, 440], "part": "stick_b", "z": 3},
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
				"cape": {"rot": [0, 1.5, 0, -1.5]},
			},
		},
		"walk": {
			"duration": 0.6,
			"loop": true,
			"tracks": {
				"body": {"dy": [0, -4, 0]},
				"leg_a": {"rot": [-6, 6, -6]},
				"leg_b": {"rot": [6, -6, 6]},
				"arm_a": {"rot": [4, -4, 4]},
				"arm_b": {"rot": [-4, 4, -4]},
			},
		},
		"cheer": {
			"duration": 1.0,
			"loop": true,
			"tracks": {
				"body": {"dy": [0, -10, 0]},
				"head": {"rot": [-4, 4, -4]},
				"arm_b": {"rot": [-40, -55, -40]},
				"stick_b": {"rot": [0, 10, 0]},
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
				"arm_b": {"rot": [0, 30, -4, 0]},
			},
		},
	}
