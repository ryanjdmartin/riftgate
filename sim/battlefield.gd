class_name Battlefield
extends RefCounted

## Battlefield state and phase resolution. Pure: no scenes, no signals, no rendering.
##
## A phase:
##   1. compute_intents()          every pack commits its path for the round: pushers and
##                                 aggressive packs to the gate, hunters toward their prey
##   2. player plots routes        (outside the sim)
##   3. resolve_phase(routes)      player routes resolve first; then each pack walks its
##                                 committed path, except an aggressive pack with a machine
##                                 inside its reach (it goes for the biggest catch) and a
##                                 hunter (it goes after its prey's new hex); a pack stops
##                                 at the first blocked hex
##   4. detect_skirmishes()        contacts: every machine inside a pack's engagement zone
##                                 where it ends fights it; a machine in two zones joins
##                                 those two packs' fights into one
##
## Units may cover several hexes (Unit.footprint). Every footprint hex blocks, touches, and
## counts as occupied. The gate and the rift are structures wider than one hex; nobody stands
## on them and packs strike any gate hex.

class PhaseResult:
	var moved: Array[int] = []        # unit ids that moved
	var rejected: Array[int] = []     # unit ids whose route was invalid
	var blocked: Array[int] = []      # pack ids stopped by a body block
	var stalled: Array[int] = []      # pack ids that had no way to any goal this phase (every approach held by their own side)
	var blockers: Dictionary = {}     # pack id -> the unit id that stood in its path (the stealth join rule reads it)
	var intents: Dictionary = {}      # pack id -> the path it followed: the committed one, or the reaction
	var gate_damage: int = 0
	var spawned: bool = false
	var skirmishes: Array = []        # Array of Array[Unit]

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
var spawn_faction: String = "undead"
## Packs the rift sends, cycled: [[foe_id, strength], ...], a guest faction's entries with
## their faction third. The game fills this from content.
var spawn_table: Array = [["ghoul", 6]]
var _spawn_index: int = 0
var phase: int = 0
var intents: Dictionary = {}   # pack id -> Array[Vector2i]: the path each pack committed to when the round opened
var stalled: Dictionary = {}   # pack id -> true: no goal was reachable when the round opened, so the pack waits where it is
var log: Array[String] = []
var _next_id: int = 1


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
	if not sq.elite:
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
		if occ != null and occ != u:
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


## Every anchor hex a unit can end its move on this phase, mapped to the cost of getting there.
func reachable(u: Unit) -> Dictionary:
	var dist: Dictionary = _search(u, u.pos, u.movespeed)[0]
	dist.erase(u.pos)
	return dist


## Cheapest route for `u` to `to` within its movespeed, as the hexes after its position.
## Empty when `to` is out of reach. What resolve_phase expects for a plotted mech.
func route_to(u: Unit, to: Vector2i) -> Array[Vector2i]:
	return route_from(u, u.pos, u.movespeed, to)


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
## adjacent to the last and standable, each paid for out of what is left (a slow hex takes
## the rest and so must be the last step). The rule Resolve applies, asked ahead of time.
func route_cost(u: Unit, route: Array) -> int:
	var cost := 0
	var cur := u.pos
	for step in route:
		var s: Vector2i = step
		if not Hex.are_adjacent(cur, s) or not can_stand(u, s):
			return -1
		var c := BattleMap.spend(map.terrain[s], u.traits, u.movespeed - cost)
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


## Where each pack commits to go this round (decided 1 October: the enemy commits first,
## so a route the player reads at the round's start is the route). Pushers and aggressive
## packs head for the gate; a hunter picks its prey, if it has none, and heads for where the
## prey stands now. Paths ignore the machines, so what the player sees is "where they go
## unless you stop them"; a pack's reaction to the plan, if it has one, is `_react`'s.
##
## A pack whose way to its goal is held by its own side turns for the next goal it can
## reach (Ryan, 6 October: a stalled horde is never the norm): a gate-goer tries every
## gate hex and defence nearest first. One with no goal reachable at all waits where it
## is and is marked `stalled`, which the preview shows. Found 2 October: 156 of 600 packs
## in a packs-only run stood still for want of this, with no mark.
func compute_intents() -> void:
	# Packs plan in field order, each around where the packs before it will end and
	# where the ones after it stand now (Ryan, 22 September), so a pack routes around a
	# hex another is taking instead of walking into it and stopping short. The same order
	# moves them at resolve, so an intent plays as shown unless a body blocks it.
	intents.clear()
	stalled.clear()
	var ends: Dictionary = {}   # pack id -> hexes it will hold, for the packs after it
	for sq in packs():
		var blocked := _held_by_others(sq, ends)
		var target := _pick_target(sq)
		var path := _affordable(sq, map.find_path(sq.pos, target, sq.traits, blocked))
		if path.is_empty() and target != sq.pos:
			for alt in _gate_targets(sq):
				if alt == target:
					continue
				path = _affordable(sq, map.find_path(sq.pos, alt, sq.traits, blocked))
				if not path.is_empty():
					break
			if path.is_empty():
				stalled[sq.id] = true
		intents[sq.id] = path
		ends[sq.id] = _held_after(sq, path)


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


