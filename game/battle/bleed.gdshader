// The compositor of the two worlds (decided 19 September). TEXTURE is the 3D battlefield;
// `painted` is the flat painted map, the other world. Where the bleed is high the painted
// map shows through, posterized into the foes' register, with a dithered, pixel-stepped
// edge so the seam is a coarse 2D thing and never a smooth 3D fade. The bleed function is
// the same as Bleed.at in bleed.gd; keep them identical.
shader_type canvas_item;

uniform sampler2D painted : filter_nearest;
uniform vec2 map_size = vec2(1.0, 1.0);
uniform vec2 grad = vec2(0.0, 1.0);          // y where the rift's bleed is total, y where it is gone
uniform vec3 sources[32];                    // x, y, radius in map pixels
uniform int source_count = 0;
uniform float cell = 4.0;                    // the dither's pixel step
uniform float levels = 6.0;                  // posterize steps per channel on the flat side

float bleed_at(vec2 px) {
	float m = 1.0 - clamp((px.y - grad.x) / max(1.0, grad.y - grad.x), 0.0, 1.0);
	for (int i = 0; i < source_count; i++) {
		vec3 s = sources[i];
		float d = distance(px, s.xy);
		m = max(m, 1.0 - smoothstep(s.z * 0.55, s.z, d));
	}
	return m;
}

// Bayer 4x4 threshold, 0..1, from the cell's integer coordinates.
float bayer(ivec2 c) {
	ivec2 lo = c - (c / 2) * 2;
	ivec2 h2 = c / 2;
	ivec2 hi = h2 - (h2 / 2) * 2;
	float m2lo = float(3 * lo.y + 2 * lo.x - 4 * lo.x * lo.y);
	float m2hi = float(3 * hi.y + 2 * hi.x - 4 * hi.x * hi.y);
	return (m2lo * 4.0 + m2hi + 0.5) / 16.0;
}

void fragment() {
	vec2 px = UV * map_size;
	ivec2 c = ivec2(floor(px / cell));
	vec2 q = (vec2(c) + 0.5) * cell;
	float k = smoothstep(0.35, 0.65, bleed_at(q));
	vec4 scene = texture(TEXTURE, UV);
	vec4 other = texture(painted, UV);
	other.rgb = floor(other.rgb * levels + 0.5) / levels;
	COLOR = (k > bayer(c)) ? other : scene;
}
