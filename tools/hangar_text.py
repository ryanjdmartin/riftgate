"""The hangar's Text tab: every text the player reads, as one inventory.

Ryan, 9 November: "I want to start working on all in-game text that the player sees ... I need
to get a strong foothold on content I've written myself, so that you can do a better job of
mimicking my intended writing style for the game when guessing at new entries. The hangar as
is, is difficult to do that in, it's hard to find what is visible in-game, what needs editing,
what's outdated, and compare between entries to ensure style consistency."

A slot is one shown text: an entry's codex, its flavour, a passive's description, a foe move's
line, a term's entry in the keywords list. This file is the one definition of what a slot is,
what kind it is, where the game draws it and whether any screen draws it today; the page
(tools/hangar.html, the Text tab) only lays out what this writes into build/hangar/text.json.

Who wrote a text is the ledger's, docs/hangar/text.json: a slot Ryan signs is his ("ryan": he
wrote it, the corpus a session copies its style from) or accepted ("ok": a session's draft he
passed as it stands); a slot the ledger does not name is a draft. A signature keeps the text
as signed and the mechanics it described, so a slot reads as moved when a session changed his
words, and as stale when the numbers or the rule under them changed and the words did not.
docs/voice.md is the ledger's "ryan" texts laid out by kind and by voice, for a session to
read before it drafts anything shown.

His work on the page waits in the artifact's database (collection "text", one document a
slot: a new text, a mark, a note) until a session folds it in:

    python3 tools/hangar_text.py                    # write build/hangar/text.json, print the counts
    python3 tools/hangar_text.py --check            # check only: every string key classified, the ledger sound
    python3 tools/hangar_text.py --fold DIR --dry   # what the "text" collection (ArtifactData's list, out_dir DIR) would change
    python3 tools/hangar_text.py --fold DIR         # write content/*.json, the ledger and docs/voice.md; print the batch that clears the documents
    python3 tools/hangar_text.py --corpus           # docs/voice.md again, from the ledger

Text the code composes (a status's line in sim/effects.gd, a foe's aim and condition words in
sim/foe.gd) is listed read-only, so it can be seen, compared and noted on; the fold changes no
code. What it does not list at all is said in NOT_LISTED, which the page prints.
"""
import datetime, glob, json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join("build", "hangar", "text.json")
LEDGER = os.path.join("docs", "hangar", "text.json")
CORPUS = os.path.join("docs", "voice.md")
FILES = ["vocabulary", "chassis", "components", "modules", "foes", "factions", "loot"]

# The kinds of shown text, in the order the page lists them: what one is, where the game
# draws it (checked against the code that draws it, 9 November), and what its rows group by.
KINDS = [
    {"id": "term", "label": "Keywords and statuses", "group": "category",
     "what": "A term's entry: the rule as the player reads it.",
     "where": "The keywords list in the pause menu, and the tip a tap on the term opens over any text. A status chip's meaning is this entry."},
    {"id": "chassis_codex", "label": "Chassis codex", "group": "maker",
     "what": "A machine's history, in its maker's voice.",
     "where": "The codex (a double-tap on a machine), under its name and designation."},
    {"id": "chassis_flavour", "label": "Chassis flavour", "group": "maker",
     "what": "An in-world quote about the machine.",
     "where": "The codex, the quote at the foot of a machine's page."},
    {"id": "passive", "label": "Passives", "group": "maker",
     "what": "What a machine's passive does, after its name.",
     "where": "The codex and the quick campaign's hangar: NAME: description."},
    {"id": "component_codex", "label": "Component codex", "group": "maker",
     "what": "One or two lines on a piece of kit.",
     "where": "The die's readout (a tap on a die) and the codex's entry list, under the component's name."},
    {"id": "component_flavour", "label": "Component flavour", "group": "maker",
     "what": "An in-world quote about the piece.",
     "where": ""},
    {"id": "module_text", "label": "Module rules", "group": "maker",
     "what": "What a module does beyond its stat lines.",
     "where": "Wherever a module is listed (the codex's active effects, the hangar's module slots), after its stat lines."},
    {"id": "module_codex", "label": "Module codex", "group": "maker",
     "what": "One or two lines on a module.", "where": ""},
    {"id": "module_flavour", "label": "Module flavour", "group": "maker",
     "what": "An in-world quote about the module.", "where": ""},
    {"id": "foe_codex", "label": "Foe codex", "group": "domain",
     "what": "What a foe is and how it fights.",
     "where": "The codex (a double-tap on a foe or a pack), under its name."},
    {"id": "foe_flavour", "label": "Foe flavour", "group": "domain",
     "what": "An in-world quote about the foe.",
     "where": "The codex, the quote at the foot of a foe's page."},
    {"id": "foe_move", "label": "Foe moves", "group": "domain",
     "what": "One move's line; {damage} and {value} are filled with its numbers.",
     "where": "The foe's codex, under the move's name, and the readout of its intent."},
    {"id": "domain_flavour", "label": "Domain flavour", "group": "domain",
     "what": "An in-world quote about a domain.", "where": ""},
    {"id": "loot_codex", "label": "Caches", "group": "",
     "what": "A line on a cache lying on the field.",
     "where": "The readout a tap on a cache opens, after its likely contents."},
    {"id": "title", "label": "Titles", "group": "owner",
     "what": "A designation, a passive's name, a move's name: the short names that are not an entry's own.",
     "where": "Beside the text they head: a machine's designation under its name, a passive's name before its description, a move's name over its line and on the plaque when it lands."},
    {"id": "status_line", "label": "Status lines (in code)", "group": "",
     "what": "A status's one-line description, written in sim/effects.gd.",
     "where": "Only the codex's KEPT FOR THE BATTLE row, for a status a battle keeps (the Ammit's Souls). Since 2 November a chip says its name and count and a tap opens the term's entry, so nothing else draws these."},
    {"id": "intent_words", "label": "Aims and conditions (in code)", "group": "",
     "what": "How a foe's aim and a move's condition are said, written in sim/foe.gd.",
     "where": "A foe's codex: its sense (AIMS AT THE EXPOSED) and the condition after a move's name (when below half)."},
]

