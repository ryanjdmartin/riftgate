class_name EntryReadout
extends Control

## The die's hold (Ryan, 25 and 26 October): the entry showing, alone, its iconography as text
## ("it just turns the iconography into text, basically"). Its place on the die and its name,
## what holds on it now (a cooldown with its turns left, a foe's switch-off, corruption), its
## codex, then a line for each mark the die carries: its number as the die prints it, its heat
## and its costs, its target, then its keywords (how it lands, what it leaves on each foe hit,
## Rapid's or Instant's turn after), then its own rules and a written-out grant's (the star; "unique effects
## last"), then its tags. A number the live sources have moved off the component's own is
## coloured rather than its sources listed (Ryan, 26 October: listing them "reads to me like
## we're expecting the player to do math"; "just change the font colour and add the arrow"):
## green where the change is good for its unit, the red-red (LOSS) where it is bad (more heat, a
## smaller blow), relative to the unit and never to the player ("Positive and negative are
## always relative to the unit"), its arrow attached to the number that moved, so a split
## weapon's smaller blow and its extra strike each say so ("Skua should have down on the damage
## and up on the count"), and it reads without the hue. What a keyword means is the keywords list's (the pause menu,
## and the button under the eye). No flavour yet.
##
## A term the keywords list defines reads bold in its colour with its icon before it, wherever
## shown text names it (Ryan, 30 October: "in codex and help text, we should be highlighting
## keywords in their colour when applicable, and even including the iconography"; "Try bold in
## the colour first, and I'll judge"), the colour and the icon the one table's (Terms); a tap on
## it opens its entry where it stands (KeywordTip; "Tapping a keyword is exactly what we need").
## The readout claims a tap on a term alone, so every other tap falls through as it did.

## The content width at the readout's panel width (460, less the panel's margins).
const WIDTH := 432.0
const LEADING := 3.0      # between two lines of text
const BREATH := 9.0       # between the name block and the effects, and before the tags
const ARROW_GAP := 2.0    # between a moved number and its arrow
const BAR_X := 74.0       # a gauge's bar, after its label
const BAR_W := 220.0
const BAR_H := 13.0
const CHIP := 22.0        # a chip's box, its text beside it
const CHIP_INDENT := 32.0
const MARK_GAP := 4.0     # between two marks at a line's head
const MARKED := ["effect", "rule"]   # the lines that share the marks' column, when any of them has a mark
const PASSIVE_PX := 15    # a number in a passive box mark
const ICON := 0.86        # a term's icon, a share of its text's size
const ICON_GAP := 3.0     # between a term's icon and its word
const TAP_GROW := 6.0     # a term's tap area past its word, for a thumb
const TAP_SLOP := 14.0    # how far a press may travel and still be a tap

var lines: Array = []   # the readout as built, each {style, text, parts, place}: what tests read
var _words: Array = []  # the words as laid out, each {text, font, px, ink, at, arrow, w, icon, glyph, terms}
var _bars: Array = []   # the gauges as laid out, each {rect, frac, colour}
var _chips: Array = []  # the chips' boxes as laid out, each {rect, glyph, colour}
var _hits: Array = []   # the terms as laid out, each {rect, terms}: where a tap opens one
var _press_at := Vector2.ZERO
var _press_terms: Array = []


func _init() -> void:
	# A tap lands here on a term alone (_has_point), so the rest falls through to what lies under.
	mouse_filter = Control.MOUSE_FILTER_PASS


## The quieter face's ink: halfway from the ink to the muted grey (the tags row).
static func hint_ink() -> Color:
	return Palette.INK.lerp(Palette.MUTED, 0.5)


## The readout's lines for `f`, the entry as its machine shows it now (Skirmish.shown_face), at
## `place` on its die (from one). `shown` is its blow as the die prints it (Skirmish.shown_number:
## every modifier in; -1, the entry's own), `base` the component as
## built, whose numbers a highlight is read against, `states` what holds on it now, `grants`
## the written-out grants' lines (Effects.printed_grants), `types` what kind of piece it is on
## its machine (face_types), beside its name; its tags are the shown entry's, a passive's
## change in. A state is its words, or [words, mark()] when the die shows a mark for it (the
## lock, the corruption); `extra` is what the screen adds for a mark the die prints from its
## machine (a stepping die's next chamber), each a line with its mark, after the entry's own.
static func lines_for(f: Face, place: int, shown: int, base: Face, states: Array, grants: Array, db: ContentDB, types: Array = [], extra: Array = [], cooldown: int = -1) -> Array:
	var out: Array = []
	if f == null:
		return out
	var comp: Dictionary = db.components.get(f.component, {}) if not f.component.is_empty() else {}
	var title := "EMPTY HARDPOINT" if f.empty else (entry_name(f, db).to_upper() if not f.component.is_empty() else f.describe().to_upper())
	out.append({"style": "title", "text": title, "place": Hud.roman(place), "type": ", ".join(PackedStringArray(types))})
	for st in states:
		# One line a state, so the mark the die shows for it (the lock, the corruption) stands at its head.
		if st is Array and (st as Array).size() >= 2:
			out.append(marked(text_line("state", str(st[0])), [st[1]]))
		else:
			out.append(text_line("state", str(st)))
	var codex := str(comp.get("codex", ""))
	if not codex.is_empty():
		out.append(text_line("codex", codex))
	out.append_array(effects_of(f, shown, base, cooldown))
	out.append_array(extra)
	for g in grants:
		out.append(marked(text_line("rule", str(g), "rule"), [mark("star", Glyphs.colour_for("star"))]))
	if not f.tags.is_empty():
		var names: Array[String] = []
		for t in f.tags:
			names.append(capital(t))
		out.append(text_line("tags", "Tags: " + ", ".join(names)))
	return out


