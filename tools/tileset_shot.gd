extends SceneTree

## The domains' tilesets side by side, for judging (DomainGround): a row a domain, in content's
## order, its four decorative grounds and then its water and walls, each a hex at the map's
## size; a patch of field mixing them all, its roads and its crags joined up as the map joins
## them; and a small range of each look of wall (BattleMap.WALL_LOOKS: crags, mesas, towers,
## cliffs, chasms), each joined as a range is and ending as one does, a chasm sunk. Laid in the view's layout
## (MapOrient: RIFTGATE_MAP_VIEW=left|bottom), posterized as the map's compositor posterizes the
## painted world (bleed.gdshader), so it shows what the map shows.
## Needs a renderer:
##   xvfb-run -a godot --rendering-method gl_compatibility --path . -s tools/tileset_shot.gd -- out.png [frame]

const HEX := 48.0
const LEVELS := 5.0   # the compositor's posterize, steps a channel (bleed.gdshader's `levels`)
const GROUNDS := [BattleMap.Terrain.PLAIN, BattleMap.Terrain.ROAD, BattleMap.Terrain.ROUGH, BattleMap.Terrain.RUINS, BattleMap.Terrain.WATER, BattleMap.Terrain.MOUNTAIN]
## The patch: a few rows of field, which ground each hex is, by its index in GROUNDS, its rows
## laid odd-r as the map's are.
## A small range of each look: its walls' hexes, axial about its first, on a ring of plain ground.
const RANGE := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(2, 1)]
const PATCH := [
	[0, 0, 2, 2, 0, 5],
	[0, 1, 1, 2, 4, 5],
	[3, 3, 1, 0, 4, 4],
	[3, 0, 1, 0, 0, 5],
]

var _vp: SubViewport
var _frames := 0
var _out := "tilesets.png"


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 1:
		_out = args[0]
	var frame := int(args[1]) if args.size() >= 2 else 0
	var view := OS.get_environment("RIFTGATE_MAP_VIEW")
	if view == "left" or view == "bottom":
		MapOrient.wall_left = view == "left"
	var db := ContentDB.load_default()
	var rows: Array = []
	for id in db.factions.keys():
		var f: Dictionary = db.factions[id]
		rows.append([str(f.get("name", id)).to_upper(), str(f.get("bleed", ""))])
	var sheet := Sheet.new()
	sheet.rows = rows
	sheet.frame = frame
	sheet.size = sheet.layout()
	_vp = SubViewport.new()
	_vp.size = Vector2i(sheet.size)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_vp.canvas_item_default_texture_filter = SubViewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(_vp)
	_vp.add_child(sheet)
	process_frame.connect(_tick)


func _tick() -> void:
	_frames += 1
	if _frames < 4:
		return
	process_frame.disconnect(_tick)
	var img := _vp.get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	var data := img.get_data()
	for i in range(data.size()):
		if i % 4 != 3:
			data[i] = int(round(floorf(data[i] / 255.0 * LEVELS + 0.5) / LEVELS * 255.0))
	img = Image.create_from_data(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8, data)
	var err := img.save_png(_out)
	print("tilesets -> %s (%s)" % [_out, error_string(err)])
	quit(0 if err == OK else 1)


