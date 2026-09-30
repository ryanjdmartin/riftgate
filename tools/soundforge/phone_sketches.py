"""Sketches for the phone (Ryan, 26 September: on the phone's speaker the low end is hard to
hear and the driven bass in Hold The Line is harsh and tinny).

Two sets, rendered from Hold The Line's own opening with one thing changed at a time, so
each file is an A/B against the first of its set; never written over a shipped track.

  voices    the driven bass, five ways: as shipped; through a bass cabinet; cabinet and two
            stages of asymmetric saturation with no hard clip; that split into a clean low
            string under a driven upper one; and the split with the drive following the
            note's own envelope and a little per-note variation. Each in the riff, and all
            five alone in one file, four bars each.
  balance   the mix for a phone speaker, one step at a time: as shipped; shadows the speaker
            can play under the kick, the toms and the sub (a knock at 200 Hz and a band of
            harmonics 150 to 600 Hz); the sub cut (below 45 Hz gone, below 80 Hz -6 dB);
            a gentler master tilt with a narrow presence lift at 1 to 2 kHz; all three.
            And the levelling gap: Hold The Line then The Far Bank, first at the shipped
            levels, then levelled by what a phone speaker plays (a model: high-passed at
            220 Hz twice, a presence bump, rolled off at 9 kHz).

    tools/spriter/.venv/bin/python tools/soundforge/phone_sketches.py [voices|balance|levels|voices2|guitar|shadows2|rift|round3|round4|round5|round6|round7|round8]

Second round (28 September, from Ryan's notes on the first): voices2 (two hybrids of voice 2
and the split, and the other bass voices the tracks use), guitar (the backing guitar without
its hard clip), shadows2 (the kick's shadow without the pitch sweep, a gentler sub, a softer
crash), rift (The Far Bank as shipped and on the human master), and a half-gap level file.
The tilt was decided the same day and the human builders carry it, so every file renders on
that master except where a row says "old master".

Third round (28 September, later): Ryan's picks landed in the forge itself (voice 12 as
bass_real, the clip-free guitar as guitar_real's driven branch, the metal kick, the tightened
tom, the softer crash, the sub's shadow, the rift levels up a quarter of their gap). So a
"shipped" row rendered after that carries the new voices, and the first two rounds' files
are history: re-render only to compare against what ships now.

Writes WAVs and AAC (afconvert, macOS) into tools/soundforge/out/phone/ with a manifest,
and copies the listening page (phone_page.html, committed beside this file) in beside them
as index.html. The page is the thing to edit; out/phone/ is git-ignored scratch, so a new
session renders the sets it wants and publishes out/phone/index.html with the .mp4 files
and manifest.json as its `files`.
"""
import json
import math
import os
import subprocess
import sys
import wave

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402

OUT = os.path.join(F.OUT_SKETCH, "phone")
SKIRMISH_LEVEL = F.LEVELS["music_hold_the_line"]
VOICE_FORM = "AAAAAAAAAAAAAAAA B NNNN"            # the riff (bass from bar 5), the turn, the riff on power chords
BALANCE_FORM = "AAAAAAAAAAAAAAAA B CCCCCCCC"      # ... and the lift: the sub, and the tom fill closing it
FAR_BANK_FORM = "PPPPPPPP AAAAAAAB CCCCCCCB"      # the groove bare, the groove, the lift


# ---------------------------------------------------------------- the phone model

def phone_model(x):
    """What a phone speaker plays of a signal: nothing under about 200 Hz, a presence bump,
    little above 9 kHz. For levelling and measurement, never for listening."""
    y = F.hp(F.hp(x, 220.0), 220.0)
    y = y + F.bp(y, 900.0, 2500.0) * 0.4
    return F.lp(y, 9000.0)


def phone_level(x):
    return F.mean_level(phone_model(x))


# ---------------------------------------------------------------- bass voices

def bass_cabinet(x, jitter=1.0):
    """A bass cabinet: a few resonant peaks (a 4x10's), closed steeply above 4 kHz."""
    y = np.zeros(len(x))
    for f, g in ((100.0, 1.0), (250.0, 0.9), (700.0, 0.7), (1600.0, 0.45)):
        f *= jitter
        y += F.bp(x, f * 0.75, f * 1.3) * g
    return F.lp(F.lp(y / 2.0 + x * 0.2, 4000.0), 4000.0)


def asat(x, drive, bias=0.25):
    """Asymmetric soft saturation: tanh with a bias, so even harmonics appear (the tube's
    warmth a symmetric clip never has); the DC it makes is removed."""
    y = np.tanh(x * drive + bias) - math.tanh(bias)
    y /= (math.tanh(drive + bias) - math.tanh(bias))
    return y - F.lp(y, 15.0)


def string_and_thump(f, dur, bright=0.5):
    n = F.n_of(dur)
    x = F.pluck(f, dur, bright=bright, damp=0.998)[:n] + F.pluck(f * 1.001, dur, bright=bright * 0.6, damp=0.998)[:n] * 0.5
    x = x + F.bp(x, 80.0, 140.0) * 0.8
    thump = F.lp(F.noise(F.n_of(0.02)), 900.0) * F.env_ad(F.n_of(0.02), 0.0005, 0.006) * 0.5
    return F.at(x, thump, 0.0)[:n]


def bass_shipped(f, dur, drive=2.6):
    return F.bass_real(f, dur, drive)


def bass_cab(f, dur, drive=2.6):
    # The shipped chain (tanh, then the hard clip, then the growl) into a cabinet instead of
    # the flat low-pass at 2.2 kHz.
    x = string_and_thump(f, dur)
    x = np.clip(F.sat(x * drive, drive) * (1.0 + 0.15 * drive), -1.0, 1.0)
    x = x + F.bp(x, 200.0, 500.0) * 0.5
    return F.hp(bass_cabinet(x), 40.0) * 0.85


def drive_stages(x, drive):
    """Pre-emphasis, a hot asymmetric stage, a tone control, a gentler second stage."""
    pre = F.hp(x, 300.0) * 1.2 + x * 0.5
    y = asat(pre * drive, 1.6)
    y = F.lp(y, 1500.0) + F.bp(y, 500.0, 900.0) * 0.4
    return asat(y * 1.4, 1.2)


def bass_stage(f, dur, drive=2.6):
    x = string_and_thump(f, dur)
    return F.hp(bass_cabinet(drive_stages(x, drive)), 40.0) * 0.9


def bass_split(f, dur, drive=2.6, jitter=1.0, bright=0.5):
    # The bass recording's trick: the string under 250 Hz kept clean for pitch and body, the
    # part above driven through the stages and the cabinet, blended.
    x = string_and_thump(f, dur, bright)
    clean = F.sat(F.lp(x, 250.0), 1.3) * 0.9
    driven = bass_cabinet(drive_stages(F.hp(x, 250.0), drive), jitter) * 0.75
    return F.hp(clean + driven, 40.0) * 0.95


