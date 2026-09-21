// The columns' tops wear the gritty ground texture: each samples the flat map by its world
// position, so the marks live in one texture and a raised hex still shows the right
// picture. Lit, so the sun and the shadows read on it and the 3D side stays muted.
shader_type spatial;
render_mode cull_disabled;

uniform sampler2D painted : source_color, filter_nearest;
uniform vec2 origin = vec2(0.0, 0.0);     // where hex (0,0) sits in the map, in pixels
uniform vec2 map_size = vec2(1.0, 1.0);
uniform float ppu = 1.0;                  // screen pixels per model unit
uniform float sin_pitch = 1.0;            // depth is stretched by this, so undo it

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 px = vec2(wpos.x * ppu + origin.x, wpos.z * ppu * sin_pitch + origin.y);
	// Lifted a little: the painted colours were tuned unlit, and the sun only half lights a flat top.
	ALBEDO = min(texture(painted, px / map_size).rgb * 1.45, vec3(1.0));
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}
