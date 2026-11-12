class_name Skirmish
extends RefCounted

## The dice skirmish. Mechs have no positions. Enemies stand in a two-rank, four-column
## formation, a pack what its eight slots hold: nothing steps into a kill's slot (no
## reinforcement inside a fight, Ryan, 6 November). The rules are docs/rules.md's.
##
## Round loop:
##   start_round()       passive cooling, roll every live mech's die, telegraph foe intents
##   reroll([...])       up to REROLLS_PER_ROUND times, any subset of unspent mech dice,
##                       before or after spending others: a low damage roll is information;
##                       a reroll always lands on a different face (see Die.reroll)
##   assign(i, target)   spend a mech's face on a foe (attacks) or a mech (shield, vent);
##                       a kill clears its slot at once; a decided fight ends at once
##   end_round()         the player's turn ends: a machine's Burning adds its heat and loses a
##                       stack, Scorched goes, then heat over the cap burns hull; then
##                       burn ticks, foes act, the dead are cleared, mech statuses tick, a
##                       part due grows back in its corpse's slot, outcome is checked
##   can_withdraw()      false: there is no withdrawal (the long wall brief 3.5); a fight ends
##                       in the foes' fall or the team's
##   undo()              takes back the last spend or reroll, in the order made, back to the
##                       last roll (the round's, a reroll's draw, a spend's own); the screen's
##                       fight keeps the snapshots (keeps_undo); can_undo(), undo_depth()
##
## The player's damage is in fives, everything else in tens. Nothing rolls but the dice.

enum State { SETUP, ROUND_START, ASSIGN, DONE }
enum Outcome { NONE, VICTORY, DEFEAT, WITHDRAWN }   # WITHDRAWN is never produced since the long wall brief 3.5 (there is no withdrawal); kept for the saves and the runners' tallies
## How a spend at a foe pays for its hits (_pay_hits), the caller's to say: the firer's gauge takes
## the heat the pipeline makes of them (HEAT); a forging machine's gun paid ammo before it fired,
## and only a foe's debuff still heats it (AMMO: the Musk Ox's Desublimation Forge, the salvo's
## magazine); a vent's blast is one hit inside the vent's spend, which paid its own heat (VENT).
## Passed as an `int`, as every enum here is (CLAUDE.md).
enum Pays { HEAT, AMMO, VENT }

const DEFAULT_COLUMNS := 4   # the formation's width (Ryan, 23 September: four plays better than three)
const REROLLS_PER_ROUND := 2   # two since 6 November (Ryan: a reroll gained is worth more, and two is the standard; a trial)
## The shapes a foe past a strike's target stands in (area by shape, numbered: Ryan, 28 October),
## each its own number in place of the roll (area_shapes, area_number).
const AREA_ROW := 1      # beside the target in its rank: Spread's, Splash's
const AREA_COLUMN := 2   # the other rank of its column: Penetrate's, Splash's
const AREA_ALL := 3      # any other foe a reach over every foe adds: nothing
const AREA_CHAIN := 4    # every other Shocked foe on the field: Chain's conductors (28 October)
const INJURY_MIN_HULL_PCT := 25     # a single hull hit this big (percent of max) destroys the entry the die lands on
static var injury_pct: int = INJURY_MIN_HULL_PCT   # the threshold read; tools/balance.gd's --injury sets it for one run's what-if
## The injury rule's switch: off, for now (Ryan, 9 November, from his play of Phase 2 and the
## refit pass, docs/briefs/refit_pass.md: "I'm fine disabling component destruction entirely to
## test these points. It was placed to offer a balancing lever between tanks and dps, an issue
## that clearly no longer exists"; "Lets turn destruction off completely, for now, and see where
## that gets us"). Off, no blow injures: no entry breaks in a fight and no component is destroyed,
## in the game and the runners alike. The rule stands whole behind the switch until the pass's
## reads and his play say; a test of the rule, and tools/balance.gd's --injury, turn it on.
static var injuries: bool = false
static var overheat_scale: int = 1   # hull an overheat burns a point of heat past the maximum; tools/balance.gd's --overheat sets it for one run's what-if (30 October)
static var pilot: Dictionary = {}   # chassis id -> heat it gains as each round opens, a what-if for tools/balance.gd's --pilot (the Whip Scorpion's pilot light, 3 November); never content
# Two more what-ifs on the overheat (Ryan, 30 October), set by tools/balance.gd for one run: a
# burn reaching the injury threshold burns out the component that took the gauge past the
# maximum (--burnout), and every overheat Corrupts that component, so many stacks (--overheat-corrupt N).
static var overheat_burnout: bool = false
static var overheat_corrupt: int = 0


class MechState:
	var unit: Unit
	var die: Die
	var heat: int = 0:
		set(v):
			heat = v
			if heat <= heat_max:
				hot_entry = -1   # back at or under the maximum (a vent, the settle): no spend stands accused (the overheat's what-ifs)
	var heat_max: int = 60
	var face_index: int = -1
	var locked: bool = false
	var assigned: bool = false
	var passed: bool = false    # it ended the player's turn with an entry it could have spent (a pass: the Whip Scorpion's release reads it)
	var free_rerolls: int = 0   # rerolls of this die alone left this round, from a passive, on top of the team's
	var ammo: int = 0           # the magazine (the Musk Ox's Desublimation Forge): a resource beside heat, never a status
	var ammo_max: int = 0       # its size; 0 for a machine that forges nothing
	var hot_entry: int = -1     # the entry whose spend last took the gauge past its maximum this turn (the overheat's what-ifs)

	## The entry showing, as it is right now: a disabled one shows as blank (the component
	## itself is untouched; the status is what says so).
	func face() -> Face:
		if face_index < 0 or face_index >= die.faces.size():
			return null
		if Effects.is_entry_disabled(unit, face_index):
			return Face.disabled_stand_in(die.faces[face_index])
		return die.faces[face_index]

	func alive() -> bool:
		return unit.hull > 0


## What a weapon's or a debuff's hits did (_hit), for the spend that fired them to tell them and pay
## for them (_finish_hits).
class Hits:
	var reach: int = 0              # the entry's reach as the hits began (the runner's reach tally)
	var aimed_back := false         # the target stood in the back rank as they began (the tally)
	var heat := 0                   # the spend's heat through the pipeline, once a spend; a shield's burn takes its share (_zap)
	var vent := 0                   # what the firer's modifiers vent off it
	var dealt := 0                  # hull the blows took off foes standing, for the tally
	var total := 0                  # what the hits landed on their own foes, for the log and the screen
	var base := 0                   # their numbers before the pipeline, for the screen's flash
	var armoured := 0               # what the target's armour took off, for the log
	var fired := 0                  # what Vents all fired into every blow, for the log
	var vented_all := 0             # the heat Vents all emptied, for the log
	var reached: Array = []         # every foe the blows reached, felled or not (the casings' refund)
	var thawed := 0                 # Cryo stacks the hits spent, cooling the hitter once its heat lands (_pay_hits)
	var swept: Array[String] = []   # a Sweep's shots, the foe and what it took, for the log
	var sweep_rank := -1            # the rank a Sweep fired along
	## What the hits aimed at the spend's target fired at it, for the Mine its machine leaves there
	## (Ryan, 9 November: "the mine should take the entire result of the spend, then apply it"):
	## each status's stacks every hit laid, as its machine deepened and doubled them, its Purge
	## and Chain at every hit's number, the flags once (Skirmish.mine_riders' shape).
	var mine := {"stacks": {}, "dispel": 0, "chain": 0, "keywords": []}

	func mine_stack(sid: String, n: int) -> void:
		if n <= 0:
			return
		var st: Dictionary = mine["stacks"]
		st[sid] = int(st.get(sid, 0)) + n

	func mine_flag(k: int) -> void:
		var kws: Array = mine["keywords"]
		var name := str(Face.KEYWORD_NAMES.get(k, ""))
		if not name.is_empty() and not kws.has(name):
			kws.append(name)


var rng := RandomNumberGenerator.new()
var mechs: Array[MechState] = []
var packs: Array[Unit] = []
var columns: int = DEFAULT_COLUMNS
var terrain: int = BattleMap.Terrain.PLAIN   # the ground the fight is on (the contact hex), for the screen
var ground: String = "plain"                 # its word for the header, a wall by its look (BattleMap.ground_id)
var front: Array = []
var back: Array = []
var reinforcements: Array[Foe] = []   # the foes dealt to the fight before it begins; `begin` stands them in the formation and none waits after (no reinforcement inside a fight: Ryan, 6 November)
## A fallen part whose core will regrow it holds its slot until it does (Ryan, 7 November: "anything
## that regrows should leave it's corpse in place, to make it clear"; "How on earth would that
## spot ever get filled?"): Vector2i(rank, column) -> the fallen part. Nothing steps into it.
var corpses: Dictionary = {}
var round: int = 0
var rerolls_left: int = 0
var state: int = State.SETUP
var outcome: int = Outcome.NONE
var destroyed: int = 0   # components destroyed this fight, for the balance runner (the hangar's destroyed-is-gone rule, bible section 10, depends on the rate)
var log: Array[String] = []

## The most recent attack, for the screen to show: {mech, target, rolled, final, tags}; the tags it
## was fired with (the Cottonmouth's drum adds its own) say how the screen animates it, a lunge in
## place of a kick back for melee with nothing that crosses the field.
var last_roll: Dictionary = {}
## The heat released by passed turns as the last enemy turn ended (the Whip Scorpion's), for the
## screen: {mech, rank, shots, blows (spend_blows' shape)} each. Cleared as a turn ends.
var releases: Array = []
var _held: Dictionary = {}   # Foe -> the status ids a pin holds from this round's halving, read as the round's statuses run out
## The statuses no unit's clock runs down at this round's end, either side's (the Soul Siphon's
## hold, Ryan, 12 November: "No Empowered decays this round. And I mean none, not ally or enemy"):
## a rule of the round and no status on anyone, so a Ward turns nothing away and what a unit gains
## of it later in the round is held too. Set by a spend whose entry holds one (Face.holds_all),
## read as the round's statuses run down (_finish_round) and cleared there; saved with the fight.
var round_holds: Array = []
var last_blast: Dictionary = {}   # the last vent blast, {mech, foe, dealt}, for the screen; cleared each round
## The fight's share of the run's Sponsorship measures (the bible's Sponsorship row; tallied 21
## October, never shown live): damage the team took on shield and armour, dice spent on
## entries that deal damage (a vent that blasts among them) and on entries that deal none.
## The battle adds them up with the hexes its machines move; each maker's content names its own.
var sponsorship := {"guarded": 0, "damaging_spends": 0, "quiet_spends": 0}
## What each reach did this fight, for the balance runner's reach table (tools/balance.gd):
## by reach name, the spends, the hull its blows took off foes, the spends aimed at the back
## rank and the heat paid. Never read by the game.
var reach_tally: Dictionary = {}
## The damage the foes dealt by the rank they struck from. The runner's alone.
var taken_by_rank: Dictionary = {}
## The returns a spend holds until it ends (Ryan, 7 November: "check death - end spend -
## revive/split"; "nothing normal should hit a unit and it's revive/split/spawn in the same
## spend"): while a die entry is spent its kills are checked and their slots cleared as ever,
## but a foe getting back up and a split's arrivals wait in these, [foe, rank, column] each,
## until the spend is done (_release_returns). Outside a spend they return at once. The hold is
## the spend's scope, opened and closed by _assign alone and read by every death check inside
## it, the falls a Mine's blast in the spend makes included (a blast set off by a spend is part
## of it: the audit's Question 9, settled with the Lammergeier's rework, 9 November).
var _holding_returns := false
var _risers: Array = []
var _splitters: Array = []
## The Mines of the foes the death check under way has cleared, each blowing once their slots
## are clear and before what the falls bring back stands (_clear_dead_slots): {mine, rank, col,
## massive, where}.
var _blasts: Array = []
## The enemy's turn is under way (_enemy_turn): a Mine's Disrupt does nothing then, the foes' moves
## being under way.
var _enemy_acting := false
## Every blow of the last enemy turn, in order, for the screen to replay:
## {foe, mech (index), absorbed, through, blocked, broke_shield, injured, shield, hull,
## seq, name, boss, all}. `seq` orders it among the turn's specials; `name` is the move's shown
## name, `boss` whether a massive foe struck and `all` whether the blow struck every machine,
## for the plaque (decided 9 October; `all` 15 October).
var turn_events: Array = []
## The last acts of foes that fell during the latest spend (15 October), for the screen to name
## and land: {foe, name, mechs (indices struck), gauges (each struck machine's [shield, hull] as
## the act met it, so the screen lands the act's damage with the act)}.
var last_acts: Array = []
## Every foe a kill brought back this round, in order (Ryan, 7 November: "a revive or a split
## SHOULD be a preview chip that shows up, taking the place of a death chip"): {foe, how:
## "rises" for a foe getting back up, "splits" for one whose arrivals stood}. The round preview
## reads its copy's; cleared as each round opens.
var returned: Array = []
## Every blow the latest spend landed on a foe, in the order it landed, for the screen to land a
## blow at a time in step with the strikes (Ryan, 2 November: "flechette pod and other multistrikes
## need to clearly show the strikes in order, with individual ticks of damage ... damage needs to
## be timed to the animation across the board"): {foe, strike (from 0, the zap after the last),
## taken (what the blow took off its HP), hp (after it), kind ("strike", "area", "chain", "spill",
## "zap", "mine", or "miss" for a Sweep's shot at an empty column, its foe null and its `slot` the
## [rank, column] it landed in)}, a blow on a foe an earlier hit felled included. Cleared as a
## spend begins; the rules never read it.
var spend_blows: Array = []
## Every special of the last enemy turn (a defend, buff or debuff in place of a blow), for
## the screen to announce on its plaque in order: {foe, name, kind, seq}.
var turn_specials: Array = []
var _seq: int = 0   # the order of the turn's blows and specials, shared by both lists
## A merge's lift on the merger (30 October), granted once its own move has spent what it carried,
## so the lift rides its next move: foe -> the Empowered it gains.
var _lift_after: Dictionary = {}
## The team's kills this fight (is_kill), counted at the death check: a spend's kills are the
## difference across it (the kill triggers), and a grudge reads the whole.
var team_kills: int = 0
## The same by pack and type, pack id -> {content id: kills}: salvage and the menace a kill is
## worth (kills_by_type).
var kills: Dictionary = {}
## The fights the rule before the long wall brief kept from a withdrawal: a battle's boss fight
## (Ryan, 25 October: "the player is committed to closing the rift or getting scrapped trying")
## and every quick campaign fight. Since the brief (3.5) no fight is left, so it marks those
## fights for the screen and the save and refuses nothing more.
var committed := false
## A dealt composition's layout (the long wall brief, section 6; Battle._build_skirmish passes it
## when the fight holds that one pack): eight cells, the front rank's four then the back's, each
## a foe id or "" for empty. The first deployment places by it; empty, the heaviest hitters first.
var layout: Array = []
## The twin slot (Ryan, 26 October: the Gel's halves "should exist as a pair taking the place of
## one unit"): Vector2i(rank, column) -> the right-hand half, the left standing in front or back
## as any foe. The slot is one slot to the formation, full while either stands, so nothing else
## joins it; an area blow that reaches it reaches both, a single-target blow the one it is spent
## on. When one falls the other keeps the slot alone,
## and with both gone it is a plain slot again: the pair exists only as its split made it.
var twins: Dictionary = {}
## The runner's Mine tally (the game never reads it): spends that left a Mine, Mines that blew,
## the drone's detonations and the Mines the Contractor gathered, and the HP the blasts took.
var mine_tally := {"laid": 0, "blasts": 0, "detonated": 0, "gathered": 0, "damage": 0}
## Every mech that burnt at the end of the last enemy turn, for the screen to land after
## the blows: {mech (index), over, hull}.
var overheats: Array = []
## The foes that have finished their action in the enemy turn under way, so a suppress that
## lands on one of them afterwards (a machine's loop catching a status it just gained) skips
## its next action rather than an action already taken.
var _acted: Array = []
## The round preview (Ryan, 26 October: it "should account for every single thing that will
## happen other than 1) random active effects ... and 2) player decisions"): set on a copy of the
## fight that plays the rest of the round (preview_round), so every rule runs as it will, and a
## random draw is never made there: the copy holds it back and notes it, and the preview
## promises nothing a roll decides.
var previewing := false
var preview_notes: Array = []   # what the copy held back: {kind: pick, blast; foe or mech}
## Rerolls a foe's roar has cost the team for the coming round.
var reroll_debt: int = 0
## The team's rerolls banked as the last player's turn ended (Maverick's Playbook, the Giant
## Petrel's; built 30 October), back at the next round's start while a banker fights.
var banked: int = 0
## Makes a foe from a content id, for a summoning action; set by the battle (the content
## database), left empty by tests, in which case a summon calls nothing up.
var foe_factory: Callable = Callable()
## The targeting rule: empty for the aims (decided 2 October), "lowest" for the rule before
## it (every foe on the machine with the lowest shield, then the lowest hull), kept for the
## balance runner's comparison and nothing else.
var targeting_override: String = ""
## The shared pick of a rank that fires as one this round, by rank; cleared as the round opens.
var _focus: Dictionary = {}
## The undo (Ryan, 2 November, the randomness pass: "undo to your last roll"): every spend and
## reroll since the last draw from the stream can be taken back, in the order made, the fight
## put back as it was before each. A draw is the floor, since a draw taken back would show its
## result for free: the round's roll, a reroll that draws, a spend that draws inside itself
## (Rapid's reroll, a roll again, the Scorpion's blast's pick). A stepping die draws nothing, so
## its step is no floor. The screen's fight keeps the snapshots (the save's own dictionaries,
## SaveGame.snapshot_skirmish); the runners and the preview's copy keep none, and the bars are
## kept whoever plays.
var keeps_undo := false
var history: Array[Dictionary] = []   # the fight before each spend or reroll since the last roll, in order
var roll_marks: Array[int] = []       # the log's length at each roll of the fight: the trail's bars


func _init(seed_value: int = 0, columns_arg: int = DEFAULT_COLUMNS) -> void:
	rng.seed = seed_value
	columns = maxi(1, columns_arg)
	front.resize(columns)
	front.fill(null)
	back.resize(columns)
	back.fill(null)


# ---------------------------------------------------------------- setup

func add_mech(u: Unit, d: Die = null) -> MechState:
	var ms := MechState.new()
	ms.unit = u
	ms.die = d if d != null else u.die
	ms.heat_max = u.heat_max
	# The magazine opens each fight at its start (the Musk Ox's Forge, Ryan's go of 21 October).
	var forge := Effects.forge_rule(u)
	if not forge.is_empty():
		ms.ammo_max = maxi(1, int(forge.get("value", 10)))
		ms.ammo = clampi(int(forge.get("start", 0)), 0, ms.ammo_max)
	mechs.append(ms)
	return ms


func add_foes(list: Array, from_pack: Unit = null) -> void:
	for f in list:
		if from_pack != null:
			f.pack_id = from_pack.id
		reinforcements.append(f)
	if from_pack != null and not packs.has(from_pack):
		packs.append(from_pack)


func begin() -> void:
	# First deployment: heaviest hitters first, so they stand left and strike first, and the
	# player sees the big blow coming from the jump. Ties keep arrival order, so a formation
	# is predictable.
	var ordered: Array = reinforcements.duplicate()
	var ranked: Array = []
	for i in range(ordered.size()):
		ranked.append([ordered[i].threat(), -i, ordered[i]])
	ranked.sort_custom(func(a, b) -> bool: return a[0] > b[0] or (a[0] == b[0] and a[1] > b[1]))
	reinforcements.clear()
	for r in ranked:
		reinforcements.append(r[2])
	if layout.is_empty():
		_first_deployment(false)
	else:
		_deploy_layout()
	if not reinforcements.is_empty():
		# A pack is what its eight slots hold (no reinforcement inside a fight). Every fight the
		# game deals is one pack, validated to fit, and the harness fits its own, so nothing
		# reaches here; a fight given more stays honest all the same: what does not stand was
		# never in it and is no kill (the tally counts only what a death check clears).
		log.append("%d more could not stand: the formation is full" % reinforcements.size())
		reinforcements.clear()
	_refresh_guards()
	_refresh_allies()
	state = State.ROUND_START
	# Passives that fire once as the fight begins.
	for ms in live_mechs():
		_fired(ms, Effects.fire(ms.unit, "on_skirmish_start"), "as the fight begins")


# ---------------------------------------------------------------- queries

## Every foe on the field once. A massive foe sits in both slots of its column.
func field_foes() -> Array[Foe]:
	var out: Array[Foe] = []
	for r in range(2):
		var row: Array = front if r == 0 else back
		for col in range(row.size()):
			var f: Foe = row[col]
			if f != null and not out.has(f):
				out.append(f)
			var t: Foe = twins.get(Vector2i(r, col), null)
			if t != null:
				out.append(t)   # the right-hand half acts after the left
	return out


## The other half of a twin slot's pair (the Gel's), or null.
func twin_of(f: Foe) -> Foe:
	if f == null or f.rank < 0 or f.column < 0:
		return null
	var key := Vector2i(f.rank, f.column)
	if not twins.has(key):
		return null
	var right: Foe = twins[key]
	var left := foe_at(f.rank, f.column)
	if f == right:
		return left
	return right if f == left else null


## A slot's foes, the left first: one, two for a twin slot's pair, or none.
func slot_foes(rank: int, col: int) -> Array[Foe]:
	var out: Array[Foe] = []
	var lead := foe_at(rank, col)
	if lead != null:
		out.append(lead)
	var t: Foe = twins.get(Vector2i(rank, col), null)
	if t != null:
		out.append(t)
	return out


func foe_at(rank: int, col: int) -> Foe:
	return front[col] if rank == 0 else back[col]


func is_exposed(col: int) -> bool:
	return front[col] == null


## Is this foe in Direct reach: the front rank, a back-rank foe whose column's front is empty
## (the layout, nothing said about it), or any foe carrying Exposed (the debuff, 21 October).
func in_direct_reach(foe: Foe) -> bool:
	if foe == null or foe.rank < 0:
		return false
	return foe.rank == 0 or is_exposed(foe.column) or Effects.has(foe, "exposure")


func live_mechs() -> Array[MechState]:
	var out: Array[MechState] = []
	for m in mechs:
		if m.alive():
			out.append(m)
	return out


## The live machines a foe may pick or a teammate may land a shield, a vent or a buff on, and
## every one a blow or a special at every machine reaches (a foe's turn, a last act, the forecast,
## a scorch all; the audit's ninth bug, 8 November): one out of the fight is none of them, Phased
## (the Swallowtail's Mooring Screens, 21 October) or Swallowed (a foe's swallow, 30 October).
func targetable_mechs() -> Array[MechState]:
	var out: Array[MechState] = []
	for m in live_mechs():
		if not is_out(m):
			out.append(m)
	return out


## Is the machine Phased (cannot act, take damage or be targeted until the round's end)?
static func is_phased(ms: MechState) -> bool:
	return ms != null and Effects.has(ms.unit, "phased")


## Is the machine Swallowed (a foe's swallow, 30 October: out of the fight until its rounds run
## out or its swallower falls)?
static func is_swallowed(ms: MechState) -> bool:
	return ms != null and Effects.has(ms.unit, "swallowed")


## Is the machine out of the fight: Phased or Swallowed? Nothing reaches it, nobody may target
## it, and it takes no damage; its own cooling, ticks and overheats are its own.
static func is_out(ms: MechState) -> bool:
	return is_phased(ms) or is_swallowed(ms)


## The pack's own foes left standing, on the field or waiting: what it keeps on the map. A pack
## is one foe type times a strength (docs/rules.md, the packs), so a foe that joined it in the
## fight (a Gel's half, a raised Revenant, a part) is never a survivor: counted, it would come
## back as one of the pack's own and the pack would grow (the mechanics audit, 25 October).
func survivors_for(sq: Unit) -> int:
	var n := 0
	for f in field_foes():
		if f.pack_id == sq.id and f.alive() and is_own(sq, f):
			n += 1
	for f in reinforcements:
		if f.pack_id == sq.id and is_own(sq, f):
			n += 1
	return n


## Is this foe one of the pack's own, the foes it came with (a readied one that got back up
## among them), rather than one that joined it in the fight (a Gel's half, a summon, a part)?
## A boss unit's own are its commanders and its escort; a pack's, its foe type.
static func is_own(sq: Unit, f: Foe) -> bool:
	if f.joined:
		return false   # a half, a summon or a part: never own, whatever its type
	if sq.is_boss:
		return f.commands or f.escorts
	if not sq.members.is_empty():
		return sq.member_ids().has(f.content_id)   # a composition's own are its members' types
	return sq.foe_id.is_empty() or f.content_id == sq.foe_id


## A pack's members left after this fight, [[content id, count], ...] in the pack's own order
## (a boss unit's: its escort, never its commanders): its own foes alive on the field or
## waiting. What the map keeps of a composition (Battlefield.apply_skirmish_result).
func members_left(sq: Unit) -> Array:
	var counts := {}
	for f in field_foes():
		if f.pack_id == sq.id and f.alive() and is_own(sq, f) and not f.commands:
			counts[f.content_id] = int(counts.get(f.content_id, 0)) + 1
	for f in reinforcements:
		if f.pack_id == sq.id and is_own(sq, f) and not f.commands:
			counts[f.content_id] = int(counts.get(f.content_id, 0)) + 1
	var out: Array = []
	for m in sq.member_list():
		var cid := str(m[0])
		if int(counts.get(cid, 0)) > 0:
			out.append([cid, int(counts[cid])])
			counts.erase(cid)
	for cid in counts.keys():
		if int(counts[cid]) > 0:
			out.append([str(cid), int(counts[cid])])
	return out


## The foes of a pack this fight killed, by type (content id -> count), for the menace each is
## worth (the Rupture meter, Anathema and salvage, 30 October): every kill (is_kill) of its own
## and of the foes that joined it, counted at the death check. Read before the map takes the
## result.
func kills_by_type(sq: Unit) -> Dictionary:
	return (kills.get(sq.id, {}) as Dictionary).duplicate()


## What a kill is (Ryan, 8 November): a foe the death check clears that stays down. A foe getting
## back up or splitting goes on ("If a foe is killed during the death check and revives, that
## shouldn't count for kill triggers. Same with gel splits"); a part is never one, felled alone or
## taken with its core, since a core and its parts are one unit whose kill is the core's
## ("technically one giant unit, thematically, the parts are extensions"; "I thought I said only
## the core counts"); a Bomb's burst was never the team's; and a merge's foes never reach the
## death check. The kill triggers, the grudge, salvage and menace all read it.
func is_kill(f: Foe) -> bool:
	return not f.stays_down and not Effects.has(f, "risen") and not f.on_death.has("summon") and not is_part(f)


## A core's part (parts_of): a foe whose type a core of its pack on the field names, the core
## standing or felled.
func is_part(f: Foe) -> bool:
	for c in field_foes():
		if c != f and c.pack_id == f.pack_id and c.part_ids.has(f.content_id):
			return true
	return false


## A kill counted, as the death check clears it: the team's whole and its pack's by type.
func _count_kill(f: Foe) -> void:
	team_kills += 1
	var t: Dictionary = kills.get(f.pack_id, {})
	t[f.content_id] = int(t.get(f.content_id, 0)) + 1
	kills[f.pack_id] = t


## Every kill a death check counts, whoever or whatever made it (on_foe_killed; the Ammit's Souls,
## Ryan, 12 November: "Souls granted by any kill"): each machine standing in the fight fires its
## passives on the count, so an ally's kill, a burn's tick and a Mine's blast all feed it, and a
## foe getting back up, a part or a Bomb's burst, no kill, feeds nothing.
func _foes_fell(n: int) -> void:
	if n <= 0:
		return
	for ms in live_mechs():
		var got := Effects.fire(ms.unit, "on_foe_killed", n)
		var parts := _apply(ms, got)
		if not parts.is_empty():
			log.append("%s: %s, %s" % [ms.unit.display_name, "a foe falls" if n == 1 else "%d foes fall" % n, ", ".join(_with_counts(ms, parts, got))])


