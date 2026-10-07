extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Code-drawn glowstick weapons (Story 008). One static entry point draws the whole weapon
## from the grip to the tip for the five styles in GameState.WEAPONS: "stick", "comet",
## "rod", "scepter" and "wand". Call from a CanvasItem's _draw(). Every polygon is simple.

const Shade := preload("res://scripts/hunter_shade.gd")

const STYLES: PackedStringArray = ["stick", "comet", "rod", "scepter", "wand"]
const STICK := Color("#F5EFFF")
const GOLD := Color("#FFD36E")
const GOLD_DARK := Color("#C98F2E")
const ROD := Color("#6C62A8")
const COMET_SHAFT := Color("#E4FFF8")
const WAND_SHAFT := Color("#D9CCFF")
## Grip length behind the hand, in `u` units (u = thickness / 4).
const GRIP := 6.0


## Draws the weapon `style` (unknown ids fall back to "stick"). `hand` is where the fist
## closes; the weapon starts 6u behind it and runs `length` pixels along unit vector `dir`
## to the tip (the caller passes 36 * u for the standard reach). `thickness` is the shaft
## width (4 * u), `glow` the head colour, `alpha` the view alpha, and `pulse` / `pulse_a`
## (1.0 = still) scale the halo radius and strength.
static func draw(ci: CanvasItem, style: String, hand: Vector2, dir: Vector2, length: float, thickness: float, glow: Color, alpha: float, pulse: float, pulse_a: float) -> void:
	var u: float = thickness / 4.0
	var d: Vector2 = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	var start: Vector2 = hand - d * GRIP * u
	var tip: Vector2 = start + d * length
	var n: Vector2 = d.orthogonal()
	FD.circle(ci, tip, 10.0 * u * pulse, Shade.fade(glow, 0.25 * pulse_a * alpha))
	match style:
		"comet":
			_comet(ci, start, tip, d, n, u, glow, alpha)
		"rod":
			_rod(ci, start, tip, d, n, u, glow, alpha)
		"scepter":
			_scepter(ci, start, tip, d, n, u, glow, alpha)
		"wand":
			_wand(ci, start, tip, d, n, u, glow, alpha, pulse, pulse_a)
		_:
			_shaft(ci, start, tip, u * 4.0, STICK, alpha)
			Shade.circle(ci, tip, 5.0 * u, Shade.fade(glow, alpha), u * 0.8, Shade.ink(Shade.fade(glow, alpha)))
			FD.circle(ci, tip - n * u * 1.2 - d * u * 1.2, 1.6 * u, Shade.fade(Shade.lighten(glow, 0.7), alpha))


## Outlined shaft with a lit stripe.
static func _shaft(ci: CanvasItem, a: Vector2, b: Vector2, w: float, col: Color, alpha: float) -> void:
	var c: Color = Shade.fade(col, alpha)
	ci.draw_line(a, b, Shade.ink(c), w + 1.6)
	ci.draw_line(a, b, c, w)
	var n: Vector2 = (b - a).orthogonal().normalized()
	ci.draw_line(a - n * w * 0.22, b - n * w * 0.22, Shade.fade(Shade.lighten(col, 0.6), 0.6 * alpha), maxf(1.0, w * 0.2))


## Point `o` offset by local coords (x along `d`, y along `n`).
static func _p(o: Vector2, d: Vector2, n: Vector2, x: float, y: float) -> Vector2:
	return o + d * x + n * y


## Comet Baton: bright shaft, round core head with a swept tail of fading dots.
static func _comet(ci: CanvasItem, a: Vector2, tip: Vector2, d: Vector2, n: Vector2, u: float, glow: Color, alpha: float) -> void:
	_shaft(ci, a, tip - d * 4.0 * u, u * 3.6, COMET_SHAFT, alpha)
	var tail := PackedVector2Array([_p(tip, d, n, 0.0, -4.6 * u), _p(tip, d, n, -17.0 * u, 7.0 * u), _p(tip, d, n, 0.0, 4.6 * u)])
	FD.poly(ci, tail, Shade.fade(glow, 0.45 * alpha))
	for i in range(3):
		var f: float = float(i + 1)
		FD.circle(ci, _p(tip, d, n, -(6.0 + f * 4.0) * u, (2.0 + f * 1.8) * u), (2.2 - f * 0.45) * u, Shade.fade(Shade.lighten(glow, 0.4), (0.8 - f * 0.2) * alpha))
	Shade.circle(ci, tip, 5.4 * u, Shade.fade(glow, alpha), u * 0.8, Shade.ink(Shade.fade(glow, alpha)))
	FD.circle(ci, tip + (-n - d) * u * 1.3, 2.0 * u, Shade.fade(Color.WHITE, 0.85 * alpha))


