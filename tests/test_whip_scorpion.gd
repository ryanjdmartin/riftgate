extends TestCase

## The Whip Scorpion's Thermal Ejection Manifold (Ryan, 23 November: "Deals -50% damage at zero heat
## to +100% damage at max heat, scaling linearly. When over 50% heat, damage recieved from hits is
## doubled"; "No longer gains heat on being hit"; "The death ray is not on the die normally. Reboot is
## replaced with "Death Ray" when holding its die. Selecting reboot equips the Heliographic Death Ray
## instead of rebooting. Holding the death ray changes reboot to "Cancel," and cancelling returns the
## die to what it was before"; "The death ray does it's thing when used, then the Scorpion reboots";
## of the scale past the maximum, "Hold"; 24 November, his option of the 23rd taken, "all damage
## received is doubled, so that overheat pays twice"), on synthetic passives and pieces: its damage by
## its heat, the die's number and the bot reading it; all damage it takes on a hot gauge doubled, a
## hit, the burn, a tick, a bite and a price in hull; the reboot piece off the die,
## brought up and stood down, fired and the reboot after, saved and undone; with nothing to fire at,
## the bot stands it down; the validator holds the keys to their shapes.

const L := Face.Reach.DIRECT

const SCALE := {"id": "scale", "name": "Scale", "description": "", "effects": [
	{"trigger": "static", "effect": "heat_scale", "cold": 50, "hot": 200}]}
const HOT := {"id": "hot", "name": "Hot", "description": "", "effects": [
	{"trigger": "static", "effect": "hot_damage", "value": 2}]}
const RAYED := {"id": "rayed", "name": "Rayed", "description": "", "effects": [
	{"trigger": "static", "effect": "reboot_piece", "piece": "test_ray", "label": "Death Ray"}]}


func _mech(name: String, d: Die, heat_max: int = 10, shield: int = 10, hull: int = 200) -> Unit:
	var u := Unit.mech(0, name, Vector2i.ZERO)
	u.shield = shield
	u.shield_max = shield
	u.hull = hull
	u.hull_max = hull
	u.heat_max = heat_max
	u.die = d
	return u


func _fight(units: Array, foes: Array) -> Skirmish:
	var sk := Skirmish.new(1)
	for u in units:
		sk.add_mech(u)
	sk.add_foes(foes)
	sk.begin()
	sk.start_round()
	return sk


## The ray: a low base and a point for every 2 heat it fires, the gauge emptied.
func _ray() -> Face:
	var f := Face.from_dict({"kind": "attack", "reach": "direct", "power": 2, "heat": 3, "vents_all": true, "power_per_heat": 1, "per_heat": 2})
	f.component = "test_ray"
	return f


func test_its_damage_runs_from_half_cold_to_double_at_its_maximum_and_holds_past_it() -> void:
	var gun := Face.attack(10, L)
	var u := _mech("W", Die.single(gun))
	u.grant_passive(SCALE)
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(Effects.heat_damage_multiple(u, 0, 10), 0.5, "half at no heat")
	assert_eq(Effects.heat_damage_multiple(u, 5, 10), 1.25, "a straight line between")
	assert_eq(Effects.heat_damage_multiple(u, 10, 10), 2.0, "double at its maximum")
	assert_eq(Effects.heat_damage_multiple(u, 15, 10), 2.0, "held at double past it")
	assert_eq(Effects.heat_damage_multiple(_mech("Q", Die.single(gun)), 0, 10), 1.0, "none on a machine without the scale")
	assert_eq(sk.shown_number(ms, gun, foe), 5, "the die shows half, cold")
	assert_eq(Policy.make(Policy.GREEDY, 1).expected_damage(ms, gun, foe), 5.0, "and the bot reads it")
	assert_true(sk.assign(0, foe), "a shot, cold")
	assert_eq(foe.hp, 895, "it lands half")
	sk.end_round()
	sk.start_round()
	ms.heat = 10
	assert_eq(sk.shown_number(ms, gun, foe), 20, "the die shows double, at its maximum")
	assert_true(sk.assign(0, foe), "a shot, hot")
	assert_eq(foe.hp, 875, "it lands double")
	assert_true(Effects.effect_text(SCALE["effects"][0]).contains("at no heat"), "reads as a sentence")


