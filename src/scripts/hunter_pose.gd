extends RefCounted
## Front-view poses for the idol hunter portrait (Story 032). `look["pose"]` selects one:
## idle (default), cheer / victory (both arms up, little hops), sit (relaxed, for the HQ
## couch), fever (stick high, sparkle ring). All coordinates are figure units, origin at the
## feet. Pure data; the portrait draws arms, legs and effects from it.

const IDS: Array[String] = ["idle", "cheer", "victory", "sit", "fever"]


## Pose dictionary for `pose` at `t` seconds (`live` false = still frame). Keys: dy (body drop,
## + down), legs ("stand" | "sit"), l_sh, l_hand, r_sh, r_hand, tip (stick end), expr (default
## expression), aura (0..1.6), ring (bool, fever sparkle ring), tilt (head x shift), hair (extra
## hair sway), bend_l / bend_r (elbow bend).
static func get_pose(pose: String, t: float, live: bool) -> Dictionary:
	var p := {"dy": 0.0, "legs": "stand", "l_sh": Vector2(-26, -48), "l_hand": Vector2(-33, -30), "r_sh": Vector2(26, -48),
		"r_hand": Vector2(34, -36), "tip": Vector2(42, -74), "expr": "neutral", "aura": 1.0, "ring": false, "tilt": 0.0,
		"hair": 0.0, "bend_l": 0.08, "bend_r": 0.08}
	match pose:
		"cheer", "victory":
			var hop: float = absf(sin(t * 4.2)) if live else 0.0
			var wave: float = sin(t * 6.0) * 3.0 if live else 0.0
			p["dy"] = -hop * 5.0
			p["l_hand"] = Vector2(-42, -70 + wave)
			p["r_hand"] = Vector2(41, -72 - wave)
			p["tip"] = Vector2(52, -108 - wave)
			p["expr"] = "cheer"
			p["aura"] = 1.25
			p["hair"] = hop * 3.0
			p["bend_l"] = -0.14
			p["bend_r"] = -0.14
		"sit":
			p["dy"] = 6.0
			p["legs"] = "sit"
			p["l_hand"] = Vector2(-20, -23)
			p["r_hand"] = Vector2(19, -24)
			p["tip"] = Vector2(-30, -16)
			p["expr"] = "happy"
			p["aura"] = 0.7
			p["tilt"] = 2.0
			p["bend_l"] = 0.2
			p["bend_r"] = 0.2
		"fever":
			var s: float = sin(t * 5.0) if live else 0.0
			p["l_hand"] = Vector2(-38, -64 + s * 3.0)
			p["r_hand"] = Vector2(38, -78)
			p["tip"] = Vector2(46, -112)
			p["expr"] = "cheer"
			p["aura"] = 1.6
			p["ring"] = true
			p["hair"] = s * 2.5
			p["bend_l"] = -0.1
			p["bend_r"] = -0.1
	return p