## The hexes a pack will hold after walking `path`: a strike on the gate or a body in the
## way is where it stops, not where it stands.
func _held_after(sq: Unit, path: Array) -> Array:
	var end: Vector2i = sq.pos
	for step in path:
		if map.gate_hexes.has(step) or (unit_at(step) != null and unit_at(step).is_player() and unit_at(step).can_block()):
			break
		end = step
	var held: Array = []
	for o in sq.footprint:
		held.append(end + o)
	return held


## A hunter's prey, picked by its caveat the first time it needs one and kept until the
## machine is gone (single-minded, so the lock the player sees holds). Stealth machines
## are never picked. Null when there is nothing to hunt.
func pick_prey(sq: Unit) -> Unit:
	var current := unit_by_id(sq.prey)
	if current != null and current.is_player() and not current.is_static():
		return current
	var best: Unit = null
	var best_key := 0
	for m in mechs():
		if m.traits.has("stealth"):
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


## Where a pack heads this phase. A boss patrols its zone outside the rift (Ryan, 22
## September): one step to a standable hex within BOSS_ZONE of the rift, picked by the
## phase so the preview never disagrees with the resolve; nothing, when nothing fits.
const BOSS_ZONE := 2

func _pick_target(sq: Unit) -> Vector2i:
	if sq.elite and sq.strength == 0:
		var options: Array[Vector2i] = []
		for n in Hex.neighbors(sq.pos):
			if map.has(n) and Hex.distance(n, map.rift) <= BOSS_ZONE and can_stand(sq, n) and not map.rift_hexes.has(n):
				options.append(n)
		if options.is_empty():
			return sq.pos
		return options[(phase * 7 + sq.id * 13) % options.size()]
	if sq.behaviour == "hunt":
		var prey := pick_prey(sq)
		if prey != null:
			return hunt_target(sq, prey)
	return _gate_target(sq)


## Where a hunter heads for its prey: the prey's own hex when the pack could stand there
## (the path stops at the body, which is the strike), else the nearest hex inside the
## pack's zone of the prey that the pack can reach, nearest to the pack. A prey standing in
## water (a wall to the horde) would otherwise give the planner an impassable goal and the
## pack would stand still with no mark (found 2 October).
func hunt_target(sq: Unit, prey: Unit) -> Vector2i:
	if BattleMap.passable(map.terrain[prey.pos], sq.traits):
		return prey.pos
	var ring: Dictionary = {}
	_ring_into(prey.pos, sq.zone, ring)
	var best := prey.pos
	var best_d := 1 << 30
	for h in ring.keys():
		var hx: Vector2i = h
		if hx == prey.pos or not BattleMap.passable(map.terrain[hx], sq.traits):
			continue
		var d := Hex.distance(sq.pos, hx)
		if d < best_d or (d == best_d and (hx.y < best.y or (hx.y == best.y and hx.x < best.x))):
			best = hx
			best_d = d
	return best


## Each pack's path for this phase's movement, the machines having moved: the committed
## one, unless the pack reacts (decided 1 October). An aggressive pack with a machine
## inside its reach goes for the hex within its move whose zone holds the most machines,
## ties toward the gate. A hunter goes for where its prey now stands. Both show in the
## preview, which is the same dry run, so the reaction is read before Resolve; the reach
## ring and the lock say beforehand whether there will be one.
func _react() -> Dictionary:
	var plans: Dictionary = {}
	var ends: Dictionary = {}
	for sq in packs():
		var blocked := _held_by_others(sq, ends)
		var path: Array[Vector2i] = []
		path.assign(intents.get(sq.id, []))
		if sq.behaviour == "aggressive" and not (sq.elite and sq.strength == 0):
			var best: Array = _best_catch(sq, blocked)
			if int(best[1]) > 0:
				path = _affordable(sq, map.find_path(sq.pos, best[0], sq.traits, blocked))
		elif sq.behaviour == "hunt":
			var prey := pick_prey(sq)
			if prey != null:
				path = _affordable(sq, map.find_path(sq.pos, hunt_target(sq, prey), sq.traits, blocked))
		plans[sq.id] = path
		ends[sq.id] = _held_after(sq, path)
	return plans


