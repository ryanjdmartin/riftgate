class_name EntryReadout
extends Control

## The die's hold (Ryan, 25 and 26 October): the entry showing, alone, its iconography as text
## ("it just turns the iconography into text, basically"). Its place on the die and its name,
## what holds on it now (a cooldown with its turns left, a foe's switch-off, corruption), its
## codex, then a line for each mark the die carries, in the order a spend runs it: its number as
## the die prints it, its target, how it lands, what the spend costs, what it leaves on each foe
## hit, Rapid's turn after, then its own rules and a written-out grant's (the star; "unique
## effects last"), then its tags. A number the live sources have moved off the component's own
## is coloured rather than its sources listed (Ryan, 26 October: listing them "reads to me like
## we're expecting the player to do math"; "just change the font colour and add the arrow"):
## green where the change is the player's gain, the enemy red where it is a loss (more heat, a
## smaller blow), its arrow attached to the number that moved, so a split weapon's smaller blow
## and its extra strike each say so ("Skua should have down on the damage and up on the count"),
## and it reads without the hue. What a keyword means is the keywords list's (the pause menu,
## and the button under the eye). No flavour yet.

## The content width at the readout's panel width (460, less the panel's margins).
const WIDTH := 432.0
const LEADING := 3.0      # between two lines of text
const BREATH := 9.0       # between the name block and the effects, and before the tags
const ARROW_GAP := 2.0    # between a moved number and its arrow

var lines: Array = []   # the readout as built, each {style, text, parts, place}: what tests read
var _words: Array = []  # the words as laid out, each {text, font, px, ink, at, arrow, w}


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## The quieter face's ink: halfway from the ink to the muted grey (the tags row).
static func hint_ink() -> Color:
	return Palette.INK.lerp(Palette.MUTED, 0.5)


## The readout's lines for `f`, the entry as its machine shows it now (Skirmish.shown_face), at
## `place` on its die (from one). `shown` is its blow as the die prints it ([low, high],
## Skirmish.shown_number: every modifier in; empty, the entry's own), `base` the component as
## built, whose numbers a highlight is read against, `states` what holds on it now, `grants`
## the written-out grants' lines (Effects.printed_grants).
static func lines_for(f: Face, place: int, shown: Array, base: Face, states: Array, grants: Array, db: ContentDB) -> Array:
	var out: Array = []
	if f == null:
		return out
	var comp: Dictionary = db.components.get(f.component, {}) if not f.component.is_empty() else {}
	var title := "EMPTY HARDPOINT" if f.empty else (db.component_name(f.component).to_upper() if not f.component.is_empty() else f.describe().to_upper())
	out.append({"style": "title", "text": title, "place": Hud.roman(place)})
	if not states.is_empty():
		out.append(_line("state", " · ".join(PackedStringArray(states))))
	var codex := str(comp.get("codex", ""))
	if not codex.is_empty():
		out.append(_line("codex", codex))
	out.append_array(effects_of(f, shown, base))
	for g in grants:
		out.append(_line("rule", str(g), "rule"))
	if not f.tags.is_empty():
		var names: Array[String] = []
		for t in f.tags:
			names.append(capital(t))
		out.append(_line("tags", "Tags: " + ", ".join(names)))
	return out


