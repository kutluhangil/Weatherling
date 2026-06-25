## Gerçek yerel hava → oyun durumu. (Plan §3.4, §6.3) Open-Meteo, ANAHTARSIZ.
## Faz 0: WMO→durum eşlemesi (saf, test edilebilir) + cache okuma/yazma hazır;
## ağ çağrısı iskeleti var ama _ready'de OTOMATİK ÇAĞRILMAZ (konum izni Faz 3).
extends Node

enum WeatherState { CLEAR, CLOUDS, FOG, RAIN, SNOW, THUNDER, WINDY }

const CACHE_PATH := "user://weather_cache.dat"
const CACHE_TTL := 1800            # 30 dk (Plan §6.3)
const WINDY_THRESHOLD_KMH := 40.0  # üstünde rüzgâr modifiyesi
const API := "https://api.open-meteo.com/v1/forecast"
const GEO_API := "https://geocoding-api.open-meteo.com/v1/search"

var state: int = WeatherState.CLEAR
var temp_c: float = 20.0
var is_day := true
var wind_kmh := 0.0
var is_offline := false
var last_fetch_unix := 0
var last_lat := 0.0
var last_lon := 0.0

var _http: HTTPRequest
var _geo: HTTPRequest


func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)
	_geo = HTTPRequest.new()
	add_child(_geo)
	_geo.request_completed.connect(_on_geo_completed)
	_read_cache()  # son bilinen veriyle aç (ağ yok)
	_auto_start()


## Konumdan güncelle. WeatherService bunu Faz 3'te izin/şehir akışından çağırır.
func refresh(lat: float, lon: float) -> void:
	var url := "%s?latitude=%f&longitude=%f&current=temperature_2m,weather_code,is_day,wind_speed_10m&daily=sunrise,sunset&timezone=auto&forecast_days=1" % [API, lat, lon]
	var err := _http.request(url)
	if err != OK:
		is_offline = true
		EventBus.offline_mode_changed.emit(true)


## Manuel şehir → koordinat (Open-Meteo geocoding, anahtarsız) → refresh.
func set_city(city: String) -> void:
	if city.strip_edges() == "":
		return
	Settings.set_value("general/manual_city", city)
	var url := "%s?name=%s&count=1&language=tr&format=json" % [GEO_API, city.uri_encode()]
	var err := _geo.request(url)
	if err != OK:
		is_offline = true
		EventBus.offline_mode_changed.emit(true)


func _on_geo_completed(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		return
	var json: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) != TYPE_DICTIONARY or not json.has("results"):
		return
	var arr: Array = json.results
	if arr.is_empty():
		return
	var r: Dictionary = arr[0]
	last_lat = float(r.get("latitude", 0.0))
	last_lon = float(r.get("longitude", 0.0))
	refresh(last_lat, last_lon)


## Konuma bağlı hava akışını başlat (gizlilik dostu: yalnızca şehir varsa çeker).
func _auto_start() -> void:
	var mode: String = Settings.get_value("general/location_mode")
	if mode == "off":
		return
	var city: String = Settings.get_value("general/manual_city")
	if city != "":
		set_city(city)
	# TODO(Faz 3 GPS): mode == "auto" + coarse-location Android eklentisi → koordinat → refresh.


func _iso_to_minutes(iso: String) -> int:
	# "2026-06-25T05:31" → 331
	var parts := iso.split("T")
	if parts.size() < 2:
		return 0
	var hm := parts[1].split(":")
	if hm.size() < 2:
		return 0
	return int(hm[0]) * 60 + int(hm[1])


func _on_request_completed(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		is_offline = true
		EventBus.offline_mode_changed.emit(true)
		return
	var json: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) != TYPE_DICTIONARY or not json.has("current"):
		return
	var cur: Dictionary = json.current
	temp_c = float(cur.get("temperature_2m", temp_c))
	wind_kmh = float(cur.get("wind_speed_10m", 0.0))
	is_day = int(cur.get("is_day", 1)) == 1
	state = state_for_wmo(int(cur.get("weather_code", 0)), wind_kmh)
	is_offline = false
	last_fetch_unix = int(Time.get_unix_time_from_system())

	# Sunrise/sunset → TimeService (timezone=auto → yerel ISO). (Plan §6.1)
	if json.has("daily"):
		var daily: Dictionary = json.daily
		var srs: Array = daily.get("sunrise", [])
		var sss: Array = daily.get("sunset", [])
		if not srs.is_empty() and not sss.is_empty():
			TimeService.set_sun_minutes(_iso_to_minutes(str(srs[0])), _iso_to_minutes(str(sss[0])))

	_write_cache()
	EventBus.offline_mode_changed.emit(false)
	EventBus.weather_changed.emit(state, temp_c, is_day)


## WMO weather code → WeatherState. (Plan §6.3 tablosu) Saf — GUT ile test edilir.
static func state_for_wmo(code: int, wind: float = 0.0) -> int:
	if wind >= WINDY_THRESHOLD_KMH:
		return WeatherState.WINDY
	if code in [0, 1]:
		return WeatherState.CLEAR
	if code in [2, 3]:
		return WeatherState.CLOUDS
	if code in [45, 48]:
		return WeatherState.FOG
	if code >= 95:
		return WeatherState.THUNDER
	if (code >= 71 and code <= 77) or code in [85, 86]:
		return WeatherState.SNOW
	if (code >= 51 and code <= 67) or (code >= 80 and code <= 82):
		return WeatherState.RAIN
	return WeatherState.CLOUDS


## Sıcaklık modifiyesi → NeedsService'e ipucu. (Plan §6.3)
func temperature_mood() -> String:
	if temp_c < 5.0:
		return "cold"
	if temp_c > 30.0:
		return "hot"
	return "neutral"


func _write_cache() -> void:
	var f := FileAccess.open(CACHE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_var({
		"state": state, "temp_c": temp_c, "is_day": is_day,
		"wind_kmh": wind_kmh, "ts": last_fetch_unix,
	}, false)
	f.close()


func _read_cache() -> void:
	if not FileAccess.file_exists(CACHE_PATH):
		return
	var f := FileAccess.open(CACHE_PATH, FileAccess.READ)
	if f == null:
		return
	var d: Variant = f.get_var(false)
	f.close()
	if typeof(d) != TYPE_DICTIONARY:
		return
	state = int(d.get("state", state))
	temp_c = float(d.get("temp_c", temp_c))
	is_day = bool(d.get("is_day", is_day))
	wind_kmh = float(d.get("wind_kmh", 0.0))
	last_fetch_unix = int(d.get("ts", 0))
	is_offline = (int(Time.get_unix_time_from_system()) - last_fetch_unix) > CACHE_TTL
