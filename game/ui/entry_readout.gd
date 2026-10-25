class_name EntryReadout
extends Control

## The die's hold (Ryan, 25 October: "only show the visible component"): the entry showing,
## alone, as a list. Its place on the die and its name, the states on it now, its codex, then
## one effect a line in the order a spend runs it (its number, its reach or whom it is spent
## on, how it lands, what the spend costs, what it leaves on each foe hit, Rapid's turn after),
## then its own rules and what applies to it now ("unique effects last"), then its tags. A
## keyword's line carries what the keyword does in the quotes' condensed italic, quieter, as
## the tags row does: a keyword that lays a status reads that status's own description, every
## other keyword and each reach its vocabulary hint. No flavour yet (Ryan: "Don't include
## flavour text for now"). The whole die is the codex's, a double-tap on the machine.

## The content width at the readout's panel width (460, less the panel's margins).
const WIDTH := 432.0
const LEADING := 3.0      # between two lines of text
const BREATH := 9.0       # between the name block and the effects, and before the tags

var lines: Array = []   # the readout as built, each {style, text, hint, place}: what tests read
var _words: Array = []  # the words as laid out: [text, font, px, ink, baseline position]


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## The quieter face's ink: halfway from the ink to the muted grey, so it reads clearly dimmer
## than the line it explains and still reads on a phone (lean hotter: never the grey itself).
static func hint_ink() -> Color:
	return Palette.INK.lerp(Palette.MUTED, 0.5)


## The readout's lines for `f`, the entry as its machine shows it now (Skirmish.shown_face),
## at `place` on its die (from one), its number as the die prints it (`number`,
## Skirmish.shown_number_text: every modifier in; empty, the entry's own). `states` are what
## holds on it now (FIXED, DARK and the rest), `notes` what changes it (Effects.explain_parts).
static func lines_for(f: Face, place: int, number: String, states: Array, notes: Array, db: ContentDB) -> Array:
	var out: Array = []
	if f == null:
		return out
	var comp: Dictionary = db.components.get(f.component, {}) if not f.component.is_empty() else {}
	var title := "EMPTY HARDPOINT" if f.empty else (db.component_name(f.component).to_upper() if not f.component.is_empty() else f.describe().to_upper())
	out.append({"style": "title", "text": title, "hint": "", "place": Hud.roman(place)})
	if not states.is_empty():
		out.append(_line("state", " // ".join(PackedStringArray(states))))
	var codex := str(comp.get("codex", ""))
	if not codex.is_empty():
		out.append(_line("codex", codex))
	out.append_array(effects_of(f, db, number))
	for n in notes:
		if bool(n.get("own", false)):
			out.append(_line("rule", str(n["source"]), str(n["text"])))   # the component's own passive: its name, then what it does
		else:
			out.append(_line("rule", capital(str(n["text"])), str(n["source"])))
	if not f.tags.is_empty():
		var names: Array[String] = []
		for t in f.tags:
			names.append(capital(t))
		out.append(_line("tags", "Tags: " + ", ".join(names)))
	return out


