class_name Battlefield
extends RefCounted

## Battlefield state and the turn's rules (bible section 4, the round row; section 5, the
## fights-by-ring row). Pure: no scenes, no signals, no rendering.
##
## A turn:
##   1. plan_walks()        where every pack will walk on the enemy's turn, against the field as
##                          it stands: a pusher toward the gate, a hunter toward its prey, through
##                          every other unit (terrain alone blocks a walk since 10 November) and
##                          never ending on one
##   2. the player's turn   (Battle) first every fight a hunter forced (forced_fights: its prey
##                          beside it, at the engage range), then
##                          fights the player picks (attack_roster): one pack is one fight (the
##                          long wall brief 3.4), nothing joins it, and the machines committed are
##                          those whose attack range covers it
##   3. enemy_turn()        the packs walk what plan_walks says; a pack on the gate's apron
##                          strikes it
##
## Units may cover several hexes (Unit.footprint). Every footprint hex counts as occupied. The
## gate and the rift are structures wider than one hex; nobody stands on them.

## A pack's walk on the enemy's turn.
class Walk:
	var path: Array[Vector2i] = []   # the hexes it walks, after its own
	var route: Array[Vector2i] = []  # its whole way to its goal as the field stands, after its own hex: the path, then the turns after it (a pusher's to its wall segment, a hunter's to where its prey stands inside its ring); empty when it goes nowhere
	var end: Vector2i                # where it stops
	var strikes := false             # it stops on the gate's apron and strikes the gate
	var waits := false               # no way to its goal: it stays where it is
	var catches: int = 0             # a hunter whose walk ends with what it comes for inside its ring: that machine's id
	var prey: int = 0                # what a hunter comes for this turn, by id: its prey (catch_of)

## What the map knows of each foe type (ContentDB.pack_profiles): its move, its wings, its
## shown name. Battle fills it from content, and a pack is dressed from it when it is made or
## spawns, so the defaults are the content's and never an id's. Whether a pack hunts is its
## composition's (pack_of), and a hunter catches at the engage range alone (Unit.ENGAGE_RANGE).
var foe_profiles: Dictionary = {}

var map: BattleMap
var units: Array[Unit] = []
var gate_hp: int = 200
var gate_hp_max: int = 200
var rift_pressure: int = 0
var rift_pressure_max: int = 12   # the timer: the ramp's (Ramp.timer_at), set by the battle
var spawn_faction: String = ""    # the faction a composition that names none belongs to
## The ramp the battle reads its counts and speed from (Ramp): the campaign's live Convergence.
var ramp: int = 0
## The battle's seed (Battle.setup sets it; the save restores it from the battle's): the caches'
## seeding reads it.
var seed_value: int = 0
## The tide's packs, a rating (1 to 3) to the compositions of it the domain has, in the order
## dealt: each {"id", "size", "faction", "members": [[foe_id, strength], ...], "layout": its eight
## cells}, the lead's and the guest's in turn (Battle.setup lays them from content, the save keeps
## them). With them the hunting compositions that come out of the rift, and where each list stands.
var graded: Dictionary = {}
var hunters: Array = []
var _graded_at: Dictionary = {}
var _hunter_index: int = 0
## The row the next tears open on (the pacing session, 30 October): tear_row_start() at the start,
## a row nearer the wall a peak (Ramp.tear_creep_at), as far as tear_row_stop(), so each peak's
## tears open a little nearer the wall and never beside it. It was the seam's row until 23 November, the painting's edge drawn on it;
## the seam is a picture alone since (Ryan: "The seam is visual only. Tears are still spawned by
## the same logic they are now"; Bleed.seam_radius), and this row is the tears' own, drawn nowhere.
var tear_row: int = 0   # tear_row_start(), set as the field takes its map


## Where the tears' row stands at a battle's start (the long wall brief 3.2): a share of the depth,
## a row for every five of it rounded up (two at least, four at most) and one more: row 4 at twelve
## deep, 5 at sixteen. A placeholder.
func tear_row_start() -> int:
	return clampi(ceili(float(map.height) / 5.0), 2, 4) + 1


## Where the tears' row stops: TEAR_STOP_ROWS short of the row before the wall, never short of its
## start (Ryan, 23 November: "not putting tears so close to the wall, at least so quickly", and
## "Tears need to spread wide, the crawl forward isn't as important as distributing enemy
## forces"). It ran to the row before the wall itself, reached by the third peak at twelve deep,
## where a tear's pack struck almost as it landed. A placeholder.
const TEAR_STOP_ROWS := 4

func tear_row_stop() -> int:
	return maxi(tear_row_start(), apron_row() - TEAR_STOP_ROWS)


## The tears (Ryan's name, 30 October): the mouths beside the rift's, each {"pos": Vector2i,
## "opened": the phase it opened at}. A tear opens at a peak on the tears' row, far from the
## other mouths, and sends a patrol at every peak after, so where the next flood comes from is
## known an interval ahead. Tears stay open.
var tears: Array = []
## The hunters that turned on a machine since the screen last asked ([hunter id, prey id], in
## order; pick_prey): the battle hands them over (Battle.take_locks) for the declaration on
## screen (Ryan, 8 November: "Declare when a hunter selects a target").
var locks: Array = []
## The caches lying on the field (the bible's loot rows; Ryan, 7 November: "have all the loot on
## the field round 1"; 8 November: "farther away it is means more likely to spawn a higher tier
## cache, and don't build any seam interaction yet"): each {"id", "tier": its kind's, "pos":
## Vector2i}, seeded with the map (seed_caches) short of the wall, its kind likelier the better the
## farther from the wall it lies, claimed by a machine standing on it as the player's turn ends or
## as the battle is won (Battle). The seam does nothing to a cache.
var caches: Array = []
var peaks: int = 0        # Rift Pressure's peaks so far this battle
var rift_spawns: int = 0  # packs the rift has sent (the runner reads both)
var tear_spawns: int = 0
const TIMER_FLOOR := 1    # the interval never shortens below this (the long wall brief 3.2)
const NO_HEX := Vector2i(-9999, -9999)
var phase: int = 0
var log: Array[String] = []
var _next_id: int = 1
## The machines a carrier's move lifts while its route is searched (the Swallowtail's carry,
## Ryan, 21 October: lifted in place, they travel as a ring round it), so their hexes never
## block it. Battle sets it for the search and clears it after; empty otherwise.
var lifted: Array[Unit] = []
## The machines wrecked this battle, each on the hexes it fell on (Ryan, 4 November: a wreck
## stays on its hex and blocks it for the battle; 16 November: "A wreck should behave like any
## other unit, meaning nobody can land on it"). Every walk passes it as it passes a unit
## (`passes`) and none ends on it (can_stand, _landable), and no tear opens on it; it is off
## `units`, so no pack hunts it, no fight takes it and nothing counts it as a machine. The
## campaign reads its die from here (Campaign._fielded).
var wrecks: Array[Unit] = []
## The rift's shell while the seal stands (BattleMap.shell_hexes; Ryan, 16 November: "the 7 hexes
## next to the rift are inaccessible to player units"): hex -> true. No machine enters or stands on
## one, a flyer as much as any (_ground_fits); the packs pass and land there as ever, the rift's
## own coming out through them. The battle lays it as it opens with the seal and lifts it at the
## Rupture (Battle.rupture); empty with no seal.
var shell: Dictionary = {}


func _init(battle_map: BattleMap) -> void:
	map = battle_map
	tear_row = tear_row_start()


func add_unit(u: Unit) -> Unit:
	if u.id == 0:
		u.id = _next_id
	_next_id = maxi(_next_id, u.id + 1)
	if u.is_enemy() and u.full_strength <= 0:
		u.full_strength = heads(u)   # what it took the field with: its strike is scaled against it as it wears (strike_of)
	units.append(u)
	return u


## The gate's bar a pip of threat rating strikes for, each enemy turn a pack stands at the wall: a
## placeholder (a patrol of three struck ten and a formation of eight twenty-six by the head
## count this replaces).
const STRIKE_PER_PIP := 5   # placeholder: ten until 25 November, five the number the graded tide was played at (Ryan's pick of the played set as the game's own, that day)
## A trial strike a pip, 0 for the game's (Ryan, 11 November, of more spawns: "even if it means
## that each needs to do less to the wall"): a debug build's SETTINGS → TRIALS → STRIKE and
## RIFTGATE_STRIKE set it (Settings.field_trial).
static var strike_trial: int = 0


