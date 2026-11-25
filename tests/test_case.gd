class_name TestCase
extends RefCounted

## Minimal assertion base for headless tests. run_tests.gd drives it.

var failures: Array[String] = []
var checks: int = 0
## How many script errors the test means to raise. The runner fails a test for every script error
## the engine logs while it runs (a crash aborts its function and the caller plays on, so a
## crashed test read as passed); a test of that check itself says how many it raises, and fails on
## any other count. The runner clears it before each test.
var script_errors_expected: int = 0


func assert_true(cond: bool, msg: String) -> void:
	checks += 1
	if not cond:
		failures.append(msg)


func assert_false(cond: bool, msg: String) -> void:
	assert_true(not cond, msg)


func assert_eq(actual, expected, msg: String) -> void:
	checks += 1
	if actual != expected:
		failures.append("%s (expected %s, got %s)" % [msg, str(expected), str(actual)])


func assert_ne(actual, unexpected, msg: String) -> void:
	checks += 1
	if actual == unexpected:
		failures.append("%s (got %s)" % [msg, str(actual)])


## Whether a screen carries a HudButton reading `text` (the withdraw button is gone: the long
## wall brief 7.5).
func has_button(screen: Node, text: String) -> bool:
	for b in screen.find_children("*", "HudButton", true, false):
		if (b as HudButton).text == text:
			return true
	return false


# ---------------------------------------------------------------- a battle's quiet start

## The field a battle test reads its own rule on, apart from the opening (the rules' Setup: packs
## before every band of the wall, each two or more of its own moves out, the rift a turn short
## of its peak): every pack but the boss parked in the north, across the width on rows 3 to 5 in
## the order the opening stood them, whatever each is rated and however many they are, the rift's
## clock held so nothing spawns over a test's turns, and the forced fights read again from where
## the packs now stand. The opening's own tests read a raw setup.
func quiet_start(b: Battle) -> void:
	var parked: Array = b.field.packs().filter(func(sq: Unit) -> bool: return not sq.is_boss)
	var w := b.map.width
	for k in range(parked.size()):
		var sq: Unit = parked[k]
		sq.pos = b.field.landing(sq, Hex.offset_to_axial((w * (k + 1)) / (parked.size() + 1), 3 + (k % 3)))
	b.field.rift_pressure = 0
	b.field.rift_pressure_max = 99
	b.forced = b.field.forced_fights()


# ---------------------------------------------------------------- the tide's lists

## Every composition a field's tide holds: its lists by rating, the lightest rating first, each
## in the order dealt, then its hunting packs.
func tide_lists(f: Battlefield) -> Array:
	var out: Array = []
	var ratings: Array = f.graded.keys()
	ratings.sort()
	for r in ratings:
		out.append_array(f.graded[r])
	out.append_array(f.hunters)
	return out


## A domain's pushing packs at a tier (1 to 3) and a Convergence as the tide lists them, a rating
## to their ids in content's order, worked out apart from the battle's own lookup: the packs
## written for the tide's bands (`tide`: graded) where the domain has any, else its patrols and
## formations, each by its threat rating and none that hunts.
func tide_packs(db: ContentDB, fid: String, tier: int, ramp: int) -> Dictionary:
	var found: Array = db.compositions(fid, tier, "patrol", ramp, ContentDB.GRADED) + db.compositions(fid, tier, "formation", ramp, ContentDB.GRADED)
	if found.is_empty():
		found = db.compositions(fid, tier, "patrol", ramp) + db.compositions(fid, tier, "formation", ramp)
	var out := {}
	for c in found:
		if not str(c.get("hunts", "")).is_empty():
			continue
		var r := clampi(ContentDB.squad_of(c), 1, 3)
		if not out.has(r):
			out[r] = []
		(out[r] as Array).append(str(c["id"]))
	return out


## Two lists in turn, the first's first, the leftovers of the longer after: how a guest's packs
## stand among the lead's.
func in_turn(a: Array, b: Array) -> Array:
	var out: Array = []
	for k in range(maxi(a.size(), b.size())):
		if k < a.size():
			out.append(a[k])
		if k < b.size():
			out.append(b[k])
	return out


