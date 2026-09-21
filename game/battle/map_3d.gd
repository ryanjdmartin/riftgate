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
var _base: Dictionary = {}      # unit id -> resting position, which the idle sway plays around
var _phase: Dictionary = {}     # unit id -> idle phase, so the team does not sway in step
var _columns: Dictionary = {}   # hex -> Node3D: the column and its props, collapsed by the bleed
var _structs: Array = []        # [[hex, Node3D], ...] the gate and walls, collapsed the same way
var _lift: Dictionary = {}      # hex -> how far above its grid cell the top sits on screen, in px
var _materials: Dictionary = {} # tile name -> ShaderMaterial
var _time: float = 0.0


func setup(f: Battlefield, view_size: Vector2, origin: Vector2, hex_size: float) -> void:
	field = f
	hex_px = hex_size
	_origin = origin
	_view = view_size
	_ppu = hex_px / HEX_WORLD
	_sin = sin(deg_to_rad(PITCH))
	_cos = cos(deg_to_rad(PITCH))
	size = Vector2i(int(view_size.x), int(view_size.y))
	own_world_3d = true
	transparent_bg = true
	render_target_update_mode = SubViewport.UPDATE_ALWAYS   # alive: sway and ripple every frame
	msaa_3d = SubViewport.MSAA_4X
	canvas_item_default_texture_filter = SubViewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_build_light()
	_build_ground()
	_build_structures()
	_build_camera()
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
	_camera.position = target + back * CAMERA_DISTANCE
	_camera.look_at(target, Vector3.UP)


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
	# A little glow, so the lamps, engines and light strips bleed like a screen would.
	e.glow_enabled = true
	e.glow_intensity = 0.8
	e.glow_bloom = 0.08
	e.glow_hdr_threshold = 0.9
	env.environment = e
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


## RIFTGATE_MAP_WIRE=1: the terrain as the display's wireframe, a trial (Ryan, 21 September).
static func wire_mode() -> bool:
	return OS.get_environment("RIFTGATE_MAP_WIRE") == "1"


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


