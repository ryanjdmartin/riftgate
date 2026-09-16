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
const YAW := 45.0
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
const LIVERY := {
	"halvard": ["3a0f16", "5a1620", "8a2430", "b8303f"],
	"kestrel": ["132148", "1c3270", "2d4fa8", "4a74d8"],
	"orrin_pike": ["8f8a7a", "a9a291", "d8d2c2", "f0ebdc"],
}

var texture: Texture2D
var mode: String = "pixel"

var _inner: SubViewport
var _camera: Camera3D
var _model: Node3D


static func has_model(chassis_id: String) -> bool:
	return ResourceLoader.exists("res://art/models/%s.glb" % chassis_id)


## Build a view of a chassis in one of the two looks. Falls back to the given chassis when
## the wanted one has no model, so a screen can show one model in every slot.
static func make(chassis_id: String, maker: String, look: String, fallback: String = "bulwark") -> MechView3D:
	var v := MechView3D.new()
	v.mode = look
	v._setup(chassis_id if has_model(chassis_id) else fallback, maker)
	return v


func _setup(chassis_id: String, maker: String) -> void:
	var k := 1 if mode == "pixel" else CLEAN_SCALE
	var frame := PIXEL_FRAME * k
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
	_model.rotation.y = deg_to_rad(YAW)
	_inner.add_child(_model)
	_apply_materials(_model, maker)

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


func _apply_materials(node: Node, maker: String) -> void:
	if node is MeshInstance3D:
		var mi: MeshInstance3D = node
		for i in range(mi.mesh.get_surface_count()):
			var src := mi.get_active_material(i)
			var role := "steel"
			if src != null:
				role = src.resource_name.get_slice(".", 0).to_lower()
			var ramp: Array = LIVERY.get(maker, LIVERY["halvard"]) if role == "livery" else RAMPS.get(role, RAMPS["steel"])
			var m := ShaderMaterial.new()
			m.shader = load("res://game/ui/mech_toon.gdshader")
			for t in range(4):
				m.set_shader_parameter("tone%d" % t, Color(ramp[t]))
			m.set_shader_parameter("bands", 4 if mode == "pixel" else 0)
			mi.set_surface_override_material(i, m)
	for c in node.get_children():
		_apply_materials(c, maker)


## Orthographic camera on the sprites' angle, sized so the model fills the frame the way
## blendforge fits it: the projected extents of every mesh's bounds, with a little slack.
func _frame_camera() -> void:
	var corners: Array[Vector3] = []
	_collect_corners(_model, corners)
	if corners.is_empty():
		return
	var pitch := deg_to_rad(PITCH)
	var back := Vector3(0.0, sin(pitch), -cos(pitch))   # from the model toward the camera
	var up := Vector3(0.0, cos(pitch), sin(pitch))
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
	_camera.near = 1.0
	_camera.far = 2000.0


func _collect_corners(node: Node, out: Array[Vector3]) -> void:
	if node is MeshInstance3D:
		var mi: MeshInstance3D = node
		var aabb := mi.get_aabb()
		for i in range(8):
			out.append(mi.global_transform * aabb.get_endpoint(i))
	for c in node.get_children():
		_collect_corners(c, out)
