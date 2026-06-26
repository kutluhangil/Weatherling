## Başarımlar & koleksiyon — nazik, cezasız ilerleme. (Plan §22)
## EventBus olaylarını dinler, sayaçları state.stats içine yazar, koşul sağlanınca
## başarım açar (bir kez) ve EventBus.achievement_unlocked yayar.
## Unlock mantığı SAF (unlocked_for) → GUT/headless ile test edilir.
## stats şeması (CreatureState.stats, kalıcı):
##   weather_seen: {state_int: true}, seasons_seen: {name: true},
##   pet_count/feed_count/play_count: int, bond_level: int,
##   full_moon_seen: bool, days_together: int, achievements: {id: unlock_unix}
extends Node

# WeatherState enum aynası (saf evaluator dependency-free kalsın diye).
# CLEAR0 CLOUDS1 FOG2 RAIN3 SNOW4 THUNDER5 WINDY6
const _RAIN := 3
const _SNOW := 4
const _ALL_WEATHER := 7

var _state: CreatureState = null


func _ready() -> void:
	EventBus.state_loaded.connect(_on_state_loaded)
	EventBus.weather_changed.connect(_on_weather)
	EventBus.season_changed.connect(_on_season)
	EventBus.moon_phase_changed.connect(_on_moon)
	EventBus.creature_interacted.connect(_on_interacted)
	EventBus.bond_level_up.connect(_on_bond_up)


# --- Saf unlock değerlendirici (test edilir) -----------------------

## stats sözlüğü → açık olması gereken başarım id'leri. (Saf)
static func unlocked_for(s: Dictionary) -> Dictionary:
	var u := {}
	var weather: Dictionary = s.get("weather_seen", {})
	var seasons: Dictionary = s.get("seasons_seen", {})
	var days := int(s.get("days_together", 0))
	var pets := int(s.get("pet_count", 0))
	var feeds := int(s.get("feed_count", 0))
	var bond := int(s.get("bond_level", 1))
	var full_moon := bool(s.get("full_moon_seen", false))

	if days >= 1: u["first_day"] = true
	if days >= 7: u["week_together"] = true
	if days >= 100: u["hundred_days"] = true
	if weather.has(_RAIN): u["first_rain"] = true
	if weather.has(_SNOW): u["first_snow"] = true
	if weather.size() >= 5: u["weather_watcher"] = true
	if weather.size() >= _ALL_WEATHER: u["storm_chaser"] = true
	if seasons.size() >= 4: u["four_seasons"] = true
	if full_moon: u["moongazer"] = true
	if pets >= 50: u["beloved"] = true
	if feeds >= 50: u["well_fed"] = true
	if bond >= 5: u["close_bond"] = true
	if bond >= 10: u["soulmates"] = true
	return u


## Açık + henüz açılmamış tüm başarımların tam listesi (UI için id sırası).
const ALL_IDS := [
	"first_day", "week_together", "hundred_days",
	"first_rain", "first_snow", "weather_watcher", "storm_chaser",
	"four_seasons", "moongazer", "beloved", "well_fed",
	"close_bond", "soulmates",
]


# --- Olay kancaları -------------------------------------------------

func _on_state_loaded(state: Resource) -> void:
	_state = state as CreatureState
	_eval()


func _on_weather(state: int, _temp: float, _is_day: bool) -> void:
	if _state == null:
		return
	var seen: Dictionary = _state.stats.get("weather_seen", {})
	seen[state] = true
	_state.stats["weather_seen"] = seen
	_eval()


func _on_season(season_name: String) -> void:
	if _state == null:
		return
	var seen: Dictionary = _state.stats.get("seasons_seen", {})
	seen[season_name] = true
	_state.stats["seasons_seen"] = seen
	_eval()


func _on_moon(phase_name: String, _illum: float) -> void:
	if _state == null:
		return
	if phase_name == "full_moon":
		_state.stats["full_moon_seen"] = true
		_eval()


func _on_interacted(kind: String) -> void:
	if _state == null:
		return
	var key := kind + "_count"
	_state.stats[key] = int(_state.stats.get(key, 0)) + 1
	_eval()


func _on_bond_up(level: int) -> void:
	if _state == null:
		return
	_state.stats["bond_level"] = level
	_eval()


# --- Değerlendir + aç -----------------------------------------------

func _eval() -> void:
	if _state == null:
		return
	# Gün sayısını şimdiki zamandan türet (evaluator saf kalsın diye stats'a yaz).
	if _state.birth_unix > 0:
		var days := int((Time.get_unix_time_from_system() - _state.birth_unix) / 86400)
		_state.stats["days_together"] = maxi(days, int(_state.stats.get("days_together", 0)))

	var unlocked := unlocked_for(_state.stats)
	var have: Dictionary = _state.stats.get("achievements", {})
	var changed := false
	for id in unlocked:
		if not have.has(id):
			have[id] = int(Time.get_unix_time_from_system())
			EventBus.achievement_unlocked.emit(id)
			changed = true
	if changed:
		_state.stats["achievements"] = have


# --- UI yardımcıları -------------------------------------------------

func is_unlocked(id: String) -> bool:
	if _state == null:
		return false
	return _state.stats.get("achievements", {}).has(id)


func unlocked_count() -> int:
	if _state == null:
		return 0
	return _state.stats.get("achievements", {}).size()


## Görülen hava türü id'leri (koleksiyon ekranı için).
func weather_collection() -> Dictionary:
	if _state == null:
		return {}
	return _state.stats.get("weather_seen", {})
