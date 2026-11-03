class_name BattleBot
extends RefCounted

## Plays a whole battle headless, for the runner (6 October; the per-battle measures the
## economy waits on, bible section 10). The map layer is one plain rule, in the redesigned
## round (bible section 4): first every fight a hunter forced, with every machine that can
## join; then the squad moves as one (the four-machines row's default, 26 October): every
## machine with an action left walks toward the pack nearest the squad, pack or boss, and the
## pack the most machines can reach is attacked with all of them (`as_one` false walks each
## machine toward its own nearest enemy, the rule before, kept so the two can be compared:
## it split the squad into lone fights three times in four). Every fight is played by
## `Policy` at the rung given. It is a floor, not a player: nothing here guards the gate,
## splits a formation or picks a fight, so read what it loses as the cost of not thinking on
## the map. Its one habit is the fight bot's persona (`withdraw_below`, 26 October, the
## foes' fresh start): a fight it is losing is left under the line, except a fight a hunter
## forced, which a withdrawal would only leave caught.

const MAX_PHASES := 120   # a battle the bot cannot finish in this many turns is stalled


var kind: int = Policy.GREEDY
var as_one: bool = true       # the squad walks as one, on the pack nearest it; false, each machine on its own nearest enemy
var withdraw_below: int = 0   # persona (Policy.withdraw_below): withdraw a fight once the fighters' hull is under this percent; 0 never
## The turtle (the pacing session, 30 October: the stall read): the squad holds the rows before
## the gate and fights only what reaches it, never walking more than TURTLE_REACH hexes north
## of where it started; what it banks, loses and the turn it breaks is the stall's price.
var turtle: bool = false
const TURTLE_REACH := 2
## The detaching persona (30 October): one machine is sent at the nearest patrol within
## DETACH_REACH of it while the body fights the nearest formation, so the price of a
## detachment is read beside the squad as one.
var detach: bool = false
const DETACH_REACH := 5
var _start_rows: Dictionary = {}   # machine id -> the row it started on (the turtle's line)
var detachments: int = 0           # fights a lone machine was sent to by the detaching persona
var rng := RandomNumberGenerator.new()
var phases: int = 0
var fights: int = 0
var fights_won: int = 0
var withdrawals: int = 0      # fights the persona withdrew from
var stalled: bool = false
var spends: Dictionary = {}   # component id -> times spent, over every fight
## One entry a fight: [machines in it, machines on the field, packs in it, won, withdrew].
## Rings and attack range decide who fights, so a fight need not hold the whole squad.
var fight_sizes: Array = []


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


## One player's turn: the forced fights; then every machine with an action left walks toward
## its nearest enemy, and the pack the most machines can reach is attacked with all of them,
## again while any pack is in reach; a tireless machine's second action goes round again.
func take_turn(b: Battle) -> void:
	if _start_rows.is_empty():
		for m in b.mechs():
			_start_rows[m.id] = Hex.axial_to_offset(m.pos).y
	var guard := 0
	while not b.forced.is_empty() and b.state == Battle.State.PLAN and guard < 16:
		guard += 1
		# The catch comes first, but the caught machine's allies may move before it opens (the
		# prey alone cannot), so they walk into range of the hunters and join it rather than
		# leave the prey to fight alone (26 October: before this, a catch was fought by whoever
		# happened to stand within range).
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
		_fight(b, b.attack(null, r.get("eligible", [])), true)
	guard = 0
	while b.state == Battle.State.PLAN and guard < 8:
		guard += 1
		if b.field.packs().is_empty():
			return
		var sent: Unit = null
		if detach:
			sent = _detach(b)
		var squad_target: Unit = _squad_target(b) if as_one else null
		for m in b.mechs():
			if not b.can_move(m) or m == sent:
				continue
			var target := squad_target if squad_target != null else _nearest(m.pos, b.field.packs())
			if turtle and not _within_the_line(m, target):
				continue   # the turtle never walks out to meet it
			if Battlefield.unit_distance(m, target) > m.attack_range:
				_close_on(b, m, target)
		var fought := false
		while b.state == Battle.State.PLAN:
			var aim := _best_target(b)
			if aim == null:
				break
			_fight(b, b.attack(aim, b.roster(aim).get("eligible", [])))
			fought = true
		if not fought:
			return


