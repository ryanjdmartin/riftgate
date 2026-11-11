class_name MechRig
extends RefCounted

## A machine's joints and what its pilot does with them: the idle acts (decided 2 October,
## the bible's idle-acts row) and the strikes. One rig drives one instanced model, in the
## skirmish (MechView3D) or on the map (Map3D), from the model's own sidecar,
## art/models/<id>.rig.json, written by tools/lowforge beside the glTF: every joint's
## axis, its limits and its parent, the acts as keyframes, and the cornering numbers. No
## runtime code keys on a chassis id; a model with no sidecar has joints by name alone and
## no acts, and stands still.
##
## The model's tags (tools/lowforge/bl_low.py): `joint_<name>` is a pivot with the limb's
## parts under it, nested where it rides another joint; `hp_<n>` is a weapon socket with its
## stock part under it. Both come through the glTF as plain Node3Ds by name.
##
## Angles are authored in the machine's own terms and turned into the node's Euler here:
## pitch about the axle line (x; positive raises the forward end), yaw about up (y; positive
## turns left), roll about forward (positive drops the right side). Blender's y forward is
## Godot's -z, so a roll of +r is rotation.z = -r and a slide (dx, dy, dz) is (dx, dz, -dy).
##
## A grounded machine never sways or bobs (Ryan, 2 October): every few seconds it plays one
## of its own acts, never the same one twice running, each instance on its own clock so a
## team is never in step. RIFTGATE_ACTS_DEBUG=1 plays the acts back to back for judging
## them running; RIFTGATE_ACTS_DEBUG=<act name> loops that one act.
##
## Weight (Ryan, 4 October, the third pass: some acts stilted, bank and hard stop; real
## machines with real physics, limbs and weapons heavy, with inertia): an act's keys are a
## curve that runs on through a key a part passes on its way (it stops only to turn back or
## to hold), and what the curve asks of each part is chased by a servo, a mass on a damped
## spring, the machine's `heft` its time constant: a part gathers speed, carries a touch past
## its mark and settles, and a heavy machine lags its pilot more than a light one.
##
## Movement (the joints row, 2 October): while the map moves a machine, `drive` feeds the rig
## its speed, the bearing it is travelling on relative to its facing, and how fast its facing
## is turning, and the sidecar's gait answers: cycles keyed by distance travelled (a walk,
## stride by stride, so a slow machine steps slowly), wheels spun by their radius, treads
## scrolled, steering knuckles turned with the turn and casters pointed along the travel,
## offsets held while moving (the Badger's booms lifting the claw), boosters brightening, a
## rock on pulling away and stopping, and a bank into turns for what flies. The map's
## cornering module owes the rig the numbers (Map3D). A helicopter-style machine (Ryan, 3
## October: the Stingray, and one or two more to come) keeps its facing and tilts toward
## its travel instead: nose down to go forward, nose up to go back, a side down to go that
## way (`tilt` in its cornering numbers; the map holds its facing through `strafe`). A
## turret turns with the hull on the move (Ryan, 4 October: holding its aim was not worth
## the complexity). RIFTGATE_MOVE_DEBUG=1 drives every machine constantly at its own full
## speed on the map (`top_speed`, map_speed), on both screens, for judging a gait running.
##
## A count display (the sidecar's `counts`, b.count: the Cassowary's capacitor, 2 November) lights
## the first n of its parts for a number the screen passes as it refreshes (show_counts, one of
## COUNT_SOURCES), and a number that falls flares them all and lets them go dark, a discharge. A
## spin may be held while the machine carries a status (the sidecar's `spin_held`, b.spin_held:
## the capacitor turns while Spun Up), eased up to speed and down again. RIFTGATE_COUNT_DEBUG=1
## counts every display up a part a second until it falls; RIFTGATE_SPIN_DEBUG=1 holds every
## status's spin and lets it go in turn; both on both screens, to judge them running.
##
## An act may lock a spinner with a step (the sidecar's `spin_step` and an act's `locks`, b.spin's
## step: the Cottonmouth's drum, its chamber 60 degrees, Ryan, 2 November): as the act starts the
## spin parks on its next step ahead, the way it turns, over PARK_TIME, and holds there while the
## act plays, the act's own track on it adding whole steps; when the act ends that turn goes into
## the spin's own, so nothing unwinds, and the idle turn takes up again from where it stands.

const GAP_MIN := 6.0          # seconds between acts, at least (Ryan, 7 October: from 2.5, as the acts overlapped too often)
const GAP_MAX := 12.0         # and at most (from 6.5)
const OPEN_FIRST := 2.0       # seconds: the first machine in a place opens within this of the screen loading
const OPEN_GAP := 1.5         # and each machine set up with it opens at least this long after the one before
const OPEN_JITTER := 0.8      # plus up to this, so the openings are not a metronome
const GAP_DEBUG := 0.4        # with the debug switch on
const WAIT_TICK_MAX := 0.1    # seconds of the gap a single tick may spend, however long the frame (a hitch must not start every machine at once)
const GLOW_BASE := 1.8        # the amber role's emission at rest (MechView3D.toon), before light() eases it
const LIGHT_EASE := 1.0 / 2.2 # the power a lit part's light is eased by on the phone's renderer (light())
static var _eases_light := -1   # whether light() eases: unknown until first asked (the renderer's known once the screen is up)
const HALO_FULL := 8.0        # a halo is full once its part's light stands this many rests over its own (_light_to)
const HALO_SPREAD := 0.025    # how far a halo stands out, a share of its machine's longest side (_setup_halos)
const HALO_REACH := 0.45      # the share of its part's colour a halo adds at its fullest (halo.gdshader)
const HALO_AHEAD := 3.0       # how far toward the eye a halo is drawn, in its part's units: out of a slot over its walls; a part standing proud names its own (_setup_halos)
const JOLT_SHARE := 0.045     # a blow on the hull shoves the machine back this share of its longest side (jolt),
const JOLT_PITCH := 6.0       # rocking its nose up this many degrees,
const JOLT_UP := 0.05         # in this many seconds,
const JOLT_DOWN := 0.34       # and settling back over this long
const GUTTER := 0.9           # a machine lost: its lit parts gutter out over this many seconds (kill)
# And then it slumps (Ryan, 3 November: "they should slump or collapse after, limbs dropping, flyers
# and hovers landing, fans stopping, idle spins stopping"), one rule every model shares, worked on
# its own frame; the second notes the same day: "don't fall through the floor, and don't do weird
# impossible leans ... it can keep its feet planted and just sink using its ankles and knees. Same
# with the bipeds, sink using knees and ankles and only slump forward at the waist. The bipeds also
# swing their arms behind them when they should just go slack at the elbows" (_collapse_wants).
const COLLAPSE_AT := 0.3       # seconds into the gutter that a lost machine starts to go
const COLLAPSE_HEFT := 0.3     # its servos' time constant as it goes: a drop with weight, not a pose
const COLLAPSE_SINK := 0.28    # a walker sinks this share of its shortest planted limb's height, each foot where it stands
const COLLAPSE_WAIST := 16.0   # a biped's waist slumps forward this many degrees (a walker with a hand on the floor keeps its back)
const COLLAPSE_PASSES := 2     # how often the slack joints settle, each hanging what it carries from where the last pass left it
const COLLAPSE_TOUCH := 0.02   # a limb whose end comes within this share of the machine's size of the floor stands on it
const SPIN_STOP := 1.4         # seconds its fans, rotors and idle spins take to run down
## The joints the slack leaves alone (a leg's, which sinks planted or stays, a waist, which slumps,
## a spin, a mechanism, a turn about up), by how their names begin.
const COLLAPSE_SKIP := ["hip", "knee", "ankle", "toe", "foot", "coxa", "wheel", "steer", "caster", "tread", "rotor",
	"fan", "drum", "louvre", "shutter", "vent", "valve", "run", "salvo", "top_mouth", "top_lamp", "cell", "recoil",
	"capacitor", "rudder", "waist", "yaw", "turret", "sensor", "eye"]
const FLASH_PEAK := 12.0      # a weapon's fire flaring as it fires (flash): this many rests over its own at the top,
const FLASH_UP := 0.05        # reached in this many seconds,
const FLASH_HOLD := 0.15      # held this long,
const FLASH_DOWN := 0.6       # and gone in this long, easing out
const HALO_SHADER := preload("res://game/ui/halo.gdshader")
static var _halo_meshes: Dictionary = {}   # "<mesh id>:<surface>" -> the halo's shell, its normals smoothed, built once a mesh
const MOVE_REF_SPEED := 150.0 # model units a second the slide and the tilt are authored at (a machine's own full speed on the map is `top_speed`)
const MOVE_BLEND_IN := 0.25   # seconds a gait takes to come up from standing
const MOVE_BLEND_OUT := 0.35  # and to settle back when the machine stops
const ROCK_ACCEL := 200.0     # model units a second squared that earns the whole rock: a machine reaching full speed in under a second (MovePath accelerates; was 1500 when moves started at full speed)
const BANK_TURN := 1.2        # radians a second of turning that earns the whole bank (the curve's corners turn about this fast)
const STEER_EASE := 0.12      # seconds a steered joint (a knuckle, a nacelle) takes to follow the turn: its servo
# Turning in place steps the legs round (Ryan, 7 October, the twentieth notes: a machine turns
# onto its way before it sets off, and a walker turning on the spot slid round on its feet):
# the turn counts toward the gait's travel as though each foot went round a circle PIVOT_STEP
# of a stride across, never faster than PIVOT_CAP of its own full speed (the twenty-first
# notes: some stepped round faster than they walk, which read as skating; 0.5 and no cap
# before; the twenty-second: 0.4 was too slow, up to three quarters), fading out as the
# machine gathers PIVOT_FADE units a second of its own; a turn
# slower than PIVOT_MIN radians a second is a settle, not a step. Nothing banks standing: the
# bank comes in with BANK_SPEED units a second.
const PIVOT_STEP := 0.35
const PIVOT_CAP := 0.75
const PIVOT_FADE := 20.0
const PIVOT_MIN := 0.15
const BANK_SPEED := 37.5
const DRIFT_UNITS := 12.0     # model units a machine with a slide of 1 drifts off its path when the travel is square to its facing
const HEFT_DEFAULT := 0.12    # seconds: the inertia of a machine whose sidecar names none (`move.heft`)
const DAMPING := 0.7          # the joints' servos: a touch under critical, so a heavy part gives a little past its mark and settles
const FORM_DEBUG_PERIOD := 2.5  # seconds a form is held, then let go, under RIFTGATE_SEAL_DEBUG
const RECOIL_SLIDE := 1.5       # world units a gun that only runs in and out of its port kicks back along its line on a shot
const RECOIL_BODY := 1.2        # model units the whole machine kicks back along a gun's line when it fires from a mount on the body
const AIM_UP := 0.22            # seconds a machine takes to turn onto its target before it fires (aim), the blow and its sound waiting on it (Ryan, 2 November: "make sure that the turns or aims happen before the sound effects"),
const AIM_DOWN := 0.5           # and to turn back once the blow has landed
const FIRE_HEFT := 0.1          # a firing slice's weight: snappier than an idle act's, so its wind-up lands on the blow
const COUNT_SOURCES := ["shots", "ammo"]   # the numbers a count display may show, as the skirmish passes them (MechView3D.count_values)
const COUNT_RISE := 0.08        # seconds a count display's part takes to light, its servo's time constant
const COUNT_FALL := 0.35        # and to go dark again, a flare's fading included
const COUNT_DEBUG_PERIOD := 1.0 # seconds a step under RIFTGATE_COUNT_DEBUG
const SPIN_HELD_EASE := 0.45    # seconds a status's spin takes to come up to speed, and to run down
const SPIN_DEBUG_PERIOD := 3.0  # seconds a status's spin is held, then let go, under RIFTGATE_SPIN_DEBUG
const PARK_TIME := 0.3          # seconds a locked spin takes to park on its next step ahead
const STEP := 1.0 / 60.0      # the longest step the acts and the servos advance by, so a long tick (a frozen frame) plays the same as frames

var joints: Dictionary = {}        # "shoulder_l" -> Node3D
var hardpoints: Dictionary = {}    # 1 -> Node3D
var meta: Dictionary = {}          # joint name -> {"axis", "limits", "swing", "parent"} (the sidecar; a bare default for an untagged joint)
var acts: Array = []               # the sidecar's acts, in authoring order
var move: Dictionary = {}          # the cornering numbers: {"slide", "bank"}
var model: Node3D = null           # the glTF's root
var body: Node3D = null            # the node a body track moves (the model root unless told otherwise)
var gait: Dictionary = {}          # the sidecar's gait: how this machine moves (see drive)
var gait_options: Dictionary = {}  # other ways it could move, built beside it for judging (b.gait_option); the game uses one only as a gait's start
var _start_gait: Dictionary = {}   # the gait it starts and stops in, when its gait names one: {"gait", "curves", "below", "full"}, and the stride it changes in: "from", "to" and "handoff" (a gait whose stride is its length)
var _travel := 0.0                 # model units travelled since it last stood still
var _start_offset := 0.0           # model units added to the travel for the start gait's phase (it sets off at its handoff's "from")
var _main_offset := 0.0            # and for the gait's own (at the handoff's "to" as it sets off)
var _handoff_at := 0.0             # the travel (`_dist`) the stride it changes in counts from
var _handing := false              # whether it is rolling and the handoff counts (false standing)
var spinners: Dictionary = {}      # joint -> [idle, moving] degrees a second: turned without end on its own axis (b.spin: the Stingray's fans)
var _spun: Dictionary = {}         # joint -> degrees turned so far, wrapped
var spin_steps: Dictionary = {}    # joint -> degrees a step: a spinner an act may lock (b.spin's step; the sidecar's spin_step)
var _locked: Dictionary = {}       # joint -> [from, to, seconds into its park]: a spinner the act playing parks and holds (its `locks`)
var held_spins: Dictionary = {}    # status -> {joint: degrees a second}: turned while the machine carries the status (b.spin_held: the Cassowary's capacitor while Spun Up)
var _held_on: Dictionary = {}      # status -> whether it is held (hold_spin)
var _held_speed: Dictionary = {}   # joint -> degrees a second it turns at now, eased toward what its held statuses ask
var spin_debug: bool = false       # RIFTGATE_SPIN_DEBUG: every status's spin held and let go in turn
var _spin_debug_t := 0.0
var count_displays: Array = []     # [{"source", "parts": [[[material, its light at rest], ...] a part], "on", "off", "flare", "n", "k": [each part's light now]}]: the sidecar's counts (b.count)
var count_debug: bool = false      # RIFTGATE_COUNT_DEBUG: every display counts up a part a second until it falls
var _count_debug_t := 0.0
var forms: Dictionary = {}         # name -> {"duration", "curves": {joint: curve, BODY: the body's}, "glow": [[material, its light at rest, k]], "acts": [act]}: poses held while the machine carries the status of the same name, each with the acts it plays while held (the sidecar's forms: the Polar Bear's seal)
var _form_on: Dictionary = {}      # name -> whether it is held (set_form)
var _form_t: Dictionary = {}       # name -> seconds into its turn: 0 let go, its duration held
var _form_rot: Dictionary = {}     # joint -> degrees the forms add
var _form_slide: Dictionary = {}   # joint -> world-unit slide the forms add
var _form_body_rot := Vector3.ZERO   # degrees (pitch, yaw, roll) the forms add to the body (the seal's hunker)
var _form_body_slide := Vector3.ZERO
var form_debug: bool = false       # RIFTGATE_SEAL_DEBUG: every form held and let go in turn, to judge running
## The pose a machine stands in while a form is not held (the Polar Bear's vents ajar while its shell
## is open; Ryan, 2 November: "When unsealed, the vents should be open, and then more open during
## the vent animation"): joint -> [degrees, slide] over its built rest, fading out as the form named
## by `ajar_unless` turns in. An act that moves the joint opens it the rest of the way: the ajar
## share gives way as the act's own swing grows, so the act still ends where it was authored to,
## never past it. The sidecar's "ajar": {"unless": a form, "joints": {joint: [pitch, yaw, roll(,
## dx, dy, dz)]}}.
var ajar: Dictionary = {}
var ajar_unless := ""
var _ajar_span: Dictionary = {}   # joint -> [degrees, slide]: the furthest any act swings it, axis by axis
var _form_debug_t := 0.0
var debug: String = ""             # RIFTGATE_ACTS_DEBUG, read at setup
var debug_move: bool = false       # RIFTGATE_MOVE_DEBUG: driven constantly
var last_act: String = ""          # the act played last (never played twice running)
var moving: bool = false           # whether the last drive had any speed

