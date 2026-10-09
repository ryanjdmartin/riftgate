"""The console assembled from Ryan's verdicts on the two fresh sets and the parked set (3 October,
by principle, not pitch). Pulse code for the hand and for targeting: a tap, a heavy press,
select, dismiss, the lock, a die spent (it sounds like targeting), the reroll (slower), a route
set, the codex. The shell for the body: a die lifted and set back, a hold's readout, the commit,
the pause menu. Both for refuse. The round opening mixed. From the parked set: the boop and the
warning, absolutely; the dismissal's low ping, for something; the three short boop figures as
menu navigation, forward, back, select; the codex and menu openers with their static; the boop
refuse; the voice at one word at most, and either lower fidelity or real words, since the
current level sits in the comical cute register.

Each event has one primary built to the verdict. Where he said mixed, both or also, a second
variant sits beside it. Three new rows for menu navigation, and the voice at two fidelities on
real words.

    python3 tools/soundforge/assembled_sketches.py          # into out/fx, after the others
"""
import json
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as X  # noqa: E402
import console_sketches as C  # noqa: E402  (the beds and the sequences' event lists)
import fresh_sketches as R  # noqa: E402  (pulse code and the shell)
import boop_sketches as B  # noqa: E402  (the boop, the warning, the static, the hum, the ping)
import audition_sketches as A  # noqa: E402  (the breaker, the pulse, the radio)
import speech  # noqa: E402

SR = F.SR
n_of, t_of, mix, at = F.n_of, F.t_of, F.mix, F.at


def lofi(x, band=(500.0, 2000.0), hold=9, grain=5.0, static=0.35):
    """The voice at lower fidelity: a narrower band, coarser samples, fewer bits, static under
    it for its whole length."""
    y = F.bp(x, band[0], band[1], order=4)
    y = F.sat(y / (np.max(np.abs(y)) + 1e-9) * 2.2, 3.0)
    y = np.repeat(y[::hold], hold)[:len(x)]
    steps = 2.0 ** grain
    y = np.round(y * steps) / steps
    n = len(y)
    s = F.bp(F.noise(n), 500.0, 1600.0, order=3) * static * F.env_pts(n, [(0.0, 0.0), (0.01, 1.0), (n / SR - 0.02, 1.0), (n / SR, 0.0)])
    return F.lp(y + s, 2200.0, order=3)


def words(line, voice="vega", fidelity="radio", gain=1.0):
    w = speech.say(line, voice)
    body = A.radio(w) if fidelity == "radio" else lofi(w)
    buf = at(A.sq(0.9), body, 0.03)
    return at(buf, A.sq(0.7, 0.022), 0.03 + len(w) / SR + 0.02) * gain


def round_open_mixed():
    """The shell's plate bowed under the pulse's three slow dashes."""
    return mix(R.shell_round() * 0.8, at(np.zeros(1), R.cell("- - -", gap=0.14), 0.15))


def round_open_warning():
    """The warning's two-tone, twice, over the shell's plate bowed."""
    return mix(R.shell_round() * 0.8, at(np.zeros(1), B.warning(B.B4, B.E4, 0.2, 2, 0.9), 0.2))


def refuse_both():
    return mix(R.cell("........", rate=20.0, gain=0.9, f=240.0), R.shell_scrape(180.0, 0.8))


def reroll_slow():
    return R.cell(".....", rate=14.0)


def reroll_mixed():
    return mix(R.cell(".....", rate=14.0), R.shell_scrape(230.0, 0.5))


def commit_with_word(fidelity="radio"):
    buf = R.shell_commit()
    return at(buf, words("weapons online", "vega", fidelity, 0.9), 1.5)


