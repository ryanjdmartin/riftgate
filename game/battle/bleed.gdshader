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
uniform sampler2D painted2 : filter_nearest;  // the other world's second frame
uniform float anim_rate = 1.6;               // frames per second between the two
uniform float saturation = 1.0;              // the tuner's: 0 grey, 1 as painted
uniform float brightness = 1.0;
uniform float flicker = 1.0;                 // the corrupted side's tear, 0 off
uniform vec2 map_size = vec2(1.0, 1.0);      // the painted map, in map pixels
uniform vec2 view_size = vec2(1.0, 1.0);     // this texture, in screen pixels
uniform vec2 scroll = vec2(0.0, 0.0);        // the map view's scroll
uniform float zoom = 1.0;
uniform vec2 grad = vec2(0.0, 1.0);          // y where the rift's bleed is total, y where it is gone
uniform vec3 sources[32];                    // x, y, radius in map pixels
uniform int source_count = 0;
uniform sampler2D units : filter_nearest;    // the machines alone: a mask where the scene wins
uniform float cell = 4.0;                    // the dither's pixel step, on screen
uniform float levels = 5.0;                  // posterize steps per channel on the flat side
uniform float focus_y = 0.0;                 // map-pixel y of the screen's middle
uniform float south_y = 1.0e6;               // map-pixel y of the wall's foot: the city past it softens into the HUD
uniform float focus_band = 330.0;            // the sharp zone reaches this far north of the middle, in map pixels
uniform float focus_falloff = 180.0;         // map pixels over which the blur reaches its maximum
uniform float blur_max = 3.0;                // the blur's tap spacing at its maximum, in screen pixels
uniform vec2 play_x = vec2(0.0, 1.0);        // the playable field's left and right, in map pixels
uniform float edge_fade = 30.0;              // map pixels past the field over which the side blur reaches full strength (smaller is harder)
uniform float edge_blur = 1.6;               // the side blur's maximum

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
	float s = clamp((px.y - south_y) / (focus_falloff * 0.5), 0.0, 1.0);
	return max(f, s) * blur_max;
}

// A dense 7x7 box at `rad` spacing: thick and smooth, never a ghosted multiple image.
// Three copies, since a built-in and a uniform sampler cannot share one function.
vec4 blurred_scene(sampler2D scene_tex, vec2 uv, vec2 texel, float rad) {
	if (rad < 0.05) {
		return texture(scene_tex, uv);
	}
	vec4 acc = vec4(0.0);
	for (int i = -3; i <= 3; i++) {
		for (int j = -3; j <= 3; j++) {
			acc += texture(scene_tex, uv + vec2(float(i), float(j)) * texel * rad);
		}
	}
	return acc / 49.0;
}

vec4 blurred_units(vec2 uv, vec2 texel, float rad) {
	if (rad < 0.05) {
		return texture(units, uv);
	}
	vec4 acc = vec4(0.0);
	for (int i = -3; i <= 3; i++) {
		for (int j = -3; j <= 3; j++) {
			acc += texture(units, uv + vec2(float(i), float(j)) * texel * rad);
		}
	}
	return acc / 49.0;
}

vec4 blurred_other(vec2 uv, vec2 texel, float rad) {
	if (rad < 0.05) {
		return texture(painted, uv);
	}
	vec4 acc = vec4(0.0);
	for (int i = -3; i <= 3; i++) {
		for (int j = -3; j <= 3; j++) {
			acc += texture(painted, uv + vec2(float(i), float(j)) * texel * rad);
		}
	}
	return acc / 49.0;
}

vec4 blurred_other2(vec2 uv, vec2 texel, float rad) {
	if (rad < 0.05) {
		return texture(painted2, uv);
	}
	vec4 acc = vec4(0.0);
	for (int i = -3; i <= 3; i++) {
		for (int j = -3; j <= 3; j++) {
			acc += texture(painted2, uv + vec2(float(i), float(j)) * texel * rad);
		}
	}
	return acc / 49.0;
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
	float rad = max(blur_radius(px), edge * edge_blur);
	vec4 scene = blurred_scene(TEXTURE, UV, 1.0 / view_size, rad);
	// The corrupted side is input the display cannot hold: rarely, a piece of a band of it
	// tears, shearing sideways and dimming. Only the painted side ever shows it (the tear
	// is on `other`), so a lone enemy tile between 3D tiles can glitch on its own; and a
	// tear is a short stretch of its row at a random place, never the whole width (Ryan,
	// 23 September). Around the rift (the first source, always) the input is worst: the
	// tears come more often there and shear further. Centred above the rift's hexes,
	// where the vortex's mouth is, not on them, reaching about a hex beyond it.
	float band = floor(px.y / 6.0);
	float tick = floor(TIME * 2.5);   // a tear holds 0.4 s (Ryan, 23 September)
	vec2 mouth = sources[0].xy - vec2(0.0, sources[0].z * 0.75);
	float near = source_count > 0 ? 1.0 - smoothstep(sources[0].z * 0.5, sources[0].z * 1.0, distance(px, mouth)) : 0.0;
	float h1 = fract(sin(band * 12.9898 + tick * 7.31) * 43758.5453);
	float h2 = fract(sin(band * 3.117 + tick * 5.19 + 1.3) * 27183.1);
	float h3 = fract(sin(band * 8.233 + tick * 2.71 + 4.1) * 19937.7);
	float seg_x0 = h2 * map_size.x;
	float seg_len = mix(50.0, 200.0, h3);
	float in_seg = step(seg_x0, px.x) * step(px.x, seg_x0 + seg_len);
	float flick = step(mix(0.99714, 0.982, near), h1) * in_seg * flicker;   // one row in 350 a tick on the field
	// The shear the vortex's own bands have (three of its pixels at the map's 2x): two
	// map pixels was invisible on the dithered painting (Ryan, 23 September).
	float shear = flick * (mod(band, 2.0) * 2.0 - 1.0) * mix(6.0, 8.0, near);
	vec2 opx = px + vec2(shear, 0.0);
	// The other world runs at two frames, the old way.
	bool second = mod(floor(TIME * anim_rate), 2.0) > 0.5;
	vec4 other = second ? blurred_other2(opx / map_size, 1.0 / (map_size * zoom), rad) : blurred_other(opx / map_size, 1.0 / (map_size * zoom), rad);
	other.rgb = floor(other.rgb * levels + 0.5) / levels;
	other.rgb *= 1.0 - (0.12 + 0.2 * near) * flick;
	// Where a machine is, the reconstruction wins whatever the bleed says: the machines
	// are its own and never go under the painting (Ryan, 22 September). The units layer
	// is a mask only; the pixel comes from the scene, so the wall and the crags still
	// stand in front of a machine behind them.
	// One rule for the machines (Ryan, 22 September): under the painting the
	// reconstruction's geometry is gone, so a machine there is drawn from its own layer,
	// nothing in front of it; on the reconstruction the scene's pixel wins, with its real
	// depth, so the wall and the crags stand in front of a machine behind them. The
	// units layer's translucent part (a flyer's shadow) falls on the painting the same way.
	vec4 u = blurred_units(UV, 1.0 / view_size, rad);
	if (k > bayer(c)) {
		COLOR = other;
		COLOR.rgb = mix(COLOR.rgb, u.rgb, u.a);
	} else {
		COLOR = scene;
	}
	float luma = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
	COLOR.rgb = mix(vec3(luma), COLOR.rgb, saturation) * brightness;
	// No fade to black at the sides: the blur alone is the edge of what the table resolves.
}
