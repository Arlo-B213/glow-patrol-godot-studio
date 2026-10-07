extends RefCounted
## Pure logic for Glow Bubbles (Story 028): a hex-offset grid of coloured orbs. No nodes, no drawing,
## so it is headless-testable. Cells hold -1 (empty), 0..4 (colours) or SPECIAL_RAINBOW / SPECIAL_BOMB.
## Rows grow downward from the ceiling (row 0). Offset rows are shifted half a cell right and have
## COLS - 1 usable cells. Inserting a row at the top flips `parity` so existing rows keep their offset.

const COLS := 9
const EMPTY := -1
const SPECIAL_RAINBOW := 5
const SPECIAL_BOMB := 6
const ROW_H := 1.7320508  # row spacing in radii (sqrt 3)

var rows: Array = []  # Array of PackedInt32Array
var parity := 0


## True when row `r` is shifted half a cell to the right.
func is_offset(r: int) -> bool:
	return (r + parity) % 2 == 1


## Number of usable cells in row `r`.
func cols_in_row(r: int) -> int:
	return COLS - (1 if is_offset(r) else 0)


## True when (r, c) is a real cell of the grid (rows beyond the stored ones are valid but empty).
func valid(r: int, c: int) -> bool:
	return r >= 0 and c >= 0 and c < cols_in_row(r)


## Orb at (r, c) or EMPTY when out of range / empty.
func get_cell(r: int, c: int) -> int:
	if r < 0 or r >= rows.size() or c < 0 or c >= COLS:
		return EMPTY
	return (rows[r] as PackedInt32Array)[c]


## Writes an orb, growing the row list as needed.
func set_cell(r: int, c: int, v: int) -> void:
	while rows.size() <= r:
		var row := PackedInt32Array()
		row.resize(COLS)
		row.fill(EMPTY)
		rows.append(row)
	rows[r][c] = v


## Grid-local centre of a cell for orb radius `rad` (origin = top-left corner of the field).
func cell_pos(r: int, c: int, rad: float) -> Vector2:
	var x: float = rad + float(c) * 2.0 * rad + (rad if is_offset(r) else 0.0)
	return Vector2(x, rad + float(r) * rad * ROW_H)


