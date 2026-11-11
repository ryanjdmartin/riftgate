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

const MAX_PHASES := 120   # a battle the bot cannot finish in this many turns is stalled


var kind: int = Policy.GREEDY
var rng := RandomNumberGenerator.new()
var phases: int = 0
var fights: int = 0
var fights_won: int = 0
var stalled: bool = false
var stalled_fights: int = 0   # fights past the fight bot's round cap (Policy.MAX_ROUNDS)
var stalemates: int = 0       # fights with ten rounds running of nothing changed (Policy.stalemate), counted apart
var spends: Dictionary = {}   # component id -> times spent, over every fight
## One entry a fight: [machines in it, machines on the field, packs in it, won, the packs held by
## size, its threat rating (the largest of its packs')].
var fight_sizes: Array = []
## The pressure ratio as each player's turn opened (pressure(): the long wall brief, section 5).
var ratios: Array[float] = []


static func make(kind_arg: int, seed_value: int = 0) -> BattleBot:
	var bot := BattleBot.new()
	bot.kind = kind_arg
	bot.rng.seed = seed_value
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
	var size := [sk.mechs.size(), b.mechs().size(), sk.packs.size(), false, held, squad]
	var pol := Policy.make(kind, rng.randi())
	if pol.play(sk) == Skirmish.Outcome.VICTORY:
		fights_won += 1
		size[3] = true
	if pol.stalled:
		stalled_fights += 1
	if pol.stalemate:
		stalemates += 1
	fight_sizes.append(size)
	fights += 1
	for cid in pol.spends.keys():
		spends[cid] = int(spends.get(cid, 0)) + int(pol.spends[cid])
	b.finish_skirmish()


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
