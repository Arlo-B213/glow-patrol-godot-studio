extends RefCounted
## Extra Alley Brawl environment layers (Story 034), called from brawl_scenery.gd: distant hills
## and gradient clouds, drifting fog, neon street spill + wet-road reflections, lantern light
## pools on the ground, bridge crowd with glow sticks, fireworks, moon shimmer, and the
## foreground weather (petals / rain / embers), shafts, vignette and grain. Positions use the
## same camera maths as brawl_scenery.gd. `t` = 0.0 draws a static scene (reduce motion).

const FxLight := preload("res://scripts/fx_light.gd")
const FxParticles := preload("res://scripts/fx_particles.gd")
const World := preload("res://scenes/battle/brawl_world.gd")
const Props := preload("res://scenes/battle/brawl_props.gd")

const FAR2_PARALLAX := 0.14
const MID_PARALLAX := 0.6


static func _c(col: Color, a: float) -> Color:
	return Color(col.r, col.g, col.b, col.a * a)


## Per-district weights [noodle, neon, bridge] 0..1 at the screen centre (soft across the blends).
static func weights(cam_x: float, size: Vector2) -> Array[float]:
	var x: float = (cam_x + size.x * 0.5) / size.x
	var out: Array[float] = []
	for d in World.DISTRICTS:
		var dist: float = maxf(maxf(float(d["from"]) - x, x - float(d["to"])), 0.0)
		out.append(clampf(1.0 - dist / (World.BLEND * 0.6), 0.0, 1.0))
	return out


## Horizon glow, gradient clouds and the far-far hills; drawn right after the sky + stars.
static func sky_extras(ci: CanvasItem, cam_x: float, size: Vector2, ground_y: float, u: float, t: float, pal: Dictionary) -> void:
	var a: Color = pal["a"]
	FxLight.halo(ci, Vector2(size.x * 0.5, ground_y - 20.0 * u), size.x * 0.75, _c(a, 0.55), 0.55, ground_y * 0.32)
	var cloud_col: Color = (pal["sky_bot"] as Color).lerp(a, 0.5).lightened(0.12)
	for i in 5:
		var span: float = size.x * 1.6
		var x: float = fposmod(FxLight.hash01(i, 61) * span - cam_x * 0.07 + t * (4.0 + float(i) * 1.5), span) - size.x * 0.3
		var y: float = ground_y * (0.1 + 0.3 * FxLight.hash01(i, 62))
		var w: float = (80.0 + 70.0 * FxLight.hash01(i, 63)) * u
		for k in 3:
			FxLight.halo(ci, Vector2(x + float(k - 1) * w * 0.5, y + float(k % 2) * 4.0 * u), w * 0.62, _c(cloud_col, 0.5), 0.5, w * 0.17)
	# Far-far hills (very slow), tinted from the sky so they melt into the horizon.
	var off: float = cam_x * FAR2_PARALLAX
	var hill: Color = (pal["far"] as Color).lerp(pal["sky_bot"], 0.55)
	var pts := PackedVector2Array()
	var step: float = 36.0 * u
	var x0: float = -fposmod(off, step) - step
	var xx: float = x0
	pts.append(Vector2(x0, ground_y))
	while xx <= size.x + step:
		var wx: float = xx + off
		var h: float = ground_y * (0.2 + 0.1 * sin(wx * 0.006) + 0.07 * sin(wx * 0.017 + 1.3) + 0.03 * sin(wx * 0.05))
		pts.append(Vector2(xx, ground_y - h))
		xx += step
	pts.append(Vector2(xx, ground_y))
	ci.draw_colored_polygon(pts, _c(hill, 0.85))
	FxLight.fog_band(ci, 0.0, size.x, ground_y - 110.0 * u, 100.0 * u, _c(a.lerp(Color.WHITE, 0.3), 0.14 + (0.05 * sin(t * 0.5) if t != 0.0 else 0.0)))


