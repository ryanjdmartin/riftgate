class_name QuickRun
extends RefCounted

## The quick campaign (Ryan, 25 October; the bible's quick campaign row, section 3): a run of
## battles with no map and no cities, Slice and Dice's flow. A battle is its fights back to back
## against one domain's formations and elites, then its boss; when the boss falls the squad is
## mended, the battle's loot is handed out with the token's component and a maker's offer, and
## the hangar refits it for the next. A test bed for the curve and the enemy's tiers that reads
## a squad fighting every fight together, and perhaps a short campaign one day. Headless and
## seeded, like everything in sim/: the screens and the runner (tools/quick_run.gd) drive it.
##
## Rules, in one place (every number a placeholder):
##   the start     three different tier-one chassis, picked freely, in their stock; the party
##                 dealt as the campaign deals it; the basics free and without limit
##   a battle      a domain drawn at random, and from GUEST_TIER a guest; as many fights before
##                 the boss as the Rupture's Fractures at its tier, ELITES of them elites, then
##                 the boss with its formation; BATTLES of them, a tier every TIER_EVERY, then
##                 the finale, whose last fight is the party's line alone
##   a formation   a domain's whole spawn list in one fight, the lead's and the guest's in turn;
##                 an elite's slot holds the lead's formation alone until the elites land (the
##                 bench hero that stood in went on 27 October)
##   a fight       the squad's machines still standing, their damage carried from the last and
##                 their heat from zero; no withdrawal; won, one field recharge before the next;
##                 every machine wrecked, the run is over
##   the boss dead the campaign's after-battle rule without the shop (hull mends; a destroyed
##                 hardpoint piece is gone, a destroyed fixed one rebuilt); then a loot pick for
##                 each fight before the boss, the token and a maker's offer, each one of
##                 CHOICES, one taken
##   the hangar    up to SQUAD machines of the roster; any piece from the stores on any
##                 hardpoint and any module in any slot, what comes off going back to the stores

const DRAFT := 0     # picking the three chassis
const HANGAR := 1    # between battles: the squad and its fits, the next battle shown
const BATTLE := 2    # a battle under way: its fights in order, one open or the next waiting
const REWARDS := 3   # the boss is dead: the picks, the token and the offer, in order
const OVER := 4      # the run is over; `won` says which way

# ---- placeholders, every one
const START_MACHINES := 3
const SQUAD := Campaign.SQUAD
const BATTLES := Campaign.FINALE_AT         # the campaign's twelve battles, the finale after them (Ryan, 25 October: the full run for now)
const TIER_EVERY := Campaign.TIER_EVERY     # a battle a step of the Convergence, a tier every four
const TOP_TIER := 2                         # the tiers count 0 to 2, shown 1 to 3
const GUEST_TIER := Campaign.GUEST_TIER
const FINAL_TIER := 1                        # from tier two a domain's final may be a battle's boss (Ryan, 25 October)
const FRACTURES := Ramp.FRACTURES   # the fights before the boss by tier: the Rupture's Fractures (bible section 4's pacing row; the one table, 30 October)
const ELITES := [1, 2, 3]           # of them, elites: an elite counts a Fracture (Ryan, 25 October), as many as the Fractures the tier names (Ramp.ELITE_FRACTURES)
const CHOICES := 3             # a loot pick, the token and the offer: one of three
## A loot pick's items by the battle's tier: the weights of item tiers one, two and three (the
## curve proposal's calls, Ryan 24 October: a tier-two rift still deals tier one, and tier three
## is a chance, none from tier one, small from tier two, larger from tier three).
const LOOT_TIERS := [[1.0, 0.0, 0.0], [0.45, 0.5, 0.05], [0.25, 0.6, 0.15]]


## One machine of the roster: a chassis, its hardpoint components in die order (the empty
## hardpoints are what the list leaves over) and its modules in slot order.
class Machine:
	var uid: int = 0
	var chassis: String = ""
	var loadout: Array = []
	var modules: Array = []


