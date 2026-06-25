## Gece gökyüzü katmanı: yıldız alanı + doğru ay evresi. (Plan §11.2, Faz 2)
## Gündüz görünmez (faza göre alpha fade). Yıldızlar tek seferlik çizilir (pil dostu).
extends Control

@onready var moon: ColorRect = $Moon

# Faza göre gökyüzü görünürlüğü.
const ALPHA := {"dawn": 0.30, "day": 0.0, "dusk": 0.55, "night": 1.0}
const STAR_COUNT := 80
const STAR_SEED := 20260625

var _stars: Array = []  # her biri [nx, ny, radius, alpha]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gen_stars()
	resized.connect(queue_redraw)
	EventBus.time_phase_changed.connect(_on_phase_changed)
	EventBus.moon_phase_changed.connect(_on_moon_changed)
	_apply_moon()
	modulate.a = ALPHA.get(TimeService.get_phase(), 0.0)
	queue_redraw()


func _gen_stars() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = STAR_SEED
	for i in STAR_COUNT:
		_stars.append([
			rng.randf(),                  # nx 0..1
			rng.randf() * 0.55,           # ny üst gökyüzü
			rng.randf_range(1.0, 2.3),    # yarıçap
			rng.randf_range(0.4, 1.0),    # parlaklık
		])


func _draw() -> void:
	var sz := size
	for s in _stars:
		draw_circle(Vector2(s[0] * sz.x, s[1] * sz.y), s[2], Color(1, 1, 1, s[3]))


func _on_phase_changed(phase: String) -> void:
	var t := create_tween()
	t.tween_property(self, "modulate:a", ALPHA.get(phase, 0.0), 1.5)


func _on_moon_changed(_name: String, _illum: float) -> void:
	_apply_moon()


func _apply_moon() -> void:
	var mat := moon.material as ShaderMaterial
	if mat != null:
		mat.set_shader_parameter("phase", TimeService.get_moon().phase)
