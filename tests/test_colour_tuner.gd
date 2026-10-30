extends TestCase

## The colour tuner (ColourTuner) and its page (a debug build's COLOURS, under SETTINGS): every
## slot names a colour its script declares, a pick lands in the script and comes off again, a
## slot that follows another takes its value until it is set, a HUD choice's pick reaches the
## HUD, and a headless run keeps no picks. Nothing here writes the settings file: a headless
## run never saves a pick.


func test_every_slot_names_a_colour() -> void:
	var keys := {}
	for s in ColourTuner.SLOTS:
		var key: String = s[0]
		assert_false(keys.has(key), "%s is one slot" % key)
		keys[key] = true
		assert_ne(ColourTuner.value(key), Color.MAGENTA, "%s reads a colour from %s" % [key, s[2]])
		if str(s[4]) != "":
			assert_true(keys.has(str(s[4])), "%s follows a slot listed before it" % key)
	assert_eq(ColourTuner.value("ENEMY"), Color("ff0000"), "the red as the palette declares it")


func test_a_pick_lands_follows_and_comes_off() -> void:
	ColourTuner.reset_all(false)
	var red := Palette.ENEMY
	ColourTuner.set_colour("ENEMY", Color("ffff00"), false)
	assert_eq(Palette.ENEMY, Color("ffff00"), "the pick is the palette's red")
	assert_eq(Palette.ENEMY_ARROW, Color("ffff00"), "the arrows follow the red")
	assert_eq(Palette.ENEMY_MAP, Color("ffff00"), "and so does the map's ground red")
	ColourTuner.set_colour("ENEMY_ARROW", Color("00ffff"), false)
	assert_eq(Palette.ENEMY_ARROW, Color("00ffff"), "the arrows parted from the chips")
	assert_eq(Palette.ENEMY_MAP, Color("ffff00"), "the map's still following")
	assert_true(ColourTuner.export_text().contains("ENEMY #ffff00") and ColourTuner.export_text().contains("ENEMY_ARROW #00ffff"), "the copy lists both picks")
	ColourTuner.reset("ENEMY", false)
	assert_eq(Palette.ENEMY, red, "a reset puts the declared red back")
	assert_eq(Palette.ENEMY_MAP, red, "and the follower with it")
	assert_eq(Palette.ENEMY_ARROW, Color("00ffff"), "a slot set itself stays set")
	ColourTuner.reset_all(false)
	assert_eq(Palette.ENEMY_ARROW, red, "RESET ALL clears it")
	assert_eq(ColourTuner.export_text(), "No colours changed.", "and the copy says so")


func test_a_hud_choice_pick_reaches_the_hud() -> void:
	ColourTuner.reset_all(false)
	var was := Settings.hud
	Settings.hud = "green"
	var green: Color = Settings.HUD_OPTIONS["green"]
	ColourTuner.set_colour("hud_green", Color("ffffff"), false)
	assert_eq(Settings.HUD_OPTIONS["green"], Color("ffffff"), "the choice's colour is the pick")
	assert_eq(Palette.HUD, Color("ffffff"), "and the HUD wears it while green is chosen")
	ColourTuner.reset_all(false)
	assert_eq(Settings.HUD_OPTIONS["green"], green, "a reset puts the choice back")
	Settings.hud = was
	ColourTuner.apply()


func test_the_map_and_the_plaque_take_their_picks() -> void:
	ColourTuner.reset_all(false)
	var hot := BattleMapView.ENEMY_HOT
	ColourTuner.set_colour("ENEMY_HOT", Color("ffff00"), false)
	ColourTuner.set_colour("PLAQUE_BLUE_TOP", Color("00ff00"), false)
	assert_eq(BattleMapView.ENEMY_HOT, Color("ffff00"), "the map's bright")
	assert_eq(Plaque.BLUE_TOP, Color("00ff00"), "the plaque's blue")
	ColourTuner.reset_all(false)
	assert_eq(BattleMapView.ENEMY_HOT, hot, "both come off")


func test_a_headless_run_keeps_no_picks() -> void:
	assert_false(ColourTuner.enabled(), "headless, the tuner keeps nothing")
	var cf := ConfigFile.new()
	cf.set_value(ColourTuner.SECTION, "ENEMY", "ffff00")
	ColourTuner.load_saved(cf)
	assert_true(ColourTuner.picks().is_empty(), "a saved pick is not read")
	assert_eq(Palette.ENEMY, Color("ff0000"), "the declared red stands")


func test_the_page_lists_every_colour_and_a_pick_rebuilds() -> void:
	ColourTuner.reset_all(false)
	var menu := PauseMenu.new()
	var rebuilt: Array = []
	menu.hud_changed.connect(func() -> void: rebuilt.append(true))
	menu._show_page("colours")
	assert_eq(_count(menu._list, "ColorPickerButton"), ColourTuner.SLOTS.size(), "a swatch a colour")
	menu._pick("ENEMY", Color("ffff00"))
	assert_eq(Palette.ENEMY, Color("ffff00"), "a pick from the page lands")
	assert_eq(rebuilt.size(), 1, "and the host rebuilds once")
	menu._pick("ENEMY", Color("ffff00"))
	assert_eq(rebuilt.size(), 1, "the same colour again rebuilds nothing")
	menu._peek(true)
	assert_false(menu._panel.visible, "PEEK clears the menu away")
	assert_true(menu._peek_tag.visible, "and says how to come back")
	var tap := InputEventMouseButton.new()
	tap.pressed = true
	menu._scrim.gui_input.emit(tap)
	assert_true(menu._panel.visible and not menu._peeking, "a tap brings it back")
	menu._recolour(func() -> void: ColourTuner.reset_all(false))
	assert_eq(Palette.ENEMY, Color("ff0000"), "RESET ALL from the page")
	menu.free()


func _count(node: Node, cls: String) -> int:
	var n := 1 if node.get_class() == cls else 0
	for c in node.get_children():
		n += _count(c, cls)
	return n
