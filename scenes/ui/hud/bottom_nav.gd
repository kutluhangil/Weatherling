## Alt navigasyon + orta FAB. (Pixel-Prime, Plan §5.2)
## Home · Oyna · [FAB=Etkileşim] · Mağaza · Menü. Etkileşim cooldown YOK.
extends Control

signal nav_home
signal nav_play
signal nav_shop
signal nav_menu
signal fab_interact

@onready var _bg: Panel = $Bg
@onready var _home: Button = $Row/Home
@onready var _play: Button = $Row/Oyna
@onready var _shop: Button = $Row/Magaza
@onready var _menu: Button = $Row/Menu
@onready var _fab: Button = $Fab


func _ready() -> void:
	var bgs := StyleBoxFlat.new()
	bgs.bg_color = Palette.SURFACE_CONTAINER
	bgs.border_color = Palette.PRIMARY_CONTAINER
	bgs.border_width_top = 4
	_bg.add_theme_stylebox_override("panel", bgs)

	for b in [_home, _play, _shop, _menu]:
		_flatten(b)
	_style_fab()

	_home.pressed.connect(func(): nav_home.emit())
	_play.pressed.connect(func(): nav_play.emit())
	_shop.pressed.connect(func(): nav_shop.emit())
	_menu.pressed.connect(func(): nav_menu.emit())
	_fab.pressed.connect(func(): fab_interact.emit())
	_localize()
	EventBus.locale_changed.connect(func(_l): _localize())


func _localize() -> void:
	_home.text = tr("NAV_HOME")
	_play.text = tr("NAV_PLAY")
	_shop.text = tr("ACTION_SHOP")
	_menu.text = tr("ACTION_MENU")


func _flatten(b: Button) -> void:
	var empty := StyleBoxEmpty.new()
	b.add_theme_stylebox_override("normal", empty)
	b.add_theme_stylebox_override("hover", empty)
	b.add_theme_stylebox_override("pressed", empty)
	b.add_theme_stylebox_override("focus", empty)
	b.add_theme_color_override("font_color", Palette.ON_SURFACE_VARIANT)
	b.add_theme_color_override("font_pressed_color", Palette.HORIZON_GLOW)
	b.add_theme_color_override("font_hover_color", Palette.ON_SURFACE)
	b.add_theme_font_size_override("font_size", 13)


func _style_fab() -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = Palette.DUSK_AMBER
	s.set_corner_radius_all(999)
	s.border_color = Palette.ON_PRIMARY_CONTAINER
	s.set_border_width_all(3)
	s.shadow_color = Color(0, 0, 0, 0.4)
	s.shadow_size = 6
	_fab.add_theme_stylebox_override("normal", s)
	_fab.add_theme_stylebox_override("hover", s)
	var sp := s.duplicate()
	sp.bg_color = Palette.PRIMARY_CONTAINER
	_fab.add_theme_stylebox_override("pressed", sp)
	_fab.icon = load("res://art/ui/icons/clean.svg")
	_fab.add_theme_color_override("icon_normal_color", Palette.ON_PRIMARY_CONTAINER)
	_fab.expand_icon = true
