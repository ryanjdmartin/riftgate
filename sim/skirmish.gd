class_name Skirmish
extends RefCounted

## The dice skirmish. Mechs have no positions. Enemies stand in a two-rank, four-column
## formation, a pack what its eight slots hold: nothing steps into a kill's slot (no
## reinforcement inside a fight, Ryan, 6 November). The rules are docs/rules.md's.
##
## Round loop:
##   start_round()       a reboot's recovery, what cooling and regen are granted, roll every live
##                       mech's die, telegraph foe intents
##   reroll([...])       up to REROLLS_PER_ROUND times, any subset of unspent mech dice,
##                       before or after spending others: a low damage roll is information;
##                       a reroll always lands on a different face (see Die.reroll)
##   assign(i, target)   spend a mech's face on a foe (attacks) or a mech (shield, vent);
##                       a kill clears its slot at once; a decided fight ends at once
##   end_round()         the player's turn ends: a machine's Ablating takes its points, the
##                       shield first, and loses a stack, Scorched goes, then heat over the cap
##                       burns hull; then foes act, each after its own ticks, the dead are cleared, mech statuses tick, a
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
## magazine); a passed turn's release fires its heat as its shots and pays none of its own (FREE:
## the Whip Scorpion's). Passed as an `int`, as every enum here is (CLAUDE.md).
enum Pays { HEAT, AMMO, FREE }

const SQUAD_SPOTS := 4   # the squad's spots across the floor, one under each of the foes' columns (the screen draws them)
const DEFAULT_COLUMNS := 4   # the formation's width (Ryan, 23 September: four plays better than three)
const REROLLS_PER_ROUND := 2   # two since 6 November (Ryan: a reroll gained is worth more, and two is the standard; a trial)
## The shapes a foe past a strike's target stands in (area by shape, numbered: Ryan, 28 October),
## each its own number in place of the roll (area_shapes, area_number).
const AREA_ROW := 1      # beside the target in its rank: Spread's, Splash's
const AREA_COLUMN := 2   # the other rank of its column: Penetrate's, Splash's
const AREA_ALL := 3      # any other foe a reach over every foe adds: nothing
const AREA_CHAIN := 4    # every other Shocked foe on the field: Chain's conductors (28 October)
const AREA_SIDE := 5     # the foe to the right of the target in its rank: the Macaque's Beam Rifle's blow, beside any area's (19 November)
## A spend's hits in the order they land (_hit): the entry's strikes, the sword's hit again after
## each (the Macaque's Beam Sword, 19 November), and a Ricochet's after them all.
const HIT_STRIKE := 0
const HIT_AGAIN := 1
const HIT_BOUNCE := 2
static var overheat_scale: int = 1   # hull an overheat burns a point of heat past the maximum; tools/balance.gd's --overheat sets it for one run's what-if (30 October)
## The Phased trial (Ryan, 20 November: "Set the debug toggle for phased"; the reactive form of
## docs/domain_statuses_proposal.md, section 5): a debug build's TRIALS → PHASED and RIFTGATE_PHASED
## set it (Settings.field_trial). At once, a machine's Phased lands as its entry is spent and stands
## until the round ends, and every foe whose pick it was picks again (_phase_at_once); off, it lands
## as the round ends and stands through the next, the game's. A foe's Phased lands as the round
## ends either way: the proposal's reading, under which a ghost plays as it does today.
static var phase_at_once: bool = false
static var pilot: Dictionary = {}   # chassis id -> heat it gains as each round opens, a what-if for tools/balance.gd's --pilot (the Whip Scorpion's pilot light, 3 November); never content
# One more what-if on the overheat (Ryan, 30 October), set by tools/balance.gd for one run: every
# overheat Corrupts the component that took the gauge past the maximum, so many stacks
# (--overheat-corrupt N).
static var overheat_corrupt: int = 0
## The reboot, the shield's and the heat's rule (Ryan, 13 November; folded in on his go of 15
## November: "Go ahead on the fold and build"; docs/briefs/refit_pass.md, section 22, has his
## words and the spec line by line):
##   - A chassis has no shield regen and no cooling of its own; a module, a passive or a status
##     may grant either (shield_regen_of, cooling_of).
##   - A machine that has spent nothing this turn may reboot (reboot_mech): its shield goes to
##     nothing at once, and as the next round opens its heat is nothing and its shield whole.
##     Nothing forces one.
##   - Heat past the maximum stays (MechState.overheat_stacks), and at the end of the player's
##     turn every point of it burns a point of hull, every turn it stands ("the overheat damage
##     stacks, damages the hull every turn for the total stacks, and keeps building until the
##     player is essentially forced to reboot, or die").
##   - The first time a machine ends its turn past its maximum since its last reboot its shield
##     breaks, and whatever an overheat sets off fires: once between reboots.
##   - A shield at nothing is broken, whatever took it there, its own machine's spend or cost
##     included ("you can break yourself"), and gains no shield by any method until the reboot.
##   - A Barrier is a buff in front of the gauges and is untouched by any of it.


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
	var free_rerolls: int = 0   # rerolls of this die alone left this round, from a passive, on top of the team's
	var ammo: int = 0           # the magazine (the Musk Ox's Desublimation Forge): a resource beside heat, never a status
	var ammo_max: int = 0       # its size; 0 for a machine that forges nothing
	var hot_entry: int = -1     # the entry whose spend last took the gauge past its maximum this turn (the overheat's what-ifs)
	var spends: int = 0             # the entries it has spent this turn: a reboot is for a machine that has spent nothing
	var rebooting: bool = false     # it gave this turn to a reboot: its heat went as its shield dropped, it is bare through the enemy's turn, and its shield is back as the next round opens
	var shield_broken: bool = false # its shield has stood at nothing since its last reboot: it gains none by any method until the reboot's recovery
	var overheated: bool = false    # it has overheated since its last reboot: one overheat, and one shield broken by it, between reboots
	var killed_round: bool = false  # an attack of its own killed this round: what its passive reads as the round ends (on_round_kill: the Ammit's flare)
	var offhand: int = -1           # the form its offhand holds, by its place in the cycle (Effects.offhand_forms: the Macaque's); -1 for none
	var parried: int = 0            # what a Barrier and its armour have kept off foes' blows while its Parry stands this round (the Beam Buckler's)

	## The heat it carries past its maximum, a stack a point (the reboot's Overheated).
	func overheat_stacks() -> int:
		return maxi(0, heat - heat_max)

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
	var heat := 0                   # the spend's heat through the pipeline, once a spend
	var vent := 0                   # what the firer's modifiers vent off it
	var dealt := 0                  # hull the blows took off foes standing, for the tally
	var total := 0                  # what the hits landed on their own foes, for the log and the screen
	var base := 0                   # their numbers before the pipeline, for the screen's flash
	var armoured := 0               # what the target's armour took off, for the log
	var fired := 0                  # what Vents all fired into every blow, for the log
	var vented_all := 0             # the heat Vents all emptied, for the log
	var reached: Array = []         # every foe the blows reached, felled or not (the casings' refund)
	var thawed := 0                 # Cryo stacks the hits spent, cooling the hitter once its heat lands (_pay_hits)
	var damaged := 0                # the foes the blows took HP off (the on_damage trigger's read)
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
## screen: {mech, heat, blows (spend_blows' shape)} each. Cleared as a turn ends.
var releases: Array = []
var _shoved: Dictionary = {}   # Foe -> true: the front-rank foes this spend has driven into the rank behind (the Juggernaut Drive), once a spend
## The fight's share of the run's Sponsorship measures (the bible's Sponsorship row; tallied 21
## October, never shown live): damage the team took on shield and armour, dice spent on
## entries that deal damage and on entries that deal none.
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
## The machine whose spend, or whose passed turn's release, is under way: the one that makes
## the kills its death check clears, as the kill trigger reads them (_after_kills). Null
## outside one: a tick's kill, a Mine blowing in the enemy's turn and a foe's own burst are
## nobody's. A fall's curse lands on it (_last_act).
var _killer: MechState = null
var _mended: Foe = null   # the foe a move's heal mended, for a cleanse that follows it in the same move (the Cleric's Cure, one patient); cleared as each move's first step begins
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
## be timed to the animation across the board"): {foe, strike (from 0, a shove after the last),
## taken (what the blow took off its HP), hp (after it), kind ("strike", "ricochet", "area",
## "chain", "spill", "shove" or "mine")}, a blow on a foe an earlier hit felled included. Cleared as a
## spend begins; the rules never read it.
var spend_blows: Array = []
## The foes the latest spend at a foe reached, felled or not (Hits.reached): what a grant on its
## own machine counts a stack for (Face.self_statuses' per_foe). The rules never read it otherwise.
var _reached_last := 0
## The zap the spend in hand paid for (the Buzzard's: _pay_zap), added to its every blow; 0 between spends.
var _zap_now := 0
## Every special of the last enemy turn (a defend, buff or debuff in place of a blow), for
## the screen to announce on its plaque in order: {foe, name, kind, seq}.
var turn_specials: Array = []
var _seq: int = 0   # the order of the turn's blows and specials, shared by both lists
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
## Every machine its Ablating took from as the player's turn ended, for the screen to land
## before the overheats: {mech (index), points, shield_lost, hull_lost, shield, hull}.
var ablations: Array = []
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
## Rerolls a foe's roar has cost the team for the coming round.
var reroll_debt: int = 0
## The rerolls a drain took from this round, as it opened: what the REROLL button's note says
## while the round lasts (Ryan, 15 November: "There should be an effect on the reroll button
## when this happens"). The count itself is rerolls_left.
var drained: int = 0
## The drains that landed in the enemy's turn just played, for the screen to strike the REROLL
## button as each lands: {foe, value, seq}.
var turn_drains: Array = []
## The team's rerolls banked as the last player's turn ended (Maverick's Playbook, the Giant
## Petrel's; built 30 October), back at the next round's start while a banker fights.
var banked: int = 0
## Makes a foe from a content id, for a summoning action; set by the battle (the content
## database), left empty by tests, in which case a summon calls nothing up.
var foe_factory: Callable = Callable()
## The undo (Ryan, 2 November, the randomness pass: "undo to your last roll"): every spend and
## reroll since the last draw from the stream can be taken back, in the order made, the fight
## put back as it was before each. A draw is the floor, since a draw taken back would show its
## result for free: the round's roll, a reroll that draws, a spend that draws inside itself
## (Rapid's reroll, a roll again). A stepping die draws nothing, so
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
	# The offhand (the Macaque's, Ryan, 19 November): every fight opens on its first form.
	for ms in live_mechs():
		_take_up_form(ms, 0)


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


## Is the machine Phased (cannot be damaged or targeted by anything until the round's end; it
## acts, and what its own acts cost it is its own)?
static func is_phased(ms: MechState) -> bool:
	return ms != null and Effects.has(ms.unit, "phased")


## Is the machine Swallowed (a foe's swallow, 30 October: out of the fight until its rounds run
## out or its swallower falls)?
static func is_swallowed(ms: MechState) -> bool:
	return ms != null and Effects.has(ms.unit, "swallowed")


## Is the machine out of reach: Phased or Swallowed? Nothing reaches it, neither side may target
## it (it may spend on itself), and nothing damages it: no blow, no tick's point, no burn and no
## bite of a piece of its own (a Volatile's, a corrupted entry's), the heat past its maximum
## staying for the turn it is back. The two part on time (Ryan, 16 November). A Phased machine
## acts, and everything it carries ticks: "It doesn't take damage but it's a way of waiting out
## a debuff". A Swallowed one is out of play, its die spent, and everything it carries pauses
## (paused): "Swallowed it's out of play so everything should pause".
static func is_out(ms: MechState) -> bool:
	return is_phased(ms) or is_swallowed(ms)


## Is everything this machine carries paused (Swallowed)? No stack fades, halves or pays, no
## timed status runs out but the swallow itself (each moves a round later for every round's end
## it sits out: Effects.pause_round), nothing of its own cools, regenerates or fires, a buff of
## its own holds nothing on the field, and it burns nothing: the rounds it sat out never came
## for it. Let go as its swallow's rounds run out, it is back before that round's end is read,
## the end it was owed from the round it was taken in; let go sooner (its swallower felled or
## hurt), it goes on from where it stood. Two things are no clock and reach it all the same: an
## event of its fight (a foe felled banks its count), and a reboot it had begun, which recovers
## as the next round opens, the second half of a turn it gave before it was taken.
static func paused(ms: MechState) -> bool:
	return is_swallowed(ms)


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


## Every kill a death check counts, whoever or whatever made it (on_foe_killed; the Ammit's Essence,
## Ryan, 12 November: "Souls granted by any kill"): each machine standing in the fight fires its
## passives once for each foe that fell, which is what the trigger is and no option of an
## effect's, so an ally's kill, an Ablate tick and a Mine's blast all feed it, and a foe getting
## back up, a part or a Bomb's burst, no kill, feeds nothing. One line in the log a machine,
## however many fell.
func _foes_fell(n: int) -> void:
	if n <= 0:
		return
	for ms in live_mechs():
		var parts: Array[String] = []
		var granted := {"statuses": [] as Array[String]}
		for i in range(n):
			var got := Effects.fire(ms.unit, "on_foe_killed")
			for part in _apply(ms, got):
				if not parts.has(part):
					parts.append(part)
			for status_name in got["statuses"]:
				if not (granted["statuses"] as Array).has(status_name):
					(granted["statuses"] as Array).append(status_name)
		if not parts.is_empty():
			log.append("%s: %s, %s" % [ms.unit.display_name, "a foe falls" if n == 1 else "%d foes fall" % n, ", ".join(_with_counts(ms, parts, granted))])


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


## A plain blow of `amount` on a foe (the Wild Boar's shove): no keyword and no Shock read, through
## what the foe takes and its armour; nothing on a Guarded core, as every blow there. The Storm
## Petrel's zap was dealt so until its rework of 17 November.
static func plain_blow_on(foe: Foe, amount: int, by: MechState) -> int:
	if foe == null or amount <= 0:
		return 0
	return maxi(0, Effects.damage_taken(foe, amount, by.unit if by != null else null) - foe.armour_total())


## What a vent-on-fire attack adds to every blow from the heat it fires: its power_per_heat
## for each `per_heat` the machine carries right now (the Heliographic Death Ray; the Buzzard's cannon first, 28 September;
## the step a field since the stock pass, 22 October).
static func heat_bonus(ms: MechState, f: Face) -> int:
	if f == null or not f.vents_all:
		return 0
	return f.power_per_heat * int(ms.heat / maxi(1, f.per_heat))


## What a gun that fires its machine's whole shield adds to every blow from the shield it fires: its
## power_per_shield for each `per_shield` the shield holds right now, nothing on a shield at nothing
## (the Shield-burner Cannon since 18 November, Ryan: "the cannon fires its whole field").
static func shield_bonus(ms: MechState, f: Face) -> int:
	if f == null or not f.spends_shield or ms.shield_broken:
		return 0
	return f.power_per_shield * int(maxi(0, ms.unit.shield) / maxi(1, f.per_shield))


## The zap a weapon's spend at a foe would pay for now (the Buzzard's, Effects.zap_of): its damage
## when the shield holds the cost, 0 when it is short or broken, so the gun fires plain (Ryan, 11
## November: "when it can't pay it doesn't zap"). The die's number and the bot read it here.
static func zap_ready(ms: MechState, f: Face) -> int:
	if ms == null or f == null or ms.shield_broken:
		return 0
	var z := Effects.zap_of(ms.unit, f)
	if z.is_empty() or ms.unit.shield < int(z["cost"]):
		return 0
	return int(z["damage"])


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
## Brittle, a point a stack on a weapon's blow; a Guarded core's nothing) and its armour off the
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
	var add := heat_bonus(ms, f) + shield_bonus(ms, f) + hopper_bonus(ms.unit, f)   # what the entry prints from its firer, inside the pipeline
	var own := (f.missing_bonus(target) + f.consume_bonus(target)) if not f.is_debuff() else 0   # the foe's own reads, flat after it (the blow's order)
	# A split entry (the Skua's) shows a hit's blow: its base halved, rounded down, never below one, then the buffs.
	var zap := zap_ready(ms, f) if not ms.assigned else 0   # the zap it would pay for, beside Empowered's add
	var d := int(Effects.attack(ms.unit, f, split_share(f.power + add, f.split), 0, target, {"zap": zap} if zap > 0 else {})["damage"]) + own
	if target != null:
		if not f.is_debuff():
			d = Effects.damage_taken(target, d, ms.unit, true, false)   # every add and multiply it takes (its Brittle, a Guarded core's nothing) but a Shocked doubling, the foe's own chip
		d = maxi(0, d - target.armour_for(f))
	return d


## The shield an entry gives the machine it is spent on: a shield's number, or what takes it to its
## maximum (the Sutler's Hoist's full reset). The spend, the die dragged over the machine and the
## bot all read it here.
func shield_amount(_ms: MechState, f: Face, who: MechState) -> int:
	if f == null:
		return 0
	if f.kind == Face.Kind.SHIELD and f.fills_shield:
		return maxi(0, who.unit.shield_max - who.unit.shield) if who != null else 0   # the Hoist's full reset
	return maxi(0, f.power) if f.kind == Face.Kind.SHIELD else 0


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
		elif k == Face.Keyword.DISRUPT and (foe.committed or foe.immune_to("disrupt")):
			out.append(k)   # an announced follow-up holds (2 November), and so does a gather its foe is immune through: the chip struck over it
		elif k == Face.Keyword.SUPPRESS and foe.immune_to("suppress"):
			out.append(k)   # no stun lands on a foe immune to it: the chip struck over it
	return out


func shown_number_text(ms: MechState, f: Face, target: Foe = null) -> String:
	if f == null or not f.is_attack() or f.is_debuff():
		return f.number_text() if f != null else ""
	return str(shown_number(ms, f, target))


## Every live machine learns how many allies stand with it, for passives that read it.
func _refresh_allies() -> void:
	var n := live_mechs().size()
	for ms in mechs:
		ms.unit.allies = maxi(0, n - 1) if ms.alive() else 0


## The foes that will strike this mech when the round ends, in the order they act: alive,
## not suppressed, aimed at it with an attack (a foe bracing, rallying or roaring lands no
## blow), and not about to die to its Ablating first.
func attackers_of(ms: MechState) -> Array[Foe]:
	var out: Array[Foe] = []
	for f in acting_on(ms):
		if f.attacks():
			out.append(f)
	return out


## Every foe that will act on this mech when the round ends, whatever its action: alive, not
## suppressed, showing intent on it (its pick, or a blow at every machine; a special that acts
## on nobody in particular shows none: Foe.intent_on). A foe its Ablating will fell strikes
## first: its ticks come as its turn ends (16 November; at its action's start until then, when
## a doomed foe's blow was left out here).
func acting_on(ms: MechState) -> Array[Foe]:
	var out: Array[Foe] = []
	if is_out(ms):
		return out   # nothing reaches a machine out of the fight
	for f in field_foes():
		if not f.intent_on(ms.unit):
			continue
		out.append(f)
	return out


## The HP a foe's ticks leave it as its turn ends (its Ablating, then Vitriol's share): static
## numbers, so its gauge shows the loss to come (Ryan, 26 October). At 0 its ticks fell it
## once it has acted: its blow lands and its rally lands first (16 November, his four places).
func hp_after_ticks(f: Foe) -> int:
	if foe_phased(f):
		return f.hp   # its clocks run and take nothing
	return maxi(0, f.hp - int(Effects.tick_preview(f)["hp"]))


func incoming_for(ms: MechState) -> int:
	var total := 0
	for f in attackers_of(ms):
		total += foe_blow(f) * f.strikes()
	return total


## The blow a foe's move lands, as its intent shows it (Ryan, 26 October: "The intents should
## take into account incoming buffs"): its own statuses and the rallies on their way to it
## (rallies_on), one damage formula, every add on the move's own number (Foe.damage_of).
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
## Suppressed, not gathering and not stepped up this round.
func rallies_now(r: Foe) -> bool:
	if r == null or not r.alive() or r.fresh or r.is_suppressed() or r.gathering() or _acted.has(r):
		return false
	return not Foe.is_attack_action(r.action) and str(r.action.get("effect", "")) == "rally"


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
## "splits" for one whose halves step up, "" for none)}}}; the fight itself is untouched.
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
	# The rerolls the die in hand would bring the team, or cost it (a piece that grants one, a
	# kill's, an ally use's price): the REROLL button lights on a gain (Ryan, 15 November: "We
	# can communicate by highlighting the reroll button as part of the preview, if one will be
	# granted").
	var rerolls_gained := copy.rerolls_left - rerolls_left
	var events: Array = copy.turn_events.duplicate()   # a last act the spend set off lands now
	var over: Array[int] = []
	var ablated: Array[int] = []
	var standing: Array[int] = []
	over.resize(mechs.size())
	ablated.resize(mechs.size())
	standing.resize(mechs.size())
	if copy.outcome == Outcome.NONE:
		copy._end_player_turn()
		for o in copy.overheats:
			over[int(o["mech"])] += int(o["over"])
		for a in copy.ablations:
			ablated[int(a["mech"])] += int(a["points"])
	for i in range(mechs.size()):
		standing[i] = copy.mechs[i].unit.shield
	var heat_end: Array[int] = []
	for i in range(mechs.size()):
		heat_end.append(copy.mechs[i].heat)   # the gauge does not settle: what stands past the maximum stays
	var played := copy.outcome == Outcome.NONE   # a spend that wins, or a burn that wrecks the last machine, ends the fight at once
	if played:
		copy._enemy_turn()
		events.append_array(copy.turn_events)
	var shield_hit: Array[int] = []
	for i in range(mechs.size()):
		shield_hit.append(copy.mechs[i].unit.shield)
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
			"ablated": ablated[i],         # what its Ablating takes as the turn ends, the shield first
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
	return {"mechs": out_mechs, "foes": out_foes, "rerolls": rerolls_gained}


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
		if not rallies_on(x).has(r) or not x.attacks() or x.is_suppressed() or not x.intends():
			continue
		var machines := targetable_mechs().size() if x.hits_all() else 1
		total += (foe_blow(x) - x.damage_of(x.action, incoming_rally(x) - v)) * x.strikes() * machines
	return total


## What spending the entry showing would cost its owner through Corrupted stacks: nothing
## for a blank (a blank is not spent) or a die already spent.
func pending_bite(ms: MechState) -> int:
	var f := ms.face()
	if f == null or ms.assigned or f.kind == Face.Kind.BLANK or is_phased(ms):
		return 0   # a Phased machine is damaged by nothing, a bite of its own entry included
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
	if f == null or ms.assigned or is_phased(ms):
		return 0   # a Phased machine pays no hull for its spend (Ryan, 16 November: "I think we block the damage as a feature, and see how bad it is once we have real hull cost pieces that matter")
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
## whoever weighs one. Its Ablating ticks first, as the player's turn ends: the shield, then the hull, none
## for a machine out of the fight. Then each foe's blows walk the shield they meet (blows_on, the
## blow that lands' own arithmetic). Heat is what the gauge holds and a seal's, before the enemy
## acts (11 October), the foes adding none (their fire leaves Ablating, which is damage, and
## Scorched, which taxes the next turn's spends), then the heat a passive banks with their blows
## (the Whip Scorpion's).
func forecast(ms: MechState, extra_shield: int = 0) -> Dictionary:
	var shield := mini(maxi(ms.unit.shield_max, ms.unit.shield), ms.unit.shield + extra_shield)
	var hull := ms.unit.hull
	var ablated := 0 if is_out(ms) else int(Effects.tick_preview(ms.unit, true)["hp"])
	var off_shield := clampi(shield, 0, ablated)
	shield -= off_shield
	hull -= ablated - off_shield
	# Its Regenerating pays as its turn ends, after the Ablating and before the foes strike (16
	# November): a point of shield a stack, none for a shield that is broken or that the tick
	# has just taken to nothing, none while it is Swallowed.
	var regrow := 0 if paused(ms) else Effects.regrowth(ms.unit)
	if regrow > 0 and not ms.shield_broken and not (off_shield > 0 and shield <= 0):
		shield = mini(maxi(ms.unit.shield_max, shield), shield + regrow)
	var incoming := 0
	var component_risk := false
	var walk := {"shield": shield, "barrier": Effects.has(ms.unit, "barrier")}
	var blows := 0
	for f in attackers_of(ms):
		incoming += foe_blow(f) * f.strikes()
		blows += f.strikes()
		for r in blows_on(ms, f, walk):
			hull -= int(r["through"])
			if int(r["through"]) > 0 and destroys(f, ms):
				component_risk = true
	shield = int(walk["shield"])
	var heat_end := ms.heat + seal_heat(ms)
	var over := maxi(0, heat_end - ms.heat_max)
	if is_out(ms):
		over = 0   # one out of reach neither burns nor overheats (_burn_stacks); a rebooting machine has vented, and burns what it carries like any
	hull -= over * overheat_scale
	# The gauge does not settle: what stands past the maximum stays, and burns again.
	var heat_after := heat_end + Effects.heat_per_blow(ms.unit) * blows
	return {
		"incoming": incoming,
		"ablated": ablated,           # what its Ablating takes as the turn ends, the shield first
		"shield_after": shield,
		"hull_after": hull,
		"heat_end": heat_end,       # the gauge as the turn ends, uncapped: what the burn reads
		"heat_after": heat_after,   # the gauge after the round: what the turn left on it, then the foes' heat
		"overheat": over,
		"component_risk": component_risk,
		"destroyed": hull <= 0 and ms.alive(),
	}