## The pack nearest the squad as a whole: the least summed distance from every machine with
## an action left (every machine when none has one), the first in field order on a tie.
func _squad_target(b: Battle) -> Unit:
	var movers: Array = []
	for m in b.mechs():
		if b.actions_left(m) > 0:
			movers.append(m)
	if movers.is_empty():
		movers = b.mechs()
	var best: Unit = null
	var best_d := 1 << 30
	for p in b.field.packs():
		var d := 0
		for m in movers:
			d += Battlefield.unit_distance(m, p)
		if best == null or d < best_d:
			best = p
			best_d = d
	return best


## The pack the most ready machines can reach, nearest the gate on a tie; null when none can.
## A fight needs an order, which needs a machine with an action left within its attack range
## of the pack (Battle.order; the screen's ENGAGE); only then does the boss's fight bring every
## machine (the roster's all_in), so the bot never opens the boss's fight from across the map.
func _best_target(b: Battle) -> Unit:
	var best: Unit = null
	var best_n := 0
	for p in b.field.packs():
		var r := b.roster(p)
		var ordered := false
		for m in r.get("in_range", []):
			if b.actions_left(m) > 0:
				ordered = true
				break
		if not ordered:
			continue
		var n := (r.get("eligible", []) as Array).size()
		if n > best_n:
			best = p
			best_n = n
	return best


## Walk a machine to the hex it can reach nearest the target; the turtle only to a hex within
## its reach of the line it started on.
func _close_on(b: Battle, m: Unit, target: Unit) -> void:
	var dests := b.destinations_for(m)
	var best := m.pos
	var best_d := _distance(m.pos, target)
	for h in dests.keys():
		if turtle and Hex.axial_to_offset(h).y < int(_start_rows.get(m.id, 0)) - TURTLE_REACH:
			continue
		var d := _distance(h, target)
		if d < best_d:
			best = h
			best_d = d
	if best != m.pos:
		b.move_to(m, best)


## Whether a pack stands near enough the turtle's line for a machine to meet it without
## leaving the line: within the machine's move and its reach of the line.
func _within_the_line(m: Unit, target: Unit) -> bool:
	var row := Hex.axial_to_offset(target.pos).y
	return row >= int(_start_rows.get(m.id, 0)) - TURTLE_REACH - m.movespeed - m.attack_range


## The detaching persona's move: the nearest patrol (a composition of that size, or a pack of
## four or fewer) within DETACH_REACH of some machine with an action left, and that machine
## sent at it alone, fighting it where it can; the machine sent, or null.
func _detach(b: Battle) -> Unit:
	var best: Unit = null
	var best_pack: Unit = null
	var best_d := DETACH_REACH + 1
	for p in b.field.packs():
		if p.is_boss or p.sealed or not (p.composition_size == "patrol" or (p.composition_size.is_empty() and p.strength <= 4)):
			continue
		for m in b.mechs():
			if not b.can_move(m):
				continue
			var d := Battlefield.unit_distance(m, p)
			if d < best_d:
				best = m
				best_pack = p
				best_d = d
	if best == null:
		return null
	if Battlefield.unit_distance(best, best_pack) > best.attack_range:
		_close_on(b, best, best_pack)
	if b.actions_left(best) > 0 and b.in_range_from(best, best.pos, best_pack) and b.can_target(best_pack):
		var r := b.roster(best_pack)
		if not r.is_empty() and not bool(r.get("all_in", false)):
			detachments += 1
			_fight(b, b.attack(best_pack, [best]))
	return best


## One fight, played out by the fight bot. A fight a hunter forced (`forced`) is never
## withdrawn from: the prey stays caught and the hunter's volley lands all the same, so the
## persona would buy nothing but the same fight next turn.
func _fight(b: Battle, sk: Skirmish, forced: bool = false) -> void:
	if sk == null:
		return
	sk.begin()
	var held := {"patrol": 0, "formation": 0, "elite": 0, "boss": 0}
	for p in sk.packs:
		var key := "boss" if p.is_boss else (p.composition_size if held.has(p.composition_size) else "patrol")
		held[key] = int(held[key]) + 1
	var size := [sk.mechs.size(), b.mechs().size(), sk.packs.size(), false, false, held]
	var pol := Policy.make(kind, rng.randi())
	pol.withdraw_below = 0 if forced else withdraw_below
	if pol.play(sk) == Skirmish.Outcome.VICTORY:
		fights_won += 1
		size[3] = true
	if pol.withdrew:
		withdrawals += 1
		size[4] = true
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
