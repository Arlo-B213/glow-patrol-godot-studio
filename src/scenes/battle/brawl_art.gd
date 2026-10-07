extends RefCounted
## Procedural enemy art entry points for Alley Brawl, Star Catch and Zap Patrol (the idol hunter lives
## in res://scripts/hunter_art.gd). Story 031 replaced the old blobs with expressive humanoid "gloom"
## characters (gloom_imp / gloom_scout / gloom_brute / gloom_king / gloom_hydra, built on gloom_kit,
## gloom_face and gloom_gear); this file keeps the original API. Every function draws onto a
## CanvasItem and must be called from its _draw(). `u` is the view's layout scale.

const SKIN := Color("#FFD9C2")
const INK := Color("#1A0B33")
const BLACKOUT := Color("#0A0418")
const GOLD := Color("#FFD36E")
const PINK := Color("#FF5FA2")
const Extra := preload("res://scenes/battle/brawl_art_enemies.gd")
const Hydra := preload("res://scenes/battle/brawl_art_hydra.gd")
const Imp := preload("res://scenes/battle/gloom_imp.gd")
const Scout := preload("res://scenes/battle/gloom_scout.gd")
const Brute := preload("res://scenes/battle/gloom_brute.gd")
const King := preload("res://scenes/battle/gloom_king.gd")
const HydraBody := preload("res://scenes/battle/gloom_hydra.gd")

## Draw calls issued by the most recent enemy/boss draw (for performance checks).
static var last_calls: int = 0


## Draws one enemy by `type_id` (see brawl_enemies.gd). `fx` keys, all optional: flash (0..1 white
## tint), sq (vertical squash, 1 = none), alpha (0..1 fade), hp (health left, for Mossback), walk
## (0..1 walk blend), near (0..1 hunter proximity wind-up), strike (0..1 just bumped), stun (bool),
## dying (0..1 defeat progress), air (bool dangling pose), mood (gloom_kit Mood override).
static func draw_enemy(ci: CanvasItem, type_id: String, x: float, ground_y: float, s: float, color: Color, age: int, toward: float, u: float, fx: Dictionary = {}) -> void:
	match type_id:
		"blinker":
			last_calls = Scout.draw(ci, x, ground_y, s, color, age, toward, u, fx)
		"mossback":
			last_calls = Brute.draw(ci, x, ground_y, s, color, age, toward, u, fx)
		_:
			last_calls = Imp.draw(ci, x, ground_y, s, color, age, toward, u, fx)


## A Gloomling: a shadow imp kid in a tattered hoodie. `toward` is -1 or 1, the side the player is
## on, so the eyes track them (0 = look straight ahead). `fx`: see draw_enemy.
static func draw_gloomling(ci: CanvasItem, x: float, ground_y: float, s: float, color: Color, age: int, toward: float, u: float, fx: Dictionary = {}) -> void:
	last_calls = Imp.draw(ci, x, ground_y, s, color, age, toward, u, fx)


## Draws the boss of `kind` ("king" or "hydra"); see brawl_enemies.gd BOSS_KINDS. `fx` extras:
## hpf (health fraction 0..1), stun (bool), near, strike, flash (0..1, overrides the bool).
static func draw_boss_kind(ci: CanvasItem, kind: String, x: float, ground_y: float, s: float, flash: bool, age: int, toward: float, u: float, fx: Dictionary = {}) -> void:
	var f: Dictionary = fx.duplicate()
	if flash and not f.has("flash"):
		f["flash"] = 0.55
	if kind == "hydra":
		last_calls = HydraBody.draw(ci, x, ground_y, s * 0.88, age, toward, u, f)
	else:
		last_calls = King.draw(ci, x, ground_y, s * 0.88, age, toward, u, f)


## The Grumble King (kept for older callers): see draw_boss_kind.
static func draw_boss(ci: CanvasItem, x: float, ground_y: float, s: float, flash: bool, age: int, toward: float, u: float, fx: Dictionary = {}) -> void:
	draw_boss_kind(ci, "king", x, ground_y, s, flash, age, toward, u, fx)
