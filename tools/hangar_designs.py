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
    python3 tools/hangar_designs.py --fold build/hangar/inbox [--dry]   # fold the page's notes into the briefs

The page's notes are the documents of its database's "designs" collection, saved one JSON file a
document by ArtifactData's list with out_dir (build/hangar/inbox/designs/<id>.json). --fold lays
each into its brief as Ryan's, dated by the day the page recorded: a correction replaces its block
in place, wrapped to the file and closed with "(Ryan's correction, <day>.)"; a strike removes its
block; a note goes under its heading as "**Ryan's note (<day>)**: ..."; a direction goes under the
brief's header as "**Ryan's direction (<day>)**: ...", replacing an earlier one. An idea is listed
for the session to brief. It prints what it folded, what it could not (the brief moved under it:
fold that one by hand), and the ArtifactData batch that clears the folded documents.
"""
import glob, hashlib, json, os, re, subprocess, sys, textwrap

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


WIDTH = 100   # the briefs wrap at a hundred columns
MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September",
          "October", "November", "December"]


def load_inbox(path):
    """The page's notes from ArtifactData's files (one a document, or a list in one file): each
    note's fields with its "id" and, when the file carries it, its "version"."""
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
            data = it["data"] if isinstance(it.get("data"), dict) and "type" not in it else it
            nid = it.get("id") or it.get("doc_id") or (os.path.splitext(os.path.basename(p))[0] if len(items) == 1 else None)
            out.append(dict(data, id=nid, version=it.get("version", data.get("version"))))
    return [n for n in out if n.get("type")]


def day_of(n):
    """The day a note was made, as the briefs date Ryan's words ("5 November")."""
    if n.get("day"):
        return n["day"]
    m = re.match(r"(\d{4})-(\d\d)-(\d\d)", n.get("updated") or n.get("created") or "")
    return "%d %s" % (int(m.group(3)), MONTHS[int(m.group(2)) - 1]) if m else "undated"


def paragraphs(text):
    """A textarea's words as paragraphs: a blank line parts them, a single newline is a space."""
    return [" ".join(p.split()) for p in re.split(r"\n\s*\n", text.strip()) if p.strip()]


def wrap(text, first, rest):
    return textwrap.fill(text, WIDTH, initial_indent=first, subsequent_indent=rest,
                         break_long_words=False, break_on_hyphens=False)


def block_source(n, text):
    """A block's new source from its kind, marker and indent: a paragraph, a list item (a second
    paragraph indented under it), a quote; a table or a code fence as written."""
    kind, pad = n.get("kind", "p"), " " * int(n.get("level") or 0)
    if kind in ("table", "code"):
        return text.strip("\n")
    paras = paragraphs(text)
    if kind == "li":
        mk = (n.get("marker") or "-") + " "
        under = pad + " " * len(mk)
        return "\n\n".join([wrap(paras[0], pad + mk, under)] + [wrap(p, under, under) for p in paras[1:]])
    if kind == "quote":
        return "\n>\n".join(wrap(p, "> ", "> ") for p in paras)
    if kind.startswith("h"):
        return "#" * int(kind[1]) + " " + " ".join(paras)
    return "\n\n".join(wrap(p, pad, pad) for p in paras)


def labelled(label, text):
    """A note or a direction as its paragraphs, the first opening on Ryan's label."""
    paras = paragraphs(text)
    paras[0] = label + ": " + paras[0]
    return [wrap(p, "", "") for p in paras]


