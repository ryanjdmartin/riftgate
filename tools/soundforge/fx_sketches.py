"""A second pass at the game's effects (30 September, evening), sketched beside what ships
so Ryan can A/B each on the phone. Nothing here is written into art/audio: a pick lands in
forge.py afterwards, then `build` and one `--import`.

The idea: one sound world in the three registers the screen already has.

  console   green, the player's own quiet lines: CARE's reconstruction. One grammar for
            every press: a key (a membrane key under glass, a damped tuk, no relay spring),
            a reply (a flat console tone tuned to the music's E: G3, B3, E4), and work
            (chatter). The die is a mechanism, not a button: lifted from its socket, seated
            back without a tone, the roll the readout's own digit scramble (ticks at the
            flip rate, the brackets collapsing shut), the lock the corners snapping on.
  iron      the player's machines, mid-nineties 3D in five makers' metals. A blow sounds
            by the weapon's shape (barrel, twin barrel, rack, blade, dish), since the mount
            rule made the shape the thing on screen; a hit, a block and a kill sound in the
            metal of the machine struck (Minerva steel, Kestrel chrome, Wainwright iron,
            Aphelion ceramic, Arsenal gunmetal with its red glass). A footfall by silhouette.
  rift      violet, the other side, drawn flat and painterly: each family gets its own
            blow, heavy blow and arrival. The Risen are dry bone and grave-light (cold flat
            hums, brittle cracks, rattles); the Infernal Horde is fire (whoomps, roars,
            embers, loud and telegraphed); The Chorus is geometry (the choir on a cluster,
            gated and crushed as if the feed cannot hold it, and it talks to the console's
            own ticks). A boss reveal: the feed tearing, the name resolving from a scramble.
  red       where it is about to hurt: the alarm, the dive, the gate, the end. Tuned to E
            so they sit in any of the six tracks; the dive counts in on the console's
            key; defeat ends on the feed losing signal.

The rules kept: nothing sweeps in pitch (a filter may move, a loudness may grow); damped
knocks, never a bell; weight in the 150 to 800 Hz band the phone can play.

Ryan's first notes (1 October), each a change here, still nothing shipped: the console wants
more beeps and fewer clicks (the clicks are rightly digital, just overused, and poor on the
speaker), so the reply leads every press and the key sits under it, lower and softer, and the
roll scrambles in tones; the barrel's breech cycles well after the shot; the rack's salvo
flies before it lands; the blade runs longer; the laser much longer, a beam held on the plate;
the plasma winds up before it fires; the deflector rings on after it seals; a punch for the
blunt melee weapons (metal into flesh, hard); a block deflects rather than knocks hollow; a
blow a standing shield takes has a sound of its own; and a machine dying is the big deal it
should be.

The third cut (Ryan, 1 October, night: "more oomph"). A lot of the set did not read on the
phone: explosions and single shots carry no weight on a speaker. Regardless, exaggerate: not
comical irony, over-the-top Doom energy; draw the weapons out, since each die spent is
deliberate and nothing fires in a row, and make each feel rewarding and powerful; shields and
buffs too. The console the same: deliberate and with intent, not understated; retro 90s game
flair, super stereotypical computer sounds, ironically edgy, weighty. So: the console speaks
in a thick square-and-saw voice with an octave under it, a mechanical clack for a key, data
bursts and stepped confirms (the 24 September "future-digital, not retro" is retired for the
interface; the Pac-Man ruling stands for the weapons: no blow glides in pitch); every blow
gets its weight in the band a speaker plays (`heft`: its own mids saturated and added back)
and a boom tail, and runs longer; the levels the sketches are written at carry an offset
(`BOOST`) over the shipped ones, said on the page, for Ryan to pull back.

The console's fourth cut (Ryan, 2 October): "90s computer" meant 90s computer game, StarCraft
1, MechWarrior 2, Descent; retro-future, not retro. The voice is clean tones with a chorus and
a glide into the note through a resonant filter, the button a dry plastic click, the computer
talking a fast run of clean tones, a synth thump under every confirmation.

    tools/spriter/.venv/bin/python tools/soundforge/fx_sketches.py            # everything into out/fx
    tools/spriter/.venv/bin/python tools/soundforge/fx_sketches.py singles    # the sounds alone
    tools/spriter/.venv/bin/python tools/soundforge/fx_sketches.py sequences  # the rounds over the music

Writes WAV and AAC (.mp4) into tools/soundforge/out/fx/ with a manifest, and copies
fx_page.html in beside them as index.html, to publish with `root` set to that folder.
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
import speech  # noqa: E402

OUT = os.path.join(F.OUT_SKETCH, "fx")
PAGE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fx_page.html")

# E-tuned console pitches.
E1, E2, B2, E3, G3, B3, E4, G4, B4, E5 = 41.2, 82.41, 123.47, 164.81, 196.0, 246.94, 329.63, 392.0, 493.88, 659.26

n_of, t_of = F.n_of, F.t_of
mix, at, room = F.mix, F.at, F.room


def heft(x, amount=0.6, drive=3.0):
    """The phone's weight: the signal's own mids, saturated and added back in the band a
    speaker plays (250 to 2000 Hz). Headphones keep the sub underneath; the speaker gets
    harmonics it can move air with. The third cut's answer to "it doesn't carry on a speaker"."""
    # Filtered with silence after it: the forge's filters work on the whole buffer in the
    # frequency domain, so a sharp front wrapped round to the end as a pop well after the
    # sound had died (found 9 October in nine shipped effects); the padding takes the wrap.
    pad = np.zeros(F.n_of(0.5))
    return x + F.bp(np.concatenate([F.sat(x * 1.5, drive), pad]), 250.0, 2000.0)[:len(x)] * amount


def boom_tail(dur=0.8, gain=0.7, cut=350.0):
    """The air after a blast: low noise decaying over most of a second, saturated so its
    harmonics reach the speaker. Draws a blow out without repeating it."""
    n = n_of(dur)
    r = F.lp(F.sat(F.lp(F.noise(n), cut) * 2.0, 3.0), 1500.0)
    return r * F.env_pts(n, [(0.0, 0.0), (0.02, 1.0), (dur * 0.35, 0.45), (dur, 0.0)]) * gain


def big_blast(dur=1.4, low=24.0, gain=1.0, debris=4):
    return heft(mix(F.explosion(dur, low, gain, debris), boom_tail(dur * 0.7, 0.6 * gain)), 0.6)


# ---------------------------------------------------------------- the console
#
# The fourth cut of the console (Ryan, 2 October: "90s computer" meant 90s computer game,
# StarCraft 1, MechWarrior 2, Descent; retro-future, not retro; the square-and-saw voice of
# the third cut read as retro). That era's interface was sampled synths, not chips: a dry
# plastic button click (StarCraft's Terran panel), clean tones with a chorus on them and a
# short glide into the note through a resonant filter (MechWarrior 2's cockpit, "target
# locked"), the computer talking as a fast run of clean tones (Descent's messages), menu
# sweeps of filtered air, and a synth thump under anything confirmed. Weight is the thump
# and an octave under every tone. Pitches stay low (Ryan, 25 September): G3 to E4 for the
# voice, the run up to E5. Glides are back in the console only, short and into a note; a
# blow still never glides (the Pac-Man ruling).

def chorus(x, depth=0.0035, rate=0.9, voices=2, wet=0.6):
    """The era's gloss: copies of the signal on a slowly moving short delay."""
    n = len(x)
    t = t_of(n)
    idx = np.arange(n)
    out = np.array(x, dtype=float)
    for v in range(voices):
        d = 0.006 + depth * np.sin(2.0 * math.pi * rate * t + v * 2.1)
        out += np.interp(idx - d * F.SR, idx, x, left=0.0) * (wet / voices)
    return out


def thock(weight=1.0, pitch=1.0):
    """A StarCraft button: a dry plastic click, short and mid, no spring and no casing ring."""
    k = mix(F.knock([1500.0 * pitch, 2600.0 * pitch], [0.004, 0.003], [1.0, 0.5], noise_gain=0.7) * 0.6,
            F.knock([520.0 * pitch, 820.0 * pitch], [0.009, 0.006], [1.0, 0.5], noise_gain=0.2) * 0.7)
    return F.lp(k, 5000.0) * weight


key = thock     # earlier cuts' names, for the rows that still call them
clack = thock


def bleep(f, dur, gain=0.5, glide=1.0, q=0.6, bright=1.0):
    """The cockpit's tone: a sine with a triangle edge, an octave over and an octave under,
    a short glide into the note over its first 30 ms (`glide` under 1 rises in, over 1
    falls in), through a resonant low-pass that opens with the note and closes with it,
    then the chorus. MechWarrior 2's beeps, Descent's menu."""
    n = n_of(dur)
    t = t_of(n)
    g = np.where(t < 0.03, glide + (1.0 - glide) * (t / 0.03), 1.0)
    ph = 2.0 * math.pi * np.cumsum(f * g) / F.SR
    tri = 2.0 / math.pi * np.arcsin(np.sin(ph))
    x = np.sin(ph) * 0.7 + tri * 0.3 + np.sin(2.0 * ph) * 0.25 * bright + np.sin(ph * 0.5) * 0.35
    cut = F.env_pts(n, [(0.0, 900.0), (0.02, 3500.0 * bright), (dur * 0.6, 2500.0 * bright), (dur, 700.0)])
    x = F.svf(x, cut, q)
    env = F.env_pts(n, [(0.0, 0.0), (0.004, 1.0), (max(dur - 0.02, 0.01), 0.8), (dur, 0.0)])
    return chorus(x * env) * gain


def reply(f, dur, gain=0.5):
    return bleep(f, dur, gain)


