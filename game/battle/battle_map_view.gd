class_name BattleMapView
extends Control

## The battlefield as a scrolling, touchable map in the overlay style. Draws terrain, the gate
## and the rift, every pack's walk on the enemy's turn, every hunter's lock and its ring, the
## fights a hunter forced, the fight being set up, the hexes the selected machine can reach, and
## the units themselves (bible section 4, the round row).
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

## A tap on a unit and a double-tap on it work as a die's do in a fight (Ryan, 10 November:
## "Double-tap for codex entries needs to work the same way as the dice do in skirmishes";
## DieFaceView, whose window this is, from a tap's release to the next touch): the tap lands only
## once the window has passed with no second touch, so a double-tap opens the codex and never
## shows a tap's work first (it selected the unit and let it go again); the unit's hex is
## bracketed from the touch until the tap lands. A tap on bare ground has no entry to wait for and
## lands at once.
const DOUBLE_TAP_SECONDS := DieFaceView.DOUBLE_TAP_SECONDS

const HEX_SIZE := 48.0   # up from 44 (Ryan, 23 September: the map must not get smaller)
const FOCUS_VIEW_H := 898.0   # the map view's height on the 1280 design: the tilt-shift's focus band is laid out for it, whatever the glass adds
const FOCUS_BAND := 330.0     # the sharp zone's reach toward the rift from the view's middle, in map pixels, with the wall at the bottom: the far blur begins about 120 from the top
const FOCUS_BAND_LEFT := 240.0   # the same with the wall at the left, where the rift lies across the view's width: about 120 from the right edge
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
var queue: Array = []                # the fights waiting, in the order ENGAGE opens them (Battle.fights_waiting): numbered on the map
var flatten_at := Vector2.ZERO       # the handover into a skirmish: one more bleed source, growing
var flatten_r := 0.0                 # its radius in hexes; 0 is none (tweened by the screen)
var destinations: Dictionary = {}    # hexes the selected mech may end on
var threat: Dictionary = {}          # hexes past its move the selected mech may attack from there (Battle.threat_for), in the enemy's violet
var plans: Array = []                # the moves planned and not yet played (Battle.plan_pieces), drawn as routes
var shown: Dictionary = {}           # machine id -> [hex, facing]: where a planned machine stands until its plan plays (Battle.shown_positions)
var scroll_y: float = 0.0            # the map's offset on screen, in pixels
var scroll_x: float = 0.0
var zoom: float = 1.0                # the reconstruction's zoom (Ryan, 21 September); 1 fits the width
var seam_shown := -1.0               # the seam's row as drawn while a peak's creep waits or plays (hold_peak, play_peak); under 0, the field's own
var tears_shown := -1                # how many of the field's tears are drawn, the rest waiting for their opening; under 0, all

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
var _tap_due := -1.0                # when a tap waiting out the double-tap window lands; negative, none
var _tap_hex := Vector2i(-9999, -9999)   # the hex that tap is on
var _second := false                # this touch came inside the window on the same hex: its release is the double-tap
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
	_end_cutscene()
	_layout()
	scroll_to_bottom()
	# The battlefield is geometry with the other world bleeding in (decided 19 September):
	# the painted map rendered once, the 3D scene whose ground wears it, and a compositor
	# that mixes the two by the bleed, drawn behind this control's own overlays. Headless
	# runs have no renderer and fall back to the painted map alone.
	if DisplayServer.get_name() != "headless":
		for old in [_painted, _painted2, _map3d, _mix] + _portraits.values():
			if old != null:
				old.queue_free()
		_portraits = {}
		var map_size := _map_size
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
		# The tilt-shift lies from the wall toward the rift in either view: the far ground softens
		# past the focus band and the city softens past the wall's foot, at the screen's top and
		# foot with the wall at the bottom, at its right and left with the wall at the left.
		var far := MapOrient.toward_rift()
		mat.set_shader_parameter("far_axis", far)
		mat.set_shader_parameter("south_d", (_origin + MapOrient.to_pixel(field.map.gate, HEX_SIZE)).dot(far) - HEX_SIZE * 0.75)
		mat.set_shader_parameter("focus_band", FOCUS_BAND_LEFT if MapOrient.wall_left else FOCUS_BAND)
		mat.set_shader_parameter("grad_axis", Bleed.axis())
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


## Map space holds the whole content, the field and its scenery (the margin past the field's
## sides and past the rift, the city past the wall), its top left at the map's (0, 0) less the
## pads; the painted world is drawn once at that size. Either orientation (MapOrient) lays the
## same hexes; only where they fall turns.
func _layout() -> void:
	var c := _content_rect()
	_origin = -c.position + Vector2(0.0, TOP_PAD)
	_map_size = (c.size + Vector2(0.0, TOP_PAD + BOTTOM_PAD)).ceil()


## Every hex of the field and of the scenery round it, in the view's pixels about hex (0, 0),
## each hex's own extent included.
func _content_rect() -> Rect2:
	var hexes: Array = field.map.all_hexes().duplicate()
	hexes.append_array(field.map.margin.keys())
	return _hex_bounds(hexes)


func _hex_bounds(hexes: Array) -> Rect2:
	var lo := Vector2(INF, INF)
	var hi := -lo
	for h in hexes:
		var p := MapOrient.to_pixel(h, HEX_SIZE)
		lo = lo.min(p)
		hi = hi.max(p)
	var ext := MapOrient.turn(Vector2(sqrt(3.0) * 0.5, 1.0) * HEX_SIZE).abs()   # a pointy-top hex's half width across, its radius up; turned with the view
	return Rect2(lo - ext, hi - lo + ext * 2.0)


## Where the scroll may run, in map space: the playable field, the vortex's height past the
## rift and a row of city past the wall (Ryan, 21 September: the rest of the scenery fills the
## edges and is never scrolled to), in either view.
func _scroll_rect() -> Rect2:
	var r := _hex_bounds(field.map.all_hexes())
	r.position += _origin
	var t := MapOrient.toward_rift()
	r = r.expand(base(field.map.rift) + t * HEX_SIZE * 3.6)
	r = r.expand(base(field.map.gate) - t * HEX_SIZE * 2.6)
	return r


## Keep the view on the scroll's range: no bare edge at any zoom. An axis the range is shorter
## than the view on sits centred.
func _clamp_scroll() -> void:
	var r := _scroll_rect()
	scroll_x = _clamp_axis(scroll_x, r.position.x, r.end.x, size.x)
	scroll_y = _clamp_axis(scroll_y, r.position.y, r.end.y, size.y)


func _clamp_axis(s: float, lo: float, hi: float, view: float) -> float:
	if (hi - lo) * zoom <= view:
		return (view - (lo + hi) * zoom) * 0.5
	return clampf(s, view - hi * zoom, -lo * zoom)


## Start at the gate's end, where the player's machines stand: the wall's end of the range
## across it, centred on the gate along it.
func scroll_to_bottom() -> void:
	_scroll_to_end(-MapOrient.toward_rift())


## The rift's end, centred on the rift along the wall.
func scroll_to_top() -> void:
	_scroll_to_end(MapOrient.toward_rift())


func _scroll_to_end(dir: Vector2) -> void:
	var on := base(field.map.gate if dir.dot(MapOrient.toward_rift()) < 0.0 else field.map.rift)
	scroll_x = size.x * 0.5 - on.x * zoom
	scroll_y = size.y * 0.5 - on.y * zoom
	if dir.y > 0.5:
		scroll_y = -1.0e9
	elif dir.y < -0.5:
		scroll_y = 1.0e9
	elif dir.x > 0.5:
		scroll_x = -1.0e9
	elif dir.x < -0.5:
		scroll_x = 1.0e9
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
	return _origin + MapOrient.to_pixel(h, HEX_SIZE)


## Centre of a hex in map space: its grid cell, lifted by the height of its column so the
## overlays stand on the terrain. Under the painting the column is gone and the ground is
## flat, so the lift goes with it (Ryan, 29 September: a pack on flattened ground was
## placed by the height of the geometry the painting had replaced, and its marks with it).
func center(h: Vector2i) -> Vector2:
	return _origin + MapOrient.to_pixel(h, HEX_SIZE) + Vector2(0, -_lift_at(h))


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
		_bleed_grad = Bleed.gradient(field, _origin, HEX_SIZE, seam_shown)
		_bleed_src = Bleed.sources(field, _origin, HEX_SIZE, _anim_px)
	return lift * Bleed.solid(base(h), _bleed_grad, _bleed_src)


