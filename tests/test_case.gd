class_name TestCase
extends RefCounted

## Minimal assertion base for headless tests. run_tests.gd drives it.

var failures: Array[String] = []
var checks: int = 0


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
