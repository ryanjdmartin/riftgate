"""The console, derived again (Ryan, 2 October: the rounds since 30 September were increments,
not a shift; derive the interface's sound from the UI design, the music's atmosphere and the
direction notes, not from the existing sounds). Nothing here is shipped; a pick lands in forge.py.

What the UI is. CARE's tactical display is a feed being analysed: a vector HUD of bracketed
readouts, slanted gauges, a terminal log and dice with corner brackets, whose motion has four
verbs already on screen. Brackets collapse onto a thing over a third of a second as the display
acquires it; digits scramble (45 ms frames on an intent, 18 fps on the orders board) and
settle; text types at 12 ms a character; a thing lands (0.35 s; a reroll's flip 0.22 s). Every
button plays a tap on press (`hud_button.gd`), and four of them, MENU, END TURN, RESOLVE and
ENGAGE, are blanked because their action plays its own sound. It is a digital feed: it
quantises, holds, drops frames and resolves; it never hisses.

Its own instrument (Ryan, 2 October, after the first cut of this pass: the console needs an
identity of its own that sits in the music's atmosphere without drawing on its instruments,
since the skirmish rotates three tracks and the map two more; no static, since the feed is
digital not analog; no knock, since the human register has a digital softness beside its heavy
gain, and only the weapons hit hard). So the console is an FM terminal: that era's cockpits
and consoles were FM synths and sample cards, retro-future digital, and FM's glassy, faintly
metallic tones are a timbre no instrument in the music uses (saws, guitars, piano, orchestra),
so the separation is in kind, not level. Its motions are digital: a tone that starts coarse
(a high modulation index, a shallow bit depth) and resolves to clean as the brackets land; the
same run backward for a thing let go; pitches that step, never glide. Four verbs:

  touch     every button: a short soft FM tick, a slow enough front that it is a key, not a click.
  acquire   the display grabbing something: a tone resolving from coarse to clean over the time
            the brackets take, landing with them. Selecting, lifting a die, a readout opening, a
            foe's intent locking, the round opening with every intent at once (the console's
            signature line, with a short falling figure after it).
  confirm   a thing committed: a soft bloom, a low body with a brief FM burst on its front, then
            a dyad sustained and closing under a filter. Weight from depth, not from a hit. Small
            for a lock, medium for a die spent, large for RESOLVE and END TURN as three stepped
            notes, E, B, E, the last held.
  refuse    the one wrong note: F falling to E, dry and short.

And a scramble: the orders board's line or a reroll's flips as quantised pitches stepping at
the display's own frame rate and landing on the note. The digit scramble made audible as
pitch, and the only "work" the console does out loud.

Pitches are E and B (every track is E-centred, so they sit under all five), E5 and B5 for the
speaker with an E4 or E3 body for headphones; a speaker plays nothing under about 220 Hz and
the guitars fill the band to 1,500 Hz, so the identity lives above that. Every file is
levelled by what the phone model plays of it. Gaps the code has, which a pick adds a hook for:
no "seated over a target" state during a drag; nothing animates when a round deals its dice;
an invalid drop and a disabled press are silent; the codex, confirm panel, hold readout and
menu appear with no transition.

    python3 tools/soundforge/console_sketches.py          # the console into out/fx (after fx_sketches.py)
"""
import json
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as X  # noqa: E402  (the writer, the beds and the shipped files: plumbing, not design)
from phone_sketches import phone_model  # noqa: E402

SR = F.SR
n_of, t_of, mix, at = F.n_of, F.t_of, F.mix, F.at

# ---------------------------------------------------------------- the key
E2 = 82.41


def hz(semis, octave):
    return E2 * 2.0 ** (semis / 12.0) * 2.0 ** octave


E3, E4, B4, E5, B5, E6, F5 = hz(0, 1), hz(0, 2), hz(7, 2), hz(0, 3), hz(7, 3), hz(0, 4), hz(1, 3)
SCRAMBLE = 1.0 / 0.045   # the intent acquire's digit frames
BOARD = 18.0             # the orders board's scramble
BED_DB = -4.0            # the music under the sequences, pulled down (Ryan, 2 October: too loud against the UI)


def shape(n, points):
    return F.env_pts(n, points)


def curve(n, a, b, power=1.6):
    """From a to b over the buffer, fast first."""
    return a + (b - a) * np.linspace(0.0, 1.0, n) ** (1.0 / power)


# ---------------------------------------------------------------- the instrument

