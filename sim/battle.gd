class_name Battle
extends RefCounted

## One battle, from the first turn until the gate falls, every machine is wrecked, or the
## boss powering the rift dies. Owns the battlefield, the player's turn (who has moved, who
## has fought, which fights a hunter forced) and the skirmish open. Pure: the battle screen
## drives it, tests drive it headless. The round is bible section 4's; the fights, section 5's.
##
## Loop:
##   PLAN      the player's turn: move_to() any machine with an action left, once an action
##             and in one go; order() it onto
##             a pack in its attack range (order_onto() moves it into range first); undo()
##             takes back the last move or order, in the order they were made; engage() opens
##             the next fight with the machines ordered onto it, a fight hunters forced always
##             first (`forced`); end_turn() when done. A move lands in the battle at once and is
##             planned on the map (`planned`): the screen plays the plan on ENGAGE or END TURN
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
## The machines that have moved this action (Ryan, 28 October: a move is given in one go): mech
## id -> true. A fight's spent action clears it, so a second action moves again.
var moved: Dictionary = {}
var last_carry: Array = []       # the last move's riders, [[rider id, hex, hex set down], ...], for the map's ring; never saved
## The turn's undo, in the order things were done (Ryan, 25 October: "undo should happen in
## global order, not on a per-unit basis"): one entry a move or an order (an order's move into
## range with it), each the turn as it stood before it (_snapshot), so UNDO takes back the
## last, always. A fight is a barrier: what came before it is played and fought over, so the
## stack starts again after it, and a new turn empties it.
var history: Array = []
## The moves made and not yet played on the map (Ryan, 25 October: "highlight and display the
## planned move like we used to, and then on engage or end turn actually animate and resolve"):
## one piece a move, in the order made, {"unit": id, "from": [x, y], "facing": int, "path":
## [[x, y], ...] the hexes after it, "to_facing": int, "riders": [[rider id, x, y, facing, set
## down x, y], ...]}. The battle has every machine at its route's end already, so the next
## move, the orders and every walk are read from there; the map draws each machine where its
## plan starts (shown_positions) with its route ahead of it, until take_plan() hands the plan
## to the screen to play. Kept JSON's way (arrays, never hexes), for the save and the undo.
var planned: Array = []
var _batch := 0              # inside order_onto: its move and its order are one entry
var _batch_dirty := false    # and something changed under it
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
## The battle's tier, 0 to 2 (the campaign's, set before setup; 0 in the harness): its boss unit
## stands at it, its commanders' numbers and its escort following (ContentDB.BOSS_TIERS).
var tier: int = 0
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
## still reads their dice (a wreck loses its destroyed components).
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
	var lead_table: Array = db.spawn_table(faction, tier + 1)   # the battle's tier's list (28 October), tier counting 0 to 2
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
		var visitors: Array = db.spawn_table(guest, tier + 1)
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
	var firsts := db.bosses_of(faction)
	var boss_id := str(lineup[0]) if not lineup.is_empty() else (firsts[0] if not firsts.is_empty() else "")
	if with_boss and db.foes.has(boss_id):
		# The finale's line goes by the party's name; a final's hero and a boss by its own.
		var named := "the party" if lineup.size() > 1 else str(db.foes[boss_id]["name"]).to_lower()
		boss = Unit.boss(0, named, Vector2i.ZERO, faction, Unit.BOSS_MOVE)
		boss.lineup = lineup.duplicate()
		if escort.size() >= 2:
			# A named escort foe is a hand-tailored escort; unnamed, the tier's own units.
			if db.foes.has(str(escort[0])):
				boss.foe_id = str(escort[0])
			boss.strength = maxi(0, int(escort[1]))
		boss.boss_tier = tier
		boss.strength += ContentDB.escort_at(tier)
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


## Whether a machine may move now: the player's turn, an action left, not moved this action
## (one move an action, in one go), a move to give, not caught.
func can_move(u: Unit) -> bool:
	return state == State.PLAN and actions_left(u) > 0 and not moved.has(u.id) and u.movespeed > 0 and not is_pinned(u)


