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
## A machine's widest extent on the map, in hex widths, by its class by mass (chassis
## `size`; Ryan, 5 October: the machines' scale, which had fitted every machine to one width
## and a flyer a little smaller): a scout car takes most of a hex, a heavy the whole of it as
## before, an assault machine overflows it, drawn south over north. The flyers' own shrink
## (21 September: a small craft beside a mech) is the light and medium classes' now.
const SIZE_FIT := {"light": 0.72, "medium": 0.88, "heavy": 1.05, "assault": 1.2}
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
var _density: float = 1.0       # device pixels rendered per design pixel (Hud.density)
var _scroll := Vector2.ZERO     # the map view's scroll
var _zoom: float = 1.0
var _camera: Camera3D
var _units: Dictionary = {}     # unit id -> Node3D, the seat at the hex (set south a little); the pivot under it turns
var _pivots: Dictionary = {}    # unit id -> the pivot that turns to the facing; the model hangs off it centred by its bounds
var _shadows: Dictionary = {}   # unit id -> the ground disc under a flyer
var _rigs: Dictionary = {}      # unit id -> MechRig: the machine's joints, its idle acts and strikes (the same as the skirmish's)
var _plumes: Dictionary = {}    # unit id -> its boosters' plumes (MechView3D.setup_plumes), lit with their boosters each frame
var _scale: Dictionary = {}     # unit id -> the model's scale on the map (model units to world units)
var _outlined: Dictionary = {}  # unit id -> [the model, its bounds in its own space] (outline_boxes)
var _heading: Dictionary = {}   # unit id -> the yaw the move is heading, radians, while a move plays
var _last_pos: Dictionary = {}  # unit id -> the seat's position last frame, for the speed
var _rest_yaw: Dictionary = {}  # unit id -> the facing it settles to at rest; eased, never snapped (Ryan, 4 October)
const REST_TURN_RATE := 4.0     # per second: a standing machine turns to its recorded facing this briskly
const SLIDE_RATE_SNAP := 12.0   # per second: a machine with no slide follows its heading round the curve, smoothly (Ryan, 4 October: was 30, a snap)
const SLIDE_RATE_FULL := 2.2    # per second: a slide of 1 lets the facing lag the path through a corner
const OVERSTEER_AHEAD := 0.4    # seconds along the path an oversteering nose looks ahead, so it turns in before the corner
const OVERSTEER_WINDOW := 0.5   # seconds of path an oversteering nose averages its headings over (MovePath.chord), now and ahead
const TURN_RATE_MAX := 5.0      # radians a second a machine's facing turns at most (turn_toward)
const TURN_ACCEL_MAX := 30.0    # radians a second a second its turn rate changes at most
const OVERSTEER_GAIN := 1.4     # how far past the heading ahead an oversteer of 1 swings the nose, into the corner
const OVERSTEER_MAX := 1.45     # radians the nose may lead the path by, at most (eased toward; 0.95 until the seventh notes: nose in more; 1.2 until the eighth: the rear kicked out further)
const OVERSTEER_RATE := 7.0     # per second: how briskly an oversteering nose chases its lead
# A drifter eases into its kick-out (Ryan, 6 October, the ninth notes: not so sudden; it would
# help the whipping): it looks further ahead and averages a longer stretch, so the nose starts
# turning in sooner and builds over longer, and chases its lead on a softer spring, so its nose
# turns slower at its quickest for about the same kick. The tenth notes (the same day: it kicked
# out a touch too soon, a sideways strafe before the corner) brought the look ahead in from 0.7;
# the eleventh (a little of a segment break through the corner) found the nose's swing in two
# lumps through the route's double corner, fast, slower over the short leg between, fast again,
# and widened the stretch it averages over to a second and two fifths so it sweeps through both
# as one, which started the nose in sooner again. The fourteenth (it turned in too soon again)
# keeps that stretch but weights its middle most (MovePath.chord_tapered), looks a little less
# far ahead and leads harder for the turn it sees (DRIFT_GAIN), on a slightly stiffer spring:
# the Dingo's nose a tenth of the way in 0.22 s later and half in 0.17 s later, its sideways
# travel on the straight before the first corner 74 units where it was 104 (a hex is 104), its
# kick 74 degrees as before, its quickest turn 2.4 radians a second (1.5 before), the double
# corner still one sweep. The nose is fully in just before the corner either way: a hex corner
# turns the path 60 degrees in a quarter of a second, faster than a nose can gain on it, so a
# later start costs a quicker swing or a smaller kick. The jets, oversteering a third or less,
# keep the values above (oversteer_ease is 0 for them, and their stretch untapered).
const DRIFT_AHEAD := 0.35
const DRIFT_WINDOW := 1.4
const DRIFT_RATE := 4.5
const DRIFT_MAX := 1.55
const DRIFT_GAIN := 2.0
var _heading_ahead: Dictionary = {}  # unit id -> the yaw the path heads oversteer_ahead seconds on
var _turn_vel: Dictionary = {}       # unit id -> how fast its facing is turning, radians a second (turn_toward)
var _setoff: Dictionary = {}         # unit id -> [the facing it set off from, seconds since, seconds the turn takes] while a move plays
var _setoff_turn: Dictionary = {}    # unit id -> seconds its next move's turn onto its way takes (setoff_seconds)
var _heading_smooth: Dictionary = {} # unit id -> the path's heading averaged over OVERSTEER_WINDOW about now (MovePath.chord)
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
	_density = density
	_ppu = hex_px / HEX_WORLD
	_sin = sin(deg_to_rad(PITCH))
	_cos = cos(deg_to_rad(PITCH))
	size = Vector2i((view_size * density).round())   # the pixels rendered: the glass's (Hud.density)
	own_world_3d = true
	transparent_bg = true
	render_target_update_mode = SubViewport.UPDATE_ALWAYS   # alive: sway and ripple every frame
	msaa_3d = Hud.msaa_3d()
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
	return _world(MapOrient.to_pixel(h, hex_px), height)


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
## The scenery's ground in shade (Ryan, 10 November, of the painting's shaded scenery: "should do
## something equivalent to the 3D map as well, can be more subtle since the hex highlight does
## some of the work"): the ground past the field a step darker than the field's, by its material's
## own brightness, the city and the wall's rows as they were. Lightness, never a hue.
const SCENERY_SHADE := 0.62

func _terrain_material(tile: String, ripple: float = 0.0, by_uv: bool = false, shade: float = 1.0) -> ShaderMaterial:
	if shade != 1.0:
		var key := "%s/shade" % tile
		if not _materials.has(key):
			var dark: ShaderMaterial = _terrain_material(tile, ripple, by_uv).duplicate()
			dark.set_shader_parameter("lift", 1.35 * shade)
			_materials[key] = dark
		return _materials[key]
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
var _road_mat_shade: ShaderMaterial = null

func _road_material(shaded: bool = false) -> ShaderMaterial:
	if shaded:
		if _road_mat_shade == null:
			_road_mat_shade = _road_material().duplicate()
			_road_mat_shade.set_shader_parameter("lift", 1.35 * SCENERY_SHADE)
		return _road_mat_shade
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


func _ball(col: Node3D, radius: float, material: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO, traced: bool = true, squash: Vector3 = Vector3.ONE) -> void:
	var xf := Transform3D(Basis.from_euler(rot), col.position + pos).scaled_local(squash * radius)
	var band: int = col.get_meta("band", 0)
	var hex = col.get_meta("prop_hex") if col.has_meta("prop_hex") else null
	_bake(_unit_geo("ball"), xf, material, band, true, "", 1, null, hex)
	if traced:
		_bake(_unit_geo("ball_lines"), xf, _trace_material("prop"), band, false, "prop", 1, null, hex)


func _cyl(col: Node3D, top: float, bottom: float, height: float, segments: int, material: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO, traced: bool = true) -> void:
	var xf := Transform3D(Basis.from_euler(rot), col.position + pos)
	var band: int = col.get_meta("band", 0)
	var hex = col.get_meta("prop_hex") if col.has_meta("prop_hex") else null
	_bake(_cylinder_geo(top, bottom, height, segments), xf, material, band, true, "", 1, null, hex)
	if traced:
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
## A machine whose move is planned and not yet played stands where its plan starts (Ryan, 25
## October): unit id -> [hex, facing], in place of the battle's hex, until the plan plays.
var seam_shown := -1.0   # the seam's row as the map shows it while its creep waits or plays (BattleMapView.seam_shown); under 0, the field's
var held: Dictionary = {}


func _hex_of(u: Unit) -> Vector2i:
	return held[u.id][0] if held.has(u.id) else u.pos


