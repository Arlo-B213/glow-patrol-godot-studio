extends Node
## Global game state — persistent player data, unlocks, and shared game data
## tables (outfits, weapons, hairstyles, accessories, Lanternboys).
## Mirrors the web version's `state` object + data arrays.

const SAVE_PATH := "user://glowstick_patrol_save.json"
const XP_PER_LEVEL := 50

## Star payout for a finished battle/game run (see design/balance.md).
const PAYOUT_MIN := 10
const PAYOUT_MAX := 40


## Stars earned for a run score: the score itself, clamped to [PAYOUT_MIN, PAYOUT_MAX].
static func payout_for(score: int) -> int:
	return clampi(score, PAYOUT_MIN, PAYOUT_MAX)


# ---------------- Data tables ----------------

const OUTFITS := [
	{"id": "starter", "name": "Practice Fit", "cost": 0, "hair": Color("#3B2A6B"), "outfit": Color("#6C5CE7"), "style": "track"},
	{"id": "stage", "name": "Stage Sparkle", "cost": 40, "hair": Color("#B93B6B"), "outfit": Color("#FF5FA2"), "style": "sequin"},
	{"id": "beat", "name": "Beat Armor", "cost": 60, "hair": Color("#154C40"), "outfit": Color("#52E8C6"), "style": "armor"},
	{"id": "lantern", "name": "Lantern Silk", "cost": 80, "hair": Color("#7A3B12"), "outfit": Color("#FFC15E"), "style": "robe"},
	{"id": "moon", "name": "Moonlit Hanbok", "cost": 100, "hair": Color("#101033"), "outfit": Color("#8E7CFF"), "style": "hanbok"},
	{"id": "encore", "name": "Encore Gold", "cost": 150, "hair": Color("#3B2A6B"), "outfit": Color("#FFD36E"), "style": "tailcoat"},
	{"id": "honor", "name": "Honor Roll Cape", "cost": 180, "hair": Color("#B93B6B"), "outfit": Color("#52E8C6"), "style": "cape"},
	{"id": "genius", "name": "Genius Galaxy Suit", "cost": 260, "hair": Color("#101033"), "outfit": Color("#FF5FA2"), "style": "galaxy"},
]

const WEAPONS := [
	# `reach` scales the tap radius in Zap Patrol and the punch reach in Alley Brawl (1.0 = baseline).
	# PROVISIONAL values chosen while the author was away; tune freely, then run /balance-check.
	{"id": "glowstick", "name": "Practice Glowstick", "cost": 0, "style": "stick", "glow": Color("#FFC15E"),"reach": 1.0, "blurb": "Starter reach"},
	{"id": "comet", "name": "Comet Baton", "cost": 60, "style": "comet", "glow": Color("#52E8C6"), "reach": 1.1, "blurb": "Reach +10%"},
	{"id": "storm", "name": "Storm Rod", "cost": 90, "style": "rod", "glow": Color("#8E7CFF"), "reach": 1.2, "blurb": "Reach +20%"},
	{"id": "solar", "name": "Solar Scepter", "cost": 140, "style": "scepter", "glow": Color("#FF5FA2"), "reach": 1.3, "blurb": "Reach +30%"},
	{"id": "galaxy", "name": "Galaxy Wand", "cost": 220, "style": "wand", "glow": Color("#FFD36E"), "reach": 1.4, "blurb": "Reach +40%"},
]

