class_name UnitView
extends Control

## A unit on the skirmish screen: the sprite, its gauges, its intent, and its statuses.
## Gauges hug the drawing (the opaque part of the sprite), not the frame. Mechs carry their
## gauges above the sprite; foes carry one small floating gauge at the top-right. Under every
## sprite runs one row of chips: a foe's intent (fantasy icon plus number) and its statuses;
## a mech's statuses and its warning signs. No names: hold or double-tap for those.
##
## A gauge entry is [value, max, Color] or [value, max, Color, pending]; a pending value
## draws a pulsing overlay over the part of the bar about to change.
##
## Gestures: tap -> `tapped`, double-tap -> `double_tapped`, hold -> `held` / `hold_released`.

signal tapped
signal double_tapped
signal held
signal hold_released

const HOLD_SECONDS := 0.45
const DOUBLE_TAP_SECONDS := DieFaceView.DOUBLE_TAP_SECONDS   # a die's window, the one every double-tap in a fight waits (Ryan, 23 November: "Codex views need the same double-tap delay as other double taps, like the die face")
const STATUS_H := 38.0
const CHIP_H := 30.0
const CHIP_GLYPH := 18.0
const CHIP_TEXT := 16
const BAR_H := 11.0
const BAR_STEP := 14.0
const FLOAT_BAR_W := 60.0
const GAP := 10.0          # between the drawing and its gauges above or its chips below
const FLOAT_LIFT := 16.0   # a foe's floating gauge: how far its bottom row sits above the drawing (any higher and it crowds the rank above)
const LEADER := 16.0       # the floating gauge's leader, in x and in y; it runs onto the sprite, which is allowed
const PENDING_RATE := 3.2  # the one clock every pending mark breathes on, radians a second: a gauge's change and a buff on its way (a preview chip) pulse in step
const CHIP_GAP := 6.0      # between two chips in a row
const ROW_GAP := 4.0       # between two rows of chips
const RIDER_GLYPH := 16.0  # a rider's mark inside the intent chip
const RIDER_TEXT := 14
const RIDER_PAD := 6.0     # before a rider: its divider's room
const ACT_RATE := 9.0      # the acting foe's breath, radians a second: quick, it is happening now
## How a status chip carries its number (Ryan, 22 November: "In StS for instance, the number is
## overlayed on the bottom of the chip ... alternate chip designs that let us incorporate numbers
## in a way that isn't just directly to the right at full size"): "corner", a square tile with its
## number over the bottom-right corner on a dark outline; "tab", a square tile with its number on a
## small solid plate at that corner; "classic", the number at full size to the glyph's right. A
## debug build's CHIP STYLE (Settings), or RIFTGATE_CHIP_STYLE on any run; the first the default.
const CHIP_STYLES := ["corner", "tab", "classic"]
const TILE := 36.0          # a square chip's side
const TILE_GLYPH := 24.0    # its glyph, larger than the classic chip's
const TILE_TEXT := 18       # its number over the corner
const TILE_ROW_GAP := 8.0   # between two rows of square chips: the corner's number and the wedges stand past the edge
const TAB_TEXT := 14        # the tab's number, on its plate
## A foe's intent stands above it, apart from its chips (Ryan, 22 November: "move intents to above
## the enemy unit, be a bit larger, and be either shaped or styled differently than the chips, to
## stand out"), larger: a dark plate edged in the intent's colour, its glyph and number in it, each
## rider after a divider in its own colour, its bottom level with the floating gauge's (the same
## day: "I like the black background, no arrow. Move it up so the bottom is flush with the bottom
## of the HP bar").
const INTENT_H := 40.0
const INTENT_GLYPH := 26.0
const INTENT_TEXT := 26
const INTENT_PAD := 7.0
const INTENT_RIDER_GLYPH := 18.0
const INTENT_RIDER_TEXT := 18

var display_name: String = ""     # for the codex and readouts; never drawn here
var is_enemy: bool = false
var massive: bool = false
var bars: Array = []              # [[value, max, Color, (pending), (points a notch), (broken), (a break point)], ...]
var bars_above: bool = false      # true: full-width gauges above the sprite; false: floating
var pips: Array = []              # [count, of]: a count toward a shot drawn as cells under the gauges (the Cassowary's sixth shot), the last lit when it is next; empty for none
var store: Array = []             # [count, cap, colour, glyph]: a capped store's bar under the heat, a segment a stack up to its cap, lit to its count (the Honey Badger's hopper, the Nemesis's rage); empty for none
var sprite_density := 1.0         # a machine's render is this much larger than the frame it stands for (MechView3D.density); pixel art is 1
var intent_kind: String = ""      # "attack", "defend", "heal", "buff", "debuff", or ""
var intent_value: int = 0
var intent_note: String = ""      # after the number: "×2" for a double strike
## The blow's riders inside the intent chip, after its number (Ryan, 2 November: "Enemy intents with
## a rider need to show that rider as part of the intent chip"): [[glyph, text, Color], ...], a
## scorch with its stacks, a blow at every machine.
var intent_riders: Array = []
var chip_wrap := 0.0              # the widest a row of chips runs before the next row starts; 0, the view's width
var intent: String = ""           # quiet text under a foe, or a corpse's regrowth"
var intent_dim: bool = false
var statuses: Array = []          # [[glyph id, chip text, (Color), (kind), (what)], ...] under the sprite; kind "preview" a buff on its way (a rally's Empowered), pulsing, "ability" the unit's own mechanic, its glyph on a solid tile; what "buff" or "debuff" (Effects.status_kind), its chip's mark
var highlight: bool = false       # valid drop target while dragging a die
## The foe acting in the enemy's turn, lit from just before its move until the next acts (Ryan, 2
## November: "enemies need to highlight during their attacks, starting right before"): a glow in
## the enemy's violet behind its drawing and heavy corners breathing round it, so it reads by
## structure and motion as well as hue.
var acting: bool = false
## A machine in its sealed form (the Polar Bear's Lockdown; Ryan, 2 November: "a better indication
## of what form it's in"): a heavy hexagon shell round its drawing in the shield's blue, steady,
## and a burst as it seals or opens (form_shift), rings closing in or thrown off with the word.
var shell: bool = false
var _shift: float = -1.0          # seconds since its form shifted; negative when idle
var _shift_sealing := true
const SHIFT_SECONDS := 1.1
var dead: bool = false
var away: bool = false             # out of the fight, swallowed (30 October): drawn as a faint ghost under a dashed edge
var sprite: Texture2D = null      # pixel art drawn at an integer scale; null draws a placeholder
var pixel_snap := false           # a foe's pixel art: scaled by whole device pixels, not design pixels (below)
var used_override := Rect2()      # the drawing's extent inside the sprite, when the caller knows it (a 3D view's model bounds)
var breathe: bool = false         # a slow vertical bob from the feet: a painted foe alive
var flip_h: bool = false          # mirror the sprite, so an enemy painted facing right faces left
var breathe_phase: float = 0.0
## Standing on the skirmish's floor (29 October, the field). A foe's drawing stands with its
## feet on `feet_y` rather than centred, so sprites of every height share their rank's ground,
## and `hover` lifts what flies off it; a machine's view is drawn at `sprite_at`, the window of
## the floor's own camera it was rendered for. The shadow lies on the floor at `ground_at`
## (under the feet when unset), flattened by the floor's perspective there.
var ground_shadow: bool = false
var feet_y := -1.0                # the drawing's lowest pixel stands on this line; negative centres it as before
var hover := 0.0                  # how far above its feet line a flyer's drawing floats
var sprite_at := Rect2()          # the frame drawn here, unscaled, when set (a machine's view on the floor)
var ground_at := Vector2(-1.0, -1.0)   # the shadow's centre when set; otherwise under the drawing's feet
var shadow_rx := 0.0              # the shadow's half-width when set; otherwise from the drawing
var shadow_ratio := 0.22          # the shadow's height over its width: the floor's foreshortening where it lies
var empty_pad: bool = false       # an empty slot drawn as a place on the floor rather than a panel
var _shatter: float = -1.0        # seconds since the shield broke on this unit; negative when idle
var _ripple: float = -1.0         # seconds since a blow its shield took landed (ripple_shield); negative when idle
const SHATTER_SECONDS := 0.55
const RIPPLE_SECONDS := 0.5
var _acquire: float = -1.0        # seconds since the display locked onto this unit's intent; negative when idle
const ACQUIRE_SECONDS := 0.3
const SCRAMBLE_PART := 0.55       # the first part of the acquire, while the number is still settling
var _glitch: float = -1.0         # seconds since this unit's picture tore; negative when idle
var _glitch_kind := "tear"        # "tear": slices jump sideways; "drop": the signal goes, static and a tag
var _glitch_for := 0.5            # how long this tear lasts
var _spend: float = -1.0          # seconds since a store's stack went from a chip (the Nemesis's rage); negative when idle
var _spend_glyph := ""           # the chip it went from
const SPEND_SECONDS := 0.55
var _chip_rects := {}             # glyph -> [rect, colour] as last drawn, so a chip's last stack bursts where the chip was