func _facing_of(u: Unit) -> int:
	return int(held[u.id][1]) if held.has(u.id) else u.facing

## While a phase plays, a unit is where its animation says, not on its hex. The heading is
## where the move is going; the facing follows it through the cornering module (_corner),
## at once for most machines and lagging for one with a slide.
func set_anim(uid: int, px: Vector2, heading: Vector2, ahead: Vector2 = Vector2.ZERO, smooth: Vector2 = Vector2.ZERO) -> void:
	_anim_px[uid] = px
	if heading.length_squared() > 0.001:
		_heading[uid] = atan2(-heading.x, -heading.y)
	if ahead.length_squared() > 0.001:
		_heading_ahead[uid] = atan2(-ahead.x, -ahead.y)
	if smooth.length_squared() > 0.001:
		_heading_smooth[uid] = atan2(-smooth.x, -smooth.y)


func clear_anim(uid: int) -> void:
	_anim_px.erase(uid)
	_setoff.erase(uid)
	_heading.erase(uid)
	_last_pos.erase(uid)
	_heading_ahead.erase(uid)
	_heading_smooth.erase(uid)
	_setoff_turn.erase(uid)


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
			var settled := turn_toward(pivot.rotation.y, float(_turn_vel.get(uid, 0.0)), float(_rest_yaw[uid]), REST_TURN_RATE, delta)
			pivot.rotation.y = settled.x
			_turn_vel[uid] = settled.y
			turn = settled.y
		_setoff.erase(uid)
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
	var over := maxf(0.0, float(rig.move.get("oversteer", 0.0)))
	var rate := lerpf(SLIDE_RATE_SNAP, SLIDE_RATE_FULL, slide)
	var heading: float = _heading[uid]
	var want := heading
	if over > 0.0:
		# The path's heading averaged about now and a moment ahead, so the nose swings through
		# a corner as one smooth motion (the tangent swings at once where a corner's arc begins).
		var base := float(_heading_smooth.get(uid, heading))
		var ahead := float(_heading_ahead.get(uid, base))
		want = base + oversteer_lead(wrapf(ahead - base, -PI, PI), over)
		rate = lerpf(rate, oversteer_rate(over), minf(over, 1.0))
	if strafe > 0.0:
		var u := field.unit_by_id(uid)
		if u != null:
			want = facing_target(heading, facing_yaw(u.facing), strafe)
			rate = lerpf(rate, STRAFE_TURN_RATE, strafe)
	want = setoff_aim(_setoff_step(uid, pivot.rotation.y, delta), want)
	var turned := turn_toward(pivot.rotation.y, float(_turn_vel.get(uid, 0.0)), want, rate, delta)
	pivot.rotation.y = turned.x
	_turn_vel[uid] = turned.y
	rig.drive(speed, wrapf(heading - pivot.rotation.y, -PI, PI), turned.y, delta)


const STRAFE_TURN_RATE := 6.0   # per second: a helicopter yaws to where it will face in the first moment of a move, then translates
const SETOFF_S := 0.5           # seconds a move's set-off takes to bring the facing's aim from where it stood onto the path, when nothing says longer
# A machine turns onto its way before it sets off (Ryan, 7 October, the twentieth notes: the
# turn at a move's start was a little jumpy, half a second whatever the angle, rolling as it
# swung): a sixth of a turn takes SETOFF_TURN_BASE plus SETOFF_TURN_PER_ACCEL for each second
# of its `accel` (the heavy turn slower), a bigger turn longer by the root of its size, and the
# move holds at its start for SETOFF_ROLL of that, rolling off as the turn finishes. The
# twenty-second notes slowed it two fifths for every machine (0.6 and 0.4 before).
const SETOFF_TURN_BASE := 0.85
const SETOFF_TURN_PER_ACCEL := 0.55
const SETOFF_ROLL := 0.75


## The set-off (Ryan, 6 October, the eighth notes: a frame jerk at the corners, worse each time
## the drift was made harder): a move that sets off in another direction than the machine
## faces, as every move of the hangar's route does after its turn, sent the aim there at
## once, and the facing's spring took that step at its full turning acceleration in a frame.
## The aim eases from the facing it set off from onto the path's over SETOFF_S (a
## smootherstep, so the turn's acceleration builds from nothing); `state` is [that facing,
## seconds since].
static func setoff_aim(state: Array, want: float) -> float:
	var u := clampf(float(state[1]) / maxf(0.05, float(state[2]) if state.size() > 2 else SETOFF_S), 0.0, 1.0)
	var s := u * u * u * (u * (6.0 * u - 15.0) + 10.0)
	return float(state[0]) + wrapf(want - float(state[0]), -PI, PI) * s


func _setoff_step(uid: int, facing: float, delta: float) -> Array:
	if not _setoff.has(uid):
		_setoff[uid] = [facing, 0.0, maxf(SETOFF_S, float(_setoff_turn.get(uid, SETOFF_S)))]
		_setoff_turn.erase(uid)
	var state: Array = _setoff[uid]
	state[1] = float(state[1]) + delta
	return state


## Seconds a machine's move holds at its start while it turns from where it faces onto the
## move's first heading (`first`, map pixels), SETOFF_ROLL of the turn, which it remembers for
## that move's set-off; none for a helicopter, which turns as it translates.
func setoff_seconds(uid: int, first: Vector2) -> float:
	_setoff_turn.erase(uid)
	if not _pivots.has(uid) or not _rigs.has(uid) or first.length_squared() < 1e-6:
		return 0.0
	var rig: MechRig = _rigs[uid]
	if float(rig.move.get("strafe", 0.0)) > 0.0:
		return 0.0
	var angle := absf(wrapf(atan2(-first.x, -first.y) - (_pivots[uid] as Node3D).rotation.y, -PI, PI))
	var turn := setoff_turn(angle, float(rig.move.get("accel", MovePath.ACCEL_DEFAULT)))
	_setoff_turn[uid] = turn
	return turn * SETOFF_ROLL


## Seconds a turn of `angle` radians onto a move's way takes a machine of `accel`.
static func setoff_turn(angle: float, accel: float) -> float:
	return (SETOFF_TURN_BASE + SETOFF_TURN_PER_ACCEL * accel) * sqrt(absf(angle) / (PI / 3.0))


## A machine's widest extent on the map, in hex widths, for its class by mass; a class the
## table does not know is drawn as a heavy, the one width every machine had before.
static func fit_for(size: String) -> float:
	return float(SIZE_FIT.get(size, SIZE_FIT["heavy"]))


## How far an oversteering nose leads its path, radians: past the turn the path makes over
## the next oversteer_ahead seconds (`turn_ahead`, radians), easing toward oversteer_max
## rather than stopping hard at it (a hard stop was a kink the nose showed).
static func oversteer_lead(turn_ahead: float, oversteer: float) -> float:
	var top := oversteer_max(oversteer)
	return top * tanh(turn_ahead * oversteer_gain(oversteer) * oversteer / top)


## How much of a drifter's easing a machine takes: none at an oversteer of a half or less (the
## jets, and the Stingray since the eighteenth notes), all of it from one and a half (the Puffin
## and the Dingo).
static func oversteer_ease(oversteer: float) -> float:
	return clampf((oversteer - 0.5) / 1.0, 0.0, 1.0)


static func oversteer_ahead(oversteer: float) -> float:
	return lerpf(OVERSTEER_AHEAD, DRIFT_AHEAD, oversteer_ease(oversteer))


static func oversteer_window(oversteer: float) -> float:
	return lerpf(OVERSTEER_WINDOW, DRIFT_WINDOW, oversteer_ease(oversteer))


static func oversteer_rate(oversteer: float) -> float:
	return lerpf(OVERSTEER_RATE, DRIFT_RATE, oversteer_ease(oversteer))


static func oversteer_max(oversteer: float) -> float:
	return lerpf(OVERSTEER_MAX, DRIFT_MAX, oversteer_ease(oversteer))


static func oversteer_gain(oversteer: float) -> float:
	return lerpf(OVERSTEER_GAIN, DRIFT_GAIN, oversteer_ease(oversteer))


## A facing turned toward `want` over `delta` seconds, from `facing` turning at `vel` radians a
## second: (the new facing, the new turn rate). A critically damped spring (Ryan, 5 October, the
## sixth notes: the drift's rear swung out with a jerk at every corner's start, three for the
## three turns of the hangar's route): the turn rate itself eases in and out, so a corner
## beginning, which bends where the nose should point, never shows as a jolt. `rate` is a first
## order chase's, the spring set to lag as long (its natural frequency twice the rate). Its
## turn rate and how fast that changes are capped, so a move that sets off a long way from the
## machine's facing swings it round at a pace and not in a frame.
static func turn_toward(facing: float, vel: float, want: float, rate: float, delta: float) -> Vector2:
	var w := 2.0 * rate
	var n := maxi(1, int(ceil(delta * w / 0.25)))
	var h := delta / float(n)
	for i in range(n):
		var acc := clampf(wrapf(want - facing, -PI, PI) * w * w - 2.0 * w * vel, -TURN_ACCEL_MAX, TURN_ACCEL_MAX)
		vel = clampf(vel + acc * h, -TURN_RATE_MAX, TURN_RATE_MAX)
		facing += vel * h
	return Vector2(facing, vel)


