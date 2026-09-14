class_name Battlefield
extends RefCounted

## Battlefield state and phase resolution. Pure: no scenes, no signals, no rendering.
##
## A phase:
##   1. compute_intents()          enemy destinations are previewed for the player
##   2. player plots routes        (outside the sim)
##   3. resolve_phase(routes)      player routes resolve first, then squads execute their
##                                 previewed moves and stop at the first blocked hex
##   4. detect_skirmishes()        connected groups of touching units that mix both sides
##
## Units may cover several hexes (Unit.footprint). Every footprint hex blocks, touches, and
## counts as occupied. The gate and the rift are structures wider than one hex; nobody stands
## on them and squads strike any gate hex.

class PhaseResult:
	var moved: Array[int] = []        # unit ids that moved
	var rejected: Array[int] = []     # unit ids whose route was invalid
	var blocked: Array[int] = []      # squad ids stopped by a body block
	var gate_damage: int = 0
	var spawned: bool = false
	var skirmishes: Array = []        # Array of Array[Unit]

var map: BattleMap
var units: Array[Unit] = []
var gate_hp: int = 20
var gate_hp_max: int = 20
var rift_pressure: int = 0
var rift_pressure_max: int = 12
var spawn_faction: String = "undead"
var phase: int = 0
var intents: Dictionary = {}   # squad id -> Array[Vector2i], the affordable part of its path
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


func squads() -> Array[Unit]:
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
## `ignore_flyers` is set (squads pass through them).
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
	var dist := {u.pos: 0}
	var frontier: Array = [[0, u.pos]]
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
			if nd > u.movespeed:
				continue
			if not dist.has(n) or nd < dist[n]:
				dist[n] = nd
				frontier.append([nd, n])
	dist.erase(u.pos)
	return dist


## Where each squad intends to go this phase. Paths ignore mechs, so what the player sees is
## "where they go unless you stop them". Other squads' current hexes are avoided.
func compute_intents() -> void:
	intents.clear()
	for sq in squads():
		var target := _pick_target(sq)
		var blocked := {}
		for other in squads():
			if other != sq:
				for h in other.hexes():
					blocked[h] = true
		var full := map.find_path(sq.pos, target, sq.traits, blocked)
		intents[sq.id] = _affordable(sq, full)


func _pick_target(sq: Unit) -> Vector2i:
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
		if map.gate_hexes.has(step) or (occ != null and occ.is_player()):
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
	for uid in routes.keys():
		var u := unit_by_id(uid)
		if u == null or not u.is_player() or u.is_static():
			result.rejected.append(uid)
			continue
		if _apply_route(u, routes[uid]):
			result.moved.append(uid)
		else:
			result.rejected.append(uid)
			log.append("%s: route rejected" % u.display_name)
	for sq in squads():
		_execute_squad(sq, result)
	result.spawned = tick_pressure(1)
	result.skirmishes = detect_skirmishes()
	return result


func _apply_route(u: Unit, route: Array) -> bool:
	var cost := 0
	var cur := u.pos
	for step in route:
		var s: Vector2i = step
		if not Hex.are_adjacent(cur, s) or not can_stand(u, s):
			return false
		cost += BattleMap.move_cost(map.terrain[s], u.traits)
		if cost > u.movespeed:
			return false
		cur = s
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


func _execute_squad(sq: Unit, result: PhaseResult) -> void:
	var path: Array = intents.get(sq.id, [])
	var budget := sq.movespeed
	var landed := sq.pos
	var prev := sq.pos
	for step in path:
		var s: Vector2i = step
		if map.gate_hexes.has(s):
			var dmg := maxi(1, sq.strength / 3)
			gate_hp = maxi(0, gate_hp - dmg)
			result.gate_damage += dmg
			log.append("%s hits the gate for %d" % [sq.display_name, dmg])
			break
		var occ := unit_at(s)
		if occ != null and occ != sq and (occ.can_block() or occ.is_enemy()):
			result.blocked.append(sq.id)
			log.append("%s blocked at %s by %s" % [sq.display_name, str(s), occ.display_name])
			break
		if sq.is_multi_hex() and not can_stand(sq, s, true):
			result.blocked.append(sq.id)
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
	sq.pos = landed


## Connected groups of touching units that contain at least one unit from each side.
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
	return groups


## Feed the Rift Pressure clock. Spawns a squad at the rift when it fills. Returns true on spawn.
func tick_pressure(ticks: int) -> bool:
	rift_pressure += ticks
	if rift_pressure < rift_pressure_max:
		return false
	rift_pressure -= rift_pressure_max
	var at := nearest_free(map.rift, [])
	var sq := Unit.squad(0, "%s reinforcements" % spawn_faction, at, spawn_faction)
	add_unit(sq)
	log.append("Rift pressure peaks: %s emerge at %s" % [sq.display_name, str(at)])
	return true


## Apply a finished skirmish back to the map: survivors keep marching, wrecks are removed.
func apply_skirmish_result(sk: Skirmish) -> void:
	for ms in sk.mechs:
		if ms.unit.hull <= 0:
			log.append("%s is wrecked" % ms.unit.display_name)
			units.erase(ms.unit)
	for sq in sk.squads:
		var left := sk.survivors_for(sq)
		if left <= 0:
			log.append("%s destroyed" % sq.display_name)
			units.erase(sq)
		else:
			sq.strength = left
	tick_pressure(sk.round)
