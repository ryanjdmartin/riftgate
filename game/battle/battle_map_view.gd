class_name BattleMapView
extends Control

## The battlefield as a scrolling, touchable map in the overlay style. Draws terrain, the gate
## and the rift, every pack's walk on the enemy's turn and every hunter's lock, the fights a
## hunter forced, the fight being set up, the hexes the selected machine can reach, and the
## units themselves (bible section 4, the round row).
##
## Gestures: drag to scroll; tap a hex (the screen decides what that means); hold a unit for
## its readout; drag from one of the player's machines to draw its route by hand (Ryan, 25
## September), the screen deciding what each hex the finger reaches does to the draft. The
## view owns no game logic.

signal hex_tapped(h: Vector2i)
signal hex_double_tapped(h: Vector2i)
signal unit_held(u: Unit)
signal hold_released
signal route_drag_started(u: Unit)
signal route_drag_to(h: Vector2i)
signal route_drag_ended(commit: bool)

const DOUBLE_TAP_SECONDS := 0.35

const HEX_SIZE := 48.0   # up from 44 (Ryan, 23 September: the map must not get smaller)
const FOCUS_VIEW_H := 898.0   # the map view's height on the 1280 design: the tilt-shift's focus band is laid out for it, whatever the glass adds
const DRAG_THRESHOLD := 12.0
const HOLD_SECONDS := 0.45
const SPRITE_SCALE := 2.0
const TOP_PAD := 8.0
const BOTTOM_PAD := 16.0
const TAG_SIZE := Vector2(60, 58)
const TAG_GAP := 6.0

## Terrain sits well behind the overlay: dim, low-saturation ground.
const TERRAIN := {
	BattleMap.Terrain.PLAIN: Color("2a3628"),
	BattleMap.Terrain.ROAD: Color("46422f"),
	BattleMap.Terrain.ROUGH: Color("3a3824"),
	BattleMap.Terrain.RUINS: Color("393c39"),
	BattleMap.Terrain.WATER: Color("1a2f4a"),
	BattleMap.Terrain.MOUNTAIN: Color("23212a"),
}

var field: Battlefield
var selected: Unit = null
var walks: Dictionary = {}           # pack id -> Battlefield.Walk: where each pack walks on the enemy's turn (the screen keeps it)
var forced: Array = []               # the fights hunters forced, first in line (Battle.forced)
var attack: Dictionary = {}          # the fight shown (Battle.roster) with "committed": the machines in it; empty for none
var orders: Dictionary = {}          # mech id -> the pack it is ordered onto (Battle.orders): drawn as a line to it
var fight_group: Array = []          # the fight being entered: the map freezes on it through the handover
var spent: Dictionary = {}           # machine id -> true: no action left this turn
var flatten_at := Vector2.ZERO       # the handover into a skirmish: one more bleed source, growing
var flatten_r := 0.0                 # its radius in hexes; 0 is none (tweened by the screen)
var destinations: Dictionary = {}    # hexes the selected mech may end on
var threat: Dictionary = {}          # hexes past its move the selected mech may attack from there (Battle.threat_for), in the enemy's violet
var plans: Array = []                # the moves planned and not yet played (Battle.plan_pieces), drawn as routes
var shown: Dictionary = {}           # machine id -> [hex, facing]: where a planned machine stands until its plan plays (Battle.shown_positions)
var scroll_y: float = 0.0            # the map's offset on screen, in pixels
var scroll_x: float = 0.0
var zoom: float = 1.0                # the reconstruction's zoom (Ryan, 21 September); 1 fits the width

const ZOOM_MIN := 1.0
const ZOOM_MAX := 2.6

var _origin := Vector2.ZERO
var _map3d: Map3D = null             # the battlefield's geometry; null only when headless
var _painted: SubViewport = null     # the other world's flat bright map, rendered once
var _painted2: SubViewport = null    # its second frame
var sweep_on := true                 # the scan band; the tuner can stop it
var frame_alpha := 0.5               # the field's boundary lines, the table's frame (Ryan, 21 September)
var _mix: SubViewport = null         # the two worlds mixed by the bleed, screen-sized, drawn under the overlays
var _composite: TextureRect = null   # the rect inside _mix that carries the bleed shader
var _map_size := Vector2.ZERO        # the map in map pixels
var _tags: Array = []                # [[Rect2, Unit], ...] the off-screen portraits, as drawn
var _pressed := false
var _dragged := false
var _holding := false
var _press_pos := Vector2.ZERO
var _last_pos := Vector2.ZERO
var _press_at := 0.0
var _last_tap_at := -10.0
var _last_tap_hex := Vector2i(-9999, -9999)
var _touches: Dictionary = {}       # finger index -> position, for the pinch
var _pinch_d := 0.0                 # the fingers' distance when the pinch last zoomed
var _pinching := false
var route_drawing := false          # the screen allows a route to be drawn from a machine (planning, nothing playing)
var draft: Array = []               # the route being drawn, hexes after the machine's own; the screen keeps it legal
var draft_land: Dictionary = {}     # a carrier's block at the draft's end (Battle.draft_landing): {"to": rider -> hex, "bad": [hexes]}; empty when it carries nobody
var _press_unit: Unit = null        # the player's machine under the finger at press: a drag from it draws
var _route_drag: Unit = null        # the machine whose route is being drawn, while it is
var _draft_hex := Vector2i(-9999, -9999)   # the last hex the finger reported, so a hex is announced once


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST   # zoom scales texels, never blurs them
	set_process(true)   # the scan sweeps every frame; the hold timer rides the same loop


func set_field(f: Battlefield) -> void:
	field = f
	_layout()
	scroll_to_bottom()
	# The battlefield is geometry with the other world bleeding in (decided 19 September):
	# the painted map rendered once, the 3D scene whose ground wears it, and a compositor
	# that mixes the two by the bleed, drawn behind this control's own overlays. Headless
	# runs have no renderer and fall back to the painted map alone.
	if DisplayServer.get_name() != "headless":
		for old in [_painted, _painted2, _map3d, _mix]:
			if old != null:
				old.queue_free()
		var map_size := Vector2(size.x, _map_px_height())
		_map_size = map_size
		_painted = _paint(map_size, 0)
		_painted2 = _paint(map_size, 1)
		# The 3D scene and the compositor are the size of this control, not the map: the
		# camera follows the scroll and zoom, so a frame costs the same at any zoom and the
		# scene runs every frame (sway, ripple, later the movement phase).
		# The scene and the compositor render at the glass's density, so the stretch lands
		# one to one (the fine map: Ryan, 29 September, and always since 30 October; the
		# painted world keeps its pixels, sampled from the design-size paintings). At the
		# design's size the window stretched them 1.5 times on a 1080 phone, nearest, and the
		# machines' edges stepped; the glass's costs 2.25 times the pixels there, at 60 fps.
		var density := _density()
		_map3d = Map3D.new()
		add_child(_map3d)
		_map3d.setup(field, size, _origin, HEX_SIZE, density)
		_mix = SubViewport.new()
		_mix.size = Vector2i((size * density).round())
		_mix.transparent_bg = true
		_mix.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_mix.canvas_item_default_texture_filter = SubViewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		add_child(_mix)
		_composite = TextureRect.new()
		_composite.texture = _map3d.get_texture()
		_composite.size = (size * density).round()
		var mat := ShaderMaterial.new()
		mat.shader = load("res://game/battle/bleed.gdshader")
		mat.set_shader_parameter("painted", _painted.get_texture())
		mat.set_shader_parameter("painted2", _painted2.get_texture())
		mat.set_shader_parameter("units", _map3d.get_units_texture())
		mat.set_shader_parameter("scene_lin", _map3d.get_texture())   # the same two, read linear by the FXAA (Hud.fxaa)
		mat.set_shader_parameter("units_lin", _map3d.get_units_texture())
		mat.set_shader_parameter("fxaa", Hud.fxaa())
		mat.set_shader_parameter("outline_px", Map3D.outline_px() * density)   # the machines' outline, one width at every zoom
		mat.set_shader_parameter("map_size", map_size)
		mat.set_shader_parameter("view_size", size)
		mat.set_shader_parameter("play_x", _frame_x())   # sharp inside the frame's lines, soft outside
		mat.set_shader_parameter("south_y", _origin.y + Hex.to_pixel(field.map.gate, HEX_SIZE).y + HEX_SIZE * 0.75)
		_composite.material = mat
		_mix.add_child(_composite)
	queue_redraw()


## Device pixels per design pixel for the scene and the compositor: the window's stretch.
func _density() -> float:
	return Hud.density(self)


## The other world's painted map, one frame of two, rendered once into a viewport the size
## of the whole map.
func _paint(map_size: Vector2, frame: int) -> SubViewport:
	var vp := SubViewport.new()
	vp.size = Vector2i(map_size)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	vp.canvas_item_default_texture_filter = SubViewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(vp)
	var painted := PaintedMap.new()
	painted.size = map_size
	painted.setup(field, _origin, HEX_SIZE, frame)
	vp.add_child(painted)
	return vp


## A live knob from the map tuner: a compositor uniform by name.
func tune(name: String, value: Variant) -> void:
	if _composite != null:
		(_composite.material as ShaderMaterial).set_shader_parameter(name, value)
	queue_redraw()


func _layout() -> void:
	var px_w := sqrt(3.0) * HEX_SIZE * (field.map.width + 0.5)
	# The scenery rows beyond the rift sit above hex (0,0), so the origin moves down for them.
	_origin = Vector2((size.x - px_w) / 2.0 + sqrt(3.0) * HEX_SIZE / 2.0, HEX_SIZE + TOP_PAD + HEX_SIZE * 1.5 * BattleMap.MARGIN_ROWS)


func _map_px_height() -> float:
	var rows := field.map.height + BattleMap.MARGIN_ROWS + BattleMap.CITY_ROWS
	return HEX_SIZE * (1.5 * (rows - 1) + 2.0) + TOP_PAD + BOTTOM_PAD


## Keep the map covering the view: no bare edge at any zoom. The scroll runs over the
## playable field plus a little of the scenery beyond each end; the rest of the margin
## rows are there to fill the edges, not to scroll to (Ryan, 21 September).
func _clamp_scroll() -> void:
	var top := _origin.y - HEX_SIZE * 3.6                                                  # the scenery past the rift, and the vortex's height
	var bottom := _origin.y + Hex.to_pixel(field.map.gate, HEX_SIZE).y + HEX_SIZE * 2.6   # a row of city past the wall
	scroll_y = clampf(scroll_y, minf(-top * zoom, size.y - bottom * zoom), -top * zoom)
	scroll_x = clampf(scroll_x, minf(0.0, size.x - size.x * zoom), 0.0)


## Start at the gate end, where the player's machines stand.
func scroll_to_bottom() -> void:
	scroll_y = -1.0e9
	_clamp_scroll()


func scroll_to_top() -> void:
	scroll_y = 1.0e9
	_clamp_scroll()


## Map space is the unzoomed, unscrolled map: the composite texture's pixels. The overlays
## are drawn in it under one transform; gestures and popups convert.
func to_screen(p: Vector2) -> Vector2:
	return p * zoom + Vector2(scroll_x, scroll_y)


func to_map(local: Vector2) -> Vector2:
	return (local - Vector2(scroll_x, scroll_y)) / zoom


## The overlay's marks hold their size on screen at every zoom (Ryan, 30 October: "all UI
## overlay type items should hold at one width. It will look better"): a line's width, a
## dash, an inset and a glyph are given in screen pixels and drawn in map space through
## `_px`; a plaque, a gauge and a tag are drawn in screen space at their place on the map.
## What a mark outlines or fills (a hex, a region, a route from hex to hex, a ring sized to
## its hex) stays where it is on the map.
func _px(screen_px: float) -> float:
	return screen_px / zoom


func _map_space() -> void:
	draw_set_transform(Vector2(scroll_x, scroll_y), 0.0, Vector2(zoom, zoom))


