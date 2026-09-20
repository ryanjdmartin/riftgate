class_name Map3D
extends SubViewport

## The battlefield in 3D (decided 19 September). The hex ground, the gate and walls, and the
## player's mechs are real geometry under an orthographic camera pitched like the map tokens.
## Foes are never here: they are flat pictures the map view draws over this viewport's
## texture, with no 3D cues, because they are the other world showing through. The ground is
## stretched in depth so every hex projects exactly onto the 2D grid the overlays and gestures
## already use: the overlays did not have to change, only what is under them.

const PITCH := 42.0            # the map tokens' tilt
const HEX_WORLD := 35.0        # a hex's circumradius in model units: a mech is about one hex wide
const CAMERA_DISTANCE := 900.0

const TERRAIN := {
	BattleMap.Terrain.PLAIN: Color("2a3628"),
	BattleMap.Terrain.ROAD: Color("46422f"),
	BattleMap.Terrain.ROUGH: Color("3a3824"),
	BattleMap.Terrain.RUINS: Color("393c39"),
	BattleMap.Terrain.WATER: Color("1a2f4a"),
	BattleMap.Terrain.MOUNTAIN: Color("23212a"),
}

var field: Battlefield
var hex_px: float = 44.0        # the 2D view's HEX_SIZE, so the projection lands on its grid
var _ppu: float = 1.0           # screen pixels per model unit
var _sin: float = 1.0
var _origin := Vector2.ZERO     # where hex (0,0) sits in this viewport, in pixels
var _camera: Camera3D
var _units: Dictionary = {}     # unit id -> Node3D
var _statics: Array = []


func setup(f: Battlefield, view_size: Vector2, origin: Vector2, hex_size: float) -> void:
	field = f
	hex_px = hex_size
	_origin = origin
	_ppu = hex_px / HEX_WORLD
	_sin = sin(deg_to_rad(PITCH))
	size = Vector2i(int(view_size.x), int(view_size.y))
	own_world_3d = true
	transparent_bg = true
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	msaa_3d = SubViewport.MSAA_4X
	canvas_item_default_texture_filter = SubViewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_build_light()
	_build_ground()
	_build_structures()
	_build_camera()
	sync()


## A sun from the north-west and a little ambient, for the props; the mechs and structures
## carry their own toon light.
func _build_light() -> void:
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.4
	sun.rotation_degrees = Vector3(-55.0, 35.0, 0.0)
	add_child(sun)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0, 0, 0, 0)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("6a7a8a")
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)


## World position of a 2D pixel offset from hex (0,0): x as is, depth stretched so the
## pitched camera compresses it back to the 2D grid.
func _world(px: Vector2, height: float = 0.0) -> Vector3:
	return Vector3(px.x / _ppu, height, px.y / (_ppu * _sin))


func _hex_world(h: Vector2i, height: float = 0.0) -> Vector3:
	return _world(Hex.to_pixel(h, hex_px), height)


## Ground colour: unshaded so the palette stays exact, and two-sided so the winding of a
## hand-built polygon never matters.
func _flat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.albedo_color = color
	return m