def fm(f, dur, ratio=2.0, index=1.0, amp=None, feedback=0.0):
    """One FM voice: a sine carrier at `f` phase-modulated by a sine at `f * ratio` with
    `index` (a number or a per-sample array; high is coarse and metallic, zero is a pure
    sine). `amp` is the envelope; a touch of feedback on the modulator adds edge."""
    n = n_of(dur)
    t = t_of(n)
    idx = np.broadcast_to(np.asarray(index, dtype=float), (n,))
    ph_m = 2.0 * math.pi * f * ratio * t
    mod = np.sin(ph_m + feedback * np.sin(ph_m))
    x = np.sin(2.0 * math.pi * f * t + idx * mod)
    if amp is None:
        amp = shape(n, [(0.0, 0.0), (0.004, 1.0), (dur * 0.6, 0.7), (dur, 0.0)])
    return x * amp


def bits(x, depth):
    """Bit depth per sample: coarse (3 or 4 bits) is the feed not yet resolved; 16 is clean."""
    d = np.broadcast_to(np.asarray(depth, dtype=float), (len(x),))
    steps = 2.0 ** d
    return np.round(x * steps) / steps


def glass(x, decay=0.07, mixv=0.14):
    """The terminal's small digital room: short and bright."""
    return F.room(x, decay=decay, mix=mixv, cut=7000.0, pre=0.003)


def lowpass_closing(x, c0, c1):
    return F.lp_var(x, np.geomspace(c0, c1, len(x)), passes=1)


# ---------------------------------------------------------------- the verbs

def touch(weight=1.0):
    """Every button: a soft FM tick. Inharmonic ratio so it is glass, not a note; a 3 ms
    front so it is a key under a finger, not a relay."""
    n = n_of(0.045)
    amp = shape(n, [(0.0, 0.0), (0.003, 1.0), (0.012, 0.5), (0.045, 0.0)])
    x = fm(1760.0, 0.045, ratio=1.414, index=curve(n, 2.2, 0.3), amp=amp)
    under = fm(440.0, 0.045, ratio=2.0, index=0.4, amp=amp * 0.5) * weight
    return glass(mix(x, under), decay=0.04, mixv=0.1) * 0.8


def acquire(dur=0.3, note=B5, gain=1.0, body=0.5, coarse=5.0):
    """The display grabbing something: a tone resolving from coarse to clean over `dur`, the
    FM index falling from `coarse` to nothing and the bit depth climbing from 3 bits to 16
    on the same curve, landing clean as the brackets land. A body an octave or two under
    for headphones. No glide: the pitch is the note from the first sample."""
    n = n_of(dur)
    p = np.linspace(0.0, 1.0, n) ** 0.7
    index = coarse * (1.0 - p) ** 2.0
    depth = 3.0 + 13.0 * p
    amp = shape(n, [(0.0, 0.0), (dur * 0.12, 0.8), (dur * 0.9, 1.0), (dur, 0.0)])
    x = bits(fm(note, dur, ratio=2.0, index=index, amp=amp), depth)
    x = mix(x, bits(fm(note * 0.5, dur, ratio=3.0, index=index * 0.6, amp=amp * 0.6), depth) * body,
            fm(note * 0.25, dur, ratio=2.0, index=0.3, amp=amp * 0.5) * body * 0.8)
    land = fm(note * 2.0, 0.05, ratio=1.414, index=1.2, amp=shape(n_of(0.05), [(0.0, 0.0), (0.002, 1.0), (0.05, 0.0)])) * 0.5
    return glass(at(x, land, dur - 0.04)) * gain


def release(dur=0.18, note=B5, gain=1.0):
    """The reverse: a clean note going coarse and out. A thing let go. Nothing lands."""
    n = n_of(dur)
    p = np.linspace(0.0, 1.0, n) ** 1.4
    amp = shape(n, [(0.0, 1.0), (dur * 0.5, 0.7), (dur, 0.0)])
    x = bits(fm(note, dur, ratio=2.0, index=4.0 * p, amp=amp), 16.0 - 12.0 * p)
    x = mix(x, fm(note * 0.5, dur, ratio=2.0, index=0.3 + 2.0 * p, amp=amp * 0.5))
    return glass(x, decay=0.05) * gain


