## Sürüklenebilir oda eşyası — dokunmatik + fare. (Plan §6.3 serbest drag)
## _input kullanır (gui_input değil) → hızlı sürüklemede imleç kontrolden çıksa bile yakalar.
extends Control

signal moved(id: String, pos: Vector2)

var id := ""
var _drag := false


func setup(item_id: String, tex: Texture2D) -> void:
	id = item_id
	custom_minimum_size = Vector2(64, 64)
	size = Vector2(64, 64)
	mouse_filter = Control.MOUSE_FILTER_STOP
	if tex != null:
		var t := TextureRect.new()
		t.set_anchors_preset(Control.PRESET_FULL_RECT)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t.texture = tex
		add_child(t)
	else:
		# Asset yoksa renkli kutu + baş harf (drag yine çalışır).
		var box := ColorRect.new()
		box.set_anchors_preset(Control.PRESET_FULL_RECT)
		box.color = Palette.SECONDARY_CONTAINER
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(box)
		var lbl := Label.new()
		lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		lbl.text = item_id.substr(0, 1).to_upper()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.add_theme_color_override("font_color", Palette.ON_SECONDARY_CONTAINER)
		add_child(lbl)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed and not _drag and get_global_rect().has_point(event.position):
			_drag = true
			move_to_front()
			get_viewport().set_input_as_handled()
		elif not event.pressed and _drag:
			_drag = false
			moved.emit(id, position)
			get_viewport().set_input_as_handled()
	elif _drag and (event is InputEventScreenDrag or event is InputEventMouseMotion):
		position += event.relative
		get_viewport().set_input_as_handled()
