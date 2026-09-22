class_name MechView3D
extends SubViewport

## A player mech drawn in 3D for the skirmish screen. The model (art/models/<chassis>.glb,
## exported from Blender with materials named by role) is lit by the spriter's toon shader,
## framed by an orthographic camera at the sprites' angle (30 degrees down, turned 45 off
## head-on), then outlined in 2D. `texture` is a Texture2D the UnitView can draw like a sprite.
##
## Two looks. "pixel": rendered at the sprite frame (80x96) with hard tone steps and a
## one-pixel outline, drawn at 2x like the sprites, so it sits on the foes' pixel grid.
## "clean": rendered at 160x192 with smooth shading, drawn at 1x, so it is the same size on
## screen but twice the resolution and no pixel grid: real 3D against the 2D foes.
## Experiment, 16 September. RIFTGATE_MECH3D=pixel|clean switches the skirmish screen to it.

const PIXEL_FRAME := Vector2i(80, 96)
const CLEAN_SCALE := 2
const PITCH := 30.0
const YAW_FRONT := 45.0     # front three-quarter: the codex hero angle
const YAW_REAR := 225.0     # rear three-quarter, kept for hero shots
const YAW_SKIRMISH := 155.0 # the skirmish: rear three-quarter facing the foes above, turned to the left (the claw side shows)
const FILL := 0.92

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
const LIVERY := {
	"minerva": ["3a0f16", "5a1620", "8a2430", "b8303f"],
	"kestrel": ["132148", "1c3270", "2d4fa8", "4a74d8"],
	"wainwright_sutler": ["8f8a7a", "a9a291", "d8d2c2", "f0ebdc"],
	"aphelion": ["7a3a10", "b85a18", "f08a2a", "ffb35a"],      # signal orange on gunmetal
	"arsenal": ["6a5a10", "a08a14", "e0c020", "ffe25a"],       # hazard yellow, the HUD's own colour
}

var texture: Texture2D
var mode: String = "pixel"
var spin: bool = false            # turn slowly, for the codex
var sway: bool = false            # a slow idle: a breath of yaw and a bob, for the skirmish
var sway_phase: float = 0.0
var sway_bob: float = 0.35        # model units of vertical drift; a flyer hovers, a tank does not
var sway_yaw: float = 0.035       # radians of yaw drift
var _t := 0.0
var yaw: float = YAW_FRONT
var pitch: float = PITCH          # camera tilt down; the map tokens look steeper (tools/map_tokens.gd)
var token: bool = false           # a 24 px map token: no detail parts, no surface pass, lit from the viewer's side
var hide_detail: bool = true      # in token mode: drop ".detail" parts (a structure sprite keeps them)
var paint: Dictionary = {}        # optional repaint: {"primary": Color, "secondary": Color} over the maker's livery and bone plating
var frame_override: Vector2i = Vector2i.ZERO
const SPIN_SPEED := 0.7           # radians per second

# The model's tags, from the Empties in the Blender file (tools/blendforge/README.md):
# `joint_<name>` is a pivot with the limb's parts under it, `hp_<n>` is a weapon socket with
# its placeholder under it. Both come through the glTF as plain Node3Ds by name.
var joints: Dictionary = {}       # "shoulder_l" -> Node3D
var hardpoints: Dictionary = {}   # 1 -> Node3D
var _rest: Dictionary = {}        # joint name -> rest rotation (Vector3)
var _idle: Dictionary = {}        # joint name -> idle rotation offset, added on top of rest and strikes
var _strike: Dictionary = {}      # joint name -> strike rotation offset (tweened)
const IDLE_SWING := 0.022         # radians: a shoulder settling, barely there

var _inner: SubViewport
var _camera: Camera3D
var _model: Node3D


static func has_model(chassis_id: String) -> bool:
	return ResourceLoader.exists("res://art/models/%s.glb" % chassis_id)