## Moon/water shimmer, fireworks, glowing windows bleed and the bridge crowd; after the mid row.
static func mid_extras(ci: CanvasItem, cam_x: float, size: Vector2, ground_y: float, u: float, t: float, pal: Dictionary) -> void:
	var w: Array[float] = weights(cam_x, size)
	var slot: float = 156.0 * u
	var off: float = cam_x * MID_PARALLAX
	var first: int = int(floor(off / slot))
	var last: int = int(floor((off + size.x) / slot))
	for i in range(first, last + 1):
		var x: float = float(i) * slot - off
		var d: int = World.district_at(x + slot * 0.5 + cam_x, size.x)
		if d == 0:
			# Warm window / lantern spill bleeding out of the shopfronts.
			FxLight.halo(ci, Vector2(x + slot * 0.5, ground_y - 54.0 * u), slot * 0.62, _c(pal["a"], 0.5), 0.4 + (0.1 * sin(t * 3.0 + float(i)) if t != 0.0 else 0.0), 52.0 * u)
		elif d == 1:
			var neon: Color = pal["a"] if FxLight.hash01(i, 14) > 0.45 else pal["b"]
			var flick: float = 1.0 if t == 0.0 else 0.8 + 0.2 * sin(t * 5.0 + float(i) * 3.0)
			var h: float = (130.0 + 56.0 * FxLight.hash01(i, 13)) * u
			FxLight.halo(ci, Vector2(x + slot * 0.5, ground_y - h + 35.0 * u), slot * 0.85, _c(neon, 0.7), 0.5 * flick, 70.0 * u)
		else:
			_crowd(ci, x, slot, ground_y, u, t, i, pal)
	if w[2] > 0.3:
		var mx: float = size.x * 0.74 - cam_x * 0.04
		FxLight.reflection(ci, mx, ground_y - 96.0 * u, 62.0 * u, 34.0 * u, Color(0.9, 0.95, 1.0, 0.55), w[2], t)
		FxParticles.fireworks(ci, Rect2(0, 0, size.x, ground_y * 0.55), t, 3)


static func _crowd(ci: CanvasItem, x: float, slot: float, ground_y: float, u: float, t: float, i: int, pal: Dictionary) -> void:
	var dark := Color("#0A1230")
	for k in 4:
		var h1: float = FxLight.hash01(i * 4 + k, 71)
		var px: float = x + slot * (0.1 + 0.8 * float(k) / 3.0) + (h1 - 0.5) * 12.0 * u
		var bob: float = 0.0 if t == 0.0 else sin(t * 4.0 + h1 * 10.0) * 2.0 * u
		var by: float = ground_y - 34.0 * u + bob
		ci.draw_rect(Rect2(px - 5.0 * u, by - 18.0 * u, 10.0 * u, 18.0 * u), dark)
		ci.draw_circle(Vector2(px, by - 23.0 * u), 5.0 * u, dark)
		if h1 > 0.35:
			var wave: float = 0.0 if t == 0.0 else sin(t * 5.0 + h1 * 7.0) * 0.5
			var tip := Vector2(px + 8.0 * u + wave * 10.0 * u, by - 40.0 * u)
			ci.draw_line(Vector2(px + 3.0 * u, by - 14.0 * u), tip, dark, 2.0 * u)
			var gc: Color = pal["a"] if h1 > 0.65 else Color("#FF5FA2")
			FxLight.bloom(ci, tip, 11.0 * u, gc, 0.9)


## Road detail, neon spill, wet reflections and lantern light pools; after the floor, before props.
static func ground_extras(ci: CanvasItem, cam_x: float, size: Vector2, ground_y: float, u: float, t: float, pal: Dictionary) -> void:
	var road_h: float = size.y - ground_y
	# Horizon haze and a darker kerb strip give the road depth.
	FxLight.gradient_rect(ci, Rect2(0, ground_y, size.x, road_h * 0.22), _c((pal["sky_bot"] as Color).lightened(0.1), 0.32), _c(pal["floor"], 0.0))
	ci.draw_rect(Rect2(0, ground_y + 3.0 * u, size.x, 7.0 * u), Color(0, 0, 0, 0.22))
	FxLight.gradient_rect(ci, Rect2(0, size.y - road_h * 0.3, size.x, road_h * 0.3), Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.3))
	# Cracks, manholes and crosswalk stripes (parallax 1.0, culled).
	var step: float = 210.0 * u
	var first: int = int(floor(cam_x / step)) - 1
	var last: int = int(floor((cam_x + size.x) / step)) + 1
	var w: Array[float] = weights(cam_x, size)
	for i in range(first, last + 1):
		var x: float = float(i) * step - cam_x
		var h1: float = FxLight.hash01(i, 81)
		var y: float = ground_y + road_h * (0.34 + 0.4 * FxLight.hash01(i, 82))
		if h1 > 0.6:
			ci.draw_arc(Vector2(x, y), 15.0 * u, 0.0, TAU, 16, _c(pal["floor_line"], 0.22), 2.0 * u, true)
			ci.draw_arc(Vector2(x, y), 9.0 * u, 0.0, TAU, 12, Color(0, 0, 0, 0.25), 2.0 * u, true)
		elif h1 > 0.25:
			ci.draw_polyline(PackedVector2Array([Vector2(x, y), Vector2(x + 18.0 * u, y + 5.0 * u), Vector2(x + 30.0 * u, y + 2.0 * u), Vector2(x + 52.0 * u, y + 9.0 * u)]), Color(0, 0, 0, 0.3), 1.6 * u)
		else:
			for s in 4:
				ci.draw_rect(Rect2(x + float(s) * 16.0 * u, ground_y + road_h * 0.55, 9.0 * u, road_h * 0.2), Color(1, 1, 1, 0.08))
	# Neon spill on the street (Neon Crossing) alternating pink / teal with wet streaks.
	if w[1] > 0.05:
		var nstep: float = 260.0 * u
		var n0: int = int(floor(cam_x / nstep)) - 1
		var n1: int = int(floor((cam_x + size.x) / nstep)) + 1
		for i in range(n0, n1 + 1):
			var x: float = (float(i) + 0.5) * nstep - cam_x
			var col: Color = pal["a"] if i % 2 == 0 else pal["b"]
			var fl: float = 1.0 if t == 0.0 else 0.85 + 0.15 * sin(t * 5.0 + float(i) * 2.3)
			FxLight.light_pool(ci, Vector2(x, ground_y + road_h * 0.35), 150.0 * u, col, 0.55 * w[1] * fl, 0.26)
			FxLight.reflection(ci, x, ground_y + 10.0 * u, road_h * 0.6, 22.0 * u, col, 0.4 * w[1] * fl, t)
	# Lantern pools: each lamppost throws a warm pool that tints the ground the fighters stand on.
	for p in Props.PROPS:
		if String(p["k"]) != "lamp" and String(p["k"]) != "cart":
			continue
		var lx: float = float(p["x"]) * size.x - cam_x
		if lx < -170.0 * u or lx > size.x + 170.0 * u:
			continue
		var is_lamp: bool = String(p["k"]) == "lamp"
		var gl: float = 1.0 if t == 0.0 else 0.92 + 0.08 * sin(t * 2.4 + float(p["x"]) * 9.0)
		var col2: Color = pal["a"]
		FxLight.light_pool(ci, Vector2(lx, ground_y + 34.0 * u), (130.0 if is_lamp else 100.0) * u, col2, 0.5 * gl, 0.24)
		if is_lamp:
			FxLight.shaft(ci, Vector2(lx, ground_y - 162.0 * u), PI * 0.5, 170.0 * u, 130.0 * u, col2, 0.16 * gl)
			FxLight.bloom(ci, Vector2(lx, ground_y - 158.0 * u), 44.0 * u, col2, 0.9 * gl)
			FxLight.reflection(ci, lx, ground_y + 12.0 * u, road_h * 0.5, 16.0 * u, col2, 0.35 * gl, t)