## Storm Rod: dark rod with a glowing zig-zag bolt head and tiny spark lines.
static func _rod(ci: CanvasItem, a: Vector2, tip: Vector2, d: Vector2, n: Vector2, u: float, glow: Color, alpha: float) -> void:
	_shaft(ci, a, tip - d * 6.0 * u, u * 3.8, ROD, alpha)
	var bolt := PackedVector2Array([_p(tip, d, n, -8.0 * u, 1.0 * u), _p(tip, d, n, -3.0 * u, -4.0 * u), _p(tip, d, n, -1.0 * u, 2.5 * u), _p(tip, d, n, 3.0 * u, -2.5 * u), _p(tip, d, n, 6.0 * u, 1.0 * u)])
	FD.polyline(ci, bolt, Shade.ink(Shade.fade(glow, alpha)), 4.2 * u, true)
	FD.polyline(ci, bolt, Shade.fade(glow, alpha), 3.0 * u, true)
	FD.polyline(ci, bolt, Shade.fade(Shade.lighten(glow, 0.8), 0.9 * alpha), 1.1 * u, true)
	var spark: Color = Shade.fade(Shade.lighten(glow, 0.6), 0.85 * alpha)
	ci.draw_line(_p(tip, d, n, 4.0 * u, 5.0 * u), _p(tip, d, n, 6.5 * u, 8.5 * u), spark, 1.2 * u)
	ci.draw_line(_p(tip, d, n, 1.0 * u, -6.0 * u), _p(tip, d, n, 2.0 * u, -9.5 * u), spark, 1.2 * u)
	ci.draw_line(_p(tip, d, n, 7.0 * u, -3.0 * u), _p(tip, d, n, 10.0 * u, -4.5 * u), spark, 1.2 * u)


## Solar Scepter: gold decorated shaft with collars and a sun head (disc + 8 rays).
static func _scepter(ci: CanvasItem, a: Vector2, tip: Vector2, d: Vector2, n: Vector2, u: float, glow: Color, alpha: float) -> void:
	_shaft(ci, a, tip - d * 5.0 * u, u * 3.8, GOLD_DARK, alpha)
	var span: float = (tip - a).length()
	var gold: Color = Shade.fade(GOLD, alpha)
	for f in [0.42, 0.88]:
		var c: Vector2 = a + d * span * float(f)
		var ring := PackedVector2Array([_p(c, d, n, -1.8 * u, -3.4 * u), _p(c, d, n, 1.8 * u, -3.4 * u), _p(c, d, n, 1.8 * u, 3.4 * u), _p(c, d, n, -1.8 * u, 3.4 * u)])
		Shade.fill(ci, ring, gold, u * 0.7, Shade.ink(gold))
	for f in [0.62, 0.72]:
		FD.circle(ci, a + d * span * float(f), 1.3 * u, Shade.fade(glow, alpha))
	for i in range(8):
		var ang: float = TAU * float(i) / 8.0
		var r: Vector2 = Vector2(cos(ang), sin(ang))
		ci.draw_line(tip + r * 5.6 * u, tip + r * 9.0 * u, gold, 1.8 * u)
	Shade.circle(ci, tip, 5.4 * u, gold, u * 0.8, Shade.ink(gold))
	FD.circle(ci, tip, 3.2 * u, Shade.fade(glow, alpha))
	FD.circle(ci, tip + (-n - d) * u * 1.0, 1.2 * u, Shade.fade(Color.WHITE, 0.8 * alpha))


## Galaxy Wand: lilac shaft, five-point star head and three wiggling orbiting sparkles.
static func _wand(ci: CanvasItem, a: Vector2, tip: Vector2, d: Vector2, n: Vector2, u: float, glow: Color, alpha: float, pulse: float, pulse_a: float) -> void:
	_shaft(ci, a, tip - d * 5.0 * u, u * 3.4, WAND_SHAFT, alpha)
	var star := PackedVector2Array()
	var base_ang: float = d.angle()
	for i in range(10):
		var r: float = (7.4 if i % 2 == 0 else 3.1) * u
		var ang: float = base_ang + TAU * float(i) / 10.0
		star.append(tip + Vector2(cos(ang), sin(ang)) * r)
	var col: Color = Shade.fade(glow, alpha)
	Shade.fill(ci, star, col, u * 0.8, Shade.ink(col))
	FD.circle(ci, tip, 2.0 * u, Shade.fade(Shade.lighten(glow, 0.75), alpha))
	var wob: float = (pulse - 1.0) * 14.0 + (pulse_a - 1.0) * 1.5
	for i in range(3):
		var ang: float = 0.6 + TAU * float(i) / 3.0 + wob
		var rad: float = (10.5 + float(i) * 0.8) * u
		var sp: Vector2 = tip + Vector2(cos(ang), sin(ang)) * rad
		var s: float = (1.6 - float(i) * 0.25) * u
		var sc: Color = Shade.fade(Shade.lighten(glow, 0.7), 0.9 * alpha)
		ci.draw_line(sp - Vector2(s * 1.6, 0.0), sp + Vector2(s * 1.6, 0.0), sc, maxf(1.0, s * 0.7))
		ci.draw_line(sp - Vector2(0.0, s * 1.6), sp + Vector2(0.0, s * 1.6), sc, maxf(1.0, s * 0.7))
