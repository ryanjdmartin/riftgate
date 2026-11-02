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
	assert_true(s._skirmish._withdraw_btn.disabled, "no withdrawal here")
	assert_eq(s._skirmish._withdraw_btn.text, "NO RETREAT", "and the button says why, as in the boss's fight")
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


## The controls under `n` that would keep a touch from the scroller above them.
func _stoppers(n: Node) -> Array:
	var out: Array = []
	if n is Control and (n as Control).mouse_filter == Control.MOUSE_FILTER_STOP:
		out.append(n)
	for c in n.get_children():
		out.append_array(_stoppers(c))
	return out


## Every scrolled list on the screen hands a touch on to its scroller (Ryan, 2 November: "quick
## campaign draft menu is hard to scroll"): no card, row or button in it stops one, in the draft,
## the hangar and its chooser, between the fights and in the rewards, rebuilt or not.
func test_every_scrolled_list_passes_a_touch_on_to_its_scroller() -> void:
	var s := _screen()
	assert_eq(_stoppers(s._content).size(), 0, "the draft: nothing stops a touch")
	s._toggle_pick(str(QuickRun.draft_choices(s.run.db)[0]))
	assert_eq(_stoppers(s._content).size(), 0, "nor once a pick has rebuilt it")
	s.free()
	s = _drafted()
	var m: QuickRun.Machine = s.run.roster[0]
	assert_eq(_stoppers(s._content).size(), 0, "the hangar")
	s._open_hardpoint(m.uid, 0, s.run.db.chassis[m.chassis].get("fixed", []).size())
	var lists: Array = s._chooser.find_children("*", "ScrollContainer", true, false)
	assert_eq(lists.size(), 1, "the chooser scrolls its pieces")
	assert_eq(_stoppers((lists[0] as ScrollContainer).get_child(0)).size(), 0, "and nothing in it stops a touch")
	s._close_chooser()
	s._on_primary()
	assert_eq(s.run.state, QuickRun.BATTLE, "between the fights")
	assert_eq(_stoppers(s._content).size(), 0, "the track and the squad's rows")
	for i in range(s.run.encounters.size()):
		_end(s.run, Skirmish.Outcome.VICTORY)
		s.run.finish_fight()
	s._refresh()
	assert_eq(s.run.state, QuickRun.REWARDS, "the rewards")
	assert_eq(_stoppers(s._content).size(), 0, "the reward cards")
	s.free()


## The first card's PICK (PICKED once it is picked).
func _first_pick(s: QuickRunScreen) -> HudButton:
	for b in s._content.find_children("*", "HudButton", true, false):
		if (b as HudButton).text in ["PICK", "PICKED"]:
			return b
	return null


## The draft scrolls from anywhere on it (Ryan, 2 November: "quick campaign draft menu is hard to
## scroll"). A ScrollContainer scrolls on the touch itself, and a card's panel or its button, both
## stopping a touch, kept it from the scroller: only the gaps between the cards scrolled, and a
## short drag that ended on PICK picked. Live: the screen in the tree, a finger's events pushed
## through its viewport as the phone's arrive.
func live_test_a_drag_over_a_card_scrolls_the_draft_and_never_picks() -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(720, 1280)
	(Engine.get_main_loop() as SceneTree).root.add_child(vp)
	var s := QuickRunScreen.new()
	s.run = QuickRun.new(5)
	vp.add_child(s)
	_lay_out(vp)
	var pick := _first_pick(s)
	assert_true(pick != null and pick.is_visible_in_tree(), "a card's PICK on the glass")
	_drag(vp, pick.get_global_rect().get_center(), Vector2(0, -200))
	var after := s._scroll.scroll_vertical
	assert_true(after >= 150, "a drag that starts on PICK scrolls the list (%d)" % after)
	assert_true(s._picked.is_empty(), "and picks nothing")
	_lay_out(vp)
	_drag(vp, pick.get_global_rect().get_center(), Vector2(0, -24), 3)
	assert_true(s._scroll.scroll_vertical > after, "a short drag past the dead zone scrolls")
	assert_true(s._picked.is_empty(), "though it lifts on PICK, it never picks")
	_lay_out(vp)
	var card: Control = pick.get_parent().get_parent().get_parent()   # PICK's row, the card's column, its panel
	assert_true(card is HudPanel, "the card itself")
	var on_card := pick.get_global_rect().get_center() + Vector2(0, -80)   # on its die's entries, above PICK
	assert_true(card.get_global_rect().has_point(on_card) and not pick.get_global_rect().has_point(on_card), "a spot on the card off its buttons")
	var before := s._scroll.scroll_vertical
	_drag(vp, on_card, Vector2(0, -150))
	assert_true(s._scroll.scroll_vertical >= before + 100, "a drag on the card's panel scrolls too (%d to %d)" % [before, s._scroll.scroll_vertical])
	_lay_out(vp)
	var at := pick.get_global_rect().get_center()
	_finger(vp, at, true)
	_finger(vp, at, false)
	assert_eq(s._picked.size(), 1, "a tap on PICK still picks")
	s._scroll.scroll_vertical = 0   # where the pick's own refresh leaves it for a frame
	_lay_out(vp)   # the pick rebuilt the list
	var again := _first_pick(s)
	assert_eq(again.text, "PICKED", "the rebuilt card says so")
	before = s._scroll.scroll_vertical
	_drag(vp, again.get_global_rect().get_center(), Vector2(0, -200))
	assert_true(s._scroll.scroll_vertical >= before + 150, "and the rebuilt list scrolls from its cards as well (%d to %d)" % [before, s._scroll.scroll_vertical])
	assert_eq(s._picked.size(), 1, "with no pick taken back")
	vp.free()


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