var _pressed := false
var _press_at := 0.0
var _holding := false
var _last_tap_at := -10.0
var _second := false              # this touch came inside the double-tap window
var _tap_due := -1.0              # when a tap waiting out the window lands; negative for none


## A tap waiting out the double-tap window lands now, if one is waiting.
func _land_tap() -> void:
	if _tap_due < 0.0:
		return
	_tap_due = -1.0
	tapped.emit()
var _t := 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST   # the sprite is pixel art; the screen's text is linear
	set_process(false)


## What the view draws, to dress another as it (dress()): a foe the spend kills is stood in for by
## a copy of its view as it stood, its gauge ticking down a blow at a time, until its killing blow
## lands (Ryan, 2 November: "damage needs to be timed to the animation across the board").
const LOOK := ["display_name", "is_enemy", "massive", "bars", "bars_above", "pips", "store", "sprite_density",
	"intent_kind", "intent_value", "intent_note", "intent_riders", "intent", "intent_dim", "statuses", "chip_wrap",
	"sprite", "pixel_snap", "used_override", "breathe", "flip_h", "breathe_phase", "ground_shadow", "feet_y",
	"hover", "sprite_at", "ground_at", "shadow_rx", "shadow_ratio", "empty_pad", "size", "texture_filter"]


func look() -> Dictionary:
	var out := {}
	for key in LOOK:
		var v = get(key)
		out[key] = v.duplicate(true) if v is Array else v
	return out


func dress(d: Dictionary) -> void:
	for key in d.keys():
		set(key, d[key])
	queue_redraw()


## Centre of the drawing, in global coordinates, for arrows.
func anchor_global() -> Vector2:
	return get_global_transform() * _visible().get_center()


func _bars_height() -> float:
	return (bars.size() * BAR_STEP + _pips_step() + _store_step() + GAP) if bars_above and not bars.is_empty() else 0.0


func _pips_step() -> float:
	return BAR_STEP if pips.size() >= 2 and int(pips[1]) > 0 else 0.0   # a gauge's step


## The room a capped store's bar takes in the stack: a gauge's own step.
func _store_step() -> float:
	return BAR_STEP if store.size() >= 2 and int(store[1]) > 0 else 0.0


## The top of the stack of gauges above the drawing.
func _bars_top() -> float:
	return _visible().position.y - GAP - bars.size() * BAR_STEP - _pips_step() - _store_step()


func _scale() -> float:
	if sprite == null:
		return 1.0
	if sprite_at.size.x > 0.0:
		return sprite_at.size.x / maxf(1.0, _sprite_size().x)
	var top := _bars_height() + 2.0
	var avail := size.y - top - STATUS_H
	var ts := _sprite_size()
	if pixel_snap:
		# A foe's sprite pixel lands on a whole number of device pixels (decided 9 October,
		# with the 72x96 frame): on the 1080 phone, two; a denser glass may take three and
		# draw a little larger, the design's 720 one. Scaling by whole design pixels instead
		# put a 72-wide sprite at 1.5 device pixels a pixel, which the nearest filter draws
		# unevenly.
		var d := _device_scale()
		var k := maxf(1.0, floorf(minf(size.x * d / ts.x, avail * d / ts.y)))
		return k / d
	return maxf(1.0, floorf(minf(size.x / ts.x, avail / ts.y)))


## Device pixels per local pixel: the canvas and the window's stretch together; 1 off the
## tree (headless tests), where the design is the glass.
func _device_scale() -> float:
	if not is_inside_tree():
		return 1.0
	var xf := get_viewport().get_final_transform() * get_global_transform_with_canvas()
	return maxf(0.01, xf.get_scale().y)


## The sprite's size in design pixels: its texture's, over the density it was rendered at.
func _sprite_size() -> Vector2:
	return sprite.get_size() / sprite_density


## The opaque part of the sprite, in sprite pixels: told by the caller, or read from the
## image (pixel art only; a viewport texture would be read back from the GPU every frame).
func _used() -> Rect2:
	if used_override.size.x > 0.0 and used_override.size.y > 0.0:
		return Rect2(used_override.position / sprite_density, used_override.size / sprite_density)
	return Sprites.used_rect(sprite)


## The drawn frame on screen (unflipped), for a ghost of the sprite when the unit dies.
func sprite_frame() -> Rect2:
	return _silhouette()


## The whole sprite frame, centred in the sprite area so units of different heights line up
## on their middles. Gauges and chips hug the drawing inside the frame, not the frame.
func _silhouette() -> Rect2:
	var top := (_bars_height() + 2.0) if sprite != null else size.y * 0.12 + _bars_height()
	var avail := size.y - top - STATUS_H
	if sprite != null:
		if sprite_at.size.x > 0.0:
			return sprite_at
		var s := _scale()
		var ts := _sprite_size() * s
		var used := _used()
		if feet_y >= 0.0:
			# On the floor: the drawing's lowest pixel on the feet line (less a flyer's lift), so
			# a short sprite and a tall one stand on the same ground.
			return Rect2(Vector2(floorf((size.x - ts.x) * 0.5), floorf(feet_y - hover - used.end.y * s)), ts)
		# Centre the drawing, not the frame: shift by the frame's own transparent margins.
		var margin_top := used.position.y * s
		var margin_bottom := (_sprite_size().y - used.end.y) * s
		var y := top + (avail - ts.y) * 0.5 + (margin_bottom - margin_top) * 0.5
		return Rect2(Vector2(floorf((size.x - ts.x) * 0.5), floorf(y)), ts)
	var w := size.x * 0.46
	var h := minf(avail, size.y * (0.78 if massive else 0.62))
	return Rect2(Vector2((size.x - w) * 0.5, top + (avail - h) * 0.5), Vector2(w, h))


## The top of what the view draws over the drawing (its gauges, or the drawing itself), in its
## own space: where a readout over the unit rests.
func drawn_top() -> float:
	var vis := _visible()
	if bars.is_empty() or dead:
		return vis.position.y
	if bars_above:
		return vis.position.y - GAP - bars.size() * BAR_STEP - _pips_step() - _store_step()
	return vis.position.y - FLOAT_LIFT


## The opaque part of the drawing on screen: what gauges and chips hug.
func _visible() -> Rect2:
	var sil := _silhouette()
	if sprite == null:
		return sil
	var used := _used()
	var s := _scale()
	return Rect2(sil.position + used.position * s, used.size * s)


func _has_pending() -> bool:
	for b in bars:
		if b.size() >= 4 and int(b[3]) != int(b[0]):
			return true
	for st in statuses:
		if st.size() >= 4 and st[3] == "preview":
			return true   # a buff on its way pulses
	return false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pressed = true
			_holding = false
			_press_at = Time.get_ticks_msec() / 1000.0
			_second = _press_at - _last_tap_at <= DOUBLE_TAP_SECONDS   # the window runs from the last tap's release to this touch, as a die's
			set_process(true)
		else:
			if _holding:
				hold_released.emit()
			elif _pressed:
				var now := Time.get_ticks_msec() / 1000.0
				if _second:
					_second = false
					_last_tap_at = -10.0
					_tap_due = -1.0   # the double-tap stands in for its first tap
					double_tapped.emit()
				else:
					_last_tap_at = now
					_land_tap()
					_tap_due = now + DOUBLE_TAP_SECONDS   # a tap lands once the window has passed, so a double-tap never shows a tap's work
			_pressed = false
			_holding = false
			# The loop stops itself once nothing plays: stopped here, a tear or a dropped signal
			# under the finger froze where it stood (Ryan, 25 October: SIG LOST held for ages).
			set_process(true)
		accept_event()


func _process(delta: float) -> void:
	if _tap_due >= 0.0 and not _pressed and Time.get_ticks_msec() / 1000.0 >= _tap_due:
		_land_tap()
	if _pressed and not _holding and Time.get_ticks_msec() / 1000.0 - _press_at >= HOLD_SECONDS:
		_holding = true
		_tap_due = -1.0
		held.emit()
	if _shatter >= 0.0:
		_shatter += delta
		if _shatter > SHATTER_SECONDS:
			_shatter = -1.0
		queue_redraw()
	if _ripple >= 0.0:
		_ripple += delta
		if _ripple > RIPPLE_SECONDS:
			_ripple = -1.0
		queue_redraw()
	if _acquire >= 0.0:
		_acquire += delta
		if _acquire > ACQUIRE_SECONDS:
			_acquire = -1.0
		queue_redraw()
	if _glitch >= 0.0:
		_glitch += delta
		if _glitch > _glitch_for:
			_glitch = -1.0
		queue_redraw()
	if _spend >= 0.0:
		_spend += delta
		if _spend > SPEND_SECONDS:
			_spend = -1.0
		queue_redraw()
	if _shift >= 0.0:
		_shift += delta
		if _shift > SHIFT_SECONDS:
			_shift = -1.0
		queue_redraw()
	if (_has_pending() or breathe or acting) and visible and not dead:
		_t += delta
		queue_redraw()
	elif not _pressed and _tap_due < 0.0 and _shatter < 0.0 and _ripple < 0.0 and _acquire < 0.0 and _glitch < 0.0 and _spend < 0.0 and _shift < 0.0:
		set_process(false)