var seed_value: int = 1
var rng := RandomNumberGenerator.new()
var db: ContentDB
var state: int = DRAFT
var won: bool = false
var battle: int = 0               # battles begun, the first 1; the finale is BATTLES + 1
var roster: Array = []            # Machine
var squad: Array = []             # roster uids, up to SQUAD, in the order they deploy
var components: Dictionary = {}   # the stores: component id -> copies unfitted (the basics are never counted: free and without limit)
var modules: Dictionary = {}      # the stores: module id -> copies unfitted
var party: Dictionary = {}        # domain -> its dealt hero (the finale's line)
var bosses_ended: Dictionary = {} # domain -> the bosses beaten this run, so the next draws another (the campaign's rule)
var finals_won: Array = []        # domains whose final was won: their hero leaves the finale's line, as in the campaign
## The formations' density by tier, the runner's lever on top of the ramp's own (Ramp.scaled by
## the battle's number as the Convergence; 1.0 everywhere unless the runner asks: docs/measurements.md, 25 October).
var density: Array = [1.0, 1.0, 1.0]
# ---- the battle ahead or under way
var lead: String = ""
var guest: String = ""
var encounters: Array = []        # {"kind": formation, elite, boss or finale; "domain"}, in order
var fight: int = 0                # the encounter under way or next
var units: Array = []             # Unit: the squad as this battle holds it, damage carried, parallel to `squad`
var current: Skirmish = null
var rewards: Array = []           # owed after the boss, in order: {"kind": loot, token or offer, "choices": [...], "maker"}
var history: Array = []           # one report a battle
var lost_at: Dictionary = {}      # where a lost run ended: {"battle", "fight", "kind", "domain"}
var _next_uid: int = 1


func _init(seed_arg: int = 1) -> void:
	seed_value = seed_arg
	rng.seed = seed_arg
	db = ContentDB.load_default()


# ---------------------------------------------------------------- the start

## The chassis the run may start with (Ryan, 25 October: three tier-one chassis, picked freely):
## every tier one the engine can field, in content order.
static func draft_choices(content: ContentDB) -> Array:
	var out: Array = []
	for id in content.chassis_of_tier(1):
		if content.chassis_runnable(str(id)):
			out.append(str(id))
	return out


## Start the run with three different chassis from the draft, in their stock. The party is
## dealt as the campaign deals it, and the first battle drawn. False when the pick is not three
## different chassis the draft offers.
func choose(ids: Array) -> bool:
	if state != DRAFT or ids.size() != START_MACHINES:
		return false
	var offered := draft_choices(db)
	var seen := {}
	for id in ids:
		if not offered.has(str(id)) or seen.has(str(id)):
			return false
		seen[str(id)] = true
	for id in ids:
		squad.append(add_machine(str(id)).uid)
	party = Campaign.deal_party(db, seed_value)
	_roll_battle()
	state = HANGAR
	return true


## Add a machine of `chassis_id` in its stock (a bought chassis brings one copy of each piece
## it stocks, bible section 10).
func add_machine(chassis_id: String) -> Machine:
	var m := Machine.new()
	m.uid = _next_uid
	_next_uid += 1
	m.chassis = chassis_id
	m.loadout = db.chassis[chassis_id].get("loadout", []).duplicate()
	roster.append(m)
	return m


# ---------------------------------------------------------------- reading the run

func machine(uid: int) -> Machine:
	for m in roster:
		if m.uid == uid:
			return m
	return null


## The battle's tier, 0 to 2 (shown 1 to 3): a step of the Convergence a battle, a tier every
## TIER_EVERY; the finale fights at the top.
func tier() -> int:
	return mini(TOP_TIER, maxi(0, battle - 1) / TIER_EVERY)


func is_finale() -> bool:
	return battle > BATTLES


## The unit fighting for a roster machine this battle, or null.
func unit_of(uid: int) -> Unit:
	for u in units:
		if u.id == uid:
			return u
	return null


func live_units() -> Array:
	return units.filter(func(u) -> bool: return u.hull > 0)


func hardpoints(m: Machine) -> int:
	return int(db.chassis.get(m.chassis, {}).get("hardpoints", 0))


func module_slots(m: Machine) -> int:
	return int(db.chassis.get(m.chassis, {}).get("module_slots", 0))


## Basics are free and without limit in the hangar: the run starts with their blueprints and
## has no salvage to build with (bible section 3's quick campaign row).
func is_basic(component_id: String) -> bool:
	return db.component_tier(component_id) == 0