## The hex under a screen point. A raised hex's top sits above its cell and covers part of
## the hex north of it, so the candidates' lifted outlines are tested, the southmost (nearest
## the camera) winning.
func hex_at(local: Vector2) -> Vector2i:
	var p := to_map(local)
	var flat := MapOrient.from_pixel(p - _origin, HEX_SIZE)
	if _map3d == null or field == null:
		return flat
	var best := flat
	var best_y := -INF
	var cands: Array[Vector2i] = [flat]
	cands.append_array(Hex.neighbors(flat))
	for cand in cands:
		if not field.map.has(cand):
			continue
		var cy := base(cand).y   # nearest the camera is lowest on screen, in either view
		if cy <= best_y:
			continue
		if Geometry2D.is_point_in_polygon(p, MapOrient.corners(center(cand), HEX_SIZE)):
			best = cand
			best_y = cy
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
## The edge tags (the long wall brief 7.1: a wall longer than a screen wants them in both views):
## every pack and machine past the view's edge gets a tag at the edge it lies past, laid along
## that edge in the order they stand, never overlapping. [[Rect2, the Unit, "top" | "bottom" |
## "left" | "right"], ...]. A tear has none, as the rift has none (Ryan, 10 November: "Tear
## doesn't need an edge tag, same way the rift doesn't"): its opening is shown as it happens
## (play_peak).
func offscreen_tags() -> Array:
	var out: Array = []
	if field == null:
		return out
	var edges := {"top": [], "bottom": [], "left": [], "right": []}
	var things: Array = []
	things.append_array(field.packs())
	things.append_array(field.mechs())
	var m := HEX_SIZE * 0.3
	for thing in things:
		var c := to_screen(center((thing as Unit).pos))
		var edge := "top" if c.y < -m else ("bottom" if c.y > size.y + m else ("left" if c.x < -m else ("right" if c.x > size.x + m else "")))
		if not edge.is_empty():
			(edges[edge] as Array).append([c, thing])
	for edge in ["top", "bottom"]:
		var list: Array = edges[edge]
		list.sort_custom(func(a, b) -> bool: return a[0].x < b[0].x)
		var next_x := TAG_GAP
		# Under the frame's top readout, or over its bottom one (Ryan, 23 September: the
		# frame belongs to the viewport, so the tags make room for it).
		var y := FRAME_PAD + 24.0 if edge == "top" else size.y - TAG_SIZE.y - FRAME_PAD - 20.0
		for item in list:
			var x := maxf(clampf(item[0].x - TAG_SIZE.x * 0.5, TAG_GAP, size.x - TAG_SIZE.x - TAG_GAP), next_x)
			next_x = x + TAG_SIZE.x + TAG_GAP
			out.append([Rect2(Vector2(x, y), TAG_SIZE), item[1], edge])
	for edge in ["left", "right"]:
		var list: Array = edges[edge]
		list.sort_custom(func(a, b) -> bool: return a[0].y < b[0].y)
		var next_y := FRAME_PAD + 24.0 + TAG_SIZE.y + TAG_GAP
		var x := TAG_GAP if edge == "left" else size.x - TAG_SIZE.x - TAG_GAP
		for item in list:
			var y := maxf(clampf(item[0].y - TAG_SIZE.y * 0.5, next_y, size.y - TAG_SIZE.y * 2.0 - FRAME_PAD - 20.0 - TAG_GAP), next_y)
			next_y = y + TAG_SIZE.y + TAG_GAP
			out.append([Rect2(Vector2(x, y), TAG_SIZE), item[1], edge])
	return out


## The unit an edge tag under a screen point stands for, null for none.
func _tag_at(local: Vector2) -> Variant:
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


## An enemy's picture on the map: a pack's token, the boss's own larger picture.
static func foe_picture(u: Unit) -> Texture2D:
	var id := foe_sprite_id(u)
	return Sprites.map_boss(id) if u.is_boss else Sprites.map_foe(id)


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
		_map3d.seam_shown = seam_shown
		_map3d.sync()
		var mat: ShaderMaterial = _composite.material
		var src := Bleed.sources(field, _origin, HEX_SIZE, _anim_px)
		if flatten_r > 0.0 and src.size() < Bleed.MAX_SOURCES:
			src.append(Vector3(flatten_at.x, flatten_at.y, flatten_r * HEX_SIZE))
		_bleed_grad = Bleed.gradient(field, _origin, HEX_SIZE, seam_shown)
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
		var focus_mid := Vector2(size.x * 0.5 - scroll_x, minf(size.y, FOCUS_VIEW_H) * 0.5 - scroll_y) / zoom
		mat.set_shader_parameter("focus_d", focus_mid.dot(MapOrient.toward_rift()))
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
			var pts := MapOrient.corners(center(h), HEX_SIZE - 1.5)
			draw_colored_polygon(pts, TERRAIN[map.terrain[h]])
			TerrainArt.draw(self, center(h), HEX_SIZE, map.terrain[h], h.x * 131 + h.y * 7919, 0.9)
			Hud.stroke_poly(self, pts, Color(hud, 0.10), _px(1.0))
		for wh in map.wall_hexes:
			draw_colored_polygon(MapOrient.corners(center(wh), HEX_SIZE - 3.0), Color(Palette.MUTED, 0.35))
		for g in map.gate_hexes:
			var pts := MapOrient.corners(center(g), HEX_SIZE - 3.0)
			draw_colored_polygon(pts, Color(hud, 0.10))
			Hud.stroke_poly(self, pts, Color(hud, 0.85), _px(2.0))
	_draw_rift(map)

	# Where the selected mech may end its move: every hex alike, lit under one solid edge (Ryan,
	# 28 October: a move is given in one go and the map draws reach and nothing else).
	# The border runs round the range's perimeter, the machine's own hex inside it, and not round
	# each cell (Ryan, 10 November: "its move hexes should have the border around the perimeter
	# of the range display").
	for h in destinations.keys():
		draw_colored_polygon(MapOrient.corners(center(h), HEX_SIZE - _px(2.0)), Color(hud, 0.26))
	if not destinations.is_empty():
		var reach := destinations.duplicate()
		if selected != null:
			reach[shown_hex(selected)] = true
		_region_outline(reach, Color(hud, 0.95), 3.0)

	# A pack the selected machine could be ordered onto, from where its move can take it or where
	# it stands, bracketed in the violet's bright (the long wall brief 7.2: the band past the move
	# went with the rings; the move's lit cells and these brackets are what a selection shows).
	if not threat.is_empty() and _anim.is_empty():
		if selected != null:
			for sq in field.packs():
				var hit := false
				for x in sq.hexes():
					hit = hit or threat.has(x) or Hex.distance(x, selected.pos) <= selected.attack_range
				if hit:
					var bc := center(sq.pos)
					Hud.brackets(self, Rect2(bc - Vector2(HEX_SIZE, HEX_SIZE) * 0.9, Vector2(HEX_SIZE, HEX_SIZE) * 1.8), _px(12.0), ENEMY_HOT, _px(3.0))

	# Where every pack walks on the enemy's turn (bible section 4), from where the machines
	# stand now, and who hunts whom, for the chips drawn over the units; nothing while a move
	# plays or a fight is entered. A fight a hunter forced comes first, so its marks have the map
	# until it is fought. No ring is drawn round a hunter (Ryan, 10 November: "Hunters don't need
	# their catch rings anymore", the catch being the reach everyone shares): its chip names its
	# prey and its landing hex says when it catches.
	var hunted := {}   # prey -> the packs hunting it, for the tags drawn over the units
	var hunting := {}  # hunter -> its prey, for the hunter's own chip
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
					hunting[sq] = prey
			var whole := shows_whole_way(sq, w)
			if whole:
				# Its whole way as the field stands, past this turn's walk to its goal, with the
				# turns after it numbered, and the thing it comes for marked (Ryan, 9 November:
				# "Pushers should show their current complete path to their targeted wall segment
				# when tapped. Similarly, hunters").
				_way_on(sq, w)
			if not w.path.is_empty():
				# The same route mark as the player's (Ryan, 29 September), in steady violet; the
				# colour breathes only on the pack that was tapped.
				_route(sq.pos, w.path, Palette.ENEMY, false, false, whole, true)
			_walk_end(sq, w, whole)
			var below := center(w.end) + Vector2(0.0, HEX_SIZE * 1.15)
			if w.strikes:
				_plaque(below, "STRIKES THE GATE", Palette.ENEMY, 1.5)
			elif w.waits:
				_plaque(below, "WAITS", Palette.MUTED, 1.5)

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
		Hud.stroke_poly(self, MapOrient.corners(prev, HEX_SIZE * 0.45), hud, _px(2.5))
		# A carrier's block where it would land (the Swallowtail's carry, Ryan, 21 October): each
		# rider's hex outlined; one it cannot land on dashed and struck through, and the stop
		# itself crossed and tagged, so the player changes it before letting go. By structure,
		# never by hue alone (Ryan is colourblind), and heavy, for the phone.
		var bad: Array = draft_land.get("bad", [])
		var lands: Dictionary = draft_land.get("to", {})
		for r in lands.keys():
			var lh: Vector2i = lands[r]
			var pts := MapOrient.corners(center(lh), HEX_SIZE - _px(6.0))
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
	# tagged; they come first on the player's turn, and the catch is drawn as the prey's order
	# onto its hunters, below.
	if _anim.is_empty() and fight_group.is_empty():
		for f in forced:
			var prey: Unit = f["prey"]
			for h in f["hunters"]:
				_contact_effect((h as Unit).pos, true, true)
			Hud.brackets(self, Rect2(center(prey.pos) - Vector2(HEX_SIZE, HEX_SIZE) * 0.9, Vector2(HEX_SIZE, HEX_SIZE) * 1.8), _px(12.0), Palette.ENEMY, _px(3.0))
			_plaque(center(prey.pos) + Vector2(0.0, -HEX_SIZE * 1.05), "CAUGHT", Palette.ENEMY, 2.0)
	# The orders (bible section 5): a line from each machine to the pack it is ordered onto, in
	# the display's light, dashes crawling toward the pack; a caught machine's to its hunters.
	if _anim.is_empty() and fight_group.is_empty():
		for pair in order_pairs():
			_order_line(pair[0], pair[1])
	# The fight shown (bible section 5): the next one ENGAGE opens, the one a dragged machine
	# is over, or a pack looked at: its pack lit, the machines in it bracketed. No band says where
	# a machine must stand (the long wall brief 7.2): beside the pack, which the lit move shows.
	if not attack.is_empty() and _anim.is_empty():
		var targets: Array = attack.get("targets", [])
		var group: Array = targets
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
	# The queue (the long wall brief 7.4): each fight waiting numbered in the order ENGAGE opens
	# it, on its pack (a catch's on the machine caught). No pip under a machine says whether it can
	# still act: the board under the map says it, each machine's row (Ryan, 9 November: "I don't
	# like the action-remaining marker, it causes clutter and confusion. Remove, the panel does that
	# job").
	if _anim.is_empty() and fight_group.is_empty():
		for k in range(queue.size()):
			var q: Dictionary = queue[k]
			var on: Unit = q["target"] if q["target"] != null else q["prey"]
			if on != null:
				_queue_number(center(on.pos) + Vector2(-HEX_SIZE * 0.62, -HEX_SIZE * 0.55), k + 1)

	_draw_caches()
	for u in field.units:
		_draw_unit(u)
	for prey in hunted.keys():
		_hunted_tag(prey, hunted[prey])
	for sq in hunting.keys():
		_hunter_chip(sq, hunting[sq])

	if selected != null:
		var c := _unit_center(selected)
		Hud.brackets(self, Rect2(c - Vector2(HEX_SIZE, HEX_SIZE) * 0.85, Vector2(HEX_SIZE, HEX_SIZE) * 1.7), _px(12.0), hud, _px(2.0))
	if _tap_due >= 0.0 or _second:
		# A tap waiting out the double-tap window: its hex lit from the touch, as a die's is.
		var tc := center(_tap_hex)
		Hud.brackets(self, Rect2(tc - Vector2(HEX_SIZE, HEX_SIZE) * 0.85, Vector2(HEX_SIZE, HEX_SIZE) * 1.7), _px(12.0), Color(hud, 0.7), _px(2.0))

	_screen_space()   # from here, screen space
	# The HUD's own marks (the frame, the bars, their text) are drawn in screen space at
	# their positions under the zoom, so they stay crisp and their lines stay thin however
	# far the reconstruction is zoomed (Ryan, 22 September).
	if _map3d != null and frame_alpha > 0.0:
		_draw_frame(hud)
	_draw_seam_front()
	_draw_tears()
	_draw_tags()
	if _map3d != null:
		_map3d.set_marks(_ground_marks)
		_ground_marks = []
	# The whole battlefield is a projection, the same one as the skirmish's backdrop: its
	# faint scanlines and its soft band drifting down, over everything, foes and overlays
	# too (Ryan, 21 September).
	Hud.scanlines(self, Rect2(Vector2.ZERO, size))


