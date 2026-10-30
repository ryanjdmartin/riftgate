class_name MechView3D
extends SubViewport

## A player mech drawn in 3D for the skirmish screen. The model (art/models/<chassis>.glb,
## exported from Blender with materials named by role) is lit by the spriter's toon shader,
## framed by an orthographic camera at the sprites' angle (30 degrees down, turned 45 off
## head-on), then outlined in 2D. `texture` is a Texture2D the UnitView can draw like a sprite.
##
## One look, "clean": rendered at 160x192 with smooth shading, drawn at 1x, so it is
## sprite-sized on screen but twice the resolution and no pixel grid: real 3D against the
## 2D foes. (The "pixel" look, hard tone steps at 80x96, was an experiment of 16 September
## and went on the 22nd.) RIFTGATE_MECH3D=off draws placeholders instead.

const PIXEL_FRAME := Vector2i(80, 96)
const CLEAN_SCALE := 2
const PITCH := 30.0
const YAW_FRONT := 45.0     # front three-quarter: the codex hero angle
const YAW_REAR := 225.0     # rear three-quarter, kept for hero shots
const YAW_SKIRMISH := 155.0 # the old skirmish pose and the act tools': rear three-quarter facing the foes above, turned to the left (the claw side shows)
const YAW_FIELD := 0.0      # the skirmish on its floor (29 October): facing the foes, seen from behind by the floor's camera; `field.turn` turns each toward the middle
const FILL := 0.92
## How much of its frame a machine fills, by its class by mass (chassis `size`; Ryan, 5
## October: the machines' scale): the skirmish sets `size_k` from it, so the team stands in
## proportion, an assault machine filling its slot and a scout car well inside its own. The
## codex and the hangar frame every machine whole.
const SIZE_FILL := {"light": 0.7, "medium": 0.82, "heavy": 0.92, "assault": 1.0}

# The spriter's tones, so 3D and sprites share a palette (tools/spriter/spriter.py).
const RAMPS := {
	"steel": ["2b3038", "4a525e", "737d8a", "a3acb6"],
	"steel_dark": ["1f2329", "2b3038", "4a525e", "737d8a"],
	"rubber": ["16181c", "22262c", "35393f", "454a51"],
	"tread": ["16181c", "22262c", "35393f", "454a51"],
	"glass": ["1c6f8a", "2fa7c9", "6fe3ff", "c8f6ff"],
	"amber": ["7a5217", "a8741f", "e8a93a", "ffd27a"],
	"hot": ["7a2018", "b0342a", "e0473a", "ff8a6a"],
	"bore": ["0b0d10", "0b0d10", "14171c", "1f2329"],
	"white": ["8f8a7a", "a9a291", "d8d2c2", "f0ebdc"],
	"grille": ["1f2329", "2b3038", "4a525e", "737d8a"],
	"rivet": ["2b3038", "4a525e", "737d8a", "a3acb6"],
	"panel": ["2b3038", "4a525e", "737d8a", "a3acb6"],
}
# What the shader's surface pass needs to know about a material: which kind of thing it is.
const ROLE_INDEX := {
	"steel": 0, "rivet": 0, "panel": 0, "white": 0,
	"steel_dark": 1, "grille": 1, "bore": 1,
	"livery": 2,
	"glass": 3,
	"amber": 4,
	"hot": 5,
	"rubber": 6, "tread": 6,
}
# The maker's finish, for the shader's gloss lever: Kestrel gloss-coats, the wagon-builders barely.
const GLOSS := {"minerva": 0.35, "kestrel": 1.0, "wainwright_sutler": 0.15, "aphelion": 0.75, "arsenal": 0.5}
# The same finish on a textured (lowforge) model: roughness, metallic, specular (Ryan, 22
# September). Kestrel is chrome and shines like it, the signature; Minerva and the
# wagon-builders are strict matte; Aphelion's white has a pearl sheen (gloss without
# metal, so the white stays white); the Arsenal is black chrome, a dark mirror.
# Glossy makers' meshes also sit on this render layer, which only the sheen light lights.
const SHEEN_LAYER := 20
const FINISH := {"minerva": [0.92, 0.0, 0.2], "kestrel": [0.15, 1.0, 1.0], "wainwright_sutler": [0.96, 0.0, 0.15], "aphelion": [0.3, 0.3, 0.9], "arsenal": [0.2, 0.9, 1.0]}
const LIVERY := {
	# The livery tones, after the metals decided with the ally art (21 September; the
	# earlier red, bone, orange and yellow retired 22 September). Only untextured models
	# read these; lowforge models carry their maker's tiles.
	"minerva": ["1e2614", "35401f", "6b8047", "8fa668"],       # military green
	"kestrel": ["132148", "1c3270", "2d4fa8", "4a74d8"],       # cobalt
	"wainwright_sutler": ["3a2010", "5c3218", "85492a", "a8683f"],   # warm brown
	"aphelion": ["5a0c0c", "8c1414", "db1f1f", "f05a5a"],      # red on white
	"arsenal": ["2a2c30", "3f4247", "5c6169", "7f858e"],       # gunmetal
}