def bass_dyn(f, dur, drive=2.6):
    # The split, with the drive following the note: hot at the front, cleaning up as the
    # string decays, as an amp compresses; and the string's brightness and the cabinet's
    # peaks a hair different every note, so no two notes share a waveform.
    bright = F.RNG.uniform(0.4, 0.62)
    jitter = F.RNG.uniform(0.95, 1.05)
    x = string_and_thump(f, dur, bright)
    env = F.lp(np.abs(x), 25.0)
    env = np.clip(env / (np.max(env) + 1e-9), 0.0, 1.0)
    d = drive * (0.35 + 0.65 * env ** 0.6)
    upper = F.hp(x, 250.0)
    pre = F.hp(upper, 300.0) * 1.2 + upper * 0.5
    y = np.tanh(pre * d * 1.6 + 0.25) - math.tanh(0.25)
    y = y - F.lp(y, 15.0)
    y = F.lp(y, 1500.0) + F.bp(y, 500.0, 900.0) * 0.4
    y = asat(y * 1.4, 1.2)
    fret = F.bp(F.noise(F.n_of(0.015)), 1500.0, 4000.0) * F.env_ad(F.n_of(0.015), 0.0003, 0.004) * F.RNG.uniform(0.05, 0.2)
    driven = bass_cabinet(F.at(y, fret, 0.0)[: len(y)], jitter) * 0.75
    clean = F.sat(F.lp(x, 250.0), 1.3) * 0.9
    return F.hp(clean + driven, 40.0) * 0.95


BASS_VOICES = [
    ("shipped", bass_shipped, "as shipped: tanh, a hard clip, a growl band, a flat low-pass at 2.2 kHz"),
    ("cab", bass_cab, "the same chain into a bass cabinet (peaks at 100, 250, 700, 1600 Hz; closed above 4 kHz)"),
    ("stage", bass_stage, "cabinet, and two stages of asymmetric saturation with a tone control between; no hard clip"),
    ("split", bass_split, "the string under 250 Hz kept clean, only the part above driven; cabinet on the driven part"),
    ("dyn", bass_dyn, "the split, the drive following the note's own envelope, brightness and cabinet a hair different per note"),
]


# Second round (Ryan, 28 September: voice 2's sound liked most, but Duke Nukem in the power
# chords; 4 and 5 too alike to tell). Two hybrids keep voice 2's clip and cabinet and take the
# split from 4, so the clipped part is only the string above 250 Hz; the low string stays clean
# under the chord, which is where the chip-tune fifths came from.

def bass_cabsplit(f, dur, drive=2.6):
    x = string_and_thump(f, dur)
    clean = F.sat(F.lp(x, 250.0), 1.3) * 0.9
    hi = F.hp(x, 250.0)
    hi = np.clip(F.sat(hi * drive, drive) * (1.0 + 0.15 * drive), -1.0, 1.0)
    hi = hi + F.bp(hi, 200.0, 500.0) * 0.5
    return F.hp(clean + bass_cabinet(hi) * 0.8, 40.0) * 0.9


def bass_cabdyn(f, dur, drive=2.6):
    # The hybrid, with the clip's drive following the note, so the buzz on a held note thins
    # as the string decays.
    x = string_and_thump(f, dur, F.RNG.uniform(0.42, 0.58))
    env = F.lp(np.abs(x), 25.0)
    env = np.clip(env / (np.max(env) + 1e-9), 0.0, 1.0)
    d = drive * (0.45 + 0.55 * env ** 0.6)
    clean = F.sat(F.lp(x, 250.0), 1.3) * 0.9
    hi = F.hp(x, 250.0)
    hi = np.clip(np.tanh(hi * d) / np.tanh(d) * (1.0 + 0.15 * d), -1.0, 1.0)
    hi = hi + F.bp(hi, 200.0, 500.0) * 0.5
    return F.hp(clean + bass_cabinet(hi, F.RNG.uniform(0.96, 1.04)) * 0.8, 40.0) * 0.9


BASS_VOICES_2 = [
    ("cabsplit", bass_cabsplit, "voice 2's clip and cabinet on the string above 250 Hz only; the low string clean under it"),
    ("cabdyn", bass_cabdyn, "the same, the clip's drive following the note, so a held note's buzz thins as it decays"),
]
# The other bass voices the tracks already use, in the riff: the soft sub (the lift's and the
# keys'), the crunch synth (the second lift's), the clean bass (Full Bore's melody voice) and,
# for the record, the rift's contrabass.
OTHER_VOICES = [
    ("sub", "sub_bass", "the soft sub: a sine with a little saw, soft-edged; the lift's and the keys' bass"),
    ("crunch", "bass", "the crunch synth: a saw with a shadow, driven and clipped, one fixed low-pass; the second lift's bass"),
    ("cleanbass", "bass_clean", "the clean bass: the string with its harmonics open and no drive; Full Bore's melody voice"),
    ("contra", "contrabass_real", "the rift's bowed contrabass, out of its world"),
]
for _name, _fn, _ in BASS_VOICES + BASS_VOICES_2:
    F.NOTE_INST["bass_" + _name] = (lambda fn: (lambda f, d, p: fn(f, d, p.get("drive", 2.6))))(_fn)
for _name, _inst, _ in OTHER_VOICES:
    # Bound to the forge's own function now, under a name of its own (a key that shadowed
    # the forge's "bass_clean" called itself).
    F.NOTE_INST["bass_" + _name] = (lambda fn: (lambda f, d, p: fn(f, d, {})))(F.NOTE_INST[_inst])


def guitar_soft(f, dur, mute=True, clean=False):
    # The backing guitar without its hard clip (Ryan, 28 September: liked as garbage cans,
    # maybe too clippy): the same strings and pick scrape, then two asymmetric stages with a
    # tone control between, and the guitar cabinet. The palm mute and the body knock as shipped.
    n = F.n_of(dur)
    x = np.zeros(n)
    for ratio, g in ((1.0, 1.0), (1.5, 0.7), (2.0, 0.5)):
        x += F.pluck(f * ratio * F.RNG.uniform(0.998, 1.002), dur, bright=F.RNG.uniform(0.4, 0.6), damp=0.993)[:n] * g
    scrape = F.bp(F.noise(F.n_of(0.012)), 2000.0, 7000.0) * F.env_ad(F.n_of(0.012), 0.0002, 0.003) * 0.6
    x = F.at(x, scrape, 0.0)[:n]
    y = asat(F.hp(x, 600.0) * 3.5 + x * 1.2, 1.6)
    y = F.lp(y, 3000.0) + F.bp(y, 700.0, 1400.0) * 0.3
    y = F.cabinet(asat(y * 1.3, 1.2)) * 1.1
    env = F.env_ad(n, 0.001, min(0.16, dur * 0.5), curve=3.0) if mute else F.env_ad(n, 0.001, dur * 0.7, curve=2.0)
    return F.mix(y * env, F.body(200.0, 90.0, 0.05, drive=2.0, click=0.2) * 0.3)


def _rms(x):
    return math.sqrt(float(np.mean(x ** 2)) + 1e-12)


def _match_guitar():
    # The soft guitar read as louder (Ryan, 28 September), so it is level-matched to the shipped
    # one on a palm-muted low E before it goes into the mix.
    F.seed("match_guitar")
    a = F.guitar_real(82.41, 0.3)
    F.seed("match_guitar")
    b = guitar_soft(82.41, 0.3)
    return _rms(a) / _rms(b)