## A trigger's log pieces with each status it granted read at its count as it stands ("Souls ×7"):
## a count the machine banks says where it is, as its chip does.
func _with_counts(ms: MechState, parts: Array[String], result: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for p in parts:
		if (result["statuses"] as Array).has(p):
			var n := 0
			for m in ms.unit.modifiers:
				if m.name == p:
					n += m.stacks
			out.append("%s ×%d" % [p, n])
		else:
			out.append(p)
	return out


## A boss unit's commanders still standing in this fight (Foe.commands: its boss, a final's
## hero, the finale's line), alive on the field, a readied one that got back up among them: their
## content ids, field first. The unit stands while one does.
func commanders_left(sq: Unit) -> Array:
	var out: Array = []
	for f in field_foes():
		if f.pack_id == sq.id and f.commands and f.alive():
			out.append(f.content_id)
	for f in reinforcements:
		if f.pack_id == sq.id and f.commands:
			out.append(f.content_id)
	return out


## A boss unit's escort left after this fight (Foe.escorts): its strength on the map.
func escort_left(sq: Unit) -> int:
	var n := 0
	for f in field_foes():
		if f.pack_id == sq.id and f.escorts and f.alive():
			n += 1
	for f in reinforcements:
		if f.pack_id == sq.id and f.escorts:
			n += 1
	return n


## The foes of a pack this fight killed, for the salvage the battle tallies ("a kill is a
## kill", the bible): its own that are gone, a pack's strength less its survivors or a boss
## unit's fallen commanders and escort, and every foe that joined it and fell for good (read
## before the map takes the result, while its lineup and strength are still the ones it came
## with).
func kills_for(sq: Unit) -> int:
	var n := 0
	for cid in kills_by_type(sq).keys():
		n += int(kills_by_type(sq)[cid])
	return n


func any_assigned() -> bool:
	for m in mechs:
		if m.assigned:
			return true
	return false


## There is no withdrawal (the long wall brief 3.5; Ryan, 6 November: "what if there's just NO
## withdrawal? Tactical options get removed, obviously, but it does simplify things a huge
## amount"): a fight ends in the foes' fall or the team's, at every state.
func can_withdraw() -> bool:
	return false


## The shield a weapon's spend burns in place of `heat` (the Storm Petrel's Riot Field Generator,
## Ryan's go of 21 October; built 30 October): as much of the gun's own heat as the shield holds
## as it stands, overshield included; the rest reaches the gauge, and so does a Scorched machine's
## extra, which heats the bar and never the shield (Ryan, 8 November: "scorch affects the actual
## heat bar, not the ammo cost ... Same as the storm petrel when its shield is up"; the forge
## splits it the same way, Effects.ammo_price). Nothing for equipment, a forging machine's gun
## (its heat is paid in ammo) or a machine whose shield pays nothing. `paid` is the shield a
## shield cost takes first, when the spend is still to come (the die as shown, shown_face): a
## strict cost is paid as the entry is spent, before the heat, and is never burnt into a blow
## (Ryan, 4 November, asking whether the passive turns every shield cost into damage: it does not).
static func shield_burn(ms: MechState, f: Face, heat: int, paid: int = 0) -> int:
	if ms == null or f == null or not f.is_weapon() or heat <= 0 or ms.ammo_max > 0 or not Effects.burns_shield(ms.unit):
		return 0
	var own := maxi(0, heat - Effects.debuff_heat(ms.unit, f))
	return mini(own, maxi(0, ms.unit.shield - paid))


## The blow the burn pays a foe after a weapon's strikes (the zap): what the shield paid, plain,
## through what the foe takes and its armour; nothing on a Guarded core, as every blow there.
static func zap_on(foe: Foe, burnt: int, by: MechState) -> int:
	if foe == null or burnt <= 0:
		return 0
	return maxi(0, Effects.damage_taken(foe, burnt, by.unit if by != null else null) - foe.armour_total())


## What a vent-on-fire attack adds to every blow from the heat it fires: its power_per_heat
## for each `per_heat` the machine carries right now (the Afterburner Cannon, 28 September;
## the step a field since the stock pass, 22 October).
static func heat_bonus(ms: MechState, f: Face) -> int:
	if f == null or not f.vents_all:
		return 0
	return f.power_per_heat * int(ms.heat / maxi(1, f.per_heat))


## The loads one shot of a hopper-firing attack takes (fires_hopper, the Bullion Fragmenter,
## 11 October): as many as the machine's hopper holds, up to the shot's most, so a full
## hopper feeds several shots rather than one. Read as the die is spent.
static func hopper_loads(u, f: Face) -> int:
	if f == null or f.fires_hopper <= 0:
		return 0
	return mini(Effects.stacks_of(u, "hopper"), f.fires_hopper)


## What the hopper adds to every blow of that shot.
static func hopper_bonus(u, f: Face) -> int:
	return hopper_loads(u, f) * f.power_per_load if f != null else 0


## The loads each foe a spend of this entry damages puts in its machine's hopper: the weapon's
## own number where it prints one (the Chainsaw Claw's two), else the machine's passive's for
## any weapon (the Ore Hopper's one, 31 October); equipment deals no damage and loads nothing.
static func hopper_fill_of(u, f: Face) -> int:
	if f == null or not f.is_weapon():
		return 0
	return f.fills_hopper if f.fills_hopper > 0 else Effects.hopper_fill(u)


## What one blow of an attack entry will deal, as the die shows it (decided 10 October, bible
## section 5: the game does the arithmetic and the player reads it): [low, high], equal for a
## flat entry. Without a target, every source that needs none: the pipeline's adds and
## multiplies, the heat a vent-on-fire shot fires, a raised ceiling. Over a foe, what it deals
## to that foe: its missing hull, conditions on it (a status it carries), what it takes (its
## Flak, a point a stack on a weapon's blow; a Guarded core's nothing) and its armour off the
## blow. A shock is left out, the foe's own chip, and spent by the first blow of many.
## `f` is the entry as this machine's passives make it (shown_face); [0, 0] for no attack.
## A split entry's base (the Skua's Split-cycle Breech, Ryan, 7 November: "base weapon damage is
## halved"; "the spirit of buffs and riders is they happen after"): the number and what the entry
## prints from its firer, divided by the split before the firer's modifiers, rounded down and never
## below one while there is a number at all (Ryan, 27 October: "rounded down, min 1", so a Twin
## Autoguns' 1 strikes 1 twice where it struck 0 twice); a number of nothing stays nothing. Every
## buff, passive and foe's condition then counts on each hit, whole.
static func split_share(roll: int, split: int) -> int:
	if split <= 1:
		return roll
	return maxi(1, roll / split) if roll > 0 else 0


func shown_number(ms: MechState, f: Face, target: Foe = null) -> int:
	if f == null or not f.is_attack():
		return 0
	var add := heat_bonus(ms, f) + hopper_bonus(ms.unit, f)   # what the entry prints from its firer, inside the pipeline
	var own := (f.missing_bonus(target) + f.consume_bonus(target)) if not f.is_debuff() else 0   # the foe's own reads, flat after it (the blow's order)
	# A split entry (the Skua's) shows a hit's blow: its base halved, rounded down, never below one, then the buffs.
	var d := int(Effects.attack(ms.unit, f, split_share(f.power + add, f.split), 0, target)["damage"]) + own
	if target != null:
		if not f.is_debuff():
			d = Effects.damage_taken(target, d, ms.unit, true, false)   # every add and multiply it takes (its Flak, a Guarded core's nothing) but a Shocked doubling, the foe's own chip
		d = maxi(0, d - target.armour_for(f))
	return d


## The shield an entry gives the machine it is spent on: its number (a shield's, or a vent's
## shield half, the combined entry), and on an ally what the spender's passives add from the
## heat that ally carries at the spend (shield_per_ally_heat; the Puffin's Slipstream
## Projector, 21 October), after the vent's half for a combined entry (the vent first, the
## shield reading what is left). The spend, the die dragged over the ally and the bot all
## read it here.
func shield_amount(ms: MechState, f: Face, who: MechState) -> int:
	if f == null:
		return 0
	if f.kind == Face.Kind.SHIELD and f.fills_shield:
		return maxi(0, who.unit.shield_max - who.unit.shield) if who != null else 0   # the Hoist's full reset
	var n := f.power if f.kind == Face.Kind.SHIELD else (f.shields if f.kind == Face.Kind.VENT else 0)
	if n <= 0:
		return 0
	if who != null and who != ms:
		var left := maxi(0, who.heat - f.vents) if f.kind == Face.Kind.SHIELD else maxi(0, who.heat - f.power)
		if f.cools_all:
			left = 0
		n += Effects.granted_shield(ms.unit, left)
	return n


## The shown number as the die prints it: one number, or the range; a debuff prints none (a
## gun whose blow is nothing here prints "0").
## The keywords a gate shuts on this foe (the gated stuns, 22 October): the die held over it
## strikes their chips. None without a foe in hand.
func shut_gates(ms: MechState, f: Face, foe: Foe) -> Array[int]:
	var out: Array[int] = []
	if f == null or foe == null:
		return out
	for k in f.keywords:
		if not Effects.gate_holds(ms.unit, f, k, foe):
			out.append(k)
		elif k == Face.Keyword.DISRUPT and foe.committed:
			out.append(k)   # an announced follow-up holds (2 November): the chip struck over it
	return out


func shown_number_text(ms: MechState, f: Face, target: Foe = null) -> String:
	if f == null or not f.is_attack() or f.is_debuff():
		return f.number_text() if f != null else ""
	# The blow alone: a blow a passive adds after the strikes (the Storm Petrel's zap) is its own
	# number in the die's passive box (after_blow), never joined to this one (Ryan, 4 November:
	# "not made the player do math").
	return str(shown_number(ms, f, target))


## The blow a machine's passive adds after a weapon's strikes, as the die's passive box prints it
## (a shield mark and the number, no sign): the Storm Petrel's zap, what its shield pays for the
## weapon's heat, over a foe through that foe's damage taken and armour (zap_on); 0 for an entry
## with none.
static func after_blow(ms: MechState, f: Face, target: Foe = null) -> int:
	if f == null or not f.is_weapon() or f.burns <= 0:
		return 0
	return zap_on(target, f.burns, ms) if target != null else f.burns


## Every live machine learns how many allies stand with it, for passives that read it.
func _refresh_allies() -> void:
	var n := live_mechs().size()
	for ms in mechs:
		ms.unit.allies = maxi(0, n - 1) if ms.alive() else 0


## The foes that will strike this mech when the round ends, in the order they act: alive,
## not suppressed, aimed at it with an attack (a foe bracing, rallying or roaring lands no
## blow), and not about to die to burn first.
func attackers_of(ms: MechState) -> Array[Foe]:
	var out: Array[Foe] = []
	for f in acting_on(ms):
		if f.attacks():
			out.append(f)
	return out


## Every foe that will act on this mech when the round ends, whatever its action: alive, not
## suppressed, showing intent on it (its pick, or a blow at every machine; a special that acts
## on nobody in particular shows none: Foe.intent_on), and not about to die to burn first. Its
## intent still shows on the screen whether its blow will land or not (Ryan, 4 November: "that
## is still possibly relevant information", an effect counting the intents on a machine).
func acting_on(ms: MechState) -> Array[Foe]:
	var out: Array[Foe] = []
	if is_out(ms):
		return out   # nothing reaches a machine out of the fight
	for f in field_foes():
		if not f.intent_on(ms.unit):
			continue
		if hp_after_ticks(f) <= 0:   # burns to death before it strikes
			continue
		out.append(f)
	return out


## The HP a foe's ticks leave it at the start of its action (its Burning, then Vitriol's share):
## static numbers, so its gauge shows the loss to come and a death before it acts (Ryan, 26
## October). At 0 it burns to death before it strikes: the forecast leaves its blow out and no
## rally of its lands, while its intent stays shown.
func hp_after_ticks(f: Foe) -> int:
	return maxi(0, f.hp - int(Effects.tick_preview(f)["hp"]))


func incoming_for(ms: MechState) -> int:
	var total := 0
	for f in attackers_of(ms):
		total += foe_blow(f) * f.strikes()
	return total


## The blow a foe's move lands, as its intent shows it (Ryan, 26 October: "The intents should
## take into account incoming buffs"): its own statuses and the rallies on their way to it
## (rallies_on), one damage formula, every add before the factor (Foe.damage_of).
func foe_blow(f: Foe) -> int:
	return f.damage_of(f.action, incoming_rally(f))


## The number a foe's intent shows: the blow as it would land (foe_blow) for a move that strikes
## or is still gathering to, its move's own value for any other (a rally's, a mend's). The one
## read for the field's chip and the readout's.
func intent_value(f: Foe) -> int:
	return foe_blow(f) if f.attacks() or f.gathering() else int(f.action.get("value", 0))


## What the rallies on their way to a foe add to its move (rallies_on), each at its move's value.
func incoming_rally(x: Foe) -> int:
	var n := 0
	for r in rallies_on(x):
		n += maxi(0, int(r.action.get("value", 0)))
	return n


## The foes whose rally reaches this one before its move lands this round: every other foe on
## the field rallying this round (rallies_now) and acting ahead of it. Nothing reaches a foe that
## has acted, one that stepped up this round (its next move is next round's), or a countdown still
## gathering, whose blow lands in a later round: its intent shows what it would deal now (Ryan, 8
## November: "It shouldn't forecast rounds in the future. Show what it would deal at the current
## game state"). A rallier killed, Suppressed or Disrupted drops out at once, so the intents do
## too; once a rally lands it is the foe's own Empowered.
func rallies_on(x: Foe) -> Array[Foe]:
	var out: Array[Foe] = []
	if x == null or not x.alive() or x.fresh or _acted.has(x) or x.gathering():
		return out
	for r in field_foes():
		if r == x:
			break
		if rallies_now(r):
			out.append(r)
	return out


## Will this foe's move this round rally the others: a rally, the foe alive and yet to act, not
## Suppressed, not gathering, not stepped up this round and not about to burn to death at its
## action.
func rallies_now(r: Foe) -> bool:
	if r == null or not r.alive() or r.fresh or r.is_suppressed() or r.gathering() or _acted.has(r):
		return false
	if Foe.is_attack_action(r.action) or str(r.action.get("effect", "")) != "rally":
		return false
	return hp_after_ticks(r) > 0


## The rest of the round as it stands (Ryan, 26 October: the preview "should account for every
## single thing that will happen other than 1) random active effects ... and 2) player decisions
## such as spending dice faces. Die faces only apply to the preview when hovered over a valid
## target"). A copy of the fight plays it out, every rule as it runs: the die in hand spent on
## `hover_target` when one is given, the end of the player's turn, the enemy's turn (each foe's
## move as announced: its heal, its death before it acts, a last act, a web's burst, a rally, a
## self-destruct) and the round's end. A pick made again (a foe whose machine fell first) is the
## next machine in line, so the copy strikes the machine the round will. Nothing random is
## drawn: a strike at a random foe among several is held back (`notes`), and a stun on a Numbed
## foe strips a stack as the fight would; the
## reinforcements are the next round's. Returns {"mechs": the forecast's keys for each machine by
## index, plus "coming" (the statuses the round lands on it: {id: {"stacks", "name",
## "description"}}), "foes": {foe on the field: {"hp", "alive", "struck" (the machines its blows
## land on, by index), "coming", "returns" ("rises" for a foe the round fells that gets back up,
## "splits" for one whose halves step up, "" for none)}}, "notes": what was held back}; the fight
## itself is untouched.
func preview_round(hover_mech: int = -1, hover_target = null) -> Dictionary:
	var copy: Skirmish = SaveGame.clone_skirmish(self)
	copy.previewing = true
	# Every status the copy's play lands (Ryan, 26 October: "All incoming chips should appear as
	# pulsing opacity versions"), noted by the copy's own machines and foes (Effects._record).
	var recorded: Array = []
	for cm in copy.mechs:
		cm.unit.recorder = recorded
	var ours := field_foes()
	var theirs := copy.field_foes()
	for cf in theirs:
		cf.recorder = recorded
	var back := {}   # the copy's foe -> ours
	for i in range(mini(ours.size(), theirs.size())):
		back[theirs[i]] = ours[i]
	var bite := 0
	var volatile := 0
	if hover_mech >= 0 and hover_mech < mechs.size() and hover_target != null:
		var t = hover_target
		if t is Foe:
			var at := ours.find(t)
			t = theirs[at] if at >= 0 and at < theirs.size() else null
		elif t is MechState:
			var at := mechs.find(t)
			t = copy.mechs[at] if at >= 0 else null
		if t != null:
			bite = pending_bite(mechs[hover_mech])
			volatile = pending_volatile(mechs[hover_mech])
			copy.assign(hover_mech, t)
	var events: Array = copy.turn_events.duplicate()   # a last act the spend set off lands now
	var over: Array[int] = []
	var standing: Array[int] = []
	over.resize(mechs.size())
	standing.resize(mechs.size())
	if copy.outcome == Outcome.NONE:
		copy._end_player_turn()
		for o in copy.overheats:
			over[int(o["mech"])] += int(o["over"])
	for i in range(mechs.size()):
		standing[i] = copy.mechs[i].unit.shield
	var heat_end: Array[int] = []
	for i in range(mechs.size()):
		heat_end.append(copy.mechs[i].heat + over[i])
	var played := copy.outcome == Outcome.NONE   # a spend that wins, or a burn that wrecks the last machine, ends the fight at once
	if played:
		copy._enemy_turn()
		events.append_array(copy.turn_events)
	var shield_hit: Array[int] = []
	for i in range(mechs.size()):
		shield_hit.append(copy.mechs[i].unit.shield)
	if played and copy.outcome == Outcome.NONE:
		copy._release_passes()   # a passed turn's heat, on the rank as the enemy's turn left it
	if played and copy.outcome == Outcome.NONE:   # a fight decided in the enemy's turn has no round's end
		copy._finish_round()
	var coming := {}   # the copy's unit or foe -> {status id: {"stacks", "name", "description"}}
	for r in recorded:
		var per: Dictionary = coming.get(r[0], {})
		var m: Effects.Modifier = r[1]
		var c: Dictionary = per.get(m.id, {"stacks": 0, "name": m.name, "description": m.description})
		c["stacks"] = int(c["stacks"]) + int(r[2])
		per[m.id] = c
		coming[r[0]] = per
	var out_mechs: Array = []
	for i in range(mechs.size()):
		var cm: MechState = copy.mechs[i]
		var incoming := 0
		var injures := false
		for ev in events:
			if int(ev.get("mech", -1)) == i:
				incoming += int(ev.get("amount", 0))
				injures = injures or bool(ev.get("injured", false))
		out_mechs.append({
			"coming": coming.get(cm.unit, {}),
			"incoming": incoming,
			"bite": bite if i == hover_mech else 0,
			"volatile": volatile if i == hover_mech else 0,
			"shield_after": cm.unit.shield,
			"hull_after": cm.unit.hull,
			"heat_end": heat_end[i],       # the gauge as the turn ends, uncapped: what the burn reads
			"heat_after": cm.heat,         # the gauge after the round
			"overheat": over[i],
			"breaks_shield": standing[i] > 0 and shield_hit[i] <= 0,
			"component_risk": injures,
			"destroyed": mechs[i].alive() and not cm.alive(),
		})
	# What a kill the round brings back (Ryan, 7 November: "a revive or a split SHOULD be a preview
	# chip that shows up, taking the place of a death chip"): the copy's foes that got back up or
	# split, by how; the last return of each counts.
	var came_back := {}
	for r in copy.returned:
		came_back[r["foe"]] = str(r["how"])
	var out_foes := {}
	for cf in back.keys():
		var struck: Array[int] = []
		for ev in events:
			if ev.get("foe", null) == cf and not struck.has(int(ev.get("mech", -1))):
				struck.append(int(ev.get("mech", -1)))
		out_foes[back[cf]] = {"hp": maxi(0, cf.hp), "alive": cf.alive(), "struck": struck, "coming": coming.get(cf, {}), "returns": str(came_back.get(cf, ""))}
	var notes: Array = []
	for n in copy.preview_notes:
		var d: Dictionary = n.duplicate()
		if d.get("foe") is Foe:
			d["foe"] = back.get(d["foe"], null)
		notes.append(d)
	return {"mechs": out_mechs, "foes": out_foes, "notes": notes}


## What a rally adds to this round's blows, on every machine they reach: each foe acting after
## the rallier with a blow landing this round, its blow with the rally less without, its strikes
## on its machines. The bot reads it as the rallier's threat, so killing, Suppressing or
## Disrupting the rallier weighs what it saves; the next round's share, on the foes that acted
## before it, is left out. Nothing for a foe whose move is no rally that will land.
func rally_worth(r: Foe) -> int:
	if not rallies_now(r):
		return 0
	var v := maxi(0, int(r.action.get("value", 0)))
	var total := 0
	for x in field_foes():
		if not rallies_on(x).has(r) or not x.attacks() or x.is_suppressed() or x.target == null:
			continue
		if hp_after_ticks(x) <= 0:
			continue   # its Burning kills it before it acts (the audit's fifteenth)
		var machines := targetable_mechs().size() if x.hits_all() else 1
		total += (foe_blow(x) - x.damage_of(x.action, incoming_rally(x) - v)) * x.strikes() * machines
	return total


## What spending the entry showing would cost its owner through Corrupted stacks: nothing
## for a blank (a blank is not spent) or a die already spent.
func pending_bite(ms: MechState) -> int:
	var f := ms.face()
	if f == null or ms.assigned or f.kind == Face.Kind.BLANK:
		return 0
	return Effects.corrupt_stacks(ms.unit, ms.face_index) * corrupt_bite()


## What a stack of Corrupted bites its owner each time its entry is spent: the corrupted
## status's own number (the stock pass's engine, 22 October; a constant before).
static func corrupt_bite() -> int:
	return Effects.status_value("corrupted", "corrupt_bite")


## The heat a weapon's hit sheds for its hitter for each stack of Cryo it spends on a foe:
## the Cryo status's own number (the stock pass's engine, 22 October; a constant before).
static func cryo_cool() -> int:
	return Effects.status_value("cryoed", "cool_hitter")


## What spending the entry showing costs its owner as a volatile component (the Arsenal's
## keyword, 28 September): hull straight away, past shield and armour, whatever the
## component does. Nothing for a die already spent or an entry that is not volatile.
func pending_volatile(ms: MechState) -> int:
	var f := ms.face()
	if f == null or ms.assigned:
		return 0
	return spend_bite(ms.unit, Effects.effective_face(ms.unit, f))


## The hull a volatile entry costs its owner per spend, the number its Volatile carries (a
## numbered keyword since the stock pass's engine, 22 October); zero for any other entry.
static func volatile_cost(f: Face) -> int:
	return f.volatile if f != null else 0


## The hull spending this entry costs its owner: a volatile bite, and a passive's price on
## every component spent (hull_per_spend; never on a blank, which is no component).
static func spend_bite(u, f: Face) -> int:
	if f == null:
		return 0
	var tithe := 0 if f.kind == Face.Kind.BLANK else Effects.hull_per_spend(u)
	return volatile_cost(f) + tithe


## What the end of the round does to this mech as the fight stands, no die counted: the bot's
## estimate, added up here without a copy of the fight (the screen reads preview_round, a copy
## playing the round out, the die in hand spent on it). Recomputed after every action, so
## shielding or killing an attacker moves the numbers at once. `extra_shield` asks the same
## question with that much more shield standing (a shield component about to be spent here), for
## whoever weighs one; `overshield` lets it pass the maximum, as a component with that keyword
## would. Each foe's blows walk the shield they meet (blows_on, the blow that lands' own
## arithmetic); heat is what the gauge holds, Burning's tick at the end of the player's turn and
## a seal's, before the enemy acts (11 and 13 October), the foes adding none outright (their fire
## leaves Burning and Scorched, which land on later turns), then a Siphon's heat with their blows.
func forecast(ms: MechState, extra_shield: int = 0, overshield: bool = false) -> Dictionary:
	var shield := ms.unit.shield + extra_shield if overshield else mini(maxi(ms.unit.shield_max, ms.unit.shield), ms.unit.shield + extra_shield)
	var hull := ms.unit.hull
	var incoming := 0
	var component_risk := false
	var walk := {"shield": shield, "barrier": Effects.has(ms.unit, "barrier")}
	var blows := 0
	for f in attackers_of(ms):
		incoming += foe_blow(f) * f.strikes()
		blows += f.strikes()
		for r in blows_on(ms, f, walk):
			hull -= int(r["through"])
			if r["injures"]:
				component_risk = true
	shield = int(walk["shield"])
	var heat_end := ms.heat + int(Effects.tick_preview(ms.unit, true)["heat"]) + seal_heat(ms)
	var over := maxi(0, heat_end - ms.heat_max)
	hull -= over * overheat_scale
	var heat_after := mini(heat_end, ms.heat_max) + int(Effects.tick_preview(ms.unit)["heat"]) + Effects.heat_per_blow(ms.unit) * blows
	return {
		"incoming": incoming,
		"shield_after": shield,
		"hull_after": hull,
		"heat_end": heat_end,       # the gauge as the turn ends, uncapped: what the burn reads
		"heat_after": heat_after,   # the gauge after the round: settled at the cap, then the foes' heat
		"overheat": over,
		"component_risk": component_risk,
		"destroyed": hull <= 0 and ms.alive(),
	}


## One foe's blows on a machine as they would land now, in order: each through what the
## machine takes (damage_taken), a Barrier that stands taking the first that deals anything,
## a breach unless a Ward turns it away, each against the shield the one before left. `walk`
## carries the shield and the Barrier from blow to blow, and from foe to foe for a caller
## walking every attacker: {"shield": int, "barrier": bool}, updated.
## Returns each blow's arithmetic (_blow_on's).
func blows_on(ms: MechState, f: Foe, walk: Dictionary) -> Array:
	var out: Array = []
	for s in range(f.strikes()):
		var r := _blow_on(ms, foe_blow(f), f, int(walk["shield"]), bool(walk.get("barrier", false)))
		if bool(r["barred"]):
			walk["barrier"] = false
		walk["shield"] = r["shield"]
		out.append(r)
	return out


## One foe's blow on a machine, the arithmetic the blow that lands (_damage_mech) and the
## forecast's walk (blows_on) share, changing nothing: what the machine takes of `amount`
## (damage_taken, the striker read for its statuses, a plate that stands with the shield reading
## `shield`, the shield this blow meets), a Barrier standing (`barrier`) taking it whole if it deals
## anything, a breach unless a Ward turns it away, then the shield, the armour (the machine's and
## what it holds against the striker's rank) and the hull (_blow). Returns _blow's dictionary
## with `amount` (the blow as it arrives, before a Barrier), `barred` and `warded` (a Ward turned
## its breach away).
func _blow_on(ms: MechState, amount: int, source: Foe, shield: int, barrier: bool) -> Dictionary:
	var arrived := Effects.damage_taken(ms.unit, amount, source, false, true, maxi(0, shield))
	var barred := arrived > 0 and barrier
	var warded := source.breaches() and Effects.has(ms.unit, "ward")
	var r := _blow(shield, ms.unit.hull_max, ms.unit.armour + Effects.armour_against(ms.unit, source.rank), 0 if barred else arrived, source.breaches() and not warded)
	r["amount"] = arrived
	r["barred"] = barred
	r["warded"] = warded
	return r


## Machines a shield, a vent or a buff may be spent on: itself, its allies, or both, as the
## component says (Ryan, 26 September: not every shield reaches an ally). Live machines only.
func machine_targets_for(ms: MechState, f: Face) -> Array[MechState]:
	var out: Array[MechState] = []
	if f == null or not f.on_machines() or cannot_pay(ms, f):
		return out
	for who in live_mechs():
		if who != ms and is_out(who):
			continue   # an ally out of the fight cannot be targeted (Ryan, 20 October)
		if f.act_again and (who == ms or not who.assigned):
			continue   # an ally acting again: one whose die is spent (the Reveille Horn's charged form)
		if f.action_price > 0 and who != ms and (not who.assigned or rerolls_left < f.action_price):
			continue   # an ally's action bought (the Immelmann Booster): one whose die is spent, while the team's rerolls pay its price
		if (who == ms and f.can_target_self()) or (who != ms and f.can_target_ally()):
			out.append(who)
	return out


## The machines an entry reaching every ally lands on (the Swallowtail's team shield, its
## Phased): every one it may target, the yet-to-act alone for a grant that needs it.
func reached_machines(ms: MechState, f: Face) -> Array[MechState]:
	var out: Array[MechState] = []
	for who in machine_targets_for(ms, f):
		if f.not_acted and who.assigned:
			continue
		out.append(who)
	return out


## Can this machine spend its entry charged (the Swallowtail's locked pieces; the Nemesis's
## Knuckles on its rage since 11 November): the entry has a charged form and its store holds the
## price.
func can_charge(ms: MechState) -> bool:
	var f := ms.face() if ms != null else null
	return f != null and not f.charged.is_empty() and charge_held(ms, f) >= f.charge_price()


## What the entry's charged store holds toward its price: the Muster's charges, or the stacks of
## any other store (the Nemesis's rage).
static func charge_held(ms: MechState, f: Face) -> int:
	if f.charge_store() == "muster":
		return Effects.muster_charges(ms.unit)
	return Effects.stacks_of(ms.unit, f.charge_store())


## Whether the entry goes out charged now (Ryan, 22 October: never primed, "it just gets used
## if it's up"): a muster pays for it and its charged form has somewhere to land, a foe in its
## reach or a machine it may be spent on (the Horn's act again an ally whose die is
## spent). A grant reaching every ally yet to act (the Mooring Screens' Phased) lands only while
## no ally has acted this round (Ryan, 22 October: else "it can be used as a selective
## protection which is not the intent"). A charged form with nothing to land on leaves the plain
## one, and the muster waits.
func charge_lands(ms: MechState) -> bool:
	if not can_charge(ms):
		return false
	var cf := ms.face().charged_form()
	if cf.is_attack():
		return not targets_for_face(ms, cf).is_empty()
	if cf.on_machines():
		var eff := Effects.effective_face(ms.unit, cf)
		if cf.reaches_all:
			if cf.not_acted:
				for who in machine_targets_for(ms, eff):
					if who != ms and who.assigned:
						return false   # an ally has acted: the whole team or nobody
			return not reached_machines(ms, eff).is_empty()
		return not machine_targets_for(ms, eff).is_empty()
	return false


## The entry as it would be spent: its charged form whenever it goes out charged, else itself.
func spend_face(ms: MechState) -> Face:
	var f := ms.face()
	if charge_lands(ms):
		return f.charged_form()
	return f


## Foes this mech's current face may be spent on.
func targets_for(mech_index: int) -> Array[Foe]:
	var ms := mechs[mech_index]
	return targets_for_face(ms, ms.face())


## Foes this mech could spend `f` on, whether or not the die shows it: the same reach rules,
## asked about any entry (a player weighing a reroll, or a bot weighing a die).
## The second targets a Swap entry takes beside its first (the Dingo's Combat Translocator, Ryan's
## go of 19 October): every other foe on the field and every empty slot, the slot as
## Vector2i(rank, column); never a massive foe, which fills its column and stays, and nothing
## for a massive first.
func swap_targets(first: Foe, carries: bool = false) -> Array:
	var out: Array = []
	if first == null or not first.alive() or (first.is_massive() and not carries):
		return out
	var pair := twin_of(first)
	for foe in field_foes():
		if foe != first and foe != pair and foe.alive() and (carries or not foe.is_massive()):
			out.append(foe)
	for col in range(columns):
		if front[col] == null and not corpses.has(Vector2i(0, col)):
			out.append(Vector2i(0, col))
		if back[col] == null and not corpses.has(Vector2i(1, col)):
			out.append(Vector2i(1, col))
	return out   # a slot a corpse holds is no empty slot: its part regrows there


## Does this entry, spent now, take a second target (a Swap)?
func needs_second(ms: MechState) -> bool:
	var f := ms.face()
	return f != null and Effects.effective_face(ms.unit, f).has(Face.Keyword.SWAP)


## Whether this machine's Swap carries a rider beside it (the Combat Translocator's Shock; Ryan,
## 11 November: "Translocator should still target two, always ... maybe you want to target two
## things and not have them move, just shock both of them"): such an entry may name a massive
## foe as either target, which stays where it stands, the rider landing on both all the same.
func swap_carries(ms: MechState) -> bool:
	var f := ms.face()
	if f == null:
		return false
	var ef := Effects.effective_face(ms.unit, f)
	return ef.has(Face.Keyword.SWAP) and ef.keywords.size() > 1


func targets_for_face(ms: MechState, f: Face) -> Array[Foe]:
	var out: Array[Foe] = []
	if f == null or not f.is_attack() or not can_fire(ms, f) or cannot_pay(ms, f):
		return out   # a dry gun on a forging machine (the Musk Ox's), or an entry whose price its machine cannot pay (a shield cost, a count it spends), has nothing it may be spent on
	# Reach: direct hits the front and any exposed column's back; indirect hits everyone; a
	# sweep is dropped on any foe and walks that foe's rank (Ryan, 3 November: "You pick a rank
	# and that's the rank it hits"). A foe already killed this round still stands until the dead
	# are cleared, but it is no target: a die spent on it would be wasted.
	var anyone := reach_of(ms, f) != Face.Reach.DIRECT
	for col in range(columns):
		for foe in slot_foes(0, col):
			if foe.alive() and not out.has(foe):
				out.append(foe)
		for foe in slot_foes(1, col):
			if not foe.alive() or out.has(foe):
				continue
			if anyone or in_direct_reach(foe):
				out.append(foe)
	var ef := Effects.effective_face(ms.unit, f)
	# A Swap moves its target, and a massive foe fills its column and stays (the Dingo's row).
	# A Swap that carries a rider beside it may still name a foe it cannot move (the Combat
	# Translocator's Shock, Ryan, 11 November: "not dead versus ... massives and bosses that can't
	# be swapped"), with its second target as ever.
	if ef.has(Face.Keyword.SWAP) and ef.keywords.size() <= 1:
		out = out.filter(func(foe: Foe) -> bool: return not foe.is_massive())
	return out


## A component's reach as it is right now: its own, unless the mech's passive says
## otherwise while a condition holds (a passive's set_reach). Computed on
## every read and never written to the component, so the answer always has a source: an
## ally reading the same component gets its own answer, and a suppressed passive stops
## answering.
func reach_of(ms: MechState, f: Face) -> int:
	return Effects.effective_reach(ms.unit, f)


## The component as the player should see it and as the resolver spends it: a copy carrying
## the effective reach and any keyword a passive grants. The die keeps the real one. An
## attack also shows the heat a spend adds through every live source (a Scorched machine's
## weapons and debuffs run hotter, 13 October; the Thrust Overboost's double): the game does the arithmetic.
## Over a target, the keywords its rank grants too (the Cottonmouth's drum: Spread at the
## front, Penetrate at the back), as the spend will carry them.
func shown_face(ms: MechState, f: Face, target: Foe = null) -> Face:
	var sf := Effects.effective_face(ms.unit, f, target)
	if sf != null and cannot_pay(ms, sf):
		if sf == f:
			sf = f.duplicate_face()
		sf.short = true   # its machine cannot pay: the cost struck through, like a dry gun's ammo
	if sf != null and not sf.spends.is_empty() and not sf.short:
		# An entry that spends a count for its stacks (the Soul Siphon): the die shows what it would
		# take now, and so what it would grant; with none to take it shows its most, struck.
		if sf == f:
			sf = f.duplicate_face()
		sf.buff_stacks = spend_take(ms, sf)
	if sf == null or not sf.is_attack():
		return sf
	var heat := int(Effects.attack(ms.unit, sf, 0, sf.heat)["heat"])
	var price := ammo_price_of(ms, sf)
	if price > 0:
		# A forging machine's gun (the Musk Ox's): its price in ammo in the heat slot's place, and
		# on the heat bar only what a foe's debuff adds (Scorched's extra).
		if sf == f:
			sf = f.duplicate_face()
		sf.ammo = price
		sf.dry = not can_fire(ms, sf)
		sf.heat = Effects.debuff_heat(ms.unit, sf)
		return sf
	var burn := shield_burn(ms, sf, heat, sf.shield_cost if not ms.assigned else 0)   # a spent entry's cost is paid already
	if burn > 0:
		# A weapon whose heat the shield pays (the Storm Petrel's): the burn, the passive box's
		# number on the die (never a cost along its foot: Ryan, 4 November), and the heat past what
		# the shield holds once a shield cost has taken its share, along the foot.
		if sf == f:
			sf = f.duplicate_face()
		sf.burns = burn
		sf.heat = heat - burn
		return sf
	if heat == sf.heat:
		return sf
	if sf == f:
		sf = f.duplicate_face()
	sf.heat = heat
	return sf


# ---------------------------------------------------------------- round flow

func start_round() -> void:
	assert(state == State.ROUND_START, "start_round called out of order")
	round += 1
	returned.clear()
	# The bank (Maverick's Playbook): what the last turn left unspent comes back while a banker
	# still fights, a reroll like any other; a roar's cost comes off the whole.
	var from_bank := mini(banked, bank_cap())
	banked = 0
	rerolls_left = maxi(0, REROLLS_PER_ROUND + from_bank - reroll_debt)   # a roar last round costs rerolls now
	if from_bank > 0:
		log.append("the bank carries %d reroll%s" % [from_bank, "" if from_bank == 1 else "s"])
	if reroll_debt > 0:
		log.append("the roar costs the team %d reroll%s" % [reroll_debt, "" if reroll_debt == 1 else "s"])
	reroll_debt = 0
	last_roll.clear()
	last_blast.clear()
	# The turn begins with passive cooling (Ryan, 22 September: cool at the start, heat at
	# the end): every machine sheds its chassis's cooling rating, one log line for all.
	var cooled: Array[String] = []
	for ms in mechs:
		# A swallowed machine cannot act while it is out (30 October): its die is spent before it rolls.
		ms.assigned = is_swallowed(ms)
		if not ms.alive():
			continue
		# A sealed machine's own cooling stops (the Polar Bear's Lockdown, 20 October): opening
		# is its one way down, since no die is dealt a vent.
		var drop := 0 if Effects.is_sealed(ms.unit) else mini(ms.heat, ms.unit.cooling)
		if drop > 0:
			ms.heat -= drop
			cooled.append("%s -%d" % [ms.unit.display_name, drop])
		if pilot.has(ms.unit.chassis_id):
			ms.heat += int(pilot[ms.unit.chassis_id])
			log.append("%s's pilot light: +%d heat (a what-if)" % [ms.unit.display_name, int(pilot[ms.unit.chassis_id])])
		ms.hot_entry = -1
		ms.face_index = _roll(ms)
		ms.free_rerolls = Effects.free_rerolls(ms.unit)
		# The forge's trickle (the Musk Ox's), from the second round: the first holds its start, 3
		# in all (Ryan, 22 October: "make it a total of 3").
		if ms.ammo_max > 0 and round > 1:
			_reload(ms, int(Effects.forge_rule(ms.unit).get("per_round", 0)), "")
	if not cooled.is_empty():
		log.append("cooling: " + ", ".join(cooled))
	_refresh_allies()
	# The shield regen (the long wall brief 3.6; Ryan, 5 November: "Base shield regen and
	# cooling returning, as a build-strategy buffer"): every machine regains its shield_regen up
	# to its maximum, after the cooling and before the round-start passives, a shield gain like
	# any other (on_shield_gain fires), one log line for all. A sealed machine's regen runs:
	# nothing stops it, where the seal stops its own cooling. What its heat adds to the regen (the
	# Buzzard's Thermal Recoupler) is read here with it, the heat as the cooling left it.
	var regened: Array[String] = []
	for ms in live_mechs():
		var gained := _gain_shield(ms, shield_regen_of(ms))
		if gained > 0:
			regened.append("%s +%d" % [ms.unit.display_name, gained])
	if not regened.is_empty():
		log.append("shield regen: " + ", ".join(regened))
	# Passives that fire at the round's start, after the roll: shield from heat, a flat
	# shield, a vent (the Buzzard's Thermal Recoupler reads the heat as it stands now).
	for ms in live_mechs():
		_fired(ms, Effects.round_start(ms.unit, ms.heat), "round start")
	# The hopper grants its Armoured for the round, what the loads it holds are worth (the Honey
	# Badger's, Ryan, 10 November: "returns at the start of his turn since its granted by the
	# funnel bar"): last round's went at the round's end as every machine's Armoured does, and a
	# Purge may have taken it sooner. Before the foes announce, so their blows are drawn against it.
	for ms in live_mechs():
		var plated := Effects.plate_round(ms.unit)
		if plated > 0:
			log.append("%s's hopper plates it: %s ×%d" % [ms.unit.display_name, Effects.STATUS["braced"]["name"], Effects.plated(ms.unit)])
	# Every foe announces its move for the round: which action, at whom. Chosen now, before
	# the player acts, so the intent chips and the forecast are exact. The move first, from
	# the ones its conditions allow (never the same special twice running), then the pick by
	# the move's aim, each foe on its own; a rank that fires as one shares its pick. The foes
	# draw in the order they strike and never over-commit (Ryan, 24 October, after Slice and
	# Dice): a machine the blows already drawn would wreck is skipped while another stands.
	_focus.clear()
	_refresh_kin()
	var ahead := {}
	for f in field_foes():
		f.fresh = false   # a half that stepped up last round acts from this one
		# A move gathered last round holds, and so does its pick while the machine stands.
		var carried := not f.pending.is_empty()
		_choose_foe_action(f)
		if not (carried and f.target != null and (f.target as MechState).alive()):
			f.target = _pick_mech_target(f, _doomed(ahead))
		_draw_blows(f, ahead)
	state = State.ASSIGN
	_mark_roll()   # the round's roll: the undo reaches back to here, and the trail shows the bar


## The machines the blows drawn so far this round would wreck.
func _doomed(ahead: Dictionary) -> Array:
	var out: Array = []
	for ms in ahead.keys():
		if int(ahead[ms]["hull"]) <= 0:
			out.append(ms)
	return out


## A foe's blows this round walked through the machines they would land on as the picks are
## drawn, each machine's shield, Barrier and hull carried from the blows before it, as the
## forecast reads them: a blow at every machine on each, any other on its pick. A special, a
## suppressed foe and a countdown still gathering land nothing this round.
func _draw_blows(f: Foe, ahead: Dictionary) -> void:
	if not f.attacks() or foe_blow(f) <= 0 or f.is_suppressed():
		return
	if not f.pending.is_empty() and f.charge > 0:
		return
	var on: Array = []
	if f.hits_all():
		on = targetable_mechs()
	elif f.target != null:
		on = [f.target]
	for ms in on:
		if not ahead.has(ms):
			ahead[ms] = {"shield": ms.unit.shield, "barrier": Effects.has(ms.unit, "barrier"), "hull": ms.unit.hull}
		var walk: Dictionary = ahead[ms]
		for r in blows_on(ms, f, walk):
			walk["hull"] = int(walk["hull"]) - int(r["through"])


## The moves a foe may announce this round: those whose conditions hold, less the special
## it announced last round when anything else is open (a special never fires twice running,
## so the swing after the roar can be counted on). Nothing legal falls back to its blow.
func legal_actions(f: Foe) -> Array:
	var legal: Array = []
	var follow := Foe.follow_ups(f.actions)
	for a in f.actions:
		if follow.has(str(a.get("id", ""))):
			continue   # a follow-up comes only after the move that names it (30 October)
		if str(a.get("effect", "")) == "swallow" and swallowable().size() < 2:
			continue   # never the last machine able to act
		if str(a.get("effect", "")) == "merge" and mergeable(f, a).is_empty():
			continue   # nothing of its kinds stands to take in
		if str(a.get("effect", "")) == "summon" and not _summon_has_room(f, a):
			continue   # a summoner never summons with no room (Ryan, 7 November: "a summoner should not summon if there's no space")
		if bool(a.get("once", false)) and f.spent_once.has(str(a.get("id", ""))):
			continue   # used once this fight already
		if _when_holds(f, a):
			legal.append(a)
	if legal.size() > 1 and not f.last_special.is_empty():
		var kept: Array = []
		for a in legal:
			if Foe.is_attack_action(a) or str(a.get("id", "")) != f.last_special:
				kept.append(a)
		if not kept.is_empty():
			legal = kept
	if legal.is_empty():
		for a in f.actions:
			if Foe.is_attack_action(a):
				legal.append(a)
	return legal


## Whether a summon has a slot for what it calls: an empty slot of the called foe's rank no
## corpse holds. Without the battle's content (a test with no factory) it calls nothing up and
## stays legal.
func _summon_has_room(f: Foe, a: Dictionary) -> bool:
	var who := str(a.get("foe", ""))
	if not foe_factory.is_valid() or who.is_empty():
		return true
	var probe = foe_factory.call(who)
	if not (probe is Foe):
		return true
	# Room for one at least (Ryan, 8 November: "Summoner should be able to summon whatever they're
	# able to", so a slot left just short never shuts it); the call stands as many as fit.
	return _free_slots_for(probe) >= 1


## The slots a foe of `n`'s rank could step into now: its rank's empty slots holding no corpse, a
## massive foe's the columns empty in both ranks.
func _free_slots_for(n: Foe) -> int:
	var out := 0
	for c in range(columns):
		if n.is_massive():
			if front[c] == null and back[c] == null and not corpses.has(Vector2i(0, c)) and not corpses.has(Vector2i(1, c)):
				out += 1
		elif n.prefers_back:
			if back[c] == null and not corpses.has(Vector2i(1, c)):
				out += 1
		elif front[c] == null and not corpses.has(Vector2i(0, c)):
			out += 1
	return out


func _choose_foe_action(f: Foe) -> void:
	if not f.pending.is_empty():
		f.action = f.pending   # a countdown move holds until it lands
		return
	# A follow-up (30 October): the move its last move named in `then` comes now, announced like
	# any; a borrowed swing with nothing taken has nothing to swing, and the roll decides.
	var next := f.next_move
	f.next_move = ""
	f.committed = false
	if not next.is_empty():
		for a in f.actions:
			if str(a.get("id", "")) == next and (not Foe.swings_held(a) or not f.held.is_empty()):
				f.action = a
				f.committed = true   # announced a round ahead, so no Disrupt turns it (Ryan, 2 November): the first move was the window
				f.last_special = "" if f.attacks() else str(f.action.get("id", ""))
				_begin_countdown(f)
				return
	f.choose_from(legal_actions(f), rng)
	f.last_special = "" if f.attacks() else str(f.action.get("id", ""))
	_begin_countdown(f)


## A move with a countdown starts gathering as it is announced (15 October).
func _begin_countdown(f: Foe) -> void:
	var n := Foe.countdown_of(f.action)
	if n > 0:
		f.pending = f.action
		f.charge = n


## Does a move's condition hold right now? One word or a list meaning any (Foe.WHENS).
func _when_holds(f: Foe, a: Dictionary) -> bool:
	var whens := Foe.whens_of(a)
	if whens.is_empty():
		return true
	for w in whens:
		if _when_word_holds(f, a, str(w)):
			return true
	return false


func _when_word_holds(f: Foe, a: Dictionary, w: String) -> bool:
	match w:
		"below_half":
			return f.hp * 2 <= f.hp_max
		"missing_hull":
			return f.hp <= f.hp_max - maxi(1, int(a.get("value", 0)))
		"back_behind":
			if f.rank != 0 or f.column < 0 or f.column >= columns:
				return false
			var behind: Foe = back[f.column]
			return behind != null and behind != f and behind.alive()
		"ally_hurt":
			for o in field_foes():
				if o.alive() and o.hp < o.hp_max:
					return true
			return false
		"others_on_field":
			for o in field_foes():
				if o != f and o.alive():
					return true
			return false
		"ally_unready":
			return _unready_ally(f) != null
		"machine_buffed":
			for ms in live_mechs():
				if Effects.buff_stacks(ms.unit) > 0:
					return true
			return false
		"ally_marked":
			return cleanse_target(f) != null
		"part_fallen":
			return parts_down(f) > 0
		"calm":
			return not Effects.has(f, "golden")   # a rage at a time (4 November): it goes gold again only once calm
	return true


## The player's Purge N on one foe (28 October; by its number since 2 November): every buff it
## carries loses N stacks (Effects.purge: its abilities stay, a core's guard and a golden rage
## among them), told when anything moved; a Ward turns it away and stands (Ryan, 2 November:
## nothing but damage lands on a Warded foe).
func _purge_foe(by: String, foe: Foe, n: int, turned = null) -> void:
	if Effects.has(foe, "ward"):
		if turned is Dictionary:
			_note_turned(turned, foe, "Purge")   # no status of its own: the tell names it as it is
		else:
			log.append("%s's Ward turns the Purge away" % foe.display_name)
		return
	var touched := Effects.purge(foe, n)
	if not touched.is_empty():
		log.append("%s purges %s ×%d: %s" % [by, foe.display_name, n, ", ".join(touched)])


## A foe's Barrier (28 October): the next weapon blow it takes deals nothing, the blow's riders
## landing; a debuff pops nothing. True when this blow was the one it took.
func _barrier_eats(foe: Foe, weapon: bool) -> bool:
	if not weapon or not Effects.has(foe, "barrier"):
		return false
	Effects.remove(foe, "barrier")
	log.append("%s's Barrier takes the blow" % foe.display_name)
	return true


## The foe a cleanse lands on (28 October): the one on its side, itself included, carrying the
## most of the team's marks (each status one), the first in strike order on a tie; null when
## none carries one.
func cleanse_target(f: Foe) -> Foe:
	var best: Foe = null
	var most := 0
	for o in field_foes():
		if not o.alive():
			continue
		var n := Effects.team_marks(o)
		if n > most:
			best = o
			most = n
	return best


## The live machines showing an intact weapon or debuff: what a foe that aims at the armed looks for.
func _armed_mechs() -> Array[MechState]:
	var out: Array[MechState] = []
	for ms in targetable_mechs():
		var face := ms.face()
		if face != null and face.is_attack():
			out.append(ms)
	return out


## A foe that splits (the Gel): destroyed, so many of the named foe step up at once (Ryan, 25
## October: "spawn the half-gel immediately in place, not wait for the reinforcement phase"; the
## Gel is a wall, not an attacker), made by the battle's content; without a factory nothing
## steps in. The first takes the slot it fell from, the rest the nearest empty slots of their
## rank, the left on a tie, and one with no room never forms (no reinforcement inside a fight,
## Ryan, 6 November, as a summon with no room is never cast). Its round is over, so it shows no
## intent and acts from the next round (Foe.fresh).
func _split(f: Foe, at_rank: int = -1, at_col: int = -1) -> void:
	if f.on_death.is_empty() or not foe_factory.is_valid():
		return
	var who := str(f.on_death.get("summon", ""))
	var count := maxi(1, int(f.on_death.get("count", 1)))
	var made: Array[Foe] = []
	for i in range(count):
		var n = foe_factory.call(who)
		if n is Foe:
			n.pack_id = f.pack_id
			n.joined = true
			made.append(n)
	if made.is_empty():
		return
	# A pair (the Gel's halves, 26 October): both stand in the slot it fell from, one slot to the
	# formation, their round over.
	if bool(f.on_death.get("pair", false)) and made.size() == 2 and at_col >= 0 and foe_at(at_rank, at_col) == null:
		var at := Vector2i(at_rank, at_col)
		for n in made:
			n.fresh = true
		_set_contents(at, [made[0], made[1]])
		log.append("%s splits: 2 %s step up in its place, a pair in one slot" % [f.display_name, made[0].display_name])
		return
	var stood := 0
	for n in made:
		if _step_up(n, at_col):
			stood += 1
	var unformed := made.size() - stood
	var name_of := made[0].display_name
	if stood > 0 and unformed > 0:
		log.append("%s splits: %d %s step up in its place, %d with no room" % [f.display_name, stood, name_of, unformed])
	elif stood > 0:
		log.append("%s splits: %d %s step up in its place" % [f.display_name, stood, name_of])
	else:
		log.append("%s splits, with no room for its %s" % [f.display_name, name_of])


## A foe that arrives mid-round (a split's half, a summon) steps up into the slot `_split_slot`
## finds near `at_col`, its round over (Foe.fresh). False when there is no room, and it is not
## placed.
func _step_up(n: Foe, at_col: int) -> bool:
	var slot := _split_slot(n, 0, at_col)
	if slot.y < 0:
		return false
	n.fresh = true
	if n.is_massive():
		back[slot.y] = n   # both slots of its column
	_place(n, slot.x, slot.y)
	return true


## Where a split's arrival steps up: the slot of its rank in the column the foe fell from, then
## the nearest column with that slot empty, the left on a tie (a massive arrival a whole empty
## column). (-1, -1) when there is no room, or nowhere it fell from.
func _split_slot(n: Foe, _at_rank: int, at_col: int) -> Vector2i:
	if at_col < 0 or at_col >= columns:
		return Vector2i(-1, -1)
	var want := 1 if n.prefers_back and not n.is_massive() else 0
	for d in range(columns):
		for c in [at_col - d, at_col + d]:
			if c < 0 or c >= columns or (d == 0 and c != at_col):
				continue
			if n.is_massive():
				if front[c] == null and back[c] == null and not corpses.has(Vector2i(0, c)) and not corpses.has(Vector2i(1, c)):
					return Vector2i(0, c)
			elif (front if want == 0 else back)[c] == null and not corpses.has(Vector2i(want, c)):
				return Vector2i(want, c)
	return Vector2i(-1, -1)


## Every foe on the field learns how many of its kind stand with it, for a swarm blow. Kept
## current as foes fall and step in, so the intent chips drop as the pack thins.
func _refresh_kin() -> void:
	var live := field_foes()
	for f in live:
		var n := 0
		for o in live:
			if o != f and o.alive() and _same_kind(o, f):
				n += 1
		f.kin = n
		f.grudge = team_kills   # a blow that grows with the team's kills (`per_kill`) reads them as it is shown
	for f in reinforcements:
		f.grudge = team_kills


static func _same_kind(a: Foe, b: Foe) -> bool:
	if not a.content_id.is_empty() or not b.content_id.is_empty():
		return a.content_id == b.content_id
	return a.display_name == b.display_name


## Reroll the dice named. One die alone, on a machine with a free reroll of its own left
## (the Trim Tabs module's), spends that instead of the team's; anything else
## spends one of the team's.
func reroll(mech_indices: Array) -> bool:
	if state != State.ASSIGN:
		return false
	var snap := SaveGame.snapshot_skirmish(self) if keeps_undo and not previewing else {}
	var before := rng.state
	if not _reroll(mech_indices):
		return false
	if rng.state != before:
		_mark_roll()   # a draw: the undo's floor
	elif not snap.is_empty():
		history.append(snap)   # a stepping die's step draws nothing: taken back like a spend
	return true


## The reroll itself: a machine's own free reroll when one die alone is named and it has one,
## else one of the team's on every die named; nothing named that can roll, nothing spent (the
## audit's tenth bug, 8 November).
func _reroll(mech_indices: Array) -> bool:
	var live: Array[MechState] = []
	for i in mech_indices:
		if int(i) < 0 or int(i) >= mechs.size():
			continue
		var ms := mechs[i]
		if ms.alive() and not ms.assigned:
			live.append(ms)
	if live.is_empty():
		return false
	if live.size() == 1 and live[0].free_rerolls > 0:
		live[0].free_rerolls -= 1
		_reroll_die(live[0])
		log.append("%s rerolls its own die for free" % live[0].unit.display_name)
		return true
	if rerolls_left <= 0:
		return false
	for ms in live:
		_reroll_die(ms)
	rerolls_left -= 1
	return true


## One die rerolled: never the same entry. A stepping die steps (a reroll is a roll); a folded
## die (the Clydesdale's) rerolls among its live entries, the battery up and its fixed pieces.
func _reroll_die(ms: MechState) -> void:
	_rolled()
	ms.face_index = _step(ms) if Effects.steps_die(ms.unit) else ms.die.reroll_among(rng, Effects.live_entries(ms.unit, ms.die), ms.face_index)


## A die rolling (Ryan's wording for the Cassowary, 12 October: "Whenever its die rolls, it
## moves to the next entry instead, in sequence"): a stepping die steps, once the fight's
## first roll has spun it to a random chamber (Ryan, 18 October: "like a revolver spinning");
## any other die rolls.
func _roll(ms: MechState) -> int:
	if previewing:
		return ms.face_index   # the copy's die keeps its entry: a roll is never promised
	_rolled()
	if ms.face_index >= 0 and Effects.steps_die(ms.unit):
		return _step(ms)
	return ms.die.roll_among(rng, Effects.live_entries(ms.unit, ms.die))


## The entry after the one showing, past the last back to the first.
func _step(ms: MechState) -> int:
	var n := ms.die.faces.size()
	return 0 if n == 0 or ms.face_index < 0 else (ms.face_index + 1) % n


## The entry a stepping die's next step turns to (the Cassowary's), its place on the die; -1 for
## a die that rolls. The hold's cylinder points its arrow at it.
func next_index(ms: MechState) -> int:
	if ms == null or ms.face_index < 0 or not Effects.steps_die(ms.unit) or ms.die.faces.is_empty():
		return -1
	return _step(ms)


## What a stepping die shows after its next step, as the die would show it (a dark entry's
## stand-in, the passives' reach and heat): the screen's next-chamber chip. Null for a die
## that rolls.
func next_face(ms: MechState) -> Face:
	if ms.face_index < 0 or not Effects.steps_die(ms.unit) or ms.die.faces.is_empty():
		return null
	var at := _step(ms)
	if Effects.is_entry_disabled(ms.unit, at):
		return Face.disabled_stand_in(ms.die.faces[at])
	return shown_face(ms, ms.die.faces[at])


## The most of the team's unspent rerolls the bank carries to the next round (Maverick's
## Playbook): the largest cap of a live machine that banks, so two never bank twice; 0 when none
## fights.
func bank_cap() -> int:
	var cap := 0
	for ms in live_mechs():
		cap = maxi(cap, Effects.bank_cap(ms.unit))
	return cap


## Is any reroll open: an unspent die to roll, and the team's reroll or a machine's own?
func can_reroll() -> bool:
	if state != State.ASSIGN:
		return false
	var unspent := false
	for ms in live_mechs():
		if not ms.assigned:
			unspent = true
			if ms.free_rerolls > 0:
				return true
	return unspent and rerolls_left > 0


## Whether UNDO has anything to take back: the player's turn, and a spend or a reroll since
## the last roll.
func can_undo() -> bool:
	return state == State.ASSIGN and not history.is_empty()


## How far the undo reaches: the spends and rerolls it can take back, in order.
func undo_depth() -> int:
	return history.size() if state == State.ASSIGN else 0


## Take back the last spend or reroll: the fight as it was before it, the machines' units (the
## field's own) with their numbers written back, the foes as they stood (new objects: the
## screen draws by slot), the log and the stream as they were. False with nothing to take back.
func undo() -> bool:
	if not can_undo():
		return false
	var snap: Dictionary = history.pop_back()
	SaveGame.restore_skirmish(self, snap)
	return true


## A draw made (the round's roll, a reroll's, a spend's own): the undo reaches no further
## back, and the trail shows a bar where the draw was.
func _mark_roll() -> void:
	history.clear()
	if roll_marks.is_empty() or roll_marks[-1] != log.size():
		roll_marks.append(log.size())


## Whether die `mech_index` may be spent on `target` now (a Foe for an attack, a MechState or
## null for a shield, a vent or a buff): the checks `assign` makes before it acts, changing nothing. The
## screen asks it while a die is dragged, for the hover over a valid target.
func can_assign(mech_index: int, target) -> bool:
	if state != State.ASSIGN or mech_index < 0 or mech_index >= mechs.size():
		return false
	var ms := mechs[mech_index]
	if not ms.alive() or ms.assigned or ms.face() == null:
		return false
	var raw := spend_face(ms)
	var f := Effects.effective_face(ms.unit, raw)
	if f.is_attack():
		return target is Foe and targets_for_face(ms, raw).has(target)
	if f.on_machines():
		return machine_targets_for(ms, f).has(target if target is MechState else ms)
	return false


## Whether die `mech_index` has anywhere to be spent now: alive and unspent, an entry that is no
## blank (a dark one is), and a target it may land on (a foe in reach, a machine its chip
## allows). The screen's END TURN pulses once no die has (25 October).
func can_spend(mech_index: int) -> bool:
	if state != State.ASSIGN or mech_index < 0 or mech_index >= mechs.size():
		return false
	var ms := mechs[mech_index]
	if not ms.alive() or ms.assigned or ms.face() == null or ms.face().kind == Face.Kind.BLANK:
		return false
	var raw := spend_face(ms)
	var f := Effects.effective_face(ms.unit, raw)
	if f.is_attack():
		return not targets_for_face(ms, raw).is_empty()
	if f.on_machines():
		return not machine_targets_for(ms, f).is_empty()
	return false


## A locked piece of the Swallowtail's goes out in its charged form whenever a muster pays for it
## and it has somewhere to land (charge_lands), the muster spent with it.
## Spend a mech's face. `target` is a Foe for attacks, a MechState (or null for self) for
## shield and vent. Returns false if the assignment is not legal. The undo's snapshot is taken
## before it; a spend that draws from the stream (Rapid's reroll, a roll again, the Scorpion's
## blast's pick) is the undo's floor instead.
func assign(mech_index: int, target = null, second = null) -> bool:
	if state != State.ASSIGN:
		return false
	var snap := SaveGame.snapshot_skirmish(self) if keeps_undo and not previewing else {}
	var before := rng.state
	if not _assign(mech_index, target, second):
		return false
	if rng.state != before:
		_mark_roll()
	elif not snap.is_empty():
		history.append(snap)
	return true


func _assign(mech_index: int, target = null, second = null) -> bool:
	if state != State.ASSIGN:
		return false
	last_acts.clear()
	spend_blows.clear()
	var ms := mechs[mech_index]
	if not ms.alive() or ms.assigned:
		return false
	var f := ms.face()
	if f == null:
		return false
	var store := f.charge_store()
	var price := f.charge_price()
	var charged := charge_lands(ms)
	var raw := spend_face(ms)   # the entry as spent, its charged form when a muster pays for it
	f = raw
	var quick := Effects.quick_turn_live(ms.unit, f)   # Rapid by a once-a-round gate (the Needletail's), read before the spend
	f = Effects.effective_face(ms.unit, f, target if target is Foe else null)   # the entry as this machine's passives make it, over the foe it is aimed at
	if f.is_attack() and (not (target is Foe) or not targets_for_face(ms, raw).has(target)):
		return false
	# A Swap takes its second target with it (Ryan, 21 October: drag to the first, drop, then
	# tap the second): another foe or an empty slot, never a massive foe.
	if f.has(Face.Keyword.SWAP) and not swap_targets(target, swap_carries(ms)).has(second):
		return false
	if f.on_machines() and not machine_targets_for(ms, f).has(target if target is MechState else ms):
		return false
	# A shield cost (Ryan, 26 October: "if you don't have the shield, the face cannot be played,
	# and overshield does cheat it out at the cost of using two actions for one effect"): taken
	# first, from the shield as it stands, overshield included; short of it the entry is locked
	# (cannot_pay) and never reaches here.
	var toll := f.shield_cost
	if toll > 0:
		if ms.unit.shield < toll:
			return false
		ms.unit.shield -= toll
		log.append("%s: %s costs shield %d" % [ms.unit.display_name, f.describe(), toll])
	# A corrupted entry bites its owner as it is spent (shield first, no armour: the rot is
	# inside the machine), before the component does its work. A machine it finishes acts
	# no further.
	var bite := pending_bite(ms)
	if bite > 0:
		var b := _bite(ms.unit.shield, ms.unit.hull, bite)
		log.append("%s: %s bites back, shield -%d, hull -%d" % [ms.unit.display_name, f.describe(), ms.unit.shield - int(b["shield"]), ms.unit.hull - int(b["hull"])])
		var hull_lost: bool = int(b["hull"]) < ms.unit.hull
		ms.unit.shield = b["shield"]
		ms.unit.hull = b["hull"]
		if hull_lost:
			_hull_damaged(ms)
		if not ms.alive():
			log.append("%s is wrecked by its own corrupted component" % ms.unit.display_name)
			ms.assigned = true
			_check_outcome()
			return true
	# A volatile component bites too, hull outright: shield and armour never see it (the
	# Arsenal's keyword, 28 September). It fires whatever the component is, so a volatile
	# shield costs hull to raise. A machine it finishes acts no further.
	var volatile := pending_volatile(ms)
	if volatile > 0:
		ms.unit.hull -= volatile
		log.append("%s: %s %s hull %d" % [ms.unit.display_name, f.describe(), "costs" if f.volatile > 0 else "pays its tithe,", volatile])
		_hull_damaged(ms)
		if not ms.alive():
			log.append("%s is wrecked by its own volatile component" % ms.unit.display_name)
			ms.assigned = true
			_check_outcome()
			return true
	if charged and store == "muster":
		# The muster spent (the Swallowtail's): the charged form's price, a charge a muster.
		Effects.spend_stacks(ms.unit, "muster", price * maxi(1, int(Effects.muster_rule(ms.unit).get("value", 30))))
		log.append("%s spends a muster: %s" % [ms.unit.display_name, f.describe()])
	elif charged:
		# Another store (the Nemesis's rage, Ryan, 11 November: "its rage is consumed in chunks of
		# 5", "spent automatically"): its price in stacks, taken as the charged form goes out.
		Effects.spend_stacks(ms.unit, store, price)
		log.append("%s spends %d %s: %s" % [ms.unit.display_name, price, str(Effects.STATUS.get(store, {}).get("name", store)).to_lower(), f.describe()])
	var blasted := false   # a vent that blasted deals damage, for the Sponsorship tally
	var killed := 0        # the foes a weapon spend or a vent's blast felled, arcs and spills included (a kill trigger, the reset gun)
	if f.kind != Face.Kind.BLANK and not f.is_weapon():
		_feed_rage(ms, f)   # a shield, a vent or equipment feeds every raging foe on the field, before it acts, so a Purge clears its own feed (3 November)
	# The spend's order (Ryan, 7 November): its hits, their riders, the death check, the spend's
	# end, then what its kills bring back; so the returns wait until the match is done.
	_holding_returns = true
	match f.kind:
		Face.Kind.BLANK:
			pass
		Face.Kind.SHIELD:
			var who: MechState = target if target is MechState else ms
			# A team shield reaches every ally (the Swallowtail's Mooring Screens, 21 October).
			var whom: Array[MechState] = []
			if f.reaches_all:
				whom = reached_machines(ms, f)
			else:
				whom.append(who)
			for w in whom:
				var amount := shield_amount(ms, f, w)   # sized at the spend, on the heat its cooling leaves
				# The Sutler's Hoist: its cooling first, then the shield; charged, the heat to
				# nothing and the shield to its maximum.
				if f.cools_all or f.vents > 0:
					var cooled := w.heat if f.cools_all else mini(w.heat, f.vents)
					w.heat -= cooled
					log.append("%s cools %s by %d" % [ms.unit.display_name, w.unit.display_name, cooled])
				_gain_shield(w, amount, f.has(Face.Keyword.OVERSHIELD))
				log.append("%s shields %s for %d%s" % [ms.unit.display_name, w.unit.display_name, amount, " (past its maximum)" if w.unit.shield > w.unit.shield_max else ""])
				if w != ms:
					_shield_granted(ms, w, amount)
				_cleanse_with(ms, w, f)
		Face.Kind.VENT:
			var who: MechState = target if target is MechState else ms
			var shield_half := shield_amount(ms, f, who)   # sized at the spend, on what the vent will leave
			var blast := blast_amount(ms, f, who)            # read before the heat it fires comes off
			who.heat = maxi(0, who.heat - f.power)
			log.append("%s vents %s by %d" % [ms.unit.display_name, who.unit.display_name, f.power])
			# The Thermal Ejection Manifold (the Whip Scorpion's, 12 and 13 October): a vent it
			# spends on itself blasts a random foe for the heat it took off; a vent on an ally
			# blasts nothing, and so does an ally's vent on it.
			if blast > 0:
				var kills_before := team_kills
				_blast(mech_index, ms, blast)
				blasted = true
				killed = team_kills - kills_before
				_after_kills(ms, killed)
			# The combined entry (Ryan's go, 20 October, the Wake Diffuser): the vent, then the
			# shield on the same machine, through its shield gain and the spender's passives
			# for an ally it shields, sized on the heat the vent left.
			if shield_half > 0 and who.alive():
				_gain_shield(who, shield_half, false)
				log.append("%s shields %s for %d%s" % [ms.unit.display_name, who.unit.display_name, shield_half, " (past its maximum)" if who.unit.shield > who.unit.shield_max else ""])
				if who != ms:
					_shield_granted(ms, who, shield_half)
			_cleanse_with(ms, who, f)
		Face.Kind.BUFF:
			# Equipment that grants a status for the round (or more): the pipeline reads it
			# like any modifier, and end_round lets it go.
			var who: MechState = target if target is MechState else ms
			if f.act_again:
				# The Reveille Horn's charged form (the gun platform's engine): the ally's spent die
				# rolls again by the reroll rule, never onto the entry it spent (Ryan, 8 November:
				# "It's a roll, it should follow roll rules, like everything that rolls"), and it acts
				# again.
				_act_again(who, f)
				log.append("%s rallies %s: its die rolls again, and it acts again" % [ms.unit.display_name, who.unit.display_name])
			elif f.turns_die:
				# The Changeover (the Clydesdale's, Ryan, 11 November): its die turns to its other
				# battery, which stays up from fight to fight; Rapid's free roll lands on it below.
				if Effects.folds_die(ms.unit) > 0:
					var raised := Effects.turn_die(ms.unit)
					log.append("%s changes over: its %s battery is up" % [ms.unit.display_name, "second" if raised else "first"])
			elif f.action_price > 0 and who != ms:
				# The Immelmann Booster's ally use (the Giant Petrel's, Ryan's go of 21 October; built
				# 30 October): on an ally whose die is spent, the team's rerolls pay its price, banked
				# or fresh, and the ally's die rolls again by Rapid's path, never onto the entry it
				# showed, and it acts again. The Booster's own Rapid gives the Petrel its turn back too,
				# so no turn is traded for the ally's.
				rerolls_left -= f.action_price
				_act_again(who, f)
				log.append("%s pays %d reroll%s: %s's die rolls again, and it acts again" % [ms.unit.display_name, f.action_price, "" if f.action_price == 1 else "s", who.unit.display_name])
			else:
				var until := round + f.buff_rounds - 1
				var src := "buff:" + f.component if not f.component.is_empty() else "buff"
				# A grant reaching every ally (the Mooring Screens' Phased, on those yet to act).
				var whom: Array[MechState] = []
				if f.reaches_all:
					whom = reached_machines(ms, f)
				else:
					whom.append(who)
				# A buff that spends a count of its machine's for its stacks (the Soul Siphon, Ryan,
				# 12 November: "Consume up to 5 souls, granting 1 Empowered per soul"): as many as it
				# holds, up to its most, taken as it is spent, a stack granted a one.
				var grants := f.buff_stacks
				if not f.spends.is_empty():
					grants = Effects.spend_stacks(ms.unit, f.spends, f.spends_up_to)
					var spent_name := str(Effects.STATUS.get(f.spends, {}).get("name", f.spends))
					log.append("%s consumes %d %s: %d left" % [ms.unit.display_name, grants, spent_name, Effects.stacks_of(ms.unit, f.spends)])
				for w in whom:
					if f.buff_status == "phased" and w.assigned:
						continue   # Phased only before it acts (Ryan, 20 October)
					var stacks := _stacks_from(ms, f.buff_status, grants)
					var m := Effects.grant_buff(w.unit, f.buff_status, stacks, src, until)
					if m == null:
						continue
					log.append("%s buffs %s: %s ×%d%s" % [ms.unit.display_name, w.unit.display_name, m.name, stacks, "" if f.buff_rounds == 1 else " for %d rounds" % f.buff_rounds])
					if f.buff_status == "phased":
						_phase(w)
					elif f.buff_status == "rallied":
						rerolls_left += stacks   # the team's reroll more this round (the Reveille Horn)
					# The Reheat Uplink's roll (the Giant Petrel's, Ryan's go of 21 October; built 30
					# October): the die of the machine it lands on rolls again, never onto the entry
					# showing; a spent die rolls nothing.
					if f.rolls_target and w.alive() and not w.assigned:
						_roll_again(w)
						log.append("%s's die rolls again" % w.unit.display_name)
			_cleanse_with(ms, who, f)
		Face.Kind.ATTACK:
			# The sixth shot (the Cassowary's, Ryan's kit of 18 October): the spend the count
			# lands on doubles its damage and the stacks it lays (an nth_shot rule read through
			# the pipeline); every spend at a foe counts, and a weapon's spends the machine's Spun
			# Up whole, equipment leaving it (Ryan, 26 October: "Spun up only interacts with damage").
			if Effects.nth_shot_due(ms.unit):
				log.append("%s: the %s shot counts double" % [ms.unit.display_name, Effects.ordinal(Effects.counts_shots(ms.unit))])
			var kills_before := team_kills   # the spend's kills are counted at its death check (is_kill)
			if f.spends_magazine:
				_salvo(mech_index, ms, f, target)
			elif target != null:
				# A Mine laid, the gather, the detonation and the Swap land in the rider phase,
				# before the death check, on a target the hit felled too (_spend_at).
				_spend_at(mech_index, ms, f, target, second)
			# The primers (Ryan, 2 November): a weapon fired spends a stack of Charged and of
			# Supercooled, which rode it as its keywords (Effects.effective_face); a salvo is one
			# fire, and equipment spends nothing.
			if f.is_weapon():
				_spend_primers(ms)
			killed = team_kills - kills_before
			_after_kills(ms, killed, f)
			# The Spindrift Salvo's kill rider (the Giant Petrel's, Ryan's go of 21 October; built 30
			# October): a spend that kills gives the team its rerolls this round, banked if unspent.
			if f.kill_rerolls > 0 and killed > 0:
				rerolls_left += f.kill_rerolls
				log.append("%s: the kill brings the team %d reroll%s" % [ms.unit.display_name, f.kill_rerolls, "" if f.kill_rerolls == 1 else "s"])
			# The rider on its own spender (the Storm Petrel's St. Elmo's Regenerator, Ryan's go of 21
			# October; built 30 October): spent on a foe, its machine gains Regenerating, the entry's
			# shield at the start of each of the rounds it says after this one, a grant of its own, so
			# a second keeps its own end. Bought by a die entry, so a foe's purge takes it.
			if f.regen_shield > 0 and f.regen_rounds > 0 and target is Foe and ms.alive():
				Effects.grant_for_rounds(ms.unit, Effects.regenerating_shield(f.regen_shield), "buff:" + f.component, round + f.regen_rounds)
				log.append("%s regenerates: %d shield at the start of each of the next %d rounds" % [ms.unit.display_name, f.regen_shield, f.regen_rounds])
			if Effects.counts_shots(ms.unit) > 0:
				Effects.stack(ms.unit, Effects.STATUS["shots"], Effects.SKIRMISH, "count", 1, Effects.DECAY_NONE)
			if f.is_weapon() and Effects.remove(ms.unit, "spun_up"):
				log.append("%s: the spin is spent" % ms.unit.display_name)
	_holding_returns = false
	_release_returns()   # the spend is done with the field: what its kills bring back stands now
	if f.on_machines():
		_machine_spend_after(ms, f, target)
	# A hold on the whole field (the Soul Siphon's, Ryan, 12 November: "No Empowered decays this
	# round. And I mean none, not ally or enemy"): the status the entry names, on either side,
	# skips this round's run-down on every unit (round_holds), what stands and what comes later.
	if not f.holds_all.is_empty():
		for held_id in Effects.named_like(f.holds_all):
			if not round_holds.has(held_id):
				round_holds.append(held_id)
		log.append("%s: no %s decays this round" % [ms.unit.display_name, str(Effects.STATUS.get(f.holds_all, {}).get("name", f.holds_all))])
	# The brace (Ryan, 12 October; the Breaching Plow's in place of the Glacis): spending the
	# entry Braces its owner until the round's end, so the plate stands behind the charge
	# through the enemy's turn and is gone when the next round opens.
	if f.braces > 0 and ms.alive():
		var bm := Effects.grant_buff(ms.unit, "braced", f.braces, "brace:" + f.component, round)
		if bm != null:
			log.append("%s braces: %s ×%d" % [ms.unit.display_name, bm.name, f.braces])
	# The Stoker's fire on its own firer (the stock pass's landing, 22 October): spending it
	# sets its machine Burning, the stacks it prints, after the blow: slow fuel by decision, the
	# machine's Burning heating it at the turn's end before the overheat, then fading a stack,
	# so a vent makes room for it and a cleanse lifts it.
	if f.self_burn > 0 and ms.alive():
		Effects.stack(ms.unit, Effects.STATUS["burning_mech"], Effects.SKIRMISH, "self:" + f.component, f.self_burn, Effects.status_decay(Effects.STATUS["burning_mech"]))
		log.append("%s: its own fire, %s ×%d" % [ms.unit.display_name, Effects.STATUS["burning_mech"]["name"], f.self_burn])
	_shift_form(ms, f, target)
	if f.kind != Face.Kind.BLANK:
		var deals := blasted or (f.is_attack() and f.power > 0)
		var measure := "damaging_spends" if deals else "quiet_spends"
		sponsorship[measure] = int(sponsorship[measure]) + 1
	# The Siphon (the Whip Scorpion's, 20 October): every blow a foe lands on its owner this
	# round adds the entry's heat, next round's fuel (Siphoning, until the round's end).
	if f.heat_per_blow > 0 and ms.alive():
		Effects.grant_for_rounds(ms.unit, Effects.siphon_status(f.heat_per_blow), "siphon:" + f.component, round)
		log.append("%s siphons: +%d heat for every blow it takes this round" % [ms.unit.display_name, f.heat_per_blow])
	ms.assigned = true
	# A cooldown (Ryan, 14 October): the entry goes dark for the rounds it prints, this one
	# included, shown on the die with the rounds left. Rapid carries none of its own (Ryan, 2
	# November: "Rapid does not have a native Cooldown, it needs to be displayed always"): a Rapid
	# piece prints its cooldown, or pays heat or hull every spend (Face.cooldown_rounds).
	var cd := cooldown_of(ms, f)
	if cd > 0:
		Effects.disable_entry(ms.unit, ms.face_index, "cooldown", round + cd - 1)
	# The reset gun (the Kite's Pinion Driver, 21 October): if its spend killed, every entry dark
	# from a cooldown comes back, itself included, and the machine acts again through Rapid's
	# path, the free roll never landing on the entry just spent; a team reroll back onto it
	# chains it again with every kill, with no limit (Ryan, 24 October).
	var reset := f.resets_on_kill and killed > 0 and ms.alive() and not (field_foes().is_empty() and reinforcements.is_empty())
	if reset:
		var lit := Effects.clear_cooldowns(ms.unit)
		_act_again(ms, f)
		log.append("%s: the kill resets it, %d back, and it acts again" % [ms.unit.display_name, lit])
	# Rapid: the die rerolls for free (never the same entry; a copy of it may come up, so
	# stacked copies chain, the cooldown of each copy its own), and the mech may act again.
	# A spin (the Spin-Up's, Ryan's exception to the reroll rule, 19 October) is a true roll
	# over every entry, itself included; a stepping die's free reroll steps it.
	if f.has(Face.Keyword.RAPID) and not reset:
		if quick:
			# The gate spent (the Needletail's Quick-turn Avionics Relay): once a round.
			Effects.grant_for_rounds(ms.unit, Effects.STATUS["quick_turned"], "gate", round)
		_act_again(ms, f)
		log.append("%s: %s" % [ms.unit.display_name, "the cylinder spins" if f.spins else ("a quick turn, rolls again" if quick else "rapid, rolls again")])
	# Rolling again on a status (the Nemesis's fists on rage, Ryan, 12 October): spending the
	# entry spends a stack, if its owner has one, and the die rolls again, a plain roll as the
	# round opens. Not Rapid's reroll, which never lands on the entry just spent: a plain roll
	# may show the same fist again. Nothing switches off: the stacks are the limit, and a fist
	# that shows again punches again. A fight already won rolls nothing.
	elif not f.rolls_again_on.is_empty() and ms.alive() and not (field_foes().is_empty() and reinforcements.is_empty()) \
			and Effects.spend_stacks(ms.unit, f.rolls_again_on, 1) > 0:
		ms.face_index = _roll(ms)
		ms.assigned = false
		log.append("%s: %s, rolls again (%d left)" % [ms.unit.display_name, str(Effects.STATUS.get(f.rolls_again_on, {}).get("name", f.rolls_again_on)).to_lower(), Effects.stacks_of(ms.unit, f.rolls_again_on)])
	# The fight ends the moment it is decided (Ryan, 22 September): the last foe down, or
	# the last machine burnt out by its own heat, and nobody waits for End turn.
	_refresh_allies()
	_check_outcome()
	return true


func end_round() -> int:
	assert(state == State.ASSIGN, "end_round called out of order")
	_end_player_turn()
	if outcome != Outcome.NONE:
		return outcome   # the burn wrecked the last machine: the enemy never acts
	_enemy_turn()
	if outcome != Outcome.NONE:
		return outcome   # decided in the enemy's turn: the fight ends there, no round's end after it
	_release_passes()
	if outcome != Outcome.NONE:
		return outcome   # the release felled the last foe
	_finish_round()
	# No reinforcement phase (Ryan, 6 November: "Cut"): a pack is what its grid holds, so a kill's
	# slot stays empty unless a split, a summon or a part regrowing in its corpse's place fills it.
	_refresh_guards()
	_refresh_allies()
	_check_outcome()
	if outcome == Outcome.NONE:
		state = State.ROUND_START
	return outcome


## The rank a passed turn's release sweeps: the one with the most foes standing, the back on a tie
## (Ryan, 11 November: "Tie can be back rank"). A massive foe stands in both.
func release_rank() -> int:
	var count := [0, 0]
	for rank in range(2):
		for spot in sweep_spots(rank):
			if spot[0] != null and (spot[0] as Foe).alive():
				count[rank] += 1
	return 0 if count[0] > count[1] else 1


## The shot a machine's release fires: a Sweep, a shot for every heat it holds, each of its
## passive's damage. Null for a machine whose pass releases nothing, or one holding no heat.
func release_shot(ms: MechState) -> Face:
	var power := Effects.pass_sweep(ms.unit) if ms != null else 0
	if power <= 0 or ms.heat <= 0:
		return null
	var shot := Face.attack(power, Face.Reach.SWEEP)
	shot.strikes = ms.heat
	return shot


## The passes released (the Whip Scorpion's Thermal Ejection Manifold; Ryan, 11 November), as the
## enemy's turn ends, so the heat the foes' blows banked over its maximum fires with the rest
## ("end the turn right under the overheat, get hit a couple times to go over the threshold, and
## then release it all"): each machine that passed and holds heat sweeps the rank with the most
## foes, a shot for every heat, and is left cold. The shots are its hits, resolved as any Sweep's
## (_hit), costing no heat of their own; the fight they decide ends there.
func _release_passes() -> void:
	for i in range(mechs.size()):
		var ms := mechs[i]
		if not ms.passed or not ms.alive() or outcome != Outcome.NONE:
			continue
		var shot := release_shot(ms)
		if shot == null:
			continue
		var rank := release_rank()
		var target: Foe = null
		for spot in sweep_spots(rank):
			if spot[0] != null and (spot[0] as Foe).alive():
				target = spot[0]
				break
		if target == null:
			continue
		var fired := ms.heat
		log.append("%s opens its valves: %d heat along the %s" % [ms.unit.display_name, fired, "front" if rank == 0 else "back"])
		ms.heat = 0
		spend_blows.clear()
		var h := _hit(ms, shot, target)
		_finish_hits(i, ms, shot, target, h, Pays.VENT)
		ms.heat = 0   # cold after it, whatever the shots cashed
		releases.append({"mech": i, "rank": rank, "shots": fired, "blows": spend_blows.duplicate()})
		_refresh_guards()
		_check_outcome()


## The round's end, once the enemy's turn is done and the fight undecided: the machines' statuses
## tick, a foe's halving statuses halve (Flak, Empowered's clock), each but what a pin or the
## round holds (round_holds), shield past the maximum fades and the parts due grow back. The fight's own (end_round, which then refreshes its cores' guards
## and its machines' allies and reads the outcome) and the round preview's copy (preview_round)
## both run it, so the preview's round ends as the round will.
func _finish_round() -> void:
	_tick_mechs()
	for f in field_foes():
		Effects.halve(f, (_held.get(f, []) as Array) + round_holds)
	_held.clear()
	round_holds = []   # the round's own hold (the Soul Siphon's) is over: everything halves again from the next
	_trim_overshield()
	_regrow_parts()


## The end of the player's turn (Ryan, 11 October): heat over the maximum burns hull now,
## before the enemy acts, so an overheat is the machine's own doing on its own turn, like a
## volatile bite. A machine it wrecks is gone before the enemy strikes, and a fight it
## decides ends here. A foe's Burning adds its heat just before it (13 October), so a vent
## made room for it or a cleanse took it off. END TURN's (a withdrawal shared it until the long
## wall brief, 3.5).
func _end_player_turn() -> void:
	# A pass (Ryan, 11 November: "any time it ends the round with a spendable die face"): read as
	# the turn ends, before anything moves, so an entry Rapid rolled or an action granted and left
	# unspent is one and a blank, a spent die or an entry with nowhere to land is none.
	releases.clear()
	for i in range(mechs.size()):
		mechs[i].passed = can_spend(i)
	overheats.clear()
	history.clear()   # the enemy's turn draws: nothing before it comes back
	# Maverick's Playbook (the Giant Petrel's, built 30 October): the team's rerolls left unspent
	# as the turn ends are banked, up to its cap, for the next round while it still fights.
	banked = mini(rerolls_left, bank_cap())
	for f in field_foes():
		Effects.player_turn_end_foe(f)   # a foe's Barrier and Ward last to the end of the player's turn (28 October)
	_burn_mechs()
	_seal_heat()
	_settle_heat()
	_refresh_allies()
	_check_outcome()


## The enemy's turn: every foe on the field acts in order, statuses tick, timed effects run
## out. The end of a round's.
func _enemy_turn() -> void:
	turn_events.clear()
	turn_specials.clear()
	_seq = 0
	# Foes act in the order they stand: front rank left to right, then the back rank. Each
	# foe's statuses tick at the start of its action (burning may kill it first, and a dead foe
	# never strikes: Ryan, 4 November, "What we absolutely do not want to do is have a zero-hp
	# enemy attacking and then dying after"; vitriol eats its share of what is left and
	# finishes nobody), a suppressed foe skips, and a foe with two strikes lands two separate
	# blows, so a shield stops the first and the second reaches the hull. A web on the foe
	# bursts at the end of its action, skipped or not (18 October). The death check runs as each
	# foe's action is done, and at once on a foe its tick kills (the audit's first bug, 8
	# November): its last act lands, its parts fall, its machine is let go and a return stands
	# before the next foe moves; and the fight ends the moment it is decided, the foes after the
	# blow that wrecks the last machine doing nothing (the audit's second).
	_acted.clear()
	_enemy_acting = true
	for f in field_foes():
		if outcome != Outcome.NONE:
			break
		if not f.alive():
			continue   # fallen earlier this turn (with its core, taken in by a merge), and does nothing
		var regrow := Effects.regrowth(f)   # read before the tick counts down its clock (28 October)
		var tick := Effects.tick(f, false)   # a halving status (Flak) waits for the round's end
		var share := int(tick.get("share", 0))
		if int(tick["hp"]) - share > 0:
			log.append("%s burns for %d" % [f.display_name, int(tick["hp"]) - share])
		if share > 0:
			log.append("vitriol eats %s for %d" % [f.display_name, share])
		if int(tick["hp"]) > 0:
			f.hp -= int(tick["hp"])
			if not f.alive():
				_turn_death_check()   # burnt to death before it acts: a web it carried goes with it
				continue
		# Regenerating (28 October): what it regrows comes after its Burning and Vitriol, so a
		# burn is a race and never a wall; a suppressed foe regrows too, its ticks being its own.
		if regrow > 0 and f.hp < f.hp_max:
			var before := f.hp
			f.hp = mini(f.hp_max, f.hp + regrow)
			log.append("%s regenerates %d" % [f.display_name, f.hp - before])
		# Its move this turn, landing or lost to a Suppress, spends what a rally gave it (Empowered,
		# 26 October); a countdown still gathering carries it to the blow it lands, and a foe
		# that stepped up this round has had its round, so it keeps it for its next.
		var moves := not f.fresh and not f.gathering()
		if tick["skip"] and not _staggered(f):
			f.recovering = true   # its action lost to a stun: its stun resist lands as Numbed at the round's end (a stagger is no stun's, and numbs nothing)
		if not tick["skip"] and not f.fresh:   # a suppressed foe does nothing, and a web on it still bursts; one that stepped up this round has had its round
			_foe_turn(f)
			# A move that landed names its follow-up for next round (30 October); one lost to a
			# Suppress or turned by a Disrupt names nothing, so either answer breaks the pair.
			if f.alive() and not f.gathering() and f.action.has("then"):
				f.next_move = str(f.action["then"])
		if moves:
			Effects.remove(f, "primed")   # a stoker's priming rides the move it makes (28 October); its Empowered halves at the round's end instead (4 November)
		if _lift_after.has(f):
			# A merge's lift (30 October), its own Empowered, riding its next move.
			Effects.stack(f, Effects.STATUS["kindled"], Effects.SKIRMISH, "foe:" + f.content_id, int(_lift_after[f]), Effects.DECAY_HALF)
			_lift_after.erase(f)
		_web_burst(f)
		_turn_death_check()   # with the foe in _acted: a gold rage its own tick broke staggers it out of its next action, not the one it has had
	if outcome == Outcome.NONE:
		_turn_death_check()   # and once the turn is done, for a foe that fell outside an action's check
	_enemy_acting = false
	_acted.clear()
	if outcome != Outcome.NONE:
		return
	# Numbed's clock (Ryan, 2 November): a stack goes at the round's end, then a foe that lost its
	# action to a stun this turn gains its stun resist in stacks, so its chip reads the rounds
	# until one stun lands.
	for f in field_foes():
		if not f.alive():
			continue
		if Effects.stacks_of(f, "numbed") > 0:
			Effects.spend_stacks(f, "numbed", 1)
		if f.recovering:
			f.recovering = false
			var r := f.stun_resist()
			if r > 0:
				Effects.stack(f, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", r, Effects.DECAY_NONE)
				log.append("%s recovers: Numbed ×%d" % [f.display_name, Effects.stacks_of(f, "numbed")])
	for ms in mechs:
		Effects.end_round(ms.unit, round)   # timed effects run out
	_held.clear()
	for f in field_foes():
		var kept := Effects.held_statuses(f)   # read before its round's statuses run out: a pin holds this round's halving
		if not kept.is_empty():
			_held[f] = kept
		Effects.end_round(f, round)


## The enemy's turn's death check, after a foe's action or a tick that kills it: the dead cleared
## (_clear_dead) and the fight's outcome read.
func _turn_death_check() -> void:
	_clear_dead()
	_check_outcome()


## One foe's action in the enemy's turn: its pick (or a new one, its machine gone), its
## countdown gathering, its blow at one machine or at every machine, or its special in place of
## a blow; then a self-destruct spends it. With no machine standing to strike (every one
## fallen or Phased) only its blow is lost: its countdown gathers, a special on its own side
## acts, and the turn goes on to the foes after it, whose ticks, webs and specials are their
## own (the mechanics audit's 13, 27 October).
func _foe_turn(f: Foe) -> void:
	var t := f.target as MechState
	if t == null or not t.alive() or is_out(t):
		t = _repick(f)   # its machine fell, or is out of the fight: the next in line
	_acted.append(f)   # from its first blow, a suppress landing on it costs its next action
	if not f.pending.is_empty():
		if f.charge > 0:
			# A countdown move gathers this turn and lands when its count runs out; the
			# plaque names it as it begins, so the warning has a voice (15 October).
			if f.charge == Foe.countdown_of(f.pending):
				turn_specials.append({"foe": f, "name": str(f.pending.get("name", "")), "kind": "charge", "seq": _seq})
				_seq += 1
			f.charge -= 1
			var when := "next round" if f.charge == 0 else "in %d rounds" % (f.charge + 1)
			log.append("%s gathers: %s lands %s" % [f.display_name, str(f.pending.get("name", "")), when])
			return
		f.pending = {}   # it lands now
	if f.hits_all():
		# A blow at every machine (`all`, Ryan, 15 October): its strikes land on each live
		# machine in turn, left to right, so no aim or lure moves it; a screened machine is
		# out of it.
		for m in targetable_mechs():
			_strike(f, m)
	else:
		if t == null:
			# Nobody to strike: a special on its own side still acts, a blow has nowhere to land.
			if not f.attacks():
				_foe_acts(f, null)
			else:
				log.append("%s has no machine to strike" % f.display_name)
			return
		if not f.attacks():
			_foe_acts(f, t)   # a defend, buff or debuff instead of a blow
			return
		_strike(f, t)
	if Foe.swings_held(f.action):
		f.held = {}   # the borrowed swing spends what it took (30 October)
	if f.has_keyword(f.action, "self_destruct") and f.alive():
		# The blow spends the striker (the Bomb): it dies whole and never gets back up.
		f.hp = 0
		f.stays_down = true
		log.append("%s bursts, and is gone" % f.display_name)
	return


## The web bursts at the end of the webbed foe's action (the funnel-web's Web Bomb, Ryan's go,
## 18 October): a Suppress on it, costing its next action since it has acted (its countdown
## held a round, if it gathers one), and one on the next foe to act beside it (web_catch), each
## resisted by its own Numbed; a foe already suppressed for that action gains nothing, as from
## any second suppress, so a web on a foe the team has stunned is spent on the neighbour alone.
## The web is spent either way. A foe gone by the end of its action (a Bomb's burst) takes its
## web with it, as one killed before it does.
func _web_burst(f: Foe) -> void:
	if not f.alive() or not Effects.has(f, "webbed"):
		return
	Effects.remove(f, "webbed")
	var beside := web_catch(f)
	log.append("%s's web bursts%s" % [f.display_name, "" if beside == null else ", catching %s" % beside.display_name])
	if _suppress(f):
		_foe_gained_status(f, "suppressed")
	if beside != null and _suppress(beside):
		_foe_gained_status(beside, "suppressed")


## The foe a web on `f` catches: the next to act beside it, its right-hand neighbour in its
## rank (which acts after it, so the burst costs this round's action), or with none standing
## there the one to its left (which has acted, and loses its next); a massive foe stands in
## both ranks, so it is beside either. Null with nobody standing beside it.
func web_catch(f: Foe) -> Foe:
	if f.column < 0 or f.rank < 0:
		return null
	# The rank in acting order, a twin slot's pair left then right: the next after it, or with
	# none standing there the one before.
	var order: Array[Foe] = []
	for c in range(columns):
		for foe in slot_foes(f.rank, c):
			if not order.has(foe):
				order.append(foe)
	var i := order.find(f)
	if i < 0:
		return null
	for j in [i + 1, i - 1]:
		if j < 0 or j >= order.size():
			continue
		var n: Foe = order[j]
		if absi(n.column - f.column) <= 1 and n != f and n.alive():
			return n
	return null


## A foe's blows on one machine: each strike lands on its own, against the shield the one
## before left, and each carries the move's riders unless a Ward turns them away.
func _strike(f: Foe, t: MechState) -> void:
	var turned := false
	for s in range(f.strikes()):
		if not t.alive():
			break   # the enemy's turn is sequenced as it happens (Ryan, 4 November): a wreck takes no more
		var hull_before := t.unit.hull
		var events_before := turn_events.size()
		_damage_mech(t, f.damage(), f)
		if turn_events.size() == events_before:
			break   # a machine out of the fight took nothing, and nothing rides it
		var ev: Dictionary = turn_events[turn_events.size() - 1]
		# A drain (the Vampire Lord's, 30 October): the striker regrows what the blow took from the
		# hull, no more than the machine had, so a shield starves it (one of shield and hull walled
		# the slow trios, the shield no answer to the heal). It lays nothing on the machine, so no
		# Ward turns it away; a Barrier's blow deals nothing, and Burning on the striker races it.
		if f.has_keyword(f.action, "drain") and f.alive() and turn_events.size() > events_before:
			var dealt := clampi(int(ev["through"]), 0, maxi(0, hull_before))
			var had := f.hp
			f.hp = mini(f.hp_max, f.hp + dealt)
			if f.hp > had:
				log.append("%s drains %d" % [f.display_name, f.hp - had])
		# The live hull (the Polar Bear's, a machine under Retaliate): a blow that reaches
		# hull shocks the foe that struck; a shutters' blocked blow (the shield took it whole)
		# shocks too, and a blow a Barrier took never touched either. Shocked is a setup and
		# nothing else (Ryan, 11 October): the discharge a Shocked striker paid was thorns,
		# scaling with the blows a horde lands, and it went.
		if not bool(ev["barred"]) and Effects.shocks_striker(t.unit, bool(ev["blocked"])):
			_shock(f, t)
		# A Ward turns away every rider a foe's blows lay this round; the damage has landed.
		if Effects.has(t.unit, "ward"):
			if t.alive() and _rides(f) and not turned:
				log.append("%s: the Ward turns %s's riders away" % [t.unit.display_name, f.display_name])
				turned = true
			continue
		if f.has_keyword(f.action, "scorch") and t.alive():
			var ns := f.rider(f.action, "scorch")
			_fire_on(t, "scorched", ns, f)
			log.append("%s scorches %s ×%d" % [f.display_name, t.unit.display_name, ns])
		if f.has_keyword(f.action, "burn") and t.alive():
			var nb := f.rider(f.action, "burn")
			_fire_on(t, "burning_mech", nb, f)
			log.append("%s sets %s burning ×%d" % [f.display_name, t.unit.display_name, nb])
		# Primed (a stoker's, 28 October): each blow of the move leaves its stacks of Burning, as
		# a Burn rider would, and the move spends it (_enemy_turn).
		var primed := Effects.stacks_of(f, "primed")
		if primed > 0 and t.alive():
			_fire_on(t, "burning_mech", primed, f)
			log.append("%s, primed, sets %s burning ×%d" % [f.display_name, t.unit.display_name, primed])
		if f.has_keyword(f.action, "disable") and t.alive() and t.face_index >= 0:
			# The entry the die shows is switched off through the mech's next turn.
			Effects.disable_entry(t.unit, t.face_index, "foe:" + f.content_id, round + 1)
			log.append("%s disables %s's %s" % [f.display_name, t.unit.display_name, t.die.faces[t.face_index].describe()])
		if f.has_keyword(f.action, "corrupt") and t.alive() and t.face_index >= 0:
			# The entry the die shows is corrupted for the fight: it bites when spent.
			Effects.corrupt_entry(t.unit, t.face_index, "foe:" + f.content_id, f.rider(f.action, "corrupt"))
			log.append("%s corrupts %s's %s (×%d)" % [f.display_name, t.unit.display_name, t.die.faces[t.face_index].describe(), Effects.corrupt_stacks(t.unit, t.face_index)])
		if f.has_keyword(f.action, "crush") and t.alive():
			# A crush (4 November, the World Eater's pin): Crushed on the machine, a point more on
			# every blow it takes a stack, through the next round, so the pack's blows after the
			# pin and the next turn's land harder; an ally's Cleanse lifts it.
			var nc := f.rider(f.action, "crush")
			Effects.stack(t.unit, Effects.STATUS["crushed"], Effects.ROUNDS, "foe:" + f.content_id, nc, Effects.DECAY_NONE, round + 1)
			log.append("%s crushes %s ×%d: every blow it takes through the next round lands harder" % [f.display_name, t.unit.display_name, nc])
		if f.has_keyword(f.action, "steal") and t.alive() and t.face_index >= 0:
			_steal(f, t)



## Whether this foe's blows carry a rider a Ward turns away: a scorch, a burn, a disable or a
## corrupt (the breach is the Ward's too, in _damage_mech; a silence and a purge are specials).
static func _rides(f: Foe) -> bool:
	for kw in ["scorch", "burn", "disable", "corrupt", "crush", "steal"]:
		if f.has_keyword(f.action, kw):
			return true
	return Effects.has(f, "primed")   # a primed foe's blows carry Burning as a rider (28 October)


## A Swap (the Dingo's Combat Translocator, Ryan's go of 19 October; built 21 October): the
## first target and the second trade places, a foe for a foe, or the foe into an empty slot (a
## back foe into an empty front slot is a pull). A foe keeps its pick and its move; the rank it
## stands in is the swap's, so a caster pulled forward stands exposed to Direct fire.
func _swap(first: Foe, second) -> void:
	# A massive foe fills its column and stays: named by a Swap that carries a rider, nothing
	# moves, and the rider lands all the same.
	if first.is_massive() or (second is Foe and (second as Foe).is_massive()):
		log.append("%s holds its ground: nothing trades places" % (first.display_name if first.is_massive() else (second as Foe).display_name))
		return
	var from := Vector2i(first.rank, first.column)
	var ours := _slot_contents(from)   # a twin slot's pair moves together, and a Mine with its foe
	if second is Foe:
		var other: Foe = second
		var to := Vector2i(other.rank, other.column)
		var theirs := _slot_contents(to)
		_set_contents(to, ours)
		_set_contents(from, theirs)
		log.append("%s and %s trade places" % [first.display_name, other.display_name])
	elif second is Vector2i:
		var slot: Vector2i = second
		_set_contents(from, [null, null])
		_set_contents(slot, ours)
		log.append("%s is moved to the %s rank" % [first.display_name, "front" if slot.x == 0 else "back"])
	_refresh_kin()
	_refresh_guards()


## A slot's contents, [the left foe or null, its twin or null].
func _slot_contents(at: Vector2i) -> Array:
	return [foe_at(at.x, at.y), twins.get(at, null)]


## Stand [left, twin] in a slot, as they are.
func _set_contents(at: Vector2i, c: Array) -> void:
	_set_slot(at, c[0])
	if c[1] != null:
		twins[at] = c[1]
	else:
		twins.erase(at)
	for f in c:
		if f != null:
			f.rank = at.x
			f.column = at.y


## A swap read without making it (the bot's bunching, 22 October): the two foes, or the foe and
## the empty slot, trade places while `read` runs, then stand where they stood; no log, no kin or
## guard refreshed.
func swap_what_if(first: Foe, second, read: Callable) -> void:
	var from := Vector2i(first.rank, first.column)
	var other: Foe = second if second is Foe else null
	var to: Vector2i = Vector2i(other.rank, other.column) if other != null else second
	var ours := _slot_contents(from)
	var theirs := _slot_contents(to)
	_set_contents(to, ours)
	_set_contents(from, theirs)
	read.call()
	_set_contents(from, ours)
	_set_contents(to, theirs)


func _set_slot(at: Vector2i, f: Foe) -> void:
	if at.x == 0:
		front[at.y] = f
	else:
		back[at.y] = f


## Silenced (Ryan, 17 and 18 October; built 21 October; keywords alone since 28 October): its
## components' keywords are muted through its next round, its buffs and stores untouched, as a
## foe's Disabled lasts: the foe acts as the round ends, so "the round" a silence costs is the
## machine's next.
func _silence(t: MechState, f: Foe) -> void:
	Effects.grant_for_rounds(t.unit, Effects.STATUS["silenced"], "foe:" + f.content_id, round + 1)
	log.append("%s silences %s: its keywords are muted through its next round" % [f.display_name, t.unit.display_name])


## A foe's Purge N (28 October; by its number since 2 November): every buff the machine carries
## loses N stacks for good, whatever granted it (Ryan, 8 November: "A stack is a stack, doesn't
## matter where it came from"); its abilities, its stores and a stack its passive keeps stay.
func _purge(t: MechState, f: Foe, n: int = 1) -> void:
	var touched := Effects.purge(t.unit, n)
	log.append("%s purges %s ×%d%s" % [f.display_name, t.unit.display_name, n, ": " + ", ".join(touched) if not touched.is_empty() else ", and finds nothing to take"])


## The round ends with the machines' statuses ticking, after the enemy has struck. Burning and
## Scorched are not among them: they tick at the end of the player's turn (_burn_mechs).
func _tick_mechs() -> void:
	for ms in live_mechs():
		var t := Effects.tick(ms.unit, true, round_holds)
		if int(t["heat"]) > 0:
			log.append("%s: %d heat from its statuses" % [ms.unit.display_name, int(t["heat"])])
			_add_heat(ms, int(t["heat"]))


## The end of the player's turn, before the overheat (Ryan, 13 October): each machine's
## Burning adds its heat, so a vent made room for it or a cleanse took it off; Burning loses a
## stack and Scorched goes.
## A machine's shield regen as the round opens: the stat, and what its heat adds to it (the
## Buzzard's Thermal Recoupler).
static func shield_regen_of(ms: MechState) -> int:
	return maxi(0, ms.unit.shield_regen + Effects.regen_from_heat(ms.unit, ms.heat))


## The heat a sealed machine runs at the end of its turn (the Polar Bear's Lockdown): the
## seal's own number, or nothing.
func seal_heat(ms: MechState) -> int:
	if not Effects.is_sealed(ms.unit):
		return 0
	return int(Effects.seal_form(ms.unit).get("heat", 0))


## Sealed machines run hotter at the end of the player's turn, after Burning and before the
## overheat (Burning's timing), so the clock bites where a vent can answer it.
func _seal_heat() -> void:
	for ms in live_mechs():
		var h := seal_heat(ms)
		if h > 0:
			log.append("%s runs sealed: +%d heat" % [ms.unit.display_name, h])
			_add_heat(ms, h)


## The form change (the Polar Bear's Lockdown, Ryan's framework of 15 October, his go 20
## October; its trigger since the refit pass took the shields off the die, Ryan, 11 November:
## "target equipment at itself to seal. And then the only way to open is with a weapon. Offensive
## equipment like it's lure remain neutral"): equipment it spends on itself seals the machine, a
## weapon it fires opens it; equipment on an ally and a debuff (its lures) leave the form as it
## is, and so does a shield or a vent, kinds no die is dealt. The seal is one chip carrying the
## passive's armour; the heat clock and the stopped cooling read it.
func _shift_form(ms: MechState, f: Face, target) -> void:
	if not ms.alive():
		return
	match form_change(ms, f, not (target is MechState) or target == ms):
		"seal":
			var seal := Effects.seal_form(ms.unit)
			Effects.stack(ms.unit, Effects.sealed_status(int(seal["armour"]), int(seal["heat"])), Effects.SKIRMISH, "seal", 1, Effects.DECAY_NONE)
			log.append("%s seals: armour +%d, its own cooling stopped, +%d heat a turn" % [ms.unit.display_name, int(seal["armour"]), int(seal["heat"])])
		"open":
			Effects.remove(ms.unit, "sealed")
			log.append("%s opens" % ms.unit.display_name)


## What a spend does to its machine's form (_shift_form), read off the form as it stands: "seal"
## for a buff spent on itself while open, "open" for a weapon while sealed, "" for nothing. The
## die's mark reads it too. `on_self` says the spend lands on its own machine: a buff dropped on
## itself, or one written for itself alone.
static func form_change(ms: MechState, f: Face, on_self: bool = true) -> String:
	if ms == null or f == null or Effects.seal_form(ms.unit).is_empty():
		return ""
	if Effects.is_sealed(ms.unit):
		return "open" if f.is_weapon() else ""
	return "seal" if f.kind == Face.Kind.BUFF and on_self else ""


func _burn_mechs() -> void:
	for ms in live_mechs():
		var t := Effects.turn_tick(ms.unit)
		if int(t["heat"]) > 0:
			log.append("%s burns: +%d heat" % [ms.unit.display_name, int(t["heat"])])
			_add_heat(ms, int(t["heat"]))


## A foe's fire on a machine (Ryan, 13 October: Burn and Scorch; foes heat machines only
## through them): stacks of Burning or Scorched for the skirmish, decaying as each says at the
## end of the player's turn (Burning a stack, Scorched every stack).
func _fire_on(t: MechState, id: String, n: int, f: Foe) -> void:
	Effects.stack(t.unit, Effects.STATUS[id], Effects.SKIRMISH, "foe:" + f.content_id, n, Effects.status_decay(Effects.STATUS[id]))


## Refused at every state: there is no withdrawal (can_withdraw, the long wall brief 3.5).
func withdraw() -> bool:
	return false


# ---------------------------------------------------------------- resolution

## A weapon's or a debuff's spend at a foe, the plain one (the salvo and a vent's blast fire their
## own: _salvo, _blast). A forging machine's gun pays ammo first for the heat its own spend would
## make (the Musk Ox's Desublimation Forge), a dry magazine firing nothing; then its hits (_hit);
## then, in the rider phase before the death check, on a target the hit felled too: the Mine its
## machine leaves on the target (_lay_mine, what the hits fired at it) and what the entry does
## past its blow (_entry_effects: the gather, the detonation, the Swap with
## its `second` target); then the hits' end (_finish_hits).
func _spend_at(mech_index: int, ms: MechState, f: Face, target: Foe, second = null) -> void:
	var pays: int = Pays.HEAT
	var price := ammo_price_of(ms, f)
	if price > 0:
		if ms.ammo < price:
			log.append("%s: the magazine is dry" % ms.unit.display_name)
			return
		ms.ammo -= price
		pays = Pays.AMMO
	var h := _hit(ms, f, target)
	_lay_mine(ms, target, h.mine)
	if f.reach != Face.Reach.SWEEP:
		_entry_effects(ms, f, target, second)
	_finish_hits(mech_index, ms, f, target, h, pays)


## One weapon's or debuff's hits on its target, shared by every spend at a foe (the plain one, the
## salvo, a vent's blast) and paying for none of it: every strike is its own blow (its own number,
## its keywords and passives), landing on every foe the component reaches; then the riders, the
## hopper's loads and what lands after the blow (_after_blow). The death check and what the spend
## pays are its caller's (_finish_hits).
func _hit(ms: MechState, f: Face, target: Foe) -> Hits:
	var h := Hits.new()
	h.reach = reach_of(ms, f)
	h.aimed_back = target.rank == 1
	var touched: Array = []    # every foe the blows reached, felled or not, for Shock, Expose, Lure and Disrupt
	var gained := {}           # foe -> the statuses this spend put on it, told once each at the end (an application, never a stack or a strike)
	var turned := {}           # foe -> the marks its Ward turned away this spend, told once at the end (28 October)
	# A vent-on-fire attack fires the machine's whole heat into the blow: its bonus is read now and
	# the gauge emptied before the strikes land.
	var fired := heat_bonus(ms, f)
	h.fired = fired
	var loads := hopper_loads(ms.unit, f)   # the loads this shot fires from the hopper, read once too
	var from_hopper := loads * f.power_per_load
	var own := fired + from_hopper   # what the entry prints from its firer, on every blow of the spend
	var damaged: Array = []    # every foe the blows took HP off, for the hopper's loads (Ryan, 31 October: "per foe damaged")
	h.vented_all = ms.heat if f.vents_all else 0
	if f.vents_all:
		ms.heat = 0
	# Every foe one strike reaches (a Spread's neighbours, a Penetrate's column), the same for
	# each strike, since a kill clears its slot only after the spend; a sweep's later strikes
	# find their own (below).
	var hit := reached_by(f, target)
	var shapes := area_shapes(f, target)   # the shape each foe past the target stands in, for its number
	# What the hit judges on each foe it reaches, before it lands (_judge): its machine's lays,
	# the foe's own reads and the gates. A single-target weapon's hits judge once, here; a Sweep's
	# shots each judge their own as they fire (below).
	var sweep := f.reach == Face.Reach.SWEEP
	var judged := _judge(ms, f, [] if sweep else hit)
	var lays: Dictionary = judged["lays"]
	var reads: Dictionary = judged["reads"]
	var shut: Dictionary = judged["shut"]
	var laid := {}
	var webbed: Array[Foe] = []
	var riders: Array[Callable] = []   # every rider the strikes earn, in order, landed once the strikes are done (Ryan, 3 November)
	var doubled := Effects.stack_multiplier(ms.unit, f, target)   # the stacks this spend lays, multiplied (the sixth shot)
	var told_shut := {}   # the foes a gate turned the keyword from, told once
	var split := maxi(1, f.split)    # the Skua's Split-cycle Breech: the hits it doubles, each base halved (Effects.split_of)
	# Two shapes of weapon (Ryan, 7 November). A single-target one, area included: its hits all on
	# the target, every hit's riders, then the death check. A multi-target one, Sweep alone for
	# now, "Fires a shot at each column, left to right, repeating until it runs out of shots": each
	# shot aimed at the foe in its column of the rank picked, hit and its riders landed before the
	# next shot fires, then the death check once the shots are done. The Musk Ox's salvo is a
	# Sweep, an ammo a shot (_salvo).
	h.sweep_rank = sweep_rank_of(target) if sweep else -1
	var spots: Array = sweep_spots(h.sweep_rank) if sweep else []   # queued as the spend begins (Ryan, 8 November)
	var aimed := target              # the hit's own foe: the target, or the foe in a shot's column
	var struck_once := {}            # every foe a blow of the spend has met, for what a foe reads on its first
	var blocked := 0                 # the weapon's blows a living foe's armour or Barrier took whole (on_blocked)
	if sweep:
		h.heat += int(Effects.attack(ms.unit, f, 0, f.heat, target)["heat"])   # a sweep's heat, once, wherever its first shot falls
	for s in range(maxi(1, f.strikes)):
		if sweep:
			# A shot at its spot: the foe there, standing or felled by an earlier shot, since a kill
			# clears nothing until the death check (Ryan, 7 November: "sweep hits a unit it already
			# killed and doesn't skip it"); an empty column takes the shot and nothing else, its area
			# with it, so a lone foe takes its own column's shots alone ("it will NOT stack hits on a
			# solo boss"); a pair's halves a spot each (8 November).
			var spot: Array = spots[s % spots.size()]
			aimed = spot[0]
			if aimed == null:
				h.swept.append("nothing")
				_note_miss(Vector2i(h.sweep_rank, int(spot[1])), s)   # fired all the same, so the screen shows it land
				continue
			hit = reached_by(f, aimed)
			shapes = area_shapes(f, aimed)
			# Each shot a hit of its own (Ryan, 8 November: "Per shot"): it judges the foes it
			# reaches as it fires, the shots before it landed, and what a foe reads on its first
			# blow is read on this shot's.
			judged = _judge(ms, f, hit)
			lays = judged["lays"]
			reads = judged["reads"]
			shut = judged["shut"]
			struck_once.clear()
			doubled = Effects.stack_multiplier(ms.unit, f, aimed)
		if s % split == 0:
			h.base += f.power + own   # the number before the pipeline, once a split's hits, for the screen's flash
		var heat := f.heat if s == 0 and not sweep else 0
		# The blow's order (Ryan, 28 October), the hit's own foe (the target, or a shot's) first:
		# the entry's number and what it prints from its firer (the heat Vents all fired, the
		# hopper's loads), a split's halving of that base (the Skua's, Ryan, 7 November: "base
		# weapon damage is halved"), then the firer's pipeline, every live modifier's adds,
		# multiplies and floors in that order, its conditions read on that foe; then that foe's own
		# reads, flat (_foe_reads): "the spirit of buffs and riders is they happen after".
		var modded := Effects.attack(ms.unit, f, split_share(f.power + own, split), heat, aimed)
		var dmg: int = int(modded["damage"]) + _foe_reads(f, reads, aimed, not struck_once.has(aimed))
		if s == 0 and not sweep:
			h.heat += modded["heat"]   # heat is paid once a spend, every modifier's with it (the rules: a blow)
		h.vent += modded["vent"]
		var landed := dmg
		# Area by shape, numbered (Ryan, 28 October; the half retired): every other foe the strike
		# reaches takes its shape's number (Spread's, Penetrate's, Splash's, Chain's on a Shocked
		# conductor, whose Shock stands, no strike being aimed at it) in place of the roll,
		# through the same order, the firer's modifiers on it and its own reads. Every blow of the
		# strike is read before any lands, so a kill in it (the talons' Empowered) feeds the next
		# strike, never this one's other blows.
		var blows := {}
		for foe in hit:
			blows[foe] = dmg if foe == aimed else _area_blow(ms, f, int(shapes.get(foe, AREA_ALL)), foe, own, split) + _foe_reads(f, reads, foe, not struck_once.has(foe))
		for foe in hit:
			var was_alive := foe.alive()
			var hp_before := foe.hp
			var first := not struck_once.has(foe)   # the foe's first blow of the spend
			struck_once[foe] = true
			var into_mine := foe == aimed and aimed == target   # a hit aimed at the spend's target: its riders are the Mine's too
			if not h.reached.has(foe):
				h.reached.append(foe)
			if int(shapes.get(foe, 0)) == AREA_CHAIN:
				log.append("%s arcs to %s" % [ms.unit.display_name, foe.display_name])   # Chain (28 October): a conductor's blow
			var blow: int = blows[foe]
			# Spillover (Overwhelm until 6 October): damage past the kill of a front-rank foe carries
			# into the foe behind it (_spill). A massive foe fills its column: nothing is behind it.
			var spills := f.has(Face.Keyword.SPILLOVER) and foe.rank == 0 and not foe.is_massive()
			var taken := 0   # what the foe takes of the blow, nothing for a corpse a later strike spills past
			if spills and not was_alive:
				# A later strike on a foe an earlier strike of this spend killed (Ryan, 15 October:
				# "All its damage or subsequent strikes spill over"): the fallen foe takes nothing
				# more, its armour included, and the strike's whole number goes on behind it; with
				# nothing standing there, it is lost. The blow's record counts it whole, as it
				# counts the killing strike's excess. Its riders land on the corpse as any hit's do
				# (the audit's eighth bug, 8 November: a Wild Boar's ×2 Flak 1 that kills with its
				# first strike leaves Flak 2).
				if foe == aimed:
					_note_blow(foe, s, 0, "strike")   # the shot lands on the corpse before it spills
				_spill(ms, f, foe, blow, hit, s, not f.is_debuff())
				if foe == aimed:
					landed = blow
			else:
				# What the foe takes of the blow: its own statuses read last (its Flak adds to a
				# weapon's blow, a strike of 0 included: Ryan, 25 October; a Shocked foe takes the
				# strike aimed at it double, spending the shock, while a blow that only reaches it, an
				# area's or a Chain's arc, neither doubles nor spends it: Ryan, 29 October), then its armour comes off, flat,
				# so small blows bounce off a braced foe the way they do off a heavy machine; a
				# breaching blow meets none (one breach, 22 October). Every blow is recorded, one on a
				# foe an earlier hit of the spend felled included, so the screen shows every hit and
				# shot land (Ryan, 7 November: "Anything truncated confuses the player").
				var landing := _land_blow(foe, blow, ms.unit, not f.is_debuff(), foe == aimed, foe.armour_for(f), s, "strike" if foe == aimed else ("chain" if int(shapes.get(foe, 0)) == AREA_CHAIN else "area"))
				taken = int(landing["taken"])
				var foe_armoured := int(landing["armoured"])
				var barred := bool(landing["barred"])
				if was_alive and not f.is_debuff() and taken == 0 and (barred or foe_armoured > 0):
					blocked += 1   # a blow its armour or its Barrier took whole, every foe's and every strike's
				if was_alive and taken > 0 and not damaged.has(foe):
					damaged.append(foe)
				var eaten := int(reads.get(foe, [0, 0])[1]) if first else 0   # each foe struck eats its own, on its first blow
				if eaten > 0:
					Effects.remove(foe, f.consumes)
					log.append("%s consumes %s ×%d on %s, +%d" % [ms.unit.display_name, str(Effects.STATUS.get(f.consumes, {}).get("name", f.consumes)), eaten, foe.display_name, eaten * f.per_consumed])
				if was_alive:
					h.dealt += clampi(taken, 0, maxi(0, hp_before))
				if foe == aimed:
					landed = taken
					h.armoured += foe_armoured
				# A weapon's strike aimed at the foe spends a shock, even one that deals nothing (Ryan,
				# 25 October: "The important part is that it was a damaging weapon"; 29 October: "when
				# targeted and struck by a weapon"); equipment (a lure, a probe) and a blow that only
				# reaches the foe leave it standing.
				if not f.is_debuff() and foe == aimed and Effects.remove(foe, "shocked"):
					log.append(("%s: the shock is spent on the Barrier" % foe.display_name) if barred else ("%s: the shock lands, %d doubled" % [foe.display_name, blow]))
			# A hit lays what the passives lay on this foe, a stack per strike, a debuff's included,
			# unless the passive asks for a weapon's hit (the Ambush's Vitriol, its text says so:
			# Ryan, 25 October).
			if lays.has(foe):
				for pair in lays[foe]:
					if bool(pair[2]) and f.is_debuff():
						continue
					var sid := str(pair[0])
					var n_laid := _stacks_from(ms, sid, int(pair[1])) * doubled
					riders.append(func() -> void: _land_rider(foe, sid, n_laid, gained, turned, laid))
					if into_mine:
						h.mine_stack(sid, n_laid)
			# The killing strike: what it had past the kill carries on.
			if spills and was_alive and not foe.alive():
				_spill(ms, f, foe, taken - hp_before, hit, s)
			# Every rider lands on the foe its strike struck, felled or not (Ryan, 3 November: "the
			# point is to show that the riders hit, AND it dies"; death is the spend's last check, so
			# the preview shows them beside the skull and no trigger goes unfired).
			if f.has(Face.Keyword.BURN):
				# Burn is a numbered keyword (Ryan, 18 October): the stacks it says, whatever the
				# blow dealt (it was a stack per 10 of the damage, rounded up, until then).
				var burn_laid := _stacks_from(ms, "burning", f.burn) * doubled
				riders.append(func() -> void: _land_rider(foe, "burning", burn_laid, gained, turned))
				if into_mine:
					h.mine_stack("burning", burn_laid)
			if f.has(Face.Keyword.SUPPRESS) and shut.get(foe, []).has(Face.Keyword.SUPPRESS):
				if foe.alive() and not told_shut.has(foe):
					told_shut[foe] = true
					log.append("%s's suppress does not land on %s (%s)" % [ms.unit.display_name, foe.display_name, Effects.gate_text(f.gates.get("suppress", {}))])
			elif f.has(Face.Keyword.SUPPRESS):
				riders.append(func() -> void:
					if _suppress(foe, turned):
						_note_status(gained, foe, "suppressed"))
				if into_mine:
					h.mine_flag(Face.Keyword.SUPPRESS)   # fired through its gate: each foe the blast meets judges its own Numbed
			# Web (18 October): the foe is Webbed, one web however often it is webbed, and the
			# skirmish bursts it at the end of the foe's action (_web_burst).
			if f.has(Face.Keyword.WEB):
				riders.append(func() -> void: _land_web(foe, gained, turned, webbed))
				if into_mine:
					h.mine_flag(Face.Keyword.WEB)
			# Cryo (20 October): a weapon's hit spends every stack the foe carries (Ryan, 25
			# October), and the hitter cools for them once the spend's own heat has landed (below);
			# equipment spends none. The blow's own Cryo lands with the riders, so a spend never
			# eats what it lays.
			if was_alive and not f.is_debuff() and Effects.has(foe, "cryoed"):
				h.thawed += Effects.stacks_of(foe, "cryoed")
				Effects.remove(foe, "cryoed")
			if f.has(Face.Keyword.CRYO):
				var cryo_laid := _stacks_from(ms, "cryoed", f.cryo) * doubled
				riders.append(func() -> void: _land_rider(foe, "cryoed", cryo_laid, gained, turned))
				if into_mine:
					h.mine_stack("cryoed", cryo_laid)
			# Flak (Ryan's go, 19 October; built 21 October): each foe hit gains the keyword's
			# number in stacks a strike, with the riders, so no strike of the spend feeds on what
			# it lays (Ryan, 3 November: "5,5,5 makes way more sense to me").
			if f.has(Face.Keyword.FLAK):
				var flak_laid := _stacks_from(ms, "flakked", f.flak) * doubled
				riders.append(func() -> void: _land_rider(foe, "flakked", flak_laid, gained, turned))
				if into_mine:
					h.mine_stack("flakked", flak_laid)
			# A pin (the Hollow-point Harpoon's; Ryan, 11 November: "the target's flak does not decay
			# this round"): the status held through this round's end, after what the spend lays.
			if not f.holds.is_empty():
				var held_id := f.holds
				riders.append(func() -> void:
					var holder: String = Effects.HOLDERS[held_id]
					if foe.alive() and Effects.grant_for_rounds(foe, Effects.STATUS[holder], "mech", round) != null:
						log.append("%s is %s: its %s does not decay this round" % [foe.display_name, str(Effects.STATUS[holder]["name"]), str(Effects.STATUS[held_id]["name"])])
						_foe_gained_status(foe, holder))
			# Purge (the player's, 28 October): every buff the foe carries but Numbed and Guarded,
			# with the riders, equipment's included; a foe the blow killed loses its Getting Back
			# Up, so it stays down.
			if f.has(Face.Keyword.DISPEL):
				var purged := maxi(1, f.dispel)
				riders.append(func() -> void: _purge_foe(ms.unit.display_name, foe, purged, turned))
				if into_mine:
					h.mine["dispel"] = int(h.mine["dispel"]) + purged
			if into_mine and f.has(Face.Keyword.CHAIN) and not f.is_debuff():
				h.mine["chain"] = int(h.mine["chain"]) + maxi(0, f.chain)   # every hit's arc number
			if not touched.has(foe):
				touched.append(foe)   # every foe the blows reached, felled or not: Shock, Expose, Lure and Disrupt land on it below
		# A Primed machine's Burning, a stack a strike on each strike's own foe (the mechanics
		# audit's 8, 27 October): a sweep's strikes burn the foes they fell on.
		if int(modded["burn"]) > 0:
			var primed_laid := _stacks_from(ms, "burning", int(modded["burn"])) * doubled
			var struck := aimed
			riders.append(func() -> void: _land_rider(struck, "burning", primed_laid, gained, turned))
			if aimed == target:
				h.mine_stack("burning", primed_laid)
		h.total += landed
		if sweep:
			h.swept.append("%s %d" % [aimed.display_name, landed])
			# A shot is a hit of its own (Ryan, 7 November: "[select target - hit(s) - riders per
			# hit] for each shot fired"): its riders, and what lands after its blow, land before
			# the next shot fires, so a later shot at the same column reads them.
			_land_riders(ms, riders, laid, webbed)
			_after_blow(ms, f, touched, gained, turned)
	# Riders land after the hits (Ryan, 3 November: "a multi-hit weapon with Shock would apply it
	# after both hits ... Cryo should work the same way, resulting in 2 applications, not
	# apply-cash-apply-cash, and not hit-hit-apply once"; and "It should be standard, not
	# branching code"): every rider the hits earned, gathered above in the order the hits earned
	# them, lands now the hits are done, an application a hit on each hit's own foe, so nothing in
	# the hit cashes, feeds on or reads what it lays. Shock, Expose, Lure and Disrupt land below,
	# after the blow, as they did. A sweep landed each shot's above.
	if not sweep:
		_land_riders(ms, riders, laid, webbed)
	# The hopper (11 October; the Ore Hopper, 31 October): a shot that fires it spends the loads
	# it took; then each foe the spend's blows damaged puts loads in, after the blow, so a claw
	# never feeds the shot it is part of: a weapon's own number where it prints one (the
	# Chainsaw Claw's two), the passive's for any other weapon, never past the hopper's cap. The
	# hopper's Armoured follows the loads' worth both ways (Effects._plate).
	if loads > 0:
		Effects.spend_loads(ms.unit, loads)
		log.append("%s fires the hopper: %d load%s, +%d" % [ms.unit.display_name, loads, "" if loads == 1 else "s", from_hopper])
	var per_foe := hopper_fill_of(ms.unit, f)
	if per_foe > 0 and not damaged.is_empty():
		var n := Effects.add_loads(ms.unit, per_foe * damaged.size())
		if n > 0:
			log.append("%s fills the hopper: +%d (%d)" % [ms.unit.display_name, n, Effects.stacks_of(ms.unit, "hopper")])
	if not sweep:
		_after_blow(ms, f, touched, gained, turned)
	if blocked > 0:
		_blows_blocked(ms, blocked)
	# What lands after the blow, and Breach on it, ride a Mine once.
	for k in [Face.Keyword.SHOCK, Face.Keyword.EXPOSE, Face.Keyword.DISRUPT, Face.Keyword.BREACH]:
		if f.has(k):
			h.mine_flag(k)
	return h


## One blow of a hit landing on a foe, a strike's, an area's, an arc's or a spill's: what the foe
## takes of `blow` (Effects.damage_taken: its own statuses read last, a `weapon`'s blow taking its
## Flak even at 0, a Shocked foe's double on a weapon's strike `aimed` at it), a Barrier taking a
## weapon's blow whole (28 October), then its `armour`, flat; off its HP and recorded for the
## screen as `kind` in `strike`. Returns {taken: what came off its HP, armoured: what the armour
## took, barred: whether a Barrier took it}.
func _land_blow(foe: Foe, blow: int, by: Unit, weapon: bool, aimed: bool, armour: int, strike: int, kind: String) -> Dictionary:
	var taken := Effects.damage_taken(foe, blow, by, weapon, aimed)
	var barred := _barrier_eats(foe, weapon)
	if barred:
		taken = 0   # its riders land all the same
	var armoured := mini(taken, armour)
	taken -= armoured
	foe.hp -= taken
	_note_blow(foe, strike, taken, kind)
	return {"taken": taken, "armoured": armoured, "barred": barred}


## The end of a spend's hits, in the spend's order (Ryan, 7 November: the hits and their riders,
## the death check, the spend's end): told (_tell_hits), the shield's burn and its zap for a gun
## whose heat its gauge takes (_zap), the death check, then what the spend pays (_pay_hits,
## `pays` one of Pays).
func _finish_hits(mech_index: int, ms: MechState, f: Face, target: Foe, h: Hits, pays: int) -> void:
	_tell_hits(mech_index, ms, f, target, h, pays)
	if pays == Pays.HEAT:
		_zap(ms, f, target, h)
	# The death check (Ryan, 7 November), once the hits and their riders are done, a sweep's every
	# shot: a kill clears its slot (Ryan, 22 September: burning a hole through the front opens the
	# back rank to direct fire), and what it brings back waits for the spend's end. Indirect fire
	# at the front rank costs its firer nothing (danger close retired with the stock pass, 22 October).
	_clear_dead()
	_pay_hits(ms, f, h, pays)


## The hits told: the screen's last roll and the log's line (a Sweep's shots, a vent's blast or a
## hit), then the heat Vents all fired into them.
func _tell_hits(mech_index: int, ms: MechState, f: Face, target: Foe, h: Hits, pays: int) -> void:
	last_roll = {"mech": mech_index, "target": target, "base": h.base, "final": h.total, "tags": f.tags.duplicate()}
	var how := f.describe()
	var armour := " (armour -%d)" % h.armoured if h.armoured > 0 else ""
	if f.reach == Face.Reach.SWEEP:
		log.append("%s sweeps the %s: %s (%s)%s" % [ms.unit.display_name, "front" if h.sweep_rank == 0 else "back", ", ".join(h.swept), how, armour])
	elif pays == Pays.VENT:
		log.append("%s's vent blasts %s for %d%s" % [ms.unit.display_name, target.display_name, h.total, armour])
	else:
		log.append("%s hits %s for %d (%s)%s" % [ms.unit.display_name, target.display_name, h.total, how, armour])
	if h.vented_all > 0:
		log.append("%s fires its heat: -%d, +%d to the blow" % [ms.unit.display_name, h.vented_all, h.fired])


## The Riot Field Generator (the Storm Petrel's, Ryan's go of 21 October; built 30 October): while
## its shield stands its weapons burn shield in place of heat, the gun's own heat coming off the
## shield as it stands, overshield included, and the rest reaching the gauge, a Scorched machine's
## extra among it (shield_burn); then, the hits landed, the target takes a blow of what the
## shield paid (the zap), plain, no keyword and no Shock read, through what it takes and its
## armour, before the death check, so a target the strikes felled takes it too (Ryan, 7 November).
## The burn comes off the hits' heat and the zap's hull joins what they dealt.
func _zap(ms: MechState, f: Face, target: Foe, h: Hits) -> void:
	var burnt := shield_burn(ms, f, h.heat)
	if burnt <= 0:
		return
	ms.unit.shield -= burnt
	h.heat -= burnt
	log.append("%s burns %d shield in place of heat" % [ms.unit.display_name, burnt])
	var zap_before := target.hp
	var zap := zap_on(target, burnt, ms)
	if _barrier_eats(target, true):
		zap = 0
	target.hp -= zap
	_note_blow(target, maxi(1, f.strikes), zap, "zap")   # after the strikes, on a corpse too
	h.dealt += clampi(zap, 0, maxi(0, zap_before))
	log.append("%s zaps %s for %d" % [ms.unit.display_name, target.display_name, zap])


## What a spend pays for its hits once its death check is done, in order: the runner's reach tally
## (a lure or a probe deals nothing and is no spend of damage; a vent's blast is no spend of its
## own), the heat the firer's modifiers vent, the spend's heat as `pays` says (Pays: the gauge takes
## the hits'; the forge took the gun's own in ammo, the salvo's included, a foe's debuff still
## heating it, Ryan, 8 November: "scorch affects the actual heat bar, not the ammo cost"; the
## vent's spend paid a blast's, once), the Shrapnel Recuperator's casings (ammo back for every foe
## its blows reached), and the Cryo its hits spent, cooling the hitter once its heat has landed.
func _pay_hits(ms: MechState, f: Face, h: Hits, pays: int) -> void:
	if f.power > 0 and pays != Pays.VENT:
		_tally_reach(h.reach, h.dealt, h.aimed_back, h.heat)
	if h.vent > 0:
		ms.heat = maxi(0, ms.heat - h.vent)
	var heat := h.heat
	if pays == Pays.AMMO:
		heat = Effects.debuff_heat(ms.unit, f)
	elif pays == Pays.VENT:
		heat = 0
	_add_heat(ms, heat, ms.face_index)
	if f.ammo_per_foe_hit > 0 and ms.ammo_max > 0 and not h.reached.is_empty():
		_reload(ms, f.ammo_per_foe_hit * h.reached.size(), "its casings")
	if h.thawed > 0:
		var cooled := mini(ms.heat, h.thawed * cryo_cool())
		ms.heat -= cooled
		log.append("%s cashes Cryo ×%d: -%d heat" % [ms.unit.display_name, h.thawed, cooled])


## What a hit judges on each foe it reaches, read before it lands (the blow's order, Ryan, 28
## October): its machine's lays, judged alone (the funnel-web's Ambush, 18 October: a Suppress gun
## never feeds its own read), foe -> [[status id, stacks a hit, asks a weapon], ...]; the foe's
## own reads (the mechanics audit's 19), foe -> [the hull it is missing (the Coriolis's), the
## stacks a consumer eats on it (the Backdraft Charge's)], landed on its blow after the firer's
## pipeline, flat, beside its Flak, the eaten stacks a point each on its first blow and gone as it
## lands; and the gates (the stock pass's engine, 22 October: the Suppression Battery's Suppress on
## a foe carrying Flak), foe -> [keywords turned away], so a hit never opens its own gate. A
## single-target weapon's hits judge once, at the spend; a Sweep's shots each their own as they
## fire, the shots before them landed (Ryan, 8 November: "Per shot").
func _judge(ms: MechState, f: Face, foes: Array) -> Dictionary:
	var lays := {}
	var reads := {}
	var shut := {}
	for foe in foes:
		var l := Effects.laid_statuses(ms.unit, f, foe)
		if not l.is_empty():
			lays[foe] = l
		reads[foe] = [f.missing_bonus(foe), Effects.stacks_of(foe, f.consumes) if not f.consumes.is_empty() else 0]
		if f.has(Face.Keyword.SUPPRESS) and not Effects.gate_holds(ms.unit, f, Face.Keyword.SUPPRESS, foe):
			shut[foe] = [Face.Keyword.SUPPRESS]
	return {"lays": lays, "reads": reads, "shut": shut}


## What an entry does past its blow, landed in the rider phase before the death check, on a
## target the hit felled too (Ryan, 7 November: "deal damage, then swap (in the rider phase),
## check death, end spend, and revive in the NEW spot, since the split/revive is attached to the
## unit, not the spot"): the Lorentz Contractor gathers every Mine onto the target, the Syrinx
## Drone detonates the target's (each after the spend's own Mine joined it), and the Swap moves
## the target and its `second`.
func _entry_effects(ms: MechState, f: Face, target: Foe, second = null) -> void:
	if target == null or target.rank < 0:
		return
	if f.gathers_mines:
		_gather_mines(ms, target)
	if f.detonates:
		_detonate(ms, target)
	if f.has(Face.Keyword.SWAP) and second != null:
		_swap(target, second)
		# What the Swap carries lands on the foe traded with too (the Translocator's Shock: both
		# come out Shocked).
		if second is Foe and (second as Foe).alive() and f.has(Face.Keyword.SHOCK):
			_shock(second, ms)


## A hit's riders landing (Ryan, 3 November: "a multi-hit weapon with Shock would apply it after
## both hits"): every rider its hits earned, in the order they earned them, an application a hit
## on each hit's own foe; then what they laid and webbed, told. A single-target weapon lands
## them once its hits are done, a Sweep once each shot is (Ryan, 7 November).
func _land_riders(ms: MechState, riders: Array[Callable], laid: Dictionary, webbed: Array[Foe]) -> void:
	for land in riders:
		land.call()
	for foe in laid.keys():
		var bits: Array[String] = []
		for sid in laid[foe].keys():
			bits.append("%s ×%d" % [str(Effects.STATUS[sid]["name"]), int(laid[foe][sid])])
		log.append("%s lays %s on %s" % [ms.unit.display_name, ", ".join(bits), foe.display_name])
	for foe in webbed:
		var caught := web_catch(foe)
		log.append("%s webs %s: it bursts after its action%s" % [ms.unit.display_name, foe.display_name, "" if caught == null else ", on it and %s" % caught.display_name])
	riders.clear()
	laid.clear()
	webbed.clear()


## What lands after a hit's blow, on every foe its blows reached, felled or not, before the death
## check: Shock (9 October: a charge for the team's next blow, after this one landed, so a
## shocking hit never spends its own), Expose (through the next round, a second refreshing it),
## Disrupt then Lure (so an entry carrying both ends with the foe's new move aimed at the
## spender); then what a Ward turned away, told, and every status gained, for what reads it.
func _after_blow(ms: MechState, f: Face, touched: Array, gained: Dictionary, turned: Dictionary) -> void:
	if f.has(Face.Keyword.SHOCK):
		for foe in touched:
			_shock(foe, ms, turned)
	if f.has(Face.Keyword.EXPOSE):
		for foe in touched:
			_expose(foe, ms, turned)
	if f.has(Face.Keyword.DISRUPT):
		_disrupt(touched)
	if f.has(Face.Keyword.LURE):
		_lure(ms, touched)
	_tell_turned(turned)
	for foe in gained.keys():
		for status_id in gained[foe]:
			_foe_gained_status(foe, status_id)
	touched.clear()
	gained.clear()
	turned.clear()


## A vent's blast (the Whip Scorpion's Thermal Ejection Manifold): the heat it took off, as
## one flat blow of the machine's on a live foe drawn from the seeded stream, back rank
## included. The vent is a weapon too on that machine (Effects.kinds_of; Ryan, 26 October:
## "Vent blast should obviously proc cryo, that's the point of tagging it with weapon. It
## shouldn't need exceptions in code"), so the blow is a weapon's hit and resolves as every
## weapon's does (_hit): the machine's pipeline, the foe's Flak, a Shocked doubling spent, its
## Cryo cashed for the machine's cooling, its armour, a Primed machine's Burning, and its kills fire the machine's kill rules (_after_kills). It is one hit inside the vent's
## spend, so the spend's heat, ammo and tallies stay the vent's, paid once (Pays.VENT). A kill
## clears its slot as any blow's does. The round preview's copy draws nothing: a lone foe takes
## it for sure, else the blast is held back and noted.
func _blast(mech_index: int, ms: MechState, amount: int) -> void:
	var live := blast_targets()
	if live.is_empty() or amount <= 0:
		return
	if previewing and live.size() > 1:
		preview_notes.append({"kind": "blast", "mech": mech_index})
		return
	var foe: Foe = live[0] if previewing else live[rng.randi_range(0, live.size() - 1)]
	var shot := blast_shot(amount)
	var hp_before := foe.hp
	var h := _hit(ms, shot, foe)
	_finish_hits(mech_index, ms, shot, foe, h, Pays.VENT)
	last_blast = {"mech": mech_index, "foe": foe, "dealt": hp_before - foe.hp}


## The blast as the blow it is: flat, Indirect, the heat the vent took off.
static func blast_shot(amount: int) -> Face:
	return Face.attack(amount, Face.Reach.INDIRECT)


## A spend's kills, its weapon's or its vent's blast's, counted at its death check (is_kill):
## Empowered a kill where an entry prints it (no piece does today), the muster its guns earn (the
## Swallowtail's) and the kill trigger, once however many fell (the Kite's heat tax, 21 October) or
## once for each (an effect that says `each`: the Ammit's flare, Ryan, 12 November: "the flare
## should be the Ammit kill only"; the Souls its kills banked are in already, the death check's).
func _after_kills(ms: MechState, killed: int, f: Face = null) -> void:
	if killed <= 0:
		return
	if f != null and f.devours > 0 and ms.alive():
		_overcharge_on_kill(ms, killed, f.devours)
	_muster(ms, killed * int(Effects.muster_rule(ms.unit).get("kill", 0)))
	if ms.alive():
		var got := Effects.fire(ms.unit, "on_kill", killed)
		var parts := _apply(ms, got)
		if not parts.is_empty():
			log.append("%s: after the kill, %s" % [ms.unit.display_name, ", ".join(_with_counts(ms, parts, got))])


## What a vent spent on `who` blasts (the Whip Scorpion's Thermal Ejection Manifold, 12 and 13
## October): the heat it would take off its own machine, at the passive's share, rounded;
## nothing for a vent on an ally, an ally's vent, or a machine whose vents blast nothing. The
## spend, the die and the forecast's marks read it here.
func blast_amount(ms: MechState, f: Face, who: MechState = null) -> int:
	if ms == null or f == null or f.kind != Face.Kind.VENT or (who != null and who != ms):
		return 0
	var share := Effects.vent_blast(ms.unit)
	if share <= 0.0:
		return 0
	return int(roundf(float(mini(ms.heat, f.power)) * share))


## The foes a blast may land on: every live foe on the field, the draw being over them all.
func blast_targets() -> Array[Foe]:
	var live: Array[Foe] = []
	for foe in field_foes():
		if foe.alive():
			live.append(foe)
	return live


## A blast's number as the die prints a blow (shown_number's convention): through the machine's
## pipeline, then on `foe` its flat adds and its armour, a Shocked foe's doubling left to its
## chip; before any foe with none. The die over its own machine and the foes' marks read it.
func blast_number(ms: MechState, amount: int, foe: Foe = null) -> int:
	if amount <= 0:
		return 0
	return shown_number(ms, blast_shot(amount), foe)


## The foes a Lure entry spent on `aimed` would turn on this machine, as the arrows show them:
## every foe it reaches, alive, not suppressed, with an arrow to move (a blow at every machine
## and a special that acts on nobody keep theirs), and not on it already. A reach over every
## foe (the Whip Scorpion's Siphon) needs no aim. Empty for an entry without Lure.
func lure_turns(ms: MechState, aimed: Foe = null) -> Array[Foe]:
	var out: Array[Foe] = []
	for foe in _lured(ms, aimed):
		if foe.alive() and not foe.is_suppressed() and foe.target != ms and not foe.reaches_every_machine() and not foe.acts_on_nobody():
			out.append(foe)
	return out


## Every foe a Lure entry reaches from `aimed` as _lure would turn them (a reach over every foe
## from any of them); nothing for a spent die, an entry without Lure, or an aim it cannot take.
func _lured(ms: MechState, aimed: Foe) -> Array[Foe]:
	var out: Array[Foe] = []
	if ms == null or ms.assigned or ms.face() == null:
		return out
	var f := spend_face(ms)
	if f == null or not f.is_attack():
		return out
	var targets := targets_for_face(ms, f)
	if aimed == null and f.reaches_all and not targets.is_empty():
		aimed = targets[0]
	if aimed == null or not targets.has(aimed):
		return out
	var ef := Effects.effective_face(ms.unit, f, aimed)
	if not ef.has(Face.Keyword.LURE):
		return out
	for foe in reached_by(ef, aimed):
		if not foe.fresh:
			out.append(foe)
	return out


## Every foe one strike of an entry reaches from its target, each once: the target, a Spread's
## neighbours in its rank, a Penetrate's other rank of its column; a foe killed this round
## still standing in its slot included, as the strikes find it. The resolver and the bot read
## the same list.
func reached_by(f: Face, target: Foe) -> Array[Foe]:
	var hit: Array[Foe] = [target]
	# A reach over every foe in the fight (the Whip Scorpion's Siphon, a lure-all), front and back.
	if f.reaches_all:
		for foe in field_foes():
			if not hit.has(foe):
				hit.append(foe)
		return hit
	if f.reaches_row():
		for c in [target.column - 1, target.column + 1]:
			if c >= 0 and c < columns:
				var n := foe_at(target.rank, c)
				if n != null and not hit.has(n):
					hit.append(n)
	if f.reaches_column():
		var other := foe_at(1 - target.rank, target.column)
		if other != null and not hit.has(other):
			hit.append(other)
	if f.has_area():
		_with_twins(hit)   # an area blow reaches a twin slot whole
	# Chain's conductors (28 October): every other Shocked foe on the field, after the shapes, so
	# a foe both beside the target and Shocked takes one blow, the shape's; a twin's half only if
	# it carries the charge itself.
	for foe in conductors(f, target):
		if not hit.has(foe):
			hit.append(foe)
	return hit


## Chain's conductors (Ryan, 28 October; the kill and repeat retired): every other foe on the
## field alive and Shocked, wherever it stands and whatever the entry's reach, in the field's
## order. None for an entry without Chain, or for a debuff, whose blow is nothing. Read as the
## die is spent, before any blow lands, so a Shock the spend lays never conducts its own arc.
func conductors(f: Face, target: Foe) -> Array[Foe]:
	if f != null and f.has(Face.Keyword.CHAIN) and not f.is_debuff():
		return shocked_foes(target)
	var none: Array[Foe] = []
	return none


## Every foe on the field alive and Shocked but `but`, in the field's order: a Chain's
## conductors, a Mine's blast's included.
func shocked_foes(but: Foe) -> Array[Foe]:
	var out: Array[Foe] = []
	for foe in field_foes():
		if foe != but and foe.alive() and Effects.has(foe, "shocked") and not out.has(foe):
			out.append(foe)
	return out


## The shape each foe one strike reaches past its target stands in (area by shape, numbered:
## Ryan, 28 October), for the number it takes in place of the roll: AREA_ROW beside the target
## in its rank (Spread's, Splash's), AREA_COLUMN the other rank of its column (Penetrate's,
## Splash's), a twin slot's other half as the half it pairs with (the target's own twin beside it
## in the row, or the column's when the entry reaches no row), AREA_CHAIN every other Shocked foe
## on the field (Chain's conductors), AREA_ALL any other foe a reach over every foe adds. The
## target is not in it. The resolver and the bot read the same map.
func area_shapes(f: Face, target: Foe) -> Dictionary:
	var out := {}
	if f == null or target == null:
		return out
	if f.reaches_row():
		for c in [target.column - 1, target.column + 1]:
			if c >= 0 and c < columns:
				var n := foe_at(target.rank, c)
				if n != null and n != target and not out.has(n):
					out[n] = AREA_ROW
	if f.reaches_column():
		var other := foe_at(1 - target.rank, target.column)
		if other != null and other != target and not out.has(other):
			out[other] = AREA_COLUMN
	if f.has_area():
		for foe in out.keys():
			var t := twin_of(foe)
			if t != null and t != target and not out.has(t):
				out[t] = out[foe]
		var pair := twin_of(target)
		if pair != null and not out.has(pair):
			out[pair] = AREA_ROW if f.reaches_row() else AREA_COLUMN
	for foe in conductors(f, target):
		if not out.has(foe):
			out[foe] = AREA_CHAIN
	if f.reaches_all:
		for foe in field_foes():
			if foe != target and not out.has(foe):
				out[foe] = AREA_ALL
	return out


## The number a foe in a shape takes in place of the roll: the row's (Spread's or Splash's),
## the column's (Penetrate's or Splash's), Chain's on a conductor, nothing for a foe a reach over
## every foe adds (the Siphon's lure-all, equipment, whose blow is nothing).
static func area_number(f: Face, shape: int) -> int:
	match shape:
		AREA_ROW:
			return f.row_number()
		AREA_COLUMN:
			return f.column_number()
		AREA_CHAIN:
			return f.number_of(Face.Keyword.CHAIN)
	return 0


## What one foe reads for itself in a spend (the blow's order): the hull it is missing, on
## every blow, and on its first blow the stacks a consumer eats on it, a point each
## (per_consumed); flat, after the firer's pipeline, beside its Flak. A debuff's blow stays
## nothing. A foe the spend did not judge (none in practice) is read now.
static func _foe_reads(f: Face, reads: Dictionary, foe: Foe, first: bool) -> int:
	if f.is_debuff():
		return 0
	var r: Array = reads.get(foe, [f.missing_bonus(foe), 0])
	return int(r[0]) + (int(r[1]) * f.per_consumed if first else 0)


## One hit's blow on a foe past its own, before the foe's own reads, statuses and armour: its
## shape's number with `prints` (what the entry prints from its firer), a split's halving of that
## base, through the firer's pipeline with its conditions judged on that foe.
func _area_blow(ms: MechState, f: Face, shape: int, foe: Foe, prints: int, split: int) -> int:
	return int(Effects.attack(ms.unit, f, split_share(area_number(f, shape) + prints, split), 0, foe)["damage"])


## Every twin of the foes in `hit` joins it, the slot reached whole: an area blow's (26 October).
func _with_twins(hit: Array[Foe]) -> void:
	for foe in hit.duplicate():
		var t := twin_of(foe)
		if t != null and not hit.has(t):
			hit.append(t)


## A foe's defend, buff or debuff action, resolved in its turn in place of a blow (the ten
## planned actions of 14 September, built 30 September). Every field is the action's;
## nothing here keys on a foe's id. `Foe.ACTION_EFFECTS` says what each kind may do.
func _foe_acts(f: Foe, t: MechState) -> void:
	var a := f.action
	var effect := str(a.get("effect", ""))
	var value := int(a.get("value", 0))
	if t == null and effect in ["burn", "disable", "silence", "dispel", "swallow"]:
		log.append("%s: %s, and no machine stands to take it" % [f.display_name, str(a.get("name", effect))])
		return
	turn_specials.append({"foe": f, "name": str(a.get("name", "")), "kind": Foe.kind_of(a), "seq": _seq})
	_seq += 1
	if bool(a.get("once", false)):
		f.spent_once.append(str(a.get("id", "")))   # a move used once a fight is spent as it acts
	match effect:
		"brace":
			# Armoured, the machines' status (Ryan, 16 October: an effect and the buff it creates
			# share a name; Braced until 18 October): the move's value in stacks of armour, a
			# point each, flat off every blow, every stack going at once at the foe's next action
			# (its tick), as a foe's armour from a defend always lasted.
			var n := Effects.brace_stacks(value)
			if n > 0:
				Effects.stack(f, Effects.STATUS["braced"], Effects.SKIRMISH, "foe:" + f.content_id, n, Effects.status_decay(Effects.STATUS["braced"]))
			log.append("%s: %s, %s ×%d (armour +%d until its next action)" % [f.display_name, str(a.get("name", "braces")), Effects.STATUS["braced"]["name"], n, n * Effects.braced_armour()])
		"regrow":
			var before := f.hp
			f.hp = mini(f.hp_max, f.hp + value)
			log.append("%s: %s, regrows %d" % [f.display_name, str(a.get("name", "regrows")), f.hp - before])
		"regrow_ally":
			# Foes helping foes (15 October): the most hurt of its own by hull missing, itself
			# included, the first in the order they stand on a tie.
			var hurt: Foe = null
			for other in field_foes():
				if other.alive() and other.hp < other.hp_max and (hurt == null or other.hp_max - other.hp > hurt.hp_max - hurt.hp):
					hurt = other
			if hurt == null:
				log.append("%s: %s, and none of its own is hurt" % [f.display_name, str(a.get("name", "cures"))])
			else:
				var before := hurt.hp
				hurt.hp = mini(hurt.hp_max, hurt.hp + value)
				log.append("%s: %s, %s regrows %d" % [f.display_name, str(a.get("name", "cures")), hurt.display_name, hurt.hp - before])
		"brace_all":
			# Armoured on every foe in the fight through the next round, so it stands through the
			# player's turn and is gone when the enemy acts again: its next action, as the
			# player sees it, which going at each foe's own tick would cut short for the foes
			# acting after it.
			var n := Effects.brace_stacks(value)
			var braced := 0
			for other in field_foes():
				if other.alive() and n > 0:
					Effects.stack(other, Effects.STATUS["braced"], Effects.ROUNDS, "foe:" + f.content_id, n, Effects.DECAY_NONE, round + 1)
					braced += 1
			log.append("%s: %s, %d of its own %s ×%d (armour +%d through the next round)" % [f.display_name, str(a.get("name", "protects")), braced, Effects.STATUS["braced"]["name"], n, n * Effects.braced_armour()])
		"revive_once":
			Effects.stack(f, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:" + f.content_id, 1, Effects.DECAY_NONE)
			log.append("%s: %s (it will return once)" % [f.display_name, str(a.get("name", "readies"))])
		"revive_once_ally":
			# Reraise on an ally (Ryan, 16 October: the promoted Cleric's, cast on the other
			# party members, never itself): Undying on one of its own.
			var ally := _unready_ally(f)
			if ally == null:
				log.append("%s: %s, and none of its own needs readying" % [f.display_name, str(a.get("name", "readies"))])
			else:
				Effects.stack(ally, Effects.STATUS["risen"], Effects.SKIRMISH, "foe:" + f.content_id, 1, Effects.DECAY_NONE)
				log.append("%s: %s, %s will return once" % [f.display_name, str(a.get("name", "readies")), ally.display_name])
		"summon":
			var count := maxi(1, int(a.get("count", 1)))
			var who := str(a.get("foe", ""))
			if foe_factory.is_valid() and not who.is_empty():
				# A summon takes an empty slot of its rank at once, the nearest the summoner's
				# column (Ryan, 26 October), its round over, so it strikes from the next; one with
				# no room is never called (no pool: Ryan, 6 and 7 November).
				var stood := 0
				var named := who   # the foe's own name in the log, never its content id (the audit's thirteenth bug)
				for i in range(count):
					var n = foe_factory.call(who)
					if n is Foe:
						named = n.display_name
						n.pack_id = f.pack_id
						n.joined = true
						if _step_up(n, f.column):
							stood += 1
				log.append("%s: %s, %d %s answer%s the call%s" % [f.display_name, str(a.get("name", "calls")), count, named, "s" if count == 1 else "",
					"" if stood == 0 else (", stepping up" if stood == count else ", %d stepping up" % stood)])
			else:
				log.append("%s: %s, and nothing answers" % [f.display_name, str(a.get("name", "calls"))])
		"merge":
			_merge(f, a)
		"rally":
			# Empowered lands at once on every other foe on the field, at the move's own value
			# in stacks (Ryan, 26 October: "howl is more clear if it gives kindled for the next
			# action, which could be the turn its granted"): one acting after the rallier this turn
			# hits harder now, and every intent showed it from the round's start (incoming_rally).
			# The stacks halve at the round's end like a machine's (Ryan, 4 November: one clock on
			# both sides), so one that has acted carries half to the next round; two rallies add.
			var rallied := 0
			for other in field_foes():
				if other != f and other.alive():
					Effects.stack(other, Effects.STATUS["kindled"], Effects.SKIRMISH, "foe:" + f.content_id, maxi(0, value), Effects.DECAY_HALF)
					rallied += 1
			log.append("%s: %s, %d hit %d harder, halving each round" % [f.display_name, str(a.get("name", "rallies")), rallied, value])
		"drain_rerolls":
			reroll_debt += maxi(0, value)
			log.append("%s: %s, the team loses %d reroll%s next round" % [f.display_name, str(a.get("name", "roars")), value, "" if value == 1 else "s"])
		"golden":
			# The Thunder Ape's Golden Rage (4 November): a mode for the rounds the move says, its
			# blows harder by the move's value and a point of plate; a quarter of its HP lost from
			# here breaks it and it staggers (_break_golden), a Suppress breaks it too (_suppress).
			var rounds := clampi(int(a.get("rounds", 3)), 1, 5)
			Effects.grant_for_rounds(f, Effects.golden(maxi(1, value)), "golden", round + rounds)
			f.golden_mark = f.hp
			log.append("%s: %s, its blows %d harder and a point of armour for %d round%s; %d more damage breaks it" % [f.display_name, str(a.get("name", "goes gold")), maxi(1, value), rounds, "" if rounds == 1 else "s", golden_left(f)])
		"burn":
			# A Ward turns away every rider a foe lays on its machine, a special's as a blow's
			# (Ryan, 25 October: "Should stop all riders, even from non-damaging attacks").
			if Effects.has(t.unit, "ward"):
				log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "stokes")), t.unit.display_name])
			else:
				_fire_on(t, "burning_mech", maxi(1, value), f)
				log.append("%s: %s, %s burning ×%d" % [f.display_name, str(a.get("name", "stokes")), t.unit.display_name, maxi(1, value)])
		"swallow":
			_swallow(f, t, maxi(1, value))
		"disable":
			# The entry the die shows is switched off through the machine's next turn, no blow.
			if Effects.has(t.unit, "ward"):
				log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "hushes")), t.unit.display_name])
			elif t.face_index >= 0:
				Effects.disable_entry(t.unit, t.face_index, "foe:" + f.content_id, round + 1)
				log.append("%s: %s, %s's %s is switched off" % [f.display_name, str(a.get("name", "hushes")), t.unit.display_name, t.die.faces[t.face_index].describe()])
		"cleanse":
			# A foe's cleanse (28 October, the Marsh's lever: "debuffs are hard here"): every mark
			# the team laid off the most-marked of its own, itself included; never Numbed, never
			# Suppressed, never a buff.
			var marked := cleanse_target(f)
			if marked == null:
				log.append("%s: %s, and none of its own carries a mark" % [f.display_name, str(a.get("name", "cleanses"))])
			else:
				var gone := Effects.clear_marks(marked)
				log.append("%s: %s, %s loses %s" % [f.display_name, str(a.get("name", "cleanses")), marked.display_name, ", ".join(gone).to_lower()])
		"barrier":
			# A foe's Barrier (28 October, the Waste's burrow by lean): the next weapon blow it
			# takes deals nothing, its riders landing; a debuff pops nothing; it goes at the end
			# of the player's next turn if nothing pops it.
			Effects.stack(f, Effects.foe_barrier(), Effects.SKIRMISH, "foe:" + f.content_id, 1, Effects.DECAY_TURN_ALL)
			log.append("%s: %s, the next weapon blow on it deals nothing" % [f.display_name, str(a.get("name", "shelters"))])
		"ward_all":
			# A sanctuary (28 October, the Marsh's by lean): a Ward on every foe on the field,
			# itself included, until the end of the player's next turn; no mark the team lays
			# lands, Suppressed excepted, and the damage does.
			var warded := 0
			for other in field_foes():
				if other.alive():
					Effects.stack(other, Effects.foe_ward(), Effects.SKIRMISH, "foe:" + f.content_id, 1, Effects.DECAY_TURN_ALL)
					warded += 1
			log.append("%s: %s, %d of its own warded against the team's marks" % [f.display_name, str(a.get("name", "hallows")), warded])
		"prime":
			# A stoker (28 October, the Peak's by lean): Primed at its value on every other foe on
			# the field at once, as a rally's Empowered lands, each foe's next move spending it.
			var primed := 0
			for other in field_foes():
				if other != f and other.alive():
					Effects.grant(other, Effects.primed_foe(value, "foe:" + f.content_id))
					primed += 1
			log.append("%s: %s, %d primed to burn ×%d" % [f.display_name, str(a.get("name", "stokes")), primed, maxi(1, value)])
		"regenerate":
			# Regenerating on itself (28 October, the Marsh's by lean): its value at each of its
			# next three actions, after its ticks.
			var m := Effects.regenerating(maxi(1, value))
			m.source = "foe:" + f.content_id
			Effects.grant(f, m)
			log.append("%s: %s, regrowing %d at each of its next three actions" % [f.display_name, str(a.get("name", "knits")), maxi(1, value)])
		"silence":
			# A caster's silence (17 October; keywords alone, 28 October): no blow, the machine
			# Silenced through its next round.
			if Effects.has(t.unit, "ward"):
				log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "silences")), t.unit.display_name])
			else:
				_silence(t, f)
		"dispel":
			# A hero's or a boss's Purge N (17 October; numbered 2 November): no blow, every buff N
			# stacks down, the stores kept.
			if Effects.has(t.unit, "ward"):
				log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "purges")), t.unit.display_name])
			else:
				_purge(t, f, maxi(1, value))
		"scorch_all":
			var names: Array[String] = []
			for ms in targetable_mechs():
				if Effects.has(ms.unit, "ward"):
					log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "erupts")), ms.unit.display_name])
					continue
				_fire_on(ms, "scorched", maxi(1, value), f)
				names.append(ms.unit.display_name)
			log.append("%s: %s, %s scorched ×%d" % [f.display_name, str(a.get("name", "erupts")), ", ".join(names) if not names.is_empty() else "nobody", maxi(1, value)])
		"corrupt_all":
			var hit_names: Array[String] = []
			for ms in targetable_mechs():
				if Effects.has(ms.unit, "ward"):
					log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "unravels")), ms.unit.display_name])
					continue
				if ms.face_index >= 0:
					Effects.corrupt_entry(ms.unit, ms.face_index, "foe:" + f.content_id, maxi(1, value))
					hit_names.append(ms.unit.display_name)
			log.append("%s: %s, the showing component of %s is corrupted" % [f.display_name, str(a.get("name", "unravels")), ", ".join(hit_names) if not hit_names.is_empty() else "nobody"])
		_:
			log.append("%s: %s" % [f.display_name, str(a.get("name", "acts"))])


