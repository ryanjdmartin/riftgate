"""The hangar's Designs tab data: every brief in docs/briefs/, parsed for the page.

Each brief opens with a hangar header under its title, an HTML comment holding a JSON object
(the briefs README's How a session runs says what each field means):

    # Brief: the lure tank, Minerva's tier-one front (new chassis)

    <!-- hangar: {"kind": "chassis", "maker": "minerva", "tier": 1, "status": "idea", "slot": true, "name": "the lure tank"} -->

This reads every brief, checks its header, and splits the body into sections (by heading) and
blocks (a paragraph, a list item, a quote paragraph, a table, a code fence), each block keeping
its exact source text so an edit Ryan makes on the page can be folded back into the file by a
plain text match. It writes build/hangar/designs.json, which tools/hangar_data.py publishes
beside the page as hangar/designs.json (5 November, Ryan: "I'd like to be able to edit briefs
and WIP designs in the hangar if possible, so when I start a design session I'm not correcting
a bunch of bad assumptions in context").

    python3 tools/hangar_designs.py            # write build/hangar/designs.json, print a summary
    python3 tools/hangar_designs.py --check    # check the headers only, write nothing
"""
import hashlib, json, os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BRIEFS = os.path.join(ROOT, "docs", "briefs")
OUT = os.path.join("build", "hangar", "designs.json")
KINDS = {"chassis", "component", "module", "rule", "hub", "shared"}
HEADER = re.compile(r"^<!-- hangar: (\{.*\}) -->$")
LIST_ITEM = re.compile(r"^(\s*)([-*]|\d+\.) (.*)$")
HEADING = re.compile(r"^(#{1,6}) (.*)$")


def makers():
    return [m["id"] for m in json.load(open(os.path.join(ROOT, "content", "chassis.json")))["makers"]]


def check_header(fn, h, maker_ids):
    """Every problem with one brief's header, as text; an empty list when it is sound."""
    bad = []
    if h.get("kind") not in KINDS:
        bad.append("kind %r is not one of %s" % (h.get("kind"), sorted(KINDS)))
    if h.get("maker") is not None and h.get("maker") not in maker_ids:
        bad.append("maker %r is no content maker" % h.get("maker"))
    if h.get("tier") is not None and h.get("tier") not in (1, 2, 3):
        bad.append("tier %r is not 1, 2, 3 or null" % h.get("tier"))
    if not isinstance(h.get("status"), str) or not h.get("status"):
        bad.append("status must be a short word")
    if not isinstance(h.get("slot"), bool):
        bad.append("slot must be true or false")
    if not isinstance(h.get("name"), str) or not h.get("name"):
        bad.append("name must be its working name")
    if h.get("slot") and h.get("kind") != "chassis":
        bad.append("only a chassis fills a roster slot")
    if h.get("slot") and not h.get("maker"):
        bad.append("a roster slot needs its maker")
    return ["%s: %s" % (fn, b) for b in bad]


def blocks_of(lines):
    """The body's blocks, in order: (type, level, marker, start, end) over line indices, end
    exclusive. A heading is a block too; a blank line separates; a list item takes the indented
    lines under it; an indented paragraph after a blank line (an item's second paragraph) is a
    paragraph of its own at that indent."""
    out, i, n = [], 0, len(lines)

    def starts_block(ln):
        return (not ln.strip() or HEADING.match(ln) or ln.startswith("|") or ln.startswith(">")
                or ln.startswith("```") or LIST_ITEM.match(ln))

    while i < n:
        ln = lines[i]
        if not ln.strip():
            i += 1
            continue
        if ln.startswith("```"):
            j = i + 1
            while j < n and not lines[j].startswith("```"):
                j += 1
            out.append(("code", 0, "", i, min(j + 1, n)))
            i = j + 1
            continue
        m = HEADING.match(ln)
        if m:
            out.append(("h%d" % len(m.group(1)), 0, "", i, i + 1))
            i += 1
            continue
        if ln.startswith("|"):
            j = i
            while j < n and lines[j].startswith("|"):
                j += 1
            out.append(("table", 0, "", i, j))
            i = j
            continue
        if ln.startswith(">"):
            j = i
            while j < n and lines[j].startswith(">") and lines[j].strip() != ">":
                j += 1
            out.append(("quote", 0, "", i, j))
            while j < n and lines[j].strip() == ">":
                j += 1
            i = j
            continue
        m = LIST_ITEM.match(ln)
        if m:
            indent = len(m.group(1))
            j = i + 1
            while j < n and lines[j].strip() and not starts_block(lines[j]) and (len(lines[j]) - len(lines[j].lstrip())) > indent:
                j += 1
            out.append(("li", indent, m.group(2), i, j))
            i = j
            continue
        indent = len(ln) - len(ln.lstrip())
        j = i + 1
        while j < n and lines[j].strip() and not starts_block(lines[j]):
            j += 1
        out.append(("p", indent, "", i, j))
        i = j
    return out


