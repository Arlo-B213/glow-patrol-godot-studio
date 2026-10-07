extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Stateless, code-drawn particle emitters (Story 034). Each call recomputes every particle from
## a hash of its index and the time `t`, so there is no node, no array and no per-frame
## allocation to manage. Counts are hard-capped (MAX_COUNT). Pass t = 0.0 (or FxLight.time(t))
## for the reduce-motion static look. All draw onto any CanvasItem inside _draw().

const FxLight := preload("res://scripts/fx_light.gd")

const MAX_COUNT := 48
const CONFETTI := [Color("#FF5FA2"), Color("#FFC15E"), Color("#52E8C6"), Color("#8E7CFF"), Color("#FFFFFF")]


static func _h(i: int, salt: int) -> float:
	return FxLight.hash01(i, salt)


## Confetti burst from `origin`; `age` is seconds since the burst (0..~1.6). Pieces arc out and fall.
static func confetti(ci: CanvasItem, origin: Vector2, age: float, count: int = 28, power: float = 260.0, scale: float = 1.0) -> void:
	if age <= 0.0 or age > 1.8:
		return
	var fade: float = clampf((1.8 - age) / 0.6, 0.0, 1.0)
	for i in mini(count, MAX_COUNT):
		var ang: float = -PI * 0.5 + (_h(i, 1) - 0.5) * 2.4
		var sp: float = power * (0.4 + _h(i, 2) * 0.8)
		var pos := origin + Vector2(cos(ang) * sp * age, sin(ang) * sp * age + 380.0 * age * age) * scale
		var spin: float = age * (6.0 + _h(i, 3) * 8.0) + float(i)
		var s: float = (3.0 + _h(i, 4) * 3.0) * scale
		var dir := Vector2(cos(spin), sin(spin)) * s
		var col: Color = CONFETTI[i % CONFETTI.size()]
		col.a = fade
		ci.draw_line(pos - dir, pos + dir, col, s * 0.9)


## Sparkle storm: twinkling four-point stars rising and swirling through `rect` (celebrations).
static func sparkle_storm(ci: CanvasItem, rect: Rect2, t: float, count: int = 24, col: Color = Color("#FFE9A0"), size: float = 8.0) -> void:
	for i in mini(count, MAX_COUNT):
		var x: float = rect.position.x + _h(i, 5) * rect.size.x + sin(t * 1.3 + float(i)) * 12.0
		var y: float = rect.position.y + fposmod(_h(i, 6) * rect.size.y - t * (30.0 + _h(i, 7) * 40.0), rect.size.y)
		var tw: float = 0.6 if t == 0.0 else maxf(0.0, sin(t * (2.0 + _h(i, 8) * 3.0) + float(i) * 2.0))
		if tw < 0.05:
			continue
		sparkle(ci, Vector2(x, y), size * (0.5 + _h(i, 9)) * tw, col)


## One four-point twinkle star with a soft halo.
static func sparkle(ci: CanvasItem, c: Vector2, r: float, col: Color) -> void:
	FxLight.halo(ci, c, r * 2.2, col, 0.5)
	var pts := PackedVector2Array()
	for k in 8:
		var a: float = TAU * float(k) / 8.0 - PI * 0.5
		var rr: float = r if k % 2 == 0 else r * 0.22
		pts.append(c + Vector2(cos(a), sin(a)) * rr)
	FD.poly(ci, pts, Color(1, 1, 1, 0.92).lerp(col, 0.25))


