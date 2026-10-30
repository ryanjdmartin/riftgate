extends SceneTree

## The domains' tilesets side by side, for judging (DomainGround): a row a domain, in content's
## order, its four decorative grounds and then water and the walls (alike in every row), each a
## hex at the map's size, and a patch of field mixing them all, posterized as the map's
## compositor posterizes the painted world (bleed.gdshader), so it shows what the map shows.
## Needs a renderer:
##   xvfb-run -a godot --rendering-method gl_compatibility --path . -s tools/tileset_shot.gd -- out.png [frame]

const HEX := 48.0
const LEVELS := 5.0   # the compositor's posterize, steps a channel (bleed.gdshader's `levels`)
const GROUNDS := [BattleMap.Terrain.PLAIN, BattleMap.Terrain.ROAD, BattleMap.Terrain.ROUGH, BattleMap.Terrain.RUINS, BattleMap.Terrain.WATER, BattleMap.Terrain.MOUNTAIN]
## The patch: a few rows of field, which ground each hex is, by its index in GROUNDS.
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
	var db := ContentDB.load_default()
	var rows: Array = []
	for id in db.factions.keys():
		var f: Dictionary = db.factions[id]
		rows.append([str(f.get("name", id)).to_upper(), str(f.get("bleed", ""))])
	var sheet := Sheet.new()
	sheet.rows = rows
	sheet.frame = frame
	var w := sqrt(3.0) * HEX
	sheet.size = Vector2(40.0 + 6.0 * (w + 10.0) + 30.0 + 6.5 * w + 20.0, 50.0 + rows.size() * (HEX * 6.4 + 30.0))
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

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Palette.BG)
		var font := Hud.mono()
		var w := sqrt(3.0) * HEX
		var y := 40.0
		for i in range(rows.size()):
			var name: String = rows[i][0]
			var biome: String = rows[i][1]
			draw_string(font, Vector2(20.0, y), "%s  (%s)" % [name, biome if not biome.is_empty() else "no bleed"], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Palette.INK)
			var top := y + 16.0 + HEX
			for k in range(GROUNDS.size()):
				var t: int = GROUNDS[k]
				var c := Vector2(40.0 + w * 0.5 + k * (w + 10.0), top)
				DomainGround.draw_hex(self, c, HEX, t, 7919 * (i + 1) + 131 * k, frame, biome)
				var label := "walls" if t == BattleMap.Terrain.MOUNTAIN else str(BattleMap.TERRAIN_NAMES[t])
				draw_string(font, Vector2(c.x - w * 0.5, top + HEX + 16.0), label, HORIZONTAL_ALIGNMENT_CENTER, w, 14, Palette.MUTED)
			# The patch: the grounds as they lie together on a field, at the map's size.
			var ox := 40.0 + 6.0 * (w + 10.0) + 30.0 + w * 0.5
			for r in range(PATCH.size()):
				for q in range(PATCH[r].size()):
					var c := Vector2(ox + q * w + (w * 0.5 if r % 2 == 1 else 0.0), y + 16.0 + HEX + r * HEX * 1.5)
					var t: int = GROUNDS[int(PATCH[r][q])]
					DomainGround.draw_hex(self, c, HEX, t, 977 * (i + 1) + 37 * (r * 8 + q), frame, biome)
			y += HEX * 6.4 + 30.0