## The one a Reraise on an ally readies: a live foe on the field other than the caster, not
## readied already and able to get back up (one gone whole cannot); a party member before the
## rest of its own, the heaviest hitter first (Foe.threat), then the order they stand. Null
## when there is none.
func _unready_ally(caster: Foe) -> Foe:
	var best: Foe = null
	for o in field_foes():
		if o == caster or not o.alive() or o.stays_down or Effects.has(o, "risen"):
			continue
		if best == null or (o.hero and not best.hero) or (o.hero == best.hero and o.threat() > best.threat()):
			best = o
	return best


## A machine's unspent die rolled again in place (the Reheat Uplink's roll, 30 October): never
## onto the entry showing, a stepping die stepping, as a team reroll does; the round preview's
## copy keeps its entry, a roll never promised.
func _roll_again(ms: MechState) -> void:
	if previewing:
		return
	_reroll_die(ms)


## The machine acts again through Rapid's path: the die rolls for free, never onto the entry
## just spent (a copy of it may come up), a spin over every entry, a stepping die stepping; a folded
## die among its live entries, so a Changeover's roll lands on the battery it raised.
func _act_again(ms: MechState, f: Face) -> void:
	if previewing:
		ms.assigned = false   # it acts again; the copy's die keeps its entry, a roll never promised
		return
	_rolled()
	var live := Effects.live_entries(ms.unit, ms.die)
	if f.spins:
		ms.face_index = ms.die.roll_among(rng, live)
	elif Effects.steps_die(ms.unit):
		ms.face_index = _step(ms)
	else:
		ms.face_index = ms.die.reroll_among(rng, live, ms.face_index)
	ms.assigned = false