## The motion numbers in a machine's rig sidecar (`move`: slide, bank, strafe, tilt, accel,
## heft), for the map view's curve; empty for a unit with no rig.
func motion_of(uid: int) -> Dictionary:
	return (_rigs[uid] as MechRig).move if _rigs.has(uid) else {}


## The pivot's yaw for one of the six facings: the model faces -Z (north) at rest and
## screen-down is +Z, so the facing turns the other way from the pixel direction.
static func facing_yaw(facing: int) -> float:
	var d: Vector2 = MapOrient.to_pixel(Hex.DIRECTIONS[facing], 1.0).normalized()
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
const EDGE_W := 1.0   # the edge's width in design pixels on screen, at every zoom: a hairline, the tint does the work (Ryan, 22 September)

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
				line = _line_mark(_edge_mesh(y + 0.05, m["edges"]), _columns[h])
			_marks[h] = [fill, line]
	for m in list:
		var pair: Array = _marks.get(m["hex"], [])
		if pair.is_empty():
			continue
		if pair[0] != null:
			(pair[0].material_override as StandardMaterial3D).albedo_color = _scene_alpha(m["fill"])
		if pair[1] != null:
			(pair[1].material_override as ShaderMaterial).set_shader_parameter("color", _scene_alpha(m["line"]))


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


## A mark's edge, drawn by mark_line.gdshader: EDGE_W design pixels on screen at every zoom,
## smoothed, as the grid's.
func _line_mark(mesh: Mesh, col: Node3D) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var mat := ShaderMaterial.new()
	mat.shader = load("res://game/battle/mark_line.gdshader")
	mat.set_shader_parameter("line_px", EDGE_W * _density)
	mat.set_shader_parameter("inset_px", maxf(0.5, GRID_INSET * _density))
	mat.render_priority = 1
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	col.add_child(mi)
	return mi


func _mark_mesh(y: float) -> ArrayMesh:
	var corners := MapOrient.corners(Vector2.ZERO, hex_px - 3.0)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var c := _world(Vector2.ZERO, y)
	for i in range(corners.size()):
		st.add_vertex(c)
		st.add_vertex(_world(corners[(i + 1) % corners.size()], y))
		st.add_vertex(_world(corners[i], y))
	return st.commit()


## Ribbons along the given edges (corner i to i+1), just inside the hex's edge, GRID_RIBBON
## map pixels deep: UV.x carries each corner's distance in, which mark_line.gdshader turns
## into a line of one width on screen.
func _edge_mesh(y: float, edges: Array) -> ArrayMesh:
	var outer := MapOrient.corners(Vector2.ZERO, hex_px - 1.0)
	var inner := MapOrient.corners(Vector2.ZERO, hex_px - 1.0 - GRID_RIBBON * 2.0 / sqrt(3.0))
	var edge := Vector2.ZERO
	var deep := Vector2(GRID_RIBBON, 0.0)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for e in edges:
		var i: int = int(e)
		var j := (i + 1) % 6
		var a := _world(outer[i], y)
		var b := _world(outer[j], y)
		var c := _world(inner[j], y)
		var d := _world(inner[i], y)
		st.set_uv(edge); st.add_vertex(a)
		st.set_uv(edge); st.add_vertex(b)
		st.set_uv(deep); st.add_vertex(c)
		st.set_uv(edge); st.add_vertex(a)
		st.set_uv(deep); st.add_vertex(c)
		st.set_uv(deep); st.add_vertex(d)
	return st.commit()


## The hex outline as a ribbon just inside the column's edge at height `y`, for the glowing
## grid. Geometry, not GL lines: a line primitive is one device pixel whatever the screen,
## and on the phone (Ryan, 25 September: faint at rest on native Android) that is a
## hairline on a small dense screen, thinner and dimmer still on the Compatibility
## renderer. The line keeps GRID_W design pixels on screen at every zoom (Ryan, 30 October:
## it thickened as the map zoomed in, and stepped zoomed out), drawn smoothed by
## grid.gdshader on a ribbon GRID_RIBBON map pixels wide, which holds the line and its
## smoothing down to zoom 1 on a glass of the design's density.
const GRID_W := 1.5
const GRID_INSET := 0.4   # design pixels between the column's edge and the line
const GRID_RIBBON := 3.0

func _grid_geo(y: float) -> Dictionary:
	var outer := MapOrient.corners(Vector2.ZERO, hex_px - 0.75)
	var inner := MapOrient.corners(Vector2.ZERO, hex_px - 0.75 - GRID_RIBBON * 2.0 / sqrt(3.0))   # a corner's inset is measured along the edge's normal, not the radius, and exactly: UV.x says how deep it is
	var v := PackedVector3Array()
	var uv := PackedVector2Array()
	var edge := Vector2.ZERO
	var deep := Vector2(GRID_RIBBON, 0.0)   # UV.x: map pixels in from the column's edge
	for i in range(outer.size()):
		var j := (i + 1) % outer.size()
		var a := _world(outer[i], y)
		var b := _world(outer[j], y)
		var c := _world(inner[j], y)
		var d := _world(inner[i], y)
		v.append(a); v.append(b); v.append(c)
		v.append(a); v.append(c); v.append(d)
		uv.append(edge); uv.append(edge); uv.append(deep)
		uv.append(edge); uv.append(deep); uv.append(deep)
	return {"v": v, "uv": uv}


var _grid_mat: ShaderMaterial = null

## The display's light: the trace shader's scan on the grid's own (grid.gdshader), so the
## scan bar lights the grid as it passes; a little dimmer than the traces.
func _grid_material() -> ShaderMaterial:
	if _grid_mat == null:
		_grid_mat = ShaderMaterial.new()
		_grid_mat.shader = load("res://game/battle/grid.gdshader")
		_grid_mat.set_shader_parameter("color", Palette.HUD)
		_grid_mat.set_shader_parameter("gain", GRID_GAIN_PHONE if OS.has_feature("mobile") else GRID_GAIN)
		_grid_mat.set_shader_parameter("line_px", GRID_W * _density)
		_grid_mat.set_shader_parameter("inset_px", maxf(0.5, GRID_INSET * _density))
	return _grid_mat


## The grid's resting brightness (the tuner's GRID knob). The phone needs far more than
## the Mac: the ribbons drawn at the Mac's gain were still dim on the phone at any zoom
## (Ryan, 28 September; the Compatibility renderer adds no bloom halo to a line, and the
## glass is small), so a phone rests hotter. Down a fifth on 25 October to calm a busy
## screen, and back once the lines held one width at every zoom (Ryan, 30 October: "With
## these changes, I think it could go back how it was").
const GRID_GAIN := 0.7
const GRID_GAIN_PHONE := 1.5