# What the page says it does not carry, so the gap is seen and not guessed at.
NOT_LISTED = [
    "An entry's own name (a machine, a component, a foe, a term): a rename moves ids, models and records, so it is asked for in chat or on the Names tab.",
    "Lines the code composes from numbers: a component's effect lines and a passive's generic wording (sim/effects.gd's effect_text, sim/face.gd), a chip's readout (Buff, Empowered +2), the battle log, the warning bands, the map's readouts.",
    "Screen furniture: buttons, headings, the pause menu, the harness and the quick campaign's screens.",
    "Jenny's lines (art/audio/voice/lines.json): each is a rendered sound, so a new line is a soundforge run.",
    "A maker's style and voice (content/chassis.json's makers): the guide each row shows above its group, never drawn in the game.",
]

# Every string an entry may hold at its top level that is no shown text: ids, enums and names.
# A key outside this and the slot table fails the check, so a new text key is classified here
# or given a slot before the page can lose sight of it.
OTHER_KEYS = {
    "vocabulary.entries": {"id", "category", "name", "status"},
    "chassis.entries": {"id", "name", "maker", "size", "status"},
    "chassis.makers": {"id", "name", "style", "voice", "sponsorship"},
    "components.entries": {"id", "name", "maker", "shape", "sound", "status"},
    "modules.entries": {"id", "name", "maker"},
    "foes.entries": {"id", "name", "faction", "rank", "aim", "promotes", "guard", "role"},   # role: a pusher's, a hunter's or a flanker's (10 November), read by the validator and never shown
    "factions.entries": {"id", "name", "bleed", "reward_bias"},
    "loot.entries": {"id", "name"},
}
SLOT_KEYS = {
    "vocabulary.entries": {"codex"},
    "chassis.entries": {"codex", "flavour", "designation"},
    "chassis.makers": set(),
    "components.entries": {"codex", "flavour"},
    "modules.entries": {"codex", "flavour"},
    "foes.entries": {"codex", "flavour"},
    "factions.entries": {"flavour"},
    "loot.entries": {"codex"},
}


def read(rel):
    return open(os.path.join(ROOT, rel), encoding="utf-8").read()


def load(name):
    return json.loads(read("content/%s.json" % name))


def canon(x):
    """One spelling of a piece of content, for telling whether it moved."""
    return json.dumps(x, sort_keys=True, ensure_ascii=False, separators=(",", ":"))


def slot_id(key, entry, path):
    return "%s/%s/%s" % (key, entry, path)


def doc_id(sid):
    """A slot's document in the page's database: its id with the slashes doubled to underscores."""
    return sid.replace("/", "__")


def glossary_shape():
    """The categories the keywords list shows (PauseMenu.GLOSSARY) and the terms with a row in
    Terms.TABLE, the two things that decide whether a term's entry is ever opened."""
    g = re.search(r"^const GLOSSARY := (\[.*\])\s*$", read("game/ui/pause_menu.gd"), re.M)
    cats = [c[0] for c in json.loads(g.group(1))]
    t = re.search(r"^const TABLE := \{\n(.*?)^\}", read("game/ui/terms.gd"), re.M | re.S)
    terms = set(re.findall(r'"([a-z0-9_]+)": \[', t.group(1)))
    return cats, terms


def effect_words(effects):
    """A passive's or a module's effects in the engine's own words, one clause each."""
    out = []
    for e in effects or []:
        rest = ", ".join("%s %s" % (k, canon(v) if isinstance(v, (list, dict)) else v) for k, v in e.items() if k not in ("trigger", "effect"))
        out.append("%s: %s%s" % (e.get("trigger", "?"), e.get("effect", "?"), " (" + rest + ")" if rest else ""))
    return "; ".join(out)


def face_words(face):
    """A component's die entry in a line: its kind, its number, its heat, its reach and the rest."""
    if not isinstance(face, dict):
        return ""
    bits = [str(face.get("kind", ""))]
    if "power" in face:
        bits.append("%s to %s" % (face["power"], face["power_max"]) if "power_max" in face else str(face["power"]))
    for k in ("shield", "vents"):
        if k in face:
            bits.append("%s %s" % (k, face[k]))
    if "heat" in face:
        bits.append("heat %s" % face["heat"])
    if face.get("reach"):
        bits.append(str(face["reach"]))
    for kw in face.get("keywords", []) or []:
        bits.append("%s %s" % (kw, face[kw]) if kw in face and not isinstance(face[kw], (dict, list)) else str(kw))
    skip = {"kind", "power", "power_max", "shield", "vents", "heat", "reach", "keywords"} | set(face.get("keywords", []) or [])
    for k, v in face.items():
        if k not in skip:
            bits.append("%s %s" % (k, canon(v) if isinstance(v, (list, dict)) else v))
    return ", ".join(b for b in bits if b)