## Whether this foe's blow, reaching this machine's hull, destroys the entry its die shows
## (Destroy, the foes' rider; Ryan, 15 November: "destroys the visible face if it damages hull at
## all"): its move carries the rider, no Ward turns it away, and a component shows that no
## passive holds (a blank or a broken entry has nothing left to break). The forecast's read;
## the blow itself is _strike's.
func destroys(f: Foe, ms: MechState) -> bool:
	if f == null or not f.has_keyword(f.action, "destroy") or Effects.has(ms.unit, "ward"):
		return false
	var showing := ms.face()
	return showing != null and showing.kind != Face.Kind.BLANK and not Effects.no_destroy(ms.unit, showing)


## One foe's blows on a machine as they would land now, in order: each through what the
## machine takes (damage_taken), a Barrier that stands taking the first that deals anything,
## each against the shield the one before left. `walk`
## carries the shield and the Barrier from blow to blow, and from foe to foe for a caller
## walking every attacker: {"shield": int, "barrier": bool}, updated.
## Returns each blow's arithmetic (_blow_on's).
## A purge its move lays before the blow (purge_ahead) is read as landed: the machine's
## buffs are held, purged for the reckoning and given back before this returns, and the walk
## carries the stacks taken (`purged`) to the foes after it.
func blows_on(ms: MechState, f: Foe, walk: Dictionary) -> Array:
	var out: Array = []
	var purged := int(walk.get("purged", 0)) + purge_ahead(f, ms)
	var held: Array = []
	if purged > 0:
		held = _hold_buffs(ms.unit)
		Effects.purge(ms.unit, purged)
		walk["purged"] = purged
		walk["barrier"] = bool(walk.get("barrier", false)) and Effects.has(ms.unit, "barrier")
	for s in range(f.strikes()):
		var r := _blow_on(ms, foe_blow(f), f, int(walk["shield"]), bool(walk.get("barrier", false)))
		if bool(r["barred"]):
			walk["barrier"] = false
		walk["shield"] = r["shield"]
		out.append(r)
	if purged > 0:
		_give_back(ms.unit, held)
	return out


## The stacks a foe's move purges from this machine before its blow lands (its `before`
## steps: the Pilgrim's knife, 18 November), nothing where a Ward turns a purge away.
func purge_ahead(f: Foe, ms: MechState) -> int:
	if f == null or ms == null or Effects.has(ms.unit, "ward"):
		return 0
	var n := 0
	for st in Foe.before_of(f.action):
		if str(st.get("effect", "")) == "dispel":
			n += maxi(1, int(st.get("value", 0)))
	return n


## A unit's modifiers and their stacks as they stand, for a reckoning that changes them and
## gives them back (blows_on's purge ahead of a blow): the list and each stack count.
static func _hold_buffs(u) -> Array:
	var stacks: Array = []
	for m in u.modifiers:
		stacks.append(m.stacks)
	return [u.modifiers.duplicate(), stacks]


static func _give_back(u, held: Array) -> void:
	var mods: Array = held[0]
	for i in mods.size():
		mods[i].stacks = int(held[1][i])
	u.modifiers = mods


## One foe's blow on a machine, the arithmetic the blow that lands (_damage_mech) and the
## forecast's walk (blows_on) share, changing nothing: what the machine takes of `amount`
## (damage_taken, the striker read for its statuses, a plate that stands with the shield reading
## `shield`, the shield this blow meets), a Barrier standing (`barrier`) taking it whole if it deals
## anything, then the shield, the armour (the machine's and
## what it holds against the striker's rank) and the hull (_blow). Returns _blow's dictionary
## with `amount` (the blow as it arrives, before a Barrier) and `barred`. No blow of a foe's
## passes a shield or armour (Ryan, 15 November: "Sure, let's cut breach").
func _blow_on(ms: MechState, amount: int, source: Foe, shield: int, barrier: bool) -> Dictionary:
	var arrived := Effects.damage_taken(ms.unit, amount, source, false, true, maxi(0, shield))
	var barred := arrived > 0 and barrier
	var r := _blow(shield, ms.unit.armour, 0 if barred else arrived)
	r["amount"] = arrived
	r["barred"] = barred
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


## Is this foe out of the team's reach right now? A foe Aloft (the Roc while its Stoop gathers,
## Ryan, 16 November: "the stoop can make it untargetable ... it should still take damage from
## its riders, unlike phased"; 17 November: "the roc doesn't get splashed while aloft"): it is
## no target of a spend, a Swap's second included, and nothing a spend lands with no aim
## reaches it either, a neighbour's Spread, a blow or a mark at every foe, a Chain's arc, a
## Mine's blast beside it, a web's catch, a spill or a shove from the foe in front. What it
## carries is its own: its Ablating and Vitriol tick and damage it, a web on it bursts on it
## and a Mine on it blows on it. A Phased foe is out of reach the same way (foe_phased), and
## nothing damages it besides. Every list of the foes a spend reaches is read through here
## (reached_by, area_shapes, shocked_foes, mine_reach, web_catch), so the bot and the screen
## read the same.
static func out_of_reach(foe: Foe) -> bool:
	return foe != null and (Effects.has(foe, "aloft") or Effects.has(foe, "phased"))


## Is this foe Phased (Ryan, 15 November: "I think we give this to the foes too"; "Phased on
## foes can be less strict since it's balanced around their kit and theme"; 16 November:
## "Phased foes act")? It fades as the round its move lands in ends (_land_phases) and is back
## as the next one ends: out of the team's reach meanwhile, with an aim or without, and
## damaged by nothing, what it carries included, whose clocks run all the same. It acts, and
## its own side still reaches it, a rally or a mend: less strict than a machine's, as he
## allowed. Never the last foe standing, and never two rounds running.
static func foe_phased(foe: Foe) -> bool:
	return foe != null and Effects.has(foe, "phased")


## Would a step that fades this foe (`phase`) lay its wait now? Never on one Phased already or
## waiting for it, so none is out two rounds running: the step's own rule, and the intent's
## read of it, so its chip wears the mark only on a round the fade would land.
static func fade_lands(foe: Foe) -> bool:
	return foe != null and not Effects.has(foe, "phased") and not Effects.has(foe, "phasing")


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
		if foe != first and foe != pair and foe.alive() and (carries or not foe.is_massive()) and not out_of_reach(foe):
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
	return f != null and Effects.effective_face(ms.unit, f).swaps


## Whether this machine's Swap carries a rider beside it (the Combat Translocator's Shock; Ryan,
## 11 November: "Translocator should still target two, always ... maybe you want to target two
## things and not have them move, just shock both of them"): such an entry may name a massive
## foe as either target, which stays where it stands, the rider landing on both all the same.
func swap_carries(ms: MechState) -> bool:
	var f := ms.face()
	if f == null:
		return false
	var ef := Effects.effective_face(ms.unit, f)
	return ef.swaps and not ef.keywords.is_empty()


func targets_for_face(ms: MechState, f: Face) -> Array[Foe]:
	var out: Array[Foe] = []
	if f == null or not f.is_attack() or not can_fire(ms, f) or cannot_pay(ms, f):
		return out   # a dry gun on a forging machine (the Musk Ox's), or an entry whose price its machine cannot pay (a shield cost, a count it spends), has nothing it may be spent on
	# Reach: direct hits the front and any exposed column's back; indirect hits everyone, and a
	# reach over every foe is dropped on any. A foe already killed this round still stands until the dead
	# are cleared, but it is no target: a die spent on it would be wasted.
	var anyone := reach_of(ms, f) != Face.Reach.DIRECT
	for col in range(columns):
		for foe in slot_foes(0, col):
			if foe.alive() and not out.has(foe) and not out_of_reach(foe):
				out.append(foe)
		for foe in slot_foes(1, col):
			if not foe.alive() or out.has(foe) or out_of_reach(foe):
				continue
			if anyone or in_direct_reach(foe):
				out.append(foe)
	var ef := Effects.effective_face(ms.unit, f)
	# A Swap moves its target, and a massive foe fills its column and stays (the Dingo's row).
	# A Swap that carries a rider beside it may still name a foe it cannot move (the Combat
	# Translocator's Shock, Ryan, 11 November: "not dead versus ... massives and bosses that can't
	# be swapped"), with its second target as ever.
	if ef.swaps and ef.keywords.is_empty():
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
		# An entry that spends a count for its stacks (the Quintessence Tap): the die shows what it would
		# take now, and so what it would grant; with none to take it shows its most, struck.
		if sf == f:
			sf = f.duplicate_face()
		sf.buff_stacks = spend_take(ms, sf)
	if sf != null and sf.passes_heat:
		# An entry that passes its machine's heat for its stacks (the Puffin's dump): what the heat it
		# carries now would grant.
		if sf == f:
			sf = f.duplicate_face()
		sf.buff_stacks = ms.heat / maxi(1, sf.heat_per_stack)
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
	drained = REROLLS_PER_ROUND + from_bank - rerolls_left   # what the drains took of this round's, never more than it had
	if from_bank > 0:
		log.append("the bank carries %d reroll%s" % [from_bank, "" if from_bank == 1 else "s"])
	if reroll_debt > 0:
		log.append("the roar costs the team %d reroll%s" % [reroll_debt, "" if reroll_debt == 1 else "s"])
	reroll_debt = 0
	last_roll.clear()
	# The player's side's turn opens: what lasts until then goes, every stack at once (a
	# machine's Armoured, from a buff, a brace or the hopper; Ryan, 16 November: "Armoured we
	# should change so its end is symmetrical on both sides. Probably means until "start of its
	# next turn.""), as a foe's goes when the foes' turn opens. Before the hopper plates again
	# and before the foes announce, so their blows are drawn against the armour that will stand.
	for ms in mechs:
		if not paused(ms):
			_parry_returns(ms)   # what its Parry counted last round stands as the next weapon's add, before the Parry goes with its turn's opening
			Effects.turn_opens(ms.unit, round)   # its turn starts: Armoured, a Barrier and a Ward go, its Brittle halves, and an Exposed whose round is past falls
	# The turn begins with what cooling a machine is granted (a module's, a passive's, a
	# status's: a chassis has none of its own since the reboot), one log line for all.
	var cooled: Array[String] = []
	for ms in mechs:
		# A swallowed machine cannot act while it is out (30 October): its die is spent before it rolls.
		ms.assigned = is_swallowed(ms)
		ms.spends = 0
		if not ms.alive():
			continue
		# A reboot's recovery: the machine that gave its last turn to one opens the round with its
		# shield whole, before anything cools or regenerates and before the foes pick. Its heat
		# went as its shield dropped.
		if ms.rebooting:
			_recover(ms)
		# A sealed machine's cooling stops (the Polar Bear's Lockdown, 20 October): opening or
		# a reboot is its way down.
		var drop := 0 if Effects.is_sealed(ms.unit) or paused(ms) else mini(ms.heat, cooling_of(ms))
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
		if ms.ammo_max > 0 and round > 1 and not paused(ms):
			_reload(ms, int(Effects.forge_rule(ms.unit).get("per_round", 0)), "")
	if not cooled.is_empty():
		log.append("cooling: " + ", ".join(cooled))
	_refresh_allies()
	# The shield regen a machine is granted (a chassis has none of its own since the reboot):
	# up to its maximum, after the cooling and before the round-start passives, a shield gain
	# like any other (on_shield_gain fires), one log line for all. A sealed machine's regen runs:
	# nothing stops it, where the seal stops its cooling.
	var regened: Array[String] = []
	for ms in live_mechs():
		var gained := 0 if paused(ms) else _gain_shield(ms, shield_regen_of(ms))   # a broken shield takes none
		if gained > 0:
			regened.append("%s +%d" % [ms.unit.display_name, gained])
	if not regened.is_empty():
		log.append("shield regen: " + ", ".join(regened))
	# The hopper grants its Armoured for the round, what the loads it holds are worth (the Honey
	# Badger's, Ryan, 10 November: "returns at the start of his turn since its granted by the
	# funnel bar"): last round's went at the round's end as every machine's Armoured does, and a
	# Purge may have taken it sooner. Before the foes announce, so their blows are drawn against it.
	for ms in live_mechs():
		var plated := 0 if paused(ms) else Effects.plate_round(ms.unit)
		if plated > 0:
			log.append("%s's hopper plates it: %s ×%d" % [ms.unit.display_name, Effects.STATUS["braced"]["name"], Effects.plated(ms.unit)])
	# Every foe announces its move for the round: which action, at whom. Chosen now, before
	# the player acts, so the intent chips and the forecast are exact. The move first, from
	# the ones its conditions allow (never the same special twice running), then its pick, each
	# foe on its own, when the move is aimed at one machine: a move at every machine or at
	# nobody draws none (Ryan, 17 November). The foes draw in the order they strike and never
	# over-commit (Ryan, 24 October, after Slice and Dice): a machine the blows already drawn
	# would wreck is skipped while another stands.
	_refresh_kin()
	var ahead := {}
	var announced: Array = []   # the foes whose move for this round is out, in the order they strike
	for f in field_foes():
		f.fresh = false   # a half that stepped up last round acts from this one
		# A move gathered last round holds, and so does its pick while the machine stands.
		var carried := not f.pending.is_empty()
		_choose_foe_action(f, announced)
		announced.append(f)
		if not f.aims_at_one():
			f.target = null   # nothing of it lands on one machine: no pick, and no draw
		elif not (carried and f.target != null and (f.target as MechState).alive() and not is_out(f.target as MechState)):
			f.target = _pick_mech_target(f, _doomed(ahead))   # a pick that fell, or went out of reach as the round ended (Phased), is drawn again
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
## so the swing after the roar can be counted on). Nothing legal falls back to its blow, one
## whose own condition holds before any other.
## `announced` is the foes whose move for this round is already out, as the round's opening
## hands them down the strike order; unsaid, it is every foe on the field (the player's turn,
## where a Disrupt reads what a foe would turn to).
func legal_actions(f: Foe, announced = null) -> Array:
	var legal: Array = []
	var follow := Foe.follow_ups(f.actions)
	for a in f.actions:
		if follow.has(str(a.get("id", ""))):
			continue   # a follow-up comes only after the move that names it (30 October)
		if Foe.does(a, "drain_rerolls") and drain_announced(f, announced) >= REROLLS_PER_ROUND:
			continue   # the drains already out take every reroll a round gives (Ryan, 15 November: "mandragoras shouldn't try to scream away 3 rerolls, they should be smarter than that when declaring intents")
		if Foe.does(a, "swallow") and swallowable().size() < 2:
			continue   # never the last machine able to act
		if Foe.exposes(a) and (expose_announced(f, announced) or _any_exposed()):
			continue   # one at a time (Ryan, 15 November): none while another's Expose is out, nor while a machine stands Exposed, so the whole field's fire comes every other round at most
		if str(a.get("effect", "")) == "merge" and mergeable(f, a).is_empty():
			continue   # nothing of its kinds stands to take in
		if str(a.get("effect", "")) == "summon" and not _summon_has_room(f, a):
			continue   # a summoner never summons with no room (Ryan, 7 November: "a summoner should not summon if there's no space")
		if bool(a.get("refill", false)) and refill_short(f, a) < 1:
			continue   # a call back with nothing lost (the Wild Huntsman's Horn): none of its kind has fallen
		if bool(a.get("once", false)) and f.spent_once.has(str(a.get("id", ""))):
			continue   # used once this fight already
		if _when_holds(f, a):
			legal.append(a)
	if f.strikes_when_buffed and not legal.is_empty():
		# The goblins (Ryan, 20 November: "goblins only attack when they have any buff, or are
		# predicted to get one"; "If a goblin is getting a shield from its peer in the intent, it
		# should queue an attack"): with a buff on it, or one a move announced ahead of it lays on
		# it, its blows alone; with none, anything but a blow, where it has one open.
		var buffed := buffed_or_coming(f, announced)
		var kept_buffed: Array = []
		for a in legal:
			if Foe.is_attack_action(a) == buffed:
				kept_buffed.append(a)
		if not kept_buffed.is_empty():
			legal = kept_buffed
	if legal.size() > 1 and not f.last_special.is_empty():
		var kept: Array = []
		for a in legal:
			if Foe.is_attack_action(a) or str(a.get("id", "")) != f.last_special:
				kept.append(a)
		if not kept.is_empty():
			legal = kept
	if legal.is_empty():
		# Nothing legal falls back to its blow: first a blow whose own condition holds, which
		# only a rule of announcing held back (a blow that also takes a reroll past the round's
		# two, the Thief's Mug; a blow whose rider is a second Expose, the Piercing Eye's Gaze),
		# so a foe never reaches for a move its own condition shuts; then any blow at all.
		for a in f.actions:
			if Foe.is_attack_action(a) and not follow.has(str(a.get("id", ""))) and _when_holds(f, a) and not (bool(a.get("once", false)) and f.spent_once.has(str(a.get("id", "")))):
				legal.append(a)
	if legal.is_empty():
		for a in f.actions:
			if Foe.is_attack_action(a):
				legal.append(a)
	return legal


## Does any live machine stand Exposed, in reach or out of it? What the rule of announcing
## reads: a machine marked and then Phased or Swallowed is marked still.
func _any_exposed() -> bool:
	for ms in live_mechs():
		if Effects.has(ms.unit, "exposure_mech"):
			return true
	return false


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


## A summon that calls back only what its pack has lost (`refill`, the Wild Huntsman's Horn, Ryan's
## go of 20 November on "a fallen rider rides back"): how many of the kind it calls its pack stands
## short of what rode out, its pack's own lineup less those of the kind standing in the fight. A
## pack the fight does not hold (a test's bare foes) rode out with none, so nothing is short.
func refill_short(f: Foe, a: Dictionary) -> int:
	var who := str(a.get("foe", ""))
	var rode := 0
	for sq in packs:
		if sq.id == f.pack_id:
			for m in sq.member_list():
				if str(m[0]) == who:
					rode += int(m[1])
	var standing := 0
	for o in field_foes():
		if o.alive() and o.pack_id == f.pack_id and o.content_id == who:
			standing += 1
	for o in reinforcements:
		if o.pack_id == f.pack_id and o.content_id == who:
			standing += 1
	return maxi(0, rode - standing)


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


## The rerolls the other foes' announced moves would take from the team's next round: every
## live foe on the field but `f` whose move is a drain, among `announced` (every foe on the
## field when unsaid). What a foe reads before it announces a drain of its own, so the field
## never announces more than a round's rerolls.
func drain_announced(f: Foe, announced = null) -> int:
	var out := 0
	var said: Array = announced if announced is Array else Array(field_foes())
	for o in said:
		if o == f or not o.alive() or not o.on_field() or not Foe.does(o.action, "drain_rerolls"):
			continue
		if o.fresh or o.is_suppressed() or (not o.pending.is_empty() and o.charge > 0):
			continue   # stepped up this round with no move out, held this round, or still gathering: it takes nothing yet
		for st in Foe.effects_of(o.action):
			if str(st.get("effect", "")) == "drain_rerolls":
				out += maxi(0, int(st.get("value", 0)))
	return out


## Whether a foe holds a buff (what a Purge would reach, Effects.buff_stacks), or one a move of its
## own side announced ahead of it this round will lay on it: a wall beside it, a brace or a rally
## on every foe, a Ward on every foe. What a foe that strikes only when buffed reads (the goblins'
## rule). `announced` as legal_actions takes it: unsaid, every foe on the field.
func buffed_or_coming(f: Foe, announced = null) -> bool:
	if Effects.buff_stacks(f) > 0:
		return true
	var said: Array = announced if announced is Array else Array(field_foes())
	for o in said:
		if o == f or not o.alive() or not o.on_field():
			continue
		if o.fresh or o.is_suppressed() or (not o.pending.is_empty() and o.charge > 0):
			continue   # stepped up with no move out, held this round, or still gathering: it lays nothing yet
		for st in Foe.effects_of(o.action):
			var e := str(st.get("effect", ""))
			if e in ["brace_all", "rally", "ward_all"]:
				return true
			if e == "brace_beside" and foes_beside(o).has(f):
				return true
	return false


func _choose_foe_action(f: Foe, announced = null) -> void:
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
			if str(a.get("id", "")) == next and (Foe.power_status(a).is_empty() or Effects.has(f, Foe.power_status(a))):
				f.action = a
				f.committed = true   # announced a round ahead, so no Disrupt turns it (Ryan, 2 November): the first move was the window
				f.last_special = "" if f.attacks() else str(f.action.get("id", ""))
				_begin_countdown(f)
				return
	f.choose_from(legal_actions(f, announced), rng)
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


## The foe a heal mends (15 October, foes helping foes): the most hurt of its side by hull
## missing, the healer included, the first in the order they stand on a tie; null when none
## is hurt. One rule for the move and for the bot's read of it.
func heal_target(_f: Foe) -> Foe:
	var hurt: Foe = null
	for other in field_foes():
		if other.alive() and other.hp < other.hp_max and (hurt == null or other.hp_max - other.hp > hurt.hp_max - hurt.hp):
			hurt = other
	return hurt


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


## The spot machine `i` stands in across the floor (Ryan, 29 October): a squad of one or two in
## the middle spots, the outer ones left empty, a squad of three from the left; a wrecked machine
## keeps its spot. The screen draws the squad by it, and a machine faces the foes' column of its
## spot (Ryan, 11 November: "The machines are lined up, very clearly, in four columns with gaps
## for missing ones").
func mech_spot(i: int) -> int:
	return i + floori((maxi(SQUAD_SPOTS, mechs.size()) - mechs.size()) * 0.5)


## The foes' column a machine faces: its spot's, within the formation's width.
func mech_column(ms: MechState) -> int:
	return clampi(mech_spot(mechs.find(ms)), 0, columns - 1)


## The foe in front of a machine (the Photosphere Lance's; Ryan, 11 November: "The enemy directly
## in front of them gets the debuff, or if none in either rank in front, the closest column that
## does, searching left-right-left-right"): its column's front rank, then its back; else the next
## column left, then right, then two left, two right. Null with no foe standing.
func foe_in_front(ms: MechState) -> Foe:
	var c := mech_column(ms)
	var order: Array[int] = [c]
	for d in range(1, columns):
		order.append(c - d)
		order.append(c + d)
	for col in order:
		if col < 0 or col >= columns:
			continue
		for rank in [0, 1]:
			var foe := foe_at(rank, col)
			if foe != null and foe.alive():
				return foe
	return null


