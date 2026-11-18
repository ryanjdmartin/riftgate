extends TestCase

## The Buzzard's engines (Ryan, 11 and 18 November: "Automatically paid"; "Do the carrion-style";
## "Put the bonus damage where Empowered goes in the damage calculation"), on synthetic passives and
## entries: the zap a weapon's spend pays in shield for a flat add on every blow, plain when the
## shield is short, breaking its own shield when it takes the last point; the shield every foe that
## falls in its fight gives it; a later grant in the same slot replacing the passive's (its Sustain);
## the gun that fires its whole shield; a branch's raise of a piece's own number (its Burst).

const L := Face.Reach.DIRECT
const K := Face.Keyword

## The Buzzard's passive's shape: every foe that falls gives 2 shield; every weapon pays 2 for +2.
const RECOUPLER := {"id": "recoupler", "name": "Recoupler", "description": "", "effects": [
	{"trigger": "on_foe_killed", "effect": "add_shield", "value": 2, "slot": "carrion"},
	{"trigger": "static", "effect": "shield_zap", "value": 2, "cost": 2, "slot": "zap"}]}
## Its Sustain branch's shape, granted after it: the zap adds 3, a fall lays Regenerating 2 instead.
const SUSTAIN := {"id": "sustain", "name": "Sustain", "description": "", "effects": [
	{"trigger": "static", "effect": "shield_zap", "value": 3, "cost": 2, "slot": "zap"},
	{"trigger": "on_foe_killed", "effect": "stack_status", "value": "regenerating", "stacks": 2, "slot": "carrion"}]}


func _mech(name: String, d: Die, shield: int = 10, hull: int = 100) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = 12
	u.hull = hull
	u.hull_max = hull
	u.die = d
	return u


func _fight(units: Array, foes: Array) -> Skirmish:
	var sk := Skirmish.new(1, 4)
	for u in units:
		sk.add_mech(u)
	sk.add_foes(foes)
	sk.begin()
	sk.start_round()
	return sk


## The cannon's shape: 2, and a point for every 2 shield it fires.
func _cannon() -> Face:
	var f := Face.attack(2, L)
	f.spends_shield = true
	f.power_per_shield = 1
	f.per_shield = 2
	return f


func test_a_weapon_pays_its_zap_for_a_flat_add_where_empowered_goes() -> void:
	var gun := Face.attack(3, L)
	var u := _mech("Buzzard", Die.single(gun), 10)
	u.grant_passive(RECOUPLER)
	var foe := Foe.make("revenant", 50, 0)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(Skirmish.zap_ready(ms, gun), 2, "its shield holds the cost: the zap is ready")
	assert_eq(sk.shown_number(ms, gun, foe), 5, "the die's number carries it: 3 and the zap's 2")
	Effects.stack(u, Effects.STATUS["overcharged"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_true(sk.assign(0, foe), "spent")
	assert_eq(u.shield, 8, "it paid 2 shield, unasked")
	assert_eq(foe.hp, 50 - (3 + 2 + 1), "3, the zap's 2 and Empowered's 1, one add beside the other")
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("pays 2 shield into the blow")), "the log says so")


func test_short_of_the_cost_it_fires_plain_and_the_last_point_breaks_it() -> void:
	var gun := Face.attack(3, L)
	var u := _mech("Buzzard", Die.single(gun), 1)
	u.grant_passive(RECOUPLER)
	var foe := Foe.make("revenant", 50, 0)
	var sk := _fight([u], [foe])
	assert_eq(Skirmish.zap_ready(sk.mechs[0], gun), 0, "a shield of 1 cannot pay 2")
	assert_true(sk.assign(0, foe), "spent")
	assert_eq([u.shield, foe.hp], [1, 47], "it fires plain and keeps its shield")
	var v := _mech("Buzzard", Die.single(gun.duplicate_face()), 2)
	v.grant_passive(RECOUPLER)
	var other := Foe.make("revenant", 50, 0)
	var s2 := _fight([v], [other])
	assert_true(s2.assign(0, other), "a shield of 2 pays its last point")
	assert_eq([v.shield, other.hp], [0, 45], "the zap lands")
	assert_true(s2.mechs[0].shield_broken, "and its own spend broke the shield (Ryan: \"being able to break its own shield is fine\")")