const LANTERNBOYS := [
	{
		"id": "hae", "name": "Hae", "color": Color("#FFC15E"), "role": "Leader — carries the biggest lantern",
		"lines": [
			"Patrol went quiet tonight. Quiet is good. Quiet means the noodle cart is safe.",
			"I polished my lantern for an hour. An HOUR. It's very shiny now.",
			"If a Gloomling asks you to dance, say no. They cheat.",
			"You're getting really good at this. The other lanterns talk about you.",
		],
	},
	{
		"id": "bit", "name": "Bit", "color": Color("#FF8B5E"), "role": "Dancer — hums while he walks",
		"lines": [
			"I made up a new step for the encore. Wanna see it? ...okay later then.",
			"Fought a Gloomling earlier. We ended up just dancing instead. Ten out of ten.",
			"Do you ever hum during battle? I do. It confuses them.",
			"Your outfit today is a solid nine. I'm saving the ten for stage day.",
		],
	},
	{
		"id": "nun", "name": "Nun", "color": Color("#FFE08A"), "role": "Quiet one — talks to the moths",
		"lines": [
			"The moths said a storm is coming. I believe them more than the weather app.",
			"...",
			"Thank you for the light. Not everyone shares theirs.",
			"I counted 212 stars tonight. You were the 213th good thing.",
		],
	},
]

const HAIRSTYLES := [
	{"id": "bob", "name": "Classic Bob", "cost": 0},
	{"id": "twintails", "name": "Twin Tails", "cost": 35},
]

const HAIR_COLORS := [
	{"id": "violet", "name": "Midnight Violet", "hex": Color("#3B2A6B"), "cost": 0},
	{"id": "rose", "name": "Rose", "hex": Color("#B93B6B"), "cost": 20},
	{"id": "gold", "name": "Golden Blonde", "hex": Color("#FFC15E"), "cost": 20},
	{"id": "mint", "name": "Mint", "hex": Color("#52E8C6"), "cost": 20},
	{"id": "pink", "name": "Bubblegum Pink", "hex": Color("#FF5FA2"), "cost": 20},
	{"id": "jet", "name": "Jet Black", "hex": Color("#101033"), "cost": 20},
]

const HEADWEAR := [
	{"id": "none", "name": "No Headwear", "cost": 0},
	{"id": "bow", "name": "Ribbon Bow", "cost": 30},
	{"id": "star-clip", "name": "Star Clip", "cost": 25},
	{"id": "flower-crown", "name": "Flower Crown", "cost": 45},
	{"id": "cat-ears", "name": "Cat Ears", "cost": 40},
]

const FACE_ACC := [
	{"id": "none", "name": "No Accessory", "cost": 0},
	{"id": "blush", "name": "Rosy Blush", "cost": 15},
	{"id": "glasses", "name": "Star Glasses", "cost": 30},
	{"id": "freckles", "name": "Freckles", "cost": 15},
]