## What an entry lays on the foe in front of the machine it lands on (the Photosphere Lance's
## Sapped beside its Empowered), deepened by the spender's passives as any stack it lays.
func _lay_in_front(ms: MechState, who: MechState, f: Face) -> void:
	if f.front_status.is_empty() or who == null:
		return
	var foe := foe_in_front(who)
	if foe == null:
		return
	var gained := {}
	var turned := {}
	var n := _stacks_from(ms, f.front_status, f.front_stacks)
	_land_rider(foe, f.front_status, n, gained, turned)
	if not Effects.turns_mark(foe, f.front_status):
		log.append("%s lays %s ×%d on %s, in front of %s" % [ms.unit.display_name, str(Effects.STATUS[f.front_status]["name"]), n, foe.display_name, who.unit.display_name])
	_tell_turned(turned)
	for x in gained.keys():
		for sid in gained[x]:
			_foe_gained_status(x, sid, int(gained[x][sid]))


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
## before it; a spend that draws from the stream (Rapid's reroll, a roll again) is the undo's
## floor instead.
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
	_shoved.clear()
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
	var turn := turn_entries(ms, f)   # where a one-of-each machine's die may turn once this is out (the Needletail's), read before the spend
	var spent_kind := _turn_kind(ms, f) if Effects.one_of_each(ms.unit) and not f.acts_again() else 0   # the kind the Relay sends onto cooldown: 1 the weapons, 2 the equipment, 0 none (a Rapid or Instant spend, a blank)
	f = Effects.effective_face(ms.unit, f, target if target is Foe else null)   # the entry as this machine's passives make it, over the foe it is aimed at
	if f.is_attack() and (not (target is Foe) or not targets_for_face(ms, raw).has(target)):
		return false
	# A Swap takes its second target with it (Ryan, 21 October: drag to the first, drop, then
	# tap the second): another foe or an empty slot, never a massive foe.
	if f.swaps and not swap_targets(target, swap_carries(ms)).has(second):
		return false
	if f.on_machines() and not machine_targets_for(ms, f).has(target if target is MechState else ms):
		return false
	# A shield cost (Ryan, 26 October: "if you don't have the shield, the face cannot be played,
	# and overshield does cheat it out at the cost of using two actions for one effect"): taken
	# first, from the shield as it stands; short of it the entry is locked
	# (cannot_pay) and never reaches here.
	var toll := f.shield_cost
	if toll > 0:
		if ms.unit.shield < toll:
			return false
		ms.unit.shield -= toll
		_note_break(ms)   # a cost may take its own machine's last point ("you can break yourself")
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
		_note_break(ms)
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
	var killed := 0        # the foes a weapon's spend felled, arcs and spills included (a kill trigger)
	if f.kind != Face.Kind.BLANK and not f.is_weapon():
		_feed_rage(ms, f)   # a shield, a vent or equipment feeds every raging foe on the field, before it acts, so a Purge clears its own feed (3 November)
	# The spend's order (Ryan, 7 November): its hits, their riders, the death check, the spend's
	# end, then what its kills bring back; so the returns wait until the match is done.
	_holding_returns = true
	_killer = ms
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
				_gain_shield(w, amount)
				log.append("%s shields %s for %d" % [ms.unit.display_name, w.unit.display_name, amount])
				if w != ms:
					_shield_granted(ms, w, amount)
				_cleanse_with(ms, w, f)
		Face.Kind.VENT:
			var who: MechState = target if target is MechState else ms
			who.heat = maxi(0, who.heat - f.power)
			log.append("%s vents %s by %d" % [ms.unit.display_name, who.unit.display_name, f.power])
			_cleanse_with(ms, who, f)
		Face.Kind.BUFF:
			# Equipment that grants a status for the round (or more): the pipeline reads it
			# like any modifier, and end_round lets it go.
			var who: MechState = target if target is MechState else ms
			var landed: Array[MechState] = [who]   # whom it lands on, read before it does: the allies a pull reads
			if f.reaches_all:
				landed = reached_machines(ms, f)
			if f.act_again:
				# The Reveille Horn's charged form (the gun platform's engine): the ally's spent die
				# rolls again by the reroll rule, never onto the entry it spent (Ryan, 8 November:
				# "It's a roll, it should follow roll rules, like everything that rolls"), and it acts
				# again.
				_act_again(who)
				log.append("%s rallies %s: its die rolls again, and it acts again" % [ms.unit.display_name, who.unit.display_name])
			elif f.turns_die:
				# The Changeover (the Clydesdale's, Ryan, 11 November): its die turns to its other
				# battery, which stays up from fight to fight; Rapid's free roll lands on it below.
				if Effects.folds_die(ms.unit) > 0:
					var raised := Effects.turn_die(ms.unit)
					log.append("%s changes over: its %s battery is up" % [ms.unit.display_name, "second" if raised else "first"])
			elif f.team_rerolls > 0 and not (f.action_price > 0 and who != ms):
				# A reroll for the team (the Reveille Horn, the Immelmann Booster's own use; Ryan, 15
				# November, in the place of the Rallied buff: "This doesn't need to be a temporary buff
				# or a keyword"; "allow it" past the round's two): given at once, no status and no chip.
				rerolls_left += f.team_rerolls
				log.append("%s: the team gains %s" % [ms.unit.display_name, "a reroll" if f.team_rerolls == 1 else "%d rerolls" % f.team_rerolls])
			elif f.action_price > 0 and who != ms:
				# The Immelmann Booster's ally use (the Giant Petrel's, Ryan's go of 21 October; built
				# 30 October): on an ally whose die is spent, the team's rerolls pay its price, banked
				# or fresh, and the ally's die rolls again by Rapid's path, never onto the entry it
				# showed, and it acts again. The Booster's own Rapid gives the Petrel its turn back too,
				# so no turn is traded for the ally's.
				rerolls_left -= f.action_price
				_act_again(who)
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
				# A buff that spends a count of its machine's for its stacks (the Quintessence Tap, Ryan,
				# 12 November: "Consume up to 5 souls, granting 1 Empowered per soul"): as many as it
				# holds, up to its most, taken as it is spent, a stack granted a one.
				var grants := f.buff_stacks
				if not f.spends.is_empty():
					grants = Effects.spend_stacks(ms.unit, f.spends, f.spends_up_to)
					var spent_name := str(Effects.STATUS.get(f.spends, {}).get("name", f.spends))
					log.append("%s consumes %d %s: %d left" % [ms.unit.display_name, grants, spent_name, Effects.stacks_of(ms.unit, f.spends)])
				elif f.passes_heat:
					grants = _pass_heat(ms, who, f)
				for w in whom:
					if f.buff_status == "phased" and phase_at_once:
						_phase_at_once(w, src)
						_lay_in_front(ms, w, f)
						continue
					if f.buff_status == "phased":
						# Phased is granted as the round ends (Ryan, 15 November: "all sources of
						# Phased should say "at the end of this round, grant Phased""): what lands
						# now is the wait for it, on a machine that has acted or not.
						if Effects.grant_buff(w.unit, "phasing", 1, src, round) != null:
							log.append("%s buffs %s: Phased as the round ends, if it stands" % [ms.unit.display_name, w.unit.display_name])
						_lay_in_front(ms, w, f)
						continue
					var stacks := _stacks_from(ms, f.buff_status, grants)
					if stacks <= 0:
						continue   # a dump of too little heat for a stack grants nothing
					var m := Effects.grant_buff(w.unit, f.buff_status, stacks, src, until)
					if m == null:
						continue
					log.append("%s buffs %s: %s ×%d%s" % [ms.unit.display_name, w.unit.display_name, m.name, stacks, "" if f.buff_rounds == 1 else " for %d rounds" % f.buff_rounds])
					_lay_in_front(ms, w, f)
					if f.buff_status == "barrier" and w.alive():
						_fired(w, Effects.fire(w.unit, "on_barrier"), "as it gains a Barrier")   # the Wild Boar's Juggernaut Drive
					# The Reheat Uplink's roll (the Giant Petrel's, Ryan's go of 21 October; built 30
					# October): the die of the machine it lands on rolls again, never onto the entry
					# showing; a spent die rolls nothing.
					if f.rolls_target and w.alive() and not w.assigned:
						_roll_again(w)
						log.append("%s's die rolls again" % w.unit.display_name)
			_cleanse_with(ms, who, f)
			# The Puffin's pull: equipment spent on an ally takes some of its heat onto the spender,
			# once for each ally it lands on; the piece that passes heat pulls none, its heat going the
			# other way.
			if not f.passes_heat and ms.alive():
				for w in landed:
					if w != ms and w.alive():
						_pull_heat(ms, w)
			# The Retrocausal Shroud (the Baboon's, Ryan, 11 November: "Cleanse an ally. Disrupt all
			# enemies targeting it"; "Targeting all means targeting the ally"): every foe showing intent
			# on the machine, its pick or a blow at every machine, takes Disrupt, the keyword's effect.
			if f.disrupts_attackers:
				var aiming := acting_on(who)
				if aiming.is_empty():
					log.append("%s: no foe aims at %s" % [ms.unit.display_name, who.unit.display_name])
				else:
					log.append("%s disrupts the foes aiming at %s" % [ms.unit.display_name, who.unit.display_name])
					_disrupt(aiming)
			# What the buff lays on its own spender beside its grant (the Aile Assaulter's Empowered,
			# Ryan, 19 November: "Gain 1 Empowered"), once it has landed.
			if not f.self_statuses.is_empty() and ms.alive():
				_self_grants(ms, f, 0)
		Face.Kind.ATTACK:
			# The sixth shot (the Cassowary's, Ryan's kit of 18 October): the spend the count
			# lands on doubles its damage and the stacks it lays (an nth_shot rule read through
			# the pipeline); every spend at a foe counts, and a weapon's spends the machine's Spun
			# Up whole, equipment leaving it (Ryan, 26 October: "Spun up only interacts with damage").
			if Effects.nth_shot_due(ms.unit):
				log.append("%s: the %s shot counts double" % [ms.unit.display_name, Effects.ordinal(Effects.counts_shots(ms.unit))])
			var kills_before := team_kills   # the spend's kills are counted at its death check (is_kill)
			if target != null:
				# A Mine laid, the gather, the detonation and the Swap land in the rider phase,
				# before the death check, on a target the hit felled too (_spend_at).
				_spend_at(mech_index, ms, f, target, second)
			# The primers (Ryan, 2 November): a weapon fired spends a stack of Charged and of
			# Supercooled, which rode it as its keywords (Effects.effective_face); a salvo is one
			# fire, and equipment spends nothing.
			if f.is_weapon():
				_spend_primers(ms)
			killed = team_kills - kills_before
			_after_kills(ms, killed)
			# The Spindrift Salvo's kill rider (the Giant Petrel's, Ryan's go of 21 October; built 30
			# October): a spend that kills gives the team its rerolls this round, banked if unspent.
			if f.kill_rerolls > 0 and killed > 0:
				rerolls_left += f.kill_rerolls
				log.append("%s: the kill brings the team %d reroll%s" % [ms.unit.display_name, f.kill_rerolls, "" if f.kill_rerolls == 1 else "s"])
			# What the spend lays on its own spender (the Storm Petrel's lure and its branches, 17
			# November: Hardened for each foe it reached, Charged): after the primers, so a weapon
			# that grants Charged never spends the stack it has just laid.
			if not f.self_statuses.is_empty() and target is Foe and ms.alive():
				_self_grants(ms, f, _reached_last)
			if Effects.counts_shots(ms.unit) > 0:
				Effects.stack(ms.unit, Effects.STATUS["shots"], Effects.SKIRMISH, "count", 1, Effects.DECAY_NONE)
			if f.is_weapon() and Effects.remove(ms.unit, "spun_up"):
				log.append("%s: the spin is spent" % ms.unit.display_name)
			if f.is_weapon() and Effects.remove(ms.unit, "juggernaut"):
				log.append("%s: its Juggernaut Drive is spent" % ms.unit.display_name)
			# What waits on the next weapon fired goes with it, every strike of its spend having had it
			# (Ryan, 19 November: "Next weapon fired. Applies to the whole spend"): the Aile Booster's
			# buffs and the Parry's return.
			if f.is_weapon():
				for id in ["aile_boost", "aile_blitz", "aile_assault", "parry_strike"]:
					if Effects.remove(ms.unit, id):
						log.append("%s: its %s is spent" % [ms.unit.display_name, str(Effects.STATUS[id]["name"])])
			# The offhand turns (the Macaque's, Ryan, 19 November: "It cycles after a spend"; the
			# spends that carry its rider, his answer that day): every weapon and equipment spent at a
			# foe takes its next form up, a Rapid second spend riding the form after.
			if target != null and ms.alive():
				_turn_offhand(ms)
	_holding_returns = false
	_killer = null
	_release_returns()   # the spend is done with the field: what its kills bring back stands now
	if f.on_machines():
		_machine_spend_after(ms, f, target)
	# A hold on the whole field (the Quintessence Tap's, Ryan, 12 November: "No Empowered decays this
	# round. And I mean none, not ally or enemy"): the spender gains the buff that holds the status
	# the entry names (Essence Flare, its own since 15 November: "an Ammit specific buff ... even
	# though it affects the whole battlefield"), until the round's end. While a live machine
	# carries it, no unit's stacks of that status run down this round (field_holds).
	if not f.holds_all.is_empty() and Effects.ROUND_HOLDERS.has(f.holds_all):
		var flare: Dictionary = Effects.STATUS[str(Effects.ROUND_HOLDERS[f.holds_all])]
		Effects.grant_for_rounds(ms.unit, flare, "self", round)
		log.append("%s gains %s: no %s decays this round" % [ms.unit.display_name, str(flare["name"]), str(Effects.STATUS.get(f.holds_all, {}).get("name", f.holds_all))])
	# The brace (Ryan, 12 October; the Breaching Plow's in place of the Glacis): spending the
	# entry Armours its owner until its side's next turn begins, so the plate stands behind the
	# charge through the enemy's turn and goes as the next round opens.
	if f.braces > 0 and ms.alive():
		var bm := Effects.grant_buff(ms.unit, "braced", f.braces, "brace:" + f.component, round)
		if bm != null:
			log.append("%s braces: %s ×%d" % [ms.unit.display_name, bm.name, f.braces])
	# The Stoker's fire on its own firer (the stock pass's landing, 22 October): spending it
	# sets its machine Ablating, the stacks it prints, after the blow. Since Ablate took Burn's
	# place (15 November) that is a point a stack off its own shield, then its hull, as its turn
	# ends, where it was heat: a price, and fuel for no machine. A cleanse lifts it.
	if f.self_ablate > 0 and ms.alive():
		Effects.stack(ms.unit, Effects.STATUS["ablating_mech"], Effects.SKIRMISH, "self:" + f.component, f.self_ablate, Effects.status_decay(Effects.STATUS["ablating_mech"]))
		log.append("%s: its own fire, %s ×%d" % [ms.unit.display_name, Effects.STATUS["ablating_mech"]["name"], f.self_ablate])
	_shift_form(ms, f, target)
	if f.kind != Face.Kind.BLANK:
		var deals := f.is_attack() and f.power > 0
		var measure := "damaging_spends" if deals else "quiet_spends"
		sponsorship[measure] = int(sponsorship[measure]) + 1
	ms.assigned = true
	if not (f.acts_again() and Effects.one_of_each(ms.unit)):
		ms.spends += 1   # on a one-of-each machine (the Needletail's) a Rapid or Instant spend is none of its spends (Ryan, 18 November: "rapid does not consume any of the spends")
	# A cooldown (Ryan, 14 October; counted after the round of the spend since 12 November:
	# "change the count so 1 is how I intended"): the entry is dark for the rest of this round and
	# for the rounds it prints after it, shown on the die with the rounds left. Rapid's own
	# switch-off is the keyword's and never printed (Ryan, 12 November: "rapid gets its innate
	# cooldown zero back without the explicit display"): a Rapid entry, its own or the Needletail's
	# gate's, is dark for the rest of the round. Instant's darkens nothing, its roll free to land
	# on it again.
	var cd := f.cooldown_rounds()
	if cd > 0 or f.has(Face.Keyword.RAPID):
		Effects.disable_entry(ms.unit, ms.face_index, "cooldown", round + cd)
	# Rapid: the die rerolls for free (never the same entry; a copy of it may come up, so
	# stacked copies chain, each copy dark once spent), and the mech may act again; a stepping
	# die's free reroll steps it. Instant (Ryan, 12 November: "reroll after use, can land on
	# itself"): the die rolls again as the round opens, itself included, a spin on a stepping die
	# (the Spin-Up's), so the same entry may show again and be spent again; its limit is what it
	# costs and the odds (the Knuckle of Fury's five rage, the cylinder's sixth). A fight already
	# won, or a machine its own spend wrecked, rolls nothing.
	if f.acts_again() and ms.alive() and not (field_foes().is_empty() and reinforcements.is_empty()):
		var instant := f.has(Face.Keyword.INSTANT)
		_act_again(ms, instant)
		var how := "rapid, rolls again"
		if instant:
			how = "the cylinder spins" if Effects.steps_die(ms.unit) else "instant, rolls again"
		log.append("%s: %s" % [ms.unit.display_name, how])
	# Two things a round (the Needletail's Quick-turn Avionics Relay, Ryan, 11 November; rewritten
	# on 18 November: "just to send the 'unlit' kinds onto cooldown. There's no special cases or
	# states then"): a spend of a weapon sends every weapon on its die onto cooldown for the rest
	# of the round, one of equipment its equipment, and while a lit entry of the other kind stands
	# its die flips to one and it acts again. A Rapid or Instant spend sends nothing but itself
	# (its own rule), so its kind stays lit (his ruling: "rapid does not consume any of the
	# spends"). A fight already won flips nothing.
	elif spent_kind != 0 and ms.alive():
		for at in range(ms.die.faces.size()):
			if _turn_kind(ms, ms.die.faces[at]) == spent_kind:
				Effects.disable_entry(ms.unit, at, "cooldown", round)
		if not turn.is_empty() and not (field_foes().is_empty() and reinforcements.is_empty()):
			var lit: Array[int] = []
			for at in turn:
				if not Effects.is_entry_disabled(ms.unit, at):
					lit.append(at)   # still lit once the spend is done
			if not lit.is_empty():
				_turn_die(ms, lit)
				log.append("%s: a quick turn, and it acts again" % ms.unit.display_name)
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
	_finish_round()
	# No reinforcement phase (Ryan, 6 November: "Cut"): a pack is what its grid holds, so a kill's
	# slot stays empty unless a split, a summon or a part regrowing in its corpse's place fills it.
	_refresh_guards()
	_refresh_allies()
	_check_outcome()
	if outcome == Outcome.NONE:
		state = State.ROUND_START
	return outcome


## The blow a machine's reboot lands on every foe as its heat vents (the Whip Scorpion's Thermal
## Ejection Manifold; Ryan, 17 November: "the reboot vent is the one that explodes"; and, of the
## gate of 8 heat it had from 12 November, "remove the 8 heat minimum. Set it to 1 damage to
## all enemies for every X heat, your call. Far more intuitive I think, and more flexible"): its
## passive's number for every `per` heat it holds, whole steps alone. Null for a machine whose
## vent blasts nothing, or one holding less than a step. Read before the heat goes.
func release_shot(ms: MechState) -> Face:
	var rule := Effects.reboot_release(ms.unit) if ms != null else {}
	if rule.is_empty():
		return null
	var power := int(rule["value"]) * int(ms.heat / maxi(1, int(rule["per"])))
	if power <= 0:
		return null
	return Face.attack(power, Face.Reach.EVERY_FOE)


## A reboot's vent that explodes (the Whip Scorpion's; Ryan, 17 November, in place of the release
## on a passed turn of 11 and 12 November: "the reboot vent is the one that explodes. It's an
## easy swap in. Unfortunately it changes it's profile from sustained damage to huge burst, but I
## think it's ok"): the heat a machine sheds as its shield drops lands on every foe, `shot` as
## release_shot read it before the heat went. One hit, a weapon's, striking every foe (_hit),
## costing no heat of its own, its machine's kill for what it fells; the fight it decides ends
## there. With less heat than a step of its rule the vent is every machine's, and blasts nothing.
func _vent_blast(i: int, ms: MechState, shot: Face, fired: int) -> void:
	var standing := field_foes().filter(func(foe: Foe) -> bool: return foe.alive() and not out_of_reach(foe))
	if shot == null or standing.is_empty() or outcome != Outcome.NONE:
		return   # nothing stands in reach to take it: the heat vents as any machine's
	var target: Foe = standing[0]
	log.append("%s opens its valves: %d heat, %d on every foe" % [ms.unit.display_name, fired, shot.power])
	_killer = ms   # its own shot: what it fells is its kill
	var h := _hit(ms, shot, target)
	_finish_hits(i, ms, shot, target, h, Pays.FREE)
	_killer = null
	ms.heat = 0   # cold after it, whatever the blows cashed
	releases.append({"mech": i, "heat": fired, "blows": spend_blows.duplicate()})
	_refresh_guards()
	_check_outcome()


## The statuses the field holds from decaying right now, on every unit of either side: what a
## live machine's buff holds (Effects.holds_all: Essence Flare's hold on Empowered). A wreck holds
## nothing, and a buff a Purge took holds nothing: the hold stands while its carrier does.
func field_holds() -> Array:
	var out: Array = []
	for ms in live_mechs():
		if paused(ms):
			continue   # out of play: its buff waits with it, and holds the round it is back in
		for id in Effects.holds_all(ms.unit):
			if not out.has(id):
				out.append(id)
	return out


## The round's end, once the enemy's turn is done and the fight undecided: the machines'
## once-a-round notes go, a machine whose own attack killed fires what its passive grants for
## it, and the parts due grow back. Nothing halves or ticks here since 16 November: each does
## at its carrier's turn start or end. The fight's own (end_round, which then refreshes its cores' guards
## and its machines' allies and reads the outcome) and the round preview's copy (preview_round)
## both run it, so the preview's round ends as the round will.
func _finish_round() -> void:
	_burst_webs()
	_tick_mechs()
	_round_kills()
	_regrow_parts()


## What a machine's passive grants as the round ends, when an attack of its own killed in it
## (on_round_kill; the Ammit's Quintessence Reactor, Ryan, 16 November: "At the start of the
## skirmish, or at the end of a round where the Ammit killed at least one enemy, the Essences
## Flare, granting 1 Empowered per 5 Essences it holds"): once a round however many fell and
## however many attacks felled them, after the enemy's turn, so the stacks stand whole through
## its next turn and halve as that turn ends. A machine wrecked in the enemy's turn flares
## nothing; a Swallowed one waits with the rest of what it carries.
func _round_kills() -> void:
	for ms in live_mechs():
		if not ms.killed_round or paused(ms):
			continue
		ms.killed_round = false
		var got := Effects.fire(ms.unit, "on_round_kill")
		var parts := _apply(ms, got)
		if not parts.is_empty():
			log.append("%s: as the round ends, after its kill, %s" % [ms.unit.display_name, ", ".join(_with_counts(ms, parts, got))])


## The end of the player's turn (Ryan, 11 October): heat over the maximum burns hull now,
## before the enemy acts, so an overheat is the machine's own doing on its own turn, like a
## volatile bite. A machine it wrecks is gone before the enemy strikes, and a fight it
## decides ends here. A machine's Ablating takes its points just before it (15 November; as
## heat, 13 October), the shield first, so a cleanse took it off in the turn the player had.
## END TURN's (a withdrawal shared it until the long wall brief, 3.5).
func _end_player_turn() -> void:
	releases.clear()
	overheats.clear()
	ablations.clear()
	history.clear()   # the enemy's turn draws: nothing before it comes back
	# Maverick's Playbook (the Giant Petrel's, built 30 October): the team's rerolls left unspent
	# as the turn ends are banked, up to its cap, for the next round while it still fights.
	banked = mini(rerolls_left, bank_cap())
	_ablate_mechs()
	_seal_heat()
	_burn_overheated()
	# The machines' turn ends: a machine's Empowered halves (Ryan, 16 November: "Empowered
	# should decay at the end of turn, clearly, not end of round"; a foe's halves as its own
	# turn ends). What it gains in the enemy's turn it now carries whole into
	# its next turn. A hold on the field (Essence Flare) is read here for the machines' own.
	var holds := field_holds()
	for ms in live_mechs():
		if not paused(ms):
			Effects.halve_buffs(ms.unit, holds)
			Effects.entries_relight(ms.unit, round)   # a dark entry whose rounds are done lights as its machine's turn ends: a cooldown, a jam, Rapid's switch-off
	_refresh_allies()
	_check_outcome()


