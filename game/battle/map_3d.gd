class_name Map3D
extends SubViewport

## The battlefield in 3D (decided 19 September). Every hex is a column with a real height by
## terrain wearing a material tile from art/terrain (decided 21 September: the ground is the
## same kind of texture as the units), the gate and walls are models, and the player's mechs
## are the skirmish's own models with an outline, all under an orthographic camera pitched
## like the map tokens, with one sun casting shadows. Foes are never here: they are flat
## pictures the map view draws over this viewport's texture, because they are the other
## world showing through.
##
## The viewport is the size of the screen area, not the map: the camera pans and zooms in
## the world to follow the map view's scroll and zoom (`look`), so a frame costs the same at
## any zoom and the scene can render every frame. That pays for the idle sway, the water
## ripple and, later, the movement phase. The ground is stretched in depth so a hex at
## ground level projects exactly onto the 2D grid the overlays and gestures use; a raised
## hex's top sits higher on screen by `lift`, and the overlays ask for it.

const PITCH := 42.0            # the map tokens' tilt
const HEX_WORLD := 35.0        # a hex's circumradius in model units: a mech is about one hex wide
const CAMERA_DISTANCE := 900.0
const MARKER_FIT := 1.05       # a mech's widest extent, in hex widths, on the map
const FIT_FLYER := 0.8         # a flyer is a small craft beside a mech (Ryan, 21 September)
## The ground keeps its true height under the bleed; the other world's painting sits over
## it at ground level, half up and half down (Ryan, 22 September: flawless). The enemy's
## marks sit at the base. So nothing on the ground moves once built, and all of it is
## baked into a few meshes (see `_bake`).
const BAND_ROWS := 4           # rows of hexes per baked mesh, so the far end still culls under zoom
const UNITS_LAYER := 2         # the machines render again into their own layer, drawn over both worlds
const HOVER := 30.0            # a flyer rides this far above the ground, in model units: clear of a mech
const SHADOW_RADIUS := 0.38    # a flyer's ground shadow, in hex widths: it says which tile it is on
const TILE_WORLD := 40.0       # world units one terrain tile covers, as the structures

const TERRAIN := {
	BattleMap.Terrain.PLAIN: Color("2a3628"),
	BattleMap.Terrain.ROAD: Color("46422f"),
	BattleMap.Terrain.ROUGH: Color("3a3824"),
	BattleMap.Terrain.RUINS: Color("393c39"),
	BattleMap.Terrain.WATER: Color("1a2f4a"),
	BattleMap.Terrain.MOUNTAIN: Color("23212a"),
}

## Height is landscape, not terrain type (Ryan, 21 September): the map's relief field in
## steps of STEP, water sunk so its far bank shows. A crag sits at its ground's level with
## the spikes on top.
const STEP := 7.0
const WATER_DROP := -5.0

## The tile each terrain's top wears (art/terrain/<name>.png); sides wear rock.
const TILE := {
	BattleMap.Terrain.PLAIN: "dirt",
	BattleMap.Terrain.ROAD: "concrete",
	BattleMap.Terrain.ROUGH: "scrub",
	BattleMap.Terrain.RUINS: "rubble",
	BattleMap.Terrain.WATER: "water",
	BattleMap.Terrain.MOUNTAIN: "crag",
}

var field: Battlefield
var hex_px: float = 44.0        # the 2D view's HEX_SIZE, so the projection lands on its grid
var _ppu: float = 1.0           # screen pixels per model unit at zoom 1
var _sin: float = 1.0
var _cos: float = 1.0
var _origin := Vector2.ZERO     # where hex (0,0) sits in the map, in map pixels
var _view := Vector2.ZERO       # the screen area, in pixels
var _scroll := Vector2.ZERO     # the map view's scroll
var _zoom: float = 1.0
var _camera: Camera3D
var _units: Dictionary = {}     # unit id -> Node3D, the seat at the hex (set south a little); the pivot under it turns
var _pivots: Dictionary = {}    # unit id -> the pivot that turns to the facing; the model hangs off it centred by its bounds
var _shadows: Dictionary = {}   # unit id -> the ground disc under a flyer
var _rigs: Dictionary = {}      # unit id -> MechRig: the machine's joints, its idle acts and strikes (the same as the skirmish's)
var _scale: Dictionary = {}     # unit id -> the model's scale on the map (model units to world units)
var _heading: Dictionary = {}   # unit id -> the yaw the move is heading, radians, while a move plays
var _last_pos: Dictionary = {}  # unit id -> the seat's position last frame, for the speed
var _rest_yaw: Dictionary = {}  # unit id -> the facing it settles to at rest; eased, never snapped (Ryan, 4 October)
const REST_TURN_RATE := 4.0     # per second: a standing machine turns to its recorded facing this briskly
const SLIDE_RATE_SNAP := 12.0   # per second: a machine with no slide follows its heading round the curve, smoothly (Ryan, 4 October: was 30, a snap)
const SLIDE_RATE_FULL := 2.2    # per second: a slide of 1 lets the facing lag the path through a corner
const OVERSTEER_AHEAD := 0.4    # seconds along the path an oversteering nose looks ahead, so it turns in before the corner
const OVERSTEER_GAIN := 1.4     # how far past the heading ahead an oversteer of 1 swings the nose, into the corner
const OVERSTEER_MAX := 0.8      # radians the nose may lead the path by, at most
const OVERSTEER_RATE := 7.0     # per second: how briskly an oversteering nose chases its lead
var _heading_ahead: Dictionary = {}  # unit id -> the yaw the path heads OVERSTEER_AHEAD seconds on
var _base: Dictionary = {}      # unit id -> resting position, which the idle sway plays around
var _phase: Dictionary = {}     # unit id -> idle phase, so the team does not sway in step
var _columns: Dictionary = {}   # hex -> Node3D at the hex's ground: the marks hang off it
var _lift: Dictionary = {}      # hex -> how far above its grid cell the top sits on screen, in px
var _top: Dictionary = {}       # hex -> the tallest thing standing on it, in model units above the ground
var _materials: Dictionary = {} # tile name -> ShaderMaterial
var _time: float = 0.0


func setup(f: Battlefield, view_size: Vector2, origin: Vector2, hex_size: float, density: float = 1.0) -> void:
	field = f
	hex_px = hex_size
	_origin = origin
	_view = view_size   # the screen area in design pixels: the camera's frame, whatever the density
	_ppu = hex_px / HEX_WORLD
	_sin = sin(deg_to_rad(PITCH))
	_cos = cos(deg_to_rad(PITCH))
	size = Vector2i((view_size * density).round())   # the pixels rendered: the design's, or the glass's (the FINE MAP setting)
	own_world_3d = true
	transparent_bg = true
	render_target_update_mode = SubViewport.UPDATE_ALWAYS   # alive: sway and ripple every frame
	msaa_3d = Hud.msaa_3d()   # none on a phone: the Compatibility renderer leaks with it (Hud.msaa_3d)
	canvas_item_default_texture_filter = SubViewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_build_light()
	_build_ground()
	_build_structures()
	_build_camera()
	_build_units_layer()
	sync()


## Follow the map view: what it scrolls and zooms, the camera pans and zooms in the world.
func look(scroll: Vector2, zoom: float) -> void:
	_scroll = scroll
	_zoom = zoom
	_aim()


func _aim() -> void:
	if _camera == null:
		return
	_camera.size = _view.y / (_ppu * _zoom)
	var centre_px := (_view * 0.5 - _scroll) / _zoom   # the map pixel under the screen's middle
	var target := _world(centre_px - _origin)
	var back := Vector3(0.0, _sin, _cos)
	# Aimed before the map is in the tree too (setup runs first), so nothing global here:
	# both cameras sit directly under their viewport and local is global.
	_camera.look_at_from_position(target + back * CAMERA_DISTANCE, target, Vector3.UP)
	if _units_cam != null:
		_units_cam.size = _camera.size
		_units_cam.transform = _camera.transform


## The machines are the reconstruction's own and never go under the other world's
## painting (Ryan, 22 September: a machine over a flat hex showed a hole of dark ground
## around it). A second viewport shares this world and a camera that only sees the
## units' layer; the compositor draws its texture over both worlds.
var _units_vp: SubViewport = null
var _units_cam: Camera3D = null

