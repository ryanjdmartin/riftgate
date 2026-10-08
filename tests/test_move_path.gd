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


func test_a_move_setting_off_across_its_facing_turns_without_a_jolt() -> void:
	# Ryan, 6 October, the eighth notes: a frame jerk at the corners, worse each time the drift
	# was made harder. A move setting off sixty degrees from where the machine faced (every move
	# of the hangar's route, after its turn) sent the aim there at once, and the facing's spring
	# took it at its full turning acceleration in a frame. The aim eases in over SETOFF_S now.
	var dt := 1.0 / 60.0
	var worst := [0.0, 0.0]
	for eased in [false, true]:
		var facing := 0.0
		var vel := 0.0
		var prev_acc := 0.0
		var state := [0.0, 0.0]
		for i in range(90):
			state[1] = float(state[1]) + dt
			var want := Map3D.setoff_aim(state, PI / 3.0) if eased else PI / 3.0
			var turned := Map3D.turn_toward(facing, vel, want, Map3D.OVERSTEER_RATE, dt)
			var acc := (turned.y - vel) / dt
			worst[int(eased)] = maxf(float(worst[int(eased)]), absf(acc - prev_acc))
			prev_acc = acc
			facing = turned.x
			vel = turned.y
		if eased:
			assert_true(absf(facing - PI / 3.0) < 0.01, "and it still comes round onto the path (%f)" % facing)
	assert_true(float(worst[1]) < 6.0, "the turn's acceleration builds a little a frame (%f radians a second squared)" % worst[1])
	assert_true(float(worst[0]) > 20.0, "where the aim sent at once jumped it (%f)" % worst[0])
	assert_true(is_equal_approx(Map3D.setoff_aim([1.0, 0.0], 2.0), 1.0) and is_equal_approx(Map3D.setoff_aim([1.0, Map3D.SETOFF_S], 2.0), 2.0), "from the facing it stood at to the path's aim")


func test_a_drifter_eases_into_its_kick_out() -> void:
	# Ryan, 6 October, the ninth notes: ease into the kick-out, not so sudden, to help the
	# whipping. A drifter (oversteer 2) looks further ahead over a longer stretch and chases its
	# lead on a softer spring: its nose turns slower at its quickest, for about the same kick,
	# than it would on the jets' numbers.
	var mp := MovePath.build(_route([90, 90, 90, 30, -30]), 110.0, 0.5)   # the hangar's first move: three north, a turn through north-east to south-east
	var dt := 1.0 / 60.0
	var yaw := func(v: Vector2) -> float: return atan2(-v.x, -v.y)
	var runs := []
	for drifter in [false, true]:
		var over := 2.0
		var ah: float = Map3D.oversteer_ahead(over) if drifter else Map3D.OVERSTEER_AHEAD
		var w: float = (Map3D.oversteer_window(over) if drifter else Map3D.OVERSTEER_WINDOW) * 0.5
		var rate: float = Map3D.oversteer_rate(over) if drifter else Map3D.OVERSTEER_RATE
		var top: float = Map3D.oversteer_max(over) if drifter else Map3D.OVERSTEER_MAX
		var facing: float = yaw.call(mp.at(0.0)[1])
		var vel := 0.0
		var fastest := 0.0
		var kick := 0.0
		var t := 0.0
		var taper: float = Map3D.oversteer_ease(over) if drifter else 0.0
		var gain: float = Map3D.oversteer_gain(over) if drifter else Map3D.OVERSTEER_GAIN
		while t < mp.duration:
			var base: float = yaw.call(mp.chord_tapered(t, w, taper))
			var ca := mp.chord_tapered(t + ah, w, taper)
			var ahead: float = yaw.call(ca) if ca != Vector2.ZERO else base
			var want := base + top * tanh(wrapf(ahead - base, -PI, PI) * gain * over / top)
			var turned := Map3D.turn_toward(facing, vel, want, rate, dt)
			facing = turned.x
			vel = turned.y
			fastest = maxf(fastest, absf(vel))
			kick = maxf(kick, absf(wrapf(facing - float(yaw.call(mp.at(t)[1])), -PI, PI)))
			t += dt
		runs.append([fastest, kick])
	assert_true(float(runs[1][0]) < float(runs[0][0]) * 0.8, "the nose whips round slower (%f against %f radians a second)" % [runs[1][0], runs[0][0]])
	assert_true(float(runs[1][1]) > float(runs[0][1]) * 0.85, "for about the same kick (%f against %f radians)" % [runs[1][1], runs[0][1]])


