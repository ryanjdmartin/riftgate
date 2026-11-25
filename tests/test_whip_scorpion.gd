extends TestCase

## The Whip Scorpion's Thermal Ejection Manifold (Ryan, 23 November: "Deals -50% damage at zero heat
## to +100% damage at max heat, scaling linearly. When over 50% heat, damage recieved from hits is
## doubled"; "No longer gains heat on being hit"; "The death ray is not on the die normally. Reboot is
## replaced with "Death Ray" when holding its die. Selecting reboot equips the Heliographic Death Ray
## instead of rebooting. Holding the death ray changes reboot to "Cancel," and cancelling returns the
## die to what it was before"; "The death ray does it's thing when used, then the Scorpion reboots";
## of the scale past the maximum, "Hold"; 24 November, the hits alone again on his option 1, "Go
## with option 1 and max heat 12"), on synthetic passives and pieces: its damage by
## its heat, the die's number and the bot reading it; a hit on a hot gauge doubled, its burn, a
## tick, a bite and a price in hull as printed; the reboot piece off the die,
## brought up and stood down, fired and the reboot after, saved and undone; with nothing to fire at,
## the bot stands it down; the validator holds the keys to their shapes.

const L := Face.Reach.DIRECT

const SCALE := {"id": "scale", "name": "Scale", "description": "", "effects": [
	{"trigger": "static", "effect": "heat_scale", "cold": 50, "hot": 200}]}
const HOT := {"id": "hot", "name": "Hot", "description": "", "effects": [
	{"trigger": "static", "effect": "hot_hits", "value": 2}]}
## The Incinerator's shape (Ryan, 24 November: "Resolve: For each hit, gain 1 heat and apply 1
## Ablate. If Overheated, apply 2 Ablate Instead").
const STOKE := {"id": "stoke", "name": "Stoke", "description": "", "effects": [
	{"trigger": "on_attack", "effect": "hit_heat", "value": 1},
	{"trigger": "on_attack", "effect": "lay_status", "value": "ablating", "stacks": 1, "overheated": 2}]}
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
	assert_eq(Effects.hot_hits(u, 5, 10), 1, "at half, plain")
	assert_eq(Effects.hot_hits(u, 6, 10), 2, "past half, doubled")
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
	assert_true(Effects.effect_text(HOT["effects"][0]).contains("a hit on it"), "reads as a sentence")


## Its hits alone, past half its heat (Ryan, 24 November, his option 1: "Go with option 1 and max
## heat 12", so a branch that rides Overheated pays the plain burn): its overheat's burn, its
## Ablating's tick, a Corrupted bite and a price in hull land as printed, hot or cold, and the
## forecast, the die and the bot read them so.
func test_past_half_its_burn_its_tick_a_bite_and_its_hull_price_land_as_printed() -> void:
	var gun := Face.from_dict({"kind": "attack", "reach": "direct", "power": 1, "volatile": 2})
	var u := _mech("W", Die.single(gun), 10, 0, 200)
	u.grant_passive(HOT)
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = 13
	assert_eq(int(sk.forecast(ms)["burn"]), 3, "the forecast reads 3 past its maximum burning 3")
	assert_eq(int(sk.preview_round()["mechs"][0]["burn"]), 3, "and so does the round preview the screen draws")
	var hull := u.hull
	sk._burn_stacks(ms, 3)
	assert_eq(hull - u.hull, 3, "and it burns 3: the burn is no hit")
	ms.heat = 6
	Effects.stack(u, Effects.STATUS["ablating_mech"], Effects.SKIRMISH, "test", 2, Effects.status_decay(Effects.STATUS["ablating_mech"]))
	assert_eq(int(sk.forecast(ms)["ablated"]), 2, "past half the tick reads plain")
	hull = u.hull
	sk._ablate(ms, 2)
	assert_eq(hull - u.hull, 2, "and ticks plain")
	ms.face_index = 0
	Effects.corrupt_entry(u, 0, "test", 1)
	assert_eq([sk.pending_bite(ms), sk.pending_volatile(ms), sk.shown_face(ms, ms.face()).volatile], [Skirmish.corrupt_bite(), 2, 2], "the bite and Volatile's price as printed, on the die too")
	hull = u.hull
	assert_true(sk.assign(0, foe), "it fires, corrupted and volatile")
	assert_eq(hull - u.hull, Skirmish.corrupt_bite() + 2, "the bite and the price plain")


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


