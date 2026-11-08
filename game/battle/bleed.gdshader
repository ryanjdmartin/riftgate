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
uniform vec2 grad = vec2(0.0, 1.0);          // where the rift's bleed is total and where it is gone, along grad_axis
uniform vec2 grad_axis = vec2(0.0, 1.0);     // from the rift toward the wall (Bleed.axis): down the screen, or leftward with the wall at the left
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
// FXAA in the FXAA mode (Hud.fxaa: the AA MODE setting, MSAA off): the scene and the machines read
// again through linear samplers of the same textures, smoothing their edges in the sharp zone.
uniform bool fxaa = false;
uniform sampler2D scene_lin : filter_linear;
uniform sampler2D units_lin : filter_linear;
// The machines' light outline (Ryan, 30 October: "I don't want the outline to thicken as I
// zoom in"): a ring round the machines' layer, `outline_px` of the scene's pixels wide at
// every zoom, smoothed, unbroken, and round the whole machine where the wall stands in front
// of it, since the wall is not in that layer. Looked for only near a machine: `boxes` holds
// each one's box on screen (Map3D.outline_boxes), so the rest of the map pays a comparison a
// machine.
uniform float outline_px = 0.0;              // 0: no outline
uniform vec4 outline_color = vec4(0.36, 1.0, 0.42, 1.0);
uniform vec4 boxes[32];                      // left, top, right, bottom, in the scene's pixels
uniform int box_count = 0;

