extends TestCase

## A foe's Purge on a machine's buffs (28 October; Purge N, 2 November): a buff a die entry bought
## goes for good; what the machine is (a passive's, a module's, a store's grant) sleeps, its
## clocks running, and wakes at the player's turn. The audit's fifth and sixth bugs (8 November):
## sleeping stacks kept their clock, and grants of one status from different sources stayed
## apart, so a Purge reads each by its own source.


func _unit() -> Unit:
	var u := Unit.mech(0, "A", Vector2i.ZERO)
	u.hull = 100
	u.hull_max = 100
	return u


func test_a_partly_purged_buffs_sleeping_stacks_keep_its_clock() -> void:
	var u := _unit()
	Effects.stack(u, Effects.STATUS["overcharged"], Effects.SKIRMISH, "module:reliquary", 3, Effects.DECAY_HALF)
	var r := Effects.purge(u, 1)
	assert_true((r["lowered"] as Array).size() == 1, "a Purge 1 puts one stack to sleep")
	assert_eq(Effects.stacks_of(u, "overcharged"), 2, "two stand awake")
	Effects.tick(u)   # the round's end: it halves, asleep or awake
	Effects.wake(u)
	assert_eq(Effects.stacks_of(u, "overcharged"), 1, "it wakes where it would stand unpurged: 3 halved to 1")


func test_grants_of_one_status_from_different_sources_stay_apart_for_a_purge() -> void:
	for bought_first in [true, false]:
		var u := _unit()
		if bought_first:
			Effects.grant_buff(u, "overcharged", 2, "buff:overcharge_coil", 1)
		Effects.stack(u, Effects.STATUS["overcharged"], Effects.SKIRMISH, "module:reliquary", 2, Effects.DECAY_HALF)
		if not bought_first:
			Effects.grant_buff(u, "overcharged", 2, "buff:overcharge_coil", 1)
		assert_eq(Effects.stacks_of(u, "overcharged"), 4, "four stacks, one status")
		Effects.purge(u, 4)
		assert_eq(Effects.stacks_of(u, "overcharged"), 0, "a Purge 4 takes them all off")
		Effects.wake(u)
		assert_eq(Effects.stacks_of(u, "overcharged"), 2, "the module's two wake and the bought two are gone, whichever came first (bought first: %s)" % bought_first)


func test_a_reset_lights_a_cooldown_and_leaves_a_foes_switch_off_on_the_same_entry() -> void:
	var u := _unit()
	Effects.disable_entry(u, 0, "cooldown", 3)
	Effects.disable_entry(u, 0, "foe:hush", 3)
	assert_eq(Effects.clear_cooldowns(u), 1, "the reset brings back the cooldown")
	assert_eq(Effects.dark_rounds(u, 0, 1), 3, "and the foe's switch-off stands")
	var left: Array = u.modifiers.filter(func(m) -> bool: return m.id == "disabled_0")
	assert_true(left.size() == 1 and left[0].tags.has(Effects.CLEANSABLE), "the foe's own, a cleanse's to lift")
