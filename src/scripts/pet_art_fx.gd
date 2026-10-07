extends RefCounted
## Mood and reaction effects for PetArt (Story 033): floating hearts, sleepy "z"s, sweat
## drops, twinkles, crumbs, purr hearts and the grow-up evolution flash. Everything is a
## pure function of the context `p` (time `t`, reaction clock `rt`), so it needs no state.

const Shade := preload("res://scripts/hunter_shade.gd")
const PINK := Color(1.0, 0.4, 0.64)


## Ambient effects for the current mood (above the head, pet space).
static func mood(ci: CanvasItem, p: Dictionary) -> void:
	var md: int = p["mood"]
	var t: float = p["t"]
	var k: float = p["k"]
	var ha: Vector2 = p["a_head"]
	var anim: bool = p["anim"]
	var react: String = p["react"]
	match md:
		PetArt.MOOD_HAPPY:
			if react == "pet":
				return
			for i in 3:
				var ph: float = fmod(t * 0.55 + float(i) / 3.0, 1.0) if anim else float(i) / 3.0
				var at := PetArt.q(p, ha.x - 17.0 + float(i) * 17.0 + sin(ph * 6.0 + float(i)) * 3.0, ha.y - 4.0 - ph * 16.0)
				PetArt.heart(ci, at, (4.2 - float(i % 2)) * k + 0.8, Shade.fade(PINK, 0.9 * (1.0 - ph * 0.7)))
		PetArt.MOOD_SLEEPY:
			var font := ThemeDB.fallback_font
			for i in 3:
				var ph: float = fmod(t * 0.3 + float(i) * 0.33, 1.0) if anim else 0.25 + 0.3 * float(i)
				var at := PetArt.q(p, ha.x + 14.0 + float(i) * 7.0 + ph * 5.0, ha.y + 2.0 - ph * 18.0)
				var al := 0.9 * (1.0 - ph * 0.7)
				var fs := int(9 + i * 4)
				ci.draw_string(font, at + Vector2(0.7, 0.7), "z", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.1, 0.0, 0.3, al * 0.5))
				ci.draw_string(font, at, "z", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.88, 0.84, 1.0, al))
		PetArt.MOOD_SURPRISED:
			var c := PetArt.q(p, ha.x + 18.0, ha.y - 4.0)
			for i in 3:
				var a := -1.2 + float(i) * 0.45
				ci.draw_line(c + Vector2(cos(a), sin(a)) * 4.0 * k, c + Vector2(cos(a), sin(a)) * 10.0 * k, Color(1.0, 0.9, 0.5), 1.6, true)
		PetArt.MOOD_SHY:
			var c := PetArt.q(p, ha.x + 20.0, ha.y + 8.0)
			var sy: float = c.y + (sin(t * 3.0) * 0.6 if anim else 0.0)
			var drop := PackedVector2Array([Vector2(c.x, sy - 4.5 * k), Vector2(c.x + 2.4 * k, sy), Vector2(c.x + 1.6 * k, sy + 2.4 * k),
				Vector2(c.x - 1.6 * k, sy + 2.4 * k), Vector2(c.x - 2.4 * k, sy)])
			ci.draw_colored_polygon(drop, Color(0.6, 0.85, 1.0, 0.9))
		PetArt.MOOD_EXCITED:
			for i in 4:
				var ph: float = fmod(t * 1.3 + float(i) * 0.25, 1.0) if anim else float(i) * 0.25
				var a := float(i) * 1.7 + 0.6
				var at := PetArt.q(p, ha.x + cos(a) * 30.0, ha.y + 12.0 + sin(a) * 16.0)
				PetArt.star4(ci, at, (3.0 + 2.0 * sin(ph * PI)) * k, Color(1.0, 0.95, 0.6, 0.9 * sin(ph * PI)))


