extends SceneTree

## Renders a scene into a 720x1280 offscreen viewport and saves a PNG. Needs a window
## (not headless) because the dummy renderer produces no pixels.
##   godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/skirmish/skirmish_screen.tscn out.png [pose]
## Poses put the skirmish screen into a state before the capture: codex (a foe's entry),
## mechcodex, hold (a die's readout), confirm (the end-turn question), lock, rage (the rage's
## roll again mid-burst), heat (Burning and Scorched on the first machine).

var _frames := 0
var _vp: SubViewport
var _out := "screenshot.png"
var _pose := ""
var _node: Node
var _window := false


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
	# RIFTGATE_SHOT_H=1616 renders at a taller phone's height (with RIFTGATE_SAFE=top,bottom
	# for its safe bands): the phone's layout on the Mac.
	var shot_h := OS.get_environment("RIFTGATE_SHOT_H")
	var design := Vector2i(720, int(shot_h) if not shot_h.is_empty() else 1280)
	# RIFTGATE_SHOT_SCALE=1.5 renders the design at a phone's pixel density (a 1080-wide
	# phone is 1.5 design pixels per device pixel), the way the window's canvas_items stretch
	# does on the device: the PNG comes out that many times larger, and shows how text and
	# textures survive the scale.
	var scale_env := OS.get_environment("RIFTGATE_SHOT_SCALE")
	if not scale_env.is_empty():
		var s := float(scale_env)
		_vp.size = Vector2i(int(design.x * s), int(design.y * s))
		_vp.size_2d_override = design
		_vp.size_2d_override_stretch = true
	else:
		_vp.size = design
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	# RIFTGATE_SHOT_WINDOW=1 skips the SubViewport and puts the scene in the window itself,
	# so the capture goes through the project's own stretch and font oversampling, the way
	# the phone does: run with --resolution 1080x1920 for a 1080 phone's density.
	_window = OS.get_environment("RIFTGATE_SHOT_WINDOW") == "1"
	if not _window:
		root.add_child(_vp)
	var scene: PackedScene = load(scene_path)
	if scene == null:
		push_error("cannot load %s" % scene_path)
		quit(2)
		return
	_node = scene.instantiate()
	if _window:
		root.add_child(_node)
	else:
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
		"acquire":
			# The display locking onto every intent, mid-collapse (RIFTGATE_SHOT_FRAME=10).
			s._acquire_intents()
		"groundtear":
			# The corrupted side's tear, caught as it fires: the backdrop's clock is set just
			# past the first firing time (RIFTGATE_SHOT_FRAME=4).
			s._bg._t = TearLayer.fire_time() + 0.03
		"feed_scanbox", "feed_databox", "feed_readout", "feed_levels", "feed_recalc", "feed_wobble", "feed_tear", "feed_signal":
			# One of the feed's analysis events, started now (RIFTGATE_SHOT_FRAME=20 for the
			# boxes, 8 for the tear, the signal drop and the recalculation).
			s._fx.force(_pose.trim_prefix("feed_"))
		"menu", "settings", "quit":
			s._open_menu()
			if _pose != "menu":
				s._menu._show_page(_pose)
		"withdraw":
			# Withdraw confirmed: the enemy's parting blows replay (RIFTGATE_SHOT_FRAME) before
			# the outcome.
			s._on_withdraw()
			s._confirm_yes()
		"strike":
			# Spend the first mech's face on the first front foe: the attack animation plays.
			var foe: Foe = s.sk.front[0]
			s._use_die(0, foe)
		"plaque":
			# The other world's window announcing a foe's named move (RIFTGATE_SHOT_FRAME=20,
			# past its fade-in).
			s._announce("Self-Destruct")
		"blast", "siphon":
			# The Whip Scorpion's forecasts (22 October): the first machine whose die carries a vent
			# that blasts (blast) or a Lure over every foe (siphon) shows that entry, hot enough to
			# fire, dragged: over its own machine for the blast's rings, over a foe for the lure's
			# dashed arrows and gauges. RIFTGATE_TEAM puts the Whip Scorpion on the team.
			for i in range(s.sk.mechs.size()):
				var ms: Skirmish.MechState = s.sk.mechs[i]
				for k in range(ms.die.faces.size()):
					var f: Face = ms.die.faces[k]
					var want: bool = (f.kind == Face.Kind.VENT and Effects.vent_blast(ms.unit) > 0.0) if _pose == "blast" else (f.reaches_all and f.has(Face.Keyword.LURE))
					if not want:
						continue
					ms.face_index = k
					ms.heat = maxi(ms.heat, 40)
					s._refresh()
					s._on_drag_started(i)
					var over: Control = s._mech_views[i] if _pose == "blast" else s._foe_view_for(s.sk.front[0])
					var at := over.get_global_rect().get_center()
					s._on_drag_moved(at)
					return
		"reserve":
			# The reinforcements waiting by rank in the formation's gutter: two for the front, one
			# for the back, one massive (its tall plaque between the ranks).
			var archer := Foe.make("skeleton_archer", 30, 10)
			archer.prefers_back = true
			var big := Foe.make("revenant", 300, 10)
			big.size = 2
			s.sk.reinforcements.clear()
			s.sk.reinforcements.append_array([Foe.make("revenant", 30, 10), Foe.make("revenant", 30, 10), archer, big])
			s._refresh()
		"rage":
			# The rage's roll again: the chip's burst and the die folded before its flip
			# (RIFTGATE_SHOT_FRAME=8 catches the burst mid-flight).
			s._rage_debug()
		"heat":
			# A foe's fire on the first machine: Burning ×2 and Scorched ×1 on its chip row, with
			# Primed beside them, the one other flame a machine wears.
			var u: Unit = s.sk.mechs[0].unit
			Effects.stack(u, Effects.STATUS["burning_mech"], Effects.SKIRMISH, "shot", 2, Effects.DECAY_TURN)
			Effects.stack(u, Effects.STATUS["scorched"], Effects.SKIRMISH, "shot", 1, Effects.DECAY_TURN_ALL)
			Effects.stack(u, Effects.STATUS["primed"], Effects.SKIRMISH, "shot", 1, Effects.DECAY_TICK)
			s._refresh()
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