def burble(dur, gain=0.45, pitches=(E4, G4, B4, E5)):
    """The computer talking: a fast run of clean tones on a few pitches around E, each a
    few ms, no glide, a soft tick on each, the whole through a filter opening over the run
    and a chorus. Descent's messages, the readout working."""
    n = n_of(dur)
    buf = np.zeros(n)
    when = 0.0
    while when < dur - 0.015:
        d = F.RNG.uniform(0.012, 0.022)
        m = n_of(d)
        f = float(F.RNG.choice(pitches))
        ph = 2.0 * math.pi * f * t_of(m)
        tone = (np.sin(ph) * 0.8 + np.sin(ph * 0.5) * 0.4) * F.env_pts(m, [(0.0, 0.0), (0.002, 1.0), (d - 0.004, 0.8), (d, 0.0)])
        buf = at(buf, mix(tone, F.tick_click() * 0.5), when, F.RNG.uniform(0.5, 1.0))[:n]
        when += d + F.RNG.uniform(0.004, 0.014)
    t = t_of(n)
    buf = F.lp_var(buf, 900.0 + 3200.0 * np.clip(t / (dur * 0.6), 0.0, 1.0))
    return chorus(buf) * gain


def thump(gain=0.6, f0=140.0, f1=70.0, dur=0.14):
    """A synth thump under a confirmation: the weight of the era's panel, with its mids
    saturated so a phone speaker plays it."""
    n = n_of(dur)
    x = F.sweep(f0, f1, n, tau=dur * 0.3) * F.env_ad(n, 0.002, dur * 0.3)
    return heft(F.lp(F.sat(x, 2.0), 600.0), 0.8, 3.5) * gain


def ui_sweep(dur=0.12, down=True, gain=0.3):
    """Descent's menu: filtered air sweeping through, chorused."""
    n = n_of(dur)
    t = t_of(n)
    cut = 4000.0 - 3300.0 * (t / dur) if down else 700.0 + 3300.0 * (t / dur)
    x = F.lp_var(F.hp(F.noise(n), 500.0), cut) * F.env_pts(n, [(0.0, 0.0), (dur * 0.2, 1.0), (dur, 0.0)])
    return chorus(x) * gain


def c_ui_tap():
    # The panel button: a dry click and a clean tone rising into B3.
    return room(mix(thock(1.0), bleep(B3, 0.08, 0.55, glide=0.85)), decay=0.09, mix=0.14, cut=7000.0)


def c_ui_back():
    # The cancel: the click, a tone falling into B3, a sweep of air going out.
    return room(mix(thock(0.9), bleep(B3, 0.11, 0.5, glide=1.4), ui_sweep(0.1, True, 0.25)), decay=0.09, mix=0.14, cut=7000.0)


def c_plot():
    # Waypoint set: the computer talks, the click, two tones up B3 to E4 with a thump under.
    b = burble(0.18, 0.4)
    b = at(b, mix(thock(1.0), bleep(B3, 0.06, 0.5, glide=0.9), thump(0.4)), 0.2)
    b = at(b, bleep(E4, 0.09, 0.5), 0.27)
    return room(b, decay=0.1, mix=0.14, cut=7000.0)


def c_die_pick():
    # Lifted: the click, air sweeping up as it leaves the panel, the arm's servo, a tone
    # rising into E4.
    b = mix(thock(0.8, 1.1), ui_sweep(0.1, False, 0.3), F.servo(220.0, 300.0, 0.12, gain=0.25, band=(400.0, 2500.0)))
    return room(at(b, bleep(E4, 0.07, 0.5, glide=0.8), 0.03), decay=0.09, mix=0.14, cut=7000.0)


def c_die_drop():
    # Seated: the thump, a heavier click, a hiss of the seat, and a low tone falling into E3.
    b = mix(thump(0.8, 160.0, 75.0), thock(1.2, 0.8), F.hydraulic(0.08, 2500.0, 900.0, 0.25))
    return room(at(b, bleep(E3, 0.12, 0.45, glide=1.15, bright=0.7), 0.01), decay=0.1, mix=0.12)


def c_die_roll():
    # The readout working for half a second: the console under load, the computer talking
    # fast with its filter opening, then the stop: a heavy click, the thump, and the number
    # held on G3 with its filter closing over it.
    dur = 0.52
    n = n_of(dur)
    hum = F.lp(F.sat(F.saws(E2, n, (0.996, 1.0, 1.004)), 1.5), 700.0) * F.env_pts(n, [(0.0, 0.0), (0.03, 0.4), (0.46, 0.35), (0.52, 0.0)]) * 0.4
    b = mix(hum, burble(0.5, 0.5))
    b = at(b, mix(thock(1.4, 0.85), thump(0.7)), 0.52)
    return room(at(b, bleep(G3, 0.28, 0.6, q=0.5), 0.53), decay=0.12, mix=0.14, cut=7000.0)


def c_die_lock():
    # Target locked: two clicks under two tones up, B3 then E4, the second held with the
    # filter closing over it, a thump under it, and a quiet hold hum on E3 after.
    b = mix(thock(1.0), bleep(B3, 0.08, 0.5, glide=0.9))
    b = at(b, mix(thock(1.2, 0.9), bleep(E4, 0.3, 0.5, glide=0.95, q=0.5), thump(0.6)), 0.1)
    n = n_of(0.3)
    hold = F.lp(F.harmonics(E3, n, [1.0, 0.4, 0.2]) + np.sin(2.0 * math.pi * E2 * t_of(n)) * 0.4, 1200.0) * F.env_pts(n, [(0.0, 0.0), (0.02, 0.3), (0.2, 0.25), (0.3, 0.0)]) * 0.3
    return room(at(b, hold, 0.25), decay=0.12, mix=0.14, cut=7000.0)


def c_resolve():
    # Weapons online: the computer talks, three tones climb E3, G3, B3, the slam (the
    # console's heavy latch, the thump, the click), then the chord held, E3 and B3 chorused
    # through the filter with E2 under them, for six tenths.
    b = burble(0.28, 0.5)
    for k, (f, when) in enumerate([(E3, 0.3), (G3, 0.38), (B3, 0.46)]):
        b = at(b, mix(bleep(f, 0.07, 0.5, glide=0.9), thock(0.6)), when)
    slam = mix(F.thud(160.0, 45.0, 0.32, click=1.3, drive=4.0, body_gain=1.5) * 0.9, thock(1.4, 0.8), thump(0.8),
               F.knock([330.0, 560.0, 900.0], [0.03, 0.02, 0.012], [1.0, 0.5, 0.3], noise_gain=0.3) * 0.5)
    b = at(b, heft(slam, 0.5), 0.56)
    n = n_of(0.6)
    chord = mix(bleep(E3, 0.6, 0.45, q=0.5), bleep(B3, 0.6, 0.28, q=0.5),
                F.lp(F.sat(F.saws(E2, n, (0.995, 1.0, 1.005)), 2.0), 900.0) * F.env_pts(n, [(0.0, 0.0), (0.02, 0.5), (0.45, 0.4), (0.6, 0.0)]))
    b = at(b, chord, 0.6)
    return room(b, decay=0.2, mix=0.16, cut=7000.0)


def c_intent():
    # The warning on a foe's intent: two tones falling in, off the scale, a step apart,
    # lightly crushed, with a tick. The cockpit's "incoming".
    b = mix(F.crush(bleep(float(F.CHATTER_PITCHES[5]), 0.06, 0.5, glide=1.2, bright=0.6), bits=7, hold=2), F.glitch_perc() * 0.3)
    return at(b, F.crush(bleep(float(F.CHATTER_PITCHES[3]), 0.08, 0.5, glide=1.2, bright=0.6), bits=7, hold=2), 0.08)


# ---------------------------------------------------------------- the iron: makers' metals

PLATE = {
    # freqs, decays, amps, body gain, drive, the metal's own extra
    "minerva": ([480.0, 860.0, 1390.0, 2100.0], [0.045, 0.03, 0.02, 0.012], [1.0, 0.6, 0.35, 0.2], 1.2, 3.5),
    "kestrel": ([720.0, 1310.0, 2150.0, 3100.0], [0.03, 0.02, 0.012, 0.008], [1.0, 0.7, 0.45, 0.3], 0.75, 3.0),
    "wainwright_sutler": ([310.0, 560.0, 930.0, 1420.0], [0.07, 0.05, 0.035, 0.02], [1.0, 0.6, 0.4, 0.25], 1.25, 3.5),
    "aphelion": ([1050.0, 1900.0, 2800.0], [0.012, 0.008, 0.005], [1.0, 0.5, 0.3], 0.85, 3.0),
    "arsenal": ([260.0, 470.0, 790.0, 1230.0], [0.06, 0.045, 0.03, 0.02], [1.0, 0.7, 0.45, 0.3], 1.3, 4.0),
}
MAKERS = list(PLATE)
MAKER_NAMES = {"minerva": "Minerva steel", "kestrel": "Kestrel chrome", "wainwright_sutler": "Wainwright iron",
               "aphelion": "Aphelion ceramic", "arsenal": "Arsenal gunmetal"}


def plate(maker, gain=0.5):
    freqs, decays, amps, _, _ = PLATE[maker]
    k = F.knock(freqs, decays, amps, noise_gain=0.35) * gain
    if maker == "kestrel":
        k = mix(k, F.burst(0.03, 3000.0, 10000.0, decay=0.006) * 0.3 * gain)   # chrome's bright front
    if maker == "wainwright_sutler":
        k = mix(k, F.bp(F.noise(n_of(0.06)), 300.0, 1500.0) * F.env_ad(n_of(0.06), 0.001, 0.02) * 0.3 * gain)   # iron's grit
    if maker == "aphelion":
        k = mix(k, F.bp(F.noise(n_of(0.012)), 2000.0, 8000.0) * F.env_ad(n_of(0.012), 0.0002, 0.002) * 0.5 * gain)   # a dry click
    if maker == "arsenal":
        n = n_of(0.22)
        hum = F.lp(F.sat(F.harmonics(E1, n, [1.0, 0.6, 0.4, 0.3, 0.2]), 2.5), 500.0) * F.env_ad(n, 0.004, 0.08) * 0.35 * gain
        glass = F.knock([3200.0, 4800.0], [0.006, 0.004], [1.0, 0.5], noise_gain=0.2) * 0.3 * gain
        k = mix(k, hum, glass)
    return k


def i_hit(maker):
    # A blow landing on a machine, heavier than the second cut: the thud with more body
    # and drive, the strike, the maker's plate, a short boom tail, and the heft for the speaker.
    _, _, _, body_gain, drive = PLATE[maker]
    b = mix(F.thud(150.0, 45.0, 0.36, click=1.2, drive=drive + 0.5, body_gain=body_gain * 1.3),
            F.burst(0.1, 250.0, 5000.0, decay=0.025) * 0.9,
            plate(maker, 0.65), F.metal(0.12, 0.9), boom_tail(0.35, 0.35))
    return room(heft(b, 0.5), decay=0.18, mix=0.14)