var texture: Texture2D
var mode: String = "clean"
var spin: bool = false            # turn slowly, for the codex
var sway: bool = false            # a slow idle: a breath of yaw and a bob, for the skirmish
var sway_phase: float = 0.0
var sway_bob: float = 0.35        # model units of vertical drift; a flyer hovers, a tank does not
var sway_yaw: float = 0.035       # radians of yaw drift
var sway_pitch: float = 0.0       # radians of pitch drift
var balance: HoverBalance = null  # a hovercraft's idle in place of the bob and pitch: it balances on its cushion as the currents shift it (Ryan, 5 October); sway_bob scales its heave
var _t := 0.0
var yaw: float = YAW_FRONT
var pitch: float = PITCH          # camera tilt down; the map tokens look steeper (tools/map_tokens.gd)
var token: bool = false           # a 24 px map token: no detail parts, no surface pass, lit from the viewer's side
var hide_detail: bool = true      # in token mode: drop ".detail" parts (a structure sprite keeps them)
var paint: Dictionary = {}        # optional repaint: {"primary": Color, "secondary": Color} over the maker's livery and bone plating
var frame_override: Vector2i = Vector2i.ZERO
var size_k: float = 1.0           # the share of FILL the model takes (SIZE_FILL); set before it is in the tree
## The skirmish's floor (29 October, the field), set by make_on_floor: the machine is drawn as
## the floor's own camera sees it standing on its hex, through a window of that camera's view,
## rather than framed alone at the sprites' angle. focal (design px) and height (hexes) are the
## camera's, level, its centre `principal` (design px) on the horizon; `at` the hex's centre on
## the floor (x across, y deep, in hexes); `window` the view's rect on the screen (design px);
## `fill` the machine's size in hexes; `lift` how far off the floor it flies; `turn` the degrees
## it turns from facing the foes, positive to its left.
var field: Dictionary = {}
const SPIN_SPEED := 0.7           # radians per second

# The model's tags (tools/lowforge/bl_low.py): `joint_<name>` is a pivot with the limb's
# parts under it, `hp_<n>` is a weapon socket with its stock part under it. Both come
# through the glTF as plain Node3Ds by name. The rig reads them and the model's sidecar
# (art/models/<id>.rig.json) and plays the idle acts and the strikes (MechRig).
var rig := MechRig.new()
var joints: Dictionary = {}       # "shoulder_l" -> Node3D (the rig's)
var hardpoints: Dictionary = {}   # 1 -> Node3D (the rig's)
var plan: Array = []              # what the pins wear instead of their stock (mount_plan rows), applied in _setup
var model_id: String = ""         # the glTF drawn: the chassis, or the fallback when it has no model

var _inner: SubViewport
var _camera: Camera3D
var _model: Node3D
var _pivot: Node3D = null   # the model's turntable, at its bounds' centre
var _stage: Node3D = null   # where the pivot stands: the world's origin, or on the floor its hex at the floor's scale
var _field_scale := 1.0     # on the floor: hexes a model unit


## The sky a chrome finish mirrors: the nineties chrome map, pale blue overhead running
## down to a white horizon, cool dark ground below, both gradients wide and soft so that
## neighbouring flat facets (one reflection sample each under the orthographic camera)
## shade continuously instead of snapping between sky and ground as the model turns
## (Ryan, 22 September: "random faces glitching"). Never drawn; the background stays
## transparent.
static func chrome_sky() -> Sky:
	var mat := ProceduralSkyMaterial.new()
	mat.sky_top_color = Color("6e9bd6")   # a real blue overhead: the top facets go light blue, not white
	mat.sky_horizon_color = Color("ffffff")
	mat.sky_curve = 0.3   # the white hugs the horizon as a band; chrome reads by the band against the blue
	mat.sky_energy_multiplier = 1.25
	mat.ground_horizon_color = Color("7d8894")   # cool below, so dark parts stay steel, not bronze
	mat.ground_bottom_color = Color("0b0d10")
	mat.ground_curve = 0.35
	mat.sun_angle_max = 0.0
	var sky := Sky.new()
	sky.sky_material = mat
	sky.radiance_size = Sky.RADIANCE_SIZE_128
	return sky


## The sheen: a light that rides with the camera, from a little above it, so a glossy
## facet facing the viewer carries a highlight at every pose. The sun's highlight only
## lands when a facet's normal bisects sun and camera, which the spin passes through near
## north-south and the map's and skirmish's three-quarter pose never does (Ryan, 22
## September). Its cull mask keeps it off the matte makers; chrome shows no diffuse, so
## on Kestrel and the Arsenal it is pure highlight. A child of the camera.
const SHEEN := 3.6            # hot on purpose: on a phone an effect has to be exaggerated to be obvious (Ryan, 22 September)
const SHEEN_SKIRMISH := 5.4   # the skirmish's rear pose shows fewer facets to the light; hotter to match the codex (Ryan)


