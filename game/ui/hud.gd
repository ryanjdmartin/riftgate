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


## The 3D's anti-aliasing, the player's AA MODE in SETTINGS (Settings.AA_MODES; Ryan, 30
## October: "Can we add an AA mode setting, not just for debug?"): none, the map's FXAA, or MSAA
## at 2x or 4x, MSAA 4x by default. RIFTGATE_AA=<mode> forces one for a run, to compare.
static func aa_mode() -> String:
	var env := OS.get_environment("RIFTGATE_AA")
	if Settings.AA_MODES.has(env):
		return env
	var mode := str(Settings.display.get("aa_mode", Settings.DISPLAY_DEFAULTS["aa_mode"]))
	return mode if Settings.AA_MODES.has(mode) else str(Settings.DISPLAY_DEFAULTS["aa_mode"])


## The 3D viewports' MSAA, from the AA mode. A phone had none on Godot 4.7: its Compatibility
## renderer leaked native memory every frame a 3D viewport drew with MSAA on Android
## (godotengine/godot#97967). Measured on the Pixel 9 (29 September, MSAA 2x with the fine
## map), the native heap grew about 170 MB every twenty seconds until the GL driver aborted out
## of memory at 1.8 GB, three and a half minutes in: a phone's GPU resolves MSAA on the chip,
## so the renderer made no MSAA buffer, took the missing buffer for "not set up" and set the
## target up again, a framebuffer every frame. Godot 4.8 fixes it (godotengine/godot#124643),
## and the project runs it from 4.8-beta2 for that (Ryan, 30 October: "Let's update Godot so
## we can get the msaa fix"). Returns a SubViewport.MSAA value, typed int (a class-scoped
## enum type fails in a headless runner).
static func msaa_3d() -> int:
	match aa_mode():
		"msaa4":
			return SubViewport.MSAA_4X
		"msaa2":
			return SubViewport.MSAA_2X
	return SubViewport.MSAA_DISABLED


## Whether the map's compositor runs FXAA of its own (bleed.gdshader), the phone's renderer
## refusing Godot's: the FXAA mode, MSAA off (Ryan, 30 October: "a lot of aliasing on models
## and hex grid lines on the phone", before MSAA ran there).
static func fxaa() -> bool:
	return aa_mode() == "fxaa"


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


## The closest two ticks may stand, in design pixels (six device pixels on the 1080 phone): the
## ones closer than this crowd, and the bar ticks its fives alone, then its tens.
const TICK_PITCH := 4.0


## Which whole points of a bar `span` wide holding `top` are ticked: every one (its fives the
## big ticks), every fifth when the ones would crowd, every tenth when the fives would; 0 when
## even those would, or the bar holds one point.
static func tick_step(span: float, top: int) -> int:
	if top <= 1 or span <= 0.0:
		return 0
	var pitch := span / float(top)
	for step in [1, 5, 10]:
		if pitch * step >= TICK_PITCH:
			return step
	return 0


## A gauge's scale (Ryan, 2 November: "with the number rescaling, HP/Shield/heat bars can have
## tick marks now. Tick on the ones, a bigger or more prominent tick on the 5s, reduce to ticking
## on 5s only if the 1s get crowded on a particular bar"): a tick at each whole point across
## `inner` (the fill's own span) for a bar holding `now` of `top`, every fifth one long and
## heavy, the rest short; the fives alone, all long, where the ones would crowd (tick_step).
## Inside the fill a tick is a cut in the ground's dark, past it a line in the bar's colour, so
## the room left counts as well as what is held, by structure on any bar colour. `lean` leans
## each tick as the fill's end leans (the slanted gauges'), its top `lean` right of its foot.
static func ticks(ci: CanvasItem, inner: Rect2, now: int, top: int, color: Color, lean: float = 0.0) -> void:
	var step := tick_step(inner.size.x, top)
	if step == 0:
		return
	var v := step
	while v < top:
		var big := v % 5 == 0
		var x := inner.position.x + inner.size.x * float(v) / float(top)   # the tick's top, where the fill ends at v
		var held := v < now
		var ink := Color(Palette.BG, 0.9 if big else 0.75) if held else Color(color, 0.85 if big else 0.45)
		var h := inner.size.y if big else ceilf(inner.size.y * 0.5)
		var foot := Vector2(x - lean, inner.end.y)
		var head := Vector2(x - lean + lean * h / maxf(1.0, inner.size.y), inner.end.y - h)
		if big:
			# A five stands past the fill's edges, a little proud of the bar, so it reads as the
			# scale's long tick and not a seam.
			var out := 1.5
			var dir := (head - foot) / maxf(0.01, h)
			foot -= dir * out
			head += dir * out
		ci.draw_line(foot, head, ink, 2.0 if big else 1.0)
		v += step


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
