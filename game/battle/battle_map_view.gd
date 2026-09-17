class_name BattleMapView
extends Control

## The battlefield as a scrolling, touchable map in the overlay style. Draws terrain, the gate
## and the rift, every squad's previewed move, the routes the player has plotted, the hexes
## the selected mech can reach, and the units themselves.
##
## Gestures: drag to scroll; tap a hex (the screen decides what that means); hold a unit for
## its readout. The view owns no game logic.

signal hex_tapped(h: Vector2i)
signal unit_held(u: Unit)
signal hold_released

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
var scroll_y: float = 0.0

var _origin := Vector2.ZERO
var _tags: Array = []                # [[Rect2, Unit], ...] the off-screen portraits, as drawn
var _pressed := false
var _dragged := false
var _holding := false
var _press_pos := Vector2.ZERO
var _last_pos := Vector2.ZERO
var _press_at := 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	set_process(false)


func set_field(f: Battlefield) -> void:
	field = f
	_layout()
	scroll_to_bottom()
	queue_redraw()


func _layout() -> void:
	var px_w := sqrt(3.0) * HEX_SIZE * (field.map.width + 0.5)
	_origin = Vector2((size.x - px_w) / 2.0 + sqrt(3.0) * HEX_SIZE / 2.0, HEX_SIZE + TOP_PAD)


func _map_px_height() -> float:
	return HEX_SIZE * (1.5 * (field.map.height - 1) + 2.0) + TOP_PAD + BOTTOM_PAD


func _min_scroll() -> float:
	return minf(0.0, size.y - _map_px_height())


## Start at the gate end, where the player's machines stand.
func scroll_to_bottom() -> void:
	scroll_y = _min_scroll()


## Pixel centre of a hex in this control's coordinates.
func center(h: Vector2i) -> Vector2:
	return _origin + Vector2(0, scroll_y) + Hex.to_pixel(h, HEX_SIZE)


func hex_at(local: Vector2) -> Vector2i:
	return Hex.from_pixel(local - _origin - Vector2(0, scroll_y), HEX_SIZE)


## Scroll so the unit sits in the middle of the view.
func scroll_to_unit(u: Unit) -> void:
	var y := _origin.y + Hex.to_pixel(u.pos, HEX_SIZE).y
	scroll_y = clampf(size.y * 0.5 - y, _min_scroll(), 0.0)
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
		var c := center(sq.pos)
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
	for h in map.all_hexes():
		var pts := Hex.corners(center(h), HEX_SIZE - 1.5)
		draw_colored_polygon(pts, TERRAIN[map.terrain[h]])
		TerrainArt.draw(self, center(h), HEX_SIZE, map.terrain[h], h.x * 131 + h.y * 7919, 0.9)
		Hud.stroke_poly(self, pts, Color(hud, 0.10), 1.0)
	for g in map.gate_hexes:
		var pts := Hex.corners(center(g), HEX_SIZE - 3.0)
		draw_colored_polygon(pts, Color(hud, 0.10))
		Hud.stroke_poly(self, pts, Color(hud, 0.85), 2.0)
	for r in map.rift_hexes:
		var pts := Hex.corners(center(r), HEX_SIZE - 3.0)
		draw_colored_polygon(pts, Color("2a1a3f"))
		Hud.stroke_poly(self, pts, Palette.RIFT, 2.0)

	# Where the selected mech may end its move.
	for h in destinations.keys():
		var pts := Hex.corners(center(h), HEX_SIZE - 5.0)
		draw_colored_polygon(pts, Color(hud, 0.14))
		Hud.stroke_poly(self, pts, Color(hud, 0.55), 1.0)

	# Enemy previews: where each squad goes unless something stops it.
	for sq in field.squads():
		var path: Array = field.intents.get(sq.id, [])
		if path.is_empty():
			continue
		var prev := center(sq.pos)
		for step in path:
			var p := center(step)
			draw_line(prev, p, Color(Palette.ENEMY, 0.75), 3.0)
			prev = p
		draw_circle(prev, 5.0, Palette.ENEMY)

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

	for u in field.units:
		_draw_unit(u)

	if selected != null:
		var c := center(selected.pos)
		Hud.brackets(self, Rect2(c - Vector2(HEX_SIZE, HEX_SIZE) * 0.85, Vector2(HEX_SIZE, HEX_SIZE) * 1.7), 12.0, hud, 2.0)

	_draw_tags()