# ---------------- Pets (Story 024) ----------------
# PROVISIONAL tuning (author away); every number below is data, tune freely.
# `growth` = care points needed to reach baby / child / adult (egg is stage 0).
# `zap_every` = seconds between companion zaps per stage [egg, baby, child, adult] (0 = none);
# `zap_boss` = boss health chipped by a zap per stage (regular Gloomlings fall to any zap).
const PETS := [
	{"id": "xolo", "name": "Xolo", "cost": 30, "color": Color("#FFC2B8"), "accent": Color("#FF6FA8"),
		"blurb": "A giggly axolotl-like xocoatl with feathery glow-gills.",
		"growth": [6.0, 20.0, 45.0], "zap_every": [0.0, 9.0, 8.0, 7.0], "zap_boss": [0, 0, 1, 1]},
	{"id": "puff", "name": "Puff", "cost": 40, "color": Color("#CBB8FF"), "accent": Color("#52E8C6"),
		"blurb": "A fluffy round glow-moth that flutters when it is happy.",
		"growth": [6.0, 20.0, 45.0], "zap_every": [0.0, 9.0, 8.0, 7.0], "zap_boss": [0, 0, 1, 1]},
	{"id": "sparkfox", "name": "Sparkfox", "cost": 50, "color": Color("#FF9A5E"), "accent": Color("#FFD36E"),
		"blurb": "A small fox with a tail that glows like a lantern.",
		"growth": [6.0, 20.0, 45.0], "zap_every": [0.0, 9.0, 8.0, 7.0], "zap_boss": [0, 0, 1, 1]},
	{"id": "moonbun", "name": "Moonbun", "cost": 45, "color": Color("#F2EAFF"), "accent": Color("#9CC8FF"),
		"blurb": "A round moon-rabbit whose long ears glow like little lanterns.",
		"growth": [6.0, 22.0, 48.0], "zap_every": [0.0, 9.0, 8.0, 7.0], "zap_boss": [0, 0, 1, 1]},
	{"id": "inkydrake", "name": "Inkydrake", "cost": 55, "color": Color("#3FD0C0"), "accent": Color("#FF7FC8"),
		"blurb": "A tiny teal dragon with soft wing-fins and ink-spot freckles.",
		"growth": [7.0, 24.0, 52.0], "zap_every": [0.0, 9.0, 8.0, 7.0], "zap_boss": [0, 0, 1, 1]},
]
## Cosmetic pet accessories (Story 033). A pet may wear one it has unlocked: free once the
## pet reaches `stage` (9 = never by growth), or bought early for `cost` stars (per pet).
const PET_ACCESSORIES := [
	{"id": "bow", "name": "Bow", "color": Color("#FF5FA2"), "stage": 1, "cost": 6},
	{"id": "scarf", "name": "Scarf", "color": Color("#FF8A4C"), "stage": 2, "cost": 9},
	{"id": "crown", "name": "Star Crown", "color": Color("#FFD36E"), "stage": 3, "cost": 15},
	{"id": "headphones", "name": "Headphones", "color": Color("#6B5BFF"), "stage": 9, "cost": 12},
	{"id": "sunglasses", "name": "Sunglasses", "color": Color("#2A1260"), "stage": 9, "cost": 18},
]
const PET_STAGE_NAMES := ["Egg", "Baby", "Child", "Adult"]
const PET_FEED_COST := 3
const PET_FEED_GROWTH := 3.0       ## care points per feed
const PET_PET_GROWTH := 0.5        ## care points per petting (only while happiness < 100)
const PET_PET_COOLDOWN := 4.0      ## seconds between petting rewards
const PET_FEED_FILL := 35.0
const PET_FEED_JOY := 6.0
const PET_PET_JOY := 12.0
const PET_FULL_AT := 90.0          ## at/above this fullness a pet politely refuses a snack
const PET_HUNGER_DECAY_PER_HOUR := 3.0
const PET_JOY_DECAY_PER_HOUR := 2.0
const PET_NEED_FLOOR := 10.0       ## needs never drift below this
const PET_OFFLINE_MAX_SECS := 86400.0  ## at most 24 h of away-time is counted
const PET_LOW_NEED := 30.0         ## below this a pet is "sleepy"/"wants a snack": growth is slower
const PET_SLOW_GROWTH_MULT := 0.4

# ---------------- Player state ----------------

var star_points: int = 20
var total_earned: int = 20
var unlocked_outfits: Array = ["starter"]
var equipped_outfit: String = "starter"
var unlocked_weapons: Array = ["glowstick"]
var equipped_weapon: String = "glowstick"
var unlocked_hairstyles: Array = ["bob"]
var hairstyle: String = "bob"
var unlocked_hair_colors: Array = ["violet"]
var hair_color: String = "violet"
var unlocked_headwear: Array = ["none"]
var headwear: String = "none"
var unlocked_face_acc: Array = ["none"]
var face_acc: String = "none"
var affection: Dictionary = {"hae": 0, "bit": 0, "nun": 0}
var best_scores: Dictionary = {"battle": 0, "rhythm": 0, "memory": 0, "brawl": 0, "catch": 0, "lantern": 0, "study_math": 0, "study_grammar": 0, "study_reading": 0}
var grade: int = 3
var story_wins: int = 0
var story_claimed: int = 0
var sound_on: bool = true
## Accessibility: when true, UI animations jump straight to their final state.
var reduce_motion: bool = false
## Pets: id -> {name, growth, hunger (100 = full), happiness, last_ts}. Never removed, never harmed.
var owned_pets: Dictionary = {}
var active_pet: String = ""
## Onboarding / retention (Story 022). Old saves lack these and keep the defaults.
var tutorial_done: bool = false
var streak: int = 0                  ## consecutive days with a claimed Daily Glow Bonus
var last_login_date: String = ""     ## "YYYY-MM-DD" of the last claimed bonus
var stickers: Array = []             ## earned sticker ids (see Stickers.STICKERS)
## Story 020: viewed Lanternboy arc scene ids and whether the finale reward was paid.
var seen_scenes: Array = []
var finale_done: bool = false
## Scratch instances used in checks set this false so nothing touches the real save.
var persist_saves: bool = true
var _pet_cooldown: Dictionary = {}

