extends TestCase

## A Purge N on either side (28 October; its number since 2 November; Ryan, 8 November: "A stack
## is a stack, doesn't matter where it came from"): every buff a unit carries loses N stacks for
## good, whatever granted them, a die entry, a module, a kill; an ability is no buff and stays
## ("It's not a Buff, it's not a Debuff, it's labelled as an Ability, so it doesn't get purged").


func _unit() -> Unit:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.hull = 100
	u.hull_max = 100
	return u


func test_a_stack_is_a_stack_whatever_granted_it() -> void:
	var u := _unit()
	Effects.grant_buff(u, "overcharged", 2, "buff:overcharge_coil", 1)
	Effects.stack(u, Effects.STATUS["overcharged"], Effects.SKIRMISH, "passive:grievance_reliquary", 2, Effects.DECAY_HALF)
	assert_eq(Effects.stacks_of(u, "overcharged"), 4, "four stacks, one status")
	assert_eq(Effects.purge(u, 3), ["Empowered 1"] as Array[String], "a Purge 3 takes three, whichever granted them")
	assert_eq(Effects.purge(u, 3), ["Empowered gone"] as Array[String], "and the last goes with the next")
	assert_false(Effects.has(u, "overcharged"), "nothing comes back")


func test_abilities_stores_and_kept_stacks_stay() -> void:
	var u := _unit()
	Effects.stack(u, Effects.sealed_status(3, 2), Effects.SKIRMISH, "seal", 1, Effects.DECAY_NONE)
	Effects.stack(u, Effects.STATUS["hot_streak"], Effects.SKIRMISH, "passive:regulators", 2, Effects.DECAY_NONE)
	Effects.stack(u, Effects.STATUS["muster"], Effects.SKIRMISH, "muster", 30, Effects.DECAY_NONE)
	assert_true(Effects.is_ability("sealed") and Effects.is_ability("hot_streak"), "the seal and Hot Streak are abilities")
	assert_true(Effects.purge(u, 9).is_empty(), "so a Purge finds nothing")
	assert_true(Effects.is_sealed(u) and Effects.has(u, "hot_streak") and Effects.has(u, "muster"), "the abilities and the store stand")
	var keeper := _unit()
	keeper.grant_passive({"id": "tap", "name": "Tap", "description": "", "effects": [{"trigger": "static", "effect": "keep_status", "value": "overcharged"}]})
	Effects.stack(keeper, Effects.STATUS["overcharged"], Effects.SKIRMISH, "kill", 5, Effects.DECAY_HALF)
	assert_true(Effects.purge(keeper, 9).is_empty() and Effects.stacks_of(keeper, "overcharged") == 5, "a kept stack stays: the Ammit's Quintessence Tap")


func test_a_foes_abilities_stay_and_its_buffs_go() -> void:
	var f := Foe.make("ape", 40, 6)
	Effects.stack(f, Effects.STATUS["golden"], Effects.SKIRMISH, "foe:ape", 1, Effects.DECAY_NONE)
	Effects.stack(f, Effects.STATUS["guarded"], Effects.SKIRMISH, "foe:ape", 1, Effects.DECAY_NONE)
	Effects.stack(f, Effects.STATUS["kindled"], Effects.SKIRMISH, "foe:shaman", 2, Effects.DECAY_HALF)
	Effects.stack(f, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:ape", 1, Effects.DECAY_NONE)
	assert_eq(Effects.purge(f, 9), ["Empowered gone", "Undying gone"] as Array[String], "its buffs go")
	assert_true(Effects.has(f, "golden") and Effects.has(f, "guarded"), "its abilities stay")


func test_a_save_from_before_the_rule_loads_a_sleeping_buff_awake() -> void:
	var u := _unit()
	var md := SaveGame._modifier_dict(Effects.stack(u, Effects.STATUS["overcharged"], Effects.SKIRMISH, "passive:reliquary", 2, Effects.DECAY_HALF))
	md["slept_stacks"] = 1
	md["slept"] = true
	var back: Array = SaveGame._modifiers_from([md])
	assert_eq(back.size(), 1, "one grant")
	assert_eq(int(back[0].stacks), 3, "its sleeping stack back on it, awake")
