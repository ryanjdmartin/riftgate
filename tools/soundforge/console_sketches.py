"""The console, a fresh pass (Ryan, 2 October: the rounds since 30 September were incremental
adjustments, not a shift in direction; derive the interface's sound again from the UI design,
the music, Hold The Line above all, and the direction notes, without the existing sounds or
the existing choice of what sounds). Nothing here is shipped; a pick lands in forge.py.

What the UI is. CARE's tactical display is a feed being analysed, not a panel of buttons: a
vector HUD of bracketed readouts, slanted gauges, a terminal log and dice with corner
brackets. Its motion has four verbs, all already on screen: brackets collapse onto a thing
over a third of a second as the display acquires it; digits scramble and settle (45 ms
frames on an intent, 18 fps on the orders board) as it works; text types in at 12 ms a
character; and a thing lands (the SETTLE, 0.35 s; a reroll's flip, 0.22 s; the contact
panel's slide, 0.22 s). Buttons never take an effect (the bible's rule), and the code blanks
the button sound on MENU, END TURN, RESOLVE and ENGAGE because the action carries its own.
Nothing moves while the player is thinking; a constant sound on a phone is fatigue.

So the sound follows the display, not the finger. The finger is nearly nothing: a dry
contact on glass, the same for every press. Everything else is the display answering, and
each answer is one of five verbs that twin the four motions plus a refusal:

  touch     the finger on the glass. Dry, mid, fifteen milliseconds. Weight is the only
            variation (a primary press is heavier).
  acquire   the display grabbing something: a band of static narrowing onto a pitch over the
            time the brackets take to land, ending as the brackets land. The filter moves;
            the pitch does not. Selecting, lifting a die, a readout opening, a foe's intent
            locking on, and the round opening with every intent at once.
  work      the display computing: ticks at the scramble's own frame rate, filtered noise a
            few milliseconds long, thinning as the digits settle; typing is the same at the
            log's rate. The Terran console's data. A reroll, a route set, a line typing.
  confirm   a thing committed: a thump in the band a speaker plays (the weight) under a
            short chord from the drone's own voice with its filter closing (MechWarrior 2's
            confirm). Small for a lock, medium for a die spent, large for RESOLVE and END
            TURN: three stepped notes, E, B, E, the last held and closing; weapons online.
  refuse    the one dissonance: the Phrygian second, F falling to E, both dull, a muted knock
            under. NO ROUTE, a drop that lands on nothing valid, a disabled press.

Where it comes from. Hold The Line is in E Phrygian (E F G A B C D) at 104, and Ryan singled
out its drone, the sweep pad's saws held on one chord with the filter three quarters open, as
the element for every human track; the interface is CARE's and human, so the console's
pitched voice is that drone's saws through that filter (`pad_sweep`'s dark and bright pair),
chorused as that era's cockpits were, on E and B, with F for no. The direction notes: a 90s
computer game's cockpit (StarCraft 1's panel, MechWarrior 2's targeting computer, Descent's
menus), retro-future not retro, deliberate and with intent, weighty, irony not parody.

The phone decides the pitches and the levels. A speaker plays nothing under about 220 Hz,
so an E3 (165 Hz) is silent there and E4 (330) is thin; the chug guitar fills everything to
1,500 Hz in E, so a console tone inside that band is masked by the music it is tuned to.
Hence: identity lives from 2 kHz up (the static of an acquire, the ticks of work), the
pitched voice sits at E5 and B5 with E6 over it, the weight of a confirm is a knock at 300
to 600 Hz rather than a sub, and an E3 rides under for headphones only. Every sound here is
levelled by what the phone model plays of it (its loudness through `phone_model`), so a
sound heavy in the lows is written hotter rather than vanishing on the speaker; the page
says both figures.

Gaps the code has today, which a pick would add a hook for: no "seated over a target" state
during a drag (lift, move and drop are the only events), so the bible's seated-die voice has
nothing to hang on; nothing animates when a round deals its dice; a drop on an invalid unit
is silent and invisible; a disabled button emits nothing; the codex, the confirm panel, the
hold readout and the menu appear and vanish with no transition.

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
RNG = lambda: F.RNG  # noqa: E731  (seeded per sound by F.seed)

# ---------------------------------------------------------------- the key
# Hold The Line's E. Semitones from E; octave 0 is E2 (82 Hz), so octave 3 puts E at 659 Hz.
E2 = 82.41


def hz(semis, octave):
    return E2 * 2.0 ** (semis / 12.0) * 2.0 ** octave


E4, E5, B5, E6, F5 = hz(0, 2), hz(0, 3), hz(7, 3), hz(0, 4), hz(1, 3)
SCRAMBLE = 1.0 / 0.045   # the intent acquire's digit frames
BOARD = 18.0             # the orders board's scramble
TYPING = 1.0 / 0.012     # the log


# ---------------------------------------------------------------- the voice: the drone's saws

def drone(semis, dur, octave=3, open_=0.75, detune=(0.994, 1.0, 1.006)):
    """Hold The Line's drone: detuned saws through the sweep pad's two filters blended (dark
    420 Hz, bright 2,600 Hz), `open_` where the blend sits, a number or a per-sample array.
    The filter may move; the pitch never does."""
    n = n_of(dur)
    x = np.zeros(n)
    for s in semis:
        x += F.saws(hz(s, octave), n, detune)
    x /= max(1, len(semis))
    x = F.sat(x, 1.4)
    dark, bright = F.lp(x, 420.0), F.lp(x, 2600.0)
    o = np.clip(np.broadcast_to(np.asarray(open_, dtype=float), (n,)), 0.0, 1.0)
    return dark * (1.0 - o) + bright * o


def chorus(x, depth=0.0028, rate=0.7, wet=0.55):
    """The era's gloss: two copies on slowly moving short delays."""
    n = len(x)
    t = t_of(n)
    idx = np.arange(n)
    out = np.array(x, dtype=float)
    for r, ph in ((rate, 0.0), (rate * 1.37, 2.1)):
        d = 0.007 + depth * np.sin(2.0 * math.pi * r * t + ph)
        out += np.interp(idx - d * SR, idx, x, left=0.0) * (wet / 2.0)
    return out