signal pet_changed(id: String)
signal pet_stage_changed(id: String, stage: int)
signal active_pet_changed(id: String)
signal points_changed(new_total: int)
signal leveled_up(new_level: int)
## Emitted by earn_points with the amount gained (for "+N" feedback).
signal points_earned(amount: int)


## Stores the reduced-motion preference and saves it.
func set_reduce_motion(v: bool) -> void:
	reduce_motion = v
	save_game()


func _ready() -> void:
	load_game()


func level_for_xp(xp: int) -> int:
	return int(floor(float(xp) / float(XP_PER_LEVEL))) + 1


func earn_points(amount: int) -> void:
	var before_level := level_for_xp(total_earned)
	star_points += amount
	total_earned += amount
	var after_level := level_for_xp(total_earned)
	points_changed.emit(star_points)
	points_earned.emit(amount)
	if after_level > before_level:
		leveled_up.emit(after_level)
	save_game()


func spend_points(amount: int) -> bool:
	if star_points < amount:
		return false
	star_points -= amount
	points_changed.emit(star_points)
	save_game()
	return true


func outfit_by_id(id: String) -> Dictionary:
	for o in all_outfits():
		if o["id"] == id:
			return o
	return OUTFITS[0]


## OUTFITS plus the story outfits the player already owns (StoryRewards); what the Closet lists.
func all_outfits() -> Array:
	var list: Array = OUTFITS.duplicate()
	for o in StoryRewards.OUTFITS_BY_CHAPTER.values():
		if unlocked_outfits.has(o["id"]):
			list.append(o)
	return list


func weapon_by_id(id: String) -> Dictionary:
	for w in WEAPONS:
		if w["id"] == id:
			return w
	return WEAPONS[0]


## The hunter's equipped look for HunterArt: outfit/hair/glow colours plus hairstyle,
## headwear and face_acc ids. Built the same way for every screen.
func hunter_look() -> Dictionary:
	return {
		"outfit": outfit_by_id(equipped_outfit)["outfit"],
		"outfit_style": String(outfit_by_id(equipped_outfit).get("style", "track")),
		"hair": style_item_by_id(HAIR_COLORS, hair_color)["hex"],
		"glow": weapon_by_id(equipped_weapon)["glow"],
		"weapon": String(weapon_by_id(equipped_weapon).get("style", "stick")),
		"hairstyle": hairstyle,
		"headwear": headwear,
		"face_acc": face_acc,
	}


## Reach multiplier of the equipped weapon (1.0 = baseline); see WEAPONS.
func weapon_reach() -> float:
	return float(weapon_by_id(equipped_weapon).get("reach", 1.0))


func lanternboy_by_id(id: String) -> Dictionary:
	for b in LANTERNBOYS:
		if b["id"] == id:
			return b
	return LANTERNBOYS[0]


func style_item_by_id(list: Array, id: String) -> Dictionary:
	for item in list:
		if item["id"] == id:
			return item
	return list[0]