## The enemy's turn: every foe on the field acts in order, statuses tick, timed effects run
## out. The end of a round's.
func _enemy_turn() -> void:
	turn_events.clear()
	turn_specials.clear()
	turn_drains.clear()
	_seq = 0
	# Foes act in the order they stand: front rank left to right, then the back rank. A
	# suppressed foe skips, and a foe with two strikes lands two separate blows, so a shield
	# stops the first and the second reaches the hull. Each foe's statuses tick as its turn
	# ends, its action done or lost (Ryan, 16 November, his four places: "Its turn End:
	# Empowered, Regeneration, Brittle, Ablate, Vitriol ..."; at its action's start until then,
	# when a burn could fell a foe before it struck): its Ablating takes its points and Vitriol
	# its share of what is left, finishing nobody; what it regrows comes after them; its stacks
	# fade, its Empowered halves, its Sapped goes and its Numbed counts down or lands. A foe is
	# never struck down and then left to strike (Ryan, 4 November: "What we absolutely do not
	# want to do is have a zero-hp enemy attacking and then dying after, because burn ticked
	# first"): it strikes whole and burns after. A web on a foe bursts as the round ends, no
	# foe's own turn's business since 16 November (_burst_webs). The death check runs as each foe's action is done
	# and again on a foe its tick fells: its last act lands, its parts fall, its machine is let
	# go and a return stands before the next foe moves; and the fight ends the moment it is
	# decided, the foes after the blow that wrecks the last machine doing nothing.
	_acted.clear()
	_enemy_acting = true
	# The foes' turn starts (his four places: "Its turn Start: Armoured, Barrier, Ward"; Brittle
	# with them, the team's blows having used it): every foe's plate, Barrier and Ward from its
	# last turn go here, before the first foe acts, its Brittle halves unless a pin holds it,
	# and an Exposed whose round is past falls. The whole side's opening, never each foe's own
	# action: what one foe lays on the rest must outlast their actions that turn (a guard on
	# every foe), and no blow of the team's lands between the two moments.
	for f in field_foes():
		if f.alive():
			Effects.turn_opens(f, round)
	for f in field_foes():
		if outcome != Outcome.NONE:
			break
		if not f.alive():
			continue   # fallen earlier this turn (with its core, taken in by a merge), and does nothing
		var skip := f.is_suppressed()
		# A countdown still gathering carries its priming to the blow it lands, and a foe that
		# stepped up this round has had its round, so it keeps it for its next.
		var moves := not f.fresh and not f.gathering()
		if skip and not _staggered(f):
			f.recovering = true   # its action lost to a stun: its stun resist lands as Numbed as its turn ends (a stagger is no stun's, and numbs nothing)
		if not skip and not f.fresh:   # a suppressed foe does nothing, and a web on it still bursts; one that stepped up this round has had its round
			_foe_turn(f)
			# A move that landed names its follow-up for next round (30 October); one lost to a
			# Suppress or turned by a Disrupt names nothing, so either answer breaks the pair.
			if f.alive() and not f.gathering() and f.action.has("then"):
				f.next_move = str(f.action["then"])
		if moves and not skip and f.attacks():
			Effects.spend_stacks(f, "primed", 1)   # a stoker's priming rides a move that strikes, a stack a move (15 November: the primers' format); a special or a move lost to a stun spends none
		_turn_death_check()   # what its action felled, and the fight's end if its blow decided it: nothing ticks after that
		if outcome != Outcome.NONE:
			break
		if not f.alive():
			continue   # spent by its own blow (a Bomb's burst): it takes its web with it
		# Its turn ends. Regenerating (28 October) is read before the tick fades its stack, and
		# regrows after the Ablating and the Vitriol, so an Ablate is a race and never a wall; a
		# suppressed foe ticks and regrows too, its turn being its own.
		var regrow := Effects.regrowth(f)
		var tick := Effects.tick(f)
		if foe_phased(f):
			# Phased: everything it carries ticks and nothing damages it, as a machine's does.
			if int(tick["hp"]) > 0:
				log.append("%s is faded: what it carries takes nothing" % f.display_name)
			tick["hp"] = 0
			tick["share"] = 0
		var share := int(tick.get("share", 0))
		if int(tick["hp"]) - share > 0:
			log.append("%s is ablating: -%d" % [f.display_name, int(tick["hp"]) - share])
		if share > 0:
			log.append("vitriol eats %s for %d" % [f.display_name, share])
		if int(tick["hp"]) > 0:
			f.hp -= int(tick["hp"])
			if not f.alive():
				_turn_death_check()   # ablated to death, its action done: a web it carried goes with it
				continue
		if regrow > 0 and f.hp < f.hp_max:
			var before := f.hp
			f.hp = mini(f.hp_max, f.hp + regrow)
			log.append("%s regenerates %d" % [f.display_name, f.hp - before])
		# Its Empowered halves, its own turn over (16 November: a machine's at END TURN, a foe's
		# here, where it halved as the round ended until then): a rally stands whole on the next
		# blow of a foe that had acted before it landed. Essence Flare holds it while it stands.
		Effects.halve_buffs(f, field_holds())
		Effects.foe_turn_end(f)   # what lasts until after its next turn goes (Sapped)
		# Numbed's clock (Ryan, 2 November; at its turn's end since 16 November, "Numbed (applied
		# or reduced)"): a stack goes, then a foe that lost this action to a stun gains its stun
		# resist in stacks, so its chip reads the turns until one stun lands.
		if Effects.stacks_of(f, "numbed") > 0:
			Effects.spend_stacks(f, "numbed", 1)
		if f.recovering:
			f.recovering = false
			var r := f.stun_resist()
			if r > 0:
				Effects.stack(f, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", r, Effects.DECAY_NONE)
				log.append("%s recovers: Numbed ×%d" % [f.display_name, Effects.stacks_of(f, "numbed")])
		if skip:
			# The Suppress is spent with the turn it cost (his four places: "Its turn End: ...
			# Suppressed"): the foe has had its turn, so a stun that reaches it later this turn
			# meets its Numbed and costs its next action like any foe's that has acted.
			_spend_suppress(f)
			if not _acted.has(f):
				_acted.append(f)
		_turn_death_check()   # with the foe in _acted: a gold rage its own tick broke staggers it out of its next action, not the one it has had
	if outcome == Outcome.NONE:
		_turn_death_check()   # and once the turn is done, for a foe that fell outside an action's check
	_enemy_acting = false
	_acted.clear()
	if outcome != Outcome.NONE:
		return
	# A Swallowed machine first (Ryan, 16 November: "Swallowed it's out of play so everything
	# should pause"): one whose swallow has run its rounds is let go here, as the round ends, so
	# this round's end reads it like any machine, the end of the round it was taken in, owed
	# since; one still held has everything timed on it moved a round later.
	for ms in mechs:
		if paused(ms):
			Effects.pause_round(ms.unit, round, "swallowed")
	_land_phases()   # before the round's timed effects run out: the wait for Phased is one of them
	for ms in mechs:
		if not paused(ms):
			Effects.end_round(ms.unit, round)   # timed effects run out; a Swallowed machine's wait
	for f in field_foes():
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
	if f.aims_at_one() and (t == null or not t.alive() or is_out(t)):
		t = _repick(f)   # its machine fell, or is out of the fight: the next in line
	_acted.append(f)   # from its first blow, a suppress landing on it costs its next action
	if not f.pending.is_empty():
		if f.charge > 0:
			# A countdown move gathers this turn and lands when its count runs out; the
			# plaque names it as it begins, so the warning has a voice (15 October).
			if f.charge == Foe.countdown_of(f.pending):
				turn_specials.append({"foe": f, "name": str(f.pending.get("name", "")), "kind": "charge", "seq": _seq})
				_seq += 1
				if Foe.climbs(f.pending):
					# It leaves the dice's reach as it begins to gather, and comes down as the move
					# lands: the round it was announced was the window.
					Effects.stack(f, Effects.STATUS["aloft"], Effects.SKIRMISH, "foe:" + f.content_id, 1, Effects.DECAY_NONE)
					log.append("%s climbs out of reach" % f.display_name)
			f.charge -= 1
			var when := "next round" if f.charge == 0 else "in %d rounds" % (f.charge + 1)
			log.append("%s gathers: %s lands %s" % [f.display_name, str(f.pending.get("name", "")), when])
			return
		f.pending = {}   # it lands now
		Effects.remove(f, "aloft")   # and a foe that climbed for it is back in reach
	# What its blow does before it lands (`before`, 18 November: the Pilgrim's knife purges
	# first), each step in order on the move's own pick: the blow meets the machine as they
	# leave it. A blow with no machine to strike does none of them.
	if f.attacks() and (t != null or f.hits_all()):
		for st in Foe.before_of(f.action):
			if not f.alive():
				break
			_foe_acts(f, t, st)
	# The move's first step: its blow, or its one special in a blow's place.
	var swung := false
	if not f.attacks():
		_foe_acts(f, t)   # a defend, buff or debuff instead of a blow; on its own side it acts with no machine standing
	elif f.hits_all():
		# A blow at every machine (`all`, Ryan, 15 October): its strikes land on each live
		# machine in turn, left to right, so no aim or lure moves it; a screened machine is
		# out of it.
		for m in targetable_mechs():
			_strike(f, m)
		swung = true
	elif t == null:
		log.append("%s has no machine to strike" % f.display_name)   # nobody to strike: a blow has nowhere to land
	else:
		_strike(f, t)
		swung = true
	# What the move does also (16 November: a move is a short list of steps), each in order
	# once the first is done, on the move's own pick where it has a target: a step on its own
	# side acts whoever stands, and one aimed at a machine that fell to the blow, or is out of
	# the fight, lands on nobody. A foe its own blow spent does nothing more.
	for st in f.action.get("also", []):
		if not f.alive():
			break
		_foe_acts(f, t, st)
	if swung and not Foe.power_status(f.action).is_empty():
		Effects.remove(f, Foe.power_status(f.action))   # the borrowed swing spends what it took (30 October; Appropriated since 16 November)
	if f.has_keyword(f.action, "self_destruct") and f.alive():
		# The blow spends the striker (the Bomb): it dies whole and never gets back up.
		f.hp = 0
		f.stays_down = true
		log.append("%s bursts, and is gone" % f.display_name)
	return


## Every web on the field bursts as the round ends (the funnel-web's Web Bomb, Ryan's go of 18
## October; at the round's end since 16 November, his: "moved to End of Round and be
## repositioned as a double suppress on a delay, not suppress one this turn and one the next",
## with no cooldown): a Suppress on the webbed foe and one on the foe beside it (web_catch),
## each for its next turn, a countdown it gathers held a round. Every foe's own turn has ended
## by then, so the stun meets the Numbed the foe ends the round with: one the team stunned this
## round has just gained its Numbed, and the web strips a stack of it and stuns nothing. A foe
## already Suppressed for its next turn gains nothing, and a Ward turns the stun away. The web
## is spent either way. A foe felled before the round ends takes its web with it, and a foe's
## cleanse may lift it first. In the order the foes stand.
func _burst_webs() -> void:
	for f in field_foes():
		if not f.alive() or not Effects.has(f, "webbed"):
			continue
		Effects.remove(f, "webbed")
		var beside := web_catch(f)
		log.append("%s's web bursts%s" % [f.display_name, "" if beside == null else ", catching %s" % beside.display_name])
		if _suppress(f, null, true):
			_foe_gained_status(f, "suppressed")
		if beside != null and _suppress(beside, null, true):
			_foe_gained_status(beside, "suppressed")


## The foe a web on `f` catches, the one beside it in its rank: its right-hand neighbour, or
## with none standing there the one to its left; a massive foe stands in
## both ranks, so it is beside either. Null with nobody standing beside it.
func web_catch(f: Foe) -> Foe:
	if f.column < 0 or f.rank < 0:
		return null
	# The rank left to right, a twin slot's pair left then right: the next after it, or with
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
		if absi(n.column - f.column) <= 1 and n != f and n.alive() and not out_of_reach(n):
			return n   # one out of the team's reach (Aloft) is no catch: the other side is tried
	return null


## The foes beside `f` (the goblins' Shield Wall, Ryan, 20 November: "I said neighbors, not all, so
## it would be 3 max if they all rolled it at the same time"): every live foe in its rank one column
## to its left or right, a twin slot's other half with it, and a massive foe in a column beside it,
## which stands in both ranks; a massive `f` has those of both ranks beside it. Never itself.
func foes_beside(f: Foe) -> Array[Foe]:
	var out: Array[Foe] = []
	if f == null or f.column < 0 or f.rank < 0:
		return out
	var ranks: Array = [0, 1] if f.is_massive() else [f.rank]
	for r in ranks:
		for c in [f.column - 1, f.column, f.column + 1]:
			if c < 0 or c >= columns:
				continue
			for o in slot_foes(int(r), int(c)):
				if o != f and o.alive() and not out.has(o):
					out.append(o)
	return out


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
		# A drain (the Vampire Lord's, 30 October; its own Ability since 16 November, every blow
		# of its, Foe.drains): the striker regrows what the blow took from the
		# hull, no more than the machine had, so a shield starves it (one of shield and hull walled
		# the slow trios, the shield no answer to the heal). It lays nothing on the machine, so no
		# Ward turns it away; a Barrier's blow deals nothing, and Ablating on the striker races it.
		if f.drains and f.alive() and turn_events.size() > events_before:
			var dealt := clampi(int(ev["through"]), 0, maxi(0, hull_before))
			var had := f.hp
			f.hp = mini(f.hp_max, f.hp + dealt)
			if f.hp > had:
				log.append("%s drains %d" % [f.display_name, f.hp - had])
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
		if f.has_keyword(f.action, "ablate") and t.alive():
			var nb := f.rider(f.action, "ablate")
			_fire_on(t, "ablating_mech", nb, f)
			log.append("%s lays Ablating ×%d on %s" % [f.display_name, nb, t.unit.display_name])
		# Primed (a stoker's, 28 October; the primers' format since 15 November): each blow of a
		# move that strikes leaves Ablating 1, as an Ablate rider would, and the move spends a
		# stack (_enemy_turn).
		if Effects.stacks_of(f, "primed") > 0 and t.alive():
			_fire_on(t, "ablating_mech", 1, f)
			log.append("%s, primed, lays Ablating ×1 on %s" % [f.display_name, t.unit.display_name])
		if f.has_keyword(f.action, "jam") and t.alive() and t.face_index >= 0:
			# Jam: the entry the die shows is Jammed, switched off until the machine reboots.
			Effects.disable_entry(t.unit, t.face_index, "foe:" + f.content_id, Effects.JAM_REBOOT)
			log.append("%s jams %s's %s" % [f.display_name, t.unit.display_name, t.die.faces[t.face_index].describe()])
		if f.has_keyword(f.action, "corrupt") and t.alive() and t.face_index >= 0:
			# The entry the die shows is corrupted for the fight: it bites when spent.
			Effects.corrupt_entry(t.unit, t.face_index, "foe:" + f.content_id, f.rider(f.action, "corrupt"))
			log.append("%s corrupts %s's %s (×%d)" % [f.display_name, t.unit.display_name, t.die.faces[t.face_index].describe(), Effects.corrupt_stacks(t.unit, t.face_index)])
		if f.has_keyword(f.action, "brittle") and t.alive():
			# Brittle on the machine (15 November; the World Eater's pin, a crush until then): a
			# point more on every blow it takes a stack, so the pack's blows after this one land
			# harder; the stacks halve as its next turn starts, and an ally's Cleanse lifts them.
			var nc := f.rider(f.action, "brittle")
			_fire_on(t, "brittled_mech", nc, f)
			log.append("%s lays Brittle ×%d on %s: every blow it takes lands harder" % [f.display_name, nc, t.unit.display_name])
		if f.has_keyword(f.action, "expose") and t.alive() and not _any_exposed():
			# One machine at a time, and never a mark renewed (the rule of announcing, legal_actions):
			# a blow whose rider this is may be its foe's one move (the Piercing Eye's Gaze), so the
			# rider lands nothing while a machine stands Exposed, and the whole field's fire still
			# comes every other round at the most.
			_expose_mech(f, t)
		if f.has_keyword(f.action, "destroy") and t.alive() and int(ev["through"]) > 0:
			# Destroy (Ryan, 15 November: "a boss-level rider, that destroys the visible face if it
			# damages hull at all"): any of the blow on the hull, past shield, armour and a Barrier,
			# and the entry the die shows is destroyed. What it did rides on the event: the console
			# says a component was destroyed (Jenny's information lines, 8 October).
			ev["component"] = apply_injury(t)
			ev["injured"] = str(ev["component"]) == "destroyed"



## Whether this foe's blows carry a rider a Ward turns away: a scorch, an ablate, a jam, a
## corrupt, a Brittle, a destroy or an expose (a purge is a special).
static func _rides(f: Foe) -> bool:
	for kw in ["scorch", "ablate", "jam", "corrupt", "brittle", "destroy", "expose"]:
		if f.has_keyword(f.action, kw):
			return true
	return Effects.has(f, "primed")   # a primed foe's blows carry Ablating as a rider (28 October)


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


## A foe's Purge N (28 October; by its number since 2 November): every buff the machine carries
## loses N stacks for good, whatever granted it (Ryan, 8 November: "A stack is a stack, doesn't
## matter where it came from"); its abilities, its stores and a stack its passive keeps stay.
func _purge(t: MechState, f: Foe, n: int = 1) -> void:
	var touched := Effects.purge(t.unit, n)
	log.append("%s purges %s ×%d%s" % [f.display_name, t.unit.display_name, n, ": " + ", ".join(touched) if not touched.is_empty() else ", and finds nothing to take"])


## The round ends for the machines, after the enemy has struck: their once-a-round notes go.
## What ticks on a machine does so as its turn ends (_ablate_mechs), and what halves as its
## turn ends or starts.
func _tick_mechs() -> void:
	for ms in live_mechs():
		if not paused(ms):
			Effects.tick(ms.unit, true)


## A machine's shield regen as the round opens: what it is granted (a module's, a passive's, a
## status's; a chassis has none of its own). The Buzzard's heat added to it until 18 November.
static func shield_regen_of(ms: MechState) -> int:
	return maxi(0, Effects.stat(ms.unit, "shield_regen"))


## A machine's cooling as the round opens: what it is granted, a chassis having none of its own.
static func cooling_of(ms: MechState) -> int:
	return Effects.stat(ms.unit, "cooling")


## The heat a sealed machine runs at the end of its turn (the Polar Bear's Lockdown): the
## seal's own number, or nothing.
func seal_heat(ms: MechState) -> int:
	if not Effects.is_sealed(ms.unit):
		return 0
	return int(Effects.seal_form(ms.unit).get("heat", 0))


## Sealed machines run hotter at the end of the player's turn, after Ablating and before the
## overheat, so the clock bites on the turn the player ended.
func _seal_heat() -> void:
	for ms in live_mechs():
		var h := 0 if paused(ms) else seal_heat(ms)
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
			log.append("%s seals: armour +%d, its cooling stopped, +%d heat a turn" % [ms.unit.display_name, int(seal["armour"]), int(seal["heat"])])
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


## The end of the player's turn, before the overheat (Ryan, 15 November: Ablate, one rule on
## both sides): each machine's Ablating takes a point a stack and loses a stack, its Regenerating
## pays a point of shield a stack and loses one, and its Scorched and Sapped go. A Phased machine
## takes no point and its stacks fade all the same; a Swallowed one's wait and
## tick again the turn it is back, as its overheat does.
func _ablate_mechs() -> void:
	for ms in live_mechs():
		if paused(ms):
			continue   # Swallowed: out of play, so its Ablating, its Scorched and its Sapped wait for the turn it is back
		var regrow := Effects.regrowth(ms.unit)   # read before the tick fades its stack
		var points := int(Effects.turn_tick(ms.unit, is_phased(ms))["hp"])   # Phased: the stacks fade and take nothing
		if points > 0:
			_ablate(ms, points)
		# Regenerating (16 November, his four places: its turn's end, after its Ablating, the
		# foes' order): a point of shield a stack, a shield gain like any, so a shield the tick
		# just broke takes none; the stack has faded either way.
		if regrow > 0 and ms.alive():
			var mended := _gain_shield(ms, regrow)
			if mended > 0:
				log.append("%s regenerates %d shield" % [ms.unit.display_name, mended])


## What a machine's Ablating takes as its turn ends: the shield first ("hits shield first, I
## think. Pretty deadly otherwise"), then the hull past armour ("Bypasses armour when damaging
## hull"). A tick is no blow: a Barrier neither stops it nor is spent on it ("Tick of ablate
## ignores barrier yes"), nothing that reads a blow on the shield fires, and what reads hull
## damage does where it reaches the hull. A shield it takes to nothing is broken like any other.
func _ablate(ms: MechState, points: int) -> void:
	var from_shield := clampi(ms.unit.shield, 0, points)
	var from_hull := points - from_shield
	ms.unit.shield -= from_shield
	ms.unit.hull -= from_hull
	ablations.append({"mech": mechs.find(ms), "points": points, "shield_lost": from_shield, "hull_lost": from_hull, "shield": ms.unit.shield, "hull": ms.unit.hull})
	var bits: Array[String] = []
	if from_shield > 0:
		bits.append("shield -%d" % from_shield)
	if from_hull > 0:
		bits.append("hull -%d" % from_hull)
	log.append("%s is ablating: %s" % [ms.unit.display_name, ", ".join(bits)])
	_note_break(ms)
	if from_hull > 0 and ms.alive():
		_hull_damaged(ms)


## What a foe lays on a machine that ticks or fades at the end of the player's turn (Ryan, 13
## October, as Burn and Scorch; Ablate since 15 November): stacks of Ablating or Scorched for
## the skirmish, decaying as each says there (Ablating a stack, Scorched every stack).
## A foe's Expose lands on a machine (Ryan, 15 November: "all armour of all kinds"; "So the
## whole field targets up until predicted death, then the rest pick intent targets as
## normal"): Exposed at once and through the round after, its armour counting for nothing
## (the status's own effect, read through the stat) and, as that round opens, every targeted
## intent turning on it (_pick_mech_target). Refreshed, never added. The caller has read the
## Ward.
func _expose_mech(f: Foe, t: MechState, said: String = "") -> void:
	Effects.grant_for_rounds(t.unit, Effects.STATUS["exposure_mech"], "foe:" + f.content_id, round + 1)
	var lead := "%s exposes %s" % [f.display_name, t.unit.display_name] if said.is_empty() else "%s: %s, %s is Exposed" % [f.display_name, said, t.unit.display_name]
	log.append("%s: its armour counts for nothing, and the next round's fire turns on it" % lead)


## The machine that stands Exposed and can be picked, or null: one at a time is the foes'
## rule of announcing (legal_actions), so the first is the one.
func exposed_mech() -> MechState:
	for ms in targetable_mechs():
		if Effects.has(ms.unit, "exposure_mech"):
			return ms
	return null


## Is another foe's Expose out this round: a live foe on the field but `f`, among `announced`
## (every foe on the field when unsaid), whose move lays Exposed and will land? What a foe
## reads before it announces one of its own (Ryan, 15 November: "Enemy units should be smart
## enough to only try to Expose one player unit at a time"), the reroll drain's pattern.
func expose_announced(f: Foe, announced = null) -> bool:
	var said: Array = announced if announced is Array else Array(field_foes())
	for o in said:
		if o == f or not o.alive() or not o.on_field() or not Foe.exposes(o.action):
			continue
		if o.fresh or o.is_suppressed():
			continue   # stepped up this round with no move out, or held this round: it lays nothing
		return true
	return false


## Would this foe's blow lay its Exposed as the round stands (a rider on a blow, _strike): no
## machine stands Exposed, and no foe that strikes before it this round is laying one? The
## intent's read, so the mark on its chip is the truth: one machine at a time.
func expose_rider_lands(f: Foe) -> bool:
	if _any_exposed():
		return false
	var ahead: Array = []
	for o in field_foes():
		if o == f:
			break
		ahead.append(o)
	return not expose_announced(f, ahead)


func _fire_on(t: MechState, id: String, n: int, f: Foe) -> void:
	Effects.stack(t.unit, Effects.STATUS[id], Effects.SKIRMISH, "foe:" + f.content_id, n, Effects.status_decay(Effects.STATUS[id]))


## Refused at every state: there is no withdrawal (can_withdraw, the long wall brief 3.5).
func withdraw() -> bool:
	return false


# ---------------------------------------------------------------- resolution

## A weapon's or a debuff's spend at a foe, the plain one (the salvo and a pass's release fire
## their own: _salvo, _vent_blast). A forging machine's gun pays ammo first for the heat its own spend would
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
		if f.spends_magazine:
			log.append("%s empties the magazine: %d ammo" % [ms.unit.display_name, price])
		ms.ammo -= price
		pays = Pays.AMMO
	_zap_now = _pay_zap(ms, f)
	var h := _hit(ms, f, target)
	_zap_now = 0
	_reached_last = h.reached.size()
	_lay_mine(ms, target, h.mine)
	_entry_effects(ms, f, target, second)
	_finish_hits(mech_index, ms, f, target, h, pays)


## One weapon's or debuff's hits on its target, shared by every spend at a foe (the plain one, the
## salvo, a pass's release) and paying for none of it: every strike is its own blow (its own number,
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
	var fired := heat_bonus(ms, f) + shield_bonus(ms, f)
	h.fired = fired
	var loads := hopper_loads(ms.unit, f)   # the loads this shot fires from the hopper, read once too
	var from_hopper := loads * f.power_per_load
	var own := fired + from_hopper   # what the entry prints from its firer, on every blow of the spend
	var damaged: Array = []    # every foe the blows took HP off, for the hopper's loads (Ryan, 31 October: "per foe damaged")
	h.vented_all = ms.heat if f.vents_all else 0
	if f.vents_all:
		ms.heat = 0
	# A gun that fires its whole shield (the Shield-burner Cannon since 18 November): the shield goes to
	# nothing before the strikes, broken, as any shield a spend of its own takes to nothing is (Ryan:
	# "Yes, same answer as 1 now. Breaks the shield").
	if f.spends_shield and ms.unit.shield > 0:
		log.append("%s fires its whole shield: -%d, +%d to the blow" % [ms.unit.display_name, ms.unit.shield, fired])
		ms.unit.shield = 0
		_note_break(ms)
	# Every foe one strike reaches (a Spread's neighbours, a Penetrate's column, every foe for a
	# reach over them all), the same for each strike, since a kill clears its slot only after the
	# spend.
	var hit := reached_by(f, target)
	var shapes := area_shapes(f, target)   # the shape each foe past the target stands in, for its number
	# The offhand's riders (the Macaque's, Ryan, 19 November; "I had intended for everything to
	# apply riders"): the rifle's blow on the foe to the right of the target with every strike, its
	# own blow beside an area's ("Two spreads on the same weapon would combine, but the rifle buff is
	# a different form"), and the sword's hit again on the target after every strike, its number the
	# share it says of the strike's blow, rounded down. A reach over every foe has no one target, so
	# neither rides it. Neither follows a Ricochet's hit, the entry's strikes alone setting them off.
	var everyone := f.reach == Face.Reach.EVERY_FOE
	var side := 0 if everyone else Effects.side_strike(ms.unit, f, target)
	var right: Foe = right_of(target) if side > 0 else null
	var again := 0 if everyone else Effects.strike_again(ms.unit, f, target)
	# What the hit judges on each foe it reaches, before it lands (_judge): its machine's lays,
	# the foe's own reads and the gates, once, as the die is spent.
	var judging: Array[Foe] = hit.duplicate()
	if right != null and not judging.has(right):
		judging.append(right)
	var judged := _judge(ms, f, judging)
	var lays: Dictionary = judged["lays"]
	var reads: Dictionary = judged["reads"]
	var shut: Dictionary = judged["shut"]
	var judged_hp: Dictionary = judged["hp"]   # each foe's HP as the hit judged it, for a condition on it
	var laid := {}
	var webbed: Array[Foe] = []
	var riders: Array[Callable] = []   # every rider the strikes earn, in order, landed once the strikes are done (Ryan, 3 November)
	var doubled := Effects.stack_multiplier(ms.unit, f, target)   # the stacks this spend lays, multiplied (the sixth shot)
	var told_shut := {}   # the foes a gate turned the keyword from, told once
	var split := maxi(1, f.split)    # a split: the hits it doubles, each base halved (Effects.split_of; the Split-cycle Breech, a module)
	# One shape of weapon (Sweep, the one multi-target mode, went on 12 November): its hits all on
	# the target, an area's shape riding each, every hit's riders, then the death check.
	var struck_once := {}            # every foe a blow of the spend has met, for what a foe reads on its first
	var blocked := 0                 # the weapon's blows a living foe's armour or Barrier took whole (on_blocked)
	# Ricochet (the Skua's, Ryan, 12 November: "After firing a weapon, it hits the primary target 1
	# more time per stack, dealing 1 damage each time and applying all effects other than area
	# keywords"): once the weapon's strikes are done, a strike of 1 more a stack at the target
	# alone. Each is a strike through the whole blow, its number 1 in place of the entry's and what
	# the entry reads: the firer's pipeline on it, the foe's Brittle and armour, the weapon's riders
	# a strike. Read as the spend begins, so a stack the spend earns bounces none of it.
	var strikes := maxi(1, f.strikes)
	# A reach over every foe has no one target (Ryan, 12 November: "Target all shouldn't need a
	# target in the same way that sweep didn't"): every foe is struck, so a Shock on any of them
	# is doubled and spent, and with no primary target no Ricochet follows it.
	var bounces := Effects.stacks_of(ms.unit, "ricochet") if f.is_weapon() and not everyone else 0
	# The hits in the order they land, each a place of its own on the screen: every strike, the
	# sword's hit again after each, then the Ricochet's.
	var order: Array[int] = []
	for s in range(strikes):
		order.append(HIT_STRIKE)
		if again > 0:
			order.append(HIT_AGAIN)
	for b in range(bounces):
		order.append(HIT_BOUNCE)
	var spread := hit                # the foes a strike reaches and the shapes they stand in, for the strikes between the hits on the target alone
	var spread_shapes := shapes
	var strike := -1                 # the entry's own strike a hit belongs to
	for at in range(order.size()):
		var step: int = order[at]
		var bounce := step == HIT_BOUNCE
		var echo := step == HIT_AGAIN
		if step == HIT_STRIKE:
			strike += 1
		if bounce or echo:
			var only: Array[Foe] = [target]
			hit = only
			shapes = {}
		else:
			hit = spread
			shapes = spread_shapes
		if bounce:
			h.base += 1
		elif step == HIT_STRIKE and strike % split == 0:
			h.base += f.power + own   # the number before the pipeline, once a split's hits, for the screen's flash
		var heat := f.heat if at == 0 else 0
		# The blow's order (Ryan, 28 October), the target first:
		# the entry's number and what it prints from its firer (the heat Vents all fired, the
		# hopper's loads), a split's halving of that base (Ryan, 7 November: "base
		# weapon damage is halved"), then the firer's pipeline, every live modifier's adds,
		# multiplies and floors in that order, its conditions read on that foe; then that foe's own
		# reads, flat (_foe_reads): "the spirit of buffs and riders is they happen after".
		# A Ricochet's strike is 1 where the entry's number and its reads of the foe would stand. The
		# sword's hit again is a strike of its own (Ryan, 19 November: "it should be based on the base
		# damage, then its own math applied, just like a multi-strike weapon"; "Base 4 -> treat like a
		# 4,2 weapon (two strikes)", "Base 2x2 -> treat like a 2,1,2,1"): its number the share it says
		# of the strike's own, rounded down, then the firer's pipeline and the entry's reads of the foe
		# as any later strike's, so a buff on one strike never lands on the other.
		var number := split_share(f.power + own, split)
		if bounce:
			number = 1
		elif echo:
			number = floori(number * again / 100.0)
			h.base += number
		var ctx := _zapped(_judged(judged_hp, target))
		if at == 0:
			ctx["first_blow"] = true   # the spend's first blow, its first strike's on its target (the strike order): a next strike's add lands on it alone (the Parry's return)
		var modded := Effects.attack(ms.unit, f, number, heat, target, ctx)
		var dmg: int = int(modded["damage"]) + (0 if bounce else _foe_reads(f, reads, target, not struck_once.has(target)))
		if at == 0:
			h.heat += modded["heat"]   # heat is paid once a spend, every modifier's with it (the rules: a blow)
		h.vent += modded["vent"]
		var landed := dmg
		# Area by shape, numbered (Ryan, 28 October; the half retired): every other foe the strike
		# reaches takes its shape's number (Spread's, Penetrate's, Splash's, Chain's on a Shocked
		# conductor, whose Shock stands, no strike being aimed at it) in place of the roll,
		# through the same order, the firer's modifiers on it and its own reads. Every blow of the
		# strike is read before any lands, so no blow of it reads what another did.
		var blows := {}
		for foe in hit:
			blows[foe] = dmg if foe == target else _area_blow(ms, f, int(shapes.get(foe, AREA_ALL)), foe, own, split, _zapped(_judged(judged_hp, foe))) + _foe_reads(f, reads, foe, not struck_once.has(foe))
		# Every blow of the strike in the strike order, [foe, its blow, the shape it stands in] (Ryan,
		# 19 November: "Spread always computes before Penetrate, and Penetrate computes before
		# Rifle"): the target, Spread's left and right, Penetrate's other rank, then the rifle's blow
		# on the foe to the right, a blow of its own on a foe an area of the strike reached too, then
		# Chain's arcs, which follow the impact.
		var landings: Array = []
		var arcs: Array = []
		for foe in hit:
			var row := [foe, blows[foe], int(shapes.get(foe, 0))]
			if int(row[2]) == AREA_CHAIN:
				arcs.append(row)
			else:
				landings.append(row)
		if step == HIT_STRIKE and right != null:
			var first_right := not struck_once.has(right) and not hit.has(right)
			landings.append([right, _side_blow(ms, f, side, own, split, right, _zapped(_judged(judged_hp, right))) + _foe_reads(f, reads, right, first_right), AREA_SIDE])
		landings.append_array(arcs)
		for landing_at in landings:
			var foe: Foe = landing_at[0]
			var shape: int = landing_at[2]
			var was_alive := foe.alive()
			var hp_before := foe.hp
			var first := not struck_once.has(foe)   # the foe's first blow of the spend
			struck_once[foe] = true
			var into_mine := foe == target   # the blow on the spend's target: its riders are the Mine's too
			var struck := foe == target or everyone   # a strike aimed at this foe, never a blow that only reaches it
			# A Chain's arc is its blow alone (Ryan, 18 November: "take riders off chain. Thematically
			# it's a lightning arc, not part of the impact"): no rider of the entry, its primers or a
			# passive lands on a conductor, and no Shock, Expose, Lure or Disrupt after the blow.
			var arc := shape == AREA_CHAIN
			if not h.reached.has(foe):
				h.reached.append(foe)
			if shape == AREA_CHAIN:
				log.append("%s arcs to %s" % [ms.unit.display_name, foe.display_name])   # Chain (28 October): a conductor's blow
			var blow: int = landing_at[1]
			# Spillover (Overwhelm until 6 October): damage past the kill of a front-rank foe carries
			# into the foe behind it (_spill). A massive foe fills its column: nothing is behind it.
			var spills := f.spills and foe.rank == 0 and not foe.is_massive()
			var taken := 0   # what the foe takes of the blow, nothing for a corpse a later strike spills past
			if spills and not was_alive:
				# A later strike on a foe an earlier strike of this spend killed (Ryan, 15 October:
				# "All its damage or subsequent strikes spill over"): the fallen foe takes nothing
				# more, its armour included, and the strike's whole number goes on behind it; with
				# nothing standing there, it is lost. The blow's record counts it whole, as it
				# counts the killing strike's excess. Its riders land on the corpse as any hit's do
				# (the audit's eighth bug, 8 November: a Wild Boar's ×2 Brittle 1 that kills with its
				# first strike leaves Brittle 2).
				if struck:
					_note_blow(foe, at, 0, "ricochet" if bounce else ("again" if echo else "strike"))   # the shot lands on the corpse before it spills
				_spill(ms, f, foe, blow, hit, at, not f.is_debuff())
				if foe == target:
					landed = blow
			else:
				# What the foe takes of the blow: its own statuses read last (its Brittle adds to a
				# weapon's blow, a strike of 0 included: Ryan, 25 October; a Shocked foe takes the
				# strike aimed at it double, spending the shock, while a blow that only reaches it, an
				# area's or a Chain's arc, neither doubles nor spends it: Ryan, 29 October), then its armour comes off, flat,
				# so small blows bounce off a braced foe the way they do off a heavy machine; a
				# piece that ignores armour meets none (Foe.armour_for). Every blow is recorded, one on a
				# foe an earlier hit of the spend felled included, so the screen shows every hit and
				# shot land (Ryan, 7 November: "Anything truncated confuses the player").
				var landing := _land_blow(foe, blow, ms.unit, not f.is_debuff(), struck, foe.armour_for(f), at, ("ricochet" if bounce else ("again" if echo else "strike")) if struck else ("chain" if shape == AREA_CHAIN else "area"))
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
				if foe == target:
					landed = taken
					h.armoured += foe_armoured
				# A weapon's strike aimed at the foe spends a shock, even one that deals nothing (Ryan,
				# 25 October: "The important part is that it was a damaging weapon"; 29 October: "when
				# targeted and struck by a weapon"); equipment (a lure, a probe) and a blow that only
				# reaches the foe leave it standing.
				if not f.is_debuff() and struck and Effects.remove(foe, "shocked"):
					log.append(("%s: the shock is spent on the Barrier" % foe.display_name) if barred else ("%s: the shock lands, %d doubled" % [foe.display_name, blow]))
			# A hit lays what the passives lay on this foe, a stack per strike, a debuff's included,
			# unless the passive asks for a weapon's hit (the Ambush's Vitriol, its text says so:
			# Ryan, 25 October).
			if lays.has(foe) and not arc:
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
				_spill(ms, f, foe, taken - hp_before, hit, at)
			# Every rider lands on the foe its strike struck, felled or not (Ryan, 3 November: "the
			# point is to show that the riders hit, AND it dies"; death is the spend's last check, so
			# the preview shows them beside the skull and no trigger goes unfired).
			if f.has(Face.Keyword.ABLATE) and not arc:
				# Ablate is a numbered keyword (Ryan, 18 October): the stacks it says, whatever the
				# blow dealt (it was a stack per 10 of the damage, rounded up, until then).
				var ablate_laid := _stacks_from(ms, "ablating", f.ablate) * doubled
				riders.append(func() -> void: _land_rider(foe, "ablating", ablate_laid, gained, turned))
				if into_mine:
					h.mine_stack("ablating", ablate_laid)
			if arc:
				pass   # an arc carries no stun
			elif f.has(Face.Keyword.SUPPRESS) and shut.get(foe, []).has(Face.Keyword.SUPPRESS):
				if foe.alive() and not told_shut.has(foe):
					told_shut[foe] = true
					log.append("%s's suppress does not land on %s (%s)" % [ms.unit.display_name, foe.display_name, Effects.gate_text(f.gates.get("suppress", {}))])
			elif f.has(Face.Keyword.SUPPRESS):
				riders.append(func() -> void:
					if _suppress(foe, turned):
						_note_status(gained, foe, "suppressed"))
				if into_mine:
					h.mine_flag(Face.Keyword.SUPPRESS)   # fired through its gate: each foe the blast meets judges its own Numbed
			# The Web Bomb's web (18 October; its piece's own rule since 15 November): the foe wears
			# its mark, one web however often it is webbed, and the skirmish bursts it as the round
			# ends (_burst_webs). No Mine carries it: a rule one piece prints is that
			# piece's.
			if f.webs and not arc:
				riders.append(func() -> void: _land_web(foe, gained, turned, webbed))
			# Cryo (20 October): a weapon's hit spends every stack the foe carries (Ryan, 25
			# October), and the hitter cools for them once the spend's own heat has landed (below);
			# equipment spends none. The blow's own Cryo lands with the riders, so a spend never
			# eats what it lays.
			if was_alive and not f.is_debuff() and Effects.has(foe, "cryoed"):
				h.thawed += Effects.stacks_of(foe, "cryoed")
				Effects.remove(foe, "cryoed")
			if f.has(Face.Keyword.CRYO) and not arc:
				var cryo_laid := _stacks_from(ms, "cryoed", f.cryo) * doubled
				riders.append(func() -> void: _land_rider(foe, "cryoed", cryo_laid, gained, turned))
				if into_mine:
					h.mine_stack("cryoed", cryo_laid)
			# Brittle (Ryan's go, 19 October; built 21 October): each foe hit gains the keyword's
			# number in stacks a strike, with the riders, so no strike of the spend feeds on what
			# it lays (Ryan, 3 November: "5,5,5 makes way more sense to me").
			# Sap (the Baboon's Redshift Emitter, 11 November): Sapped laid as Brittle is, with the riders.
			if f.has(Face.Keyword.SAP) and not arc:
				var sap_laid := _stacks_from(ms, "sapped", f.sap) * doubled
				riders.append(func() -> void: _land_rider(foe, "sapped", sap_laid, gained, turned))
				if into_mine:
					h.mine_stack("sapped", sap_laid)
			if f.has(Face.Keyword.BRITTLE) and not arc:
				var brittle_laid := _stacks_from(ms, "brittled", f.brittle) * doubled
				riders.append(func() -> void: _land_rider(foe, "brittled", brittle_laid, gained, turned))
				if into_mine:
					h.mine_stack("brittled", brittle_laid)
			# A pin (the Hollow-point Harpoon's; Ryan, 16 November: "the next time it would decay, it
			# doesn't"): laid after what the spend lays, spent by the decay it stops (Effects.spend_hold)
			# or gone as its foe's turn ends where it held nothing (19 November).
			if not f.holds.is_empty() and not arc:
				var held_id := f.holds
				riders.append(func() -> void:
					var holder: String = Effects.HOLDERS[held_id]
					if foe.alive() and Effects.stack(foe, Effects.STATUS[holder], Effects.SKIRMISH, "mech", 1, Effects.status_decay(Effects.STATUS[holder])) != null:
						log.append("%s is %s: the next time its %s would decay, it does not" % [foe.display_name, str(Effects.STATUS[holder]["name"]), str(Effects.STATUS[held_id]["name"])])
						_foe_gained_status(foe, holder))
			# Purge (the player's, 28 October): every buff the foe carries but Numbed and Guarded,
			# with the riders, equipment's included; a foe the blow killed loses its Getting Back
			# Up, so it stays down.
			if f.has(Face.Keyword.DISPEL) and not arc:
				var purged := maxi(1, f.dispel)
				riders.append(func() -> void: _purge_foe(ms.unit.display_name, foe, purged, turned))
				if into_mine:
					h.mine["dispel"] = int(h.mine["dispel"]) + purged
			if into_mine and f.has(Face.Keyword.CHAIN) and not f.is_debuff():
				h.mine["chain"] = int(h.mine["chain"]) + maxi(0, f.chain)   # every hit's arc number
			if not touched.has(foe) and not arc:
				touched.append(foe)   # every foe the blows reached, felled or not, but a Chain's conductors: Shock, Expose, Lure and Disrupt land on it below
		h.total += landed
	# Riders land after the hits (Ryan, 3 November: "a multi-hit weapon with Shock would apply it
	# after both hits ... Cryo should work the same way, resulting in 2 applications, not
	# apply-cash-apply-cash, and not hit-hit-apply once"; and "It should be standard, not
	# branching code"): every rider the hits earned, gathered above in the order the hits earned
	# them, lands now the hits are done, an application a hit on each hit's own foe, so nothing in
	# the hit cashes, feeds on or reads what it lays. Shock, Expose, Lure and Disrupt land below,
	# after the blow, as they did.
	_land_riders(ms, riders, laid, webbed)
	# The hopper (11 October; the Ore Hopper, 31 October): a shot that fires it spends the loads
	# it took; then each foe the spend's blows damaged puts loads in, after the blow, so a claw
	# never feeds the shot it is part of: a weapon's own number where it prints one (the
	# Chainsaw Claw's two), the passive's for any other weapon, never past the hopper's cap. The
	# hopper's Armoured follows the loads' worth both ways (Effects._plate).
	if loads > 0:
		Effects.spend_loads(ms.unit, loads)
		log.append("%s fires the hopper: %d load%s, +%d" % [ms.unit.display_name, loads, "" if loads == 1 else "s", from_hopper])
	h.damaged = damaged.size()
	var per_foe := hopper_fill_of(ms.unit, f)
	if per_foe > 0 and not damaged.is_empty():
		var n := Effects.add_loads(ms.unit, per_foe * damaged.size())
		if n > 0:
			log.append("%s fills the hopper: +%d (%d)" % [ms.unit.display_name, n, Effects.stacks_of(ms.unit, "hopper")])
	_after_blow(ms, f, touched, gained, turned)
	if blocked > 0:
		_blows_blocked(ms, blocked)
	# What lands after the blow rides a Mine once.
	for k in [Face.Keyword.SHOCK, Face.Keyword.EXPOSE, Face.Keyword.DISRUPT]:
		if f.has(k):
			h.mine_flag(k)
	return h


## One blow of a hit landing on a foe, a strike's, an area's, an arc's or a spill's: what the foe
## takes of `blow` (Effects.damage_taken: its own statuses read last, a `weapon`'s blow taking its
## Brittle even at 0, a Shocked foe's double on a weapon's strike `aimed` at it), a Barrier taking a
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
## the death check, the spend's end): told (_tell_hits), the shove, the death check, then what the
## spend pays (_pay_hits, `pays` one of Pays).
func _finish_hits(mech_index: int, ms: MechState, f: Face, target: Foe, h: Hits, pays: int) -> void:
	_tell_hits(mech_index, ms, f, target, h, pays)
	_shove(ms, f, h)
	# The death check (Ryan, 7 November), once the hits and their riders are done: a kill clears
	# its slot (Ryan, 22 September: burning a hole through the front opens the
	# back rank to direct fire), and what it brings back waits for the spend's end. Indirect fire
	# at the front rank costs its firer nothing (danger close retired with the stock pass, 22 October).
	_clear_dead()
	_pay_hits(ms, f, h, pays)
	# What damaging a foe earns the machine (on_damage; the Skua's stack of Ricochet, once a round
	# by its own gate): after the spend that did it, so none of that spend's shots bounce off it.
	if h.damaged > 0 and f.is_weapon() and ms.alive():
		_fired(ms, Effects.fire(ms.unit, "on_damage"), "for the damage")


## The Juggernaut Drive (the Wild Boar's, Ryan, 11 November: "Damaging an enemy in the front rank
## deals 25% of its maximum HP, rounded up, to the enemy immediately behind"; "like the old storm
## petrel zap, but to all targets hit"): once the spend's hits have landed, every front-rank foe a
## blow of it damaged, felled or not, drives that share into the foe standing behind it, once a
## spend, a plain blow (plain_blow_on): no keyword, through what the foe takes, its armour and its
## Barrier, before the death check. A massive foe fills its column: nothing stands behind it.
func _shove(ms: MechState, f: Face, h: Hits) -> void:
	var pct := Effects.shove_share(ms.unit)
	if pct <= 0:
		return
	var fronts: Array[Foe] = []
	for b in spend_blows:
		var foe = b.get("foe", null)
		if foe == null or int(b.get("taken", 0)) <= 0 or str(b.get("kind", "")) in ["mine", "shove"]:
			continue
		if foe.rank == 0 and not foe.is_massive() and not fronts.has(foe) and not _shoved.has(foe):
			fronts.append(foe)
	for front in fronts:
		_shoved[front] = true
		var back := foe_at(1, front.column)
		if back == null or back == front or not back.alive() or out_of_reach(back):
			continue
		var before := back.hp
		var dealt := plain_blow_on(back, ceili(float(front.hp_max) * float(pct) / 100.0), ms)
		if _barrier_eats(back, true):
			dealt = 0
		back.hp -= dealt
		_note_blow(back, maxi(1, f.strikes), dealt, "shove")   # after the strikes
		h.dealt += clampi(dealt, 0, maxi(0, before))
		log.append("%s drives %s into %s for %d" % [ms.unit.display_name, front.display_name, back.display_name, dealt])


## The hits told: the screen's last roll and the log's line, then the heat Vents all fired into
## them.
func _tell_hits(mech_index: int, ms: MechState, f: Face, target: Foe, h: Hits, pays: int) -> void:
	last_roll = {"mech": mech_index, "target": target, "base": h.base, "final": h.total, "tags": f.tags.duplicate()}
	var how := f.describe()
	var armour := " (armour -%d)" % h.armoured if h.armoured > 0 else ""
	log.append("%s hits %s for %d (%s)%s" % [ms.unit.display_name, target.display_name, h.total, how, armour])
	if h.vented_all > 0:
		log.append("%s fires its heat: -%d, +%d to the blow" % [ms.unit.display_name, h.vented_all, h.fired])




## What a spend pays for its hits once its death check is done, in order: the runner's reach tally
## (a lure or a probe deals nothing and is no spend of damage; a pass's release is no spend of
## its own, FREE), the heat the firer's modifiers vent, the spend's heat as `pays` says (Pays: the gauge takes
## the hits'; the forge took the gun's own in ammo, the salvo's included, a foe's debuff still
## heating it, Ryan, 8 November: "scorch affects the actual heat bar, not the ammo cost"; the
## release pays none), the Shrapnel Recuperator's casings (ammo back for every foe
## its blows reached), and the Cryo its hits spent, cooling the hitter once its heat has landed.
func _pay_hits(ms: MechState, f: Face, h: Hits, pays: int) -> void:
	if f.power > 0 and pays != Pays.FREE:
		_tally_reach(h.reach, h.dealt, h.aimed_back, h.heat)
	if h.vent > 0:
		ms.heat = maxi(0, ms.heat - h.vent)
	var heat := h.heat
	if pays == Pays.AMMO:
		heat = Effects.debuff_heat(ms.unit, f)
	elif pays == Pays.FREE:
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
## pipeline, flat, beside its Brittle, the eaten stacks a point each on its first blow and gone as it
## lands; and the gates (the stock pass's engine, 22 October: the Suppression Battery's Suppress on
## a foe carrying Brittle), foe -> [keywords turned away], so a hit never opens its own gate. A
## weapon's hits judge once, at the spend.
func _judge(ms: MechState, f: Face, foes: Array) -> Dictionary:
	var lays := {}
	var reads := {}
	var shut := {}
	var hp := {}
	for foe in foes:
		var l := Effects.laid_statuses(ms.unit, f, foe)
		if not l.is_empty():
			lays[foe] = l
		reads[foe] = [f.missing_bonus(foe), Effects.stacks_of(foe, f.consumes) if not f.consumes.is_empty() else 0]
		hp[foe] = foe.hp   # the HP a condition on it reads for every blow of the hit (the Kite's opener, its lock's finish)
		if f.has(Face.Keyword.SUPPRESS) and not Effects.gate_holds(ms.unit, f, Face.Keyword.SUPPRESS, foe):
			shut[foe] = [Face.Keyword.SUPPRESS]
	return {"lays": lays, "reads": reads, "shut": shut, "hp": hp}


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
	if f.swaps and second != null:
		_swap(target, second)
		# What the Swap carries lands on the foe traded with too (the Translocator's Shock: both
		# come out Shocked).
		if second is Foe and (second as Foe).alive() and f.has(Face.Keyword.SHOCK):
			_shock(second, ms)


## A hit's riders landing (Ryan, 3 November: "a multi-hit weapon with Shock would apply it after
## both hits"): every rider its hits earned, in the order they earned them, an application a hit
## on each hit's own foe; then what they laid and webbed, told, once the spend's hits are done.
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
		log.append("%s webs %s: it bursts as the round ends%s" % [ms.unit.display_name, foe.display_name, "" if caught == null else ", on it and %s" % caught.display_name])
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
			_foe_gained_status(foe, status_id, int(gained[foe][status_id]))
	touched.clear()
	gained.clear()
	turned.clear()


## A spend's kills, counted at its death check (is_kill):
## the muster its guns earn (the Swallowtail's) and the kill trigger, once however many fell (the
## Kite's shield back whole;
## the Ammit's flare, Ryan, 12 November: "the flare should be the Ammit kill only", and of a
## flare for each foe, built first: "Flaring twice for an AoE is probably wrong, let's make it
## 'one of more killed' by an attack"; the Essence its kills banked are in already, the death
## check's).
func _after_kills(ms: MechState, killed: int) -> void:
	if killed <= 0:
		return
	_muster(ms, killed * int(Effects.muster_rule(ms.unit).get("kill", 0)))
	ms.killed_round = true   # what its passive reads as the round ends (_round_kills)
	if ms.alive():
		var got := Effects.fire(ms.unit, "on_kill")
		var parts := _apply(ms, got)
		if not parts.is_empty():
			log.append("%s: after the kill, %s" % [ms.unit.display_name, ", ".join(_with_counts(ms, parts, got))])


## The foes a Lure entry spent on `aimed` would turn on this machine, as the arrows show them:
## every foe it reaches, alive, not suppressed, with an arrow to move (a blow at every machine
## and a special that acts on nobody keep theirs), and not on it already. A reach over every
## foe (the Shift Whistle) needs no aim. Empty for an entry without Lure.
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
	for foe in ridden_by(ef, aimed):
		if not foe.fresh:
			out.append(foe)
	return out


## Every foe one strike of an entry reaches from its target, each once: the target, a Spread's
## neighbours in its rank, a Penetrate's other rank of its column; a foe killed this round
## still standing in its slot included, as the strikes find it. A foe out of the team's reach
## (out_of_reach: Aloft) is passed over by all of it. The resolver and the bot read the same
## list.
## The foes a spend's riders land on (Ryan, 18 November: "take riders off chain. Thematically it's a
## lightning arc, not part of the impact"): every foe it reaches but Chain's conductors, which take
## the arc's blow alone. What a lure's turn, a Shock, a mark and a passive's lay are read over.
func ridden_by(f: Face, target: Foe) -> Array[Foe]:
	var shapes := area_shapes(f, target)
	var out: Array[Foe] = []
	for foe in reached_by(f, target):
		if foe == target or int(shapes.get(foe, AREA_ALL)) != AREA_CHAIN:
			out.append(foe)
	return out


func reached_by(f: Face, target: Foe) -> Array[Foe]:
	var hit: Array[Foe] = [target]
	# A reach over every foe in the fight (the Shift Whistle, a lure-all), front and back.
	if f.reaches_all:
		for foe in field_foes():
			if not hit.has(foe) and not out_of_reach(foe):
				hit.append(foe)
		return hit
	# In the strike order (Ryan, 19 November: "Center -> Left -> Right for Spread, and Center ->
	# Front/Rear for penetrate. Spread always computes before Penetrate"): the target, then Spread's
	# left and its right, then Penetrate's other rank, each with its twin, an area blow reaching a
	# twin slot whole; Chain's conductors last.
	var area := f.has_area()
	if area:
		_pair_with(hit, target)
	if f.reaches_row():
		for c in [target.column - 1, target.column + 1]:
			if c >= 0 and c < columns:
				var n := foe_at(target.rank, c)
				if n != null and not hit.has(n) and not out_of_reach(n):
					hit.append(n)
					if area:
						_pair_with(hit, n)
	if f.reaches_column():
		var other := foe_at(1 - target.rank, target.column)
		if other != null and not hit.has(other) and not out_of_reach(other):
			hit.append(other)
			if area:
				_pair_with(hit, other)
	# Chain's conductors (28 October): every other Shocked foe on the field, after the shapes, so
	# a foe both beside the target and Shocked takes one blow, the shape's; a twin's half only if
	# it carries the charge itself.
	for foe in conductors(f, target):
		if not hit.has(foe):
			hit.append(foe)
	return hit


## Chain's conductors (Ryan, 28 October; the kill and repeat retired): every other foe on the
## field alive and Shocked, wherever it stands and whatever the entry's reach, in the field's
## order. None for an entry without Chain. A debuff's arcs are its Chain's number alone, and they
## carry its riders as any area of it does (the Storm Petrel's lure since 17 November: every
## Shocked foe it arcs to is lured). Read as the die is spent, before any blow lands, so a Shock
## the spend lays never conducts its own arc.
func conductors(f: Face, target: Foe) -> Array[Foe]:
	if f != null and f.has(Face.Keyword.CHAIN):
		return shocked_foes(target)
	var none: Array[Foe] = []
	return none


## Every foe on the field alive and Shocked but `but`, in the field's order: a Chain's
## conductors, a Mine's blast's included.
func shocked_foes(but: Foe) -> Array[Foe]:
	var out: Array[Foe] = []
	for foe in field_foes():
		if foe != but and foe.alive() and Effects.has(foe, "shocked") and not out.has(foe) and not out_of_reach(foe):
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
				if n != null and n != target and not out.has(n) and not out_of_reach(n):
					out[n] = AREA_ROW
	if f.reaches_column():
		var other := foe_at(1 - target.rank, target.column)
		if other != null and other != target and not out.has(other) and not out_of_reach(other):
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
			if foe != target and not out.has(foe) and not out_of_reach(foe):
				out[foe] = AREA_ALL
	return out


## The number a foe in a shape takes in place of the roll: the row's (Spread's or Splash's),
## the column's (Penetrate's or Splash's), Chain's on a conductor, and the entry's own for a foe
## a reach over every foe adds (a weapon's strikes each whole, the Whip Scorpion's release's;
## equipment's blow is nothing, the Shift Whistle's lure-all's).
static func area_number(f: Face, shape: int) -> int:
	match shape:
		AREA_ROW:
			return f.row_number()
		AREA_COLUMN:
			return f.column_number()
		AREA_CHAIN:
			return f.number_of(Face.Keyword.CHAIN)
		AREA_ALL:
			return f.power
	return 0


## What one foe reads for itself in a spend (the blow's order): the hull it is missing, on
## every blow, and on its first blow the stacks a consumer eats on it, a point each
## (per_consumed); flat, after the firer's pipeline, beside its Brittle. A debuff's blow stays
## nothing. A foe the spend did not judge (none in practice) is read now.
static func _foe_reads(f: Face, reads: Dictionary, foe: Foe, first: bool) -> int:
	if f.is_debuff():
		return 0
	var r: Array = reads.get(foe, [f.missing_bonus(foe), 0])
	return int(r[0]) + (int(r[1]) * f.per_consumed if first else 0)


## The rifle's blow on the foe to the right of a strike's target (the Macaque's Beam Rifle, Ryan,
## 19 November: "Each strike also strikes the foe to the right for 2"; "The rifle is half of a
## Spread"), before the foe's own reads, statuses and armour: its number with `prints` (what the
## entry prints from its firer), a split's halving of that base, through the firer's pipeline with
## its conditions judged on that foe, as a Spread's blow is; equipment's blow nothing, its riders
## landing all the same.
func _side_blow(ms: MechState, f: Face, side: int, prints: int, split: int, foe: Foe, ctx: Dictionary = {}) -> int:
	if f.is_debuff():
		return 0
	return int(Effects.attack(ms.unit, f, split_share(side + prints, split), 0, foe, ctx)["damage"])


## The foe to the right of `foe` in its rank (the Beam Rifle's, Ryan, 19 November: "the foe to the
## right"): a twin slot's right half beside its left, else the next slot's foe, its left half for a
## twin; none past the rank's end, in an empty slot, or out of the team's reach (Aloft). A foe the
## spend has felled still stands in its slot until the spend's death check, as an area finds it.
func right_of(foe: Foe) -> Foe:
	if foe == null or foe.rank < 0 or foe.column < 0:
		return null
	var pair := twin_of(foe)
	if pair != null and foe == foe_at(foe.rank, foe.column):
		return null if out_of_reach(pair) else pair
	var c := foe.column + 1
	if c >= columns:
		return null
	var n := foe_at(foe.rank, c)
	if n == null or n == foe or out_of_reach(n):
		return null
	return n


## One hit's blow on a foe past its own, before the foe's own reads, statuses and armour: its
## shape's number with `prints` (what the entry prints from its firer), a split's halving of that
## base, through the firer's pipeline with its conditions judged on that foe.
func _area_blow(ms: MechState, f: Face, shape: int, foe: Foe, prints: int, split: int, ctx: Dictionary = {}) -> int:
	if f.is_debuff():
		# A debuff deals nothing under any effect (Effects.attack); its Chain's arcs land the number
		# it prints, plain, no add or multiply (the Storm Petrel's lure, its Striker branch, 17
		# November: "adds Chain 3 to the lure"), and every other area of it nothing.
		return area_number(f, shape) if shape == AREA_CHAIN else 0
	return int(Effects.attack(ms.unit, f, split_share(area_number(f, shape) + prints, split), 0, foe, ctx)["damage"])


## What a blow's pipeline reads of a foe in place of its own state: the HP its hit judged it at,
## so a condition on it (unhurt, at half) holds for every blow of the hit or for none.
static func _judged(judged_hp: Dictionary, foe) -> Dictionary:
	return {"hp": int(judged_hp[foe])} if judged_hp.has(foe) else {}


## A blow's context with the zap this spend paid for (_zap_now), so the pipeline adds it where
## Empowered's add goes, on every blow of the spend, an area's and a Ricochet's among them.
func _zapped(ctx: Dictionary) -> Dictionary:
	if _zap_now > 0:
		ctx["zap"] = _zap_now
	return ctx


## The Buzzard's zap paid as a weapon's spend at a foe begins (Ryan, 11 November: "Automatically
## paid"; "when it can't pay it doesn't zap"): its cost off the shield when the shield holds it, a
## shield it takes to nothing broken like any (18 November: "being able to break its own shield is
## fine"); its damage for the spend's blows, 0 when it fires plain.
func _pay_zap(ms: MechState, f: Face) -> int:
	var dmg := zap_ready(ms, f)
	if dmg <= 0:
		return 0
	var cost := int(Effects.zap_of(ms.unit, f)["cost"])
	ms.unit.shield -= cost
	log.append("%s pays %d shield into the blow, +%d" % [ms.unit.display_name, cost, dmg])
	_note_break(ms)
	return dmg


## The twin of `foe` joins `hit` right after it, the slot reached whole: an area blow's (26 October).
func _pair_with(hit: Array[Foe], foe: Foe) -> void:
	var t := twin_of(foe)
	if t != null and not hit.has(t):
		hit.append(t)


## A foe's defend, buff or debuff action, resolved in its turn in place of a blow (the ten
## planned actions of 14 September, built 30 September). Every field is the action's;
## nothing here keys on a foe's id. `Foe.ACTION_EFFECTS` says what each kind may do.
func _foe_acts(f: Foe, t: MechState, step: Dictionary = {}) -> void:
	# The move's own special, or a step it does also (Foe.steps_of): the same effects by the
	# same rules, a step speaking under its move's name and announced with it.
	var first := step.is_empty()
	var a := f.action if first else step
	if not first and not a.has("name") and f.action.has("name"):
		a = a.duplicate()
		a["name"] = f.action["name"]
	var effect := str(a.get("effect", ""))
	var value := int(a.get("value", 0))
	if effect in ["ablate", "jam", "brittle", "dispel", "swallow", "expose", "appropriate"] and (t == null or (not first and (not t.alive() or is_out(t)))):
		log.append("%s: %s, and no machine stands to take it" % [f.display_name, str(a.get("name", effect))])
		return
	if first:
		_mended = null
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
			log.append("%s: %s, %s ×%d (armour +%d until its next turn)" % [f.display_name, str(a.get("name", "braces")), Effects.STATUS["braced"]["name"], n, n * Effects.braced_armour()])
		"recover":
			var before := f.hp
			f.hp = mini(f.hp_max, f.hp + value)
			log.append("%s: %s, recovers %d" % [f.display_name, str(a.get("name", "recovers")), f.hp - before])
		"heal":
			# Foes helping foes (15 October): the most hurt of its own by hull missing, itself
			# included, the first in the order they stand on a tie (heal_target).
			var hurt := heal_target(f)
			if hurt == null:
				log.append("%s: %s, and none of its own is hurt" % [f.display_name, str(a.get("name", "heals"))])
			else:
				var before := hurt.hp
				hurt.hp = mini(hurt.hp_max, hurt.hp + value)
				_mended = hurt
				log.append("%s: %s, heals %s for %d" % [f.display_name, str(a.get("name", "heals")), hurt.display_name, hurt.hp - before])
		"brace_all":
			# Armoured on every foe in the fight, on the one clock every Armoured runs (15
			# November): it stands through the player's turn and goes as the foes' next turn
			# opens, the foes acting after this one in the turn keeping it (turn_opens).
			var n := Effects.brace_stacks(value)
			var braced := 0
			for other in field_foes():
				if other.alive() and n > 0:
					Effects.stack(other, Effects.STATUS["braced"], Effects.SKIRMISH, "foe:" + f.content_id, n, Effects.status_decay(Effects.STATUS["braced"]))
					braced += 1
			log.append("%s: %s, %d of its own %s ×%d (armour +%d until their next turn)" % [f.display_name, str(a.get("name", "protects")), braced, Effects.STATUS["braced"]["name"], n, n * Effects.braced_armour()])
		"brace_beside":
			# Armoured on itself and on every foe beside it (the goblins' Shield Wall, Ryan, 21
			# November: "neighbors, not all"), on the one clock every Armoured runs, so walls
			# raised side by side add: three at the most on a goblin between two that wall.
			var n := Effects.brace_stacks(value)
			var walled: Array[Foe] = [f]
			walled.append_array(foes_beside(f))
			if n > 0:
				for o in walled:
					Effects.stack(o, Effects.STATUS["braced"], Effects.SKIRMISH, "foe:" + f.content_id, n, Effects.status_decay(Effects.STATUS["braced"]))
			log.append("%s: %s, %s ×%d on itself and %d beside it (armour +%d until their next turn)" % [f.display_name, str(a.get("name", "walls")), Effects.STATUS["braced"]["name"], n, walled.size() - 1, n * Effects.braced_armour()])
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
			if bool(a.get("refill", false)):
				count = mini(count, refill_short(f, a))   # never more of the kind than rode out
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
			# Empowered lands at once on every foe on the field, the rallier too (Ryan, 15 November:
			# "Buff itself too. Helps with low foe counts"; every other foe until then), at the
			# move's own value in stacks (Ryan, 26 October: "howl is more clear if it gives kindled
			# for the next action, which could be the turn its granted"): one acting after the
			# rallier this turn hits harder now, and every intent showed it from the round's start
			# (incoming_rally). The stacks halve as its own turn ends, like a machine's (Ryan, 4
			# November: one clock on both sides), so one that has acted, the rallier among them,
			# carries half to the next round; two rallies add.
			var rallied := 0
			for other in field_foes():
				if other.alive():
					Effects.stack(other, Effects.STATUS["kindled"], Effects.SKIRMISH, "foe:" + f.content_id, maxi(0, value), Effects.DECAY_HALF)
					rallied += 1
			log.append("%s: %s, %d hit %d harder, halving each turn" % [f.display_name, str(a.get("name", "rallies")), rallied, value])
		"drain_rerolls":
			# A move's, in the enemy's turn (a fall's drain left with the roots' scream, 19
			# November): the screen strikes the REROLL button as each lands.
			reroll_debt += maxi(0, value)
			turn_drains.append({"foe": f, "value": maxi(0, value), "seq": _seq})
			_seq += 1
			log.append("%s: %s, the team loses %d reroll%s next round" % [f.display_name, str(a.get("name", "roars")), value, "" if value == 1 else "s"])
		"golden":
			# The Thunder Ape's Golden Rage (4 November): a mode for the rounds the move says, its
			# blows harder by the move's value and a point of plate; a quarter of its HP lost from
			# here breaks it and it staggers (_break_golden), a Suppress breaks it too (_suppress).
			var rounds := clampi(int(a.get("rounds", 3)), 1, 5)
			Effects.grant_for_rounds(f, Effects.golden(maxi(1, value)), "golden", round + rounds)
			f.golden_mark = f.hp
			log.append("%s: %s, its blows %d harder and a point of armour for %d round%s; %d more damage breaks it" % [f.display_name, str(a.get("name", "goes gold")), maxi(1, value), rounds, "" if rounds == 1 else "s", golden_left(f)])
		"ablate":
			# A Ward turns away every rider a foe lays on its machine, a special's as a blow's
			# (Ryan, 25 October: "Should stop all riders, even from non-damaging attacks").
			if Effects.has(t.unit, "ward"):
				log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "stokes")), t.unit.display_name])
			else:
				_fire_on(t, "ablating_mech", maxi(1, value), f)
				log.append("%s: %s, Ablating ×%d on %s" % [f.display_name, str(a.get("name", "stokes")), maxi(1, value), t.unit.display_name])
		"brittle":
			# Brittle on its target, a curse (the Mandragora's scream on its killer, 19 November):
			# a point more on every blow a foe lands on it a stack, halving as its turn starts.
			if Effects.has(t.unit, "ward"):
				log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "curses")), t.unit.display_name])
			else:
				_fire_on(t, "brittled_mech", maxi(1, value), f)
				log.append("%s: %s, Brittle ×%d on %s" % [f.display_name, str(a.get("name", "curses")), maxi(1, value), t.unit.display_name])
		"brittle_all":
			# Brittle on every machine in the fight (the higher roots' scream, 19 November).
			var cracked: Array[String] = []
			for ms in targetable_mechs():
				if Effects.has(ms.unit, "ward"):
					log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "curses")), ms.unit.display_name])
					continue
				_fire_on(ms, "brittled_mech", maxi(1, value), f)
				cracked.append(ms.unit.display_name)
			log.append("%s: %s, %s Brittle ×%d" % [f.display_name, str(a.get("name", "curses")), ", ".join(cracked) if not cracked.is_empty() else "nobody", maxi(1, value)])
		"sap_all":
			# Sapped on every machine in the fight (the Fell Rider's Shriek, 20 November): its
			# attacks a point lower a stack through its next turn, gone as that turn ends.
			var sapped: Array[String] = []
			for ms in targetable_mechs():
				if Effects.has(ms.unit, "ward"):
					log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "saps")), ms.unit.display_name])
					continue
				_fire_on(ms, "sapped", maxi(1, value), f)
				sapped.append(ms.unit.display_name)
			log.append("%s: %s, %s Sapped ×%d" % [f.display_name, str(a.get("name", "saps")), ", ".join(sapped) if not sapped.is_empty() else "nobody", maxi(1, value)])
		"swallow":
			_swallow(f, t, maxi(1, value))
		"expose":
			# Exposed on a machine (Ryan, 15 November): a move of its own here, a rider on a blow in
			# _strike. A Ward turns it away as it turns every rider.
			if Effects.has(t.unit, "ward"):
				log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "exposes")), t.unit.display_name])
			else:
				_expose_mech(f, t, str(a.get("name", "exposes")))
		"jam":
			# The entry the die shows is Jammed, switched off until the machine reboots, no blow.
			if Effects.has(t.unit, "ward"):
				log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "hushes")), t.unit.display_name])
			elif t.face_index >= 0:
				Effects.disable_entry(t.unit, t.face_index, "foe:" + f.content_id, Effects.JAM_REBOOT)
				log.append("%s: %s, %s's %s is jammed" % [f.display_name, str(a.get("name", "hushes")), t.unit.display_name, t.die.faces[t.face_index].describe()])
		"appropriate":
			# Gilgamesh's own rule (30 October, the slate's signature: "takes the weapon a machine
			# shows and fights with it; now and then the piece it took is a fake"; a step of his
			# Collect since 16 November, on Ryan's mark: "It grants Jammed on the target, and
			# Gilgamesh gains Appropriated with the value"): the foe gains Appropriated, the number
			# of the entry the machine's die shows, a weapon's printed blow and 1 for anything
			# else, the fake. What it held is replaced: one piece at a time. It acts on the
			# machine, so a Ward turns it away as it turns the jam it follows.
			if Effects.has(t.unit, "ward"):
				log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "takes")), t.unit.display_name])
			elif t.face_index >= 0:
				var taken: Face = t.die.faces[t.face_index]
				Effects.remove(f, "appropriated")
				Effects.stack(f, Effects.STATUS["appropriated"], Effects.SKIRMISH, "foe:" + f.content_id, stolen_number(taken), Effects.DECAY_NONE)
				log.append("%s: %s, it takes %s's %s%s: %s ×%d" % [f.display_name, str(a.get("name", "takes")), t.unit.display_name, taken.describe(),
					"" if taken.is_weapon() else ", a fake", Effects.STATUS["appropriated"]["name"], Effects.stacks_of(f, "appropriated")])
		"cleanse":
			# A foe's cleanse (28 October, the Marsh's lever: "debuffs are hard here"): every mark
			# the team laid off the most-marked of its own, itself included; never Numbed, never
			# Suppressed, never a buff.
			# A cleanse that follows a heal in one move has the heal's patient (the Cleric's Cure,
			# Ryan's yes of 17 November: "Cure heals 4, then cleanses the same foe").
			var same: bool = not first and _mended != null and _mended.alive()
			var marked: Foe = _mended if same else cleanse_target(f)
			if marked == null:
				log.append("%s: %s, and none of its own carries a mark" % [f.display_name, str(a.get("name", "cleanses"))])
			else:
				var gone := Effects.clear_marks(marked)
				if gone.is_empty():
					log.append("%s: %s, and %s carries no mark to lift" % [f.display_name, str(a.get("name", "cleanses")), marked.display_name])
				else:
					log.append("%s: %s, %s loses %s" % [f.display_name, str(a.get("name", "cleanses")), marked.display_name, ", ".join(gone).to_lower()])
		"phase":
			# A foe's Phased (foe_phased), its own move or a step of one: the wait for it, as a
			# machine's is laid, landing as the round ends (_land_phases). A foe Phased already
			# gains none, so none is out two rounds running.
			if not fade_lands(f):
				log.append("%s: %s, and it cannot fade again so soon" % [f.display_name, str(a.get("name", "fades"))])
			else:
				Effects.stack(f, Effects.STATUS["phasing"], Effects.SKIRMISH, "foe:" + f.content_id, 1, Effects.DECAY_NONE)
				log.append("%s: %s, and it fades as the round ends" % [f.display_name, str(a.get("name", "fades"))])
		"unready_all":
			# The Lich's fall (Ryan's yes of 17 November to the bench's row: "Killed, every foe it
			# readied loses its readiness to rise"): every other foe still standing loses the
			# Undying this foe's kind gave it. What a foe readied for itself is its own and
			# stays, and one felled by the same blow has fallen with its readiness: it gets up.
			var lost: Array[String] = []
			for other in field_foes():
				if other == f or not other.alive():
					continue
				var keep: Array = []
				var stripped := false
				for m in other.modifiers:
					if m.id == "risen" and m.source == "foe:" + f.content_id:
						stripped = true
					else:
						keep.append(m)
				if stripped:
					other.modifiers = keep
					lost.append(other.display_name)
			if lost.is_empty():
				log.append("%s: %s, and nothing it readied still stands" % [f.display_name, str(a.get("name", "falls"))])
			else:
				log.append("%s: %s, %s will not get back up" % [f.display_name, str(a.get("name", "falls")), ", ".join(lost)])
		"barrier":
			# A foe's Barrier (28 October, the Waste's burrow by lean): the next weapon blow it
			# takes deals nothing, its riders landing; a debuff pops nothing; it goes as its next
			# turn starts if nothing pops it (the foes' turn opening, the end of the player's).
			Effects.stack(f, Effects.foe_barrier(), Effects.SKIRMISH, "foe:" + f.content_id, 1, Effects.DECAY_ROUND)
			log.append("%s: %s, the next weapon blow on it deals nothing" % [f.display_name, str(a.get("name", "shelters"))])
		"ward_all":
			# A sanctuary (28 October, the Marsh's by lean): a Ward on every foe on the field,
			# itself included, until its next turn starts; no mark the team lays
			# lands, Suppressed excepted, and the damage does.
			var warded := 0
			for other in field_foes():
				if other.alive():
					Effects.stack(other, Effects.foe_ward(), Effects.SKIRMISH, "foe:" + f.content_id, 1, Effects.DECAY_ROUND)
					warded += 1
			log.append("%s: %s, %d of its own warded against the team's marks" % [f.display_name, str(a.get("name", "hallows")), warded])
		"prime":
			# A stoker (28 October, the Peak's by lean): Primed, its value in stacks, on every other
			# foe on the field at once, as a rally's Empowered lands; each foe's next moves that
			# strike spend a stack each, their blows leaving Ablating 1 (15 November).
			var primed := 0
			for other in field_foes():
				if other != f and other.alive():
					Effects.stack(other, Effects.primed_foe(), Effects.SKIRMISH, "foe:" + f.content_id, maxi(1, value), Effects.DECAY_NONE)
					primed += 1
			log.append("%s: %s, %d Primed ×%d" % [f.display_name, str(a.get("name", "stokes")), primed, maxi(1, value)])
		"regenerate":
			# Regenerating on itself (28 October, the Marsh's by lean), its value in stacks: a point
			# a stack at each of its actions, after its ticks, a stack fading each (15 November).
			Effects.stack(f, Effects.STATUS["regenerating"], Effects.SKIRMISH, "foe:" + f.content_id, maxi(1, value), Effects.DECAY_TICK)
			log.append("%s: %s, Regenerating ×%d" % [f.display_name, str(a.get("name", "knits")), Effects.stacks_of(f, "regenerating")])
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
## just spent (a copy of it may come up), a stepping die stepping; a folded die among its live
## entries, so a Changeover's roll lands on the battery it raised. Instant's roll (`itself`) is a
## true roll over every live entry, itself included, a spin on a stepping die.
func _act_again(ms: MechState, itself := false) -> void:
	if previewing:
		ms.assigned = false   # it acts again; the copy's die keeps its entry, a roll never promised
		return
	_rolled()
	var live := Effects.live_entries(ms.unit, ms.die)
	if itself:
		ms.face_index = ms.die.roll_among(rng, live)
	elif Effects.steps_die(ms.unit):
		ms.face_index = _step(ms)
	else:
		ms.face_index = ms.die.reroll_among(rng, live, ms.face_index)
	ms.assigned = false


