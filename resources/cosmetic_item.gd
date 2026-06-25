## Kozmetik / dekor item'ı (data-driven). (Plan §6.8, §7 wardrobe)
## data/items/<id>.tres. Görsel: Faz 7'de emoji placeholder, Faz 10'da gerçek sprite.
class_name CosmeticItem
extends Resource

@export var id: String = ""
@export var display_name_key: String = ""
@export var slot: String = "accessory"   # "hat" | "scarf" | "accessory" | "decor"
@export var price: int = 0
@export var icon: Texture2D
@export var sprite: Texture2D
@export var emoji: String = ""            # placeholder görsel
@export var unlocked_by_default: bool = false