## What the entry does, a line each in the order a spend runs it: its number as the die prints
## it (`shown`), its target, how it lands, what the spend costs, what it leaves on each foe hit,
## Rapid's turn after, then its own rules (Face.rule_phrases). `base`, the component as built,
## is what each number is read against; null reads `f` as its own. Each line carries its group,
## for the codex's three lines: "attr" (its number, its target, its heat and ammo), "kw" (how it
## lands, Volatile, what it applies, Rapid) and "rule" (its own rules).
static func effects_of(f: Face, shown: Array = [], base: Face = null) -> Array:
	var out: Array = []
	if base == null:
		base = f
	if f.kind == Face.Kind.BLANK:
		# The title names what was there; the line says what the blank does.
		if f.empty:
			out.append(_line("effect", "Comes up blank: nothing fills it", "attr"))
		elif not f.disabled and not f.component.is_empty():
			out.append(_line("effect", "Destroyed: comes up blank for the rest of the battle", "attr"))
		else:
			out.append(_line("effect", capital(f.describe()), "attr"))
		return out
	# The strikes, read against the component's own: a split weapon's extra strike is the
	# player's gain beside its smaller blow (Ryan, 26 October).
	var strikes: Array = [_num("×%d" % f.strikes, f.strikes, base.strikes)] if f.strikes > 1 or base.strikes > 1 else []
	match f.kind:
		Face.Kind.ATTACK:
			if f.is_debuff():
				out.append(_parts("effect", [_word("Debuff")] + strikes, "attr"))
			else:
				var lo: int = int(shown[0]) if shown.size() == 2 else f.power
				var hi: int = int(shown[1]) if shown.size() == 2 else f.power_max
				# A strike's blow, its middle against the component's own: more is the gain.
				var blow := _word(str(lo) if lo == hi else "%d–%d" % [lo, hi])
				_trend(blow, lo + hi, base.power + base.power_max)
				out.append(_parts("effect", [_word("Attack"), blow] + strikes, "attr"))
			out.append(_line("effect", "Target: Enemy, %s" % capital(Face.REACH_NAMES[f.reach]), "attr"))
		Face.Kind.BUFF:
			if f.act_again:
				out.append(_line("effect", "An ally whose die is spent acts again", "attr"))
			else:
				var st: Dictionary = Effects.STATUS.get(f.buff_status, {})
				var line := [_word("Grants %s" % str(st.get("name", f.buff_status))), _num("×%d" % f.buff_stacks, f.buff_stacks, base.buff_stacks)]
				if f.buff_rounds > 1:
					line.append(_word("for %d rounds" % f.buff_rounds))
				out.append(_parts("effect", line, "attr"))
		Face.Kind.SHIELD:
			if f.fills_shield:
				out.append(_line("effect", "Shield to its maximum", "attr"))
			else:
				out.append(_parts("effect", [_word("Shield"), _num(str(f.power), f.power, base.power)], "attr"))
		Face.Kind.VENT:
			if f.power <= 0 and f.reloads_ammo > 0:
				out.append(_parts("effect", [_word("Reloads"), _num(str(f.reloads_ammo), f.reloads_ammo, base.reloads_ammo), _word("ammo")], "attr"))
			else:
				out.append(_parts("effect", [_word("Vent"), _num(str(f.power), f.power, base.power)], "attr"))
			if f.shields > 0:
				out.append(_parts("effect", [_word("Shield"), _num(str(f.shields), f.shields, base.shields)], "attr"))   # the combined entry's second half, after the vent
	if f.kind != Face.Kind.ATTACK:
		out.append(_line("effect", whom(f), "attr"))
	var land: Array = []   # how it lands
	var cost: Array = []   # what the spend costs past its heat
	var lays: Array = []   # what it leaves on each foe hit
	var after: Array = []  # Rapid's turn
	for k in f.keywords:
		if f.printed.has(k):
			continue   # a grant written out is its passive's line, with the rules
		var label := capital(Face.keyword_label(k))
		var gate := Effects.gate_text(f.gates[Face.KEYWORD_NAMES[k]]) if f.gates.has(Face.KEYWORD_NAMES[k]) else ""
		if Face.KEYWORD_STATUS.has(k):
			var line := [_word("Apply %s" % label)]
			var field: String = {Face.Keyword.BURN: "burn", Face.Keyword.CRYO: "cryo", Face.Keyword.FLAK: "flak"}.get(k, "")
			if not field.is_empty() and int(f.get(field)) > 0:
				line.append(_num(str(f.get(field)), int(f.get(field)), int(base.get(field))))
			line.append(_word(gate if not gate.is_empty() else "on hit"))
			lays.append(_parts("effect", line, "kw"))
		elif k == Face.Keyword.VOLATILE:
			cost.append(_parts("effect", [_word(label), _num(str(f.volatile), f.volatile, base.volatile, true)], "kw"))
		elif k == Face.Keyword.RAPID:
			after.append(_line("effect", label, "kw"))
		elif k in [Face.Keyword.LURE, Face.Keyword.DISRUPT, Face.Keyword.SWAP]:
			lays.append(_line("effect", label, "kw"))
		else:
			land.append(_line("effect", label, "kw"))
	out.append_array(land)
	if f.ammo > 0:
		# A forging machine's gun (the Musk Ox's): its price in ammo.
		var ammo := [_word("Ammo"), _num(str(f.ammo), f.ammo, base.ammo, true)]
		if f.dry:
			ammo.append(_word("(the magazine cannot pay it)"))
		out.append(_parts("effect", ammo, "attr"))
	if f.heat > 0 or base.heat > 0:
		out.append(_parts("effect", [_word("Heat"), _num(str(f.heat), f.heat, base.heat, true)], "attr"))
	out.append_array(cost)
	out.append_array(lays)
	out.append_array(after)
	for r in f.rule_phrases():
		out.append(_line("rule", capital(r), "rule"))
	return out