def bloom(f=E4, dur=0.22, burst=3.0, gain=1.0):
    """Confirm's weight: a low sine body with a brief FM burst on its front (the index falls
    from `burst` to nothing in the first sixty milliseconds), soft, deep, no hit."""
    n = n_of(dur)
    t = t_of(n)
    index = burst * np.exp(-t / 0.02)
    amp = shape(n, [(0.0, 0.0), (0.012, 1.0), (dur * 0.5, 0.6), (dur, 0.0)])
    x = fm(f, dur, ratio=3.0, index=index, amp=amp)
    x = mix(x, fm(f * 0.5, dur, ratio=2.0, index=0.2, amp=amp) * 0.7)   # headphones
    return x * gain


def dyad(semis, dur, octave=3, c0=6000.0, c1=900.0, hold=0.4, gain=1.0):
    """The sustained part of a confirm: two clean FM notes, a slow front, closing under a
    low-pass over the hold."""
    n = n_of(dur)
    amp = shape(n, [(0.0, 0.0), (0.018, 1.0), (dur * hold, 0.9), (dur, 0.0)])
    x = np.zeros(n)
    for s in semis:
        x += fm(hz(s, octave), dur, ratio=2.0, index=0.7, amp=amp, feedback=0.3)
    x /= max(1, len(semis))
    return lowpass_closing(x, c0, c1) * gain


def confirm(weight="medium"):
    """Something committed. Small: a lock. Medium: a die spent. Large: RESOLVE and END TURN,
    three stepped notes E, B, E, the last held: weapons online. Steps, never a glide."""
    if weight == "small":
        return glass(mix(bloom(E4, 0.16, 2.0, 0.6), dyad([0, 7], 0.18, 3, hold=0.3, gain=0.7)))
    if weight == "medium":
        return glass(mix(bloom(E4, 0.26, 3.0, 0.9), dyad([0, 7], 0.3, 3, hold=0.4)))
    buf = bloom(E3, 0.5, 3.5, 1.0)
    buf = at(buf, dyad([0], 0.11, 2, c0=4000.0, c1=2500.0, hold=0.7, gain=0.8), 0.0)
    buf = at(buf, dyad([7], 0.11, 2, c0=4500.0, c1=2800.0, hold=0.7, gain=0.85), 0.1)
    buf = at(buf, bloom(E4, 0.4, 2.5, 0.7), 0.2)
    buf = at(buf, dyad([0, 7, 12], 0.6, 3, c0=7000.0, c1=700.0, hold=0.45), 0.2)
    return glass(buf, decay=0.09, mixv=0.18)


def refuse():
    """The one wrong note: F falling to E, dry, a slightly sour ratio, short."""
    n1, n2 = n_of(0.1), n_of(0.16)
    a = fm(F5, 0.1, ratio=1.5, index=1.4, amp=shape(n1, [(0.0, 0.0), (0.005, 1.0), (0.08, 0.7), (0.1, 0.0)]))
    b = fm(E5, 0.16, ratio=1.5, index=1.0, amp=shape(n2, [(0.0, 0.0), (0.005, 1.0), (0.1, 0.6), (0.16, 0.0)]))
    buf = at(a, b, 0.095)
    buf = at(buf, fm(E4, 0.2, ratio=2.0, index=0.5) * 0.5, 0.095)
    return buf


def scramble(dur, note=B5, rate=BOARD, gain=1.0, pool=(0, 3, 7, 10, 12, 15)):
    """Digits flipping as pitch: quantised notes from the E set stepping at `rate`, each a
    clean short FM tone, the pool narrowing toward the note, landing on it."""
    buf = np.zeros(n_of(dur) + n_of(0.08))
    step = 1.0 / rate
    t = 0.0
    k = 0
    total = int(dur / step)
    while t < dur - step * 0.5:
        p = k / max(total - 1, 1)
        choices = pool if p < 0.5 else pool[-3:]
        s = choices[int(F.RNG.integers(0, len(choices)))]
        f = E5 * 2.0 ** (s / 12.0)
        d = step * 0.9
        n = n_of(d)
        x = fm(f, d, ratio=2.0, index=0.6 + 1.5 * (1.0 - p), amp=shape(n, [(0.0, 0.0), (0.004, 1.0), (d * 0.7, 0.6), (d, 0.0)]))
        buf = at(buf, x, t, gain * (0.5 + 0.5 * p))
        t += step
        k += 1
    n = n_of(0.08)
    land = fm(note, 0.08, ratio=2.0, index=0.3, amp=shape(n, [(0.0, 0.0), (0.004, 1.0), (0.05, 0.7), (0.08, 0.0)]))
    return glass(at(buf, land, dur)) * gain


