class_name StoryArc
extends RefCounted
## The Dimming Streets (act 1) and Moth Garden (act 2) of the saga (author-approved, see
## design/narrative/chapters/). Chapters unlock one at a time, in order, when the next chapter's
## trigger is met and the chapter before it is finished (GameState.check_story). Trigger kinds:
##   {"type": "lounge_visit"}                 the player has opened the Lounge once
##   {"type": "brawl_wins", "n": int}         n cleared patrols in total
##   {"type": "affection", "boy": id, "n": int}   friendship with a Lanternboy reaches n
##   {"type": "chapter_done", "id": id}       another chapter is finished (quiz passed)

const TITLE := "The Dimming Streets"
const REWARD_PER_CHAPTER := 10

const CHAPTERS := [
	{"id": "ch1_missing_lantern", "title": "The Missing Lantern", "boy": "hae",
		"trigger": {"type": "lounge_visit"}, "quiz_grade": 1,
		"lines": [
			"Look at this, patrol. A lantern-shaped gap on the shelf. Mine used to hang right here.",
			"The Gloomlings didn't break anything. They just borrowed the glow. Very rudely.",
			"I'm not angry. Okay, a little. Mostly I worry the lantern is sad in the dark.",
			"Come with me. We'll follow the little glittery crumbs down Pudding Lane.",
		]},
	{"id": "ch2_dancing_clue", "title": "The Dancing Clue", "boy": "bit",
		"trigger": {"type": "brawl_wins", "n": 1}, "quiz_grade": 2,
		"lines": [
			"Shh, listen. The Gloomlings hum when they carry a lantern. It goes la-la-LOOO.",
			"I matched the tune with my feet and they followed me straight to the old bridge!",
			"They're not so scary when they dance. Mostly they trip.",
			"Clue found: three little lantern hooks hidden under the bridge. Encore?",
		]},
	{"id": "ch3_rooftop_promise", "title": "The Rooftop Promise", "boy": "hae",
		"trigger": {"type": "affection", "boy": "hae", "n": 20}, "quiz_grade": 3,
		"lines": [
			"Up here you can see the whole street. Every dark lamp is a promise we haven't kept yet.",
			"When I was small, a lamplighter lit my street. I wanted to be one forever.",
			"Now I think a lamplighter is anyone who shares their light. That's you too.",
			"Tomorrow we find the Grumble King. Tonight, let's watch the stars come out.",
		]},
	{"id": "ch4_moths_said", "title": "What the Moths Said", "boy": "nun",
		"trigger": {"type": "affection", "boy": "nun", "n": 20}, "quiz_grade": 3,
		"lines": [
			"The moths told me a secret. The lanterns aren't lost. They're in a cold tower.",
			"A gloomy, grumbly tower with one tiny window that faces the moon.",
			"Moths don't lie, but they do get distracted by lamps. I had to ask three times.",
			"Thank you for listening. Not many people wait for the whole story.",
		]},
	{"id": "ch5_stage_light", "title": "Stage Light", "boy": "bit",
		"trigger": {"type": "affection", "boy": "bit", "n": 20}, "quiz_grade": 4,
		"lines": [
			"I get nervous before big encores, you know. My knees do a wobble.",
			"Then I remember the lanterns. Every stolen light is waiting for a happy song.",
			"So I'll dance on the rooftop tomorrow. The loudest, happiest step I've got.",
			"You keep the beat, patrol. Together we're a ten out of ten.",
		]},
	{"id": "ch6_bright_feet", "title": "Bright Feet, Bright Light", "boy": "hae",
		"trigger": {"type": "chapter_done", "id": "ch5_stage_light"}, "quiz_grade": 4,
		"lines": [
			"Hey, you're the new patrol! I heard you beat the Gloomlings on the bridge. Let's go!",
			"Moth Garden is where the lanterns used to glow brightest. Now it's all quiet and dark.",
			"Juno keeps a rhythm for everything, patrol. Walking, talking, even breathing. Watch the beat.",
			"The moths lead us to the gate. Stick close, and keep your glowstick high. Ready? One, two, go!",
		]},
	{"id": "ch7_moths_in_dark", "title": "Moths in the Dark", "boy": "nun",
		"trigger": {"type": "brawl_wins", "n": 8}, "quiz_grade": 4,
		"lines": [
			"The moths are scared. Something cold is crawling through the flowers, pushing the light away.",
			"Then we dance it out! Gloomlings hate a beat they can't follow. Watch me, then copy me.",
			"Careful. The cold does not like noise. It likes quiet. That is why it hides in the Quiet Park.",
			"Quiet is overrated. Let's go find the quiet, then give it a song to listen to.",
		]},
	{"id": "ch8_quiet_park", "title": "The Quiet Park", "boy": "nun",
		"trigger": {"type": "affection", "boy": "nun", "n": 60}, "quiz_grade": 5,
		"lines": [
			"This park used to be full of lantern benches. Each one had a name carved under it, for a lamplighter.",
			"I counted them in the moonlight. Forty-two names. Only one bench is still lit, and it is cold.",
			"Forty-two lamplighters, and nobody left to light the benches? That's the saddest song I've heard.",
			"The Grumble King was one of them, the first. Maybe he forgot the name he was given.",
		]},
	{"id": "ch9_dancing_hill", "title": "Dancing Up the Hill", "boy": "bit",
		"trigger": {"type": "affection", "boy": "bit", "n": 60}, "quiz_grade": 5,
		"lines": [
			"I hummed the whole way up the hill, and the Gloomlings followed us like a parade. Ha!",
			"That's the trick! Make the dark dance, and it forgets how to be scary.",
			"My knees are wobbling again. But the tower is up there, and I want to be brave for the lanterns.",
			"Then we dance the last steps together. One beat at a time, all the way to the gate.",
		]},
	{"id": "ch10_tower_gate", "title": "The Tower Gate", "boy": "hae",
		"trigger": {"type": "chapter_done", "id": "ch9_dancing_hill"}, "quiz_grade": 5,
		"lines": [
			"The gate is open. Wait... it's not locked. It's waiting for us, like it knows we're coming.",
			"Gates don't wait. Someone inside is calling for help, and the cold is too quiet to hide that.",
			"Who keeps climbing my stairs? Go home, little lights. It is cold up here, and I am tired.",
			"He sounds tired, not cruel. Let's bring the light up the stairs, and show him what warm feels like.",
		]},
	# PLACEHOLDER (not author-approved): act 3 opener. Pearl unlocks when this chapter is done.
	{"id": "ch11_grumble_stairs", "title": "The Grumble Stairs", "boy": "hae",
		"trigger": {"type": "chapter_done", "id": "ch10_tower_gate"}, "quiz_grade": 5,
		"lines": [
			"PLACEHOLDER: Act 3 opens on the Grumble Tower stairs. Pearl's arrival is still to be written.",
			"PLACEHOLDER: The patrol climbs higher, and the cold gets quieter with every step.",
		]},
]

