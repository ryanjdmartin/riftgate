shader_type canvas_item;
render_mode unshaded;

// The skirmish's floor (29 October, the field): our side's ground as the floor's camera sees
// it, the camera level at `cam_h` hexes with its centre on the horizon over the band's middle,
// `focal` pixels deep; the reconstruction's tile laid on it, lit in the middle and dimmed at the
// edges, and the display's hex grid, a row of hex centres through the machines' feet (`shift`),
// fading where a hex would be too small to read. Pixelated on the sprites' grid. Above `seam_y`
// it gives way to the other world painted under it through a dithered edge of cells.

uniform sampler2D tile : repeat_enable, filter_nearest;
uniform vec2 band_size = vec2(720.0, 300.0);
uniform float horizon = 0.0;       // the vanishing line, in the band's pixels
uniform float focal = 1000.0;      // the camera's focal length, in pixels
uniform float cam_h = 3.4;         // the camera's height, in hexes (a hex is one across)
uniform float shift = 0.0;         // the lattice's offset in depth, in hexes
uniform float tiles = 1.4;         // the tile's repeats across a hex
uniform float art_px = 1.0;        // design pixels an art pixel
uniform float dim = 0.62;
uniform vec4 hud : source_color = vec4(0.36, 1.0, 0.42, 1.0);
uniform float grid_alpha = 0.14;
uniform float grid_fade = 140.0;   // the grid is whole where a hex is a sixth of this on the glass, gone under a sixteenth
uniform float seam_y = -1.0e6;     // where the floor starts; above it, nothing of it
uniform float seam_band = 30.0;
uniform float seam_amp = 9.0;

varying vec2 local;

void vertex() {
	local = VERTEX;
}

float bayer(vec2 c) {
	int x = int(mod(c.x, 4.0));
	int y = int(mod(c.y, 4.0));
	int m[16] = int[16](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	return (float(m[y * 4 + x]) + 0.5) / 16.0;
}

const vec2 HS = vec2(1.0, 1.7320508);

// How far inside its hex a point is: 0 on an edge, 0.5 at the centre (pointy-top, as the map).
float hex_inside(vec2 uv) {
	vec4 hc = floor(vec4(uv, uv - vec2(0.5, 1.0)) / HS.xyxy) + 0.5;
	vec4 h = vec4(uv - hc.xy * HS, uv - (hc.zw + 0.5) * HS);
	vec2 q = dot(h.xy, h.xy) < dot(h.zw, h.zw) ? h.xy : h.zw;
	q = abs(q);
	return 0.5 - max(dot(q, HS * 0.5), q.x);
}

void fragment() {
	vec2 cell = floor(local / art_px);
	vec2 p = (cell + 0.5) * art_px;
	// The hand-over: below a wandering line the floor, above it the other world, between them
	// the cells trading places by the ordered dither.
	float sy = seam_y + sin(p.x * 0.021) * seam_amp + sin(p.x * 0.057 + 1.3) * seam_amp * 0.45;
	float st = clamp((p.y - sy) / seam_band, 0.0, 1.0);
	if (bayer(cell) > st) {
		COLOR = vec4(0.0);
	} else {
		float d = max(p.y - horizon, 1.0);
		vec2 world = vec2((p.x - band_size.x * 0.5) * cam_h / d, focal * cam_h / d);
		// One art pixel's reach on the floor, the larger of its two ways, so a grid line stays a
		// pixel thick however far off; and a hex's size on the glass, its tighter way.
		float reach = max(cam_h / d, focal * cam_h / (d * d)) * art_px;
		float hex_px = min(d / cam_h, d * d / (focal * cam_h));
		float legible = smoothstep(grid_fade * 0.06, grid_fade * 0.16, hex_px);
		vec3 col = texture(tile, world * tiles).rgb * dim;
		float side = abs(p.x / band_size.x - 0.5) * 2.0;
		col *= 1.0 - 0.4 * side * side;
		col *= mix(1.05, 0.72, smoothstep(0.55, 1.0, p.y / band_size.y));
		float edge = hex_inside(vec2(world.x, world.y - shift));
		float line = step(edge, reach * 0.75) * legible;
		COLOR = vec4(mix(col, hud.rgb, line * grid_alpha), 1.0);
	}
}