static func strike_per_pip() -> int:
	return strike_trial if strike_trial > 0 else STRIKE_PER_PIP


## The heads a pack holds: its foes, and a boss unit's commanders with its escort.
static func heads(sq: Unit) -> int:
	return maxi(0, sq.strength) + ((maxi(1, sq.lineup.size())) if sq.is_boss else 0)


## A pack's strike at the gate's bar (Ryan, 10 November: "Strike following the threat rating makes
## a lot of sense, otherwise a single giant dude that composes a threat 3 on his own could be
## ignored. It also makes elites make more sense too"): its threat rating's worth, STRIKE_PER_PIP
## a pip, so the pips say how many machines it wants and how hard it hits the wall. A pack a
## fight has worn strikes by the share still standing, the heads it holds over the heads it took
## the field with (his word on the survivors, the same day), one at least; a pack that has grown
## past that count strikes for its rating and no more. It replaces the head count of 30 October
## (a third of ten a foe), written when a count was the threat.
static func strike_of(sq: Unit) -> int:
	var now := heads(sq)
	var full := maxi(now, sq.full_strength)
	if full <= 0:
		return 1
	return maxi(1, (clampi(sq.squad, 1, 4) * strike_per_pip() * now) / full)


## The packs every mouth sends at a peak, the rift and each open tear alike, 1 the game's (Ryan,
## 24 November: "I think enabling multiple spawns at the rift and at tears is plenty ... If we
## enable multiple simultaneous spawns from all spawn points, it gives us a very useful tuning
## dial for convergences. More so then the beat, I think"): each of a mouth's packs makes for a
## stretch of wall of its own (assign_goal), and the Rupture's size counts them (Battle.setup).
## SENDS_A_PEAK is the game's, two, the number the graded tide was played at (Ryan's pick of the
## played set as the game's own, 25 November), a placeholder until the ramp's table holds it by
## the Convergence. A dial beside it, 0 for the game's: SETTINGS → TRIALS → SENDS and
## RIFTGATE_SENDS.
const SENDS_A_PEAK := 2
static var sends_trial: int = 0


static func sends_a_peak() -> int:
	return sends_trial if sends_trial > 0 else SENDS_A_PEAK
## The graded tide, the game's (Ryan, 23 November: "Packs vary in strength, threat 1-3, 4 for elites
## ... Spawns reduce in strength the further to the sides of the map they target. So the far edges
## are 1s with a sprinkling of 2s, then 2s in between, and 3s coming right down the center. Move
## speed for pushers probably should reflect that, with 1s fastest and 3s slowest"; locked 25
## November, "our direction here is locked", and switched over the same day on his "Go ahead with
## the switch-over"). The wall is five bands (BAND_RATING); a mouth's packs each draw a band, the
## rift from all five and a tear from its own and the ones beside it, and the band says the
## rating: a pack for one at the ends, one in END_TWO_IN of them for two, a pack for two between,
## a pack for three down the middle. The pack is the next of its rating the domain has (`graded`,
## laid by Battle.setup from content: ContentDB.graded_packs), it walks at its composition's pace,
## and it comes down onto its own stretch from above (_higher), so none runs along the wall. A
## hunting pack comes out of the rift every other peak from the second (`hunters`). Its numbers
## are placeholders, his to set (docs/briefs/graded_tide.md). The form it retires: a cycle of the
## tier's formations and patrols in turn from the rift and of its patrols from the tears, each to
## the wall it reached soonest, which gave no reason to leave the middle (his play of it).
const BAND_RATING := [1, 2, 3, 2, 1]   # the wall's bands from one end to the other, each the rating that makes for it
const END_TWO_IN := 5                  # one in so many of an end's packs is a pack for two (the session's lean: rare)


## Give a pack its foe types' map profile: its move and its wings. `foe` names the entry when
## the unit's own foe_id does not (the boss, which unpacks by its faction). No foe says whether
## its pack hunts (its composition does, pack_of) or how far it reaches: a hunter catches at the
## engage range everyone shares (Unit.ENGAGE_RANGE; Ryan, 8 November, the rings purged after a
## goblin warband caught from three hexes through the Mandragoras' old back-rank ring; 10
## November, the pounce retired with the body blocking).
func dress_pack(sq: Unit, foe: String = "") -> Unit:
	var p: Dictionary = foe_profiles.get(foe if not foe.is_empty() else sq.foe_id, {})
	if p.has("movespeed"):
		sq.movespeed = int(p["movespeed"])   # the boss's too, which it never walks (it holds its hex)
	if not sq.is_boss:
		# A winged foe's pack crosses water and crags as a flyer does and stands there (Ryan,
		# 28 October, the movement proposal's lever 2); the boss is never winged.
		var winged := bool(p.get("winged", false))
		# A composition (the foes' fresh start, 30 October): it walks by its lead, at its slowest
		# member's pace, and is winged only when every member is, since a walker among them
		# cannot cross water.
		for m in sq.members:
			var mp: Dictionary = foe_profiles.get(str(m[0]), {})
			if mp.has("movespeed"):
				sq.movespeed = mini(sq.movespeed, int(mp["movespeed"]))
			winged = winged and bool(mp.get("winged", false))
		if winged and not sq.traits.has("winged"):
			sq.traits.append("winged")
	return sq


func unit_at(h: Vector2i) -> Unit:
	for u in units:
		if u.occupies(h):
			return u
	return null


## The wreck lying on a hex, or null (`wrecks`).
func wreck_at(h: Vector2i) -> Unit:
	for u in wrecks:
		if u.occupies(h):
			return u
	return null


func unit_by_id(uid: int) -> Unit:
	for u in units:
		if u.id == uid:
			return u
	return null


func mechs() -> Array[Unit]:
	var out: Array[Unit] = []
	for u in units:
		if u.is_player() and not u.is_static():
			out.append(u)
	return out


func packs() -> Array[Unit]:
	var out: Array[Unit] = []
	for u in units:
		if u.is_enemy():
			out.append(u)
	return out


func defenses() -> Array[Unit]:
	var out: Array[Unit] = []
	for u in units:
		if u.is_static():
			out.append(u)
	return out


func is_free(h: Vector2i) -> bool:
	return map.has(h) and not map.is_structure(h) and unit_at(h) == null and wreck_at(h) == null


## Whether `mover` may pass the hex `occ` stands on, never stopping there: always, since 10
## November (Ryan, after his play of the long wall: "the body blocking just adds a layer of
## complexity and pathing issues we just don't need anymore. The challenge now is in covering
## the whole map from multitudes"; the units "slide under each other, as theoretically they're
## from two different dimensional counts"). Terrain alone blocks a walk; nobody ends on another
## unit's hex (can_stand, _landable). Until then a grounded machine and a grounded pack were each
## other's walls, and two grounded machines each other's (29 October).
static func passes(_mover: Unit, _occ: Unit) -> bool:
	return true


## Whether `u` could stand with its anchor at `at`: every footprint hex in the map, passable,
## not a structure, and not held by another unit or a wreck. Nobody stops on another unit's hex.
func can_stand(u: Unit, at: Vector2i) -> bool:
	if not _ground_fits(u, at):
		return false
	for o in u.footprint:
		var occ := unit_at(at + o)
		if occ != null and occ != u and not lifted.has(occ):
			return false
		if wreck_at(at + o) != null:
			return false
	return true


## Whether `u` could pass through with its anchor at `at` on its way somewhere: the ground as
## for standing, and every unit there one it passes (`passes`).
func can_pass(u: Unit, at: Vector2i) -> bool:
	if not _ground_fits(u, at):
		return false
	for o in u.footprint:
		var occ := unit_at(at + o)
		if occ != null and occ != u and not lifted.has(occ) and not passes(u, occ):
			return false
	return true


## Every footprint hex on the field, no structure, ground `u` can enter, and for a machine none
## of the rift's shell while it stands.
func _ground_fits(u: Unit, at: Vector2i) -> bool:
	for o in u.footprint:
		var h: Vector2i = at + o
		if not map.has(h) or map.is_structure(h):
			return false
		if not BattleMap.passable(map.terrain[h], u.traits):
			return false
		if u.is_player() and shell.has(h):
			return false
	return true