GUITAR_MATCH = _match_guitar()
F.NOTE_INST["guitar_soft"] = lambda f, d, p: guitar_soft(f, d, p.get("mute", True), p.get("clean", False)) * GUITAR_MATCH


# ---------------------------------------------------------------- round three (Ryan, 28 September, second notes)

def bass_stagedyn(f, dur, drive=2.6):
    # Voice 3 with the drive following the note (the whole string driven, no split).
    x = string_and_thump(f, dur, F.RNG.uniform(0.42, 0.58))
    env = F.lp(np.abs(x), 25.0)
    env = np.clip(env / (np.max(env) + 1e-9), 0.0, 1.0)
    d = drive * (0.35 + 0.65 * env ** 0.6)
    pre = F.hp(x, 300.0) * 1.2 + x * 0.5
    y = np.tanh(pre * d * 1.6 + 0.25) - math.tanh(0.25)
    y = y - F.lp(y, 15.0)
    y = F.lp(y, 1500.0) + F.bp(y, 500.0, 900.0) * 0.4
    y = asat(y * 1.4, 1.2)
    return F.hp(bass_cabinet(y), 40.0) * 0.9


def bass_splitbright(f, dur, drive=2.6):
    # Voice 5 with its driven part brought up to voice 3's weight, the clean low a little down.
    bright = F.RNG.uniform(0.4, 0.62)
    jitter = F.RNG.uniform(0.95, 1.05)
    x = string_and_thump(f, dur, bright)
    env = F.lp(np.abs(x), 25.0)
    env = np.clip(env / (np.max(env) + 1e-9), 0.0, 1.0)
    d = drive * (0.35 + 0.65 * env ** 0.6)
    upper = F.hp(x, 250.0)
    pre = F.hp(upper, 300.0) * 1.2 + upper * 0.5
    y = np.tanh(pre * d * 1.6 + 0.25) - math.tanh(0.25)
    y = y - F.lp(y, 15.0)
    y = F.lp(y, 1500.0) + F.bp(y, 500.0, 900.0) * 0.4
    y = asat(y * 1.4, 1.2)
    driven = bass_cabinet(y, jitter) * 1.05
    clean = F.sat(F.lp(x, 250.0), 1.3) * 0.8
    return F.hp(clean + driven, 40.0) * 0.9


BASS_VOICES_3 = [
    ("stagedyn", bass_stagedyn, "voice 3 with the drive following the note"),
    ("splitbright", bass_splitbright, "voice 5 with its driven part brought up to voice 3's weight"),
]
for _name, _fn, _ in BASS_VOICES_3:
    F.NOTE_INST["bass_" + _name] = (lambda fn: (lambda f, d, p: fn(f, d, p.get("drive", 2.6))))(_fn)


def kick_metal3(pitch=1.0):
    # A metal kick rather than a club one (Ryan: a hit followed by mush, a floor tom): the
    # skin's fall quicker and shorter, more beater, a short static knock at 190 Hz for the
    # speaker in place of the sweep and the harmonics band, and less room.
    n = F.n_of(0.3)
    t = F.t_of(n)
    f = (55.0 + 70.0 * np.exp(-t / 0.028)) * pitch
    skin = np.sin(2.0 * math.pi * np.cumsum(f) / F.SR) * F.env_ad(n, 0.001, 0.075, curve=3.0)
    beater = F.bp(F.noise(F.n_of(0.006)), 2500.0, 7000.0) * F.env_ad(F.n_of(0.006), 0.0002, 0.0015) * 1.1
    knock = F.harmonics(190.0 * pitch, n, [1.0, 0.3]) * F.env_ad(n, 0.0008, 0.03, curve=3.0) * 0.5
    shell = F.harmonics(180.0 * pitch, n, [0.5, 0.3, 0.15]) * F.env_ad(n, 0.001, 0.02) * 0.4
    x = F.mix(F.sat(skin, 1.6), F.at(np.zeros(1), beater, 0.0), shell, knock)
    return F.room(x, decay=0.06, mix=0.08, cut=3000.0)


def tom_v2(f=150.0, pitch=1.0):
    # The tom pitched lower and duller (Ryan: pew-pew on the speaker, too high or too bright):
    # a smaller pitch fall, a lower shell, the stick low-passed, and its shadow at 120 to 500 Hz.
    n = F.n_of(0.5)
    t = F.t_of(n)
    fr = f * pitch * (1.0 + 0.18 * np.exp(-t / 0.05))
    skin = np.sin(2.0 * math.pi * np.cumsum(fr) / F.SR) * F.env_ad(n, 0.001, 0.15, curve=2.5)
    sub = np.sin(2.0 * math.pi * f * pitch * 0.5 * t) * F.env_ad(n, 0.002, 0.12) * 0.5
    shell = F.harmonics(f * pitch * 1.4, n, [0.5, 0.25, 0.1]) * F.env_ad(n, 0.001, 0.035) * 0.3
    stick = F.lp(F.bp(F.noise(F.n_of(0.01)), 1200.0, 5000.0), 4000.0) * F.env_ad(F.n_of(0.01), 0.0002, 0.003) * 1.1
    front = F.body(f * pitch * 1.6, f * pitch, 0.04, drive=2.0, click=0.5) * 0.8
    shadow = F.bp(F.sat(skin + sub, 3.0), 120.0, 500.0) * 0.35
    return F.room(F.mix(F.sat(skin + sub, 1.6), shell, front, F.at(np.zeros(1), stick, 0.0), shadow), decay=0.09, mix=0.1, cut=4000.0) * 1.1


def drums_clip(patches):
    """Four bars of the riff's drums alone (the kick's pattern, the snare, hats, a crash at the
    top and the tom fill that closes the lift in the last bar), with the kit as patched."""
    with Patched(**patches):
        kit = {"kick": (F.variants(F.kick_real), 1.0), "snare": (F.variants(F.snare_real), 1.0),
               "hat": (F.variants(lambda p: F.hat_real(False, p)), 0.45), "crash": ([F.crash_real()], 0.9),
               "tom": (F.variants(lambda p: F.tom_real(150.0, p)), 0.9), "tom2": (F.variants(lambda p: F.tom_real(105.0, p)), 0.9)}
        drums = {"kick": {"A": "x.xx.x."}, "snare": {"A": "....x.......x..."}, "hat": {"A": "x.x.x.x.x.x.x.x."},
                 "crash": {"A": "x" + "." * 63}, "tom": {"A": "." * 48 + "....x.x.xx.x.x.."}, "tom2": {"A": "." * 48 + "......x.....x.xx"}}
        F.seed("phone_drums")
        return F.groove(bpm=100, form="AAAA", kit=kit, drums=drums, chords={"*": [[0, 7, 12]]}, voices=[], tilt=1.5, presence=0.25, low=(150.0, -6.0), human=(0.005, 0.15))


# ---------------------------------------------------------------- shadows for the speaker

_KICK, _TOM, _SUB = F.kick_real, F.tom_real, F.sub_bass   # the shipped voices, kept while the module's names are swapped