## A prop with the display's trace on it.
func _prop(col: Node3D, mesh: Mesh, material: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.position = pos
	mi.rotation = rot
	col.add_child(mi)
	_trace(mi)
	return mi


## The display traces a thing's edges in light: every crease (faces meeting at more than
## EDGE_ANGLE) and every silhouette-only edge, as glowing lines that pulse with the
## field's wave, plus a thin grown hull for the outline. RIFTGATE_INK=dark keeps the old
## black hull alone, to compare.
const EDGE_ANGLE := 28.0
var _edge_cache: Dictionary = {}   # mesh rid -> ArrayMesh of lines
var _trace_mat: ShaderMaterial = null

func _trace(mi: MeshInstance3D) -> void:
	if mi.mesh == null:
		return
	var hull := MeshInstance3D.new()
	hull.mesh = mi.mesh
	hull.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	hull.material_override = _ink(0.7)
	mi.add_child(hull)
	if OS.get_environment("RIFTGATE_INK") == "dark":
		return
	var edges := _edge_mesh(mi.mesh)
	if edges == null:
		return
	var em := MeshInstance3D.new()
	em.mesh = edges
	em.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	em.material_override = _trace_material()
	mi.add_child(em)


func _trace_material() -> ShaderMaterial:
	if _trace_mat == null:
		_trace_mat = ShaderMaterial.new()
		_trace_mat.shader = load("res://game/battle/trace.gdshader")
		_trace_mat.set_shader_parameter("color", Palette.HUD)
	return _trace_mat


## The feature edges of a mesh as a line mesh: edges shared by faces that meet at an angle,
## or belonging to one face only. Vertices are welded by position, since flat-shaded
## exports split them per face.
func _edge_mesh(mesh: Mesh) -> ArrayMesh:
	var key := mesh.get_rid()
	if _edge_cache.has(key):
		return _edge_cache[key]
	var edges: Dictionary = {}   # "a|b" -> [Vector3 a, Vector3 b, Array normals]
	var limit := cos(deg_to_rad(EDGE_ANGLE))
	for s in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(s)
		if arrays.is_empty():
			continue
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		var n := idx.size() if idx.size() > 0 else verts.size()
		for f in range(0, n - 2, 3):
			var a: Vector3 = verts[idx[f]] if idx.size() > 0 else verts[f]
			var b: Vector3 = verts[idx[f + 1]] if idx.size() > 0 else verts[f + 1]
			var c: Vector3 = verts[idx[f + 2]] if idx.size() > 0 else verts[f + 2]
			var nrm := (b - a).cross(c - a)
			if nrm.length_squared() < 1e-8:
				continue
			nrm = nrm.normalized()
			for pair in [[a, b], [b, c], [c, a]]:
				var ka := _vkey(pair[0])
				var kb := _vkey(pair[1])
				var k := ka + "|" + kb if ka < kb else kb + "|" + ka
				if not edges.has(k):
					edges[k] = [pair[0], pair[1], []]
				(edges[k][2] as Array).append(nrm)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	var any := false
	for k in edges.keys():
		var e: Array = edges[k]
		var normals: Array = e[2]
		var keep := normals.size() == 1
		if not keep:
			for i in range(normals.size()):
				for j in range(i + 1, normals.size()):
					if (normals[i] as Vector3).dot(normals[j]) < limit:
						keep = true
		if keep:
			st.add_vertex(e[0])
			st.add_vertex(e[1])
			any = true
	var out: ArrayMesh = st.commit() if any else null
	_edge_cache[key] = out
	return out


static func _vkey(v: Vector3) -> String:
	return "%d,%d,%d" % [roundi(v.x * 50.0), roundi(v.y * 50.0), roundi(v.z * 50.0)]


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


## The hex outline as lines at height `y`, for the glowing grid.
func _grid_mesh(y: float) -> ArrayMesh:
	var corners := Hex.corners(Vector2.ZERO, hex_px - 1.5)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	for i in range(corners.size()):
		st.add_vertex(_world(corners[i], y))
		st.add_vertex(_world(corners[(i + 1) % corners.size()], y))
	return st.commit()


var _grid_mat: StandardMaterial3D = null

## The display's light: unshaded HUD colour, emissive so the glow pass catches it.
func _grid_material() -> StandardMaterial3D:
	if _grid_mat == null:
		_grid_mat = StandardMaterial3D.new()
		_grid_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_grid_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_grid_mat.albedo_color = Color(Palette.HUD, 0.55)
		_grid_mat.emission_enabled = true
		_grid_mat.emission = Palette.HUD
		_grid_mat.emission_energy_multiplier = 1.4
	return _grid_mat


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


## A hex column: surface 0 is the top at `h`, surface 1 its sides from the ground to `h`,
## only on the edges in `sides` (an edge shared with a neighbour of the same height has no
## wall: two water hexes are one pool, two gravel hexes one field). Normals are explicit,
## outward for a raised column and inward for a sunk one, since it is the sunk hex's far
## bank that faces the camera.
func _column_mesh(h: float, sides: Array) -> ArrayMesh:
	var corners := Hex.corners(Vector2.ZERO, hex_px - 0.75)
	var top: Array[Vector3] = []
	for c in corners:
		top.append(_world(c, h))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(1, corners.size() - 1):
		for j in [0, i + 1, i]:
			st.set_normal(Vector3.UP)
			st.set_uv(corners[j] / (hex_px * 2.0) + Vector2(0.5, 0.5))   # the hex inscribed in the tile
			st.add_vertex(top[j])
	var mesh := st.commit()
	if absf(h) < 0.01 or not sides.has(true):
		return mesh
	var ss := SurfaceTool.new()
	ss.begin(Mesh.PRIMITIVE_TRIANGLES)
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
			ss.set_normal(nrm)
			ss.add_vertex(v)
	return ss.commit(mesh)


func _build_ground() -> void:
	var rim := _hex_mesh(0.0)
	var rim_mat := _flat(Color(Palette.HUD, 0.10).blend(Palette.BG))
	var rock := _terrain_material("rock")
	var map := field.map
	var rng := RandomNumberGenerator.new()
	var corners := Hex.corners(Vector2.ZERO, hex_px)
	var hexes: Array = map.all_hexes().duplicate()
	hexes.append_array(map.margin.keys())
	var wire := wire_mode()
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
		var r := MeshInstance3D.new()
		r.mesh = rim
		r.material_override = rim_mat
		r.position = at + Vector3(0, minf(0.0, hgt) - 0.2, 0)
		add_child(r)
		# The column and everything on it hang off one node at ground level, so the bleed
		# can collapse the lot by scaling its height: the hex sinks into the painting.
		var col := Node3D.new()
		col.position = at
		add_child(col)
		_columns[h] = col
		# A crag keeps the ground it stands on (crag-water, crag-ruin, crag-field: the
		# flavour of the tile shows through under the rock).
		var ground_t: int = map.crag_base.get(h, t) if t == BattleMap.Terrain.MOUNTAIN else t
		var mi := MeshInstance3D.new()
		mi.mesh = _column_mesh(hgt, sides)
		if wire:
			mi.set_surface_override_material(0, _wire_fill())
			if mi.mesh.get_surface_count() > 1:
				mi.set_surface_override_material(1, _wire_fill())
			var edges := MeshInstance3D.new()
			edges.mesh = _column_edges(hgt, sides)
			edges.material_override = _grid_material()
			col.add_child(edges)
		else:
			if ground_t == BattleMap.Terrain.ROAD:
				mi.set_surface_override_material(0, _road_material())
				mi.set_instance_shader_parameter("links", _road_links(h))
				mi.set_instance_shader_parameter("seed", float(h.x * 131 + h.y * 7919))
			else:
				mi.set_surface_override_material(0, _terrain_material(TILE[ground_t], 1.0 if ground_t == BattleMap.Terrain.WATER else 0.0))
			if mi.mesh.get_surface_count() > 1:
				mi.set_surface_override_material(1, rock)
		col.add_child(mi)
		if in_field and not (map.gate_hexes.has(h) or map.wall_hexes.has(h)):
			# The grid is the display's own light, drawn on the ground in the scene so a
			# raised hex hides the lines behind it and the bleed takes them with the column.
			var grid := MeshInstance3D.new()
			grid.mesh = _grid_mesh(hgt + 0.35)
			grid.material_override = _grid_material()
			grid.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			col.add_child(grid)
		rng.seed = h.x * 131 + h.y * 7919
		if wire:
			continue
		match t:
			BattleMap.Terrain.MOUNTAIN:
				_crag(col, ground_t, hgt, rng)
			BattleMap.Terrain.RUINS:
				# Broken blocks and a couple of standing wall stubs.
				var rubble := _terrain_material("rubble")
				for k in range(5):
					var b := BoxMesh.new()
					b.size = Vector3(rng.randf_range(5, 12), rng.randf_range(3, 12), rng.randf_range(4, 9))
					_prop(col, b, rubble, Vector3(rng.randf_range(-18, 18), hgt + b.size.y * 0.5, rng.randf_range(-13, 13)), Vector3(0.0, rng.randf_range(0, TAU), 0.0))
				for k in range(2):
					var wall_stub := BoxMesh.new()
					wall_stub.size = Vector3(rng.randf_range(10, 18), rng.randf_range(14, 24), 2.5)
					_prop(col, wall_stub, rubble, Vector3(rng.randf_range(-14, 14), hgt + wall_stub.size.y * 0.5, rng.randf_range(-10, 10)), Vector3(0.0, rng.randf_range(0, TAU), 0.0))
			BattleMap.Terrain.ROUGH:
				# Wasteland: dead trees and boulders, the parallel of the other world's forest.
				for k in range(rng.randi_range(2, 4)):
					_dead_tree(col, Vector3(rng.randf_range(-18, 18), hgt, rng.randf_range(-14, 14)), rng)
				for k in range(rng.randi_range(1, 3)):
					var boulder := SphereMesh.new()
					boulder.radius = rng.randf_range(3.0, 6.0)
					boulder.height = boulder.radius * 1.6
					boulder.radial_segments = 6
					boulder.rings = 3
					_prop(col, boulder, rock, Vector3(rng.randf_range(-16, 16), hgt + boulder.radius * 0.6, rng.randf_range(-12, 12)), Vector3(0.0, rng.randf_range(0, TAU), 0.0))


## The blocking crag on a tile, in the ground's own idiom: rock spikes on dirt and water,
## broken towers on ruins, mesas on wasteland (Ryan, 21 September). All overflow the tile's
## height so they read as things you fly over.
func _crag(col: Node3D, ground_t: int, hgt: float, rng: RandomNumberGenerator) -> void:
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
					var b := BoxMesh.new()
					var frac := 1.0 - 0.22 * step
					b.size = Vector3(w * frac, tall / 3.0, w * frac * rng.randf_range(0.7, 1.0))
					_prop(col, b, rubble, Vector3(ox + rng.randf_range(-1.0, 1.0), hgt + tall / 6.0 + step * tall / 3.0, oz + rng.randf_range(-1.0, 1.0)))
				if k == 0:
					var win := BoxMesh.new()
					win.size = Vector3(w * 0.7, 2.0, 0.6)
					var wm := StandardMaterial3D.new()
					wm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
					wm.albedo_color = Color(0.9, 0.7, 0.35)
					wm.emission_enabled = true
					wm.emission = Color(0.9, 0.7, 0.35)
					wm.emission_energy_multiplier = 1.2
					for wz in [tall * 0.35, tall * 0.55]:
						var wi := MeshInstance3D.new()
						wi.mesh = win
						wi.material_override = wm
						wi.position = Vector3(ox, hgt + wz, oz - w * 0.5 * rng.randf_range(0.8, 1.0))
						col.add_child(wi)
		BattleMap.Terrain.ROUGH:
			# Mesas: flat-topped blocks stacked and offset, a badland.
			var rock := _terrain_material("rock")
			for k in range(3):
				var tall := rng.randf_range(30.0, 46.0) if k == 0 else rng.randf_range(18.0, 30.0)
				var ox := 0.0 if k == 0 else rng.randf_range(-16.0, 16.0)
				var oz := 0.0 if k == 0 else rng.randf_range(-12.0, 12.0)
				for step in range(2):
					var slab := CylinderMesh.new()
					slab.radial_segments = 6
					slab.top_radius = rng.randf_range(10.0, 15.0) * (0.8 if step == 1 else 1.0)
					slab.bottom_radius = slab.top_radius * 1.15
					slab.height = tall * (0.6 if step == 0 else 0.4)
					_prop(col, slab, rock, Vector3(ox, hgt + slab.height * 0.5 + (tall * 0.6 if step == 1 else 0.0), oz), Vector3(0.0, rng.randf_range(0, TAU), 0.0))
		_:
			# Rock spikes, leaning, filling the tile.
			var rock_dark := _terrain_material("rock")
			for k in range(6):
				var spike := CylinderMesh.new()
				spike.top_radius = 0.8
				spike.bottom_radius = rng.randf_range(9.0, 14.0)
				spike.height = rng.randf_range(40.0, 56.0) if k == 0 else rng.randf_range(22.0, 40.0)
				spike.radial_segments = 4
				var a := k * TAU / 5.0 + rng.randf_range(-0.4, 0.4)
				var dist := 0.0 if k == 0 else rng.randf_range(14.0, 22.0)
				_prop(col, spike, rock_dark, Vector3(cos(a) * dist, hgt + spike.height * 0.5 - 1.0, sin(a) * dist),
					Vector3(rng.randf_range(-0.18, 0.18), rng.randf_range(0, TAU), rng.randf_range(-0.18, 0.18)))


## A dead tree: a bare trunk, thick at the foot, with a few stub branches, inked.
func _dead_tree(col: Node3D, at: Vector3, rng: RandomNumberGenerator) -> void:
	var bark := _lit(Color("2e2a26"))
	var tall := rng.randf_range(16.0, 28.0)
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.9
	trunk.bottom_radius = 2.4
	trunk.height = tall
	trunk.radial_segments = 5
	_prop(col, trunk, bark, at + Vector3(0.0, tall * 0.5, 0.0), Vector3(0.0, 0.0, rng.randf_range(-0.12, 0.12)))
	for k in range(rng.randi_range(2, 4)):
		var branch := BoxMesh.new()
		branch.size = Vector3(rng.randf_range(6.0, 12.0), 1.4, 1.4)
		_prop(col, branch, bark, at + Vector3(branch.size.x * 0.4, tall * rng.randf_range(0.5, 0.9), 0.0),
			Vector3(0.0, rng.randf_range(0, TAU), rng.randf_range(0.3, 0.8)))


var _wire_mat: StandardMaterial3D = null

## The wireframe trial's ground: near-black glass, so only the lines and the units show.
func _wire_fill() -> StandardMaterial3D:
	if _wire_mat == null:
		_wire_mat = StandardMaterial3D.new()
		_wire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_wire_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		_wire_mat.albedo_color = Color(0.02, 0.05, 0.03, 1.0)
	return _wire_mat


## A column's vertical edges as lines, for the wireframe trial.
func _column_edges(h: float, sides: Array) -> ArrayMesh:
	var corners := Hex.corners(Vector2.ZERO, hex_px - 0.75)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	var n := corners.size()
	for i in range(n):
		if sides[i] or sides[(i - 1 + n) % n]:
			st.add_vertex(_world(corners[i], 0.0))
			st.add_vertex(_world(corners[i], h))
	if absf(h) > 0.01:
		for i in range(n):
			st.add_vertex(_world(corners[i], 0.0))
			st.add_vertex(_world(corners[(i + 1) % n], 0.0))
	return st.commit()


func _model(id: String, maker: String, paint: Dictionary = {}) -> Node3D:
	var scene: PackedScene = load("res://art/models/%s.glb" % id)
	var node: Node3D = scene.instantiate()
	MechView3D.toon(node, maker, "clean", paint, false)
	return node


func _build_structures() -> void:
	var map := field.map
	if MechView3D.has_model("gate"):
		var g := _model("gate", "arsenal")
		_marker(g)   # ink on its creases, so the towers and reveals read as geometry
		g.position = _hex_world(map.gate)
		g.rotation.y = PI   # turned about, so its portcullis face is the one the player sees
		add_child(g)
		_structs.append([map.gate, g])
	if MechView3D.has_model("wall"):
		# The wall runs the whole width of the view, margin included: the field is a window
		# on a longer line.
		var bottom: Array = []
		for w in map.wall_hexes:
			if Hex.axial_to_offset(w).y == map.height - 1:
				bottom.append(w)
		for mh in map.margin.keys():
			if Hex.axial_to_offset(mh).y == map.height - 1:
				bottom.append(mh)
		for w in bottom:
			var m := _model("wall", "arsenal")
			_marker(m)
			m.position = _hex_world(w)
			m.rotation.y = PI
			add_child(m)
			_structs.append([w, m])


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	_camera.near = 1.0
	_camera.far = 4000.0
	add_child(_camera)
	_aim()


## Collapse the columns and structures under the bleed (where the other world has reached,
## height goes), then put every mech where the field says it is, on top of its column and
## turned to its facing.
func sync() -> void:
	var grad := Bleed.gradient(field, _origin, hex_px)
	var src := Bleed.sources(field, _origin, hex_px)
	var map := field.map
	for h in _columns.keys():
		var s := Bleed.standing(Bleed.at(_origin + Hex.to_pixel(h, hex_px), grad, src))
		(_columns[h] as Node3D).scale.y = maxf(0.02, s)
		_lift[h] = _height_of(h) * s * _cos * _ppu
	for st in _structs:
		(st[1] as Node3D).scale.y = maxf(0.02, Bleed.standing(Bleed.at(_origin + Hex.to_pixel(st[0], hex_px), grad, src)))
	var seen := {}
	for u in field.units:
		seen[u.id] = true
		var node: Node3D = _units.get(u.id, null)
		if node == null:
			node = _make_unit(u)
			if node == null:
				continue
			add_child(node)
			_units[u.id] = node
			_phase[u.id] = float(u.id) * 1.7
		_base[u.id] = _hex_world(u.pos, _lift.get(u.pos, 0.0) / (_cos * _ppu))
		node.position = _base[u.id]
		if _shadows.has(u.id):
			(_shadows[u.id] as Node3D).position = _base[u.id] + Vector3(0.0, 0.3, 0.0)
		if u.is_player() and not u.is_static() and _pivots.has(u.id):
			# The model faces -Z (north) at rest; screen-down is +Z, so the facing turns the
			# other way from the pixel direction. The pivot turns; the seat's southward set
			# above it does not.
			var d: Vector2 = Hex.to_pixel(Hex.DIRECTIONS[u.facing], 1.0).normalized()
			(_pivots[u.id] as Node3D).rotation.y = atan2(-d.x, -d.y)
	for uid in _units.keys():
		if not seen.has(uid):
			_units[uid].queue_free()
			_units.erase(uid)
			_pivots.erase(uid)
			_base.erase(uid)
			if _shadows.has(uid):
				_shadows[uid].queue_free()
				_shadows.erase(uid)


## Only a flyer moves at rest: it rides a slow swell, each on its own beat. A grounded
## machine holds still; its idle will be joint motion, the same as the skirmish's, once the
## joints exist (Ryan, 21 September).
func _process(delta: float) -> void:
	_time += delta
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
		var node := _model(MechView3D.model_for(u.chassis_id, "badger"), maker, u.paint)
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
			sh.material_override = sm
			sh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(sh)
			_shadows[u.id] = sh
		return pivot
	return null   # foes and static units are drawn flat by the map view


## On the map a mech is the same textured model as the skirmish, traced in light so it
## still reads at one hex.
func _marker(node: Node) -> void:
	for child in node.find_children("*", "MeshInstance3D", true, false):
		_trace(child)


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
