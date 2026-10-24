class_name Battlefield
extends RefCounted

## Battlefield state and the turn's rules (bible section 4, the round row; section 5, the
## fights-by-ring row). Pure: no scenes, no signals, no rendering.
##
## A turn:
##   1. plan_walks()        where every pack will walk on the enemy's turn, against the field as
##                          it stands: a pusher toward the gate, a hunter toward its prey, round
##                          the machines, which are ground the horde goes round and never a stop
##   2. the player's turn   (Battle) first every fight a hunter forced (forced_fights), then
##                          fights the player picks (attack_roster): a fight is at the pack
##                          attacked, every pack whose ring covers it joins, and the machines
##                          committed are those whose attack range covers it
##   3. enemy_turn()        the packs walk what plan_walks says; a pack on the gate's apron
##                          strikes it
##
## Units may cover several hexes (Unit.footprint). Every footprint hex counts as occupied. The
## gate and the rift are structures wider than one hex; nobody stands on them.

## A pack's walk on the enemy's turn.
class Walk:
	var path: Array[Vector2i] = []   # the hexes it walks, after its own
	var end: Vector2i                # where it stops
	var strikes := false             # it stops on the gate's apron and strikes the gate
	var waits := false               # no way to its goal: it stays where it is
	var catches: int = 0             # a hunter whose walk ends within its ring of its prey: the prey's id
	var prey: int = 0                # a hunter's prey, by id

## What the map knows of each foe type (ContentDB.pack_profiles): the pack's engagement
## zone, whether it hunts, its move. Battle fills it from content, and a pack is dressed
## from it when it is made or spawns, so the defaults are the content's and never an id's.
var foe_profiles: Dictionary = {}

var map: BattleMap
var units: Array[Unit] = []
var gate_hp: int = 200
var gate_hp_max: int = 200
var rift_pressure: int = 0
var rift_pressure_max: int = 12
var spawn_faction: String = ""
## Packs the rift sends, cycled: [[foe_id, strength], ...], a guest faction's entries with
## their faction third. The game fills this from content (both, so no default names a foe).
var spawn_table: Array = []
var _spawn_index: int = 0
var phase: int = 0
var log: Array[String] = []
var _next_id: int = 1
## The machines a carrier's move lifts while its route is searched (the Swallowtail's carry,
## Ryan, 21 October: lifted in place, they travel as a ring round it), so their hexes never
## block it. Battle sets it for the search and clears it after; empty otherwise.
var lifted: Array[Unit] = []


func _init(battle_map: BattleMap) -> void:
	map = battle_map


func add_unit(u: Unit) -> Unit:
	if u.id == 0:
		u.id = _next_id
	_next_id = maxi(_next_id, u.id + 1)
	units.append(u)
	return u


## Give a pack its foe type's map profile. `foe` names the entry when the unit's own
## foe_id does not (the boss, which unpacks by its faction).
func dress_pack(sq: Unit, foe: String = "") -> Unit:
	var p: Dictionary = foe_profiles.get(foe if not foe.is_empty() else sq.foe_id, {})
	sq.zone = int(p.get("zone", sq.zone))
	if p.has("movespeed"):
		sq.movespeed = int(p["movespeed"])   # the boss's too: its patrol step is content
	if not sq.is_boss:
		sq.behaviour = str(p.get("behaviour", sq.behaviour))
		sq.hunts = str(p.get("hunts", sq.hunts))
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


## Whether `u` could stand with its anchor at `at`: every footprint hex in the map, passable,
## not a structure, and not held by another unit. Flyers are ignored as blockers only when
## `ignore_flyers` is set (packs pass through them).
func can_stand(u: Unit, at: Vector2i, ignore_flyers: bool = false) -> bool:
	for o in u.footprint:
		var h: Vector2i = at + o
		if not map.has(h) or map.is_structure(h):
			return false
		if not BattleMap.passable(map.terrain[h], u.traits):
			return false
		var occ := unit_at(h)
		if occ != null and occ != u and not lifted.has(occ):
			if ignore_flyers and not occ.can_block() and occ.is_player():
				continue
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
## its move this action has the rest).
func reachable(u: Unit, budget: int = -1) -> Dictionary:
	var dist: Dictionary = _search(u, u.pos, u.movespeed if budget < 0 else budget)[0]
	dist.erase(u.pos)
	return dist


## Cheapest route for `u` to `to` within its movespeed (or `budget`), as the hexes after its
## position. Empty when `to` is out of reach.
func route_to(u: Unit, to: Vector2i, budget: int = -1) -> Array[Vector2i]:
	return route_from(u, u.pos, u.movespeed if budget < 0 else budget, to)


