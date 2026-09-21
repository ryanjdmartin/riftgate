// The compositor of the two worlds (decided 19 September; the seam made hard and the
// reconstruction tilt-shifted on 20 September). TEXTURE is the 3D battlefield as the
// screen sees it; `painted` is the other world, the flat bright overworld map, the size of
// the whole map. `scroll` and `zoom` say where the screen sits on the map, so every pixel
// knows its map position. Where the bleed is past half the other world shows through,
// posterized, and the edge is a coarse dithered band a few cells wide, never a smooth fade:
// the seam is a 2D thing. The 3D side is blurred away from a focus band around the middle
// of the screen, so the reconstruction reads as a miniature with depth of field while the
// flat world is always sharp. The bleed function is the same as Bleed.at in bleed.gd; keep
// them identical.
shader_type canvas_item;

uniform sampler2D painted : filter_nearest;
uniform vec2 map_size = vec2(1.0, 1.0);      // the painted map, in map pixels
uniform vec2 view_size = vec2(1.0, 1.0);     // this texture, in screen pixels
uniform vec2 scroll = vec2(0.0, 0.0);        // the map view's scroll
uniform float zoom = 1.0;
uniform vec2 grad = vec2(0.0, 1.0);          // y where the rift's bleed is total, y where it is gone
uniform vec3 sources[32];                    // x, y, radius in map pixels
uniform int source_count = 0;
uniform float cell = 4.0;                    // the dither's pixel step, on screen
uniform float levels = 5.0;                  // posterize steps per channel on the flat side
uniform float focus_y = 0.0;                 // map-pixel y of the screen's middle
uniform float focus_band = 330.0;            // the sharp zone reaches this far north of the middle, in map pixels
uniform float focus_falloff = 180.0;         // map pixels over which the blur reaches its maximum
uniform float blur_max = 2.4;                // the blur's tap spacing at its maximum, in screen pixels
uniform vec2 play_x = vec2(0.0, 1.0);        // the playable field's left and right, in map pixels
uniform float edge_fade = 150.0;             // map pixels past the field over which the scenery softens and fades out

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

// Only the far ground softens, north of the focus; the gate end stays sharp (Ryan, 21
// September). Both worlds soften alike: all or none.
float blur_radius(vec2 px) {
	float f = clamp((focus_y - focus_band - px.y) / focus_falloff, 0.0, 1.0);
	return f * blur_max;
}

// Two helpers, since a built-in and a uniform sampler cannot share one function.
vec4 blurred_scene(sampler2D scene_tex, vec2 uv, vec2 texel, float rad) {
	if (rad < 0.05) {
		return texture(scene_tex, uv);
	}
	vec4 acc = vec4(0.0);
	for (int i = -2; i <= 2; i++) {
		for (int j = -2; j <= 2; j++) {
			acc += texture(scene_tex, uv + vec2(float(i), float(j)) * texel * rad);
		}
	}
	return acc / 25.0;
}

vec4 blurred_other(vec2 uv, vec2 texel, float rad) {
	if (rad < 0.05) {
		return texture(painted, uv);
	}
	vec4 acc = vec4(0.0);
	for (int i = -2; i <= 2; i++) {
		for (int j = -2; j <= 2; j++) {
			acc += texture(painted, uv + vec2(float(i), float(j)) * texel * rad);
		}
	}
	return acc / 25.0;
}

void fragment() {
	vec2 spx = UV * view_size;                                 // screen pixel
	ivec2 c = ivec2(floor(spx / cell));
	vec2 q = ((vec2(c) + 0.5) * cell - scroll) / zoom;         // the dither cell's map pixel
	float k = smoothstep(0.42, 0.58, bleed_at(q));
	vec2 px = (spx - scroll) / zoom;                           // this fragment's map pixel
	// Past the field's sides the world softens and fades into the edge of the table, the
	// same way the far north does: blur first, then darkness (Ryan, 21 September).
	float outside = max(play_x.x - px.x, px.x - play_x.y);
	float edge = smoothstep(0.0, edge_fade, outside);
	float rad = max(blur_radius(px), edge * blur_max);
	vec4 scene = blurred_scene(TEXTURE, UV, 1.0 / view_size, rad);
	vec4 other = blurred_other(px / map_size, 1.0 / (map_size * zoom), rad);
	other.rgb = floor(other.rgb * levels + 0.5) / levels;
	// The corrupted side is input the display cannot hold: now and then a band of it tears.
	float band = floor(px.y / 6.0);
	float tick = floor(TIME * 14.0);
	float flick = step(0.995, fract(sin(band * 12.9898 + tick * 7.31) * 43758.5453));
	other.rgb *= 1.0 - 0.18 * flick;
	COLOR = (k > bayer(c)) ? other : scene;
	float side = 1.0 - edge;
	COLOR.rgb *= side;
	COLOR.a *= side;
}