## The hex within a pack's move whose zone holds the most machines, ties toward the gate,
## as [hex, count]; its own hex counts. A count of 0 means nothing is in its reach.
func _best_catch(sq: Unit, blocked: Dictionary) -> Array:
	var best := sq.pos
	var best_n := _catch(sq, sq.pos)
	var best_d := _gate_distance(sq.pos)
	var reach: Dictionary = _search(sq, sq.pos, sq.movespeed, blocked, true)[0]
	for h in reach.keys():
		var n := _catch(sq, h)
		var d := _gate_distance(h)
		if n > best_n or (n == best_n and d < best_d):
			best = h
			best_n = n
			best_d = d
	return [best, best_n]


## An aggressive pack's reach: every hex its zone can fall on this round, from every hex it
## can walk to past the other packs. What the map draws as the ring, and what "a machine
## within its reach" means, so the ring never promises what the ground denies.
func reach_hexes(sq: Unit) -> Dictionary:
	var out: Dictionary = {}
	var reach: Dictionary = _search(sq, sq.pos, sq.movespeed, _held_by_others(sq, {}), true)[0]
	for h in reach.keys():
		for o in sq.footprint:
			_ring_into(h + o, sq.zone, out)
	return out


func _ring_into(h: Vector2i, r: int, out: Dictionary) -> void:
	var dist := {h: 0}
	var queue: Array[Vector2i] = [h]
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		if map.has(cur) and not map.is_structure(cur):
			out[cur] = true
		if int(dist[cur]) >= r:
			continue
		for n in Hex.neighbors(cur):
			if not dist.has(n):
				dist[n] = int(dist[cur]) + 1
				queue.append(n)


## How many machines a pack standing at `at` would have inside its zone. Stealth machines
## are not counted: a zone never pulls one in.
func _catch(sq: Unit, at: Vector2i) -> int:
	var n := 0
	for m in mechs():
		if m.traits.has("stealth"):
			continue
		var d := 1 << 30
		for o in sq.footprint:
			for h in m.hexes():
				d = mini(d, Hex.distance(at + o, h))
		if d <= sq.zone:
			n += 1
	return n


func _gate_distance(h: Vector2i) -> int:
	var d := Hex.distance(h, map.gate)
	for g in map.gate_hexes:
		d = mini(d, Hex.distance(h, g))
	return d


## The nearest gate hex or static defence: where a pusher heads.
func _gate_target(sq: Unit) -> Vector2i:
	return _gate_targets(sq)[0]


## Every gate hex and static defence, nearest to the pack first (ties in field order, the
## gate's centre first), so a pack held off one can try the next.
func _gate_targets(sq: Unit) -> Array[Vector2i]:
	var goals: Array[Vector2i] = [map.gate]
	for g in map.gate_hexes:
		if not goals.has(g):
			goals.append(g)
	for d in defenses():
		if not goals.has(d.pos):
			goals.append(d.pos)
	var order: Array = []
	for i in range(goals.size()):
		order.append([Hex.distance(sq.pos, goals[i]), i])
	order.sort()
	var out: Array[Vector2i] = []
	for o in order:
		out.append(goals[int(o[1])])
	return out


func _affordable(sq: Unit, path: Array[Vector2i]) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var budget := sq.movespeed
	for step in path:
		# Reaching a target hex (gate, defense, mech) is an attack, not a move. Keep it in
		# the preview so the player sees the strike, then stop.
		var occ := unit_at(step)
		if map.gate_hexes.has(step) or (occ != null and occ.is_player() and occ.can_block()):
			out.append(step)
			break
		var c := BattleMap.spend(map.terrain[step], sq.traits, budget)
		if c < 0:
			break
		budget -= c
		out.append(step)
	return out


## Resolve one phase. `routes` maps a mech id to an Array of anchor hexes after its position.
func resolve_phase(routes: Dictionary) -> PhaseResult:
	var result := PhaseResult.new()
	phase += 1
	_move_all(routes, result, false)
	result.spawned = tick_pressure(1)
	result.skirmishes = detect_skirmishes(result.blockers)
	return result


