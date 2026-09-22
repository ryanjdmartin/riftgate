extends SceneTree

## Measures the battle screen's per-frame cost on this machine: frame time and draw calls
## at zoom 1 and at full zoom, over a run of frames each, printed as a table. Needs a
## window; run without vsync so the frame time is the work, not the refresh.
##   godot --path . --resolution 360x640 --disable-vsync -s tools/perf_probe.gd

const WARMUP := 60
const RUN := 180

var _vp: SubViewport
var _screen: BattleScreen
var _frames := 0
var _phase := 0
var _t0 := 0
var _samples: Array = []


func _init() -> void:
	_vp = SubViewport.new()
	_vp.size = Vector2i(720, 1280)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	var scene: PackedScene = load("res://game/battle/battle_screen.tscn")
	_screen = scene.instantiate()
	_vp.add_child(_screen)
	process_frame.connect(_tick)


func _tick() -> void:
	_frames += 1
	var now := Time.get_ticks_usec()
	if _frames == WARMUP:
		_t0 = now
		_samples.clear()
	elif _frames > WARMUP:
		_samples.append((now - _t0) / 1000.0)
		_t0 = now
	if _frames == WARMUP + RUN:
		_report("zoom 1.0")
		_screen._map.zoom_at(_screen._map.size * 0.5, 2.6)
		_frames = 0
		_phase += 1
		if _phase == 2:
			quit(0)


func _report(label: String) -> void:
	_samples.sort()
	var sum := 0.0
	for s in _samples:
		sum += s
	var mean := sum / _samples.size()
	var p95: float = _samples[int(_samples.size() * 0.95)]
	print("%-10s  mean %.2f ms  p95 %.2f ms  draw calls %d  primitives %d  objects %d" % [
		label if _phase == 0 else "zoom 2.6", mean, p95,
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))])
