class_name HudBackdrop
extends Control

## The screen's ground: near-black with faint scanlines, a few dim section rules, a scan
## band that sweeps down the screen now and then so the HUD never sits perfectly still,
## and, when a screen asks for it, bands of ground in the terrain the fight is on (the
## skirmish's field). Each ground band is its own clipped child, so nothing it draws spills
## past its edges; the bands are still pictures, drawn once.

const SCAN_SPEED := 140.0     # pixels per second
const FLOOR_SHADER := preload("res://game/ui/floor_plane.gdshader")
const SCAN_PAUSE := 6.0       # seconds between sweeps (Ryan, 22 September: too often was busy)

var rules: Array[float] = []   # y positions of faint horizontal rules
var grounds: Array = []        # [[Rect2, terrain, seed, style, opts], ...]: GroundBand's styles and opts
var glass: Array = []          # Rect2 panes of dark glass over the ground, under a console that floats on it
var marks: Array = []          # [PackedVector2Array, empty]: the squad's hexes on the floor, an empty spot's dashed
var scan: bool = true          # the sweeping band
var _t := 0.0
var _overlay: Control = null


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	for g in grounds:
		var band := GroundBand.new()
		band.rect = g[0]
		band.terrain = int(g[1])
		band.seed_value = int(g[2])
		band.style = g[3] if g.size() > 3 else "floor"
		band.opts = g[4] if g.size() > 4 else {}
		band.owner_bg = self
		band.position = (g[0] as Rect2).position
		band.size = (g[0] as Rect2).size
		add_child(band)
	_overlay = Overlay.new()
	_overlay.owner_bg = self
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)
	set_process(true)


func _process(delta: float) -> void:
	_t += delta
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


## One band of ground, clipped to its rect: the skirmish's field (29 October), in two layers
## sharing the floor's camera. "backdrop" is the other world as a battle screen's backdrop
## (BattleBackdrop, painted once), "floor" our side's ground on the floor in perspective
## (floor_plane.gdshader), laid over the backdrop below its seam. Their opts: horizon (the
## vanishing line, in the band's pixels), focal, height and shift (the camera and its lattice,
## SkirmishScreen._field_camera), biome (a domain's bleed), dim, seam (where the floor starts).
class GroundBand extends Control:
	var rect := Rect2()
	var terrain: int = 0
	var seed_value: int = 0
	var style := "floor"
	var opts: Dictionary = {}
	var owner_bg: HudBackdrop
	var _tex: Texture2D = null
	var _art := 1.0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST   # the ground is pixel art; the screen's text is linear
		clip_contents = true

	func _ready() -> void:
		_art = HudBackdrop.art_pixel(self)
		if style == "backdrop":
			var px := Vector2i(ceili(size.x / _art), ceili(size.y / _art))
			var hz := int(roundf(float(opts.get("horizon", size.y * 0.25)) / _art))
			# The far floor's bands a hex row deep, in step with the grid below the seam.
			var rows := {}
			if opts.has("focal"):
				var row_depth := sqrt(3.0) * 0.5
				rows = {"k": float(opts["focal"]) * float(opts["height"]) / (row_depth * _art), "phase": -float(opts.get("shift", 0.0)) / row_depth}
			_tex = ImageTexture.create_from_image(BattleBackdrop.paint(str(opts.get("biome", "")), terrain, seed_value, px, hz, rows))
		else:
			var m := ShaderMaterial.new()
			m.shader = HudBackdrop.FLOOR_SHADER
			m.set_shader_parameter("band_size", size)
			m.set_shader_parameter("horizon", float(opts.get("horizon", 0.0)))
			m.set_shader_parameter("focal", float(opts.get("focal", 1000.0)))
			m.set_shader_parameter("cam_h", float(opts.get("height", 3.4)))
			m.set_shader_parameter("shift", float(opts.get("shift", 0.0)))
			m.set_shader_parameter("tiles", float(opts.get("tiles", 1.4)))
			m.set_shader_parameter("art_px", _art)
			m.set_shader_parameter("dim", float(opts.get("dim", 0.62)))
			m.set_shader_parameter("hud", Palette.HUD)
			m.set_shader_parameter("grid_alpha", float(opts.get("grid", 0.14)))
			m.set_shader_parameter("grid_fade", float(opts.get("grid_fade", 140.0)))
			m.set_shader_parameter("seam_y", float(opts.get("seam", -1.0e6)))
			m.set_shader_parameter("seam_band", float(opts.get("seam_band", 30.0)))
			var path := "res://art/terrain/%s.png" % str(TerrainArt.TILE.get(terrain, "dirt"))
			if ResourceLoader.exists(path):
				m.set_shader_parameter("tile", load(path))
			material = m

	func _draw() -> void:
		if style == "backdrop":
			if _tex != null:
				var k := float(opts.get("dim", 1.0))
				draw_texture_rect(_tex, Rect2(Vector2.ZERO, Vector2(_tex.get_size()) * _art), false, Color(k, k, k, 1.0))
		else:
			draw_rect(Rect2(Vector2.ZERO, size), Color.WHITE)


## Scanlines, rules and the scan band, over everything.
class Overlay extends Control:
	var owner_bg: HudBackdrop

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		for m in owner_bg.marks:
			var pts: PackedVector2Array = m[0]
			if bool(m[1]):
				# An empty spot: its hex in dashes, a squad's place no machine fills.
				for k in range(pts.size()):
					var a := pts[k]
					var b := pts[(k + 1) % pts.size()]
					for t in range(4):
						var t0 := float(t) / 4.0
						draw_line(a.lerp(b, t0 + 0.04), a.lerp(b, t0 + 0.17), Color(Palette.HUD, 0.55), 2.0)
			else:
				var ring := pts.duplicate()
				ring.append(pts[0])
				draw_polyline(ring, Color(Palette.HUD, 0.32), 1.5)
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