def closing(n, a=0.75, b=0.12, curve=1.6):
    """A filter position falling from a to b over the buffer, fast first."""
    p = np.linspace(0.0, 1.0, n) ** (1.0 / curve)
    return a + (b - a) * p


def shape(n, points):
    return F.env_pts(n, points)


# ---------------------------------------------------------------- the five verbs

def touch(weight=1.0):
    """The finger on the glass: a dry contact, a little body under it so it exists on a
    speaker, fifteen milliseconds, no spring and no casing ring."""
    c = F.knock([2600.0, 4100.0], [0.003, 0.002], [1.0, 0.6], noise_gain=0.8) * 0.8
    b = F.knock([640.0, 980.0], [0.007, 0.005], [1.0, 0.5], noise_gain=0.15) * 0.5 * weight
    u = F.body(520.0, 330.0, 0.03, drive=1.5, click=0.0) * 0.2 * weight
    return F.lp(mix(c, b, u), 6000.0)


def converge(dur=0.3, note=B5, gain=1.0, start_width=1.8, end_width=0.03, rise=0.25, under=0.35):
    """Acquire: static narrowing onto the note over `dur`. A Hann-windowed band-pass, frame
    by frame, whose width (in octaves either side of the note) falls from `start_width` to
    `end_width`, its level held as it narrows so the noise becomes the pitch; the drone's E
    opens under it (E4 for the speaker, E3 for headphones) at `under`."""
    n = n_of(dur)
    frame = n_of(0.012)
    hop = frame // 2
    win = np.hanning(frame)
    src = F.noise(n + frame)
    out = np.zeros(n + frame)
    w0 = start_width
    for start in range(0, n, hop):
        p = start / float(n)
        w = (w0 - end_width) * (1.0 - p) ** 2.2 + end_width
        lo, hi = note * 2.0 ** (-w), note * 2.0 ** w
        seg = src[start:start + frame] * win
        y = F.bp(seg, max(lo, 150.0), min(hi, 12000.0), order=2)
        bw = min(hi, 12000.0) - max(lo, 150.0)
        bw0 = note * (2.0 ** w0 - 2.0 ** -w0)
        y *= 1.0 / math.sqrt(max(bw, note * 0.04) / bw0)
        out[start:start + frame] += y
    x = out[:n] * shape(n, [(0.0, 0.0), (dur * rise, 1.0), (dur * 0.85, 1.0), (dur, 0.0)])
    x = F.lp(x, 9000.0) * 0.9
    if under > 0.0:
        o = shape(n, [(0.0, 0.15), (dur, 0.75)])
        d = mix(drone([0], dur, 2, o) * 0.7, drone([0], dur, 1, o) * 0.5)
        d *= shape(n, [(0.0, 0.0), (dur * 0.3, 1.0), (dur, 0.6)])
        x = mix(x, chorus(d) * under)
    return x * gain


