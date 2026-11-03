class_name Skirmish
extends RefCounted

## The dice skirmish. Mechs have no positions. Enemies stand in a two-rank, four-column
## formation fed from the reinforcements, so a horde keeps coming. The rules are docs/rules.md's.
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
##                       burn ticks, foes act, the dead are cleared, mech statuses tick, the
##                       reinforcements refill, outcome is checked
##   can_withdraw()      at any point of the player's turn
##
## The player's damage is in fives, everything else in tens. Nothing rolls but the dice.

enum State { SETUP, ROUND_START, ASSIGN, DONE }
enum Outcome { NONE, VICTORY, DEFEAT, WITHDRAWN }

const DEFAULT_COLUMNS := 4   # the formation's width (Ryan, 23 September: four plays better than three)
const REROLLS_PER_ROUND := 3
## The shapes a foe past a strike's target stands in (area by shape, numbered: Ryan, 28 October),
## each its own number in place of the roll (area_shapes, area_number).
const AREA_ROW := 1      # beside the target in its rank: Spread's, Splash's
const AREA_COLUMN := 2   # the other rank of its column: Penetrate's, Splash's
const AREA_ALL := 3      # any other foe a reach over every foe adds: nothing
const AREA_CHAIN := 4    # every other Shocked foe on the field: Chain's conductors (28 October)
const INJURY_MIN_HULL_PCT := 25     # a single hull hit this big (percent of max) destroys the entry the die lands on
static var injury_pct: int = INJURY_MIN_HULL_PCT   # the threshold read; tools/balance.gd's --injury sets it for one run's what-if
static var overheat_scale: int = 1   # hull an overheat burns a point of heat past the maximum; tools/balance.gd's --overheat sets it for one run's what-if (30 October)
# Two more what-ifs on the overheat (Ryan, 30 October), set by tools/balance.gd for one run: a
# burn reaching the injury threshold burns out the component that took the gauge past the
# maximum (--burnout), and every overheat Corrupts that component, so many stacks (--overheat-corrupt N).
static var overheat_burnout: bool = false
static var overheat_corrupt: int = 0
const NUMBED_PER_SUPPRESS := 2       # Numbed stacks a landed suppress adds; one is lost at each of the foe's turns
const NUMBED_PER_SUPPRESS_MASSIVE := 3


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


var rng := RandomNumberGenerator.new()
var mechs: Array[MechState] = []
var packs: Array[Unit] = []
var columns: int = DEFAULT_COLUMNS
var terrain: int = BattleMap.Terrain.PLAIN   # the ground the fight is on (the contact hex), for the screen
var ground: String = "plain"                 # its word for the header, a wall by its look (BattleMap.ground_id)
var front: Array = []
var back: Array = []
var reinforcements: Array[Foe] = []   # foes waiting behind the formation; they step in at the reinforcement phase
var round: int = 0
var rerolls_left: int = 0
var state: int = State.SETUP
var outcome: int = Outcome.NONE
var destroyed: int = 0   # components destroyed this fight, for the balance runner (the hangar's destroyed-is-gone rule, bible section 10, depends on the rate)
var log: Array[String] = []

## The most recent attack, for the screen to show: {mech, target, rolled, final, melee}; melee
## (the tag) is how the screen animates it, a lunge in place of a kick back.
var last_roll: Dictionary = {}
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
var _chaining := false
var _salvo_strike := false   # a strike of the Musk Ox's salvo, paid for by the whole magazine at the spend
var _blast_strike := false   # a vent's blast: one weapon hit inside the vent's spend, whose heat, ammo and tallies are the spend's
## Every blow of the last enemy turn, in order, for the screen to replay:
## {foe, mech (index), absorbed, through, blocked, broke_shield, injured, shield, hull,
## seq, name, boss, all}. `seq` orders it among the turn's specials; `name` is the move's shown
## name, `boss` whether a massive foe struck and `all` whether the blow struck every machine,
## for the plaque (decided 9 October; `all` 15 October).
var turn_events: Array = []
## The last acts of foes that fell during the latest spend (15 October), for the screen to name
## and land: {foe, name, mechs (indices struck)}.
var last_acts: Array = []
## Every special of the last enemy turn (a defend, buff or debuff in place of a blow), for
## the screen to announce on its plaque in order: {foe, name, kind, seq}.
var turn_specials: Array = []
var _seq: int = 0   # the order of the turn's blows and specials, shared by both lists
var _falls: int = 0   # foes that have fallen this fight, counted as their slots clear: a spend's kills are the difference
## Foes that joined a pack in this fight (a Gel's half, a summon, a part) and fell for good, by
## pack id: the kills its own count cannot see (kills_for).
var joined_fallen: Dictionary = {}
## The same by type, pack id -> {content id: fallen}, for the menace a kill is worth
## (kills_by_type).
var joined_fallen_types: Dictionary = {}
## What each pack came into the fight with, pack id -> {content id: count} of its own foes
## (add_foes), so the kills by type are what came less what is left; a resumed fight carries it
## in its save, and one from before reads the pack itself (_came_with_of).
var came_with: Dictionary = {}
## Mines (the Lammergeier's Fuse-delayed Bay, 21 October): Vector2i(rank, column) -> the shots
## waiting in that empty slot, in laid order, each {damage, keywords, burn, cryo, flak, by, seq}:
## its number as rolled and modified when laid, and its keywords, acting as it lands.
var mines: Dictionary = {}
var mine_seq: int = 0          # the order shots were laid, so a pull gathers them in laid order
var _reinforcing := false       # the reinforcement step: every arrival placed first, then the mines land left to right
## A fight nobody withdraws from, so it ends in the foes' fall or the team's: a battle's boss
## fight (Ryan, 25 October: "the player is committed to closing the rift or getting scrapped
## trying") and every quick campaign fight (no withdrawal there, the same day).
var committed := false
## The twin slot (Ryan, 26 October: the Gel's halves "should exist as a pair taking the place of
## one unit"): Vector2i(rank, column) -> the right-hand half, the left standing in front or back
## as any foe. The slot is one slot to the formation, full while either stands, so no mine is
## laid in it and nothing else joins it; an area blow that reaches it reaches both, a
## single-target blow the one it is spent on. When one falls the other keeps the slot alone,
## and with both gone it is a plain slot again: the pair exists only as its split made it.
var twins: Dictionary = {}
## The runner's mine tally (the game never reads it): spends on a slot, shots laid by them and
## by the drone, shots landed on an arrival or by the pull, and the hull they took.
var mine_tally := {"slot_spends": 0, "laid": 0, "drone_laid": 0, "landed": 0, "pulled": 0, "damage": 0}
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
var preview_notes: Array = []   # what the copy held back: {kind: pick, resist, blast, spray, random_target; foe or mech}
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
			if is_own(from_pack, f):
				var tally: Dictionary = came_with.get(from_pack.id, {})
				tally[f.content_id] = int(tally.get(f.content_id, 0)) + 1
				came_with[from_pack.id] = tally
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
	_reinforce(false)
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


## The live machines a foe may pick or a teammate may land a shield, a vent or a buff on: one out
## of the fight is neither, Phased (the Swallowtail's Mooring Screens, 21 October) or Swallowed
## (a foe's swallow, 30 October).
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


## What a pack came into this fight with, by type: recorded as its foes were added, or read off
## the pack itself for a fight resumed from a save made before the record (its members, or its
## one type times its strength; a boss unit's commanders and its escort).
func _came_with_of(sq: Unit) -> Dictionary:
	if came_with.has(sq.id):
		return came_with[sq.id]
	var tally := {}
	if sq.is_boss:
		for cid in sq.lineup:
			tally[str(cid)] = int(tally.get(str(cid), 0)) + 1
		if sq.lineup.is_empty():
			for f in field_foes():
				if f.pack_id == sq.id and f.commands:
					tally[f.content_id] = int(tally.get(f.content_id, 0)) + 1
	for m in sq.member_list():
		if not str(m[0]).is_empty():
			tally[str(m[0])] = int(tally.get(str(m[0]), 0)) + int(m[1])
	return tally


## The foes of a pack this fight killed, by type (content id -> count), for the menace each is
## worth (the Rupture meter, Anathema and salvage, 30 October): its own that are gone, what it
## came with less what is left, and every foe that joined it and fell for good. Read before the
## map takes the result.
func kills_by_type(sq: Unit) -> Dictionary:
	var left := {}
	for f in field_foes():
		if f.pack_id == sq.id and f.alive() and is_own(sq, f):
			left[f.content_id] = int(left.get(f.content_id, 0)) + 1
	for f in reinforcements:
		if f.pack_id == sq.id and is_own(sq, f):
			left[f.content_id] = int(left.get(f.content_id, 0)) + 1
	var out := {}
	var came := _came_with_of(sq)
	for cid in came.keys():
		var n := int(came[cid]) - int(left.get(cid, 0))
		if n > 0:
			out[str(cid)] = n
	var joined: Dictionary = joined_fallen_types.get(sq.id, {})
	for cid in joined.keys():
		out[str(cid)] = int(out.get(str(cid), 0)) + int(joined[cid])
	return out


## A boss unit's commanders still standing in this fight (Foe.commands: its boss, a final's
## hero, the finale's line), alive on the field or waiting in the pool, a readied one that got
## back up among them: their content ids, field first. The unit stands while one does.
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


## Withdraw is open at any point of the player's turn, the first round included. Its price is
## always the same: the enemy takes its turn, then the team flees at the end of the round, so
## there is no leapfrogging out of contact unscathed (Ryan, 19 September).
func can_withdraw() -> bool:
	return not committed and (state == State.ROUND_START or state == State.ASSIGN)


## Heat the mech's current face will add if it is spent as an attack: negative for one that
## fires the gauge empty first. A charged form's own when it goes out charged.
func pending_heat(ms: MechState) -> int:
	var f := spend_face(ms) if ms.face() != null else null
	if f == null or ms.assigned:
		return 0
	if not f.is_attack():
		return f.heat if f.on_machines() else 0   # a printed heat on a piece spent on machines (the Musk Ox's quick reload)
	if ammo_price_of(ms, f) > 0:
		return Effects.debuff_heat(ms.unit, f)   # a forging machine's gun pays ammo; only a foe's debuff heats it
	var added: int = Effects.attack(ms.unit, f, 0, f.heat)["heat"]
	added -= shield_burn(ms, Effects.effective_face(ms.unit, f), added)   # what the shield pays never reaches the gauge (the Storm Petrel's)
	return added - ms.heat if f.vents_all else added


## The shield a weapon's spend burns in place of `heat` (the Storm Petrel's Riot Field Generator,
## Ryan's go of 21 October; built 30 October): as much of the heat as the shield holds as it
## stands, overshield included; the rest reaches the gauge. Nothing for equipment, a forging
## machine's gun (its heat is paid in ammo) or a machine whose shield pays nothing.
static func shield_burn(ms: MechState, f: Face, heat: int) -> int:
	if ms == null or f == null or not f.is_weapon() or heat <= 0 or ms.ammo_max > 0 or not Effects.burns_shield(ms.unit):
		return 0
	return mini(heat, maxi(0, ms.unit.shield))


## The shield the entry in hand would burn as it is spent (shield_burn), for the forecast.
func pending_burn(ms: MechState) -> int:
	var f := spend_face(ms) if ms.face() != null else null
	if f == null or ms.assigned or not f.is_attack():
		return 0
	return shield_burn(ms, Effects.effective_face(ms.unit, f), int(Effects.attack(ms.unit, f, 0, f.heat)["heat"]))


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


## What one blow of an attack entry will deal, as the die shows it (decided 10 October, bible
## section 5: the game does the arithmetic and the player reads it): [low, high], equal for a
## flat entry. Without a target, every source that needs none: the pipeline's adds and
## multiplies, the heat a vent-on-fire shot fires, a raised ceiling. Over a foe, what it deals
## to that foe: its missing hull, conditions on it (a status it carries), its Flak (a point a
## stack on a weapon's blow) and its armour off the blow. A shock is left out, the
## foe's own chip, and spent by the first blow of many.
## `f` is the entry as this machine's passives make it (shown_face); [0, 0] for no attack.
## A split entry's strike takes its share of the roll: the roll divided among the strikes it
## serves, rounded down and never below one while the roll is one or more (Ryan, 27 October:
## "rounded down, min 1", so a Twin Autoguns' 1 strikes 1 twice where it struck 0 twice); a roll
## of nothing shares nothing. One strike takes the whole roll.
static func split_share(roll: int, split: int) -> int:
	if split <= 1:
		return roll
	return maxi(1, roll / split) if roll > 0 else 0


func shown_number(ms: MechState, f: Face, target: Foe = null) -> int:
	if f == null or not f.is_attack():
		return 0
	var add := heat_bonus(ms, f) + hopper_bonus(ms.unit, f)   # what the entry prints from its firer, inside the pipeline
	var own := (f.missing_bonus(target) + f.consume_bonus(target)) if not f.is_debuff() else 0   # the foe's own reads, flat after it (the blow's order)
	# A split entry (the Skua's) shows a strike's share of the number, rounded down, never below one.
	var d := int(Effects.attack(ms.unit, f, split_share(f.power + add, f.split), 0, target)["damage"]) + own
	if target != null:
		if not f.is_debuff():
			d += Effects.damage_taken_add(target, ms.unit)
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
	return out


func shown_number_text(ms: MechState, f: Face, target: Foe = null) -> String:
	if f == null or not f.is_attack() or f.is_debuff():
		return f.number_text() if f != null else ""
	var text := str(shown_number(ms, f, target))
	# Over a foe, a weapon whose heat the shield pays shows its zap joined to the blow (the Storm
	# Petrel's, "4+2"), each with the foe's armour off; the zap is lost if the blow kills.
	if target != null and f.burns > 0:
		text += "+%d" % zap_on(target, f.burns, ms)
	return text


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
## on nobody in particular shows none: Foe.intent_on), and not about to die to burn first.
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
## rally of its lands.
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


## What the rallies on their way to a foe add to its move (rallies_on), each at its move's value.
func incoming_rally(x: Foe) -> int:
	var n := 0
	for r in rallies_on(x):
		n += maxi(0, int(r.action.get("value", 0)))
	return n