func queue_refresh() -> void:
	if _has_pending() or breathe:
		set_process(true)
	queue_redraw()


## The shield just broke on this unit: a hex ring bursts outward and shards fly, in the
## shield's colour, over the drawing. Called by the skirmish screen as the blow lands.
func shatter_shield() -> void:
	_shatter = 0.0
	set_process(true)
	queue_redraw()


## A blow its shield took whole (the to-do's hit reaction, on Ryan's go of 3 November: it shows on
## the shield instead of the hull): the shield's hex lit over the drawing and rippling outward twice in the
## shield's blue, the machine under it untouched. Called by the skirmish screen as the blow lands.
func ripple_shield() -> void:
	_ripple = 0.0
	set_process(true)
	queue_redraw()


## The display locks onto this unit's intent (Ryan, 23 September: a feed being read, not a
## print): bracket corners collapse onto the intent chip, its number settles from a
## scramble, and the gauge's leader draws itself. Called when a round's intents appear and
## when a foe arrives.
func acquire() -> void:
	_acquire = 0.0
	set_process(true)
	queue_redraw()


## This unit's picture is input the display cannot hold for a moment (Ryan, 23 September:
## the corrupted side's tear on one unit, not only across the whole side). "tear": the
## sprite's slices jump sideways; "drop": the signal goes, the sprite fades under static
## and a tag says so.
func glitch(kind: String = "tear", seconds: float = 0.5) -> void:
	_glitch = 0.0
	_glitch_kind = kind
	_glitch_for = seconds
	set_process(true)
	queue_redraw()


## A stack spent from one of this unit's chips (the Nemesis's rage rolling its die again,
## Ryan, 13 October): the chip flashes hot, a ring and sparks burst off it and a "-1" rises.
## Called by the skirmish screen as the stack goes, before the die rolls.
func spend_chip(glyph: String) -> void:
	_spend = 0.0
	_spend_glyph = glyph
	# A capped store's stack goes from its bar (the rage, 22 October): the burst is on the
	# segment that just emptied, the count having already dropped.
	if store.size() >= 4 and str(store[3]) == glyph and int(store[1]) > 0:
		var at := clampi(int(store[0]), 0, int(store[1]) - 1)
		_chip_rects[glyph] = [_store_cell(at).grow(3.0), store[2]]
	set_process(true)
	queue_redraw()


## The machine's form shifts as a spend lands (the Polar Bear seals or opens): a burst of rings, closing
## in on it as it seals or thrown off as it opens, and the word, SEALED or OPEN, rising off it.
func form_shift(sealing: bool) -> void:
	_shift = 0.0
	_shift_sealing = sealing
	set_process(true)
	queue_redraw()


## The shell's hexagon round the drawing, `grow` past its usual size.
func _shell_points(vis: Rect2, grow: float) -> PackedVector2Array:
	var r := maxf(vis.size.x, vis.size.y) * 0.5 + 12.0 + grow
	var c := vis.get_center()
	var pts := PackedVector2Array()
	for k in range(7):
		var a := PI / 6.0 + TAU * float(k % 6) / 6.0
		pts.append(c + Vector2(cos(a) * r, sin(a) * r * 0.78))   # a touch flattened, as the floor lies
	return pts


func _draw_shell(vis: Rect2) -> void:
	var col := Palette.SHIELD
	if shell:
		var pts := _shell_points(vis, 0.0)
		draw_colored_polygon(pts, Color(col, 0.08))
		draw_polyline(pts, Color(Palette.BG, 0.85), 7.0)
		draw_polyline(pts, col, 3.5)
	if _shift < 0.0:
		return
	var t := clampf(_shift / SHIFT_SECONDS, 0.0, 1.0)
	for k in range(3):
		# Three rings a beat apart: closing onto the shell as it seals, thrown off it as it opens.
		var u := clampf(t * 1.6 - k * 0.22, 0.0, 1.0)
		if u <= 0.0 or u >= 1.0:
			continue
		var grow := (1.0 - u) * 70.0 if _shift_sealing else u * 70.0
		var a := (u if _shift_sealing else 1.0 - u) * 0.9
		draw_polyline(_shell_points(vis, grow), Color(Palette.BG, a * 0.7), 6.0)
		draw_polyline(_shell_points(vis, grow), Color(col, a), 3.0)
	var font := Hud.display_bold()
	var word := "SEALED" if _shift_sealing else "OPEN"
	var w := font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	var y := vis.position.y - 8.0 - 26.0 * t
	var plate := Rect2(vis.get_center().x - w * 0.5 - 8.0, y - 22.0, w + 16.0, 30.0)
	var fade := 1.0 - maxf(0.0, t - 0.6) / 0.4
	Hud.box(self, plate, 4.0, Color(Palette.BG, 0.9 * fade), Color(col, fade), 2.0)
	draw_string(font, Vector2(plate.position.x, plate.end.y - 8.0), word, HORIZONTAL_ALIGNMENT_CENTER, plate.size.x, 22, Color(col, fade))


## The opaque part of the drawing, in this view's pixels, for anything drawn around the
## unit from outside (the feed's analysis boxes).
func drawing_rect() -> Rect2:
	return _visible()


