## Alt eylem barı: Besle / Oyna / Temizle / Uyut / Menü. (Plan §10.2)
extends Control

signal feed_pressed
signal menu_pressed


func _ready() -> void:
	$Bar/Feed.pressed.connect(func(): feed_pressed.emit())
	$Bar/Play.pressed.connect(func(): NeedsService.apply_care("play"))
	$Bar/Clean.pressed.connect(func(): NeedsService.apply_care("clean"))
	$Bar/Sleep.pressed.connect(func(): NeedsService.apply_care("sleep"))
	$Bar/Menu.pressed.connect(func(): menu_pressed.emit())
	_localize()
	EventBus.locale_changed.connect(func(_l): _localize())


func _localize() -> void:
	$Bar/Feed.text = tr("ACTION_FEED")
	$Bar/Play.text = tr("ACTION_PLAY")
	$Bar/Clean.text = tr("ACTION_CLEAN")
	$Bar/Sleep.text = tr("ACTION_SLEEP")
	$Bar/Menu.text = tr("ACTION_MENU")
