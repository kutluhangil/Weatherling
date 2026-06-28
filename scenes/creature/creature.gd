## Yaratık — durum makinesi + prosedürel "canlı" his. (Plan §11.1, Faz 1)
## Faz 1 placeholder: SVG gövde + kod-tabanlı animasyon (nefes, göz kırpma, dokunma tepkisi).
## Faz 5: evreye göre gerçek sprite seti + AnimationTree; set_state() API'si aynı kalır.
class_name Creature
extends Node2D

enum State { IDLE, HAPPY, SAD, SLEEPY, SLEEP, EAT, PET_REACT, COLD, HOT, SICK }

## Evreye göre placeholder palet (gövde modulate) ve taban ölçek. (Plan §7, §11.1)
const STAGE_PALETTE := {
	"filiz": Color(1.0, 1.0, 1.0), "tomurcuk": Color(0.95, 0.95, 1.0),
	"cicek": Color(1.0, 0.98, 0.95), "meyve": Color(1.0, 0.97, 0.92),
	"hasat": Color(1.0, 0.95, 0.88), "kok": Color(0.96, 0.93, 0.9),
	"cinar": Color(0.93, 0.92, 0.95),
}
const STAGE_SCALE := {
	"filiz": 0.85, "tomurcuk": 0.95, "cicek": 1.0, "meyve": 1.05,
	"hasat": 1.05, "kok": 1.0, "cinar": 0.95,
}

@export var touch_radius: float = 95.0

@onready var visual: Node2D = $Visual
@onready var body: Sprite2D = $Visual/Body
@onready var face: Node2D = $Visual/Face
@onready var blink_timer: Timer = $BlinkTimer

const PLACEHOLDER_BODY := "res://art/creature/placeholder/body.svg"

var state: int = State.IDLE
var _t: float = 0.0
var _visual_base: Vector2
var _hearts: CPUParticles2D
var _pet_tween: Tween


func _ready() -> void:
	_make_hearts()
	_apply_stage_look()
	blink_timer.timeout.connect(_blink)
	_schedule_blink()
	EventBus.time_phase_changed.connect(_on_phase_changed)
	EventBus.weather_changed.connect(_on_weather_changed)
	EventBus.state_loaded.connect(func(_s): _apply_stage_look())
	EventBus.settings_changed.connect(_on_settings_changed)
	_update_motion()
	_on_phase_changed(TimeService.get_phase())  # açılışta gece ise uyu


## Yaşam evresine göre palet + taban ölçek. (Faz 5)
func _apply_stage_look() -> void:
	var id := LifeStageService.current_id()
	var sc: float = STAGE_SCALE.get(id, 1.0)
	_visual_base = Vector2(sc, sc)
	# Evre sprite'ı varsa gerçek art'ı kullan (gözler gömülü → placeholder yüzü gizle);
	# yoksa placeholder gövde + kod gözleri + evre palet tonu. (Auto-fit: art gelince oturur)
	var sprite_path := "res://art/creature/%s.png" % id
	if ResourceLoader.exists(sprite_path):
		body.texture = load(sprite_path)
		face.visible = false
		visual.modulate = Color.WHITE
	else:
		body.texture = load(PLACEHOLDER_BODY)
		face.visible = true
		visual.modulate = STAGE_PALETTE.get(id, Color.WHITE)


func _process(delta: float) -> void:
	# Nefes: hacim koruyan squash & stretch — sadece Visual'a uygulanır,
	# böylece pet-react'in kök ölçek tween'iyle çakışmaz.
	_t += delta * _breath_speed()
	var s := sin(_t)
	var amp := _breath_amp()
	visual.scale = Vector2(
		_visual_base.x * (1.0 - s * amp * 0.6),
		_visual_base.y * (1.0 + s * amp)
	)


func set_state(new_state: int) -> void:
	state = new_state


func _breath_speed() -> float:
	match state:
		State.SLEEP:
			return 1.1
		State.HAPPY:
			return 6.0
		State.SAD:
			return 1.6
		_:
			return 2.6