## The Obliterator's shape (Ryan, 24 November: "Turn Start: Gain 1 heat. Heliographic Death Ray ->
## Heliographic Doom Ray. Hull Cost: 1. Direct, 2 damage plus 1 per 2 heat. Spread. Penetrate.
## Ignores Armour"), on synthetic passives and pieces: a heat as its turn starts; a step's form of the
## reboot piece comes up in its place, REBOOT wearing the word its slot's later grant gives; its
## hull cost as printed; the heat it fires on every hit of the shot (the blow's order:
## what the entry prints from its firer lands on every blow), so the whole shot lands on each
## Sprite it reaches, past armour; then the reboot.
func test_a_step_s_form_of_the_reboot_piece_comes_up_with_its_word_and_fires_wide() -> void:
	var u := _mech("W", Die.of([Face.attack(3, L, [], 2), _ray()]), 10, 10, 200)
	u.grant_passive({"id": "rayed", "name": "Rayed", "description": "", "effects": [
		{"trigger": "static", "effect": "reboot_piece", "piece": "test_ray", "label": "Death Ray", "slot": "ray"}]})
	u.grant_passive(SCALE)
	u.grant_passive(HOT)
	u.grant_passive({"id": "doom", "name": "Doom", "description": "", "effects": [
		{"trigger": "on_turn_start", "effect": "gain_heat", "value": 1},
		{"trigger": "static", "effect": "piece_form", "entry": "test_ray", "name": "Test Doom Ray", "face": {"kind": "attack", "reach": "direct", "power": 2,
			"keywords": ["cleave", "penetrate"], "cleave": 2, "penetrate": 2, "heat": 3, "vents_all": true, "power_per_heat": 1, "per_heat": 2, "volatile": 1, "ignores_armour": true}},
		{"trigger": "static", "effect": "reboot_piece", "piece": "test_ray", "label": "Doom Ray", "slot": "ray"}]}, "branch")
	var left := Foe.make("dummy", 900, 0)
	var mid := Foe.make("dummy", 900, 0)
	var right := Foe.make("dummy", 900, 0)
	var behind := Foe.make("dummy", 900, 0, true)
	left.armour = 5
	var sk := Skirmish.new(1, 3)
	sk.add_mech(u)
	sk.add_foes([left, mid, right, behind])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	assert_eq(ms.heat, 1, "a heat as its turn starts")
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("+1 heat as its turn starts")), "the log says so")
	sk.end_round()
	ms.heat = 9
	sk.start_round()
	assert_eq(ms.heat, 10, "its turn opens a heat higher")
	assert_eq(Effects.reboot_label(u), "Doom Ray", "REBOOT wears the later grant's word")
	assert_true(sk.reboot_mech(0), "its die on REBOOT")
	assert_true(sk.log.any(func(l: String) -> bool: return l == "W brings its Test Doom Ray up"), "the log names the piece as its step calls it")
	var shown := sk.shown_face(ms, ms.face())
	assert_eq([ms.face().component, shown.volatile], ["test_ray", 1], "the form comes up, its hull cost as printed")
	assert_true(shown.has(Face.Keyword.CLEAVE) and shown.has(Face.Keyword.PENETRATE) and shown.ignores_armour, "Spread, Penetrate, Ignores Armour")
	assert_eq([left.column, behind.column, behind.rank], [0, 0, 1], "the armoured one in front of the one behind")
	var hull := u.hull
	assert_true(sk.assign(0, left), "it fires")
	var shot := (2 + 10 / 2) * 2   # 2 and a point for every 2 of its 10, doubled at its maximum
	assert_eq([900 - left.hp, 900 - mid.hp, 900 - behind.hp, 900 - right.hp], [shot, shot, shot, 0], "the whole shot on the target, the one beside and the one behind, past the armour; none past them")
	assert_eq(hull - u.hull, 1, "its hull cost")
	assert_true(ms.rebooting, "and it reboots")


