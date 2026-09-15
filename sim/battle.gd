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
var faction: String = "undead"
var boss: Unit = null
var state: int = State.PLAN
var outcome: int = Outcome.NONE
var routes: Dictionary = {}     # mech id -> Array[Vector2i]
var pending: Array = []         # contact groups (Array[Unit]) waiting for a skirmish
var current: Skirmish = null
var last_result: Battlefield.PhaseResult = null
var skirmishes_fought: int = 0


func _init(seed_arg: int = 1) -> void:
	seed_value = seed_arg
	rng.seed = seed_arg
	db = ContentDB.load_default()


# ---------------------------------------------------------------- setup

## Generate the map, stand the team in front of the gate, place the faction's formation in the
## north third of the field and its boss just south of the rift, then preview the first enemy
## moves.
func setup(team: Array, faction_id: String = "undead", w: int = DEFAULT_WIDTH, h: int = DEFAULT_HEIGHT) -> void:
	faction = faction_id
	map = BattleMap.generate(w, h, seed_value)
	field = Battlefield.new(map)
	field.spawn_faction = faction
	field.spawn_table = db.spawn_table(faction)
	var gate_o := Hex.axial_to_offset(map.gate)
	var i := 0
	for u in team:
		var want := Hex.offset_to_axial(gate_o.x - 1 + i, gate_o.y - 1)
		u.pos = field.nearest_standable(u, want)
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


## Hexes a mech may end this phase on, minus the destinations other mechs already claimed.
func destinations_for(u: Unit) -> Dictionary:
	var out := field.reachable(u)
	for uid in routes.keys():
		if uid == u.id:
			continue
		var r: Array = routes[uid]
		if not r.is_empty():
			out.erase(r[r.size() - 1])
	return out


## Plot the cheapest route to `to`. The mech's own hex clears its route. False when the hex
## is out of reach or claimed.
func set_route(u: Unit, to: Vector2i) -> bool:
	if state != State.PLAN:
		return false
	if to == u.pos:
		routes.erase(u.id)
		return true
	if not destinations_for(u).has(to):
		return false
	var route := field.route_to(u, to)
	if route.is_empty():
		return false
	routes[u.id] = route
	return true


func clear_route(uid: int) -> void:
	routes.erase(uid)


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
	_after_phase()
	return last_result


func has_pending() -> bool:
	return not pending.is_empty()


## Build the next contact group's skirmish. Null when nothing is left to fight, in which case
## the battle has moved on to the next plan (or ended).
func open_next_skirmish() -> Skirmish:
	while not pending.is_empty():
		var group: Array = pending.pop_front()
		var sk := _build_skirmish(group)
		if sk != null:
			current = sk
			skirmishes_fought += 1
			return sk
	_after_phase()
	return null


## The mechs of the group fight every foe the group's squads unpack into.
func _build_skirmish(group: Array) -> Skirmish:
	var sk := Skirmish.new(rng.randi())
	for u in group:
		if not field.units.has(u):
			continue
		if u.is_player() and not u.is_static():
			sk.add_mech(u)
		elif u.is_enemy():
			sk.add_foes(db.foes_for(u), u)
	if sk.mechs.is_empty() or sk.pool.is_empty():
		return null
	return sk


## Apply the finished skirmish: wrecks leave the map, squads shrink or vanish, survivors'
## shields recharge, and Rift Pressure ticks once per round fought.
func finish_skirmish() -> void:
	if current == null:
		return
	field.apply_skirmish_result(current)
	for ms in current.mechs:
		if ms.alive():
			ms.unit.recharge_shield()
	current = null
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
		state = State.DONE
		return true
	return false
