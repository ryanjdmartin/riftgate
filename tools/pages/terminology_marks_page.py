#!/usr/bin/env python3
"""The terminology pass's rules as a page Ryan marks on (20 November: "Can you turn this into an
artifact for me?", of the rules spelled out in chat).

Reads docs/terminology_proposal.md, the one home of the rules: its section 2 (the rules by group,
each with its examples and, where it offers a choice, its A and B) and its section 4 (the calls
that are no rule: who rewrites the drafts, and the names, each with what may be picked). Prints
the page: every rule and call with its marks (A or B where it offers a choice, else Agree; then
Change and Ask), every name with its picks, and a note each. The marks live in the page's
database, collection `marks`, a document an item keyed by its id (`rule-13`, `call-who-rewrites`,
`name-aloft`), so a session reads them back with ArtifactData and folds them into the proposal's
section 8.

    python3 tools/pages/terminology_marks_page.py > build/terminology_marks.html

The page's link is in docs/status.md, Pages. Publish with capabilities {"db": {}, "user": {}}.
A rule's id is its number, so a rule renumbered in the proposal loses its mark's key: move the
document with it.
"""

import html
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DOC = os.path.join(ROOT, "docs", "terminology_proposal.md")


def slug(s: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")


def section(lines: list, n: int) -> list:
    """The lines of the proposal's section `n`, its heading left out."""
    start = next((i for i, l in enumerate(lines) if l.startswith("## %d. " % n)), None)
    if start is None:
        raise SystemExit("no section %d in %s" % (n, DOC))
    end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith("## ")), len(lines))
    return lines[start + 1:end]


def inline(t: str) -> str:
    """One line of the proposal's markdown as HTML: bold, italics, code, and its quotes curled."""
    t = html.escape(t, quote=False)
    t = re.sub(r"`([^`]+)`", r"<code>\1</code>", t)
    t = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", t)
    t = re.sub(r"(?<![\w*])\*(?!\s)(.+?)(?<!\s)\*(?![\w*])", r"<em>\1</em>", t)
    t = re.sub(r'(^|[\s(\[>/])"', "\\1\u201c", t)
    t = t.replace('"', "\u201d").replace("'", "\u2019")
    return t


