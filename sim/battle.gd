class_name Battle
extends RefCounted

## One battle, from the first turn until the gate falls, every machine is wrecked, or the
## boss powering the rift dies. Owns the battlefield, the player's turn (who has moved, who
## has fought, which fights a hunter forced) and the skirmish open. Pure: the battle screen
## drives it, tests drive it headless. The round is bible section 4's; the fights, section 5's.
##
## Loop:
##   PLAN      the player's turn: move_to() any machine with an action left; order() it onto
##             a pack in its attack range; engage() opens the next fight with the machines
##             ordered onto it, a fight hunters forced always first (`forced`); end_turn()
##             when done
##   SKIRMISH  the fight attack() opened; the screen plays it, finish_skirmish() applies it
##             back to the map and the machines in it are spent; back to PLAN
##   DONE      outcome is set
##
## Hull never repairs during a battle; shield comes back at the field rate in a turn a
## machine does not fight; damaged faces persist on the unit.

enum State { PLAN, SKIRMISH, DONE }
enum Outcome { NONE, VICTORY, GATE_FALLEN, WRECKED }

const DEFAULT_WIDTH := 9   # nine wide, the thumb's limit, so four machines can split two and two (bible section 4, the round row)
const DEFAULT_HEIGHT := 20

var seed_value: int = 1
var map_kind := "mixed"   # the map's type (BattleMap.KINDS); set before setup, the intel the player will choose by
var rng := RandomNumberGenerator.new()
var db: ContentDB
var map: BattleMap
var field: Battlefield
var faction: String = ""
var boss: Unit = null
var state: int = State.PLAN
var outcome: int = Outcome.NONE
var spent: Dictionary = {}       # mech id -> actions spent this turn (a fight spends one)
var move_left: Dictionary = {}   # mech id -> move points left in its current action; whole when absent
var action_from: Dictionary = {} # mech id -> [hex, facing, move left] where its current action's moving began, for an undo
var fought: Dictionary = {}      # mech id -> true: it fought this turn, so no field recharge
## The fights hunters forced this turn, first in line (bible section 5): [{"prey": Unit,
## "hunters": Array[Unit]}]. While any is left, it is the only fight that may open and the
## turn cannot end; its prey cannot move.
var forced: Array = []
## Attack orders (bible section 5): mech id -> the pack it fights when ENGAGE is pressed, in
## the order given. A drag or a tap onto a pack gives one; nothing opens until ENGAGE, so a
## mis-drop on a phone is harmless. Several machines on one pack are one fight.
var orders: Dictionary = {}
var boss_fight := false          # the open fight holds the boss (its reveal and its theme)
var last_spawned := false        # the last enemy turn's rift tick spawned a pack
var current: Skirmish = null
var skirmishes_fought: int = 0
var columns: int = Skirmish.DEFAULT_COLUMNS   # formation width for every skirmish this battle opens
## A guest faction (bible section 3: one lead and at most one guest a battle): set before
## setup, its spawn list joins the rift's cycle, alternating with the lead's; the formation
## on the field at the start is the lead's alone. Empty for none.
var guest: String = ""
## The enemy side composed by hand (the harness, for play tests), set before setup: the
## packs as [[foe_id, strength], ...], placed at the start and cycled by the rift as the
## lead's spawn table would be, each pack under its own foe's faction. Empty keeps the lead
## faction's spawn table.
var formation: Array = []
## Whether the lead faction's boss takes the field. Without one the battle has no victory,
## only the gate's fall or the team's (the harness, to watch the packs alone).
var with_boss := true
## The rift's commanders composed by the campaign, set before setup (the party, bible section
## 9): the foes its boss unit unpacks into, in order (a final's dealt hero; the finale's line),
## and the escort beside them, [foe_id, count] (a final's wildlife). The battle is won when
## every commander has fallen. Empty keeps the lead faction's boss alone.
var lineup: Array = []
var escort: Array = []
## Every foe killed this battle, in any fight however it ended (Ryan, 7 October: a kill is a
## kill, and withdrawing never takes it away), for the salvage the campaign tallies at the
## battle's end and never shows while it is fought. The battle only counts; the campaign
## decides what is kept.
var foes_killed: int = 0
## The battle's share of the run's Sponsorship measures (the bible's Sponsorship row): the
## hexes its machines move on the map, and each fight's own (Skirmish.sponsorship), added up.
var sponsorship := {"hexes_moved": 0, "guarded": 0, "damaging_spends": 0, "quiet_spends": 0}   # ContentDB.SPONSORSHIP_MEASURES
var action_hexes: Dictionary = {}   # mech id -> hexes moved in its current action, taken back with an undo
## The machines wrecked this battle, as they fell: the map lets go of them, the campaign
## still reads their dice (a wreck loses its cracked and destroyed components).
var wrecks: Array[Unit] = []


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
	map = BattleMap.generate(w, h, seed_value, map_kind)
	field = Battlefield.new(map)
	field.spawn_faction = faction
	var lead_table: Array = db.spawn_table(faction)
	if not formation.is_empty():
		lead_table = []
		for e in formation:
			var fac := db.faction_of_foe(str(e[0]))
			lead_table.append([str(e[0]), int(e[1]), fac if not fac.is_empty() else faction])
	field.spawn_table = lead_table
	if not guest.is_empty() and guest != faction and db.factions.has(guest):
		# The guest joins the rift's cycle only, each entry carrying its own faction; the
		# formation placed below is the lead's alone (found 6 October: placing it from the
		# mixed table doubled the field).
		var visitors: Array = db.spawn_table(guest)
		var mixed: Array = []
		for k in range(maxi(lead_table.size(), visitors.size())):
			if k < lead_table.size():
				mixed.append(lead_table[k])
			if k < visitors.size():
				mixed.append([visitors[k][0], visitors[k][1], guest])
		field.spawn_table = mixed
	field.foe_profiles = db.pack_profiles()
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
	var table: Array = lead_table
	for j in range(table.size()):
		var entry: Array = table[j]
		var col := (w * (j + 1)) / (table.size() + 1)
		var row := 3 + (j % 3)
		var sq := Unit.pack(0, _pack_name(str(entry[0])), Vector2i.ZERO, str(entry[2]) if entry.size() > 2 else faction, Unit.PACK_MOVE, int(entry[1]), str(entry[0]))
		sq.pos = field.nearest_standable(sq, Hex.offset_to_axial(col, row))
		field.add_unit(field.dress_pack(sq))
	var fac: Dictionary = db.factions.get(faction, {})
	var boss_id := str(lineup[0]) if not lineup.is_empty() else str(fac.get("boss", ""))
	if with_boss and db.foes.has(boss_id):
		# The finale's line goes by the party's name; a final's hero and a boss by its own.
		var named := "the party" if lineup.size() > 1 else str(db.foes[boss_id]["name"]).to_lower()
		boss = Unit.boss(0, named, Vector2i.ZERO, faction, Unit.BOSS_MOVE)
		boss.lineup = lineup.duplicate()
		if escort.size() >= 2 and db.foes.has(str(escort[0])):
			boss.foe_id = str(escort[0])
			boss.strength = maxi(0, int(escort[1]))
		boss.pos = field.nearest_standable(boss, Hex.offset_to_axial(w / 2 - 1, 1))
		field.add_unit(field.dress_pack(boss, boss_id))
	state = State.PLAN
	_new_turn()


