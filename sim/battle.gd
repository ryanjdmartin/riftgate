class_name Battle
extends RefCounted

## One battle, from the first phase until the gate falls, every machine is wrecked, or the
## boss powering the rift dies. Owns the battlefield, the routes the player is plotting, and
## the skirmishes that contact opens. Pure: the battle screen drives it, tests drive it
## headless.
##
## Loop:
##   PLAN      set_route() for any mech, then commit() resolves the phase
##   SKIRMISH  contact groups wait in `pending`; open_next_skirmish() builds one, the screen
##             plays it, finish_skirmish() applies it back to the map, repeat until empty
##   DONE      outcome is set
##
## Shields recharge fully between skirmishes; hull never repairs during a battle; damaged
## faces persist on the unit.

enum State { PLAN, SKIRMISH, DONE }
enum Outcome { NONE, VICTORY, GATE_FALLEN, WRECKED }

const SQUAD_SPEED := 2
const BOSS_SPEED := 1
const DEFAULT_WIDTH := 7
const DEFAULT_HEIGHT := 20

var seed_value: int = 1
var rng := RandomNumberGenerator.new()
var db: ContentDB
var map: BattleMap
var field: Battlefield
var faction: String = ""
var boss: Unit = null
var state: int = State.PLAN
var outcome: int = Outcome.NONE
var routes: Dictionary = {}     # mech id -> Array[Vector2i]
var pending: Array = []         # contact groups (Array[Unit]) waiting for a skirmish
var boss_contact := false       # this phase's contact is the boss's: one fight, every machine in it
var current: Skirmish = null
var last_result: Battlefield.PhaseResult = null
var skirmishes_fought: int = 0
var columns: int = Skirmish.DEFAULT_COLUMNS   # formation width for every skirmish this battle opens


func _init(seed_arg: int = 1) -> void:
	seed_value = seed_arg
	rng.seed = seed_arg
	db = ContentDB.load_default()


# ---------------------------------------------------------------- setup

## Generate the map, stand the team in front of the gate, place the faction's formation in the
## north third of the field and its boss just south of the rift, then preview the first enemy
## moves.
func setup(team: Array, faction_id: String = "", w: int = DEFAULT_WIDTH, h: int = DEFAULT_HEIGHT) -> void:
	faction = faction_id if not faction_id.is_empty() else db.default_faction()
	map = BattleMap.generate(w, h, seed_value)
	field = Battlefield.new(map)
	field.spawn_faction = faction
	field.spawn_table = db.spawn_table(faction)
	var gate_o := Hex.axial_to_offset(map.gate)
	var i := 0
	var face_rng := RandomNumberGenerator.new()
	face_rng.seed = seed_value * 7 + 3
	for u in team:
		var want := Hex.offset_to_axial(gate_o.x - 1 + i, gate_o.y - BattleMap.GATE_ROWS)
		u.pos = field.nearest_standable(u, want)
		u.facing = face_rng.randi_range(1, 2)   # northward, one of the two directions that lead away from the gate
		field.add_unit(u)
		i += 1
	var table: Array = field.spawn_table
	for j in range(table.size()):
		var entry: Array = table[j]
		var col := (w * (j + 1)) / (table.size() + 1)
		var row := 3 + (j % 3)
		var sq := Unit.squad(0, _squad_name(str(entry[0])), Vector2i.ZERO, faction, SQUAD_SPEED, int(entry[1]), str(entry[0]))
		sq.pos = field.nearest_standable(sq, Hex.offset_to_axial(col, row))
		field.add_unit(sq)
	var fac: Dictionary = db.factions.get(faction, {})
	var boss_id := str(fac.get("boss", ""))
	if db.foes.has(boss_id):
		boss = Unit.boss(0, str(db.foes[boss_id]["name"]).to_lower(), Vector2i.ZERO, faction, BOSS_SPEED)
		boss.pos = field.nearest_standable(boss, Hex.offset_to_axial(w / 2 - 1, 1))
		field.add_unit(boss)
	field.compute_intents()
	state = State.PLAN


func _squad_name(foe_id: String) -> String:
	if db.foes.has(foe_id):
		return "%s squad" % str(db.foes[foe_id]["name"]).to_lower()
	return "%s squad" % foe_id


# ---------------------------------------------------------------- planning

func mechs() -> Array[Unit]:
	return field.mechs()