func test_the_zap_rides_every_strike_and_a_shock_doubles_it_and_equipment_pays_none() -> void:
	var burst := Face.attack(2, L)
	burst.strikes = 3
	var u := _mech("Buzzard", Die.single(burst), 10)
	u.grant_passive(RECOUPLER)
	var foe := Foe.make("revenant", 60, 0)
	var sk := _fight([u], [foe])
	Effects.stack(foe, Effects.STATUS["shocked"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	assert_true(sk.assign(0, foe), "three strikes")
	assert_eq(u.shield, 8, "the cost paid once a spend")
	assert_eq(foe.hp, 60 - ((2 + 2) * 2 + (2 + 2) * 2), "every strike takes the zap, as Empowered's add, and the first, aimed at a Shocked foe, is doubled whole: 8, then 4 and 4")
	var lure := Face.attack(0, L, [K.LURE])
	assert_true(Effects.zap_of(u, lure).is_empty(), "equipment pays no zap")


func test_every_foe_that_falls_in_its_fight_feeds_its_shield_and_a_broken_one_takes_none() -> void:
	var u := _mech("Buzzard", Die.single(Face.blank()), 4)
	u.grant_passive(RECOUPLER)
	var ally := _mech("Ally", Die.single(Face.attack(40, L)), 10)
	var a := Foe.make("revenant", 10, 0)
	var b := Foe.make("revenant", 10, 0)
	var sk := _fight([u, ally], [a, b])
	assert_true(sk.assign(1, a), "an ally's kill")
	assert_eq(u.shield, 6, "2 shield for a foe that fell, whoever felled it")
	sk.mechs[0].shield_broken = true
	u.shield = 0
	sk.end_round()
	sk.start_round()
	assert_true(sk.assign(1, b), "another kill")
	assert_eq(u.shield, 0, "a broken shield takes none")


func test_a_later_grant_in_a_slot_replaces_the_passives_its_sustain() -> void:
	var gun := Face.attack(3, L)
	var u := _mech("Buzzard", Die.single(gun), 4)
	u.grant_passive(RECOUPLER)
	u.grant_passive(SUSTAIN)
	assert_eq(Effects.zap_of(u, gun), {"cost": 2, "damage": 3}, "the zap adds 3 for the same 2")
	var ally := _mech("Ally", Die.single(Face.attack(40, L)), 10)
	var a := Foe.make("revenant", 10, 0)
	var sk := _fight([u, ally], [a, Foe.make("revenant", 300, 0)])
	assert_true(sk.assign(1, a), "a foe falls")
	assert_eq(u.shield, 4, "no flat 2 any more")
	assert_eq(Effects.stacks_of(u, "regenerating"), 2, "Regenerating 2 in its place")
	sk.end_round()
	assert_eq(u.shield, 6, "its first 2 as its turn ends")


func test_a_gun_that_fires_the_whole_shield_breaks_it_and_takes_no_zap() -> void:
	var cannon := _cannon()
	var u := _mech("Buzzard", Die.single(cannon), 12)
	u.grant_passive(RECOUPLER)
	var foe := Foe.make("revenant", 50, 0)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(Skirmish.shield_bonus(ms, cannon), 6, "a point for every 2 of its 12")
	assert_true(Effects.zap_of(u, cannon).is_empty(), "the zap cannot ride it: the shield will be empty")
	assert_eq(sk.shown_number(ms, cannon, foe), 8, "the die's number: 2 and 6")
	assert_true(sk.assign(0, foe), "fired")
	assert_eq(foe.hp, 42, "8 on the foe")
	assert_eq(u.shield, 0, "the whole field fired")
	assert_true(ms.shield_broken, "and broken")
	assert_true("\n".join(sk.log).contains("fires its whole shield: -12, +6"), "the log says so")
	assert_eq(Skirmish.shield_bonus(ms, cannon), 0, "a broken shield adds nothing")
	assert_true(Face.from_dict(cannon.to_dict()).spends_shield and Face.from_dict(cannon.to_dict()).per_shield == 2, "a save keeps its form")


func test_a_branch_raises_a_pieces_own_number_and_its_area_keeps_its_printed_one() -> void:
	var cannon := Face.attack(4, L, [K.CLEAVE])
	cannon.cleave = 2
	cannon.component = "test_cannon"
	var u := _mech("Buzzard", Die.single(cannon), 0)
	u.grant_passive({"id": "burst", "name": "Burst", "description": "", "effects": [
		{"trigger": "static", "effect": "add_power", "value": 2, "entry": "test_cannon"}]})
	var e := Effects.effective_face(u, cannon)
	assert_eq(e.power, 6, "its own number 2 higher")
	assert_eq(Effects.effective_face(u, Face.attack(4, L)).power, 4, "another piece's untouched")
	var a := Foe.make("revenant", 50, 0)
	var b := Foe.make("revenant", 50, 0)
	var sk := _fight([u], [a, b])
	assert_true(sk.assign(0, sk.foe_at(0, 0)), "fired")
	assert_eq([sk.foe_at(0, 0).hp, sk.foe_at(0, 1).hp], [44, 48], "6 on its target, Spread's printed 2 beside it")


func test_the_bot_weighs_the_shield_a_spend_pays() -> void:
	var gun := Face.attack(3, L)
	var u := _mech("Buzzard", Die.single(gun), 6)
	u.grant_passive(RECOUPLER)
	var sk := _fight([u], [Foe.make("revenant", 50, 8), Foe.make("revenant", 50, 8)])
	var ms: Skirmish.MechState = sk.mechs[0]
	var bot := Policy.make(Policy.GREEDY, 1)
	assert_true(bot.shield_spend_cost(sk, ms, gun) > 0.0, "a zap's 2 shield is a cost before this round's blows")
	assert_true(bot.shield_spend_cost(sk, ms, _cannon()) > bot.shield_spend_cost(sk, ms, gun), "the whole field more")
	u.shield = 1
	assert_eq(bot.shield_spend_cost(sk, ms, gun), 0.0, "short of the cost it fires plain: nothing paid")


## The die shows the zap: its cost in the passive box while the shield holds it, the add in the
## number, nothing once it would fire plain; the tap's readout says it on that box's line.
func test_the_die_shows_the_zaps_cost_in_its_passive_box_while_the_shield_holds_it() -> void:
	var db := ContentDB.load_default()
	var sk := Skirmish.new(1, 2)
	var m := db.make_mech("badger")
	m.die = Die.single(Face.attack(3, L))
	m.grant_passive(RECOUPLER)
	sk.add_mech(m)
	var foe := Foe.make("revenant", 30, 0)
	sk.add_foes([foe])
	var s := SkirmishScreen.new()
	s.setup(sk)
	s._refresh()
	assert_eq(s._dice[0].zap_cost, 2, "the die carries the cost")
	assert_true(s._dice[0].passive_marks().any(func(x: Array) -> bool: return str(x[0]) == "shield" and str(x[1]) == "-2"), "in its passive box: %s" % str(s._dice[0].passive_marks()))
	m.shield = 1
	s._refresh()
	assert_eq(s._dice[0].zap_cost, 0, "short of it, none")
	var said := str(EntryReadout.zap_line(2, 3))
	assert_true(said.contains("pays 2 shield") and said.contains("+3"), "the readout's line: %s" % said)
	s.free()