def release(dur=0.18, note=B5, gain=1.0):
    """The reverse of an acquire: the note dissolving back into static and gone over `dur`.
    A cancel, a dismiss, a die set back. No tick at the end: nothing landed."""
    n = n_of(dur)
    frame = n_of(0.012)
    hop = frame // 2
    win = np.hanning(frame)
    src = F.noise(n + frame)
    out = np.zeros(n + frame)
    for start in range(0, n, hop):
        p = start / float(n)
        w = 0.03 + 1.6 * p ** 1.6
        lo, hi = note * 2.0 ** (-w), note * 2.0 ** w
        y = F.bp(src[start:start + frame] * win, max(lo, 150.0), min(hi, 12000.0), order=2)
        bw = min(hi, 12000.0) - max(lo, 150.0)
        y *= 1.0 / math.sqrt(max(bw, note * 0.04) / (note * 2.9))
        out[start:start + frame] += y
    x = out[:n] * shape(n, [(0.0, 1.0), (dur * 0.4, 0.8), (dur, 0.0)])
    d = drone([0], dur, 2, shape(n, [(0.0, 0.6), (dur, 0.1)])) * shape(n, [(0.0, 0.5), (dur, 0.0)])
    return F.lp(mix(x * 0.8, chorus(d) * 0.25), 9000.0) * gain


def tick(pitch=1.0, gain=1.0):
    """A bracket landing: a tiny dry knock, high."""
    return F.knock([3100.0 * pitch, 4700.0 * pitch], [0.0035, 0.0025], [1.0, 0.5], noise_gain=0.6) * gain


def work(dur, rate=SCRAMBLE, gain=1.0, jitter=0.35, fade=(0.55, 1.0), band=(1800.0, 5600.0), blips=0.25):
    """The display computing: ticks at the scramble's frame rate with jitter, each a few
    milliseconds of filtered noise, one in four a saw blip on E or B, thinning as the digits
    settle (from `fade[0]` of the way through to `fade[1]`)."""
    buf = np.zeros(n_of(dur) + n_of(0.04))
    t = 0.0
    while t < dur:
        d = F.RNG.uniform(0.003, 0.008)
        m = n_of(d)
        lo = F.RNG.uniform(band[0], band[1] * 0.6)
        hi = min(lo * F.RNG.uniform(1.4, 2.2), 11000.0)
        x = F.bp(F.noise(m), lo, hi) * F.env_ad(m, 0.0003, d * 0.5)
        if F.RNG.uniform() < blips:
            note = (E5, B5, E6)[int(F.RNG.integers(0, 3))]
            x = mix(x, drone([0], 0.007, 3, 0.9) * F.env_ad(n_of(0.007), 0.0005, 0.003) * 0.5 * (note / E5))
        p = t / dur
        g = 1.0 if p < fade[0] else max(0.0, 1.0 - (p - fade[0]) / max(fade[1] - fade[0], 1e-3))
        buf = at(buf, x, t, gain * g * F.RNG.uniform(0.55, 1.0))
        t += (1.0 / rate) * F.RNG.uniform(1.0 - jitter, 1.0 + jitter)
    return F.lp(buf, 11000.0)