static func sheen_light(energy: float = SHEEN) -> DirectionalLight3D:
	var l := DirectionalLight3D.new()
	l.name = "Sheen"
	l.light_energy = energy
	l.light_specular = 1.0
	l.shadow_enabled = false
	l.light_cull_mask = 1 << (SHEEN_LAYER - 1)
	l.rotation_degrees = Vector3(-50.0, 0.0, 0.0)   # from well above the camera, so the spine's upper strakes catch it at the skirmish's rear pose too
	return l


## How hot this view's sheen is; the skirmish asks for more than the codex.
func set_sheen(energy: float) -> void:
	var l := _camera.get_node_or_null("Sheen")
	if l is DirectionalLight3D:
		(l as DirectionalLight3D).light_energy = energy


static func has_model(chassis_id: String) -> bool:
	return ResourceLoader.exists("res://art/models/%s.glb" % chassis_id)


## Four toon tones from one colour, the way the maker ramps are built: two darker, the
## colour itself, one lighter.
static func ramp_for(c: Color) -> Array:
	return [c.darkened(0.55).to_html(false), c.darkened(0.3).to_html(false), c.to_html(false), c.lightened(0.3).to_html(false)]


## Which glTF a chassis draws: its own, else the fallback named, else the stand-in (below).
## RIFTGATE_MECH3D_MODEL=<id> shows another exported file in every slot instead, for previewing
## a model without installing it.
static func model_for(chassis_id: String, fallback: String = "") -> String:
	var over := OS.get_environment("RIFTGATE_MECH3D_MODEL")
	if not over.is_empty() and has_model(over):
		return over
	if has_model(chassis_id):
		return chassis_id
	return fallback if not fallback.is_empty() else stand_in()


## The model a chassis without one of its own borrows: the first chassis in content's order that
## has one, so the default comes from content and a renamed id renames it (CLAUDE.md's rule).
static var _stand_in := ""

static func stand_in() -> String:
	if _stand_in.is_empty():
		for id in ContentDB.load_default().chassis.keys():
			if has_model(str(id)):
				_stand_in = str(id)
				break
	return _stand_in


## What a node name in the model means: ["joint", "shoulder_l"], ["hp", 1], or [] for a part
## (MechRig.parse_tag; kept here for the tools that read it).
static func parse_tag(node_name: String) -> Array:
	return MechRig.parse_tag(node_name)


## Which look the screens use: "clean" by default, RIFTGATE_MECH3D=pixel for the pixel look,
## RIFTGATE_MECH3D=off for the 2D sprites.
static func look_setting() -> String:
	var env := OS.get_environment("RIFTGATE_MECH3D")
	if env == "off" or DisplayServer.get_name() == "headless":   # tests: no renderer, placeholders
		return ""
	return "clean"


## Build a view of a chassis in one of the two looks. Falls back to the given chassis when
## the wanted one has no model, so a screen can show one model in every slot (none given, the
## stand-in).
static func make(chassis_id: String, maker: String, look: String, fallback: String = "", yaw_deg: float = YAW_REAR, frame: Vector2i = Vector2i.ZERO, spinning: bool = false, paint_arg: Dictionary = {}, plan_arg: Array = []) -> MechView3D:
	var v := MechView3D.new()
	v.mode = look
	v.yaw = yaw_deg
	v.frame_override = frame
	v.spin = spinning
	v.paint = paint_arg
	var id := model_for(chassis_id, fallback)
	v.model_id = id
	v.plan = plan_arg if id == chassis_id else []   # a borrowed model never wears another machine's kit
	v._setup(id, maker)
	return v


## A machine standing on the skirmish's floor, drawn by the floor's camera (`field`, above).
static func make_on_floor(chassis_id: String, maker: String, look: String, field_arg: Dictionary, paint_arg: Dictionary = {}, plan_arg: Array = []) -> MechView3D:
	var v := MechView3D.new()
	v.mode = look
	v.yaw = YAW_FIELD + float(field_arg.get("turn", 0.0))
	v.field = field_arg
	v.paint = paint_arg
	var id := model_for(chassis_id, "")
	v.model_id = id
	v.plan = plan_arg if id == chassis_id else []
	v._setup(id, maker)
	return v


## The silhouette classes (decided 29 September; ContentDB.SHAPES is the list): a fitted
## component wears its class at the pin, in its own maker's metal, from
## art/models/shapes/<shape>_<maker>.glb.
static func shape_model(shape: String, maker: String) -> String:
	return "shapes/%s_%s" % [shape, maker]