## One hex of flat ground as a polygon: the dark rim under the columns, for the grid gaps.
func _hex_mesh(inset: float) -> ArrayMesh:
	var corners := MapOrient.corners(Vector2.ZERO, hex_px - inset)
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
	var corners := MapOrient.corners(Vector2.ZERO, hex_px - 0.75)
	# The UV is the pointy-top hex inscribed in the tile whichever way the view turns (corner i
	# of the flat-top layout is pointy corner i turned), so a shader that reads the hex's
	# directions off the UV (road.gdshader's edge midpoints) reads them right in both views
	# (Ryan, 10 November: the roads lined up in the painted world and not in the 3D).
	var uv_corners := Hex.corners(Vector2.ZERO, hex_px - 0.75)
	var top: Array[Vector3] = []
	for c in corners:
		top.append(_world(c, h))
	var tv := PackedVector3Array()
	var tuv := PackedVector2Array()
	for i in range(1, corners.size() - 1):
		for j in [0, i + 1, i]:
			tv.append(top[j])
			tuv.append(uv_corners[j] / (hex_px * 2.0) + Vector2(0.5, 0.5))
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
	var corners := MapOrient.corners(Vector2.ZERO, hex_px)
	var hexes: Array = map.all_hexes().duplicate()
	hexes.append_array(map.margin.keys())
	var scenery := {}
	for h in map._scenery():
		scenery[h] = true
	for h in hexes:
		var t: int = map.terrain_of(h)
		var in_field: bool = map.has(h)
		var at := _hex_world(h)
		var hgt := _height_of(h)
		# Which edges need a wall: those facing a neighbour at another height, or none.
		var sides: Array = []
		var here := MapOrient.to_pixel(h, hex_px)
		for i in range(corners.size()):
			var mid: Vector2 = (corners[i] + corners[(i + 1) % corners.size()]) * 0.5
			var across := here + mid * 2.0
			var other: float = -999.0
			for nb in Hex.neighbors(h):
				if (map.has(nb) or map.margin.has(nb)) and MapOrient.to_pixel(nb, hex_px).distance_to(across) < hex_px * 0.5:
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
		var shaded: bool = scenery.has(h)   # past the field: in shade (SCENERY_SHADE)
		var column: Array
		if ground_t == BattleMap.Terrain.ROAD:
			# The road's links and its seed ride in the vertex colour (road.gdshader), so
			# road hexes bake like any other and need nothing per instance.
			var seed_f := fmod(float(h.x * 131 + h.y * 7919) * 0.0137, 1.0)
			column = _column_geo(hgt, sides, Color(float(_road_links(h)) / 255.0, absf(seed_f), 0.0, 1.0))
			_bake(column[0], at_xf, _road_material(shaded), band, true)
		else:
			column = _column_geo(hgt, sides)
			_bake(column[0], at_xf, _terrain_material(TILE[ground_t], 1.0 if ground_t == BattleMap.Terrain.WATER else 0.0, false, SCENERY_SHADE if shaded else 1.0), band, true)
		_bake(column[1], at_xf, _terrain_material("rock", 0.0, false, SCENERY_SHADE) if shaded else rock, band, true)
		if in_field and not (map.gate_hexes.has(h) or map.wall_hexes.has(h)):
			# The grid is the display's own light, drawn on the ground in the scene so a
			# raised hex hides the lines behind it; the wall and the machines hide it the
			# same way, by standing on it.
			_bake(_grid_geo(hgt + 0.35), at_xf, _grid_material(), band, false)
		rng.seed = h.x * 131 + h.y * 7919
		if map.city.has(h) or _city_row(h):
			_city_block(col, hgt, rng)
			continue
		if t == BattleMap.Terrain.MOUNTAIN:
			_top[h] = hgt + _wall_model(col, str(map.wall_look.get(h, BattleMap.WALL_LOOKS[0])), hgt, rng)
			continue
		var dressed := _dress(col, h, t, hgt, rng)
		if dressed > 0.0:
			_top[h] = hgt + dressed
	_flush_batches()


## The decoration, laid to be read (Ryan, 29 October: placement "can go a long way towards
## making the map less cluttered and easier to read, while still looking believable"):
## knee-high, so a wall is the one tall thing on the field (DRESS_MAX under WALL_MIN, measured
## from the ground, so a raised hex never lifts it past a wall); dense out in the scenery and
## against the walls and the water, sparse in the open ground the squads play on; and of the
## shape's kind: rubble on ruins, scrub on rough, and on bare ground what the shape stands on
## its banks, at its walls' feet and in its scenery (BattleMap.KINDS' dress). Nothing stands
## under the wall's rows. Returns the tallest thing it stood, above the ground.
const DRESS_MAX := 16.0
const WALL_MIN := 40.0
const DENSE := 1.0      # the scenery
const EDGE := 0.7       # the field's ground against a wall or the water
const LANE := 0.25      # the field's open ground


func _dress(col: Node3D, h: Vector2i, t: int, hgt: float, rng: RandomNumberGenerator) -> float:
	var map := field.map
	if Hex.axial_to_offset(h).y >= map.height - BattleMap.GATE_ROWS:
		return 0.0
	var by_wall := false
	var by_water := false
	for n in Hex.neighbors(h):
		if not (map.has(n) or map.margin.has(n)):
			continue
		by_wall = by_wall or map.terrain_of(n) == BattleMap.Terrain.MOUNTAIN
		by_water = by_water or map.terrain_of(n) == BattleMap.Terrain.WATER
	var scenery := not map.has(h)
	var density := DENSE if scenery else (EDGE if by_wall or by_water else LANE)
	var dress: Dictionary = BattleMap.KINDS.get(map.kind, {}).get("dress", {})
	match t:
		BattleMap.Terrain.RUINS:
			return _rubble(col, hgt, rng, density)
		BattleMap.Terrain.ROUGH:
			return _scrub(col, hgt, rng, density)
		BattleMap.Terrain.PLAIN:
			var word := ""
			if by_water:
				word = str(dress.get("bank", ""))
			elif by_wall:
				word = str(dress.get("foot", ""))
			elif scenery:
				word = str(dress.get("scenery", ""))
			else:
				word = str(dress.get("field", ""))   # the open field's own, sparse (the steppe's grass: Ryan, 10 November, "VERY barren")
			return _strew(col, word, hgt, rng, density)
	return 0.0


## How many of a prop a hex takes: `full` at full density, a little either way.
func _count(rng: RandomNumberGenerator, full: int, density: float) -> int:
	return int(round(float(full) * density * rng.randf_range(0.7, 1.3)))


## Ruins: broken blocks, and a standing wall stub where the rubble is thick. In the open the
## blocks are few, low and dark, so a street reads clear between the towers.
func _rubble(col: Node3D, hgt: float, rng: RandomNumberGenerator, density: float) -> float:
	var rubble := _terrain_material("rubble")
	var tallest := 0.0
	for k in range(_count(rng, 5, density)):
		var size := Vector3(rng.randf_range(7, 14), rng.randf_range(4, 11), rng.randf_range(6, 12))
		if density < EDGE:
			size *= Vector3(0.7, 0.5, 0.7)
		_box(col, size, rubble if density >= EDGE else _stone_material(), Vector3(rng.randf_range(-18, 18), hgt + size.y * 0.5, rng.randf_range(-13, 13)), Vector3(0.0, rng.randf_range(0, TAU), 0.0), density >= EDGE)
		tallest = maxf(tallest, size.y)
	if density >= EDGE:
		var stub := Vector3(rng.randf_range(12, 20), rng.randf_range(10, DRESS_MAX), 3.5)
		_box(col, stub, rubble, Vector3(rng.randf_range(-14, 14), hgt + stub.y * 0.5, rng.randf_range(-10, 10)), Vector3(0.0, rng.randf_range(0, TAU), 0.0))
		tallest = maxf(tallest, stub.y)
	return tallest


## Low scrub: bushes and a boulder or two (the badlands' rough ground).
func _scrub(col: Node3D, hgt: float, rng: RandomNumberGenerator, density: float) -> float:
	for k in range(_count(rng, 4, density)):
		var r := rng.randf_range(4.0, 7.0)
		_ball(col, r, _plant_material(), Vector3(rng.randf_range(-18, 18), hgt + r * 0.5, rng.randf_range(-14, 14)), Vector3(0.0, rng.randf_range(0, TAU), 0.0))
	for k in range(_count(rng, 2, density)):
		var r := rng.randf_range(4.0, 6.5)
		_ball(col, r, _stone_material(), Vector3(rng.randf_range(-16, 16), hgt + r * 0.6, rng.randf_range(-12, 12)), Vector3(0.0, rng.randf_range(0, TAU), 0.0))
	return 10.0


