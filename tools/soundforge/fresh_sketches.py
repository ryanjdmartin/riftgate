"""Two fresh console sets (Ryan, 3 October: start fresh; the patterns he liked from the audition
come back later, not now). Neither borrows a grammar, a timbre or a pitch frame from any cut
so far, and they differ from each other in principle:

  PULSE CODE   rhythm first. One voice only, a dry low pip (a damped body around 300 Hz with
               a soft front, no tone to speak of), at two lengths, a dot and a dash. Every
               event is a short cell, Morse-like but no letters: a press is a dot, a lock a
               dash and a dot, a spend three even dots, a reroll a run, the round opening
               three slow dashes, the commit a long cell. Identity lives in timing. Military
               (the telegraph), utilitarian (one sound), never piercing, never melodic.

  MODAL SHELL  body first. The console is a resonant body, an armour plate and a glass panel
               with inharmonic modes, struck softly or bowed with noise so the body groans
               rather than rings, every mode damped by hand so nothing is a bell. No
               oscillator plays a note anywhere; what is heard is a shell answering to a
               touch. Each event is a different way of exciting the body: a tap, a double
               tap, a short bow, a long bow swelling, a scrape for no.

Both are measured for piercing (the 2 to 8 kHz band against the body, held ten decibels under)
and levelled by what the phone model plays of them.

    python3 tools/soundforge/fresh_sketches.py          # into out/fx, after fx_sketches.py
"""
import json
import math
import os
import sys

import numpy as np
from scipy.signal import lfilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as X  # noqa: E402
import console_sketches as C  # noqa: E402  (the beds and the sequences' event lists only)
from phone_sketches import phone_model  # noqa: E402

SR = F.SR
n_of, t_of, mix, at = F.n_of, F.t_of, F.mix, F.at


def env(n, pts):
    return F.env_pts(n, pts)


# ================================================================ pulse code

DOT, DASH, GAP = 0.045, 0.16, 0.07


def pip(dur=DOT, gain=1.0, f=300.0):
    """The one voice: a damped body, a sine with its second harmonic and a touch of the
    third, a three-millisecond front, held for `dur` and stopped. Dry."""
    n = n_of(dur + 0.03)
    t = t_of(n)
    x = np.sin(2.0 * math.pi * f * t) + 0.45 * np.sin(2.0 * math.pi * f * 2.0 * t) + 0.15 * np.sin(2.0 * math.pi * f * 3.0 * t)
    e = env(n, [(0.0, 0.0), (0.003, 1.0), (dur, 0.85), (dur + 0.03, 0.0)])
    front = F.lp(F.noise(n), 1800.0) * F.env_ad(n, 0.0005, 0.003) * 0.25
    return F.lp(F.sat((x * e + front), 1.6), 2400.0) * gain


def cell(code, gap=GAP, rate=None, gain=1.0, f=300.0):
    """A cell: '.' a dot, '-' a dash, ' ' a pause of one gap. `rate` overrides the spacing
    (dots per second) for runs."""
    buf = np.zeros(1)
    t = 0.0
    for ch in code:
        if ch == " ":
            t += gap
            continue
        d = DOT if ch == "." else DASH
        buf = at(buf, pip(d, gain, f), t)
        t += (1.0 / rate) if rate else (d + gap)
    return buf