## What a machine's mounts must change to show its fitted die instead of the chassis's
## stock loadout (the rule, 30 September): the model's pins are gun mounts, hp_1 onward,
## and the die's shaped components (a weapon, or anything else that looks like one) take them
## in the die's order; a component with no shape (armour, a vent) takes a die entry and no
## mount. One row [k, component, shape, maker] per mount whose component is not the one
## the stock loadout put there, with an empty component for a mount left bare (the stock
## part hides and nothing replaces it). Empty when the die is the stock kit, which every
## machine's is today.
static func mount_plan(die: Die, stock: Array, db: ContentDB) -> Array:
	var out: Array = []
	if die == null:
		return out
	var fitted: Array = []
	for f in die.faces:
		if f.fixed or f.component.is_empty():
			continue
		if _shaped(f.component, db):
			fitted.append(f.component)
	var stock_mounts: Array = []
	for cid in stock:
		if _shaped(str(cid), db):
			stock_mounts.append(str(cid))
	for k in range(maxi(fitted.size(), stock_mounts.size())):
		var want := str(fitted[k]) if k < fitted.size() else ""
		var have := str(stock_mounts[k]) if k < stock_mounts.size() else ""
		if want == have:
			continue
		if want.is_empty():
			out.append([k + 1, "", "", ""])
		else:
			var c: Dictionary = db.components.get(want, {})
			out.append([k + 1, want, str(c.get("shape", "")), str(c.get("maker", ""))])
	return out


## Whether a component takes a mount: it has a shape other than none.
static func _shaped(cid: String, db: ContentDB) -> bool:
	var shape := str(db.components.get(cid, {}).get("shape", ContentDB.SHAPE_NONE))
	return not shape.is_empty() and shape != ContentDB.SHAPE_NONE


## The plan for a unit against its chassis's stock loadout in content.
static func plan_for(u: Unit, db: ContentDB) -> Array:
	if u == null or db == null:
		return []
	var stock: Array = db.chassis.get(u.chassis_id, {}).get("loadout", [])
	return mount_plan(u.die, stock, db)


## A plan from a debug spec, "1:enfilade_beam,4:coolant_jacket" (RIFTGATE_FIT in tools/hero_shot.gd):
## the pin's number and the component to hang there, or "1:" to empty a socket.
static func plan_from_spec(spec: String, db: ContentDB) -> Array:
	var out: Array = []
	for item in spec.split(",", false):
		var parts := item.strip_edges().split(":")
		if parts.size() != 2 or not parts[0].is_valid_int():
			continue
		var cid := parts[1].strip_edges()
		if cid.is_empty():
			out.append([int(parts[0]), "", "", ""])
		elif db.components.has(cid) and _shaped(cid, db):
			var c: Dictionary = db.components[cid]
			out.append([int(parts[0]), cid, str(c.get("shape", "")), str(c.get("maker", ""))])
	return out


## Wear the plan: each row hangs its class shape on its pin, or bares the socket.
func _apply_plan() -> void:
	for row in plan:
		if row.size() < 4:
			continue
		var n := int(row[0])
		if str(row[1]).is_empty():
			hide_stock(n)
		elif not mount_shape(n, str(row[2]), str(row[3])):
			push_warning("no shape model for %s (%s) on hp_%d of %s" % [row[1], row[2], n, model_id])


## Hang a silhouette class on a pin in a maker's metal; false when the pin or the shape's
## model is missing.
func mount_shape(n: int, shape: String, maker: String) -> bool:
	var id := shape_model(shape, maker)
	if not has_model(id):
		return false
	return mount(n, load("res://art/models/%s.glb" % id), maker)


## Bare a socket: the stock part hides and nothing replaces it (an empty hardpoint).
func hide_stock(n: int) -> void:
	if not hardpoints.has(n):
		return
	for c in (hardpoints[n] as Node3D).get_children():
		if c is Node3D:
			c.visible = false


var density := 1.0              # device pixels a design pixel: the render is this much larger than `frame_px` (Hud.density)
var frame_px := Vector2i.ZERO   # the design-size frame the render stands for; a consumer draws the texture at this size

