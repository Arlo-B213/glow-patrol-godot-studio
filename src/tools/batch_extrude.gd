@tool
extends EditorScript
## Batch-extrudes every PNG in SOURCE_DIR into a 2.5D ArrayMesh saved as a .tres in OUTPUT_DIR.
## Each sprite becomes a slab: the opaque silhouette is traced from its alpha, the front and back
## faces keep the sprite's pixels as UVs, and the side walls take the silhouette's outline. The
## result casts 3D shadows and takes 3D lights through a MeshInstance3D.
## Run from the Script Editor: File > Run (Ctrl+Shift+X). See tools/README_batch_extrude.md.

## Folder scanned for .png sprites (res:// path, not recursive).
const SOURCE_DIR := "res://assets/art/characters/breaker/parts"
## Folder the .tres meshes are written to. Created if missing.
const OUTPUT_DIR := "res://assets/meshes_25d"
## Slab thickness in world units.
const DEPTH := 0.12
## World units per sprite pixel. 0.01 makes a 1024 px sprite about 10 units tall.
const PIXEL_SIZE := 0.01
## Alpha above this counts as solid when tracing the silhouette (0..1).
const ALPHA_THRESHOLD := 0.5
## Outline simplification in pixels. Larger gives fewer side walls and a cheaper mesh.
const SIMPLIFY_EPSILON := 2.0


func _run() -> void:
	var made: int = batch(SOURCE_DIR, OUTPUT_DIR, DEPTH, PIXEL_SIZE, ALPHA_THRESHOLD, SIMPLIFY_EPSILON)
	print("batch_extrude: wrote %d mesh(es) to %s" % [made, OUTPUT_DIR])
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()


## Converts every .png in `source_dir` and returns how many meshes were saved.
static func batch(source_dir: String, output_dir: String, depth: float, pixel_size: float, alpha_threshold: float, epsilon: float) -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var dir := DirAccess.open(source_dir)
	if dir == null:
		push_error("batch_extrude: cannot open %s" % source_dir)
		return 0
	var made: int = 0
	for file: String in dir.get_files():
		if not file.to_lower().ends_with(".png"):
			continue
		var texture := ResourceLoader.load(source_dir.path_join(file)) as Texture2D
		if texture == null:
			push_warning("batch_extrude: could not load %s" % file)
			continue
		var mesh: ArrayMesh = build_mesh(texture.get_image(), depth, pixel_size, alpha_threshold, epsilon)
		if mesh == null:
			push_warning("batch_extrude: no opaque pixels in %s" % file)
			continue
		var out_path: String = output_dir.path_join(file.get_basename() + ".tres")
		if ResourceSaver.save(mesh, out_path) == OK:
			made += 1
		else:
			push_error("batch_extrude: could not save %s" % out_path)
	return made


## Builds the slab mesh for one image. Returns null when the image has no opaque pixels.
static func build_mesh(image: Image, depth: float, pixel_size: float, alpha_threshold: float, epsilon: float) -> ArrayMesh:
	var img := image.duplicate() as Image
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	var size: Vector2i = img.get_size()
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img, alpha_threshold)
	var outlines: Array = bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, size), epsilon)
	if outlines.is_empty():
		return null
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var faces := PackedVector3Array()
	var face_normals := PackedVector3Array()
	var face_uvs := PackedVector2Array()
	var walls := PackedVector3Array()
	var wall_normals := PackedVector3Array()
	var wall_uvs := PackedVector2Array()
	var centre := Vector2(size) * 0.5
	var z_front := depth * 0.5
	var z_back := -depth * 0.5
	for raw: Variant in outlines:
		var outline: PackedVector2Array = raw
		if outline.size() < 3:
			continue
		var tris: PackedInt32Array = Geometry2D.triangulate_polygon(outline)
		if tris.is_empty():
			# Self-touching traces cannot be triangulated. Their hull still covers the sprite;
			# the alpha-scissor material discards any transparent texels it adds.
			outline = _convex_hull(outline)
			tris = Geometry2D.triangulate_polygon(outline)
		for i in range(0, tris.size(), 3):
			for k in [0, 2, 1]:
				var p: Vector2 = outline[tris[i + k]]
				var local := _to_world(p, centre, pixel_size)
				var uv := p / Vector2(size)
				faces.append(Vector3(local.x, local.y, z_front))
				face_normals.append(Vector3(0, 0, 1))
				face_uvs.append(uv)
			for k in [0, 1, 2]:
				var p2: Vector2 = outline[tris[i + k]]
				var local2 := _to_world(p2, centre, pixel_size)
				faces.append(Vector3(local2.x, local2.y, z_back))
				face_normals.append(Vector3(0, 0, -1))
				face_uvs.append(p2 / Vector2(size))
		_append_walls(outline, centre, pixel_size, z_front, z_back, size, walls, wall_normals, wall_uvs)
	if faces.is_empty():
		return null
	var mesh := ArrayMesh.new()
	var face_arrays: Array = []
	face_arrays.resize(Mesh.ARRAY_MAX)
	face_arrays[Mesh.ARRAY_VERTEX] = faces
	face_arrays[Mesh.ARRAY_NORMAL] = face_normals
	face_arrays[Mesh.ARRAY_TEX_UV] = face_uvs
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, face_arrays)
	if not walls.is_empty():
		var wall_arrays: Array = []
		wall_arrays.resize(Mesh.ARRAY_MAX)
		wall_arrays[Mesh.ARRAY_VERTEX] = walls
		wall_arrays[Mesh.ARRAY_NORMAL] = wall_normals
		wall_arrays[Mesh.ARRAY_TEX_UV] = wall_uvs
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, wall_arrays)
	return mesh


