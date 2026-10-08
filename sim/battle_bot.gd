class_name BattleBot
extends RefCounted

## Plays a whole battle headless, for the runner (6 October; the per-battle measures the
## economy waits on, bible section 10). The map layer is one plain rule, in the redesigned
## round (bible section 4): first every fight a hunter forced, with every machine that can
## join; then each machine with an action left, in roster order, walks toward the nearest
## enemy, pack or boss, and attacks the nearest one in its range with every machine that can
## join. Every fight is played by `Policy` at the rung given. It is a floor, not a player:
## nothing here guards the gate, splits a formation or picks a fight, so read what it loses
## as the cost of not thinking on the map.

const MAX_PHASES := 120   # a battle the bot cannot finish in this many turns is stalled


var kind: int = Policy.GREEDY
var rng := RandomNumberGenerator.new()
var phases: int = 0
var fights: int = 0
var fights_won: int = 0
var stalled: bool = false
var spends: Dictionary = {}   # component id -> times spent, over every fight
## One entry a fight: [machines in it, machines on the field, packs in it, won]. Rings and
## attack range decide who fights, so a fight need not hold the whole squad.
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


## One player's turn: the forced fights, then every machine's move and attack.
func take_turn(b: Battle) -> void:
	var guard := 0
	while not b.forced.is_empty() and b.state == Battle.State.PLAN and guard < 16:
		guard += 1
		var r := b.roster()
		_fight(b, b.attack(null, r.get("eligible", [])))
	var acted := true
	guard = 0
	while acted and b.state == Battle.State.PLAN and guard < 16:
		guard += 1
		acted = false
		for m in b.mechs():
			if b.state != Battle.State.PLAN:
				return
			if b.actions_left(m) <= 0 or not b.field.units.has(m):
				continue
			var enemies: Array[Unit] = b.field.packs()
			if enemies.is_empty():
				return
			var target := _nearest(m.pos, enemies)
			if Battlefield.unit_distance(m, target) > m.attack_range:
				_close_on(b, m, target)
			var in_range: Array[Unit] = []
			for e in enemies:
				if Battlefield.unit_distance(m, e) <= m.attack_range:
					in_range.append(e)
			if in_range.is_empty():
				continue
			var aim := _nearest(m.pos, in_range)
			var r := b.roster(aim)
			_fight(b, b.attack(aim, r.get("eligible", [])))
			acted = true


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


func _fight(b: Battle, sk: Skirmish) -> void:
	if sk == null:
		return
	sk.begin()
	var size := [sk.mechs.size(), b.mechs().size(), sk.packs.size(), false]
	var pol := Policy.make(kind, rng.randi())
	if pol.play(sk) == Skirmish.Outcome.VICTORY:
		fights_won += 1
		size[3] = true
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
