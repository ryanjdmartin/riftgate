"""The console from a palette of liked profiles (Ryan, 4 October: the rows he liked on the assembled
console were sound profiles he liked, not good matches for their events; the combined cut wrongly
kept them pinned to their old events). The eight are a palette, each named for its character, and
every event is built by fit from them:

  P5   the short bright glass bow: light, airy, rising           (was "die lifted")
  P13  the warning over the bowed plate: an announcement          (was "round opens, with the warning")
  P14  the long bow into the plate, taps, the glass answering     (was "end turn")
  P17  the soft glass bow: gentle, informational                  (was "a hold's readout")
  P21  the low plate bow with a tap landing: weight arriving      (was "menu opens")
  P26  two boops and the pulse: an affirmation                    (was "menu: select")
  P27  the stutter with the scrape: churn, a scramble             (was "refused")
  P28  F falling to E on dull boops: no                           (was "refused, the parked one")

The second cut (Ryan, 5 October, on the first; each note a rule):

  - Not everything needs a pip and a glass. The die is a virtual object, so die interactions are
    the glass register alone; where the die meets the UI (lock, unlock, spend) both registers
    play. A die spent is only the confirm part of the action and must not be too much: a hum
    while the die hovers over a valid target, eager to drop, carries the rest. The hover is a
    hook the game does not have (a drag has lift, move and drop, no over-target state).
  - The reroll was too long; it is a dice interaction, so glass.
  - The round opening needs no alarm: P13 once was better than twice, and less alarm-like still.
  - End turn: P14 or P21, not both. The "chunk" (a tap landing in the plate) was never hated,
    only too prevalent as a core sound; it earns its place where control is handed over, so the
    end of the turn keeps it and nothing else does.
  - The codex boots and shuts down: a climbing boop figure to open, a descending one to close.
  - A hold's readout is acknowledged by a ping, as a console would.
  - The pause menu is fine. Menu forward, back and confirm are the same sounds as select,
    dismiss and confirm, so they are easier to track.
  - The refuse variant (P27 with P28 falling out of it) wanted blending and shortening.

The third cut (Ryan, 6 October, on the second): no boops on a die spent; the hover more of a
hum, subtler, with a buzz in it; the lock and unlock closer to the shipped clicks (the relays),
subtler; the reroll's flips too subtle; the round opening ends after its two-note; the end of the
turn is P21 drawn out ("it sounds like Protoss and I'm here for it"); a route set's pitches must
not read as a cancel; the ping too subtle; the codex faster and quieter or it will annoy; the menu
opening is P21 with a boop-boop over it, the closing adds one lower boop; refuse's dropout and
scrape had hard edges that clicked on the speaker, fixed at their source.

The fourth cut (Ryan, 6 October, on the third): the hover closer, pitched down, quieter, easing
in rather than starting loud; a die spent on a machine the same sound as on a foe; the reroll's
flips slower, longer if need be; select, a route set, the codex and the menu opening pitched up;
wherever a boop rides on a glass bow (select, dismiss, confirm, the round opening, a route set,
the menu opening) the boop starts at the start rather than the glass growing into it; the round
opening and the end of the turn too loud; the glass under confirm longer; the ping good in
direction but too hard, more of a shoo than a boo; the menu opens on the heavy press (P21 short)
with the boops over it, and its old P21 moves under the menu closing.

The fifth cut (Ryan, 6 October, on the fourth): a general press, selecting a menu item and
"select" are one act, so they are one sound, and the map (a tile, a pack, a machine tapped) is
where something is acquired, so it gets its own scan-and-acquire; confirm quieter; the hover
down and quieter again; the lock's clicks digital, not analog; the reroll down and a little
shorter; the round opening's glass sooner and its boops quicker, the whole shorter; the end of
the turn slower and quieter; a route set less busy (the rising pair stays, the pips go); the
shoo softer, a common interaction; the codex with glass under it and its boops quieter, also
common; the menu opening's under-glass longer and its boops longer and down a fourth so it is
not the forward's pitch; the menu closing's boop audible from the start.

The sixth cut (Ryan, 6 October, on the fifth): the map's acquire softer, down, shorter, a minor
signal that something was boxed; the map, confirm and the round opening all shared the E-B pitches
and all read as confirmation, and a route set had the same spread on other pitches, so each gets
its own figure (the map one soft boop on G, confirm its E-B, the round opening one long B closing,
a route set two quick ticks on A); the lock's click cracked the speaker (a four-millisecond
transient); the round opening a touch slower; the end of the turn swelling nearer its start with
a longer tail, quieter; the shoo softer with a longer tail; the menu opening's boops shorter; the
menu closing's plate swelling at the start and tailing off.

    python3 tools/soundforge/palette_sketches.py          # into out/fx, after the others
"""
import json
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as X  # noqa: E402
import console_sketches as C  # noqa: E402  (the beds and the map's event list)
import fresh_sketches as R  # noqa: E402
import boop_sketches as B  # noqa: E402
import audition_sketches as A  # noqa: E402

