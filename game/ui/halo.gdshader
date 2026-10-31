// A lit part's halo (MechRig's halos; on trial, Ryan, 30 October): a copy of the part grown out
// along its smoothed normals, in the part's own colour held to its hue and leaning red (a hot part's
// glow reads as its heat, never as white), whole from the part's edge and fading to nothing at the
// shell's rim. It adds its light to what it lies over, so the part's own hot core shows through,
// and it is drawn a little toward the eye, so a part in a slot or a channel glows out over its
// walls as a bloom would; past a machine's outline it leaves a fringe of the same colour in the
// see-through view, which the outline pass keeps (outline.gdshader). Sized in the part's own
// units, it keeps its share of the machine at any size it is drawn, so the hangar zoomed in shows
// the game's look magnified. The first form, seven units out laid over the machine in its clipped
// colour, was "way too much" (Ryan, 30 October).
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_back, shadows_disabled;

uniform sampler2D tile : filter_nearest;   // the part's lit tile, as stored: the phone's renderer lights it so (MechRig.light)
uniform float light = 1.0;                 // the part's light now, as its own material has it
uniform float presence = 0.0;              // 0 to 1: how much halo the part's light over its rest earns
uniform float grow = 2.5;                  // how far out the shell stands, in the part's own units
uniform float ahead = 3.0;                 // drawn this many of the part's units toward the eye: out of its slot, never through the hull
uniform float reach = 0.35;                // the share of the part's colour it adds at its fullest

void vertex() {
	VERTEX += NORMAL * grow;
	vec4 view = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	// Toward the eye along its own ray (the view's axis for an orthogonal camera), which moves it
	// on no screen, only nearer.
	vec3 eye = mix(normalize(-view.xyz), vec3(0.0, 0.0, 1.0), PROJECTION_MATRIX[3][3]);
	view.xyz += eye * ahead * length(MODELVIEW_MATRIX[0].xyz);
	POSITION = PROJECTION_MATRIX * view;
}

void fragment() {
	// The tile's colour without its grey, so a white-hot texel lends no white, at the part's light,
	// held to its hue, then squared: a halo cooler than its core, leaning red as heat does here.
	vec3 t = texture(tile, UV).rgb;
	vec3 c = (t - min(t.r, min(t.g, t.b))) * light;
	c /= max(1.0, max(c.r, max(c.g, c.b)));
	c *= c;
	float facing = abs(dot(normalize(NORMAL), normalize(VIEW)));
	// Additive blending adds ALBEDO times ALPHA to the colour and ALPHA squared to the alpha
	// (measured on the phone's renderer), so the root of the strength in both adds the colour at
	// that strength over the machine and leaves the colour at that alpha over the see-through view.
	ALPHA = sqrt(reach * presence * smoothstep(0.0, 0.6, facing));
	ALBEDO = c * ALPHA;
}
