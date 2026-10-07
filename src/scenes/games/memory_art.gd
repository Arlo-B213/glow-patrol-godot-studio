extends RefCounted
## Art for Memory Match (Story 027): card back with a glowing lantern emblem, card faces drawn as
## UiIcons, the cosy lantern-lit board and the hanging lantern. Every function draws onto a
## CanvasItem from its _draw(); `t` is animation seconds (0 = still when reduced motion).

## Card faces: UiIcons names tinted with the parallel COLORS entry (same set as the old hub game).
const ICONS := ["star", "heart", "lantern", "zap", "music", "catch"]
const COLORS := [UiTheme.GOLD, UiTheme.ACCENT, UiTheme.VIOLET, UiTheme.TEAL, UiTheme.ACCENT, UiTheme.GOLD]

static var _cache := {}


static func _box(key: String, bg: Color, border: Color, bw: int, radius: int) -> StyleBoxFlat:
	var k := "%s_%d" % [key, radius]
	if not _cache.has(k):
		_cache[k] = UiTheme.box(bg, border, bw, radius, 0, 0, 0)
	return _cache[k]


## Warm board panel behind the cards, lit from the hanging lantern above it.
static func board(ci: CanvasItem, r: Rect2, t: float, u: float) -> void:
	var sb: StyleBoxFlat = _box("board", Color("#2B1A22", 0.82), Color(UiTheme.GOLD, 0.35), 3, int(22.0 * u))
	sb.draw(ci.get_canvas_item(), r)
	var flick: float = 1.0 if t == 0.0 else 1.0 + 0.08 * sin(t * 5.0) + 0.04 * sin(t * 11.0)
	for i in 4:
		ci.draw_circle(Vector2(r.get_center().x, r.position.y - 20.0 * u), (r.size.x * (0.25 + 0.17 * float(i))) * flick, Color(UiTheme.GOLD, 0.045))


## Lantern hanging from the top edge at `x` (string, glow, icon).
static func hanging_lantern(ci: CanvasItem, x: float, hang_y: float, t: float, u: float) -> void:
	var sway: float = 0.0 if t == 0.0 else sin(t * 1.4) * 3.0 * u
	var c := Vector2(x + sway, hang_y)
	ci.draw_line(Vector2(x, 0.0), c + Vector2(0.0, -16.0 * u), Color(1, 1, 1, 0.35), 2.0 * u, true)
	var flick: float = 0.8 if t == 0.0 else 0.8 + 0.2 * sin(t * 5.0)
	ci.draw_circle(c, 34.0 * u * flick, Color(UiTheme.GOLD, 0.12))
	ci.draw_circle(c, 22.0 * u * flick, Color(UiTheme.GOLD, 0.18))
	UiIcons.draw(ci, "lantern", Rect2(c - Vector2(16.0, 16.0) * u, Vector2(32.0, 32.0) * u), UiTheme.GOLD)


## Face-down card: deep panel, thin inner frame and a glowing lantern emblem.
static func card_back(ci: CanvasItem, r: Rect2, t: float, seed_v: float) -> void:
	var rad: int = int(minf(r.size.x, r.size.y) * 0.14)
	_box("back", UiTheme.PANEL, UiTheme.PANEL_LIGHT, 3, rad).draw(ci.get_canvas_item(), r)
	var inner: Rect2 = r.grow(-r.size.y * 0.05)
	_box("frame", Color(0, 0, 0, 0), Color(UiTheme.GOLD, 0.28), 2, maxi(1, rad - 4)).draw(ci.get_canvas_item(), inner)
	var c: Vector2 = r.get_center()
	var side: float = minf(r.size.x, r.size.y)
	if r.size.x < r.size.y * 0.3:
		return  # squeezed mid-flip: the emblem would be a degenerate polygon
	var pulse: float = 0.5 if t == 0.0 else 0.5 + 0.5 * sin(t * 2.2 + seed_v)
	ci.draw_circle(c, side * (0.36 + 0.05 * pulse), Color(UiTheme.GOLD, 0.10 + 0.08 * pulse))
	ci.draw_circle(c, side * 0.26, Color(UiTheme.GOLD, 0.12))
	UiIcons.draw(ci, "lantern", Rect2(c - Vector2(side, side) * 0.24, Vector2(side, side) * 0.48), UiTheme.GOLD)


## Face-up card showing icon `idx`; `matched` adds a gold frame and a soft pulsing glow.
static func card_face(ci: CanvasItem, r: Rect2, idx: int, matched: bool, t: float, seed_v: float) -> void:
	var col: Color = COLORS[idx]
	var rad: int = int(minf(r.size.x, r.size.y) * 0.14)
	var c: Vector2 = r.get_center()
	var side: float = minf(r.size.x, r.size.y)
	if matched:
		var pulse: float = 0.5 if t == 0.0 else 0.5 + 0.5 * sin(t * 3.0 + seed_v)
		ci.draw_circle(c, side * (0.62 + 0.05 * pulse), Color(UiTheme.GOLD, 0.14))
	if r.size.x < r.size.y * 0.3:
		return
	var border: Color = UiTheme.GOLD if matched else col
	_box("face%d%s" % [idx, "m" if matched else ""], UiTheme.BG.lerp(col, 0.22 if matched else 0.16), border, 4 if matched else 3, rad).draw(ci.get_canvas_item(), r)
	UiIcons.draw(ci, ICONS[idx], Rect2(c - Vector2(side, side) * 0.3, Vector2(side, side) * 0.6), col)
