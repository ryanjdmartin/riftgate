// Player mechs in 3D, shaded the way the spriter shades pixels: one fixed light, four tones
// per material, top faces bumped a tone. bands 4 is the pixel look (hard steps); bands 0 is
// the clean look (a smooth ramp through the same four tones plus a rim), and the clean look
// also reads the baked wear layer in the vertex colour: R is occlusion (grime in crevices),
// G is pointiness (bright worn metal on convex edges, darker in concave corners). A mesh
// with no bake has white vertex colour, which reads as "no data" and leaves the plate alone.
shader_type spatial;
render_mode unshaded, cull_back;

uniform vec4 tone0 : source_color = vec4(0.169, 0.188, 0.220, 1.0);
uniform vec4 tone1 : source_color = vec4(0.290, 0.322, 0.369, 1.0);
uniform vec4 tone2 : source_color = vec4(0.451, 0.490, 0.541, 1.0);
uniform vec4 tone3 : source_color = vec4(0.639, 0.675, 0.714, 1.0);
uniform int bands = 4;
// The spriter's light (-0.45, -0.55, 0.7) in its x-right, y-forward, z-up world, mapped to
// Godot's y-up world: x stays, y becomes -z, z becomes y.
uniform vec3 light_dir = vec3(-0.45, 0.7, 0.55);
uniform float grime = 0.55;        // how dark a fully occluded crevice gets
uniform float wear = 0.6;          // how much convex edges brighten toward bare metal
uniform vec4 bare_metal : source_color = vec4(0.72, 0.74, 0.76, 1.0);

varying vec3 world_pos;
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

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wear_data = COLOR;
}

void fragment() {
	vec3 n = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float ndl = dot(n, normalize(light_dir));
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
		// Wear, from the bake. White vertex colour means no bake: leave the plate alone.
		bool baked = wear_data.g < 0.98 || wear_data.r < 0.98;
		if (baked) {
			float ao = wear_data.r;
			float pointy = wear_data.g;
			// Grime: crevices and undersides darken; a coarse noise keeps it from looking like a gradient.
			float g = noise3(world_pos * 0.35) * 0.5 + 0.5;
			float crevice = 1.0 - smoothstep(0.35, 0.9, ao);
			col *= 1.0 - grime * crevice * (0.6 + 0.4 * g);
			// Worn edges: convex edges lose their paint to bare metal, patchily.
			float edge = smoothstep(0.56, 0.8, pointy);
			float patch = smoothstep(0.35, 0.75, noise3(world_pos * 1.7));
			col = mix(col, bare_metal.rgb, wear * edge * patch);
			// Fine scratches: a whisper of noise across every surface.
			col *= 0.94 + 0.06 * noise3(world_pos * 6.0);
		}
	}
	ALBEDO = col;
}
