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
var JS: GDScript
var SV: GDScript
var SK: GDScript


func _initialize() -> void:
	WS = load("res://autoload/weather_service.gd")
	LS = load("res://autoload/life_stage_service.gd")
	NS = load("res://autoload/needs_service.gd")
	TS = load("res://autoload/time_service.gd")
	AS = load("res://autoload/achievement_service.gd")
	JS = load("res://autoload/journal_service.gd")
	SV = load("res://autoload/save_service.gd")
	SK = load("res://autoload/skill_service.gd")

	_test_weather_wmo()
	_test_stage_for_age()
	_test_decayed()
	_test_phase_for()
	_test_season_for()
	_test_moon_name()
	_test_achievements()
	_test_journal()
	_test_device_pass()
	_test_palette()
	_test_ui_factory()
	_test_scene_bg()
	_test_leveling()
	_test_minigame_rewards()

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
	# WeatherState enum sırası: CLEAR0 CLOUDS1 FOG2 RAIN3 SNOW4 THUNDER5 WINDY6.
	var w: Dictionary = WS.WeatherState
	_eq(WS.state_for_wmo(0, 0.0), w["CLEAR"], "wmo clear")
	_eq(WS.state_for_wmo(3, 0.0), w["CLOUDS"], "wmo clouds")
	_eq(WS.state_for_wmo(45, 0.0), w["FOG"], "wmo fog")
	_eq(WS.state_for_wmo(95, 0.0), w["THUNDER"], "wmo thunder")
	_eq(WS.state_for_wmo(71, 0.0), w["SNOW"], "wmo snow")
	_eq(WS.state_for_wmo(61, 0.0), w["RAIN"], "wmo rain")
	_eq(WS.state_for_wmo(81, 0.0), w["RAIN"], "wmo rain shower")
	# Rüzgâr eşiği (>=40 km/s) her kodu geçersiz kılar.
	_eq(WS.state_for_wmo(0, 50.0), w["WINDY"], "wmo windy override")
	_eq(WS.state_for_wmo(61, 39.0), w["RAIN"], "wmo wind below threshold")


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
	var d100: Dictionary = AS.unlocked_for({"days_together": 100})
	_eq(d100.has("hundred_days") and d100.has("week_together"), true, "ach hundred cascade")
	# Kar görülünce (state 4) → first_snow.
	_eq(AS.unlocked_for({"weather_seen": {4: true}}).has("first_snow"), true, "ach first_snow")
	# 7 hava türü → weather_watcher + storm_chaser.
	var allw := {"weather_seen": {0: true, 1: true, 2: true, 3: true, 4: true, 5: true, 6: true}}
	var w: Dictionary = AS.unlocked_for(allw)
	_eq(w.has("storm_chaser") and w.has("weather_watcher"), true, "ach storm_chaser")
	# 4 mevsim → four_seasons.
	var seasons := {"seasons_seen": {"spring": true, "summer": true, "autumn": true, "winter": true}}
	_eq(AS.unlocked_for(seasons).has("four_seasons"), true, "ach four_seasons")
	# Dolunay → moongazer.
	_eq(AS.unlocked_for({"full_moon_seen": true}).has("moongazer"), true, "ach moongazer")
	# Bağ seviyesi 10 → close_bond + soulmates.
	var b: Dictionary = AS.unlocked_for({"bond_level": 10})
	_eq(b.has("soulmates") and b.has("close_bond"), true, "ach soulmates")
	# 50 sevme → beloved.
	_eq(AS.unlocked_for({"pet_count": 50}).has("beloved"), true, "ach beloved")


# --- JournalService.note_keys_for ---------------------------------

func _test_journal() -> void:
	# Her hava durumu (0..6) en az bir not anahtarı döndürür.
	for w in range(7):
		_eq(JS.note_keys_for(w).size() >= 1, true, "journal pool %d" % w)
	# Bilinmeyen hava → CLEAR (0) havuzuna düşer.
	_eq(JS.note_keys_for(99), JS.note_keys_for(0), "journal unknown fallback")
	# Yağmur havuzu kar havuzundan farklı.
	_eq(JS.note_keys_for(3) != JS.note_keys_for(4), true, "journal distinct pools")


