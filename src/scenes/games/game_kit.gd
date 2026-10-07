class_name GameKit
extends RefCounted
## Shared look for the mini-games (Story 026-030): the same pills, hearts, round buttons, themed
## animated backdrops and pet cheer as the Alley Brawl, so every game feels like one family.
## All helpers draw onto a CanvasItem; they never touch GameState except to read reduce_motion/pet.

## Themes: sky gradient top/bottom, glow accent, skyline silhouette colour, star colour.
const FxLight := preload("res://scripts/fx_light.gd")

const THEMES := {
	"neon": {"top": Color("#1A0F3D"), "bot": Color("#5B2A86"), "glow": Color("#FF5FA2"), "sil": Color("#241552"), "star": Color("#FFE9F5")},
	"lantern": {"top": Color("#0E1B3D"), "bot": Color("#2B3F7A"), "glow": Color("#FFC15E"), "sil": Color("#16244F"), "star": Color("#FFF3C9")},
	"mint": {"top": Color("#0D2B3A"), "bot": Color("#1F6E73"), "glow": Color("#52E8C6"), "sil": Color("#133B4A"), "star": Color("#D9FFF4")},
	"dusk": {"top": Color("#2A1457"), "bot": Color("#B8467E"), "glow": Color("#FFD36E"), "sil": Color("#3A1D6B"), "star": Color("#FFF0D1")},
}


## True when decorative motion should be off (GameState.reduce_motion).
static func calm() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	var gs: Node = tree.root.get_node_or_null("GameState") if tree else null
	return gs != null and bool(gs.get("reduce_motion"))


## Gradient sky + twinkling stars + two parallax skyline layers + drifting glow motes.
## `t` is seconds of animation (pass 0 when calm), `scroll` shifts the skyline sideways (px).
static func draw_backdrop(ci: CanvasItem, size: Vector2, theme: String, t: float, scroll: float = 0.0) -> void:
	var th: Dictionary = THEMES.get(theme, THEMES["neon"])
	var bands := 24
	for i in bands:
		var f0: float = float(i) / float(bands)
		var c: Color = (th["top"] as Color).lerp(th["bot"], f0)
		ci.draw_rect(Rect2(0.0, size.y * f0, size.x, size.y / float(bands) + 1.0), c)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	for i in 46:
		var p := Vector2(rng.randf() * size.x, rng.randf() * size.y * 0.6)
		var tw: float = 0.55 + 0.45 * sin(t * 2.0 + float(i) * 1.7)
		ci.draw_circle(p, 1.2 + rng.randf() * 1.4, Color(th["star"], 0.25 + 0.6 * tw))
	_skyline(ci, size, th["sil"], 0.30, 0.20, scroll * 0.25, 7)
	_skyline(ci, size, (th["sil"] as Color).darkened(0.25), 0.22, 0.14, scroll * 0.5, 11)
	for i in 14:
		var bx: float = fposmod(rng.randf() * size.x + t * (8.0 + float(i % 4) * 3.0) + scroll * 0.7, size.x + 40.0) - 20.0
		var by: float = size.y * (0.15 + rng.randf() * 0.7) + sin(t * 1.3 + float(i)) * 8.0
		ci.draw_circle(Vector2(bx, by), 5.0, Color(th["glow"], 0.07))
		ci.draw_circle(Vector2(bx, by), 2.0, Color(th["glow"], 0.55))
	_light_pass(ci, size, th, t)


## Cheap lighting pass: two drifting light shafts, a horizon halo and a vignette.
static func _light_pass(ci: CanvasItem, size: Vector2, th: Dictionary, t: float) -> void:
	var fl: float = 0.0 if calm() else t
	var g: Color = th["glow"]
	FxLight.halo(ci, Vector2(size.x * 0.5, size.y * 0.92), size.x * 0.7, g, 0.3, size.y * 0.16)
	FxLight.shaft(ci, Vector2(size.x * 0.2, -8.0), PI * 0.5 + 0.3, size.y * 0.8, size.x * 0.3, g, 0.09, fl, 1.0)
	FxLight.shaft(ci, Vector2(size.x * 0.75, -8.0), PI * 0.5 - 0.25, size.y * 0.75, size.x * 0.26, Color(th["star"]), 0.07, fl, 2.0)
	FxLight.vignette(ci, Rect2(Vector2.ZERO, size), 0.35)


