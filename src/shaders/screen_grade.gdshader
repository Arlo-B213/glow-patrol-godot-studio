shader_type canvas_item;
// Soft violet vignette over the whole screen: darkens the corners and pulls the eye to the
// stage. Purely decorative, so it is drawn with no input handling.

uniform float strength : hint_range(0.0, 1.0) = 0.28;
uniform float softness : hint_range(0.2, 1.0) = 0.62;
uniform vec3 edge_tint : source_color = vec3(0.07, 0.02, 0.16);

void fragment() {
	vec2 uv = (UV - vec2(0.5)) * vec2(1.0, 1.08);
	float d = length(uv);
	float v = smoothstep(softness * 0.5, softness * 0.5 + 0.5, d);
	COLOR = vec4(edge_tint, v * strength);
}
