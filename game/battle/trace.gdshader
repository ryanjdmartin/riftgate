// The display's trace: the edges of a thing drawn as light, or as ink that the scan
// lights. Unshaded, never writing depth, so it draws over the surface it outlines. The
// scan band drifting down the screen brightens the traces it passes over (`sweep_p`, the
// band's depth along `screen_down`, set every frame), snapping on just ahead of the band
// and fading in its wake (Ryan, 21 September). With `base` at zero the lines rest as black
// ink and only the scan brings them up: the pulse mode (Ryan, 22 September).
shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never;

uniform vec3 color : source_color = vec3(0.2, 1.0, 0.33);
uniform float base = 0.42;       // steady brightness: 0 rests as ink
uniform float pulse = 1.1;       // the extra at the scan's leading edge, past the bloom threshold (1.6 was a bit much on the phone: Ryan, 29 September)
uniform float gain = 1.0;        // the tuner's overall multiplier
uniform float sweep_p = -1.0e6;  // the scan band's projected depth along `screen_down`, in world units
uniform vec3 screen_down = vec3(0.0, -0.743, 0.669);   // the world direction that runs down the screen, so height counts
uniform float lead = 10.0;       // projected units the light reaches ahead of the band: it snaps on
uniform float tail = 75.0;        // projected units the light lingers behind it: it fades in the wake

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float d = dot(wpos, screen_down) - sweep_p;
	float w = (d > 0.0) ? exp(-(d / lead) * (d / lead)) : exp(d / tail * 1.6);
	float k = (base + pulse * w) * gain;
	ALBEDO = color * min(k, 1.0);
	EMISSION = color * max(k - 0.35, 0.0) * 1.1;
	ALPHA = 0.9;
}