## Counts a cleared patrol toward the story arc. Returns the chapters newly
## unlocked (and pays StoryArc.REWARD_PER_CHAPTER stars for each), then saves.
func record_battle_win() -> Array:
	var arc := preload("res://scripts/story_arc.gd")
	story_wins += 1
	var fresh: Array = []
	var count: int = arc.unlocked_count(story_wins)
	while story_claimed < count:
		fresh.append(arc.CHAPTERS[story_claimed])
		story_claimed += 1
		earn_points(arc.REWARD_PER_CHAPTER)
	StoryRewards.sync_outfits(self)
	save_game()
	return fresh


## Species definition for `id` (empty dictionary when unknown).
func pet_def(id: String) -> Dictionary:
	for d in PETS:
		if d["id"] == id:
			return d
	return {}


## Accessory definition for `id` (empty dictionary when unknown).
func accessory_def(id: String) -> Dictionary:
	for d in PET_ACCESSORIES:
		if d["id"] == id:
			return d
	return {}


## True when pet `pet_id` may wear `acc_id`: its stage reached the free stage, or it was bought.
func accessory_unlocked(pet_id: String, acc_id: String) -> bool:
	var def := accessory_def(acc_id)
	if def.is_empty() or not owned_pets.has(pet_id):
		return false
	if pet_stage(pet_id) >= int(def["stage"]):
		return true
	return (owned_pets[pet_id].get("acc_own", []) as Array).has(acc_id)


## Accessory id the pet currently wears ("" = none).
func pet_accessory(pet_id: String) -> String:
	if not owned_pets.has(pet_id):
		return ""
	return str(owned_pets[pet_id].get("acc", ""))


## Buys an accessory for one pet with stars. False when unknown, unlocked already or too few stars.
func buy_accessory(pet_id: String, acc_id: String) -> bool:
	var def := accessory_def(acc_id)
	if def.is_empty() or not owned_pets.has(pet_id) or accessory_unlocked(pet_id, acc_id):
		return false
	if star_points < int(def["cost"]):
		return false
	star_points -= int(def["cost"])
	points_changed.emit(star_points)
	var own: Array = owned_pets[pet_id].get("acc_own", [])
	own.append(acc_id)
	owned_pets[pet_id]["acc_own"] = own
	_persist()
	pet_changed.emit(pet_id)
	return true


## Puts an unlocked accessory on the pet ("" takes it off). False when not allowed.
func equip_accessory(pet_id: String, acc_id: String) -> bool:
	if not owned_pets.has(pet_id) or (acc_id != "" and not accessory_unlocked(pet_id, acc_id)):
		return false
	owned_pets[pet_id]["acc"] = acc_id
	_persist()
	pet_changed.emit(pet_id)
	return true


func has_pet(id: String) -> bool:
	return owned_pets.has(id)


## Stage 0..3 (egg, baby, child, adult) of an owned pet; -1 when not owned.
func pet_stage(id: String) -> int:
	if not owned_pets.has(id):
		return -1
	return stage_for_growth(id, float(owned_pets[id].get("growth", 0.0)))


## Stage reached by `growth` care points for species `id` (0 when unknown).
func stage_for_growth(id: String, growth: float) -> int:
	var stage := 0
	for need in pet_def(id).get("growth", []):
		if growth >= float(need):
			stage += 1
	return stage


## Progress 0..1 through the current stage toward the next; 1.0 when fully grown.
func pet_progress(id: String) -> float:
	var stage := pet_stage(id)
	if stage < 0 or stage >= 3:
		return 1.0 if stage >= 3 else 0.0
	var th: Array = pet_def(id)["growth"]
	var lo: float = 0.0 if stage == 0 else float(th[stage - 1])
	var hi: float = float(th[stage])
	return clampf((float(owned_pets[id].get("growth", 0.0)) - lo) / (hi - lo), 0.0, 1.0)