## The sprite drawn torn: seven slices, most holding, a few thrown sideways and one tinted;
## a dropped signal draws them faint under static with a tag.
func _draw_glitched(frame: Rect2) -> void:
	var drop := _glitch_kind == "drop"
	var tick := int(_glitch * 24.0)   # the slices hold a new position for a few frames each
	var ts := sprite.get_size()
	var n := 7
	for k in range(n):
		var f0 := float(k) / float(n)
		var f1 := float(k + 1) / float(n)
		var src := Rect2(0.0, ts.y * f0, ts.x, ts.y * (f1 - f0))
		# A tear throws slices sideways; a dropped signal barely moves them (Ryan, 23 September:
		# the two read alike), it fades the picture and fills it with static.
		var off := (Hud.noise(tick * 1.3 + k * 0.77 + breathe_phase) - 0.5) * (6.0 if drop else 18.0)
		if Hud.noise(tick * 2.1 + k * 0.31 + breathe_phase) < (0.7 if drop else 0.4):
			off = 0.0
		var dst := Rect2(Vector2(frame.position.x + off, frame.position.y + frame.size.y * f0), Vector2(frame.size.x, frame.size.y * (f1 - f0)))
		var mod := Color.WHITE
		if drop:
			mod = Color(1, 1, 1, 0.12 + 0.18 * Hud.noise(tick + k * 0.5))
		elif Hud.noise(tick * 3.3 + k * 0.17) > 0.8:
			mod = Color(1.3, 0.6, 1.6)   # a slice in the enemy's violet (30 October; it was red)
		draw_texture_rect_region(sprite, dst, src, mod)
	if drop:
		var r := frame.abs()
		for j in range(22):
			var yy := r.position.y + Hud.noise(tick * 0.7 + j * 0.61) * r.size.y
			var x0 := r.position.x + Hud.noise(tick * 1.9 + j * 0.23) * r.size.x * 0.6
			var w := r.size.x * (0.15 + 0.4 * Hud.noise(tick * 0.4 + j * 0.83))
			draw_rect(Rect2(x0, yy, w, 1.0), Color(Palette.HUD, 0.3 + 0.3 * Hud.noise(tick * 1.1 + j)))
		# The tag on a dark plate, in the enemy's colour, blinking slowly.
		if int(_glitch * 3.0) % 2 == 0:
			var font := Hud.display_bold()
			var tw := font.get_string_size("SIG LOST", HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
			var plate := Rect2(r.get_center().x - tw * 0.5 - 8.0, r.get_center().y - 13.0, tw + 16.0, 26.0)
			Hud.box(self, plate, 4.0, Color(Palette.BG, 0.9), Palette.ENEMY, 1.2)
			draw_string(font, Vector2(plate.position.x, plate.get_center().y + 6.0), "SIG LOST", HORIZONTAL_ALIGNMENT_CENTER, plate.size.x, 16, Palette.ENEMY)


func _draw_shatter(vis: Rect2) -> void:
	var t := clampf(_shatter / SHATTER_SECONDS, 0.0, 1.0)
	var c := vis.get_center()
	var r0 := minf(vis.size.x, vis.size.y) * 0.42
	var ring := Color(Palette.SHIELD, (1.0 - t) * 0.9)
	draw_polyline(Hex.corners(c, r0 * (1.0 + t * 0.9)), ring, 2.5 * (1.0 - t * 0.6), true)
	if t < 0.5:
		draw_polyline(Hex.corners(c, r0 * (1.0 + t * 0.4)), Color(Color.WHITE, (0.5 - t) * 1.2), 1.5, true)
	for k in range(8):
		var ang := TAU * float(k) / 8.0 + 0.3
		var dir := Vector2(cos(ang), sin(ang))
		var a := c + dir * r0 * (0.6 + t * 1.6)
		var b := a + dir * (10.0 + 14.0 * (1.0 - t))
		draw_line(a, b, Color(Palette.SHIELD, (1.0 - t) * 0.8), 2.0)


func _draw_ripple(vis: Rect2) -> void:
	var t := clampf(_ripple / RIPPLE_SECONDS, 0.0, 1.0)
	var c := vis.get_center()
	var r0 := minf(vis.size.x, vis.size.y) * 0.46
	# The shield's face lit for a moment, then two rings running out over it, the second behind.
	if t < 0.45:
		draw_colored_polygon(Hex.corners(c, r0), Color(Palette.SHIELD, 0.32 * (1.0 - t / 0.45)))
	draw_polyline(_closed_hex(c, r0), Color(Palette.SHIELD, 0.9 * (1.0 - t)), 3.0, true)
	for lag in [0.0, 0.25]:
		var u := clampf((t - lag) / (1.0 - lag), 0.0, 1.0)
		if u <= 0.0 or u >= 1.0:
			continue
		draw_polyline(_closed_hex(c, r0 * (1.0 + u * 0.35)), Color(Palette.SHIELD, 0.95 * (1.0 - u)), 3.5 * (1.0 - u * 0.5), true)


static func _closed_hex(c: Vector2, r: float) -> PackedVector2Array:
	var pts := Hex.corners(c, r)
	pts.append(pts[0])
	return pts


## The stack going (spend_chip): hot and loud, since every effect judged on the phone has come
## back hotter. Drawn over the chip, or where the chip was when that was its last stack.
func _draw_spend(mono: Font) -> void:
	if _spend < 0.0 or not _chip_rects.has(_spend_glyph):
		return
	var t := clampf(_spend / SPEND_SECONDS, 0.0, 1.0)
	var rect: Rect2 = _chip_rects[_spend_glyph][0]
	var col: Color = _chip_rects[_spend_glyph][1]
	var c := rect.get_center()
	# The flash: the chip floods with its colour, white at the core for the first moment.
	Hud.fill_poly(self, Hud.cut(rect.grow(3.0 * (1.0 - t)), 4.0), Color(col, 0.9 * (1.0 - t)))
	if t < 0.35:
		Hud.fill_poly(self, Hud.cut(rect.grow(-5.0), 3.0), Color(Color.WHITE, (0.35 - t) * 2.6))
	# The ring, bursting off the chip, and the sparks flying ahead of it.
	Hud.stroke_poly(self, Hud.cut(rect.grow(4.0 + 34.0 * t), 6.0), Color(col, 1.0 - t), 3.5 * (1.0 - t * 0.5))
	for k in range(10):
		var ang := TAU * float(k) / 10.0 + 0.2
		var dir := Vector2(cos(ang), sin(ang) * 0.7)
		var a := c + dir * (rect.size.x * 0.5 + 40.0 * t)
		draw_line(a, a + dir * (9.0 + 13.0 * (1.0 - t)), Color(col, (1.0 - t) * 0.95), 2.5)
	# The count going: a -1 rising off the chip, on a dark edge so it holds over any ground.
	var y := rect.position.y - 8.0 - 30.0 * t
	draw_string_outline(mono, Vector2(rect.position.x, y), "-1", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, 4, Color(Palette.BG, (1.0 - t * t) * 0.9))
	draw_string(mono, Vector2(rect.position.x, y), "-1", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, Color(col, 1.0 - t * t))


func _draw() -> void:
	var hud := Palette.HUD
	var mono := Hud.mono()
	var sil := _silhouette()
	var vis := _visible()
	var act := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * ACT_RATE) if acting and not dead else -1.0
	if act >= 0.0:
		# The acting foe's glow, behind everything it draws.
		Hud.fill_poly(self, Hud.cut(vis.grow(12.0), 12.0), Color(Palette.ENEMY, 0.18 + 0.17 * act))
		Hud.stroke_poly(self, Hud.cut(vis.grow(12.0), 12.0), Color(Palette.ENEMY, 0.35 + 0.3 * act), 2.0)
	if sprite != null and ground_shadow:
		var foot := ground_at if ground_at.x >= 0.0 else Vector2(vis.get_center().x, vis.end.y + hover - 1.0)
		var rx := shadow_rx if shadow_rx > 0.0 else vis.size.x * (0.4 if hover > 0.0 else 0.5)
		_draw_shadow(foot, rx, 0.2 if dead else (0.28 if hover > 0.0 else 0.42))
	if sprite != null:
		var breath := breath_frame()
		var frame: Rect2 = breath[0]
		if flip_h:
			frame = Rect2(Vector2(frame.end.x, frame.position.y), Vector2(-frame.size.x, frame.size.y))
		if _glitch >= 0.0 and not dead:
			_draw_glitched(frame)
		else:
			var lean: Transform2D = breath[1]
			if lean != Transform2D.IDENTITY:
				draw_set_transform_matrix(lean)
			draw_texture_rect(sprite, frame, false, Color(0.3, 0.3, 0.3) if dead else (Color(1, 1, 1, 0.22) if away else Color.WHITE))
			if lean != Transform2D.IDENTITY:
				draw_set_transform_matrix(Transform2D.IDENTITY)
		if away and not dead:
			_draw_dashed(vis.grow(6.0), Palette.ENEMY, 3.0)   # round the drawing itself: the field's views are wider than their machines
	elif empty_pad:
		# A place on the floor: a shadow with a dashed rim where a foe would stand.
		var foot := Vector2(size.x * 0.5, feet_y if feet_y >= 0.0 else sil.end.y - 6.0)
		var rx := size.x * 0.36
		_draw_shadow(foot, rx, 0.3)
		for k in range(16):
			if k % 2 == 0:
				var a0 := TAU * float(k) / 16.0
				var a1 := TAU * float(k + 1) / 16.0
				draw_line(foot + Vector2(cos(a0) * rx, sin(a0) * rx * shadow_ratio), foot + Vector2(cos(a1) * rx, sin(a1) * rx * shadow_ratio), Color(0, 0, 0, 0.5), 2.0)
	else:
		var edge := Color(Palette.LOSS_DIM if dead else hud, 0.4)
		Hud.box(self, sil, 10.0, Color(Palette.PANEL_RAISED, 0.9), edge, 1.0)
	if dead:
		draw_line(vis.position, vis.end, Palette.LOSS_DIM, 2.0)
		draw_line(Vector2(vis.position.x, vis.end.y), Vector2(vis.end.x, vis.position.y), Palette.LOSS_DIM, 2.0)
	if highlight:
		Hud.brackets(self, vis.grow(6.0), 14.0, Palette.TARGET, 2.0)
	if act >= 0.0:
		# Heavy corners breathing round the acting foe, on a dark edge so they hold on any ground.
		var r := vis.grow(14.0 + 4.0 * act)
		Hud.brackets(self, r, 22.0, Color(Palette.BG, 0.8), 7.0)
		Hud.brackets(self, r, 22.0, Palette.ENEMY, 4.0)
	if _shatter >= 0.0:
		_draw_shatter(vis)
	if (shell or _shift >= 0.0) and not dead:
		_draw_shell(vis)
	if _ripple >= 0.0:
		_draw_ripple(vis)

	# Every gauge has a dark ground of its own shape (Ryan, 23 September: the plate under the
	# stack was a box; the bars keep the chamfer and the ground keeps them readable on
	# terrain). Gauges and chips stand a little off the drawing, not against it.
	if not bars.is_empty() and not dead:
		if bars_above:
			# Full-width gauges stacked above the drawing: hull, shield, heat.
			var bx := size.x * 0.1
			var bw := size.x * 0.8
			var y := vis.position.y - GAP - bars.size() * BAR_STEP - _pips_step() - _store_step()
			for b in bars:
				_gauge(Rect2(bx, y, bw, BAR_H), b)
				y += BAR_STEP
			# A capped store's bar nestles under them, the heat's last, in their shape.
			if _store_step() > 0.0:
				_draw_store(Rect2(bx, y, bw, BAR_H))
				y += _store_step()
			if _pips_step() > 0.0:
				_draw_pips(Rect2(bx, y, bw, BAR_H))
		else:
			# One small gauge floating above the drawing's top-right, with a leader dropping
			# from a third of the way along its underside, diagonally down-left onto the sprite.
			# On acquire the leader draws itself.
			var bx := _float_x()
			var y := vis.position.y - FLOAT_LIFT
			var from := Vector2(bx + FLOAT_BAR_W / 3.0, y + BAR_H)
			var reach := 1.0 if _acquire < 0.0 else clampf(_acquire / (ACQUIRE_SECONDS * 0.6), 0.0, 1.0)
			if reach > 0.0:
				# Thicker, on a dark edge, so it holds on the phone and on the other world's
				# green when the HUD is green (Ryan, 28 September).
				var tip := from + Vector2(-LEADER, LEADER) * reach
				draw_line(from, tip, Color(Palette.BG, 0.7), 5.0)
				draw_line(from, tip, Color(hud, 1.0), 3.0)
			for b in bars:
				_gauge(Rect2(bx, y, FLOAT_BAR_W, BAR_H), b)
				y -= BAR_STEP

	# Quiet readout for an empty slot.
	if not intent.is_empty() and not dead and sprite == null and intent_kind.is_empty():
		draw_string(mono, Vector2(0, sil.get_center().y + 5.0), "[%s]" % intent, HORIZONTAL_ALIGNMENT_CENTER, size.x, 13, Color(hud, 0.45 if intent_dim else 0.95))

	# The chips under the drawing, the statuses, centred in rows that wrap at the view's width
	# (Ryan, 2 November: "chips can go off the sides of the screen if there are too many ... Need
	# to wrap rows"), each row kept on the screen (chip_layout); the intent's plate above it.
	if dead:
		return
	var acq := clampf(_acquire / ACQUIRE_SECONDS, 0.0, 1.0) if _acquire >= 0.0 else 1.0
	for laid_chip in chip_layout():
		var rect: Rect2 = laid_chip[0]
		var ch: Array = laid_chip[1]
		_chip_rects[ch[0]] = [rect, ch[2]]
		draw_chip(self, rect, ch, mono)
	var ir := intent_rect()
	if ir.size.x > 0.0:
		var ich := intent_chip()
		var locking := acq < 1.0
		var txt: String = ich[1]
		if locking and acq < SCRAMBLE_PART:
			txt = Hud.scramble(txt, int(Time.get_ticks_msec() / 45), get_instance_id() % 97)
		draw_intent(self, ir, ich, mono, txt)
		if locking:
			# The lock: bracket corners collapsing onto the plate, fading as they land.
			Hud.brackets(self, ir.grow(3.0 + 18.0 * (1.0 - acq)), 10.0, Color(ich[2], 1.0 - acq * 0.7), 2.0)
	_draw_spend(mono)