func _pack_name(foe_id: String) -> String:
	if db.foes.has(foe_id):
		return "%s pack" % str(db.foes[foe_id]["name"]).to_lower()
	return "%s pack" % foe_id


# ---------------------------------------------------------------- the player's turn

func mechs() -> Array[Unit]:
	return field.mechs()


## The actions a machine has left this turn: one a turn, more if its passive grants them.
func actions_left(u: Unit) -> int:
	return maxi(0, Battlefield.actions_for(u) - int(spent.get(u.id, 0)))


## Whether a hunter has caught this machine and the fight is still to come.
func is_pinned(u: Unit) -> bool:
	for f in forced:
		if f["prey"] == u:
			return true
	return false


## The move points left in a machine's current action.
func moves_left(u: Unit) -> int:
	return int(move_left.get(u.id, u.movespeed))


## Whether a machine may move now: the player's turn, an action left, move left, not caught.
func can_move(u: Unit) -> bool:
	return state == State.PLAN and actions_left(u) > 0 and moves_left(u) > 0 and not is_pinned(u)


## Hexes a machine may move to now, with the move it has left.
func destinations_for(u: Unit) -> Dictionary:
	if u == null or not can_move(u):
		return {}
	return field.reachable(u, moves_left(u))


## Move a machine to `to` by its cheapest route, at once (a machine moves, then fights; bible
## section 4). The route walked, as the hexes after where it stood; empty when refused.
func move_to(u: Unit, to: Vector2i) -> Array[Vector2i]:
	var none: Array[Vector2i] = []
	if not destinations_for(u).has(to):
		return none
	var route := field.route_to(u, to, moves_left(u))
	if route.is_empty():
		return none
	_walk_machine(u, route)
	return route


