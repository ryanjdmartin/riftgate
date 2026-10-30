class_name CodexBox
extends Control

## The codex: the spec plate a double-tap opens for a unit, on any screen (Ryan, 22
## September: the map needs it as much as the skirmish). A shade over the whole screen, the
## panel over it; a tap outside closes it. Head-on portrait top-right, across from the
## name; mechs get the model itself turning slowly, in black ink only.
##
## Its layout (Ryan, 26 October): the numbers at the top, each the base with what the loadout
## and the battle make of it in a bracket beside it; the passive under them; then the active
## effects, what else the machine carries between fights (a module, a battle's reward); then
## the die, one column, each component a row: its tile, its name with its tags, and the
## hold's lines joined into three, its attributes, its keywords and its own rules, at the
## component's own numbers (a foe's moves the same way, with no tile); then its lore. A long
## plate scrolls under a CLOSE that stays in view.
##
## Entry keys (see `ContentDB.codex_for_unit` / `codex_for_foe`): title, designation,
## subtitle, body, stat_items, passive, passive_rows ([text, source] pairs, coloured by
## source), effects ({name, text, kind, note}), faces (Array of Face), face_rules (each face's
## component passive lines), current (index), steps (a die that steps: its chambers as a
## cylinder above them), moves and foe (a foe's moves), flavour, sprite_id (a chassis or foe
## id), paint and unit (the machine, so the model can wear its fitted loadout).

const WIDTH := 640.0
const TOP := 150.0
const BOTTOM := 40.0        # air under the panel at the screen's foot
var bottom := BOTTOM        # a host keeping a row clear under the panel raises it (the skirmish's KEYWORDS)
const MARGIN := 24.0        # the panel's content margin
const SCROLLBAR := 10.0     # the plate's scroll bar, beside its rows
const TEXT := WIDTH - MARGIN * 2.0 - SCROLLBAR - 6.0   # a line's width in the plate
const TILE := 86.0          # a component row's numeral and tile

var _shade: ColorRect
var _panel: HudPanel
var _scroll: ScrollContainer
var _title: Label
var _sub: Label
var _sprite: TextureRect
var _body: Label
var _designation: HudButton   # a stamped tag, not a label, so the plate does not read as three stacked lines
var _stats: StatBlock
var _view: MechView3D = null   # the spinning model, when mechs are 3D
var _passives: VBoxContainer   # the chassis's passive, in its source's colour
var _effects: EntryReadout     # the active effects: a module's, a reward's, a status the battle keeps
var _moves: EntryReadout       # a foe's moves, each a name and its lines
var _faces: VBoxContainer      # the die, a row a component: its tile and its lines
var _ring: CylinderView        # a die that steps (the Cassowary's): its order as a cylinder
var _flavour: Label


## The colour a passive's row takes from its source: the chassis's own in heat's colour, the
## accent it has always worn, anything
## granted (a component's, a module's, a reward's) in ink, its source named beside it. Never the
## HUD colour, which is decoration (Ryan, 26 October: "Actual gameplay text should be in a
## sensible colour").
static func passive_colour(kind: String) -> Color:
	match kind:
		"component", "module", "reward":
			return Palette.INK
	return Palette.HEAT


