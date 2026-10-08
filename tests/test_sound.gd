extends TestCase

## The sound layer: every name the game asks for has a file, and headless every call is a
## no-op that touches nothing.


func test_every_named_sound_has_a_file() -> void:
	for name in Sound.all_names():
		assert_true(FileAccess.file_exists(Sound.DIR + name + ".wav"), "art/audio/%s.wav exists (tools/soundforge builds it)" % name)


func test_a_component_sound_finds_its_blow() -> void:
	for word in ContentDB.SOUNDS:
		assert_true(Sound.BLOWS.has(word), "the sound word %s has a blow" % word)
		assert_true(Sound.NAMES.has(Sound.BLOWS[word]), "%s's blow is a named sound" % word)
	assert_eq(Sound.blow(["barrel"]), "w_barrel", "one word is its blow")
	assert_eq(Sound.blow(["blunt", "plasma"]), "w_blunt_plasma", "a combination the forge built plays as itself")
	assert_eq(Sound.blow(["rack", "plasma"]), "w_rack", "one it did not build plays its first word")
	assert_eq(Sound.blow([]), "", "no layers, no blow")
	assert_eq(Sound.blow(["not_a_word"]), "", "an unknown word plays nothing")


func test_metal_family_and_footfall_names_are_files() -> void:
	var db := ContentDB.load_default()
	for id in db.chassis:
		var maker := str(db.chassis[id].get("maker", ""))
		assert_true(Sound.MAKERS.has(maker), "chassis %s's maker %s has a metal" % [id, maker])
		var step := Sound.step_for(db.chassis[id].get("traits", []))
		assert_true(Sound.NAMES.has(step), "chassis %s has a footfall (%s)" % [id, step])
	for f in db.factions:
		assert_true(Sound.FAMILIES.has(f), "family %s has its blows and arrival" % f)
	for way in BattleMap.WAYS:
		assert_true(Sound.STEPS.has(way), "the way of moving %s has a footfall" % way)
	assert_eq(Sound.struck("hit", "kestrel"), "hit_kestrel", "a hit in Kestrel chrome")
	assert_eq(Sound.struck("kill", "not_a_maker"), "kill_minerva", "an unknown maker is Minerva's steel")
	assert_eq(Sound.family("heavy", "demonic"), "foe_demonic_heavy", "the Horde's heavy blow")
	assert_eq(Sound.family("spawn", "eldritch"), "spawn_eldritch", "the Chorus arriving")
	assert_eq(Sound.step_for(["wheeled", "stealth"]), "step_wheeled", "a way among other traits")
	assert_eq(Sound.step_for([]), "step_legged", "no way is legs")


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
	for key in ["music", "effects", "voice"]:
		assert_true(Settings.DISPLAY_DEFAULTS.has(key), "%s has a default" % key)
		assert_true(Settings.DISPLAY_RANGES.has(key), "%s has a slider range" % key)



## Jenny's table as the forge ships it: every hook the game says is in it, every file exists,
## and the information hooks speak every time.
func test_the_lines_table_is_whole() -> void:
	var table := Sound._read_lines()
	assert_true(not table.is_empty(), "art/audio/voice/lines.json is shipped (voice_lines.py ship)")
	var hooks: Dictionary = table.get("hooks", {})
	for hook in ["die_spent", "foe_down", "foe_down_undead", "foe_down_demonic", "foe_down_eldritch", "buff",
			"heat_vented", "heat_high", "overheat", "machine_lost", "component_damaged", "component_destroyed",
			"resolve_all", "resolve_move", "contact", "engage", "boss", "gate", "loss_gate", "victory", "codex",
			"refuse", "battle_open"]:
		assert_true(hooks.has(hook), "the game's hook %s has lines" % hook)
	for hook in hooks:
		var h: Dictionary = hooks[hook]
		assert_true(not (h.get("lines", []) as Array).is_empty() or not (h.get("personality", []) as Array).is_empty(), "%s has a line" % hook)
		for key in ["lines", "personality"]:
			for line in h.get(key, []):
				assert_true(FileAccess.file_exists(Sound.VOICE_DIR + str(line["file"]) + ".wav"), "%s's %s is a file" % [hook, line["file"]])
		for other in h.get("merge", []):
			assert_true(hooks.has(other), "%s merges %s, a hook" % [hook, other])
		var sig := str(h.get("signal", ""))
		if not sig.is_empty():
			assert_true(Sound.NAMES.has(sig), "%s's signal %s is a named sound" % [hook, sig])
	for hook in ["machine_lost", "component_damaged", "component_destroyed", "heat_high", "overheat", "loss_gate"]:
		assert_true(bool(hooks[hook].get("info", false)), "%s is information" % hook)


func _table() -> Dictionary:
	return {"spacing": 6.0, "stale": 2.0, "personality": 0.0, "hooks": {
		"rare": {"chance": 0.0, "info": false, "lines": [{"file": "r"}]},
		"chatty": {"chance": 1.0, "info": false, "lines": [{"file": "a"}, {"file": "b"}, {"file": "c"}], "personality": [{"file": "p"}]},
		"info": {"chance": 0.0, "info": true, "lines": [{"file": "i"}]},
		"family": {"chance": 1.0, "info": false, "lines": [{"file": "f"}], "merge": ["chatty"]},
		"heat_high": {"chance": 1.0, "info": true, "lines": [{"file": "warm"}], "signal": "heat_warn"},
		"overheat": {"chance": 1.0, "info": true, "lines": [{"file": "hot"}], "signal": "heat_alarm"},
		"loss_gate": {"chance": 1.0, "info": true, "lines": [{"file": "lost"}]},
	}}


