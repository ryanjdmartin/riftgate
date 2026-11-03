// A blow on a machine's hull (the to-do's hit reaction, on Ryan's go of 3 November: the struck
// side flashes for a beat in heat's red-orange, never white): laid over every
// surface of the model as its overlay for a beat, in heat's colour, mixed over the hull rather
// than added so it holds its colour on a white hull as on a black one, strongest on the faces
// toward the side the blow came from (MechView3D.hit).
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec3 colour = vec3(1.0, 0.25, 0.0);
uniform float strength = 0.0;            // 0 to 1, the flash's beat now
uniform vec3 toward = vec3(0.0, 0.6, 0.8);   // the side the blow came from, in view space

void fragment() {
	float face = 0.55 + 0.45 * max(dot(normalize(NORMAL), normalize(toward)), 0.0);
	ALBEDO = colour;
	ALPHA = clamp(strength * face, 0.0, 1.0);
}
