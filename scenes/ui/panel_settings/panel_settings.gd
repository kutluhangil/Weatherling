## Ayarlar — ses, erişilebilirlik, bildirim, dil, konum. (Plan §10.4)
## Form kodda üretilir (sürüm-bağımsız). Değerler Settings'e yazılır, anında uygulanır.
extends Control

@onready var _form: VBoxContainer = $Panel/VBox/Scroll/Form
@onready var _title: Label = $Panel/VBox/Title
@onready var _close: Button = $Panel/VBox/Close


func _ready() -> void:
	visible = false
	_title.text = tr("SETTINGS")
	_close.text = tr("CLOSE")
	_close.pressed.connect(close)
	$Dim.gui_input.connect(_on_dim_input)
	_build()


func open() -> void:
	visible = true


func close() -> void:
	visible = false


func _build() -> void:
	_header("SET_AUDIO")
	_slider("audio/master", "SET_MASTER")
	_slider("audio/music", "SET_MUSIC")
	_slider("audio/ambient", "SET_AMBIENT")
	_slider("audio/sfx", "SET_SFX")

	_header("SET_A11Y")
	_check("a11y/reduced_motion", "SET_REDUCED")

	_header("SET_NOTIFS")
	_notif_check("needs", "NOTIF_CAT_NEEDS")
	_notif_check("weather", "NOTIF_CAT_WEATHER")
	_notif_check("daily", "NOTIF_CAT_DAILY")

	_header("SET_GENERAL")
	_lang_row()
	_loc_row()


func _header(key: String) -> void:
	var l := Label.new()
	l.text = tr(key)
	l.add_theme_font_size_override("font_size", 14)
	l.modulate = Color(0.7, 0.78, 0.95)
	_form.add_child(l)


func _slider(setting_key: String, label_key: String) -> void:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = tr(label_key)
	l.custom_minimum_size = Vector2(110, 0)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.custom_minimum_size = Vector2(150, 0)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.value = float(Settings.get_value(setting_key))
	s.value_changed.connect(func(v): Settings.set_value(setting_key, v))
	row.add_child(l)
	row.add_child(s)
	_form.add_child(row)


func _check(setting_key: String, label_key: String) -> void:
	var c := CheckButton.new()
	c.text = tr(label_key)
	c.button_pressed = bool(Settings.get_value(setting_key))
	c.toggled.connect(func(on): Settings.set_value(setting_key, on))
	_form.add_child(c)


func _notif_check(category: String, label_key: String) -> void:
	var c := CheckButton.new()
	c.text = tr(label_key)
	c.button_pressed = NotificationService.is_enabled(category)
	c.toggled.connect(func(on): NotificationService.set_enabled(category, on))
	_form.add_child(c)


func _lang_row() -> void:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = tr("SET_LANGUAGE")
	l.custom_minimum_size = Vector2(110, 0)
	var o := OptionButton.new()
	o.add_item("Türkçe")
	o.add_item("English")
	o.selected = 0 if Localization.current_locale().begins_with("tr") else 1
	o.item_selected.connect(func(i): Localization.set_locale("tr" if i == 0 else "en"))
	row.add_child(l)
	row.add_child(o)
	_form.add_child(row)


func _loc_row() -> void:
	var modes := ["auto", "manual", "off"]
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = tr("SET_LOCATION")
	l.custom_minimum_size = Vector2(110, 0)
	var o := OptionButton.new()
	o.add_item(tr("LOC_AUTO"))
	o.add_item(tr("LOC_MANUAL"))
	o.add_item(tr("LOC_OFF"))
	o.selected = modes.find(str(Settings.get_value("general/location_mode")))
	o.item_selected.connect(func(i): Settings.set_value("general/location_mode", modes[i]))
	row.add_child(l)
	row.add_child(o)
	_form.add_child(row)


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