## A bare hex's dressing, by the shape's word: reeds on a bank, shingle on a shore, rocks or
## scree at a wall's foot, grass and the odd low dead tree out in the scenery, boulders. The
## small stuff wears no trace, so it reads as texture and the walls as things.
func _strew(col: Node3D, word: String, hgt: float, rng: RandomNumberGenerator, density: float) -> float:
	var rock := _stone_material()
	match word:
		"reeds":
			for k in range(_count(rng, 10, density)):
				var tall := rng.randf_range(7.0, 13.0)
				_box(col, Vector3(1.1, tall, 1.1), _plant_material(), Vector3(rng.randf_range(-18, 18), hgt + tall * 0.5, rng.randf_range(-13, 13)), Vector3(rng.randf_range(-0.25, 0.25), 0.0, rng.randf_range(-0.25, 0.25)), false)
			return 13.0
		"shingle":
			for k in range(_count(rng, 9, density)):
				var r := rng.randf_range(2.0, 3.6)
				_ball(col, r, rock, Vector3(rng.randf_range(-18, 18), hgt + r * 0.25, rng.randf_range(-13, 13)), Vector3(0.0, rng.randf_range(0, TAU), 0.0), false, Vector3(1.5, 0.45, 1.0))
			return 3.0
		"rocks", "boulders":
			for k in range(_count(rng, 3 if word == "rocks" else 2, density)):
				var r := rng.randf_range(4.0, 7.5)
				_ball(col, r, rock, Vector3(rng.randf_range(-16, 16), hgt + r * 0.6, rng.randf_range(-12, 12)), Vector3(0.0, rng.randf_range(0, TAU), 0.0))
			return 12.0
		"scree":
			if rng.randf() < 0.5:
				return 0.0   # a gorge's lanes run along its cliffs, so the scree lies at every other foot
			for k in range(_count(rng, 8, density)):
				var size := Vector3(rng.randf_range(2.0, 5.0), rng.randf_range(1.5, 3.5), rng.randf_range(2.0, 5.0))
				_box(col, size, rock, Vector3(rng.randf_range(-18, 18), hgt + size.y * 0.4, rng.randf_range(-13, 13)), Vector3(rng.randf_range(-0.4, 0.4), rng.randf_range(0, TAU), rng.randf_range(-0.4, 0.4)), false)
			return 4.0
		"grass":
			for k in range(_count(rng, 9, density)):
				var tall := rng.randf_range(3.0, 6.0)
				_cyl(col, 0.0, 1.8, tall, 4, _plant_material(), Vector3(rng.randf_range(-18, 18), hgt + tall * 0.5, rng.randf_range(-13, 13)), Vector3.ZERO, false)
			if rng.randf() < 0.25 * density:
				_dead_tree(col, Vector3(rng.randf_range(-12, 12), hgt, rng.randf_range(-9, 9)), rng)
				return DRESS_MAX
			return 6.0
	return 0.0


var _plant_mat: StandardMaterial3D = null
var _stone_mat: StandardMaterial3D = null

## The vegetation's one colour, a dark dry olive, so a hex's grass, reeds and scrub bake together
## and read as the ground's texture, not as things.
func _plant_material() -> StandardMaterial3D:
	if _plant_mat == null:
		_plant_mat = _lit(Color("2c2e1c"))
	return _plant_mat


## The small stones' one colour (shingle, scree, rocks, boulders), dark for the same reason.
func _stone_material() -> StandardMaterial3D:
	if _stone_mat == null:
		_stone_mat = _lit(Color("34322f"))
	return _stone_mat


## A wall by what it is (BattleMap.WALL_LOOKS; Ryan, 29 October: one rule under every name):
## crags are rock spikes, mesas flat-topped rock stacked and offset, towers dead skyscrapers
## and cliffs a wall of rock. Every one overflows its tile and stands WALL_MIN at least, well
## over the decoration, so it reads as a thing a flyer goes over. Returns how tall it stands
## above the ground, so a flyer clears it and no more.
func _wall_model(col: Node3D, look: String, hgt: float, rng: RandomNumberGenerator) -> float:
	match look:
		"towers":
			# Dead skyscrapers: tall thin shells stepping down as they rise, a few dim
			# windows still lit on the tallest, far above anything else on the field.
			var rubble := _terrain_material("rubble")
			for k in range(4):
				var w := rng.randf_range(8.0, 12.0)
				var tall := rng.randf_range(70.0, 96.0) if k == 0 else rng.randf_range(WALL_MIN, 62.0)
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
			return 96.0
		"mesas":
			# Mesas: flat-topped blocks stacked and offset, a badland.
			var rock := _terrain_material("rock")
			for k in range(3):
				var tall := rng.randf_range(44.0, 54.0) if k == 0 else rng.randf_range(28.0, 38.0)
				var ox := 0.0 if k == 0 else rng.randf_range(-16.0, 16.0)
				var oz := 0.0 if k == 0 else rng.randf_range(-12.0, 12.0)
				for step in range(2):
					var top := rng.randf_range(10.0, 15.0) * (0.8 if step == 1 else 1.0)
					var slab_h := tall * (0.6 if step == 0 else 0.4)
					_cyl(col, top, top * 1.15, slab_h, 6, rock, Vector3(ox, hgt + slab_h * 0.5 + (tall * 0.6 if step == 1 else 0.0), oz), Vector3(0.0, rng.randf_range(0, TAU), 0.0))
			return 54.0
		"cliffs":
			return _cliff(col, hgt, rng)
	# Crags: rock spikes, leaning, filling the tile.
	var rock_dark := _terrain_material("rock")
	for k in range(6):
		var foot := rng.randf_range(9.0, 14.0)
		var spike_h := rng.randf_range(46.0, 58.0) if k == 0 else rng.randf_range(28.0, 42.0)
		var a := k * TAU / 5.0 + rng.randf_range(-0.4, 0.4)
		var dist := 0.0 if k == 0 else rng.randf_range(14.0, 22.0)
		_cyl(col, 0.8, foot, spike_h, 4, rock_dark, Vector3(cos(a) * dist, hgt + spike_h * 0.5 - 1.0, sin(a) * dist),
			Vector3(rng.randf_range(-0.18, 0.18), rng.randf_range(0, TAU), rng.randf_range(-0.18, 0.18)))
	return 58.0


## A hex prism's trace, `inset` of the hex's radius in from its rim: its top's rim and its
## corners' edges down to `from`.
func _prism_lines(inset: float, from: float, to: float) -> Dictionary:
	var corners := MapOrient.corners(Vector2.ZERO, hex_px - inset)
	var v := PackedVector3Array()
	for i in range(corners.size()):
		var a := _world(corners[i], to)
		v.append(a)
		v.append(_world(corners[(i + 1) % corners.size()], to))
		v.append(a)
		v.append(_world(corners[i], from))
	return {"v": v, "lines": true}


## A hex prism `inset` in from the hex's rim, from `from` up to `to`: its top and every side.
func _prism_geo(inset: float, from: float, to: float) -> Array:
	var corners := MapOrient.corners(Vector2.ZERO, hex_px - inset)
	var tv := PackedVector3Array()
	for i in range(1, corners.size() - 1):
		for j in [0, i + 1, i]:
			tv.append(_world(corners[j], to))
	var sv := PackedVector3Array()
	var sn := PackedVector3Array()
	for i in range(corners.size()):
		var a := corners[i]
		var b := corners[(i + 1) % corners.size()]
		var mid := (a + b) * 0.5
		var nrm := Vector3(mid.x, 0.0, mid.y).normalized()
		for p in [_world(a, from), _world(b, from), _world(b, to), _world(a, from), _world(b, to), _world(a, to)]:
			sv.append(p)
			sn.append(nrm)
	return [{"v": tv, "n": _filled3(tv.size(), Vector3.UP)}, {"v": sv, "n": sn}]


## A cliff (the gorge's): its hex a column of rock with a face on every edge, so neighbouring
## cliffs stand as one wall, like basalt columns, some of them stepping up again narrower, so
## the wall's top line breaks; traced, as the props are.
func _cliff(col: Node3D, hgt: float, rng: RandomNumberGenerator) -> float:
	var rock := _terrain_material("rock")
	var band: int = col.get_meta("band", 0)
	var xf := Transform3D(Basis.IDENTITY, col.position)
	var tall := hgt + rng.randf_range(WALL_MIN + 4.0, WALL_MIN + 12.0)
	var base := _prism_geo(0.75, 0.0, tall)
	_bake(base[0], xf, rock, band, true)
	_bake(base[1], xf, rock, band, true)
	_bake(_prism_lines(0.75, 0.0, tall), xf, _trace_material("prop"), band, false, "prop")
	if rng.randf() < 0.6:
		var inset := hex_px * rng.randf_range(0.3, 0.5)
		var top := tall + rng.randf_range(6.0, 12.0)
		var step := _prism_geo(inset, tall, top)
		_bake(step[0], xf, rock, band, true)
		_bake(step[1], xf, rock, band, true)
		_bake(_prism_lines(inset, tall, top), xf, _trace_material("prop"), band, false, "prop")
		tall = top
	return tall - hgt


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


## A dead tree, knee-high (DRESS_MAX): a bare trunk, thick at the foot, with a few stub
## branches, inked.
var _bark_mat: StandardMaterial3D = null

func _dead_tree(col: Node3D, at: Vector3, rng: RandomNumberGenerator) -> void:
	if _bark_mat == null:
		_bark_mat = _lit(Color("2e2a26"))
	var bark := _bark_mat
	var tall := rng.randf_range(11.0, DRESS_MAX)
	_cyl(col, 1.0, 2.6, tall, 5, bark, at + Vector3(0.0, tall * 0.5, 0.0), Vector3(0.0, 0.0, rng.randf_range(-0.12, 0.12)))
	for k in range(rng.randi_range(2, 3)):
		var branch := Vector3(rng.randf_range(5.0, 10.0), 1.6, 1.6)
		_box(col, branch, bark, at + Vector3(branch.x * 0.4, tall * rng.randf_range(0.5, 0.9), 0.0),
			Vector3(0.0, rng.randf_range(0, TAU), rng.randf_range(0.3, 0.8)))


