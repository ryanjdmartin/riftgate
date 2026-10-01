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

OUT = os.path.join(F.OUT_SKETCH, "fx")
PAGE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fx_page.html")

# E-tuned console pitches.
E1, E2, B2, E3, G3, B3, E4, G4, B4, E5 = 41.2, 82.41, 123.47, 164.81, 196.0, 246.94, 329.63, 392.0, 493.88, 659.26

n_of, t_of = F.n_of, F.t_of
mix, at, room = F.mix, F.at, F.room


# ---------------------------------------------------------------- the console

def key(weight=1.0, pitch=1.0):
    """A membrane key under glass: a damped tuk with a dry front. No relay spring."""
    k = F.knock([640.0 * pitch, 1180.0 * pitch], [0.007, 0.004], [1.0, 0.5], noise_gain=0.5)
    return F.bp(k, 300.0, 5000.0) * 0.9 * weight


def reply(f, dur, gain=0.5):
    return F.tone(f, dur, gain, edge=0.35)


def c_ui_tap():
    return mix(key(1.0), reply(B3, 0.045, 0.4))


def c_ui_back():
    return mix(key(0.9, 0.85), reply(G3, 0.06, 0.4))


def c_plot():
    # The route taken: the console works, the key, the reply, and a second softer dot (the
    # route is two ends).
    b = F.chatter(0.1, 0.7)
    b = at(b, mix(key(1.0), reply(E4, 0.06, 0.45)), 0.11)
    return at(b, reply(E4, 0.04, 0.25), 0.2)


def c_die_pick():
    # Lifted from its socket: the key, a plate lift, a short high reply.
    b = mix(key(1.1, 1.1), F.knock([900.0, 1500.0], [0.01, 0.006], [1.0, 0.4], noise_gain=0.3) * 0.5)
    return at(b, reply(E4, 0.04, 0.35), 0.01)


def c_die_drop():
    # Seated: no tone. A damped knock, a little body, the socket's click.
    b = mix(F.knock([300.0, 520.0, 840.0], [0.02, 0.014, 0.01], [1.0, 0.6, 0.3], noise_gain=0.4) * 0.9,
            F.body(260.0, 110.0, 0.05, click=0.4) * 0.45)
    return at(b, key(0.6, 0.9), 0.012)


def c_die_roll():
    # The readout's digit scramble: ticks at the flip rate, thinning, each with a flat
    # tone off any scale; the console under load under it; then the brackets collapse
    # shut, two knocks closing, and the number settles on a low reply.
    dur = 0.46
    n = n_of(dur)
    hum = F.lp(F.sat(F.saws(E2, n, (0.996, 1.0, 1.004)), 1.5), 700.0) * F.env_pts(n, [(0.0, 0.0), (0.03, 0.35), (0.3, 0.3), (0.42, 0.0)]) * 0.35
    b = hum
    when = 0.0
    k = 0
    while when < 0.3:
        tk = F.tick_click() * 1.4
        tn = F.tone(float(F.RNG.choice(F.CHATTER_PITCHES)), 0.012, edge=0.6) * F.RNG.uniform(0.3, 0.7)
        b = at(b, mix(tk, tn), when)
        when += 0.028 + 0.004 * k
        k += 1
    b = at(b, F.knock([480.0, 860.0], [0.012, 0.008], [1.0, 0.5], noise_gain=0.5) * 0.8, 0.33)
    b = at(b, F.knock([380.0, 640.0], [0.014, 0.009], [1.0, 0.5], noise_gain=0.5) * 0.9, 0.355)
    return at(b, reply(G3, 0.12, 0.6), 0.37)


def c_die_lock():
    # The corners snap on: the key, then a heavier key with the latch's casing, the reply,
    # and a short hold hum.
    b = key(0.8)
    b = at(b, mix(key(1.2, 0.8), F.knock([420.0, 700.0], [0.016, 0.01], [1.0, 0.5], noise_gain=0.2) * 0.6, reply(B3, 0.08, 0.5)), 0.04)
    n = n_of(0.16)
    hold = F.lp(F.harmonics(E3, n, [1.0, 0.4, 0.2]), 1200.0) * F.env_pts(n, [(0.0, 0.0), (0.02, 0.3), (0.12, 0.25), (0.16, 0.0)]) * 0.3
    return at(b, hold, 0.06)


