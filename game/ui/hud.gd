class_name Hud
extends RefCounted

## The tactical-overlay look: fonts, chamfered shapes, bracket corners, scanlines. Everything
## the HUD widgets draw goes through here so the style lives in one place.

const MONO_PATH := "res://art/fonts/ShareTechMono-Regular.ttf"
const DISPLAY_PATH := "res://art/fonts/Rajdhani-SemiBold.ttf"
const DISPLAY_BOLD_PATH := "res://art/fonts/Rajdhani-Bold.ttf"
const QUOTE_PATH := "res://art/fonts/BarlowCondensed-MediumItalic.ttf"

static var _mono: Font = null
static var _display: Font = null
static var _display_bold: Font = null
static var _quote: Font = null


## Monospace face for readouts, numbers and the log.
static func mono() -> Font:
	if _mono == null:
		_mono = _load(MONO_PATH)
	return _mono


## Narrow display face for names, titles and buttons.
static func display() -> Font:
	if _display == null:
		_display = _load(DISPLAY_PATH)
	return _display


static func display_bold() -> Font:
	if _display_bold == null:
		_display_bold = _load(DISPLAY_BOLD_PATH)
	return _display_bold


## The face for quotes: a true italic. Rajdhani ships none and a sheared Rajdhani renders
## badly, so quotes use Barlow Condensed Medium Italic, a condensed companion in the same
## register (OFL, bundled).
static func quote() -> Font:
	if _quote == null:
		_quote = _load(QUOTE_PATH)
	return _quote


static func _load(path: String) -> Font:
	if ResourceLoader.exists(path):
		var f := load(path)
		if f is Font:
			return f
	return ThemeDB.fallback_font


## A label in one of the HUD faces. Labels clip glyphs at their left edge, and the mono face
## has glyphs that start left of their origin, so every label gets a few pixels of left
## padding rather than losing the first stem of an H.
## The height a screen should lay itself out to: the design's 1280 or, in the tree on a
## taller phone (the window keeps the width and expands the height), the real one less
## the safe insets at its top and bottom.
static func screen_height(screen: Control) -> float:
	if screen.is_inside_tree():
		var ins := safe_insets(screen)
		return maxf(1280.0, screen.get_viewport_rect().size.y - ins.x - ins.y)
	return 1280.0


## The band at the top and at the bottom of the glass a screen must keep clear, in design
## pixels: (top, bottom). Ryan, 25 September, first native Android run: the build is edge
## to edge and immersive, so the layout ran from the very top of the glass to the very
## bottom, MENU sat in the rounded corner under the cutout and was hard to press, and the
## bottom buttons were cut off by the corners and the gesture zone (the framebuffer showed
## them whole; the panel did not). The display reports its cutouts; the corners and the
## gesture zone it does not, so on a phone each band is at least SAFE_FLOOR. Desktop
## windows keep no band. RIFTGATE_SAFE=top,bottom forces one anywhere, to see the phone's
## layout on the Mac.
const SAFE_FLOOR := Vector2(40.0, 32.0)

static func safe_insets(screen: Control) -> Vector2:
	if not screen.is_inside_tree():
		return Vector2.ZERO
	var view_h := screen.get_viewport_rect().size.y
	var ins := Vector2.ZERO
	var env := OS.get_environment("RIFTGATE_SAFE")
	if not env.is_empty():
		var parts := env.split(",")
		ins = Vector2(float(parts[0]), float(parts[1]) if parts.size() > 1 else float(parts[0]))
	elif OS.has_feature("mobile"):
		var win := screen.get_window()
		var win_pos := Vector2(DisplayServer.window_get_position(win.get_window_id()))
		var win_h := float(win.size.y)
		var safe := DisplayServer.get_display_safe_area()
		var top := maxf(0.0, float(safe.position.y) - win_pos.y)
		var bottom := maxf(0.0, win_pos.y + win_h - float(safe.end.y))
		var scale := view_h / maxf(1.0, win_h)   # design pixels per device pixel
		ins = Vector2(maxf(top * scale, SAFE_FLOOR.x), maxf(bottom * scale, SAFE_FLOOR.y))
	# The layout is never shorter than the design: on glass too short to keep the whole
	# band clear as well, the band gives way, both ends in proportion.
	var spare := maxf(0.0, view_h - 1280.0)
	var total := ins.x + ins.y
	if total > spare and total > 0.0:
		ins *= spare / total
	return ins


