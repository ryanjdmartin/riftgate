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
##             first (`forced`), one pack a fight and nothing joining (the long wall brief
##             3.4), so orders onto several packs queue and play one at a time; end_turn() when
##             done. A move lands in the battle at once and is
##             planned on the map (`planned`): the screen plays the plan on EXECUTE, ENGAGE or
##             END TURN (take_plan())
##   SKIRMISH  the fight attack() opened; the screen plays it, finish_skirmish() applies it
##             back to the map and the machines in it are spent; back to PLAN
##   DONE      outcome is set
##
## Hull never repairs during a battle; the shield is full as every fight opens and nothing
## returns on the map (the long wall brief 3.6); damaged faces persist on the unit.

enum State { PLAN, SKIRMISH, DONE }
enum Outcome { NONE, VICTORY, GATE_FALLEN, WRECKED }

## The old field's size, kept for the tests that pass a size of their own; a battle's own size is
## the ramp's (Ramp.wall_length_at, Ramp.depth_at; the long wall brief 3.1).
const DEFAULT_WIDTH := 9
const DEFAULT_HEIGHT := 20

var seed_value: int = 1
var map_kind := ""   # the map's shape (BattleMap.KINDS), set before setup: the intel the player will choose by; "" draws one by the seed
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
## The machines whose move this action has played on the map with an order standing (Ryan, 16
## November: "if an attack wasn't ordered, it cannot attack. What is allowed, is plotting a path,
## THEN selecting an attack in range. Once execute is run, the action is forfeit (barring undo, of
## course)"): mech id -> true. Its order stands as given: it takes no other, and taking it back
## ends the action. A move that plays with no order standing ends the action there (take_plan).
var played: Dictionary = {}
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
## The fights hunters forced this turn, first in line (bible section 5), one a hunter, a machine
## caught twice in two of them (Battlefield.forced_fights): [{"prey": Unit, "hunters": [the
## hunter]}]. While any is left, the first is the only fight that may open and the turn cannot
## end; its prey cannot move, and fights in each of its catches whether it has fought or not.
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
## stands at it, its commanders' numbers and its escort following (ContentDB.BOSS_TIERS), and
## its compositions, its Fractures and its elites are the tier's (Ramp).
var tier: int = 0
## The battle's ramp (the campaign's live Convergence, set before setup; 0 in the harness):
## the compositions on the field at the start, the timer, the tears a peak (Ramp, the one table
## of placeholders); it scales no pack.
var ramp: int = 0
## Every foe killed this battle, in any fight however it ended (Ryan, 7 October: a kill is a
## kill, and withdrawing never takes it away), for the salvage the campaign tallies at the
## battle's end and never shows while it is fought. The battle only counts; the campaign
## decides what is kept.
var foes_killed: int = 0
## The menace killed this battle, the one weight for the Rupture meter, Anathema and salvage (30
## October), tallied as each fight ends like the kills. Menace is a pack's threat rating since 11
## November (ContentDB.worth_of, in hundredths of a pip): a pack a fight has worn has paid the
## share of its rating its strike at the wall has lost, the heads gone of the heads it took the
## field with; its fall makes it whole; and nothing pays past it or twice (pack_paid).
var menace_killed: int = 0
var pack_paid: Dictionary = {}    # a standing pack's id -> what the tally holds of its rating so far, made whole as it falls
## The Rupture meter (the pacing session, 30 October; sized in beats since 11 November, the
## bible's pacing row): the tally above against the Fractures' thresholds, set at setup. The
## Rupture's size is the field's part and the elites'. The field's part is the menace
## the opening places (the boss unit aside) and the tide sends through the ramp's beats
## (Ramp.beats_at: the rift's compositions and the tears' patrols, peak by peak), less the
## lightest patrol the tide deals, which the squad may leave (RUPTURE_LEAVE); so it follows
## the ramp's counts without a table of its own, level across the domains, and the seal is
## earned by fighting the tide, never the opening alone. Each elite the tier's Fractures call
## adds its rating's worth, four pips, whichever elite comes. The Fractures split the
## size at growing steps (later ones cost more). A Fracture pays out as a fight ends: the log
## names it, and at the Fractures the tier names the next elite composition of the lead's
## domain not yet fought this battle spawns at the rift. The last Fracture is the Rupture: the
## boss's seal breaks. Nothing else breaks it: a field cleared is the squad's own breathing
## room until the next peak (Ryan, 11 November; the stall guard of 30 October, which broke the
## seal on a cleared field, is gone). Rift Pressure keeps running after. The prize a Fracture
## may bring is not built (decided after the meter is played).
const FRACTURE_STEPS := [1.0, 1.5, 2.0, 2.5, 3.0]
const RUPTURE_LEAVE := 1          # patrols' worth the field's part leaves the squad to leave, the tide's lightest; placeholder
var thresholds: Array = []        # the menace each Fracture is earned at, the tier's count of them
var fractures: int = 0            # Fractures earned so far
var rupture_turn: int = -1        # the phase the seal broke at; -1 while it holds (or with no seal)
var elites_spawned: Array = []    # the elite compositions spawned this battle, by id
var field_menace: int = 0         # the menace of the opening and the tide through the beats, the thresholds' base
## The pack bonus on trial, menace a pack pays the Rupture meter as it falls, on top of its
## rating's worth, 0 the game's (Ryan, 23 November: "Maybe add a flat fracture bonus to a pack on
## top of the per-foe weight, so that splitting into 4 fights across the map and grouping for
## bigger packs are both viable ways of farming fracture"). Every pack but the boss's unit pays it,
## once, as its last foe falls; the meter's size counts it for every pack it counts (setup), so
## the battle's length holds and what moves is the mix: at half a pip a pack for one machine
## fills the meter half again as fast as its pips, a pack for two a quarter again, a formation a
## sixth. The tally (salvage's and Anathema's) is never touched. A debug build's SETTINGS →
## TRIALS → PACK BONUS and RIFTGATE_PACK_BONUS set it (Settings.field_trial).
static var pack_bonus_trial: int = 0
var meter_bonus: int = 0          # menace the pack bonus's trial has added to the meter this battle; 0 with no trial
## The battle's share of the run's Sponsorship measures (the bible's Sponsorship row): the
## hexes its machines move on the map, and each fight's own (Skirmish.sponsorship), added up.
var sponsorship := {"hexes_moved": 0, "guarded": 0, "damaging_spends": 0, "quiet_spends": 0}   # ContentDB.SPONSORSHIP_MEASURES
var action_hexes: Dictionary = {}   # mech id -> hexes moved in its current action, taken back with an undo
## The move points a machine has spent on its waypoints this action (Ryan, 22 November: "If
## points remain, re-draw reachable hexes from the waypoint ... until movement points are
## emptied"): mech id -> the cost walked, water's two included. A move is laid a waypoint at a
## time until it plays (execute) or the move is spent.
var move_used: Dictionary = {}
## The caches claimed this battle, in the order claimed (the bible's loot rows; built 7
## November): each {"kind", "tier", "salvage", "components": [ids], "blueprint": an id or "",
## "by": the machine's id}. The campaign banks them as the battle ends, as it banks the kills.
var loot: Array = []
## The run's blueprints as the battle opens (the campaign sets them before setup), so a cache's
## blueprint is one the run holds none of.
var blueprints_known: Array = []


func _init(seed_arg: int = 1) -> void:
	seed_value = seed_arg
	rng.seed = seed_arg
	db = ContentDB.load_default()


# ---------------------------------------------------------------- setup