# ---------------------------------------------------------------- the hangar

## The squad for the next battle: one to SQUAD different roster machines, in deploying order.
func set_squad(uids: Array) -> bool:
	if state != HANGAR or uids.is_empty() or uids.size() > SQUAD:
		return false
	var seen := {}
	for uid in uids:
		if machine(int(uid)) == null or seen.has(int(uid)):
			return false
		seen[int(uid)] = true
	squad = []
	for uid in uids:
		squad.append(int(uid))
	return true


## Put a component on a hardpoint of a machine, from the stores or a basic; the piece it
## replaces goes back to the stores. "" strips the hardpoint. A hardpoint past the fitted ones
## takes the next place in the die's order.
func fit(uid: int, slot: int, component_id: String) -> bool:
	var m := machine(uid)
	if state != HANGAR or m == null or slot < 0 or slot >= hardpoints(m):
		return false
	if component_id.is_empty():
		if slot >= m.loadout.size():
			return false
		_store_component(str(m.loadout[slot]))
		m.loadout.remove_at(slot)
		return true
	if not db.components.has(component_id) or db.is_fixed(component_id):
		return false
	if not is_basic(component_id) and int(components.get(component_id, 0)) <= 0:
		return false
	if not is_basic(component_id):
		components[component_id] = int(components[component_id]) - 1
		if int(components[component_id]) <= 0:
			components.erase(component_id)
	if slot < m.loadout.size():
		_store_component(str(m.loadout[slot]))
		m.loadout[slot] = component_id
	else:
		m.loadout.append(component_id)
	return true


## Put a module from the stores in a slot of a machine; the one it replaces goes back. ""
## empties the slot.
func fit_module(uid: int, slot: int, module_id: String) -> bool:
	var m := machine(uid)
	if state != HANGAR or m == null or slot < 0 or slot >= module_slots(m):
		return false
	if module_id.is_empty():
		if slot >= m.modules.size():
			return false
		modules[str(m.modules[slot])] = int(modules.get(str(m.modules[slot]), 0)) + 1
		m.modules.remove_at(slot)
		return true
	if int(modules.get(module_id, 0)) <= 0:
		return false
	modules[module_id] = int(modules[module_id]) - 1
	if int(modules[module_id]) <= 0:
		modules.erase(module_id)
	if slot < m.modules.size():
		modules[str(m.modules[slot])] = int(modules.get(str(m.modules[slot]), 0)) + 1
		m.modules[slot] = module_id
	else:
		m.modules.append(module_id)
	return true


func _store_component(component_id: String) -> void:
	if component_id.is_empty() or is_basic(component_id):
		return   # a basic needs no keeping
	components[component_id] = int(components.get(component_id, 0)) + 1


## Into the battle the hangar shows: the squad's machines made whole from their fits.
func start_battle() -> bool:
	if state != HANGAR or squad.is_empty():
		return false
	units = []
	for uid in squad:
		var m := machine(int(uid))
		units.append(db.make_mech(m.chassis, m.uid, Vector2i.ZERO, m.loadout.duplicate(), m.modules.duplicate()))
	fight = 0
	current = null
	state = BATTLE
	return true


# ---------------------------------------------------------------- a battle

## The next battle: its lead domain at random, a guest from GUEST_TIER, its encounters.
func _roll_battle() -> void:
	battle += 1
	var all: Array = db.factions.keys()
	lead = str(all[rng.randi_range(0, all.size() - 1)]) if not all.is_empty() else ""
	guest = ""
	if tier() >= GUEST_TIER:
		var others: Array = all.filter(func(f) -> bool: return str(f) != lead)
		if not others.is_empty():
			guest = str(others[rng.randi_range(0, others.size() - 1)])
	encounters = _encounters(tier())
	fight = 0


