## Opsiyonel inanç / gelenek katmanı. (Plan §8, Faz 6)
## Seçilen gelenek → ilgili ritüel zamanlayıcıları; vakit geldiğinde
## EventBus.devotion_time yayılır → Creature ritüel animasyonunu oynatır.
## Hassasiyet ilkeleri (Plan §8): eşlik opsiyonel, ceza yok, değiştirilebilir/kapatılabilir.
extends Node

const SUPPORTED := ["islam", "christianity", "judaism", "hinduism", "buddhism", "other", "none"]
const ALADHAN_API := "https://api.aladhan.com/v1/timingsByCity"

# Günlük namaz vakitleri (İslam) — dakika cinsinden (lokal saat)
var _prayer_minutes: Array[int] = []  # [fajr, dhuhr, asr, maghrib, isha]
var _prayer_names   := ["fajr", "dhuhr", "asr", "maghrib", "isha"]

var _http: HTTPRequest
var _timer: Timer
var _last_faith := ""


func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_http_done)

	_timer = Timer.new()
	_timer.wait_time = 60.0
	_timer.timeout.connect(_tick)
	add_child(_timer)

	EventBus.state_loaded.connect(_on_state_loaded)
	EventBus.settings_changed.connect(_on_settings_changed)


func _on_state_loaded(state: CreatureState) -> void:
	_activate(state.faith)


## İnanç değişince çağrılır (Ayarlar → İnanç). (Plan §8)
func set_faith(faith: String) -> void:
	if faith == _last_faith:
		return
	GameManager.state.faith = faith
	_activate(faith)


func get_faith() -> String:
	return _last_faith


# --- Aktivasyon ---------------------------------------------------------

func _activate(faith: String) -> void:
	_last_faith = faith if faith in SUPPORTED else "none"
	_prayer_minutes.clear()
	_timer.stop()

	match _last_faith:
		"islam":
			_fetch_prayer_times()
		"christianity":
			# Pazar sabahı kilise anı (~10:00) + her gün kısa şükür (~08:00)
			_schedule_weekly("christianity", "sunday_service", 7, 10 * 60)
			_start_daily_tick()
		"judaism":
			# Cuma akşamı Shabbat başlangıcı → sunset bilgisi TimeService'ten
			_start_daily_tick()
		"hinduism", "buddhism":
			_start_daily_tick()
		"other":
			_start_daily_tick()
		_:
			pass  # none: ritüel yok


func _start_daily_tick() -> void:
	_timer.start()
	call_deferred("_tick")


# --- İslam: Namaz Vakitleri --------------------------------------------

func _fetch_prayer_times() -> void:
	var city: String = Settings.get_value("general/manual_city")
	if city == "":
		_use_fallback_prayer_times()
		return
	var country := "TR"
	var url := "%s?city=%s&country=%s&method=2" % [ALADHAN_API, city.uri_encode(), country]
	var err := _http.request(url)
	if err != OK:
		_use_fallback_prayer_times()


func _on_http_done(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_use_fallback_prayer_times()
		return
	var json: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) != TYPE_DICTIONARY:
		_use_fallback_prayer_times()
		return
	var timings: Dictionary = json.get("data", {}).get("timings", {})
	if timings.is_empty():
		_use_fallback_prayer_times()
		return
	# Aladhan formatı: "05:14 (+03)", alırız HH:MM kısmı
	_prayer_minutes.clear()
	for name in _prayer_names:
		var key := name.capitalize()
		var raw: String = timings.get(key, "00:00")
		_prayer_minutes.append(_time_str_to_min(raw))
	_start_daily_tick()


## Aladhan erişilemezse yerel yedeğe düş (İstanbul ortalama varsayılan).
func _use_fallback_prayer_times() -> void:
	# Fajr=5:10, Dhuhr=13:00, Asr=16:30, Maghrib=20:00, Isha=21:30
	_prayer_minutes = [310, 780, 990, 1200, 1290]
	_start_daily_tick()


# --- Günlük Tick -------------------------------------------------------

func _tick() -> void:
	var now_dict := Time.get_datetime_dict_from_system()
	var now_min: int = now_dict.hour * 60 + now_dict.minute
	var weekday: int = now_dict.weekday  # 0=Pazar

	match _last_faith:
		"islam":
			for i in _prayer_minutes.size():
				if abs(now_min - _prayer_minutes[i]) <= 1:
					EventBus.devotion_time.emit("islam", _prayer_names[i])
		"christianity":
			if weekday == 0 and abs(now_min - 10 * 60) <= 1:
				EventBus.devotion_time.emit("christianity", "sunday_service")
			elif abs(now_min - 8 * 60) <= 1:
				EventBus.devotion_time.emit("christianity", "daily_prayer")
		"judaism":
			var ss := TimeService.sunset_minutes
			if weekday == 5 and abs(now_min - ss) <= 2:   # Cuma akşamı Shabbat başlar
				EventBus.devotion_time.emit("judaism", "shabbat_start")
			elif weekday == 6 and abs(now_min - ss) <= 2: # Cumartesi akşamı biter
				EventBus.devotion_time.emit("judaism", "shabbat_end")
		"hinduism":
			if abs(now_min - 6 * 60) <= 1 or abs(now_min - 18 * 60) <= 1:
				EventBus.devotion_time.emit("hinduism", "aarti")
		"buddhism":
			if abs(now_min - 7 * 60) <= 1:
				EventBus.devotion_time.emit("buddhism", "meditation")
		"other":
			if abs(now_min - 8 * 60) <= 1:
				EventBus.devotion_time.emit("other", "mindfulness")


# --- Haftalık zamanlama (gelecek Pazar vb.) ----------------------------

func _schedule_weekly(_faith: String, _ritual: String, _weekday: int, _minute: int) -> void:
	pass  # _tick() döngüsüyle zaten yakalanıyor; ayrı zamanlayıcı gerekmez.


# --- Yardımcılar -------------------------------------------------------

func _time_str_to_min(s: String) -> int:
	var parts := s.split(" ")[0].split(":")
	if parts.size() < 2:
		return 0
	return int(parts[0]) * 60 + int(parts[1])


func _on_settings_changed(key: String, value: Variant) -> void:
	if key == "faith/tradition":
		set_faith(str(value))