## The foes whose rally reaches this one before its move lands: every other foe on the field
## rallying this round (rallies_now), those acting ahead of it for a move this round and every
## one for a countdown still gathering, whose blow lands after the round. Nothing reaches a
## foe that has acted, or one that stepped up this round (its next move is next round's). A
## rallier killed, Suppressed or Disrupted drops out at once, so the intents do too; once a
## rally lands it is the foe's own Empowered.
func rallies_on(x: Foe) -> Array[Foe]:
	var out: Array[Foe] = []
	if x == null or not x.alive() or x.fresh or _acted.has(x):
		return out
	var ahead := true
	for r in field_foes():
		if r == x:
			ahead = false
		elif (ahead or x.gathering()) and rallies_now(r):
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
## drawn: a stun Numbed may shrug off and a strike at a random foe among several are held
## back (`notes`); the
## reinforcements are the next round's. Returns {"mechs": the forecast's keys for each machine by
## index, plus "coming" (the statuses the round lands on it: {id: {"stacks", "name",
## "description"}}), "foes": {foe on the field: {"hp", "alive", "struck" (the machines its blows
## land on, by index), "coming"}}, "notes": what was held back}; the fight itself is untouched.
func preview_round(hover_mech: int = -1, hover_target = null) -> Dictionary:
	var copy: Skirmish = SaveGame.clone_skirmish(self)
	copy.previewing = true
	Effects.recorded = []
	Effects.recording = true   # every status the copy's play lands (Ryan, 26 October: "All incoming chips should appear as pulsing opacity versions")
	var ours := field_foes()
	var theirs := copy.field_foes()
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
	if played:
		copy._tick_mechs()
		for f in copy.field_foes():
			Effects.halve(f)
		copy._trim_overshield()
		copy._regrow_parts()
	Effects.recording = false
	var coming := {}   # the copy's unit or foe -> {status id: {"stacks", "name", "description"}}
	for r in Effects.recorded:
		var per: Dictionary = coming.get(r[0], {})
		var m: Effects.Modifier = r[1]
		var c: Dictionary = per.get(m.id, {"stacks": 0, "name": m.name, "description": m.description})
		c["stacks"] = int(c["stacks"]) + int(r[2])
		per[m.id] = c
		coming[r[0]] = per
	Effects.recorded = []
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
	var out_foes := {}
	for cf in back.keys():
		var struck: Array[int] = []
		for ev in events:
			if ev.get("foe", null) == cf and not struck.has(int(ev.get("mech", -1))):
				struck.append(int(ev.get("mech", -1)))
		out_foes[back[cf]] = {"hp": maxi(0, cf.hp), "alive": cf.alive(), "struck": struck, "coming": coming.get(cf, {})}
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
		var machines := live_mechs().size() if x.hits_all() else 1
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


## What the end of the round does to this mech if nothing else changes: the screen's warning
## signs and bar overlays. Recomputed after every action, so shielding or killing an attacker
## moves the numbers at once. `with_face` counts the heat of the die's showing component as
## if spent; the screen asks for that only while the die is being dragged. `extra_shield`
## asks the same question with that much more shield standing (a shield component about
## to be spent here), for whoever weighs one; `overshield` lets it pass the maximum, as a
## component with that keyword would. `aimed`, the foe a dragged die is held over, folds in
## what that spend cashes there: a weapon's hit on a Cryo foe cools the hitter after its own
## heat lands (Ryan, 16 October: the net on the heat bar, never the die).
func forecast(ms: MechState, with_face: bool = true, extra_shield: int = 0, overshield: bool = false, aimed: Foe = null) -> Dictionary:
	var shield := ms.unit.shield + extra_shield if overshield else mini(maxi(ms.unit.shield_max, ms.unit.shield), ms.unit.shield + extra_shield)
	var hull := ms.unit.hull
	var bite := pending_bite(ms) if with_face else 0
	if bite > 0:
		# A corrupted entry bites the moment it is spent, shield first, before the enemy's blows.
		var b := _bite(shield, hull, bite)
		shield = b["shield"]
		hull = b["hull"]
	# A volatile entry costs hull outright as it is spent, shield or no shield.
	var volatile := pending_volatile(ms) if with_face else 0
	hull -= volatile
	# A weapon that burns shield in place of heat (the Storm Petrel's) takes it as it is spent, after
	# a bite: the shield the enemy's blows meet is what it leaves.
	if with_face:
		shield -= mini(shield, pending_burn(ms))
	var incoming := 0
	var component_risk := false
	# The die in hand's own grant on its machine, for this round's blows: a brace's armour (the
	# Breaching Plow, the Siphon) and a Siphon's heat a blow, a second Siphon renewing the first.
	var spent := spend_face(ms) if with_face and not ms.assigned and ms.face() != null else null
	var braced := spent.braces * Effects.braced_armour() if spent != null else 0
	var per_blow := Effects.heat_per_blow(ms.unit)
	if spent != null and spent.heat_per_blow > 0 and not Effects.has(ms.unit, "siphoning"):
		per_blow += spent.heat_per_blow
	var walk := {"shield": shield, "barrier": Effects.has(ms.unit, "barrier"), "armour": braced}
	for f in attackers_of(ms):
		incoming += foe_blow(f) * f.strikes()
		for r in blows_on(ms, f, walk):
			hull -= int(r["through"])
			if r["injures"]:
				component_risk = true
	shield = int(walk["shield"])
	# Heat: what the gauge holds (past the cap, if the turn ran hot), the face's own if asked
	# and Burning's tick burn at the end of the player's turn, before the enemy acts (11 and
	# 13 October). Foes add no heat outright: their fire leaves Burning and Scorched, which
	# land on later turns.
	var heat_mid := ms.heat + (pending_heat(ms) if with_face else 0)
	heat_mid -= mini(heat_mid, cryo_cash(ms, aimed) if with_face else 0)
	var heat_end := heat_mid + int(Effects.tick_preview(ms.unit, true)["heat"]) + seal_heat(ms)
	if spent != null and spent.self_burn > 0:
		heat_end += spent.self_burn * Effects.status_value("burning_mech", "tick_heat")   # the Stoker's own fire ticks with the rest
	var over := maxi(0, heat_end - ms.heat_max)
	hull -= over * overheat_scale
	var blows := 0
	for f in attackers_of(ms):
		blows += f.strikes()
	var heat_after := mini(heat_end, ms.heat_max) + int(Effects.tick_preview(ms.unit)["heat"]) + per_blow * blows   # a Siphon's heat lands with the blows
	return {
		"incoming": incoming,
		"bite": bite,
		"volatile": volatile,
		"shield_after": shield,
		"hull_after": hull,
		"heat_end": heat_end,       # the gauge as the turn ends, uncapped: what the burn reads
		"heat_after": heat_after,   # the gauge after the round: settled at the cap, then the foes' heat
		"overheat": over,
		"component_risk": component_risk,
		"destroyed": hull <= 0 and ms.alive(),
	}


## The heat a weapon spend of the entry showing would cash off Cryo foes, aimed at `over`:
## every stack on every foe it reaches, at the Cryo rate. Nothing for equipment or
## without a foe in hand.
func cryo_cash(ms: MechState, over: Foe) -> int:
	var f := ms.face()
	if over == null or f == null or ms.assigned or not f.is_attack():
		return 0
	var ef := Effects.effective_face(ms.unit, f, over)
	if ef.is_debuff():
		return 0
	var stacks := 0
	for foe in reached_by(ef, over):
		if foe.alive():
			stacks += Effects.stacks_of(foe, "cryoed")
	return stacks * cryo_cool()


## One foe's blows on a machine as they would land now, in order: each through what the
## machine takes (damage_taken), a Barrier that stands taking the first that deals anything,
## a breach unless a Ward turns it away, each against the shield the one before left. `walk`
## carries the shield and the Barrier from blow to blow, and from foe to foe for a caller
## walking every attacker: {"shield": int, "barrier": bool, "armour": int}, updated; its armour
## is a grant not yet made (the die in hand's brace), on top of the machine's own.
## Returns each blow's arithmetic (_blow's).
func blows_on(ms: MechState, f: Foe, walk: Dictionary) -> Array:
	var out: Array = []
	var breach := f.breaches() and not Effects.has(ms.unit, "ward")
	var armour := ms.unit.armour + Effects.armour_against(ms.unit, f.rank) + int(walk.get("armour", 0))
	for s in range(f.strikes()):
		var amount := Effects.damage_taken(ms.unit, foe_blow(f), f, false, true, maxi(0, int(walk["shield"])))   # a plate that stands with the shield reads the shield this blow meets
		if amount > 0 and bool(walk.get("barrier", false)):
			walk["barrier"] = false
			amount = 0
		var r := _blow(int(walk["shield"]), ms.unit.hull_max, armour, amount, breach)
		walk["shield"] = r["shield"]
		out.append(r)
	return out


## Machines a shield, a vent or a buff may be spent on: itself, its allies, or both, as the
## component says (Ryan, 26 September: not every shield reaches an ally). Live machines only.
func machine_targets_for(ms: MechState, f: Face) -> Array[MechState]:
	var out: Array[MechState] = []
	if f == null or not f.on_machines() or shield_short(ms, f):
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


## Can this machine spend its entry charged (the Swallowtail's locked pieces): the entry has a
## charged form and the Muster holds its price.
func can_charge(ms: MechState) -> bool:
	var f := ms.face() if ms != null else null
	return f != null and not f.charged.is_empty() and Effects.muster_charges(ms.unit) >= f.muster_price()


## Whether the entry goes out charged now (Ryan, 22 October: never primed, "it just gets used
## if it's up"): a muster pays for it and its charged form has somewhere to land, a foe or a slot
## in its reach or a machine it may be spent on (the Horn's act again an ally whose die is
## spent). A grant reaching every ally yet to act (the Mooring Screens' Phased) lands only while
## no ally has acted this round (Ryan, 22 October: else "it can be used as a selective
## protection which is not the intent"). A charged form with nothing to land on leaves the plain
## one, and the muster waits.
func charge_lands(ms: MechState) -> bool:
	if not can_charge(ms):
		return false
	var cf := ms.face().charged_form()
	if cf.is_attack():
		return not targets_for_face(ms, cf).is_empty() or not slot_targets(ms, Effects.effective_face(ms.unit, cf)).is_empty()
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
func swap_targets(first: Foe) -> Array:
	var out: Array = []
	if first == null or not first.alive() or first.is_massive():
		return out
	var pair := twin_of(first)
	for foe in field_foes():
		if foe != first and foe != pair and foe.alive() and not foe.is_massive():
			out.append(foe)
	for col in range(columns):
		if front[col] == null:
			out.append(Vector2i(0, col))
		if back[col] == null:
			out.append(Vector2i(1, col))
	return out


## Does this entry, spent now, take a second target (a Swap)?
func needs_second(ms: MechState) -> bool:
	var f := ms.face()
	return f != null and Effects.effective_face(ms.unit, f).has(Face.Keyword.SWAP)


func targets_for_face(ms: MechState, f: Face) -> Array[Foe]:
	var out: Array[Foe] = []
	if f == null or not f.is_attack() or not can_fire(ms, f) or shield_short(ms, f):
		return out   # a dry gun on a forging machine (the Musk Ox's), or an entry whose shield cost the shield cannot pay, has nothing it may be spent on
	# Reach: direct hits the front and any exposed column's back; indirect hits everyone.
	# A foe already killed this round still stands until the dead are cleared, but it is
	# no target: a die spent on it would be wasted.
	for col in range(columns):
		for foe in slot_foes(0, col):
			if foe.alive() and not out.has(foe):
				out.append(foe)
		for foe in slot_foes(1, col):
			if not foe.alive() or out.has(foe):
				continue
			if reach_of(ms, f) == Face.Reach.INDIRECT or in_direct_reach(foe):
				out.append(foe)
	# A Swap moves its target, and a massive foe fills its column and stays (the Dingo's row).
	if Effects.effective_face(ms.unit, f).has(Face.Keyword.SWAP):
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
## weapons and debuffs run hotter, 13 October; the Sparrowhawk's double): the game does the arithmetic.
## Over a target, the keywords its rank grants too (the Cottonmouth's drum: Spread at the
## front, Penetrate at the back), as the spend will carry them.
func shown_face(ms: MechState, f: Face, target: Foe = null) -> Face:
	var sf := Effects.effective_face(ms.unit, f, target)
	if sf != null and shield_short(ms, sf):
		if sf == f:
			sf = f.duplicate_face()
		sf.short = true   # the shield cannot pay: the cost struck through, like a dry gun's ammo
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
	var burn := shield_burn(ms, sf, heat)
	if burn > 0:
		# A weapon whose heat the shield pays (the Storm Petrel's): the burn in the heat slot's place
		# with the shield's mark, and the heat past what the shield holds beside it.
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
		# A sealed machine's own cooling stops (the Armadillo's Lockdown, 20 October); an ally's
		# vent still cools it.
		var drop := 0 if Effects.is_sealed(ms.unit) else mini(ms.heat, ms.unit.cooling)
		if drop > 0:
			ms.heat -= drop
			cooled.append("%s -%d" % [ms.unit.display_name, drop])
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
	# Passives that fire at the round's start, after the roll: shield from heat, a flat
	# shield, a vent (the Goshawk's Thermal Recoupler reads the heat as it stands now).
	for ms in live_mechs():
		_fired(ms, Effects.round_start(ms.unit, ms.heat), "round start")
	# What a purge put to sleep wakes now, the turn's start resolved (28 October: the cooling,
	# the roll and the round-start passives first, "a mild punishment"), and before the foes
	# draw, so they pick against the machine as it stands.
	for ms in live_mechs():
		var woke := Effects.wake(ms.unit)
		if not woke.is_empty():
			log.append("%s's %s return%s" % [ms.unit.display_name, ", ".join(woke), "s" if woke.size() == 1 else ""])
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
		on = live_mechs()
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


func _choose_foe_action(f: Foe) -> void:
	if not f.pending.is_empty():
		f.action = f.pending   # a countdown move holds until it lands
		return
	# A follow-up (30 October): the move its last move named in `then` comes now, announced like
	# any; a borrowed swing with nothing taken has nothing to swing, and the roll decides.
	var next := f.next_move
	f.next_move = ""
	if not next.is_empty():
		for a in f.actions:
			if str(a.get("id", "")) == next and (not Foe.swings_held(a) or not f.held.is_empty()):
				f.action = a
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
	return true