## Lay the rift's shell (`up`) or lift it.
func set_shell(up: bool) -> void:
	shell = {}
	if up:
		for h in map.shell_hexes():
			shell[h] = true


## Nearest hex where a unit with `traits` could stand, by breadth-first ring search.
func nearest_free(h: Vector2i, traits: Array) -> Vector2i:
	var probe := Unit.new()
	for t in traits:
		probe.traits.append(str(t))
	return nearest_standable(probe, h)


func nearest_standable(u: Unit, h: Vector2i) -> Vector2i:
	var seen := {h: true}
	var queue: Array[Vector2i] = [h]
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		if can_stand(u, cur):
			return cur
		for n in Hex.neighbors(cur):
			if map.has(n) and not seen.has(n):
				seen[n] = true
				queue.append(n)
	return h


## Every anchor hex a unit can end its move on, mapped to the cost of getting there: from
## its hex with its whole move, or with `budget` when given (a machine that has moved part of
## its move this action has the rest). A hex it only passes (another unit's) is no end.
func reachable(u: Unit, budget: int = -1) -> Dictionary:
	var dist: Dictionary = _search(u, u.pos, u.movespeed if budget < 0 else budget)[0]
	dist.erase(u.pos)
	for h in dist.keys():
		if not can_stand(u, h):
			dist.erase(h)
	return dist


## Cheapest route for `u` to `to` within its move (or `budget`), as the hexes after its
## position. Empty when `to` is out of reach.
func route_to(u: Unit, to: Vector2i, budget: int = -1) -> Array[Vector2i]:
	return route_from(u, u.pos, u.movespeed if budget < 0 else budget, to)


