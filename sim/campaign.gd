class_name Campaign
extends RefCounted

## The run (bible sections 3 and 10, decided 5 October; the between-battle rules, first
## pass, 6 October). Five cities, one a capital, each gate the only number that tracks its
## city's health. Rifts open at cities, each with a faction rolled when it opens; the open
## ones are the fronts. A battle is fought at one front with up to four ready machines;
## what it ends in decides the city, the roster and the salvage, then the turn ends: every
## other open rift bleeds its city's gate, every fallen city's horde drains the capital,
## the Convergence rises and new rifts open. The finale is due at the Convergence's threshold and is
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
##   third boss     a domain's FINAL_AFTER-th boss beaten sets its final: every standing
##                  city's rift it leads turns final at once, its hero the boss, and so does
##                  every rift it leads after
##   won final      the domain is beaten: it leads no new rift and guests none, and every
##                  standing city's rift it leads closes too, that city quiet for QUIET_TURNS,
##                  its gate as it stood and nothing paid (a free reprieve)
##   gate fallen    the city falls; the battle's salvage is lost; its rift stays open and
##                  its horde drains the capital every turn from then on
##   team wiped     the horde strikes the gate unopposed for WIPE_PHASES; at zero the city
##                  falls as above, otherwise it stands wounded, the rift stays, the salvage
##                  is kept; no token, no offer
##   every machine  hull repairs free; a destroyed hardpoint component is gone, a
##                  destroyed fixed one rebuilt; a wreck sits out SHOP_BATTLES battles,
##                  unless rushed
##   end of a turn  (after a battle, or a turn passed) open rifts bleed their cities, a gate
##                  at zero falls unfought, fallen cities drain the capital, the capital at
##                  zero loses the run, the Convergence rises, rifts open up to the tier's count
##   the party      dealt as the run starts, one hero to each domain from its bench, the front
##                  jobs and the back as even as the benches allow; a domain's final is fought
##                  against its hero with its wildlife and counts when the hero falls; the
##                  finale against the party promoted, a beaten hero's column held by a
##                  standing domain's boss

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
const SALVAGE_PER_MENACE := 2  # salvage a point of menace killed, in any fight however it ended (7 October: a kill is a kill; 30 October: weighted by danger, the reinforcements light, so the farm pays a trickle and the rift's bounty is where the salvage is); set so a battle banks about what it banked at ten a kill
const START_SALVAGE := 0      # salvage builds; a run starts with nothing to build with but its blueprints
const FAVOUR_PER_WIN := 100   # the Council's Favour for a won battle (7 October: the second currency, earned by results, spent on purchases and services)
const FAVOUR_DOCK := 1        # Favour docked per point of gate damage the city took in that battle; never below nothing
const START_FAVOUR := 100     # enough for one rush
const RUSH_PRICE := 100       # Favour to bring a wreck out of the shop now (6 October: a choice after a wreck, never routine repair)
const REPAIR_COST := 5        # salvage a point of the capital's gate costs (the one priced repair, section 3; materials, so salvage)
const START_MACHINES := 3     # a run starts with three machines and all SQUAD slots; the fourth is bought (7 October)
const CONVERGENCE_PER_TURN := 1   # a turn passed raises it too, so waiting never stops the clock
const TIER_EVERY := 4         # Convergence per tier
const FINALE_AT := 12         # the Convergence that makes the finale due (twelve battles, section 3); each fallen city brings it one sooner
const RIFTS_BASE := 2         # rifts open at tier 0; one more a tier
const GUEST_TIER := 1         # from this tier a rift carries a guest faction
const QUIET_TURNS := 1        # a city whose rift was closed opens no new one for this many turns
const SHOP_BATTLES := 1       # a wreck sits out this many battles
const FINAL_AFTER := 3        # bosses of one faction beaten before its next rift is its final, fought against the domain's dealt hero


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
## A map shape every battle of the run is fought on (BattleMap.KINDS), for the campaign runner's
## --shape; "" draws each battle's shape by its seed, as the game does. Never saved.
var map_kind := ""
var rng := RandomNumberGenerator.new()
var db: ContentDB
var state: int = PICK
var won: bool = false
var turn: int = 0                 # turns ended
var convergence: int = 0       # the campaign's clock toward the finale (named the Convergence, Ryan, 7 October)
var cities: Dictionary = {}       # city id -> City, the capital last
var roster: Array = []            # Machine
var components: Dictionary = {}   # component id -> count owned and not fitted
var salvage: int = 0             # materials, earned by fighting (kills, loot); spent on building and the capital's gate (module slots are a number of the chassis, never bought)
var favour: int = 0              # the Council's Favour, earned by results (a won battle, docked for gate damage); spent on procurement and rushes
var blueprints: Array = []        # component ids the run can build without limit: the tier-one blueprints at the start (7 October), more from loot, offers and research
var tokens: Array = []            # research tokens, by the faction whose boss dropped them (unpacked in the hangar, not built)
var offers: Array = []            # city ids whose maker owes an offer (the offer itself waits on the catalogues)
var bosses_beaten: Dictionary = {}   # faction id -> bosses beaten this run
var anathema: Dictionary = {}        # faction id -> the menace of its foes killed this run, every battle however it ended (the Rupture meter's weight; recorded beside the count of three bosses, which still decides the final)
var bosses_ended: Dictionary = {}    # faction id -> the bosses its battles ended on this run, by foe id, so the next draws another
var finals_won: Array = []        # factions beaten (their final won): they lead and guest no new rift
var party: Dictionary = {}        # faction id -> the hero dealt it at the run's start (its final; promoted, its column at the finale)
var battle: Battle = null
var battle_city: String = ""
var squad: Array = []             # roster uids fighting `battle`
var history: Array = []           # one report a battle (finish_battle's)
var sponsorship: Dictionary = {}   # measure -> the run's tally (the bible's Sponsorship row; never shown live): each battle's added at its end; sponsorship_by_maker reads it through the makers' content
var _next_uid: int = 1