## Care points needed for the next stage, or -1.0 when fully grown / not owned.
func pet_next_threshold(id: String) -> float:
	var stage := pet_stage(id)
	if stage < 0 or stage >= 3:
		return -1.0
	return float(pet_def(id)["growth"][stage])


## Valid active pet id, or "" when none is owned.
func active_pet_id() -> String:
	if owned_pets.has(active_pet):
		return active_pet
	return ""


func set_active_pet(id: String) -> bool:
	if not owned_pets.has(id):
		return false
	active_pet = id
	_persist()
	active_pet_changed.emit(id)
	return true


## Buys the species egg with stars. False when unknown, already owned or too few stars.
func adopt_pet(id: String) -> bool:
	var def := pet_def(id)
	if def.is_empty() or owned_pets.has(id) or star_points < int(def["cost"]):
		return false
	star_points -= int(def["cost"])
	points_changed.emit(star_points)
	give_pet(id)
	return true


## Adds the species egg for free (story rewards). False when unknown or already owned.
func give_pet(id: String) -> bool:
	var def := pet_def(id)
	if def.is_empty() or owned_pets.has(id):
		return false
	owned_pets[id] = {"name": def["name"], "growth": 0.0, "hunger": 80.0, "happiness": 80.0,
		"last_ts": Time.get_unix_time_from_system(), "acc": "", "acc_own": []}
	if active_pet_id() == "":
		active_pet = id
		active_pet_changed.emit(id)
	_persist()
	pet_changed.emit(id)
	return true


## "" when feeding is possible, else "not_owned", "full" or "stars".
func can_feed(id: String) -> String:
	if not owned_pets.has(id):
		return "not_owned"
	if float(owned_pets[id].get("hunger", 0.0)) >= PET_FULL_AT:
		return "full"
	if star_points < PET_FEED_COST:
		return "stars"
	return ""


## Feeds the pet (costs PET_FEED_COST stars). False when can_feed() is not "".
func feed_pet(id: String) -> bool:
	if can_feed(id) != "":
		return false
	star_points -= PET_FEED_COST
	points_changed.emit(star_points)
	var pet: Dictionary = owned_pets[id]
	pet["hunger"] = minf(100.0, float(pet["hunger"]) + PET_FEED_FILL)
	pet["happiness"] = minf(100.0, float(pet["happiness"]) + PET_FEED_JOY)
	_pet_gain(id, PET_FEED_GROWTH)
	_persist()
	pet_changed.emit(id)
	return true


## Pets the pet (free). False when not owned or still on cooldown (`now_s` is for checks).
func pet_pet(id: String, now_s: float = -1.0) -> bool:
	if not owned_pets.has(id):
		return false
	var now: float = now_s if now_s >= 0.0 else float(Time.get_ticks_msec()) / 1000.0
	if now < float(_pet_cooldown.get(id, -1.0)):
		return false
	_pet_cooldown[id] = now + PET_PET_COOLDOWN
	var pet: Dictionary = owned_pets[id]
	var was_joy: float = float(pet["happiness"])
	pet["happiness"] = minf(100.0, was_joy + PET_PET_JOY)
	if was_joy < 100.0:
		_pet_gain(id, PET_PET_GROWTH)
	_persist()
	pet_changed.emit(id)
	return true


## Adds care points (slowed, never reduced below zero, when a need is low) and signals new stages.
func _pet_gain(id: String, amount: float) -> void:
	var pet: Dictionary = owned_pets[id]
	var before := pet_stage(id)
	var mult := 1.0
	if float(pet["hunger"]) < PET_LOW_NEED or float(pet["happiness"]) < PET_LOW_NEED:
		mult = PET_SLOW_GROWTH_MULT
	pet["growth"] = float(pet["growth"]) + amount * mult
	var after := pet_stage(id)
	if after > before:
		pet_stage_changed.emit(id, after)


