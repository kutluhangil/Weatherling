## İnanç / gelenek katmanı — opsiyonel, saygılı, yargısız. (Plan §8)
## SAYGI İLKELERİ: ibadet ödül kasması DEĞİL; eşlik opsiyonel, eşlik etmemenin
## cezası YOK; kullanıcı her an değiştirip kapatabilir.
## Vakitler konuma bağlı (sunrise/sunset'ten yerel hesap — çevrimdışı çalışır);
## Aladhan API daha hassas yedek olarak eklenebilir (TODO).
extends Node

const PROFILE_DIR := "res://data/faiths/"
const CHECK_SECONDS := 60.0

var current_faith := "none"
var _profile: FaithProfile = null
var _check_timer: Timer
var _fired := {}        # "yyyy-m-d:ritual" → true
var _last_day := ""


func _ready() -> void:
	EventBus.state_loaded.connect(func(s): set_faith(s.faith))
	_check_timer = Timer.new()
	_check_timer.wait_time = CHECK_SECONDS
	_check_timer.timeout.connect(_on_check)
	add_child(_check_timer)
	_check_timer.start()


func set_faith(faith_id: String) -> void:
	current_faith = faith_id if faith_id != "" else "none"
	_profile = _load_profile(current_faith)
	_fired.clear()
	_schedule_notifications()


func profile() -> FaithProfile:
	return _profile


## Namaz vakitleri (yerel hesap, dakika cinsinden). (Plan §8 — çevrimdışı)
## Basit yöntem: sunrise/sunset + ofset. Hassas için Aladhan eklenebilir (TODO).
func prayer_minutes() -> Dictionary:
	var sr: int = TimeService.sunrise_minutes
	var ss: int = TimeService.sunset_minutes
	var noon := int((sr + ss) / 2.0)
	return {
		"fajr": maxi(sr - 80, 0),
		"dhuhr": noon,
		"asr": int(noon + (ss - noon) * 0.6),
		"maghrib": ss,
		"isha": mini(ss + 80, 1439),
	}


func _on_check() -> void:
	if _profile == null or _profile.rhythm_type == "none":
		return
	var now := Time.get_datetime_dict_from_system()
	var today := "%d-%d-%d" % [now.year, now.month, now.day]
	if today != _last_day:
		_last_day = today
		_fired.clear()
	var now_min: int = now.hour * 60 + now.minute

	match _profile.rhythm_type:
		"prayer_times":
			var times := prayer_minutes()
			for r in ["fajr", "dhuhr", "asr", "maghrib", "isha"]:
				_maybe_fire(today, r, times[r], now_min)
		"weekday":
			for entry in _profile.rituals:
				if int(now.weekday) == int(entry.get("day", 0)):
					_maybe_fire(today, str(entry.get("ritual", "service")), int(entry.get("minute", 600)), now_min)
		"daily_times":
			for entry in _profile.rituals:
				_maybe_fire(today, str(entry.get("ritual", "devotion")), int(entry.get("minute", 480)), now_min)
		"sunset_window":
			if int(now.weekday) == 5:  # Cuma akşamı (Shabbat başlangıcı)
				_maybe_fire(today, "shabbat", TimeService.sunset_minutes, now_min)


func _maybe_fire(day: String, ritual: String, target_min: int, now_min: int) -> void:
	if now_min < target_min or now_min > target_min + 1:
		return
	var key := day + ":" + ritual
	if _fired.has(key):
		return
	_fired[key] = true
	EventBus.devotion_time.emit(current_faith, ritual)  # eşlik opsiyonel, ceza yok


## Bugünün yaklaşan vakitleri için nazik bildirim planla (opt-in). (Plan §14)
func _schedule_notifications() -> void:
	if _profile == null or not bool(Settings.get_value("notify/faith")):
		return
	if _profile.rhythm_type != "prayer_times":
		return
	NotificationService.cancel_all()
	var now := Time.get_datetime_dict_from_system()
	var now_min: int = now.hour * 60 + now.minute
	var base_unix := int(Time.get_unix_time_from_system())
	var times := prayer_minutes()
	for r in times:
		var tmin: int = times[r]
		if tmin > now_min:
			NotificationService.schedule("faith", tr("APP_NAME"), tr("NOTIF_PRAYER"), base_unix + (tmin - now_min) * 60)


func _load_profile(faith_id: String) -> FaithProfile:
	var path := PROFILE_DIR + faith_id + ".tres"
	if not ResourceLoader.exists(path):
		return null
	return load(path) as FaithProfile