## Foreground weather and finishing light: low fog, petals / rain / embers, shafts, vignette, grain.
static func fore_extras(ci: CanvasItem, cam_x: float, size: Vector2, ground_y: float, u: float, t: float, pal: Dictionary) -> void:
	var w: Array[float] = weights(cam_x, size)
	var screen := Rect2(Vector2.ZERO, size)
	var sky := Rect2(0, 0, size.x, size.y * 0.95)
	# Drifting low fog puffs in front of the road.
	for i in 3:
		var fx: float = fposmod(FxLight.hash01(i, 91) * size.x * 1.6 - cam_x * 1.1 + t * (9.0 + float(i) * 4.0), size.x * 1.6) - size.x * 0.3
		FxLight.halo(ci, Vector2(fx, ground_y + (10.0 + 40.0 * float(i)) * u), 190.0 * u, Color(0.85, 0.8, 1.0, 0.5), 0.16, 26.0 * u)
	# Weather per district.
	var petal_n: int = int(round(14.0 * w[0]))
	if petal_n > 0:
		FxParticles.petals(ci, sky, t, petal_n, Color("#FFB3C9"), 5.0 * u, 20.0 * u, 36.0 * u, cam_x * 0.9)
	var rain_n: int = int(round(34.0 * w[1]))
	if rain_n > 0:
		FxParticles.rain(ci, sky, t if t != 0.0 else 0.4, rain_n, Color(0.75, 0.9, 1.0, 0.28), 14.0 * u, cam_x * 0.6)
	var ember_n: int = int(round(12.0 * w[2]))
	if ember_n > 0:
		FxParticles.embers(ci, Rect2(0, size.y * 0.15, size.x, ground_y * 0.8), t, ember_n, Color("#FFD36E"), 2.4 * u)
		FxParticles.petals(ci, sky, t, int(round(6.0 * w[2])), Color("#D8EBFF"), 4.0 * u, -14.0 * u, 28.0 * u, cam_x * 0.9)
	# Light shafts from the sky and a soft neon edge glow.
	for i in 3:
		var sx: float = fposmod(FxLight.hash01(i, 95) * size.x * 1.4 - cam_x * 0.2, size.x * 1.4) - size.x * 0.2
		FxLight.shaft(ci, Vector2(sx, -10.0), PI * 0.5 + 0.28 - float(i) * 0.1, ground_y * 1.05, 120.0 * u, pal["a"] if i % 2 == 0 else pal["b"], 0.09, t, float(i))
	FxLight.edge_glow(ci, screen, pal["b"], 0.16 * (w[1] + w[2] * 0.6), 40.0 * u, t)
	FxLight.vignette(ci, screen, 0.28, 0.0)
	FxLight.grain(ci, screen, t, 24, 0.05)
