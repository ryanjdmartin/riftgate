// Player mechs in 3D, shaded the way the spriter shades pixels: one fixed light, four tones
// per material, top faces bumped a tone. bands 4 is the pixel look (hard steps); bands 0 is
// the clean look: a smooth ramp through the same four tones, a rim, the baked wear layer
// (vertex colour: R occlusion, G pointiness), and a surface pass that needs no textures.
//
// The surface pass is procedural and per role, so it applies to every mech with no UV
// unwrapping: dust and mud low on the machine, rust streaks down from crevices on steel,
// paint chipped to bare metal on livery, tread bands on rubber, faint panel seams, a soft
// specular on steel, glass with a fresnel glow, lamps and nozzles emissive.
shader_type spatial;
render_mode unshaded, cull_back;

uniform vec4 tone0 : source_color = vec4(0.169, 0.188, 0.220, 1.0);
uniform vec4 tone1 : source_color = vec4(0.290, 0.322, 0.369, 1.0);
uniform vec4 tone2 : source_color = vec4(0.451, 0.490, 0.541, 1.0);
uniform vec4 tone3 : source_color = vec4(0.639, 0.675, 0.714, 1.0);
uniform int bands = 4;
uniform int role = 0;              // 0 steel, 1 steel_dark, 2 livery, 3 glass, 4 amber, 5 hot, 6 rubber
// The spriter's light (-0.45, -0.55, 0.7) in its x-right, y-forward, z-up world, mapped to
// Godot's y-up world: x stays, y becomes -z, z becomes y.
uniform vec3 light_dir = vec3(-0.45, 0.7, 0.55);
uniform float grime = 0.55;        // how dark a fully occluded crevice gets
uniform float wear = 0.6;          // how much convex edges brighten toward bare metal
uniform float dust = 0.5;          // how much the lower body takes dust and mud
uniform float rust = 0.45;         // rust streaking below crevices on steel
uniform float seams = 0.35;        // faint panel seams across plates
uniform float chips = 0.5;         // paint chipping on livery
uniform float dust_height = 9.0;   // model units above the ground where dust fades out
uniform vec4 bare_metal : source_color = vec4(0.72, 0.74, 0.76, 1.0);
uniform vec4 dust_colour : source_color = vec4(0.47, 0.42, 0.33, 1.0);
uniform vec4 rust_colour : source_color = vec4(0.38, 0.19, 0.09, 1.0);

varying vec3 world_pos;
varying vec3 obj_pos;
varying vec4 wear_data;