# ---------------------------------------------------------------- the Musk Ox's

## What this gun costs its machine in ammo now (the Musk Ox's Desublimation Forge, Ryan's go of
## 21 October): the whole magazine for the salvo, at least one; the forge's price for any other
## weapon; nothing on a machine that forges nothing, or for anything but a weapon.
func ammo_price_of(ms: MechState, f: Face) -> int:
	if ms == null or ms.ammo_max <= 0 or f == null or not f.is_attack():
		return 0
	if f.spends_magazine:
		return maxi(1, ms.ammo)
	return Effects.ammo_price(ms.unit, f)


## Can the magazine pay for this entry (a dry gun cannot be spent)?
func can_fire(ms: MechState, f: Face) -> bool:
	var price := ammo_price_of(ms, f)
	return price <= 0 or ms.ammo >= price


## The first entry with a condition on its play (Ryan, 26 October, the shield cost: "if you don't
## have the shield, the face cannot be played"): true while the machine's shield, overshield
## included, is short of the entry's shield cost. Every target list reads it, so the die has
## nowhere to land, the screen's drag finds no target, the bot passes it over and END TURN
## pulses; the die shows the cost struck through (Face.short, shown_face). The pattern for any
## conditional entry to come.
func shield_short(ms: MechState, f: Face) -> bool:
	return f != null and f.shield_cost > 0 and ms.unit.shield < f.shield_cost