SR = F.SR
n_of, t_of, mix, at = F.n_of, F.t_of, F.mix, F.at
PREFIX = "pal6_"   # the fifth cut's files; the earlier cuts' files are cleared from the server as each is superseded


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


def glass_let_go(dur=0.16, gain=0.8, f0=500.0):
    """The glass bowed and letting go: full at the start and dying, nothing landing."""
    n = n_of(dur)
    x = F.lp(F.hp(F.noise(n), 120.0), 1300.0) * F.env_pts(n, [(0.0, 0.9), (dur * 0.3, 0.6), (dur, 0.0)])
    return R.body(np.concatenate([x, np.zeros(n_of(0.3))]), "glass", f0, dur + 0.08) * gain


# ---------------------------------------------------------------- the shared gestures
# select, dismiss and confirm are one set: the map's selection and the menus use the same three.

def select():
    """A press, a menu item, a selection in a panel: one act, one sound. The boop first, on E5,
    the glass under it from the same instant; quiet, since it is the commonest sound."""
    return lay((0.0, boop(B.E5, 0.12, 0.5)), (0.0, p5(0.8)))


def map_select():
    """The map is where something is acquired: a tile, a pack, a machine. A scan, the glass
    bowed with its colour rising over a fifth of a second (the filter moves, no pitch does),
    then the lock, two quick boops E5 B5."""
    dur = 0.12
    n = n_of(dur)
    x = F.lp_var(F.hp(F.noise(n), 150.0), np.geomspace(400.0, 2200.0, n)) * F.env_pts(n, [(0.0, 0.0), (0.03, 1.0), (dur - 0.02, 0.9), (dur, 0.0)])
    scan = R.body(np.concatenate([x * 0.5, np.zeros(n_of(0.3))]), "glass", 460.0, 0.2)
    return lay((0.0, scan), (0.1, boop(B.G4, 0.09, 0.4)))


def dismiss():
    return lay((0.0, boop(B.B3, 0.12, 0.45, bright=1000.0)), (0.0, p17(0.6, 0.8, 440.0)))


def confirm():
    """P26 from the first instant with a longer P5 under it: the affirmation on glass."""
    return lay((0.0, p26()), (0.0, p5(1.2, 0.7)))


# ---------------------------------------------------------------- the die: the glass register

