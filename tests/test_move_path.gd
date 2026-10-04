extends TestCase

## A machine's move on the map (MovePath, Ryan, 4 October): a smooth curve through the hex
## centres, a speed that starts and ends at rest, brakes into corners and never jumps.

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
	var mp := MovePath.build(_route([90, 90, 90, 90]), 120.0, 0.8, 0.35)
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


func test_a_machine_brakes_into_a_corner_by_its_own_share() -> void:
	var centres := _route([90, 90, -30, -30])   # a sharp corner, 120 degrees
	var heavy := MovePath.build(centres, 120.0, 0.4, 0.6)
	var light := MovePath.build(centres, 120.0, 0.4, 0.0)
	var slowest_heavy := 1e9
	var slowest_light := 1e9
	for i in range(2, heavy.points.size() - 2):
		if heavy.arc[i] > STEP * 1.5 and heavy.arc[i] < STEP * 2.3:
			slowest_heavy = minf(slowest_heavy, heavy.speed[i])
	for i in range(2, light.points.size() - 2):
		if light.arc[i] > STEP * 1.5 and light.arc[i] < STEP * 2.3:
			slowest_light = minf(slowest_light, light.speed[i])
	assert_true(slowest_heavy < slowest_light * 0.7, "a machine that brakes for corners slows through this one (%f against %f)" % [slowest_heavy, slowest_light])
	assert_true(slowest_heavy >= 120.0 * MovePath.CORNER_FLOOR - 0.01, "never below the floor")
	assert_true(heavy.duration > light.duration, "and takes longer over the route")


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
	var pack := MovePath.build(_route([90, 30]), 100.0, 0.001, 0.0, false)
	assert_eq(pack.points.size(), 3, "the packs keep the hex-to-hex lines, no arcs")
	assert_true(absf(pack.duration - 2.0 * STEP / 100.0) < 0.05, "at their flat step (%f)" % pack.duration)
	var still := MovePath.build([Vector2.ONE], 100.0)
	assert_eq(still.duration, 0.0, "a one-hex route takes no time")