## The Incinerator's rule on synthetic pieces: each hit gives its machine a heat as its riders land,
## ahead of its lay, so the hit that takes the gauge past its maximum lays 2 and the ones before it
## 1; every Sprite hit counts, an area's and equipment's too; the Death Ray vents before it hits, so
## its hit lays 1 and its heat goes with the reboot; the bot counts a heat a hit.
func test_each_hit_heats_its_machine_and_lays_ablate_two_once_past_its_maximum() -> void:
	var triple := Face.from_dict({"kind": "attack", "reach": "direct", "power": 1, "strikes": 3, "heat": 0})
	var u := _mech("W", Die.single(triple), 10, 10, 200)
	u.grant_passive(STOKE)
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = 8
	assert_eq(Policy.heat_of(ms, triple), 3, "the bot counts a heat a hit")
	assert_true(sk.assign(0, foe), "three hits")
	assert_eq(ms.heat, 11, "a heat a hit")
	assert_eq(Effects.stacks_of(foe, "ablating"), 4, "1 at 9, 1 at its maximum, 2 past it")
	assert_true(sk.log.any(func(l: String) -> bool: return l.contains("+3 heat from its hits")), "the log says so")


func test_every_sprite_hit_counts_an_area_s_and_equipment_s_and_the_ray_lays_one() -> void:
	var spread := Face.from_dict({"kind": "attack", "reach": "direct", "power": 1, "keywords": ["cleave"], "cleave": 1, "heat": 0})
	var probe := Face.from_dict({"kind": "attack", "reach": "direct", "power": 0, "keywords": ["brittle"], "brittle": 1, "heat": 0})
	var u := _mech("W", Die.of([spread, probe, _ray()]), 10, 10, 200)
	u.grant_passive(STOKE)
	u.grant_passive(RAYED)
	var left := Foe.make("dummy", 900, 0)
	var mid := Foe.make("dummy", 900, 0)
	var right := Foe.make("dummy", 900, 0)
	var sk := Skirmish.new(1, 3)
	sk.add_mech(u)
	sk.add_foes([left, mid, right])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = 0
	ms.face_index = 0
	assert_true(sk.assign(0, mid), "a spread on the middle")
	assert_eq(ms.heat, 3, "a heat for each Sprite it hit")
	assert_eq([Effects.stacks_of(left, "ablating"), Effects.stacks_of(mid, "ablating"), Effects.stacks_of(right, "ablating")], [1, 1, 1], "and an Ablate on each")
	sk.end_round()
	sk.start_round()
	ms.face_index = 1
	var had := Effects.stacks_of(left, "ablating")   # its first stack ticked away in its own turn
	assert_true(sk.assign(0, left), "a debuff")
	assert_eq([ms.heat, Effects.stacks_of(left, "ablating") - had], [4, 1], "equipment's hit counts too")
	sk.end_round()
	sk.start_round()
	ms.heat = 14
	assert_true(sk.reboot_mech(0), "the Ray up, past its maximum")
	var before := Effects.stacks_of(mid, "ablating")
	assert_true(sk.assign(0, mid), "it fires")
	assert_eq(Effects.stacks_of(mid, "ablating") - before, 1, "it vents before it hits: 1, not 2")
	assert_true(ms.rebooting and ms.heat == 0, "and the reboot takes its heat")