## Four toon tones from one colour, the way the maker ramps are built: two darker, the
## colour itself, one lighter.
static func ramp_for(c: Color) -> Array:
	return [c.darkened(0.55).to_html(false), c.darkened(0.3).to_html(false), c.to_html(false), c.lightened(0.3).to_html(false)]


## Which glTF a chassis draws: its own, else the fallback. RIFTGATE_MECH3D_MODEL=<id> shows
## another exported file in every slot instead, for previewing a model without installing it.
static func model_for(chassis_id: String, fallback: String) -> String:
	var over := OS.get_environment("RIFTGATE_MECH3D_MODEL")
	if not over.is_empty() and has_model(over):
		return over
	return chassis_id if has_model(chassis_id) else fallback


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


## Which look the screens use: "clean" by default, RIFTGATE_MECH3D=pixel for the pixel look,
## RIFTGATE_MECH3D=off for the 2D sprites.
static func look_setting() -> String:
	var env := OS.get_environment("RIFTGATE_MECH3D")
	if env == "off" or DisplayServer.get_name() == "headless":   # tests: no renderer, use the sprites
		return ""
	if env == "pixel" or env == "clean":
		return env
	return "clean"


## Build a view of a chassis in one of the two looks. Falls back to the given chassis when
## the wanted one has no model, so a screen can show one model in every slot.
static func make(chassis_id: String, maker: String, look: String, fallback: String = "badger", yaw_deg: float = YAW_REAR, frame: Vector2i = Vector2i.ZERO, spinning: bool = false, paint_arg: Dictionary = {}) -> MechView3D:
	var v := MechView3D.new()
	v.mode = look
	v.yaw = yaw_deg
	v.frame_override = frame
	v.spin = spinning
	v.paint = paint_arg
	v._setup(model_for(chassis_id, fallback), maker)
	return v


func _setup(chassis_id: String, maker: String) -> void:
	var k := 1 if mode == "pixel" else CLEAN_SCALE
	var frame := frame_override if frame_override != Vector2i.ZERO else PIXEL_FRAME * k
	# The outer viewport holds the outlined 2D result; the inner one renders the 3D.
	size = frame
	transparent_bg = true
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	canvas_item_default_texture_filter = SubViewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

	var nested := OS.get_environment("RIFTGATE_MECH3D_FLAT") != "1"   # debug: no outline pass, 3D straight into this viewport
	if nested:
		_inner = SubViewport.new()
		_inner.size = frame
		_inner.own_world_3d = true     # otherwise every mech view shares one world and the models overlap
		_inner.transparent_bg = true
		_inner.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_inner.msaa_3d = SubViewport.MSAA_DISABLED if mode == "pixel" else SubViewport.MSAA_4X
		_inner.screen_space_aa = SubViewport.SCREEN_SPACE_AA_DISABLED
		add_child(_inner)
	else:
		_inner = self
		own_world_3d = true
		msaa_3d = SubViewport.MSAA_DISABLED if mode == "pixel" else SubViewport.MSAA_4X

	var scene: PackedScene = load("res://art/models/%s.glb" % chassis_id)
	_model = scene.instantiate()
	_model.rotation.y = deg_to_rad(yaw)
	_inner.add_child(_model)
	_apply_materials(_model, maker)
	_collect_tags(_model)
	if not token and mode != "pixel":
		# The skirmish's machines carry the display's trace too (Ryan, 21 September); the
		# screen's scan bar lights it through set_sweep_screen.
		var tmode := TraceLines.mode()
		if spin:
			# The codex: black ink only, no silhouette, no scan (Ryan, 22 September).
			_trace_mat = TraceLines.ink_material()
			for child in _model.find_children("*", "MeshInstance3D", true, false):
				var mi: MeshInstance3D = child
				for i in range(mi.get_surface_override_material_count()):
					var sm := mi.get_surface_override_material(i)
					if sm is BaseMaterial3D and "stencil_mode" in sm:
						sm.set("stencil_mode", BaseMaterial3D.STENCIL_MODE_DISABLED)
		elif tmode == "pulse":
			_trace_mat = TraceLines.pulse_material(Palette.HUD)
		elif TraceLines.inked(tmode, "asset"):
			_trace_mat = TraceLines.ink_material()
		else:
			_trace_mat = TraceLines.light_material(Palette.HUD)
		if _trace_mat is ShaderMaterial:
			(_trace_mat as ShaderMaterial).set_shader_parameter("gain", 0.8)
		TraceLines.attach(_model, _trace_mat)
	if OS.get_environment("RIFTGATE_MECH3D_WIRE") == "1":
		# Wireframe trial (21 September): the reconstruction's own telemetry drawing.
		_inner.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	# One sun from the front-left and above, a little cool ambient, and shadows, so the
	# tiled facets and overhangs read. The toon shader carries its own light and ignores it.
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.7
	sun.rotation_degrees = Vector3(-55.0, yaw - 150.0, 0.0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 2000.0
	_inner.add_child(sun)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0, 0, 0, 0)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("a0b4c8")
	e.ambient_light_energy = 0.7
	e.glow_enabled = true
	e.glow_intensity = 0.5
	e.glow_bloom = 0.05
	e.glow_hdr_threshold = 1.0
	env.environment = e
	_inner.add_child(env)

	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	_inner.add_child(_camera)
	# Framing needs global transforms, so it waits for the tree (see _ready).

	if nested:
		var rect := TextureRect.new()
		rect.texture = _inner.get_texture()
		rect.size = frame
		rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var mat := ShaderMaterial.new()
		mat.shader = load("res://game/ui/outline.gdshader")
		mat.set_shader_parameter("width", float(k))
		rect.material = mat
		add_child(rect)
	texture = get_texture()