## What the entry does, a line each: its number as the die prints it (`shown`), its heat (or its
## ammo) and its costs beside it, its target (Ryan, 26 October: "Swap heat and target places"), then its keywords below
## them, how it lands, what it leaves on each foe hit, Rapid's or Instant's turn after, then its own
## rules (Face.rule_phrases). `base`, the component as built, is what each number is read
## against; null reads `f` as its own. Each line carries its group, for the codex's three lines:
## "attr" (its number, its heat and ammo, its target), "kw" (its keywords) and "rule" (its own
## rules).
## `cooldown`: the rounds a spend darkens it as its machine has it (Skirmish.cooldown_of, the
## Kite's two); -1 reads the entry's own.
static func effects_of(f: Face, shown: int = -1, base: Face = null, cooldown: int = -1) -> Array:
	var out: Array = []
	if base == null:
		base = f
	# Each line carries the die's mark it says in words (Ryan, 2 November: every icon on a die face
	# represented in the popup): the big glyph on what the piece is, a keyword's chip on its line,
	# the star on every unique rule, the marks beside the heat on theirs, the three hexes on whom
	# it is spent on.
	var main := mark(Glyphs.primary_for(f), Palette.HUD, false)
	var star := mark("star", Glyphs.colour_for("star"))
	if f.kind == Face.Kind.BLANK:
		# The title names what was there; the line says what the blank does.
		if f.empty:
			out.append(marked(text_line("effect", "Comes up blank: nothing fills it", "attr"), [main]))
		elif not f.disabled and not f.component.is_empty():
			out.append(marked(text_line("effect", "Destroyed: comes up blank for the rest of the battle", "attr"), [main]))
		else:
			out.append(marked(text_line("effect", capital(f.describe()), "attr"), [main]))
		return out
	# The strikes, read against the component's own: a split weapon's extra strike is a gain
	# beside its smaller blow (Ryan, 26 October).
	var strikes: Array = [num("×%d" % f.strikes, f.strikes, base.strikes)] if f.strikes > 1 or base.strikes > 1 else []
	match f.kind:
		Face.Kind.ATTACK:
			if f.is_debuff():
				out.append(marked(parts_line("effect", [word("Debuff")] + strikes, "attr"), [main]))
			else:
				var n: int = shown if shown >= 0 else f.power
				# A strike's blow against the component's own: more is the gain.
				var blow := word(str(n))
				_trend(blow, n, base.power)
				out.append(marked(parts_line("effect", [word("Attack"), blow] + strikes, "attr"), [main]))
		Face.Kind.BUFF:
			if f.act_again:
				out.append(marked(text_line("effect", "An ally whose die is spent acts again", "attr"), [main, star]))
			elif f.turns_die:
				out.append(marked(text_line("effect", "Turns its die to its other battery", "attr"), [main, star]))
			else:
				var st: Dictionary = Effects.STATUS.get(f.buff_status, {})
				# What a buff grants against the component's own; one that spends a count for its
				# stacks (the Quintessence Tap) grants what it would take now, its own rule and no change
				# a live source made, so its number reads plain.
				var own_stacks := f.buff_stacks if not f.spends.is_empty() else base.buff_stacks
				var line := [word("Grants %s" % str(st.get("name", f.buff_status))), num("×%d" % f.buff_stacks, f.buff_stacks, own_stacks)]
				if f.buff_rounds > 1:
					line.append(word("for %d rounds" % f.buff_rounds))
				# The status's chip beside the equipment's mark, as the die's rail carries it with its
				# stacks (DieFaceView.status_chip): the word itself wears no second icon.
				var granted := DieFaceView.status_chip(f)
				var heads := [main] + ([mark(Terms.glyph(granted), Terms.colour(granted))] if not granted.is_empty() else [])
				if not granted.is_empty():
					line[0] = _bare(line[0])
				out.append(marked(parts_line("effect", line, "attr"), heads))
		Face.Kind.SHIELD:
			if f.fills_shield:
				out.append(marked(text_line("effect", "Shield to its maximum", "attr"), [main, star]))
			else:
				out.append(marked(parts_line("effect", [word("Shield"), num(str(f.power), f.power, base.power)], "attr"), [main]))
			if f.vents > 0:
				# A shield that also cools (the Sutler's Hoist), the cooling first: its number under
				# the steam the die draws off the shield's top (Ryan, 3 November).
				out.append(marked(parts_line("effect", [word("Vent"), num(str(f.vents), f.vents, base.vents), word("before the shield")], "attr"), [mark("vent", Palette.HUD, false)]))
		Face.Kind.VENT:
			# A reload is a vent that cools nothing, its ammo its number, the shells' mark its whole
			# main mark (Ryan, 2 November: one piece on one machine wears no main mark of its own).
			var loads := marked(parts_line("effect", [word("Reloads"), num(str(f.reloads_ammo), f.reloads_ammo, base.reloads_ammo), word("ammo")], "attr"), [mark("ammo", Palette.SELECT, false)])
			if f.power <= 0 and f.reloads_ammo > 0:
				out.append(loads)
			else:
				out.append(marked(parts_line("effect", [word("Vent"), num(str(f.power), f.power, base.power)], "attr"), [main]))
				if f.reloads_ammo > 0:
					out.append(loads)
	if f.ammo > 0:
		# A forging machine's gun (the Musk Ox's): its price in ammo, by the shells' mark.
		var ammo := [word("Ammo"), num(str(f.ammo), f.ammo, base.ammo, true)]
		if f.dry:
			ammo.append(word("(the magazine cannot pay it)"))
		out.append(marked(parts_line("effect", ammo, "attr"), [mark("ammo", Palette.LOSS if f.dry else Palette.SELECT, false)]))
	if f.heat > 0 or base.heat > 0:
		# The costs, each by the mark the die prints it with along its foot (Ryan, 2 November).
		out.append(marked(parts_line("effect", [word("Heat"), num(str(f.heat), f.heat, base.heat, true)], "attr"), [mark("heat", Palette.HEAT, false)]))
	# The entry's costs past heat, beside it as the die prints them (Ryan, 26 October: Volatile a
	# cost printed beside the heat, a keyword with a chip until then, and a shield cost beside it):
	# the hull a spend bites, the shield it takes first. Less is the gain.
	if f.volatile > 0 or base.volatile > 0:
		out.append(marked(parts_line("effect", [word("Costs"), num(str(f.volatile), f.volatile, base.volatile, true), word("hull")], "attr"), [mark("hull", Palette.HULL, false)]))
	if f.shield_cost > 0 or base.shield_cost > 0:
		var shield_cost := [word("Costs"), num(str(f.shield_cost), f.shield_cost, base.shield_cost, true), word("shield")]
		if f.short:
			shield_cost.append(word("(the shield cannot pay it)"))
		out.append(marked(parts_line("effect", shield_cost, "attr"), [mark("shield", Palette.LOSS if f.short else Palette.SHIELD, false)]))
	if not f.spends.is_empty():
		# A count its machine spends for its stacks (the Quintessence Tap's Essence): what it would take
		# now, by the count's own mark, as the die prints it along its foot.
		var spent_term := Terms.of_status(f.spends)
		var spent := [word("Consumes"), word(str(f.buff_stacks)), word(str(Effects.STATUS.get(f.spends, {}).get("name", f.spends)))]
		if f.short:
			spent.append(word("(it holds none)"))
		out.append(marked(parts_line("effect", spent, "attr"), [mark(Terms.glyph(spent_term) if not spent_term.is_empty() else "star", Palette.LOSS if f.short else Terms.status_colour(f.spends), false)]))
	# The rounds it goes dark once spent, a cost by its clock along the die's foot (Ryan, 2
	# November: "Cooldown should be a cost in the bottom section as well").
	var cd := cooldown if cooldown >= 0 else f.cooldown_rounds()
	if cd > 0:
		out.append(marked(parts_line("effect", [_bare(word("Cooldown")), num(str(cd), cd, base.cooldown_rounds(), true)], "attr"), [mark("cooldown", Palette.INK, false)]))
	# Whom it is aimed at, headed by the targeting mark the die draws under its number
	# (Glyphs.aim_for: a line of fire for Direct, lobbed for Indirect, the enemy's formation lit for
	# Every Foe; the three hexes for a piece spent
	# on machines, under an arch for Every Ally and Every Other Ally), bare as the mark is. An area past the
	# target is its keyword's line (Spread, Penetrate, Splash), as the die chips it.
	# The words bare: the reach's term stays a term (tap it), its icon the line's own mark, never
	# a second one shrunk into the words (the formation reads as a blob at the text's size).
	var aimed := ("Target: Every Foe" if f.reach == Face.Reach.EVERY_FOE else "Target: Enemy, %s" % capital(Face.REACH_NAMES[f.reach])) if f.kind == Face.Kind.ATTACK else whom(f)
	var target := parts_line("effect", [_bare(word(aimed))], "attr")
	var aim := Glyphs.aim_for(f)
	if not aim.is_empty():
		marked(target, [mark(aim, Palette.HUD, false)])
	out.append(target)
	var land: Array = []   # how it lands
	var lays: Array = []   # what it leaves on each foe hit
	var after: Array = []  # Rapid's or Instant's turn
	for k in f.keywords:
		# Its name as the list writes it (Every Foe), so the word is the term's and taps open it.
		var label := Face.keyword_label(k).capitalize()
		var gate := Effects.gate_text(f.gates[Face.KEYWORD_NAMES[k]]) if f.gates.has(Face.KEYWORD_NAMES[k]) else ""
		# The keyword's chip, as the die boxes it, the star beside it when a gate is the entry's own
		# rule; the chip is the term's icon, so the word itself wears none.
		var chip := [mark(Face.KEYWORD_NAMES[k], Glyphs.colour_for(Face.KEYWORD_NAMES[k]))] + ([star] if not gate.is_empty() else [])
		var line: Dictionary
		if Face.KEYWORD_STATUS.has(k):
			var parts := [_bare(word("Apply %s" % label))]
			var field: String = {Face.Keyword.ABLATE: "ablate", Face.Keyword.CRYO: "cryo", Face.Keyword.BRITTLE: "brittle", Face.Keyword.SAP: "sap"}.get(k, "")
			if not field.is_empty() and int(f.get(field)) > 0:
				parts.append(num(str(f.get(field)), int(f.get(field)), int(base.get(field))))
			parts.append(word(gate if not gate.is_empty() else "on hit"))
			lays.append(marked(parts_line("effect", parts, "kw"), chip))
		elif Face.ACT_AGAIN_KEYWORDS.has(k):
			after.append(marked(parts_line("effect", [_bare(word(label))], "kw"), chip))
		elif k in [Face.Keyword.LURE, Face.Keyword.DISRUPT, Face.Keyword.DISPEL]:
			lays.append(marked(parts_line("effect", [_bare(word(label))], "kw"), chip))
		elif (Face.AREA_KEYWORDS.has(k) or k == Face.Keyword.CHAIN) and not f.is_debuff():
			# Area by shape, numbered (Ryan, 28 October): what each foe past the target takes, its
			# change from the component's own marked as every number's is (the drum's Spread 2);
			# Chain's the same, what each Shocked conductor takes, plain (29 October: no strike is
			# aimed at it, so its charge stands).
			land.append(marked(parts_line("effect", [_bare(word(label)), num(str(f.number_of(k)), f.number_of(k), base.number_of(k))], "kw"), chip))
		else:
			land.append(marked(parts_line("effect", [_bare(word(label))], "kw"), chip))
	out.append_array(land)
	out.append_array(lays)
	out.append_array(after)
	for r in f.rule_phrases():
		out.append(marked(text_line("rule", capital(r), "rule"), [star]))
	# A rule the die stars with no line of its own (a reload that is its vent's number, the Musk
	# Ox's): the star on what the piece does, so the die's star always heads a line.
	if f.has_unique_rule() and not out.any(func(l: Dictionary) -> bool: return (l.get("marks", []) as Array).any(func(m: Dictionary) -> bool: return str(m.get("glyph", "")) == "star")):
		marked(out[0], [star])
	return out


