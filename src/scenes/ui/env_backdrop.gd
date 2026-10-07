extends Control
const FD := preload("res://scripts/fast_draw.gd")
## Themed animated screen backdrop (Story 034): sits behind each tab screen in main.gd. Drawn
## code-only with FxLight/FxParticles at ~24 fps; static when reduce motion is on. Themes:
## home (dusk skyline + stage lights), club (cosy lounge string lights), study (library glow),
## games (arcade neon grid), pets (cosy home window + fairy lights).

const FxLight := preload("res://scripts/fx_light.gd")
const FxParticles := preload("res://scripts/fx_particles.gd")

const THEMES := {
	"home": {"top": Color("#1B1040"), "bot": Color("#6B2F78"), "a": Color("#FF5FA2"), "b": Color("#8E7CFF")},
	"club": {"top": Color("#20102F"), "bot": Color("#4A2238"), "a": Color("#FFB35E"), "b": Color("#FF5FA2")},
	"study": {"top": Color("#0E1B33"), "bot": Color("#1F3F55"), "a": Color("#FFD36E"), "b": Color("#52E8C6")},
	"games": {"top": Color("#0E0A2E"), "bot": Color("#2A1260"), "a": Color("#FF5FA2"), "b": Color("#52E8C6")},
	"pets": {"top": Color("#2A1A3F"), "bot": Color("#6E3A58"), "a": Color("#FFC15E"), "b": Color("#FF9BC0")},
}

var theme_name := "home"
var _t := 0.0
var _acc := 0.0


## Sets the theme key (home/club/study/games/pets) and redraws.
func set_theme_name(n: String) -> void:
	theme_name = n if THEMES.has(n) else "home"
	queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _process(delta: float) -> void:
	if FxLight.calm():
		return
	_t += delta
	_acc += delta
	if _acc >= 1.0 / 20.0:
		_acc = 0.0
		queue_redraw()


func _draw() -> void:
	if size.x < 8.0 or size.y < 8.0:
		return
	var th: Dictionary = THEMES[theme_name]
	var t: float = FxLight.time(_t)
	var r := Rect2(Vector2.ZERO, size)
	FxLight.gradient_rect(self, r, th["top"], th["bot"])
	var a: Color = th["a"]
	var b: Color = th["b"]
	match theme_name:
		"home": _home(r, t, a, b)
		"club": _club(r, t, a, b)
		"study": _study(r, t, a, b)
		"games": _games(r, t, a, b)
		_: _pets(r, t, a, b)
	FxLight.motes(self, r, t, 8, Color(1, 0.95, 0.85, 0.7), 2.6, theme_name.length())
	FxLight.vignette(self, r, 0.4)


func _home(r: Rect2, t: float, a: Color, b: Color) -> void:
	FxParticles.sparkle_storm(self, Rect2(0, 0, r.size.x, r.size.y * 0.4), t, 10, Color("#FFF3C9"), 5.0)
	FxLight.halo(self, Vector2(r.size.x * 0.5, r.size.y * 0.72), r.size.x * 0.9, a, 0.35, r.size.y * 0.18)
	for i in 3:
		FxLight.shaft(self, Vector2(r.size.x * (0.15 + 0.35 * i), -10), PI * 0.5 + (0.3 - 0.3 * i), r.size.y * 0.85, 150.0, a if i % 2 == 0 else b, 0.12, t, float(i))
	_skyline(r, Color("#1A0F38"), 0.72, 9, 0.2, a)
	_skyline(r, Color("#120A2B"), 0.82, 5, 0.3, b)


func _skyline(r: Rect2, col: Color, base: float, seed_v: int, hfrac: float, win: Color) -> void:
	var x := 0.0
	var i := 0
	var by: float = r.size.y * base
	while x < r.size.x:
		var w: float = 34.0 + 40.0 * FxLight.hash01(i, seed_v)
		var h: float = r.size.y * (0.04 + hfrac * FxLight.hash01(i, seed_v + 1))
		draw_rect(Rect2(x, by - h, w, r.size.y - by + h), col)
		for k in int(h / 20.0):
			if FxLight.hash01(i * 9 + k, seed_v + 2) > 0.55:
				draw_rect(Rect2(x + 6.0 + 12.0 * float(k % 2), by - h + 6.0 + 18.0 * float(k), 5, 8), Color(win.r, win.g, win.b, 0.45))
		x += w + 3.0
		i += 1