## Generate the map, stand the team in front of the gate, place the faction's formation in the
## north third of the field and its boss just south of the rift, then preview the first enemy
## moves.
func setup(team: Array, faction_id: String = "", w: int = -1, h: int = -1) -> void:
	# The field's size is the ramp's (the long wall brief 3.1): a width or height of -1 reads
	# Ramp.wall_length_at and Ramp.depth_at at the battle's ramp; a test passes a size of its own
	# (DEFAULT_WIDTH and DEFAULT_HEIGHT stay for those), and nothing in the game passes one.
	if w < 0:
		w = Ramp.wall_length_at(ramp)
	if h < 0:
		h = Ramp.depth_at(ramp)
	faction = faction_id if not faction_id.is_empty() else db.default_faction()
	map = BattleMap.generate(w, h, seed_value, map_kind)
	field = Battlefield.new(map)
	field.spawn_faction = faction
	field.ramp = ramp
	field.seed_value = seed_value
	field.rift_pressure_max = Ramp.timer_at(ramp)
	# The siege under way (the long wall brief 3.2): the pressure opens a turn short of its peak,
	# so the rift's first wave spawns at the end of turn one, behind the formations already close.
	field.rift_pressure = maxi(0, field.rift_pressure_max - 1)   # placeholder (the long wall brief)
	field.foe_profiles = db.pack_profiles()
	# What the rift sends and what stands on the field at the start (the foes' fresh start, 30
	# October): the tier's compositions, the lead's and the guest's in turn, formations and
	# patrols in turn in the cycle, the patrols alone in the tears' cycle; on the field at the
	# start the ramp's count of formations (the second the guest's where there is one) and
	# patrols, at the ramp's density. The harness's composed side (`formation`) is each entry a
	# pack of one type under its own foe's faction, all placed and all cycled, as before.
	var placed: Array = []   # [composition, hex, opening, band]: opening 0 places it on the hex, 1 a move of its own from the apron, 2 two moves; band, the band of the wall it makes for under the graded tide, -1 with none
	var w_cols := w
	if not formation.is_empty():
		var comps: Array = []
		for e in formation:
			var fac := db.faction_of_foe(str(e[0]))
			var comp := Battlefield.composition([[str(e[0]), int(e[1])]], fac if not fac.is_empty() else faction)
			comp["squad"] = ContentDB.SQUAD_DEFAULT   # a pack of no composition: for three (the long wall brief 3.7)
			comps.append(comp)
		field.cycle = comps
		field.patrol_cycle = comps.duplicate(true)
		for j in range(comps.size()):
			placed.append([comps[j], Hex.offset_to_axial((w_cols * (j + 1)) / (comps.size() + 1), 3 + (j % 3)), 0, -1])
	else:
		var has_guest := not guest.is_empty() and guest != faction and db.factions.has(guest)
		# The tier's compositions the ramp's gate holds (7 November: variants placed on the tier and
		# the ramp; one with no gate at every ramp).
		var forms := _alternate(db.compositions(faction, tier + 1, "formation", ramp), db.compositions(guest, tier + 1, "formation", ramp) if has_guest else [])
		var patrols := _alternate(db.compositions(faction, tier + 1, "patrol", ramp), db.compositions(guest, tier + 1, "patrol", ramp) if has_guest else [])
		field.cycle = _alternate(forms, patrols)
		field.patrol_cycle = patrols
		var nf := Ramp.formations_at(ramp)
		var np := Ramp.patrols_at(ramp)
		if Battlefield.graded_tide:
			# The graded tide (Battlefield.graded_tide): the domain's packs by rating, the guest's
			# in turn with them, each list taken from a start of its own by the battle's seed; the
			# hunting packs apart. Its opening is its own (graded_opening).
			var mine := db.graded_packs(faction, tier + 1, ramp)
			var theirs := db.graded_packs(guest, tier + 1, ramp) if has_guest else {}
			for r in [1, 2, 3]:
				var pool := _alternate(mine.get(r, []), theirs.get(r, []))
				if not pool.is_empty():
					field.graded[r] = pool
					field._graded_at[r] = posmod(hash([seed_value, r]), pool.size())
			field.hunters = patrols.filter(func(c: Dictionary) -> bool: return not str(c.get("hunts", "")).is_empty())
		if not field.graded.is_empty():
			for e in graded_opening(ramp, w_cols):
				placed.append([field.next_graded(int(e[1])), Hex.offset_to_axial(int(e[2]), OPENING_FLOOR_ROW), int(e[3]), int(e[0])])
			forms = []
			patrols = []
		# The opening (the long wall brief 3.2): the ramp's formations across the width as before,
		# each a move of its own from the apron, so its first walk reaches the wall; the ramp's
		# patrols on the flanks, two moves out. The rows are set once each pack is dressed and
		# its pace known (_open_rows, below).
		if not forms.is_empty():
			for k in range(nf):
				placed.append([forms[k % forms.size()], Hex.offset_to_axial((w_cols * (k + 1)) / (nf + 1), OPENING_FLOOR_ROW), 1, -1])
		# No hunter stands on the field at turn one (Ryan, 8 November: "no hunters should be on the
		# field turn one, but that was a formation pass issue, I think"): the opening's patrols are
		# the tier's that push, in their order, and the hunting packs come with the tide and the
		# tears. A tier whose patrols all hunt opens with them all the same.
		var openers: Array = patrols.filter(func(c: Dictionary) -> bool: return str(c.get("hunts", "")).is_empty())
		if openers.is_empty():
			openers = patrols
		if not openers.is_empty():
			for k in range(np):
				var inset := (k / 2) * 3   # the two flanks' edges first, then three columns in at a time
				placed.append([openers[k % openers.size()], Hex.offset_to_axial(inset if k % 2 == 0 else w_cols - 1 - inset, OPENING_FLOOR_ROW), 2, -1])
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
	for p in placed:
		if (p[0] as Dictionary).is_empty():
			continue
		var sq := field.emerge(p[0], p[1], 0, 1, int(p[3]))
		if sq != null and int(p[2]) > 0:
			_open_row(sq, Hex.axial_to_offset(p[1]).x, int(p[2]))
			field.assign_goal(sq, 0, 1, int(p[3]))   # its segment is read from where it opens: the wall it reaches soonest, or its band's under the graded tide
	var fac: Dictionary = db.factions.get(faction, {})
	var firsts := db.bosses_of(faction)
	var boss_id := str(lineup[0]) if not lineup.is_empty() else (firsts[0] if not firsts.is_empty() else "")
	if with_boss and db.foes.has(boss_id):
		boss = make_boss_unit(db, faction, tier, boss_id, lineup, escort, ramp)
		boss.pos = field.nearest_standable(boss, boss_home(map))   # its hex, held for the battle (the nearest free one should a pack hold it)
		field.add_unit(field.dress_pack(boss, boss_id))
	# The caches, on the field from the first turn (Ryan, 7 November), round the units placed.
	field.seed_caches(db, seed_value)
	# The Rupture meter, sized in beats (11 November), and the seal on the boss while there is a
	# field to earn it against. The field's part: the compositions placed and the tide through the
	# ramp's beats, as Battlefield.peak sends it (the rift's cycle in order; a patrol from every
	# tear open before a peak, in the tears' cycle's order; the ramp's tears opening after it),
	# each at its threat rating's worth, so a layout's draw moves no threshold. Placeholders.
	# Every mouth's sends are counted (Battlefield.sends_trial), and under the graded tide each
	# at the mean of the bands its mouth draws from (Battlefield.graded_mean), with the hunting
	# pack the rift sends every other peak.
	field_menace = 0
	var packs_counted := 0   # the packs that menace comes in, for the pack bonus's trial
	for p in placed:
		if not (p[0] as Dictionary).is_empty():
			field_menace += db.composition_menace(p[0])
			packs_counted += 1
	var sends := maxi(1, Battlefield.sends_trial)
	var tears_open := 0
	var cycle_at := 0
	var patrol_at := 0
	for j in range(Ramp.beats_at(tier)):
		if not field.graded.is_empty():
			field_menace += sends * Battlefield.graded_mean(true) + tears_open * sends * Battlefield.graded_mean(false)
			packs_counted += sends * (1 + tears_open)
			if j % 2 == 1 and not field.hunters.is_empty():
				field_menace += db.composition_menace(field.hunters[(j / 2) % field.hunters.size()])
				packs_counted += 1
		else:
			for k in range(sends):
				if field.cycle.is_empty():
					break
				field_menace += db.composition_menace(field.cycle[cycle_at % field.cycle.size()])
				packs_counted += 1
				cycle_at += 1
			for t in range(tears_open * sends):
				if field.patrol_cycle.is_empty():
					break
				field_menace += db.composition_menace(field.patrol_cycle[patrol_at % field.patrol_cycle.size()])
				packs_counted += 1
				patrol_at += 1
		tears_open += Ramp.tears_at(ramp)
	# The lightest patrol the tide deals is the squad's to leave; an elite the tier calls is
	# its size's rating, whichever comes.
	var lightest := ContentDB.MENACE_PER_PIP if not field.graded.is_empty() else 0
	for c in (field.patrol_cycle if field.graded.is_empty() else []):
		var m := db.composition_menace(c)
		lightest = m if lightest == 0 else mini(lightest, m)
	var elite := ContentDB.worth_of(int(ContentDB.SQUAD_BY_SIZE["elite"]))
	thresholds = []
	var n := Ramp.fractures_at(tier)
	if field_menace > 0 and n > 0:
		var size := maxi(1, field_menace - RUPTURE_LEAVE * lightest) + Ramp.elite_fractures_at(tier).size() * elite
		# The pack bonus's trial: every pack the size counts pays its bonus, the one the squad may
		# leave aside and each elite with them.
		size += maxi(0, pack_bonus_trial) * (maxi(0, packs_counted - (RUPTURE_LEAVE if lightest > 0 else 0)) + Ramp.elite_fractures_at(tier).size())
		var steps: Array = []
		var total := 0.0
		for k in range(n):
			total += float(FRACTURE_STEPS[mini(k, FRACTURE_STEPS.size() - 1)])
			steps.append(total)
		for k in range(n):
			thresholds.append(maxi(1, roundi(float(size) * float(steps[k]) / total)))
	if boss != null and not thresholds.is_empty():
		boss.sealed = true
	field.set_shell(is_sealed())   # the seven beside the rift closed to the machines while the seal stands
	state = State.PLAN
	_new_turn()


