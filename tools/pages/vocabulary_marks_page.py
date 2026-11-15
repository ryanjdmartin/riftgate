#!/usr/bin/env python3
"""The vocabulary pass's table as a page Ryan marks on (15 November: "I just need to see them
all in one place to mark them").

Reads docs/vocabulary_table.md, the one home of the table, and prints the page: every rider,
buff and debuff as a row with four marks (KEEP, CHANGE, CUT, ASK) and a note. The marks live
in the page's database, collection `marks`, a document a row keyed by the row's name as a
slug, so a session reads them back with ArtifactData and folds them into the proposal.

    python3 tools/pages/vocabulary_marks_page.py > /tmp/vocabulary_marks.html

The page's link is in docs/status.md, Pages. Publish with capabilities {"db": {}}.
"""

import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TABLE = os.path.join(ROOT, "docs", "vocabulary_table.md")


def slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


def rows_of(text: str) -> list:
    """The table's rows in order: {"group": title} for a heading row, else a row's cells."""
    out = []
    seen = set()
    for line in text.splitlines():
        if not line.startswith("|") or line.startswith("|---") or line.startswith("| Name |"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) != 4:
            raise SystemExit("a row of %d cells, not four: %s" % (len(cells), line[:80]))
        heading = re.fullmatch(r"\*\*(.+)\*\*", cells[0])
        if heading and not any(cells[1:]):
            out.append({"group": heading.group(1)})
            continue
        rid = slug(cells[0])
        if rid in seen:
            raise SystemExit("two rows named alike: " + cells[0])
        seen.add(rid)
        out.append({"id": rid, "name": cells[0], "type": cells[1], "effect": cells[2], "where": cells[3]})
    if not out:
        raise SystemExit("no table in " + TABLE)
    return out


