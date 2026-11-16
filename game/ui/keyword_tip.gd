class_name KeywordTip
extends CanvasLayer

## What a term means, where the player reads it (Ryan, 30 October: "Tapping a keyword is exactly
## what we need"): a tap on a term in shown text (EntryReadout) opens its entry from the keywords
## list beside the word, over every screen and the pause menu: the list's heading, the term's icon
## and its name in its colour, then its line, whose own terms open theirs in its place. A name two
## terms share (Cryo, Brittle: a keyword and the status it leaves) shows both. A tap anywhere else, or
## back, closes it. One is open at a time.

const LAYER := 120         # over the screens and the pause menu
const WIDTH := 520.0
const MARGIN := 16.0       # off the screen's edges
const GAP := 8.0           # between the word and the tip
const PAD := 16.0          # the panel's content margin

static var _open: KeywordTip = null

var terms: Array = []      # the ids it shows: what tests read
var _catch: Control
var _panel: HudPanel
var _lines: EntryReadout


## Open the tip for `ids` beside `near` (the word's rect on the screen's canvas) over the
## viewport `from` is drawn in, or move the open one there. Off a tree (a test) it is built and
## read, never shown.
static func open(from: Node, ids: Array, near: Rect2) -> KeywordTip:
	var tip := current()
	if tip == null:
		tip = KeywordTip.new()
		if from != null and from.is_inside_tree():
			from.get_viewport().add_child(tip)   # the screen's own viewport: the window, or a capture's
		_open = tip
	tip._fill(ids, near)
	return tip


static func current() -> KeywordTip:
	return _open if _open != null and is_instance_valid(_open) else null


static func close_open() -> void:
	var tip := current()
	_open = null
	if tip == null:
		return
	if tip.is_inside_tree():
		tip._close()
	else:
		tip.free()   # off a tree (a test): nothing draws it, so it goes at once


func _init() -> void:
	layer = LAYER
	process_mode = Node.PROCESS_MODE_ALWAYS   # the pause menu's keywords page pauses the fight
	_catch = Control.new()
	_catch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_catch.mouse_filter = Control.MOUSE_FILTER_STOP   # the tap that closes it reaches nothing under it
	_catch.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and (e as InputEventMouseButton).pressed:
			_catch.accept_event()
			_close.call_deferred())
	add_child(_catch)
	_panel = HudPanel.new(PAD)
	_panel.fill_alpha = 1.0
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE   # a tap on its words, a term's aside, closes it
	add_child(_panel)
	_lines = EntryReadout.new()
	_panel.add_child(_lines)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close.call_deferred()


## Gone at once from the screen, freed after the frame: out of the input that closed it.
func _close() -> void:
	if _open == self:
		_open = null
	if is_inside_tree():
		get_parent().remove_child(self)
	queue_free()


## Each term's heading, its head and its line; then the panel sized to them and set beside the
## word, above it where there is room, else below.
func _fill(ids: Array, near: Rect2) -> void:
	terms = ids.duplicate()
	var db := ContentDB.load_default()
	var list: Array = []
	for id in ids:
		var e := Terms.entry(str(id), db)
		if not str(e["heading"]).is_empty():
			list.append({"style": "caption", "text": str(e["heading"]), "parts": [], "place": ""})
		list.append(EntryReadout.term_line(str(id)))
		list.append(EntryReadout.prose_line(str(e["codex"]), 17, Palette.INK))
	var screen := _screen()
	var width := minf(WIDTH, screen.size.x - MARGIN * 2.0)
	_lines.set_lines(list, width - PAD * 2.0)
	_panel.size = Vector2.ZERO
	_panel.reset_size()
	var size := _panel.get_combined_minimum_size()
	_panel.size = size
	var x := clampf(near.get_center().x - size.x * 0.5, screen.position.x + MARGIN, screen.end.x - size.x - MARGIN)
	var y := near.position.y - GAP - size.y
	if y < screen.position.y + MARGIN:
		y = near.end.y + GAP
	y = clampf(y, screen.position.y + MARGIN, maxf(screen.position.y + MARGIN, screen.end.y - size.y - MARGIN))
	_panel.position = Vector2(x, y)


func _screen() -> Rect2:
	return get_viewport().get_visible_rect() if is_inside_tree() else Rect2(0, 0, 720, 1280)


## The text it shows, a line each, for tests.
func text() -> String:
	return _lines.text()
