class_name BattleMapView
extends Control

## The battlefield as a scrolling, touchable map in the overlay style. Draws terrain, the gate
## and the rift, every squad's previewed move, the routes the player has plotted, the hexes
## the selected mech can reach, and the units themselves.
##
## Gestures: drag to scroll; tap a hex (the screen decides what that means); hold a unit for
## its readout. The view owns no game logic.

signal hex_tapped(h: Vector2i)
signal hex_double_tapped(h: Vector2i)
signal unit_held(u: Unit)
signal hold_released

const DOUBLE_TAP_SECONDS := 0.35

const HEX_SIZE := 48.0   # up from 44 (Ryan, 23 September: the map must not get smaller)
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
var routes: Dictionary = {}          # mech id -> Array[Vector2i]
var selected: Unit = null
var pending: Array = []              # contact groups waiting to be fought: the map freezes on them
var flatten_at := Vector2.ZERO       # the handover into a skirmish: one more bleed source, growing
var flatten_r := 0.0                 # its radius in hexes; 0 is none (tweened by the screen)
var destinations: Dictionary = {}    # hexes the selected mech may end on
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
		_map3d = Map3D.new()
		add_child(_map3d)
		_map3d.setup(field, size, _origin, HEX_SIZE)
		_mix = SubViewport.new()
		_mix.size = Vector2i(size)
		_mix.transparent_bg = true
		_mix.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_mix.canvas_item_default_texture_filter = SubViewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		add_child(_mix)
		_composite = TextureRect.new()
		_composite.texture = _map3d.get_texture()
		_composite.size = size
		var mat := ShaderMaterial.new()
		mat.shader = load("res://game/battle/bleed.gdshader")
		mat.set_shader_parameter("painted", _painted.get_texture())
		mat.set_shader_parameter("painted2", _painted2.get_texture())
		mat.set_shader_parameter("units", _map3d.get_units_texture())
		mat.set_shader_parameter("map_size", map_size)
		mat.set_shader_parameter("view_size", size)
		mat.set_shader_parameter("play_x", _frame_x())   # sharp inside the frame's lines, soft outside
		mat.set_shader_parameter("south_y", _origin.y + Hex.to_pixel(field.map.gate, HEX_SIZE).y + HEX_SIZE * 0.75)
		_composite.material = mat
		_mix.add_child(_composite)
	queue_redraw()


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


## The base of a hex in map space: its grid cell before any height. The enemy's marks and
## the squads themselves sit here (Ryan, 22 September: their world is flat, and they
## flatten what they walk on).
func base(h: Vector2i) -> Vector2:
	return _origin + Hex.to_pixel(h, HEX_SIZE)


## Centre of a hex in map space: its grid cell, lifted by the height of its column so the
## overlays stand on the terrain.
func center(h: Vector2i) -> Vector2:
	var lift := _map3d.lift(h) if _map3d != null else 0.0
	return _origin + Hex.to_pixel(h, HEX_SIZE) + Vector2(0, -lift)


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


## Scroll so the unit sits in the middle of the view.
func scroll_to_unit(u: Unit) -> void:
	var p := center(u.pos)
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


## Squads outside the visible strip, with the edge tag each gets: [[Rect2, Unit], ...]. Tags
## sit at the top or bottom edge at the squad's x, nudged right when two would overlap, so an
## intent line entering the view has a face at its source.
func offscreen_tags() -> Array:
	var out: Array = []
	if field == null:
		return out
	var rows := {true: [], false: []}
	for sq in field.squads():
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


