// A waterfall down a chasm's wall, where a flooded stretch of the gorge spills into the chasm beside
// it (Ryan, 16 November: "Is there any way to get a water tile on Gorge to waterfall if it touches a
// chasm?"). UV.x runs along the lip, UV.y down the fall: the water tile sliding down, lanes of foam
// falling at their own pace, white at the lip and the foot, darkening down into the chasm as its
// rock does (Map3D.CHASM_FLOOR_SHADE).
shader_type spatial;
render_mode cull_disabled;

uniform sampler2D tile : source_color, filter_nearest, repeat_enable;
uniform float lift = 1.35;          // brightness, since the tiles were tuned unlit
uniform float speed = 1.1;          // the fall's lengths a second
uniform float lanes = 14.0;         // foam lanes along the lip
uniform float fade_floor = 0.45;    // how dark at the foot, a share of the lit tone
uniform vec3 foam = vec3(0.86, 0.94, 1.0);

float hash(float n) {
	return fract(sin(n * 12.9898) * 43758.5453);
}

void fragment() {
	vec2 uv = vec2(UV.x * 1.4, UV.y * 2.2 - TIME * speed);
	vec3 water = texture(tile, uv).rgb * lift * 1.1;
	float lane = floor(UV.x * lanes);
	float h = hash(lane + 1.0);
	float run = fract(UV.y * 2.4 - TIME * speed * (0.75 + 0.6 * h) + h * 5.0);
	float streak = smoothstep(0.62, 0.95, run) * step(0.3, h);
	vec3 col = mix(water, foam, streak * 0.7);
	col = mix(col, foam, (1.0 - smoothstep(0.0, 0.07, UV.y)) * 0.8);    // the lip breaking white
	col = mix(col, foam, smoothstep(0.88, 1.0, UV.y) * 0.55);          // the spray at the foot
	ALBEDO = min(col * mix(1.0, fade_floor, UV.y), vec3(1.0));
	ROUGHNESS = 0.35;
	METALLIC = 0.0;
}
