extends RefCounted
## Cosmetic accessories for PetArt (Story 033): bow, star crown, scarf, headphones and
## sunglasses, drawn on every species from the head/eye/neck anchors the species body
## records in the context (a_hc, a_hrx, a_hry, a_eye, a_eyedx, a_eyer, a_neck, a_nw).
## Colours and ids come from GameState.PET_ACCESSORIES (p["acc_col"]).

const Shade := preload("res://scripts/hunter_shade.gd")


static func draw(ci: CanvasItem, p: Dictionary, id: String) -> void:
	match id:
		"bow": _bow(ci, p)
		"crown": _crown(ci, p)
		"scarf": _scarf(ci, p)
		"headphones": _headphones(ci, p)
		"sunglasses": _glasses(ci, p)


static func _bow(ci: CanvasItem, p: Dictionary) -> void:
	var col: Color = p["acc_col"]
	var hc: Vector2 = p["a_hc"]
	var rx: float = p["a_hrx"]
	var ry: float = p["a_hry"]
	var sc := rx / 22.0
	var at := Vector2(hc.x + rx * 0.62, hc.y - ry * 0.78)
	var wob: float = sin(float(p["t"]) * 2.0) * 0.04 if p["anim"] else 0.0
	for side in [-1.0, 1.0]:
		var pts: Array = []
		for v in [Vector2(0, 0), Vector2(side * 11, -7), Vector2(side * 12.5, 0), Vector2(side * 11, 7)]:
			pts.append(at + (v as Vector2).rotated(0.35 + wob) * sc)
		PetArt.cel_poly(ci, p, pts, col)
	PetArt.cel(ci, p, at.x, at.y, 3.2 * sc, 3.6 * sc, Shade.lighten(col, 0.15), 0.0, 12, false)
	PetArt.star4(ci, PetArt.q(p, at.x - 1.0, at.y - 1.5), 2.2 * float(p["k"]), Color(1, 1, 1, 0.8))


static func _crown(ci: CanvasItem, p: Dictionary) -> void:
	var col: Color = p["acc_col"]
	var hc: Vector2 = p["a_hc"]
	var rx: float = p["a_hrx"]
	var ry: float = p["a_hry"]
	var top := hc.y - ry * 0.92
	var w := rx * 0.5
	var pts: Array = [Vector2(hc.x - w, top + 5), Vector2(hc.x - w * 1.05, top - 9), Vector2(hc.x - w * 0.5, top - 2),
		Vector2(hc.x, top - 13), Vector2(hc.x + w * 0.5, top - 2), Vector2(hc.x + w * 1.05, top - 9), Vector2(hc.x + w, top + 5)]
	PetArt.cel_poly(ci, p, pts, col)
	PetArt.glow(ci, p, hc.x, top - 1.0, 2.4, Color("#FF6FA8"))
	var k: float = p["k"]
	for tip in [Vector2(hc.x - w * 1.05, top - 9), Vector2(hc.x, top - 13), Vector2(hc.x + w * 1.05, top - 9)]:
		ci.draw_circle(PetArt.q(p, (tip as Vector2).x, (tip as Vector2).y), 1.6 * k, Color(1, 1, 0.9))
	if p["anim"]:
		var ph := fmod(float(p["t"]) * 0.9, 1.0)
		PetArt.star4(ci, PetArt.q(p, hc.x + w * 1.3, top - 14.0 - ph * 4.0), 3.0 * k * sin(ph * PI), Color(1, 1, 0.8, 0.95))


static func _scarf(ci: CanvasItem, p: Dictionary) -> void:
	var col: Color = p["acc_col"]
	var nk: Vector2 = p["a_neck"]
	var nw: float = p["a_nw"]
	var k: float = p["k"]
	var band := PackedVector2Array()
	for i in 11:
		var a := PI * 0.08 + PI * 0.84 * float(i) / 10.0
		band.append(PetArt.q(p, nk.x + cos(a) * nw, nk.y + sin(a) * 4.2))
	ci.draw_polyline(band, PetArt.ol_of(col), PetArt.lw(p, 7.4), true)
	ci.draw_polyline(band, PetArt.shade_of(col), PetArt.lw(p, 5.6), true)
	ci.draw_polyline(band, col, PetArt.lw(p, 4.0), true)
	var sway: float = sin(float(p["t"]) * 3.0 - 1.0) * 1.8 if p["anim"] else 0.0
	var x0 := nk.x + nw * 0.45
	var tail: Array = [Vector2(x0, nk.y + 2), Vector2(x0 + 6.5, nk.y + 3), Vector2(x0 + 8.0 + sway, nk.y + 14), Vector2(x0 + 1.0 + sway, nk.y + 15)]
	PetArt.cel_poly(ci, p, tail, col)
	for j in 2:
		var y := nk.y + 6.0 + float(j) * 4.5
		ci.draw_line(PetArt.q(p, x0 + 0.5 + sway * 0.3, y), PetArt.q(p, x0 + 7.5 + sway * 0.6, y + 0.4), Shade.lighten(col, 0.5), 1.1, true)
	ci.draw_circle(PetArt.q(p, nk.x - nw * 0.4, nk.y + 3.0), 1.2 * k, Shade.lighten(col, 0.55))