func _setup(chassis_id: String, maker: String) -> void:
	var frame := frame_override if frame_override != Vector2i.ZERO else PIXEL_FRAME * CLEAN_SCALE
	if not field.is_empty():
		frame = Vector2i((field["window"] as Rect2).size.round())
	frame_px = frame
	density = Hud.density(self)
	var px := Vector2i((Vector2(frame) * density).round())
	# The outer viewport holds the outlined 2D result; the inner one renders the 3D, both
	# at the glass's density (Ryan, 29 September: the skirmish's machines get the map's
	# sharpness too).
	size = px
	transparent_bg = true
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	canvas_item_default_texture_filter = SubViewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

	var nested := OS.get_environment("RIFTGATE_MECH3D_FLAT") != "1"   # debug: no outline pass, 3D straight into this viewport
	if nested:
		_inner = SubViewport.new()
		_inner.size = px
		_inner.own_world_3d = true     # otherwise every mech view shares one world and the models overlap
		_inner.transparent_bg = true
		_inner.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_inner.msaa_3d = Hud.msaa_3d()
		_inner.screen_space_aa = SubViewport.SCREEN_SPACE_AA_DISABLED   # FXAA is refused by the Compatibility renderer (the phone's), so no screen-space AA anywhere
		add_child(_inner)
	else:
		_inner = self
		own_world_3d = true
		msaa_3d = Hud.msaa_3d()

	var scene: PackedScene = load("res://art/models/%s.glb" % chassis_id)
	_model = scene.instantiate()
	# The model hangs off a pivot at its own bounds' centre (a model's origin is wherever
	# its author put it; the Badger's is off to one side, and it turned around that, Ryan
	# 22 September). Yaw, spin and sway all turn the pivot. The ground stays at y = 0.
	_stage = Node3D.new()
	_inner.add_child(_stage)
	_pivot = Node3D.new()
	_stage.add_child(_pivot)
	_pivot.add_child(_model)
	var corners: Array[Vector3] = []
	_collect_corners_local(_model, _model, corners)   # before the tree: relative transforms, never global
	var widest := 0.0
	if not corners.is_empty():
		var lo := corners[0]
		var hi := corners[0]
		for c in corners:
			lo = Vector3(minf(lo.x, c.x), minf(lo.y, c.y), minf(lo.z, c.z))
			hi = Vector3(maxf(hi.x, c.x), maxf(hi.y, c.y), maxf(hi.z, c.z))
		_model.position = -Vector3((lo.x + hi.x) * 0.5, 0.0, (lo.z + hi.z) * 0.5)
		widest = maxf(hi.x - lo.x, hi.z - lo.z)
		if not field.is_empty():
			# On its hex at the floor's scale, a tall machine kept to the same share of the hex
			# a wide one is; the pivot under the stage still turns and bobs in model units.
			var tall := hi.y - minf(lo.y, 0.0)
			_field_scale = float(field.get("fill", 0.86)) / maxf(0.001, maxf(widest, tall * 0.8))
			var at: Vector2 = field["at"]
			_stage.position = Vector3(at.x, float(field.get("lift", 0.0)), -at.y)
			_stage.scale = Vector3.ONE * _field_scale
	_pivot.rotation.y = deg_to_rad(yaw)
	_apply_materials(_model, maker)
	MechWeld.weld(_model, MechWeld.kept_parts(chassis_id))   # a mesh a material in each moving group (the battery plan), before the rig and the traces read it
	rig.place = "skirmish"
	rig.setup(_model, chassis_id)   # after the materials: the acts' glows look for the lit surfaces
	if widest > 0.0:
		# The debug drive (RIFTGATE_MOVE_DEBUG) runs at the machine's own pace on the map.
		var c: Dictionary = ContentDB.load_default().chassis.get(chassis_id, {})
		rig.top_speed = MechRig.map_speed(widest, int(c.get("movespeed", Unit.MECH_MOVE)), Map3D.fit_for(str(c.get("size", ""))))
	joints = rig.joints
	hardpoints = rig.hardpoints
	_apply_plan()   # before the traces attach and the camera frames, so a mounted shape gets both
	if not token:
		# The skirmish's machines carry the display's trace too (Ryan, 21 September); the
		# screen's scan bar lights it through set_sweep_screen.
		var tmode := TraceLines.mode()
		if spin:
			# The codex: black ink only, no scan (Ryan, 22 September).
			_trace_mat = TraceLines.ink_material()
		elif tmode == "pulse":
			_trace_mat = TraceLines.pulse_material(Palette.HUD)
		elif TraceLines.inked(tmode, "asset"):
			_trace_mat = TraceLines.ink_material()
		else:
			_trace_mat = TraceLines.light_material(Palette.HUD)
		if _trace_mat is ShaderMaterial:
			(_trace_mat as ShaderMaterial).set_shader_parameter("gain", 0.8)
			if not field.is_empty():
				# The scan's reach and wake are in world units, the model's own until the floor
				# made the world hexes.
				(_trace_mat as ShaderMaterial).set_shader_parameter("lead", 10.0 * _field_scale)
				(_trace_mat as ShaderMaterial).set_shader_parameter("tail", 75.0 * _field_scale)
		TraceLines.attach(_model, _trace_mat)
	if OS.get_environment("RIFTGATE_MECH3D_WIRE") == "1":
		# Wireframe trial (21 September): the reconstruction's own telemetry drawing.
		_inner.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	# One sun from the front-left and above, a little cool ambient, and shadows, so the
	# tiled facets and overhangs read. The toon shader carries its own light and ignores it.
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.7
	sun.rotation_degrees = Vector3(-55.0, (yaw if field.is_empty() else YAW_FIELD) - 150.0, 0.0)   # on the floor one sun for the squad, however each is turned
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 2000.0 if field.is_empty() else 30.0   # the floor's world is in hexes
	_inner.add_child(sun)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0, 0, 0, 0)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("a0b4c8")
	e.ambient_light_energy = 0.7
	# A plain sky for reflections only (the ambient stays the flat colour above), so chrome
	# has something to mirror: Kestrel shines, the signature (Ryan, 22 September).
	e.sky = chrome_sky()
	e.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	e.glow_enabled = true
	e.glow_intensity = 0.5
	e.glow_bloom = 0.05
	e.glow_hdr_threshold = 1.0
	env.environment = e
	_inner.add_child(env)

	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	if not field.is_empty():
		# The floor's camera, level at its height, looking down the floor; this view is the
		# window of its picture where the machine stands: a frustum shifted off its centre.
		var win: Rect2 = field["window"]
		var principal: Vector2 = field["principal"]
		var focal := float(field["focal"])
		var c := win.get_center()
		_camera.projection = Camera3D.PROJECTION_FRUSTUM
		_camera.near = 0.05
		_camera.far = 400.0
		_camera.size = _camera.near * win.size.y / focal
		_camera.frustum_offset = Vector2(_camera.near * (c.x - principal.x) / focal, -_camera.near * (c.y - principal.y) / focal)
		_camera.position = Vector3(0.0, float(field["height"]), 0.0)
	_inner.add_child(_camera)
	_camera.add_child(sheen_light())
	# Framing needs global transforms, so it waits for the tree (see _ready).

	if nested:
		var rect := TextureRect.new()
		rect.texture = _inner.get_texture()
		rect.size = px
		rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var mat := ShaderMaterial.new()
		mat.shader = load("res://game/ui/outline.gdshader")
		mat.set_shader_parameter("width", float(CLEAN_SCALE) * density)
		rect.material = mat
		add_child(rect)
	texture = get_texture()