## A new run. `team` is the starting roster's chassis ids, the player's pick from
## `tender`; without one the run takes START_MACHINES of its tender at random.
func _init(seed_arg: int = 1, team: Array = []) -> void:
	seed_value = seed_arg
	rng.seed = seed_arg
	db = ContentDB.load_default()
	for id in db.city_makers():
		_add_city(str(id), false)
	_add_city(db.capital_maker(), true)
	# The starting team is the player's pick from the tender; a run made without one (the
	# runner, a test) takes START_MACHINES of the tender's machines at random.
	var start: Array = team
	if start.is_empty():
		start = tender(db, seed_arg)
		var pick := RandomNumberGenerator.new()
		pick.seed = seed_arg * 4813 + 5   # the pick's own stream, so it never reads the offer's draws nor moves the run's
		_shuffle(start, pick)
		start = start.slice(0, START_MACHINES)
	for cid in start:
		add_machine(str(cid))
	salvage = START_SALVAGE
	favour = START_FAVOUR
	blueprints = db.starting_blueprints()
	party = deal_party(db, seed_arg)
	_open_rifts()


## The starting draft (Ryan, 7 October): a tender. Each city maker offers one of its
## tier-one chassis, drawn by the run's seed, in its stock loadout, and the player takes
## START_MACHINES of them. The Arsenal never offers; a maker with no tier-one chassis
## offers nothing, and a chassis the engine cannot field yet (its passive or a locked piece
## planned; ContentDB.chassis_runnable) is never dealt, so a maker whose only tier one is a
## draft offers nothing until it lands. The same seed always offers the same machines, drawn on
## a stream of its own, as the party's (the mechanics audit, 25 October: on the run's own
## stream the runner's pick of three reread Minerva's offer, so the Armadillo started every run
## it was offered, and the offer told where the first rifts would open).
static func tender(content: ContentDB, seed_arg: int) -> Array:
	var r := RandomNumberGenerator.new()
	r.seed = seed_arg * 6151 + 29
	var tier_one := content.chassis_of_tier(1)
	var out: Array = []
	for mk in content.city_makers():
		var pool: Array = []
		for id in tier_one:
			if str(content.chassis[id].get("maker", "")) == str(mk) and content.chassis_runnable(str(id)):
				pool.append(str(id))
		if not pool.is_empty():
			out.append(pool[r.randi_range(0, pool.size() - 1)])
	return out