def move_words(a):
    """A foe's move in a line: its kind and everything the engine reads off it."""
    bits = [str(a.get("kind", ""))]
    for k, v in a.items():
        if k in ("id", "name", "text", "kind", "status"):
            continue
        bits.append("%s %s" % (k, canon(v) if isinstance(v, (list, dict)) else v))
    return ", ".join(bits)


def dealt_foes(foes, factions):
    """Every foe something sends: a composition's grid, a boss list, a bench, a summon, a split,
    a core's parts, a hero's promoted form. A foe outside it is written and never met."""
    seen = set()
    for f in factions:
        for c in f.get("compositions", []):
            for cell in list(c.get("front", [])) + list(c.get("back", [])):
                if cell:
                    seen.add(cell)
            if c.get("boss"):
                seen.add(c["boss"])
        seen.update(f.get("boss", []))
        seen.update(f.get("bench", []))
    grew = True
    while grew:
        grew = False
        for e in foes:
            if e["id"] not in seen and not (e.get("promotes") in seen):
                continue
            more = set([e["id"]])
            for a in e.get("actions", []):
                more.update(a["foe"] if isinstance(a.get("foe"), list) else [a["foe"]] if a.get("foe") else [])
            if isinstance(e.get("on_death"), dict) and e["on_death"].get("summon"):
                more.add(e["on_death"]["summon"])
            more.update(e.get("parts", []) or [])
            if not more <= seen:
                seen |= more
                grew = True
    return seen