PAGE = r"""<title>Vocabulary Marks</title>
<meta name="claude:viewport-fit-sides" content="cover">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Barlow:wght@400;500;600&family=Barlow+Semi+Condensed:wght@600&family=Share+Tech+Mono&display=swap">
<style>
/* layout: a sticky strip of filters over one long ruled list; a row is four columns and its marks on a desk, a stacked card on a phone */
:root {
  --ground: #f2f4f6; --panel: #ffffff; --ink: #18202a; --muted: #5b6876; --rule: #cfd6dd;
  --accent: #1d5fc4; --accent-ink: #ffffff; --tint: #e3ecf9;
  --body: "Barlow", "Segoe UI", system-ui, sans-serif;
  --head: "Barlow Semi Condensed", "Barlow", "Segoe UI", system-ui, sans-serif;
  --mono: "Share Tech Mono", ui-monospace, "SFMono-Regular", Menlo, Consolas, monospace;
}
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) {
  --ground: #11161c; --panel: #19212a; --ink: #e6ebf0; --muted: #9aa7b4; --rule: #33404d;
  --accent: #8ab8ff; --accent-ink: #0c1420; --tint: #1f2f45; color-scheme: dark } }
:root[data-theme="dark"] {
  --ground: #11161c; --panel: #19212a; --ink: #e6ebf0; --muted: #9aa7b4; --rule: #33404d;
  --accent: #8ab8ff; --accent-ink: #0c1420; --tint: #1f2f45; color-scheme: dark }
body { background: var(--ground); color: var(--ink); font: 400 16px/1.45 var(--body); }
body::before { content: ""; position: fixed; inset: 0 0 auto; height: env(safe-area-inset-top, 0px); z-index: 10; background: var(--ground); }
.wrap { max-width: 1280px; margin: 0 auto; padding-block: 20px 56px; padding-left: max(16px, env(safe-area-inset-left, 0px)); padding-right: max(16px, env(safe-area-inset-right, 0px)); display: flex; flex-direction: column; gap: 14px; }
h1 { font: 600 30px/1.1 var(--head); margin: 0; text-wrap: balance; }
.lede { margin: 0; max-width: 65ch; color: var(--muted); }
.strip { position: sticky; top: env(safe-area-inset-top, 0px); z-index: 5; background: var(--ground); padding-block: 8px; display: flex; flex-wrap: wrap; gap: 8px 14px; align-items: center; border-bottom: 2px solid var(--ink); }
.filters { display: flex; flex-wrap: wrap; gap: 6px; }
.count { font: 14px var(--mono); color: var(--muted); margin-left: auto; text-align: right; }
.state { font: 14px var(--mono); color: var(--muted); flex-basis: 100%; }
.state[data-kind="warn"] { color: var(--ink); font-weight: 600; }
button { font: inherit; color: inherit; }
.chip, .mark { font: 14px var(--mono); letter-spacing: .04em; text-transform: uppercase; background: var(--panel); border: 1.5px solid var(--rule); padding: 7px 10px; min-height: 38px; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; }
.chip[aria-pressed="true"] { background: var(--ink); color: var(--ground); border-color: var(--ink); }
.chip:focus-visible, .mark:focus-visible, textarea:focus-visible { outline: 3px solid var(--accent); outline-offset: 2px; }
h2 { font: 600 20px/1.2 var(--head); margin: 22px 0 0; padding-bottom: 6px; border-bottom: 1.5px solid var(--ink); display: flex; gap: 10px; align-items: baseline; }
h2 span { font: 13px var(--mono); color: var(--muted); }
.row { display: grid; grid-template-columns: minmax(0, 15ch) minmax(0, 15ch) minmax(0, 1fr) minmax(0, 1fr) 232px; gap: 6px 18px; padding-block: 12px; border-bottom: 1px solid var(--rule); align-items: start; }
.name { font: 600 17px/1.25 var(--body); overflow-wrap: anywhere; }
.type { font: 13px/1.35 var(--mono); color: var(--muted); text-transform: uppercase; letter-spacing: .03em; overflow-wrap: anywhere; }
.effect, .where { overflow-wrap: anywhere; }
.where { color: var(--muted); }
.lab { display: none; font: 12px var(--mono); text-transform: uppercase; letter-spacing: .06em; color: var(--muted); }
.act { display: flex; flex-direction: column; gap: 6px; min-width: 0; }
.marks { display: grid; grid-template-columns: repeat(4, 1fr); gap: 4px; }
.mark { justify-content: center; padding: 7px 4px; font-size: 13px; }
.mark i { font-style: normal; font-weight: 700; }
.mark[data-m="change"] { border-style: dashed; }
.mark[data-m="ask"] { border-style: dotted; }
.mark[aria-pressed="true"] { background: var(--accent); color: var(--accent-ink); border-color: var(--accent); border-style: solid; }
.row[data-mark="cut"] .name { text-decoration: line-through; text-decoration-thickness: 2px; }
.row[data-mark]:not([data-mark=""]) { background: linear-gradient(90deg, var(--tint), transparent 60%); }
textarea { font: 15px/1.35 var(--body); color: var(--ink); background: var(--panel); border: 1.5px solid var(--rule); padding: 7px 8px; width: 100%; min-height: 38px; resize: vertical; box-sizing: border-box; }
.empty { padding-block: 28px; color: var(--muted); }
@media (max-width: 900px) {
  .row { grid-template-columns: minmax(0, 1fr); gap: 4px; }
  .lab { display: block; margin-top: 4px; }
  .act { margin-top: 6px; }
  .count { margin-left: 0; text-align: left; }
}
@media (prefers-reduced-motion: no-preference) { .mark, .chip { transition: background-color .12s, color .12s; } }
</style>
<div class="wrap">
  <h1>Vocabulary Marks</h1>
  <p class="lede">Every rider, buff and debuff in the game as it stands, with what the pass has decided or proposed. Mark each row and leave a note where one helps. The marks save as you go and Claude reads them back.</p>
  <div class="strip">
    <div class="filters" id="filters" role="group" aria-label="Show"></div>
    <div class="count" id="count"></div>
    <div class="state" id="state" role="status">Loading the marks.</div>
  </div>
  <div id="list"></div>
</div>
<script>
const ROWS = __ROWS__;
const MARKS = [["keep", "✓", "Keep"], ["change", "Δ", "Change"], ["cut", "✕", "Cut"], ["ask", "?", "Ask"]];
const FILTERS = [["all", "All"], ["none", "Unmarked"], ["keep", "Keep"], ["change", "Change"], ["cut", "Cut"], ["ask", "Ask"], ["noted", "Noted"]];
const items = ROWS.filter(r => !r.group);
let marks = {};          // id -> {mark, note}
let db = null, local = false, filter = "all";
const queues = {}, timers = {};
const $ = id => document.getElementById(id);
function el(tag, attrs, kids) {
  const n = document.createElement(tag);
  for (const k in attrs || {}) { if (k === "text") n.textContent = attrs[k]; else n.setAttribute(k, attrs[k]); }
  for (const c of kids || []) n.appendChild(c);
  return n;
}
function said(text, kind) { const s = $("state"); s.textContent = text; s.dataset.kind = kind || ""; }
function of(id) { return marks[id] || {mark: "", note: ""}; }
function shows(r) {
  const m = of(r.id);
  if (filter === "all") return true;
  if (filter === "none") return !m.mark && !m.note;
  if (filter === "noted") return !!m.note;
  return m.mark === filter;
}
function build() {
  const list = $("list");
  let group = null;
  for (const r of ROWS) {
    if (r.group) {
      group = el("section", {"data-group": r.group}, [el("h2", {}, [document.createTextNode(r.group), el("span", {})])]);
      list.appendChild(group);
      continue;
    }
    const row = el("div", {class: "row", id: "row-" + r.id, "data-mark": ""});
    row.appendChild(el("div", {class: "name", text: r.name}));
    row.appendChild(el("div", {class: "type", text: r.type}));
    row.appendChild(el("div", {class: "effect"}, [el("div", {class: "lab", text: "Effect"}), document.createTextNode(r.effect)]));
    row.appendChild(el("div", {class: "where"}, [el("div", {class: "lab", text: "Where it exists"}), document.createTextNode(r.where)]));
    const bar = el("div", {class: "marks", role: "group", "aria-label": "Mark " + r.name});
    for (const [m, glyph, label] of MARKS) {
      const b = el("button", {class: "mark", type: "button", "data-m": m, "aria-pressed": "false", id: "m-" + r.id + "-" + m}, [el("i", {text: glyph}), document.createTextNode(label)]);
      b.addEventListener("click", () => { const cur = of(r.id); put(r, {mark: cur.mark === m ? "" : m, note: cur.note}); });
      bar.appendChild(b);
    }
    const note = el("textarea", {id: "n-" + r.id, rows: "1", placeholder: "Note", "aria-label": "Note on " + r.name});
    note.addEventListener("input", () => { clearTimeout(timers[r.id]); timers[r.id] = setTimeout(() => keep(r, note), 900); });
    note.addEventListener("blur", () => { clearTimeout(timers[r.id]); keep(r, note); });
    row.appendChild(el("div", {class: "act"}, [bar, note]));
    group.appendChild(row);
  }
  list.appendChild(el("div", {class: "empty", id: "empty", hidden: ""}, [document.createTextNode("No row carries that mark yet.")]));
  const f = $("filters");
  for (const [id, label] of FILTERS) {
    const b = el("button", {class: "chip", type: "button", id: "f-" + id, "aria-pressed": String(id === filter)}, [document.createTextNode(label), el("span", {})]);
    b.addEventListener("click", () => { filter = id; try { localStorage.setItem("vocab-filter", id); } catch (e) {} paint(); });
    f.appendChild(b);
  }
}
function keep(r, note) { const cur = of(r.id); const text = note.value.trim(); if (text !== cur.note) put(r, {mark: cur.mark, note: text}); }
function paint() {
  const tally = {all: items.length, none: 0, keep: 0, change: 0, cut: 0, ask: 0, noted: 0};
  let shown = 0;
  for (const r of items) {
    const m = of(r.id), row = $("row-" + r.id);
    row.dataset.mark = m.mark;
    for (const [k] of MARKS) $("m-" + r.id + "-" + k).setAttribute("aria-pressed", String(m.mark === k));
    const note = $("n-" + r.id);
    if (document.activeElement !== note && note.value.trim() !== m.note) note.value = m.note;
    if (m.mark) tally[m.mark]++;
    if (m.note) tally.noted++;
    if (!m.mark && !m.note) tally.none++;
    const on = shows(r);
    row.hidden = !on;
    if (on) shown++;
  }
  for (const s of document.querySelectorAll("section[data-group]")) {
    const rows = [...s.querySelectorAll(".row")], live = rows.filter(x => !x.hidden).length;
    s.hidden = live === 0;
    s.querySelector("h2 span").textContent = live === rows.length ? rows.length + " rows" : live + " of " + rows.length;
  }
  for (const [id] of FILTERS) { const b = $("f-" + id); b.setAttribute("aria-pressed", String(id === filter)); b.querySelector("span").textContent = tally[id]; }
  $("empty").hidden = shown > 0;
  $("count").textContent = "Marked " + (items.length - tally.none) + " of " + items.length;
}
function put(r, next) {
  marks[r.id] = next;
  paint();
  if (local || !db) {
    try { localStorage.setItem("vocab-marks", JSON.stringify(marks)); } catch (e) {}
    return;
  }
  said("Saving.");
  const ref = db.doc("marks/" + r.id);
  const body = {name: r.name, mark: next.mark, note: next.note, at: new Date().toISOString()};
  const write = () => (next.mark || next.note ? ref.set(body) : ref.delete());
  queues[r.id] = (queues[r.id] || Promise.resolve()).then(write).then(
    () => said("Saved."),
    e => said(e && e.code === "invalid_argument" ? "This view cannot save marks: it reads only." : "A mark did not save. Tap it again in a moment.", "warn"));
}
function start() {
  try { const f = localStorage.getItem("vocab-filter"); if (FILTERS.some(x => x[0] === f)) filter = f; } catch (e) {}
  build();
  paint();
  const use = window.claude && window.claude.use ? window.claude.use.bind(window.claude) : null;
  const offline = () => {
    local = true;
    try { marks = JSON.parse(localStorage.getItem("vocab-marks") || "{}") || {}; } catch (e) { marks = {}; }
    said("Marks are kept on this device only: this view cannot reach the page's store.", "warn");
    paint();
  };
  if (!use) return offline();
  use("db").then(got => {
    if (!got) return offline();
    db = got;
    const slow = setTimeout(() => said("The marks can't be reached yet. Still trying.", "warn"), 10000);
    db.collection("marks").onSnapshot(snap => {
      const next = {};
      for (const d of snap.docs) { const b = d.data() || {}; next[d.id] = {mark: String(b.mark || ""), note: String(b.note || "")}; }
      marks = next;
      if (!snap.metadata.fromCache) { clearTimeout(slow); if ($("state").textContent !== "Saving.") said(snap.size ? "Saved." : "No marks yet. Tap one to begin."); }
      paint();
    }, () => { clearTimeout(slow); said("The marks can't be reached in this view.", "warn"); });
  }, offline);
}
start();
</script>
"""


def main() -> None:
    rows = rows_of(open(TABLE, encoding="utf-8").read())
    sys.stdout.write(PAGE.replace("__ROWS__", json.dumps(rows, ensure_ascii=False)))


if __name__ == "__main__":
    main()