## The codex's row for a component (Ryan, 26 October: "each component row has a line for basic
## attributes, a line for keywords, and a line for unique component effects"): its name with its
## tags beside it, then the hold's lines joined by group, at the component's own numbers, and
## `rules` (its passive's lines) after its own. A line with nothing to say is left out.
static func codex_lines(f: Face, db: ContentDB, rules: Array = []) -> Array:
	var title := "EMPTY HARDPOINT" if f.empty else (db.component_name(f.component).to_upper() if not f.component.is_empty() else f.describe().to_upper())
	var tags: Array[String] = []
	for t in f.tags:
		tags.append(capital(t))
	var out: Array = [{"style": "name", "text": title, "tags": ", ".join(tags), "parts": [_word(title)], "place": ""}]
	var marks := effects_of(f)
	for r in rules:
		marks.append(_line("rule", str(r), "rule"))
	out.append_array(joined(marks))
	return out


## Lines of one group each, in the order attributes, keywords, rules, each a group's lines' parts
## run together with a dot between: the codex's way of saying what the hold says a line a mark.
static func joined(marks: Array) -> Array:
	var out: Array = []
	for g in ["attr", "kw", "rule"]:
		var parts: Array = []
		for l in marks:
			if str(l.get("group", "")) != g:
				continue
			if not parts.is_empty():
				parts.append(_word("·"))
			parts.append_array(l.get("parts", [_word(str(l.get("text", "")))]))
		if not parts.is_empty():
			out.append(_parts("row_" + g, parts, g))
	return out


