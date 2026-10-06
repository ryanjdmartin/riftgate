class_name Campaign
extends RefCounted

## The run (bible sections 3 and 10, decided 5 October; the between-battle rules, first
## pass, 6 October). Five cities, one a capital, each gate the only number that tracks its
## city's health. Rifts open at cities, each with a faction rolled when it opens; the open
## ones are the fronts. A battle is fought at one front with up to four ready machines;
## what it ends in decides the city, the roster and the salvage, then the turn ends: every
## other open rift bleeds its city's gate, every fallen city's horde drains the capital,
## the threat rises and new rifts open. The finale is due at the threat threshold and is
## fought at the capital on what its gate has left.
##
## Headless and seeded, like everything in sim/: the screens and the runner decide when to
## call it. Numbers here are placeholders (the constants below), measured by
## `tools/campaign_run.gd`, never tuned by guess.
##
## Rules, in one place:
##   won battle     the city's gate is restored to full (the siege is lifted) and its rift
##                  closes; the city opens no new rift for QUIET_TURNS; the battle's salvage
##                  banks; the boss drops a research token of its faction; the host maker
##                  owes an offer
##   gate fallen    the city falls; the battle's salvage is lost; its rift stays open and
##                  its horde drains the capital every turn from then on
##   team wiped     the horde strikes the gate unopposed for WIPE_PHASES; at zero the city
##                  falls as above, otherwise it stands wounded, the rift stays, the salvage
##                  is kept; no token, no offer
##   every machine  hull and cracked components repair free; a destroyed hardpoint
##                  component is gone, a destroyed fixed one rebuilt; a wreck also loses its
##                  cracked components and sits out SHOP_BATTLES battles, unless rushed
##   end of a turn  (after a battle, or a turn passed) open rifts bleed their cities, a gate
##                  at zero falls unfought, fallen cities drain the capital, the capital at
##                  zero loses the run, the threat rises, rifts open up to the tier's count

const PICK := 0     # between battles: choose a front, refit, rush, repair the capital, or pass
const BATTLE := 1   # a battle is under way (`battle`, at `battle_city`)
const OVER := 2     # the run is over; `won` says which way

# ---- placeholders, every one (bible section 10, the numbers row: measured, then set)
const CITY_GATE := 200        # a city's gate, full (the battle's gate was 200 before the campaign)
const CAPITAL_GATE := 300     # the capital's gate: the run's life bar
const BLEED := 50             # a city under an open rift it was not defended at loses this a turn
const DRAIN := 25             # each fallen city's horde takes this from the capital a turn
const SQUAD := 4              # machines a battle takes at most (four columns, section 5)
const WIPE_PHASES := 6        # phases the horde strikes the gate unopposed after a team wipe
const SALVAGE_PER_FOE := 1    # salvage for each foe a won skirmish kills
const START_SALVAGE := 20     # enough for one rush
const RUSH_PRICE := 20        # salvage to bring a wreck out of the shop now (6 October: a choice after a wreck, never routine repair)
const CAPITAL_REPAIR := 2     # capital gate points one salvage buys (the one priced repair, section 3)
const THREAT_PER_TURN := 1    # a turn passed raises it too, so waiting never stops the clock
const TIER_EVERY := 4         # threat per tier
const FINALE_AT := 12         # the threat that makes the finale due (twelve battles, section 3); each fallen city brings it one sooner
const RIFTS_BASE := 2         # rifts open at tier 0; one more a tier
const GUEST_TIER := 1         # from this tier a rift carries a guest faction
const QUIET_TURNS := 1        # a city whose rift was closed opens no new one for this many turns
const SHOP_BATTLES := 1       # a wreck sits out this many battles
const FINAL_AFTER := 3        # bosses of one faction beaten before its next rift is its final (track B; no final boss exists yet, so a final is a battle flagged as one)


## One city. `id` is its host maker's id; the capital's is the capital maker's.
class City:
	var id: String = ""
	var capital: bool = false
	var gate: int = 0
	var gate_max: int = 0
	var fallen: bool = false
	var quiet: int = 0              # turns left before a new rift may open here
	var rift: Dictionary = {}       # empty for none; {"faction", "guest", "final"}


## One machine of the roster: a chassis, what is fitted on its hardpoints, and the shop.
class Machine:
	var uid: int = 0
	var chassis: String = ""
	var loadout: Array = []         # hardpoint components fitted, in die order; fixed ones are the chassis's
	var shop: int = 0               # battles left in the shop; 0 is ready