## Move a machine along a route drawn by hand (Ryan, 25 September: the drag says which way
## round), at once. False when it cannot be walked with the move left.
func move_along(u: Unit, route: Array) -> bool:
	if not can_move(u) or route.is_empty():
		return false
	if field.route_cost(u, route, moves_left(u)) < 0:
		return false
	var typed: Array[Vector2i] = []
	for s in route:
		typed.append(s)
	_walk_machine(u, typed)
	return true


func _walk_machine(u: Unit, route: Array[Vector2i]) -> void:
	var cost := field.route_cost(u, route, moves_left(u))
	if not action_from.has(u.id):
		action_from[u.id] = [u.pos, u.facing, moves_left(u)]
	move_left[u.id] = moves_left(u) - cost
	var before: Vector2i = route[route.size() - 2] if route.size() >= 2 else u.pos
	u.facing = field._direction_index(before, route[route.size() - 1])
	u.pos = route[route.size() - 1]
	sponsorship["hexes_moved"] = int(sponsorship["hexes_moved"]) + route.size()
	action_hexes[u.id] = int(action_hexes.get(u.id, 0)) + route.size()
	_prune_orders()


## Whether a machine's move this action can be taken back.
func can_undo(u: Unit) -> bool:
	if state != State.PLAN or u == null or not action_from.has(u.id):
		return false
	var a: Array = action_from[u.id]
	return u.pos == a[0] or field.can_stand(u, a[0])


## Put a machine back where its current action's moving began, its move whole again.
func undo_move(u: Unit) -> bool:
	if not can_undo(u):
		return false
	var a: Array = action_from[u.id]
	u.pos = a[0]
	u.facing = int(a[1])
	move_left[u.id] = int(a[2])
	action_from.erase(u.id)
	sponsorship["hexes_moved"] = maxi(0, int(sponsorship["hexes_moved"]) - int(action_hexes.get(u.id, 0)))
	action_hexes.erase(u.id)
	_prune_orders()
	return true


## One step of drawing a route by hand: `draft` is the route so far (hexes after the
## machine's own), `h` the hex the finger has reached. Back on the machine clears; a hex
## already on the draft cuts it back to there; anything else is joined by the cheapest
## continuation that fits the move left (a finger that skips a hex still draws a walkable
## route), or the draft stands when nothing fits.
func draft_step(u: Unit, draft: Array, h: Vector2i) -> Array:
	if h == u.pos:
		return []
	var at := draft.find(h)
	if at >= 0:
		return draft.slice(0, at + 1)
	var end: Vector2i = draft[draft.size() - 1] if not draft.is_empty() else u.pos
	var spent_move := field.route_cost(u, draft, moves_left(u))
	if spent_move < 0:
		return draft
	var ext := field.route_from(u, end, moves_left(u) - spent_move, h)
	if ext.is_empty():
		return draft
	var out: Array = draft.duplicate()
	out.append_array(ext)
	return out


## What a draft costs so far out of the move left; -1 when it cannot be walked.
func draft_cost(u: Unit, draft: Array) -> int:
	return field.route_cost(u, draft, moves_left(u))


## The move gauge's reading of a draft (decided 3 October, bible section 4): the move its
## steps spent, and the move a slow last step took when it ends on one, as (spent, stopped).
## A slow step takes whatever is left, so a route that ends on rubble and one that ran its
## move out on open ground both leave nothing; the gauge tells them apart by what took it.
## (-1, 0) when the draft cannot be walked.
func draft_spend(u: Unit, draft: Array) -> Vector2i:
	var cost := draft_cost(u, draft)
	if cost < 0 or draft.is_empty():
		return Vector2i(cost, 0)
	var last: Vector2i = draft[draft.size() - 1]
	if BattleMap.move_cost(field.map.terrain_at(last), u.traits) != BattleMap.SLOW:
		return Vector2i(cost, 0)
	var before := draft_cost(u, draft.slice(0, draft.size() - 1))
	return Vector2i(before, cost - before)


