// A lit part's halo (MechRig's halos; on trial, Ryan, 30 October): a copy of the part grown out
// along its smoothed normals, in the part's own colour at its light, its alpha highest where the
// shell faces the eye and gone at its rim, so a flare spills soft past the part's edge. It writes
// alpha, so past a machine's outline it reaches the outline pass as a soft fringe (outline.gdshader)
// and from there the screen, rather than the additive light a see-through view would lose.
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_back, shadows_disabled;

uniform sampler2D tile : filter_nearest;   // the part's lit tile, as stored: the phone's renderer lights it so (MechRig.light)
uniform float light = 1.0;                 // the part's light now, as its own material has it
uniform float presence = 0.0;              // 0 to 1: how much halo the part's light over its rest earns
uniform float grow = 3.0;                  // how far out the shell stands, in the part's own units
uniform float reach = 0.49;                // the alpha at its fullest: under a half, so the outline pass keeps it a fringe

void vertex() {
	VERTEX += NORMAL * grow;
}

void fragment() {
	ALBEDO = min(texture(tile, UV).rgb * light, vec3(1.0));
	float facing = abs(dot(normalize(NORMAL), normalize(VIEW)));
	ALPHA = reach * presence * pow(facing, 1.5);
}
