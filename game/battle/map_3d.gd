class_name Map3D
extends SubViewport

## The battlefield in 3D (decided 19 September). Every hex is a column with a real height by
## terrain (elevation decided 20 September: it is real, and it will come to matter), the gate
## and walls are models, and the player's mechs are toon models, all under an orthographic
## camera pitched like the map tokens, with one sun casting shadows. Foes are never here:
## they are flat pictures the map view draws over this viewport's texture, with no 3D cues,
## because they are the other world showing through. The ground is stretched in depth so a
## hex at ground level projects exactly onto the 2D grid the overlays and gestures use; a
## raised hex's top sits higher on screen by `lift`, and the overlays ask for it.

const PITCH := 42.0            # the map tokens' tilt
const HEX_WORLD := 35.0        # a hex's circumradius in model units: a mech is about one hex wide
const CAMERA_DISTANCE := 900.0
const MARKER_FIT := 1.05       # a mech's widest extent, in hex widths, on the map
const HOVER := 8.0             # a flyer rides this far above the ground, in model units

const TERRAIN := {
	BattleMap.Terrain.PLAIN: Color("2a3628"),
	BattleMap.Terrain.ROAD: Color("46422f"),
	BattleMap.Terrain.ROUGH: Color("3a3824"),
	BattleMap.Terrain.RUINS: Color("393c39"),
	BattleMap.Terrain.WATER: Color("1a2f4a"),
	BattleMap.Terrain.MOUNTAIN: Color("23212a"),
}

## The top of each terrain's column in model units. Water is sunk, so its far bank shows.
const HEIGHT := {
	BattleMap.Terrain.PLAIN: 0.0,
	BattleMap.Terrain.ROAD: 0.0,
	BattleMap.Terrain.ROUGH: 3.0,
	BattleMap.Terrain.RUINS: 5.0,
	BattleMap.Terrain.WATER: -4.0,
	BattleMap.Terrain.MOUNTAIN: 12.0,
}

var field: Battlefield
var hex_px: float = 44.0        # the 2D view's HEX_SIZE, so the projection lands on its grid
var painted: Texture2D          # the gritty ground texture the columns' tops wear (PaintedMap "ground")
var _ppu: float = 1.0           # screen pixels per model unit
var _sin: float = 1.0
var _cos: float = 1.0
var _origin := Vector2.ZERO     # where hex (0,0) sits in this viewport, in pixels
var _camera: Camera3D
var _units: Dictionary = {}     # unit id -> Node3D
var _rise: Dictionary = {}      # unit id -> how far up the model sits so its lowest point is on the ground
var _base_size := Vector2.ZERO  # the map in 1x pixels; `size` is this times render_scale
var render_scale: float = 1.0   # 2 when zoomed in, so the reconstruction shows more, not bigger texels
var _columns: Dictionary = {}   # hex -> Node3D: the column and its props, collapsed by the bleed
var _structs: Array = []        # [[hex, Node3D], ...] the gate and walls, collapsed the same way
var _lift: Dictionary = {}      # hex -> how far above its grid cell the top sits on screen, in px


func setup(f: Battlefield, view_size: Vector2, origin: Vector2, hex_size: float, ground_tex: Texture2D) -> void:
	field = f
	painted = ground_tex
	hex_px = hex_size
	_origin = origin
	_ppu = hex_px / HEX_WORLD
	_sin = sin(deg_to_rad(PITCH))
	_cos = cos(deg_to_rad(PITCH))
	_base_size = view_size
	size = Vector2i(int(view_size.x), int(view_size.y))
	own_world_3d = true
	transparent_bg = true
	render_target_update_mode = SubViewport.UPDATE_ONCE   # the map view asks for a frame when something changed
	msaa_3d = SubViewport.MSAA_4X
	canvas_item_default_texture_filter = SubViewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_build_light()
	_build_ground()
	_build_structures()
	_build_camera()
	sync()


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
	e.glow_intensity = 0.5
	e.glow_bloom = 0.05
	e.glow_hdr_threshold = 1.0
	env.environment = e
	add_child(env)


## Render at `k` times the map's pixel size (1 or 2) and ask for a frame.
func set_render_scale(k: float) -> void:
	render_scale = k
	size = Vector2i(_base_size * k)
	if _camera != null:
		_camera.size = float(size.y) / (_ppu * render_scale)
	redraw()


## The scene renders once per change, never per frame: the map view calls this whenever it
## redraws.
func redraw() -> void:
	render_target_update_mode = SubViewport.UPDATE_ONCE