func _build_units_layer() -> void:
	_units_vp = SubViewport.new()
	_units_vp.size = size
	_units_vp.transparent_bg = true
	_units_vp.own_world_3d = false
	_units_vp.world_3d = world_3d
	_units_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_units_vp.msaa_3d = msaa_3d
	add_child(_units_vp)
	_units_cam = Camera3D.new()
	_units_cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	_units_cam.keep_aspect = Camera3D.KEEP_HEIGHT
	_units_cam.near = 1.0
	_units_cam.far = 4000.0
	_units_cam.cull_mask = 1 << (UNITS_LAYER - 1)
	var e: Environment = _env.duplicate()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0, 0, 0, 0)
	_units_cam.environment = e
	_units_vp.add_child(_units_cam)
	_aim()


func get_units_texture() -> Texture2D:
	return _units_vp.get_texture() if _units_vp != null else null


func _to_units_layer(n: Node) -> void:
	var mask := 1 | (1 << (UNITS_LAYER - 1))
	if n is VisualInstance3D:
		(n as VisualInstance3D).layers |= mask   # keeps the sheen layer a glossy maker joined
	for c in n.find_children("*", "VisualInstance3D", true, false):
		(c as VisualInstance3D).layers |= mask


## One sun from the north-west, casting shadows, and a little ambient; the mechs and
## structures carry their own toon light on top.
func _build_light() -> void:
	var sun := DirectionalLight3D.new()
	sun.light_energy = 2.4
	sun.rotation_degrees = Vector3(-52.0, 35.0, 0.0)
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 4000.0
	sun.shadow_bias = 0.15
	sun.shadow_normal_bias = 1.5
	add_child(sun)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0, 0, 0, 0)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("aab4bc")
	e.ambient_light_energy = 1.0
	e.sky = MechView3D.chrome_sky()   # reflections only, so Kestrel's chrome shines here too
	e.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	# A little glow, so the lamps, engines and light strips bleed like a screen would.
	e.glow_enabled = true
	e.glow_intensity = 0.8
	e.glow_bloom = 0.08
	e.glow_hdr_threshold = 0.9
	env.environment = e
	_env = e
	add_child(env)


## World position of a map pixel offset from hex (0,0): x as is, depth stretched so the
## pitched camera compresses it back to the 2D grid.
func _world(px: Vector2, height: float = 0.0) -> Vector3:
	return Vector3(px.x / _ppu, height, px.y / (_ppu * _sin))


func _hex_world(h: Vector2i, height: float = 0.0) -> Vector3:
	return _world(Hex.to_pixel(h, hex_px), height)


## How far above its grid cell a hex's top sits on screen right now, in map pixels
## (negative when sunk). The overlays add it so routes, plaques and taps follow the terrain.
func lift(h: Vector2i) -> float:
	return _lift.get(h, 0.0)


## A hex's ground height in model units, from the map's relief (margin hexes included).
func _height_of(h: Vector2i) -> float:
	var e: int = field.map.elevation.get(h, 0)
	return WATER_DROP if e < 0 else float(e) * STEP


## Flat colour: unshaded so the palette stays exact, two-sided so winding never matters.
func _flat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.albedo_color = color
	return m