func _ready() -> void:
	_frame_camera()
	set_process(spin or sway or not joints.is_empty())


func _process(delta: float) -> void:
	if _model == null:
		return
	_t += delta
	if spin:
		_model.rotation.y += SPIN_SPEED * delta
	elif sway:
		_model.rotation.y = deg_to_rad(yaw) + sin(_t * 0.9 + sway_phase) * sway_yaw
		_model.position.y = sin(_t * 1.9 + sway_phase) * sway_bob + sin(_t * 0.6 + sway_phase) * sway_bob * 0.5
	if not joints.is_empty():
		# A ground machine's idle is its limbs: each joint settles slowly about its pivot,
		# left and right out of step, so the mech stands like a machine under power.
		var k := 0
		for name in joints.keys():
			var side := 1.0 if str(name).ends_with("_r") else -1.0
			_idle[name] = Vector3(sin(_t * 0.7 + sway_phase + k * 1.3) * IDLE_SWING * side, 0.0, 0.0)
			k += 1
		_pose_joints()


## Rest plus idle plus strike, applied to every joint. Rotations are about the joint's own
## axes: x swings a limb forward and back (Blender's X, the axle line), y turns it in.
func _pose_joints() -> void:
	for name in joints.keys():
		var j: Node3D = joints[name]
		j.rotation = _rest[name] + _idle.get(name, Vector3.ZERO) + _strike.get(name, Vector3.ZERO)


## A blow: the shoulders swing the arms forward and back. Ranged: only the arms with a
## weapon socket kick back, a recoil. Does nothing on an untagged model.
func strike(ranged: bool) -> void:
	if joints.is_empty() or not is_inside_tree():
		return
	var armed := {}
	for n in hardpoints.keys():
		var owner := _joint_of(hardpoints[n])
		if not owner.is_empty():
			armed[owner] = true
	for name in joints.keys():
		var swing: float
		if ranged:
			if not armed.has(name):
				continue
			swing = 0.09
		else:
			swing = -0.5
		var tw := create_tween()
		tw.tween_method(_set_strike.bind(name), Vector3.ZERO, Vector3(swing, 0.0, 0.0), 0.10 if not ranged else 0.05).set_ease(Tween.EASE_OUT)
		tw.tween_method(_set_strike.bind(name), Vector3(swing, 0.0, 0.0), Vector3.ZERO, 0.28 if not ranged else 0.2).set_ease(Tween.EASE_IN_OUT)


