extends TestCase

## The block, a what-if behind two switches (Skirmish.shield_break, shield_break_min; Ryan, 13
## November: "What if we bring back that when a shield breaks, it absorbs the whole blow? It does
## not bleed into the hull"; docs/briefs/refit_pass.md, sections 15 to 22). Off, the honest
## shield of 14 October runs, and tests/test_skirmish.gd holds that. Its other half that day, a
## broken shield resting before its regen started again, left with the reboot
## (tests/test_reboot.gd), where nothing comes back by itself. The runner turns every switch off
## before each test. Numbers are in tens; every piece here is synthetic.

const L := Face.Reach.DIRECT


func _mech(name: String, shield: int, hull: int) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.die = Die.single(Face.attack(1, L))
	return u


func _fight(m: Unit, foes: Array) -> Skirmish:
	var sk := Skirmish.new(1)
	sk.add_mech(m)
	sk.add_foes(foes)
	sk.begin()
	return sk


func _round(sk: Skirmish) -> void:
	sk.start_round()
	sk.end_round()


## The grid cleared and the foes stood where a test says: [foe, rank, column] each.
func _regrid(sk: Skirmish, cells: Array) -> void:
	for col in range(sk.columns):
		sk.front[col] = null
		sk.back[col] = null
	for cell in cells:
		sk._place(cell[0], cell[1], cell[2])


func test_off_a_blow_past_the_shield_reaches_the_hull() -> void:
	var r := Skirmish._blow(10, 0, 50, Skirmish.breaks_whole(10, 10))
	assert_false(Skirmish.breaks_whole(10, 10), "off, no break stops a blow")
	assert_eq(int(r["through"]), 40, "the forty past a ten-point shield reach the hull")
	assert_true(bool(r["broke"]) and int(r["stopped"]) == 0, "the shield broke and stopped nothing more than its number")
	var m := _mech("A", 10, 100)
	var sk := _fight(m, [Foe.make("brute", 900, 50)])
	_round(sk)
	assert_eq(m.hull, 60, "and so in a fight")
	sk.start_round()
	assert_eq(m.shield, 0, "and nothing mends it the round after: a shield at nothing is broken until its machine reboots")


func test_the_blow_that_breaks_a_shield_is_stopped_whole() -> void:
	Skirmish.shield_break = true
	var m := _mech("A", 10, 100)
	var sk := _fight(m, [Foe.make("brute", 900, 50)])
	sk.start_round()
	var fc := sk.forecast(sk.mechs[0])
	assert_eq(int(fc["hull_after"]), 100, "the forecast knows the break stops it")
	sk.end_round()
	assert_eq(m.shield, 0, "the shield is spent")
	assert_eq(m.hull, 100, "and none of the fifty reached the hull")
	var ev: Dictionary = sk.turn_events[0]
	assert_true(bool(ev["blocked"]) and bool(ev["broke_shield"]), "the blow broke the shield and was blocked")
	assert_eq(int(ev["stopped"]), 40, "the event says what the break kept from the hull")
	assert_true("\n".join(sk.log).contains("brute hits A: shield -10, it breaks and stops the other 40"), "and the log")
	_round(sk)
	assert_eq(m.hull, 50, "the next blow finds no shield and lands whole")


func test_a_blow_under_the_shield_leaves_it_standing_at_its_number() -> void:
	Skirmish.shield_break = true
	var m := _mech("A", 10, 100)
	var sk := _fight(m, [Foe.make("jab", 900, 4)])
	_round(sk)
	assert_eq(m.shield, 6, "a shield is still its number against a blow it outlasts")
	assert_eq(m.hull, 100, "nothing passed")
	assert_eq(int(sk.turn_events[0]["stopped"]), 0, "and nothing was stopped past it")


## The order the foes stand in decides which blow the break stops: they act front rank left to
## right, then the back rank, so the first blow to meet a standing shield at or over its number
## is the one stopped, and a small one that spends the shield bares the hull to the big one.
func test_the_first_blow_to_break_it_is_the_one_stopped() -> void:
	Skirmish.shield_break = true
	var m := _mech("A", 10, 100)
	var jab := Foe.make("jab", 900, 10)
	var brute := Foe.make("brute", 900, 50)
	var sk := _fight(m, [jab, brute])
	_regrid(sk, [[jab, 0, 0], [brute, 0, 1]])
	_round(sk)
	assert_eq(m.hull, 50, "the jab's ten spent the shield exactly, and the fifty landed whole on the hull")
	var m2 := _mech("B", 10, 100)
	var jab2 := Foe.make("jab", 900, 10)
	var brute2 := Foe.make("brute", 900, 50)
	var s2 := _fight(m2, [jab2, brute2])
	_regrid(s2, [[brute2, 0, 0], [jab2, 0, 1]])
	_round(s2)
	assert_eq(m2.hull, 90, "the brute first: its fifty is stopped whole, and only the jab reaches the hull")
	var m3 := _mech("C", 10, 100)
	var jab3 := Foe.make("jab", 900, 10)
	var brute3 := Foe.make("brute", 900, 50)
	var s3 := _fight(m3, [jab3, brute3])
	_regrid(s3, [[jab3, 0, 0], [brute3, 1, 0]])
	_round(s3)
	assert_eq(m3.hull, 50, "the back rank strikes after the front: the brute behind lands whole")


func test_a_second_strike_lands_on_the_hull_the_first_bared() -> void:
	Skirmish.shield_break = true
	var m := _mech("A", 10, 100)
	var brute := Foe.make("brute", 900, 30)
	brute.actions[0]["strikes"] = 2
	var sk := _fight(m, [brute])
	sk.start_round()
	assert_eq(int(sk.forecast(sk.mechs[0])["hull_after"]), 70, "the forecast walks both strikes")
	sk.end_round()
	assert_eq(m.hull, 70, "the first is stopped whole and the second lands whole")


func test_a_barrier_takes_the_blow_and_the_shield_behind_it_never_breaks() -> void:
	Skirmish.shield_break = true
	var m := _mech("A", 10, 100)
	var sk := _fight(m, [Foe.make("brute", 900, 50)])
	sk.start_round()
	Effects.grant_buff(m, "barrier", 1, "test", sk.round)
	sk.end_round()
	assert_eq(m.shield, 10, "the Barrier took it, the shield untouched")
	assert_eq(m.hull, 100, "and the hull")


## The bench's guard against a sliver: a shield under the share of its maximum breaks honestly,
## and one at the share or over stops the blow whole.
func test_a_shield_under_the_share_breaks_honestly() -> void:
	Skirmish.shield_break = true
	Skirmish.shield_break_min = 50
	assert_false(Skirmish.breaks_whole(4, 10), "four of ten is under half")
	assert_true(Skirmish.breaks_whole(5, 10), "five of ten is half")
	assert_false(Skirmish.breaks_whole(0, 10), "no shield, no break")
	var m := _mech("A", 10, 100)
	m.shield = 4
	var sk := _fight(m, [Foe.make("brute", 900, 20)])
	_round(sk)
	assert_eq(m.hull, 84, "a sliver takes its four and the sixteen pass")
	var m2 := _mech("B", 10, 100)
	m2.shield = 5
	var s2 := _fight(m2, [Foe.make("brute", 900, 20)])
	_round(s2)
	assert_eq(m2.hull, 100, "half a gauge breaks and stops it whole")