## A battle's encounters at a tier: as many fights before the boss as the Fractures, a
## formation first, then elites and formations in turn, the elites left over at the end, then
## the boss (the finale's line on the finale). The formations are the lead's and the guest's in
## turn; the elites and the boss the lead's.
func _encounters(t: int) -> Array:
	var n: int = FRACTURES[t]
	var e: int = mini(ELITES[t], n)
	var kinds: Array = []
	var f := n - e
	var next_formation := true
	while f > 0 or e > 0:
		if (next_formation and f > 0) or e == 0:
			kinds.append("formation")
			f -= 1
		else:
			kinds.append("elite")
			e -= 1
		next_formation = not next_formation
	var out: Array = []
	var formations := 0
	var dealt := {}   # domain -> formations dealt it this battle, so its compositions come in turn
	var elites_dealt := 0
	for k in kinds:
		var enc := {"kind": k, "domain": lead}
		if k == "formation":
			if not guest.is_empty() and formations % 2 == 1:
				enc["domain"] = guest
			formations += 1
			enc["index"] = int(dealt.get(enc["domain"], 0))   # which of the domain's formation compositions
			dealt[enc["domain"]] = int(enc["index"]) + 1
		else:
			# An elite's slot takes the lead's elite compositions in turn (30 October); with none
			# left, the lead's formation holds the slot as before.
			var elites := db.elite_compositions(lead, t + 1)
			enc["foe"] = str(elites[elites_dealt]["id"]) if elites_dealt < elites.size() else ""
			enc["index"] = 0
			elites_dealt += 1
		out.append(enc)
	if is_finale():
		# The line is drawn as the finale is rolled, so whoever shows it reads the one fought.
		out.append({"kind": "finale", "domain": lead, "line": finale_line()})
	else:
		out.append(_boss_encounter(t))
	return out


## The fight a battle ends on: one of the lead's bosses its battles have not ended on this run,
## or from FINAL_TIER its final, the dealt hero leading the lead's formation, drawn as one more
## boss while that hero stands (Ryan, 25 October: "finale bosses can just appear as a random
## boss in tier 2 or 3"); once all are beaten, any of its bosses again.
func _boss_encounter(t: int) -> Dictionary:
	var hero := str(party.get(lead, ""))
	var final_open := t >= FINAL_TIER and db.foes.has(hero) and not finals_won.has(lead)
	var ended: Array = bosses_ended.get(lead, [])
	var open: Array = Array(db.bosses_of(lead)).filter(func(id) -> bool: return not ended.has(id))
	var n := open.size() + (1 if final_open else 0)
	if n == 0:
		return {"kind": "boss", "domain": lead, "foe": draw_boss(lead)}
	var pick := 0 if n == 1 else rng.randi_range(0, n - 1)
	if pick >= open.size():
		return {"kind": "final", "domain": lead, "foe": hero}
	return {"kind": "boss", "domain": lead, "foe": str(open[pick])}


## Whom an encounter fields, in arrival order (the skirmish deploys the heaviest hitters first):
## an elite composition's members, the boss or a final's hero before the domain's formation; the
## finale's line, as the campaign fields it. A boss, a final's hero and the finale's line stand
## at the battle's tier and bring its escort after them, as the campaign's boss unit does
## (ContentDB.BOSS_TIERS); an elite does not.
func encounter_foes(enc: Dictionary) -> Array:
	var out: Array = []
	var kind := str(enc.get("kind", ""))
	var boss := kind == "boss" or kind == "final" or kind == "finale"
	if kind == "finale":
		for fid in (enc["line"] if enc.has("line") else finale_line()):
			if db.foes.has(str(fid)):
				var f := db.make_foe(str(fid))
				db.scale_boss(f, tier())
				out.append(f)
	elif kind == "elite" and not str(enc.get("foe", "")).is_empty():
		for c in db.elite_compositions(lead, tier() + 1):
			if str(c["id"]) == str(enc["foe"]):
				out.append_array(_composition_foes(c))
		if out.is_empty():
			out.append_array(formation_foes(str(enc.get("domain", lead)), int(enc.get("index", 0))))
	else:
		var lead_foe := str(enc.get("foe", ""))
		if db.foes.has(lead_foe):
			var f := db.make_foe(lead_foe)
			if boss:
				db.scale_boss(f, tier())
			out.append(f)
		out.append_array(formation_foes(str(enc.get("domain", lead)), int(enc.get("index", 0))))
	if boss:
		out.append_array(escort_foes(str(enc.get("domain", lead))))
	return out