## The chips under the drawing as they lay out, in order: [[Rect2 in the view, the chip], ...]: rows
## that wrap at `chip_wrap` (the view's width when none), each centred under the view and held on
## the screen, the first row just under the drawing. Empty for a dead unit or one with no chips. The
## intent stands apart, above the drawing (intent_rect).
func chip_layout() -> Array:
	var out: Array = []
	if dead:
		return out
	var hud := Palette.HUD
	var mono := Hud.mono()
	var chips: Array = []
	for s in statuses:
		chips.append([s[0], str(s[1]), s[2] if s.size() >= 3 else hud, s[3] if s.size() >= 4 else "status", [], s[4] if s.size() >= 5 else ""])
	if chips.is_empty():
		return out
	var widths: Array[float] = []
	for ch in chips:
		widths.append(chip_width(mono, ch))
	var rows := chip_rows(widths, chip_wrap if chip_wrap > 0.0 else size.x)
	var span := _screen_span()
	var h := chip_h()
	var cy := minf(_visible().end.y + GAP, size.y - 2.0) + h * 0.5
	cy = minf(cy, size.y - h * 0.5 - 1.0)
	for row in rows:
		var total := 0.0
		for i in row:
			total += widths[i] + CHIP_GAP
		total -= CHIP_GAP
		var x := floorf((size.x - total) * 0.5)
		x = clampf(x, span.x, maxf(span.x, span.y - total))
		for i in row:
			out.append([Rect2(x, cy - h * 0.5, widths[i], h), chips[i]])
			x += widths[i] + CHIP_GAP
		cy += h + row_gap()
	return out


## The screen's span in the view's x, inset 2 px: [left, right] (unbounded without a parent).
func _screen_span() -> Vector2:
	var parent := get_parent() as Control
	if parent == null:
		return Vector2(-INF, INF)
	return Vector2(2.0 - position.x, parent.size.x - position.x - 2.0)


## The intent as its plate draws it ([glyph, text, Color, "intent", riders]), or empty for none.
func intent_chip() -> Array:
	if intent_kind.is_empty():
		return []
	return [Glyphs.intent_for(intent_kind), (str(intent_value) + intent_note) if intent_value > 0 else "", Palette.ENEMY if is_enemy else Palette.HUD, "intent", intent_riders]


## The intent's plate in the view: over the drawing, left of the floating gauge, its bottom level
## with the gauge's lowest bar, held on the screen; an empty rect for a dead unit or one showing no
## intent.
func intent_rect() -> Rect2:
	if dead or intent_kind.is_empty():
		return Rect2()
	var w := chip_width(Hud.mono(), intent_chip())
	var vis := _visible()
	var span := _screen_span()
	var x := floorf(vis.get_center().x - w * 0.5)
	if not bars.is_empty() and not bars_above:
		x = minf(x, _float_x() - 6.0 - w)   # clear of the floating gauge at the drawing's top-right, its pointer still on the drawing
	x = clampf(x, span.x, maxf(span.x, span.y - w))
	var bottom := vis.position.y - FLOAT_LIFT + BAR_H   # the floating gauge's lowest bar's bottom (_draw)
	return Rect2(x, bottom - INTENT_H, w, INTENT_H)


## The floating gauge's left edge (a foe's): at the drawing's top-right, held in the view.
func _float_x() -> float:
	var vis := _visible()
	return minf(vis.end.x - 10.0, size.x - FLOAT_BAR_W - 2.0)


## Where a foe's intent arrow leaves it: the middle of its drawing (Ryan, 22 November: "Put intent
## arrows coming from the center of the portrait"), the plate standing above it.
func intent_anchor_global() -> Vector2:
	return anchor_global()


## The chips' rows: each as many chips, in order, as fit `wrap` with their gaps, a chip wider than
## the row on a row of its own. Index lists, the first row first.
static func chip_rows(widths: Array, wrap: float) -> Array:
	var rows: Array = [[]]
	var run := 0.0
	for i in range(widths.size()):
		var w := float(widths[i])
		var row: Array = rows.back()
		if not row.is_empty() and run + CHIP_GAP + w > wrap:
			rows.append([i])
			run = w
		else:
			run += (CHIP_GAP if not row.is_empty() else 0.0) + w
			row.append(i)
	return rows


## The chip style drawn now (CHIP_STYLES).
static func chip_style() -> String:
	return Settings.look("RIFTGATE_CHIP_STYLE", "chip_style", CHIP_STYLES)


## A status chip is a square tile with its number at its corner, in either square style.
static func square() -> bool:
	return chip_style() != "classic"


## A status chip's height and the gap between two rows of them, in the style drawn now.
static func chip_h() -> float:
	return TILE if square() else CHIP_H


static func row_gap() -> float:
	return TILE_ROW_GAP if square() else ROW_GAP


## A chip's size: an intent's plate (draw_intent), or a status chip in the style drawn now.
static func chip_size(mono: Font, ch: Array) -> Vector2:
	if _is_intent(ch):
		return Vector2(chip_width(mono, ch), INTENT_H)
	return Vector2(chip_width(mono, ch), chip_h())


static func _is_intent(ch: Array) -> bool:
	return ch.size() > 3 and str(ch[3]) == "intent"


## A count as a square chip's corner shows it: the multiplication sign goes, the number is the
## stacks ("×2" is 2); a sign of more or less stays.
static func corner_text(t: String) -> String:
	return t.trim_prefix("×")


## A chip's width: an intent's plate (draw_intent); a square tile in the square styles; else its
## glyph's square and its text. `ch` is [glyph, text, Color, kind, riders].
const ABILITY_TEXT_GAP := 5.0   # what an ability chip's text stands off its solid tile

static func chip_width(mono: Font, ch: Array) -> float:
	if _is_intent(ch):
		return draw_intent(null, Rect2(), ch, mono)
	if square():
		return TILE
	var txt := str(ch[1])
	var w := CHIP_H + (mono.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, CHIP_TEXT).x + 8.0 if not txt.is_empty() else 0.0)
	if not txt.is_empty() and ch.size() > 3 and str(ch[3]) == "ability":
		w += ABILITY_TEXT_GAP   # its text stands clear of its solid tile (draw_chip)
	for r in (ch[4] if ch.size() > 4 else []):
		w += RIDER_PAD + RIDER_GLYPH + 4.0
		var rt := str(r[1])
		if not rt.is_empty():
			w += mono.get_string_size(rt, HORIZONTAL_ALIGNMENT_LEFT, -1, RIDER_TEXT).x + 2.0
	return w


