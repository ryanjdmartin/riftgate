class_name Battlefield
extends RefCounted

## Battlefield state and phase resolution. Pure: no scenes, no signals, no rendering.
##
## A phase:
##   1. compute_intents()          enemy destinations are previewed for the player
##   2. player plots routes        (outside the sim)
##   3. resolve_phase(routes)      player routes resolve first, then packs execute their
##                                 previewed moves and stop at the first blocked hex
##   4. detect_skirmishes()        contacts: touching units that mix both sides, plus every
##                                 grounded machine within ENGAGE_RANGE of a member
##
## Units may cover several hexes (Unit.footprint). Every footprint hex blocks, touches, and
## counts as occupied. The gate and the rift are structures wider than one hex; nobody stands
## on them and packs strike any gate hex.

class PhaseResult:
	var moved: Array[int] = []        # unit ids that moved
	var rejected: Array[int] = []     # unit ids whose route was invalid
	var blocked: Array[int] = []      # pack ids stopped by a body block
	var intercepted: Array[int] = []  # pack ids stopped by a mech's control of the ground beside it
	var intents: Dictionary = {}      # pack id -> the path it followed, planned after the mechs moved
	var gate_damage: int = 0
	var spawned: bool = false
	var skirmishes: Array = []        # Array of Array[Unit]

## How far a machine may stand from a fight and still be in it (Ryan, 28 September: a contact
## made of touching units turned three slow walkers into a placement puzzle). Zone of control
## stays at one hex: a contact still seeds where a pack and a machine touch.
const ENGAGE_RANGE := 2

var map: BattleMap
var units: Array[Unit] = []
var gate_hp: int = 200
var gate_hp_max: int = 200
var rift_pressure: int = 0
var rift_pressure_max: int = 12
var spawn_faction: String = "undead"
## Packs the rift sends, cycled: [[foe_id, strength], ...]. The game fills this from content.
var spawn_table: Array = [["ghoul", 6]]
var _spawn_index: int = 0
var phase: int = 0
var intents: Dictionary = {}   # pack id -> Array[Vector2i], the affordable part of its path
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
## adjacent to the last and standable, the whole within its movespeed. The rule Resolve
## applies, asked ahead of time.
func route_cost(u: Unit, route: Array) -> int:
	var cost := 0
	var cur := u.pos
	for step in route:
		var s: Vector2i = step
		if not Hex.are_adjacent(cur, s) or not can_stand(u, s):
			return -1
		cost += BattleMap.move_cost(map.terrain[s], u.traits)
		if cost > u.movespeed:
			return -1
		cur = s
	return cost


## Dijkstra from `from`, bounded by `budget` move points. Returns [dist, prev].
func _search(u: Unit, from: Vector2i, budget: int) -> Array:
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
			if not map.has(n) or not can_stand(u, n):
				continue
			var nd := d + BattleMap.move_cost(map.terrain[n], u.traits)
			if nd > budget:
				continue
			if not dist.has(n) or nd < dist[n]:
				dist[n] = nd
				prev[n] = h
				frontier.append([nd, n])
	return [dist, prev]


## Where each pack intends to go this phase. Paths ignore mechs, so what the player sees is
## "where they go unless you stop them". Other packs' current hexes are avoided.
func compute_intents() -> void:
	# Packs plan in field order, each around where the packs before it will end and
	# where the ones after it stand now (Ryan, 22 September), so a pack routes around a
	# hex another is taking instead of walking into it and stopping short. The same order
	# moves them at resolve, so an intent plays as shown unless a mech blocks it.
	intents.clear()
	var ends: Dictionary = {}   # pack id -> hexes it will hold, for the packs after it
	for sq in packs():
		var target := _pick_target(sq)
		var blocked := {}
		for other in packs():
			if other == sq:
				continue
			var held: Array = ends[other.id] if ends.has(other.id) else other.hexes()
			for h in held:
				blocked[h] = true
		var ignores_control := sq.elite and sq.strength == 0   # the boss guards; nothing herds it
		if not ignores_control and controlled(sq.pos):
			# Already under a machine's guns: it holds its ground, and the contact is this
			# phase's fight. Nothing ambiguous to preview.
			var none: Array[Vector2i] = []
			intents[sq.id] = none
			ends[sq.id] = sq.hexes()
			continue
		# Packs plan blind to the machines (Ryan, 22 September: a plot never makes a pack
		# swerve; the enemy's path is stable and only where it is cut changes). Control cuts
		# the affordable path at the first controlled hex, where the pack will stop.
		var full := map.find_path(sq.pos, target, sq.traits, blocked)
		var path := _affordable(sq, full)
		if not ignores_control:
			for i in range(path.size()):
				if controlled(path[i]) and not map.gate_hexes.has(path[i]):
					path = path.slice(0, i + 1)
					break
		intents[sq.id] = path
		var end: Vector2i = sq.pos
		for step in path:
			if map.gate_hexes.has(step) or (unit_at(step) != null and unit_at(step).is_player() and unit_at(step).can_block()):
				break   # a strike, not a move
			end = step
		var held_now: Array = []
		for o in sq.footprint:
			held_now.append(end + o)
		ends[sq.id] = held_now