def die_hover(dur=1.2):
    """The die over a valid target: a hum. The glass bowed softly and held, a slow shallow pulse
    on it, and a faint electrical buzz under it (a low pulse wave on E3 through a low-pass).
    Glass register, subtle: in the game this would loop while the ghost sits over a target."""
    n = n_of(dur)
    t = t_of(n)
    env = F.env_pts(n, [(0.0, 0.0), (min(0.45, dur * 0.45), 1.0), (dur - 0.15, 1.0), (dur, 0.0)])   # eases in
    x = F.lp(F.hp(F.noise(n), 120.0), 700.0)
    eager = 1.0 - 0.14 * 0.5 * (1.0 + np.sin(2.0 * math.pi * 2.2 * t))
    glass = R.body(np.concatenate([x * env * eager * 0.4, np.zeros(n_of(0.25))]), "glass", 320.0, None)
    f = B.hz(0, 0)   # E2
    buzz = np.sign(np.sin(2.0 * math.pi * f * t) + 0.3) * 0.5 + 0.5 * np.sin(2.0 * math.pi * f * 2.0 * t)
    buzz = F.lp(buzz, 700.0) * env * (1.0 - 0.12 * 0.5 * (1.0 + np.sin(2.0 * math.pi * 7.0 * t))) * 0.35
    return mix(glass, buzz)


def die_spend():
    """Only the confirm part of the action, once the hover has carried the rest: the glass
    letting the die go onto the target and the weight's pulse under it. No boop."""
    return lay((0.0, glass_let_go(0.14, 0.8)), (0.05, A.pulse(92.0, 0.12, 0.7)))


def die_spend_self():
    return lay((0.0, die_spend()), (0.24, p5(0.8, 0.55)))


def reroll():
    """The flips as the glass fluttering for the 0.22 s they take, then the glass tapped as
    the dice land. Glass alone and short; the flutter brighter and harder than the second cut."""
    dur = 0.28
    n = n_of(dur)
    t = t_of(n)
    gate = 0.15 + 0.85 * (np.sin(2.0 * math.pi * 14.0 * t) > 0.0).astype(float)
    gate = np.convolve(gate, np.ones(n_of(0.0015)) / n_of(0.0015), mode="same")
    x = F.lp(F.hp(F.noise(n), 200.0), 2600.0) * gate * F.env_pts(n, [(0.0, 0.0), (0.015, 1.0), (dur - 0.02, 1.0), (dur, 0.0)])
    flips = R.body(np.concatenate([x * 1.4, np.zeros(n_of(0.3))]), "glass", 480.0, dur + 0.08)
    return lay((0.0, flips), (dur, R.shell_tap("glass", 450.0, 1.0, 0.14)))


def click(gain=1.0, pitch=1.0):
    """A digital click (Ryan: the relay sounded analog): two clean sine partials, four
    milliseconds, no noise and no casing."""
    k = F.knock([520.0 * pitch, 1040.0 * pitch, 1560.0 * pitch], [0.012, 0.008, 0.005], [0.8, 1.0, 0.35], noise_gain=0.0)
    n = n_of(0.003)
    k[:n] *= 0.5 * (1.0 - np.cos(np.linspace(0.0, math.pi, n)))   # a three-millisecond onset: the hard front cracked the speaker
    return k * gain * 0.55


def lock():
    """Closer to the shipped lock's clicks (two relays, the second under the tone), subtler:
    two soft relays with a short glass under the second instead of the tone. Both registers."""
    return lay((0.0, click(0.5)), (0.05, click(0.65, 0.9)), (0.05, p5(0.45, 0.5)))


def unlock():
    """One soft relay and the glass letting go."""
    return lay((0.0, click(0.5, 0.85)), (0.01, glass_let_go(0.12, 0.6)))


# ---------------------------------------------------------------- the console's own lines

def round_open():
    """The glass and then the plate bowed, one soft rising two-note on the boop, and nothing
    after it."""
    g = np.concatenate([R.bow(0.32, 1.0, 1400.0, 0.18), np.zeros(n_of(0.5))])
    glass = R.body(g, "glass", 560.0, 0.5)
    pl = np.zeros(n_of(1.1))
    pl = at(pl, R.bow(0.6, 1.0, 650.0, 0.35), 0.12)
    plate = R.body(pl, "plate", 180.0, 0.9)
    return lay((0.0, boop(B.B4, 0.34, 0.45, attack=0.02, close=(2200.0, 700.0))), (0.0, mix(glass * 0.6, plate) * 0.8))


