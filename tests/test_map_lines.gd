extends TestCase

## The battle map's lines keep one width on screen at every zoom (Ryan, 30 October: "I don't
## want the outline to thicken as I zoom in"; the grid's lines thickened with it): the grid's
## ribbon carries how far in from the column's edge each corner is, which grid.gdshader turns
## into screen pixels, and the machines' outline is the compositor's, a width in design pixels,
## with no machine wearing the engine's.


func test_the_grid_ribbon_carries_its_distance_in() -> void:
	var m := Map3D.new()
	m.hex_px = 44.0
	m._ppu = m.hex_px / Map3D.HEX_WORLD
	m._sin = sin(deg_to_rad(Map3D.PITCH))
	var geo: Dictionary = m._grid_geo(0.0)
	var v: PackedVector3Array = geo["v"]
	var uv: PackedVector2Array = geo["uv"]
	assert_eq(uv.size(), v.size(), "a distance a corner")
	# Back to map pixels: the shader reads UV.x as map pixels square to the column's edge, so
	# each corner's must be its true distance from its edge's line.
	var px := func(p: Vector3) -> Vector2: return Vector2(p.x * m._ppu, p.z * m._ppu * m._sin)
	var worst := 0.0
	for t in range(0, v.size(), 6):
		var a: Vector2 = px.call(v[t])
		var edge: Vector2 = (px.call(v[t + 1]) - a).normalized()
		for k in range(6):
			var d := absf((px.call(v[t + k]) - a).cross(edge))
			worst = maxf(worst, absf(d - uv[t + k].x))
	assert_true(worst < 0.01, "every corner reads its distance in (off by %.3f at worst)" % worst)
	m.free()


func test_the_grid_line_is_a_width_on_screen() -> void:
	var m := Map3D.new()
	m._density = 1.5
	var mat := m._grid_material()
	assert_eq(mat.shader.resource_path, "res://game/battle/grid.gdshader", "the grid draws with its own shader")
	assert_true(is_equal_approx(float(mat.get_shader_parameter("line_px")), Map3D.GRID_W * 1.5), "GRID_W design pixels at the glass's density")
	assert_true(Map3D.GRID_RIBBON >= Map3D.GRID_INSET + Map3D.GRID_W + 1.0, "the ribbon holds the line and its smoothing at zoom 1 on a glass of the design's density")
	m.free()


func test_the_outline_is_a_width_on_screen() -> void:
	var was := OS.get_environment("RIFTGATE_OUTLINE")
	var ink := OS.get_environment("RIFTGATE_INK")
	OS.unset_environment("RIFTGATE_OUTLINE")
	OS.unset_environment("RIFTGATE_INK")
	assert_eq(Map3D.outline_px(), Map3D.OUTLINE, "design pixels, whatever the zoom")
	OS.set_environment("RIFTGATE_OUTLINE", "3.5")
	assert_eq(Map3D.outline_px(), 3.5, "RIFTGATE_OUTLINE sets it, to compare")
	OS.unset_environment("RIFTGATE_OUTLINE")
	OS.set_environment("RIFTGATE_INK", "light")
	assert_eq(Map3D.outline_px(), 0.0, "the trace modes that never outlined the player's things still do not")
	OS.unset_environment("RIFTGATE_INK")
	if not was.is_empty():
		OS.set_environment("RIFTGATE_OUTLINE", was)
	if not ink.is_empty():
		OS.set_environment("RIFTGATE_INK", ink)
	var code := (load("res://game/battle/bleed.gdshader") as Shader).code
	assert_true(code.contains("uniform vec4 boxes[%d];" % Map3D.MAX_BOXES), "the compositor holds Map3D.MAX_BOXES machines' boxes")


func test_no_machine_wears_the_engines_outline() -> void:
	# The engine's outline grew each flat face along its own normal, so it broke into pieces
	# round a machine, and it grew with the zoom. The compositor's replaced it on the map; the
	# skirmish and the codex never drew one.
	var node: Node = (load("res://art/models/%s.glb" % MechView3D.stand_in()) as PackedScene).instantiate()
	MechView3D.toon(node, ContentDB.load_default().makers.keys()[0], "clean")
	var outlined: Array = []
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = child
		for i in range(mi.get_surface_override_material_count()):
			var sm := mi.get_surface_override_material(i)
			if sm is BaseMaterial3D and int(sm.get("stencil_mode")) != BaseMaterial3D.STENCIL_MODE_DISABLED:
				outlined.append(str(mi.name))
	node.free()
	assert_true(outlined.is_empty(), "no part wears a stencil outline: %s" % str(outlined))


