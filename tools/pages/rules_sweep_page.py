"""Renders docs/rules_sweep_proposal.md as the page Ryan marks it on (the status has the link): each
item a card with its words and Claude's suggestion, and three marks, Cut, Lean and Keep, with a note.
His marks are documents in the page's database (collection "marks", one a item, id the item's, e.g.
"V1"): {item, mark, note, by, day, updated}; a session reads them with ArtifactData and folds them.
Run from the repo root after the proposal changes, and publish the output to the page's URL:
    python3 tools/pages/rules_sweep_page.py > /tmp/rules_sweep.html
"""
import html
import json
import pathlib
import re
import sys

SRC = pathlib.Path("docs/rules_sweep_proposal.md")
FIELDS = ["Kind", "Where", "It says", "His words", "A cut", "Claude"]


def parse(text):
    """The proposal as {title, intro, sections}; a section holds items (### ...) or a body."""
    lines = text.split("\n")
    title = lines[0].lstrip("# ").strip()
    intro, sections, cur, item = [], [], None, None
    field = None
    for raw in lines[1:]:
        if raw.startswith("## "):
            cur = {"title": raw[3:].strip(), "items": [], "body": []}
            sections.append(cur)
            item, field = None, None
            continue
        if raw.startswith("### "):
            m = re.match(r"### (\w+)\. (.*)", raw)
            item = {"id": m.group(1), "title": m.group(2).strip(), "fields": {}, "parts": {}}
            cur["items"].append(item)
            field = None
            continue
        if item is not None:
            m = re.match(r"- \*\*(.+?):\*\* ?(.*)", raw)
            if m:
                field = m.group(1)
                item["fields"][field] = m.group(2).strip()
                continue
            m = re.match(r"  - (.*)", raw)
            if m and field:
                item["parts"].setdefault(field, []).append(m.group(1).strip())
                continue
            if raw.startswith("  ") and field and raw.strip():
                if item["parts"].get(field):
                    item["parts"][field][-1] += " " + raw.strip()
                else:
                    item["fields"][field] += " " + raw.strip()
            continue
        (cur["body"] if cur else intro).append(raw)
    for s in sections:
        for it in s["items"]:
            missing = [f for f in FIELDS if f not in it["fields"]]
            if missing:
                sys.exit(f"{it['id']}: missing {missing}")
            claude = it["fields"]["Claude"].lower()
            it["suggest"] = next((m for m in ("cut", "lean", "keep") if claude.startswith(m)), "")
            if not it["suggest"]:
                sys.exit(f"{it['id']}: Claude's suggestion is not cut, lean or keep")
    return {"title": title, "intro": intro, "sections": sections}