## A wrapping label needs a width before its first layout pass, or it reports the height
## of every word on its own line and the panel opens far too tall the first time.
static func _wrap(l: Label) -> void:
	l.autowrap_mode = TextServer.AUTOWRAP_WORD
	l.custom_minimum_size = Vector2(TEXT, 0)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT


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
	_panel.size = Vector2(WIDTH, 0)
	add_child(_panel)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 14)
	_panel.add_child(outer)
	# The plate scrolls; the button under it stays put.
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bar := _scroll.get_v_scroll_bar()
	bar.custom_minimum_size.x = SCROLLBAR
	var grab := StyleBoxFlat.new()
	grab.bg_color = Color(Palette.HUD, 0.55)
	for k in ["grabber", "grabber_highlight", "grabber_pressed"]:
		bar.add_theme_stylebox_override(k, grab)
	var track := StyleBoxFlat.new()
	track.bg_color = Color(Palette.HUD, 0.08)
	bar.add_theme_stylebox_override("scroll", track)
	outer.add_child(_scroll)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 10)
	cv.custom_minimum_size.x = TEXT
	cv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(cv)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	cv.add_child(top)
	var head := VBoxContainer.new()
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_theme_constant_override("separation", 4)
	top.add_child(head)
	# Name plate: the maker's designation as a stamped tag, the nickname big in quotes, then
	# maker, traits and die as the subtitle. Like a spec plate on the hull.
	_designation = HudButton.new("")
	_designation.filled = true
	_designation.mono = true
	_designation.font_size = 12
	_designation.slant_px = 8.0
	_designation.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_designation.custom_minimum_size = Vector2(0, 24)
	_designation.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_title = Hud.label("", 34, Palette.INK, Hud.display_bold())
	_sub = Hud.label("", 13, Color(Palette.HUD, 0.8), Hud.mono())
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD
	_sub.custom_minimum_size = Vector2(330, 0)
	_sub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_designation)
	head.add_child(_title)
	head.add_child(_sub)
	_sprite = TextureRect.new()
	_sprite.custom_minimum_size = Vector2(200, 240)    # the corner portrait, top-right
	_sprite.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(_sprite)
	# The play half: the stat grid beside the portrait; the passive, the active effects and the
	# die full width under both. A thin rule separates play from lore: codex text, then quote.
	_stats = StatBlock.new()
	_stats.custom_minimum_size = Vector2(330, 0)
	_stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	head.add_child(spacer)
	head.add_child(_stats)
	_passives = VBoxContainer.new()
	_passives.add_theme_constant_override("separation", 3)
	_passives.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_passives.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv.add_child(_passives)
	_effects = EntryReadout.new()
	cv.add_child(_effects)
	_moves = EntryReadout.new()
	cv.add_child(_moves)
	_ring = CylinderView.new()
	_ring.visible = false
	_ring.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cv.add_child(_ring)
	_faces = VBoxContainer.new()
	_faces.add_theme_constant_override("separation", 12)
	_faces.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv.add_child(_faces)
	var rule := ColorRect.new()
	rule.color = Color(Palette.HUD, 0.25)
	rule.custom_minimum_size = Vector2(0, 1)
	cv.add_child(rule)
	_body = Hud.label("", 19, Palette.INK)
	_flavour = Hud.label("", 18, Palette.MUTED, Hud.quote())
	for l in [_body, _flavour]:
		_wrap(l)
		cv.add_child(l)
	var close_btn := HudButton.new("CLOSE", close)
	close_btn.sound = ""   # the codex closing is its own figure
	close_btn.custom_minimum_size = Vector2(0, 52)
	outer.add_child(close_btn)