## The player's Purge on one foe (28 October): every buff it carries but Numbed and Guarded,
## told when anything went.
func _purge_foe(by: String, foe: Foe) -> void:
	var gone := Effects.purge_foe(foe)
	if not gone.is_empty():
		log.append("%s purges %s: %s" % [by, foe.display_name, ", ".join(gone)])


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
## rank, the left on a tie, and one with no room waits in the pool. An arrival sets off a mine
## waiting in its slot, as any way in but the reinforcement step's does; its round is over, so
## it shows no intent and acts from the next round (Foe.fresh).
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
	# formation, their round over; a mine waiting there goes off on them as it would on one.
	if bool(f.on_death.get("pair", false)) and made.size() == 2 and at_col >= 0 and foe_at(at_rank, at_col) == null:
		var at := Vector2i(at_rank, at_col)
		for n in made:
			n.fresh = true
		_set_contents(at, [made[0], made[1]])
		if not mines.is_empty():
			_land(made[0])
		log.append("%s splits: 2 %s step up in its place, a pair in one slot" % [f.display_name, made[0].display_name])
		return
	var stood := 0
	for n in made:
		if _step_up(n, at_col):
			stood += 1
		else:
			reinforcements.append(n)
	var waiting := made.size() - stood
	var name_of := made[0].display_name
	if stood > 0 and waiting > 0:
		log.append("%s splits: %d %s step up in its place, %d into the pool" % [f.display_name, stood, name_of, waiting])
	elif stood > 0:
		log.append("%s splits: %d %s step up in its place" % [f.display_name, stood, name_of])
	else:
		log.append("%s splits: %d %s step into the pool" % [f.display_name, waiting, name_of])


## A foe that arrives mid-round (a split's half, a summon) steps up into the slot `_split_slot`
## finds near `at_col`, its round over (Foe.fresh), setting off any mine waiting there. False
## when there is no room, and it is not placed.
func _step_up(n: Foe, at_col: int) -> bool:
	var slot := _split_slot(n, 0, at_col)
	if slot.y < 0:
		return false
	n.fresh = true
	if n.is_massive():
		back[slot.y] = n   # both slots of its column, before a mine there can land on it
	_place(n, slot.x, slot.y)
	if _reinforcing and not mines.is_empty():
		_land(n)   # the step's mines have their arrivals already: this one takes its slot's now
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
				if front[c] == null and back[c] == null:
					return Vector2i(0, c)
			elif (front if want == 0 else back)[c] == null:
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


static func _same_kind(a: Foe, b: Foe) -> bool:
	if not a.content_id.is_empty() or not b.content_id.is_empty():
		return a.content_id == b.content_id
	return a.display_name == b.display_name


## Reroll the dice named. One die alone, on a machine with a free reroll of its own left
## (the Clydesdale's Battery Director), spends that instead of the team's; anything else
## spends one of the team's.
func reroll(mech_indices: Array) -> bool:
	if state != State.ASSIGN:
		return false
	var live: Array[MechState] = []
	for i in mech_indices:
		var ms := mechs[i]
		if ms.alive() and not ms.assigned:
			live.append(ms)
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


## One die rerolled: never the same entry. A stepping die steps (a reroll is a roll).
func _reroll_die(ms: MechState) -> void:
	_rolled()
	ms.face_index = _step(ms) if Effects.steps_die(ms.unit) else ms.die.reroll(rng, ms.face_index)


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
	return ms.die.roll(rng)


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


## Is any reroll open: the team's, or a machine's own?
func can_reroll() -> bool:
	if state != State.ASSIGN:
		return false
	if rerolls_left > 0:
		return true
	for ms in live_mechs():
		if not ms.assigned and ms.free_rerolls > 0:
			return true
	return false


## Spend a mech's face. `target` is a Foe for attacks, a MechState (or null for self) for
## shield and vent. Returns false if the assignment is not legal.
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
	if f.is_attack() and target is Vector2i:
		return slot_targets(ms, f).has(target)
	if f.is_attack():
		return target is Foe and targets_for_face(ms, raw).has(target)
	if f.on_machines():
		return machine_targets_for(ms, f).has(target if target is MechState else ms)
	return false


## Whether die `mech_index` has anywhere to be spent now: alive and unspent, an entry that is no
## blank (a dark one is), and a target it may land on (a foe or an empty slot in reach, a
## machine its chip allows). The screen's END TURN pulses once no die has (25 October).
func can_spend(mech_index: int) -> bool:
	if state != State.ASSIGN or mech_index < 0 or mech_index >= mechs.size():
		return false
	var ms := mechs[mech_index]
	if not ms.alive() or ms.assigned or ms.face() == null or ms.face().kind == Face.Kind.BLANK:
		return false
	var raw := spend_face(ms)
	var f := Effects.effective_face(ms.unit, raw)
	if f.is_attack():
		return not targets_for_face(ms, raw).is_empty() or not slot_targets(ms, f).is_empty()
	if f.on_machines():
		return not machine_targets_for(ms, f).is_empty()
	return false


## A locked piece of the Swallowtail's goes out in its charged form whenever a muster pays for it
## and it has somewhere to land (charge_lands), the muster spent with it.
func assign(mech_index: int, target = null, second = null) -> bool:
	if state != State.ASSIGN:
		return false
	last_acts.clear()
	var ms := mechs[mech_index]
	if not ms.alive() or ms.assigned:
		return false
	var f := ms.face()
	if f == null:
		return false
	var price := f.muster_price()
	var charged := charge_lands(ms)
	var raw := spend_face(ms)   # the entry as spent, its charged form when a muster pays for it
	f = raw
	var quick := Effects.quick_turn_live(ms.unit, f)   # Rapid by a once-a-round gate (the Needletail's), read before the spend
	f = Effects.effective_face(ms.unit, f, target if target is Foe else null)   # the entry as this machine's passives make it, over the foe it is aimed at
	if f.is_attack() and target is Vector2i:
		if not slot_targets(ms, f).has(target):
			return false   # an empty slot: a mine laid, or the pull's gather (the Lammergeier's)
	elif f.is_attack() and (not (target is Foe) or not targets_for_face(ms, raw).has(target)):
		return false
	# A Swap takes its second target with it (Ryan, 21 October: drag to the first, drop, then
	# tap the second): another foe or an empty slot, never a massive foe.
	if f.has(Face.Keyword.SWAP) and not swap_targets(target).has(second):
		return false
	if f.on_machines() and not machine_targets_for(ms, f).has(target if target is MechState else ms):
		return false
	# A shield cost (Ryan, 26 October: "if you don't have the shield, the face cannot be played,
	# and overshield does cheat it out at the cost of using two actions for one effect"): taken
	# first, from the shield as it stands, overshield included; short of it the entry is locked
	# (shield_short) and never reaches here.
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
	if charged:
		# The muster spent (the Swallowtail's): the charged form's price, a charge a muster.
		Effects.spend_stacks(ms.unit, "muster", price * maxi(1, int(Effects.muster_rule(ms.unit).get("value", 30))))
		log.append("%s spends a muster: %s" % [ms.unit.display_name, f.describe()])
	var blasted := false   # a vent that blasted deals damage, for the Sponsorship tally
	var killed := 0        # the foes a weapon spend or a vent's blast felled, arcs and spills included (a kill trigger, the reset gun)
	var free := false      # a spend made Rapid by its target (the Syrinx Drone on a foe already Exposed)
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
				var falls_before := _falls
				_blast(mech_index, ms, blast)
				blasted = true
				killed = _falls - falls_before
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
				# rolls again, and it acts again.
				who.assigned = false
				who.face_index = _roll(who)
				log.append("%s rallies %s: its die rolls again, and it acts again" % [ms.unit.display_name, who.unit.display_name])
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
				for w in whom:
					if f.buff_status == "phased" and w.assigned:
						continue   # Phased only before it acts (Ryan, 20 October)
					var stacks := _stacks_from(ms, f.buff_status, f.buff_stacks)
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
			var falls_before := _falls
			var exposed_before := target is Foe and Effects.has(target, "exposure")
			if target is Vector2i:
				# An empty slot (the Lammergeier's, 21 October): the pull gathers every mine there;
				# any other weapon or debuff lays its shot as a mine.
				mine_tally["slot_spends"] += 1
				if f.pulls_mines:
					_spend_heat(ms, f)
					_pull(ms, target)
				else:
					_lay(ms, f, target)
			elif f.spends_magazine:
				_salvo(mech_index, ms, f, raw)
			else:
				if f.random_targets:
					target = _random_foe(target)   # the drop is the gesture; the shot goes where it will
				if target != null:   # the round preview's copy holds a random target back
					_resolve_attack(mech_index, ms, f, target)
					if f.pulls_mines and target.alive():
						_pull(ms, Vector2i(0 if target.is_massive() else target.rank, target.column))
					if f.drones and target.alive():
						free = _drone(ms, target, exposed_before)
			killed = _falls - falls_before
			_after_kills(ms, killed)
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
			if f.has(Face.Keyword.SWAP) and target is Foe and target.alive():
				_swap(target, second)
			if Effects.counts_shots(ms.unit) > 0:
				Effects.stack(ms.unit, Effects.STATUS["shots"], Effects.SKIRMISH, "count", 1, Effects.DECAY_NONE)
			if f.is_weapon() and Effects.remove(ms.unit, "spun_up"):
				log.append("%s: the spin is spent" % ms.unit.display_name)
	if f.on_machines():
		_machine_spend_after(ms, f, target)
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
	# included, shown on the die with the rounds left; Rapid's switch-off is a cooldown of one,
	# the rest of this round, there to stop an infinite turn (Face.cooldown_rounds).
	var cd := cooldown_of(ms, f)
	if free:
		cd = maxi(cd, 1)   # made Rapid by its target: Rapid's switch-off, the rest of the round
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
	if (f.has(Face.Keyword.RAPID) or free) and not reset:
		if quick and f.has(Face.Keyword.RAPID) and not free:
			# The gate spent (the Needletail's Quick-turn Avionics Relay): once a round.
			Effects.grant_for_rounds(ms.unit, Effects.STATUS["quick_turned"], "gate", round)
		_act_again(ms, f)
		log.append("%s: %s" % [ms.unit.display_name, "the cylinder spins" if f.spins else ("a quick turn, rolls again" if quick and not free else "rapid, rolls again")])
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
	_tick_mechs()
	for f in field_foes():
		Effects.halve(f)   # a foe's halving statuses (Flak) halve at the round's end, Empowered's clock
	_trim_overshield()
	_regrow_parts()
	_reinforce(true)    # the reinforcement phase: a random waiting foe of the right rank per empty slot
	_refresh_guards()
	_refresh_allies()
	_check_outcome()
	if outcome == Outcome.NONE:
		state = State.ROUND_START
	return outcome


## The end of the player's turn (Ryan, 11 October): heat over the maximum burns hull now,
## before the enemy acts, so an overheat is the machine's own doing on its own turn, like a
## volatile bite. A machine it wrecks is gone before the enemy strikes, and a fight it
## decides ends here. A foe's Burning adds its heat just before it (13 October), so a vent
## made room for it or a cleanse took it off. Shared by END TURN and a withdrawal.
func _end_player_turn() -> void:
	overheats.clear()
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
## out. Shared by the end of a round and by a withdrawal.
func _enemy_turn() -> void:
	turn_events.clear()
	turn_specials.clear()
	_seq = 0
	# Foes act in the order they stand: front rank left to right, then the back rank. Each
	# foe's statuses tick at the start of its action (burning may kill it first; vitriol eats
	# its share of what is left and finishes nobody), a suppressed foe skips, and a foe with
	# two strikes lands two separate blows, so a shield stops the first and the second reaches
	# the hull. A web on the foe bursts at the end of its action, skipped or not (18 October).
	_acted.clear()
	for f in field_foes():
		if not f.alive():
			continue   # killed by a die this round; it stands until the dead are cleared, and does nothing
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
				continue   # burnt to death before it acts: a web it carried goes with it
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
		if not tick["skip"] and not f.fresh:   # a suppressed foe does nothing, and a web on it still bursts; one that stepped up this round has had its round
			_foe_turn(f)
			# A move that landed names its follow-up for next round (30 October); one lost to a
			# Suppress or turned by a Disrupt names nothing, so either answer breaks the pair.
			if f.alive() and not f.gathering() and f.action.has("then"):
				f.next_move = str(f.action["then"])
		if moves:
			Effects.remove(f, "kindled")
			Effects.remove(f, "primed")   # a stoker's priming rides the same move (28 October)
		_web_burst(f)
	_acted.clear()
	_clear_dead()
	for ms in mechs:
		Effects.end_round(ms.unit, round)   # timed effects run out
	for f in field_foes():
		Effects.end_round(f, round)


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
		for m in live_mechs():
			if is_out(m):
				continue   # out of the fight
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
			break
		_damage_mech(t, f.damage(), f)
		var ev: Dictionary = turn_events[turn_events.size() - 1]
		# The live hull (the Armadillo's, a machine under Retaliate): a blow that reaches
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
		if f.has_keyword(f.action, "steal") and t.alive() and t.face_index >= 0:
			_steal(f, t)



## Whether this foe's blows carry a rider a Ward turns away: a scorch, a burn, a disable or a
## corrupt (the breach is the Ward's too, in _damage_mech; a silence and a purge are specials).
static func _rides(f: Foe) -> bool:
	for kw in ["scorch", "burn", "disable", "corrupt", "steal"]:
		if f.has_keyword(f.action, kw):
			return true
	return Effects.has(f, "primed")   # a primed foe's blows carry Burning as a rider (28 October)


## A Swap (the Dingo's Combat Translocator, Ryan's go of 19 October; built 21 October): the
## first target and the second trade places, a foe for a foe, or the foe into an empty slot (a
## back foe into an empty front slot is a pull). A foe keeps its pick and its move; the rank it
## stands in is the swap's, so a caster pulled forward stands exposed to Direct fire.
func _swap(first: Foe, second) -> void:
	var from := Vector2i(first.rank, first.column)
	var mine := _slot_contents(from)   # a twin slot's pair moves together
	if second is Foe:
		var other: Foe = second
		var to := Vector2i(other.rank, other.column)
		var theirs := _slot_contents(to)
		_set_contents(to, mine)
		_set_contents(from, theirs)
		log.append("%s and %s trade places" % [first.display_name, other.display_name])
		_arrive_at(from)
		_arrive_at(to)
	elif second is Vector2i:
		var slot: Vector2i = second
		_set_contents(from, [null, null])
		_set_contents(slot, mine)
		log.append("%s is moved to the %s rank" % [first.display_name, "front" if slot.x == 0 else "back"])
		_arrive_at(slot)
	_refresh_kin()
	_refresh_guards()


