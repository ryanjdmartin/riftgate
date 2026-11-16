extends TestCase

## The rift's shell (Ryan, 16 November: "The shell only needs to cover the 7 hexes in front of the
## rift ... The result should be that the 7 hexes next to the rift are inaccessible to player
## units"): the seven hexes beside the rift's five are closed to every machine while the seal
## stands, the packs passing and landing there as ever, and open at the Rupture.


func _battle(seed_value: int = 3) -> Battle:
	var db := ContentDB.load_default()
	var team: Array = []
	for id in ["badger", "kite", "stingray"]:
		team.append(db.make_mech(id))
	var b := Battle.new(seed_value)
	b.setup(team, "meadow", Battle.DEFAULT_WIDTH, Battle.DEFAULT_HEIGHT)
	quiet_start(b)
	return b


func test_the_shell_is_the_seven_beside_the_rift() -> void:
	for wh in [[20, 12], [24, 14], [16, 12]]:
		var m := BattleMap.generate(wh[0], wh[1], 5, "")
		var shell := m.shell_hexes()
		assert_eq(shell.size(), 7, "seven at %d by %d" % wh)
		for h in shell:
			assert_false(m.rift_hexes.has(h), "none of the rift's own")
			var beside := false
			for r in m.rift_hexes:
				beside = beside or Hex.distance(h, r) == 1
			assert_true(beside, "each beside the rift")
		assert_true(shell.has(Battle.boss_home(m)), "the boss's hex among them")
		assert_eq(shell[3], Battle.boss_home(m), "its plate the middle one, round the rift")
		assert_eq(Hex.axial_to_offset(shell[0]).y, 0, "the ring opening on the rift's row")
		assert_eq(Hex.axial_to_offset(shell[6]).y, 0, "and closing on it")


func test_no_machine_enters_the_shell_while_the_seal_stands() -> void:
	var b := _battle()
	assert_true(b.is_sealed(), "the seal stands")
	assert_eq(b.field.shell.size(), 7, "and the shell with it")
	for m in b.mechs():
		for h in b.field.shell.keys():
			assert_false(b.field.can_stand(m, h), "%s stands on none of the seven" % m.display_name)
			assert_false(b.field.can_pass(m, h), "%s passes none of them, a flyer and a hover as any" % m.display_name)
	var flyer: Unit = b.mechs()[1]
	var near := Battlefield.NO_HEX
	for h in b.field.map.all_hexes():
		if not b.field.shell.has(h) and b.field.can_stand(flyer, h) and Hex.distance(h, Battle.boss_home(b.map)) == 2:
			near = h
			break
	flyer.pos = near
	for h in b.destinations_for(flyer).keys():
		assert_false(b.field.shell.has(h), "no move ends inside it")


func test_the_packs_pass_and_land_inside_the_shell() -> void:
	var b := _battle()
	var sq: Unit = b.field.packs()[0]
	for h in b.field.shell.keys():
		if b.field.unit_at(h) == null:
			assert_true(b.field._landable(sq, h, {}), "a pack may stop on one of the seven")
			assert_true(b.field._walkable(sq, h, {}), "and walk through it")
			break


func test_the_rupture_opens_the_shell() -> void:
	var b := _battle()
	var m: Unit = b.mechs()[0]
	var h := Battlefield.NO_HEX
	for x in b.field.shell.keys():
		if b.field.unit_at(x) == null:
			h = x
			break
	assert_false(b.field.can_stand(m, h), "closed while the seal stands")
	b.fractures = b.thresholds.size()
	b.rupture()
	assert_true(b.field.shell.is_empty(), "the Rupture bursts it")
	assert_true(b.field.can_stand(m, h), "and the machines may go there")


func test_a_saved_battle_keeps_its_shell_by_its_seal() -> void:
	var b := _battle()
	var back := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_eq(back.field.shell.size(), 7, "sealed, the shell read back")
	b.rupture()
	var after := SaveGame.from_dict(JSON.parse_string(JSON.stringify(SaveGame.to_dict(b))))
	assert_true(after.field.shell.is_empty(), "broken, none")


func test_no_cache_lies_inside_the_shell() -> void:
	for sd in range(1, 13):
		var db := ContentDB.load_default()
		var b := Battle.new(sd)
		b.setup([db.make_mech("badger")], "waste")
		for c in b.field.caches:
			assert_false(b.map.shell_hexes().has(c["pos"]), "seed %d: no cache behind the shell until its loot is decided" % sd)
