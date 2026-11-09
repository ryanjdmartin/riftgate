class_name MusicTicker
extends Control

## The readout of what is playing (Ryan, 25 September): a small beat meter and the track's title
## in mono, right-aligned in its box (the skirmish's header, between the phase readout and MENU),
## or with `centred` settled in its box's middle (the battle's bottom row, between its two
## buttons, since its top bar holds the gauges: Ryan, 9 November). A new title runs in from the
## right edge like a line on a ticker; a title too long for the box keeps rolling. The meter's three bars kick on the beat, the half bar and the bar,
## from `Sound.beat()`, so the readout moves with the music rather than sitting as a label.
## Nothing playing: the bars rest and the text is blank.

const FONT_PX := 12
const METER_W := 16.0     # the three bars and their gaps
const GAP := 8.0          # meter to text
const ROLL_PX_S := 28.0   # a long title's crawl
const RUN_IN_S := 0.55    # a new title's run in from the right
const WRAP := "   //   "  # between a rolling title's repeats

var centred := false      # settle the meter and the title in the box's middle, not at its right
var _title := ""
var _loop := ""
var _t := 0.0             # seconds since the title changed
var _roll := 0.0          # a rolling title's offset


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true


func _process(delta: float) -> void:
	var loop := Sound.track()
	if loop != _loop:
		_loop = loop
		_title = Sound.title(loop).to_upper()
		_t = 0.0
		_roll = 0.0
	_t += delta
	_roll += delta * ROLL_PX_S
	queue_redraw()


func _draw() -> void:
	var col := Color(Palette.HUD, 0.7)
	var font := Hud.mono()
	var mid := size.y * 0.5
	var box_x := METER_W + GAP        # the text's box, right of the meter, when the title crawls
	var box_w := size.x - box_x
	var tw := font.get_string_size(_title, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX).x if not _title.is_empty() else 0.0
	var fits := tw <= box_w
	# The meter sits just left of where the title settles, so the two read as one readout
	# against MENU; under a crawling title it holds the box's left edge. Centred, the pair sits in
	# the box's middle.
	var right := size.x - ((size.x - (tw + GAP + METER_W)) * 0.5 if centred else 0.0)   # where the title settles its right end
	var meter_x := right - tw - GAP - METER_W if fits else 0.0
	_draw_meter(meter_x, mid, col)
	if _title.is_empty():
		return
	var ty := mid + font.get_ascent(FONT_PX) * 0.5 - font.get_descent(FONT_PX) * 0.5
	if fits:
		# It runs in from the right edge and settles at its place.
		var run := clampf(_t / RUN_IN_S, 0.0, 1.0)
		var settle := 1.0 - pow(1.0 - run, 3.0)
		draw_string(font, Vector2(lerpf(size.x, right - tw, settle), ty), _title, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX, col)
		return
	# Too long: a crawl, the title repeated behind itself with a separator, clipped at the
	# meter by a strip of the bar's black.
	var unit := _title + WRAP
	var uw := font.get_string_size(unit, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX).x
	var x := box_x + box_w - fmod(_roll, uw)
	draw_string(font, Vector2(x - uw, ty), unit + unit + unit, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX, col)
	draw_rect(Rect2(0.0, 0.0, box_x, size.y), Palette.BG)
	_draw_meter(meter_x, mid, col)


## Three bars: bar k falls from its kick over 2^k beats, so they read as the beat, the half
## bar and the bar; between kicks each rests at a third. Nothing playing, all three rest.
func _draw_meter(x0: float, mid: float, col: Color) -> void:
	var beat := Sound.beat()
	for k in range(3):
		var h := 0.3
		if beat >= 0.0:
			var period := float(1 << k)
			var phase := fmod(beat, period) / period
			h = 0.3 + 0.7 * pow(1.0 - phase, 2.5)
		var bar_h := maxf(2.0, (size.y - 6.0) * h)
		draw_rect(Rect2(x0 + 1.0 + k * 6.0, mid - bar_h * 0.5, 4.0, bar_h), Color(col, 0.55 + 0.45 * h))
