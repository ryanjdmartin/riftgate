class_name EntryReadout
extends Control

## The die's hold (Ryan, 25 and 26 October): the entry showing, alone, its iconography as text
## ("it just turns the iconography into text, basically"). Its place on the die and its name,
## what holds on it now (a cooldown with its turns left, a foe's switch-off, corruption), its
## codex, then a line for each mark the die carries, in the order a spend runs it: its number as
## the die prints it, its target, how it lands, what the spend costs, what it leaves on each foe
## hit, Rapid's turn after, then its own rules and a written-out grant's (the star; "unique
## effects last"), then its tags. A number the live sources have moved off the component's own
## is highlighted rather than its sources listed (Ryan, 26 October: listing them "reads to me
## like we're expecting the player to do math"): a chip, white where the change is the player's
## gain and the enemy red where it is a loss (more heat, less damage), with an arrow for which
## way it moved, so it reads without the hue. What a keyword means is the keywords list's (the
## pause menu, and the button under the eye). No flavour yet.

## The content width at the readout's panel width (460, less the panel's margins).
const WIDTH := 432.0
const LEADING := 3.0      # between two lines of text
const BREATH := 9.0       # between the name block and the effects, and before the tags
const CHIP_PAD := 5.0     # a highlighted number's chip, each side of its text
const NBSP := "\u00a0"    # keeps a highlighted number one word ("1–2 ×4")

var lines: Array = []   # the readout as built, each {style, text, value, trend, gain, place}: what tests read
var _words: Array = []  # the words as laid out, each {text, font, px, ink, at, chip, arrow, w}


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
		out.append(_line("rule", str(g)))
	if not f.tags.is_empty():
		var names: Array[String] = []
		for t in f.tags:
			names.append(capital(t))
		out.append(_line("tags", "Tags: " + ", ".join(names)))
	return out


## What the entry does, a line each in the order a spend runs it: its number as the die prints
## it (`shown`), its target, how it lands, what the spend costs, what it leaves on each foe hit,
## Rapid's turn after, then its own rules (Face.rule_phrases). `base`, the component as built,
## is what a moved number and heat are read against; null reads `f` as its own.
static func effects_of(f: Face, shown: Array = [], base: Face = null) -> Array:
	var out: Array = []
	if base == null:
		base = f
	if f.kind == Face.Kind.BLANK:
		# The title names what was there; the line says what the blank does.
		if f.empty:
			out.append(_line("effect", "Comes up blank: nothing fills it"))
		elif not f.disabled and not f.component.is_empty():
			out.append(_line("effect", "Destroyed: comes up blank for the rest of the battle"))
		else:
			out.append(_line("effect", capital(f.describe())))
		return out
	var strikes := (NBSP + "×%d" % f.strikes) if f.strikes > 1 else ""
	match f.kind:
		Face.Kind.ATTACK:
			if f.is_debuff():
				out.append(_line("effect", "Debuff" + strikes.replace(NBSP, " ")))
			else:
				var lo: int = int(shown[0]) if shown.size() == 2 else f.power
				var hi: int = int(shown[1]) if shown.size() == 2 else f.power_max
				var line := _line("effect", "Attack")
				line["value"] = (str(lo) if lo == hi else "%d–%d" % [lo, hi]) + strikes
				# The blow's worth over the spend, its strikes counted, against the component's own:
				# more is the player's gain.
				var now := (lo + hi) * 0.5 * maxi(1, f.strikes)
				var own := (base.power + base.power_max) * 0.5 * maxi(1, base.strikes)
				line["trend"] = _sign(now - own)
				line["gain"] = now > own
				out.append(line)
			out.append(_line("effect", "Target: Enemy, %s" % capital(Face.REACH_NAMES[f.reach])))
		Face.Kind.BUFF:
			if f.act_again:
				out.append(_line("effect", "An ally whose die is spent acts again"))
			else:
				var st: Dictionary = Effects.STATUS.get(f.buff_status, {})
				out.append(_line("effect", "Grants %s ×%d" % [str(st.get("name", f.buff_status)), f.buff_stacks] + (" for %d rounds" % f.buff_rounds if f.buff_rounds > 1 else "")))
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
			continue   # a grant written out is its passive's line, with the rules
		var label := capital(Face.keyword_label(k))
		var gate := Effects.gate_text(f.gates[Face.KEYWORD_NAMES[k]]) if f.gates.has(Face.KEYWORD_NAMES[k]) else ""
		if Face.KEYWORD_STATUS.has(k):
			var n: int = {Face.Keyword.BURN: f.burn, Face.Keyword.CRYO: f.cryo, Face.Keyword.FLAK: f.flak}.get(k, 0)
			lays.append(_line("effect", "Apply %s%s %s" % [label, " %d" % n if n > 0 else "", gate if not gate.is_empty() else "on hit"]))
		elif k == Face.Keyword.VOLATILE:
			cost.append(_line("effect", "%s %d" % [label, f.volatile]))
		elif k == Face.Keyword.RAPID:
			after.append(_line("effect", label))
		elif k in [Face.Keyword.LURE, Face.Keyword.DISRUPT, Face.Keyword.SWAP]:
			lays.append(_line("effect", label))
		else:
			land.append(_line("effect", label))
	out.append_array(land)
	if f.ammo > 0:
		out.append(_line("effect", "Ammo %d" % f.ammo + (", the magazine cannot pay it" if f.dry else "")))   # a forging machine's gun (the Musk Ox's)
	if f.heat > 0:
		var heat := _line("effect", "Heat")
		heat["value"] = str(f.heat)
		heat["trend"] = _sign(f.heat - base.heat)
		heat["gain"] = f.heat < base.heat
		out.append(heat)
	out.append_array(cost)
	out.append_array(lays)
	out.append_array(after)
	for r in f.rule_phrases():
		out.append(_line("rule", capital(r)))
	return out


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