## Falling petals / leaves with sideways sway. `wind` pushes them sideways (px/s), `fall` is px/s.
static func petals(ci: CanvasItem, rect: Rect2, t: float, count: int, col: Color, size: float = 5.0, wind: float = 18.0, fall: float = 34.0, drift_x: float = 0.0) -> void:
	for i in mini(count, MAX_COUNT):
		var sp: float = fall * (0.7 + _h(i, 11) * 0.7)
		var y: float = rect.position.y + fposmod(_h(i, 12) * rect.size.y + t * sp, rect.size.y)
		var x: float = rect.position.x + fposmod(_h(i, 13) * rect.size.x + t * wind * (0.6 + _h(i, 14)) - drift_x + sin(t * 1.2 + float(i) * 1.9) * 16.0, rect.size.x)
		var ang: float = t * (1.0 + _h(i, 15) * 2.0) + float(i)
		var s: float = size * (0.6 + _h(i, 16) * 0.7)
		var d := Vector2(cos(ang), sin(ang))
		var n := Vector2(-d.y, d.x) * s * 0.5 * (0.3 + 0.7 * absf(sin(ang * 1.3)))
		var c := Vector2(x, y)
		FD.poly(ci, PackedVector2Array([c - d * s, c + n, c + d * s, c - n]), Color(col.r, col.g, col.b, col.a * (0.55 + 0.4 * _h(i, 17))))


## Slanted rain streaks across `rect` (drift_x shifts them with a scrolling camera).
static func rain(ci: CanvasItem, rect: Rect2, t: float, count: int, col: Color, len: float = 14.0, drift_x: float = 0.0) -> void:
	var slant := Vector2(-0.22, 1.0).normalized()
	for i in mini(count, MAX_COUNT * 2):
		var sp: float = 520.0 + _h(i, 21) * 260.0
		var y: float = rect.position.y + fposmod(_h(i, 22) * rect.size.y + t * sp, rect.size.y)
		var x: float = rect.position.x + fposmod(_h(i, 23) * rect.size.x - drift_x - (y - rect.position.y) * 0.22, rect.size.x)
		ci.draw_line(Vector2(x, y), Vector2(x, y) + slant * len * (0.6 + _h(i, 24) * 0.8), col, 1.2)


## Rising embers / glow motes that cool as they climb (steam-lit alleys, lanterns).
static func embers(ci: CanvasItem, rect: Rect2, t: float, count: int, col: Color, size: float = 2.5) -> void:
	for i in mini(count, MAX_COUNT):
		var life: float = fposmod(t * (0.12 + _h(i, 31) * 0.12) + _h(i, 32), 1.0)
		var x: float = rect.position.x + _h(i, 33) * rect.size.x + sin(life * 9.0 + float(i)) * 10.0
		var y: float = rect.end.y - life * rect.size.y
		var a: float = sin(life * PI)
		FxLight.halo(ci, Vector2(x, y), size * 3.5, col, 0.4 * a)
		FD.circle(ci, Vector2(x, y), size * 0.6, Color(1, 1, 1, 0.8 * a))


## Firework bursts above `rect` (each one cycles on its own timer). Static frame when t = 0.
static func fireworks(ci: CanvasItem, rect: Rect2, t: float, shells: int = 3, spokes: int = 14) -> void:
	for s in mini(shells, 6):
		var period: float = 3.4 + _h(s, 41) * 1.6
		var ph: float = fposmod(t + _h(s, 42) * period, period) / period if t != 0.0 else 0.35
		if ph > 0.7:
			continue
		var e: float = ph / 0.7
		var c := Vector2(rect.position.x + (0.15 + 0.7 * _h(s * 7 + int(t / period), 43)) * rect.size.x, rect.position.y + (0.1 + 0.4 * _h(s, 44)) * rect.size.y)
		var col: Color = CONFETTI[(s + int(t / period)) % 4]
		var a: float = (1.0 - e) * (1.0 if e < 0.8 else 0.6)
		FxLight.halo(ci, c, 70.0 * e + 12.0, col, 0.35 * a)
		for k in spokes:
			var ang: float = TAU * float(k) / float(spokes)
			var d := Vector2(cos(ang), sin(ang))
			var rad: float = 58.0 * (1.0 - pow(1.0 - e, 2.0))
			var p := c + d * rad + Vector2(0, 16.0 * e * e)
			ci.draw_line(p - d * 7.0 * (1.0 - e), p, Color(col.r, col.g, col.b, a), 2.0)
			FD.circle(ci, p, 1.8, Color(1, 1, 1, a))
