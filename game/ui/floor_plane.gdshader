shader_type canvas_item;
render_mode unshaded;

// A floor in perspective for the skirmish's ground (29 October, the options behind
// RIFTGATE_SKIRMISH_BG): a plane seen from behind the machines, pixelated on the sprites'
// grid and wearing the display's hex grid. Mode 0 lays the reconstruction's tile on it,
// dimmed, lit in the middle and fogged far off; mode 1 is the holo-table, a dark floor with
// the grid and the ground's relief drawn as contours. Above `seam_y` it hands over to what is
// drawn under it through a dithered edge of cells, the grid carrying on across.

uniform int mode = 0;
uniform sampler2D tile : repeat_enable, filter_nearest;
uniform sampler2D relief : repeat_enable, filter_linear;
uniform vec2 band_size = vec2(720.0, 300.0);
uniform float horizon = -300.0;      // the vanishing line, in the band's pixels (above it: negative)
uniform float tile_px = 96.0;        // a tile's width at the band's foot
uniform float foreshorten = 0.5;     // a tile's height over its width at the foot
uniform float art_px = 1.0;          // design pixels an art pixel
uniform float dim = 0.6;
uniform vec4 hud : source_color = vec4(0.36, 1.0, 0.42, 1.0);
uniform float grid_alpha = 0.16;
uniform float hex_tiles = 1.6;       // a grid hex's size, in tiles
uniform float contour_alpha = 0.2;
uniform float contours = 6.0;
uniform vec4 fog : source_color = vec4(0.027, 0.035, 0.027, 1.0);
uniform float fog_top = 0.0;         // the band's top fades from the fog over this many pixels
uniform float seam_y = -1.0e6;       // where the floor starts; above it only the grid
uniform float seam_band = 30.0;
uniform float seam_amp = 9.0;
uniform float grid_fade = 140.0;     // the grid is whole where a hex is a sixth of this on the glass, gone under a sixteenth

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

vec2 ground(vec2 p, float foot) {
	float d = max(p.y - horizon, 1.0);
	float k = foot / tile_px;
	return vec2((p.x - band_size.x * 0.5) * k / d, foot * k / (foreshorten * d));
}

void fragment() {
	vec2 cell = floor(local / art_px);
	vec2 p = (cell + 0.5) * art_px;
	float foot = band_size.y - horizon;
	float d = max(p.y - horizon, 1.0);
	vec2 world = ground(p, foot);
	// One art pixel's reach on the ground, the larger of its two ways: what a line a pixel
	// wide covers, so the grid and the contours stay a pixel thick however far off.
	float k = foot / tile_px;
	float reach = max(k / d, foot * k / (foreshorten * d * d)) * art_px;
	// A grid hex's size on the glass, its tighter way: the grid and the contours fade out where
	// the hexes would be too small to read, rather than turn to static toward the horizon.
	float hex_px = hex_tiles * min(d / k, foreshorten * d * d / (foot * k));
	float legible = smoothstep(grid_fade * 0.06, grid_fade * 0.16, hex_px);

	vec3 col;
	if (mode == 0) {
		col = texture(tile, world).rgb * dim;
		float side = abs(p.x / band_size.x - 0.5) * 2.0;
		col *= 1.0 - 0.4 * side * side;
		col *= mix(1.05, 0.7, smoothstep(0.55, 1.0, p.y / band_size.y));
	} else {
		col = fog.rgb;
		float n = texture(relief, world * 0.09).r * contours;
		float nx = texture(relief, ground(p + vec2(art_px, 0.0), foot) * 0.09).r * contours;
		float ny = texture(relief, ground(p + vec2(0.0, art_px), foot) * 0.09).r * contours;
		float slope = max(abs(nx - n), abs(ny - n));
		float c = fract(n);
		float on = step(min(c, 1.0 - c), max(slope * 0.6, 0.004));
		col = mix(col, hud.rgb, on * contour_alpha * legible);
	}
	float edge = hex_inside(world / hex_tiles);
	float line = step(edge, reach / hex_tiles * 0.75) * legible;
	float galpha = grid_alpha * (mode == 1 ? 2.2 : 1.0);
	col = mix(col, hud.rgb, line * galpha);
	if (fog_top > 0.0) {
		col = mix(fog.rgb, col, smoothstep(0.0, fog_top, p.y));
	}
	// The hand-over: below a wandering line the floor, above it only the grid, between them
	// the cells trading places by the ordered dither.
	float sy = seam_y + sin(p.x * 0.021) * seam_amp + sin(p.x * 0.057 + 1.3) * seam_amp * 0.45;
	float st = clamp((p.y - sy) / seam_band, 0.0, 1.0);
	if (bayer(cell) > st) {
		COLOR = vec4(hud.rgb, line * galpha * 0.8);
	} else {
		COLOR = vec4(col, 1.0);
	}
}
