class_name BattleBot
extends RefCounted

## Plays a whole battle headless, for the runner (6 October; the per-battle measures the
## economy waits on, bible section 10). The map layer is the defence rule (the long wall brief,
## docs/briefs/long_wall_build.md section 5), plain and nothing cleverer: every fight a hunter
## forced first, the caught machine's allies walking into reach of its hunters; then each machine
## with an action, in roster order, is ordered onto the pack it can stand beside this turn that
## reaches the wall soonest (one on the apron first, then by the turns its planned walk needs to
## reach the apron), ties by the larger threat rating, then the nearer; machines ordered onto one
## pack fight it together; a machine with no pack in reach takes a cache its move reaches (the
## nearest, the higher kind on a tie: the field's loot, claimed as the turn ends, 7 November), else
## moves toward the pack that reaches the wall soonest. It never fights the sealed boss; the unsealed boss is a pack like any other to
## the rule. No reading of a fight's odds and no holding back: every fight is played by `Policy`
## at the rung given and fought out (there is no withdrawal). It is a floor, not a player. As
## each turn opens it reads the pressure ratio (pressure()). The squad-as-one rule and the turtle
## and detaching personas of 26 and 30 October went with the brief.
##
## The other rule, MUSTER, is a player that gathers (the anchor's reads of 12 November, built 16
## November on Ryan's word; `muster_orders`): the catches first as above, then each pack in the
## order it reaches the wall takes as many machines as it is rated, the nearest that can reach
## it this turn; a pack that cannot have its rating is fought one short when it strikes the wall
## this coming turn, and is gathered on otherwise, its rating's count of the nearest machines
## walking toward it and holding off every other pack; a machine left over takes a cache or
## closes on the pack that reaches the wall soonest. The boss, once its seal breaks, comes
## first: the race for it, since its fall is the battle's (the anchor's reads raced for it too).
## The defence rule sent one or two machines at an elite rated for four and lost that fight, so
## a campaign read measured its orders.

const MAX_PHASES := 120   # a battle the bot cannot finish in this many turns is stalled

## The map's rule: DEFENCE, the floor (the header); MUSTER, the player that gathers.
enum Rule { DEFENCE, MUSTER }

var rule: int = Rule.DEFENCE
var kind: int = Policy.GREEDY
var guard_weight: float = 1.0   # the fight bot's habit, passed to every fight (Policy.guard_weight: the aggressor, near nothing)
var short_at_wall := true       # the mustering player fights a pack one short when it strikes the wall this coming turn; off, it gathers its rating and lets the strike land (a what-if of 19 November)
var rng := RandomNumberGenerator.new()
var phases: int = 0
var fights: int = 0
var fights_won: int = 0
var stalled: bool = false
var stalled_fights: int = 0   # fights past the fight bot's round cap (Policy.MAX_ROUNDS)
var stalemates: int = 0       # fights with ten rounds running of nothing changed (Policy.stalemate), counted apart
var spends: Dictionary = {}   # component id -> times spent, over every fight
## One entry a fight: [machines in it, machines on the field, packs in it, won, the packs held by
## size, its threat rating (the largest of its packs'), its rounds, the hull its machines lost,
## their hull at its start, the machines it wrecked, its kind (fight_kind)].
var fight_sizes: Array = []
## The pressure ratio as each player's turn opened (pressure(): the long wall brief, section 5).
var ratios: Array[float] = []


static func make(kind_arg: int, seed_value: int = 0, rule_arg: int = Rule.DEFENCE) -> BattleBot:
	var bot := BattleBot.new()
	bot.kind = kind_arg
	bot.rng.seed = seed_value
	bot.rule = rule_arg
	return bot


## Play `b` to its end (or MAX_PHASES turns). Returns its outcome.
func play(b: Battle) -> int:
	while b.state == Battle.State.PLAN:
		if phases >= MAX_PHASES:
			stalled = true
			break
		take_turn(b)
		if b.state != Battle.State.PLAN:
			break
		b.end_turn()
		phases += 1
	return b.outcome