## A slot's contents, [the left foe or null, its twin or null].
func _slot_contents(at: Vector2i) -> Array:
	return [foe_at(at.x, at.y), twins.get(at, null)]


## Stand [left, twin] in a slot, as they are, no mine set off.
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


## Whoever has just come into a slot outside the reinforcement step sets off what waits there.
func _arrive_at(at: Vector2i) -> void:
	var lead := foe_at(at.x, at.y)
	if lead != null and not _reinforcing and not mines.is_empty():
		_land(lead)


## A swap read without making it (the bot's bunching, 22 October): the two foes, or the foe and
## the empty slot, trade places while `read` runs, then stand where they stood; no log, no kin or
## guard refreshed, no mine set off.
func swap_what_if(first: Foe, second, read: Callable) -> void:
	var from := Vector2i(first.rank, first.column)
	var other: Foe = second if second is Foe else null
	var to: Vector2i = Vector2i(other.rank, other.column) if other != null else second
	var mine := _slot_contents(from)
	var theirs := _slot_contents(to)
	_set_contents(to, mine)
	_set_contents(from, theirs)
	read.call()
	_set_contents(from, mine)
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


## A purge (by source, 28 October): what a die face bought goes for good, what the machine is
## sleeps until the player's turn, the kept and the stores stay.
func _purge(t: MechState, f: Foe) -> void:
	var r := Effects.purge(t.unit)
	var gone: Array = r["gone"]
	var slept: Array = r["slept"]
	var said: Array[String] = []
	if not gone.is_empty():
		said.append(", ".join(gone) + " gone")
	if not slept.is_empty():
		said.append(", ".join(slept) + " asleep until its turn")
	log.append("%s purges %s%s" % [f.display_name, t.unit.display_name, ": " + "; ".join(said) if not said.is_empty() else ", and finds nothing to take"])


## The round ends with the machines' statuses ticking, after the enemy has struck. Burning and
## Scorched are not among them: they tick at the end of the player's turn (_burn_mechs).
func _tick_mechs() -> void:
	for ms in live_mechs():
		var t := Effects.tick(ms.unit)
		if int(t["heat"]) > 0:
			log.append("%s: %d heat from its statuses" % [ms.unit.display_name, int(t["heat"])])
			_add_heat(ms, int(t["heat"]))


## The end of the player's turn, before the overheat (Ryan, 13 October): each machine's
## Burning adds its heat, so a vent made room for it or a cleanse took it off; Burning loses a
## stack and Scorched goes.
## The heat a sealed machine runs at the end of its turn (the Armadillo's Lockdown): the
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


## The form change (the Armadillo's Lockdown, Ryan's framework of 15 October, his go 20
## October): a shield spent on itself seals the machine, a vent or a weapon opens it; a shield
## on an ally and equipment (a buff, a debuff: its lures) leave the form
## as it is. The seal is one chip carrying the passive's armour; the heat clock and the
## stopped cooling read it.
func _shift_form(ms: MechState, f: Face, target) -> void:
	var seal := Effects.seal_form(ms.unit)
	if seal.is_empty() or not ms.alive():
		return
	if f.kind == Face.Kind.SHIELD and (not (target is MechState) or target == ms):
		if not Effects.is_sealed(ms.unit):
			Effects.stack(ms.unit, Effects.sealed_status(int(seal["armour"]), int(seal["heat"])), Effects.SKIRMISH, "seal", 1, Effects.DECAY_NONE)
			log.append("%s seals: armour +%d, its own cooling stopped, +%d heat a turn" % [ms.unit.display_name, int(seal["armour"]), int(seal["heat"])])
	elif f.kind == Face.Kind.VENT or (f.is_attack() and f.power > 0):
		if Effects.remove(ms.unit, "sealed"):
			log.append("%s opens" % ms.unit.display_name)


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


func withdraw() -> bool:
	if not can_withdraw():
		return false
	if state == State.ROUND_START:
		start_round()
	log.append("Withdrawing: the enemy strikes as the team pulls out")
	# Leaving ends the player's turn, so the heat burns first (Ryan, 11 October): running hot
	# and then withdrawing is no way round an overheat.
	_end_player_turn()
	if outcome != Outcome.NONE:
		return true   # burnt out on the way: the fight is lost, and the enemy never strikes
	_enemy_turn()
	outcome = Outcome.DEFEAT if live_mechs().is_empty() else Outcome.WITHDRAWN
	_finish()
	if outcome == Outcome.WITHDRAWN:
		log.append("Withdrew at the end of round %d" % round)
	return true


# ---------------------------------------------------------------- resolution