## `pet` with needs drifted down for the real time since `last_ts` (max 24 h counted,
## never below PET_NEED_FLOOR) and last_ts set to `now`. Pure: returns a copy.
static func decay_needs(pet: Dictionary, now: float) -> Dictionary:
	var out := pet.duplicate()
	var hours := clampf(now - float(pet.get("last_ts", now)), 0.0, PET_OFFLINE_MAX_SECS) / 3600.0
	var hun := float(pet.get("hunger", 80.0))
	var joy := float(pet.get("happiness", 80.0))
	out["hunger"] = minf(hun, maxf(PET_NEED_FLOOR, hun - hours * PET_HUNGER_DECAY_PER_HOUR))
	out["happiness"] = minf(joy, maxf(PET_NEED_FLOOR, joy - hours * PET_JOY_DECAY_PER_HOUR))
	out["last_ts"] = now
	return out


## Applies decay_needs to every owned pet (call on load and when the Pets screen opens).
func refresh_pet_needs(now: float = -1.0) -> void:
	var t: float = now if now >= 0.0 else Time.get_unix_time_from_system()
	for id in owned_pets.keys():
		owned_pets[id] = decay_needs(owned_pets[id], t)


## 2 = sleepy / wants a snack, 1 = happy, 0 = normal (used for the pet's face).
func pet_mood(id: String) -> int:
	if not owned_pets.has(id):
		return 0
	var pet: Dictionary = owned_pets[id]
	if float(pet["hunger"]) < PET_LOW_NEED or float(pet["happiness"]) < PET_LOW_NEED:
		return 2
	return 1 if float(pet["happiness"]) >= 70.0 and float(pet["hunger"]) >= 50.0 else 0


## Gentle one-liner about how the pet feels (no negative messaging).
func pet_status_text(id: String) -> String:
	if not owned_pets.has(id):
		return ""
	var pet: Dictionary = owned_pets[id]
	if float(pet["hunger"]) < PET_LOW_NEED:
		return "wants a snack"
	if float(pet["happiness"]) < PET_LOW_NEED:
		return "is a little sleepy"
	return "is feeling great!" if pet_mood(id) == 1 else "is happy to see you"


## Companion assist numbers for a pet's current stage: {every: seconds, boss: health chipped}.
func pet_zap(id: String) -> Dictionary:
	var stage := pet_stage(id)
	if stage < 0:
		return {"every": 0.0, "boss": 0}
	var def := pet_def(id)
	return {"every": float(def["zap_every"][stage]), "boss": int(def["zap_boss"][stage])}


func _persist() -> void:
	if persist_saves:
		save_game()


func save_game() -> void:
	if not persist_saves:
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(to_save_dict()))
		f.close()


## Every persisted field. Must stay in step with apply_save_dict().
func to_save_dict() -> Dictionary:
	return {
		"owned_pets": owned_pets,
		"active_pet": active_pet,
		"star_points": star_points,
		"total_earned": total_earned,
		"unlocked_outfits": unlocked_outfits,
		"equipped_outfit": equipped_outfit,
		"unlocked_weapons": unlocked_weapons,
		"equipped_weapon": equipped_weapon,
		"unlocked_hairstyles": unlocked_hairstyles,
		"hairstyle": hairstyle,
		"unlocked_hair_colors": unlocked_hair_colors,
		"hair_color": hair_color,
		"unlocked_headwear": unlocked_headwear,
		"headwear": headwear,
		"unlocked_face_acc": unlocked_face_acc,
		"face_acc": face_acc,
		"affection": affection,
		"best_scores": best_scores,
		"grade": grade,
		"story_wins": story_wins,
		"story_claimed": story_claimed,
		"sound_on": sound_on,
		"reduce_motion": reduce_motion,
		"tutorial_done": tutorial_done,
		"streak": streak,
		"last_login_date": last_login_date,
		"stickers": stickers,
		"seen_scenes": seen_scenes,
		"finale_done": finale_done,
	}


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not f:
		return
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	apply_save_dict(parsed)


