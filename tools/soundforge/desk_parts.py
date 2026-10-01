"""Every shipped track's melodic parts as notes, for the Melody Desk (the artifact Ryan
scores on, 30 September): one JSON document per track and voice into out/desk/, which a
session seeds into the desk's store (collection `parts`) so a part can be loaded into the
roll and edited.

    tools/spriter/.venv/bin/python tools/soundforge/desk_parts.py            # every track
    tools/spriter/.venv/bin/python tools/soundforge/desk_parts.py music_hold_the_line

Each track is built with `groove` swapped for a capture, so the recipe runs (kits and all)
but nothing is mixed. A voice's notes come from the same walk the engine does: riff mode
from its pattern letters, chord mode from the bar's chord, stabs and pads as the chord's
tones. Pitches are semitones above E2, the forge's root; steps are the section's own (a
12-step bar is flagged, since the desk draws sixteen)."""
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge  # noqa: E402

TITLES = {
    "music_far_bank": "The Far Bank", "music_hold_the_line": "Hold The Line", "music_low_ground": "Low Ground",
    "music_night_shift": "Night Shift", "music_crossing": "The Crossing", "music_full_bore": "Full Bore",
}
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out", "desk")
WINDOW = 16   # the desk's longest roll, in bars


def capture(name):
    got = {}

    def fake_groove(bpm, form, kit, drums, chords, voices, pad=None, meter=None, **kw):
        got.update(bpm=bpm, form=form.replace(" ", ""), chords=chords, voices=voices, pad=pad, meter=meter)
        return np.zeros(8)

    real = forge.groove
    forge.groove = fake_groove
    try:
        forge.SOUNDS[name]()
    finally:
        forge.groove = real
    return got


def runs_of(form):
    out, b0 = [], 0
    while b0 < len(form):
        e0 = b0
        while e0 < len(form) and form[e0] == form[b0]:
            e0 += 1
        out.append((b0, e0))
        b0 = e0
    return out


