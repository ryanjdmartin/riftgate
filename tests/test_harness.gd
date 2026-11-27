extends TestCase

## The harness: its setup (the team's loadouts, the battle and the fight it launches, kept
## between launches) and a headless drive of its tabs. Content-agnostic: every id comes from the
## content in file order.

const HARNESS := preload("res://game/harness.gd")
const TMP := "user://test_harness.json"


func _db() -> ContentDB:
	return ContentDB.load_default()


## A chassis with at least two hardpoints, and a component its stock does not carry.
func _refit_pair(db: ContentDB) -> Array:
	for id in db.chassis.keys():
		var stock: Array = db.chassis[id].get("loadout", [])
		if int(db.chassis[id].get("hardpoints", 0)) < 2:
			continue
		for cid in db.components.keys():
			if not stock.has(cid):
				return [str(id), str(cid)]
	return []


func test_the_defaults_are_the_contents() -> void:
	var db := _db()
	var s := HarnessSetup.defaults(db)
	assert_eq(s.team, db.default_team(), "the starting team")
	assert_true(s.loadouts.is_empty(), "in stock")
	var fac := db.default_faction()
	var table: Array = []
	for e in db.spawn_table(fac, 1):
		table.append([str(e[0]), int(e[1])])
	assert_eq(s.packs, table, "a fight against the first faction's spawn list")
	assert_eq(s.boss, str(db.bosses_of(fac)[0]), "and its first boss")
	assert_eq(s.battle_domain(), fac, "a battle against the first domain")
	assert_eq(s.battle_boss_id(), str(db.bosses_of(fac)[0]), "and its first boss")
	for b in s.bosses():
		assert_false(s.pack_foes().has(b), "a boss is never a pack's foe")


func test_a_refit_reaches_the_machines_die() -> void:
	var db := _db()
	var pair := _refit_pair(db)
	assert_false(pair.is_empty(), "the content has a machine to refit")
	var id: String = pair[0]
	var cid: String = pair[1]
	var s := HarnessSetup.defaults(db)
	s.team = [id]
	var stock := s.stock_picks(id)
	assert_eq(stock.size(), int(db.chassis[id]["hardpoints"]), "one pick per hardpoint")
	s.set_pick(id, 0, cid)
	s.set_pick(id, 1, "")
	assert_true(s.is_refit(id), "an edit is a refit")
	var want: Array = [cid]
	for k in range(2, stock.size()):
		if not str(stock[k]).is_empty():
			want.append(stock[k])
	assert_eq(s.fitted(id), want, "the empty hardpoint drops out of the loadout")
	var u: Unit = s.make_team()[0]
	var fixed: Array = db.chassis[id].get("fixed", [])
	assert_eq(u.die.faces.size(), fixed.size() + stock.size(), "the die is still every fixed component and every hardpoint")
	assert_eq(u.die.faces[fixed.size()].component, cid, "the refit takes the first hardpoint's entry")
	var empties := 0
	for f in u.die.faces:
		if f.component.is_empty():
			empties += 1
	assert_eq(empties, stock.size() - want.size(), "and the emptied hardpoint is an empty entry")
	s.set_pick(id, 0, str(stock[0]))
	s.set_pick(id, 1, str(stock[1]))
	assert_false(s.is_refit(id), "edited back to stock, the edit is forgotten")


## A fight by hand is one unit, as the game deals one (one pack is one fight): the packs' foes as
## one pack's members, or with a boss picked, its escort; with no packs, the boss's own curated
## escort at the fight's tier, or the boss alone; what the slots cannot hold is left out.
func test_a_fight_by_hand_is_one_unit() -> void:
	var db := _db()
	var s := HarnessSetup.defaults(db)
	var foes := s.pack_foes()
	s.packs = [[str(foes[0]), 1], [str(foes[foes.size() - 1]), 1]]
	s.boss = ""
	var sk := s.make_skirmish()
	assert_eq(sk.mechs.size(), s.team.size(), "the team")
	assert_eq(sk.packs.size(), 1, "one pack")
	assert_eq(sk.packs[0].member_list(), [[str(foes[0]), 1], [str(foes[foes.size() - 1]), 1]], "of the packs' foes")
	s.boss = str(s.bosses()[0])
	sk = s.make_skirmish()
	assert_eq(sk.packs.size(), 1, "with a boss, still one unit")
	assert_true(sk.packs[0].is_boss, "the boss's")
	assert_eq(sk.reinforcements.filter(func(f) -> bool: return f.escorts).size(), 2, "the packs' foes its escort")
	s.packs = [[str(foes[0]), HarnessSetup.MAX_STRENGTH]]
	s.boss = ""
	sk = s.make_skirmish()
	sk.begin()
	assert_true(sk.reinforcements.is_empty(), "what the slots cannot hold was left out before the fight")
	assert_true(sk.field_foes().size() <= 8, "the fight is one the game could deal")
	s.packs = []
	s.boss = str(s.bosses()[0])
	sk = s.make_skirmish()
	var own := db.escort_composition(db.faction_of_foe(s.boss), s.fight_tier, s.boss)
	var want := 0
	if str(own.get("boss", "")) == s.boss:
		for m in own["members"]:
			want += int(m[1])
	assert_eq(sk.reinforcements.filter(func(f) -> bool: return f.escorts).size(), want, "no packs: its own curated escort at the tier, or none")
	s.boss = ""
	assert_true(s.make_skirmish() == null, "nothing to fight")
	s.boss = str(s.bosses()[0])
	s.team = []
	assert_true(s.make_skirmish() == null, "nobody to fight it")