func test_the_marks_edges_carry_their_distance_in() -> void:
	# The ground marks' edges (Map3D.set_marks) are lines of one width on screen too, drawn by
	# mark_line.gdshader from the distance in each corner carries.
	var m := Map3D.new()
	m.hex_px = 44.0
	m._ppu = m.hex_px / Map3D.HEX_WORLD
	m._sin = sin(deg_to_rad(Map3D.PITCH))
	var arrays := m._edge_mesh(0.0, [0, 3]).surface_get_arrays(0)
	var v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	assert_eq(uv.size(), v.size(), "a distance a corner")
	var px := func(p: Vector3) -> Vector2: return Vector2(p.x * m._ppu, p.z * m._ppu * m._sin)
	var worst := 0.0
	for t in range(0, v.size(), 6):
		var a: Vector2 = px.call(v[t])
		var edge: Vector2 = (px.call(v[t + 1]) - a).normalized()
		for k in range(6):
			worst = maxf(worst, absf(absf((px.call(v[t + k]) - a).cross(edge)) - uv[t + k].x))
	assert_true(worst < 0.01, "every corner reads its distance in (off by %.3f at worst)" % worst)
	m.free()


func test_the_overlay_holds_its_size_at_every_zoom() -> void:
	# Ryan, 30 October: "all UI overlay type items should hold at one width". The map view
	# draws its marks in map space under the zoom, so a size given in screen pixels goes
	# through _px; a plaque is laid out in screen space at its place.
	var view := BattleMapView.new()
	view.size = Vector2(720.0, 1000.0)
	for z in [1.0, 1.7, 2.6]:
		view.zoom = z
		assert_true(is_equal_approx(view._px(3.0) * z, 3.0), "three screen pixels at zoom %.1f" % z)
	var r := view._plaque_rect(Vector2(10.0, 50.0), Vector2(60.0, 18.0))
	assert_eq(r.position.x, 4.0, "a plaque near the view's edge keeps inside it, in screen pixels")
	assert_eq(r.size, Vector2(60.0, 18.0), "and keeps its size")
	view.free()


func test_the_machines_layer_is_lit_by_the_sun() -> void:
	# The machines are drawn over the painting from their own layer, by a camera that sees that
	# layer alone, and a camera's cull mask hides the lights off its layers too: the sun and the
	# sheen stand on it, or a machine walking into the painting goes dark (Ryan, 16 November:
	# "There's weird shadows on mechs that move into the painted area").
	var m := Map3D.new()
	m._build_light()
	var units := 1 << (Map3D.UNITS_LAYER - 1)
	var suns := m.find_children("*", "DirectionalLight3D", true, false)
	assert_true(suns.size() > 0, "the map has a sun")
	for l in suns:
		assert_true(((l as DirectionalLight3D).layers & units) != 0, "%s lights the machines' layer" % l.name)
		assert_true(((l as DirectionalLight3D).layers & 1) != 0, "and the scene's")
	m.free()


