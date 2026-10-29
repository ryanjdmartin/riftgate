class_name HudBackdrop
extends Control

## The screen's ground: near-black with faint scanlines, a few dim section rules, a scan
## band that sweeps down the screen now and then so the HUD never sits perfectly still,
## and, when a screen asks for it, bands of ground in the terrain the fight is on. Each
## ground band is its own clipped child, so nothing it draws spills past its edges.

const SCAN_SPEED := 140.0     # pixels per second
const FLOOR_SHADER := preload("res://game/ui/floor_plane.gdshader")
const SCAN_PAUSE := 6.0       # seconds between sweeps (Ryan, 22 September: too often was busy)
const BAND_HEX := 72.0        # the ground bands' hex size: bigger than the map's, and bare of marks

var rules: Array[float] = []   # y positions of faint horizontal rules
var grounds: Array = []        # [[Rect2, terrain, seed, style, opts], ...]: opts a Dictionary for the styles that read one
var glass: Array = []          # Rect2 panes of dark glass over the ground, under a console that floats on it
var scan: bool = true          # the sweeping band
var _t := 0.0
var _bands: Array = []
var _overlay: Control = null


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	for g in grounds:
		var band := GroundBand.new()
		band.rect = g[0]
		band.terrain = int(g[1])
		band.seed_value = int(g[2])
		band.style = g[3] if g.size() > 3 else "ground"
		band.opts = g[4] if g.size() > 4 else {}
		band.owner_bg = self
		band.position = (g[0] as Rect2).position
		band.size = (g[0] as Rect2).size
		add_child(band)
		_bands.append(band)
	_overlay = Overlay.new()
	_overlay.owner_bg = self
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)
	set_process(true)


func _process(delta: float) -> void:
	_t += delta
	for b in _bands:
		b.queue_redraw()
	if _overlay != null:
		_overlay.queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Palette.BG)


## Where the band is right now, in this control's pixels. Through the pause it keeps
## travelling below the screen, so the traces' tails fade out on their own instead of
## snapping to black when the sweep switched off (Ryan, 22 September).
func scan_y() -> float:
	if not scan:
		return -1.0e6
	var sweep := (size.y + 120.0) / SCAN_SPEED
	var t := fmod(_t, sweep + SCAN_PAUSE)
	return t * SCAN_SPEED - 60.0


## Whether the band is on screen: the drawn lines want to know, the traces do not.
func scan_visible() -> bool:
	if not scan:
		return false
	var sweep := (size.y + 120.0) / SCAN_SPEED
	return fmod(_t, sweep + SCAN_PAUSE) <= sweep


func time() -> float:
	return _t


## Design pixels one art pixel of a painted ground spans: the foes' sprites' own (a whole number
## of device pixels, two on the 1080 phone), so the backdrop and the foes share one grid.
static func art_pixel(ci: CanvasItem) -> float:
	if not ci.is_inside_tree():
		return 1.0
	var xf := ci.get_viewport().get_final_transform() * ci.get_global_transform_with_canvas()
	var d := maxf(0.01, xf.get_scale().y)
	return maxf(1.0, floorf(d * 1.6)) / d