def content_slots():
    """Every shown text content holds, in content's order. Returns (slots, groups, problems)."""
    slots, problems = [], []
    docs = {n: load(n) for n in FILES}
    cats, terms = glossary_shape()
    makers = {m["id"]: m for m in docs["chassis"]["makers"]}
    domains = {f["id"]: f for f in docs["factions"]["entries"]}
    comps = {c["id"]: c for c in docs["components"]["entries"]}
    foes = {f["id"]: f for f in docs["foes"]["entries"]}
    cat_names = {c: c.replace("_", " ") for c in docs["vocabulary"].get("categories", [])}
    groups = {}
    for m in makers.values():
        groups["maker:" + m["id"]] = {"label": m["name"], "voice": m.get("voice", ""), "style": m.get("style", "")}
    for d in domains.values():
        groups["domain:" + d["id"]] = {"label": d["name"], "voice": "", "style": d.get("design", {}).get("fantasy", "")}
    for c, label in cat_names.items():
        groups["category:" + c] = {"label": label[:1].upper() + label[1:], "voice": "", "style": ""}

    def add(key, entry, path, kind, text, name, group, **more):
        if not isinstance(text, str):
            problems.append("%s: not a string" % slot_id(key, entry, path))
            return
        s = {"id": slot_id(key, entry, path), "key": key, "entry": entry, "path": path, "kind": kind, "name": name,
             "group": group, "text": text, "shown": True, "why": "", "sub": "", "facts": "", "pitch": "", "mech": "", "edit": True}
        s.update(more)
        slots.append(s)

    def classify(key, e):
        for k, v in e.items():
            if isinstance(v, str) and k not in OTHER_KEYS[key] and k not in SLOT_KEYS[key]:
                problems.append("%s/%s: the key \"%s\" holds text the Text tab does not know; give it a slot or list it in OTHER_KEYS (tools/hangar_text.py)" % (key, e.get("id"), k))

    # The vocabulary: a term's entry.
    for e in docs["vocabulary"]["entries"]:
        classify("vocabulary.entries", e)
        cat, st = e.get("category", ""), e.get("status", "")
        shown, why = True, ""
        if st != "implemented":
            shown, why = False, "%s: the engine does not run it, so the list leaves it out" % st
        elif cat not in cats:
            shown, why = False, "the rules' reference only: the keywords list shows no %s terms, so no screen opens this entry (docs/vocabulary.md and the bible's tables read it)" % cat_names.get(cat, cat)
        elif cat == "foe" and e["id"] not in terms:
            shown, why = False, "the engine's word: of the foes' terms the list shows only the keywords a move carries"
        add("vocabulary.entries", e["id"], "codex", "term", e.get("codex", ""), e.get("name", e["id"]), "category:" + cat,
            shown=shown, why=why, facts=cat_names.get(cat, cat), pitch=str(e.get("design", {}).get("holes", "")))

    # The makers' guides hold no slot; the check still reads their keys.
    for m in docs["chassis"]["makers"]:
        classify("chassis.makers", m)

    def passive_slots(key, e, group, shown, why, owner):
        p = e.get("passive")
        if not isinstance(p, dict):
            return
        planned = p.get("status") == "planned"
        sh, wy = (False, "planned: the engine does not run this passive yet") if planned else (shown, why)
        mech = canon(p.get("effects", []))
        add(key, e["id"], "passive.name", "title", p.get("name", ""), owner, group, shown=sh, why=wy, sub="passive", facts=p.get("description", ""))
        add(key, e["id"], "passive.description", "passive", p.get("description", ""), owner, group, shown=sh, why=wy,
            sub=p.get("name", ""), facts=effect_words(p.get("effects")), mech=mech)

    # Chassis.
    for e in docs["chassis"]["entries"]:
        classify("chassis.entries", e)
        g = "maker:" + str(e.get("maker", ""))
        p = e.get("passive")
        runnable = not (isinstance(p, dict) and p.get("status") == "planned") and all(comps.get(c, {}).get("status") != "planned" for c in e.get("fixed", []))
        shown, why = (True, "") if runnable else (False, "planned: the machine cannot be fielded yet")
        facts = ", ".join(str(x) for x in [e.get("designation", ""), e.get("size", ""), " ".join(e.get("traits", [])), "tier %s" % e.get("tier", "?")] if x)
        pitch = str(e.get("design", {}).get("fantasy", ""))
        add("chassis.entries", e["id"], "codex", "chassis_codex", e.get("codex", ""), e["name"], g, shown=shown, why=why, facts=facts, pitch=pitch)
        add("chassis.entries", e["id"], "flavour", "chassis_flavour", e.get("flavour", ""), e["name"], g, shown=shown, why=why, facts=facts, pitch=pitch)
        add("chassis.entries", e["id"], "designation", "title", e.get("designation", ""), e["name"], g, shown=shown, why=why, sub="designation", facts=pitch)
        passive_slots("chassis.entries", e, g, shown, why, e["name"])

    # Components.
    for e in docs["components"]["entries"]:
        classify("components.entries", e)
        g = "maker:" + str(e.get("maker", ""))
        shown, why = (False, "planned: the engine cannot run this piece yet") if e.get("status") == "planned" else (True, "")
        facts, pitch = face_words(e.get("face")) + (" · " + " ".join(e.get("tags", [])) if e.get("tags") else ""), str(e.get("design", {}).get("fantasy", ""))
        add("components.entries", e["id"], "codex", "component_codex", e.get("codex", ""), e["name"], g, shown=shown, why=why,
            facts=facts, pitch=pitch, mech=canon({"face": e.get("face"), "passive": (e.get("passive") or {}).get("effects") if isinstance(e.get("passive"), dict) else None}))
        add("components.entries", e["id"], "flavour", "component_flavour", e.get("flavour", ""), e["name"], g, shown=False,
            why="no screen draws a component's flavour yet: the die's readout shows its codex alone", facts=facts, pitch=pitch)
        passive_slots("components.entries", e, g, shown, why, e["name"])

    # Modules.
    for e in docs["modules"]["entries"]:
        classify("modules.entries", e)
        g = "maker:" + str(e.get("maker", ""))
        stats = ", ".join("%s %+d" % (k, v) for k, v in (e.get("stats") or {}).items())
        t = e.get("text")
        pitch = str(e.get("design", {}).get("fantasy", ""))
        if isinstance(t, dict):
            planned = t.get("status", "implemented") != "implemented"
            add("modules.entries", e["id"], "text.description", "module_text", t.get("description", ""), e["name"], g,
                shown=not planned, why="planned: the engine does not run this rule yet, so only the stat lines show" if planned else "",
                facts="; ".join(x for x in [stats, effect_words(t.get("effects"))] if x), pitch=pitch,
                mech=canon({"stats": e.get("stats"), "effects": t.get("effects")}))
        for path, kind in (("codex", "module_codex"), ("flavour", "module_flavour")):
            add("modules.entries", e["id"], path, kind, e.get(path, ""), e["name"], g, shown=False,
                why="no screen draws a module's %s yet: a module shows its name, its stat lines and its rule" % path,
                facts="; ".join(x for x in [stats, t.get("description", "") if isinstance(t, dict) else ""] if x), pitch=pitch)

    # Foes.
    dealt = dealt_foes(docs["foes"]["entries"], docs["factions"]["entries"])
    for e in docs["foes"]["entries"]:
        classify("foes.entries", e)
        hero = foes.get(e.get("promotes", ""), {})
        name = e.get("name") or (hero.get("name", e["id"]) + ", promoted")
        g = "domain:" + str(e.get("faction", hero.get("faction", "")))
        met = e["id"] in dealt
        shown, why = (True, "") if met else (False, "nothing deals it: no composition, boss list, bench or summon names this foe")
        kind_words = ", ".join(x for x in ["boss" if e.get("boss") else "", "elite" if e.get("elite") else "", "hero" if e.get("hero") else "",
                                            "massive" if e.get("size") == 2 else "", "%s rank" % e.get("rank", ""), "HP %s" % e.get("hp", "?"),
                                            "attack %s" % e["attack"] if "attack" in e else "", "tier %s" % e["tier"] if "tier" in e else ""] if x)
        pitch = str(e.get("design", {}).get("fantasy", ""))
        for path, kind in (("codex", "foe_codex"), ("flavour", "foe_flavour")):
            if path in e:
                add("foes.entries", e["id"], path, kind, e[path], name, g, shown=shown, why=why, facts=kind_words, pitch=pitch)
        for a in e.get("actions", []):
            if "__" in str(a.get("id", "")) or "/" in str(a.get("id", "")):
                problems.append("foes.entries/%s: the move id \"%s\" would break a slot's id" % (e["id"], a.get("id")))
            planned = a.get("status") != "implemented"
            sh, wy = (False, "planned: the engine does not run this move, so the codex leaves it out") if planned else (shown, why)
            mech = canon({k: v for k, v in a.items() if k not in ("id", "name", "text", "status")})
            add("foes.entries", e["id"], "actions.%s.name" % a["id"], "title", a.get("name", ""), name, g, shown=sh, why=wy, sub="move", facts=a.get("text", ""))
            add("foes.entries", e["id"], "actions.%s.text" % a["id"], "foe_move", a.get("text", ""), name, g, shown=sh, why=wy,
                sub=a.get("name", ""), facts=move_words(a), mech=mech)
        # A fall: a last act's blow, or one special in its place (16 November), either with steps.
        for key in ("blow", "act"):
            blow = e.get("on_death", {}).get(key) if isinstance(e.get("on_death"), dict) else None
            if isinstance(blow, dict):
                mech = canon({k: v for k, v in blow.items() if k not in ("name", "text")})
                if "name" in blow:
                    add("foes.entries", e["id"], "on_death.%s.name" % key, "title", blow["name"], name, g, shown=shown, why=why, sub="last act", facts=blow.get("text", ""))
                if "text" in blow:
                    add("foes.entries", e["id"], "on_death.%s.text" % key, "foe_move", blow["text"], name, g, shown=shown, why=why,
                        sub=blow.get("name", "last act"), facts="last act, " + move_words(blow), mech=mech)

    # Domains and caches.
    for e in docs["factions"]["entries"]:
        classify("factions.entries", e)
        add("factions.entries", e["id"], "flavour", "domain_flavour", e.get("flavour", ""), e["name"], "domain:" + e["id"], shown=False,
            why="no screen draws a domain's flavour yet", pitch=str(e.get("design", {}).get("fantasy", "")),
            facts=str(e.get("design", {}).get("signature", "")))
    for e in docs["loot"]["entries"]:
        classify("loot.entries", e)
        add("loot.entries", e["id"], "codex", "loot_codex", e.get("codex", ""), e["name"], "", facts="tier %s, salvage %s to %s" % (e.get("tier"), *e.get("salvage", ["?", "?"])),
            pitch=str(e.get("design", {}).get("holes", "")))
    return slots, groups, problems