def end_turn():
    """P21 alone, drawn out: the low plate bow and the chunk landing in it, handing control
    over (Ryan: it sounds like Protoss)."""
    d = 0.8
    pl = np.concatenate([R.bow(d, 1.0, 600.0, 0.18), np.zeros(n_of(0.9))])
    plate = R.body(pl, "plate", 150.0, None)
    n = len(plate)
    plate *= F.env_pts(n, [(0.0, 1.0), (d + 0.1, 1.0), (n / SR, 0.0)])   # tails off rather than being stopped
    return lay((0.0, plate), (d * 0.88, R.shell_tap("plate", 150.0, 1.0, 0.5)))


def codex_open():
    """Booting: a climbing boop figure, E4 G4 B4, quick, over a short glass bow."""
    return lay((0.0, boop(B.hz(0, 3), 0.09, 0.35)), (0.08, boop(B.hz(3, 3), 0.09, 0.35)), (0.16, boop(B.hz(7, 3), 0.14, 0.35, close=(2600.0, 1100.0))), (0.0, p5(1.1, 0.7)))


def codex_close():
    """Shutting down: the figure descending, quick, the glass letting go under it."""
    return lay((0.0, glass_let_go(0.26, 0.7)), (0.0, boop(B.hz(7, 3), 0.08, 0.32)), (0.08, boop(B.hz(3, 3), 0.08, 0.3)), (0.16, boop(B.hz(0, 3), 0.12, 0.3, bright=1600.0)))


def hold_readout():
    """The ping softened into a shoo: a breath of air swelling over a tenth of a second with a
    faint E3 inside it, eased in and out, the glass touch under its front."""
    dur = 0.9
    n = n_of(dur)
    t = t_of(n)
    air = F.bp(F.noise(n), 500.0, 1700.0) * F.env_pts(n, [(0.0, 0.0), (0.16, 1.0), (0.4, 0.4), (dur, 0.0)]) * 0.28   # the band kept under 2 kHz; the tail drawn out
    f = B.hz(0, 1)
    tone = (np.sin(2.0 * math.pi * f * t) + 0.5 * np.sin(2.0 * math.pi * f * 2.0 * t) + 0.2 * np.sin(2.0 * math.pi * f * 3.0 * t)) * F.env_pts(n, [(0.0, 0.0), (0.08, 1.0), (0.4, 0.45), (dur, 0.0)]) * 0.5
    return lay((0.0, p17(0.5, 0.35, 480.0)), (0.0, F.room(mix(air, tone), decay=0.14, mix=0.1, cut=2500.0)))


def route_set():
    """P5 with two pips and a rising pair of boops, E4 then B4: a waypoint logged, going up,
    not a cancel."""
    return lay((0.0, boop(B.A4, 0.07, 0.5)), (0.09, boop(B.A4, 0.09, 0.5)), (0.0, p5(0.7, 0.5)))


def menu_open():
    """The heavy press (P21 short) under a boop-boop on E5 from the first instant: PAUSED."""
    return lay((0.0, boop(B.B4, 0.12, 0.55)), (0.14, boop(B.B4, 0.15, 0.55)), (0.0, p21(0.8, 1.0, 180.0)))


def menu_close():
    """The full P21 that used to open the menu, with one lower boop over the top."""
    d = 0.5
    pl = np.concatenate([R.bow(d, 1.0, 600.0, 0.08), np.zeros(n_of(0.6))])
    plate = R.body(pl, "plate", 160.0, None)
    plate *= F.env_pts(len(plate), [(0.0, 1.0), (d, 1.0), (len(plate) / SR, 0.0)])
    return lay((0.0, boop(B.B3, 0.16, 0.8, attack=0.008, bright=1100.0)), (0.0, boop(B.B4, 0.12, 0.3, attack=0.008)), (0.0, plate), (d * 0.88, R.shell_tap("plate", 160.0, 0.8, 0.3)))


