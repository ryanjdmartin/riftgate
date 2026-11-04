// One-line dark outline around the opaque shape, the spriter's, drawn into transparent
// neighbours. width is in texture pixels; 1 for the pixel look, 2 for the clean look.
// A lit part's halo (halo.gdshader) reaches here as a soft fringe, its alpha under a half and its
// colour premultiplied by the 3D pass: it passes through, un-premultiplied, and blend_premul_alpha
// stores every pixel as given, so this view holds straight alpha and the screen's own blending lays
// the fringe over the field (an opaque pixel, the line and the clear ones are unchanged by it).
shader_type canvas_item;
render_mode blend_premul_alpha;

uniform vec4 line : source_color = vec4(0.102, 0.114, 0.137, 1.0);
uniform float width = 1.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (c.a >= 0.5) {
		COLOR = vec4(c.rgb, 1.0);
	} else {
		vec2 px = TEXTURE_PIXEL_SIZE * width;
		vec4 n = vec4(texture(TEXTURE, UV + vec2(px.x, 0.0)).a, texture(TEXTURE, UV - vec2(px.x, 0.0)).a,
			texture(TEXTURE, UV + vec2(0.0, px.y)).a, texture(TEXTURE, UV - vec2(0.0, px.y)).a);
		if (c.a <= 0.004) {
			COLOR = dot(n, vec4(1.0)) >= 0.5 ? line : vec4(0.0);   // a clear pixel, as it always was
		} else if (dot(step(vec4(0.5), n), vec4(1.0)) >= 0.5) {
			COLOR = line;   // a soft pixel against the shape: the outline
		} else {
			COLOR = vec4(c.rgb / c.a, c.a);   // a halo's soft fringe, its colour un-premultiplied
		}
	}
}