float bleed_at(vec2 px) {
	float m = 1.0 - clamp((dot(px, grad_axis) - grad.x) / max(1.0, grad.y - grad.x), 0.0, 1.0);
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

// FXAA (Lottes's console form) with a contrast threshold, so only real edges blend: a
// machine's silhouette, its outline, the grid's ribbons, a crag against the ground; a
// texture's quiet texels stay as they are. `texel` is the texture's own pixel.
const vec3 LUMA = vec3(0.299, 0.587, 0.114);
const float FXAA_EDGE_MIN = 0.0625;
const float FXAA_EDGE = 0.125;
const float FXAA_REDUCE_MIN = 1.0 / 128.0;
const float FXAA_REDUCE_MUL = 1.0 / 8.0;
const float FXAA_SPAN = 8.0;

vec4 fxaa_at(sampler2D tex, vec2 uv, vec2 texel) {
	vec4 m = texture(tex, uv);
	float lm = dot(m.rgb, LUMA);
	float lnw = dot(texture(tex, uv + vec2(-0.5, -0.5) * texel).rgb, LUMA);
	float lne = dot(texture(tex, uv + vec2(0.5, -0.5) * texel).rgb, LUMA);
	float lsw = dot(texture(tex, uv + vec2(-0.5, 0.5) * texel).rgb, LUMA);
	float lse = dot(texture(tex, uv + vec2(0.5, 0.5) * texel).rgb, LUMA);
	float lo = min(lm, min(min(lnw, lne), min(lsw, lse)));
	float hi = max(lm, max(max(lnw, lne), max(lsw, lse)));
	if (hi - lo < max(FXAA_EDGE_MIN, hi * FXAA_EDGE)) {
		return m;
	}
	vec2 dir = vec2(-((lnw + lne) - (lsw + lse)), (lnw + lsw) - (lne + lse));
	float reduce = max((lnw + lne + lsw + lse) * 0.25 * FXAA_REDUCE_MUL, FXAA_REDUCE_MIN);
	float rcp = 1.0 / (min(abs(dir.x), abs(dir.y)) + reduce);
	dir = clamp(dir * rcp, vec2(-FXAA_SPAN), vec2(FXAA_SPAN)) * texel;
	vec4 a = 0.5 * (texture(tex, uv + dir * (1.0 / 3.0 - 0.5)) + texture(tex, uv + dir * (2.0 / 3.0 - 0.5)));
	vec4 b = a * 0.5 + 0.25 * (texture(tex, uv - dir * 0.5) + texture(tex, uv + dir * 0.5));
	float lb = dot(b.rgb, LUMA);
	return (lb < lo || lb > hi) ? a : b;
}

// How much of a machine the machines' layer holds at a texel: a flyer's shadow (alpha 0.45)
// is not one.
float solid_at(ivec2 p, ivec2 hi) {
	return clamp((texelFetch(units, clamp(p, ivec2(0), hi), 0).a - 0.5) * 4.0, 0.0, 1.0);
}

// The outline's cover at a pixel: the machines' layer grown by `outline_px` (each texel
// within reach counts, the farthest by how far it falls inside), less the machine itself,
// whose own cover is smoothed over its four neighbours so the ring's inner edge does not
// stair-step along the silhouette.
float outline_at(vec2 uv, vec2 texel) {
	vec2 p = uv / texel;
	float pad = outline_px + 2.0;
	bool near = false;
	for (int i = 0; i < box_count; i++) {
		vec4 b = boxes[i];
		if (p.x > b.x - pad && p.x < b.z + pad && p.y > b.y - pad && p.y < b.w + pad) {
			near = true;
			break;
		}
	}
	if (!near) {
		return 0.0;
	}
	ivec2 hi = textureSize(units, 0) - ivec2(1);
	ivec2 c = ivec2(floor(p));
	float inner = (2.0 * solid_at(c, hi) + solid_at(c + ivec2(1, 0), hi) + solid_at(c - ivec2(1, 0), hi)
		+ solid_at(c + ivec2(0, 1), hi) + solid_at(c - ivec2(0, 1), hi)) / 6.0;
	if (inner >= 1.0) {
		return 0.0;
	}
	float reach = outline_px + 1.0;
	int n = int(ceil(reach));
	// First, whether anything at all is in reach: a linear read at a corner where four texels
	// meet averages the four, so a quarter of the reads cover the square, and most pixels near
	// a machine are not near its edge.
	float found = 0.0;
	for (int y = -n; y <= n; y += 2) {
		for (int x = -n; x <= n; x += 2) {
			found = max(found, texture(units_lin, (vec2(c + ivec2(x, y)) + 1.0) * texel).a);
		}
	}
	if (found <= 0.0) {
		return 0.0;
	}
	float grown = 0.0;
	for (int y = -n; y <= n; y++) {
		for (int x = -n; x <= n; x++) {
			float w = clamp(reach - length(vec2(float(x), float(y))), 0.0, 1.0);
			if (w > grown) {
				grown = max(grown, solid_at(c + ivec2(x, y), hi) * w);
			}
		}
	}
	return grown * (1.0 - inner);
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
	bool aa_here = fxaa && rad < 0.05;   // the blurred zones are soft already
	// The corrupted side is input the display cannot hold: rarely, a piece of a band of it
	// tears, shearing sideways and dimming. Only the painted side ever shows it (the tear
	// is on `other`), so a lone enemy tile between 3D tiles can glitch on its own; and a
	// tear is a short stretch of its row at a random place, never the whole width (Ryan,
	// 23 September). Around the rift (the first source, always) the input is worst: the
	// tears come more often there and shear further. Centred above the rift's hexes,
	// where the vortex's mouth is, not on them, reaching about a hex beyond it.
	// The map is cut into rows of 32 pixels; a torn row's tear is a stretch of it, from 6
	// to 10 pixels tall at a random height in the row (Ryan, 23 September: the old fixed
	// six was too thin, 28 too tall), and from 120 to 260 wide at a random place along it
	// (the little ones looked out of place).
	float band = floor(px.y / 32.0);
	float tick = floor(TIME * 3.5);   // a tear holds under 0.3 s (Ryan, 23 September)
	vec2 mouth = sources[0].xy - vec2(0.0, sources[0].z * 0.75);
	float near = source_count > 0 ? 1.0 - smoothstep(sources[0].z * 0.5, sources[0].z * 1.0, distance(px, mouth)) : 0.0;
	float h1 = fract(sin(band * 12.9898 + tick * 7.31) * 43758.5453);
	float h2 = fract(sin(band * 3.117 + tick * 5.19 + 1.3) * 27183.1);
	float h3 = fract(sin(band * 8.233 + tick * 2.71 + 4.1) * 19937.7);
	float h4 = fract(sin(band * 5.71 + tick * 9.13 + 2.9) * 31337.3);
	float h5 = fract(sin(band * 2.39 + tick * 4.47 + 7.7) * 12289.9);
	float seg_x0 = h2 * map_size.x;
	float seg_len = mix(120.0, 260.0, h3);
	float tear_h = mix(6.0, 10.0, h4);   // always thinner than the vortex's 16-pixel bands
	float tear_y0 = band * 32.0 + h5 * (32.0 - tear_h);
	float in_seg = step(seg_x0, px.x) * step(px.x, seg_x0 + seg_len) * step(tear_y0, px.y) * step(px.y, tear_y0 + tear_h);
	// Per row per tick: on the field enough that a tear or two usually shows (Ryan, 23
	// September, halved from one to three); a little more around the rift's mouth.
	float flick = step(mix(0.988, 0.96, near), h1) * in_seg * flicker;
	// The skirmish's tear (tear.gdshader) is the model, Ryan, 23 September: the slice
	// shears by a shift that jitters every few frames while it holds, up to 18 pixels
	// either way, with only a light dim (its hairlines were tried here and cut).
	float sub = floor(TIME * 16.0);
	float h6 = fract(sin(band * 4.13 + tick * 3.37 + sub * 1.7 + 5.5) * 15731.3);
	float shear = flick * (h6 - 0.5) * 24.0 * mix(1.0, 1.3, near);
	vec2 opx = px + vec2(shear, 0.0);
	// The other world runs at two frames, the old way.
	bool second = mod(floor(TIME * anim_rate), 2.0) > 0.5;
	vec4 other = second ? blurred_other2(opx / map_size, 1.0 / (map_size * zoom), rad) : blurred_other(opx / map_size, 1.0 / (map_size * zoom), rad);
	other.rgb = floor(other.rgb * levels + 0.5) / levels;
	other.rgb *= 1.0 - 0.12 * flick;
	// Where a machine is, the reconstruction wins whatever the bleed says: the machines
	// are its own and never go under the painting (Ryan, 22 September). The units layer
	// is a mask only; the pixel comes from the scene, so the wall and the crags still
	// stand in front of a machine behind them.
	// One rule for the machines (Ryan, 22 September): under the painting the
	// reconstruction's geometry is gone, so a machine there is drawn from its own layer,
	// nothing in front of it; on the reconstruction the scene's pixel wins, with its real
	// depth, so the wall and the crags stand in front of a machine behind them. The
	// units layer's translucent part (a flyer's shadow) falls on the painting the same way.
	// Each side reads only its own: the machines' layer where the painting shows, the scene
	// where it does not (the units layer is the scene's size, so one texel serves both).
	if (k > bayer(c)) {
		vec4 u = aa_here ? fxaa_at(units_lin, UV, TEXTURE_PIXEL_SIZE) : blurred_units(UV, 1.0 / view_size, rad);
		COLOR = other;
		COLOR.rgb = mix(COLOR.rgb, u.rgb, u.a);
	} else {
		COLOR = aa_here ? fxaa_at(scene_lin, UV, TEXTURE_PIXEL_SIZE) : blurred_scene(TEXTURE, UV, 1.0 / view_size, rad);
	}
	if (outline_px > 0.0) {
		// Over either world, and gone where the ground blurs: a sharp ring round a soft machine
		// reads as a sticker.
		float ring = outline_at(UV, TEXTURE_PIXEL_SIZE) * (1.0 - clamp(rad / 1.5, 0.0, 1.0));
		COLOR.rgb = mix(COLOR.rgb, outline_color.rgb, ring);
		COLOR.a = max(COLOR.a, ring);
	}
	float luma = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
	COLOR.rgb = mix(vec3(luma), COLOR.rgb, saturation) * brightness;
	// No fade to black at the sides: the blur alone is the edge of what the table resolves.
}