def c_resolve():
    # The plan committed: the console works, the lines lock in one by one (three keys), the
    # heavy latch, the reply low and long.
    b = F.chatter(0.14, 0.8)
    for k, when in enumerate([0.12, 0.16, 0.2]):
        b = at(b, key(0.9 + 0.15 * k, 1.0 - 0.08 * k), when)
    b = at(b, mix(F.thud(170.0, 50.0, 0.22, click=1.0, drive=3.5) * 0.75,
                  F.knock([330.0, 560.0, 900.0], [0.03, 0.02, 0.012], [1.0, 0.5, 0.3], noise_gain=0.3) * 0.5), 0.25)
    return room(at(b, reply(E3, 0.22, 0.55), 0.27), decay=0.16, mix=0.12)


def c_intent():
    # The brackets collapsing onto a foe's intent as its number settles: a crushed tick
    # (the console reading the other side) and a small knock.
    return mix(F.glitch_perc() * 0.5, F.knock([520.0, 910.0], [0.008, 0.005], [1.0, 0.4], noise_gain=0.3) * 0.5)


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
    _, _, _, body_gain, drive = PLATE[maker]
    b = mix(F.thud(150.0, 45.0, 0.3, click=1.0, drive=drive, body_gain=body_gain),
            F.burst(0.08, 250.0, 5000.0, decay=0.02) * 0.7,
            plate(maker, 0.55), F.metal(0.12, 0.9))
    return room(b, decay=0.16, mix=0.14)


def i_block(maker):
    _, _, _, body_gain, _ = PLATE[maker]
    b = mix(plate(maker, 0.95), F.burst(0.05, 500.0, 3500.0, decay=0.015) * 0.5,
            F.body(240.0, 100.0, 0.08, click=0.5) * 0.5 * body_gain, F.metal(0.25, 1.3))
    return room(b, decay=0.12, mix=0.12)


def i_kill(maker):
    buf = F.explosion(1.2, 26.0, 1.0, debris=2)
    buf = at(buf, F.hydraulic(0.5, 2500.0, 500.0, 0.35), 0.1)
    for k, when in enumerate([0.3, 0.42, 0.58, 0.8]):
        buf = at(buf, plate(maker, 0.6) * (1.0 - 0.2 * k), when)
    return buf


# ---------------------------------------------------------------- the iron: weapons by shape

def armour_hit(gain=0.9):
    return mix(F.thud(150.0, 45.0, 0.25, click=0.5, drive=3.0), plate("minerva", 0.4)) * gain


def w_barrel():
    # A slug cannon, a railgun: one heavy report, the breech cycling after, the hit.
    front = mix(F.thud(300.0, 60.0, 0.12, click=1.4, drive=4.0, body_gain=1.3), F.burst(0.06, 400.0, 6000.0, decay=0.015) * 0.9,
                F.bp(F.noise(n_of(0.02)), 2500.0, 10000.0) * F.env_ad(n_of(0.02), 0.0002, 0.004) * 0.9)
    b = at(front, armour_hit(0.85), 0.09)
    b = at(b, mix(F.knock([900.0, 1500.0], [0.012, 0.008], [1.0, 0.4], noise_gain=0.5) * 0.5, F.hydraulic(0.12, 2500.0, 700.0, 0.25)), 0.16)
    return room(b, decay=0.22, mix=0.16)


def w_twin():
    # Twin autoguns: three double-taps, the action clacking, the last pair landing.
    buf = np.zeros(1)
    for pair in range(3):
        t0 = pair * 0.115
        for j in range(2):
            buf = at(buf, F.shot(F.RNG.uniform(0.95, 1.05)) * 0.85, t0 + j * 0.042, 1.0 - 0.05 * pair)
        buf = at(buf, F.knock([1400.0, 2300.0], [0.008, 0.005], [0.6, 0.3], noise_gain=0.4) * 0.35, t0 + 0.07)
    buf = at(buf, armour_hit(0.75), 0.3)
    return room(buf, decay=0.2, mix=0.16)


def w_rack():
    # A missile rack: four launches, each an ignition tonk and a whoosh (a noise band
    # opening, not a pitch), then four impacts landing close together.
    buf = np.zeros(1)
    for k in range(4):
        n = n_of(0.18)
        t = t_of(n)
        whoosh = F.lp_var(F.hp(F.noise(n), 300.0), 500.0 + 3500.0 * (t / 0.18)) * F.env_pts(n, [(0.0, 0.0), (0.02, 1.0), (0.12, 0.6), (0.18, 0.0)]) * 0.5
        tonk = F.knock([260.0, 520.0], [0.025, 0.015], [1.0, 0.5], noise_gain=0.4) * 0.5
        buf = at(buf, mix(tonk, whoosh), k * 0.065)
    for k in range(4):
        buf = at(buf, F.explosion(0.45, 40.0, 0.55, debris=0), 0.42 + k * 0.055, 1.0 - 0.1 * k)
    return room(buf, decay=0.25, mix=0.16)


