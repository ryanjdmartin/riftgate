extends SceneTree

## Renders a scene into a 720x1280 offscreen viewport and saves a PNG. Needs a window
## (not headless) because the dummy renderer produces no pixels.
##   godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/skirmish/skirmish_screen.tscn out.png [pose]
## Poses put the skirmish screen into a state before the capture: codex (a foe's entry),
## mechcodex, hold (a die's readout), confirm (the end-turn question), lock.

var _frames := 0
var _vp: SubViewport
var _out := "screenshot.png"
var _pose := ""
var _node: Node


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var scene_path := "res://game/skirmish/skirmish_screen.tscn"
	if args.size() >= 1:
		scene_path = args[0]
	if args.size() >= 2:
		_out = args[1]
	if args.size() >= 3:
		_pose = args[2]
	_vp = SubViewport.new()
	_vp.size = Vector2i(720, 1280)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	var scene: PackedScene = load(scene_path)
	if scene == null:
		push_error("cannot load %s" % scene_path)
		quit(2)
		return
	_node = scene.instantiate()
	_vp.add_child(_node)
	process_frame.connect(_tick)


func _apply_pose() -> void:
	if _pose.is_empty():
		return
	if _node is BattleScreen:
		_apply_battle_pose()
		return
	if not (_node is SkirmishScreen):
		return
	var s: SkirmishScreen = _node
	match _pose:
		"codex":
			s._on_foe_double_tapped(s._foe_view_for(s.sk.front[0]))
		"mechcodex":
			s._on_mech_double_tapped(0)
		"hold":
			s._on_die_held(1)
		"confirm":
			s._on_end_turn()
		"lock":
			s._on_die_tapped(0)
			s._toggle_all_arrows(true)
		"strike":
			# Spend the first mech's face on the first front foe: the attack animation plays.
			var foe: Foe = s.sk.front[0]
			s._use_die(0, foe)
		"enemyturn":
			# Thin every shield so the enemy turn breaks some: the replay and shatter play.
			for ms in s.sk.mechs:
				ms.unit.shield = mini(ms.unit.shield, 10)
			s._end_turn_now()
		"rounds", "logfull":
			# A few rounds of events; logfull then opens the log full screen.
			for k in range(3):
				s._use_die(0, s.sk.front[0])
				s._end_turn_now()
			if _pose == "logfull":
				s._toggle_log_full()
		"killed":
			# The first foe killed by a big die: its slot cleared, the death ghost mid-flight
			# (RIFTGATE_SHOT_FRAME=14), the foe behind it exposed, every arrow on.
			s.sk.mechs[0].die.faces[s.sk.mechs[0].face_index] = Face.attack(200)
			s._use_die(0, s.sk.front[0])
			s._toggle_all_arrows(true)


## Battle screen poses: select (a mech and its reach), route (two routes plotted), hold (a
## squad's readout), codex / foecodex (a machine's or a squad's entry), resolve (one
## phase run), contact (a skirmish open over the map).
func _apply_battle_pose() -> void:
	var s: BattleScreen = _node
	var b := s.battle
	match _pose:
		"select":
			s._on_hex_tapped(b.mechs()[0].pos)
		"route":
			for i in range(mini(2, b.mechs().size())):
				s._on_hex_tapped(b.mechs()[i].pos)
				var dests: Array = s._map.destinations.keys()
				if not dests.is_empty():
					s._on_hex_tapped(dests[dests.size() / 2])
		"hold":
			s._on_unit_held(b.field.squads()[0])
		"north":
			# The rift end of the map, where the other world bleeds in.
			s._map.scroll_to_top()
			s._map.queue_redraw()
		"tune":
			s._toggle_tuner()
		"menu":
			s._open_menu()
		"settings":
			s._open_menu()
			s._menu._show_page("settings")
		"predict":
			# A squad parked beside the first mech and a route plotted: the plan's contact
			# and block tags before resolve.
			var m: Unit = b.mechs()[0]
			var sq: Unit = b.field.squads()[0]
			for n in Hex.neighbors(m.pos):
				if b.field.can_stand(sq, n):
					sq.pos = n
					break
			b.field.compute_intents()
			s._on_hex_tapped(b.mechs()[1].pos)
			var dests: Array = s._map.destinations.keys()
			if not dests.is_empty():
				s._on_hex_tapped(dests[0])
		"flyer":
			# The flyer parked two rows south of the rift, in the other world's ground, zoomed.
			for m in b.mechs():
				if m.traits.has("flyer"):
					var want := Hex.offset_to_axial(Hex.axial_to_offset(b.field.map.rift).x, Hex.axial_to_offset(b.field.map.rift).y + 2)
					m.pos = b.field.nearest_standable(m, want)
					s._map.zoom_at(s._map.size * 0.5, 2.0)
					s._map.scroll_to_unit(m)
					break
		"zoom", "zoomlast":
			# Zoomed in twice on the first (or last) mech, panned so it sits mid-screen.
			s._map.zoom_at(s._map.size * 0.5, 2.4)
			s._map.scroll_to_unit(b.mechs()[0] if _pose == "zoom" else b.mechs()[b.mechs().size() - 1])
		"codex":
			s._on_hex_double_tapped(b.mechs()[0].pos)
		"foecodex":
			s._on_hex_double_tapped(b.field.squads()[0].pos)
		"resolve":
			s._on_resolve()
		"engage":
			# ENGAGE pressed: the handover into the skirmish, mid-flight (RIFTGATE_SHOT_FRAME).
			var m: Unit = b.mechs()[0]
			var sq: Unit = b.field.squads()[0]
			for n in Hex.neighbors(m.pos):
				if b.field.can_stand(sq, n):
					sq.pos = n
					break
			sq.movespeed = 0
			b.field.compute_intents()
			b.commit()
			s._refresh()
			s._open_skirmish(0)
		"contact":
			var m: Unit = b.mechs()[0]
			var sq: Unit = b.field.squads()[0]
			for n in Hex.neighbors(m.pos):
				if b.field.can_stand(sq, n):
					sq.pos = n
					break
			sq.movespeed = 0
			b.field.compute_intents()
			s._on_resolve()


func _tick() -> void:
	_frames += 1
	if _frames == 2:
		_apply_pose()
	# RIFTGATE_SHOT_FRAME picks the capture frame (default 6), to catch an animation mid-flight.
	var want := 6
	var env := OS.get_environment("RIFTGATE_SHOT_FRAME")
	if not env.is_empty():
		want = int(env)
	if _frames < want:
		return
	process_frame.disconnect(_tick)
	var img := _vp.get_texture().get_image()
	var err := img.save_png(_out)
	print("saved %s (%s)" % [_out, error_string(err)])
	quit(0 if err == OK else 1)