## A boss's escort at the battle's tier, beyond its formation: the domain's own units of the
## tier, ContentDB.escort_at(tier) of them, as the campaign's boss unit brings it.
func escort_foes(domain: String) -> Array:
	return Array(db.escort_units(domain, tier(), ContentDB.escort_at(tier())))


## A domain's formation: the tier's formation compositions in turn (`index`, wrapping), at the
## ramp's density times the runner's lever; the whole derived list when the domain has none.
func formation_foes(domain: String, index: int = 0) -> Array:
	var forms := db.compositions(domain, tier() + 1, "formation")
	if not forms.is_empty():
		return _composition_foes(forms[index % forms.size()])
	var out: Array = []
	var d: float = float(density[tier()]) if tier() < density.size() else 1.0
	for e in db.spawn_table(domain, tier() + 1):
		if not db.foes.has(str(e[0])):
			continue
		for i in range(maxi(1, roundi(int(e[1]) * d))):
			out.append(db.make_foe(str(e[0])))
	return out


## A composition's foes: every member at the ramp's density (the battle's number as the
## Convergence) times the runner's lever for the tier.
func _composition_foes(c: Dictionary) -> Array:
	var out: Array = []
	var d: float = float(density[tier()]) if tier() < density.size() else 1.0
	for m in c.get("members", []):
		if not db.foes.has(str(m[0])):
			continue
		for i in range(maxi(1, roundi(float(Ramp.scaled(int(m[1]), ramp())) * d))):
			var f := db.make_foe(str(m[0]))
			if f.wanders:
				db.scale_boss(f, tier())   # a wandering elite stands at the battle's tier (31 October)
			out.append(f)
	return out


## The battle's ramp: its number as the Convergence (the campaign's a battle a step).
func ramp() -> int:
	return clampi(maxi(0, battle - 1), 0, Ramp.TOP)


## The elite a domain fields first at the battle's tier: its first elite composition's id, or
## "" when it has none, so the slot holds the lead's formation alone and the Fracture count
## stands (the bench hero that stood in went on 27 October, Ryan: "just a can of worms").
func elite_of(domain: String) -> String:
	var elites := db.elite_compositions(domain, tier() + 1)
	return str(elites[0]["id"]) if not elites.is_empty() else ""


## The boss a domain brings: one its battles have not ended on this run, any once all have been
## (Campaign.draw_boss's rule).
func draw_boss(domain: String) -> String:
	var all := db.bosses_of(domain)
	if all.size() <= 1:
		return all[0] if not all.is_empty() else ""
	var ended: Array = bosses_ended.get(domain, [])
	var open: Array = all.filter(func(id: String) -> bool: return not ended.has(id))
	if open.is_empty():
		open = all
	return str(open[rng.randi_range(0, open.size() - 1)])


## The finale's line, the campaign's rule (Campaign.finale_line): each domain's dealt hero
## promoted, a column a domain, in content order; a domain whose final was won leaves its column
## to boss-tier wildlife of a domain still standing, each standing domain's boss drawn in turn
## before any comes twice.
func finale_line() -> Array:
	var standing: Array = []
	for fid in db.factions.keys():
		if not finals_won.has(fid):
			standing.append_array(db.bosses_of(str(fid)))
	var bag: Array = []
	var out: Array = []
	for fid in db.factions.keys():
		var promoted := db.promoted_form(str(party.get(fid, "")))
		if not finals_won.has(fid) and not promoted.is_empty():
			out.append(promoted)
			continue
		if standing.is_empty():
			continue
		if bag.is_empty():
			bag = standing.duplicate()
		out.append(str(bag.pop_at(rng.randi_range(0, bag.size() - 1))))
	return out


## The fight under way, opened on the next encounter if none is: the squad's machines still
## standing against its foes, no withdrawal. Null outside a battle.
func open_fight() -> Skirmish:
	if state != BATTLE:
		return null
	if current != null:
		return current
	var sk := Skirmish.new(rng.randi())
	sk.committed = true
	sk.foe_factory = func(foe_id: String) -> Foe: return db.make_foe(foe_id) if db.foes.has(foe_id) else null
	for u in live_units():
		sk.add_mech(u)
	sk.add_foes(encounter_foes(encounters[fight]))
	current = sk
	return sk


