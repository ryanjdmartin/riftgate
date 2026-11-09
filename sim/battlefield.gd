class_name Battlefield
extends RefCounted

## Battlefield state and the turn's rules (bible section 4, the round row; section 5, the
## fights-by-ring row). Pure: no scenes, no signals, no rendering.
##
## A turn:
##   1. plan_walks()        where every pack will walk on the enemy's turn, against the field as
##                          it stands: a pusher toward the gate, a hunter toward its prey, round
##                          the grounded machines, which are ground the horde goes round and
##                          never a stop, through the other packs and under the flyers
##   2. the player's turn   (Battle) first every fight a hunter forced (forced_fights: its prey
##                          in its ring, or the machine it took when its prey is sealed off), then
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
	var prey: int = 0                # what a hunter comes for this turn, by id: its prey, or the machine it takes when its prey is sealed off (catch_of)

## What the map knows of each foe type (ContentDB.pack_profiles): its move, its wings, its
## shown name. Battle fills it from content, and a pack is dressed from it when it is made or
## spawns, so the defaults are the content's and never an id's. Whether a pack hunts is its
## composition's (pack_of), and a hunter's ring is the pounce alone (ContentDB.HUNTER_RING).
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
## The compositions the rift sends, cycled (the foes' fresh start, 30 October): each
## {"id", "size", "faction", "members": [[foe_id, strength], ...], "layout": its eight cells}, formations and patrols in
## turn, the lead's and the guest's in turn. The game fills this from content.
var cycle: Array = []
## The compositions the tears send, cycled: the patrols, the lead's and the guest's in turn.
var patrol_cycle: Array = []
var _cycle_index: int = 0
var _patrol_index: int = 0
## The flattening's edge (the pacing session, 30 October): the row the rift's bleed reaches,
## total on the rift's row and gone here, seam_start() at the start; it creeps south a peak
## (Ramp.seam_creep_at) as the clock's picture, as far as the apron. No rule reads the
## flattened hexes; the tears open on the seam's row.
var seam_row: int = 0   # seam_start(), set as the field takes its map


## Where the seam stands at a battle's start (the long wall brief 3.2): the first row past the
## rift's mouth at any depth (BattleMap.mouth_rows: 4 at twelve deep, 5 at twenty, the old
## field's number).
func seam_start() -> int:
	return map.mouth_rows() + 1


## The tears (Ryan's name, 30 October): the mouths beside the rift's, each {"pos": Vector2i,
## "opened": the phase it opened at}. A tear opens at a peak on the seam's row, far from the
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


func _init(battle_map: BattleMap) -> void:
	map = battle_map
	seam_row = seam_start()


func add_unit(u: Unit) -> Unit:
	if u.id == 0:
		u.id = _next_id
	_next_id = maxi(_next_id, u.id + 1)
	units.append(u)
	return u


## Give a pack its foe types' map profile: its move and its wings. `foe` names the entry when
## the unit's own foe_id does not (the boss, which unpacks by its faction). No foe says whether
## its pack hunts (its composition does, pack_of) or how far it reaches: a hunter catches at the
## pounce, one number (ContentDB.HUNTER_RING; Ryan, 8 November, the rings purged after a goblin
## warband caught from three hexes through the Mandragoras' old back-rank ring).
func dress_pack(sq: Unit, foe: String = "") -> Unit:
	var p: Dictionary = foe_profiles.get(foe if not foe.is_empty() else sq.foe_id, {})
	if p.has("movespeed"):
		sq.movespeed = int(p["movespeed"])   # the boss's too: its patrol step is content
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
	return map.has(h) and not map.is_structure(h) and unit_at(h) == null


## Whether `mover` may pass the hex `occ` stands on, never stopping there (Ryan, 29 October:
## "flyers and ground never interact except to fight", and enemies pass through enemies, since
## "enemy units are flat sprites so it's not like they take up space"): an airborne unit passes
## and is passed by everything, and a pack passes a pack. A grounded machine and a grounded
## pack are each other's walls, and two grounded machines each other's (the player sequences
## them: a move lands at once, so the next is planned from where it ended).
static func passes(mover: Unit, occ: Unit) -> bool:
	return mover.airborne() or occ.airborne() or (mover.is_enemy() and occ.is_enemy())