## The Incinerator as it stands (Ryan, 24 November: "Resolve: Gain 1 heat and apply 1 Ablate. If
## Overheated, apply 3 Ablate instead"; "It should apply to everything hit, not just the target"):
## once a spend, its heat with the spend's first hit and its Ablate on each Sprite hit once, however
## many strikes; the heat lands first, so the spend that takes it past its maximum lays 3 on each.
func test_once_a_spend_its_heat_and_an_ablate_on_each_sprite_hit_three_past_its_maximum() -> void:
	var triple := Face.from_dict({"kind": "attack", "reach": "direct", "power": 1, "strikes": 3, "keywords": ["cleave"], "cleave": 1, "heat": 0})
	var u := _mech("W", Die.single(triple), 10, 10, 200)
	u.grant_passive({"id": "stoke_once", "name": "Stoke Once", "description": "", "effects": [
		{"trigger": "on_attack", "effect": "hit_heat", "value": 1, "once": "spend"},
		{"trigger": "on_attack", "effect": "lay_status", "value": "ablating", "stacks": 1, "overheated": 3, "once": "spend"}]})
	var left := Foe.make("dummy", 900, 0)
	var mid := Foe.make("dummy", 900, 0)
	var sk := Skirmish.new(1, 2)
	sk.add_mech(u)
	sk.add_foes([left, mid])
	sk.begin()
	sk.start_round()
	var ms: Skirmish.MechState = sk.mechs[0]
	ms.heat = 0
	assert_eq(Policy.heat_of(ms, triple), 1, "the bot counts a heat a spend")
	assert_true(sk.assign(0, left), "three strikes, a spread on each")
	assert_eq(ms.heat, 1, "a heat a spend")
	assert_eq([Effects.stacks_of(left, "ablating"), Effects.stacks_of(mid, "ablating")], [1, 1], "an Ablate on each Sprite hit, once")
	sk.end_round()
	sk.start_round()
	ms.heat = 10
	var had := [Effects.stacks_of(left, "ablating"), Effects.stacks_of(mid, "ablating")]
	assert_true(sk.assign(0, left), "from its maximum")
	assert_eq(ms.heat, 11, "its heat first, past the maximum")
	assert_eq([Effects.stacks_of(left, "ablating") - int(had[0]), Effects.stacks_of(mid, "ablating") - int(had[1])], [3, 3], "so 3 on each")


## The log names a piece as content does (the Heliographic Death Ray, not its id).
func test_the_log_names_the_reboot_piece_as_content_does() -> void:
	var db := ContentDB.load_default()
	var u := db.make_mech("whip_scorpion")
	var sk := Skirmish.new(1)
	sk.add_mech(u)
	sk.add_foes([Foe.make("dummy", 900, 0)])
	sk.begin()
	sk.start_round()
	assert_true(sk.reboot_mech(0), "the Ray up")
	var name := str(db.components[Effects.reboot_piece(u)]["name"])
	assert_true(sk.log.any(func(l: String) -> bool: return l.ends_with("brings its %s up" % name)), "by its name in content")


## The bot banks the heat that is its shot (24 November, so it holds its heat past half as the
## stock is built to): a heat-scale machine whose reboot fires its heat reads held heat as a share of
## its next shot (shot_worth), so mid-gauge it spends a builder over the Ray, and with the builder
## that would burn it, it fires the Ray; heat on it costs less than on a plain machine.
func test_the_bot_banks_its_heat_for_the_shot_and_fires_it_near_the_top() -> void:
	var gun := Face.attack(3, L, [], 4)
	var u := _mech("W", Die.of([gun, _ray()]), 12, 10, 200)
	u.grant_passive(SCALE)
	u.grant_passive(RAYED)
	var plain := _mech("P", Die.single(gun.duplicate_face()), 12, 10, 200)
	var foe := Foe.make("dummy", 900, 0)
	var sk := _fight([u, plain], [foe])
	var ms: Skirmish.MechState = sk.mechs[0]
	var bot := Policy.make(Policy.GREEDY, 1)
	assert_true(Policy.shot_worth(ms, 7) > Policy.shot_worth(ms, 0) and Policy.shot_worth(ms, 0) > 0.0, "its held heat banks a bigger shot")
	assert_eq(Policy.shot_worth(sk.mechs[1], 7), 0.0, "a plain machine banks none")
	ms.heat = 3
	sk.mechs[1].heat = 3
	assert_true(bot.heat_cost_of(sk, ms, 4) < bot.heat_cost_of(sk, sk.mechs[1], 4), "heat on it costs less: it is fuel")
	ms.face_index = 0
	ms.heat = 7
	var spend := -INF
	for o in bot.options_for(sk, 0):
		spend = maxf(spend, float(o["score"]))
	assert_true(bot.piece_worth(sk, 0) < spend, "past half, it builds on rather than fire the Ray (%s against %s)" % [bot.piece_worth(sk, 0), spend])
	ms.heat = 11
	spend = -INF
	for o in bot.options_for(sk, 0):
		spend = maxf(spend, float(o["score"]))
	assert_true(bot.piece_worth(sk, 0) > spend, "near the top, the builder would burn it: it fires (%s against %s)" % [bot.piece_worth(sk, 0), spend])