## Up to six neighbouring valid cells of (r, c).
func neighbors(r: int, c: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var cand: Array[Vector2i] = [Vector2i(r, c - 1), Vector2i(r, c + 1)]
	var shift: int = 0 if is_offset(r) else -1
	for rr in [r - 1, r + 1]:
		cand.append(Vector2i(rr, c + shift))
		cand.append(Vector2i(rr, c + shift + 1))
	for p in cand:
		if valid(p.x, p.y):
			out.append(p)
	return out


## Number of orbs on the grid.
func count() -> int:
	var n := 0
	for row in rows:
		for v in (row as PackedInt32Array):
			if v != EMPTY:
				n += 1
	return n


## Index of the lowest row that holds an orb, or -1 when empty.
func lowest_row() -> int:
	for r in range(rows.size() - 1, -1, -1):
		for v in (rows[r] as PackedInt32Array):
			if v != EMPTY:
				return r
	return -1


## Sorted list of plain colours (0..4) currently on the grid.
func colors_present() -> Array[int]:
	var seen := {}
	for row in rows:
		for v in (row as PackedInt32Array):
			if v >= 0 and v < SPECIAL_RAINBOW:
				seen[v] = true
	var out: Array[int] = []
	for k in seen.keys():
		out.append(int(k))
	out.sort()
	return out


## Connected same-colour cells starting at (r, c) (rainbow cells match any colour).
func find_match(r: int, c: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var col: int = get_cell(r, c)
	if col == EMPTY:
		return out
	var seen := {Vector2i(r, c): true}
	var stack: Array[Vector2i] = [Vector2i(r, c)]
	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		out.append(p)
		for n in neighbors(p.x, p.y):
			if seen.has(n):
				continue
			var v: int = get_cell(n.x, n.y)
			if v == EMPTY or v == SPECIAL_BOMB:
				continue
			if v == col or v == SPECIAL_RAINBOW or col == SPECIAL_RAINBOW:
				seen[n] = true
				stack.append(n)
	return out


## The cell plus its filled neighbours (the area a bomb orb clears).
func bomb_area(r: int, c: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = [Vector2i(r, c)]
	for n in neighbors(r, c):
		if get_cell(n.x, n.y) != EMPTY:
			out.append(n)
	return out


## Cells that are not connected to the ceiling (row 0) and would fall.
func find_orphans() -> Array[Vector2i]:
	var seen := {}
	var stack: Array[Vector2i] = []
	for c in cols_in_row(0):
		if get_cell(0, c) != EMPTY:
			seen[Vector2i(0, c)] = true
			stack.append(Vector2i(0, c))
	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		for n in neighbors(p.x, p.y):
			if not seen.has(n) and get_cell(n.x, n.y) != EMPTY:
				seen[n] = true
				stack.append(n)
	var out: Array[Vector2i] = []
	for r in rows.size():
		for c in cols_in_row(r):
			if get_cell(r, c) != EMPTY and not seen.has(Vector2i(r, c)):
				out.append(Vector2i(r, c))
	return out


## Empties the listed cells.
func remove_cells(cells: Array[Vector2i]) -> void:
	for p in cells:
		set_cell(p.x, p.y, EMPTY)


## True when a ball of radius `rad` centred at grid-local `p` touches the ceiling or any orb.
func hit_test(p: Vector2, rad: float) -> bool:
	if p.y - rad <= 0.0:
		return true
	var rr: int = int(floor((p.y - rad) / (rad * ROW_H)))
	var lim: float = rad * 1.8
	for r in range(maxi(0, rr - 1), mini(rows.size(), rr + 3)):
		for c in cols_in_row(r):
			if get_cell(r, c) != EMPTY and cell_pos(r, c, rad).distance_squared_to(p) < lim * lim:
				return true
	return false


## Nearest empty cell to grid-local `p` that is attached to the ceiling or to another orb.
func snap_cell(p: Vector2, rad: float) -> Vector2i:
	var best := Vector2i(0, 0)
	var best_d := INF
	var last: int = mini(rows.size() + 1, int(p.y / (rad * ROW_H)) + 2)
	for r in range(0, last + 1):
		for c in cols_in_row(r):
			if get_cell(r, c) != EMPTY:
				continue
			var attached: bool = r == 0
			if not attached:
				for n in neighbors(r, c):
					if get_cell(n.x, n.y) != EMPTY:
						attached = true
						break
			if not attached:
				continue
			var d: float = cell_pos(r, c, rad).distance_squared_to(p)
			if d < best_d:
				best_d = d
				best = Vector2i(r, c)
	return best


## Inserts a freshly generated row at the ceiling (everything moves down one row).
func add_row_top(rng: RandomNumberGenerator, colors: int) -> void:
	var row := PackedInt32Array()
	row.resize(COLS)
	row.fill(EMPTY)
	parity = 1 - parity
	rows.insert(0, row)
	for c in cols_in_row(0):
		rows[0][c] = rng.randi() % colors


## Procedural stage: `row_count` rows of `colors` colours, seeded, biased to form small clusters.
func generate(seed_v: int, row_count: int, colors: int) -> void:
	rows.clear()
	parity = 0
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	for r in row_count:
		for c in cols_in_row(r):
			var v: int = rng.randi() % colors
			if c > 0 and rng.randf() < 0.28:
				v = get_cell(r, c - 1)
			elif r > 0 and rng.randf() < 0.12:
				var ups: Array[Vector2i] = []
				for n in neighbors(r, c):
					if n.x == r - 1:
						ups.append(n)
				if not ups.is_empty():
					var u: Vector2i = ups[rng.randi() % ups.size()]
					v = get_cell(u.x, u.y)
			set_cell(r, c, v)