def i_block(maker):
    # Armour turning a blow (Ryan, 1 October: the blocks were hollow, not deflecting). No
    # body and no thud, which were the hollow: the blow glances. A scrape whose band climbs
    # as it skids off (a filter moving, never a pitch), the plate's knock bright and short,
    # the little metal allowed at a higher pitch for the ring of the deflection, and a dry
    # snap at the front. The third cut gives it more front and a longer skid.
    n = n_of(0.13)
    t = t_of(n)
    scrape = F.lp_var(F.hp(F.noise(n), 700.0), 1200.0 + 4000.0 * (t / 0.13)) * F.env_pts(n, [(0.0, 0.0), (0.004, 1.0), (0.06, 0.5), (0.13, 0.0)]) * 0.8
    snap = F.burst(0.025, 2000.0, 9000.0, decay=0.005) * 0.9
    b = mix(snap, scrape, plate(maker, 0.85), F.metal(0.6, 1.6))
    b = at(b, F.metal(0.35, 2.1), 0.02)
    b = at(b, F.metal(0.2, 1.3), 0.06)
    return room(heft(b, 0.4), decay=0.1, mix=0.1)


def field_hum(n, gain=1.0):
    """The deflector's field: B1 with E2 and B2 over it, saturated, the hum of the set."""
    return F.lp(F.sat(F.harmonics(61.74, n, [1.0, 0.8, 0.5, 0.4, 0.3]) + F.harmonics(E2, n, [0.5, 0.4, 0.3]) + F.harmonics(B2, n, [0.25, 0.15]), 2.5), 1800.0) * gain


def i_shield_hit():
    # A standing shield taking a blow (Ryan, 1 October: a sound for a hit on a shield). The
    # blow never reaches the metal: a thump, the field's own hum flaring and settling over
    # six tenths, an electric snap, static gated as the field strains, and a shimmer of E4
    # partials dying. The third cut: bigger thump, louder flare, longer.
    n = n_of(0.6)
    hum = field_hum(n) * F.env_pts(n, [(0.0, 0.0), (0.005, 1.0), (0.1, 0.85), (0.6, 0.0)]) * 0.85
    tear_n = n_of(0.18)
    static = F.bp(F.noise(tear_n), 500.0, 3500.0) * (0.5 + 0.5 * np.sign(np.sin(2.0 * math.pi * 90.0 * t_of(tear_n)))) * F.env_ad(tear_n, 0.001, 0.06) * 0.55
    shimmer = F.knock([E4, E4 * 1.5, E4 * 2.0], [0.08, 0.06, 0.04], [1.0, 0.5, 0.3], noise_gain=0.0) * 0.3
    b = mix(F.burst(0.035, 1500.0, 9000.0, decay=0.007) * 1.0, hum, static, shimmer,
            F.thud(180.0, 60.0, 0.22, click=0.9, drive=3.0, body_gain=1.3) * 1.0)
    return room(heft(b, 0.9, 3.5), decay=0.16, mix=0.12)


def i_shield_break():
    # The shield failing, with the oomph the third cut asks of every shield sound: the
    # electric crack, the field tearing as gated static for a quarter of a second, the
    # discharge as a blast of its own with a boom tail, the shards scattering longer, the
    # field's hum flickering out, and the ground taking the weight.
    tear_n = n_of(0.25)
    tear = F.bp(F.noise(tear_n), 400.0, 3000.0) * (0.5 + 0.5 * np.sign(np.sin(2.0 * math.pi * 90.0 * t_of(tear_n)))) * F.env_ad(tear_n, 0.001, 0.08) * 0.9
    b = mix(F.burst(0.05, 2000.0, 14000.0, decay=0.008) * 1.1, F.body(900.0, 220.0, 0.06, click=1.0, drive=3.0) * 0.7, tear)
    b = at(b, mix(F.explosion(0.6, 36.0, 0.7, debris=1), boom_tail(0.5, 0.5)), 0.04)
    for k in range(14):
        pch = F.RNG.uniform(0.7, 1.6)
        shard = F.knock([2100.0 * pch, 3300.0 * pch], [0.018, 0.012], [0.6, 0.3], noise_gain=0.3) * 0.4
        b = at(b, shard, 0.05 + k * F.RNG.uniform(0.015, 0.04))
    n = n_of(0.5)
    flicker = np.ones(n)
    for when in (0.08, 0.17, 0.24, 0.33, 0.39):
        flicker[n_of(when):n_of(when + 0.03)] = 0.1
    b = at(b, field_hum(n, 0.6) * flicker * F.env_pts(n, [(0.0, 0.0), (0.02, 1.0), (0.3, 0.6), (0.5, 0.0)]), 0.1)
    b = at(b, F.thud(120.0, 40.0, 0.4, click=0.4, drive=2.5, body_gain=1.3) * 0.8, 0.08)
    return room(heft(b, 0.5), decay=0.2, mix=0.14)


def i_kill(maker):
    # A machine scrapped (Ryan, 1 October: a big deal, and it should sound like one; the
    # third cut: more). Near three seconds: the blast with its boom; hydraulics letting go;
    # the frame groaning on E1 as it gives; a second, lower blast; the magazine going up as
    # a third; the maker's plate falling in pieces for two seconds; sparks twice; the hull
    # hitting the ground as the biggest thud of the set with a slab of plate under it and a
    # boom of its own; steam, and the last pieces.
    n = n_of(1.6)
    buf = big_blast(1.5, 24.0, 1.1, debris=3)
    buf = at(buf, F.hydraulic(0.8, 3000.0, 400.0, 0.45), 0.08)
    groan = F.lp(F.sat(mix(F.saws(E1, n, (0.99, 1.0, 1.01)) * 0.6, F.harmonics(E1, n, [1.0, 0.5, 0.3])), 2.5), 900.0)
    groan = groan * F.env_pts(n, [(0.0, 0.0), (0.12, 0.5), (0.8, 0.45), (1.6, 0.0)]) * 0.5
    buf = at(buf, heft(groan, 0.4), 0.1)
    buf = at(buf, big_blast(1.2, 22.0, 0.95, debris=2), 0.4)
    buf = at(buf, big_blast(0.9, 30.0, 0.75, debris=2), 0.95)
    for k, when in enumerate([0.5, 0.62, 0.78, 0.95, 1.15, 1.4, 1.65, 1.9]):
        buf = at(buf, plate(maker, 0.7) * (1.0 - 0.1 * k), when + F.RNG.uniform(0.0, 0.02))
    for when in (0.42, 1.0):
        sn = n_of(0.35)
        sparks = F.bp(F.noise(sn), 2000.0, 8000.0) * (F.RNG.uniform(0.0, 1.0, sn) > 0.96) * F.env_ad(sn, 0.005, 0.12) * 0.5
        buf = at(buf, sparks, when)
    ground = mix(F.thud(110.0, 32.0, 0.7, click=1.1, drive=3.5, body_gain=1.8),
                 F.knock([120.0, 190.0, 310.0], [0.09, 0.07, 0.05], [1.0, 0.6, 0.3], noise_gain=0.3) * 0.6, boom_tail(0.9, 0.6))
    buf = at(buf, heft(ground, 0.6), 1.35)
    steam = F.hp(F.noise(n_of(0.9)), 2500.0) * F.env_ad(n_of(0.9), 0.02, 0.25) * 0.22
    buf = at(buf, steam, 1.4)
    for when in (2.1, 2.35):
        buf = at(buf, F.knock([F.RNG.uniform(500.0, 900.0), F.RNG.uniform(1200.0, 2000.0)], [0.03, 0.02], [0.6, 0.3]) * 0.3, when)
    return room(buf, decay=0.3, mix=0.12)


# ---------------------------------------------------------------- the iron: weapons by shape
#
# The third cut (Ryan, 1 October): over-the-top Doom energy, drawn out, since each die spent
# is deliberate and nothing fires in a row; rewarding and powerful. Every blow gets its heft
# (the speaker's band) and a boom tail, and runs longer. Nothing glides in pitch.

def armour_hit(gain=0.9):
    return heft(mix(F.thud(150.0, 45.0, 0.3, click=0.7, drive=3.5, body_gain=1.3), plate("minerva", 0.5),
                    F.burst(0.08, 250.0, 5000.0, decay=0.02) * 0.6), 0.5) * gain


def w_barrel():
    # A slug cannon, a railgun: one heavy report with a boom behind it, the shell cracking
    # the air, the hit as a blast of its own, the gun's recoil hydraulics, then the breech
    # cycling well after (Ryan, 1 October: it was too close): the case out, the breech closing.
    front = mix(F.thud(300.0, 50.0, 0.3, click=1.6, drive=5.0, body_gain=1.6), F.burst(0.1, 300.0, 6000.0, decay=0.025) * 1.1,
                F.bp(F.noise(n_of(0.02)), 2500.0, 10000.0) * F.env_ad(n_of(0.02), 0.0002, 0.004) * 1.0, boom_tail(0.7, 0.7))
    b = heft(front, 0.6)
    b = at(b, F.burst(0.03, 3000.0, 12000.0, decay=0.006) * 0.6, 0.06)
    b = at(b, mix(armour_hit(1.0), F.explosion(0.6, 36.0, 0.6, debris=2)), 0.14)
    b = at(b, F.hydraulic(0.3, 3000.0, 600.0, 0.4), 0.2)
    b = at(b, mix(F.knock([900.0, 1500.0], [0.012, 0.008], [1.0, 0.4], noise_gain=0.5) * 0.6, F.hydraulic(0.14, 2500.0, 700.0, 0.3)), 0.62)
    b = at(b, F.knock([520.0, 900.0], [0.014, 0.009], [1.0, 0.5], noise_gain=0.35) * 0.7, 0.76)
    return room(b, decay=0.25, mix=0.16)