## The cheapest continuation for `u` from `from` to `to` inside `budget` move points, as
## the hexes after `from`; empty when `to` is out of reach. A route drawn by hand grows by
## these, so a finger that skips a hex still leaves a walkable route.
func route_from(u: Unit, from: Vector2i, budget: int, to: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if to == from:
		return out
	var prev: Dictionary = _search(u, from, budget)[1]
	if not prev.has(to):
		return out
	var c := to
	while c != from:
		out.push_front(c)
		c = prev[c]
	return out


## What a route costs `u` in move points, or -1 when it is not one it can walk: every step
## adjacent to the last and standable, each paid for out of what is left of its move (or of
## `budget`); a slow hex takes the rest and so must be the last step.
func route_cost(u: Unit, route: Array, budget: int = -1) -> int:
	var cost := 0
	var cur := u.pos
	var move := u.movespeed if budget < 0 else budget
	for step in route:
		var s: Vector2i = step
		if not Hex.are_adjacent(cur, s) or not can_stand(u, s):
			return -1
		var c := BattleMap.spend(map.terrain[s], u.traits, move - cost)
		if c < 0:
			return -1
		cost += c
		cur = s
	return cost


## Dijkstra from `from`, bounded by `budget` move points. Returns [dist, prev]. `blocked`
## hexes are not entered; `through_flyers` lets a pack pass a flyer's hex without landing.
## A slow hex (BattleMap.SLOW) is entered with whatever is left and spends it all, so it
## is reached at the budget and nothing is reached through it: the stop that no move buys.
func _search(u: Unit, from: Vector2i, budget: int, blocked: Dictionary = {}, through_flyers: bool = false) -> Array:
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
			if not map.has(n) or blocked.has(n) or not can_stand(u, n, through_flyers):
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
		if Effects.never_hunted(m):
			continue
		var key := 0
		match sq.hunts:
			"weakest":
				key = m.hull + m.shield
			"strongest":
				key = -(m.hull + m.shield)
			"slowest":
				key = m.movespeed
			"fastest":
				key = -m.movespeed
			_:
				key = unit_distance(sq, m)
		if best == null or key < best_key:
			best = m
			best_key = key
	sq.prey = best.id if best != null else 0
	return best


## A boss patrols its ground outside the rift (Ryan, 22 September): one step to a standable
## hex within BOSS_ZONE of the rift, picked by the turn so the preview never disagrees with
## the walk; its own hex when nothing fits.
const BOSS_ZONE := 2

func _patrol_step(sq: Unit, blocked: Dictionary) -> Vector2i:
	var options: Array[Vector2i] = []
	for n in Hex.neighbors(sq.pos):
		if map.has(n) and Hex.distance(n, map.rift) <= BOSS_ZONE and not map.rift_hexes.has(n) and _walkable(sq, n, blocked) and _landable(sq, n):
			options.append(n)
	if options.is_empty():
		return sq.pos
	return options[(phase * 7 + sq.id * 13) % options.size()]


## Every pack's walk for the enemy's turn, against the field as it stands now (bible section
## 4, the round row). Packs plan in field order, each round where the packs before it will
## end and where the ones after it stand now, so the walk plays as shown. The preview is this
## call: nothing a pack does reacts to the plan, it reads where the machines stand.
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
## horde can cross, no structure, no other pack's hold, no grounded machine (a flyer is passed
## under). Machines are ground the horde goes round, never a stop.
func _walkable(sq: Unit, at: Vector2i, blocked: Dictionary) -> bool:
	for o in sq.footprint:
		var h: Vector2i = at + o
		if not map.has(h) or map.is_structure(h) or blocked.has(h):
			return false
		if not BattleMap.passable(map.terrain[h], sq.traits):
			return false
		var occ := unit_at(h)
		if occ != null and occ != sq and occ.is_player() and occ.can_block():
			return false
	return true


## Whether a pack may stop with its anchor at `at`: walkable, and no machine there at all.
func _landable(sq: Unit, at: Vector2i) -> bool:
	for o in sq.footprint:
		var occ := unit_at(at + o)
		if occ != null and occ != sq and occ.is_player():
			return false
	return true


## Whether a pack with its anchor at `at` stands on the gate's apron, beside a gate hex.
func on_apron(sq: Unit, at: Vector2i) -> bool:
	for o in sq.footprint:
		for g in map.gate_hexes:
			if Hex.distance(at + o, g) <= 1:
				return true
	return false


## The shortest distance from a pack anchored at `at` to a unit.
func _distance_from(sq: Unit, at: Vector2i, u: Unit) -> int:
	var best := 1 << 30
	for o in sq.footprint:
		for h in u.hexes():
			best = mini(best, Hex.distance(at + o, h))
	return best


## One pack's walk. A boss patrols, its escort with it. A hunter heads for the nearest hex it can reach that puts
## its prey inside its ring, or as near as it gets; a pusher for the nearest hex of the gate's
## apron. It walks as far as its move goes, round machines and the other packs, never ending
## under a flyer. A pusher with no way to the gate waits, and the map says so.
func _walk(sq: Unit, blocked: Dictionary) -> Walk:
	var w := Walk.new()
	w.end = sq.pos
	if sq.is_boss:
		var step := _patrol_step(sq, blocked)
		if step != sq.pos:
			w.path.append(step)
			w.end = step
		return w
	var found := _walk_search(sq, blocked)
	var dist: Dictionary = found[0]
	var prev: Dictionary = found[1]
	var goal := sq.pos
	var prey: Unit = pick_prey(sq) if sq.behaviour == "hunt" else null
	if prey != null:
		w.prey = prey.id
		var best_key := Vector2i(maxi(_distance_from(sq, sq.pos, prey) - sq.zone, 0), 0)
		for h in dist.keys():
			var hx: Vector2i = h
			if not _landable(sq, hx):
				continue
			var key := Vector2i(maxi(_distance_from(sq, hx, prey) - sq.zone, 0), int(dist[hx]))
			if key.x < best_key.x or (key.x == best_key.x and key.y < best_key.y):
				best_key = key
				goal = hx
	elif not on_apron(sq, sq.pos):
		var best := 1 << 30
		for h in dist.keys():
			var hx: Vector2i = h
			if on_apron(sq, hx) and _landable(sq, hx) and int(dist[hx]) < best:
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
	while not walked.is_empty() and not _landable(sq, walked[walked.size() - 1]):
		walked.pop_back()
	w.path = walked
	w.end = walked[walked.size() - 1] if not walked.is_empty() else sq.pos
	w.strikes = prey == null and on_apron(sq, w.end)
	if prey != null and _distance_from(sq, w.end, prey) <= sq.zone:
		w.catches = prey.id
	return w


## Dijkstra over the horde's ground from a pack's hex, unbounded: [cost, prev].
func _walk_search(sq: Unit, blocked: Dictionary) -> Array:
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
			var c := BattleMap.spend(map.terrain[n], sq.traits, 1 << 20)
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
			var dmg := maxi(10, (sq.strength * 10) / 3)
			gate_hp = maxi(0, gate_hp - dmg)
			log.append("%s strikes the gate for %d" % [sq.display_name, dmg])
		elif w.waits:
			log.append("%s has no way through and waits" % sq.display_name)
		elif w.catches != 0:
			var prey := unit_by_id(w.catches)
			if prey != null:
				log.append("%s catches %s" % [sq.display_name, prey.display_name])
	return walks


## The fights a hunter forces (bible section 5): every hunter that stands within its ring of
## its prey has caught it, and that fight comes first on the player's turn. One fight per
## caught machine, with every hunter that caught it, in field order:
## [{"prey": Unit, "hunters": Array[Unit]}].
func forced_fights() -> Array:
	var order: Array = []
	var by_prey: Dictionary = {}
	for sq in packs():
		if sq.behaviour != "hunt" or sq.is_boss:
			continue
		var prey := pick_prey(sq)
		if prey == null or not in_ring(sq, prey):
			continue
		if not by_prey.has(prey.id):
			by_prey[prey.id] = {"prey": prey, "hunters": []}
			order.append(prey.id)
		by_prey[prey.id]["hunters"].append(sq)
	var out: Array = []
	for pid in order:
		out.append(by_prey[pid])
	return out


## The fight at `targets` (bible section 5): every other pack whose ring covers a target joins,
## and the machines whose attack range covers a target may be committed.
## {"targets": Array[Unit], "joins": Array[Unit], "in_range": Array[Unit]}.
func attack_roster(targets: Array) -> Dictionary:
	var joins: Array[Unit] = []
	for p in packs():
		if targets.has(p):
			continue
		for t in targets:
			if in_ring(p, t):
				joins.append(p)
				break
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


## Whether `u` stands inside the pack's ring.
static func in_ring(sq: Unit, u: Unit) -> bool:
	return unit_distance(sq, u) <= sq.zone


## The shortest hex distance between any hex of `a` and any hex of `b`.
static func unit_distance(a: Unit, b: Unit) -> int:
	var best := 1 << 30
	for x in a.hexes():
		for y in b.hexes():
			best = mini(best, Hex.distance(x, y))
	return best

## Feed the Rift Pressure clock. Spawns a pack at the rift when it fills. Returns true on spawn.
func tick_pressure(ticks: int) -> bool:
	rift_pressure += ticks
	if rift_pressure < rift_pressure_max:
		return false
	rift_pressure -= rift_pressure_max
	var at := nearest_free(map.rift, [])
	var entry: Array = spawn_table[_spawn_index % spawn_table.size()] if not spawn_table.is_empty() else ["", 6]
	_spawn_index += 1
	var fac := str(entry[2]) if entry.size() > 2 else spawn_faction
	var sq := Unit.pack(0, "%s pack" % str(entry[0]), at, fac, Unit.PACK_MOVE, int(entry[1]), str(entry[0]))
	add_unit(dress_pack(sq))
	log.append("Rift pressure peaks: %s emerge at %s" % [sq.display_name, str(at)])
	return true


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
				sq.strength = sk.escort_left(sq)
			continue
		var left := sk.survivors_for(sq)
		if left <= 0:
			log.append("%s destroyed" % sq.display_name)
			units.erase(sq)
		else:
			sq.strength = left