static func _sign(d: float) -> int:
	return 1 if d > 0.001 else (-1 if d < -0.001 else 0)


static func _line(style: String, text: String) -> Dictionary:
	return {"style": style, "text": text, "value": "", "trend": 0, "gain": false, "place": ""}


## Fill the readout from `list` (lines_for) at `width`, its height the text's. Each line's spans
## (its text, then a highlighted number's chip) flow as one paragraph, word by word, wrapping
## at the width: laid out here, now, so the panel opens at its size the first time.
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


## A line's spans, each {text, font, px, ink, pad (extra space before it), chip, arrow}: a
## number a live source has moved sits in a chip, white for the player's gain, the enemy red
## for a loss, its arrow saying which way it moved; a number nothing moved is plain.
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
	var out: Array = [_span(text, Hud.display(), 18, Palette.INK)]
	var value := str(l.get("value", ""))
	if not value.is_empty():
		var trend := int(l.get("trend", 0))
		if trend == 0:
			out.append(_span(value, Hud.display(), 18, Palette.INK))
		else:
			var gain := bool(l.get("gain", false))
			var chip := _span(value, Hud.display_bold(), 18, Palette.BG if gain else Palette.INK)
			chip["chip"] = Palette.SELECT if gain else Palette.ENEMY
			chip["arrow"] = trend
			out.append(chip)
	return out


static func _span(text: String, font: Font, px: int, ink: Color, pad: float = 0.0) -> Dictionary:
	return {"text": text, "font": font, "px": px, "ink": ink, "pad": pad, "chip": null, "arrow": 0}


## Lay the spans' words left to right from `y`, wrapping at `width`; returns the bottom. A
## chip is one word: its text, its arrow and its padding.
func _flow(spans: Array, width: float, y: float) -> float:
	var row: Array = []
	var x := 0.0
	for sp in spans:
		var font: Font = sp["font"]
		var px: int = sp["px"]
		var space := font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		var words: PackedStringArray = [str(sp["text"])] if sp["chip"] != null else str(sp["text"]).split(" ", false)
		var first := true
		for w in words:
			var ww := font.get_string_size(w, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
			if sp["chip"] != null:
				ww += CHIP_PAD * 2.0 + px * 0.95   # the arrow beside the number, inside the chip
			var lead := 0.0 if row.is_empty() else space + (float(sp["pad"]) if first else 0.0)
			if not row.is_empty() and x + lead + ww > width:
				y = _commit(row, y) + LEADING
				row = []
				x = 0.0
				lead = 0.0
			row.append({"text": w, "font": font, "px": px, "ink": sp["ink"], "x": x + lead, "w": ww, "chip": sp["chip"], "arrow": sp["arrow"]})
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
		if w["chip"] != null:
			var px := float(w["px"])
			draw_rect(Rect2(Vector2(at.x, float(w["top"]) - 1.0), Vector2(float(w["w"]), float(w["height"]) + 2.0)), w["chip"], true)
			draw_string(w["font"], at + Vector2(CHIP_PAD, 0), w["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, w["px"], w["ink"])
			# The arrow: which way the number moved, so the chip reads without its hue.
			var cx: float = at.x + float(w["w"]) - CHIP_PAD - px * 0.3
			var cy: float = at.y - px * 0.36
			var s := px * 0.3
			var tip := Vector2(cx, cy - s) if int(w["arrow"]) > 0 else Vector2(cx, cy + s)
			var base_y := cy + s * 0.75 if int(w["arrow"]) > 0 else cy - s * 0.75
			draw_colored_polygon(PackedVector2Array([tip, Vector2(cx - s, base_y), Vector2(cx + s, base_y)]), w["ink"])
		else:
			draw_string(w["font"], at, w["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, w["px"], w["ink"])


## The readout's text as one string, a line each, for tests and the log: a moved number with its
## arrow.
func text() -> String:
	var out: Array[String] = []
	for l in lines:
		var t := (str(l.get("place", "")) + "  " if not str(l.get("place", "")).is_empty() else "") + str(l.get("text", ""))
		if not str(l.get("value", "")).is_empty():
			t += " " + str(l["value"]).replace(NBSP, " ") + ("" if int(l.get("trend", 0)) == 0 else (" ▲" if int(l["trend"]) > 0 else " ▼"))
		out.append(t)
	return "\n".join(out)