## A boss unit as a battle fields it, wherever it is fought (the battle's setup, the quick
## campaign's boss, final and finale, the harness's fight; Ryan, 7 November: one code tree for both
## modes): its commanders (`lineup_ids`: the boss, a final's hero, the finale's line; empty for the
## domain's first, `boss_id`), going by the party's name for a line, a true four (Ryan, 6 November;
## the long wall brief 3.7), at the tier (ContentDB.BOSS_TIERS: its numbers); its escort a named one
## (`escort_spec`: [a foe id, or "" for the tier's own units, as a final's wildlife; a count]), else
## its curated composition at the tier whose ramp gate holds `ramp_at` (an `escort`), else none: never
## grown by the tier (Ryan, 7 November). Unplaced and undressed: the caller does those.
static func make_boss_unit(content: ContentDB, faction_id: String, t: int, boss_id: String, lineup_ids: Array = [], escort_spec: Array = [], ramp_at: int = -1) -> Unit:
	var named := "the party" if lineup_ids.size() > 1 else str(content.foes.get(boss_id, {}).get("name", boss_id)).to_lower()
	var u := Unit.boss(0, named, Vector2i.ZERO, faction_id, Unit.BOSS_MOVE)
	u.squad = 4
	u.lineup = lineup_ids.duplicate()
	u.boss_tier = t
	u.boss_step = ContentDB.step_in_tier(t, ramp_at)
	if escort_spec.size() >= 2:
		if content.foes.has(str(escort_spec[0])):
			u.foe_id = str(escort_spec[0])
		u.strength = maxi(0, int(escort_spec[1]))
	else:
		var tailored := content.escort_composition(faction_id, t + 1, boss_id, ramp_at)
		if not tailored.is_empty():
			var members: Array = []
			for m in tailored["members"]:
				members.append([str(m[0]), int(m[1])])
			u.set_members(members)
	return u


## The graded tide's opening (Ryan, 24 November: "There needs to be more packs on the field at the
## start, for sure"): packs before every band of the wall, each of its band's rating and each
## its own moves from the row before the wall, as [band, rating, column, moves], in the order
## they are stood. Before the middle the ramp's count of packs for three (Ramp.formations_at), the
## first two moves out and each after it a move farther back, so they come down the centre one
## behind another; a pack for two before each band between, three moves out; at each end two packs
## for one, the outer three moves out and the inner two. Nothing strikes on the first turn. Seven
## packs at the first Convergence, eight from the third and nine from the eighth, where the game
## as built stands three, four and four. The session's form and placeholders all: a set form by
## Convergence is Ryan's to mark (docs/briefs/graded_tide.md).
static func graded_opening(ramp_at: int, cols: int) -> Array:
	var n := Battlefield.BAND_RATING.size()
	var by_band: Array = []   # every band's columns, in order along the wall
	for b in range(n):
		by_band.append([])
	for col in range(cols):
		(by_band[clampi((col * n) / maxi(1, cols), 0, n - 1)] as Array).append(col)
	var out: Array = []
	var mid := n / 2
	for b in range(n):
		if (by_band[b] as Array).is_empty():
			return out   # a field too narrow to have five bands opens with nothing of this form
	var middle: Array = by_band[mid]
	for k in range(Ramp.formations_at(ramp_at)):
		# About the band's middle column: on it, then a column either side in turn.
		var step := ((k + 1) / 2) * (1 if k % 2 == 1 else -1)
		var col: int = middle[clampi(middle.size() / 2 + step, 0, middle.size() - 1)]
		out.append([mid, int(Battlefield.BAND_RATING[mid]), col, 2 + k])
	for b in range(1, n - 1):
		if b == mid:
			continue
		var between: Array = by_band[b]
		# A band on the wall's far side stands its pack as the near side's mirror.
		var col: int = between[between.size() / 2] if b < mid else between[(between.size() - 1) / 2]
		out.append([b, int(Battlefield.BAND_RATING[b]), col, 3])
	var first: Array = by_band[0]
	var last: Array = by_band[n - 1]
	# One end's outer and inner, then the other's inner and outer: the packs for one come in turn
	# from their list, so each end stands two different packs where the list holds two.
	out.append([0, int(Battlefield.BAND_RATING[0]), int(first[0]), 3])
	out.append([0, int(Battlefield.BAND_RATING[0]), int(first[first.size() - 1]), 2])
	out.append([n - 1, int(Battlefield.BAND_RATING[n - 1]), int(last[0]), 2])
	out.append([n - 1, int(Battlefield.BAND_RATING[n - 1]), int(last[last.size() - 1]), 3])
	return out