## Restores state from a parsed save; missing keys keep their current value.
func apply_save_dict(parsed: Dictionary) -> void:
	star_points = parsed.get("star_points", star_points)
	total_earned = parsed.get("total_earned", total_earned)
	unlocked_outfits = parsed.get("unlocked_outfits", unlocked_outfits)
	equipped_outfit = parsed.get("equipped_outfit", equipped_outfit)
	unlocked_weapons = parsed.get("unlocked_weapons", unlocked_weapons)
	equipped_weapon = parsed.get("equipped_weapon", equipped_weapon)
	unlocked_hairstyles = parsed.get("unlocked_hairstyles", unlocked_hairstyles)
	hairstyle = parsed.get("hairstyle", hairstyle)
	unlocked_hair_colors = parsed.get("unlocked_hair_colors", unlocked_hair_colors)
	hair_color = parsed.get("hair_color", hair_color)
	unlocked_headwear = parsed.get("unlocked_headwear", unlocked_headwear)
	headwear = parsed.get("headwear", headwear)
	unlocked_face_acc = parsed.get("unlocked_face_acc", unlocked_face_acc)
	face_acc = parsed.get("face_acc", face_acc)
	affection = parsed.get("affection", affection)
	best_scores = parsed.get("best_scores", best_scores)
	grade = parsed.get("grade", grade)
	story_wins = int(parsed.get("story_wins", story_wins))
	story_claimed = int(parsed.get("story_claimed", story_claimed))
	sound_on = parsed.get("sound_on", sound_on)
	reduce_motion = parsed.get("reduce_motion", reduce_motion)
	tutorial_done = bool(parsed.get("tutorial_done", false))
	streak = int(parsed.get("streak", 0))
	last_login_date = str(parsed.get("last_login_date", ""))
	var raw_st = parsed.get("stickers", [])
	stickers = (raw_st as Array).duplicate() if typeof(raw_st) == TYPE_ARRAY else []
	var raw_sc = parsed.get("seen_scenes", [])
	seen_scenes = (raw_sc as Array).duplicate() if typeof(raw_sc) == TYPE_ARRAY else []
	finale_done = bool(parsed.get("finale_done", false))
	StoryRewards.sync_outfits(self)
	_load_pets(parsed)


## Known accessory id or "" (old or hand-edited saves).
func _clean_acc(v) -> String:
	return str(v) if not accessory_def(str(v)).is_empty() else ""


func _clean_acc_list(v) -> Array:
	var out: Array = []
	if typeof(v) == TYPE_ARRAY:
		for x in v:
			if not accessory_def(str(x)).is_empty() and not out.has(str(x)):
				out.append(str(x))
	return out


## Reads pets from a parsed save with defaults for every field (old saves have none),
## then applies the gentle offline decay.
func _load_pets(parsed: Dictionary) -> void:
	owned_pets = {}
	var raw = parsed.get("owned_pets", {})
	var now := Time.get_unix_time_from_system()
	if typeof(raw) == TYPE_DICTIONARY:
		for id in raw.keys():
			var def := pet_def(str(id))
			if def.is_empty() or typeof(raw[id]) != TYPE_DICTIONARY:
				continue
			var p: Dictionary = raw[id]
			owned_pets[str(id)] = decay_needs({
				"name": str(p.get("name", def["name"])),
				"growth": maxf(0.0, float(p.get("growth", 0.0))),
				"hunger": clampf(float(p.get("hunger", 80.0)), 0.0, 100.0),
				"happiness": clampf(float(p.get("happiness", 80.0)), 0.0, 100.0),
				"last_ts": float(p.get("last_ts", now)),
					"acc": _clean_acc(p.get("acc", "")),
					"acc_own": _clean_acc_list(p.get("acc_own", [])),
			}, now)
	active_pet = str(parsed.get("active_pet", ""))
	if not owned_pets.has(active_pet):
		active_pet = owned_pets.keys()[0] if owned_pets.size() > 0 else ""