var _rest: Dictionary = {}         # joint -> rest rotation
var _rest_pos: Dictionary = {}     # joint -> rest position
var _body_rest_pos := Vector3.ZERO
var _body_rest_rot := Vector3.ZERO
var _act_rot: Dictionary = {}      # joint -> degrees (pitch, yaw, roll) from the act playing
var _act_slide: Dictionary = {}    # joint -> world-unit slide (dx, dy, dz, Blender's axes)
var _strikes: Array = []           # [{joint, vec (degrees), slide (world units, a gun kicking back along its line), up, down, t}]
var _glow: Array = []              # [{mats: [StandardMaterial3D], base: [float]}] per glow track of the act playing
var _glow_cache: Dictionary = {}   # part prefix -> [StandardMaterial3D]
var _halos: Dictionary = {}        # a lit material -> the halos' ShaderMaterials round its surfaces (_setup_halos)
var _standing: Dictionary = {}     # a lit material -> the multiple of its rest light it never falls under (_setup_standing)
var _halo_grow := 0.0              # how far a halo stands out on this model (_setup_halos), for hot parts hung later (wear_hot)
var _flashes: Array = []           # [{mats, base, t}] a weapon's fire flaring (flash)
var dead := false                  # the machine is lost: no acts, its lit parts dark (kill)
var halo_skip: Array = []          # lit parts that wear no halo, set before setup: a booster burning as a plume (MechView3D)
var _gutter := -1.0                # seconds into its lit parts guttering out (kill); negative when not
var _gutter_mats: Array = []       # [material, its light at rest] for every lit part, as the kill found them
var _size := -1.0                  # the model's longest side, measured once (_model_size), for the jolt
var _collapse := -1.0              # seconds since a lost machine was killed, for its slump (kill); negative while standing
var _centroids: Dictionary = {}     # mesh -> [its vertex centroid, its vertex count] (_centroid_of)
var airborne := false              # a flyer or a hover (the view sets it): lost, it comes down onto its lowest point rather than sinking on its limbs
var collapse_floor := 0.0          # the floor a lost machine's slump keeps to, in its own frame: an airborne one's lowest point standing, where the view lands it (MechView3D.lose)
var _spin_k := 1.0                 # how much of its turn every spinner keeps: running down to nothing as a lost machine dies
var _fire_turn: Dictionary = {}    # a fixed component -> how many times it has fired, so its slices take turns (fire_slice)
var _flares: Array = []            # [{node, mat, look, t}] a muzzle flare on its look's beat (fire_flare)
var _aim: Dictionary = {}          # {joint (or BODY), deg, hold, t}: the turn onto a target (aim)
var fires: Dictionary = {}         # a fixed component -> {act, from, to[, blow]} or a list of them taking turns: the slices of acts that are its firing (the sidecar's `fires`)
var aims: Dictionary = {}          # a fixed component -> the joint that turns to aim it, when no waist does (the sidecar's `aims`)
var pivots := false                # the whole machine turns on the spot to aim (the sidecar's `pivots`: a tank's tracks, a castered chassis)
var _until := -1.0                 # where a firing slice playing now ends (fire_act); below nought, the act's own end
var _body_act_rot := Vector3.ZERO  # the act's body track, degrees (pitch, yaw, roll)
var _body_act_slide := Vector3.ZERO
var _body_move_rot := Vector3.ZERO # the gait's body: bob, rock, bank
var _body_move_slide := Vector3.ZERO
var _gait_rot: Dictionary = {}     # joint -> degrees from the gait (cycles, wheels, steering, holds)
var _gait_slide: Dictionary = {}
var _dist := 0.0                   # model units travelled since setup (wheels and strides read it)
var _speed := 0.0                  # model units a second, smoothed
var _blend := 0.0                  # 0 standing, 1 moving: the gait's weight
var _accel := 0.0                  # the smoothed change of speed, for the rock
var _bank := 0.0                   # degrees of roll into the turn, eased
var _tilt := Vector2.ZERO          # degrees of (pitch, roll) toward the travel, a helicopter's, eased
var _steer: Dictionary = {}        # joint -> degrees a steered joint has turned with the turn, eased
var _drift := 0.0                  # model units the body sits off its path, right positive, eased (the slide)
var _tread_mats: Array = []        # [[StandardMaterial3D, base uv offset]] the treads scroll
var _move_glow: Array = []         # [[StandardMaterial3D, base]] the boosters brighten
var _current: Dictionary = {}      # the act playing, or empty
var _curves: Dictionary = {}       # the act playing as curves: joint -> curve, BODY -> curve
var _t := 0.0                      # time into the act playing
var _wait := 0.0                   # seconds until the next act starts
var _rng := RandomNumberGenerator.new()
var _wait_budget := 0.0            # what is left of this tick's share of the gap (WAIT_TICK_MAX)
static var _opening: Dictionary = {}   # place -> the msec clock when the last machine set up there opens (its first act)
var heft := HEFT_DEFAULT           # seconds: how long a joint or the body takes to catch up with what the pilot asks (the sidecar's `move.heft`)
var place: String = ""             # where this machine stands, "map" or "skirmish": an act may be for one of them only (its `places`); empty plays them all
var _act_heft := HEFT_DEFAULT      # the heft while the act playing asks for its own (a blow sharper than the machine's weight)
var top_speed := MOVE_REF_SPEED    # model units a second at this machine's full speed on the map (map_speed; the debug drive's pace)
var _want_rot: Dictionary = {}     # joint -> degrees the act asks for now; the servos chase it into _act_rot
var _want_slide: Dictionary = {}
var _body_want_rot := Vector3.ZERO
var _body_want_slide := Vector3.ZERO
var _servo: Dictionary = {}        # joint (or BODY) -> [rot, rot speed, slide, slide speed]: where each part is and how fast it moves
var _spin: Dictionary = {}         # the gait's wheels: an act turns them directly, never through a servo (a spin never unwinds)
var _gait_curves: Dictionary = {}  # the gait's cycles as curves: joint -> curve, BODY -> curve

const BODY := "@body"


## The sidecar of a model, or an empty dictionary when it has none.
static func load_sidecar(model_id: String) -> Dictionary:
	var path := "res://art/models/%s.rig.json" % model_id
	if not FileAccess.file_exists(path):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


## What a node name in the model means: ["joint", "shoulder_l"], ["hp", 1], or [] for a part.
## Godot's importer may append a suffix to keep names unique; the tag survives that.
static func parse_tag(node_name: String) -> Array:
	if node_name.begins_with("joint_") and node_name.length() > 6:
		return ["joint", node_name.substr(6)]
	if node_name.begins_with("hp_"):
		var rest := node_name.substr(3)
		var digits := ""
		for ch in rest:
			if ch.is_valid_int():
				digits += ch
			else:
				break
		if not digits.is_empty():
			return ["hp", int(digits)]
	return []


## The axis a joint turns about when the sidecar names none: a turret, a caster, a steering
## knuckle, a head or a sensor about up; anything else about the axle line (lowforge's rule).
static func axis_for(name: String) -> String:
	for prefix in ["turret", "caster", "steer", "head", "sensor"]:
		if name.begins_with(prefix):
			return "yaw"
	return "pitch"


## The node-space direction of an authored axis: pitch is the node's x, yaw its y, roll its
## -z (Blender's forward came through as -z).
static func axis_vector(axis: String) -> Vector3:
	match axis:
		"yaw":
			return Vector3(0.0, 1.0, 0.0)
		"roll":
			return Vector3(0.0, 0.0, -1.0)
	return Vector3(1.0, 0.0, 0.0)


## Authored degrees (pitch, yaw, roll) as the node's Euler offset in radians.
static func euler_of(deg: Vector3) -> Vector3:
	return Vector3(deg_to_rad(deg.x), deg_to_rad(deg.y), -deg_to_rad(deg.z))


## An authored slide (dx right, dy forward, dz up) as the node's offset.
static func offset_of(slide: Vector3) -> Vector3:
	return Vector3(slide.x, slide.z, -slide.y)


## Degrees clamped to a joint's limits: {"pitch": [lo, hi], "yaw": [...], "roll": [...]},
## an axis without a pair left free.
static func clamp_degrees(deg: Vector3, limits: Dictionary) -> Vector3:
	var out := deg
	for i in range(3):
		var axis: String = ["pitch", "yaw", "roll"][i]
		if limits.has(axis) and limits[axis] is Array and (limits[axis] as Array).size() == 2:
			out[i] = clampf(out[i], float(limits[axis][0]), float(limits[axis][1]))
	return out


## An act's keys as a curve: each key is [t, v1, v2, ...]; the track rests (every value
## zero) at time 0 and again at `duration` unless a key is authored there, so an act always
## returns the machine to its pose. "smooth" runs a monotone cubic through the keys (Ryan, 4
## October, the third pass: a part passing a key on its way keeps its speed through it, so
## only a turn or a hold stops it, and nothing overshoots a key); "linear" runs straight
## between them (a wheel spinning). Sample it with curve_at.
static func curve(keys: Array, duration: float, ease: String = "smooth") -> Dictionary:
	var width := 1
	for k in keys:
		width = maxi(width, (k as Array).size())
	var zero: Array = []
	for i in range(width):
		zero.append(0.0)
	var pts: Array = []
	if keys.is_empty() or float(keys[0][0]) > 0.0:
		pts.append(zero.duplicate())
	for k in keys:
		var row: Array = (k as Array).duplicate()
		while row.size() < width:
			row.append(0.0)
		pts.append(row)
	if float(pts[pts.size() - 1][0]) < duration:
		var end := zero.duplicate()
		end[0] = duration
		pts.append(end)
	return _through(pts, ease)


## Cyclic keys over a phase of 0 to 1 as a curve: the track wraps, so a key at 1 is the key
## at 0 unless that one is authored too, and the curve runs through the wrap without a stop.
static func cycle_curve(keys: Array, ease: String = "smooth") -> Dictionary:
	if keys.is_empty():
		return {}
	var rows: Array = []
	var at := {}
	for k in keys:
		var row: Array = (k as Array).duplicate()
		row[0] = float(row[0])
		if row[0] < 1.0:
			rows.append(row)
			at[snappedf(row[0], 0.0001)] = true
	for k in keys:
		var row: Array = (k as Array).duplicate()
		row[0] = float(row[0])
		if row[0] >= 1.0 and not at.has(snappedf(row[0] - 1.0, 0.0001)):
			row[0] -= 1.0
			rows.append(row)
	rows.sort_custom(func(a, b): return float(a[0]) < float(b[0]))
	var width := 1
	for r in rows:
		width = maxi(width, (r as Array).size())
	for r in rows:
		while (r as Array).size() < width:
			(r as Array).append(0.0)
	# Two keys of the cycle before and two after, so every key inside a stride has neighbours
	# on both sides and its slope is the cycle's own.
	var n := rows.size()
	var pts: Array = []
	for i in range(-2, n + 2):
		var row: Array = (rows[posmod(i, n)] as Array).duplicate()
		row[0] = float(row[0]) + float(floori(float(i) / n))
		pts.append(row)
	return _through(pts, ease)


## The slopes of a monotone cubic through `pts` ([t, v...] rows in time order): zero at a
## turn, a hold and the two ends, the weighted harmonic mean of the neighbouring secants
## where the track runs on through a key (Fritsch and Butland).
static func _through(pts: Array, ease: String) -> Dictionary:
	var n := pts.size()
	var width := (pts[0] as Array).size() - 1
	var times := PackedFloat64Array()
	var vals: Array = []
	var slopes: Array = []
	for p in pts:
		times.append(float(p[0]))
		var v := PackedFloat64Array()
		for j in range(1, width + 1):
			v.append(float(p[j]))
		vals.append(v)
	var linear := ease == "linear"
	for i in range(n):
		var m := PackedFloat64Array()
		m.resize(width)
		if not linear and i > 0 and i < n - 1:
			var h0 := times[i] - times[i - 1]
			var h1 := times[i + 1] - times[i]
			for j in range(width):
				if h0 <= 0.0 or h1 <= 0.0:
					continue
				var d0: float = (float(vals[i][j]) - float(vals[i - 1][j])) / h0
				var d1: float = (float(vals[i + 1][j]) - float(vals[i][j])) / h1
				if d0 * d1 <= 0.0:
					continue
				var w0 := 2.0 * h1 + h0
				var w1 := h1 + 2.0 * h0
				m[j] = (w0 + w1) / (w0 / d0 + w1 / d1)
		slopes.append(m)
	return {"t": times, "v": vals, "m": slopes, "linear": linear, "width": width}


## A curve's values at time `t`, held at its first and last keys outside them.
static func curve_at(c: Dictionary, t: float) -> Array:
	var out: Array = []
	if c.is_empty():
		return out
	var times: PackedFloat64Array = c["t"]
	var vals: Array = c["v"]
	var width := int(c["width"])
	var n := times.size()
	var row: PackedFloat64Array
	if t <= times[0]:
		row = vals[0]
	elif t >= times[n - 1]:
		row = vals[n - 1]
	else:
		var i := clampi(times.bsearch(t, false) - 1, 0, n - 2)
		var h := times[i + 1] - times[i]
		var u := 1.0 if h <= 0.0 else (t - times[i]) / h
		var a: PackedFloat64Array = vals[i]
		var b: PackedFloat64Array = vals[i + 1]
		if bool(c["linear"]):
			for j in range(width):
				out.append(lerpf(a[j], b[j], u))
			return out
		var ma: PackedFloat64Array = c["m"][i]
		var mb: PackedFloat64Array = c["m"][i + 1]
		var u2 := u * u
		var u3 := u2 * u
		var h00 := 2.0 * u3 - 3.0 * u2 + 1.0
		var h10 := u3 - 2.0 * u2 + u
		var h01 := -2.0 * u3 + 3.0 * u2
		var h11 := u3 - u2
		for j in range(width):
			out.append(h00 * a[j] + h10 * h * ma[j] + h01 * b[j] + h11 * h * mb[j])
		return out
	for j in range(width):
		out.append(row[j])
	return out