## Whether `u` could stand with its anchor at `at`: every footprint hex in the map, passable,
## not a structure, and not held by another unit. Nobody stops on another unit's hex.
func can_stand(u: Unit, at: Vector2i) -> bool:
	if not _ground_fits(u, at):
		return false
	for o in u.footprint:
		var occ := unit_at(at + o)
		if occ != null and occ != u and not lifted.has(occ):
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


## Every footprint hex on the field, no structure, ground `u` can enter.
func _ground_fits(u: Unit, at: Vector2i) -> bool:
	for o in u.footprint:
		var h: Vector2i = at + o
		if not map.has(h) or map.is_structure(h):
			return false
		if not BattleMap.passable(map.terrain[h], u.traits):
			return false
	return true


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
	var best: Unit = null
	var best_key := 0
	for m in mechs():
		if Effects.never_hunted(m) or hunted_by_other(m, sq):
			continue
		var key := _prey_key(sq, m)
		if best == null or key < best_key:
			best = m
			best_key = key
	# One hunter a machine (Ryan, 8 November): with every machine hunted already it pushes for the
	# wall instead, and turns on a machine once one is free, which the log says.
	var was := sq.prey
	sq.prey = best.id if best != null else 0
	if best != null and sq.prey != was:
		log.append("%s turns on %s" % [sq.display_name, best.display_name])
		locks.append([sq.id, best.id])
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
		"fastest":
			return -m.movespeed
	return _distance_from(sq, at, m)


## Who a hunter standing where it stands has caught (bible section 4, the fights-picked row):
## its prey inside its ring; or, when its prey is sealed off (`reaches`), the machine inside its
## ring that stands nearest its prey (Ryan, 29 October: "my target if I can reach him,
## otherwise the closest machine to my target that I can reach this turn, otherwise chase my
## target"; "It's just punishing hiding"). Null when it has caught nobody.
func catch_of(sq: Unit) -> Unit:
	var prey := pick_prey(sq)
	if prey == null:
		return null
	if in_ring(sq, prey):
		return prey
	return null if reaches(sq, prey) else _stand_in(sq, sq.pos, prey)


## Whether some hex a hunter can walk to puts `prey` inside its ring, by any route and over
## any number of turns, with the machines where they stand now: the ground it crosses, round
## the grounded machines, through the packs (they move) and under the flyers, onto a hex no
## machine holds. False only when walls and machines seal the prey off, which is hiding: a
## prey that keeps its distance is reached, and only its speed saves it.
func reaches(sq: Unit, prey: Unit) -> bool:
	var seen := {sq.pos: true}
	var queue: Array[Vector2i] = [sq.pos]
	while not queue.is_empty():
		var h: Vector2i = queue.pop_front()
		if _distance_from(sq, h, prey) <= ContentDB.HUNTER_RING and _landable(sq, h, {}):
			return true
		for n in Hex.neighbors(h):
			if not seen.has(n) and _walkable(sq, n, {}):
				seen[n] = true
				queue.append(n)
	return false


## The machine a hunter at `at` takes when its prey is sealed off: of the machines inside its
## ring from there, the one standing nearest its prey, its caveat deciding a tie and then the
## field's order. Never the prey, and never a machine whose passive says never_hunted (the
## Prairie Dog's, which is never hunted). Null when its ring holds none.
func _stand_in(sq: Unit, at: Vector2i, prey: Unit) -> Unit:
	var best: Unit = null
	var best_key := Vector2i.ZERO
	for m in mechs():
		if m == prey or Effects.never_hunted(m) or _distance_from(sq, at, m) > ContentDB.HUNTER_RING:
			continue
		var key := Vector2i(unit_distance(m, prey), _taste(sq, m, at))
		if best == null or key.x < best_key.x or (key.x == best_key.x and key.y < best_key.y):
			best = m
			best_key = key
	return best


