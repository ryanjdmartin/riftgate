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


func test_a_debug_build_can_draw_the_map_without_its_traces() -> void:
	Settings.display["traces"] = true
	assert_eq(Map3D._first_trace_mode(), TraceLines.mode(), "the traces drawn by default")
	if OS.is_debug_build():   # the tests' build always is; a release build draws them whatever is saved
		Settings.display["traces"] = false
		assert_eq(Map3D._first_trace_mode(), "off", "TRACES off draws none (the phone's switch)")
		Settings.display["traces"] = true