## The cheapest continuation for `u` from `from` to `to` inside `budget` of move, as
## the hexes after `from`; empty when `to` is out of reach or no place to stop. A route drawn
## by hand grows by these, so a finger that skips a hex still leaves a walkable route, and one
## over a unit it passes waits there until the finger moves on.
func route_from(u: Unit, from: Vector2i, budget: int, to: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if to == from or not can_stand(u, to):
		return out
	var prev: Dictionary = _search(u, from, budget)[1]
	if not prev.has(to):
		return out
	var c := to
	while c != from:
		out.push_front(c)
		c = prev[c]
	return out


## What a route costs `u` of its move, or -1 when it is not one it can walk: every step
## adjacent to the last and one it may pass, its last one it may stop on, each paid for out of
## what is left of its move (or of `budget`); a wade entered with less than its price left
## takes the rest, so nothing follows it.
func route_cost(u: Unit, route: Array, budget: int = -1) -> int:
	var cost := 0
	var cur := u.pos
	var move := u.movespeed if budget < 0 else budget
	for i in range(route.size()):
		var s: Vector2i = route[i]
		if not Hex.are_adjacent(cur, s) or not can_pass(u, s):
			return -1
		if i == route.size() - 1 and not can_stand(u, s):
			return -1
		var c := BattleMap.spend(map.terrain[s], u.traits, move - cost)
		if c < 0:
			return -1
		cost += c
		cur = s
	return cost


## Dijkstra from `from`, bounded by `budget` of move, through every hex `u` may pass (an
## airborne unit's, or a grounded one's when `u` flies: `passes`). Returns [dist, prev]; a
## passed hex is in them, and `reachable` keeps the ends. `blocked` hexes are not entered. A
## water hex a ground machine wades costs two, and with one left it is still entered for the
## one (BattleMap.spend), so it is reached at the budget and nothing is reached through it.
func _search(u: Unit, from: Vector2i, budget: int, blocked: Dictionary = {}) -> Array:
	var dist := {from: 0}
	var prev := {}
	var frontier: Array = [[0, from]]
	while not frontier.is_empty():
		var best := 0
		for i in range(1, frontier.size()):
			if frontier[i][0] < frontier[best][0]:
				best = i
		var cur: Array = frontier.pop_at(best)
		var d: int = cur[0]
		var h: Vector2i = cur[1]
		if d > dist[h]:
			continue
		for n in Hex.neighbors(h):
			if not map.has(n) or blocked.has(n) or not can_pass(u, n):
				continue
			var c := BattleMap.spend(map.terrain[n], u.traits, budget - d)
			if c < 0:
				continue
			var nd := d + c
			if not dist.has(n) or nd < dist[n]:
				dist[n] = nd
				prev[n] = h
				frontier.append([nd, n])
	return [dist, prev]


## A hunter's prey, picked by its caveat the first time it needs one and kept until the
## machine is gone (single-minded, so the lock the player sees holds). A machine whose passive
## says never_hunted (the Prairie Dog, bible section 7) is never picked. Null when there is
## nothing to hunt.
func pick_prey(sq: Unit) -> Unit:
	var current := unit_by_id(sq.prey)
	if current != null and current.is_player() and not current.is_static():
		return current
	var best := would_hunt(sq)
	# One hunter a machine (Ryan, 8 November): with every machine hunted already it pushes for the
	# wall instead, and turns on a machine once one is free, which the log says.
	var was := sq.prey
	sq.prey = best.id if best != null else 0
	if best != null and sq.prey != was:
		log.append("%s turns on %s" % [sq.display_name, best.display_name])
		locks.append([sq.id, best.id])
	return best


## The machine a hunter with no prey would turn on from where it stands, by its caveat, locking
## nothing (pick_prey locks; the rift reads this to land a hunting pack on its prey's side). Null
## with nothing to hunt.
func would_hunt(sq: Unit) -> Unit:
	var best: Unit = null
	var best_key := 0
	for m in mechs():
		if Effects.never_hunted(m) or hunted_by_other(m, sq):
			continue
		var key := _prey_key(sq, m)
		if best == null or key < best_key:
			best = m
			best_key = key
	return best


## Whether another hunter on the field already hunts this machine.
func hunted_by_other(m: Unit, sq: Unit) -> bool:
	for other in packs():
		if other != sq and other.behaviour == "hunt" and other.prey == m.id:
			return true
	return false


## How a hunter's caveat ranks a machine as prey: the lowest key is picked.
func _prey_key(sq: Unit, m: Unit) -> int:
	return _taste(sq, m, sq.pos)


## A hunter's caveat as a key, read from `at` where it is the nearest that counts.
func _taste(sq: Unit, m: Unit, at: Vector2i) -> int:
	match sq.hunts:
		"weakest":
			return m.hull + m.shield
		"strongest":
			return -(m.hull + m.shield)
		"slowest":
			return m.movespeed
	return _distance_from(sq, at, m)


## Who a hunter standing where it stands has caught (bible section 4, the fights-picked row):
## its prey, when it stands within the engage range (in_ring). Null when it has caught nobody.
## Until 10 November a prey sealed off by walls and machines cost the machine nearest it (the
## stand-in, Ryan, 29 October: "It's just punishing hiding"); with every unit passing every
## other nothing seals a prey off but the hexes beside it being taken, which is a screen the
## player paid for with those machines' places, so the hunter closes on its prey and waits.
func catch_of(sq: Unit) -> Unit:
	var prey := pick_prey(sq)
	if prey == null:
		return null
	return prey if in_ring(sq, prey) else null


## Every pack's walk for the enemy's turn, against the field as it stands now (bible section
## 4, the round row). Packs plan in field order, each walking through the others but never
## stopping where the packs before it will end or where the ones after it stand now, so the
## walk plays as shown. The preview is this call: nothing a pack does reacts to the plan, it
## reads where the machines stand.
func plan_walks() -> Dictionary:
	var out: Dictionary = {}
	var ends: Dictionary = {}   # pack id -> the hexes it will hold, for the packs after it
	for sq in packs():
		var w := _walk(sq, _held_by_others(sq, ends))
		out[sq.id] = w
		var held: Array = []
		for o in sq.footprint:
			held.append(w.end + o)
		ends[sq.id] = held
	return out


## The hexes every other pack holds: where the ones planned before it will end, where the
## rest stand now.
func _held_by_others(sq: Unit, ends: Dictionary) -> Dictionary:
	var blocked := {}
	for other in packs():
		if other == sq:
			continue
		var held: Array = ends[other.id] if ends.has(other.id) else other.hexes()
		for h in held:
			blocked[h] = true
	return blocked


## Whether a pack may walk with its anchor at `at`: every footprint hex in the map, ground the
## horde can cross, no structure, and no unit it does not pass (`passes`: every unit, since 10
## November). `blocked` is for stopping (`_landable`).
func _walkable(sq: Unit, at: Vector2i, _blocked: Dictionary) -> bool:
	for o in sq.footprint:
		var h: Vector2i = at + o
		if not map.has(h) or map.is_structure(h):
			return false
		if not BattleMap.passable(map.terrain[h], sq.traits):
			return false
		var occ := unit_at(h)
		if occ != null and occ != sq and occ.is_player() and not passes(sq, occ):
			return false
	return true


## Whether a pack may stop with its anchor at `at`: walkable, no machine or wreck there at all,
## and no other pack's hold (`blocked`: where the packs planned before it end, where the rest
## stand).
func _landable(sq: Unit, at: Vector2i, blocked: Dictionary) -> bool:
	for o in sq.footprint:
		var h: Vector2i = at + o
		if blocked.has(h):
			return false
		var occ := unit_at(h)
		if occ != null and occ != sq and occ.is_player():
			return false
		if wreck_at(h) != null:
			return false
	return true


## Whether a pack with its anchor at `at` stands on the apron: beside a gate hex, or beside
## any hex of the wall (Ryan, 30 October: the whole wall is a target, so a pack strikes the
## gate's bar from anywhere along the bottom rows and the apron cannot be plugged).
func on_apron(sq: Unit, at: Vector2i) -> bool:
	var apron := apron_hexes()
	for o in sq.footprint:
		if apron.has(at + o):
			return true
	return false


var _apron: Dictionary = {}

## Every hex a pack strikes from: the ones beside a gate hex or a wall hex, read once.
func apron_hexes() -> Dictionary:
	if _apron.is_empty():
		for s in map.gate_hexes + map.wall_hexes:
			for n in Hex.neighbors(s):
				if map.has(n) and not map.is_structure(n):
					_apron[n] = true
	return _apron


## The row before the wall, the last a pack walks to.
func apron_row() -> int:
	return map.height - BattleMap.GATE_ROWS - 1


## Whether a hunter anchored at `at` holds `u` inside its ring: the catch's own reach, the engage range.
func catches_at(sq: Unit, at: Vector2i, u: Unit) -> bool:
	return u != null and _distance_from(sq, at, u) <= Unit.ENGAGE_RANGE


## The shortest distance from a pack anchored at `at` to a unit.
func _distance_from(sq: Unit, at: Vector2i, u: Unit) -> int:
	var best := 1 << 30
	for o in sq.footprint:
		for h in u.hexes():
			best = mini(best, Hex.distance(at + o, h))
	return best


## One pack's walk. The boss holds its hex in front of the rift and never walks (Battle.boss_home;
## its patrol of 22 September, a hex a turn within two of the rift, went on 10 November: Ryan, "I
## feel like the boss no longer should patrol"). A hunter heads for the nearest hex it
## can reach that puts its prey within the engage range, or as near as it gets. A pusher heads
## for its wall segment on the gate's apron row. It walks as far as its move goes, through every
## other unit (10 November), never ending on another unit's hex. A pusher with no way to the gate
## waits, and the map says so.
func _walk(sq: Unit, blocked: Dictionary) -> Walk:
	var w := Walk.new()
	w.end = sq.pos
	if sq.is_boss:
		return w
	var prey: Unit = pick_prey(sq) if sq.behaviour == "hunt" else null
	var found := _walk_search(sq, blocked)
	var dist: Dictionary = found[0]
	var prev: Dictionary = found[1]
	var goal := sq.pos
	if prey != null:
		w.prey = prey.id
		var best_key := Vector2i(maxi(_distance_from(sq, sq.pos, prey) - Unit.ENGAGE_RANGE, 0), 0)
		for h in dist.keys():
			var hx: Vector2i = h
			if not _landable(sq, hx, blocked):
				continue
			var key := Vector2i(maxi(_distance_from(sq, hx, prey) - Unit.ENGAGE_RANGE, 0), int(dist[hx]))
			if key.x < best_key.x or (key.x == best_key.x and key.y < best_key.y):
				best_key = key
				goal = hx
	elif not on_apron(sq, sq.pos) and sq.goal_col >= 0:
		# A pusher walks to its wall segment (the long wall brief 3.3): the apron hex in its goal
		# column when it is land and reachable, else the reachable land apron hex nearest that
		# column, ties toward the gate's column, then the nearer walk.
		var gate_col := Hex.axial_to_offset(map.gate).x
		var best := Vector3i(1 << 30, 0, 0)
		for h in dist.keys():
			var hx: Vector2i = h
			if not on_apron(sq, hx) or not _landable(sq, hx, blocked) or not _land(hx):
				continue
			var col := Hex.axial_to_offset(hx).x
			var key := Vector3i(absi(col - sq.goal_col), absi(col - gate_col), int(dist[hx]))
			if key.x < best.x or (key.x == best.x and (key.y < best.y or (key.y == best.y and key.z < best.z))):
				best = key
				goal = hx
		if best.x == 1 << 30:
			w.waits = true
	elif not on_apron(sq, sq.pos):
		# No segment (a pack made by hand, a hunter left without prey): the nearest apron hex.
		var best := 1 << 30
		for h in dist.keys():
			var hx: Vector2i = h
			if on_apron(sq, hx) and _landable(sq, hx, blocked) and int(dist[hx]) < best:
				best = int(dist[hx])
				goal = hx
		if best == 1 << 30:
			w.waits = true
	var route: Array[Vector2i] = []
	var c := goal
	var high := prey == null   # a pusher comes down onto its own stretch (_higher)
	while c != sq.pos:
		route.push_front(c)
		c = _higher(c, dist, prev) if high else prev[c]
	var budget := sq.movespeed
	var walked: Array[Vector2i] = []
	for s in route:
		var cost := BattleMap.spend(map.terrain[s], sq.traits, budget)
		if cost < 0:
			break
		budget -= cost
		walked.append(s)
	while not walked.is_empty() and not _landable(sq, walked[walked.size() - 1], blocked):
		walked.pop_back()
	w.path = walked
	w.route = route   # the whole way, of which the path is the first turn's
	w.end = walked[walked.size() - 1] if not walked.is_empty() else sq.pos
	w.strikes = prey == null and on_apron(sq, w.end)
	if prey != null and _distance_from(sq, w.end, prey) <= Unit.ENGAGE_RANGE:
		w.catches = prey.id
	return w


## The hex a shortest way reaches `c` from, the one nearest the rift of those that serve: read
## back from the wall, so a pack bound for a far stretch crosses the field high and comes down
## onto its own stretch, never along the wall past stretches it could strike (Ryan, 23 November,
## of the walk it would otherwise be: "they're skipping sections they could hit this turn to go
## hit something two turns away"). Every neighbour as far from the pack as the search's own
## choice is as short a way.
func _higher(c: Vector2i, dist: Dictionary, prev: Dictionary) -> Vector2i:
	var best: Vector2i = prev[c]
	var want := int(dist[best])
	var best_row := Hex.axial_to_offset(best).y
	for n in Hex.neighbors(c):
		if dist.has(n) and int(dist[n]) == want and Hex.axial_to_offset(n).y < best_row:
			best = n
			best_row = Hex.axial_to_offset(n).y
	return best


## Where each later turn of a walk's whole way ends (Walk.route past its path), as indices into
## the route: a pack walks its move a turn, a water hex costing two and entered with whatever is
## left, as the turn's own walk does (_walk), from the first turn's end. The map numbers them on a
## tapped pack's way (Ryan, 9 November: "Pushers should show their current complete path to their
## targeted wall segment when tapped"). Read as the field stands, so a stop is where it would be
## if nothing moved; it reads no landing, since who stands where then is unknown.
func turn_ends(sq: Unit, w: Walk) -> Array[int]:
	var out: Array[int] = []
	var at := w.path.size()
	while at < w.route.size():
		var budget := sq.movespeed
		var moved := false
		while at < w.route.size():
			var cost := BattleMap.spend(map.terrain[w.route[at]], sq.traits, budget)
			if cost < 0:
				break
			budget -= cost
			at += 1
			moved = true
		if not moved:
			break   # nothing this pack can cross: no stop further on
		out.append(at - 1)
	return out


## Whether a hex is land: neither water nor a wall (a pusher's segment is a land apron hex).
func _land(h: Vector2i) -> bool:
	var t := int(map.terrain.get(h, BattleMap.Terrain.PLAIN))
	return t != BattleMap.Terrain.WATER and t != BattleMap.Terrain.MOUNTAIN


## Dijkstra over the horde's ground from a pack's hex: [cost, prev]. Unbounded, or inside
## `budget` of move when one is given, a water hex then entered with whatever is left
## (BattleMap.spend), as a machine's own search does.
func _walk_search(sq: Unit, blocked: Dictionary, budget: int = -1) -> Array:
	var dist := {sq.pos: 0}
	var prev := {}
	var frontier: Array = [[0, sq.pos]]
	while not frontier.is_empty():
		var best := 0
		for i in range(1, frontier.size()):
			if frontier[i][0] < frontier[best][0]:
				best = i
		var cur: Array = frontier.pop_at(best)
		var d: int = cur[0]
		var h: Vector2i = cur[1]
		if d > dist[h]:
			continue
		for n in Hex.neighbors(h):
			if not _walkable(sq, n, blocked):
				continue
			var c := BattleMap.spend(map.terrain[n], sq.traits, (1 << 20) if budget < 0 else budget - d)
			if c < 0:
				continue
			var nd := d + c
			if not dist.has(n) or nd < dist[n]:
				dist[n] = nd
				prev[n] = h
				frontier.append([nd, n])
	return [dist, prev]


## The enemy's turn: every pack walks what plan_walks says, and a pack on the gate's apron
## strikes the gate for its threat rating's worth (strike_of). Returns the walks played.
func enemy_turn() -> Dictionary:
	var walks := plan_walks()
	for sq in packs():
		var w: Walk = walks[sq.id]
		if not w.path.is_empty():
			var before: Vector2i = w.path[w.path.size() - 2] if w.path.size() >= 2 else sq.pos
			sq.facing = _direction_index(before, w.end)
		sq.pos = w.end
		if w.strikes:
			var dmg := strike_of(sq)   # by its threat rating, less as a fight has worn it (10 November)
			gate_hp = maxi(0, gate_hp - dmg)
			log.append("%s strikes the gate for %d" % [sq.display_name, dmg])
		elif w.waits:
			log.append("%s has no way through and waits" % sq.display_name)
		elif w.catches != 0:
			var prey := unit_by_id(w.catches)
			if prey != null:
				log.append("%s catches %s" % [sq.display_name, prey.display_name])
	return walks


## The fights a hunter forces (bible section 5): every hunter that has caught a machine
## (`catch_of`: its prey beside it, within the engage range),
## and those fights come first on the player's turn. One pack is one fight (the long wall brief
## 3.4), a catch included (Ryan, 7 November, of two hunters on one machine: "Wouldn't it be two
## fights, since we're no longer merging fights?"): a fight per hunter, the prey in each, a prey's
## catches together, in field order: [{"prey": Unit, "hunters": [the hunter]}].
func forced_fights() -> Array:
	var order: Array = []
	var by_prey: Dictionary = {}
	for sq in packs():
		if sq.behaviour != "hunt" or sq.is_boss:
			continue
		var prey := catch_of(sq)
		if prey == null:
			continue
		if not by_prey.has(prey.id):
			by_prey[prey.id] = []
			order.append(prey.id)
		(by_prey[prey.id] as Array).append({"prey": prey, "hunters": [sq]})
	var out: Array = []
	for pid in order:
		out.append_array(by_prey[pid])
	return out


## The fight at `targets`: one pack is one fight (the long wall brief 3.4; Ryan, 5 November, of
## the rings and the joining: "it just adds so much complexity for not a lot of gain"), so no
## other pack joins it, and the machines whose attack range covers a target may be committed. The
## target is one pack: the one ordered onto, or the hunter that caught a machine (a forced fight).
## A ring is read only by a hunter's catch (catch_of, reaches, the walk's catch).
## {"targets": Array[Unit], "joins": Array[Unit] (always empty), "in_range": Array[Unit]}.
func attack_roster(targets: Array) -> Dictionary:
	var joins: Array[Unit] = []
	var in_range: Array[Unit] = []
	for m in mechs():
		for t in targets:
			if unit_distance(m, t) <= m.attack_range:
				in_range.append(m)
				break
	return {"targets": targets, "joins": joins, "in_range": in_range}


## How many actions a machine has a turn: one, and one more for each its passives grant (the
## Dingo's second).
static func actions_for(u: Unit) -> int:
	return 1 + Effects.extra_actions(u)


func _direction_index(from: Vector2i, to: Vector2i) -> int:
	var d := to - from
	for i in range(Hex.DIRECTIONS.size()):
		if Hex.DIRECTIONS[i] == d:
			return i
	return 0


## Whether `u` stands inside a hunter's ring: within the engage range of it (Unit.ENGAGE_RANGE, one
## number for everyone; the hunters' pounce of two retired 10 November), a hunter's catch the one reader.
static func in_ring(sq: Unit, u: Unit) -> bool:
	return unit_distance(sq, u) <= Unit.ENGAGE_RANGE


## The shortest hex distance between any hex of `a` and any hex of `b`.
static func unit_distance(a: Unit, b: Unit) -> int:
	var best := 1 << 30
	for x in a.hexes():
		for y in b.hexes():
			best = mini(best, Hex.distance(x, y))
	return best

## Feed the Rift Pressure clock. A peak when it fills. Returns true on a peak.
func tick_pressure(ticks: int) -> bool:
	rift_pressure += ticks
	if rift_pressure < rift_pressure_max:
		return false
	rift_pressure -= rift_pressure_max
	peak()
	return true


## A peak of Rift Pressure (the pacing session, 30 October): every mouth sends its packs
## (sends_a_peak, two the game's), each drawn by the band it makes for (_graded_sends), the rift from all
## five bands and a tear open before this peak from its own and the ones beside it; a hunting
## pack comes out of the rift every other peak from the second; the tears' row steps toward the
## wall; the ramp's count of new tears open on it, each to send from the next peak; and the
## interval shortens by the ramp's step. One clock, more mouths as the ramp rises.
func peak() -> void:
	peaks += 1
	var n := sends_a_peak()
	_graded_sends(map.rift, range(BAND_RATING.size()), n, true)
	for t in tears:
		var b := band_of(Hex.axial_to_offset(t["pos"]).x)
		_graded_sends(t["pos"], range(maxi(0, b - 1), mini(BAND_RATING.size(), b + 2)), n, false)
	if peaks >= 2 and peaks % 2 == 0 and not hunters.is_empty():
		var hunt := emerge(hunters[_hunter_index % hunters.size()], map.rift)
		_hunter_index += 1
		if hunt != null:
			rift_spawns += 1
			log.append("Rift pressure peaks: %s emerge at %s" % [hunt.display_name, str(hunt.pos)])
	tear_row = mini(tear_row + Ramp.tear_creep_at(ramp), tear_row_stop())
	for i in range(Ramp.tears_at(ramp)):
		var at := tear_hex()
		if at == NO_HEX:
			break
		tears.append({"pos": at, "opened": phase})
		log.append("A tear opens at %s" % str(at))
	rift_pressure_max = maxi(TIMER_FLOOR, rift_pressure_max - Ramp.step_at(ramp))


## The band of the wall a column stands in, 0 to 4 from one end to the other (BAND_RATING).
func band_of(col: int) -> int:
	return clampi((col * BAND_RATING.size()) / maxi(1, map.width), 0, BAND_RATING.size() - 1)


## One mouth's sends at a peak: `n` packs, each to a band of its own drawn
## from `bands` by the battle's seed, the peak and the mouth (so a resumed battle sends as the
## unbroken one did), the band's rating's next pack; an end's pack is for two one time in
## END_TWO_IN.
func _graded_sends(mouth: Vector2i, bands: Array, n: int, from_rift: bool) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed_value, peaks, mouth])
	var order: Array = bands.duplicate()
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var held = order[i]
		order[i] = order[j]
		order[j] = held
	for k in range(n):
		if order.is_empty():
			break
		var band := int(order[k % order.size()])
		var rating := int(BAND_RATING[band])
		if rating == 1 and rng.randi_range(1, END_TWO_IN) == 1:
			rating = 2
		var c := next_graded(rating)
		if c.is_empty():
			continue
		var sq := emerge(c, mouth, band)
		if sq == null:
			continue
		if from_rift:
			rift_spawns += 1
			log.append("Rift pressure peaks: %s emerge at %s" % [sq.display_name, str(sq.pos)])
		else:
			tear_spawns += 1
			log.append("A tear sends %s at %s" % [sq.display_name, str(sq.pos)])


