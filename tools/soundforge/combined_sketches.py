"""The console combined (Ryan, 4 October, on the assembled console: everything too monotone, which
is the pulses; combine more). What he liked was every sustained, textured thing (the glass bows,
the plate bowed with a tap landing in it, the commit, the warning over the plate) and every
layered thing (two boops and the pulse; the stutter with the scrape; the boop refuse). What he
did not like was the single dry gesture (a stopped tap) and the static-and-boop openers. The
meh was every pulse cell alone: monotone blips.

So the rule here: nothing plays alone. Every event is two or three materials. A bow (glass for
the light things, plate for the heavy) or a boop carries it; the pips are a rhythm layer under
the carrier, never the whole sound; the boop is the pitched punctuation, used where something is
said; the warning is the round; the weight sits under the big ones. The liked rows are kept as
they were (5, 13, 14, 17, 21, 26, 27, 28) and everything else is rebuilt as a combination.

The voice is set aside: Ryan decided against the babble (dumb and lazy, not as funny as he
thought) and against the formant voice's style, which cannot reach the Terran Adjutant's
register (smooth and human, soulless and slightly synthesised, a machine assistant with neither
monotone nor perfect human cadence). If a voice comes, it starts from a real speech
synthesiser and is processed down into the machine, not built up in the forge. Not necessary;
an experiment for later.

    python3 tools/soundforge/combined_sketches.py          # into out/fx, after the others
"""
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as X  # noqa: E402
import console_sketches as C  # noqa: E402  (the beds and the sequences' event lists)
import fresh_sketches as R  # noqa: E402  (pulse code and the shell)
import boop_sketches as B  # noqa: E402  (the boop, the warning, the hum)
import audition_sketches as A  # noqa: E402  (the weight's pulse)

SR = F.SR
n_of, t_of, mix, at = F.n_of, F.t_of, F.mix, F.at


def glass(dur=0.14, gain=1.0, colour=1500.0, swell=0.4, stop=None):
    return R.shell_bow("glass", 540.0, dur, gain, colour, swell, stop if stop else dur + 0.1)


def plate(dur=0.3, gain=1.0, colour=900.0, swell=0.35, stop=None, f0=200.0):
    return R.shell_bow("plate", f0, dur, gain, colour, swell, stop if stop else dur + 0.14)


def fade_glass(dur=0.2, gain=0.8):
    """A glass bow that starts full and dies: a thing let go."""
    n = n_of(dur)
    x = F.lp(F.hp(F.noise(n), 120.0), 1300.0) * F.env_pts(n, [(0.0, 0.9), (dur * 0.3, 0.6), (dur, 0.0)])
    return R.body(np.concatenate([x, np.zeros(n_of(0.3))]), "glass", 500.0, dur + 0.08) * gain


def boop(f, dur=0.16, gain=0.8, **kw):
    return B.boop(f, dur, gain, **kw)


# ---------------------------------------------------------------- the events, each two or three materials

def tap():
    return mix(glass(0.09, 0.8, 1400.0, 0.3), R.cell(".", gain=0.7))


def press_heavy():
    return mix(plate(0.16, 0.9, 800.0, 0.3), R.cell("-", gain=0.8))


def select():
    return at(glass(0.12, 0.8), boop(B.E4, 0.12, 0.6, attack=0.015), 0.05)


def dismiss():
    return mix(fade_glass(0.18, 0.8), at(np.zeros(1), boop(B.B3, 0.12, 0.5, attack=0.012, bright=1100.0), 0.04))


def die_lift():   # row 5, kept, with a pip as the ghost takes
    return at(R.shell_bow("glass", 540.0, 0.18, 1.0, 1600.0, 0.5, 0.26), R.pip(R.DOT, 0.5), 0.2)


def die_drop_back():   # the stopped tap replaced: the glass dying and a low dull boop
    return mix(fade_glass(0.16, 0.9), at(np.zeros(1), boop(B.B3, 0.14, 0.6, attack=0.012, bright=1000.0), 0.02))


def die_lock():   # row 26's figure (two boops and the pulse) over a short glass bow
    return mix(glass(0.14, 0.6, 1500.0, 0.3), at(np.zeros(1), B.lock(), 0.03))


def die_spend():   # the plate groaning under three targeting pips, a boop landing
    buf = plate(0.3, 1.0, 900.0, 0.3)
    buf = at(buf, R.cell("...", gap=0.05, gain=0.8), 0.04)
    buf = at(buf, boop(B.E4, 0.2, 0.7, attack=0.015, close=(2200.0, 800.0)), 0.3)
    return at(buf, A.pulse(92.0, 0.14, 0.7), 0.3)


