// The 3D ground wears the painted map: each hex samples the flat map by its world position,
// so the terrain marks live in one texture and the 3D side fades into the very picture it
// stands on (decided 19 September). Unshaded, so the palette stays exact.
shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled;

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
	ALBEDO = texture(painted, px / map_size).rgb;
}