## A part whose terms wear no icon of their own: its line's mark is the icon.
static func _bare(p: Dictionary) -> Dictionary:
	p["icon"] = false
	return p


## The codex's row for a component (Ryan, 26 October: "each component row has a line for basic
## attributes, a line for keywords, and a line for unique component effects"): its name, its
## type (face_type) and its tags beside it, then the hold's lines joined by group, at the
## component's own numbers, and `rules` (its passive's lines) after its own. A line with
## nothing to say is left out.
static func codex_lines(f: Face, db: ContentDB, rules: Array = []) -> Array:
	var title := "EMPTY HARDPOINT" if f.empty else (entry_name(f, db).to_upper() if not f.component.is_empty() else f.describe().to_upper())
	var tags: Array[String] = []
	for t in f.tags:
		tags.append(capital(t))
	var out: Array = [{"style": "name", "text": title, "type": face_type(f), "tags": ", ".join(tags), "parts": [word(title)], "place": ""}]
	var marks := effects_of(f)
	for r in rules:
		marks.append(text_line("rule", str(r), "rule"))
	out.append_array(joined(marks))
	return out


## What kinds of piece an entry is on its machine, for the die's hold: the engine's kinds
## (Effects.kinds_of), its own then any a passive adds there (Ryan, 26 October: "Hybrid cases can
## exist. Such as the steam vents, they get tagged as a hybrid 'vent, weapon' on that machine";
## "If a passive or other effect alters labels or tags, the same rule applies"), so the label
## and the rules read one source. `f` is the entry as the machine shows it, its rewrites in, so
## the drum's shot from a debuff reads as the weapon it fires as. The codex reads the component
## as built and never asks this.
static func face_types(f: Face, u = null) -> Array[String]:
	var out: Array[String] = []
	for k in Effects.kinds_of(u, f):
		out.append(capital(k))
	return out