## The bot reads the Incinerator's lay past the maximum: a spend that takes it there lays 3 a Sprite
## where it would lay 1, so it weighs more than the same spend on a lay with no such stacks; one that
## stays under lays 1 either way.
func test_the_bot_reads_the_lay_a_spend_past_its_maximum_lays() -> void:
	var gun := Face.attack(3, L, [], 4)
	var scores := []
	for hot_n in [3, 0]:
		var u := _mech("W", Die.single(gun), 12, 10, 200)
		var lay := {"trigger": "on_attack", "effect": "lay_status", "value": "ablating", "stacks": 1, "once": "spend"}
		if hot_n > 0:
			lay["overheated"] = hot_n
		u.grant_passive({"id": "stoke_once", "name": "Stoke Once", "description": "", "effects": [
			{"trigger": "on_attack", "effect": "hit_heat", "value": 1, "once": "spend"}, lay]})
		var foe := Foe.make("dummy", 900, 0)
		var sk := _fight([u], [foe])
		var ms: Skirmish.MechState = sk.mechs[0]
		var bot := Policy.make(Policy.GREEDY, 1)
		ms.heat = 8
		var past := bot.attack_score(sk, ms, gun, foe)
		ms.heat = 2
		var under := bot.attack_score(sk, ms, gun, foe)
		scores.append([past, under])
	assert_true(float(scores[0][0]) > float(scores[1][0]), "taking it past its maximum, its 3 Ablate weigh more than 1 (%s against %s)" % [scores[0][0], scores[1][0]])
	assert_eq(float(scores[0][1]), float(scores[1][1]), "under it, the same 1")


func test_the_validator_holds_the_scale_the_doubling_and_the_piece_to_their_shapes() -> void:
	var db := ContentDB.new()
	db.load_dir(ContentDB.DIR)
	var cases := {
		"scale_flat": [{"trigger": "static", "effect": "heat_scale", "cold": 100, "hot": 100}, "apart"],
		"scale_ok": [{"trigger": "static", "effect": "heat_scale", "cold": 50, "hot": 200}, ""],
		"hot_one": [{"trigger": "static", "effect": "hot_hits", "value": 1}, "2 or more"],
		"hot_ok": [{"trigger": "static", "effect": "hot_hits", "value": 2}, ""],
		"piece_unnamed": [{"trigger": "static", "effect": "reboot_piece", "piece": "no_such_piece", "label": "Ray"}, "names its piece"],
		"stoke_none": [{"trigger": "on_attack", "effect": "hit_heat", "value": 0}, "1 or more"],
		"stoke_once": [{"trigger": "on_attack", "effect": "hit_heat", "value": 1, "once": "spend"}, ""],
		"heat_once": [{"trigger": "on_attack", "effect": "add_heat", "value": 1, "once": "spend"}, "once is"],
		"stoke_ok": [{"trigger": "on_attack", "effect": "hit_heat", "value": 1}, ""],
		"lay_hot_none": [{"trigger": "on_attack", "effect": "lay_status", "value": "ablating", "stacks": 1, "overheated": 0}, "past the heat maximum"],
		"lay_hot_ok": [{"trigger": "on_attack", "effect": "lay_status", "value": "ablating", "stacks": 1, "overheated": 2}, ""],
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