## World position of a 2D pixel offset from hex (0,0): x as is, depth stretched so the
## pitched camera compresses it back to the 2D grid.
func _world(px: Vector2, height: float = 0.0) -> Vector3:
	return Vector3(px.x / _ppu, height, px.y / (_ppu * _sin))


func _hex_world(h: Vector2i, height: float = 0.0) -> Vector3:
	return _world(Hex.to_pixel(h, hex_px), height)


## How far above its grid cell a hex's top sits on screen right now, in pixels (negative
## when sunk). The overlays add it so routes, plaques and taps follow the terrain.
func lift(h: Vector2i) -> float:
	return _lift.get(h, 0.0)


## Flat colour: unshaded so the palette stays exact, two-sided so winding never matters.
func _flat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.albedo_color = color
	return m


## Lit, matte, two-sided: props and the columns' sides.
func _lit(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 1.0
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


## The columns' tops sample the gritty ground texture by world position (ground.gdshader),
## lit, so the sun and the shadows read on them.
func _ground_material() -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = load("res://game/battle/ground.gdshader")
	m.set_shader_parameter("painted", painted)
	m.set_shader_parameter("origin", _origin)
	m.set_shader_parameter("map_size", _base_size)
	m.set_shader_parameter("ppu", _ppu)
	m.set_shader_parameter("sin_pitch", _sin)
	return m


## One hex of flat ground as a polygon: the dark rim under the columns, for the grid gaps.
func _hex_mesh(inset: float) -> ArrayMesh:
	var corners := Hex.corners(Vector2.ZERO, hex_px - inset)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(1, corners.size() - 1):
		st.set_normal(Vector3.UP)
		st.add_vertex(_world(corners[0]))
		st.set_normal(Vector3.UP)
		st.add_vertex(_world(corners[i + 1]))
		st.set_normal(Vector3.UP)
		st.add_vertex(_world(corners[i]))
	return st.commit()


## A hex column: surface 0 is the top at `h`, surface 1 its six sides from the ground to
## `h` (absent when flat). Normals are explicit, outward for a raised column and inward for
## a sunk one, since it is the sunk hex's far bank that faces the camera.
func _column_mesh(h: float) -> ArrayMesh:
	var corners := Hex.corners(Vector2.ZERO, hex_px - 0.75)
	var top: Array[Vector3] = []
	for c in corners:
		top.append(_world(c, h))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(1, corners.size() - 1):
		for v in [top[0], top[i + 1], top[i]]:
			st.set_normal(Vector3.UP)
			st.add_vertex(v)
	var mesh := st.commit()
	if absf(h) < 0.01:
		return mesh
	var ss := SurfaceTool.new()
	ss.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := corners.size()
	for i in range(n):
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
	var ground_mat := _ground_material()
	var map := field.map
	var rng := RandomNumberGenerator.new()
	for h in map.all_hexes():
		var t: int = map.terrain[h]
		var at := _hex_world(h)
		var hgt: float = HEIGHT[t]
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
		var mi := MeshInstance3D.new()
		mi.mesh = _column_mesh(hgt)
		mi.set_surface_override_material(0, ground_mat)
		if mi.mesh.get_surface_count() > 1:
			mi.set_surface_override_material(1, _lit(TERRAIN[t].lightened(0.22)))
		col.add_child(mi)
		rng.seed = h.x * 131 + h.y * 7919
		match t:
			BattleMap.Terrain.MOUNTAIN:
				var cone := CylinderMesh.new()
				cone.top_radius = 2.0
				cone.bottom_radius = HEX_WORLD * 0.62
				cone.height = 22.0 + rng.randf_range(-4.0, 6.0)
				cone.radial_segments = 6
				var pk := MeshInstance3D.new()
				pk.mesh = cone
				pk.material_override = _lit(TERRAIN[t].lightened(0.18))
				pk.position = Vector3(rng.randf_range(-3, 3), hgt + cone.height * 0.5, rng.randf_range(-2, 2))
				col.add_child(pk)
			BattleMap.Terrain.RUINS:
				for k in range(3):
					var b := BoxMesh.new()
					b.size = Vector3(rng.randf_range(6, 12), rng.randf_range(4, 14), rng.randf_range(5, 9))
					var bi := MeshInstance3D.new()
					bi.mesh = b
					bi.material_override = _lit(TERRAIN[t].lightened(0.25))
					bi.position = Vector3(rng.randf_range(-16, 16), hgt + b.size.y * 0.5, rng.randf_range(-12, 12))
					col.add_child(bi)
			BattleMap.Terrain.ROUGH:
				for k in range(4):
					var b := BoxMesh.new()
					b.size = Vector3(rng.randf_range(3, 6), rng.randf_range(2, 5), rng.randf_range(3, 6))
					var bi := MeshInstance3D.new()
					bi.mesh = b
					bi.material_override = _lit(TERRAIN[t].darkened(0.25))
					bi.position = Vector3(rng.randf_range(-18, 18), hgt + b.size.y * 0.5, rng.randf_range(-14, 14))
					bi.rotation.y = rng.randf_range(0, TAU)
					col.add_child(bi)
			BattleMap.Terrain.ROAD:
				var b := BoxMesh.new()
				b.size = Vector3(HEX_WORLD * 0.55, 0.3, HEX_WORLD * 1.5 / _sin)
				var bi := MeshInstance3D.new()
				bi.mesh = b
				bi.material_override = _flat(TERRAIN[t].lightened(0.12))
				bi.position = Vector3(0, hgt + 0.2, 0)
				col.add_child(bi)


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
		_structs.append([map.gate, g])
	if MechView3D.has_model("wall"):
		for w in map.wall_hexes:
			if Hex.axial_to_offset(w).y != map.height - 1:
				continue   # the structures are GATE_ROWS deep; the models stand on the bottom row only
			var m := _model("wall", "arsenal")
			m.position = _hex_world(w)
			m.rotation.y = PI
			add_child(m)
			_structs.append([w, m])


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	_camera.size = float(size.y) / (_ppu * render_scale)
	_camera.near = 1.0
	_camera.far = 4000.0
	# The point that must land on the viewport's centre: hex (0,0) sits at `_origin`.
	var target := _world(_base_size * 0.5 - _origin)
	var back := Vector3(0.0, _sin, cos(deg_to_rad(PITCH)))
	add_child(_camera)
	_camera.look_at_from_position(target + back * CAMERA_DISTANCE, target, Vector3.UP)


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
		_lift[h] = HEIGHT[map.terrain[h]] * s * _cos * _ppu
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
		node.position = _hex_world(u.pos, _lift.get(u.pos, 0.0) / (_cos * _ppu) + _rise.get(u.id, 0.0))
		if u.is_player() and not u.is_static():
			# The model faces -Z (north) at rest; screen-down is +Z, so the facing turns the
			# other way from the pixel direction.
			var d: Vector2 = Hex.to_pixel(Hex.DIRECTIONS[u.facing], 1.0).normalized()
			node.rotation.y = atan2(-d.x, -d.y)
	for uid in _units.keys():
		if not seen.has(uid):
			_units[uid].queue_free()
			_units.erase(uid)


func _make_unit(u: Unit) -> Node3D:
	if u.is_player() and not u.is_static():
		var maker := str(ContentDB.load_default().chassis.get(u.chassis_id, {}).get("maker", "minerva"))
		var node := _model(MechView3D.model_for(u.chassis_id, "badger"), maker, u.paint)
		_marker(node)
		# Mechs are the reconstruction's markers, drawn at marker size: whatever the model's
		# true size, its footprint is fitted to about one hex.
		var aabb := _bounds(node)
		var widest := maxf(aabb.size.x, aabb.size.z)
		if widest > 0.0:
			node.scale = Vector3.ONE * (HEX_WORLD * 2.0 * MARKER_FIT / widest)
		# Stand it on its lowest point (a model's origin is wherever its author put it), and
		# let a flyer hover.
		_rise[u.id] = -aabb.position.y * node.scale.y + (HOVER if u.traits.has("flyer") else 0.0)
		return node
	return null   # foes and static units are drawn flat by the map view


## On the map a mech is the same textured model as the skirmish (Ryan, 21 September: one
## model everywhere, and the map zooms), with a dark inverted-hull outline so it still reads
## at one hex.
func _marker(node: Node) -> void:
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = child
		if mi.mesh == null:
			continue
		var hull := MeshInstance3D.new()
		hull.mesh = mi.mesh
		hull.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var om := StandardMaterial3D.new()
		om.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		om.cull_mode = BaseMaterial3D.CULL_FRONT
		om.grow = true
		om.grow_amount = 2.0
		om.albedo_color = Palette.BG
		hull.material_override = om
		mi.add_child(hull)


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
