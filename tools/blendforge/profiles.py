"""How each maker finishes a machine, and what each chassis carries because of its history.

The polish pass (bl_polish.py) reads one merged profile: the maker's manner plus the
chassis's kit. Lore first: these come from the makers' codex voice and the chassis's story,
and they are drafts for Ryan to correct as models arrive.

Maker manner:
  plate_strength   scale of chamfers, panel recesses and bolts on plates (1.0 is subtle)
  track_strength   scale of cleats and wheels on tracks
  bevel_segments   1 is a hard chamfer (brick house), 3 is a rounded edge (airframe)
  cleat_spacing    units between track cleats
  wheels           road wheels per track run
  rivet_scale      bolt size at plate corners; 0 for flush construction
  rims             raised bars along the top edges of big plates, like bumpers
  vents            a grille block on the rear deck of the hull
  pistons          a hydraulic ram between each arm and the hull
  collars          a ring and an open cap on vertical stacks
Chassis kit: a list of named extras, each a rule in bl_polish.py. Anything that adds mass to
the silhouette (fins, boosters, wing_pack, crest) is kit-only: a maker manner adds surface
and converts parts, and never adds something big on its own. The pass errs toward too much
small detail; Ryan cuts from the polished file, and the polished file is his to edit.
"""

MAKERS = {
    # Brick house. Armour first; everything is a tank, even the ones with legs. Nothing
    # rounded, everything bolted, bumpers on the corners, a radiator where you can reach it.
    "minerva": dict(plate_strength=2.5, track_strength=1.5, bevel_segments=1, cleat_spacing=6.0,
                    wheels=2, rivet_scale=1.4, rims=True, vents=True, pistons=True, collars=True),
    # Sleek. Shaped by air even when it never leaves the ground: rounded edges, flowing skin,
    # no bolts, no rims, no grille, and swept tail fins with a nav light at each tip on any
    # chassis. Tracks and wheels stay smooth.
    "kestrel": dict(plate_strength=1.6, track_strength=1.0, bevel_segments=3, cleat_spacing=4.0,
                    wheels=3, rivet_scale=0.0, rims=False, vents=False, pistons=False, collars=False,
                    ),   # fins are kit-only: nothing big is ever added automatically
    # Wagon-builders. Exposed frame, angle-iron trim, honest bolts, rams you can see working.
    "wainwright_sutler": dict(plate_strength=2.0, track_strength=1.5, bevel_segments=2, cleat_spacing=5.0,
                              wheels=3, rivet_scale=1.0, rims=True, vents=False, pistons=True, collars=True),
    # High-tech mecha. Blocky, precise modules with small hard chamfers and no taper; three
    # fine seams across every big face; exposed actuators at the joints; a booster pack of two
    # pivot-mounted thruster pods; a pair of angled wing-blades off the back; flush light
    # strips; sensor blisters. An aversion to wheels and treads: no cleats, no road wheels.
    "aphelion": dict(plate_strength=1.5, track_strength=1.0, bevel_segments=1, cleat_spacing=999.0,
                     wheels=0, rivet_scale=0.0, rims=False, vents=False, pistons=True, collars=False,
                     seams=3, blisters=True, strip_lights=True),   # boosters and wing-blades are kit-only
    # The Council's own. Heavy, gothic, brutal, slightly wrong: hard chamfers at the largest
    # scale, armour layered over armour, vertical fluting on the big walls, a dorsal crest,
    # bolts in rows along the rims as ornament, and one lit seam low in every big face, the
    # only glow on a machine that is not an engine.
    "arsenal": dict(plate_strength=2.8, track_strength=1.5, bevel_segments=1, cleat_spacing=6.0,
                    wheels=2, rivet_scale=0.0, rims=True, vents=True, pistons=True, collars=True,
                    layered=True, ribs=True, stud_rows=True, glow_seams=True),   # the crest is kit-only
}
DEFAULT_MAKER = MAKERS["minerva"]

CHASSIS = {
    # A refitted mining machine: it kept its work lights and its tow points.
    "badger": dict(kit=["work_lights", "tow_lugs"]),
}


def profile_for(maker, chassis):
    p = dict(DEFAULT_MAKER)
    p.update(MAKERS.get(maker, {}))
    p["kit"] = list(CHASSIS.get(chassis, {}).get("kit", []))
    return p
