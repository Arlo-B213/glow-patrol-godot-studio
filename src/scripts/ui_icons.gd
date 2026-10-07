class_name UiIcons
extends RefCounted
## Code-drawn UI icon set (Story 011). Entry point is `UiIcons.draw()`.
## Shared language: bold fills, one stroke weight (UiIconKit.STROKE), round caps,
## the `tint` as the main colour with light/dark companions derived from it.
## Tab, sound and arrow icons live in ui_icons_tabs.gd.

const K := preload("res://scripts/ui_icon_kit.gd")

## Every icon name `draw()` understands (used by contact sheets and tests).
const ICON_NAMES: Array[String] = [
	"star", "level", "heart", "outfit", "friendship", "sound_on", "sound_off",
	"home", "club", "battle", "games", "study", "back", "forward", "close",
	"zap", "fist", "music", "cards", "catch", "lantern", "math", "grammar",
	"reading", "lounge", "closet", "stage", "motion_on", "motion_off",
	"paw", "bowl",
]


## Draws icon `icon` inside `rect` (centred and squared to the smaller side) in `tint`.
static func draw(ci: CanvasItem, icon: String, rect: Rect2, tint: Color) -> void:
	var side := minf(rect.size.x, rect.size.y)
	if side <= 0.0:
		return
	var sq := Rect2(rect.position + (rect.size - Vector2(side, side)) * 0.5, Vector2(side, side))
	sq = sq.grow(-side * 0.04)
	match icon:
		"star": draw_star(ci, sq, tint)
		"level": draw_level(ci, sq, tint)
		"heart": draw_heart(ci, sq, tint)
		"outfit": draw_outfit(ci, sq, tint)
		"friendship": draw_friendship(ci, sq, tint)
		"sound_on": UiIconsTabs.draw_sound(ci, sq, tint, true)
		"sound_off": UiIconsTabs.draw_sound(ci, sq, tint, false)
		"home": UiIconsTabs.draw_home(ci, sq, tint)
		"club": UiIconsTabs.draw_club(ci, sq, tint)
		"battle": UiIconsTabs.draw_battle(ci, sq, tint)
		"games": UiIconsTabs.draw_games(ci, sq, tint)
		"study": UiIconsTabs.draw_study(ci, sq, tint)
		"paw": UiIconsTabs.draw_paw(ci, sq, tint)
		"bowl": UiIconsTabs.draw_bowl(ci, sq, tint)
		"back": UiIconsTabs.draw_back(ci, sq, tint)
		"forward":
			# The back arrow mirrored around the icon's vertical centre line.
			var cx: float = sq.position.x + sq.size.x * 0.5
			ci.draw_set_transform_matrix(Transform2D(Vector2(-1.0, 0.0), Vector2(0.0, 1.0), Vector2(2.0 * cx, 0.0)))
			UiIconsTabs.draw_back(ci, sq, tint)
			ci.draw_set_transform_matrix(Transform2D.IDENTITY)
		"close": UiIconsTabs.draw_close(ci, sq, tint)
		"zap": UiIconsCards.draw_zap(ci, sq, tint)
		"fist": UiIconsCards.draw_fist(ci, sq, tint)
		"music": UiIconsCards.draw_music(ci, sq, tint)
		"cards": UiIconsCards.draw_cards(ci, sq, tint)
		"catch": UiIconsCards.draw_catch(ci, sq, tint)
		"lantern": UiIconsCards.draw_lantern(ci, sq, tint)
		"math": UiIconsCards.draw_math(ci, sq, tint)
		"grammar": UiIconsCards.draw_grammar(ci, sq, tint)
		"reading": UiIconsCards.draw_reading(ci, sq, tint)
		"lounge": UiIconsCards.draw_lounge(ci, sq, tint)
		"closet": UiIconsCards.draw_closet(ci, sq, tint)
		"stage": UiIconsCards.draw_stage(ci, sq, tint)
		"motion_on": draw_motion(ci, sq, tint, true)
		"motion_off": draw_motion(ci, sq, tint, false)
		_:
			push_warning("UiIcons: unknown icon '%s'" % icon)
			ci.draw_circle(sq.get_center(), side * 0.4, tint)