## A chasm has a bottom in the machines' world (Ryan, 16 November: "for the machine world there
## should be like a barely visible bottom. Maybe some little rivers down there ... its not just a
## hole into nothing"): its rock darkens down its walls to a dim floor, and a gorge's stream runs on
## the floor through each chasm hex to the edge it shares with the next, one body of water.
func test_a_chasm_has_a_dim_floor_and_a_stream() -> void:
	var m := _chasm_map([Hex.offset_to_axial(4, 5), Hex.offset_to_axial(4, 5) + Hex.DIRECTIONS[0]])
	var a := Hex.offset_to_axial(4, 5)
	var b: Vector2i = a + Hex.DIRECTIONS[0]
	var rock := m._chasm_material("rock")
	assert_eq(float(rock.get_shader_parameter("fade_below")), Map3D.CHASM_DROP, "the rock darkens down to the floor")
	assert_true(float(rock.get_shader_parameter("fade_floor")) <= 0.5, "to a dim floor, barely seen")
	assert_true(Map3D.CHASM_STREAM_SHADE > 0.0 and Map3D.CHASM_STREAM_SHADE <= 0.25, "the stream faint, a fifth or so of the water's lit tone (Ryan, 24 November: \"the water in them fainter\")")
	assert_true(Map3D.CHASM_DROP <= -60.0, "the gorge deep (24 November: \"Machine gorges can be deeper\")")
	var gorges := m._gorges()
	assert_eq(gorges, [[a, b] if a < b else [b, a]], "the two chasm hexes one gorge")
	var polys := m._stream_polys(gorges[0])
	assert_eq(polys.size(), 1, "its water one body")
	var ca := m._hex_world(a)
	var cb := m._hex_world(b)
	assert_true(Geometry2D.is_point_in_polygon((Vector2(ca.x, ca.z) + Vector2(cb.x, cb.z)) * 0.5, polys[0]), "running over the edge the two share")
	assert_true(Geometry2D.is_point_in_polygon(Vector2(ca.x, ca.z), polys[0]) and Geometry2D.is_point_in_polygon(Vector2(cb.x, cb.z), polys[0]), "from the middle of one to the middle of the next")
	m.free()


## The water connects as water does (Ryan, 24 November: "Water should connect more fluidly with
## rounded vertices, it looks like a spiderweb now. If there's an enclosed section of river in a
## gorge, it should get filled in like a flooded section"): three chasm hexes round a corner close a
## loop, and what the loop closes round is water, one body with no hole; a fork's inside corners are
## rounded off, so nowhere in it does the outline turn sharply in.
func test_a_gorge_s_water_fills_what_it_closes_round() -> void:
	var a := Hex.offset_to_axial(4, 5)
	var b: Vector2i = a + Hex.DIRECTIONS[0]
	var c: Vector2i = a + Hex.DIRECTIONS[1]
	var m := _chasm_map([a, b, c])
	var polys := m._stream_polys(m._gorges()[0])
	assert_eq(polys.size(), 1, "one body of water")
	var mid := Vector2.ZERO
	for h in [a, b, c]:
		var w := m._hex_world(h)
		mid += Vector2(w.x, w.z) / 3.0
	assert_true(Geometry2D.is_point_in_polygon(mid, polys[0]), "the corner the three close round flooded")
	m.free()
	# A fork: a hex with three ways out, nowhere sharp on its inside.
	var f := Hex.offset_to_axial(4, 5)
	var fork := [f, f + Hex.DIRECTIONS[0], f + Hex.DIRECTIONS[2], f + Hex.DIRECTIONS[4]]
	var mf := _chasm_map(fork)
	var body: PackedVector2Array = mf._stream_polys(mf._gorges()[0])[0]
	var sharp := 0
	for i in range(body.size()):
		var p0 := body[(i + body.size() - 1) % body.size()]
		var p1 := body[i]
		var p2 := body[(i + 1) % body.size()]
		var turn := (p1 - p0).angle_to(p2 - p1)
		if absf(turn) > deg_to_rad(40.0):
			sharp += 1
	assert_eq(sharp, 0, "no sharp turn anywhere on its outline: round where the ways meet")
	mf.free()


## Not every gorge carries water (Ryan, 24 November: "Not every gorge needs water in it"): over a
## generated gorge map some gorges are dry and some wet, and one a flooded stretch spills into is
## always wet.
func test_some_gorges_are_dry_and_a_fed_one_never() -> void:
	var wet := 0
	var dry := 0
	var fed := 0
	for seed_value in [1, 2, 3]:
		var m := Map3D.new()
		m.hex_px = 44.0
		m._ppu = m.hex_px / Map3D.HEX_WORLD
		m._sin = sin(deg_to_rad(Map3D.PITCH))
		m.field = Battlefield.new(BattleMap.generate(9, 24, seed_value, "gorge"))
		for run in m._gorges():
			var spills := false
			for h in run:
				for d in Hex.DIRECTIONS:
					spills = spills or m.field.map.terrain_of(h + d) == BattleMap.Terrain.WATER
			if spills:
				fed += 1
				assert_true(m._gorge_wet(run), "a gorge a flooded stretch spills into carries water")
			elif m._gorge_wet(run):
				wet += 1
			else:
				dry += 1
		m.free()
	assert_true(wet > 0 and dry > 0, "some wet and some dry: %d wet, %d dry (%d fed)" % [wet, dry, fed])


