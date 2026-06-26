## Kullanıcı tercihleri. user://settings.cfg içinde ConfigFile ile kalıcı.
## Değişince EventBus.settings_changed yayılır. (Plan §3.3, §10.4)
extends Node

const PATH := "user://settings.cfg"

# Varsayılanlar — yeni anahtar eklerken buraya da ekle.
const DEFAULTS := {
	# ses (0.0–1.0)
	"audio/master": 1.0,
	"audio/music": 0.8,
	"audio/ambient": 0.8,
	"audio/sfx": 0.9,
	# bildirim kategorileri (Plan §14) — hepsi opt-in
	"notify/needs": false,
	"notify/weather": false,
	"notify/daily": false,
	# erişilebilirlik (Plan §10.4)
	"a11y/reduced_motion": false,
	"a11y/text_scale": 1.0,
	"a11y/high_contrast": false,
	# genel
	"general/locale": "tr",
	"general/location_mode": "auto",   # "auto" | "manual" | "off"
	"general/manual_city": "",
}

var _cfg := ConfigFile.new()


func _ready() -> void:
	if _cfg.load(PATH) != OK:
		# ilk açılış: varsayılanları yaz
		for key in DEFAULTS:
			_set_raw(key, DEFAULTS[key])
		_cfg.save(PATH)


func get_value(key: String) -> Variant:
	var parts := key.split("/")
	return _cfg.get_value(parts[0], parts[1], DEFAULTS.get(key))


func set_value(key: String, value: Variant) -> void:
	_set_raw(key, value)
	_cfg.save(PATH)
	EventBus.settings_changed.emit(key, value)


func _set_raw(key: String, value: Variant) -> void:
	var parts := key.split("/")
	_cfg.set_value(parts[0], parts[1], value)