static func _skyline(ci: CanvasItem, size: Vector2, col: Color, top_frac: float, hmax_frac: float, shift: float, seed_v: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var x: float = -fposmod(shift, 90.0) - 90.0
	var base: float = size.y * (1.0 - top_frac * 0.0)
	while x < size.x + 90.0:
		var w: float = 40.0 + rng.randf() * 50.0
		var h: float = size.y * (0.05 + rng.randf() * hmax_frac)
		ci.draw_rect(Rect2(x, base - h - size.y * 0.05, w, h + size.y * 0.06), col)
		if rng.randf() < 0.6:
			for wy in int(h / 22.0):
				if rng.randf() < 0.5:
					ci.draw_rect(Rect2(x + 8.0 + rng.randf() * (w - 22.0), base - h - size.y * 0.05 + 8.0 + float(wy) * 22.0, 6.0, 8.0), Color(1.0, 0.85, 0.5, 0.35))
		x += w + 4.0


## Rounded translucent pill.
static func pill(ci: CanvasItem, r: Rect2, fill: Color) -> void:
	var sb: StyleBoxFlat = UiTheme.box(fill, Color(1, 1, 1, 0.18), 2, int(r.size.y * 0.5), 8, 2, 2)
	sb.draw(ci.get_canvas_item(), r)


## Centered text in a rect using the fallback font.
static func text(ci: CanvasItem, txt: String, r: Rect2, px: float, col: Color, align: int = HORIZONTAL_ALIGNMENT_CENTER) -> void:
	var f: Font = ThemeDB.fallback_font
	var fs: int = int(px)
	var ty: float = r.position.y + (r.size.y + float(fs) * 0.72) * 0.5
	ci.draw_string(f, Vector2(r.position.x, ty), txt, align as HorizontalAlignment, r.size.x, fs, col)


## Row of hearts (full / empty) inside a pill; returns the pill rect.
static func hearts(ci: CanvasItem, pos: Vector2, have: int, total: int, u: float) -> Rect2:
	var hs: float = 30.0 * u
	var panel := Rect2(pos, Vector2(hs * float(total) + 12.0 * u, hs + 8.0 * u))
	pill(ci, panel, Color(UiTheme.PANEL, 0.8))
	for i in total:
		var r := Rect2(pos.x + 6.0 * u + float(i) * hs, pos.y + 4.0 * u, hs, hs)
		if i < have:
			UiIcons.draw(ci, "heart", r, UiTheme.ACCENT)
		else:
			UiIcons.draw(ci, "heart", r.grow(-3.0 * u), Color(UiTheme.LOCKED, 0.55))
	return panel


## Score pill (and an optional second pill below it) at the top-right; returns bottom y.
static func score_pills(ci: CanvasItem, size: Vector2, u: float, score: int, sub: String = "", sub_hot: bool = false) -> float:
	var m: float = 12.0 * u
	var pw: float = 112.0 * u
	var ph: float = 28.0 * u
	var sr := Rect2(size.x - pw - m, m, pw, ph)
	pill(ci, sr, Color(UiTheme.PANEL, 0.85))
	text(ci, "Score %d" % score, sr, 14.0 * u, UiTheme.TEXT)
	var bottom: float = sr.end.y
	if sub != "":
		var wr := Rect2(size.x - pw - m, m + ph + 6.0 * u, pw, ph)
		pill(ci, wr, Color(UiTheme.ACCENT_DARK if sub_hot else UiTheme.PANEL_LIGHT, 0.9))
		text(ci, sub, wr, 14.0 * u, UiTheme.TEXT)
		bottom = wr.end.y
	return bottom


## Circular countdown ring with seconds inside. `ratio` 1 -> 0.
static func timer_ring(ci: CanvasItem, c: Vector2, radius: float, ratio: float, label: String, hot: bool = false) -> void:
	ci.draw_circle(c, radius, Color(UiTheme.PANEL, 0.85))
	ci.draw_arc(c, radius - 3.0, 0.0, TAU, 40, Color(1, 1, 1, 0.12), 5.0, true)
	var col: Color = UiTheme.ACCENT if hot else UiTheme.TEAL
	ci.draw_arc(c, radius - 3.0, -PI * 0.5, -PI * 0.5 + TAU * clampf(ratio, 0.0, 1.0), 40, col, 5.0, true)
	text(ci, label, Rect2(c - Vector2(radius, radius), Vector2(radius, radius) * 2.0), radius * 0.8, UiTheme.TEXT)


## Draws the active pet (if hatched) as a small cheering sidekick at `c`; `cheer` 0..1 hops it.
static func pet_cheer(ci: CanvasItem, c: Vector2, px: float, t: float, cheer: float = 0.0) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var gs: Node = tree.root.get_node_or_null("GameState") if tree else null
	if gs == null:
		return
	var id: String = String(gs.call("active_pet_id"))
	if id == "":
		return
	var stage: int = int(gs.call("pet_stage", id))
	if stage < 1:
		return
	var hop: float = -absf(sin(t * 9.0)) * 10.0 * cheer
	var PetArt := load("res://scripts/pet_art.gd")
	PetArt.draw(ci, id, stage, Rect2(c.x - px * 0.5, c.y - px + hop, px, px), t, not calm(), PetArt.MOOD_HAPPY if cheer > 0.0 else PetArt.MOOD_NORMAL, cheer, false)


## One-shot confetti-style sparkle at a position inside `parent` (no-op when calm).
static func burst(parent: Control, global_center: Vector2) -> void:
	if calm():
		return
	SparkleBurst.spawn(parent, global_center)