## What the entry does, a line each in the order a spend runs it: its number (`number`, as the
## die prints it), its reach or whom it is spent on, how it lands, what the spend costs, what it
## leaves on each foe hit, Rapid's turn after, then its own rules (Face.rule_phrases).
static func effects_of(f: Face, db: ContentDB, number: String = "") -> Array:
	var out: Array = []
	if f.kind == Face.Kind.BLANK:
		# The title names what was there; the line says what the blank does.
		if f.empty:
			out.append(_line("effect", "Comes up blank: nothing fills it"))
		elif not f.disabled and not f.component.is_empty():
			out.append(_line("effect", "Destroyed: comes up blank for the rest of the battle"))
		else:
			out.append(_line("effect", capital(f.describe())))
		return out
	match f.kind:
		Face.Kind.ATTACK:
			var strikes := " ×%d" % f.strikes if f.strikes > 1 else ""
			out.append(_line("effect", ("Debuff" if f.is_debuff() else "Attack " + (number if not number.is_empty() else f.number_text())) + strikes))
			var reach: String = Face.REACH_NAMES[f.reach]
			out.append(_line("effect", capital(reach), _hint(db, reach)))
		Face.Kind.BUFF:
			if f.act_again:
				out.append(_line("effect", "An ally whose die is spent acts again"))
			else:
				var st: Dictionary = Effects.STATUS.get(f.buff_status, {})
				var grant := "Grants %s ×%d" % [str(st.get("name", f.buff_status)), f.buff_stacks] + (" for %d rounds" % f.buff_rounds if f.buff_rounds > 1 else "")
				out.append(_line("effect", grant, status_hint(f.buff_status)))
		Face.Kind.SHIELD:
			out.append(_line("effect", "Shield to its maximum" if f.fills_shield else "Shield %d" % f.power))
		Face.Kind.VENT:
			out.append(_line("effect", ("Reloads %d ammo" % f.reloads_ammo) if f.power <= 0 and f.reloads_ammo > 0 else "Vent %d" % f.power))
			if f.shields > 0:
				out.append(_line("effect", "Shield %d" % f.shields))   # the combined entry's second half, after the vent
	if f.kind != Face.Kind.ATTACK:
		out.append(_line("effect", whom(f)))
	var land: Array = []   # how it lands
	var cost: Array = []   # what the spend costs past its heat
	var lays: Array = []   # what it leaves on each foe hit
	var after: Array = []  # Rapid's turn
	for k in f.keywords:
		if f.printed.has(k):
			continue   # a grant written out reads its passive's line, among the notes
		var label := capital(Face.keyword_label(k))
		var gate := Effects.gate_text(f.gates[Face.KEYWORD_NAMES[k]]) if f.gates.has(Face.KEYWORD_NAMES[k]) else ""
		if Face.KEYWORD_STATUS.has(k):
			var n: int = {Face.Keyword.BURN: f.burn, Face.Keyword.CRYO: f.cryo, Face.Keyword.FLAK: f.flak}.get(k, 0)
			lays.append(_line("effect", "Apply %s%s %s" % [label, " %d" % n if n > 0 else "", gate if not gate.is_empty() else "on hit"], status_hint(Face.KEYWORD_STATUS[k])))
		elif k == Face.Keyword.VOLATILE:
			cost.append(_line("effect", "%s %d" % [label, f.volatile], _hint(db, Face.KEYWORD_NAMES[k])))
		elif k == Face.Keyword.RAPID:
			after.append(_line("effect", label, _hint(db, Face.KEYWORD_NAMES[k])))
		elif k in [Face.Keyword.LURE, Face.Keyword.DISRUPT, Face.Keyword.SWAP]:
			lays.append(_line("effect", label, _hint(db, Face.KEYWORD_NAMES[k])))
		else:
			land.append(_line("effect", label, _hint(db, Face.KEYWORD_NAMES[k])))
	out.append_array(land)
	if f.ammo > 0:
		out.append(_line("effect", "Ammo %d" % f.ammo, "The magazine cannot pay it" if f.dry else ""))   # a forging machine's gun (the Musk Ox's)
	if f.heat > 0:
		out.append(_line("effect", "Heat %d" % f.heat))
	out.append_array(cost)
	out.append_array(lays)
	out.append_array(after)
	for r in f.rule_phrases():
		out.append(_line("rule", capital(r)))
	return out


## Whom a piece of equipment is spent on, as its line says it.
static func whom(f: Face) -> String:
	if f.reaches_all:
		return "Every ally yet to act" if f.not_acted else "Every ally"
	match f.targets:
		Face.Target.SELF:
			return "Self only"
		Face.Target.ALLY:
			return "Allies only"
	return "Self or an ally"


## A status's own description with its numbers filled, as the line beside what lays it reads it.
static func status_hint(status_id: String) -> String:
	var st: Dictionary = Effects.STATUS.get(status_id, {})
	return str(Effects.filled(str(st.get("description", "")), st.get("effects", []))).trim_suffix(".")


