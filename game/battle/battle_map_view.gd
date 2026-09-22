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

const HEX_SIZE := 44.0
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
	var top := _origin.y - HEX_SIZE * 2.4                                                  # a row of scenery past the rift
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
		var y := TAG_GAP if above else size.y - TAG_SIZE.y - TAG_GAP
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
		if frame_alpha > 0.0:
			# The frame: the field's two boundary lines in the display's light, a tick on
			# every row's centre with the row's number, and a sector readout at each end, so
			# the playable area has a viewfinder's edge and the blur runs into it.
			var fx := _frame_x()
			var left := fx.x
			var right := fx.y
			var top := _origin.y - HEX_SIZE
			var bottom := _origin.y + Hex.to_pixel(map.gate, HEX_SIZE).y - HEX_SIZE * 1.5 * (BattleMap.GATE_ROWS - 0.5)
			var fc := Color(hud, frame_alpha)
			var font := Hud.mono()
			for x in [left, right]:
				var dir := 1.0 if x == left else -1.0
				draw_line(Vector2(x, top), Vector2(x, bottom), fc, 2.0)
				for row in range(map.height - BattleMap.GATE_ROWS):
					var y := _origin.y + HEX_SIZE * 1.5 * row
					draw_line(Vector2(x, y), Vector2(x + 10.0 * dir, y), fc, 2.0)
					var label := "%02d" % (map.height - BattleMap.GATE_ROWS - row)   # counted up from the gate
					var lx: float = (x - 30.0) if dir > 0.0 else (x + 8.0)
					draw_string(font, Vector2(lx, y + 4.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, fc)
				draw_line(Vector2(x, top), Vector2(x + 18.0 * dir, top), fc, 2.0)
				draw_line(Vector2(x, bottom), Vector2(x + 18.0 * dir, bottom), fc, 2.0)
			draw_string(font, Vector2(left + 6.0, top - 6.0), "SEC %02d // GRID %dx%d // RECON" % [field.map.map_seed % 100, map.width, map.height - BattleMap.GATE_ROWS], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, fc)
			draw_string(font, Vector2(left + 6.0, bottom + 14.0), "CARE // PROJECTOR LINE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, fc)
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
	for r in map.rift_hexes:
		var pts := Hex.corners(center(r), HEX_SIZE - 3.0)
		draw_colored_polygon(pts, Color("2a1a3f"))
		Hud.stroke_poly(self, pts, RIFT_ART, 2.0)   # the rift's own art, not a palette role

	# Where the selected mech may end its move.
	for h in destinations.keys():
		var pts := Hex.corners(center(h), HEX_SIZE - 5.0)
		draw_colored_polygon(pts, Color(hud, 0.14))
		Hud.stroke_poly(self, pts, Color(hud, 0.55), 1.0)

	# Enemy previews: where each squad goes given the plan as it stands, from the same dry
	# run that finds the contacts (Ryan, 22 September: a route that cuts a squad off shows
	# in that squad's path), and none at all while a move is playing.
	var contact_hexes: Dictionary = {}
	if _anim.is_empty():
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
			# The line stops at the destination's edge; the target inside it is the effect.
			pts[pts.size() - 1] = pts[pts.size() - 2].lerp(pts[pts.size() - 1], 0.5)
			draw_polyline(pts, Color(Palette.BG, 0.75), 10.0)
			draw_polyline(pts, Color(Palette.ENEMY, 0.95), 5.0)
			if contact_hexes.has(dest) or map.gate_hexes.has(dest):
				continue   # the contact effect owns this hex; the gate is a strike
			_destination_effect(center(dest))

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

	# The plan as it will resolve, from the resolver itself run dry (Ryan, 21 September:
	# never ambiguous): every contact group, every squad stopped by a body block, every
	# route that will be rejected.
	if _anim.is_empty():
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
				_contact_effect(c, lit)
			mid /= float(group.size())
			# Who is in it: the machines against the squads, so the player knows what the
			# skirmish will hold before locking in (Ryan, 22 September).
			_plaque(Vector2(mid.x, top_y - HEX_SIZE * 0.95), "CONTACT // " + contact_text(group), Palette.ENEMY, 2.0)
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

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)   # the edge tags live in screen space
	_draw_tags()
	# The whole battlefield is a projection, the same one as the skirmish's backdrop: its
	# faint scanlines and its soft band drifting down, over everything, foes and overlays
	# too (Ryan, 21 September).
	Hud.scanlines(self, Rect2(Vector2.ZERO, size))


## The one scan bar crosses the whole screen on the top layer (the battle screen draws it);
## it tells the map where it is, in this control's pixels, and the traces under it light.
func sweep_at(local_y: float) -> void:
	if _map3d != null:
		_map3d.set_sweep((local_y - scroll_y) / zoom if sweep_on else -1.0e6)


## Off-screen squads get a portrait at the edge nearest them: the source of the intent line.
const RIFT_ART := Color("c9a6ff")   # what the rift looks like; it means nothing but the rift


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

func _destination_effect(c: Vector2) -> void:
	var breath := 0.5 + 0.5 * sin(_ring_t * 3.0)
	draw_colored_polygon(Hex.corners(c, HEX_SIZE - 3.0), Color(Palette.ENEMY, 0.30))
	Hud.stroke_poly(self, Hex.corners(c, HEX_SIZE - 3.0), Color(Palette.ENEMY, 0.8), 2.0)
	for k in range(3):
		var r := HEX_SIZE * (0.22 + 0.2 * k) * (0.85 + 0.15 * breath)
		draw_arc(c, r, 0.0, TAU, 32, Color(Palette.ENEMY, 0.95 - 0.2 * k), 2.5)
	draw_circle(c, 3.5, Palette.ENEMY)


func _contact_effect(c: Vector2, lit: bool) -> void:
	var a := 1.0 if lit else 0.35
	var breath := 0.5 + 0.5 * sin(_ring_t * 4.0)
	draw_colored_polygon(Hex.corners(c, HEX_SIZE - 3.0), Color(Palette.ENEMY, (0.38 + 0.22 * breath) * a))
	Hud.stroke_poly(self, Hex.corners(c, HEX_SIZE - 3.0), Color(Palette.ENEMY, 0.95 * a), 4.0)
	for k in range(2):
		var phase := fmod(_ring_t * 0.9 + k * 0.5, 1.0)
		var r := HEX_SIZE * (0.3 + 1.1 * phase)
		draw_arc(c, r, 0.0, TAU, 40, Color(Palette.ENEMY, (1.0 - phase) * 0.9 * a), 3.0 * (1.0 - phase * 0.5) + 1.0)


## A machine's zone: its six neighbours as one tinted flower with one outline round the
## outside, so the zone belongs visibly to the hex at its centre.
func _zone(h: Vector2i, col: Color) -> void:
	var cluster: Dictionary = {h: true}
	for n in Hex.neighbors(h):
		if field.map.has(n) and not field.map.is_structure(n):
			cluster[n] = true
	for n in cluster.keys():
		if n == h:
			continue
		var pts := Hex.corners(center(n), HEX_SIZE)
		draw_colored_polygon(pts, Color(col, 0.13))
	for n in cluster.keys():
		if n == h:
			continue
		var pts := Hex.corners(center(n), HEX_SIZE - 1.0)
		var nb := Hex.neighbors(n)
		# Corner i to corner i+1 of a pointy hex (corners from -30 degrees) faces the
		# direction at 60i degrees, which is DIRECTIONS[(6 - i) % 6]; draw the edges whose
		# far side is outside the cluster.
		for i in range(6):
			var across: Vector2i = nb[(6 - i) % 6]
			if not cluster.has(across):
				draw_line(pts[i], pts[(i + 1) % 6], Color(col, 0.75), 2.0)


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


## The frame's left and right lines in map pixels: the field plus a little, and the line
## the side blur begins at.
func _frame_x() -> Vector2:
	var hex_w := sqrt(3.0) * HEX_SIZE
	var left := _origin.x - hex_w * 0.5 - HEX_SIZE * 0.55
	return Vector2(left, left + hex_w * (field.map.width + 0.5) + HEX_SIZE * 1.1)


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
const MOVE_REF_SPEED := 5.0          # a unit this quick moves at that pace; slower ones slower
var _anim: Dictionary = {}      # unit id -> {path: Array[Vector2i], t: float}
var _anim_queue: Array = []     # [[moves], ...] phases still to play: mechs, then squads
var _anim_done: Callable = Callable()


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
		a["t"] += delta / (MOVE_SECONDS_PER_HEX * maxf(1.0, MOVE_REF_SPEED / maxf(1.0, float(a["speed"]))))
		var last := float(path.size() - 1)
		if a["t"] >= last:
			finished.append(uid)
			continue
		var i := int(floor(a["t"]))
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
	var tex: Texture2D = Sprites.map_mech(u.chassis_id, u.facing) if u.is_player() else Sprites.map_foe(foe_sprite_id(u))
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
		zoom_at(event.position, event.factor)   # pinch on a touch screen or trackpad
		accept_event()
	elif event is InputEventMouseMotion and _pressed and not _holding:
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
