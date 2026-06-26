## Başarımlar & koleksiyon paneli. (Plan §22) Cezasız ilerleme listesi.
## AchievementService.ALL_IDS üzerinden kilitli/açık satırlar + hava koleksiyonu özeti.
extends Control

@onready var _list: VBoxContainer = $Panel/VBox/Scroll/List
@onready var _title: Label = $Panel/VBox/Title
@onready var _progress: Label = $Panel/VBox/Progress
@onready var _weather: Label = $Panel/VBox/Weather
@onready var _close: Button = $Panel/VBox/Close


func _ready() -> void:
	visible = false
	_title.text = tr("ACH_TITLE")
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
	var ids: Array = AchievementService.ALL_IDS
	_progress.text = tr("ACH_PROGRESS") % [AchievementService.unlocked_count(), ids.size()]
	_weather.text = tr("ACH_WEATHER_SEEN") % AchievementService.weather_collection().size()
	for id in ids:
		var unlocked: bool = AchievementService.is_unlocked(id)
		var row := Label.new()
		row.text = "%s  %s" % ["✓" if unlocked else "🔒", tr("ACH_" + id)]
		if not unlocked:
			row.modulate = Color(1, 1, 1, 0.45)
		_list.add_child(row)


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
