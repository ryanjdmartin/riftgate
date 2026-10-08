class_name MovePath
extends RefCounted

## A machine's move on the map as a curve and a speed along it (Ryan, 4 October: too fast, no
## acceleration, hard corners). The hex centres of the route become one smooth curve: each
## interior corner is cut by a curve, the endpoints and the last step's direction kept,
## so the machine ends on its hex facing the way the simulation records. Along the curve the
## speed starts at rest, accelerates at the machine's rate, holds its full speed through the
## corners (Ryan, 4 October, the third pass: braking for them was not needed) and comes to
## rest at the end: the classic forward and backward pass over a speed limit. Pure arithmetic
## in map pixels, so it runs headless and the hangar page ports it (tools/hangar_motion.js,
## Route) line for line.
## A corner is a quintic, not a quadratic (Ryan, 6 October, the seventh notes: the drift still
## jerked as each corner began): its first and last three control points lie along the legs,
## so its curvature rises from nothing on the straight and falls back to nothing, and a
## machine's turn rate eases in and out of every corner instead of stepping at the arc's start.
##
## The number per machine lives in its rig sidecar's `move` (written by lowforge's b.move):
## `accel`, the seconds it takes from rest to full speed. A machine without it takes the
## default below.

const CUT := 0.42            # each corner's arc starts this share of the way along its legs (at most half)
const ARC_STEPS := 24        # samples per corner arc
const ACCEL_DEFAULT := 0.6   # seconds from rest to full speed
const FINE := 24             # samples a straight span is cut into, so the speed profile is smooth within a hex

var points: PackedVector2Array = PackedVector2Array()   # the curve, sampled
var arc: PackedFloat32Array = PackedFloat32Array()      # distance along the curve at each sample
var speed: PackedFloat32Array = PackedFloat32Array()    # the speed at each sample, pixels a second
var time: PackedFloat32Array = PackedFloat32Array()     # the time each sample is reached
var duration := 0.0
var lead := 0.0     # seconds it holds at its start before it sets off, turning onto its way (hold_start)


## The curve through `centres` (map pixels), each interior corner cut by a quintic. Each
## sample carries the turn of the corner it belongs to, radians (0 on a straight).
static func smooth(centres: Array) -> Array:
	var pts: Array = []
	var turns: Array = []
	if centres.size() < 2:
		for c in centres:
			pts.append(c)
			turns.append(0.0)
		return [pts, turns]
	pts.append(centres[0])
	turns.append(0.0)
	for i in range(1, centres.size() - 1):
		var a: Vector2 = centres[i - 1]
		var p: Vector2 = centres[i]
		var b: Vector2 = centres[i + 1]
		var din := (p - a).normalized()
		var dout := (b - p).normalized()
		var turn := absf(din.angle_to(dout))
		if turn < 0.01:
			pts.append(p)
			turns.append(0.0)
			continue
		var p1 := p + (a - p) * CUT
		var p2 := p + (b - p) * CUT
		var ctrl := [p1, p1.lerp(p, 0.4), p1.lerp(p, 0.8), p2.lerp(p, 0.8), p2.lerp(p, 0.4), p2]
		for k in range(ARC_STEPS + 1):
			pts.append(quintic(ctrl, float(k) / ARC_STEPS))
			turns.append(turn)
	pts.append(centres[centres.size() - 1])
	turns.append(0.0)
	return [pts, turns]


## A quintic Bezier through its six control points at `t`.
static func quintic(c: Array, t: float) -> Vector2:
	var s := 1.0 - t
	var w := [s * s * s * s * s, 5.0 * t * s * s * s * s, 10.0 * t * t * s * s * s, 10.0 * t * t * t * s * s, 5.0 * t * t * t * t * s, t * t * t * t * t]
	var out := Vector2.ZERO
	for i in range(6):
		out += (c[i] as Vector2) * float(w[i])
	return out


## The move: `centres` in map pixels, `top` the full speed in pixels a second, `accel_s` the
## seconds from rest to full speed. `smooth_corners` false keeps the hex-to-hex lines (the
## packs, which are pictures).
static func build(centres: Array, top: float, accel_s: float = ACCEL_DEFAULT, smooth_corners: bool = true) -> MovePath:
	var mp := MovePath.new()
	var sm: Array = smooth(centres) if smooth_corners else [centres, centres.map(func(_c): return 0.0)]
	var pts: Array = []
	# Long straight spans cut fine, so a machine reaching full speed partway along one is timed
	# by the samples, not by a whole hex's average.
	var coarse: Array = sm[0]
	for i in range(coarse.size()):
		if i > 0 and float(sm[1][i]) == 0.0 and float(sm[1][i - 1]) == 0.0 and smooth_corners:
			var a0: Vector2 = coarse[i - 1]
			var b0: Vector2 = coarse[i]
			for k in range(1, FINE):
				pts.append(a0.lerp(b0, float(k) / FINE))
		pts.append(coarse[i])
	# Drop repeated points, so no segment has zero length.
	var clean: Array = []
	for i in range(pts.size()):
		if clean.is_empty() or (pts[i] as Vector2).distance_to(clean[clean.size() - 1]) > 0.001:
			clean.append(pts[i])
	mp.points = PackedVector2Array(clean)
	var n := clean.size()
	mp.arc.resize(n)
	mp.speed.resize(n)
	mp.time.resize(n)
	if n < 2 or top <= 0.0:
		return mp
	mp.arc[0] = 0.0
	for i in range(1, n):
		mp.arc[i] = mp.arc[i - 1] + (clean[i] as Vector2).distance_to(clean[i - 1])
	var a := top / maxf(0.05, accel_s)
	# The limit at each sample: full speed, corners and all.
	var lim: Array = []
	for i in range(n):
		lim.append(top)
	if smooth_corners:   # a machine starts and ends at rest; a pack keeps its flat step
		lim[0] = 0.0
		lim[n - 1] = 0.0
	# Forward: no faster than accelerating from the last sample allows.
	var v: Array = lim.duplicate()
	for i in range(1, n):
		var ds := mp.arc[i] - mp.arc[i - 1]
		v[i] = minf(float(v[i]), sqrt(float(v[i - 1]) * float(v[i - 1]) + 2.0 * a * ds))
	# Backward: no faster than braking to the next sample allows.
	for i in range(n - 2, -1, -1):
		var ds := mp.arc[i + 1] - mp.arc[i]
		v[i] = minf(float(v[i]), sqrt(float(v[i + 1]) * float(v[i + 1]) + 2.0 * a * ds))
	mp.time[0] = 0.0
	for i in range(n):
		mp.speed[i] = float(v[i])
	for i in range(1, n):
		var ds := mp.arc[i] - mp.arc[i - 1]
		var avg := maxf(0.5 * (mp.speed[i - 1] + mp.speed[i]), top * 0.02)
		mp.time[i] = mp.time[i - 1] + ds / avg
	mp.duration = mp.time[n - 1]
	return mp


