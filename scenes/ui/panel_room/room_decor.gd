## Oda dekorasyonu — serbest sürükle-bırak. (Plan §6.3) Mobilya al + yerleştir, konum kaydet.
## Eşya konumları CreatureState.home_decor = { id: {x, y} }. Mobilya art'ı yoksa renkli kutu.
extends Control

const DRAG := preload("res://scenes/ui/panel_room/draggable_item.gd")
const ROOM := Vector2(330, 300)
const FURNITURE := [
	{"id": "plant", "cost": 120},
	{"id": "lamp", "cost": 250},
	{"id": "rug", "cost": 180},
	{"id": "poster", "cost": 150},
	{"id": "record", "cost": 850},
]

@onready var _dim: ColorRect = $Dim
@onready var _panel: PanelContainer = $Panel
@onready var _title: Label = $Panel/VBox/Title
@onready var _coins: Label = $Panel/VBox/Coins
@onready var _room: Control = $Panel/VBox/Room
@onready var _shelf: HBoxContainer = $Panel/VBox/Shelf
@onready var _close: Button = $Panel/VBox/Close

var _shelf_btns := {}


func _ready() -> void:
	visible = false
	_panel.add_theme_stylebox_override("panel", UiFactory.panel())
	_title.text = tr("ROOM_TITLE")
	_close.text = tr("CLOSE")
	_close.pressed.connect(close)
	_dim.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: close())
	_build_shelf()


func open() -> void:
	_rebuild()
	visible = true


func close() -> void:
	visible = false


func _build_shelf() -> void:
	for f in FURNITURE:
		var b := Button.new()
		b.custom_minimum_size = Vector2(58, 40)
		b.pressed.connect(_buy.bind(f.id, f.cost))
		_shelf.add_child(b)
		_shelf_btns[f.id] = b


func _rebuild() -> void:
	for c in _room.get_children():
		if c.name != "RoomBg":
			c.queue_free()
	_coins.text = "🪙 %d" % EconomyService.balance()
	var s := GameManager.current_state()
	if s != null:
		for id in s.home_decor:
			var d: Dictionary = s.home_decor[id]
			_spawn(str(id), Vector2(float(d.get("x", 0)), float(d.get("y", 0))))
	_refresh_shelf()


func _refresh_shelf() -> void:
	var s := GameManager.current_state()
	for f in FURNITURE:
		var owned: bool = s != null and s.home_decor.has(f.id)
		var b: Button = _shelf_btns[f.id]
		if owned:
			b.text = "✓"
			b.disabled = true
		else:
			b.text = "%s\n🪙%d" % [tr("FURN_" + f.id), f.cost]
			b.disabled = not EconomyService.can_afford(f.cost)


func _buy(id: String, cost: int) -> void:
	var s := GameManager.current_state()
	if s == null or s.home_decor.has(id):
		return
	if not EconomyService.spend_coins(cost):
		return
	var center := ROOM * 0.5 - Vector2(32, 32)
	s.home_decor[id] = {"x": center.x, "y": center.y}
	_spawn(id, center)
	GameManager.save_now()
	_coins.text = "🪙 %d" % EconomyService.balance()
	_refresh_shelf()


func _spawn(id: String, pos: Vector2) -> void:
	var d := Control.new()
	d.set_script(DRAG)
	_room.add_child(d)
	d.setup(id, _tex(id))
	d.position = pos
	d.moved.connect(_on_moved)


func _tex(id: String) -> Texture2D:
	var path := "res://art/items/furniture/%s.png" % id
	return load(path) if ResourceLoader.exists(path) else null


func _on_moved(id: String, pos: Vector2) -> void:
	var s := GameManager.current_state()
	if s == null:
		return
	# Oda sınırlarına kıstır (dokunmatik taşmasın).
	var px := clampf(pos.x, 0.0, ROOM.x - 64.0)
	var py := clampf(pos.y, 0.0, ROOM.y - 64.0)
	s.home_decor[id] = {"x": px, "y": py}
	GameManager.save_now()