## The entries a one-of-each machine's die may flip to once `spent` is out (Effects.one_of_each,
## the Needletail's Quick-turn Avionics Relay): its lit entries of the other kind, equipment for
## a weapon and weapons for equipment, each read as the machine has it; once the other kind has
## been spent this round it is on cooldown, so there is none. None on a machine without the
## rule, for a Rapid or Instant spend (it acts again by its own rule), or for a spend that is
## neither kind (a shield, a vent, a blank).
func turn_entries(ms: MechState, spent: Face) -> Array[int]:
	var out: Array[int] = []
	if ms == null or spent == null or not ms.alive() or not Effects.one_of_each(ms.unit) or spent.acts_again():
		return out
	var kind := _turn_kind(ms, spent)
	if kind == 0:
		return out
	for at in range(ms.die.faces.size()):
		if not Effects.is_entry_disabled(ms.unit, at) and _turn_kind(ms, ms.die.faces[at]) == 3 - kind:
			out.append(at)
	return out


## An entry's kind for the turn: 1 a weapon, 2 equipment (a buff or a debuff), 0 neither.
func _turn_kind(ms: MechState, f: Face) -> int:
	var as_fired := Effects.rewritten(ms.unit, f)
	if as_fired == null:
		return 0
	return 1 if as_fired.is_weapon() else (2 if as_fired.is_equipment() else 0)