## Fill and show the codex.
func open(entry: Dictionary) -> void:
	var designation := str(entry.get("designation", "")).to_upper()
	# A mech with a designation gets its nickname in quotes; a foe or a die keeps its name plain.
	_title.text = ("“%s”" % str(entry.get("title", ""))) if not designation.is_empty() else str(entry.get("title", ""))
	_sub.text = str(entry.get("subtitle", ""))
	_designation.text = designation
	_designation.custom_minimum_size.x = Hud.mono().get_string_size(designation, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 30.0
	_designation.visible = not designation.is_empty()
	_designation.queue_redraw()
	var sid := str(entry.get("sprite_id", ""))
	var tex: Texture2D = null
	if _view != null:
		_view.queue_free()
		_view = null
	var look := MechView3D.look_setting()
	if not sid.is_empty() and not look.is_empty() and MechView3D.has_model(sid):
		# Mechs in 3D: the codex gets the model itself, turning slowly.
		var db := ContentDB.load_default()
		var maker := db.maker_of(sid)
		var paint: Dictionary = entry.get("paint", {})
		var plan: Array = MechView3D.plan_for(entry.get("unit", null), db)   # the fitted loadout, where it differs from stock
		_view = MechView3D.make(sid, maker, "clean", "", MechView3D.YAW_FRONT, Vector2i(200, 240), true, paint, plan)
		add_child(_view)
		tex = _view.texture
	elif not sid.is_empty():
		tex = Sprites.combat_foe(sid)
	_sprite.texture = tex
	_sprite.visible = tex != null
	_stats.set_items(entry.get("stat_items", []))
	_body.text = str(entry.get("body", ""))
	_body.visible = not _body.text.is_empty()
	# The passive, in its source's colour (Ryan's to-do: granted passives coloured): the
	# chassis's own in the accent.
	for c in _passives.get_children():
		_passives.remove_child(c)   # out of the tree now, so the rows below are the only children
		c.queue_free()
	var rows: Array = entry.get("passive_rows", [])
	if rows.is_empty() and not str(entry.get("passive", "")).is_empty():
		rows = [[str(entry.get("passive", "")), "chassis"]]
	for row in rows:
		var l := Hud.label(str(row[0]), 17, passive_colour(str(row[1])))
		_wrap(l)
		_passives.add_child(l)
	_passives.visible = not rows.is_empty()
	# The active effects, each its name in its source's colour, then what it does.
	var effects: Array = entry.get("effects", [])
	_effects.visible = not effects.is_empty()
	if not effects.is_empty():
		_effects.set_lines(effect_lines(effects), TEXT)
	# A foe's moves, each a codex row: its name, then its attributes, riders and text.
	var db := ContentDB.load_default()
	var moves: Array = entry.get("moves", [])
	var foe: Foe = entry.get("foe", null)
	_moves.visible = not moves.is_empty() and foe != null
	if _moves.visible:
		var lines: Array = []
		for a in moves:
			lines.append_array(EntryReadout.codex_move_lines(foe, a, db))
		_moves.set_lines(lines, TEXT)
	# The die, a row a component: its tile at its place, its lines beside it.
	for c in _faces.get_children():
		_faces.remove_child(c)
		c.queue_free()
	var faces: Array = entry.get("faces", [])
	var rules: Array = entry.get("face_rules", [])
	var current := int(entry.get("current", -1))
	for i in range(faces.size()):
		_faces.add_child(_face_row(faces[i], i, i == current, rules[i] if i < rules.size() else [], db))
	_faces.visible = not faces.is_empty()
	# A die that steps prints its order (the Cassowary's): its chambers round a cylinder, every gap
	# a faint arrow, the way the die turns.
	_ring.visible = bool(entry.get("steps", false)) and not faces.is_empty()
	if _ring.visible:
		_ring.set_cylinder(faces, current, -1)
	var quote := str(entry.get("flavour", ""))
	_flavour.text = "“%s”" % quote if not quote.is_empty() else ""
	_flavour.visible = not quote.is_empty()
	_scroll.scroll_vertical = 0
	if not visible:
		Sound.play("codex_open")
		Sound.say("codex")   # rarely: she looks it up
	visible = true
	_fit()
	# Wrapping labels report their true height only after a layout pass at the panel's
	# width, so the first open used to come out the wrong size. Fit again once that has run.
	_fit.call_deferred()


## The active effects as readout lines: a caption, then each its name and where it comes from in
## its source's colour, then what it does.
static func effect_lines(effects: Array) -> Array:
	var out: Array = [{"style": "caption", "text": "ACTIVE EFFECTS", "parts": [], "place": ""}]
	for e in effects:
		var head := "%s (%s):" % [str(e.get("name", "")), str(e.get("note", ""))] if not str(e.get("note", "")).is_empty() else "%s:" % str(e.get("name", ""))
		var parts: Array = [{"text": head, "trend": 0, "gain": false, "bold": true, "ink": passive_colour(str(e.get("kind", "")))}, {"text": str(e.get("text", "")), "trend": 0, "gain": false}]
		out.append({"style": "named", "text": head + " " + str(e.get("text", "")), "parts": parts, "place": ""})
	return out


## One component's row: its numeral and tile, bracketed when it is the entry showing, then its
## name and its lines at its own numbers (EntryReadout.codex_lines).
func _face_row(f: Face, i: int, showing: bool, rules: Array, db: ContentDB) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tile := FaceListView.new()
	tile.tiles_only = true
	tile.first_place = i + 1
	tile.set_faces([f], 0 if showing else -1)
	tile.custom_minimum_size = Vector2(TILE, FaceListView.ROW)
	tile.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(tile)
	var lines := EntryReadout.new()
	lines.set_lines(EntryReadout.codex_lines(f, db, rules), TEXT - TILE - 6.0)
	lines.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(lines)
	return row


func _fit() -> void:
	# The plate as tall as its contents, up to what the screen leaves under the panel's top; past
	# that it scrolls.
	var screen := size.y if size.y > 0.0 else (get_viewport_rect().size.y if is_inside_tree() else 1280.0)
	var room := screen - TOP - bottom - MARGIN * 2.0 - 52.0 - 14.0
	var content := _scroll.get_child(0) as Control
	var wanted := content.get_combined_minimum_size().y if content != null else 0.0
	_scroll.custom_minimum_size = Vector2(0, minf(wanted, maxf(200.0, room)))
	_panel.reset_size()
	_panel.size = Vector2(WIDTH, _panel.get_combined_minimum_size().y)


func close() -> void:
	if visible:
		Sound.play("codex_close")
	visible = false
	if _view != null:
		_view.queue_free()
		_view = null


func is_open() -> bool:
	return visible
