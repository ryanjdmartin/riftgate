"""HISTORY. Applied to the Badger's working file and baked into models/badger.blend
(finished 17 September 2026). Do not run it again.

Applied to badger_polished.blend in place (forge.py apply). Replaces the hex bolts with
Minerva's X-braced armour plates, removes the sliver teeth that landed in empty space on the
right, and puts teeth on every real claw blade by shape."""

for o in list(objs()):
    if o.name.startswith("bolt_") or o.name.startswith("tooth_"):
        remove(o)

plates = [o for o in objs() if role_of(o) in PLATE_ROLES and not o.name.startswith(("brace_", "rim_", "lamp", "lug_", "vent_", "cleat_", "hydraulic"))]
counts["braced"] = braced_panels(plates, roles=("livery", "steel"))
counts["blades"] = teeth_on_blades(objs())