# name: (recipe, phone dB, shipped name, label, note)
SET = [
    ("tap", (lambda: R.cell(".")), -23.0, "ui_tap", "A tap", "pulse: a dot"),
    ("press_heavy", (lambda: R.cell("-")), -20.0, "ui_tap", "A heavy press", "pulse: a dash"),
    ("select", (lambda: R.cell("..")), -18.0, "ui_tap", "Select", "pulse: two dots"),
    ("dismiss", (lambda: R.cell(". ", gain=0.8)), -21.0, "ui_back", "Dismiss", "pulse: a soft dot"),
    ("die_lift", (lambda: R.shell_bow("glass", 540.0, 0.18, 1.0, 1600.0, 0.5, 0.26)), -17.0, "die_pick", "Die lifted", "shell: a short bow on the glass"),
    ("die_drop_back", (lambda: R.shell_tap("plate", 230.0, 0.8, 0.06)), -21.0, "die_drop", "Die set back", "shell: set down, stopped"),
    ("die_lock", (lambda: R.cell("-.")), -16.0, "die_lock", "Die locked", "pulse: dash dot"),
    ("die_spend", (lambda: R.cell("...", gap=0.05)), -14.0, "die_drop", "Die spent on a foe", "pulse: three even dots; targeting"),
    ("die_spend_self", (lambda: R.cell("..-", gap=0.05)), -14.0, "die_drop", "Die spent on a machine", "pulse: two dots and a dash"),
    ("reroll", reroll_slow, -16.0, "die_roll", "Reroll", "pulse: the run at half the speed, fourteen a second"),
    ("reroll_b", reroll_mixed, -16.0, None, "Reroll, mixed", "the slower run with the shell's scrape under it"),
    ("round_open", round_open_mixed, -12.0, None, "The round opens", "mixed: the shell's plate bowed under the pulse's three slow dashes"),
    ("round_open_b", round_open_warning, -12.0, None, "The round opens, with the warning", "the warning's two-tone twice over the plate bowed; the boop's first job"),
    ("end_turn", R.shell_commit, -11.0, "resolve", "End turn", "shell: the long bow swelling into the plate, two taps landing in it, the glass answering"),
    ("end_turn_word", (lambda: commit_with_word("radio")), -11.0, None, "End turn, with a word", "the same with \"weapons online\" on the radio after it"),
    ("route_set", (lambda: R.cell("..-", gap=0.06)), -16.0, "plot", "A route set", "pulse: two dots and a dash"),
    ("hold_readout", (lambda: R.shell_bow("glass", 500.0, 0.25, 0.7, 1200.0, 0.6, 0.3)), -19.0, None, "A hold's readout", "shell: a soft bow on the glass"),
    ("codex_open", (lambda: R.cell("-..", gap=0.06)), -15.0, "codex_open", "Codex opens", "pulse: dash dot dot"),
    ("codex_open_b", (lambda: at(at(A.breaker(1.0, 0.55), B.static(0.4, 0.3, 30.0), 0.02), B.acquire(B.E4, 0.3, 0.9), 0.1)), -15.0, None, "Codex opens, the parked one", "the parked set's: the key, a static bed, a boop coming up out of it"),
    ("codex_close", (lambda: R.cell("..-", gap=0.06, gain=0.8)), -18.0, "codex_close", "Codex closes", "pulse: dot dot dash"),
    ("menu_open", (lambda: mix(R.shell_bow("plate", 160.0, 0.45, 1.0, 600.0, 0.5, 0.6), at(np.zeros(1), R.shell_tap("plate", 160.0, 1.0, 0.3), 0.4))), -14.0, "menu_open", "Menu opens", "shell: a low bow and a tap landing in it"),
    ("menu_open_b", (lambda: at(at(A.breaker(1.6, 0.9), B.hum(0.6, 0.5, 0.2), 0.0), B.boop(B.E4, 0.3, 0.8, attack=0.03, close=(1800.0, 700.0)), 0.15)), -14.0, None, "Menu opens, the parked one", "the breaker thrown, the hum for a moment, a boop closing"),
    ("menu_close", (lambda: R.shell_tap("plate", 160.0, 0.9, 0.12)), -17.0, "menu_open", "Menu closes", "shell: a tap on the plate"),
    ("nav_forward", (lambda: at(A.breaker(0.9, 0.55), B.boop(B.E4, 0.12, 0.8, attack=0.012), 0.02)), -18.0, "ui_tap", "Menu: forward", "the parked set's figure you read as forward: the key and a short boop"),
    ("nav_back", (lambda: B.boop(B.B3, 0.12, 0.8, attack=0.01, bright=1100.0)), -19.0, "ui_back", "Menu: back", "a dull low boop"),
    ("nav_select", B.lock, -16.0, "ui_tap", "Menu: select", "two boops and the pulse"),
    ("refuse", refuse_both, -15.0, "ui_back", "Refused", "both: the pulse's stutter with the shell's scrape under it"),
    ("refuse_b", B.refuse, -15.0, None, "Refused, the parked one", "F falling to E on dull boops, a dropout"),
    ("word_radio", (lambda: words("target locked", "vega", "radio")), -14.0, None, "The voice: real words, the radio", "\"target locked\" in the male register through the hard radio, as the parked set had it"),
    ("word_lofi", (lambda: words("target locked", "vega", "lofi")), -14.0, None, "The voice: real words, lower fidelity", "the same through a narrower band, coarser samples, fewer bits, static under it the whole way"),
    ("word_lofi_2", (lambda: words("weapons online", "vega", "lofi")), -14.0, None, "The voice: lower fidelity, \"weapons online\"", ""),
    ("babble_lofi", (lambda: at(at(A.sq(0.8), lofi(B.babble(1, "vega", 1.0, "lofi")), 0.03), A.sq(0.6, 0.022), 0.9)), -14.0, None, "The voice: a word that is not a word, lower fidelity", "the parked babble at the lower fidelity, for the comparison"),
]
SET_BY = {name: (fn, db, beside, label, note) for name, fn, db, beside, label, note in SET}
NAMES = {"touch": "tap", "touch_heavy": "press_heavy", "round_acquire": "round_open", "resolve": "end_turn", "route_clear": "dismiss"}


