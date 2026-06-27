## Oyna ekranı — mini-oyun listesi. (Plan §6.2) Hava Avcısı oynanır; diğerleri "Yakında".
extends Control

const RAIN := preload("res://scenes/minigames/rain_catcher/rain_catcher.tscn")
const STAR := preload("res://scenes/minigames/star_connect/star_connect.tscn")
const RHYTHM := preload("res://scenes/minigames/rhythm_forest/rhythm_forest.tscn")

@onready var _dim: ColorRect = $Dim
@onready var _panel: PanelContainer = $Panel
@onready var _title: Label = $Panel/VBox/Title
@onready var _list: VBoxContainer = $Panel/VBox/Scroll/List
@onready var _close: Button = $Panel/VBox/Close


func _ready() -> void:
	visible = false
	_panel.add_theme_stylebox_override("panel", UiFactory.panel())
	_title.text = tr("MG_TITLE")
	_close.text = tr("CLOSE")
	_close.pressed.connect(close)
	_dim.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: close())


func open() -> void:
	_rebuild()
	visible = true


func close() -> void:
	visible = false


func _rebuild() -> void:
	for c in _list.get_children():
		c.queue_free()
	var s := GameManager.current_state()
	var stats: Dictionary = s.stats if s != null else {}
	_add_card("MG_RAIN", "MG_RAIN_DESC", 15, true, int(stats.get("mg_rain_high", 0)), _launch.bind(RAIN))
	_add_card("MG_STAR", "MG_STAR_DESC", 10, true, int(stats.get("mg_star_high", 0)), _launch.bind(STAR))
	_add_card("MG_RHYTHM", "MG_RHYTHM_DESC", 20, true, int(stats.get("mg_rhythm_high", 0)), _launch.bind(RHYTHM))


func _add_card(title_key: String, desc_key: String, cost: int, playable: bool, high: int, cb: Callable) -> void:
	var card := PanelContainer.new()
	var cs := UiFactory.panel()
	cs.bg_color = Palette.SURFACE_CONTAINER_HIGH
	card.add_theme_stylebox_override("panel", cs)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var t := Label.new()
	t.text = tr(title_key)
	t.add_theme_color_override("font_color", Palette.HORIZON_GLOW)
	var d := Label.new()
	d.text = tr(desc_key)
	d.add_theme_font_size_override("font_size", 12)
	d.add_theme_color_override("font_color", Palette.ON_SURFACE_VARIANT)
	var meta := Label.new()
	meta.add_theme_font_size_override("font_size", 11)
	meta.add_theme_color_override("font_color", Palette.STATUS_ENERGY)
	meta.text = "⚡%d   %s: %d" % [cost, tr("MG_HIGH"), high]
	info.add_child(t)
	info.add_child(d)
	info.add_child(meta)
	var btn := Button.new()
	if playable:
		btn.text = tr("MG_PLAY")
		btn.pressed.connect(cb)
	else:
		btn.text = tr("MG_LOCKED")
		btn.disabled = true
	row.add_child(info)
	row.add_child(btn)
	card.add_child(row)
	_list.add_child(card)


func _launch(scene: PackedScene) -> void:
	var g := scene.instantiate()
	add_child(g)
	g.connect("closed", func(): if is_instance_valid(g): g.queue_free(); _rebuild())
	g.call("start")  # enerji yetmezse oyun kendi "dinlenmeli" sonucunu gösterir
