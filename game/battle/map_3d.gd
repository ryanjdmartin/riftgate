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

## The top of each terrain's column in model units. Water is sunk, so its far bank shows;
## a crag is a tall column with a spire on it, and only a flyer crosses it.
const HEIGHT := {
	BattleMap.Terrain.PLAIN: 0.0,
	BattleMap.Terrain.ROAD: 1.0,
	BattleMap.Terrain.ROUGH: 6.0,
	BattleMap.Terrain.RUINS: 9.0,
	BattleMap.Terrain.WATER: -5.0,
	BattleMap.Terrain.MOUNTAIN: 20.0,
}

## The tile each terrain's top wears (art/terrain/<name>.png); sides wear rock.
const TILE := {
	BattleMap.Terrain.PLAIN: "dirt",
	BattleMap.Terrain.ROAD: "concrete",
	BattleMap.Terrain.ROUGH: "gravel",
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
var _units: Dictionary = {}     # unit id -> Node3D, a pivot at the hex; the model hangs off it centred by its bounds
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
	e.glow_intensity = 0.5
	e.glow_bloom = 0.05
	e.glow_hdr_threshold = 1.0
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


## A terrain tile as a lit material sampled by world position (terrain.gdshader).
func _terrain_material(tile: String, ripple: float = 0.0) -> ShaderMaterial:
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
	_materials[tile] = m
	return m


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
		for v in [top[0], top[i + 1], top[i]]:
			st.set_normal(Vector3.UP)
			st.add_vertex(v)
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
	for h in map.all_hexes():
		if map.gate_hexes.has(h) or map.wall_hexes.has(h):
			continue   # the gate's rows are the structures' ground, not the field's
		var t: int = map.terrain[h]
		var at := _hex_world(h)
		var hgt: float = HEIGHT[t]
		# Which edges need a wall: those facing a neighbour at another height, or none.
		var sides: Array = []
		var here := Hex.to_pixel(h, hex_px)
		for i in range(corners.size()):
			var mid: Vector2 = (corners[i] + corners[(i + 1) % corners.size()]) * 0.5
			var across := here + mid * 2.0
			var other: float = -999.0
			for nb in Hex.neighbors(h):
				if map.has(nb) and Hex.to_pixel(nb, hex_px).distance_to(across) < hex_px * 0.5:
					other = HEIGHT[map.terrain[nb]] if not (map.gate_hexes.has(nb) or map.wall_hexes.has(nb)) else 0.0
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
		var mi := MeshInstance3D.new()
		mi.mesh = _column_mesh(hgt, sides)
		mi.set_surface_override_material(0, _terrain_material(TILE[t], 1.0 if t == BattleMap.Terrain.WATER else 0.0))
		if mi.mesh.get_surface_count() > 1:
			mi.set_surface_override_material(1, rock)
		col.add_child(mi)
		rng.seed = h.x * 131 + h.y * 7919
		match t:
			BattleMap.Terrain.MOUNTAIN:
				# The crag: a cluster of narrow leaning rock spikes, tall enough that nobody
				# but a flyer gets over it.
				var rock_dark := _lit(Color("3a383e"))
				for k in range(3):
					var spike := CylinderMesh.new()
					spike.top_radius = 0.6
					spike.bottom_radius = rng.randf_range(5.0, 8.0)
					spike.height = rng.randf_range(22.0, 38.0) if k == 0 else rng.randf_range(14.0, 26.0)
					spike.radial_segments = 4
					var pk := MeshInstance3D.new()
					pk.mesh = spike
					pk.material_override = rock_dark
					var a := rng.randf_range(0.0, TAU)
					var dist := 0.0 if k == 0 else rng.randf_range(8.0, 14.0)
					pk.position = Vector3(cos(a) * dist, hgt + spike.height * 0.5 - 1.0, sin(a) * dist)
					pk.rotation = Vector3(rng.randf_range(-0.18, 0.18), rng.randf_range(0, TAU), rng.randf_range(-0.18, 0.18))
					col.add_child(pk)
			BattleMap.Terrain.RUINS:
				for k in range(3):
					var b := BoxMesh.new()
					b.size = Vector3(rng.randf_range(6, 12), rng.randf_range(4, 14), rng.randf_range(5, 9))
					var bi := MeshInstance3D.new()
					bi.mesh = b
					bi.material_override = _lit(Color("5a5c60"))
					bi.position = Vector3(rng.randf_range(-16, 16), hgt + b.size.y * 0.5, rng.randf_range(-12, 12))
					col.add_child(bi)
			BattleMap.Terrain.ROUGH:
				for k in range(4):
					var b := BoxMesh.new()
					b.size = Vector3(rng.randf_range(3, 6), rng.randf_range(2, 5), rng.randf_range(3, 6))
					var bi := MeshInstance3D.new()
					bi.mesh = b
					bi.material_override = _lit(Color("3a3834"))
					bi.position = Vector3(rng.randf_range(-18, 18), hgt + b.size.y * 0.5, rng.randf_range(-14, 14))
					bi.rotation.y = rng.randf_range(0, TAU)
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
		g.rotation.y = PI   # turned about, so its portcullis face is the one the player sees
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
			_phase[u.id] = float(u.id) * 1.7
		_base[u.id] = _hex_world(u.pos, _lift.get(u.pos, 0.0) / (_cos * _ppu))
		node.position = _base[u.id]
		if _shadows.has(u.id):
			(_shadows[u.id] as Node3D).position = _base[u.id] + Vector3(0.0, 0.3, 0.0)
		if u.is_player() and not u.is_static():
			# The model faces -Z (north) at rest; screen-down is +Z, so the facing turns the
			# other way from the pixel direction.
			var d: Vector2 = Hex.to_pixel(Hex.DIRECTIONS[u.facing], 1.0).normalized()
			node.rotation.y = atan2(-d.x, -d.y)
	for uid in _units.keys():
		if not seen.has(uid):
			_units[uid].queue_free()
			_units.erase(uid)
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
		node.rotation.z = sin(_time * 1.6 + ph) * 0.035
		node.rotation.x = sin(_time * 1.1 + ph * 0.7) * 0.02
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
		var k := (HEX_WORLD * 2.0 * MARKER_FIT / widest) if widest > 0.0 else 1.0
		var flyer := u.traits.has("flyer")
		var pivot := Node3D.new()
		node.scale = Vector3.ONE * k
		node.position = Vector3(-aabb.get_center().x, -aabb.position.y, -aabb.get_center().z) * k + Vector3(0.0, HOVER if flyer else 0.0, 0.0)
		pivot.add_child(node)
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


## On the map a mech is the same textured model as the skirmish, with a dark inverted-hull
## outline so it still reads at one hex.
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
		om.grow_amount = 1.4
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
