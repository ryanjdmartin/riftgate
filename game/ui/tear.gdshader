shader_type canvas_item;

// The corrupted side's tear, over everything on it: one or two slices of what is already
// drawn (ground and sprites alike) redrawn displaced and dimmed, with a bright hairline on
// top and a dark one under. TearLayer sets the slices in this rect's UV and the shift as a
// fraction of the screen's width (the layer spans it). Outside a slice the layer is clear.

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest, repeat_disable;
uniform int count = 0;
uniform vec4 slice0 = vec4(0.0);   // x, y, w, h in this rect's UV
uniform vec4 slice1 = vec4(0.0);
uniform float shift0 = 0.0;        // sideways, as a fraction of the screen's width
uniform float shift1 = 0.0;
uniform float dim0 = 0.0;
uniform float dim1 = 0.0;
uniform float px_y = 0.002;        // one of this rect's pixels, in UV

void fragment() {
	vec4 out_col = vec4(0.0);
	for (int i = 0; i < 2; i++) {
		if (i >= count) {
			break;
		}
		vec4 s = i == 0 ? slice0 : slice1;
		float sh = i == 0 ? shift0 : shift1;
		float dm = i == 0 ? dim0 : dim1;
		if (UV.x >= s.x && UV.x < s.x + s.z && UV.y >= s.y && UV.y < s.y + s.w) {
			vec3 c = texture(screen_tex, SCREEN_UV + vec2(sh, 0.0)).rgb * (1.0 - dm);
			if (UV.y < s.y + px_y) {
				c += vec3(0.25);
			} else if (UV.y > s.y + s.w - px_y) {
				c *= 0.6;
			}
			out_col = vec4(c, 1.0);
		}
	}
	COLOR = out_col;
}