## Keys sampled at `t` (the curve through them, at once): for one look, not a frame loop.
static func sample(keys: Array, t: float, duration: float, ease: String = "smooth") -> Array:
	return curve_at(curve(keys, duration, ease), t)


## A machine's full speed on the map in its own model units a second: the map fits it to
## `fit` hex widths at its widest (Map3D.fit_for, by its class by mass) and a step at full
## speed takes the map's pace for its move (BattleMapView.mech_seconds_per_hex). What the
## debug drive and the hangar's Walk run at, so a stride is seen at the pace the map gives
## it: the smaller a machine is drawn, the more of itself a hex is, the more strides it takes.
static func map_speed(widest: float, movespeed: int, fit: float) -> float:
	var step := sqrt(3.0) * widest / (2.0 * maxf(0.01, fit))
	return step / BattleMapView.mech_seconds_per_hex(float(movespeed))


## Move by `g` from now on: the sidecar's gait (setup does this) or one of its options, for a
## tool or a page judging one running (tools/gait_clip.gd).
func use_gait(g: Dictionary) -> void:
	gait = g
	_spin = {}
	for name in gait.get("wheels", {}).keys():
		_spin[name] = true
	_gait_curves = _cycle_curves(gait)
	# A gait may start and stop in another (Ryan, 7 October, the nineteenth notes: the
	# Clydesdale took off straight into its gallop): `start` names one of the options, moved by
	# wholly under `below` of its full speed, by its own gait over `full`, crossfading between.
	# Its handoff (the twenty-second notes) sets it off in that gait at `from` and plays the
	# stride it changes in, worked out foot by foot over `length` units, into its own at `to`.
	_start_gait = {}
	_main_offset = 0.0
	_start_offset = 0.0
	_handing = false
	var st: Variant = gait.get("start", {})
	if st is Dictionary and gait_options.get(str(st.get("option", "")), null) is Dictionary:
		var opt: Dictionary = gait_options[str(st["option"])]
		_start_gait = {"gait": opt, "curves": _cycle_curves(opt), "below": float(st.get("below", 0.3)), "full": float(st.get("full", 0.8))}
		var h: Variant = st.get("handoff", {})
		if h is Dictionary and float((h as Dictionary).get("length", 0.0)) > 0.0:
			var change := {"stride": float(h["length"]), "ease": "linear", "tracks": h.get("tracks", {}), "body": h.get("body", [])}
			change["curves"] = _once_curves(change)
			_start_gait["from"] = float(h.get("from", 0.0))
			_start_gait["to"] = float(h.get("to", 0.0))
			_start_gait["handoff"] = change


## The cyclic curves of a gait's tracks and body.
func _cycle_curves(g: Dictionary) -> Dictionary:
	var out := {}
	var ease := str(g.get("ease", "smooth"))
	var cycles: Dictionary = g.get("tracks", {})
	for name in cycles.keys():
		out[name] = cycle_curve((cycles[name] as Dictionary).get("keys", []), ease)
	if not g.get("body", []).is_empty():
		out[BODY] = cycle_curve(g["body"], ease)
	return out


## The stride a gait changes in as curves: once through, its first key the start gait's pose
## and its last the gait's own, never wrapping (cycle_curve would read its end as its start).
func _once_curves(g: Dictionary) -> Dictionary:
	var out := {}
	var tracks: Dictionary = g.get("tracks", {})
	for name in tracks.keys():
		out[name] = curve((tracks[name] as Dictionary).get("keys", []), 1.0, "linear")
	if not g.get("body", []).is_empty():
		out[BODY] = curve(g["body"], 1.0, "linear")
	return out


## Read the model's tags and its sidecar. Call once the materials are applied (the glows
## look for the lit surfaces) and before anything moves; `phase` seeds this instance's
## clock so two machines of one kind never act in step.
func setup(root: Node3D, model_id: String, body_node: Node3D = null, phase: int = -1) -> void:
	model = root
	body = body_node if body_node != null else root
	joints.clear()
	hardpoints.clear()
	_rest.clear()
	_rest_pos.clear()
	_collect(root)
	var side := load_sidecar(model_id)
	meta = {}
	var sm: Dictionary = side.get("joints", {})
	for name in joints.keys():
		var m: Dictionary = sm.get(name, {})
		meta[name] = {
			"axis": str(m.get("axis", axis_for(name))),
			"limits": m.get("limits", {}),
			"swing": bool(m.get("swing", str(name).begins_with("shoulder"))),
			"parent": str(m.get("parent", "")),
			"slide": m.get("slide", []),   # a joint that only runs along its line (a gun in a port): that line, model axes
		}
	acts = []
	for a in side.get("acts", []):
		if a is Dictionary and a.has("name"):
			acts.append(a)
	move = side.get("move", {})
	heft = float(move.get("heft", HEFT_DEFAULT))
	gait_options = side.get("gait_options", {}) if side.get("gait_options", {}) is Dictionary else {}
	spinners = {}
	_spun = {}
	var sp: Dictionary = side.get("spin", {}) if side.get("spin", {}) is Dictionary else {}
	for name in sp.keys():
		if joints.has(name) and sp[name] is Array and (sp[name] as Array).size() >= 2:
			spinners[name] = [float(sp[name][0]), float(sp[name][1])]
			_spun[name] = 0.0
	spin_steps = {}
	_locked.clear()
	var ss: Dictionary = side.get("spin_step", {}) if side.get("spin_step", {}) is Dictionary else {}
	for name in ss.keys():
		if spinners.has(name) and float(ss[name]) > 0.0:
			spin_steps[name] = float(ss[name])
	held_spins = {}
	_held_on.clear()
	_held_speed.clear()
	var hs: Dictionary = side.get("spin_held", {}) if side.get("spin_held", {}) is Dictionary else {}
	for status in hs.keys():
		if not (hs[status] is Dictionary):
			continue
		var turned := {}
		for jn in (hs[status] as Dictionary).keys():
			if joints.has(jn):
				turned[jn] = float(hs[status][jn])
				_spun[jn] = float(_spun.get(jn, 0.0))
				_held_speed[jn] = 0.0
		if not turned.is_empty():
			held_spins[str(status)] = turned
			_held_on[str(status)] = false
	spin_debug = OS.get_environment("RIFTGATE_SPIN_DEBUG") == "1"
	_spin_debug_t = 0.0
	use_gait(side.get("gait", {}) if side.get("gait", {}) is Dictionary else {})
	fires = side.get("fires", {}) if side.get("fires", {}) is Dictionary else {}
	aims = side.get("aims", {}) if side.get("aims", {}) is Dictionary else {}
	pivots = bool(side.get("pivots", false))
	_body_rest_pos = body.position
	_body_rest_rot = body.rotation
	_rng.seed = hash(model_id) ^ (randi() if phase < 0 else phase * 7919)
	debug = OS.get_environment("RIFTGATE_ACTS_DEBUG")
	debug_move = OS.get_environment("RIFTGATE_MOVE_DEBUG") == "1"
	_wait = GAP_DEBUG if not debug.is_empty() else _first_wait()
	_glow_cache.clear()
	_tread_mats = []
	_move_glow = []
	_dist = 0.0
	_speed = 0.0
	_blend = 0.0
	_accel = 0.0
	_bank = 0.0
	_tilt = Vector2.ZERO
	_steer.clear()
	_travel = 0.0
	_handing = false
	_drift = 0.0
	_current = {}
	_curves = {}
	_want_rot.clear()
	_want_slide.clear()
	_body_want_rot = Vector3.ZERO
	_body_want_slide = Vector3.ZERO
	_servo.clear()
	_act_rot.clear()
	_act_slide.clear()
	_gait_rot.clear()
	_gait_slide.clear()
	var treads: Dictionary = gait.get("treads", {})
	for part in treads.get("parts", []):
		_tread_named(root, str(part))
	var mg: Dictionary = gait.get("glow", {})
	for part in mg.get("parts", []):
		for m in _lit_materials(str(part)):
			_move_glow.append([m, _rest_of(m)])
	_setup_forms(side.get("forms", {}) if side.get("forms", {}) is Dictionary else {})
	_setup_halos(side)
	_setup_standing(side)
	_setup_counts(side.get("counts", []))
	_setup_ajar(side.get("ajar", {}) if side.get("ajar", {}) is Dictionary else {})
	_pose()   # the rest it stands in, ajar included, before anything moves


## The ajar pose a sidecar names (ajar, above): its joints' offsets, and how far the acts swing
## each, which the offset gives way to.
func _setup_ajar(aj: Dictionary) -> void:
	ajar = {}
	_ajar_span = {}
	ajar_unless = str(aj.get("unless", ""))
	var js: Dictionary = aj.get("joints", {}) if aj.get("joints", {}) is Dictionary else {}
	for jn in js.keys():
		if not joints.has(jn) or not (js[jn] is Array) or (js[jn] as Array).size() < 3:
			continue
		var v: Array = js[jn]
		ajar[jn] = [Vector3(float(v[0]), float(v[1]), float(v[2])), Vector3(float(v[3]), float(v[4]), float(v[5])) if v.size() >= 6 else Vector3.ZERO]
		var rot := Vector3.ZERO
		var sl := Vector3.ZERO
		for a in acts:
			for row in (a.get("tracks", {}) as Dictionary).get(jn, []):
				for i in range(3):
					if row.size() > 1 + i and absf(float(row[1 + i])) > absf(rot[i]):
						rot[i] = float(row[1 + i])
					if row.size() > 4 + i and absf(float(row[4 + i])) > absf(sl[i]):
						sl[i] = float(row[4 + i])
		_ajar_span[jn] = [rot, sl]


## Where joint `jn` stands at rest, the ajar pose in (ajar_open's share of it).
func home_position(jn: String) -> Vector3:
	var slide: Vector3 = (ajar[jn][1] as Vector3) * ajar_open() if ajar.has(jn) else Vector3.ZERO
	return _rest_pos[jn] + offset_of(slide)


## The ajar offset `off` on a joint whose acts swing it `span` and swing it `now`: whole at rest, nil
## once an act has it at its furthest.
static func ajar_share(off: Vector3, span: Vector3, now: Vector3) -> Vector3:
	var out := off
	for i in range(3):
		if span[i] != 0.0:
			out[i] *= clampf(1.0 - now[i] / span[i], 0.0, 1.0)
	return out


## How far the ajar pose stands in, 1 open to 0 shut: the form it waits on, turned in, shuts it.
func ajar_open() -> float:
	if ajar.is_empty():
		return 0.0
	if ajar_unless.is_empty() or not forms.has(ajar_unless):
		return 1.0
	return 1.0 - clampf(float(_form_t[ajar_unless]) / float(forms[ajar_unless]["duration"]), 0.0, 1.0)


## The forms a sidecar names, ready to hold: their tracks as curves over their turn, and
## their lit parts with the light each has at rest.
func _setup_forms(fs: Dictionary) -> void:
	forms = {}
	_form_on.clear()
	_form_t.clear()
	_form_rot.clear()
	_form_slide.clear()
	_form_debug_t = 0.0
	form_debug = OS.get_environment("RIFTGATE_SEAL_DEBUG") == "1"
	for name in fs.keys():
		var f: Dictionary = fs[name]
		var duration := maxf(0.01, float(f.get("duration", 0.6)))
		var curves := {}
		var tracks: Dictionary = f.get("tracks", {})
		for jn in tracks.keys():
			if joints.has(jn):
				curves[jn] = curve(tracks[jn], duration, "smooth")
		if not (f.get("body", []) as Array).is_empty():
			curves[BODY] = curve(f["body"], duration, "smooth")
		var glow: Array = []
		for g in f.get("glow", []):
			for part in g.get("parts", []):
				for m in _lit_materials(str(part)):
					glow.append([m, _rest_of(m), float(g.get("k", -1.0))])
		var own: Array = []
		for a in f.get("acts", []):
			if a is Dictionary and a.has("name"):
				own.append(a)
		forms[name] = {"duration": duration, "curves": curves, "glow": glow, "acts": own}
		_form_on[name] = false
		_form_t[name] = 0.0
	_form_body_rot = Vector3.ZERO
	_form_body_slide = Vector3.ZERO


## Hold a form or let it go: it turns in over its duration and back out the same way, from
## wherever it is (the Polar Bear seals: its guns sink, its ports shut and it hunkers down; it
## opens in the reverse). While a form turns no act starts, and one playing stops: held, the
## machine plays the form's own acts, from its held pose (Ryan, 29 October: sealed, "the
## animations set shouldn't be the same"), or else its own, less any that moves a joint the
## form keeps.
func set_form(name: String, on: bool) -> void:
	if not forms.has(name) or bool(_form_on[name]) == on:
		return
	_form_on[name] = on
	if not _current.is_empty():
		_end_act()


## Whether a form is held (or on its way in).
func form_held(name: String) -> bool:
	return bool(_form_on.get(name, false))


## Hold a status's spin or let it go (the Cassowary's capacitor turns while it is Spun Up, Ryan,
## 2 November): the joints it names come up to speed and run down again over SPIN_HELD_EASE,
## stopping wherever they are. True when it changes.
func hold_spin(status: String, on: bool) -> bool:
	if not held_spins.has(status) or bool(_held_on[status]) == on:
		return false
	_held_on[status] = on
	return true


## Whether a status's spin is held.
func spin_held(status: String) -> bool:
	return bool(_held_on.get(status, false))


## Ease every held spin's joints toward the speed their held statuses ask and turn them; true
## while any turns.
func _spins_held_step(delta: float) -> bool:
	var turning := false
	for jn in _held_speed.keys():
		var want := 0.0
		for status in held_spins.keys():
			if bool(_held_on[status]) and (held_spins[status] as Dictionary).has(jn):
				want += float(held_spins[status][jn])
		var v := want + (float(_held_speed[jn]) - want) * exp(-delta / SPIN_HELD_EASE)
		if absf(v - want) < 3.0:   # the exponential's tail, a creep, cut off
			v = want
		_held_speed[jn] = v
		if v != 0.0 and _spin_k > 0.0:
			_spun[jn] = fposmod(float(_spun.get(jn, 0.0)) + v * delta * _spin_k, 360.0)
			turning = true
	return turning


## The count displays a sidecar names, ready to light: each part's lit materials with their
## light at rest, and every part shown dark, nothing counted yet.
func _setup_counts(cs: Variant) -> void:
	count_displays = []
	count_debug = OS.get_environment("RIFTGATE_COUNT_DEBUG") == "1"
	_count_debug_t = 0.0
	if not (cs is Array):
		return
	for c in cs:
		if not (c is Dictionary) or not (c.get("parts", null) is Array) or (c["parts"] as Array).is_empty():
			continue
		var off := float(c.get("off", -0.85))
		var parts: Array = []
		var k: Array = []
		for part in c["parts"]:
			var lit: Array = []
			for m in _lit_materials(str(part)):
				lit.append([m, (m as StandardMaterial3D).emission_energy_multiplier])
			parts.append(lit)
			k.append(off)
		count_displays.append({"source": str(c.get("source", "")), "parts": parts, "on": float(c.get("on", 1.5)), "off": off,
			"flare": float(c.get("flare", 0.0)), "n": -1, "k": k})
	_light_counts()