## A Map3D over a flat map whose `pits` are chasm hexes, set up enough to lay their water.
func _chasm_map(pits: Array) -> Map3D:
	var m := Map3D.new()
	m.hex_px = 44.0
	m._ppu = m.hex_px / Map3D.HEX_WORLD
	m._sin = sin(deg_to_rad(Map3D.PITCH))
	var map := BattleMap.flat(9, 12)
	for h in pits:
		map.terrain[h] = BattleMap.Terrain.MOUNTAIN
		map.wall_look[h] = "chasms"
	m.field = Battlefield.new(map)
	return m


## Where a flooded stretch of the gorge meets a chasm, the chasm's wall there is a waterfall in the
## machines' world (Ryan, 16 November: "Is there any way to get a water tile on Gorge to waterfall if
## it touches a chasm?"): a sheet from the water's level down to the chasm's floor, its UV along the
## lip and down the fall, drawn by its own shader.
func test_a_flooded_stretch_falls_into_the_chasm_beside_it() -> void:
	var m := Map3D.new()
	m.hex_px = 44.0
	m._ppu = m.hex_px / Map3D.HEX_WORLD
	m._sin = sin(deg_to_rad(Map3D.PITCH))
	var geo := m._falls_geo([0], Map3D.CHASM_DROP)
	var v: PackedVector3Array = geo["v"]
	var uv: PackedVector2Array = geo["uv"]
	assert_eq(v.size(), 6, "one sheet on the one edge")
	var lo := INF
	var hi := -INF
	for p in v:
		lo = minf(lo, p.y)
		hi = maxf(hi, p.y)
	assert_eq([hi, lo], [Map3D.WATER_DROP, Map3D.CHASM_DROP], "from the water's level to the chasm's floor")
	var reach := Rect2(uv[0], Vector2.ZERO)
	for c in uv:
		reach = reach.expand(c)
	assert_eq(reach, Rect2(0.0, 0.0, 1.0, 1.0), "along the lip and down the fall")
	assert_eq(m._falls_material().shader.resource_path, "res://game/battle/waterfall.gdshader", "drawn as falling water")
	m.free()



## A hex's dressing lies down under a machine and stands up again as it goes (Ryan, 25 November: "The
## caches and terrain elements flickering in and out of existence when a frame moves through the hex
## is weird. There has to be a better way"): whole a step away, flat on it, eased between, the mesh
## squashed onto its ground rather than hidden.
func test_a_hex_s_dressing_lies_down_under_a_machine() -> void:
	var m := _chasm_map([])
	var h := Hex.offset_to_axial(4, 5)
	var n: Vector2i = h + Hex.DIRECTIONS[0]
	var at := MapOrient.to_pixel(h, m.hex_px)
	var next := MapOrient.to_pixel(n, m.hex_px)
	assert_eq(m.standing(h, []), 1.0, "nothing near: whole")
	assert_eq(m.standing(h, [at]), 0.0, "a machine on it: flat")
	assert_eq(m.standing(h, [next]), 1.0, "a machine on the next hex: whole")
	var between := m.standing(h, [at.lerp(next, 0.62)])
	assert_true(between > 0.0 and between < 1.0, "a machine on its way between: eased (%.2f)" % between)
	var mi := MeshInstance3D.new()
	m._prop_meshes[h] = [mi]
	m._flatten_props([at.lerp(next, 0.62)], {})
	assert_true(mi.visible, "part-way down it still shows")
	assert_true(absf(mi.transform.basis.get_scale().y - between) < 0.01, "squashed by as much")
	m._flatten_props([at], {})
	assert_false(mi.visible, "flat under the machine")
	m._flatten_props([], {h: true})
	assert_false(mi.visible, "a wreck's or a cache's hex keeps it flat")
	m._flatten_props([], {})
	assert_true(mi.visible and is_equal_approx(mi.transform.basis.get_scale().y, 1.0), "and it stands whole again once the machine has gone")
	mi.free()
	m.free()