## The phase as it would resolve right now, without resolving it (Ryan, 21 September: the
## plan must never be ambiguous). Runs the same movement as `resolve_phase`, dry, then puts
## every unit back. Returns {"result": PhaseResult, "ends": {unit id: hex}}. Only the
## pressure tick and its spawn are left out: a pack that spawns at the rift this phase
## cannot be in a contact, since nothing stands at the rift.
func preview_phase(routes: Dictionary) -> Dictionary:
	var saved: Dictionary = {}
	for u in units:
		saved[u.id] = [u.pos, u.facing]
	var result := PhaseResult.new()
	phase += 1   # the phase the resolve will be, so a boss's patrol step is the same one
	_move_all(routes, result, true)
	phase -= 1
	result.skirmishes = detect_skirmishes(result.blockers)
	var ends: Dictionary = {}
	for u in units:
		ends[u.id] = u.pos
	for u in units:
		u.pos = saved[u.id][0]
		u.facing = saved[u.id][1]
	return {"result": result, "ends": ends}


## The movement of one phase: the mechs' routes in the order given, then every pack in
## field order. Order matters twice, and this is the one place it is decided: a route
## through a hex another mech is leaving is rejected unless that mech went first, and a
## pack stops short of a hex another pack has already taken. `dry` skips the gate
## damage and the log.
func _move_all(routes: Dictionary, result: PhaseResult, dry: bool) -> void:
	# Mechs first, in the order the player plotted them (the dictionary's order). Routes
	# are planned in that same order against where earlier machines will be (Ryan, 22
	# September: don't let a destination be chosen that an earlier move blocks), so a
	# route is never rejected here in play; the branch stays as a guard.
	for uid in routes.keys():
		var u := unit_by_id(uid)
		if u == null or not u.is_player() or u.is_static():
			result.rejected.append(uid)
			continue
		if _apply_route(u, routes[uid]):
			result.moved.append(uid)
		else:
			result.rejected.append(uid)
			if not dry:
				log.append("%s: route rejected" % u.display_name)
	# The packs walk what they committed to when the round opened, or their reaction to
	# where the machines now stand (an aggressive pack with someone in reach, a hunter),
	# worked out here so the preview and the resolve agree.
	var plans := _react()
	result.intents = plans.duplicate(true)
	for sq in packs():
		var plan: Array = plans.get(sq.id, [])
		_execute_pack(sq, plan, result, dry)
		if plan.is_empty() and stalled.has(sq.id):
			result.stalled.append(sq.id)
			if not dry:
				log.append("%s has no way through and waits" % sq.display_name)


## Run `fn` with the machines that move before `u` (earlier in `routes`, or all of them
## when `u` has no route yet) standing at their destinations, then put them back. This is
## the view a route is planned in, so plotting in order can never conflict at resolve.
func with_plan(u: Unit, routes: Dictionary, fn: Callable) -> Variant:
	var saved: Dictionary = {}
	var before := not routes.has(u.id)
	for uid in routes.keys():
		if uid == u.id:
			before = false
			continue
		if not before:
			continue
		var o := unit_by_id(uid)
		var r: Array = routes[uid]
		if o == null or r.is_empty():
			continue
		saved[uid] = o.pos
		o.pos = r[r.size() - 1]
	var out: Variant = fn.call()
	for uid in saved.keys():
		unit_by_id(uid).pos = saved[uid]
	return out


func _apply_route(u: Unit, route: Array) -> bool:
	if route_cost(u, route) < 0:
		return false
	var cur: Vector2i = route[route.size() - 1] if not route.is_empty() else u.pos
	if cur != u.pos:
		u.facing = _direction_index(route[route.size() - 2] if route.size() >= 2 else u.pos, cur)
	u.pos = cur
	return true


func _direction_index(from: Vector2i, to: Vector2i) -> int:
	var d := to - from
	for i in range(Hex.DIRECTIONS.size()):
		if Hex.DIRECTIONS[i] == d:
			return i
	return 0