## Battle screen poses: select (a mech and its reach), route (two machines moved), draft and
## draftslow (a route drawn by hand, its move gauge spent or stopped by a slow hex), carry (a
## carrier's route drawn to a stop where its rider cannot land: NO ROOM), hold (a
## pack's readout), codex / foecodex (a machine's or a pack's entry), resolve (one turn
## ended), attack (a fight set up beside a pack), caught (a hunter's forced fight), engage
## (the handover into a fight), bosscontact (the boss's reveal).
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
			s._on_unit_held(b.field.packs()[0])
		"draft", "draftslow":
			# A route being drawn by hand, the move gauge at its end (decided 3 October): draft
			# stops about halfway through the move on open ground, draftslow ends on a slow hex,
			# whose step takes the rest (the hatched pips). The first machine that has one.
			for m in b.mechs():
				s._on_route_drag_started(m)
				s._map._route_drag = m
				var pick := Vector2i(-9999, -9999)
				for h in s._map.destinations.keys():
					var slow := BattleMap.move_cost(b.field.map.terrain[h], m.traits) == BattleMap.SLOW
					var cost := b.field.route_cost(m, b.field.route_to(m, h))
					if _pose == "draftslow" and slow and cost > 0 and b.draft_spend(m, b.field.route_to(m, h)).x > 0:
						pick = h
						break
					if _pose == "draft" and not slow and cost >= m.movespeed / 2 and cost < m.movespeed:
						pick = h
						break
				if pick != Vector2i(-9999, -9999):
					s._on_route_drag_to(pick)
					s._map.scroll_to_unit(m)
					break
				s._on_route_drag_ended(false)
				s._map._route_drag = null
		"carry":
			# The Swallowtail's block (Ryan, 21 October): the first machine carries, the second
			# rides beside it, the third holds the hex the rider would land on, and the route is
			# drawn two hexes on, over the rider: the landing that fails and the stop marked.
			var ours: Array = [b.mechs()[0], b.mechs()[1], b.mechs()[2]]
			(ours[0] as Unit).grant_passive({"id": "deck", "name": "Deck", "description": "", "effects": [{"trigger": "static", "effect": "carry"}]})
			var near: Array = b.field.map.all_hexes()   # nearest the machines first, away from the packs
			var home: Vector2i = (ours[0] as Unit).pos
			near.sort_custom(func(x, y): return Hex.distance(x, home) < Hex.distance(y, home))
			for c in near:
				var by_pack := false
				for sq in b.field.packs():
					if Hex.distance(sq.pos, c) <= 4:
						by_pack = true
				if by_pack:
					continue
				var done := false
				for d in Hex.DIRECTIONS:
					var line: Array = [c, c + d, c + d * 2, c + d * 3]
					var ok := true
					for k in range(4):
						var h: Vector2i = line[k]
						var o := b.field.unit_at(h) if b.field.map.has(h) else null
						if not b.field.map.has(h) or b.field.map.is_structure(h) or (o != null and not ours.has(o)) \
								or not BattleMap.passable(b.field.map.terrain[h], (ours[0] as Unit).traits) \
								or BattleMap.move_cost(b.field.map.terrain[h], (ours[0] as Unit).traits) == BattleMap.SLOW:
							ok = false
							break
					if ok:
						(ours[0] as Unit).pos = line[0]
						(ours[1] as Unit).pos = line[1]
						(ours[2] as Unit).pos = line[3]
						s._refresh()
						s._on_route_drag_started(ours[0])
						s._map._route_drag = ours[0]
						s._on_route_drag_to(line[2])
						s._map.scroll_to_unit(ours[0])
						done = true
						break
				if done:
					break
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
		"attack", "predict":
			# A pack parked beside the first machine and tapped with it in hand: the fight's
			# panel, the target lit, the attack range and the joining rings on the map.
			var m: Unit = b.mechs()[0]
			var sq: Unit = b.field.packs()[0]
			for n in Hex.neighbors(m.pos):
				if b.field.can_stand(sq, n):
					sq.pos = n
					break
			sq.movespeed = 0
			sq.behaviour = "push"
			s._refresh()
			s._on_hex_tapped(m.pos)
			s._on_hex_tapped(sq.pos)
		"caught":
			# A hunter beside the first machine at the turn's start: the warning, then the panel.
			var m: Unit = b.mechs()[0]
			var sq: Unit = b.field.packs()[0]
			for n in Hex.neighbors(m.pos):
				if b.field.can_stand(sq, n):
					sq.pos = n
					break
			sq.behaviour = "hunt"
			sq.prey = m.id
			b._new_turn()
			s._after_step()
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
			s._on_hex_double_tapped(b.field.packs()[0].pos)
		"resolve":
			s._on_end_turn()
		"gate":
			# The gate tapped: its footprint and the hexes it can be attacked from.
			s._on_hex_tapped(b.field.map.gate_hexes[0])
		"foe":
			# A pack tapped: bracketed, its path heavy, its strength over it; the map looks at it.
			var fsq: Unit = b.field.packs()[0]
			s._map.scroll_to_unit(fsq)
			s._on_hex_tapped(fsq.pos)
		"onprops":
			# The first machine set down on the nearest hex with props (ruins, city, rough):
			# the props there hide under it.
			var fm: Unit = b.mechs()[0]
			var bmap := b.field.map
			var best := fm.pos
			var best_d := 1 << 30
			for hh in bmap.all_hexes():
				var tt: int = bmap.terrain_of(hh)
				if (tt == BattleMap.Terrain.RUINS or tt == BattleMap.Terrain.ROUGH or bmap.city.has(hh)) and b.field.can_stand(fm, hh):
					var dd := Hex.distance(fm.pos, hh)
					if dd < best_d:
						best_d = dd
						best = hh
			fm.pos = best
			s._refresh()
			s._map.scroll_to_unit(fm)
		"logfull":
			# The battle's log, full screen, from the board's LOG button.
			s._toggle_log_full()
		"engage":
			# ENGAGE pressed: the handover into the skirmish, mid-flight (RIFTGATE_SHOT_FRAME).
			var m: Unit = b.mechs()[0]
			var sq: Unit = b.field.packs()[0]
			for n in Hex.neighbors(m.pos):
				if b.field.can_stand(sq, n):
					sq.pos = n
					break
			sq.movespeed = 0
			sq.behaviour = "push"
			s._refresh()
			s._on_hex_tapped(m.pos)
			s._on_hex_tapped(sq.pos)
			s._engage()
		"contact":
			# The fight open over the map: as engage, at its end (a later RIFTGATE_SHOT_FRAME).
			var m: Unit = b.mechs()[0]
			var sq: Unit = b.field.packs()[0]
			for n in Hex.neighbors(m.pos):
				if b.field.can_stand(sq, n):
					sq.pos = n
					break
			sq.movespeed = 0
			sq.behaviour = "push"
			s._refresh()
			s._on_hex_tapped(m.pos)
			s._on_hex_tapped(sq.pos)
			s._engage()
		"bosscontact":
			# The boss attacked: the reveal over the map (RIFTGATE_REVEAL_T pins its second).
			var m: Unit = b.mechs()[0]
			var boss: Unit = b.boss
			for n in Hex.neighbors(m.pos):
				if b.field.can_stand(boss, n):
					boss.pos = n
					break
			boss.movespeed = 0
			s._refresh()
			s._on_hex_tapped(m.pos)
			s._on_hex_tapped(boss.pos)
			s._engage()

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
	var img := (root.get_viewport().get_texture() if _window else _vp.get_texture()).get_image()
	var err := img.save_png(_out)
	print("saved %s (%s)" % [_out, error_string(err)])
	quit(0 if err == OK else 1)