def die_spend_self():
    buf = die_spend()
    return at(buf, boop(B.E5, 0.14, 0.45, attack=0.02, close=(2000.0, 800.0)), 0.52)


def reroll():   # the slow run over a scrape, a boop landing
    buf = mix(R.cell(".....", rate=14.0, gain=0.8), R.shell_scrape(230.0, 0.6))
    return at(buf, boop(B.E4, 0.16, 0.7, attack=0.015), 0.38)


def round_open():   # row 13, kept, with the weight under it
    buf = mix(R.shell_round() * 0.8, at(np.zeros(1), B.warning(B.B4, B.E4, 0.2, 2, 0.9), 0.2))
    return at(buf, A.pulse(69.0, 0.3, 0.8), 0.2)


def end_turn():   # row 14 with three boops stepping over the bow's climax and the weight
    buf = R.shell_commit()
    for k, f in enumerate((B.E4, B.G4, B.B4)):
        buf = at(buf, boop(f, 0.18 if k < 2 else 0.4, 0.7, attack=0.02, close=(2200.0, 900.0) if k == 2 else None), 0.72 + k * 0.17)
    return at(buf, A.pulse(55.0, 0.5, 0.9), 0.75)


def route_set():   # the pips over a glass bow, a boop landing on B
    buf = mix(glass(0.3, 0.6, 1300.0, 0.5), R.cell("..-", gap=0.06, gain=0.8))
    return at(buf, boop(B.B4, 0.16, 0.6, attack=0.015), 0.36)


def hold_readout():   # row 17, kept
    return R.shell_bow("glass", 500.0, 0.25, 0.7, 1200.0, 0.6, 0.3)


def codex_open():   # the plate bowed with a tap landing (row 21's language), a boop closing over it
    buf = mix(plate(0.35, 1.0, 800.0, 0.5, f0=190.0), at(np.zeros(1), R.shell_tap("plate", 190.0, 0.9, 0.3), 0.3))
    return at(buf, boop(B.E4, 0.26, 0.6, attack=0.03, close=(1800.0, 700.0)), 0.32)


def codex_close():
    return mix(fade_glass(0.2, 0.8), at(np.zeros(1), boop(B.B3, 0.16, 0.5, attack=0.015, bright=1100.0), 0.05))


def menu_open():   # row 21, kept, a soft boop on PAUSED
    buf = mix(R.shell_bow("plate", 160.0, 0.45, 1.0, 600.0, 0.5, 0.6), at(np.zeros(1), R.shell_tap("plate", 160.0, 1.0, 0.3), 0.4))
    return at(buf, boop(B.E4, 0.22, 0.45, attack=0.03, close=(1600.0, 700.0)), 0.42)


def menu_close():
    return mix(glass(0.12, 0.8, 1200.0, 0.3), at(np.zeros(1), boop(B.B3, 0.14, 0.5, attack=0.012, bright=1000.0), 0.03))


def nav_forward():
    return at(glass(0.1, 0.7, 1500.0, 0.3), boop(B.E4, 0.12, 0.7, attack=0.012), 0.03)


def nav_back():
    return mix(fade_glass(0.14, 0.7), at(np.zeros(1), boop(B.B3, 0.12, 0.6, attack=0.01, bright=1100.0), 0.02))


def nav_select():   # row 26, kept
    return B.lock()


def refuse():   # rows 27 and 28 together: the stutter with the scrape under it, and F falling to E over them
    return mix(R.cell("........", rate=20.0, gain=0.8, f=240.0), R.shell_scrape(180.0, 0.7), at(np.zeros(1), B.refuse() * 0.8, 0.02))


