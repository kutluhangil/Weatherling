## Hava (WeatherService.state) × gün-zamanı (TimeService phase) → tam ekran illüstrasyon.
## Dosya yoksa palet düz renge düşer (asset gelmeden çalışır). VFX motorunun yerini alır.
class_name SceneBackground
extends TextureRect

const _STATE_NAMES := ["clear", "clouds", "fog", "rain", "snow", "thunder", "windy"]
const _PHASES := ["dawn", "day", "dusk", "night"]

var _current_path := ""
var _pending := ""


func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	EventBus.weather_changed.connect(func(_s, _t, _d): refresh())
	EventBus.time_phase_changed.connect(func(_p): refresh())
	refresh()


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
