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
	if Sound._node != null:
		Sound._node._lines.always = true   # Jenny on every hook: the chain's booked lines run too
	var sk := screen.sk
	for r in range(ROUNDS):
		if sk.outcome != Skirmish.Outcome.NONE:
			break
		screen._toggle_lock(0)
		screen._toggle_lock(0)
		screen._on_reroll()
		screen._on_die_tapped(0)
		screen._on_die_tapped(0)
		if not sk.field_foes().is_empty():
			screen._on_foe_held(screen._foe_view_for(sk.field_foes()[0]))
		screen._on_mech_held(0)
		screen._close_pop()
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
	screen._land_death(screen._mech_views[0], "wainwright_sutler")   # a machine's death at the turn's end
	await _wait(2.5)
	print("skirmish smoke: round %d, outcome %d" % [sk.round, sk.outcome])
	if Sound._node != null:
		Sound._node._lines.always = false
	await _wait(1.0)
	screen.queue_free()
	await _wait(0.3)


## One machine stood within its reach of the nearest pack, so the first turn can order it in
## and ENGAGE: the handover, the fight's sounds and Jenny on them, every run.
func _stand_in_reach(b: Battle) -> void:
	for m in b.mechs():
		if m.is_static() or not m.alive():
			continue
		for p in b.field.packs():
			for h in b.field.map.terrain.keys():
				var hx: Vector2i = h
				if b.in_range_from(m, hx, p) and b.field.can_stand(m, hx) and b.field.unit_at(hx) == null:
					m.pos = hx
					return


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
	# The peak's two sounds and a hunter's roar (16 November), each hook run once.
	screen._on_peak_beat("seam")
	await _wait(0.4)
	screen._on_peak_beat("tear")
	await _wait(0.4)
	if not b.field.packs().is_empty() and not b.mechs().is_empty():
		screen._show_lock(b.field.packs()[0], b.mechs()[0])
		await _wait(1.6)
	for phase in range(PHASES):
		if b.state != Battle.State.PLAN:
			break
		# The player's turn (main's battle, 8 October): a machine that can reach a pack is
		# ordered onto it (it walks into range); any other moves at once (tap it, tap where).
		# The one button then ENGAGEs the fight, or ENDs THE TURN when none is ordered.
		var ordered := 0
		if phase == 0:
			_stand_in_reach(b)   # the smoke needs a fight, not the walk to one
		for m in b.mechs():
			if m.is_static() or not m.alive() or b.actions_left(m) <= 0:
				continue
			var target: Unit = null
			for p in b.field.packs():
				if b.can_target(p) and b.attack_hex(m, p) != Battle.NO_HEX:
					target = p
					break
			if target != null:
				screen._order_attack(m, target, [])
				ordered += 1
			else:
				# Toward the packs: the reachable hex nearest any of them.
				screen._on_hex_tapped(m.pos)
				var best := Battle.NO_HEX
				var best_d := 1 << 30
				for h in screen._map.destinations.keys():
					for p in b.field.packs():
						var d: int = b._distance_from(h, p)
						if d < best_d:
							best_d = d
							best = h
				if best != Battle.NO_HEX:
					screen._on_hex_tapped(best)
			await _wait(1.2)   # its walk plays
			screen._select(null)
		print("battle smoke: turn %d, %d ordered onto packs, %s" % [phase, ordered, "ENGAGE" if not b.next_fight().is_empty() else "END TURN"])
		for k in range(50):   # the button ignores a press while a walk still plays
			if not screen._map.is_playing():
				break
			await _wait(0.2)
		screen._on_main_button()
		await _wait(5.0)
		if b.state == Battle.State.SKIRMISH:
			# The handover (or a boss's reveal) plays, then the fight opens.
			for k in range(40):
				if screen._skirmish != null:
					break
				await _wait(0.5)
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