## Lit, matte, two-sided: the props.
func _lit(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 1.0
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


## A terrain tile as a lit material sampled by world position, or by the hex's UVs for a
## tile that covers one hex exactly (terrain.gdshader).
func _terrain_material(tile: String, ripple: float = 0.0, by_uv: bool = false) -> ShaderMaterial:
	if _materials.has(tile):
		return _materials[tile]
	var m := ShaderMaterial.new()
	m.shader = load("res://game/battle/terrain.gdshader")
	var path := "res://art/terrain/%s.png" % tile
	if ResourceLoader.exists(path):
		m.set_shader_parameter("tile", load(path))
	m.set_shader_parameter("tile_world", TILE_WORLD)
	m.set_shader_parameter("ripple", ripple)
	m.set_shader_parameter("lift", 1.35)
	m.set_shader_parameter("by_uv", 1.0 if by_uv else 0.0)
	_materials[tile] = m
	return m


## Which neighbours of a road hex are road too (the gate counts, so the road runs into
## it), as a bitmask over Hex.DIRECTIONS for road.gdshader.
func _road_links(h: Vector2i) -> int:
	var map := field.map
	var bits := 0
	for i in range(Hex.DIRECTIONS.size()):
		var n: Vector2i = h + Hex.DIRECTIONS[i]
		if map.terrain_of(n) == BattleMap.Terrain.ROAD or map.gate_hexes.has(n):
			bits |= 1 << i
	return bits


var _road_mat: ShaderMaterial = null

func _road_material() -> ShaderMaterial:
	if _road_mat == null:
		_road_mat = ShaderMaterial.new()
		_road_mat.shader = load("res://game/battle/road.gdshader")
		var path := "res://art/terrain/concrete.png"
		if ResourceLoader.exists(path):
			_road_mat.set_shader_parameter("tile", load(path))
		_road_mat.set_shader_parameter("tile_world", TILE_WORLD)
	return _road_mat


## A prop with the display's trace on it, baked into its column's band (`pos` and `rot`
## are in the column's space, as if it were a child). Three shapes make every prop: a box,
## a cylinder (a cone, a mesa slab, a trunk) and a ball. None is ever a Mesh resource: the
## renderer is asked for a box's and a ball's arrays once, and cylinders are made here.
func _box(col: Node3D, size: Vector3, material: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO, traced: bool = true) -> void:
	var xf := Transform3D(Basis.from_euler(rot), col.position + pos).scaled_local(size)
	var band: int = col.get_meta("band", 0)
	var hex = col.get_meta("prop_hex") if col.has_meta("prop_hex") else null
	_bake(_unit_geo("box"), xf, material, band, true, "", 1, null, hex)
	if traced:
		_bake(_unit_geo("box_lines"), xf, _trace_material("prop"), band, false, "prop", 1, null, hex)


func _ball(col: Node3D, radius: float, material: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO) -> void:
	var xf := Transform3D(Basis.from_euler(rot), col.position + pos).scaled_local(Vector3.ONE * radius)
	var band: int = col.get_meta("band", 0)
	var hex = col.get_meta("prop_hex") if col.has_meta("prop_hex") else null
	_bake(_unit_geo("ball"), xf, material, band, true, "", 1, null, hex)
	_bake(_unit_geo("ball_lines"), xf, _trace_material("prop"), band, false, "prop", 1, null, hex)


func _cyl(col: Node3D, top: float, bottom: float, height: float, segments: int, material: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO) -> void:
	var xf := Transform3D(Basis.from_euler(rot), col.position + pos)
	var band: int = col.get_meta("band", 0)
	var hex = col.get_meta("prop_hex") if col.has_meta("prop_hex") else null
	_bake(_cylinder_geo(top, bottom, height, segments), xf, material, band, true, "", 1, null, hex)
	_bake(_cylinder_lines(top, bottom, height, segments), xf, _trace_material("prop"), band, false, "prop", 1, null, hex)


# ---------------------------------------------------------------- baking

## Every static thing on the ground (rims, columns, grid lines, props, their traces, the
## gate and the walls) is welded with its world transform into one mesh per material per
## band of rows, instead of an instance each: the field was about 5,400 draw calls with
## every prop and trace its own object, and a phone pays per draw call more than per
## vertex. Bands keep the far end of the map culled under zoom. Geometry travels as packed
## arrays, never indexed, and is appended with the engine's own array ops: asking the
## renderer for a mesh's arrays is a round trip to its thread, so a shape is read back once
## (`_geo_of`) and the thousands of props are transforms of a few shapes. The marks and
## the units are live and stay nodes.
class Batch:
	var material: Material
	var shadow: bool
	var layers: int
	var kind: String            # "" for geometry, else a trace kind (set_trace_mode)
	var lines: bool
	var colours: bool
	var hex = null              # a Vector2i when the batch is one hex's props, hidden while a machine stands there
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var uv := PackedVector2Array()
	var c := PackedColorArray()

var _batches: Dictionary = {}   # key -> Batch, until _flush_batches
var _geo_cache: Dictionary = {} # mesh rid/surface -> geometry, the mesh kept alive with it
var _baked_models: Array = []   # the model instances the structures were baked from, kept: freeing them mid-build upsets the renderer
var _shapes: Dictionary = {}    # "box", "box_lines", "ball", "ball_lines" -> geometry


func _band(h: Vector2i) -> int:
	return floori(float(h.y) / BAND_ROWS)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for m in _baked_models:
			if is_instance_valid(m):
				m.free()


## A mesh surface as packed arrays: {"v", "n", "uv", "c" as present, "lines"}. Indexed
## surfaces are expanded, so every batch is a plain triangle or segment list.
func _geo_of(mesh: Mesh, surface: int = 0) -> Dictionary:
	var key := "%d/%d" % [mesh.get_rid().get_id(), surface]
	if _geo_cache.has(key):
		return _geo_cache[key]
	var out := {"keep": mesh}
	var arrays := mesh.surface_get_arrays(surface)
	if not arrays.is_empty():
		out["lines"] = mesh is ArrayMesh and (mesh as ArrayMesh).surface_get_primitive_type(surface) == Mesh.PRIMITIVE_LINES
		var idx = arrays[Mesh.ARRAY_INDEX]
		for pair in [[Mesh.ARRAY_VERTEX, "v"], [Mesh.ARRAY_NORMAL, "n"], [Mesh.ARRAY_TEX_UV, "uv"], [Mesh.ARRAY_COLOR, "c"]]:
			var src = arrays[pair[0]]
			if src == null:
				continue
			if idx != null and idx.size() > 0:
				var dst = src.duplicate()
				dst.clear()
				for i in idx:
					dst.append(src[i])
				out[pair[1]] = dst
			else:
				out[pair[1]] = src
	_geo_cache[key] = out
	return out


## The unit shapes: a box of side 1, a ball of radius 1, and their traces.
func _unit_geo(name: String) -> Dictionary:
	if _shapes.has(name):
		return _shapes[name]
	var geo: Dictionary
	match name:
		"box":
			var u := BoxMesh.new()
			u.size = Vector3.ONE
			geo = _geo_of(u)
		"box_lines":
			var u := BoxMesh.new()
			u.size = Vector3.ONE
			geo = {"v": TraceLines.edge_points(u), "lines": true, "keep": u}
		"ball":
			geo = _geo_of(_unit_ball())
		"ball_lines":
			var u := _unit_ball()
			geo = {"v": TraceLines.edge_points(u), "lines": true, "keep": u}
	_shapes[name] = geo
	return geo


## The boulders: six around, three rings, a little squat (height 1.6 of the radius).
func _unit_ball() -> SphereMesh:
	var u := SphereMesh.new()
	u.radius = 1.0
	u.height = 1.6
	u.radial_segments = 6
	u.rings = 3
	return u


## A cylinder or cone with flat facets, as CylinderMesh lays it out (x = r sin a,
## z = r cos a, y centred on the height), with its caps.
func _cylinder_geo(top: float, bottom: float, height: float, segments: int) -> Dictionary:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var half := height * 0.5
	for i in range(segments):
		var a0 := TAU * float(i) / segments
		var a1 := TAU * float(i + 1) / segments
		var t0 := Vector3(sin(a0) * top, half, cos(a0) * top)
		var t1 := Vector3(sin(a1) * top, half, cos(a1) * top)
		var b0 := Vector3(sin(a0) * bottom, -half, cos(a0) * bottom)
		var b1 := Vector3(sin(a1) * bottom, -half, cos(a1) * bottom)
		var am := (a0 + a1) * 0.5
		var side := Vector3(sin(am) * height, bottom - top, cos(am) * height).normalized()
		for p in [b0, b1, t1, b0, t1, t0]:
			v.append(p)
			n.append(side)
		if top > 0.01:
			for p in [Vector3(0, half, 0), t0, t1]:
				v.append(p)
				n.append(Vector3.UP)
		for p in [Vector3(0, -half, 0), b1, b0]:
			v.append(p)
			n.append(Vector3.DOWN)
	return {"v": v, "n": n}


## Its trace: the two rims and the verticals between them.
func _cylinder_lines(top: float, bottom: float, height: float, segments: int) -> Dictionary:
	var v := PackedVector3Array()
	var half := height * 0.5
	for i in range(segments):
		var a0 := TAU * float(i) / segments
		var a1 := TAU * float(i + 1) / segments
		var t0 := Vector3(sin(a0) * top, half, cos(a0) * top)
		var b0 := Vector3(sin(a0) * bottom, -half, cos(a0) * bottom)
		var b1 := Vector3(sin(a1) * bottom, -half, cos(a1) * bottom)
		if top > 0.01:
			v.append(t0)
			v.append(Vector3(sin(a1) * top, half, cos(a1) * top))
		v.append(b0)
		v.append(b1)
		v.append(b0)
		v.append(t0)
	return {"v": v, "lines": true}


## `key_of` names the batch when the material to draw with is not the one to group by: a
## model's surfaces each wear their own copy of a toon'd material, but the copies of one
## source are alike, so they group by the source and draw with the first copy seen.
func _bake(geo: Dictionary, xf: Transform3D, material: Material, band: int, shadow: bool, kind: String = "", layers: int = 1, key_of: Object = null, hex = null) -> void:
	if not geo.has("v"):
		return
	var lines: bool = geo.get("lines", false)
	var group := key_of if key_of != null else material
	# A prop on ground a machine can stand on bakes with its own hex, so the hex's props are
	# a few meshes of their own and can hide while a machine stands there (Ryan, 29
	# September: rubble and buildings came up through the machines' roofs and feet). The
	# rest of the field stays in the big batches.
	var key := "%d/%d/%s/%d/%s" % [group.get_instance_id(), band, kind, layers, str(hex) if hex != null else ""]
	var b: Batch = _batches.get(key, null)
	if b == null:
		b = Batch.new()
		b.material = material
		b.shadow = shadow
		b.kind = kind
		b.layers = layers
		b.lines = lines
		b.colours = geo.has("c")
		b.hex = hex
		_batches[key] = b
	var src: PackedVector3Array = geo["v"]
	b.v.append_array(xf * src)
	if lines:
		return
	if geo.has("n"):
		# Rotation only: the props' scales are along their own axes or uniform, so the
		# normals need no inverse transpose.
		b.n.append_array(Transform3D(xf.basis.orthonormalized(), Vector3.ZERO) * (geo["n"] as PackedVector3Array))
	else:
		b.n.append_array(_filled3(src.size(), Vector3.UP))
	if geo.has("uv"):
		b.uv.append_array(geo["uv"])
	else:
		var z := PackedVector2Array()
		z.resize(src.size())
		b.uv.append_array(z)
	if b.colours:
		if geo.has("c"):
			b.c.append_array(geo["c"])
		else:
			var w := PackedColorArray()
			w.resize(src.size())
			w.fill(Color.WHITE)
			b.c.append_array(w)


func _filled3(count: int, value: Vector3) -> PackedVector3Array:
	var out := PackedVector3Array()
	out.resize(count)
	out.fill(value)
	return out


func _flush_batches() -> void:
	for b in _batches.values():
		if b.v.is_empty():
			continue
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = b.v
		if not b.lines:
			arrays[Mesh.ARRAY_NORMAL] = b.n
			arrays[Mesh.ARRAY_TEX_UV] = b.uv
			if b.colours:
				arrays[Mesh.ARRAY_COLOR] = b.c
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES if b.lines else Mesh.PRIMITIVE_TRIANGLES, arrays)
		var mi := MeshInstance3D.new()
		mi.mesh = mesh
		mi.material_override = b.material
		mi.layers = b.layers
		if not b.shadow:
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if not b.kind.is_empty():
			mi.set_meta("is_trace", true)
			mi.set_meta("kind", b.kind)
			mi.visible = _trace_mode != "off"
			_trace_nodes.append(mi)
		if b.hex != null:
			mi.set_meta("prop_hex", b.hex)   # so set_trace_mode can leave a hidden hex's traces hidden
			if not _prop_meshes.has(b.hex):
				_prop_meshes[b.hex] = []
			(_prop_meshes[b.hex] as Array).append(mi)
		add_child(mi)
	_batches.clear()


var _prop_meshes: Dictionary = {}   # hex -> the meshes of its props, hidden while a machine stands there
var _props_hidden: Dictionary = {}  # hex -> true while hidden

