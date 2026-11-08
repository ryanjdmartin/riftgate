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
var fought: Dictionary = {}      # mech id -> true: it fought this turn (out_of_combat fires for the rest)
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
## The menace of every foe killed this battle (ContentDB.menace, the one weight for the Rupture
## meter, Anathema and salvage, 30 October), tallied as each fight ends like the kills.
var menace_killed: int = 0
## The Rupture meter (the pacing session, 30 October; the bible's pacing row): the tally above
## against the Fractures' thresholds, set at setup from the field's menace at the start (the
## packs placed, the boss unit aside) as fractions of it, the last at RUPTURE_SHARE and the
## steps growing (later Fractures cost more), so they follow the tier's numbers and the ramp's
## count without a table of their own, and the Rupture is earnable from the field alone with a
## third of it left to leave and pay for at the gate. A Fracture pays out as a fight ends: the
## log names it, and at the Fractures the tier names the next elite composition of the lead's
## domain not yet fought this battle spawns at the rift. The last Fracture is the Rupture: the
## boss's seal breaks. The stall guard breaks it too, when no pack but the boss's stands as a
## fight ends, so a team that cleared the field never waits on the clock. Rift Pressure keeps
## running after. The prize a Fracture may bring is not built (decided after the meter is
## played).
const RUPTURE_SHARE := 0.67
const FRACTURE_STEPS := [1.0, 1.5, 2.0, 2.5, 3.0]
var thresholds: Array = []        # the menace each Fracture is earned at, the tier's count of them
var fractures: int = 0            # Fractures earned so far
var rupture_turn: int = -1        # the phase the seal broke at; -1 while it holds (or with no seal)
var stall_guard: bool = false     # the Rupture came by the guard, not the tally
var elites_spawned: Array = []    # the elite compositions spawned this battle, by id
var field_menace: int = 0         # the field's menace at the start, the thresholds' base
## The battle's share of the run's Sponsorship measures (the bible's Sponsorship row): the
## hexes its machines move on the map, and each fight's own (Skirmish.sponsorship), added up.
var sponsorship := {"hexes_moved": 0, "guarded": 0, "damaging_spends": 0, "quiet_spends": 0}   # ContentDB.SPONSORSHIP_MEASURES
var action_hexes: Dictionary = {}   # mech id -> hexes moved in its current action, taken back with an undo
## The machines wrecked this battle, as they fell: the map lets go of them, the campaign
## still reads their dice (a wreck loses its destroyed components).
var wrecks: Array[Unit] = []
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
	var placed: Array = []   # [composition, hex, opening]: opening 0 places it on the hex, 1 a move from the apron, 2 two moves
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
			placed.append([comps[j], Hex.offset_to_axial((w_cols * (j + 1)) / (comps.size() + 1), 3 + (j % 3)), 0])
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
		# The opening (the long wall brief 3.2): the ramp's formations across the width as before,
		# each a move of its own from the apron, so its first walk reaches the wall; the ramp's
		# patrols on the flanks, two moves out. The rows are set once each pack is dressed and
		# its pace known (_open_rows, below).
		if not forms.is_empty():
			for k in range(nf):
				placed.append([forms[k % forms.size()], Hex.offset_to_axial((w_cols * (k + 1)) / (nf + 1), BattleMap.MOUTH_ROWS), 1])
		if not patrols.is_empty():
			for k in range(np):
				placed.append([patrols[k % patrols.size()], Hex.offset_to_axial(0 if k % 2 == 0 else w_cols - 1, BattleMap.MOUTH_ROWS), 2])
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
	for j in range(placed.size()):
		var p: Array = placed[j]
		var sq := field.emerge(p[0], p[1])
		if sq != null and int(p[2]) > 0:
			_open_row(sq, Hex.axial_to_offset(p[1]).x, int(p[2]))
	var fac: Dictionary = db.factions.get(faction, {})
	var firsts := db.bosses_of(faction)
	var boss_id := str(lineup[0]) if not lineup.is_empty() else (firsts[0] if not firsts.is_empty() else "")
	if with_boss and db.foes.has(boss_id):
		boss = make_boss_unit(db, faction, tier, boss_id, lineup, escort, ramp)
		boss.pos = field.nearest_standable(boss, Hex.offset_to_axial(w / 2 - 1, 1))
		field.add_unit(field.dress_pack(boss, boss_id))
	# The caches, on the field from the first turn (Ryan, 7 November), round the units placed.
	field.seed_caches(db, seed_value)
	# The Rupture meter: the thresholds from the field's menace at the start, and the seal on the
	# boss while there is a field to earn it against.
	# The compositions placed and the tide's first waves (the long wall brief 3.8: the field is
	# thin at the start, so the thresholds read the first compositions the rift will send as well,
	# as many as the tier's Fractures, in the cycle's order), each as content writes it, so a
	# layout's draw moves no threshold. Placeholder.
	field_menace = 0
	for p in placed:
		for m in (p[0] as Dictionary).get("members", []):
			field_menace += db.menace(str(m[0])) * int(m[1])
	if not field.cycle.is_empty():
		for k in range(Ramp.fractures_at(tier)):
			for m in field.cycle[k % field.cycle.size()].get("members", []):
				field_menace += db.menace(str(m[0])) * int(m[1])
	thresholds = []
	var n := Ramp.fractures_at(tier)
	if field_menace > 0 and n > 0:
		var steps: Array = []
		var total := 0.0
		for k in range(n):
			total += float(FRACTURE_STEPS[mini(k, FRACTURE_STEPS.size() - 1)])
			steps.append(total)
		for k in range(n):
			thresholds.append(maxi(1, roundi(RUPTURE_SHARE * float(field_menace) * float(steps[k]) / total)))
	if boss != null and not thresholds.is_empty():
		boss.sealed = true
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