## The one entry a one-of-each machine's die turns to once the entry showing is spent, as the
## die would show it; null when its second action is spent, when it has none to turn to, or
## when several stand and the turn is a draw among them. The die's passive box shows it.
func turn_face(ms: MechState) -> Face:
	if ms == null or ms.assigned or ms.face() == null:
		return null
	var entries := turn_entries(ms, spend_face(ms))
	return shown_face(ms, ms.die.faces[entries[0]]) if entries.size() == 1 else null


## Its place on the die, from 0; -1 with turn_face's null.
func turn_index(ms: MechState) -> int:
	if ms == null or ms.assigned or ms.face() == null:
		return -1
	var entries := turn_entries(ms, spend_face(ms))
	return entries[0] if entries.size() == 1 else -1


## Turn a die to one of `entries` and give its machine the turn back: the one, with no draw (so
## the undo reaches past it), or a draw among several. A preview's copy takes the first, a
## stand-in of the right kind and never a promise.
func _turn_die(ms: MechState, entries: Array[int]) -> void:
	ms.assigned = false
	if previewing or entries.size() == 1:
		ms.face_index = entries[0]
		return
	_rolled()
	ms.face_index = entries[rng.randi_range(0, entries.size() - 1)]


# ---------------------------------------------------------------- the Musk Ox's

