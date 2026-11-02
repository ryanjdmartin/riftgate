// A weapon's muzzle flare (MuzzleFlare; Ryan, 31 October: "If the flare colour of the weapons can
// follow their tags, that would be really cool"): a quad turned to face the eye at the class's
// muzzle, drawn a little toward the eye so it blooms over the gun's own end, a soft core with
// rays (none, a streak or a star) in the look's colour, its middle whitening as a flash's does.
// It lays its colour over what is there, rather than adding light as a halo does, so it holds
// its colour on a white hull as on a black one (added, it read pale pink on the Badger's grey);
// past the outline it leaves its colour in the see-through view for the outline pass to keep
// (outline.gdshader).
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec3 colour = vec3(1.0, 0.42, 0.0);
uniform float strength = 0.0;   // 0 to 1, the flare's beat now (MuzzleFlare.strength)
uniform float rays = 4.0;       // 0 a round bloom, 2 a streak across, more a star
uniform float spin = 0.0;       // the star's turn, new each shot, so no two flares sit alike
uniform float ahead = 4.0;      // drawn this many of its own units toward the eye, over the muzzle
uniform float core = 0.6;       // how far its middle whitens (MuzzleFlare.CORES)

void vertex() {
	vec4 centre = MODELVIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0);
	float s = length(MODELVIEW_MATRIX[0].xyz);
	vec3 eye = mix(normalize(-centre.xyz), vec3(0.0, 0.0, 1.0), PROJECTION_MATRIX[3][3]);
	centre.xyz += eye * ahead * s;
	POSITION = PROJECTION_MATRIX * (centre + vec4(VERTEX.xy * s, 0.0, 0.0));
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float bloom = 1.0 - smoothstep(0.15, 0.6, r);
	float star = 0.0;
	if (rays > 0.5) {
		float a = atan(p.y, p.x) + spin;
		float arm = pow(abs(cos(a * rays * 0.5)), rays < 2.5 ? 16.0 : 6.0);
		star = arm * (1.0 - smoothstep(0.2, 1.0, r));
	} else {
		star = 0.7 * (1.0 - smoothstep(0.4, 1.0, r));
	}
	ALBEDO = mix(colour, vec3(1.0), core * (1.0 - smoothstep(0.0, 0.4, r)));
	ALPHA = clamp(bloom + star, 0.0, 1.0) * strength;
}