## Hexes a machine may move to now, with its whole move; a carrier only where the block it
## carries fits (the Swallowtail's carry), its riders lifted off its way.
func destinations_for(u: Unit) -> Dictionary:
	if u == null or not can_move(u):
		return {}
	var riders := _lift(u)
	var out := field.reachable(u, u.movespeed)
	_set_down()
	if not riders.is_empty():
		for h in out.keys():
			if not block_fits(u, riders, h):
				out.erase(h)
	return out


## Where a machine could attack from this action, past its move (Ryan, 25 October: "not only
## its available move spaces, but its available attacking spaces at the edge of that move, in
## red"): every hex within its attack range of where it stands or of any hex its move reaches,
## not one of those, and not a structure. A pack standing in it can be ordered on. Empty
## with no action left; with no move left, the ring of its range round where it stands.
func threat_for(u: Unit) -> Dictionary:
	if u == null or state != State.PLAN or actions_left(u) <= 0:
		return {}
	var dests := destinations_for(u)
	var out := {}
	var seen := {}
	var queue: Array = []
	for h in dests.keys() + [u.pos]:
		seen[h] = 0
		queue.append(h)
	# Outward from the whole reach at once: a hex's distance is to the nearest hex of it.
	while not queue.is_empty():
		var h: Vector2i = queue.pop_front()
		var d: int = seen[h]
		var occ := field.unit_at(h) if d > 0 else null
		if d > 0 and field.map.has(h) and not field.map.is_structure(h) and not (occ != null and occ.is_player()):
			out[h] = true   # a machine's hex is no place to attack
		if d >= u.attack_range:
			continue
		for n in Hex.neighbors(h):
			if not seen.has(n):
				seen[n] = d + 1
				queue.append(n)
	return out


## The machines that travel with a carrier when it moves (the Swallowtail's Muster Deck, Ryan's
## go of 21 October): every machine on a hex beside it, a caught one aside (it cannot move first).
func riders_of(u: Unit) -> Array[Unit]:
	var out: Array[Unit] = []
	if u == null or not Effects.carries(u):
		return out
	for m in mechs():
		if m != u and m.alive() and Hex.distance(m.pos, u.pos) == 1 and not is_pinned(m):
			out.append(m)
	return out


## Where the riders would land if the carrier stopped at `at` (Ryan, 21 October: lifted in
## place, they travel as a ring round the carrier and land as a block, each where it rode from
## it): {"to": rider -> hex, "bad": the hexes a rider could not stand on}. The block fits only
## when nothing is bad, and a stop it does not fit is no move: the map marks it and the player
## changes it.
func landing(u: Unit, riders: Array[Unit], at: Vector2i) -> Dictionary:
	var to := {}
	var bad: Array[Vector2i] = []
	for r in riders:
		var h: Vector2i = at + (r.pos - u.pos)
		to[r] = h
		if not _lands_on(r, h, u, riders):
			bad.append(h)
	return {"to": to, "bad": bad}


func block_fits(u: Unit, riders: Array[Unit], at: Vector2i) -> bool:
	return (landing(u, riders, at)["bad"] as Array).is_empty()


## Whether a drafted route's end would take the carrier's block (empty for a machine that
## carries nobody): the map's mark on a stop the riders cannot land round.
func draft_landing(u: Unit, draft: Array) -> Dictionary:
	var riders := riders_of(u)
	if riders.is_empty() or draft.is_empty():
		return {}
	return landing(u, riders, draft[draft.size() - 1])


## Whether rider `r` could land on `h`: on the map, no structure, ground it stands on, and no
## unit there but the block itself (the carrier and the riders are lifted).
func _lands_on(r: Unit, h: Vector2i, u: Unit, riders: Array[Unit]) -> bool:
	for o in r.footprint:
		var at: Vector2i = h + o
		if not field.map.has(at) or field.map.is_structure(at):
			return false
		if not BattleMap.passable(field.map.terrain[at], r.traits):
			return false
		var occ := field.unit_at(at)
		if occ != null and occ != r and occ != u and not riders.has(occ):
			return false
	return true


## A carrier's riders lifted off the field's blockers for its route (they travel with it);
## `_set_down` puts them back. Returns the riders.
func _lift(u: Unit) -> Array[Unit]:
	var riders := riders_of(u)
	field.lifted = riders
	return riders


func _set_down() -> void:
	field.lifted = []


static func _arr(h: Vector2i) -> Array:
	return [h.x, h.y]