## A battle as a run deals it (Ryan, 7 November: "The Battle from the harness should be a battle,
## as it will be in the final game"): the domain picked at the tier and the ramp, its boss, the
## guest's compositions taking turns, on the seed's map; the fight's packs touch it nowhere.
func test_a_battle_is_dealt_as_a_run_deals_it() -> void:
	var db := _db()
	var facs: Array = db.factions.keys()
	var s := HarnessSetup.defaults(db)
	var fac := str(facs[1])
	var bosses := db.bosses_of(fac)
	s.battle_faction = fac
	s.battle_boss = str(bosses[bosses.size() - 1])
	s.guest = str(facs[2]) if facs.size() > 2 else ""
	s.battle_tier = 2
	s.ramp = 4
	s.map_kind = str(BattleMap.KINDS.keys()[1])
	s.seed_value = 11
	s.packs = [[str(s.pack_foes()[0]), 2]]   # the fight's: no part of a battle
	var b := s.make_battle()
	assert_eq(b.faction, fac, "the domain picked")
	assert_eq(str(b.boss.lineup[0]), s.battle_boss, "its boss picked")
	assert_eq([b.tier, b.ramp], [1, 4], "at the tier and the ramp")
	assert_eq(b.map.kind, s.map_kind, "on the chosen ground")
	assert_eq(b.seed_value, 11, "from the seed")
	assert_eq(b.guest, s.guest, "with the guest")
	var dealt := {}
	for who in [fac, s.guest]:
		for size in ["formation", "patrol"]:
			for c in db.compositions(str(who), 2, size) + db.compositions(str(who), 2, size, -1, ContentDB.GRADED):
				dealt[str(c["id"])] = true
	for sq in b.field.packs():
		if not sq.is_boss:
			assert_true(dealt.has(sq.composition), "%s: one of the tier's compositions, as a run deals them" % sq.composition)
	var waves := tide_lists(b.field)
	assert_false(waves.is_empty(), "the tide has its lists")
	for w in waves:
		assert_true(dealt.has(str(w["id"])), "and so is every pack the tide holds (%s)" % str(w["id"]))
	s.guest = fac
	assert_eq(s.make_battle().guest, "", "the domain itself is no guest")
	s.battle_boss = "no_such_boss"
	assert_eq(str(s.make_battle().boss.lineup[0]), str(bosses[0]), "a boss not the domain's: its first")
	s.team = []
	assert_true(s.make_battle() == null, "nobody to fight it")


