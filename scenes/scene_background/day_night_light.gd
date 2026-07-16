## Gün-gece renk geçişi — CanvasModulate'e shader uygular + faza göre renk lerp.
## Plan §11.2: dawn turuncu-pastel, day parlak-nötr, dusk altın-sıcak, night lacivert-mor.
## EventBus.time_phase_changed sinyaliyle her faz değişiminde yumuşakça güncellenir.
extends CanvasModulate

# Faz başına [tint_color (vec3), tint_strength (0-1), brightness (0.3-1.5)]
const PHASE_PARAMS := {
	"dawn":  {"tint": Color(1.0, 0.78, 0.55),  "strength": 0.22, "brightness": 0.92},
	"day":   {"tint": Color(1.0, 1.0,  1.0),   "strength": 0.0,  "brightness": 1.0},
	"dusk":  {"tint": Color(1.0, 0.60, 0.30),  "strength": 0.28, "brightness": 0.88},
	"night": {"tint": Color(0.25, 0.28, 0.55), "strength": 0.38, "brightness": 0.60},
}

const TRANSITION_SECS := 8.0  # faz geçiş süresi (saniye)

var _shader_mat: ShaderMaterial
var _target_tint    := Color.WHITE
var _target_strength := 0.0
var _target_bright   := 1.0
var _cur_tint        := Color.WHITE
var _cur_strength    := 0.0
var _cur_bright      := 1.0
var _transitioning   := false


func _ready() -> void:
	_shader_mat = ShaderMaterial.new()
	_shader_mat.shader = load("res://shaders/day_night.gdshader")
	material = _shader_mat
	EventBus.time_phase_changed.connect(_on_phase_changed)
	_apply_phase(TimeService.get_phase(), false)  # anlık, geçişsiz açılış


func _on_phase_changed(phase: String) -> void:
	_apply_phase(phase, true)


func _apply_phase(phase: String, animated: bool) -> void:
	var p: Dictionary = PHASE_PARAMS.get(phase, PHASE_PARAMS["day"])
	_target_tint     = p.tint
	_target_strength = p.strength
	_target_bright   = p.brightness
	if animated:
		_transitioning = true
		set_process(true)
	else:
		_cur_tint     = _target_tint
		_cur_strength = _target_strength
		_cur_bright   = _target_bright
		_flush()
		set_process(false)


func _process(delta: float) -> void:
	if not _transitioning:
		set_process(false)
		return
	var t := clampf(delta / TRANSITION_SECS, 0.0, 1.0)
	_cur_tint     = _cur_tint.lerp(_target_tint, t * 5.0 * delta)
	_cur_strength = lerpf(_cur_strength, _target_strength, t * 5.0 * delta)
	_cur_bright   = lerpf(_cur_bright,   _target_bright,   t * 5.0 * delta)
	var done := (
		_cur_tint.is_equal_approx(_target_tint)
		and absf(_cur_strength - _target_strength) < 0.002
		and absf(_cur_bright   - _target_bright)   < 0.002
	)
	if done:
		_cur_tint     = _target_tint
		_cur_strength = _target_strength
		_cur_bright   = _target_bright
		_transitioning = false
		set_process(false)
	_flush()


func _flush() -> void:
	if _shader_mat == null:
		return
	_shader_mat.set_shader_parameter("tint_color",   Vector3(_cur_tint.r, _cur_tint.g, _cur_tint.b))
	_shader_mat.set_shader_parameter("tint_strength", _cur_strength)
	_shader_mat.set_shader_parameter("brightness",    _cur_bright)
	# CanvasModulate'in kendi rengini nötr tut; shader tüm efekti taşır.
	color = Color.WHITE
