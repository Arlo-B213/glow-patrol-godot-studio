extends RefCounted
## Expressive faces for the gloom characters (Story 031): glowing eyes with sclera, iris, pupil and
## highlights, thick brows, a nose hint, cheeks and mouths with fangs, teeth and tongue. One
## entry point, `draw`, picks the look from a `Kit.Mood`. Local units, see gloom_kit.gd.

const Kit := preload("res://scenes/battle/gloom_kit.gd")
const Shade := preload("res://scripts/hunter_shade.gd")

## Brow tilt per mood: positive = angry (inner end low), negative = worried/raised.
const TILT := {
	Kit.Mood.IDLE: 0.18, Kit.Mood.ANGRY: 0.95, Kit.Mood.HURT: -0.5, Kit.Mood.STUNNED: -0.1,
	Kit.Mood.DYING: -0.7, Kit.Mood.SMILE: -0.25, Kit.Mood.SLEEPY: -0.2, Kit.Mood.GIGGLE: -0.35,
	Kit.Mood.SNEEZE: 0.25, Kit.Mood.ROAR: 1.0, Kit.Mood.GRUMP: 0.6,
}


## Draws a face centred at local (cx, cy), half-width `hw`, half-height `hh`. `spec` keys (all
## optional): skin (Color), brow (Color), eye (iris Color), eye_scale, big_side (-1/1: one huge
## monocle eye, the other tiny), nose (scale), fang (bool), blush (alpha), brow_w (thickness scale),
## lid (0..1 forced eyelid closure).
static func draw(r: Kit.Rig, cx: float, cy: float, hw: float, hh: float, mood: int, spec: Dictionary = {}) -> void:
	var skin: Color = spec.get("skin", Color("#4A3A7A"))
	var eye_col: Color = spec.get("eye", r.glow)
	var brow_col: Color = spec.get("brow", Shade.darken(skin, 0.6))
	var es: float = float(spec.get("eye_scale", 1.0))
	var big_side: float = float(spec.get("big_side", 0.0))
	var lid: float = float(spec.get("lid", 0.0))
	if mood == Kit.Mood.SLEEPY:
		lid = maxf(lid, 0.6 - r.breath * 0.12)
	if r.blink:
		lid = 1.0
	var ey: float = cy + hh * 0.02
	for side in [-1.0, 1.0]:
		var sd: float = side
		var sc: float = es
		if big_side != 0.0:
			sc *= 1.4 if sd == big_side else 0.55
		var ex: float = cx + sd * hw * 0.42
		var erx: float = hw * 0.26 * sc
		var ery: float = hw * 0.32 * sc
		_eye(r, sd, ex, ey, erx, ery, mood, eye_col, skin, lid)
		_brow(r, sd, ex, ey - ery * 1.2, erx, ery, mood, brow_col, float(spec.get("brow_w", 1.0)), hh, big_side)
		if big_side == sd:
			_monocle(r, ex, ey, erx, ery)
	if r.detail:
		_nose(r, cx, cy + hh * 0.26, hw, skin, float(spec.get("nose", 1.0)))
	var blush: float = float(spec.get("blush", 0.3))
	if mood == Kit.Mood.SMILE or mood == Kit.Mood.GIGGLE:
		blush = maxf(blush, 0.55)
	if blush > 0.0 and r.detail:
		for side in [-1.0, 1.0]:
			r.ell(cx + float(side) * hw * 0.66, cy + hh * 0.38, hw * 0.16, hw * 0.09, Color("#FF6FA8", blush), false, false)
	_mouth(r, cx, cy + hh * 0.56, hw, hh, mood, bool(spec.get("fang", true)), skin)