func test_the_setup_is_kept_and_checked_against_the_content() -> void:
	var db := _db()
	var pair := _refit_pair(db)
	var id: String = pair[0]
	var s := HarnessSetup.defaults(db)
	var other := str(db.chassis.keys()[db.chassis.size() - 1] if db.chassis.keys()[0] == id else db.chassis.keys()[0])
	s.team = [other, id]
	s.set_pick(id, 0, pair[1])
	s.packs = [[str(s.pack_foes()[0]), 5]]
	s.seed_value = 42
	SaveGame.clear(TMP)
	s.save(TMP)
	var back := HarnessSetup.load_or_default(db, TMP)
	SaveGame.clear(TMP)
	assert_eq(back.to_dict(), s.to_dict(), "what was launched comes back")
	var d := s.to_dict()
	d["team"] = ["no_such_chassis", id, id]
	d["loadouts"] = {id: [pair[1], "no_such_component"], "no_such_chassis": []}
	d["packs"] = [["no_such_foe", 3], [str(s.pack_foes()[0]), 99], [str(s.bosses()[0]), 1]]
	d["boss"] = "no_such_boss"
	d["guest"] = "no_such_faction"
	d["map_kind"] = "no_such_kind"
	d["seed"] = -4
	d["battle_faction"] = "no_such_faction"
	d["battle_boss"] = "no_such_boss"
	d["battle_tier"] = 9
	d["ramp"] = -3
	d.erase("fight_tier")
	d["tier"] = 3   # the fight's tier as a harness saved it before the tabs parted
	var checked := HarnessSetup.from_dict(d, db)
	assert_eq(checked.team, [id], "unknown and repeated machines drop out")
	var p := checked.picks(id)
	assert_eq(p.size(), int(db.chassis[id]["hardpoints"]), "a loadout is padded to its hardpoints")
	assert_eq([p[0], p[1]], [pair[1], ""], "an unknown component is an empty hardpoint")
	assert_eq(checked.packs, [[str(s.pack_foes()[0]), HarnessSetup.MAX_STRENGTH]], "unknown foes and bosses drop out of the packs, strength is clamped")
	assert_eq([checked.boss, checked.guest, checked.map_kind, checked.seed_value], ["", "", "", 1], "and the rest falls back, the map to the shape its seed draws")
	assert_eq([checked.battle_faction, checked.battle_boss, checked.battle_tier, checked.ramp], ["", "", 3, 0], "the battle's too, its numbers clamped")
	assert_eq(checked.fight_tier, 3, "and a fight's tier saved under its old key read")
	assert_eq(HarnessSetup.load_or_default(db, TMP).to_dict(), HarnessSetup.defaults(db).to_dict(), "nothing kept: the defaults")


func test_the_harness_drives_the_setup() -> void:
	var db := _db()
	var pair := _refit_pair(db)
	var id: String = pair[0]
	var h: Control = HARNESS.new()
	var s := HarnessSetup.defaults(db)
	s.team = []
	h.build(s)
	assert_eq(h._pages.size(), 4, "four tabs: the team, the battle, the fight and the setup")
	assert_true(h._pages[0].visible and not h._pages[1].visible, "the team's showing")
	assert_true(h._battle_btn.disabled and h._fight_btn.disabled, "nobody ticked: nothing to launch")
	h._rows[id]["check"].button_pressed = true
	assert_eq(s.team, [id], "a tick deploys")
	assert_false(h._battle_btn.disabled, "and the battle can launch")
	h._toggle_loadout(id)
	var pickers: Array = []
	var module_pickers: Array = []
	for line in h._rows[id]["editor"].get_children():
		for ch in line.get_children():
			if ch is OptionButton:
				var tag: String = (line.get_child(0) as Label).text
				if tag.begins_with("UPG"):
					continue   # its upgrades' build, beside the hardpoints
				(module_pickers if tag.begins_with("MOD") else pickers).append(ch)
	assert_eq(pickers.size(), int(db.chassis[id]["hardpoints"]), "one picker per hardpoint")
	assert_eq(module_pickers.size(), int(db.chassis[id]["module_slots"]), "and one per module slot")
	var mob: OptionButton = module_pickers[0]
	var mk: int = h._index_of(mob, str(db.modules.keys()[0]))
	mob.select(mk)
	mob.item_selected.emit(mk)
	assert_eq(s.fitted_modules(id), [str(db.modules.keys()[0])], "a module pick is the setup's")
	assert_true(h._rows[id]["status"].text.contains("modules: "), "the row names it")
	mob.select(0)
	mob.item_selected.emit(0)
	assert_true(s.fitted_modules(id).is_empty(), "and the slot empties again")
	var ob: OptionButton = pickers[0]
	var k: int = h._index_of(ob, pair[1])
	ob.select(k)
	ob.item_selected.emit(k)
	assert_eq(s.picks(id)[0], pair[1], "a pick is the setup's")
	assert_true(h._rows[id]["status"].text.begins_with("REFIT"), "the row says it is refitted")
	assert_true(h._summary.text.contains("(refit)"), "and so does the summary")
	var stock_btn: Button = null
	for line in h._rows[id]["editor"].get_children():
		for ch in line.get_children():
			if ch is Button and not (ch is OptionButton) and ch.text == "Stock":
				stock_btn = ch
	stock_btn.pressed.emit()
	assert_false(s.is_refit(id), "Stock puts the stock loadout back")
	assert_true(h._rows[id]["status"].text.begins_with("stock"), "and the row says so")
	h._select_tab(1)
	assert_true(h._pages[1].visible and not h._pages[0].visible, "the battle's showing")
	var other := str(db.factions.keys()[db.factions.size() - 1])
	var di: int = h._index_of(h._battle_domain, other)
	h._battle_domain.select(di)
	h._battle_domain.item_selected.emit(di)
	assert_eq(s.battle_domain(), other, "a domain picked is the battle's")
	assert_eq(h._battle_boss.item_count, db.bosses_of(other).size(), "its bosses listed")
	assert_eq(str(h._battle_boss.get_item_metadata(h._battle_boss.selected)), str(db.bosses_of(other)[0]), "its first picked")
	assert_true(h._summary.text.contains("BATTLE  " + str(db.factions[other].get("name", other))), "the summary names it")
	h._select_tab(2)
	assert_true(h._pages[2].visible and not h._pages[1].visible, "the fight's showing")
	var before := s.packs.size()
	h._on_add_pack()
	assert_eq(s.packs.size(), before + 1, "a pack added")
	assert_eq(h._packs_box.get_child_count(), before + 1, "with its row")
	s.packs.clear()
	h._fill_packs()
	h._refresh_summary()
	assert_false(h._battle_btn.disabled, "a battle needs no packs: a run deals it")
	assert_false(h._fight_btn.disabled, "the boss alone is still a fight")
	h.free()