## The fight the player would open at `target`, or the next fight a hunter forced, which comes
## first whatever is tapped (bible section 5): {"targets": the packs attacked, "joins": the
## packs whose ring covers a target, "in_range": the machines whose attack range covers one,
## "eligible": those of them with an action left (a caught machine always), "pinned": the
## caught machine or null, "forced": whether this is a forced fight}. Empty when there is none.
func roster(target: Unit = null) -> Dictionary:
	if state != State.PLAN:
		return {}
	var targets: Array = []
	var pinned: Unit = null
	if not forced.is_empty():
		targets = (forced[0]["hunters"] as Array).duplicate()
		pinned = forced[0]["prey"]
	elif target != null and target.is_enemy() and field.units.has(target):
		targets = [target]
	else:
		return {}
	var r := field.attack_roster(targets)
	var eligible: Array[Unit] = []
	if pinned != null:
		eligible.append(pinned)
	for m in r["in_range"]:
		if m != pinned and actions_left(m) > 0:
			eligible.append(m)
	r["eligible"] = eligible
	r["pinned"] = pinned
	r["forced"] = pinned != null
	return r


## Open a fight: the machines committed (those of `machines` the roster allows; a caught
## machine always) against the targets and every pack that joins. The skirmish, or null when
## refused (not the player's turn, no fight there, nobody to commit).
func attack(target: Unit, machines: Array) -> Skirmish:
	var r := roster(target)
	if r.is_empty():
		return null
	var team: Array = []
	if r["pinned"] != null:
		team.append(r["pinned"])
	for m in machines:
		if (r["eligible"] as Array).has(m) and not team.has(m):
			team.append(m)
	if team.is_empty():
		return null
	var group: Array = []
	group.append_array(r["targets"])
	group.append_array(r["joins"])
	group.append_array(team)
	var sk := _build_skirmish(group)
	if sk == null:
		return null
	boss_fight = boss != null and group.has(boss)
	current = sk
	skirmishes_fought += 1
	state = State.SKIRMISH
	return sk


# ---------------------------------------------------------------- attack orders

const NO_HEX := Vector2i(-9999, -9999)


## The distance from a hex to a unit, by the unit's nearest hex.
func _distance_from(h: Vector2i, u: Unit) -> int:
	var best := 1 << 30
	for x in u.hexes():
		best = mini(best, Hex.distance(h, x))
	return best


## Whether a machine standing at `h` has `target` within its attack range.
func in_range_from(m: Unit, h: Vector2i, target: Unit) -> bool:
	return _distance_from(h, target) <= m.attack_range


## Where a machine attacks `target` from when it is dragged or tapped onto it (bible section
## 5): where it stands, if the target is in range; else the hex its move left reaches that has
## the target in range and stands farthest from it, the cheaper on a tie. NO_HEX when none.
func attack_hex(m: Unit, target: Unit) -> Vector2i:
	if m == null or target == null:
		return NO_HEX
	if in_range_from(m, m.pos, target):
		return m.pos
	var best := NO_HEX
	var best_d := -1
	var best_c := 1 << 30
	var dests := destinations_for(m)
	for h in dests.keys():
		var hx: Vector2i = h
		if not in_range_from(m, hx, target):
			continue
		var d := _distance_from(hx, target)
		var c := int(dests[hx])
		if d > best_d or (d == best_d and c < best_c):
			best = hx
			best_d = d
			best_c = c
	return best


## Whether a fight may be ordered at `target` now: a pack on the field, and while a hunter's
## catch waits, one of its hunters alone (that fight comes first).
func can_target(target: Unit) -> bool:
	if target == null or not target.is_enemy() or not field.units.has(target):
		return false
	if not forced.is_empty():
		return (forced[0]["hunters"] as Array).has(target)
	return true


## Order a machine onto `target` for ENGAGE: on the player's turn, with an action left, the
## target in range where it stands now (a machine moves first), and the target one that may
## be fought now. False when refused.
func order(m: Unit, target: Unit) -> bool:
	if state != State.PLAN or m == null or not field.units.has(m) or actions_left(m) <= 0:
		return false
	if not can_target(target) or not in_range_from(m, m.pos, target):
		return false
	orders[m.id] = target
	return true


func cancel_order(m: Unit) -> void:
	if m != null:
		orders.erase(m.id)


## The pack a machine is ordered onto, or null.
func order_of(m: Unit) -> Unit:
	return orders.get(m.id, null) if m != null else null