def inline(s):
    """`code` and **bold** as the proposal writes them, everything else escaped."""
    out = []
    for i, part in enumerate(re.split(r"(`[^`]+`)", s)):
        if i % 2:
            out.append("<code>" + html.escape(part[1:-1]) + "</code>")
        else:
            t = html.escape(part, quote=False)
            out.append(re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", t))
    return "".join(out)


def blocks(lines):
    """Paragraphs and flat bullet lists, as HTML."""
    out, para, items = [], [], []

    def flush():
        if para:
            out.append("<p>" + inline(" ".join(para)) + "</p>")
            para.clear()
        if items:
            out.append("<ul>" + "".join("<li>" + inline(x) + "</li>" for x in items) + "</ul>")
            items.clear()

    for raw in lines:
        if not raw.strip():
            flush()
        elif raw.startswith("- "):
            if para:
                flush()
            items.append(raw[2:].strip())
        elif raw.startswith("  ") and items:
            items[-1] += " " + raw.strip()
        else:
            if items:
                flush()
            para.append(raw.strip())
    flush()
    return "".join(out)


def main():
    doc = parse(SRC.read_text(encoding="utf-8"))
    data = []
    for s in doc["sections"]:
        if s["items"]:
            for it in s["items"]:
                f = it["fields"]
                data.append({
                    "id": it["id"], "section": s["title"], "title": inline(it["title"]),
                    "kind": inline(f["Kind"]), "where": inline(f["Where"]),
                    "says": inline(f["It says"]), "says_parts": [inline(p) for p in it["parts"].get("It says", [])],
                    "words": inline(f["His words"]), "cut": inline(f["A cut"]),
                    "claude": inline(f["Claude"]), "suggest": it["suggest"],
                })
    plain = [{"title": s["title"], "html": blocks(s["body"])} for s in doc["sections"] if not s["items"]]
    marked = [s["title"] for s in doc["sections"] if s["items"]]
    payload = json.dumps({"items": data, "plain": plain, "sections": marked}, ensure_ascii=False).replace("</", "<\\/")
    page = TEMPLATE.replace("%TITLE%", "Riftgate Rules Sweep").replace("%INTRO%", blocks(doc["intro"])).replace("%DATA%", payload)
    sys.stdout.write(page)


TEMPLATE = r"""<title>%TITLE%</title>
<meta name="claude:viewport-fit-sides" content="cover">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=IBM+Plex+Sans:ital,wght@0,400;0,500;0,600;1,400&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
/* Layout: one reading column of cards, a sticky bar with the count and the filters; the hangar's
   ground, paper and ink, its display, body and mono faces. A mark is told by fill and its word,
   never by hue alone. */
:root{
  --ground:#ECE8DF; --paper:#F6F3EC; --sunk:#E2DDD2; --ink:#1F2226; --ink-2:#4B5058; --ink-3:#6E737B;
  --rule:#CFC9BC; --rule-strong:#B4AD9F; --cut:#9A2E25; --lean:#2F5E95; --keep:#33663F;
  --display:"Barlow Condensed","Arial Narrow",Arial,sans-serif;
  --body:"IBM Plex Sans","Helvetica Neue",Arial,sans-serif;
  --mono:"IBM Plex Mono",Menlo,monospace;
}
@media (prefers-color-scheme: dark){
  :root:not([data-theme="light"]){
    --ground:#191B1F; --paper:#22252B; --sunk:#1D2025; --ink:#E6E2D8; --ink-2:#B6B1A6; --ink-3:#8E8A82;
    --rule:#383C44; --rule-strong:#4A505A; --cut:#F08A7E; --lean:#8AB4EA; --keep:#86C894; color-scheme:dark;
  }
}
:root[data-theme="dark"]{
  --ground:#191B1F; --paper:#22252B; --sunk:#1D2025; --ink:#E6E2D8; --ink-2:#B6B1A6; --ink-3:#8E8A82;
  --rule:#383C44; --rule-strong:#4A505A; --cut:#F08A7E; --lean:#8AB4EA; --keep:#86C894; color-scheme:dark;
}
*{box-sizing:border-box}
body{margin:0;background:var(--ground);color:var(--ink);font:15px/1.5 var(--body);
  padding-left:max(16px,env(safe-area-inset-left,0px));padding-right:max(16px,env(safe-area-inset-right,0px))}
body::before{content:"";position:fixed;inset:0 0 auto;height:env(safe-area-inset-top,0px);z-index:10;background:var(--ground)}
.wrap{max-width:820px;margin:0 auto;padding-block:14px 64px}
h1{font:800 32px/1.05 var(--display);text-transform:uppercase;letter-spacing:.02em;margin:6px 0 10px;text-wrap:balance}
.eyebrow{font:500 11px/1.4 var(--mono);letter-spacing:.12em;text-transform:uppercase;color:var(--ink-3)}
.intro{color:var(--ink-2);max-width:68ch}
.intro p{margin:0 0 10px} .intro ul{margin:0 0 10px;padding-left:20px} .intro li{margin:2px 0}
code{font:400 .86em var(--mono);background:var(--sunk);padding:0 3px;border-radius:2px;overflow-wrap:anywhere}
.bar{position:sticky;top:env(safe-area-inset-top,0px);z-index:5;background:var(--ground);border-bottom:1px solid var(--rule);padding-block:10px 8px;margin-top:14px;display:flex;flex-direction:column;gap:8px}
.count{display:flex;gap:12px;flex-wrap:wrap;align-items:baseline;font-size:13px;color:var(--ink-2)}
.count b{font-variant-numeric:tabular-nums;color:var(--ink)}
.meter{height:8px;border:1px solid var(--rule-strong);border-radius:2px;background:var(--sunk);overflow:hidden;display:flex}
.meter span{display:block;height:100%}
.meter .m-cut{background:var(--cut)} .meter .m-lean{background:repeating-linear-gradient(45deg,var(--lean) 0 3px,transparent 3px 5px)} .meter .m-keep{background:repeating-linear-gradient(90deg,var(--keep) 0 2px,transparent 2px 4px)}
.chips{display:flex;gap:5px;flex-wrap:nowrap;overflow-x:auto;scrollbar-width:none;padding-bottom:2px}
.chips::-webkit-scrollbar{display:none}
.chip{flex:0 0 auto}
.chip{border:1px solid var(--rule-strong);background:transparent;color:var(--ink-2);border-radius:999px;padding:5px 10px;font:600 13px/1.1 var(--display);letter-spacing:.05em;text-transform:uppercase;cursor:pointer}
.chip .n{font:500 11px/1 var(--mono);margin-left:5px;color:var(--ink-3)}
.chip[aria-pressed="true"]{background:var(--ink);border-color:var(--ink);color:var(--ground)}
.chip[aria-pressed="true"] .n{color:inherit;opacity:.75}
.secnav{display:flex;gap:4px;flex-wrap:wrap;margin-top:12px}
.secnav a{font:600 12px/1.3 var(--display);letter-spacing:.06em;text-transform:uppercase;color:var(--ink-3);text-decoration:none;border:1px solid var(--rule);border-radius:3px;padding:3px 8px}
.secnav a:hover{color:var(--ink);border-color:var(--rule-strong)}
.status{font-size:12.5px;color:var(--ink-3);margin-top:8px}
.status.warn{color:var(--cut)}
h2{font:700 21px/1.1 var(--display);letter-spacing:.05em;text-transform:uppercase;margin:26px 0 8px;scroll-margin-top:160px}
.cards{display:flex;flex-direction:column;gap:10px}
.card{background:var(--paper);border:1px solid var(--rule);border-radius:3px;padding:12px 14px;display:flex;flex-direction:column;gap:8px;min-width:0;scroll-margin-top:160px}
.card.marked{border-left:4px solid var(--ink-3)}
.head{display:flex;gap:8px;align-items:baseline;flex-wrap:wrap}
.id{font:600 12px/1 var(--mono);color:var(--ink-3)}
.head h3{margin:0;font:700 18px/1.2 var(--display);letter-spacing:.02em;text-wrap:balance;flex:1 1 260px;min-width:0}
.kind{font:600 10px/1.6 var(--display);letter-spacing:.1em;text-transform:uppercase;border:1.5px solid currentColor;border-radius:2px;padding:0 6px;color:var(--ink-2);white-space:nowrap}
dl{display:grid;grid-template-columns:auto minmax(0,1fr);gap:4px 12px;margin:0;font-size:14px}
dt{font:600 11px/1.7 var(--display);letter-spacing:.1em;text-transform:uppercase;color:var(--ink-3);white-space:nowrap}
dd{margin:0;color:var(--ink-2);overflow-wrap:anywhere;min-width:0}
dd ul{margin:2px 0 0;padding-left:18px} dd li{margin:2px 0}
dd.says{color:var(--ink)}
.foot{display:flex;gap:10px;align-items:center;flex-wrap:wrap;justify-content:space-between;border-top:1px dashed var(--rule);padding-top:8px}
.claude{font-size:13px;color:var(--ink-2)}
.claude b{font:600 11px/1 var(--display);letter-spacing:.1em;text-transform:uppercase;color:var(--ink-3);margin-right:4px}
.marks{display:flex;gap:6px;flex-wrap:wrap}
.mk{min-width:74px;border:1.5px solid var(--rule-strong);background:transparent;color:var(--ink);border-radius:4px;padding:8px 12px;font:700 15px/1 var(--display);letter-spacing:.08em;text-transform:uppercase;cursor:pointer}
.mk.cut{border-color:var(--cut);color:var(--cut)} .mk.lean{border-color:var(--lean);color:var(--lean)} .mk.keep{border-color:var(--keep);color:var(--keep)}
.mk[aria-pressed="true"]{color:var(--paper)}
.mk.cut[aria-pressed="true"]{background:var(--cut)} .mk.lean[aria-pressed="true"]{background:var(--lean)} .mk.keep[aria-pressed="true"]{background:var(--keep)}
.mk[aria-pressed="true"]::before{content:"\2713\00a0"}
.mk:disabled{opacity:.45;cursor:default}
.tag{font:600 10px/1.6 var(--display);letter-spacing:.1em;text-transform:uppercase;border:1px dashed var(--ink-3);border-radius:2px;padding:0 6px;color:var(--ink-2)}
.note{display:flex;flex-direction:column;gap:6px}
.note textarea{width:100%;min-height:42px;padding:8px 10px;border:1px solid var(--rule-strong);border-radius:4px;background:var(--ground);color:var(--ink);font:inherit;font-size:14.5px;line-height:1.45;resize:vertical}
.note .saved{font-size:12px;color:var(--ink-3)}
.linkbtn{border:0;background:none;padding:0;font:inherit;font-size:13px;color:var(--ink-2);text-decoration:underline;text-underline-offset:2px;cursor:pointer}
.plain{color:var(--ink-2);max-width:70ch}
.plain p{margin:0 0 10px} .plain ul{margin:0 0 10px;padding-left:20px} .plain li{margin:3px 0}
.bulk{margin-top:28px;padding:12px 14px;border:1px dashed var(--rule-strong);border-radius:4px;display:flex;flex-direction:column;gap:8px}
.bulk p{margin:0;font-size:14px;color:var(--ink-2)}
.btn{border:1px solid var(--rule-strong);background:var(--paper);color:var(--ink);padding:8px 12px;border-radius:4px;font:700 14px/1 var(--display);letter-spacing:.06em;text-transform:uppercase;cursor:pointer}
.btn.primary{background:var(--ink);border-color:var(--ink);color:var(--ground)}
.btn:disabled{opacity:.45;cursor:default}
.row{display:flex;gap:8px;flex-wrap:wrap;align-items:center}
.empty{color:var(--ink-3);padding:12px 0}
button:focus-visible,textarea:focus-visible,a:focus-visible{outline:2px solid var(--ink);outline-offset:2px}
@media (max-width:520px){dl{grid-template-columns:1fr;gap:1px}dt{margin-top:4px}.mk{flex:1 1 0;min-width:0}}
</style>

<div class="wrap">
  <span class="eyebrow">Riftgate · for your marks</span>
  <h1>The rules sweep</h1>
  <div class="intro">%INTRO%</div>
  <nav class="secnav" id="secnav" aria-label="Sections"></nav>
  <div class="status" id="status">Connecting to the page's database…</div>
  <div class="bar" id="bar">
    <div class="count" id="count"></div>
    <div class="meter" id="meter" role="img" aria-label="Marked so far"></div>
    <div class="chips" id="chips" role="group" aria-label="Show"></div>
  </div>
  <main id="main"></main>
  <div class="bulk" id="bulk"></div>
</div>
<script type="application/json" id="data">%DATA%</script>
<script>
const DATA = JSON.parse(document.getElementById("data").textContent);
const MARKS = [{id: "cut", label: "Cut"}, {id: "lean", label: "Lean"}, {id: "keep", label: "Keep"}];
const state = {db: null, can: false, marks: {}, show: "all", notes: {}, open: {}, confirm: false, busy: false};
try { const s = localStorage.getItem("sweep.show"); if (s) state.show = s; } catch (e) {}
const $ = (s) => document.querySelector(s);
const el = (tag, attrs = {}, ...kids) => {
  const n = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (k === "class") n.className = v;
    else if (k === "html") n.innerHTML = v;
    else if (k.startsWith("on")) n.addEventListener(k.slice(2), v);
    else if (v !== null && v !== undefined && v !== false) n.setAttribute(k, v === true ? "" : v);
  }
  for (const c of kids) if (c !== null && c !== undefined && c !== false) n.append(c);
  return n;
};
const slug = (s) => s.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
const markOf = (id) => (state.marks[id] && state.marks[id].mark) || "";
const noteOf = (id) => (state.marks[id] && state.marks[id].note) || "";
const day = () => new Date().toLocaleDateString("en-GB", {day: "numeric", month: "long"});
function setStatus(t, warn) { const s = $("#status"); s.textContent = t; s.classList.toggle("warn", !!warn); }

async function write(id, patch) {
  if (!state.db || !state.can) return false;
  const cur = state.marks[id] || {};
  const doc = {item: id, mark: cur.mark || "", note: cur.note || "", ...patch, by: "ryan", day: day(), updated: new Date().toISOString()};
  try {
    if (!doc.mark && !doc.note) { if (state.marks[id]) await state.db.doc("marks/" + id).delete(); delete state.marks[id]; }
    else { await state.db.doc("marks/" + id).set(doc); state.marks[id] = doc; }
    return true;
  } catch (e) { setStatus("Not saved: " + (e && e.code ? e.code : "the database refused it"), true); return false; }
}
async function setMark(id, m) { if (await write(id, {mark: markOf(id) === m ? "" : m})) render(); }

function visible(it) {
  const m = markOf(it.id);
  if (state.show === "open") return !m;
  if (state.show === "differs") return !!m && m !== it.suggest;
  if (MARKS.some(x => x.id === state.show)) return m === state.show;
  return true;
}
function counts() {
  const c = {total: DATA.items.length, marked: 0, cut: 0, lean: 0, keep: 0, differs: 0};
  for (const it of DATA.items) { const m = markOf(it.id); if (m) { c.marked++; c[m]++; if (m !== it.suggest) c.differs++; } }
  return c;
}
function renderBar() {
  const c = counts();
  $("#count").replaceChildren(...[el("span", {}, el("b", {}, String(c.marked)), ` of ${c.total} marked`),
    el("span", {}, `cut ${c.cut} · lean ${c.lean} · keep ${c.keep}`), c.differs ? el("span", {}, `${c.differs} unlike Claude's`) : null].filter(Boolean));
  const pct = (n) => `width:${(100 * n / c.total).toFixed(2)}%`;
  $("#meter").setAttribute("aria-label", `${c.marked} of ${c.total} marked: ${c.cut} cut, ${c.lean} lean, ${c.keep} keep`);
  $("#meter").replaceChildren(el("span", {class: "m-cut", style: pct(c.cut)}), el("span", {class: "m-lean", style: pct(c.lean)}), el("span", {class: "m-keep", style: pct(c.keep)}));
  const chip = (id, label, n) => el("button", {class: "chip", id: "show-" + id, "aria-pressed": String(state.show === id), onclick: () => { state.show = id; try { localStorage.setItem("sweep.show", id); } catch (e) {} render(); }}, label, el("span", {class: "n"}, String(n)));
  $("#chips").replaceChildren(chip("all", "All", c.total), chip("open", "To mark", c.total - c.marked), chip("cut", "Cut", c.cut), chip("lean", "Lean", c.lean), chip("keep", "Keep", c.keep), chip("differs", "Unlike Claude's", c.differs));
  $("#secnav").replaceChildren(...[...DATA.sections, ...DATA.plain.map(p => p.title)].map(t => el("a", {href: "#" + slug(t)}, t)));
}
function card(it) {
  const m = markOf(it.id), n = noteOf(it.id);
  const box = el("article", {class: "card" + (m ? " marked" : ""), id: "item-" + it.id});
  box.append(el("div", {class: "head"}, el("span", {class: "id"}, it.id), el("h3", {html: it.title}), el("span", {class: "kind", html: it.kind})));
  const dl = el("dl");
  const says = el("dd", {class: "says", html: it.says});
  if (it.says_parts.length) says.append(el("ul", {}, ...it.says_parts.map(p => el("li", {html: p}))));
  dl.append(el("dt", {}, "It says"), says, el("dt", {}, "His words"), el("dd", {html: it.words}), el("dt", {}, "A cut"), el("dd", {html: it.cut}), el("dt", {}, "Where"), el("dd", {html: it.where}));
  box.append(dl);
  const marks = el("div", {class: "marks", role: "group", "aria-label": "Your mark on " + it.id});
  for (const x of MARKS) marks.append(el("button", {class: "mk " + x.id, id: `mk-${it.id}-${x.id}`, "aria-pressed": String(m === x.id), disabled: !state.can, onclick: () => setMark(it.id, x.id)}, x.label));
  const claude = el("span", {class: "claude"}, el("b", {}, "Claude"), el("span", {html: it.claude}));
  if (m && m !== it.suggest) claude.append(" ", el("span", {class: "tag"}, "your mark differs"));
  box.append(el("div", {class: "foot"}, marks, claude));
  const open = state.open[it.id] || !!n;
  if (!open) { if (state.can) box.append(el("div", {}, el("button", {class: "linkbtn", onclick: () => { state.open[it.id] = true; render(); const t = document.getElementById("nt-" + it.id); if (t) t.focus(); }}, "Add a note"))); return box; }
  const ta = el("textarea", {id: "nt-" + it.id, rows: "2", placeholder: "What to keep, what to change, why", "aria-label": "Your note on " + it.id, disabled: !state.can});
  ta.value = state.notes[it.id] !== undefined ? state.notes[it.id] : n;
  let t = null;
  const send = async () => { clearTimeout(t); const v = ta.value.trim(); delete state.notes[it.id]; if (v !== n) { if (await write(it.id, {note: v})) renderBar(); } };
  ta.addEventListener("input", () => { state.notes[it.id] = ta.value; clearTimeout(t); t = setTimeout(send, 1500); });
  ta.addEventListener("change", send);
  box.append(el("div", {class: "note"}, ta, n ? el("span", {class: "saved"}, "Saved " + ((state.marks[it.id] || {}).day || "")) : null));
  return box;
}
function render() {
  // A redraw keeps the focus and the caret where they were (a note being typed, a mark tapped by key).
  const act = document.activeElement;
  const keep = act && act.id && /^(nt|mk|show|bulk)-/.test(act.id) ? {id: act.id, a: act.selectionStart, b: act.selectionEnd} : null;
  draw();
  if (keep) {
    const n = document.getElementById(keep.id);
    if (n) { n.focus({preventScroll: true}); if (typeof keep.a === "number" && n.setSelectionRange) try { n.setSelectionRange(keep.a, keep.b); } catch (e) {} }
  }
}
function draw() {
  renderBar();
  const main = $("#main"); main.replaceChildren();
  let shown = 0;
  for (const sec of DATA.sections) {
    const items = DATA.items.filter(it => it.section === sec && visible(it));
    shown += items.length;
    main.append(el("h2", {id: slug(sec)}, sec));
    if (!items.length) { main.append(el("p", {class: "empty"}, "Nothing here under this filter.")); continue; }
    main.append(el("div", {class: "cards"}, ...items.map(card)));
  }
  for (const p of DATA.plain) main.append(el("h2", {id: slug(p.title)}, p.title), el("div", {class: "plain", html: p.html}));
  renderBulk();
}
function renderBulk() {
  const box = $("#bulk"); box.replaceChildren();
  const rest = DATA.items.filter(it => !markOf(it.id));
  if (!state.can || !rest.length) { box.hidden = true; return; }
  box.hidden = false;
  box.append(el("p", {}, `${rest.length} item${rest.length === 1 ? "" : "s"} unmarked. You can mark the rest as Claude suggests in one go, after marking the ones you disagree with.`));
  if (!state.confirm) box.append(el("div", {class: "row"}, el("button", {class: "btn", id: "bulk-ask", onclick: () => { state.confirm = true; renderBulk(); }}, "Mark the rest as Claude suggests")));
  else box.append(el("div", {class: "row"},
    el("button", {class: "btn primary", id: "bulk-go", disabled: state.busy, onclick: async () => {
      state.busy = true; renderBulk();
      for (const it of rest) { if (!markOf(it.id)) await write(it.id, {mark: it.suggest}); }
      state.busy = false; state.confirm = false; render();
    }}, state.busy ? "Marking…" : `Yes, mark ${rest.length} as suggested`),
    el("button", {class: "btn", id: "bulk-no", disabled: state.busy, onclick: () => { state.confirm = false; renderBulk(); }}, "Cancel")));
}

render();
(async () => {
  const db = window.claude && window.claude.use ? await window.claude.use("db") : null;
  if (!db) { setStatus("Read only: the database did not load in this view. Open the page signed in, from its link, to mark it."); return; }
  state.db = db; state.can = true;
  try { const user = await window.claude.use("user"); if (user) { const w = await user.can("data.write"); if (w === false) state.can = false; } } catch (e) {}
  db.collection("marks").onSnapshot((snap) => {
    state.marks = {};
    for (const d of snap.docs) { const v = d.data(); if (v && v.item) state.marks[d.id] = v; }
    setStatus(state.can ? "Each mark saves as you tap it; tap it again to take it back. A session folds them." : "You can read the marks here but not make them.");
    render();
  }, (err) => { setStatus("Marks cannot sync: " + (err && err.code ? err.code : "unknown"), true); });
})();
</script>
"""

if __name__ == "__main__":
    main()
