// The display's trace: the edges of a thing drawn as light. Additive, unshaded, never
// writing depth, so it glows over the surface it outlines. A slow wave of brightness rolls
// north across the field so the overlay reads as being generated from live data, not
// drawn once (Ryan, 21 September).
shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_never;

uniform vec3 color : source_color = vec3(0.2, 1.0, 0.33);
uniform float base = 0.55;      // steady brightness
uniform float pulse = 0.45;     // the wave's extra
uniform float wave_len = 220.0; // model units per wave
uniform float speed = 1.6;      // waves per second, southward

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float w = 0.5 + 0.5 * sin(TIME * speed * 6.2831 + wpos.z / wave_len * 6.2831);
	float k = base + pulse * w * w;
	ALBEDO = color * k;
	EMISSION = color * k * 0.8;   // enough to glow, not enough to fatten the line
	ALPHA = 0.85;
}