## Hide the props of every hex a grounded machine stands on (or is crossing), and show the
## rest again. A flyer hides nothing: it rides over what stands there.
func _hide_props_under(occupied: Dictionary) -> void:
	for h in _prop_meshes.keys():
		var hide: bool = occupied.has(h)
		if _props_hidden.get(h, false) == hide:
			continue
		_props_hidden[h] = hide
		for mi in _prop_meshes[h]:
			var m: MeshInstance3D = mi
			if hide:
				m.visible = false
			else:
				m.visible = not m.has_meta("is_trace") or _trace_mode != "off"


## A static model (the gate, a wall segment) baked the same way at its current transform,
## its creases into the asset traces; the node never joins the tree, and one instance can
## be baked at many places. Grouped by the source material of each surface (see `_bake`),
## so a dozen wall segments draw as a few meshes.
func _bake_model(node: Node3D, band: int) -> void:
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = child
		if mi.mesh == null or mi.has_meta("is_trace") or not mi.visible:
			continue
		var xf := node.transform * _relative(mi, node)
		for sfc in range(mi.mesh.get_surface_count()):
			var mat := mi.get_active_material(sfc)
			if mat == null:
				continue
			var src := mi.mesh.surface_get_material(sfc)
			_bake(_geo_of(mi.mesh, sfc), xf, mat, band, true, "", mi.layers, src if src != null else mat)
		var pts := TraceLines.edge_points(mi.mesh)
		if not pts.is_empty():
			_bake({"v": pts, "lines": true}, xf, _trace_material("asset"), band, false, "asset")


## The display traces a thing's edges in light (TraceLines), lit by the scan bar as it
## passes. RIFTGATE_INK=dark starts them as black ink.
var _trace_nodes: Array = []
var _trace_mode := TraceLines.mode()
var _light_mat: ShaderMaterial = null
var _ink_line_mat: StandardMaterial3D = null

func _trace(mi: MeshInstance3D, kind: String = "prop") -> void:
	var added := TraceLines.attach(mi, _trace_material(kind))
	for em in added:
		em.visible = _trace_mode != "off"
		em.set_meta("kind", kind)
	_trace_nodes.append_array(added)


var _pulse_mat: ShaderMaterial = null

func _trace_material(kind: String) -> Material:
	if _trace_mode == "pulse":
		if _pulse_mat == null:
			_pulse_mat = TraceLines.pulse_material(Palette.HUD)
		return _pulse_mat
	if TraceLines.inked(_trace_mode, kind):
		if _ink_line_mat == null:
			_ink_line_mat = TraceLines.ink_material()
		return _ink_line_mat
	if _light_mat == null:
		_light_mat = TraceLines.light_material(Palette.HUD)
	return _light_mat


# ---------------------------------------------------------------- live tuning

## "light", "ink" or "off": every trace on the map swaps at once.
func set_trace_mode(mode: String) -> void:
	_trace_mode = mode
	for em in _trace_nodes:
		if is_instance_valid(em):
			# A prop's traces stay hidden while a machine stands on its hex (audit, 29
			# September: this used to show a hidden hex's outlines again, through the machine).
			var under_machine: bool = em.has_meta("prop_hex") and _props_hidden.get(em.get_meta("prop_hex"), false)
			em.visible = mode != "off" and not under_machine
			if mode != "off":
				em.material_override = _trace_material(str(em.get_meta("kind", "prop")))



func set_trace_gain(v: float) -> void:
	for m in [_light_mat, _pulse_mat]:
		if m != null:
			m.set_shader_parameter("gain", v)


## Where the scan band is, as a map-pixel y: the traces and the grid under it brighten.
func set_sweep(map_y: float) -> void:
	var p := (map_y - _origin.y) / _ppu   # projected depth: what the shader computes along screen-down
	for m in [_light_mat, _grid_mat, _pulse_mat]:
		if m != null:
			m.set_shader_parameter("sweep_p", p)
			m.set_shader_parameter("screen_down", Vector3(0.0, -_cos, _sin))


# ---------------------------------------------------------------- the movement phase

var _anim_px: Dictionary = {}   # unit id -> map pixel while a move plays, in place of its hex

## While a phase plays, a unit is where its animation says, not on its hex. The heading is
## where the move is going; the facing follows it through the cornering module (_corner),
## at once for most machines and lagging for one with a slide.
func set_anim(uid: int, px: Vector2, heading: Vector2, ahead: Vector2 = Vector2.ZERO) -> void:
	_anim_px[uid] = px
	if heading.length_squared() > 0.001:
		_heading[uid] = atan2(-heading.x, -heading.y)
	if ahead.length_squared() > 0.001:
		_heading_ahead[uid] = atan2(-ahead.x, -ahead.y)


func clear_anim(uid: int) -> void:
	_anim_px.erase(uid)
	_heading.erase(uid)
	_last_pos.erase(uid)
	_heading_ahead.erase(uid)


## The cornering module (the joints row, 2 October): one piece for the Dingo's drift and the
## banking of flyers and hovercraft. The body's facing and its path are separate: the facing
## eases toward the heading at a rate the machine's `slide` sets (0 snaps, 1 lags), and the
## rig is told the speed, the bearing of the travel against the facing (the casters point
## along it) and the turn (the steering and the bank). An oversteering machine (Ryan, 5
## October: the Dingo and the hovercraft, which lagged where they should drift; `oversteer`)
## aims its nose past where the path will be heading a moment on, so it turns in before the
## corner, as a drift is entered, swings through it with its tail stepping out, and comes
## back out of it as the corner ends; reading the path ahead rather than how fast it turns
## keeps it smooth across the corner's spans (Ryan, 5 October: it jerked span by span). A helicopter-style
## machine (Ryan, 3 October; `strafe`) faces where it will end up facing instead, turning
## there first and then translating, so its travel can be sideways or backward and its rig
## tilts it that way. A standing machine is driven at zero, so its gait settles.
func _corner(uid: int, rig: MechRig, delta: float) -> void:
	if not _pivots.has(uid) or delta <= 0.0:
		return
	var pivot: Node3D = _pivots[uid]
	var k: float = float(_scale.get(uid, 1.0))
	if not _anim_px.has(uid) or not _heading.has(uid):
		# At rest: settle to the facing the simulation records, eased, so a move that ended on
		# a lagging facing (the Dingo's drift) never snaps round.
		var turn := 0.0
		if _rest_yaw.has(uid):
			var diff := wrapf(float(_rest_yaw[uid]) - pivot.rotation.y, -PI, PI)
			var step := diff * (1.0 - exp(-delta * REST_TURN_RATE))
			pivot.rotation.y += step
			turn = step / delta
		rig.drive(0.0, 0.0, turn, delta)
		return
	var node: Node3D = _units[uid]
	var pos := node.position
	var speed := 0.0
	if _last_pos.has(uid):
		speed = (pos - (_last_pos[uid] as Vector3)).length() / delta / maxf(0.001, k)
	_last_pos[uid] = pos
	var slide := clampf(float(rig.move.get("slide", 0.0)), 0.0, 1.0)
	var strafe := clampf(float(rig.move.get("strafe", 0.0)), 0.0, 1.0)
	var over := clampf(float(rig.move.get("oversteer", 0.0)), 0.0, 1.0)
	var rate := lerpf(SLIDE_RATE_SNAP, SLIDE_RATE_FULL, slide)
	var heading: float = _heading[uid]
	var want := heading
	if over > 0.0:
		var ahead := float(_heading_ahead.get(uid, heading))
		want = heading + oversteer_lead(wrapf(ahead - heading, -PI, PI), over)
		rate = lerpf(rate, OVERSTEER_RATE, over)
	if strafe > 0.0:
		var u := field.unit_by_id(uid)
		if u != null:
			want = facing_target(heading, facing_yaw(u.facing), strafe)
			rate = lerpf(rate, STRAFE_TURN_RATE, strafe)
	var facing := pivot.rotation.y
	var diff := wrapf(want - facing, -PI, PI)
	var step := diff * (1.0 - exp(-delta * rate))
	pivot.rotation.y = facing + step
	rig.drive(speed, wrapf(heading - pivot.rotation.y, -PI, PI), step / delta, delta)


const STRAFE_TURN_RATE := 6.0   # per second: a helicopter yaws to where it will face in the first moment of a move, then translates