func _screen_space() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## The base of a hex in map space: its grid cell before any height. The enemy's marks and
## the packs themselves sit here (Ryan, 22 September: their world is flat, and they
## flatten what they walk on).
func base(h: Vector2i) -> Vector2:
	return _origin + Hex.to_pixel(h, HEX_SIZE)


## Centre of a hex in map space: its grid cell, lifted by the height of its column so the
## overlays stand on the terrain. Under the painting the column is gone and the ground is
## flat, so the lift goes with it (Ryan, 29 September: a pack on flattened ground was
## placed by the height of the geometry the painting had replaced, and its marks with it).
func center(h: Vector2i) -> Vector2:
	return _origin + Hex.to_pixel(h, HEX_SIZE) + Vector2(0, -_lift_at(h))


var _bleed_grad := Vector2.ZERO
var _bleed_src := PackedVector3Array()

## A hex's lift on screen: its column's height where the reconstruction stands, nothing
## where the painting has taken it, with the compositor's own threshold between.
func _lift_at(h: Vector2i) -> float:
	if _map3d == null:
		return 0.0
	var lift := _map3d.lift(h)
	if lift == 0.0:
		return 0.0
	if _bleed_src.is_empty():
		_bleed_grad = Bleed.gradient(field, _origin, HEX_SIZE)
		_bleed_src = Bleed.sources(field, _origin, HEX_SIZE, _anim_px)
	return lift * Bleed.solid(base(h), _bleed_grad, _bleed_src)


## The hex under a screen point. A raised hex's top sits above its cell and covers part of
## the hex north of it, so the candidates' lifted outlines are tested, the southmost (nearest
## the camera) winning.
func hex_at(local: Vector2) -> Vector2i:
	var p := to_map(local)
	var flat := Hex.from_pixel(p - _origin, HEX_SIZE)
	if _map3d == null or field == null:
		return flat
	var best := flat
	var best_row := -1000000
	var cands: Array[Vector2i] = [flat]
	cands.append_array(Hex.neighbors(flat))
	for cand in cands:
		if not field.map.has(cand) or cand.y <= best_row:
			continue
		if Geometry2D.is_point_in_polygon(p, Hex.corners(center(cand), HEX_SIZE)):
			best = cand
			best_row = cand.y
	return best


## The unit a tap on `h` means: a machine standing there on the map (one whose plan has not
## played stands where its plan starts), else whatever the battle has there (a planned
## machine's route end among them).
func unit_at_shown(h: Vector2i) -> Unit:
	if field == null:
		return null
	for uid in shown.keys():
		if shown[uid][0] == h:
			var m := field.unit_by_id(int(uid))
			if m != null:
				return m
	return field.unit_at(h)


## Where a unit stands on the map: a planned machine at its plan's start.
func shown_hex(u: Unit) -> Vector2i:
	return shown[u.id][0] if shown.has(u.id) else u.pos


## Scroll so the unit sits in the middle of the view.
func scroll_to_unit(u: Unit) -> void:
	var p := center(shown_hex(u))
	scroll_x = size.x * 0.5 - p.x * zoom
	scroll_y = size.y * 0.5 - p.y * zoom
	_clamp_scroll()
	queue_redraw()


## Zoom about a screen point, so what is under the finger stays under it.
func zoom_at(local: Vector2, factor: float) -> void:
	var nz := clampf(zoom * factor, ZOOM_MIN, ZOOM_MAX)
	var k := nz / zoom
	scroll_x = local.x - (local.x - scroll_x) * k
	scroll_y = local.y - (local.y - scroll_y) * k
	zoom = nz
	_clamp_scroll()
	queue_redraw()


## Packs outside the visible strip, with the edge tag each gets: [[Rect2, Unit], ...]. Tags
## sit at the top or bottom edge at the pack's x, nudged right when two would overlap, so an
## intent line entering the view has a face at its source.
func offscreen_tags() -> Array:
	var out: Array = []
	if field == null:
		return out
	var rows := {true: [], false: []}
	for sq in field.packs():
		var c := to_screen(center(sq.pos))
		var above := c.y < -HEX_SIZE * 0.3
		var below := c.y > size.y + HEX_SIZE * 0.3
		if not (above or below):
			continue
		rows[above].append([c.x, sq])
	for above in [true, false]:
		var list: Array = rows[above]
		list.sort_custom(func(a, b) -> bool: return a[0] < b[0])
		var next_x := TAG_GAP
		# Under the frame's top readout, or over its bottom one (Ryan, 23 September: the
		# frame belongs to the viewport, so the tags make room for it).
		var y := FRAME_PAD + 24.0 if above else size.y - TAG_SIZE.y - FRAME_PAD - 20.0
		for item in list:
			var x := clampf(item[0] - TAG_SIZE.x * 0.5, TAG_GAP, size.x - TAG_SIZE.x - TAG_GAP)
			x = maxf(x, next_x)
			next_x = x + TAG_SIZE.x + TAG_GAP
			out.append([Rect2(Vector2(x, y), TAG_SIZE), item[1], above])
	return out


func _tag_at(local: Vector2) -> Unit:
	for t in _tags:
		if t[0].has_point(local):
			return t[1]
	return null


## Map sprite id for an enemy: its foe type, or for a boss unit its first commander (a final's
## hero, the finale's line) or the faction's boss.
static func foe_sprite_id(u: Unit) -> String:
	if u.is_boss:
		if not u.lineup.is_empty():
			return str(u.lineup[0])
		var all := ContentDB.load_default().bosses_of(u.faction)
		return all[0] if not all.is_empty() else ""
	return u.foe_id