## A fight's place in the queue: its number on a disc in the display's light, ringed heavy, on
## the pack it opens on; drawn on screen at its place, so it holds its size at every zoom.
func _queue_number(at: Vector2, n: int) -> void:
	_screen_space()
	var p := to_screen(at)
	var r := 13.0
	draw_circle(p, r + 2.0, Palette.BG)
	draw_circle(p, r, Palette.HUD)
	draw_arc(p, r + 2.0, 0.0, TAU, 24, Palette.BG, 2.0)
	var font := Hud.display_bold()
	var t := str(n)
	var tw := font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
	draw_string(font, p + Vector2(-tw * 0.5, 7.0), t, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Palette.BG)
	_map_space()


## The attack orders the map draws (bible section 5), [[machine, pack], ...]: each machine's
## order onto the pack it fights, then a caught machine's onto each hunter that caught it (Ryan,
## 2 November: "when caught, the unit should show the attack order on the enemy that caught it
## for clarity"), one line a pair however it came.
func order_pairs() -> Array:
	var out: Array = []
	if field == null:
		return out
	for uid in orders.keys():
		var m := field.unit_by_id(int(uid))
		var target: Unit = orders[uid]
		if m != null and target != null and field.units.has(target):
			out.append([m, target])
	for f in forced:
		var prey: Unit = f["prey"]
		if not field.units.has(prey):
			continue
		for h in f["hunters"]:
			if field.units.has(h) and orders.get(prey.id, null) != h:
				out.append([prey, h])
	return out


## An attack order on the map (bible section 5): a line from the machine, where its move ends,
## to the pack it fights, in the display's light under a wide faint band, dashes crawling toward
## the pack and an arrowhead short of it. Map space.
func _order_line(m: Unit, target: Unit) -> void:
	var hud := Palette.HUD
	var a := center(m.pos)
	var b := center(target.pos)
	var dir := (b - a).normalized()
	a += dir * HEX_SIZE * 0.55
	b -= dir * HEX_SIZE * 0.6
	draw_line(a, b, Color(hud, 0.35), _px(6.0))
	_dashed_line(a, b, hud, HEX_SIZE * 0.2, fmod(_ring_t * 2.0, 2.0))
	var side := Vector2(-dir.y, dir.x)
	draw_polyline(PackedVector2Array([b - dir * _px(10.0) + side * _px(8.0), b, b - dir * _px(10.0) - side * _px(8.0)]), hud, _px(3.0))


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
	if MapOrient.wall_left:
		# The rows run across: the ruler along the top and the foot, a tick a row counted from
		# the gate, clear of the corner readouts.
		for sy in [top, bottom]:
			var dir := 1.0 if sy < size.y * 0.5 else -1.0
			draw_line(Vector2(FRAME_SIDE, sy), Vector2(size.x - FRAME_SIDE, sy), fc, 2.0)
			for row in range(map.height - BattleMap.GATE_ROWS):
				var x := to_screen(Vector2(center(Hex.offset_to_axial(0, row)).x, 0.0)).x
				if x < FRAME_SIDE + 30.0 or x > size.x - FRAME_SIDE - 30.0:
					continue
				draw_line(Vector2(x, sy), Vector2(x, sy + 10.0 * dir), fc, 2.0)
				var label := "%02d" % (map.height - BattleMap.GATE_ROWS - row)
				var ly: float = (sy + 26.0) if dir > 0.0 else (sy - 14.0)
				draw_string(font, Vector2(x - label_w * 0.5, ly), label, HORIZONTAL_ALIGNMENT_LEFT, -1, FRAME_FONT, fc)
		_readout(font, Vector2(FRAME_SIDE + 8.0, top + 19.0 + 26.0), "SEC %02d // %s // RECON" % [map.map_seed % 100, BattleMap.KINDS[map.kind]["name"]], fc)
		_readout(font, Vector2(FRAME_SIDE + 8.0, bottom - 8.0 - 26.0), "CARE // PROJECTOR LINE", fc)
		return
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


## The hex a tap asked about (a pack, the ground): lit while its readout is up. The gate and the
## rift carry no bar and no selection on the map (Ryan, 9 November: "The rift and wall no longer
## need to show their bars, nor be selectable"): their numbers are the top bar's (TopBar).
var inspected := Vector2i(-9999, -9999)


## The caches lying on the field (the bible's loot rows; built 7 November). A cache's picture is
## its model while its hex is the reconstruction's (Map3D's, Ryan, 9 November: "can we get models
## (and art, when flattened), for loot caches on map?") and its flat token once the painting has
## taken the hex (art/loot, tools/loot_tokens.py), crossing over with the ground as the
## compositor does. What says how good it is stands over the picture in both worlds: a chest on
## a plate, the plainer the poorer (_chest), and no name (Ryan, 10 November: "Caches on the map
## don't need their name. Instead, change their icon from the pips to something representing how
## rare of a "chest" it is. Use chest iconography since the player gets that instantly"); its
## name is the readout's, on a tap. A kind with no model, and every cache drawn headless, wears
## the chest alone, larger. Under the units: a machine standing on one draws over its dimmed
## mark, and claims it as the turn ends. First cuts, judged on the phone.
const CACHE_TOKEN := 3.0   # a cache's token, in screen pixels a texel at zoom 1: a little over a foe's (2.6), hot for the phone
const CHEST := 36.0        # the chest's plate on screen, held at every zoom: hot, for the phone

func _draw_caches() -> void:
	if field == null or field.caches.is_empty():
		return
	var db := ContentDB.load_default()
	_map_space()
	for c in field.caches:
		var h: Vector2i = c["pos"]
		var at := center(h)
		var t := int(c.get("tier", 1))
		var a := 0.45 if field.unit_at(h) != null else 1.0
		var kind := db.loot_kind_of_tier(t)
		if _map3d == null or not Map3D.has_cache_model(kind):
			_chest(at, t, a, CHEST * 1.3)
			continue
		# The token over the painting, by how much of the hex the painting has (the model's own
		# sinking is Map3D's, by the same threshold).
		var flat := 1.0 - _solid_at(h)
		var tex := Sprites.map_cache(kind)
		if flat > 0.02 and tex != null:
			var ts := tex.get_size() * CACHE_TOKEN
			draw_texture_rect(tex, Rect2((at - Vector2(ts.x * 0.5, ts.y - SPRITE_FEET)).floor(), ts), false, Color(1, 1, 1, flat * a))
		_chest(at + Vector2(0.0, -HEX_SIZE * 0.86), t, a, CHEST)


## How good a cache is, as a chest on a dark plate (drawn in screen space at the map point `at`,
## so it holds its size at every zoom), told by what the chest is made of and never by a hue.
## Every tier is the same chest, a box under a domed lid, and each adds to the last: tier one
## bare, an outline with a latch; tier two strapped, two bands down it and a lock plate; tier
## three a treasure chest, solid, its straps and lock cut out of it, a glint over it, on a plate
## with a double border.
func _chest(at: Vector2, tier: int, a: float, plate: float) -> void:
	_screen_space()
	var p := to_screen(at)
	var ink := Color(Palette.INK, a)
	var dark := Color(Palette.BG, a)
	var rect := Rect2(p - Vector2(plate, plate) * 0.5, Vector2(plate, plate))
	draw_rect(rect.grow(2.0), Color(Palette.BG, 0.92 * a), true)
	draw_rect(rect.grow(2.0), ink, false, 1.5)
	if tier >= 3:
		draw_rect(rect.grow(5.5), ink, false, 1.5)
	var w := plate * 0.74
	var seam := p.y - plate * 0.02            # where the lid meets the box
	var foot := p.y + plate * 0.32
	var crown := plate * 0.30                 # the dome's height
	var dome := PackedVector2Array()
	for i in range(13):
		var ang := PI + PI * float(i) / 12.0
		dome.append(Vector2(p.x + cos(ang) * w * 0.5, seam + sin(ang) * crown))
	var body := Rect2(p.x - w * 0.5, seam, w, foot - seam)
	if tier >= 3:
		draw_colored_polygon(dome, ink)
		draw_rect(body, ink, true)
		draw_line(Vector2(body.position.x, seam), Vector2(body.end.x, seam), dark, 2.0)
	else:
		var closed := dome.duplicate()
		closed.append(dome[0])
		draw_polyline(closed, ink, 2.0)
		draw_rect(body, ink, false, 2.0)
	var mark := dark if tier >= 3 else ink
	if tier >= 2:
		for band in [-0.27, 0.27]:
			var bx: float = band
			var x: float = p.x + w * bx
			draw_line(Vector2(x, seam - crown * sqrt(maxf(0.0, 1.0 - 4.0 * bx * bx))), Vector2(x, foot), mark, 2.0)
		draw_rect(Rect2(p.x - 3.5, seam - 3.0, 7.0, 8.0), mark, true)   # the lock plate
		if tier >= 3:
			draw_rect(Rect2(p.x - 1.5, seam - 1.0, 3.0, 4.0), ink, true)   # its keyhole, lit
	else:
		draw_line(Vector2(p.x, seam - 2.0), Vector2(p.x, seam + 4.0), ink, 2.0)   # a latch
	if tier >= 3:
		var g := Vector2(rect.end.x - 5.0, rect.position.y + 5.0)   # the glint
		for d in [Vector2(4.5, 0), Vector2(0, 4.5)]:
			draw_line(g - d, g + d, ink, 1.5)
	_map_space()


