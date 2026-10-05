class_name HoverBalance
extends RefCounted

## A hovercraft holding station on its cushion (Ryan, 5 October: not the flyers' bob and
## turn, but someone balancing on a platform in the water, the attitude adjusting in every
## direction as the currents change, always trying to stay level). Its attitude is a mass
## on a spring a little under critical damping, the hover's own trim, pushed toward a lean
## by slow currents that wander round every direction and now and then knocked by a gust,
## so it tips off level, catches itself and settles with a touch of overshoot, never quite
## still. A heave rides with it: a slow swell, and a dip at each gust that it climbs back
## out of. Deterministic for a seed, stepped at a fixed rate whatever the frame rate. The
## hangar's port is HoverBalance in tools/hangar_motion.js: keep the two in step.
## A gust is a push over half a second, never a knock in one frame, and while the machine plays
## an act (`quiet`) no gust comes and the whole balance eases down to a third (Ryan, 5 October,
## the sixth notes: a gust jerked the Stingray in the middle of its scan).

const OMEGA := 3.2                    # the trim's natural frequency, radians a second
const ZETA := 0.3                     # its damping: under critical, so a correction overshoots a little
const CURRENT := 0.05                 # radians of lean the currents push toward, at most
const GUST := 0.22                    # radians a second a gust knocks the lean
const GUST_GAP := Vector2(1.3, 3.4)   # seconds between gusts
const HEAVE_OMEGA := 2.6
const HEAVE_ZETA := 0.4
const SWELL := 0.8                    # units the swell lifts and drops it, at most
const HEAVE_GUST := 3.0               # units a second a gust pushes it down
const STEP := 1.0 / 120.0
const GUST_TIME := 0.5                # seconds a gust pushes for
const QUIET := 0.35                   # the balance's share while an act plays
const QUIET_RATE := 1.5               # per second: how briskly it eases to and from quiet

var pitch := 0.0   # radians, the nose up
var roll := 0.0    # radians, about the forward axis as the view's pivot turns it
var heave := 0.0   # model units up
var quiet := false # set while the machine plays an act: no gusts, the balance eased down

var _k := 1.0                 # the balance's share now, easing toward 1 or QUIET
var _push := Vector3.ZERO     # the gust pushing now: (pitch, roll, heave) rates it adds in all
var _push_t := GUST_TIME      # seconds into it
var _pitch := 0.0             # the balance unscaled; pitch, roll and heave are these times _k
var _roll := 0.0
var _heave := 0.0

var _rate := Vector2.ZERO   # (pitch, roll) a second
var _heave_rate := 0.0
var _t := 0.0
var _acc := 0.0
var _next_gust := 0.0
var _phase: Array = []
var _rng := RandomNumberGenerator.new()


func _init(seed_value: int = 1) -> void:
	_rng.seed = seed_value
	for i in range(5):
		_phase.append(_rng.randf() * TAU)
	_next_gust = _rng.randf_range(0.4, GUST_GAP.y)


## The lean the currents push toward at time `t`, (pitch, roll): two slow waves each way out
## of step, so the push wanders round every direction and never repeats on a beat.
func current(t: float) -> Vector2:
	return Vector2(sin(t * 0.53 + _phase[0]) * 0.6 + sin(t * 1.27 + _phase[1]) * 0.4,
			sin(t * 0.71 + _phase[2]) * 0.6 + sin(t * 1.53 + _phase[3]) * 0.4) * CURRENT


func step(dt: float) -> void:
	_acc += minf(dt, 0.25)
	while _acc >= STEP:
		_acc -= STEP
		_t += STEP
		_k = move_toward(_k, QUIET if quiet else 1.0, QUIET_RATE * STEP)
		if _t >= _next_gust:
			if not quiet:
				var a := _rng.randf() * TAU
				var k := _rng.randf_range(0.6, 1.0)
				_push = Vector3(cos(a) * GUST * k, sin(a) * GUST * k, -HEAVE_GUST * k)
				_push_t = 0.0
			_next_gust = _t + _rng.randf_range(GUST_GAP.x, GUST_GAP.y)
		var shove := Vector3.ZERO
		if _push_t < GUST_TIME:
			# A half sine over GUST_TIME, adding the whole push by its end.
			shove = _push * (sin(PI * _push_t / GUST_TIME) * PI / (2.0 * GUST_TIME))
			_push_t += STEP
		var att := Vector2(_pitch, _roll)
		_rate += ((current(_t) - att) * OMEGA * OMEGA - _rate * (2.0 * ZETA * OMEGA) + Vector2(shove.x, shove.y)) * STEP
		att += _rate * STEP
		_pitch = att.x
		_roll = att.y
		var swell := sin(_t * 0.9 + _phase[4]) * SWELL
		_heave_rate += ((swell - _heave) * HEAVE_OMEGA * HEAVE_OMEGA - _heave_rate * (2.0 * HEAVE_ZETA * HEAVE_OMEGA) + shove.z) * STEP
		_heave += _heave_rate * STEP
		pitch = _pitch * _k
		roll = _roll * _k
		heave = _heave * _k
