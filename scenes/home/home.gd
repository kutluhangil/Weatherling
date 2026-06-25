## Ana yaşayan dünya. (Plan §10.2) Faz 0: sinyal akışını kanıtlayan debug ekranı.
## Faz 1: Creature buraya (CreatureAnchor) gelir. Faz 2-3: ışık shader'ı + hava VFX.
extends Control

@onready var info: Label = $HUD/Info

const WEATHER_NAMES := ["clear", "clouds", "fog", "rain", "snow", "thunder", "windy"]


func _ready() -> void:
	EventBus.weather_changed.connect(_on_weather_changed)
	EventBus.time_phase_changed.connect(func(_p): _refresh())
	EventBus.season_changed.connect(func(_s): _refresh())
	EventBus.need_changed.connect(func(_k, _v): _refresh())
	_refresh()


func _on_weather_changed(_state: int, _temp: float, _is_day: bool) -> void:
	_refresh()


func _refresh() -> void:
	var s: CreatureState = GameManager.current_state()
	var cname := s.creature_name if s != null else "?"
	var stage := s.life_stage if s != null else "-"
	var moon: Dictionary = TimeService.get_moon()
	var w: int = WeatherService.state
	info.text = "Weatherling — Faz 0\n\n" + \
		"Yaratık: %s\n" % cname + \
		"Evre: %s\n" % stage + \
		"Faz: %s\n" % TimeService.get_phase() + \
		"Mevsim: %s\n" % TimeService.get_season() + \
		"Ay: %s\n" % moon.name + \
		"Hava: %s (%.0f°C)\n" % [WEATHER_NAMES[w], WeatherService.temp_c] + \
		("• çevrimdışı" if WeatherService.is_offline else "")
