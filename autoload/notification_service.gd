## Yerel bildirimler — nazik, kategori bazlı, spam değil. (Plan §14)
## Android 13+ POST_NOTIFICATIONS runtime izni; reddedilirse sessizce devam.
## Faz 0: iskelet + Settings köprüsü. Gerçek zamanlama Faz 9 (Android eklentisi).
extends Node

# Bildirim kategorileri ↔ Settings anahtarları (Plan §14).
const CATEGORIES := {
	"needs": "notify/needs",     # "[İsim] acıktı"
	"weather": "notify/weather", # "Senin orada yağmur başladı"
	"faith": "notify/faith",     # vakit hatırlatması
	"daily": "notify/daily",     # nazik günlük check-in
}

var _plugin = null  # TODO(Faz 9): addons/ altındaki bildirim eklentisi singleton'ı


func _ready() -> void:
	# TODO(Faz 9): Engine.has_singleton(...) ile eklentiyi bağla.
	pass


func is_enabled(category: String) -> bool:
	var key: String = CATEGORIES.get(category, "")
	return key != "" and bool(Settings.get_value(key))


func set_enabled(category: String, on: bool) -> void:
	if CATEGORIES.has(category):
		Settings.set_value(CATEGORIES[category], on)


## Android 13+ runtime izni iste. Reddedilirse sessiz.
func request_permission() -> void:
	# TODO(Faz 9): eklenti üzerinden POST_NOTIFICATIONS iste; sonuç →
	# EventBus.notification_permission_changed.emit(granted)
	pass


## Kategori açıksa belirtilen unix zamanına bildirim planla.
func schedule(category: String, _title: String, _body: String, _at_unix: int) -> void:
	if not is_enabled(category):
		return
	pass  # TODO(Faz 9): eklenti schedule çağrısı


func cancel_all() -> void:
	pass  # TODO(Faz 9)