## The party (the bible's section 9, decided 9 October): one hero to each domain from its
## bench, drawn by the run's seed on a stream of its own, so the rest of the run rolls as it
## would without it. The deal keeps the front jobs and the back as even as the benches allow
## (two and two over four domains): every deal of one hero a domain is weighed, and one of the
## evenest is drawn. A domain with an empty bench is dealt nobody. Faction id -> hero id.
static func deal_party(content: ContentDB, seed_arg: int) -> Dictionary:
	var r := RandomNumberGenerator.new()
	r.seed = seed_arg * 7919 + 17
	var domains: Array = []
	var benches: Array = []
	for fid in content.factions.keys():
		var bench := content.bench_of(str(fid))
		if not bench.is_empty():
			domains.append(str(fid))
			benches.append(bench)
	var deals: Array = [[]]
	for bench in benches:
		var grown: Array = []
		for d in deals:
			for h in bench:
				grown.append(d + [h])
		deals = grown
	var best: Array = []
	var best_gap := 1 << 30
	for d in deals:
		var back := 0
		for h in d:
			if str(content.foes[h].get("rank", "front")) == "back":
				back += 1
		var gap := absi(d.size() - 2 * back)
		if gap < best_gap:
			best = [d]
			best_gap = gap
		elif gap == best_gap:
			best.append(d)
	var out := {}
	if best.is_empty() or domains.is_empty():
		return out
	var pick: Array = best[r.randi_range(0, best.size() - 1)]
	for i in range(domains.size()):
		out[domains[i]] = str(pick[i])
	return out


func _shuffle(a: Array, r: RandomNumberGenerator) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := r.randi_range(0, i)
		var t = a[i]
		a[i] = a[j]
		a[j] = t


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
	return convergence / TIER_EVERY


func fallen_count() -> int:
	var n := 0
	for c in cities.values():
		if c.fallen and not c.capital:
			n += 1
	return n


func finale_due() -> bool:
	return convergence >= FINALE_AT - fallen_count()


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
	# The tier is the rift's, locked as it opened and shown on its card (Ryan's form, the curve
	# proposal; 30 October); the ramp is the live Convergence, the same for every open front.
	b.tier = int(c.rift.get("tier", tier())) if not c.capital else tier()
	b.ramp = convergence
	b.guest = str(c.rift.get("guest", ""))
	var lead := str(c.rift.get("faction", ""))
	if c.capital:
		# The finale (the bible's section 9): the dealt party, promoted, at the capital.
		b.lineup = finale_line()
	elif bool(c.rift.get("final", false)) and db.foes.has(str(party.get(lead, ""))):
		# A domain's final: its dealt hero commands the rift, in its rank, the domain's wildlife
		# in the other columns (the tier's own units, unnamed here), and the final counts when
		# the hero falls.
		b.lineup = [str(party[lead])]
		b.escort = ["", b.columns - 1]
	else:
		# A boss its domain has not ended on this run (the bible's section 9: three a domain
		# before its hero, drawn without repeats).
		var boss_id := draw_boss(lead)
		if not boss_id.is_empty():
			b.lineup = [boss_id]
	b.map_kind = map_kind
	b.blueprints_known = blueprints.duplicate()   # a cache's blueprint is one the run lacks
	b.setup(team, lead)
	b.field.gate_hp_max = c.gate_max
	b.field.gate_hp = c.gate
	battle = b
	battle_city = city_id
	squad = uids.duplicate()
	state = BATTLE
	return b