def w_blade():
    # A chainsaw claw: a motor at one speed (no glide), teeth as a flutter on it, the load
    # dipping where it bites, the rip through plate, the plate knocked.
    n = n_of(0.36)
    t = t_of(n)
    motor = F.lp(F.sat(F.saws(95.0, n, (0.99, 1.0, 1.01)) + np.sin(2.0 * math.pi * 190.0 * t) * 0.4, 2.5), 1800.0)
    teeth = 0.75 + 0.25 * np.sign(np.sin(2.0 * math.pi * 23.0 * t))
    load = F.env_pts(n, [(0.0, 0.0), (0.02, 1.0), (0.1, 1.0), (0.13, 0.55), (0.2, 0.9), (0.3, 0.8), (0.36, 0.0)])
    b = motor * teeth * load * 0.5
    rip = F.bp(F.noise(n_of(0.16)), 600.0, 5000.0) * (0.5 + 0.5 * np.sign(np.sin(2.0 * math.pi * 58.0 * t_of(n_of(0.16))))) * F.env_ad(n_of(0.16), 0.001, 0.05) * 0.8
    b = at(b, rip, 0.11)
    b = at(b, mix(F.thud(170.0, 50.0, 0.2, click=0.7, drive=3.0), plate("minerva", 0.4)), 0.13, 0.9)
    return room(b, decay=0.18, mix=0.14)


def w_laser():
    # A laser carbine: the capacitor dump's crack, a flat beam at B2 for a tenth of a
    # second, and the hit a burn rather than a thud: a pop and a sizzle on the plate.
    n = n_of(0.11)
    beam = F.lp(F.sat(F.saws(B2, n, (0.99, 1.0, 1.01)) + F.harmonics(B2 * 2, n, [0.5, 0.4, 0.3, 0.2]), 3.0), 3500.0)
    beam = F.bp(beam, 250.0, 4000.0) * F.env_pts(n, [(0.0, 0.0), (0.003, 1.0), (0.09, 0.9), (0.11, 0.0)])
    crack = F.bp(F.noise(n_of(0.03)), 1500.0, 9000.0) * F.env_ad(n_of(0.03), 0.0002, 0.006)
    b = mix(crack, beam * 0.8)
    pop = mix(F.body(600.0, 180.0, 0.05, click=1.0, drive=3.0) * 0.7, F.burst(0.04, 800.0, 6000.0, decay=0.01) * 0.7)
    sizzle = F.hp(F.noise(n_of(0.3)), 3000.0) * F.env_ad(n_of(0.3), 0.002, 0.09) * 0.3
    b = at(b, mix(pop, sizzle, F.thud(140.0, 50.0, 0.18, click=0.3, drive=2.5) * 0.5), 0.04)
    return room(b, decay=0.2, mix=0.14)


def w_plasma():
    # The Arsenal's plasma, which runs hot: a whoomp with a slow front, a sub hum at E1
    # under it, a hint of a vowel (the manual written as liturgy), crackle, and the hit a
    # hot splash.
    n = n_of(0.3)
    t = t_of(n)
    whoomp = F.lp(F.noise(n), 450.0) * F.env_pts(n, [(0.0, 0.0), (0.018, 1.0), (0.12, 0.5), (0.3, 0.0)]) * 1.2
    hum = F.lp(F.sat(F.harmonics(E1, n, [1.0, 0.7, 0.5, 0.3]), 3.0), 400.0) * F.env_ad(n, 0.01, 0.1) * 0.6
    voice = F.choir([0, 7], n_of(0.3), gain=0.35, vowel="oh", octave=2)[:n] * F.env_ad(n, 0.01, 0.08)
    crackle = F.bp(F.noise(n), 2000.0, 8000.0) * (F.RNG.uniform(0.0, 1.0, n) > 0.975) * F.env_ad(n, 0.02, 0.1) * 0.5
    b = mix(whoomp, hum, voice, crackle)
    splash = mix(F.burst(0.2, 300.0, 3500.0, decay=0.06) * 0.8, F.thud(160.0, 48.0, 0.2, click=0.4, drive=3.0) * 0.6,
                 F.hp(F.noise(n_of(0.35)), 2500.0) * F.env_ad(n_of(0.35), 0.003, 0.1) * 0.3)
    b = at(b, splash, 0.07)
    return room(b, decay=0.22, mix=0.16)