## The second: an entry that spends a count of its machine's for what it grants (Face.spends, the
## Soul Siphon's Souls) cannot be played while the machine holds none of it.
func spend_short(ms: MechState, f: Face) -> bool:
	return f != null and not f.spends.is_empty() and Effects.stacks_of(ms.unit, f.spends) <= 0


## Whether its machine cannot pay an entry's price now, whichever it prints: every target list
## and the die's shown entry read this, so each conditional entry behaves as the first did.
func cannot_pay(ms: MechState, f: Face) -> bool:
	return shield_short(ms, f) or spend_short(ms, f)


## What an entry that spends a count would take from its machine now: what it holds, up to the
## entry's most; its most when the machine holds none (the die prints that, struck).
func spend_take(ms: MechState, f: Face) -> int:
	if f == null or f.spends.is_empty():
		return 0
	var held := Effects.stacks_of(ms.unit, f.spends)
	return mini(held, f.spends_up_to) if held > 0 else f.spends_up_to


## Ammo into the magazine, up to its size.
func _reload(ms: MechState, n: int, why: String) -> void:
	if ms.ammo_max <= 0 or n <= 0:
		return
	var add := mini(n, ms.ammo_max - ms.ammo)
	if add <= 0:
		return
	ms.ammo += add
	if not why.is_empty():
		log.append("%s reloads %d from %s: %d of %d" % [ms.unit.display_name, add, why, ms.ammo, ms.ammo_max])


