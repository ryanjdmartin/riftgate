extends SceneTree

## Headless test runner.
##   godot --headless --path . -s tests/run_tests.gd
## Discovers tests/test_*.gd, instantiates each, and calls every method named test_*.


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

	var total_checks := 0
	var total_failures := 0
	var total_tests := 0
	for f in files:
		var script: GDScript = load("res://tests/" + f)
		if script == null or not script.can_instantiate():
			print("  LOAD  %s failed to compile" % f)
			total_failures += 1
			continue
		var inst = script.new()
		for m in inst.get_method_list():
			var name: String = m.name
			if not name.begins_with("test_"):
				continue
			total_tests += 1
			inst.failures.clear()
			inst.checks = 0
			inst.call(name)
			total_checks += inst.checks
			# A script error aborts the method silently, so a test that made no checks is
			# treated as a failure rather than a pass.
			if inst.checks == 0:
				inst.failures.append("no checks ran (script error before the first assertion?)")
			if inst.failures.is_empty():
				print("  ok    %s :: %s" % [f, name])
			else:
				total_failures += inst.failures.size()
				print("  FAIL  %s :: %s" % [f, name])
				for msg in inst.failures:
					print("        - " + msg)
	print("")
	print("%d tests, %d checks, %d failures" % [total_tests, total_checks, total_failures])
	quit(1 if total_failures > 0 else 0)