def w_twin():
    # Twin autoguns, at a deliberate cadence now: three double-taps a quarter second apart,
    # each shot heavier, the action clacking, each pair landing on armour, the casings
    # tinkling down after, a boom under the lot.
    buf = np.zeros(1)
    for pair in range(3):
        t0 = pair * 0.26
        for j in range(2):
            buf = at(buf, heft(F.shot(F.RNG.uniform(0.82, 0.9)), 0.6) * 1.0, t0 + j * 0.05, 1.0 - 0.04 * pair)
        buf = at(buf, F.knock([1400.0, 2300.0], [0.008, 0.005], [0.6, 0.3], noise_gain=0.4) * 0.4, t0 + 0.09)
        buf = at(buf, armour_hit(0.6 if pair < 2 else 0.95), t0 + 0.12)
    buf = at(buf, boom_tail(0.6, 0.45), 0.55)
    for k in range(6):
        buf = at(buf, F.knock([F.RNG.uniform(2400.0, 3600.0), F.RNG.uniform(4000.0, 6000.0)], [0.012, 0.008], [0.6, 0.3], noise_gain=0.3) * 0.25, 0.85 + k * F.RNG.uniform(0.04, 0.08))
    return room(buf, decay=0.22, mix=0.16)


def w_rack():
    # A missile rack: four launches, each an ignition thud and a whoosh (a noise band
    # opening, not a pitch), the salvo in flight for most of a second, then four impacts
    # landing close together as blasts of their own and the air rolling after them.
    buf = np.zeros(1)
    for k in range(4):
        n = n_of(0.2)
        t = t_of(n)
        whoosh = F.lp_var(F.hp(F.noise(n), 300.0), 500.0 + 3500.0 * (t / 0.2)) * F.env_pts(n, [(0.0, 0.0), (0.02, 1.0), (0.12, 0.6), (0.2, 0.0)]) * 0.6
        ign = mix(F.thud(220.0, 60.0, 0.15, click=1.0, drive=3.5, body_gain=1.3) * 0.7, F.knock([260.0, 520.0], [0.025, 0.015], [1.0, 0.5], noise_gain=0.4) * 0.5)
        buf = at(buf, heft(mix(ign, whoosh), 0.5), k * 0.12)
    fn = n_of(0.7)
    ft = t_of(fn)
    flight = F.lp_var(F.hp(F.noise(fn), 400.0), 3000.0 - 2200.0 * (ft / 0.7)) * F.env_pts(fn, [(0.0, 0.0), (0.05, 0.6), (0.55, 0.3), (0.7, 0.0)]) * 0.35
    buf = at(buf, flight, 0.4)
    for k in range(4):
        buf = at(buf, big_blast(0.7, 34.0, 0.75, debris=1), 1.15 + k * 0.09, 1.0 - 0.08 * k)
    buf = at(buf, boom_tail(0.9, 0.5), 1.45)
    return room(buf, decay=0.28, mix=0.16)


def w_blade():
    # A chainsaw claw: the motor revving up in loudness with its filter opening (no glide),
    # the teeth a flutter on it, three bites each a rip through plate with the plate knocked
    # and sparks off it, the motor dying away after. Over a second now.
    n = n_of(1.1)
    t = t_of(n)
    motor = F.lp_var(F.sat(F.saws(95.0, n, (0.99, 1.0, 1.01)) + np.sin(2.0 * math.pi * 190.0 * t) * 0.4, 2.5),
                     np.interp(t, [0.0, 0.15, 0.9, 1.1], [800.0, 2200.0, 2000.0, 700.0]))
    teeth = 0.75 + 0.25 * np.sign(np.sin(2.0 * math.pi * 23.0 * t))
    load = F.env_pts(n, [(0.0, 0.0), (0.15, 1.0), (0.2, 0.55), (0.3, 0.95), (0.45, 0.55), (0.55, 0.95), (0.7, 0.5), (0.8, 0.9), (0.95, 0.7), (1.1, 0.0)])
    b = heft(motor * teeth * load * 0.55, 0.4)

    def rip(dur):
        m = n_of(dur)
        return F.bp(F.noise(m), 600.0, 5000.0) * (0.5 + 0.5 * np.sign(np.sin(2.0 * math.pi * 58.0 * t_of(m)))) * F.env_ad(m, 0.001, dur * 0.3) * 0.9

    for k, when in enumerate([0.18, 0.43, 0.68]):
        b = at(b, rip(0.18 + 0.04 * k), when)
        b = at(b, heft(mix(F.thud(170.0, 50.0, 0.22, click=0.8, drive=3.0, body_gain=1.3), plate("minerva", 0.45)), 0.5), when + 0.02, 0.85 + 0.1 * k)
        sn = n_of(0.2)
        b = at(b, F.bp(F.noise(sn), 2500.0, 9000.0) * (F.RNG.uniform(0.0, 1.0, sn) > 0.97) * F.env_ad(sn, 0.002, 0.07) * 0.5, when + 0.03)
    return room(b, decay=0.2, mix=0.14)


def w_blunt(layers=()):
    # A blunt impact (Ryan, 2 October: one sound for the plow and the knuckles alike; these
    # are multi-ton war machines, so a blunt blow is a car hitting a wall). The mass coming:
    # a low rumble rising with the hydraulics driving; the impact: the biggest thud of the
    # blows, the crumple (a dense run of plate knocks over a sixth of a second, saturated in
    # the speaker's band), a broadband crack, glass going; then the boom behind it, debris,
    # a rattle settling, the hydraulics venting, and a little of the wet under it for the
    # flesh it hit.
    n = n_of(0.3)
    t = t_of(n)
    rumble = heft(F.lp(F.sat(F.lp(F.noise(n), 150.0) * 2.5, 3.0), 900.0) * (t / 0.3) ** 2 * 0.7, 0.8)
    b = mix(rumble, F.hydraulic(0.3, 700.0, 2800.0, 0.45))
    crumple = np.zeros(n_of(0.22))
    when = 0.0
    while when < 0.17:
        kn = F.knock([F.RNG.uniform(300.0, 900.0), F.RNG.uniform(900.0, 2500.0)], [0.012, 0.007], [1.0, 0.5], noise_gain=0.6)
        crumple = at(crumple, kn, when, F.RNG.uniform(0.5, 1.0) * (1.0 - when * 2.5))[:len(crumple)]
        when += F.RNG.uniform(0.005, 0.011)
    crumple = heft(crumple, 0.9, 4.0)
    glass = np.zeros(n_of(0.3))
    for k in range(10):
        glass = at(glass, F.knock([F.RNG.uniform(3000.0, 5000.0), F.RNG.uniform(5000.0, 8000.0)], [0.01, 0.006], [0.6, 0.3], noise_gain=0.3) * 0.3, 0.02 + k * F.RNG.uniform(0.012, 0.03))[:len(glass)]
    impact = mix(F.thud(120.0, 30.0, 0.6, click=1.5, drive=4.5, body_gain=1.8), crumple, glass,
                 F.burst(0.12, 150.0, 6000.0, decay=0.03) * 1.0, boom_tail(0.8, 0.7),
                 F.burst(0.06, 150.0, 1400.0, decay=0.02) * 0.5)   # the wet, under it
    b = at(b, heft(impact, 0.7), 0.3)
    for k, when in enumerate([0.55, 0.68, 0.84]):
        b = at(b, mix(F.body(F.RNG.uniform(220.0, 340.0), 90.0, 0.07, click=0.6) * 0.5, F.knock([F.RNG.uniform(500.0, 1000.0), F.RNG.uniform(1200.0, 2200.0)], [0.03, 0.02], [0.6, 0.3]) * 0.4), when, 1.0 - 0.2 * k)
    b = at(b, F.ratchet(7, 0.35, 700.0, 0.4, jitter=0.3), 0.75)
    b = at(b, F.hydraulic(0.3, 3000.0, 600.0, 0.3), 0.7)
    # the layers a `sound` list puts on the landing (the first word is the blow)
    if "plasma" in layers:
        b = at(b, plasma_splash(0.9), 0.33)
    return room(b, decay=0.25, mix=0.16)


def w_laser():
    # A laser carbine, drawn out: the capacitor charging (a buzz on E3 growing in loudness,
    # never in pitch, with its ticks quickening), the dump's crack, then the beam held on
    # the plate for six tenths: flat on B2 with B1 under it, saturated, a slow flutter on its
    # loudness, the plate burning under it the whole while (a sizzle, pops as it spits, each
    # bigger), until the plate gives with a thunk and the capacitor cuts, the burn dying away.
    cn = n_of(0.18)
    ct = t_of(cn)
    charge = F.lp(F.sat(F.saws(E3, cn, (0.993, 1.0, 1.007)), 3.0), 2500.0) * (ct / 0.18) ** 2 * 0.5
    for when in np.arange(0.0, 0.17, 0.025):
        charge = at(charge, F.tick_click() * 0.8, float(when), 0.3 + 3.0 * when)[:cn]
    b = charge
    dur = 0.6
    n = n_of(dur)
    t = t_of(n)
    beam = F.lp(F.sat(F.saws(B2, n, (0.99, 1.0, 1.01)) + F.harmonics(B2 * 2, n, [0.5, 0.4, 0.3, 0.2]) + F.harmonics(61.74, n, [0.8, 0.6, 0.4]), 3.5), 3500.0)
    flutter = 0.86 + 0.14 * np.sin(2.0 * math.pi * 31.0 * t)
    beam = F.bp(beam, 200.0, 4000.0) * flutter * F.env_pts(n, [(0.0, 0.0), (0.003, 1.0), (0.55, 0.9), (0.6, 0.0)])
    crack = F.bp(F.noise(n_of(0.03)), 1500.0, 9000.0) * F.env_ad(n_of(0.03), 0.0002, 0.006) * 1.2
    b = at(b, heft(mix(crack, beam * 0.9), 0.5), 0.18)
    sizzle = F.hp(F.noise(n_of(0.95)), 3000.0) * F.env_pts(n_of(0.95), [(0.0, 0.0), (0.02, 1.0), (0.6, 0.9), (0.95, 0.0)]) * 0.3
    b = at(b, mix(sizzle, F.thud(140.0, 50.0, 0.2, click=0.4, drive=2.5) * 0.6), 0.22)
    for k, when in enumerate([0.22, 0.34, 0.45, 0.55, 0.64, 0.72]):
        pop = mix(F.body(600.0, 180.0, 0.05, click=1.0, drive=3.0) * 0.7, F.burst(0.04, 800.0, 6000.0, decay=0.01) * 0.7)
        b = at(b, pop, when, 0.5 + 0.1 * k)
    gives = heft(mix(F.thud(150.0, 45.0, 0.3, click=0.8, drive=3.5, body_gain=1.3), plate("minerva", 0.5), F.burst(0.08, 300.0, 4000.0, decay=0.02) * 0.6), 0.5)
    b = at(b, gives, 0.76)
    b = at(b, F.burst(0.02, 2000.0, 9000.0, decay=0.004) * 0.6, 0.78)   # the capacitor cuts
    return room(b, decay=0.22, mix=0.14)