## The tide's next pack of a rating, its list taken in turn; of the nearest rating that has any
## when its own has none (rating_dealt); empty with no pack at all.
func next_graded(rating: int) -> Dictionary:
	var r := rating_dealt(rating)
	if r < 0:
		return {}
	var pool: Array = graded[r]
	var at := int(_graded_at.get(r, 0))
	_graded_at[r] = at + 1
	return pool[at % pool.size()]


## The rating whose list a pack of `rating` is taken from: its own, else the nearest that has any
## (one lighter before one heavier); -1 with no pack at all.
func rating_dealt(rating: int) -> int:
	for r in [rating, rating - 1, rating + 1, rating - 2, rating + 2]:
		if not (graded.get(r, []) as Array).is_empty():
			return r
	return -1


## What a pack dealt for `rating` is worth on the Rupture meter, in menace, as the lists stand:
## the mean of the list it is taken from, each pack at its own threat rating.
func rating_worth(rating: int) -> int:
	var r := rating_dealt(rating)
	if r < 0:
		return 0
	var sum := 0
	for c in graded[r]:
		sum += ContentDB.worth_of(ContentDB.squad_of(c))
	return sum / (graded[r] as Array).size()


## What a send is worth on the Rupture meter before it is drawn, in menace: the mean of the
## bands a mouth draws from, the rift from all five and a tear from an end's and the one beside
## it, an end's pack counted with its share of twos, each rating at what its list holds
## (rating_worth: a domain with no pack for two deals a lighter one there, and is counted so).
## The meter is sized on it (Battle.setup), so no draw moves a threshold.
func send_worth(from_rift: bool) -> int:
	var one := rating_worth(1)
	var two := rating_worth(2)
	var end := one + (two - one) / END_TWO_IN
	if not from_rift:
		return (end + two) / 2
	return (2 * end + 2 * two + rating_worth(3)) / BAND_RATING.size()