## What this gun costs its machine in ammo now (the Musk Ox's Desublimation Forge, Ryan's go of
## 21 October): the whole magazine for the salvo, at least its gate (magazine_min: under it the
## salvo cannot fire); the forge's price for any other
## weapon; nothing on a machine that forges nothing, or for anything but a weapon.
func ammo_price_of(ms: MechState, f: Face) -> int:
	if ms == null or ms.ammo_max <= 0 or f == null or not f.is_attack():
		return 0
	if f.spends_magazine:
		return maxi(maxi(1, f.magazine_min), ms.ammo)   # the whole magazine, and never under its gate: short of it the gun is dry
	return Effects.ammo_price(ms.unit, f)


## Can the magazine pay for this entry (a dry gun cannot be spent)?
func can_fire(ms: MechState, f: Face) -> bool:
	var price := ammo_price_of(ms, f)
	return price <= 0 or ms.ammo >= price


## The first entry with a condition on its play (Ryan, 26 October, the shield cost: "if you don't
## have the shield, the face cannot be played"): true while the machine's shield
## is short of the entry's shield cost. Every target list reads it, so the die has
## nowhere to land, the screen's drag finds no target, the bot passes it over and END TURN
## pulses; the die shows the cost struck through (Face.short, shown_face). The pattern for any
## conditional entry to come.
func shield_short(ms: MechState, f: Face) -> bool:
	return f != null and f.shield_cost > 0 and ms.unit.shield < f.shield_cost


## The second: an entry that spends a count of its machine's for what it grants (Face.spends, the
## Quintessence Tap's Essence) cannot be played while the machine holds none of it.
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


# ---------------------------------------------------------------- the Swallowtail's

## The Phased trial's grant (phase_at_once): Phased now, out of reach of both sides until the round
## ends, and every foe whose pick it was draws its pick again from the machines in reach, as the
## round's opening draws one, so its intent moves under the player's eyes.
func _phase_at_once(w: MechState, src: String) -> void:
	Effects.grant_for_rounds(w.unit, Effects.STATUS["phased"], src, round)
	log.append("%s is Phased: out of reach until the round ends" % w.unit.display_name)
	for foe in field_foes():
		if foe.alive() and foe.target == w and foe.aims_at_one():
			foe.target = _pick_mech_target(foe)


## Phased lands (Ryan, 15 November: granted "at the end of this round", "with the caveat that
## you have to survive the current round"): as the enemy's turn ends, every machine that waits
## for it and still stands is Phased through the next round's end, out of reach of both sides
## and acting all the same. A machine wrecked this turn never phases; a Purge that took the wait
## took the Phased with it. The foes announce the next round with it out of reach already, so no
## pick moves under the player.
func _land_phases() -> void:
	for ms in live_mechs():
		if paused(ms) or not Effects.remove(ms.unit, "phasing"):
			continue   # a Swallowed machine's wait pauses with the rest, and lands at the end of the round it is back in
		Effects.grant_for_rounds(ms.unit, Effects.STATUS["phased"], "buff", round + 1)
		log.append("%s is Phased: out of reach until the next round's end" % ms.unit.display_name)
	# A foe that waits for it (a step of its move, `phase`) fades the same way, if it still
	# stands, and never the last foe standing: a fight has a foe to end on.
	for f in field_foes():
		if not Effects.remove(f, "phasing") or not f.alive():
			continue
		var others := 0
		for o in field_foes():
			if o != f and o.alive():
				others += 1
		if others == 0:
			log.append("%s does not fade: it is the last one standing" % f.display_name)
			continue
		Effects.grant_for_rounds(f, Effects.STATUS["phased"], "foe:" + f.content_id, round + 1)
		log.append("%s fades: out of reach until the next round's end" % f.display_name)


# ---------------------------------------------------------------- a swallow and what a foe takes (30 October)

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
## keeping the slot alone); the merger regrows the HP they had left and gains the move's value in
## Empowered for each, its own, halving as its turn ends like any, so thinning them first is the
## answer.
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
		# Its own Empowered, gained in its own turn like a rallier's share of its rally: it
		# halves as that turn ends, so half reaches its next blow.
		Effects.stack(f, Effects.STATUS["kindled"], Effects.SKIRMISH, "foe:" + f.content_id, lift, Effects.DECAY_HALF)
	log.append("%s: %s, %d taken in, regrows %d, Empowered ×%d" % [f.display_name, str(a.get("name", "merges")), taken, f.hp - before, lift])
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


## The number an entry a foe takes swings for (the `appropriate` step, Gilgamesh's): a weapon's
## printed blow, anything else 1, the fake.
static func stolen_number(face: Face) -> int:
	if face == null or not face.is_weapon():
		return 1
	return maxi(1, face.power)


## A die rolled, any machine's (the Swallowtail's Muster, Ryan's go of 21 October): every machine
## that musters gains a sliver.
func _rolled() -> void:
	for ms in live_mechs():
		_muster(ms, 1)


## Points on a machine's Muster, up to its cap (a store, which nothing a foe does takes); a charge
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
## The keywords a Mine carries once each: a stun or a mark it lays (Suppress, Shock, Expose) and
## Disrupt; a rule written on one piece (ignores armour, a web, a swap, a spill) stays with the
## piece, so a Mine's blast always meets armour and webs nothing. Ryan, 9 November: "Area
## modifiers, targeting rules (sweep), and hit counts are ignored. Anything that ties it back to
## the firer is ignored, like lure": Spread and Penetrate are area, Rapid the spend's own, Lure
## the firer's; the hits count in the stacks they fired, never in the Mine's damage.
const MINE_FLAGS := [Face.Keyword.SHOCK, Face.Keyword.SUPPRESS, Face.Keyword.EXPOSE, Face.Keyword.DISRUPT]


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
	for k in [Face.Keyword.ABLATE, Face.Keyword.CRYO, Face.Keyword.BRITTLE, Face.Keyword.SAP]:
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
## the keyword that lays it where one does ("Mine 6: Ablate 4, Brittle 3, Vitriol 2, Shock").
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
## and the spend's riders join the Mine the foe carries, one Mine a foe, a reach over every foe's on
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
			# The slot's own foe carries the Mine, and what a foe carries is its own; a neighbour
			# out of the team's reach (Aloft) is passed over, and nothing damages a Phased foe.
			if foe.alive() and not out.has(foe) and not foe_phased(foe) and (slot == at[0] or not out_of_reach(foe)):
				out.append(foe)
	return out


## A Mine blowing at a slot (Ryan, 9 November): one plain blow of its damage on every foe its reach
## meets (mine_reach), each through its own reads (its Brittle, a Barrier, what it takes; aimed at
## nobody, so a Shock neither doubles it nor is spent) and its armour, and
## Chain's number on every other Shocked foe on the field; then its riders on each foe it met,
## felled or not, as a hit's land: every status's stacks it carries (Ablating, Cryo, Brittle, a
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
		taken = maxi(0, taken - foe.armour_total())
		foe.hp -= taken
		_note_blow(foe, beat, taken, "mine")
		mine_tally["damage"] += clampi(taken, 0, maxi(0, hp_before))
		log.append("the Mine %s %s for %d" % ["arcs to" if arcs.has(foe) else "hits", foe.display_name, taken])
	var gained := {}
	var turned := {}
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
			_foe_gained_status(foe, status_id, int(gained[foe][status_id]))


## A mark a Mine's blast lays after its blow, Shocked or Exposed (through the player's next
## turn, renewing), or noted turned away by a Ward.
func _mine_mark(foe: Foe, sid: String, gained: Dictionary, turned: Dictionary) -> void:
	if not Effects.turns_mark(foe, sid):
		if sid == "exposure":
			Effects.grant_for_rounds(foe, Effects.STATUS["exposure"], "mech", round)   # it falls as its turn starts, the first after this round (Effects.turn_opens)
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
	# What halves on hull damage (Ricochet: Ryan, 11 November, "Lose half stacks of Ricochet on any
	# hull damage"), at each blow, bite or overheat that takes hull.
	var halved := Effects.halve_on_hull_damage(ms.unit)
	if not halved.is_empty():
		log.append("%s: its hull takes the hit, %s" % [ms.unit.display_name, ", ".join(halved)])


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
## Exposed on a foe (renewing, never adding): in Direct reach of every machine and its armour
## counting for nothing, through the player's next turn: it falls as the foe's turn starts in
## the next round (Ryan, 16 November: "Exposed on next turn start"; the next round's end until
## then, an enemy turn longer and no blow of the team's apart).
func _expose(foe: Foe, by: MechState, turned = null) -> void:
	if Effects.turns_mark(foe, "exposure"):
		_turned_away(foe, "exposure", turned, by)
		return
	Effects.grant_for_rounds(foe, Effects.STATUS["exposure"], "mech", round)
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


## The primers (Ryan, 2 November; keywords since 3 November; Primed the third since 15 November):
## Charged, Supercooled and Primed ride the weapons a machine fires as Shock, as Cryo and as
## Ablate, one more a strike (Effects.effective_face), and a weapon fired or laid spends a stack
## of each: a Rapid's second fire is a second fire, a salvo one, a passed turn's release none,
## and equipment spends nothing.
func _spend_primers(ms: MechState) -> void:
	for id in ["charged", "supercooled", "primed"]:
		if Effects.stacks_of(ms.unit, id) <= 0:
			continue
		Effects.spend_stacks(ms.unit, id, 1)
		log.append("%s: %s spent on the fire (%d left)" % [ms.unit.display_name, str(Effects.STATUS[id]["name"]), Effects.stacks_of(ms.unit, id)])


## What a spend at a foe lays on its own machine (Face.self_statuses as its machine's branches make
## it: the Hardlight Pulse's Hardened Light, the Defence direction's Ward, the Striker's Charged;
## Ryan, 18 November): each status its stacks, or its stacks for every foe the spend reached when it
## says per_foe (a Spread's neighbours among them), up to its cap, on the clock its definition
## names. A machine's Regenerating is the status in a machine's words (shield). Bought by a die
## entry, so a foe's Purge takes it.
func _self_grants(ms: MechState, f: Face, reached: int) -> void:
	for g in f.self_statuses:
		var id := str(g.get("status", ""))
		if not Effects.STATUS.has(id):
			continue
		# A set for every foe the spend reached, beside the flat stacks a `plus` says (the Beam
		# Pavise's "Gain 1 Armoured, plus 1 Armoured for every foe struck").
		var each := bool(g.get("per_foe", false))
		var n := maxi(1, int(g.get("stacks", 1))) * (maxi(0, reached) if each else 1) + (maxi(0, int(g.get("plus", 0))) if each else 0)
		var cap := int(g.get("cap", 0))
		if cap > 0:
			n = mini(n, maxi(0, cap - Effects.stacks_of(ms.unit, id)))   # up to its cap (Hardened Light's 3, 4 or 5)
		if n <= 0:
			continue
		var def: Dictionary = Effects.regenerating_mech() if id == "regenerating" else Effects.STATUS[id]
		Effects.stack(ms.unit, def, Effects.status_scope(def), "buff:" + f.component, n, Effects.status_decay(def))
		log.append("%s gains %s ×%d" % [ms.unit.display_name, str(def["name"]), Effects.stacks_of(ms.unit, id)])
		if id == "barrier":
			_fired(ms, Effects.fire(ms.unit, "on_barrier"), "as it gains a Barrier")   # gaining a Barrier, whatever lays it (the Beam Buckler's)


## The offhand takes up its form at `at` in the cycle (the Macaque's, Ryan, 19 November): its chip
## and its riders, the form's own (Effects.hold_form). A machine with no offhand takes nothing.
func _take_up_form(ms: MechState, at: int) -> void:
	var forms := Effects.offhand_forms(ms.unit)
	if forms.is_empty():
		ms.offhand = -1
		return
	ms.offhand = posmod(at, forms.size())
	Effects.hold_form(ms.unit, forms[ms.offhand])


## The offhand turns to its next form, the first after the last (Ryan, 19 November: "It cycles after
## a spend"): after every weapon and equipment the machine spends at a foe, so the next one rides it.
func _turn_offhand(ms: MechState) -> void:
	if ms.offhand < 0:
		return
	_take_up_form(ms, ms.offhand + 1)
	log.append("%s's offhand turns: %s" % [ms.unit.display_name, Effects.held_form(ms.unit)])


## The Parry's return as its machine's turn opens (the Beam Buckler's, Ryan, 19 November: "The first
## weapon fired next turn gains bonus damage equal to half of all damage blocked by this machine this
## round (rounded down)"): half of what it counted, rounded down, stands as the first weapon's add
## this turn, a point a stack on every strike, lifted by that weapon and gone as the turn ends if
## none fires; the count starts again with the next Parry. Before the turn's opening takes the Parry.
func _parry_returns(ms: MechState) -> void:
	var count := ms.parried
	ms.parried = 0
	if not Effects.has(ms.unit, "parry") or not ms.alive():
		return
	var back := int(count / 2.0)
	if back <= 0:
		log.append("%s's Parry turned nothing aside" % ms.unit.display_name)
		return
	Effects.stack(ms.unit, Effects.STATUS["parry_strike"], Effects.SKIRMISH, "parry", back, Effects.DECAY_AFTER_TURN)
	log.append("%s's Parry returns: its first weapon this turn deals %d more a strike" % [ms.unit.display_name, back])


## A strike's rider landing on its foe once the strikes are done, felled or not (death is the
## spend's last check): `n` stacks of a status, told once (gained) or turned away by its Ward
## (turned); a passive's lay is tallied for the log (laid).
func _land_rider(foe: Foe, sid: String, n: int, gained: Dictionary, turned: Dictionary, laid = null) -> void:
	if n <= 0:
		return
	Effects.stack(foe, Effects.STATUS[sid], Effects.SKIRMISH, "mech", n, Effects.status_decay(Effects.STATUS[sid]))
	_note_status(gained, foe, sid, turned, n)
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
## (_land_blow: the weapon's damage, so a Barrier takes it, then its armour); it
## counts as the spend's kill where it fells one and carries no keyword of the blow, and, aimed at nobody, it
## neither doubles on a Shock nor spends one (29 October). A foe behind
## that the blow already reaches (a penetrate) takes the strike itself, never a spill too, and
## one already fallen takes nothing: nothing stands behind the back rank, so the damage is lost.
## `strike`: the strike it spills from, for the blow it records. `whole`: a later strike's whole
## number, a weapon's, which lands as its blow even at 0 (its Brittle added); a kill's excess of 0
## carries nothing.
func _spill(ms: MechState, f: Face, foe: Foe, amount: int, hit: Array[Foe], strike: int, whole: bool = false) -> void:
	var behind: Foe = back[foe.column] if foe.column >= 0 and foe.column < columns else null
	if (amount <= 0 and not whole) or behind == null or not behind.alive() or hit.has(behind) or out_of_reach(behind):
		return
	var behind_taken := int(_land_blow(behind, amount, ms.unit, true, false, behind.armour_total(), strike, "spill")["taken"])
	log.append("%s spills over: %d into %s" % [ms.unit.display_name, behind_taken, behind.display_name])


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
func _suppress(foe: Foe, turned = null, ahead: bool = false) -> bool:
	# A foe that has already acted this turn loses its next action instead of one it has taken,
	# and so does one that stepped up mid-round (a split's half), the round's turn being over;
	# `ahead` says the round itself is over (a web's burst), so every foe loses its next.
	var next := ahead or _acted.has(foe) or foe.fresh
	if foe.immune_to("suppress"):
		log.append("%s is immune: no stun lands on it" % foe.display_name)
		return false   # its own Ability (Foe.immune): nothing gained, and nothing for the Paradox
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


## The Suppressed that cost a foe this round's turn, gone as that turn ends; one laid for its
## next action (on a foe that had acted, or one that stepped up this round) stays for it.
func _spend_suppress(f: Foe) -> void:
	f.modifiers = f.modifiers.filter(func(m) -> bool: return not (m.id == "suppressed" and m.scope == Effects.ROUNDS and m.expires_round <= round))


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
static func _note_status(gained: Dictionary, foe: Foe, status_id: String, turned = null, n: int = 1) -> void:
	if Effects.turns_mark(foe, status_id):
		# A foe's Ward turned it away (28 October): nothing gained, nothing for the Paradox, and
		# the spend tells it once.
		if turned is Dictionary and foe.alive():
			_note_turned(turned, foe, status_id)
		return
	# Each status the foe gained and the stacks it gained of it (the Paradox counts stacks since 11
	# November); a status that never stacks gains one.
	var got: Dictionary = gained.get(foe, {})
	got[status_id] = int(got.get(status_id, 0)) + maxi(1, n)
	gained[foe] = got


## A mark a foe's Ward turned away (28 October), noted once a spend.
static func _note_turned(turned: Dictionary, foe: Foe, status_id: String) -> void:
	var ids: Array = turned.get(foe, [])
	if not ids.has(status_id):
		ids.append(status_id)
	turned[foe] = ids


