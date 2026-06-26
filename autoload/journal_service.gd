## Günlük (Journal) — yaratık her gün havayı/anı kısa, sevimli notla yazar. (Plan §22)
## Günde TEK kayıt; gün içinde hava değişirse o günün hava/sıcaklığı güncellenir, not sabit kalır.
## Kayıtlar state.stats.journal içinde (en yeni başta), MAX_ENTRIES ile kapaklı → şema değişmez.
## Not seçimi SAF (note_keys_for) → headless test edilir. Metinler .po'da (TR+EN).
## entry şeması: {date:"YYYY-MM-DD", weather:int, temp:float, season:String, note_key:String}
extends Node

const MAX_ENTRIES := 90

# WeatherState (int) → not anahtarı havuzu. (CLEAR0..WINDY6)
const NOTE_KEYS := {
	0: ["JOURNAL_CLEAR_1", "JOURNAL_CLEAR_2"],
	1: ["JOURNAL_CLOUDS_1", "JOURNAL_CLOUDS_2"],
	2: ["JOURNAL_FOG_1", "JOURNAL_FOG_2"],
	3: ["JOURNAL_RAIN_1", "JOURNAL_RAIN_2"],
	4: ["JOURNAL_SNOW_1", "JOURNAL_SNOW_2"],
	5: ["JOURNAL_THUNDER_1", "JOURNAL_THUNDER_2"],
	6: ["JOURNAL_WINDY_1", "JOURNAL_WINDY_2"],
}

var _state: CreatureState = null


func _ready() -> void:
	EventBus.state_loaded.connect(_on_state_loaded)
	EventBus.weather_changed.connect(_on_weather)


# --- Saf not seçimi (test edilir) ----------------------------------

## Hava durumuna göre not anahtarı havuzu. Bilinmeyen → CLEAR havuzu. (Saf)
static func note_keys_for(weather: int) -> Array:
	return NOTE_KEYS.get(weather, NOTE_KEYS[0])


# --- Kayıt ----------------------------------------------------------

func _on_state_loaded(state: Resource) -> void:
	_state = state as CreatureState
	_maybe_record()


func _on_weather(_state: int, _temp: float, _is_day: bool) -> void:
	_maybe_record()


func _today_key() -> String:
	return Time.get_date_string_from_system(false)  # yerel "YYYY-MM-DD"


func _maybe_record() -> void:
	if _state == null:
		return
	var key := _today_key()
	var journal: Array = _state.stats.get("journal", [])
	if not journal.is_empty() and str(journal[0].get("date", "")) == key:
		# Bugünün kaydı var: en güncel havayı/sıcaklığı yansıt, notu koru.
		journal[0]["weather"] = WeatherService.state
		journal[0]["temp"] = WeatherService.temp_c
		_state.stats["journal"] = journal
		return
	# Yeni gün → yeni kayıt.
	var pool := note_keys_for(WeatherService.state)
	var entry := {
		"date": key,
		"weather": WeatherService.state,
		"temp": WeatherService.temp_c,
		"season": TimeService.get_season(),
		"note_key": pool[randi() % pool.size()],
	}
	journal.push_front(entry)
	if journal.size() > MAX_ENTRIES:
		journal.resize(MAX_ENTRIES)
	_state.stats["journal"] = journal
	EventBus.journal_entry_added.emit(key)


# --- UI yardımcıları -------------------------------------------------

## En yeni başta kayıt listesi (kopya değil — salt okuma amaçlı).
func entries() -> Array:
	if _state == null:
		return []
	return _state.stats.get("journal", [])


func entry_count() -> int:
	return entries().size()