## Spend an attack: every strike is its own blow (its own roll, its own keywords and
## passives), landing on every foe the component reaches. Heat is paid once per
## use.
## `real`: the entry as the die holds it, when it is not the one showing (a Chain repeated out
## of a mine, in the reinforcement step), for the next link's reach and a drone's mine.
func _resolve_attack(mech_index: int, ms: MechState, f: Face, target: Foe, real: Face = null) -> void:
	if real == null:
		real = ms.face()
	# A forging machine's weapon pays ammo for the heat its own spend would make (the Musk
	# Ox's Desublimation Forge): a chain link it cannot pay for is never fired. The salvo's
	# strikes are paid for by the whole magazine, at the spend.
	var forged := not _blast_strike and ammo_price_of(ms, f) > 0
	if forged and not _salvo_strike:
		var price := ammo_price_of(ms, f)
		if ms.ammo < price:
			log.append("%s: the magazine is dry" % ms.unit.display_name)
			return
		ms.ammo -= price
	var reach := reach_of(ms, f)
	var aimed_back := target.rank == 1
	var dealt := 0             # hull the blows took off every foe they reached, for the reach tally
	var total := 0
	var base_total := 0   # the strikes' numbers before the pipeline, for the screen's flash
	var heat_total := 0
	var vent := 0
	var armoured_total := 0   # what the primary target's armour took off, for the log
	var touched: Array = []    # every foe the blows reached and left alive, for a lure or a disrupt
	var gained := {}           # foe -> the statuses this spend put on it, told once each at the end (an application, never a stack or a strike)
	var turned := {}           # foe -> the marks its Ward turned away this spend, told once at the end (28 October)
	# A vent-on-fire attack fires the machine's whole heat into the blow: its bonus is read
	# now and the gauge is emptied once the strikes have landed.
	var fired := heat_bonus(ms, f)
	var loads := hopper_loads(ms.unit, f)   # the loads this shot fires from the hopper, read once too
	var from_hopper := loads * f.power_per_load
	var own := fired + from_hopper   # what the entry prints from its firer, on every blow of the spend
	var reached: Array = []    # every foe the blows reached, killed or not, for a weapon that fills the hopper
	var vented_all := ms.heat if f.vents_all else 0
	if f.vents_all:
		ms.heat = 0
	# Every foe one strike reaches (a Spread's neighbours, a Penetrate's column), the same for
	# each strike, since a kill clears its slot only after the spend; a spray's later strikes
	# find their own (below).
	var hit := reached_by(f, target)
	var shapes := area_shapes(f, target)   # the shape each foe past the target stands in, for its number
	# What this machine's passives lay on each foe reached, judged alone and read now, before
	# any strike's riders land (the funnel-web's Ambush, 18 October: a Suppress gun never feeds
	# its own read): foe -> [[status id, stacks a hit], ...]; and what was laid, for the log.
	# A spray may land on any foe in the fight, so every one is judged.
	var judged: Array[Foe] = field_foes() if f.spray else hit
	var lays := {}
	for foe in judged:
		var l := Effects.laid_statuses(ms.unit, f, foe)
		if not l.is_empty():
			lays[foe] = l
	# What each foe the spend may strike reads for itself, as the die is spent and before any
	# strike lands (the blow's order, Ryan, 28 October; the mechanics audit's 19): the hull it is
	# missing (the Coriolis's), and the stacks a consumer eats on it (the Backdraft Charge's), each
	# that foe's alone. Both land on that foe's blow after the firer's pipeline, flat, beside its
	# Flak (Ryan's chain: the struck unit's reads after the firer's multiplies, so the Kite's double
	# and the sixth shot never touch them); the eaten stacks a point each on its first blow, and
	# they go as that blow lands.
	var reads := {}
	for foe in judged:
		reads[foe] = [f.missing_bonus(foe), Effects.stacks_of(foe, f.consumes) if not f.consumes.is_empty() else 0]
	var laid := {}
	var webbed: Array[Foe] = []
	var doubled := Effects.stack_multiplier(ms.unit, f, target)   # the stacks this spend lays, multiplied (the sixth shot)
	# A gated keyword (the stock pass's engine, 22 October: the Suppression Battery's Suppress
	# on a foe carrying Flak): each foe reached judged at the spend, before any strike's riders,
	# so the spend never opens its own gate.
	var shut := {}
	for foe in judged:
		if f.has(Face.Keyword.SUPPRESS) and not Effects.gate_holds(ms.unit, f, Face.Keyword.SUPPRESS, foe):
			shut[foe] = [Face.Keyword.SUPPRESS]
	var thawed := 0   # Cryo stacks this spend's weapon hits spent, cooling the hitter after its heat lands
	var split := maxi(1, f.split)    # the strikes one roll serves (the Skua's Split-cycle Breech; Effects.split_of)
	var roll := 0                    # the roll the strikes of one split share
	var aimed := target              # the strike's own foe: the target, or where a spray's strike fell
	var sprayed: Array[String] = []  # a spray's strikes, the foe and what it took, for the log
	for s in range(maxi(1, f.strikes)):
		if f.spray and s > 0:
			# The spray (the Skua's Flechette Pod, built 25 October): each strike after the first
			# falls on a random foe in reach at that moment, the same foe again allowed; a kill
			# clears its slot at once, so a hole in the front opens the foe behind it.
			_clear_dead()
			aimed = _spray_pick(ms, real)
			if aimed == null:
				break
			hit = reached_by(f, aimed)
			shapes = area_shapes(f, aimed)
		if s % split == 0:
			# One number, split (Ryan, 24 October): the strikes of one split share it.
			roll = f.power
			base_total += roll + own
		var heat := f.heat if s == 0 else 0
		# The blow's order (Ryan, 28 October), the strike's own foe (the target, or a spray's pick)
		# first: the roll and what the entry prints from its firer (the heat Vents all fired, the
		# hopper's loads), a split's share of it (rounded down, never below one), then the firer's
		# pipeline, every live modifier's adds, multiplies and floors in that order, its conditions
		# read on that foe; then that foe's own reads, flat (_foe_reads).
		var modded := Effects.attack(ms.unit, f, split_share(roll + own, split), heat, aimed)
		var dmg: int = modded["damage"] + _foe_reads(f, reads, aimed, s == 0)
		if s == 0:
			heat_total += modded["heat"]   # heat is paid once a spend, every modifier's with it (the rules: a blow)
		vent += modded["vent"]
		var landed := dmg
		# Area by shape, numbered (Ryan, 28 October; the half retired): every other foe the strike
		# reaches takes its shape's number (Spread's, Penetrate's, Splash's, Chain's on a Shocked
		# conductor, whose Shock stands, no strike being aimed at it) in place of the roll,
		# through the same order, the firer's modifiers on it and its own reads. Every blow of the
		# strike is read before any lands, so a kill in it (the talons' Empowered) feeds the next
		# strike, never this one's other blows.
		var blows := {}
		for foe in hit:
			blows[foe] = dmg if foe == aimed else _area_blow(ms, f, int(shapes.get(foe, AREA_ALL)), foe, own, split) + _foe_reads(f, reads, foe, s == 0)
		for foe in hit:
			var was_alive := foe.alive()
			var hp_before := foe.hp
			if not reached.has(foe):
				reached.append(foe)
			if int(shapes.get(foe, 0)) == AREA_CHAIN:
				log.append("%s arcs to %s" % [ms.unit.display_name, foe.display_name])   # Chain (28 October): a conductor's blow
			var blow: int = blows[foe]
			# Spillover (Overwhelm until 6 October): damage past the kill of a front-rank foe carries
			# into the foe behind it (_spill). A massive foe fills its column: nothing is behind it.
			var spills := f.has(Face.Keyword.SPILLOVER) and foe.rank == 0 and not foe.is_massive()
			if spills and not was_alive:
				# A later strike on a foe an earlier strike of this spend killed (Ryan, 15 October:
				# "All its damage or subsequent strikes spill over"): the fallen foe takes nothing
				# more, its armour included, and the strike's whole number goes on behind it; with
				# nothing standing there, it is lost. The blow's record counts it whole, as it
				# counts the killing strike's excess.
				_spill(ms, f, foe, blow, hit, not f.is_debuff())
				if foe == aimed:
					landed = blow
				continue
			# What the foe takes of the blow: its own statuses read last (its Flak adds to a
			# weapon's blow, a strike of 0 included: Ryan, 25 October; a Shocked foe takes the
			# strike aimed at it double, spending the shock, while a blow that only reaches it, an
			# area's or a Chain's arc, neither doubles nor spends it: Ryan, 29 October), then its armour comes off, flat,
			# so small blows bounce off a braced foe the way they do off a heavy machine; a
			# breaching blow meets none (one breach, 22 October).
			var taken := Effects.damage_taken(foe, blow, ms.unit, not f.is_debuff(), foe == aimed)
			var barred := _barrier_eats(foe, not f.is_debuff())
			if barred:
				taken = 0   # a foe's Barrier takes the weapon's blow whole; its riders land (28 October)
			var foe_armoured := mini(taken, foe.armour_for(f))
			taken -= foe_armoured
			foe.hp -= taken
			var eaten := int(reads.get(foe, [0, 0])[1]) if s == 0 else 0   # each foe struck eats its own, on its first blow
			if eaten > 0:
				Effects.remove(foe, f.consumes)
				log.append("%s consumes %s ×%d on %s, +%d" % [ms.unit.display_name, str(Effects.STATUS.get(f.consumes, {}).get("name", f.consumes)), eaten, foe.display_name, eaten * f.per_consumed])
			if was_alive:
				dealt += clampi(taken, 0, maxi(0, hp_before))
			if foe == aimed:
				landed = taken
				armoured_total += foe_armoured
			# A weapon's strike aimed at the foe spends a shock, even one that deals nothing (Ryan,
			# 25 October: "The important part is that it was a damaging weapon"; 29 October: "when
			# targeted and struck by a weapon"); equipment (a lure, a probe) and a blow that only
			# reaches the foe leave it standing.
			if not f.is_debuff() and foe == aimed and Effects.remove(foe, "shocked"):
				log.append(("%s: the shock is spent on the Barrier" % foe.display_name) if barred else ("%s: the shock lands, %d doubled" % [foe.display_name, blow]))
			# A hit lays what the passives lay on this foe, a stack per strike, a debuff's included,
			# unless the passive asks for a weapon's hit (the Ambush's Vitriol, its text says so:
			# Ryan, 25 October); a strike on a foe an earlier one
			# killed lays nothing on it.
			if was_alive and lays.has(foe):
				for pair in lays[foe]:
					if bool(pair[2]) and f.is_debuff():
						continue
					var sid := str(pair[0])
					var n_laid := _stacks_from(ms, sid, int(pair[1])) * doubled
					Effects.stack(foe, Effects.STATUS[sid], Effects.SKIRMISH, "mech", n_laid, Effects.status_decay(Effects.STATUS[sid]))
					_note_status(gained, foe, sid, turned)
					if Effects.turns_mark(foe, sid):
						continue   # its Ward turned the lay away: nothing laid to tell
					var per: Dictionary = laid.get(foe, {})
					per[sid] = int(per.get(sid, 0)) + n_laid
					laid[foe] = per
			if was_alive and not foe.alive() and f.devours > 0:
				_overcharge_on_kill(ms, foe, f.devours)
			if was_alive and not foe.alive() and Effects.has(foe, "syrinx_drone"):
				_drone_mine(foe, _shot(ms, f, blow, real, doubled, 0, false, _area_shot(ms, f, own, split)))   # the killing shot as fired
			# The killing strike: what it had past the kill carries on.
			if spills and was_alive and not foe.alive():
				_spill(ms, f, foe, taken - hp_before, hit)
			if f.has(Face.Keyword.BURN):
				# Burn is a numbered keyword (Ryan, 18 October): the stacks it says, whatever the
				# blow dealt (it was a stack per 10 of the damage, rounded up, until then).
				Effects.stack(foe, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", _stacks_from(ms, "burning", f.burn) * doubled)
				_note_status(gained, foe, "burning", turned)
			if f.has(Face.Keyword.SUPPRESS) and shut.get(foe, []).has(Face.Keyword.SUPPRESS):
				if s == 0 and foe.alive():
					log.append("%s's suppress does not land on %s (%s)" % [ms.unit.display_name, foe.display_name, Effects.gate_text(f.gates.get("suppress", {}))])
			elif f.has(Face.Keyword.SUPPRESS) and _suppress(foe):
				_note_status(gained, foe, "suppressed")
			# Web (18 October): the foe is Webbed, one web however often it is webbed, and the
			# skirmish bursts it at the end of the foe's action (_web_burst).
			if f.has(Face.Keyword.WEB) and foe.alive() and not Effects.has(foe, "webbed"):
				Effects.stack(foe, Effects.STATUS["webbed"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
				_note_status(gained, foe, "webbed", turned)
				if Effects.has(foe, "webbed"):
					webbed.append(foe)
			# Cryo (20 October): a weapon's hit spends every stack the foe carries (Ryan, 25
			# October), and the hitter cools for them once the spend's own heat has landed (below);
			# equipment spends none. Then the blow's own Cryo lands, after the cash, so a Cryo
			# weapon never eats what it lays.
			if was_alive and not f.is_debuff() and Effects.has(foe, "cryoed"):
				thawed += Effects.stacks_of(foe, "cryoed")
				Effects.remove(foe, "cryoed")
			if f.has(Face.Keyword.CRYO) and foe.alive():
				Effects.stack(foe, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", _stacks_from(ms, "cryoed", f.cryo) * doubled, Effects.DECAY_NONE)
				_note_status(gained, foe, "cryoed", turned)
			# Flak (Ryan's go, 19 October; built 21 October): each foe hit gains the keyword's
			# number in stacks, after the blow, so the blow that lays it
			# never feeds on it; a later strike of the same spend does.
			if f.has(Face.Keyword.FLAK) and foe.alive():
				Effects.stack(foe, Effects.STATUS["flakked"], Effects.SKIRMISH, "mech", _stacks_from(ms, "flakked", f.flak) * doubled, Effects.status_decay(Effects.STATUS["flakked"]))
				_note_status(gained, foe, "flakked", turned)
			# Purge (the player's, 28 October): every buff the foe carries but Numbed and Guarded,
			# after the blow and with the riders, equipment's included; a foe the blow killed loses
			# its Getting Back Up, so it stays down.
			if f.has(Face.Keyword.DISPEL) and was_alive:
				_purge_foe(ms.unit.display_name, foe)
			if foe.alive() and not touched.has(foe):
				touched.append(foe)
		# A Primed machine's Burning lands blow by blow, on each strike's own foe (the mechanics
		# audit's 8, 27 October): a spray's strikes burn the foes they fell on, and a kill leaves
		# nothing to burn.
		if int(modded["burn"]) > 0 and aimed.alive():
			Effects.stack(aimed, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", _stacks_from(ms, "burning", int(modded["burn"])) * doubled)
			_note_status(gained, aimed, "burning", turned)
		total += landed
		if f.spray:
			sprayed.append("%s %d" % [aimed.display_name, landed])
	for foe in laid.keys():
		var bits: Array[String] = []
		for sid in laid[foe].keys():
			bits.append("%s ×%d" % [str(Effects.STATUS[sid]["name"]), int(laid[foe][sid])])
		log.append("%s lays %s on %s" % [ms.unit.display_name, ", ".join(bits), foe.display_name])
	for foe in webbed:
		var caught := web_catch(foe)
		log.append("%s webs %s: it bursts after its action%s" % [ms.unit.display_name, foe.display_name, "" if caught == null else ", on it and %s" % caught.display_name])
	# The hopper (11 October): a shot that fires it spends the loads it took; a weapon that
	# fills it puts its loads in for every foe its blows reached, after the blow, so a claw
	# never feeds the shot it is part of.
	if loads > 0:
		Effects.spend_stacks(ms.unit, "hopper", loads)
		log.append("%s fires the hopper: %d load%s, +%d" % [ms.unit.display_name, loads, "" if loads == 1 else "s", from_hopper])
	if f.fills_hopper > 0 and not reached.is_empty():
		var n := f.fills_hopper * reached.size()
		Effects.stack(ms.unit, Effects.STATUS["hopper"], Effects.SKIRMISH, "mech", n, Effects.DECAY_NONE)
		log.append("%s fills the hopper: +%d (%d)" % [ms.unit.display_name, n, Effects.stacks_of(ms.unit, "hopper")])
	# Shock (9 October): every foe the blows reached and left alive carries a charge for the
	# team's next blow, after this one landed, so a shocking weapon never spends its own.
	if f.has(Face.Keyword.SHOCK):
		for foe in touched:
			_shock(foe, ms, turned)
	# Chain's charge (Ryan, 29 October): after its arcs, one other foe at random is Shocked.
	if f.has(Face.Keyword.CHAIN) and not f.is_debuff():
		_chain_charge(target, ms, ms.unit.display_name, turned, mech_index)
	# Expose (the Needletail's Fovea Designator, 21 October): every foe reached and left
	# standing is Exposed through the next round, a second Expose refreshing it.
	if f.has(Face.Keyword.EXPOSE):
		for foe in touched:
			_expose(foe, ms, turned)
	# Disrupt first, then lure, so an entry carrying both ends with the foe's new move aimed at
	# the spender.
	if f.has(Face.Keyword.DISRUPT):
		_disrupt(touched)
	if f.has(Face.Keyword.LURE):
		_lure(ms, touched)
	_tell_turned(turned)
	for foe in gained.keys():
		for status_id in gained[foe]:
			_foe_gained_status(foe, status_id)
	last_roll = {"mech": mech_index, "target": target, "base": base_total, "final": total, "melee": f.tags.has("melee")}
	var how := f.describe()
	if f.spray:
		log.append("%s sprays %s (%s)%s" % [ms.unit.display_name, ", ".join(sprayed), how, " (armour -%d)" % armoured_total if armoured_total > 0 else ""])
	elif _blast_strike:
		log.append("%s's vent blasts %s for %d%s" % [ms.unit.display_name, target.display_name, total, " (armour -%d)" % armoured_total if armoured_total > 0 else ""])
	else:
		log.append("%s hits %s for %d (%s)%s" % [ms.unit.display_name, target.display_name, total, how, " (armour -%d)" % armoured_total if armoured_total > 0 else ""])
	if vented_all > 0:
		log.append("%s fires its heat: -%d, +%d to the blow" % [ms.unit.display_name, vented_all, fired])
	# The Riot Field Generator (the Storm Petrel's, Ryan's go of 21 October; built 30 October):
	# while its shield stands its weapons burn shield in place of heat, every point the spend adds
	# (a Scorched machine's extra included) coming off the shield as it stands, overshield
	# included, and the rest reaching the gauge; then, the strikes landed, the target takes a blow
	# of what the shield paid (the zap), plain, no keyword and no Shock read, through what it takes
	# and its armour, and lost on a kill.
	var burnt := 0 if forged or _blast_strike else shield_burn(ms, f, heat_total)
	if burnt > 0:
		ms.unit.shield -= burnt
		heat_total -= burnt
		log.append("%s burns %d shield in place of heat" % [ms.unit.display_name, burnt])
		if target.alive():
			var zap_before := target.hp
			var zap := zap_on(target, burnt, ms)
			if _barrier_eats(target, true):
				zap = 0
			target.hp -= zap
			dealt += clampi(zap, 0, maxi(0, zap_before))
			log.append("%s zaps %s for %d" % [ms.unit.display_name, target.display_name, zap])
	# A kill clears the slot at once (Ryan, 22 September): burning a hole through the front
	# opens the back rank to direct fire until reinforcements plug it. Indirect fire at the
	# front rank costs its firer nothing (danger close retired with the stock pass, 22 October).
	_clear_dead()
	if f.power > 0 and not _blast_strike:   # a lure or a probe deals nothing: it is no spend of damage; a blast is no spend of its own
		_tally_reach(reach, dealt, aimed_back, heat_total)
	if vent > 0:
		ms.heat = maxi(0, ms.heat - vent)
	if forged:
		heat_total = 0 if _salvo_strike else Effects.debuff_heat(ms.unit, f)   # the forge took the gun's own heat; a foe's debuff still heats it
	if _blast_strike:
		heat_total = 0   # the vent's spend paid its own heat, once
	_add_heat(ms, heat_total, ms.face_index)
	# The Shrapnel Recuperator's refund: ammo back for every foe its blows reached.
	if f.ammo_per_foe_hit > 0 and ms.ammo_max > 0 and not reached.is_empty():
		_reload(ms, f.ammo_per_foe_hit * reached.size(), "its casings")
	if thawed > 0:
		var cooled := mini(ms.heat, thawed * cryo_cool())
		ms.heat -= cooled
		log.append("%s cashes Cryo ×%d: -%d heat" % [ms.unit.display_name, thawed, cooled])


## A vent's blast (the Whip Scorpion's Thermal Ejection Manifold): the heat it took off, as
## one flat blow of the machine's on a live foe drawn from the seeded stream, back rank
## included. The vent is a weapon too on that machine (Effects.kinds_of; Ryan, 26 October:
## "Vent blast should obviously proc cryo, that's the point of tagging it with weapon. It
## shouldn't need exceptions in code"), so the blow is a weapon's hit and resolves as every
## weapon's does (_resolve_attack): the machine's pipeline, the foe's Flak, a Shocked doubling
## spent, its Cryo cashed for the machine's cooling, its armour, a Primed machine's Burning, a
## drone's mine, and its kills fire the machine's kill rules (_after_kills). It is one hit inside
## the vent's spend, so the spend's heat, ammo and tallies stay the vent's, paid once. A kill
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
	var was := _blast_strike
	_blast_strike = true
	_resolve_attack(mech_index, ms, shot, foe, shot)
	_blast_strike = was
	last_blast = {"mech": mech_index, "foe": foe, "dealt": hp_before - foe.hp}


## The blast as the blow it is: flat, Indirect, the heat the vent took off.
static func blast_shot(amount: int) -> Face:
	return Face.attack(amount, Face.Reach.INDIRECT)


## A spend's kills, its weapon's or its vent's blast's: the muster its guns earn (the
## Swallowtail's) and the kill trigger (the Kite's heat tax, 21 October), once however many fell.
func _after_kills(ms: MechState, killed: int) -> void:
	if killed <= 0:
		return
	_muster(ms, killed * int(Effects.muster_rule(ms.unit).get("kill", 0)))
	if ms.alive():
		_fired(ms, Effects.fire(ms.unit, "on_kill"), "after the kill")


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


## The round as it would stand once this machine's Lure entry, spent on `aimed`, turns what it
## reaches (the Whip Scorpion's Siphon over every foe): every live machine's forecast with those
## foes on the spender, the spender's with its die in hand (its brace, its Siphon's heat a
## blow), then the foes put back as they were. Empty when there is nothing to turn.
func lure_preview(ms: MechState, aimed: Foe = null) -> Dictionary:
	var out := {}
	var saved := {}
	for foe in _lured(ms, aimed):
		if foe.alive() and foe.target != ms:
			saved[foe] = foe.target
			foe.target = ms
	if saved.is_empty():
		return out
	for m in live_mechs():
		out[m] = forecast(m, m == ms, 0, false, aimed if m == ms else null)
	for foe in saved.keys():
		foe.target = saved[foe]
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


## Chain's charge (Ryan, 29 October: "then Shock one other random non-targeted enemy that doesn't
## already have Shock"): after a Chain spend's arcs, one foe on the field, alive, neither the
## target nor already Shocked, drawn from the seeded stream, is Shocked; a Ward turns it away. The
## round preview's copy draws nothing: a lone such foe takes it for sure, else it is held back and
## noted. `by` may be null (a mine whose spender is gone); `who` names the spender in the log.
func _chain_charge(target: Foe, by: MechState, who: String, turned, mech_index: int) -> void:
	var pool: Array[Foe] = []
	for foe in field_foes():
		if foe != target and foe.alive() and not Effects.has(foe, "shocked"):
			pool.append(foe)
	if pool.is_empty():
		return
	if previewing and pool.size() > 1:
		preview_notes.append({"kind": "charge", "mech": mech_index})
		return
	var foe: Foe = pool[0] if pool.size() == 1 else pool[rng.randi_range(0, pool.size() - 1)]
	if Effects.turns_mark(foe, "shocked"):
		_turned_away(foe, "shocked", turned, by)
		return
	Effects.stack(foe, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	log.append("%s leaves a charge on %s: Shocked" % [who, foe.display_name])
	_foe_gained_status(foe, "shocked")


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
## conductors, a mine's as it lands included.
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


## One strike's blow on a foe past its own, before the foe's own reads, statuses and armour:
## its shape's number with `prints` (what the entry prints from its firer), a split's share of
## it, through the firer's pipeline with its conditions judged on that foe.
func _area_blow(ms: MechState, f: Face, shape: int, foe: Foe, prints: int, split: int) -> int:
	return int(Effects.attack(ms.unit, f, split_share(area_number(f, shape) + prints, split), 0, foe)["damage"])


## A shot's area numbers as a mine carries them, [the row's, the column's, Chain's], each through
## its spender's modifiers with no foe in hand, as the shot's own number is laid; nothing for a
## shape the entry does not reach.
func _area_shot(ms: MechState, f: Face, own: int, split: int) -> Array:
	var out := [0, 0, 0]
	if f.reaches_row():
		out[0] = _area_blow(ms, f, AREA_ROW, null, own, split)
	if f.reaches_column():
		out[1] = _area_blow(ms, f, AREA_COLUMN, null, own, split)
	if f.has(Face.Keyword.CHAIN) and not f.is_debuff():
		out[2] = _area_blow(ms, f, AREA_CHAIN, null, own, split)
	return out


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
			# party members, never itself): Getting Back Up on one of its own.
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
				# column, else it waits in the pool (Ryan, 26 October); either way its round is
				# over, so it strikes from the next.
				var stood := 0
				for i in range(count):
					var n = foe_factory.call(who)
					if n is Foe:
						n.pack_id = f.pack_id
						n.joined = true
						if _step_up(n, f.column):
							stood += 1
						else:
							reinforcements.append(n)
				log.append("%s: %s, %d %s answer%s the call%s" % [f.display_name, str(a.get("name", "calls")), count, who, "s" if count == 1 else "",
					"" if stood == 0 else (", stepping up" if stood == count else ", %d stepping up" % stood)])
			else:
				log.append("%s: %s, and nothing answers" % [f.display_name, str(a.get("name", "calls"))])
		"rally":
			# Empowered lands at once on every other foe on the field, at the move's own value
			# (Ryan, 26 October: "howl is more clear if it gives kindled for the next action,
			# which could be the turn its granted"): one acting after the rallier this turn hits
			# harder now, one that has acted carries it to its next move, and every intent
			# showed it from the round's start (incoming_rally). Each grant is its own, so two
			# rallies add.
			var rallied := 0
			for other in field_foes():
				if other != f and other.alive():
					Effects.grant(other, Effects.make(Effects.kindled(maxi(0, value)), Effects.SKIRMISH, "foe:" + f.content_id))
					rallied += 1
			log.append("%s: %s, %d hit %d harder at their next move" % [f.display_name, str(a.get("name", "rallies")), rallied, value])
		"drain_rerolls":
			reroll_debt += maxi(0, value)
			log.append("%s: %s, the team loses %d reroll%s next round" % [f.display_name, str(a.get("name", "roars")), value, "" if value == 1 else "s"])
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
			# A hero's or a boss's purge (17 October): no blow, every buff gone, the stores kept.
			if Effects.has(t.unit, "ward"):
				log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "purges")), t.unit.display_name])
			else:
				_purge(t, f)
		"scorch_all":
			var names: Array[String] = []
			for ms in specials_reach():
				if Effects.has(ms.unit, "ward"):
					log.append("%s: %s, and %s's Ward turns it away" % [f.display_name, str(a.get("name", "erupts")), ms.unit.display_name])
					continue
				_fire_on(ms, "scorched", maxi(1, value), f)
				names.append(ms.unit.display_name)
			log.append("%s: %s, %s scorched ×%d" % [f.display_name, str(a.get("name", "erupts")), ", ".join(names) if not names.is_empty() else "nobody", maxi(1, value)])
		"corrupt_all":
			var hit_names: Array[String] = []
			for ms in specials_reach():
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


## The machines a special on every machine reaches (a scorch all, a corrupt all): every live one
## but the Phased, which is out of the fight until the round's end as it is for a blow at every
## machine (the mechanics audit, 25 October).
func specials_reach() -> Array[MechState]:
	var out: Array[MechState] = []
	for ms in live_mechs():
		if not is_out(ms):
			out.append(ms)
	return out


## A machine's unspent die rolled again in place (the Reheat Uplink's roll, 30 October): never
## onto the entry showing, a stepping die stepping, as a team reroll does; the round preview's
## copy keeps its entry, a roll never promised.
func _roll_again(ms: MechState) -> void:
	if previewing:
		return
	_reroll_die(ms)


## The machine acts again through Rapid's path: the die rolls for free, never onto the entry
## just spent (a copy of it may come up), a spin over every entry, a stepping die stepping.
func _act_again(ms: MechState, f: Face) -> void:
	if previewing:
		ms.assigned = false   # it acts again; the copy's die keeps its entry, a roll never promised
		return
	_rolled()
	if f.spins:
		ms.face_index = ms.die.roll(rng)
	elif Effects.steps_die(ms.unit):
		ms.face_index = _step(ms)
	else:
		ms.face_index = ms.die.reroll(rng, ms.face_index)
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
	if on_self and f.kind == Face.Kind.VENT:
		_reload(ms, int(rule.get("vent", 0)), "the vent")
	elif on_self and f.kind == Face.Kind.SHIELD:
		_reload(ms, int(rule.get("shield", 0)), "the shield")


## A random live foe from the seeded stream, or `fallback` when none stands. The round preview's
## copy draws nothing: a lone foe is a sure strike, and among more the strike is held back.
func _random_foe(fallback: Foe) -> Foe:
	var live: Array[Foe] = []
	for foe in field_foes():
		if foe.alive():
			live.append(foe)
	if live.is_empty():
		return fallback
	if previewing:
		if live.size() == 1:
			return live[0]
		preview_notes.append({"kind": "random_target"})
		return null
	return live[rng.randi_range(0, live.size() - 1)]


## Where a spray's strike falls (the Skua's Flechette Pod): a random live foe the entry reaches
## now, from the seeded stream, the same foe again allowed; null when none stands in reach. The
## round preview's copy draws nothing: a lone foe in reach takes it for sure, else it is held back.
func _spray_pick(ms: MechState, real: Face) -> Foe:
	var pool := targets_for_face(ms, real)
	if pool.is_empty():
		return null
	if previewing:
		if pool.size() == 1:
			return pool[0]
		preview_notes.append({"kind": "spray", "mech": mechs.find(ms)})
		return null
	return pool[rng.randi_range(0, pool.size() - 1)]


## The Unrestricted Expenditure (the Musk Ox's, Ryan's go of 21 October): every ammo in the
## magazine as a strike, each at a random live foe from the seeded stream, with the entry's
## keywords (Spread and Penetrate on every strike), the magazine its price and no heat; a kill
## clears its slot as the strike lands, so the later strikes fall among the foes left.
func _salvo(mech_index: int, ms: MechState, f: Face, real: Face) -> void:
	var n := ms.ammo
	ms.ammo = 0
	log.append("%s empties the magazine: %d strike%s at random" % [ms.unit.display_name, n, "" if n == 1 else "s"])
	var was_chaining := _chaining
	var was_salvo := _salvo_strike
	_salvo_strike = true
	for i in range(n):
		var t := _random_foe(null)
		if t == null:
			break
		_resolve_attack(mech_index, ms, Effects.effective_face(ms.unit, real, t), t, real)
		_chaining = true   # one spend: the strikes after the first are its blows, not spends
	_chaining = was_chaining
	_salvo_strike = was_salvo


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
	Effects.grant_for_rounds(t.unit, Effects.STATUS["swallowed"], swallow_source(f), round + rounds)
	t.assigned = true
	for foe in field_foes():
		if foe.alive() and foe.target == t:
			foe.target = _repick(foe)
	log.append("%s: %s, %s swallowed: out of the fight for %d round%s, or until %s falls" % [f.display_name, what, t.unit.display_name, rounds, "" if rounds == 1 else "s", f.display_name])


## A swallower down lets go of what it holds, at once (30 October).
func _release_swallowed(f: Foe) -> void:
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
			log.append("%s falls, and lets %s go" % [f.display_name, ms.unit.display_name])


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

## The empty slots this entry may be spent on (the Lammergeier's, 21 October): a weapon or a
## debuff of a machine that lays mines, or a pull, under the reach rules as if a foe stood there, Direct a
## front slot or a back slot whose front is empty, Indirect any; a massive foe fills its
## column. A Swap and the Syrinx Drone take a foe: a slot holds none to move or carry it.
func slot_targets(ms: MechState, f: Face) -> Array:
	var out: Array = []
	if f == null or not f.is_attack() or not (f.pulls_mines or Effects.lays_mines(ms.unit)) or not can_fire(ms, f) or shield_short(ms, f):
		return out
	if f.drones or Effects.effective_face(ms.unit, f).has(Face.Keyword.SWAP):
		return out
	var indirect := reach_of(ms, f) == Face.Reach.INDIRECT
	for col in range(columns):
		if front[col] == null:
			out.append(Vector2i(0, col))
			if back[col] == null:
				out.append(Vector2i(1, col))
		elif back[col] == null and indirect:
			out.append(Vector2i(1, col))
	return out


## One shot as a mine carries it: the number as dealt by its spender; its keywords, every one
## acting as the shot lands but the spend's own (Rapid and Volatile acted at the spend, and Lure
## and Disrupt do nothing once their round is over); its numbered stacks, deepened as its
## spender lays them (`extra_burn` a Primed machine's); its area numbers (`area`, the row's, the
## column's and Chain's as its spender's modifiers make them: _area_shot); and its spender and
## entry, for its gate and its consumer. Plain damage (a spill's) carries no keyword.
func _shot(ms: MechState, f: Face, dmg: int, real: Face, doubled: int = 1, extra_burn: int = 0, plain: bool = false, area: Array = []) -> Dictionary:
	var kws: Array = []
	if not plain:
		for k in f.keywords:
			if not [Face.Keyword.RAPID, Face.Keyword.LURE, Face.Keyword.DISRUPT, Face.Keyword.SWAP].has(k):
				kws.append(int(k))
	var burn := (f.burn if f.has(Face.Keyword.BURN) else 0) + extra_burn
	mine_seq += 1
	return {"damage": maxi(0, dmg), "weapon": plain or not f.is_debuff(), "keywords": kws, "seq": mine_seq, "by": ms.unit.display_name, "mech": mechs.find(ms),
		"face": real.to_dict() if real != null and not plain else {},
		"burn": _stacks_from(ms, "burning", burn) * doubled if burn > 0 and not plain else 0,
		"cryo": _stacks_from(ms, "cryoed", f.cryo) * doubled if f.has(Face.Keyword.CRYO) and not plain else 0,
		"flak": _stacks_from(ms, "flakked", f.flak) * doubled if f.has(Face.Keyword.FLAK) and not plain else 0,
		"row": int(area[0]) if area.size() >= 2 and not plain else 0,
		"column": int(area[1]) if area.size() >= 2 and not plain else 0,
		"chain": int(area[2]) if area.size() >= 3 and not plain else 0}


## A weapon or a debuff laid as a mine (the Fuse-delayed Bay): each strike a shot, its number as rolled and
## modified now, read as a blow's is (what heat fired and the hopper add, then the machine's
## modifiers) with no foe's, none standing there; the shots wait behind what is already laid.
## The spend's heat lands now and the hopper's loads are spent.
func _lay(ms: MechState, f: Face, slot: Vector2i) -> void:
	var fired := heat_bonus(ms, f)
	var loads := hopper_loads(ms.unit, f)
	var from_hopper := loads * f.power_per_load
	if f.vents_all:
		ms.heat = 0
	var doubled := Effects.stack_multiplier(ms.unit, f, null)
	var laid: Array = []
	var heat_total := 0
	var vent := 0
	var split := maxi(1, f.split)
	var roll := 0
	for s in range(maxi(1, f.strikes)):
		if s % split == 0:
			roll = f.power + fired + from_hopper
		var rolled := split_share(roll, split)   # a split entry's strike takes its share of the roll, rounded down, never below one
		var modded := Effects.attack(ms.unit, f, rolled, f.heat if s == 0 else 0, null)
		if s == 0:
			heat_total += int(modded["heat"])   # heat once a spend
		vent += int(modded["vent"])
		laid.append(_shot(ms, f, int(modded["damage"]), ms.face(), doubled, int(modded["burn"]), false, _area_shot(ms, f, fired + from_hopper, split)))
	var waiting: Array = mines.get(slot, [])
	waiting.append_array(laid)
	mines[slot] = waiting
	mine_tally["laid"] += laid.size()
	if ammo_price_of(ms, f) > 0:
		ms.ammo -= mini(ms.ammo, ammo_price_of(ms, f))   # a forging machine's gun pays ammo, laid or fired
		heat_total = Effects.debuff_heat(ms.unit, f)
	if loads > 0:
		Effects.spend_stacks(ms.unit, "hopper", loads)
	if vent > 0:
		ms.heat = maxi(0, ms.heat - vent)
	_add_heat(ms, heat_total, ms.face_index)
	var says: Array[String] = []
	for shot in laid:
		says.append(_shot_text(shot))
	log.append("%s lays %s in the %s rank's slot %d: %s" % [ms.unit.display_name, "a mine" if laid.size() == 1 else "%d mines" % laid.size(), "front" if slot.x == 0 else "back", slot.y + 1, ", ".join(says)])


## A spend's heat alone, for an entry whose spend lands no blow (the pull on an empty slot).
func _spend_heat(ms: MechState, f: Face) -> void:
	_add_heat(ms, int(Effects.attack(ms.unit, f, 0, f.heat)["heat"]), ms.face_index)


static func _shot_text(shot: Dictionary) -> String:
	var bits: Array[String] = [str(int(shot.get("damage", 0)))]
	for k in shot.get("keywords", []):
		bits.append(Face.keyword_label(int(k)))
	return " ".join(bits)


## What waits in a slot, the shots in laid order (the screen's mark and the bot read it).
func mines_at(slot: Vector2i) -> Array:
	return mines.get(slot, [])


## The foe stepping into a mined slot takes every shot waiting there (both slots of its column
## when massive), shot by shot in laid order, before it acts; shots left when it falls wait on.
## `pulled`: the shots came by the Lorentz Contractor's gather, for the runner's tally.
func _land(foe: Foe, pulled: bool = false) -> void:
	if mines.is_empty() or foe == null or not foe.alive() or foe.rank < 0:
		return
	var slots: Array[Vector2i] = [Vector2i(foe.rank, foe.column)]
	if foe.is_massive():
		slots = [Vector2i(0, foe.column), Vector2i(1, foe.column)]
	var shots: Array = []
	for slot in slots:
		if mines.has(slot):
			shots.append_array(mines[slot])
			mines.erase(slot)
	if shots.is_empty():
		return
	shots.sort_custom(func(a, b) -> bool: return int(a["seq"]) < int(b["seq"]))
	log.append("%s steps onto %d mine%s" % [foe.display_name, shots.size(), "" if shots.size() == 1 else "s"])
	var left: Array = []
	for shot in shots:
		if foe.alive():
			_mine_hit(foe, shot)
			mine_tally["pulled" if pulled else "landed"] += 1
		else:
			left.append(shot)
	if not left.is_empty():
		var waiting: Array = mines.get(slots[0], [])
		waiting.append_array(left)
		mines[slots[0]] = waiting
	_clear_dead()


## The machine that laid a shot, while it stands.
func _mine_spender(shot: Dictionary) -> MechState:
	var i := int(shot.get("mech", -1))
	if i < 0 or i >= mechs.size() or not mechs[i].alive():
		return null
	return mechs[i]


## One mine's shot on the foe that takes it, a blow as a weapon lands one: through each foe's
## damage taken (a Shocked arrival takes double, spending the shock) and its armour, then the shot's
## keywords acting as on a blow: Spread its rank neighbours too, Penetrate the other rank of its
## column and Splash both (a cluster), each taking the shot's number for its shape as laid, Spillover past a front kill, Burning, a stun, a web, Cryo (cashed
## for its spender, as any weapon's hit cashes it), Flak, Shock, Exposed, and Chain, its number
## as laid on every other Shocked foe on the field as the shot lands, then a charge on one other
## foe at random (28 and 29 October). The arrival is the shot's own foe: a Shock it carries doubles
## the shot and is spent, while a foe the shot only reaches keeps its own. A kill on a foe
## carrying the Syrinx Drone leaves the shot in its slot again.
func _mine_hit(foe: Foe, shot: Dictionary) -> void:
	var kws: Array = shot.get("keywords", [])
	var by := _mine_spender(shot)
	var source = by.unit if by != null else null
	var hit: Array[Foe] = [foe]
	var shape := {}   # each foe past the arrival -> the shape it stands in, for its number
	var row := kws.has(Face.Keyword.CLEAVE) or kws.has(Face.Keyword.SPLASH)
	var column := kws.has(Face.Keyword.PENETRATE) or kws.has(Face.Keyword.SPLASH)
	if row:
		for dc in [-1, 1]:
			var c: int = foe.column + dc
			if c >= 0 and c < columns:
				var n := foe_at(foe.rank, c)
				if n != null and n.alive() and not hit.has(n):
					hit.append(n)
					shape[n] = AREA_ROW
	if column and not foe.is_massive():
		var other := foe_at(1 - foe.rank, foe.column)
		if other != null and other.alive() and not hit.has(other):
			hit.append(other)
			shape[other] = AREA_COLUMN
	if row or column:
		# A twin slot reached whole, each half as the one it pairs with (the arrival's own beside it).
		for x in hit.duplicate():
			var t := twin_of(x)
			if t != null and not hit.has(t):
				hit.append(t)
				shape[t] = shape.get(x, AREA_ROW if row else AREA_COLUMN)
		hit = hit.filter(func(x: Foe) -> bool: return x.alive())
	# Chain (28 October): the shot arcs its number as laid to every other Shocked foe on the field
	# as it lands, after the shapes, so a foe in both takes one blow, its shape's; a shot laid
	# before the conductor, in an old save, carries no arc's number and arcs nothing.
	if kws.has(Face.Keyword.CHAIN) and shot.has("chain") and bool(shot.get("weapon", true)):
		for t in shocked_foes(foe):
			if not hit.has(t):
				hit.append(t)
				shape[t] = AREA_CHAIN
	var dmg := int(shot.get("damage", 0))
	var gained := {}
	var turned := {}   # foe -> the marks its Ward turned away, told once (28 October)
	var touched: Array[Foe] = []
	var webbed: Array[Foe] = []
	var thawed := 0
	# The shot's gate and its consumer travel with it (the face it was laid from): each foe it
	# reaches judged as the shot lands, before its own riders; each foe's own stacks eaten.
	var laid_face: Dictionary = shot.get("face", {}) if shot.get("face", {}) is Dictionary else {}
	var gate = (laid_face.get("gates", {}) as Dictionary).get("suppress", null) if laid_face.get("gates", {}) is Dictionary else null
	var eat := str(laid_face.get("consumes", ""))
	var shut: Array[Foe] = []
	if gate is Dictionary:
		for t in hit:
			if not Effects._holds(source, gate, null, t):
				shut.append(t)
	for t in hit:
		var hp_before := t.hp
		# Area by shape, numbered: the arrival takes the shot, every other foe its shape's number
		# as laid (a shot laid before the numbers, in an old save, half the shot), a conductor
		# Chain's.
		var at := int(shape.get(t, AREA_ROW))
		var blow := dmg
		if t != foe:
			blow = int(shot.get("chain", 0)) if at == AREA_CHAIN else int(shot.get("row" if at == AREA_ROW else "column", dmg / 2))
		if t != foe and at == AREA_CHAIN:
			log.append("a mine of %s's arcs to %s" % [str(shot.get("by", "")), t.display_name])
		var eaten := Effects.stacks_of(t, eat) if not eat.is_empty() else 0   # each foe it strikes eats its own
		if eaten > 0:
			blow += eaten * maxi(1, int(laid_face.get("per_consumed", 1)))
			Effects.remove(t, eat)
			log.append("a mine of %s's consumes %s ×%d on %s" % [str(shot.get("by", "")), str(Effects.STATUS.get(eat, {}).get("name", eat)), eaten, t.display_name])
		var weapon := bool(shot.get("weapon", blow > 0))   # a weapon's shot, a blow of 0 included; equipment's is none
		var taken := maxi(0, Effects.damage_taken(t, blow, source, weapon, t == foe) - (0 if kws.has(Face.Keyword.BREACH) else t.armour_total()))
		var barred := _barrier_eats(t, weapon)
		if barred:
			taken = 0   # a foe's Barrier takes the shot's blow whole (28 October)
		t.hp -= taken
		mine_tally["damage"] += clampi(taken, 0, maxi(0, hp_before))
		if weapon and t == foe and Effects.remove(t, "shocked"):   # the arrival, the shot's own foe; an area's foe or an arc's keeps its shock (29 October)
			log.append(("%s: the shock is spent on the Barrier" % t.display_name) if barred else ("%s: the shock lands, %d doubled" % [t.display_name, blow]))
		log.append("a mine of %s's hits %s for %d" % [str(shot.get("by", "")), t.display_name, taken])
		if not t.alive() and kws.has(Face.Keyword.DISPEL):
			_purge_foe("a mine of %s's" % str(shot.get("by", "")), t)   # a foe its shot killed stays down
		if not t.alive():
			if Effects.has(t, "syrinx_drone"):
				var again := shot.duplicate(true)
				mine_seq += 1
				again["seq"] = mine_seq
				_drone_mine(t, again)
			if kws.has(Face.Keyword.SPILLOVER) and t.rank == 0 and not t.is_massive():
				_mine_spill(t, taken - hp_before, hit, shot, source)
			continue
		if bool(shot.get("weapon", dmg > 0)) and Effects.has(t, "cryoed"):
			thawed += Effects.stacks_of(t, "cryoed")
			Effects.remove(t, "cryoed")
		if int(shot.get("burn", 0)) > 0:
			Effects.stack(t, Effects.STATUS["burning"], Effects.SKIRMISH, "mech", int(shot["burn"]))
			_note_status(gained, t, "burning", turned)
		if kws.has(Face.Keyword.SUPPRESS) and not shut.has(t) and _suppress(t):
			_note_status(gained, t, "suppressed")
		if kws.has(Face.Keyword.WEB) and not Effects.has(t, "webbed"):
			Effects.stack(t, Effects.STATUS["webbed"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
			_note_status(gained, t, "webbed", turned)
			if Effects.has(t, "webbed"):
				webbed.append(t)
		if int(shot.get("cryo", 0)) > 0:
			Effects.stack(t, Effects.STATUS["cryoed"], Effects.SKIRMISH, "mech", int(shot["cryo"]), Effects.DECAY_NONE)
			_note_status(gained, t, "cryoed", turned)
		if int(shot.get("flak", 0)) > 0:
			Effects.stack(t, Effects.STATUS["flakked"], Effects.SKIRMISH, "mech", int(shot["flak"]), Effects.status_decay(Effects.STATUS["flakked"]))
			_note_status(gained, t, "flakked", turned)
		if kws.has(Face.Keyword.DISPEL):
			_purge_foe("a mine of %s's" % str(shot.get("by", "")), t)   # every foe the entry reaches, a laid shot's arrival included (28 October)
		touched.append(t)
	for t in webbed:
		var caught := web_catch(t)
		log.append("a mine webs %s: it bursts after its action%s" % [t.display_name, "" if caught == null else ", on it and %s" % caught.display_name])
	for t in touched:
		if kws.has(Face.Keyword.SHOCK) and not Effects.has(t, "shocked"):
			Effects.stack(t, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
			_note_status(gained, t, "shocked", turned)
		if kws.has(Face.Keyword.EXPOSE):
			Effects.grant_for_rounds(t, Effects.STATUS["exposure"], "mech", round + 1)
			_note_status(gained, t, "exposure", turned)
	# Chain's charge as the shot lands (29 October): one other foe at random, not the arrival,
	# before the Ward's line, so a charge it turns away is told with the rest.
	if kws.has(Face.Keyword.CHAIN) and shot.has("chain") and bool(shot.get("weapon", true)):
		_chain_charge(foe, by, "a mine of %s's" % str(shot.get("by", "")), turned, int(shot.get("mech", -1)))
	_tell_turned(turned)
	for t in gained.keys():
		for status_id in gained[t]:
			_foe_gained_status(t, status_id)
	if thawed > 0 and by != null:
		var cooled := mini(by.heat, thawed * cryo_cool())
		by.heat -= cooled
		log.append("%s cashes Cryo ×%d: -%d heat" % [by.unit.display_name, thawed, cooled])


## Spillover in a mine: what the shot had past the kill of a front-rank foe carries into the
## foe behind it as plain damage, as a blow's spill does (_spill).
func _mine_spill(foe: Foe, amount: int, hit: Array[Foe], shot: Dictionary, source) -> void:
	var behind: Foe = back[foe.column]
	if amount <= 0 or behind == null or not behind.alive() or hit.has(behind):
		return
	var taken := maxi(0, Effects.damage_taken(behind, amount, source, false, false) - behind.armour_total())
	if _barrier_eats(behind, true):
		taken = 0
	behind.hp -= taken
	log.append("a mine of %s's spills over: %d into %s" % [str(shot.get("by", "")), taken, behind.display_name])
	if not behind.alive() and Effects.has(behind, "syrinx_drone"):
		var plain := {"damage": amount, "keywords": [], "by": shot.get("by", ""), "mech": shot.get("mech", -1), "face": {}, "burn": 0, "cryo": 0, "flak": 0}
		mine_seq += 1
		plain["seq"] = mine_seq
		_drone_mine(behind, plain)


## The Lorentz Contractor's pull (the Lammergeier's, 21 October): every mine on the field
## gathers into this slot in laid order, and a foe standing there takes them now.
func _pull(ms: MechState, slot: Vector2i) -> void:
	var shots: Array = []
	for at in mines.keys():
		shots.append_array(mines[at])
	mines.clear()
	if shots.is_empty():
		log.append("%s pulls, and nothing waits" % ms.unit.display_name)
		return
	shots.sort_custom(func(a, b) -> bool: return int(a["seq"]) < int(b["seq"]))
	mines[slot] = shots
	log.append("%s gathers %d mine%s into the %s rank's slot %d" % [ms.unit.display_name, shots.size(), "" if shots.size() == 1 else "s", "front" if slot.x == 0 else "back", slot.y + 1])
	var foe := foe_at(slot.x, slot.y)
	if foe != null and foe.alive():
		_land(foe, true)


## The Syrinx Drone on a foe (the Lammergeier's, Ryan's go of 21 October): the foe carries it,
## one at a time; if it carried Exposed before the spend the drone is Rapid (true), otherwise
## it gives the foe Exposed, never refreshing it.
func _drone(ms: MechState, foe: Foe, exposed_before: bool) -> bool:
	if Effects.turns_mark(foe, "syrinx_drone"):
		_turned_away(foe, "syrinx_drone", null, ms)   # its Ward turns the drone away; the spend's Rapid is the machine's (28 October)
	else:
		if not Effects.has(foe, "syrinx_drone"):
			Effects.stack(foe, Effects.STATUS["syrinx_drone"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
			_foe_gained_status(foe, "syrinx_drone")
		log.append("%s drones %s" % [ms.unit.display_name, foe.display_name])
	if exposed_before:
		return true
	_expose(foe, ms)
	return false


## A foe carrying the drone killed by a weapon's shot: the shot waits as a mine in the slot it
## empties (the front of a massive foe's column); one mine a drone.
func _drone_mine(foe: Foe, shot: Dictionary) -> void:
	Effects.remove(foe, "syrinx_drone")
	if foe.rank < 0:
		return
	var pair := twin_of(foe)
	if pair != null and pair.alive():
		# Its other half still holds the slot, and a held slot takes no mine (Ryan, 26 October:
		# "a half is treated as occupied"): the shot goes with it.
		log.append("the Syrinx Drone falls with %s: its other half holds the slot" % foe.display_name)
		return
	var slot := Vector2i(0 if foe.is_massive() else foe.rank, foe.column)
	var waiting: Array = mines.get(slot, [])
	waiting.append(shot)
	mines[slot] = waiting
	mine_tally["drone_laid"] += 1
	log.append("the Syrinx Drone leaves the killing shot in %s's slot: %s" % [foe.display_name, _shot_text(shot)])


## The rounds an entry goes dark once this machine spends it, this one included: its own
## cooldown (Rapid's switch-off one) or the one its machine's passives grant every weapon and
## debuff (the Kite's two), the longer.
func cooldown_of(ms: MechState, f: Face) -> int:
	if f == null:
		return 0
	return maxi(f.cooldown_rounds(), Effects.granted_cooldown(ms.unit, f))


## One attack's share of the reach tally (the runner's; the game never reads it).
func _tally_reach(reach: int, dealt: int, aimed_back: bool, heat: int) -> void:
	var k := str(Face.REACH_NAMES.get(reach, reach))
	var t: Dictionary = reach_tally.get(k, {"spends": 0, "damage": 0, "back": 0, "heat": 0})
	if not _chaining:
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


## Shocked (the Armadillo's retaliation, 28 September; built 29 September): the foe that struck
## carries one shock, never more, until a weapon's strike aimed at it spends it double. A machine's loop passive
## may catch the status like any other.
## Exposed on a foe through the next round (renewing, never adding): in Direct reach of every
## machine and its armour counting for nothing.
func _expose(foe: Foe, by: MechState, turned = null) -> void:
	if not foe.alive():
		return
	if Effects.turns_mark(foe, "exposure"):
		_turned_away(foe, "exposure", turned, by)
		return
	Effects.grant_for_rounds(foe, Effects.STATUS["exposure"], "mech", round + 1)
	log.append("%s exposes %s" % [by.unit.display_name, foe.display_name])
	_foe_gained_status(foe, "exposure")


func _shock(foe: Foe, by: MechState, turned = null) -> void:
	if not foe.alive() or Effects.has(foe, "shocked"):
		return
	if Effects.turns_mark(foe, "shocked"):
		_turned_away(foe, "shocked", turned, by)
		return
	Effects.stack(foe, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1, Effects.DECAY_NONE)
	log.append("%s shocks %s" % [by.unit.display_name, foe.display_name])
	_foe_gained_status(foe, "shocked")


## Spillover: `amount` of a blow, past the kill of the front-rank `foe`, carries into the foe
## behind it in the column as plain damage, through that foe's own damage taken and its armour;
## it feeds the talons' kill rule and carries no keyword of the blow, and, aimed at nobody, it
## neither doubles on a Shock nor spends one (29 October). A foe behind
## that the blow already reaches (a penetrate) takes the strike itself, never a spill too, and
## one already fallen takes nothing: nothing stands behind the back rank, so the damage is lost.
## `whole`: a later strike's whole number, a weapon's, which lands as its blow even at 0 (its
## Flak added); a kill's excess of 0 carries nothing.
func _spill(ms: MechState, f: Face, foe: Foe, amount: int, hit: Array[Foe], whole: bool = false) -> void:
	var behind: Foe = back[foe.column] if foe.column >= 0 and foe.column < columns else null
	if (amount <= 0 and not whole) or behind == null or not behind.alive() or hit.has(behind):
		return
	var behind_taken := maxi(0, Effects.damage_taken(behind, amount, ms.unit, whole, false) - behind.armour_total())
	if _barrier_eats(behind, true):
		behind_taken = 0   # the spill is the weapon's damage, so a Barrier takes it
	behind.hp -= behind_taken
	log.append("%s spills over: %d into %s" % [ms.unit.display_name, behind_taken, behind.display_name])
	if not behind.alive() and Effects.has(behind, "syrinx_drone"):
		_drone_mine(behind, _shot(ms, f, amount, null, 1, 0, true))   # the spill is plain damage, so its mine carries no keyword
	if not behind.alive() and f.devours > 0:
		_overcharge_on_kill(ms, behind, f.devours)


## The Soulcutter Talons' rule (28 September; built 29 September; a rule printed on its one
## carrier and no keyword to learn since 11 October, Ryan: "devour is not a thing"): every foe
## the entry kills gives its owner `per_kill` stacks of Empowered (a spread that kills two
## feeds twice, a Chain on every conductor it kills). The stacks halve each round like any Empowered;
## on the Ammit its Quintessence Tap keeps them for the battle (Effects.stack applies the keep).
func _overcharge_on_kill(ms: MechState, foe: Foe, per_kill: int) -> void:
	var stacks := _stacks_from(ms, "overcharged", per_kill)
	var m := Effects.stack(ms.unit, Effects.STATUS["overcharged"], Effects.SKIRMISH, "kill", stacks, Effects.status_decay(Effects.STATUS["overcharged"]))
	log.append("%s kills %s: %s ×%d" % [ms.unit.display_name, foe.display_name, m.name, Effects.stacks_of(ms.unit, "overcharged")])


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
## already acted this turn), then grows Numbed (two stacks, three for a massive foe). It
## resists at its own base resistance plus 10% a stack, on the skirmish's own die (Ryan, 26
## September): a suppress it shrugs off does nothing at all and numbs it no further, and
## Numbed loses a stack at each of the foe's turns, so a stun repeated on one foe stops
## landing while stuns spread across the formation keep working. A foe already suppressed
## gains nothing more, Numbed included: Suppressed never stacks and never carries (Ryan, 17
## October: "Suppressed is suppressed - they lose their next action. It does not stack, it
## does not carry"), so a Paradox tripping on a suppressed foe is wasted, its meter spent.
func _suppress(foe: Foe) -> bool:
	# A foe that has already acted this turn loses its next action instead of one it has taken,
	# and so does one a mine stuns as it steps in or one that stepped up mid-round (a split's
	# half), the round's turn being over.
	var next := _acted.has(foe) or _reinforcing or foe.fresh
	if _suppressed_through(foe, round + 1 if next else round):
		log.append("%s is already suppressed" % foe.display_name)
		return false
	var resist := foe.resist_total()
	if resist > 0 and resist < 100 and previewing:
		preview_notes.append({"kind": "resist", "foe": foe})   # a stun Numbed may shrug off is never promised
		return false
	if resist > 0 and rng.randi_range(1, 100) <= resist:
		log.append("%s shrugs off the suppression (%d%% resistant)" % [foe.display_name, resist])
		return false
	Effects.grant_for_rounds(foe, Effects.STATUS["suppressed"], "mech", round + 1 if next else round)
	Effects.stack(foe, Effects.STATUS["numbed"], Effects.SKIRMISH, "mech", NUMBED_PER_SUPPRESS_MASSIVE if foe.is_massive() else NUMBED_PER_SUPPRESS, Effects.DECAY_TICK)
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


## A mark a foe's Ward turned away outside a spend's own count (a drone, a machine's Retaliate):
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
## count. Numbed is a resistance, not a status.
func _foe_gained_status(foe: Foe, status_id: String) -> void:
	if status_id == "paradox" or status_id == "numbed" or not foe.alive() or Effects.turns_mark(foe, status_id):
		return
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
		if not foe.alive() or foe.fresh:
			continue   # one that stepped up mid-round has had its round: nothing to turn, as on a mine's arrival
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
		if not foe.alive() or foe.fresh:
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
	amount = Effects.damage_taken(ms.unit, amount, source)   # buffs and debuffs on damage taken, before shield and armour; the striker read for its statuses
	var brought := amount   # the blow as it arrives, for the round preview's incoming
	# A Barrier takes the next blow that deals anything, whole, and is spent; a blow of nothing
	# leaves it standing (Shocked's mirror). A Ward turns a breach away, so the shield absorbs
	# it like any blow (Ryan, 14 October).
	var barred := amount > 0 and Effects.has(ms.unit, "barrier")
	if barred:
		Effects.remove(ms.unit, "barrier")
		amount = 0
	var warded := source.breaches() and Effects.has(ms.unit, "ward")
	var breach := source.breaches() and not warded
	var r := _blow(ms.unit.shield, ms.unit.hull_max, ms.unit.armour + Effects.armour_against(ms.unit, source.rank), amount, breach)
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
		log.append("%s siphons the blow: +%d heat" % [ms.unit.display_name, siphoned])
	if int(r["through"]) > 0:
		_hull_damaged(ms)
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
	var injures := through > 0 and through * 100 >= hull_max * injury_pct
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


## At the round's end, the parts due back step into the pool, to fill a slot as any waiting
## foe does.
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
			if n is Foe:
				n.pack_id = core.pack_id
				n.joined = true
				reinforcements.append(n)
				log.append("%s grows back its %s" % [core.display_name, n.display_name])
		core.regrow_due = keep


## A foe's last act (15 October, the Behemoth's Meteor): its death blow lands the moment it
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
	if f.hits_all():
		for m in live_mechs():
			struck.append(mechs.find(m))
			_strike(f, m)
	else:
		var t := f.target as MechState
		if t == null or not t.alive():
			t = _repick(f)
		if t != null:
			struck.append(mechs.find(t))
			_strike(f, t)
	last_acts.append({"foe": f, "name": str(blow.get("name", "")), "mechs": struck})


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
		if not parts.is_empty() or not waiting.is_empty():
			log.append("%s falls, and its parts with it" % core.display_name)


## The pack a foe fights for, or null (a test's foes come from none).
func _pack_of(f: Foe) -> Unit:
	for sq in packs:
		if sq.id == f.pack_id:
			return sq
	return null


func _clear_dead_slots() -> void:
	var splits: Array = []   # [foe, rank, column]: the foes that split, stepping up once their slots are clear
	var risen: Array = []    # [foe, rank, column]: the foes getting back up, in the slots they fell from
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
					_falls += 1   # a foe down, gone or getting back up: what a spend counts as a kill
					_release_swallowed(f)   # a swallower down lets its machine go, whatever comes next
					# A foe that readied itself to get back up does so once, whole, in its own slot
					# and at once (Ryan, 26 October: "just like the gel splitting. It makes clearing
					# that column harder"), unless it went whole (a Bomb's burst).
					if Effects.has(f, "risen") and not f.stays_down:
						Effects.remove(f, "risen")
						f.hp = f.hp_max
						f.target = null
						f.modifiers.clear()
						risen.append([f, 0 if is_same(rank, front) or f.is_massive() else 1, col])
						log.append("%s falls, and gets back up" % f.display_name)
					else:
						log.append("%s destroyed" % f.display_name)
						var sq := _pack_of(f)
						if sq != null and not is_own(sq, f):
							joined_fallen[sq.id] = int(joined_fallen.get(sq.id, 0)) + 1
							var types: Dictionary = joined_fallen_types.get(sq.id, {})
							types[f.content_id] = int(types.get(f.content_id, 0)) + 1
							joined_fallen_types[sq.id] = types
						_last_act(f)
						if not f.on_death.is_empty() and f.on_death.has("summon"):
							splits.append([f, 0 if is_same(rank, front) else 1, col])
				f.rank = -1
			if cleared:
				# A twin slot's survivor keeps it alone; with none it is a plain empty slot.
				var standing: Array = members.filter(func(x) -> bool: return x != null and x.alive())
				rank[col] = standing[0] if not standing.is_empty() else null
				twins.erase(key)
	# A foe getting back up stands again in its slot once it is clear, its round over, and
	# takes a mine its fall left there; then a split steps up (the Gel's halves, in its place).
	for rs in risen:
		var back_up: Foe = rs[0]
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
		_split(sp[0], sp[1], sp[2])


## The reinforcement phase. Ranks hold: a front foe only ever stands in the front, a back
## foe only in the back, so the question "how is that ghoul hitting me from the back row"
## never comes up. Massive foes need a whole empty column and take both slots. Empty slots
## fill left to right, front rank first, each taking a random foe of the right rank from
## those waiting; the rest keep waiting.
func _reinforce(random: bool = true) -> void:
	_reinforcing = true
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
	# Then the mines (the Lammergeier's, 16 October): each arrival in a mined slot takes what
	# waits there once every arrival stands, left to right, so a Spread mine catches the
	# arrivals beside it, and before any of them acts.
	if not mines.is_empty():
		for col in range(columns):
			for r in [0, 1]:
				var f := foe_at(r, col)
				if f != null and f.alive() and (r == 0 or f != front[col]):
					_land(f)
	_reinforcing = false
	_refresh_kin()


## The reinforcements waiting, by the rank each will step into (the formation's reserve view, 22
## October): the front rank's, the back rank's (a foe that prefers the back), and the massive
## ones that take a whole empty column.
func reserve_counts() -> Dictionary:
	var out := {"front": 0, "back": 0, "massive": 0}
	for f in reinforcements:
		if f.is_massive():
			out["massive"] += 1
		elif f.prefers_back:
			out["back"] += 1
		else:
			out["front"] += 1
	return out


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
	# Any way into a mined slot but the reinforcement step's (a Swap, Minos's turn of the ranks)
	# sets it off at once.
	if not _reinforcing and not mines.is_empty():
		_land(f)


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
	# Shield past the maximum is the round's buffer, so it fades as the fight ends, mid-turn or by
	# a withdrawal, never carried onto the map and into the next fight (the mechanics audit, 25
	# October: only the round's end trimmed it).
	_trim_overshield()
	for ms in mechs:
		Effects.end_skirmish(ms.unit)
