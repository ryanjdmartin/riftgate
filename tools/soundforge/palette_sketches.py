"""The console from a palette of liked profiles (Ryan, 4 October: the rows he liked on the assembled
console were sound profiles he liked, not good matches for their events; the combined cut wrongly
kept them pinned to their old events). So the eight become a palette, each named for its character,
and every event is built by fit from two or three of them, nothing played alone:

  P5   the short bright glass bow: light, airy, rising           (was "die lifted")
  P13  the warning over the bowed plate: an announcement          (was "round opens, with the warning")
  P14  the long bow into the plate, taps, the glass answering     (was "end turn")
  P17  the soft glass bow: gentle, informational                  (was "a hold's readout")
  P21  the low plate bow with a tap landing: weight arriving      (was "menu opens")
  P26  two boops and the pulse: an affirmation                    (was "menu: select")
  P27  the stutter with the scrape: churn, a scramble             (was "refused")
  P28  F falling to E on dull boops: no                           (was "refused, the parked one")

Each profile takes a length and a gain so it can be a whole event or a layer in one.

    python3 tools/soundforge/palette_sketches.py          # into out/fx, after the others
"""
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as X  # noqa: E402
import console_sketches as C  # noqa: E402  (the beds and the sequences' event lists)
import fresh_sketches as R  # noqa: E402
import boop_sketches as B  # noqa: E402
import audition_sketches as A  # noqa: E402

SR = F.SR
n_of, mix, at = F.n_of, F.mix, F.at


def lay(*parts):
    """(seconds, sound) pairs into one buffer."""
    buf = np.zeros(1)
    for when, x in parts:
        buf = at(buf, x, when)
    return buf


# ---------------------------------------------------------------- the palette

def p5(scale=1.0, gain=1.0):
    d = 0.18 * scale
    return R.shell_bow("glass", 540.0, d, gain, 1600.0, 0.5, d + 0.08)


def p13(times=2, gain=1.0):
    return mix(R.shell_round() * 0.8 * gain, at(np.zeros(1), B.warning(B.B4, B.E4, 0.2, times, 0.9 * gain), 0.2))


def p14(gain=1.0):
    return R.shell_commit() * gain


def p17(scale=1.0, gain=0.7, f0=500.0):
    d = 0.25 * scale
    return R.shell_bow("glass", f0, d, gain, 1200.0, 0.6, d + 0.05)


def p21(scale=1.0, gain=1.0, f0=160.0):
    d = 0.45 * scale
    return mix(R.shell_bow("plate", f0, d, gain, 600.0, 0.5, d + 0.15),
               at(np.zeros(1), R.shell_tap("plate", f0, gain, 0.3), d * 0.88))


def p26(gain=1.0):
    return B.lock() * gain


def p27(rate=20.0, n=8, gain=1.0, f=240.0, scrape=0.8):
    return mix(R.cell("." * n, rate=rate, gain=0.9 * gain, f=f), R.shell_scrape(180.0 + (f - 240.0) * 0.3, scrape * gain))


def p28(gain=1.0):
    return B.refuse() * gain


def boop(f, dur=0.14, gain=0.6, **kw):
    return B.boop(f, dur, gain, attack=kw.pop("attack", 0.015), **kw)


# ---------------------------------------------------------------- the events, by fit