func _ready() -> void:
	_frame_camera()
	set_process(spin or sway or rig.alive())


func _process(delta: float) -> void:
	if _model == null:
		return
	_t += delta
	if spin:
		_pivot.rotation.y += SPIN_SPEED * delta
	elif sway:
		_pivot.rotation.y = deg_to_rad(yaw) + sin(_t * 0.9 + sway_phase) * sway_yaw
		if balance != null:
			balance.quiet = rig.in_act()
			balance.step(delta)
			_pivot.rotation.x = balance.pitch
			_pivot.rotation.z = balance.roll
			_pivot.position.y = balance.heave * sway_bob
		else:
			_pivot.rotation.x = sin(_t * 0.7 + sway_phase * 0.5) * sway_pitch
			_pivot.position.y = sin(_t * 1.9 + sway_phase) * sway_bob + sin(_t * 0.6 + sway_phase) * sway_bob * 0.5
	# A grounded machine's idle is its acts, what the pilot does with it every few seconds
	# (the idle-acts row, 2 October); the rig plays them and the strikes from the model's
	# sidecar. It never sways.
	rig.tick(delta)


## The node-space axis a joint turns about when its sidecar names none: a turret
## (`joint_turret`, `joint_turret_l`...), a caster, a steering knuckle, a head or a sensor
## about its up axis; a limb about its x, the axle line (MechRig.axis_for).
static func joint_axis(name: String) -> Vector3:
	return MechRig.axis_vector(MechRig.axis_for(name))


## A blow: the shoulders swing the arms forward and back. Ranged: every joint carrying a
## weapon socket kicks about its own axis, a recoil; a turret with a mount flinches on its
## traverse. A melee blow leaves turrets alone. Does nothing on an untagged model (MechRig).
func strike(ranged: bool) -> void:
	if not is_inside_tree():
		return
	rig.strike(ranged)
	set_process(true)


## Hang a component's model on a socket: the stock part under `hp_<n>` is hidden and the
## scene is added under the pin, so it points where the pin points and wears the pin's
## scale (lowforge sets both; a Sparrowhawk's pins are half size). Returns false when the
## model has no such socket.
func mount(n: int, scene: PackedScene, maker: String) -> bool:
	if not hardpoints.has(n):
		return false
	var pin: Node3D = hardpoints[n]
	for c in pin.get_children():
		if c is Node3D:
			c.visible = false
	var part := scene.instantiate()
	part.set_meta("mounted", true)
	pin.add_child(part)
	_apply_materials(part, maker)
	MechWeld.weld(part as Node3D)
	return true


## Show the placeholder again and drop anything mounted.
func unmount(n: int) -> void:
	if not hardpoints.has(n):
		return
	var pin: Node3D = hardpoints[n]
	for c in pin.get_children():
		if c.has_meta("mounted"):
			c.queue_free()
		elif c is Node3D:
			c.visible = true


func _apply_materials(node: Node, maker: String) -> void:
	toon(node, maker, mode, paint, token, hide_detail)


