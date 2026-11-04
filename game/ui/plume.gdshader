// A booster's plume along its thrust (Ryan, 31 October, of the Stingray's exhaust: "can it be
// directional? If not, then we can tone it back down"): a flame out of the mouth, its long axis
// the plume node's forward (its -z, as a pin points its class), turned about that axis to face the
// eye, tapering and fading to its tail;
// pale at its middle near the mouth, the exhaust's orange, deep red at its rim, as a booster's
// glow is (the models row). Laid over what is behind it rather than added, so it holds its colour
// over a pale ground; `strength` follows the exhaust's own light (MechView3D._setup_plumes).
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec3 hot = vec3(1.0, 0.9, 0.7);
uniform vec3 colour = vec3(1.0, 0.42, 0.1);
uniform vec3 rim = vec3(0.8, 0.08, 0.02);
uniform float strength = 0.5;
uniform float reach = 20.0;      // how far it runs out of the mouth, in the node's units
uniform float breadth = 8.0;     // how wide it is at the mouth
uniform float ceiling = 0.48;    // its thickest: under a half in a machine's own view, whose outline pass inks anything
                                 // thicker as the machine's shape (outline.gdshader), so it passes as a glow; the map sets more

void vertex() {
	vec4 origin = MODELVIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0);
	vec3 axis = normalize((MODELVIEW_MATRIX * vec4(0.0, 0.0, -1.0, 0.0)).xyz);
	float s = length(MODELVIEW_MATRIX[2].xyz);
	vec3 to_eye = mix(normalize(-origin.xyz), vec3(0.0, 0.0, 1.0), PROJECTION_MATRIX[3][3]);
	vec3 side = cross(axis, to_eye);
	side = length(side) > 0.001 ? normalize(side) : vec3(1.0, 0.0, 0.0);
	float along = UV.y;
	float half_w = 0.5 * breadth * s * (1.0 - 0.6 * along);
	float stretch = 0.4 + 0.6 * clamp(strength, 0.0, 1.0);   // short at rest, running out as the booster burns
	vec3 p = origin.xyz + axis * (along * reach * stretch * s) + side * ((UV.x * 2.0 - 1.0) * half_w);
	POSITION = PROJECTION_MATRIX * vec4(p, 1.0);
}

void fragment() {
	float across = 1.0 - abs(UV.x * 2.0 - 1.0);   // 1 on the axis, 0 at its edges
	float along = 1.0 - UV.y;                     // 1 at the mouth, 0 at its tail
	vec3 c = mix(rim, colour, smoothstep(0.05, 0.55, across));
	c = mix(c, hot, smoothstep(0.55, 0.95, across * along));
	ALBEDO = c;
	ALPHA = clamp(strength * pow(across, 0.9) * pow(along, 1.2) * 1.6, 0.0, 1.0) * ceiling;
}
