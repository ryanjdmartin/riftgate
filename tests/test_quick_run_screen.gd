extends TestCase

## Drives the quick campaign's screens through their handlers without a window: the draft's
## three picks, the hangar's fits and squad, the track between fights, a fight opened without
## its withdrawal and back, the rewards' chosen card, and the run's end.


func _screen(seed_value: int = 5) -> QuickRunScreen:
	var s := QuickRunScreen.new()
	s.setup(QuickRun.new(seed_value))
	return s


func _drafted(seed_value: int = 5) -> QuickRunScreen:
	var s := _screen(seed_value)
	for id in QuickRun.draft_choices(s.run.db).slice(0, QuickRun.START_MACHINES):
		s._toggle_pick(str(id))
	s._on_primary()
	return s


## End the open fight the way a skirmish does.
func _end(r: QuickRun, outcome: int) -> void:
	var sk := r.open_fight()
	sk.outcome = outcome
	sk.state = Skirmish.State.DONE


func test_the_draft_takes_three_and_opens_the_hangar() -> void:
	var s := _screen()
	assert_eq(s._title.text, "QUICK CAMPAIGN", "the draft first")
	assert_true(s._primary.disabled, "nothing picked: START waits")
	var offered := QuickRun.draft_choices(s.run.db)
	assert_true(s._content.get_child_count() >= offered.size(), "a card a chassis")
	for id in offered.slice(0, QuickRun.START_MACHINES):
		s._toggle_pick(str(id))
	assert_eq(s._picked.size(), 3, "three picked")
	s._toggle_pick(str(offered[QuickRun.START_MACHINES]))
	assert_eq(s._picked.size(), 3, "never a fourth")
	assert_false(s._primary.disabled, "START is open")
	s._on_primary()
	assert_eq(s.run.state, QuickRun.HANGAR, "into the hangar")
	assert_eq(s._title.text, "BATTLE 1 OF %d" % QuickRun.BATTLES, "the first battle ahead")
	assert_true(s._sub.text.contains("HANGAR"), "in the hangar")
	s.free()


func test_the_hangar_fits_from_the_stores_and_sets_the_squad() -> void:
	var s := _drafted()
	var r := s.run
	var m: QuickRun.Machine = r.roster[0]
	var piece := ""
	for it in r.pool(2):
		if it["kind"] == "component":
			piece = str(it["id"])
			break
	r.components[piece] = 1
	s._refresh()
	var fixed_n: int = r.db.chassis[m.chassis].get("fixed", []).size()
	s._open_hardpoint(m.uid, 0, fixed_n)
	assert_true(s._chooser != null, "the chooser opens")
	s._fit(m.uid, 0, piece)
	assert_eq(m.loadout[0], piece, "fitted")
	assert_true(s._chooser == null, "and the chooser closes")
	s._toggle_squad(m.uid)
	assert_false(r.squad.has(m.uid), "benched")
	s._toggle_squad(m.uid)
	assert_true(r.squad.has(m.uid), "back in, last to deploy")
	r.modules[str(r.db.modules.keys()[0])] = 1
	s._open_module(m.uid, 0)
	s._fit_module(m.uid, 0, str(r.db.modules.keys()[0]))
	assert_eq(m.modules.size(), 1, "a module fitted")
	s.free()


func test_a_fight_opens_without_withdrawal_and_comes_back_to_the_track() -> void:
	var s := _drafted()
	s._on_primary()
	assert_eq(s.run.state, QuickRun.BATTLE, "into the battle")
	assert_eq(s._primary.text, "FIGHT", "the first fight waits")
	s._on_primary()
	assert_true(s._skirmish != null, "the fight's screen")
	assert_false(s._skirmish._withdraw_btn.visible, "no withdrawal here")
	assert_eq(s._skirmish.back_label, "BACK TO THE RUN", "back leads to the run")
	s.run.current.outcome = Skirmish.Outcome.VICTORY
	s.run.current.state = Skirmish.State.DONE
	s._on_fight_back()
	assert_true(s._skirmish == null, "the fight's screen gone")
	assert_eq(s.run.fight, 1, "the next fight ahead")
	assert_true(s._sub.text.contains("FIGHT 2"), "the track says so")
	s.free()


func test_the_rewards_take_the_chosen_card() -> void:
	var s := _drafted()
	var r := s.run
	r.start_battle()
	for i in range(r.encounters.size()):
		_end(r, Skirmish.Outcome.VICTORY)
		r.finish_fight()
	s._refresh()
	assert_eq(r.state, QuickRun.REWARDS, "the boss is down")
	assert_true(s._primary.disabled, "nothing chosen: TAKE waits")
	var owed := r.rewards.size()
	s._select_reward(0)
	assert_false(s._primary.disabled, "a card chosen")
	s._on_primary()
	assert_eq(r.rewards.size(), owed - 1, "taken")
	assert_eq(s._choice, -1, "the next pick starts unchosen")
	s.free()


func test_the_end_says_where_and_goes_back() -> void:
	var s := _drafted()
	var r := s.run
	r.start_battle()
	_end(r, Skirmish.Outcome.DEFEAT)
	r.finish_fight()
	s._refresh()
	assert_eq(s._title.text, "RUN LOST", "lost")
	assert_true(s._sub.text.begins_with("BATTLE 1"), "where")
	assert_eq(s._primary.text, "BACK", "back to the harness")
	var left := [0]
	s.back_requested.connect(func() -> void: left[0] += 1)
	s._on_primary()
	assert_eq(left[0], 1, "it goes back")
	s.free()
