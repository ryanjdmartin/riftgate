extends TestCase

## The skirmish's field (Ryan, 29 October: "it's 100% field"): every domain's bleed has a
## backdrop and the painter is the same for a seed; one floor in both places the controls take
## ("Skirmish Controls", "bottom" or "middle"); the machines in fixed hexes of that floor, a
## smaller squad's spots left empty, each drawn through the floor's own camera; the foes' feet
## on their rank's line, what flies over its shadow, and the breathe planted at the feet.


func _screen(controls: String, team: Array = ["badger", "clydesdale", "sparrowhawk"]) -> SkirmishScreen:
	Settings.display["skirmish_controls"] = controls
	var db := ContentDB.load_default()
	var sk := Skirmish.new(3)
	for id in team:
		sk.add_mech(db.make_mech(id))
	var ghouls := Unit.pack(1, "ghouls", Vector2i.ZERO, "marsh", 2, 4, "revenant")
	sk.add_foes(db.foes_for(ghouls), ghouls)
	var screen := SkirmishScreen.new()
	screen.setup(sk)
	return screen


## A foe's view in a slot, holding a sprite whose opaque rows run from `top` to `bottom`.
func _foe_view(top: int, bottom: int) -> UnitView:
	var img := Image.create_empty(72, 96, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	img.fill_rect(Rect2i(20, top, 30, bottom - top), Color.WHITE)
	var v := UnitView.new()
	v.is_enemy = true
	v.size = SkirmishScreen.SLOT_SIZE
	v.sprite = ImageTexture.create_from_image(img)
	v.pixel_snap = true
	v.feet_y = SkirmishScreen.SLOT_SIZE.y - UnitView.STATUS_H
	return v


func test_every_domain_has_a_backdrop() -> void:
	# The palettes are keyed by a domain's bleed in content: a renamed bleed fails here until
	# the painter follows.
	var db := ContentDB.load_default()
	for fac in db.factions.keys():
		var bleed := str(db.factions[fac].get("bleed", ""))
		assert_true(BattleBackdrop.PALETTES.has(bleed), "%s's bleed %s has a backdrop" % [fac, bleed])


func test_the_backdrop_is_the_size_asked_and_the_same_for_a_seed() -> void:
	for biome in BattleBackdrop.PALETTES.keys():
		for t in BattleMap.TERRAIN_NAMES.keys():
			var img := BattleBackdrop.paint(str(biome), int(t), 5, Vector2i(180, 110), 30)
			assert_eq(img.get_size(), Vector2i(180, 110), "%s on %s is the size asked" % [biome, BattleMap.TERRAIN_NAMES[t]])
	var a := BattleBackdrop.paint("plains", BattleMap.Terrain.RUINS, 5, Vector2i(180, 110), 30)
	var b := BattleBackdrop.paint("plains", BattleMap.Terrain.RUINS, 5, Vector2i(180, 110), 30)
	assert_eq(a.get_data(), b.get_data(), "a seed paints the same backdrop every time")
	var c := BattleBackdrop.paint("plains", BattleMap.Terrain.RUINS, 6, Vector2i(180, 110), 30)
	assert_true(a.get_data() != c.get_data(), "another seed another")
	var first := str(BattleBackdrop.PALETTES.keys()[0])
	var unknown := BattleBackdrop.paint("no_such_bleed", BattleMap.Terrain.PLAIN, 5, Vector2i(180, 110), 30)
	var fallback := BattleBackdrop.paint(first, BattleMap.Terrain.PLAIN, 5, Vector2i(180, 110), 30)
	assert_eq(unknown.get_data(), fallback.get_data(), "a bleed with no palette paints the first")
	var rows := BattleBackdrop.paint("plains", BattleMap.Terrain.RUINS, 5, Vector2i(180, 110), 30, {"k": 900.0, "phase": 0.3})
	assert_true(rows.get_data() != a.get_data(), "the floor's bands follow the camera's rows when given")


func test_one_field_in_both_places_for_the_controls() -> void:
	var was: Variant = Settings.display.get("skirmish_controls", "middle")
	assert_eq(str(Settings.DISPLAY_DEFAULTS["skirmish_controls"]), "middle", "the controls start between the sides")
	for controls in Settings.SKIRMISH_CONTROLS:
		var s := _screen(controls)
		assert_eq(SkirmishScreen.controls(), controls, "the setting places the controls (%s)" % controls)
		assert_eq(s._bg.grounds.size(), 2, "one field in two layers (%s)" % controls)
		assert_eq(str(s._bg.grounds[0][3]), "backdrop", "the other world painted under it all")
		assert_eq(str(s._bg.grounds[1][3]), "floor", "our floor over it below the seam")
		var field: Rect2 = s._bg.grounds[0][0]
		assert_eq(field, s._bg.grounds[1][0], "both layers the same field")
		assert_true(field.position.y <= s.BACK_Y and field.end.y >= s.MECH_Y + SkirmishScreen.MECH_FOOT, "from over the back rank to under the machines' feet")
		assert_eq(s._bg.glass.is_empty(), controls == "bottom", "glass under a console that floats on the floor, none under one below it")
		s.free()
	Settings.display["skirmish_controls"] = was


func test_the_menu_moves_the_controls_mid_fight() -> void:
	# The settings page's Skirmish Controls row re-lays the fight it was opened over, at once.
	var was: Variant = Settings.display.get("skirmish_controls", "middle")
	var s := _screen("middle")
	var middle_y := s.MECH_Y
	s._open_menu()
	s._menu._show_page("settings")
	var labels := []
	for b in s._menu.find_children("*", "HudButton", true, false):
		labels.append((b as HudButton).text)
	assert_true(labels.has("MIDDLE") and labels.has("BOTTOM"), "the settings page offers both places")
	Settings.display["skirmish_controls"] = "bottom"   # what the row's button sets, kept off the settings file here
	s._menu.display_changed.emit("skirmish_controls", "bottom")
	assert_true(s.MECH_Y < middle_y, "the machines step up under the foes")
	assert_eq(s._mech_views.size(), 3, "the squad drawn again")
	assert_true(s._bg.glass.is_empty(), "the console off the floor")
	s.free()
	Settings.display["skirmish_controls"] = was


func test_the_controls_at_the_bottom_stand_the_machines_under_the_foes() -> void:
	var was: Variant = Settings.display.get("skirmish_controls", "middle")
	var s := _screen("middle")
	assert_true(s.DIE_Y < s.MECH_Y, "in the middle the dice sit between the foes and the machines")
	s.free()
	s = _screen("bottom")
	assert_true(s.MECH_Y >= s.FRONT_Y + SkirmishScreen.SLOT_SIZE.y, "at the bottom the machines stand under the front rank")
	assert_true(s.LOG_Y >= s.MECH_Y + SkirmishScreen.MECH_SIZE.y, "the log under the machines")
	assert_true(s.DIE_Y >= s.LOG_Y + SkirmishScreen.LOG_H, "the dice under the log")
	assert_true(s.REROLL_Y + SkirmishScreen.REROLL_SIZE.y <= s.BOTTOM_Y - 16.0, "Reroll clear of the bottom row")
	assert_eq(s.MECH_Y + SkirmishScreen.MECH_SIZE.y + SkirmishScreen.MECH_LOG_GAP + SkirmishScreen.CHIP_ROOM, s.LOG_Y, "the machines' row rests on the log, room for three rows of chips between (Ryan, 2 November)")
	var field: Rect2 = s._bg.grounds[0][0]
	assert_true(s.LOG_Y - field.end.y <= 12.0, "the field reaches down to the log: no black over it (Ryan, 29 October)")
	s.free()
	Settings.display["skirmish_controls"] = was


func test_the_quick_switch_moves_the_controls() -> void:
	# Ryan, 29 October: "a quick-switch that changes the control layout position", beside the eye.
	var was: Variant = Settings.display.get("skirmish_controls", "middle")
	var s := _screen("middle")
	assert_eq(s._switch.glyph, "controls_middle", "its glyph says where they sit")
	var middle_y := s.MECH_Y
	s._switch_controls()
	assert_eq(SkirmishScreen.controls(), "bottom", "a press moves them to the bottom, saved as the setting")
	assert_true(s.MECH_Y < middle_y, "the screen laid again around the fight")
	assert_eq(s._switch.glyph, "controls_bottom", "the new switch says so")
	s._switch_controls()
	assert_eq(SkirmishScreen.controls(), "middle", "and back")
	s.free()
	Settings.set_display("skirmish_controls", str(was))


func test_the_squad_stands_in_fixed_hexes() -> void:
	# Four spots whatever the squad: a squad of one or two in the middle ones, the outer spots
	# empty; three from the left (Ryan, 29 October). Each die in its machine's column.
	var was: Variant = Settings.display.get("skirmish_controls", "middle")
	var spots := {}
	var four: Array = []
	for team in [["badger"], ["badger", "clydesdale"], ["badger", "clydesdale", "sparrowhawk"], ["badger", "clydesdale", "sparrowhawk", "baboon"]]:
		var s := _screen("middle", team)
		var xs: Array = []
		for i in range(team.size()):
			var v: UnitView = s._mech_views[i]
			xs.append(v.position.x)
			var die_mid := s._dice[i].position.x + SkirmishScreen.DIE_SIZE * 0.5
			assert_true(absf(die_mid - (v.position.x + SkirmishScreen.MECH_SIZE.x * 0.5)) < 0.5, "die %d in its machine's column" % i)
			assert_eq(v.ground_at, Vector2(SkirmishScreen.MECH_SIZE.x * 0.5, SkirmishScreen.MECH_FOOT), "its shadow on its hex's centre")
		spots[team.size()] = xs
		var empty: Array = []
		for k in range(s._bg.marks.size()):
			if bool(s._bg.marks[k][1]):
				empty.append(k)
		assert_eq(s._bg.marks.size(), SkirmishScreen.SLOTS, "%d machines: the squad's spots all marked" % team.size())
		assert_eq(empty, {1: [0, 2, 3], 2: [0, 3], 3: [3], 4: []}[team.size()], "%d machines: the spots no machine fills left empty" % team.size())
		if team.size() == 4:
			for k in range(4):
				four.append(s._slot_x(k) - SkirmishScreen.MECH_SIZE.x * 0.5)
		s.free()
	assert_eq(spots[1], [four[1]], "one machine in the left of the middle spots")
	assert_eq(spots[2], [four[1], four[2]], "two in the middle spots")
	assert_eq(spots[3], [four[0], four[1], four[2]], "three from the left")
	assert_eq(spots[4], four, "four in all four")
	Settings.display["skirmish_controls"] = was


func test_the_machines_turn_toward_the_middle() -> void:
	# Ryan, 29 October: "player units on the left side can face slightly to the right, and units
	# on the right can face slightly left". MechView3D's turn is positive to the machine's left: a
	# yaw that swings the nose (away from the camera, -Z) toward -X, the screen's left.
	var was: Variant = Settings.display.get("skirmish_controls", "middle")
	var s := _screen("middle", ["badger", "clydesdale", "sparrowhawk", "baboon"])
	assert_eq([s._mech_turn(0), s._mech_turn(1)], [-SkirmishScreen.FIELD_TURN, -SkirmishScreen.FIELD_TURN], "the left two turn to their right")
	assert_eq([s._mech_turn(2), s._mech_turn(3)], [SkirmishScreen.FIELD_TURN, SkirmishScreen.FIELD_TURN], "the right two to their left")
	s.free()
	s = _screen("middle", ["badger"])
	assert_eq(s._mech_turn(0), -SkirmishScreen.FIELD_TURN, "a lone machine, left of the middle, to its right")
	s.free()
	var view := MechView3D.make_on_floor("badger", "minerva", "clean", {"focal": 900.0, "height": 4.0, "principal": Vector2(360, 100), "at": Vector2(0.5, 7.0), "window": Rect2(0, 0, 200, 240), "fill": 0.9, "turn": SkirmishScreen.FIELD_TURN})
	assert_eq(view.yaw, MechView3D.YAW_FIELD + SkirmishScreen.FIELD_TURN, "the view takes the turn as its yaw")
	view.free()
	var nose := Basis(Vector3.UP, deg_to_rad(SkirmishScreen.FIELD_TURN)) * Vector3(0, 0, -1)
	assert_true(nose.x < 0.0, "a positive yaw swings the nose to the screen's left")
	assert_true(SkirmishScreen.FIELD_TURN > 0.0 and SkirmishScreen.FIELD_TURN <= 25.0, "slightly")
	Settings.display["skirmish_controls"] = was


func test_each_spot_is_a_hex_of_the_floor() -> void:
	var was: Variant = Settings.display.get("skirmish_controls", "middle")
	for controls in Settings.SKIRMISH_CONTROLS:
		var s := _screen(controls)
		var cam: Dictionary = s._cam
		# The floor's lattice (floor_plane.gdshader) puts its half-offset rows' centres at depth
		# (m + 1/2) root 3 past the shift: one of them runs through the machines' feet.
		var row := (float(cam.depth) - float(cam.shift)) / sqrt(3.0) - 0.5
		assert_true(absf(row - roundf(row)) < 1.0e-4, "a row of hex centres through the machines' feet (%s)" % controls)
		assert_true(absf(float(cam.row) - (s.MECH_Y + SkirmishScreen.MECH_FOOT)) < 1.0e-3, "at their foot line")
		for i in range(SkirmishScreen.SLOTS):
			var c := s._on_floor(s._slot_hex_x(i), cam.depth)
			assert_true(c.distance_to(Vector2(s._slot_x(i), cam.row)) < 1.0e-3, "spot %d is a hex centre on the floor (%s)" % [i, controls])
			var across := s._on_floor(s._slot_hex_x(i) + 0.5, cam.depth).x - s._on_floor(s._slot_hex_x(i) - 0.5, cam.depth).x
			assert_true(absf(across - SkirmishScreen.PITCH) < 1.0e-3, "its hex a pitch across")
		assert_true(absf(s._mech_views[0].shadow_ratio - tan(deg_to_rad(SkirmishScreen.FIELD_THETA))) < 1.0e-4, "the machines' shadows flattened as the floor is under them")
		s.free()
	Settings.display["skirmish_controls"] = was


func test_a_machine_is_drawn_through_the_floor_camera() -> void:
	# The floor's camera, a window of it: the machine's ground point lands on its hex's centre
	# in the view, as the floor draws that hex on the screen.
	var window := Rect2(250.0, 600.0, 220.0, 256.0)
	var focal := 1000.0
	var height := 3.4
	var principal := Vector2(360.0, 150.0)
	var at := Vector2(-0.5, focal / SkirmishScreen.PITCH)
	var view := MechView3D.make_on_floor("badger", "minerva", "clean", {"focal": focal, "height": height, "principal": principal, "at": at, "window": window, "fill": 0.9})
	# Headless tests run before the tree: project as the camera does (its frustum, its place).
	var cam: Camera3D = view._camera
	var px := Vector2(view.size)
	var proj := Projection.create_frustum_aspect(cam.size, px.x / px.y, cam.frustum_offset, cam.near, cam.far, false)
	var p := cam.transform.affine_inverse() * view._stage.position
	var clip := proj * Vector4(p.x, p.y, p.z, 1.0)
	var got := Vector2((clip.x / clip.w + 1.0) * 0.5 * px.x, (1.0 - clip.y / clip.w) * 0.5 * px.y)
	var hex := principal + Vector2(focal * at.x / at.y, focal * height / at.y)
	var expected := (hex - window.position) * view.density
	assert_true(got.distance_to(expected) < 0.5, "the hex's centre where the floor puts it (%s, %s)" % [got, expected])
	assert_eq(view.yaw, MechView3D.YAW_FIELD, "facing the foes")
	view.free()


func test_foes_stand_on_their_feet_line() -> void:
	var short := _foe_view(40, 92)
	var tall := _foe_view(4, 80)
	for v in [short, tall]:
		assert_true(absf(v._visible().end.y - v.feet_y) < 1.0, "a sprite's lowest pixel on its rank's feet line, whatever its height")
	tall.hover = SkirmishScreen.WINGED_LIFT
	assert_true(absf(tall._visible().end.y - (tall.feet_y - SkirmishScreen.WINGED_LIFT)) < 1.0, "what flies floats over it")
	short.free()
	tall.free()


func test_the_breathe_keeps_the_feet_planted() -> void:
	var v := _foe_view(10, 84)
	v.breathe = true
	v.breathe_phase = 1.3
	var vis := v._visible()
	var feet := Vector2(vis.get_center().x, vis.end.y)
	var used := Sprites.used_rect(v.sprite)
	var s := v._scale()
	var leaned := false
	for t in [0.0, 0.7, 1.9, 3.3, 5.1]:
		v._t = t
		var breath := v.breath_frame()
		var frame: Rect2 = breath[0]
		var k := frame.size.y / v._silhouette().size.y
		assert_true(absf(frame.position.y + used.end.y * s * k - vis.end.y) < 0.01, "the rise scales from the feet (t %.1f)" % t)
		var lean: Transform2D = breath[1]
		assert_true((lean * feet).distance_to(feet) < 0.001, "the lean leaves the feet where they stand (t %.1f)" % t)
		if (lean * Vector2(feet.x, vis.position.y)).distance_to(Vector2(feet.x, vis.position.y)) > 0.01:
			leaned = true
	assert_true(leaned, "while the top of it leans")
	v.free()


## Room for three rows of chips under the machines, clear of the controls in both layouts (Ryan, 2
## November: "there needs to be space for 2-3 rows of chips under the player units specifically
## without bumping into the UI"), and the rows wrap at a unit's width.
func test_three_rows_of_chips_fit_under_the_machines() -> void:
	var was: Variant = Settings.display.get("skirmish_controls", "middle")
	for mode in ["middle", "bottom"]:
		Settings.display["skirmish_controls"] = mode
		var db := ContentDB.load_default()
		var sk := Skirmish.new(3)
		for id in ["badger", "armadillo", "clydesdale", "wild_boar"]:
			sk.add_mech(db.make_mech(id))
		sk.add_foes([Foe.make("revenant", 30, 4)])
		var s := SkirmishScreen.new()
		s.setup(sk)
		var below := (s.LOG_Y - 4.0) if mode == "bottom" else (s.BOTTOM_Y - 4.0)
		for v in s._mech_views:
			# The first row stands under the drawing, at most the view's own chip row; two more under it.
			var first: float = v.position.y + v.size.y - UnitView.STATUS_H
			var third_end := first + 3.0 * UnitView.CHIP_H + 2.0 * UnitView.ROW_GAP
			assert_true(third_end <= below, "%s: the third row ends at %.0f, clear of the controls at %.0f" % [mode, third_end, below])
		s.free()
	Settings.display["skirmish_controls"] = was
	var rows := UnitView.chip_rows([56.0, 56.0, 56.0, 56.0, 56.0], 176.0)
	assert_eq(rows, [[0, 1], [2, 3], [4]], "chips wrap two to a machine's row, in order")
	assert_eq(UnitView.chip_rows([200.0, 40.0], 150.0), [[0], [1]], "a chip wider than the row stands alone")
