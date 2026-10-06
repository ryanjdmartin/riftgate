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


func test_an_oversteering_nose_swings_into_each_corner_without_a_jolt() -> void:
	# Ryan, 5 October, the sixth notes: the drift's rear swung out with a jerk as each corner
	# began, three for the hangar's three turns. The tangent swings at once where a corner's arc
	# begins; the nose now aims at the path's heading averaged about now and a moment ahead
	# (MovePath.chord) and turns there on a spring, so its turn rate eases in and out, where the
	# old aim (the tangents) and chase (first order) changed it by a jump a frame.
	var mp := MovePath.build(_route([0, 0, 60, 60, 0, -60]), 120.0, 0.7)   # a quick machine, three corners
	var dt := 1.0 / 60.0
	var yaw := func(v: Vector2) -> float: return atan2(-v.x, -v.y)
	var start: float = yaw.call(mp.at(0.0)[1])
	var facing := start
	var vel := 0.0
	var old := start
	var prev_vel := 0.0
	var prev_old_vel := 0.0
	var worst := 0.0
	var worst_old := 0.0
	var widest := 0.0
	var w := Map3D.OVERSTEER_WINDOW * 0.5
	var base := start
	var ahead := start
	var t := 0.0
	while t < mp.duration:
		var heading: float = yaw.call(mp.at(t)[1])
		var cb := mp.chord(t - w, t + w)
		var ca := mp.chord(t + Map3D.OVERSTEER_AHEAD - w, t + Map3D.OVERSTEER_AHEAD + w)
		if cb != Vector2.ZERO:
			base = yaw.call(cb)   # off the curve's end the chord has no length, and the map keeps the last
		if ca != Vector2.ZERO:
			ahead = yaw.call(ca)
		var want := base + Map3D.oversteer_lead(wrapf(ahead - base, -PI, PI), 1.0)
		var turned := Map3D.turn_toward(facing, vel, want, Map3D.OVERSTEER_RATE, dt)
		facing = turned.x
		vel = turned.y
		worst = maxf(worst, absf(vel - prev_vel))
		prev_vel = vel
		var old_ahead: float = yaw.call(mp.at(t + Map3D.OVERSTEER_AHEAD)[1])
		var old_want := heading + clampf(wrapf(old_ahead - heading, -PI, PI) * Map3D.OVERSTEER_GAIN, -0.8, 0.8)
		var step := wrapf(old_want - old, -PI, PI) * (1.0 - exp(-dt * Map3D.OVERSTEER_RATE))
		old += step
		worst_old = maxf(worst_old, absf(step / dt - prev_old_vel))
		prev_old_vel = step / dt
		widest = maxf(widest, absf(wrapf(facing - heading, -PI, PI)))
		t += dt
	assert_true(widest > 0.15, "the nose does lead the path into its corners (%f radians at most)" % widest)
	assert_true(worst < worst_old * 0.5, "its turn rate eases where the old aim and chase jumped (%f against %f a frame)" % [worst, worst_old])
	var settled := Vector2(0.0, 0.0)
	for i in range(240):
		settled = Map3D.turn_toward(settled.x, settled.y, 1.0, 4.0, dt)
	assert_true(absf(settled.x - 1.0) < 0.001 and absf(settled.y) < 0.001, "and it settles where it is sent, without ringing")


func test_a_corner_eases_its_turn_in_and_out() -> void:
	# Ryan, 6 October, the seventh notes: the drift still jerked as each corner began. A quadratic
	# arc's curvature starts at once where it leaves the straight, so a quick machine's travel
	# went from straight to turning at about 1.75 radians a second in a frame; a corner is a
	# quintic now, its curvature rising from nothing, so the turn rate builds over the corner.
	var mp := MovePath.build(_route([0, 0, 60, 60, 0, -60]), 120.0, 0.7)
	var dt := 1.0 / 60.0
	var prev: Vector2 = mp.at(0.0)[1]
	var prev_rate := 0.0
	var worst := 0.0
	var fastest := 0.0
	var t := dt
	while t < mp.duration:
		var here: Vector2 = mp.at(t)[1]
		var rate := prev.angle_to(here) / dt
		worst = maxf(worst, absf(rate - prev_rate))
		fastest = maxf(fastest, absf(rate))
		prev = here
		prev_rate = rate
		t += dt
	assert_true(worst < 0.8, "the travel's turn rate changes by little in a frame (%f radians a second)" % worst)
	assert_true(fastest > 2.0, "and the corners still turn it briskly at their middle (%f)" % fastest)
	var c := [Vector2(0, 0), Vector2(4, 0), Vector2(8, 0), Vector2(10, 2), Vector2(10, 6), Vector2(10, 10)]
	var d0 := MovePath.quintic(c, 0.01) - MovePath.quintic(c, 0.0)
	var d1 := MovePath.quintic(c, 0.02) - MovePath.quintic(c, 0.01)
	assert_true(absf(d0.angle_to(d1)) < 0.001, "a quintic leaves its first leg without turning")