## How far an oversteering nose leads its path, radians: past the turn the path makes over
## the next OVERSTEER_AHEAD seconds (`turn_ahead`, radians), up to OVERSTEER_MAX.
static func oversteer_lead(turn_ahead: float, oversteer: float) -> float:
	return clampf(turn_ahead * OVERSTEER_GAIN * oversteer, -OVERSTEER_MAX, OVERSTEER_MAX)


## The motion numbers in a machine's rig sidecar (`move`: slide, bank, strafe, tilt, accel,
## heft), for the map view's curve; empty for a unit with no rig.
func motion_of(uid: int) -> Dictionary:
	return (_rigs[uid] as MechRig).move if _rigs.has(uid) else {}


## The pivot's yaw for one of the six facings: the model faces -Z (north) at rest and
## screen-down is +Z, so the facing turns the other way from the pixel direction.
static func facing_yaw(facing: int) -> float:
	var d: Vector2 = Hex.to_pixel(Hex.DIRECTIONS[facing], 1.0).normalized()
	return atan2(-d.x, -d.y)


## Where a moving machine turns its nose: its heading, or, by its `strafe`, the facing it
## will end the move with, so it travels sideways or backward holding that.
static func facing_target(heading: float, final_facing: float, strafe: float) -> float:
	return lerp_angle(heading, final_facing, clampf(strafe, 0.0, 1.0))


var _env: Environment = null

func set_glow(v: float) -> void:
	if _env != null:
		_env.glow_intensity = v
		_env.glow_enabled = v > 0.01


func set_grid(gain: float) -> void:
	_grid_material().set_shader_parameter("gain", gain)


var _ink_mat: StandardMaterial3D = null

## The outline hull's material: light, not ink (Ryan, 21 September), the HUD colour with a
## little emission so the glow pass catches it, like the grid. RIFTGATE_INK=dark for the
## old black line, to compare.
func _ink(grow: float = 1.0) -> StandardMaterial3D:
	if _ink_mat == null:
		_ink_mat = StandardMaterial3D.new()
		_ink_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_ink_mat.cull_mode = BaseMaterial3D.CULL_FRONT
		_ink_mat.grow = true
		_ink_mat.grow_amount = grow
		if OS.get_environment("RIFTGATE_INK") == "dark":
			_ink_mat.albedo_color = Palette.BG
		else:
			_ink_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			_ink_mat.albedo_color = Color(Palette.HUD, 0.5)
			_ink_mat.emission_enabled = true
			_ink_mat.emission = Palette.HUD
			_ink_mat.emission_energy_multiplier = 0.9
	return _ink_mat


## Marks on the ground, in the scene so they sit under the machines (Ryan, 22 September:
## a tint or a line over a machine reads as on top of it; the machines and the wall hide
## these by standing on them, like the grid). Each mark is {hex, fill: Color, edges:
## Array[int], line: Color}: a flat tinted hex on the column and ribbons along the given
## edges, collapsing with the column. Rebuilt only when the set changes; the colours
## follow every call, so a mark can breathe.
var _marks: Dictionary = {}   # hex -> [fill MeshInstance3D or null, line MeshInstance3D or null]
var _marks_key := ""
const EDGE_W := 1.0   # the ribbon's width in map pixels: a hairline, the tint does the work (Ryan, 22 September)

func set_marks(list: Array) -> void:
	var key := ""
	for m in list:
		key += "%s%s;" % [str(m["hex"]), str(m["edges"])]
	if key != _marks_key:
		_marks_key = key
		for pair in _marks.values():
			for mi in pair:
				if mi != null:
					mi.queue_free()
		_marks.clear()
		for m in list:
			var h: Vector2i = m["hex"]
			if not _columns.has(h):
				continue
			var y := _height_of(h) + 0.45
			var fill: MeshInstance3D = null
			if (m["fill"] as Color).a > 0.0:
				fill = _flat_mark(_mark_mesh(y), _columns[h])
			var line: MeshInstance3D = null
			if not (m["edges"] as Array).is_empty():
				line = _flat_mark(_edge_mesh(y + 0.05, m["edges"]), _columns[h])
			_marks[h] = [fill, line]
	for m in list:
		var pair: Array = _marks.get(m["hex"], [])
		if pair.is_empty():
			continue
		if pair[0] != null:
			(pair[0].material_override as StandardMaterial3D).albedo_color = _scene_alpha(m["fill"])
		if pair[1] != null:
			(pair[1].material_override as StandardMaterial3D).albedo_color = _scene_alpha(m["line"])


## The scene blends in linear light, so a thin tint of a bright colour over dark ground
## comes out far stronger than the same alpha drawn flat on the screen. Marks are asked
## for in screen terms; this makes them land as asked.
func _scene_alpha(c: Color) -> Color:
	return Color(c.r, c.g, c.b, pow(c.a, 2.2))


func _flat_mark(mesh: Mesh, col: Node3D) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED   # flat marks: winding must never hide one
	mat.render_priority = 1
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	col.add_child(mi)
	return mi


func _mark_mesh(y: float) -> ArrayMesh:
	var corners := Hex.corners(Vector2.ZERO, hex_px - 3.0)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var c := _world(Vector2.ZERO, y)
	for i in range(corners.size()):
		st.add_vertex(c)
		st.add_vertex(_world(corners[(i + 1) % corners.size()], y))
		st.add_vertex(_world(corners[i], y))
	return st.commit()


## Ribbons along the given edges (corner i to i+1), just inside the hex's edge.
func _edge_mesh(y: float, edges: Array) -> ArrayMesh:
	var outer := Hex.corners(Vector2.ZERO, hex_px - 1.0)
	var inner := Hex.corners(Vector2.ZERO, hex_px - 1.0 - EDGE_W * 1.15)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for e in edges:
		var i: int = int(e)
		var j := (i + 1) % 6
		var a := _world(outer[i], y)
		var b := _world(outer[j], y)
		var c := _world(inner[j], y)
		var d := _world(inner[i], y)
		st.add_vertex(a); st.add_vertex(b); st.add_vertex(c)
		st.add_vertex(a); st.add_vertex(c); st.add_vertex(d)
	return st.commit()


## The hex outline as a ribbon just inside the column's edge at height `y`, for the glowing
## grid. Geometry, not GL lines: a line primitive is one device pixel whatever the screen,
## and on the phone (Ryan, 25 September: faint at rest on native Android) that is a
## hairline on a small dense screen, thinner and dimmer still on the Compatibility
## renderer. A ribbon of GRID_W map pixels scales with the hex, the zoom and the screen.
const GRID_W := 1.5

func _grid_geo(y: float) -> Dictionary:
	var outer := Hex.corners(Vector2.ZERO, hex_px - 0.75)
	var inner := Hex.corners(Vector2.ZERO, hex_px - 0.75 - GRID_W * 1.15)   # 1.15: a corner's inset is measured along the edge's normal, not the radius
	var v := PackedVector3Array()
	for i in range(outer.size()):
		var j := (i + 1) % outer.size()
		var a := _world(outer[i], y)
		var b := _world(outer[j], y)
		var c := _world(inner[j], y)
		var d := _world(inner[i], y)
		v.append(a); v.append(b); v.append(c)
		v.append(a); v.append(c); v.append(d)
	return {"v": v}


var _grid_mat: ShaderMaterial = null

## The display's light: the same trace shader as the edges, so the scan bar lights the grid
## as it passes; a little dimmer than the traces.
func _grid_material() -> ShaderMaterial:
	if _grid_mat == null:
		_grid_mat = ShaderMaterial.new()
		_grid_mat.shader = load("res://game/battle/trace.gdshader")
		_grid_mat.set_shader_parameter("color", Palette.HUD)
		_grid_mat.set_shader_parameter("gain", GRID_GAIN_PHONE if OS.has_feature("mobile") else GRID_GAIN)
	return _grid_mat


## The grid's resting brightness (the tuner's GRID knob). The phone needs far more than
## the Mac: the ribbons drawn at the Mac's gain were still dim on the phone at any zoom
## (Ryan, 28 September; the Compatibility renderer adds no bloom halo to a line, and the
## glass is small), so a phone rests hotter.
const GRID_GAIN := 0.7
const GRID_GAIN_PHONE := 1.5