## Apply a finished battle to the run, end the turn, and report what happened:
## {"turn", "city", "faction", "guest", "result" ("won", "held" or "fell"), "wiped",
##  "gate_left", "salvage", "favour", "lost" (component ids gone for good), "wrecked" (uids), "phases"}.
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
			b.field.enemy_turn()
			b.field.phase += 1
	var report := {"turn": turn, "city": c.id, "faction": b.faction, "guest": b.guest, "wiped": wiped,
		"phases": b.field.phase, "lost": [], "wrecked": [], "salvage": 0,
		"final": bool(c.rift.get("final", false)) and not c.capital, "finale": c.capital, "closed": [], "finals": [],
		"menace": b.menace_killed, "kills": b.foes_killed, "fractures": b.fractures, "fractures_of": b.thresholds.size(),
		"rupture_turn": b.rupture_turn, "stall_guard": b.stall_guard, "elites": b.elites_spawned.size(),
		"peaks": b.field.peaks, "rift_spawns": b.field.rift_spawns, "tear_spawns": b.field.tear_spawns, "tears": b.field.tears.size()}
	anathema[b.faction] = int(anathema.get(b.faction, 0)) + b.menace_killed
	# The machines. (Salvage is the kills of every fight however it ended, tallied here at the
	# battle's end and never shown while it is fought, 7 October: one less number on the
	# screen, and no visible count to farm against.)
	var wrecked: Array = []
	for uid in squad:
		var m := machine(int(uid))
		var u := _fielded(b, int(uid))
		if m == null or u == null:
			continue
		var wreck := u.hull <= 0 or not b.field.units.has(u)
		if wreck:
			wrecked.append(m)
		report["lost"].append_array(_after_battle(m, u))
	for m in wrecked:
		report["wrecked"].append(m.uid)
	# The city.
	var faction := b.faction
	var gate_damage := maxi(0, c.gate - b.field.gate_hp)   # what the city's gate took in this battle
	c.gate = maxi(0, b.field.gate_hp)
	report["favour"] = 0
	if b.outcome == Battle.Outcome.VICTORY:
		report["result"] = "won"
		c.gate = c.gate_max
		var final := bool(c.rift.get("final", false))
		c.rift = {}
		c.quiet = QUIET_TURNS
		var banked := b.menace_killed * SALVAGE_PER_MENACE + _bank_loot(b, report)
		salvage += banked
		report["salvage"] = banked
		# The Council pays for results: its Favour for the win, docked for the gate damage the
		# city took (7 October); a battle not won pays nothing.
		var fee := maxi(0, FAVOUR_PER_WIN - gate_damage * FAVOUR_DOCK)
		favour += fee
		report["favour"] = fee
		tokens.append(faction)
		offers.append(c.id)
		bosses_beaten[faction] = int(bosses_beaten.get(faction, 0)) + 1
		if not final and not c.capital and b.lineup.size() == 1:
			var ended: Array = bosses_ended.get(faction, [])
			ended.append(str(b.lineup[0]))
			bosses_ended[faction] = ended
		# A final counts when its hero falls (the bible's section 9): its hero commands the rift,
		# so the battle is won when it does (the Thief's Flee, when it lands, is the exception).
		if final and not c.capital and not finals_won.has(faction):
			finals_won.append(faction)
			report["closed"] = _close_beaten(faction)
		elif int(bosses_beaten[faction]) >= FINAL_AFTER and not finals_won.has(faction):
			report["finals"] = _set_finals(faction)
	elif c.gate <= 0:
		report["result"] = "fell"
		_fall(c)
	else:
		report["result"] = "held"
		var banked := b.menace_killed * SALVAGE_PER_MENACE + _bank_loot(b, report)
		salvage += banked
		report["salvage"] = banked
	report["gate_left"] = c.gate
	for k in b.sponsorship.keys():
		sponsorship[k] = int(sponsorship.get(k, 0)) + int(b.sponsorship[k])
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