## What kind of piece an entry is as built, as its main icon on the die says it (Ryan, 26
## October: "Face type is either Weapon, Shield, Vent, or Equipment. Equipment is the label for
## all 4 forms of buff and debuff faces"); a blank is none.
static func face_type(f: Face) -> String:
	var own := Effects.kinds_of(null, f)
	return capital(own[0]) if not own.is_empty() else ""


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
				parts.append(word("·"))
			parts.append_array(l.get("parts", [word(str(l.get("text", "")))]))
		if not parts.is_empty():
			out.append(parts_line("row_" + g, parts, g))
	return out


## A foe's move, a line a mark in the die's order (Ryan, 26 October: a foe's intent "in the same
## format as the die hold press for a component"): its name, its blow and strikes (or what kind
## of move it is), whom it is aimed at, when it lands and on what condition, its riders, then its
## text. `live` reads the blow as it will land now (its kin, a rally), coloured against its own
## relative to the foe (Ryan: "Positive and negative are always relative to the unit, not the
## player": a harder blow is green), with `target` the machine it is aimed at; the codex reads
## it at its own numbers. Groups as effects_of's.
static func move_lines(f: Foe, a: Dictionary, db: ContentDB, live: bool = false, target: String = "") -> Array:
	var out: Array = []
	var name := str(a.get("name", "")).to_upper()
	out.append({"style": "title", "text": name, "parts": [word(name)], "place": ""})
	var own := f.base_damage_of(a)
	var dmg := f.damage_of(a) if live else own
	# The word an attack carries for whom it goes for (17 November): in the codex it is the
	# target's line whole, and in a fight it follows the machine it picked.
	var aim := f.aim_of(a)
	var word_for := "" if aim.is_empty() else str(Foe.AIM_TEXT.get(aim, aim))
	var aimed := "" if word_for.is_empty() else ", " + word_for
	var anyone := "Any machine" if word_for.is_empty() else capital(word_for)
	if Foe.is_attack_action(a):
		var line := [word("Attack"), num(str(dmg), dmg, own) if live else word(str(dmg))]
		if not Foe.power_status(a).is_empty() and (not live or not Effects.has(f, Foe.power_status(a))):
			line = [word("Attack: what it took")]   # a borrowed swing (30 October): its number is the piece it took
		var n := maxi(1, int(a.get("strikes", 1)))
		if n > 1:
			line.append(word("×%d" % n))
		if int(a.get("swarm", 0)) > 0 and not live:
			line.append(word("(+%d a kin standing)" % int(a["swarm"])))
		if int(a.get("per_kill", 0)) > 0 and not live:
			line.append(word("(+%d a foe the team has killed)" % int(a["per_kill"])))   # a grudge (30 October)
		out.append(parts_line("effect", line, "attr"))
		if Array(a.get("keywords", [])).has("all"):
			out.append(text_line("effect", "Target: %s" % str(db.vocabulary.get("all", {}).get("name", "Every machine")), "attr"))   # the term, so it reads as one (Terms)
		else:
			out.append(text_line("effect", "Target: %s" % ((target + aimed) if live and not target.is_empty() else anyone), "attr"))
	else:
		var kind := capital(Foe.kind_of(a))
		var whom := str(MOVE_TARGETS.get(str(a.get("effect", "")), "Any machine"))
		if whom == "Every machine":
			whom = str(db.vocabulary.get("all", {}).get("name", whom))   # the term, as a blow at every machine says it
		if live and whom == "Any machine" and not target.is_empty():
			whom = target + aimed
		elif whom == "Any machine":
			whom = anyone
		out.append(text_line("effect", kind, "attr"))
		out.append(text_line("effect", "Target: %s" % whom, "attr"))
	if str(a.get("id", "")) == "last_act":
		out.append(text_line("effect", "Lands the moment it falls", "attr"))   # its last act (15 October)
	if bool(a.get("once", false)):
		out.append(text_line("effect", "Once a fight", "attr"))   # a special used once (30 October)
	var count := Foe.countdown_of(a)
	if count > 0:
		var left := f.charge if live and f.gathering() and f.pending.get("id", "") == a.get("id", "") else count
		out.append(text_line("effect", "Lands next round" if left == 1 else "Lands in %d rounds" % left, "attr"))
	# A follow-up (30 October): the pair says itself, so the second never reads as a move of the roll.
	var follows := str(a.get("then", ""))
	if not follows.is_empty():
		out.append(text_line("effect", "Then %s, next round" % _move_name(f, follows), "attr"))
	for o in f.actions:
		if str(o.get("then", "")) == str(a.get("id", "")) and not str(a.get("id", "")).is_empty():
			out.append(text_line("effect", "Only after %s" % str(o.get("name", "")), "attr"))
	var whens := Foe.whens_of(a)
	if not whens.is_empty():
		var said: Array[String] = []
		for w in whens:
			said.append(str(Foe.WHEN_TEXT.get(str(w), str(w))))
		out.append(text_line("effect", capital(" or ".join(said)), "attr"))
	for k in a.get("keywords", []):
		if str(k) == "all":
			continue   # its target says it
		var label := str(db.vocabulary.get(str(k), {}).get("name", str(k)))
		if Foe.NUMBERED_RIDERS.has(str(k)):
			label += " %d" % f.rider(a, str(k))
		out.append(text_line("effect", label, "kw"))
	var text := str(a.get("text", "")).replace("{damage}", str(dmg)).replace("{value}", str(int(a.get("value", 0))))
	if not text.is_empty():
		out.append(text_line("rule", text, "rule"))
	return out


## A foe's move's name by its id, or the id when it has none.
static func _move_name(f: Foe, id: String) -> String:
	for o in f.actions:
		if str(o.get("id", "")) == id:
			return str(o.get("name", id))
	return id


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
	"brace": "Self", "recover": "Self", "revive_once": "Self", "barrier": "Self", "regenerate": "Self", "golden": "Self",
	"heal": "The most hurt of its own", "brace_all": "Every foe", "revive_once_ally": "One of its own",
	"cleanse": "The most-marked of its own", "prime": "Every other foe", "ward_all": "Every foe",
	"summon": "Empty places", "rally": "Every foe", "merge": "Its kinds on the field", "appropriate": "Any machine",
	"drain_rerolls": "The team's rerolls", "scorch_all": "Every machine", "corrupt_all": "Every machine",
	"unready_all": "Every foe it readied", "phase": "Self",
}


