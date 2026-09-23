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
## taller phone (the window keeps the width and expands the height), the real one.
static func screen_height(screen: Control) -> float:
	if screen.is_inside_tree():
		return maxf(1280.0, screen.get_viewport_rect().size.y)
	return 1280.0


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
static func scanlines(ci: CanvasItem, rect: Rect2, alpha: float = 0.03) -> void:
	var y := rect.position.y
	var col := Color(1, 1, 1, alpha)
	while y < rect.end.y:
		ci.draw_rect(Rect2(rect.position.x, y, rect.size.x, 1.0), col)
		y += 3.0


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


## A short diagonal tick, the mock's "leader" mark beside a unit.
static func tick(ci: CanvasItem, at: Vector2, color: Color) -> void:
	ci.draw_line(at, at + Vector2(7.0, -11.0), color, 1.0)