## The harness's pages scroll from anywhere on them, as the quick campaign's lists (2 November):
## a picker opens on a tap's lift, never on the touch, so a drag that starts on one scrolls the
## page and opens nothing. Live: the harness in the tree over the saved setup or the defaults, a
## finger's events pushed through its viewport as the phone's arrive.
func live_test_a_drag_over_a_picker_scrolls_the_page_and_a_tap_opens_it() -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(720, 1280)
	vp.gui_embed_subwindows = true   # the picker's list opens inside it
	(Engine.get_main_loop() as SceneTree).root.add_child(vp)
	var h: Control = HARNESS.new()
	vp.add_child(h)
	var id := str(h._rows.keys()[0])
	h._toggle_loadout(id)
	_lay_out(vp)
	var ob: OptionButton = null
	for line in h._rows[id]["editor"].get_children():
		for ch in line.get_children():
			if ch is OptionButton and ob == null:
				ob = ch
	assert_true(ob != null and ob.is_visible_in_tree(), "the first machine's editor open with a picker")
	var presses := [0]
	ob.pressed.connect(func() -> void: presses[0] += 1)
	var page: ScrollContainer = h._pages[0]
	var before := page.scroll_vertical
	_drag(vp, ob.get_global_rect().get_center(), Vector2(0, -200))
	assert_true(page.scroll_vertical >= before + 150, "a drag that starts on a picker scrolls the page (%d to %d)" % [before, page.scroll_vertical])
	assert_eq(presses[0], 0, "and opens nothing")
	assert_false(ob.get_popup().visible, "its list shut")
	_lay_out(vp)
	var at := ob.get_global_rect().get_center()
	_finger(vp, at, true)
	assert_eq(presses[0], 0, "a touch alone opens nothing yet")
	_finger(vp, at, false)
	assert_eq(presses[0], 1, "a tap opens it on the lift")
	assert_true(ob.get_popup().visible, "its list out")
	ob.get_popup().hide()
	vp.free()


func test_modules_reach_the_machine_and_survive_a_save() -> void:
	var db := _db()
	var id := ""
	for cid in db.chassis.keys():
		if int(db.chassis[cid].get("module_slots", 0)) >= 2:
			id = str(cid)
			break
	assert_false(id.is_empty(), "the content has a machine with two module slots")
	assert_false(db.modules.is_empty(), "and modules to fit")
	var mid: String = db.modules.keys()[0]
	var s := HarnessSetup.defaults(db)
	s.team = [id]
	assert_eq(s.module_picks(id).size(), int(db.chassis[id]["module_slots"]), "one pick per slot")
	assert_true(s.fitted_modules(id).is_empty(), "none fitted by default")
	s.set_module(id, 1, mid)
	s.set_module(id, 0, "no_such_module")
	assert_eq(s.fitted_modules(id), [mid], "a known module fits, an unknown one leaves the slot empty")
	var u: Unit = s.make_team()[0]
	assert_eq(Array(u.modules), [mid], "the machine wears it")
	var back := HarnessSetup.from_dict(JSON.parse_string(JSON.stringify(s.to_dict())), db)
	assert_eq(back.fitted_modules(id), [mid], "and it survives a save")
	s.set_module(id, 1, "")
	assert_false(s.modules.has(id), "a machine with every slot empty forgets the edit")