## The caches the battle's machines claimed (the bible's loot rows; built 7 November), banked as
## the kills are, on a battle won or held and never on a fall: each component one copy into the
## stores, each blueprint into the run's (a blueprint found twice is one), and their salvage,
## returned for the battle's total. The report keeps them under "loot".
func _bank_loot(b: Battle, report: Dictionary) -> int:
	var got := 0
	report["loot"] = b.loot.duplicate(true)
	for l in b.loot:
		got += int(l.get("salvage", 0))
		for cid in l.get("components", []):
			if db.components.has(str(cid)):
				components[str(cid)] = int(components.get(str(cid), 0)) + 1
		var bp := str(l.get("blueprint", ""))
		if db.components.has(bp) and not blueprints.has(bp):
			blueprints.append(bp)
	report["loot_salvage"] = got
	return got


## The boss a domain's next battle brings (the bible's section 9, decided 15 October; built 22
## October): one of its bosses its battles have not ended on this run, by the run's seed; once
## every one has been, any of them. A domain with one boss draws nothing from the seed, so a run
## plays as it did before the slate. Empty for a domain without one.
func draw_boss(faction_id: String) -> String:
	var all := db.bosses_of(faction_id)
	if all.size() <= 1:
		return all[0] if not all.is_empty() else ""
	var ended: Array = bosses_ended.get(faction_id, [])
	var open: Array = all.filter(func(id: String) -> bool: return not ended.has(id))
	if open.is_empty():
		open = all
	return str(open[rng.randi_range(0, open.size() - 1)])


## The finale's line (the bible's section 9): a column for each domain, in content order, the
## dealt hero's promoted form while its domain stands; a domain whose final was won leaves its
## column to boss-tier wildlife of a domain still standing, each standing domain's boss drawn
## in turn by the run's seed before any comes twice. The reserve behind the line (elites and
## bosses) waits on the elites and the bosses' slate.
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


## Each maker's Sponsorship measure as the run has tallied it (the bible's Sponsorship row):
## maker id -> the tally of the measure its content names; a maker that names none (the
## Arsenal, whose notice comes from the Convergence's top tier) is left out. The offer at the
## run's end, to the makers whose measure the player topped, waits on the catalogues.
func sponsorship_by_maker() -> Dictionary:
	var out := {}
	for id in db.makers.keys():
		var measure := str(db.makers[id].get("sponsorship", ""))
		if not measure.is_empty():
			out[id] = int(sponsorship.get(measure, 0))
	return out


## A battle's machine as the battle holds it: on the field, or among its wrecks.
func _fielded(b: Battle, uid: int) -> Unit:
	var u := b.field.unit_by_id(uid)
	if u != null and u.is_player():
		return u
	for w in b.wrecks:
		if w.id == uid:
			return w
	return null


## What a battle left a machine with (section 3, the hangar row): hull repairs free and a
## destroyed fixed component is rebuilt, since both are the chassis's; a destroyed hardpoint
## component is gone, a wreck's as any machine's. Returns the component ids lost.
func _after_battle(m: Machine, u: Unit) -> Array:
	if u.die == null:
		return []
	var r := after_battle_loadout(db, m.chassis, u)
	m.loadout = r[0]
	return r[1]