## The opening's row for a pack placed at the start (the long wall brief 3.2): `moves` of its own
## pace short of the apron row (a formation one, a patrol two), never into the rift's mouth, at
## its column; it lands there as any spawn lands (Battlefield.landing: the nearest hex it can
## stand on with no machine beside it). A pack that hunts opens a row further back at a time
## until it has caught nobody, so no battle opens on a forced fight (Ryan, 6 November: "I
## probably would shy away from hitting the first battle with a fight in the first turn, that's
## for sure. That's just mean"); its first walk is the enemy's first turn, after the player's.
## No hunter's ring passes 3 and the machines open four rows or more below the mouth, so the
## mouth's edge always clears.
func _open_row(sq: Unit, col: int, moves: int) -> void:
	var row := maxi(BattleMap.MOUTH_ROWS, field.apron_row() - moves * sq.movespeed)   # placeholder (the long wall brief)
	sq.pos = field.landing(sq, Hex.offset_to_axial(col, row))
	while sq.behaviour == "hunt" and row > BattleMap.MOUTH_ROWS and field.catch_of(sq) != null:
		row -= 1
		sq.pos = field.landing(sq, Hex.offset_to_axial(col, row))


## Whether the boss's seal holds: it cannot be ordered onto and joins no fight until the Rupture.
func is_sealed() -> bool:
	return boss != null and boss.sealed


## The Rupture: the seal breaks, by the last Fracture or by the stall guard. Engaging the boss
## is the battle's last decision from here (the bible's boss row).
func rupture(by_guard: bool = false) -> void:
	if boss == null or not boss.sealed:
		return
	boss.sealed = false
	rupture_turn = field.phase
	stall_guard = by_guard
	field.log.append("THE RUPTURE: the seal breaks" + (" with the field clear" if by_guard else ""))
	# The tide quickens (the long wall brief 3.8; Ryan, 6 November, of a re-seal: "Isn't that just
	# a feel-bad, or a non-choice?"): nothing re-seals, and the beat halves once, so each turn of
	# delay costs more at the wall and the sally is the release; a peak's own step still applies.
	field.rift_pressure_max = maxi(1, field.rift_pressure_max / 2)   # placeholder (the long wall brief)
	field.log.append("the rift convulses: the beat is now %d" % field.rift_pressure_max)


## The Fractures earned by the tally so far, each paying out in turn: the log names it, the
## elite the tier names at it spawns at the rift, and the last breaks the seal; then the stall
## guard. Read as a fight ends, after the map has taken its result.
func _fractures() -> void:
	while fractures < thresholds.size() and menace_killed >= int(thresholds[fractures]):
		fractures += 1
		field.log.append("FRACTURE %d of %d" % [fractures, thresholds.size()])
		if Ramp.elite_fractures_at(tier).has(fractures):
			_spawn_elite()
		if fractures == thresholds.size():
			rupture(false)
	if is_sealed() and field.packs().filter(func(p: Unit) -> bool: return not p.is_boss).is_empty():
		rupture(true)


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


## The plan, handed to the screen to play (on EXECUTE, ENGAGE or END TURN), and gone from the
## battle. A piece played stays played (Ryan, 2 November: "Movement should be able to be
## executed in sequence if the player wants, and undone"): every snapshot on the undo holds
## pieces of this plan alone, so each forgets them, and an undo after it puts the machine back
## where it stood with nothing planned to play a second time.
func take_plan() -> Array:
	var out := plan_pieces()
	planned.clear()
	for snap in history:
		(snap as Dictionary)["planned"] = []
	return out


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


## The machines that can still do something on the map this turn: an action left, not ordered
## onto a fight, not caught (its fight comes first), and a move to give or a pack in reach where
## it stands. END TURN asks first while any is left (Ryan, 2 November: "If end turn is hit and
## there are movements/actions remaining, it should alert the player").
func still_to_act() -> Array[Unit]:
	var out: Array[Unit] = []
	if state != State.PLAN:
		return out
	for m in mechs():
		if m.is_static() or not m.alive() or actions_left(m) <= 0 or orders.has(m.id) or is_pinned(m):
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


## End the player's turn (bible section 4): the enemy's turn plays (packs walk round the
## machines, a pack on the apron strikes the gate), out_of_combat fires for a machine that did not
## fight this turn (nothing returns on the map since the long wall brief 3.6: the shield is full
## as every fight opens), the rift ticks once, and the next turn opens with the fights hunters
## have forced. The walks played (pack id -> Battlefield.Walk); empty when refused
## (not the player's turn, or a forced fight still to come).
func end_turn() -> Dictionary:
	if state != State.PLAN or not forced.is_empty():
		return {}
	claim_caches()
	var walks := field.enemy_turn()
	for u in field.mechs():
		if not fought.has(u.id):
			Effects.fire(u, "out_of_combat")   # a trigger nothing may ride since the long wall brief 3.6
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
		var by_type := current.kills_by_type(sq)
		for cid in by_type.keys():
			foes_killed += int(by_type[cid])
			menace_killed += db.menace(str(cid)) * int(by_type[cid])
	for k in current.sponsorship.keys():
		sponsorship[k] = int(sponsorship.get(k, 0)) + int(current.sponsorship[k])
	field.apply_skirmish_result(current)
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