def blocks(body: list) -> list:
    """An item's lines as blocks: {"p": text} or {"li": text, "depth": n}, a bullet's wrapped lines
    joined to it and a paragraph's to it."""
    out = []
    for raw in body:
        if not raw.strip():
            out.append(None)
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        text = raw.strip()
        if text.startswith("- "):
            out.append({"li": text[2:], "depth": indent // 2})
        elif out and out[-1] is not None and "li" in out[-1] and indent >= 2 * out[-1]["depth"] + 2:
            out[-1]["li"] += " " + text
        elif out and out[-1] is not None and "p" in out[-1] and indent == 0:
            out[-1]["p"] += " " + text
        else:
            out.append({"p": text})
    return [b for b in out if b is not None]


EXAMPLE = re.compile(r"^(.+?) \u2192 (.+)$")
OPTION = re.compile(r"^\*\*([AB]):\*\* (.+)$")


def example(text: str) -> str:
    m = EXAMPLE.match(text)
    return ('<div class="ex"><span class="now"><b>Now</b>%s</span><span class="to" aria-hidden="true">\u2192</span>'
            '<span class="after"><b>After</b>%s</span></div>') % (inline(m.group(1)), inline(m.group(2)))


def render(bs: list) -> tuple:
    """An item's blocks as HTML, and the options it offers (["A", "B"] or [])."""
    parts, options, i = [], [], 0
    while i < len(bs):
        b = bs[i]
        if "p" in b:
            parts.append("<p>%s</p>" % inline(b["p"]))
            i += 1
            continue
        # A run of top-level bullets, each with the deeper ones under it.
        run = []
        while i < len(bs) and "li" in bs[i]:
            if bs[i]["depth"] == 0 or not run:
                run.append([bs[i], []])
            else:
                run[-1][1].append(bs[i])
            i += 1
        plain = []
        def flush():
            if plain:
                parts.append("<ul>%s</ul>" % "".join("<li>%s</li>" % inline(t) for t in plain))
                plain.clear()
        exs = []
        def flush_ex():
            if exs:
                parts.append('<div class="exs">%s</div>' % "".join(exs))
                exs.clear()
        for top, kids in run:
            opt = OPTION.match(top["li"])
            if opt:
                flush(); flush_ex()
                key = opt.group(1)
                options.append(key)
                inner = "<p>%s</p>" % inline(opt.group(2))
                kid_ex = [example(k["li"]) for k in kids if EXAMPLE.match(k["li"])]
                kid_plain = [k["li"] for k in kids if not EXAMPLE.match(k["li"])]
                if kid_ex:
                    inner += '<div class="exs">%s</div>' % "".join(kid_ex)
                if kid_plain:
                    inner += "<ul>%s</ul>" % "".join("<li>%s</li>" % inline(t) for t in kid_plain)
                lean = '<span class="lean">Lean</span>' if key == "A" else ""
                parts.append('<div class="opt" data-key="%s"><div class="key">%s%s</div><div class="opt-body">%s</div></div>' % (key, key, lean, inner))
            elif EXAMPLE.match(top["li"]):
                flush()
                exs.append(example(top["li"]))
            else:
                flush_ex()
                plain.append(top["li"])
        flush(); flush_ex()
    return "".join(parts), options


HEAD = re.compile(r"^\*\*(?:(\d+)\. )?(.+?)\*\*(?:\s*\((.+)\))?\s*$")
PICK = re.compile(r"^\*\*(.+?)\*\*\s*(.*?)\s*Pick:\s*(.+)$")


# The proposal speaks of Ryan in the third person; the page speaks to him. Each phrase must be
# found, so a rewording in the proposal fails here rather than leaving "his" on his page.
TO_HIM = [
    ("his sign-off", "your sign-off"), ("his four timing points", "your four timing points"),
    ("(changed 19 November: his mark)", "(changed 19 November: your mark)"), ("His word:", "Your word:"),
    ("This one needs his\neye", "This one needs your\neye"), ("rulings he has already made", "rulings you've already made"),
    ("on the Text tab for his marks. Nothing is signed for him.", "on the Text tab for your marks. Nothing is signed for you."),
    ("**B:** He writes them himself", "**B:** You write them yourself"),
    ("(changed 22 November: his word)", "(changed 22 November: your word)"), ("(changed 22 November: his words)", "(changed 22 November: your words)"),
    ("His words:", "Your words:"), ("His proposal of 22 November", "Your proposal of 22 November"),
]


def to_him(text: str) -> str:
    for old, new in TO_HIM:
        if old not in text:
            raise SystemExit("the proposal no longer says %r: mend TO_HIM" % old)
        text = text.replace(old, new)
    return text


def items_of(lines: list) -> list:
    lines = to_him("\n".join(section(lines, 2)) + "\n## 4. \n" + "\n".join(section(lines, 4))).split("\n")
    cut = lines.index("## 4. ")
    rules, calls = lines[:cut], lines[cut + 1:]
    out = []

    def take(body_lines, group):
        """Every item in a section's lines: a bold head and the lines under it."""
        cur = None
        for line in body_lines:
            if line.startswith("### "):
                group = line[4:].strip()
                cur = None
                continue
            m = HEAD.match(line)
            if m and not line.startswith(" "):
                cur = {"num": m.group(1) or "", "title": m.group(2).rstrip("."), "tag": (m.group(3) or "").strip(), "group": group, "body": []}
                out.append(cur)
                continue
            if cur is not None:
                cur["body"].append(line)
        return group

    take(rules, "")
    first_call = len(out)
    take(calls, "Calls")
    items = []
    for n, it in enumerate(out):
        bs = blocks(it["body"])
        names = [b for b in bs if "li" in b and b["depth"] == 0 and "Pick:" in b["li"]]
        if names:
            # A group of names: each name its own item, its picks its marks.
            for b in names:
                m = PICK.match(b["li"])
                if not m:
                    raise SystemExit("a name without its picks: " + b["li"][:80])
                title = m.group(1).rstrip(".")
                picks = [p.strip() for p in m.group(3).split("\u00b7") if p.strip()]
                items.append({"id": "name-" + slug(title), "group": it["title"], "grouptag": it["tag"], "num": "", "title": title, "tag": "",
                              "html": "<p>%s</p>" % inline(m.group(2)) if m.group(2) else "",
                              "marks": [["pick:" + p, p, "solid"] for p in picks] + [["ask", "Ask", "dotted"]]})
            continue
        body, options = render(bs)
        if n < first_call:
            if not it["num"]:
                raise SystemExit("a rule without its number: " + it["title"])
            iid = "rule-" + it["num"]
            marks = ([[k, k, "solid"] for k in options] if options else [["agree", "Agree", "solid"]]) + [["change", "Change", "dashed"], ["ask", "Ask", "dotted"]]
        else:
            iid = "call-" + slug(it["title"])
            marks = ([[k, k, "solid"] for k in options] or [["agree", "Agree", "solid"]]) + [["ask", "Ask", "dotted"]]
        items.append({"id": iid, "group": it["group"], "grouptag": "", "num": it["num"], "title": it["title"], "tag": it["tag"],
                      "html": body, "marks": marks, "lean": "A" if "A" in options else ""})
    ids = [i["id"] for i in items]
    if len(ids) != len(set(ids)):
        raise SystemExit("two items share an id")
    return items


PAGE = r"""<title>Terminology Marks</title>
<meta name="claude:viewport-fit-sides" content="cover">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Barlow:ital,wght@0,400;0,500;0,600;1,400&family=Barlow+Semi+Condensed:wght@600&family=Share+Tech+Mono&display=swap">
<style>
/* layout: a sticky strip of filters over one long ruled list of rules; a rule's words on the left
   and its marks on the right on a desk, its marks under it on a phone */
:root {
  --ground: #f2f4f6; --panel: #ffffff; --ink: #18202a; --muted: #5b6876; --rule: #cfd6dd;
  --accent: #1d5fc4; --accent-ink: #ffffff; --tint: #e3ecf9; --now: #6b4f2a;
  --body: "Barlow", "Segoe UI", system-ui, sans-serif;
  --head: "Barlow Semi Condensed", "Barlow", "Segoe UI", system-ui, sans-serif;
  --mono: "Share Tech Mono", ui-monospace, "SFMono-Regular", Menlo, Consolas, monospace;
}
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) {
  --ground: #11161c; --panel: #19212a; --ink: #e6ebf0; --muted: #9aa7b4; --rule: #33404d;
  --accent: #8ab8ff; --accent-ink: #0c1420; --tint: #1f2f45; --now: #d8b98c; color-scheme: dark } }
:root[data-theme="dark"] {
  --ground: #11161c; --panel: #19212a; --ink: #e6ebf0; --muted: #9aa7b4; --rule: #33404d;
  --accent: #8ab8ff; --accent-ink: #0c1420; --tint: #1f2f45; --now: #d8b98c; color-scheme: dark }
body { background: var(--ground); color: var(--ink); font: 400 16px/1.5 var(--body); }
body::before { content: ""; position: fixed; inset: 0 0 auto; height: env(safe-area-inset-top, 0px); z-index: 10; background: var(--ground); }
.wrap { max-width: 1120px; margin: 0 auto; padding-block: 20px 64px; padding-left: max(16px, env(safe-area-inset-left, 0px)); padding-right: max(16px, env(safe-area-inset-right, 0px)); display: flex; flex-direction: column; gap: 14px; }
h1 { font: 600 32px/1.1 var(--head); margin: 0; text-wrap: balance; letter-spacing: .01em; }
.lede { margin: 0; max-width: 68ch; }
.meta { margin: 0; font: 13px/1.5 var(--mono); color: var(--muted); letter-spacing: .02em; }
.strip { position: sticky; top: env(safe-area-inset-top, 0px); z-index: 5; background: var(--ground); padding-block: 8px; display: flex; flex-wrap: wrap; gap: 8px 12px; align-items: center; border-bottom: 2px solid var(--ink); }
.filters { display: flex; flex-wrap: wrap; gap: 6px; }
.count { font: 14px var(--mono); color: var(--muted); margin-left: auto; font-variant-numeric: tabular-nums; }
.state { font: 14px var(--mono); color: var(--muted); flex-basis: 100%; min-height: 1.4em; }
.state[data-kind="warn"] { color: var(--ink); font-weight: 600; }
button { font: inherit; color: inherit; }
.chip, .mark, .copy { font: 13px var(--mono); letter-spacing: .05em; text-transform: uppercase; background: var(--panel); border: 1.5px solid var(--rule); padding: 7px 10px; min-height: 38px; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; gap: 6px; }
.chip span { color: var(--muted); }
.chip[aria-pressed="true"] { background: var(--ink); color: var(--ground); border-color: var(--ink); }
.chip[aria-pressed="true"] span { color: inherit; }
.copy { border-color: var(--ink); }
:is(.chip, .mark, .copy, textarea):focus-visible { outline: 3px solid var(--accent); outline-offset: 2px; }
.clip { width: 100%; font: 13px/1.4 var(--mono); }
h2 { font: 600 21px/1.2 var(--head); margin: 26px 0 0; padding-bottom: 6px; border-bottom: 1.5px solid var(--ink); display: flex; flex-wrap: wrap; gap: 4px 12px; align-items: baseline; }
h2 span { font: 13px var(--mono); color: var(--muted); letter-spacing: .03em; }
.item { display: grid; grid-template-columns: minmax(0, 1fr) 236px; gap: 10px 28px; padding-block: 16px; border-bottom: 1px solid var(--rule); scroll-margin-top: 96px; }
.item[data-mark]:not([data-mark=""]) { background: linear-gradient(90deg, var(--tint), transparent 70%); }
.words { min-width: 0; display: flex; flex-direction: column; gap: 8px; }
.head { display: grid; grid-template-columns: 2.6ch minmax(0, 1fr); align-items: baseline; gap: 4px 10px; }
.head.nonum { grid-template-columns: minmax(0, 1fr); }
.head .tag { grid-column: -2; justify-self: start; }
.num { font: 15px var(--mono); color: var(--accent); min-width: 2.2ch; font-variant-numeric: tabular-nums; }
.title { font: 600 19px/1.25 var(--head); margin: 0; text-wrap: balance; }
.tag { font: 12px/1.3 var(--mono); text-transform: uppercase; letter-spacing: .05em; border: 1.5px dashed var(--accent); color: var(--ink); padding: 2px 6px; }
.words p { margin: 0; max-width: 68ch; }
.words ul { margin: 0; padding-left: 1.2em; display: flex; flex-direction: column; gap: 3px; max-width: 68ch; }
code { font: 14px var(--mono); }
.exs { display: flex; flex-direction: column; gap: 6px; max-width: 76ch; }
.ex { display: grid; grid-template-columns: minmax(0, 1fr) 20px minmax(0, 1fr); gap: 4px 8px; align-items: start; padding: 7px 10px; border-left: 3px solid var(--rule); background: var(--panel); }
.ex b { display: block; font: 11px/1.4 var(--mono); font-weight: 400; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); }
.ex .now { color: var(--now); overflow-wrap: anywhere; }
.ex .after { font-weight: 500; overflow-wrap: anywhere; }
.ex .to { color: var(--accent); font-weight: 600; padding-top: 1.1em; text-align: center; }
.opt { display: grid; grid-template-columns: 44px minmax(0, 1fr); gap: 10px; border: 1.5px solid var(--rule); padding: 10px; background: var(--panel); }
.opt .key { font: 600 22px/1 var(--head); display: flex; flex-direction: column; align-items: center; gap: 4px; }
.opt .lean { font: 10px var(--mono); text-transform: uppercase; letter-spacing: .08em; color: var(--accent); }
.opt-body { min-width: 0; display: flex; flex-direction: column; gap: 8px; }
.opt-body .ex { background: var(--ground); }
.item[data-mark="A"] .opt[data-key="A"], .item[data-mark="B"] .opt[data-key="B"] { border-color: var(--accent); border-width: 2.5px; }
.act { display: flex; flex-direction: column; gap: 6px; min-width: 0; }
.marks { display: grid; grid-template-columns: repeat(auto-fit, minmax(70px, 1fr)); gap: 4px; }
.mark { padding: 7px 4px; text-align: center; }
.mark[data-style="dashed"] { border-style: dashed; }
.mark[data-style="dotted"] { border-style: dotted; }
.mark[aria-pressed="true"] { background: var(--accent); color: var(--accent-ink); border-color: var(--accent); border-style: solid; }
.mark:disabled { cursor: default; opacity: .6; }
textarea { font: 15px/1.35 var(--body); color: var(--ink); background: var(--panel); border: 1.5px solid var(--rule); padding: 7px 8px; width: 100%; min-height: 38px; resize: vertical; box-sizing: border-box; }
.empty { padding-block: 28px; color: var(--muted); }
@media (max-width: 760px) {
  .item { grid-template-columns: minmax(0, 1fr); }
  .count { margin-left: 0; }
  .ex { grid-template-columns: minmax(0, 1fr); }
  .ex .to { display: none; }
  .ex .after { border-top: 1px dashed var(--rule); padding-top: 4px; }
}
@media (prefers-reduced-motion: no-preference) { .mark, .chip { transition: background-color .12s, color .12s; } }
</style>
<div class="wrap">
  <h1>Terminology Marks</h1>
  <p class="lede">Every rule for how Riftgate's gameplay text names units, targets and timing, with today's words beside the rule's. Tap A or B where a rule offers a choice, or Agree; Change and Ask want a note. Marks save as you go and Claude reads them back, so marking here and in chat both work.</p>
  <p class="meta">__META__</p>
  <div class="strip">
    <div class="filters" id="filters" role="group" aria-label="Show"></div>
    <button class="copy" type="button" id="copy">Copy for chat</button>
    <div class="count" id="count"></div>
    <div class="state" id="state" role="status">Loading the marks.</div>
    <textarea class="clip" id="clip" rows="4" readonly hidden aria-label="Your marks as text"></textarea>
  </div>
  <div id="list"></div>
</div>
<script>
const ITEMS = __ITEMS__;
const FILTERS = [["all", "All"], ["none", "Unmarked"], ["choice", "A or B"], ["changed", "Changed"], ["noted", "Noted"]];
let marks = {};          // id -> {mark, note}
let db = null, local = false, readOnly = false, filter = "all";
const queues = {}, timers = {};
const $ = id => document.getElementById(id);
function el(tag, attrs, kids) {
  const n = document.createElement(tag);
  for (const k in attrs || {}) { if (k === "text") n.textContent = attrs[k]; else if (k === "html") n.innerHTML = attrs[k]; else n.setAttribute(k, attrs[k]); }
  for (const c of kids || []) n.appendChild(c);
  return n;
}
function said(text, kind) { const s = $("state"); s.textContent = text; s.dataset.kind = kind || ""; }
function of(id) { return marks[id] || {mark: "", note: ""}; }
function label(it) { return (it.num ? it.num + ". " : "") + it.title; }
function shows(it) {
  const m = of(it.id);
  if (filter === "all") return true;
  if (filter === "none") return !m.mark && !m.note;
  if (filter === "noted") return !!m.note;
  if (filter === "choice") return it.marks.some(x => x[0] === "A");
  if (filter === "changed") return !!it.tag || !!it.grouptag;
  return true;
}
function build() {
  const list = $("list");
  let group = null, name = null;
  for (const it of ITEMS) {
    if (it.group !== name) {
      name = it.group;
      const h = el("h2", {}, [document.createTextNode(name)]);
      if (it.grouptag) h.appendChild(el("span", {class: "gtag", text: it.grouptag}));
      h.appendChild(el("span", {class: "gcount"}));
      group = el("section", {"data-group": name}, [h]);
      list.appendChild(group);
    }
    const head = el("div", {class: it.num ? "head" : "head nonum"});
    if (it.num) head.appendChild(el("span", {class: "num", text: it.num}));
    head.appendChild(el("h3", {class: "title", text: it.title}));
    if (it.tag) head.appendChild(el("span", {class: "tag", text: it.tag}));
    const words = el("div", {class: "words"}, [head]);
    if (it.html) words.appendChild(el("div", {class: "body", html: it.html}));
    const bar = el("div", {class: "marks", role: "group", "aria-label": "Mark " + label(it)});
    for (const [key, text, style] of it.marks) {
      const b = el("button", {class: "mark", type: "button", "data-style": style, "aria-pressed": "false", id: "m-" + it.id + "-" + key.replace(/[^a-z0-9]+/gi, "-")}, [document.createTextNode(text)]);
      b.addEventListener("click", () => { if (readOnly) return; const cur = of(it.id); put(it, {mark: cur.mark === key ? "" : key, note: cur.note}); });
      bar.appendChild(b);
    }
    const note = el("textarea", {id: "n-" + it.id, rows: "1", placeholder: "Note", "aria-label": "Note on " + label(it)});
    note.addEventListener("input", () => { clearTimeout(timers[it.id]); timers[it.id] = setTimeout(() => keep(it, note), 900); });
    note.addEventListener("blur", () => { clearTimeout(timers[it.id]); keep(it, note); });
    group.appendChild(el("article", {class: "item", id: it.id, "data-mark": ""}, [words, el("div", {class: "act"}, [bar, note])]));
  }
  list.appendChild(el("div", {class: "empty", id: "empty", hidden: ""}, [document.createTextNode("Nothing here carries that yet.")]));
  const f = $("filters");
  for (const [id, text] of FILTERS) {
    const b = el("button", {class: "chip", type: "button", id: "f-" + id, "aria-pressed": String(id === filter)}, [document.createTextNode(text), el("span", {})]);
    b.addEventListener("click", () => { filter = id; try { localStorage.setItem("terms-filter", id); } catch (e) {} paint(); });
    f.appendChild(b);
  }
  $("copy").addEventListener("click", copy);
}
function keep(it, note) { if (readOnly) return; const cur = of(it.id); const text = note.value.trim(); if (text !== cur.note) put(it, {mark: cur.mark, note: text}); }
function markText(it, m) {
  const found = it.marks.find(x => x[0] === m.mark);
  return found ? found[1] : "";
}
function paint() {
  const tally = {all: ITEMS.length, none: 0, choice: 0, changed: 0, noted: 0};
  let shown = 0;
  for (const it of ITEMS) {
    const m = of(it.id), row = $(it.id);
    row.dataset.mark = m.mark;
    for (const [key] of it.marks) {
      const b = $("m-" + it.id + "-" + key.replace(/[^a-z0-9]+/gi, "-"));
      b.setAttribute("aria-pressed", String(m.mark === key));
      b.disabled = readOnly;
    }
    const note = $("n-" + it.id);
    note.readOnly = readOnly;
    if (document.activeElement !== note && note.value.trim() !== m.note) note.value = m.note;
    if (!m.mark && !m.note) tally.none++;
    if (m.note) tally.noted++;
    if (it.marks.some(x => x[0] === "A")) tally.choice++;
    if (it.tag || it.grouptag) tally.changed++;
    const on = shows(it);
    row.hidden = !on;
    if (on) shown++;
  }
  for (const s of document.querySelectorAll("section[data-group]")) {
    const rows = [...s.querySelectorAll(".item")], live = rows.filter(x => !x.hidden).length;
    s.hidden = live === 0;
    const n = rows.length;
    s.querySelector(".gcount").textContent = live === n ? n + (n === 1 ? " item" : " items") : live + " of " + n;
  }
  for (const [id] of FILTERS) { const b = $("f-" + id); b.setAttribute("aria-pressed", String(id === filter)); b.querySelector("span").textContent = tally[id]; }
  $("empty").hidden = shown > 0;
  $("count").textContent = "Marked " + (ITEMS.length - tally.none) + " of " + ITEMS.length;
}
function summary() {
  const lines = [];
  for (const it of ITEMS) {
    const m = of(it.id);
    if (!m.mark && !m.note) continue;
    const said = markText(it, m);
    lines.push(label(it) + ": " + (said || "note") + (m.note ? " (" + m.note + ")" : ""));
  }
  return lines.length ? lines.join("\n") : "No marks yet.";
}
function copy() {
  const text = summary();
  const clip = $("clip");
  const fallback = () => { clip.hidden = false; clip.value = text; clip.focus(); clip.select(); said("Select the text below and copy it.", "warn"); };
  try {
    navigator.clipboard.writeText(text).then(() => { clip.hidden = true; said("Copied your marks as text, ready to paste in chat."); }, fallback);
  } catch (e) { fallback(); }
}
function put(it, next) {
  marks[it.id] = next;
  paint();
  if (local || !db) {
    try { localStorage.setItem("terms-marks", JSON.stringify(marks)); } catch (e) {}
    return;
  }
  said("Saving.");
  const ref = db.doc("marks/" + it.id);
  const body = {title: label(it), mark: next.mark, note: next.note, at: new Date().toISOString()};
  const write = () => (next.mark || next.note ? ref.set(body) : ref.delete());
  queues[it.id] = (queues[it.id] || Promise.resolve()).then(write).then(
    () => said("Saved."),
    e => {
      if (e && e.code === "invalid_argument") { readOnly = true; paint(); said("This view reads only, so marks can't be saved here.", "warn"); }
      else said("A mark did not save. Tap it again in a moment.", "warn");
    });
}
function jump() {
  const id = (location.hash || "").slice(1);
  if (id && $(id)) $(id).scrollIntoView({block: "start"});
}
function start() {
  try { const f = localStorage.getItem("terms-filter"); if (FILTERS.some(x => x[0] === f)) filter = f; } catch (e) {}
  build();
  paint();
  jump();
  window.addEventListener("hashchange", jump);
  const use = window.claude && window.claude.use ? window.claude.use.bind(window.claude) : null;
  const offline = () => {
    local = true;
    try { marks = JSON.parse(localStorage.getItem("terms-marks") || "{}") || {}; } catch (e) { marks = {}; }
    said("Marks are kept on this device only: this view can't reach the page's store.", "warn");
    paint();
  };
  if (!use) return offline();
  use("user").then(u => {
    if (!u) return;
    u.can("data.write").then(ok => { if (ok === false) { readOnly = true; paint(); said("This view reads only, so marks can't be saved here."); } }, () => {});
  }, () => {});
  use("db").then(got => {
    if (!got) return offline();
    db = got;
    const slow = setTimeout(() => said("The marks can't be reached yet. Still trying.", "warn"), 10000);
    db.collection("marks").onSnapshot(snap => {
      const next = {};
      for (const d of snap.docs) { const b = d.data() || {}; next[d.id] = {mark: String(b.mark || ""), note: String(b.note || "")}; }
      marks = next;
      if (!snap.metadata.fromCache) {
        clearTimeout(slow);
        if (!readOnly && $("state").textContent !== "Saving.") said(snap.size ? "Saved." : "No marks yet. Tap one to begin.");
      }
      paint();
    }, () => { clearTimeout(slow); said("The marks can't be reached in this view.", "warn"); });
  }, offline);
}
start();
</script>
"""


def main() -> None:
    lines = open(DOC, encoding="utf-8").read().splitlines()
    items = items_of(lines)
    rules = sum(1 for i in items if i["id"].startswith("rule-"))
    meta = ("%d rules, %d calls and names \u00b7 from docs/terminology_proposal.md \u00b7 A is Claude's lean"
            % (rules, len(items) - rules))
    page = PAGE.replace("__META__", html.escape(meta)).replace("__ITEMS__", json.dumps(items, ensure_ascii=False).replace("</", "<\\/"))
    sys.stdout.write(page)


if __name__ == "__main__":
    main()