## A hunter's walk when its prey is sealed off: to the hex this turn's move reaches whose
## stand-in (`_stand_in`) stands nearest its prey, the stand-in's caveat, the field's order and
## then the shorter walk deciding, so the machine it ends beside is the one `catch_of` reads.
## Null when no hex its move reaches puts a machine inside its ring: it closes on its prey.
func _stand_in_walk(sq: Unit, blocked: Dictionary, prey: Unit) -> Walk:
	var found := _walk_search(sq, blocked, sq.movespeed)
	var dist: Dictionary = found[0]
	var prev: Dictionary = found[1]
	var order := mechs()
	var goal := sq.pos
	var taken: Unit = null
	var best_key: Array = []
	for h in dist.keys():
		var hx: Vector2i = h
		if not _landable(sq, hx, blocked):
			continue
		var m := _stand_in(sq, hx, prey)
		if m == null:
			continue
		var key: Array = [unit_distance(m, prey), _taste(sq, m, hx), order.find(m), int(dist[hx])]
		if taken == null or key < best_key:
			taken = m
			best_key = key
			goal = hx
	if taken == null:
		return null
	var w := Walk.new()
	var c := goal
	while c != sq.pos:
		w.path.push_front(c)
		c = prev[c]
	w.route = w.path.duplicate()   # it reaches the machine it takes this turn
	w.end = goal
	w.prey = taken.id
	w.catches = taken.id
	return w


## A boss patrols its ground outside the rift (Ryan, 22 September): one step to a standable
## hex within BOSS_ZONE of the rift, picked by the turn so the preview never disagrees with
## the walk; its own hex when nothing fits.
const BOSS_ZONE := 2

func _patrol_step(sq: Unit, blocked: Dictionary) -> Vector2i:
	var options: Array[Vector2i] = []
	for n in Hex.neighbors(sq.pos):
		if map.has(n) and Hex.distance(n, map.rift) <= BOSS_ZONE and not map.rift_hexes.has(n) and _walkable(sq, n, blocked) and _landable(sq, n, blocked):
			options.append(n)
	if options.is_empty():
		return sq.pos
	return options[(phase * 7 + sq.id * 13) % options.size()]


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
## horde can cross, no structure, and no machine it does not pass (`passes`): it walks through
## the other packs and under a flyer, and a winged pack over everything. A grounded machine is
## ground the horde goes round, never a stop. `blocked` is for stopping (`_landable`).
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


## Whether a pack may stop with its anchor at `at`: walkable, no machine there at all, and no
## other pack's hold (`blocked`: where the packs planned before it end, where the rest stand).
func _landable(sq: Unit, at: Vector2i, blocked: Dictionary) -> bool:
	for o in sq.footprint:
		var h: Vector2i = at + o
		if blocked.has(h):
			return false
		var occ := unit_at(h)
		if occ != null and occ != sq and occ.is_player():
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


## Whether a hunter anchored at `at` holds `u` inside its ring: the catch's own reach.
func catches_at(sq: Unit, at: Vector2i, u: Unit) -> bool:
	return u != null and _distance_from(sq, at, u) <= ContentDB.HUNTER_RING


## The shortest distance from a pack anchored at `at` to a unit.
func _distance_from(sq: Unit, at: Vector2i, u: Unit) -> int:
	var best := 1 << 30
	for o in sq.footprint:
		for h in u.hexes():
			best = mini(best, Hex.distance(at + o, h))
	return best