## Hexes a mech may end this phase on. Planned in plot order (Ryan, 22 September): the
## machines plotted before it stand at their destinations, the ones after it where they
## are, so a route can pass where an earlier machine is leaving and never where one is
## going, and Resolve can never reject it. Other claimed destinations are out too.
func destinations_for(u: Unit) -> Dictionary:
	var out: Dictionary = field.with_plan(u, routes, func() -> Dictionary: return field.reachable(u))
	for uid in routes.keys():
		if uid == u.id:
			continue
		var r: Array = routes[uid]
		if not r.is_empty():
			out.erase(r[r.size() - 1])
	return out


## Plot the cheapest route to `to`, in the same planned view. The mech's own hex clears its
## route. False when the hex is out of reach or claimed. A re-plot puts the mech last in
## the order (Ryan, 22 September: the last thing plotted moves last), so it is planned
## against everyone else's destination; any route the change still breaks is dropped and
## logged, so the plan is always one Resolve will play exactly.
func set_route(u: Unit, to: Vector2i) -> bool:
	if state != State.PLAN:
		return false
	routes.erase(u.id)
	if to == u.pos:
		_drop_conflicts()
		return true
	if not destinations_for(u).has(to):
		return false
	var route: Array = field.with_plan(u, routes, func() -> Array: return field.route_to(u, to))
	if route.is_empty():
		return false
	routes[u.id] = route
	_drop_conflicts()
	return true


## A route drawn by hand, kept as drawn (Ryan, 25 September: tap-to-destination alone
## could not say which way round a squad to walk). Legal on the same terms as a tapped
## one, planned last like a re-plot: every step adjacent and standable in the planned
## view, the cost within the machine's move, and its last hex nobody else's destination.
## An empty route clears. False when refused, and the machine's old route is gone either way.
func set_route_path(u: Unit, route: Array) -> bool:
	if state != State.PLAN:
		return false
	routes.erase(u.id)
	if route.is_empty():
		_drop_conflicts()
		return true
	var end: Vector2i = route[route.size() - 1]
	if not destinations_for(u).has(end):
		return false
	var cost: int = field.with_plan(u, routes, func() -> int: return field.route_cost(u, route))
	if cost < 0:
		return false
	var typed: Array[Vector2i] = []
	for s in route:
		typed.append(s)
	routes[u.id] = typed
	_drop_conflicts()
	return true


## One step of drawing a route by hand: `draft` is the route so far (hexes after the
## machine's own), `h` the hex the finger has reached. Back on the machine clears; a hex
## already on the draft cuts it back to there; anything else is joined by the cheapest
## continuation that fits the move left (a finger that skips a hex still draws a walkable
## route), or the draft stands when nothing fits. Planned as a re-plot: the machine last.
func draft_step(u: Unit, draft: Array, h: Vector2i) -> Array:
	if h == u.pos:
		return []
	var at := draft.find(h)
	if at >= 0:
		return draft.slice(0, at + 1)
	var others := routes.duplicate()
	others.erase(u.id)
	var end: Vector2i = draft[draft.size() - 1] if not draft.is_empty() else u.pos
	var ext: Array = field.with_plan(u, others, func() -> Array:
		var spent := field.route_cost(u, draft)
		if spent < 0:
			return []
		return field.route_from(u, end, u.movespeed - spent, h))
	if ext.is_empty():
		return draft
	var out: Array = draft.duplicate()
	out.append_array(ext)
	return out


## What a draft costs so far in the same planned view; -1 when it cannot be walked.
func draft_cost(u: Unit, draft: Array) -> int:
	var others := routes.duplicate()
	others.erase(u.id)
	return field.with_plan(u, others, func() -> int: return field.route_cost(u, draft))


func clear_route(uid: int) -> void:
	routes.erase(uid)
	_drop_conflicts()


## After a change, any route the plan would now reject is dropped, with a line in the log.
func _drop_conflicts() -> void:
	var res: Battlefield.PhaseResult = field.preview_phase(routes)["result"]
	for uid in res.rejected:
		if routes.has(uid):
			routes.erase(uid)
			var u := field.unit_by_id(uid)
			if u != null:
				field.log.append("%s: route cleared, the plan changed under it" % u.display_name)


func clear_routes() -> void:
	routes.clear()


func route_for(uid: int) -> Array:
	return routes.get(uid, [])


## Where the mech will stand after the phase: the end of its route, or where it is.
func route_end(u: Unit) -> Vector2i:
	var r: Array = routes.get(u.id, [])
	return r[r.size() - 1] if not r.is_empty() else u.pos


# ---------------------------------------------------------------- resolution