PULSE = {
    "press": ((lambda: cell(".")), -23.0, "ui_tap", "a dot"),
    "press_heavy": ((lambda: cell("-")), -20.0, "ui_tap", "a dash"),
    "select": ((lambda: cell("..")), -18.0, "ui_tap", "two dots"),
    "dismiss": ((lambda: cell(". ", gain=0.8)), -21.0, "ui_back", "one dot, softer"),
    "die_lift": ((lambda: cell(".-")), -17.0, "die_pick", "dot dash"),
    "die_drop_back": ((lambda: cell("-", gain=0.7)), -21.0, "die_drop", "a dash, soft"),
    "die_lock": ((lambda: cell("-.")), -16.0, "die_lock", "dash dot"),
    "die_spend": ((lambda: cell("...", gap=0.05)), -14.0, "die_drop", "three even dots"),
    "die_spend_self": ((lambda: cell("..-", gap=0.05)), -14.0, "die_drop", "two dots and a dash"),
    "reroll": ((lambda: cell(".......", rate=28.0)), -16.0, "die_roll", "a run at the flip rate, then nothing"),
    "round_open": ((lambda: cell("- - -", gap=0.14)), -12.0, None, "three slow dashes: the round"),
    "end_turn": ((lambda: at(cell("-.--", gap=0.06), pip(0.42, 1.0), 0.75)), -11.0, "resolve", "a long cell and a held pip: the commit"),
    "resolve": ((lambda: at(cell("-.--", gap=0.06), pip(0.42, 1.0), 0.75)), -11.0, "resolve", "the same"),
    "route_set": ((lambda: cell("..-", gap=0.06)), -16.0, "plot", "two dots and a dash"),
    "route_clear": ((lambda: cell("-", gain=0.7)), -20.0, "ui_back", ""),
    "hold_readout": ((lambda: cell(".", gain=0.7)), -19.0, None, "a dot, soft"),
    "codex_open": ((lambda: cell("-..", gap=0.06)), -15.0, "codex_open", "dash dot dot"),
    "codex_close": ((lambda: cell("..-", gap=0.06, gain=0.8)), -18.0, "codex_close", "dot dot dash"),
    "menu_open": ((lambda: cell("--", gap=0.09)), -14.0, "menu_open", "two dashes"),
    "menu_close": ((lambda: cell("-", gain=0.8)), -17.0, "menu_open", ""),
    "refuse": ((lambda: cell("........", rate=20.0, gain=0.9, f=240.0)), -15.0, "ui_back", "a stutter at twenty a second, lower: a buzz, not a note"),
}


# ================================================================ modal shell

def modes(x, freqs, decays, amps):
    """A bank of two-pole resonators, one per mode, driven by the excitation `x`."""
    out = np.zeros(len(x))
    for f, d, a in zip(freqs, decays, amps):
        r = math.exp(-1.0 / (d * SR))
        th = 2.0 * math.pi * f / SR
        b = [a * (1.0 - r)]
        aa = [1.0, -2.0 * r * math.cos(th), r * r]
        out += lfilter(b, aa, x)
    return out


PLATE = ([1.0, 1.47, 2.09, 2.56, 3.12, 3.71, 4.4], [0.42, 0.33, 0.26, 0.2, 0.15, 0.11, 0.08], [1.0, 0.7, 0.55, 0.4, 0.3, 0.2, 0.14])   # an armour plate, f0 given per sound
GLASS = ([1.0, 2.32, 3.9, 5.1, 6.4], [0.22, 0.16, 0.11, 0.08, 0.06], [1.0, 0.5, 0.35, 0.2, 0.12])                                     # a glass panel


def body(x, kind="plate", f0=210.0, stop=None):
    """The shell answering: `x` excites the plate or the glass with its modes scaled from
    `f0`; `stop` is seconds after which the body is damped by hand (a hand on the plate)."""
    fr, de, am = PLATE if kind == "plate" else GLASS
    y = modes(x, [f0 * k for k in fr], de, am)
    if stop is not None:
        n = len(y)
        s = n_of(stop)
        if s < n:
            y[s:] *= np.exp(-np.arange(n - s) / n_of(0.03))
    return y


def tap(gain=1.0, soft=0.004):
    """A soft tap: a short low-passed burst."""
    n = n_of(0.02)
    return F.lp(F.noise(n), 1200.0) * F.env_ad(n, 0.0005, soft) * gain


def bow(dur, gain=1.0, colour=900.0, swell=0.4):
    """A bow: filtered noise with a slow front, held, pressing the body into a groan."""
    n = n_of(dur)
    x = F.lp(F.hp(F.noise(n), 120.0), colour)
    return x * env(n, [(0.0, 0.0), (dur * swell, 1.0), (dur * 0.85, 0.9), (dur, 0.0)]) * gain


def scrape(dur=0.25, gain=1.0):
    """A scrape: grainy noise with a rough gate, a protest."""
    n = n_of(dur)
    g = (np.sin(2.0 * math.pi * 23.0 * t_of(n)) > 0.2).astype(float)
    g = np.convolve(g, np.ones(n_of(0.003)) / n_of(0.003), mode="same")   # soft edges: a hard gate clicked on the speaker (Ryan, 5 October)
    x = F.bp(F.noise(n), 300.0, 2400.0) * g
    return x * env(n, [(0.0, 0.0), (0.01, 1.0), (dur * 0.8, 0.8), (dur, 0.0)]) * gain


