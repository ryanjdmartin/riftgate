extends SceneTree

## Renders a scene into a 720x1280 offscreen viewport and saves a PNG. Needs a window
## (not headless) because the dummy renderer produces no pixels.
##   godot --path . --resolution 360x640 -s tools/screenshot.gd -- res://game/skirmish/skirmish_screen.tscn out.png [pose]
## Poses put the skirmish screen into a state before the capture: codex (a foe's entry), pair
## and pair_spread (a Gel's halves in its slot, and a Spread held over them; RIFTGATE_FOES=gel:2,goblin:3),
## mechcodex, hold (the second die's readout; RIFTGATE_HOLD_ENTRY=<place> picks the entry
## showing), mechhold and foehold (the first machine's and the first foe's readout, as a tap opens it), confirm (the
## end-turn question), lock, rage (the rage's roll again mid-burst), heat (Ablating and
## Scorched on the first machine), foeheat (heat's red-orange beside the enemy's violet on three foes' chips), repick (a foe whose machine falls before it acts, a second
## arrow dashed to the machine it will strike), columns (every foe aimed at the machine nearest its column, every arrow on).

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
	_vp.gui_embed_subwindows = true   # a popup (the colour picker) drawn inside the capture, as the phone embeds it
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
	if _node is QuickRunScreen:
		_apply_quick_pose()
		return
	if not (_node is SkirmishScreen):
		return
	var s: SkirmishScreen = _node
	match _pose:
		"codex":
			s._on_foe_double_tapped(s._foe_view_for(s.sk.front[0]))
		"mechcodex":
			s._on_mech_double_tapped(0)
		"termtip":
			# A term's tip (30 October): the first machine's codex, then the first term its passive
			# names opened as a tap on it opens it, once the plate has laid out (RIFTGATE_TEAM
			# chooses the machine).
			s._on_mech_double_tapped(0)
			_later(2, func() -> void:
				var r: EntryReadout = s._codex._passives
				if not r._hits.is_empty():
					r.open_tip(r._hits[0]["terms"], r._hits[0]["rect"]))
		"pair", "pair_spread":
			# The Gel's pair (26 October): the first Gel on the front falls and its halves stand
			# in its slot (RIFTGATE_FOES=gel:2,goblin:3); pair_spread holds a Spread weapon over
			# the formation, the pair bracketed as one slot.
			var db := ContentDB.load_default()
			s.sk.foe_factory = func(id: String) -> Foe: return db.make_foe(id)
			for f in s.sk.field_foes():
				if f.content_id == "gel" and f.rank == 0:
					f.hp = 0
					break
			s.sk._clear_dead()
			if _pose == "pair_spread":
				s.sk.mechs[0].die = Die.single(Face.attack(3, Face.Reach.DIRECT, Face.Keyword.CLEAVE))
				s.sk.mechs[0].face_index = 0
				s._drag_from = 0
			s._refresh()
		"hold":
			# The second machine's die read, a tap (its readout). RIFTGATE_HOLD_ENTRY=<place> (from
			# 1) shows that entry of its die first, to read any piece's (with RIFTGATE_TEAM to
			# choose the machine).
			var at := int(OS.get_environment("RIFTGATE_HOLD_ENTRY")) - 1
			if at >= 0 and at < s.sk.mechs[1].die.faces.size():
				s.sk.mechs[1].face_index = at
				s._refresh()
			s._on_die_tapped(1)
		"mechhold":
			s._on_mech_held(0)
		"foehold":
			s._on_foe_held(s._foe_view_for(s.sk.front[0]))
		"confirm":
			s._on_end_turn()
		"lock":
			s._toggle_lock(0)
		"reboot":
			# The reboot (13 November; the rule since 15 November): the first machine past
			# its maximum, the second's shield broken, the third rebooting, the first die read, and
			# REBOOT at rest at the row's right end, REROLL at its left.
			var hot: Skirmish.MechState = s.sk.mechs[0]
			hot.heat = hot.heat_max + 4
			if s.sk.mechs.size() > 1:
				s.sk.mechs[1].unit.shield = 0
				s.sk._note_break(s.sk.mechs[1])
			if s.sk.mechs.size() > 2:
				s.sk.reboot_mech(2)
			s._refresh()
			s._on_die_tapped(0)
		"rebootdrag":
			# A die in hand over REBOOT (14 November; run with RIFTGATE_REBOOT=1): the control lit
			# as the die's target and filled under it.
			s._on_drag_started(0)
			s._on_drag_moved(s._reboot_btn.get_global_rect().get_center())
		"touch":
			# The first die lit as its tap waits out the double-tap window (30 October).
			s._dice[0]._tap_due = 1.0e12
			s._dice[0].queue_redraw()
		"swaphome":
			# A Swap waiting on its first target, then a tap on nothing sending it home (30 October):
			# RIFTGATE_SHOT_FRAME=6 or so catches the die in flight.
			var ms: Skirmish.MechState = s.sk.mechs[0]
			ms.die.faces[ms.face_index] = Face.from_dict({"kind": "attack", "reach": "indirect", "power": 0, "swaps": true})
			s._refresh()
			_later(1, func() -> void:
				s._begin_second(0, s.sk.targets_for(0)[0])
				_later(2, func() -> void: s._send_second_home()))
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
		"keywords":
			s._open_menu()
			s._menu._show_page("keywords")   # as the menu's KEYWORDS opens it
		"menu", "settings", "quit", "colours", "trials":
			s._open_menu()
			if _pose != "menu":
				s._menu._show_page(_pose)
		"colourpick":
			# A debug build's COLOURS page with the first swatch's picker open (the wheel, the
			# sliders and the hex), to judge its size on the phone's layout.
			s._open_menu()
			s._menu._show_page("colours")
			var swatches := s._menu._list.find_children("*", "ColorPickerButton", true, false)
			if not swatches.is_empty():
				var pb: ColorPickerButton = swatches[3]   # ENEMY
				pb.get_popup().popup_centered()
		"strike":
			# Spend the first mech's face on the first front foe: the attack animation plays, a
			# strike at a time (RIFTGATE_SHOT_FRAME catches a burst between its blows), the entry
			# RIFTGATE_HOLD_ENTRY=<place> names showing first (RIFTGATE_TEAM=skua and its Flechette Pod).
			var place := int(OS.get_environment("RIFTGATE_HOLD_ENTRY")) - 1
			if place >= 0 and place < s.sk.mechs[0].die.faces.size():
				s.sk.mechs[0].face_index = place
				s._refresh()
			var foe: Foe = s.sk.front[0]
			s._use_die(0, foe)
		"plaque":
			# The other world's window announcing a foe's named move (RIFTGATE_SHOT_FRAME=20,
			# past its fade-in).
			s._announce("Self-Destruct")
		"lure_all":
			# The lure-all's forecast (22 October): the first machine whose die carries a Lure over
			# every foe shows that entry, hot enough to fire, dragged over a foe for the turned
			# foes' dashed arrows and the gauges. With none on the team, the content's first
			# lure-all (the Shift Whistle) takes the first machine's first entry.
			var at_i := -1
			var at_k := -1
			for i in range(s.sk.mechs.size()):
				var dm: Skirmish.MechState = s.sk.mechs[i]
				for k in range(dm.die.faces.size()):
					var df: Face = dm.die.faces[k]
					if at_i < 0 and df.reaches_all and df.has(Face.Keyword.LURE):
						at_i = i
						at_k = k
			if at_i < 0:
				var db := ContentDB.load_default()
				for cid in db.components:
					var comp: Dictionary = db.components[cid]
					if str(comp.get("status", "")) == "planned":
						continue
					var lf := db.build_face(comp.get("face", {}))
					if lf.reaches_all and lf.has(Face.Keyword.LURE):
						lf.component = str(cid)
						for t in comp.get("tags", []):
							lf.tags.append(str(t))
						s.sk.mechs[0].die.faces[0] = lf
						at_i = 0
						at_k = 0
						break
			if at_i >= 0:
				var ms: Skirmish.MechState = s.sk.mechs[at_i]
				ms.face_index = at_k
				ms.heat = maxi(ms.heat, 40)
				s._refresh()
				s._on_drag_started(at_i)
				var over: Control = s._foe_view_for(s.sk.front[0])
				s._on_drag_moved(over.get_global_rect().get_center())
		"rage":
			# The rage's roll again: the chip's burst and the die folded before its flip
			# (RIFTGATE_SHOT_FRAME=8 catches the burst mid-flight).
			s._rage_debug()
		"repick":
			# The round preview's settled re-pick (26 October): the first machine falls to the first
			# front foe's blow, so the second, aimed at it too, strikes the pick it will make; every
			# arrow on, both intents solid and the second foe's spill dashed to that machine.
			s.sk.mechs[0].unit.shield = 0
			s.sk.mechs[0].unit.hull = 1
			var foes := s.sk.field_foes()
			for i in range(mini(2, foes.size())):
				for a in foes[i].actions:
					if Foe.is_attack_action(a):
						foes[i].action = a   # a blow, not a howl
						break
				foes[i].target = s.sk.mechs[0]
			s._toggle_all_arrows(true)
			s._refresh()
		"columns":
			# One column's two arrows apart (Ryan, 9 November: two foes of one column at the machine
			# below blended): every foe aimed at the machine nearest its column, its blow drawn, every
			# arrow on (RIFTGATE_FOES=goblin:4,mandragora:4 fills both ranks).
			for foe in s.sk.field_foes():
				for a in foe.actions:
					if Foe.is_attack_action(a):
						foe.action = a
						break
				foe.target = s.sk.mechs[clampi(foe.column - (s.sk.columns - s.sk.mechs.size()) / 2, 0, s.sk.mechs.size() - 1)]
			s._toggle_all_arrows(true)
			s._refresh()
		"chips":
			# Every unit crowded with chips (Ryan, 2 November: "chips can go off the sides of the
			# screen ... Need to wrap rows ... space for 2-3 rows of chips under the player units"):
			# seven statuses on each machine and five on each foe, so the rows wrap at the unit's
			# width and the third row under a machine shows its room.
			for ms in s.sk.mechs:
				var u: Unit = ms.unit
				for st in [["ablating_mech", Effects.DECAY_TURN], ["scorched", Effects.DECAY_TURN_ALL], ["primed", Effects.DECAY_TICK], ["overcharged", Effects.DECAY_NONE], ["braced", Effects.DECAY_TURN_ALL], ["phased", Effects.DECAY_TURN_ALL], ["cryoed", Effects.DECAY_NONE]]:
					if Effects.STATUS.has(st[0]):
						Effects.stack(u, Effects.STATUS[st[0]], Effects.SKIRMISH, "shot", 2, st[1])
			for foe in s.sk.field_foes():
				for id in ["ablating", "flakked", "shocked", "cryoed", "vitriol"]:
					Effects.stack(foe, Effects.STATUS[id], Effects.SKIRMISH, "mech", 2, Effects.status_decay(Effects.STATUS[id]))
			s._refresh()
		"essence":
			# The Ammit's count and its Tap's buff (12 and 15 November; RIFTGATE_TEAM=ammit,...): every
			# machine that banks a count as foes fall holds seven of it, two stacks of Empowered and
			# Essence Flare, and the first foe carries three stacks of Empowered: the count's chip and
			# the flare's on the machine, and nothing on the foe's Empowered for the hold.
			for ms in s.sk.mechs:
				for count_id in Effects.kill_counts(ms.unit):
					Effects.stack(ms.unit, Effects.STATUS[str(count_id)], Effects.status_scope(Effects.STATUS[str(count_id)]), "mech", 7, Effects.DECAY_NONE)
					Effects.stack(ms.unit, Effects.STATUS["overcharged"], Effects.SKIRMISH, "mech", 2, Effects.DECAY_HALF)
					Effects.grant_for_rounds(ms.unit, Effects.STATUS["essence_flare"], "shot", s.sk.round)
			var foes := s.sk.field_foes()
			if not foes.is_empty():
				Effects.stack(foes[0], Effects.STATUS["kindled"], Effects.SKIRMISH, "foe", 3, Effects.DECAY_HALF)
			s._refresh()
		"stores":
			# Every machine's own resource row part filled, to judge the rows beside the heat bar
			# (10 November; RIFTGATE_TEAM=badger,nemesis,cassowary,swallowtail, then musk_ox): the
			# Honey Badger's hopper at three loads of four, the Nemesis's rage at three, the
			# Cassowary's count two short of its shot, the Swallowtail's Muster a charge and a
			# half, the Musk Ox's magazine two down, and each machine a little hot.
			for ms in s.sk.mechs:
				var u: Unit = ms.unit
				ms.heat = maxi(ms.heat, int(u.heat_max * 0.4))
				if Effects.store_cap(u, "hopper") > 0:
					Effects.add_loads(u, 3)
				if Effects.store_cap(u, "rage") > 0:
					Effects.stack(u, Effects.STATUS["rage"], Effects.SKIRMISH, "mech", 3, Effects.DECAY_NONE)
				var every := Effects.counts_shots(u)
				if every > 2:
					Effects.stack(u, Effects.STATUS["shots"], Effects.SKIRMISH, "mech", every - 2, Effects.DECAY_NONE)
				var rule := Effects.muster_rule(u)
				if not rule.is_empty():
					Effects.stack(u, Effects.STATUS["muster"], Effects.SKIRMISH, "mech", int(int(rule.get("value", 30)) * 1.5), Effects.DECAY_NONE)
				if ms.ammo_max > 0:
					ms.ammo = maxi(0, ms.ammo_max - 2)
			s._refresh()
		"heat":
			# A foe's fire on the first machine: Ablating ×2 and Scorched ×1 on its chip row, with
			# Primed beside them, the one other flame a machine wears.
			var u: Unit = s.sk.mechs[0].unit
			Effects.stack(u, Effects.STATUS["ablating_mech"], Effects.SKIRMISH, "shot", 2, Effects.DECAY_TURN)
			Effects.stack(u, Effects.STATUS["scorched"], Effects.SKIRMISH, "shot", 1, Effects.DECAY_TURN_ALL)
			Effects.stack(u, Effects.STATUS["primed"], Effects.SKIRMISH, "shot", 1, Effects.DECAY_TICK)
			s._refresh()
		"foeheat":
			# Heat's red-orange beside the enemy's violet on the foes' chip rows, the one place the two
			# sit side by side: Ablating on the first front foe, Flak on the second, Shocked on the third.
			var ids := ["ablating", "flakked", "shocked"]
			var k := 0
			for foe in s.sk.front:
				if foe == null or k >= ids.size():
					continue
				var st: Dictionary = Effects.STATUS[ids[k]]
				Effects.stack(foe, st, Effects.SKIRMISH, "shot", 1 if ids[k] == "shocked" else 2, Effects.status_decay(st))
				k += 1
		"swallowed":
			# A foe's swallow on the first machine (30 October, Floraison's): out of the fight for two
			# rounds, drawn as a ghost under a dashed edge, its chip the maw.
			var sw: Unit = s.sk.mechs[0].unit
			Effects.grant_for_rounds(sw, Effects.STATUS["swallowed"], "swallow:0:shot", s.sk.round + 2)
			s.sk.mechs[0].assigned = true
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
		"undo":
			# One die spent on a scratch (3 November): UNDO lit at the bottom row's right end with
			# the one spend it reaches on its badge, the round's bar in the trail over the spend's line.
			s.sk.mechs[0].die.faces[s.sk.mechs[0].face_index] = Face.attack(1)
			s._use_die(0, s.sk.front[0])
			s._undo_from = 0   # the blow's wait skipped: the shot is of the button open
			s._refresh_undo()


