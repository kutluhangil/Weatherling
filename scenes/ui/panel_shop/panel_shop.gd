## Mağaza — coin ile kozmetik/dekor al. (Plan §6.8) Pay-to-win yok.
extends Control

const ITEM_PATHS := [
	"res://data/items/hat_straw.tres",
	"res://data/items/scarf_red.tres",
	"res://data/items/glasses.tres",
	"res://data/items/flower_crown.tres",
	"res://data/items/lantern.tres",
]

@onready var _list: VBoxContainer = $Panel/VBox/Scroll/List
@onready var _title: Label = $Panel/VBox/Title
@onready var _coins: Label = $Panel/VBox/Coins
@onready var _close: Button = $Panel/VBox/Close


func _ready() -> void:
	visible = false
	_title.text = tr("ACTION_SHOP")
	_close.text = tr("CLOSE")
	_close.pressed.connect(close)
	$Dim.gui_input.connect(_on_dim_input)
	EventBus.coins_changed.connect(func(_t): if visible: _rebuild())


func open() -> void:
	_rebuild()
	visible = true


func close() -> void:
	visible = false


func _rebuild() -> void:
	for c in _list.get_children():
		c.queue_free()
	_coins.text = "🪙 %d" % EconomyService.balance()
	var s: CreatureState = GameManager.current_state()
	for path in ITEM_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var item := load(path) as CosmeticItem
		if item == null:
			continue
		var owned := s != null and s.inventory.has(item.id)
		var b := Button.new()
		b.text = "%s %s — %d 🪙%s" % [item.emoji, tr(item.display_name_key), item.price, "  ✓" if owned else ""]
		b.disabled = owned or not EconomyService.can_afford(item.price)
		b.pressed.connect(_on_buy.bind(item))
		_list.add_child(b)


func _on_buy(item: CosmeticItem) -> void:
	var s: CreatureState = GameManager.current_state()
	if s == null:
		return
	if EconomyService.spend_coins(item.price):
		s.inventory[item.id] = 1
		EventBus.item_purchased.emit(item.id)
		GameManager.save_now()
	_rebuild()


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