def shell_tap(kind="plate", f0=210.0, gain=1.0, stop=0.12):
    x = np.concatenate([tap(1.0), np.zeros(n_of(0.5))])
    return body(x, kind, f0, stop) * gain


def shell_double(kind="plate", f0=210.0, gain=1.0, gap=0.09, stop=0.14):
    x = np.zeros(n_of(gap + 0.5))
    x = at(x, tap(1.0), 0.0)
    x = at(x, tap(0.85), gap)
    return body(x, kind, f0, gap + stop) * gain


def shell_bow(kind="plate", f0=200.0, dur=0.35, gain=1.0, colour=900.0, swell=0.4, stop=None):
    x = np.concatenate([bow(dur, 1.0, colour, swell), np.zeros(n_of(0.4))])
    return body(x, kind, f0, stop) * gain


def shell_scrape(f0=190.0, gain=1.0):
    x = np.concatenate([scrape(0.22, 1.0), np.zeros(n_of(0.3))])
    return body(x, "plate", f0, 0.26) * gain


def shell_commit():
    """The long bow swelling into the plate, two taps landing in it, the glass answering, the
    hand stopping it."""
    n = n_of(1.3)
    x = np.zeros(n + n_of(0.5))
    x = at(x, bow(0.9, 1.0, 700.0, 0.6), 0.0)
    x = at(x, tap(1.2), 0.75)
    x = at(x, tap(1.0), 0.92)
    plate = body(x, "plate", 170.0, 1.25)
    g = np.zeros(len(x))
    g = at(g, tap(0.8), 0.92)
    glass = body(g, "glass", 520.0, 1.2)
    return mix(plate, glass * 0.5)


def shell_round():
    """The round opening: the glass bowed briefly, then the plate bowed under it, longer."""
    g = np.concatenate([bow(0.3, 1.0, 1400.0, 0.3), np.zeros(n_of(0.6))])
    glass = body(g, "glass", 560.0, 0.5)
    p = np.zeros(n_of(1.4))
    p = at(p, bow(0.7, 1.0, 650.0, 0.5), 0.2)
    plate = body(p, "plate", 180.0, 1.1)
    return mix(glass * 0.6, plate)


SHELL = {
    "press": ((lambda: shell_tap("plate", 210.0, 1.0, 0.1)), -23.0, "ui_tap", "a soft tap on the plate, stopped"),
    "press_heavy": ((lambda: shell_tap("plate", 170.0, 1.0, 0.2)), -20.0, "ui_tap", "a harder tap, lower, left a moment"),
    "select": ((lambda: shell_tap("glass", 560.0, 1.0, 0.16)), -18.0, "ui_tap", "a tap on the glass"),
    "dismiss": ((lambda: shell_tap("glass", 480.0, 0.8, 0.08)), -21.0, "ui_back", "the glass, stopped at once"),
    "die_lift": ((lambda: shell_bow("glass", 540.0, 0.18, 1.0, 1600.0, 0.5, 0.26)), -17.0, "die_pick", "a short bow on the glass: lifted"),
    "die_drop_back": ((lambda: shell_tap("plate", 230.0, 0.8, 0.06)), -21.0, "die_drop", "set down, stopped"),
    "die_lock": ((lambda: shell_double("plate", 220.0, 1.0, 0.08, 0.16)), -16.0, "die_lock", "a double tap on the plate"),
    "die_spend": ((lambda: shell_bow("plate", 200.0, 0.3, 1.0, 900.0, 0.3, 0.42)), -14.0, "die_drop", "a bow pressed into the plate, a groan, stopped"),
    "die_spend_self": ((lambda: mix(shell_bow("plate", 200.0, 0.3, 1.0, 900.0, 0.3, 0.42), at(np.zeros(1), shell_tap("glass", 600.0, 0.5, 0.2), 0.3))), -14.0, "die_drop", "the same with the glass touched after"),
    "reroll": ((lambda: shell_scrape(230.0, 0.9)), -16.0, "die_roll", "a short scrape across the plate: the flips"),
    "round_open": (shell_round, -12.0, None, "the glass bowed, then the plate bowed under it, longer"),
    "end_turn": (shell_commit, -11.0, "resolve", "the long bow swelling into the plate, two taps landing in it, the glass answering, the hand stopping it"),
    "resolve": (shell_commit, -11.0, "resolve", "the same"),
    "route_set": ((lambda: shell_double("glass", 520.0, 1.0, 0.11, 0.2)), -16.0, "plot", "a double tap on the glass"),
    "route_clear": ((lambda: shell_tap("glass", 440.0, 0.7, 0.06)), -20.0, "ui_back", ""),
    "hold_readout": ((lambda: shell_bow("glass", 500.0, 0.25, 0.7, 1200.0, 0.6, 0.3)), -19.0, None, "a soft bow on the glass"),
    "codex_open": ((lambda: shell_bow("plate", 190.0, 0.4, 1.0, 800.0, 0.5, 0.55)), -15.0, "codex_open", "a bow on the plate, longer"),
    "codex_close": ((lambda: shell_tap("plate", 190.0, 0.8, 0.1)), -18.0, "codex_close", ""),
    "menu_open": ((lambda: mix(shell_bow("plate", 160.0, 0.45, 1.0, 600.0, 0.5, 0.6), at(np.zeros(1), shell_tap("plate", 160.0, 1.0, 0.3), 0.4))), -14.0, "menu_open", "a low bow and a tap landing in it"),
    "menu_close": ((lambda: shell_tap("plate", 160.0, 0.9, 0.12)), -17.0, "menu_open", ""),
    "refuse": ((lambda: shell_scrape(180.0, 1.0)), -15.0, "ui_back", "a scrape, lower and rougher: no"),
}


