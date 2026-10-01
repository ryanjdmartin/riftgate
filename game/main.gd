extends Node2D

## Debug map viewer. Generates a taller-than-screen battlefield, places sample mechs, packs
## and a three-hex boss, and draws terrain, the gate and rift structures, and every pack's
## previewed move. Drag to scroll. Tap (without dragging) to cycle the seed.

const HEX_SIZE := 44.0
const TOP := 150.0
const VIEW_W := 720.0
const VIEW_H := 1280.0
const MAP_W := 7
const MAP_H := 20
const DRAG_THRESHOLD := 12.0
const MAP_SPRITE_SCALE := 2.0

const COLORS := {
	BattleMap.Terrain.PLAIN: Color("6f8f5a"),
	BattleMap.Terrain.ROAD: Color("a89f7c"),
	BattleMap.Terrain.ROUGH: Color("7d7a4f"),
	BattleMap.Terrain.RUINS: Color("8a8a8a"),
	BattleMap.Terrain.WATER: Color("3f6f9c"),
	BattleMap.Terrain.MOUNTAIN: Color("4d4a52"),
}

var map: BattleMap
var field: Battlefield
var map_seed: int = 1
var origin := Vector2.ZERO
var scroll_y: float = 0.0
var font: Font
var _pressed := false
var _press_pos := Vector2.ZERO
var _dragged := false
var _last_pos := Vector2.ZERO


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST   # sprites
	font = ThemeDB.fallback_font
	_build(map_seed)


func _build(s: int) -> void:
	map = BattleMap.generate(MAP_W, MAP_H, s)
	field = Battlefield.new(map)
	var db := ContentDB.load_default()
	field.spawn_faction = db.default_faction()
	field.spawn_table = db.spawn_table(field.spawn_faction)
	var rng := RandomNumberGenerator.new()
	rng.seed = s
	var gate_o := Hex.axial_to_offset(map.gate)
	var i := 0
	for m in Loadouts.sample_mechs():
		var want := Hex.offset_to_axial(gate_o.x - 1 + i, gate_o.y - BattleMap.GATE_ROWS)
		m.pos = field.nearest_standable(m, want)
		field.add_unit(m)
		i += 1
	Loadouts.sample_packs(field, 3, rng)
	var boss := db.make_boss(0, field.spawn_faction)
	boss.pos = field.nearest_standable(boss, Hex.offset_to_axial(MAP_W / 2 - 1, 3))
	field.add_unit(boss)
	field.compute_intents()
	var px_w := sqrt(3.0) * HEX_SIZE * (map.width + 0.5)
	origin = Vector2((VIEW_W - px_w) / 2.0 + sqrt(3.0) * HEX_SIZE / 2.0, TOP)
	# Start scrolled to the gate end, where the player's units are.
	var map_px_h := HEX_SIZE * (1.5 * (map.height - 1) + 2.0)
	scroll_y = minf(0.0, VIEW_H - 80.0 - TOP - map_px_h)
	queue_redraw()


func _center(h: Vector2i) -> Vector2:
	return origin + Vector2(0, scroll_y) + Hex.to_pixel(h, HEX_SIZE)


func _draw() -> void:
	draw_rect(Rect2(0, 0, VIEW_W, VIEW_H), Color("1b1f26"))
	for h in map.all_hexes():
		draw_colored_polygon(Hex.corners(_center(h), HEX_SIZE - 1.5), COLORS[map.terrain[h]])
	for g in map.gate_hexes:
		draw_colored_polygon(Hex.corners(_center(g), HEX_SIZE - 1.5), Color("3a3f48"))
		draw_polyline(Hex.corners(_center(g), HEX_SIZE - 4.0) + PackedVector2Array([Hex.corners(_center(g), HEX_SIZE - 4.0)[0]]), Color("e8e4d6"), 3.0)
	for r in map.rift_hexes:
		draw_colored_polygon(Hex.corners(_center(r), HEX_SIZE - 1.5), Color("2a1a3f"))
		draw_polyline(Hex.corners(_center(r), HEX_SIZE - 4.0) + PackedVector2Array([Hex.corners(_center(r), HEX_SIZE - 4.0)[0]]), Color("a06be0"), 3.0)
	for sq in field.packs():
		var path: Array = field.intents.get(sq.id, [])
		var prev := _center(sq.pos)
		for step in path:
			var p := _center(step)
			draw_line(prev, p, Color(1.0, 0.45, 0.3, 0.9), 4.0)
			prev = p
		if not path.is_empty():
			draw_circle(prev, 6.0, Color(1.0, 0.45, 0.3))
	for u in field.units:
		var col := Color("e0e6ee") if u.is_player() else Color("c03a3a")
		if u.is_multi_hex():
			col = Color("a06be0")
			for h in u.hexes():
				draw_colored_polygon(Hex.corners(_center(h), HEX_SIZE - 6.0), Color("5a3a7a"))
		var c := _center(u.pos)
		var tex: Texture2D = null if u.is_player() else Sprites.map_foe(u.foe_id)
		if tex != null:
			var ts := tex.get_size() * MAP_SPRITE_SCALE
			# Feet a little below the hex centre so the sprite reads as standing on the tile.
			draw_texture_rect(tex, Rect2((c - Vector2(ts.x * 0.5, ts.y - 8.0)).floor(), ts), false)
		else:
			draw_circle(c, 17.0, Color("1b1f26"))
			draw_circle(c, 14.0, col)
			var initial := u.display_name.substr(0, 1).to_upper()
			draw_string(font, c + Vector2(-6.0, 6.0), initial, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("1b1f26"))
			if u.is_player():
				var d: Vector2 = Hex.to_pixel(Hex.DIRECTIONS[u.facing], 1.0).normalized()
				draw_line(c, c + d * 22.0, Color("f2c14e"), 3.0)
		if u.is_enemy() and u.strength > 0:
			draw_string(font, c + Vector2(12.0, -10.0), "x%d" % u.strength, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e8e4d6"))
	draw_rect(Rect2(0, 0, VIEW_W, TOP + 4.0), Color("1b1f26"))
	var header := "RIFTGATE   seed %d   gate %d/%d   pressure %d/%d   map %dx%d" % [
		map_seed, field.gate_hp, field.gate_hp_max, field.rift_pressure, field.rift_pressure_max, map.width, map.height]
	draw_string(font, Vector2(24.0, 60.0), header, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("e8e4d6"))
	var y := 92.0
	for sq in field.packs():
		var line := "%s  x%d  %s" % [sq.display_name, sq.strength, sq.behaviour]
		draw_string(font, Vector2(24.0, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("c9a0a0"))
		y += 18.0
	draw_string(font, Vector2(24.0, 1240.0), "drag: scroll   tap: next seed", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("8a94a0"))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pressed = true
			_dragged = false
			_press_pos = event.position
			_last_pos = event.position
		else:
			if _pressed and not _dragged:
				map_seed += 1
				_build(map_seed)
			_pressed = false
	elif event is InputEventMouseMotion and _pressed:
		if not _dragged and event.position.distance_to(_press_pos) > DRAG_THRESHOLD:
			_dragged = true
		if _dragged:
			var map_px_h := HEX_SIZE * (1.5 * (map.height - 1) + 2.0)
			var min_scroll := minf(0.0, VIEW_H - 80.0 - TOP - map_px_h)
			scroll_y = clampf(scroll_y + (event.position.y - _last_pos.y), min_scroll, 0.0)
			_last_pos = event.position
			queue_redraw()