def refuse():
    return lay((0.0, p28()), (0.0, R.shell_scrape(170.0, 0.5)))


# name: (recipe, phone dB, shipped name, label, note)
SET = [
    ("tap", select, -20.0, "ui_tap", "A press, a menu item, select", "one act, one sound: the boop on E5 first, the glass under it; quiet, the commonest sound. Every ordinary button, the menu's forward, a selection in a panel"),
    ("map_select", map_select, -20.0, "ui_tap", "Map: a tile, a pack, a machine tapped", "softer, shorter and down: a short scan and one soft boop on G, a minor signal that something was boxed; its own pitch, not the confirm's"),
    ("press_heavy", lambda: p21(0.4, 1.0, 180.0), -20.0, "ui_tap", "A heavy press", "P21 short"),
    ("dismiss", dismiss, -21.0, "ui_back", "Dismiss", "the low boop first, P17 under it; also the menu's back"),
    ("confirm", confirm, -19.0, None, "Confirm", "P26 from the first instant, the glass under it; 3 dB down; the menu's select"),
    ("die_lift", lambda: p5(1.0), -17.0, "die_pick", "Die lifted", "glass alone"),
    ("die_hover", lambda: die_hover(1.2), -31.0, None, "Die over a valid target", "down again (the glass at 320, the buzz on E2) and quieter again, easing in"),
    ("die_spend", die_spend, -17.0, "die_drop", "Die spent", "no boop: the glass letting the die go and the pulse under it; one sound for a foe and a machine"),
    ("die_drop_back", lambda: p17(0.5, 0.8, 460.0), -21.0, "die_drop", "Die set back", "glass alone"),
    ("die_lock", lock, -20.0, "die_lock", "Die locked", "the digital clicks given a three-millisecond onset and longer, lower partials: the hard front cracked the speaker"),
    ("die_unlock", unlock, -20.0, "die_lock", "Die unlocked", "one digital click, the glass letting go"),
    ("reroll", reroll, -14.0, "die_roll", "Reroll", "the flips pitched down and a little shorter"),
    ("round_open", round_open, -15.0, None, "The round opens", "one long boop on B closing over the body, in place of the E-B pair that read as a confirm; a touch slower"),
    ("end_turn", end_turn, -20.0, "resolve", "End turn", "the plate swelling near its start, the chunk, and a long tail that fades rather than being stopped; 3 dB down again"),
    ("route_set", route_set, -16.0, "plot", "A route set", "two quick ticks on A over a quiet glass: logged, not confirmed, and not the map's figure"),
    ("hold_readout", hold_readout, -26.0, None, "A hold's readout", "the shoo softer again with a longer tail"),
    ("codex_open", codex_open, -21.0, "codex_open", "Codex opens", "the climbing figure E5 G5 B5 with its boops quieter and a longer glass under it"),
    ("codex_close", codex_close, -23.0, "codex_close", "Codex closes", "B5 G5 E5 the same way, the glass letting go under it longer"),
    ("menu_open", menu_open, -15.0, "menu_open", "Menu opens", "the boop-boop on B4 shorter again over the long under-glass"),
    ("menu_close", menu_close, -16.0, "menu_open", "Menu closes", "the plate swelling at the start and tailing off, the chunk in it, the low boop from the start"),
    ("nav_forward", select, -20.0, "ui_tap", "Menu: forward", "= a press"),
    ("nav_back", dismiss, -21.0, "ui_back", "Menu: back", "= dismiss"),
    ("nav_select", confirm, -19.0, "ui_tap", "Menu: select", "= confirm"),
    ("refuse", refuse, -15.0, "ui_back", "Refused", "P28 over a low scrape; the dropout's and the scrape's hard edges softened, which was the click on your speaker"),
]
SET_BY = {name: (fn, db, beside, label, note) for name, fn, db, beside, label, note in SET}
NAMES = {"touch": "tap", "touch_heavy": "press_heavy", "round_acquire": "round_open", "resolve": "end_turn", "route_clear": "dismiss", "select": "map_select"}

