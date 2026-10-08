class_name BattleBot
extends RefCounted

## Plays a whole battle headless, for the runner (6 October; the per-battle measures the
## economy waits on, bible section 10). The map layer is one plain rule: each machine, in
## roster order, walks to the reachable hex nearest the nearest enemy, pack or boss, so the
## bot hunts every pack and then the boss. Every fight is played by `Policy` at the rung
## given. It is a floor, not a player: nothing here blocks lanes, guards the gate or picks
## a fight, so read what it loses as the cost of not thinking on the map.

const MAX_PHASES := 120   # a battle the bot cannot finish is stalled


var kind: int = Policy.GREEDY
var rng := RandomNumberGenerator.new()
var phases: int = 0
var fights: int = 0
var fights_won: int = 0
var stalled: bool = false
var spends: Dictionary = {}   # component id -> times spent, over every fight
## One entry a fight: [machines in it, machines on the field, packs in it, won]. The
## engagement zones decide who fights, so a fight need not hold the whole squad.
var fight_sizes: Array = []


static func make(kind_arg: int, seed_value: int = 0) -> BattleBot:
	var bot := BattleBot.new()
	bot.kind = kind_arg
	bot.rng.seed = seed_value
	return bot


## Play `b` to its end (or MAX_PHASES). Returns its outcome.
func play(b: Battle) -> int:
	while b.state != Battle.State.DONE:
		if b.state == Battle.State.PLAN:
			if phases >= MAX_PHASES:
				stalled = true
				break
			plan(b)
			b.commit()
			phases += 1
		if b.state == Battle.State.SKIRMISH:
			var sk := b.open_next_skirmish()
			if sk == null:
				continue
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
	return b.outcome


## Every machine's route for this phase.
func plan(b: Battle) -> void:
	var enemies: Array[Unit] = []
	for u in b.field.units:
		if u.is_enemy():
			enemies.append(u)
	if enemies.is_empty():
		return
	for m in b.mechs():
		var target := _nearest(m.pos, enemies)
		var dests := b.destinations_for(m)
		var best := m.pos
		var best_d := _distance(m.pos, target)
		for h in dests.keys():
			var d := _distance(h, target)
			if d < best_d:
				best = h
				best_d = d
		if best != m.pos:
			b.set_route(m, best)


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