## A drifter's nose on the hangar's first move (three north, then north-east and south-east):
## [when it is a tenth of the way to its kick, the kick, how much its turn quickens again after
## its quickest, before it eases out, against its quickest], its stretch tapered by `taper`.
func _drift(mp: MovePath, over: float, taper: float) -> Array:
	var dt := 1.0 / 60.0
	var yaw := func(v: Vector2) -> float: return atan2(-v.x, -v.y)
	var w := Map3D.oversteer_window(over) * 0.5
	var ah := Map3D.oversteer_ahead(over)
	var facing: float = yaw.call(mp.at(0.0)[1])
	var vel := 0.0
	var base := facing
	var ahead := facing
	var leads: Array = []
	var rates: Array = []
	var t := 0.0
	while t < mp.duration:
		var cb := mp.chord_tapered(t, w, taper)
		var ca := mp.chord_tapered(t + ah, w, taper)
		if cb != Vector2.ZERO:
			base = yaw.call(cb)
		if ca != Vector2.ZERO:
			ahead = yaw.call(ca)
		var want := base + Map3D.oversteer_lead(wrapf(ahead - base, -PI, PI), over)
		var turned := Map3D.turn_toward(facing, vel, want, Map3D.oversteer_rate(over), dt)
		facing = turned.x
		vel = turned.y
		leads.append(absf(wrapf(facing - float(yaw.call(mp.at(t)[1])), -PI, PI)))
		rates.append(-vel)   # the route turns right
		t += dt
	var kick: float = leads.max()
	var fastest: float = rates.max()
	var first := 0
	while float(leads[first]) < 0.1 * kick:
		first += 1
	var slowest := fastest
	var again := 0.0
	for i in range(rates.find(fastest), rates.size()):
		if float(rates[i]) < 0.0:
			break   # easing out past the path's last heading
		slowest = minf(slowest, float(rates[i]))
		again = maxf(again, float(rates[i]) - slowest)
	return [first * dt, kick, again / fastest]


func test_a_drifter_turns_in_late_and_sweeps_both_corners_as_one() -> void:
	# Ryan, 6 October, the fourteenth notes: the drift turned in too soon again once the
	# eleventh widened its stretch to carry it through the double corner as one sweep. The
	# stretch's middle now counts most (MovePath.chord_tapered), so a corner at its far end turns
	# the nose a third as much: the nose starts in later, kicks out as far, and still sweeps both
	# corners without slowing between them.
	var mp := MovePath.build(_route([90, 90, 90, 30, -30]), 110.0, 0.5)
	var plain := _drift(mp, 2.0, 0.0)
	var tapered := _drift(mp, 2.0, Map3D.oversteer_ease(2.0))
	assert_true(float(tapered[0]) > float(plain[0]) + 0.1, "the nose starts in later (%f s against %f)" % [tapered[0], plain[0]])
	assert_true(float(tapered[1]) > float(plain[1]) * 0.9, "for about the same kick (%f against %f radians)" % [tapered[1], plain[1]])
	assert_true(float(tapered[2]) < 0.08, "its turn never quickens again between the corners (by %f of its quickest)" % tapered[2])
	var w := 0.6
	assert_true(mp.chord_tapered(1.0, w, 0.0).is_equal_approx(mp.chord(1.0 - w, 1.0 + w)), "untapered, the plain chord")


func test_a_machine_turns_onto_its_way_before_it_sets_off() -> void:
	# Ryan, 7 October, the twentieth notes: the turn at a move's start was a little jumpy, half a
	# second whatever the angle, rolling as it swung. A move now holds at its start while the
	# machine turns onto its way, longer for a bigger turn and a heavier machine.
	var mp := MovePath.build(_route([90, 90, 30]), 120.0, 0.7)
	var arrival := mp.duration
	mp.hold_start(0.8)
	assert_true(is_equal_approx(mp.duration, arrival + 0.8), "the move takes the hold longer (%f)" % mp.duration)
	assert_true((mp.at(0.5)[0] as Vector2).is_equal_approx(mp.points[0]) and is_zero_approx(float(mp.at(0.5)[2])), "it stands on its start through the hold")
	assert_true((mp.at(mp.duration)[0] as Vector2).is_equal_approx(mp.points[mp.points.size() - 1]), "and arrives where it did")
	var sixth := Map3D.setoff_turn(PI / 3.0, 1.0)
	assert_true(Map3D.setoff_turn(PI, 1.0) > sixth * 1.5, "a half turn takes longer than a sixth (%f against %f)" % [Map3D.setoff_turn(PI, 1.0), sixth])
	assert_true(Map3D.setoff_turn(PI / 3.0, 1.4) > Map3D.setoff_turn(PI / 3.0, 0.5), "and a heavy machine longer than a light one")
	assert_true(sixth > Map3D.SETOFF_S, "every real turn slower than the old half second (%f)" % sixth)
	assert_true(is_zero_approx(Map3D.setoff_turn(0.0, 1.0)), "and none at all when it already faces its way")