## Where a battle's opening departs from its tide's lists taken in turn, "" where it does not:
## the packs of each rating on the field at the start (the boss aside), in the order stood, are
## that rating's list from where its seed started it, each under its composition's faction. Read
## on a battle as it opens, before the tide has sent anything.
func opening_off_lists(b: Battle) -> String:
	var opened: Array = b.field.packs().filter(func(u: Unit) -> bool: return not u.is_boss)
	var counted := 0
	for r in b.field.graded.keys():
		var list: Array = b.field.graded[r]
		var stood: Array = opened.filter(func(u: Unit) -> bool: return u.squad == int(r))
		counted += stood.size()
		var from := int(b.field._graded_at.get(r, 0)) - stood.size()   # where the seed started this list
		if from < 0 or from >= list.size():
			return "the list for %d started outside itself (%d of %d)" % [int(r), from, list.size()]
		for k in range(stood.size()):
			var c: Dictionary = list[(from + k) % list.size()]
			var sq: Unit = stood[k]
			if sq.composition != str(c["id"]) or sq.faction != str(c["faction"]):
				return "pack %d for %d is %s of %s, where its list's next is %s of %s" % [k, int(r), sq.composition, sq.faction, str(c["id"]), str(c["faction"])]
	if counted != opened.size():
		return "%d of the %d packs stood are of no list's rating" % [opened.size() - counted, opened.size()]
	return ""


# ---------------------------------------------------------------- a fight's end

## A fight ended by the foes' fall, the way a fight is won (no fight is left since the long
## wall brief 3.5): every foe waiting cleared, every foe on the field felled, the round ended,
## again while a split or a rising foe leaves something standing.
func win_fight(sk: Skirmish) -> void:
	if sk.state == Skirmish.State.SETUP:
		sk.begin()
	for i in range(8):
		if sk.outcome != Skirmish.Outcome.NONE:
			return
		if sk.state == Skirmish.State.ROUND_START:
			sk.start_round()
		sk.reinforcements.clear()
		for f in sk.field_foes():
			f.hp = 0
		sk.end_round()


## A fight ended by the team's fall: every machine wrecked as the player's turn ends, so the
## packs in it keep their survivors.
func lose_fight(sk: Skirmish) -> void:
	if sk.state == Skirmish.State.SETUP:
		sk.begin()
	if sk.state == Skirmish.State.ROUND_START:
		sk.start_round()
	for ms in sk.mechs:
		ms.unit.hull = 0
	sk.end_round()


# ---------------------------------------------------------------- live input (live_test_*)

## The layout a frame would give, here and now: every control's minimum size read again (a
## wrapped label measured before it had a width keeps a height a word a line until then) and
## every container sorted, three times over so the widths and the wrapped heights settle.
func _lay_out(vp: Viewport) -> void:
	for i in range(3):
		_remeasure(vp)
		vp.propagate_notification(Container.NOTIFICATION_SORT_CHILDREN)


func _remeasure(n: Node) -> void:
	for c in n.get_children():
		_remeasure(c)
	if n is Control:
		(n as Control).update_minimum_size()


## A finger touching or lifting as Android delivers it: the mouse event Godot emulates from the
## finger first (DEVICE_ID_EMULATION, which buttons and scrollers ignore), then the touch.
func _finger(vp: Viewport, at: Vector2, down: bool) -> void:
	var mb := InputEventMouseButton.new()
	mb.device = InputEvent.DEVICE_ID_EMULATION
	mb.button_index = MOUSE_BUTTON_LEFT
	mb.pressed = down
	mb.position = at
	mb.global_position = at
	mb.button_mask = MOUSE_BUTTON_MASK_LEFT if down else 0
	vp.push_input(mb)
	var st := InputEventScreenTouch.new()
	st.index = 0
	st.pressed = down
	st.position = at
	vp.push_input(st)


## A finger down at `from`, slid `by` in `steps`, and lifted, its motion as Android delivers it.
func _drag(vp: Viewport, from: Vector2, by: Vector2, steps: int = 10) -> void:
	_finger(vp, from, true)
	var at := from
	for k in range(steps):
		at += by / steps
		var mm := InputEventMouseMotion.new()
		mm.device = InputEvent.DEVICE_ID_EMULATION
		mm.position = at
		mm.global_position = at
		mm.relative = by / steps
		mm.button_mask = MOUSE_BUTTON_MASK_LEFT
		vp.push_input(mm)
		var sd := InputEventScreenDrag.new()
		sd.index = 0
		sd.position = at
		sd.relative = by / steps
		vp.push_input(sd)
	_finger(vp, at, false)
