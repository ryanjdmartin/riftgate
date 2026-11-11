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


# ---------------------------------------------------------------- a battle's quiet start

## The field a battle test reads its own rule on, apart from the opening (the long wall brief
## 3.2: the formations a move from the wall, the patrols two, the rift a turn short of its peak):
## every pack but the boss parked in the north where the start placed it before the brief (the
## formations across the width on rows 3 to 5, the patrols on the flanks from row 5), the rift's
## clock held so nothing spawns over a test's turns, and a catch the opening forced taken back.
## The opening's own tests read a raw setup.
## Whether a screen carries a HudButton reading `text` (the withdraw button is gone: the long
## wall brief 7.5).
func has_button(screen: Node, text: String) -> bool:
	for b in screen.find_children("*", "HudButton", true, false):
		if (b as HudButton).text == text:
			return true
	return false


func quiet_start(b: Battle) -> void:
	var forms: Array = []
	var patrols: Array = []
	for sq in b.field.packs():
		if sq.is_boss:
			continue
		if sq.composition_size == "patrol":
			patrols.append(sq)
		else:
			forms.append(sq)
	var w := b.map.width
	for k in range(forms.size()):
		forms[k].pos = b.field.landing(forms[k], Hex.offset_to_axial((w * (k + 1)) / (forms.size() + 1), 3 + (k % 3)))
	for k in range(patrols.size()):
		patrols[k].pos = b.field.landing(patrols[k], Hex.offset_to_axial(0 if k % 2 == 0 else w - 1, 5 + k / 2))
	b.field.rift_pressure = 0
	b.field.rift_pressure_max = 99
	b.forced = b.field.forced_fights()


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
