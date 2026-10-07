class_name StoryRewards
extends RefCounted
## Story-linked rewards (Story 020/021). Outfits: chapter index (0-based, into StoryArc.CHAPTERS)
## -> an outfit definition in the GameState.OUTFITS shape plus "chapter_title" (for the toast).
## Entries with "finale": true are granted by the finale win instead of the chapter unlock.
## Granted outfits are appended to GameState.unlocked_outfits (cost 0), so counters and the
## Closet treat them like any owned outfit; GameState.all_outfits() lists the owned ones.

const FINALE_STARS := 50
const FINALE_EGG := "sparkfox"
const FINALE_EGG_FALLBACK_STARS := 20

const OUTFITS_BY_CHAPTER := {
	0: {"id": "lamplighter", "name": "Lamplighter Robe", "cost": 0, "hair": Color("#7A3B12"), "outfit": Color("#FFA94D"), "style": "robe", "chapter_title": "Lights Out on Pudding Lane"},
	4: {"id": "lanternking", "name": "Lantern Hero Cape", "cost": 0, "hair": Color("#101033"), "outfit": Color("#FF8FC8"), "style": "cape", "chapter_title": "Grumble King's Last Grumble", "finale": true},
}


## Outfit defined for `chapter`, or an empty Dictionary.
static func outfit_for_chapter(chapter: int) -> Dictionary:
	return OUTFITS_BY_CHAPTER.get(chapter, {})


## Story outfit with `id`, or an empty Dictionary.
static func outfit_by_id(id: String) -> Dictionary:
	for o in OUTFITS_BY_CHAPTER.values():
		if o["id"] == id:
			return o
	return {}


## Chapter-unlocked (non-finale) outfit whose chapter has `title`, or an empty Dictionary.
static func outfit_for_title(title: String) -> Dictionary:
	for o in OUTFITS_BY_CHAPTER.values():
		if o["chapter_title"] == title and not o.get("finale", false):
			return o
	return {}


## Adds every story outfit that should be owned in `gs` (chapter reached; finale ones after
## finale_done) to unlocked_outfits. Returns the outfits added. Safe to call repeatedly.
static func sync_outfits(gs: Object) -> Array:
	var added: Array = []
	var chapters: int = StoryArc.unlocked_count(int(gs.story_wins))
	for ch in OUTFITS_BY_CHAPTER.keys():
		var o: Dictionary = OUTFITS_BY_CHAPTER[ch]
		var earned: bool = bool(gs.finale_done) if o.get("finale", false) else int(ch) < chapters
		if earned and not gs.unlocked_outfits.has(o["id"]):
			gs.unlocked_outfits.append(o["id"])
			added.append(o)
	return added


## Pays the one-time finale rewards (stars, outfit, free egg). Returns
## {"stars": int, "outfit": String, "egg": String} describing what was given, or an empty
## Dictionary when the finale was already completed (no repeat rewards).
static func grant_finale(gs: Object) -> Dictionary:
	if gs.finale_done:
		return {}
	gs.finale_done = true
	var stars: int = FINALE_STARS
	var outfit := ""
	for o in sync_outfits(gs):
		outfit = String(o["name"])
	var egg := ""
	if not gs.has_pet(FINALE_EGG):
		egg = String(gs.pet_def(FINALE_EGG)["name"])
		gs.give_pet(FINALE_EGG)
	else:
		stars += FINALE_EGG_FALLBACK_STARS
	gs.earn_points(stars)
	return {"stars": stars, "outfit": outfit, "egg": egg}