SET = [
    ("tap", tap, -23.0, "ui_tap", "A tap", "a short glass bow with a pip in it"),
    ("press_heavy", press_heavy, -20.0, "ui_tap", "A heavy press", "a short plate bow with a dash in it"),
    ("select", select, -18.0, "ui_tap", "Select", "the glass bowed, a soft boop on E landing in it"),
    ("dismiss", dismiss, -21.0, "ui_back", "Dismiss", "the glass dying away, a low dull boop under"),
    ("die_lift", die_lift, -17.0, "die_pick", "Die lifted", "kept (5): the glass bow, with a pip as the ghost takes"),
    ("die_drop_back", die_drop_back, -21.0, "die_drop", "Die set back", "the stopped tap replaced: the glass dying, a low dull boop"),
    ("die_lock", die_lock, -16.0, "die_lock", "Die locked", "two boops and the pulse (26) over a short glass bow"),
    ("die_spend", die_spend, -14.0, "die_drop", "Die spent on a foe", "the plate groaning under three targeting pips, a boop landing on E, the weight"),
    ("die_spend_self", die_spend_self, -14.0, "die_drop", "Die spent on a machine", "the same with a higher boop after"),
    ("reroll", reroll, -16.0, "die_roll", "Reroll", "the slow run over the scrape, a boop landing"),
    ("round_open", round_open, -12.0, None, "The round opens", "kept (13): the warning over the plate bowed, with the weight under it"),
    ("end_turn", end_turn, -11.0, "resolve", "End turn", "kept (14) with three boops stepping over the bow's climax, E, G, B, and the weight"),
    ("route_set", route_set, -16.0, "plot", "A route set", "the pips over a glass bow, a boop landing on B"),
    ("hold_readout", hold_readout, -19.0, None, "A hold's readout", "kept (17): the soft glass bow"),
    ("codex_open", codex_open, -15.0, "codex_open", "Codex opens", "the plate bowed with a tap landing in it (21's language), a boop closing over it"),
    ("codex_close", codex_close, -18.0, "codex_close", "Codex closes", "the glass dying, a low boop"),
    ("menu_open", menu_open, -14.0, "menu_open", "Menu opens", "kept (21), with a soft boop closing on PAUSED"),
    ("menu_close", menu_close, -17.0, "menu_open", "Menu closes", "a short glass bow, a dull boop"),
    ("nav_forward", nav_forward, -18.0, "ui_tap", "Menu: forward", "a short glass bow, a boop on E"),
    ("nav_back", nav_back, -19.0, "ui_back", "Menu: back", "the glass dying, a dull boop on B3"),
    ("nav_select", nav_select, -16.0, "ui_tap", "Menu: select", "kept (26): two boops and the pulse"),
    ("refuse", refuse, -15.0, "ui_back", "Refused", "27 and 28 together: the stutter with the scrape under it and F falling to E over them"),
]
SET_BY = {name: (fn, db, beside, label, note) for name, fn, db, beside, label, note in SET}
NAMES = {"touch": "tap", "touch_heavy": "press_heavy", "round_acquire": "round_open", "resolve": "end_turn", "route_clear": "dismiss"}


def render_one(name):
    F.seed("cmb_" + name)
    fn, db, beside, label, note = SET_BY[name]
    return R.level_for_phone(fn(), db), db, beside, label, note


def main(argv):
    os.makedirs(X.OUT, exist_ok=True)
    path = os.path.join(X.OUT, "manifest.json")
    manifest = {}
    if os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
    manifest["combined"] = []
    worst = -99.0
    for name, *_ in SET:
        x, db, beside, label, note = render_one(name)
        X.write("cmb_" + name, X.tail(x, 0.35))
        pr = R.pierce(x)
        worst = max(worst, pr)
        manifest["combined"].append({"name": "cmb_" + name, "beside": beside, "label": label, "note": note, "seconds": round(len(x) / SR, 2), "phone_db": db, "pierce_db": round(pr, 1)})
        print("  cmb_%-16s %5.2f s  phone %6.1f  pierce %6.1f" % (name, len(x) / SR, db, pr))
    print("  worst pierce %.1f dB" % worst)
    for key_, base, events in (("con_turn", X.bed("music_hold_the_line", 8, 8, 104), C.TURN),
                               ("con_climax", X.bed("music_hold_the_line", C.climax_bar(), 8, 104), C.TURN),
                               ("con_map", X.bed("music_night_shift", 8, 6, 94), C.MAP)):
        F.seed("cmb_seq_" + key_)
        buf = np.array(base) * 10.0 ** (C.BED_DB / 20.0)
        for when, con, now, db in events:
            if con is not None:
                x, _, _, _, _ = render_one(NAMES.get(con, con))
            elif now is not None:
                x = X.level(X.shipped(now), F.LEVELS[now])
            else:
                continue
            buf = at(buf, x * 10.0 ** (db / 20.0), when)
        name = "seq_%s_cmb" % key_
        X.write(name, X.tail(buf, 0.5))
        manifest["combined"].append({"name": name, "seconds": round(len(buf) / SR, 2)})
        print("  %-20s %5.1f s" % (name, len(buf) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