SET = [
    ("tap", lambda: mix(p5(0.55, 0.9), R.pip(R.DOT, 0.4)), -23.0, "ui_tap", "A tap",
     "P5 short, with a pip at its front: light, quick, a finger on glass"),
    ("press_heavy", lambda: p21(0.4, 1.0, 180.0), -20.0, "ui_tap", "A heavy press",
     "P21 short: the plate bowed briefly, the tap landing"),
    ("select", lambda: lay((0.0, p5(0.8)), (0.1, boop(B.E4, 0.12, 0.55))), -18.0, "ui_tap", "Select",
     "P5 with a soft boop on E landing in it: the brackets arriving"),
    ("dismiss", lambda: lay((0.0, p17(0.6, 0.8, 440.0)), (0.06, boop(B.B3, 0.12, 0.45, bright=1000.0))), -21.0, "ui_back", "Dismiss",
     "P17 short and lower, a dull low boop under: letting go"),
    ("die_lift", lambda: lay((0.0, p5(1.0)), (0.12, R.pip(R.DOT, 0.35))), -17.0, "die_pick", "Die lifted",
     "P5, a pip as the ghost takes: lifted off the panel"),
    ("die_drop_back", lambda: lay((0.0, p17(0.5, 0.8, 460.0)), (0.0, R.pip(R.DOT, 0.3, 260.0))), -21.0, "die_drop", "Die set back",
     "P17 short over a low pip: set down softly"),
    ("die_lock", lambda: lay((0.0, p5(0.6, 0.7)), (0.06, p26())), -16.0, "die_lock", "Die locked",
     "P26 over a short P5: the affirmation, lifted on glass"),
    ("die_spend", lambda: lay((0.0, p21(0.6, 1.0, 190.0)), (0.3, boop(B.E4, 0.2, 0.6, close=(2200.0, 800.0))), (0.0, R.cell("...", gap=0.05, gain=0.5))), -14.0, "die_drop", "Die spent on a foe",
     "P21 (weight arriving) with the three targeting pips under its front and a boop closing on E"),
    ("die_spend_self", lambda: lay((0.0, p21(0.6, 1.0, 190.0)), (0.32, p5(0.8, 0.7))), -14.0, "die_drop", "Die spent on a machine",
     "P21 then P5 rising off it: weight arriving, something going up on the machine"),
    ("reroll", lambda: lay((0.0, p27(14.0, 5, 0.8, 300.0, 0.5)), (0.36, boop(B.E4, 0.14, 0.6))), -16.0, "die_roll", "Reroll",
     "P27 lighter and slower as the churn of the flips, a boop landing as the dice settle"),
    ("round_open", lambda: lay((0.0, p13(2)), (0.2, A.pulse(69.0, 0.3, 0.7))), -12.0, None, "The round opens",
     "P13 with the weight under it: an announcement"),
    ("round_open_b", lambda: lay((0.0, p13(1)), (0.55, p26(0.8))), -12.0, None, "The round opens, variant",
     "P13 once, then P26: announced, then confirmed"),
    ("end_turn", lambda: lay((0.0, p14()), (1.45, p26(0.7))), -11.0, "resolve", "End turn",
     "P14 with P26 at its tail: the commitment, then the affirmation"),
    ("end_turn_b", lambda: lay((0.0, p21(0.7, 1.0, 150.0)), (0.35, p14(0.9))), -11.0, None, "End turn, variant",
     "P21 as a heavy lead-in, P14 swelling out of it"),
    ("route_set", lambda: lay((0.0, p5(0.7, 0.8)), (0.08, R.cell("..", gap=0.05, gain=0.5)), (0.2, boop(B.B4, 0.14, 0.55))), -16.0, "plot", "A route set",
     "P5 with two pips and a boop on B: a waypoint logged"),
    ("hold_readout", lambda: p17(1.0, 0.7), -19.0, None, "A hold's readout",
     "P17: the one profile that already fits its own event"),
    ("codex_open", lambda: lay((0.0, p21(0.5, 1.0, 180.0)), (0.22, p17(1.2, 0.6, 520.0))), -15.0, "codex_open", "Codex opens",
     "P21 short then P17: the panel's weight arriving, the glass coming up over it"),
    ("codex_close", lambda: lay((0.0, p17(0.6, 0.7, 460.0)), (0.08, R.shell_tap("plate", 180.0, 0.6, 0.12))), -18.0, "codex_close", "Codex closes",
     "P17 short with the plate's tap under it: put away"),
    ("menu_open", lambda: lay((0.0, p21(1.0)), (0.38, p17(0.8, 0.5, 480.0))), -14.0, "menu_open", "Menu opens",
     "P21 with P17 over its landing: everything stops"),
    ("menu_close", lambda: lay((0.0, p5(0.7, 0.8)), (0.1, R.shell_tap("plate", 170.0, 0.6, 0.12))), -17.0, "menu_open", "Menu closes",
     "P5 short, the plate's tap: back to it"),
    ("nav_forward", lambda: lay((0.0, p5(0.55, 0.8)), (0.06, boop(B.E4, 0.12, 0.6))), -18.0, "ui_tap", "Menu: forward",
     "P5 short, a boop on E"),
    ("nav_back", lambda: lay((0.0, p17(0.5, 0.7, 440.0)), (0.04, boop(B.B3, 0.12, 0.55, bright=1100.0))), -19.0, "ui_back", "Menu: back",
     "P17 short and low, a boop on B3"),
    ("nav_select", lambda: lay((0.0, p26()), (0.12, p5(0.5, 0.5))), -16.0, "ui_tap", "Menu: select",
     "P26 with a short P5 over its second boop"),
    ("refuse", lambda: lay((0.0, p28()), (0.0, R.shell_scrape(170.0, 0.5))), -15.0, "ui_back", "Refused",
     "P28 over a low scrape: no"),
    ("refuse_b", lambda: lay((0.0, p27(20.0, 8, 0.8, 220.0, 0.7)), (0.18, p28(0.7))), -15.0, None, "Refused, variant",
     "P27 low and heavy, P28 falling out of it: the churn refused"),
]
SET_BY = {name: (fn, db, beside, label, note) for name, fn, db, beside, label, note in SET}
NAMES = {"touch": "tap", "touch_heavy": "press_heavy", "round_acquire": "round_open", "resolve": "end_turn", "route_clear": "dismiss"}