## Whom a shield, a vent or a buff is spent on (Ryan's words, 26 October), Every Ally and Every
## Other Ally among them (targeting modes since 4 November).
static func whom(f: Face) -> String:
	match f.targets:
		Face.Target.SELF:
			return "Target: Self"
		Face.Target.ALLY:
			return "Target: Any other ally"
		Face.Target.EVERY_ALLY:
			return "Target: Every Ally" + (" yet to act" if f.not_acted else "")
		Face.Target.EVERY_OTHER_ALLY:
			return "Target: Every Other Ally" + (" yet to act" if f.not_acted else "")
	return "Target: Any ally or self"


static func capital(s: String) -> String:
	return s.substr(0, 1).to_upper() + s.substr(1)


## A mark at a line's head (Ryan, 2 November: "any icon on a die face NEEDS to be represented in
## the popup, star icon before the unique effect for instance"): the mark on the die, or on a
## unit's chip, that the line says in words, boxed as the die boxes its chips or bare as it draws
## its main glyph and the marks beside its heat.
static func mark(glyph: String, ink: Color, boxed: bool = true) -> Dictionary:
	return {"glyph": glyph, "ink": ink, "box": boxed}


## The die's passive box as a mark (DieFaceView.passive_marks: [glyph, text, Color]): what the
## machine's passive adds to the entry, a dashed box holding its mark or its number or both, at
## the head of the line that says it (Ryan, 4 November: "the tap popup will clarify").
static func passive_mark(glyph: String, text: Variant, ink: Color) -> Dictionary:
	return {"passive": [glyph, text], "ink": ink}


## How wide a passive box mark is: a chip's width, or what it holds and a margin.
static func passive_width(m: Dictionary) -> float:
	var held: Array = m.get("passive", ["", ""])
	var tw := 0.0
	for r in DieFaceView.passive_runs(held[1], Palette.HUD):
		tw += DieFaceView.run_width(r, Hud.mono(), PASSIVE_PX)
	var inner := (13.0 if not str(held[0]).is_empty() else 0.0) + (2.0 if not str(held[0]).is_empty() and tw > 0.0 else 0.0) + tw
	return maxf(CHIP, inner + 8.0)


## A field's chip as a mark (UnitView.draw_chip's [glyph, text, Color, kind, riders]): a foe's
## intent drawn in its readout as it stands under the foe, riders and all.
static func chip_mark(chip: Array) -> Dictionary:
	return {"chip": chip}


## `l` with `marks` at its head (mark()), after any it carries; returns it.
static func marked(l: Dictionary, marks: Array) -> Dictionary:
	var all: Array = l.get("marks", [])
	all.append_array(marks)
	l["marks"] = all
	return l


## A line of one plain part.
static func text_line(style: String, text: String, group: String = "") -> Dictionary:
	return parts_line(style, [word(text)], group)


## A line of parts, each {text, trend, gain, glue}: plain words, or a number a live source moved;
## a glued part sits against the one before it, no space between. Its `text` is the parts
## joined, for tests and the log.
static func parts_line(style: String, parts: Array, group: String = "") -> Dictionary:
	var t := ""
	for p in parts:
		t += ("" if t.is_empty() or bool(p.get("glue", false)) else " ") + str(p["text"])
	return {"style": style, "text": t, "parts": parts, "place": "", "group": group}


static func word(text: String) -> Dictionary:
	return {"text": text, "trend": 0, "gain": false}


## A number `now` read against its unit's own `own`: moved, it carries the way it moved and
## whether that is a gain for the unit whose number it is, never for the player (Ryan, 26
## October): more is, unless `less_is_gain` (heat, a hull price).
static func num(text: String, now: int, own: int, less_is_gain: bool = false) -> Dictionary:
	var p := word(text)
	_trend(p, now, own, less_is_gain)
	return p


static func _trend(p: Dictionary, now: int, own: int, less_is_gain: bool = false) -> void:
	p["trend"] = signi(now - own)
	p["gain"] = (now < own) if less_is_gain else (now > own)


## The ink of a moved number: green for its unit's gain, the red-red for its loss (Ryan, 26
## October: "If that means using green, this is the place for it"); unmoved, the text's own.
static func trend_ink(p: Dictionary, plain: Color = Palette.INK) -> Color:
	if int(p.get("trend", 0)) == 0:
		return plain
	return Palette.GAIN if bool(p.get("gain", false)) else Palette.LOSS