# ---------------------------------------------------------------- drawing

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Palette.BG)
	if field == null:
		return
	var hud := Palette.HUD
	var map := field.map
	if _map3d != null:
		# The ground, the structures and the mechs are geometry in the 3D viewport, mixed
		# with the painted map by the compositor, both screen-sized and drawn here in screen
		# space; the foes, being pictures from the other world, and every overlay are drawn
		# on top in map space.
		_map3d.look(Vector2(scroll_x, scroll_y), zoom)
		_map3d.held = shown
		_map3d.sync()
		var mat: ShaderMaterial = _composite.material
		var src := Bleed.sources(field, _origin, HEX_SIZE, _anim_px)
		if flatten_r > 0.0 and src.size() < Bleed.MAX_SOURCES:
			src.append(Vector3(flatten_at.x, flatten_at.y, flatten_r * HEX_SIZE))
		_bleed_grad = Bleed.gradient(field, _origin, HEX_SIZE)
		_bleed_src = src.duplicate()   # what the overlays' lifts read this frame (_lift_at)
		mat.set_shader_parameter("grad", _bleed_grad)
		mat.set_shader_parameter("source_count", src.size())
		src.resize(Bleed.MAX_SOURCES)
		mat.set_shader_parameter("sources", src)
		# The focus band is laid out for the design's map height. A taller phone gives its
		# extra height to the map, and measured from the taller view's middle the sharp
		# zone's north edge slid south and the far blur grew to more than twice its height,
		# at full strength (Ryan, 26 September: too tall on the phone, not so on the Mac).
		# Measured from the design's middle it sits where it does on the Mac.
		mat.set_shader_parameter("focus_y", (minf(size.y, FOCUS_VIEW_H) * 0.5 - scroll_y) / zoom)
		mat.set_shader_parameter("scroll", Vector2(scroll_x, scroll_y))
		mat.set_shader_parameter("zoom", zoom)
		var boxes := _map3d.outline_boxes()
		mat.set_shader_parameter("box_count", boxes.size())
		boxes.resize(Map3D.MAX_BOXES)
		mat.set_shader_parameter("boxes", boxes)
		mat.set_shader_parameter("outline_color", Palette.HUD)
		draw_texture_rect(_mix.get_texture(), Rect2(Vector2.ZERO, size), false)
		# Everything from here to the edge tags is drawn in map space under the zoom and
		# scroll. The grid itself is in the scene, lit, so raised ground hides it.
		_map_space()
	else:
		_map_space()
		# Headless: the painted map, so the view still lays out and the structures still show.
		for h in map.all_hexes():
			var pts := Hex.corners(center(h), HEX_SIZE - 1.5)
			draw_colored_polygon(pts, TERRAIN[map.terrain[h]])
			TerrainArt.draw(self, center(h), HEX_SIZE, map.terrain[h], h.x * 131 + h.y * 7919, 0.9)
			Hud.stroke_poly(self, pts, Color(hud, 0.10), _px(1.0))
		for wh in map.wall_hexes:
			draw_colored_polygon(Hex.corners(center(wh), HEX_SIZE - 3.0), Color(Palette.MUTED, 0.35))
		for g in map.gate_hexes:
			var pts := Hex.corners(center(g), HEX_SIZE - 3.0)
			draw_colored_polygon(pts, Color(hud, 0.10))
			Hud.stroke_poly(self, pts, Color(hud, 0.85), _px(2.0))
	_draw_rift(map)

	# Where the selected mech may end its move: every hex alike, lit under one solid edge (Ryan,
	# 28 October: a move is given in one go and the map draws reach and nothing else).
	for h in destinations.keys():
		var pts := Hex.corners(center(h), HEX_SIZE - _px(5.0))
		draw_colored_polygon(pts, Color(hud, 0.26))
		Hud.stroke_poly(self, pts, Color(hud, 0.8), _px(1.5))

	# Where the selected machine could attack from past its move (Ryan, 25 October: "not only its
	# available move spaces, but its available attacking spaces at the edge of that move, in
	# red", the rings' colour, which is the enemy's violet since 30 October): a band round the lit
	# hexes, tinted, under one solid edge, so it reads as one region beside the move's outlined
	# cells (structure as well as hue); a pack it could be ordered onto, in the band or in reach
	# where it stands, bracketed in the violet's bright.
	if not threat.is_empty() and _anim.is_empty():
		for h in threat.keys():
			draw_colored_polygon(Hex.corners(center(h), HEX_SIZE - _px(5.0)), Color(Palette.ENEMY_MAP, 0.26))
		_ring_outline(threat, Palette.ENEMY_MAP, 3.0, false)
		if selected != null:
			for sq in field.packs():
				var hit := false
				for x in sq.hexes():
					hit = hit or threat.has(x) or Hex.distance(x, selected.pos) <= selected.attack_range
				if hit:
					var bc := center(sq.pos)
					Hud.brackets(self, Rect2(bc - Vector2(HEX_SIZE, HEX_SIZE) * 0.9, Vector2(HEX_SIZE, HEX_SIZE) * 1.8), _px(12.0), ENEMY_HOT, _px(3.0))

	# Every pack's ring, the enemy's engagement range: a fight on a hex in it pulls the pack in,
	# and a hunter catches what stands in it (Ryan, 25 October: "always visible, and become more
	# visible when the enemy is tapped, and done in red not hud colour"; in the enemy's violet
	# since 30 October: "keep purple for enemy activities"). At rest a dashed violet edge on a
	# deep-violet track; the pack tapped, or one that would join the fight shown, its ring tinted
	# under a solid edge, heavier.
	if _anim.is_empty() and fight_group.is_empty():
		var lit := {}
		var tapped := field.unit_at(inspected) if map.has(inspected) else null
		if tapped != null and tapped.is_enemy():
			lit[tapped] = true
		for j in attack.get("joins", []):
			lit[j] = true
		for sq in field.packs():
			var ring: Dictionary = {}
			_zone_hexes(sq, sq.pos, ring)
			if lit.has(sq):
				for h in ring.keys():
					_fill(h, Color(Palette.ENEMY_MAP, 0.5))
				_ring_outline(ring, Palette.ENEMY_MAP, 4.5, false, true)
			else:
				_ring_outline(ring, Color(Palette.ENEMY_MAP, 0.85), 2.5, true)

	# The moves planned and not yet played (Ryan, 25 October: "highlight and display the planned
	# move like we used to"): each machine's route in the display's light from where it stands,
	# its lock on the hex its plan ends on, and a carrier's riders' landings outlined. They play
	# on ENGAGE or END TURN.
	if _anim.is_empty() and fight_group.is_empty():
		var last_piece := {}
		for k in range(plans.size()):
			last_piece[int(plans[k]["unit"])] = k
		for k in range(plans.size()):
			var pc: Dictionary = plans[k]
			if (pc["path"] as Array).is_empty():
				continue
			_route(pc["from"], pc["path"], hud, last_piece[int(pc["unit"])] == k)
			for rd in pc["riders"]:
				Hud.stroke_poly(self, Hex.corners(center(rd[3]), HEX_SIZE - _px(6.0)), Color(hud, 0.8), _px(2.5))

	# Where every pack walks on the enemy's turn (bible section 4), from where the machines
	# stand now, and every hunter's lock on its prey; nothing while a move plays or a fight is
	# entered. A fight a hunter forced comes first, so its marks have the map until it is fought.
	var hunted := {}   # prey -> the packs hunting it, for the tags drawn over the units
	if _anim.is_empty() and fight_group.is_empty() and forced.is_empty():
		for sq in field.packs():
			var w: Battlefield.Walk = walks.get(sq.id, null)
			if w == null:
				continue
			if w.prey != 0:
				var prey := field.unit_by_id(w.prey)
				if prey != null:
					if not hunted.has(prey):
						hunted[prey] = []
					(hunted[prey] as Array).append(sq)
			if not w.path.is_empty():
				# The same route mark as the player's (Ryan, 29 September), in steady violet; the
				# colour breathes only on the pack that was tapped.
				_route(sq.pos, w.path, INTENT, false, false, sq.pos == inspected, true)
			var below := center(w.end) + Vector2(0.0, HEX_SIZE * 0.7)
			if w.strikes:
				_plaque(below, "STRIKES THE GATE", Palette.ENEMY, 1.5)
			elif w.waits:
				_plaque(below, "WAITS", Palette.MUTED, 1.5)
			elif w.catches != 0:
				_plaque(below, "CATCHES", Palette.ENEMY, 1.5)

	# The gate selected: its footprint outlined, and the hexes it can be attacked from
	# tinted (Ryan, 29 September: the bar lit alone did not say where the danger stands).
	if gate_selected and _anim.is_empty():
		var attack: Dictionary = {}
		for g in map.gate_hexes:
			for n in Hex.neighbors(g):
				if map.has(n) and not map.is_structure(n):
					attack[n] = true
		# The hexes a pack can strike from read as warning zones (Ryan, 29 September): a violet
		# border crawling round each with a warning glyph at its centre; the gate's own
		# footprint translucent but plain to see, a tint under a half-strength outline.
		var blink := 0.55 + 0.45 * sin(_ring_t * 3.0)   # the glyphs pulse together
		for n in attack.keys():
			_fill(n, Color(Palette.ENEMY_MAP, 0.06))
			_crawl_poly(Hex.corners(center(n), HEX_SIZE - _px(5.5)), Palette.ENEMY_MAP, HEX_SIZE * 0.2, fmod(_ring_t * 1.2, 2.0), ENEMY_EDGE)
			Glyphs.draw(self, "warning", center(n), _px(HEX_SIZE * (0.42 + 0.08 * blink)), Color(ENEMY_HOT, 0.5 + 0.5 * blink), _px(2.5))
		for g in map.gate_hexes:
			# A light tint (ground marks land at alpha to the 2.2, so 0.3 is faint) under
			# lines at a third (Ryan, 29 September).
			_fill(g, Color(hud, 0.3))
			Hud.stroke_poly(self, Hex.corners(center(g), HEX_SIZE - _px(2.0)), Color(hud, 0.35), _px(1.5))

	# A selected machine wears its shield and hull over its hex; an inspected pack its
	# strength as one segment a foe (Ryan, 29 September: a pack keeps only its count between
	# fights, so every segment is whole; per-foe hull would need the pack to remember it).
	if selected != null and _anim.is_empty():
		_unit_gauges(selected)
	var ipack := field.unit_at(inspected) if map.has(inspected) else null
	if ipack != null and ipack.is_enemy() and _anim.is_empty():
		_pack_segments(ipack)

	# The hex a tap asked about: bracketed in the display's light (Ryan, 29 September); a
	# pack there has its route breathing between the violets, drawn in the pack loop.
	if map.has(inspected) and _anim.is_empty():
		var ic := center(inspected)
		Hud.brackets(self, Rect2(ic - Vector2(HEX_SIZE, HEX_SIZE) * 0.95, Vector2(HEX_SIZE, HEX_SIZE) * 1.9), _px(HEX_SIZE * 0.45), Color(hud, 0.95), _px(2.5))

	# The route being drawn by hand: the same line, heavier, ringed where it ends. It never
	# leaves the lit reach, so its end needs no gauge (Ryan, 28 October: a move in one go).
	if _route_drag != null and not draft.is_empty():
		var prev := center(_route_drag.pos)
		for step in draft:
			var p := center(step)
			draw_line(prev, p, hud, _px(5.0))
			prev = p
		Hud.stroke_poly(self, Hex.corners(prev, HEX_SIZE * 0.45), hud, _px(2.5))
		# A carrier's block where it would land (the Swallowtail's carry, Ryan, 21 October): each
		# rider's hex outlined; one it cannot land on dashed and struck through, and the stop
		# itself crossed and tagged, so the player changes it before letting go. By structure,
		# never by hue alone (Ryan is colourblind), and heavy, for the phone.
		var bad: Array = draft_land.get("bad", [])
		var lands: Dictionary = draft_land.get("to", {})
		for r in lands.keys():
			var lh: Vector2i = lands[r]
			var pts := Hex.corners(center(lh), HEX_SIZE - _px(6.0))
			if bad.has(lh):
				for i in range(6):
					_dashed_line(pts[i], pts[(i + 1) % 6], Palette.LOSS, HEX_SIZE * 0.16)
				_strike(center(lh), HEX_SIZE * 0.42, Palette.LOSS)
			else:
				Hud.stroke_poly(self, pts, hud, _px(3.0))
		if not bad.is_empty():
			# The stop is no move: struck through and tagged.
			_strike(prev, HEX_SIZE * 0.42, Palette.LOSS)
			_plaque(prev + Vector2(0.0, -HEX_SIZE * 1.0), "NO ROOM", Palette.LOSS, 2.5)

	# The fights hunters forced (bible section 5): the hunter and its prey lit, the prey
	# tagged; they come first on the player's turn.
	if _anim.is_empty() and fight_group.is_empty():
		for f in forced:
			var prey: Unit = f["prey"]
			for h in f["hunters"]:
				_contact_effect((h as Unit).pos, true, true)
			Hud.brackets(self, Rect2(center(prey.pos) - Vector2(HEX_SIZE, HEX_SIZE) * 0.9, Vector2(HEX_SIZE, HEX_SIZE) * 1.8), _px(12.0), Palette.ENEMY_MAP, _px(3.0))
			_plaque(center(prey.pos) + Vector2(0.0, -HEX_SIZE * 1.05), "CAUGHT", Palette.ENEMY, 2.0)
	# The orders (bible section 5): a line from each machine to the pack it is ordered onto, in
	# the display's light, dashes crawling toward the pack.
	if _anim.is_empty() and fight_group.is_empty():
		for uid in orders.keys():
			var m := field.unit_by_id(int(uid))
			var target: Unit = orders[uid]
			if m == null or target == null or not field.units.has(target):
				continue
			var a := center(m.pos)
			var b := center(target.pos)
			var dir := (b - a).normalized()
			a += dir * HEX_SIZE * 0.55
			b -= dir * HEX_SIZE * 0.6
			draw_line(a, b, Color(hud, 0.35), _px(6.0))
			_dashed_line(a, b, hud, HEX_SIZE * 0.2, fmod(_ring_t * 2.0, 2.0))
			var side := Vector2(-dir.y, dir.x)
			draw_polyline(PackedVector2Array([b - dir * _px(10.0) + side * _px(8.0), b, b - dir * _px(10.0) - side * _px(8.0)]), hud, _px(3.0))
	# The fight shown (bible section 5): the next one ENGAGE opens, the one a dragged machine
	# is over, or a pack looked at. The attack range round the target in the display's light
	# (where a machine must stand to join), every joining pack's ring in the enemy's, the packs
	# in it lit, the machines in it bracketed.
	if not attack.is_empty() and _anim.is_empty():
		var targets: Array = attack.get("targets", [])
		# Where a machine must stand to join, in the display's light; a pack looked at with
		# nothing in hand shows its own ring instead (above), the selected machine's violet band
		# saying where it could attack from (Ryan, 25 October).
		if not bool(attack.get("inspect", false)):
			var reach: Dictionary = {}
			for t in targets:
				_zone_hexes(t, (t as Unit).pos, reach, _attack_reach())
			for h in reach.keys():
				_fill(h, Color(hud, 0.28))   # hot: on a phone every mark has come back wanting more
			_region_outline(reach, hud, 3.0)
		var group: Array = targets + attack.get("joins", [])
		for u in group:
			_contact_effect((u as Unit).pos, true, true)
		for m in attack.get("committed", []):
			var c := center((m as Unit).pos)
			Hud.brackets(self, Rect2(c - Vector2(HEX_SIZE, HEX_SIZE) * 0.9, Vector2(HEX_SIZE, HEX_SIZE) * 1.8), _px(12.0), hud, _px(3.0))
		if not targets.is_empty():
			_plaque(center((targets[0] as Unit).pos) + Vector2(0.0, -HEX_SIZE * 1.05), "FIGHT // " + contact_text(attack.get("committed", []) + group), Palette.ENEMY, 2.0)
	# The fight being entered: frozen on its units through the handover.
	if not fight_group.is_empty():
		for u in fight_group:
			_contact_effect((u as Unit).pos, true, (u as Unit).is_enemy())
	# A machine with no action left this turn says so.
	if _anim.is_empty():
		for m in field.mechs():
			if spent.has(m.id):
				_plaque(_unit_center(m) + Vector2(0.0, HEX_SIZE * 0.7), "SPENT", Palette.MUTED, 1.5)

	for u in field.units:
		_draw_unit(u)
	for prey in hunted.keys():
		_hunted_tag(prey, hunted[prey])

	if selected != null:
		var c := _unit_center(selected)
		Hud.brackets(self, Rect2(c - Vector2(HEX_SIZE, HEX_SIZE) * 0.85, Vector2(HEX_SIZE, HEX_SIZE) * 1.7), _px(12.0), hud, _px(2.0))

	_screen_space()   # from here, screen space
	# The HUD's own marks (the frame, the bars, their text) are drawn in screen space at
	# their positions under the zoom, so they stay crisp and their lines stay thin however
	# far the reconstruction is zoomed (Ryan, 22 September).
	if _map3d != null and frame_alpha > 0.0:
		_draw_frame(hud)
	_draw_gate_bar()
	_draw_rift_bar()
	_draw_tags()
	if _map3d != null:
		_map3d.set_marks(_ground_marks)
		_ground_marks = []
	# The whole battlefield is a projection, the same one as the skirmish's backdrop: its
	# faint scanlines and its soft band drifting down, over everything, foes and overlays
	# too (Ryan, 21 September).
	Hud.scanlines(self, Rect2(Vector2.ZERO, size))


## The frame: two boundary lines in the display's light, a tick on every row's centre with
## the row's number, and a readout at each end, so the field has a viewfinder's edge and
## the blur runs into it. The frame belongs to the viewport, not the map (Ryan, 23
## September): its lines stand at the view's edges through every scroll and zoom, its
## readouts sit at the view's top and bottom, and only the ticks and numbers ride the map.
## The numbers sit inside the lines, the same distance in on both sides. A row's tick
## stands level with the top of the hex beside it (the row's edge hex on that side), since
## the 3D ground is the display's native and a raised row sits higher on screen (Ryan,
## 23 September). The readouts sit on plaques, so they read over the painted world too.
## Screen space.
const FRAME_PAD := 8.0
const FRAME_SIDE := 14.0   # the lines' distance in from the view's left and right
const FRAME_FONT := 14