def typing(dur=0.4, gain=1.0):
    """Text typing in: work at the log's rate, higher and quieter, no blips."""
    return work(dur, TYPING, gain, jitter=0.2, fade=(0.8, 1.0), band=(3000.0, 7000.0), blips=0.0)


def thump(weight=1.0, dull=False):
    """The weight a speaker can play: a knock falling through 560 to 320 Hz, saturated, a
    click on its front, dead in a tenth of a second. Not a sub."""
    k = F.body(560.0 if not dull else 420.0, 320.0 if not dull else 260.0, 0.09, drive=2.2, click=0.0 if dull else 0.5)
    sub = F.thud(120.0, 48.0, 0.18, click=0.0, drive=2.0, body_gain=0.0) * 0.35   # headphones only
    return mix(k, sub) * weight


def stab(semis, dur, octave=3, open_=(0.8, 0.12), hold=0.35, under=0.5):
    """Confirm's voice: the drone's saws on the notes, chorused, the filter closing over the
    note; an E two octaves under for headphones."""
    n = n_of(dur)
    o = closing(n, open_[0], open_[1])
    x = drone(semis, dur, octave, o)
    env = shape(n, [(0.0, 0.0), (0.006, 1.0), (dur * hold, 0.85), (dur, 0.0)])
    low = drone([0], dur, 1, 0.35) * env * under
    # The glint: the same saws with the filter wide open, high-passed, dying fast on the
    # front, so a confirm keeps an edge above the guitar's band on the speaker (measured:
    # the filtered saws alone put one percent of their power above 2 kHz).
    raw = np.zeros(n)
    for s_ in semis:
        raw += F.saws(hz(s_, octave), n, (0.994, 1.0, 1.006))
    glint = F.hp(raw / max(1, len(semis)), 1800.0) * F.env_ad(n, 0.004, dur * 0.18) * 0.9
    return chorus(mix(x * env, low, glint))


def confirm(weight="medium"):
    """Something committed. Small: a lock. Medium: a die spent. Large: RESOLVE and END TURN,
    three stepped notes E, B, E with the last held and closing (weapons online). Steps, not
    a glide."""
    if weight == "small":
        return mix(thump(0.45), stab([0, 7], 0.16, 3, (0.7, 0.1), hold=0.3) * 0.8)
    if weight == "medium":
        return mix(thump(0.85), stab([0, 7], 0.26, 3, (0.8, 0.1), hold=0.35))
    buf = thump(1.25)
    buf = at(buf, stab([0], 0.1, 2, (0.6, 0.4), hold=0.6, under=0.0) * 0.9, 0.0)
    buf = at(buf, stab([7], 0.1, 2, (0.7, 0.5), hold=0.6, under=0.0) * 0.95, 0.09)
    buf = at(buf, stab([0, 7, 12], 0.55, 3, (0.9, 0.08), hold=0.4), 0.18)
    buf = at(buf, thump(0.5), 0.18)
    return buf


def refuse():
    """No: the Phrygian second, F falling to E, both dull with the filter shut, a muted
    knock under, no chorus. The console's one dissonance."""
    a = drone([1], 0.1, 2, 0.1) * shape(n_of(0.1), [(0.0, 0.0), (0.005, 1.0), (0.08, 0.8), (0.1, 0.0)])
    b = drone([0], 0.16, 2, 0.06) * shape(n_of(0.16), [(0.0, 0.0), (0.005, 1.0), (0.1, 0.7), (0.16, 0.0)])
    buf = thump(0.6, dull=True)
    buf = at(buf, a, 0.0)
    buf = at(buf, b, 0.095)
    buf = at(buf, thump(0.3, dull=True), 0.095)
    return buf