## Show the numbers the screen passes (COUNT_SOURCES: the Cassowary's capacitor reads `shots`, a
## cell a counted shot) on the model's count displays: the first n parts lit, the rest dark. A
## number that falls flares every part of its display and lets them all go dark (the capacitor
## discharging on its sixth shot, the one that counts double); the first look shows its number
## as it stands. True when a display changes.
func show_counts(values: Dictionary) -> bool:
	var changed := false
	for d in count_displays:
		if not values.has(d["source"]):
			continue
		var size := (d["parts"] as Array).size()
		var n := clampi(int(values[d["source"]]), 0, size)
		var was := int(d["n"])
		if n == was:
			continue
		if was < 0:
			for i in range(size):
				d["k"][i] = float(d["on"]) if i < n else float(d["off"])
		elif n < was and float(d["flare"]) > 0.0:
			for i in range(size):
				d["k"][i] = float(d["flare"])
		d["n"] = n
		changed = true
	if changed:
		_light_counts()
	return changed


## How many of a source's parts are lit now (its display's number; 0 before the first look).
func count_shown(source: String) -> int:
	for d in count_displays:
		if d["source"] == source:
			return maxi(0, int(d["n"]))
	return 0


## A display's part's light now, as an offset from its light at rest (`on` lit, `off` dark, its
## `flare` as a discharge begins).
func count_light(source: String, part: int) -> float:
	for d in count_displays:
		if d["source"] == source and part >= 0 and part < (d["k"] as Array).size():
			return float(d["k"][part])
	return 0.0


## Each part chases its light, quick to light and slower to fade (a flare dies away); true
## while any moves.
func _counts_step(delta: float) -> bool:
	var moving := false
	for d in count_displays:
		var n := maxi(0, int(d["n"]))
		for i in range((d["k"] as Array).size()):
			var want := float(d["on"]) if i < n else float(d["off"])
			var k := float(d["k"][i])
			if k == want:
				continue
			k = want + (k - want) * exp(-delta / (COUNT_RISE if want > k else COUNT_FALL))
			d["k"][i] = want if absf(k - want) < 0.05 else k   # the fade's tail, past seeing, cut off
			moving = true
	if moving:
		_light_counts()
	return moving


func _light_counts() -> void:
	for d in count_displays:
		for i in range((d["parts"] as Array).size()):
			for pair in d["parts"][i]:
				(pair[0] as StandardMaterial3D).emission_energy_multiplier = float(pair[1]) * light(1.0 + float(d["k"][i]))


## Whether an act keys any of these joints.
static func _keys_any(a: Dictionary, held: Dictionary) -> bool:
	for jn in (a.get("tracks", {}) as Dictionary).keys():
		if held.has(jn):
			return true
	return false


## Turn every form toward held or let go, and what they add to each joint and to their lit
## parts' light; true while one is turning.
func _forms_step(delta: float) -> bool:
	var turning := false
	for name in forms.keys():
		var want := float(forms[name]["duration"]) if bool(_form_on[name]) else 0.0
		var t := float(_form_t[name])
		if t != want:
			_form_t[name] = move_toward(t, want, delta)
			turning = true
	if not turning:
		return false
	_form_rot.clear()
	_form_slide.clear()
	_form_body_rot = Vector3.ZERO
	_form_body_slide = Vector3.ZERO
	var settled := true
	for name in forms.keys():
		var f: Dictionary = forms[name]
		var t := float(_form_t[name])
		if t != (float(f["duration"]) if bool(_form_on[name]) else 0.0):
			settled = false
		for jn in (f["curves"] as Dictionary).keys():
			var v := curve_at(f["curves"][jn], t)
			if jn == BODY:
				_form_body_slide += Vector3(float(v[0]), float(v[1]), float(v[2]))
				if v.size() >= 6:
					_form_body_rot += Vector3(float(v[4]), float(v[3]), float(v[5]))   # authored (yaw, pitch, roll)
				continue
			_form_rot[jn] = (_form_rot.get(jn, Vector3.ZERO) as Vector3) + Vector3(float(v[0]), float(v[1]), float(v[2]))
			if v.size() >= 6:
				_form_slide[jn] = (_form_slide.get(jn, Vector3.ZERO) as Vector3) + Vector3(float(v[3]), float(v[4]), float(v[5]))
		var p := t / float(f["duration"])
		for g in f["glow"]:
			_light_to(g[0], float(g[1]), 1.0 + float(g[2]) * p)
	if settled:
		_wait = GAP_DEBUG if not debug.is_empty() else _rng.randf_range(GAP_MIN, GAP_MAX)   # in or out, a pause before the first act of the new set
	return true


func _collect(node: Node) -> void:
	var tag := parse_tag(node.name)
	if tag.size() == 2 and node is Node3D:
		if tag[0] == "joint":
			joints[tag[1]] = node
			_rest[tag[1]] = (node as Node3D).rotation
			_rest_pos[tag[1]] = (node as Node3D).position
		else:
			hardpoints[tag[1]] = node
	for c in node.get_children():
		_collect(c)


## Whether anything here moves on its own: acts to play, a part still settling, a strike
## still swinging, a gait under the debug switch.
## Whether an act is playing now (a hovercraft's balance quietens through one).
func in_act() -> bool:
	return not _current.is_empty()


func alive() -> bool:
	return not acts.is_empty() or not forms.is_empty() or not _strikes.is_empty() or not _flares.is_empty() or not _aim.is_empty() or not _current.is_empty() or not _servo.is_empty() or _gutter >= 0.0 or (debug_move and not gait.is_empty()) \
		or not held_spins.is_empty() or not count_displays.is_empty()


## The wait before this machine's first act. The machines a screen sets up together open
## one after another, at least OPEN_GAP apart, rather than each at random over the first
## gap (Ryan, 7 October). A rig with no place (the tests, the tools) opens at random.
func _first_wait() -> float:
	var first := _rng.randf_range(0.6, OPEN_FIRST)
	if place.is_empty():
		return first
	var now := Time.get_ticks_msec()
	var after := (float(int(_opening.get(place, 0)) - now) / 1000.0) + OPEN_GAP + _rng.randf_range(0.0, OPEN_JITTER)
	var wait := maxf(first, after)
	_opening[place] = now + int(wait * 1000.0)
	return wait


## Advance the clock: the act playing, the gap to the next one, the servos and the strikes,
## in steps no longer than STEP, so a long tick lands where frames would have.
func tick(delta: float) -> void:
	if model == null:
		return
	var moved := false
	var left := delta
	# A long frame catches the act and the servos up in full, but spends no more than a
	# frame's worth of the gap to the next act: a hitch (a screen opening, a shader compiling)
	# used to run every machine's wait out in the same frame, so they all started together
	# (Ryan, 7 October).
	_wait_budget = minf(delta, WAIT_TICK_MAX)
	while left > 0.0:
		var dt := minf(left, STEP)
		left -= dt
		if _step(dt):
			moved = true
	# The held forms (the Polar Bear's seal) turn on their own clock; the debug switch holds
	# every one and lets it go in turn.
	if form_debug and not forms.is_empty():
		_form_debug_t += delta
		for name in forms.keys():
			set_form(name, fmod(_form_debug_t, FORM_DEBUG_PERIOD * 2.0) >= FORM_DEBUG_PERIOD)
	if _forms_step(delta):
		moved = true
	# A status's spin (the capacitor while Spun Up) and the count displays run on their own
	# clocks; the switches hold every spin and let it go in turn, and count every display up.
	if spin_debug and not held_spins.is_empty():
		_spin_debug_t += delta
		for status in held_spins.keys():
			hold_spin(str(status), fmod(_spin_debug_t, SPIN_DEBUG_PERIOD * 2.0) >= SPIN_DEBUG_PERIOD)
	if _spins_held_step(delta):
		moved = true
	if count_debug and not count_displays.is_empty():
		_count_debug_t += delta
		if _count_debug_t >= COUNT_DEBUG_PERIOD:
			_count_debug_t -= COUNT_DEBUG_PERIOD
			var up := {}
			for d in count_displays:
				up[d["source"]] = (maxi(0, int(d["n"])) + 1) % ((d["parts"] as Array).size() + 1)   # up to every part lit, then it falls
			show_counts(up)
	_counts_step(delta)
	# What turns without end turns whatever else is happening, faster as the move blends in,
	# unless the act playing locks it: then it eases onto its step and holds there.
	for name in spinners.keys():
		if _locked.has(name):
			var lk: Array = _locked[name]
			lk[2] = minf(float(lk[2]) + delta, PARK_TIME)
			var u := float(lk[2]) / PARK_TIME
			_spun[name] = lerpf(float(lk[0]), float(lk[1]), u * u * (3.0 - 2.0 * u))
		else:
			var r: Array = spinners[name]
			_spun[name] = fposmod(float(_spun[name]) + lerpf(float(r[0]), float(r[1]), _blend) * delta * _spin_k, 360.0)
		moved = true
	if debug_move and not gait.is_empty():
		drive(top_speed, 0.0, 0.0, delta)
	elif moved:
		_pose()


func _step(dt: float) -> bool:
	var moved := false
	if not _current.is_empty():
		_t += dt
		_evaluate_act()
		moved = true
		if _t >= (_until if _until >= 0.0 else float(_current.get("duration", 0.0))):
			_end_act()
	elif not dead and not act_set().is_empty() and not moving:   # a pilot on the move has no hands free for an act, a lost one none at all
		var spent := minf(dt, _wait_budget)
		_wait_budget -= spent
		_wait -= spent
		if _wait <= 0.0:
			var next := choose()
			if not next.is_empty():
				_start(next)
				_evaluate_act()
				moved = true
	if not _servo.is_empty() or not _want_rot.is_empty() or _body_want_rot != Vector3.ZERO or _body_want_slide != Vector3.ZERO:
		_follow(dt)
		moved = true
	if not _strikes.is_empty():
		for st in _strikes:
			st["t"] = float(st["t"]) + dt
		_strikes = _strikes.filter(func(st): return float(st["t"]) < float(st["up"]) + float(st["down"]))
		moved = true
	if not _flares.is_empty():
		var lit: Array = []
		for fl in _flares:
			fl["t"] = float(fl["t"]) + dt
			var k := MuzzleFlare.strength(str(fl["look"]), float(fl["t"]))
			(fl["mat"] as ShaderMaterial).set_shader_parameter("strength", k)
			(fl["node"] as Node3D).visible = k > 0.0
			if float(fl["t"]) < MuzzleFlare.lasts(str(fl["look"])):
				lit.append(fl)
			else:
				(fl["node"] as Node3D).visible = false
		_flares = lit
	if not _aim.is_empty():
		_aim["t"] = float(_aim["t"]) + dt
		if float(_aim["t"]) >= AIM_UP + float(_aim["hold"]) + AIM_DOWN:
			_aim = {}
		moved = true
	if not _flashes.is_empty():
		var live: Array = []
		for f in _flashes:
			f["t"] = float(f["t"]) + dt
			var done := float(f["t"]) >= FLASH_UP + FLASH_HOLD + FLASH_DOWN
			for i in range(f["mats"].size()):
				_light_to(f["mats"][i], float(f["base"][i]), 1.0 if done else 1.0 + flash_k(float(f["t"])))
			if not done:
				live.append(f)
		_flashes = live
		moved = true
	if _gutter >= 0.0:
		_gutter += dt
		var k := gutter_k(_gutter)
		for pair in _gutter_mats:
			var m: StandardMaterial3D = pair[0]
			var e := float(pair[1]) * k
			m.emission_energy_multiplier = e
			for h in _halos.get(m, []):
				(h as ShaderMaterial).set_shader_parameter("light", e)
				(h as ShaderMaterial).set_shader_parameter("presence", 0.0)
		if _gutter >= GUTTER:
			_gutter = -1.0
		moved = true
	if dead:
		if _spin_k > 0.0:
			_spin_k = maxf(0.0, _spin_k - dt / SPIN_STOP)
			moved = true
		if _collapse >= 0.0 and _collapse < COLLAPSE_AT:
			_collapse += dt
			if _collapse >= COLLAPSE_AT:
				_collapse_wants()
			moved = true
	return moved


## A lost machine's slump (kill), worked out once from its pose at rest (a held form's with it) as
## its lights go, its servos carrying it there heavily (COLLAPSE_HEFT):
## - a walker sinks on the limbs it stands on (_planted_limbs: a leg's hip, knee and ankle, and an
##   arm's shoulder, elbow and wrist when its hand is on the floor), every foot kept where it stands
##   and as it stands, by as much of COLLAPSE_SINK as every such limb reaches within its limits;
## - a biped (a walker with no hand on the floor) slumps forward at the waist (COLLAPSE_WAIST);
## - every other loose joint hangs what it carries where its weight takes it, the outermost first,
##   so an elbow goes slack before its shoulder and an arm hangs instead of swinging back; within its
##   limits and never below the floor (what already reached below it at rest going no lower);
## - nothing tips the body: a walker sinks straight down, anything else stays where it stands, and a
##   flyer or a hover (airborne) comes down onto its lowest point, the view landing it on
##   collapse_floor (MechView3D.lose), its loose parts hanging no lower than that.
## The legs' other joints, the spins and the mechanisms stay where they are (COLLAPSE_SKIP).
func _collapse_wants() -> void:
	if model == null:
		return
	if _size < 0.0:
		_size = _model_size()
	var held := {}
	var deg := {}   # joint -> the authored degrees it is turned to over its rest while this works
	for name in joints.keys():
		held[name] = (joints[name] as Node3D).rotation
		deg[name] = _form_rot.get(name, Vector3.ZERO)
		_turn_to(name, deg[name])
	var standing := _lowest_under(model)
	collapse_floor = standing if airborne else 0.0
	var sink := 0.0
	var limbs: Array = []
	if not airborne:
		limbs = _planted_limbs(COLLAPSE_TOUCH * maxf(1.0, _size))
		var turns := _sink_turns(limbs, deg)
		sink = float(turns[0])
		var add: Dictionary = turns[1]
		for name in add.keys():
			deg[name] = (deg[name] as Vector3) + (add[name] as Vector3)
			_turn_to(name, deg[name])
	var planted := {}
	var hands := false
	for trio in limbs:
		for name in trio:
			planted[name] = true
		hands = hands or not str(trio[0]).begins_with("hip")
	var legs := not limbs.is_empty()
	if legs and not hands:
		for name in joints.keys():
			if str(name).begins_with("waist"):
				deg[name] = (deg[name] as Vector3) + Vector3(-COLLAPSE_WAIST, 0.0, 0.0)   # pitch, whatever turn it is built for: forward is down at the front
				_turn_to(name, deg[name])
	var floor_y := collapse_floor + sink   # the floor in the model's frame once it has sunk
	var slack: Array = []   # [depth, name], the outermost first
	var floor_of := {}      # joint -> the floor what it carries keeps to: the floor, or lower if it reached lower at rest
	for name in joints.keys():
		var key := str(name)
		if spinners.has(name) or _spin.has(name) or planted.has(name):
			continue
		var skip := false
		for w in COLLAPSE_SKIP:
			if key.begins_with(w):
				skip = true
		if skip:
			continue
		var low := _lowest_under(joints[name])
		if low == INF:
			continue
		floor_of[name] = minf(floor_y, low)
		slack.append([_joint_depth(joints[name]), name])
	slack.sort_custom(func(a, b): return int(a[0]) > int(b[0]))
	for _pass in range(COLLAPSE_PASSES):
		for row in slack:
			_hang(row[1], deg, float(floor_of[row[1]]))
	if airborne:
		collapse_floor = _lowest_under(model)   # it lands on what hangs lowest once it has slumped (never lower than it stood)
	for name in joints.keys():
		var want: Vector3 = (deg[name] as Vector3) - (_form_rot.get(name, Vector3.ZERO) as Vector3)
		if want.length() > 0.01:
			_want_rot[name] = want
		(joints[name] as Node3D).rotation = held[name]
	_body_want_slide = Vector3(0.0, 0.0, -sink)   # authored: x right, y forward, z up (offset_of)
	_body_want_rot = Vector3.ZERO