func test_a_hook_speaks_by_its_chance_and_information_always() -> void:
	var v := VoiceLines.new()
	v.load_table(_table())
	v.rng.seed = 7
	for k in range(20):
		assert_false(v.trigger("rare", 0.0), "a hook at chance 0 never speaks")
	assert_true(v.trigger("info", 0.0), "information speaks even at chance 0")
	assert_false(v.trigger("unknown", 0.0), "a hook without lines says nothing")


func test_the_bag_never_repeats_until_spent_and_a_hook_queues_once() -> void:
	var v := VoiceLines.new()
	v.load_table(_table())
	v.rng.seed = 3
	var said := {}
	var t := 0.0
	for k in range(3):
		assert_true(v.trigger("chatty", t), "queued")
		assert_false(v.trigger("chatty", t), "a hook already waiting is not queued twice")
		var q := v.next(t)
		said[q["file"]] = true
		v.started(t, 1.0)
		t += 10.0
	assert_eq(said.size(), 3, "three draws from a bag of three are the three lines")


func test_lines_keep_their_distance_and_go_stale() -> void:
	var v := VoiceLines.new()
	v.load_table(_table())
	v.trigger("chatty", 0.0)
	var q := v.next(0.0)
	assert_true(not q.is_empty(), "the first line plays at once")
	v.started(0.0, 1.0)
	v.trigger("family", 1.5)
	assert_true(v.next(2.0).is_empty(), "inside the spacing nothing plays")
	assert_true(v.next(7.5).is_empty(), "a line that would wait past STALE is dropped")
	assert_true(v.waiting().is_empty(), "and is gone from the queue")
	v.trigger("info", 1.2)
	assert_true(v.next(1.5).is_empty(), "information waits for the line in progress and its own short gap")
	assert_eq(str(v.next(1.0 + VoiceLines.INFO_GAP)["file"]), "i", "then speaks, long before the spacing")


func test_a_merged_hook_draws_both_pools() -> void:
	var v := VoiceLines.new()
	v.load_table(_table())
	v.rng.seed = 11
	var said := {}
	var t := 0.0
	for k in range(8):
		v.trigger("family", t)
		said[v.next(t)["file"]] = true
		v.started(t, 0.5)
		t += 10.0
	assert_eq(said.size(), 4, "its own line and the merged pool's three")


func test_the_personality_layer_replaces_a_line() -> void:
	var table := _table()
	table["personality"] = 1.0
	var v := VoiceLines.new()
	v.load_table(table)
	v.trigger("chatty", 0.0)
	assert_eq(str(v.next(0.0)["file"]), "p", "at chance one the personality line speaks")


func test_overheat_replaces_the_warning_and_a_loss_cuts_in() -> void:
	var v := VoiceLines.new()
	v.load_table(_table())
	v.trigger("chatty", 0.0)
	v.next(0.0)
	v.started(0.0, 3.0)
	v.trigger("heat_high", 0.5)
	v.trigger("overheat", 0.6)
	var hooks: Array = v.waiting().map(func(q: Dictionary) -> String: return q["hook"])
	assert_eq(hooks, ["overheat"], "the overheat replaced the waiting warning")
	assert_eq(str(v.waiting()[0]["signal"]), "heat_alarm", "and carries its signal")
	v.trigger("loss_gate", 1.0)
	assert_eq(v.waiting().size(), 1, "a loss clears the queue")
	assert_eq(str(v.next(1.0)["file"]), "lost", "and speaks at once, over the line in progress")


func test_the_win_clears_the_queue() -> void:
	var v := VoiceLines.new()
	v.load_table(_table())
	v.trigger("info", 0.0)
	v.trigger("heat_high", 0.0)
	v.clear()
	assert_true(v.next(5.0).is_empty(), "nothing queued during the fight is said after it")



func test_every_landing_is_a_blow_the_game_plays() -> void:
	for name in Sound.LAND:
		assert_true(Sound.all_names().has(name), "%s lands somewhere: it is a named sound" % name)
		assert_true(Sound.lands(name) >= 0.0 and Sound.lands(name) < 2.0, "%s lands within two seconds" % name)
	assert_eq(Sound.lands("not_a_blow"), 0.0, "a sound without a landing lands at once")
	assert_true(Sound.lands("w_rack") > Sound.lands("w_barrel"), "the rack's salvo is in flight before it lands; the barrel's report is the hit")


func test_every_line_mode_speaks_every_hook_a_second_apart() -> void:
	var v := VoiceLines.new()
	v.load_table(_table())
	v.always = true
	assert_true(v.trigger("rare", 0.0), "a hook at chance 0 speaks in the test mode")
	v.next(0.0)
	v.started(0.0, 1.0)
	v.trigger("chatty", 0.2)
	assert_true(v.next(1.5).is_empty(), "the line in progress and a second first")
	assert_eq(str(v.next(1.0 + VoiceLines.INFO_GAP)["hook"]), "chatty", "then the next, never stale")