## A composition by its domain, tier and threat rating (Ryan, 6 November: the harness "should
## load a formation from a selected tier and threat level (the machine count, 1-4 that includes
## elites)"): the list follows the knobs; picked, FIGHT fights it alone, its members as content
## writes them (the ramp scales no pack, 7 November); a battle never takes it; the pick is kept and
## checked as the rest of the setup is; the FIGHT tab drives it.
func test_a_composition_is_picked_by_tier_and_rating() -> void:
	var db := _db()
	var s := HarnessSetup.defaults(db)
	var fac := str(db.factions.keys()[0])
	s.comp_faction = fac
	s.fight_tier = 1
	s.rating = 0
	var all := s.compositions_listed()
	assert_true(not all.is_empty(), "the domain's tier-one compositions are listed")
	for r in [1, 3, 4]:
		s.rating = r
		for c in s.compositions_listed():
			assert_eq(ContentDB.squad_of(c), r, "rated %d: %s" % [r, str(c["id"])])
	s.rating = 3
	var forms := s.compositions_listed()
	assert_true(not forms.is_empty(), "a formation is listed at its rating")
	var c: Dictionary = forms[0]
	s.composition = str(c["id"])
	var sk := s.make_skirmish()
	assert_true(sk != null, "FIGHT fights it")
	var want := 0
	var ids: Array = []
	for m in c["members"]:
		want += int(m[1])
		ids.append(str(m[0]))
	var got := 0
	for f in sk.reinforcements:
		got += 1 if ids.has((f as Foe).content_id) else 0
	assert_eq(got, want, "its members as content writes them (any parts beside them)")
	assert_eq(sk.packs.size(), 1, "and it alone")
	s.battle_tier = 2
	var b := s.make_battle()
	assert_eq(b.tier, 1, "a battle takes its own tier, never the fight's")
	var only_it := true
	for w in tide_lists(b.field):
		only_it = only_it and str(w["id"]) == str(c["id"])
	assert_false(only_it, "nor the composition picked: a run's waves")
	s.save(TMP)
	var back := HarnessSetup.load_or_default(db, TMP)
	assert_eq(back.composition, s.composition, "the pick is kept")
	assert_eq([back.fight_tier, back.rating, back.comp_faction], [1, 3, fac], "with its knobs")
	back.rating = 1
	assert_true(back.picked_composition().is_empty(), "a pick no longer listed is no pick")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TMP))
	var h: Control = HARNESS.new()
	var hs := HarnessSetup.defaults(db)
	hs.comp_faction = fac
	hs.rating = 3
	h.build(hs)
	var k: int = h._index_of(h._comp, str(c["id"]))
	assert_true(k > 0, "the tab lists it")
	h._comp.select(k)
	h._comp.item_selected.emit(k)
	assert_eq(hs.composition, str(c["id"]), "a pick on the tab is the setup's")
	assert_true(h._summary.text.contains("FIGHT  " + str(c["id"])), "and the summary names it")
	assert_false(h._battle_btn.disabled or h._fight_btn.disabled, "both launch")
	h.free()