## Map sprite id for an enemy: its foe type, or the faction's boss for an elite.
static func foe_sprite_id(u: Unit) -> String:
	if u.elite:
		return str(ContentDB.load_default().factions.get(u.faction, {}).get("boss", ""))
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
		_map3d.sync()
		var mat: ShaderMaterial = _composite.material
		var src := Bleed.sources(field, _origin, HEX_SIZE, _anim_px)
		if flatten_r > 0.0 and src.size() < Bleed.MAX_SOURCES:
			src.append(Vector3(flatten_at.x, flatten_at.y, flatten_r * HEX_SIZE))
		mat.set_shader_parameter("grad", Bleed.gradient(field, _origin, HEX_SIZE))
		mat.set_shader_parameter("source_count", src.size())
		src.resize(Bleed.MAX_SOURCES)
		mat.set_shader_parameter("sources", src)
		mat.set_shader_parameter("focus_y", (size.y * 0.5 - scroll_y) / zoom)
		mat.set_shader_parameter("scroll", Vector2(scroll_x, scroll_y))
		mat.set_shader_parameter("zoom", zoom)
		draw_texture_rect(_mix.get_texture(), Rect2(Vector2.ZERO, size), false)
		# Everything from here to the edge tags is drawn in map space under the zoom and
		# scroll. The grid itself is in the scene, lit, so raised ground hides it.
		draw_set_transform(Vector2(scroll_x, scroll_y), 0.0, Vector2(zoom, zoom))
	else:
		draw_set_transform(Vector2(scroll_x, scroll_y), 0.0, Vector2(zoom, zoom))
		# Headless: the painted map, so the view still lays out and the structures still show.
		for h in map.all_hexes():
			var pts := Hex.corners(center(h), HEX_SIZE - 1.5)
			draw_colored_polygon(pts, TERRAIN[map.terrain[h]])
			TerrainArt.draw(self, center(h), HEX_SIZE, map.terrain[h], h.x * 131 + h.y * 7919, 0.9)
			Hud.stroke_poly(self, pts, Color(hud, 0.10), 1.0)
		for wh in map.wall_hexes:
			draw_colored_polygon(Hex.corners(center(wh), HEX_SIZE - 3.0), Color(Palette.MUTED, 0.35))
		for g in map.gate_hexes:
			var pts := Hex.corners(center(g), HEX_SIZE - 3.0)
			draw_colored_polygon(pts, Color(hud, 0.10))
			Hud.stroke_poly(self, pts, Color(hud, 0.85), 2.0)
	_draw_rift(map)

	# Where the selected mech may end its move.
	for h in destinations.keys():
		var pts := Hex.corners(center(h), HEX_SIZE - 5.0)
		draw_colored_polygon(pts, Color(hud, 0.26))
		Hud.stroke_poly(self, pts, Color(hud, 0.8), 1.5)

	# Enemy previews: where each squad goes given the plan as it stands, from the same dry
	# run that finds the contacts (Ryan, 22 September: a route that cuts a squad off shows
	# in that squad's path), and none at all while a move is playing.
	var contact_hexes: Dictionary = {}
	if _anim.is_empty() and pending.is_empty():
		var pv := _preview()
		var res: Battlefield.PhaseResult = pv["result"]
		for group in res.skirmishes:
			for u in group:
				contact_hexes[(pv["ends"] as Dictionary)[u.id]] = true
		# The zone of control: the ground beside every grounded machine's destination, one
		# tinted flower around the machine with a single outline, so whose it is reads at a
		# glance and the field stays quiet (Ryan, 22 September).
		var ends: Dictionary = pv["ends"]
		for m in field.mechs():
			if m.traits.has("flyer"):
				continue
			_zone(ends[m.id], hud)
		for sq in field.squads():
			var path: Array = res.intents.get(sq.id, [])
			if path.is_empty():
				continue
			var dest: Vector2i = path[path.size() - 1]
			var pts: PackedVector2Array = [center(sq.pos)]
			for step in path:
				pts.append(center(step))
			var owned := not (contact_hexes.has(dest) or map.gate_hexes.has(dest))
			if owned:
				# The line runs over the outline to the target's centre: line, tint, outline
				# and rings are one component, nothing translucent, the hex under the line
				# so nothing cuts it (Ryan, 22 September).
				_destination_hex(dest)
			draw_polyline(pts, _ring_colour(), 4.0)   # the line breathes with the target (Ryan, 22 September)
			if owned:
				_destination_rings(center(dest))

	# The player's plotted routes, ending in a small marker hex.
	for uid in routes.keys():
		var u := field.unit_by_id(uid)
		var route: Array = routes[uid]
		if u == null or route.is_empty():
			continue
		var prev := center(u.pos)
		for step in route:
			var p := center(step)
			draw_line(prev, p, hud, 3.0)
			prev = p
		Hud.stroke_poly(self, Hex.corners(prev, HEX_SIZE * 0.45), hud, 2.0)

	# Contacts waiting to be fought (Ryan, 22 September): the map freezes on them, the
	# units about to engage lit, and nothing of the next phase shows until they are done.
	if not pending.is_empty() and _anim.is_empty():
		for group in pending:
			var lit := _highlight.is_empty() or _highlight.has((group[0] as Unit).pos)
			for u in group:
				_contact_effect(u.pos, lit, u.is_enemy())
	# The plan as it will resolve, from the resolver itself run dry (Ryan, 21 September:
	# never ambiguous): every contact group, every squad stopped by a body block, every
	# route that will be rejected.
	if _anim.is_empty() and pending.is_empty():
		var pv := _preview()
		var res: Battlefield.PhaseResult = pv["result"]
		var ends: Dictionary = pv["ends"]
		for group in res.skirmishes:
			var mid := Vector2.ZERO
			var top_y := INF
			var group_hexes: Array = []
			for u in group:
				group_hexes.append(ends[u.id])
			var lit := _highlight.is_empty() or _highlight.has(group_hexes[0])
			for u in group:
				var c := center(ends[u.id])
				mid += c
				top_y = minf(top_y, c.y)
				_contact_effect(ends[u.id], lit, u.is_enemy())
			mid /= float(group.size())
			# Who is in it: the machines against the squads, so the player knows what the
			# skirmish will hold before locking in (Ryan, 22 September).
			_plaque(Vector2(mid.x, top_y - HEX_SIZE * 0.95), "CONTACT // " + contact_label(group, ends), Palette.ENEMY, 2.0)
		for sid in res.blocked:
			var sq := field.unit_by_id(sid)
			if sq != null:
				_plaque(center(ends[sid]) + Vector2(0.0, HEX_SIZE * 0.7), "BLOCKED", Palette.MUTED, 1.5)
		for mid_id in res.rejected:
			var m := field.unit_by_id(mid_id)
			if m != null:
				_plaque(center(m.pos) + Vector2(0.0, HEX_SIZE * 0.7), "NO ROUTE", Palette.ENEMY, 1.5)

	for u in field.units:
		_draw_unit(u)

	if selected != null:
		var c := center(selected.pos)
		Hud.brackets(self, Rect2(c - Vector2(HEX_SIZE, HEX_SIZE) * 0.85, Vector2(HEX_SIZE, HEX_SIZE) * 1.7), 12.0, hud, 2.0)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)   # from here, screen space
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
	_readout(font, Vector2(FRAME_SIDE + 8.0, top + 19.0), "SEC %02d // GRID %dx%d // RECON" % [map.map_seed % 100, map.width, map.height - BattleMap.GATE_ROWS], fc)
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

