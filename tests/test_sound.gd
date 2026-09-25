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


func test_headless_calls_are_no_ops() -> void:
	Sound.play("hit")
	Sound.play_after(0.1, "kill")
	Sound.music("skirmish")
	Sound.duck(true)
	Sound.apply_settings()
	assert_eq(Sound._node, null, "no node is made without a display")


func test_volume_knobs_are_settings() -> void:
	for key in ["music", "effects"]:
		assert_true(Settings.DISPLAY_DEFAULTS.has(key), "%s has a default" % key)
		assert_true(Settings.DISPLAY_RANGES.has(key), "%s has a slider range" % key)