## Turns a joint to `deg` authored degrees over its rest (the slump's sums; put back after).
func _turn_to(name, deg_v: Vector3) -> void:
	(joints[name] as Node3D).rotation = _rest[name] + euler_of(deg_v)


## How many joints stand above a joint in the model, for the slack's order.
func _joint_depth(node: Node) -> int:
	var n := 0
	var p := node.get_parent()
	while p != null and p != model:
		if p is Node3D and joints.values().has(p):
			n += 1
		p = p.get_parent()
	return n


## The lowest point of what a node carries, in the model's frame: the shown surfaces under it (a
## halo, a flare, a plume, an outline's hull or anything hidden aside); INF when it carries none.
func _lowest_under(node: Node) -> float:
	var low := INF
	var stack: Array = [node]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is Node3D and not (n as Node3D).visible:
			continue
		for c in n.get_children():
			stack.append(c)
		if n is MeshInstance3D and not n.has_meta("halo") and not n.has_meta("plume") and not n.has_meta("is_trace"):
			var mi := n as MeshInstance3D
			if mi.mesh == null:
				continue
			var xf := _in_model(mi)
			var bb := mi.get_aabb()
			for k in range(8):
				low = minf(low, (xf * bb.get_endpoint(k)).y)
	return low


## The limbs a walker stands on, each [root, middle, end]: a leg's hip, knee and ankle, and an arm's
## shoulder, elbow and wrist (or hand) when what its end carries is on the floor (within `touch`): the
## Baboon's knuckles, the Ammit's low hands.
func _planted_limbs(touch: float) -> Array:
	var out: Array = []
	for name in joints.keys():
		var key := str(name)
		var trio: Array = []
		if key.begins_with("knee"):
			var s := key.substr(4)
			trio = ["hip" + s, key, "ankle" + s]
		elif key.begins_with("elbow"):
			var s := key.substr(5)
			trio = ["shoulder" + s, key, ("wrist" + s) if joints.has("wrist" + s) else ("hand" + s)]
		else:
			continue
		if not joints.has(trio[0]) or not joints.has(trio[2]):
			continue
		if _lowest_under(joints[trio[2]]) > touch:
			continue   # it does not stand on this
		out.append(trio)
	var legs := false
	for trio in out:
		legs = legs or str(trio[0]).begins_with("hip")
	return out if legs else []   # a hand alone on the floor (the Badger's claw resting) is no stance


## How far a walker sinks and the turns that keep it standing: [sink, {joint: degrees added}], the
## most of COLLAPSE_SINK that every limb in `limbs` reaches within its limits with its belly still
## clear of the floor (the Polar Bear's shell rides low over its stubby legs), halved down to it
## (nought, and no turns, when none can).
func _sink_turns(limbs: Array, deg: Dictionary) -> Array:
	if limbs.is_empty():
		return [0.0, {}]
	var span := INF
	for trio in limbs:
		span = minf(span, _in_model(joints[trio[0]]).origin.y - _in_model(joints[trio[2]]).origin.y)
	var want := COLLAPSE_SINK * maxf(0.0, span)
	var floor_y := minf(0.0, _lowest_under(model))   # what stood a touch below the floor stays there
	var best := [0.0, {}]
	var lo := 0.0
	var hi := want
	for step in range(12):
		var d := hi if step == 0 else (lo + hi) * 0.5
		var turns := {}
		var ok := d > 0.0
		for trio in limbs:
			if not ok:
				break
			var t := _sink_limb(trio, d, deg)
			if t.is_empty():
				ok = false
			else:
				turns.merge(t)
		if ok:
			for name in turns.keys():
				_turn_to(name, (deg[name] as Vector3) + (turns[name] as Vector3))
			ok = _lowest_under(model) - d >= floor_y - 0.05   # in the model's frame the floor rises by what it sinks
			for name in turns.keys():
				_turn_to(name, deg[name])
		if ok:
			best = [d, turns]
			if step == 0:
				break
			lo = d
		else:
			hi = d
	return best


## The degrees a planted limb's root, middle and end add so that its end stays where it stands, and
## as it stands, while the machine sinks `d` in its own frame: a two-link reach in the plane its
## middle joint turns in, the knee folding the way it folds at rest, the end turning back what the
## root and middle turned. Empty when it cannot (out of reach, out of that plane, past a limit).
func _sink_limb(trio: Array, d: float, deg: Dictionary) -> Dictionary:
	var xr := _in_model(joints[trio[0]])
	var xm := _in_model(joints[trio[1]])
	var xe := _in_model(joints[trio[2]])
	var u := (xm.basis * axis_vector("pitch")).normalized()   # the limb's plane: its middle joint's axle
	var ur := (xr.basis * axis_vector("pitch")).normalized()
	var ue := (xe.basis * axis_vector("pitch")).normalized()
	if absf(u.dot(ur)) < 0.95 or absf(u.dot(ue)) < 0.95:
		return {}
	var a := Vector3.UP
	var b := u.cross(a)
	if b.length() < 0.5:
		return {}
	b = b.normalized()   # (up, b) so that a turn the positive way about u climbs from up toward b
	var h := xr.origin
	var k2 := Vector2((xm.origin - h).dot(a), (xm.origin - h).dot(b))
	var e2 := Vector2((xe.origin - h).dot(a), (xe.origin - h).dot(b))
	var t2 := e2 + Vector2(d, 0.0)   # the end stays put as the machine sinks: d nearer the root
	var l1 := k2.length()
	var l2 := (e2 - k2).length()
	var reach := t2.length()
	if l1 < 0.001 or l2 < 0.001 or reach >= l1 + l2 - 0.001 or reach <= absf(l1 - l2) + 0.001:
		return {}
	var shin0 := e2 - k2
	var bend := signf(k2.x * shin0.y - k2.y * shin0.x)
	var aim := atan2(t2.y, t2.x)
	var spread := acos(clampf((l1 * l1 + reach * reach - l2 * l2) / (2.0 * l1 * reach), -1.0, 1.0))
	for sg in [1.0, -1.0]:
		var a1: float = aim + sg * spread
		var k := Vector2(cos(a1), sin(a1)) * l1
		var shin := t2 - k
		if bend != 0.0 and signf(k.x * shin.y - k.y * shin.x) != bend:
			continue
		var d_root := wrapf(a1 - atan2(k2.y, k2.x), -PI, PI)
		var d_mid := wrapf((atan2(shin.y, shin.x) - a1) - (atan2(shin0.y, shin0.x) - atan2(k2.y, k2.x)), -PI, PI)
		var d_end := -(d_root + d_mid)
		var out := {
			trio[0]: Vector3(rad_to_deg(d_root) * signf(u.dot(ur)), 0.0, 0.0),
			trio[1]: Vector3(rad_to_deg(d_mid), 0.0, 0.0),
			trio[2]: Vector3(rad_to_deg(d_end) * signf(u.dot(ue)), 0.0, 0.0),
		}
		for name in out.keys():
			var m: Dictionary = meta.get(name, {})
			if str(m.get("axis", "pitch")) != "pitch":
				return {}
			var total: Vector3 = (deg[name] as Vector3) + (out[name] as Vector3)
			if clamp_degrees(total, m.get("limits", {})).distance_to(total) > 0.5:
				return {}   # past a limit: it cannot sink this far
		return out
	return {}


## Hangs what a slack joint carries where its weight takes it (_collapse_wants): the turn about its
## own axle that brings the middle of what it carries under it, within its limits, eased back so what
## it carries keeps above `floor_y`; `deg` takes the result and the joint is left turned to it.
func _hang(name, deg: Dictionary, floor_y: float) -> void:
	var j: Node3D = joints[name]
	var m: Dictionary = meta.get(name, {})
	var axis := str(m.get("axis", axis_for(str(name))))
	var i := ["pitch", "yaw", "roll"].find(axis)
	if i < 0:
		return
	var centre = _subtree_centre(j)
	if centre == null:
		return
	var xj := _in_model(j)
	var u := (xj.basis * axis_vector(axis)).normalized()
	var r: Vector3 = (centre as Vector3) - xj.origin
	var g := Vector3.DOWN
	var rp := r - u * r.dot(u)
	var gp := g - u * g.dot(u)
	if gp.length() < 0.3 or rp.length() < 0.05:
		return   # it turns about up, or carries nothing off its axle
	var turn := rad_to_deg(atan2(u.dot(rp.cross(gp)), rp.dot(gp)))
	var now: Vector3 = deg[name]
	var lim: Dictionary = m.get("limits", {})
	var edges = lim.get(axis, null)
	if absf(turn) > 170.0 and edges is Array and (edges as Array).size() == 2:
		# balanced on top, as like to fall one way as the other: the way its limits give it room
		turn = absf(turn) * (1.0 if float(edges[1]) - now[i] >= now[i] - float(edges[0]) else -1.0)
	var to := now
	to[i] = now[i] + turn
	to = clamp_degrees(to, lim)
	_turn_to(name, to)
	if _lowest_under(j) < floor_y - 0.01:
		var lo := 0.0   # the share of the turn that keeps above the floor
		var hi := 1.0
		for _s in range(10):
			var f := (lo + hi) * 0.5
			_turn_to(name, now.lerp(to, f))
			if _lowest_under(j) < floor_y - 0.01:
				hi = f
			else:
				lo = f
		to = now.lerp(to, lo)
		_turn_to(name, to)
	deg[name] = to


## The middle of what a joint carries, in the model's frame: the centroid of every vertex shown
## under it (a halo, a flare, a plume, an outline's hull or anything hidden aside), so it reads the
## same whether the parts are welded into a few meshes (the game) or not (the hangar); null when it
## carries none.
func _subtree_centre(j: Node3D):
	var sum := Vector3.ZERO
	var n := 0
	var stack: Array = [j]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is Node3D and not (node as Node3D).visible:
			continue
		for c in node.get_children():
			stack.append(c)
		if node is MeshInstance3D and (node as MeshInstance3D).mesh != null and not node.has_meta("halo") and not node.has_meta("plume") and not node.has_meta("is_trace"):
			var mi := node as MeshInstance3D
			var c: Array = _centroid_of(mi.mesh)
			if int(c[1]) > 0:
				sum += (_in_model(mi) * (c[0] as Vector3)) * float(c[1])
				n += int(c[1])
	return sum / float(n) if n > 0 else null


## A mesh's own vertex centroid and count, [Vector3, int], worked out once a mesh.
func _centroid_of(mesh: Mesh) -> Array:
	if _centroids.has(mesh):
		return _centroids[mesh]
	var sum := Vector3.ZERO
	var n := 0
	for si in range(mesh.get_surface_count()):
		var verts = mesh.surface_get_arrays(si)[Mesh.ARRAY_VERTEX]
		if verts is PackedVector3Array:
			for v in verts:
				sum += v
			n += (verts as PackedVector3Array).size()
	var out := [sum / float(n) if n > 0 else Vector3.ZERO, n]
	_centroids[mesh] = out
	return out


## A node's transform in the model's own frame, by its parent chain (outside the tree too).
func _in_model(node: Node) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var n := node
	while n != null and n != model:
		if n is Node3D:
			xf = (n as Node3D).transform * xf
		n = n.get_parent()
	return xf


## A blow on the hull (the to-do's hit reaction, on Ryan's go of 3 November): the whole
## machine shoved back from it, `away` in the model's own axes (backward, a little to the side the
## blow came from), its nose rocking up, on its body's servo, settling over JOLT_DOWN. `k` scales
## it (a blow the armour turned shoves at half).
func jolt(away: Vector3, k: float = 1.0) -> void:
	if body == null or model == null or away == Vector3.ZERO:
		return
	if _size < 0.0:
		_size = _model_size()
	_strikes.append({"joint": BODY, "vec": Vector3(JOLT_PITCH * k, 0.0, 0.0), "slide": away.normalized() * JOLT_SHARE * _size * k,
		"up": JOLT_UP, "down": JOLT_DOWN, "t": 0.0})
	_pose()


## The machine is lost (the kill's beat, Ryan's go of 3 November): its act stops, no other starts,
## and every lit part gutters out over GUTTER, flickering as it dies, its halo with it; it stays
## dark. revive() lights it again (the hit debug switch's machines come back).
func kill() -> void:
	if dead:
		return
	dead = true
	if not _current.is_empty():
		_end_act()
	_flashes.clear()
	_gutter_mats.clear()
	if model != null:
		var mats: Array = []
		_lit_under(model, mats)
		for m in mats:
			_rest_of(m)   # its rest kept before it dims, for revive()
			_gutter_mats.append([m, (m as StandardMaterial3D).emission_energy_multiplier])
	_gutter = 0.0
	_collapse = 0.0


func revive() -> void:
	if not dead:
		return
	dead = false
	_gutter = -1.0
	for pair in _gutter_mats:
		_light_to(pair[0], _rest_of(pair[0]), 1.0)
	_gutter_mats.clear()
	_collapse = -1.0
	collapse_floor = 0.0
	_spin_k = 1.0
	_want_rot.clear()
	_body_want_rot = Vector3.ZERO
	_body_want_slide = Vector3.ZERO
	_wait = GAP_MIN


## How much of its light a lost machine's lit part keeps `t` seconds into guttering out: a stutter
## of dips and catches, each catch dimmer, to nothing at GUTTER.
static func gutter_k(t: float) -> float:
	if t >= GUTTER:
		return 0.0
	var f := t / GUTTER
	var fade := (1.0 - f) * (1.0 - f)
	var stutter := 0.35 if fmod(t, 0.13) < 0.05 else 1.0
	return fade * stutter


## The next act: random among the machine's own, never the one just played (Ryan, 2
## October). With the debug switch naming an act, that act.
func choose() -> Dictionary:
	var set_now := act_set()
	if set_now.is_empty():
		return {}
	if not debug.is_empty() and debug != "1":
		for a in set_now:
			if str(a["name"]) == debug:
				return a
	# An act may be for the map or the skirmish alone (Ryan, 5 October: the Kite's loop
	# and circle mean nothing in the skirmish's frame); this machine plays what fits its place.
	# An act that is a weapon's firing alone (its `idle` false: the Nemesis's punches) never plays at rest.
	var here: Array = set_now.filter(func(a): return bool(a.get("idle", true)) and (place.is_empty() or (a.get("places", []) as Array).is_empty() or (a.get("places", []) as Array).has(place)))
	if here.is_empty():
		return {}
	if here.size() == 1:
		return here[0]
	var pool: Array = here.filter(func(a): return str(a["name"]) != last_act)
	return pool[_rng.randi_range(0, pool.size() - 1)]