## What a piece spent on a machine does beside its kind: a printed heat lands on its spender (the Musk Ox's quick
## reload, Rapid with heat its limiter); and a forging machine reloads, what the entry says (the
## quick reload, which the Forge counts as no vent), else the Forge's own for a vent or a shield
## it spends on itself.
func _machine_spend_after(ms: MechState, f: Face, target) -> void:
	if f.heat > 0 and ms.alive():
		_add_heat(ms, f.heat, ms.face_index)
	if ms.ammo_max <= 0:
		return
	if f.reloads_ammo > 0:
		_reload(ms, f.reloads_ammo, "a quick reload")
		return
	var on_self: bool = not f.reaches_all and (not (target is MechState) or target == ms)
	var rule := Effects.forge_rule(ms.unit)
	if on_self:
		# A vent reloads its number, a shield its own; an entry both at once reloads once, the
		# greater (Ryan, 8 November: "Once, take the greater number").
		var by_vent := int(rule.get("vent", 0)) if f.cools_machine() else 0
		var by_shield := int(rule.get("shield", 0)) if f.shields_machine() else 0
		if by_vent > 0 or by_shield > 0:
			_reload(ms, maxi(by_vent, by_shield), "the vent" if by_vent >= by_shield else "the shield")


## The Nob's rage (3 November; its own from the fight's start since 8 November): every shield,
## vent or equipment entry the team spends stacks Enraged on each live foe on the field that
## rages, by its rage, a point of attack a stack for the rest of the fight
## (Effects.foe_attack_bonus reads it into every blow and every intent); a weapon or a blank feeds
## nothing. The feed is the round's own grant, stacked, so a Purge clears what has gathered and
## the rage goes on.
func _feed_rage(ms: MechState, f: Face) -> void:
	for foe in field_foes():
		if foe.alive() and foe.rage > 0:
			Effects.stack(foe, Effects.STATUS["enraged"], Effects.SKIRMISH, "foe:" + foe.content_id, foe.rage, Effects.DECAY_NONE)
			log.append("%s: %s feeds %s's rage: its blows hit %d harder" % [ms.unit.display_name, f.describe(), foe.display_name, Effects.foe_attack_bonus(foe)])


## Every raging foe's feed on one more non-weapon spend, for the bot: the rage of each live
## foe on the field, summed.
func rage_on_field() -> int:
	var n := 0
	for foe in field_foes():
		if foe.alive():
			n += foe.rage
	return n


## The rank a Sweep fires along (Ryan, 2 November: "target a rank, not a unit"; 3 November: "You
## pick a rank and that's the rank it hits"): the rank of the foe the entry was dropped on, a
## massive foe's the front. The drop picks the rank and nothing else: the shots start at its
## first column.
func sweep_rank_of(target: Foe) -> int:
	return 0 if target == null or target.is_massive() or target.rank < 0 else target.rank


## The spots a Sweep's shots walk on a rank (Ryan, 7 November: "Fires a shot at each column, left
## to right, repeating until it runs out of shots"; 8 November, of a Gel's pair: "I would use up
## a shot for each gel half. It functionally adds another column ... it queues up the spots to
## target at the start of the spend, targeting each full column at least once"): each column in
## turn as [its foe or null, the column], an empty column a spot of its own whose shot is wasted,
## a pair's two halves a spot each, and a massive foe, filling both slots of its column, the spot
## of either rank's column. Read once as the spend begins: a foe a shot fells keeps its spot, its
## corpse taking the shots, and a half that fell before the spend leaves none.
func sweep_spots(rank: int) -> Array:
	var out: Array = []
	for col in range(columns):
		var standing := slot_foes(rank, col)
		if standing.is_empty():
			out.append([null, col])
		for foe in standing:
			out.append([foe, col])
	return out


## The shots each foe takes of a Sweep's `shots` dropped on `target`'s rank (the bot's read of the
## rank as it stands): the spots in turn, repeating (sweep_spots), an empty column's wasted.
func sweep_shots(target: Foe, shots: int) -> Dictionary:
	var out := {}
	var spots := sweep_spots(sweep_rank_of(target))
	for s in range(maxi(1, shots)):
		var foe = spots[s % spots.size()][0]
		if foe != null:
			out[foe] = int(out.get(foe, 0)) + 1
	return out


## The Unrestricted Expenditure (the Musk Ox's, Ryan's go of 21 October): every ammo in the
## magazine a shot of one Sweep (Ryan, 7 November: every sweep on the one path) along the rank
## it was dropped on, with the entry's keywords (Splash on every shot), the magazine its price
## (Pays.AMMO: a foe's debuff alone heats it); a split doubles the shots as it does any sweep's.
## One spend, so one Mine on the foe it was dropped on for a machine that leaves them (_lay_mine).
func _salvo(mech_index: int, ms: MechState, f: Face, target: Foe = null) -> void:
	var n := ms.ammo
	ms.ammo = 0
	if target == null:
		var standing := field_foes()
		if standing.is_empty():
			return
		target = standing[0]
	var shots := n * maxi(1, f.split)
	log.append("%s empties the magazine: %d shot%s along the %s" % [ms.unit.display_name, shots, "" if shots == 1 else "s", "front" if sweep_rank_of(target) == 0 else "back"])
	if shots <= 0:
		return
	var salvo := f.duplicate_face()
	salvo.reach = Face.Reach.SWEEP
	salvo.strikes = shots
	var pays: int = Pays.AMMO if ammo_price_of(ms, salvo) > 0 else Pays.HEAT   # the magazine, emptied above, its price
	var h := _hit(ms, salvo, target)
	_lay_mine(ms, target, h.mine)
	_finish_hits(mech_index, ms, salvo, target, h, pays)


# ---------------------------------------------------------------- the Swallowtail's

## Phased (Ryan, 20 October): granted only to a machine yet to act, its action the price, so its
## die stands down for the round; a foe whose pick it was picks again, so the intent lines move.
func _phase(w: MechState) -> void:
	w.assigned = true
	for foe in field_foes():
		if foe.alive() and foe.target == w:
			foe.target = _repick(foe)
	log.append("%s is Phased: out of the fight until the round's end" % w.unit.display_name)


# ---------------------------------------------------------------- a swallow and a steal (30 October)

## The machines a swallow may take: alive and in the fight. A swallow needs two of them, so it
## never takes the last machine able to act (Floraison's, 30 October).
func swallowable() -> Array[MechState]:
	return targetable_mechs()


## The foes a merge would take in now (the King Gel's, 30 October): every other live foe on the
## field of the kinds its move names.
func mergeable(f: Foe, a: Dictionary) -> Array[Foe]:
	var kinds := Foe.kinds_named(a)
	var out: Array[Foe] = []
	for o in field_foes():
		if o != f and o.alive() and kinds.has(o.content_id):
			out.append(o)
	return out


## A merge (the King Gel's, 30 October): every foe of the move's kinds on the field is taken into
## the merger, leaving its slot with no fall (no last act, no split, no kill of the team's, a twin
## keeping the slot alone); the merger regrows the HP they had left and its next move hits the
## move's value harder for each, an Empowered of its own, so thinning them first is the answer.
func _merge(f: Foe, a: Dictionary) -> void:
	var regrown := 0
	var taken := 0
	for o in mergeable(f, a):
		regrown += o.hp
		# Its Mine goes in with it (Ryan's lean of 9 November: a foe taken in never falls), joining
		# the merger's, so the merger's fall blows them all.
		var carried := mine_of(o)
		if not carried.is_empty():
			Effects.remove(o, "mine")
			_add_mine(f, int(carried["damage"]), carried["riders"])
			log.append("%s takes in the Mine on %s" % [f.display_name, o.display_name])
		_lift_out(o)
		taken += 1
	var before := f.hp
	f.hp = mini(f.hp_max, f.hp + regrown)
	var lift := maxi(1, int(a.get("value", 1))) * taken
	if lift > 0:
		_lift_after[f] = int(_lift_after.get(f, 0)) + lift   # granted after this move spends what it carried
	log.append("%s: %s, %d taken in, regrows %d, its next move %d harder" % [f.display_name, str(a.get("name", "merges")), taken, f.hp - before, lift])
	_refresh_kin()


## A foe leaves the field without falling (taken into another, 30 October): its slot clears, a
## twin keeping it alone, a massive foe out of both ranks; it stands nowhere after and acts no more.
func _lift_out(o: Foe) -> void:
	if o.rank >= 0 and o.column >= 0 and o.column < columns:
		var at := Vector2i(o.rank, o.column)
		var c := _slot_contents(at)
		if c[0] == o:
			_set_contents(at, [c[1], null])
		elif c[1] == o:
			_set_contents(at, [c[0], null])
		for r in [0, 1]:
			if foe_at(r, o.column) == o:
				_set_slot(Vector2i(r, o.column), null)
	o.rank = -1
	o.hp = 0
	o.stays_down = true
	o.target = null


## The source a swallow's status carries: the swallower by its pack and type, so its fall finds
## the machine it holds after a save, with no references kept.
static func swallow_source(f: Foe) -> String:
	return "swallow:%d:%s" % [f.pack_id, f.content_id]


## A foe's swallow on its machine (Floraison's, 30 October, the slate's signature: "swallows a
## machine, out of the fight for a few rounds"): Swallowed for `rounds` rounds, out of the fight
## as a Phased machine is, cannot act, take damage or be targeted, until its rounds run out or
## its swallower falls. A Ward turns it away; it never takes the last machine able to act.
func _swallow(f: Foe, t: MechState, rounds: int) -> void:
	var what := str(f.action.get("name", "swallows"))
	if Effects.has(t.unit, "ward"):
		log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, what, t.unit.display_name])
		return
	if is_out(t) or swallowable().size() < 2:
		log.append("%s: %s, and finds nothing it may take" % [f.display_name, what])
		return
	# A quarter of its HP lost from here lets the machine go (31 October); a second machine
	# taken while it holds one joins the first's count, so the release its chip promised never
	# moves back (the review of 2 November).
	if swallowed_by(f) == null:
		f.swallow_mark = f.hp
	Effects.grant_for_rounds(t.unit, Effects.STATUS["swallowed"], swallow_source(f), round + rounds)
	t.assigned = true
	for foe in field_foes():
		if foe.alive() and foe.target == t:
			foe.target = _repick(foe)
	log.append("%s: %s, %s swallowed: out of the fight for %d round%s, or until %s falls" % [f.display_name, what, t.unit.display_name, rounds, "" if rounds == 1 else "s", f.display_name])


## The HP a swallower lets its machine go at: a quarter of its HP below its HP as it swallowed
## (Ryan, 31 October, agreeing Claude's lean: a damage threshold, Clair Obscur's stagger in its
## smallest form; a quarter is a round of the team's focus, a third as long as waiting).
static func swallow_release_at(f: Foe) -> int:
	return f.swallow_mark - ceili(f.hp_max / 4.0)


## The damage still to deal a swallower before it lets its machine go: its chip's number, never
## more than it has left (a swallower already under a quarter lets go only as it falls).
static func swallow_left(f: Foe) -> int:
	return clampi(f.hp - swallow_release_at(f), 0, maxi(0, f.hp))


## The machine a foe holds swallowed, or null.
func swallowed_by(f: Foe) -> MechState:
	var src := swallow_source(f)
	for ms in mechs:
		for m in Effects.live(ms.unit):
			if m.id == "swallowed" and m.source == src:
				return ms
	return null


## The HP a gold foe's rage breaks at: a quarter of its HP below its HP as it went gold (the
## swallow's release, the same stagger in its smallest form; 4 November).
static func golden_break_at(f: Foe) -> int:
	return f.golden_mark - ceili(f.hp_max / 4.0)


## The damage still to deal a gold foe before its rage breaks: its chip's number, never more
## than it has left.
static func golden_left(f: Foe) -> int:
	return clampi(f.hp - golden_break_at(f), 0, maxi(0, f.hp))


## The rounds a gold foe's rage has left, this one counted; 0 while it is calm.
func golden_rounds_left(f: Foe) -> int:
	for m in Effects.live(f):
		if m.id == "golden":
			return maxi(1, m.expires_round - round + 1) if m.expires_round >= 0 else 1
	return 0


## A gold foe that has lost a quarter of its HP since it went gold staggers (4 November, Ryan's
## read of Rajang: the rage is "broken by a bold player with great timing"): the rage ends and
## it loses its next action, the bold play's pay, where the swallow's release loses none (the
## exit if it reads as a free stun). One whose rage ran out on its clock, or was purged, is calm.
func _break_golden() -> void:
	for f in field_foes():
		if f.golden_mark < 0 or not f.alive():
			continue
		if not Effects.has(f, "golden"):
			f.golden_mark = -1
		elif f.hp <= golden_break_at(f):
			_stagger(f, "reels")


## The rage broken: the gold goes and the foe loses its next action, never Numbed (a stagger is
## the mode's own, no stun piece's), and one already suppressed loses nothing more.
func _staggered(f: Foe) -> bool:
	for m in Effects.live(f):
		if m.id == "suppressed" and m.source == "stagger":
			return true
	return false


func _stagger(f: Foe, why: String) -> void:
	Effects.remove(f, "golden")
	f.golden_mark = -1
	var next := _acted.has(f) or f.fresh
	if not _suppressed_through(f, round + 1 if next else round):
		Effects.grant_for_rounds(f, Effects.STATUS["suppressed"], "stagger", round + 1 if next else round)
	log.append("%s %s: its golden rage breaks, and it staggers out of its next action" % [f.display_name, why])


## A swallower that has lost a quarter of its HP since it swallowed lets its machine go at
## once, and loses nothing else (a lost action on top would be a stun, the stun row's care);
## a swallower whose machine came back on its own clock holds nothing (31 October).
func _release_staggered() -> void:
	for f in field_foes():
		if f.swallow_mark < 0 or not f.alive():
			continue
		if swallowed_by(f) == null:
			f.swallow_mark = -1
		elif f.hp <= swallow_release_at(f):
			f.swallow_mark = -1
			_release_swallowed(f, "reels")