func _execute_pack(sq: Unit, path: Array, result: PhaseResult, dry: bool = false) -> void:
	var budget := sq.movespeed
	var landed := sq.pos
	var prev := sq.pos
	for step in path:
		var s: Vector2i = step
		if map.gate_hexes.has(s):
			var dmg := maxi(10, (sq.strength * 10) / 3)
			result.gate_damage += dmg
			if not dry:
				gate_hp = maxi(0, gate_hp - dmg)
				log.append("%s hits the gate for %d" % [sq.display_name, dmg])
			break
		var occ := unit_at(s)
		if occ != null and occ != sq and (occ.can_block() or occ.is_enemy()):
			result.blocked.append(sq.id)
			result.blockers[sq.id] = occ.id
			if not dry:
				log.append("%s blocked at %s by %s" % [sq.display_name, str(s), occ.display_name])
			break
		if sq.is_multi_hex() and not can_stand(sq, s, true):
			result.blocked.append(sq.id)
			if not dry:
				log.append("%s cannot fit at %s" % [sq.display_name, str(s)])
			break
		var c := BattleMap.spend(map.terrain[s], sq.traits, budget)
		if c < 0:
			break
		budget -= c
		# A flyer's hex is passed through but never landed on.
		if occ == null or occ == sq:
			landed = s
			sq.facing = _direction_index(prev, s)
		prev = s
	sq.pos = landed


## Contact groups (decided 1 October). Every pack has an engagement zone (`Unit.zone`, from
## its foe type), and a machine standing inside it where the pack ends its move fights it.
## A machine inside two packs' zones puts both packs in one fight, and that is the only way
## fights join: packs never join through each other and machines never through each other,
## so nothing chains and the zones drawn on the map are the whole rule. A flyer fights by
## the zone like anyone; its difference is that it cannot stop a pack. A stealth machine is
## never pulled in by a zone alone: it is in the fight when it stopped one of its packs in
## its path (`blockers`, the trait's join rule of 28 September), or when another machine is
## in it. A static defence inside a zone is in the fight too. Packs come first in a group,
## since the fight's ground is its first pack's hex. `blockers` says which unit stopped
## which pack this phase.
func detect_skirmishes(blockers: Dictionary = {}) -> Array:
	var groups: Array = []
	var seen := {}
	var open_mechs: Array[Unit] = []   # machines a zone pulls in on its own
	var shy: Array[Unit] = []          # stealth machines and static defences: join on their own terms
	for u in units:
		if not u.is_player():
			continue
		if u.is_static() or u.traits.has("stealth"):
			shy.append(u)
		else:
			open_mechs.append(u)
	for sq in packs():
		if seen.has(sq.id):
			continue
		var group_packs: Array[Unit] = []
		var group_mechs: Array[Unit] = []
		var queue: Array[Unit] = [sq]
		seen[sq.id] = true
		while not queue.is_empty():
			var cur: Unit = queue.pop_front()
			if cur.is_enemy():
				group_packs.append(cur)
				for m in open_mechs:
					if not seen.has(m.id) and in_zone(cur, m):
						seen[m.id] = true
						queue.append(m)
				for m in shy:
					# A stealth machine that stopped this pack is in, whoever else is.
					if not seen.has(m.id) and m.traits.has("stealth") and in_zone(cur, m) and int(blockers.get(cur.id, -1)) == m.id:
						seen[m.id] = true
						queue.append(m)
			else:
				group_mechs.append(cur)
				for p in packs():
					if not seen.has(p.id) and in_zone(p, cur):
						seen[p.id] = true
						queue.append(p)
		if group_mechs.is_empty():
			for p in group_packs:
				seen.erase(p.id)   # no fight here; the packs stay free for nothing
			continue
		var has_ally := false
		for m in group_mechs:
			has_ally = has_ally or not m.traits.has("stealth")
		for m in shy:
			if seen.has(m.id):
				continue
			var inside := false
			for p in group_packs:
				inside = inside or in_zone(p, m)
			# A defence inside the zone is in; a stealth machine only beside an ally.
			if inside and (m.is_static() or has_ally):
				seen[m.id] = true
				group_mechs.append(m)
		var group: Array[Unit] = []
		group.append_array(group_packs)
		group.append_array(group_mechs)
		groups.append(group)
	return groups


## Whether `u` stands inside the pack's engagement zone.
static func in_zone(sq: Unit, u: Unit) -> bool:
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
func apply_skirmish_result(sk: Skirmish) -> void:
	for ms in sk.mechs:
		if ms.unit.hull <= 0:
			log.append("%s is wrecked" % ms.unit.display_name)
			units.erase(ms.unit)
	for sq in sk.packs:
		var left := sk.survivors_for(sq)
		if left <= 0:
			log.append("%s destroyed" % sq.display_name)
			units.erase(sq)
		else:
			sq.strength = left
	tick_pressure(sk.round)