## Where a pack heads this phase. A boss patrols its zone outside the rift (Ryan, 22
## September): one step to a standable hex within BOSS_ZONE of the rift, picked by the
## phase so the preview never disagrees with the resolve; nothing, when nothing fits.
const BOSS_ZONE := 2

func _pick_target(sq: Unit) -> Vector2i:
	if sq.elite and sq.strength == 0 and not sq.aggro:
		var options: Array[Vector2i] = []
		for n in Hex.neighbors(sq.pos):
			if map.has(n) and Hex.distance(n, map.rift) <= BOSS_ZONE and can_stand(sq, n) and not map.rift_hexes.has(n):
				options.append(n)
		if options.is_empty():
			return sq.pos
		return options[(phase * 7 + sq.id * 13) % options.size()]
	if sq.aggro:
		var best: Unit = null
		for m in mechs():
			if best == null or Hex.distance(sq.pos, m.pos) < Hex.distance(sq.pos, best.pos):
				best = m
		if best != null:
			return best.pos
	var target := map.gate
	var best_d := Hex.distance(sq.pos, target)
	for g in map.gate_hexes:
		if Hex.distance(sq.pos, g) < best_d:
			best_d = Hex.distance(sq.pos, g)
			target = g
	for d in defenses():
		if Hex.distance(sq.pos, d.pos) < best_d:
			best_d = Hex.distance(sq.pos, d.pos)
			target = d.pos
	return target


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
		var c := BattleMap.move_cost(map.terrain[step], sq.traits)
		if c > budget:
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
	result.skirmishes = detect_skirmishes()
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
	result.skirmishes = detect_skirmishes()
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
	# The packs plan against where the machines now stand (Ryan, 22 September: a route
	# that cuts a pack off must show in that pack's path before Resolve), so their
	# intents are recomputed here, in the preview and the resolve alike.
	compute_intents()
	result.intents = intents.duplicate(true)
	for sq in packs():
		_execute_pack(sq, result, dry)


## Whether a grounded machine controls `h`: a pack that steps beside a mech stops there
## (decided 22 September). A flyer controls nothing; its edge is speed, and it engages by
## ending beside a pack.
func controlled(h: Vector2i) -> bool:
	for m in mechs():
		# A flyer controls nothing; nor does a stealth machine (28 September): packs walk past it.
		if m.traits.has("flyer") or m.traits.has("stealth"):
			continue
		if Hex.distance(m.pos, h) == 1:
			return true
	return false


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


func _execute_pack(sq: Unit, result: PhaseResult, dry: bool = false) -> void:
	var path: Array = intents.get(sq.id, [])
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
			if not dry:
				log.append("%s blocked at %s by %s" % [sq.display_name, str(s), occ.display_name])
			break
		if sq.is_multi_hex() and not can_stand(sq, s, true):
			result.blocked.append(sq.id)
			if not dry:
				log.append("%s cannot fit at %s" % [sq.display_name, str(s)])
			break
		var c := BattleMap.move_cost(map.terrain[s], sq.traits)
		if c > budget:
			break
		budget -= c
		# A flyer's hex is passed through but never landed on.
		if occ == null or occ == sq:
			landed = s
			sq.facing = _direction_index(prev, s)
		prev = s
		if controlled(s) and not (sq.elite and sq.strength == 0):
			result.intercepted.append(sq.id)
			if not dry:
				log.append("%s stopped at %s, under a machine's guns" % [sq.display_name, str(s)])
			break
	sq.pos = landed


## Contact groups. A fight seeds where units touch: connected groups of adjacent units with a
## unit from each side, which is the zone-of-control contract (a pack stops beside a machine,
## and a machine two hexes from a lone pack is no fight). Then the engagement range: every
## grounded machine within ENGAGE_RANGE of any member joins, the nearest group first, until
## nothing more joins, so a machine two hexes behind a joined one is in as well (Ryan, 28
## September). A stealth machine is never pulled in by range; it fights only what it touches.
func detect_skirmishes() -> Array:
	var groups: Array = []
	var seen := {}
	for u in units:
		if seen.has(u.id):
			continue
		var group: Array[Unit] = []
		var queue: Array[Unit] = [u]
		seen[u.id] = true
		while not queue.is_empty():
			var cur: Unit = queue.pop_front()
			group.append(cur)
			for other in units:
				if not seen.has(other.id) and cur.touches(other):
					seen[other.id] = true
					queue.append(other)
		var has_player := false
		var has_enemy := false
		for g in group:
			has_player = has_player or g.is_player()
			has_enemy = has_enemy or g.is_enemy()
		if has_player and has_enemy:
			groups.append(group)
	if groups.is_empty():
		return groups
	var placed := {}
	for g in groups:
		for m in g:
			placed[m.id] = true
	var joined := true
	while joined:
		joined = false
		for m in mechs():
			if placed.has(m.id) or m.traits.has("stealth"):
				continue
			var best := -1
			var best_d := ENGAGE_RANGE + 1
			for i in range(groups.size()):
				for member in groups[i]:
					var d := unit_distance(m, member)
					if d < best_d:
						best_d = d
						best = i
			if best >= 0:
				(groups[best] as Array).append(m)
				placed[m.id] = true
				joined = true
	return groups


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
	var sq := Unit.pack(0, "%s pack" % str(entry[0]), at, spawn_faction, 2, int(entry[1]), str(entry[0]))
	add_unit(sq)
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