def steps(notes, each=0.06, octave=3, gain=0.6, index=0.5):
    """A short figure of clean notes: the console's own line."""
    buf = np.zeros(1)
    for k, s in enumerate(notes):
        n = n_of(each * 1.6)
        x = fm(hz(s, octave), each * 1.6, ratio=2.0, index=index, amp=shape(n, [(0.0, 0.0), (0.004, 1.0), (each, 0.7), (each * 1.6, 0.0)]))
        buf = at(buf, x, k * each, gain)
    return glass(buf)


# ---------------------------------------------------------------- the events

def e_touch():
    return touch(1.0)


def e_touch_heavy():
    return touch(1.6)


def e_select():      # a machine, a pack or a hex tapped on the map: the brackets land on it
    return at(touch(1.0), acquire(0.2, B5, 0.8), 0.0)


def e_dismiss():     # the second tap, or the readout dismissed: the brackets let go
    return at(touch(0.8), release(0.18, B5), 0.0)


def e_die_lift():    # the slot clears, the ghost follows the finger, the targets light
    return at(touch(0.9), acquire(0.22, E5, 0.75), 0.0)


def e_die_drop_back():   # dropped on nothing: the ghost vanishes
    return release(0.16, E5, 0.9)


def e_die_lock():    # corners snap on, LOCKED under it
    buf = touch(1.0)
    buf = at(buf, acquire(0.1, B5, 0.6, body=0.3, coarse=3.0), 0.0)
    return at(buf, confirm("small"), 0.08)


def e_die_unlock():
    return at(touch(0.9), release(0.14, B5, 0.7), 0.0)


def e_die_spend():   # a die spent on a foe: the die greys, the blow follows (the iron's)
    return confirm("medium")


def e_die_spend_self():   # on a machine: a shield, a vent, a buff; something going up on it
    return at(confirm("medium"), steps([0, 7, 12], 0.055, 3, 0.35), 0.12)


def e_reroll(dice=3):   # the press, the flips as a scramble for the 0.22 s they take, each die landing
    buf = at(touch(1.1), scramble(0.22, E5, 30.0, 0.8), 0.0)
    for k in range(dice):
        f = (E5, B5, E6)[k % 3]
        n = n_of(0.12)
        buf = at(buf, fm(f, 0.12, ratio=2.0, index=0.4, amp=shape(n, [(0.0, 0.0), (0.004, 1.0), (0.08, 0.6), (0.12, 0.0)])) * 0.5, 0.22 + k * 0.045)
    return buf


def e_round_acquire():   # the round opens: every intent acquired at once over 0.3 s, then the console's line
    buf = scramble(0.165, B5, SCRAMBLE, 0.5)
    buf = at(buf, acquire(0.3, B5, 1.2, body=0.7, coarse=6.0), 0.0)
    return at(buf, steps([12, 7, 0], 0.07, 3, 0.55, index=0.4), 0.32)


def e_end_turn():    # the primary press, weapons online, then the readout to ENEMY PHASE
    buf = at(touch(1.6), confirm("large"), 0.0)
    return at(buf, scramble(0.3, E5, BOARD, 0.35), 0.78)


def e_resolve():     # the map's commit
    return at(touch(1.6), confirm("large"), 0.0)


def e_route_set():   # a lit hex tapped: the orders board's line scrambles 0.45 s and settles
    return at(touch(1.0), scramble(0.45, B5, BOARD, 0.7), 0.0)


def e_route_clear():
    return at(touch(0.9), release(0.2, E5, 0.8), 0.0)


def e_hold_readout():   # at 0.45 s of a hold the panel opens; no touch, the finger is down
    return acquire(0.2, B5, 0.6, body=0.3)


def e_codex_open():   # the shade, the plate acquired, its text typing in
    buf = at(touch(1.0), steps([12, 7, 0], 0.05, 3, 0.3, index=0.3), 0.0)
    buf = at(buf, acquire(0.3, B5, 0.9), 0.1)
    return at(buf, scramble(0.4, E6, 1.0 / 0.012 / 3.0, 0.2, pool=(12, 15, 19)), 0.42)


def e_codex_close():
    return at(at(touch(0.8), release(0.18, B5, 0.8), 0.0), steps([0, 7, 12], 0.05, 3, 0.25, index=0.3), 0.06)


def e_menu_open():    # MENU: the scrim comes down, PAUSED
    buf = at(touch(1.4), steps([12, 7, 0], 0.07, 3, 0.45, index=0.4), 0.0)
    return at(buf, confirm("small"), 0.2)