def text_of(kind, lines):
    """What the page shows and edits: the block's words with its markup of place stripped (a
    list marker, a quote's '>', the indent), lines joined by a space; a table or code fence raw."""
    if kind in ("table", "code"):
        return "\n".join(lines)
    if kind.startswith("h"):
        return HEADING.match(lines[0]).group(2).strip()
    if kind == "quote":
        return " ".join(re.sub(r"^>\s?", "", ln).strip() for ln in lines).strip()
    if kind == "li":
        first = LIST_ITEM.match(lines[0]).group(3)
        return " ".join([first.strip()] + [ln.strip() for ln in lines[1:]]).strip()
    return " ".join(ln.strip() for ln in lines).strip()


def parse(path, maker_ids):
    """One brief as the page reads it, and the problems its header has."""
    fn = os.path.basename(path)
    raw = open(path, encoding="utf-8").read()
    lines = raw.split("\n")
    problems = []
    if not lines or not lines[0].startswith("# "):
        return None, ["%s: the first line must be its title, '# ...'" % fn]
    title = lines[0][2:].strip()
    header, body_from = None, 1
    for k in range(1, min(len(lines), 6)):
        m = HEADER.match(lines[k].strip())
        if m:
            try:
                header = json.loads(m.group(1))
            except ValueError as e:
                problems.append("%s: its header is not JSON (%s)" % (fn, e))
                header = {}
            body_from = k + 1
            break
    if header is None:
        return None, ["%s: no hangar header under its title (the briefs README says how to write one)" % fn]
    problems += check_header(fn, header, maker_ids)
    body = lines[body_from:]
    blocks, sections, seen = [], [{"id": "s0", "heading": "", "level": 1}], {}
    for kind, level, marker, a, b in blocks_of(body):
        src_lines = body[a:b]
        src = "\n".join(src_lines)
        if kind.startswith("h"):
            sections.append({"id": "s%d" % len(sections), "heading": text_of(kind, src_lines), "level": int(kind[1])})
        h = hashlib.sha1(src.encode("utf-8")).hexdigest()[:12]
        seen[h] = seen.get(h, 0) + 1
        bid = h if seen[h] == 1 else "%s-%d" % (h, seen[h])
        blocks.append({"id": bid, "type": kind, "level": level, "marker": marker,
                       "sec": sections[-1]["id"], "text": text_of(kind, src_lines), "src": src,
                       "line": body_from + a + 1})
    return {"id": fn[:-3], "file": "docs/briefs/" + fn, "title": title, "header": header,
            "sections": sections, "blocks": blocks}, problems


def stamp():
    """The commit the briefs were read at, and whether the working tree had moved past it."""
    try:
        head = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT, capture_output=True, text=True).stdout.strip()
        dirty = subprocess.run(["git", "status", "--porcelain", "--", "docs/briefs"], cwd=ROOT, capture_output=True, text=True).stdout.strip()
        return head + ("+edits" if dirty else "")
    except OSError:
        return "unknown"


def build(check_only=False):
    """Parse every brief; write the page's file unless only checking. Returns (docs, problems)."""
    maker_ids = makers()
    docs, problems = [], []
    for fn in sorted(os.listdir(BRIEFS)):
        if not fn.endswith(".md"):
            continue
        d, p = parse(os.path.join(BRIEFS, fn), maker_ids)
        problems += p
        if d:
            docs.append(d)
    if not check_only and not problems:
        os.makedirs(os.path.dirname(os.path.join(ROOT, OUT)), exist_ok=True)
        json.dump({"_about": "Every brief in docs/briefs/ as the hangar's Designs tab reads it, written by tools/hangar_designs.py: its header, its sections and its blocks, each block's exact source kept for folding an edit back in.",
                   "stamp": stamp(), "docs": docs},
                  open(os.path.join(ROOT, OUT), "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
    return docs, problems


def main():
    check_only = "--check" in sys.argv
    docs, problems = build(check_only)
    if problems:
        print("\n".join(problems), file=sys.stderr)
        sys.exit(1)
    slots = {}
    for d in docs:
        h = d["header"]
        if h.get("slot"):
            slots[h["maker"]] = slots.get(h["maker"], 0) + 1
    blocks = sum(len(d["blocks"]) for d in docs)
    print("%d briefs, %d blocks; roster slots in briefs: %s%s" % (len(docs), blocks, ", ".join("%s %d" % kv for kv in sorted(slots.items())),
                                                              "" if check_only else "; written to " + OUT))


if __name__ == "__main__":
    main()