func test_a_hit_on_a_gauge_past_half_lands_double() -> void:
	var u := _mech("W", Die.single(Face.attack(1, L)), 10, 0, 200)
	u.grant_passive(HOT)
	var foe := Foe.make("revenant", 900, 3)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = 5
	assert_eq(Effects.hot_damage(u, 5, 10), 1, "at half, plain")
	assert_eq(Effects.hot_damage(u, 6, 10), 2, "past half, doubled")
	var fc := sk.forecast(ms)
	assert_eq(200 - int(fc["hull_after"]), 3 * foe.strikes(), "the forecast reads a plain blow at half")
	var hull := u.hull
	sk.end_round()
	assert_eq(hull - u.hull, 3 * foe.strikes(), "and it lands plain")
	sk.start_round()
	ms.heat = 6
	fc = sk.forecast(ms)
	assert_eq(u.hull - int(fc["hull_after"]), 6 * foe.strikes(), "past half the forecast reads it doubled")
	hull = u.hull
	sk.end_round()
	assert_eq(hull - u.hull, 6 * foe.strikes(), "and it lands doubled")
	assert_true(Policy.make(Policy.GREEDY, 1).hot_cost(sk, ms, 0, sk.forecast(ms)) == 0.0, "no heat added, no cost")
	assert_true(Effects.effect_text(HOT["effects"][0]).contains("all damage it takes"), "reads as a sentence")


## All the damage it takes past half its heat, not its hits alone (Ryan, 24 November: "I think we
## implement the double damage recieved penalty on the Whip as well"): its overheat's burn, its
## Ablating's tick, a Corrupted bite and a price in hull land double (his, the same day: "Volatile
## should double as well, all damage is all damage"), and the forecast, the die and the bot read
## them so; at half, all plain.
func test_its_burn_its_tick_a_bite_and_its_hull_price_land_double_past_half() -> void:
	var gun := Face.from_dict({"kind": "attack", "reach": "direct", "power": 1, "volatile": 2})
	var u := _mech("W", Die.single(gun), 10, 0, 200)
	u.grant_passive(HOT)
	var plain := _mech("P", Die.single(Face.attack(1, L)), 10, 0, 200)
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u, plain], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	# The burn: past its maximum it is past half, so every point burns two.
	assert_eq([Skirmish.burn_scale(ms), Skirmish.burn_scale(sk.mechs[1])], [2, 1], "two a point past the maximum, one on a plain machine")
	ms.heat = 13
	assert_eq(int(sk.forecast(ms)["burn"]), 6, "the forecast reads 3 past it burning 6")
	assert_eq(int(sk.preview_round()["mechs"][0]["burn"]), 6, "and so does the round preview the screen draws")
	var hull := u.hull
	sk._burn_stacks(ms, 3)
	assert_eq(hull - u.hull, 6, "and it burns 6: the overheat pays twice")
	# The tick: 2 Ablating, a point a stack.
	ms.heat = 6
	Effects.stack(u, Effects.STATUS["ablating_mech"], Effects.SKIRMISH, "test", 2, Effects.status_decay(Effects.STATUS["ablating_mech"]))
	assert_eq(int(sk.forecast(ms)["ablated"]), 4, "past half the forecast reads the tick doubled")
	hull = u.hull
	sk._ablate(ms, 2)
	assert_eq(hull - u.hull, 4, "and it ticks double")
	ms.heat = 5
	assert_eq(int(sk.forecast(ms)["ablated"]), 2, "at half, plain")
	assert_true(Policy.make(Policy.GREEDY, 1).hot_cost(sk, ms, 1, sk.forecast(ms)) > 0.0, "a heat that tips it past half costs the tick it doubles")
	# The bite: a Corrupted entry's 3 a stack, and Volatile's price beside it.
	ms.face_index = 0
	Effects.corrupt_entry(u, 0, "test", 1)
	assert_eq(sk.pending_bite(ms), Skirmish.corrupt_bite(), "at half, the bite plain")
	assert_eq([sk.pending_volatile(ms), sk.shown_face(ms, ms.face()).volatile], [2, 2], "and Volatile's price as printed, on the die too")
	var price := Policy.volatile_cost(sk, ms, ms.face())
	ms.heat = 6
	assert_eq(sk.pending_bite(ms), 2 * Skirmish.corrupt_bite(), "past half, doubled")
	assert_eq([sk.pending_volatile(ms), sk.shown_face(ms, ms.face()).volatile], [4, 4], "and Volatile's price, the die showing what it costs now")
	assert_eq(gun.volatile, 2, "the piece keeps its printed price")
	assert_true(Policy.volatile_cost(sk, ms, ms.face()) > price, "and the bot prices the doubled hull")
	hull = u.hull
	assert_true(sk.assign(0, foe), "it fires, corrupted and volatile")
	assert_eq(hull - u.hull, 2 * Skirmish.corrupt_bite() + 4, "the bite and the price both doubled")