def kick_shadow(pitch=1.0):
    k = _KICK(pitch)
    knock = F.body(230.0 * pitch, 120.0 * pitch, 0.07, drive=2.2, click=0.35) * 0.55
    harm = F.bp(F.sat(k, 3.0), 150.0, 600.0) * 0.35
    return F.mix(k, knock, harm)


def tom_shadow(f=150.0, pitch=1.0):
    t = _TOM(f, pitch)
    return F.mix(t, F.bp(F.sat(t, 3.0), 200.0, 800.0) * 0.4)


def sub_shadow(f, dur, res=0.0, punch=0.0, fade=0.0):
    s = _SUB(f, dur, res, punch, fade)
    return s + F.bp(F.sat(s * 2.0, 3.0), 150.0, 600.0) * 0.35


# Second cut (Ryan, 28 September: in headphones the shadowed kick went "pew-pew", the sub a
# little digital, the toms different but fine): the kick's shadow without the pitch sweep (a
# static 200 Hz burst and the harmonics only), the sub's gentler and lower, and a softer
# crash, since the shipped ones read as clipped and hissy on the speaker.

def kick_shadow2(pitch=1.0):
    k = _KICK(pitch)
    n = len(k)
    burst = F.harmonics(200.0 * pitch, n, [1.0, 0.35]) * F.env_ad(n, 0.001, 0.045, curve=3.0) * 0.4
    harm = F.bp(F.sat(k, 3.0), 150.0, 600.0) * 0.4
    return F.mix(k, burst, harm)


def sub_shadow2(f, dur, res=0.0, punch=0.0, fade=0.0):
    s = _SUB(f, dur, res, punch, fade)
    return s + F.lp(F.bp(F.sat(s * 2.0, 2.5), 150.0, 400.0), 500.0) * 0.22


_CRASH = F.crash_real


def crash_soft():
    n = F.n_of(1.0)
    wash = F.bp(F.noise(n), 1800.0, 9000.0) * F.env_ad(n, 0.003, 0.24, curve=2.0) * 0.75
    plate = F.knock([2900.0, 4300.0, 6400.0, 8100.0], [0.3, 0.22, 0.17, 0.14], [0.4, 0.3, 0.25, 0.2], noise_gain=0.0) * 0.45
    return F.sat(F.mix(wash, plate), 1.3) * 0.35


SHADOWS_2 = dict(kick_real=kick_shadow2, tom_real=tom_shadow, sub_bass=sub_shadow2, crash_real=crash_soft)
SHADOWS_3 = dict(kick_real=kick_metal3, tom_real=tom_v2, sub_bass=sub_shadow2, crash_real=crash_soft)


def sub_cut(x):
    return F.low_shelf(F.hp(F.hp(x, 45.0), 45.0), 80.0, -6.0)


def presence(x):
    return x + F.bp(x, 1000.0, 2200.0) * 0.25



# ---------------------------------------------------------------- round four (the shipped build)
# Ryan's picks are in the forge now, so a plain render is what ships. These are the two notes
# left open (28 September): the kick's own size, which sounded high alone, and the toms, still
# soft and echoey in headphones. Each variant is a step further in the direction he asked for,
# so he can say "that one" or "further" rather than describing a pitch.

def kick_at(mult):
    """The shipped kick, pitched by `mult` (lower is a bigger drum). Calls the voice saved
    above, never the module name, which is the one being patched."""
    return lambda pitch=1.0: _KICK(pitch * mult)


def tom_at(skin, room, front):
    """The shipped tom with its skin's decay, its room and its front's hit scaled."""
    def voice(f=150.0, pitch=1.0):
        n = F.n_of(0.45)
        t = F.t_of(n)
        fr = f * pitch * (1.0 + 0.18 * F.np.exp(-t / 0.05))
        sk = F.np.sin(2.0 * F.math.pi * F.np.cumsum(fr) / F.SR) * F.env_ad(n, 0.001, 0.11 * skin, curve=2.5)
        sub = F.np.sin(2.0 * F.math.pi * f * pitch * 0.5 * t) * F.env_ad(n, 0.002, 0.09 * skin) * 0.5
        shell = F.harmonics(f * pitch * 1.4, n, [0.5, 0.25, 0.1]) * F.env_ad(n, 0.001, 0.03) * 0.3
        stick = F.lp(F.bp(F.noise(F.n_of(0.01)), 1500.0, 6000.0), 5000.0) * F.env_ad(F.n_of(0.01), 0.0002, 0.003) * 1.6
        hit = F.body(f * pitch * 1.6, f * pitch, 0.04, drive=2.4, click=0.7) * front
        shadow = F.bp(F.sat(sk + sub, 3.0), 120.0, 500.0) * 0.35
        return F.room(F.mix(F.sat(sk + sub, 1.6), shell, hit, F.at(F.np.zeros(1), stick, 0.0), shadow),
                      decay=0.05 * room, mix=0.06 * room, cut=4500.0) * 1.1
    return voice


KICK_SIZES = [("as ships", {}), ("lower", dict(kick_real=kick_at(0.9))), ("lowest", dict(kick_real=kick_at(0.82)))]
TOM_TIGHTS = [("as ships", {}), ("tighter", dict(tom_real=tom_at(0.75, 0.6, 1.15))), ("tightest", dict(tom_real=tom_at(0.55, 0.3, 1.3)))]



# ---------------------------------------------------------------- round six (Ryan, 29 September, on round four)
# The kick: the middle size in the track, and the old kick (the one before the metal cut) in
# the track, since "the original kick was better than I thought" could mean either. The toms:
# not the voice but the playing ("the drummer is grooving instead of beating; hit it like you
# mean it"), so the voice hits harder (more saturation in the body, a harder front and stick,
# the body kept rather than tightened, which read as hollow) and the kit plays it louder.

def kick_old(pitch=1.0):
    n = F.n_of(0.45)
    t = F.t_of(n)
    f = (50.0 + 80.0 * F.np.exp(-t / 0.05)) * pitch
    skin = F.np.sin(2.0 * F.math.pi * F.np.cumsum(f) / F.SR) * F.env_ad(n, 0.001, 0.14, curve=3.0)
    beater = F.bp(F.noise(F.n_of(0.006)), 2000.0, 6000.0) * F.env_ad(F.n_of(0.006), 0.0002, 0.0015) * 0.9
    shell = F.harmonics(180.0 * pitch, n, [0.5, 0.3, 0.15]) * F.env_ad(n, 0.001, 0.02) * 0.4
    return F.room(F.mix(F.sat(skin, 1.6), F.at(F.np.zeros(1), beater, 0.0), shell), decay=0.12, mix=0.12, cut=3000.0)


