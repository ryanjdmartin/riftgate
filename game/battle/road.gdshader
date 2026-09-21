// A road hex, drawn rather than tiled (Ryan, 21 September: roads must meet). `links` says
// which of the six neighbours are road (bit i for Hex.DIRECTIONS[i]); a deck runs from the
// hex centre to each linked edge, so adjoining road hexes make one continuous road. The
// rest of the hex is concrete shoulder from the terrain tile. Kerbs, a worn guide line,
// and guide lamps along the verges, some still lit and glowing. UV is the hex inscribed in
// the unit square (Map3D._column_mesh), pointy-top, y down the screen.
shader_type spatial;
render_mode cull_disabled;

uniform sampler2D tile : source_color, filter_nearest, repeat_enable;   // the shoulder
uniform float tile_world = 40.0;
uniform float lift = 1.35;
instance uniform int links = 0;
instance uniform float seed = 0.0;

const float HALF_W = 0.17;   // deck half width in UV
const float KERB = 0.19;

varying vec3 wpos;

float hash(float n) {
	return fract(sin(n) * 43758.5453);
}

void fragment() {
	vec2 p = UV - vec2(0.5);
	// Edge midpoints of the six neighbours, in UV units: to_pixel(dir) / (2 * hex) / 2.
	const float S3 = 0.8660254;
	vec2 mids[6] = {vec2(S3 * 0.5, 0.0), vec2(S3 * 0.25, -0.375), vec2(-S3 * 0.25, -0.375),
	                vec2(-S3 * 0.5, 0.0), vec2(-S3 * 0.25, 0.375), vec2(S3 * 0.25, 0.375)};
	float d_min = 1.0;
	float lamp = 0.0;
	float lit = 0.0;
	for (int i = 0; i < 6; i++) {
		if ((links & (1 << i)) == 0) {
			continue;
		}
		vec2 m = mids[i];
		float t = clamp(dot(p, m) / dot(m, m), 0.0, 1.0);
		float d = length(p - m * t);
		d_min = min(d_min, d);
		// Lamps on both verges at three stations along the segment.
		vec2 nrm = normalize(vec2(-m.y, m.x));
		for (int k = 0; k < 3; k++) {
			float tk = 0.3 + 0.28 * float(k);
			for (int s = -1; s <= 1; s += 2) {
				vec2 lp = m * tk + nrm * float(s) * (KERB + 0.03);
				if (length(p - lp) < 0.018) {
					lamp = 1.0;
					lit = step(0.6, hash(seed + float(i) * 7.1 + float(k) * 3.3 + float(s) * 1.7));
				}
			}
		}
	}
	if (links == 0) {
		d_min = length(p);   // a lone slab: a pad
	}
	vec2 wuv = vec2(wpos.x, wpos.z) / tile_world;
	vec3 shoulder = texture(tile, wuv).rgb * lift * 1.05;   // pale concrete against a near-black deck
	vec3 deck = vec3(0.07, 0.08, 0.09) * (0.92 + 0.08 * hash(floor(wpos.x * 0.5) + floor(wpos.z * 0.5) * 91.0));
	vec3 col = shoulder;
	if (d_min < HALF_W) {
		col = deck;
		if (d_min < 0.007) {
			col = vec3(0.34, 0.36, 0.34);   // the guide line
		}
	} else if (d_min < KERB) {
		col = vec3(0.24, 0.25, 0.24);       // the kerb
	}
	vec3 emit = vec3(0.0);
	if (lamp > 0.5) {
		col = (lit > 0.5) ? vec3(1.0, 0.78, 0.35) : vec3(0.22, 0.18, 0.12);
		emit = (lit > 0.5) ? vec3(1.0, 0.7, 0.3) * 1.6 : vec3(0.0);
	}
	ALBEDO = min(col, vec3(1.0));
	EMISSION = emit;
	ROUGHNESS = 0.95;
	METALLIC = 0.0;
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