## A prop (a peak, rubble, a rock): lit, so its faces read as volume.
func _lit(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 1.0
	return m


## One hex of ground as a flat polygon, with a darker rim just under it for the grid.
func _hex_mesh(inset: float) -> ArrayMesh:
	var corners := Hex.corners(Vector2.ZERO, hex_px - inset)
	var verts := PackedVector3Array()
	var idx := PackedInt32Array()
	for c in corners:
		verts.append(_world(c))
	for i in range(1, corners.size() - 1):
		idx.append_array([0, i + 1, i])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = idx
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _build_ground() -> void:
	var fill := _hex_mesh(1.5)
	var rim := _hex_mesh(0.0)
	var rim_mat := _flat(Color(Palette.HUD, 0.10).blend(Palette.BG))
	var map := field.map
	var rng := RandomNumberGenerator.new()
	for h in map.all_hexes():
		var t: int = map.terrain[h]
		var at := _hex_world(h)
		# Water sits a step below the ground, rim and all, so its bank shows as a dark edge.
		var drop := Vector3(0, -4.0, 0) if t == BattleMap.Terrain.WATER else Vector3.ZERO
		var r := MeshInstance3D.new()
		r.mesh = rim
		r.material_override = rim_mat
		r.position = at + drop + Vector3(0, -0.2, 0)
		add_child(r)
		var g := MeshInstance3D.new()
		g.mesh = fill
		g.material_override = _flat(TERRAIN[t])
		g.position = at + drop
		add_child(g)
		rng.seed = h.x * 131 + h.y * 7919
		match t:
			BattleMap.Terrain.MOUNTAIN:
				var cone := CylinderMesh.new()
				cone.top_radius = 2.0
				cone.bottom_radius = HEX_WORLD * 0.62
				cone.height = 26.0 + rng.randf_range(-4.0, 6.0)
				cone.radial_segments = 6
				var mi := MeshInstance3D.new()
				mi.mesh = cone
				mi.material_override = _lit(TERRAIN[t].lightened(0.18))
				mi.position = at + Vector3(rng.randf_range(-3, 3), cone.height * 0.5, rng.randf_range(-2, 2))
				add_child(mi)
			BattleMap.Terrain.RUINS:
				for k in range(3):
					var b := BoxMesh.new()
					b.size = Vector3(rng.randf_range(6, 12), rng.randf_range(4, 14), rng.randf_range(5, 9))
					var mi := MeshInstance3D.new()
					mi.mesh = b
					mi.material_override = _lit(TERRAIN[t].lightened(0.25))
					mi.position = at + Vector3(rng.randf_range(-16, 16), b.size.y * 0.5, rng.randf_range(-12, 12))
					add_child(mi)
			BattleMap.Terrain.ROUGH:
				for k in range(4):
					var b := BoxMesh.new()
					b.size = Vector3(rng.randf_range(3, 6), rng.randf_range(2, 5), rng.randf_range(3, 6))
					var mi := MeshInstance3D.new()
					mi.mesh = b
					mi.material_override = _lit(TERRAIN[t].darkened(0.25))
					mi.position = at + Vector3(rng.randf_range(-18, 18), b.size.y * 0.5, rng.randf_range(-14, 14))
					mi.rotation.y = rng.randf_range(0, TAU)
					add_child(mi)
			BattleMap.Terrain.ROAD:
				var b := BoxMesh.new()
				b.size = Vector3(HEX_WORLD * 0.55, 0.3, HEX_WORLD * 1.5 / _sin)
				var mi := MeshInstance3D.new()
				mi.mesh = b
				mi.material_override = _flat(TERRAIN[t].lightened(0.12))
				mi.position = at + Vector3(0, 0.2, 0)
				add_child(mi)


func _model(id: String, maker: String, paint: Dictionary = {}) -> Node3D:
	var scene: PackedScene = load("res://art/models/%s.glb" % id)
	var node: Node3D = scene.instantiate()
	MechView3D.toon(node, maker, "clean", paint, false)
	return node


func _build_structures() -> void:
	var map := field.map
	if MechView3D.has_model("gate"):
		var g := _model("gate", "arsenal")
		g.position = _hex_world(map.gate)
		g.rotation.y = PI   # facing north
		add_child(g)
	if MechView3D.has_model("wall"):
		for w in map.wall_hexes:
			if Hex.axial_to_offset(w).y != map.height - 1:
				continue   # the structures are GATE_ROWS deep; the models stand on the bottom row only
			var m := _model("wall", "arsenal")
			m.position = _hex_world(w)
			m.rotation.y = PI
			add_child(m)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	_camera.size = float(size.y) / _ppu
	_camera.near = 1.0
	_camera.far = 4000.0
	# The point that must land on the viewport's centre: hex (0,0) sits at `_origin`.
	var target := _world(Vector2(size.x * 0.5, size.y * 0.5) - _origin)
	var back := Vector3(0.0, _sin, cos(deg_to_rad(PITCH)))
	add_child(_camera)
	_camera.look_at_from_position(target + back * CAMERA_DISTANCE, target, Vector3.UP)


## Put every mech where the field says it is, as a model turned to its facing.
func sync() -> void:
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
		node.position = _hex_world(u.pos)
		if u.is_player() and not u.is_static():
			var d: Vector2 = Hex.to_pixel(Hex.DIRECTIONS[u.facing], 1.0).normalized()
			node.rotation.y = atan2(d.x, d.y)
	for uid in _units.keys():
		if not seen.has(uid):
			_units[uid].queue_free()
			_units.erase(uid)


func _make_unit(u: Unit) -> Node3D:
	if u.is_player() and not u.is_static():
		var maker := str(ContentDB.load_default().chassis.get(u.chassis_id, {}).get("maker", "minerva"))
		return _model(MechView3D.model_for(u.chassis_id, "badger"), maker, u.paint)
	return null   # foes and static units are drawn flat by the map view