def gd_string(s):
    """A GDScript string literal's inside, as text."""
    return s.replace('\\"', '"').replace("\\\\", "\\")


def code_slots():
    """The shown text two tables in the code hold, read-only: a status's line and a foe's aim
    and condition words. A table that moves or changes shape is a problem, never a silent gap."""
    slots, problems = [], []
    src = read("sim/effects.gd")
    block = re.search(r"^const STATUS := \{\n(.*?)^\}", src, re.M | re.S)
    rows = re.findall(r'^\t"([a-z0-9_]+)": \{"id": "\1", "name": "((?:[^"\\]|\\.)*)", "description": "((?:[^"\\]|\\.)*)"(.*)$', block.group(1) if block else "", re.M)
    if len(rows) < 30:
        problems.append("sim/effects.gd: STATUS no longer reads as a table of {id, name, description} lines (%d found); mend code_slots in tools/hangar_text.py" % len(rows))
    for sid, name, desc, rest in rows:
        slots.append({"id": slot_id("code.status", sid, "description"), "key": "code.status", "entry": sid, "path": "description", "kind": "status_line",
                      "name": gd_string(name), "group": "", "text": gd_string(desc), "shown": False,
                      "why": "drawn only in the codex's KEPT FOR THE BATTLE row; a chip's meaning is its term's entry (Keywords and statuses)",
                      "sub": "", "facts": "sim/effects.gd, STATUS[\"%s\"]" % sid, "pitch": "", "mech": "", "edit": False})
    foe = read("sim/foe.gd")
    for const, key, label in (("AIM_TEXT", "code.aim", "aim"), ("WHEN_TEXT", "code.when", "condition")):
        b = re.search(r"^const %s := \{\n(.*?)^\}" % const, foe, re.M | re.S)
        pairs = re.findall(r'"([a-z0-9_]+)": "((?:[^"\\]|\\.)*)"', b.group(1) if b else "")
        if not pairs:
            problems.append("sim/foe.gd: %s no longer reads as a table of words; mend code_slots in tools/hangar_text.py" % const)
        for k, v in pairs:
            slots.append({"id": slot_id(key, k, "text"), "key": key, "entry": k, "path": "text", "kind": "intent_words", "name": k.replace("_", " "),
                          "group": "", "text": gd_string(v), "shown": True, "why": "", "sub": label, "facts": "sim/foe.gd, %s[\"%s\"]" % (const, k),
                          "pitch": "", "mech": "", "edit": False})
    return slots, problems