## Text at the glass's density. The window stretches the 720-wide design over the phone
## (1.5 device pixels a design pixel on a 1080 phone), and its fonts were rasterised at the
## design's size and stretched nearest with everything else: jagged, uneven strokes, the
## small mono labels hard to read (Ryan, 26 September, the codex on the phone). Rendered
## into a SubViewport with size_2d_override the same screen oversamples and comes out
## clean, so the window's font oversampling is set here to its stretch scale outright,
## and follows the window when it changes. Called once per window; later calls return.
static func oversample(win: Window) -> void:
	if win == null or win.has_meta("riftgate_oversampled"):
		return
	win.set_meta("riftgate_oversampled", true)
	var apply := func() -> void:
		# The stretch the window really applies, read from its own transform: the same
		# number that put the scanlines on device pixels on the phone. Computed from the
		# window's size and content scale, the text stayed unsampled on the device (Ryan,
		# 29 September) while the Mac's window path was crisp; the log says which it took.
		var scale := win.get_final_transform().get_scale().y
		var fallback := float(win.size.x) / maxf(1.0, float(win.content_scale_size.x))
		if scale <= 0.0:
			scale = fallback
		win.oversampling_override = maxf(1.0, scale)
		print("riftgate: font oversampling %.2f (window %s, stretch %.2f, size ratio %.2f)" % [win.oversampling_override, str(win.size), scale, fallback])
	apply.call()
	win.size_changed.connect(apply)


## The 3D viewports' anti-aliasing: 4x on the desktop, none on a phone. Godot's
## Compatibility renderer leaks native memory every frame a 3D viewport draws with MSAA
## on Android (godotengine/godot#97967, open since October 2024; seen here on a Pixel 9,
## Mali-G715: the GL driver aborts out of memory after some minutes, Ryan, 26 September).
## The phone renders at the design's 720 and upscales nearest anyway, so MSAA bought
## little there. RIFTGATE_MSAA=on or off forces it, to compare. Returns a
## SubViewport.MSAA value, typed int (a class-scoped enum type fails in a headless runner).
static func msaa_3d() -> int:
	var env := OS.get_environment("RIFTGATE_MSAA")
	if env == "off":
		return SubViewport.MSAA_DISABLED
	if env != "on" and OS.has_feature("mobile"):
		# Measured on the Pixel 9 (29 September, MSAA 2x with the fine map): the native heap
		# grew about 170 MB every twenty seconds until the GL driver aborted out of memory
		# at 1.8 GB, three and a half minutes in. Godot's bug (godotengine/godot#97967): a
		# phone's GPU resolves MSAA on the chip, so the renderer makes no MSAA buffer, takes
		# the missing buffer for "not set up" and sets the target up again, a framebuffer
		# every frame (where the 3D draws through a buffer of its own, by the fix's author:
		# scaling, or post effects like the map's glow). Fixed for Godot 4.8
		# (godotengine/godot#124643, 22 October), not in 4.7.2: MSAA comes back on a phone
		# once the project runs a Godot with the fix and the Pixel's memory holds flat.
		return SubViewport.MSAA_DISABLED
	return SubViewport.MSAA_4X


## The smoothing the 3D gets where MSAA cannot run (Ryan, 30 October: "a lot of aliasing on
## models and hex grid lines on the phone"): the machines' textures read their mipmaps, so a
## machine drawn small stops sparkling, and where the viewports have no MSAA the map's
## compositor runs FXAA of its own (bleed.gdshader), the phone's renderer refusing Godot's.
## RIFTGATE_AA=off, or AA off in a debug build's settings, draws as before, to compare;
## RIFTGATE_AA=fxaa runs the FXAA beside MSAA too (the desk judging the phone's look).
static func smoothing() -> bool:
	if OS.get_environment("RIFTGATE_AA") == "off":
		return false
	return bool(Settings.display.get("aa", true)) or not OS.is_debug_build()