## Move a machine to `to` by its cheapest route, at once (a machine moves, then fights; bible
## section 4). The route walked, as the hexes after where it stood; empty when refused.
func move_to(u: Unit, to: Vector2i) -> Array[Vector2i]:
	var none: Array[Vector2i] = []
	if not destinations_for(u).has(to):
		return none
	_lift(u)
	var route := field.route_to(u, to, u.movespeed)
	_set_down()
	if route.is_empty():
		return none
	_walk_machine(u, route)
	return route


## Move a machine along a route drawn by hand (Ryan, 25 September: the drag says which way
## round), at once. False when it cannot be walked with its move.
func move_along(u: Unit, route: Array) -> bool:
	if not can_move(u) or route.is_empty():
		return false
	var riders := _lift(u)
	var cost := field.route_cost(u, route, u.movespeed)
	_set_down()
	if cost < 0:
		return false
	if not riders.is_empty() and not block_fits(u, riders, route[route.size() - 1]):
		return false   # a carrier cannot stop where its block does not fit
	var typed: Array[Vector2i] = []
	for s in route:
		typed.append(s)
	_walk_machine(u, typed)
	return true


func _walk_machine(u: Unit, route: Array[Vector2i]) -> void:
	var riders := _lift(u)   # who rides, read where it stood
	_set_down()
	var lands: Dictionary = landing(u, riders, route[route.size() - 1])["to"] if not riders.is_empty() else {}
	_push(u)
	var piece := {"unit": u.id, "from": _arr(u.pos), "facing": u.facing, "path": route.map(func(h): return _arr(h)), "riders": []}
	for r in riders:
		(piece["riders"] as Array).append([r.id, r.pos.x, r.pos.y, r.facing, (lands[r] as Vector2i).x, (lands[r] as Vector2i).y])
	moved[u.id] = true   # one move an action, the whole of it
	var before: Vector2i = route[route.size() - 2] if route.size() >= 2 else u.pos
	u.facing = field._direction_index(before, route[route.size() - 1])
	u.pos = route[route.size() - 1]
	# The carry (the Swallowtail's): the block lands round where it stops, every rider where it
	# rode from the carrier, its action as it was and its move if it has not moved (the lift
	# changes where it is, never what it has left).
	last_carry = []
	if not riders.is_empty():
		for r in riders:
			last_carry.append([r.id, r.pos, lands[r]])
		for r in riders:
			r.pos = lands[r]
	piece["to_facing"] = u.facing
	planned.append(piece)
	sponsorship["hexes_moved"] = int(sponsorship["hexes_moved"]) + route.size()
	action_hexes[u.id] = int(action_hexes.get(u.id, 0)) + route.size()
	_prune_orders()


# ---------------------------------------------------------------- the undo and the plan

## The turn as it stands, JSON's way: every machine's hex and facing, who has moved this
## action, the orders, the hexes moved and the plan. `who` is the machine the step about to be
## taken is about (an undo hands it back to the player's hand).
func _snapshot(who: Unit = null) -> Dictionary:
	var units := {}
	for m in field.mechs():
		units[str(m.id)] = [m.pos.x, m.pos.y, m.facing]
	var who_moved: Array = []
	for uid in moved.keys():
		who_moved.append(int(uid))
	var hexes := {}
	for uid in action_hexes.keys():
		hexes[str(uid)] = int(action_hexes[uid])
	var ords := {}
	for uid in orders.keys():
		ords[str(uid)] = (orders[uid] as Unit).id
	return {"who": who.id if who != null else 0, "units": units, "moved": who_moved,
		"action_hexes": hexes, "orders": ords, "hexes_moved": int(sponsorship["hexes_moved"]), "planned": planned.duplicate(true)}


## Put the turn back as a snapshot had it (a JSON round trip's floats and string keys read too).
func _restore(snap: Dictionary) -> void:
	var units: Dictionary = snap.get("units", {})
	for m in field.mechs():
		var at = units.get(str(m.id), null)
		if at is Array and (at as Array).size() >= 3:
			m.pos = Vector2i(int(at[0]), int(at[1]))
			m.facing = int(at[2])
	moved.clear()
	for uid in snap.get("moved", []):
		moved[int(uid)] = true
	action_hexes.clear()
	var hexes: Dictionary = snap.get("action_hexes", {})
	for k in hexes.keys():
		action_hexes[int(str(k))] = int(hexes[k])
	orders.clear()
	var ords: Dictionary = snap.get("orders", {})
	for k in ords.keys():
		var t := field.unit_by_id(int(ords[k]))
		if t != null:
			orders[int(str(k))] = t
	sponsorship["hexes_moved"] = int(snap.get("hexes_moved", sponsorship["hexes_moved"]))
	planned = (snap.get("planned", []) as Array).duplicate(true)
	last_carry = []