## A foe's move, a line a mark in the die's order (Ryan, 26 October: a foe's intent "in the same
## format as the die hold press for a component"): its name, its blow and strikes (or what kind
## of move it is), whom it is aimed at, when it lands and on what condition, its riders, then its
## text. `live` reads the blow as it will land now (its kin, a rally), coloured against its own
## from the player's side (a harder blow is the player's loss), with `target` the machine it is
## aimed at; the codex reads it at its own numbers. Groups as effects_of's.
static func move_lines(f: Foe, a: Dictionary, db: ContentDB, live: bool = false, target: String = "") -> Array:
	var out: Array = []
	var name := str(a.get("name", "")).to_upper()
	out.append({"style": "title", "text": name, "parts": [_word(name)], "place": ""})
	var own := f.base_damage_of(a)
	var dmg := f.damage_of(a) if live else own
	var aim := f.aim_of(a)
	var aimed := "" if aim == Foe.AIM_ANYTHING else ", " + str(Foe.AIM_TEXT.get(aim, aim))
	if Foe.is_attack_action(a):
		var line := [_word("Attack"), _num(str(dmg), dmg, own, true) if live else _word(str(dmg))]
		var n := maxi(1, int(a.get("strikes", 1)))
		if n > 1:
			line.append(_word("×%d" % n))
		if int(a.get("swarm", 0)) > 0 and not live:
			line.append(_word("(+%d a kin standing)" % int(a["swarm"])))
		out.append(_parts("effect", line, "attr"))
		if Array(a.get("keywords", [])).has("all"):
			out.append(_line("effect", "Target: Every machine", "attr"))
		else:
			out.append(_line("effect", "Target: %s%s" % [target if live and not target.is_empty() else "Any machine", aimed], "attr"))
	else:
		var kind := capital(Foe.kind_of(a))
		var whom := str(MOVE_TARGETS.get(str(a.get("effect", "")), "Any machine"))
		if live and whom == "Any machine" and not target.is_empty():
			whom = target
		out.append(_line("effect", kind, "attr"))
		out.append(_line("effect", "Target: %s%s" % [whom, aimed if whom == "Any machine" or whom == target else ""], "attr"))
	if str(a.get("id", "")) == "last_act":
		out.append(_line("effect", "Lands the moment it falls", "attr"))   # its last act (15 October)
	var count := Foe.countdown_of(a)
	if count > 0:
		var left := f.charge if live and f.gathering() and f.pending.get("id", "") == a.get("id", "") else count
		out.append(_line("effect", "Lands next round" if left == 1 else "Lands in %d rounds" % left, "attr"))
	var whens := Foe.whens_of(a)
	if not whens.is_empty():
		var said: Array[String] = []
		for w in whens:
			said.append(str(Foe.WHEN_TEXT.get(str(w), str(w))))
		out.append(_line("effect", capital(" or ".join(said)), "attr"))
	for k in a.get("keywords", []):
		if str(k) == "all":
			continue   # its target says it
		var label := str(db.vocabulary.get(str(k), {}).get("name", str(k)))
		if Foe.NUMBERED_RIDERS.has(str(k)):
			label += " %d" % f.rider(a, str(k))
		out.append(_line("effect", label, "kw"))
	var text := str(a.get("text", "")).replace("{damage}", str(dmg)).replace("{value}", str(int(a.get("value", 0))))
	if not text.is_empty():
		out.append(_line("rule", text, "rule"))
	return out


## The codex's row for a foe's move: its name, then move_lines' groups joined, at its own numbers.
static func codex_move_lines(f: Foe, a: Dictionary, db: ContentDB) -> Array:
	var marks := move_lines(f, a, db)
	var head: Dictionary = marks.pop_front()
	head["style"] = "name"
	head["tags"] = ""
	return [head] + joined(marks)


## Whom a foe's move that is no blow acts on, by its effect (Foe.ACTION_EFFECTS); a debuff aimed at
## a machine is "Any machine", as a blow is.
const MOVE_TARGETS := {
	"brace": "Self", "regrow": "Self", "revive_once": "Self",
	"regrow_ally": "The most hurt of its own", "brace_all": "Every foe", "revive_once_ally": "One of its own",
	"summon": "The waiting pool", "rally": "Every other foe",
	"drain_rerolls": "The team's rerolls", "scorch_all": "Every machine", "corrupt_all": "Every machine",
}


## Whom a piece of equipment is spent on (Ryan's words, 26 October).
static func whom(f: Face) -> String:
	if f.reaches_all:
		return "Target: Every ally yet to act" if f.not_acted else "Target: Every ally"
	match f.targets:
		Face.Target.SELF:
			return "Target: Self"
		Face.Target.ALLY:
			return "Target: Any other ally"
	return "Target: Any ally or self"


static func capital(s: String) -> String:
	return s.substr(0, 1).to_upper() + s.substr(1)


## A line of one plain part.
static func _line(style: String, text: String, group: String = "") -> Dictionary:
	return _parts(style, [_word(text)], group)