static func _eye(r: Kit.Rig, sd: float, ex: float, ey: float, erx: float, ery: float, mood: int, eye_col: Color, skin: Color, lid: float) -> void:
	var w: float = maxf(1.0, r.ow)
	match mood:
		Kit.Mood.HURT, Kit.Mood.SNEEZE:
			var inner: float = ex - sd * erx * 0.7
			var outer: float = ex + sd * erx * 1.0
			r.polyline([Vector2(outer, ey - ery * 0.9), Vector2(inner, ey), Vector2(outer, ey + ery * 0.9)], 2.4, eye_col)
			return
		Kit.Mood.DYING:
			r.line(Vector2(ex - erx * 0.9, ey - ery * 0.9), Vector2(ex + erx * 0.9, ey + ery * 0.9), 2.4, eye_col)
			r.line(Vector2(ex + erx * 0.9, ey - ery * 0.9), Vector2(ex - erx * 0.9, ey + ery * 0.9), 2.4, eye_col)
			return
		Kit.Mood.SMILE, Kit.Mood.GIGGLE:
			r.arc(ex, ey + ery * 0.35, erx * 0.95, PI, TAU, 2.6, Color("#FFF7D6"))
			return
	if r.detail:
		r.disc(ex, ey, erx * 1.75, Color(eye_col, 0.2))
	r.ell(ex, ey, erx, ery, Kit.EYE_WHITE, false)
	var spin: float = 0.0 if r.calm else r.t * 0.3
	if mood == Kit.Mood.STUNNED:
		var sp: Array = []
		for i in 14:
			var a: float = spin + float(i) * 0.7
			var rr: float = ery * 0.9 * float(i) / 13.0
			sp.append(Vector2(ex + cos(a) * rr * (erx / ery), ey + sin(a) * rr))
		r.polyline(sp, 1.4, Kit.INK)
	else:
		var lx: float = ex + r.look * erx * 0.32
		r.circ(lx, ey + ery * 0.05, ery * 0.72, eye_col, false)
		r.circ(lx + r.look * erx * 0.08, ey + ery * 0.05, ery * 0.36, Kit.BLACKOUT, false)
		r.disc(lx - erx * 0.28, ey - ery * 0.3, ery * 0.2, Color.WHITE)
		if r.detail:
			r.disc(lx + erx * 0.22, ey + ery * 0.28, ery * 0.1, Color(1, 1, 1, 0.8))
	if lid > 0.02:
		var yl: float = ey - ery + 2.0 * ery * lid
		var quad: Array = [Vector2(ex - erx * 1.2, ey - ery * 1.25), Vector2(ex + erx * 1.2, ey - ery * 1.25), Vector2(ex + erx * 1.2, yl), Vector2(ex - erx * 1.2, yl)]
		r.poly(quad, skin, false)
		r.line(Vector2(ex - erx * 1.05, yl), Vector2(ex + erx * 1.05, yl), 1.6, Kit.BLACKOUT)
	w = 0.0


static func _brow(r: Kit.Rig, sd: float, ex: float, by: float, erx: float, ery: float, mood: int, col: Color, thick: float, hh: float, big_side: float) -> void:
	if mood == Kit.Mood.DYING:
		return
	var tilt: float = float(TILT.get(mood, 0.2))
	var th: float = hh * 0.11 * thick
	var xi: float = ex - sd * erx * 1.05
	var xo: float = ex + sd * erx * 1.2
	var yi: float = by + tilt * ery * 0.75
	var yo: float = by - tilt * ery * 0.55
	if big_side != 0.0 and sd != big_side:
		yi -= ery * 0.3
	r.poly([Vector2(xi, yi - th), Vector2(xo, yo - th), Vector2(xo, yo + th), Vector2(xi, yi + th)], col, false)


static func _monocle(r: Kit.Rig, ex: float, ey: float, erx: float, ery: float) -> void:
	r.ci.draw_arc(r.p(ex, ey), maxf(erx, ery) * 1.22 * r.k, 0.0, TAU, 18, r.c(Color("#FFD36E")), maxf(1.6, r.ow * 1.2), true)
	r.ci.draw_arc(r.p(ex, ey), maxf(erx, ery) * 0.95 * r.k, 3.6, 4.9, 6, r.c(Color(1, 1, 1, 0.8)), maxf(1.0, r.ow * 0.8), true)
	r.line(Vector2(ex - erx * 0.8, ey + ery * 1.15), Vector2(ex - erx * 1.4, ey + ery * 3.2), 0.9, Color("#FFD36E"))
	r.n += 2


static func _nose(r: Kit.Rig, cx: float, ny: float, hw: float, skin: Color, scale: float) -> void:
	r.ell(cx, ny, hw * 0.1 * scale, hw * 0.075 * scale, Shade.darken(skin, 0.3), false, false)
	r.disc(cx - hw * 0.03 * scale, ny - hw * 0.03 * scale, hw * 0.025 * scale, Color(1, 1, 1, 0.5))