class Sheet extends Control:
	var rows: Array = []
	var frame := 0
	var _blocks: Array = []   # each domain's [title y, singles' centres, patch origin, ranges' origins]

	## Where everything goes, in the view's layout (each block placed by its own bounds, since the
	## wall-left view turns the hexes' layout), and the sheet's size.
	func layout() -> Vector2:
		_blocks = []
		var w := 2.0 * HEX   # a hex's width at most, in either layout
		var patch: Array = []
		for r in range(PATCH.size()):
			for q in range(PATCH[r].size()):
				patch.append(Hex.offset_to_axial(q, r))
		var ground := _range_ground()
		var pb := _bounds(patch)
		var rb := _bounds(ground.keys())
		var y := 30.0
		var right := 0.0
		for i in range(rows.size()):
			var singles: Array = []
			for k in range(GROUNDS.size()):
				singles.append(Vector2(30.0 + w * 0.5 + k * (w + 6.0), y + 26.0 + HEX))
			var px := 30.0 + GROUNDS.size() * (w + 6.0) + 20.0
			var patch_origin := Vector2(px, y + 26.0) - pb.position
			var top := y + 26.0 + maxf(2.0 * HEX + 24.0, pb.size.y) + 20.0
			var origins: Array = []
			for j in range(BattleMap.WALL_LOOKS.size()):
				origins.append(Vector2(30.0 + j * (rb.size.x + 16.0), top) - rb.position)
			_blocks.append([y, singles, patch_origin, origins])
			right = maxf(right, maxf(px + pb.size.x, 30.0 + float(BattleMap.WALL_LOOKS.size()) * (rb.size.x + 16.0)))
			y = top + rb.size.y + 40.0
		return Vector2(right + 20.0, y)

	## The bounds of some hexes in the view's layout about hex (0, 0).
	func _bounds(hexes: Array) -> Rect2:
		var lo := Vector2(INF, INF)
		var hi := Vector2(-INF, -INF)
		for hx in hexes:
			for p in MapOrient.corners(MapOrient.to_pixel(hx, HEX), HEX):
				lo = lo.min(p)
				hi = hi.max(p)
		return Rect2(lo, hi - lo)

	## A range's hexes and the ring of plain ground round them.
	func _range_ground() -> Dictionary:
		var ground := {}
		for hx in RANGE:
			ground[hx] = true
			for n in Hex.neighbors(hx):
				ground[n] = true
		return ground

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Palette.BG)
		var font := Hud.mono()
		var w := sqrt(3.0) * HEX
		for i in range(rows.size()):
			var name: String = rows[i][0]
			var biome: String = rows[i][1]
			var block: Array = _blocks[i]
			draw_string(font, Vector2(20.0, float(block[0]) + 14.0), "%s  (%s)" % [name, biome if not biome.is_empty() else "no bleed"], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Palette.INK)
			for k in range(GROUNDS.size()):
				var t: int = GROUNDS[k]
				var c: Vector2 = block[1][k]
				DomainGround.draw_columns(self, [_col(c, t, 7919 * (i + 1) + 131 * k, 0, "crags", 0)], HEX, frame, biome)
				var label := "walls" if t == BattleMap.Terrain.MOUNTAIN else str(BattleMap.TERRAIN_NAMES[t])
				draw_string(font, Vector2(c.x - w * 0.5, c.y + HEX + 16.0), label, HORIZONTAL_ALIGNMENT_CENTER, w, 14, Palette.MUTED)
			# The patch: the grounds as they lie together on a field, at the map's size, its walls a
			# range of crags joined as the map joins them.
			var origin: Vector2 = block[2]
			var cols: Array = []
			for r in range(PATCH.size()):
				for q in range(PATCH[r].size()):
					var c := origin + MapOrient.to_pixel(Hex.offset_to_axial(q, r), HEX)
					var t: int = GROUNDS[int(PATCH[r][q])]
					cols.append(_col(c, t, 977 * (i + 1) + 37 * (r * 8 + q), _links(q, r) if t == BattleMap.Terrain.ROAD else 0, "crags", _wall_links(q, r)))
			DomainGround.draw_columns(self, cols, HEX, frame, biome)
			# A small range of each look on its plain ground, joined where its hexes meet.
			var ground := _range_ground()
			for j in range(BattleMap.WALL_LOOKS.size()):
				var look: String = BattleMap.WALL_LOOKS[j]
				var base: Vector2 = block[3][j]
				var range_cols: Array = []
				var pit := DomainGround.lift_of_step(-2, HEX)   # a chasm's floor, deep
				for hx in ground.keys():
					if RANGE.has(hx):
						continue
					var col := _col(base + MapOrient.to_pixel(hx, HEX), BattleMap.Terrain.PLAIN, 31 * (hx.x + 7) + 113 * (hx.y + 5) + j, 0, "", 0)
					if look == "chasms":
						# Its banks go down into the chasm on the sides that face it.
						var drops := PackedInt32Array()
						for e in DomainGround._hex_edges(1.0):
							drops.append(pit if RANGE.has(hx + Hex.DIRECTIONS[int(e["dir"])]) else 0)
						col["drops"] = drops
					range_cols.append(col)
				for hx in RANGE:
					var links := 0
					for k in range(Hex.DIRECTIONS.size()):
						if RANGE.has(hx + Hex.DIRECTIONS[k]):
							links |= 1 << k
					var wall := _col(base + MapOrient.to_pixel(hx, HEX), BattleMap.Terrain.MOUNTAIN, 5003 * (i + 1) + 71 * (hx.x + 3) + 7 * (hx.y + 3) + j, 0, look, links)
					if look == "chasms":
						wall.erase("wall")
						wall["pit"] = true
						wall["lift"] = pit
						var floor_drops := PackedInt32Array()
						for e in DomainGround._hex_edges(1.0):
							floor_drops.append(pit)
						wall["drops"] = floor_drops
					range_cols.append(wall)
				DomainGround.draw_columns(self, range_cols, HEX, frame, biome)
				var lb := _bounds(ground.keys())
				draw_string(font, base + lb.position + Vector2(4.0, lb.size.y + 14.0), look, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.MUTED)

	## One hex of the sheet for DomainGround.draw_columns, on level ground: a wall of `look` joined
	## to `wall_links`, a road to `links`.
	func _col(c: Vector2, t: int, seed_value: int, links: int, look: String, wall_links: int) -> Dictionary:
		var col := {"c": c, "lift": 0, "drops": PackedInt32Array([0, 0, 0, 0, 0, 0]), "t": t, "seed": seed_value, "links": links, "cell": true, "tint": Color.WHITE}
		if t == BattleMap.Terrain.MOUNTAIN:
			col["wall"] = {"look": look, "links": wall_links}
		return col

	## The patch's roads beside one of its hexes (DomainGround.road_links), its rows laid
	## odd-r as the map's are.
	func _links(q: int, r: int) -> int:
		return _beside(q, r, BattleMap.Terrain.ROAD)

	## The patch's walls beside one of its hexes (DomainGround.wall_links).
	func _wall_links(q: int, r: int) -> int:
		return _beside(q, r, BattleMap.Terrain.MOUNTAIN)

	func _beside(q: int, r: int, ground: int) -> int:
		var h := Hex.offset_to_axial(q, r)
		var links := 0
		for k in range(Hex.DIRECTIONS.size()):
			var at := Hex.axial_to_offset(h + Hex.DIRECTIONS[k])
			if at.y >= 0 and at.y < PATCH.size() and at.x >= 0 and at.x < PATCH[at.y].size() and GROUNDS[int(PATCH[at.y][at.x])] == ground:
				links |= 1 << k
		return links
