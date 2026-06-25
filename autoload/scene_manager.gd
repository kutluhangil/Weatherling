## Yumuşak geçişli sahne yükleme. (Plan Faz 0)
## Tam ekran karartma overlay'i ile fade-out → sahne değiştir → fade-in.
extends Node

var _layer: CanvasLayer
var _rect: ColorRect


func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 128  # her şeyin üstünde
	add_child(_layer)
	_rect = ColorRect.new()
	_rect.color = Color(0.105882, 0.117647, 0.180392, 0.0)
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_rect)


func change_scene(path: String, dur: float = 0.35) -> void:
	EventBus.scene_change_started.emit(path)
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP  # geçişte girdiyi engelle
	var t := create_tween()
	t.tween_property(_rect, "color:a", 1.0, dur)
	await t.finished

	get_tree().change_scene_to_file(path)
	await get_tree().process_frame

	var t2 := create_tween()
	t2.tween_property(_rect, "color:a", 0.0, dur)
	await t2.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	EventBus.scene_change_finished.emit(path)