## How much of a hex is still the reconstruction's, 1 solid to 0 under the painting (Bleed.solid,
## the compositor's threshold); 1 with no 3D map, which paints nothing.
func _solid_at(h: Vector2i) -> float:
	if _map3d == null:
		return 1.0
	if _bleed_src.is_empty():
		_bleed_grad = Bleed.gradient(field, _origin, HEX_SIZE, seam_shown)
		_bleed_src = Bleed.sources(field, _origin, HEX_SIZE, _anim_px)
	return Bleed.solid(base(h), _bleed_grad, _bleed_src)


## The tears (30 October): each a small vortex ring in the rift's own light on the seam's
## ground, with its name, so where the next flood comes from is known an interval ahead. The
## ring is sized to its hex and stands on it in map space, its lines one width at every zoom;
## its name is a plaque on screen at that place. Called from screen space and left there (the
## ring was once drawn in it too, at its map position, so it hung at one place on the glass
## while the map scrolled under it: Ryan, 10 November, "it's just fixed in place as I pan
## around"). A tear that opened at the peak just played waits unseen for its opening
## (tears_shown) and then bursts open (_tear_opening). A first cut, judged running on the phone.
func _draw_tears() -> void:
	var n := field.tears.size() if tears_shown < 0 else mini(tears_shown, field.tears.size())
	for i in range(n):
		_map_space()
		var c := center(field.tears[i]["pos"])
		var age: float = _ring_t - float(_tear_born[i]) if _tear_born.has(i) else TEAR_OPEN_SECONDS
		var grow := 1.0
		if age < TEAR_OPEN_SECONDS:
			grow = _tear_opening(field.tears[i]["pos"], c, age)
		var r := HEX_SIZE * 0.55 * grow
		draw_arc(c, r, 0.0, TAU, 24, Color(Palette.ENEMY, 0.9), _px(3.0))
		draw_arc(c, r * 0.6, 0.0, TAU, 18, Color(Palette.ENEMY, 0.6), _px(2.0))
		for k in range(6):
			var a := float(k) * TAU / 6.0 + fmod(_ring_t, TAU)
			draw_line(c + Vector2(cos(a), sin(a)) * r * 0.6, c + Vector2(cos(a + 0.5), sin(a + 0.5)) * r, Color(Palette.ENEMY, 0.8), _px(2.0))
		if age > TEAR_OPEN_SECONDS * 0.3:
			_plaque(c + Vector2(0.0, -HEX_SIZE * 0.55 - 12.0), _term("tear"), Palette.ENEMY, 1.5)
	_screen_space()


## A battlefield term's name for a plaque, content's own (the vocabulary's entry).
static func _term(id: String) -> String:
	return ContentDB.load_default().term_name(id).to_upper()


## A tear opening, `age` seconds in (map space): a white burst on its hex that goes to the
## enemy's violet, the hex lit under it, and three heavy rings thrown out one after another past
## its neighbours, while the ring itself springs open from a point and overshoots. By motion and
## by weight, hot for the phone. Returns the ring's size, 0 to a little over 1.
const TEAR_OPEN_SECONDS := 1.3

func _tear_opening(h: Vector2i, c: Vector2, age: float) -> float:
	var u := clampf(age / TEAR_OPEN_SECONDS, 0.0, 1.0)
	_fill(h, Color(Palette.ENEMY, 0.75 * (1.0 - u)))
	var flash := clampf(age / 0.28, 0.0, 1.0)
	if flash < 1.0:
		draw_circle(c, HEX_SIZE * (0.3 + 1.1 * flash), Color(Color.WHITE.lerp(Palette.ENEMY, flash), 0.85 * (1.0 - flash)))
	for k in range(3):
		var ph := (age - float(k) * 0.16) / 0.85
		if ph <= 0.0 or ph >= 1.0:
			continue
		var eased := 1.0 - (1.0 - ph) * (1.0 - ph)
		draw_arc(c, HEX_SIZE * (0.4 + 2.4 * eased), 0.0, TAU, 48, Color(ENEMY_HOT if k == 0 else Palette.ENEMY, 1.0 - ph), _px(7.0 * (1.0 - ph) + 2.0))
	# The ring springs open: past its size and back (a back ease).
	var g := clampf(age / 0.55, 0.0, 1.0) - 1.0
	return 1.0 + 2.2 * g * g * g + 1.2 * g * g


# ---------------------------------------------------------------- the cutscenes

## The map shows a thing as it happens (Ryan, 10 November: a tear "needs ... an
## animation/cutscene when one opens. And an animation/cutscene when the seam moves, too"; "We
## should pan and zoom to hunters when they acquire as well"): it glides to the thing, zooming in
## on what stands on one hex (a tear, a hunter), shows it, and glides back to where the player
## was looking, at the zoom they had. One plays at a time and nothing is taken while it plays, on
## the map or off it, and nothing skips it; headless, or with nothing to show, it hands on at once. First cuts, judged running.
##
## A peak of Rift Pressure: the field has already peaked when the enemy's turn is taken, so the
## screen calls hold_peak before it (the map keeps the seam where it stood and the new tears
## unseen while the packs walk) and play_peak after the walks: the map glides to the seam, the
## painting's edge sweeps to its new row under a hot violet front with its name on it, then the
## map glides in on each new tear as it bursts open (RIFTGATE_PEAK_DEBUG=1 peaks every enemy
## turn). A hunter's lock: play_locks glides in on each hunter that turned on a machine, in
## turn, and the screen declares it there.
signal peak_beat(what: String)   # "seam" as the creep starts, "tear" as each opens: the screen's sounds
signal cutscene_changed(playing: bool)   # one began or ended: the screen takes no input while one plays

const CUT_GLIDE := 0.45          # the map's glide to a thing and back
const CUT_ZOOM := 1.6            # the zoom on what stands on one hex, a tear or a hunter; a player zoomed further in keeps their own
const SEAM_SWEEP := 1.2          # the edge's sweep to its new row
const SEAM_FADE := 0.6           # the front's fade once it stands
const LOCK_HOLD := 2.0           # the map held on a hunter while its declaration shows

var _cut_tween: Tween = null
var _cut_done := Callable()
var _cut_home := Vector3.ZERO    # the scroll (x, y) and the zoom (z) the cutscene started from
var _cut_cam := Vector3.ZERO     # the map point at mid-screen (x, y) and the zoom (z) the last glide ends on
var _tear_born: Dictionary = {}  # a tear's index -> the clock (_ring_t) its opening began at
var _seam_front := -1.0          # the clock the seam's sweep began at; under 0, no front is drawn
var _seam_to := 0.0              # the row the sweep ends on
var _spawn_hidden: Dictionary = {}   # a pack's id -> true: unseen until its arrival is played (hold_spawn)
var _spawn_born: Dictionary = {}     # a pack's id -> the clock (_ring_t) its arrival began at


## Keep the seam and the tears as they stand now, through whatever the field does next.
func hold_peak() -> void:
	if field == null:
		return
	seam_shown = float(field.seam_row)
	tears_shown = field.tears.size()


## Whether a cutscene is playing.
func cutscene_playing() -> bool:
	return _cut_tween != null


## Play what the field did since hold_peak (the seam's creep, the tears opened), then `done`.
func play_peak(done: Callable) -> void:
	var crept: bool = field != null and seam_shown >= 0.0 and float(field.seam_row) > seam_shown
	var opened: int = (field.tears.size() - tears_shown) if field != null and tears_shown >= 0 else 0
	if not _can_play() or (not crept and opened <= 0):
		_end_cutscene()
		if done.is_valid():
			done.call()
		return
	var tw := _begin_cutscene(done)
	if crept:
		# The seam, where the player is looking along the wall: its old edge and its new both in
		# view, the middle of the creep at the middle of the screen across the field, at the
		# player's own zoom (the seam is the whole field's, nothing to close in on).
		_seam_to = float(field.seam_row)
		var mid := (Bleed.seam_edge(field, _origin, HEX_SIZE, seam_shown) + Bleed.seam_edge(field, _origin, HEX_SIZE, _seam_to)) * 0.5
		var axis := Bleed.axis()
		var here := to_map(size * 0.5)
		_glide_to(tw, here + axis * (mid - here.dot(axis)), zoom)
		tw.tween_callback(func() -> void:
			_seam_front = _ring_t
			peak_beat.emit("seam"))
		tw.tween_property(self, "seam_shown", _seam_to, SEAM_SWEEP).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tw.tween_interval(0.35)
	for i in range(maxi(0, tears_shown), field.tears.size()):
		_glide_to(tw, center(field.tears[i]["pos"]), maxf(zoom, CUT_ZOOM))
		tw.tween_callback(func() -> void:
			tears_shown = i + 1
			_tear_born[i] = _ring_t
			peak_beat.emit("tear"))
		tw.tween_interval(TEAR_OPEN_SECONDS + 0.2)
	_glide_home(tw)


