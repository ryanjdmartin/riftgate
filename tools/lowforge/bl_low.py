"""Lowforge, the Blender side: the mid-nineties 3D register (Descent, MechWarrior 2), tried
21 September. A model is a few hundred deliberate facets, flat shaded, wearing small tiled
textures (64 px, generated here: brushed metal, panels, stripes, vents, lights, glass,
treads, engines) applied by box projection, so nothing is ever unwrapped.

    Blender -b -P bl_low.py -- --model honey_badger --out art/models/honey_badger.glb --tiles tools/lowforge/tiles

Conventions as the rest of the art: x right, y forward toward the enemy, z up; a mech is
about one hex (60 units) wide. Materials are named "<role>.<tile>" so the engine's toon and
ink passes still know the role.
"""

import math
import os
import re
import sys

import bmesh
import bpy
import numpy as np
from mathutils import Matrix, Vector

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

TILE = 64          # texels per tile
FIST_TIP = 52     # the thumb's tip, rows down the fist's front (Ryan, 1 October: a little shorter)
TILE_WORLD = 14.0  # world units one tile covers, so a mech gets about four texels per unit


def _args():
    argv = sys.argv[sys.argv.index("--") + 1:]
    return {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv), 2)}


# ---------------------------------------------------------------- tiles

## The primary differentiator between makers (Ryan, 21 September): the metal itself.
## grey is the base value, streak the brushed banding, mottle the grain, tint the cast,
## livery the maker's colour, rivets the panel stud spacing (0 for none).
## Ryan's tones (21 September): Minerva steel and military greens, matte; Kestrel chrome,
## silver and blues; Wainwright & Sutler iron and warm browns; Aphelion whites and reds;
## the Arsenal dark steel and gunmetal.
MAKERS = {
    "minerva": {"grey": 0.40, "streak": 0.05, "mottle": 0.03, "tint": (0.86, 0.90, 0.87), "livery": (0.42, 0.50, 0.28), "rivets": 12},
    "kestrel": {"grey": 0.70, "streak": 0.04, "mottle": 0.012, "tint": (0.92, 0.95, 1.0), "livery": (0.16, 0.40, 0.88), "rivets": 0},
    "wainwright_sutler": {"grey": 0.42, "streak": 0.045, "mottle": 0.025, "tint": (1.0, 0.88, 0.76), "livery": (0.52, 0.29, 0.16), "rivets": 8},   # calmer grain than the first cut: it read as wood (Ryan, 22 September)
    "aphelion": {"grey": 0.80, "streak": 0.02, "mottle": 0.01, "tint": (1.0, 1.0, 1.0), "livery": (0.86, 0.12, 0.12), "rivets": 0},
    "arsenal": {"grey": 0.28, "streak": 0.025, "mottle": 0.012, "tint": (0.88, 0.90, 0.96), "livery": (0.36, 0.38, 0.42), "rivets": 16},
}