## One chip in `rect` on `ci` (the field's views, a readout's mark): its frame by its kind (a
## coming status's dashed pulse, an ability's solid tile, a status's box), its glyph, its text
## (`txt`, or its own), then each rider after a divider, its mark and its number in its own
## colour; a buff's or a debuff's mark at its corner (`ch` [glyph, text, Color, kind, riders,
## what]: _polarity_mark).
static func draw_chip(ci: CanvasItem, rect: Rect2, ch: Array, mono: Font, txt = null) -> void:
	if _is_intent(ch):
		draw_intent(ci, rect, ch, mono, txt)
		return
	if square():
		_draw_tile(ci, rect, ch, mono, txt)
		return
	var col: Color = ch[2]
	var kind := str(ch[3]) if ch.size() > 3 else "status"
	var glyph_col := col
	if kind == "preview":
		# A buff on its way (a rally's Empowered, Ryan, 26 October: "a pulsing version of the
		# incoming buff as a preview chip"): an opacity pulse, as a gauge's change is ("Similar
		# in concept to the health and shield bars"), on the gauges' one clock, a full swing
		# between faint and lit on its dark ground, its edge dashed, so "coming" reads by
		# motion and structure, never by hue.
		var beat := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * PENDING_RATE)
		Hud.fill_poly(ci, Hud.cut(rect, 4.0), Color(Palette.BG, 0.94))
		col = Color(col, 0.3 + 0.7 * beat)
		dashed_rect(ci, rect, col, 2.0)
	elif kind == "ability":
		# An ability (Ryan, 8 November: "It's not a Buff, it's not a Debuff, it's labelled as an
		# Ability, so it doesn't get purged"): the unit's own mechanic, its glyph cut out of a
		# solid tile in its colour inside the chip's heavier box, so it reads by structure, never
		# by hue, as the rule the unit plays by (placeholders to judge on the phone).
		Hud.box(ci, rect, 4.0, Color(Palette.BG, 0.94), col, 2.0)
		var p := rect.position
		var tile_end := minf(rect.end.x, p.x + CHIP_H)
		var tile := PackedVector2Array([Vector2(p.x + 4.0, p.y), Vector2(tile_end, p.y), Vector2(tile_end, rect.end.y), Vector2(p.x, rect.end.y), Vector2(p.x, p.y + 4.0)])
		if tile_end >= rect.end.x:
			tile = Hud.cut(rect, 4.0)
		Hud.fill_poly(ci, tile, col)
		glyph_col = Palette.BG
	else:
		Hud.box(ci, rect, 4.0, Color(Palette.BG, 0.94), col, 1.2)
	var cy := rect.get_center().y
	Glyphs.draw(ci, str(ch[0]), Vector2(rect.position.x + CHIP_H * 0.5, cy), CHIP_GLYPH, glyph_col if kind != "preview" else col, 2.0)
	var text := str(ch[1]) if txt == null else str(txt)
	var x := rect.position.x + CHIP_H - 2.0
	if kind == "ability":
		x += ABILITY_TEXT_GAP   # clear of the solid tile, in whose colour the text is drawn: a bare count's first stroke sat under it (the Ammit's Essence, 12 November)
	if not text.is_empty():
		ci.draw_string(mono, Vector2(x, cy + CHIP_TEXT * 0.36), text, HORIZONTAL_ALIGNMENT_LEFT, -1, CHIP_TEXT, col)
		x += mono.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, CHIP_TEXT).x + 8.0
	else:
		x = rect.position.x + CHIP_H
	for r in (ch[4] if ch.size() > 4 else []):
		# A rider: a divider, then its mark and its number in its own colour (its term's).
		var rc: Color = r[2]
		rc.a *= col.a
		ci.draw_line(Vector2(x + RIDER_PAD * 0.5 - 2.0, rect.position.y + 5.0), Vector2(x + RIDER_PAD * 0.5 - 2.0, rect.end.y - 5.0), Color(col, 0.55 * col.a), 1.0)
		x += RIDER_PAD
		Glyphs.draw(ci, str(r[0]), Vector2(x + RIDER_GLYPH * 0.5, cy), RIDER_GLYPH, rc, 1.8)
		x += RIDER_GLYPH + 4.0
		var rt := str(r[1])
		if not rt.is_empty():
			ci.draw_string(mono, Vector2(x - 2.0, cy + RIDER_TEXT * 0.36), rt, HORIZONTAL_ALIGNMENT_LEFT, -1, RIDER_TEXT, rc)
			x += mono.get_string_size(rt, HORIZONTAL_ALIGNMENT_LEFT, -1, RIDER_TEXT).x + 2.0
	_polarity_mark(ci, rect, str(ch[5]) if ch.size() > 5 else "", col)


## A buff's or a debuff's mark on its chip (Ryan, 9 November: "Buffs and debuffs ... need to be
## clearly labeled as such, so that it's clear what gets purged"): a solid wedge on the chip's
## edge, pointing up off its top at the left for a buff and down off its bottom at the right for a
## debuff, in the chip's colour on a dark edge, so the two part by shape and place, never by hue
## (Ryan is colourblind), and a debuff over a buff in the next row never meets its wedge; an
## ability's solid tile, a store and a warning wear none. Hot, for the phone.
const POLARITY_W := 12.0   # the wedge's base, along the chip's edge
const POLARITY_H := 8.0    # how far it stands off the edge, half of it past the chip

static func _polarity_mark(ci: CanvasItem, rect: Rect2, what: String, col: Color) -> void:
	if what != "buff" and what != "debuff":
		return
	var up := what == "buff"
	var x0 := rect.position.x + 5.0 if up else rect.end.x - 5.0 - POLARITY_W
	if square():
		# A square chip's number holds its bottom-right corner: the buff's wedge stands off the top
		# at the right and the debuff's off the bottom at the left, still a diagonal apart.
		x0 = rect.end.x - 5.0 - POLARITY_W if up else rect.position.x + 5.0
	var edge := rect.position.y if up else rect.end.y
	var dir := -1.0 if up else 1.0   # away from the chip
	var base_y := edge - dir * POLARITY_H * 0.5
	var tip := Vector2(x0 + POLARITY_W * 0.5, edge + dir * POLARITY_H * 0.5)
	var wedge := PackedVector2Array([Vector2(x0, base_y), Vector2(x0 + POLARITY_W, base_y), tip])
	var rim := PackedVector2Array([Vector2(x0 - 2.0, base_y - dir * 1.0), Vector2(x0 + POLARITY_W + 2.0, base_y - dir * 1.0), tip + Vector2(0.0, dir * 2.0)])
	ci.draw_colored_polygon(rim, Color(Palette.BG, 0.95 * col.a))
	ci.draw_colored_polygon(wedge, col)


## A status chip as a square tile (the square styles): its frame by its kind as the classic chip's,
## its glyph larger and centred, and its number at the bottom-right corner, over it on a dark
## outline ("corner") or on a small plate of the chip's colour ("tab").
static func _draw_tile(ci: CanvasItem, rect: Rect2, ch: Array, mono: Font, txt = null) -> void:
	var col: Color = ch[2]
	var kind := str(ch[3]) if ch.size() > 3 else "status"
	var glyph_col := col
	if kind == "preview":
		var beat := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * PENDING_RATE)
		Hud.fill_poly(ci, Hud.cut(rect, 4.0), Color(Palette.BG, 0.94))
		col = Color(col, 0.3 + 0.7 * beat)
		glyph_col = col
		dashed_rect(ci, rect, col, 2.0)
	elif kind == "ability":
		# The ability's solid tile is the whole chip, its glyph cut out of it.
		Hud.fill_poly(ci, Hud.cut(rect.grow(1.0), 5.0), Color(Palette.BG, 0.94))
		Hud.fill_poly(ci, Hud.cut(rect, 4.0), col)
		glyph_col = Palette.BG
	else:
		Hud.box(ci, rect, 4.0, Color(Palette.BG, 0.94), col, 1.5)
	var text := corner_text(str(ch[1]) if txt == null else str(txt))
	var c := rect.get_center()
	if not text.is_empty():
		c += Vector2(-3.0, -3.0)   # the glyph leans off the corner its number holds
	Glyphs.draw(ci, str(ch[0]), c, TILE_GLYPH, glyph_col, 2.2)
	if not text.is_empty():
		_draw_count(ci, rect, text, col)
	_polarity_mark(ci, rect, str(ch[5]) if ch.size() > 5 else "", col)


## A square chip's number at its bottom-right corner, standing a little past it.
static func _draw_count(ci: CanvasItem, rect: Rect2, text: String, col: Color) -> void:
	var font := Hud.display_bold()
	if chip_style() == "tab":
		var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, TAB_TEXT).x
		var plate := Rect2(rect.end.x + 3.0 - (tw + 7.0), rect.end.y - 11.0, tw + 7.0, 16.0)
		Hud.fill_poly(ci, Hud.cut(plate.grow(1.5), 3.0), Color(Palette.BG, 0.95 * col.a))
		Hud.fill_poly(ci, Hud.cut(plate, 2.5), col)
		var ink := Palette.BG if col.get_luminance() > 0.45 else Palette.INK   # dark on a light plate, light on a dark one (the shield's blue)
		ci.draw_string(font, Vector2(plate.position.x + 3.5, plate.end.y - 3.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, TAB_TEXT, Color(ink, col.a))
		return
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, TILE_TEXT).x
	var at := Vector2(rect.end.x + 3.0 - w, rect.end.y + 4.0)
	ci.draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, TILE_TEXT, 6, Color(Palette.BG, 0.95 * col.a))
	ci.draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, TILE_TEXT, Color(Palette.INK, col.a))


