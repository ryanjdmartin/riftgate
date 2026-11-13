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
			for c in db.compositions(str(who), 2, size):
				dealt[str(c["id"])] = true
	for sq in b.field.packs():
		if not sq.is_boss:
			assert_true(dealt.has(sq.composition), "%s: one of the tier's compositions, as a run deals them" % sq.composition)
	for w in b.field.cycle:
		assert_true(dealt.has(str(w["id"])), "and so is every wave")
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
	for w in b.field.cycle:
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


## The field's trial is the game's own field until something asks (Ryan, 10 November, the map "a
## bit too shallow"): a debug build's settings where the game starts a battle, the
## environment anywhere, and a scene run alone or a test never reads a machine's saved settings.
func test_the_fields_trial_reads_the_settings_only_where_the_game_starts_a_battle() -> void:
	if not OS.get_environment("RIFTGATE_FIELD_DEPTH").is_empty() or not OS.get_environment("RIFTGATE_OPENING").is_empty():
		Settings.field_trial()
		assert_true(Ramp.depth_trial > 0 or Battle.opening_trial > 0, "the environment's trial is the field's")
		return
	var depth_was = Settings.display.get("field_depth", "12")
	var opening_was = Settings.display.get("field_opening", "0")
	var fodder_was = Settings.display.get("fodder_worth", "100")
	var beats_was = Settings.display.get("rupture_beats", "2")
	var tide_was = Settings.display.get("tide_density", "100")
	var strike_was = Settings.display.get("wall_strike", "10")
	var burn_was = Settings.display.get("overheat_burn", "1")
	var break_was = Settings.display.get("shield_break", "off")
	var reboot_was = Settings.display.get("reboot", "off")
	Settings.display["overheat_burn"] = "2"
	Settings.display["shield_break"] = "on"
	Settings.display["reboot"] = "on"
	Settings.display["tide_density"] = "150"
	Settings.display["wall_strike"] = "5"
	Settings.display["field_depth"] = "16"
	Settings.display["field_opening"] = "2"
	Settings.display["fodder_worth"] = "50"
	Settings.display["rupture_beats"] = "3"
	Settings.field_trial()
	assert_eq([Ramp.depth_trial, Battle.opening_trial, Battle.fodder_trial, Ramp.beats_trial], [0, 0, 100, 0], "run alone, the saved settings move nothing")
	assert_eq([Ramp.tide_trial, Battlefield.strike_trial], [100, 0], "nor the tide's density or the wall strike")
	assert_eq(Skirmish.overheat_scale, 1, "nor the overheat's burn")
	assert_eq([Skirmish.shield_break, Skirmish.reboot], [false, false], "nor the block or the reboot")
	Settings.field_trial(true)
	assert_eq([Ramp.depth_trial, Battle.opening_trial, Battle.fodder_trial, Ramp.beats_trial], [16, 2, 50, 3] if OS.is_debug_build() else [0, 0, 100, 0], "where the game starts a battle, a debug build's settings are the trial")
	assert_eq([Ramp.tide_trial, Battlefield.strike_trial], [150, 5] if OS.is_debug_build() else [100, 0], "the tide's density and the wall strike with them")
	assert_eq(Battlefield.strike_per_pip(), 5 if OS.is_debug_build() else Battlefield.STRIKE_PER_PIP, "and the field answers with the strike")
	assert_eq(Skirmish.overheat_scale, 2 if OS.is_debug_build() else 1, "the overheat's burn with them")
	assert_eq([Skirmish.shield_break, Skirmish.reboot], [true, true] if OS.is_debug_build() else [false, false], "and the block, a break stopping the blow whole, and the reboot")
	assert_eq(Ramp.beats_at(0), 3 if OS.is_debug_build() else Ramp.BEATS, "and the ramp answers with the beats")
	assert_eq(Ramp.depth_at(0), 16 if OS.is_debug_build() else 12, "and the ramp answers with it")
	Settings.display["field_depth"] = "a mile"
	Settings.display["field_opening"] = "far"
	Settings.display["fodder_worth"] = "a pittance"
	Settings.display["rupture_beats"] = "an age"
	Settings.display["tide_density"] = "a flood"
	Settings.display["wall_strike"] = "a tap"
	Settings.display["overheat_burn"] = "a furnace"
	Settings.display["shield_break"] = "a wall"
	Settings.display["reboot"] = "2"
	Settings.field_trial(true)
	assert_eq([Ramp.depth_trial, Battle.opening_trial, Battle.fodder_trial, Ramp.beats_trial], [0, 0, 100, 0], "a value that is no option asks for nothing")
	assert_eq([Ramp.tide_trial, Battlefield.strike_trial], [100, 0], "of the tide or the strike either")
	assert_eq(Skirmish.overheat_scale, 1, "or of the overheat")
	assert_eq([Skirmish.shield_break, Skirmish.reboot], [false, false], "or of the shield or the reboot: a rest of two rounds, the old dial's, is no option now")
	Settings.display["shield_break"] = "off"
	Settings.display["reboot"] = "off"
	Settings.field_trial(true)
	assert_eq([Skirmish.shield_break, Skirmish.reboot], [false, false], "and the game's own shield and heat are no trial")
	Settings.display["wall_strike"] = str(Battlefield.STRIKE_PER_PIP)
	Settings.field_trial(true)
	assert_eq(Battlefield.strike_trial, 0, "and the game's own strike is no trial")
	Settings.display["field_depth"] = depth_was
	Settings.display["field_opening"] = opening_was
	Settings.display["fodder_worth"] = fodder_was
	Settings.display["rupture_beats"] = beats_was
	Settings.display["tide_density"] = tide_was
	Settings.display["wall_strike"] = strike_was
	Settings.display["overheat_burn"] = burn_was
	Settings.display["shield_break"] = break_was
	Settings.display["reboot"] = reboot_was
	assert_eq(str(Settings.DISPLAY_DEFAULTS["shield_break"]), "off", "the shield ships honest, its number and the rest on the hull")
	assert_true(Settings.SHIELD_BREAKS.has("off"), "which is among its options")
	assert_eq(str(Settings.DISPLAY_DEFAULTS["reboot"]), "off", "and the game ships with its regen and its cooling: the reboot is a trial")
	assert_true(Settings.REBOOTS.has("off"), "which is among its options")
	assert_eq(str(Settings.DISPLAY_DEFAULTS["overheat_burn"]), "1", "the overheat ships at one hull a point")
	assert_eq([str(Settings.DISPLAY_DEFAULTS["tide_density"]), str(Settings.DISPLAY_DEFAULTS["wall_strike"])], ["100", str(Battlefield.STRIKE_PER_PIP)], "the tide and the strike ship on the game's own")
	assert_true(Settings.TIDES.has("100") and Settings.STRIKES.has(str(Battlefield.STRIKE_PER_PIP)), "which are among their options")
	assert_eq([str(Settings.DISPLAY_DEFAULTS["field_depth"]), str(Settings.DISPLAY_DEFAULTS["field_opening"]), str(Settings.DISPLAY_DEFAULTS["fodder_worth"]), str(Settings.DISPLAY_DEFAULTS["rupture_beats"])], ["12", "0", "100", str(Ramp.BEATS)], "all four ship on the game's own field and meter")
	assert_true(Settings.FIELD_DEPTHS.has("12") and Settings.FIELD_OPENINGS.has("0") and Settings.FODDER_WORTHS.has("100") and Settings.RUPTURE_BEATS.has(str(Ramp.BEATS)), "and the game's own is among the options")
	Ramp.depth_trial = 0
	Battle.opening_trial = 0
	Battle.fodder_trial = 100
	Ramp.beats_trial = 0
	Ramp.tide_trial = 100
	Battlefield.strike_trial = 0
	Skirmish.overheat_scale = 1
	Skirmish.shield_break = false
	Skirmish.reboot = false
	if OS.is_debug_build():
		var menu := PauseMenu.new()
		menu._show_page("settings")
		assert_true(_menu_labels(menu).has("TRIALS"), "a debug build's settings page opens the trials' page")
		for d in Settings.FIELD_DEPTHS:
			assert_false(_menu_labels(menu).has(str(d)), "and carries none of their rows itself (%s)" % d)
		menu._show_page("trials")
		var labels := _menu_labels(menu)
		for d in Settings.FIELD_DEPTHS:
			assert_true(labels.has(str(d)), "the trials' page offers the depth %s" % d)
		for o in Settings.FIELD_OPENINGS:
			assert_true(labels.has(str(Settings.FIELD_OPENING_LABELS[o])), "the opening %s" % Settings.FIELD_OPENING_LABELS[o])
		for f in Settings.FODDER_WORTHS:
			assert_true(labels.has(str(Settings.FODDER_WORTH_LABELS[f])), "and the fodder's worth %s" % Settings.FODDER_WORTH_LABELS[f])
		for r in Settings.RUPTURE_BEATS:
			assert_true(labels.has(str(Settings.RUPTURE_BEATS_LABELS[r])), "and the Rupture's beats %s" % Settings.RUPTURE_BEATS_LABELS[r])
		for t in Settings.TIDES:
			assert_true(labels.has(str(Settings.TIDE_LABELS[t])), "the tide's density %s" % Settings.TIDE_LABELS[t])
		for k in Settings.STRIKES:
			assert_true(labels.has(str(k)), "and the wall strike %s" % k)
		assert_true(labels.has("BACK"), "with its way back")
		menu.free()


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


