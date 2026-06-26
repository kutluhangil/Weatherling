## Günlük paneli — yaratığın günlük hava/anı notları, en yeni başta. (Plan §22)
extends Control

# WeatherState (int) → emoji. (CLEAR0..WINDY6)
const EMOJI := ["☀️", "☁️", "🌫️", "🌧️", "❄️", "⛈️", "🍃"]

@onready var _list: VBoxContainer = $Panel/VBox/Scroll/List
@onready var _title: Label = $Panel/VBox/Title
@onready var _count: Label = $Panel/VBox/Count
@onready var _close: Button = $Panel/VBox/Close


func _ready() -> void:
	visible = false
	_title.text = tr("JOURNAL_TITLE")
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
	var e: Array = JournalService.entries()
	_count.text = tr("JOURNAL_COUNT") % e.size()
	if e.is_empty():
		var empty := Label.new()
		empty.text = tr("JOURNAL_EMPTY")
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_list.add_child(empty)
		return
	for entry in e:
		var w := int(entry.get("weather", 0))
		var emoji: String = EMOJI[w] if w >= 0 and w < EMOJI.size() else "·"
		var row := Label.new()
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.text = "%s  %s %.0f°C\n%s" % [
			str(entry.get("date", "")), emoji,
			float(entry.get("temp", 0.0)), tr(str(entry.get("note_key", ""))),
		]
		_list.add_child(row)


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
