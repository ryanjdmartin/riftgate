class_name CodexBox
extends Control

## The codex: the spec plate a double-tap opens for a unit, on any screen (Ryan, 22
## September: the map needs it as much as the skirmish). A shade over the whole screen, the
## panel over it; a tap outside closes it. Head-on portrait top-right, across from the
## name; mechs get the model itself turning slowly, in black ink only.
##
## Entry keys (see `ContentDB.codex_for_unit` / `codex_for_foe`): title, designation,
## subtitle, body, stat_items, actions, passive, faces (Array of Face), face_columns,
## face_labels, current (index), modifiers, flavour, sprite_id (a chassis or foe id), paint,
## passive_rows ([text, source] pairs, coloured by source) and unit (the machine, so the
## model can wear its fitted loadout).

const WIDTH := 640.0
const TOP := 150.0

var _shade: ColorRect
var _panel: HudPanel
var _title: Label
var _sub: Label
var _sprite: TextureRect
var _body: Label
var _designation: HudButton   # a stamped tag, not a label, so the plate does not read as three stacked lines
var _stats: StatBlock
var _view: MechView3D = null   # the spinning model, when mechs are 3D
var _actions: Label
var _passives: VBoxContainer   # one label a passive, coloured by its source: the chassis's own, a component's, a reward
var _faces: FaceListView
var _modifiers: Label            # every live effect on the mech, on the die screen
var _flavour: Label


## The colour a passive's row takes from its source.
static func passive_colour(kind: String) -> Color:
	match kind:
		"component", "module":
			return Palette.HUD
		"reward":
			return Palette.INK
	return Palette.ACCENT


## A wrapping label needs a width before its first layout pass, or it reports the height
## of every word on its own line and the panel opens far too tall the first time.
static func _wrap(l: Label) -> void:
	l.autowrap_mode = TextServer.AUTOWRAP_WORD
	l.custom_minimum_size = Vector2(560, 0)
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
	_panel = HudPanel.new(24.0)
	_panel.custom_minimum_size = Vector2(WIDTH, 0)
	_panel.position = Vector2(40, TOP)
	_panel.size = Vector2(WIDTH, 0)
	add_child(_panel)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 10)
	_panel.add_child(cv)
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
	_sub.custom_minimum_size = Vector2(340, 0)
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
	# The play half: the stat grid sits beside the portrait; the passive and any actions run
	# full width under both, so they need not wrap around the picture; the faces run in two
	# columns under that. A thin rule separates play from lore: codex text, then quote.
	_stats = StatBlock.new()
	_stats.custom_minimum_size = Vector2(340, 0)
	_stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_passives = VBoxContainer.new()
	_passives.add_theme_constant_override("separation", 3)
	_passives.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_passives.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_actions = Hud.label("", 14, Palette.INK, Hud.mono())
	_body = Hud.label("", 19, Palette.INK)
	_faces = FaceListView.new()
	_faces.columns = 2
	_modifiers = Hud.label("", 14, Palette.INK, Hud.mono())
	_flavour = Hud.label("", 18, Palette.MUTED, Hud.quote())
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	head.add_child(spacer)
	head.add_child(_stats)
	for l in [_actions, _modifiers]:
		_wrap(l)
	cv.add_child(_passives)
	cv.add_child(_actions)
	cv.add_child(_faces)
	cv.add_child(_modifiers)
	var rule := ColorRect.new()
	rule.color = Color(Palette.HUD, 0.25)
	rule.custom_minimum_size = Vector2(0, 1)
	cv.add_child(rule)
	for l in [_body, _flavour]:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		l.custom_minimum_size = Vector2(560, 0)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		cv.add_child(l)
	var gap := Control.new()   # air between the quote and the button
	gap.custom_minimum_size = Vector2(0, 8)
	cv.add_child(gap)
	var close_btn := HudButton.new("CLOSE", close)
	close_btn.custom_minimum_size = Vector2(0, 52)
	cv.add_child(close_btn)


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
		var maker := str(db.chassis.get(sid, {}).get("maker", "minerva"))
		var paint: Dictionary = entry.get("paint", {})
		var plan: Array = MechView3D.plan_for(entry.get("unit", null), db)   # the fitted loadout, where it differs from stock
		_view = MechView3D.make(sid, maker, "clean", "badger", MechView3D.YAW_FRONT, Vector2i(200, 240), true, paint, plan)
		add_child(_view)
		tex = _view.texture
	elif not sid.is_empty():
		tex = Sprites.combat_foe(sid)
	_sprite.texture = tex
	_sprite.visible = tex != null
	_stats.set_items(entry.get("stat_items", []))
	for pair in [[_body, "body"], [_actions, "actions"]]:
		var l: Label = pair[0]
		l.text = str(entry.get(pair[1], ""))
		l.visible = not l.text.is_empty()
	# The passives, one row each in its source's colour (Ryan's to-do: granted passives
	# coloured): the chassis's own in the accent, a component's in the overlay colour, a
	# battle reward in ink. A foe's entry carries one block of text and no rows.
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
	var faces: Array = entry.get("faces", [])
	_faces.visible = not faces.is_empty()
	_faces.columns = int(entry.get("face_columns", 2))
	_faces.labels = entry.get("face_labels", [])
	if not faces.is_empty():
		_faces.set_faces(faces, int(entry.get("current", -1)))
	_modifiers.text = str(entry.get("modifiers", ""))
	_modifiers.visible = not _modifiers.text.is_empty()
	var quote := str(entry.get("flavour", ""))
	_flavour.text = "“%s”" % quote if not quote.is_empty() else ""
	_flavour.visible = not quote.is_empty()
	if not visible:
		Sound.play("codex_open")
	visible = true
	_fit()
	# Wrapping labels report their true height only after a layout pass at the panel's
	# width, so the first open used to come out the wrong size. Fit again once that has run.
	_fit.call_deferred()


func _fit() -> void:
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
