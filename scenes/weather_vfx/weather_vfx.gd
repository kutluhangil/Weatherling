## Hava efektleri — WeatherState'e bağlı. (Plan §11.3, Faz 3)
## Yağmur/kar CPUParticles2D (havuzlu, Compatibility'de güvenli). Sis shader. Şimşek flash.
## Partiküller kodda kurulur → .tscn'de sürüm-bağımlı partikül alanı riski yok.
extends Control

@onready var fog: ColorRect = $Fog
@onready var flash: ColorRect = $Flash

var _rain: CPUParticles2D
var _snow: CPUParticles2D
var _thunder_active := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rain = _make_rain()
	_snow = _make_snow()
	fog.visible = false
	flash.color = Color(1, 1, 1, 0)
	EventBus.weather_changed.connect(_on_weather_changed)
	_apply(WeatherService.state)


func _on_weather_changed(state: int, _temp: float, _is_day: bool) -> void:
	_apply(state)


func _apply(state: int) -> void:
	var ws := WeatherService.WeatherState
	var raining := state == ws.RAIN or state == ws.THUNDER
	_rain.emitting = raining
	_snow.emitting = state == ws.SNOW
	fog.visible = state == ws.FOG
	if state == ws.THUNDER:
		_start_thunder()
	else:
		_thunder_active = false


# --- Şimşek ---

func _start_thunder() -> void:
	if _thunder_active:
		return
	_thunder_active = true
	_thunder_loop()


func _thunder_loop() -> void:
	await get_tree().create_timer(randf_range(3.0, 8.0)).timeout
	if not _thunder_active or not is_inside_tree():
		return
	var t := create_tween()
	t.tween_property(flash, "color:a", 0.75, 0.05)
	t.tween_property(flash, "color:a", 0.0, 0.5)
	# TODO(Faz 10 ses): gecikmeli gök gürültüsü SFX (AudioManager.play_sfx)
	_thunder_loop()


# --- Partikül kurulumları ---

func _make_rain() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.emitting = false
	p.amount = int(220 * _amount_mult())
	p.lifetime = 1.1
	p.preprocess = 1.1
	p.local_coords = false
	p.position = Vector2(270, -24)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(320, 4)
	p.direction = Vector2(0.12, 1.0)
	p.spread = 3.0
	p.gravity = Vector2(0, 980)
	p.initial_velocity_min = 360.0
	p.initial_velocity_max = 470.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 1.3
	p.color = Color(0.72, 0.82, 1.0, 0.7)
	_set_tex(p, "res://art/particles/raindrop.svg")
	add_child(p)
	return p


func _make_snow() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.emitting = false
	p.amount = int(130 * _amount_mult())
	p.lifetime = 6.0
	p.preprocess = 3.0
	p.local_coords = false
	p.position = Vector2(270, -24)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(320, 4)
	p.direction = Vector2(0.2, 1.0)
	p.spread = 18.0
	p.gravity = Vector2(0, 70)
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 70.0
	p.angular_velocity_min = -40.0
	p.angular_velocity_max = 40.0
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.1
	p.color = Color(1, 1, 1, 0.9)
	_set_tex(p, "res://art/particles/snowflake.svg")
	add_child(p)
	return p


## Hareket azaltma + düşük cihaz → daha az partikül. (Plan §10.4, §11.4)
func _amount_mult() -> float:
	return 0.4 if bool(Settings.get_value("a11y/reduced_motion")) else 1.0


func _set_tex(p: CPUParticles2D, path: String) -> void:
	if ResourceLoader.exists(path):
		var tex := load(path)
		if tex is Texture2D:
			p.texture = tex
