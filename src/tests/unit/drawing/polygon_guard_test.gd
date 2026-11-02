extends GdUnitTestSuite
## Polygon drawing guard: zero-area and non-finite shapes are skipped, so the engine never
## triangulates them (that failure spammed "Invalid polygon data" on the phone).

const FD := preload("res://scripts/fast_draw.gd")


func test_triangle_has_area() -> void:
	assert_bool(FD.has_area(PackedVector2Array([Vector2(0, 0), Vector2(10, 0), Vector2(0, 10)]))).is_true()


func test_collinear_points_have_no_area() -> void:
	assert_bool(FD.has_area(PackedVector2Array([Vector2(0, 0), Vector2(5, 5), Vector2(10, 10)]))).is_false()


func test_single_point_repeated_has_no_area() -> void:
	assert_bool(FD.has_area(PackedVector2Array([Vector2(3, 3), Vector2(3, 3), Vector2(3, 3), Vector2(3, 3)]))).is_false()


func test_too_few_points_have_no_area() -> void:
	assert_bool(FD.has_area(PackedVector2Array([Vector2(0, 0), Vector2(10, 0)]))).is_false()


func test_nan_points_are_rejected() -> void:
	assert_bool(FD.has_area(PackedVector2Array([Vector2(0, 0), Vector2(NAN, 0), Vector2(0, 10)]))).is_false()
