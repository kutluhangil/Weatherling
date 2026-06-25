## Bir yemek item'ı (data-driven). Plan §6.5.
## data/foods/<id>.tres. Yaş evresine göre tercih/tepki LifeStageConfig'ten gelir.
class_name FoodItem
extends Resource

@export var id: String = ""
@export var display_name_key: String = ""
@export var icon: Texture2D
@export var sprite: Texture2D

# Etki (0–100 ölçeğinde delta) --------------------------------------
@export var hunger_restore: float = 20.0
@export var happiness_delta: float = 5.0
@export var health_delta: float = 0.0
@export var energy_delta: float = 0.0

# Ekonomi ------------------------------------------------------------
@export var price: int = 0
@export var unlocked_by_default: bool = true

# Etiketler (tercih eşleşmesi için) ---------------------------------
@export var tags: Array[String] = []          # "sweet","veg","soup","coffee"...
