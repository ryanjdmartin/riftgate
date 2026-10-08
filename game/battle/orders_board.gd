class_name OrdersBoard
extends Control

## The strip between the map and the buttons, while no readout is held. The readout keeps a
## strip of its own so that, held, it never covers a hex someone wants to tap (Ryan, 28
## September: an overlay on the map would make selecting under it annoying); empty, the
## strip read as a black gap on a tall phone, so it carries the orders board while it
## waits. What a player wants at a glance (Ryan, 29 September): every machine's shield
## and hull, what it can still do this turn, and whether a hunter is after it; the enemy on
## the field as a count; what the enemy's turn will do to the gate. Not the rift's count
## (the top bar and the rift's own bar say it), not the nearest pack (the map is faster). The display dresses it: a bytes readout ticking in the corner, and a
## line whose text changed settles from a scramble. Covered (drawn blank) while the
## readout is up. The LOG button at its corner belongs to the screen and opens the full log.

var battle: Battle
var walks: Callable = Callable()     # -> Dictionary: every pack's walk on the enemy's turn (the map's)
var covered: Callable = Callable()   # -> bool: the readout panel is up
var playing: Callable = Callable()   # -> bool: the movement phase is playing

const ROW_H := 24.0
const SETTLE := 0.45   # seconds a changed line spends scrambled
const BAR_W := 54.0
const BAR_H := 6.0

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
	Hud.brackets(self, Rect2(Vector2.ZERO, size), 12.0, Color(hud, 0.55), 1.0)
	# Header: the board's name at the left, the display's bytes before the LOG button.
	var y := 17.0   # the header two down and a size up, at full strength (Ryan, 29 September: its top half read dimmed on the phone)
	draw_string(mono, Vector2(10.0, y), _title(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(hud, 0.9))
	draw_string(mono, Vector2(0.0, y), Hud.hex_bytes(4, frame, 3), HORIZONTAL_ALIGNMENT_RIGHT, size.x - 76.0, 12, Color(hud, 0.45))
	draw_line(Vector2(10.0, y + 6.0), Vector2(size.x - 10.0, y + 6.0), Color(hud, 0.22), 1.0)
	y += ROW_H
	# The machines, one row each, in the team's order: name, shield and hull, order, contact.
	var split := size.x * 0.64   # the field column starts here
	var rows := _rows()
	for i in range(rows.size()):
		var r: Dictionary = rows[i]
		var key := "m%d" % i
		var x := 10.0
		_text(mono, Vector2(x, y), _settled(key + "n", r["name"], frame), 13, Color(hud, 0.95), 118.0)
		x += 124.0
		var u: Unit = r["unit"]
		_bar(Rect2(x, y - 9.0, BAR_W, BAR_H), float(u.shield) / maxf(1.0, float(u.shield_max)), Palette.SHIELD)
		_bar(Rect2(x, y - 1.0, BAR_W, BAR_H), float(u.hull) / maxf(1.0, float(u.hull_max)), Palette.HULL)
		x += BAR_W + 12.0
		_text(mono, Vector2(x, y), _settled(key + "o", r["order"], frame), 13, r["colour"], 90.0)
		if not str(r["meets"]).is_empty():
			x += mono.get_string_size(r["order"], HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x + 12.0
			_text(mono, Vector2(x, y), _settled(key + "c", r["meets"], frame), 13, Color(Palette.ENEMY, 0.9), split - x - 8.0)
		y += ROW_H
	# The field, at the right.
	var fy := 15.0 + ROW_H + 2.0
	var lines := _field_lines()
	for j in range(lines.size()):
		var line: Array = lines[j]
		_text(mono, Vector2(split, fy), _settled("f%d" % j, line[0], frame), 12, line[1], size.x - split - 10.0)
		fy += ROW_H


func _text(font: Font, at: Vector2, s: String, px: int, col: Color, width: float) -> void:
	draw_string(font, at, s, HORIZONTAL_ALIGNMENT_LEFT, maxf(20.0, width), px, col)


## A thin gauge on a dark ground, the colour of what it measures.
func _bar(r: Rect2, frac: float, col: Color) -> void:
	draw_rect(r.grow(1.0), Color(Palette.BG, 0.9))
	draw_rect(r, Color(col, 0.25))
	draw_rect(Rect2(r.position, Vector2(r.size.x * clampf(frac, 0.0, 1.0), r.size.y)), col)


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
		return "MOVING // TURN %02d" % (battle.field.phase + 1)
	match battle.state:
		Battle.State.PLAN:
			return "ORDERS // TURN %02d" % (battle.field.phase + 1)
		Battle.State.SKIRMISH:
			return "FIGHT // TURN %02d" % (battle.field.phase + 1)
	return "BATTLE OVER"


## One entry per machine: its unit (for the gauges), what it can still do this turn (READY,
## MOVED, ONE MORE, SPENT, CAUGHT) and which hunter is after it.
func _rows() -> Array:
	var out: Array = []
	for m in battle.mechs():
		var order := "READY"
		var col := Palette.HUD
		if battle.is_pinned(m):
			order = "CAUGHT"
			col = Palette.ENEMY
		elif battle.actions_left(m) <= 0:
			order = "SPENT"
			col = Color(Palette.HUD, 0.45)
		elif battle.order_of(m) != null:
			order = "> " + _short(battle.order_of(m).display_name)
			col = Palette.HUD
		elif battle.action_from.has(m.id):
			order = "MOVED"
		elif battle.actions_left(m) < Battlefield.actions_for(m):
			order = "ONE MORE"
		var meets := ""
		for p in battle.field.packs():
			if p.behaviour == "hunt" and p.prey == m.id:
				meets = "HUNTED BY " + _short(p.display_name)
				break
		out.append({"unit": m, "name": m.display_name.to_upper(), "order": order, "meets": meets, "colour": col})
	return out


## The enemy on the field as a count, and what the enemy's turn will do to the gate.
func _field_lines() -> Array:
	var packs := battle.field.packs()
	var foes := 0
	for p in packs:
		foes += p.strength
	# The register is military (Ryan, 29 September): hostiles, not foes.
	var lines: Array = [["PACKS %02d // %d HOSTILES" % [packs.size(), foes], Color(Palette.HUD, 0.75)]]
	if battle.state == Battle.State.PLAN:
		if not battle.forced.is_empty():
			lines.append(["CAUGHT // %d FIGHT%s FIRST" % [battle.forced.size(), "" if battle.forced.size() == 1 else "S"], Color(Palette.ENEMY, 0.9)])
		elif not battle.orders.is_empty():
			lines.append(["ORDERS // ENGAGE WHEN READY", Color(Palette.HUD, 0.9)])
		var strikes := 0
		var w: Dictionary = walks.call() if walks.is_valid() else {}
		for k in w.keys():
			if (w[k] as Battlefield.Walk).strikes:
				strikes += 1
		if strikes > 0:
			lines.append(["GATE // %d STRIKE%s NEXT" % [strikes, "" if strikes == 1 else "S"], Color(Palette.ENEMY, 0.9)])
		else:
			lines.append(["GATE // CLEAR", Color(Palette.HUD, 0.5)])
	return lines


## A hex as the display names it: the column and the row, the row counted up from the gate
## as the map's frame counts it.
func _hex_label(h: Vector2i) -> String:
	var o := Hex.axial_to_offset(h)
	return "%02d.%02d" % [o.x + 1, battle.field.map.height - BattleMap.GATE_ROWS - o.y]


## "ghoul squad" -> "GHOUL": the pack's kind, the word that tells it apart.
func _short(name: String) -> String:
	return name.split(" ")[0].to_upper()