## One hex of flat ground as a polygon: the dark rim under the columns, for the grid gaps.
func _hex_mesh(inset: float) -> ArrayMesh:
	var corners := Hex.corners(Vector2.ZERO, hex_px - inset)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(1, corners.size() - 1):
		for v in [corners[0], corners[i + 1], corners[i]]:
			st.set_normal(Vector3.UP)
			st.add_vertex(_world(v))
	return st.commit()


## A hex column as two pieces of geometry: the top at `h`, and its sides from the ground
## to `h`, only on the edges in `sides` (an edge shared with a neighbour of the same height
## has no wall: two water hexes are one pool, two gravel hexes one field). Normals are
## explicit, outward for a raised column and inward for a sunk one, since it is the sunk
## hex's far bank that faces the camera. `colour` rides on the top's vertices for a shader
## that wants per-hex data (the road's links).
func _column_geo(h: float, sides: Array, colour: Color = Color.WHITE) -> Array:
	var corners := Hex.corners(Vector2.ZERO, hex_px - 0.75)
	var top: Array[Vector3] = []
	for c in corners:
		top.append(_world(c, h))
	var tv := PackedVector3Array()
	var tuv := PackedVector2Array()
	for i in range(1, corners.size() - 1):
		for j in [0, i + 1, i]:
			tv.append(top[j])
			tuv.append(corners[j] / (hex_px * 2.0) + Vector2(0.5, 0.5))   # the hex inscribed in the tile
	var tc := PackedColorArray()
	tc.resize(tv.size())
	tc.fill(colour)
	var top_geo := {"v": tv, "n": _filled3(tv.size(), Vector3.UP), "uv": tuv, "c": tc}
	var sv := PackedVector3Array()
	var sn := PackedVector3Array()
	if absf(h) >= 0.01 and sides.has(true):
		var n := corners.size()
		for i in range(n):
			if not sides[i]:
				continue
			var a := top[i]
			var b := top[(i + 1) % n]
			var a0 := Vector3(a.x, 0.0, a.z)
			var b0 := Vector3(b.x, 0.0, b.z)
			var mid := (a0 + b0) * 0.5
			var nrm := Vector3(mid.x, 0.0, mid.z).normalized() * (1.0 if h > 0.0 else -1.0)
			for v in [a0, b0, b, a0, b, a]:
				sv.append(v)
				sn.append(nrm)
	return [top_geo, {"v": sv, "n": sn} if not sv.is_empty() else {}]


func _build_ground() -> void:
	var rim := _geo_of(_hex_mesh(0.0))
	var rim_mat := _flat(Color(Palette.HUD, 0.10).blend(Palette.BG))
	var rock := _terrain_material("rock")
	var map := field.map
	var rng := RandomNumberGenerator.new()
	var corners := Hex.corners(Vector2.ZERO, hex_px)
	var hexes: Array = map.all_hexes().duplicate()
	hexes.append_array(map.margin.keys())
	for h in hexes:
		var t: int = map.terrain_of(h)
		var in_field: bool = map.has(h)
		var at := _hex_world(h)
		var hgt := _height_of(h)
		# Which edges need a wall: those facing a neighbour at another height, or none.
		var sides: Array = []
		var here := Hex.to_pixel(h, hex_px)
		for i in range(corners.size()):
			var mid: Vector2 = (corners[i] + corners[(i + 1) % corners.size()]) * 0.5
			var across := here + mid * 2.0
			var other: float = -999.0
			for nb in Hex.neighbors(h):
				if (map.has(nb) or map.margin.has(nb)) and Hex.to_pixel(nb, hex_px).distance_to(across) < hex_px * 0.5:
					other = _height_of(nb)
			sides.append(absf(other - hgt) > 0.01)
		var band := _band(h)
		_bake(rim, Transform3D(Basis.IDENTITY, at + Vector3(0, minf(0.0, hgt) - 0.2, 0)), rim_mat, band, false)
		# One node at ground level per hex: the marks hang off it.
		var col := Node3D.new()
		col.position = at
		col.set_meta("band", band)
		if in_field and t != BattleMap.Terrain.MOUNTAIN:
			col.set_meta("prop_hex", h)   # its props bake by hex, to hide under a standing machine
		add_child(col)
		_columns[h] = col
		# A crag keeps the ground it stands on (crag-water, crag-ruin, crag-field: the
		# flavour of the tile shows through under the rock).
		var ground_t: int = map.crag_base.get(h, t) if t == BattleMap.Terrain.MOUNTAIN else t
		var at_xf := Transform3D(Basis.IDENTITY, at)
		var column: Array
		if ground_t == BattleMap.Terrain.ROAD:
			# The road's links and its seed ride in the vertex colour (road.gdshader), so
			# road hexes bake like any other and need nothing per instance.
			var seed_f := fmod(float(h.x * 131 + h.y * 7919) * 0.0137, 1.0)
			column = _column_geo(hgt, sides, Color(float(_road_links(h)) / 255.0, absf(seed_f), 0.0, 1.0))
			_bake(column[0], at_xf, _road_material(), band, true)
		else:
			column = _column_geo(hgt, sides)
			_bake(column[0], at_xf, _terrain_material(TILE[ground_t], 1.0 if ground_t == BattleMap.Terrain.WATER else 0.0), band, true)
		_bake(column[1], at_xf, rock, band, true)
		if in_field and not (map.gate_hexes.has(h) or map.wall_hexes.has(h)):
			# The grid is the display's own light, drawn on the ground in the scene so a
			# raised hex hides the lines behind it; the wall and the machines hide it the
			# same way, by standing on it.
			_bake(_grid_geo(hgt + 0.35), at_xf, _grid_material(), band, false)
		rng.seed = h.x * 131 + h.y * 7919
		if map.city.has(h):
			_city_block(col, hgt, rng)
			continue
		match t:
			BattleMap.Terrain.MOUNTAIN:
				_top[h] = hgt + _crag(col, ground_t, hgt, rng)
			BattleMap.Terrain.RUINS:
				# Broken blocks and a couple of standing wall stubs.
				var rubble := _terrain_material("rubble")
				for k in range(5):
					var size := Vector3(rng.randf_range(8, 16), rng.randf_range(5, 18), rng.randf_range(6, 13))
					_box(col, size, rubble, Vector3(rng.randf_range(-18, 18), hgt + size.y * 0.5, rng.randf_range(-13, 13)), Vector3(0.0, rng.randf_range(0, TAU), 0.0))
				for k in range(2):
					var stub := Vector3(rng.randf_range(14, 24), rng.randf_range(20, 32), 3.5)
					_box(col, stub, rubble, Vector3(rng.randf_range(-14, 14), hgt + stub.y * 0.5, rng.randf_range(-10, 10)), Vector3(0.0, rng.randf_range(0, TAU), 0.0))
			BattleMap.Terrain.ROUGH:
				# Wasteland: dead trees and boulders, the parallel of the other world's forest.
				_top[h] = hgt + 40.0
				for k in range(rng.randi_range(2, 4)):
					_dead_tree(col, Vector3(rng.randf_range(-18, 18), hgt, rng.randf_range(-14, 14)), rng)
				for k in range(rng.randi_range(1, 3)):
					var radius := rng.randf_range(5.0, 9.0)
					_ball(col, radius, rock, Vector3(rng.randf_range(-16, 16), hgt + radius * 0.6, rng.randf_range(-12, 12)), Vector3(0.0, rng.randf_range(0, TAU), 0.0))
	_flush_batches()