## A swallower down, or reeling from a quarter of its HP lost, lets go of what it holds, at
## once (30 and 31 October).
func _release_swallowed(f: Foe, why: String = "falls") -> void:
	var src := swallow_source(f)
	for ms in mechs:
		var keep: Array = []
		var freed := false
		for m in ms.unit.modifiers:
			if m.id == "swallowed" and m.source == src:
				freed = true
				continue
			keep.append(m)
		if freed:
			ms.unit.modifiers = keep
			if state == State.ASSIGN:
				ms.assigned = false   # let go in the player's turn, it acts this round
			log.append("%s %s, and lets %s go" % [f.display_name, why, ms.unit.display_name])


## A steal (Gilgamesh's, 30 October, the slate's signature: "takes the weapon a machine shows and
## fights with it; now and then the piece it took is a fake"): the entry the machine's die shows
## is switched off through its next turn, as a disable, and the foe holds it: its borrowed swing
## lands that weapon's number (a blow a strike), and anything else it
## took, a shield, a vent, equipment or a blank, is a fake, for 1.
func _steal(f: Foe, t: MechState) -> void:
	var face: Face = t.die.faces[t.face_index]
	Effects.disable_entry(t.unit, t.face_index, "foe:" + f.content_id, round + 1)
	var weapon := face.is_weapon()
	f.held = {"name": face.describe(), "power": stolen_number(face), "fake": not weapon}
	log.append("%s takes %s's %s%s" % [f.display_name, t.unit.display_name, face.describe(), "" if weapon else ", a fake"])


## The number a stolen entry swings for: a weapon's printed blow, anything else 1, the fake.
static func stolen_number(face: Face) -> int:
	if face == null or not face.is_weapon():
		return 1
	return maxi(1, face.power)


## A die rolled, any machine's (the Swallowtail's Muster, Ryan's go of 21 October): every machine
## that musters gains a sliver.
func _rolled() -> void:
	for ms in live_mechs():
		_muster(ms, 1)


## Points on a machine's Muster, up to its cap (a store, which no Silence touches); a charge
## filled is told.
func _muster(ms: MechState, points: int) -> void:
	var rule := Effects.muster_rule(ms.unit)
	if rule.is_empty() or points <= 0 or not ms.alive():
		return
	var per := maxi(1, int(rule.get("value", 30)))
	var cap := maxi(1, int(rule.get("cap", 3))) * per
	var have := 0
	for m in ms.unit.modifiers:
		if m.id == "muster":
			have += m.stacks
	var add := mini(points, cap - have)
	if add <= 0:
		return
	Effects.stack(ms.unit, Effects.STATUS["muster"], Effects.SKIRMISH, "muster", add, Effects.DECAY_NONE)
	if (have + add) / per > have / per:
		log.append("%s: a muster ready (%d)" % [ms.unit.display_name, (have + add) / per])


# ---------------------------------------------------------------- mines

## A Mine's riders (Ryan, 9 November: "mines combine into one large hit with all keywords
## combined"; "the mine should take the entire result of the spend, then apply it"): {stacks,
## status id -> the stacks of it the spends fired at the foe; dispel, its Purge; chain, its arc
## number; keywords, the flags once each}. The numbered ones add up across every spend that fed it.
const MINE_NUMBERED := ["dispel", "chain"]
## The keywords a Mine carries once each: a stun or a mark it lays (Suppress, a web, Shock,
## Expose), Breach on its blow, and Disrupt. Ryan, 9 November: "Area modifiers, targeting rules
## (sweep), and hit counts are ignored. Anything that ties it back to the firer is ignored, like
## lure": Spread, Penetrate, Splash and Spillover are area, the Swap a target, Rapid the spend's
## own, Lure the firer's; the hits count in the stacks they fired, never in the Mine's damage.
const MINE_FLAGS := [Face.Keyword.SHOCK, Face.Keyword.SUPPRESS, Face.Keyword.WEB, Face.Keyword.EXPOSE, Face.Keyword.BREACH, Face.Keyword.DISRUPT]


## The Mine a foe carries (the Lammergeier's Reverberant Payload, Ryan, 9 November): {damage, the
## status's stacks; riders, as mine_riders_merged gives them}. Empty when it carries none.
static func mine_of(foe: Foe) -> Dictionary:
	var dmg := Effects.stacks_of(foe, "mine")
	if dmg <= 0:
		return {}
	var riders := {}
	for m in foe.modifiers:
		if m.id == "mine" and not m.effects.is_empty() and m.effects[0] is Dictionary:
			riders = mine_riders_merged(riders, m.effects[0])
	return {"damage": dmg, "riders": mine_riders_merged(riders, {})}


## An entry's riders as a Mine would carry them, read off the entry as printed, its every strike's
## stacks and numbers counted: the bot's estimate before the spend. A spend's own Mine takes what
## its hits fired at the target (Hits.mine), deepened, doubled and gated as they were.
static func mine_riders(f: Face) -> Dictionary:
	var hits := maxi(1, f.strikes)
	var stacks := {}
	for k in [Face.Keyword.BURN, Face.Keyword.CRYO, Face.Keyword.FLAK]:
		if f.has(k):
			var n := maxi(0, int(f.get(str(Face.NUMBER_FIELDS[k])))) * hits
			if n > 0:
				stacks[str(Face.KEYWORD_STATUS[k])] = n
	var kws: Array = []
	for k in MINE_FLAGS:
		if f.has(k):
			kws.append(str(Face.KEYWORD_NAMES[k]))
	return {"stacks": stacks, "dispel": maxi(1, f.dispel) * hits if f.has(Face.Keyword.DISPEL) else 0,
		"chain": maxi(0, f.chain) * hits if f.has(Face.Keyword.CHAIN) and not f.is_debuff() else 0, "keywords": kws}


## Two Mines' riders as one: each status's stacks and the numbered ones added, the flags once each,
## in a fixed order. A fresh dictionary, neither one changed, since a preview's copy shares its
## fight's.
static func mine_riders_merged(a: Dictionary, b: Dictionary) -> Dictionary:
	var stacks := {}
	for src in [a.get("stacks", {}), b.get("stacks", {})]:
		if src is Dictionary:
			for sid in (src as Dictionary).keys():
				var n := int(src[sid])
				if n > 0:
					stacks[str(sid)] = int(stacks.get(str(sid), 0)) + n
	var out := {"stacks": stacks}
	for key in MINE_NUMBERED:
		out[key] = int(a.get(key, 0)) + int(b.get(key, 0))
	var kws: Array = []
	for k in MINE_FLAGS:
		var name := str(Face.KEYWORD_NAMES[k])
		if Array(a.get("keywords", [])).has(name) or Array(b.get("keywords", [])).has(name):
			kws.append(name)
	out["keywords"] = kws
	return out


## A Mine's words, for the log and the chip's readout: its damage, then its riders, each stack by
## the keyword that lays it where one does ("Mine 6: Burn 4, Flak 3, Vitriol 2, Shock, Breach").
static func mine_text(mine: Dictionary) -> String:
	var bits: Array[String] = []
	var r: Dictionary = mine.get("riders", {})
	var by_status := {}
	for k in Face.KEYWORD_STATUS.keys():
		by_status[str(Face.KEYWORD_STATUS[k])] = k
	var stacks: Dictionary = r.get("stacks", {})
	var ids: Array = stacks.keys()
	ids.sort()
	for sid in ids:
		var n := int(stacks[sid])
		if n <= 0:
			continue
		var word := Face.keyword_label(int(by_status[sid])).capitalize() if by_status.has(sid) else str(Effects.STATUS.get(sid, {}).get("name", sid))
		bits.append("%s %d" % [word, n])
	for key in MINE_NUMBERED:
		var n := int(r.get(key, 0))
		if n > 0:
			bits.append("%s %d" % [Face.keyword_label(Face.keyword_from_name(key)).capitalize(), n])
	for name in r.get("keywords", []):
		bits.append(Face.keyword_label(Face.keyword_from_name(str(name))).capitalize())
	var head := "Mine %d" % int(mine.get("damage", 0))
	return head if bits.is_empty() else "%s: %s" % [head, ", ".join(bits)]


## The Mine a spend leaves on its target (the Reverberant Payload, Ryan, 9 November: "Enemies
## targeted by the lammergeier's weapons and equipment get a mine on hit"; "One mine per spend";
## "the mine is laid as a rider, so ... applied before the death check"): the machine's flat damage
## and the spend's riders join the Mine the foe carries, one Mine a foe, a Sweep's or a salvo's on
## the foe the die was dropped on. Its riders are what the spend's hits fired at the target
## (`riders`, Hits.mine: "the mine should take the entire result of the spend, then apply it",
## Ryan, 9 November), every hit's stacks as its machine laid them and a gated keyword where its
## gate held; its damage stays flat. A Ward turns it away.
func _lay_mine(ms: MechState, target: Foe, riders: Dictionary) -> void:
	var n := Effects.mine_damage(ms.unit)
	if n <= 0 or target == null or target.rank < 0:
		return
	if Effects.turns_mark(target, "mine"):
		log.append("%s's Ward turns %s's Mine away" % [target.display_name, ms.unit.display_name])
		return
	_add_mine(target, n, mine_riders_merged(riders, {}))
	mine_tally["laid"] += 1
	log.append("%s leaves a Mine on %s: %s" % [ms.unit.display_name, target.display_name, mine_text(mine_of(target))])
	_foe_gained_status(target, "mine")   # a status the team put on the foe: the Paradox counts it


## `n` damage and `riders` joining the Mine a foe carries, or its first. A Ward turns it away.
func _add_mine(foe: Foe, n: int, riders: Dictionary) -> void:
	var had := mine_of(foe)
	var m := Effects.stack(foe, Effects.STATUS["mine"], Effects.SKIRMISH, "mine", maxi(0, n), Effects.DECAY_NONE)
	if m == null:
		return
	m.effects = [mine_riders_merged(had.get("riders", {}), riders)]   # a fresh array: the preview's copy shares the fight's


## The live foes a Mine's blast at a slot meets (Ryan, 9 November: "On death, the mine explodes,
## dealing its damage and keywords in an area, I would probably go for Splash as the shape to
## start"): the slot's own (the foe the drone detonates, or a fallen half's twin), the foes beside it
## in its rank and the other rank of its column, a twin slot's pair both; a massive foe's blast its
## rank's neighbours alone, its column being its own.
func mine_reach(rank: int, col: int, massive: bool) -> Array[Foe]:
	var out: Array[Foe] = []
	var at: Array[Vector2i] = [Vector2i(rank, col)]
	var row := 0 if massive else rank
	for c in [col - 1, col + 1]:
		if c >= 0 and c < columns:
			at.append(Vector2i(row, c))
	if not massive:
		at.append(Vector2i(1 - rank, col))
	for slot in at:
		for foe in slot_foes(slot.x, slot.y):
			if foe.alive() and not out.has(foe):
				out.append(foe)
	return out


## A Mine blowing at a slot (Ryan, 9 November): one plain blow of its damage on every foe its reach
## meets (mine_reach), each through its own reads (its Flak, a Barrier, what it takes; aimed at
## nobody, so a Shock neither doubles it nor is spent) and its armour, none under Breach, and
## Chain's number on every other Shocked foe on the field; then its riders on each foe it met,
## felled or not, as a hit's land: every status's stacks it carries (Burning, Cryo, Flak, a
## passive's Vitriol), Purge, Suppress and a web, then Shock and Expose, and Disrupt in the
## player's turn alone, the foes' moves being under way in theirs.
## Nothing ties it to the machine that laid it: no modifier, no deepening, no Cryo cashed. Its
## blows are the "mine" kind for the screen, a beat after what the spend has landed. `where` names
## the foe it blew on.
func _blow_mine(mine: Dictionary, rank: int, col: int, massive: bool, where: String) -> void:
	var dmg := int(mine.get("damage", 0))
	var r: Dictionary = mine.get("riders", {})
	var kws: Array = r.get("keywords", [])
	var met := mine_reach(rank, col, massive)
	var arcs: Array[Foe] = []
	var chain := int(r.get("chain", 0))
	if chain > 0:
		for foe in shocked_foes(null):
			if not met.has(foe):
				arcs.append(foe)
	mine_tally["blasts"] += 1
	log.append("the Mine on %s blows: %s" % [where, mine_text(mine)])
	var beat := _next_beat()
	var all: Array[Foe] = []
	all.append_array(met)
	all.append_array(arcs)
	for foe in all:
		var blow := chain if arcs.has(foe) else dmg
		var hp_before := foe.hp
		var taken := Effects.damage_taken(foe, blow, null, true, false)
		if _barrier_eats(foe, true):
			taken = 0   # its riders land all the same
		taken = maxi(0, taken - (0 if kws.has("breach") else foe.armour_total()))
		foe.hp -= taken
		_note_blow(foe, beat, taken, "mine")
		mine_tally["damage"] += clampi(taken, 0, maxi(0, hp_before))
		log.append("the Mine %s %s for %d" % ["arcs to" if arcs.has(foe) else "hits", foe.display_name, taken])
	var gained := {}
	var turned := {}
	var webbed: Array[Foe] = []
	var stacks: Dictionary = r.get("stacks", {})
	var ids: Array = stacks.keys()
	ids.sort()
	for foe in all:
		for sid in ids:
			if Effects.STATUS.has(str(sid)):
				_land_rider(foe, str(sid), int(stacks[sid]), gained, turned)
		if int(r.get("dispel", 0)) > 0:
			_purge_foe("the Mine", foe, int(r["dispel"]), turned)
		if kws.has("suppress") and _suppress(foe, turned):
			_note_status(gained, foe, "suppressed")
		if kws.has("web"):
			_land_web(foe, gained, turned, webbed)
	for foe in webbed:
		var caught := web_catch(foe)
		log.append("the Mine webs %s: it bursts after its action%s" % [foe.display_name, "" if caught == null else ", on it and %s" % caught.display_name])
	for foe in all:
		if kws.has("shock") and not Effects.has(foe, "shocked"):
			_mine_mark(foe, "shocked", gained, turned)
		if kws.has("expose"):
			_mine_mark(foe, "exposure", gained, turned)
	if kws.has("disrupt") and not _enemy_acting:
		_disrupt(all)
	_tell_turned(turned)
	for foe in gained.keys():
		for status_id in gained[foe]:
			_foe_gained_status(foe, status_id)