## One player's turn by the defence rule (the header).
func take_turn(b: Battle) -> void:
	ratios.append(pressure(b))
	var guard := 0
	while not b.forced.is_empty() and b.state == Battle.State.PLAN and guard < 16:
		guard += 1
		# The catch comes first, but the caught machine's allies may move before it opens (the
		# prey alone cannot), so they walk into range of the hunters and join it rather than
		# leave the prey to fight alone (26 October).
		var hunters: Array[Unit] = []
		for h in b.forced[0]["hunters"]:
			hunters.append(h)
		var prey: Unit = b.forced[0]["prey"]
		for m in b.mechs():
			if m == prey or not b.can_move(m) or hunters.is_empty():
				continue
			var near := _nearest(m.pos, hunters)
			if Battlefield.unit_distance(m, near) > m.attack_range:
				_close_on(b, m, near)
		var r := b.roster()
		_fight(b, b.attack(null, r.get("eligible", [])))
	if rule == Rule.MUSTER:
		_muster_turn(b)
		return
	guard = 0
	while b.state == Battle.State.PLAN and guard < 8:
		guard += 1
		if b.field.packs().is_empty():
			return
		var walks := b.field.plan_walks()
		for m in b.mechs():
			if b.state != Battle.State.PLAN or b.actions_left(m) <= 0 or b.order_of(m) != null:
				continue
			var near := soonest(b, walks, m, true)
			if near != null:
				b.order_onto(m, near)
			elif b.can_move(m):
				var cache := cache_in_reach(b, m)
				if cache != Battlefield.NO_HEX:
					b.move_to(m, cache)
				else:
					var far := soonest(b, walks, m, false)
					if far != null:
						_close_on(b, m, far)
		if b.next_fight().is_empty():
			return
		while b.state == Battle.State.PLAN and not b.next_fight().is_empty():
			var sk := b.engage()
			if sk == null:
				break
			_fight(b, sk)


## The mustering player's turn past the catches (the header): orders as `muster_orders` gives
## them, a second look once the machines that gathered have moved (a gathering that ends beside
## its pack fights it the same turn), the fights they queue fought, and again while a fight's end
## frees machines to act.
func _muster_turn(b: Battle) -> void:
	var gathering := {}
	var guard := 0
	while b.state == Battle.State.PLAN and guard < 8:
		guard += 1
		if b.field.packs().is_empty():
			return
		muster_orders(b, gathering)
		if b.next_fight().is_empty() and not gathering.is_empty():
			muster_orders(b, gathering)
		if b.next_fight().is_empty():
			return
		while b.state == Battle.State.PLAN and not b.next_fight().is_empty():
			var sk := b.engage()
			if sk == null:
				break
			_fight(b, sk)


## The mustering player's orders for the turn as the field stands (the header): each pack the
## machines may be ordered onto, in the order it reaches the wall (by_wall), takes its rating's
## count of the free machines that can reach it this turn, the nearest, its rating capped at the
## machines standing; short of that it is fought one short when it strikes the wall this coming
## turn (turns_to_wall at one or none), and otherwise gathered on: its rating's count of the
## nearest free machines walk toward it and hold, kept in `gathering` (machine id -> the pack)
## for the rest of the turn, free for that pack alone. A machine left free takes a cache its move
## reaches, else closes on the pack that reaches the wall soonest. Fights nothing: the orders
## wait for ENGAGE.
func muster_orders(b: Battle, gathering: Dictionary = {}) -> void:
	var walks := b.field.plan_walks()
	var free: Array[Unit] = []
	for m in b.mechs():
		if b.actions_left(m) > 0 and b.order_of(m) == null and not b.is_pinned(m):
			free.append(m)
	var standing := b.mechs().size()
	for p in by_wall(b, walks):
		if free.is_empty():
			break
		var need := mini(maxi(1, p.squad), standing)
		var mine: Array[Unit] = []   # the free machines this pack may have: none held for another standing pack
		for m in free:
			var held: Unit = gathering.get(m.id, null)
			if held == null or held == p or not b.field.units.has(held):
				mine.append(m)
		var reach: Array[Unit] = []
		for m in mine:
			if b.attack_hex(m, p) != Battle.NO_HEX:
				reach.append(m)
		reach.sort_custom(func(x: Unit, y: Unit) -> bool: return Battlefield.unit_distance(x, p) < Battlefield.unit_distance(y, p))
		var strikes := turns_to_wall(b, p, walks.get(p.id, null)) <= 1
		if reach.size() >= need or (short_at_wall and strikes and not reach.is_empty() and reach.size() >= need - 1):
			for m in reach.slice(0, need):
				b.order_onto(m, p)
				free.erase(m)
				gathering.erase(m.id)
			continue
		mine.sort_custom(func(x: Unit, y: Unit) -> bool: return Battlefield.unit_distance(x, p) < Battlefield.unit_distance(y, p))
		for m in mine.slice(0, need):
			if b.can_move(m):
				_close_on(b, m, p)
			gathering[m.id] = p
			free.erase(m)
	for m in free:
		if gathering.has(m.id) and b.field.units.has(gathering[m.id]):
			continue   # held for its pack, which wanted it no further this time
		if b.state != Battle.State.PLAN or not b.can_move(m):
			continue
		var cache := cache_in_reach(b, m)
		if cache != Battlefield.NO_HEX:
			b.move_to(m, cache)
		else:
			var far := soonest(b, walks, m, false)
			if far != null:
				_close_on(b, m, far)