## The trials' page holds what is tried in person and nothing else (Ryan, 24 November: "clean up
## the trials tab. Remove anything no longer relevant ... just what is actually needed to try in
## person versus just chatting it out"): the sends, the strike, the pack bonus, the field's depth
## and when Phased lands, each the game's own until a debug build's setting or the environment
## asks, read only where the game starts a battle; one set lays the page back at the game's own;
## and the dials that left have no row, the tide's among them (the graded tide is the game's,
## Ryan, 25 November: "Go ahead with the switch-over").
func test_the_trials_page_holds_what_is_tried_in_person() -> void:
	for env in ["RIFTGATE_SENDS", "RIFTGATE_STRIKE", "RIFTGATE_PACK_BONUS", "RIFTGATE_FIELD_DEPTH", "RIFTGATE_OPENING", "RIFTGATE_BEATS", "RIFTGATE_LEADERS"]:
		if not OS.get_environment(env).is_empty():
			return
	# Each dial asked off the game's own, on an option of its row.
	var asked := {"mouth_sends": "3", "wall_strike": "10", "pack_bonus": "100", "field_depth": "16"}
	var was := {}
	for key in Settings.TRIAL_KEYS:
		was[key] = Settings.display.get(key, Settings.DISPLAY_DEFAULTS[key])
	for key in asked:
		assert_ne(str(asked[key]), str(Settings.DISPLAY_DEFAULTS[key]), "%s is asked off the game's own" % key)
		Settings.display[key] = asked[key]
	var read := func() -> Array: return [Battlefield.sends_trial, Battlefield.strike_trial, Battle.pack_bonus_trial, Ramp.depth_trial]
	var answers := func() -> Array: return [Battlefield.sends_a_peak(), Battlefield.strike_per_pip(), Battle.pack_bonus(), Ramp.depth_at(0)]
	var own := [0, 0, -1, 0]   # every dial at the value that reads as the game's own
	Settings.field_trial()
	assert_eq(read.call(), own, "run alone, the saved settings move nothing")
	var games: Array = answers.call()
	assert_eq(games.slice(0, 3), [Battlefield.SENDS_A_PEAK, Battlefield.STRIKE_PER_PIP, Battle.PACK_BONUS], "and the field answers with the game's own sends, strike and pack bonus")
	Settings.field_trial(true)
	assert_eq(read.call(), [3, 10, 100, 16] if OS.is_debug_build() else own, "where the game starts a battle, a debug build's settings are the trial")
	assert_eq(answers.call(), [3, 10, 100, 16] if OS.is_debug_build() else games, "and the field answers with the sends, the strike and the pack bonus, the ramp with the depth")
	for key in asked:
		Settings.display[key] = "a lot"
	Settings.field_trial(true)
	assert_eq(read.call(), own, "a value that is no option asks for nothing")
	# The game's own number on a dial is the game's, by whichever road: the strike reads as no
	# trial, and the sends and the pack bonus answer as the game's do.
	for key in Settings.TRIAL_KEYS:
		Settings.display[key] = Settings.DISPLAY_DEFAULTS[key]
	Settings.field_trial(true)
	assert_eq(Battlefield.strike_trial, 0, "the game's own strike is no trial")
	assert_eq(answers.call(), games, "and the page as it ships is the game's own field")
	# A pack bonus of none is a trial of its own, never the game's: the dial's NONE.
	Settings.display["pack_bonus"] = "0"
	Settings.field_trial(true)
	assert_eq([Battle.pack_bonus_trial, Battle.pack_bonus()], [0, 0] if OS.is_debug_build() else [-1, Battle.PACK_BONUS], "NONE asks for no bonus where the game's own is one")
	Settings.display["pack_bonus"] = Settings.DISPLAY_DEFAULTS["pack_bonus"]
	Settings.field_trial(true)
	# The dials that left the page: a build's saved setting for one moves nothing, and none is a
	# setting. Three stay the runners' what-ifs by the environment alone, and the tide's left with
	# its question: the graded tide is the game's only one.
	var gone := {"tide_form": "built", "field_opening": "2", "fodder_worth": "50", "rupture_beats": "3", "tide_density": "200", "pack_pace": "2", "rift_sends": "3", "flank_tears": "4", "leader_step": "20", "formation_form": "fodder", "overheat_burn": "2"}
	for key in gone:
		assert_false(Settings.DISPLAY_DEFAULTS.has(key), "%s is no setting" % key)
		Settings.display[key] = gone[key]
	Settings.field_trial(true)
	assert_eq([Battle.opening_trial, Ramp.beats_trial, ContentDB.leader_step_trial, Skirmish.overheat_scale], [0, 0, 0, 1], "a dial an older build saved moves nothing")
	assert_eq(answers.call(), games, "and the field is the game's own still")
	for key in gone:
		Settings.display.erase(key)
	assert_false(Settings.DISPLAY_DEFAULTS.has("reboot") or Settings.DISPLAY_DEFAULTS.has("shield_regen") or Settings.DISPLAY_DEFAULTS.has("shield_break"), "the reboot is the rule and no dial (folded in 15 November), the regen's dial went with the regen, and the block's with the rule that a blow past the shield reaches the hull")
	# The page's keys and its set.
	assert_eq(Settings.TRIAL_KEYS, ["mouth_sends", "wall_strike", "pack_bonus", "field_depth", "phased_form"], "five dials")
	for key in Settings.TRIAL_KEYS:
		assert_true(Settings.DISPLAY_DEFAULTS.has(key), "%s is a setting" % key)
	assert_eq([str(Settings.DISPLAY_DEFAULTS["mouth_sends"]), str(Settings.DISPLAY_DEFAULTS["wall_strike"]), str(Settings.DISPLAY_DEFAULTS["pack_bonus"]), str(Settings.DISPLAY_DEFAULTS["field_depth"])], [str(Battlefield.SENDS_A_PEAK), str(Battlefield.STRIKE_PER_PIP), str(Battle.PACK_BONUS), str(games[3])], "each ships on the game's own")
	var options := {"mouth_sends": Settings.SENDS, "wall_strike": Settings.STRIKES, "pack_bonus": Settings.PACK_BONUSES, "field_depth": Settings.FIELD_DEPTHS, "phased_form": Settings.PHASED_FORMS}
	for key in Settings.TRIAL_KEYS:
		assert_true(options.has(key) and (options[key] as Array).has(str(Settings.DISPLAY_DEFAULTS[key])), "the game's own %s is an option of its dial, so GAME'S OWN lays it on a button" % key)
	if OS.is_debug_build():
		var menu := PauseMenu.new()
		menu._show_page("settings")
		assert_true(_menu_labels(menu).has("TRIALS"), "a debug build's settings page opens the trials' page")
		for d in Settings.FIELD_DEPTHS:
			assert_false(_menu_labels(menu).has(str(d)), "and carries none of their rows itself (%s)" % d)
		Settings.display["mouth_sends"] = asked["mouth_sends"]   # one dial off the game's own
		menu._show_page("trials")
		var labels := _menu_labels(menu)
		for want in ["GAME'S OWN", "+½", "+1", "NONE", "BACK"] + Settings.FIELD_DEPTHS + Settings.SENDS + Settings.STRIKES:
			assert_true(labels.has(str(want)), "the trials' page offers %s" % str(want))
		for left in ["GRADED", "BUILT", "AS BUILT"]:
			assert_false(labels.has(left), "and no %s: the tide's row and its sets left the page" % left)
		var captions: Array = []
		for l in menu._rows.find_children("*", "Label", true, false):
			captions.append(str((l as Label).text))
		assert_eq(captions.filter(func(c: String) -> bool: return c == c.to_upper() and c.length() <= 12), ["TRIALS", "SET", "SENDS", "STRIKE", "PACK BONUS", "FIELD DEPTH", "PHASED"], "its title and its rows, and no other")
		assert_eq(_set_buttons(menu, "GAME'S OWN"), [false], "one set, unfilled while a dial stands off the game's own")
		Settings.display["mouth_sends"] = Settings.DISPLAY_DEFAULTS["mouth_sends"]
		menu._show_page("trials")
		assert_eq(_set_buttons(menu, "GAME'S OWN"), [true], "and filled while every dial stands as it lays it")
		assert_eq(menu._trials_as_built().keys().size(), Settings.TRIAL_KEYS.size(), "GAME'S OWN names every trial dial")
		for key in Settings.TRIAL_KEYS:
			assert_eq(str(menu._trials_as_built()[key]), str(Settings.DISPLAY_DEFAULTS[key]), "at the game's own (%s)" % key)
		menu.free()
	for key in was:
		Settings.display[key] = was[key]
	Settings.field_trial()