func _draw_frame(hud: Color) -> void:
	var map := field.map
	var fc := Color(hud, frame_alpha)
	var font := Hud.mono()
	var top := FRAME_PAD
	var bottom := size.y - FRAME_PAD
	var label_w := font.get_string_size("00", HORIZONTAL_ALIGNMENT_LEFT, -1, FRAME_FONT).x
	for sx in [FRAME_SIDE, size.x - FRAME_SIDE]:
		var dir := 1.0 if sx < size.x * 0.5 else -1.0
		draw_line(Vector2(sx, top), Vector2(sx, bottom), fc, 2.0)
		for row in range(map.height - BattleMap.GATE_ROWS):
			var edge := Hex.offset_to_axial(0 if dir > 0.0 else map.width - 1, row)
			var y := to_screen(Vector2(0, center(edge).y)).y
			if y < top + 30.0 or y > bottom - 30.0:
				continue   # under the readouts
			draw_line(Vector2(sx, y), Vector2(sx + 10.0 * dir, y), fc, 2.0)
			var label := "%02d" % (map.height - BattleMap.GATE_ROWS - row)   # counted up from the gate
			var lx: float = (sx + 14.0) if dir > 0.0 else (sx - 14.0 - label_w)
			draw_string(font, Vector2(lx, y + 5.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, FRAME_FONT, fc)
		for y in [top, bottom]:
			draw_line(Vector2(sx, y), Vector2(sx + 18.0 * dir, y), fc, 2.0)
	_readout(font, Vector2(FRAME_SIDE + 8.0, top + 19.0), "SEC %02d // %s // RECON" % [map.map_seed % 100, BattleMap.KINDS[map.kind]["name"]], fc)
	_readout(font, Vector2(FRAME_SIDE + 8.0, bottom - 8.0), "CARE // PROJECTOR LINE", fc)


## A readout on its own dark plaque.
func _readout(font: Font, at: Vector2, text: String, fc: Color) -> void:
	var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FRAME_FONT).x
	draw_rect(Rect2(at.x - 5.0, at.y - 15.0, tw + 10.0, 20.0), Color(Palette.BG, 0.5), true)   # faint: it is not real information (Ryan, 23 September)
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, FRAME_FONT, fc)


## A HUD bar in screen space: a backing, a track, a fill, a rim, a label above on its own
## dark plaque, so it reads on any ground, the rift's included (Ryan, 23 September).
const BAR_FONT := 14

func _hud_bar(map_pos: Vector2, map_w: float, frac: float, col: Color, label: String, a: float = 1.0) -> Rect2:
	var p := to_screen(map_pos)
	var rect := Rect2(p.x - map_w * zoom * 0.5, p.y, map_w * zoom, 12.0)
	var font := Hud.mono()
	var tw := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, BAR_FONT).x
	draw_rect(Rect2(rect.position.x - 3.0, rect.position.y - 22.0, tw + 10.0, 20.0), Color(Palette.BG, 0.85), true)
	draw_rect(rect.grow(3.0), Color(Palette.BG, 0.85), true)
	draw_rect(rect, Color(col, 0.18 * a), true)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * frac, rect.size.y)), Color(col, a), true)
	draw_rect(rect.grow(3.0), Color(col, 0.7 * a), false, 1.5)
	draw_string(font, Vector2(rect.position.x + 2.0, rect.position.y - 7.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, BAR_FONT, Color(col, a))
	return rect


## The gate's integrity as a true bar (Ryan, 22 September), on the wall's face under the
## gate, always; brighter while the gate is selected.
var gate_selected := false
var inspected := Vector2i(-9999, -9999)   # the hex a tap asked about (a pack, the ground): lit while its readout is up

func _draw_gate_bar() -> void:
	var map := field.map
	var at := _origin + Hex.to_pixel(map.gate, HEX_SIZE) + Vector2(0, -HEX_SIZE * 1.5 * (BattleMap.GATE_ROWS - 0.5) + 26.0)
	var frac := float(field.gate_hp) / maxf(1.0, float(field.gate_hp_max))
	var col := Palette.HUD if frac > 0.34 else Palette.LOSS
	var rect := _hud_bar(at, HEX_SIZE * 3.2, frac, col, "GATE %d/%d" % [field.gate_hp, field.gate_hp_max], 1.0 if gate_selected else 0.8)
	if gate_selected:
		Hud.brackets(self, rect.grow(10.0), 8.0, col, 2.0)


## The rift's pressure as a bar toward the next spawn (Ryan, 22 September), above the rift
## in the scenery rows, where the boss standing in front of the rift never covers it.
func _draw_rift_bar() -> void:
	var at := _origin + Hex.to_pixel(field.map.rift, HEX_SIZE) + Vector2(0, -HEX_SIZE * 2.7)
	var frac := float(field.rift_pressure) / maxf(1.0, float(field.rift_pressure_max))
	_hud_bar(at, HEX_SIZE * 3.2, frac, RIFT_ART, "NEXT SPAWN IN %d" % (field.rift_pressure_max - field.rift_pressure))


## The one scan bar crosses the whole screen on the top layer (the battle screen draws it);
## it tells the map where it is, in this control's pixels, and the traces under it light.
func sweep_at(local_y: float) -> void:
	if _map3d != null:
		_map3d.set_sweep((local_y - scroll_y) / zoom if sweep_on else -1.0e6)


static var RIFT_ART := Color("c9a6ff")   # what the rift looks like; it means nothing but the rift
const RIFT_FRAME_SECONDS := 0.7    # a frame, on the vortex's own clock
const RIFT_ON_BEAT := false        # true: one turn of the strip is a bar of the music instead (Ryan, 23 September: an option, off for now)
const RIFT_TEAR_ROWS := 16         # the bands the vortex is drawn in, for its tear

## The rift (Ryan, 23 September): a vortex tearing a hole in reality, in the foes' own
## register, standing over its three hexes and reaching up into the scenery, its spiral
## turning a little and back. The hexes under it are the hole's floor. Without the art,
## the old outline.
func _draw_rift(map: BattleMap) -> void:
	for r in map.rift_hexes:
		draw_colored_polygon(Hex.corners(center(r), HEX_SIZE - 3.0), Color("140a1f"))
	var tex := Sprites.rift()
	if tex == null:
		for r in map.rift_hexes:
			Hud.stroke_poly(self, Hex.corners(center(r), HEX_SIZE - 3.0), RIFT_ART, _px(2.0))
		return
	var fh := tex.get_size().y
	var frames := maxi(1, int(round(tex.get_size().x / fh)))   # square frames side by side
	var fw := tex.get_size().x / frames
	# On its own slow clock; or, with RIFT_ON_BEAT, one turn of the strip is a bar of the
	# music, four beats, however many frames it holds (it had landed near the beat by
	# chance once, and Ryan liked it, then wanted it slower).
	var beat := Sound.beat() if RIFT_ON_BEAT else -1.0
	var k := int(beat / 4.0 * frames if beat >= 0.0 else _ring_t / RIFT_FRAME_SECONDS) % frames
	var c := center(map.rift)
	var dest := Rect2((c - Vector2(fw * SPRITE_SCALE * 0.5, fh * SPRITE_SCALE - HEX_SIZE * 0.9)).floor(), Vector2(fw, fh) * SPRITE_SCALE)
	# The vortex is the worst input the display gets: it is drawn in bands, and now and
	# then one tears sideways and dims, the same tear the compositor gives the ground
	# around it (Ryan, 23 September; a band in five each tick was far too much). Off with
	# the glitch setting.
	if not bool(Settings.display.get("glitch", true)):
		draw_texture_rect_region(tex, dest, Rect2(k * fw, 0, fw, fh))
		return
	var tick := floorf(_ring_t * 5.0)   # a tear holds a fifth of a second
	var rows := RIFT_TEAR_ROWS
	var band_h := fh / rows
	# Never more than two bands torn at once, and most ticks none (Ryan, 23 September):
	# the tick draws how many, then which, from the mouth's bands (the tendrils over the
	# hexes never tear: it read too low).
	var roll: float = fmod(absf(sin(tick * 7.31 + 3.7) * 43758.5453), 1.0)
	var count := 0 if roll < 0.7 else (1 if roll < 0.92 else 2)
	var torn_bands := {}
	for i in range(count):
		var pick: float = fmod(absf(sin(tick * 5.19 + float(i) * 2.9 + 1.3) * 27183.1), 1.0)
		torn_bands[int(pick * rows * 0.7)] = true
	# The shear jitters every few frames while a tear holds, as the map's does.
	var sub := floorf(_ring_t * 16.0)
	for b in range(rows):
		var torn: bool = torn_bands.has(b)
		var jitter: float = fmod(absf(sin(float(b) * 4.13 + tick * 3.37 + sub * 1.7 + 5.5) * 15731.3), 1.0)
		var shear := (jitter - 0.5) * 6.0 * SPRITE_SCALE if torn else 0.0
		var src := Rect2(k * fw, b * band_h, fw, band_h)
		var dst := Rect2(dest.position + Vector2(shear, b * band_h * SPRITE_SCALE), Vector2(fw, band_h) * SPRITE_SCALE)
		draw_texture_rect_region(tex, dst, src, Color(1, 1, 1, 1) if not torn else Color(0.55, 0.55, 0.68, 1.0))   # dimmed hard: at 0.82 only the shear showed (Ryan, 23 September)


## Off-screen packs get a portrait at the edge nearest them: the source of the intent line.


## A number on a dark plaque with a coloured border: legible on any tile, and the colour
## carries the side without asking coloured text to survive the ground.
## A cross through a hex's middle, on its own dark ground so it reads on any terrain: a stop
## or a landing that cannot be taken.
func _strike(c: Vector2, r: float, col: Color) -> void:
	for d in [Vector2(1, 1), Vector2(1, -1)]:
		var v: Vector2 = d.normalized() * r
		draw_line(c - v, c + v, Color(Palette.BG, 0.9), _px(9.0))
		draw_line(c - v, c + v, col, _px(5.0))


## A plaque at a map point `at`, drawn in screen space there so it holds its size at every zoom.
func _plaque(at: Vector2, text: String, border: Color, thick: float = 1.5) -> void:
	_screen_space()
	var w := Hud.mono().get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 10.0
	var rect := _plaque_rect(to_screen(at), Vector2(w, 18.0))
	draw_rect(rect, Palette.BG, true)
	draw_rect(rect, border, false, thick)
	draw_string(Hud.mono(), rect.position + Vector2(5.0, 13.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	_map_space()


## A plaque's rect centred on the screen point `at`, kept inside the view's width so a plaque
## never runs off the screen.
func _plaque_rect(at: Vector2, sz: Vector2) -> Rect2:
	var x := clampf(at.x, 4.0 + sz.x * 0.5, size.x - 4.0 - sz.x * 0.5) if size.x - 8.0 > sz.x else at.x
	return Rect2(Vector2(x, at.y) - sz * 0.5, sz)


func _draw_tags() -> void:
	_tags = offscreen_tags()
	for t in _tags:
		var rect: Rect2 = t[0]
		var sq: Unit = t[1]
		var above: bool = t[2]
		var border := Palette.ENEMY
		Hud.box(self, rect, 6.0, Color(Palette.BG, 0.94), Color(border, 0.9), 1.5)
		if sq.is_boss:
			Hud.box(self, rect.grow(-4.0), 4.0, Color(0, 0, 0, 0), Color(border, 0.9), 1.5)   # a double border says boss
		var c := rect.position + Vector2(rect.size.x * 0.5, 24.0)
		var tex := Sprites.map_foe(foe_sprite_id(sq))
		if tex != null:
			var ts := tex.get_size()
			var s := minf(2.0, floorf(36.0 / maxf(ts.x, ts.y)))
			s = maxf(1.0, s)
			ts *= s
			draw_texture_rect(tex, Rect2((c - ts * 0.5).floor(), ts), false)
		else:
			var r := 12.0
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)]), border)
			draw_string(Hud.mono(), c + Vector2(-4.0, 5.0), sq.display_name.substr(0, 1).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.BG)
		var label := "BOSS" if sq.is_boss else "×%d" % sq.strength
		draw_string(Hud.mono(), rect.position + Vector2(0, rect.size.y - 6.0), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 12, Palette.INK)
		# A chevron on the outer edge, pointing the way to the pack.
		var mid := rect.position.x + rect.size.x * 0.5
		var edge_y := rect.position.y - 1.0 if above else rect.end.y + 1.0
		var dir := -1.0 if above else 1.0
		draw_colored_polygon(PackedVector2Array([Vector2(mid - 6.0, edge_y), Vector2(mid + 6.0, edge_y), Vector2(mid, edge_y + 6.0 * dir)]), border)