static func _headphones(ci: CanvasItem, p: Dictionary) -> void:
	var col: Color = p["acc_col"]
	var acc: Color = p["accent"]
	var hc: Vector2 = p["a_hc"]
	var rx: float = p["a_hrx"]
	var ry: float = p["a_hry"]
	var k: float = p["k"]
	var band := PackedVector2Array()
	for i in 15:
		var a := PI * 1.12 + PI * 0.76 * float(i) / 14.0
		band.append(PetArt.q(p, hc.x + cos(a) * (rx * 1.02 + 1.0), hc.y + sin(a) * (ry * 1.04 + 1.0)))
	ci.draw_polyline(band, PetArt.ol_of(col), PetArt.lw(p, 5.4), true)
	ci.draw_polyline(band, col, PetArt.lw(p, 3.4), true)
	ci.draw_polyline(band, Shade.lighten(col, 0.35), PetArt.lw(p, 1.0), true)
	for side in [-1.0, 1.0]:
		var cx: float = hc.x + side * (rx * 1.0 + 1.0)
		var cy: float = hc.y - ry * 0.12
		PetArt.cel(ci, p, cx, cy, 5.4, 7.4, col, 0.0, 16, false)
		ci.draw_circle(PetArt.q(p, cx - side * 0.8, cy), 3.0 * k, Shade.darken(col, 0.45))
		var pulse: float = 0.6 + 0.4 * sin(float(p["t"]) * 5.0) if p["anim"] else 0.8
		ci.draw_arc(PetArt.q(p, cx - side * 0.8, cy), 3.0 * k, 0.0, TAU, 12, Shade.fade(Shade.lighten(acc, 0.4), pulse), 1.1, true)


static func _glasses(ci: CanvasItem, p: Dictionary) -> void:
	var col: Color = p["acc_col"]
	var e: Vector2 = p["a_eye"]
	var dx: float = p["a_eyedx"]
	var r: float = float(p["a_eyer"]) * 1.45
	var k: float = p["k"]
	var hc: Vector2 = p["a_hc"]
	var rx: float = p["a_hrx"]
	for side in [-1.0, 1.0]:
		ci.draw_line(PetArt.q(p, e.x + side * (dx + r * 0.95), e.y - 1.0), PetArt.q(p, hc.x + side * rx * 0.97, e.y - 2.5),
			PetArt.ol_of(col), PetArt.lw(p, 2.0), true)
	ci.draw_line(PetArt.q(p, e.x - dx + r * 0.9, e.y - 1.0), PetArt.q(p, e.x + dx - r * 0.9, e.y - 1.0), PetArt.ol_of(col), PetArt.lw(p, 2.0), true)
	for side in [-1.0, 1.0]:
		var cx: float = e.x + side * dx
		ci.draw_colored_polygon(PetArt.ell(p, cx, e.y, r * 1.12, r * 0.98, 0.0, 18), PetArt.ol_of(col))
		ci.draw_colored_polygon(PetArt.ell(p, cx, e.y, r, r * 0.86, 0.0, 18), Color("#2A1260"))
		ci.draw_colored_polygon(PetArt.ell(p, cx, e.y + r * 0.22, r * 0.9, r * 0.5, 0.0, 14), Color("#5B2FA8"))
		ci.draw_line(PetArt.q(p, cx - r * 0.55, e.y - r * 0.2), PetArt.q(p, cx - r * 0.1, e.y - r * 0.62), Color(1, 1, 1, 0.75), PetArt.lw(p, 1.5), true)
		ci.draw_line(PetArt.q(p, cx + r * 0.05, e.y - r * 0.05), PetArt.q(p, cx + r * 0.25, e.y - r * 0.3), Color(1, 1, 1, 0.5), PetArt.lw(p, 1.0), true)
	ci.draw_circle(PetArt.q(p, e.x, e.y - 1.0), 0.01 * k, Color(0, 0, 0, 0))