func _club(r: Rect2, t: float, a: Color, b: Color) -> void:
	for row in 2:
		var y0: float = 60.0 + float(row) * 90.0
		var n := 7
		for i in n:
			var f: float = float(i) / float(n - 1)
			var p := Vector2(r.size.x * f, y0 + sin(f * PI) * 26.0 + 0.0)
			var col: Color = a if (i + row) % 2 == 0 else b
			FxLight.halo(self, p, 26.0, col, 0.8 + (0.2 * sin(t * 2.0 + float(i)) if t != 0.0 else 0.0))
	FxLight.halo(self, Vector2(r.size.x * 0.5, r.size.y * 0.88), r.size.x * 0.6, a, 0.3, r.size.y * 0.12)
	FxParticles.sparkle_storm(self, r, t, 8, Color("#FFD9A0"), 5.0)


func _study(r: Rect2, t: float, a: Color, b: Color) -> void:
	for i in 4:
		var sx: float = r.size.x * (0.05 + 0.3 * float(i))
		draw_rect(Rect2(sx, r.size.y * 0.25, r.size.x * 0.2, r.size.y * 0.5), Color(0.05, 0.08, 0.16, 0.55))
		for k in 5:
			draw_rect(Rect2(sx + 4.0, r.size.y * 0.25 + 16.0 + float(k) * 56.0, r.size.x * 0.2 - 8.0, 5.0), Color(0.3, 0.2, 0.15, 0.6))
	FxLight.shaft(self, Vector2(r.size.x * 0.8, -10), PI * 0.5 - 0.35, r.size.y * 0.9, 190.0, a, 0.14, t)
	FxLight.light_pool(self, Vector2(r.size.x * 0.3, r.size.y * 0.8), r.size.x * 0.6, a, 0.45, 0.3)
	FxLight.motes(self, Rect2(r.size.x * 0.3, 0, r.size.x * 0.6, r.size.y), t, 14, a, 2.4, 3)


func _games(r: Rect2, t: float, a: Color, b: Color) -> void:
	var hy: float = r.size.y * 0.55
	FxLight.halo(self, Vector2(r.size.x * 0.5, hy), r.size.x * 0.8, a, 0.4, r.size.y * 0.15)
	for i in 14:
		var f: float = float(i) / 13.0
		draw_line(Vector2(r.size.x * 0.5, hy), Vector2(r.size.x * (f * 3.0 - 1.0), r.size.y), Color(b.r, b.g, b.b, 0.28), 1.5)
	for k in 8:
		var f: float = fposmod(float(k) / 8.0 + t * 0.08, 1.0)
		var y: float = hy + (r.size.y - hy) * f * f
		draw_line(Vector2(0, y), Vector2(r.size.x, y), Color(a.r, a.g, a.b, 0.3 * f), 1.5)
	FxLight.edge_glow(self, r, b, 0.22, 34.0, t)
	FxParticles.sparkle_storm(self, Rect2(0, 0, r.size.x, hy), t, 10, b, 5.0)


func _pets(r: Rect2, t: float, a: Color, b: Color) -> void:
	var w := Rect2(r.size.x * 0.58, r.size.y * 0.1, r.size.x * 0.32, r.size.y * 0.22)
	draw_rect(w, Color("#2B2060"))
	FD.circle(self, w.position + Vector2(w.size.x * 0.65, w.size.y * 0.35), 16.0, Color("#FFF3D0"))
	draw_rect(w, Color("#7A4A5A"), false, 5.0)
	FxLight.shaft(self, w.get_center(), PI * 0.5 - 0.5, r.size.y * 0.7, 200.0, Color("#FFE9B0"), 0.12, t)
	for i in 8:
		var f: float = float(i) / 7.0
		FxLight.halo(self, Vector2(r.size.x * f, 40.0 + sin(f * 6.0) * 14.0), 18.0, a if i % 2 == 0 else b, 0.8 + (0.2 * sin(t * 2.0 + float(i)) if t != 0.0 else 0.0))
	FxLight.halo(self, Vector2(r.size.x * 0.5, r.size.y * 0.9), r.size.x * 0.9, a, 0.3, r.size.y * 0.2)
	FxParticles.petals(self, r, t, 8, Color("#FF9BC0"), 5.0, 8.0, 16.0)