## Whether each button reading `text` on the menu's page is filled, in the page's order.
func _set_buttons(menu: PauseMenu, text: String) -> Array:
	var out: Array = []
	for btn in menu._rows.find_children("*", "", true, false):
		if btn is HudButton and str((btn as HudButton).text) == text:
			out.append((btn as HudButton).filled)
	return out


## A lone fight from the menu reads the fight's trials as a battle does (when Phased lands is a
## fight's): a dial set inside one fight is the next one's, with no relaunch. The launch here has
## nobody to fight, so it stops before it saves or shows.
func test_a_lone_fight_from_the_menu_reads_the_trials() -> void:
	if not OS.get_environment("RIFTGATE_PHASED").is_empty():
		return
	var phased_was = Settings.display.get("phased_form", "round_end")
	var h: Control = HARNESS.new()
	var hs := HarnessSetup.defaults(_db())
	hs.team = []
	h.setup = hs
	Settings.display["phased_form"] = "at_once"
	Skirmish.phase_at_once = false
	h._on_fight()
	assert_eq(Skirmish.phase_at_once, OS.is_debug_build(), "a debug build's PHASED is the next lone fight's")
	Settings.display["phased_form"] = "round_end"
	h._on_fight()
	assert_false(Skirmish.phase_at_once, "and the game's own again with the dial")
	Settings.display["phased_form"] = phased_was
	Settings.field_trial()
	h.free()


## The text of every button a menu page shows.
func _menu_labels(menu: PauseMenu) -> Array:
	var labels: Array = []
	for b in menu._rows.find_children("*", "", true, false):
		if b is HudButton:
			labels.append(str((b as HudButton).text))
	return labels