static func capital(s: String) -> String:
	return s.substr(0, 1).to_upper() + s.substr(1)


static func _hint(db: ContentDB, term: String) -> String:
	return str(db.vocabulary.get(term, {}).get("hint", ""))


static func _line(style: String, text: String, hint: String = "") -> Dictionary:
	return {"style": style, "text": text, "hint": hint, "place": ""}


## Fill the readout from `list` (lines_for) at `width`, its height the text's. Each line's spans
## (its text, then what explains it in the quieter face) flow as one paragraph, word by word,
## wrapping at the width: laid out here, now, so the panel opens at its size the first time.
func set_lines(list: Array, width: float = WIDTH) -> void:
	lines = list
	_words.clear()
	var y := 0.0
	for i in range(list.size()):
		var l: Dictionary = list[i]
		var style := str(l.get("style", "effect"))
		if i > 0:
			var before := str(list[i - 1].get("style", ""))
			y += BREATH if style == "tags" or (style in ["effect", "rule"] and before in ["title", "state", "codex"]) else LEADING
		y = _flow(_spans(l), width, y)
	custom_minimum_size = Vector2(width, ceilf(y))
	size = custom_minimum_size
	queue_redraw()


## A line's spans, each [text, font, size, ink, extra space before it].
static func _spans(l: Dictionary) -> Array:
	var text := str(l.get("text", ""))
	match str(l.get("style", "effect")):
		"title":
			return [[str(l.get("place", "")), Hud.quote(), 19, Palette.MUTED, 0.0], [text, Hud.display_bold(), 21, Palette.INK, 6.0]]
		"state":
			return [[text, Hud.mono(), 12, Palette.HUD, 0.0]]
		"codex":
			return [[text, Hud.display(), 17, Palette.INK, 0.0]]
		"tags":
			return [[text, Hud.quote(), 17, hint_ink(), 0.0]]
	var out: Array = [[text, Hud.display(), 18, Palette.INK, 0.0]]
	var hint := str(l.get("hint", ""))
	if not hint.is_empty():
		out.append(["(%s)" % hint, Hud.quote(), 17, hint_ink(), 0.0])
	return out


## Lay the spans' words left to right from `y`, wrapping at `width`; returns the bottom.
func _flow(spans: Array, width: float, y: float) -> float:
	var row: Array = []   # [text, font, px, ink, x]
	var x := 0.0
	for sp in spans:
		var font: Font = sp[1]
		var px: int = sp[2]
		var space := font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		var first := true
		for w in str(sp[0]).split(" ", false):
			var ww := font.get_string_size(w, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
			var lead := 0.0 if row.is_empty() else space + (float(sp[4]) if first else 0.0)
			if not row.is_empty() and x + lead + ww > width:
				y = _commit(row, y) + LEADING
				row = []
				x = 0.0
				lead = 0.0
			row.append([w, font, px, sp[3], x + lead])
			x += lead + ww
			first = false
	if not row.is_empty():
		y = _commit(row, y)
	return y


## One laid line: every word on the row's shared baseline, the tallest face's ascent below `y`.
func _commit(row: Array, y: float) -> float:
	var ascent := 0.0
	var descent := 0.0
	for w in row:
		ascent = maxf(ascent, (w[1] as Font).get_ascent(w[2]))
		descent = maxf(descent, (w[1] as Font).get_descent(w[2]))
	for w in row:
		_words.append([w[0], w[1], w[2], w[3], Vector2(w[4], y + ascent)])
	return y + ascent + descent


func _draw() -> void:
	for w in _words:
		draw_string(w[1], w[4], w[0], HORIZONTAL_ALIGNMENT_LEFT, -1, w[2], w[3])


## The readout's text as one string, a line each, for tests and the log.
func text() -> String:
	var out: Array[String] = []
	for l in lines:
		var t := (str(l.get("place", "")) + "  " if not str(l.get("place", "")).is_empty() else "") + str(l.get("text", ""))
		if not str(l.get("hint", "")).is_empty():
			t += " (%s)" % str(l["hint"])
		out.append(t)
	return "\n".join(out)
