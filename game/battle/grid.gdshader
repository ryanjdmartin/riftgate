// The hex grid's light: the trace's scan (trace.gdshader's; keep the two alike) on a ribbon
// whose line keeps one width on screen at every zoom (Ryan, 30 October: "I don't want the
// outline to thicken as I zoom in", and the grid's lines thickened with it). The ribbon is
// wider than the line; UV.x is how far in from the column's edge a point is, in map pixels,
// and the line is drawn from `inset_px` to `inset_px + line_px` of this viewport's pixels in
// from the edge, each side smoothed over a pixel, so nothing steps where the phone has no MSAA.
shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never;

uniform vec3 color : source_color = vec3(0.2, 1.0, 0.33);
uniform float base = 0.42;       // steady brightness: 0 rests as ink
uniform float pulse = 1.1;       // the extra at the scan's leading edge
uniform float gain = 1.0;        // the tuner's overall multiplier
uniform float sweep_p = -1.0e6;  // the scan band's projected depth along `screen_down`, in world units
uniform vec3 screen_down = vec3(0.0, -0.743, 0.669);
uniform float lead = 10.0;
uniform float tail = 75.0;
uniform float line_px = 2.25;    // the line's width, in this viewport's pixels
uniform float inset_px = 0.6;    // where it starts in from the column's edge, in this viewport's pixels

varying vec3 wpos;
varying float across;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	across = UV.x;
}

void fragment() {
	// `across` is affine over each triangle, so its screen gradient is exact: pixels in from
	// the edge, measured square to it on screen whatever the edge's angle or the zoom.
	float per_px = length(vec2(dFdx(across), dFdy(across)));
	float d = across / max(per_px, 1.0e-6);
	// The pixel's share of the line, its footprint a pixel wide across it.
	float cover = clamp(min(d + 0.5, inset_px + line_px) - max(d - 0.5, inset_px), 0.0, 1.0);
	if (cover <= 0.0) {
		discard;
	}
	float s = dot(wpos, screen_down) - sweep_p;
	float w = (s > 0.0) ? exp(-(s / lead) * (s / lead)) : exp(s / tail * 1.6);
	float k = (base + pulse * w) * gain;
	ALBEDO = color * min(k, 1.0);
	EMISSION = color * max(k - 0.35, 0.0) * 1.1;
	ALPHA = 0.9 * cover;
}