## The effects, told apart by motion (Ryan, 22 September: a red outline alone never reads
## against this ground, so tint the hex and move something). A pack's destination: a
## tinted hex with a target of concentric rings breathing inside it. A contact: a heavier
## tint that pulses, a thick outline, and rings bursting out past the hex's edge, again and
## again. Dimmed when another contact is the one being looked at.
var _ring_t := 0.0

var _ground_marks: Array = []   # {hex, fill, edges, line} this frame, handed to the scene after the draw

## A hex's tint: on the ground in the scene, under the machines, when there is a scene;
## drawn flat when headless.
func _fill(h: Vector2i, col: Color) -> void:
	if _map3d != null:
		_mark(h)["fill"] = col
	else:
		draw_colored_polygon(Hex.corners(center(h), HEX_SIZE - 3.0), col)


## Some of a hex's edges (corner i to i+1) as a line on the ground, the same way.
func _edges(h: Vector2i, idx: Array, col: Color) -> void:
	if _map3d != null:
		var m := _mark(h)
		m["edges"] = idx
		m["line"] = col
	else:
		var pts := Hex.corners(center(h), HEX_SIZE - 1.0)
		for i in idx:
			draw_line(pts[i], pts[(i + 1) % 6], col, _px(2.0))


func _mark(h: Vector2i) -> Dictionary:
	for m in _ground_marks:
		if m["hex"] == h:
			return m
	var m := {"hex": h, "fill": Color(0, 0, 0, 0), "edges": [], "line": Color(0, 0, 0, 0)}
	_ground_marks.append(m)
	return m


const DEST_RING := HEX_SIZE * 0.58   # the target's outer ring
# A pack's intent in the rift's register (Ryan, 29 September: they are rift units, so
# violet, which nothing else on the field uses but the rift itself): the route, its target
# and the tapped pack's pulse. Since 30 October the contact, the gate's warning zones and the
# tags wear the violet too (Ryan: "keep purple for enemy activities"): the warning parts from
# the plan by its structure, a ring of dashed hex edges against a line, its target and stripes.
# Picked by simulation, not by eye (Ryan is colourblind, 29 September): each colour's
# worst-case Lab distance from every HUD option and the enemy red under protan, deutan and
# tritan vision. The rest sits 60 from its nearest neighbour (the blue HUD, deutan), the
# bright 36; the rift's own pale (c9a6ff) was 7 from the blue HUD and a paler lavender 1,
# so the pulse never goes that far, and plum went toward the red under red-green vision.
# Two violets in all (Ryan, 30 September): the light one is the route's line and the field's
# bright; the deep one is the line's crawling gaps and the field's dark.
static var INTENT := Color("c8a4ff")       # a pack's route at rest, and the field's bright (L 73; Ryan, 30 September: room left on the phone; the striped structure carries it now, not the hue)
static var INTENT_HOT := Color("c8a4ff")   # the same
static var INTENT_DEEP := Color("6a30c0")  # the field's dark and the line's gaps (up again, Ryan, 30 September: it blended into the dark tiles)
static var INTENT_PALE := Color("d0b8ff")  # the top of the tapped pack's pulse, briefly
static var INTENT_DARK := Color("2a0e4a")  # the bottom of the tapped pack's pulse for the dark
static var INTENT_DIM := Color("9a68e0")   # the bottom of the pulse for the light: under its resting value (Ryan, 30 September)
static var INTENT_EDGE := Color("2a0e4a")  # the edge, if RIFTGATE_INTENT_EDGE puts it on

# The pair the field and the line draw with right now: the constants for a pack at rest,
# both lifted together on the tapped pack so the whole mark pulses (Ryan, 30 September:
# the pulse had been on the line alone).
var _field_hot: Color = INTENT_HOT
var _field_deep: Color = INTENT_DEEP

func _set_intent_pair(breathe: bool) -> void:
	var b := _intent_breath() if breathe else 0.0
	if not breathe:
		_field_hot = INTENT_HOT
		_field_deep = INTENT_DEEP
		return
	# The tapped pack swings the whole way: down to the old dark, up to the pale.
	_field_hot = INTENT_DIM.lerp(INTENT_PALE, b)
	_field_deep = INTENT_DARK.lerp(INTENT_DEEP.lerp(INTENT_HOT, 0.5), b)
## Whether the intent marks wear that edge at all (Ryan, 30 September: trying them without);
## RIFTGATE_INTENT_EDGE=1 puts it back for a comparison. The solid line and its deep-violet
## crawling gaps stay either way: the gaps are the motion, the edge was only the contrast.
static func _intent_edged() -> bool:
	return OS.get_environment("RIFTGATE_INTENT_EDGE") == "1"
static var ENEMY_HOT := Color("ecdcff")    # the contact's bright: the violet paled, a breath that shows in every vision (ΔE 12 to 17 from the violet, docs/measurements.md)
static var ENEMY_EDGE := Color("2a0e4a")   # the edge under every violet line and border: deep violet, not black (Ryan, 29 September: black made candy canes)

## The tapped pack's intent breathes between violet and the rift's pale, most of the way up
## and never quite down to the deep, so on any ground it passes through a colour that reads.
## The intent field (Ryan, 30 September): a hidden static map of diagonal stripes in the
## deep and the bright violet, which the rings, the target's border and the route's dashes
## sample as they pass over it. A striped mark is another kind of thing from the HUD's
## single-colour lines, so the whole range of violets can show at once. The stripes stand
## still for a pack at rest and crawl for the tapped one.
const STRIPE := HEX_SIZE * 0.9   # one stripe's width in map pixels: near a hex each (Ryan, 30 September: longer still)
const STRIPE_DIR := Vector2(0.8, 0.6)   # the stripes run across this direction

## The stripe coordinate of a map point: the stripes are the integer steps of this.
func _stripe_u(p: Vector2, phase: float) -> float:
	return p.dot(STRIPE_DIR) / STRIPE + phase


func _intent_at(p: Vector2, phase: float) -> Color:
	# Hard stripes (Ryan, 30 September: the hard boundary is what the line uses and it
	# looks good); what has to be exact is where the boundary falls, below.
	return _field_hot if floori(_stripe_u(p, phase)) % 2 == 0 else _field_deep


## A straight piece in the field's colours, split exactly where the stripes change rather
## than at fixed steps (Ryan, 30 September: a piece that could only be one colour snapped
## the boundary to its own length).
func _field_line(a: Vector2, b: Vector2, phase: float, width: float) -> void:
	var u0 := _stripe_u(a, phase)
	var u1 := _stripe_u(b, phase)
	var lo := minf(u0, u1)
	var hi := maxf(u0, u1)
	var cuts: Array[float] = [0.0]
	var k := floorf(lo) + 1.0
	while k < hi:
		cuts.append((k - u0) / (u1 - u0))
		k += 1.0
	cuts.append(1.0)
	cuts.sort()
	for i in range(cuts.size() - 1):
		var p0 := a.lerp(b, cuts[i])
		var p1 := a.lerp(b, cuts[i + 1])
		if p0.distance_squared_to(p1) > 0.01:
			draw_line(p0, p1, _intent_at((p0 + p1) * 0.5, phase), width)


## The target lock's three broken rings over a static field of spokes about the target
## (Ryan, 30 September: over the diagonal stripes a turning ring crossed a boundary at a
## pace that changed round the ring and reversed at the tangents, which read as the map
## moving underneath). Over spokes a ring turning at a steady rate crosses one every so
## many degrees, forward, always. Each arc is split exactly at the spokes. Sixteen, not
## twelve (Ryan, 30 September: with twelve the inner ring's three dashes, 120 degrees
## apart, crossed spokes in step and the whole ring blinked), and each ring's spokes turned
## a third of a spoke from the last, so no two dashes anywhere change colour together.
const SPOKES := 6   # sixty degrees a spoke (neither ring's dash spacing, 72 and 51 degrees, is a multiple of it, so no ring blinks in step)

func _field_rings(c: Vector2, r: float, dir: float, _phase: float, width: float = 3.0) -> void:
	var step := TAU / SPOKES
	# Two rings (Ryan, 30 September: the innermost of three was noise), the outer a little
	# farther out: [radius as a share of r, dashes, turning rate, direction].
	for k in range(2):
		var spec: Array = [[0.62, 5, 0.75, -1.0], [1.0, 7, 0.5, 1.0]][k]
		var rad: float = r * spec[0]
		var segs: int = spec[1]
		var a0: float = _ring_t * dir * spec[2] * spec[3]
		for sgm in range(segs):
			var a := a0 + TAU * float(sgm) / float(segs)
			var b := a + TAU / float(segs) * 0.6
			var turn := step * float(k) / 3.0   # this ring's spokes, turned from the last ring's
			var cuts: Array[float] = [a, b]
			var m := floorf((a - turn) / step) + 1.0
			while m * step + turn < b:
				cuts.append(m * step + turn)
				m += 1.0
			cuts.sort()   # without this the first pair was the dash's own ends and the rest were skipped as backwards: one colour a dash, flipping (the blink)
			for q in range(cuts.size() - 1):
				var b0: float = cuts[q]
				var b1: float = cuts[q + 1]
				if b1 - b0 < 0.002:
					continue
				var colour := _field_hot if posmod(floori(((b0 + b1) * 0.5 - turn) / step), 2) == 0 else _field_deep
				draw_arc(c, rad, b0, b1, maxi(2, int((b1 - b0) * rad * zoom / 3.0) + 1), colour, _px(width))


func _intent_breath() -> float:
	return 0.5 + 0.5 * sin(_ring_t * 2.0)   # a touch quicker than the contact's 1.6 (Ryan, 30 September: halfway back from 2.4)


## The contact marks breathe between the violet and its pale (Ryan, 22 September, of the red then).
func _ring_colour() -> Color:
	var breath := 0.5 + 0.5 * sin(_ring_t * 1.6)
	return Palette.ENEMY_MAP.lerp(ENEMY_HOT, 0.35 + 0.65 * breath)



## Three rings of broken arcs turning against each other: the display's own target lock.
func _target_rings(c: Vector2, col: Color, r: float, dir: float, width: float = 3.0) -> void:
	for k in range(3):
		var rad := r * (0.42 + 0.29 * k)
		var segs := 3 + k * 2
		var a0 := _ring_t * dir * (1.0 - 0.25 * k) * (1.0 if k % 2 == 0 else -1.0)
		for sgm in range(segs):
			var a := a0 + TAU * float(sgm) / float(segs)
			draw_arc(c, rad, a, a + TAU / float(segs) * 0.6, 10, col, width)


## Under a machine's own destination marker: two faint rings breathing, in the display's
## light, so the plan's ends read as the same language as the enemy's, quieter.
func _ally_target(c: Vector2, col: Color) -> void:
	var breath := 0.5 + 0.5 * sin(_ring_t * 2.5)
	for k in range(2):
		var r := HEX_SIZE * (0.3 + 0.22 * k) * (0.9 + 0.1 * breath)
		draw_arc(c, r, 0.0, TAU, 32, Color(col, 0.4 - 0.12 * k), 1.5)


func _contact_effect(h: Vector2i, lit: bool, _at_base: bool = false) -> void:
	var c := center(h)
	var a := 1.0 if lit else 0.35
	var breath := 0.5 + 0.5 * sin(_ring_t * 4.0)
	_fill(h, Color(Palette.ENEMY_MAP, (0.7 + 0.25 * breath) * a))
	Hud.stroke_poly(self, Hex.corners(c, HEX_SIZE - _px(3.0)), Color(Palette.ENEMY_MAP, a), _px(2.5))
	var col := _ring_colour()
	for k in range(2):
		var phase := fmod(_ring_t * 0.9 + k * 0.5, 1.0)
		var r := HEX_SIZE * (0.3 + 1.1 * phase)
		draw_arc(c, r, 0.0, TAU, 40, Color(col, (1.0 - phase) * a), _px(3.0 * (1.0 - phase * 0.5) + 1.0))


