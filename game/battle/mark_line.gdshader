// A ground mark's edge (Map3D.set_marks): a line that keeps one width on screen at every
// zoom, smoothed, the same way as the grid's (grid.gdshader; keep the two alike). UV.x is how
// far in from the hex's edge a point is, in map pixels; the line runs from `inset_px` to
// `inset_px + line_px` of this viewport's pixels in from it.
shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never;

uniform vec4 color : source_color = vec4(1.0);
uniform float line_px = 1.5;   // the line's width, in this viewport's pixels
uniform float inset_px = 0.6;  // where it starts in from the hex's edge, in this viewport's pixels

varying float across;

void vertex() {
	across = UV.x;
}

void fragment() {
	float per_px = length(vec2(dFdx(across), dFdy(across)));
	float d = across / max(per_px, 1.0e-6);
	float cover = clamp(min(d + 0.5, inset_px + line_px) - max(d - 0.5, inset_px), 0.0, 1.0);
	if (cover <= 0.0) {
		discard;
	}
	ALBEDO = color.rgb;
	ALPHA = color.a * cover;
}