## Give every mesh under `node` the toon shader in the maker's tones (or a repaint), the way
## the skirmish and the codex draw a mech. Shared with the 3D battlefield (Map3D).
static func toon(node: Node, maker: String, look: String, paint_arg: Dictionary = {}, as_token: bool = false, drop_detail: bool = true) -> void:
	if node is MeshInstance3D:
		var mi: MeshInstance3D = node
		for i in range(mi.mesh.get_surface_count()):
			var src := mi.get_active_material(i)
			var role := "steel"
			if src != null:
				role = src.resource_name.get_slice(".", 0).to_lower()
			var ramp: Array = LIVERY.get(maker, LIVERY.values()[0]) if role == "livery" else RAMPS.get(role, RAMPS["steel"])
			# A repaint: the primary colour takes the livery panels, the secondary the bone plating.
			if role == "livery" and paint_arg.has("primary"):
				ramp = ramp_for(paint_arg["primary"])
			elif role == "white" and paint_arg.has("secondary"):
				ramp = ramp_for(paint_arg["secondary"])
			if src is StandardMaterial3D and (src as StandardMaterial3D).albedo_texture != null:
				# A lowforge model (the ally register, decided 21 September): its own tiled
				# texture, nearest filtered through its mipmaps, flat facets, lit by the scene's sun, gloss by
				# maker. The toon pass below is for untextured models (the structures).
				var tm: StandardMaterial3D = (src as StandardMaterial3D).duplicate()
				tm.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS if Hud.smoothing() else BaseMaterial3D.TEXTURE_FILTER_NEAREST   # its mipmaps, so a machine drawn small never sparkles
				var finish: Array = FINISH.get(maker, FINISH.values()[0])
				if float(finish[1]) >= 0.25:
					mi.layers |= 1 << (SHEEN_LAYER - 1)   # the sheen light finds it
				tm.roughness = float(finish[0])
				tm.metallic = float(finish[1])
				tm.metallic_specular = float(finish[2])
				tm.cull_mode = BaseMaterial3D.CULL_DISABLED   # wings and fins are single plates
				# Opaque and writing depth, whatever the export said: a machine stands on the
				# grid and hides it, like a prop or the wall (Ryan, 22 September).
				tm.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
				tm.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
				if role == "amber":
					# Lamps, engines and light strips glow: the reconstruction's own light.
					tm.emission_enabled = true
					tm.emission_texture = tm.albedo_texture
					tm.emission_energy_multiplier = 1.8
				elif role == "glass":
					tm.roughness = 0.25
					tm.metallic = 0.35
				mi.set_surface_override_material(i, tm)
				continue
			var m := ShaderMaterial.new()
			m.shader = load("res://game/ui/mech_toon.gdshader")
			for t in range(4):
				m.set_shader_parameter("tone%d" % t, Color(ramp[t]))
			m.set_shader_parameter("bands", 0)
			m.set_shader_parameter("role", ROLE_INDEX.get(role, 0))
			m.set_shader_parameter("gloss", float(GLOSS.get(maker, 0.4)))
			if as_token:
				# At 24 px the surface pass is noise and the wear is mud: flat tones, lit
				# from above and the viewer's side so the top and front read.
				for u in ["grime", "wear", "dust", "seams", "chips"]:
					m.set_shader_parameter(u, 0.0)
				m.set_shader_parameter("gloss", 0.0)
				m.set_shader_parameter("light_dir", Vector3(-0.4, 0.8, -0.45))
			mi.set_surface_override_material(i, m)
		if as_token and drop_detail and node.name.contains("detail"):
			mi.visible = false   # the spriter drops detail parts from tokens too
	for c in node.get_children():
		toon(c, maker, look, paint_arg, as_token, drop_detail)


## The world height an orthographic camera shows so a model whose projection spans `extent`
## fills FILL of a frame `aspect` wide to tall, times `k` (its class's share, SIZE_FILL).
static func view_height(extent: Vector2, aspect: float, k: float = 1.0) -> float:
	return maxf(extent.y, extent.x / aspect) / (FILL * clampf(k, 0.1, 1.0))