func _draw_gate_bar() -> void:
	var map := field.map
	var at := _origin + Hex.to_pixel(map.gate, HEX_SIZE) + Vector2(0, -HEX_SIZE * 1.5 * (BattleMap.GATE_ROWS - 0.5) + 26.0)
	var frac := float(field.gate_hp) / maxf(1.0, float(field.gate_hp_max))
	var col := Palette.HUD if frac > 0.34 else Palette.ENEMY
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


const RIFT_ART := Color("c9a6ff")   # what the rift looks like; it means nothing but the rift
const RIFT_FRAME_SECONDS := 0.6    # a frame, on the vortex's own clock
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
			Hud.stroke_poly(self, Hex.corners(center(r), HEX_SIZE - 3.0), RIFT_ART, 2.0)
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
	var tick := floorf(_ring_t * 4.0)
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
	for b in range(rows):
		var torn: bool = torn_bands.has(b)
		var shear := (3.0 if int(b) % 2 == 0 else -3.0) * SPRITE_SCALE if torn else 0.0
		var src := Rect2(k * fw, b * band_h, fw, band_h)
		var dst := Rect2(dest.position + Vector2(shear, b * band_h * SPRITE_SCALE), Vector2(fw, band_h) * SPRITE_SCALE)
		draw_texture_rect_region(tex, dst, src, Color(1, 1, 1, 1) if not torn else Color(0.55, 0.55, 0.68, 1.0))   # dimmed hard: at 0.82 only the shear showed (Ryan, 23 September)