static func fxaa() -> bool:
	return smoothing() and (msaa_3d() == SubViewport.MSAA_DISABLED or OS.get_environment("RIFTGATE_AA") == "fxaa")


## Device pixels per design pixel a 3D render uses: the window's stretch, so the map and the
## machines render at the glass's density and the stretch lands one to one (the fine map,
## always: Ryan, 30 October, "set fine map on as the default and remove the option"). From
## the node's own viewport when it is in the tree, else the window's.
static func density(node: Node) -> float:
	var vp: Viewport = node.get_viewport() if node != null and node.is_inside_tree() else null
	if vp == null:
		var loop := Engine.get_main_loop()
		if loop is SceneTree:
			vp = (loop as SceneTree).root
	if vp == null:
		return 1.0
	return maxf(1.0, vp.get_final_transform().get_scale().y)


## Fit a screen's root to the glass less the safe bands: full rect, then the top and
## bottom offsets pulled in by whatever of the band its parent does not already keep
## clear (a skirmish opened inside the battle screen sits in a root that is inset already).
static func inset_screen(screen: Control) -> void:
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if not screen.is_inside_tree():
		return
	var ins := safe_insets(screen)
	if ins == Vector2.ZERO:
		return
	var parent := screen.get_parent_control()
	var view_h := screen.get_viewport_rect().size.y
	var parent_top := parent.get_global_rect().position.y if parent != null else 0.0
	var parent_bottom := parent.get_global_rect().end.y if parent != null else view_h
	screen.offset_top = maxf(0.0, ins.x - parent_top)
	screen.offset_bottom = -maxf(0.0, ins.y - (view_h - parent_bottom))


static func label(text: String, size_px: int, color: Color, font: Font = null) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", font if font != null else display())
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	var pad := StyleBoxEmpty.new()
	pad.content_margin_left = 3.0
	pad.content_margin_right = 3.0
	l.add_theme_stylebox_override("normal", pad)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


# ---------------------------------------------------------------- shapes

## A parallelogram: the top-left and bottom-right corners cut by `k` along x.
static func slant(rect: Rect2, k: float) -> PackedVector2Array:
	var p := rect.position
	var e := rect.end
	return PackedVector2Array([
		Vector2(p.x + k, p.y), Vector2(e.x, p.y), Vector2(e.x - k, e.y), Vector2(p.x, e.y),
	])


## A box with the top-left and bottom-right corners chamfered by `c`.
static func cut(rect: Rect2, c: float) -> PackedVector2Array:
	var p := rect.position
	var e := rect.end
	return PackedVector2Array([
		Vector2(p.x + c, p.y), Vector2(e.x, p.y), Vector2(e.x, e.y - c),
		Vector2(e.x - c, e.y), Vector2(p.x, e.y), Vector2(p.x, p.y + c),
	])


static func fill_poly(ci: CanvasItem, pts: PackedVector2Array, color: Color) -> void:
	ci.draw_colored_polygon(pts, color)


static func stroke_poly(ci: CanvasItem, pts: PackedVector2Array, color: Color, width: float = 1.0) -> void:
	var closed := PackedVector2Array(pts)
	closed.append(pts[0])
	ci.draw_polyline(closed, color, width)


## Fill and stroke a chamfered box.
static func box(ci: CanvasItem, rect: Rect2, c: float, fill: Color, border: Color, width: float = 1.0) -> void:
	var pts := cut(rect, c)
	if fill.a > 0.0:
		fill_poly(ci, pts, fill)
	if border.a > 0.0 and width > 0.0:
		stroke_poly(ci, pts, border, width)


