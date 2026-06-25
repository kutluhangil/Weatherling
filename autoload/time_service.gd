## Gerçek yerel saat → gün-gece fazı, mevsim, ay evresi. (Plan §6.1, §6.2)
## Sunrise/sunset gerçek değerlerini WeatherService Faz 3'te set_sun_times() ile besler;
## o zamana kadar makul varsayılan kullanılır. Faz çekirdek mantığı burada (saf, test edilebilir).
extends Node

const SYNODIC_MONTH := 29.53058867
const REF_NEW_MOON_UNIX := 947182440  # 2000-01-06 18:14 UTC, bilinen yeni ay
const TWILIGHT_MIN := 45              # şafak/alacakaranlık yarı-penceresi (dk)

# Konuma bağlı; WeatherService günceller. Varsayılan ~06:30 / ~19:30.
var sunrise_minutes := 390
var sunset_minutes := 1170
var hemisphere_north := true

var _last_phase := ""
var _last_season := ""
var _last_moon := ""
var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = 60.0
	_timer.timeout.connect(_tick)
	add_child(_timer)
	_timer.start()
	# İlk değerleri dinleyiciler bağlanınca yay.
	call_deferred("_tick")


func set_sun_times(sunrise_unix: int, sunset_unix: int) -> void:
	sunrise_minutes = _unix_to_local_minutes(sunrise_unix)
	sunset_minutes = _unix_to_local_minutes(sunset_unix)
	_tick()


# --- Saf hesaplar ---------------------------------------------------

func get_phase() -> String:
	var now := Time.get_datetime_dict_from_system()
	return phase_for(now.hour * 60 + now.minute, sunrise_minutes, sunset_minutes)


static func phase_for(now_min: int, sr_min: int, ss_min: int) -> String:
	if now_min >= sr_min - TWILIGHT_MIN and now_min <= sr_min + TWILIGHT_MIN:
		return "dawn"
	if now_min >= ss_min - TWILIGHT_MIN and now_min <= ss_min + TWILIGHT_MIN:
		return "dusk"
	if now_min > sr_min + TWILIGHT_MIN and now_min < ss_min - TWILIGHT_MIN:
		return "day"
	return "night"


func is_day() -> bool:
	var p := get_phase()
	return p == "day" or p == "dawn"


func get_season() -> String:
	var month := Time.get_datetime_dict_from_system().month
	return season_for(month, hemisphere_north)


static func season_for(month: int, north: bool) -> String:
	var seasons := ["winter", "spring", "summer", "autumn"]
	# Kuzey: Ara-Oca-Şub kış. İndeks = ((month % 12) / 3).
	var idx := int(float(month % 12) / 3.0)
	if not north:
		idx = (idx + 2) % 4
	return seasons[idx]


func get_moon() -> Dictionary:
	var now := Time.get_unix_time_from_system()
	var days := (now - REF_NEW_MOON_UNIX) / 86400.0
	var phase := fposmod(days, SYNODIC_MONTH) / SYNODIC_MONTH  # 0..1
	var illum := (1.0 - cos(TAU * phase)) / 2.0
	return {"name": _moon_name(phase), "phase": phase, "illumination": illum}


static func _moon_name(phase: float) -> String:
	var names := [
		"new_moon", "waxing_crescent", "first_quarter", "waxing_gibbous",
		"full_moon", "waning_gibbous", "last_quarter", "waning_crescent",
	]
	return names[int(round(phase * 8.0)) % 8]


# --- Periyodik kontrol ---------------------------------------------

func _tick() -> void:
	var phase := get_phase()
	if phase != _last_phase:
		_last_phase = phase
		EventBus.time_phase_changed.emit(phase)

	var season := get_season()
	if season != _last_season:
		_last_season = season
		EventBus.season_changed.emit(season)

	var moon := get_moon()
	if moon.name != _last_moon:
		_last_moon = moon.name
		EventBus.moon_phase_changed.emit(moon.name, moon.illumination)


func _unix_to_local_minutes(unix_time: int) -> int:
	var d := Time.get_datetime_dict_from_unix_time(unix_time)
	return d.hour * 60 + d.minute