## Apply the fight just finished: won, the next encounter waits after a field recharge, or the
## boss's fall ends the battle; lost, the run is over. Returns the fight's report, empty while
## the fight is still on.
func finish_fight() -> Dictionary:
	var sk := current
	if state != BATTLE or sk == null or sk.state != Skirmish.State.DONE:
		return {}
	current = null
	var enc: Dictionary = encounters[fight]
	var report := {"battle": battle, "tier": tier(), "fight": fight, "kind": str(enc["kind"]), "domain": str(enc["domain"]),
		"won": sk.outcome == Skirmish.Outcome.VICTORY, "rounds": sk.round, "destroyed": sk.destroyed,
		"hull_left": hull_left(), "standing": live_units().size()}
	if sk.outcome != Skirmish.Outcome.VICTORY:
		lost_at = {"battle": battle, "fight": fight, "kind": str(enc["kind"]), "domain": str(enc["domain"])}
		history.append(_battle_report(false))
		units = []
		state = OVER
		won = false
		return report
	if str(enc["kind"]) == "boss" and not str(enc.get("foe", "")).is_empty():
		var ended: Array = bosses_ended.get(lead, [])
		ended.append(str(enc["foe"]))
		bosses_ended[lead] = ended
	elif str(enc["kind"]) == "final" and not finals_won.has(lead):
		finals_won.append(lead)
	fight += 1
	if fight < encounters.size():
		_recharge()
	else:
		_battle_won()
	return report


## The walk to the next fight (Ryan, 25 October: one field recharge after each fight): every
## machine standing regains its field rate, and what fires out of a fight fires.
func _recharge() -> void:
	for u in live_units():
		u.recharge_shield(u.recharge_field)
		var fired := Effects.fire(u, "out_of_combat")
		if int(fired["shield"]) > 0:
			u.recharge_shield(int(fired["shield"]))


## The squad's hull standing, as a share of its whole (a wreck counts nothing).
func hull_left() -> float:
	var have := 0
	var whole := 0
	for u in units:
		whole += u.hull_max
		have += maxi(0, u.hull)
	return 100.0 * have / maxi(1, whole)


## The boss is down: the after-battle rule, then the rewards (or the run won, at the finale).
func _battle_won() -> void:
	var lost: Array = []
	var wrecked: Array = []
	for u in units:
		var m := machine(u.id)
		if m == null or u.die == null:
			continue
		var wreck: bool = u.hull <= 0
		if wreck:
			wrecked.append(m.uid)
		var r := Campaign.after_battle_loadout(db, m.chassis, u)
		m.loadout = r[0]
		lost.append_array(r[1])
	var report := _battle_report(true)
	report["lost"] = lost
	report["wrecked"] = wrecked
	history.append(report)
	units = []
	if is_finale():
		state = OVER
		won = true
		return
	rewards = []
	for i in range(encounters.size() - 1):
		var picks := _loot_choices()
		if not picks.is_empty():
			rewards.append({"kind": "loot", "choices": picks})
	var token := _token_choices()
	if not token.is_empty():
		rewards.append({"kind": "token", "choices": token})
	var makers: Array = db.makers.keys()
	if not makers.is_empty():
		var mk := str(makers[rng.randi_range(0, makers.size() - 1)])
		var offer := _offer_choices(mk)
		if not offer.is_empty():
			rewards.append({"kind": "offer", "maker": mk, "choices": offer})
	state = REWARDS
	if rewards.is_empty():
		_next_battle()


func _battle_report(battle_won: bool) -> Dictionary:
	return {"battle": battle, "tier": tier(), "lead": lead, "guest": guest, "won": battle_won,
		"fights": fight + (0 if battle_won else 1), "finale": is_finale(), "lost": [], "wrecked": []}


## The rewards are taken: the hangar opens on the next battle, the squad as it was (a wreck is
## mended with the rest; no shop).
func _next_battle() -> void:
	_roll_battle()
	state = HANGAR


# ---------------------------------------------------------------- the rewards