def e_menu_close():
    return at(touch(1.0), steps([0, 7, 12], 0.06, 3, 0.4, index=0.4), 0.0)


def e_refuse():      # NO ROUTE, a drop on nothing valid, a disabled press
    return refuse()


# name: (recipe, target dB as the phone plays it, the shipped sound it would replace, the row's note)
CONSOLE = {
    # the verbs alone
    "verb_touch": ((lambda: touch(1.0)), -24.0, None, "touch"),
    "verb_acquire": ((lambda: acquire(0.3, B5, 1.0)), -16.0, None, "acquire: coarse to clean over a third of a second, landing on B"),
    "verb_scramble": ((lambda: scramble(0.45, B5, BOARD, 0.8)), -17.0, None, "the scramble: digits flipping as pitch, landing"),
    "verb_confirm_small": ((lambda: confirm("small")), -16.0, None, "confirm, small"),
    "verb_confirm_medium": ((lambda: confirm("medium")), -14.0, None, "confirm, medium"),
    "verb_confirm_large": ((lambda: confirm("large")), -11.0, None, "confirm, large: E, B, E, weapons online"),
    "verb_refuse": (refuse, -15.0, None, "refuse: F to E"),
    # the events
    "touch": (e_touch, -24.0, "ui_tap", "any ordinary press"),
    "touch_heavy": (e_touch_heavy, -21.0, "ui_tap", "a primary press, before its confirm"),
    "select": (e_select, -17.0, "ui_tap", "a machine, a pack or a hex tapped on the map"),
    "dismiss": (e_dismiss, -21.0, "ui_back", "the second tap or the readout dismissed"),
    "die_lift": (e_die_lift, -17.0, "die_pick", "the die lifted"),
    "die_drop_back": (e_die_drop_back, -21.0, "die_drop", "dropped on nothing"),
    "die_lock": (e_die_lock, -16.0, "die_lock", "tap to lock"),
    "die_unlock": (e_die_unlock, -20.0, "die_lock", ""),
    "die_spend": (e_die_spend, -14.0, "die_drop", "a die spent on a foe"),
    "die_spend_self": (e_die_spend_self, -14.0, "die_drop", "a die spent on a machine"),
    "reroll": (e_reroll, -16.0, "die_roll", "the press, the flips, each die landing"),
    "round_acquire": (e_round_acquire, -12.0, None, "the round opens"),
    "end_turn": (e_end_turn, -11.0, "resolve", "weapons online, then ENEMY PHASE"),
    "resolve": (e_resolve, -11.0, "resolve", "the map's commit"),
    "route_set": (e_route_set, -16.0, "plot", "a hex tapped"),
    "route_clear": (e_route_clear, -20.0, "ui_back", ""),
    "hold_readout": (e_hold_readout, -19.0, None, "a hold's readout"),
    "codex_open": (e_codex_open, -15.0, "codex_open", ""),
    "codex_close": (e_codex_close, -18.0, "codex_close", ""),
    "menu_open": (e_menu_open, -14.0, "menu_open", ""),
    "menu_close": (e_menu_close, -17.0, "menu_open", ""),
    "refuse": (e_refuse, -15.0, "ui_back", "NO ROUTE; an invalid drop; a disabled press"),
}


# ---------------------------------------------------------------- levels and writing

def phone_loudness(x):
    return F.loudness(phone_model(x))


def level_for_phone(x, db):
    """Scale so the phone model's loudest 50 ms sits at `db`."""
    return x * 10.0 ** ((db - phone_loudness(x)) / 20.0)


def render_one(name):
    F.seed("con_" + name)
    fn, db, beside, note = CONSOLE[name]
    x = level_for_phone(fn(), db)
    return x, db, beside, note


