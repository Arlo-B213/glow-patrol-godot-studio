extends RefCounted
## The Hiccup Hydra (Story 021): a fluffy teal puffball with three silly heads on wobbly necks. Every
## ~2.5 s one head sneezes a burst of sparkles (purely visual) and the whole puff hiccups. Called
## from the Alley Brawl view's _draw() onto a CanvasItem; `s` is the boss size like draw_boss.

const INK := Color("#1A0B33")
const BLACKOUT := Color("#0A0418")
const GOLD := Color("#FFD36E")
const SNEEZE_CYCLE := 150
const SNEEZE_LEN := 26


static func _c(col: Color, a: float) -> Color:
	return Color(col.r, col.g, col.b, col.a * a)


## 0..1 progress of the current sneeze (0 = not sneezing), from the boss age.
static func sneeze_progress(age: int) -> float:
	var ph: int = age % SNEEZE_CYCLE
	var start: int = SNEEZE_CYCLE - SNEEZE_LEN
	return 0.0 if ph < start else float(ph - start + 1) / float(SNEEZE_LEN)


## 4-point sparkle star (8 vertices, simple).
static func _star(c: Vector2, r: float, rot: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(8):
		var a: float = rot + TAU * float(i) / 8.0
		var rr: float = r if i % 2 == 0 else r * 0.38
		pts.append(c + Vector2(cos(a) * rr, sin(a) * rr))
	return pts


static func _ellipse(center: Vector2, rx: float, ry: float, points: int = 18) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(points):
		var a: float = TAU * float(i) / float(points)
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


static func draw(ci: CanvasItem, x: float, ground_y: float, s: float, flash: bool, age: int, toward: float, u: float) -> void:
	var t: float = float(age)
	var sneeze: float = sneeze_progress(age)
	var hic: float = pow(maxf(0.0, sin(t * 0.09 + 1.0)), 8.0)
	var c := Vector2(x, ground_y - s * 0.42 - absf(sin(t * 0.1)) * 3.0 * u - hic * 5.0 * u)
	var wht: float = 1.0 if flash else 0.0
	var fluff: Color = Color("#7FF0D4").lerp(Color.WHITE, wht)
	var body: Color = Color("#2FC6A8").lerp(Color.WHITE, wht)
	var head_c: Color = Color("#FFB8DA").lerp(Color.WHITE, wht)
	var squeeze: float = 1.0 + hic * 0.06

	ci.draw_circle(c, s * 0.68, Color(0.5, 1.0, 0.85, 0.13 + 0.03 * sin(t * 0.12)))
	# Feet.
	for side in [-1.0, 1.0]:
		ci.draw_colored_polygon(_ellipse(Vector2(c.x + side * s * 0.2, ground_y - s * 0.05), s * 0.15, s * 0.07, 12), body.darkened(0.35))
	# Fluffy body: a ring of bumps over a solid disc.
	var br: float = s * 0.4
	for i in range(14):
		var a: float = TAU * float(i) / 14.0 + 0.2
		var bump: float = 1.0 + sin(t * 0.05 + float(i) * 1.7) * 0.03
		ci.draw_circle(c + Vector2(cos(a) * br * 0.92 / squeeze, sin(a) * br * 0.88 * squeeze), s * 0.13 * bump, fluff)
	ci.draw_circle(c, br * 0.98, body)
	ci.draw_circle(c + Vector2(0.0, br * 0.18), br * 0.62, body.lightened(0.18))
	# Three heads on necks; head 1 is the sneezer.
	var angles := [-0.66, 0.0, 0.66]
	for i in range(3):
		var wob: float = sin(t * 0.07 + float(i) * 2.1)
		var ang: float = float(angles[i]) + wob * 0.07
		var is_sneezer: bool = i == (age / SNEEZE_CYCLE) % 3
		var reach: float = s * (0.5 if i == 1 else 0.44) + (s * 0.05 * sin(sneeze * PI) if is_sneezer else 0.0)
		var base: Vector2 = c + Vector2(sin(ang) * br * 0.6, -cos(ang) * br * 0.7)
		var tip: Vector2 = c + Vector2(sin(ang) * reach, -cos(ang) * reach - s * 0.05)
		if is_sneezer:
			tip += Vector2(toward * -sneeze * s * 0.04, sneeze * s * 0.05) * sin(sneeze * PI)
		ci.draw_line(base, tip, body, s * 0.13)
		ci.draw_line(base, tip, fluff, s * 0.06)
		var hr: float = s * (0.19 if i == 1 else 0.165)
		ci.draw_circle(tip, hr * 1.12, _c(GOLD if i == 1 else fluff, 0.9))
		ci.draw_circle(tip, hr, head_c)
		for sd in [-1.0, 1.0]:
			var e: Vector2 = tip + Vector2(sd * hr * 0.42, -hr * 0.1)
			if is_sneezer and sneeze > 0.0:
				ci.draw_line(e + Vector2(-hr * 0.2, -hr * 0.1), e + Vector2(hr * 0.2, 0.0), BLACKOUT, 2.0 * u)
				ci.draw_line(e + Vector2(-hr * 0.2, hr * 0.1), e + Vector2(hr * 0.2, 0.0), BLACKOUT, 2.0 * u)
			else:
				ci.draw_circle(e, hr * 0.25, Color.WHITE)
				ci.draw_circle(e + Vector2(toward * hr * 0.08, hr * 0.02), hr * 0.12, INK)
			ci.draw_circle(tip + Vector2(sd * hr * 0.62, hr * 0.32), hr * 0.15, Color(1.0, 0.45, 0.65, 0.5))
		if is_sneezer and sneeze > 0.0:
			ci.draw_circle(tip + Vector2(0.0, hr * 0.42), hr * 0.2 * sin(sneeze * PI) + 1.0, BLACKOUT)
			_sparkles(ci, tip + Vector2(toward * hr * 0.3, hr * 0.4), s, sneeze, toward, u)
		else:
			ci.draw_arc(tip + Vector2(0.0, hr * 0.28), hr * 0.22, 0.2, PI - 0.2, 8, BLACKOUT, 2.0 * u)
		# Tiny tuft on top of each head.
		ci.draw_colored_polygon(PackedVector2Array([
			tip + Vector2(-hr * 0.2, -hr * 0.95), tip + Vector2(hr * 0.2, -hr * 0.95), tip + Vector2(hr * 0.05 + wob * hr * 0.2, -hr * 1.5),
		]), fluff)


static func _sparkles(ci: CanvasItem, from: Vector2, s: float, p: float, toward: float, u: float) -> void:
	var cols := [Color("#FFD36E"), Color("#FF5FA2"), Color("#7FF0D4"), Color.WHITE]
	for k in range(9):
		var a: float = (float(k) / 8.0 - 0.5) * 1.5 + (0.45 if toward > 0.0 else PI - 0.45)
		var dist: float = s * (0.15 + p * (0.5 + 0.09 * float(k % 3)))
		var pos: Vector2 = from + Vector2(cos(a) * dist, sin(a) * dist * 0.7 + p * p * s * 0.12)
		var col: Color = cols[k % 4]
		ci.draw_colored_polygon(_star(pos, s * (0.05 + 0.015 * float(k % 2)) * (1.2 - p * 0.5), p * 3.0 + float(k)), _c(col, 1.0 - p * 0.7))