## The refit pass's what-ifs are off until something asks (docs/briefs/refit_pass.md; the model
## itself is content): RIFTGATE_REFIT names a spec, or a debug build's SHIELD REGEN names a flat
## number in place of each chassis's own.
func test_the_refit_what_if_is_off_until_the_setting_or_the_environment_asks() -> void:
	if not OS.get_environment("RIFTGATE_REFIT").is_empty():
		assert_eq(HARNESS.refit_spec(), OS.get_environment("RIFTGATE_REFIT"), "the environment's spec is the what-if's")
		return
	var was = Settings.display.get("shield_regen", "built")
	var heat_was = Settings.display.get("heat_trial", "0")
	var barrier_was = Settings.display.get("barrier_basic", "built")
	Settings.display["shield_regen"] = "built"
	Settings.display["heat_trial"] = "0"
	Settings.display["barrier_basic"] = "built"
	assert_eq(HARNESS.refit_spec(), "", "as built by default: the game plays the content as written")
	# The Barrier basic's dial (13 November): off the stock dice, the same what-if.
	Settings.display["barrier_basic"] = "none"
	assert_eq(HARNESS.refit_spec(), "barrier=none" if OS.is_debug_build() else "", "a debug build's setting takes the Barrier basic off the stock dice")
	Settings.display["barrier_basic"] = "everywhere"
	assert_eq(HARNESS.refit_spec(), "", "a value that is no option asks for nothing")
	Settings.display["barrier_basic"] = "built"
	for regen in Settings.SHIELD_REGENS:
		Settings.display["shield_regen"] = regen
		var want: String = "" if regen == "built" or not OS.is_debug_build() else "regen=%s" % regen
		assert_eq(HARNESS.refit_spec(), want, "a debug build's setting names the flat regen: %s" % regen)
		if not want.is_empty():
			assert_eq(str(Refit.parse(want)["regen"]), regen, "and the what-if takes it")
		assert_true(Settings.SHIELD_REGEN_LABELS.has(regen), "%s has its button's label" % regen)
	Settings.display["shield_regen"] = "plenty"
	assert_eq(HARNESS.refit_spec(), "", "a value that is no option asks for nothing")
	# The heat's dial beside it (12 November): every weapon a point cooler or hotter than content
	# prices it, the hotter with more cooling to sustain it, the same what-if, alone or with the
	# regen's.
	Settings.display["shield_regen"] = "built"
	for heat in Settings.HEATS:
		Settings.display["heat_trial"] = heat
		var want_heat: String = "" if heat == "0" or not OS.is_debug_build() else str(Settings.HEAT_SPECS[heat])
		assert_eq(HARNESS.refit_spec(), want_heat, "a debug build's setting names the heat's prices: %s" % heat)
		if not want_heat.is_empty():
			var priced := Refit.parse(want_heat)
			assert_eq(int(priced["hotter"]), int(heat), "the what-if takes the price")
			assert_eq(int(priced["cooling"]) >= 1, int(heat) > 0, "a hotter price with more cooling to sustain it, a cooler one on the cooling as built")
		assert_true(Settings.HEAT_LABELS.has(heat), "%s has its button's label" % heat)
	Settings.display["shield_regen"] = "2"
	Settings.display["heat_trial"] = "1"
	if OS.is_debug_build():
		var both := Refit.parse(HARNESS.refit_spec())
		assert_eq([str(both["regen"]), int(both["hotter"]), int(both["cooling"])], ["2", 1, 1], "the two dials make one spec")
	Settings.display["heat_trial"] = "scalding"
	Settings.display["shield_regen"] = "built"
	assert_eq(HARNESS.refit_spec(), "", "a heat that is no option asks for nothing")
	Settings.display["shield_regen"] = was
	Settings.display["heat_trial"] = heat_was
	Settings.display["barrier_basic"] = barrier_was
	assert_eq(str(Settings.DISPLAY_DEFAULTS.get("barrier_basic", "")), "built", "the Barrier basic ships on the dice content gives it")
	assert_eq(str(Settings.DISPLAY_DEFAULTS.get("shield_regen", "")), "built", "and the setting ships as built")
	assert_eq(str(Settings.DISPLAY_DEFAULTS.get("heat_trial", "")), "0", "the heat's too")
	if OS.is_debug_build():
		var menu := PauseMenu.new()
		menu._show_page("trials")
		var labels := _menu_labels(menu)
		for regen in Settings.SHIELD_REGENS:
			assert_true(labels.has(str(Settings.SHIELD_REGEN_LABELS[regen])), "a debug build's trials page offers the regen %s" % Settings.SHIELD_REGEN_LABELS[regen])
		for heat in Settings.HEATS:
			assert_true(labels.has(str(Settings.HEAT_LABELS[heat])), "the heat's offset %s" % Settings.HEAT_LABELS[heat])
		for burn in Settings.OVERHEATS:
			assert_true(labels.has(str(Settings.OVERHEAT_LABELS[burn])), "and the overheat's burn %s" % Settings.OVERHEAT_LABELS[burn])
		for block in Settings.SHIELD_BREAKS:
			assert_true(labels.has(str(Settings.SHIELD_BREAK_LABELS[block])), "and the block %s" % Settings.SHIELD_BREAK_LABELS[block])
		for boot in Settings.REBOOTS:
			assert_true(labels.has(str(Settings.REBOOT_LABELS[boot])), "and the reboot %s" % Settings.REBOOT_LABELS[boot])
		for deal in Settings.BARRIER_BASICS:
			assert_true(labels.has(str(Settings.BARRIER_BASIC_LABELS[deal])), "and the Barrier basic's place %s" % Settings.BARRIER_BASIC_LABELS[deal])
		menu.free()