## A step about to be taken goes on the undo, unless it is part of an order's (order_onto).
func _push(who: Unit) -> void:
	if _batch > 0:
		_batch_dirty = true
		return
	history.append(_snapshot(who))


## Whether UNDO has anything to take back: the player's turn, and a move or an order since the
## turn opened or the last fight.
func can_undo() -> bool:
	return state == State.PLAN and not history.is_empty()


## Take back the last move or order, whoever made it (Ryan, 25 October: "the undo stack is
## stored in order, and undos in order, always"). The machine it was about, or null when
## there was nothing to undo.
func undo() -> Unit:
	if not can_undo():
		return null
	var snap: Dictionary = history.pop_back()
	_restore(snap)
	return field.unit_by_id(int(snap.get("who", 0)))


## The plan as the map draws it: each piece with hexes, in the order made.
func plan_pieces() -> Array:
	var out: Array = []
	for p in planned:
		var path: Array[Vector2i] = []
		for h in p["path"]:
			path.append(Vector2i(int(h[0]), int(h[1])))
		var riders: Array = []
		for r in p.get("riders", []):
			riders.append([int(r[0]), Vector2i(int(r[1]), int(r[2])), int(r[3]), Vector2i(int(r[4]), int(r[5]))])
		out.append({"unit": int(p["unit"]), "from": Vector2i(int(p["from"][0]), int(p["from"][1])), "facing": int(p["facing"]),
			"path": path, "to_facing": int(p.get("to_facing", p["facing"])), "riders": riders})
	return out


## Where the map draws each machine whose plan has not played: where its first piece starts (or
## where a carrier's first piece lifted it), facing as it stood. Machine id -> [hex, facing].
func shown_positions() -> Dictionary:
	var out := {}
	for p in plan_pieces():
		if not out.has(p["unit"]):
			out[p["unit"]] = [p["from"], p["facing"]]
		for r in p["riders"]:
			if not out.has(r[0]):
				out[r[0]] = [r[1], r[2]]
	return out


## The plan, handed to the screen to play (on ENGAGE or END TURN), and gone from the battle.
func take_plan() -> Array:
	var out := plan_pieces()
	planned.clear()
	return out


## One step of drawing a route by hand: `draft` is the route so far (hexes after the
## machine's own), `h` the hex the finger has reached. Back on the machine clears; a hex
## already on the draft cuts it back to there; anything else is joined by the cheapest
## continuation that fits the move (a finger that skips a hex still draws a walkable route),
## or the draft stands when nothing fits.
func draft_step(u: Unit, draft: Array, h: Vector2i) -> Array:
	if h == u.pos:
		return []
	var at := draft.find(h)
	if at >= 0:
		return draft.slice(0, at + 1)
	var end: Vector2i = draft[draft.size() - 1] if not draft.is_empty() else u.pos
	_lift(u)
	var spent_move := field.route_cost(u, draft, u.movespeed)
	var ext: Array[Vector2i] = []
	if spent_move >= 0:
		ext = field.route_from(u, end, u.movespeed - spent_move, h)
	_set_down()
	if spent_move < 0 or ext.is_empty():
		return draft
	var out: Array = draft.duplicate()
	out.append_array(ext)
	return out


## Whether nothing is left for the player to do on the map this turn but press the button
## (Ryan, 25 October: END TURN pulses "when all units are out of actions"): every machine has
## fought its actions out, is ordered onto a fight, is caught (its fight comes first), or can
## neither move nor reach a pack where it stands.
func nothing_left() -> bool:
	if state != State.PLAN:
		return false
	for m in mechs():
		if m.is_static() or not m.alive() or actions_left(m) <= 0 or orders.has(m.id) or is_pinned(m):
			continue
		if can_move(m):
			return false
		for p in field.packs():
			if can_target(p) and in_range_from(m, m.pos, p):
				return false
	return true