## Motion toggle: sparkle (big four-point star plus small spark); crossed out when `on` is false.
static func draw_motion(ci: CanvasItem, r: Rect2, tint: Color, on: bool) -> void:
	var w := K.sw(r)
	var big: Array = [
		Vector2(0.44, 0.1), Vector2(0.53, 0.4), Vector2(0.82, 0.5), Vector2(0.53, 0.6),
		Vector2(0.44, 0.9), Vector2(0.35, 0.6), Vector2(0.06, 0.5), Vector2(0.35, 0.4),
	]
	K.poly(ci, r, big, tint, w * 0.5)
	K.line(ci, r, Vector2(0.82, 0.12), Vector2(0.82, 0.3), tint, w * 0.6)
	K.line(ci, r, Vector2(0.73, 0.21), Vector2(0.91, 0.21), tint, w * 0.6)
	if not on:
		K.line(ci, r, Vector2(0.1, 0.9), Vector2(0.9, 0.1), UiTheme.ACCENT, w)


## Star Points: five-point star with an inner highlight.
static func draw_star(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var pts: Array = []
	for i in 10:
		var ang := -PI * 0.5 + i * PI / 5.0
		var rad := 0.44 if i % 2 == 0 else 0.2
		pts.append(Vector2(0.5 + cos(ang) * rad, 0.55 + sin(ang) * rad))
	K.poly(ci, r, pts, tint, K.sw(r) * 0.9)
	# Inner highlight: small bright facet near the upper left of the centre.
	var hl: Array = [Vector2(0.5, 0.3), Vector2(0.58, 0.5), Vector2(0.5, 0.58), Vector2(0.42, 0.5)]
	K.poly(ci, r, hl, K.light(tint), 0.0)


## Level badge: rounded shield with a double chevron.
static func draw_level(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var shield: Array = [
		Vector2(0.16, 0.12), Vector2(0.84, 0.12), Vector2(0.84, 0.52),
		Vector2(0.5, 0.94), Vector2(0.16, 0.52),
	]
	K.poly(ci, r, shield, tint, K.sw(r) * 0.9)
	var w := K.sw(r) * 0.85
	var d := K.dark(tint)
	K.polyline(ci, r, [Vector2(0.33, 0.5), Vector2(0.5, 0.33), Vector2(0.67, 0.5)], d, w)
	K.polyline(ci, r, [Vector2(0.33, 0.68), Vector2(0.5, 0.51), Vector2(0.67, 0.68)], d, w)


## Heart with a small highlight.
static func draw_heart(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	K.heart(ci, r, 0.5, 0.45, 0.98, tint)
	K.circ(ci, r, 0.29, 0.28, 0.06, K.light(tint))


## Outfit: clothes hanger with a tinted garment body.
static func draw_outfit(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var w := K.sw(r)
	var body: Array = [Vector2(0.5, 0.42), Vector2(0.94, 0.78), Vector2(0.06, 0.78)]
	K.poly(ci, r, body, K.light(tint).lerp(tint, 0.5), w * 0.6)
	# Hook: open circle with a gap, then the neck down to the shoulders.
	K.arc(ci, r, 0.5, 0.2, 0.11, PI * 0.55, PI * 2.25, tint, w)
	K.line(ci, r, Vector2(0.5, 0.31), Vector2(0.5, 0.42), tint, w)
	K.line(ci, r, Vector2(0.5, 0.42), Vector2(0.06, 0.78), tint, w)
	K.line(ci, r, Vector2(0.5, 0.42), Vector2(0.94, 0.78), tint, w)
	K.line(ci, r, Vector2(0.06, 0.8), Vector2(0.94, 0.8), tint, w)


## Friendship: two overlapping hearts with a spark.
static func draw_friendship(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var back_col := tint.lerp(UiTheme.GOLD, 0.6)
	K.heart(ci, r, 0.68, 0.6, 0.62, back_col)
	K.heart(ci, r, 0.36, 0.5, 0.74, UiTheme.BG)
	K.heart(ci, r, 0.36, 0.5, 0.62, tint)
	K.circ(ci, r, 0.22, 0.38, 0.045, K.light(tint))
	# Spark (four-point) top right.
	var w := K.sw(r) * 0.55
	K.line(ci, r, Vector2(0.78, 0.1), Vector2(0.78, 0.3), UiTheme.GOLD, w)
	K.line(ci, r, Vector2(0.68, 0.2), Vector2(0.88, 0.2), UiTheme.GOLD, w)