def voice_notes(g, v):
    """Every note of a voice across the whole form: (step, pitch, length in steps)."""
    form, meter, chords = g["form"], g["meter"], g["chords"]
    steps, starts, _ = forge._bars(form, meter)
    total = sum(steps)
    step_bar = []
    for b, s in enumerate(steps):
        step_bar.extend([b] * s)
    s = forge._steps(form, v["pat"], meter)
    per_bar = forge._chords_per_bar(form, chords)
    mode = v.get("mode", "riff")
    octave = v.get("octave", 0)
    notes = []
    if mode == "riff":
        i = 0
        while i < len(s):
            c = s[i]
            if c in ".-":
                i += 1
                continue
            semis = int(c) if c.isdigit() else forge.NOTE[c]
            length = 1
            while i + length < len(s) and s[i + length] == "-":
                length += 1
            notes.append((i, semis + 12 * octave, length))
            i += length
    elif mode == "chord":
        dur = max(1, int(round(v.get("dur", 1.6))))
        for i, c in enumerate(s):
            if not c.isdigit() or i >= total or not per_bar[step_bar[i]]:
                continue
            semis = per_bar[step_bar[i]]
            k = int(c)
            notes.append((i, semis[k % len(semis)] + 12 * (k // len(semis)) + 12 * octave, dur))
    elif mode == "stab":
        dur = max(1, int(round(v.get("dur", 1.2))))
        for i, c in enumerate(s):
            if c == "x" and i < total and per_bar[step_bar[i]]:
                for semi in per_bar[step_bar[i]]:
                    notes.append((i, semi + 12 * octave, dur))
    return notes


def pad_notes(g, pad):
    """A pad as its chord's tones held a bar at a time, in the sections it plays."""
    form, meter, chords = g["form"], g["meter"], g["chords"]
    steps, starts, _ = forge._bars(form, meter)
    per_bar = forge._chords_per_bar(form, chords)
    secs = pad.get("sections", form)
    skip = pad.get("skip", {})
    own = pad.get("chord")
    runs = runs_of(form)

    def run_start(i):
        for r0, r1 in runs:
            if r0 <= i < r1:
                return r0
        return 0

    notes = []
    for b in range(len(form)):
        c = own if (own and per_bar[b]) else per_bar[b]
        if not c or form[b] not in secs or b - run_start(b) < int(skip.get(form[b], 0)):
            continue
        for semi in c:
            notes.append((starts[b], semi + 12 * int(pad.get("octave", 0)), steps[b]))
    return notes


def sections(g, notes):
    """Notes cut into the form's runs, each at most WINDOW bars, relative to the run's start."""
    form, meter = g["form"], g["meter"]
    steps, starts, _ = forge._bars(form, meter)
    total = sum(steps)
    out = []
    for r0, r1 in runs_of(form):
        for c0 in range(r0, r1, WINDOW):
            c1 = min(r1, c0 + WINDOW)
            s0 = starts[c0]
            s1 = starts[c1] if c1 < len(form) else total
            inside = [(s - s0, p, l) for (s, p, l) in notes if s0 <= s < s1]
            if not inside:
                continue
            spb = sorted(set(steps[c0:c1]))
            out.append({
                "key": form[c0], "bar": c0 + 1, "bars": c1 - c0,
                "stepsPerBar": spb[0] if len(spb) == 1 else spb,
                "notes": [{"s": s, "p": p, "l": l} for (s, p, l) in sorted(inside, key=lambda n: (n[0], -n[1]))],
            })
    return out


def export(name):
    g = capture(name)
    docs = []
    for vi, v in enumerate(g["voices"]):
        notes = voice_notes(g, v)
        secs = sections(g, notes)
        if not secs:
            continue
        mode = v.get("mode", "riff")
        docs.append({
            "id": "%s__v%02d_%s" % (name, vi, v["inst"]),
            "track": name, "trackName": TITLES.get(name, name), "bpm": g["bpm"], "form": g["form"],
            "voice": vi, "inst": v["inst"], "mode": mode, "octave": v.get("octave", 0), "gain": v.get("gain", 0.4),
            "label": "%s (%s)" % (v["inst"], mode) if mode != "riff" else v["inst"],
            "sections": secs,
        })
    pads = g["pad"] if isinstance(g["pad"], list) else ([g["pad"]] if g["pad"] else [])
    for pi, pad in enumerate(pads):
        secs = sections(g, pad_notes(g, pad))
        if not secs:
            continue
        docs.append({
            "id": "%s__p%02d_%s" % (name, pi, pad["inst"]),
            "track": name, "trackName": TITLES.get(name, name), "bpm": g["bpm"], "form": g["form"],
            "voice": 100 + pi, "inst": pad["inst"], "mode": "pad", "octave": int(pad.get("octave", 0)), "gain": pad.get("gain", 0.2),
            "label": "%s (pad)" % pad["inst"],
            "sections": secs,
        })
    return docs


def main(argv):
    """One JSON file per track (document `parts/<track>`), its parts inside, so the desk
    reads six documents and a session seeds them in one batch."""
    names = argv or [n for n in forge.SOUNDS if n.startswith("music_")]
    os.makedirs(OUT, exist_ok=True)
    for name in names:
        docs = export(name)
        body = {
            "track": name, "trackName": TITLES.get(name, name), "bpm": docs[0]["bpm"] if docs else None,
            "form": docs[0]["form"] if docs else "",
            "parts": [{k: d[k] for k in ("voice", "inst", "mode", "octave", "gain", "label", "sections")} for d in docs],
        }
        path = os.path.join(OUT, name + ".json")
        with open(path, "w") as f:
            json.dump(body, f, separators=(",", ":"))
        print("%-24s %7d bytes %3d parts %5d notes" % (name, os.path.getsize(path), len(docs),
                                                     sum(len(s["notes"]) for d in docs for s in d["sections"])))
    print("into %s" % OUT)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