## A mark a Mine's blast lays after its blow, Shocked or Exposed (through the next round, renewing),
## or noted turned away by a Ward.
func _mine_mark(foe: Foe, sid: String, gained: Dictionary, turned: Dictionary) -> void:
	if not Effects.turns_mark(foe, sid):
		if sid == "exposure":
			Effects.grant_for_rounds(foe, Effects.STATUS["exposure"], "mech", round + 1)
		else:
			Effects.stack(foe, Effects.STATUS[sid], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	_note_status(gained, foe, sid, turned)


## The beat after every blow the spend under way has landed, for a blast to land on its own.
func _next_beat() -> int:
	var beat := 0
	for b in spend_blows:
		beat = maxi(beat, int(b["strike"]) + 1)
	return beat


## The Lorentz Contractor (the Lammergeier's, Ryan, 9 November: "moves all mines to a single target,
## and Exposes that target"): in the rider phase, every Mine the field's other live foes carry joins
## the target's, their damage added and their riders as one, after the spend's own Mine joined it;
## the Expose is its keyword, so the Mine it gathers carries Expose too ("The Expose rider will
## effectively create an AoE expose mine, which we can try and see if it's dangerous"). A Ward on
## the target turns the gather away and the Mines stay where they were.
func _gather_mines(ms: MechState, target: Foe) -> void:
	var from: Array[Foe] = []
	for foe in field_foes():
		if foe != target and foe.alive() and not mine_of(foe).is_empty():
			from.append(foe)
	if from.is_empty():
		log.append("%s gathers, and no Mine waits elsewhere" % ms.unit.display_name)
		return
	if Effects.turns_mark(target, "mine"):
		log.append("%s's Ward turns the gathered Mines away" % target.display_name)
		return
	var total := 0
	var riders := {}
	for foe in from:
		var m := mine_of(foe)
		total += int(m["damage"])
		riders = mine_riders_merged(riders, m["riders"])
		Effects.remove(foe, "mine")
	_add_mine(target, total, riders)
	mine_tally["gathered"] += from.size()
	log.append("%s gathers %d Mine%s onto %s: %s" % [ms.unit.display_name, from.size(), "" if from.size() == 1 else "s", target.display_name, mine_text(mine_of(target))])


## The Syrinx Drone (the Lammergeier's, Ryan, 9 November: "Deals a small amount of damage and
## detonates a foe's combined mine immediately ... The small chip damage makes it add a stack first.
## Try without a cooldown first"): in the rider phase, after the spend's own Mine joined the
## target's, the target's Mine blows now on the target and every foe round it (_blow_mine) and is
## spent, so a target the drone fells blows nothing more at the death check.
func _detonate(ms: MechState, target: Foe) -> void:
	var mine := mine_of(target)
	if mine.is_empty():
		log.append("%s's drone finds no Mine on %s" % [ms.unit.display_name, target.display_name])
		return
	Effects.remove(target, "mine")
	mine_tally["detonated"] += 1
	log.append("%s detonates the Mine on %s" % [ms.unit.display_name, target.display_name])
	_blow_mine(mine, 0 if target.is_massive() else target.rank, target.column, target.is_massive(), target.display_name)


## The rounds an entry goes dark once this machine spends it, this one included: its own
## printed cooldown or the one its machine's passives grant every weapon and debuff (the Kite's
## two), the longer.
func cooldown_of(ms: MechState, f: Face) -> int:
	if f == null:
		return 0
	return maxi(f.cooldown_rounds(), Effects.granted_cooldown(ms.unit, f))


## One attack's share of the reach tally (the runner's; the game never reads it).
func _tally_reach(reach: int, dealt: int, aimed_back: bool, heat: int) -> void:
	var k := str(Face.REACH_NAMES.get(reach, reach))
	var t: Dictionary = reach_tally.get(k, {"spends": 0, "damage": 0, "back": 0, "heat": 0})
	t["spends"] += 1
	if aimed_back:
		t["back"] += 1
	t["damage"] += dealt
	t["heat"] += heat
	reach_tally[k] = t


## Hull lost, to a blow, a bite or an overheat (Ryan, 10 October: taking hull damage is any of
## them): the on_hull_damage passives fire (the Nemesis's Crucible, a shield raised, heat
## shed, a buff stacked).
func _hull_damaged(ms: MechState) -> void:
	var parts := _apply(ms, Effects.hull_damaged(ms.unit))
	if not parts.is_empty():
		log.append("%s: %s from the hit" % [ms.unit.display_name, ", ".join(parts)])


## A foe's blow its shield took, nothing of it on the hull (Ryan, 11 November, the Nemesis: "hull
## damage takes priority"): the on_shield_hit passives fire. A bite of its own and a Barrier's
## block are no hit on its shield.
func _shield_hit(ms: MechState) -> void:
	var parts := _apply(ms, Effects.shield_hit(ms.unit))
	if not parts.is_empty():
		log.append("%s: %s from the hit on its shield" % [ms.unit.display_name, ", ".join(parts)])


## The blows of a spend that a foe's armour or Barrier took whole (the Nemesis's rage, Ryan, 11
## November, per blow): the on_blocked passives fire once a blow, one log line for the spend.
func _blows_blocked(ms: MechState, n: int) -> void:
	var parts: Array[String] = []
	for i in range(n):
		for p in _apply(ms, Effects.blow_blocked(ms.unit)):
			if not parts.has(p):
				parts.append(p)
	if not parts.is_empty():
		log.append("%s: %s, %d blow%s blocked whole" % [ms.unit.display_name, ", ".join(parts), n, "" if n == 1 else "s"])


## Shocked (the Polar Bear's retaliation, 28 September; built 29 September): the foe that struck
## carries one shock, never more, until a weapon's strike aimed at it spends it double. A machine's loop passive
## may catch the status like any other.
## Exposed on a foe through the next round (renewing, never adding): in Direct reach of every
## machine and its armour counting for nothing.
func _expose(foe: Foe, by: MechState, turned = null) -> void:
	if Effects.turns_mark(foe, "exposure"):
		_turned_away(foe, "exposure", turned, by)
		return
	Effects.grant_for_rounds(foe, Effects.STATUS["exposure"], "mech", round + 1)
	log.append("%s exposes %s" % [by.unit.display_name, foe.display_name])
	_foe_gained_status(foe, "exposure")


func _shock(foe: Foe, by: MechState, turned = null) -> void:
	if Effects.has(foe, "shocked"):
		return
	if Effects.turns_mark(foe, "shocked"):
		_turned_away(foe, "shocked", turned, by)
		return
	Effects.stack(foe, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	log.append("%s shocks %s" % [by.unit.display_name, foe.display_name])
	_foe_gained_status(foe, "shocked")


## The primers (Ryan, 2 November; keywords since 3 November): Charged and Supercooled ride the
## weapons a machine fires as Shock and as Cryo, one more a strike (Effects.effective_face), and
## a weapon fired or laid spends a stack of each: a Rapid's second fire is a second fire, a salvo
## one, a blast none, and equipment spends nothing.
func _spend_primers(ms: MechState) -> void:
	for id in ["charged", "supercooled"]:
		if Effects.stacks_of(ms.unit, id) <= 0:
			continue
		Effects.spend_stacks(ms.unit, id, 1)
		log.append("%s: %s spent on the fire (%d left)" % [ms.unit.display_name, str(Effects.STATUS[id]["name"]), Effects.stacks_of(ms.unit, id)])


## A strike's rider landing on its foe once the strikes are done, felled or not (death is the
## spend's last check): `n` stacks of a status, told once (gained) or turned away by its Ward
## (turned); a passive's lay is tallied for the log (laid).
func _land_rider(foe: Foe, sid: String, n: int, gained: Dictionary, turned: Dictionary, laid = null) -> void:
	if n <= 0:
		return
	Effects.stack(foe, Effects.STATUS[sid], Effects.SKIRMISH, "mech", n, Effects.status_decay(Effects.STATUS[sid]))
	_note_status(gained, foe, sid, turned)
	if laid == null or Effects.turns_mark(foe, sid):
		return   # its Ward turned the lay away: nothing laid to tell
	var per: Dictionary = laid.get(foe, {})
	per[sid] = int(per.get(sid, 0)) + n
	laid[foe] = per


## A Web landing once the strikes are done: one web however often the foe was webbed.
func _land_web(foe: Foe, gained: Dictionary, turned: Dictionary, webbed: Array[Foe]) -> void:
	if Effects.has(foe, "webbed"):
		return
	Effects.stack(foe, Effects.STATUS["webbed"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	_note_status(gained, foe, "webbed", turned)
	if foe.alive() and Effects.has(foe, "webbed") and not webbed.has(foe):
		webbed.append(foe)   # a fallen foe's web never bursts: nothing to tell


## Spillover: `amount` of a blow, past the kill of the front-rank `foe`, carries into the foe
## behind it in the column as plain damage, a blow of the hit's landing as every blow does
## (_land_blow: the weapon's damage, so a Barrier takes it, then its armour, never a breach); it
## feeds the talons' kill rule and carries no keyword of the blow, and, aimed at nobody, it
## neither doubles on a Shock nor spends one (29 October). A foe behind
## that the blow already reaches (a penetrate) takes the strike itself, never a spill too, and
## one already fallen takes nothing: nothing stands behind the back rank, so the damage is lost.
## `strike`: the strike it spills from, for the blow it records. `whole`: a later strike's whole
## number, a weapon's, which lands as its blow even at 0 (its Flak added); a kill's excess of 0
## carries nothing.
func _spill(ms: MechState, f: Face, foe: Foe, amount: int, hit: Array[Foe], strike: int, whole: bool = false) -> void:
	var behind: Foe = back[foe.column] if foe.column >= 0 and foe.column < columns else null
	if (amount <= 0 and not whole) or behind == null or not behind.alive() or hit.has(behind):
		return
	var behind_taken := int(_land_blow(behind, amount, ms.unit, true, false, behind.armour_total(), strike, "spill")["taken"])
	log.append("%s spills over: %d into %s" % [ms.unit.display_name, behind_taken, behind.display_name])


## The Soulcutter Talons' rule (28 September; built 29 September; a rule printed on its one
## carrier and no keyword to learn since 11 October, Ryan: "devour is not a thing"): every foe
## the entry kills gives its owner `per_kill` stacks of Empowered, a grant a kill (a spread that
## kills two feeds twice, a Chain on every conductor it kills), counted at the spend's death check
## as every kill trigger is (is_kill, Ryan, 8 November), so a foe getting back up feeds nothing.
## The stacks halve each round like any Empowered; on the Ammit its Quintessence Tap keeps them
## for the battle (Effects.stack applies the keep).
func _overcharge_on_kill(ms: MechState, killed: int, per_kill: int) -> void:
	for i in range(killed):
		var stacks := _stacks_from(ms, "overcharged", per_kill)
		Effects.stack(ms.unit, Effects.STATUS["overcharged"], Effects.SKIRMISH, "kill", stacks, Effects.status_decay(Effects.STATUS["overcharged"]))
	log.append("%s feeds on %d kill%s: %s ×%d" % [ms.unit.display_name, killed, "" if killed == 1 else "s", str(Effects.STATUS["overcharged"]["name"]), Effects.stacks_of(ms.unit, "overcharged")])


## Stacks this machine is applying, deepened by its on_stack passives (the Stingray's
## Exothermic Suite: a stack per 20 heat carried, on every stack it applies, to a foe, an
## ally or itself). Numbed is never deepened: it is exempt from every interaction (Ryan,
## 2 October), and Effects.extra_stacks says so.
func _stacks_from(ms: MechState, status_id: String, n: int) -> int:
	if n <= 0:
		return n
	var extra := Effects.extra_stacks(ms.unit, status_id, ms.heat)
	if extra > 0:
		log.append("%s runs hot: +%d %s" % [ms.unit.display_name, extra, str(Effects.STATUS.get(status_id, {}).get("name", status_id))])
	return n + extra


## Suppress: the foe loses its next action (this round's, or the next round's when it has
## already acted this turn). A Ward turns the stun away as it turns any mark (Ryan,
## 2 November). A Numbed foe (Ryan, 2 November, in place of the roll of 26 September): the stun
## strips a stack and lands nothing, so a foe with Numbed N takes N+1 stuns in a round to stun
## again; the foe gains its stun resist in stacks as it recovers, after the round's decay, and
## a stack goes at each round's end (_enemy_turn), so the chip counts the rounds until one stun
## lands. A foe already suppressed gains nothing more: Suppressed never stacks and never
## carries (Ryan, 17 October: "Suppressed is suppressed - they lose their next action. It does
## not stack, it does not carry"), so a Paradox tripping on a suppressed foe is wasted, its
## meter spent.
func _suppress(foe: Foe, turned = null) -> bool:
	# A foe that has already acted this turn loses its next action instead of one it has taken,
	# and so does one that stepped up mid-round (a split's half), the round's turn being over.
	var next := _acted.has(foe) or foe.fresh
	if _suppressed_through(foe, round + 1 if next else round):
		log.append("%s is already suppressed" % foe.display_name)
		return false
	if Effects.has(foe, "ward"):
		if turned is Dictionary:
			_note_turned(turned, foe, "suppressed")
		else:
			log.append("%s's Ward turns the stun away" % foe.display_name)
		return false
	var numbed := Effects.stacks_of(foe, "numbed")
	if numbed > 0:
		Effects.spend_stacks(foe, "numbed", 1)
		log.append("%s: the stun strips a stack of Numbed (%d left)" % [foe.display_name, numbed - 1])
		return false
	Effects.grant_for_rounds(foe, Effects.STATUS["suppressed"], "mech", round + 1 if next else round)
	if Effects.has(foe, "golden"):
		# A stun breaks a golden rage (4 November, Ryan's read: it "transforms back after a time
		# or getting staggered"), the Suppress already its lost action.
		Effects.remove(foe, "golden")
		foe.golden_mark = -1
		log.append("%s's golden rage breaks under the stun" % foe.display_name)
	return true


## Is the foe's action of round `r` already lost to a Suppressed it carries?
func _suppressed_through(foe: Foe, r: int) -> bool:
	for m in Effects.live(foe):
		if m.id == "suppressed" and (m.expires_round < 0 or m.expires_round >= r):
			return true
	return false


## The count that knocks a foe out through Paradox: the lowest any live machine runs, or 0 when
## no machine runs the meter (the screen's chips read it).
func paradox_count() -> int:
	var at := 0
	for ms in live_mechs():
		var t: int = Effects.paradox(ms.unit)[1]
		if t > 0 and (at == 0 or t < at):
			at = t
	return at


## One spend's status on one foe, told once at the end of the spend however many strikes or
## stacks put it there (Ryan, 10 October: an application, not a stack).
static func _note_status(gained: Dictionary, foe: Foe, status_id: String, turned = null) -> void:
	if Effects.turns_mark(foe, status_id):
		# A foe's Ward turned it away (28 October): nothing gained, nothing for the Paradox, and
		# the spend tells it once.
		if turned is Dictionary and foe.alive():
			_note_turned(turned, foe, status_id)
		return
	var ids: Array = gained.get(foe, [])
	if not ids.has(status_id):
		ids.append(status_id)
	gained[foe] = ids


## A mark a foe's Ward turned away (28 October), noted once a spend.
static func _note_turned(turned: Dictionary, foe: Foe, status_id: String) -> void:
	var ids: Array = turned.get(foe, [])
	if not ids.has(status_id):
		ids.append(status_id)
	turned[foe] = ids


## A mark a foe's Ward turned away outside a spend's own count (a machine's Retaliate):
## noted for the spend's one line when the spend gathers them, told at once otherwise.
func _turned_away(foe: Foe, status_id: String, turned, by: MechState) -> void:
	if turned is Dictionary:
		_note_turned(turned, foe, status_id)
	else:
		log.append("%s's Ward turns %s's %s away" % [foe.display_name, by.unit.display_name, str(Effects.STATUS.get(status_id, {}).get("name", status_id))])


## One line a foe for the marks its Ward turned away in a spend (28 October).
func _tell_turned(turned: Dictionary) -> void:
	for foe in turned.keys():
		var names: Array[String] = []
		for id in turned[foe]:
			names.append(str(Effects.STATUS.get(id, {}).get("name", id)))
		log.append("%s's Ward turns away %s" % [foe.display_name, ", ".join(names)])


## A foe has just gained a status (whoever applied it, once a spend): every live machine's
## on_foe_status passive answers. The Baboon's Pocket Paradox, a meter since 10 October
## (Ryan): the foe gains Paradox, deepened like any status its machine applies, and at the
## machine's count it is Suppressed and the Paradox clears. Paradox never counts, and the
## Suppressed it causes is never told, so it never feeds itself; a Suppress keyword's does
## count. Numbed is a buff a Purge lowers and nothing else touches (2 November).
func _foe_gained_status(foe: Foe, status_id: String) -> void:
	if status_id == "paradox" or status_id == "numbed" or Effects.turns_mark(foe, status_id):
		return   # a felled foe's gains count too: a trigger never goes unfired for a death checked last (3 November)
	for ms in live_mechs():
		var meter := Effects.paradox(ms.unit)
		if meter[1] <= 0:
			continue
		Effects.stack(foe, Effects.STATUS["paradox"], Effects.SKIRMISH, "mech", _stacks_from(ms, "paradox", meter[0]), Effects.DECAY_NONE)
		if Effects.stacks_of(foe, "paradox") >= meter[1]:
			Effects.remove(foe, "paradox")
			log.append("%s got trapped in a paradox! (%s)" % [foe.display_name, ms.unit.display_name])
			_suppress(foe)
			return


## Lure (decided 2 October, in place of taunt and beacon): every foe this entry reached turns
## on the spender for the round, intents and all. No status and no chip: the arrow changing
## is the record. A lured foe whose move has no target (a blow at every machine included)
## keeps doing it, and the log says so.
func _lure(ms: MechState, foes: Array) -> void:
	var turned: Array[String] = []
	var idle: Array[String] = []
	for foe in foes:
		if foe.fresh:
			continue   # one that stepped up mid-round has had its round: nothing to turn
		if foe.hits_all() or foe.acts_on_nobody():
			idle.append(foe.display_name)
		if foe.target != ms:
			foe.target = ms
			turned.append(foe.display_name)
	if not turned.is_empty():
		log.append("%s lures %s" % [ms.unit.display_name, ", ".join(turned)])
	if not idle.is_empty():
		log.append("lured, but %s %s nothing to turn" % [", ".join(idle), "has" if idle.size() == 1 else "have"])


## Disrupt (decided 2 October): the foe does its other move instead, this round, the new
## intent shown at once. Deterministic: the next move in its list that its conditions allow,
## so a boss with three moves steps through its pattern; a foe with nothing else open is not
## moved. The new move keeps the pick while the machine stands.
func _disrupt(foes: Array) -> void:
	for foe in foes:
		if foe.fresh:
			continue
		if foe.committed:
			# A follow-up announced a round ahead holds (Ryan, 2 November: "cannot be Disrupted"):
			# the move that named it was the window, and a Suppress still takes it.
			log.append("%s is committed to %s, and nothing turns it" % [foe.display_name, str(foe.action.get("name", ""))])
			continue
		var next := disrupt_next(foe)
		if next.is_empty():
			log.append("%s is disrupted, and has nothing else to do" % foe.display_name)
			continue
		var was := str(foe.action.get("name", ""))
		var aimed: bool = not foe.acts_on_nobody() and not foe.reaches_every_machine()   # its pick was its intent, shown
		foe.pending = {}   # a gathered move is broken off
		foe.charge = 0
		foe.action = next
		foe.last_special = "" if foe.attacks() else str(foe.action.get("id", ""))
		_begin_countdown(foe)
		# Its pick holds (Ryan, 26 October: the intent moves on a Disrupt "only if the disrupt would
		# result in an invalid target"): a new one when the machine is gone or Phased, or when the
		# move it leaves aimed at no one machine (a brace, a blow at every machine), so the pick it
		# carried was never an intent the player saw.
		var t := foe.target as MechState
		if t == null or not t.alive() or is_out(t) or not aimed:
			foe.target = _repick(foe)
		log.append("%s is disrupted: %s instead of %s" % [foe.display_name, str(next.get("name", "")), was])


## The move a disrupt turns this foe to: the next in its pattern, the first legal move after its
## current one, wrapping; empty when it has nothing else open. The spend and the bot read it here.
func disrupt_next(foe: Foe) -> Dictionary:
	var others: Array = []
	for a in legal_actions(foe):
		if a != foe.action:
			others.append(a)
	if others.is_empty():
		return {}
	var start: int = foe.actions.find(foe.action)
	var next: Dictionary = others[0]
	for k in range(1, foe.actions.size() + 1):
		var cand: Dictionary = foe.actions[(start + k) % foe.actions.size()]
		if others.has(cand):
			next = cand
			break
	return next


## The cleanse keyword on a shield or vent component: whoever it was spent on loses every
## cleansable status (a foe's disable, Corrupted, Silenced, Burning, Scorched), and the log says which.
func _cleanse_with(ms: MechState, who: MechState, f: Face) -> void:
	if not f.has(Face.Keyword.CLEANSE):
		return
	var gone := Effects.cleanse(who.unit)
	if gone.is_empty():
		log.append("%s cleanses %s: nothing to clear" % [ms.unit.display_name, who.unit.display_name])
	else:
		log.append("%s cleanses %s: %s cleared" % [ms.unit.display_name, who.unit.display_name, ", ".join(gone).to_lower()])


## A corrupted entry's bite against a shield and a hull: shield first, whole, then hull,
## never armoured and never an injury. Shared by the real bite and the forecast.
static func _bite(shield: int, hull: int, amount: int) -> Dictionary:
	var absorbed := mini(shield, amount)
	return {"shield": shield - absorbed, "hull": hull - (amount - absorbed)}


## Heat only climbs here, past the maximum too. It burns at the end of the round (Ryan,
## 22 September: every overheat lands at once, never as a spike when a component is spent),
## so a machine run hot can still be vented before it pays. Gaining heat fires the
## on_heat_gain passives (which may raise shield, never heat).
func _add_heat(ms: MechState, amount: int, entry: int = -1) -> void:
	if amount > 0:
		if entry >= 0 and ms.heat <= ms.heat_max and ms.heat + amount > ms.heat_max:
			ms.hot_entry = entry   # a spend took the gauge past its maximum: the overheat's what-ifs land on it
		ms.heat += amount
		_fired(ms, Effects.fire(ms.unit, "on_heat_gain", amount), "on the heat")


## Shield gained from any source, capped at the maximum unless the component carries
## Overshield; gaining any fires the on_shield_gain passives (which may shed heat, never
## raise shield). Returns what stood up.
func _gain_shield(ms: MechState, amount: int, overshield: bool = false) -> int:
	if amount <= 0:
		return 0
	var gained := ms.unit.recharge_shield(amount, overshield)
	if gained > 0:
		_fired(ms, Effects.fire(ms.unit, "on_shield_gain", gained), "on the shield")
	return gained


## A shield component spent on an ally fires the spender's on_shield_granted passives on
## that ally (the Puffin's escort passive, 5 October): heat the ally sheds, statuses it
## gains. Fires on the spend, whatever the shield gained.
func _shield_granted(ms: MechState, who: MechState, amount: int) -> void:
	var r := Effects.shield_granted(ms.unit, who.unit, amount)
	var parts: Array[String] = []
	var vented := mini(who.heat, int(r["vent"]))
	if vented > 0:
		who.heat -= vented
		parts.append("-%d heat" % vented)
	for name in r["statuses"]:
		parts.append(str(name))
	if not parts.is_empty():
		log.append("%s: %s's escort, %s" % [who.unit.display_name, ms.unit.display_name, ", ".join(parts)])


## The round's end lets shield past the maximum go (Overshield, 5 October): the excess was a
## one-round buffer, and a buffer that stayed would stack a team past every blow.
func _trim_overshield() -> void:
	for ms in live_mechs():
		if ms.unit.shield > ms.unit.shield_max:
			log.append("%s: %d shield past its maximum fades" % [ms.unit.display_name, ms.unit.shield - ms.unit.shield_max])
			ms.unit.shield = ms.unit.shield_max


## Apply what a trigger's passives gave a machine: shield up (which is a shield gain of its
## own), heat off, and a log line naming it when anything happened.
func _fired(ms: MechState, result: Dictionary, when: String) -> void:
	var parts := _apply(ms, result)
	if not parts.is_empty():
		log.append("%s: %s, %s" % [ms.unit.display_name, when, ", ".join(parts)])


## What a trigger's passives gave a machine, applied where the gauges live; returns the
## pieces for the log line.
func _apply(ms: MechState, result: Dictionary) -> Array[String]:
	var parts: Array[String] = []
	var gained := _gain_shield(ms, int(result["shield"]))
	if gained > 0:
		parts.append("+%d shield" % gained)
	var vented := mini(ms.heat, int(result["vent"]))
	if vented > 0:
		ms.heat -= vented
		parts.append("-%d heat" % vented)
	for name in result["statuses"]:
		parts.append(str(name))
	return parts


## The end of the player's turn: heat above the maximum burns hull one for one (overheat_scale
## a point, for a runner's what-if) and the gauge settles at its cap.
func _settle_heat() -> void:
	for ms in live_mechs():
		var over := ms.heat - ms.heat_max
		if over <= 0:
			continue
		var burn := over * overheat_scale
		var culprit := ms.hot_entry   # read before the gauge settles, which clears it
		ms.unit.hull -= burn
		ms.heat = ms.heat_max
		overheats.append({"mech": mechs.find(ms), "over": over, "burn": burn, "hull": ms.unit.hull})
		log.append("%s overheats: hull -%d" % [ms.unit.display_name, burn])
		if ms.alive():
			_hull_damaged(ms)   # an overheat is hull damage like any other (10 October)
		_overheat_marks(ms, burn, culprit)


## The overheat's what-ifs (Ryan, 30 October), on the component whose spend took the gauge past
## its maximum this turn and left it there (`idx`, MechState.hot_entry): none when a status's
## heat did, or when a vent brought the gauge back under before a status took it over again. A
## burn reaching the injury threshold burns it out for the battle as an injury does, else the
## overheat Corrupts it.
func _overheat_marks(ms: MechState, burn: int, idx: int) -> void:
	if idx < 0 or idx >= ms.die.faces.size() or not ms.alive():
		return
	if overheat_burnout and burn * 100 >= ms.unit.hull_max * injury_pct:
		log.append("%s: the overheat burns out its %s" % [ms.unit.display_name, ms.die.faces[idx].describe()])
		if _injure_entry(ms, idx) == "destroyed":
			return
	if overheat_corrupt > 0 and ms.die.faces[idx].kind != Face.Kind.BLANK:
		Effects.corrupt_entry(ms.unit, idx, "overheat", overheat_corrupt)
		log.append("%s: the overheat corrupts its %s (×%d)" % [ms.unit.display_name, ms.die.faces[idx].describe(), Effects.corrupt_stacks(ms.unit, idx)])


## One blow. The honest shield (Ryan, 14 October; built 21 October): the shield absorbs its
## number and the excess reaches the hull. A blow that reaches the hull loses the chassis's
## armour first, so small hits bounce off a heavy machine, and it destroys a component when
## what gets through reaches the injury threshold, a share of max hull (INJURY_MIN_HULL_PCT).
## One breach (22 October): a breach ignores the shield, which stands, and the armour, so the
## whole blow reaches the hull. A Barrier takes the next blow whole; a Ward turns a breach
## away. A shield sized to a telegraphed blow, or a Barrier, is the counterplay.
func _damage_mech(ms: MechState, amount: int, source: Foe) -> void:
	if is_out(ms):
		return   # a machine out of the fight takes no damage (ticks and overheats are its own, and land elsewhere)
	# Buffs and debuffs on damage taken, before shield and armour, the striker read for its
	# statuses; a Barrier takes the next blow that deals anything, whole, and is spent, a blow of
	# nothing leaving it standing (Shocked's mirror); a Ward turns a breach away, so the shield
	# absorbs it like any blow (Ryan, 14 October): _blow_on, the forecast's arithmetic too.
	var r := _blow_on(ms, amount, source, ms.unit.shield, Effects.has(ms.unit, "barrier"))
	var brought := int(r["amount"])   # the blow as it arrives, for the round preview's incoming
	var barred := bool(r["barred"])
	if barred:
		Effects.remove(ms.unit, "barrier")
	var warded := bool(r["warded"])
	var breach := bool(r["breach"])
	var had_shield := ms.unit.shield > 0
	ms.unit.shield = r["shield"]
	ms.unit.hull -= r["through"]
	var rk := "back" if source != null and source.rank == 1 else "front"
	taken_by_rank[rk] = int(taken_by_rank.get(rk, 0)) + int(r["absorbed"]) + int(r["through"])
	sponsorship["guarded"] = int(sponsorship["guarded"]) + int(r["absorbed"]) + int(r["armoured"])
	# The mech's gauges after the blow ride along, so a replay can step them down blow by blow.
	turn_events.append({"foe": source, "mech": mechs.find(ms), "amount": brought, "absorbed": r["absorbed"], "through": r["through"],
		"blocked": r["blocked"], "barred": barred, "broke_shield": had_shield and ms.unit.shield == 0, "injured": r["injures"],
		"shield": ms.unit.shield, "hull": ms.unit.hull, "seq": _seq,
		"name": str(source.action.get("name", "")) if source != null else "", "boss": source != null and source.boss,
		"all": source != null and source.hits_all()})
	_seq += 1
	var verb := "breaches" if breach and had_shield else "hits"
	var armoured: String = " (armour -%d)" % r["armoured"] if r["armoured"] > 0 else ""
	if warded and had_shield and not barred:
		log.append("%s: the Ward turns %s's breach away" % [ms.unit.display_name, source.display_name])
	if barred:
		log.append("%s hits %s: the Barrier takes the blow" % [source.display_name, ms.unit.display_name])
	elif r["blocked"]:
		log.append("%s hits %s: shield -%d, blocked" % [source.display_name, ms.unit.display_name, r["absorbed"]])
	elif r["through"] == 0:
		log.append("%s %s %s: %sarmour holds" % [source.display_name, verb, ms.unit.display_name, "shield -%d, " % r["absorbed"] if r["absorbed"] > 0 else ""])
	elif r["absorbed"] > 0:
		log.append("%s hits %s: shield -%d, hull -%d%s" % [source.display_name, ms.unit.display_name, r["absorbed"], r["through"], armoured])
	else:
		log.append("%s %s %s: hull -%d%s" % [source.display_name, verb, ms.unit.display_name, r["through"], armoured])
	# Siphoning: every blow a foe lands adds heat, whatever it dealt, in the enemy's turn, after
	# the overheat has settled, so it is next round's fuel or next turn's burn.
	var siphoned := Effects.heat_per_blow(ms.unit)
	if siphoned > 0 and ms.alive():
		_add_heat(ms, siphoned)   # through the heat path, so a passive on heat gained answers it (the audit's 17)
		log.append("%s banks the blow: +%d heat" % [ms.unit.display_name, siphoned])
	if int(r["through"]) > 0:
		_hull_damaged(ms)
	elif int(r["absorbed"]) > 0:
		_shield_hit(ms)   # a blow its shield took, none of it on the hull (the Nemesis's rage: hull first)
	if r["injures"]:
		# What the injury did rides on the event too: the console says a component was
		# damaged or destroyed (Jenny's information lines, 8 October).
		turn_events[turn_events.size() - 1]["component"] = apply_injury(ms)


## The arithmetic of one blow against a shield, hull max and armour, shared by the real hit
## and the forecast. The honest shield (Ryan, 14 October): a shield absorbs its number and the
## excess passes to the hull. One breach (22 October): a breach ignores the shield outright,
## which stands, and the armour, so the whole blow reaches the hull.
## Returns shield after, absorbed, through (to hull), armoured (taken off by armour), blocked
## (the shield took the whole blow), injures (what reached the hull, over the threshold) and
## breach (the blow ignored shield and armour).
static func _blow(shield: int, hull_max: int, armour: int, amount: int, breach: bool) -> Dictionary:
	var absorbed := 0 if breach else mini(maxi(0, shield), maxi(0, amount))
	var through := maxi(0, amount) - absorbed
	# Armour comes off every blow that reaches the hull, a shield's overflow included, and never
	# off a breach (one breach, 22 October: the anti-tank threat, by move, the Ward its answer;
	# until then a breach beat the shield and never the plate). A blow on the shield costs it
	# its full damage: shield is not armoured.
	var armoured := mini(armour, through) if through > 0 and not breach else 0
	through -= armoured
	# Injury counts what reaches the hull in one blow, wherever it came from: past the shield,
	# past a breach, on bare hull (the injury row: a share of the hull in one blow injures).
	var injures := injuries and through > 0 and through * 100 >= hull_max * injury_pct
	return {"shield": shield - absorbed, "absorbed": absorbed, "through": through, "armoured": armoured, "blocked": absorbed > 0 and through + armoured == 0, "injures": injures, "breach": breach}


## The injury destroys the entry the die shows (Ryan, 2 November, in place of the die's roll of
## 17 September: what faces the enemy is the player's choice, the entry it spent, held or
## locked): blank, until the hangar mends it (one state, Ryan, 25 October: "Cracked is gone").
## A destroyed component or an empty hardpoint showing takes the blow and nothing happens, so a
## second such blow in the turn finds nothing to break. The damage lives on the unit and
## persists until repaired in the hangar. A passive may say no_destroy on_injury: then the
## component holds. The preview's copy breaks the same entry, so the forecast is exact.
func apply_injury(ms: MechState) -> String:
	if ms.die.faces.is_empty():
		return ""
	return _injure_entry(ms, ms.face_index)


## The injury on one entry: a component is destroyed (unless a passive holds it), a blank
## shrugs it off. Returns what happened: "destroyed", or "" for nothing.
func _injure_entry(ms: MechState, idx: int) -> String:
	if idx < 0 or idx >= ms.die.faces.size():
		return ""
	var f := ms.die.faces[idx]
	if f.kind == Face.Kind.BLANK:
		log.append("%s: the blow lands on %s; nothing left to break" % [ms.unit.display_name, "an empty hardpoint" if f.empty else "a destroyed component"])
		return ""
	var what := f.describe()
	if Effects.no_destroy(ms.unit, f):
		log.append("%s: %s holds, never destroyed" % [ms.unit.display_name, what])
		return ""
	var originals: Dictionary = ms.unit.damaged_faces
	if not originals.has(idx):
		originals[idx] = f.duplicate_face()
	var d := Face.blank()
	d.component = f.component
	ms.die.faces[idx] = d
	destroyed += 1
	log.append("%s: a component is destroyed (%s)" % [ms.unit.display_name, what])
	return "destroyed"


## Whom a foe strikes (decided 2 October): its own pick, by the sense its move follows, at
## random unless the foe carries an aim (24 October). Anything, uniform; the exposed, weighted
## by the hull its blow would reach, so a shield standing lowers the draw and a shield down
## raises it; heat, the hottest machine; the armed, a machine showing an intact weapon or debuff; the
## buffed, the most stacks of buffs (each of those two the exposed when no machine qualifies);
## fires as one (focus), the rank's shared pick. No pick lands on a machine in `avoid`, which
## the blows already drawn this round would wreck, while another stands. The pick is a
## commitment: a foe whose target shields up still swings at it. With the override set, or
## asked with no foe, the rule before: the lowest shield, then the lowest hull. A pick made
## again mid-round is _repick's, and draws nothing.
func _pick_mech_target(f: Foe = null, avoid: Array = []) -> MechState:
	var live := targetable_mechs()
	if live.is_empty():
		return null
	var r := rng
	# Never over-commit: a machine the blows already drawn would wreck is passed over while
	# another stands.
	var open: Array[MechState] = []
	for ms in live:
		if not avoid.has(ms):
			open.append(ms)
	if not open.is_empty():
		live = open
	if f == null or targeting_override == "lowest":
		return _lowest_shield(live)
	match f.aim_of():
		"anything":
			return live[r.randi_range(0, live.size() - 1)]
		"heat":
			var hottest: Array[MechState] = []
			for ms in live:
				if hottest.is_empty() or ms.heat > hottest[0].heat:
					hottest = [ms]
				elif ms.heat == hottest[0].heat:
					hottest.append(ms)
			return hottest[r.randi_range(0, hottest.size() - 1)]
		"armed":
			var armed: Array[MechState] = []
			for ms in _armed_mechs():
				if live.has(ms):
					armed.append(ms)
			if armed.is_empty():
				return _pick_exposed(f, live, r)
			return armed[r.randi_range(0, armed.size() - 1)]
		"buffed":
			# The buffed (21 October): the machine carrying the most stacks of buffs (never stores),
			# drawn among the tied; the exposed when none carries any.
			var most: Array[MechState] = []
			var top := 0
			for ms in live:
				var n := Effects.buff_stacks(ms.unit)
				if n > top:
					top = n
					most = [ms]
				elif n == top and n > 0:
					most.append(ms)
			if most.is_empty():
				return _pick_exposed(f, live, r)
			return most[r.randi_range(0, most.size() - 1)]
		"focus":
			var shared = _focus.get(f.rank, null)
			if shared != null and shared.alive() and not is_out(shared) and live.has(shared):
				return shared
			var pick := _pick_exposed(f, live, r)
			_focus[f.rank] = pick
			return pick
	return _pick_exposed(f, live, r)


## A pick made again mid-round (its machine fell before it acts or is Phased, a Disrupted foe's
## gone): the next machine in line, left to right, that stands and is not Phased, whatever the
## foe's aim (Ryan, 26 October: Slice and Dice's rule, "it just targets the next ally in line",
## which the player can tell without the preview, and an aim breaking it would be "more
## unpredictable info"; it retires a draw from a stream of the fight's own, randomness the player
## could see only through the preview). With the override set, the rule before.
func _repick(_f: Foe) -> MechState:
	var live := targetable_mechs()   # in field order, left to right
	if live.is_empty():
		return null
	if targeting_override == "lowest":
		return _lowest_shield(live)
	return live[0]


static func _lowest_shield(live: Array[MechState]) -> MechState:
	var best: MechState = null
	for ms in live:
		if best == null \
				or ms.unit.shield < best.unit.shield \
				or (ms.unit.shield == best.unit.shield and ms.unit.hull < best.unit.hull):
			best = ms
	return best


## The exposed: each machine weighs one, plus the hull this foe's blows would reach through
## its shield, armour, Barrier and Ward as they stand, plus half of any shield they would
## break (a shield about to fail is exposure too), and the pick is drawn by weight from `r`.
func _pick_exposed(f: Foe, live: Array[MechState], r: RandomNumberGenerator) -> MechState:
	var weights: Array[float] = []
	var total := 0.0
	for ms in live:
		var w := 1.0 + float(hull_reached(f, ms)) + float(shield_broken(f, ms)) * 0.5
		weights.append(w)
		total += w
	var roll := r.randf() * total
	for i in range(live.size()):
		roll -= weights[i]
		if roll <= 0.0:
			return live[i]
	return live[live.size() - 1]


## The shield this foe's blows would take off a machine, when they would take all of it;
## zero when the shield holds.
func shield_broken(f: Foe, ms: MechState) -> int:
	if foe_blow(f) <= 0 or ms.unit.shield <= 0:
		return 0
	var walk := {"shield": ms.unit.shield, "barrier": Effects.has(ms.unit, "barrier")}
	blows_on(ms, f, walk)
	return ms.unit.shield if int(walk["shield"]) <= 0 else 0


## The hull this foe's blows would reach on a machine as it stands: its damage, its strikes,
## its breach, against the shield, armour, Barrier, Ward and damage taken the forecast reads.
func hull_reached(f: Foe, ms: MechState) -> int:
	if foe_blow(f) <= 0:
		return 0
	var walk := {"shield": ms.unit.shield, "barrier": Effects.has(ms.unit, "barrier")}
	var through := 0
	for r in blows_on(ms, f, walk):
		through += int(r["through"])
	return mini(through, maxi(0, ms.unit.hull))


# ---------------------------------------------------------------- formation

func _clear_dead() -> void:
	_fall_with_cores()
	_clear_dead_slots()
	_release_staggered()
	_break_golden()
	_refresh_kin()
	_refresh_guards()


# ---------------------------------------------------------------- a boss in parts

## The boss in parts (Ryan, 15 October: parts that regrow, or stand for a while, until the core
## is killed, so the player chooses what to focus): a core's parts are the foes of its pack
## whose type it names, on the field. Found by pack and type, so a save needs no references.
func parts_of(core: Foe) -> Array[Foe]:
	var out: Array[Foe] = []
	if not core.has_parts():
		return out
	for f in field_foes():
		if f != core and f.alive() and f.pack_id == core.pack_id and core.part_ids.has(f.content_id):
			out.append(f)
	return out


## How many of a core's parts are down (30 October, the Obsidian Tyrant's rider): its parts less
## those standing and those waiting to step in, a part growing back counted down until it stands.
func parts_down(core: Foe) -> int:
	if not core.has_parts():
		return 0
	var up := parts_of(core).size()
	for f in reinforcements:
		if f.alive() and f.pack_id == core.pack_id and core.part_ids.has(f.content_id):
			up += 1
	return maxi(0, core.part_ids.size() - up)


## Every core's guard as its parts stand now: Guarded while all its parts stand ("all"), or
## while any does ("any"), lifted the moment that stops being true, so a part killed by one
## die opens the core to the next.
func _refresh_guards() -> void:
	for core in field_foes():
		if not core.alive() or not core.has_parts():
			continue
		_schedule_regrowth(core)
		if core.guard.is_empty():
			continue
		var standing := parts_of(core).size()
		var guarded := standing > 0 and (core.guard == "any" or standing >= core.part_ids.size())
		if guarded and not Effects.has(core, "guarded"):
			Effects.stack(core, Effects.STATUS["guarded"], Effects.SKIRMISH, "parts", 1, Effects.DECAY_NONE)
		elif not guarded and Effects.has(core, "guarded"):
			Effects.remove(core, "guarded")
			log.append("%s is open: its guard has fallen" % core.display_name)


## A part down, while the core stands, is on its way back when the core regrows its parts.
func _schedule_regrowth(core: Foe) -> void:
	if core.regrow_parts <= 0:
		return
	var present: Dictionary = {}
	for f in parts_of(core):
		present[f.content_id] = int(present.get(f.content_id, 0)) + 1
	for f in reinforcements:
		if f.pack_id == core.pack_id and core.part_ids.has(f.content_id):
			present[f.content_id] = int(present.get(f.content_id, 0)) + 1
	for d in core.regrow_due:
		present[str(d[0])] = int(present.get(str(d[0]), 0)) + 1
	for pid in core.part_ids:
		if int(present.get(pid, 0)) > 0:
			present[pid] = int(present[pid]) - 1
		else:
			core.regrow_due.append([pid, round + core.regrow_parts])


## At the round's end, the parts due back regrow where they fell: each in the slot its corpse
## holds (Ryan, 7 November: "a boss regrowing is the same thing as the gel"), else the nearest
## free slot of its rank by its core; with no room it waits for the next round's end.
func _regrow_parts() -> void:
	if not foe_factory.is_valid():
		return
	for core in field_foes():
		if not core.alive() or core.regrow_due.is_empty():
			continue
		var keep: Array = []
		for d in core.regrow_due:
			if int(d[1]) > round:
				keep.append(d)
				continue
			var n = foe_factory.call(str(d[0]))
			if not (n is Foe):
				continue
			n.pack_id = core.pack_id
			n.joined = true
			var at := _corpse_slot(core, str(d[0]))
			if at.x >= 0:
				corpses.erase(at)
				n.fresh = true
				_place(n, at.x, at.y)
				log.append("%s grows back its %s where it fell" % [core.display_name, n.display_name])
			elif _step_up(n, core.column):
				log.append("%s grows back its %s" % [core.display_name, n.display_name])
			else:
				keep.append(d)   # no room yet: it waits for a slot to open
		core.regrow_due = keep


## The slot a core's fallen part of `part_id` holds, (-1, -1) for none.
func _corpse_slot(core: Foe, part_id: String) -> Vector2i:
	for at in corpses.keys():
		var c: Foe = corpses[at]
		if c.content_id == part_id and c.pack_id == core.pack_id:
			return at
	return Vector2i(-1, -1)


## Whether a fallen foe is a part its standing core will regrow: it holds its slot as a corpse.
func _regrows(f: Foe) -> bool:
	for core in field_foes():
		if core != f and core.alive() and core.regrow_parts > 0 and core.pack_id == f.pack_id and core.part_ids.has(f.content_id):
			return true
	return false


## A foe's last act (15 October, the Gargantuan King's Meteor): its death blow lands the moment it
## falls, before anything else, so the player shields first and kills after, and even the last
## foe's lands, since damage sticks for the battle.
func _last_act(f: Foe) -> void:
	var blow := f.last_act()
	if blow.is_empty():
		return
	f.action = blow
	f.pending = {}
	f.charge = 0
	log.append("%s falls, and its last act lands: %s" % [f.display_name, str(blow.get("name", ""))])
	var struck: Array[int] = []
	var gauges: Array = []   # each struck machine's [shield, hull] as the act met it
	if f.hits_all():
		for m in targetable_mechs():
			struck.append(mechs.find(m))
			gauges.append([m.unit.shield, m.unit.hull])
			_strike(f, m)
	else:
		var t := f.target as MechState
		if t == null or not t.alive():
			t = _repick(f)
		if t != null:
			struck.append(mechs.find(t))
			gauges.append([t.unit.shield, t.unit.hull])
			_strike(f, t)
	last_acts.append({"foe": f, "name": str(blow.get("name", "")), "mechs": struck, "gauges": gauges})


## A core that falls for good takes its parts with it, on the field and waiting alike.
func _fall_with_cores() -> void:
	for core in field_foes():
		if core.alive() or not core.has_parts() or (Effects.has(core, "risen") and not core.stays_down):
			continue
		var parts := parts_of(core)
		for f in parts:
			f.hp = 0
			f.stays_down = true
		var waiting: Array[Foe] = []
		for f in reinforcements:
			if f.pack_id == core.pack_id and core.part_ids.has(f.content_id):
				waiting.append(f)
		for f in waiting:
			reinforcements.erase(f)
		core.regrow_due = []
		for at in corpses.keys():
			var c: Foe = corpses[at]
			if c.pack_id == core.pack_id and core.part_ids.has(c.content_id):
				corpses.erase(at)   # its parts never regrow now: their slots are only empty
		if not parts.is_empty() or not waiting.is_empty():
			log.append("%s falls, and its parts with it" % core.display_name)


## A blow the spend under way landed on `foe`, for the screen (spend_blows).
func _note_blow(foe: Foe, strike: int, taken: int, kind: String) -> void:
	spend_blows.append({"foe": foe, "strike": strike, "taken": maxi(0, taken), "hp": foe.hp, "kind": kind})


## A Sweep's shot at an empty column (Ryan, 7 November: "Animate wasted shots"): no foe, the slot
## it landed in, for the screen to fire at and land on.
func _note_miss(slot: Vector2i, strike: int) -> void:
	spend_blows.append({"foe": null, "slot": slot, "strike": strike, "taken": 0, "hp": 0, "kind": "miss"})


## The pack a foe fights for, or null (a test's foes come from none).
func _pack_of(f: Foe) -> Unit:
	for sq in packs:
		if sq.id == f.pack_id:
			return sq
	return null


## The death check's slots (_clear_dead): every felled foe cleared (_clear_fallen); then the Mines
## of those that fell (Ryan, 9 November: "the explosion should occur after the death check
## regardless of revive or split"), each blowing once the slots are clear, in strike order, front
## left to right then the back, a foe a blast fells checked at once and its own Mine blowing in
## turn; then, outside a spend, what the falls bring back stands.
func _clear_dead_slots() -> void:
	_clear_fallen()
	while not _blasts.is_empty():
		var due := _blasts
		_blasts = []
		due.sort_custom(func(a, b) -> bool: return int(a["rank"]) < int(b["rank"]) or (int(a["rank"]) == int(b["rank"]) and int(a["col"]) < int(b["col"])))
		for b in due:
			_blow_mine(b["mine"], int(b["rank"]), int(b["col"]), bool(b["massive"]), str(b["where"]))
		_fall_with_cores()
		_clear_fallen()
	if not _holding_returns:
		_release_returns()


## Every felled foe on the field cleared from its slot, its kill counted, its swallowed machine let
## go, its last act landed and its return or its corpse noted; its Mine taken off it to blow
## (_blasts). A twin slot's survivor keeps the slot alone.
func _clear_fallen() -> void:
	# The kills first, every felled foe judged against the field as the death check finds it, so a
	# core cleared before its part below still names it (is_part).
	var fell := 0
	for f in field_foes():
		if not f.alive() and f.rank >= 0 and is_kill(f):
			_count_kill(f)
			fell += 1
	_foes_fell(fell)
	for col in range(columns):
		for rank in [front, back]:
			var key := Vector2i(0 if is_same(rank, front) else 1, col)
			var members: Array = [rank[col], twins.get(key, null)]
			var cleared := false
			for f in members:
				if f == null or f.alive():
					continue
				cleared = true
				if f.rank >= 0:
					var mine := mine_of(f)
					if not mine.is_empty():
						Effects.remove(f, "mine")   # it blows once the slots are clear; whatever gets back up starts clean
						_blasts.append({"mine": mine, "rank": 0 if f.is_massive() or is_same(rank, front) else 1, "col": col, "massive": f.is_massive(), "where": f.display_name})
					_release_swallowed(f)   # a swallower down lets its machine go, whatever comes next
					# A foe that readied itself to get back up does so once, whole, in its own slot,
					# unless it went whole (a Bomb's burst): once its slot is clear, or, a kill of a
					# spend's, once the spend is done (_release_returns).
					if Effects.has(f, "risen") and not f.stays_down:
						_risers.append([f, 0 if is_same(rank, front) or f.is_massive() else 1, col])
					else:
						log.append("%s destroyed" % f.display_name)
						_last_act(f)
						if not f.on_death.is_empty() and f.on_death.has("summon"):
							_splitters.append([f, 0 if is_same(rank, front) else 1, col])
						elif _regrows(f):
							corpses[Vector2i(0 if is_same(rank, front) else 1, col)] = f   # it holds its slot until its core regrows it there
				f.rank = -1
			if cleared:
				# A twin slot's survivor keeps it alone; with none it is a plain empty slot.
				var standing: Array = members.filter(func(x) -> bool: return x != null and x.alive())
				rank[col] = standing[0] if not standing.is_empty() else null
				twins.erase(key)


## What a kill brings back (Ryan, 7 November, the order of a spend: "hit(s) - riders per hit -
## check death - end spend - revive/split"): every foe getting back up and every split's
## arrivals, once the spend that felled them is done, so nothing the spend does meets them;
## outside a spend (a foe's own tick) the moment its slot is clear and the Mines of the falls have
## blown. A foe getting back up does so once, whole, in the slot it fell from (Ryan, 26 October:
## "just like the gel splitting. It makes clearing that column harder"), its round over; then a
## split steps up (the Gel's halves, in its place).
func _release_returns() -> void:
	if _risers.is_empty() and _splitters.is_empty():
		return
	var risen := _risers
	var splits := _splitters
	_risers = []
	_splitters = []
	for rs in risen:
		var back_up: Foe = rs[0]
		Effects.remove(back_up, "risen")
		back_up.hp = back_up.hp_max
		back_up.target = null
		back_up.modifiers.clear()
		log.append("%s falls, and gets back up" % back_up.display_name)
		returned.append({"foe": back_up, "how": "rises"})
		back_up.fresh = true
		var held := foe_at(rs[1], rs[2])
		if held != null and held != back_up:
			# Its other half kept the slot: it stands again beside it, the pair whole.
			_set_contents(Vector2i(rs[1], rs[2]), [held, back_up])
			continue
		if back_up.is_massive():
			back[rs[2]] = back_up
		_place(back_up, rs[1], rs[2])
	for sp in splits:
		var before := field_foes().size() + reinforcements.size()
		_split(sp[0], sp[1], sp[2])
		if field_foes().size() + reinforcements.size() > before:
			returned.append({"foe": sp[0], "how": "splits"})
	_refresh_kin()
	_refresh_guards()


## The reinforcement phase. Ranks hold: a front foe only ever stands in the front, a back
## foe only in the back, so the question "how is that ghoul hitting me from the back row"
## never comes up. Massive foes need a whole empty column and take both slots. Empty slots
## fill left to right, front rank first, each taking a random foe of the right rank from
## those waiting; the rest keep waiting.
func _first_deployment(random: bool = true) -> void:
	var placed := 0
	for col in range(columns):
		if front[col] == null and back[col] == null:
			var i := _reinforcement_index_massive()
			if i >= 0:
				var f: Foe = reinforcements.pop_at(i)
				_place(f, 0, col)
				back[col] = f
				placed += 1
	var slots: Array = []
	for col in range(columns):
		if front[col] == null:
			slots.append([0, col])
		if back[col] == null:
			slots.append([1, col])
	for slot in slots:
		var want_back: bool = slot[0] == 1
		var choices: Array = []
		for i in range(reinforcements.size()):
			if not reinforcements[i].is_massive() and reinforcements[i].prefers_back == want_back:
				choices.append(i)
		if choices.is_empty():
			continue
		var f: Foe = reinforcements.pop_at(choices[rng.randi_range(0, choices.size() - 1)] if random else choices[0])
		_place(f, slot[0], slot[1])
		placed += 1
	if placed > 0 and round > 0:
		log.append("%d reinforcement%s step%s in" % [placed, "s" if placed != 1 else "", "" if placed != 1 else "s"])
	_refresh_kin()


## The first deployment by a layout (the long wall brief, section 6): each cell, front then back,
## left to right, takes the first foe waiting of the kind it names, a massive one filling its
## column; a cell that names none, or whose kind has none left waiting, stands empty. The pack
## holds what its layout places (Battlefield.recount_by_layout), so none is left over; one
## that is (a foe the layout cannot stand) is never dealt (begin).
func _deploy_layout() -> void:
	for cell in range(mini(layout.size(), 8)):
		var fid := str(layout[cell])
		var rank := 0 if cell < 4 else 1
		var col := cell % 4
		if fid.is_empty() or col >= columns or foe_at(rank, col) != null:
			continue
		for i in range(reinforcements.size()):
			var f: Foe = reinforcements[i]
			if f.content_id != fid:
				continue
			if f.is_massive() and (rank != 0 or back[col] != null):
				break
			reinforcements.remove_at(i)
			_place(f, rank, col)
			if f.is_massive():
				back[col] = f
			break
	_refresh_kin()


func _reinforcement_index_massive() -> int:
	for i in range(reinforcements.size()):
		if reinforcements[i].is_massive():
			return i
	return -1


func _place(f: Foe, rank: int, col: int) -> void:
	f.rank = rank
	f.column = col
	if rank == 0:
		front[col] = f
	else:
		back[col] = f


func _check_outcome() -> void:
	if live_mechs().is_empty():
		outcome = Outcome.DEFEAT
		_finish()
	elif field_foes().is_empty() and reinforcements.is_empty():
		outcome = Outcome.VICTORY
		_finish()


## Damaged components are NOT restored here: they are repaired in the hangar. Skirmish-long
## and timed effects end.
func _finish() -> void:
	state = State.DONE
	# Shield past the maximum is the round's buffer, so it fades as the fight ends, mid-turn
	# included, never carried onto the map (the mechanics audit, 25 October: only the round's end
	# trimmed it).
	_trim_overshield()
	round_holds = []
	for ms in mechs:
		Effects.end_skirmish(ms.unit)
