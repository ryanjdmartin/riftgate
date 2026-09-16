// One-line dark outline around the opaque shape, the spriter's, drawn into transparent
// neighbours. width is in texture pixels; 1 for the pixel look, 2 for the clean look.
shader_type canvas_item;

uniform vec4 line : source_color = vec4(0.102, 0.114, 0.137, 1.0);
uniform float width = 1.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (c.a >= 0.5) {
		COLOR = vec4(c.rgb, 1.0);
	} else {
		vec2 px = TEXTURE_PIXEL_SIZE * width;
		float a = texture(TEXTURE, UV + vec2(px.x, 0.0)).a
			+ texture(TEXTURE, UV - vec2(px.x, 0.0)).a
			+ texture(TEXTURE, UV + vec2(0.0, px.y)).a
			+ texture(TEXTURE, UV - vec2(0.0, px.y)).a;
		COLOR = a >= 0.5 ? line : vec4(0.0);
	}
}
