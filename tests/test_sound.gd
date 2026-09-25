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