## A model in its maker's materials, wearing its fitted die on the pins as the skirmish does
## (MechView3D.plan_for), so the outline's bounds take them in. A machine's light outline is
## the compositor's, drawn round the machines' layer (outline_boxes); the gate and walls wear
## none (Ryan, 22 September).
func _model(id: String, maker: String, paint: Dictionary = {}, plan: Array = [], own: bool = true) -> Node3D:
	var scene: PackedScene = load("res://art/models/%s.glb" % id)
	var node: Node3D = scene.instantiate()
	MechView3D.toon(node, maker, "clean", paint, false)
	var pins := MechView3D.pins_of(node)
	MechView3D.wear(pins, plan, "clean", paint, false, true, id)
	MechView3D.wear_burns(pins, MechView3D.burn_rows(id, plan, ContentDB.load_default(), own), "clean", paint)   # a burn weapon's fire, dim at rest
	return node


## The machines' light outline, in design pixels on screen at every zoom (Ryan, 30 October:
## "I don't want the outline to thicken as I zoom in"; the engine's outline grew with the
## world, 2.6 model units, and broke along the models' flat faces). The compositor draws it
## (bleed.gdshader) in the trace modes that outline the player's things; RIFTGATE_OUTLINE=<n>
## sets it, to compare widths by eye.
const OUTLINE := 2.0
const MAX_BOXES := 32   # bleed.gdshader's `boxes`

static func outline_px() -> float:
	if not TraceLines.mode() in ["assets", "pulse"]:
		return 0.0
	var env := OS.get_environment("RIFTGATE_OUTLINE")
	return float(env) if not env.is_empty() else OUTLINE


## Where each machine stands on screen, for the compositor's outline: the box round its bounds
## as they project now (the model's own transform carries its facing and its body's acts), an
## eighth larger each way for its limbs', in this viewport's pixels, so the outline is looked
## for only near one.
func outline_boxes() -> PackedVector4Array:
	var out := PackedVector4Array()
	if _camera == null or not _camera.is_inside_tree():
		return out
	for uid in _outlined.keys():
		var model: Node3D = _outlined[uid][0]
		if not is_instance_valid(model) or not model.is_visible_in_tree() or out.size() >= MAX_BOXES:
			continue
		var bounds: AABB = _outlined[uid][1]
		var xf := model.global_transform
		var lo := Vector2(INF, INF)
		var hi := -lo
		for i in range(8):
			var at := _camera.unproject_position(xf * bounds.get_endpoint(i))
			lo = lo.min(at)
			hi = hi.max(at)
		var grow := (hi - lo) * 0.125
		out.append(Vector4(lo.x - grow.x, lo.y - grow.y, hi.x + grow.x, hi.y + grow.y))
	return out


## A structure's scale along the wall (the long wall brief 7.1). The ground is stretched in
## depth so the pitched camera lays it on the 2D grid; a model is not. With the wall at the
## bottom it runs across the screen and needs nothing; at the left it runs into the screen's
## depth, foreshortened by the pitch, so it stretches by as much along its own length (its
## local x, turned into the depth) to meet the next segment.
func _along_wall() -> Vector3:
	return Vector3(1.0 / _sin, 1.0, 1.0) if MapOrient.wall_left else Vector3.ONE


## Where the wall's models stand off the back row (the gate's and the wall's both stand on it).
## With the wall at the bottom the camera's pitch stands their height over the row in front, so
## that row reads as the wall's foot; with the wall at the left the pitch runs along the wall and
## that row lay bare in front of it, out of play and looking like ground (Ryan, 9 November: "the
## wall in wall-left view has the out-of-play row completely bare in front ... It looks weird").
## So there they stand a row toward the field, against the apron, and the back row behind them is
## the city's (_city_row), so neither view shows a row out of play (Ryan, the same day: "yeah that's
## the best solution I think").
func _wall_shift() -> Vector3:
	if not MapOrient.wall_left:
		return Vector3.ZERO
	return _world(MapOrient.toward_rift() * hex_px * 1.5)   # one row's pitch toward the rift


## Whether a hex on the wall's back row stands behind the shifted wall (_wall_shift), so it holds a
## city block, as the city past the wall does: every hex of the field's last row and of the margin's,
## the city's own aside (it builds its block already).
func _city_row(h: Vector2i) -> bool:
	if _wall_shift() == Vector3.ZERO or field.map.city.has(h):
		return false
	return Hex.axial_to_offset(h).y == field.map.height - 1


func _build_structures() -> void:
	var map := field.map
	var shift := _wall_shift()
	if MechView3D.has_model("gate"):
		var g := _model("gate", "arsenal")
		g.position = _hex_world(map.gate) + shift
		g.rotation.y = MapOrient.yaw(PI)   # turned about, so its portcullis face is the one the player sees; with the wall at the left, toward the city
		g.scale = _along_wall()
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
		var m := _model("wall", "arsenal")   # one segment, baked at every place on the line
		m.rotation.y = MapOrient.yaw(PI)
		m.scale = _along_wall()
		for w in bottom:
			m.position = _hex_world(w) + shift
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
	var grad := Bleed.gradient(field, _origin, hex_px, seam_shown)
	var src := Bleed.sources(field, _origin, hex_px, _anim_px)
	var map := field.map
	for h in _columns.keys():
		_lift[h] = _height_of(h) * _cos * _ppu
	var seen := {}
	var occupied: Dictionary = {}
	for u in field.units:
		seen[u.id] = true
		if u.is_player() and not u.traits.has("flyer"):
			occupied[MapOrient.from_pixel(_anim_px[u.id], hex_px) if _anim_px.has(u.id) else _hex_of(u)] = true
		var node: Node3D = _units.get(u.id, null)
		if node == null:
			node = _make_unit(u)
			if node == null:
				continue
			add_child(node)
			_units[u.id] = node
			_phase[u.id] = float(u.id) * 1.7
		if _rigs.has(u.id):
			# A form its machine carries between fights (the Clydesdale's battery up, Changed Over)
			# held on the map as in the fight (MechView3D.hold_statuses).
			var rig: MechRig = _rigs[u.id]
			for name in rig.forms.keys():
				rig.set_form(str(name), Effects.has(u, str(name)))
		var under: Vector2i = MapOrient.from_pixel(_anim_px[u.id], hex_px) if _anim_px.has(u.id) else _hex_of(u)
		var y: float = float(_lift.get(under, 0.0)) / (_cos * _ppu)
		var ground_y := y
		if u.traits.has("flyer"):
			# A flyer rides over whatever stands on its hex (Ryan, 22 September: no clipping
			# through a mesa), just clear of the tallest thing there. Over ground the other
			# world has taken, the painting is flat, so it flies level with it, and the
			# height it flies at eases between hexes rather than stepping (Ryan, the same day).
			var under_px: Vector2 = _origin + (_anim_px[u.id] if _anim_px.has(u.id) else MapOrient.to_pixel(_hex_of(u), hex_px))
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
			_base[u.id] = _hex_world(_hex_of(u), y)
			if _shadows.has(u.id):
				(_shadows[u.id] as Node3D).position = _hex_world(_hex_of(u), ground_y + 0.3)   # on the ground, always
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
				(_pivots[u.id] as Node3D).rotation.y = facing_yaw(_facing_of(u))
			_rest_yaw[u.id] = facing_yaw(_facing_of(u))
	_sync_wrecks(occupied)
	_sync_caches(occupied, grad, src)
	_hide_props_under(occupied)
	for uid in _units.keys():
		if not seen.has(uid):
			_units[uid].queue_free()
			_units.erase(uid)
			_pivots.erase(uid)
			_balance.erase(uid)
			_turn_vel.erase(uid)
			_setoff.erase(uid)
			_rigs.erase(uid)
			_plumes.erase(uid)
			_scale.erase(uid)
			_outlined.erase(uid)
			_rest_yaw.erase(uid)
			_heading.erase(uid)
			_last_pos.erase(uid)
			_base.erase(uid)
			_fly_y.erase(uid)
			if _shadows.has(uid):
				_shadows[uid].queue_free()
				_shadows.erase(uid)


# ---------------------------------------------------------------- the field's wrecks

