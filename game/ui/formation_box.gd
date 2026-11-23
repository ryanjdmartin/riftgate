class_name FormationBox
extends Control

## A pack's formation, the plate a double-tap on a pack opens on the map (Ryan, 23 November: "When
## double tapping a pack, it should show the formation. Double tapping a unit in the formation
## opens it's codex entry"): the pack's name and what it is, then its grid as the fight will deal it,
## the back rank over the front as the skirmish stands them, each foe its picture on a plate and an
## empty cell a dashed one. A double-tap on a foe asks for its codex (`foe_double_tapped`), which
## the screen opens over this. A shade over the whole screen, the panel over it; a tap outside or
## CLOSE shuts it. Its rank labels are the codex's words for a rank.

signal foe_double_tapped(foe_id: String)

const WIDTH := 640.0
const TOP := 220.0
const MARGIN := 24.0
const CELL := 128.0
const CELL_GAP := 12.0
const RANK_GAP := 26.0
const LABEL_H := 18.0

var _shade: ColorRect
var _panel: HudPanel
var _title: Label
var _sub: Label
var _grid: _Grid


## The grid: eight cells, the front rank's four then the back's (Unit.layout's order), drawn back
## over front; a double-tap on a foe's cell inside the die's window asks for its codex.
class _Grid extends Control:
	signal cell_double_tapped(i: int)
	var cells: Array = []   # eight foe ids or ""
	var _last_at := -10.0
	var _last_cell := -1

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		custom_minimum_size = Vector2(4.0 * CELL + 3.0 * CELL_GAP, 2.0 * (CELL + LABEL_H) + RANK_GAP)

	func cell_rect(i: int) -> Rect2:
		var back := i >= 4
		var col := i % 4
		var x := (size.x - (4.0 * CELL + 3.0 * CELL_GAP)) * 0.5 + col * (CELL + CELL_GAP)
		var y := LABEL_H if back else LABEL_H * 2.0 + CELL + RANK_GAP
		return Rect2(x, y, CELL, CELL)

	func _gui_input(event: InputEvent) -> void:
		if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
			return
		accept_event()
		var hit := -1
		for i in range(cells.size()):
			if cell_rect(i).has_point(event.position) and not str(cells[i]).is_empty():
				hit = i
		var now := Time.get_ticks_msec() / 1000.0
		if hit >= 0 and hit == _last_cell and now - _last_at <= DieFaceView.DOUBLE_TAP_SECONDS:
			_last_cell = -1
			cell_double_tapped.emit(hit)
		else:
			_last_cell = hit
			_last_at = now

	func _draw() -> void:
		var mono := Hud.mono()
		draw_string(mono, Vector2(cell_rect(4).position.x, LABEL_H - 4.0), "BACK", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(Palette.HUD, 0.8))
		draw_string(mono, Vector2(cell_rect(0).position.x, cell_rect(0).position.y - 4.0), "FRONT", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(Palette.HUD, 0.8))
		for i in range(8):
			var r := cell_rect(i)
			var fid := str(cells[i]) if i < cells.size() else ""
			if fid.is_empty():
				UnitView.dashed_rect(self, r.grow(-6.0), Color(Palette.HUD, 0.35), 2.0)
				continue
			Hud.box(self, r, 8.0, Color(Palette.PANEL_RAISED, 0.95), Color(Palette.ENEMY, 0.9), 2.0)
			var tex := Sprites.combat_foe(fid)
			if tex == null:
				continue
			var ts := tex.get_size()
			var k := maxf(1.0, floorf(minf((r.size.x - 12.0) / ts.x, (r.size.y - 12.0) / ts.y)))
			if ts.x * k > r.size.x - 12.0 or ts.y * k > r.size.y - 12.0:
				k = minf((r.size.x - 12.0) / ts.x, (r.size.y - 12.0) / ts.y)
			var sz := ts * k
			draw_texture_rect(tex, Rect2((r.get_center() - sz * 0.5).floor(), sz), false)


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_shade = ColorRect.new()
	_shade.color = Color(0, 0, 0, 0.6)
	_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_shade.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			close())
	add_child(_shade)
	_panel = HudPanel.new(MARGIN)
	_panel.custom_minimum_size = Vector2(WIDTH, 0)
	_panel.position = Vector2(40, TOP)
	add_child(_panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	_panel.add_child(col)
	_title = Hud.label("", 30, Palette.INK, Hud.display_bold())
	col.add_child(_title)
	_sub = Hud.label("", 13, Color(Palette.HUD, 0.8), Hud.mono())
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD
	_sub.custom_minimum_size = Vector2(WIDTH - 2.0 * MARGIN, 0)
	col.add_child(_sub)
	_grid = _Grid.new()
	_grid.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_grid.cell_double_tapped.connect(func(i: int) -> void: foe_double_tapped.emit(str(_grid.cells[i])))
	col.add_child(_grid)
	var close_btn := HudButton.new("CLOSE", close)
	close_btn.custom_minimum_size = Vector2(0, 52)
	col.add_child(close_btn)


## Show `cells` (eight foe ids or "", the front rank's four then the back's) under `title` and
## `subtitle`.
func open(title: String, subtitle: String, cells: Array) -> void:
	_title.text = title
	_sub.text = subtitle
	var eight: Array = cells.duplicate()
	eight.resize(8)
	for i in range(8):
		eight[i] = "" if eight[i] == null else str(eight[i])
	_grid.cells = eight
	_grid.queue_redraw()
	if not visible:
		Sound.play("codex_open")
	visible = true
	_panel.reset_size()
	_panel.size = Vector2(WIDTH, _panel.get_combined_minimum_size().y)


## A pack's eight cells: its dealt grid where it has one, else its members in order, the front rank
## filled first (a pack of no composition, a test's).
static func cells_of(u: Unit) -> Array:
	if not u.layout.is_empty():
		return u.layout.duplicate()
	var out: Array = []
	for m in u.member_list():
		for k in range(int(m[1])):
			if out.size() < 8:
				out.append(str(m[0]))
	return out


func close() -> void:
	if visible:
		Sound.play("codex_close")
	visible = false


func is_open() -> bool:
	return visible
