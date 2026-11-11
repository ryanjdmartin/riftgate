extends SceneTree

## Headless test runner.
##   godot --headless --path . -s tests/run_tests.gd
## Discovers tests/test_*.gd, instantiates each, and calls every method named test_* as the
## runner starts. A method named live_test_* runs on the first frame instead, once the scene
## tree is up (its root is not in the tree while the runner starts): a test that needs input
## routed as the engine routes it (a touch dragged over a scrolled list) adds its screen to the
## tree and pushes the events through a viewport.
##   godot --headless --path . -s tests/run_tests.gd -- loot rig
## runs only the files whose names hold one of those words (test_loot.gd, test_mech_rig.gd), for a
## quick look while working; the whole suite is the check before a commit.

var _total_checks := 0
var _total_failures := 0
var _total_tests := 0
var _live: Array = []   # [file, instance, method]: the live tests, for the first frame
var _errors := ScriptErrors.new()


## The engine's log, read for script errors while a test runs. A script error aborts the function
## it is raised in and the caller plays on, so a test that crashed after its first check, or whose
## code under test crashed and handed back a null, used to read as passed (found 30 October). The
## engine may log from any thread, hence the lock.
class ScriptErrors extends Logger:
	var _lock := Mutex.new()
	var _seen: Array[String] = []

	func _log_error(_function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtraces: Array) -> void:
		if error_type != ERROR_TYPE_SCRIPT:
			return
		_lock.lock()
		_seen.append("%s (%s:%d)" % [rationale if rationale != "" else code, file, line])
		_lock.unlock()

	func take() -> Array[String]:
		_lock.lock()
		var out := _seen.duplicate()
		_seen.clear()
		_lock.unlock()
		return out


func _init() -> void:
	OS.add_logger(_errors)
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
	var only := Array(OS.get_cmdline_user_args())
	if not only.is_empty():
		files = files.filter(func(f: String) -> bool: return only.any(func(w: String) -> bool: return f.contains(w)))

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
	inst.script_errors_expected = 0
	_errors.take()
	inst.call(method)
	_total_checks += inst.checks
	# A script error aborts its function silently, in the test or under it, so each one the
	# engine logged while the test ran fails it, and so does a test that made no checks.
	var errors := _errors.take()
	if inst.script_errors_expected > 0:
		if errors.size() != inst.script_errors_expected:
			inst.failures.append("expected %d script errors, the engine logged %d" % [inst.script_errors_expected, errors.size()])
	else:
		for e in errors:
			inst.failures.append("script error: " + e)
	if inst.checks == 0:
		inst.failures.append("no checks ran")
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