## The acts the machine may play now: none while a form turns; a form held all the way in
## plays its own when it has any (the sealed Polar Bear's, from its hunkered pose; Ryan, 29
## October); else the machine's own, less any that moves a joint a held form keeps (the
## sealed Polar Bear presents no guns it has sunk).
func act_set() -> Array:
	var held := {}
	for name in forms.keys():
		var on := bool(_form_on[name])
		var t := float(_form_t[name])
		if (on and t < float(forms[name]["duration"])) or (not on and t > 0.0):
			return []
		if on:
			if not (forms[name]["acts"] as Array).is_empty():
				return forms[name]["acts"]
			for jn in (forms[name]["curves"] as Dictionary).keys():
				held[jn] = true
	if held.is_empty():
		return acts
	return acts.filter(func(a): return not _keys_any(a, held))


## A fixed weapon fires with its own act (Ryan, 31 October: "For the locked weapons, go for ones
## that are cheapest to do first, where pre-existing animation work has already been looked at
## that you can leverage"): the slice of an idle act the sidecar names for it (`fires`) plays now,
## from `lead` seconds before its start, the act playing cut short, its servos snappier than an
## idle act's so the wind-up lands on the blow. False when it has none, or a held form keeps the
## joints its act moves (the sealed Polar Bear's rack): the spend strikes as before.
func fire_act(cid: String, lead := 0.0) -> bool:
	var f := fire_slice(cid)
	if f.is_empty():
		return false
	var act: Dictionary = {}
	for a in act_set():
		if str(a["name"]) == str(f.get("act", "")):
			act = a
	if act.is_empty():
		return false
	_fire_turn[cid] = int(_fire_turn.get(cid, 0)) + 1
	if not _current.is_empty():
		_end_act()
	_start(act)
	_t = maxf(0.0, float(f.get("from", 0.0)) - lead)
	_until = float(f.get("to", act.get("duration", 0.0)))
	_act_heft = minf(_act_heft, FIRE_HEFT)
	_evaluate_act()
	_pose()
	return true


## The firing slices a sidecar names for a fixed component: one {act, from, to[, blow]}, or several
## that take turns (Ryan, 3 November, of the Ammit: it "can also afford two different Claw
## animations since it's got 4 and will use them often").
func fire_slices(cid: String) -> Array:
	var f = fires.get(cid, null)
	if f is Dictionary:
		return [f]
	if f is Array:
		return (f as Array).filter(func(s): return s is Dictionary)
	return []


## The slice that fires next, the slices taking turns; empty when the component fires with none.
func fire_slice(cid: String) -> Dictionary:
	var all := fire_slices(cid)
	if all.is_empty():
		return {}
	return all[int(_fire_turn.get(cid, 0)) % all.size()]


## How long the next slice winds up before its blow (its `blow`, the act's seconds at which the blow
## lands, after its `from`): the caller holds the blow's sound and its landing until then (Ryan, 3
## November: a weapon that "won't be fired every round" is "worth a little longer time"). Nought for
## a slice that starts just before its blow.
func fire_wind(cid: String) -> float:
	var s := fire_slice(cid)
	if s.is_empty() or not s.has("blow"):
		return 0.0
	return maxf(0.0, float(s["blow"]) - float(s.get("from", 0.0)))


## How long the next slice plays, start to end: an aim held on its target waits it out.
func fire_span(cid: String) -> float:
	var s := fire_slice(cid)
	return 0.0 if s.is_empty() else maxf(0.0, float(s.get("to", 0.0)) - float(s.get("from", 0.0)))


## Start a named act now, among those it may play first, then its own and its forms'; false
## when the machine has no act of that name.
func play(name: String) -> bool:
	var every: Array = act_set() + acts
	for f in forms.values():
		every += f["acts"]
	for a in every:
		if str(a["name"]) == name:
			_start(a)
			_evaluate_act()
			_pose()
			return true
	return false


func _start(a: Dictionary) -> void:
	_unlock_spins()
	_current = a
	_t = 0.0
	_until = -1.0
	_lock_spins(a)
	last_act = str(a["name"])
	var duration := float(a.get("duration", 0.0))
	var ease := str(a.get("ease", "smooth"))
	_act_heft = float(a.get("heft", heft))
	_curves = {}
	var tracks: Dictionary = a.get("tracks", {})
	for name in tracks.keys():
		if joints.has(name):
			_curves[name] = curve(tracks[name], duration, ease)
	if not a.get("body", []).is_empty():
		_curves[BODY] = curve(a["body"], duration, ease)
	_glow = []
	for g in a.get("glow", []):
		var mats: Array = []
		for part in g.get("parts", []):
			mats.append_array(_lit_materials(str(part)))
		var base: Array = []
		for m in mats:
			base.append(_rest_of(m))
		_glow.append({"curve": curve(g.get("keys", []), duration, ease), "mats": mats, "base": base})


## The act is over: its glows go back to rest and its asks to nothing, and the servos bring
## every part home from wherever its weight has carried it, each angle first taken the short
## way round (a loop or a spin ends a whole turn on, which is the pose it started in, so it
## never unwinds; Ryan, 5 October).
func _end_act() -> void:
	_unlock_spins()
	for name in _servo.keys():
		var st: Array = _servo[name]
		var r: Vector3 = st[0]
		st[0] = Vector3(wrapf(r.x, -180.0, 180.0), wrapf(r.y, -180.0, 180.0), wrapf(r.z, -180.0, 180.0))
	for g in _glow:
		for i in range(g["mats"].size()):
			_light_to(g["mats"][i], float(g["base"][i]), 1.0)
	_glow = []
	_current = {}
	_curves = {}
	_until = -1.0
	_want_rot.clear()
	_want_slide.clear()
	_body_want_rot = Vector3.ZERO
	_body_want_slide = Vector3.ZERO
	_wait = GAP_DEBUG if not debug.is_empty() else _rng.randf_range(GAP_MIN, GAP_MAX)


## Park every spinner the act locks (its `locks`): from where its turn stands to its next step
## ahead, the way it turns (never back), eased over PARK_TIME in tick, then held.
func _lock_spins(a: Dictionary) -> void:
	for jn in a.get("locks", []):
		var name := str(jn)
		if not spinners.has(name) or not spin_steps.has(name):
			continue
		var step := float(spin_steps[name])
		var from := float(_spun[name])
		var r: Array = spinners[name]
		var to := (ceilf(from / step - 0.0001) if lerpf(float(r[0]), float(r[1]), _blend) >= 0.0 else floorf(from / step + 0.0001)) * step
		_locked[name] = [from, to, 0.0]


## Let every locked spinner go: the act's own turn on it (whole steps) goes into its turn, so it
## never unwinds, and its idle turn takes up again from where it stands.
func _unlock_spins() -> void:
	for name in _locked.keys():
		var ax := ["pitch", "yaw", "roll"].find(str(meta.get(name, {}).get("axis", "pitch")))
		var turned := float(_spun[name])
		if _servo.has(name):
			var st: Array = _servo[name]
			var r: Vector3 = st[0]
			var v: Vector3 = st[1]
			turned += r[ax]
			r[ax] = 0.0
			v[ax] = 0.0
			st[0] = r
			st[1] = v
		if _act_rot.has(name):
			var ar: Vector3 = _act_rot[name]
			ar[ax] = 0.0
			_act_rot[name] = ar
		_spun[name] = fposmod(turned, 360.0)
	_locked.clear()


## Whether the act playing holds a spinner parked (its `locks`).
func spin_locked(name: String) -> bool:
	return _locked.has(name)


## What the act asks of each part at this moment: the servos chase it (_follow).
func _evaluate_act() -> void:
	for name in _curves.keys():
		var v := curve_at(_curves[name], _t)
		if name == BODY:
			_body_want_slide = Vector3(float(v[0]), float(v[1]), float(v[2]))
			_body_want_rot = Vector3(float(v[4]), float(v[3]), float(v[5])) if v.size() >= 6 else Vector3.ZERO   # authored (yaw, pitch, roll)
			continue
		_want_rot[name] = Vector3(float(v[0]), float(v[1]), float(v[2]))
		_want_slide[name] = Vector3(float(v[3]), float(v[4]), float(v[5])) if v.size() >= 6 else Vector3.ZERO
	for g in _glow:
		var k := float(curve_at(g["curve"], _t)[0]) + 1.0   # the keys are offsets from rest: 0 is the base light
		for i in range(g["mats"].size()):
			_light_to(g["mats"][i], float(g["base"][i]), k)


## The machine's weight (Ryan, 4 October, the third pass: heavy, with inertia, real machines
## and not toys): every part an act moves, and the body, is driven to what the act asks by
## a servo, a mass on a spring a touch under critical damping, so it gathers speed, carries
## a little past its mark and settles, `heft` seconds its time constant. A wheel the gait
## spins takes the act's keys as they are. A part home and still drops out.
func _follow(dt: float) -> void:
	var w := 1.0 / maxf(0.02, COLLAPSE_HEFT if dead else (_act_heft if not _current.is_empty() else heft))
	var names := {}
	for name in _servo.keys():
		names[name] = true
	for name in _want_rot.keys():
		names[name] = true
	if _body_want_rot != Vector3.ZERO or _body_want_slide != Vector3.ZERO:
		names[BODY] = true
	for name in names.keys():
		var want_r: Vector3 = _body_want_rot if name == BODY else _want_rot.get(name, Vector3.ZERO)
		var want_s: Vector3 = _body_want_slide if name == BODY else _want_slide.get(name, Vector3.ZERO)
		var st: Array
		if _spin.has(name):
			st = [want_r, Vector3.ZERO, want_s, Vector3.ZERO]
		else:
			st = _servo.get(name, [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO])
			var vr: Vector3 = st[1] + (w * w * (want_r - (st[0] as Vector3)) - 2.0 * DAMPING * w * (st[1] as Vector3)) * dt
			var vs: Vector3 = st[3] + (w * w * (want_s - (st[2] as Vector3)) - 2.0 * DAMPING * w * (st[3] as Vector3)) * dt
			st = [(st[0] as Vector3) + vr * dt, vr, (st[2] as Vector3) + vs * dt, vs]
		var home: bool = want_r == Vector3.ZERO and want_s == Vector3.ZERO and (st[0] as Vector3).length() < 0.02 \
			and (st[1] as Vector3).length() < 0.05 and (st[2] as Vector3).length() < 0.005 and (st[3] as Vector3).length() < 0.01
		if home:
			_servo.erase(name)
			st = [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]
		else:
			_servo[name] = st
		if name == BODY:
			_body_act_rot = st[0]
			_body_act_slide = st[2]
		elif home:
			_act_rot.erase(name)
			_act_slide.erase(name)
		else:
			_act_rot[name] = st[0]
			_act_slide[name] = st[2]


## Rest plus the act plus the gait plus the strikes, clamped to the joint's limits, on every
## joint; the body's rest plus its act and gait tracks.
func _pose() -> void:
	var open_k := ajar_open()
	for name in joints.keys():
		var j: Node3D = joints[name]
		var deg: Vector3 = _act_rot.get(name, Vector3.ZERO) + _gait_rot.get(name, Vector3.ZERO) + _form_rot.get(name, Vector3.ZERO)
		var ajar_slide := Vector3.ZERO
		if open_k > 0.0 and ajar.has(name):
			var span: Array = _ajar_span.get(name, [Vector3.ZERO, Vector3.ZERO])
			deg += ajar_share((ajar[name][0] as Vector3) * open_k, span[0], _act_rot.get(name, Vector3.ZERO))
			ajar_slide = ajar_share((ajar[name][1] as Vector3) * open_k, span[1], _act_slide.get(name, Vector3.ZERO))
		var kick := Vector3.ZERO
		for st in _strikes:
			if st["joint"] == name:
				deg += (st["vec"] as Vector3) * _strike_envelope(st)
				kick += (st.get("slide", Vector3.ZERO) as Vector3) * _strike_envelope(st)
		if not _aim.is_empty() and _aim["joint"] == name:
			deg.y += float(_aim["deg"]) * aim_envelope()
		var m: Dictionary = meta.get(name, {})
		deg = clamp_degrees(deg, m.get("limits", {}))
		if _spun.has(name):
			deg[["pitch", "yaw", "roll"].find(str(m.get("axis", "yaw")))] += float(_spun[name])
		j.rotation = _rest[name] + euler_of(deg)
		var slide: Vector3 = _act_slide.get(name, Vector3.ZERO) + _gait_slide.get(name, Vector3.ZERO) + _form_slide.get(name, Vector3.ZERO) + kick + ajar_slide
		if slide != Vector3.ZERO or j.position != _rest_pos[name]:
			j.position = _rest_pos[name] + offset_of(slide)
	if body != null:
		var recoil := Vector3.ZERO
		var rock := Vector3.ZERO
		for st in _strikes:
			if st["joint"] == BODY:
				recoil += (st["slide"] as Vector3) * _strike_envelope(st)
				rock += (st["vec"] as Vector3) * _strike_envelope(st)   # a jolt's nose rocking up
		var turn := Vector3(0.0, float(_aim["deg"]) * aim_envelope(), 0.0) if not _aim.is_empty() and _aim["joint"] == BODY else Vector3.ZERO
		body.position = _body_rest_pos + offset_of(_body_act_slide + _body_move_slide + _form_body_slide) + recoil
		body.rotation = _body_rest_rot + euler_of(_body_act_rot + _body_move_rot + _form_body_rot + turn + rock)


# ---------------------------------------------------------------- movement

## Cyclic keys sampled at a phase (the curve through them, at once): for one look, not a
## frame loop; the rig keeps its gait's curves from setup.
static func sample_cycle(keys: Array, phase: float, ease: String = "smooth") -> Array:
	if keys.is_empty():
		return []
	return curve_at(cycle_curve(keys, ease), fposmod(phase, 1.0))