def render_one(name):
    F.seed("asm_" + name)
    fn, db, beside, label, note = SET_BY[name]
    return R.level_for_phone(fn(), db), db, beside, label, note


def main(argv):
    os.makedirs(X.OUT, exist_ok=True)
    path = os.path.join(X.OUT, "manifest.json")
    manifest = {}
    if os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
    manifest["assembled"] = []
    worst = -99.0
    for name, *_ in SET:
        x, db, beside, label, note = render_one(name)
        X.write("asm_" + name, X.tail(x, 0.35))
        pr = R.pierce(x)
        worst = max(worst, pr)
        manifest["assembled"].append({"name": "asm_" + name, "beside": beside, "label": label, "note": note, "seconds": round(len(x) / SR, 2), "phone_db": db, "pierce_db": round(pr, 1)})
        print("  asm_%-16s %5.2f s  phone %6.1f  pierce %6.1f" % (name, len(x) / SR, db, pr))
    print("  worst pierce %.1f dB" % worst)
    for key_, base, events in (("con_turn", X.bed("music_hold_the_line", 8, 8, 104), C.TURN),
                               ("con_climax", X.bed("music_hold_the_line", C.climax_bar(), 8, 104), C.TURN),
                               ("con_map", X.bed("music_night_shift", 8, 6, 94), C.MAP)):
        F.seed("asm_seq_" + key_)
        buf = np.array(base) * 10.0 ** (C.BED_DB / 20.0)
        for when, con, now, db in events:
            if con is not None:
                x, _, _, _, _ = render_one(NAMES.get(con, con))
            elif now is not None:
                x = X.level(X.shipped(now), F.LEVELS[now])
            else:
                continue
            buf = at(buf, x * 10.0 ** (db / 20.0), when)
        name = "seq_%s_asm" % key_
        X.write(name, X.tail(buf, 0.5))
        manifest["assembled"].append({"name": name, "seconds": round(len(buf) / SR, 2)})
        print("  %-20s %5.1f s" % (name, len(buf) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