## Shown once the finale has been won (the finale is offered after the last chapter).
const FINALE_TEXT := "The Grumble King can't hold the glow, it only makes him sneeze. He hands the lanterns back, and they float home. Every lamp on the street flickers on, and he gets his very own tiny lantern to keep warm. Lantern Hero, you did it!"


## A chapter's lines as one paragraph (for the story card).
static func text_of(ch: Dictionary) -> String:
	return " ".join(PackedStringArray(ch["lines"]))


## True when `gs` (GameState) has met the chapter's trigger.
static func trigger_met(ch: Dictionary, gs: Object) -> bool:
	var t: Dictionary = ch["trigger"]
	match String(t["type"]):
		"lounge_visit":
			return bool(gs.lounge_visited)
		"brawl_wins":
			return int(gs.story_wins) >= int(t["n"])
		"affection":
			return int(gs.affection.get(String(t["boy"]), 0)) >= int(t["n"])
		"chapter_done":
			return gs.chapter_done(String(t["id"]))
	return false


## What the player must do to unlock a locked chapter (shown on its card).
static func trigger_hint(ch: Dictionary) -> String:
	var t: Dictionary = ch["trigger"]
	match String(t["type"]):
		"lounge_visit":
			return "Visit the Lounge to meet the Lanternboys."
		"brawl_wins":
			return "Clear %d patrol(s) to unlock." % int(t["n"])
		"affection":
			return "Reach friendship %d with %s." % [int(t["n"]), String(t["boy"]).capitalize()]
		"chapter_done":
			return "Finish the chapter before this one first."
	return "Keep playing to unlock."