## The opening's row for a pack placed at the start (the long wall brief 3.2): `moves` of its own
## pace short of the apron row (a formation one, a patrol two), never into the rift's mouth, at
## its column; it lands there as any spawn lands (Battlefield.landing: the nearest hex it can
## stand on with no machine beside it), a pusher on ground that has a way to the wall. A pack that hunts opens a row further back at a time
## until it has caught nobody, so no battle opens on a forced fight (Ryan, 6 November: "I
## probably would shy away from hitting the first battle with a fight in the first turn, that's
## for sure. That's just mean"); its first walk is the enemy's first turn, after the player's.
## A hunter catches at the engage range, 1 (Unit.ENGAGE_RANGE), and the machines open eight rows or
## more below the floor, so a hunter always finds a row clear of them.
const OPENING_FLOOR_ROW := 1   # the row nearest the rift a pack opens on: the rift's own row is the spawns' (10 November, the mouth no longer rows)
## How many moves farther from the wall the opening's packs stand, a trial beside Ramp.depth_trial
## and 0 for the opening as the brief has it (10 November): the opening is measured from the wall,
## so a deeper field alone leaves a formation's first walk on the wall as before; a debug build's
## SETTINGS → OPENING and RIFTGATE_OPENING set it (Settings.field_trial).
static var opening_trial: int = 0


func _open_row(sq: Unit, col: int, moves: int) -> void:
	moves += maxi(0, opening_trial)
	var row := maxi(OPENING_FLOOR_ROW, field.apron_row() - moves * sq.movespeed)   # placeholder (the long wall brief)
	# A pusher opens on ground with a way to the wall (Battlefield.wall_ground), never in a pocket
	# the shape closed off, where it would hold its hex for the battle.
	var ground := field.wall_ground(sq) if sq.behaviour == "push" else {}
	sq.pos = field.landing(sq, Hex.offset_to_axial(col, row), OPENING_FLOOR_ROW, {}, ground)
	while sq.behaviour == "hunt" and row > OPENING_FLOOR_ROW and field.catch_of(sq) != null:
		row -= 1
		sq.pos = field.landing(sq, Hex.offset_to_axial(col, row), OPENING_FLOOR_ROW)


## Whether the boss's seal holds: it cannot be ordered onto and joins no fight until the Rupture.
## The boss's hex (Ryan, 10 November: "Put him on the single hex in front of the two new out of
## play ones"): the one hex touching both of the rift's front hexes, on its middle line, so it
## stands centred in front of the rift in either view of the map; it holds it for the battle and
## never walks. Its fight is ordered from a hex beside it, and takes every machine.
static func boss_home(m: BattleMap) -> Vector2i:
	return Hex.offset_to_axial(Hex.axial_to_offset(m.rift).x, BattleMap.RIFT_ROWS)


func is_sealed() -> bool:
	return boss != null and boss.sealed


## What the Rupture meter reads: the menace killed, and what the pack bonus's trial has paid.
func meter() -> int:
	return menace_killed + meter_bonus


## The Rupture: the seal breaks, by the last Fracture. Engaging the boss is the battle's last
## decision from here (the bible's boss row).
func rupture() -> void:
	if boss == null or not boss.sealed:
		return
	boss.sealed = false
	rupture_turn = field.phase
	field.set_shell(false)   # the shell bursts with the seal: the seven open to the machines
	field.log.append("THE RUPTURE: the seal breaks")
	# The tide quickens (the long wall brief 3.8; Ryan, 6 November, of a re-seal: "Isn't that just
	# a feel-bad, or a non-choice?"): nothing re-seals, and the beat halves once, so each turn of
	# delay costs more at the wall and the sally is the release; a peak's own step still applies.
	field.rift_pressure_max = maxi(1, field.rift_pressure_max / 2)   # placeholder (the long wall brief)
	field.log.append("the rift convulses: the beat is now %d" % field.rift_pressure_max)


## The Fractures earned by the meter so far, each paying out in turn: the log names it, the
## elite the tier names at it spawns at the rift, and the last breaks the seal. Read as a fight
## ends, after the map has taken its result. A field cleared with the seal standing earns
## nothing by itself (Ryan, 11 November: "a clear field is its own reward, it's breathing room
## to reposition or get loot"); the next peak comes on its beat.
func _fractures() -> void:
	while fractures < thresholds.size() and meter() >= int(thresholds[fractures]):
		fractures += 1
		field.log.append("FRACTURE %d of %d" % [fractures, thresholds.size()])
		if Ramp.elite_fractures_at(tier).has(fractures):
			_spawn_elite()
		if fractures == thresholds.size():
			rupture()


## The next elite composition of the lead's domain not yet fought this battle emerges at the
## rift (the elites' moment is a Fracture, 30 October); none when the domain's are spent.
func _spawn_elite() -> void:
	# The domain's next own elite, or a wanderer on the Fracture's roll (ContentDB.next_elite,
	# 2 November); each once a battle.
	var c := db.next_elite(faction, tier + 1, elites_spawned, _elite_roll(), ramp)
	if c.is_empty():
		return
	var sq := field.emerge(c, map.rift)
	if sq == null:
		return
	sq.boss_tier = tier   # a wandering elite stands at the battle's tier (31 October)
	sq.boss_step = ContentDB.step_in_tier(tier, ramp)
	elites_spawned.append(str(c["id"]))
	field.log.append("An elite emerges at the rift: %s" % sq.display_name)


## The Fracture's roll for a wanderer, from the battle's seed and its count of Fractures, so
## a resumed battle rolls as the unbroken one did (the save keeps both and no third stream)
## and the battle's own streams run on untouched.
func _elite_roll() -> float:
	return float(absi(hash(Vector2i(seed_value, fractures))) % 1000) / 1000.0


func _pack_name(foe_id: String) -> String:
	if db.foes.has(foe_id):
		return "%s pack" % str(db.foes[foe_id]["name"]).to_lower()
	return "%s pack" % foe_id


## Two lists in turn, the first's first, the leftovers of the longer after.
static func _alternate(a: Array, b: Array) -> Array:
	var out: Array = []
	for k in range(maxi(a.size(), b.size())):
		if k < a.size():
			out.append(a[k])
		if k < b.size():
			out.append(b[k])
	return out


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


## The hunters that caught this machine, in field order: its fights to come, one a hunter, which
## the map draws as the machine's orders onto them and the board names; empty while none has.
func catchers_of(u: Unit) -> Array:
	var out: Array = []
	for f in forced:
		if f["prey"] == u:
			out.append_array(f["hunters"])
	return out


## Whether a machine may move now: the player's turn, an action left, its move not yet played
## this action, move points left to lay a waypoint with, not caught.
func can_move(u: Unit) -> bool:
	return state == State.PLAN and actions_left(u) > 0 and not played.has(u.id) and move_left(u) > 0 and not is_pinned(u)


## The move points a machine has left this action: its move less what its waypoints have spent.
func move_left(u: Unit) -> int:
	return maxi(0, u.movespeed - int(move_used.get(u.id, 0))) if u != null else 0


## Hexes a machine may move to now, from its latest waypoint with the move it has left; a
## carrier only where the block it carries fits (the Swallowtail's carry), its riders lifted off
## its way.
func destinations_for(u: Unit) -> Dictionary:
	if u == null or not can_move(u):
		return {}
	var riders := _lift(u)
	var out := field.reachable(u, move_left(u))
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
	if u == null or state != State.PLAN or actions_left(u) <= 0 or played.has(u.id):
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


