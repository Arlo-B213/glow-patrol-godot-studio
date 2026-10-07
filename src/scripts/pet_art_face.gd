extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Faces for PetArt (Story 033): big glossy eyes (iris gradient, two highlights, lashes,
## blink), brows, mouths and blush for the seven expressions MOOD_NORMAL .. MOOD_SURPRISED.
## All positions are pet space; sizes follow the stage so babies get bigger eyes.

const Shade := preload("res://scripts/hunter_shade.gd")
const INK := Color("#1E0F3A")
const MOUTH := Color("#4A1238")
const TONGUE := Color("#FF7FA8")


## Both eyes (centred on x = 0, `dx` apart) plus brows for the current mood.
static func eyes(ci: CanvasItem, p: Dictionary, y: float, dx: float, r: float) -> void:
	for side in [-1.0, 1.0]:
		eye(ci, p, side * dx, y, r, side)
		_brow(ci, p, side * dx, y, r, side)


## One eye at a pet-space point; `side` is -1 (left) or 1 (right).
static func eye(ci: CanvasItem, p: Dictionary, x: float, y: float, r: float, side: float) -> void:
	var k: float = p["k"]
	var c := PetArt.q(p, x, y)
	var rr: float = r * k * (1.0 + 0.09 * float(3 - int(p["stage"])))
	var mood: int = p["mood"]
	var w := maxf(1.5, rr * 0.36)
	if mood == PetArt.MOOD_HAPPY or mood == PetArt.MOOD_EATING:
		FD.arc(ci, c + Vector2(0.0, rr * 0.5), rr * 0.95, PI * 1.1, PI * 1.9, 12, INK, w, true)
		_lashes(ci, c + Vector2(0.0, -rr * 0.1), rr, side)
		return
	if bool(p["blink"]):
		FD.arc(ci, c - Vector2(0.0, rr * 0.25), rr * 0.95, PI * 0.1, PI * 0.9, 12, INK, w, true)
		_lashes(ci, c + Vector2(0.0, rr * 0.35), rr, side)
		return
	var surprised := mood == PetArt.MOOD_SURPRISED
	var acc: Color = p["accent"]
	var iris_dark := Color(acc.r * 0.35 + 0.08, acc.g * 0.3 + 0.04, acc.b * 0.45 + 0.18)
	var iris_mid := acc.lerp(iris_dark, 0.15)
	var iris_lite := Shade.lighten(acc, 0.45)
	var look: Vector2 = p["look"]
	if mood == PetArt.MOOD_SHY:
		look = Vector2(-side * 0.5, 0.75)
	elif mood == PetArt.MOOD_EXCITED:
		look = Vector2(look.x * 0.4, -0.35)
	FD.circle(ci, c, rr * 1.12, INK)
	if surprised:
		FD.circle(ci, c, rr * 1.0, Color(1.0, 1.0, 1.0))
	var ir: float = rr * (0.62 if surprised else 0.94)
	var ic := c + look.limit_length(1.0) * rr * (0.38 if surprised else 0.16)
	FD.circle(ci, ic, ir, iris_dark)
	FD.circle(ci, ic + Vector2(0.0, ir * 0.22), ir * 0.78, iris_mid)
	FD.circle(ci, ic + Vector2(0.0, ir * 0.44), ir * 0.46, iris_lite)
	FD.circle(ci, ic, ir * (0.3 if surprised else 0.4), INK)
	FD.circle(ci, ic + Vector2(-ir * 0.36, -ir * 0.4), ir * 0.34, Color.WHITE)
	if mood == PetArt.MOOD_EXCITED:
		PetArt.star4(ci, ic + Vector2(ir * 0.34, ir * 0.38), ir * 0.34, Color(1.0, 1.0, 1.0, 0.95))
	else:
		FD.circle(ci, ic + Vector2(ir * 0.34, ir * 0.4), ir * 0.15, Color(1.0, 1.0, 1.0, 0.85))
	FD.arc(ci, c, rr * 1.06, PI * 1.05, PI * 1.95, 12, INK, w * 1.2, true)
	_lashes(ci, c, rr, side)
	if mood == PetArt.MOOD_SLEEPY:
		var lid := PackedVector2Array()
		for i in 13:
			var a := PI + PI * float(i) / 12.0
			lid.append(c + Vector2(0.0, rr * 0.18) + Vector2(cos(a), sin(a)) * rr * 1.3)
		FD.poly(ci, lid, PetArt.shade_of(p["col"]))
		ci.draw_line(c + Vector2(-rr * 1.1, rr * 0.18), c + Vector2(rr * 1.1, rr * 0.18), INK, w, true)
		_lashes(ci, c + Vector2(0.0, rr * 0.35), rr, side)


## Two or three little lashes flicking out of the outer upper corner.
static func _lashes(ci: CanvasItem, c: Vector2, rr: float, side: float) -> void:
	var base := -0.55 if side > 0.0 else PI + 0.55
	for j in 2:
		var ang := base + (0.0 if j == 0 else (0.5 if side > 0.0 else -0.5))
		var a := c + Vector2(cos(ang), sin(ang)) * rr * 1.08
		ci.draw_line(a, a + Vector2(side * rr * (0.5 - 0.15 * j), -rr * (0.38 - 0.1 * j)), INK, maxf(1.2, rr * 0.2), true)


static func _brow(ci: CanvasItem, p: Dictionary, x: float, y: float, r: float, side: float) -> void:
	var mood: int = p["mood"]
	var lift := 0.0
	var tilt := 0.0
	match mood:
		PetArt.MOOD_SHY:
			lift = 1.55
			tilt = 0.5
		PetArt.MOOD_SURPRISED:
			lift = 1.9
		PetArt.MOOD_EXCITED:
			lift = 1.6
		PetArt.MOOD_SLEEPY:
			lift = 1.0
			tilt = -0.25
		_:
			return
	var k: float = p["k"]
	var c := PetArt.q(p, x, y - r * lift - 1.5)
	var half := r * k * 0.8
	var d := Vector2(half, -half * tilt * side).rotated(0.0)
	ci.draw_line(c - Vector2(d.x, -d.y * 0.0) + Vector2(0.0, tilt * side * half * 0.5),
		c + Vector2(d.x, 0.0) - Vector2(0.0, tilt * side * half * 0.5), INK, PetArt.lw(p, 1.5), true)


## Mouth centred at a pet-space point, `w` wide. `wide` gives a long single smile.
static func mouth(ci: CanvasItem, p: Dictionary, x: float, y: float, w: float, wide: bool = false) -> void:
	var k: float = p["k"]
	var c := PetArt.q(p, x, y)
	var ww := w * k
	var mood: int = p["mood"]
	var t: float = p["t"]
	match mood:
		PetArt.MOOD_SLEEPY:
			FD.arc(ci, c + Vector2(0.0, ww * 0.1), ww * 0.14, 0.0, TAU, 10, INK, 1.4, true)
		PetArt.MOOD_HAPPY:
			_open(ci, c, ww, 0.6)
		PetArt.MOOD_EXCITED:
			_open(ci, c, ww, 0.95)
		PetArt.MOOD_EATING:
			_open(ci, c, ww, 0.12 + 0.55 * absf(sin(t * 10.0)) if p["anim"] else 0.4)
		PetArt.MOOD_SURPRISED:
			var pts := PackedVector2Array()
			for i in 14:
				var a := TAU * float(i) / 14.0
				pts.append(c + Vector2(cos(a) * ww * 0.14, sin(a) * ww * 0.22))
			FD.poly(ci, pts, MOUTH)
		PetArt.MOOD_SHY:
			var wv := PackedVector2Array()
			for i in 7:
				var f := float(i) / 6.0
				wv.append(c + Vector2((f - 0.5) * ww * 0.6, sin(f * TAU * 1.5) * ww * 0.05))
			FD.polyline(ci, wv, INK, 1.3, true)
		_:
			if wide:
				FD.arc(ci, c - Vector2(0.0, ww * 0.25), ww * 0.5, PI * 0.15, PI * 0.85, 12, INK, 1.5, true)
			else:
				FD.arc(ci, c + Vector2(-ww * 0.17, -ww * 0.12), ww * 0.2, PI * 0.05, PI * 0.9, 8, INK, 1.4, true)
				FD.arc(ci, c + Vector2(ww * 0.17, -ww * 0.12), ww * 0.2, PI * 0.1, PI * 0.95, 8, INK, 1.4, true)


static func _open(ci: CanvasItem, c: Vector2, ww: float, open: float) -> void:
	var h := ww * 0.42 * open
	var pts := PackedVector2Array()
	for i in 13:
		var a := PI * float(i) / 12.0
		pts.append(c + Vector2(cos(a) * ww * 0.42, sin(a) * h))
	FD.poly(ci, pts, MOUTH)
	if h > ww * 0.12:
		FD.poly(ci, Shade.ellipse(c + Vector2(0.0, h * 0.62), ww * 0.2, h * 0.24, 10), TONGUE)
	ci.draw_line(pts[0], pts[12], INK, 1.3, true)


## Anime-style blush: two soft patches with slanted hatch marks. `x` is the offset from centre.
static func cheeks(ci: CanvasItem, p: Dictionary, x: float, y: float, r: float) -> void:
	var mood: int = p["mood"]
	var a := 0.55 if mood == PetArt.MOOD_SHY else 0.34
	if mood == PetArt.MOOD_SHY or mood == PetArt.MOOD_HAPPY:
		a += 0.1
	for side in [-1.0, 1.0]:
		var cx: float = side * x
		FD.poly(ci, PetArt.ell(p, cx, y, r * 1.15, r * 0.75, 0.0, 14), Color(1.0, 0.45, 0.62, a * 0.5))
		FD.poly(ci, PetArt.ell(p, cx, y, r * 0.78, r * 0.5, 0.0, 12), Color(1.0, 0.4, 0.58, a))
		for j in 3:
			var a0 := PetArt.q(p, cx + (float(j) - 1.0) * r * 0.42 - r * 0.1, y + r * 0.22)
			ci.draw_line(a0, a0 + Vector2(r * 0.22, -r * 0.4) * float(p["k"]), Color(1.0, 0.3, 0.5, a + 0.2), 0.8, true)
