// The display's trace: the edges of a thing drawn as light. Additive, unshaded, never
// writing depth, so it glows over the surface it outlines. The scan band drifting down the
// screen brightens the traces it passes over (`sweep_z`, the band's world depth, set every
// frame by the map view), so the overlay reads as being refreshed by the scan, not drawn
// once (Ryan, 21 September).
shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_never;

uniform vec3 color : source_color = vec3(0.2, 1.0, 0.33);
uniform float base = 0.4;        // steady brightness
uniform float pulse = 1.8;       // the extra under the scan: past the bloom threshold, so it lights
uniform float gain = 1.0;        // the tuner's overall multiplier
uniform float sweep_z = -1.0e6;  // world z of the scan band
uniform float band = 90.0;       // half width of the brightened band, in world units

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float d = (wpos.z - sweep_z) / band;
	float w = exp(-d * d);
	float k = (base + pulse * w) * gain;
	ALBEDO = color * min(k, 1.0);
	EMISSION = color * k * 1.1;   // over 1 under the band, where the glow pass blooms it
	ALPHA = 0.85;
}