def w_plasma():
    # The Arsenal's plasma, which runs hot, with a windup (Ryan, 1 October) of four tenths:
    # the sub hum on E1 growing in loudness with its filter opening (never a pitch), ticks
    # quickening, the crackle thickening, the vowel surfacing; then the whoomp with its slow
    # front and a boom behind it, the hit a hot splash with a blast in it, steam after.
    wind = 0.4
    wn = n_of(wind)
    wt = t_of(wn)
    charge = F.lp_var(F.sat(F.harmonics(E1, wn, [1.0, 0.7, 0.5, 0.4, 0.3]), 3.0), 150.0 + 1100.0 * (wt / wind) ** 2) * (wt / wind) ** 1.6 * 0.8
    dens = 0.995 - 0.035 * (wt / wind) ** 2
    crack_up = F.bp(F.noise(wn), 2000.0, 8000.0) * (F.RNG.uniform(0.0, 1.0, wn) > dens) * (wt / wind) * 0.55
    voice_up = F.choir([0, 7], wn, gain=0.35, vowel="oh", octave=2)[:wn] * (wt / wind) ** 2
    b = mix(charge, crack_up, voice_up)
    for when in np.arange(0.0, 0.38, 0.04):
        b = at(b, F.tick_click() * 0.7, float(when), 0.2 + 2.0 * when)[:wn]
    b = heft(b, 0.4)
    n = n_of(0.4)
    whoomp = F.lp(F.noise(n), 500.0) * F.env_pts(n, [(0.0, 0.0), (0.02, 1.0), (0.14, 0.5), (0.4, 0.0)]) * 1.5
    hum = F.lp(F.sat(F.harmonics(E1, n, [1.0, 0.7, 0.5, 0.3]), 3.0), 400.0) * F.env_ad(n, 0.01, 0.12) * 0.7
    voice = F.choir([0, 7], n, gain=0.4, vowel="oh", octave=2)[:n] * F.env_ad(n, 0.01, 0.1)
    crackle = F.bp(F.noise(n), 2000.0, 8000.0) * (F.RNG.uniform(0.0, 1.0, n) > 0.975) * F.env_ad(n, 0.02, 0.12) * 0.5
    b = at(b, heft(mix(whoomp, hum, voice, crackle, boom_tail(0.6, 0.6)), 0.6), wind)
    b = at(b, plasma_splash(), wind + 0.09)
    return room(b, decay=0.25, mix=0.16)


def plasma_splash(gain=1.0):
    """The hot splash where plasma lands: a burst, a small blast, steam. The plasma's own hit,
    and the layer a `sound` list puts on another blow (the Gravity Knuckles: blunt, plasma)."""
    splash = mix(F.burst(0.25, 300.0, 3500.0, decay=0.07) * 0.9, F.explosion(0.5, 40.0, 0.6, debris=0),
                 F.hp(F.noise(n_of(0.6)), 2500.0) * F.env_ad(n_of(0.6), 0.003, 0.16) * 0.35)
    n = n_of(0.5)
    crackle = F.bp(F.noise(n), 2000.0, 8000.0) * (F.RNG.uniform(0.0, 1.0, n) > 0.975) * F.env_ad(n, 0.02, 0.15) * 0.5
    return heft(mix(splash, crackle), 0.5) * gain


def w_dish_shield():
    # The deflector raised, a power-up with oomph (Ryan, 1 October): the clack, the field's
    # hum snapping on at B1 with E2 and B2 over it, a crack as it seals and a thud as it
    # locks, a second thud as the plates close, static crackling off the new field for half
    # a second, then the field ringing on for a second and a half with a slow breath on its
    # loudness and a shimmer of E4 partials over it fading first. No relay cuts it.
    dur = 1.5
    n = n_of(dur)
    t = t_of(n)
    breath = 0.85 + 0.15 * np.sin(2.0 * math.pi * 6.5 * t)
    hum = field_hum(n) * breath * F.env_pts(n, [(0.0, 0.0), (0.008, 1.0), (0.3, 0.85), (0.8, 0.5), (dur, 0.0)])
    shimmer = F.lp(F.harmonics(E4, n, [1.0, 0.4, 0.2]), 5000.0) * F.env_pts(n, [(0.0, 0.0), (0.02, 1.0), (0.4, 0.4), (0.9, 0.0)]) * 0.16
    sn = n_of(0.5)
    crackle = F.bp(F.noise(sn), 1500.0, 7000.0) * (F.RNG.uniform(0.0, 1.0, sn) > 0.975) * F.env_ad(sn, 0.005, 0.15) * 0.45
    b = mix(clack(0.9), hum * 0.8, shimmer, crackle, F.burst(0.06, 1500.0, 9000.0, decay=0.014) * 0.8)
    b = at(b, heft(mix(F.thud(200.0, 60.0, 0.25, click=1.0, drive=3.5, body_gain=1.4), plate("minerva", 0.4)), 0.5), 0.02)
    b = at(b, heft(mix(F.thud(180.0, 55.0, 0.2, click=0.8, drive=3.0, body_gain=1.2) * 0.8, plate("minerva", 0.35)), 0.5), 0.3)
    return room(heft(b, 0.3), decay=0.16, mix=0.12)


def w_dish_coil():
    # An overcharge coil, the buff, with oomph: the bank charging for half a second as a
    # buzz on E3 growing in loudness with its filter opening (never in pitch), ticking
    # faster, then the discharge: the crack, the body, a boom, the clack, and the charge
    # held in the machine as a hum on E2 with a tremolo dying over six tenths.
    n = n_of(0.55)
    t = t_of(n)
    buzz = F.lp_var(F.sat(F.saws(E3, n, (0.993, 1.0, 1.007)) + np.sin(2.0 * math.pi * E3 * 2 * t) * 0.3, 3.0), 900.0 + 2500.0 * (t / 0.55) ** 2) * (t / 0.55) ** 2 * 0.7
    tick = np.zeros(n)
    when = 0.0
    while when < 0.53:
        tick = at(tick, F.tick_click() * 0.9, when, 0.3 + 2.0 * when)[:n]
        when += 0.05 - 0.035 * (when / 0.55)
    b = heft(mix(buzz, tick), 0.4)
    disc = mix(F.burst(0.06, 1500.0, 12000.0, decay=0.01) * 1.2, F.body(700.0, 200.0, 0.08, click=1.0, drive=3.5) * 0.9,
               F.thud(170.0, 55.0, 0.25, click=1.0, drive=3.5, body_gain=1.3) * 0.8, clack(1.0), boom_tail(0.45, 0.5))
    b = at(b, heft(disc, 0.6), 0.55)
    hn = n_of(0.6)
    ht = t_of(hn)
    held = F.lp(F.sat(F.harmonics(E2, hn, [1.0, 0.6, 0.4, 0.3]), 2.5), 1400.0) * (0.75 + 0.25 * np.sign(np.sin(2.0 * math.pi * 11.0 * ht))) * F.env_pts(hn, [(0.0, 0.0), (0.02, 0.6), (0.3, 0.4), (0.6, 0.0)])
    b = at(b, held, 0.6)
    return room(b, decay=0.18, mix=0.12)


# ---------------------------------------------------------------- the iron: footfalls

def s_tracked():
    b = mix(F.thud(140.0, 45.0, 0.14, click=0.5, drive=2.5, body_gain=1.1), F.ratchet(5, 0.1, 900.0, 0.5, jitter=0.2) * 0.6)
    return room(b, decay=0.12, mix=0.1)


def s_legged():
    return F.step()


def s_wheeled():
    n = n_of(0.14)
    grit = F.bp(F.noise(n), 500.0, 3000.0) * F.env_pts(n, [(0.0, 0.0), (0.02, 1.0), (0.1, 0.5), (0.14, 0.0)]) * 0.5
    b = mix(grit, F.knock([180.0, 320.0], [0.03, 0.02], [1.0, 0.5], noise_gain=0.2) * 0.5, F.body(220.0, 100.0, 0.06, click=0.2) * 0.3)
    return room(b, decay=0.1, mix=0.1)


def s_flyer():
    n = n_of(0.2)
    t = t_of(n)
    pas = F.lp_var(F.hp(F.noise(n), 600.0), 1200.0 + 2500.0 * np.sin(math.pi * t / 0.2)) * F.env_pts(n, [(0.0, 0.0), (0.06, 1.0), (0.14, 0.8), (0.2, 0.0)]) * 0.5
    return room(pas, decay=0.1, mix=0.1)


# ---------------------------------------------------------------- the rift

def cold_hum(dur, gain=0.5):
    """Grave-light: a flat high hum at B4 and E5 with a tremolo on its loudness, and static."""
    n = n_of(dur)
    t = t_of(n)
    h = F.lp(F.harmonics(B4, n, [1.0, 0.3, 0.15]) + F.harmonics(E5, n, [0.6, 0.2]) * 0.6, 5000.0)
    trem = 0.7 + 0.3 * np.sign(np.sin(2.0 * math.pi * 7.0 * t))
    static = F.bp(F.noise(n), 2000.0, 9000.0) * 0.18
    return (h * trem + static) * gain


def bone_crack(gain=1.0):
    k = F.knock([1900.0, 2700.0, 4100.0], [0.02, 0.014, 0.01], [1.0, 0.6, 0.4], noise_gain=0.6)
    w = F.knock([330.0, 600.0], [0.03, 0.02], [1.0, 0.5], noise_gain=0.0) * 0.6
    snap = F.burst(0.02, 2000.0, 9000.0, decay=0.004) * 0.8
    return mix(k, w, snap) * gain