## A composition as the tide's lists hold one, for the harness and the tests: one or more members
## under a faction, a patrol unless named otherwise.
static func composition(members: Array, faction: String, size: String = "patrol", id: String = "") -> Dictionary:
	var list: Array = []
	for m in members:
		list.append([str(m[0]), int(m[1])])
	return {"id": id if not id.is_empty() else (str(list[0][0]) if not list.is_empty() else ""), "size": size, "faction": faction, "members": list}


## A pack's shown name: its lead's shown name and "pack", as the setup names its packs (the
## mechanics audit's 30: a spawn was named by its content id, "zombie_knight pack").
func pack_name(foe_id: String) -> String:
	return "%s pack" % str(foe_profiles.get(foe_id, {}).get("name", foe_id)).to_lower()


## A composition emerges at a mouth (the rift, a tear, or where the setup places it): a pack of
## its members as content writes them, dressed by its lead, on the nearest free hex to the mouth
## with no machine adjacent (30 October: the player sees a spawn for a whole turn and nothing
## appears on top of a detachment), its wall segment drawn from there. A pack the rift sends then
## takes its place outside the shell, on the side it is headed (rift_landing). It walks at its
## slowest member's pace, or at the pace its composition names (`pace`: a pack's pace is its own,
## so a small band may run and a hunting pack of any size be fast). Null for a composition with no
## members. `band` is the band of the wall it makes for, -1 for the wall it reaches soonest.
func emerge(c: Dictionary, mouth: Vector2i, band: int = -1) -> Unit:
	var sq := pack_of(c, spawn_faction)
	if sq == null:
		return null
	sq.display_name = pack_name(sq.foe_id)
	dress_pack(sq)
	if int(c.get("pace", 0)) > 0:
		sq.movespeed = int(c["pace"])
	sq.pos = landing(sq, mouth)
	add_unit(sq)
	assign_goal(sq, band)
	if mouth == map.rift:
		sq.pos = rift_landing(sq, heading_of(sq))   # its segment is drawn first, so the draw is the one it always made
	return sq


## A composition dealt as a pack, wherever it is fought (the field's emerge, the quick campaign's
## encounters, the harness's fight; Ryan, 7 November: one code tree for both modes): its members as
## content writes them (the ramp scales no pack), its lead first (the long wall brief, section 6:
## the member whose sprite the pack wears; the first member when it names none), whether it hunts
## and whom (its `hunts`, the composition's to say and never its foes': Ryan, 8 November; else it
## pushes), its threat rating, its grid (eight cells, the fight's layout) and the pack counted to
## what the grid holds. Unplaced, unnamed and undressed: the caller does those. Null for no members.
static func pack_of(c: Dictionary, fallback_faction: String = "") -> Unit:
	var members: Array = []
	for m in c.get("members", []):
		members.append([str(m[0]), int(m[1])])
	if members.is_empty():
		return null
	var lead := str(c.get("lead", ""))
	for i in range(members.size()):
		if str(members[i][0]) == lead and i > 0:
			members.push_front(members.pop_at(i))
			break
	var fac := str(c.get("faction", ""))
	var sq := Unit.pack(0, "", Vector2i.ZERO, fac if not fac.is_empty() else fallback_faction, Unit.PACK_MOVE, 0, str(members[0][0]))
	sq.set_members(members)
	sq.composition = str(c.get("id", ""))
	sq.composition_size = str(c.get("size", ""))
	if not str(c.get("hunts", "")).is_empty():
		sq.behaviour = "hunt"
		sq.hunts = str(c["hunts"])
	sq.squad = ContentDB.squad_of(c)   # the threat rating the map shows (the long wall brief 3.7)
	sq.layout = Array(c.get("layout", [])).duplicate()
	recount_by_layout(sq)
	return sq


## A pack with a layout is what the layout places (no reinforcement inside a fight, Ryan, 6
## November): its members recounted from the named cells, a kind's count capped at the strength
## the composition gives it, the lead first while one stands. Content's grid and its members
## agree by construction (ContentDB.grid_members); the harness's and the tests' hand-made
## compositions may not, and are counted here. No layout keeps the members as given, and so
## does one that names nothing, which is dropped so the fight deploys them heaviest first.
static func recount_by_layout(sq: Unit) -> void:
	if sq.layout.is_empty():
		return
	var cap := {}
	for m in sq.member_list():
		cap[str(m[0])] = int(cap.get(str(m[0]), 0)) + int(m[1])
	var counts := {}
	var order: Array = []
	for cell in sq.layout:
		var fid := str(cell)
		if fid.is_empty() or int(counts.get(fid, 0)) >= int(cap.get(fid, 0)):
			continue
		if not counts.has(fid):
			order.append(fid)
		counts[fid] = int(counts.get(fid, 0)) + 1
	if order.is_empty():
		sq.layout = []
		return
	var lead := sq.foe_id
	if order.has(lead):
		order.erase(lead)
		order.push_front(lead)
	var members: Array = []
	for fid in order:
		members.append([fid, int(counts[fid])])
	sq.set_members(members)