## A line of parts, each {text, trend, gain, glue}: plain words, or a number a live source moved;
## a glued part sits against the one before it, no space between. Its `text` is the parts
## joined, for tests and the log.
static func _parts(style: String, parts: Array, group: String = "") -> Dictionary:
	var t := ""
	for p in parts:
		t += ("" if t.is_empty() or bool(p.get("glue", false)) else " ") + str(p["text"])
	return {"style": style, "text": t, "parts": parts, "place": "", "group": group}


static func _word(text: String) -> Dictionary:
	return {"text": text, "trend": 0, "gain": false}


## A number `now` read against the component's own `own`: moved, it carries the way it moved and
## whether that is the player's gain (more is, unless `less_is_gain`: heat, a hull price).
static func _num(text: String, now: int, own: int, less_is_gain: bool = false) -> Dictionary:
	var p := _word(text)
	_trend(p, now, own, less_is_gain)
	return p


static func _trend(p: Dictionary, now: int, own: int, less_is_gain: bool = false) -> void:
	p["trend"] = signi(now - own)
	p["gain"] = (now < own) if less_is_gain else (now > own)


## The ink of a moved number: green for the player's gain, the enemy red for a loss (Ryan, 26
## October: "If that means using green, this is the place for it"); unmoved, the text's own.
static func trend_ink(p: Dictionary, plain: Color = Palette.INK) -> Color:
	if int(p.get("trend", 0)) == 0:
		return plain
	return Palette.GAIN if bool(p.get("gain", false)) else Palette.ENEMY


## Fill the readout from `list` (lines_for) at `width`, its height the text's. Each line's parts
## flow as one paragraph, word by word, wrapping at the width: laid out here, now, so the panel
## opens at its size the first time.
func set_lines(list: Array, width: float = WIDTH) -> void:
	lines = list
	_words.clear()
	var y := 0.0
	for i in range(list.size()):
		var l: Dictionary = list[i]
		var style := str(l.get("style", "effect"))
		if i > 0:
			var before := str(list[i - 1].get("style", ""))
			if style in ["name", "caption"]:
				y += BREATH + 6.0   # a codex row or a section starts clear of the one before
			elif style == "tags" or (style in ["effect", "rule"] and before in ["title", "state", "codex"]):
				y += BREATH
			else:
				y += LEADING
		y = _flow(_spans(l), width, y)
	custom_minimum_size = Vector2(width, ceilf(y))
	size = custom_minimum_size
	queue_redraw()


## A line's spans, each {text, font, px, ink, pad (extra space before it), arrow}: a number a
## live source has moved is bold in its trend's ink with its arrow attached, the way it moved;
## a number nothing moved is plain.
static func _spans(l: Dictionary) -> Array:
	var text := str(l.get("text", ""))
	match str(l.get("style", "effect")):
		"title":
			return [_span(str(l.get("place", "")), Hud.quote(), 19, Palette.MUTED), _span(text, Hud.display_bold(), 21, Palette.INK, 6.0)]
		"state":
			return [_span(text, Hud.display_bold(), 18, Palette.INK)]
		"codex":
			return [_span(text, Hud.display(), 17, Palette.INK)]
		"tags":
			return [_span(text, Hud.quote(), 17, hint_ink())]
		"name":
			# A codex row's head: the name, its tags quiet beside it.
			var head := [_span(text, Hud.display_bold(), 18, Palette.INK)]
			if not str(l.get("tags", "")).is_empty():
				head.append(_span(str(l["tags"]), Hud.quote(), 16, hint_ink(), 8.0))
			return head
		"caption":
			return [_span(text, Hud.mono(), 12, Color(Palette.HUD, 0.75))]
	# The codex's joined rows a size down from the hold's lines. A moved number is bold in its
	# trend's ink with its arrow; a part may ask for bold or an ink of its own (a source's).
	var px := 17 if str(l.get("style", "")).begins_with("row_") or str(l.get("style", "")) == "named" else 18
	var out: Array = []
	for p in l.get("parts", [_word(text)]):
		var trend := int(p.get("trend", 0))
		var bold := trend != 0 or bool(p.get("bold", false))
		var sp := _span(str(p["text"]), Hud.display_bold() if bold else Hud.display(), px, trend_ink(p, p.get("ink", Palette.INK)))
		sp["arrow"] = trend
		sp["glue"] = bool(p.get("glue", false))
		out.append(sp)
	return out