## Off-screen squads get a portrait at the edge nearest them: the source of the intent line.


## A number on a dark plaque with a coloured border: legible on any tile, and the colour
## carries the side without asking coloured text to survive the ground.
func _plaque(at: Vector2, text: String, border: Color, thick: float = 1.5) -> void:
	var w := Hud.mono().get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 10.0
	# Kept inside the visible width, so a zoomed-in plaque never runs off the screen.
	var left := (4.0 - scroll_x) / zoom
	var right := (size.x - 4.0 - scroll_x) / zoom
	var x := clampf(at.x, left + w * 0.5, right - w * 0.5) if right - left > w else at.x
	var rect := Rect2(Vector2(x, at.y) - Vector2(w * 0.5, 9.0), Vector2(w, 18.0))
	draw_rect(rect, Palette.BG, true)
	draw_rect(rect, border, false, thick)
	draw_string(Hud.mono(), rect.position + Vector2(5.0, 13.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)


func _draw_tags() -> void:
	_tags = offscreen_tags()
	for t in _tags:
		var rect: Rect2 = t[0]
		var sq: Unit = t[1]
		var above: bool = t[2]
		var border := Palette.ENEMY
		Hud.box(self, rect, 6.0, Color(Palette.BG, 0.94), Color(border, 0.9), 1.5)
		if sq.elite:
			Hud.box(self, rect.grow(-4.0), 4.0, Color(0, 0, 0, 0), Color(border, 0.9), 1.5)   # a double border says elite
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
		var label := ("×%d" % sq.strength) if sq.strength > 0 else "BOSS"
		draw_string(Hud.mono(), rect.position + Vector2(0, rect.size.y - 6.0), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 12, Palette.INK)
		# A chevron on the outer edge, pointing the way to the squad.
		var mid := rect.position.x + rect.size.x * 0.5
		var edge_y := rect.position.y - 1.0 if above else rect.end.y + 1.0
		var dir := -1.0 if above else 1.0
		draw_colored_polygon(PackedVector2Array([Vector2(mid - 6.0, edge_y), Vector2(mid + 6.0, edge_y), Vector2(mid, edge_y + 6.0 * dir)]), border)


## The effects, told apart by motion (Ryan, 22 September: a red outline alone never reads
## against this ground, so tint the hex and move something). A squad's destination: a
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
			draw_line(pts[i], pts[(i + 1) % 6], col, 2.0)


func _mark(h: Vector2i) -> Dictionary:
	for m in _ground_marks:
		if m["hex"] == h:
			return m
	var m := {"hex": h, "fill": Color(0, 0, 0, 0), "edges": [], "line": Color(0, 0, 0, 0)}
	_ground_marks.append(m)
	return m


const DEST_RING := HEX_SIZE * 0.58   # the target's outer ring
const ENEMY_LIT := Color("ffb3a6")    # the enemy marks' bright: red lifted well toward white, so the rings ride the tint

## The target in the HUD's own weight (Ryan, 22 September: nothing translucent, nothing
## abutting, the animation the thing you see): a tint on the ground and a thin outline
## under the line, then three bright broken rings turning against each other around a
## centre dot. On the ground's own height, like everything else (a trial at the hex's
## base was worse, Ryan the same day).
func _destination_hex(h: Vector2i) -> void:
	# The tint pulses on the same clock as the line and rings (Ryan, 22 September).
	var breath := 0.5 + 0.5 * sin(_ring_t * 1.6)
	_fill(h, Color(Palette.ENEMY, 0.45 + 0.2 * breath))
	Hud.stroke_poly(self, Hex.corners(center(h), HEX_SIZE - 3.0), _ring_colour(), 2.5)


## The enemy marks breathe between red and the bright, most of the way up and never
## quite down to the deep red, so on any ground, props or not, they pass through a
## colour that reads (Ryan, 22 September).
func _ring_colour() -> Color:
	var breath := 0.5 + 0.5 * sin(_ring_t * 1.6)
	return Palette.ENEMY.lerp(ENEMY_LIT, 0.35 + 0.65 * breath)


func _destination_rings(c: Vector2) -> void:
	var col := _ring_colour()
	_target_rings(c, col, DEST_RING, 1.0)
	draw_circle(c, 4.0, col)


## Three rings of broken arcs turning against each other: the display's own target lock.
func _target_rings(c: Vector2, col: Color, r: float, dir: float) -> void:
	for k in range(3):
		var rad := r * (0.42 + 0.29 * k)
		var segs := 3 + k * 2
		var a0 := _ring_t * dir * (1.0 - 0.25 * k) * (1.0 if k % 2 == 0 else -1.0)
		for sgm in range(segs):
			var a := a0 + TAU * float(sgm) / float(segs)
			draw_arc(c, rad, a, a + TAU / float(segs) * 0.6, 10, col, 3.0)


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
	_fill(h, Color(Palette.ENEMY, (0.7 + 0.25 * breath) * a))
	Hud.stroke_poly(self, Hex.corners(c, HEX_SIZE - 3.0), Color(Palette.ENEMY, a), 2.5)
	var col := _ring_colour()
	for k in range(2):
		var phase := fmod(_ring_t * 0.9 + k * 0.5, 1.0)
		var r := HEX_SIZE * (0.3 + 1.1 * phase)
		draw_arc(c, r, 0.0, TAU, 40, Color(col, (1.0 - phase) * a), 3.0 * (1.0 - phase * 0.5) + 1.0)


## A machine's zone: its six neighbours as one tinted flower with one outline round the
## outside, so the zone belongs visibly to the hex at its centre.
func _zone(h: Vector2i, col: Color) -> void:
	var cluster: Dictionary = {h: true}
	for n in Hex.neighbors(h):
		if field.map.has(n) and not field.map.is_structure(n):
			cluster[n] = true
	# A real aura (Ryan, 22 September: the tints were far too subtle; the UX matters more
	# than the ground under them), breathing so it reads as the machine's reach.
	var breath := 0.5 + 0.5 * sin(_ring_t * 2.2)
	for n in cluster.keys():
		if n != h:
			_fill(n, Color(col, 0.28 + 0.12 * breath))
	for n in cluster.keys():
		if n == h:
			continue
		var nb := Hex.neighbors(n)
		# Corner i to corner i+1 of a pointy hex (corners from -30 degrees) faces the
		# direction at 60i degrees, which is DIRECTIONS[(6 - i) % 6]; the edges whose far
		# side is outside the cluster make the flower's outline, on the ground so the
		# machines standing in the zone hide it (Ryan, 22 September).
		var edges: Array = []
		for i in range(6):
			var across: Vector2i = nb[(6 - i) % 6]
			# No edge against the wall, the gate or the map's end: nothing comes from there.
			if not cluster.has(across) and field.map.has(across) and not field.map.is_structure(across):
				edges.append(i)
		if not edges.is_empty():
			_edges(n, edges, Color(col, 0.7))


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
	var squads: Array[String] = []
	for u in group:
		if u.is_player():
			mechs.append(str(u.display_name))
		else:
			squads.append("%s ×%d" % [u.display_name, u.strength] if u.strength > 0 else str(u.display_name).to_upper())
	return " + ".join(mechs) + " vs " + " + ".join(squads)


## The contact's words with the ground it is fought on (decided 22 September).
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


## The dry run of the phase, redone only when the plan changes.
var _preview_key := ""
var _preview_cache: Dictionary = {}

func _preview() -> Dictionary:
	var key := "%d|%s|%s" % [field.phase, str(routes), str(field.intents)]
	if key != _preview_key:
		_preview_key = key
		_preview_cache = field.preview_phase(routes)
	return _preview_cache


# ---------------------------------------------------------------- the movement phase

const MOVE_SECONDS_PER_HEX := 0.22   # the fastest anything ever moves (Ryan, 22 September)
static var pace := 1.0               # the player's setting: seconds per hex are divided by it
const MOVE_REF_SPEED := 5.0          # a unit this quick moves at that pace; slower ones slower
var _anim: Dictionary = {}      # unit id -> {path: Array[Vector2i], t: float}
var _anim_queue: Array = []     # [[moves], ...] phases still to play: mechs, then squads
var _anim_done: Callable = Callable()


func is_playing() -> bool:
	return not _anim.is_empty() or not _anim_queue.is_empty()


## Play the phase's moves: the mechs along their routes, then the squads along their
## intents, then `done`. Each move is [unit id, Array of hexes from start to end].
func play_moves(mech_moves: Array, squad_moves: Array, done: Callable) -> void:
	_anim_queue = [mech_moves, squad_moves]
	_anim_done = done
	# Everyone who will move starts where they were, this frame, so nobody blinks to the
	# end and rewinds (Ryan, 22 September); the squads wait there while the mechs play.
	for moves in _anim_queue:
		for mv in moves:
			var path: Array = mv[1]
			if path.size() >= 2:
				var px: Vector2 = Hex.to_pixel(path[0], HEX_SIZE)
				_anim_px[mv[0]] = px
				if _map3d != null:
					_map3d.set_anim(mv[0], px, Vector2.ZERO)
	_next_anim_phase()


func _next_anim_phase() -> void:
	_anim.clear()
	while not _anim_queue.is_empty() and _anim.is_empty():
		var moves: Array = _anim_queue.pop_front()
		for mv in moves:
			if (mv[1] as Array).size() >= 2:
				var u := field.unit_by_id(mv[0])
				_anim[mv[0]] = {"path": mv[1], "t": 0.0, "speed": u.movespeed if u != null else MOVE_REF_SPEED}
	if _anim.is_empty():
		for uid in _anim_px.keys():
			if _map3d != null:
				_map3d.clear_anim(uid)
		_anim_px.clear()
		var cb := _anim_done
		_anim_done = Callable()
		if cb.is_valid():
			cb.call()
	queue_redraw()


func _advance_anim(delta: float) -> void:
	var finished: Array = []
	for uid in _anim.keys():
		var a: Dictionary = _anim[uid]
		var path: Array = a["path"]
		a["t"] += delta * pace / (MOVE_SECONDS_PER_HEX * maxf(1.0, MOVE_REF_SPEED / maxf(1.0, float(a["speed"]))))
		var last := float(path.size() - 1)
		if a["t"] >= last:
			finished.append(uid)
			continue
		var i := int(floor(a["t"]))
		if i != int(a.get("i", -1)):
			a["i"] = i
			if i > 0 and field.unit_by_id(uid) != null and field.unit_by_id(uid).is_player():
				Sound.play("step", 0.0, 0.1)   # a footfall a hex (quiet by its file); the squads are pictures and make none
		var f: float = a["t"] - i
		var from: Vector2 = Hex.to_pixel(path[i], HEX_SIZE)
		var to: Vector2 = Hex.to_pixel(path[i + 1], HEX_SIZE)
		var px := from.lerp(to, f)
		_anim_px[uid] = px
		if _map3d != null:
			_map3d.set_anim(uid, px, (to - from).normalized())
	for uid in finished:
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
		var lift := _map3d.lift(under) if _map3d != null else 0.0
		return _origin + px + Vector2(0, -lift)
	return center(u.pos)


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
		draw_texture_rect(tex, Rect2((c - Vector2(ts.x * 0.5, ts.y - 8.0)).floor(), ts), false)
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
		_plaque(c + Vector2(28.0, -30.0), "×%d" % u.strength, Palette.ENEMY, 3.0 if u.elite else 1.5)   # up and right, clear of the picture


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
		else:
			if _holding:
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
			elif _pinch_d > 1.0:
				zoom_at(mid, d / _pinch_d)
			_pinch_d = d
		elif _pinching and _touches.size() < 2:
			_pinching = false
			_pressed = false
		if _touches.size() >= 2 or _pinching:
			accept_event()
	elif event is InputEventMouseMotion and _pressed and not _holding and not _pinching:
		if not _dragged and event.position.distance_to(_press_pos) > DRAG_THRESHOLD:
			_dragged = true
		if _dragged:
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
			var u := field.unit_at(hex_at(_press_pos))
			if u != null:
				unit_held.emit(u)