## A foe's intent plate in `rect` on `ci`, or with `ci` null only measured: returns its width. A
## dark plate edged in the intent's colour, its glyph and number in that colour (`txt`, or its own),
## each rider after a divider, its mark and number in its own colour (its term's).
static func draw_intent(ci: CanvasItem, rect: Rect2, ch: Array, mono: Font, txt = null) -> float:
	var col: Color = ch[2]
	var font := Hud.display_bold()
	var text := str(ch[1]) if txt == null else str(txt)
	var riders: Array = ch[4] if ch.size() > 4 else []
	var cy := rect.get_center().y
	if ci != null:
		Hud.fill_poly(ci, Hud.cut(rect.grow(2.0), 8.0), Color(Palette.BG, 0.9 * col.a))   # a dark edge outside the colour's, for any ground
		Hud.fill_poly(ci, Hud.cut(rect, 7.0), Color(Palette.BG, 0.94 * col.a))
		Hud.stroke_poly(ci, Hud.cut(rect, 7.0), col, 3.0)
	var x := rect.position.x + INTENT_PAD
	if ci != null:
		Glyphs.draw(ci, str(ch[0]), Vector2(x + INTENT_GLYPH * 0.5, cy), INTENT_GLYPH, col, 3.0)
	x += INTENT_GLYPH
	if not text.is_empty():
		x += 3.0
		if ci != null:
			ci.draw_string(font, Vector2(x, cy + INTENT_TEXT * 0.36), text, HORIZONTAL_ALIGNMENT_LEFT, -1, INTENT_TEXT, col)
		x += font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, INTENT_TEXT).x
	x += INTENT_PAD
	for r in riders:
		var rt := str(r[1])
		var rw := 5.0 + INTENT_RIDER_GLYPH + (2.0 + font.get_string_size(rt, HORIZONTAL_ALIGNMENT_LEFT, -1, INTENT_RIDER_TEXT).x if not rt.is_empty() else 0.0) + 5.0
		if ci != null:
			var rc: Color = r[2]
			rc.a *= col.a
			var at := x - 2.0
			ci.draw_line(Vector2(at - 2.0, rect.position.y + 7.0), Vector2(at - 2.0, rect.end.y - 7.0), Color(col, 0.6 * col.a), 2.0)
			Glyphs.draw(ci, str(r[0]), Vector2(at + 5.0 + INTENT_RIDER_GLYPH * 0.5, cy), INTENT_RIDER_GLYPH, rc, 2.0)
			if not rt.is_empty():
				ci.draw_string(font, Vector2(at + 5.0 + INTENT_RIDER_GLYPH + 2.0, cy + INTENT_RIDER_TEXT * 0.36), rt, HORIZONTAL_ALIGNMENT_LEFT, -1, INTENT_RIDER_TEXT, rc)
		x += rw + 4.0
	return x - rect.position.x


## A rect drawn in dashes on any canvas item (a chip's edge), its dark edge under each dash.
static func dashed_rect(ci: CanvasItem, rect: Rect2, color: Color, width: float) -> void:
	var dash := 9.0
	var gap := 6.0
	var corners := [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
	for k in range(4):
		var a: Vector2 = corners[k]
		var b: Vector2 = corners[(k + 1) % 4]
		var length := a.distance_to(b)
		var dir := (b - a) / maxf(1.0, length)
		var t := 0.0
		while t < length:
			ci.draw_line(a + dir * t, a + dir * minf(t + dash, length), Color(Palette.BG, 0.8 * color.a), width + 2.0)
			ci.draw_line(a + dir * t, a + dir * minf(t + dash, length), color, width)
			t += dash + gap


## The drawing's frame this moment and its lean, a shear about the feet line (a Transform2D
## to draw it through): a 2% rise from
## the feet and a small lean, slow and out of phase between foes, enough to be seen as
## deliberate and not enough to animate a painted sprite. Planted (Ryan, 29 October): the rise
## scales from the drawing's feet and the lean shears about them, so the feet never slide or
## lift off the floor. Each foe at its own rate as well as its own phase, so neighbours drift
## apart instead of falling into step (Ryan, 23 September; and a touch less of it).
func breath_frame() -> Array:
	var sil := _silhouette()
	if not breathe or dead or sprite == null:
		return [sil, Transform2D.IDENTITY]
	var vis := _visible()
	var rate := 1.35 + 0.5 * Hud.noise(breathe_phase * 0.37 + 0.11)
	var k := 1.0 + 0.022 * sin(_t * rate + breathe_phase)
	var lean := 0.007 * sil.size.x * sin(_t * rate * 0.55 + breathe_phase * 0.7)
	var frame := Rect2(Vector2(sil.position.x, vis.end.y - (vis.end.y - sil.position.y) * k), Vector2(sil.size.x, sil.size.y * k))
	var shear := lean / maxf(1.0, vis.size.y)   # x moves by shear * (feet - y): the top by the lean, the feet not at all
	return [frame, Transform2D(Vector2(1.0, 0.0), Vector2(-shear, 1.0), Vector2(shear * vis.end.y, 0.0))]


## A shadow lying on the floor, centred on `foot`, flattened by the floor's perspective there.
func _draw_shadow(foot: Vector2, rx: float, alpha: float) -> void:
	var ry := maxf(2.5, rx * shadow_ratio)
	draw_set_transform(foot, 0.0, Vector2(1.0, ry / rx))
	draw_circle(Vector2.ZERO, rx, Color(0, 0, 0, alpha * 0.55))
	draw_circle(Vector2.ZERO, rx * 0.72, Color(0, 0, 0, alpha * 0.6))
	draw_set_transform_matrix(Transform2D.IDENTITY)


## A rect drawn in dashes (a preview chip's edge): structure, so it never
## rests on its hue. The dark edge under each dash fades with the colour.
func _draw_dashed(rect: Rect2, color: Color, width: float) -> void:
	dashed_rect(self, rect, color, width)


## A gauge on its own dark ground, with, when a pending value is given, a pulsing overlay on
## the part about to change. The overlay is ink white with a dark edge, never a hue: it has
## to read against any bar colour and for any kind of colour vision. Where it sits says
## which way the bar moves: inside the fill, that much is about to go; past the fill, that
## much is coming.
## A count toward a shot as cells across the gauges' width, in the stores' own shape and row (the
## Cassowary's sixth shot; pips from 21 October until Ryan, 10 November: "Cassowary's needs to
## match as well - just need a different kind of indication that the sixth is special"): a cell
## a shot, lit to the count, and the last, the one that counts double, apart from the rest by
## structure: under a heavier border, a diamond set in it, at its row's own height. When it is next
## the whole cell lights in the heat's colour and breathes, the diamond cut out of it.
func _draw_pips(rect: Rect2) -> void:
	var of := maxi(1, int(pips[1]))
	var count := int(pips[0]) % of
	var hud := Palette.HUD
	for k in range(of - 1):
		var cell := _cell_rect(k, of, rect)
		var pts := Hud.slant(cell, 4.0)
		Hud.fill_poly(self, Hud.slant(cell.grow(1.0), 4.0), Color(Palette.BG, 0.9))
		if k < count:
			Hud.fill_poly(self, Hud.slant(cell.grow(-2.0), 2.4) if cell.size.x >= 18.0 else pts, hud)
		Hud.stroke_poly(self, pts, Color(hud, 0.95), 1.5)
	var last := _cell_rect(of - 1, of, rect)   # its row's own height: taller, it touched the heat bar above (Ryan, 10 November)
	var next := count == of - 1
	var col: Color = Palette.HEAT if next else hud
	var lpts := Hud.slant(last, 4.0)
	Hud.fill_poly(self, Hud.slant(last.grow(1.0), 4.0), Color(Palette.BG, 0.92))
	if next:
		var beat := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * PENDING_RATE)
		Hud.fill_poly(self, lpts, Color(col, 0.7 + 0.3 * beat))
	Hud.stroke_poly(self, lpts, Color(col, 1.0), 2.5)
	var c := last.get_center()
	var r := minf(last.size.y * 0.5 - 2.0, last.size.x * 0.3)
	var gem := PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)])
	if next:
		draw_colored_polygon(gem, Color(Palette.BG, 0.95))
	else:
		draw_colored_polygon(gem, col)


## A capped store as one more bar under the heat, in the heat bar's own shape and place (Ryan, 10
## November: "Resource bars like the badgers should be the same shape as the other resource bars
## ... So the badger's should nestle under the Heat bar, same shape, divided into four clear
## segments"), and split into its units (the same day, of the first cut's thick ticks: "can we
## actually split them into different bars with borders and whitespace, in the same row? So a
## continuous bar but actually split into discrete segments"): one little bar a unit, each with
## its own border and dark ground and a gap of clear ground between, lit from the left to the
## count in the store's colour. So the count is how many are filled and the room left how many
## are outlines, by structure on any colour. Every resource that comes in whole units is drawn
## so (the hopper's loads, the rage, the Musk Ox's ammo); one that fills by degrees stays a
## meter (the Swallowtail's Muster: "that's a meter with non-discrete fills"). The last lit cell
## is where a stack's spend bursts (spend_chip).
const CELL_GAP := 1.0        # the ground between two cells: a hairline, the borders doing the parting (5, then 3; Ryan, 10 November: "still too spaced apart, need like 1 or two pixels only")
const CELL_GAP_MANY := 1.0   # the same in a row of more than six (the magazine's ten)