## Battle screen poses: select (a mech and its reach), route (two machines' moves planned),
## plan_play (those two played on END TURN), execute (played on EXECUTE, the turn going on),
## endask (END TURN's question while machines can still act), inspect (a pack tapped: its walk and its hold), queue
## (two machines ordered onto two packs: the numbered fights and ENGAGE 1 OF 2), draft (a
## route drawn by hand, about halfway through the move), carry (a
## carrier's route drawn to a stop where its rider cannot land: NO ROOM), hold (a
## pack's readout; boss and ground the others'), fracture (a Fracture announced), rift (the rift's end: the vortex and the boss), codex / foecodex (a machine's or a pack's entry), resolve (one turn
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
		"boss":
			s._on_unit_held(b.boss)
		"ground":
			# Nothing in hand, a tap on the first open water (else ruins): what the ground is.
			var pick := Vector2i(-9999, -9999)
			for want in [BattleMap.Terrain.WATER, BattleMap.Terrain.RUINS]:
				for h in b.field.map.all_hexes():
					if b.field.map.terrain.get(h, -1) == want and b.field.unit_at(h) == null and not b.field.map.is_structure(h):
						pick = h
						break
				if pick != Vector2i(-9999, -9999):
					break
			s._on_hex_tapped(pick)
		"plan_play", "execute":
			# Two machines' moves planned, then END TURN, or EXECUTE (the turn going on): the plan
			# playing (RIFTGATE_SHOT_FRAME), or played, at a later frame.
			for i in range(mini(2, b.mechs().size())):
				s._on_hex_tapped(b.mechs()[i].pos)
				var dests: Array = s._map.destinations.keys()
				if not dests.is_empty():
					s._on_hex_tapped(dests[dests.size() / 2])
			if _pose == "execute":
				s._on_main_button()
			else:
				s._on_end_turn()
		"endask":
			# END TURN pressed with every machine still able to act: the question.
			s._on_main_button()
		"inspect":
			# A pack tapped with nothing in hand: its ring lit, every other pack's at rest.
			var sq: Unit = b.field.packs()[0]
			s._on_hex_tapped(sq.pos)
			s._map.scroll_to_unit(sq)
		"hunter":
			# A hunter and its chip (10 November): the first pack a few hexes off the first machine
			# and hunting it, the map looking at the pack: its chip with the machine's small picture
			# and the attack mark, the machine's tag with the hunter's, no ring round either.
			var hsq: Unit = b.field.packs()[0]
			var hm: Unit = b.mechs()[0]
			var best := hsq.pos
			for h in b.field.map.all_hexes():
				if Hex.distance(h, hm.pos) == 4 and b.field.can_stand(hsq, h) and Hex.axial_to_offset(h).y < Hex.axial_to_offset(hm.pos).y:
					best = h
					break
			hsq.pos = best
			hsq.behaviour = "hunt"
			hsq.prey = hm.id
			s._refresh()
			s._map.scroll_to_unit(hsq)
		"draft":
			# A route being drawn by hand: it stops about halfway through the move. The first
			# machine that has such a hex.
			for m in b.mechs():
				s._on_route_drag_started(m)
				s._map._route_drag = m
				var pick := Vector2i(-9999, -9999)
				for h in s._map.destinations.keys():
					var cost := b.field.route_cost(m, b.field.route_to(m, h))
					if cost >= m.movespeed / 2 and cost < m.movespeed:
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
								or BattleMap.step_cost(b.field.map.terrain[h], (ours[0] as Unit).traits) != BattleMap.STEP:
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
		"trials":
			# A debug build's TRIALS page (the refit's and the field's dials), to check it fits the glass.
			s._open_menu()
			s._menu._show_page("trials")
		"queue":
			# The fight queue (the long wall brief 7.4): two packs parked beside two machines and
			# each machine ordered onto one, so the map numbers the two fights and the button reads
			# ENGAGE 1 OF 2; the third machine's action pip still lit.
			var ms := b.mechs()
			var packs: Array = b.field.packs().filter(func(u: Unit) -> bool: return not u.is_boss)
			for k in range(mini(2, mini(ms.size(), packs.size()))):
				var m: Unit = ms[k]
				var sq: Unit = packs[k]
				for n in Hex.neighbors(m.pos):
					if b.field.can_stand(sq, n):
						sq.pos = n
						break
				sq.movespeed = 0
				sq.behaviour = "push"
				b.order(m, sq)
			s._refresh()
			s._map.scroll_to_unit(ms[0])
		"attack", "predict":
			# A pack parked beside the first machine and tapped with it in hand: the fight's
			# panel, the target lit and the machines in it bracketed.
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
		"caches", "cachesflat":
			# Zoomed in on the first cache (with RIFTGATE_CACHE_DEBUG=1 the three kinds beside the
			# team, on solid ground) or the last (the three by the rift, under the painting).
			var cs: Array = b.field.caches
			if not cs.is_empty():
				var on: Vector2i = cs[0 if _pose == "caches" else cs.size() - 1]["pos"]
				s._map.zoom_at(s._map.size * 0.5, 2.0)
				var p: Vector2 = s._map.center(on)
				s._map.scroll_x = s._map.size.x * 0.5 - p.x * s._map.zoom
				s._map.scroll_y = s._map.size.y * 0.5 - p.y * s._map.zoom
				s._map._clamp_scroll()
				s._map.queue_redraw()
		"wrecks":
			# Zoomed in on the first wreck (with RIFTGATE_WRECK_DEBUG=1 one of each of the team's
			# chassis lies beside it, 16 November).
			if not b.field.wrecks.is_empty():
				s._map.zoom_at(s._map.size * 0.5, 2.0)
				var p: Vector2 = s._map.center(b.field.wrecks[0].pos)
				s._map.scroll_x = s._map.size.x * 0.5 - p.x * s._map.zoom
				s._map.scroll_y = s._map.size.y * 0.5 - p.y * s._map.zoom
				s._map._clamp_scroll()
				s._map.queue_redraw()
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
		"rift":
			# The rift's end of the field: the vortex standing on its hexes (on the lowest of them
			# with the wall at the left) and the boss's picture at its size beside it (9 November).
			s._map.scroll_to_top()
			s._map.queue_redraw()
		"tear":
			# A peak of Rift Pressure (RIFTGATE_PEAKS=<n> for more): the seam crept, a tear open on
			# its row, the map looking at the newest, a little off the middle so the ring is seen
			# to stand on its hex under its name wherever the map is scrolled (10 November).
			for i in range(maxi(1, int(OS.get_environment("RIFTGATE_PEAKS")))):
				b.field.peak()
			s._refresh()
			if not b.field.tears.is_empty():
				var tp: Vector2 = s._map.center(b.field.tears[b.field.tears.size() - 1]["pos"])
				s._map.scroll_x = s._map.size.x * 0.4 - tp.x * s._map.zoom
				s._map.scroll_y = s._map.size.y * 0.6 - tp.y * s._map.zoom
				s._map._clamp_scroll()
			s._map.queue_redraw()
		"peak":
			# A peak's cutscene (10 November): the seam's creep under its front, then the tear
			# bursting open, then the map back where it was; RIFTGATE_SHOT_FRAME picks the moment
			# (a cloud session draws few frames a second: the sweep near 12, the tear's burst near 26).
			s._map.hold_peak()
			b.field.peak()
			s._refresh()
			s._map.play_peak(Callable())
		"hunted":
			# A hunter turns on a machine (10 November): the map gliding in on it, zoomed, the
			# HUNTED band over it, then back; RIFTGATE_SHOT_FRAME picks the moment (in a cloud
			# session the band over the hunter near 9).
			var lm: Unit = b.mechs()[0]
			s._map.play_locks([[b.field.packs()[0], lm]], s._show_lock, s._after_locks, maxf(s._map.size.y * 0.5, s.WARN_BAND_Y + s.WARN_BAND_H + 130.0))
		"fracture":
			# A Fracture announced as a fight's tally earns it (Ryan, 9 November: "Fractures need to
			# be announced"): the band over the map and the top bar's gauge flashing (the default
			# frame catches the band at full; it is gone by about the fortieth in a cloud session).
			if not b.thresholds.is_empty():
				b.menace_killed = int(b.thresholds[0])
				b.fractures = 1
			s._refresh()
			s._show_fracture(false)
		"elite":
			# A Fracture's elite introduced as it arrives (10 November): the map gliding in on its
			# hex, zoomed, the elite bursting out under the band that names it; RIFTGATE_SHOT_FRAME
			# picks the moment (in a cloud session the burst near 10, the band over it near 14).
			if not b.thresholds.is_empty():
				b.menace_killed = int(b.thresholds[0])
				b.fractures = 1
			b._spawn_elite()
			s._refresh()
			s._show_fracture(true)
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
	# RIFTGATE_SHOT_ZOOM=<z> shows any pose zoomed to z on its first machine, to judge its marks
	# zoomed in (they hold their size on screen at every zoom).
	var z := float(OS.get_environment("RIFTGATE_SHOT_ZOOM"))
	if z > 0.0 and is_instance_valid(s._map):
		s._map.zoom_at(s._map.size * 0.5, z / s._map.zoom)
		s._map.scroll_to_unit(b.mechs()[0])

