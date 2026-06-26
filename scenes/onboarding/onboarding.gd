## Onboarding: isim → yaş → konum(ops) → başla. (Plan §10.3)
## Faz 5: tek formlu sade akış. Yaş yaratığın evresini belirler. (İnanç adımı kaldırıldı.)
extends Control

@onready var _box: VBoxContainer = $Center/VBox
@onready var _name: LineEdit = $Center/VBox/NameEdit
@onready var _age: SpinBox = $Center/VBox/AgeSpin
@onready var _city: LineEdit = $Center/VBox/CityEdit
@onready var _start: Button = $Center/VBox/Start


func _ready() -> void:
	$Center/VBox/Title.text = tr("APP_NAME")
	$Center/VBox/NameLabel.text = tr("ONBOARD_NAME")
	$Center/VBox/AgeLabel.text = tr("ONBOARD_AGE")
	$Center/VBox/CityLabel.text = tr("ONBOARD_LOCATION")
	_start.text = tr("ONBOARD_START")
	_name.placeholder_text = "Weatherling"
	_start.pressed.connect(_on_start)


func _on_start() -> void:
	var nm := _name.text.strip_edges()
	if nm == "":
		nm = "Weatherling"
	var age := int(_age.value)
	GameManager.new_game(nm, age)
	var city := _city.text.strip_edges()
	if city != "":
		Settings.set_value("general/location_mode", "manual")
		WeatherService.set_city(city)
	SceneManager.change_scene("res://scenes/home/home.tscn")
