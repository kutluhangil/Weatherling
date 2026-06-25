// Katmanlı, yavaş kayan sis. (Plan §11.3) Compatibility (GLES3) uyumlu.
shader_type canvas_item;

uniform vec4 fog_color : source_color = vec4(0.80, 0.82, 0.87, 1.0);
uniform float density : hint_range(0.0, 1.0) = 0.38;
uniform float speed = 0.03;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(41.3, 289.1))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	vec2 uv = UV * 3.0;
	float t = TIME * speed;
	float n = noise(uv + vec2(t, 0.0)) * 0.6 + noise(uv * 2.0 + vec2(-t, t * 0.5)) * 0.4;
	float a = smoothstep(0.25, 0.9, n) * density;
	COLOR = vec4(fog_color.rgb, a);
}