## The caches, seeded with the map (content/loot.json): `per_battle` of them, one in each of as
## many bands along the wall, in the rows from `rift_gap` to `wall_gap` short of the apron (Ryan,
## 7 November: "we just don't seed loot that close to the wall"), on open ground a machine can end
## a move on, on no unit, the rift and the gate aside; each kind by its weight at the cache's depth
## (a kind's weight read between its wall's-end and rift's-end values by the row, so the farther
## from the wall the likelier a better kind: Ryan, 8 November), from a stream of its own off the
## battle's seed, so the map's other draws stand as they were. A band with no room seeds none.
func seed_caches(content: ContentDB, seed_arg: int) -> void:
	caches = []
	var kinds := content.loot_kinds()
	var n := int(content.loot_rules.get("per_battle", 0))
	if kinds.is_empty() or n <= 0:
		return
	var first := int(content.loot_rules.get("rift_gap", 3))
	var last := apron_row() - int(content.loot_rules.get("wall_gap", 2))
	if last < first:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = absi(hash([seed_arg, "caches"]))
	for i in range(n):
		var lo := (map.width * i) / n
		var hi := maxi(lo, (map.width * (i + 1)) / n - 1)
		var at := NO_HEX
		for attempt in range(32):
			var h := Hex.offset_to_axial(rng.randi_range(lo, hi), rng.randi_range(first, last))
			if _cache_fits(h):
				at = h
				break
		if at == NO_HEX:
			continue
		var depth := float(last - Hex.axial_to_offset(at).y) / float(maxi(1, last - first))   # 0 at the wall's end, 1 at the rift's
		var kind := _roll_kind(content, kinds, depth, rng)
		if kind.is_empty():
			continue
		caches.append({"id": i + 1, "tier": int(content.loot[kind].get("tier", 1)), "pos": at})
	# Behind the rift's shell (Ryan, 16 November: "a cache can and probably should appear behind it
	# as well"): on its seven hexes beside the rift, the boss's aside, its kind rolled at the rift's
	# depth, so the best likeliest: the final sortie's bait, out of the machines' reach until the
	# Rupture opens the seven.
	var behind: Array = map.shell_hexes().filter(func(h: Vector2i) -> bool: return _cache_fits(h))
	for i in range(int(content.loot_rules.get("behind_shell", 0))):
		if behind.is_empty():
			break
		var at: Vector2i = behind[rng.randi_range(0, behind.size() - 1)]
		var kind := _roll_kind(content, kinds, 1.0, rng)
		if kind.is_empty():
			break
		caches.append({"id": n + 1 + i, "tier": int(content.loot[kind].get("tier", 1)), "pos": at})
		behind = behind.filter(func(h: Vector2i) -> bool: return _cache_fits(h))


## A cache's kind rolled at `depth` (0 at the wall's end of the field, 1 at the rift's), each kind
## weighted between its two weights; "" when nothing weighs.
func _roll_kind(content: ContentDB, kinds: Array, depth: float, rng: RandomNumberGenerator) -> String:
	var weights: Array = []
	var total := 0.0
	for k in kinds:
		var w: Array = content.loot[k].get("weight", [0, 0])
		weights.append(lerpf(float(w[0]), float(w[1]), depth))
		total += weights[weights.size() - 1]
	if total <= 0.0:
		return ""
	var roll := rng.randf() * total
	for j in range(kinds.size()):
		roll -= float(weights[j])
		if roll < 0.0:
			return str(kinds[j])
	return str(kinds[0])


## Whether a cache may lie on a hex: open ground on the field (a step to cross, no water and no
## wall), no unit on it, not the rift's or the gate's, and no cache beside it.
func _cache_fits(h: Vector2i) -> bool:
	if not map.has(h) or map.is_structure(h) or unit_at(h) != null:
		return false
	if BattleMap.step_cost(int(map.terrain.get(h, BattleMap.Terrain.PLAIN)), []) != BattleMap.STEP:
		return false
	for c in caches:
		if Hex.distance(c["pos"], h) <= 1:
			return false
	return true


## The cache on a hex, {} for none.
func cache_at(h: Vector2i) -> Dictionary:
	for c in caches:
		if c["pos"] == h:
			return c
	return {}


## A pusher's wall segment. A pack the tide deals makes for the band it was drawn for (`band`,
## BAND_RATING), wherever in it the wall is least crowded (_crowding: the other pushers' segments
## on it or beside it; Ryan, 9 November: "avoiding crowding ... make sure packs don't get stuck on
## one another"), then the column nearest a draw from the turn and the pack, so a resumed battle
## draws as the unbroken one did (no stream). A pack dealt for no band (an elite that pushes, a
## pack made by hand), or whose band it cannot reach, takes the stretch of wall it reaches
## soonest, by the same draw (soonest_columns; Ryan, 23 November, of a formation one move from the
## wall that walked two turns to a stretch beside it: "they're skipping sections they could hit
## this turn to go hit something two turns away. I think the randomization of their movement
## should be chosen from targets of equivalent closeness, not distance from center"). A hunter
## and the boss draw none. Called as a pack is dealt (emerge, and again where the opening stands
## it: Battle.setup).
func assign_goal(sq: Unit, band: int = -1) -> void:
	if sq.is_boss or sq.behaviour != "push":
		return
	var cols := band_columns(sq, band) if band >= 0 else soonest_columns(sq)
	if cols.is_empty() and band >= 0:
		cols = soonest_columns(sq)
	if cols.is_empty():
		sq.goal_col = Hex.axial_to_offset(sq.pos).x   # no way to the wall as the field stands: its own column, where it waits
		return
	var want: int = cols[(phase * 31 + sq.id * 17) % cols.size()]
	var best := want
	var best_key := Vector2i(1 << 30, 0)
	for col in cols:
		var key := Vector2i(_crowding(sq, col), absi(col - want))
		if key.x < best_key.x or (key.x == best_key.x and key.y < best_key.y):
			best_key = key
			best = col
	sq.goal_col = best


## The wall columns a pusher reaches soonest from where it stands, in order along the wall: every
## land hex of the apron its own walk reaches (the ground's rules alone: who stands where by then is
## unknown, though a wreck holds its hex for the battle), each by the turns that walk takes
## (_turns_along), and of them the columns of the fewest. Empty when it has no way to the wall.
func soonest_columns(sq: Unit) -> Array[int]:
	var found := _walk_search(sq, {})
	var dist: Dictionary = found[0]
	var prev: Dictionary = found[1]
	var by_col := {}
	var fewest := 1 << 30
	for h in dist.keys():
		var hx: Vector2i = h
		if not on_apron(sq, hx) or not _land(hx) or wreck_at(hx) != null:
			continue
		var route: Array[Vector2i] = []
		var c := hx
		while c != sq.pos:
			route.push_front(c)
			c = prev[c]
		var turns := _turns_along(sq, route)
		var col := Hex.axial_to_offset(hx).x
		if not by_col.has(col) or turns < int(by_col[col]):
			by_col[col] = turns
		fewest = mini(fewest, turns)
	var out: Array[int] = []
	for col in by_col.keys():
		if int(by_col[col]) == fewest:
			out.append(int(col))
	out.sort()
	return out


## The wall columns of a band a pusher can reach from where it stands, in order along the wall:
## every land hex of the apron in the band its own walk reaches, whatever the turns (the tide's
## packs make for their band, not for the wall nearest them).
func band_columns(sq: Unit, band: int) -> Array[int]:
	var dist: Dictionary = _walk_search(sq, {})[0]
	var seen := {}
	for h in dist.keys():
		var hx: Vector2i = h
		if on_apron(sq, hx) and _land(hx) and wreck_at(hx) == null and band_of(Hex.axial_to_offset(hx).x) == band:
			seen[Hex.axial_to_offset(hx).x] = true
	var out: Array[int] = []
	for col in seen.keys():
		out.append(int(col))
	out.sort()
	return out


## The turns a pack takes to walk a route from where it stands: its move a turn, a water hex
## costing two and entered with whatever is left, as the turn's own walk spends it (_walk). None
## for a route of nothing; a route it cannot walk counts as never.
func _turns_along(sq: Unit, route: Array) -> int:
	var turns := 0
	var at := 0
	while at < route.size():
		var budget := sq.movespeed
		var moved := false
		while at < route.size():
			var cost := BattleMap.spend(map.terrain[route[at]], sq.traits, budget)
			if cost < 0:
				break
			budget -= cost
			at += 1
			moved = true
		if not moved:
			return 1 << 20
		turns += 1
	return turns


## How crowded a wall column is for a pusher drawing its segment: two for every other pusher whose
## segment it is, one for each whose segment is beside it, so two packs share a stretch of wall only
## when the window holds nothing emptier.
func _crowding(sq: Unit, col: int) -> int:
	var n := 0
	for other in packs():
		if other == sq or other.is_boss or other.behaviour != "push" or other.goal_col < 0:
			continue
		var d := absi(other.goal_col - col)
		n += 2 if d == 0 else (1 if d == 1 else 0)
	return n


## Whether a machine stands beside a hex.
func machine_adjacent(h: Vector2i) -> bool:
	for n in Hex.neighbors(h):
		var occ := unit_at(n)
		if occ != null and occ.is_player():
			return true
	return false


