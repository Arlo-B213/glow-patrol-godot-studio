class_name StoryArc
extends RefCounted
## PROVISIONAL first story arc (Story 004). Original, kid-friendly text written
## by the build agent while the author was away - replace freely. Data-driven:
## a chapter unlocks when the player has cleared `wins` patrols in total.

const TITLE := "The Dimming Streets"
const REWARD_PER_CHAPTER := 10

const CHAPTERS := [
	{"wins": 1, "title": "Lights Out on Pudding Lane", "boy": "hae",
		"text": "The streetlamps on Pudding Lane went dark overnight, and the noodle cart is sitting in the shadows. Hae holds up the biggest lantern and says, \"Somebody is borrowing the glow. Patrol, you're with me!\" You find a trail of glittery crumbs leading toward the old bridge."},
	{"wins": 2, "title": "The Moth Report", "boy": "nun",
		"text": "Nun hears the moths whispering about a Gloomling nest under the old bridge. \"They only fly toward real light,\" he says. \"So keep your glowstick bright.\" A hundred tiny wings flutter ahead to show the way."},
	{"wins": 4, "title": "Encore at the Bridge", "boy": "bit",
		"text": "Bit dances across the bridge to lure the Gloomlings out. It works, and it's a little bit embarrassing for everyone. The nest is found, and three lantern hooks are hanging inside. They're empty!"},
	{"wins": 6, "title": "The Quiet Before", "boy": "hae",
		"text": "The nest was empty, but there are tracks leading up to the rooftops. Hae counts the lanterns: \"Three are missing. The Grumble King took them.\" Far away, a very grumbly tower hums in the dark. Tomorrow, you climb it."},
	{"wins": 9, "title": "Grumble King's Last Grumble", "boy": "nun",
		"text": "At the top of the tower sits the Grumble King, hugging the stolen lanterns and grumbling into his big cold beard. \"He just wants to feel warm,\" Nun whispers. The street is waiting. Are you ready for the final patrol?"},
]

## Shown once the finale has been won.
const FINALE_TEXT := "The Grumble King can't hold the glow, it only makes him sneeze. He hands the lanterns back, and they float home. Every lamp on the street flickers on, and he gets his very own tiny lantern to keep warm. Lantern Hero, you did it!"


## Number of chapters unlocked after `wins` cleared patrols.
static func unlocked_count(wins: int) -> int:
	var n := 0
	for ch in CHAPTERS:
		if wins >= int(ch["wins"]):
			n += 1
	return n


## Wins still needed for the next locked chapter (0 when finished).
static func wins_to_next(wins: int) -> int:
	for ch in CHAPTERS:
		if wins < int(ch["wins"]):
			return int(ch["wins"]) - wins
	return 0