# A turn of the skirmish, console only plus the shipped blows for context, over Hold The Line.
# (seconds, console name or None, shipped name or None for the "now" lay, dB offset)
TURN = [
    (0.3, "round_acquire", None, 0.0),
    (1.6, "die_lift", "die_pick", 0.0), (2.1, "die_spend", "die_drop", 0.0), (2.15, None, "gunfire", 0.0),
    (3.6, "die_lift", "die_pick", 0.0), (4.0, "die_drop_back", "die_drop", 0.0),
    (4.7, "die_lock", "die_lock", 0.0), (5.3, "reroll", "die_roll", 0.0),
    (6.5, "hold_readout", None, 0.0),
    (7.3, "die_lift", "die_pick", 0.0), (7.8, "die_spend", "die_drop", 0.0), (7.85, None, "laser", 0.0),
    (9.2, "die_lift", "die_pick", 0.0), (9.7, "die_spend_self", "die_drop", 0.0), (9.75, None, "shield_up", 0.0),
    (10.8, "end_turn", "resolve", 0.0),
    (12.0, None, "slash", 0.0), (12.1, None, "hit", -3.0), (12.6, None, "slash", 0.0), (12.7, None, "block", -3.0),
    (13.3, None, "slam", 0.0), (13.4, None, "hit", -3.0),
    (14.3, "round_acquire", None, 0.0),
    (15.6, "die_lift", "die_pick", 0.0), (16.1, "die_spend", "die_drop", 0.0), (16.15, None, "cannon", 0.0), (16.9, None, "kill", 0.0),
]
MAP = [   # the map: select, routes, a refusal, the commit, the moves, the menu, the codex, over Night Shift
    (0.4, "select", "ui_tap", 0.0), (1.0, "route_set", "plot", 0.0),
    (1.9, "select", "ui_tap", 0.0), (2.6, "route_set", "plot", 0.0),
    (3.5, "refuse", "ui_back", 0.0), (4.1, "route_set", "plot", 0.0),
    (5.0, "touch", "ui_tap", 0.0), (5.8, "resolve", "resolve", 0.0),
    (6.6, None, "step", 0.0), (6.95, None, "step", 0.0), (7.3, None, "step", 0.0), (7.65, None, "step", 0.0),
    (8.6, "menu_open", "menu_open", 0.0), (9.9, "menu_close", "ui_back", 0.0),
    (10.6, "codex_open", "codex_open", 0.0), (12.0, "codex_close", "codex_close", 0.0),
]


def lay(base, events, which):
    buf = np.array(base) * 10.0 ** (BED_DB / 20.0)
    for when, con, now, db in events:
        if which == "new":
            if con is not None:
                x, _, _, _ = render_one(con)
            elif now is not None:
                x = X.level(X.shipped(now), F.LEVELS[now])
            else:
                continue
        else:
            if now is None:
                continue
            x = X.level(X.shipped(now), F.LEVELS[now])
        buf = at(buf, x * 10.0 ** (db / 20.0), when)
    return buf


def climax_bar():
    """Hold The Line's first climax bar (S), in 4/4 bars from the top: sixteen-step bars
    except the twelve bars of seven (fourteen steps)."""
    form = F.MUSIC["music_hold_the_line"]["form"].replace(" ", "")
    before = form[:form.index("S")]
    return sum(14 if c == "X" else 16 for c in before) / 16.0


def main(argv):
    os.makedirs(X.OUT, exist_ok=True)
    path = os.path.join(X.OUT, "manifest.json")
    manifest = {"singles": [], "sequences": []}
    if os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
    manifest["console"] = []
    print("console")
    for name in CONSOLE:
        x, db, beside, note = render_one(name)
        X.write("con_" + name, X.tail(x, 0.3))
        full = F.loudness(x)
        manifest["console"].append({"name": "con_" + name, "beside": beside, "seconds": round(len(x) / SR, 2),
                                    "phone_db": db, "full_db": round(full, 1), "note": note})
        print("  con_%-18s %5.2f s  phone %6.1f  full %6.1f  (%+.1f)" % (name, len(x) / SR, db, full, full - db))
        if beside and not os.path.exists(os.path.join(X.OUT, "now_%s.mp4" % beside)):
            y = X.level(X.shipped(beside), F.LEVELS[beside])
            X.write("now_" + beside, X.tail(y))
    print("sequences")
    seqs = [
        ("con_turn", X.bed("music_hold_the_line", 8, 8, 104), TURN, "a turn over Hold The Line's riff, bar nine on"),
        ("con_climax", X.bed("music_hold_the_line", climax_bar(), 8, 104), TURN, "the same turn over the climax"),
        ("con_map", X.bed("music_night_shift", 8, 6, 94), MAP, "the map over Night Shift"),
    ]
    for key_, base, events, note in seqs:
        for which in ("now", "new"):
            F.seed("con_seq_" + key_ + which)
            x = lay(base, events, which)
            name = "seq_%s_%s" % (key_, which)
            X.write(name, X.tail(x, 0.5))
            manifest["console"].append({"name": name, "seconds": round(len(x) / SR, 2), "note": note, "which": which})
            print("  %-20s %5.1f s" % (name, len(x) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