func _set_strike(value: Vector3, name: String) -> void:
	_strike[name] = value
	_pose_joints()


## The joint a node hangs under, by name, or "" when it is on the body.
func _joint_of(node: Node) -> String:
	var p := node.get_parent()
	while p != null and p != _model:
		var tag := parse_tag(p.name)
		if tag.size() == 2 and tag[0] == "joint":
			return str(tag[1])
		p = p.get_parent()
	return ""


## Hang a component's model on a socket: the placeholder under `hp_<n>` is hidden and the
## scene is added under the pin, so it points where the pin points. Returns false when the
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


func _collect_tags(node: Node) -> void:
	var tag := parse_tag(node.name)
	if tag.size() == 2 and node is Node3D:
		if tag[0] == "joint":
			joints[tag[1]] = node
			_rest[tag[1]] = (node as Node3D).rotation
		else:
			hardpoints[tag[1]] = node
	for c in node.get_children():
		_collect_tags(c)


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
			var ramp: Array = LIVERY.get(maker, LIVERY["minerva"]) if role == "livery" else RAMPS.get(role, RAMPS["steel"])
			# A repaint: the primary colour takes the livery panels, the secondary the bone plating.
			if role == "livery" and paint_arg.has("primary"):
				ramp = ramp_for(paint_arg["primary"])
			elif role == "white" and paint_arg.has("secondary"):
				ramp = ramp_for(paint_arg["secondary"])
			if src is StandardMaterial3D and (src as StandardMaterial3D).albedo_texture != null:
				# A lowforge model (the ally register, decided 21 September): its own tiled
				# texture, nearest filtered, flat facets, lit by the scene's sun, gloss by
				# maker. The toon pass below is for untextured models (the structures).
				var tm: StandardMaterial3D = (src as StandardMaterial3D).duplicate()
				tm.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
				tm.roughness = clampf(1.0 - float(GLOSS.get(maker, 0.4)) * 0.9, 0.3, 0.98)
				tm.metallic = 0.0
				tm.cull_mode = BaseMaterial3D.CULL_DISABLED   # wings and fins are single plates
				if TraceLines.mode() in ["assets", "pulse"]:
					TraceLines.silhouette(tm, Palette.HUD, 2.0)   # the light outline around the whole machine
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
			m.set_shader_parameter("bands", 4 if look == "pixel" else 0)
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


## Orthographic camera on the sprites' angle, sized so the model fills the frame the way
## blendforge fits it: the projected extents of every mesh's bounds, with a little slack.
func _frame_camera() -> void:
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
	var height := maxf(extent.y, extent.x / aspect) / FILL
	_camera.size = height
	var mid := (lo + hi) * 0.5
	var target := right * mid.x + up * mid.y + back * centre.dot(back)
	_camera.position = target + back * 500.0
	_camera.look_at(target, up)
	_target = target
	_screen_down = -up


var _trace_mat: Material = null
var _target := Vector3.ZERO
var _screen_down := Vector3.ZERO

## The screen's scan bar, in this view's own pixels from its top: the traces under it light.
func set_sweep_screen(local_y: float) -> void:
	if _trace_mat == null or not (_trace_mat is ShaderMaterial) or _camera == null:
		return
	var per_px := _camera.size / float(size.y)   # world units per view pixel
	var p := _target.dot(_screen_down) + (local_y - size.y * 0.5) * per_px
	(_trace_mat as ShaderMaterial).set_shader_parameter("sweep_p", p)
	(_trace_mat as ShaderMaterial).set_shader_parameter("screen_down", _screen_down)
	_camera.near = 1.0
	_camera.far = 2000.0


func _collect_corners(node: Node, out: Array[Vector3]) -> void:
	if node is MeshInstance3D and (node as MeshInstance3D).visible:
		var mi: MeshInstance3D = node
		var aabb := mi.get_aabb()
		for i in range(8):
			out.append(mi.global_transform * aabb.get_endpoint(i))
	for c in node.get_children():
		_collect_corners(c, out)