## One-shot reaction visuals for p["react"] at reaction time p["rt"] (seconds).
static func react(ci: CanvasItem, p: Dictionary) -> void:
	var kind: String = p["react"]
	var rt: float = p["rt"]
	var k: float = p["k"]
	var ha: Vector2 = p["a_head"]
	match kind:
		"pet":
			for i in 7:
				var age := rt - float(i) * 0.17
				if age < 0.0 or age > 1.3:
					continue
				var at := PetArt.q(p, ha.x + sin(float(i) * 2.3) * 20.0 + age * (float(i % 3) - 1.0) * 6.0, ha.y + 6.0 - age * 30.0)
				PetArt.heart(ci, at, (4.4 + float(i % 3)) * k + 0.8, Shade.fade(PINK, clampf(1.5 - age * 1.1, 0.0, 1.0)))
			for i in 3:
				var w := PetArt.q(p, -26.0 + float(i) * 26.0, -4.0)
				ci.draw_arc(w, 4.0 * k, PI * 1.1, PI * 1.9, 6, Color(1.0, 0.7, 0.85, 0.5 + 0.3 * sin(rt * 20.0 + float(i))), 1.2, true)
		"eat":
			var m: Vector2 = p["a_mouth"]
			for i in 7:
				var age := rt - 0.15 - float(i) * 0.1
				if age < 0.0 or age > 0.9:
					continue
				var dir := -1.0 if i % 2 == 0 else 1.0
				var at := PetArt.q(p, m.x + dir * (4.0 + age * 20.0) * (0.6 + 0.1 * float(i % 3)), m.y + 2.0 - 14.0 * age + 34.0 * age * age)
				ci.draw_circle(at, (1.5 - age * 0.6) * k + 0.4, Color(1.0, 0.8, 0.45, 1.0 - age))
			for i in 3:
				var ph := fmod(rt * 1.4 + float(i) * 0.33, 1.0)
				PetArt.star4(ci, PetArt.q(p, ha.x - 22.0 + float(i) * 22.0, ha.y + 2.0 - ph * 12.0), 3.4 * k, Color(1.0, 0.92, 0.55, 1.0 - ph))
		"grow":
			_grow(ci, p, rt)


## Evolution flash: white bloom, spinning light rays, ring of sparkles.
static func _grow(ci: CanvasItem, p: Dictionary, rt: float) -> void:
	var k: float = p["k"]
	var acc: Color = p["accent"]
	var c := PetArt.q(p, 0.0, -36.0)
	var f := clampf(rt / 1.1, 0.0, 1.0)
	if f < 1.0:
		var a := sin(f * PI) * 0.85
		ci.draw_circle(c, 46.0 * k * (0.5 + f), Color(1.0, 1.0, 1.0, a * 0.6))
		ci.draw_circle(c, 30.0 * k * (0.5 + f), Color(1.0, 1.0, 0.95, a))
		for i in 12:
			var an := TAU * float(i) / 12.0 + rt * 1.2
			var l := (62.0 + 18.0 * float(i % 2)) * k * (0.4 + f)
			var ray := PackedVector2Array([c + Vector2(cos(an - 0.07), sin(an - 0.07)) * 8.0 * k,
				c + Vector2(cos(an), sin(an)) * l, c + Vector2(cos(an + 0.07), sin(an + 0.07)) * 8.0 * k])
			ci.draw_colored_polygon(ray, Shade.fade(Shade.lighten(acc, 0.6), a * 0.8))
	for i in 10:
		var age := rt - 0.25 - float(i) * 0.04
		if age < 0.0 or age > 1.4:
			continue
		var an := TAU * float(i) / 10.0
		var rr := (10.0 + age * 40.0) * k
		PetArt.star4(ci, c + Vector2(cos(an), sin(an) - 0.2) * rr, (3.0 + float(i % 3)) * k, Shade.fade(Shade.lighten(acc, 0.5), 1.0 - age / 1.4))


## Pulsing "ready to zap" ring and orbiting spark above the pet (companion).
static func ready(ci: CanvasItem, p: Dictionary) -> void:
	var t: float = p["t"]
	var k: float = p["k"]
	var acc: Color = p["accent"]
	var ha: Vector2 = p["a_head"]
	var c := PetArt.q(p, ha.x, ha.y - 8.0)
	var pulse := 0.5 + 0.5 * sin(t * 8.0)
	ci.draw_circle(c, (7.0 + 2.5 * pulse) * k, Shade.fade(acc, 0.25))
	PetArt.star4(ci, c + Vector2(cos(t * 5.0), sin(t * 5.0)) * 8.0 * k, 3.6 * k, Shade.fade(Shade.lighten(acc, 0.6), 0.95))