def r_undead_hit():
    # A ghoul's claw: dry bone, a brittle crack, a rattle after, little weight.
    b = mix(bone_crack(0.9), F.thud(160.0, 55.0, 0.16, click=0.3, drive=2.5) * 0.45)
    b = at(b, F.ratchet(4, 0.08, 1700.0, 0.5, jitter=0.3) * 0.5, 0.04)
    return room(b, decay=0.14, mix=0.14)


def r_undead_heavy():
    # The necromancer's hex bolt, the colossus's weight: grave-light held cold for a third
    # of a second, then the crack and the ground taking it.
    b = cold_hum(0.3, 0.55) * F.env_pts(n_of(0.3), [(0.0, 0.0), (0.02, 1.0), (0.25, 0.9), (0.3, 0.0)])
    b = at(b, mix(bone_crack(1.0), F.thud(130.0, 38.0, 0.4, click=0.8, drive=3.5, body_gain=1.4)), 0.28)
    b = at(b, F.ratchet(6, 0.14, 1500.0, 0.5, jitter=0.3) * 0.4, 0.34)
    return room(b, decay=0.2, mix=0.14)


def r_undead_spawn():
    # The Risen arriving: a rattle of bone gathering, the cold hum swelling under it, the
    # boom, and the rattle settling.
    n = n_of(1.3)
    t = t_of(n)
    b = cold_hum(1.3, 0.5) * (t / 1.3) ** 2.2
    when = 0.0
    k = 0
    while when < 0.95:
        b = at(b, F.knock([F.RNG.uniform(1200.0, 2400.0), F.RNG.uniform(2600.0, 4200.0)], [0.012, 0.008], [1.0, 0.5], noise_gain=0.5) * 0.45, when, 0.3 + 0.7 * when)
        when += 0.11 - 0.06 * (when / 0.95) + F.RNG.uniform(0.0, 0.02)
        k += 1
    b = at(b, F.explosion(0.6, 34.0, 0.8, debris=0), 1.02)
    b = at(b, F.ratchet(7, 0.25, 1600.0, 0.5, jitter=0.3) * 0.4, 1.1)
    return room(b, decay=0.3, mix=0.14)


def whoomp(dur=0.3, cut=450.0, gain=1.0):
    n = n_of(dur)
    return F.lp(F.noise(n), cut) * F.env_pts(n, [(0.0, 0.0), (0.018, 1.0), (dur * 0.4, 0.5), (dur, 0.0)]) * gain


def embers(dur=0.45, gain=0.5):
    n = n_of(dur)
    return F.bp(F.noise(n), 2500.0, 9000.0) * (F.RNG.uniform(0.0, 1.0, n) > 0.98) * F.env_ad(n, 0.01, dur * 0.4) * gain


def roar(dur, gain=0.6):
    n = n_of(dur)
    return F.lp(F.sat(F.lp(F.noise(n), 260.0) * 3.0, 3.0), 900.0) * gain


def r_demonic_hit():
    # A brute's haymaker: a fist of slag, the thud with a whoomp of fire on it, embers after.
    b = mix(F.thud(150.0, 42.0, 0.32, click=1.0, drive=3.5, body_gain=1.3), whoomp(0.28, 500.0, 1.0), F.burst(0.08, 250.0, 4000.0, decay=0.02) * 0.6)
    b = at(b, embers(0.4, 0.5), 0.05)
    return room(b, decay=0.18, mix=0.14)


def r_demonic_heavy():
    # The hellcaster's firebolt, lobbed: the whoosh of it coming (a band opening), then the
    # fireball: the blast with a roar in it, embers and a hiss after.
    n = n_of(0.3)
    t = t_of(n)
    lob = F.lp_var(F.hp(F.noise(n), 250.0), 400.0 + 2600.0 * (t / 0.3) ** 1.5) * F.env_pts(n, [(0.0, 0.0), (0.05, 0.7), (0.26, 1.0), (0.3, 0.0)]) * 0.55
    b = at(lob, mix(F.explosion(0.75, 30.0, 0.95, debris=1), roar(0.45, 0.7) * F.env_ad(n_of(0.45), 0.005, 0.15)), 0.28)
    b = at(b, embers(0.5, 0.6), 0.36)
    b = at(b, F.hp(F.noise(n_of(0.4)), 3000.0) * F.env_ad(n_of(0.4), 0.01, 0.12) * 0.25, 0.4)
    return room(b, decay=0.25, mix=0.16)


def r_demonic_spawn():
    # The Horde arriving: a furnace door, the roar swelling behind it, the door's iron
    # knocking, the boom, the crackle after. Loud and telegraphed.
    n = n_of(1.3)
    t = t_of(n)
    b = roar(1.3, 0.7) * (t / 1.3) ** 1.8
    b = at(b, F.knock([180.0, 330.0, 540.0], [0.06, 0.04, 0.025], [1.0, 0.6, 0.3], noise_gain=0.4) * 0.6, 0.2)
    b = at(b, F.knock([180.0, 330.0, 540.0], [0.06, 0.04, 0.025], [1.0, 0.6, 0.3], noise_gain=0.4) * 0.6, 0.62)
    b = at(b, mix(F.explosion(0.7, 30.0, 0.9, debris=1), whoomp(0.4, 400.0, 0.9)), 1.02)
    b = at(b, embers(0.6, 0.6), 1.1)
    return room(b, decay=0.3, mix=0.14)


def gate(x, hz, duty=0.5, depth=1.0):
    t = t_of(len(x))
    g = (np.sign(np.sin(2.0 * math.pi * hz * t) - (1.0 - 2.0 * duty)) + 1.0) * 0.5
    return x * (1.0 - depth + depth * g)


def chorus_cluster(dur, gain=0.5, semis=(0, 1, 6)):
    """The Chorus: the choir on a cluster (a minor second and a tritone over E), crushed
    and gated as if the feed cannot hold it."""
    n = n_of(dur)
    v = F.choir(list(semis), n, gain=1.0, vowel="oh", octave=2)[:n]
    v = F.crush(v, bits=6, hold=4)
    return F.lp(v, 5000.0) * gain


def r_eldritch_hit():
    # A spawn's lash, a sweep: a geometric whip, a crushed rip gated hard with its halves
    # flipped, a cold impact, two crushed ticks after.
    n = n_of(0.14)
    rip = gate(F.crush(F.bp(F.noise(n), 500.0, 6000.0), bits=5, hold=6), 70.0, 0.5) * F.env_ad(n, 0.001, 0.05) * 0.8
    half = n // 2
    rip[half:] *= -1.0
    b = mix(rip, F.body(900.0, 220.0, 0.05, click=1.0, drive=3.0) * 0.6)
    b = at(b, F.thud(140.0, 45.0, 0.22, click=0.5, drive=3.0) * 0.7, 0.03)
    b = at(b, F.glitch_perc() * 0.6, 0.1)
    b = at(b, F.glitch_perc() * 0.45, 0.16)
    return room(b, decay=0.14, mix=0.12)


def r_eldritch_heavy():
    # The whisperer's murmur, a word that hurts: the choir on the cluster, gated at 28 Hz
    # and crushed, cut dead, then the impact as a crushed thud and the console flinching:
    # two of its own ticks. It talks to your dice.
    n = n_of(0.5)
    word = gate(chorus_cluster(0.5, 0.8), 28.0, 0.45) * F.env_pts(n, [(0.0, 0.0), (0.02, 1.0), (0.42, 0.9), (0.44, 0.0)])
    b = at(word, mix(F.crush(F.thud(150.0, 45.0, 0.3, click=1.0, drive=3.5, body_gain=1.2), bits=6, hold=3), F.glitch_perc() * 0.7), 0.44)
    b = at(b, mix(F.tick_click() * 1.2, F.tone(float(F.CHATTER_PITCHES[2]), 0.015, 0.4, edge=0.6)), 0.6)
    b = at(b, mix(F.tick_click() * 1.2, F.tone(float(F.CHATTER_PITCHES[5]), 0.015, 0.4, edge=0.6)), 0.66)
    return room(b, decay=0.12, mix=0.1)


def r_eldritch_spawn():
    # The Chorus arriving: the cluster swelling under a stutter that quickens (a rate, not
    # a pitch), static, the boom with a crushed tail, and a scatter of crushed ticks.
    n = n_of(1.3)
    t = t_of(n)
    v = chorus_cluster(1.3, 0.7) * (t / 1.3) ** 2.0
    rate = 6.0 + 34.0 * (t / 1.3) ** 2
    ph = 2.0 * math.pi * np.cumsum(rate) / F.SR
    g = (np.sign(np.sin(ph)) + 1.0) * 0.5
    b = v * (0.35 + 0.65 * g)
    b = mix(b, F.bp(F.noise(n), 1000.0, 7000.0) * (t / 1.3) ** 3 * 0.4)
    b = at(b, mix(F.explosion(0.6, 34.0, 0.8, debris=0), F.crush(F.lp(F.noise(n_of(0.5)), 500.0), bits=5, hold=8) * F.env_ad(n_of(0.5), 0.005, 0.15) * 0.5), 1.02)
    for k in range(5):
        b = at(b, F.glitch_perc() * 0.5, 1.12 + k * F.RNG.uniform(0.03, 0.07))
    return room(b, decay=0.3, mix=0.14)


def r_reveal():
    # A boss revealed: the feed tears (a hard cut of static), the band's red rules (two
    # knocks), the picture's afterimages (three crushed ticks), the name resolving out of
    # a scramble (chatter), the order typing in (ticks), a low E1 swell under it all.
    n = n_of(1.3)
    t = t_of(n)
    swell = F.lp(F.sat(F.harmonics(E1, n, [1.0, 0.7, 0.5, 0.35, 0.25]), 2.5), 700.0) * F.env_pts(n, [(0.0, 0.0), (0.4, 0.6), (1.0, 0.7), (1.3, 0.0)]) * 0.5
    b = mix(swell, F.burst(0.08, 200.0, 9000.0, decay=0.02) * 1.0)
    b = at(b, F.knock([420.0, 700.0], [0.016, 0.01], [1.0, 0.5], noise_gain=0.3) * 0.7, 0.06)
    b = at(b, F.knock([380.0, 640.0], [0.016, 0.01], [1.0, 0.5], noise_gain=0.3) * 0.7, 0.11)
    for k in range(3):
        b = at(b, F.glitch_perc() * 0.6, 0.18 + k * 0.05)
    b = at(b, F.chatter(0.4, 0.9), 0.35)
    for k in range(6):
        b = at(b, mix(key(0.7, 1.1), F.tick_click() * 0.6), 0.8 + k * 0.045)
    return room(b, decay=0.25, mix=0.14)


