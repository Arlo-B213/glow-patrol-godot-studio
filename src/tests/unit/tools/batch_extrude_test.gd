extends GdUnitTestSuite
## Checks the extruded mesh built by tools/batch_extrude.gd: face winding and wall normals.

const BatchExtrude := preload("res://tools/batch_extrude.gd")


## A 40 x 40 image with an opaque square in the middle and transparent surroundings.
func _square_image() -> Image:
	var img := Image.create(40, 40, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(10, 30):
		for y in range(10, 30):
			img.set_pixel(x, y, Color(1, 1, 1, 1))
	return img


func test_empty_image_builds_no_mesh() -> void:
	# Arrange
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	# Act
	var mesh: ArrayMesh = BatchExtrude.build_mesh(img, 0.1, 0.01, 0.5, 2.0)
	# Assert
	assert_object(mesh).is_null()


func test_square_builds_front_back_and_wall_surfaces() -> void:
	# Arrange / Act
	var mesh: ArrayMesh = BatchExtrude.build_mesh(_square_image(), 0.1, 0.01, 0.5, 2.0)
	# Assert: one surface for the faces, one for the walls
	assert_int(mesh.get_surface_count()).is_equal(2)


func test_front_faces_point_plus_z_and_back_faces_minus_z() -> void:
	# Arrange
	var mesh: ArrayMesh = BatchExtrude.build_mesh(_square_image(), 0.1, 0.01, 0.5, 2.0)
	var arrays: Array = mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	# Act / Assert: geometric triangle normal agrees with the stored normal
	for t in range(0, verts.size(), 3):
		var geo: Vector3 = (verts[t + 1] - verts[t]).cross(verts[t + 2] - verts[t]).normalized()
		assert_float(geo.dot(normals[t])).is_greater(0.99)


func test_wall_normals_point_away_from_the_silhouette_centre() -> void:
	# Arrange
	var mesh: ArrayMesh = BatchExtrude.build_mesh(_square_image(), 0.1, 0.01, 0.5, 2.0)
	var arrays: Array = mesh.surface_get_arrays(1)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	# Act / Assert: each wall quad's normal points away from the centre of the slab
	for v in range(0, verts.size(), 6):
		var mid: Vector3 = (verts[v] + verts[v + 1] + verts[v + 2] + verts[v + 5]) * 0.25
		var outward: Vector2 = Vector2(mid.x, mid.y).normalized()
		assert_float(Vector2(normals[v].x, normals[v].y).dot(outward)).is_greater(0.5)