## Convex hull of a point set (monotone chain), counter-clockwise in screen space.
static func _convex_hull(points: PackedVector2Array) -> PackedVector2Array:
	var pts: Array = Array(points)
	pts.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x or (a.x == b.x and a.y < b.y))
	var lower: Array = []
	for p: Vector2 in pts:
		while lower.size() >= 2 and _cross(lower[-2], lower[-1], p) <= 0.0:
			lower.pop_back()
		lower.append(p)
	var upper: Array = []
	for i in range(pts.size() - 1, -1, -1):
		var q: Vector2 = pts[i]
		while upper.size() >= 2 and _cross(upper[-2], upper[-1], q) <= 0.0:
			upper.pop_back()
		upper.append(q)
	lower.pop_back()
	upper.pop_back()
	return PackedVector2Array(lower + upper)


static func _cross(o: Vector2, a: Vector2, b: Vector2) -> float:
	return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)


## Pixel position to world position: centred on the image, y up, so the sprite stands upright.
static func _to_world(p: Vector2, centre: Vector2, pixel_size: float) -> Vector2:
	return Vector2(p.x - centre.x, centre.y - p.y) * pixel_size


## Two triangles per outline edge, facing outward. Outline winding decides which side is outside.
static func _append_walls(outline: PackedVector2Array, centre: Vector2, pixel_size: float, z_front: float, z_back: float, size: Vector2i, walls: PackedVector3Array, wall_normals: PackedVector3Array, wall_uvs: PackedVector2Array) -> void:
	var sign_flip: float = 1.0 if _signed_area(outline) < 0.0 else -1.0
	var n: int = outline.size()
	for i in n:
		var a: Vector2 = outline[i]
		var b: Vector2 = outline[(i + 1) % n]
		var wa := _to_world(a, centre, pixel_size)
		var wb := _to_world(b, centre, pixel_size)
		var edge: Vector2 = (wb - wa).normalized()
		var normal := Vector3(edge.y, -edge.x, 0.0) * sign_flip
		var ua := a / Vector2(size)
		var ub := b / Vector2(size)
		var quad := [
			Vector3(wa.x, wa.y, z_front), Vector3(wb.x, wb.y, z_front), Vector3(wb.x, wb.y, z_back),
			Vector3(wa.x, wa.y, z_front), Vector3(wb.x, wb.y, z_back), Vector3(wa.x, wa.y, z_back),
		]
		var quad_uv := [ua, ub, ub, ua, ub, ua]
		for k in 6:
			walls.append(quad[k])
			wall_normals.append(normal)
			wall_uvs.append(quad_uv[k])


static func _signed_area(poly: PackedVector2Array) -> float:
	var area: float = 0.0
	for i in poly.size():
		var a: Vector2 = poly[i]
		var b: Vector2 = poly[(i + 1) % poly.size()]
		area += a.x * b.y - b.x * a.y
	return area * 0.5