## The blocking crag on a tile, in the ground's own idiom: rock spikes on dirt and water,
## broken towers on ruins, mesas on wasteland (Ryan, 21 September). All overflow the tile's
## height so they read as things you fly over.
func _crag(col: Node3D, ground_t: int, hgt: float, rng: RandomNumberGenerator) -> float:
	## Returns how tall the crag stands above the ground, so a flyer clears it and no more.
	match ground_t:
		BattleMap.Terrain.RUINS:
			# Dead skyscrapers: tall thin shells stepping down as they rise, a few dim
			# windows still lit on the tallest, far above anything else on the field.
			var rubble := _terrain_material("rubble")
			for k in range(4):
				var w := rng.randf_range(8.0, 12.0)
				var tall := rng.randf_range(70.0, 96.0) if k == 0 else rng.randf_range(34.0, 62.0)
				var ox := 0.0 if k == 0 else rng.randf_range(-17.0, 17.0)
				var oz := 0.0 if k == 0 else rng.randf_range(-13.0, 13.0)
				for step in range(3):
					var frac := 1.0 - 0.22 * step
					var size := Vector3(w * frac, tall / 3.0, w * frac * rng.randf_range(0.7, 1.0))
					_box(col, size, rubble, Vector3(ox + rng.randf_range(-1.0, 1.0), hgt + tall / 6.0 + step * tall / 3.0, oz + rng.randf_range(-1.0, 1.0)))
				if k == 0:
					var wm := _window_material("dim", Color(0.9, 0.7, 0.35), 1.2)
					for wz in [tall * 0.35, tall * 0.55]:
						_box(col, Vector3(w * 0.7, 2.0, 0.6), wm, Vector3(ox, hgt + wz, oz - w * 0.5 * rng.randf_range(0.8, 1.0)), Vector3.ZERO, false)
		BattleMap.Terrain.ROUGH:
			# Mesas: flat-topped blocks stacked and offset, a badland.
			var rock := _terrain_material("rock")
			for k in range(3):
				var tall := rng.randf_range(30.0, 46.0) if k == 0 else rng.randf_range(18.0, 30.0)
				var ox := 0.0 if k == 0 else rng.randf_range(-16.0, 16.0)
				var oz := 0.0 if k == 0 else rng.randf_range(-12.0, 12.0)
				for step in range(2):
					var top := rng.randf_range(10.0, 15.0) * (0.8 if step == 1 else 1.0)
					var slab_h := tall * (0.6 if step == 0 else 0.4)
					_cyl(col, top, top * 1.15, slab_h, 6, rock, Vector3(ox, hgt + slab_h * 0.5 + (tall * 0.6 if step == 1 else 0.0), oz), Vector3(0.0, rng.randf_range(0, TAU), 0.0))
		_:
			# Rock spikes, leaning, filling the tile.
			var rock_dark := _terrain_material("rock")
			for k in range(6):
				var foot := rng.randf_range(9.0, 14.0)
				var spike_h := rng.randf_range(40.0, 56.0) if k == 0 else rng.randf_range(22.0, 40.0)
				var a := k * TAU / 5.0 + rng.randf_range(-0.4, 0.4)
				var dist := 0.0 if k == 0 else rng.randf_range(14.0, 22.0)
				_cyl(col, 0.8, foot, spike_h, 4, rock_dark, Vector3(cos(a) * dist, hgt + spike_h * 0.5 - 1.0, sin(a) * dist),
					Vector3(rng.randf_range(-0.18, 0.18), rng.randf_range(0, TAU), rng.randf_range(-0.18, 0.18)))
	match ground_t:
		BattleMap.Terrain.RUINS:
			return 96.0
		BattleMap.Terrain.ROUGH:
			return 46.0
		_:
			return 56.0


## A hex of the city behind the wall: intact blocks in the Arsenal's grey, lit windows in
## rows, one or two taller. What the gate protects, seen past the wall.
func _city_block(col: Node3D, hgt: float, rng: RandomNumberGenerator) -> void:
	var skin := _terrain_material("rubble")
	var win := _window_material("lit", Color(1.0, 0.85, 0.5), 1.3)
	for k in range(rng.randi_range(2, 4)):
		var w := rng.randf_range(12.0, 20.0)
		var tall := rng.randf_range(40.0, 80.0) if k == 0 else rng.randf_range(18.0, 44.0)
		var ox := 0.0 if k == 0 else rng.randf_range(-18.0, 18.0)
		var oz := 0.0 if k == 0 else rng.randf_range(-14.0, 14.0)
		var size := Vector3(w, tall, w * rng.randf_range(0.7, 1.0))
		_box(col, size, skin, Vector3(ox, hgt + tall * 0.5, oz))
		var rows := int(tall / 9.0)
		for r in range(rows):
			if rng.randf() < 0.35:
				continue
			_box(col, Vector3(w * 0.8, 1.6, 0.6), win, Vector3(ox, hgt + 5.0 + r * 9.0, oz + size.z * 0.5 + 0.2), Vector3.ZERO, false)


var _window_mats: Dictionary = {}

## A lit window strip: unshaded and glowing, one material per tone so the strips bake together.
func _window_material(tone: String, colour: Color, energy: float) -> StandardMaterial3D:
	if not _window_mats.has(tone):
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = colour
		m.emission_enabled = true
		m.emission = colour
		m.emission_energy_multiplier = energy
		_window_mats[tone] = m
	return _window_mats[tone]


## A dead tree: a bare trunk, thick at the foot, with a few stub branches, inked.
var _bark_mat: StandardMaterial3D = null

func _dead_tree(col: Node3D, at: Vector3, rng: RandomNumberGenerator) -> void:
	if _bark_mat == null:
		_bark_mat = _lit(Color("2e2a26"))
	var bark := _bark_mat
	var tall := rng.randf_range(24.0, 40.0)
	_cyl(col, 1.2, 3.4, tall, 5, bark, at + Vector3(0.0, tall * 0.5, 0.0), Vector3(0.0, 0.0, rng.randf_range(-0.12, 0.12)))
	for k in range(rng.randi_range(2, 4)):
		var branch := Vector3(rng.randf_range(9.0, 18.0), 2.0, 2.0)
		_box(col, branch, bark, at + Vector3(branch.x * 0.4, tall * rng.randf_range(0.5, 0.9), 0.0),
			Vector3(0.0, rng.randf_range(0, TAU), rng.randf_range(0.3, 0.8)))


func _model(id: String, maker: String, paint: Dictionary = {}, outline: bool = true) -> Node3D:
	var scene: PackedScene = load("res://art/models/%s.glb" % id)
	var node: Node3D = scene.instantiate()
	MechView3D.toon(node, maker, "clean", paint, false)
	if outline:
		TraceLines.silhouette_through_all(node)   # a machine keeps its outline behind the wall
	else:
		TraceLines.strip_silhouette(node)         # the gate and walls wear none (Ryan, 22 September)
	return node


func _build_structures() -> void:
	var map := field.map
	if MechView3D.has_model("gate"):
		var g := _model("gate", "arsenal", {}, false)
		g.position = _hex_world(map.gate)
		g.rotation.y = PI   # turned about, so its portcullis face is the one the player sees
		_bake_model(g, _band(map.gate))   # with ink on its creases, so the towers and reveals read as geometry
		_baked_models.append(g)
	if MechView3D.has_model("wall"):
		# The wall runs the whole width of the view, margin included: the field is a window
		# on a longer line.
		var bottom: Array = []
		for w in map.wall_hexes:
			if Hex.axial_to_offset(w).y == map.height - 1:
				bottom.append(w)
		for mh in map.margin.keys():
			if Hex.axial_to_offset(mh).y == map.height - 1 and not map.city.has(mh):
				bottom.append(mh)
		var m := _model("wall", "arsenal", {}, false)   # one segment, baked at every place on the line
		m.rotation.y = PI
		for w in bottom:
			m.position = _hex_world(w)
			_bake_model(m, _band(w))
		_baked_models.append(m)
	_flush_batches()


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	_camera.near = 1.0
	_camera.far = 4000.0
	add_child(_camera)
	_camera.add_child(MechView3D.sheen_light())   # one world: the units' camera shares it
	_aim()


