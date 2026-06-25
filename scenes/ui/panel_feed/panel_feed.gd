## Besleme paneli — yemek listesi, dokun → besle. (Plan §6.5, §10.2)
extends Control

const FOOD_PATHS := [
	"res://data/foods/apple.tres",
	"res://data/foods/soup.tres",
	"res://data/foods/salad.tres",
	"res://data/foods/coffee.tres",
	"res://data/foods/candy.tres",
]

@onready var _list: VBoxContainer = $Panel/VBox/FoodList
@onready var _title: Label = $Panel/VBox/Title
@onready var _close: Button = $Panel/VBox/Close


func _ready() -> void:
	visible = false
	_title.text = tr("ACTION_FEED")
	_close.text = tr("CLOSE")
	_close.pressed.connect(close)
	$Dim.gui_input.connect(_on_dim_input)
	_build()


func open() -> void:
	visible = true


func close() -> void:
	visible = false


func _build() -> void:
	for path in FOOD_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var food := load(path) as FoodItem
		if food == null:
			continue
		var b := Button.new()
		b.text = "%s   (+%d 🍽)" % [tr(food.display_name_key), int(food.hunger_restore)]
		b.pressed.connect(_on_food_pressed.bind(food))
		_list.add_child(b)


func _on_food_pressed(food: FoodItem) -> void:
	NeedsService.feed(food)
	close()


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