static func _span(text: String, font: Font, px: int, ink: Color, pad: float = 0.0) -> Dictionary:
	return {"text": text, "font": font, "px": px, "ink": ink, "pad": pad, "arrow": 0, "glue": false}


## The width an arrow takes beside a number at `px`.
static func arrow_width(px: float) -> float:
	return ARROW_GAP + px * 0.66


## Lay the spans' words left to right from `y`, wrapping at `width`; returns the bottom. A moved
## number is one word with its arrow.
func _flow(spans: Array, width: float, y: float) -> float:
	var row: Array = []
	var x := 0.0
	for sp in spans:
		var font: Font = sp["font"]
		var px: int = sp["px"]
		var space := font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		var words: PackedStringArray = [str(sp["text"])] if int(sp["arrow"]) != 0 else str(sp["text"]).split(" ", false)
		var first := true
		for w in words:
			var ww := font.get_string_size(w, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
			if int(sp["arrow"]) != 0:
				ww += arrow_width(px)
			var lead := 0.0 if row.is_empty() or (first and bool(sp["glue"])) else space + (float(sp["pad"]) if first else 0.0)
			if not row.is_empty() and x + lead + ww > width:
				y = _commit(row, y) + LEADING
				row = []
				x = 0.0
				lead = 0.0
			row.append({"text": w, "font": font, "px": px, "ink": sp["ink"], "x": x + lead, "w": ww, "arrow": sp["arrow"]})
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
		ascent = maxf(ascent, (w["font"] as Font).get_ascent(w["px"]))
		descent = maxf(descent, (w["font"] as Font).get_descent(w["px"]))
	for w in row:
		w["at"] = Vector2(w["x"], y + ascent)
		w["top"] = y
		w["height"] = ascent + descent
		_words.append(w)
	return y + ascent + descent


func _draw() -> void:
	for w in _words:
		var at: Vector2 = w["at"]
		draw_string(w["font"], at, w["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, w["px"], w["ink"])
		if int(w["arrow"]) != 0:
			draw_arrow(self, Vector2(at.x + float(w["w"]) - arrow_width(float(w["px"])) + ARROW_GAP, at.y), float(w["px"]), int(w["arrow"]), w["ink"])


## A moved number's arrow, a filled triangle from `left` on the baseline `left.y`, up or down by
## `trend`, sized to the text's `px`: which way the number moved, so it reads without its hue.
static func draw_arrow(ci: CanvasItem, left: Vector2, px: float, trend: int, ink: Color) -> void:
	var s := px * 0.33
	var cx := left.x + s
	var cy := left.y - px * 0.36
	var tip := Vector2(cx, cy - s) if trend > 0 else Vector2(cx, cy + s)
	var foot := cy + s * 0.8 if trend > 0 else cy - s * 0.8
	ci.draw_colored_polygon(PackedVector2Array([tip, Vector2(cx - s, foot), Vector2(cx + s, foot)]), ink)


## A line as text: its parts, a moved number with its arrow attached ("1–2▼ ×2▲").
static func line_text(l: Dictionary) -> String:
	var out := ""
	for p in l.get("parts", [_word(str(l.get("text", "")))]):
		var t := str(p["text"])
		if int(p.get("trend", 0)) != 0:
			t += "▲" if int(p["trend"]) > 0 else "▼"
		out += ("" if out.is_empty() or bool(p.get("glue", false)) else " ") + t
	return out


## The readout's text as one string, a line each, for tests and the log.
func text() -> String:
	var out: Array[String] = []
	for l in lines:
		out.append((str(l.get("place", "")) + "  " if not str(l.get("place", "")).is_empty() else "") + line_text(l))
	return "\n".join(out)
