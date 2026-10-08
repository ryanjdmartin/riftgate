extends SceneTree

## A smoke run of the game's sound hooks with a window, so the Sound node exists and every
## hook's code path runs (headless, Sound is a no-op and the tests never reach them). The
## master bus is muted; the log is the result: any SCRIPT ERROR is a broken hook.
##   godot --path . --resolution 360x640 -s tools/sound_smoke.gd
## It plays a skirmish (every die spent where it may go, locks, a reroll, holds, the codex,
## the menu, the turn ended and the enemy's replay) for a few rounds, then a battle (routes,
## resolves, a contact and its skirmish) until a fight opens or the phases run out.

const ROUNDS := 4
const PHASES := 8


func _init() -> void:
	_run.call_deferred()


func _wait(seconds: float) -> void:
	await create_timer(seconds).timeout


func _run() -> void:
	AudioServer.set_bus_mute(0, true)
	await _skirmish()
	await _battle()
	print("SMOKE DONE")
	quit(0)


func _skirmish() -> void:
	var screen: SkirmishScreen = load("res://game/skirmish/skirmish_screen.tscn").instantiate()
	root.add_child(screen)
	await _wait(1.0)
	var sk := screen.sk
	for r in range(ROUNDS):
		if sk.outcome != Skirmish.Outcome.NONE:
			break
		screen._on_die_tapped(0)
		screen._on_die_tapped(0)
		screen._on_reroll()
		screen._on_die_held(0)
		screen._on_hold_released()
		if not sk.field_foes().is_empty():
			screen._on_foe_held(screen._foe_view_for(sk.field_foes()[0]))
			screen._on_hold_released()
		screen._on_mech_held(0)
		screen._on_hold_released()
		Sound.hover(true)
		await _wait(0.3)
		Sound.hover(false)
		for i in range(sk.mechs.size()):
			var spent := false
			for foe in sk.field_foes():
				if sk.can_assign(i, foe):
					screen._use_die(i, foe)
					spent = true
					break
			if not spent and sk.can_assign(i, sk.mechs[i]):
				screen._use_die(i, sk.mechs[i])
			await _wait(0.4)
		if r == 0:
			screen._on_mech_double_tapped(0)
			await _wait(0.3)
			screen._close_codex()
			screen._open_menu()
			await _wait(0.3)
			screen._menu.close()
		if sk.outcome != Skirmish.Outcome.NONE:
			break
		screen._end_turn_now()
		await _wait(6.0)
	print("skirmish smoke: round %d, outcome %d" % [sk.round, sk.outcome])
	await _wait(1.0)
	screen.queue_free()
	await _wait(0.3)


func _battle() -> void:
	Sound.voice_clear()
	await _wait(7.0)   # past the skirmish's last line and its spacing
	var screen: BattleScreen = load("res://game/battle/battle_screen.tscn").instantiate()
	root.add_child(screen)
	await _wait(1.5)
	# The battle's opening line, every time: she should be speaking now, the music under her.
	var node: Sound = Sound._node
	print("voice: playing %s, line %s, music under her %.1f dB" % [node._voice.playing,
		node._voice.stream.resource_path.get_file() if node._voice.stream != null else "none", node._voice_db])
	var b := screen.battle
	for phase in range(PHASES):
		if b.state != Battle.State.PLAN:
			break
		for m in b.mechs():
			if m.is_static() or not m.alive():
				continue
			screen._on_hex_tapped(m.pos)
			var dests: Array = screen._map.destinations.keys()
			if not dests.is_empty():
				screen._on_hex_tapped(dests[dests.size() - 1])
			await _wait(0.2)
		screen._on_resolve()
		await _wait(5.0)
		if b.state == Battle.State.SKIRMISH:
			# The contact's warning plays, then its panel slides in; a boss opens its own fight.
			for k in range(40):
				if screen._contacts != null or screen._skirmish != null:
					break
				await _wait(0.5)
			if screen._skirmish == null:
				screen._open_skirmish(0)
			await _wait(4.0)
			if screen._skirmish != null:
				var sk: Skirmish = screen._skirmish.sk
				for i in range(sk.mechs.size()):
					for foe in sk.field_foes():
						if sk.can_assign(i, foe):
							screen._skirmish._use_die(i, foe)
							break
				screen._skirmish._end_turn_now()
				await _wait(6.0)
			print("battle smoke: a skirmish opened at phase %d" % phase)
			break
	print("battle smoke: state %d, outcome %d" % [b.state, b.outcome])
	screen.queue_free()
	await _wait(0.3)