## The packs the machines may be ordered onto (never the sealed boss), in the order they reach
## the wall (turns_to_wall), ties by the larger threat rating, then the nearer to a machine; the
## unsealed boss ahead of them all (the race for it).
static func by_wall(b: Battle, walks: Dictionary) -> Array[Unit]:
	var out: Array[Unit] = []
	var keys := {}
	for p in b.field.packs():
		if not b.can_target(p):
			continue
		var near := 1 << 30
		for m in b.mechs():
			near = mini(near, Battlefield.unit_distance(m, p))
		keys[p.id] = Vector3i(-1 if p.is_boss else turns_to_wall(b, p, walks.get(p.id, null)), -p.squad, near)
		out.append(p)
	out.sort_custom(func(x: Unit, y: Unit) -> bool:
		var kx: Vector3i = keys[x.id]
		var ky: Vector3i = keys[y.id]
		return kx.x < ky.x or (kx.x == ky.x and (kx.y < ky.y or (kx.y == ky.y and kx.z < ky.z))))
	return out


## The pack the defence rule sends `m` at: among the packs it may be ordered onto (never the
## sealed boss), those its move can bring it beside this turn when `in_reach`, else all of them,
## the one that reaches the wall soonest, ties by the larger threat rating, then the nearer;
## null when none.
static func soonest(b: Battle, walks: Dictionary, m: Unit, in_reach: bool) -> Unit:
	var best: Unit = null
	var best_key := Vector3i(1 << 30, 0, 0)
	for p in b.field.packs():
		if not b.can_target(p):
			continue
		if in_reach and b.attack_hex(m, p) == Battle.NO_HEX:
			continue
		var key := Vector3i(turns_to_wall(b, p, walks.get(p.id, null)), -p.squad, Battlefield.unit_distance(m, p))
		if best == null or key.x < best_key.x or (key.x == best_key.x and (key.y < best_key.y or (key.y == best_key.y and key.z < best_key.z))):
			best = p
			best_key = key
	return best


## The cache a machine's move reaches this turn (the field's loot, 7 November): the nearest, the
## higher kind on a tie; NO_HEX for none.
static func cache_in_reach(b: Battle, m: Unit) -> Vector2i:
	var dests := b.destinations_for(m)
	var best := Battlefield.NO_HEX
	var key := Vector2i(1 << 30, 0)
	for c in b.field.caches:
		var h: Vector2i = c["pos"]
		if not dests.has(h):
			continue
		var k := Vector2i(Hex.distance(m.pos, h), -int(c.get("tier", 1)))
		if best == Battlefield.NO_HEX or k.x < key.x or (k.x == key.x and k.y < key.y):
			best = h
			key = k
	return best


