## Ana yaşayan dünya. (Plan §10.2) Yaratık + hava/ışık VFX + bakım HUD.
extends Control

@onready var info: Label = $HUD/Info
@onready var action_bar: Control = $HUD/ActionBar
@onready var feed_panel: Control = $HUD/PanelFeed
@onready var faith_panel: Control = $HUD/PanelFaith
@onready var menu: Control = $HUD/MenuMain
@onready var skills_panel: Control = $HUD/PanelSkills
@onready var shop_panel: Control = $HUD/PanelShop
@onready var wardrobe_panel: Control = $HUD/PanelWardrobe
@onready var account_panel: Control = $HUD/PanelAccount
@onready var settings_panel: Control = $HUD/PanelSettings
@onready var achievements_panel: Control = $HUD/PanelAchievements
@onready var journal_panel: Control = $HUD/PanelJournal

const WEATHER_NAMES := ["CLEAR", "CLOUDS", "FOG", "RAIN", "SNOW", "THUNDER", "WINDY"]


func _ready() -> void:
	action_bar.feed_pressed.connect(feed_panel.open)
	action_bar.menu_pressed.connect(_on_menu)
	menu.open_skills.connect(skills_panel.open)
	menu.open_shop.connect(shop_panel.open)
	menu.open_wardrobe.connect(wardrobe_panel.open)
	menu.open_faith.connect(faith_panel.open)
	menu.open_account.connect(account_panel.open)
	menu.open_settings.connect(settings_panel.open)
	menu.open_achievements.connect(achievements_panel.open)
	menu.open_journal.connect(journal_panel.open)
	EventBus.weather_changed.connect(func(_s, _t, _d): _refresh())
	EventBus.time_phase_changed.connect(func(_p): _refresh())
	EventBus.offline_mode_changed.connect(func(_o): _refresh())
	_refresh()


func _on_menu() -> void:
	menu.open()


func _refresh() -> void:
	var s: CreatureState = GameManager.current_state()
	var cname := s.creature_name if s != null else "?"
	var phase_key := "PHASE_" + TimeService.get_phase().to_upper()
	var weather_key := "WEATHER_" + WEATHER_NAMES[WeatherService.state]
	var line := "%s · %s · %s %.0f°C" % [
		cname, tr(phase_key), tr(weather_key), WeatherService.temp_c
	]
	if WeatherService.is_offline:
		line += " · ⚠"
	info.text = line