## A route, either side's (Ryan, 29 September): a quiet line with dashes crawling toward
## the destination and a chevron a step, no dark edge. It leaves from the edge of the unit's
## hex rather than its centre, so it never draws across the machine or the pack. `lock`
## puts the target on its end: the display's rings turning and a dashed border crawling
## round the hex.
func _route(from: Vector2i, path: Array, col: Color, lock: bool, from_edge: bool = true, breathe: bool = true, edged: bool = false) -> void:
	# A machine's route leaves from its hex's edge, so it never crosses the machine; a
	# pack's comes out of the sprite (Ryan, 29 September). An edged route (the enemy's)
	# is a solid saturated line on a dark edge with the dashes bright over it: contrast
	# both ways on any ground; a machine's stays the quiet line with no edge.
	var pts: PackedVector2Array = [center(from).lerp(center(path[0]), 0.5) if from_edge else center(from)]
	for step in path:
		pts.append(center(step))
	if edged:
		# One violet line: the light violet, and the motion as deep-violet gaps crawling along
		# it, so nothing alternates between two bright colours.
		_set_intent_pair(breathe)   # the tapped pack's whole mark pulses: line, gaps, rings, border
		col = _field_hot
		if _intent_edged():
			draw_polyline(pts, INTENT_EDGE, _px(7.0))
		draw_polyline(pts, col, _px(3.5))
		# The moving dashes over the line stay one dark colour (Ryan, 30 September: the field
		# on them made the line itself look striped); the field is for the rings and border.
		for i in range(pts.size() - 1):
			_dashed_line(pts[i], pts[i + 1], _field_deep, HEX_SIZE * 0.22, fmod(_ring_t * 2.0, 2.0) + 1.0)
	else:
		draw_polyline(pts, Color(col, 0.5), _px(3.0))
		for i in range(pts.size() - 1):
			_dashed_line(pts[i], pts[i + 1], col, HEX_SIZE * 0.22, fmod(_ring_t * 2.0, 2.0))
	# A chevron a step, pointing the way (edged too, on the enemy's).
	for i in range(pts.size() - 1):
		var dir := (pts[i + 1] - pts[i]).normalized()
		var tip := pts[i].lerp(pts[i + 1], 0.55)
		var side := Vector2(-dir.y, dir.x)
		var k := _px(6.0)
		var chev := PackedVector2Array([tip - dir * k + side * k, tip, tip - dir * k - side * k])
		if edged and _intent_edged():
			draw_polyline(chev, INTENT_EDGE, _px(5.0))
		draw_polyline(chev, col, _px(2.5))
	if not lock:
		return
	var end := pts[pts.size() - 1]
	# An enemy route's rings pulse in the line's own register (the selected pack's whole
	# route breathes together, Ryan, 29 September); a machine's lift toward white.
	var bright := col if edged else (col.lerp(Color.WHITE, 0.25 + 0.25 * sin(_ring_t * 1.6)) if breathe else col)
	if edged:
		# The rings and the target's border in the field's stripes (crawling on the tapped pack).
		var phase := 0.0   # the field never moves (Ryan, 30 September: a crawl under turning rings read as the map sliding); the pulse is the selection
		if _intent_edged():
			_field_rings(end, DEST_RING, -1.0, phase, 6.0)
		_field_rings(end, DEST_RING, -1.0, phase)
		draw_circle(end, _px(3.5), col)
		_crawl_poly(Hex.corners(end, HEX_SIZE - _px(5.5)), Color(0, 0, 0, 0), HEX_SIZE * 0.2, fmod(_ring_t * 1.5, 2.0), INTENT_EDGE if _intent_edged() else Color(0, 0, 0, 0), phase)   # just inside the hex lines (Ryan, 30 September)
		return
	# A machine's target lock in the same construction (Ryan, 30 September), over the same
	# fields, in its line's two colours: the display's light, and the light at half.
	_field_hot = bright
	_field_deep = Color(bright, 0.5)
	_field_rings(end, DEST_RING, -1.0, 0.0)
	draw_circle(end, _px(3.5), bright)
	_crawl_poly(Hex.corners(end, HEX_SIZE - _px(5.5)), Color(0, 0, 0, 0), HEX_SIZE * 0.2, fmod(_ring_t * 1.5, 2.0))   # just inside the hex lines (Ryan, 30 September)


## A closed outline drawn as dashes that crawl round it: `offset` in dashes, dash and gap
## both `dash` screen pixels long.
func _crawl_poly(pts: PackedVector2Array, col: Color, dash: float, offset: float, edge: Color = Color(0, 0, 0, 0), phase: float = 0.0) -> void:
	var per := 0.0
	for i in range(pts.size()):
		per += pts[i].distance_to(pts[(i + 1) % pts.size()])
	var n := maxi(2, int(per / _px(dash)) & ~1)
	var step := per / n
	for pass_i in range(2 if edge.a > 0.0 else 1):
		var k := -2.0 + offset
		while k < n:
			var d0 := maxf(0.0, k * step)
			var d1 := minf(per, (k + 1.0) * step)
			if d1 > d0:
				_poly_segment(pts, d0, d1, edge if pass_i == 0 and edge.a > 0.0 else col, 5.0 if pass_i == 0 and edge.a > 0.0 else 2.5, phase)
			k += 2.0


## The stretch of a closed outline between distances `d0` and `d1` along it, `width` screen
## pixels wide. `col` at zero alpha means the intent field's colours, at `phase`.
func _poly_segment(pts: PackedVector2Array, d0: float, d1: float, col: Color, width: float = 2.5, phase: float = 0.0) -> void:
	var walked := 0.0
	for i in range(pts.size()):
		var a := pts[i]
		var b := pts[(i + 1) % pts.size()]
		var len := a.distance_to(b)
		var s0 := clampf(d0 - walked, 0.0, len)
		var s1 := clampf(d1 - walked, 0.0, len)
		if s1 > s0:
			if col.a == 0.0:
				_field_line(a.lerp(b, s0 / len), a.lerp(b, s1 / len), phase, _px(width))
			else:
				draw_line(a.lerp(b, s0 / len), a.lerp(b, s1 / len), col, _px(width))
		walked += len


## A dashed line from `a` to `b`, dash and gap both `dash` screen pixels long and the line
## `width`, the pattern shifted along by `offset` dashes so it can crawl.
func _dashed_line(a: Vector2, b: Vector2, col: Color, dash: float, offset: float = 0.0, phase: float = 0.0, width: float = 3.0) -> void:
	var n := maxi(1, int(a.distance_to(b) / _px(dash)))
	var k := -2.0 + fmod(offset, 2.0)
	while k < n:
		var t0 := clampf(k / n, 0.0, 1.0)
		var t1 := clampf((k + 1.0) / n, 0.0, 1.0)
		if t1 > t0:
			if col.a == 0.0:   # the intent field's colours
				_field_line(a.lerp(b, t0), a.lerp(b, t1), phase, _px(width))
			else:
				draw_line(a.lerp(b, t0), a.lerp(b, t1), col, _px(width))
		k += 2.0


## A hunted machine wears a tag hovering by it (Ryan, 25 October: not the orange target under
## it, "a tag hovering by the unit with the hunter's portrait (probably cropped) and some kind
## of target symbol"): one plate a hunter, up and left of the machine, clear of its gauges,
## each the hunter's map picture trimmed to what is drawn and a target turning beside it, in
## the enemy's register.
const HUNT_TAG := Vector2(66.0, 40.0)   # the picture at twice its pixels, the target beside it

func _hunted_tag(prey: Unit, hunters: Array) -> void:
	_screen_space()
	var right := to_screen(_unit_center(prey) + Vector2(-HEX_SIZE * 0.72, -HEX_SIZE * 0.95))   # the first plate's right edge, clear of a selected machine's gauges
	for k in range(hunters.size()):
		var sq: Unit = hunters[k]
		var rect := Rect2(right + Vector2(-HUNT_TAG.x - k * (HUNT_TAG.x + 4.0), -HUNT_TAG.y * 0.5), HUNT_TAG)
		draw_rect(rect.grow(2.0), Color(ENEMY_EDGE, 0.9), true)
		draw_rect(rect, Color(Palette.BG, 0.95), true)
		draw_rect(rect, Palette.ENEMY, false, 2.5)
		var face := Rect2(rect.position + Vector2(4.0, 4.0), Vector2(HUNT_TAG.y - 8.0, HUNT_TAG.y - 8.0))
		var tex := Sprites.map_foe(foe_sprite_id(sq))
		if tex != null:
			var used := Sprites.used_rect(tex)
			var s := maxf(1.0, floorf(face.size.y / maxf(used.size.x, used.size.y)))
			var sz := used.size * s
			draw_texture_rect_region(tex, Rect2((face.get_center() - sz * 0.5).floor(), sz), used)
		else:
			draw_string(Hud.mono(), face.position + Vector2(6.0, 17.0), sq.display_name.substr(0, 1).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.ENEMY)
		_target_mark(Vector2(rect.end.x - 14.0, rect.get_center().y), 10.0)
		# A tick from the first plate toward the machine, so the tag reads as its.
		if k == 0:
			var tip := Vector2(rect.end.x + 6.0, rect.end.y + 6.0)
			draw_colored_polygon(PackedVector2Array([Vector2(rect.end.x - 10.0, rect.end.y), Vector2(rect.end.x, rect.end.y - 8.0), tip]), Palette.ENEMY)
	_map_space()


## The target: a ring of three dashes turning, four ticks closing on a hot centre.
func _target_mark(c: Vector2, r: float) -> void:
	for k in range(3):
		var a := _ring_t * 1.6 + TAU * float(k) / 3.0
		draw_arc(c, r, a, a + TAU / 3.0 * 0.62, 8, ENEMY_HOT, 2.0)
	for d in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		draw_line(c + d * (r * 0.35), c + d * (r * 0.8), Palette.ENEMY_MAP, 2.0)
	draw_circle(c, 1.8, ENEMY_HOT)


## The hexes within a unit's ring of its anchor at `anchor` (a pack's own, or `radius`):
## pure hex distance from any of its footprint hexes, structures left out of the region but
## not of the count.
func _zone_hexes(sq: Unit, anchor: Vector2i, region: Dictionary, radius: int = -1) -> void:
	var r := sq.zone if radius < 0 else radius
	for o in sq.footprint:
		var seed: Vector2i = anchor + o
		var dist := {seed: 0}
		var queue: Array[Vector2i] = [seed]
		while not queue.is_empty():
			var h: Vector2i = queue.pop_front()
			if field.map.has(h) and not field.map.is_structure(h):
				region[h] = true
			if int(dist[h]) >= r:
				continue
			for n in Hex.neighbors(h):
				if not dist.has(n):
					dist[n] = int(dist[h]) + 1
					queue.append(n)


## The edge of a region of hexes drawn over the map, heavy enough for the phone: each edge whose
## far side is outside the region, on a deep-violet track, solid or dashed, and with `crawl` the
## contact's bright dashes crawling along it; no edge against the map's end. Corner i to i+1
## faces DIRECTIONS[(6 - i) % 6], as on the ground (_region_outline).
func _ring_outline(region: Dictionary, col: Color, width: float, dashed: bool, crawl: bool = false) -> void:
	for h in region.keys():
		var nb := Hex.neighbors(h)
		var pts := Hex.corners(center(h), HEX_SIZE - _px(2.5))
		for i in range(6):
			var across: Vector2i = nb[(6 - i) % 6]
			if region.has(across) or not field.map.has(across):
				continue
			var a := pts[i]
			var b := pts[(i + 1) % 6]
			draw_line(a, b, Color(ENEMY_EDGE, minf(1.0, col.a + 0.1)), _px(width + 3.0))
			if dashed:
				_dashed_line(a, b, col, HEX_SIZE * 0.17, 0.0, 0.0, width)
			else:
				draw_line(a, b, col, _px(width))
			if crawl:
				_dashed_line(a, b, ENEMY_HOT, HEX_SIZE * 0.2, fmod(_ring_t * 2.0, 2.0), 0.0, width * 0.5)