float hash3(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise3(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = mix(mix(hash3(i), hash3(i + vec3(1, 0, 0)), f.x), mix(hash3(i + vec3(0, 1, 0)), hash3(i + vec3(1, 1, 0)), f.x), f.y);
	float b = mix(mix(hash3(i + vec3(0, 0, 1)), hash3(i + vec3(1, 0, 1)), f.x), mix(hash3(i + vec3(0, 1, 1)), hash3(i + vec3(1, 1, 1)), f.x), f.y);
	return mix(a, b, f.z);
}

// A thin line where a coordinate crosses a multiple of period.
float seam_line(float u, float period, float width) {
	float d = abs(fract(u / period + 0.5) - 0.5) * period;
	return 1.0 - smoothstep(0.0, width, d);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	obj_pos = VERTEX;
	wear_data = COLOR;
}

void fragment() {
	vec3 n = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 l = normalize(light_dir);
	float ndl = dot(n, l);
	vec3 col;
	if (bands > 0) {
		int t = ndl > 0.62 ? 3 : (ndl > 0.22 ? 2 : (ndl > -0.25 ? 1 : 0));
		if (n.y > 0.85 && t < 3) {
			t += 1;
		}
		col = t == 0 ? tone0.rgb : (t == 1 ? tone1.rgb : (t == 2 ? tone2.rgb : tone3.rgb));
	} else {
		float k = clamp(ndl * 0.5 + 0.5, 0.0, 1.0);
		k = k * k * (3.0 - 2.0 * k);
		float p = min(k * 3.0, 2.999);
		vec3 a = p < 1.0 ? tone0.rgb : (p < 2.0 ? tone1.rgb : tone2.rgb);
		vec3 b = p < 1.0 ? tone1.rgb : (p < 2.0 ? tone2.rgb : tone3.rgb);
		col = mix(a, b, fract(p));
		vec3 to_cam = normalize((INV_VIEW_MATRIX * vec4(0.0, 0.0, 1.0, 0.0)).xyz);
		float rim = pow(1.0 - clamp(dot(n, to_cam), 0.0, 1.0), 3.0);
		col += rim * 0.12;
		if (n.y > 0.85) {
			col += 0.04;
		}

		// ---- the surface pass, per role
		bool baked = wear_data.g < 0.98 || wear_data.r < 0.98;
		float ao = baked ? wear_data.r : 1.0;
		float pointy = baked ? wear_data.g : 0.5;
		bool metal = role == 0 || role == 1;
		bool paint = role == 2;
		bool plate = metal || paint;

		if (plate) {
			// Faint panel seams in the plate's own space, along the two axes across the face.
			vec3 an = abs(n);
			vec2 uv = an.x > 0.7 ? obj_pos.zy : (an.y > 0.7 ? obj_pos.xz : obj_pos.xy);
			float s = max(seam_line(uv.x, 6.0, 0.18), seam_line(uv.y, 8.0, 0.18));
			col *= 1.0 - seams * 0.55 * s;
		}
		if (baked) {
			// Grime: crevices and undersides darken; a coarse noise keeps it from a gradient.
			float g = noise3(world_pos * 0.35) * 0.5 + 0.5;
			float crevice = 1.0 - smoothstep(0.35, 0.9, ao);
			col *= 1.0 - grime * crevice * (0.6 + 0.4 * g);
			// Rust: streaks running down from crevices on bare steel.
			if (metal) {
				float streak = noise3(vec3(world_pos.x * 2.6, world_pos.y * 0.35, world_pos.z * 2.6));
				float below = smoothstep(0.55, 0.95, streak) * crevice;
				col = mix(col, rust_colour.rgb, rust * below);
			}
			// Worn edges: convex edges lose paint to bare metal, patchily.
			float edge = smoothstep(0.56, 0.8, pointy);
			float patch = smoothstep(0.35, 0.75, noise3(world_pos * 1.7));
			col = mix(col, bare_metal.rgb, wear * edge * patch);
			// Chips: paint on livery flakes in small patches away from edges too.
			if (paint) {
				float chip = smoothstep(0.74, 0.8, noise3(world_pos * 2.4)) * smoothstep(0.4, 0.6, pointy);
				col = mix(col, bare_metal.rgb, chips * chip);
			}
		}
		if (role == 6) {
			// Tread bands across the run, which lies along the part's own z (Blender's y).
			float band = seam_line(obj_pos.z, 3.0, 0.9);
			col *= 1.0 - 0.45 * band;
		}
		// Dust and mud: the lower body, heavier on undersides and in the noise's dark pockets.
		float low = 1.0 - smoothstep(0.0, dust_height, world_pos.y);
		float mud = noise3(world_pos * 0.9) * 0.5 + 0.5;
		float dusty = low * (0.5 + 0.5 * mud) * (n.y < 0.0 ? 1.0 : 0.7);
		if (role != 3 && role != 4 && role != 5) {
			col = mix(col, dust_colour.rgb, dust * dusty);
		}
		// Fine scratches: a whisper of noise across every surface.
		col *= 0.94 + 0.06 * noise3(world_pos * 6.0);
		// Specular: a soft highlight on steel where the light reflects toward the camera.
		if (metal) {
			vec3 h = normalize(l + to_cam);
			float spec = pow(max(dot(n, h), 0.0), 24.0);
			col += spec * 0.18;
		}
		// Glass: fresnel glow. Lamps and nozzles: emissive, flat, bright.
		if (role == 3) {
			col = mix(col, tone3.rgb, 0.35) + rim * 0.5;
		} else if (role == 4 || role == 5) {
			col = tone3.rgb * 1.15;
		}
	}
	ALBEDO = col;
}