def render_one(name):
    F.seed("pal_" + name)
    fn, db, beside, label, note = SET_BY[name]
    return R.level_for_phone(fn(), db), db, beside, label, note


def main(argv):
    os.makedirs(X.OUT, exist_ok=True)
    path = os.path.join(X.OUT, "manifest.json")
    manifest = {}
    if os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
    manifest["palette"] = []
    worst = -99.0
    for name, *_ in SET:
        x, db, beside, label, note = render_one(name)
        X.write("pal_" + name, X.tail(x, 0.35))
        pr = R.pierce(x)
        worst = max(worst, pr)
        manifest["palette"].append({"name": "pal_" + name, "beside": beside, "label": label, "note": note, "seconds": round(len(x) / SR, 2), "phone_db": db, "pierce_db": round(pr, 1)})
        print("  pal_%-16s %5.2f s  phone %6.1f  pierce %6.1f" % (name, len(x) / SR, db, pr))
    print("  worst pierce %.1f dB" % worst)
    for key_, base, events in (("con_turn", X.bed("music_hold_the_line", 8, 8, 104), C.TURN),
                               ("con_climax", X.bed("music_hold_the_line", C.climax_bar(), 8, 104), C.TURN),
                               ("con_map", X.bed("music_night_shift", 8, 6, 94), C.MAP)):
        F.seed("pal_seq_" + key_)
        buf = np.array(base) * 10.0 ** (C.BED_DB / 20.0)
        for when, con, now, db in events:
            if con is not None:
                x, _, _, _, _ = render_one(NAMES.get(con, con))
            elif now is not None:
                x = X.level(X.shipped(now), F.LEVELS[now])
            else:
                continue
            buf = at(buf, x * 10.0 ** (db / 20.0), when)
        name = "seq_%s_pal" % key_
        X.write(name, X.tail(buf, 0.5))
        manifest["palette"].append({"name": name, "seconds": round(len(buf) / SR, 2)})
        print("  %-20s %5.1f s" % (name, len(buf) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