# The words CLAUDE.md keeps out of shown text, and what a line may hold in braces.
def lints(s, planned_terms):
    out = []
    t = s["text"]
    if not t:
        return out
    # A foe has a face of its own; the word is the die's only on our side of the field.
    if not s["kind"].startswith(("foe_", "domain_")) and not (s["kind"] == "title" and s["key"] == "foes.entries") and re.search(r"\b(?:a|the|its|each|every|per|this|that|same|another|one|any|whose|which|blank|rolled) (?:\w+ )?face\b|\bfaces (?:on|of|that|which|are|is|show|roll)\b", t, re.I):
        out.append("says \"face\": the player sees no polyhedron, an entry is a component or an entry")
    if re.search(r"damaging weapon", t, re.I):
        out.append("says \"damaging weapon\": a weapon deals damage by definition")
    allowed = {"damage", "value"} if s["kind"] in ("foe_move", "status_line", "passive", "module_text") else set()
    for b in re.findall(r"\{([a-z_]+)\}", t):
        if b not in allowed:
            out.append("{%s} is filled by nothing here" % b)
    if t != t.strip() or "  " in t:
        out.append("stray spaces")
    if s["kind"] != "term":
        for name in planned_terms:
            if re.search(r"(?<![A-Za-z])%s(?![A-Za-z])" % re.escape(name), t):
                out.append("names %s, a term the engine does not run yet" % name)
    return out


def load_ledger():
    p = os.path.join(ROOT, LEDGER)
    if not os.path.exists(p):
        return {"signed": {}}
    return json.load(open(p, encoding="utf-8"))


LEDGER_ABOUT = ("Who wrote each shown text (tools/hangar_text.py; the hangar's Text tab). signed: a slot's id -> by (\"ryan\": Ryan wrote it, "
                "the corpus docs/voice.md is drawn from; \"ok\": a session's draft he accepted as it stands), text (as he signed it), mech (the "
                "mechanics it described then) and on (the day). A slot not named here is a draft. Written by the fold alone, from his marks on "
                "the page: a session never signs a text for him, and one that changes a signed text leaves the signature as it is, so the page "
                "shows him the change.")


def save_ledger(ledger):
    signed = {k: ledger["signed"][k] for k in sorted(ledger["signed"])}
    with open(os.path.join(ROOT, LEDGER), "w", encoding="utf-8") as f:
        json.dump({"_about": LEDGER_ABOUT, "signed": signed}, f, indent=1, ensure_ascii=False)
        f.write("\n")


def stamp():
    import subprocess
    try:
        head = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT, capture_output=True, text=True).stdout.strip()
        dirty = subprocess.run(["git", "status", "--porcelain", "--", "content", "sim", LEDGER], cwd=ROOT, capture_output=True, text=True).stdout.strip()
        return head + ("+edits" if dirty else "")
    except OSError:
        return "unknown"


def inventory():
    """Every slot with its signature laid on: (slots, groups, problems)."""
    slots, groups, problems = content_slots()
    more, p2 = code_slots()
    slots += more
    problems += p2
    ids = [s["id"] for s in slots]
    if len(set(ids)) != len(ids):
        problems.append("two slots share an id: " + ", ".join(sorted(set(i for i in ids if ids.count(i) > 1))[:5]))
    ledger = load_ledger()
    by_id = {s["id"]: s for s in slots}
    for sid, sig in ledger["signed"].items():
        if sid not in by_id:
            problems.append("%s: the ledger signs a slot that is gone (%s); a rename moves its ledger line with it (%s)" % (LEDGER, sid, "python3 tools/hangar_text.py --check"))
        elif sig.get("by") not in ("ryan", "ok") or not isinstance(sig.get("text"), str):
            problems.append("%s: %s is not a signature (by ryan or ok, with its text)" % (LEDGER, sid))
    vocab = load("vocabulary")["entries"]
    live_names = {e["name"] for e in vocab if e.get("status") == "implemented"}
    planned = sorted({e["name"] for e in vocab if e.get("status") != "implemented" and e.get("name") and e["name"] not in live_names and len(e["name"]) > 3})
    for s in slots:
        sig = ledger["signed"].get(s["id"])
        s["by"] = sig["by"] if sig else ""
        s["on"] = sig.get("on", "") if sig else ""
        # His words as he signed them, kept only where a session has since changed them.
        s["signed"] = sig["text"] if sig and sig["text"] != s["text"] else None
        s["mech_was"] = sig.get("mech", "") if sig and sig.get("mech", "") != s["mech"] else None
        s["lints"] = lints(s, planned)
    return slots, groups, problems


def build(check_only=False):
    slots, groups, problems = inventory()
    if not check_only and not problems:
        os.makedirs(os.path.dirname(os.path.join(ROOT, OUT)), exist_ok=True)
        with open(os.path.join(ROOT, OUT), "w", encoding="utf-8") as f:
            json.dump({"_about": "Every shown text as the hangar's Text tab reads it, written by tools/hangar_text.py: the kinds, the groups (a maker's voice, a domain, a category) and one slot a text, its signature from docs/hangar/text.json laid on.",
                       "stamp": stamp(), "kinds": KINDS, "groups": groups, "not_listed": NOT_LISTED, "slots": slots}, f, ensure_ascii=False, separators=(",", ":"))
    return slots, groups, problems


def state_of(s):
    if s["by"]:
        if s["signed"] is not None:
            return "moved"
        if s["mech_was"] is not None:
            return "stale"
        return "yours" if s["by"] == "ryan" else "passed"
    return "draft" if s["text"] else "empty"