## The rule above for any machine's die (the quick campaign's too): [the hardpoint components
## it keeps, in die order; the ones gone for good].
static func after_battle_loadout(content: ContentDB, chassis_id: String, u: Unit) -> Array:
	var fixed_n: int = content.chassis.get(chassis_id, {}).get("fixed", []).size()
	var kept: Array = []
	var lost: Array = []
	for idx in range(fixed_n, u.die.faces.size()):
		var f: Face = u.die.faces[idx]
		if f.component.is_empty():
			continue   # an empty hardpoint: nothing was there
		var destroyed := f.kind == Face.Kind.BLANK and not f.empty and not f.disabled
		if destroyed:
			lost.append(f.component)
		else:
			kept.append(f.component)
	return [kept, lost]


## A beaten domain's other rifts close with its final (Ryan, 26 October: "if a domain gets
## beat, other rifts for that domain should close"): every standing city whose rift it leads is
## free of it, quiet for QUIET_TURNS as a won city is ("if that is too easy then we take it
## away"), its gate as it stood, since only a win restores one, and nothing paid, a reprieve
## and no battle. A rift it only guests keeps it, and a fallen city's rift is no front, so it
## stays as it is. Returns the cities freed.
func _close_beaten(faction: String) -> Array:
	var closed: Array = []
	for c in cities.values():
		if c.capital or c.fallen or c.rift.is_empty() or str(c.rift.get("faction", "")) != faction:
			continue
		c.rift = {}
		c.quiet = QUIET_TURNS
		closed.append(c.id)
	return closed


## A domain's final is set by its third boss beaten (FINAL_AFTER; Ryan, 26 October: "If the
## final is set, then all open rifts should change to show the final as the boss in the mission
## select"): every standing city's rift it leads turns final at once, its dealt hero the boss
## shown, so no rift opened before then brings a plain boss after; the ones it opens later are
## dealt final (_roll_rift). The capital's rift is the finale, and a fallen city's is no front.
## Returns the cities turned.
func _set_finals(faction: String) -> Array:
	var turned: Array = []
	for c in cities.values():
		if c.capital or c.fallen or c.rift.is_empty() or str(c.rift.get("faction", "")) != faction or bool(c.rift.get("final", false)):
			continue
		c.rift["final"] = true
		turned.append(c.id)
	return turned


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
	convergence += CONVERGENCE_PER_TURN
	_open_rifts()
	for c in cities.values():
		c.quiet = maxi(0, c.quiet - 1)


## Open rifts up to the tier's count at standing, quiet-free cities; once the finale is
## due, one at the capital.
func _open_rifts() -> void:
	var cap := capital()
	if finale_due() and cap != null and cap.rift.is_empty():
		cap.rift = _roll_rift()
		cap.rift["final"] = false   # the capital's is the finale, never a domain's final
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
## lead is any faction not yet beaten; a guest, from GUEST_TIER, any other faction not beaten
## (Ryan, 26 October: a beaten domain "should stop being a guest in new rifts").
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
			if str(f) != lead and not finals_won.has(f):
				others.append(f)
		if not others.is_empty():
			guest = str(others[rng.randi_range(0, others.size() - 1)])
	var final := int(bosses_beaten.get(lead, 0)) >= FINAL_AFTER and not finals_won.has(lead)
	return {"faction": lead, "guest": guest, "final": final, "tier": tier()}


# ---------------------------------------------------------------- the hangar

## Bring a wreck out of the shop now, for RUSH_PRICE Favour (each wreck its own cost).
func rush(uid: int) -> bool:
	var m := machine(uid)
	if state != PICK or m == null or m.shop == 0 or favour < RUSH_PRICE:
		return false
	favour -= RUSH_PRICE
	m.shop = 0
	return true


## Spend up to `spend` salvage on the capital's gate, REPAIR_COST a point, never past full.
## Returns the salvage spent.
func repair_capital(spend: int) -> int:
	var cap := capital()
	if state != PICK or cap == null:
		return 0
	var points := mini(maxi(0, mini(spend, salvage)) / REPAIR_COST, cap.gate_max - cap.gate)
	var cost := points * REPAIR_COST
	salvage -= cost
	cap.gate += points
	return cost


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
