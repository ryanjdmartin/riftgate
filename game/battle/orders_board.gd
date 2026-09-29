class_name OrdersBoard
extends Control

## The strip between the map and the log, while no readout is held. The readout keeps a
## strip of its own so that, held, it never covers a hex someone wants to tap (Ryan, 28
## September: an overlay on the map would make selecting under it annoying); empty, the
## strip read as a black gap on a tall phone, so it carries the orders board while it
## waits. One row a machine: its name, its order (HOLD, or the row it moves to and the
## hexes it spends), and what the plan says it meets, from the same dry run the map
## previews. At the right, the field: packs, the nearest to the gate, the rift's count.
## The display dresses it: a bytes readout ticking in the corner, and a line whose text
## changed settles from a scramble. Covered (drawn blank) while the readout is up.

var battle: Battle
var preview: Callable = Callable()   # -> Dictionary: the map's cached plan preview
var covered: Callable = Callable()   # -> bool: the readout panel is up
var playing: Callable = Callable()   # -> bool: the movement phase is playing

const ROW_H := 21.0
const SETTLE := 0.45   # seconds a changed line spends scrambled

var _t := 0.0
var _last: Dictionary = {}    # line key -> text last drawn, to see a change
var _changed: Dictionary = {} # line key -> when it changed


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	if battle == null or (covered.is_valid() and covered.call()):
		return
	var hud := Palette.HUD
	var mono := Hud.mono()
	var frame := int(_t * 18.0)
	# The frame: a rule down each side and brackets, the strip's own shape.
	Hud.brackets(self, Rect2(Vector2.ZERO, size), 12.0, Color(hud, 0.55), 1.0)
	# Header: the board's name at the left, the display's bytes at the right.
	var y := 15.0
	draw_string(mono, Vector2(10.0, y), _title(), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(hud, 0.7))
	draw_string(mono, Vector2(0.0, y), Hud.hex_bytes(4, frame, 3), HORIZONTAL_ALIGNMENT_RIGHT, size.x - 10.0, 11, Color(hud, 0.35))
	draw_line(Vector2(10.0, y + 6.0), Vector2(size.x - 10.0, y + 6.0), Color(hud, 0.22), 1.0)
	y += ROW_H + 4.0
	# The machines, one row each, in the team's order.
	var split := size.x * 0.62   # the field column starts here
	var rows := _rows()
	for i in range(rows.size()):
		var r: Array = rows[i]
		var key := "m%d" % i
		var name_x := 10.0
		var col: Color = r[3]
		_text(mono, Vector2(name_x, y), _settled(key + "n", str(r[0]), frame), 13, Color(hud, 0.95), 118.0)
		_text(mono, Vector2(name_x + 122.0, y), _settled(key + "o", str(r[1]), frame), 13, Color(col, 0.9), split - name_x - 130.0)
		if not str(r[2]).is_empty():
			var mx := name_x + 122.0 + mono.get_string_size(str(r[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x + 12.0
			_text(mono, Vector2(mx, y), _settled(key + "c", str(r[2]), frame), 13, Color(Palette.ENEMY, 0.9), split - mx - 8.0)
		y += ROW_H
	# The field, at the right.
	var fy := 15.0 + ROW_H + 4.0
	for j in range(_field_lines().size()):
		var line: String = _field_lines()[j]
		_text(mono, Vector2(split, fy), _settled("f%d" % j, line, frame), 12, Color(hud, 0.75), size.x - split - 10.0)
		fy += ROW_H


func _text(font: Font, at: Vector2, s: String, px: int, col: Color, width: float) -> void:
	draw_string(font, at, s, HORIZONTAL_ALIGNMENT_LEFT, maxf(20.0, width), px, col)


## A line's text, scrambled for a moment after it changed, so a number is seen to settle.
func _settled(key: String, text: String, frame: int) -> String:
	if _last.get(key, null) != text:
		_last[key] = text
		_changed[key] = _t
	if _t - float(_changed.get(key, -10.0)) < SETTLE:
		return Hud.scramble(text, frame, key.hash() % 97)
	return text


func _title() -> String:
	if playing.is_valid() and playing.call():
		return "RESOLVING // PHASE %02d" % (battle.field.phase + 1)
	match battle.state:
		Battle.State.PLAN:
			return "ORDERS // ROUND %02d" % (battle.field.phase + 1)
		Battle.State.SKIRMISH:
			return "CONTACT // %d PENDING" % battle.pending.size()
	return "BATTLE OVER"


## [name, order, meets, colour] per machine. The order reads HOLD when no route is
## plotted; otherwise the row the machine ends on and the hexes the route spends. Meets
## names the pack the plan has it fighting, from the preview's contact groups.
func _rows() -> Array:
	var out: Array = []
	var pv: Dictionary = preview.call() if preview.is_valid() and battle.state == Battle.State.PLAN else {}
	var groups: Array = []
	if pv.has("result") and pv["result"] != null:
		groups = pv["result"].skirmishes
	for m in battle.mechs():
		var route: Array = battle.routes.get(m.id, [])
		var order := "HOLD"
		var col := Color(Palette.HUD, 0.55)
		if not route.is_empty():
			order = "> ROW %s  %d HEX" % [_row_label(route[route.size() - 1]), route.size()]
			col = Palette.HUD
		var meets := ""
		for g in groups:
			if g.has(m):
				var names: Array[String] = []
				for u in g:
					if u.is_enemy():
						names.append("%s x%d" % [_short(u.display_name), u.strength])
				meets = "MEETS " + ", ".join(names)
				break
		out.append([m.display_name.to_upper(), order, meets, col])
	return out


## The field at a glance: packs on the field, the nearest to the gate by row, the rift.
func _field_lines() -> Array[String]:
	var f := battle.field
	var packs := f.packs()
	var nearest := -1
	var nearest_name := ""
	for p in packs:
		var row := _row_of(p.pos)
		if nearest < 0 or row < nearest:
			nearest = row
			nearest_name = _short(p.display_name)
	var lines: Array[String] = ["PACKS %02d" % packs.size()]
	if nearest >= 0:
		lines.append("NEAREST ROW %02d %s" % [nearest, nearest_name.to_upper()])
	lines.append("RIFT %d/%d" % [f.rift_pressure, f.rift_pressure_max])
	return lines


## The row's number as the map's frame shows it, counted up from the gate.
func _row_of(h: Vector2i) -> int:
	return battle.field.map.height - BattleMap.GATE_ROWS - Hex.axial_to_offset(h).y


func _row_label(h: Vector2i) -> String:
	return "%02d" % _row_of(h)


## "ghoul squad" -> "GHOUL": the pack's kind, the word that tells it apart.
func _short(name: String) -> String:
	var first := name.split(" ")[0]
	return first.to_upper()
