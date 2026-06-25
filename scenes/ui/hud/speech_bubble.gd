## Ruh hali baloncuğu — mood değişince kısa, sevimli bir cümle gösterir. (Plan §6.6)
extends PanelContainer

@onready var label: Label = $Label

var _idle_timer: Timer


func _ready() -> void:
	modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	EventBus.mood_changed.connect(_on_mood_changed)
	_idle_timer = Timer.new()
	_idle_timer.one_shot = true
	_idle_timer.timeout.connect(_idle_line)
	add_child(_idle_timer)
	_schedule_idle()


func _schedule_idle() -> void:
	_idle_timer.wait_time = randf_range(25.0, 45.0)
	_idle_timer.start()


## Evreye özel idle diyalogu (varsa) — gece sus.
func _idle_line() -> void:
	if TimeService.get_phase() != "night":
		var cfg := LifeStageService.current_config()
		if cfg != null and not cfg.idle_dialogue_keys.is_empty():
			say(tr(cfg.idle_dialogue_keys.pick_random()))
	_schedule_idle()


func _on_mood_changed(mood: String) -> void:
	say(tr("MOOD_" + mood.to_upper()))


func say(text: String) -> void:
	label.text = text
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.2)
	t.tween_interval(2.4)
	t.tween_property(self, "modulate:a", 0.0, 0.4)