var seed_value: int = 1
var rng := RandomNumberGenerator.new()
var db: ContentDB
var state: int = PICK
var won: bool = false
var turn: int = 0                 # turns ended
var threat: int = 0
var cities: Dictionary = {}       # city id -> City, the capital last
var roster: Array = []            # Machine
var components: Dictionary = {}   # component id -> count owned and not fitted
var salvage: int = 0
var blueprints: Array = []        # blueprint ids held this run (nothing yields one yet)
var tokens: Array = []            # research tokens, by the faction whose boss dropped them (unpacked in the hangar, not built)
var offers: Array = []            # city ids whose maker owes an offer (the offer itself waits on the catalogues)
var bosses_beaten: Dictionary = {}   # faction id -> bosses beaten this run
var finals_won: Array = []        # factions thinned: they lead no new rift
var battle: Battle = null
var battle_city: String = ""
var squad: Array = []             # roster uids fighting `battle`
var history: Array = []           # one report a battle (finish_battle's)
var _next_uid: int = 1


## A new run. `team` is the starting roster's chassis ids (the draft is not designed yet;
## the default is the content's starting team).
func _init(seed_arg: int = 1, team: Array = []) -> void:
	seed_value = seed_arg
	rng.seed = seed_arg
	db = ContentDB.load_default()
	for id in db.city_makers():
		_add_city(str(id), false)
	_add_city(db.capital_maker(), true)
	for cid in (team if not team.is_empty() else db.default_team()):
		add_machine(str(cid))
	salvage = START_SALVAGE
	_open_rifts()


func _add_city(id: String, capital: bool) -> void:
	var c := City.new()
	c.id = id
	c.capital = capital
	c.gate_max = CAPITAL_GATE if capital else CITY_GATE
	c.gate = c.gate_max
	cities[id] = c


## Add a machine of `chassis_id` in its stock loadout, ready. Its uid is the run's.
func add_machine(chassis_id: String, loadout = null) -> Machine:
	var m := Machine.new()
	m.uid = _next_uid
	_next_uid += 1
	m.chassis = chassis_id
	m.loadout = (db.chassis[chassis_id].get("loadout", []) if loadout == null else loadout).duplicate()
	roster.append(m)
	return m


# ---------------------------------------------------------------- reading the run

func capital() -> City:
	for c in cities.values():
		if c.capital:
			return c
	return null


func machine(uid: int) -> Machine:
	for m in roster:
		if m.uid == uid:
			return m
	return null


func ready_machines() -> Array:
	var out: Array = []
	for m in roster:
		if m.shop == 0:
			out.append(m)
	return out


func tier() -> int:
	return threat / TIER_EVERY


func fallen_count() -> int:
	var n := 0
	for c in cities.values():
		if c.fallen and not c.capital:
			n += 1
	return n


func finale_due() -> bool:
	return threat >= FINALE_AT - fallen_count()


## Where a battle can be fought: every standing city under an open rift, or, once the
## finale is due, the capital alone.
func fronts() -> Array:
	var out: Array = []
	if finale_due():
		var cap := capital()
		if cap != null and not cap.rift.is_empty():
			out.append(cap.id)
		return out
	for c in cities.values():
		if not c.capital and not c.fallen and not c.rift.is_empty():
			out.append(c.id)
	return out


## The warning the front card shows (6 October: never a forced last stand): turns until an
## undefended city's gate bleeds to zero and it falls unfought. -1 when nothing bleeds it.
func turns_to_fall(city_id: String) -> int:
	var c: City = cities.get(city_id)
	if c == null or c.fallen or c.capital or c.rift.is_empty():
		return -1
	return int(ceil(float(c.gate) / float(BLEED)))


# ---------------------------------------------------------------- a battle

## Open a battle at `city_id` with the ready machines `uids` (one to SQUAD). Null when the
## run is not between battles, the city is no front, or the squad is not ready.
func start_battle(city_id: String, uids: Array) -> Battle:
	if state != PICK or not fronts().has(city_id) or uids.is_empty() or uids.size() > SQUAD:
		return null
	var team: Array = []
	for uid in uids:
		var m := machine(int(uid))
		if m == null or m.shop > 0:
			return null
		team.append(db.make_mech(m.chassis, m.uid, Vector2i.ZERO, m.loadout))
	var c: City = cities[city_id]
	var b := Battle.new(rng.randi_range(1, 1 << 30))
	b.guest = str(c.rift.get("guest", ""))
	b.setup(team, str(c.rift.get("faction", "")))
	b.field.gate_hp_max = c.gate_max
	b.field.gate_hp = c.gate
	battle = b
	battle_city = city_id
	squad = uids.duplicate()
	state = BATTLE
	return b


