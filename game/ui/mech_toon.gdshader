// Player mechs in 3D, shaded the way the spriter shades pixels: one fixed light, four tones
// per material, top faces bumped a tone. bands 4 is the pixel look (hard steps); bands 0 is
// the clean look (a smooth ramp through the same four tones plus a rim).
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
	}
	ALBEDO = col;
}