## Orthographic camera on the sprites' angle, sized so the model fills the frame the way
## blendforge fits it: the projected extents of every mesh's bounds, with a little slack. On
## the floor the camera is the floor's and fixed; only where the drawing lands is measured.
func _frame_camera() -> void:
	if not field.is_empty():
		_frame_field()
		return
	var corners: Array[Vector3] = []
	_collect_corners(_model, corners)
	if corners.is_empty():
		return
	if spin:
		# A turning model must fit at every angle: sweep the corners around the model's axis.
		var swept: Array[Vector3] = []
		for c in corners:
			for step in range(12):
				swept.append(c.rotated(Vector3.UP, deg_to_rad(step * 30.0)))
		corners = swept
	var tilt := deg_to_rad(pitch)
	var back := Vector3(0.0, sin(tilt), -cos(tilt))   # from the model toward the camera
	var up := Vector3(0.0, cos(tilt), sin(tilt))
	var right := Vector3(1.0, 0.0, 0.0)
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	var centre := Vector3.ZERO
	for c in corners:
		centre += c
		var p := Vector2(c.dot(right), c.dot(up))
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	centre /= corners.size()
	var extent := hi - lo
	var aspect := float(size.x) / float(size.y)
	var height := view_height(extent, aspect, size_k)
	_camera.size = height
	var mid := (lo + hi) * 0.5
	# Where the drawing lands in the frame, in pixels: every vertex projected the same way,
	# so a view can hug the model without reading the rendered image back from the GPU.
	# Vertices, not box corners: a tilted box projects taller than the thing inside it.
	var px_per_unit := float(size.y) / height
	var verts: Array[Vector3] = []
	_collect_vertices(_model, verts)
	var vlo := Vector2(INF, INF)
	var vhi := Vector2(-INF, -INF)
	for v in (verts if not verts.is_empty() else corners):
		var p := Vector2(v.dot(right), v.dot(up))
		vlo = Vector2(minf(vlo.x, p.x), minf(vlo.y, p.y))
		vhi = Vector2(maxf(vhi.x, p.x), maxf(vhi.y, p.y))
	_model_rect = Rect2(
		Vector2(size.x * 0.5 + (vlo.x - mid.x) * px_per_unit, size.y * 0.5 - (vhi.y - mid.y) * px_per_unit),
		(vhi - vlo) * px_per_unit)
	var target := right * mid.x + up * mid.y + back * centre.dot(back)
	_camera.position = target + back * 500.0
	_camera.look_at(target, up)
	_target = target
	_screen_down = -up


var _trace_mat: Material = null
var _target := Vector3.ZERO
var _model_rect := Rect2()


## On the floor: where the drawing lands in this view's pixels, every vertex through the
## floor's camera, so the gauges hug it without reading the render back.
func _frame_field() -> void:
	var verts: Array[Vector3] = []
	_collect_vertices(_model, verts)
	if verts.is_empty():
		return
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for v in verts:
		var p := _camera.unproject_position(v)
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	_model_rect = Rect2(lo, hi - lo)
	_screen_down = Vector3(0.0, -1.0, 0.0)


## The model's projected bounds in this view's pixels, from the camera's framing. Gauges
## and chips hug this; nothing reads the viewport's image back (a GPU readback every frame
## on a phone, and an empty one before the first render, which left gauges floating).
func model_rect() -> Rect2:
	return _model_rect
var _screen_down := Vector3.ZERO

## The screen's scan bar, in this view's own pixels from its top: the traces under it light.
func set_sweep_screen(local_y: float) -> void:
	if _trace_mat == null or not (_trace_mat is ShaderMaterial) or _camera == null:
		return
	if not field.is_empty():
		# The floor's camera is level: the band's row is a height at the machine's depth.
		var win: Rect2 = field["window"]
		var at: Vector2 = field["at"]
		var row := win.position.y + local_y / maxf(0.01, density)
		var y := float(field["height"]) - (row - (field["principal"] as Vector2).y) * at.y / float(field["focal"])
		(_trace_mat as ShaderMaterial).set_shader_parameter("sweep_p", -y)
		(_trace_mat as ShaderMaterial).set_shader_parameter("screen_down", Vector3(0.0, -1.0, 0.0))
		return
	var per_px := _camera.size / float(size.y)   # world units per view pixel
	var p := _target.dot(_screen_down) + (local_y - size.y * 0.5) * per_px
	(_trace_mat as ShaderMaterial).set_shader_parameter("sweep_p", p)
	(_trace_mat as ShaderMaterial).set_shader_parameter("screen_down", _screen_down)
	_camera.near = 1.0
	_camera.far = 2000.0


func _collect_vertices(node: Node, out: Array[Vector3]) -> void:
	if node is MeshInstance3D and (node as MeshInstance3D).visible and (node as MeshInstance3D).mesh != null:
		var mi: MeshInstance3D = node
		for v in mi.mesh.get_faces():
			out.append(mi.global_transform * v)
	for c in node.get_children():
		_collect_vertices(c, out)


## Every mesh's box corners in `root`'s own space, by walking the parent chain: usable
## before anything is in the tree, where global transforms are not. A welded mesh gives its
## parts' boxes (MechWeld.corners).
func _collect_corners_local(node: Node, root: Node3D, out: Array[Vector3]) -> void:
	if node is MeshInstance3D and (node as MeshInstance3D).visible:
		var mi: MeshInstance3D = node
		var xf := Transform3D.IDENTITY
		var p: Node = mi
		while p != null and p != root:
			if p is Node3D:
				xf = (p as Node3D).transform * xf
			p = p.get_parent()
		for c in MechWeld.corners(mi):
			out.append(xf * c)
	for c in node.get_children():
		_collect_corners_local(c, root, out)


func _collect_corners(node: Node, out: Array[Vector3]) -> void:
	if node is MeshInstance3D and (node as MeshInstance3D).visible:
		var mi: MeshInstance3D = node
		for c in MechWeld.corners(mi):
			out.append(mi.global_transform * c)
	for c in node.get_children():
		_collect_corners(c, out)
