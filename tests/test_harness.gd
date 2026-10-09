extends TestCase

## The harness: its setup (the team's loadouts and the enemy side it launches, kept between
## launches) and a headless drive of its tabs. Content-agnostic: every id comes from the
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
	for e in db.spawn_table(fac):
		table.append([str(e[0]), int(e[1])])
	assert_eq(s.packs, table, "against the first faction's spawn list")
	assert_eq(s.boss, str(db.factions[fac]["boss"]), "and its boss")
	assert_eq(s.lead_faction(), fac, "which leads")
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


func test_a_fight_chains_every_pack_and_the_boss() -> void:
	var db := _db()
	var s := HarnessSetup.defaults(db)
	var foes := s.pack_foes()
	s.packs = [[str(foes[0]), 3], [str(foes[foes.size() - 1]), 2]]
	s.boss = str(s.bosses()[0])
	var sk := s.make_skirmish()
	assert_eq(sk.mechs.size(), s.team.size(), "the team")
	assert_eq(sk.packs.size(), 3, "two packs and the boss")
	assert_eq(sk.reinforcements.size(), 6, "five foes and the boss in the pool")
	s.packs = []
	assert_eq(s.make_skirmish().reinforcements.size(), 1, "the boss alone")
	s.boss = ""
	assert_true(s.make_skirmish() == null, "nothing to fight")
	s.boss = str(s.bosses()[0])
	s.team = []
	assert_true(s.make_skirmish() == null, "nobody to fight it")


func test_a_battle_takes_the_packs_the_boss_and_the_guest() -> void:
	var db := _db()
	var facs: Array = db.factions.keys()
	var s := HarnessSetup.defaults(db)
	var a := str(db.spawn_foes(str(facs[0]))[0])
	s.packs = [[a, 2]]
	s.boss = str(db.factions[facs[1]]["boss"])
	s.guest = str(facs[2]) if facs.size() > 2 else ""
	s.map_kind = str(BattleMap.KINDS.keys()[1])
	s.seed_value = 11
	var b := s.make_battle()
	assert_eq(b.faction, str(facs[1]), "the boss's faction leads")
	assert_true(b.boss != null, "its boss takes the field")
	assert_eq(b.map.kind, s.map_kind, "on the chosen ground")
	assert_eq(b.seed_value, 11, "from the seed")
	assert_eq(b.guest, s.guest, "with the guest")
	var packs := 0
	for sq in b.field.packs():
		if not sq.elite:
			packs += 1
			assert_eq([sq.foe_id, sq.strength, sq.faction], [a, 2, str(facs[0])], "the composed pack, its own faction's")
	assert_eq(packs, 1, "and only it")
	s.boss = ""
	b = s.make_battle()
	assert_true(b.boss == null, "none: no boss")
	assert_eq(b.faction, str(facs[0]), "and the first pack's faction leads")
	s.packs = []
	assert_true(s.make_battle() == null, "a battle needs a pack for the rift to send")


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
	var checked := HarnessSetup.from_dict(d, db)
	assert_eq(checked.team, [id], "unknown and repeated machines drop out")
	var p := checked.picks(id)
	assert_eq(p.size(), int(db.chassis[id]["hardpoints"]), "a loadout is padded to its hardpoints")
	assert_eq([p[0], p[1]], [pair[1], ""], "an unknown component is an empty hardpoint")
	assert_eq(checked.packs, [[str(s.pack_foes()[0]), HarnessSetup.MAX_STRENGTH]], "unknown foes and bosses drop out of the packs, strength is clamped")
	assert_eq([checked.boss, checked.guest, checked.map_kind, checked.seed_value], ["", "", "mixed", 1], "and the rest falls back")
	assert_eq(HarnessSetup.load_or_default(db, TMP).to_dict(), HarnessSetup.defaults(db).to_dict(), "nothing kept: the defaults")


func test_the_harness_drives_the_setup() -> void:
	var db := _db()
	var pair := _refit_pair(db)
	var id: String = pair[0]
	var h: Control = HARNESS.new()
	var s := HarnessSetup.defaults(db)
	s.team = []
	h.build(s)
	assert_eq(h._pages.size(), 3, "three tabs")
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
	assert_true(h._pages[1].visible and not h._pages[0].visible, "the enemy's showing")
	var before := s.packs.size()
	h._on_add_pack()
	assert_eq(s.packs.size(), before + 1, "a pack added")
	assert_eq(h._packs_box.get_child_count(), before + 1, "with its row")
	s.packs.clear()
	h._fill_packs()
	h._refresh_summary()
	assert_true(h._battle_btn.disabled, "no packs: no battle")
	assert_false(h._fight_btn.disabled, "the boss alone is still a fight")
	h.free()


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
