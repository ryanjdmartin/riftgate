extends TestCase

## A machine's move on the map (MovePath, Ryan, 4 October): a smooth curve through the hex
## centres, a speed that starts and ends at rest, holds through corners and never jumps.

const STEP := 60.0


func _route(dirs: Array) -> Array:
	var p := Vector2.ZERO
	var pts: Array = [p]
	for deg in dirs:
		p += Vector2(cos(deg_to_rad(deg)), -sin(deg_to_rad(deg))) * STEP
		pts.append(p)
	return pts


func test_the_curve_keeps_the_ends_and_the_last_direction() -> void:
	var centres := _route([90, 90, 30, -30])
	var mp := MovePath.build(centres, 120.0)
	assert_true(mp.points[0].is_equal_approx(centres[0]), "it starts on the first hex")
	assert_true(mp.points[mp.points.size() - 1].is_equal_approx(centres[centres.size() - 1]), "and ends on the last")
	var last_dir: Vector2 = (centres[centres.size() - 1] - centres[centres.size() - 2]).normalized()
	var end: Array = mp.at(mp.duration - 0.001)
	assert_true((end[1] as Vector2).dot(last_dir) > 0.999, "it ends travelling the way the last step goes, the facing the simulation records")
	assert_true(mp.arc[mp.arc.size() - 1] < STEP * 4.0, "a cut corner is shorter than the hex-to-hex route")
	assert_true(mp.arc[mp.arc.size() - 1] > STEP * 3.5, "but not by much")


func test_the_speed_starts_and_ends_at_rest_and_never_jumps() -> void:
	var mp := MovePath.build(_route([90, 90, 90, 90]), 120.0, 0.8)
	assert_eq(mp.speed[0], 0.0, "at rest at the start")
	assert_eq(mp.speed[mp.speed.size() - 1], 0.0, "and at the end")
	var a := 120.0 / 0.8
	var worst := 0.0
	for i in range(1, mp.points.size()):
		var ds := mp.arc[i] - mp.arc[i - 1]
		var dv2 := absf(mp.speed[i] * mp.speed[i] - mp.speed[i - 1] * mp.speed[i - 1])
		worst = maxf(worst, dv2 / (2.0 * ds))
	assert_true(worst <= a * 1.001, "no change of speed beyond the machine's acceleration (%f of %f)" % [worst, a])
	var mid: Array = mp.at(mp.duration * 0.5)
	assert_true(absf(float(mid[2]) - 120.0) < 1.0, "a long straight reaches full speed in the middle (%f)" % float(mid[2]))
	var linear := 4.0 * STEP / 120.0
	assert_true(mp.duration > linear, "accelerating and braking take longer than a flat run (%f against %f)" % [mp.duration, linear])


func test_a_machine_keeps_its_speed_through_a_corner() -> void:
	# Ryan, 4 October, the third pass: no braking for corners.
	var centres := _route([90, 90, 90, -30, -30, -30])   # a sharp corner, 120 degrees, in the middle of a long move
	var mp := MovePath.build(centres, 120.0, 0.4)
	var slowest := 1e9
	for i in range(mp.points.size()):
		if mp.arc[i] > STEP * 2.2 and mp.arc[i] < STEP * 3.4:
			slowest = minf(slowest, mp.speed[i])
	assert_true(slowest > 120.0 * 0.999, "full speed through the corner (%f)" % slowest)


func test_at_moves_forward_continuously_and_the_packs_keep_their_lines() -> void:
	var mp := MovePath.build(_route([90, 30, 30]), 100.0)
	var last := -1.0
	var prev: Vector2 = mp.at(0.0)[0]
	var biggest := 0.0
	var t := 0.0
	while t <= mp.duration:
		var here: Array = mp.at(t)
		assert_true(float(here[3]) >= last - 0.0001, "the distance along it never runs back")
		last = float(here[3])
		biggest = maxf(biggest, (here[0] as Vector2).distance_to(prev))
		prev = here[0]
		t += 1.0 / 60.0
	assert_true(biggest < 100.0 / 60.0 * 1.2, "no frame jumps further than full speed allows (%f)" % biggest)
	var pack := MovePath.build(_route([90, 30]), 100.0, 0.001, false)
	assert_eq(pack.points.size(), 3, "the packs keep the hex-to-hex lines, no arcs")
	assert_true(absf(pack.duration - 2.0 * STEP / 100.0) < 0.05, "at their flat step (%f)" % pack.duration)
	var still := MovePath.build([Vector2.ONE], 100.0)
	assert_eq(still.duration, 0.0, "a one-hex route takes no time")


func test_the_heading_turns_evenly_round_a_corner() -> void:
	# Ryan, 5 October: a slow machine's turn stuttered in five to eight jumps, one a span of the
	# corner's arc. The heading turns evenly within a span, so no frame turns it much more than
	# the frame before.
	var mp := MovePath.build(_route([90, 90, 30, -30, -30]), 40.0, 1.2)   # a slow machine through two corners
	var prev: Vector2 = mp.at(0.0)[1]
	var prev_turn := 0.0
	var worst_jerk := 0.0
	var t := 1.0 / 60.0
	while t < mp.duration:
		var here: Vector2 = mp.at(t)[1]
		var turn := absf(prev.angle_to(here))
		worst_jerk = maxf(worst_jerk, absf(turn - prev_turn))
		prev = here
		prev_turn = turn
		t += 1.0 / 60.0
	assert_true(worst_jerk < 0.01, "the heading's turn a frame never leaps (%f radians)" % worst_jerk)
