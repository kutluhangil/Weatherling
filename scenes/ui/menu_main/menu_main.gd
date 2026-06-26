## Ana menü — alt panellere geçiş. (Plan §10.2) Faz 7'de temel; Faz 10'da cila + Ayarlar/Profil.
extends Control

signal open_skills
signal open_shop
signal open_wardrobe
signal open_journal
signal open_achievements
signal open_account
signal open_settings


func _ready() -> void:
	visible = false
	$Panel/VBox/Title.text = tr("ACTION_MENU")
	$Panel/VBox/Skills.text = tr("ACTION_SKILLS")
	$Panel/VBox/Shop.text = tr("ACTION_SHOP")
	$Panel/VBox/Wardrobe.text = tr("MENU_WARDROBE")
	$Panel/VBox/Journal.text = tr("MENU_JOURNAL")
	$Panel/VBox/Achievements.text = tr("MENU_ACHIEVEMENTS")
	$Panel/VBox/Account.text = tr("MENU_ACCOUNT")
	$Panel/VBox/Settings.text = tr("SETTINGS")
	$Panel/VBox/Close.text = tr("CLOSE")
	$Panel/VBox/Skills.pressed.connect(_emit_and_close.bind("open_skills"))
	$Panel/VBox/Shop.pressed.connect(_emit_and_close.bind("open_shop"))
	$Panel/VBox/Wardrobe.pressed.connect(_emit_and_close.bind("open_wardrobe"))
	$Panel/VBox/Journal.pressed.connect(_emit_and_close.bind("open_journal"))
	$Panel/VBox/Achievements.pressed.connect(_emit_and_close.bind("open_achievements"))
	$Panel/VBox/Account.pressed.connect(_emit_and_close.bind("open_account"))
	$Panel/VBox/Settings.pressed.connect(_emit_and_close.bind("open_settings"))
	$Panel/VBox/Close.pressed.connect(close)
	$Dim.gui_input.connect(_on_dim_input)


func _emit_and_close(signal_name: String) -> void:
	emit_signal(signal_name)
	close()


func open() -> void:
	visible = true


func close() -> void:
	visible = false


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
