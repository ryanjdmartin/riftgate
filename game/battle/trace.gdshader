// The display's trace: the edges of a thing drawn as light. Additive, unshaded, never
// writing depth, so it glows over the surface it outlines. The scan band drifting down the
// screen brightens the traces it passes over (`sweep_z`, the band's world depth, set every
// frame by the map view), so the overlay reads as being refreshed by the scan, not drawn
// once (Ryan, 21 September).
shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_never;

uniform vec3 color : source_color = vec3(0.2, 1.0, 0.33);
uniform float base = 0.55;       // steady brightness: a high floor, so the lines always read
uniform float pulse = 1.6;       // the extra at the scan's leading edge, past the bloom threshold
uniform float gain = 1.0;        // the tuner's overall multiplier
uniform float sweep_p = -1.0e6;  // the scan band's projected depth: map pixels below hex (0,0), per unit
uniform float sin_pitch = 0.669; // the camera's pitch, so a tall thing's top counts where it appears on screen
uniform float cos_pitch = 0.743;
uniform float lead = 10.0;       // projected units the light reaches ahead of the band: it snaps on
uniform float tail = 55.0;       // projected units the light lingers behind it: it fades in the wake

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Light snaps on just ahead of the band and decays behind it, like a wake.
	// Where this point sits on screen, not on the ground: height lifts it toward the bar.
	float d = (wpos.z * sin_pitch - wpos.y * cos_pitch) - sweep_p;
	float w = (d > 0.0) ? exp(-(d / lead) * (d / lead)) : exp(d / tail * 2.2);
	float k = (base + pulse * w) * gain;
	ALBEDO = color * min(k, 1.0);
	EMISSION = color * k * 1.1;   // over 1 under the band, where the glow pass blooms it
	ALPHA = 0.85;
}