## The turns a pack needs to reach the wall: none on the apron, one when its planned walk ends
## there, else one more for every move of its own the rows left past its walk's end take.
static func turns_to_wall(b: Battle, sq: Unit, w: Battlefield.Walk) -> int:
	if b.field.on_apron(sq, sq.pos):
		return 0
	if w != null and b.field.on_apron(sq, w.end):
		return 1
	var end: Vector2i = w.end if w != null else sq.pos
	var rows := maxi(0, b.field.apron_row() - Hex.axial_to_offset(end).y)
	return 1 + int(ceil(float(rows) / float(maxi(1, sq.movespeed))))


## The pressure ratio as a turn opens (the long wall brief, section 5): the threat ratings of
## the packs on the apron and of those whose planned walk ends there this coming enemy turn,
## over the machines standing. A formation and a patrol arriving read 1.0 against four machines,
## the three and one; two formations 1.5.
static func pressure(b: Battle) -> float:
	var walks := b.field.plan_walks()
	var demand := 0
	for sq in b.field.packs():
		var w: Battlefield.Walk = walks.get(sq.id, null)
		if b.field.on_apron(sq, sq.pos) or (w != null and b.field.on_apron(sq, w.end)):
			demand += sq.squad
	return float(demand) / float(maxi(1, b.mechs().size()))


## Walk a machine to the hex it can reach nearest the target.
func _close_on(b: Battle, m: Unit, target: Unit) -> void:
	var dests := b.destinations_for(m)
	var best := m.pos
	var best_d := _distance(m.pos, target)
	for h in dests.keys():
		var d := _distance(h, target)
		if d < best_d:
			best = h
			best_d = d
	if best != m.pos:
		b.move_to(m, best)


## One fight, played out by the fight bot to the foes' fall or the team's.
func _fight(b: Battle, sk: Skirmish) -> void:
	if sk == null:
		return
	sk.begin()
	var held := {"patrol": 0, "formation": 0, "elite": 0, "boss": 0}
	for p in sk.packs:
		var key := "boss" if p.is_boss else (p.composition_size if held.has(p.composition_size) else "patrol")
		held[key] = int(held[key]) + 1
	var squad := 0
	for p in sk.packs:
		squad = maxi(squad, p.squad)
	var hull_before := 0
	for ms in sk.mechs:
		hull_before += maxi(0, ms.unit.hull)
	var size := [sk.mechs.size(), b.mechs().size(), sk.packs.size(), false, held, squad, 0, 0, hull_before, 0, fight_kind(sk)]
	var pol := Policy.make(kind, rng.randi())
	pol.guard_weight = guard_weight
	if pol.play(sk) == Skirmish.Outcome.VICTORY:
		fights_won += 1
		size[3] = true
	var hull_after := 0
	var wrecked := 0
	for ms in sk.mechs:
		hull_after += maxi(0, ms.unit.hull)
		if ms.unit.hull <= 0:
			wrecked += 1
	size[6] = sk.round
	size[7] = hull_before - hull_after
	size[9] = wrecked
	if pol.stalled:
		stalled_fights += 1
	if pol.stalemate:
		stalemates += 1
	fight_sizes.append(size)
	fights += 1
	for cid in pol.spends.keys():
		spends[cid] = int(spends.get(cid, 0)) + int(pol.spends[cid])
	b.finish_skirmish()


## What a fight held, as the runners name it: "boss", "elite", "formation", or a patrol by the
## machines it is rated for ("patrol for 1", the lone duel; "patrol for 2", a hunting pack or a
## duel's pair), by the largest of its packs.
static func fight_kind(sk: Skirmish) -> String:
	var out := ""
	var squad := 0
	for p in sk.packs:
		if p.is_boss:
			return "boss"
		if p.composition_size == "elite":
			out = "elite"
		elif p.composition_size == "formation" and out != "elite":
			out = "formation"
		squad = maxi(squad, p.squad)
	return out if not out.is_empty() else "patrol for %d" % maxi(1, squad)


static func _nearest(from: Vector2i, enemies: Array[Unit]) -> Unit:
	var best: Unit = enemies[0]
	var best_d := _distance(from, best)
	for e in enemies:
		var d := _distance(from, e)
		if d < best_d:
			best = e
			best_d = d
	return best


static func _distance(from: Vector2i, u: Unit) -> int:
	var d := 1 << 30
	for h in u.hexes():
		d = mini(d, Hex.distance(from, h))
	return d