## The quick campaign's screens (25 October): draft (the default, nothing picked), picked (three
## picked), hangar (the first battle ahead, a stored piece and module: RIFTGATE_SHOT_H=3000 shows
## the stores at its foot), chooser (a hardpoint's pieces), fight (the first fight open), track
## (between fights, one won), rewards (the boss down, a card chosen), over.
func _apply_quick_pose() -> void:
	var s: QuickRunScreen = _node
	var r := s.run
	if _pose == "draft":
		return
	for id in QuickRun.draft_choices(r.db).slice(0, QuickRun.START_MACHINES):
		s._toggle_pick(str(id))
	if _pose == "picked":
		return
	s._on_primary()
	for it in r.pool(2):
		if it["kind"] == "component":
			r.components[str(it["id"])] = 1
			break
	r.modules[str(r.db.modules.keys()[0])] = 1
	s._refresh()
	match _pose:
		"chooser":
			var m: QuickRun.Machine = r.roster[0]
			s._open_hardpoint(m.uid, 0, r.db.chassis[m.chassis].get("fixed", []).size())
		"fight":
			s._on_primary()
			s._on_primary()
		"track", "rewards", "over":
			r.start_battle()
			var sk := r.open_fight()
			r.units[0].hull = r.units[0].hull_max / 2
			r.units[1].shield = 1
			sk.outcome = Skirmish.Outcome.VICTORY if _pose != "over" else Skirmish.Outcome.DEFEAT
			sk.state = Skirmish.State.DONE
			r.finish_fight()
			if _pose == "rewards":
				while r.state == QuickRun.BATTLE:
					var next := r.open_fight()
					next.outcome = Skirmish.Outcome.VICTORY
					next.state = Skirmish.State.DONE
					r.finish_fight()
				s._choice = 1
			s._refresh()


## Run `f` `frames` frames on, once the containers have laid out what a pose opened.
func _later(frames: int, f: Callable) -> void:
	for i in range(frames):
		await process_frame
	f.call()


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