## One outline round the outside of a region of hexes, on the ground so the units standing
## in it hide it. Corner i to corner i+1 of a pointy hex (corners from -30 degrees) faces
## the direction at 60i degrees, which is DIRECTIONS[(6 - i) % 6]; the edges whose far side
## is outside the region make the outline. No edge against the map's end.
func _region_outline(region: Dictionary, col: Color, _thick: float) -> void:
	for h in region.keys():
		var nb := Hex.neighbors(h)
		var edges: Array = []
		for i in range(6):
			var across: Vector2i = nb[(6 - i) % 6]
			if not region.has(across) and field.map.has(across):
				edges.append(i)
		if not edges.is_empty():
			_edges(h, edges, col)


## A selected machine's shield and hull as two gauges floating over its hex.
func _unit_gauges(u: Unit) -> void:
	_screen_space()
	var c := to_screen(_unit_center(u) + Vector2(0.0, -HEX_SIZE * 1.05))
	var w := HEX_SIZE * 1.3   # a hex's width at zoom 1, held at every zoom
	var r := Rect2(c.x - w * 0.5, c.y - 12.0, w, 6.0)
	for pair in [[u.shield, u.shield_max, Palette.SHIELD], [u.hull, u.hull_max, Palette.HULL]]:
		draw_rect(r.grow(1.5), Color(Palette.BG, 0.9))
		draw_rect(r, Color(pair[2], 0.25))
		draw_rect(Rect2(r.position, Vector2(r.size.x * clampf(float(pair[0]) / maxf(1.0, float(pair[1])), 0.0, 1.0), r.size.y)), pair[2])
		r.position.y += 9.0
	_map_space()


## An inspected pack's strength: one segment a foe, so a pack thinned by a fight reads
## thinner than a fresh one.
func _pack_segments(p: Unit) -> void:
	_screen_space()
	var n := maxi(1, p.strength)
	var c := to_screen(center(p.pos) + Vector2(0.0, -HEX_SIZE * 1.05))
	var w := HEX_SIZE * 1.3   # a hex's width at zoom 1, held at every zoom
	var gap := 2.0
	var seg := (w - gap * (n - 1)) / n
	var x := c.x - w * 0.5
	draw_rect(Rect2(x - 1.5, c.y - 13.5, w + 3.0, 9.0), Color(Palette.BG, 0.9))
	for i in range(n):
		draw_rect(Rect2(x, c.y - 12.0, seg, 6.0), Palette.ENEMY)
		x += seg + gap
	_map_space()


func _dotted_poly(pts: PackedVector2Array, col: Color, dash: float) -> void:
	for i in range(pts.size()):
		var a := pts[i]
		var b := pts[(i + 1) % pts.size()]
		var n := int(a.distance_to(b) / dash)
		for k in range(0, n, 2):
			draw_line(a.lerp(b, float(k) / n), a.lerp(b, float(k + 1) / n), col, 2.0)


## The contact being looked at in the contact panel: its hexes, so the others dim.
var _highlight: Dictionary = {}

func set_highlight(hexes: Array) -> void:
	_highlight.clear()
	for h in hexes:
		_highlight[h] = true
	queue_redraw()


## Zoom to `z` and centre a map point, for the contact panel's look at a fight.
func focus_on(p: Vector2, z: float) -> void:
	zoom = clampf(z, ZOOM_MIN, ZOOM_MAX)
	scroll_x = size.x * 0.5 - p.x * zoom
	scroll_y = size.y * 0.5 - p.y * zoom
	_clamp_scroll()
	queue_redraw()


## "Badger + Sparrowhawk vs ghouls ×6 + necromancers ×3": one contact group, in words.
static func contact_text(group: Array) -> String:
	var mechs: Array[String] = []
	var packs: Array[String] = []
	for u in group:
		if u.is_player():
			mechs.append(str(u.display_name))
		else:
			packs.append("%s ×%d" % [u.display_name, u.strength] if u.strength > 0 else str(u.display_name).to_upper())
	return " + ".join(mechs) + " vs " + " + ".join(packs)


## The fight's words with the ground it is fought on (decided 22 September).
func contact_label(group: Array, ends: Dictionary = {}) -> String:
	var ground_h: Vector2i = Battle.ground_hex(group)
	if ends.has((group[0] as Unit).id):
		for u in group:
			if u.is_enemy():
				ground_h = ends[u.id]
				break
	var t: int = field.map.terrain.get(ground_h, BattleMap.Terrain.PLAIN)
	return "%s // %s" % [contact_text(group), str(BattleMap.TERRAIN_NAMES.get(t, "plain")).to_upper()]


## The frame's left and right lines in map pixels: the field plus a little, and the line
## the side blur begins at.
func _frame_x() -> Vector2:
	# Close on the play area, so the blur runs on outside it (Ryan, 23 September).
	var hex_w := sqrt(3.0) * HEX_SIZE
	var left := _origin.x - hex_w * 0.5 - HEX_SIZE * 0.22
	return Vector2(left, left + hex_w * (field.map.width + 0.5) + HEX_SIZE * 0.44)


## The widest attack range on the team: the ring drawn round a target.
func _attack_reach() -> int:
	var best := 0
	for m in field.mechs():
		best = maxi(best, m.attack_range)
	return best


# ---------------------------------------------------------------- the movement phase

const MOVE_SECONDS_PER_HEX := 0.22   # the packs' step: the fastest anything moves (Ryan, 22 September); they are pictures with nothing to show
## A machine's step at full speed, seconds a hex, by its move in hexes (Ryan, 5 October: the
## walkers plod better at the third pass's pace, but the moves of 2 and 3 want to be slower and
## 4 and 5 faster, so the pace is a table rather than one step slowed in proportion; keyed by
## hexes since 28 October, every machine at the pace it had). Between the keys it runs
## straight; past the ends it holds.
const MECH_PACE := {1: 2.8, 2: 1.9, 3: 1.25, 4: 0.55, 5: 0.42, 6: 0.36}
static var pace := 1.0               # the player's setting: seconds per hex are divided by it
const MOVE_REF_SPEED := 5.0          # the packs' reference, in hexes: a pack this quick takes MOVE_SECONDS_PER_HEX a hex, slower ones slower


## Seconds a hex at full speed for a machine of move `move` (MECH_PACE).
static func mech_seconds_per_hex(move: float) -> float:
	var keys: Array = MECH_PACE.keys()
	keys.sort()
	if move <= float(keys[0]):
		return float(MECH_PACE[keys[0]])
	for i in range(1, keys.size()):
		if move <= float(keys[i]):
			var a := float(keys[i - 1])
			var b := float(keys[i])
			return lerpf(float(MECH_PACE[keys[i - 1]]), float(MECH_PACE[keys[i]]), (move - a) / (b - a))
	return float(MECH_PACE[keys[keys.size() - 1]])
var _anim: Dictionary = {}      # unit id -> {path, t, curve: MovePath, hex: the step reached}
var _anim_queue: Array = []     # [[moves], ...] phases still to play: mechs, then packs
var _anim_done: Callable = Callable()


## The plan as phases to play (Ryan, 25 October: the planned moves animate on ENGAGE or END
## TURN, and the fight opens once they have): every piece in the first phase it may play in,
## after its own machine's earlier piece (a rider's included) and after any piece that left a
## hex it walks into or sets a rider down on, since it was planned into the room that move
## made. Each move in play_phases' form, with where it leaves its machine and its riders.
static func plan_phases(pieces: Array) -> Array:
	var wave_of: Array[int] = []
	var phases: Array = []
	for k in range(pieces.size()):
		var p: Dictionary = pieces[k]
		var mine := _piece_units(p)
		var enters := {}
		for h in p["path"]:
			enters[h] = true
		for r in p["riders"]:
			enters[r[3]] = true
		var w := 0
		for j in range(k):
			var q: Dictionary = pieces[j]
			var after := enters.has(q["from"])
			for uid in _piece_units(q):
				after = after or mine.has(uid)
			for r in q["riders"]:
				after = after or enters.has(r[1])
			if after:
				w = maxi(w, wave_of[j] + 1)
		wave_of.append(w)
		while phases.size() <= w:
			phases.append([])
		var path: Array = [p["from"]]
		path.append_array(p["path"])
		var riders: Array = []
		var rider_lands := {}
		for r in p["riders"]:
			riders.append([r[0], r[1]])
			rider_lands[r[0]] = [r[3], r[2]]
		phases[w].append([p["unit"], path, riders, [path[path.size() - 1], p["to_facing"]], rider_lands])
	return phases


static func _piece_units(p: Dictionary) -> Dictionary:
	var out := {int(p["unit"]): true}
	for r in p["riders"]:
		out[int(r[0])] = true
	return out


func is_playing() -> bool:
	return not _anim.is_empty() or not _anim_queue.is_empty()


## Play the phase's moves: the mechs along their routes, then the packs along their
## intents, then `done`. Each move is [unit id, Array of hexes from start to end].
## A machine's move may carry riders, [uid, path, [[rider id, the hex it rode from], ...]]: the
## Swallowtail's ring (Ryan, 21 October), each rider riding the carrier's curve at the offset it
## stood at, so the block travels as one and lands where the engine set it down.
func play_moves(mech_moves: Array, pack_moves: Array, done: Callable) -> void:
	play_phases([mech_moves, pack_moves], done)


## Play phases of moves one after another, then `done`: each phase a list of moves played
## together, [unit id, Array of hexes from start to end, riders], a move's riders
## [[rider id, the hex it rode from, ...], ...]. A move may carry where it leaves its unit
## standing, [..., riders, [end hex, facing], {rider id: [hex, facing]}], so a planned machine
## with more of its plan still to play stands there between its pieces (`shown`).
func play_phases(phases: Array, done: Callable) -> void:
	_anim_queue = phases.duplicate()
	_anim_done = done
	# Everyone who will move starts where they were, this frame, so nobody blinks to the
	# end and rewinds (Ryan, 22 September); the packs wait there while the mechs play. A unit
	# that moves in more than one phase starts where its first move does, and a planned
	# machine stands where its plan starts already (`shown`).
	for moves in _anim_queue:
		for mv in moves:
			var path: Array = mv[1]
			if path.size() >= 2 and not _anim_px.has(mv[0]) and not shown.has(mv[0]):
				var px: Vector2 = Hex.to_pixel(path[0], HEX_SIZE)
				_anim_px[mv[0]] = px
				if _map3d != null:
					_map3d.set_anim(mv[0], px, Vector2.ZERO)
			for rd in (mv[2] if mv.size() >= 3 else []):
				if _anim_px.has(rd[0]) or shown.has(rd[0]):
					continue
				var rpx: Vector2 = Hex.to_pixel(rd[1], HEX_SIZE)
				_anim_px[rd[0]] = rpx
				if _map3d != null:
					_map3d.set_anim(rd[0], rpx, Vector2.ZERO)
	_next_anim_phase()


