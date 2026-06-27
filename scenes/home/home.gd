## Ana yaşayan dünya. (Pixel-Prime, Plan §5.1) SceneBackground + yaratık + HUD.
extends Control

@onready var top_bar: Control = $HUD/TopBar
@onready var bottom_nav: Control = $HUD/BottomNav
@onready var drawer: Control = $HUD/InteractionDrawer
@onready var feed_panel: Control = $HUD/PanelFeed
@onready var menu: Control = $HUD/MenuMain
@onready var skills_panel: Control = $HUD/PanelSkills
@onready var shop_panel: Control = $HUD/PanelShop
@onready var wardrobe_panel: Control = $HUD/PanelWardrobe
@onready var account_panel: Control = $HUD/PanelAccount
@onready var settings_panel: Control = $HUD/PanelSettings
@onready var achievements_panel: Control = $HUD/PanelAchievements
@onready var journal_panel: Control = $HUD/PanelJournal
@onready var play_screen: Control = $HUD/PlayScreen
@onready var room_panel: Control = $HUD/RoomDecor


func _ready() -> void:
	# FAB → etkileşim drawer; drawer "Besle" → yemek paneli.
	bottom_nav.fab_interact.connect(drawer.open)
	drawer.feed_pressed.connect(feed_panel.open)
	# Alt nav sekmeleri.
	bottom_nav.nav_menu.connect(menu.open)
	bottom_nav.nav_shop.connect(shop_panel.open)
	bottom_nav.nav_play.connect(_on_play)
	bottom_nav.nav_home.connect(_on_home)
	# Menü → derin sayfalar.
	menu.open_skills.connect(skills_panel.open)
	menu.open_shop.connect(shop_panel.open)
	menu.open_wardrobe.connect(wardrobe_panel.open)
	menu.open_account.connect(account_panel.open)
	menu.open_settings.connect(settings_panel.open)
	menu.open_achievements.connect(achievements_panel.open)
	menu.open_journal.connect(journal_panel.open)
	menu.open_room.connect(room_panel.open)


func _on_play() -> void:
	play_screen.open()


func _on_home() -> void:
	pass  # Ana ekran zaten görünür; ileride panelleri kapatır.