def counts(slots):
    kinds = {k["id"]: k for k in KINDS}
    order = ["yours", "passed", "moved", "stale", "draft", "empty"]
    rows = {}
    for s in slots:
        r = rows.setdefault(s["kind"], {"shown": dict.fromkeys(order, 0), "unshown": dict.fromkeys(order, 0)})
        r["shown" if s["shown"] else "unshown"][state_of(s)] += 1
    w = max(len(k["label"]) for k in KINDS)
    print("%-*s  %s   not drawn yet" % (w, "shown in game", "  ".join("%6s" % o for o in order)))
    for k in KINDS:
        r = rows.get(k["id"])
        if r:
            print("%-*s  %s   %d" % (w, kinds[k["id"]]["label"], "  ".join("%6d" % r["shown"][o] for o in order), sum(r["unshown"].values())))
    flagged = [s for s in slots if s["lints"]]
    if flagged:
        print("%d slot%s with a flag:" % (len(flagged), "" if len(flagged) == 1 else "s"))
        for s in flagged[:40]:
            print("  %s: %s" % (s["id"], "; ".join(s["lints"])))


# ------------------------------------------------------------------ the corpus
def write_corpus(slots):
    """docs/voice.md: Ryan's own texts by kind and by voice, as he signed them."""
    kinds = {k["id"]: k for k in KINDS}
    _s, groups, _p = content_slots()
    mine = [s for s in slots if s["by"] == "ryan"]
    out = ["# Ryan's voice", "",
           "Generated by `tools/hangar_text.py` from `docs/hangar/text.json`: every shown text Ryan has signed",
           "as his own on the hangar's Text tab, as he signed it, by kind and by voice. Read the kind you are",
           "about to draft, and its maker's or domain's group first, before writing any shown text; a draft is",
           "written to sit beside these and is never signed for him. A text he only passed (a session's draft",
           "accepted as it stands) is not here: it is fit to ship, not his hand.", ""]
    if not mine:
        out += ["Nothing signed yet.", ""]
    for k in KINDS:
        rows = [s for s in mine if s["kind"] == k["id"]]
        if not rows:
            continue
        out += ["## %s" % k["label"], "", k["what"] + (" " + k["where"] if k["where"] else ""), ""]
        seen = []
        for s in rows:
            if s["group"] not in seen:
                seen.append(s["group"])
        for g in seen:
            info = groups.get(g, {})
            if g:
                out += ["### %s" % info.get("label", g), ""]
                if info.get("voice"):
                    out += ["Voice: %s" % info["voice"], ""]
            for s in [r for r in rows if r["group"] == g]:
                text = s["signed"] if s["signed"] is not None else s["text"]
                head = s["name"] + (", " + s["sub"] if s["sub"] else "")
                out += ["- **%s**%s: %s" % (head, " (changed by a session since)" if s["signed"] is not None else "", " ".join(text.split()))]
            out += [""]
    with open(os.path.join(ROOT, CORPUS), "w", encoding="utf-8") as f:
        f.write("\n".join(out).rstrip("\n") + "\n")
    return len(mine)


# ------------------------------------------------------------------ the fold
MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


def load_inbox(path):
    """The page's documents as ArtifactData's list saved them (a file each, or one list)."""
    paths = sorted(glob.glob(os.path.join(path, "**", "*.json"), recursive=True)) if os.path.isdir(path) else [path]
    out = []
    for p in paths:
        j = json.load(open(p, encoding="utf-8"))
        if isinstance(j, dict) and isinstance(j.get("documents", j.get("docs")), list):
            j = j.get("documents", j.get("docs"))
        items = j if isinstance(j, list) else [j]
        for it in items:
            if not isinstance(it, dict):
                continue
            data = it["data"] if isinstance(it.get("data"), dict) and "slot" not in it else it
            nid = it.get("id") or it.get("doc_id") or (os.path.splitext(os.path.basename(p))[0] if len(items) == 1 else None)
            out.append(dict(data, id=nid, version=it.get("version", data.get("version"))))
    return [n for n in out if n.get("slot")]


def get_at(entry, path):
    """A slot's value inside its entry: a dotted path, a foe's move by its id."""
    parts = path.split(".")
    node = entry
    k = 0
    while k < len(parts):
        if parts[k] == "actions" and isinstance(node, dict) and isinstance(node.get("actions"), list):
            node = next((a for a in node["actions"] if a.get("id") == parts[k + 1]), None)
            k += 2
        else:
            node = node.get(parts[k]) if isinstance(node, dict) else None
            k += 1
        if node is None:
            return None
    return node


def set_at(entry, path, value):
    parts = path.split(".")
    node = entry
    k = 0
    while k < len(parts) - 1:
        if parts[k] == "actions":
            node = next(a for a in node["actions"] if a.get("id") == parts[k + 1])
            k += 2
        else:
            node = node[parts[k]]
            k += 1
    node[parts[-1]] = value


def replace_in_file(raw, key, entry_id, path, old, new):
    """The file's text with one slot's string replaced and nothing else moved: content is laid out
    by hand in places, so the literal is swapped where it stands, and the result is read back and
    held to the one change. Returns the new text, or None when no spot gives exactly that change."""
    fname, lname = key.split(".")
    want = json.loads(raw)
    target = next((e for e in want[lname] if e.get("id") == entry_id), None)
    if target is None or get_at(target, path) != old:
        return None
    set_at(target, path, new)
    field = path.split(".")[-1]
    lit = lambda s: json.dumps(s, ensure_ascii=False)
    for old_lit in {lit(old), json.dumps(old)}:
        for m in re.finditer(r'"%s":\s*%s' % (re.escape(field), re.escape(old_lit)), raw):
            cand = raw[:m.start()] + m.group(0)[:len(m.group(0)) - len(old_lit)] + lit(new) + raw[m.end():]
            try:
                if json.loads(cand) == want:
                    return cand
            except ValueError:
                pass
    return None