def w_dish_shield():
    # The deflector raised: the key, the field's hum snapping on at B1 with E2 over it, a
    # crack as it seals, a short bed, then the field settles and the relay cuts it.
    n = n_of(0.34)
    hum = F.lp(F.sat(F.harmonics(61.74, n, [1.0, 0.8, 0.5, 0.4, 0.3]) + F.harmonics(E2, n, [0.5, 0.4, 0.3]), 2.5), 1800.0)
    hum = hum * F.env_pts(n, [(0.0, 0.0), (0.008, 1.0), (0.26, 0.7), (0.29, 0.7), (0.3, 0.0)])
    b = mix(F.relay(0.8), hum * 0.7, F.burst(0.05, 1500.0, 9000.0, decay=0.012) * 0.6)
    b = at(b, mix(F.thud(200.0, 60.0, 0.2, click=0.9, drive=3.0) * 0.9, plate("minerva", 0.35)), 0.02)
    b = at(b, F.relay(0.7, 0.9), 0.3)
    return room(b, decay=0.14, mix=0.12)


def w_dish_coil():
    # An overcharge coil: the bank charging as a buzz at E3 growing in loudness, never in
    # pitch, then the discharge's crack and the key.
    n = n_of(0.32)
    t = t_of(n)
    buzz = F.lp(F.sat(F.saws(E3, n, (0.993, 1.0, 1.007)) + np.sin(2.0 * math.pi * E3 * 2 * t) * 0.3, 3.0), 2500.0) * (t / 0.32) ** 2 * 0.6
    tick = np.zeros(n)
    for when in np.arange(0.0, 0.3, 0.03):
        tick = at(tick, F.tick_click() * 0.8, float(when), 0.3 + 2.0 * when)[:n]
    b = mix(buzz, tick)
    b = at(b, mix(F.burst(0.05, 1500.0, 12000.0, decay=0.008) * 1.0, F.body(700.0, 200.0, 0.06, click=0.8, drive=3.0) * 0.7, F.relay(0.9)), 0.32)
    return room(b, decay=0.16, mix=0.12)


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


# ---------------------------------------------------------------- the set

# name -> (builder, the shipped name it stands beside or replaces, the level it is written at)
NEW = {
    "ui_tap": (c_ui_tap, "ui_tap", "ui_tap"), "ui_back": (c_ui_back, "ui_back", "ui_back"), "plot": (c_plot, "plot", "plot"),
    "die_pick": (c_die_pick, "die_pick", "die_pick"), "die_drop": (c_die_drop, "die_drop", "die_drop"),
    "die_roll": (c_die_roll, "die_roll", "die_roll"), "die_lock": (c_die_lock, "die_lock", "die_lock"),
    "resolve": (c_resolve, "resolve", "resolve"), "intent": (c_intent, None, "die_lock"),
    "w_barrel": (w_barrel, "gunfire", "gunfire"), "w_twin": (w_twin, "gunfire", "gunfire"), "w_rack": (w_rack, "cannon", "cannon"),
    "w_blade": (w_blade, "slash", "slash"), "w_laser": (w_laser, "laser", "laser"), "w_plasma": (w_plasma, "laser", "laser"),
    "w_dish_shield": (w_dish_shield, "shield_up", "shield_up"), "w_dish_coil": (w_dish_coil, "shield_up", "shield_up"),
    "step_tracked": (s_tracked, "step", "step"), "step_legged": (s_legged, "step", "step"),
    "step_wheeled": (s_wheeled, "step", "step"), "step_flyer": (s_flyer, "step", "step"),
    "foe_undead_hit": (r_undead_hit, "slash", "slash"), "foe_undead_heavy": (r_undead_heavy, "slam", "slam"), "spawn_undead": (r_undead_spawn, "spawn", "spawn"),
    "foe_demonic_hit": (r_demonic_hit, "slash", "slash"), "foe_demonic_heavy": (r_demonic_heavy, "slam", "slam"), "spawn_demonic": (r_demonic_spawn, "spawn", "spawn"),
    "foe_eldritch_hit": (r_eldritch_hit, "slash", "slash"), "foe_eldritch_heavy": (r_eldritch_heavy, "slam", "slam"), "spawn_eldritch": (r_eldritch_spawn, "spawn", "spawn"),
    "reveal": (r_reveal, None, "contact"),
    "contact": (d_contact, "contact", "contact"), "engage": (d_engage, "engage", "engage"), "gate_hit": (d_gate_hit, "gate_hit", "gate_hit"),
    "victory": (d_victory, "victory", "victory"), "defeat": (d_defeat, "defeat", "defeat"),
}
for m in MAKERS:
    NEW["hit_" + m] = ((lambda m=m: i_hit(m)), "hit", "hit")
    NEW["block_" + m] = ((lambda m=m: i_block(m)), "block", "block")
    NEW["kill_" + m] = ((lambda m=m: i_kill(m)), "kill", "kill")


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
    try:
        subprocess.run(["afconvert", "-f", "mp4f", "-d", "aac", "-b", "128000", "-q", "127", wav, m4a], check=True, capture_output=True)
    except (OSError, subprocess.CalledProcessError) as e:
        print("  (no aac for %s: %s)" % (name, e))
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
            lv = F.LEVELS[NEW[name][2]]
        buf = at(buf, level(x, lv + db), when)
    return buf


