extends SceneTree

## Headless test runner.
##   godot --headless --path . -s tests/run_tests.gd
## Discovers tests/test_*.gd, instantiates each, and calls every method named test_* as the
## runner starts. A method named live_test_* runs on the first frame instead, once the scene
## tree is up (its root is not in the tree while the runner starts): a test that needs input
## routed as the engine routes it (a touch dragged over a scrolled list) adds its screen to the
## tree and pushes the events through a viewport.

var _total_checks := 0
var _total_failures := 0
var _total_tests := 0
var _live: Array = []   # [file, instance, method]: the live tests, for the first frame


func _init() -> void:
	var dir := DirAccess.open("res://tests")
	if dir == null:
		push_error("tests/ directory not found")
		quit(2)
		return
	var files: Array[String] = []
	for f in dir.get_files():
		if f.begins_with("test_") and f.ends_with(".gd") and f != "test_case.gd":
			files.append(f)
	files.sort()

	for f in files:
		var script: GDScript = load("res://tests/" + f)
		if script == null or not script.can_instantiate():
			print("  LOAD  %s failed to compile" % f)
			_total_failures += 1
			continue
		var inst = script.new()
		for m in inst.get_method_list():
			var method: String = m.name
			if method.begins_with("live_test_"):
				_live.append([f, inst, method])
			elif method.begins_with("test_"):
				_run(f, inst, method)
	if _live.is_empty():
		_finish()
	else:
		process_frame.connect(_run_live, CONNECT_ONE_SHOT)


func _run_live() -> void:
	for t in _live:
		_run(t[0], t[1], t[2])
	_finish()


func _run(f: String, inst, method: String) -> void:
	_total_tests += 1
	inst.failures.clear()
	inst.checks = 0
	# Every test starts on the engine's own switches, so one that turns the injury rule on to read
	# it (off in the game since 9 November) never leaves it on for the next.
	Skirmish.injuries = false
	inst.call(method)
	_total_checks += inst.checks
	# A script error aborts the method silently, so a test that made no checks is
	# treated as a failure rather than a pass.
	if inst.checks == 0:
		inst.failures.append("no checks ran (script error before the first assertion?)")
	if inst.failures.is_empty():
		print("  ok    %s :: %s" % [f, method])
	else:
		_total_failures += inst.failures.size()
		print("  FAIL  %s :: %s" % [f, method])
		for msg in inst.failures:
			print("        - " + msg)


func _finish() -> void:
	print("")
	print("%d tests, %d checks, %d failures" % [_total_tests, _total_checks, _total_failures])
	quit(1 if _total_failures > 0 else 0)