## Apply a finished battle to the run, end the turn, and report what happened:
## {"turn", "city", "faction", "guest", "result" ("won", "held" or "fell"), "wiped",
##  "gate_left", "salvage", "lost" (component ids gone for good), "wrecked" (uids), "phases"}.
## Empty when no battle has finished.
func finish_battle() -> Dictionary:
	if state != BATTLE or battle == null or battle.state != Battle.State.DONE:
		return {}
	var b := battle
	var c: City = cities[battle_city]
	var wiped := b.outcome == Battle.Outcome.WRECKED
	if wiped:
		# Nobody stands in the way: the horde walks on and strikes the gate (6 October).
		for i in range(WIPE_PHASES):
			if b.field.gate_hp <= 0:
				break
			b.field.compute_intents()
			b.field.resolve_phase({})
	var report := {"turn": turn, "city": c.id, "faction": b.faction, "guest": b.guest, "wiped": wiped,
		"phases": b.field.phase, "lost": [], "wrecked": [], "salvage": 0}
	# The machines.
	var wrecked: Array = []
	for uid in squad:
		var m := machine(int(uid))
		var u := _fielded(b, int(uid))
		if m == null or u == null:
			continue
		var wreck := u.hull <= 0 or not b.field.units.has(u)
		if wreck:
			wrecked.append(m)
		report["lost"].append_array(_after_battle(m, u, wreck))
	for m in wrecked:
		report["wrecked"].append(m.uid)
	# The city.
	var faction := b.faction
	c.gate = maxi(0, b.field.gate_hp)
	if b.outcome == Battle.Outcome.VICTORY:
		report["result"] = "won"
		c.gate = c.gate_max
		var final := bool(c.rift.get("final", false))
		c.rift = {}
		c.quiet = QUIET_TURNS
		var banked := b.foes_killed * SALVAGE_PER_FOE
		salvage += banked
		report["salvage"] = banked
		tokens.append(faction)
		offers.append(c.id)
		bosses_beaten[faction] = int(bosses_beaten.get(faction, 0)) + 1
		if final and not finals_won.has(faction):
			finals_won.append(faction)
	elif c.gate <= 0:
		report["result"] = "fell"
		_fall(c)
	else:
		report["result"] = "held"
		var banked := b.foes_killed * SALVAGE_PER_FOE
		salvage += banked
		report["salvage"] = banked
	report["gate_left"] = c.gate
	history.append(report)
	var fought := c.id
	battle = null
	battle_city = ""
	squad = []
	state = PICK
	if c.capital and report["result"] == "won":
		won = true
		state = OVER
	elif c.capital and report["result"] == "fell":
		state = OVER
	if state != OVER:
		_end_turn(fought)
	for m in wrecked:
		m.shop = SHOP_BATTLES
	return report


## A battle's machine as the battle holds it: on the field, or among its wrecks.
func _fielded(b: Battle, uid: int) -> Unit:
	var u := b.field.unit_by_id(uid)
	if u != null and u.is_player():
		return u
	for w in b.wrecks:
		if w.id == uid:
			return w
	return null


## What a battle left a machine with (section 3, the hangar row): hull and cracks repair
## free and a destroyed fixed component is rebuilt, since both are the chassis's; a
## destroyed hardpoint component is gone; a wreck loses its cracked ones too. Returns the
## component ids lost.
func _after_battle(m: Machine, u: Unit, wreck: bool) -> Array:
	var fixed_n: int = db.chassis.get(m.chassis, {}).get("fixed", []).size()
	var kept: Array = []
	var lost: Array = []
	if u.die == null:
		return lost
	for idx in range(fixed_n, u.die.faces.size()):
		var f: Face = u.die.faces[idx]
		if f.component.is_empty():
			continue   # an empty hardpoint: nothing was there
		var destroyed := f.kind == Face.Kind.BLANK and not f.empty and not f.disabled
		if destroyed or (wreck and f.cracked):
			lost.append(f.component)
		else:
			kept.append(f.component)
	m.loadout = kept
	return lost


func _fall(c: City) -> void:
	c.fallen = true
	c.gate = 0
	# The rift stays open: the city's horde is loose and marches on the capital.


