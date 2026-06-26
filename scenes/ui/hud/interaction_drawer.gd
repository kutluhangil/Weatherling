## Etkileşim drawer (FAB açar). Besle/Oyna/Uyut/Temizle + ikincil ihtiyaç barları.
## Cooldown YOK (cozy). Besle → panel_feed'i açtırmak için sinyal yayar. (Plan §5.2)
extends Control

signal feed_pressed

const SECONDARY := ["hygiene", "health", "social"]
const SEC_LABELS := {"hygiene": "NEED_HYGIENE", "health": "NEED_HEALTH", "social": "NEED_SOCIAL"}
const ICONS := {
	"feed": "res://art/ui/icons/feed.svg", "play": "res://art/ui/icons/play.svg",
	"sleep": "res://art/ui/icons/sleep.svg", "clean": "res://art/ui/icons/clean.svg",
}

@onready var _dim: ColorRect = $Dim
@onready var _sheet: PanelContainer = $Sheet
@onready var _title: Label = $Sheet/VBox/Title
@onready var _feed: Button = $Sheet/VBox/Grid/Feed
@onready var _play: Button = $Sheet/VBox/Grid/Play
@onready var _sleep: Button = $Sheet/VBox/Grid/Sleep
@onready var _clean: Button = $Sheet/VBox/Grid/Clean
@onready var _secondary: VBoxContainer = $Sheet/VBox/Secondary
@onready var _close: Button = $Sheet/VBox/Close

var _bars := {}


func _ready() -> void:
	visible = false
	_sheet.add_theme_stylebox_override("panel", UiFactory.panel())
	_title.text = tr("INTERACT_TITLE")
	_close.text = tr("CLOSE")
	_feed.icon = load(ICONS.feed)
	_play.icon = load(ICONS.play)
	_sleep.icon = load(ICONS.sleep)
	_clean.icon = load(ICONS.clean)
	_feed.pressed.connect(func(): feed_pressed.emit(); close())
	_play.pressed.connect(_care.bind("play"))
	_sleep.pressed.connect(_care.bind("sleep"))
	_clean.pressed.connect(_care.bind("clean"))
	_close.pressed.connect(close)
	_dim.gui_input.connect(_on_dim_input)
	_build_secondary()
	_localize()
	EventBus.locale_changed.connect(func(_l): _localize())
	EventBus.need_changed.connect(func(k, v): if _bars.has(k): _bars[k].value = v)


func _localize() -> void:
	_title.text = tr("INTERACT_TITLE")
	_feed.text = tr("ACTION_FEED")
	_play.text = tr("ACTION_PLAY")
	_sleep.text = tr("ACTION_SLEEP")
	_clean.text = tr("ACTION_CLEAN")
	_close.text = tr("CLOSE")


func _build_secondary() -> void:
	for k in SECONDARY:
		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = tr(SEC_LABELS[k])
		lbl.custom_minimum_size = Vector2(72, 0)
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Palette.ON_SURFACE_VARIANT)
		var bar := ProgressBar.new()
		bar.min_value = 0.0
		bar.max_value = 100.0
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(120, 12)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.add_theme_stylebox_override("background", UiFactory.bar_track())
		bar.add_theme_stylebox_override("fill", UiFactory.bar_fill(Palette.need_color(k)))
		row.add_child(lbl)
		row.add_child(bar)
		_secondary.add_child(row)
		_bars[k] = bar


func open() -> void:
	_refresh()
	visible = true


func close() -> void:
	visible = false


func _care(kind: String) -> void:
	NeedsService.apply_care(kind)
	_refresh()  # açık kalır, tekrar dokunulabilir


func _refresh() -> void:
	var s: CreatureState = GameManager.current_state()
	if s == null:
		return
	for k in SECONDARY:
		_bars[k].value = s.get_need(k)


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