func _draw_store(rect: Rect2) -> void:
	_draw_cells(rect, int(store[0]), int(store[1]), store[2] if store.size() >= 3 else Palette.HUD)


## A row of whole units as cells across `rect`: `count` of `cap` lit, and with `after` given the
## change on its way pulsing as a gauge's does (the cells about to go breathing in ink, the ones
## about to come hatched in the row's colour).
func _draw_cells(rect: Rect2, count: int, cap: int, col: Color, after: int = -1) -> void:
	cap = maxi(1, cap)
	count = clampi(count, 0, cap)
	after = count if after < 0 else clampi(after, 0, cap)
	var clock := Time.get_ticks_msec() / 1000.0
	var beat := 0.5 + 0.5 * sin(clock * PENDING_RATE)
	for k in range(cap):
		var cell := _cell_rect(k, cap, rect)
		var pts := Hud.slant(cell, 4.0)
		Hud.fill_poly(self, Hud.slant(cell.grow(1.0), 4.0), Color(Palette.BG, 0.9))
		# A cell too narrow for a fill set in from its border is filled whole (the magazine's ten).
		var inner := Hud.slant(cell.grow(-2.0), 2.4) if cell.size.x >= 18.0 else pts
		if k < count:
			Hud.fill_poly(self, inner, col)
			if k >= after:
				# About to go: it breathes between dimmed and lit in ink, as a gauge's loss does.
				Hud.fill_poly(self, inner, Color(Palette.BG, 0.65 * (1.0 - beat)))
				Hud.fill_poly(self, inner, Color(Palette.INK, 0.55 * beat))
		elif k < after:
			# About to come: hatched in the row's colour, "coming", not "there".
			var x := cell.position.x + 2.0
			while x < cell.end.x - 2.0:
				draw_line(Vector2(x, cell.end.y - 2.0), Vector2(minf(x + cell.size.y - 4.0, cell.end.x - 2.0), cell.position.y + 2.0), Color(col, 0.5 + 0.3 * beat), 1.0)
				x += 4.0
		Hud.stroke_poly(self, pts, Color(col, 0.95), 1.5)   # every cell its own border, lit or not


## Cell `k` of `cap` across `row`, the gaps between them clear ground.
func _cell_rect(k: int, cap: int, row: Rect2) -> Rect2:
	var gap := CELL_GAP_MANY if cap > 6 else CELL_GAP
	var w := (row.size.x - gap * float(cap - 1)) / float(cap)
	return Rect2(row.position.x + (w + gap) * float(k), row.position.y, w, row.size.y)


## Cell `k` of a capped store's row, in `row` or where the gauges put the row.
func _store_cell(k: int, row: Rect2 = Rect2()) -> Rect2:
	if row.size == Vector2.ZERO:
		row = Rect2(size.x * 0.1, _bars_top() + bars.size() * BAR_STEP, size.x * 0.8, BAR_H)
	return _cell_rect(k, maxi(1, int(store[1])), row)


## A break point on a bar (a swallow's release, a golden rage's break: 22 November): a thick
## notch through the bar, past both its edges, on a dark ground, and a caret over it pointing down,
## so it reads by structure on any bar colour. Hot to start: it comes down once judged on a phone.
func _break_notch(rect: Rect2, at: float) -> void:
	var x := rect.position.x + rect.size.x * at
	var top := Vector2(x + 2.4, rect.position.y - 4.0)
	var foot := Vector2(x - 2.4, rect.end.y + 4.0)
	draw_line(top, foot, Color(Palette.BG, 0.95), 6.0)
	draw_line(top, foot, Color(Palette.INK, 1.0), 3.0)
	var tip := Vector2(x + 2.4, rect.position.y - 4.0)
	var caret := PackedVector2Array([tip, tip + Vector2(-5.0, -7.0), tip + Vector2(5.0, -7.0)])
	draw_colored_polygon(caret, Color(Palette.BG, 0.95))
	var inner := PackedVector2Array([tip + Vector2(0, -1.5), tip + Vector2(-3.0, -5.5), tip + Vector2(3.0, -5.5)])
	draw_colored_polygon(inner, Palette.INK)


func _gauge(rect: Rect2, b: Array) -> void:
	if b.size() >= 5 and int(b[4]) == 1:
		# A bar whose every unit is its own notch holds whole units (the Musk Ox's ammo): cells,
		# as a store's are, its change on its way pulsing on them.
		_draw_cells(rect, int(b[0]), int(b[1]), b[2], int(b[3]))
		return
	var mx := float(maxi(1, int(b[1])))
	var frac: float = clampf(float(b[0]) / mx, 0.0, 1.0)
	var col: Color = b[2]
	Hud.fill_poly(self, Hud.slant(rect.grow(1.0), 4.0), Color(Palette.BG, 0.9))
	Hud.gauge(self, rect, frac, col)
	# A broken shield (the reboot, 13 November; a sixth element, set): the bar's edge
	# broken into dashes in place of its line, so a shield that is broken reads apart from one
	# that is only empty by structure, not hue.
	if b.size() >= 6 and int(b[5]) != 0:
		var edge := Hud.slant(rect, 4.0)
		for e in range(edge.size()):
			var from: Vector2 = edge[e]
			var to: Vector2 = edge[(e + 1) % edge.size()]
			var run := from.distance_to(to)
			var along := (to - from) / maxf(run, 0.001)
			var at := 0.0
			while at < run:
				draw_line(from + along * at, from + along * minf(run, at + 6.0), Color(col, 0.95), 2.0)
				at += 10.0
	else:
		Hud.stroke_poly(self, Hud.slant(rect, 4.0), Color(col, 0.95), 1.0)   # a full-strength edge, so an empty bar still shows
	# A banked bar's charges (the Swallowtail's Muster, a fifth element the points a charge): a
	# notch at each charge across the bar, so its count reads by structure; every other bar
	# wears its scale, a tick a point (Hud.ticks), drawn over its pending change so it holds.
	if b.size() >= 5 and int(b[4]) > 0:
		var step := float(int(b[4])) / mx
		var at := step
		while at < 0.999:
			# The notch leans as the bar's ends lean, 4 across its height (Hud.slant; Ryan, 10
			# November: "Ticks on the swallowtail should be slanted").
			var x := rect.position.x + rect.size.x * at
			draw_line(Vector2(x + 2.4, rect.position.y - 1.0), Vector2(x - 2.4, rect.end.y + 1.0), Color(Palette.BG, 0.95), 3.0)
			at += step
	elif b.size() < 4 or int(b[3]) == int(b[0]):
		Hud.ticks(self, rect.grow(-2.0), int(b[0]), int(b[1]), col, 2.4)
	if b.size() >= 7 and int(b[6]) > 0:
		_break_notch(rect, clampf(float(b[6]) / mx, 0.0, 1.0))
	if b.size() < 4 or int(b[3]) == int(b[0]):
		return
	var pending: float = clampf(float(b[3]) / mx, 0.0, 1.0)
	var lo := minf(frac, pending)
	var hi := maxf(frac, pending)
	var inner := rect.grow(-2.0)
	# One clock for every gauge on screen (Ryan, 22 September: bars that breathe together
	# are easier to read), not this view's own, which starts when its first pending shows.
	var clock := Time.get_ticks_msec() / 1000.0
	var pulse := 0.72 + 0.22 * sin(clock * PENDING_RATE)
	var seg := Rect2(inner.position + Vector2(inner.size.x * lo, 0), Vector2(maxf(3.0, inner.size.x * (hi - lo)), inner.size.y))
	var pts := Hud.slant(seg, 2.4)
	if pending < frac:
		# A loss: the part about to go breathes between dimmed and lit in ink, a full swing,
		# so it is seen to pulse on any bar colour (Ryan, 22 September: it had faded to a
		# faint dimming).
		var beat := 0.5 + 0.5 * sin(clock * PENDING_RATE)
		Hud.fill_poly(self, pts, Color(Palette.BG, 0.65 * (1.0 - beat)))
		Hud.fill_poly(self, pts, Color(Palette.INK, 0.55 * beat))
		Hud.stroke_poly(self, pts, Color(Palette.INK, 0.6 + 0.4 * beat), 1.0)
	else:
		# A gain: hatched in the bar's own colour, so it reads as "coming", not "there".
		Hud.stroke_poly(self, pts, Color(col, pulse), 1.0)
		var x := seg.position.x + 3.0
		while x < seg.end.x:
			draw_line(Vector2(x, seg.end.y), Vector2(x + seg.size.y, seg.position.y), Color(col, pulse * 0.8), 1.0)
			x += 4.0
	if b.size() < 5 or int(b[4]) <= 0:
		Hud.ticks(self, rect.grow(-2.0), int(b[0]), int(b[1]), col, 2.4)