def tom_power(skin, drive, front, stick, room_decay, room_mix):
    def voice(f=150.0, pitch=1.0):
        n = F.n_of(0.5)
        t = F.t_of(n)
        fr = f * pitch * (1.0 + 0.18 * F.np.exp(-t / 0.05))
        sk = F.np.sin(2.0 * F.math.pi * F.np.cumsum(fr) / F.SR) * F.env_ad(n, 0.001, skin, curve=2.5)
        sub = F.np.sin(2.0 * F.math.pi * f * pitch * 0.5 * t) * F.env_ad(n, 0.002, skin * 0.8) * 0.5
        shell = F.harmonics(f * pitch * 1.4, n, [0.5, 0.25, 0.1]) * F.env_ad(n, 0.001, 0.03) * 0.3
        st = F.lp(F.bp(F.noise(F.n_of(0.01)), 1500.0, 6000.0), 5000.0) * F.env_ad(F.n_of(0.01), 0.0002, 0.003) * stick
        hit = F.body(f * pitch * 1.6, f * pitch, 0.04, drive=2.6, click=0.8) * front
        shadow = F.bp(F.sat(sk + sub, 3.0), 120.0, 500.0) * 0.35
        return F.room(F.mix(F.sat(sk + sub, drive), shell, hit, F.at(F.np.zeros(1), st, 0.0), shadow),
                      decay=room_decay, mix=room_mix, cut=4500.0) * 1.1
    return voice


TOM_POWER = [
    ("as ships", {}, 1.0),
    ("power one", dict(tom_real=tom_power(0.13, 2.2, 1.3, 1.8, 0.06, 0.07)), 1.4),
    ("power two", dict(tom_real=tom_power(0.15, 2.6, 1.5, 2.0, 0.08, 0.09)), 1.8),
]


def groove_kit_gain(part_mult):
    """A groove wrapper that scales named kit parts' gains: {"tom": 1.4} plays the toms harder."""
    orig = F.groove

    def g(*a, **kw):
        kit = dict(kw["kit"])
        for name, mult in part_mult.items():
            if name in kit:
                entry = kit[name]
                kit[name] = (entry[0], entry[1] * mult) + tuple(entry[2:])
        kw["kit"] = kit
        return orig(*a, **kw)
    return g


def render_hold_kit(form, patches, part_mult):
    saved = with_form("music_hold_the_line", form)
    try:
        F.seed("music_hold_the_line")
        with Patched(groove=groove_kit_gain(part_mult), **patches):
            x = F.music_hold_the_line()
    finally:
        F.MUSIC["music_hold_the_line"]["form"] = saved
    return x


def drums_clip_kit(patches, part_mult):
    with Patched(groove=groove_kit_gain(part_mult)):
        return drums_clip(patches)



# ---------------------------------------------------------------- round eight (Ryan, 29 September, on round six)
# The power cuts raised the toms' volume, which was not the ask: keep the harder stick and
# front without playing them louder, with the middle tightening from round four, and the
# high tom brought down in pitch toward the low one.

def tom_hard(skin_mult, room_mult, drive, front, stick):
    def voice(f=150.0, pitch=1.0):
        f = 130.0 if f > 120.0 else f   # the high tom compressed down toward the low one
        n = F.n_of(0.5)
        t = F.t_of(n)
        fr = f * pitch * (1.0 + 0.18 * F.np.exp(-t / 0.05))
        sk = F.np.sin(2.0 * F.math.pi * F.np.cumsum(fr) / F.SR) * F.env_ad(n, 0.001, 0.11 * skin_mult, curve=2.5)
        sub = F.np.sin(2.0 * F.math.pi * f * pitch * 0.5 * t) * F.env_ad(n, 0.002, 0.09 * skin_mult) * 0.5
        shell = F.harmonics(f * pitch * 1.4, n, [0.5, 0.25, 0.1]) * F.env_ad(n, 0.001, 0.03) * 0.3
        st = F.lp(F.bp(F.noise(F.n_of(0.01)), 1500.0, 6000.0), 5000.0) * F.env_ad(F.n_of(0.01), 0.0002, 0.003) * stick
        hit = F.body(f * pitch * 1.6, f * pitch, 0.04, drive=2.6, click=0.8) * front
        shadow = F.bp(F.sat(sk + sub, 3.0), 120.0, 500.0) * 0.35
        return F.room(F.mix(F.sat(sk + sub, drive), shell, hit, F.at(F.np.zeros(1), st, 0.0), shadow),
                      decay=0.05 * room_mult, mix=0.06 * room_mult, cut=4500.0) * 1.1
    return voice


TOM_HARD = [
    ("as ships", {}),
    ("hard one", dict(tom_real=tom_hard(0.75, 0.6, 2.2, 1.3, 1.8))),
    ("hard two", dict(tom_real=tom_hard(0.75, 0.6, 2.6, 1.5, 2.0))),
]


# ---------------------------------------------------------------- rendering

class Patched:
    """Swap module globals for one render, and put them back."""

    def __init__(self, **swaps):
        self.swaps = swaps
        self.saved = {}

    def __enter__(self):
        for k, v in self.swaps.items():
            self.saved[k] = getattr(F, k)
            setattr(F, k, v)

    def __exit__(self, *a):
        for k, v in self.saved.items():
            setattr(F, k, v)


def with_form(name, form):
    saved = F.MUSIC[name]["form"]
    F.MUSIC[name]["form"] = form
    return saved


def groove_with(overrides):
    orig = F.groove

    def g(*a, **kw):
        kw.update(overrides)
        return orig(*a, **kw)
    return g


def render_hold(form, swap=None, groove_kw=None, patches=None, post=None):
    saved = with_form("music_hold_the_line", form)
    try:
        F.seed("music_hold_the_line")   # the same slop, the same drum picks: only the change is heard
        kw = dict(groove_kw or {})
        if swap:
            kw["swap"] = swap
        with Patched(groove=groove_with(kw), **(patches or {})):
            x = F.music_hold_the_line()
    finally:
        F.MUSIC["music_hold_the_line"]["form"] = saved
    return post(x) if post else x


OLD_MASTER = dict(tilt=3.0, presence=0.0)   # the human tracks' master before 28 September
_FAR = {}


def far_bank(groove_kw):
    # Whole, and cached per master: its builder sizes patterns from the form's sections, so
    # the form cannot be cut, and a render is minutes.
    key = tuple(sorted(groove_kw.items()))
    if key not in _FAR:
        F.seed("music_far_bank")
        with Patched(groove=groove_with(groove_kw)):
            _FAR[key] = F.music_far_bank()
    return _FAR[key]


def level_to(x, target_db, measure=F.mean_level):
    return F.limit(x * 10.0 ** ((target_db - measure(x)) / 20.0))


