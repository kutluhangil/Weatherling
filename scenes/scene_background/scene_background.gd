## Hava (WeatherService.state) × gün-zamanı (TimeService phase) → tam ekran illüstrasyon.
## Dosya yoksa palet düz renge düşer (asset gelmeden çalışır). VFX motorunun yerini alır.
class_name SceneBackground
extends TextureRect

const _STATE_NAMES := ["clear", "clouds", "fog", "rain", "snow", "thunder", "windy"]
const _PHASES := ["dawn", "day", "dusk", "night"]

## Hava VFX overlay PNG yolları
const VFX_RAIN := "res://art/vfx/weather/rain_particle.png"
const VFX_SNOW := "res://art/vfx/weather/snow_particle.png"
const VFX_FOG  := "res://art/vfx/weather/fog_overlay.png"

var _current_path := ""
var _pending := ""
var _vfx_rain: CPUParticles2D
var _vfx_snow: CPUParticles2D
var _vfx_fog: TextureRect


func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_vfx()
	EventBus.weather_changed.connect(func(_s, _t, _d): refresh(); _refresh_vfx())
	EventBus.time_phase_changed.connect(func(_p): refresh())
	refresh()
	_refresh_vfx()


## state×phase → asset yolu. Bilinmeyen state→clear, phase→day. (Saf — test edilir.)
static func bg_key(state: int, phase: String) -> String:
	var sname: String = _STATE_NAMES[state] if state >= 0 and state < _STATE_NAMES.size() else "clear"
	var ph: String = phase if phase in _PHASES else "day"
	return "res://art/backgrounds/%s_%s.png" % [sname, ph]


## İllüstrasyon varsa göster (THREADED → büyük PNG değişiminde takılma yok); yoksa şeffaf
## kal (arka renk .tscn'deki ColorRect). (Perf: Plan §15 async yükleme)
func refresh() -> void:
	var path := bg_key(WeatherService.state, TimeService.get_phase())
	if path == _current_path and texture != null:
		return
	if not ResourceLoader.exists(path):
		texture = null
		_current_path = path
		return
	_pending = path
	ResourceLoader.load_threaded_request(path)
	set_process(true)


func _process(_delta: float) -> void:
	if _pending == "":
		set_process(false)
		return
	var st := ResourceLoader.load_threaded_get_status(_pending)
	if st == ResourceLoader.THREAD_LOAD_LOADED:
		texture = ResourceLoader.load_threaded_get(_pending)
		_current_path = _pending
		_pending = ""
		set_process(false)
	elif st != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		_pending = ""  # FAILED / INVALID → fallback rengi kalır
		set_process(false)


## Hava VFX overlay node'larını oluştur (asset yoksa graceful skip).
func _build_vfx() -> void:
	# Yağmur partikülleri
	_vfx_rain = CPUParticles2D.new()
	_vfx_rain.emitting = false
	_vfx_rain.amount = 80
	_vfx_rain.lifetime = 0.8
	_vfx_rain.explosiveness = 0.0
	_vfx_rain.direction = Vector2(0.1, 1)
	_vfx_rain.spread = 5.0
	_vfx_rain.gravity = Vector2(0, 400)
	_vfx_rain.initial_velocity_min = 300.0
	_vfx_rain.initial_velocity_max = 500.0
	_vfx_rain.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_vfx_rain.emission_rect_extents = Vector2(300, 10)
	_vfx_rain.position = Vector2(270, -20)
	_vfx_rain.scale_amount_min = 0.4
	_vfx_rain.scale_amount_max = 0.7
	_vfx_rain.color = Color(0.7, 0.85, 1.0, 0.7)
	if ResourceLoader.exists(VFX_RAIN):
		_vfx_rain.texture = load(VFX_RAIN)
	add_child(_vfx_rain)

	# Kar partikülleri
	_vfx_snow = CPUParticles2D.new()
	_vfx_snow.emitting = false
	_vfx_snow.amount = 60
	_vfx_snow.lifetime = 3.0
	_vfx_snow.explosiveness = 0.0
	_vfx_snow.direction = Vector2(0.15, 1)
	_vfx_snow.spread = 20.0
	_vfx_snow.gravity = Vector2(0, 30)
	_vfx_snow.initial_velocity_min = 20.0
	_vfx_snow.initial_velocity_max = 60.0
	_vfx_snow.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_vfx_snow.emission_rect_extents = Vector2(300, 10)
	_vfx_snow.position = Vector2(270, -20)
	_vfx_snow.scale_amount_min = 0.2
	_vfx_snow.scale_amount_max = 0.5
	_vfx_snow.color = Color(1.0, 1.0, 1.0, 0.85)
	if ResourceLoader.exists(VFX_SNOW):
		_vfx_snow.texture = load(VFX_SNOW)
	add_child(_vfx_snow)

	# Sis overlay (statik TextureRect, hafif alpha)
	_vfx_fog = TextureRect.new()
	_vfx_fog.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_vfx_fog.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_vfx_fog.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vfx_fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vfx_fog.modulate = Color(1, 1, 1, 0.35)
	_vfx_fog.visible = false
	if ResourceLoader.exists(VFX_FOG):
		_vfx_fog.texture = load(VFX_FOG)
	add_child(_vfx_fog)


## Hava durumuna göre VFX aktif/pasif et.
func _refresh_vfx() -> void:
	if _vfx_rain == null:
		return
	var s := WeatherService.state
	_vfx_rain.emitting = (s == 3)   # rain
	_vfx_snow.emitting = (s == 4)   # snow
	_vfx_fog.visible   = (s == 2)   # fog

