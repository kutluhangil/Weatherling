## Yerel bildirimler — nazik, kategori bazlı, spam değil. (Plan §14)
## İzin: Android 13+ POST_NOTIFICATIONS (Godot çekirdek OS API'si).
## Zamanlama: bir Android bildirim eklentisi gerekir (addons/) — yoksa sessizce no-op.
extends Node

const CATEGORIES := {
	"needs": "notify/needs",     # "[İsim] acıktı"
	"weather": "notify/weather", # "Senin orada yağmur başladı"
	"faith": "notify/faith",     # vakit hatırlatması
	"daily": "notify/daily",     # nazik günlük check-in
}
const PERMISSION := "android.permission.POST_NOTIFICATIONS"

# TODO(Faz 9): addons/ altındaki gerçek bildirim eklentisinin singleton adı.
const PLUGIN_NAME := "GodotLocalNotification"

var _plugin: Object = null


func _ready() -> void:
	if Engine.has_singleton(PLUGIN_NAME):
		_plugin = Engine.get_singleton(PLUGIN_NAME)
	_schedule_daily_checkin()


func has_plugin() -> bool:
	return _plugin != null


func is_enabled(category: String) -> bool:
	var key: String = CATEGORIES.get(category, "")
	return key != "" and bool(Settings.get_value(key))


func set_enabled(category: String, on: bool) -> void:
	if not CATEGORIES.has(category):
		return
	Settings.set_value(CATEGORIES[category], on)
	if on:
		request_permission()


# --- İzin ------------------------------------------------------------

func has_permission() -> bool:
	if OS.get_name() != "Android":
		return true  # masaüstü/iOS: çekirdek izin yok
	return PERMISSION in OS.get_granted_permissions()


## Android 13+ runtime izni iste. Reddedilirse sessizce devam. (Plan §14)
func request_permission() -> void:
	if OS.get_name() == "Android" and not has_permission():
		OS.request_permission(PERMISSION)
	# Sonuç asenkron; bir sonraki has_permission() çağrısında doğrulanır.
	EventBus.notification_permission_changed.emit(has_permission())


# --- Zamanlama -------------------------------------------------------

## Kategori açık + izin var + eklenti varsa belirtilen unix zamanına bildirim planla.
func schedule(category: String, title: String, body: String, at_unix: int) -> void:
	if not is_enabled(category) or not has_permission() or _plugin == null:
		return
	var delay := at_unix - int(Time.get_unix_time_from_system())
	if delay <= 0:
		return
	if _plugin.has_method("schedule"):
		_plugin.schedule(_notif_id(category), title, body, delay)


func cancel_all() -> void:
	if _plugin != null and _plugin.has_method("cancel_all"):
		_plugin.cancel_all()


## Yarın için nazik günlük check-in (opt-in). (Plan §14)
func _schedule_daily_checkin() -> void:
	if not is_enabled("daily"):
		return
	var now := int(Time.get_unix_time_from_system())
	var d := Time.get_datetime_dict_from_system()
	var minutes_now: int = d.hour * 60 + d.minute
	var target := 19 * 60          # ~19:00
	var delay_min := target - minutes_now
	if delay_min <= 0:
		delay_min += 24 * 60       # yarın
	schedule("daily", tr("APP_NAME"), tr("NOTIF_DAILY"), now + delay_min * 60)


func _notif_id(category: String) -> int:
	return abs(category.hash()) % 100000