ROUND = [   # a round of the skirmish: the die, the blows, the enemy's turn, the end
    (0.4, "die_pick", "die_pick", 0.0), (0.8, "die_drop", "die_drop", -6.0), (1.2, "die_roll", "die_roll", 0.0), (1.9, "die_lock", "die_lock", 0.0),
    (2.3, "die_pick", "die_pick", 0.0), (2.7, "die_drop", "die_drop", -6.0), (3.1, "die_roll", "die_roll", 0.0), (3.8, "die_lock", "die_lock", 0.0),
    (4.5, "resolve", "resolve", -4.0),
    (5.3, "gunfire", "w_twin", 0.0), (5.6, "kill", "kill_minerva", 0.0),
    (7.0, "laser", "w_laser", 0.0),
    (8.2, "cannon", "w_rack", 0.0), (8.75, "kill", "kill_minerva", 0.0), (8.82, "kill", "kill_minerva", -2.0),
    (10.3, None, "intent", 0.0), (10.5, None, "intent", 0.0),
    (10.8, "slash", "foe_undead_hit", 0.0), (10.9, "block", "block_minerva", -3.0),
    (12.0, "slam", "foe_demonic_heavy", 0.0), (12.3, "hit", "hit_kestrel", -3.0),
    (13.6, "shield_up", "w_dish_shield", 0.0), (14.3, "vent", "vent", 0.0), (15.0, "shield_up", "w_dish_coil", -3.0),
    (16.2, "victory", "victory", 0.0),
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
IRON = [   # the shapes, then the makers struck: a hit, a block, a kill each
    (0.3, "gunfire", "w_barrel", 0.0), (1.2, "gunfire", "w_twin", 0.0), (2.1, "cannon", "w_rack", 0.0), (3.4, "slash", "w_blade", 0.0),
    (4.3, "laser", "w_laser", 0.0), (5.1, "laser", "w_plasma", 0.0), (6.0, "shield_up", "w_dish_shield", 0.0), (6.7, "shield_up", "w_dish_coil", -3.0),
] + [(8.0 + k * 2.0 + d, now, new_, db) for k, m in enumerate(MAKERS) for d, now, new_, db in
     [(0.0, "hit", "hit_" + m, 0.0), (0.45, "block", "block_" + m, -3.0), (0.9, "kill", "kill_" + m, 0.0)]]


def render_sequences(manifest):
    hold = bed("music_hold_the_line", 8, 8, 104)        # the power chords, bar nine on
    night = bed("music_night_shift", 8, 8, 94)
    crossing = bed("music_crossing", 4, 10, 126)
    for key_, base, events, note in [
        ("round", hold, ROUND, "a round over Hold The Line's power chords"),
        ("contact", night, CONTACT, "the map's turn and the handover over Night Shift"),
        ("rift", crossing, RIFT, "the three families over The Crossing"),
        ("iron", hold, IRON, "the five shapes, then the five makers struck, over Hold The Line"),
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
        x = level(new(name), F.LEVELS[lv])
        write("new_" + name, tail(x))
        manifest["singles"].append({"name": "new_" + name, "beside": beside, "seconds": round(len(x) / F.SR, 2)})
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
