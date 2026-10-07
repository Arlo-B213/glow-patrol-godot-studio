class_name ArcScenes
extends RefCounted
## Lanternboy arc scenes (Story 020). PROVISIONAL original text written while the author was
## away - replace freely. Each scene unlocks when the boy's affection reaches `affection`.
## Viewed ids are saved in GameState.seen_scenes; the first view pays FIRST_VIEW_STARS once.

const FIRST_VIEW_STARS := 15

const SCENES := [
	{"id": "hae_1", "boy": "hae", "affection": 20, "title": "The Missing Lantern", "lines": [
		"Look at this, patrol. A lantern-shaped gap on the shelf. Mine used to hang right here.",
		"The Gloomlings didn't break anything. They just borrowed the glow. Very rudely.",
		"I'm not angry. Okay, a little. Mostly I worry the lantern is sad in the dark.",
		"Come with me. We'll follow the little glittery crumbs down Pudding Lane.",
	]},
	{"id": "hae_2", "boy": "hae", "affection": 60, "title": "The Rooftop Promise", "lines": [
		"Up here you can see the whole street. Every dark lamp is a promise we haven't kept yet.",
		"When I was small, a lamplighter lit my street. I wanted to be one forever.",
		"Now I think a lamplighter is anyone who shares their light. That's you too.",
		"Tomorrow we find the Grumble King. Tonight, let's watch the stars come out.",
	]},
	{"id": "bit_1", "boy": "bit", "affection": 20, "title": "The Dancing Clue", "lines": [
		"Shh, listen. The Gloomlings hum when they carry a lantern. It goes la-la-LOOO.",
		"I matched the tune with my feet and they followed me straight to the old bridge!",
		"They're not so scary when they dance. Mostly they trip.",
		"Clue found: three little lantern hooks hidden under the bridge. Encore?",
	]},
	{"id": "bit_2", "boy": "bit", "affection": 60, "title": "Stage Light", "lines": [
		"I get nervous before big encores, you know. My knees do a wobble.",
		"Then I remember the lanterns. Every stolen light is waiting for a happy song.",
		"So I'll dance on the rooftop tomorrow. The loudest, happiest step I've got.",
		"You keep the beat, patrol. Together we're a ten out of ten.",
	]},
	{"id": "nun_1", "boy": "nun", "affection": 20, "title": "What the Moths Said", "lines": [
		"The moths told me a secret. The lanterns aren't lost. They're in a cold tower.",
		"A gloomy, grumbly tower with one tiny window that faces the moon.",
		"Moths don't lie, but they do get distracted by lamps. I had to ask three times.",
		"Thank you for listening. Not many people wait for the whole story.",
	]},
	{"id": "nun_2", "boy": "nun", "affection": 60, "title": "The Quiet Lantern", "lines": [
		"I know the Grumble King's secret now. He isn't mean. He's cold, and a little lonely.",
		"That's why he took the lanterns. He wanted to feel warm.",
		"We can still stop him, and we can be gentle about it.",
		"Light is for sharing. I think he'll learn, with a little help from you.",
	]},
]


## Scenes of `boy_id` in threshold order.
static func scenes_for(boy_id: String) -> Array:
	var out: Array = []
	for s in SCENES:
		if s["boy"] == boy_id:
			out.append(s)
	return out


## Scene definition for `id` (empty when unknown).
static func by_id(id: String) -> Dictionary:
	for s in SCENES:
		if s["id"] == id:
			return s
	return {}


## True when `boy_id`'s affection in `gs` has reached the scene's threshold.
static func is_unlocked(gs: Object, scene: Dictionary) -> bool:
	return int(gs.affection.get(String(scene["boy"]), 0)) >= int(scene["affection"])


## Unlocked scenes of the boy (viewed or not).
static func unlocked_for(gs: Object, boy_id: String) -> Array:
	var out: Array = []
	for s in scenes_for(boy_id):
		if is_unlocked(gs, s):
			out.append(s)
	return out


## First unlocked scene the player has not viewed yet, or an empty Dictionary.
static func new_scene(gs: Object, boy_id: String) -> Dictionary:
	for s in unlocked_for(gs, boy_id):
		if not gs.seen_scenes.has(s["id"]):
			return s
	return {}


## Marks the scene viewed. On the first view pays FIRST_VIEW_STARS and returns true;
## replays return false and pay nothing.
static func mark_seen(gs: Object, scene: Dictionary) -> bool:
	var id: String = String(scene["id"])
	if gs.seen_scenes.has(id):
		return false
	gs.seen_scenes.append(id)
	gs.earn_points(FIRST_VIEW_STARS)
	return true