def air(dur=0.25, down=True, gain=0.4):
    """Descent's menus: filtered air for a panel arriving (down) or leaving (up); a low-pass
    moving, nothing pitched."""
    n = n_of(dur)
    cut = np.geomspace(5000.0, 500.0, n) if down else np.geomspace(500.0, 5000.0, n)
    x = F.lp_var(F.hp(F.noise(n), 250.0), cut)
    return x * shape(n, [(0.0, 0.0), (dur * 0.2, 1.0), (dur * 0.7, 0.7), (dur, 0.0)]) * gain


# ---------------------------------------------------------------- the events
# Each is a recipe of verbs timed to the motion it twins. The display's own events carry no
# touch; the player's begin with one.

def e_touch():
    return touch(1.0)


def e_touch_heavy():
    return touch(1.7)


def e_select():      # a machine, a pack or a hex tapped on the map: brackets land on it
    buf = touch(1.0)
    buf = at(buf, converge(0.2, B5, 0.8), 0.0)
    return at(buf, tick(), 0.19)


def e_dismiss():     # the second tap, or the readout dismissed: the brackets let go
    buf = touch(0.8)
    return at(buf, release(0.18, B5), 0.0)


def e_die_lift():    # the slot goes clear, the ghost follows the finger, the targets light
    buf = touch(0.9)
    return at(buf, converge(0.22, E5, 0.75, under=0.3), 0.0)


def e_die_drop_back():   # dropped on nothing: the ghost vanishes, the die is back in its slot
    return release(0.16, E5, 0.9)


def e_die_lock():    # corners snap on, LOCKED under it
    buf = touch(1.0)
    buf = at(buf, tick(1.0, 0.9), 0.0)
    buf = at(buf, tick(0.85, 0.8), 0.03)
    return at(buf, confirm("small"), 0.03)


def e_die_unlock():
    buf = touch(0.9)
    return at(buf, release(0.14, B5, 0.7), 0.0)


def e_die_spend():   # a die spent on a foe: the die greys, the blow follows (the iron's)
    return confirm("medium")


def e_die_spend_self():   # on a machine: a shield, a vent, a buff; the gauges update
    buf = confirm("medium")
    return at(buf, air(0.22, down=False, gain=0.3), 0.08)


def e_reroll(dice=3):   # the press, the flips (0.22 s, a back-ease landing), each die landing
    buf = touch(1.1)
    buf = at(buf, work(0.22, 30.0, 0.9, fade=(0.7, 1.0)), 0.0)
    for k in range(dice):
        when = 0.21 + k * 0.045
        buf = at(buf, tick(1.0 - k * 0.08, 0.9), when)
        buf = at(buf, stab([0 if k % 2 == 0 else 7], 0.07, 3, (0.8, 0.3), hold=0.5, under=0.0) * 0.5, when)
    return buf


def e_round_acquire():   # the round opens: every foe's intent acquired at once, 0.3 s, the
    buf = work(0.165, SCRAMBLE, 0.8, fade=(0.7, 1.0))   # digits scrambling for the first 55%
    buf = at(buf, converge(0.3, B5, 1.3, start_width=2.2, under=0.5), 0.0)
    for k, p in enumerate((1.0, 0.92, 1.08)):   # the brackets land, one foe after another
        buf = at(buf, tick(p, 1.0), 0.29 + k * 0.012)
    return at(buf, stab([7, 12], 0.22, 3, (0.85, 0.1), hold=0.3, under=0.4) * 0.7, 0.3)


def e_end_turn():    # the primary press, weapons online, then the readout to ENEMY PHASE
    buf = touch(1.7)
    buf = at(buf, confirm("large"), 0.0)
    return at(buf, work(0.3, BOARD, 0.45), 0.72)