## One band of ground, clipped to its rect. Beside the overworld's styles (other, seam,
## ground), the skirmish's options of 29 October: "vista" the other world as a battle screen's
## backdrop (BattleBackdrop, painted once), "recon" the reconstruction's tile on a floor in
## perspective and "holo" the holo-table's (floor_plane.gdshader). Their opts: horizon (the
## floor's vanishing line in the band's pixels), biome (a domain's bleed), dim, frame (the
## vista as a feed's window), seam (where a floor starts over what is under it).
class GroundBand extends Control:
	var rect := Rect2()
	var terrain: int = 0
	var seed_value: int = 0
	var style := "ground"
	var opts: Dictionary = {}
	var owner_bg: HudBackdrop
	var _tex: Texture2D = null
	var _art := 1.0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST   # the tile is pixel art; the screen's text is linear
		clip_contents = true

	func _ready() -> void:
		_art = HudBackdrop.art_pixel(self)
		match style:
			"vista":
				var px := Vector2i(ceili(size.x / _art), ceili(size.y / _art))
				var hz := int(roundf(float(opts.get("horizon", size.y * 0.25)) / _art))
				var img := BattleBackdrop.paint(str(opts.get("biome", "")), terrain, seed_value, px, hz)
				if bool(opts.get("frame", false)):
					_feed_edge(img)
				_tex = ImageTexture.create_from_image(img)
			"recon", "holo":
				var m := ShaderMaterial.new()
				m.shader = HudBackdrop.FLOOR_SHADER
				m.set_shader_parameter("mode", 1 if style == "holo" else 0)
				m.set_shader_parameter("band_size", size)
				m.set_shader_parameter("horizon", float(opts.get("horizon", -size.y)))
				m.set_shader_parameter("tile_px", float(opts.get("tile_px", 110.0)))
				m.set_shader_parameter("foreshorten", float(opts.get("foreshorten", 0.5)))
				m.set_shader_parameter("art_px", _art)
				m.set_shader_parameter("dim", float(opts.get("dim", 0.62)))
				m.set_shader_parameter("hud", Palette.HUD)
				m.set_shader_parameter("fog", Palette.BG)
				m.set_shader_parameter("fog_top", float(opts.get("fog_top", 0.0)))
				m.set_shader_parameter("grid_alpha", float(opts.get("grid", 0.16)))
				m.set_shader_parameter("grid_fade", float(opts.get("grid_fade", 140.0)))
				m.set_shader_parameter("seam_y", float(opts.get("seam", -1.0e6)))
				m.set_shader_parameter("seam_band", float(opts.get("seam_band", 30.0)))
				if style == "recon":
					var name: String = TerrainArt.TILE.get(terrain, "dirt")
					var path := "res://art/terrain/%s.png" % name
					if ResourceLoader.exists(path):
						m.set_shader_parameter("tile", load(path))
				else:
					var n := FastNoiseLite.new()
					n.seed = seed_value
					n.frequency = 0.012
					n.fractal_octaves = 3
					m.set_shader_parameter("relief", ImageTexture.create_from_image(n.get_seamless_image(256, 256)))
					m.set_shader_parameter("contours", float(opts.get("contours", 6.0)))
				material = m

	## The window's edge: the feed's picture darkening into the panel through a dithered rim.
	func _feed_edge(img: Image) -> void:
		var w := img.get_width()
		var h := img.get_height()
		var rim := maxi(6, int(14.0 / _art))
		for y in range(h):
			for x in range(w):
				var e := mini(mini(x, w - 1 - x), mini(y, h - 1 - y))
				if e >= rim:
					continue
				var f := 1.0 - float(e) / float(rim)
				if BattleBackdrop.bayer(x, y) < f * f * 1.1:
					img.set_pixel(x, y, Palette.BG)

	func _draw() -> void:
		match style:
			"vista":
				if _tex != null:
					var k := float(opts.get("dim", 1.0))
					draw_texture_rect(_tex, Rect2(Vector2.ZERO, Vector2(_tex.get_size()) * _art), false, Color(k, k, k, 1.0))
				if bool(opts.get("frame", false)):
					var r := Rect2(Vector2(6.0, 6.0), size - Vector2(12.0, 12.0))
					Hud.brackets(self, r, 22.0, Color(Palette.HUD, 0.9), 2.0)
					draw_rect(r, Color(Palette.HUD, 0.18), false, 1.0)
			"recon", "holo":
				draw_rect(Rect2(Vector2.ZERO, size), Color.WHITE)
			_:
				var t := owner_bg.time() if owner_bg != null else 0.0
				TerrainArt.draw_ground(self, Rect2(Vector2.ZERO, size), terrain, seed_value, BAND_HEX, style, int(t * 1.6) % 2, t, false)


## Scanlines, rules and the scan band, over everything.
class Overlay extends Control:
	var owner_bg: HudBackdrop

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		for r in owner_bg.glass:
			draw_rect(r, Color(Palette.BG, 0.74))
			draw_line(r.position, Vector2(r.end.x, r.position.y), Color(Palette.HUD, 0.28), 1.0)
			draw_line(Vector2(r.position.x, r.end.y), r.end, Color(Palette.HUD, 0.28), 1.0)
		Hud.scanlines(self, Rect2(Vector2.ZERO, size))
		for ry in owner_bg.rules:
			draw_line(Vector2(12.0, ry), Vector2(size.x - 12.0, ry), Color(Palette.HUD, 0.22), 1.0)
		var y := owner_bg.scan_y()
		if owner_bg.scan_visible():
			for i in range(-2, 3):
				draw_rect(Rect2(0.0, y + i * 3.0, size.x, 1.0), Color(1, 1, 1, 0.07 - 0.015 * absi(i)))