## Where a pack emerging at a mouth lands: the nearest hex it can stand on with no machine
## adjacent, by ring search; the nearest it can stand on at all when none is clear. With a
## `floor_row` the search never enters a row nearer the rift than it (the opening's packs stay
## off the rift's row, Battle._open_row: a shape may lay water or a wall on the floor row, and
## the pack goes along it rather than back onto the rift's). It lands with no hex of its own on
## a `shut` one, though the search passes them (the rift's landing: the shell's seven), and with
## a `within` only on a hex of it (the opening's: the ground with a way to the wall).
func landing(sq: Unit, mouth: Vector2i, floor_row: int = -1, shut: Dictionary = {}, within: Dictionary = {}) -> Vector2i:
	var seen := {mouth: true}
	var queue: Array[Vector2i] = [mouth]
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		if can_stand(sq, cur) and not machine_adjacent(cur) and Hex.axial_to_offset(cur).y >= floor_row and _clear_of(sq, cur, shut) and (within.is_empty() or within.has(cur)):
			return cur
		for n in Hex.neighbors(cur):
			if map.has(n) and not seen.has(n) and Hex.axial_to_offset(n).y >= floor_row:
				seen[n] = true
				queue.append(n)
	return nearest_standable(sq, mouth)


## The ground a pack can walk to the wall from: every hex its own walk reaches from the row before
## the wall, read back from it. A pocket the map's shape closed off is none of it, so nothing is
## stood where it could only wait (the opening's packs and the tears: a pack stood in a walled
## corner of the field held its hex for the battle, "no way through", and the Rupture's size
## counted it).
func wall_ground(sq: Unit) -> Dictionary:
	var out := {}
	var stood := sq.pos
	for h in apron_hexes().keys():
		var hx: Vector2i = h
		if out.has(hx) or not _land(hx) or not _walkable(sq, hx, {}):
			continue
		sq.pos = hx
		for k in (_walk_search(sq, {})[0] as Dictionary).keys():
			out[k] = true
	sq.pos = stood
	return out


## Whether a pack anchored at `at` holds none of the `shut` hexes.
func _clear_of(sq: Unit, at: Vector2i, shut: Dictionary) -> bool:
	if shut.is_empty():
		return true
	for o in sq.footprint:
		if shut.has(at + o):
			return false
	return true


var _rift_ring: Array[Vector2i] = []

## The ring outside the rift's shell: every hex beside one of the shell's seven that is neither
## one of them nor the rift's own, in the shell's order round the rift. Read once.
func rift_ring() -> Array[Vector2i]:
	if _rift_ring.is_empty():
		var inside := {}
		for h in map.rift_hexes:
			inside[h] = true
		for h in map.shell_hexes():
			inside[h] = true
		for h in map.shell_hexes():
			for n in Hex.neighbors(h):
				if map.has(n) and not inside.has(n) and not _rift_ring.has(n):
					_rift_ring.append(n)
	return _rift_ring


## Where a pack is headed as it is dealt: a hunter's prey (the machine it would turn on, read
## without locking it: would_hunt), a pusher's wall segment on the row before the wall, and
## straight down the field from the rift with neither.
func heading_of(sq: Unit) -> Vector2i:
	if sq.behaviour == "hunt":
		var prey := would_hunt(sq)
		if prey != null:
			return prey.pos
	var col := sq.goal_col if sq.goal_col >= 0 else Hex.axial_to_offset(map.rift).x
	return Hex.offset_to_axial(col, apron_row())


## Where a pack the rift sends lands (Ryan, 24 November: "spawns from the rift should probably
## spawn outside of the shell, and on a hex that is on the side of where they're headed. Right now
## they spawn from the back and have to skirt around the whole rift to head out"): a hex of the
## ring outside the shell's seven (rift_ring), the one its own walk to `toward` is shortest from,
## of those it can stand on clear of the shell with no machine beside it; of equals, the one
## nearest the wall, so it comes out of the rift's front. With none such on the ring (machines all
## round it, or every hex held) it lands as any spawn does, from the ring's hex nearest its
## heading outward and never on the shell. The form it retires: the nearest free hex to the
## rift's middle, which was a shell hex on the rift's own row whichever way the pack was going.
func rift_landing(sq: Unit, toward: Vector2i) -> Vector2i:
	var shut := {}
	for h in map.shell_hexes():
		shut[h] = true
	# Its walk read back from where it is headed: one search, every ring hex's distance in it (a
	# water hex is paid for on entering it, so a way read backwards is out by a wade at most).
	var stood := sq.pos
	sq.pos = toward
	var dist: Dictionary = _walk_search(sq, {})[0]
	sq.pos = stood
	var best := NO_HEX
	var best_key := Vector2i(1 << 30, 0)
	var nearest := NO_HEX   # the ring's hex nearest its heading, whoever stands on or by it
	var nearest_key := Vector2i(1 << 30, 0)
	for h in rift_ring():
		var key := Vector2i(int(dist.get(h, (1 << 20) + Hex.distance(h, toward))), -Hex.axial_to_offset(h).y)
		if key.x < nearest_key.x or (key.x == nearest_key.x and key.y < nearest_key.y):
			nearest = h
			nearest_key = key
		if not can_stand(sq, h) or machine_adjacent(h) or not _clear_of(sq, h, shut):
			continue
		if key.x < best_key.x or (key.x == best_key.x and key.y < best_key.y):
			best = h
			best_key = key
	if best != NO_HEX:
		return best
	return landing(sq, nearest if nearest != NO_HEX else map.rift, -1, shut)


## Where the next tear opens: a free land hex on the tears' row (the row above or below it
## when the row has none), no machine beside it and a way to the wall from it (wall_ground), the
## farthest from the rift and every open tear, so the mouths spread across the width; among
## equals, one by the turn. NO_HEX when none.
func tear_hex() -> Vector2i:
	var ground := wall_ground(Unit.new())   # a tear opens where a pack walking the horde's ground has a way to the wall
	for row in [tear_row, tear_row - 1, tear_row + 1]:
		var best: Array = []
		var best_d := -1
		for col in range(map.width):
			var h := Hex.offset_to_axial(col, row)
			if not _tear_fits(h) or not ground.has(h):
				continue
			var d := Hex.distance(h, map.rift)
			for t in tears:
				d = mini(d, Hex.distance(h, t["pos"]))
			if d > best_d:
				best = [h]
				best_d = d
			elif d == best_d:
				best.append(h)
		if not best.is_empty():
			return best[(phase * 7 + tears.size() * 13) % best.size()]
	return NO_HEX


## Whether a tear may open on a hex: land on the field, no unit and no wreck on it, no machine
## beside it.
func _tear_fits(h: Vector2i) -> bool:
	if not map.has(h) or map.is_structure(h) or int(map.terrain[h]) == BattleMap.Terrain.WATER or int(map.terrain[h]) == BattleMap.Terrain.MOUNTAIN:
		return false
	return unit_at(h) == null and wreck_at(h) == null and not machine_adjacent(h)


## Apply a finished skirmish back to the map: survivors keep marching, a wrecked machine leaves
## the units and lies where it fell (`wrecks`). Rift Pressure does not tick here (Ryan, 13
## October: a tick per round fought punished care invisibly and taxed the epic fight like a
## stall); it ticks on the map's enemy turns only.
func apply_skirmish_result(sk: Skirmish) -> void:
	for ms in sk.mechs:
		if ms.unit.hull <= 0:
			log.append("%s is wrecked" % ms.unit.display_name)
			units.erase(ms.unit)
			if not wrecks.has(ms.unit):
				wrecks.append(ms.unit)
	for sq in sk.packs:
		if sq.is_boss:
			# A boss unit stands while one of its commanders does, holding the rift: its lineup
			# the commanders still standing, its strength the escort left (found 21 October: a
			# withdrawal counted the boss among its strength, so it walked as a pack and came back
			# with a foe of the spawn list beside it).
			var standing := sk.commanders_left(sq)
			if standing.is_empty():
				log.append("%s destroyed" % sq.display_name)
				units.erase(sq)
			else:
				sq.lineup = standing
				if not sq.members.is_empty():
					sq.set_members(sk.members_left(sq))   # a hand-tailored escort, kept by member
				else:
					sq.strength = sk.escort_left(sq)
			continue
		if not sq.members.is_empty():
			# A composition keeps its survivors by member (30 October), the lead first.
			var left_members := sk.members_left(sq)
			if left_members.is_empty():
				log.append("%s destroyed" % sq.display_name)
				units.erase(sq)
			else:
				sq.set_members(left_members)
			continue
		var left := sk.survivors_for(sq)
		if left <= 0:
			log.append("%s destroyed" % sq.display_name)
			units.erase(sq)
		else:
			sq.strength = left
