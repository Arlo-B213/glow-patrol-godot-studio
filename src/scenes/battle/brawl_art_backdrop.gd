extends RefCounted
const FD := preload("res://scripts/fast_draw.gd")
## Night-alley backdrop for Alley Brawl: gradient sky, skyline with lit windows, hanging lanterns
## and a floor. Call from the view's _draw(). `u` is the layout scale (field width / 480).

const SKYLINE := [0.34, 0.5, 0.4, 0.58, 0.32, 0.46, 0.38, 0.54, 0.36]
const LANTERN_FRACTIONS := [0.16, 0.5, 0.84]


static func draw(ci: CanvasItem, size: Vector2, ground_y: float, u: float) -> void:
	var top := Color("#120B2E")
	var bottom := Color("#2A1650")
	FD.gpoly(ci, 
		PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x, ground_y), Vector2(0, ground_y)]),
		PackedColorArray([top, top, bottom, bottom])
	)

	var count: int = SKYLINE.size()
	var slot_w: float = size.x / float(count)
	for i in range(count):
		var h: float = float(SKYLINE[i]) * ground_y
		var bx: float = float(i) * slot_w
		ci.draw_rect(Rect2(bx, ground_y - h, slot_w - 4.0 * u, h), Color("#1A0F3D"))
		var win_rows: int = int(h / (34.0 * u))
		for row in range(win_rows):
			if (i + row) % 3 == 0:
				continue
			var wy: float = ground_y - h + 14.0 * u + float(row) * 34.0 * u
			ci.draw_rect(Rect2(bx + 10.0 * u, wy, 8.0 * u, 12.0 * u), Color("#FFC15E", 0.55))
			ci.draw_rect(Rect2(bx + 30.0 * u, wy, 8.0 * u, 12.0 * u), Color("#FF5FA2", 0.4))

	for frac in LANTERN_FRACTIONS:
		var lx: float = size.x * float(frac)
		var ly: float = ground_y * 0.42
		ci.draw_line(Vector2(lx, 0.0), Vector2(lx, ly - 14.0 * u), Color("#3B2A6B"), 2.0 * u)
		FD.circle(ci, Vector2(lx, ly), 30.0 * u, Color("#FFC15E", 0.12))
		FD.circle(ci, Vector2(lx, ly), 16.0 * u, Color("#FFC15E", 0.85))

	ci.draw_rect(Rect2(0.0, ground_y, size.x, size.y - ground_y), Color("#0C0720"))
	ci.draw_line(Vector2(0.0, ground_y), Vector2(size.x, ground_y), Color("#6C5CE7"), 3.0 * u)
	var lane_y: float = ground_y + (size.y - ground_y) * 0.35
	var dash: float = 36.0 * u
	var x := 0.0
	while x < size.x:
		ci.draw_rect(Rect2(x, lane_y, dash * 0.5, 3.0 * u), Color("#3B2A6B"))
		x += dash
