"""Every shipped track's melodic parts as notes, for the Melody Desk (the artifact Ryan
scores on, 30 September): one JSON document per track and voice into out/desk/, which a
session seeds into the desk's store (collection `parts`) so a part can be loaded into the
roll and edited.

    tools/spriter/.venv/bin/python tools/soundforge/desk_parts.py            # every track
    tools/spriter/.venv/bin/python tools/soundforge/desk_parts.py music_hold_the_line

Each track is built with `groove` swapped for a capture, so the recipe runs (kits and all)
but nothing is mixed. A voice's notes come from the same walk the engine does: riff mode
from its pattern letters, chord mode from the bar's chord, stabs and pads as the chord's
tones. Pitches are semitones above E2, the forge's root, a quarter-tone half a semitone (a voice's
own `notes`, Hold The Line's X); a double-stop's fifth is a note of its own. Steps are the section's
own, and the desk draws a part's bars at its own length (16, 14 or 12 steps).

    tools/spriter/.venv/bin/python tools/soundforge/desk_parts.py --sketch hold_the_line_r22   # a sketch's X, as a part document

A sketch's document (SKETCHES) is one round of a sketch file's battle half, cut to the sections a
note asked about, under an id of its own (`parts/sketch_<round>`) so the desk lists it beside the
shipped tracks."""
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
        table = dict(forge.NOTE, **v["notes"]) if v.get("notes") else forge.NOTE
        fifth = (v.get("params") or {}).get("fifth")
        i = 0
        while i < len(s):
            c = s[i]
            if c in ".-":
                i += 1
                continue
            semis = int(c) if c.isdigit() else table[c]
            if isinstance(semis, (list, tuple)):   # a bent note ([from, to, wait, glide]) as the pitch it bends to
                semis = semis[1]
            length = 1
            while i + length < len(s) and s[i + length] == "-":
                length += 1
            notes.append((i, semis + 12 * octave, length))
            if fifth:   # a double-stop: the fifth on the next string, as real_bass plays it
                notes.append((i, semis + 7 + 12 * octave, length))
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
    return export_call(capture(name), name, TITLES.get(name, name))


def export_call(g, name, title, keys=None, labels=None):
    """A call's parts (its voices and pads), in the sections `keys` names where given, a voice's label
    from `labels` (by its index) where given."""
    docs = []
    for vi, v in enumerate(g["voices"]):
        notes = voice_notes(g, v)
        secs = [x for x in sections(g, notes) if keys is None or x["key"] in keys]
        if not secs:
            continue
        mode = v.get("mode", "riff")
        docs.append({
            "id": "%s__v%02d_%s" % (name, vi, v["inst"]),
            "track": name, "trackName": title, "bpm": g["bpm"], "form": g["form"],
            "voice": vi, "inst": v["inst"], "mode": mode, "octave": v.get("octave", 0), "gain": v.get("gain", 0.4),
            "label": (labels or {}).get(vi) or ("%s (%s)" % (v["inst"], mode) if mode != "riff" else v["inst"]),
            "sections": secs,
        })
    pads = g["pad"] if isinstance(g["pad"], list) else ([g["pad"]] if g["pad"] else [])
    for pi, pad in enumerate(pads):
        secs = [x for x in sections(g, pad_notes(g, pad)) if keys is None or x["key"] in keys]
        if not secs:
            continue
        docs.append({
            "id": "%s__p%02d_%s" % (name, pi, pad["inst"]),
            "track": name, "trackName": title, "bpm": g["bpm"], "form": g["form"],
            "voice": 100 + pi, "inst": pad["inst"], "mode": "pad", "octave": int(pad.get("octave", 0)), "gain": pad.get("gain", 0.2),
            "label": "%s (pad)" % pad["inst"],
            "sections": secs,
        })
    return docs


def sketch_hold_the_line_r22():
    """Hold The Line's round twenty-two, its seven (X) as the battle half plays it (Ryan, 7 November: "can I
    get this imported into the melody desk and have the melody desk support quarter tones?"): the riff on
    the low Omnific, its power chords on the upper with each note's fifth, the held line, the chime and the
    piano, the riff's high C a quarter-tone flat the first time through."""
    import hold_sketches as H
    call = H.copied(H.call_on(H.FORM_K, H.METER))
    H.round22()(call)
    g = {"bpm": call["bpm"], "form": call["form"].replace(" ", ""), "chords": call["chords"], "voices": call["voices"],
         "pad": call.get("pad"), "meter": call.get("meter")}
    labels = {}
    for vi, v in enumerate(g["voices"]):
        if "X" not in v.get("pat", {}):
            continue
        if v["inst"] == "real_bass":
            labels[vi] = "the riff's power chords, the upper Omnific" if (v.get("params") or {}).get("fifth") else "the riff, the low Omnific"
        elif v["inst"] == "guitar_real":
            labels[vi] = "the held line, the lead guitar"
        elif v["inst"] == "chime_metal":
            labels[vi] = "the chime"
        elif v["inst"] == "epiano":
            labels[vi] = "the piano on the long beat"
    docs = [d for d in export_call(g, "music_hold_the_line", "Hold The Line, round twenty-two", keys="X", labels=labels) if d["voice"] in labels]
    return "sketch_hold_the_line_r22", docs


SKETCHES = {"hold_the_line_r22": sketch_hold_the_line_r22}


def main(argv):
    """One JSON file per track (document `parts/<track>`), its parts inside, so the desk
    reads six documents and a session seeds them in one batch; or a sketch's (`--sketch <round>`)."""
    os.makedirs(OUT, exist_ok=True)
    if argv[:1] == ["--sketch"]:
        jobs = [SKETCHES[r]() for r in argv[1:]]
    else:
        jobs = [(name, export(name)) for name in (argv or [n for n in forge.SOUNDS if n.startswith("music_")])]
    for name, docs in jobs:
        body = {
            "track": docs[0]["track"] if docs else name, "trackName": docs[0]["trackName"] if docs else TITLES.get(name, name),
            "bpm": docs[0]["bpm"] if docs else None, "form": docs[0]["form"] if docs else "",
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
