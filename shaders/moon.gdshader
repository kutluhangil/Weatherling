// Ay evresi — küresel normal · güneş yönü yöntemi (tüm evreler doğru). (Plan §11.2)
// phase: 0=yeniay, 0.25=ilk dördün, 0.5=dolunay, 0.75=son dördün.
shader_type canvas_item;

uniform float phase : hint_range(0.0, 1.0) = 0.5;
uniform vec4 lit_color : source_color = vec4(0.97, 0.96, 0.86, 1.0);
uniform float softness = 0.04;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;            // disk yerel koord -1..1
	float r2 = dot(p, p);
	if (r2 > 1.0) {
		COLOR = vec4(0.0);             // disk dışı şeffaf
	} else {
		float z = sqrt(1.0 - r2);      // ön yarımküre yüksekliği
		float th = phase * 6.28318530718;
		// normal·güneş > 0 → aydınlık. Güneş yönü = (sin th, 0, -cos th).
		float d = p.x * sin(th) - z * cos(th);
		float a = smoothstep(-softness, softness, d);
		COLOR = vec4(lit_color.rgb, lit_color.a * a);
	}
}