## Fill the readout from `list` (lines_for) at `width`, its height the text's. Each line's parts
## flow as one paragraph, word by word, wrapping at the width: laid out here, now, so the panel
## opens at its size the first time.
func set_lines(list: Array, width: float = WIDTH) -> void:
	lines = list
	_words.clear()
	_bars.clear()
	_chips.clear()
	_hits.clear()
	# The marks' column (mark()): as wide as the most marks an effect or rule line carries, shared
	# by every one of them so their words start together; a marked line of another kind (a state,
	# a move's name) takes its own.
	var column := 0
	for l in list:
		if MARKED.has(str(l.get("style", ""))):
			column = maxi(column, (l.get("marks", []) as Array).size())
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
			elif style in ["bar", "chip"] and before not in ["bar", "chip"]:
				y += BREATH
			else:
				y += LEADING
		match style:
			"bar":
				y = _bar(l, y)
			"chip":
				# The chip's box at the line's head, its text wrapping beside it.
				_chips.append({"rect": Rect2(Vector2(0.0, y), Vector2(CHIP, CHIP)), "glyph": str(l.get("glyph", "")), "colour": l.get("colour", Palette.HUD), "box": true})
				y = maxf(_flow(_spans(l), width, y + 1.0, CHIP_INDENT), y + CHIP)
			_:
				var marks: Array = l.get("marks", [])
				var n := column if MARKED.has(style) else marks.size()
				if n == 0:
					y = _flow(_spans(l), width, y)
				else:
					# Each mark in its box at the head; a field's chip (a foe's intent, riders and
					# all) at its own size, the words beside it centred on it.
					var x := 0.0
					var tall := CHIP
					for m in marks:
						var chip: Array = m.get("chip", [])
						var sz := Vector2(UnitView.chip_width(Hud.mono(), chip), UnitView.CHIP_H) if not chip.is_empty() else Vector2(CHIP, CHIP)
						if m.has("passive"):
							sz = Vector2(passive_width(m), CHIP)
						_chips.append({"rect": Rect2(Vector2(x, y), sz), "glyph": str(m.get("glyph", "")),
							"colour": m.get("ink", Palette.INK), "box": bool(m.get("box", true)), "chip": chip, "passive": m.get("passive", [])})
						x += sz.x + MARK_GAP
						tall = maxf(tall, sz.y)
					var own := x - MARK_GAP + (CHIP_INDENT - CHIP)   # past a wider mark (a passive box holding a number)
					var indent := maxf(mark_indent(n), own) if MARKED.has(style) else own
					var bottom := _flow(_spans(l), width, y + 1.0 + (tall - CHIP) * 0.5, indent)
					y = maxf(bottom, y + tall) if not marks.is_empty() else bottom
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
			var head := [_span(str(l.get("place", "")), Hud.quote(), 19, Palette.MUTED), _span(text, Hud.display_bold(), 21, Palette.INK, 6.0)]
			if not str(l.get("type", "")).is_empty():
				head.append(_span(str(l["type"]), Hud.display(), 17, Palette.INK, 10.0))   # what kind of piece it is on this machine
			return head
		"state":
			return _marked([_span(text, Hud.display_bold(), 18, Palette.INK)])
		"codex":
			return _marked([_span(text, Hud.display(), 17, Palette.INK)])
		"term":
			var id := str(l.get("term", ""))
			var head := _span(text, Hud.display_bold(), int(l.get("px", 20)), Terms.colour(id))
			head["glyph"] = Terms.glyph(id)
			head["glyph_ink"] = Terms.colour(id)
			return [head]
		"tags":
			return [_span(text, Hud.quote(), 17, hint_ink())]
		"name":
			# A codex row's head: the name, its type in ink (it matters), its tags quiet after it.
			var head := [_span(text, Hud.display_bold(), 18, Palette.INK)]
			var kind := str(l.get("type", ""))
			var tags := str(l.get("tags", ""))
			if not kind.is_empty():
				head.append(_span(kind, Hud.display(), 16, Palette.INK, 8.0))
			if not tags.is_empty():
				head.append(_span(("· " if not kind.is_empty() else "") + tags, Hud.quote(), 16, hint_ink(), 0.0 if not kind.is_empty() else 8.0))
			return head
		"caption":
			return [_span(text, Hud.mono(), 12, Color(Palette.HUD, 0.75))]
	# The codex's joined rows a size down from the hold's lines. A moved number is bold in its
	# trend's ink with its arrow; a part may ask for bold or an ink of its own (a source's); a
	# paragraph (prose_line) brings its own size and ink. A term in a part's words is marked.
	var px := int(l.get("px", 17 if str(l.get("style", "")).begins_with("row_") or str(l.get("style", "")) in ["named", "chip"] else 18))
	var plain: Color = l.get("ink", Palette.INK)
	var out: Array = []
	for p in l.get("parts", [word(text)]):
		var trend := int(p.get("trend", 0))
		var bold := trend != 0 or bool(p.get("bold", false))
		var sp := _span(str(p["text"]), Hud.display_bold() if bold else Hud.display(), px, trend_ink(p, p.get("ink", plain)))
		sp["arrow"] = trend
		sp["glue"] = bool(p.get("glue", false))
		if trend == 0:
			out.append_array(_marked([sp], bool(p.get("icon", true))))
		else:
			out.append(sp)   # a moved number is its trend's, never a term
	return out


static func _span(text: String, font: Font, px: int, ink: Color, pad: float = 0.0) -> Dictionary:
	return {"text": text, "font": font, "px": px, "ink": ink, "pad": pad, "arrow": 0, "glue": false}


## Spans with each term in their words cut out as its own span, bold in its colour with its
## icon before it (unless `icons` is off: a chip's own name, its box beside it), the ids it
## stands for kept for a tap (Terms.split). The runs keep their spacing: a term against a
## bracket or a comma stays against it.
static func _marked(spans: Array, icons: bool = true) -> Array:
	var out: Array = []
	for sp in spans:
		var segs := Terms.split(str(sp["text"]))
		if segs.size() == 1 and (segs[0]["terms"] as Array).is_empty():
			out.append(sp)
			continue
		var first := true
		var spaced := false   # the run before ended on a space
		for seg in segs:
			var t := str(seg["text"])
			var bare := t.strip_edges()
			if bare.is_empty():
				spaced = true
				continue
			var sub: Dictionary = sp.duplicate()
			sub["text"] = bare
			sub["pad"] = float(sp["pad"]) if first else 0.0
			sub["glue"] = bool(sp["glue"]) if first else not (spaced or t.begins_with(" "))
			var terms: Array = seg["terms"]
			if not terms.is_empty():
				var c := Terms.colour(str(terms[0]))
				sub["font"] = Hud.display_bold()
				sub["ink"] = c
				sub["terms"] = terms
				if icons:
					sub["glyph"] = Terms.glyph(str(terms[0]))
					sub["glyph_ink"] = c
			out.append(sub)
			first = false
			spaced = t.ends_with(" ")
	return out


## Where a line's words start after `n` marks at its head.
static func mark_indent(n: int) -> float:
	return 0.0 if n <= 0 else n * CHIP + (n - 1) * MARK_GAP + (CHIP_INDENT - CHIP)


## A term's icon's width before its word at `px`, the gap after it in.
static func icon_width(px: float) -> float:
	return px * ICON + ICON_GAP


## A gauge: its label, its bar filled to what it holds, then its numbers, a maximum something
## moved coloured with its arrow; returns the bottom. A label longer than the bar's place (the
## gate's Integrity) pushes the bar along.
func _bar(l: Dictionary, y: float) -> float:
	var font := Hud.display()
	var px := 17
	var ascent := font.get_ascent(px)
	var height := ascent + font.get_descent(px)
	var label := str(l.get("label", ""))
	var label_w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	_words.append({"text": label, "font": font, "px": px, "ink": Palette.INK, "at": Vector2(0.0, y + ascent), "top": y, "height": height, "w": label_w, "arrow": 0})
	var bar_x := maxf(BAR_X, label_w + 12.0)
	var top := maxi(1, int(l.get("max", 1)))
	_bars.append({"rect": Rect2(Vector2(bar_x, y + (height - BAR_H) * 0.5), Vector2(BAR_W, BAR_H)), "frac": float(l.get("now", 0)) / float(top), "colour": l.get("colour", Palette.HUD),
		"now": int(l.get("now", 0)), "top": top})
	var numbers := _spans({"style": "effect", "parts": l.get("parts", [])})
	return maxf(_flow(numbers, WIDTH * 4.0, y, bar_x + BAR_W + 12.0), y + height)