def write(name, x):
    os.makedirs(OUT, exist_ok=True)
    wav = os.path.join(OUT, name + ".wav")
    pcm = (np.clip(x, -1.0, 1.0) * 32767.0).astype("<i2")
    with wave.open(wav, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(F.SR)
        w.writeframes(pcm.tobytes())
    m4a = os.path.join(OUT, name + ".mp4")   # AAC in an MP4 container: what the listening page serves
    try:
        subprocess.run(["afconvert", "-f", "mp4f", "-d", "aac", "-b", "128000", "-q", "127", wav, m4a], check=True, capture_output=True)
    except (OSError, subprocess.CalledProcessError) as e:
        print("  (no aac for %s: %s)" % (name, e))
        m4a = None
    return wav, m4a


def bar_seconds(bpm):
    return 4.0 * 60.0 / bpm


def solo_bass_file(names=None, seed_name="phone_bass_solo"):
    """Every voice alone on the riff, four bars each, a bar's rest between."""
    names = names or [n for n, _, _ in BASS_VOICES]
    riff = "0--.3-.0-...1-..g--.3-.1-...0-.."
    form = "".join("%s%s%s%sR" % ((chr(ord("A") + i),) * 4) for i in range(len(names)))
    vs = []
    for i, name in enumerate(names):
        sec = chr(ord("A") + i)
        vs.append({"inst": "bass_" + name, "mode": "riff", "gain": 0.6, "hold": 1.0, "pat": {sec: riff}})
    drums = {"kick": {"*": "x.xx.x.", "R": "................"}, "hat": {"*": "x.x.x.x.x.x.x.x.", "R": "................"}}
    kit = {"kick": (F.variants(F.kick_real), 0.5), "hat": (F.variants(lambda p: F.hat_real(False, p)), 0.3)}
    F.seed(seed_name)
    x = F.groove(bpm=100, form=form, kit=kit, drums=drums, chords={"*": [[0, 7, 12]]}, voices=vs, tilt=1.5, presence=0.25, low=(150.0, -6.0), human=(0.005, 0.15))
    marks = [(i * 5 * bar_seconds(100), name) for i, name in enumerate(names)]
    return x, marks


def main(argv):
    which = argv[0] if argv else "all"
    os.makedirs(OUT, exist_ok=True)
    page = os.path.join(os.path.dirname(os.path.abspath(__file__)), "phone_page.html")
    if os.path.exists(page):   # the committed page, copied in so the publish has everything in one folder
        with open(page) as src, open(os.path.join(OUT, "index.html"), "w") as dst:
            dst.write(src.read())
    manifest = {"voices": [], "balance": [], "levels": [], "voices2": [], "guitar": [], "shadows2": [], "rift": [], "round3": [], "round4": [], "round5": [], "round6": [], "round7": [], "round8": [], "notes": {}}
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, "manifest.json")
    if which != "all" and os.path.exists(path):
        with open(path) as fh:   # one set re-rendered keeps the others' entries
            manifest.update(json.load(fh))
        manifest[which] = []

    def save():
        with open(path, "w") as fh:
            json.dump(manifest, fh, indent=1)
    if which in ("voices", "all"):
        print("voices")
        for name, _, note in BASS_VOICES:
            x = render_hold(VOICE_FORM, swap={"bass_real": "bass_" + name})
            x = level_to(x, SKIRMISH_LEVEL)
            wav, m4a = write("bass_" + name, x)
            manifest["voices"].append({"name": "bass_" + name, "seconds": len(x) / F.SR, "note": note, "phone_db": round(phone_level(x), 1)})
            print("  %-14s %5.1f s  phone %.1f dB" % (name, len(x) / F.SR, phone_level(x)))
        x, marks = solo_bass_file()
        x = level_to(x, SKIRMISH_LEVEL)
        write("bass_solo", x)
        manifest["voices"].append({"name": "bass_solo", "seconds": len(x) / F.SR, "note": "every voice alone on the riff, four bars each, in the order above", "marks": marks})
        print("  solo: " + ", ".join("%s at %d:%04.1f" % (n, int(t // 60), t % 60) for t, n in marks))
        save()
    if which in ("balance", "all"):
        print("balance")
        # The first three on the old master (tilt 3, no presence lift), which the builders no
        # longer carry since the tilt was decided (28 September).
        steps = [
            ("mix_shipped", "as shipped (the old master)", OLD_MASTER, None, None),
            ("mix_shadows", "shadows under the kick, the toms and the sub: a knock at 200 Hz and harmonics 150 to 600 Hz",
             OLD_MASTER, dict(kick_real=kick_shadow, tom_real=tom_shadow, sub_bass=sub_shadow), None),
            ("mix_subcut", "the sub cut: nothing below 45 Hz, -6 dB below 80; the RMS budget goes to the mids", OLD_MASTER, None, sub_cut),
            ("mix_tilt", "a gentler master tilt (1.5 dB from 3) with a narrow presence lift at 1 to 2 kHz: now the human master", {}, None, None),
            ("mix_all", "all three", {}, dict(kick_real=kick_shadow, tom_real=tom_shadow, sub_bass=sub_shadow), sub_cut),
        ]
        for name, note, kw, patches, post in steps:
            x = render_hold(BALANCE_FORM, groove_kw=kw, patches=patches, post=post)
            x = level_to(x, SKIRMISH_LEVEL)
            write(name, x)
            manifest["balance"].append({"name": name, "seconds": len(x) / F.SR, "note": note, "phone_db": round(phone_level(x), 1)})
            print("  %-14s %5.1f s  phone %.1f dB" % (name, len(x) / F.SR, phone_level(x)))
        save()
    if which in ("voices2", "all"):
        print("voices2")
        second = [(n, note) for n, _, note in BASS_VOICES_2] + [(n, note) for n, _, note in OTHER_VOICES]
        for name, note in second:
            x = level_to(render_hold(VOICE_FORM, swap={"bass_real": "bass_" + name}), SKIRMISH_LEVEL)
            write("bass_" + name, x)
            manifest["voices2"].append({"name": "bass_" + name, "seconds": len(x) / F.SR, "note": note, "phone_db": round(phone_level(x), 1)})
            print("  %-14s %5.1f s  phone %.1f dB" % (name, len(x) / F.SR, phone_level(x)))
        x, marks = solo_bass_file([n for n, _ in second], "phone_bass_solo2")
        x = level_to(x, SKIRMISH_LEVEL)
        write("bass_solo2", x)
        manifest["voices2"].append({"name": "bass_solo2", "seconds": len(x) / F.SR, "note": "the six above alone on the riff, four bars each, in order", "marks": marks})
        save()
    if which in ("guitar", "all"):
        print("guitar")
        x = level_to(render_hold(VOICE_FORM, swap={"guitar_real": "guitar_soft"}), SKIRMISH_LEVEL)
        write("guitar_soft", x)
        manifest["guitar"].append({"name": "guitar_soft", "seconds": len(x) / F.SR, "phone_db": round(phone_level(x), 1),
                                   "note": "the backing guitar without its hard clip: two asymmetric stages and the cabinet; the pick scrape and the palm as shipped"})
        print("  guitar_soft    %5.1f s  phone %.1f dB" % (len(x) / F.SR, phone_level(x)))
        save()
    if which in ("shadows2", "all"):
        print("shadows2")
        p2 = dict(kick_real=kick_shadow2, tom_real=tom_shadow, sub_bass=sub_shadow2, crash_real=crash_soft)
        for name, note, patches in [
            ("mix_shadows2", "the shadows' second cut on the human master: the kick's without the pitch sweep, the sub's gentler, a softer crash; no sub cut", p2),
            ("mix_crash", "the human master with only the softer crash, to hear that change alone", dict(crash_real=crash_soft)),
        ]:
            x = level_to(render_hold(BALANCE_FORM, patches=patches), SKIRMISH_LEVEL)
            write(name, x)
            manifest["shadows2"].append({"name": name, "seconds": len(x) / F.SR, "note": note, "phone_db": round(phone_level(x), 1)})
            print("  %-14s %5.1f s  phone %.1f dB" % (name, len(x) / F.SR, phone_level(x)))
        save()
    if which in ("rift", "all"):
        print("rift")
        fb = bar_seconds(86)
        for name, kw, note in [
            ("far_shipped", {}, "The Far Bank from its groove, as shipped (tilt 4, no presence lift)"),
            ("far_tilt", dict(tilt=1.5, presence=0.25), "the same bars on the human master (tilt 1.5, the presence lift)"),
        ]:
            far = far_bank(kw)
            x = level_to(far[int(8 * fb * F.SR): int(8 * fb * F.SR) + 30 * F.SR], F.LEVELS["music_far_bank"])
            write(name, x)
            manifest["rift"].append({"name": name, "seconds": len(x) / F.SR, "note": note, "phone_db": round(phone_level(x), 1)})
            print("  %-14s %5.1f s  phone %.1f dB" % (name, len(x) / F.SR, phone_level(x)))
        save()
    if which in ("round3", "all"):
        print("round3")
        for name, _, note in BASS_VOICES_3:
            x = level_to(render_hold(VOICE_FORM, swap={"bass_real": "bass_" + name}), SKIRMISH_LEVEL)
            write("bass_" + name, x)
            manifest["round3"].append({"name": "bass_" + name, "seconds": len(x) / F.SR, "note": note, "phone_db": round(phone_level(x), 1)})
            print("  %-14s %5.1f s  phone %.1f dB" % (name, len(x) / F.SR, phone_level(x)))
        race = ["stage", "split", "stagedyn", "splitbright"]
        x, marks = solo_bass_file(race, "phone_bass_solo3")
        x = level_to(x, SKIRMISH_LEVEL)
        write("bass_solo3", x)
        manifest["round3"].append({"name": "bass_solo3", "seconds": len(x) / F.SR, "note": "3, 5, 3 with the drive following, 5 brought up: alone on the riff, four bars each", "marks": marks})
        x = level_to(render_hold(VOICE_FORM, swap={"guitar_real": "guitar_soft"}), SKIRMISH_LEVEL)
        write("guitar_soft", x)
        manifest["round3"].append({"name": "guitar_soft", "seconds": len(x) / F.SR, "phone_db": round(phone_level(x), 1),
                                   "note": "the backing guitar without its hard clip, level-matched to the shipped one (x%.2f)" % GUITAR_MATCH})
        print("  guitar_soft    %5.1f s  phone %.1f dB  match x%.2f" % (len(x) / F.SR, phone_level(x), GUITAR_MATCH))
        x = level_to(render_hold(BALANCE_FORM, patches=SHADOWS_3), SKIRMISH_LEVEL)
        write("mix_shadows3", x)
        manifest["round3"].append({"name": "mix_shadows3", "seconds": len(x) / F.SR, "phone_db": round(phone_level(x), 1),
                                   "note": "the third cut: a metal kick (quicker fall, more beater, a short static knock, less room), the tom lower and duller, the gentler sub shadow, the softer crash"})
        print("  mix_shadows3   %5.1f s  phone %.1f dB" % (len(x) / F.SR, phone_level(x)))
        parts, marks, t = [], [], 0.0
        for label, patches in [("shipped", {}), ("second cut", SHADOWS_2), ("third cut", SHADOWS_3)]:
            d = level_to(drums_clip(patches), SKIRMISH_LEVEL)
            marks.append((t, label))
            parts.append(d)
            parts.append(np.zeros(F.SR))
            t += (len(d) + F.SR) / F.SR
        x = np.concatenate(parts)
        write("drums_kits", x)
        manifest["round3"].append({"name": "drums_kits", "seconds": len(x) / F.SR, "marks": marks,
                                   "note": "the riff's drums alone, four bars each: the shipped kit, the shadows' second cut, the third cut"})
        save()
    if which in ("round4", "all"):
        print("round4")
        # The excerpt exactly as it ships: every pick in the forge, nothing patched.
        x = level_to(render_hold(BALANCE_FORM), SKIRMISH_LEVEL)
        write("mix_ship", x)
        manifest["round4"].append({"name": "mix_ship", "seconds": len(x) / F.SR, "phone_db": round(phone_level(x), 1),
                                   "note": "the riff, the turn and the lift exactly as the track ships now: voice 12's bass, the clip-free guitar, the metal kick, the tightened tom, the softer crash, the sub's shadow, the one master"})
        print("  mix_ship       %5.1f s  phone %.1f dB" % (len(x) / F.SR, phone_level(x)))
        for name, variants, note in [("drums_kick", KICK_SIZES, "the kick's size: as it ships, then pitched down a tenth, then a fifth"),
                                     ("drums_tom", TOM_TIGHTS, "the toms: as they ship, then tighter (a shorter skin, less room, a harder front), then tightest")]:
            parts, marks, t = [], [], 0.0
            for label, patches in variants:
                d = level_to(drums_clip(patches), SKIRMISH_LEVEL)
                marks.append((t, label))
                parts.append(d)
                parts.append(np.zeros(F.SR))
                t += (len(d) + F.SR) / F.SR
            x = np.concatenate(parts)
            write(name, x)
            manifest["round4"].append({"name": name, "seconds": len(x) / F.SR, "marks": marks, "note": note})
            print("  %-14s %5.1f s  %s" % (name, len(x) / F.SR, ", ".join(l for l, _ in variants)))
        save()
    if which in ("round5", "all"):
        print("round5")
        # The Far Bank whole at three tempos (Ryan, 29 September: it was slowed to 86 when it
        # was to be a map theme; as a boss track, hear 90 and 92, the original take, again).
        # Each levelled to the shipped level; the wrap is the file's end, since a sketch has
        # no loop point.
        for bpm in (86, 90, 92):
            F.seed("music_far_bank")
            x = level_to(F.music_far_bank(bpm=bpm), F.LEVELS["music_far_bank"])
            name = "far_bank_%d" % bpm
            write(name, x)
            manifest["round5"].append({"name": name, "seconds": len(x) / F.SR, "phone_db": round(phone_level(x), 1),
                                       "note": "The Far Bank whole at %d bpm%s" % (bpm, ", as it ships" if bpm == 86 else "")})
            print("  %-14s %5.1f s  phone %.1f dB" % (name, len(x) / F.SR, phone_level(x)))
        save()
    if which in ("round6", "all"):
        print("round6")
        for name, patches, note in [
            ("mix_kick_mid", dict(kick_real=kick_at(0.9)), "the track with the kick's middle size (pitched down a tenth)"),
            ("mix_kick_old", dict(kick_real=kick_old), "the track with the old kick, the one before the metal cut, in case that is the original meant"),
        ]:
            x = level_to(render_hold(BALANCE_FORM, patches=patches), SKIRMISH_LEVEL)
            write(name, x)
            manifest["round6"].append({"name": name, "seconds": len(x) / F.SR, "phone_db": round(phone_level(x), 1), "note": note})
            print("  %-14s %5.1f s  phone %.1f dB" % (name, len(x) / F.SR, phone_level(x)))
        parts, marks, t = [], [], 0.0
        for label, patches, mult in TOM_POWER:
            d = level_to(drums_clip_kit(patches, {"tom": mult, "tom2": mult}), SKIRMISH_LEVEL)
            marks.append((t, label)); parts.append(d); parts.append(np.zeros(F.SR)); t += (len(d) + F.SR) / F.SR
        x = np.concatenate(parts)
        write("drums_tom_power", x)
        manifest["round6"].append({"name": "drums_tom_power", "seconds": len(x) / F.SR, "marks": marks,
                                   "note": "the drums bare: the toms as they ship, then hit harder (more body saturation, a harder front and stick, played louder), then harder still with more body"})
        print("  drums_tom_power %5.1f s" % (len(x) / F.SR))
        for (label, patches, mult), name in zip(TOM_POWER[1:], ("mix_tom_power1", "mix_tom_power2")):
            x = level_to(render_hold_kit(BALANCE_FORM, patches, {"tom": mult, "tom2": mult}), SKIRMISH_LEVEL)
            write(name, x)
            manifest["round6"].append({"name": name, "seconds": len(x) / F.SR, "phone_db": round(phone_level(x), 1), "note": "the track with the toms at " + label})
            print("  %-14s %5.1f s  phone %.1f dB" % (name, len(x) / F.SR, phone_level(x)))
        save()
    if which in ("round7", "all"):
        print("round7")
        # Hold The Line a little faster (Ryan, 29 September), whole, on the arrangement as it
        # ships; and its loop seam as the game plays it now: the last twelve bars, then the
        # wrap into bar five, where the bass enters, rather than the bare top.
        saved = F.MUSIC["music_hold_the_line"]["bpm"]
        try:
            F.MUSIC["music_hold_the_line"]["bpm"] = 104
            F.seed("music_hold_the_line")
            x = level_to(F.music_hold_the_line(), SKIRMISH_LEVEL)
        finally:
            F.MUSIC["music_hold_the_line"]["bpm"] = saved
        write("hold_104", x)
        manifest["round7"].append({"name": "hold_104", "seconds": len(x) / F.SR, "phone_db": round(phone_level(x), 1), "note": "Hold The Line whole at 104 (it ships at 100), on the 29 September arrangement"})
        print("  hold_104       %5.1f s  phone %.1f dB" % (len(x) / F.SR, phone_level(x)))
        y, sr = F.read("music_hold_the_line")
        bar = int(bar_seconds(F.MUSIC["music_hold_the_line"]["bpm"]) * F.SR)
        seam = np.concatenate([y[-12 * bar:], y[8 * bar: 20 * bar]])
        write("hold_seam", seam)
        manifest["round7"].append({"name": "hold_seam", "seconds": len(seam) / F.SR, "marks": [(0.0, "the last twelve bars"), (12 * bar / F.SR, "the wrap into bar five")],
                                   "note": "Hold The Line's loop as the game plays it now: the descent's last twelve bars, then bar five (the bass's entrance) onward"})
        save()
    if which in ("round8", "all"):
        print("round8")
        parts, marks, t = [], [], 0.0
        for label, patches in TOM_HARD:
            d = level_to(drums_clip(patches), SKIRMISH_LEVEL)
            marks.append((t, label)); parts.append(d); parts.append(np.zeros(F.SR)); t += (len(d) + F.SR) / F.SR
        x = np.concatenate(parts)
        write("drums_tom_hard", x)
        manifest["round8"].append({"name": "drums_tom_hard", "seconds": len(x) / F.SR, "marks": marks,
                                   "note": "the drums bare: the toms as they ship, then the harder stick and front at round six's two powers with the middle tightening and the high tom brought down to 130 Hz, played at the same volume"})
        print("  drums_tom_hard %5.1f s" % (len(x) / F.SR))
        for (label, patches), name in zip(TOM_HARD[1:], ("mix_tom_hard1", "mix_tom_hard2")):
            x = level_to(render_hold(BALANCE_FORM, patches=patches), SKIRMISH_LEVEL)
            write(name, x)
            manifest["round8"].append({"name": name, "seconds": len(x) / F.SR, "phone_db": round(phone_level(x), 1), "note": "the track with the toms at " + label})
            print("  %-14s %5.1f s  phone %.1f dB" % (name, len(x) / F.SR, phone_level(x)))
        save()
    if which in ("levels", "all"):
        print("levels")
        # The levelling gap: twenty seconds of each at the shipped levels, then by the phone model.
        hold = render_hold(BALANCE_FORM)
        far = far_bank({})
        hb, fb = bar_seconds(100), bar_seconds(86)
        hold = hold[int(4 * hb * F.SR): int(4 * hb * F.SR) + 20 * F.SR]     # from the bass's entrance
        far = far[int(8 * fb * F.SR): int(8 * fb * F.SR) + 20 * F.SR]       # from the groove
        gap = np.zeros(F.SR)
        h0 = level_to(hold, F.LEVELS["music_hold_the_line"])
        f0 = level_to(far, F.LEVELS["music_far_bank"])
        shipped = np.concatenate([h0, gap, f0])
        write("level_shipped", shipped)
        target = phone_level(h0)
        f1 = level_to(far, target, phone_level)
        h1 = h0
        phone = np.concatenate([h1, gap, f1])
        write("level_phone", phone)
        gap_db = round(target - phone_level(f0), 1)
        # Half way (Ryan, 28 September: the full gap made The Far Bank a little loud on the
        # speaker and far too loud in headphones): the same, up by half the gap.
        f2 = level_to(far, F.LEVELS["music_far_bank"] + gap_db / 2.0)
        write("level_half", np.concatenate([h0, gap, f2]))
        manifest["levels"].append({"name": "level_half", "seconds": len(phone) / F.SR, "note": "the same two, The Far Bank up by half the gap (%.1f dB)" % (gap_db / 2.0)})
        f3 = level_to(far, F.LEVELS["music_far_bank"] + gap_db / 4.0)   # and a quarter (Ryan: half still loud in both)
        write("level_quarter", np.concatenate([h0, gap, f3]))
        manifest["levels"].append({"name": "level_quarter", "seconds": len(phone) / F.SR, "note": "the same two, The Far Bank up by a quarter of the gap (%.1f dB)" % (gap_db / 4.0)})
        manifest["levels"].append({"name": "level_shipped", "seconds": len(shipped) / F.SR, "note": "Hold The Line, a second's gap, The Far Bank, at the shipped levels (-20.7 and -22.5 dB mean RMS)"})
        manifest["levels"].append({"name": "level_phone", "seconds": len(phone) / F.SR, "note": "the same two levelled by what a phone speaker plays: The Far Bank comes up %.1f dB" % gap_db})
        manifest["notes"]["level_gap_db"] = gap_db
        manifest["notes"]["far_bank_full_vs_phone"] = [round(F.mean_level(f0), 1), round(phone_level(f0), 1)]
        manifest["notes"]["hold_full_vs_phone"] = [round(F.mean_level(h0), 1), round(phone_level(h0), 1)]
        print("  levelling gap on the phone: The Far Bank %.1f dB under Hold The Line at the shipped levels" % gap_db)
        save()
    print(os.path.relpath(OUT))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
