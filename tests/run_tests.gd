## Bağımsız test koşucusu — GUT'suz, headless çalışır. (Plan §21)
## Çalıştır:  godot --headless -s tests/run_tests.gd
## Saf/statik fonksiyonları doğrular (autoload örneği gerekmez). Fail varsa exit 1.
extends SceneTree

var _pass := 0
var _fail := 0

# Saf fonksiyonları barındıran scriptler (statik çağrı için; _initialize'da yüklenir).
var WS: GDScript
var LS: GDScript
var NS: GDScript
var TS: GDScript
var AS: GDScript


func _initialize() -> void:
	WS = load("res://autoload/weather_service.gd")
	LS = load("res://autoload/life_stage_service.gd")
	NS = load("res://autoload/needs_service.gd")
	TS = load("res://autoload/time_service.gd")
	AS = load("res://autoload/achievement_service.gd")

	_test_weather_wmo()
	_test_stage_for_age()
	_test_decayed()
	_test_phase_for()
	_test_season_for()
	_test_moon_name()
	_test_achievements()

	print("\n==== %d passed, %d failed ====" % [_pass, _fail])
	quit(1 if _fail > 0 else 0)


# --- Assertion yardımcıları ---------------------------------------

func _eq(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		_pass += 1
	else:
		_fail += 1
		printerr("FAIL %s: got %s, expected %s" % [label, str(actual), str(expected)])


func _approx(actual: float, expected: float, label: String) -> void:
	if is_equal_approx(actual, expected):
		_pass += 1
	else:
		_fail += 1
		printerr("FAIL %s: got %f, expected %f" % [label, actual, expected])


# --- WeatherService.state_for_wmo ---------------------------------

func _test_weather_wmo() -> void:
	var w := WS.WeatherState
	_eq(WS.state_for_wmo(0, 0.0), w.CLEAR, "wmo clear")
	_eq(WS.state_for_wmo(3, 0.0), w.CLOUDS, "wmo clouds")
	_eq(WS.state_for_wmo(45, 0.0), w.FOG, "wmo fog")
	_eq(WS.state_for_wmo(95, 0.0), w.THUNDER, "wmo thunder")
	_eq(WS.state_for_wmo(71, 0.0), w.SNOW, "wmo snow")
	_eq(WS.state_for_wmo(61, 0.0), w.RAIN, "wmo rain")
	_eq(WS.state_for_wmo(81, 0.0), w.RAIN, "wmo rain shower")
	# Rüzgâr eşiği (>=40 km/s) her kodu geçersiz kılar.
	_eq(WS.state_for_wmo(0, 50.0), w.WINDY, "wmo windy override")
	_eq(WS.state_for_wmo(61, 39.0), w.RAIN, "wmo wind below threshold")


# --- LifeStageService.stage_for_age -------------------------------

func _test_stage_for_age() -> void:
	_eq(LS.stage_for_age(0), "filiz", "age 0")
	_eq(LS.stage_for_age(12), "filiz", "age 12")
	_eq(LS.stage_for_age(13), "tomurcuk", "age 13")
	_eq(LS.stage_for_age(18), "cicek", "age 18")
	_eq(LS.stage_for_age(30), "meyve", "age 30")
	_eq(LS.stage_for_age(45), "hasat", "age 45")
	_eq(LS.stage_for_age(60), "kok", "age 60")
	_eq(LS.stage_for_age(75), "cinar", "age 75")
	_eq(LS.stage_for_age(120), "cinar", "age 120")
	_eq(LS.stage_for_age(-5), "filiz", "age negative")


# --- NeedsService.decayed -----------------------------------------

func _test_decayed() -> void:
	# 4 birim/saat × 1 saat = 4 düşüş.
	_approx(NS.decayed(100.0, 4.0, 3600.0, false), 96.0, "decay 1h")
	_approx(NS.decayed(100.0, 4.0, 1800.0, false), 98.0, "decay 30m")
	# Taban koruması: büyük offline düşüş FLOOR(15) altına itmez.
	_approx(NS.decayed(20.0, 4.0, 36000.0, true), 15.0, "decay floor clamp")
	# Zaten taban altındaysa daha aşağı itmez (min(value,FLOOR) korur).
	_approx(NS.decayed(10.0, 4.0, 3600.0, true), 10.0, "decay below floor stays")
	# Üst sınır: negatif rate 100'ü aşmaz.
	_approx(NS.decayed(100.0, -10.0, 3600.0, false), 100.0, "decay clamp top")


# --- TimeService.phase_for (sr=06:30, ss=19:30, twilight ±45) -----

func _test_phase_for() -> void:
	_eq(TS.phase_for(700, 390, 1170), "day", "phase day")
	_eq(TS.phase_for(390, 390, 1170), "dawn", "phase dawn center")
	_eq(TS.phase_for(360, 390, 1170), "dawn", "phase dawn early edge")
	_eq(TS.phase_for(1170, 390, 1170), "dusk", "phase dusk center")
	_eq(TS.phase_for(1230, 390, 1170), "night", "phase night after dusk")
	_eq(TS.phase_for(100, 390, 1170), "night", "phase deep night")


# --- TimeService.season_for ---------------------------------------

func _test_season_for() -> void:
	_eq(TS.season_for(1, true), "winter", "north jan")
	_eq(TS.season_for(12, true), "winter", "north dec")
	_eq(TS.season_for(4, true), "spring", "north apr")
	_eq(TS.season_for(7, true), "summer", "north jul")
	_eq(TS.season_for(10, true), "autumn", "north oct")
	_eq(TS.season_for(1, false), "summer", "south jan")
	_eq(TS.season_for(7, false), "winter", "south jul")


# --- TimeService._moon_name ---------------------------------------

func _test_moon_name() -> void:
	_eq(TS._moon_name(0.0), "new_moon", "moon new")
	_eq(TS._moon_name(0.25), "first_quarter", "moon first quarter")
	_eq(TS._moon_name(0.5), "full_moon", "moon full")
	_eq(TS._moon_name(0.75), "last_quarter", "moon last quarter")
	_eq(TS._moon_name(1.0), "new_moon", "moon wrap")


# --- AchievementService.unlocked_for ------------------------------

func _test_achievements() -> void:
	# Boş stats → hiçbir başarım.
	_eq(AS.unlocked_for({}).size(), 0, "ach empty")
	# 1 gün → first_day.
	_eq(AS.unlocked_for({"days_together": 1}).has("first_day"), true, "ach first_day")
	# 100 gün → first_day + week + hundred.
	var d100 := AS.unlocked_for({"days_together": 100})
	_eq(d100.has("hundred_days") and d100.has("week_together"), true, "ach hundred cascade")
	# Kar görülünce (state 4) → first_snow.
	_eq(AS.unlocked_for({"weather_seen": {4: true}}).has("first_snow"), true, "ach first_snow")
	# 7 hava türü → weather_watcher + storm_chaser.
	var allw := {"weather_seen": {0: true, 1: true, 2: true, 3: true, 4: true, 5: true, 6: true}}
	var w := AS.unlocked_for(allw)
	_eq(w.has("storm_chaser") and w.has("weather_watcher"), true, "ach storm_chaser")
	# 4 mevsim → four_seasons.
	var seasons := {"seasons_seen": {"spring": true, "summer": true, "autumn": true, "winter": true}}
	_eq(AS.unlocked_for(seasons).has("four_seasons"), true, "ach four_seasons")
	# Dolunay → moongazer.
	_eq(AS.unlocked_for({"full_moon_seen": true}).has("moongazer"), true, "ach moongazer")
	# Bağ seviyesi 10 → close_bond + soulmates.
	var b := AS.unlocked_for({"bond_level": 10})
	_eq(b.has("soulmates") and b.has("close_bond"), true, "ach soulmates")
	# 50 sevme → beloved.
	_eq(AS.unlocked_for({"pet_count": 50}).has("beloved"), true, "ach beloved")