## One frame of movement. `speed` is model units a second along the travel; `aim` the bearing
## of the travel relative to the body's facing, radians, positive left (a Dingo strafing
## left aims its casters +90 degrees); `turn` how fast the facing is turning, radians a
## second, positive left. Zero speed is standing, and the gait settles back over a moment.
func drive(speed: float, aim: float, turn: float, delta: float) -> void:
	if model == null or delta <= 0.0:
		return
	var prev := _speed
	_speed = lerpf(_speed, maxf(0.0, speed), 1.0 - exp(-delta / 0.12))
	_accel = lerpf(_accel, (_speed - prev) / delta, 1.0 - exp(-delta / 0.15))
	var pivot := minf(absf(turn) * PIVOT_STEP * maxf(1.0, float(gait.get("stride", 40.0))), PIVOT_CAP * top_speed) * (1.0 - clampf(_speed / PIVOT_FADE, 0.0, 1.0)) if absf(turn) > PIVOT_MIN else 0.0
	moving = speed > 0.5 or pivot > 0.0
	var target := 1.0 if moving else 0.0
	var rate := MOVE_BLEND_IN if moving else MOVE_BLEND_OUT
	var stood := _blend < 0.05   # the gait not yet showing as this frame begins
	_blend = move_toward(_blend, target, delta / rate)
	_dist += (_speed + pivot) * delta
	if speed > 0.5 or _speed > 0.5:
		if _travel <= 0.0:
			_set_off(stood)
		_travel += _speed * delta
	else:
		_travel = 0.0
		_handing = false
	var bank_want := float(move.get("bank", 0.0)) * clampf(-turn / BANK_TURN, -1.0, 1.0) * clampf(_speed / BANK_SPEED, 0.0, 1.0)   # a left turn drops the left wing: roll negative
	_bank = lerpf(_bank, bank_want, 1.0 - exp(-delta / 0.3))
	# A helicopter's tilt: it leans into its travel by its speed, nose down going forward,
	# nose up going back, the left side down going left (the roll is positive right-down). A
	# third number is the share of the nose-down it sheds in a turn, as it banks and pulls into
	# the corner (Ryan, 7 October, the nineteenth notes: a helicopter pulls into the turn after
	# banking, as a plane does), all of it at the turn rate that earns the whole bank.
	var tilt_spec: Array = move.get("tilt", [])
	if tilt_spec.size() >= 2:
		var share := clampf(_speed / MOVE_REF_SPEED, 0.0, 1.0)
		var pull := float(tilt_spec[2]) * clampf(absf(turn) / BANK_TURN, 0.0, 1.0) if tilt_spec.size() >= 3 else 0.0
		var want := Vector2(-float(tilt_spec[0]) * cos(aim) * (1.0 - pull), -float(tilt_spec[1]) * sin(aim)) * share
		_tilt = _tilt.lerp(want, 1.0 - exp(-delta / 0.35))
	# Steered joints follow the turn on a servo, easing toward their limits (Ryan, 7 October,
	# the nineteenth notes: the Prairie Dog's wheels jumped from straight to full lock).
	var steer: Dictionary = gait.get("steer", {})
	for name in steer.keys():
		_steer[name] = lerpf(float(_steer.get(name, 0.0)), steer_soft(name, turn * float(steer[name])), 1.0 - exp(-delta / STEER_EASE))
	# The slide: a body with inertia sits off a path that turned under it, on the outside,
	# by how square the travel is to its facing (the Dingo's drift; a hovercraft's a little).
	var drift_want := float(move.get("slide", 0.0)) * DRIFT_UNITS * sin(aim) * clampf(_speed / MOVE_REF_SPEED, 0.0, 1.0)
	_drift = lerpf(_drift, drift_want, 1.0 - exp(-delta / 0.3))
	_evaluate_gait(aim, turn)
	_pose()


## Setting off from a standstill with a start gait that hands over: the start gait set to its
## handoff's moment, when it is not yet showing (a machine that stepped round on the spot
## first keeps its step, and the change counts from that moment of its stride nearest now),
## and the gait's own phase set to meet the change's end.
func _set_off(stood: bool) -> void:
	if not _start_gait.has("handoff"):
		return
	var s := maxf(1.0, float((_start_gait["gait"] as Dictionary).get("stride", 40.0)))
	if stood:
		_start_offset = float(_start_gait["from"]) * s - _dist
		_handoff_at = _dist
	else:
		var past := fposmod((_dist + _start_offset) / s - float(_start_gait["from"]) + 0.5, 1.0) - 0.5
		_handoff_at = _dist - past * s
	_main_offset = float(_start_gait["to"]) * maxf(1.0, float(gait.get("stride", 40.0))) - _handoff_at
	_handing = true


## How much of its moving is the gait it starts and stops in, by its share of its full
## speed: 1 under the start's `below`, 0 over its `full` (0 for a gait that names none); and
## wholly that gait standing, and off the mark until the stride it changes in begins.
func start_weight() -> float:
	if _start_gait.is_empty():
		return 0.0
	if _start_gait.has("handoff") and (not _handing or _dist < _handoff_at):
		return 1.0
	return 1.0 - smoothstep(float(_start_gait["below"]), float(_start_gait["full"]), _speed / maxf(1.0, top_speed))


## Whether the stride a machine changes gait in is playing (the twenty-second notes): from
## its handoff's start to its length, after which the gait's own cycle takes over where the
## change ends.
func changing() -> bool:
	return _handing and _start_gait.has("handoff") and _dist >= _handoff_at and _dist - _handoff_at < float(_start_gait["handoff"]["stride"])


## A gait's cycles at `weight` (its tracks and its body's bob, each at its stride's phase,
## `offset` units on), added to the gait's joints and to `body` ([slide, turn]).
func _add_cycles(g: Dictionary, curves: Dictionary, weight: float, offset: float, body_out: Array) -> void:
	if weight <= 0.0:
		return
	var phase := fposmod((_dist + offset) / maxf(1.0, float(g.get("stride", 40.0))), 1.0)
	var k := _blend * weight
	var tracks: Dictionary = g.get("tracks", {})
	for name in tracks.keys():
		if not joints.has(name) or not curves.has(name):
			continue
		var tr: Dictionary = tracks[name]
		var v := curve_at(curves[name], fposmod(phase + float(tr.get("phase", 0.0)), 1.0))
		if v.size() >= 3:
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(float(v[0]), float(v[1]), float(v[2])) * k
		if v.size() >= 6:
			_gait_slide[name] = _gait_slide.get(name, Vector3.ZERO) + Vector3(float(v[3]), float(v[4]), float(v[5])) * k
	if curves.has(BODY):
		var v := curve_at(curves[BODY], phase)
		if v.size() >= 6:
			body_out[0] += Vector3(float(v[0]), float(v[1]), float(v[2])) * k
			body_out[1] += Vector3(float(v[4]), float(v[3]), float(v[5])) * k   # authored (yaw, pitch, roll)


## Degrees a steered joint turns for `raw` (its gain times the turn rate): eased toward its
## limit on its axis that way rather than stopped hard at it, so a knuckle comes round to full
## lock as the turn builds.
func steer_soft(name: String, raw: float) -> float:
	var m: Dictionary = meta.get(name, {})
	var lim: Dictionary = m.get("limits", {})
	var axis := str(m.get("axis", "yaw"))
	if not (lim.has(axis) and lim[axis] is Array and (lim[axis] as Array).size() == 2):
		return raw
	var edge := absf(float(lim[axis][1] if raw > 0.0 else lim[axis][0]))
	return raw if edge <= 0.0 else edge * tanh(raw / edge)


func _evaluate_gait(aim: float, turn: float) -> void:
	_gait_rot.clear()
	_gait_slide.clear()
	# The cycles: a walk, stride by stride, and the gait it starts and stops in by its share
	# of the speed (use_gait), each at its own stride's phase.
	# Off the mark, the stride it changes gait in plays in place of its own (use_gait).
	var start_w := start_weight()
	var cyc_body := [Vector3.ZERO, Vector3.ZERO]   # the body's (slide, turn) from the cycles
	if changing():
		_add_cycles(_start_gait["handoff"], _start_gait["handoff"]["curves"], 1.0 - start_w, -_handoff_at, cyc_body)
	else:
		_add_cycles(gait, _gait_curves, 1.0 - start_w, _main_offset, cyc_body)
	if start_w > 0.0:
		_add_cycles(_start_gait["gait"], _start_gait["curves"], start_w, _start_offset, cyc_body)
	# Wheels spin by their radius, forward a negative pitch, and never unwind.
	var wheels: Dictionary = gait.get("wheels", {})
	for name in wheels.keys():
		if joints.has(name):
			var r := maxf(0.1, float(wheels[name]))
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(-fposmod(rad_to_deg(_dist / r), 360.0), 0.0, 0.0)
	# Steering knuckles turn with the turn, each about its own axis (a knuckle yaws; the Buzzard's
	# nacelles pitch, vectoring through a turn: Ryan, 7 October, the eighteenth notes), as far
	# as their servo has followed it (drive); casters point along the travel.
	var steer: Dictionary = gait.get("steer", {})
	for name in steer.keys():
		if joints.has(name):
			var by := Vector3.ZERO
			by[maxi(0, ["pitch", "yaw", "roll"].find(str(meta.get(name, {}).get("axis", "yaw"))))] = float(_steer.get(name, 0.0)) * _blend
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + by
	var casters: Dictionary = gait.get("aim", {})
	for name in casters.keys():
		if joints.has(name):
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(0.0, rad_to_deg(aim) * float(casters[name]) * _blend, 0.0)
	# Offsets held while moving: a claw carried clear of the ground, nacelles tilted.
	var hold: Dictionary = gait.get("hold", {})
	for name in hold.keys():
		if joints.has(name):
			var h: Array = hold[name]
			_gait_rot[name] = _gait_rot.get(name, Vector3.ZERO) + Vector3(float(h[0]), float(h[1]), float(h[2])) * _blend
	# The body: a bob over the cycle, a held attitude, the rock on pulling away and
	# stopping, and the bank into a turn.
	var body_rot: Vector3 = cyc_body[1]
	var body_slide: Vector3 = cyc_body[0]
	var bh: Array = gait.get("body_hold", [])
	if bh.size() >= 6:
		body_slide += Vector3(float(bh[0]), float(bh[1]), float(bh[2])) * _blend
		body_rot += Vector3(float(bh[4]), float(bh[3]), float(bh[5])) * _blend
	var rock := float(gait.get("rock", 0.0))
	if rock != 0.0:
		body_rot.x += rock * clampf(_accel / ROCK_ACCEL, -1.0, 1.0)   # pulling away rocks the nose up
	body_rot.z += _bank + _tilt.y
	body_rot.x += _tilt.x
	body_slide.x += _drift
	_body_move_rot = body_rot
	_body_move_slide = body_slide
	# Treads scroll with the distance; boosters brighten with the move.
	var treads: Dictionary = gait.get("treads", {})
	if not _tread_mats.is_empty():
		var scroll := float(treads.get("scroll", 1.0)) * _dist / 14.0   # one tile (TILE_WORLD) per fourteen model units
		for row in _tread_mats:
			var m: StandardMaterial3D = row[0]
			m.uv1_offset = (row[1] as Vector3) + Vector3(fposmod(scroll, 1.0), 0.0, 0.0)
	if not _move_glow.is_empty():
		var k := 1.0 + float(gait.get("glow", {}).get("k", 1.0)) * _blend
		for row in _move_glow:
			_light_to(row[0], float(row[1]), k)


## A lit part's light as the screen shows it, given as a multiple of its light at rest (or
## the rest light itself). The phone's renderer (the Compatibility renderer, the desk's too)
## multiplies a lit tile as stored and clips each channel, so a flare past a few times the rest
## light went white; there the light is eased by LIGHT_EASE first, as the Vulkan renderer
## decoded a colour before it brightened it, so a flare builds in its own colour and nears
## white only at the very top (Ryan, 30 October: "a lot of these are supposed to be looking
## 'hot' instead of 'bright' and white doesn't really sell that"). The other renderers decode
## the tile themselves, so the multiple passes through.
static func light(m: float) -> float:
	if _eases_light < 0:
		_eases_light = 1 if RenderingServer.get_current_rendering_method() == "gl_compatibility" else 0
	return pow(maxf(0.0, m), LIGHT_EASE) if _eases_light == 1 else maxf(0.0, m)


## Set a lit material's light: `base`, its light at rest, times `multiple` over that rest,
## eased (light()), and its halos with it, whose presence climbs with the multiple until it
## stands HALO_FULL rests over (_setup_halos).
func _light_to(m: StandardMaterial3D, base: float, multiple: float) -> void:
	multiple = maxf(multiple, float(_standing.get(m, 1.0)))
	var e := base * light(multiple)
	m.emission_energy_multiplier = e
	for h in _halos.get(m, []):
		(h as ShaderMaterial).set_shader_parameter("light", e)
		(h as ShaderMaterial).set_shader_parameter("presence", clampf((multiple - 1.0) / HALO_FULL, 0.0, 1.0))


## The glows a sidecar holds always (`standing`: a lit part and how many rests over its own),
## an act's flare rising past them and settling back to them, their halos lit with them (Ryan,
## 31 October: the Stingray's fans "always on with heat glow"; the Arsenal's back vents "a creepy
## glowing exhaust").
func _setup_standing(side: Dictionary) -> void:
	_standing.clear()
	var st = side.get("standing", {})
	if not (st is Dictionary):
		return
	for part in st.keys():
		for m in _lit_materials(str(part)):
			var rest := _rest_of(m)
			_standing[m] = 1.0 + float(st[part])
			_light_to(m, rest, 1.0)


## A hot part hung after setup (a burn weapon's fire over its class: MechView3D.wear_burns) wears
## the halo as the sidecar's hot parts do.
func wear_hot(node: Node) -> void:
	if _halo_grow > 0.0:
		_halo_under(node, _halo_grow, HALO_REACH, {})


## Flare the lit parts under a node as a weapon fires (Ryan, 31 October: a burn weapon's fire
## "flaring as it fires"): up to FLASH_PEAK rests over their own, held, then easing back.
func flash_under(node: Node) -> void:
	var mats: Array = []
	_lit_under(node, mats)
	if mats.is_empty():
		return
	var base: Array = []
	for m in mats:
		base.append(_rest_of(m))
	_flashes.append({"mats": mats, "base": base, "t": 0.0})


## A flash's light over its rest at `t` seconds in.
static func flash_k(t: float) -> float:
	if t < FLASH_UP:
		return FLASH_PEAK * t / FLASH_UP
	t -= FLASH_UP
	if t < FLASH_HOLD:
		return FLASH_PEAK
	var u := clampf(1.0 - (t - FLASH_HOLD) / FLASH_DOWN, 0.0, 1.0)
	return FLASH_PEAK * u * u


## A lit material's light at rest, kept on the material the first time it is asked, so a standing
## glow that raises its light is never taken for its rest.
static func _rest_of(m: StandardMaterial3D) -> float:
	if not m.has_meta("rest_light"):
		m.set_meta("rest_light", m.emission_energy_multiplier)
	return float(m.get_meta("rest_light"))