## The hunters that turned on a machine, shown one after another ([[hunter, prey], ...]): the
## map glides in on each hunter, `each` is called with the pair as it arrives (the screen's
## declaration) and the map holds there while it shows; then home, then `done`. The hunter
## stands `at_y` down the view (under the screen's band; the middle when not given). With
## nothing to play `each` is still called for every pair, at once.
func play_locks(locks: Array, each: Callable, done: Callable, at_y: float = -1.0) -> void:
	if not _can_play() or locks.is_empty():
		for pair in locks:
			each.call(pair[0], pair[1])
		if done.is_valid():
			done.call()
		return
	var tw := _begin_cutscene(done)
	for pair in locks:
		var hunter: Unit = pair[0]
		var z := maxf(zoom, CUT_ZOOM)
		var drop := (at_y - size.y * 0.5) if at_y >= 0.0 else 0.0
		_glide_to(tw, center(shown_hex(hunter)) - Vector2(0.0, drop / z), z)
		tw.tween_callback(each.bind(hunter, pair[1]))
		tw.tween_interval(LOCK_HOLD)
	_glide_home(tw)


## A pack shown as it arrives (Ryan, 10 November: "After fracture, we should zoom and introduce
## the elite as it spawns"): hold_spawn keeps it unseen, then play_spawn glides in on its hex,
## zoomed, lets it burst in (the tear's burst, its picture coming up out of it), calls `shown` as
## it does (the screen's introduction) and holds there while that shows; then home, then `done`.
## With nothing to play it is simply shown, `shown` and `done` called at once.
func hold_spawn(u: Unit) -> void:
	if u != null:
		_spawn_hidden[u.id] = true


func play_spawn(u: Unit, shown_cb: Callable, done: Callable, at_y: float = -1.0) -> void:
	if not _can_play() or u == null:
		_spawn_hidden.clear()
		if shown_cb.is_valid():
			shown_cb.call()
		if done.is_valid():
			done.call()
		return
	var tw := _begin_cutscene(done)
	var z := maxf(zoom, CUT_ZOOM)
	var drop := (at_y - size.y * 0.5) if at_y >= 0.0 else 0.0
	_glide_to(tw, center(u.pos) - Vector2(0.0, drop / z), z)
	tw.tween_callback(func() -> void:
		_spawn_hidden.erase(u.id)
		_spawn_born[u.id] = _ring_t
		if shown_cb.is_valid():
			shown_cb.call())
	tw.tween_interval(LOCK_HOLD + 0.4)
	_glide_home(tw)


## Whether a cutscene can play here: on a screen, in the tree.
func _can_play() -> bool:
	return DisplayServer.get_name() != "headless" and is_inside_tree() and field != null


## Start a cutscene: its tween, the view it began on to come home to, and what follows it.
func _begin_cutscene(done: Callable) -> Tween:
	if _cut_tween != null:
		_finish_cutscene()   # one at a time: the one playing ends where it would have
	_cut_done = done
	_cut_home = Vector3(scroll_x, scroll_y, zoom)
	var mid := to_map(size * 0.5)
	_cut_cam = Vector3(mid.x, mid.y, zoom)
	_cut_tween = create_tween()
	# A finger down as it starts is let go: its drag, hold or pinch never lands under the glide.
	_pressed = false
	_dragged = false
	_holding = false
	_pinching = false
	_touches.clear()
	_route_drag = null
	cutscene_changed.emit(true)
	return _cut_tween