## Put every mech where the field says it is, on top of its column and turned to its
## facing.
func sync() -> void:
	var grad := Bleed.gradient(field, _origin, hex_px)
	var src := Bleed.sources(field, _origin, hex_px, _anim_px)
	var map := field.map
	for h in _columns.keys():
		_lift[h] = _height_of(h) * _cos * _ppu
	var seen := {}
	var occupied: Dictionary = {}
	for u in field.units:
		seen[u.id] = true
		if u.is_player() and not u.traits.has("flyer"):
			occupied[Hex.from_pixel(_anim_px[u.id], hex_px) if _anim_px.has(u.id) else u.pos] = true
		var node: Node3D = _units.get(u.id, null)
		if node == null:
			node = _make_unit(u)
			if node == null:
				continue
			add_child(node)
			_units[u.id] = node
			_phase[u.id] = float(u.id) * 1.7
		var under: Vector2i = Hex.from_pixel(_anim_px[u.id], hex_px) if _anim_px.has(u.id) else u.pos
		var y: float = float(_lift.get(under, 0.0)) / (_cos * _ppu)
		var ground_y := y
		if u.traits.has("flyer"):
			# A flyer rides over whatever stands on its hex (Ryan, 22 September: no clipping
			# through a mesa), just clear of the tallest thing there. Over ground the other
			# world has taken, the painting is flat, so it flies level with it, and the
			# height it flies at eases between hexes rather than stepping (Ryan, the same day).
			var under_px: Vector2 = _origin + (_anim_px[u.id] if _anim_px.has(u.id) else Hex.to_pixel(u.pos, hex_px))
			# Whether the ground here is still the reconstruction's: the same threshold the
			# compositor paints at, so the flyer clears the geometry wherever it can be seen
			# and flies level only where the painting has taken it.
			var solid := Bleed.solid(under_px, grad, src)
			var clear := maxf(0.0, float(_top.get(under, 0.0)) - _height_of(under) + 6.0 - HOVER)
			var want := (_height_of(under) + clear) * solid
			var prev: float = _fly_y.get(u.id, want)
			y = lerpf(prev, want, 1.0 - exp(-_dt * 7.0))
			_fly_y[u.id] = y
			ground_y = _height_of(under) * solid
		if _anim_px.has(u.id):
			_base[u.id] = _world(_anim_px[u.id], y)
			if _shadows.has(u.id):
				(_shadows[u.id] as Node3D).position = _world(_anim_px[u.id], ground_y + 0.3)
		else:
			_base[u.id] = _hex_world(u.pos, y)
			if _shadows.has(u.id):
				(_shadows[u.id] as Node3D).position = _hex_world(u.pos, ground_y + 0.3)   # on the ground, always
		node.position = _base[u.id]
		if _anim_px.has(u.id):
			continue   # heading is set by the move
		if u.is_player() and not u.is_static() and _pivots.has(u.id):
			# The model faces -Z (north) at rest; screen-down is +Z, so the facing turns the
			# other way from the pixel direction. The pivot turns; the seat's southward set
			# above it does not.
			# Eased there by the cornering module (_corner) once it has a rig; set outright the
			# first time, so a machine never turns in from north on arrival.
			if not _rest_yaw.has(u.id) or not _rigs.has(u.id):
				(_pivots[u.id] as Node3D).rotation.y = facing_yaw(u.facing)
			_rest_yaw[u.id] = facing_yaw(u.facing)
	_hide_props_under(occupied)
	for uid in _units.keys():
		if not seen.has(uid):
			_units[uid].queue_free()
			_units.erase(uid)
			_pivots.erase(uid)
			_rigs.erase(uid)
			_scale.erase(uid)
			_rest_yaw.erase(uid)
			_heading.erase(uid)
			_last_pos.erase(uid)
			_base.erase(uid)
			_fly_y.erase(uid)
			if _shadows.has(uid):
				_shadows[uid].queue_free()
				_shadows.erase(uid)


## Only a flyer sways at rest: it rides a slow swell, each on its own beat. A grounded
## machine holds still and every few seconds plays one of its own idle acts through its rig,
## the same as the skirmish's (Ryan, 2 October).
var _fly_y: Dictionary = {}   # unit id -> the eased height a flyer is at
var _dt := 1.0 / 60.0

func _process(delta: float) -> void:
	_time += delta
	_dt = delta
	for uid in _rigs.keys():
		var rig: MechRig = _rigs[uid]
		rig.tick(delta)
		_corner(uid, rig, delta)
	for uid in _units.keys():
		var u := field.unit_by_id(uid)
		if u == null or not u.traits.has("flyer"):
			continue
		var node: Node3D = _units[uid]
		var ph: float = _phase.get(uid, 0.0)
		if _pivots.has(uid):
			var pv: Node3D = _pivots[uid]
			pv.rotation.z = sin(_time * 1.6 + ph) * 0.035
			pv.rotation.x = sin(_time * 1.1 + ph * 0.7) * 0.02
		var base: Vector3 = _base.get(uid, node.position)
		node.position = base + Vector3(0.0, sin(_time * 2.1 + ph) * 2.0, 0.0)


func _make_unit(u: Unit) -> Node3D:
	if u.is_player() and not u.is_static():
		var maker := str(ContentDB.load_default().chassis.get(u.chassis_id, {}).get("maker", "minerva"))
		var model_id := MechView3D.model_for(u.chassis_id, "badger")
		var node := _model(model_id, maker, u.paint)
		_marker(node)
		# Mechs are the reconstruction's markers, drawn at marker size: whatever the model's
		# true size, its footprint is fitted to about one hex. The model hangs off a pivot
		# at the hex, centred by its bounds (a model's origin is wherever its author put
		# it) and standing on its lowest point; a flyer hovers, with a shadow on its tile.
		var aabb := _bounds(node)
		var widest := maxf(aabb.size.x, aabb.size.z)
		var flyer := u.traits.has("flyer")
		var fit := MARKER_FIT * (FIT_FLYER if flyer else 1.0)
		var k := (HEX_WORLD * 2.0 * fit / widest) if widest > 0.0 else 1.0
		var pivot := Node3D.new()
		node.scale = Vector3.ONE * k
		var hover := HOVER if flyer else 0.0
		# The ground is the model's Z = 0 by convention, never its lowest point: a claw or a
		# wing tip may hang below it, and lifting the whole machine to clear that is what
		# shoved the Badger off its hex. Under the pitched camera a body's middle projects
		# north of its feet, so the model is set south by as much as that; and it is
		# centred halfway by its bounds, so a long reach ahead (the booms) leans over the
		# hex's front edge rather than dragging the body back.
		var south := (hover + (aabb.end.y * k) * 0.5) * _cos / _sin
		node.position = Vector3(-aabb.get_center().x, 0.0, -aabb.get_center().z * 0.5) * k + Vector3(0.0, hover, 0.0)
		pivot.add_child(node)
		# The rig after the materials and the seat: a body track moves the model under its
		# pivot, so the facing and the idle never fight; seeded by the unit, so no two act in step.
		var rig := MechRig.new()
		rig.place = "map"
		rig.setup(node, model_id, node, u.id)
		rig.top_speed = MechRig.map_speed(widest, u.movespeed, flyer)   # the debug drive's pace (RIFTGATE_MOVE_DEBUG)
		_rigs[u.id] = rig
		_scale[u.id] = k
		var seat := Node3D.new()   # the pivot turns to the facing; the seat's southward set does not
		seat.position = Vector3(0.0, 0.0, south)
		seat.add_child(pivot)
		_pivots[u.id] = pivot
		pivot = seat
		if flyer:
			var disc := CylinderMesh.new()
			disc.top_radius = HEX_WORLD * 2.0 * SHADOW_RADIUS
			disc.bottom_radius = disc.top_radius
			disc.height = 0.2
			disc.radial_segments = 12
			var sh := MeshInstance3D.new()
			sh.mesh = disc
			var sm := StandardMaterial3D.new()
			sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			sm.albedo_color = Color(0.0, 0.0, 0.0, 0.45)
			# Depth-tested (Ryan, 29 September: drawn over everything it lay over the aircraft
			# itself); a prop on the tile may cut into it, which a shadow can bear.
			sm.render_priority = 2
			sh.material_override = sm
			sh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(sh)
			_shadows[u.id] = sh
			_to_units_layer(sh)
		_to_units_layer(pivot)
		return pivot
	return null   # foes and static units are drawn flat by the map view


## On the map a mech is the same textured model as the skirmish, traced in light so it
## still reads at one hex.
func _marker(node: Node) -> void:
	for child in node.find_children("*", "MeshInstance3D", true, false):
		_trace(child, "asset")


## The union of every mesh's bounds under `node`, in the node's own space.
func _bounds(node: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for mi in node.find_children("*", "MeshInstance3D", true, false):
		var box: AABB = (mi as MeshInstance3D).get_aabb()
		var xf: Transform3D = node.global_transform.affine_inverse() * (mi as Node3D).global_transform if node.is_inside_tree() else _relative(mi, node)
		var b := xf * box
		out = b if first else out.merge(b)
		first = false
	return out


## Transform of `child` relative to `root` before either is in the tree.
func _relative(child: Node, root: Node) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var n := child
	while n != null and n != root:
		if n is Node3D:
			xf = (n as Node3D).transform * xf
		n = n.get_parent()
	return xf