## Whether the next fight ENGAGE opens holds the boss: every machine goes in, nothing moves first
## (Ryan, 25 October: "no reason to move any units once engage is clicked, just go right into
## the boss animation").
func next_fight_is_boss() -> bool:
	var f := next_fight()
	if f.is_empty() or f["target"] == null:
		return false
	return bool(roster(f["target"]).get("all_in", false))


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
	# The boss's fight takes every machine (Ryan, 25 October: "automatically make all units
	# attacking when one unit targets it, regardless of their range", "doesn't matter if a
	# unit has fought this turn already"), whether the boss is the target or its ring pulls it
	# in, since its fight cannot be left.
	var all_in := boss != null and (targets.has(boss) or (r["joins"] as Array).has(boss))
	for m in (mechs() if all_in else r["in_range"]):
		if m != pinned and not m.is_static() and (all_in or actions_left(m) > 0):
			eligible.append(m)
	r["eligible"] = eligible
	r["pinned"] = pinned
	r["forced"] = pinned != null
	r["all_in"] = all_in
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
	for m in (r["eligible"] if bool(r["all_in"]) and not machines.is_empty() else machines):
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
	sk.committed = boss_fight   # no withdrawing from the boss's fight
	# A fight is a barrier: what came before it is played out on the map and cannot be taken
	# back (Ryan, 25 October: the undo runs in order, always).
	history.clear()
	planned.clear()
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
	if orders.get(m.id, null) == target:
		return true
	_push(m)
	orders[m.id] = target
	return true


func cancel_order(m: Unit) -> void:
	if m != null and orders.has(m.id):
		_push(m)
		orders.erase(m.id)


## A tap or a drag onto a pack (bible section 5), as one step and one undo: along a drawn route
## first if one was drawn, then the order from its end if the pack is in range there; with no
## route, from the farthest hex in range its move left reaches, or where it stands. A second tap
## on the pack it is already ordered onto takes the order back. What happened: "ordered",
## "moved" (the route ended out of range: it moved, and no order), "cancelled", "refused" (not
## a pack that may be fought now, or no action left), "out_of_reach", "no_room" (a carrier's
## block does not fit where the route ends) or "blocked" (the route cannot be walked).
func order_onto(m: Unit, target: Unit, draft: Array = []) -> String:
	if m == null or state != State.PLAN:
		return "refused"
	if draft.is_empty() and order_of(m) == target:
		cancel_order(m)
		return "cancelled"
	if not can_target(target) or actions_left(m) <= 0:
		return "refused"
	var snap := _snapshot(m)
	_batch += 1
	_batch_dirty = false
	var out := _order_onto(m, target, draft)
	_batch -= 1
	if _batch_dirty:
		history.append(snap)
	return out


func _order_onto(m: Unit, target: Unit, draft: Array) -> String:
	if not draft.is_empty():
		if not move_along(m, draft):
			return "no_room" if not (draft_landing(m, draft).get("bad", []) as Array).is_empty() else "blocked"
	else:
		var h := attack_hex(m, target)
		if h == NO_HEX:
			return "out_of_reach"
		if h != m.pos and move_to(m, h).is_empty():
			return "out_of_reach"
	if order(m, target):
		return "ordered"
	return "moved" if _batch_dirty else "out_of_reach"


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
	var r := roster(first)
	if bool(r.get("all_in", false)):
		team = (r["eligible"] as Array).duplicate()   # one order on the boss's fight brings every machine
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
	moved.clear()
	action_hexes.clear()
	fought.clear()
	orders.clear()
	history.clear()
	planned.clear()
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


## What a skirmish of this battle calls up content with (a summon, a split, a part regrowing):
## the content database's foes. A fight resumed from a save takes it too (the mechanics audit,
## 25 October: without it a resumed fight never split, summoned or regrew).
func foe_factory() -> Callable:
	return func(foe_id: String) -> Foe: return db.make_foe(foe_id) if db.foes.has(foe_id) else null


func _build_skirmish(group: Array) -> Skirmish:
	var sk := Skirmish.new(rng.randi(), columns)
	sk.terrain = ground_terrain(group)
	sk.foe_factory = foe_factory()   # a summoning action calls up content
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
		moved.erase(ms.unit.id)
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