def day_of(n):
    if n.get("day"):
        return n["day"]
    m = re.match(r"(\d{4})-(\d\d)-(\d\d)", n.get("updated") or "")
    return "%d %s" % (int(m.group(3)), MONTHS[int(m.group(2)) - 1]) if m else "undated"


def fold(path, dry=False):
    """Lay the page's documents onto content and the ledger. Returns (done, held, notes): done the
    documents fully landed, held those that could not land and why, notes his words for a session."""
    slots, _g, problems = inventory()
    if problems:
        sys.exit("\n".join(problems))
    by_id = {s["id"]: s for s in slots}
    ledger = load_ledger()
    raws = {n: read("content/%s.json" % n) for n in FILES}
    done, held, notes = [], [], []
    for n in load_inbox(path):
        s = by_id.get(n["slot"])
        if s is None:
            held.append((n, "no such slot now (renamed or removed since he wrote it)"))
            continue
        text = n.get("text")
        said = []
        if isinstance(text, str) and text != s["text"]:
            if not s["edit"]:
                held.append((n, "the text is the code's (%s): change it there by hand, with its tests" % s["facts"]))
                continue
            fname = s["key"].split(".")[0]
            new_raw = replace_in_file(raws[fname], s["key"], s["entry"], s["path"], s["text"], text)
            if new_raw is None:
                held.append((n, "could not place the change in content/%s.json; apply it by hand" % fname))
                continue
            if isinstance(n.get("base"), str) and n["base"] != s["text"]:
                said.append("a session had changed it since he read it (he read: %s)" % json.dumps(n["base"], ensure_ascii=False))
            raws[fname] = new_raw
            s["text"] = text
            said.append("text")
        mark = n.get("mark", "")
        if mark in ("ryan", "ok"):
            # The mechanics as the page showed them to him, so a change since reads as stale.
            ledger["signed"][s["id"]] = {"by": mark, "text": s["text"], "mech": n.get("mech", s["mech"]) if not said else s["mech"], "on": day_of(n)}
            said.append("signed his" if mark == "ryan" else "passed")
        elif mark == "draft":
            if ledger["signed"].pop(s["id"], None) is not None:
                said.append("unsigned")
        elif said and s["id"] in ledger["signed"]:
            # His own change to a text he had signed, with no new mark: the signature follows it.
            ledger["signed"][s["id"]].update(text=s["text"], mech=s["mech"], on=day_of(n))
        if n.get("note"):
            notes.append((n, s))
        n["did"] = ", ".join(said) or ("nothing to land" if not n.get("note") else "note")
        # A note is a session's task: its document stays until the session has answered it.
        (held if n.get("note") else done).append((n, "its note waits for a session") if n.get("note") else n)
    if not dry:
        for fname, raw in raws.items():
            if raw != read("content/%s.json" % fname):
                open(os.path.join(ROOT, "content", "%s.json" % fname), "w", encoding="utf-8").write(raw)
        save_ledger(ledger)
        slots, _g, problems = inventory()
        if problems:
            sys.exit("after the fold:\n" + "\n".join(problems))
        write_corpus(slots)
    return done, held, notes


def fold_main(path, dry):
    done, held, notes = fold(path, dry)
    print("%s %d:" % ("would fold" if dry else "folded", len(done)))
    for n in done:
        print("  %s: %s" % (n["slot"], n["did"]))
    if held:
        print("held %d (each stays on the page):" % len(held))
        for n, why in held:
            print("  %s: %s%s" % (n["slot"], why, " (%s)" % n["did"] if n.get("did") and n["did"] != "note" else ""))
    if notes:
        print("his notes %d (answer each in the work, then clear its document):" % len(notes))
        for n, s in notes:
            print("  %s [%s, %s]: %s" % (n["slot"], s["name"] + (", " + s["sub"] if s["sub"] else ""), day_of(n), " ".join(str(n["note"]).split())))
    if done and not dry:
        writes = [dict({"op": "delete", "collection": "text", "doc_id": n["id"]}, **({"if_version": n["version"]} if n.get("version") else {})) for n in done]
        print("clear the folded with ArtifactData batch, writes:")
        print(json.dumps(writes))
        print("then: git diff content docs/hangar/text.json docs/voice.md, the tests, python3 tools/hangar_data.py, commit, republish the hangar")


def main():
    if "--fold" in sys.argv:
        k = sys.argv.index("--fold")
        if k + 1 >= len(sys.argv):
            sys.exit("--fold wants the folder ArtifactData's list wrote the text collection to")
        fold_main(sys.argv[k + 1], "--dry" in sys.argv)
        return
    check_only = "--check" in sys.argv
    slots, _groups, problems = build(check_only)
    if problems:
        print("\n".join(problems), file=sys.stderr)
        sys.exit(1)
    if "--corpus" in sys.argv:
        print("%d of his texts in %s" % (write_corpus(slots), CORPUS))
        return
    counts(slots)
    print("%d slots%s" % (len(slots), "" if check_only else " in " + OUT))


if __name__ == "__main__":
    main()