## The next fight ENGAGE opens: a hunter's catch first (its prey and the machines ordered onto
## its hunters), else the first pack ordered on, with every machine ordered onto it.
## {"target": the pack, null for a catch, "machines": Array}; empty when there is none.
func next_fight() -> Dictionary:
	_prune_orders()
	if not forced.is_empty():
		var hunters: Array = forced[0]["hunters"]
		var ms: Array = []
		for uid in orders.keys():
			if hunters.has(orders[uid]):
				ms.append(field.unit_by_id(int(uid)))
		return {"target": null, "machines": ms}
	if orders.is_empty():
		return {}
	var first: Unit = orders.values()[0]
	var team: Array = []
	for uid in orders.keys():
		if orders[uid] == first:
			team.append(field.unit_by_id(int(uid)))
	return {"target": first, "machines": team}


## ENGAGE: the next fight opens with the machines ordered onto it. Null when there is none.
func engage() -> Skirmish:
	var f := next_fight()
	if f.is_empty():
		return null
	var sk := attack(f["target"], f["machines"])
	if sk != null:
		for m in f["machines"]:
			orders.erase((m as Unit).id)
	return sk


## Drop an order whose machine is gone, has no action left or stands out of range, or whose
## pack is gone or cannot be fought now.
func _prune_orders() -> void:
	for uid in orders.keys():
		var m := field.unit_by_id(int(uid))
		var target: Unit = orders[uid]
		if m == null or actions_left(m) <= 0 or not can_target(target) or not in_range_from(m, m.pos, target):
			orders.erase(uid)


## End the player's turn (bible section 4): the enemy's turn plays (packs walk round the
## machines, a pack on the apron strikes the gate), a machine that did not fight this turn
## recharges at the field rate, the rift ticks once, and the next turn opens with the fights
## hunters have forced. The walks played (pack id -> Battlefield.Walk); empty when refused
## (not the player's turn, or a forced fight still to come).
func end_turn() -> Dictionary:
	if state != State.PLAN or not forced.is_empty():
		return {}
	var walks := field.enemy_turn()
	for u in field.mechs():
		if fought.has(u.id):
			continue
		u.recharge_shield(u.recharge_field)
		# Passives that fire at the end of a turn spent out of a fight (out_of_combat).
		var fired := Effects.fire(u, "out_of_combat")
		if int(fired["shield"]) > 0:
			u.recharge_shield(int(fired["shield"]))
	field.phase += 1
	last_spawned = field.tick_pressure(1)
	_new_turn()
	return walks


## A fresh turn: every machine's actions and move whole, and the fights hunters forced.
func _new_turn() -> void:
	spent.clear()
	move_left.clear()
	action_from.clear()
	action_hexes.clear()
	fought.clear()
	orders.clear()
	forced = []
	if _check_outcome():
		return
	forced = field.forced_fights()


## Drop forced fights whose prey or every hunter is gone (killed in an earlier fight).
func _prune_forced() -> void:
	var kept: Array = []
	for f in forced:
		if not field.units.has(f["prey"]):
			continue
		var hunters: Array = []
		for h in f["hunters"]:
			if field.units.has(h):
				hunters.append(h)
		if not hunters.is_empty():
			kept.append({"prey": f["prey"], "hunters": hunters})
	forced = kept


## The mechs of the group fight every foe the group's packs unpack into.
## The hex a contact is fought on (decided 22 September): the pack's, since the fight
## opens where the pack stands and its ground has already gone flat; with several
## packs, the first in field order, the one the contact names first. One rule, used by
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
	sk.foe_factory = func(foe_id: String) -> Foe: return db.make_foe(foe_id) if db.foes.has(foe_id) else null   # a summoning action calls up content
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


## Apply the finished skirmish: wrecks leave the map, packs shrink or vanish. Rift Pressure
## ticks on the map's enemy turns only, never per round fought (Ryan, 13 October). Every
## machine in it is spent, however the fight ended (bible section 4); a forced fight comes off
## the list. Shields do not refill here.
func finish_skirmish() -> void:
	if current == null:
		return
	for ms in current.mechs:
		if ms.unit.hull <= 0 and not wrecks.has(ms.unit):
			wrecks.append(ms.unit)
		spent[ms.unit.id] = int(spent.get(ms.unit.id, 0)) + 1
		fought[ms.unit.id] = true
		move_left.erase(ms.unit.id)
		action_from.erase(ms.unit.id)
		action_hexes.erase(ms.unit.id)
	for sq in current.packs:
		foes_killed += current.kills_for(sq)
	for k in current.sponsorship.keys():
		sponsorship[k] = int(sponsorship.get(k, 0)) + int(current.sponsorship[k])
	field.apply_skirmish_result(current)
	current = null
	boss_fight = false
	state = State.PLAN
	if not forced.is_empty():
		forced.pop_front()
	_prune_forced()
	_prune_orders()
	_check_outcome()


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
