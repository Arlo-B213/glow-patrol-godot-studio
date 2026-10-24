extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Alley Brawl hit feedback (Story 036): hit sparks, floating text popups (combo, pickups, Second
## Wind), hit-stop and screen shake. State lives on the view (`sparks`, `popups`, `hitstop`,
## `shake`, `shake_t`) and tuning in `v.feel` (hit_feel.gd / brawl_hit_feel.tres); everything here
## is VISUAL. Reduce motion keeps popups, drops shake and caps the hit pause. Pause and shake take
## the max of overlapping requests, so several hits in one frame never stack into a long freeze.
## World positions are world-space px (x) and screen px (y), like the other actors.


## Burst of radiating lines at `pos`; `big` is for finishers and boss hits.
static func spark(v: Variant, pos: Vector2, color: Color, big: bool = false) -> void:
	v.sparks.append({"pos": pos, "t": 0, "big": big, "color": color, "rot": randf() * TAU})


## Floating text rising from `pos`. `size` is in px at u = 1.
static func popup(v: Variant, text: String, pos: Vector2, color: Color, size: float = 18.0, life: int = 48) -> void:
	v.popups.append({"text": text, "pos": pos, "t": 0, "life": life, "color": color, "size": size})


## Feedback for a landed hit of `damage`: a short hit pause (attacker and target freeze) and a
## shake that scales with damage, both from `v.feel`.
static func hit_feedback(v: Variant, damage: int) -> void:
	var calm: bool = v.calm()
	v.hitstop = maxi(v.hitstop, v.feel.pause_frames(calm))
	shake_screen(v, v.feel.shake_px(damage, calm))


## Screen shake of `amount` px (at u = 1), easing to rest over the tuned shake time; ignored when
## reduce motion is on. A weaker request during a stronger shake does not cut it short.
static func shake_screen(v: Variant, amount: float) -> void:
	if v.calm() or amount <= 0.0:
		return
	var px: float = amount * v.u
	if px >= v.shake * float(v.shake_t) / float(v.feel.shake_frames()):
		v.shake = maxf(px, 0.0)
		v.shake_t = v.feel.shake_frames()


## Advances sparks and popups one tick and decays the shake.
static func update(v: Variant) -> void:
	for i in range(v.sparks.size() - 1, -1, -1):
		v.sparks[i]["t"] += 1
		if int(v.sparks[i]["t"]) >= (12 if bool(v.sparks[i]["big"]) else 8):
			v.sparks.remove_at(i)
	for i in range(v.popups.size() - 1, -1, -1):
		var p: Dictionary = v.popups[i]
		p["t"] += 1
		p["pos"] = Vector2(p["pos"]) + Vector2(0.0, -0.9 * v.u)
		if int(p["t"]) >= int(p["life"]):
			v.popups.remove_at(i)
	if v.shake_t > 0:
		v.shake_t -= 1
		if v.shake_t == 0:
			v.shake = 0.0


## Draws sparks and popups (call with the camera transform set).
static func draw(v: Variant) -> void:
	var u: float = v.u
	for s in v.sparks:
		var life: float = 12.0 if bool(s["big"]) else 8.0
		var k: float = float(s["t"]) / life
		var col: Color = s["color"]
		var c: Vector2 = s["pos"]
		var n: int = 8 if bool(s["big"]) else 6
		var r0: float = (6.0 + 22.0 * k) * u * (1.4 if bool(s["big"]) else 1.0)
		var r1: float = r0 + (10.0 + 8.0 * (1.0 - k)) * u
		var pts := PackedVector2Array()
		for i in n:
			var a: float = float(s["rot"]) + TAU * float(i) / float(n)
			pts.append(c + Vector2(cos(a), sin(a)) * r0)
			pts.append(c + Vector2(cos(a), sin(a)) * r1)
		v.draw_multiline(pts, Color(1.0, 0.97, 0.8, 1.0 - k), (3.5 - 2.0 * k) * u, false)
		FD.circle(v, c, (14.0 * (1.0 - k) + 3.0) * u * (1.4 if bool(s["big"]) else 1.0), Color(col, 0.55 * (1.0 - k)))
	var font: Font = ThemeDB.fallback_font
	for p in v.popups:
		var k2: float = float(p["t"]) / float(p["life"])
		var a2: float = clampf((1.0 - k2) * 2.2, 0.0, 1.0)
		var pop: float = 1.0 + 0.35 * maxf(0.0, 1.0 - float(p["t"]) / 6.0)
		var fs: int = int(float(p["size"]) * u * pop)
		var pos: Vector2 = p["pos"]
		var col2: Color = p["color"]
		var txt: String = String(p["text"])
		var w: float = 260.0 * u
		v.draw_string(font, pos + Vector2(-w * 0.5 + 1.5 * u, 1.5 * u), txt, HORIZONTAL_ALIGNMENT_CENTER, w, fs, Color(0.1, 0.03, 0.2, 0.8 * a2))
		v.draw_string(font, pos + Vector2(-w * 0.5, 0.0), txt, HORIZONTAL_ALIGNMENT_CENTER, w, fs, Color(col2, a2))