func _next_anim_phase() -> void:
	_anim.clear()
	while not _anim_queue.is_empty() and _anim.is_empty():
		var moves: Array = _anim_queue.pop_front()
		for mv in moves:
			if (mv[1] as Array).size() >= 2:
				var riders: Array = []
				for rd in (mv[2] if mv.size() >= 3 else []):
					riders.append([rd[0], Hex.to_pixel(rd[1], HEX_SIZE) - Hex.to_pixel(mv[1][0], HEX_SIZE)])
				_anim[mv[0]] = {"path": mv[1], "t": 0.0, "curve": _curve_for(mv[0], mv[1]), "hex": 0, "riders": riders,
					"lands": mv[3] if mv.size() >= 4 else [], "rider_lands": mv[4] if mv.size() >= 5 else {}}
				# On its way: the animation has it now, from where it stood.
				shown.erase(mv[0])
				var start_px: Vector2 = Hex.to_pixel(mv[1][0], HEX_SIZE)
				_anim_px[mv[0]] = start_px
				if _map3d != null:
					_map3d.set_anim(mv[0], start_px, Vector2.ZERO)
				for rd in riders:
					shown.erase(rd[0])
					_anim_px[rd[0]] = start_px + (rd[1] as Vector2)
					if _map3d != null:
						_map3d.set_anim(rd[0], start_px + (rd[1] as Vector2), Vector2.ZERO)
	if _anim.is_empty():
		for uid in _anim_px.keys():
			if _map3d != null:
				_map3d.clear_anim(uid)
		_anim_px.clear()
		shown.clear()   # every plan has played: each machine stands where the battle has it
		var cb := _anim_done
		_anim_done = Callable()
		if cb.is_valid():
			cb.call()
	queue_redraw()


## A move as a curve with a speed along it (MovePath). A machine takes its own step and its
## acceleration from its rig sidecar through the 3D map; the packs keep the old straight
## hex-to-hex lines at their fixed step. Slower units move slower either way.
func _curve_for(uid: int, path: Array) -> MovePath:
	var u := field.unit_by_id(uid)
	var centres: Array = path.map(func(h): return Hex.to_pixel(h, HEX_SIZE))
	var step_px := Hex.to_pixel(Vector2i(0, 0), HEX_SIZE).distance_to(Hex.to_pixel(Hex.DIRECTIONS[0], HEX_SIZE))
	var slow := maxf(1.0, MOVE_REF_SPEED / maxf(1.0, float(u.movespeed if u != null else MOVE_REF_SPEED)))
	if u != null and u.is_player():
		var mv: Dictionary = _map3d.motion_of(uid) if _map3d != null else {}
		var top := step_px / mech_seconds_per_hex(float(u.movespeed))
		var mp := MovePath.build(centres, top, float(mv.get("accel", MovePath.ACCEL_DEFAULT)))
		if _map3d != null and centres.size() >= 2:
			mp.hold_start(_map3d.setoff_seconds(uid, (centres[1] as Vector2) - (centres[0] as Vector2)))   # it turns onto its way first (the twentieth notes)
		return mp
	return MovePath.build(centres, step_px / (MOVE_SECONDS_PER_HEX * slow), 0.001, false)


func _advance_anim(delta: float) -> void:
	var finished: Array = []
	for uid in _anim.keys():
		var a: Dictionary = _anim[uid]
		var curve: MovePath = a["curve"]
		a["t"] += delta * pace
		if a["t"] >= curve.duration:
			finished.append(uid)
			continue
		var here: Array = curve.at(a["t"])
		var step_px := Hex.to_pixel(Vector2i(0, 0), HEX_SIZE).distance_to(Hex.to_pixel(Hex.DIRECTIONS[0], HEX_SIZE))
		var hex := int(floor(float(here[3]) / step_px + 0.5))
		if hex != int(a["hex"]):
			a["hex"] = hex
			if field.unit_by_id(uid) != null and field.unit_by_id(uid).is_player():
				Sound.play(Sound.step_for(field.unit_by_id(uid).traits), 0.0, 0.1)   # a footfall a hex by the way it moves (quiet by its file); the packs are pictures and make none
		var px: Vector2 = here[0]
		_anim_px[uid] = px
		if _map3d != null:
			var t := float(a["t"])
			var over := float(_map3d.motion_of(uid).get("oversteer", 0.0))   # a drifter looks further ahead, over a longer stretch (Map3D.oversteer_ease)
			var w := Map3D.oversteer_window(over) * 0.5
			var ah := Map3D.oversteer_ahead(over)
			var tp := Map3D.oversteer_ease(over)   # its stretch tapered, the middle counting most (the fourteenth notes)
			_map3d.set_anim(uid, px, here[1], curve.chord_tapered(t + ah, w, tp), curve.chord_tapered(t, w, tp))
		# Its riders ride the same curve at their offsets, facing its way.
		for rd in a.get("riders", []):
			var rpx: Vector2 = px + (rd[1] as Vector2)
			_anim_px[rd[0]] = rpx
			if _map3d != null:
				_map3d.set_anim(rd[0], rpx, here[1])
	for uid in finished:
		# A planned machine stands where this piece left it while the rest of its plan waits.
		var lands: Array = (_anim[uid] as Dictionary).get("lands", [])
		if lands.size() >= 2:
			shown[uid] = lands
		var rider_lands: Dictionary = (_anim[uid] as Dictionary).get("rider_lands", {})
		for rd in (_anim[uid] as Dictionary).get("riders", []):
			_anim_px.erase(rd[0])
			if rider_lands.has(rd[0]):
				shown[rd[0]] = rider_lands[rd[0]]
			if _map3d != null:
				_map3d.clear_anim(rd[0])
		_anim.erase(uid)
		_anim_px.erase(uid)
		if _map3d != null:
			_map3d.clear_anim(uid)
	if _anim.is_empty() and not _anim_queue.is_empty() or (_anim.is_empty() and _anim_done.is_valid()):
		_next_anim_phase()


var _anim_px: Dictionary = {}   # unit id -> map pixel offset from hex (0,0) while moving


func _unit_center(u: Unit) -> Vector2:
	if _anim_px.has(u.id):
		var px: Vector2 = _anim_px[u.id]
		var under := Hex.from_pixel(px, HEX_SIZE)
		return _origin + px + Vector2(0, -_lift_at(under))
	return center(shown_hex(u))


func _draw_unit(u: Unit) -> void:
	var hud := Palette.HUD
	if u.is_multi_hex():
		for h in u.hexes():
			draw_colored_polygon(Hex.corners(center(h), HEX_SIZE - 6.0), Color("4a2e66"))
	var c := _unit_center(u)
	var tex: Texture2D = null if u.is_player() else Sprites.map_foe(foe_sprite_id(u))
	if _map3d != null and u.is_player() and not u.is_static():
		pass   # a mech is geometry in the 3D viewport; the gauge below stays
	elif tex != null:
		# A foe is a flat picture on the screen, never an object in the scene: no shadow, no
		# base, no lighting. It is the other world showing through (decided 19 September).
		# A small foe draws a little larger than its pixels, so it holds its own beside a mech.
		var ts := tex.get_size() * SPRITE_SCALE * (1.3 if u.is_enemy() and not u.is_multi_hex() else 1.0)
		draw_texture_rect(tex, Rect2((c - Vector2(ts.x * 0.5, ts.y - 22.0)).floor(), ts), false)   # its feet 22 px below the hex's centre: a little lower toward the centre (Ryan, 29 September)
	elif u.is_player():
		draw_circle(c, 17.0, Palette.BG)
		draw_circle(c, 14.0, Palette.INK)
		var d: Vector2 = Hex.to_pixel(Hex.DIRECTIONS[u.facing], 1.0).normalized()
		draw_line(c, c + d * 22.0, Palette.SELECT, 3.0)
	else:
		var r := 20.0 if u.is_multi_hex() else 14.0
		var diamond := PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)])
		draw_colored_polygon(diamond, Palette.ENEMY)
		if u.is_multi_hex():
			# A boss is the big diamond with a second, inset outline: shape and size, not a colour.
			var inner := PackedVector2Array([c + Vector2(0, -r + 6.0), c + Vector2(r - 6.0, 0), c + Vector2(0, r - 6.0), c + Vector2(-r + 6.0, 0)])
			Hud.stroke_poly(self, inner, Palette.BG, 2.0)
		draw_string(Hud.mono(), c + Vector2(-5.0, 5.0), u.display_name.substr(0, 1).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.BG)
	# No gauge over a mech: shield and hull read in the docked readout when it is tapped
	# (Ryan, 21 September), where the contrast is under control.
	if u.is_enemy() and u.strength > 0:
		_plaque(c + Vector2(28.0, -30.0), "×%d" % u.strength, Palette.ENEMY, 3.0 if u.is_boss else 1.5)   # up and right, clear of the picture


# ---------------------------------------------------------------- gestures

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pressed = true
			_dragged = false
			_holding = false
			_press_pos = event.position
			_last_pos = event.position
			_press_at = Time.get_ticks_msec() / 1000.0
			# A press on one of the player's machines may become a route drawn from it.
			_press_unit = null
			if route_drawing and field != null and _tag_at(event.position) == null:
				var pu := unit_at_shown(hex_at(event.position))
				if pu != null and pu.is_player() and not pu.is_static():
					_press_unit = pu
		else:
			if _route_drag != null:
				_route_drag = null
				route_drag_ended.emit(true)
			elif _holding:
				hold_released.emit()
			elif _pressed and not _dragged and field != null:
				if _tag_at(event.position) == null:   # the edge tags only inform; no jump (Ryan, 21 September)
					var h := hex_at(event.position)
					if field.map.has(h):
						var now := Time.get_ticks_msec() / 1000.0
						if h == _last_tap_hex and now - _last_tap_at < DOUBLE_TAP_SECONDS:
							_last_tap_at = -10.0
							hex_double_tapped.emit(h)
						else:
							_last_tap_at = now
							_last_tap_hex = h
							hex_tapped.emit(h)
			_pressed = false
			_holding = false
			_press_unit = null
		accept_event()
	elif event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		zoom_at(event.position, 1.15 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.15)
		accept_event()
	elif event is InputEventMagnifyGesture:
		zoom_at(event.position, event.factor)   # a trackpad's pinch
		accept_event()
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		# The pinch, from the fingers themselves: the same on Android and in a browser
		# (the web never sends a magnify gesture). The first finger also arrives as the
		# mouse; while two are down it neither scrolls nor taps.
		if event is InputEventScreenTouch and not event.pressed:
			_touches.erase(event.index)
		else:
			_touches[event.index] = event.position
		if _touches.size() >= 2:
			var pts: Array = _touches.values()
			var d: float = (pts[0] as Vector2).distance_to(pts[1])
			var mid: Vector2 = ((pts[0] as Vector2) + (pts[1] as Vector2)) * 0.5
			if not _pinching:
				_pinching = true
				_pressed = false
				_holding = false
				_press_unit = null
				if _route_drag != null:   # a second finger cancels the draft rather than zooming it
					_route_drag = null
					route_drag_ended.emit(false)
			elif _pinch_d > 1.0:
				zoom_at(mid, d / _pinch_d)
			_pinch_d = d
		elif _pinching and _touches.size() < 2:
			_pinching = false
			_pressed = false
		if _touches.size() >= 2 or _pinching:
			accept_event()
	elif event is InputEventMouseMotion and _pressed and not _pinching:
		if _holding and (_press_unit == null or event.position.distance_to(_press_pos) <= DRAG_THRESHOLD):
			accept_event()   # a hold stays a hold; a hold on a machine that then moves draws
			return
		if not _dragged and event.position.distance_to(_press_pos) > DRAG_THRESHOLD:
			_dragged = true
			if _press_unit != null:
				# Not a scroll: a route drawn from the machine under the finger.
				if _holding:
					_holding = false
					hold_released.emit()
				_route_drag = _press_unit
				_draft_hex = _route_drag.pos
				route_drag_started.emit(_route_drag)
		if _dragged and _route_drag != null:
			var h := hex_at(event.position)
			if h != _draft_hex and field.map.has(h):
				_draft_hex = h
				route_drag_to.emit(h)
			queue_redraw()
		elif _dragged:
			scroll_x += event.position.x - _last_pos.x
			scroll_y += event.position.y - _last_pos.y
			_clamp_scroll()
			_last_pos = event.position
			queue_redraw()
		accept_event()


func _process(delta: float) -> void:
	_ring_t += delta
	if not _anim.is_empty():
		_advance_anim(delta)
	if _map3d != null:
		queue_redraw()   # the scene is alive under the overlays
	if _pressed and not _dragged and not _holding and Time.get_ticks_msec() / 1000.0 - _press_at >= HOLD_SECONDS:
		_holding = true
		if field != null:
			var u := unit_at_shown(hex_at(_press_pos))
			if u != null:
				unit_held.emit(u)