class Tiles:
    """Generated 64 px tiles in a maker's metal, cached by name, saved as PNG for review."""

    def __init__(self, out_dir, maker="minerva", seed=7):
        self.maker = maker
        self.p = MAKERS.get(maker, MAKERS["minerva"])
        self.out_dir = os.path.join(out_dir, maker)
        self.rng = np.random.default_rng(seed)
        self.images = {}
        os.makedirs(self.out_dir, exist_ok=True)

    def metal(self, grey=None, streak=None, tint=(1.0, 1.0, 1.0), mottle=None, cast=None):
        p = self.p
        cast = p["tint"] if cast is None else cast
        grey = p["grey"] if grey is None else grey
        streak = p["streak"] if streak is None else streak
        mottle = p["mottle"] if mottle is None else mottle
        rows = self.rng.uniform(-streak, streak, size=(TILE, 1, 1)).astype(np.float32)
        noise = self.rng.uniform(-mottle, mottle, size=(TILE, TILE, 1)).astype(np.float32)
        smear = np.zeros_like(noise)
        for i in range(7):
            smear += np.roll(noise, i, axis=1)
        img = np.full((TILE, TILE, 3), grey, np.float32) + rows + smear
        return np.clip(img * np.array(cast, np.float32) * np.array(tint, np.float32), 0.0, 1.0)

    def _seam(self, img, dark=0.28):
        img[0:2, :, :] *= dark
        img[:, 0:2, :] *= dark
        return img

    def _rivets(self, img, step=None, inset=4, dark=0.45):
        step = self.p["rivets"] if step is None else step
        if step <= 0:
            return img
        for y in range(inset, TILE, step):
            for x in range(inset, TILE, step):
                img[y:y + 2, x:x + 2, :] *= dark
                img[y - 1:y, x:x + 2, :] = np.minimum(img[y - 1:y, x:x + 2, :] * 1.3, 1.0)
        return img

    def _fist_side(self, kind, g):
        """The fist's other faces, drawn the way the front is seen (image row 0 at the top)
        and folded out from it as a net: the top (the thumb side) seen from above with the
        front along its bottom edge, the palm side seen from the left with the front along
        its right edge, the base (the little finger's side) seen from below with the front
        along its top edge; the back of the hand on the right in all three. The finger
        grooves, the thumb's band and tip, the knuckles' light and the dark edges meet
        the front's across every shared edge. The back of the hand and the wrist are plate."""
        streak = self.p["streak"] * 0.5
        img = self.metal(g * 0.92, streak, mottle=0.008)
        pad = self.metal(g * 1.10, streak, mottle=0.008)
        T = TILE

        def dark(rows, cols, f=0.3):
            img[rows, cols, :] *= f

        def lit(rows, cols, f=1.25):
            img[rows, cols, :] = np.minimum(img[rows, cols, :] * f, 1.0)

        def fill(rows, cols):
            img[rows, cols, :] = pad[rows, cols, :]

        if kind == "fisttop":
            # From above: the thumb down the palm edge, its root swelling toward the wrist;
            # the index finger side on, along the front from the knuckle and turning back
            # beside the thumb; the hand's body behind.
            fill(slice(0, T), slice(2, 14))                # the thumb
            fill(slice(0, 22), slice(2, 26))               # its root
            fill(slice(46, T), slice(16, T - 3))           # the index finger along the front
            fill(slice(24, 46), slice(16, 28))             # and turning back beside the thumb
            dark(slice(22, T), slice(14, 16))              # the thumb's crease, the front's groove
            dark(slice(22, 24), slice(14, 28))
            dark(slice(0, 22), slice(26, 28))
            dark(slice(34, 36), slice(2, 14), 0.35)        # the thumb's joint
            lit(slice(0, T), slice(9, 11))                 # the thumb's ridge, as on the front
            dark(slice(44, 46), slice(28, T - 3))          # the finger's back
            dark(slice(24, 44), slice(28, 30))
            lit(slice(46, 48), slice(16, T - 3), 1.15)
            lit(slice(40, T), slice(56, 59), 1.3)          # the knuckle, carried round from the front
            dark(slice(0, T), slice(0, 2), 0.4)
            dark(slice(0, T), slice(T - 3, T), 0.4)
            dark(slice(0, 2), slice(28, T), 0.4)           # the wrist
        elif kind == "fistpalm":
            # The palm side: the thumb forward along the top from its root at the wrist,
            # then bent down beside the front edge (the band the front shows along its palm
            # edge), its tip near the bottom; the other three fingers curled back in behind
            # it, their tips pressed into the palm; the heel of the hand behind them.
            fill(slice(2, 14), slice(0, T - 2))            # the thumb along the top
            fill(slice(2, 26), slice(0, 22))               # its root
            fill(slice(2, FIST_TIP), slice(50, T - 2))     # bent down beside the front
            for r0, r1 in ((18, 31), (34, 47), (50, T - 1)):
                fill(slice(r0, r1), slice(32, 48))         # a finger from behind the thumb back to its tip
                dark(slice(r0, r1), slice(40, 41), 0.55)   # the last joint
                lit(slice(r0, r0 + 2), slice(34, 48), 1.15)
                dark(slice(r0, r1), slice(30, 32))         # the tip against the palm
                dark(slice(r0, r0 + 2), slice(32, 34), 0.5)
                dark(slice(r1 - 2, r1), slice(32, 34), 0.5)
            for r in (31, 47):
                dark(slice(r, r + 3), slice(30, 48))       # the grooves between them
            fill(slice(FIST_TIP + 2, T), slice(48, T - 2))   # the little finger past the thumb's tip
            dark(slice(FIST_TIP, FIST_TIP + 2), slice(48, T - 2), 0.35)   # the thumb's tip, as on the front
            dark(slice(14, 16), slice(22, 50))             # the thumb's crease
            dark(slice(14, FIST_TIP), slice(48, 50))
            dark(slice(26, 28), slice(0, 22))
            dark(slice(14, 26), slice(22, 24))
            dark(slice(2, 14), slice(34, 36), 0.35)        # the thumb's joint
            lit(slice(9, 11), slice(0, 56))                # the thumb's ridge, round the bend
            lit(slice(9, FIST_TIP), slice(54, 56))
            dark(slice(2, 5), slice(T - 5, T - 2), 0.5)    # the bend's outer corner, rounded
            dark(slice(0, 2), slice(0, T), 0.4)
            dark(slice(0, T), slice(T - 2, T), 0.4)
            dark(slice(0, T), slice(0, 2), 0.4)            # the wrist
        else:
            # From below (Ryan, 1 October): the little finger across the top along the
            # front, curling in at the palm edge; the thumb's tip at the palm edge behind
            # it, lit along its ridge as on the other faces; the rest the heel of the palm.
            fill(slice(0, 18), slice(4, T - 3))            # the little finger along the front
            dark(slice(18, 20), slice(18, T - 3))
            dark(slice(0, 20), slice(2, 4), 0.5)           # curling in, its tip at the palm edge
            dark(slice(16, 20), slice(4, 18), 0.5)
            dark(slice(0, 18), slice(28, 29), 0.55)        # its joint
            lit(slice(0, 2), slice(4, T - 3), 1.15)
            img[20:T, 2:T - 3, :] = self.metal(g * 1.0, streak, mottle=0.008)[20:T, 2:T - 3, :]   # the palm
            fill(slice(22, 38), slice(2, 16))              # the thumb's tip
            dark(slice(20, 22), slice(2, 16))
            dark(slice(22, 38), slice(16, 18))
            dark(slice(38, 40), slice(2, 18))
            dark(slice(20, 23), slice(13, 16), 0.5)        # its end, rounded
            lit(slice(23, 38), slice(9, 11))               # the thumb's ridge
            lit(slice(0, 24), slice(56, 59), 1.3)          # the knuckle, carried round from the front
            dark(slice(0, T), slice(0, 2), 0.4)
            dark(slice(0, T), slice(T - 3, T), 0.4)
            dark(slice(T - 2, T), slice(0, T), 0.4)        # the wrist
        return img

    def get(self, name):
        if name in self.images:
            return self.images[name]
        kind = name.split("_")[0]
        g = self.p["grey"]
        if kind == "metal":
            img = self.metal()
        elif kind == "panel":
            img = self._rivets(self._seam(self.metal()))
        elif kind == "plate":
            img = self._seam(self.metal(g * 1.08, self.p["streak"] * 0.6))
        elif kind == "dark":
            img = self.metal(g * 0.55, 0.05)
        elif kind == "void":
            # The dark inside a recess, near black under any maker's finish: Kestrel's light grey
            # makes its "dark" tile a mid grey that its chrome lights, so a deep curved bay read as
            # bright metal (the Needletail's cheek bays, 12 November).
            img = self.metal(0.08, 0.01, mottle=0.006)
        elif kind == "vent":
            # Grilles read by contrast, not grain: a calm base and deep slits.
            img = self.metal(g * 0.85, 0.03, mottle=0.015)
            for y in range(6, TILE - 4, 10):
                img[y:y + 4, 6:TILE - 6, :] *= 0.15
                img[y - 1:y, 6:TILE - 6, :] = np.minimum(img[y - 1:y, 6:TILE - 6, :] * 1.6, 1.0)
        elif kind == "stripe":
            img = self.metal(g, 0.06)
            for y in range(TILE):
                for x in range(TILE):
                    if 22 <= y < 42:
                        band = ((x + y) // 8) % 2 == 0
                        img[y, x, :] = np.array([0.95, 0.75, 0.10], np.float32) * (0.9 + img[y, x, 0] * 0.2) if band else np.array([0.10, 0.10, 0.10], np.float32)
        elif kind == "strip":
            # A light strip: dark housing with one bright amber line, for the emissive role.
            img = self.metal(g * 0.5, 0.03, mottle=0.01)
            img[28:36, :, :] = np.array([1.0, 0.80, 0.30], np.float32)
            img[30:34, :, :] = np.array([1.0, 0.95, 0.70], np.float32)
        elif kind == "light":
            img = self.metal(0.25, 0.04)
            img[14:50, 10:54, :] = np.array([1.0, 0.92, 0.62], np.float32)
            img[18:46, 14:50, :] = np.array([1.0, 0.98, 0.85], np.float32)
        elif kind == "glass":
            # Cockpit glass: a cool blue gradient with a diagonal glint, or red for the
            # Arsenal (Ryan, 30 September: red glass is the Arsenal's staple), lit there
            # (Build.material: Ryan, 29 October).
            img = np.zeros((TILE, TILE, 3), np.float32)
            red = self.maker == "arsenal"
            for y in range(TILE):
                for x in range(TILE):
                    t = (x + y) / (2.0 * TILE)
                    if red:
                        img[y, x, :] = np.array([0.45 + 0.50 * t, 0.04 + 0.10 * t, 0.06 + 0.10 * t], np.float32)
                    else:
                        img[y, x, :] = np.array([0.10 + 0.25 * t, 0.30 + 0.35 * t, 0.42 + 0.45 * t], np.float32)
            img[:, :, :] *= 0.85
            for d in range(-4, 4):
                for y in range(TILE):
                    x = (TILE - y + d) % TILE
                    img[y, x, :] = np.minimum(img[y, x, :] * 1.6, 1.0)
        elif kind == "tread":
            # Dark rubber with low cleats: darker than any vent, so the two never read alike.
            img = self.metal(0.13, 0.015, mottle=0.008)
            for x in range(0, TILE, 8):
                img[:, x:x + 3, :] *= 0.55
                img[:, x + 3:x + 4, :] = np.minimum(img[:, x + 3:x + 4, :] * 1.35, 1.0)
        elif kind == "engine":
            img = self.metal(0.28, 0.05)
            img[8:56, 8:56, :] = np.array([0.55, 0.05, 0.03], np.float32)
            img[14:50, 14:50, :] = np.array([0.95, 0.12, 0.05], np.float32)
            img[22:42, 22:42, :] = np.array([1.0, 0.45, 0.20], np.float32)
        elif kind == "exhaust":
            # A booster's mouth (Ryan, 5 October: the engine tile on a booster showed a
            # cross and little red, since a world-grid tile landed anywhere on the face): a
            # radial flame filling the whole tile, white-hot at the core through orange to a
            # deep red rim, no metal border. Fitted one tile to each mouth (`fit` in loft).
            yy, xx = np.mgrid[0:TILE, 0:TILE].astype(np.float32)
            r = np.sqrt((yy - (TILE - 1) / 2.0) ** 2 + (xx - (TILE - 1) / 2.0) ** 2) / (TILE / 2.0)
            stops = [(0.0, (1.0, 0.95, 0.70)), (0.28, (1.0, 0.78, 0.32)), (0.55, (1.0, 0.42, 0.10)),
                     (0.82, (0.88, 0.14, 0.05)), (1.0, (0.55, 0.05, 0.03)), (2.0, (0.55, 0.05, 0.03))]
            img = np.zeros((TILE, TILE, 3), np.float32)
            for (r0, c0), (r1, c1) in zip(stops, stops[1:]):
                m = (r >= r0) & (r < r1)
                f = ((r - r0) / (r1 - r0))[m][:, None]
                img[m] = np.array(c0, np.float32) * (1.0 - f) + np.array(c1, np.float32) * f
        elif kind == "missile":
            img = self.metal(g * 0.9, 0.03, mottle=0.01)
            for cy in (11, 32, 53):
                for cx in (11, 32, 53):
                    yy, xx = np.mgrid[0:TILE, 0:TILE]
                    r = np.sqrt((yy - cy) ** 2 + (xx - cx) ** 2)
                    img[r < 8.0] = np.array([0.55, 0.55, 0.58], np.float32)
                    img[r < 6.0] = np.array([0.08, 0.08, 0.09], np.float32)
        elif kind == "ladder":
            img = self.metal(g, 0.05)
            img[:, 20:24, :] *= 0.4
            img[:, 40:44, :] *= 0.4
            for y in range(4, TILE, 10):
                img[y:y + 3, 20:44, :] = np.minimum(img[y:y + 3, 20:44, :] * 1.6, 1.0)
        elif kind == "livery":
            img = self.metal(0.70, self.p["streak"], tint=self.p["livery"])
        elif kind == "livery2":
            img = self._seam(self.metal(0.70, self.p["streak"], tint=self.p["livery"]))
        elif kind == "bone":
            # Bone is paint, not the maker's metal: the same white for everyone, no cast.
            img = self._seam(self.metal(0.74, self.p["streak"] * 0.5, tint=(0.96, 0.93, 0.85), mottle=0.012, cast=(1.0, 1.0, 1.0)))
        elif kind == "fist":
            # The front of a closed fist, one tile a face (Ryan, 28 September, third try):
            # the knuckles face forward, the fingers lie as four rows split by three
            # grooves, each lit at its knuckle on the back-of-hand edge, and the thumb lies
            # as a band down the palm edge, curled over the fingers. The fist tiles are
            # drawn as Ryan sees them (1 October): the front with the thumb side up and the
            # back of the hand to the right, the other faces folded out from it, so the
            # four PNGs read as a net. `_fist` maps them by the hand's anatomy.
            T = TILE
            img = self.metal(g * 1.04, self.p["streak"] * 0.5, mottle=0.008)
            for y in (16, 32, 48):
                img[y - 1:y + 2, 16:T - 3, :] *= 0.3                 # the grooves between the fingers
            img[3:T - 3, 56:59, :] = np.minimum(img[3:T - 3, 56:59, :] * 1.3, 1.0)   # the knuckles
            img[:, T - 3:T, :] *= 0.4                                 # the back of the hand's edge
            img[0:FIST_TIP, 2:14, :] = self.metal(g * 1.0, self.p["streak"] * 0.5, mottle=0.008)[0:FIST_TIP, 2:14, :]   # the thumb
            img[2:FIST_TIP + 2, 14:16, :] *= 0.3                      # its crease
            img[2:FIST_TIP, 9:11, :] = np.minimum(img[2:FIST_TIP, 9:11, :] * 1.25, 1.0)   # its ridge
            img[FIST_TIP:FIST_TIP + 2, 2:16, :] *= 0.35               # its tip, the little finger below it
            img[:, 0:2, :] *= 0.4
            img = np.flipud(img)
        elif kind in ("fisttop", "fistpalm", "fistbase"):
            img = np.flipud(self._fist_side(kind, g))
        elif kind == "lit":
            # A lit slot: uniformly bright, so a thin box wearing it lights whole wherever it
            # sits (the strip tile's one line only lit a slot that happened to cross it: Ryan,
            # 1 October).
            img = np.tile(np.array([1.0, 0.82, 0.32], np.float32), (TILE, TILE, 1))
        elif kind == "glow":
            # A fire behind a grille: solid, fiery, brighter at the centre, no pattern that
            # could read as a cross through slats (Ryan, 1 October).
            yy, xx = np.mgrid[0:TILE, 0:TILE]
            r = np.sqrt((yy - TILE / 2) ** 2 + (xx - TILE / 2) ** 2) / (TILE / 2)
            t = np.clip(1.0 - r, 0.0, 1.0)[..., None]
            img = np.array([0.80, 0.12, 0.04], np.float32) * (1.0 - t) + np.array([1.0, 0.55, 0.18], np.float32) * t
        elif kind == "ember":
            # The fire banked down: the glow's tile at under a third of its light, for a part
            # that rests dark and is lit hot by an act (Ryan, 6 October, the eighth notes: the
            # Buzzard's cannon dim at rest and bright when it charges, for the contrast).
            yy, xx = np.mgrid[0:TILE, 0:TILE]
            r = np.sqrt((yy - TILE / 2) ** 2 + (xx - TILE / 2) ** 2) / (TILE / 2)
            t = np.clip(1.0 - r, 0.0, 1.0)[..., None]
            img = 0.28 * (np.array([0.80, 0.12, 0.04], np.float32) * (1.0 - t) + np.array([1.0, 0.55, 0.18], np.float32) * t)
        elif kind == "heat":
            # A vent's heat banked down (Ryan, 29 October, of the Polar Bear's vents: the glow
            # "needs to lean way more yellow/orange", then, golden, "way too yellow"): one even
            # colour, no red rim to fill a small face, red and green alone as every red and
            # orange is (the bible's colour rows: past about #ff8200 an orange reads to Ryan as
            # yellow). The game's renderer (the phone's, and the desk's since that day) shows a
            # lit tile as the tile times its light, each channel clipped at one (measured from a
            # render: the ember's rim showed as 255, 123, 41 at an act's peak, 1.8 times eight),
            # so this is #ff7800 at that peak over 14.4 (red a little past one, for the glow's
            # bloom), a deeper orange halfway up and near black at rest.
            img = np.tile(np.array([0.080, 0.0327, 0.0], np.float32), (TILE, TILE, 1))
        elif kind == "hazard":
            img = self.metal(g, 0.05)
            img[26:38, :, :] = np.array([0.95, 0.75, 0.10], np.float32)
        elif kind == "spark":
            # St. Elmo's fire banked down, for the port's sparks that rest dim and crackle lit
            # (Ryan, 28 October: the lit corona read as a white block, and lighting it further
            # showed nothing): banked far enough that its crackle, at twenty-eight times its rest
            # light, holds an electric blue rather than white (31 October: "a tinge of something
            # other than white").
            img = 0.16 * np.tile(np.array([0.40, 0.75, 1.0], np.float32), (TILE, TILE, 1))
            img += self.rng.uniform(-0.01, 0.01, size=(TILE, TILE, 1)).astype(np.float32)
        elif kind == "corona":
            # St. Elmo's fire (the Storm Petrel's mast, 23 October): an electric blue, near uniform
            # like the lit tile, so a small part reads the same wherever the world grid lands on
            # it; the one lit colour on a machine that is no flame. Banked so it burns blue at rest
            # and pales only toward its flare (31 October: it had read white).
            img = 0.45 * np.tile(np.array([0.40, 0.70, 1.0], np.float32), (TILE, TILE, 1))
            img += self.rng.uniform(-0.02, 0.02, size=(TILE, TILE, 1)).astype(np.float32)
        elif kind == "fire":
            # A fire weapon's flame (Ryan, 31 October: "Fire weapons, like the blazethrower, need a
            # red glow, not a white one"): one even red-orange, banked so a flare to eight times
            # its rest light shows #ff380d and sixteen still a red-orange, never white; red and
            # green alone, as every red is.
            img = np.tile(np.array([0.28, 0.062, 0.0], np.float32), (TILE, TILE, 1))
        elif kind == "furnace":
            # A furnace seen through its grille (Ryan, 31 October, of the Nemesis's chest: "that
            # thing has to look HOT"): one even orange, no rim to read as a red grille, banked for a
            # part that burns always at ten times its rest light (#ff5900) and flares to sixteen
            # (#ff6e00), red and green alone and short of the orange that reads yellow to Ryan.
            img = np.tile(np.array([0.26, 0.091, 0.0], np.float32), (TILE, TILE, 1))
        elif kind == "fume":
            # The Arsenal's rear vents, its creepy glowing exhaust (Ryan, 3 November: "The standard
            # vents could use more yellow too, it looked more 'sinister' before when it was more of a
            # sickly orange-yellow than a deep red"; they had worn the lit tile's yellow, which burned
            # near white at eight times its rest light, then the furnace's orange-red): one even
            # orange-yellow, red and green alone, banked for a part that burns always at five times its
            # rest light (the game's render, #ffa?00 in the light: a sickly orange-yellow) and flares to
            # sixteen as a gold short of lemon (a yellow that pale can read green to Ryan, good's
            # colour), never white. Its colour carries nothing in play, so it is free to read yellow.
            img = np.tile(np.array([0.28, 0.168, 0.0], np.float32), (TILE, TILE, 1))
        elif kind == "tesla":
            # Lightning in a coil (Ryan, 31 October, of the Dingo's Translocator: "classic 'tesla
            # lightning blue'"): an electric cyan, banked so its flare to sixteen times its rest
            # light holds the colour; paler and greener than the shield's blue, so the two part.
            img = np.tile(np.array([0.095, 0.18, 0.21], np.float32), (TILE, TILE, 1))
        elif kind == "rift":
            # The other world's light, for a thing of theirs lying in our ground (the Relic, the
            # field's rarest cache): the enemy's violet, even like the lit tile so a small facet
            # reads the same wherever the grid lands on it, banked so it holds its colour at the
            # amber role's light rather than paling to white. A cache's kind is read by its name
            # and its pips, never this colour.
            img = 0.5 * np.tile(np.array([0.62, 0.36, 1.0], np.float32), (TILE, TILE, 1))
        elif kind == "stone":
            # Their stone: near black with a faint violet cast and a slow grain, no seam and no
            # rivet, so nothing about it reads as made here.
            img = self.metal(0.16, 0.03, tint=(0.86, 0.80, 1.0), mottle=0.02, cast=(1.0, 1.0, 1.0))
        elif kind == "hide":
            # Dried hide and sinew on a carcass: a dark brown-violet, matt.
            img = self.metal(0.20, 0.04, tint=(1.0, 0.74, 0.80), mottle=0.03, cast=(1.0, 1.0, 1.0))
        elif kind == "shield":
            # A shield's light (Ryan, 31 October, of the Puffin's amplifier and the Storm Petrel's
            # field: "since both are related to their shield-related passive, could they glow in a
            # shield-ish colour?"): the game's shield blue (Palette.SHIELD, #2f63d8) brightened,
            # banked so a flare to thirty times its rest light shows #3775ff and a rest reads dark.
            img = np.tile(np.array([0.035, 0.074, 0.161], np.float32), (TILE, TILE, 1))
        else:
            img = self.metal()
        image = bpy.data.images.new(name, TILE, TILE, alpha=True)
        rgba = np.ones((TILE, TILE, 4), np.float32)
        rgba[..., :3] = img
        image.pixels = rgba.ravel().tolist()
        image.filepath_raw = os.path.join(self.out_dir, name + ".png")
        image.file_format = "PNG"
        image.save()
        self.images[name] = image
        return image


# ---------------------------------------------------------------- geometry

def rect(cx, w, z0, z1):
    """A rectangle cross-section as (x, z) points, counter-clockwise seen from +y."""
    return [(cx - w / 2, z0), (cx + w / 2, z0), (cx + w / 2, z1), (cx - w / 2, z1)]


def hexagon(cx, cz, w, h):
    """A flattened hexagon cross-section, wide across x."""
    return [(cx + w / 2, cz), (cx + w / 4, cz + h / 2), (cx - w / 4, cz + h / 2),
            (cx - w / 2, cz), (cx - w / 4, cz - h / 2), (cx + w / 4, cz - h / 2)]


def diamond(cx, cz, w, h):
    return [(cx + w / 2, cz), (cx, cz + h / 2), (cx - w / 2, cz), (cx, cz - h / 2)]


def _labelled(name, label):
    """Whether an object carries `label`: the label itself, or the label with Blender's or the
    importer's numbering ("tread.001", "tread_001"), never another label that merely starts
    the same ("tread_deck"). MechRig.labelled and the hangar's labelled() are the same rule."""
    if name == label:
        return True
    if not name.startswith(label):
        return False
    rest = name[len(label):]
    return rest[:1] in ("_", ".") and rest[1:].isdigit()

class Build:
    """Parts as separate objects, each one material (one tile), all facets flat."""

    def __init__(self, name, tiles):
        self.name = name
        self.tiles = tiles
        self.materials = {}
        self.objects = []
        self.pins = []      # every hp_* and joint_* Empty made, in order, so a joint block can take the pins made inside it
        self.carries = {}   # hp_<n> -> the component its stock part is, "" a bare mount: the rig sidecar's pins (see pin())
        self.hidden = []    # the hp_<n> pins that show nothing, stock or fitted: the sidecar's hidden_pins (see pin())
        self.cuts = []      # (targets, cutter) pairs: booleans applied before export (see cut)
        self.joint_meta = {}   # joint name -> {"axis", "limits", "parent"}: the rig sidecar (see rig())
        self.turret_reach = {}   # turret joint -> degrees from the bow its acts may swing it, where wider than the rule's (joint()'s `reach`)
        self.joint_heading = {}   # joint name -> its resting heading in degrees (joint()'s `heading`)
        self.acts = []         # the machine's idle acts, in authoring order (see act())
        self.tuning = {}       # the cornering module's per-machine numbers (see move())
        self.gait_spec = {}    # how the machine moves (see gait())
        self.gait_options = {} # other ways it could move, for judging beside it (see gait_option())
        self.spins = {}        # joints turned without end (see spin())
        self.spin_steps = {}   # joint -> degrees a step: a spinner an act may lock, parked on a step (see spin(), act()'s `locks`)
        self.spins_held = {}   # status -> {joint: degrees a second}: turned while the machine carries the status (see spin_held())
        self.counts = []       # the count displays: parts lit in order for a number the game passes (see count())
        self.forms = {}        # poses held while a status lasts (see form())
        self.ajar_spec = None  # the pose it stands in while a form is not held (see ajar())
        self.form_acts = {}    # form name -> the acts it plays while held (act()'s `form`)
        self.halo = []         # the lit parts a glow names that wear a soft halo when they flare, the hot ones; (part, scale) for one larger, (part, scale, ahead) for one drawn its own way toward the eye (MechRig's halos)
        self.standing = {}     # lit part -> the glow it holds always, over its rest, an act's flare rising past it (MechRig's standing glow)
        self.fires = {}        # a fixed component (or the chassis's passive, for what it fires: the Whip Scorpion's release) -> (act, from, to[, blow]) or a list of them taking turns: the slices of acts that are its firing, played on the spend (MechRig.fire_act)
        self.death_pose = None   # the pose it goes to when lost, in place of the baseline slump (see death())
        self.hidden_fire = None  # (act, from, to[, blow]): the slice every weapon on a hidden mount fires with (the Cottonmouth's drum turning two chambers, 16 November), the sidecar's hidden_fire (MechRig.fire_hidden)
        self.aims = {}         # a fixed component -> the joint that turns to aim it, when it is no waist (MechView3D.aim_joint_for)
        self.pivots = False    # whether the whole machine turns on the spot to aim (a tank's tracks, a castered chassis), as a hover does
        self.fx_sizes = {}     # a fixed weapon -> its muzzle flare's size: an fx_<component> Empty at its business end (fx())
        self.plumes = []       # [{node, part, reach, breadth}]: a booster's plume along its thrust (plume())
        self.launches = {}     # a fixed weapon -> [{node, reach, seconds, delay, ...}]: what it fires out of the machine (launch())
        self.landings = {}     # a name -> where a launch falls into it (landing())
        self.launch_lit = set()   # the labels of the lit parts launches carry, which their flights light (launch())
        self.stock_shapes = {} # pin -> the silhouette class its stock part was built as (stock()), so a burn weapon's fire can sit over it
        self.fits = {}         # pin -> {class: {"shape": its variant, "scale": its scale}}: what a class wears there (pin()'s `fits`)
        self._joint_stack = []   # the joint blocks open right now, outermost first
        self.tile_world = TILE_WORLD   # a structure sets this higher: it is seen at true scale on the map

    def material(self, name):
        role, _, tile = name.partition(".")
        if role == "glass" and self.tiles.maker == "arsenal":
            # The Arsenal's cockpit glass glows, its red lit from within at rest (Ryan, 29
            # October: "apply that material change to all Arsenal cockpit glass so that they
            # all light up and have a passive glow"): the amber role is the one the game and
            # the hangar light, so an act can flare it (the Ammit's eyes).
            name, role = "amber." + tile, "amber"
        if name in self.materials:
            return self.materials[name]
        mat = bpy.data.materials.new(name)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes["Principled BSDF"]
        bsdf.inputs["Roughness"].default_value = 0.9
        bsdf.inputs["Specular IOR Level"].default_value = 0.2 if "Specular IOR Level" in bsdf.inputs else 0.2
        tex = mat.node_tree.nodes.new("ShaderNodeTexImage")
        tex.image = self.tiles.get(tile or "metal")
        tex.interpolation = "Closest"
        mat.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
        self.materials[name] = mat
        return mat

    def _finish(self, bm, material, label, transform=None, frame=None, fit_axis=None):
        """Tiles are mapped by projection. Without a `frame`, along the world axis nearest
        each face's normal, which suits anything axis-aligned and puts seams at the same
        world lines on every part. A `frame` (origin, along, across, over, scale) maps a
        member in its own axes instead (Ryan, 26 September: on a slanted arm the world
        seams cut diagonally across the plates), so panel lines run along and around the
        member; `scale` is (u, v) world units per tile, so a fist's face can carry exactly
        one tile of its own. `fit_axis` (0, 1 or 2) fits one whole tile to each face whose
        normal lies mostly along that world axis, its bounds onto the tile's, so a booster's
        mouth wears its flame centred whatever the world grid says."""
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        if transform is not None:
            bmesh.ops.transform(bm, matrix=transform, verts=bm.verts)
        uv = bm.loops.layers.uv.verify()
        for f in bm.faces:
            f.smooth = False
            n = f.normal
            if frame is None:
                ax = max(range(3), key=lambda i: abs(n[i]))
                a, b = [i for i in range(3) if i != ax]
                if fit_axis is not None and ax == fit_axis:
                    lo_a = min(l.vert.co[a] for l in f.loops)
                    hi_a = max(l.vert.co[a] for l in f.loops)
                    lo_b = min(l.vert.co[b] for l in f.loops)
                    hi_b = max(l.vert.co[b] for l in f.loops)
                    for loop in f.loops:
                        co = loop.vert.co
                        loop[uv].uv = ((co[a] - lo_a) / max(1e-6, hi_a - lo_a), (co[b] - lo_b) / max(1e-6, hi_b - lo_b))
                    continue
                for loop in f.loops:
                    co = loop.vert.co
                    loop[uv].uv = (co[a] / self.tile_world, co[b] / self.tile_world)
                continue
            origin, along, across, over, scale = frame
            su, sv = scale if scale is not None else (self.tile_world, self.tile_world)
            dots = [abs(n.dot(along)), abs(n.dot(across)), abs(n.dot(over))]
            if dots[0] >= dots[1] and dots[0] >= dots[2]:
                ua, va = across, over          # a cap: across and over
            elif dots[1] >= dots[2]:
                ua, va = over, along           # a side face: over and along the member
            else:
                ua, va = across, along         # a front or back face: across and along
            for loop in f.loops:
                rel = loop.vert.co - origin
                loop[uv].uv = (rel.dot(ua) / su, rel.dot(va) / sv)
        mesh = bpy.data.meshes.new(label)
        bm.to_mesh(mesh)
        bm.free()
        ob = bpy.data.objects.new(label, mesh)
        ob.data.materials.append(self.material(material))
        bpy.context.scene.collection.objects.link(ob)
        self.objects.append(ob)
        return ob

    def loft(self, sections, material, label="part", transform=None, cap=True):
        """Sections: [(y, [(x, z), ...]), ...] with the same point count, ordered along y. A
        part wearing the exhaust tile has a whole tile fitted to each of its caps."""
        bm = bmesh.new()
        rings = []
        for y, pts in sections:
            rings.append([bm.verts.new((x, y, z)) for x, z in pts])
        n = len(rings[0])
        for r0, r1 in zip(rings, rings[1:]):
            for i in range(n):
                quad = [r0[i], r0[(i + 1) % n], r1[(i + 1) % n], r1[i]]
                if len({v.co.to_tuple(3) for v in quad}) >= 3:
                    try:
                        bm.faces.new(quad)
                    except ValueError:
                        pass
        if cap:
            for ring in (rings[0], rings[-1]):
                if len({v.co.to_tuple(3) for v in ring}) >= 3:
                    try:
                        bm.faces.new(ring)
                    except ValueError:
                        pass
        fit = 1 if material.partition(".")[2] == "exhaust" and transform is None else None
        return self._finish(bm, material, label, transform, fit_axis=fit)

    def box(self, x0, x1, y0, y1, z0, z1, material, label="box", transform=None):
        return self.loft([(y0, rect((x0 + x1) / 2, x1 - x0, z0, z1)), (y1, rect((x0 + x1) / 2, x1 - x0, z0, z1))], material, label, transform)

    def prism(self, axis, cx, cy, cz, radius, length, material, sides=6, label="prism", phase=0.0):
        """A low-count cylinder along an axis: six sides is the register's barrel."""
        pts = []
        for i in range(sides):
            a = phase + i * 2.0 * math.pi / sides
            pts.append((radius * math.cos(a), radius * math.sin(a)))
        sections = [(-length / 2, pts), (length / 2, pts)]
        if axis == "y":
            m = Matrix.Translation((cx, cy, cz))
        elif axis == "x":
            m = Matrix.Translation((cx, cy, cz)) @ Matrix.Rotation(math.pi / 2, 4, "Z")
        else:
            m = Matrix.Translation((cx, cy, cz)) @ Matrix.Rotation(-math.pi / 2, 4, "X")
        return self.loft(sections, material, label, m)

    def cut(self, targets, p0, p1, radius, sides=8, phase=0.0, section=None):
        """A hole: a cylinder from `p0` to `p1` subtracted from every object in `targets`
        before export (a boolean modifier, applied), so a recessed port is a real hollow in
        the chassis and nothing of the hull shows inside it (Ryan, 1 October). Pair it with
        a `_tube` of the same axis a hair smaller, whose inner wall and floor line the hole.
        `phase` turns the section about the axis: four sides at a quarter pi is a square
        with its sides across and over the axis. `section`, given, replaces the polygon with
        any convex outline as (across, over) pairs about the axis, `radius` unused: a
        rectangular vent's mouth."""
        d = (Vector(p1) - Vector(p0)).normalized()
        up = Vector((0.0, 0.0, 1.0))
        side = Vector((1.0, 0.0, 0.0)) if abs(d.dot(up)) > 0.999 else d.cross(up).normalized()
        over = side.cross(d).normalized()
        if section is None:
            section = [(radius * math.cos(phase + i * 2.0 * math.pi / sides), radius * math.sin(phase + i * 2.0 * math.pi / sides)) for i in range(sides)]
        sides = len(section)
        bm = bmesh.new()
        rings = []
        for p in (Vector(p0) - d * 1.0, Vector(p1) + d * 4.0):
            rings.append([bm.verts.new(p + side * u + over * v) for u, v in section])
        for i in range(sides):
            bm.faces.new([rings[0][i], rings[0][(i + 1) % sides], rings[1][(i + 1) % sides], rings[1][i]])
        bm.faces.new(rings[0])
        bm.faces.new(list(reversed(rings[1])))
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        mesh = bpy.data.meshes.new("cutter")
        bm.to_mesh(mesh)
        bm.free()
        cutter = bpy.data.objects.new("cutter", mesh)
        bpy.context.scene.collection.objects.link(cutter)
        self.cuts.append((list(targets), cutter))
        return cutter

    def cut_hull(self, targets, points, material=None):
        """The convex hull of `points` subtracted from `targets` before export: a pocket of any
        convex shape, such as a trough whose floor ramps up to meet the surface (the Kite's
        gun port, 12 November). `material`, given, is what the pocket's own walls wear, in place
        of the target's (the Needletail's cheek recesses, dark to their rim: Ryan, 14 November,
        of a light wall showing past their lining, "the execution is leaving weird cuts")."""
        bm = bmesh.new()
        vs = [bm.verts.new(v) for v in points]
        bmesh.ops.convex_hull(bm, input=vs)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        mesh = bpy.data.meshes.new("cutter")
        bm.to_mesh(mesh)
        bm.free()
        if material:
            mesh.materials.append(self.material(material))
        cutter = bpy.data.objects.new("cutter", mesh)
        bpy.context.scene.collection.objects.link(cutter)
        self.cuts.append((list(targets), cutter))

    def cut_rings(self, targets, rings, material=None):
        """A pocket lofted through point rings (each the same count, in order along it, capped at
        both ends) subtracted from `targets` before export: a shape no hull gives, such as a
        teardrop of revolution whose point fades into the skin (the Needletail's cheek bays, 14
        November). `material` as for cut_hull."""
        bm = bmesh.new()
        vs = [[bm.verts.new(p) for p in ring] for ring in rings]
        n = len(vs[0])
        for r0, r1 in zip(vs, vs[1:]):
            for i in range(n):
                bm.faces.new([r0[i], r0[(i + 1) % n], r1[(i + 1) % n], r1[i]])
        bm.faces.new(vs[0])
        bm.faces.new(list(reversed(vs[-1])))
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        mesh = bpy.data.meshes.new("cutter")
        bm.to_mesh(mesh)
        bm.free()
        if material:
            mesh.materials.append(self.material(material))
        cutter = bpy.data.objects.new("cutter", mesh)
        bpy.context.scene.collection.objects.link(cutter)
        self.cuts.append((list(targets), cutter))
        return cutter

    def cut_box(self, targets, x0, x1, y0, y1, z0, z1):
        """A box subtracted from `targets` before export: a shallow one makes a pocket in
        a surface (a vent cut into a fairing), a deep one a hole."""
        bm = bmesh.new()
        vs = [bm.verts.new(v) for v in ((x0, y0, z0), (x1, y0, z0), (x1, y1, z0), (x0, y1, z0), (x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1))]
        for f in ((0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4), (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)):
            bm.faces.new([vs[i] for i in f])
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        mesh = bpy.data.meshes.new("cutter")
        bm.to_mesh(mesh)
        bm.free()
        cutter = bpy.data.objects.new("cutter", mesh)
        bpy.context.scene.collection.objects.link(cutter)
        self.cuts.append((list(targets), cutter))
        return cutter

    def apply_cuts(self):
        """Subtract every cutter from its targets and drop the cutters, before export. The
        faces a boolean makes carry no texture coordinates and sampled the tile's dark seam
        (Ryan, 1 October: the Polar Bear's channels read black), so every cut object is
        re-tiled afterwards by the same world-axis projection _finish gives an unframed part."""
        touched = []
        for targets, cutter in self.cuts:
            for ob in targets:
                mod = ob.modifiers.new("cut", "BOOLEAN")
                mod.operation = "DIFFERENCE"
                mod.object = cutter
                if cutter.data.materials:
                    mod.material_mode = "TRANSFER"   # the pocket's walls wear the cutter's material (cut_hull's `material`)
                with bpy.context.temp_override(object=ob, active_object=ob, selected_objects=[ob], selected_editable_objects=[ob]):
                    bpy.ops.object.modifier_apply(modifier=mod.name)
                if ob not in touched:
                    touched.append(ob)
            bpy.data.objects.remove(cutter, do_unlink=True)
        self.cuts = []
        for ob in touched:
            keep = len(ob.material_slots) > 1   # a pocket whose walls wear their own material keeps it (cut_hull's `material`)
            bm = bmesh.new()
            bm.from_mesh(ob.data)
            uv = bm.loops.layers.uv.verify()
            for f in bm.faces:
                f.smooth = False
                n = f.normal
                ax = max(range(3), key=lambda i: abs(n[i]))
                a, b2 = [i for i in range(3) if i != ax]
                for loop in f.loops:
                    co = loop.vert.co
                    loop[uv].uv = (co[a] / self.tile_world, co[b2] / self.tile_world)
                if not keep:
                    f.material_index = 0
            bm.to_mesh(ob.data)
            bm.free()

    def pin(self, name, at, forward=(0.0, 1.0, 0.0), scale=1.0, parts=(), carries=None, fits=None, hidden=False, up=None):
        """A socket: an Empty named `hp_<n>` at `at`, its own +y along `forward` (where the
        weapon points) and its scale the size a mounted component wears there, so the
        engine can hang a component's shape under it with no arithmetic. `parts` are the
        stock component's objects: parented under the pin, keeping their world transform,
        so MechView3D.mount() hides them when another component is fitted. `carries` is the
        content id of the component those parts are, "" for a bare mount: the sidecar lists
        it (rig()'s pins), and the engine compares a machine's fitted die against it, never
        against content's stock, so a stock that moves on shows its class shapes until the
        model follows (Ryan's go, 28 October). Every pin of a rigged machine names one.

        `fits`, given, says how a class sits at this mount where its standard shape at the
        pin's scale does not (Ryan, 2 November: "Hardpoint just needs to declare shape (if
        offered) and scaling"): {class: a variant's name (models_low.VARIANTS), a scale on the
        pin's own, (variant, scale), or (variant, scale, sink)}, so a round port takes a round
        launcher and a dish small enough to pass its bore. `sink` is how far back along the
        pin's line the class sits, in the pin's own units, so a port's gun starts deeper and a
        round rack sits flush in its mouth (Ryan, 11 November: "Can't the polar bears guns start
        deeper? ... a round missile rack doesn't need to poke out at all"). The sidecar carries
        it (rig()'s `fits`); the engine hangs what it names.

        `up`, given, is the way the pin's +z leans, kept square to `forward`, so a class rides a
        tilted face the way the face lies (the Needletail's pods on its upper chamfers, Ryan, 13
        November: "Can the upper pod mounts be angled to match the angle of the pod they sit
        in?"); unnamed, +z stays as near world up as `forward` allows (pin_frame). The engine
        hangs a class under the pin, so it wears the whole frame.

        `hidden` makes a mount that shows nothing, its stock or a fitted component's class (the
        Cottonmouth's guns, mounted inside its drum: Ryan, 19 October, "the guns mounted
        (invisibly) inside"): still a hardpoint, counted and recording what it carries, with no
        parts of its own; the sidecar lists it under `hidden_pins` and the engine hangs nothing
        on it (MechView3D.wear)."""
        if hidden and not name.startswith("hp_"):
            raise ValueError("%s: only a hardpoint (hp_<n>) hides, not %s" % (self.name, name))
        if hidden and parts:
            raise ValueError("%s: %s is hidden, so it carries no parts to show" % (self.name, name))
        if name.startswith("hp_"):
            self.carries[name] = carries
            if fits:
                self.fits[name] = _fits(self.name, name, fits)
            if hidden:
                self.hidden.append(name)
        e = bpy.data.objects.new(name, None)
        e.empty_display_size = 2.0
        m = Matrix.Translation(Vector(at)) @ pin_frame(forward, up).to_4x4() @ Matrix.Scale(scale, 4)
        e.matrix_world = m
        bpy.context.scene.collection.objects.link(e)
        self.pins.append(e)
        inv = m.inverted()
        for ob in parts:
            ob.parent = e
            ob.matrix_parent_inverse = inv
        return e

    def joint(self, name, at, axis=None, limits=None, swing=None, slide=None, reach=None, heading=None):
        """`with b.joint("shoulder_l", pivot): ...` builds a limb inside the block and hangs
        everything made there, pins included, under an Empty named `joint_<name>` at the
        pivot, its axes the world's. A joint inside another joint's block nests under it
        (an elbow in a shoulder, a wheel's spin in its caster, a gun's elevation in its
        turret), so a limb bends from the outer pivot and the inner one both. Only what is
        still unparented at the block's end is taken, so a socket's stock parts stay under
        their pin and the pin comes under the joint, and an inner joint keeps its own.

        `axis` is the turn the joint is for, in the machine's own terms: "pitch" (about the
        axle line, x: a limb swinging, a gun elevating, a wheel spinning; positive raises
        the forward end), "yaw" (about up: a turret, a caster, a head turning; positive
        turns left) or "roll" (about forward; positive drops the right side). Unnamed, it
        follows the name: turret_, caster_, steer_, head and sensor yaw, the rest pitch.
        `limits` clamp what the engine may add to the rest pose, in degrees: a (lo, hi)
        pair on the joint's own axis, or {"pitch": (lo, hi), "yaw": (lo, hi)} for more
        than one. `swing` says whether a melee blow swings this joint (the arms); unnamed,
        a joint named shoulder_* swings. `slide`, given, is the one line the joint moves along,
        never turning (a gun that only runs in and out of its port: the Polar Bear's, Ryan, 29
        October): every turn is held to nothing and a shot kicks it back along the line. All of
        it goes to the rig sidecar (see rig()); the engine (MechRig) reads it. `reach`, for a turret,
        is how far from the bow its acts may swing it where its model means to show its arc, in
        place of the turret rule's TURRET_REACH (the Giant Petrel's quarters to dead astern, Ryan,
        14 November: "the traverse animation should point the guns back, just cause they can"); the
        rule's slew and pause still hold. It goes to the sidecar with the rest (the rig's test reads
        it there); the engine needs it not. `heading`, given, turns the joint's own axes about up by
        that many degrees at rest (positive to the left), so its roll is about a line laid in plan
        along a tapering side rather than straight ahead (the Needletail's clamshell halves, rolling
        in about a hinge along the nose's taper: Ryan, 14 November, "an elongated clamshell that
        covers the whole cut area"). The engine and the hangar keep a joint's resting turn and add
        the pose to it (MechRig._rest), so the roll stays one turn about that line; the sidecar
        names it."""
        if heading is not None:
            self.joint_heading[name] = float(heading)
        if reach is not None:
            if not 0.0 < float(reach) <= 180.0:
                raise ValueError("joint %s of %s: a reach is up to 180 degrees from the bow, not %g" % (name, self.name, float(reach)))
            self.turret_reach[name] = float(reach)
        return _Joint(self, name, at, axis, limits, swing, slide)

    @staticmethod
    def axis_for(name):
        """The axis a joint turns about when the model names none: the engine's rule too."""
        for prefix in ("turret", "caster", "steer", "head", "sensor"):
            if name.startswith(prefix):
                return "yaw"
        return "pitch"

    def act(self, name, duration, tracks=None, body=None, glow=None, ease="smooth", heft=None, places=None, form=None, locks=None, idle=True):
        """One idle act, what the pilot does with the machine every few seconds (the
        idle-acts row, 2 October). `tracks` maps a joint name to keyframes, each
        (t, value) on the joint's own axis, or (t, pitch, yaw, roll), or
        (t, pitch, yaw, roll, dx, dy, dz) with a slide in world units (x right, y forward,
        z up: a chassis squatting). `body` moves the whole machine the same way:
        (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll), a rev or a strafe. `glow` is
        a list of (parts, keys): the lit parts named by prefix (their lowforge labels) and
        (t, k) keys scaling their light, 1 at rest, so a weapon's tip charges. Degrees and
        seconds throughout; every track starts and ends at rest. `ease` is "smooth"
        (eased between keys) or "linear" (a wheel spinning). `heft`, if given, is the act's
        own servo time constant in place of the machine's (b.move): a blow sharper than its
        weight (Ryan, 5 October). `places` limits the act to "map" or "skirmish" (the
        Kite's loop leaves the skirmish's frame); unnamed, it plays in both. `form`,
        given, makes it one of that form's acts, played while the form is held in place of the
        machine's own and added to the form's held pose (Ryan, 29 October: sealed, the
        Polar Bear's acts are its own, from its hunkered pose). `locks` names spinners with a
        step (spin()'s `step`) the act holds still: each parks quickly on its next step ahead as
        the act starts, never turning back, and holds there while it plays, the act's own track
        on it adding whole steps over that; when the act ends its turn there runs on from where
        it stands (MechRig: the Cottonmouth's drum stops on a chamber to fire, Ryan, 2 November:
        "Keep the idle turn ... Quickly spin it forward a fixed number of barrels when it
        fires"). `idle=False` makes an act a weapon's firing alone, never played at rest (Ryan, 3
        November: the Nemesis's punch, the Skua's burst, the Ammit's second claw)."""
        out = {"name": name, "duration": float(duration), "ease": ease, "tracks": {}, "body": [], "glow": []}
        if heft is not None:
            out["heft"] = float(heft)
        if not idle:
            out["idle"] = False
        if locks:
            out["locks"] = [str(j) for j in ([locks] if isinstance(locks, str) else locks)]
        if places:
            places = [places] if isinstance(places, str) else list(places)
            for pl in places:
                if pl not in ("map", "skirmish"):
                    raise ValueError("act %r of %s: a place is map or skirmish, not %r" % (name, self.name, pl))
            out["places"] = places
        for jn, keys in (tracks or {}).items():
            if jn not in self.joint_meta:
                raise ValueError("act %r of %s keys a joint the model has not got: %s" % (name, self.name, jn))
            rows = [self._row("act", name, jn, key) for key in keys]
            if jn.startswith("turret"):
                self._turret_rule(name, jn, rows, float(duration))
            out["tracks"][jn] = rows
        for key in body or []:
            key = [float(v) for v in key]
            if len(key) == 4:
                key = key + [0.0, 0.0, 0.0]
            if len(key) != 7:
                raise ValueError("act %r of %s: a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll)" % (name, self.name))
            out["body"].append(key)
        for parts, keys in glow or []:
            parts = [parts] if isinstance(parts, str) else list(parts)
            out["glow"].append({"parts": parts, "keys": [[float(t), float(k)] for t, k in keys]})
        if form is None:
            self.acts.append(out)
        else:
            self.form_acts.setdefault(form, []).append(out)
        return out

    def _row(self, kind, name, jn, key):
        """One key of a joint's track, seven wide (t, pitch, yaw, roll, dx, dy, dz), from (t, v)
        on the joint's own axis, (t, pitch, yaw, roll) or the whole row, held to its limits."""
        axis_i = ("pitch", "yaw", "roll").index(self.joint_meta[jn]["axis"])
        key = [float(v) for v in key]
        if len(key) == 2:
            row = [key[0], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            row[1 + axis_i] = key[1]
        elif len(key) == 4:
            row = key + [0.0, 0.0, 0.0]
        elif len(key) == 7:
            row = key
        else:
            raise ValueError("%s %r of %s: a key is (t, v), (t, pitch, yaw, roll) or 7 wide" % (kind, name, self.name))
        for ax, (lo, hi) in self.joint_meta[jn]["limits"].items():
            v = row[1 + ("pitch", "yaw", "roll").index(ax)]
            if not lo <= v <= hi:
                raise ValueError("%s %r of %s asks %s for %s %g, outside its limits %g..%g" % (kind, name, self.name, jn, ax, v, lo, hi))
        return row

    def form(self, name, duration, tracks, glow=None, body=None):
        """A pose the machine holds while it carries the status of the same name (the
        Polar Bear's seal, 28 October: its guns sink and its ports shut while Sealed). `tracks`
        map a joint to keys as an act's do, from rest at 0 to the held pose at `duration` (a
        last key earlier is held on to it); MechRig turns the form in over `duration` and back
        out the same way, holds it in between, and plays no act that moves one of its joints
        while it is in. `glow` is a list of (parts, k): lit parts named by label and their
        light's offset at the held pose (-1 dark, as an act's glow keys), eased in with the
        turn. `body` moves the whole machine as an act's body keys do, to the held pose (the
        sealed Polar Bear hunkers down: Ryan, 29 October). Its own acts are act()'s with
        `form` naming it."""
        out = {"duration": float(duration), "tracks": {}, "glow": []}
        if body:
            rows = []
            for key in body:
                key = [float(v) for v in key]
                if len(key) == 4:
                    key = key + [0.0, 0.0, 0.0]
                if len(key) != 7:
                    raise ValueError("form %r of %s: a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll)" % (name, self.name))
                rows.append(key)
            if rows[-1][0] < float(duration):
                rows.append([float(duration)] + rows[-1][1:])
            out["body"] = rows
        for jn, keys in tracks.items():
            if jn not in self.joint_meta:
                raise ValueError("form %r of %s keys a joint the model has not got: %s" % (name, self.name, jn))
            rows = [self._row("form", name, jn, key) for key in keys]
            if rows[-1][0] < float(duration):
                rows.append([float(duration)] + rows[-1][1:])
            out["tracks"][jn] = rows
        for parts, k in glow or []:
            parts = [parts] if isinstance(parts, str) else list(parts)
            if isinstance(k, (list, tuple)):
                # Keys over the turn, (t, k) as an act's glow keys: the light rides them as the form
                # turns (a death's: then it gutters out once it lands; the Polar Bear's vents).
                out["glow"].append({"parts": parts, "keys": [[float(t), float(v)] for t, v in k]})
            else:
                out["glow"].append({"parts": parts, "k": float(k)})
        self.forms[name] = out
        return out

    def death(self, duration, tracks=None, body=None, glow=None, ease="fall", hang=None, plant=None, sink=0.0, land=True):
        """The pose the machine goes to when it is lost (MechRig.kill), in place of the baseline
        slump every model shares (Ryan, 16 November: "The slump was supposed to be a general
        guideline so that everything got an adequate baseline death animation and pose. There's
        nothing to say that they can't be improved on a case by case basis, like the Clydesdale
        falling onto its face like the AT-AT that influenced it"). `tracks`, `body` and `glow` as a
        form's: from rest at 0 to the held pose at `duration`, eased; the rig turns it in as the
        lights go and holds it, and sets the pose down on its own lowest point (MechRig's death
        floor), so a pose tipped forward or onto its side rests on the ground, never floating and
        never through it. Keep it on its hex: a fall that throws the machine across into the next
        is the pose Ryan sent back (16 November). It falls (`ease` "fall": it starts slow and lands
        at speed, a hop and a rock as it hits; Ryan, the fourth notes: "start slower and hit
        harder"), its lowest point held on the floor every frame of the way down; a joint in `hang`
        goes limp, the rig turning it where its weight takes it once the rest of the pose lies
        where it ends (an arm "slumped down by the elbows", never placed under its own power); a
        glow given keys rides them as it goes down and gutters out once it lands.
        A planted foot never slides (Ryan, the fifth notes: "the physics of a biped, it can't just
        kick it's legs out in front like that"; a quad may slide one pair): `plant` names the joints
        whose feet stay where they stand, a joint alone for the whole fall or (joint, from, to) for a
        stretch of it, a foot that steps first planted from where it comes down; the rig moves the
        body along the floor over them, so a tip or a sit pivots on the feet. `sink` lowers a walker
        on the limbs it stands on, every foot where it stands (the slump's reach, the rig working each
        limb's turns in place of any track here names for them), by that share of the most its limits
        allow with nothing lower than its feet: a many-legged machine's belly brought down without its
        legs sliding out from under it. `land` False for a death that stays on its feet (the Ammit's
        limbs drawn in where it stands): nothing lands, so no hop and no rock."""
        self.form("@death", duration, tracks or {}, glow=glow, body=body)
        self.death_pose = self.forms.pop("@death")
        self.death_pose["ease"] = str(ease)
        for jn in hang or []:
            if jn not in self.joint_meta:
                raise ValueError("the death of %s hangs a joint the model has not got: %s" % (self.name, jn))
        if hang:
            self.death_pose["hang"] = list(hang)
        rows = []
        for p in plant or []:
            jn, t0, t1 = (p, 0.0, duration) if isinstance(p, str) else (p[0], float(p[1]), float(p[2]))
            if jn not in self.joint_meta:
                raise ValueError("the death of %s plants a joint the model has not got: %s" % (self.name, jn))
            if not 0.0 <= t0 < t1 <= duration + 1e-6:
                raise ValueError("the death of %s plants %s over %s to %s, outside its %s seconds" % (self.name, jn, t0, t1, duration))
            rows.append([jn, round(t0, 3), round(t1, 3)])
        if rows:
            self.death_pose["plant"] = rows
        if sink:
            if not 0.0 < float(sink) <= 1.0:
                raise ValueError("the death of %s sinks %s: a share, above 0 and at most 1" % (self.name, sink))
            self.death_pose["sink"] = round(float(sink), 3)
        if not land:
            self.death_pose["land"] = False
        return self.death_pose

    def ajar(self, unless, joints):
        """A pose the machine stands in while the form `unless` is not held (the Polar Bear's vents
        ajar while its shell is open; Ryan, 2 November: "When unsealed, the vents should be open,
        and then more open during the vent animation"): `joints` map a joint to degrees along its
        own axis, in its own sense, or to a (dx, dy, dz) slide. MechRig stands it in at rest, fades
        it out as the form turns in, and gives it way as an act swings the joint, so the act still
        ends where it was authored to."""
        out = {}
        for jn, v in joints.items():
            if jn not in self.joint_meta:
                raise ValueError("ajar of %s keys a joint the model has not got: %s" % (self.name, jn))
            row = [0.0] * 6
            if isinstance(v, (int, float)):
                row[("pitch", "yaw", "roll").index(self.joint_meta[jn]["axis"])] = round(float(v), 2)
            else:
                row[3:6] = [round(float(x), 2) for x in v]
            out[jn] = row
        self.ajar_spec = {"unless": unless, "joints": out}
        return self.ajar_spec

    # A turret's traverse in an act (Ryan, 4 October, the third pass: too fast and wild; not so
    # far, not nearly as fast, and a pause before it swings back, so it carries its weight).
    TURRET_REACH = 70.0   # degrees from the bow at most
    TURRET_SLEW = 35.0    # degrees a second at most between two keys, on average
    TURRET_PAUSE = 0.6    # seconds a turret holds still before it turns back

    def _turret_rule(self, name, jn, rows, duration):
        """Refuse an act that swings a turret too far or too fast, or turns it back without a
        pause: rest at the act's start and end counts as a key."""
        axis_i = ("pitch", "yaw", "roll").index(self.joint_meta[jn]["axis"])
        pts = [(0.0, 0.0)] if rows[0][0] > 0.0 else []
        pts += [(r[0], r[1 + axis_i]) for r in rows]
        if pts[-1][0] < duration:
            pts.append((duration, 0.0))
        where = "act %r of %s, %s" % (name, self.name, jn)
        reach = self.turret_reach.get(jn, self.TURRET_REACH)
        for t, v in pts:
            if abs(v) > reach + 1e-6:
                raise ValueError("%s: %g degrees at %gs, past the turret's reach of %g" % (where, v, t, reach))
        moves = []   # (t0, t1, direction) of each leg that moves
        for (t0, v0), (t1, v1) in zip(pts, pts[1:]):
            if v1 == v0:
                continue
            if t1 <= t0 or abs(v1 - v0) / (t1 - t0) > self.TURRET_SLEW + 1e-6:
                raise ValueError("%s: %g to %g degrees in %gs, faster than %g a second" % (where, v0, v1, t1 - t0, self.TURRET_SLEW))
            moves.append((t0, t1, 1 if v1 > v0 else -1))
        for (a0, a1, da), (b0, b1, db) in zip(moves, moves[1:]):
            if da != db and b0 - a1 < self.TURRET_PAUSE - 1e-6:
                raise ValueError("%s: turns back at %gs after %gs still, under the %gs pause" % (where, b0, b0 - a1, self.TURRET_PAUSE))

    def _keys(self, name, keys, jn=None):
        """Keyframes widened to (t, pitch, yaw, roll, dx, dy, dz) and checked against a
        joint's limits; `jn` None means a body track, whose keys are (t, dx, dy, dz) or
        (t, dx, dy, dz, yaw, pitch, roll)."""
        rows = []
        for key in keys:
            key = [float(v) for v in key]
            if jn is None:
                if len(key) == 4:
                    key = key + [0.0, 0.0, 0.0]
                if len(key) != 7:
                    raise ValueError("%s of %s: a body key is (t, dx, dy, dz) or (t, dx, dy, dz, yaw, pitch, roll)" % (name, self.name))
                rows.append(key)
                continue
            if jn not in self.joint_meta:
                raise ValueError("%s of %s keys a joint the model has not got: %s" % (name, self.name, jn))
            axis_i = ("pitch", "yaw", "roll").index(self.joint_meta[jn]["axis"])
            if len(key) == 2:
                row = [key[0], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                row[1 + axis_i] = key[1]
            elif len(key) == 4:
                row = key + [0.0, 0.0, 0.0]
            elif len(key) == 7:
                row = key
            else:
                raise ValueError("%s of %s: a key is (t, v), (t, pitch, yaw, roll) or 7 wide" % (name, self.name))
            for ax, (lo, hi) in self.joint_meta[jn]["limits"].items():
                v = row[1 + ("pitch", "yaw", "roll").index(ax)]
                if not lo <= v <= hi:
                    raise ValueError("%s of %s asks %s for %s %g, outside its limits %g..%g" % (name, self.name, jn, ax, v, lo, hi))
            rows.append(row)
        return rows

    def gait(self, stride=40.0, tracks=None, body=None, body_hold=None, wheels=None, steer=None, aim=None,
             treads=None, hold=None, glow=None, rock=0.0, ease="smooth", start=None):
        """How the machine moves while the map moves it (the joints row, 2 October; MechRig.drive).
        `stride` is the model units one cycle covers. `tracks` maps a joint to cyclic keys
        over a phase of 0 to 1 (the same shapes as an act's keys), or to (keys, phase) with
        an offset so a diagonal pair shares one shape; `body` the same for the whole body
        (a bob). `body_hold` is (dx, dy, dz, yaw, pitch, roll) held while moving (a flyer's
        nose down) and `hold` maps a joint to (pitch, yaw, roll) held while moving (the
        Badger's booms carrying the claw clear). `wheels` maps a spin joint to its radius;
        `steer` a knuckle to degrees per radian a second of turning, about the joint's own axis (a knuckle yaws, a nacelle pitches: the eighteenth notes), eased toward its limits rather than stopped at them and followed on a short servo (the nineteenth notes: until then it was degrees per degree a second, and a knuckle jumped to full lock); `aim` a caster
        to its share of the travel's bearing against the facing (1 points along it).
        `treads` is {"parts": [labels], "scroll": 1.0} to run the tread tiles; `glow`
        {"parts": [labels or groups], "k": 2.0} to brighten boosters by that much on the
        move; `rock` the degrees the nose comes up on pulling away and dips on stopping. A
        turret turns with the hull on the move (Ryan, 4 October: holding its aim was not worth
        the complexity). `ease` "linear" plays dense keys as they are (a walk worked out
        foot by foot, _plant), "smooth" runs a curve through them. `start` is (option, below,
        full): the machine moves wholly by that gait option under `below` of its full speed
        and by this gait over `full`, crossfading between, so it sets off and pulls up in one
        gait and runs in another (Ryan, 7 October, the nineteenth notes: the Clydesdale trots
        off the mark into its gallop); a fourth, a handoff (_transition in models_low), sets it
        off at a given moment of that gait's stride (`from`) and plays the stride it changes
        in, keys over its `length` in units, into this gait at `to` (the twenty-second notes:
        a crossfade of the whole machine at once clipped a hoof's step; the twenty-first held
        it a stride and faded over half a stride more)."""
        out = {"stride": float(stride), "ease": ease, "tracks": {}, "body": [], "wheels": {}, "steer": {}, "aim": {},
               "hold": {}, "treads": {}, "glow": {}, "rock": float(rock)}
        if start is not None:
            out["start"] = {"option": str(start[0]), "below": float(start[1]), "full": float(start[2])}
            if len(start) > 3:
                h = start[3]
                out["start"]["handoff"] = {"from": round(float(h["from"]), 4), "to": round(float(h["to"]), 4),
                                           "length": round(float(h["length"]), 3),
                                           "tracks": {jn: {"keys": self._keys("the gait's handoff", keys, jn), "phase": 0.0}
                                                      for jn, keys in h["tracks"].items()},
                                           "body": self._keys("the gait's handoff body", h["body"])}
        for jn, spec in (tracks or {}).items():
            keys, phase = (spec if isinstance(spec, tuple) and len(spec) == 2 and not isinstance(spec[0], (int, float)) else (spec, 0.0))
            out["tracks"][jn] = {"keys": self._keys("the gait", keys, jn), "phase": float(phase)}
        out["body"] = self._keys("the gait's body", body or [])
        if body_hold is not None:
            bh = [float(v) for v in body_hold]
            if len(bh) != 6:
                raise ValueError("the gait of %s: body_hold is (dx, dy, dz, yaw, pitch, roll)" % self.name)
            out["body_hold"] = bh
        for d, src in (("wheels", wheels), ("steer", steer), ("aim", aim)):
            for jn, v in (src or {}).items():
                if jn not in self.joint_meta:
                    raise ValueError("the gait of %s names a joint the model has not got: %s" % (self.name, jn))
                out[d][jn] = float(v)
        for jn, v in (hold or {}).items():
            vals = [float(x) for x in (v if isinstance(v, (list, tuple)) else (v,))]
            if len(vals) == 1:
                row = [0.0, 0.0, 0.0]
                row[("pitch", "yaw", "roll").index(self.joint_meta[jn]["axis"])] = vals[0]
                vals = row
            self._keys("the gait's hold", [[0.0] + vals], jn)   # the limits check
            out["hold"][jn] = vals
        if treads:
            parts = treads.get("parts", ["tread"])
            out["treads"] = {"parts": [parts] if isinstance(parts, str) else list(parts), "scroll": float(treads.get("scroll", 1.0))}
        if glow:
            parts = glow.get("parts", [])
            out["glow"] = {"parts": [parts] if isinstance(parts, str) else list(parts), "k": float(glow.get("k", 1.0))}
        self.gait_spec = out
        return out

    def gait_option(self, name, **kw):
        """Another way the machine could move, built as gait() builds one and written beside
        it in the sidecar under `gait_options` (Ryan, 5 October: the Ammit's arms and legs at
        different speeds, to see before deciding): the game moves by the gait alone, and the
        hangar's Walk can switch to an option to judge it running."""
        kept = self.gait_spec
        self.gait_options[name] = self.gait(**kw)
        self.gait_spec = kept
        return self.gait_options[name]

    def spin(self, joint, idle, moving=None, step=None):
        """A joint turned without end on its own axis, whatever the machine is doing (Ryan, 6
        October, the seventh notes: the Stingray's lift fans): `idle` degrees a second standing,
        `moving` (as idle if not given) once it is fully under way, the rate easing between them
        with the move. Give the joint no limits: the turn is wrapped, never clamped. `step`,
        given, is its pitch in degrees, rest one of its steps (a drum's chamber, 60 for six): an
        act may lock it (act()'s `locks`), parking it on a step while the act plays."""
        self.spins[joint] = [float(idle), float(idle if moving is None else moving)]
        if step is not None:
            if not 0.0 < float(step) <= 180.0:
                raise ValueError("%s: the spin of %s steps %g degrees, which is no step" % (self.name, joint, step))
            self.spin_steps[joint] = float(step)

    def spin_held(self, status, joint, speed):
        """A joint turned without end at `speed` degrees a second while the machine carries the
        status `status` (an id in sim/effects.gd's STATUS, a test holding it), eased up to speed
        as the status lands and run down as it goes (MechRig.hold_spin: the Cassowary's capacitor
        while Spun Up, Ryan, 2 November). Give the joint no limits on its axis: the turn is
        wrapped, never clamped."""
        if joint not in self.joint_meta:
            raise ValueError("%s: spin_held names a joint the model has not got: %s" % (self.name, joint))
        if self.joint_meta[joint]["axis"] in self.joint_meta[joint]["limits"]:
            raise ValueError("%s: the held spin's joint %s has limits on its axis, which would clamp its turn" % (self.name, joint))
        self.spins_held.setdefault(str(status), {})[joint] = float(speed)

    COUNT_SOURCES = ("shots", "ammo")   # the numbers the game passes a count display (MechRig.COUNT_SOURCES)

    def count(self, source, parts, on=1.5, off=-0.85, flare=8.0):
        """A count display: `parts` (lit labels, the first lit first) shown lit for as many as the
        number `source` the game passes as the screen refreshes (`shots`, a machine's counted
        shots toward the next that counts; `ammo`, its magazine's rounds: COUNT_SOURCES), the rest
        dark; a number that falls flares every part and lets them all go dark (MechRig.show_counts:
        the Cassowary's capacitor, a cell a counted shot, discharging on the sixth, Ryan, 2
        November). `on`, `off` and `flare` are each part's light as an offset from its light at
        rest, as a glow key's: -1 dark. The parts are kept apart by the weld, as a glow's are."""
        if source not in self.COUNT_SOURCES:
            raise ValueError("%s: a count display shows one of %s, not %r" % (self.name, ", ".join(self.COUNT_SOURCES), source))
        parts = [parts] if isinstance(parts, str) else list(parts)
        if not parts or len(set(parts)) != len(parts):
            raise ValueError("%s: a count display names its parts, each once: %r" % (self.name, parts))
        self.counts.append({"source": source, "parts": parts, "on": float(on), "off": float(off), "flare": float(flare)})

    def move(self, slide=0.0, bank=0.0, strafe=0.0, tilt=None, accel=None, heft=None, oversteer=0.0):
        """The cornering module's numbers for this machine (the joints row, 2 October):
        `slide`, how far the body drifts from its path on a turn and how slowly its heading
        catches up, 0 for a machine that corners on rails; `bank`, how far a flyer or
        hovercraft rolls into the turn, in degrees. A helicopter-style machine (Ryan, 3
        October) keeps its facing and leans into its travel instead: `strafe` is how much
        of its facing it holds through a move (1 turns to where it will end up facing
        first, then translates there, sideways or backward as the path demands; 0 faces its
        heading like everything else), and `tilt` is (pitch, roll) in degrees at the
        reference speed: nose down going forward and up going back, a side down going that
        way, and a third number if given the share of that nose-down it sheds in a turn as it banks
        and pulls into the corner (the nineteenth notes). A helicopter banks 0 and rocks 0; the tilt does both. The map's curve (Ryan, 4
        October; MovePath) reads `accel`, the seconds from rest to full speed; it holds full
        speed through corners (the third pass). `heft` is the machine's weight in its acts
        (Ryan, 4 October, the third pass: heavy, with inertia): the seconds a joint or the body
        takes to catch up with what an act asks, the servos' time constant (MechRig._follow);
        a light craft 0.08, a heavy walker 0.25. `oversteer` (Ryan, 5 October: the Dingo lagged
        through its turns where it should drift into them, and the hovercraft the same) turns
        the nose into a corner ahead of the path, the tail stepping out, and swings it back
        as the corner ends, 1 the most; the slide's lag is for what does not oversteer."""
        self.tuning = {"slide": float(slide), "bank": float(bank), "strafe": float(strafe)}
        if oversteer:
            self.tuning["oversteer"] = float(oversteer)
        if tilt is not None:
            self.tuning["tilt"] = [float(v) for v in tilt[:3]]
        if accel is not None:
            self.tuning["accel"] = float(accel)
        if heft is not None:
            self.tuning["heft"] = float(heft)

    def rig(self):
        """The rig sidecar: every joint's axis, limits and parent, the acts and the
        cornering numbers, written beside the glTF as art/models/<id>.rig.json so no
        runtime code keys on a chassis id. The names the acts' glows look up are listed
        for the weld, which must keep those parts apart."""
        for fname in self.form_acts:
            if fname not in self.forms:
                raise ValueError("%s: acts are given to a form it has not got: %s" % (self.name, fname))
        every_act = self.acts + [a for acts in self.form_acts.values() for a in acts]
        lit_parts = ({p for a in every_act for g in a["glow"] for p in g["parts"]}
                     | {p for f in self.forms.values() for g in f["glow"] for p in g["parts"]}
                     | set(self.gait_spec.get("glow", {}).get("parts", []))
                     | {p for c in self.counts for p in c["parts"]})
        glow_parts = sorted(lit_parts | set(self.gait_spec.get("treads", {}).get("parts", [])))
        # A count display's part has one master: an act, a form or the gait lighting it too would
        # fight the display over its light.
        glowing = ({p for a in every_act for g in a["glow"] for p in g["parts"]} | {p for f in self.forms.values() for g in f["glow"] for p in g["parts"]}
                   | set(self.gait_spec.get("glow", {}).get("parts", [])))
        shared = sorted(glowing & {p for c in self.counts for p in c["parts"]})
        if shared:
            raise ValueError("%s: %s light for a count display and a glow both" % (self.name, ", ".join(shared)))
        # A part a glow names is a label matched whole (the rig's MechRig.labelled: the label,
        # or the label with the importer's numbering), never a prefix: "repulsor" lights no
        # "repulsor_l" (the Puffin's amplify lit nothing for a day; Ryan, 28 October).
        names = {ob.name for ob in self.objects}
        for part in glow_parts:
            if part.startswith("joint_") or part.startswith("hp_"):
                continue
            if not any(_labelled(n, part) for n in names):
                near = sorted({n for n in names if n.startswith(part)})
                raise ValueError("%s: a glow names %r, which labels no part%s" % (self.name, part, " (a label matches whole, not by its prefix: %s)" % ", ".join(near[:4]) if near else ""))
            # And a part that can light: only the amber role glows in the game (MechView3D),
            # so a glow on a plate changes nothing (the Polar Bear's vent lit its unlit collar,
            # not the ember floor inside it, which _tube labels "<label>_floor").
            worn = {m.name.partition(".")[0] for ob in self.objects if _labelled(ob.name, part) for m in ob.data.materials if m is not None}
            if part in lit_parts and "amber" not in worn:
                raise ValueError("%s: a glow names %r, which wears no lit (amber) material, only %s" % (self.name, part, ", ".join(sorted(worn))))
        # What each pin's stock part is (pin()'s `carries`): every pin names one, so the engine
        # never guesses a model's kit from content.
        unnamed = sorted((n for n, c in self.carries.items() if c is None), key=lambda n: int(n[3:]))
        if unnamed:
            raise ValueError("%s: %s name no component they carry (b.socket/b.stock/b.pin carries=, \"\" for a bare mount)" % (self.name, ", ".join(unnamed)))
        # A lock parks a stepped spinner (act()'s `locks`): the act's own turn on it must end on a
        # whole step, held to the act's end, so the turn runs on from a step when the act ends.
        for a in every_act:
            for jn in a.get("locks", []):
                if jn not in self.spins or jn not in self.spin_steps:
                    raise ValueError("%s: act %r locks %s, which is no spinner with a step (b.spin's step)" % (self.name, a["name"], jn))
                rows = a["tracks"].get(jn, [])
                if rows:
                    turn = rows[-1][1 + ("pitch", "yaw", "roll").index(self.joint_meta[jn]["axis"])]
                    whole = turn / self.spin_steps[jn]
                    if abs(whole - round(whole)) > 1e-6 or rows[-1][0] < a["duration"] - 1e-6:
                        raise ValueError("%s: act %r ends its locked %s on %g degrees at %gs, which must be a whole step held to the act's end" % (self.name, a["name"], jn, turn, rows[-1][0]))
        out = {"_about": "the rig of art/models/%s.glb, written by tools/lowforge from models_low.py: joints (axis, limits in degrees, parent), idle acts (seconds, degrees, world units), the gait and the cornering numbers, and what each hardpoint's stock part is; MechRig reads it" % self.name,
               "joints": self.joint_meta, "acts": self.acts, "gait": self.gait_spec, "move": self.tuning, "glow_parts": glow_parts,
               "pins": {n: self.carries[n] for n in sorted(self.carries, key=lambda n: int(n[3:]))}}
        if self.hidden:
            out["hidden_pins"] = sorted(self.hidden, key=lambda n: int(n[3:]))   # mounts that show nothing, stock or fitted (pin()'s `hidden`)
        if self.gait_options:
            out["gait_options"] = self.gait_options
        if self.spins:
            out["spin"] = self.spins
        if self.spin_steps:
            out["spin_step"] = self.spin_steps
        if self.spins_held:
            out["spin_held"] = self.spins_held
        if self.counts:
            out["counts"] = self.counts
        if self.forms:
            out["forms"] = {n: dict(f, acts=self.form_acts.get(n, [])) if self.form_acts.get(n) else f for n, f in self.forms.items()}
        if self.death_pose:
            out["death"] = self.death_pose   # its death pose (death()), in place of the baseline slump
        if self.ajar_spec:
            out["ajar"] = self.ajar_spec
        # A halo is the glow's own bloom, so it names only parts a glow lights, or a lit part a launch
        # carries, which its flight lights (the Swallowtail's flare stars).
        halo = [list(h) if isinstance(h, (tuple, list)) else h for h in self.halo]
        stray = [h for h in halo if (h[0] if isinstance(h, list) else h) not in glow_parts and (h[0] if isinstance(h, list) else h) not in self.launch_lit]
        if stray:
            raise ValueError("%s: a halo names %s, which no glow lights" % (self.name, ", ".join(repr(h) for h in stray)))
        if halo:
            out["halo"] = halo
        stray = [p for p in self.standing if p not in glow_parts]
        if stray:
            raise ValueError("%s: a standing glow names %s, which no glow lights" % (self.name, ", ".join(repr(p) for p in stray)))
        if self.standing:
            out["standing"] = dict(self.standing)
        # A fixed weapon fires with a slice of one of its acts (Ryan, 31 October: "go for ones that
        # are cheapest to do first, where pre-existing animation work has already been looked at").
        # A slice is (act, from, to), or (act, from, to, blow) when it winds up before its blow (the
        # act's second the blow lands: the engine holds the blow's sound and landing till then); a
        # list of slices takes turns (Ryan, 3 November: the Ammit "can also afford two different
        # Claw animations since it's got 4 and will use them often"). A key is a fixed component's
        # id, or the chassis's passive's for what the passive fires (the Whip Scorpion's release).
        def fire_slice(cid, sl):
            name, t0, t1 = sl[0], sl[1], sl[2]
            blow = sl[3] if len(sl) > 3 else None
            act = next((a for a in self.acts if a["name"] == name), None)
            if act is None:
                raise ValueError("%s: %s fires with an act it has not got, %r" % (self.name, cid, name))
            if not (0.0 <= t0 < t1 <= act["duration"]):
                raise ValueError("%s: %s fires from %.2f to %.2f, outside %r's %.2f seconds" % (self.name, cid, t0, t1, name, act["duration"]))
            if blow is not None and not (t0 <= blow <= t1):
                raise ValueError("%s: %s's blow at %.2f lies outside its slice of %r, %.2f to %.2f" % (self.name, cid, blow, name, t0, t1))
            d = {"act": name, "from": t0, "to": t1}
            if blow is not None:
                d["blow"] = blow
            return d
        fires = {}
        for cid, spec in self.fires.items():
            out_slices = [fire_slice(cid, sl) for sl in (spec if isinstance(spec, list) else [spec])]
            fires[cid] = out_slices[0] if len(out_slices) == 1 else out_slices
        if fires:
            out["fires"] = fires
        # Every weapon on a hidden mount fires with one slice (16 November: the Cottonmouth's guns,
        # hidden inside its drum, fire as the drum's shot turning two chambers on; Ryan, 2 and 3
        # November: no effect at a hidden pin, "Shots moving two makes sense").
        if self.hidden_fire:
            if not self.hidden:
                raise ValueError("%s: a hidden mount's firing slice with no hidden mount" % self.name)
            out["hidden_fire"] = fire_slice("a hidden mount", self.hidden_fire)
        for cid, name in self.aims.items():
            if self.joint_meta.get(name, {}).get("axis") != "yaw":
                raise ValueError("%s: %s aims with %r, which is no joint turning about its up axis" % (self.name, cid, name))
        if self.aims:
            out["aims"] = dict(self.aims)
        if self.pivots:
            out["pivots"] = True
        if self.stock_shapes:
            out["stock_shapes"] = {n: self.stock_shapes[n] for n in sorted(self.stock_shapes, key=lambda n: int(n[3:]))}
        # Each booster's plume (plume()): the Empty at its mouth, the lit part it burns with, its size.
        if self.plumes:
            stray = [pl["part"] for pl in self.plumes if pl["part"] not in glow_parts]
            if stray:
                raise ValueError("%s: a plume burns with %s, which no glow lights" % (self.name, ", ".join(repr(p) for p in stray)))
            out["plumes"] = list(self.plumes)
        if self.launches:
            out["launches"] = {cid: list(rows) for cid, rows in self.launches.items()}
        # Each fixed weapon's business end (fx()): its muzzle flare's size, the Empty carrying the place.
        if self.fx_sizes:
            out["fx"] = {cid: round(size, 2) for cid, size in sorted(self.fx_sizes.items())}
        # How a class sits at a mount that declares it (pin()'s `fits`): its variant and scale.
        if self.fits:
            out["fits"] = {n: self.fits[n] for n in sorted(self.fits, key=lambda n: int(n[3:]))}
        return out

    def fx(self, cid, at, forward=(0.0, 1.0, 0.0), size=16.0):
        """A fixed weapon's business end (Ryan's go of 3 November: the fixed weapons with no act to
        cut "each want an act that shows it, or a mount to kick and flare from"): an Empty named
        `fx_<component>` at `at`, its +y along `forward`, made inside the joint block that carries
        the weapon so it rides that joint. The engine flares the weapon there in its tags' look and
        kicks that joint as it fires, as it does a mounted gun's (MechView3D.strike); `size` is the
        flare's width in world units, written to the sidecar's `fx`."""
        e = bpy.data.objects.new("fx_" + cid, None)
        e.empty_display_size = 1.0
        e.matrix_world = Matrix.Translation(Vector(at)) @ pin_frame(forward).to_4x4()
        bpy.context.scene.collection.objects.link(e)
        self.pins.append(e)
        self.fx_sizes[cid] = float(size)
        return e

    def plume(self, part, at, thrust, reach, breadth):
        """A booster's plume along its thrust (Ryan, 31 October, of the Stingray's exhaust: "can it be
        directional?"): an Empty named plume_<n> at the mouth `at`, its +y along `thrust` (the way
        the blast goes, out of the mouth), made inside the joint block that carries the booster.
        The engine draws a flame there `reach` long and `breadth` wide, lit with the lit `part`
        (its glow track's light), in place of that part's halo (MechView3D._setup_plumes)."""
        name = "plume_%d" % (len(self.plumes) + 1)
        e = bpy.data.objects.new(name, None)
        e.empty_display_size = 1.0
        e.matrix_world = Matrix.Translation(Vector(at)) @ pin_frame(thrust).to_4x4()
        bpy.context.scene.collection.objects.link(e)
        self.pins.append(e)
        self.plumes.append({"node": name, "part": part, "reach": round(float(reach), 2), "breadth": round(float(breadth), 2)})
        return e

    def launch(self, cid, at, forward=(0.0, 1.0, 0.0), reach=120.0, seconds=0.6, delay=0.0, to=None,
               ease="in", drop=0.0, spin=0.0, hang=0.0, sink=0.0, fade=0.0, light=None, lands=None):
        """`with b.launch("syrinx_drone", at, forward, ...): ...` builds what a fixed weapon fires out
        of the machine (Ryan, 3 November, of the Lammergeier: "I guess a new drone model that fires
        out, something simple"; the next day: "Go for some micro models and let's see what they look
        like"): every object made in the block hangs under an Empty named launch_<component>_<n> at
        `at`, its +y along `forward`, which the engine hides at rest; as the weapon fires it shows,
        `delay` seconds on, flies `reach` world units along that line in `seconds`, then hides
        again at home (MechView3D.launches_of). Made inside a joint's block it rides that joint.

        Its flight's shape (MechView3D.flight_at): `ease` how it gathers along its line, "in"
        gathering speed as a drone or a rocket does, "out" slowing as a lobbed round does, "line" at
        one speed as a shell leaves a muzzle; `drop` the units gravity pulls it down by the flight's
        end, growing as the square of the time, so a "line" with a drop is a thrown thing's arc;
        `to`, given, the point (in the model at rest) the flight ends at, which sets its line and its
        reach, the drop kept; `spin` the degrees it turns end over end about its own x across the
        flight; `hang` the seconds it holds where the flight ends, sinking `sink` units meanwhile (a
        flare under its chute); `fade` the last seconds over which its light dies before it hides;
        `light` the rests over its own its lit parts burn at (the engine's LAUNCH_LIGHT, 14, when
        None); `lands`, the name of a landing() made earlier, a place it falls into: its flight ends
        there at rest (as `to` does), and the engine takes its line again as it leaves, from where
        it is to where that place is then, so a casing thrown from a gun that has turned still finds
        the forge. The sidecar's `launches` lists each under its component, a shape's keys only
        where they differ from a drone's."""
        land = None
        if lands is not None:
            if lands not in self.landings:
                raise ValueError("launch of %s in %s: no landing named %r (landing() first)" % (cid, self.name, lands))
            land, to = "land_" + lands, self.landings[lands]
        return _Launch(self, cid, at, forward, reach, seconds, delay, to, ease, drop, spin, hang, sink, fade, light, land)

    def landing(self, name, at):
        """A place a launch falls into (launch()'s `lands`): an Empty named `land_<name>` at `at`, made
        inside the joint block that carries what it lands in, so it rides that joint."""
        if name in self.landings:
            raise ValueError("%s: landing %s is made twice" % (self.name, name))
        e = bpy.data.objects.new("land_" + name, None)
        e.empty_display_size = 1.0
        e.matrix_world = Matrix.Translation(Vector(at))
        bpy.context.scene.collection.objects.link(e)
        self.pins.append(e)
        self.landings[name] = tuple(at)
        return e

    def socket(self, name, at, forward=(0.0, 1.0, 0.0), scale=1.0, carries=None, fits=None):
        """`with b.socket("hp_1", at, forward): ...` builds a part inside the block and pins it:
        every object made in the block hangs under the pin. For a proposal's look test alone
        (tools/lowforge/looks/): a machine's stock gun is never built by hand, it is its class
        (stock(); Ryan, 11 November), and tests/test_mech_rig.gd holds every model to that.
        `carries` names the component, `fits` how a class sits there (pin())."""
        return _Socket(self, name, at, forward, scale, carries, fits)

    def pad(self, name, at, forward=(0.0, 1.0, 0.0), scale=1.0, size=(8.0, 3.0), material="steel.panel", fits=None):
        """A bare gun mount: a hardpoint whose stock loadout puts nothing there (the rule,
        30 September: armour and vents show nowhere, so a machine with more hardpoints than
        stock guns carries empty mounts). A low block at the socket so a fitted gun sits on
        something, and the pin with no stock part under it. `size` is (across, thick) in
        world units, the block lying under the pin along its forward."""
        w, t = size
        m = Matrix.Translation(Vector(at)) @ pin_frame(forward).to_4x4()
        start = len(self.objects)
        self.box(-w / 2.0, w / 2.0, -w / 2.0, w / 2.0, -t, 0.0, material, "pad")
        for ob in self.objects[start:]:
            ob.matrix_world = m
        return self.pin(name, at, forward, scale, carries="", fits=fits)

    def stock(self, name, at, shape, forward=(0.0, 1.0, 0.0), scale=1.0, carries=None, fits=None, up=None):
        """A pin whose stock component is one of the silhouette classes (models_low.SHAPES),
        built at the origin along +y and moved onto the pin's frame at its scale: the way a
        swapped component will sit there, so the machine is judged wearing one, in the variant
        and at the scale the pin's `fits` give its class. `carries` names the component
        (pin()); its class is `shape`; `up` leans the pin's frame (pin())."""
        import models_low
        start = len(self.objects)
        self.stock_shapes[name] = shape
        fit = _fits(self.name, name, fits or {}).get(shape, {})
        models_low.shape_builder(fit.get("shape", shape))(self, 1.0)
        m = (Matrix.Translation(Vector(at)) @ pin_frame(forward, up).to_4x4() @ Matrix.Scale(scale, 4)
             @ Matrix.Translation((0.0, -fit.get("sink", 0.0), 0.0)) @ Matrix.Scale(fit.get("scale", 1.0), 4))
        parts = self.objects[start:]
        for ob in parts:
            ob.matrix_world = m
        return self.pin(name, at, forward, scale, parts, carries=carries, fits=fits, up=up)


def _fits(model, pin, fits):
    """A pin's `fits` as the sidecar carries them, {class: {"shape": variant, "scale": k}}, each
    checked: a class content knows, a variant of that class, a scale above nothing."""
    import models_low
    out = {}
    for cls, how in fits.items():
        if cls not in models_low.SHAPES:
            raise ValueError("%s: %s fits %r, which is no class (%s)" % (model, pin, cls, ", ".join(models_low.SHAPES)))
        shape, scale, sink = cls, 1.0, 0.0
        if isinstance(how, str):
            shape = how
        elif isinstance(how, (int, float)):
            scale = float(how)
        else:
            shape, scale = how[0], float(how[1])
            if len(how) > 2:
                sink = float(how[2])
        if shape != cls and (shape not in models_low.VARIANTS or models_low.VARIANTS[shape][0] != cls):
            raise ValueError("%s: %s fits its %s with %r, which is no variant of it" % (model, pin, cls, shape))
        if scale <= 0.0:
            raise ValueError("%s: %s fits its %s at a scale of %s" % (model, pin, cls, scale))
        out[cls] = {"shape": shape, "scale": round(scale, 3)}
        if sink:
            out[cls]["sink"] = round(sink, 3)
    return out


class _Launch:
    EASES = ("in", "out", "line")

    def __init__(self, b, cid, at, forward, reach, seconds, delay, to=None, ease="in", drop=0.0, spin=0.0,
                 hang=0.0, sink=0.0, fade=0.0, light=None, lands=None):
        if ease not in _Launch.EASES:
            raise ValueError("launch of %s in %s: ease is one of %s, not %r" % (cid, b.name, ", ".join(_Launch.EASES), ease))
        if to is not None:
            # The line and the reach that end the flight at `to`: what is left once gravity's drop
            # is taken off (every ease ends its line at the whole reach).
            d = Vector(to) - Vector(at) - Vector((0.0, 0.0, -1.0)) * float(drop)
            if d.length < 1e-6:
                raise ValueError("launch of %s in %s: `to` is where it starts" % (cid, b.name))
            forward, reach = tuple(d.normalized()), d.length
        self.b, self.cid, self.at, self.forward = b, cid, at, forward
        self.reach, self.seconds, self.delay = reach, seconds, delay
        self.shape = {"ease": ease, "drop": float(drop), "spin": float(spin), "hang": float(hang), "sink": float(sink),
                      "fade": float(fade), "light": None if light is None else float(light), "lands": lands}

    def __enter__(self):
        self.start = len(self.b.objects)
        return self

    def __exit__(self, *exc):
        if exc[0] is not None:
            return False
        b = self.b
        rows = b.launches.setdefault(self.cid, [])
        name = "launch_%s_%d" % (self.cid, len(rows) + 1)
        e = bpy.data.objects.new(name, None)
        e.empty_display_size = 1.0
        m = Matrix.Translation(Vector(self.at)) @ pin_frame(self.forward).to_4x4()
        e.matrix_world = m
        bpy.context.scene.collection.objects.link(e)
        b.pins.append(e)
        inv = m.inverted()
        for ob in b.objects[self.start:]:
            ob.parent = e
            ob.matrix_parent_inverse = inv
            if ob.type == "MESH" and any(mat is not None and mat.name.startswith("amber") for mat in ob.data.materials):
                b.launch_lit.add(re.sub(r"\.\d+$", "", ob.name))
        row = {"node": name, "reach": round(float(self.reach), 2), "seconds": round(float(self.seconds), 3), "delay": round(float(self.delay), 3)}
        for key, plain in (("ease", "in"), ("drop", 0.0), ("spin", 0.0), ("hang", 0.0), ("sink", 0.0), ("fade", 0.0), ("light", None), ("lands", None)):
            v = self.shape[key]
            if v != plain:
                row[key] = v if isinstance(v, str) else round(v, 3)
        rows.append(row)
        return False


class _Socket:
    def __init__(self, b, name, at, forward, scale, carries=None, fits=None):
        self.b, self.name, self.at, self.forward, self.scale, self.carries, self.fits = b, name, at, forward, scale, carries, fits

    def __enter__(self):
        self.start = len(self.b.objects)
        return self

    def __exit__(self, *exc):
        if exc[0] is None:
            self.b.pin(self.name, self.at, self.forward, self.scale, self.b.objects[self.start:], carries=self.carries, fits=self.fits)
        return False


class _Joint:
    def __init__(self, b, name, at, axis=None, limits=None, swing=None, slide=None):
        self.b, self.name, self.at = b, name, at
        self.slide = [round(v, 4) for v in Vector(slide).normalized()] if slide is not None else None
        if self.slide is not None:
            limits = {"pitch": (0.0, 0.0), "yaw": (0.0, 0.0), "roll": (0.0, 0.0)}   # it runs along its line and never turns
        self.axis = axis or Build.axis_for(name)
        self.swing = bool(name.startswith("shoulder")) if swing is None else bool(swing)
        if self.axis not in ("pitch", "yaw", "roll"):
            raise ValueError("joint %s of %s: axis is pitch, yaw or roll" % (name, b.name))
        if limits is None:
            self.limits = {}
        elif isinstance(limits, dict):
            self.limits = {k: [float(lo), float(hi)] for k, (lo, hi) in limits.items()}
        else:
            self.limits = {self.axis: [float(limits[0]), float(limits[1])]}

    def __enter__(self):
        self.start, self.pstart = len(self.b.objects), len(self.b.pins)
        if self.name in self.b.joint_meta:
            raise ValueError("joint %s of %s is made twice" % (self.name, self.b.name))
        self.b.joint_meta[self.name] = {"axis": self.axis, "limits": self.limits, "swing": self.swing,
                                        "parent": self.b._joint_stack[-1] if self.b._joint_stack else ""}
        if self.slide is not None:
            self.b.joint_meta[self.name]["slide"] = self.slide
        if self.name in self.b.turret_reach:
            self.b.joint_meta[self.name]["reach"] = self.b.turret_reach[self.name]
        if self.name in self.b.joint_heading:
            self.b.joint_meta[self.name]["heading"] = self.b.joint_heading[self.name]
        self.b._joint_stack.append(self.name)
        return self

    def __exit__(self, *exc):
        self.b._joint_stack.pop()
        if exc[0] is not None:
            return False
        b = self.b
        e = bpy.data.objects.new("joint_" + self.name, None)
        e.empty_display_size = 3.0
        m = Matrix.Translation(Vector(self.at)) @ Matrix.Rotation(math.radians(b.joint_heading.get(self.name, 0.0)), 4, "Z")
        e.matrix_world = m
        bpy.context.scene.collection.objects.link(e)
        inv = m.inverted()
        for ob in b.objects[self.start:] + b.pins[self.pstart:]:
            if ob.parent is None:
                ob.parent = e
                ob.matrix_parent_inverse = inv
        b.pins.append(e)
        return False


def pin_frame(forward, up=None):
    """The rotation that turns +y onto `forward`, keeping +z as up where it can (a pin
    pointing straight up or down takes -y or +y as its up, so a rack firing upward wears
    its top toward the tail); `up`, given, is the way +z leans instead, kept square to
    `forward`."""
    f = Vector(forward).normalized()
    hint = Vector(up).normalized() if up is not None else Vector((0.0, 0.0, 1.0))
    if abs(f.dot(hint)) > 0.999:
        hint = Vector((0.0, -1.0, 0.0)) if f.z > 0 else Vector((0.0, 1.0, 0.0))
    z = (hint - f * hint.dot(f)).normalized()
    x = f.cross(z).normalized()
    return Matrix(((x.x, f.x, z.x), (x.y, f.y, z.y), (x.z, f.z, z.z)))


def boom(b, start, length, pitch_deg, yaw_deg, w0, h0, w1, h1, material, label):
    """An excavator-boom segment: a tapered box from `start`, pitched down and yawed, along
    its own y. Returns the far end in world space."""
    sections = [(0.0, rect(0.0, w0, -h0 / 2, h0 / 2)), (length, rect(0.0, w1, -h1 / 2, h1 / 2))]
    rot = Matrix.Rotation(math.radians(yaw_deg), 4, "Z") @ Matrix.Rotation(math.radians(-pitch_deg), 4, "X")
    m = Matrix.Translation(Vector(start)) @ rot
    b.loft(sections, material, label, m)
    end = m @ Vector((0.0, length, 0.0))
    return (end.x, end.y, end.z), rot


# ---------------------------------------------------------------- main

def terrain_tiles(out_dir, seed=11):
    """The battlefield's materials, in the same register as the units: dirt, gravel,
    rubble, cracked concrete, water and rock, 64 px each, written as PNGs for Godot."""
    rng = np.random.default_rng(seed)
    os.makedirs(out_dir, exist_ok=True)

    def base(col, mottle, streak=0.0):
        img = np.tile(np.array(col, np.float32), (TILE, TILE, 1))
        img += rng.uniform(-mottle, mottle, size=(TILE, TILE, 1)).astype(np.float32)
        if streak > 0.0:
            img += rng.uniform(-streak, streak, size=(TILE, 1, 1)).astype(np.float32)
        return img

    def specks(img, n, size, k_lo, k_hi):
        for _ in range(n):
            y, x = rng.integers(0, TILE - size, 2)
            img[y:y + size, x:x + size, :] *= rng.uniform(k_lo, k_hi)
        return img

    tiles = {}
    tiles["dirt"] = specks(base((0.36, 0.33, 0.27), 0.03), 40, 2, 0.75, 1.2)
    tiles["gravel"] = specks(specks(base((0.40, 0.40, 0.37), 0.03), 50, 3, 0.6, 0.85), 30, 2, 1.15, 1.35)
    # Scrub: broken ground with dark tufts and bushes, the 3D face of what the other world
    # paints as forest.
    scrub = base((0.33, 0.32, 0.24), 0.03)
    for _ in range(18):
        y, x = rng.integers(0, TILE - 5, 2)
        w, h = rng.integers(3, 6, 2)
        scrub[y:y + h, x:x + w, :] = np.array([0.20, 0.30, 0.16], np.float32) * rng.uniform(0.8, 1.15)
        scrub[y:y + 1, x:x + w, :] = np.array([0.30, 0.42, 0.22], np.float32)
    tiles["scrub"] = specks(scrub, 20, 2, 0.8, 1.15)
    rubble = base((0.27, 0.28, 0.30), 0.03)
    for _ in range(9):
        y, x = rng.integers(2, TILE - 12, 2)
        w, h = rng.integers(5, 12, 2)
        rubble[y:y + h, x:x + w, :] *= 0.72
        rubble[y:y + 2, x:x + w, :] *= 1.45
    tiles["rubble"] = rubble
    # A road of the future: near-black deck plate with faint seams, a worn pale guide line
    # and a row of guide lamps, most of them dead (Ryan, 21 September).
    concrete = base((0.11, 0.12, 0.13), 0.01, 0.008)
    concrete[0:1, :, :] *= 1.6
    concrete[:, 0:1, :] *= 1.6
    concrete[31:32, :, :] *= 1.4
    concrete[:, 31:32, :] *= 1.4
    concrete[30:32, :, :] = np.array([0.30, 0.32, 0.30], np.float32)
    for x in range(4, TILE, 16):
        lit = rng.random() < 0.35
        concrete[14:17, x:x + 3, :] = np.array([1.0, 0.75, 0.30], np.float32) if lit else np.array([0.20, 0.16, 0.10], np.float32)
        concrete[46:49, x + 8:x + 11, :] = np.array([1.0, 0.75, 0.30], np.float32) if rng.random() < 0.35 else np.array([0.20, 0.16, 0.10], np.float32)
    tiles["concrete"] = concrete
    # Roads are drawn in the engine (road.gdshader) so they join; the concrete tile above
    # is their shoulder.
    tiles["concrete"] = specks(base((0.36, 0.36, 0.35), 0.02), 20, 2, 0.85, 1.1)
    water = base((0.13, 0.24, 0.40), 0.015, 0.03)
    for _ in range(8):
        y, x = rng.integers(0, TILE, 2)
        w = rng.integers(8, 20)
        for i in range(w):
            water[y, (x + i) % TILE, :] = np.minimum(water[y, (x + i) % TILE, :] * 1.5, 1.0)
    tiles["water"] = water
    rock = base((0.30, 0.29, 0.31), 0.03, 0.07)
    for y in range(0, TILE, rng.integers(5, 9)):
        rock[y:y + 1, :, :] *= 0.6
    tiles["rock"] = specks(rock, 20, 2, 0.8, 1.25)
    tiles["crag"] = np.minimum(tiles["rock"] * 1.25, 1.0)
    for name, img in tiles.items():
        image = bpy.data.images.new("terrain_" + name, TILE, TILE, alpha=True)
        rgba = np.ones((TILE, TILE, 4), np.float32)
        rgba[..., :3] = np.clip(img, 0.0, 1.0)
        image.pixels = rgba.ravel().tolist()
        image.filepath_raw = os.path.join(out_dir, name + ".png")
        image.file_format = "PNG"
        image.save()
    print(f"lowforge: terrain tiles -> {out_dir}: {', '.join(tiles)}")


def write_muzzles(path):
    """The muzzle flares' places on each class (models_low.MUZZLES) in the models' own frame, as
    the glTF carries them (a point built at (x, y, z) is at (x, z, -y)): [[point, size], ...] a
    class, read by MechView3D and the hangar."""
    import json
    import models_low
    out = {"_about": "Where each silhouette class's muzzle flare blooms: [point, size] in the class's own frame under its pin, written by tools/lowforge (models_low.MUZZLES)."}
    for shape, places in models_low.MUZZLES.items():
        out[shape] = [[[round(p[0], 3), round(p[2], 3), round(-p[1], 3)], size] for p, size in places]
    with open(path, "w") as f:
        json.dump(out, f, indent=1)
        f.write("\n")


def _export(out):
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", export_apply=True, export_yup=True,
                              export_image_format="AUTO", use_selection=True)


def main():
    a = _args()
    if "terrain" in a:
        bpy.ops.wm.read_factory_settings(use_empty=True)
        terrain_tiles(a["terrain"])
        return
    if "shapes" in a:
        # The silhouette classes (decided 29 September), one file a class a maker, so a
        # swapped component wears its own maker's metal: art/models/shapes/<shape>_<maker>.glb.
        # A class's variants (models_low.VARIANTS) the same way, for the hardpoints that declare
        # one, and their names and classes into variants.json.
        import json
        import models_low
        every = dict(models_low.SHAPES, **{v: fn for v, (_, fn) in models_low.VARIANTS.items()})
        for maker in MAKERS:
            for shape, fn in every.items():
                bpy.ops.wm.read_factory_settings(use_empty=True)
                tiles = Tiles(a.get("tiles", os.path.join(HERE, "tiles")), maker)
                builder = Build("%s_%s" % (shape, maker), tiles)
                fn(builder, 1.0)
                _export(os.path.join(a["shapes"], "%s_%s.glb" % (shape, maker)))
        with open(os.path.join(a["shapes"], "variants.json"), "w") as f:
            json.dump(dict({"_about": "Each variant of a silhouette class and the class it is (models_low.VARIANTS), written by tools/lowforge: a hardpoint's `fits` in its model's sidecar may name one for its class."},
                           **{v: c for v, (c, _) in models_low.VARIANTS.items()}), f, indent=1)
            f.write("\n")
        # A burn weapon's fire over its class (models_low.BURNS), one file a class: its red is
        # no maker's metal.
        for shape, fn in models_low.BURNS.items():
            bpy.ops.wm.read_factory_settings(use_empty=True)
            builder = Build("burn_%s" % shape, Tiles(a.get("tiles", os.path.join(HERE, "tiles")), next(iter(MAKERS))))
            fn(builder, 1.0)
            _export(os.path.join(a["shapes"], "burn_%s.glb" % shape))
        write_muzzles(os.path.join(a["shapes"], "muzzles.json"))
        print(f"lowforge: {len(MAKERS) * len(every)} shapes ({len(models_low.VARIANTS)} variants), {len(models_low.BURNS)} burns and the muzzles -> {a['shapes']}")
        return
    out = a["out"]
    if "blend" in a and "model" not in a:
        # Export a hand-edited working file as it is: joints (joint_*) and pins (hp_*) are
        # Empties and come through as nodes, materials keep their "<role>.<tile>" names.
        bpy.ops.wm.open_mainfile(filepath=a["blend"])
        _export(out)
        meshes = [ob for ob in bpy.data.objects if ob.type == "MESH"]
        tris = sum(sum(len(p.vertices) - 2 for p in ob.data.polygons) for ob in meshes)
        print(f"lowforge: {a['blend']} -> {out}, {len(meshes)} parts, {tris} triangles")
        return
    bpy.ops.wm.read_factory_settings(use_empty=True)
    import models_low
    fn = getattr(models_low, a["model"])
    tiles = Tiles(a.get("tiles", os.path.join(HERE, "tiles")), getattr(fn, "maker", "minerva"))
    builder = Build(a["model"], tiles)
    fn(builder)
    builder.apply_cuts()
    _export(out)
    rig_path = os.path.splitext(out)[0] + ".rig.json"
    if builder.joint_meta or builder.acts or builder.tuning or builder.gait_spec:
        import json
        with open(rig_path, "w") as f:
            json.dump(builder.rig(), f, indent=1)
            f.write("\n")
        print(f"lowforge: {len(builder.joint_meta)} joints, {len(builder.acts)} acts -> {rig_path}")
    elif os.path.exists(rig_path):
        os.remove(rig_path)
    if "blend" in a:
        # The working file for hand edits in Blender, tiles packed inside. A rebuild from
        # code overwrites it: save a hand-edited copy under another name.
        os.makedirs(os.path.dirname(a["blend"]) or ".", exist_ok=True)
        bpy.ops.file.pack_all()
        bpy.ops.wm.save_as_mainfile(filepath=a["blend"])
    tris = sum(sum(len(p.vertices) - 2 for p in ob.data.polygons) for ob in builder.objects)
    print(f"lowforge: {a['model']} -> {out}, {len(builder.objects)} parts, {tris} triangles, {len(tiles.images)} tiles")


if __name__ == "__main__":
    main()