## Four bracket corners just outside a rect, the targeting-reticle look.
static func brackets(ci: CanvasItem, rect: Rect2, len_px: float, color: Color, width: float = 1.0) -> void:
	var p := rect.position
	var e := rect.end
	ci.draw_polyline(PackedVector2Array([Vector2(p.x, p.y + len_px), p, Vector2(p.x + len_px, p.y)]), color, width)
	ci.draw_polyline(PackedVector2Array([Vector2(e.x - len_px, p.y), Vector2(e.x, p.y), Vector2(e.x, p.y + len_px)]), color, width)
	ci.draw_polyline(PackedVector2Array([Vector2(e.x, e.y - len_px), e, Vector2(e.x - len_px, e.y)]), color, width)
	ci.draw_polyline(PackedVector2Array([Vector2(p.x + len_px, e.y), Vector2(p.x, e.y), Vector2(p.x, e.y - len_px)]), color, width)


## A slanted gauge: outline in `color`, filled to `frac`.
static func gauge(ci: CanvasItem, rect: Rect2, frac: float, color: Color, k: float = 4.0) -> void:
	stroke_poly(ci, slant(rect, k), Color(color, 0.7), 1.0)
	var inner := rect.grow(-2.0)
	if frac > 0.0:
		var w := maxf(2.0, inner.size.x * clampf(frac, 0.0, 1.0))
		fill_poly(ci, slant(Rect2(inner.position, Vector2(w, inner.size.y)), k * 0.6), color)


## Faint scanlines over a rect: the screen is a display, not paper.
## Drawn on the glass's pixels, not the design's: one device pixel every three. Drawn in
## design pixels they land unevenly on a phone (720 stretched to 1080: every line one and
## a half device pixels, every third line two) and the ground read as janky stripes (Ryan,
## 28 September). The scale is the item's, canvas and window stretch included.
static func scanlines(ci: CanvasItem, rect: Rect2, alpha: float = 0.03) -> void:
	var col := Color(1, 1, 1, alpha)
	var xf := ci.get_viewport().get_final_transform() * ci.get_global_transform_with_canvas()
	var s := maxf(0.01, xf.get_scale().y)   # device pixels per local pixel
	var top_dev := (xf * rect.position).y   # the rect's top on the glass
	var dy := ceilf(top_dev)                # the first device row inside it
	var h := 1.0 / s
	while (dy - top_dev) / s < rect.size.y:
		ci.draw_rect(Rect2(rect.position.x, rect.position.y + (dy - top_dev) / s, rect.size.x, h), col)
		dy += 3.0


## A readout's digits replaced by others, stable for a few frames at a time (`frame` is a
## coarse frame counter), so a number is seen to settle rather than flicker at random. The
## display's "still computing" look (Ryan, 23 September).
static func scramble(txt: String, frame: int, salt: int = 0) -> String:
	var out := ""
	for k in range(txt.length()):
		var c := txt[k]
		if c.is_valid_int():
			out += str(absi(hash(frame * 31 + k * 7 + salt * 131)) % 10)
		else:
			out += c
	return out


## A deterministic 0..1 from a float, for effects that must not change between frames
## unless their input does.
static func noise(x: float) -> float:
	return fmod(absf(sin(x * 12.9898) * 43758.5453), 1.0)


## Gibberish telemetry: `n` hex bytes for a coarse frame counter, as the display "reading" a
## unit shows while it works.
static func hex_bytes(n: int, frame: int, salt: int = 0) -> String:
	var parts: PackedStringArray = []
	for k in range(n):
		parts.append("%02X" % (absi(hash(frame * 17 + k * 13 + salt * 101)) % 256))
	return " ".join(parts)


## A die entry's place on its die as a Roman numeral (Ryan, 15 October), so the slot never
## reads as a stat: 1 is "I", 4 "IV", 9 "IX". Nothing for 0 or less.
static func roman(n: int) -> String:
	var out := ""
	for pair in [[1000, "M"], [900, "CM"], [500, "D"], [400, "CD"], [100, "C"], [90, "XC"],
			[50, "L"], [40, "XL"], [10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]]:
		while n >= int(pair[0]):
			out += str(pair[1])
			n -= int(pair[0])
	return out


## A short diagonal tick, the mock's "leader" mark beside a unit.
static func tick(ci: CanvasItem, at: Vector2, color: Color) -> void:
	ci.draw_line(at, at + Vector2(7.0, -11.0), color, 1.0)