## Off-screen squads get a portrait at the edge nearest them: the source of the intent line.
func _draw_tags() -> void:
	_tags = offscreen_tags()
	for t in _tags:
		var rect: Rect2 = t[0]
		var sq: Unit = t[1]
		var above: bool = t[2]
		var border := Palette.RIFT if sq.elite else Palette.ENEMY
		Hud.box(self, rect, 6.0, Color(Palette.BG, 0.94), Color(border, 0.9), 1.5)
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


func _draw_unit(u: Unit) -> void:
	var hud := Palette.HUD
	if u.is_multi_hex():
		for h in u.hexes():
			draw_colored_polygon(Hex.corners(center(h), HEX_SIZE - 6.0), Color("4a2e66"))
	var c := center(u.pos)
	var tex: Texture2D = Sprites.map_mech(u.chassis_id, u.facing) if u.is_player() else Sprites.map_foe(foe_sprite_id(u))
	if tex != null:
		var ts := tex.get_size() * SPRITE_SCALE
		draw_texture_rect(tex, Rect2((c - Vector2(ts.x * 0.5, ts.y - 8.0)).floor(), ts), false)
	elif u.is_player():
		draw_circle(c, 17.0, Palette.BG)
		draw_circle(c, 14.0, Palette.INK)
		var d: Vector2 = Hex.to_pixel(Hex.DIRECTIONS[u.facing], 1.0).normalized()
		draw_line(c, c + d * 22.0, Palette.SELECT, 3.0)
	else:
		var r := 20.0 if u.is_multi_hex() else 14.0
		var diamond := PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)])
		draw_colored_polygon(diamond, Palette.RIFT if u.is_multi_hex() else Palette.ENEMY)
		draw_string(Hud.mono(), c + Vector2(-5.0, 5.0), u.display_name.substr(0, 1).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.BG)
	if u.is_player() and not u.is_static():
		# A sliver of hull over the machine, so the state of the team reads from the map.
		var w := 30.0
		Hud.gauge(self, Rect2(c + Vector2(-w * 0.5, -HEX_SIZE * 0.78), Vector2(w, 5.0)), float(u.hull) / float(maxi(1, u.hull_max)), hud, 2.0)
	if u.is_enemy() and u.strength > 0:
		draw_string(Hud.mono(), c + Vector2(10.0, -12.0), "×%d" % u.strength, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.INK)


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
			set_process(true)
		else:
			set_process(false)
			if _holding:
				hold_released.emit()
			elif _pressed and not _dragged and field != null:
				var tagged := _tag_at(event.position)
				if tagged != null:
					scroll_to_unit(tagged)
				else:
					var h := hex_at(event.position)
					if field.map.has(h):
						hex_tapped.emit(h)
			_pressed = false
			_holding = false
		accept_event()
	elif event is InputEventMouseMotion and _pressed and not _holding:
		if not _dragged and event.position.distance_to(_press_pos) > DRAG_THRESHOLD:
			_dragged = true
		if _dragged:
			scroll_y = clampf(scroll_y + (event.position.y - _last_pos.y), _min_scroll(), 0.0)
			_last_pos = event.position
			queue_redraw()
		accept_event()


func _process(_delta: float) -> void:
	if _pressed and not _dragged and not _holding and Time.get_ticks_msec() / 1000.0 - _press_at >= HOLD_SECONDS:
		_holding = true
		set_process(false)
		if field != null:
			var u := field.unit_at(hex_at(_press_pos))
			if u != null:
				unit_held.emit(u)