func _breath_amp() -> float:
	if _reduced():
		return 0.01
	match state:
		State.SLEEP:
			return 0.06
		State.HAPPY:
			return 0.05
		State.SAD:
			return 0.015
		_:
			return 0.03


func _reduced() -> bool:
	return bool(Settings.get_value("a11y/reduced_motion"))


## Hareket azaltma: nefes _process'ini TAMAMEN durdur → her kare scale yazımı bitsin,
## low_processor_mode boştaki render'ı gerçekten kessin (Plan §15, §10.4).
func _update_motion() -> void:
	if _reduced():
		set_process(false)
		visual.scale = _visual_base
	else:
		set_process(true)


func _on_settings_changed(key: String, _value: Variant) -> void:
	if key == "a11y/reduced_motion":
		_update_motion()


# --- Dokunma (manuel hit-test; root viewport physics-picking'e bağımlı değil) ---

func _unhandled_input(event: InputEvent) -> void:
	var pos := Vector2.INF
	if event is InputEventScreenTouch and event.pressed:
		pos = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pos = event.position
	if pos == Vector2.INF:
		return
	if global_position.distance_to(pos) <= touch_radius:
		get_viewport().set_input_as_handled()
		_on_petted()


func _on_petted() -> void:
	GameManager.request_active_frames()  # squash/kalp akıcı olsun, sonra idle FPS'e dön
	NeedsService.apply_care("pet")
	if state == State.SLEEP:
		set_state(State.IDLE)  # uyuyorsa nazikçe uyandır
	_hearts.restart()
	_squash()
	set_state(State.HAPPY)
	await get_tree().create_timer(1.2).timeout
	if state == State.HAPPY:
		set_state(State.IDLE)


func _squash() -> void:
	if _pet_tween != null and _pet_tween.is_running():
		_pet_tween.kill()
	scale = Vector2.ONE
	_pet_tween = create_tween()
	_pet_tween.tween_property(self, "scale", Vector2(1.18, 0.86), 0.08) \
		.set_trans(Tween.TRANS_SINE)
	_pet_tween.tween_property(self, "scale", Vector2.ONE, 0.45) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


# --- Göz kırpma ---

func _schedule_blink() -> void:
	blink_timer.wait_time = randf_range(2.5, 5.5)
	blink_timer.start()


func _blink() -> void:
	if state != State.SLEEP and not _reduced():
		var t := create_tween()
		t.tween_property(face, "scale:y", 0.1, 0.06)
		t.tween_property(face, "scale:y", 1.0, 0.08)
	_schedule_blink()


# --- Gün fazı → uyku ---

func _on_phase_changed(phase: String) -> void:
	if phase == "night":
		set_state(State.SLEEP)
	elif state == State.SLEEP:
		set_state(State.IDLE)


func _on_weather_changed(_state: int, temp: float, _is_day: bool) -> void:
	if state == State.SLEEP:
		return
	if temp <= 4.0:
		set_state(State.COLD)
	elif temp >= 31.0:
		set_state(State.HOT)
	elif state == State.COLD or state == State.HOT:
		set_state(State.IDLE)


func _make_hearts() -> void:
	_hearts = CPUParticles2D.new()
	_hearts.emitting = false
	_hearts.one_shot = true
	_hearts.explosiveness = 0.85
	_hearts.amount = 10
	_hearts.lifetime = 0.9
	_hearts.position = Vector2(0, -70)
	_hearts.direction = Vector2(0, -1)
	_hearts.spread = 40.0
	_hearts.gravity = Vector2(0, -40)
	_hearts.initial_velocity_min = 50.0
	_hearts.initial_velocity_max = 110.0
	_hearts.scale_amount_min = 0.25
	_hearts.scale_amount_max = 0.5
	_hearts.color = Color(1.0, 0.45, 0.6)
	var tex := load("res://art/particles/heart.svg")
	if tex is Texture2D:
		_hearts.texture = tex
	add_child(_hearts)