def fold(path, dry=False):
    """Fold the page's notes into the briefs. Returns (folded, unfolded, ideas): notes, each
    unfolded one with its reason."""
    notes = load_inbox(path)
    folded, unfolded, ideas = [], [], []
    by_file = {}
    for n in notes:
        if n["type"] == "idea":
            ideas.append(n)
        elif n["type"] in ("edit", "note", "direction"):
            by_file.setdefault(n.get("file") or "docs/briefs/%s.md" % n.get("doc"), []).append(n)
        else:
            unfolded.append((n, "an unknown type %r" % n["type"]))
    for rel, items in sorted(by_file.items()):
        fp = os.path.join(ROOT, rel)
        if not os.path.exists(fp) or not rel.startswith("docs/briefs/"):
            unfolded += [(n, "no brief %s" % rel) for n in items]
            continue
        text = open(fp, encoding="utf-8").read()
        # Corrections and strikes first, by their exact source; then notes and the direction,
        # which find their heading and the header by line.
        for n in sorted((x for x in items if x["type"] == "edit"), key=lambda x: x.get("line") or 0):
            orig = n.get("original") or ""
            if not orig or text.count(orig) != 1:
                unfolded.append((n, "its block is no longer in the brief as it was" if orig and not text.count(orig) else "its block is in the brief more than once"))
                continue
            i = text.index(orig)
            if n.get("strike"):
                if re.match(r"\d+\.$", n.get("marker") or ""):
                    n["hint"] = "a numbered item: close its list's numbers, and any pointer to them"
                j = i + len(orig) + (1 if text[i + len(orig):i + len(orig) + 1] == "\n" else 0)
                text = text[:i] + text[j:]
                if text[i - 2:i] == "\n\n" and text[i:i + 1] == "\n":
                    text = text[:i] + text[i + 1:]
            else:
                new = (n.get("text") or "").strip()
                if n.get("kind") not in ("table", "code"):
                    new += " (Ryan's correction, %s.)" % day_of(n)
                text = text[:i] + block_source(n, new) + text[i + len(orig):]
            folded.append(n)
        lines = text.split("\n")
        for n in sorted((x for x in items if x["type"] == "note"), key=lambda x: x.get("updated") or "", reverse=True):
            at = next((k for k, ln in enumerate(lines) if HEADING.match(ln) and HEADING.match(ln).group(2).strip() == n.get("section")), None)
            if at is None or not (n.get("text") or "").strip():
                unfolded.append((n, "its heading %r is no longer in the brief" % n.get("section")))
                continue
            lines[at + 1:at + 1] = [""] + "\n\n".join(labelled("**Ryan's note (%s)**" % day_of(n), n["text"])).split("\n")
            folded.append(n)
        for n in (x for x in items if x["type"] == "direction"):
            at = next((k for k, ln in enumerate(lines[:6]) if HEADER.match(ln.strip())), None)
            if at is None or not (n.get("text") or "").strip():
                unfolded.append((n, "the brief has no hangar header"))
                continue
            k = at + 1
            while k < len(lines) and not lines[k].strip():
                k += 1
            if k < len(lines) and lines[k].startswith("**Ryan's direction ("):   # the earlier one goes
                e = k
                while e < len(lines) and lines[e].strip():
                    e += 1
                del lines[k:e + 1]
            lines[at + 1:at + 1] = [""] + "\n\n".join(labelled("**Ryan's direction (%s)**" % day_of(n), n["text"])).split("\n")
            folded.append(n)
        new_text = "\n".join(lines).rstrip("\n") + "\n"
        if not dry and new_text != open(fp, encoding="utf-8").read():
            open(fp, "w", encoding="utf-8").write(new_text)
    return folded, unfolded, ideas


def fold_main(path, dry):
    folded, unfolded, ideas = fold(path, dry)
    what = lambda n: "%s %s (%s%s)" % (n["type"] if not n.get("strike") else "strike", n.get("id"), n.get("doc") or n.get("tab"), ", " + n["section"] if n.get("section") else "")
    print("%s %d:" % ("would fold" if dry else "folded", len(folded)))
    for n in folded:
        print("  " + what(n) + (": " + n["hint"] if n.get("hint") else ""))
    if unfolded:
        print("not folded %d (fold by hand, then clear):" % len(unfolded))
        for n, why in unfolded:
            print("  %s: %s" % (what(n), why))
    if ideas:
        print("ideas %d (a brief each, or a bench line; then mark it briefed or drop it):" % len(ideas))
        for n in ideas:
            print("  %s [%s, %s, %s] %s: %s" % (n.get("id"), n.get("tab"), n.get("kind"), n.get("status"), n.get("name"), " ".join((n.get("concept") or "").split())))
    if folded and not dry:
        writes = [dict({"op": "delete", "collection": "designs", "doc_id": n["id"]}, **({"if_version": n["version"]} if n.get("version") else {})) for n in folded]
        print("clear the folded with ArtifactData batch, writes:")
        print(json.dumps(writes))
        print("then: git diff docs/briefs, python3 tools/hangar_data.py, commit, republish the hangar")


def main():
    if "--fold" in sys.argv:
        k = sys.argv.index("--fold")
        if k + 1 >= len(sys.argv):
            sys.exit("--fold wants the folder ArtifactData's list wrote the designs collection to")
        fold_main(sys.argv[k + 1], "--dry" in sys.argv)
        return
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
