extends Control
## Alley Brawl HUD (Story 025), code-drawn in the shared UiTheme style: hearts (UiIcons "heart")
## with the guard meter under them at top-left, a world minimap in the centre (districts, encounter
## zones, boss crown, hunter dot) and score + wave pills on the right. Also draws the pulsing
## "GO" arrow. The view just sets the fields below and calls `queue_redraw()`.

const World := preload("res://scenes/battle/brawl_world.gd")

var hearts := 3
var max_hearts := 3
var guard_ratio := 1.0
var guard_broken := false
var score := 0
var wave_text := "Wave 1/3"
## Hunter position along the world, 0..1.
var progress := 0.0
## How many zones are cleared (0..4) and whether the boss fight is on.
var zones_cleared := 0
var boss_active := false
var show_go := false
var go_y := 0.0
## Seconds of animation time (0.0 when reduce motion is on: static GO arrow).
var anim_t := 0.0
var district_name := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## Copies the view's state `v` (an AlleyBrawlView) into the HUD and `ctl` (the controls) and redraws both.
func sync_from(v: Variant, ctl: Control) -> void:
	var w: float = World.world_w(v.size.x)
	hearts = v.hearts
	max_hearts = v.BRAWL_HEARTS
	guard_ratio = v.guard / World.GUARD_MAX
	guard_broken = v.guard_break_t > 0
	score = v.score
	progress = v.player_x / w
	zones_cleared = v.zone_i
	boss_active = v.boss_phase
	anim_t = 0.0 if v.calm() else v._clock
	district_name = String(World.DISTRICTS[World.district_at(v.player_x, v.size.x)]["name"])
	show_go = not v.in_fight and not v.ended and v.zone_i < World.ZONES.size() and v.player_x < World.zone_trigger_px(v.zone_i, v.size.x) - 0.1 * v.size.x
	go_y = 84.0 * v.u
	if v.boss_phase:
		wave_text = "BOSS!"
	elif v.zone_i >= v.BRAWL_WAVES:
		wave_text = "Boss ahead"
	else:
		wave_text = "Wave %d/%d" % [v.zone_i + 1, v.BRAWL_WAVES]
	ctl.guard_ratio = guard_ratio
	ctl.guard_broken = guard_broken
	queue_redraw()
	ctl.queue_redraw()


func _pill(r: Rect2, fill: Color) -> void:
	var sb: StyleBoxFlat = UiTheme.box(fill, Color(1, 1, 1, 0.18), 2, int(r.size.y * 0.5), 8, 2, 2)
	sb.draw(get_canvas_item(), r)


func _text(txt: String, r: Rect2, px: float, col: Color) -> void:
	var f: Font = ThemeDB.fallback_font
	var fs: int = int(px)
	var ty: float = r.position.y + (r.size.y + float(fs) * 0.72) * 0.5
	draw_string(f, Vector2(r.position.x, ty), txt, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, fs, col)


func _draw() -> void:
	var u: float = clampf(size.x / 480.0, 1.0, 2.0)
	var m: float = 12.0 * u
	_draw_hearts(u, m)
	_draw_minimap(u, m)
	var pw: float = 112.0 * u
	var ph: float = 28.0 * u
	var sr := Rect2(size.x - pw - m, m, pw, ph)
	_pill(sr, Color(UiTheme.PANEL, 0.85))
	_text("Score %d" % score, sr, 14.0 * u, UiTheme.TEXT)
	var wr := Rect2(size.x - pw - m, m + ph + 6.0 * u, pw, ph)
	_pill(wr, Color(UiTheme.ACCENT_DARK if boss_active else UiTheme.PANEL_LIGHT, 0.9))
	_text(wave_text, wr, 14.0 * u, UiTheme.TEXT)
	if show_go:
		_draw_go(u)