## The halos (Ryan, 30 October, of a real bloom for lit parts: "Sure, let's try it"; the next
## day, on every machine's hot parts: "all glowing boosters and vents"). The lit parts a sidecar
## names (`halo`) wear round each lit surface a soft copy of the part grown out along its
## smoothed normals (halo.gdshader), in the part's colour held to its hue, added over what it
## lies on and faded in as the part's light climbs over its rest, so a flare spills past the
## part's edge and the machine's outline; Godot's own glow, on the phone's renderer, cannot tell
## a lit part from white paint and stops at the outline. It stands out a share of the machine's
## size (HALO_SPREAD), so it keeps its share of every machine however each is framed; a part
## named with a scale ([part, 2.0]) wears one that much larger and stronger, for a part only its
## spill shows (Ryan, 31 October, of the Puffin's repulsors: "too subtle"). RIFTGATE_HALO=off
## strips them to compare, =all puts them on every lit part of every model.
func _setup_halos(side: Dictionary) -> void:
	_halos.clear()
	var env := OS.get_environment("RIFTGATE_HALO")
	var named = side.get("glow_parts", []) if env == "all" else side.get("halo", [])
	_halo_grow = 0.0 if env == "off" else HALO_SPREAD * _model_size()
	if env == "off" or not (named is Array) or (named as Array).is_empty():
		return
	var grow := _halo_grow
	var done := {}
	for entry in named:
		if halo_skip.has(str(entry[0]) if entry is Array else str(entry)):
			continue   # a part that burns as a plume instead (MechView3D._setup_plumes)
		# A part, or [part, scale] for one larger, or [part, scale, ahead] for one drawn its own
		# distance toward the eye: nought for a part standing proud of a thin plate, whose halo the
		# usual three carried through the plate when it faced away (the Puffin's repulsors under
		# their plates, a violet wash over the blue).
		var p := str(entry[0]) if entry is Array else str(entry)
		var scale := float(entry[1]) if entry is Array and (entry as Array).size() > 1 else 1.0
		var ahead := float(entry[2]) if entry is Array and (entry as Array).size() > 2 else HALO_AHEAD
		var tag := parse_tag(p)
		if tag.size() == 2:
			var root: Node = joints.get(tag[1], null) if tag[0] == "joint" else hardpoints.get(tag[1], null)
			if root != null:
				_halo_under(root, grow * scale, minf(1.0, HALO_REACH * scale), done, ahead)
		else:
			_halo_named(model, p, grow * scale, minf(1.0, HALO_REACH * scale), done, ahead)


## The longest side of the model's bounds at rest, in its own units.
func _model_size() -> float:
	var box := AABB()
	var first := true
	for mi in model.find_children("*", "MeshInstance3D", true, false):
		var m: MeshInstance3D = mi
		if m.mesh == null or m.has_meta("halo") or m.has_meta("is_trace"):
			continue
		var to_model := Transform3D.IDENTITY
		var n: Node = m
		while n != null and n != model:
			if n is Node3D:
				to_model = (n as Node3D).transform * to_model
			n = n.get_parent()
		var b := to_model * m.mesh.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return maxf(box.size.x, maxf(box.size.y, box.size.z))


func _halo_named(node: Node, part: String, grow: float, reach: float, done: Dictionary, ahead := HALO_AHEAD) -> void:
	if node is MeshInstance3D and labelled(node.name, part):
		_halo_under(node, grow, reach, done, ahead)
	else:
		for c in node.get_children():
			_halo_named(c, part, grow, reach, done, ahead)


func _halo_under(node: Node, grow: float, reach: float, done: Dictionary, ahead := HALO_AHEAD) -> void:
	if node.has_meta("halo"):
		return
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var mi: MeshInstance3D = node
		for i in range(mi.get_surface_override_material_count()):
			var sm := mi.get_surface_override_material(i)
			var key := "%d:%d" % [mi.get_instance_id(), i]
			if done.has(key) or not (sm is StandardMaterial3D and (sm as StandardMaterial3D).emission_enabled):
				continue
			done[key] = true
			var lit: StandardMaterial3D = sm
			var hm := ShaderMaterial.new()
			hm.shader = HALO_SHADER
			hm.set_shader_parameter("tile", lit.emission_texture if lit.emission_texture != null else lit.albedo_texture)
			hm.set_shader_parameter("light", lit.emission_energy_multiplier)
			hm.set_shader_parameter("grow", grow)
			hm.set_shader_parameter("reach", reach)
			hm.set_shader_parameter("ahead", ahead)
			var h := MeshInstance3D.new()
			h.name = "halo"
			h.mesh = _halo_mesh(mi.mesh, i)
			h.material_override = hm
			h.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			h.layers = mi.layers
			h.set_meta("halo", true)   # no trace, no hull, no second halo
			mi.add_child(h)
			if not _halos.has(lit):
				_halos[lit] = []
			(_halos[lit] as Array).append(hm)
	for c in node.get_children():
		_halo_under(c, grow, reach, done, ahead)


## A surface's halo shell: its own triangles and UVs, each corner's normal the sum of the faces
## meeting there, so the shell grows out closed round a flat-shaded part; where the surface ends,
## at an edge one triangle alone uses, the corner leans outward in the surface's own plane too, so
## a flat disc's shell spreads round its rim rather than floating off its face (Ryan, 31 October,
## of the Puffin's repulsor discs: "extended way far out"). Built once a mesh.
static func _halo_mesh(mesh: Mesh, surface: int) -> ArrayMesh:
	var key := "%d:%d" % [mesh.get_instance_id(), surface]
	if _halo_meshes.has(key):
		return _halo_meshes[key]
	var arrays := mesh.surface_get_arrays(surface)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var index: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
	var sums := {}
	for i in range(verts.size()):
		var at := Vector3i((verts[i] * 64.0).round())
		sums[at] = (sums.get(at, Vector3.ZERO) as Vector3) + normals[i]
	var edges := {}   # "a|b" -> [uses, outward in the face's plane, a, b]
	var corners := index.size() if index.size() > 0 else verts.size()
	for f in range(0, corners - 2, 3):
		var tri: Array[Vector3] = []
		for c in range(3):
			tri.append(verts[index[f + c]] if index.size() > 0 else verts[f + c])
		var fn := (tri[1] - tri[0]).cross(tri[2] - tri[0])
		if fn.length_squared() < 1e-12:
			continue
		fn = fn.normalized()
		for e in range(3):
			var p: Vector3 = tri[e]
			var q: Vector3 = tri[(e + 1) % 3]
			var a := Vector3i((p * 64.0).round())
			var b := Vector3i((q * 64.0).round())
			var ek := "%s|%s" % [a, b] if str(a) < str(b) else "%s|%s" % [b, a]
			if edges.has(ek):
				edges[ek][0] = int(edges[ek][0]) + 1
				continue
			var out := (q - p).cross(fn).normalized()
			if out.dot(tri[(e + 2) % 3] - p) > 0.0:
				out = -out
			edges[ek] = [1, out, a, b]
	var rims := {}
	for ek in edges.keys():
		var e: Array = edges[ek]
		if int(e[0]) == 1:
			for at in [e[2], e[3]]:
				rims[at] = (rims.get(at, Vector3.ZERO) as Vector3) + (e[1] as Vector3)
	var smooth := PackedVector3Array()
	smooth.resize(verts.size())
	for i in range(verts.size()):
		var at := Vector3i((verts[i] * 64.0).round())
		var n: Vector3 = sums[at]
		n = n.normalized() if n.length() > 0.0001 else normals[i]
		var rim: Vector3 = rims.get(at, Vector3.ZERO)
		smooth[i] = (n + rim.normalized()).normalized() if rim.length() > 0.0001 else n
	var out := []
	out.resize(Mesh.ARRAY_MAX)
	out[Mesh.ARRAY_VERTEX] = verts
	out[Mesh.ARRAY_NORMAL] = smooth
	out[Mesh.ARRAY_TEX_UV] = arrays[Mesh.ARRAY_TEX_UV]
	out[Mesh.ARRAY_INDEX] = arrays[Mesh.ARRAY_INDEX]
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, out)
	_halo_meshes[key] = am
	return am


## The tread materials, by the meshes' names: scrolling their first UV runs the tread.
func _tread_named(node: Node, part: String) -> void:
	if node is MeshInstance3D and labelled(node.name, part):
		var mi: MeshInstance3D = node
		for i in range(mi.get_surface_override_material_count()):
			var sm := mi.get_surface_override_material(i)
			if sm is StandardMaterial3D:
				_tread_mats.append([sm, (sm as StandardMaterial3D).uv1_offset])
	for c in node.get_children():
		_tread_named(c, part)


static func _strike_envelope(st: Dictionary) -> float:
	var t := float(st["t"])
	var up := float(st["up"])
	var down := float(st["down"])
	if t <= 0.0:
		return 0.0
	if t < up:
		var f := t / up
		return 1.0 - (1.0 - f) * (1.0 - f)   # out: fast away
	var g := clampf((t - up) / down, 0.0, 1.0)
	return 1.0 - g * g * (3.0 - 2.0 * g)   # in-out: settling back


## A blow. Melee: the joints that swing (the shoulders, by the sidecar or by name) throw the
## arms forward. Ranged: every joint that carries a weapon socket kicks about its own axis,
## a recoil, toward whichever side its limits allow (a mount held to one side kicks to it).
## `only` names the joints of the weapon that fired, and only they kick (Ryan, 31 October: "It
## would obviously be really cool if the actual weapon from the die fired"), a joint named that
## carries no socket included (a fixed gun's business end on a wrist: the Badger's fragmenter);
## `recoil`, given,
## kicks the whole machine back along a gun's line, for a gun on a mount on the body. `lead`
## holds the blow that many seconds, while the machine turns onto its target (aim). Does nothing
## on an untagged model.
func strike(ranged: bool, only: Array = [], recoil := Vector3.ZERO, lead := 0.0) -> void:
	if recoil != Vector3.ZERO:
		_strikes.append({"joint": BODY, "vec": Vector3.ZERO, "slide": recoil, "up": 0.05, "down": 0.22, "t": -lead})
	if joints.is_empty():
		_pose()
		return
	var armed := {}
	for n in hardpoints.keys():
		var owner := joint_of(hardpoints[n])
		if not owner.is_empty():
			armed[owner] = true
	var named := not only.is_empty() or recoil != Vector3.ZERO
	for name in joints.keys():
		if named and not only.has(name):
			continue
		var m: Dictionary = meta.get(name, {})
		var axis := str(m.get("axis", axis_for(name)))
		var swing_deg: float
		if ranged:
			if not armed.has(name) and not only.has(name):
				continue
			var line: Array = m.get("slide", [])
			if line.size() == 3:
				# A gun that only runs in and out of its port (the Polar Bear's, Ryan, 29 October:
				# "they should only move along their axis of firing") kicks back along its line.
				_strikes.append({"joint": name, "vec": Vector3.ZERO, "slide": -Vector3(float(line[0]), float(line[1]), float(line[2])) * RECOIL_SLIDE, "up": 0.05, "down": 0.2, "t": -lead})
				continue
			swing_deg = 5.0
		elif bool(m.get("swing", false)):
			swing_deg = -29.0
		elif named:
			swing_deg = -15.0   # a blade on a joint that is not an arm's: a jab, not a swing
		else:
			continue
		var lim: Dictionary = m.get("limits", {})
		if lim.has(axis) and lim[axis] is Array and (lim[axis] as Array).size() == 2:
			var lo := float(lim[axis][0])
			var hi := float(lim[axis][1])
			if swing_deg > 0.0 and hi <= 0.0 and lo < 0.0:
				swing_deg = -swing_deg
			elif swing_deg < 0.0 and lo >= 0.0 and hi > 0.0:
				swing_deg = -swing_deg
		var vec := Vector3.ZERO
		vec[["pitch", "yaw", "roll"].find(axis)] = swing_deg
		_strikes.append({"joint": name, "vec": vec, "up": 0.05 if ranged else 0.10, "down": 0.2 if ranged else 0.28, "t": -lead})
	_pose()


## A muzzle flare on its look's beat (MuzzleFlare), from `lead` seconds on.
func fire_flare(node: MeshInstance3D, look: String, lead := 0.0) -> void:
	var mat := node.material_override as ShaderMaterial
	if mat == null:
		return
	mat.set_shader_parameter("spin", _rng.randf_range(0.0, TAU))
	_flares.append({"node": node, "mat": mat, "look": look, "t": -lead})


## Turn onto a target before firing (Ryan, 31 October: "If there's a cheap way of aiming (torso
## twist, hover pivot, gimbal) then yeah lets do that"): a joint turning about its up axis (a
## waist, a turret, a head with guns) or the whole machine (BODY, a hover's or a flyer's pivot)
## turns `deg` to its left over AIM_UP, holds `hold` seconds and turns back over AIM_DOWN. A
## joint's limits still clamp it.
func aim(joint: String, deg: float, hold: float) -> void:
	if joint != BODY and not joints.has(joint):
		return
	_aim = {"joint": joint, "deg": deg, "hold": maxf(0.0, hold), "t": 0.0}


func aim_envelope() -> float:
	if _aim.is_empty():
		return 0.0
	var t := float(_aim["t"])
	var hold := float(_aim["hold"])
	if t < AIM_UP:
		var f := t / AIM_UP
		return 1.0 - (1.0 - f) * (1.0 - f)
	if t < AIM_UP + hold:
		return 1.0
	var g := clampf((t - AIM_UP - hold) / AIM_DOWN, 0.0, 1.0)
	return 1.0 - g * g * (3.0 - 2.0 * g)


## The joint a machine turns to aim the gun on `node` (a pin): the nearest above it that turns
## about its up axis and is no spinner or steering knuckle; "" when there is none (a gun on the
## body, a quad's legs).
func aim_joint_over(node: Node) -> String:
	var steer: Dictionary = gait.get("steer", {})
	var p := node.get_parent()
	while p != null and p != model:
		var tag := parse_tag(p.name)
		if tag.size() == 2 and tag[0] == "joint":
			var name := str(tag[1])
			if joints.has(name) and str(meta.get(name, {}).get("axis", "")) == "yaw" and not spinners.has(name) and not steer.has(name):
				return name
		p = p.get_parent()
	return ""


## The joint a node hangs under, by name, or "" when it is on the body.
func joint_of(node: Node) -> String:
	var p := node.get_parent()
	while p != null and p != model:
		var tag := parse_tag(p.name)
		if tag.size() == 2 and tag[0] == "joint":
			return str(tag[1])
		p = p.get_parent()
	return ""


## The lit surfaces a glow track drives: every emissive override material on the meshes
## whose name begins with `part` (a lowforge label), or under the joint or socket named
## (`joint_turret`, `hp_3`). Per instance: MechView3D.toon duplicates every material.
func _lit_materials(part: String) -> Array:
	if _glow_cache.has(part):
		return _glow_cache[part]
	var out: Array = []
	var tag := parse_tag(part)
	if tag.size() == 2:
		var root: Node = joints.get(tag[1], null) if tag[0] == "joint" else hardpoints.get(tag[1], null)
		if root != null:
			_lit_under(root, out)
	else:
		_lit_named(model, part, out)
	_glow_cache[part] = out
	return out


## Whether a node carries a lowforge label: the label itself, or the label with the
## importer's numbering ("tread_001"), never another label that merely starts the same
## ("tread_deck").
static func labelled(node_name: String, part: String) -> bool:
	if node_name == part:
		return true
	if not node_name.begins_with(part):
		return false
	var rest := node_name.substr(part.length())
	return rest.begins_with("_") and rest.substr(1).is_valid_int() or (rest.begins_with(".") and rest.substr(1).is_valid_int())


func _lit_named(node: Node, part: String, out: Array) -> void:
	if node is MeshInstance3D and labelled(node.name, part):
		_lit_under(node, out)
	else:
		for c in node.get_children():
			_lit_named(c, part, out)


func _lit_under(node: Node, out: Array) -> void:
	if node is MeshInstance3D:
		var mi: MeshInstance3D = node
		for i in range(mi.get_surface_override_material_count()):
			var sm := mi.get_surface_override_material(i)
			if sm is StandardMaterial3D and (sm as StandardMaterial3D).emission_enabled and not out.has(sm):
				out.append(sm)
	for c in node.get_children():
		_lit_under(c, out)