static func _mouth(r: Kit.Rig, cx: float, my: float, hw: float, hh: float, mood: int, fang: bool, skin: Color) -> void:
	var mw: float = hw * 0.4
	var dark: Color = Kit.BLACKOUT
	match mood:
		Kit.Mood.IDLE:
			var pts: Array = []
			for i in 7:
				var f: float = float(i) / 6.0
				pts.append(Vector2(cx - mw + 2.0 * mw * f, my - hh * 0.05 + sin(f * PI) * hh * 0.17))
			r.polyline(pts, 2.2, dark)
			if fang:
				for sd in [-1.0, 1.0]:
					var fx: float = cx + float(sd) * mw * 0.55
					r.poly([Vector2(fx - hw * 0.05, my + hh * 0.06), Vector2(fx + hw * 0.05, my + hh * 0.06), Vector2(fx, my + hh * 0.26)], Kit.TOOTH, false)
		Kit.Mood.ANGRY, Kit.Mood.ROAR:
			var big: float = 1.35 if mood == Kit.Mood.ROAR else 1.0
			var mh: float = hh * 0.32 * big
			r.poly([Vector2(cx - mw * big, my - mh * 0.3), Vector2(cx + mw * big, my - mh * 0.3), Vector2(cx + mw * 0.75 * big, my + mh), Vector2(cx - mw * 0.75 * big, my + mh)], dark, false)
			r.ell(cx, my + mh * 0.75, mw * 0.5, mh * 0.3, Kit.TONGUE, false, false)
			var tp: Array = [Vector2(cx - mw * big, my - mh * 0.3), Vector2(cx + mw * big, my - mh * 0.3)]
			for i in range(5, -1, -1):
				var f2: float = float(i) / 5.0
				tp.append(Vector2(cx - mw * big + 2.0 * mw * big * f2, my - mh * 0.3 + (mh * 0.5 if i % 2 == 1 else mh * 0.12)))
			r.poly(tp, Kit.TOOTH, false)
		Kit.Mood.HURT, Kit.Mood.SNEEZE:
			var o: float = 0.7 + (0.0 if r.calm else sin(r.t * 0.8) * 0.15)
			r.ell(cx, my + hh * 0.08, mw * 0.55 * o, hh * 0.22 * o, dark, false, false)
			r.ell(cx, my + hh * 0.17, mw * 0.35 * o, hh * 0.08 * o, Kit.TONGUE, false, false)
		Kit.Mood.STUNNED:
			var wv: Array = []
			for i in 8:
				wv.append(Vector2(cx - mw * 0.8 + mw * 1.6 * float(i) / 7.0, my + (hh * 0.06 if i % 2 == 0 else -hh * 0.06)))
			r.polyline(wv, 2.2, dark)
			r.ell(cx + mw * 0.5, my + hh * 0.15, mw * 0.18, hh * 0.1, Kit.TONGUE, false, false)
		Kit.Mood.DYING:
			r.ell(cx, my + hh * 0.05, mw * 0.5, hh * 0.15, dark, false, false)
			r.ell(cx + mw * 0.35, my + hh * 0.2, mw * 0.2, hh * 0.15, Kit.TONGUE, false, false)
		Kit.Mood.SMILE:
			r.arc(cx, my - hh * 0.12, mw * 0.8, 0.35, PI - 0.35, 2.4, dark)
		Kit.Mood.SLEEPY:
			var o2: float = 0.5 + r.breath * 0.5
			r.ell(cx, my + hh * 0.06, mw * 0.28 * o2, hh * 0.12 * o2, dark, false, false)
		Kit.Mood.GIGGLE:
			r.poly([Vector2(cx - mw, my - hh * 0.08), Vector2(cx + mw, my - hh * 0.08), Vector2(cx + mw * 0.6, my + hh * 0.3), Vector2(cx, my + hh * 0.38), Vector2(cx - mw * 0.6, my + hh * 0.3)], dark, false)
			r.ell(cx, my + hh * 0.28, mw * 0.4, hh * 0.1, Kit.TONGUE, false, false)
		Kit.Mood.GRUMP:
			r.arc(cx, my + hh * 0.42, mw * 0.85, PI + 0.4, TAU - 0.4, 2.8, dark)
			r.poly([Vector2(cx - hw * 0.05, my + hh * 0.02), Vector2(cx + hw * 0.05, my + hh * 0.02), Vector2(cx + hw * 0.03, my - hh * 0.12), Vector2(cx - hw * 0.03, my - hh * 0.12)], Kit.TOOTH, false)
	skin.a = skin.a
