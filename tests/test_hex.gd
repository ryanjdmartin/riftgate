extends TestCase


func test_distance() -> void:
	assert_eq(Hex.distance(Vector2i(0, 0), Vector2i(0, 0)), 0, "same hex")
	assert_eq(Hex.distance(Vector2i(0, 0), Vector2i(1, 0)), 1, "neighbour")
	assert_eq(Hex.distance(Vector2i(0, 0), Vector2i(2, -1)), 2, "two steps")
	assert_eq(Hex.distance(Vector2i(-2, 3), Vector2i(3, -1)), 5, "far apart")


func test_neighbors() -> void:
	var n := Hex.neighbors(Vector2i(2, 2))
	assert_eq(n.size(), 6, "six neighbours")
	for h in n:
		assert_eq(Hex.distance(Vector2i(2, 2), h), 1, "each neighbour at distance 1")


func test_offset_round_trip() -> void:
	for row in range(0, 14):
		for col in range(0, 9):
			var a := Hex.offset_to_axial(col, row)
			assert_eq(Hex.axial_to_offset(a), Vector2i(col, row), "offset round trip %d,%d" % [col, row])


func test_offset_neighbours_are_adjacent() -> void:
	# Two hexes side by side in the same row are always adjacent.
	for row in range(0, 6):
		var a := Hex.offset_to_axial(2, row)
		var b := Hex.offset_to_axial(3, row)
		assert_true(Hex.are_adjacent(a, b), "row neighbours adjacent on row %d" % row)


func test_pixel_round_trip() -> void:
	for row in range(0, 6):
		for col in range(0, 6):
			var a := Hex.offset_to_axial(col, row)
			var p := Hex.to_pixel(a, 20.0)
			assert_eq(Hex.from_pixel(p, 20.0), a, "pixel round trip %s" % str(a))
			# A point nudged toward a corner still resolves to the same hex.
			assert_eq(Hex.from_pixel(p + Vector2(7.0, -6.0), 20.0), a, "nudged pixel %s" % str(a))


## The flat-top layout (the long wall brief 7.1) is the pointy-top one turned a quarter
## clockwise: the field's rows run across the screen, the wall (the last rows) at the left and
## the rift (row 0) at the right; a pixel round-trips, and a hex's corners stay its own, so its
## neighbours stand across the same edges in either view.
func test_the_flat_top_layout_turns_the_pointy_top_a_quarter() -> void:
	for row in range(0, 6):
		for col in range(0, 6):
			var a := Hex.offset_to_axial(col, row)
			var p := Hex.to_pixel_flat(a, 20.0)
			assert_eq(Hex.from_pixel_flat(p, 20.0), a, "flat pixel round trip %s" % str(a))
			assert_eq(Hex.from_pixel_flat(p + Vector2(-6.0, 7.0), 20.0), a, "nudged flat pixel %s" % str(a))
			assert_true(p.is_equal_approx(Hex.turn(Hex.to_pixel(a, 20.0))), "the flat centre is the pointy one turned")
			var pc := Hex.corners(Hex.to_pixel(a, 20.0), 20.0)
			var fc := Hex.corners_flat(p, 20.0)
			for i in range(6):
				assert_true(fc[i].is_equal_approx(Hex.turn(pc[i])), "corner %d turns with its hex" % i)
	var rift := Hex.to_pixel_flat(Hex.offset_to_axial(4, 0), 20.0)
	var wall := Hex.to_pixel_flat(Hex.offset_to_axial(4, 11), 20.0)
	assert_true(wall.x < rift.x, "the wall's rows stand left of the rift's")
	var flat := Hex.corners_flat(Vector2.ZERO, 20.0)
	var pointed := 0
	for c in flat:
		if c.is_equal_approx(Vector2(20.0, 0.0)) or c.is_equal_approx(Vector2(-20.0, 0.0)):
			pointed += 1
	assert_eq(pointed, 2, "a corner at either side: flat-top")