# ================================================================ render

def pierce(x):
    def band_db(lo, hi):
        y = F.bp(x, lo, hi)
        return 20.0 * math.log10(math.sqrt(float(np.mean(y ** 2))) + 1e-9)
    return band_db(2000.0, 8000.0) - band_db(300.0, 2000.0)


def level_for_phone(x, db):
    return x * 10.0 ** ((db - F.loudness(phone_model(x))) / 20.0)


def render_one(table, prefix, name):
    F.seed(prefix + name)
    fn, db, beside, note = table[name]
    return level_for_phone(fn(), db), db, beside, note


SETS = {"pulse_": PULSE, "shell_": SHELL}
NAMES = {"touch": "press", "touch_heavy": "press_heavy", "round_acquire": "round_open"}


def main(argv):
    os.makedirs(X.OUT, exist_ok=True)
    path = os.path.join(X.OUT, "manifest.json")
    manifest = {}
    if os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
    manifest["fresh"] = []
    for prefix, table in SETS.items():
        worst = -99.0
        print(prefix)
        for name in table:
            x, db, beside, note = render_one(table, prefix, name)
            X.write(prefix + name, X.tail(x, 0.35))
            pr = pierce(x)
            worst = max(worst, pr)
            manifest["fresh"].append({"name": prefix + name, "beside": beside, "seconds": round(len(x) / SR, 2), "phone_db": db, "pierce_db": round(pr, 1), "note": note})
            print("  %s%-16s %5.2f s  phone %6.1f  pierce %6.1f" % (prefix, name, len(x) / SR, db, pr))
        print("  worst pierce %.1f dB" % worst)
        for key_, base, events in (("con_turn", X.bed("music_hold_the_line", 8, 8, 104), C.TURN),
                                   ("con_climax", X.bed("music_hold_the_line", C.climax_bar(), 8, 104), C.TURN),
                                   ("con_map", X.bed("music_night_shift", 8, 6, 94), C.MAP)):
            F.seed(prefix + "seq_" + key_)
            buf = np.array(base) * 10.0 ** (C.BED_DB / 20.0)
            for when, con, now, db in events:
                if con is not None:
                    x, _, _, _ = render_one(table, prefix, NAMES.get(con, con))
                elif now is not None:
                    x = X.level(X.shipped(now), F.LEVELS[now])
                else:
                    continue
                buf = at(buf, x * 10.0 ** (db / 20.0), when)
            name = "seq_%s_%s" % (key_, prefix.rstrip("_"))
            X.write(name, X.tail(buf, 0.5))
            manifest["fresh"].append({"name": name, "seconds": round(len(buf) / SR, 2)})
            print("  %-22s %5.1f s" % (name, len(buf) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