## Spend the turn without a battle (6 October: waiting a cycle for the shop is a choice).
func pass_turn() -> void:
	if state != PICK:
		return
	_end_turn("")


func _end_turn(fought: String) -> void:
	turn += 1
	for m in roster:
		if m.shop > 0:
			m.shop -= 1
	# Every open rift the player did not fight at bleeds its city; a gate at zero falls.
	for c in cities.values():
		if c.capital or c.fallen or c.rift.is_empty() or c.id == fought:
			continue
		c.gate = maxi(0, c.gate - BLEED)
		if c.gate <= 0:
			_fall(c)
	# Every fallen city's horde drains the capital; at zero the run is lost.
	var cap := capital()
	if cap != null:
		cap.gate = maxi(0, cap.gate - DRAIN * fallen_count())
		if cap.gate <= 0:
			cap.fallen = true
			state = OVER
			won = false
			return
	threat += THREAT_PER_TURN
	_open_rifts()
	for c in cities.values():
		c.quiet = maxi(0, c.quiet - 1)


## Open rifts up to the tier's count at standing, quiet-free cities; once the finale is
## due, one at the capital.
func _open_rifts() -> void:
	var cap := capital()
	if finale_due() and cap != null and cap.rift.is_empty():
		cap.rift = _roll_rift()
	var open := 0
	var free: Array = []
	for c in cities.values():
		if c.capital or c.fallen:
			continue
		if not c.rift.is_empty():
			open += 1
		elif c.quiet == 0:
			free.append(c)
	while open < RIFTS_BASE + tier() and not free.is_empty():
		var c: City = free.pop_at(rng.randi_range(0, free.size() - 1))
		c.rift = _roll_rift()
		open += 1


## A rift's factions (6 October: rolled when the rift opens, never fixed to a city). The
## lead is any faction not yet thinned; a guest, from GUEST_TIER, any other faction.
func _roll_rift() -> Dictionary:
	var all: Array = db.factions.keys()
	var leads: Array = []
	for f in all:
		if not finals_won.has(f):
			leads.append(f)
	if leads.is_empty():
		leads = all
	var lead := str(leads[rng.randi_range(0, leads.size() - 1)]) if not leads.is_empty() else ""
	var guest := ""
	if tier() >= GUEST_TIER:
		var others: Array = []
		for f in all:
			if str(f) != lead:
				others.append(f)
		if not others.is_empty():
			guest = str(others[rng.randi_range(0, others.size() - 1)])
	var final := int(bosses_beaten.get(lead, 0)) >= FINAL_AFTER and not finals_won.has(lead)
	return {"faction": lead, "guest": guest, "final": final}


# ---------------------------------------------------------------- the hangar

## Bring a wreck out of the shop now, for RUSH_PRICE salvage.
func rush(uid: int) -> bool:
	var m := machine(uid)
	if state != PICK or m == null or m.shop == 0 or salvage < RUSH_PRICE:
		return false
	salvage -= RUSH_PRICE
	m.shop = 0
	return true


## Spend up to `spend` salvage on the capital's gate, CAPITAL_REPAIR points each, never
## past full. Returns the salvage spent.
func repair_capital(spend: int) -> int:
	var cap := capital()
	if state != PICK or cap == null:
		return 0
	var room := int(ceil(float(cap.gate_max - cap.gate) / float(CAPITAL_REPAIR)))
	var n := clampi(mini(spend, salvage), 0, room)
	salvage -= n
	cap.gate = mini(cap.gate_max, cap.gate + n * CAPITAL_REPAIR)
	return n


## Fit an owned component on a free hardpoint (refit is instant, section 3).
func fit(uid: int, component_id: String) -> bool:
	var m := machine(uid)
	if state != PICK or m == null or int(components.get(component_id, 0)) <= 0:
		return false
	if m.loadout.size() >= int(db.chassis[m.chassis].get("hardpoints", 0)):
		return false
	components[component_id] = int(components[component_id]) - 1
	if int(components[component_id]) == 0:
		components.erase(component_id)
	m.loadout.append(component_id)
	return true


## Take the component at `index` of a machine's loadout off, back into the owned stock.
func strip(uid: int, index: int) -> bool:
	var m := machine(uid)
	if state != PICK or m == null or index < 0 or index >= m.loadout.size():
		return false
	var cid := str(m.loadout[index])
	m.loadout.remove_at(index)
	components[cid] = int(components.get(cid, 0)) + 1
	return true
