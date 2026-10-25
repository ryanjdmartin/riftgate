extends SceneTree

## Measures a screen's per-frame cost on this machine: frame time and draw calls, over a run
## of frames, printed as a table. The battle screen at zoom 1 and at full zoom (the default),
## or the skirmish screen (`-- skirmish`). Each row also gives the 3D views' own draw calls:
## the map's world and its machines' layer, or each machine's view in the skirmish (the
## machines are welded at load; RIFTGATE_WELD=off counts them as authored). Needs a window;
## run without vsync so the frame time is the work, not the refresh.
##   godot --path . --resolution 360x640 --disable-vsync -s tools/perf_probe.gd [-- skirmish]

const WARMUP := 60
const RUN := 180

var _vp: SubViewport
var _screen: Node
var _skirmish := false
var _frames := 0
var _phase := 0
var _t0 := 0
var _samples: Array = []


func _init() -> void:
	_skirmish = OS.get_cmdline_user_args().has("skirmish")
	_vp = SubViewport.new()
	_vp.size = Vector2i(720, 1280)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	var scene: PackedScene = load("res://game/skirmish/skirmish_screen.tscn" if _skirmish else "res://game/battle/battle_screen.tscn")
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
		_report("skirmish" if _skirmish else ("zoom 1.0" if _phase == 0 else "zoom 2.6"))
		if _skirmish:
			quit(0)
			return
		(_screen as BattleScreen)._map.zoom_at((_screen as BattleScreen)._map.size * 0.5, 2.6)
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
	print("%-10s  mean %.2f ms  p95 %.2f ms  draw calls %d  primitives %d  objects %d  3D: %s" % [
		label, mean, p95,
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
		_views()])


## The 3D views' draw calls this frame, each pass of every machine and prop counted: the
## map's world (field and machines) and its machines' layer, or each machine's view.
func _views() -> String:
	var calls := func(v: Viewport) -> int:
		return RenderingServer.viewport_get_render_info(v.get_viewport_rid(), RenderingServer.VIEWPORT_RENDER_INFO_TYPE_VISIBLE, RenderingServer.VIEWPORT_RENDER_INFO_DRAW_CALLS_IN_FRAME)
	var parts: PackedStringArray = []
	for m in _screen.find_children("*", "Map3D", true, false):
		var map: Map3D = m
		parts.append("map %d, its machines %d" % [calls.call(map), calls.call(map._units_vp)])
	var machines: PackedStringArray = []
	var total := 0
	for v in _screen.find_children("*", "MechView3D", true, false):
		var n: int = calls.call((v as MechView3D)._inner)
		machines.append(str(n))
		total += n
	if not machines.is_empty():
		parts.append("machines %s = %d" % [" + ".join(machines), total])
	return "; ".join(parts) if not parts.is_empty() else "none"