# --- SaveService.device_pass --------------------------------------

func _test_device_pass() -> void:
	var p: String = SV.device_pass()
	# SHA-256 hex → 64 karakter.
	_eq(p.length(), 64, "device_pass length")
	# Deterministik: aynı cihazda her çağrı aynı.
	_eq(SV.device_pass(), p, "device_pass deterministic")
	# Eski sabit anahtardan farklı (sabit-anahtar zaafı kalktı).
	_eq(p != "weatherling_local_v1", true, "device_pass not legacy")


# --- Palette (Pixel-Prime) ----------------------------------------

func _test_palette() -> void:
	var PAL: GDScript = load("res://theme/palette.gd")
	_eq(PAL.DUSK_AMBER, Color("#E87C3E"), "palette dusk_amber")
	_eq(PAL.HORIZON_GLOW, Color("#FFC078"), "palette horizon_glow")
	_eq(PAL.SURFACE, Color("#1d0c24"), "palette surface")
	_eq(PAL.need_color("hunger"), PAL.STATUS_HUNGER, "palette need hunger")
	_eq(PAL.need_color("energy"), PAL.STATUS_ENERGY, "palette need energy")
	_eq(PAL.need_color("happiness"), PAL.STATUS_LOVE, "palette need happiness")
	_eq(PAL.need_color("nope"), PAL.ON_SURFACE, "palette need fallback")


# --- UiFactory styleboxes -----------------------------------------

func _test_ui_factory() -> void:
	var UF: GDScript = load("res://theme/ui_factory.gd")
	var PAL: GDScript = load("res://theme/palette.gd")
	var panel: StyleBoxFlat = UF.panel()
	_eq(panel.bg_color, PAL.SURFACE_CONTAINER, "uifactory panel bg")
	_eq(panel.border_color, PAL.DUSK_AMBER, "uifactory panel border")
	_eq(panel.border_width_left, 4, "uifactory panel border width")
	var fill: StyleBoxFlat = UF.bar_fill(PAL.STATUS_ENERGY)
	_eq(fill.bg_color, PAL.STATUS_ENERGY, "uifactory bar_fill color")


# --- SceneBackground.bg_key ---------------------------------------

func _test_scene_bg() -> void:
	var SB: GDScript = load("res://scenes/scene_background/scene_background.gd")
	_eq(SB.bg_key(3, "day"), "res://art/backgrounds/rain_day.png", "bg rain_day")
	_eq(SB.bg_key(4, "night"), "res://art/backgrounds/snow_night.png", "bg snow_night")
	_eq(SB.bg_key(0, "dusk"), "res://art/backgrounds/clear_dusk.png", "bg clear_dusk")
	_eq(SB.bg_key(99, "zzz"), "res://art/backgrounds/clear_day.png", "bg fallback key")


# --- SkillService.level_for_xp (Level/XP) -------------------------

func _test_leveling() -> void:
	# Eşik tablosu [0,50,120,220,360,550,800,1120,1520,2000].
	_eq(SK.level_for_xp(0), 1, "level xp 0")
	_eq(SK.level_for_xp(49), 1, "level xp 49")
	_eq(SK.level_for_xp(50), 2, "level xp 50")
	_eq(SK.level_for_xp(119), 2, "level xp 119")
	_eq(SK.level_for_xp(120), 3, "level xp 120")
	_eq(SK.level_for_xp(2000), 10, "level xp 2000")
	_eq(SK.level_for_xp(99999), 10, "level cap")


# --- RainCatcher.rewards_for_score (mini-oyun) --------------------

func _test_minigame_rewards() -> void:
	var RC: GDScript = load("res://scenes/minigames/rain_catcher/rain_catcher.gd")
	var r0: Dictionary = RC.rewards_for_score(0)
	_eq(r0.coins, 0, "mg reward 0 coins")
	_eq(r0.xp, 0, "mg reward 0 xp")
	var r10: Dictionary = RC.rewards_for_score(10)
	_eq(r10.coins, 10, "mg reward 10 coins")
	_eq(r10.xp, 5, "mg reward 10 xp")
	var r7: Dictionary = RC.rewards_for_score(7)
	_eq(r7.xp, 4, "mg reward 7 xp ceil")
