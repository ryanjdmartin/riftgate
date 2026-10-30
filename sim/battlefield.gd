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
	var catches: int = 0             # a hunter whose walk ends with what it comes for inside its ring: that machine's id
	var prey: int = 0                # what a hunter comes for this turn, by id: its prey, or the machine it takes when its prey is sealed off (catch_of)

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
		# A winged foe's pack crosses water and crags as a flyer does and stands there (Ryan,
		# 28 October, the movement proposal's lever 2); the boss is never winged.
		var winged := bool(p.get("winged", false))
		# A composition (the foes' fresh start, 30 October): it walks by its lead, at its slowest
		# member's pace, with the largest of its members' rings, and is winged only when every
		# member is, since a walker among them cannot cross water.
		for m in sq.members:
			var mp: Dictionary = foe_profiles.get(str(m[0]), {})
			sq.zone = maxi(sq.zone, int(mp.get("zone", 1)))
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
		if Effects.never_hunted(m):
			continue
		var key := _prey_key(sq, m)
		if best == null or key < best_key:
			best = m
			best_key = key
	sq.prey = best.id if best != null else 0
	return best


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
		if _distance_from(sq, h, prey) <= sq.zone and _landable(sq, h, {}):
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
		if m == prey or Effects.never_hunted(m) or _distance_from(sq, at, m) > sq.zone:
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
		var best_key := Vector2i(maxi(_distance_from(sq, sq.pos, prey) - sq.zone, 0), 0)
		for h in dist.keys():
			var hx: Vector2i = h
			if not _landable(sq, hx, blocked):
				continue
			var key := Vector2i(maxi(_distance_from(sq, hx, prey) - sq.zone, 0), int(dist[hx]))
			if key.x < best_key.x or (key.x == best_key.x and key.y < best_key.y):
				best_key = key
				goal = hx
	elif not on_apron(sq, sq.pos):
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
	w.end = walked[walked.size() - 1] if not walked.is_empty() else sq.pos
	w.strikes = prey == null and on_apron(sq, w.end)
	if prey != null and _distance_from(sq, w.end, prey) <= sq.zone:
		w.catches = prey.id
	return w


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
			var dmg := maxi(10, (sq.strength * 10) / 3)
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
## and that fight comes first on the player's turn. One fight per caught machine, with every
## hunter that caught it, in field order: [{"prey": Unit, "hunters": Array[Unit]}].
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
	# Named as the setup names its packs, by the foe's shown name (the mechanics audit's 30: a
	# spawn was named by its content id, "zombie_knight pack").
	var shown := str(foe_profiles.get(str(entry[0]), {}).get("name", entry[0])).to_lower()
	var sq := Unit.pack(0, "%s pack" % shown, at, fac, Unit.PACK_MOVE, int(entry[1]), str(entry[0]))
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
