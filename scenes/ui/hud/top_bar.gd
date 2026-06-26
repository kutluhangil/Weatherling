## Üst HUD: marka + hava rozeti + coin + Level/XP. (Pixel-Prime, Plan §5.1)
extends Control

const WEATHER_NAMES := ["CLEAR", "CLOUDS", "FOG", "RAIN", "SNOW", "THUNDER", "WINDY"]

@onready var _brand: Label = $Row/Left/Brand
@onready var _weather: Label = $Row/Left/Weather
@onready var _coin: Label = $Row/Right/Coin
@onready var _level: Label = $Row/Right/Level
@onready var _xp: ProgressBar = $Row/Right/Xp


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_brand.text = tr("APP_NAME")
	_brand.add_theme_color_override("font_color", Palette.DUSK_AMBER)
	_brand.add_theme_font_size_override("font_size", 22)
	# Fontlar geldiyse rol bazlı uygula (display/mono).
	var disp := FontLoader.display_font()
	if disp != null:
		_brand.add_theme_font_override("font", disp)
	var mono := FontLoader.mono_font()
	if mono != null:
		_coin.add_theme_font_override("font", mono)
		_level.add_theme_font_override("font", mono)
	_weather.add_theme_color_override("font_color", Palette.ON_SURFACE_VARIANT)
	_weather.add_theme_font_size_override("font_size", 12)
	_coin.add_theme_color_override("font_color", Palette.HORIZON_GLOW)
	_level.add_theme_color_override("font_color", Palette.HORIZON_GLOW)
	_level.add_theme_font_size_override("font_size", 12)
	_xp.custom_minimum_size = Vector2(96, 6)
	_xp.show_percentage = false
	_xp.add_theme_stylebox_override("background", UiFactory.bar_track())
	_xp.add_theme_stylebox_override("fill", UiFactory.bar_fill(Palette.HORIZON_GLOW))
	EventBus.weather_changed.connect(func(_s, _t, _d): _refresh())
	EventBus.offline_mode_changed.connect(func(_o): _refresh())
	EventBus.coins_changed.connect(func(_c): _refresh())
	EventBus.bond_xp_gained.connect(func(_x): _refresh())
	EventBus.state_loaded.connect(func(_s): _refresh())
	EventBus.locale_changed.connect(func(_l): _refresh())
	_refresh()


func _refresh() -> void:
	var wname := WEATHER_NAMES[WeatherService.state] if WeatherService.state < WEATHER_NAMES.size() else "CLEAR"
	var line := "%s  %.0f°C" % [tr("WEATHER_" + wname), WeatherService.temp_c]
	if WeatherService.is_offline:
		line += "  ⚠"
	_weather.text = line
	_coin.text = "🪙 %s" % _commafy(EconomyService.balance())
	var s: CreatureState = GameManager.current_state()
	var xp: int = s.bond_xp if s != null else 0
	# Seviye + bar ilerlemesi SkillService eşik tablosundan (tek kaynak).
	var lvl := SkillService.level_for_xp(xp)
	var th: Array = SkillService.LEVEL_THRESHOLDS
	var cur: int = th[lvl - 1] if lvl - 1 < th.size() else int(th[th.size() - 1])
	var nxt: int = th[lvl] if lvl < th.size() else cur + 480
	_level.text = "LVL %d" % lvl
	_xp.max_value = maxi(nxt - cur, 1)
	_xp.value = xp - cur


func _commafy(n: int) -> String:
	var s := str(n)
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return out