func test_its_reboot_brings_the_piece_up_and_a_second_drop_stands_it_down() -> void:
	var gun := Face.attack(3, L, [], 2)
	var u := _mech("W", Die.of([gun, gun.duplicate_face(), _ray()]))
	u.grant_passive(RAYED)
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(Effects.live_entries(u, u.die), [0, 1], "the piece is off the die: it never rolls")
	assert_eq(Effects.reboot_label(u), "Death Ray", "the control's word")
	ms.face_index = 1
	ms.heat = 8
	assert_true(sk.reboot_mech(0), "its die on REBOOT")
	assert_eq([ms.face().component, ms.ray_from], ["test_ray", 1], "the piece is up, the entry it showed kept")
	assert_false(ms.rebooting, "nothing vents yet")
	assert_eq([ms.heat, u.shield], [8, 10], "heat and shield as they were")
	assert_false(sk.reroll([0]), "a die with the piece up rerolls nothing")
	assert_true(sk.reboot_mech(0), "dropped again: cancel")
	assert_eq([ms.face_index, ms.ray_from], [1, -1], "the die shows what it did")
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("W stands its test ray down")), "the log says so")
	assert_true(sk.assign(0, foe), "it spends as ever")
	assert_false(sk.can_reboot(0), "having spent, no reboot")
	assert_false(sk.reboot_mech(0), "and no piece")


func test_the_piece_fires_at_its_heat_scale_and_the_machine_reboots_after() -> void:
	var u := _mech("W", Die.of([Face.attack(3, L, [], 2), _ray()]))
	u.grant_passive(RAYED)
	u.grant_passive(SCALE)
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = 10
	assert_true(sk.reboot_mech(0), "the piece up")
	assert_eq(sk.shown_number(ms, ms.face(), foe), 14, "2 and a point for every 2 of its 10, doubled at its maximum")
	assert_true(sk.assign(0, foe), "it fires")
	assert_eq(foe.hp, 900 - 14, "as shown")
	assert_true(ms.rebooting, "and the machine reboots")
	assert_eq([ms.heat, u.shield, ms.ray_from], [0, 0, -1], "cold, bare, the piece gone")
	assert_true(sk.log.any(func(l: String) -> bool: return l.begins_with("W reboots as its test ray has fired")), "the log says why")
	sk.end_round()
	sk.start_round()
	assert_eq(u.shield, 10, "whole as the next round opens")
	assert_ne(ms.face().component, "test_ray", "its die rolled among its own entries")


