"""Check a proposed name against the machines of the four properties our designs sit nearest
(content/reserved_names.json: BattleTech, Heavy Gear, Warhammer 40,000 and Halo) and against the
names in content now, as the hangar's Names tab checked one until it retired (20 November;
docs/naming.md is the reference of the kinds of names each maker wants).

    python3 tools/check_name.py Puffin "Drill Sergeant" Dunkleosteus   # a verdict a name
    python3 tools/check_name.py --all "Grey Wolf"                       # every shared word, not the first three
    python3 tools/check_name.py --strict "Timber Wolf"                  # exit 1 when a name is taken

Each argument is one name (quote a name of two words). A verdict says, of each name:

- ours: it is in content already (a chassis, a component or a foe), with its maker;
- taken: it is a reserved machine's name exactly, once case, spaces, hyphens, underscores,
  apostrophes, full stops, commas and brackets are set aside (ContentDB.normalise_name), with
  the property it is from;
- shares a word: a word of four letters or more, and no common one, that a reserved name
  carries too: a nudge, never a clash (the validator refuses an exact match alone);
- free: none of these.

The validator (sim/content_db.gd) refuses a chassis whose name or id is taken unless its entry
records why it stays under design.name_clash. The reserved lists are machines, not weapons, so a
component's clash is the softer signal.
"""
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHOWN = 3   # shared words named before "and N more", as the page showed them

# Words too common to mean a shared name: colours, sizes, a mark's numerals, the elements.
COMMON = {"fire", "black", "dark", "war", "night", "storm", "blood", "iron", "sun", "star", "great", "mk", "ii", "iii", "iv",
          "lam", "iic", "mad", "battle", "thunder", "arctic", "shadow", "savage", "super", "king", "red", "blue", "white",
          "grey", "gray", "silver", "gold", "snow", "ice", "stone", "rock", "sand", "sea", "sky", "wild", "dire", "little",
          "big", "heavy", "light", "the", "of", "and", "one", "two", "dog"}


def load(name):
    return json.load(open(os.path.join(ROOT, "content", name + ".json"), encoding="utf-8"))


def norm(s):
    """A name as the validator compares it (ContentDB.normalise_name)."""
    return re.sub(r"[\s\-_'.,()]", "", (s or "").lower())


def words(s):
    return [w for w in re.split(r"[\s\-]+", re.sub(r"[^a-z0-9 \-]", " ", (s or "").lower())) if len(w) >= 4 and w not in COMMON]


def reserved():
    """Every reserved name with its property's label, in the file's order."""
    out = []
    for src in load("reserved_names").get("sources", {}).values():
        for n in src.get("names", []):
            out.append((n, src.get("label", "reserved")))
    return out


def ours():
    """The names in content now: every chassis and component with its maker, and every foe."""
    chassis = load("chassis")
    makers = {m["id"]: m.get("name", m["id"]) for m in chassis["makers"]}
    out = [(e.get("name", ""), makers.get(e.get("maker"), e.get("maker", ""))) for e in chassis["entries"]]
    out += [(e.get("name", ""), makers.get(e.get("maker"), e.get("maker") or "")) for e in load("components")["entries"]]
    out += [(e.get("name", ""), "foe") for e in load("foes")["entries"]]
    return [(n, m) for n, m in out if n]


def check(name, names, exact, by_word, every=False):
    """The verdict on one name: a list of (kind, text), kind ok, bad or warn."""
    k = norm(name)
    if not k:
        return [("warn", "no name to check")]
    hits = []
    mine = next(((n, m) for n, m in names if norm(n) == k), None)
    if mine:
        hits.append(("ok", "already ours: %s (%s)" % mine))
    if k in exact:
        hits.append(("bad", "taken: %s is %s" % exact[k]))
    seen, soft = set(), []
    for w in words(name):
        for n, label in by_word.get(w, []):
            if norm(n) == k or n in seen:
                continue
            seen.add(n)
            soft.append("%s (%s)" % (n, label))
    if soft:
        shown = soft if every else soft[:SHOWN]
        more = len(soft) - len(shown)
        hits.append(("warn", "shares a word with " + ", ".join(shown) + (" and %d more" % more if more else "")))
    if not hits:
        hits.append(("ok", "free: not a machine in any of the four properties"))
    return hits


def main():
    args = sys.argv[1:]
    every, strict = "--all" in args, "--strict" in args
    names_asked = [a for a in args if a not in ("--all", "--strict")]
    if not names_asked:
        sys.exit(__doc__.split("\n\n")[1])
    exact, by_word = {}, {}
    for n, label in reserved():
        exact.setdefault(norm(n), (n, label))   # the first source to claim a name labels it
        for w in words(n):
            by_word.setdefault(w, []).append((n, label))
    names = ours()
    taken = False
    mark = {"ok": " ", "warn": "~", "bad": "!"}
    for name in names_asked:
        hits = check(name, names, exact, by_word, every)
        taken = taken or any(kind == "bad" for kind, _ in hits)
        print(name)
        for kind, text in hits:
            print("  %s %s" % (mark[kind], text))
    if strict and taken:
        sys.exit(1)


if __name__ == "__main__":
    main()
