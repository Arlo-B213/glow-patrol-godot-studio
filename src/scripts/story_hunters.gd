class_name StoryHunters
extends RefCounted
## Playable hunters (saga v2). "glow" is the player's own hunter and is always available. A fellow
## hunter unlocks when its chapter is finished (quiz passed). The three Lanternboys each have one
## brawl move (MOVE button, see brawl_moves.gd). Juno joins after chapter 5 (name provisional).
## Looks use HunterArt keys.

const ORDER := ["glow", "hae", "bit", "nun", "juno", "pearl"]

const HUNTERS := {
	"glow": {"name": "You", "unlock_chapter": "", "move": {}},
	"hae": {"name": "Hae", "unlock_chapter": "ch3_rooftop_promise",
		"move": {"id": "lantern_swing", "caption": "SWING"}, "look": {
			"outfit": Color("#FFD36E"), "outfit_style": "tailcoat", "hair": Color("#2A1F55"),
			"glow": Color("#FFC15E"), "weapon": "scepter", "hairstyle": "ponytail",
			"headwear": "none", "face_acc": "none",
		}},
	"bit": {"name": "Bit", "unlock_chapter": "ch2_dancing_clue",
		"move": {"id": "encore_spin", "caption": "SPIN"}, "look": {
			"outfit": Color("#FF8B5E"), "outfit_style": "sequin", "hair": Color("#8A4B2A"),
			"glow": Color("#52E8C6"), "weapon": "rod", "hairstyle": "bob",
			"headwear": "none", "face_acc": "blush",
		}},
	"nun": {"name": "Nun", "unlock_chapter": "ch4_moths_said",
		"move": {"id": "moth_ward", "caption": "WARD"}, "look": {
			"outfit": Color("#52E8C6"), "outfit_style": "hanbok", "hair": Color("#C9D3F0"),
			"glow": Color("#8E7CFF"), "weapon": "rod", "hairstyle": "ponytail",
			"headwear": "star-clip", "face_acc": "glasses",
		}},
	"juno": {"name": "Juno", "unlock_chapter": "ch5_stage_light", "move": {}, "look": {
		"outfit": Color("#52E8C6"), "outfit_style": "sequin", "hair": Color("#FFC15E"),
		"glow": Color("#FF5FA2"), "weapon": "comet", "hairstyle": "twintails",
		"headwear": "bow", "face_acc": "blush",
	}},
	"pearl": {"name": "Pearl", "unlock_chapter": "ch11_grumble_stairs", "move": {}, "look": {
		"outfit": Color("#8E7CFF"), "outfit_style": "armor", "hair": Color("#101033"),
		"glow": Color("#52E8C6"), "weapon": "stick", "hairstyle": "long",
		"headwear": "star-clip", "face_acc": "none",
	}},
}


## Display name of `id` ("" when unknown).
static func name_of(id: String) -> String:
	return String(HUNTERS.get(id, {}).get("name", ""))


## True when `id` can be played in `gs` (GameState).
static func unlocked(gs: Object, id: String) -> bool:
	if id == "glow":
		return true
	if not HUNTERS.has(id):
		return false
	return gs.chapter_done(String(HUNTERS[id]["unlock_chapter"]))


## Look dictionary for a fellow hunter (empty for "glow", which uses the player's own look).
static func look(id: String) -> Dictionary:
	return (HUNTERS.get(id, {}).get("look", {}) as Dictionary).duplicate()


## The hunter's brawl move ({"id", "caption"}), or an empty Dictionary when it has none.
static func move_of(id: String) -> Dictionary:
	return (HUNTERS.get(id, {}).get("move", {}) as Dictionary).duplicate()


## What the player must do to unlock `id` (shown on its locked card).
static func hint(id: String) -> String:
	if id == "glow" or not HUNTERS.has(id):
		return ""
	var chapter_id := String(HUNTERS[id]["unlock_chapter"])
	for i in StoryArc.CHAPTERS.size():
		var ch: Dictionary = StoryArc.CHAPTERS[i]
		if String(ch["id"]) == chapter_id:
			return "Finish chapter %d \"%s\" to meet %s." % [i + 1, ch["title"], name_of(id)]
	return "Keep playing to meet %s." % name_of(id)
