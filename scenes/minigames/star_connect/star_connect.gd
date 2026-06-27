## Yıldız Birleştirme — beliren yıldızlara dokun, takımyıldızı çiz. (Plan §6.2)
## Enerji harcar (0'da ceza yok). Ödül RainCatcher.rewards_for_score ile ortak.
class_name StarConnect
extends Control

signal closed

const DURATION := 30.0
const ENERGY_COST := 10.0
const STAR_TEX := "res://art/ui/icons/star.svg"
const SPAWN_MIN := 0.5
const SPAWN_MAX := 0.95
const STAR_LIFE := 2.4

var _score := 0
var _time_left := 0.0
var _spawn_t := 0.0
var _playing := false
var _hud: Label
var _points: PackedVector2Array = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Palette.DEEP_PLUM
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_hud = Label.new()
	_hud.position = Vector2(20, 24)
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_theme_font_size_override("font_size", 18)
	_hud.add_theme_color_override("font_color", Palette.ON_SURFACE)
	add_child(_hud)
	set_process(false)


func start() -> bool:
	if not NeedsService.spend_energy(ENERGY_COST):
		_show_result(tr("MG_ENERGY_LOW"))
		return false
	_score = 0
	_time_left = DURATION
	_spawn_t = 0.0
	_points = []
	_playing = true
	set_process(true)
	return true


func _process(delta: float) -> void:
	if not _playing:
		return
	GameManager.request_active_frames(0.5)
	_time_left -= delta
	_hud.text = "%s: %d   ⏱ %d" % [tr("MG_SCORE"), _score, ceil(_time_left)]
	_spawn_t -= delta
	if _spawn_t <= 0.0:
		_spawn()
		_spawn_t = randf_range(SPAWN_MIN, SPAWN_MAX)
	if _time_left <= 0.0:
		_end()


func _draw() -> void:
	if _points.size() >= 2:
		draw_polyline(_points, Palette.HORIZON_GLOW, 2.0, true)


func _spawn() -> void:
	var star := TextureRect.new()
	if ResourceLoader.exists(STAR_TEX):
		star.texture = load(STAR_TEX)
	star.custom_minimum_size = Vector2(40, 40)
	star.size = Vector2(40, 40)
	star.position = Vector2(randf_range(20.0, maxf(40.0, size.x - 60.0)), randf_range(80.0, maxf(120.0, size.y - 120.0)))
	star.modulate = Palette.HORIZON_GLOW
	star.mouse_filter = Control.MOUSE_FILTER_STOP
	star.gui_input.connect(_on_star_input.bind(star))
	add_child(star)
	var tw := star.create_tween()
	tw.tween_property(star, "modulate:a", 0.0, STAR_LIFE)
	tw.tween_callback(func(): if is_instance_valid(star): star.queue_free())


func _on_star_input(event: InputEvent, star: TextureRect) -> void:
	var hit: bool = (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventMouseButton and event.pressed)
	if hit and _playing and is_instance_valid(star):
		_score += 1
		_points.append(star.position + Vector2(20, 20))
		queue_redraw()
		star.queue_free()


func _end() -> void:
	_playing = false
	set_process(false)
	var r := RainCatcher.rewards_for_score(_score)
	EconomyService.add_coins(r.coins)
	GameManager.grant_xp(r.xp)
	var s := GameManager.current_state()
	if s != null and _score > int(s.stats.get("mg_star_high", 0)):
		s.stats["mg_star_high"] = _score
	_show_result("%s\n%s: %d\n🪙 +%d    XP +%d" % [tr("MG_DONE"), tr("MG_SCORE"), _score, r.coins, r.xp])


func _show_result(msg: String) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiFactory.panel())
	panel.set_anchors_preset(Control.PRESET_CENTER)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	var lbl := Label.new()
	lbl.text = msg
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Palette.ON_SURFACE)
	var btn := Button.new()
	btn.text = tr("CLOSE")
	btn.pressed.connect(func(): closed.emit(); queue_free())
	vb.add_child(lbl)
	vb.add_child(btn)
	panel.add_child(vb)
	add_child(panel)
