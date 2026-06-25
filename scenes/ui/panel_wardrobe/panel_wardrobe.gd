## Gardırop — sahip olunan kozmetikleri giydir/çıkar (slot başına). (Plan §7)
## Faz 7: veri + giydirme. Yaratık üzerinde görsel uygulama Faz 10 (gerçek sprite).
extends Control

@onready var _list: VBoxContainer = $Panel/VBox/Scroll/List
@onready var _title: Label = $Panel/VBox/Title
@onready var _empty: Label = $Panel/VBox/Empty
@onready var _close: Button = $Panel/VBox/Close


func _ready() -> void:
	visible = false
	_title.text = tr("MENU_WARDROBE")
	_empty.text = tr("WARDROBE_EMPTY")
	_close.text = tr("CLOSE")
	_close.pressed.connect(close)
	$Dim.gui_input.connect(_on_dim_input)


func open() -> void:
	_rebuild()
	visible = true


func close() -> void:
	visible = false


func _rebuild() -> void:
	for c in _list.get_children():
		c.queue_free()
	var s: CreatureState = GameManager.current_state()
	var has_items := s != null and not s.inventory.is_empty()
	_empty.visible = not has_items
	if not has_items:
		return
	for id in s.inventory:
		var path := "res://data/items/%s.tres" % id
		if not ResourceLoader.exists(path):
			continue
		var item := load(path) as CosmeticItem
		if item == null:
			continue
		var equipped: bool = s.equipped_cosmetics.get(item.slot, "") == item.id
		var b := Button.new()
		b.text = "%s %s%s" % [item.emoji, tr(item.display_name_key), "  ★" if equipped else ""]
		b.pressed.connect(_on_toggle.bind(item))
		_list.add_child(b)


func _on_toggle(item: CosmeticItem) -> void:
	var s: CreatureState = GameManager.current_state()
	if s == null:
		return
	if s.equipped_cosmetics.get(item.slot, "") == item.id:
		s.equipped_cosmetics.erase(item.slot)
	else:
		s.equipped_cosmetics[item.slot] = item.id
	EventBus.cosmetics_changed.emit(s.equipped_cosmetics)
	GameManager.save_now()
	_rebuild()


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