## A glide from where the last one ended to the map point `at` at mid-screen, at zoom `z`.
func _glide_to(tw: Tween, at: Vector2, z: float) -> void:
	var to := Vector3(at.x, at.y, z)
	tw.tween_method(_glide.bind(_cut_cam, to), 0.0, 1.0, CUT_GLIDE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_cut_cam = to


## The last glide, back to the view the cutscene began on, and its end.
func _glide_home(tw: Tween) -> void:
	var mid := (size * 0.5 - Vector2(_cut_home.x, _cut_home.y)) / _cut_home.z
	_glide_to(tw, mid, _cut_home.z)
	tw.tween_callback(_finish_cutscene)


## The view `u` of the way from one camera to another (a map point at mid-screen and a zoom),
## kept on the painted content: a cutscene may look past the scroll's own range into the
## scenery, so a tear at the field's end stands mid-screen and not under the frame at the edge.
func _glide(u: float, from: Vector3, to: Vector3) -> void:
	var cam := from.lerp(to, u)
	zoom = cam.z
	scroll_x = _clamp_axis(size.x * 0.5 - cam.x * zoom, 0.0, _map_size.x, size.x)
	scroll_y = _clamp_axis(size.y * 0.5 - cam.y * zoom, 0.0, _map_size.y, size.y)
	queue_redraw()


## The cutscene over, played out or skipped: the field as it stands, the view where it was.
func _finish_cutscene() -> void:
	if _cut_tween == null:
		return
	scroll_x = _cut_home.x
	scroll_y = _cut_home.y
	zoom = _cut_home.z
	var done := _cut_done
	_end_cutscene()
	if done.is_valid():
		done.call()


## Let a cutscene go, and a peak's hold with it: the seam and the tears drawn as the field has
## them.
func _end_cutscene() -> void:
	if _cut_tween != null:
		_cut_tween.kill()
		_cut_tween = null
		cutscene_changed.emit(false)
	_cut_done = Callable()
	seam_shown = -1.0
	tears_shown = -1
	_tear_born = {}
	_spawn_hidden = {}
	_spawn_born = {}
	if _seam_front >= 0.0 and _ring_t - _seam_front < SEAM_SWEEP:
		_seam_front = -1.0   # skipped mid-sweep: no front left standing where the edge is not
	queue_redraw()


## The seam's front while its creep plays and a moment after (map space, left in screen space):
## a wide violet band on the painting's moving edge across the whole field, a bright line in it
## and a white hairline in that, three fainter echoes trailing behind it toward the rift, and
## the seam's name on the line where the player is looking. A line and its motion, never a hue
## alone; hot for the phone.
func _draw_seam_front() -> void:
	if _seam_front < 0.0 or field == null:
		return
	var age := _ring_t - _seam_front
	if age > SEAM_SWEEP + 0.35 + SEAM_FADE:
		_seam_front = -1.0
		return
	var a := 1.0 - clampf((age - SEAM_SWEEP - 0.35) / SEAM_FADE, 0.0, 1.0)
	var row := seam_shown if seam_shown >= 0.0 else _seam_to
	var axis := Bleed.axis()
	var side := Vector2(-axis.y, axis.x)
	var edge := Bleed.seam_edge(field, _origin, HEX_SIZE, row)
	var r := _hex_bounds(field.map.all_hexes())
	r.position += _origin
	var mid := r.get_center()
	var half := maxf(r.size.x, r.size.y) * 0.5 + HEX_SIZE
	var on := axis * edge + side * mid.dot(side)
	_map_space()
	var moving := age < SEAM_SWEEP
	for k in range(3, 0, -1):
		var back := on - axis * HEX_SIZE * 0.45 * float(k)
		draw_line(back - side * half, back + side * half, Color(Palette.ENEMY, a * (0.5 - 0.13 * float(k)) * (1.0 if moving else 0.4)), _px(5.0))
	draw_line(on - side * half, on + side * half, Color(Palette.ENEMY, 0.45 * a), _px(22.0))
	draw_line(on - side * half, on + side * half, Color(ENEMY_HOT, a), _px(7.0))
	draw_line(on - side * half, on + side * half, Color(Color.WHITE, 0.9 * a), _px(2.0))
	var here := to_map(size * 0.5)
	_plaque(on + side * (here.dot(side) - on.dot(side)) + Vector2(0.0, -16.0 / zoom), _term("seam"), Color(Palette.ENEMY, a), 2.5)
	_screen_space()


## The one scan bar crosses the whole screen on the top layer (the battle screen draws it);
## it tells the map where it is, in this control's pixels, and the traces under it light.
func sweep_at(local_y: float) -> void:
	if _map3d != null:
		_map3d.set_sweep((local_y - scroll_y) / zoom if sweep_on else -1.0e6)


## The hex the vortex stands on: the rift's middle hex with the wall at the bottom, where its three
## hexes lie side by side under it; with the wall at the left they stack up the screen, so it stands
## on the lowest of them and rises over all three (Ryan, 9 November: "the rift sprite needs to be
## anchored on the lower hex in wall-left view").
func rift_foot(map: BattleMap) -> Vector2i:
	if not MapOrient.wall_left:
		return map.rift
	var foot: Vector2i = map.rift
	for r in map.rift_hexes:
		if base(r).y > base(foot).y:
			foot = r
	return foot


## How far below its foot hex's centre the vortex's picture ends, in hexes. With the wall at the
## bottom its foot hex is pointy-top, a whole radius from centre to its lowest point, and the
## picture ends a little inside it; with the wall at the left the hex is flat-top, 0.87 of a
## radius from centre to its lower edge, so the same drop hung the roots past the hex into the
## one below: there it ends as far inside its hex as the other view's does, a little higher
## (Ryan, 10 November: "wall-left, rift sprite needs to move up a tiny bit").
static func rift_drop() -> float:
	return 0.9 * (sqrt(3.0) * 0.5 if MapOrient.wall_left else 1.0)


## How far the vortex's picture stands off its foot hex's middle, in map pixels: with the wall at
## the left, a little to the right, away from the field and into the scenery behind it (Ryan,
## 10 November: "we should shift the rift to the right a bit in wall-left view").
static func rift_shift() -> float:
	return HEX_SIZE * 0.3 if MapOrient.wall_left else 0.0


const RIFT_FRAME_SECONDS := 0.7    # a frame, on the vortex's own clock
const RIFT_ON_BEAT := false        # true: one turn of the strip is a bar of the music instead (Ryan, 23 September: an option, off for now)
const RIFT_TEAR_ROWS := 16         # the bands the vortex is drawn in, for its tear

## The rift (Ryan, 23 September): a vortex tearing a hole in reality, in the foes' own
## register, standing over its three hexes and reaching up into the scenery, its spiral
## turning a little and back. The hexes under it are the hole's floor. Without the art,
## the old outline.
func _draw_rift(map: BattleMap) -> void:
	for r in map.rift_hexes:
		draw_colored_polygon(MapOrient.corners(center(r), HEX_SIZE - 3.0), Color("140a1f"))
	var tex := Sprites.rift()
	if tex == null:
		for r in map.rift_hexes:
			Hud.stroke_poly(self, MapOrient.corners(center(r), HEX_SIZE - 3.0), Palette.ENEMY, _px(2.0))
		return
	var fh := tex.get_size().y
	var frames := maxi(1, int(round(tex.get_size().x / fh)))   # square frames side by side
	var fw := tex.get_size().x / frames
	# On its own slow clock; or, with RIFT_ON_BEAT, one turn of the strip is a bar of the
	# music, four beats, however many frames it holds (it had landed near the beat by
	# chance once, and Ryan liked it, then wanted it slower).
	var beat := Sound.beat() if RIFT_ON_BEAT else -1.0
	var k := int(beat / 4.0 * frames if beat >= 0.0 else _ring_t / RIFT_FRAME_SECONDS) % frames
	var c := center(rift_foot(map)) + Vector2(rift_shift(), 0.0)
	var dest := Rect2((c - Vector2(fw * SPRITE_SCALE * 0.5, fh * SPRITE_SCALE - HEX_SIZE * rift_drop())).floor(), Vector2(fw, fh) * SPRITE_SCALE)
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
		var edge: String = t[2]
		var sq: Unit = t[1]
		if sq.is_player():
			_machine_tag(rect, sq, edge)
			continue
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
		if sq.is_boss:
			draw_string(Hud.mono(), rect.position + Vector2(0, rect.size.y - 6.0), "BOSS", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 12, Palette.INK)
		else:
			# Its threat rating, as the pack itself wears it (no count: 10 November).
			_pips_in(Rect2(rect.position.x, rect.end.y - 17.0, rect.size.x, 12.0), sq.squad, 7.0, 3.0)
		_tag_chevron(rect, edge, border)


## A chevron on a tag's outer edge, pointing the way to what it stands for.
func _tag_chevron(rect: Rect2, edge: String, col: Color) -> void:
	var out := {"top": Vector2(0, -1), "bottom": Vector2(0, 1), "left": Vector2(-1, 0), "right": Vector2(1, 0)}[edge] as Vector2
	var side := Vector2(-out.y, out.x)
	var tip := rect.get_center() + out * (rect.size * 0.5).dot(out.abs())
	var at := tip + out * 1.0
	draw_colored_polygon(PackedVector2Array([at + side * 6.0, at - side * 6.0, at + out * 6.0]), col)


## A machine past the edge: its name in the display's light, so the squad's split reads off
## screen too.
func _machine_tag(rect: Rect2, m: Unit, edge: String) -> void:
	var col := Palette.HUD
	Hud.box(self, rect, 6.0, Color(Palette.BG, 0.94), Color(col, 0.9), 1.5)
	var name := m.display_name.to_upper()
	draw_string(Hud.mono(), rect.position + Vector2(0, rect.size.y * 0.5 + 5.0), name.substr(0, 6), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 12, col)
	_tag_chevron(rect, edge, col)


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
		draw_colored_polygon(MapOrient.corners(center(h), HEX_SIZE - 3.0), col)


## Some of a hex's edges (corner i to i+1) as a line on the ground, the same way.
func _edges(h: Vector2i, idx: Array, col: Color) -> void:
	if _map3d != null:
		var m := _mark(h)
		m["edges"] = idx
		m["line"] = col
	else:
		var pts := MapOrient.corners(center(h), HEX_SIZE - 1.0)
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
# and the tapped pack's pulse. Since 30 October every mark of a foe's doing wears it (Ryan:
# "keep purple for enemy activities"): the contact, the gate's warning zones, the tags, the
# rift's bars and tears, so the warning parts from the plan by its structure, a ring of dashed
# hex edges against a line, its target and stripes. The register is four violets, the light
# one the palette's (Palette.ENEMY, the route's line and the field's bright) and three here:
# the deep (the field's dark and the line's crawling gaps), the edge under every violet line
# and border, and the bright the marks breathe toward. Picked by simulation, not by eye (Ryan
# is colourblind; docs/measurements.md, 29 September and 30 October).
static var ENEMY_DEEP := Color("6a30c0")   # the field's dark and the line's gaps (up again, Ryan, 30 September: it blended into the dark tiles)
static var ENEMY_EDGE := Color("2a0e4a")   # the edge under every violet line and border: deep violet, not black (Ryan, 29 September: black made candy canes)
static var ENEMY_HOT := Color("ecdcff")    # the bright the violet marks breathe toward, and the tapped intent's pulse top: a breath that shows in every vision (ΔE 12 to 17 from the violet, docs/measurements.md)

# The pair the field and the line draw with right now: the violet and its deep for a pack at
# rest, both lifted together on the tapped pack so the whole mark pulses (Ryan, 30 September:
# the pulse had been on the line alone).
var _field_hot: Color = Palette.ENEMY
var _field_deep: Color = ENEMY_DEEP

func _set_intent_pair(breathe: bool) -> void:
	var b := _intent_breath() if breathe else 0.0
	if not breathe:
		_field_hot = Palette.ENEMY
		_field_deep = ENEMY_DEEP
		return
	# The tapped pack swings the whole way: the light from under its resting value (halfway to
	# the deep) up to the bright, the dark from the edge up to halfway to the light.
	_field_hot = Palette.ENEMY.lerp(ENEMY_DEEP, 0.5).lerp(ENEMY_HOT, b)
	_field_deep = ENEMY_EDGE.lerp(ENEMY_DEEP.lerp(Palette.ENEMY, 0.5), b)
## Whether the intent marks wear that edge at all (Ryan, 30 September: trying them without);
## RIFTGATE_INTENT_EDGE=1 puts it back for a comparison. The solid line and its deep-violet
## crawling gaps stay either way: the gaps are the motion, the edge was only the contrast.
static func _intent_edged() -> bool:
	return OS.get_environment("RIFTGATE_INTENT_EDGE") == "1"

## The tapped pack's intent breathes between the violet and its bright, most of the way up
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
	return Palette.ENEMY.lerp(ENEMY_HOT, 0.35 + 0.65 * breath)



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
	Hud.stroke_poly(self, MapOrient.corners(c, HEX_SIZE - _px(3.0)), Color(Palette.ENEMY, a), _px(2.5))
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
			draw_polyline(pts, ENEMY_EDGE, _px(7.0))
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
			draw_polyline(chev, ENEMY_EDGE, _px(5.0))
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
		_crawl_poly(MapOrient.corners(end, HEX_SIZE - _px(5.5)), Color(0, 0, 0, 0), HEX_SIZE * 0.2, fmod(_ring_t * 1.5, 2.0), ENEMY_EDGE if _intent_edged() else Color(0, 0, 0, 0), phase)   # just inside the hex lines (Ryan, 30 September)
		return
	# A machine's target lock in the same construction (Ryan, 30 September), over the same
	# fields, in its line's two colours: the display's light, and the light at half.
	_field_hot = bright
	_field_deep = Color(bright, 0.5)
	_field_rings(end, DEST_RING, -1.0, 0.0)
	draw_circle(end, _px(3.5), bright)
	_crawl_poly(MapOrient.corners(end, HEX_SIZE - _px(5.5)), Color(0, 0, 0, 0), HEX_SIZE * 0.2, fmod(_ring_t * 1.5, 2.0))   # just inside the hex lines (Ryan, 30 September)


## Whether a pack's whole way shows: the pack tapped, and no other (Ryan, 10 November: "When a
## machine is selected, don't need to see the whole hunter path to them"; a hunter's chip and the
## machine's tag say who comes for whom).
func shows_whole_way(sq: Unit, _w: Battlefield.Walk) -> bool:
	return sq.pos == inspected


## Whether a pack's walk this turn ends with it attacking what it comes for: a pusher striking
## the wall from where it lands, a hunter catching its prey there. As the plan stands (the
## walks are read from where the planned machines will be), so it moves as the plans move.
static func attacks_on_landing(w: Battlefield.Walk) -> bool:
	return w != null and (w.strikes or w.catches != 0)


## Where a pack's walk ends this turn (Ryan, 9 November: "enemy unit path intents should have the
## end hex highlighted"; 10 November: "Enemy intended hexes should have the animated border, not
## a static one, even when unselected"): the hex tinted in the enemy's violet under a border of
## dashes crawling round it on a deep-violet track, brighter while the pack's whole way shows.
## Where it attacks from that hex this turn (attacks_on_landing), the warning stands on it,
## always, blinking ("If their landing hex this turn allows them to attack their target, that
## hex should have the warning triangle always visible, adjusted with previews and such"); a
## pack that attacks from where it stands wears the warning at its hex's corner, clear of its
## picture. A pack that stays and attacks nothing gets no mark.
func _walk_end(sq: Unit, w: Battlefield.Walk, lit: bool) -> void:
	var attacks := attacks_on_landing(w)
	var stays := w.path.is_empty()
	if stays and not attacks:
		return
	var c := center(w.end)
	if not stays:
		_fill(w.end, Color(Palette.ENEMY, 0.62 if lit else 0.45))
		_crawl_poly(MapOrient.corners(c, HEX_SIZE - _px(4.0)), ENEMY_HOT if lit else Palette.ENEMY, HEX_SIZE * 0.2, fmod(_ring_t * 1.5, 2.0), ENEMY_EDGE)
	if attacks:
		var at := c + (MapOrient.turn(Vector2(-0.5, -0.55)) * HEX_SIZE if stays else Vector2.ZERO)
		var blink := 0.55 + 0.45 * sin(_ring_t * 3.0)
		var r := _px(HEX_SIZE * (0.30 if stays else 0.40 + 0.06 * blink))
		draw_circle(at + Vector2(0.0, r * 0.12), r * 0.78, Color(ENEMY_EDGE, 0.85))   # its own dark ground, so it reads on any tile
		Glyphs.draw(self, "warning", at, r, Color(ENEMY_HOT, 0.6 + 0.4 * blink), _px(3.0))


## What a pack comes for, as a hex (Ryan, 10 November: "The "target" hexes for pushers and
## hunters should be the thing they're attacking. So an actual wall segment, and the actual
## machine"): a hunter's prey where the map shows it standing; a pusher's piece of the wall, the
## wall or gate hex beside where its way ends that lies nearest its own segment. NO_TARGET for
## a pack with nowhere to go.
const NO_TARGET := Vector2i(-9999, -9999)

func target_hex(sq: Unit, w: Battlefield.Walk) -> Vector2i:
	var prey := field.unit_by_id(w.prey) if w.prey != 0 else null
	if prey != null:
		return shown_hex(prey)
	var from: Vector2i = w.route[w.route.size() - 1] if not w.route.is_empty() else w.end
	var best := NO_TARGET
	var best_d := 1 << 20
	for n in Hex.neighbors(from):
		if not field.map.has(n) or not field.map.is_structure(n):
			continue
		var d := absi(Hex.axial_to_offset(n).x - sq.goal_col) if sq.goal_col >= 0 else 0
		if d < best_d:
			best = n
			best_d = d
	return best


## The attack mark, one for a pusher's target and a hunter's (Ryan, 10 November: "can we change
## the icon from the warning triangle to some kind of attack icon, like a sword? Can combine that
## with the hunter reticle somehow, both pushers and hunters can have the same icon"): the
## reticle's ring of three dashes turning round a sword, on a dark disc of its own so it reads
## on a wall, a machine or a plate. `px` is one screen pixel in the space it is drawn in.
func _attack_mark(c: Vector2, r: float, px: float = 1.0) -> void:
	draw_circle(c, r + 2.0 * px, Color(ENEMY_EDGE, 0.9))
	for k in range(3):
		var a := _ring_t * 1.6 + TAU * float(k) / 3.0
		draw_arc(c, r, a, a + TAU / 3.0 * 0.62, 10, ENEMY_HOT, 2.0 * px)
	Glyphs.draw(self, "sword", c, r * 1.15, Color.WHITE, 2.0 * px)


## A pack's way past this turn's walk (Walk.route), to its goal: a dashed violet line on a deep
## track, apart by structure from the walk's solid one, a chevron a step; each later turn's stop a
## numbered pip (2, 3, ...: when it gets there, as the field stands); and the thing it comes for
## (target_hex: the wall segment, the machine) under a crawling border with the attack mark on it.
func _way_on(sq: Unit, w: Battlefield.Walk) -> void:
	var from_i := w.path.size()
	var pts := PackedVector2Array([center(w.end) if from_i > 0 else center(sq.pos)])
	for i in range(from_i, w.route.size()):
		pts.append(center(w.route[i]))
	var col := Palette.ENEMY
	for i in range(pts.size() - 1):
		var a := pts[i]
		var b := pts[i + 1]
		if i == 0 and from_i == 0:
			a = a.lerp(b, 0.45)   # out of the sprite's edge, as the walk's leaves it
		draw_line(a, b, Color(ENEMY_EDGE, 0.85), _px(6.0))
		_dashed_line(a, b, col, HEX_SIZE * 0.16, 0.0, 0.0, 3.0)
		var dir := (b - a).normalized()
		var tip := a.lerp(b, 0.55)
		var side := Vector2(-dir.y, dir.x)
		var k := _px(5.0)
		draw_polyline(PackedVector2Array([tip - dir * k + side * k, tip, tip - dir * k - side * k]), col, _px(2.0))
	var tgt := target_hex(sq, w)
	if tgt != NO_TARGET:
		var tc := center(tgt)
		_crawl_poly(MapOrient.corners(tc, HEX_SIZE - _px(5.5)), ENEMY_HOT, HEX_SIZE * 0.2, fmod(_ring_t * 1.2, 2.0), ENEMY_EDGE)
		# On a machine the mark stands at its hex's corner, clear of the machine; on the wall, in
		# the hex's middle.
		var on_unit := field.unit_by_id(w.prey) != null if w.prey != 0 else false
		_attack_mark(tc + (MapOrient.turn(Vector2(0.5, -0.55)) * HEX_SIZE if on_unit else Vector2.ZERO), _px(15.0), _px(1.0))
	if w.route.is_empty():
		return
	# Each later turn's stop, numbered from the second (the first is this turn's, its end lit).
	var stops := field.turn_ends(sq, w)
	for n in range(stops.size()):
		_turn_pip(center(w.route[stops[n]]), n + 2)


## A later turn's stop on a pack's way: its turn's number on a dark disc ringed in the violet,
## held at its size on screen at every zoom.
func _turn_pip(at: Vector2, n: int) -> void:
	_screen_space()
	var p := to_screen(at)
	var r := 10.0
	draw_circle(p, r + 2.0, ENEMY_EDGE)
	draw_circle(p, r, Palette.BG)
	draw_arc(p, r, 0.0, TAU, 20, Palette.ENEMY, 2.0)
	var font := Hud.display_bold()
	var t := str(n)
	var tw := font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	draw_string(font, p + Vector2(-tw * 0.5, 5.0), t, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.INK)
	_map_space()


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
		_attack_mark(Vector2(rect.end.x - 15.0, rect.get_center().y), 10.0)
		# A tick from the first plate toward the machine, so the tag reads as its.
		if k == 0:
			var tip := Vector2(rect.end.x + 6.0, rect.end.y + 6.0)
			draw_colored_polygon(PackedVector2Array([Vector2(rect.end.x - 10.0, rect.end.y), Vector2(rect.end.x, rect.end.y - 8.0), tip]), Palette.ENEMY)
	_map_space()


## A hunter wears a chip of its own (Ryan, 10 November: hunters "should have a chip that shows a
## mini portrait of their target, same as the hunted gets"): one plate up and right of the pack,
## the mirror of the hunted machine's, the attack mark and then the machine it comes for, a
## small picture of its own model (the machine's name's first letter while it has none).
func _hunter_chip(sq: Unit, prey: Unit) -> void:
	_screen_space()
	var left := to_screen(_unit_center(sq) + Vector2(HEX_SIZE * 0.5, -HEX_SIZE * 0.78))
	var rect := Rect2(left + Vector2(0.0, -HUNT_TAG.y * 0.5), HUNT_TAG)
	draw_rect(rect.grow(2.0), Color(ENEMY_EDGE, 0.9), true)
	draw_rect(rect, Color(Palette.BG, 0.95), true)
	draw_rect(rect, Palette.ENEMY, false, 2.5)
	_attack_mark(Vector2(rect.position.x + 15.0, rect.get_center().y), 10.0)
	var face := Rect2(Vector2(rect.end.x - HUNT_TAG.y + 4.0, rect.position.y + 4.0), Vector2(HUNT_TAG.y - 8.0, HUNT_TAG.y - 8.0))
	var tex := portrait_of(prey)
	draw_rect(face, Color(Palette.HUD, 0.16), true)   # the machine's own light behind it, so its outline reads on the plate
	if tex != null:
		draw_texture_rect(tex, face.grow(3.0), false, Color(2.0, 2.0, 2.0, 1.0))   # lifted: the little render is lit for a floor, not a chip
	else:
		draw_string(Hud.mono(), face.position + Vector2(8.0, 22.0), prey.display_name.substr(0, 1).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Palette.HUD)
	# A tick from the plate toward the pack, so the chip reads as its.
	draw_colored_polygon(PackedVector2Array([Vector2(rect.position.x + 10.0, rect.end.y), Vector2(rect.position.x, rect.end.y - 8.0), Vector2(rect.position.x - 6.0, rect.end.y + 6.0)]), Palette.ENEMY)
	_map_space()


## A machine's small picture for a chip: its own model, fitted as it is, seen from the front and
## rendered once into a little viewport of its own; null headless and for a machine with no
## model.
var _portraits: Dictionary = {}   # machine id -> its MechView3D, or null

func portrait_of(u: Unit) -> Texture2D:
	if u == null or _map3d == null:
		return null
	if not _portraits.has(u.id):
		var view: MechView3D = null
		var db := ContentDB.load_default()
		if MechView3D.has_model(MechView3D.model_for(u.chassis_id)):
			view = MechView3D.make(u.chassis_id, db.maker_of(u.chassis_id), "clean", "", MechView3D.YAW_FRONT, Vector2i(48, 48), false, u.paint, MechView3D.plan_for(u, db))
			add_child(view)
		_portraits[u.id] = view
	var v: MechView3D = _portraits[u.id]
	return v.texture if v != null else null


## A selected machine's shield and hull as two gauges floating over its hex.
func _unit_gauges(u: Unit) -> void:
	_screen_space()
	var c := to_screen(_unit_center(u) + Vector2(0.0, -HEX_SIZE * 1.05))
	var w := HEX_SIZE * 1.3   # a hex's width at zoom 1, held at every zoom
	var r := Rect2(c.x - w * 0.5, c.y - 12.0, w, 6.0)
	for pair in [[u.hull, u.hull_max, Palette.HULL]]:   # the hull alone: the shield is the fight's (the long wall brief 7.5)
		draw_rect(r.grow(1.5), Color(Palette.BG, 0.9))
		draw_rect(r, Color(pair[2], 0.25))
		draw_rect(Rect2(r.position, Vector2(r.size.x * clampf(float(pair[0]) / maxf(1.0, float(pair[1])), 0.0, 1.0), r.size.y)), pair[2])
		Hud.ticks(self, r, int(pair[0]), int(pair[1]), pair[2])   # its scale, as every gauge wears it
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


## The edge of a region of hexes over the map (a machine's reach): each edge whose far side is
## outside the region, the line on a dark track so it reads on any ground. Corner i to i+1 faces
## DIRECTIONS[(6 - i) % 6] in either view (the flat-top corners are the pointy ones turned).
func _region_outline(region: Dictionary, col: Color, width: float) -> void:
	for pass_i in range(2):
		for h in region.keys():
			var nb := Hex.neighbors(h)
			var pts := MapOrient.corners(center(h), HEX_SIZE - _px(2.0))
			for i in range(6):
				if region.has(nb[(6 - i) % 6]):
					continue
				if pass_i == 0:
					draw_line(pts[i], pts[(i + 1) % 6], Color(Palette.BG, 0.7), _px(width + 3.0))
				else:
					draw_line(pts[i], pts[(i + 1) % 6], col, _px(width))


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


## "Badger + Kite vs ghouls ×6 + necromancers ×3": one contact group, in words.
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
	return "%s // %s" % [contact_text(group), ContentDB.load_default().term_name(field.map.ground_id(ground_h)).to_upper()]


## The frame's left and right lines in map pixels: the field plus a little, and the line
## the side blur begins at.
func _frame_x() -> Vector2:
	# Close on the play area, so the blur runs on outside it (Ryan, 23 September). With the wall
	# at the left the field's sides are the wall's ends, up and down the screen, and the
	# compositor's side blur reads across: none there (a first cut, judged on the phone).
	if MapOrient.wall_left:
		return Vector2(-1.0e7, 1.0e7)
	var r := _hex_bounds(field.map.all_hexes())
	return Vector2(_origin.x + r.position.x - HEX_SIZE * 0.22, _origin.x + r.end.x + HEX_SIZE * 0.22)


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
	return not _anim.is_empty() or not _anim_queue.is_empty() or _cut_tween != null


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
				var px: Vector2 = MapOrient.to_pixel(path[0], HEX_SIZE)
				_anim_px[mv[0]] = px
				if _map3d != null:
					_map3d.set_anim(mv[0], px, Vector2.ZERO)
			for rd in (mv[2] if mv.size() >= 3 else []):
				if _anim_px.has(rd[0]) or shown.has(rd[0]):
					continue
				var rpx: Vector2 = MapOrient.to_pixel(rd[1], HEX_SIZE)
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
					riders.append([rd[0], MapOrient.to_pixel(rd[1], HEX_SIZE) - MapOrient.to_pixel(mv[1][0], HEX_SIZE)])
				_anim[mv[0]] = {"path": mv[1], "t": 0.0, "curve": _curve_for(mv[0], mv[1]), "hex": 0, "riders": riders,
					"lands": mv[3] if mv.size() >= 4 else [], "rider_lands": mv[4] if mv.size() >= 5 else {}}
				# On its way: the animation has it now, from where it stood.
				shown.erase(mv[0])
				var start_px: Vector2 = MapOrient.to_pixel(mv[1][0], HEX_SIZE)
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
	var centres: Array = path.map(func(h): return MapOrient.to_pixel(h, HEX_SIZE))
	var step_px := MapOrient.to_pixel(Vector2i(0, 0), HEX_SIZE).distance_to(MapOrient.to_pixel(Hex.DIRECTIONS[0], HEX_SIZE))
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
		var step_px := MapOrient.to_pixel(Vector2i(0, 0), HEX_SIZE).distance_to(MapOrient.to_pixel(Hex.DIRECTIONS[0], HEX_SIZE))
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
		var under := MapOrient.from_pixel(px, HEX_SIZE)
		return _origin + px + Vector2(0, -_lift_at(under))
	return center(shown_hex(u))


func _draw_unit(u: Unit) -> void:
	if _spawn_hidden.has(u.id):
		return   # its arrival waits to be played (hold_spawn)
	var born := 1.0   # how far a pack arriving has come up, 0 to 1
	if _spawn_born.has(u.id):
		var age: float = _ring_t - float(_spawn_born[u.id])
		if age < TEAR_OPEN_SECONDS:
			_tear_opening(u.pos, _unit_center(u), age)   # the burst it comes out of, a tear's own
			born = clampf(age / 0.5, 0.0, 1.0)
	var hud := Palette.HUD
	if u.is_multi_hex():
		for h in u.hexes():
			draw_colored_polygon(MapOrient.corners(center(h), HEX_SIZE - 6.0), Color("4a2e66"))
	var c := _unit_center(u)
	var tex: Texture2D = null if u.is_player() else foe_picture(u)
	if _map3d != null and u.is_player() and not u.is_static():
		pass   # a mech is geometry in the 3D viewport; the gauge below stays
	elif tex != null:
		# A foe is a flat picture on the screen, never an object in the scene: no shadow, no
		# base, no lighting. It is the other world showing through (decided 19 September).
		# A small foe draws a little larger than its pixels, so it holds its own beside a mech; the
		# boss far larger (sprite_size).
		var ts := sprite_size(u, tex)
		draw_texture_rect(tex, Rect2((c - Vector2(ts.x * 0.5, ts.y - SPRITE_FEET)).floor(), ts), false, Color(1, 1, 1, born))   # its feet SPRITE_FEET below the hex's centre: a little lower toward the centre (Ryan, 29 September)
	elif u.is_player():
		draw_circle(c, 17.0, Palette.BG)
		draw_circle(c, 14.0, Palette.INK)
		var d: Vector2 = MapOrient.to_pixel(Hex.DIRECTIONS[u.facing], 1.0).normalized()
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
	# A pack wears its threat rating under it and no count (Ryan, 10 November: "The threat
	# display can go under the pack. Remove the unit count tag, its no longer needed").
	if u.is_enemy() and u.strength > 0:
		_threat_pips(c + Vector2(0.0, SPRITE_FEET), u.squad, Palette.ENEMY, u.is_boss)


## How big a foe's picture draws on the map at zoom 1: a pack's a little larger than its pixels,
## so it holds its own beside a machine; the boss's far larger, its frame BOSS_SPRITE_H tall (Ryan,
## 9 November: "enemy bosses need bigger map sprites. They disappear right now, they should be very
## big and ominous"), so the thing the battle is about towers over its ground and the rift's. The
## boss's picture is drawn for that size (foe_picture: a 48-pixel frame, so a texel of it is about
## a pack's token's), never its token enlarged.
const SPRITE_FEET := 22.0      # a picture's feet below its hex's centre
const BOSS_SPRITE_H := 128.0   # the boss's picture's frame on the map: 2.67 pixels a texel of its 48, a pack's token at 2.6

static func sprite_size(u: Unit, tex: Texture2D) -> Vector2:
	if tex == null:
		return Vector2(40, 40)
	var ts := tex.get_size()
	if u != null and u.is_boss:
		return ts * (BOSS_SPRITE_H / maxf(1.0, maxf(ts.x, ts.y)))
	return ts * SPRITE_SCALE * (1.3 if u != null and u.is_enemy() and not u.is_multi_hex() else 1.0)


const PIP := 9.0       # a threat pip's width on screen: hot, for the phone
const PIP_GAP := 4.0

## The pack's threat rating under the pack (the long wall brief 7.3; Ryan, 6 November: "The one
## thing we should do is show the threat rating of a formation on the map. For how many units
## it's intended for"; under the pack and alone since 10 November, the count badge gone): four
## machine pips on a plate at its feet, one filled for each machine it is intended for and the
## rest open, so the rating reads by structure, never by hue (Ryan is colourblind). The boss's
## plate has a heavier border. The one hint on the map: nothing says how to beat a pack (his
## word, 6 November). `feet` is the pack's feet in map space; the plate holds its size on screen.
func _threat_pips(feet: Vector2, n: int, border: Color, heavy: bool = false) -> void:
	_screen_space()
	var w := 4.0 * PIP + 3.0 * PIP_GAP + 10.0
	var rect := _plaque_rect(to_screen(feet) + Vector2(0.0, 4.0 + (PIP + 8.0) * 0.5), Vector2(w, PIP + 8.0))
	draw_rect(rect, Palette.BG, true)
	draw_rect(rect, border, false, 3.0 if heavy else 1.5)
	_pips_in(rect, n, PIP, PIP_GAP)
	_map_space()


## Four machine pips across the middle of `rect`, `n` of them filled.
func _pips_in(rect: Rect2, n: int, pip: float, gap: float) -> void:
	var x0 := rect.get_center().x - (4.0 * pip + 3.0 * gap) * 0.5
	for i in range(4):
		var pc := Vector2(x0 + pip * 0.5 + float(i) * (pip + gap), rect.get_center().y)
		var pts := Hex.corners(pc, pip * 0.5)
		if i < n:
			draw_colored_polygon(pts, Color.WHITE)
		else:
			pts.append(pts[0])
			draw_polyline(pts, Color(Color.WHITE, 0.7), 1.5, true)


# ---------------------------------------------------------------- gestures

## A touch let go on hex `h` without a drag or a hold: the double-tap when it came inside the
## window after a tap there; else a tap, which waits out the window when a unit stands there
## (it may be the first half of a double-tap) and lands at once on bare ground.
func tap_released(h: Vector2i) -> void:
	if _second:
		_second = false
		hex_double_tapped.emit(h)
	elif unit_at_shown(h) != null:
		_land_tap()   # a tap still waiting elsewhere lands first, in order
		_tap_hex = h
		_tap_due = Time.get_ticks_msec() / 1000.0 + DOUBLE_TAP_SECONDS
		queue_redraw()
	else:
		_land_tap()
		hex_tapped.emit(h)


## The waiting tap lands, if one waits.
func _land_tap() -> void:
	if _tap_due < 0.0:
		return
	_tap_due = -1.0
	hex_tapped.emit(_tap_hex)


func _gui_input(event: InputEvent) -> void:
	if _cut_tween != null:
		# Nothing is taken while a cutscene plays, and nothing skips it (Ryan, 10 November: "I
		# feel like I glitched one out by tapping, we should remove interactions while they run").
		accept_event()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pressed = true
			_dragged = false
			_holding = false
			_press_pos = event.position
			_last_pos = event.position
			_press_at = Time.get_ticks_msec() / 1000.0
			# A second touch inside the window on the hex a tap waits on: the tap never lands, and
			# this touch's release is the double-tap.
			_second = _tap_due >= 0.0 and _press_at <= _tap_due and field != null and hex_at(event.position) == _tap_hex
			if _second:
				_tap_due = -1.0
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
						tap_released(h)
			_second = false
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
	if _tap_due >= 0.0 and Time.get_ticks_msec() / 1000.0 >= _tap_due:
		_land_tap()
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