## One pack's walk. A boss patrols, its escort with it. A hunter heads for the nearest hex it can reach that puts
## its prey inside its ring, or as near as it gets; with its prey sealed off it takes the
## machine nearest it that this turn's move can put inside its ring (`_stand_in_walk`). A
## pusher heads for the nearest hex of the gate's apron. It walks as far as its move goes,
## round the grounded machines, through the other packs and under the flyers, never ending on
## another unit's hex. A pusher with no way to the gate waits, and the map says so.
func _walk(sq: Unit, blocked: Dictionary) -> Walk:
	var w := Walk.new()
	w.end = sq.pos
	if sq.is_boss:
		var step := _patrol_step(sq, blocked)
		if step != sq.pos:
			w.path.append(step)
			w.route.append(step)
			w.end = step
		return w
	var prey: Unit = pick_prey(sq) if sq.behaviour == "hunt" else null
	if prey != null and not reaches(sq, prey):
		var taken := _stand_in_walk(sq, blocked, prey)
		if taken != null:
			return taken
	var found := _walk_search(sq, blocked)
	var dist: Dictionary = found[0]
	var prev: Dictionary = found[1]
	var goal := sq.pos
	if prey != null:
		w.prey = prey.id
		var best_key := Vector2i(maxi(_distance_from(sq, sq.pos, prey) - ContentDB.HUNTER_RING, 0), 0)
		for h in dist.keys():
			var hx: Vector2i = h
			if not _landable(sq, hx, blocked):
				continue
			var key := Vector2i(maxi(_distance_from(sq, hx, prey) - ContentDB.HUNTER_RING, 0), int(dist[hx]))
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
	while c != sq.pos:
		route.push_front(c)
		c = prev[c]
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
	if prey != null and _distance_from(sq, w.end, prey) <= ContentDB.HUNTER_RING:
		w.catches = prey.id
	return w


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
## strikes the gate for a third of its strength, ten at least. Returns the walks played.
func enemy_turn() -> Dictionary:
	var walks := plan_walks()
	for sq in packs():
		var w: Walk = walks[sq.id]
		if not w.path.is_empty():
			var before: Vector2i = w.path[w.path.size() - 2] if w.path.size() >= 2 else sq.pos
			sq.facing = _direction_index(before, w.end)
		sq.pos = w.end
		if w.strikes:
			var dmg := maxi(1, (sq.strength * 10) / 3)   # a third of its strength, no floor but one (Ryan, 30 October: a stray pair chips less than a trio)
			gate_hp = maxi(0, gate_hp - dmg)
			log.append("%s strikes the gate for %d" % [sq.display_name, dmg])
		elif w.waits:
			log.append("%s has no way through and waits" % sq.display_name)
		elif w.catches != 0:
			var prey := unit_by_id(w.catches)
			if prey != null:
				if w.catches == sq.prey:
					log.append("%s catches %s" % [sq.display_name, prey.display_name])
				else:
					var sealed := unit_by_id(sq.prey)
					log.append("%s catches %s in %s's place" % [sq.display_name, prey.display_name, sealed.display_name if sealed != null else "its prey"])
	return walks


## The fights a hunter forces (bible section 5): every hunter that has caught a machine
## (`catch_of`: its prey inside its ring, or the machine it took when its prey is sealed off),
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


## Whether `u` stands inside a hunter's ring: within its pounce of it (ContentDB.HUNTER_RING, one
## number for every hunter since the rings were purged, 8 November), a hunter's catch the one reader.
static func in_ring(sq: Unit, u: Unit) -> bool:
	return unit_distance(sq, u) <= ContentDB.HUNTER_RING


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


## A peak of Rift Pressure (the pacing session, 30 October): the rift sends the cycle's next
## composition; every tear open before this peak sends the patrol cycle's next; the seam creeps
## south; the ramp's count of new tears open on the seam's row, each to send from the next
## peak; and the interval shortens by the ramp's step. One clock, more mouths as the ramp rises.
func peak() -> void:
	peaks += 1
	if not cycle.is_empty():
		var c: Dictionary = cycle[_cycle_index % cycle.size()]
		_cycle_index += 1
		var sq := emerge(c, map.rift)
		if sq != null:
			rift_spawns += 1
			log.append("Rift pressure peaks: %s emerge at %s" % [sq.display_name, str(sq.pos)])
	for t in tears:
		if patrol_cycle.is_empty():
			break
		var c: Dictionary = patrol_cycle[_patrol_index % patrol_cycle.size()]
		_patrol_index += 1
		var sq := emerge(c, t["pos"])
		if sq != null:
			tear_spawns += 1
			log.append("A tear sends %s at %s" % [sq.display_name, str(sq.pos)])
	seam_row = mini(seam_row + Ramp.seam_creep_at(ramp), apron_row())
	for i in range(Ramp.tears_at(ramp)):
		var at := tear_hex()
		if at == NO_HEX:
			break
		tears.append({"pos": at, "opened": phase})
		log.append("A tear opens at %s" % str(at))
	rift_pressure_max = maxi(TIMER_FLOOR, rift_pressure_max - Ramp.step_at(ramp))


## A composition as the cycle holds it, for the harness and the tests: one or more members
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
## appears on top of a detachment). Null for a composition with no members.
func emerge(c: Dictionary, mouth: Vector2i) -> Unit:
	var sq := pack_of(c, spawn_faction)
	if sq == null:
		return null
	sq.display_name = pack_name(sq.foe_id)
	dress_pack(sq)
	sq.pos = landing(sq, mouth)
	add_unit(sq)
	assign_goal(sq, -1, mouth == map.rift)
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
		var weights: Array = []
		var total := 0.0
		for k in kinds:
			var w: Array = content.loot[k].get("weight", [0, 0])
			weights.append(lerpf(float(w[0]), float(w[1]), depth))
			total += weights[weights.size() - 1]
		if total <= 0.0:
			continue
		var roll := rng.randf() * total
		var kind := str(kinds[0])
		for j in range(kinds.size()):
			roll -= float(weights[j])
			if roll < 0.0:
				kind = str(kinds[j])
				break
		caches.append({"id": i + 1, "tier": int(content.loot[kind].get("tier", 1)), "pos": at})


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


