class_name UiIconsTabs
extends RefCounted
## Tab, sound and arrow icons for UiIcons (see ui_icons.gd). All take a square
## rect and a main tint; companions come from UiIconKit.

const K := preload("res://scripts/ui_icon_kit.gd")


## Speaker with sound waves (`on`) or a cross (`off`).
static func draw_sound(ci: CanvasItem, r: Rect2, tint: Color, on: bool) -> void:
	var w := K.sw(r)
	var spk: Array = [
		Vector2(0.08, 0.38), Vector2(0.28, 0.38), Vector2(0.5, 0.18),
		Vector2(0.5, 0.82), Vector2(0.28, 0.62), Vector2(0.08, 0.62),
	]
	K.poly(ci, r, spk, tint, w * 0.5)
	if on:
		K.arc(ci, r, 0.5, 0.5, 0.2, -0.75, 0.75, tint, w)
		K.arc(ci, r, 0.5, 0.5, 0.36, -0.75, 0.75, tint, w)
	else:
		var x := UiTheme.ACCENT
		K.line(ci, r, Vector2(0.66, 0.36), Vector2(0.92, 0.64), x, w)
		K.line(ci, r, Vector2(0.92, 0.36), Vector2(0.66, 0.64), x, w)


## HQ: house with a roof, door and window.
static func draw_home(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var body_col := tint.lerp(UiTheme.BG, 0.2)
	ci.draw_rect(Rect2(K.p(r, 0.2, 0.46), Vector2(0.6, 0.44) * r.size), body_col)
	var roof: Array = [Vector2(0.5, 0.08), Vector2(0.95, 0.5), Vector2(0.05, 0.5)]
	K.poly(ci, r, roof, tint, K.sw(r) * 0.8)
	var d := K.dark(tint)
	ci.draw_rect(Rect2(K.p(r, 0.42, 0.64), Vector2(0.16, 0.26) * r.size), d)
	K.circ(ci, r, 0.5, 0.38, 0.06, d)


## Club: microphone on a stand.
static func draw_club(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var w := K.sw(r)
	K.circ(ci, r, 0.5, 0.26, 0.17, tint)
	K.circ(ci, r, 0.5, 0.52, 0.17, tint)
	ci.draw_rect(Rect2(K.p(r, 0.33, 0.26), Vector2(0.34, 0.26) * r.size), tint)
	var d := K.dark(tint)
	K.line(ci, r, Vector2(0.4, 0.34), Vector2(0.6, 0.34), d, w * 0.5)
	K.line(ci, r, Vector2(0.4, 0.46), Vector2(0.6, 0.46), d, w * 0.5)
	K.arc(ci, r, 0.5, 0.5, 0.29, 0.0, PI, tint, w)
	K.line(ci, r, Vector2(0.5, 0.8), Vector2(0.5, 0.92), tint, w)
	K.line(ci, r, Vector2(0.34, 0.92), Vector2(0.66, 0.92), tint, w)


## Battle: lightning bolt.
static func draw_battle(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var bolt: Array = [
		Vector2(0.62, 0.04), Vector2(0.2, 0.56), Vector2(0.46, 0.56),
		Vector2(0.38, 0.96), Vector2(0.8, 0.42), Vector2(0.54, 0.42),
	]
	K.poly(ci, r, bolt, tint, K.sw(r) * 0.7)
	var shine: Array = [Vector2(0.58, 0.16), Vector2(0.5, 0.36), Vector2(0.44, 0.36)]
	K.poly(ci, r, shine, K.light(tint), 0.0)


## Games: game controller with d-pad and buttons.
static func draw_games(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	K.circ(ci, r, 0.24, 0.56, 0.2, tint)
	K.circ(ci, r, 0.76, 0.56, 0.2, tint)
	ci.draw_rect(Rect2(K.p(r, 0.24, 0.3), Vector2(0.52, 0.52) * r.size), tint)
	K.circ(ci, r, 0.3, 0.32, 0.12, tint)
	K.circ(ci, r, 0.7, 0.32, 0.12, tint)
	var d := K.dark(tint)
	var w := K.sw(r) * 0.8
	K.line(ci, r, Vector2(0.25, 0.54), Vector2(0.41, 0.54), d, w)
	K.line(ci, r, Vector2(0.33, 0.46), Vector2(0.33, 0.62), d, w)
	K.circ(ci, r, 0.64, 0.5, 0.055, d)
	K.circ(ci, r, 0.76, 0.6, 0.055, d)


## Study: open book with a pencil.
static func draw_study(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var left: Array = [Vector2(0.05, 0.28), Vector2(0.48, 0.36), Vector2(0.48, 0.9), Vector2(0.05, 0.82)]
	var right: Array = [Vector2(0.52, 0.36), Vector2(0.95, 0.28), Vector2(0.95, 0.82), Vector2(0.52, 0.9)]
	K.poly(ci, r, left, tint.lerp(UiTheme.BG, 0.2), K.sw(r) * 0.4)
	K.poly(ci, r, right, tint, K.sw(r) * 0.4)
	var d := K.dark(tint)
	var w := K.sw(r) * 0.5
	K.line(ci, r, Vector2(0.14, 0.45), Vector2(0.4, 0.5), d, w)
	K.line(ci, r, Vector2(0.14, 0.6), Vector2(0.4, 0.65), d, w)
	var pencil := UiTheme.GOLD
	K.line(ci, r, Vector2(0.84, 0.08), Vector2(0.62, 0.5), pencil, K.sw(r) * 1.15)
	K.circ(ci, r, 0.6, 0.54, 0.04, K.dark(pencil))


## Pets: paw print (big pad plus four toe beans).
static func draw_paw(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var pad: Array = []
	for i in 14:
		var a := TAU * float(i) / 14.0
		pad.append(Vector2(0.5 + cos(a) * 0.24, 0.66 + sin(a) * 0.2))
	K.poly(ci, r, pad, tint, K.sw(r) * 0.6)
	K.circ(ci, r, 0.2, 0.42, 0.095, tint)
	K.circ(ci, r, 0.4, 0.26, 0.1, tint)
	K.circ(ci, r, 0.6, 0.26, 0.1, tint)
	K.circ(ci, r, 0.8, 0.42, 0.095, tint)


## Food bowl with a few kibble bits on top.
static func draw_bowl(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var bowl: Array = [Vector2(0.08, 0.5), Vector2(0.92, 0.5), Vector2(0.78, 0.86), Vector2(0.22, 0.86)]
	K.poly(ci, r, bowl, tint, K.sw(r) * 0.6)
	K.circ(ci, r, 0.34, 0.38, 0.1, K.light(tint))
	K.circ(ci, r, 0.52, 0.3, 0.1, K.light(tint))
	K.circ(ci, r, 0.68, 0.4, 0.09, K.light(tint))


## Back: left-pointing arrow.
static func draw_back(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var w := K.sw(r) * 1.1
	K.polyline(ci, r, [Vector2(0.52, 0.16), Vector2(0.2, 0.5), Vector2(0.52, 0.84)], tint, w)
	K.line(ci, r, Vector2(0.24, 0.5), Vector2(0.86, 0.5), tint, w)


## Close: X mark.
static func draw_close(ci: CanvasItem, r: Rect2, tint: Color) -> void:
	var w := K.sw(r) * 1.15
	K.line(ci, r, Vector2(0.2, 0.2), Vector2(0.8, 0.8), tint, w)
	K.line(ci, r, Vector2(0.8, 0.2), Vector2(0.2, 0.8), tint, w)