func _draw_hearts(u: float, m: float) -> void:
	var hs: float = 30.0 * u
	var panel := Rect2(m, m, hs * float(max_hearts) + 12.0 * u, hs + 28.0 * u)
	_pill(panel, Color(UiTheme.PANEL, 0.8))
	for i in max_hearts:
		var r := Rect2(m + 6.0 * u + float(i) * hs, m + 3.0 * u, hs, hs)
		if i < hearts:
			UiIcons.draw(self, "heart", r, UiTheme.ACCENT)
		else:
			UiIcons.draw(self, "heart", r.grow(-3.0 * u), Color(UiTheme.LOCKED, 0.55))
	var bar := Rect2(m + 8.0 * u, m + hs + 9.0 * u, hs * float(max_hearts) - 4.0 * u, 9.0 * u)
	draw_rect(bar, Color(0, 0, 0, 0.45))
	var col: Color = UiTheme.TEAL
	if guard_broken:
		col = UiTheme.GOLD if (anim_t == 0.0 or int(anim_t * 8.0) % 2 == 0) else UiTheme.ACCENT
	elif guard_ratio < 0.3:
		col = UiTheme.GOLD
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(guard_ratio, 0.0, 1.0), bar.size.y)), col)
	draw_rect(bar, Color(1, 1, 1, 0.35), false, 1.5 * u)


func _draw_minimap(u: float, m: float) -> void:
	var left: float = m + 30.0 * u * float(max_hearts) + 24.0 * u
	var right: float = size.x - 112.0 * u - 2.0 * m
	var track := Rect2(left, m + 8.0 * u, maxf(40.0, right - left), 14.0 * u)
	_pill(track.grow_individual(6.0 * u, 6.0 * u, 6.0 * u, 6.0 * u), Color(UiTheme.PANEL, 0.7))
	var n: int = World.DISTRICTS.size()
	for i in n:
		var d: Dictionary = World.DISTRICTS[i]
		var x0: float = track.position.x + track.size.x * float(d["from"]) / World.WORLD_SCREENS
		var x1: float = track.position.x + track.size.x * float(d["to"]) / World.WORLD_SCREENS
		var c: Color = d["a"]
		draw_rect(Rect2(x0 + 1.0, track.position.y + 3.0 * u, x1 - x0 - 2.0, track.size.y - 6.0 * u), Color(c, 0.42))
	for i in World.ZONES.size():
		var zx: float = track.position.x + track.size.x * float(World.ZONES[i]["center"]) / World.WORLD_SCREENS
		var zc := Vector2(zx, track.position.y + track.size.y * 0.5)
		if i == World.ZONES.size() - 1:
			_crown(zc, 9.0 * u, UiTheme.GOLD if not boss_active else UiTheme.ACCENT)
		else:
			var done: bool = i < zones_cleared
			draw_circle(zc, 5.5 * u, UiTheme.GOLD if done else Color(UiTheme.TEXT, 0.85))
			draw_arc(zc, 5.5 * u, 0.0, TAU, 14, UiTheme.BG, 1.5 * u, true)
	var hx: float = track.position.x + track.size.x * clampf(progress, 0.0, 1.0)
	var hc := Vector2(hx, track.position.y + track.size.y * 0.5)
	draw_circle(hc, 7.5 * u, UiTheme.ACCENT)
	draw_arc(hc, 7.5 * u, 0.0, TAU, 16, Color.WHITE, 2.0 * u, true)
	if district_name != "":
		draw_string(ThemeDB.fallback_font, Vector2(track.position.x, track.end.y + 18.0 * u), district_name, HORIZONTAL_ALIGNMENT_CENTER, track.size.x, int(12.0 * u), Color(UiTheme.TEXT, 0.75))


func _crown(c: Vector2, r: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([c + Vector2(-r, r * 0.7), c + Vector2(-r, -r * 0.6), c + Vector2(-r * 0.45, 0.0),
		c + Vector2(0.0, -r * 0.9), c + Vector2(r * 0.45, 0.0), c + Vector2(r, -r * 0.6), c + Vector2(r, r * 0.7)]), col)


func _draw_go(u: float) -> void:
	var pulse: float = 0.5 if anim_t == 0.0 else 0.5 + 0.5 * sin(anim_t * 6.0)
	var r := Rect2(size.x - 128.0 * u + 10.0 * u * pulse, go_y, 110.0 * u, 44.0 * u)
	_pill(r, Color(UiTheme.GOLD, 0.55 + 0.4 * pulse))
	_text("GO", Rect2(r.position, Vector2(r.size.x * 0.58, r.size.y)), 20.0 * u, UiTheme.TEXT_ON_ACCENT)
	UiIcons.draw(self, "forward", Rect2(r.position + Vector2(r.size.x * 0.56, 4.0 * u), Vector2(r.size.y - 8.0 * u, r.size.y - 8.0 * u)), UiTheme.TEXT_ON_ACCENT)