## A gauge's line for the unit holds: `label`, what it holds `now` of its maximum `top`, read
## against `own_top`, the maximum as built: a maximum something moved is coloured with its
## arrow (more is the unit's gain, unless `less_is_gain`).
static func bar_line(label: String, now: int, top: int, own_top: int, colour: Color, less_is_gain: bool = false) -> Dictionary:
	var high := num(str(top), top, own_top, less_is_gain)
	high["glue"] = true
	var parts: Array = [word("%d/" % now), high]
	var l := parts_line("bar", parts)
	l["label"] = label
	l["now"] = now
	l["max"] = top
	l["colour"] = colour
	l["text"] = "%s %d/%d" % [label, now, top]
	return l


## A chip's line for the unit holds: its glyph boxed in its colour, then what it says, the name
## before the first colon in bold (no icon of its own beside it: the chip's box is its icon).
static func chip_line(glyph: String, colour: Color, text: String) -> Dictionary:
	var cut := text.find(": ")
	var parts: Array = [_bare(word(text))] if cut < 0 else [{"text": text.substr(0, cut + 1), "trend": 0, "gain": false, "bold": true, "icon": false}, word(text.substr(cut + 2))]
	var l := parts_line("chip", parts)
	l["glyph"] = glyph
	l["colour"] = colour
	l["text"] = text
	return l


## A paragraph of shown text (a passive, a module's line, a term's line in the keywords list),
## its terms highlighted, at `px` in `ink`; with `bold_head`, the name before its first colon in
## bold, as a chip's.
static func prose_line(text: String, px: int = 17, ink: Color = Palette.INK, bold_head: bool = false) -> Dictionary:
	var cut := text.find(": ") if bold_head else -1
	var parts: Array = [word(text)] if cut < 0 else [{"text": text.substr(0, cut + 1), "trend": 0, "gain": false, "bold": true}, word(text.substr(cut + 2))]
	var l := parts_line("prose", parts)
	l["px"] = px
	l["ink"] = ink
	l["text"] = text
	return l


## A term's head (the keywords list's, a tip's): its icon and its name, bold in its colour.
static func term_line(id: String, px: int = 20) -> Dictionary:
	var name := str(Terms.entry(id).get("name", id))
	return {"style": "term", "term": id, "text": name, "parts": [], "place": "", "px": px}


## The width an arrow takes beside a number at `px`.
static func arrow_width(px: float) -> float:
	return ARROW_GAP + px * 0.66


