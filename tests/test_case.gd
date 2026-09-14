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
