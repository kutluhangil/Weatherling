// Gün-gece renk geçişi — tam ekran CanvasModulate shader'ı.
// Faz (dawn/day/dusk/night) ve is_day değerine göre sahneyi renk-sınıflandırır.
// Plan §11.2: color grading lerp; tek geçişli, düşük maliyet (Compatibility renderer).
shader_type canvas_item;

// Aktif palet rengi (GDScript tarafından uniform olarak set edilir)
uniform vec3 tint_color : source_color = vec3(1.0, 1.0, 1.0);
// Blend gücü (0 = orijinal, 1 = tam tint)
uniform float tint_strength : hint_range(0.0, 1.0) = 0.0;
// Parlaklık çarpanı
uniform float brightness : hint_range(0.3, 1.5) = 1.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	// Renk sıcaklığı karıştır
	vec3 tinted = mix(col.rgb, col.rgb * tint_color, tint_strength);
	// Parlaklık uygula
	COLOR = vec4(tinted * brightness, col.a);
}
