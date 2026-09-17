"""Applied to badger_polished.blend in place (forge.py apply). Breaks up the big flat decks
with geometry, no shader tricks: the track skirts become panelled armour with stowage and
a vent, the body's roof gets raised plates and a hatch. A mining machine carries its kit on
the outside; a Minerva refit bolts armour over that.

Parts, by name in the working file: skirts steel_dark_01.001 / .002 (the slabs on the
track runs), body steel_09 (the wide block that carries the glass; the Badger has no
separate lower hull, its red legs join the body straight to the tracks).
"""

skirts = [o for o in objs() if o.name.startswith("steel_dark_01")]
for o in skirts:
    lo, hi = bbox(o)
    c, _, _ = top_of(o)
    side = 1.0 if c[0] > 0 else -1.0
    # Four armour panels along the run, grooves between them.
    plate_grid(o, cols=1, rows=4, gap=0.8, proud=0.4, inset=0.5)
    # Stowage on the rear half, strapped down, and a livery-coloured can at the very back.
    z = hi.z + 0.4
    crate(f"crate_long_{o.name}", (c[0], lo.y + (hi.y - lo.y) * 0.32, z), size=(5.0, 7.0, 3.0))
    crate(f"crate_short_{o.name}", (c[0], lo.y + (hi.y - lo.y) * 0.62, z), size=(4.2, 4.0, 2.4))
    crate(f"can_{o.name}", (c[0] + side * 1.2, lo.y + 2.4, z), size=(2.2, 2.8, 3.4), mat="livery", strap=False)
    # A small intake vent near the front of the run.
    guided_vents([(Vector((c[0], hi.y - 5.5, z)), Vector((5.0, 3.0, 1.0)))])

# The body's roof: six raised plates and a round hatch at the centre rear. The work lights
# already sit at its front edge.
body = part("steel_09")
plate_grid(body, cols=3, rows=2, gap=0.8, proud=0.35, inset=1.2)
c, blo, bhi = top_of(body)
hatch("hatch_body", (c[0], blo.y + (bhi.y - blo.y) * 0.3, bhi.z + 0.35), radius=2.8)
counts["deck"] = len(skirts) + 1