## A mark a foe's Ward turned away outside a spend's own count (a Mine's blast):
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
## A status the team put on a foe, `n` its stacks gained (the Baboon's Pocket Paradox, Ryan, 11
## November: "When an enemy gains one or more debuff stacks other than Paradox, it also gains that
## many Paradox stacks"; "Shocked and such are a stack, it just caps at 1, so yes they grant 1
## paradox"): a debuff alone feeds the meter, a stack of Paradox a stack, and at its count it is
## spent into a Suppress ("At five or more, consume all stacks to grant Suppressed").
func _foe_gained_status(foe: Foe, status_id: String, n: int = 1) -> void:
	if status_id == "paradox" or status_id == "numbed" or Effects.status_kind(status_id) != "debuff" or Effects.turns_mark(foe, status_id):
		return   # a felled foe's gains count too: a trigger never goes unfired for a death checked last (3 November)
	for ms in live_mechs():
		var meter := Effects.paradox(ms.unit)
		if meter[1] <= 0:
			continue
		Effects.stack(foe, Effects.STATUS["paradox"], Effects.SKIRMISH, "mech", _stacks_from(ms, "paradox", meter[0] * maxi(1, n)), Effects.DECAY_NONE)
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
	if is_out(ms):
		log.append("%s lures nothing: nothing may target it" % ms.unit.display_name)
		return   # a Phased spender cannot be targeted, so no pick turns on it
	var turned: Array[String] = []
	var idle: Array[String] = []
	for foe in foes:
		if foe.fresh:
			continue   # one that stepped up mid-round has had its round: nothing to turn
		if not foe.aims_at_one():
			idle.append(foe.display_name)   # a move at every machine or at nobody holds no pick
		elif foe.target != ms:
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
		if foe.immune_to("disrupt"):
			# Its own Ability (Foe.immune): a gather no Disrupt breaks off, the warning being the
			# fight (the Obsidian Tyrant's Firestorm, the Ruby Colossus's Ultima); a Suppress
			# still holds it a round.
			log.append("%s is immune: no Disrupt turns it from %s" % [foe.display_name, str(foe.action.get("name", ""))])
			continue
		var next := disrupt_next(foe)
		if next.is_empty():
			log.append("%s is disrupted, and has nothing else to do" % foe.display_name)
			continue
		var was := str(foe.action.get("name", ""))
		var aimed: bool = foe.aims_at_one()   # the move it leaves held a pick, its intent, shown
		foe.pending = {}   # a gathered move is broken off
		foe.charge = 0
		Effects.remove(foe, "aloft")   # and a foe that climbed for it comes down with it
		foe.action = next
		foe.last_special = "" if foe.attacks() else str(foe.action.get("id", ""))
		_begin_countdown(foe)
		# Its pick holds (Ryan, 26 October: the intent moves on a Disrupt "only if the disrupt would
		# result in an invalid target"): a new one when the machine is gone or Phased, or when the
		# move it leaves aimed at no one machine (a brace, a blow at every machine) and so held no
		# pick; and none at all when the move it turns to is aimed at no one machine.
		var t := foe.target as MechState
		if not foe.aims_at_one():
			foe.target = null
		elif t == null or not t.alive() or is_out(t) or not aimed:
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
## cleansable status (a foe's jam, Corrupted, Ablating, Scorched), and the log says which.
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


## Shield gained from any source, capped at the maximum; gaining any fires the on_shield_gain
## passives (which may shed heat, never raise shield). Returns what stood up.
func _gain_shield(ms: MechState, amount: int) -> int:
	if amount <= 0:
		return 0
	_note_break(ms)
	if ms.shield_broken:
		return 0   # a broken shield gains none by any method until its machine reboots: no regen, no passive, no entry raises it
	var gained := ms.unit.recharge_shield(amount)
	if gained > 0:
		_fired(ms, Effects.fire(ms.unit, "on_shield_gain", gained), "on the shield")
	return gained


## A shield component spent on an ally fires the spender's on_shield_granted passives on
## that ally (the Phase Conjugator's Armoured): heat the ally sheds, statuses it gains. Fires
## on the spend, whatever the shield gained.
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


## The Puffin's pull (on_buff_granted's pull_heat; Ryan, 11 November: "Using an equipment on an
## ally moves some of its heat to the Puffin"; 19 November, "I think 4 for the Puffin"): a piece of
## equipment spent on an ally takes up to the passive's number of that ally's heat, the stacks past
## its maximum first (heat is one gauge), onto the spender, through the heat path, so a passive
## on heat gained answers it and the spender may pass its own maximum. Fires on the spend, whatever
## the equipment did.
func _pull_heat(ms: MechState, who: MechState) -> void:
	var r := Effects.fire(ms.unit, "on_buff_granted", 0, who.unit)
	var pulled := mini(who.heat, int(r["pull"]))
	if pulled <= 0:
		return
	who.heat -= pulled
	_add_heat(ms, pulled, ms.face_index)
	log.append("%s takes %d heat off %s" % [ms.unit.display_name, pulled, who.unit.display_name])


## The Puffin's dump (Face.passes_heat; Ryan, 11 November: "A locked piece can transfer the
## Puffins heat to another unit along with a buff based on heat moved", "just allies", "forcing an
## overheat for hull damage"): its machine's whole heat, its overheat with it, passes onto the ally
## it is spent on, through the heat path (the ally's on_heat_gain answers it: the Storm Petrel's
## shield) and past that ally's maximum too. Returns the stacks it grants: one for every
## heat_per_stack passed, rounded down.
func _pass_heat(ms: MechState, who: MechState, f: Face) -> int:
	var passed := ms.heat
	if passed <= 0 or who == ms:
		return 0
	ms.heat = 0
	log.append("%s passes %d heat to %s" % [ms.unit.display_name, passed, who.unit.display_name])
	_add_heat(who, passed)
	return passed / maxi(1, f.heat_per_stack)


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


## The end of the player's turn: every machine past its maximum burns (overheat_scale a point,
## a runner's what-if), and the gauge stays where it stands.
func _burn_overheated() -> void:
	for ms in live_mechs():
		var over := ms.heat - ms.heat_max
		if over > 0:
			_burn_stacks(ms, over)


## A machine's burn as the player's turn ends (Ryan, 13 November: "the overheat
## damage stacks, damages the hull every turn for the total stacks, and keeps building until the
## player is essentially forced to reboot, or die"): the heat a machine carries past its maximum
## stays, and every point of it burns hull, every turn it stands there. The first such turn since
## its last reboot is its overheat: its shield breaks, and what an overheat sets off fires, once
## between reboots. A machine giving this turn to a reboot has vented as its shield dropped
## (reboot_mech; Ryan, 17 November), so it carries nothing to burn, and no rule spares it: what
## lands on it after burns like any. One out of reach does not burn: a Swallowed machine cannot
## reboot, so the burn would ask it for a choice it has not got; and a Phased one is damaged by
## nothing, its own heat
## included (Ryan, 16 November: "it shouldn't take damage from overheating since we don't need
## the exception. It does accumulate the stacks, though, which it will feel the round after").
## What either carries past its maximum stays and burns the turn it is back in reach, the first
## such turn its overheat.
func _burn_stacks(ms: MechState, over: int) -> void:
	if is_out(ms):
		return
	var burn := over * overheat_scale
	var culprit := ms.hot_entry
	var first := not ms.overheated
	ms.overheated = true
	ms.unit.hull -= burn
	overheats.append({"mech": mechs.find(ms), "over": over, "burn": burn, "hull": ms.unit.hull, "first": first})
	log.append("%s is overheated ×%d: hull -%d" % [ms.unit.display_name, over, burn])
	if first and ms.unit.shield > 0:
		log.append("%s overheats: its shield breaks" % ms.unit.display_name)
		ms.unit.shield = 0
	_note_break(ms)
	if ms.alive():
		_hull_damaged(ms)   # the burn is hull damage like any other, each turn it burns
	if first:
		_overheat_marks(ms, culprit)


## A shield at nothing is broken (Ryan, 13 November: "the unit
## cannot gain shield by any method"), whatever took it there: a foe's blow, the overheat, its
## machine's reboot, or a shield spend or cost of its own ("you can break yourself"). Noted
## wherever a shield falls, and again before any gain, so nothing raises it until the reboot's
## recovery. One break between reboots: a broken shield cannot break again.
func _note_break(ms: MechState) -> void:
	if ms.shield_broken or ms.unit.shield > 0 or ms.unit.shield_max <= 0:
		return
	ms.shield_broken = true
	if not ms.rebooting:
		log.append("%s's shield is broken: no shield until it reboots" % ms.unit.display_name)
	# What lasts until the shield breaks goes with it, every stack, a reboot's drop included
	# (Hardened Light: Ryan, 18 November, "The reboot breaks it yes. When it breaks, it loses all
	# of them").
	for name in Effects.clear_on_break(ms.unit):
		log.append("%s's %s goes with its shield" % [ms.unit.display_name, name])


## Whether machine `mech_index` may give its turn to a reboot now (Ryan, 13
## November: "they have had to 'spent nothing' to smash the Reboot button"): on the player's
## turn, alive and in the fight, its die unspent and nothing spent by it this turn, whatever
## would let it act more than once (Rapid, Instant, a second thing a round, a grant), so no
## machine plays a Rapid piece before its reboot. A die showing nothing lit is no spend: a machine
## whose whole die is dark may reboot, the very moment to (Ryan, 18 November). The one exception is
## a one-of-each machine (the Needletail's Quick-turn Avionics Relay; the same day: "Gaming the
## reboot is the Needletail's niche"): with one spend made at most, a Rapid or Instant spend none
## of them, it may reboot whatever its die shows, a die left with nothing lit to flip to included
## ("That would be the exact time a player would want to reboot"); after both, never.
func can_reboot(mech_index: int) -> bool:
	if state != State.ASSIGN or mech_index < 0 or mech_index >= mechs.size():
		return false
	var ms := mechs[mech_index]
	if not ms.alive() or is_swallowed(ms) or ms.rebooting:
		return false   # a Phased machine may: the safe reboot (Ryan, 15 November)
	if Effects.one_of_each(ms.unit):
		return ms.spends <= 1
	return not ms.assigned and ms.spends == 0


## The reboot: the machine gives its whole turn, or the rest of it after one action (the
## Needletail's, can_reboot). At once its shield goes to nothing and its
## heat with it, what stood past the maximum too (Ryan, 17 November, of the heat that stayed on
## the gauge until the recovery: "it didn't make sense to have that overheat hanging around and
## not hurting the mech"; "Maybe the heat gets shunted when the shield gets taken down?"), and it
## is free to overheat again. It stands bare through the enemy's turn, and as the next round
## opens its shield is whole (_recover). Heat laid on it after the vent stays: one vent, at the
## drop. A sealed machine opens. A vent that explodes lands on every foe (_vent_blast, the Whip Scorpion's). No pass, no
## entry spent and no shield gain, so nothing that reads one fires. The undo takes it back like a
## spend, a blast and what it felled with it. False when it may not (can_reboot).
func reboot_mech(mech_index: int) -> bool:
	if not can_reboot(mech_index):
		return false
	var snap := SaveGame.snapshot_skirmish(self) if keeps_undo and not previewing else {}
	last_acts.clear()
	spend_blows.clear()
	_shoved.clear()
	releases.clear()
	var ms := mechs[mech_index]
	ms.rebooting = true
	ms.assigned = true
	var dropped := ms.unit.shield
	ms.unit.shield = 0
	_note_break(ms)
	# A reboot opens a sealed machine (Ryan, 17 November: "Polar bear unseals when rebooting.
	# It's a good change because you're never accidentally stuck sealed, and a weaponless build
	# is possible if you wanted it for some reason"): the shell and its armour go at the drop,
	# so the seal's clock adds nothing this turn and every seal ends on one soft turn.
	if Effects.is_sealed(ms.unit):
		Effects.remove(ms.unit, "sealed")
		log.append("%s opens as it reboots" % ms.unit.display_name)
	# Every entry a foe jammed lights (Ryan, 19 November: "Lets change Jammed to lasting until
	# Reboot"): a jam waits for its machine's reboot, and the drop is that reboot.
	var lit := Effects.clear_waiting_jams(ms.unit)
	if lit > 0:
		log.append("%s's reboot clears %d jammed entr%s" % [ms.unit.display_name, lit, "y" if lit == 1 else "ies"])
	var vented := ms.heat
	var shot := release_shot(ms)   # read while it holds its heat
	ms.heat = 0
	ms.overheated = false
	log.append("%s reboots%s: %sheat -%d, back next round" % [ms.unit.display_name, " after its action" if ms.spends > 0 else "", "shield -%d, " % dropped if dropped > 0 else "", vented])
	_vent_blast(mech_index, ms, shot, vented)
	if not snap.is_empty():
		history.append(snap)
	_refresh_allies()
	return true


## A reboot's recovery, as the round after it opens: the shield whole, and the machine free to
## break again. Its heat went as its shield dropped; what landed on it since is its own.
func _recover(ms: MechState) -> void:
	ms.rebooting = false
	ms.shield_broken = false
	ms.unit.shield = ms.unit.shield_max
	log.append("%s is back: shield %d" % [ms.unit.display_name, ms.unit.shield])


## The overheat's what-if (Ryan, 30 October), on the component whose spend took the gauge past
## its maximum this turn and left it there (`idx`, MechState.hot_entry): none when a status's
## heat did, or when a vent brought the gauge back under before a status took it over again.
## The overheat Corrupts it.
func _overheat_marks(ms: MechState, idx: int) -> void:
	if idx < 0 or idx >= ms.die.faces.size() or not ms.alive():
		return
	if overheat_corrupt > 0 and ms.die.faces[idx].kind != Face.Kind.BLANK:
		Effects.corrupt_entry(ms.unit, idx, "overheat", overheat_corrupt)
		log.append("%s: the overheat corrupts its %s (×%d)" % [ms.unit.display_name, ms.die.faces[idx].describe(), Effects.corrupt_stacks(ms.unit, idx)])


## One blow. The honest shield (Ryan, 14 October; built 21 October): the shield absorbs its
## number and the excess reaches the hull. A blow that reaches the hull loses the chassis's
## armour first, so small hits bounce off a heavy machine. No blow destroys a component by its
## size (the injury rule's threshold, 17 September to 15 November: Ryan, "No longer a general
## rule"); a blow that carries Destroy does when any of it reaches the hull (_strike).
## A Barrier takes the next blow whole. A shield sized to a telegraphed blow, or a Barrier, is
## the counterplay; no blow of a foe's passes the shield or the armour (breach, 22 October to 15
## November: its first job was to pass a shield that mended, and nothing mends).
func _damage_mech(ms: MechState, amount: int, source: Foe) -> void:
	if is_out(ms):
		return   # a machine out of the fight takes no damage (ticks and overheats are its own, and land elsewhere)
	# Buffs and debuffs on damage taken, before shield and armour, the striker read for its
	# statuses; a Barrier takes the next blow that deals anything, whole, and is spent, a blow of
	# nothing leaving it standing (Shocked's mirror): _blow_on, the forecast's arithmetic too.
	var r := _blow_on(ms, amount, source, ms.unit.shield, Effects.has(ms.unit, "barrier"))
	var brought := int(r["amount"])   # the blow as it arrives, for the round preview's incoming
	var barred := bool(r["barred"])
	if barred:
		Effects.remove(ms.unit, "barrier")
	# The Parry's count (the Beam Buckler's, Ryan, 19 November: "half of all damage blocked by this
	# machine this round"; blocked, his answer that day: what a Barrier and armour keep off it, never
	# its shield's soak): the whole blow a Barrier took, and what its armour took off what passed the
	# shield, while the Parry stands.
	if Effects.has(ms.unit, "parry"):
		var kept := (brought if barred else 0) + int(r["armoured"])
		if kept > 0:
			ms.parried += kept
			log.append("%s parries %d (%d this round)" % [ms.unit.display_name, kept, ms.parried])
	var had_shield := ms.unit.shield > 0
	ms.unit.shield = r["shield"]
	ms.unit.hull -= r["through"]
	_note_break(ms)   # a shield a blow takes to nothing is broken
	var rk := "back" if source != null and source.rank == 1 else "front"
	taken_by_rank[rk] = int(taken_by_rank.get(rk, 0)) + int(r["absorbed"]) + int(r["through"])
	sponsorship["guarded"] = int(sponsorship["guarded"]) + int(r["absorbed"]) + int(r["armoured"])
	# The mech's gauges after the blow ride along, so a replay can step them down blow by blow.
	turn_events.append({"foe": source, "mech": mechs.find(ms), "amount": brought, "absorbed": r["absorbed"], "through": r["through"],
		"blocked": r["blocked"], "barred": barred, "broke_shield": had_shield and ms.unit.shield == 0, "injured": false,
		"shield": ms.unit.shield, "hull": ms.unit.hull, "seq": _seq,
		"name": str(source.action.get("name", "")) if source != null else "", "boss": source != null and source.boss,
		"all": source != null and source.hits_all()})
	_seq += 1
	var verb := "hits"
	var armoured: String = " (armour -%d)" % r["armoured"] if r["armoured"] > 0 else ""
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
	# Heat a blow (the Whip Scorpion's passive): every blow a foe lands adds heat, whatever it
	# dealt, in the enemy's turn, after the overheat has settled, so it is next round's fuel or
	# next turn's burn.
	var banked := Effects.heat_per_blow(ms.unit)
	if banked > 0 and ms.alive():
		_add_heat(ms, banked)   # through the heat path, so a passive on heat gained answers it (the audit's 17)
		log.append("%s banks the blow: +%d heat" % [ms.unit.display_name, banked])
	if int(r["through"]) > 0:
		_hull_damaged(ms)
	elif int(r["absorbed"]) > 0:
		_shield_hit(ms)   # a blow its shield took, none of it on the hull (the Nemesis's rage: hull first)


## The arithmetic of one blow against a shield and armour, shared by the real hit
## and the forecast. The honest shield (Ryan, 14 October): a shield absorbs its number and the
## excess passes to the hull.
## Returns shield after, absorbed, through (to hull), armoured (taken off by armour), blocked
## (the shield took the whole blow) and broke (the blow took a standing shield to nothing).
static func _blow(shield: int, armour: int, amount: int) -> Dictionary:
	var absorbed := mini(maxi(0, shield), maxi(0, amount))
	var through := maxi(0, amount) - absorbed
	var broke := shield > 0 and absorbed >= shield
	# Armour comes off every blow that reaches the hull, a shield's overflow included. A blow
	# on the shield costs it its full damage: shield is not armoured.
	var armoured := mini(armour, through) if through > 0 else 0
	through -= armoured
	return {"shield": shield - absorbed, "absorbed": absorbed, "through": through, "armoured": armoured, "blocked": absorbed > 0 and through + armoured == 0, "broke": broke}


## An injury destroys the entry the die shows (Ryan, 2 November, in place of the die's roll of
## 17 September: what faces the enemy is the player's choice, the entry it spent, held or
## locked): blank, until the hangar mends it (one state, Ryan, 25 October: "Cracked is gone").
## A destroyed component or an empty hardpoint showing takes the blow and nothing happens, so a
## second such blow in the turn finds nothing to break. The damage lives on the unit and
## persists until repaired in the hangar. A passive may say no_destroy on_injury: then the
## component holds. The preview's copy breaks the same entry, so the forecast is exact. One
## thing injures: a blow that carries Destroy and reaches the hull (_strike), a boss's rider
## and no rule of every blow (Ryan, 15 November).
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


## Whom a foe strikes (Ryan, 17 November, after Slice and Dice: "random, don't overkill, and a
## spattering of 'target highest HP' and 'target lowest HP'"), for a move aimed at one machine:
## any machine, drawn level, unless the move carries a word for whom it goes for (Foe.AIMS): the
## strongest or the weakest by hull and shield together, the hottest by heat, the most buffed
## by stacks of buffs. Each is the most or the least of one thing the screen shows, a tie
## drawn level, so a field that is level picks anyone and no word falls back on another. No
## pick lands on a machine in `avoid`, which the blows already drawn this round would wreck,
## while another stands. The pick is a commitment: a foe whose target shields up or vents its
## heat still swings at it. A pick made again mid-round is _repick's, and draws nothing.
func _pick_mech_target(f: Foe, avoid: Array = []) -> MechState:
	var live := targetable_mechs()
	if live.is_empty():
		return null
	# Never over-commit: a machine the blows already drawn would wreck is passed over while
	# another stands.
	var open: Array[MechState] = []
	for ms in live:
		if not avoid.has(ms):
			open.append(ms)
	if not open.is_empty():
		live = open
	# An Exposed machine draws every targeted intent as the round opens, whatever the move's
	# word, until the blows already drawn would wreck it; from there the rest pick as they would
	# (Ryan, 15 November: "keep the logic where enemies don't try and overkill. That helps keep
	# it fair. So the whole field targets up until predicted death, then the rest pick intent
	# targets as normal"). No draw is made for it.
	var marked := exposed_mech()
	if marked != null and open.has(marked):
		return marked
	var word := f.aim_of()
	if word.is_empty():
		return live[rng.randi_range(0, live.size() - 1)]
	var most: Array[MechState] = []
	var top := 0
	for ms in live:
		var n := _aim_measure(word, ms)
		if most.is_empty() or n > top:
			top = n
			most = [ms]
		elif n == top:
			most.append(ms)
	return most[rng.randi_range(0, most.size() - 1)]


## What a move's word reads on a machine, the most of it picked: its hull and shield together
## (the strongest; the least of them the weakest), its heat (the hottest), its stacks of buffs
## (the most buffed, never stores).
func _aim_measure(word: String, ms: MechState) -> int:
	match word:
		"strongest":
			return ms.unit.hull + ms.unit.shield
		"weakest":
			return -(ms.unit.hull + ms.unit.shield)
		"hottest":
			return ms.heat
		"buffed":
			return Effects.buff_stacks(ms.unit)
	return 0


## A pick made again mid-round (its machine fell before it acts or is Phased, a Disrupted foe's
## gone): the next machine in line, left to right, that stands and is not Phased, whatever the
## move's word (Ryan, 26 October: Slice and Dice's rule, "it just targets the next ally in line",
## which the player can tell without the preview, and an aim breaking it would be "more
## unpredictable info"; it retires a draw from a stream of the fight's own, randomness the player
## could see only through the preview).
func _repick(_f: Foe) -> MechState:
	var live := targetable_mechs()   # in field order, left to right
	return null if live.is_empty() else live[0]


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


## A foe's fall (a last act, 15 October, the Gargantuan King's Meteor): what it does the moment
## it falls, before anything else, so the player readies first and kills after, and even the
## last foe's lands, since damage sticks for the battle. A short list of steps as a move is (16
## November, on Ryan's mark of 15 November: "foes who, say buff others on death, or debuff on
## death, which makes kill sequencing more interesting in normal formations"): its blow, if it
## strikes, then each effect by that effect's own rules, as a move's are (Ryan, 16 November:
## "Death effects should be dictated by the effect, same as moves"). What it aims at one
## machine lands on the machine that made the kill, its curse ("if the effect is a curse, then
## it should apply to the killer, and the dodge is ablating it") and its single blow alike
## (17 November, of the Dread Knight's Death Throes: "yes, hit its killer, if it has one"; the
## blow followed the foe's own pick until then, which no arrow shows on a round the foe aims at
## nobody): the one whose spend or release is under way (_killer), and on nobody when no
## machine made it, a tick's kill, a Mine blowing in the enemy's turn or the foe's own burst,
## nor when the killer is wrecked or out of the fight by then; a Ward on it turns the curse
## and the blow's riders. A blow at every machine lands on each as ever. What the fall lays on
## its own side reaches the foes still standing, never itself.
func _last_act(f: Foe) -> void:
	var fall := f.fall()
	if fall.is_empty():
		return
	f.action = fall
	f.pending = {}
	f.charge = 0
	log.append("%s falls, and its last act lands: %s" % [f.display_name, str(fall.get("name", ""))])
	var struck: Array[int] = []
	var gauges: Array = []   # each struck machine's [shield, hull] as the act met it
	var cursed := _killer if _killer != null and _killer.alive() and not is_out(_killer) else null   # the machine that made the kill, in the fight still
	if Foe.is_attack_action(fall):
		if f.hits_all():
			for m in targetable_mechs():
				struck.append(mechs.find(m))
				gauges.append([m.unit.shield, m.unit.hull])
				_strike(f, m)
		elif cursed != null:
			struck.append(mechs.find(cursed))
			gauges.append([cursed.unit.shield, cursed.unit.hull])
			_strike(f, cursed)
		else:
			log.append("%s lands on nobody: no machine made the kill" % str(fall.get("name", "")))
	var did: Array = []
	for st in Foe.effects_of(fall):
		_foe_acts(f, cursed, st)   # an effect aimed at nobody reads no machine at all
		did.append(str(st.get("effect", "")))
	last_acts.append({"foe": f, "name": str(fall.get("name", "")), "mechs": struck, "gauges": gauges, "effects": did,
		"cursed": mechs.find(cursed) if cursed != null else -1})


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
	for ms in mechs:
		Effects.end_skirmish(ms.unit)
