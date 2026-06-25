## Godot yerleşik çeviri sistemi (TranslationServer) üstüne ince sarmalayıcı.
## TR/EN. (Plan §3.3, §10.4) Çeviriler project.godot'ta tr.po/en.po olarak kayıtlı.
extends Node

const SUPPORTED := ["tr", "en"]


func _ready() -> void:
	var saved: String = Settings.get_value("general/locale")
	set_locale(saved if saved in SUPPORTED else "en")


func set_locale(locale: String) -> void:
	if locale not in SUPPORTED:
		locale = "en"
	TranslationServer.set_locale(locale)
	Settings.set_value("general/locale", locale)
	EventBus.locale_changed.emit(locale)


func current_locale() -> String:
	return TranslationServer.get_locale()


## Kısayol — tr() ile aynı, çağrı yerinde okunsun diye.
func t(key: String) -> String:
	return TranslationServer.translate(key)