# A turn of the skirmish with the hover before each spend (seconds, console name or None, shipped name, dB).
TURN = [
    (0.3, "round_open", None, 0.0),
    (1.6, "die_lift", "die_pick", 0.0), (1.85, "die_hover_short", None, 0.0), (2.2, "die_spend", "die_drop", 0.0), (2.25, None, "gunfire", 0.0),
    (3.6, "die_lift", "die_pick", 0.0), (4.0, "die_drop_back", "die_drop", 0.0),
    (4.7, "die_lock", "die_lock", 0.0), (5.3, "reroll", "die_roll", 0.0),
    (6.5, "hold_readout", None, 0.0),
    (7.3, "die_lift", "die_pick", 0.0), (7.55, "die_hover_short", None, 0.0), (7.9, "die_spend", "die_drop", 0.0), (7.95, None, "laser", 0.0),
    (9.2, "die_lift", "die_pick", 0.0), (9.45, "die_hover_short", None, 0.0), (9.8, "die_spend", "die_drop", 0.0), (9.85, None, "shield_up", 0.0),
    (10.8, "end_turn", "resolve", 0.0),
    (12.0, None, "slash", 0.0), (12.1, None, "hit", -3.0), (12.6, None, "slash", 0.0), (12.7, None, "block", -3.0),
    (13.3, None, "slam", 0.0), (13.4, None, "hit", -3.0),
    (14.3, "round_open", None, 0.0),
    (15.6, "die_lift", "die_pick", 0.0), (15.85, "die_hover_short", None, 0.0), (16.2, "die_spend", "die_drop", 0.0), (16.25, None, "cannon", 0.0), (17.0, None, "kill", 0.0),
]
SET_BY["die_hover_short"] = ((lambda: die_hover(0.5)), -31.0, None, "", "")


def render_one(name):
    F.seed(PREFIX + name)
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
        X.write(PREFIX + name, X.tail(x, 0.35))
        pr = R.pierce(x)
        worst = max(worst, pr)
        manifest["palette"].append({"name": PREFIX + name, "beside": beside, "label": label, "note": note, "seconds": round(len(x) / SR, 2), "phone_db": db, "pierce_db": round(pr, 1)})
        print("  %s%-16s %5.2f s  phone %6.1f  pierce %6.1f" % (PREFIX, name, len(x) / SR, db, pr))
    print("  worst pierce %.1f dB" % worst)
    # the die's handoff on its own: lifted, hovering, spent
    F.seed(PREFIX + "handoff")
    x = lay((0.0, render_one("die_lift")[0]), (0.3, render_one("die_hover")[0]), (1.4, render_one("die_spend")[0]))
    X.write(PREFIX + "handoff", X.tail(x, 0.35))
    manifest["palette"].append({"name": PREFIX + "handoff", "seconds": round(len(x) / SR, 2)})
    for key_, base, events in (("con_turn", X.bed("music_hold_the_line", 8, 8, 104), TURN),
                               ("con_climax", X.bed("music_hold_the_line", C.climax_bar(), 8, 104), TURN),
                               ("con_map", X.bed("music_night_shift", 8, 6, 94), C.MAP)):
        F.seed(PREFIX + "seq_" + key_)
        buf = np.array(base) * 10.0 ** (C.BED_DB / 20.0)
        for when, con, now, db in events:
            if con is not None:
                x, _, _, _, _ = render_one(NAMES.get(con, con))
            elif now is not None:
                x = X.level(X.shipped(now), F.LEVELS[now])
            else:
                continue
            buf = at(buf, x * 10.0 ** (db / 20.0), when)
        name = "seq_%s_%s" % (key_, PREFIX.rstrip("_"))
        X.write(name, X.tail(buf, 0.5))
        manifest["palette"].append({"name": name, "seconds": round(len(buf) / SR, 2)})
        print("  %-22s %5.1f s" % (name, len(buf) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