## Whether rider `r` could land on `h`: on the map, no structure, ground it stands on, no wreck,
## and no unit there but the block itself (the carrier and the riders are lifted).
func _lands_on(r: Unit, h: Vector2i, u: Unit, riders: Array[Unit]) -> bool:
	for o in r.footprint:
		var at: Vector2i = h + o
		if not field.map.has(at) or field.map.is_structure(at):
			return false
		if not BattleMap.passable(field.map.terrain[at], r.traits):
			return false
		if field.wreck_at(at) != null or (r.is_player() and field.shell.has(at)):
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
	var route := field.route_to(u, to, move_left(u))
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
	var cost := field.route_cost(u, route, move_left(u))
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
	var cost := maxi(0, field.route_cost(u, route, move_left(u)))
	_set_down()
	var lands: Dictionary = landing(u, riders, route[route.size() - 1])["to"] if not riders.is_empty() else {}
	_push(u)
	var piece := {"unit": u.id, "from": _arr(u.pos), "facing": u.facing, "path": route.map(func(h): return _arr(h)), "riders": []}
	for r in riders:
		(piece["riders"] as Array).append([r.id, r.pos.x, r.pos.y, r.facing, (lands[r] as Vector2i).x, (lands[r] as Vector2i).y])
	moved[u.id] = true   # it has moved this action: a waypoint laid
	move_used[u.id] = int(move_used.get(u.id, 0)) + cost
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
	var spends := {}
	for uid in spent.keys():
		spends[str(uid)] = int(spent[uid])
	var who_played: Array = []
	for uid in played.keys():
		who_played.append(int(uid))
	var used := {}
	for uid in move_used.keys():
		used[str(uid)] = int(move_used[uid])
	return {"who": who.id if who != null else 0, "units": units, "moved": who_moved, "spent": spends, "played": who_played, "move_used": used,
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
	# No fight lies between a snapshot and now (a fight empties the undo), so the actions it
	# held spent are the fights before it and the moves played before it.
	if snap.has("spent"):
		spent.clear()
		var spends: Dictionary = snap["spent"]
		for k in spends.keys():
			spent[int(str(k))] = int(spends[k])
	played.clear()
	for uid in snap.get("played", []):
		played[int(uid)] = true
	move_used.clear()
	var used: Dictionary = snap.get("move_used", {})
	for k in used.keys():
		move_used[int(str(k))] = int(used[k])
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


# ---------------------------------------------------------------- an order given again

## Whether a machine has a move planned and not yet played, or an order waiting.
func has_plan(u: Unit) -> bool:
	if u == null:
		return false
	if orders.has(u.id):
		return true
	for p in planned:
		if int(p["unit"]) == u.id:
			return true
	return false


## Where everyone it moved stands once a machine's plan is taken back on its own, unit id ->
## [hex, facing]: the machine where its move started and whoever it carried where each rode from;
## empty for a machine with no move planned. `blocked` is set when it cannot be taken back out of
## order: it rides in another machine's planned carry, one it carried has since been given a move
## or an order of its own, or another machine now stands where one of them would go back to.
func _retaken(u: Unit) -> Dictionary:
	var back := {}
	var blocked := false
	for p in planned:
		for r in p.get("riders", []):
			if int(r[0]) == u.id:
				blocked = true
		if int(p["unit"]) != u.id:
			continue
		back[u.id] = [Vector2i(int(p["from"][0]), int(p["from"][1])), int(p["facing"])]
		for r in p.get("riders", []):
			back[int(r[0])] = [Vector2i(int(r[1]), int(r[2])), int(r[3])]
	for id in back.keys():
		if int(id) != u.id:
			var rider := field.unit_by_id(int(id))
			blocked = blocked or orders.has(int(id))
			for p in planned:
				blocked = blocked or (rider != null and int(p["unit"]) == rider.id)
		var there := field.unit_at(back[id][0])
		if there != null and not back.has(there.id):
			blocked = true
	return {"back": back, "blocked": blocked}


## Whether a machine's plan (its planned move, its order) can be taken back on its own, whatever
## was planned after it (Ryan, 10 November: "If I order a unit to move or engage, I should be able
## to re-order them by tapping on them again").
func can_retake(u: Unit) -> bool:
	return state == State.PLAN and has_plan(u) and not bool(_retaken(u)["blocked"])


## Take a machine's plan back with no undo step of its own: it and whoever it carried stand where
## they stood, its move is its to give again, its order is gone.
func _retake(u: Unit) -> void:
	var back: Dictionary = _retaken(u)["back"]
	for id in back.keys():
		var m := field.unit_by_id(int(id))
		if m != null:
			m.pos = back[id][0]
			m.facing = int(back[id][1])
	var kept: Array = []
	for p in planned:
		if int(p["unit"]) == u.id:
			var n := (p["path"] as Array).size()
			sponsorship["hexes_moved"] = maxi(0, int(sponsorship["hexes_moved"]) - n)
			action_hexes[u.id] = maxi(0, int(action_hexes.get(u.id, 0)) - n)
		else:
			kept.append(p)
	if kept.size() != planned.size():
		moved.erase(u.id)
		move_used.erase(u.id)
	planned = kept
	orders.erase(u.id)
	if played.has(u.id):
		_end_action(u.id)   # its move has played: its order taken back, its action is over
	last_carry = []
	_prune_orders()


## Whether a snapshot holds any of a machine's plan: a piece of its move not yet played, or its
## order.
static func _snap_has_plan(snap: Dictionary, uid: int) -> bool:
	if (snap.get("orders", {}) as Dictionary).has(str(uid)):
		return true
	for p in snap.get("planned", []):
		if int(p["unit"]) == uid:
			return true
	return false


## Take a machine's plan back (a tap on it while it is in hand: Ryan, 10 November, "Tapping on
## them when they are selected should cancel the order"). It is the order's own undo, so the
## undo's stack shrinks by the steps that made the plan and never grows by one (his play the
## same day: "The undo grows infinitely when I take back a move"): the steps that gave the plan
## come off the stack wherever they lie in it, and every step taken after them forgets the plan,
## so an UNDO past them never puts it back. False when it has none, or it cannot be taken back
## out of order (can_retake).
func retake(u: Unit) -> bool:
	if not can_retake(u):
		return false
	# The step that began its plan: the newest snapshot that holds none of it. Every one after
	# holds the plan, a later step of its own (an order after its move) or somebody else's.
	var first := history.size() - 1
	while first >= 0 and _snap_has_plan(history[first], u.id):
		first -= 1
	if first < 0 or int((history[first] as Dictionary).get("who", 0)) != u.id:
		# Its plan began outside what the stack holds (it should not): the plan goes, as a step.
		_push(u)
		_retake(u)
		return true
	var before: Dictionary = history[first]
	var back: Dictionary = _retaken(u)["back"]
	var kept: Array = history.slice(0, first)
	for j in range(first + 1, history.size()):
		var snap: Dictionary = history[j]
		if int(snap.get("who", 0)) == u.id:
			continue   # a later step of its own plan: gone with it
		_forget_plan(snap, u, before, back)
		kept.append(snap)
	history = kept
	_retake(u)
	return true


## A later step's snapshot as it would have been had a machine's plan never been given: the
## machine and whoever it carried where they stood, its pieces and its order gone, its move its
## to give, the hexes it walked uncounted.
func _forget_plan(snap: Dictionary, u: Unit, before: Dictionary, back: Dictionary) -> void:
	var units: Dictionary = snap.get("units", {})
	for id in back.keys():
		var at: Vector2i = back[id][0]
		units[str(id)] = [at.x, at.y, int(back[id][1])]
	var walked := 0
	var pieces: Array = []
	for p in snap.get("planned", []):
		if int(p["unit"]) == u.id:
			walked += (p["path"] as Array).size()
		else:
			pieces.append(p)
	snap["planned"] = pieces
	(snap.get("orders", {}) as Dictionary).erase(str(u.id))
	if walked > 0:
		snap["hexes_moved"] = maxi(0, int(snap.get("hexes_moved", 0)) - walked)
		var hexes: Dictionary = snap.get("action_hexes", {})
		var was := int((before.get("action_hexes", {}) as Dictionary).get(str(u.id), 0))
		if was > 0:
			hexes[str(u.id)] = was
		else:
			hexes.erase(str(u.id))
		var used: Dictionary = snap.get("move_used", {})
		var was_used := int((before.get("move_used", {}) as Dictionary).get(str(u.id), 0))
		if was_used > 0:
			used[str(u.id)] = was_used
		else:
			used.erase(str(u.id))
		if not (before.get("moved", []) as Array).has(u.id):
			var who_moved: Array = snap.get("moved", [])
			who_moved.erase(u.id)
			who_moved.erase(float(u.id))   # a snapshot read back from a save holds floats


## Whether a machine has a plan in hand that has not played: waypoints laid, or an order given
## and its move not yet executed. What EXECUTE plays and a cancel takes back.
func pending(u: Unit) -> bool:
	if u == null or state != State.PLAN:
		return false
	if orders.has(u.id) and not played.has(u.id):
		return true
	for p in planned:
		if int(p["unit"]) == u.id:
			return true
	return false


static func _snap_pending(snap: Dictionary, uid: int) -> bool:
	var who_played: Array = snap.get("played", [])
	if (snap.get("orders", {}) as Dictionary).has(str(uid)) and not (who_played.has(uid) or who_played.has(float(uid))):
		return true
	for p in snap.get("planned", []):
		if int(p["unit"]) == uid:
			return true
	return false


## A machine's waypoints, in the order laid: where each of its planned legs ends (Ryan, 22
## November: "Waypoints stay lit"). The last is where its move ends.
func waypoints(u: Unit) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if u == null:
		return out
	for p in planned:
		if int(p["unit"]) == u.id and not (p["path"] as Array).is_empty():
			var last: Array = (p["path"] as Array)[(p["path"] as Array).size() - 1]
			out.append(Vector2i(int(last[0]), int(last[1])))
	return out


## Play one machine's plan now (Ryan, 22 November: "Tapping the most recent waypoint, or tapping a
## pack that was already queued with an attack order, executes that move immediately"): its legs
## come off the plan for the screen to play, one step on the undo (an UNDO puts the machine back
## where it stood with its waypoints and its order as they were). With an order standing its move
## has played and the order stands as given; with none its action is over (take_plan's rule).
## The legs, as plan_pieces gives them; empty when it has nothing to play.
func execute(u: Unit) -> Array:
	if not pending(u):
		return []
	_push(u)
	var mine: Array = []
	var kept: Array = []
	for p in planned:
		if int(p["unit"]) == u.id:
			mine.append(p)
		else:
			kept.append(p)
	planned = kept
	if orders.has(u.id):
		played[u.id] = true
	else:
		_end_action(u.id)
	last_carry = []
	return _pieces(mine)


## Cancel a machine's plan in hand (Ryan, 22 November: "Tapping outside the movement range, or
## tapping the unit itself, cancels ... anything queued to undo by that order is removed"): its
## waypoints and its order go, and so do their steps on the undo. A plan in hand is the newest
## thing on the undo, so its steps come off the top; one laid under somebody else's steps (a save
## from before) comes off as retake takes it. False when it has nothing to cancel.
func cancel(u: Unit) -> bool:
	if not pending(u):
		return false
	var i := history.size() - 1
	while i >= 0 and int((history[i] as Dictionary).get("who", 0)) == u.id and _snap_pending(history[i], u.id):
		i -= 1
	if i >= 0 and int((history[i] as Dictionary).get("who", 0)) == u.id:
		_restore(history[i])
		history.resize(i)
		return true
	return retake(u)


## Take a machine's plan back to its `keep`th waypoint (Ryan, 22 November: "Tapping a previous
## waypoint undoes every [waypoint] past that waypoint"): its steps after that waypoint come off
## the undo, as UNDO would take them. False when they are not the newest steps on the undo.
func back_to_waypoint(u: Unit, keep: int) -> bool:
	while waypoints(u).size() > keep and not history.is_empty() and int((history.back() as Dictionary).get("who", 0)) == u.id:
		_restore(history.pop_back())
	return waypoints(u).size() == keep


## The plan as the map draws it: each piece with hexes, in the order made.
func plan_pieces() -> Array:
	return _pieces(planned)


static func _pieces(from: Array) -> Array:
	var out: Array = []
	for p in from:
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


## The plan, handed to the screen to play (on EXECUTE, ENGAGE or END TURN), and gone from the
## battle. A piece played stays played (Ryan, 2 November: "Movement should be able to be
## executed in sequence if the player wants, and undone"): every snapshot on the undo holds
## pieces of this plan alone, so each forgets them, and an undo after it puts the machine back
## where it stood with nothing planned to play a second time.
##
## A machine's move played ends its action unless an order stands (Ryan, 16 November: "if an
## attack wasn't ordered, it cannot attack"): with one it is played, its order kept as given; with
## none its action is spent as a fight spends it. Every step on the undo taken after its move
## learns the same, so an UNDO of a later step leaves it spent and only an UNDO past its own move
## gives the action back. A machine it carried keeps its action and its move (the carrier's move is
## not its own: "let the swallow carry, then it can drive and fight").
func take_plan() -> Array:
	var out := plan_pieces()
	planned.clear()
	var ids: Array = []
	for p in out:
		if not ids.has(int(p["unit"])):
			ids.append(int(p["unit"]))
	for uid in ids:
		if orders.has(uid):
			played[uid] = true
		else:
			_end_action(uid)
	if ids.is_empty():
		return out
	for snap in history:
		(snap as Dictionary)["planned"] = []
		for uid in ids:
			_played_in(snap, uid)
	return out


## A machine's action over without a fight (its move played with no order standing, or its order
## taken back once its move had played): spent as a fight spends one, its move with it, so a second
## action (the Dingo's) moves again.
func _end_action(uid: int) -> void:
	spent[uid] = int(spent.get(uid, 0)) + 1
	moved.erase(uid)
	move_used.erase(uid)
	played.erase(uid)
	action_hexes.erase(uid)


## A step's snapshot as it stands once a machine's move has played: a step taken after its move
## (the snapshot holds it moved) holds it played if its order stood then, else its action spent; a
## step taken before its move is left as it was, so an UNDO back to it gives the action back.
static func _played_in(snap: Dictionary, uid: int) -> void:
	var who_moved: Array = snap.get("moved", [])
	if not (who_moved.has(uid) or who_moved.has(float(uid))):
		return
	var who_played: Array = snap.get("played", [])
	if (snap.get("orders", {}) as Dictionary).has(str(uid)):
		if not who_played.has(uid):
			who_played.append(uid)
		snap["played"] = who_played
		return
	var spends: Dictionary = snap.get("spent", {})
	spends[str(uid)] = int(spends.get(str(uid), 0)) + 1
	snap["spent"] = spends
	who_moved.erase(uid)
	who_moved.erase(float(uid))   # a snapshot read back from a save holds floats
	who_played.erase(uid)
	who_played.erase(float(uid))
	snap["played"] = who_played
	(snap.get("action_hexes", {}) as Dictionary).erase(str(uid))
	(snap.get("move_used", {}) as Dictionary).erase(str(uid))


## One step of drawing a route by hand: `draft` is the route so far (hexes after the
## machine's own), `h` the hex the finger has reached. Back on the machine clears; a hex
## already on the draft cuts it back to there, unless it is a unit's the machine only passes;
## anything else is joined by the cheapest continuation that fits the move (a finger that
## skips a hex still draws a walkable route, and one over a unit waits there until it moves
## on), or the draft stands when nothing fits.
func draft_step(u: Unit, draft: Array, h: Vector2i) -> Array:
	if h == u.pos:
		return []
	var at := draft.find(h)
	if at >= 0:
		_lift(u)
		var stops := field.can_stand(u, h)
		_set_down()
		return draft.slice(0, at + 1) if stops else draft
	var end: Vector2i = draft[draft.size() - 1] if not draft.is_empty() else u.pos
	_lift(u)
	var spent_move := field.route_cost(u, draft, move_left(u))
	var ext: Array[Vector2i] = []
	if spent_move >= 0:
		ext = field.route_from(u, end, move_left(u) - spent_move, h)
	_set_down()
	if spent_move < 0 or ext.is_empty():
		return draft
	var out: Array = draft.duplicate()
	out.append_array(ext)
	return out


## The machines that can still do something on the map this turn: an action left, not ordered
## onto a fight, not caught (its fight comes first), and a move to give or a pack in reach where
## it stands. END TURN asks first while any is left (Ryan, 2 November: "If end turn is hit and
## there are movements/actions remaining, it should alert the player").
func still_to_act() -> Array[Unit]:
	var out: Array[Unit] = []
	if state != State.PLAN:
		return out
	for m in mechs():
		if m.is_static() or not m.alive() or actions_left(m) <= 0 or orders.has(m.id) or played.has(m.id) or is_pinned(m):
			continue
		if can_move(m):
			out.append(m)
			continue
		for p in field.packs():
			if can_target(p) and in_range_from(m, m.pos, p):
				out.append(m)
				break
	return out


## Whether nothing is left for the player to do on the map this turn but press the button
## (Ryan, 25 October: END TURN pulses "when all units are out of actions"): every machine has
## fought its actions out, is ordered onto a fight, is caught (its fight comes first), or can
## neither move nor reach a pack where it stands.
func nothing_left() -> bool:
	return state == State.PLAN and still_to_act().is_empty()


## Whether the next fight ENGAGE opens holds the boss: every machine goes in, nothing moves first
## (Ryan, 25 October: "no reason to move any units once engage is clicked, just go right into
## the boss animation").
func next_fight_is_boss() -> bool:
	var f := next_fight()
	if f.is_empty() or f["target"] == null:
		return false
	return bool(roster(f["target"]).get("all_in", false))


## The fight the player would open at `target`, or the next fight a hunter forced, which comes
## first whatever is tapped (bible section 5): {"targets": the pack attacked, or the hunter that
## caught a machine, "joins": always empty (one pack is one fight, the long wall brief 3.4),
## "in_range": the machines whose attack range covers a target, "eligible": those of them with an
## action left (a caught machine always), "pinned": the caught machine or null, "forced":
## whether this is a forced fight}. Empty when there is none.
func roster(target: Unit = null) -> Dictionary:
	if state != State.PLAN:
		return {}
	var targets: Array = []
	var pinned: Unit = null
	if not forced.is_empty():
		targets = (forced[0]["hunters"] as Array).duplicate()
		pinned = forced[0]["prey"]
	elif target != null and target.is_enemy() and field.units.has(target) and not target.sealed:
		targets = [target]   # a sealed boss cannot be fought (30 October)
	else:
		return {}
	var r := field.attack_roster(targets)
	var eligible: Array[Unit] = []
	if pinned != null:
		eligible.append(pinned)
	# The boss's fight takes every machine (Ryan, 25 October: "automatically make all units
	# attacking when one unit targets it, regardless of their range", "doesn't matter if a
	# unit has fought this turn already"), since its fight cannot be left; nothing joins it and
	# it joins nothing (the long wall brief 3.4), so it is the boss's fight when the boss is the
	# target.
	var all_in := boss != null and targets.has(boss)
	for m in (mechs() if all_in else r["in_range"]):
		if m != pinned and not m.is_static() and (all_in or actions_left(m) > 0):
			eligible.append(m)
	r["eligible"] = eligible
	# The fight's threat rating, the machines it is intended for: its pack's (the long wall brief
	# 3.7).
	var squad := 0
	for t in targets:
		squad = maxi(squad, (t as Unit).squad)
	r["squad"] = squad
	r["pinned"] = pinned
	r["forced"] = pinned != null
	r["all_in"] = all_in
	return r


## Open a fight: the machines committed (those of `machines` the roster allows; a caught
## machine always) against the target, one pack (the one ordered onto, or a catch's hunter),
## nothing joining (the long wall brief 3.4). The skirmish, or null when refused (not the player's turn, no fight
## there, nobody to commit).
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
	if target == null or not target.is_enemy() or not field.units.has(target) or target.sealed:
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
	if played.has(m.id):
		return false   # once its move has played its order stands as given
	_push(m)
	orders[m.id] = target
	return true


## Take an order back; once the machine's move has played that ends its action (take_plan).
func cancel_order(m: Unit) -> void:
	if m != null and orders.has(m.id):
		_push(m)
		orders.erase(m.id)
		if played.has(m.id):
			_end_action(m.id)


## A tap or a drag onto a pack (bible section 5), as one step and one undo: along a drawn route
## first if one was drawn, then the order from its end if the pack is in range there; with no
## route, from the farthest hex in range its move left reaches from its latest waypoint, or where
## it stands. An order onto another pack replaces the one standing. What happened: "ordered",
## "moved" (the route ended out of range: it moved, and no order), "refused" (not
## a pack that may be fought now, or no action left), "out_of_reach", "no_room" (a carrier's
## block does not fit where the route ends) or "blocked" (the route cannot be walked).
func order_onto(m: Unit, target: Unit, draft: Array = []) -> String:
	if m == null or state != State.PLAN:
		return "refused"
	if draft.is_empty() and order_of(m) == target:
		return "ordered"
	if not can_target(target) or actions_left(m) <= 0 or played.has(m.id):
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


## Every fight waiting, in the order ENGAGE opens them (the long wall brief 7.4: the queue the
## button counts and the map numbers): each hunter's catch first, then each pack in the order its
## first order was given, the machines ordered onto a catch's hunters counted in the catch. Each
## {"target": the pack, null for a catch, "prey": the caught machine for a catch}.
func fights_waiting() -> Array:
	_prune_orders()
	var out: Array = []
	var in_catch := {}
	for f in forced:
		out.append({"target": null, "prey": f["prey"]})
		for h in f["hunters"]:
			in_catch[h] = true
	var seen := {}
	for uid in orders.keys():
		var p: Unit = orders[uid]
		if p == null or in_catch.has(p) or seen.has(p):
			continue
		seen[p] = true
		out.append({"target": p, "prey": null})
	return out


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
			if m != null and played.has(m.id):
				_end_action(m.id)


## End the player's turn (bible section 4): the enemy's turn plays (packs walk round the
## machines, a pack on the apron strikes the gate), the rift ticks once, and the next turn opens
## with the fights hunters have forced. Nothing returns on the map (the long wall brief 3.6: the
## shield is full as every fight opens), so a turn out of a fight fires nothing. The walks played (pack id -> Battlefield.Walk); empty when refused
## (not the player's turn, or a forced fight still to come).
func end_turn() -> Dictionary:
	if state != State.PLAN or not forced.is_empty():
		return {}
	claim_caches()
	var walks := field.enemy_turn()
	field.phase += 1
	last_spawned = field.tick_pressure(1)
	_new_turn()
	return walks


## The caches the machines stand on as the player's turn ends, or as the battle is won mid-turn
## (the boss's fall), are theirs (the bible's loot row: claimed by ending a move on one): taken off
## the field and opened, what each held in the log. Claimed as the turn ends rather than as the
## move does, so an undo never shows what a cache holds. The ones claimed now, in the order claimed.
func claim_caches() -> Array:
	var got: Array = []
	for m in field.mechs():
		for o in m.footprint:
			var c := field.cache_at(m.pos + o)
			if c.is_empty():
				continue
			var opened := open_cache(c)
			opened["by"] = m.id
			if not str(opened["blueprint"]).is_empty():
				blueprints_known.append(str(opened["blueprint"]))   # a second Relic finds another
			loot.append(opened)
			got.append(opened)
			field.caches.erase(c)
			field.log.append("%s claims a %s: %s" % [m.display_name, str(db.loot.get(str(opened["kind"]), {}).get("name", opened["kind"])), loot_text(opened)])
	return got


## What a cache holds, drawn as it is opened from a stream of its own (the battle's seed, the
## cache and the kind it stands as), so the same cache claimed as the same kind holds the same
## whenever it is claimed: its kind's salvage, so many components of the battle's tier, and on
## its kind's chance a blueprint of that tier the run holds none of (none when it holds all).
func open_cache(c: Dictionary) -> Dictionary:
	var t := int(c.get("tier", 1))
	var kind := db.loot_kind_of_tier(t)
	var e: Dictionary = db.loot.get(kind, {})
	var rng := RandomNumberGenerator.new()
	rng.seed = absi(hash([seed_value, "cache", int(c.get("id", 0)), t]))
	var sv: Array = e.get("salvage", [0, 0])
	var out := {"kind": kind, "tier": t, "salvage": rng.randi_range(int(sv[0]), int(sv[1])), "components": [], "blueprint": ""}
	var pool := db.loot_pool(tier + 1)
	for i in range(int(e.get("components", 0))):
		if pool.is_empty():
			break
		(out["components"] as Array).append(str(pool[rng.randi_range(0, pool.size() - 1)]))
	if rng.randf() < float(e.get("blueprint", 0.0)):
		var open: Array = pool.filter(func(cid) -> bool: return not blueprints_known.has(cid))
		if not open.is_empty():
			out["blueprint"] = str(open[rng.randi_range(0, open.size() - 1)])
	return out


## A claimed cache's contents in words, for the log.
func loot_text(opened: Dictionary) -> String:
	var parts: Array = ["%d salvage" % int(opened.get("salvage", 0))]
	for cid in opened.get("components", []):
		parts.append(db.component_name(str(cid)))
	if not str(opened.get("blueprint", "")).is_empty():
		parts.append("a blueprint for the %s" % db.component_name(str(opened["blueprint"])))
	return ", ".join(parts)


## The hunters that turned on a machine since the last call ([hunter, prey] units, those still on
## the field), cleared: the screen declares each after the walk plays (Ryan, 8 November).
func take_locks() -> Array:
	var out: Array = []
	for pair in field.locks:
		var h := field.unit_by_id(int(pair[0]))
		var p := field.unit_by_id(int(pair[1]))
		if h != null and p != null:
			out.append([h, p])
	field.locks.clear()
	return out


## A fresh turn: every machine's actions and move whole, and the fights hunters forced.
func _new_turn() -> void:
	spent.clear()
	moved.clear()
	move_used.clear()
	played.clear()
	action_hexes.clear()
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


## A fight's seed from what the fight is, never from how many fights opened before it (Ryan, 7
## November: "If the dice order affects reproduction, then we should fix that"): the battle's
## seed, the turn, its packs and its machines, so the same fight rolls the same dice whichever
## order the turn's fights are opened in, and a saved battle replays it. No two fights of a turn
## share packs and machines (a machine that fought is spent), so none share a seed.
func fight_seed(group: Array) -> int:
	var packs_in: Array = []
	var mechs_in: Array = []
	for u in group:
		if (u as Unit).is_enemy():
			packs_in.append(u.id)
		elif (u as Unit).is_player():
			mechs_in.append(u.id)
	packs_in.sort()
	mechs_in.sort()
	return absi(hash([seed_value, field.phase, packs_in, mechs_in]))


func _build_skirmish(group: Array) -> Skirmish:
	var sk := Skirmish.new(fight_seed(group), columns)
	sk.terrain = ground_terrain(group)
	sk.ground = map.ground_id(ground_hex(group))
	sk.foe_factory = foe_factory()   # a summoning action calls up content
	# A dealt layout places its pack (the long wall brief, section 6): a fight holds one pack, a
	# catch's included.
	var enemies := group.filter(func(x: Unit) -> bool: return x.is_enemy() and field.units.has(x))
	if enemies.size() == 1 and not (enemies[0] as Unit).layout.is_empty():
		sk.layout = (enemies[0] as Unit).layout.duplicate()
	for u in group:
		if not field.units.has(u):
			continue
		if u.is_player() and not u.is_static():
			# The shield is the fight's (the long wall brief 3.6): full as every fight opens, as
			# the heat opens at zero; hull is the battle's.
			u.shield = u.shield_max
			sk.add_mech(u)
		elif u.is_enemy():
			sk.add_foes(db.foes_for(u), u)
	if sk.mechs.is_empty() or sk.reinforcements.is_empty():
		return null
	return sk


## Apply the finished skirmish: a wrecked machine lies where it fell (Battlefield.wrecks, which
## the campaign reads its die from), packs shrink or vanish. Rift Pressure ticks on the map's
## enemy turns only, never per round fought (Ryan, 13 October). Every machine in it is spent,
## however the fight ended (bible section 4); a forced fight comes off the list. Shields do not
## refill here.
func finish_skirmish() -> void:
	if current == null:
		return
	for ms in current.mechs:
		spent[ms.unit.id] = int(spent.get(ms.unit.id, 0)) + 1
		moved.erase(ms.unit.id)
		move_used.erase(ms.unit.id)
		played.erase(ms.unit.id)
		action_hexes.erase(ms.unit.id)
	var tallied: Array[Unit] = []
	for sq in current.packs:
		var by_type := current.kills_by_type(sq)
		for cid in by_type.keys():
			foes_killed += int(by_type[cid])
		tallied.append(sq)
	for k in current.sponsorship.keys():
		sponsorship[k] = int(sponsorship.get(k, 0)) + int(current.sponsorship[k])
	field.apply_skirmish_result(current)
	# Menace: a pack is worth its threat rating (ContentDB.worth_of), and a pack a fight has
	# worn has paid the share of it its strike at the wall has lost (Battlefield.strike_of: the
	# heads gone of the heads it took the field with). Its fall makes it whole, and nothing
	# pays past it or twice, so a head raised, split off or grown back adds none.
	for sq in tallied:
		var worth := ContentDB.worth_of(sq.squad)
		var owed := worth
		var stands := field.units.has(sq)
		if stands:
			var full := maxi(1, sq.full_strength)
			owed = (worth * clampi(full - Battlefield.heads(sq), 0, full)) / full
		var paid := int(pack_paid.get(sq.id, 0))
		var pay := maxi(0, owed - paid)
		if not stands:
			pack_paid.erase(sq.id)
			if pack_bonus_trial > 0 and not sq.is_boss:
				meter_bonus += pack_bonus_trial   # the pack bonus's trial: a pack's fall, once
		elif pay > 0:
			pack_paid[sq.id] = paid + pay
		menace_killed += pay
	current = null
	boss_fight = false
	state = State.PLAN
	if not forced.is_empty():
		forced.pop_front()
	_prune_forced()
	_fractures()
	_prune_orders()
	_check_outcome()


func _check_outcome() -> bool:
	if field.gate_hp <= 0:
		outcome = Outcome.GATE_FALLEN
	elif field.mechs().is_empty():
		outcome = Outcome.WRECKED
	elif boss != null and not field.units.has(boss):
		claim_caches()   # the last turn's fetch is banked with the win
		outcome = Outcome.VICTORY
	if outcome != Outcome.NONE:
		for u in field.mechs():
			Effects.end_battle(u)
		state = State.DONE
		return true
	return false