def e_resolve():     # the map's commit
    buf = touch(1.7)
    return at(buf, confirm("large"), 0.0)


def e_route_set():   # a hex tapped: the orders board's line scrambles 0.45 s, then a tick
    buf = touch(1.0)
    buf = at(buf, work(0.45, BOARD, 0.75), 0.0)
    buf = at(buf, tick(), 0.45)
    return at(buf, stab([0], 0.09, 3, (0.7, 0.2), hold=0.4, under=0.0) * 0.5, 0.45)


def e_route_clear():
    buf = touch(0.9)
    return at(buf, release(0.2, E5, 0.8), 0.0)


def e_hold_readout():   # the finger is already down; at 0.45 s the panel opens above the thing
    buf = converge(0.2, B5, 0.6, under=0.25)
    return at(buf, tick(1.0, 0.7), 0.19)


def e_codex_open():   # the shade, the plate acquired, its text typing in
    buf = touch(1.0)
    buf = at(buf, air(0.2, down=True, gain=0.35), 0.0)
    buf = at(buf, converge(0.3, B5, 0.9), 0.05)
    buf = at(buf, tick(), 0.34)
    return at(buf, typing(0.45, 0.6), 0.36)


def e_codex_close():
    buf = touch(0.8)
    buf = at(buf, release(0.18, B5, 0.8), 0.0)
    return at(buf, air(0.2, down=False, gain=0.3), 0.02)


def e_menu_open():    # MENU: the scrim, PAUSED
    buf = touch(1.5)
    buf = at(buf, air(0.3, down=True, gain=0.45), 0.0)
    return at(buf, confirm("small"), 0.1)


def e_menu_close():
    buf = touch(1.0)
    return at(buf, air(0.25, down=False, gain=0.4), 0.0)


def e_refuse():      # NO ROUTE, a drop on nothing valid, a disabled press
    return refuse()


def e_log_type():    # a log line typing in; on every event, so quiet, and optional
    return typing(0.4, 0.5)


def e_track_runin():   # the ticker's new title running in over 0.55 s
    buf = work(0.55, BOARD, 0.5, fade=(0.5, 1.0), band=(2500.0, 6000.0), blips=0.15)
    return at(buf, tick(1.0, 0.6), 0.55)


def verb_acquire():
    return at(converge(0.3, B5, 1.0), tick(), 0.29)