## A pusher's wall segment (the long wall brief 3.3): the wall nearest where it is dealt, and a
## draw either side, from the turn and the pack, so a resumed battle draws as the unbroken one did
## (no stream). A pack the rift sends draws about the rift's column within the ramp's spread (Ryan,
## 5 November: rift packs "can target a segment left or right of it, reducing clogging and creating
## extra tension. The variance of where they target can even be a ramp factor"); any other (a flank
## patrol, a formation the opening places, a tear's patrol) about its own column within
## Ramp.FLANK_SPREAD (Ryan, 9 November: "the flankers should target their closest wall with a small
## amount of randomness, avoiding crowding, in order to force the player to make decisions ... make
## sure packs don't get stuck on one another, but also don't target halfway across the map and
## become irrelevant"). Of the window's columns the least crowded wins (_crowding: the other
## pushers' segments on it or beside it), then the one nearest the draw, so the packs spread along
## the wall and never pile onto one stretch, and none leaves its window for room. A spread given
## (the tests) sets the window. A hunter and the boss draw none. Called as a pack is dealt
## (emerge: the start's placements and every spawn).
func assign_goal(sq: Unit, spread: int = -1, from_rift: bool = false) -> void:
	if sq.is_boss or sq.behaviour != "push":
		return
	if spread < 0:
		spread = Ramp.spread_at(ramp, map.width) if from_rift else Ramp.FLANK_SPREAD
	var base := Hex.axial_to_offset(map.rift if from_rift else sq.pos).x
	var want := clampi(base + (phase * 31 + sq.id * 17) % (2 * spread + 1) - spread, 0, map.width - 1)
	var best := want
	var best_key := Vector2i(1 << 30, 0)
	for col in range(maxi(0, base - spread), mini(map.width - 1, base + spread) + 1):
		var key := Vector2i(_crowding(sq, col), absi(col - want))
		if key.x < best_key.x or (key.x == best_key.x and key.y < best_key.y):
			best_key = key
			best = col
	sq.goal_col = best


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
## out of the rift's mouth, Battle._open_row: a shape may lay water or a wall on the first row
## past the mouth, and the pack goes along it rather than back into the mouth).
func landing(sq: Unit, mouth: Vector2i, floor_row: int = -1) -> Vector2i:
	var seen := {mouth: true}
	var queue: Array[Vector2i] = [mouth]
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		if can_stand(sq, cur) and not machine_adjacent(cur) and Hex.axial_to_offset(cur).y >= floor_row:
			return cur
		for n in Hex.neighbors(cur):
			if map.has(n) and not seen.has(n) and Hex.axial_to_offset(n).y >= floor_row:
				seen[n] = true
				queue.append(n)
	return nearest_standable(sq, mouth)


## Where the next tear opens: a free land hex on the seam's row (the row above or below it
## when the row has none), no machine beside it, the farthest from the rift and every open
## tear, so the mouths spread across the width; among equals, one by the turn. NO_HEX when
## none.
func tear_hex() -> Vector2i:
	for row in [seam_row, seam_row - 1, seam_row + 1]:
		var best: Array = []
		var best_d := -1
		for col in range(map.width):
			var h := Hex.offset_to_axial(col, row)
			if not map.has(h) or map.is_structure(h) or int(map.terrain[h]) == BattleMap.Terrain.WATER or int(map.terrain[h]) == BattleMap.Terrain.MOUNTAIN:
				continue
			if unit_at(h) != null or machine_adjacent(h):
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


## Apply a finished skirmish back to the map: survivors keep marching, wrecks are removed.
## Rift Pressure does not tick here (Ryan, 13 October: a tick per round fought punished care
## invisibly and taxed the epic fight like a stall); it ticks on the map's enemy turns only.
func apply_skirmish_result(sk: Skirmish) -> void:
	for ms in sk.mechs:
		if ms.unit.hull <= 0:
			log.append("%s is wrecked" % ms.unit.display_name)
			units.erase(ms.unit)
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