## Take one of the choices of the reward owed first. The last one taken opens the hangar on the
## next battle.
func take(index: int) -> bool:
	if state != REWARDS or rewards.is_empty():
		return false
	var r: Dictionary = rewards[0]
	var choices: Array = r.get("choices", [])
	if index < 0 or index >= choices.size():
		return false
	var item: Dictionary = choices[index]
	var id := str(item.get("id", ""))
	match str(item.get("kind", "")):
		"component":
			components[id] = int(components.get(id, 0)) + 1
		"module":
			modules[id] = int(modules.get(id, 0)) + 1
		"chassis":
			var m := add_machine(id)
			if squad.size() < SQUAD:
				squad.append(m.uid)
	rewards.pop_front()
	if rewards.is_empty():
		_next_battle()
	return true


## The pieces of a tier the run may find: unlocked components and modules the engine runs.
func pool(item_tier: int) -> Array:
	var out: Array = []
	for cid in db.components.keys():
		if db.component_tier(str(cid)) == item_tier and str(db.components[cid].get("status", "")) != "planned":
			out.append({"kind": "component", "id": str(cid)})
	for mid in db.modules.keys():
		if int(db.modules[mid].get("tier", 0)) == item_tier:
			out.append({"kind": "module", "id": str(mid)})
	return out


## A loot pick: CHOICES different pieces, each of a tier drawn by LOOT_TIERS at the battle's.
func _loot_choices() -> Array:
	var weights: Array = LOOT_TIERS[tier()]
	var out: Array = []
	var guard := 0
	while out.size() < CHOICES and guard < 64:
		guard += 1
		var roll := rng.randf() * (float(weights[0]) + float(weights[1]) + float(weights[2]))
		var item_tier := 1 if roll < float(weights[0]) else (2 if roll < float(weights[0]) + float(weights[1]) else 3)
		var open: Array = pool(item_tier).filter(func(it) -> bool: return not out.has(it))
		if not open.is_empty():
			out.append(open[rng.randi_range(0, open.size() - 1)])
	return out


## The boss's token, unpacked as a component (Ryan, 25 October, in place of a blueprint): one of
## CHOICES at the battle's tier, never below while the tier has them (his call of 24 October);
## its modules fill a tier short of components (tier three holds two), then the tier below.
func _token_choices() -> Array:
	var t := tier() + 1
	var out: Array = []
	for item_tier in range(t, 0, -1):
		var comps: Array = pool(item_tier).filter(func(it) -> bool: return it["kind"] == "component")
		var mods: Array = pool(item_tier).filter(func(it) -> bool: return it["kind"] == "module")
		for list in [comps, mods]:
			_shuffle(list)
			for it in list:
				if out.size() < CHOICES:
					out.append(it)
		if out.size() >= CHOICES:
			break
	return out


## A maker's offer (the campaign's, with the maker drawn from all five: Ryan, 25 October, so
## the Arsenal's chassis are seen too): a chassis the engine can field, at or under the battle's
## tier and not one the roster holds; a component of the battle's tier, else the highest under
## it the maker makes; a module at or under the tier.
func _offer_choices(maker: String) -> Array:
	var t := tier() + 1
	var out: Array = []
	var held: Array = roster.map(func(m) -> String: return m.chassis)
	var bodies: Array = []
	for id in db.chassis.keys():
		var c: Dictionary = db.chassis[id]
		if str(c.get("maker", "")) == maker and int(c.get("tier", 0)) <= t and db.chassis_runnable(str(id)) and not held.has(str(id)):
			bodies.append(str(id))
	if not bodies.is_empty():
		out.append({"kind": "chassis", "id": bodies[rng.randi_range(0, bodies.size() - 1)]})
	for item_tier in range(t, 0, -1):
		var pieces: Array = pool(item_tier).filter(func(it) -> bool: return it["kind"] == "component" and str(db.components[it["id"]].get("maker", "")) == maker)
		if not pieces.is_empty():
			out.append(pieces[rng.randi_range(0, pieces.size() - 1)])
			break
	var mods: Array = []
	for item_tier in range(t, 0, -1):
		for it in pool(item_tier):
			if it["kind"] == "module" and str(db.modules[it["id"]].get("maker", "")) == maker:
				mods.append(it)
	if not mods.is_empty():
		out.append(mods[rng.randi_range(0, mods.size() - 1)])
	return out


func _shuffle(a: Array) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = a[i]
		a[i] = a[j]
		a[j] = t