# name: (recipe, target dB as the phone plays it, the shipped sound it would replace, the row's note)
CONSOLE = {
    # the five verbs alone
    "verb_touch": ((lambda: touch(1.0)), -24.0, None, "touch"),
    "verb_acquire": (verb_acquire, -16.0, None, "acquire: static narrowing onto B over a third of a second, the brackets landing"),
    "verb_work": ((lambda: work(0.45)), -18.0, None, "work: the scramble's ticks, thinning as the digits settle"),
    "verb_confirm_small": ((lambda: confirm("small")), -16.0, None, "confirm, small"),
    "verb_confirm_medium": ((lambda: confirm("medium")), -14.0, None, "confirm, medium"),
    "verb_confirm_large": ((lambda: confirm("large")), -11.0, None, "confirm, large: E, B, E, weapons online"),
    "verb_refuse": (refuse, -15.0, None, "refuse: F to E, dull"),
    # the events
    "touch": (e_touch, -24.0, "ui_tap", "the finger on the glass; every ordinary press: the eye, clear routes, log, a swatch"),
    "touch_heavy": (e_touch_heavy, -21.0, "ui_tap", "a primary press, before its confirm"),
    "select": (e_select, -17.0, "ui_tap", "a machine, a pack or a hex tapped on the map: the brackets land"),
    "dismiss": (e_dismiss, -21.0, "ui_back", "the second tap or the readout dismissed: the brackets let go"),
    "die_lift": (e_die_lift, -17.0, "die_pick", "the die lifted: the slot clears, the targets light"),
    "die_drop_back": (e_die_drop_back, -21.0, "die_drop", "dropped on nothing: the ghost vanishes"),
    "die_lock": (e_die_lock, -16.0, "die_lock", "tap to lock: the corners snap on"),
    "die_unlock": (e_die_unlock, -20.0, "die_lock", "the lock let go"),
    "die_spend": (e_die_spend, -14.0, "die_drop", "a die spent on a foe; the blow follows"),
    "die_spend_self": (e_die_spend_self, -14.0, "die_drop", "a die spent on a machine: shield, vent, buff"),
    "reroll": (e_reroll, -16.0, "die_roll", "the press, the flips, each die landing"),
    "round_acquire": (e_round_acquire, -12.0, None, "the round opens: every intent acquired at once; the display's own, no touch"),
    "end_turn": (e_end_turn, -11.0, "resolve", "weapons online, then the readout to ENEMY PHASE"),
    "resolve": (e_resolve, -11.0, "resolve", "the map's commit"),
    "route_set": (e_route_set, -16.0, "plot", "a hex tapped: the orders board's line scrambles and settles"),
    "route_clear": (e_route_clear, -20.0, "ui_back", "the selected machine tapped again"),
    "hold_readout": (e_hold_readout, -19.0, None, "at 0.45 s of a hold the panel opens; no touch, the finger is down"),
    "codex_open": (e_codex_open, -15.0, "codex_open", "the shade, the plate acquired, its text typing"),
    "codex_close": (e_codex_close, -18.0, "codex_close", ""),
    "menu_open": (e_menu_open, -14.0, "menu_open", "MENU: the scrim comes down"),
    "menu_close": (e_menu_close, -17.0, "menu_open", ""),
    "refuse": (e_refuse, -15.0, "ui_back", "NO ROUTE; a drop on nothing valid; a disabled press (no hook yet)"),
    "log_type": (e_log_type, -27.0, None, "a log line typing; on every event, so quiet; optional"),
    "track_runin": (e_track_runin, -25.0, None, "a new title running into the ticker; optional"),
}


# ---------------------------------------------------------------- levels and writing

def phone_loudness(x):
    return F.loudness(phone_model(x))


def level_for_phone(x, db):
    """Scale so the phone model's loudest 50 ms sits at `db`: a sound heavy in the lows is
    written hotter rather than vanishing on the speaker."""
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
MAP = [   # the map: select, routes, a refusal, the commit, the moves, the menu, over Night Shift
    (0.4, "select", "ui_tap", 0.0), (1.0, "route_set", "plot", 0.0),
    (1.9, "select", "ui_tap", 0.0), (2.6, "route_set", "plot", 0.0),
    (3.5, "refuse", "ui_back", 0.0), (4.1, "route_set", "plot", 0.0),
    (5.0, "touch", "ui_tap", 0.0), (5.8, "resolve", "resolve", 0.0),
    (6.6, None, "step", 0.0), (6.95, None, "step", 0.0), (7.3, None, "step", 0.0), (7.65, None, "step", 0.0),
    (8.6, "menu_open", "menu_open", 0.0), (9.9, "menu_close", "ui_back", 0.0),
    (10.6, "codex_open", "codex_open", 0.0), (12.0, "codex_close", "codex_close", 0.0),
]


def lay(base, events, which):
    buf = np.array(base)
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
    """Hold The Line's first climax bar (S), in 4/4 bars from the top: the form before it is
    sixteen-step bars except the twelve bars of seven (fourteen steps)."""
    form = F.MUSIC["music_hold_the_line"]["form"].replace(" ", "")
    before = form[:form.index("S")]
    steps = sum(14 if c == "X" else 16 for c in before)
    return steps / 16.0


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
        print("  con_%-16s %5.2f s  phone %6.1f  full %6.1f  (%+.1f)" % (name, len(x) / SR, db, full, full - db))
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
