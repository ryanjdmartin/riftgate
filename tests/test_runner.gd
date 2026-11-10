extends TestCase

## The runner's own check (tests/run_tests.gd): it reads the engine's log for script errors while
## a test runs and fails the test for each, since a crash aborts only its function.


func _crash() -> int:
	var d: Dictionary = {}
	return d["a deliberate crash: the runner's crash check, tested"]


## A crash under a test reaches the runner. This test raises one on purpose and says so; were the
## runner to stop hearing script errors (the Logger's interface moving with an engine update), it
## would count none and fail here, where every other test would go back to passing in silence.
## The SCRIPT ERROR this prints into every run's log is this test's.
func test_a_crash_under_a_test_reaches_the_runner() -> void:
	script_errors_expected = 1
	assert_true(true, "a check before the crash, as the tests that read as passed had")
	_crash()