## Hold the move at its start for `seconds` before it sets off (Ryan, 7 October, the twentieth
## notes: a machine turns onto its way at a measured pace before it rolls; Map3D.setoff_seconds).
func hold_start(seconds: float) -> void:
	lead = maxf(0.0, seconds)
	duration = (time[time.size() - 1] if time.size() > 0 else 0.0) + lead


## Where the move is at time `t`: [position, unit tangent, speed, distance along it]. Within
## a span the speed changes evenly with time, so the distance follows the area under it.
## The direction from where the curve is at `t0` to where it is at `t1` (times clamped to the
## curve): the path's heading averaged over that stretch, which turns smoothly through a corner
## where the tangent swings at once (Ryan, 5 October, the sixth notes: the drifting nose took
## each corner's start as a jolt). Zero when the stretch has no length.
func chord(t0: float, t1: float) -> Vector2:
	var d: Vector2 = (at(t1)[0] as Vector2) - (at(t0)[0] as Vector2)
	return d.normalized() if d.length() > 0.001 else Vector2.ZERO


## The heading averaged about `t`, `half` seconds either side, its middle counting most: the
## chords of the whole stretch and of two shorter ones nested in it (two thirds and a third of
## it), the shorter weighted by `taper` and all summed (Ryan, 6 October, the fourteenth notes:
## the drift's nose turned in too soon again). At a taper of 0 it is the plain chord; at 1 a
## corner reaching the stretch's far end turns it a third as much, so a drifter's nose starts
## in later while the whole stretch still carries it through a double corner as one sweep.
func chord_tapered(t: float, half: float, taper: float) -> Vector2:
	var sum := Vector2.ZERO
	for j in range(1, 4):
		sum += chord(t - half * j / 3.0, t + half * j / 3.0) * (1.0 if j == 3 else taper)
	return sum.normalized() if sum.length() > 1e-6 else Vector2.ZERO


func at(t: float) -> Array:
	t -= lead
	var n := points.size()
	if n == 0:
		return [Vector2.ZERO, Vector2.ZERO, 0.0, 0.0]
	if n == 1 or t <= 0.0:
		return [points[0], _tangent(0), 0.0, 0.0]
	if t >= time[n - 1]:
		return [points[n - 1], _tangent(n - 2), 0.0, arc[n - 1]]
	var i := time.bsearch(t, true) - 1
	i = clampi(i, 0, n - 2)
	var dt := time[i + 1] - time[i]
	var u := 0.0 if dt <= 0.0 else (t - time[i]) / dt
	var v := lerpf(speed[i], speed[i + 1], u)
	var ds := arc[i + 1] - arc[i]
	var d := (speed[i] * u + 0.5 * (speed[i + 1] - speed[i]) * u * u) * dt   # distance into the span
	var f := 0.0 if ds <= 0.0 else clampf(d / ds, 0.0, 1.0)
	return [points[i].lerp(points[i + 1], f), _tangent_at(i, f), v, arc[i] + d]


func _tangent(i: int) -> Vector2:
	if points.size() < 2:
		return Vector2.ZERO
	i = clampi(i, 0, points.size() - 2)
	return (points[i + 1] - points[i]).normalized()


## The heading `f` of the way along span `i`, turning evenly from the tangent at one sample to
## the tangent at the next (Ryan, 5 October: a corner's arc is a few straight spans, and the
## heading stepped round it in jumps a slow machine showed), each sample's the direction across
## its two neighbours.
func _tangent_at(i: int, f: float) -> Vector2:
	var t := _sample_tangent(i).lerp(_sample_tangent(i + 1), f)
	return t.normalized() if t.length_squared() > 1e-8 else _tangent(i)


func _sample_tangent(k: int) -> Vector2:
	var n := points.size()
	if k <= 0 or k >= n - 1:
		return _tangent(k if k <= 0 else n - 2)
	var t := points[k + 1] - points[k - 1]
	return t.normalized() if t.length_squared() > 1e-8 else _tangent(k)
