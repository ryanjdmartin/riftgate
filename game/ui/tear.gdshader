shader_type canvas_item;

// Slices of what is already drawn under this rect (ground, sprites, a die alike) redrawn
// displaced sideways and a little dimmed: the corrupted side's tear over the foes, and a
// die's wobble. TearLayer sets the slices in this rect's UV and each shift as a fraction of
// the screen's width. Outside a slice the layer is clear.

const int MAX_SLICES = 8;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest, repeat_disable;
uniform int count = 0;
uniform vec4 slices[8];    // x, y, w, h in this rect's UV
uniform float shifts[8];   // sideways, as a fraction of the screen's width
uniform float dim = 0.12;

void fragment() {
	vec4 out_col = vec4(0.0);
	for (int i = 0; i < MAX_SLICES; i++) {
		if (i >= count) {
			break;
		}
		vec4 s = slices[i];
		if (UV.x >= s.x && UV.x < s.x + s.z && UV.y >= s.y && UV.y < s.y + s.w) {
			// No hairlines on the cut (Ryan, 23 September): the shift alone says it tore.
			out_col = vec4(texture(screen_tex, SCREEN_UV + vec2(shifts[i], 0.0)).rgb * (1.0 - dim), 1.0);
		}
	}
	COLOR = out_col;
}