func test_a_raised_piece_survives_a_save_and_the_undo_takes_its_shot_back() -> void:
	var u := _mech("W", Die.of([Face.attack(3, L, [], 2), _ray()]))
	u.grant_passive(RAYED)
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u], [foe])
	sk.keeps_undo = true
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.face_index = 0
	ms.heat = 6
	assert_true(sk.reboot_mech(0), "the piece up")
	var back: Skirmish = SaveGame.clone_skirmish(sk)
	assert_eq([back.mechs[0].face_index, back.mechs[0].ray_from], [1, 0], "saved with the piece up")
	assert_true(sk.assign(0, foe), "it fires")
	assert_true(ms.rebooting, "and reboots")
	assert_true(sk.undo(), "the undo")
	var again: Skirmish.MechState = sk.mechs[0]
	assert_false(again.rebooting, "the reboot taken back")
	assert_eq([again.face_index, again.ray_from, again.heat], [1, 0, 6], "the piece up again, its heat held")
	assert_true(sk.reboot_mech(0), "and it may be stood down")
	assert_eq(sk.mechs[0].face_index, 0, "the die as it was")


func test_the_bot_fires_the_piece_for_its_reboot_and_stands_it_down_with_nothing_to_fire_at() -> void:
	var u := _mech("W", Die.of([Face.attack(3, L, [], 2), _ray()]), 10, 10, 200)
	u.grant_passive(RAYED)
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	var bot := Policy.make(Policy.GREEDY, 1)
	ms.heat = 9
	var hot := bot.piece_worth(sk, 0)
	ms.heat = 1
	var cold := bot.piece_worth(sk, 0)
	assert_true(hot > cold, "the piece is worth more on a hot gauge (%s against %s)" % [hot, cold])
	assert_eq([ms.face_index != 1, ms.ray_from], [true, -1], "and the read leaves the die as it was")
	ms.heat = 9
	assert_true(bot._reboot(sk, 0), "the bot's reboot fires the piece")
	assert_true(ms.rebooting, "then reboots")
	assert_true(foe.hp < 900, "the shot landed")
	sk.end_round()
	sk.start_round()
	Effects.stack(foe, Effects.STATUS["phased"], Effects.SKIRMISH, "test", 1, Effects.DECAY_NONE)
	var shown := ms.face_index
	assert_false(bot._reboot(sk, 0), "nothing it may fire at: no reboot")
	assert_eq([ms.face_index, ms.ray_from, ms.rebooting], [shown, -1, false], "the piece stood down, the die as it was")


func test_the_validator_holds_the_scale_the_doubling_and_the_piece_to_their_shapes() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var cases := {
		"scale_flat": [{"trigger": "static", "effect": "heat_scale", "cold": 100, "hot": 100}, "apart"],
		"scale_ok": [{"trigger": "static", "effect": "heat_scale", "cold": 50, "hot": 200}, ""],
		"hot_one": [{"trigger": "static", "effect": "hot_damage", "value": 1}, "2 or more"],
		"hot_ok": [{"trigger": "static", "effect": "hot_damage", "value": 2}, ""],
		"piece_unnamed": [{"trigger": "static", "effect": "reboot_piece", "piece": "no_such_piece", "label": "Ray"}, "names its piece"],
		"piece_wordless": [{"trigger": "static", "effect": "reboot_piece", "piece": str(db.components.keys()[0])}, "label"],
	}
	for id in cases.keys():
		var errs: Array[String] = []
		db._validate_passive("probe " + id, {"id": "p", "name": "P", "description": "P.", "effects": [cases[id][0]]}, errs)
		var want := str(cases[id][1])
		if want.is_empty():
			assert_true(errs.is_empty(), "%s passes: %s" % [id, errs])
		else:
			assert_true(errs.any(func(e: String) -> bool: return e.contains(want)), "%s is refused: %s" % [id, errs])