## The machines back in design (the refit pass's four since its model landed, 10 November; a
## chassis whose entry says so) are left out of the harness: no row to tick, none deployed, the
## launch greyed when nobody else is ticked, and the team as it was ticked kept for when one is
## handed back (never saved over).
func test_a_machine_back_in_design_has_no_row_and_the_team_as_ticked_is_kept() -> void:
	var db := ContentDB.new()   # its own copy: the test sends one back and hands it back
	db.load_dir(ContentDB.DIR)
	var ids: Array = []
	for id in db.chassis.keys():
		if db.chassis_runnable(str(id)):
			ids.append(str(id))
	var out: String = str(ids[0])
	var kept: String = str(ids[1])
	db.chassis[out]["status"] = "planned"
	var h: Control = HARNESS.new()
	var s := HarnessSetup.defaults(db)
	s.team = [out, kept]
	h.build(s)
	assert_false(h._rows.has(out), "the machine back in design has no row to tick")
	assert_true(h._rows.has(kept), "the others keep theirs")
	assert_eq(s.fielded(), [kept], "the team that deploys leaves it out")
	var mechs := s.make_team()
	assert_eq(mechs.size(), 1, "one machine is made")
	assert_eq(str(mechs[0].chassis_id), kept, "the one still fielded")
	assert_eq(s.team, [out, kept], "and the team as ticked is kept")
	assert_false(h._summary.text.contains(str(db.chassis[out]["name"])), "the summary names only who deploys: %s" % h._summary.text)
	assert_eq(Array(s.to_dict()["team"]), [out, kept], "a save keeps the ticks")
	s.team = [out]
	h._refresh_summary()
	assert_true(h._battle_btn.disabled and h._fight_btn.disabled, "only a machine back in design ticked: nothing to launch")
	h.free()
	db.chassis[out].erase("status")
	var plain: Control = HARNESS.new()
	var s2 := HarnessSetup.defaults(db)
	s2.team = [out, kept]
	plain.build(s2)
	assert_true(plain._rows.has(out) and s2.fielded() == [out, kept], "handed back, it has its row and deploys")
	plain.free()
	var real := _db()
	var benched := 0
	var live: Control = HARNESS.new()
	live.build(HarnessSetup.defaults(real))
	for id in real.chassis.keys():
		if not real.chassis_runnable(str(id)):
			benched += 1
			assert_false(live._rows.has(str(id)), "%s is back in design in content: no row" % id)
	assert_true(benched > 0, "content has machines back in design")
	live.free()


## The refit pass's what-ifs are off until the environment asks (docs/briefs/refit_pass.md; the
## model itself is content): RIFTGATE_REFIT names a spec and nothing else does. The dials that
## named its parts left the trials' page with their questions (Ryan, 23 November: "We can lock in
## the rank and file setting as 4, heat as built, top basic as built, and overheat at x1"; "barrier
## basic yes, for now at least"), so what a build saved for one asks for nothing.
func test_the_refit_what_if_is_off_until_the_environment_asks() -> void:
	if not OS.get_environment("RIFTGATE_REFIT").is_empty():
		assert_eq(HARNESS.refit_spec(), OS.get_environment("RIFTGATE_REFIT"), "the environment's spec is the what-if's")
		return
	assert_eq(HARNESS.refit_spec(), "", "as built by default: the game plays the content as written")
	var old := {"heat_trial": "-1", "top_basic_heat": "2", "rank_hp": "1", "barrier_basic": "none", "overheat_burn": "2", "basic_guns": "1", "foe_breach": "cut", "shield_regen": "2"}
	for key in old:
		assert_false(Settings.DISPLAY_DEFAULTS.has(key), "%s is no setting: its question is answered" % key)
		Settings.display[key] = old[key]
	assert_eq(HARNESS.refit_spec(), "", "a dial an older build saved is no part of the spec")
	for key in old:
		Settings.display.erase(key)
	if OS.is_debug_build():
		var menu := PauseMenu.new()
		menu._show_page("trials")
		var captions: Array = []
		for l in menu._rows.find_children("*", "Label", true, false):
			captions.append(str((l as Label).text))
		for gone in ["HEAT", "TOP BASIC", "RANK AND FILE", "OVERHEAT", "BARRIER BASIC", "FOE BREACH", "BASIC GUNS", "REBOOT", "SHIELD REGEN", "SHIELD BREAK", "SPAWNS"]:
			assert_false(captions.has(gone), "no row for %s: %s" % [gone, str(captions)])
		assert_true(captions.has("STRIKE") and captions.has("PHASED"), "the page keeps the dials whose questions are open: %s" % str(captions))
		assert_true(menu._list != null and menu._list.is_ancestor_of(menu._rows.find_children("*", "BaseButton", true, false)[0]), "the dials stand in a scroller, so a short glass holds them")
		menu.free()
