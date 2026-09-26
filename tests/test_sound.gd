extends TestCase

## The sound layer: every name the game asks for has a file, and headless every call is a
## no-op that touches nothing.


func test_every_named_sound_has_a_file() -> void:
	for name in Sound.NAMES:
		assert_true(FileAccess.file_exists(Sound.DIR + name + ".wav"), "art/audio/%s.wav exists (tools/soundforge builds it)" % name)


func test_every_set_names_known_loops() -> void:
	for picked in Sound.PICK:
		assert_true(Sound.SETS.has(picked), "picking set %s is a set" % picked)
	for set_name in Sound.SETS:
		assert_true(Sound.SETS[set_name].size() >= 1, "set %s has a loop" % set_name)
		for loop in Sound.SETS[set_name]:
			assert_true(Sound.NAMES.has(loop), "set %s's %s is a named loop" % [set_name, loop])
			assert_true(Sound.TEMPO.has(loop), "set %s's %s has a tempo" % [set_name, loop])


func test_every_loop_has_a_title_and_a_label() -> void:
	for loop in Sound.TRACKS:
		assert_true(Sound.NAMES.has(loop), "titled loop %s is a named sound" % loop)
		assert_true(not Sound.title(loop).is_empty(), "%s has a title" % loop)
		assert_true(not Sound.label(loop).is_empty(), "%s has a working label" % loop)
	for set_name in Sound.SETS:
		for loop in Sound.SETS[set_name]:
			assert_true(Sound.TRACKS.has(loop), "set %s's %s has a title for the ticker" % [set_name, loop])
	var titles := {}
	for loop in Sound.TRACKS:
		titles[Sound.title(loop)] = true
	assert_eq(titles.size(), Sound.TRACKS.size(), "no two loops share a title")
	assert_eq(Sound.title("not_a_loop"), "", "an unknown loop has no title")


func test_boss_sets_name_a_family_and_wrap_into_their_groove() -> void:
	var db := ContentDB.load_default()
	var themed := 0
	for set_name in Sound.SETS:
		if not str(set_name).begins_with("boss_"):
			continue
		var fac := str(set_name).substr(5)
		assert_true(db.factions.has(fac), "boss set %s names a family in content" % set_name)
		assert_eq(Sound.SETS[set_name].size(), 1, "a boss theme is one loop, looped for the whole fight")
		assert_eq(Sound.boss_set(fac), set_name, "boss_set finds it")
		assert_false(Sound.PICK.has(set_name), "a boss set never picks")
		themed += 1
	assert_true(themed >= 1, "at least one family has a theme")
	assert_eq(Sound.boss_set("not_a_family"), "", "a family without a theme has no set: the fight takes the skirmish's pick")
	for loop in Sound.LOOP_FROM:
		assert_true(Sound.NAMES.has(loop), "%s wraps to a bar: it is a named loop" % loop)
		assert_true(Sound.TEMPO.has(loop), "%s has a tempo to turn bars into seconds" % loop)
		assert_true(int(Sound.LOOP_FROM[loop]) > 0, "%s wraps past its top" % loop)


func test_headless_calls_are_no_ops() -> void:
	Sound.play("hit")
	Sound.play_after(0.1, "kill")
	Sound.music("skirmish")
	Sound.skip(1)
	Sound.duck(true)
	Sound.apply_settings()
	assert_eq(Sound._node, null, "no node is made without a display")
	assert_eq(Sound.track(), "", "nothing plays without a display")
	assert_eq(Sound.set_playing(), "", "no set plays without a display")


func test_volume_knobs_are_settings() -> void:
	for key in ["music", "effects"]:
		assert_true(Settings.DISPLAY_DEFAULTS.has(key), "%s has a default" % key)
		assert_true(Settings.DISPLAY_RANGES.has(key), "%s has a slider range" % key)
