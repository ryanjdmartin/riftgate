// A terrain column's material: a tile from art/terrain sampled by world position, so the
// battlefield wears the same kind of texture as the units and the walls (decided 21
// September). Lit, with shadows. Water ripples: the sample drifts and the tone breathes.
shader_type spatial;
render_mode cull_disabled;

uniform sampler2D tile : source_color, filter_nearest, repeat_enable;
uniform float tile_world = 40.0;   // world units one tile covers
uniform float ripple = 0.0;        // 1 on water
uniform float lift = 1.0;          // brightness, since the tiles were tuned unlit

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv = vec2(wpos.x, wpos.z) / tile_world;
	float breathe = 1.0;
	if (ripple > 0.0) {
		uv += vec2(sin(TIME * 1.3 + wpos.z * 0.12), cos(TIME * 1.1 + wpos.x * 0.10)) * 0.025 * ripple;
		breathe = 1.0 + 0.07 * ripple * sin(TIME * 2.0 + wpos.x * 0.25 + wpos.z * 0.2);
	}
	ALBEDO = min(texture(tile, uv).rgb * lift * breathe, vec3(1.0));
	ROUGHNESS = 0.95;
	METALLIC = 0.0;
}