## Resolve the phase with the plotted routes. Contact groups queue up as skirmishes.
func commit() -> Battlefield.PhaseResult:
	if state != State.PLAN:
		return null
	last_result = field.resolve_phase(routes)
	routes.clear()
	pending = last_result.skirmishes.duplicate()
	boss_contact = _take_boss_contact()
	# A phase spent out of combat recharges shield at the field rate. A mech in contact this
	# phase gets nothing here: its skirmish is its phase, and it recharges only at the combat
	# rate inside it. So withdrawing buys a slower recharge, not a reset.
	var engaged := {}
	for group in pending:
		for u in group:
			engaged[u] = true
	for u in field.mechs():
		if not engaged.has(u):
			u.recharge_shield(u.recharge_field)
	_after_phase()
	return last_result


## The boss's contact takes the phase (Ryan, 25 September): when any contact group holds the
## boss, the phase has one fight, every machine on the field against the boss alone, and
## the other contacts are dropped, squads in the boss's own group included. The player's
## positioning no longer matters once the boss is reached; the fight is the battle's end
## or a withdrawal. True when it happened; `pending` is then that one group.
func _take_boss_contact() -> bool:
	if boss == null:
		return false
	var found := false
	for group in pending:
		if group.has(boss):
			found = true
			break
	if not found:
		return false
	var group: Array = []
	for m in field.mechs():
		if not m.is_static():
			group.append(m)
	group.append(boss)
	pending = [group]
	return true


func has_pending() -> bool:
	return not pending.is_empty()


## Build the next contact group's skirmish. Null when nothing is left to fight, in which case
## the battle has moved on to the next plan (or ended).
func open_next_skirmish() -> Skirmish:
	return open_skirmish_at(0)


## Open the pending contact at `index` (the player's choice of which to fight first, Ryan,
## 22 September); the rest wait. Null when nothing is left to fight, in which case the
## battle has moved on.
func open_skirmish_at(index: int) -> Skirmish:
	while not pending.is_empty():
		var i := clampi(index, 0, pending.size() - 1)
		var group: Array = pending.pop_at(i)
		index = 0
		var sk := _build_skirmish(group)
		if sk != null:
			current = sk
			skirmishes_fought += 1
			return sk
	_after_phase()
	return null


## The mechs of the group fight every foe the group's squads unpack into.
## The hex a contact is fought on (decided 22 September): the squad's, since the fight
## opens where the squad stands and its ground has already gone flat; with several
## squads, the first in field order, the one the contact names first. One rule, used by
## the skirmish's terrain, the handover's spread and every label, so the ground is never
## ambiguous.
static func ground_hex(group: Array) -> Vector2i:
	for u in group:
		if u.is_enemy():
			return u.pos
	return (group[0] as Unit).pos if not group.is_empty() else Vector2i.ZERO


func ground_terrain(group: Array) -> int:
	return int(map.terrain.get(ground_hex(group), BattleMap.Terrain.PLAIN))


func _build_skirmish(group: Array) -> Skirmish:
	var sk := Skirmish.new(rng.randi(), columns)
	sk.terrain = ground_terrain(group)
	for u in group:
		if not field.units.has(u):
			continue
		if u.is_player() and not u.is_static():
			sk.add_mech(u)
		elif u.is_enemy():
			sk.add_foes(db.foes_for(u), u)
	if sk.mechs.is_empty() or sk.reinforcements.is_empty():
		return null
	return sk


## Apply the finished skirmish: wrecks leave the map, squads shrink or vanish, and Rift
## Pressure ticks once per round fought. Shields do not refill here: survivors carry what
## they had, and recharge at the field rate only in phases they spend out of combat.
func finish_skirmish() -> void:
	if current == null:
		return
	field.apply_skirmish_result(current)
	current = null
	boss_contact = false
	if _check_outcome():
		pending.clear()
		return
	if pending.is_empty():
		_after_phase()


func _after_phase() -> void:
	if _check_outcome():
		return
	if not pending.is_empty():
		state = State.SKIRMISH
		return
	field.compute_intents()
	state = State.PLAN


func _check_outcome() -> bool:
	if field.gate_hp <= 0:
		outcome = Outcome.GATE_FALLEN
	elif field.mechs().is_empty():
		outcome = Outcome.WRECKED
	elif boss != null and not field.units.has(boss):
		outcome = Outcome.VICTORY
	if outcome != Outcome.NONE:
		for u in field.mechs():
			Effects.end_battle(u)
		state = State.DONE
		return true
	return false