## Lay the spans' words left to right from `y`, wrapping at `width`; returns the bottom. A moved
## number is one word with its arrow.
func _flow(spans: Array, width: float, y: float, indent: float = 0.0) -> float:
	var row: Array = []
	var x := indent
	for sp in spans:
		var font: Font = sp["font"]
		var px: int = sp["px"]
		var space := font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		var words: PackedStringArray = [str(sp["text"])] if int(sp["arrow"]) != 0 else str(sp["text"]).split(" ", false)
		var glyph := str(sp.get("glyph", ""))
		var terms: Array = sp.get("terms", [])
		var first := true
		for w in words:
			var ww := font.get_string_size(w, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
			if int(sp["arrow"]) != 0:
				ww += arrow_width(px)
			var icon := icon_width(px) if first and not glyph.is_empty() else 0.0   # a term's icon before its first word
			ww += icon
			var lead := 0.0 if row.is_empty() or (first and bool(sp["glue"])) else space + (float(sp["pad"]) if first else 0.0)
			if not row.is_empty() and x + lead + ww > width:
				y = _commit(row, y) + LEADING
				row = []
				x = indent
				lead = 0.0
			row.append({"text": w, "font": font, "px": px, "ink": sp["ink"], "x": x + lead, "w": ww, "arrow": sp["arrow"],
				"icon": icon, "glyph": glyph if icon > 0.0 else "", "glyph_ink": sp.get("glyph_ink", sp["ink"]), "terms": terms})
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
		if not (w.get("terms", []) as Array).is_empty():
			_hits.append({"rect": Rect2(Vector2(float(w["x"]), y), Vector2(float(w["w"]), ascent + descent)), "terms": w["terms"]})
	return y + ascent + descent


func _draw() -> void:
	for b in _bars:
		var r: Rect2 = b["rect"]
		draw_rect(r, Color(Palette.BG, 0.9), true)
		draw_rect(Rect2(r.position, Vector2(r.size.x * clampf(float(b["frac"]), 0.0, 1.0), r.size.y)), b["colour"], true)
		draw_rect(r, Color(Palette.HUD, 0.45), false, 1.0)
		Hud.ticks(self, r, int(b["now"]), int(b["top"]), b["colour"])   # the gauge's scale, as the field's bars wear it
	for c in _chips:
		var r: Rect2 = c["rect"]
		if not (c.get("chip", []) as Array).is_empty():
			UnitView.draw_chip(self, r, c["chip"], Hud.mono())   # the field's own chip
		elif not (c.get("passive", []) as Array).is_empty():
			_draw_passive(r, c["passive"], c["colour"])   # the die's passive box, dashed
		elif bool(c.get("box", true)):
			Hud.box(self, r, 3.0, Color(Palette.BG, 0.92), c["colour"], 1.2)
			Glyphs.draw(self, str(c["glyph"]), r.get_center(), 13, c["colour"], 1.7)
		else:
			# Bare, as the die draws its big glyph; the three hexes of whom it reaches across the box.
			var aimed := str(c["glyph"]).begins_with("aim_")
			Glyphs.draw(self, str(c["glyph"]), r.get_center(), r.size.x if aimed else 17.0, c["colour"], 1.4 if aimed else 2.0)
	for w in _words:
		var at: Vector2 = w["at"]
		var icon := float(w.get("icon", 0.0))
		if icon > 0.0:
			# A term's icon, centred on the text's middle as the arrow is, in its colour.
			var px := float(w["px"])
			Glyphs.draw(self, str(w["glyph"]), Vector2(at.x + px * ICON * 0.5, at.y - px * 0.36), px * ICON, w["glyph_ink"], maxf(1.4, px * 0.1))
			at = Vector2(at.x + icon, at.y)
		draw_string(w["font"], at, w["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, w["px"], w["ink"])
		if int(w["arrow"]) != 0:
			draw_arrow(self, Vector2(at.x + float(w["w"]) - icon - arrow_width(float(w["px"])) + ARROW_GAP, at.y), float(w["px"]), int(w["arrow"]), w["ink"])


## The die's passive box at a line's head: a dashed frame, its mark and its number inside.
func _draw_passive(r: Rect2, held: Array, ink: Color) -> void:
	Hud.fill_poly(self, Hud.cut(r, 3.0), Color(Palette.BG, 0.92))
	var frame := Palette.HUD
	var corners := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
	for k in range(4):
		var a: Vector2 = corners[k]
		var b: Vector2 = corners[(k + 1) % 4]
		var step := 6.0 / maxf(1.0, a.distance_to(b))
		var t := 0.0
		while t < 1.0:
			draw_line(a.lerp(b, t), a.lerp(b, minf(1.0, t + step * 0.6)), frame, 1.1)
			t += step
	var mono := Hud.mono()
	var glyph := str(held[0])
	var runs := DieFaceView.passive_runs(held[1], ink)
	var tw := 0.0
	for run in runs:
		tw += DieFaceView.run_width(run, mono, PASSIVE_PX)
	var inner := (13.0 if not glyph.is_empty() else 0.0) + (2.0 if not glyph.is_empty() and tw > 0.0 else 0.0) + tw
	var x := r.get_center().x - inner * 0.5
	if not glyph.is_empty():
		Glyphs.draw(self, glyph, Vector2(x + 6.5, r.get_center().y), 12, ink, 1.6)
		x += 15.0
	for run in runs:
		DieFaceView.draw_run(self, run, Vector2(x, r.get_center().y + mono.get_ascent(PASSIVE_PX) * 0.36), mono, PASSIVE_PX, run[1])
		x += DieFaceView.run_width(run, mono, PASSIVE_PX)


## A stepping die's next chamber as a line (the Cassowary's, Ryan, 4 November: "should also
## explain its next-chamber chip in the tap popup"): where a roll or a reroll steps it, by its
## place and its name, headed by the passive box the die shows it in.
static func next_chamber_line(next: Face, place: int, db: ContentDB) -> Dictionary:
	var named := db.component_name(next.component) if next != null and not next.component.is_empty() else (next.describe() if next != null else "")
	var shown := DieFaceView.next_mark(next)
	return marked(text_line("effect", "A roll or reroll steps it to %s, %s" % [Hud.roman(place), named], "rule"), [passive_mark(str(shown[0]), shown[1], shown[2])])


## The entry a one-of-each die turns to once the one showing is spent (the Needletail's Quick-turn
## Avionics Relay, 11 November), as a line: its place and its name, headed by the passive box
## the die shows it in.
static func turn_line(next: Face, place: int, db: ContentDB) -> Dictionary:
	var named := db.component_name(next.component) if next != null and not next.component.is_empty() else (next.describe() if next != null else "")
	var shown := DieFaceView.next_mark(next)
	return marked(text_line("effect", "Spent, its die turns to %s, %s, and it acts again" % [Hud.roman(place), named], "rule"), [passive_mark(str(shown[0]), shown[1], shown[2])])


## An entry's name as its machine shows it: the name a branch's step gives its piece (the line
## frame's Aile Blitzer), else its component's.
static func entry_name(f: Face, db: ContentDB) -> String:
	return f.renamed if not f.renamed.is_empty() else db.component_name(f.component)


## What its machine's Parry returns on the weapon showing (the Beam Buckler's, Ryan, 19 November:
## "next strike"): the add on its next strike alone, headed by the mark the die's passive box shows.
static func parry_line(n: int) -> Dictionary:
	return marked(text_line("effect", "Parry: its next strike deals %d more" % n, "rule"), [passive_mark("spin", "+%d" % n, Glyphs.colour_for("parry"))])


## The armament its machine's offhand holds, riding the weapon or equipment showing (the line
## frame's, Ryan, 19 November): its name and its line, headed by the star the die's passive box shows.
static func offhand_line(name: String, line: String) -> Dictionary:
	return marked(text_line("effect", "%s: %s" % [name, line], "rule"), [passive_mark("star", "", Glyphs.colour_for("offhand"))])


## The strikes a machine's Ricochet adds to the weapon showing (the Skua's, 12 November), as a
## line headed by the passive box the die shows them in.
static func ricochet_line(stacks: int) -> Dictionary:
	var said := "Ricochet: after it fires it hits its target %d more time%s for 1" % [stacks, "" if stacks == 1 else "s"]
	return marked(text_line("effect", said, "rule"), [passive_mark("ricochet", "+%d" % stacks, Glyphs.colour_for("ricochet"))])


## The shield its machine's zap pays as this weapon fires, and the add it buys (the Buzzard's, 18
## November), headed by the mark the die's passive box shows for it; the number has the add in.
static func zap_line(cost: int, add: int) -> Dictionary:
	var said := "Zap: pays %d shield as it fires, +%d on its every blow" % [cost, add]
	return marked(text_line("effect", said, "rule"), [passive_mark("shield", "-%d" % cost, Palette.SHIELD)])


## The terms under `point`, in the readout's own space; none off them.
func terms_at(point: Vector2) -> Array:
	for h in _hits:
		if (h["rect"] as Rect2).grow(TAP_GROW).has_point(point):
			return h["terms"]
	return []


## The laid-out rect of the term under `point`.
func _hit_rect(point: Vector2) -> Rect2:
	for h in _hits:
		if (h["rect"] as Rect2).grow(TAP_GROW).has_point(point):
			return h["rect"]
	return Rect2(point, Vector2.ZERO)


## Only a term takes a tap here; the rest of the readout lets it through to what lies under it.
func _has_point(point: Vector2) -> bool:
	return not terms_at(point).is_empty()


## A tap on a term opens its tip beside it. In a popup the press is the term's, so the screen
## under it never reads it as a tap on nothing; in a scrolling plate (the codex, the keywords
## list) the press goes on, so a drag that starts on a term still scrolls.
func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton) or (event as InputEventMouseButton).button_index != MOUSE_BUTTON_LEFT:
		return
	var mb := event as InputEventMouseButton
	if mb.pressed:
		_press_at = mb.position
		_press_terms = terms_at(mb.position)
		if not _press_terms.is_empty() and not _in_scroller():
			accept_event()
		return
	if _press_terms.is_empty():
		return
	var ids := _press_terms
	_press_terms = []
	if mb.position.distance_to(_press_at) <= TAP_SLOP:
		accept_event()
		open_tip(ids, _hit_rect(_press_at))


## Open the tip for `ids` beside `rect` (the readout's own space): the tap's way, and the tests'.
func open_tip(ids: Array, rect: Rect2) -> KeywordTip:
	var xf := get_global_transform_with_canvas() if is_inside_tree() else Transform2D.IDENTITY
	return KeywordTip.open(self, ids, xf * rect)


func _in_scroller() -> bool:
	var n := get_parent()
	while n != null:
		if n is ScrollContainer:
			return true
		n = n.get_parent()
	return false


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
	var parts: Array = l.get("parts", [])
	if parts.is_empty():
		return str(l.get("text", ""))
	var out := str(l.get("label", ""))   # a gauge's label before its numbers
	for p in parts:
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