# ---------------------------------------------------------------- the red

def d_contact():
    # The alarm, tuned: the horn a power chord on E2 and B2, the klaxon the console's own
    # tone at B4 twice, the thud bigger.
    n = n_of(0.62)
    t = t_of(n)
    horn = mix(F.saws(E2, n, (0.992, 1.0, 1.008)) * 0.7, F.saws(B2, n, (0.994, 1.0, 1.006)) * 0.4,
               F.harmonics(E2 * 2, n, [0.6, 0.5, 0.4, 0.3, 0.2, 0.15]) * 0.5, np.sin(2.0 * math.pi * E1 * t) * 0.35)
    horn = F.lp(F.sat(horn, 3.0), 2200.0) * F.env_ad(n, 0.06, 0.5, curve=2.0)
    env = np.ones(n)
    env[-n_of(0.05):] = np.linspace(1.0, 0.0, n_of(0.05))
    b = mix(horn * env, F.thud(100.0, 38.0, 0.35, click=0.3, drive=2.5, body_gain=1.3) * 0.55)
    b = at(b, F.tone(B4, 0.12, edge=0.6), 0.05, 0.3)
    b = at(b, F.tone(B4, 0.12, edge=0.6), 0.3, 0.3)
    return room(b, decay=0.3, mix=0.14)


def d_engage():
    # The dive: no drive spinning down (that was a glide). The feed's floor rises (a filter
    # opening), the console arms with a key under each count-in beep at B3, the beeps
    # closing in, the last long at E4, until the cut.
    n = n_of(2.2)
    t = t_of(n)
    wash = F.lp_var(F.noise(n), 400.0 + 3000.0 * (t / 2.2) ** 2) * (t / 2.2) ** 1.5 * 0.8
    floor = F.lp(F.sat(F.harmonics(E2, n, [1.0, 0.5, 0.3, 0.2]), 2.0), 600.0) * F.env_pts(n, [(0.0, 0.0), (0.3, 0.4), (2.0, 0.6), (2.2, 0.0)]) * 0.4
    b = mix(wash, floor)
    for k, when in enumerate([0.9, 1.45, 1.8, 2.02]):
        last = k == 3
        b = at(b, mix(key(1.0), F.tone(E4 if last else B3, 0.16 if last else 0.07, 0.5)), when, 0.45)
    return room(b, decay=0.3, mix=0.12)


def d_gate_hit():
    # The gate struck: the explosion, the structure groaning on B1 with E1 under it, three
    # knocks of the plate.
    n = n_of(1.8)
    t = t_of(n)
    groan = mix(F.saws(61.74, n, (0.99, 1.0, 1.01)) * 0.6, F.harmonics(E1, n, [1.0, 0.5, 0.3]) * 0.5) * (1.0 + 0.1 * np.sin(2.0 * math.pi * 1.3 * t)) * F.env_ad(n, 0.15, 0.6) * 0.5
    groan = F.lp(F.sat(groan, 2.5), 1100.0)
    b = mix(F.explosion(1.6, 22.0, 1.3, debris=5), groan)
    for k, when in enumerate([0.6, 0.85, 1.2]):
        b = at(b, F.knock([120.0, 190.0, 310.0], [0.09, 0.07, 0.05], [1.0, 0.6, 0.3], noise_gain=0.3) * 0.4, when, gain=1.0 - 0.25 * k)
    return room(b, decay=0.45, mix=0.18)


def d_victory():
    # The stand held: the power chord on E, and CARE logging it: the console works, a key,
    # and the all-clear as two flat tones, B3 up to E4.
    n = n_of(1.8)
    chord = np.zeros(n)
    for f, a in [(E2, 1.0), (B2, 0.7), (E3, 0.5), (B3, 0.3)]:
        chord += F.saws(f, n, (0.995, 1.0, 1.005)) * a
    chord += np.sin(2.0 * math.pi * E1 * t_of(n)) * 0.3
    chord = F.lp(F.sat(chord, 2.0), 2400.0) * F.env_ad(n, 0.12, 0.7, curve=2.5)
    b = mix(chord, F.thud(120.0, 40.0, 0.5, click=0.5, drive=3.0) * 0.6)
    b = at(b, F.chatter(0.25, 0.5), 0.5)
    b = at(b, mix(key(0.9), F.tone(B3, 0.14, 0.45)), 0.8)
    b = at(b, F.tone(E4, 0.3, 0.45), 1.0)
    return room(b, decay=0.5, mix=0.18)


def d_defeat():
    # The line broken: the hum on E2 flickering out, the last thing to fall, then the
    # reconstruction losing the signal: a crushed burst of static and two console ticks
    # into silence.
    n = n_of(2.2)
    hum = F.lp(F.sat(F.harmonics(E2 / 2, n, [1.0, 0.6, 0.5, 0.3, 0.25, 0.2]) + F.saws(E2, n, (0.99, 1.0, 1.01)) * 0.3, 2.5), 900.0)
    flicker = np.ones(n)
    for when in (0.35, 0.62, 0.8, 0.98, 1.08, 1.16):
        a, b_ = n_of(when), n_of(when + F.RNG.uniform(0.02, 0.06))
        flicker[a:b_] = 0.15
    hum = hum * flicker * F.env_pts(n, [(0.0, 0.0), (0.05, 1.0), (0.9, 0.8), (1.3, 0.0), (2.2, 0.0)])
    b = at(hum, F.explosion(0.8, 28.0, 0.9, debris=2), 1.35)
    b = at(b, F.crush(F.burst(0.12, 300.0, 8000.0, decay=0.04), bits=5, hold=7) * 0.7, 1.85)
    b = at(b, mix(F.tick_click() * 1.2, F.tone(float(F.CHATTER_PITCHES[1]), 0.02, 0.35, edge=0.6)), 2.0)
    b = at(b, mix(F.tick_click() * 1.0, F.tone(float(F.CHATTER_PITCHES[0]), 0.03, 0.3, edge=0.6)), 2.08)
    return room(b, decay=0.5, mix=0.18)


# ---------------------------------------------------------------- the voice

LINES = {"target_locked": "target locked", "weapons_online": "weapons online", "incoming": "incoming", "shield_up": "shield up",
         "machine_lost": "machine lost", "nominal": "all systems nominal", "gate_breached": "gate breached", "line_held": "line held"}


def v_line(voice, key_):
    # The console speaking (Ryan's references, 2 October: Bitching Betty, the Adjutant, VEGA):
    # the channel opens on a click, the line, and the channel closes on a tick of static.
    b = thock(0.6, 1.1)
    b = at(b, speech.say(LINES[key_], voice), 0.06)
    return at(b, F.glitch_perc() * 0.25, len(b) / F.SR + 0.02)


# ---------------------------------------------------------------- the set

# name -> (builder, the shipped name it stands beside or replaces, the level it is written at)
NEW = {
    "ui_tap": (c_ui_tap, "ui_tap", "ui_tap"), "ui_back": (c_ui_back, "ui_back", "ui_back"), "plot": (c_plot, "plot", "plot"),
    "die_pick": (c_die_pick, "die_pick", "die_pick"), "die_drop": (c_die_drop, "die_drop", "die_drop"),
    "die_roll": (c_die_roll, "die_roll", "die_roll"), "die_lock": (c_die_lock, "die_lock", "die_lock"),
    "resolve": (c_resolve, "resolve", "resolve"), "intent": (c_intent, None, "die_lock"),
    "w_barrel": (w_barrel, "gunfire", "gunfire"), "w_twin": (w_twin, "gunfire", "gunfire"), "w_rack": (w_rack, "cannon", "cannon"),
    "w_blade": (w_blade, "slash", "slash"), "w_blunt": (w_blunt, "slam", "slam"), "w_blunt_plasma": ((lambda: w_blunt(("plasma",))), "slam", "slam"), "w_laser": (w_laser, "laser", "laser"), "w_plasma": (w_plasma, "laser", "laser"),
    "w_dish_shield": (w_dish_shield, "shield_up", "shield_up"), "w_dish_coil": (w_dish_coil, "shield_up", "shield_up"),
    "step_tracked": (s_tracked, "step", "step"), "step_legged": (s_legged, "step", "step"),
    "step_wheeled": (s_wheeled, "step", "step"), "step_flyer": (s_flyer, "step", "step"),
    "foe_undead_hit": (r_undead_hit, "slash", "slash"), "foe_undead_heavy": (r_undead_heavy, "slam", "slam"), "spawn_undead": (r_undead_spawn, "spawn", "spawn"),
    "foe_demonic_hit": (r_demonic_hit, "slash", "slash"), "foe_demonic_heavy": (r_demonic_heavy, "slam", "slam"), "spawn_demonic": (r_demonic_spawn, "spawn", "spawn"),
    "foe_eldritch_hit": (r_eldritch_hit, "slash", "slash"), "foe_eldritch_heavy": (r_eldritch_heavy, "slam", "slam"), "spawn_eldritch": (r_eldritch_spawn, "spawn", "spawn"),
    "reveal": (r_reveal, None, "contact"), "shield_hit": (i_shield_hit, "block", "block"), "shield_break": (i_shield_break, "shield_break", "shield_break"),
    "contact": (d_contact, "contact", "contact"), "engage": (d_engage, "engage", "engage"), "gate_hit": (d_gate_hit, "gate_hit", "gate_hit"),
    "victory": (d_victory, "victory", "victory"), "defeat": (d_defeat, "defeat", "defeat"),
}
for v in speech.VOICES:
    for k in LINES:
        NEW["v_%s_%s" % (v, k)] = ((lambda v=v, k=k: v_line(v, k)), None, "contact")   # speech sits at the contact's level: a call over the music, not a console tone (2 October: too faint to judge at the lock's)