## The wrecks (Battlefield.wrecks; Ryan, 4 November: a wreck stays on its hex and blocks it for
## the battle; 16 November: "A wreck should behave like any other unit, meaning nobody can land
## on it"): a machine wrecked in a fight lies on the hex it fell on, built as the living machine
## is (_machine_model: its model, its fit, its seat, the units' layer over both worlds, so it is
## seen as a machine is, never sunk into the ground or painted over), a size smaller so it keeps
## to its hex (Ryan, 16 November: "Make sure the kill wrecks don't take up too much of the adjacent
## hexes ... Make sure that perspective of the wrecks make sense. Don't embed them in the
## terrain"). It goes as a lost machine goes in a fight (MechRig.kill: its lights gutter out and it
## slumps, nothing tipping the body, a walker sinking on its own legs and a flyer or a hover coming
## down onto its lowest point; his rules of 3 November for the slump, no weird lean and nothing
## through the floor), its colours dimmed, no outline. A wreck the map sees come down goes there;
## one already down as the map is built lies as it lies. RIFTGATE_WRECK_DEBUG=1 lays one of each of
## the team's chassis beside it and lets them go again every few seconds.
const WRECK_FIT := 0.75         # of a living machine's fit: a heavy wreck keeps inside its hex
const WRECK_DARK := 0.28        # what is left of its colours: the sun lights a white livery at 0.45 near white again
const WRECK_SETTLE := 3.0       # seconds its slump and its landing take, done
const WRECK_LAND := 0.6         # seconds a flyer or a hover takes to come down, after the slump starts (MechView3D.LAND's role)
const WRECK_DEBUG_EVERY := 4.0  # seconds between falls under RIFTGATE_WRECK_DEBUG
static var WRECK_DEBUG := OS.get_environment("RIFTGATE_WRECK_DEBUG") == "1"
var _wrecks: Dictionary = {}       # unit id -> {"seat", "pivot", "node", "rig", "k", "airborne", "aloft": the height it comes down from, "base": the model's resting place, "age"}
var _wrecks_seen := false          # whether a sync has run: the wrecks there before it lie still


func _sync_wrecks(occupied: Dictionary) -> void:
	var live := {}
	for u in field.wrecks:
		live[u.id] = true
		if not _wrecks.has(u.id):
			var made := _make_wreck(u)
			if made.is_empty():
				continue
			add_child(made["seat"])
			_wrecks[u.id] = made
			if _wrecks_seen:
				made["age"] = 0.0
			else:
				_settle_wreck(made)   # down already: lie as it lies
		for h in u.hexes():
			occupied[h] = true   # its hex's dressing would stand through it: hidden, as under a machine
		var w: Dictionary = _wrecks[u.id]
		(w["seat"] as Node3D).position = _hex_world(u.pos, _height_of(u.pos)) + Vector3(0.0, 0.0, float(w["south"]))
	_wrecks_seen = true
	for uid in _wrecks.keys():
		if not live.has(uid):
			(_wrecks[uid]["seat"] as Node3D).queue_free()
			_wrecks.erase(uid)


## A wreck's model: the machine's own as a living machine is built (_machine_model), WRECK_FIT of
## its size and down on the ground, every surface's colour dimmed and matt, then lost
## (MechRig.kill) facing as it fell. {} for a chassis with no model.
func _make_wreck(u: Unit) -> Dictionary:
	var m := _machine_model(u, WRECK_FIT, false)
	if m.is_empty():
		return {}
	var node: Node3D = m["node"]
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = child
		for i in range(mi.mesh.get_surface_count()):
			var mat := mi.get_active_material(i)
			if mat is StandardMaterial3D:
				var sm := mat as StandardMaterial3D   # the model's own copy (MechView3D.toon duplicates each)
				sm.albedo_color = sm.albedo_color * Color(WRECK_DARK, WRECK_DARK * 0.97, WRECK_DARK * 0.94)
				sm.roughness = 0.95
				sm.metallic = 0.0
				sm.metallic_specular = 0.15
	var seat: Node3D = m["seat"]
	var pivot: Node3D = m["pivot"]
	pivot.rotation.y = facing_yaw(u.facing)
	var rig: MechRig = m["rig"]
	var airborne := u.traits.has("flyer") or u.traits.has("hover")
	rig.airborne = airborne   # a flyer or a hover comes down onto its lowest point (MechView3D.lose)
	rig.kill()
	_to_units_layer(seat)
	for vi in seat.find_children("*", "VisualInstance3D", true, false):
		(vi as VisualInstance3D).layers &= ~(1 << (MechView3D.SHEEN_LAYER - 1))   # dead metal takes no gloss: a chrome maker's sheen light lit a wreck as bright as a living machine
	var south := seat.position.z
	return {"seat": seat, "pivot": pivot, "node": node, "rig": rig, "k": float(m["k"]), "airborne": airborne,
		"aloft": HOVER if u.traits.has("flyer") else 0.0, "south": south, "age": WRECK_SETTLE}


## A wreck's slump and landing at its age: the rig's servos carry the slump (MechRig.kill, the body
## its own), and a flyer or a hover comes down from where it rode onto its lowest point as it starts
## (collapse_floor), the pivot carrying it as the fight's stage does (MechView3D.lose), so nothing of
## it reaches below the ground.
func _lay_wreck(w: Dictionary, delta: float) -> void:
	var rig: MechRig = w["rig"]
	rig.tick(delta)
	var g := clampf((float(w["age"]) - MechRig.COLLAPSE_AT) / WRECK_LAND, 0.0, 1.0)
	var e := g * g * (3.0 - 2.0 * g)
	var down := -rig.collapse_floor * float(w["k"]) if bool(w["airborne"]) else 0.0
	(w["pivot"] as Node3D).position.y = lerpf(float(w["aloft"]), down, e)


## A wreck down already: its slump played out at once.
func _settle_wreck(w: Dictionary) -> void:
	w["age"] = 0.0
	while float(w["age"]) < WRECK_SETTLE:
		w["age"] = float(w["age"]) + 0.1
		_lay_wreck(w, 0.1)


## Each wreck's slump played on while it settles; under RIFTGATE_WRECK_DEBUG every wreck stands
## again every WRECK_DEBUG_EVERY seconds and goes down again.
func _fell_wrecks(delta: float) -> void:
	for uid in _wrecks.keys():
		var w: Dictionary = _wrecks[uid]
		var age := float(w["age"]) + delta
		if WRECK_DEBUG and age > WRECK_DEBUG_EVERY:
			var rig: MechRig = w["rig"]
			rig.revive()
			rig.airborne = bool(w["airborne"])
			rig.kill()
			age = 0.0
		w["age"] = age
		if age <= WRECK_SETTLE + delta:
			_lay_wreck(w, delta)


## How long ago a wreck came down on the map, in seconds (the map view's smoke reads it); a
## large number for one the map does not show.
func wreck_age(uid: int) -> float:
	return float(_wrecks[uid]["age"]) if _wrecks.has(uid) else 1.0e6


# ---------------------------------------------------------------- the field's caches

## The caches as models (Ryan, 9 November: "can we get models (and art, when flattened), for loot
## caches on map?"): each kind in content/loot.json wears art/models/cache_<id>.glb (tools/lowforge)
## on its hex while the ground there is the reconstruction's, in the world's layer like a prop, so
## the painting covers it as it covers the ground; the map view draws its flat token over the
## painting from there (BattleMapView._draw_caches, art/loot). The kind's name and pips are the map
## view's in both worlds: the model is the picture, never the information. A kind with no model
## keeps the map view's diamond. A machine on the hex hides the model, as it hides a prop.
const CACHE_FIT := 1.3          # a cache's size on its hex, over the model's own (built to about two thirds of a hex): hot, for the phone
const CACHE_TURN := 0.7         # radians a second the Relic's core turns
const CACHE_BOB := 1.6          # model units its core rides up and down
var _caches: Dictionary = {}    # cache id -> its model's Node3D
var _cache_hex: Dictionary = {} # cache id -> the hex it was built on
var _cache_cores: Dictionary = {}   # cache id -> [the part named `core`, its resting height]: the one the map turns


static func cache_model(kind: String) -> String:
	return "cache_%s" % kind


static func has_cache_model(kind: String) -> bool:
	return not kind.is_empty() and MechView3D.has_model(cache_model(kind))


## Whether a cache's model stands on a hex right now, for the map view: built, and not hidden
## under a machine.
func cache_shown(cid: int) -> bool:
	return _caches.has(cid) and (_caches[cid] as Node3D).visible