for m in MAKERS:
    NEW["hit_" + m] = ((lambda m=m: i_hit(m)), "hit", "hit")
    NEW["block_" + m] = ((lambda m=m: i_block(m)), "block", "block")
    NEW["kill_" + m] = ((lambda m=m: i_kill(m)), "kill", "kill")


# The third cut's levels (Ryan, 1 October: not understated, more oomph): a sketch is written
# this many dB over the level its shipped sound plays at. Said on the page; Ryan's to pull back.
BOOST = {"console": 4.0, "blow": 2.0, "shield": 2.0, "kill": 1.0}


def boost(name):
    if name in ("ui_tap", "ui_back", "plot", "die_pick", "die_drop", "die_roll", "die_lock", "resolve", "intent"):
        return BOOST["console"]
    if name.startswith("v_"):
        return 0.0
    if name.startswith("w_dish") or name in ("shield_hit", "shield_break"):
        return BOOST["shield"]
    if name.startswith("w_"):
        return BOOST["blow"]
    if name.startswith("kill_"):
        return BOOST["kill"]
    return 0.0


def shipped(name):
    F.seed(name)
    return F.SOUNDS[name]()


def new(name):
    F.seed("fx_" + name)
    return NEW[name][0]()


def level(x, db):
    return x * 10.0 ** ((db - F.loudness(x)) / 20.0)


def write(name, x):
    os.makedirs(OUT, exist_ok=True)
    wav = os.path.join(OUT, name + ".wav")
    pcm = (np.clip(F.limit(x), -1.0, 1.0) * 32767.0).astype("<i2")
    with wave.open(wav, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(F.SR)
        w.writeframes(pcm.tobytes())
    m4a = os.path.join(OUT, name + ".mp4")
    # afconvert on the Mac; ffmpeg where there is none (a cloud session). ffmpeg's own AAC
    # encoder smears the first 30 ms of a transient at 128 kbps (measured 1 October: 12 dB
    # signal to noise on a tap's front against Apple's 33), and these are files of fronts,
    # so it runs at 256, which brings it within a few dB of Apple at 128.
    for cmd in (["afconvert", "-f", "mp4f", "-d", "aac", "-b", "128000", "-q", "127", wav, m4a],
                ["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-c:a", "aac", "-b:a", "256k", "-movflags", "+faststart", m4a]):
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            break
        except (OSError, subprocess.CalledProcessError) as e:
            err = e
    else:
        print("  (no aac for %s: %s)" % (name, err))
    return wav


def tail(x, seconds=0.25):
    return np.concatenate([x, np.zeros(n_of(seconds))])


def read_music(name):
    with wave.open(os.path.join(F.OUT, name + ".wav"), "rb") as w:
        return np.frombuffer(w.readframes(w.getnframes()), "<i2") / 32767.0


def bed(name, from_bar, bars, bpm):
    x = read_music(name)
    a = n_of(from_bar * 4.0 * 60.0 / bpm)
    b = n_of((from_bar + bars) * 4.0 * 60.0 / bpm)
    y = np.array(x[a:b])
    fade = n_of(0.5)
    y[-fade:] *= np.linspace(1.0, 0.0, fade)
    return y


def lay(base, events, which):
    """`events`: (seconds, shipped name, new name, dB offset). `which` is 'now' or 'new'."""
    buf = np.array(base)
    for when, now_name, new_name, db in events:
        name = now_name if which == "now" else new_name
        if name is None:
            continue
        if which == "now" or name not in NEW:
            x = shipped(name)
            lv = F.LEVELS[name]
        else:
            x = new(name)
            lv = F.LEVELS[NEW[name][2]] + boost(name)
        buf = at(buf, level(x, lv + db), when)
    return buf


ROUND = [   # a round of the skirmish: the die, the blows, the enemy's turn, the end (twelve bars; the third cut's sounds are longer)
    (0.4, "die_pick", "die_pick", 0.0), (0.9, "die_drop", "die_drop", -6.0), (1.4, "die_roll", "die_roll", 0.0), (2.4, "die_lock", "die_lock", 0.0),
    (3.0, "die_pick", "die_pick", 0.0), (3.5, "die_drop", "die_drop", -6.0), (4.0, "die_roll", "die_roll", 0.0), (5.0, "die_lock", "die_lock", 0.0),
    (5.8, "resolve", "resolve", -4.0),
    (7.4, "gunfire", "w_twin", 0.0), (8.2, "kill", "kill_minerva", 0.0),
    (11.0, "laser", "w_laser", 0.0),
    (12.8, "cannon", "w_rack", 0.0), (14.4, "kill", "kill_minerva", 0.0), (14.5, "kill", "kill_minerva", -2.0),
    (17.4, None, "intent", 0.0), (17.7, None, "intent", 0.0),
    (18.2, "slash", "foe_undead_hit", 0.0), (18.3, "block", "block_minerva", -3.0),
    (19.4, "slam", "foe_demonic_heavy", 0.0), (19.7, "hit", "hit_kestrel", -3.0),
    (20.6, "slash", "foe_undead_hit", 0.0), (20.7, "block", "shield_hit", -3.0),
    (21.8, "shield_up", "w_dish_shield", 0.0), (23.4, "vent", "vent", 0.0), (24.1, "shield_up", "w_dish_coil", -3.0),
    (25.8, "victory", "victory", 0.0),
]
CONTACT = [   # the map: footfalls, a foe into the line, the alarm, the dive, the cut, the spawns, the gate, a boss
    (0.0, "step", "step_tracked", 0.0), (0.35, "step", "step_tracked", 0.0), (0.7, "step", "step_legged", 0.0), (1.05, "step", "step_wheeled", 0.0), (1.4, "step", "step_flyer", 0.0),
    (2.0, "arrival", "arrival", 0.0), (2.6, "contact", "contact", 0.0), (3.62, "contact", "contact", -2.0),
    (4.4, "engage", "engage", 0.0), (6.6, "cut", "cut", 0.0),
    (7.6, "spawn", "spawn_undead", 0.0), (9.3, "gate_hit", "gate_hit", 0.0), (9.65, "spawn", "spawn_demonic", 0.0),
    (11.6, "spawn", "spawn_eldritch", 0.0), (13.4, None, "reveal", 0.0),
    (15.6, "defeat", "defeat", 0.0),
]
RIFT = [   # each family: its arrival, its blow, its heavy blow
    (0.3, "spawn", "spawn_undead", 0.0), (2.0, "slash", "foe_undead_hit", 0.0), (2.9, "slam", "foe_undead_heavy", 0.0),
    (4.8, "spawn", "spawn_demonic", 0.0), (6.5, "slash", "foe_demonic_hit", 0.0), (7.4, "slam", "foe_demonic_heavy", 0.0),
    (9.3, "spawn", "spawn_eldritch", 0.0), (11.0, "slash", "foe_eldritch_hit", 0.0), (11.9, "slam", "foe_eldritch_heavy", 0.0),
]
IRON = [   # the shapes, a shield taking a blow and breaking, then the makers struck: a hit, a block, a kill each
    (0.3, "gunfire", "w_barrel", 0.0), (2.2, "gunfire", "w_twin", 0.0), (4.0, "cannon", "w_rack", 0.0), (6.6, "slash", "w_blade", 0.0),
    (8.2, "slam", "w_blunt", 0.0), (9.8, "laser", "w_laser", 0.0), (11.6, "laser", "w_plasma", 0.0), (13.6, "shield_up", "w_dish_shield", 0.0),
    (15.6, "shield_up", "w_dish_coil", -3.0), (17.4, "block", "shield_hit", -3.0), (18.4, "shield_break", "shield_break", 0.0),
] + [(20.2 + k * 3.4 + d, now, new_, db) for k, m in enumerate(MAKERS) for d, now, new_, db in
     [(0.0, "hit", "hit_" + m, 0.0), (0.6, "block", "block_" + m, -3.0), (1.2, "kill", "kill_" + m, 0.0)]]


def render_sequences(manifest):
    hold = bed("music_hold_the_line", 8, 8, 104)        # the power chords, bar nine on
    night = bed("music_night_shift", 8, 8, 94)
    crossing = bed("music_crossing", 4, 10, 126)
    for key_, base, events, note in [
        ("round", bed("music_hold_the_line", 8, 12, 104), ROUND, "a round over Hold The Line's power chords"),
        ("contact", night, CONTACT, "the map's turn and the handover over Night Shift"),
        ("rift", crossing, RIFT, "the three families over The Crossing"),
        ("iron", bed("music_hold_the_line", 8, 16, 104), IRON, "the shapes, a shield struck and broken, then the five makers struck, over Hold The Line"),
    ]:
        for which in ("now", "new"):
            F.seed("fx_seq_" + key_ + which)
            x = lay(base, events, which)   # the beds are the shipped files, already at their levels
            name = "seq_%s_%s" % (key_, which)
            write(name, tail(x, 0.5))
            manifest["sequences"].append({"name": name, "seconds": round(len(x) / F.SR, 2), "note": note, "which": which})
            print("  %-18s %5.1f s" % (name, len(x) / F.SR))


def render_singles(manifest):
    done = set()
    for name, (fn, beside, lv) in NEW.items():
        x = level(new(name), F.LEVELS[lv] + boost(name))
        write("new_" + name, tail(x))
        manifest["singles"].append({"name": "new_" + name, "beside": beside, "seconds": round(len(x) / F.SR, 2), "boost_db": boost(name)})
        print("  new_%-18s %5.2f s" % (name, len(x) / F.SR))
        if beside and beside not in done:
            done.add(beside)
            y = level(shipped(beside), F.LEVELS[beside])
            write("now_" + beside, tail(y))
            manifest["singles"].append({"name": "now_" + beside, "seconds": round(len(y) / F.SR, 2)})


def main(argv):
    which = argv[0] if argv else "all"
    os.makedirs(OUT, exist_ok=True)
    if os.path.exists(PAGE):
        with open(PAGE) as src, open(os.path.join(OUT, "index.html"), "w") as dst:
            dst.write(src.read())
    path = os.path.join(OUT, "manifest.json")
    manifest = {"singles": [], "sequences": []}
    if which != "all" and os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
        manifest[which] = []
    if which in ("singles", "all"):
        print("singles")
        render_singles(manifest)
    if which in ("sequences", "all"):
        print("sequences")
        render_sequences(manifest)
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