func _sync_caches(occupied: Dictionary, grad: Vector2, src: PackedVector3Array) -> void:
	var db := ContentDB.load_default()
	var live := {}
	for c in field.caches:
		var cid := int(c["id"])
		var h: Vector2i = c["pos"]
		var kind := db.loot_kind_of_tier(int(c.get("tier", 1)))
		if not has_cache_model(kind):
			continue
		live[cid] = true
		var node: Node3D = _caches.get(cid, null)
		if node == null:
			node = _make_cache(kind)
			add_child(node)
			_caches[cid] = node
			_cache_hex[cid] = h
			var core := node.find_child("core", true, false) as Node3D
			if core != null:
				_cache_cores[cid] = [core, core.position.y]
		# Its hex's own dressing would stand through it: hidden, as under a machine.
		var under_machine: bool = occupied.has(h)
		occupied[h] = true
		# As the painting takes the hex the model sinks into it, as the ground's height does
		# (Bleed.solid, the compositor's threshold), and is gone where the hex is flat.
		var solid := Bleed.solid(_origin + MapOrient.to_pixel(h, hex_px), grad, src)
		node.visible = solid > 0.02 and not under_machine
		node.position = _hex_world(h, _height_of(h))
		node.scale = Vector3(CACHE_FIT, CACHE_FIT * maxf(solid, 0.02), CACHE_FIT)
	for cid in _caches.keys():
		if not live.has(cid):
			(_caches[cid] as Node3D).queue_free()   # claimed
			_caches.erase(cid)
			_cache_hex.erase(cid)
			_cache_cores.erase(cid)


## A cache's model, dressed matt whatever its tiles' maker: a wreck's dead steel, bone and their
## stone take no machine's polish. Its lit parts (the amber role: a Derelict's lamp, a Relic's
## light) glow as a machine's do. Traced like a prop, so it reads at one hex.
func _make_cache(kind: String) -> Node3D:
	var scene: PackedScene = load("res://art/models/%s.glb" % cache_model(kind))
	var node: Node3D = scene.instantiate()
	MechView3D.toon(node, "", "clean", {}, false)
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = child
		mi.layers = 1   # the world's layer alone: no sheen light
		for i in range(mi.mesh.get_surface_count()):
			var m := mi.get_surface_override_material(i) as StandardMaterial3D
			if m != null:
				m.roughness = 0.95
				m.metallic = 0.0
				m.metallic_specular = 0.15
	_marker(node)
	return node


## The Relic's core turns and rides on its own light, each on its own beat (a part named `core`,
## models_low.cache_relic); every other cache lies still.
func _turn_caches(delta: float) -> void:
	for cid in _cache_cores.keys():
		var core: Node3D = _cache_cores[cid][0]
		if not is_instance_valid(core):
			continue
		core.rotate_y(CACHE_TURN * delta)
		core.position.y = float(_cache_cores[cid][1]) + sin(_time * 1.3 + float(cid) * 1.9) * CACHE_BOB


## Only a flyer sways at rest: it rides a slow swell, each on its own beat; a hovercraft
## balances on its cushion (HoverBalance). A grounded
## machine holds still and every few seconds plays one of its own idle acts through its rig,
## the same as the skirmish's (Ryan, 2 October).
var _fly_y: Dictionary = {}   # unit id -> the eased height a flyer is at
var _balance: Dictionary = {}   # unit id -> HoverBalance, a hovercraft's idle
var _dt := 1.0 / 60.0

func _process(delta: float) -> void:
	_time += delta
	_turn_caches(delta)
	_fell_wrecks(delta)
	_dt = delta
	for uid in _rigs.keys():
		var rig: MechRig = _rigs[uid]
		rig.tick(delta)
		_corner(uid, rig, delta)
		for pl in _plumes.get(uid, []):
			(pl[0] as ShaderMaterial).set_shader_parameter("strength", MechView3D.plume_k((pl[1] as StandardMaterial3D).emission_energy_multiplier, float(pl[2])))
	for uid in _units.keys():
		var u := field.unit_by_id(uid)
		if u == null:
			continue
		if u.traits.has("hover") and _pivots.has(uid):
			# A hovercraft balances on its cushion as the currents shift it, every way at once
			# (Ryan, 5 October: not the flyers' bob; a platform on the water), moving or not.
			if not _balance.has(uid):
				_balance[uid] = HoverBalance.new(uid + 1)
			var hb: HoverBalance = _balance[uid]
			hb.quiet = _rigs.has(uid) and (_rigs[uid] as MechRig).in_act()
			hb.step(delta)
			var hp: Node3D = _pivots[uid]
			hp.rotation.x = hb.pitch
			hp.rotation.z = hb.roll
			(_units[uid] as Node3D).position = _base.get(uid, (_units[uid] as Node3D).position) + Vector3(0.0, hb.heave * float(_scale.get(uid, 1.0)), 0.0)
			continue
		if not u.traits.has("flyer"):
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
	if not u.is_player() or u.is_static():
		return null   # foes and static units are drawn flat by the map view
	var m := _machine_model(u)
	if m.is_empty():
		return null
	var node: Node3D = m["node"]
	var rig: MechRig = m["rig"]
	_outlined[u.id] = [node, m["aabb"]]   # where the compositor looks for its outline (outline_boxes)
	rig.top_speed = MechRig.map_speed(float(m["widest"]), u.movespeed, float(m["fit"]))   # the debug drive's pace (RIFTGATE_MOVE_DEBUG)
	_rigs[u.id] = rig
	if MechView3D.PLUMES:
		_plumes[u.id] = MechView3D.setup_plumes(node, m["side"], rig, 0.9)   # trailing behind it as it runs, the map's top-down camera seeing them whole; no outline pass to ink it
	_scale[u.id] = float(m["k"])
	_pivots[u.id] = m["pivot"]
	var seat: Node3D = m["seat"]
	if u.traits.has("flyer"):
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
	_to_units_layer(seat)
	return seat


## A machine's model as the map shows it, its rig set up, registered nowhere (_make_unit for a
## living machine, _make_wreck for a wreck): {"seat", "pivot", "node", "rig", "side", "aabb", "k",
## "widest", "fit"}. Mechs are the reconstruction's markers, drawn at marker size: whatever the
## model's true size, its footprint is fitted to about one hex (`fit_k` of that: a wreck sits
## smaller in its hex). The model hangs off a pivot at the hex, centred by its bounds (a model's
## origin is wherever its author put it) and standing on its own ground; a flyer hovers unless
## `aloft` is false. {} for no model.
func _machine_model(u: Unit, fit_k := 1.0, aloft := true) -> Dictionary:
	var db := ContentDB.load_default()
	var maker := db.maker_of(u.chassis_id)
	var model_id := MechView3D.model_for(u.chassis_id)
	if model_id.is_empty() or not ResourceLoader.exists("res://art/models/%s.glb" % model_id):
		return {}
	var node := _model(model_id, maker, u.paint, MechView3D.plan_for(u, db) if model_id == u.chassis_id else [], model_id == u.chassis_id)
	MechView3D.launches_of(node, MechRig.load_sidecar(model_id))   # what a weapon fires out of the machine stays hidden on the map (the Lammergeier's drones)
	MechWeld.weld(node, MechWeld.kept_parts(model_id))   # a mesh a material in each moving group (the battery plan), before the traces and the fit read it
	_marker(node)
	var aabb := _bounds(node)
	var widest := maxf(aabb.size.x, aabb.size.z)
	var fit := fit_for(str(db.chassis.get(u.chassis_id, {}).get("size", ""))) * fit_k
	var k := (HEX_WORLD * 2.0 * fit / widest) if widest > 0.0 else 1.0
	var pivot := Node3D.new()
	node.scale = Vector3.ONE * k
	var hover := HOVER if aloft and u.traits.has("flyer") else 0.0
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
	var side := MechRig.load_sidecar(model_id)
	if MechView3D.PLUMES:
		for pl in side.get("plumes", []):
			rig.halo_skip.append(str(pl.get("part", "")))   # a booster's plume burns where its halo's ring was
	rig.setup(node, model_id, node, u.id)
	var seat := Node3D.new()   # the pivot turns to the facing; the seat's southward set does not
	seat.position = Vector3(0.0, 0.0, south)
	seat.add_child(pivot)
	return {"seat": seat, "pivot": pivot, "node": node, "rig": rig, "side": side, "aabb": aabb, "k": k, "widest": widest, "fit": fit}


## On the map a mech is the same textured model as the skirmish, traced in light so it
## still reads at one hex.
func _marker(node: Node) -> void:
	for child in node.find_children("*", "MeshInstance3D", true, false):
		_trace(child, "asset")


## The union of every mesh's bounds under `node`, in the node's own space (a welded mesh's
## are its parts', MechWeld.corners).
func _bounds(node: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for mi in node.find_children("*", "MeshInstance3D", true, false):
		var xf: Transform3D = node.global_transform.affine_inverse() * (mi as Node3D).global_transform if node.is_inside_tree() else _relative(mi, node)
		for c in MechWeld.corners(mi):
			var p := xf * c
			out = AABB(p, Vector3.ZERO) if first else out.expand(p)
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
