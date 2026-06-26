## Hava Avcısı — düşen taneleri yakala. (Plan §6.2) Enerji harcar, 0'da ceza yok.
## Ödül: coin + bond XP, high-score stats'a. Kod-tabanlı (sürüm-bağımsız).
class_name RainCatcher
extends Control

signal closed

const DURATION := 30.0
const ENERGY_COST := 15.0
const DROP_TEX := "res://art/particles/raindrop.svg"
const SPAWN_MIN := 0.35
const SPAWN_MAX := 0.8
const FALL_SPEED := 320.0

var _score := 0
var _time_left := 0.0
var _spawn_t := 0.0
var _playing := false
var _drops: Array[TextureRect] = []
var _hud: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Palette.SURFACE
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


## Skor → ödül. (Saf — test edilir.)
static func rewards_for_score(score: int) -> Dictionary:
	return {"coins": score, "xp": int(ceil(score * 0.5))}


## Enerji yetiyorsa başlat. Yetmiyorsa false (dinlenmeli, ceza yok).
func start() -> bool:
	if not NeedsService.spend_energy(ENERGY_COST):
		_show_result(tr("MG_ENERGY_LOW"))
		return false
	_score = 0
	_time_left = DURATION
	_spawn_t = 0.0
	_playing = true
	set_process(true)
	return true


func _process(delta: float) -> void:
	if not _playing:
		return
	_time_left -= delta
	_hud.text = "%s: %d   ⏱ %d" % [tr("MG_SCORE"), _score, ceil(_time_left)]
	_spawn_t -= delta
	if _spawn_t <= 0.0:
		_spawn()
		_spawn_t = randf_range(SPAWN_MIN, SPAWN_MAX)
	for d in _drops.duplicate():
		d.position.y += FALL_SPEED * delta
		if d.position.y > size.y + 40.0:
			_drops.erase(d)
			d.queue_free()
	if _time_left <= 0.0:
		_end()


func _spawn() -> void:
	var d := TextureRect.new()
	if ResourceLoader.exists(DROP_TEX):
		d.texture = load(DROP_TEX)
	d.custom_minimum_size = Vector2(44, 44)
	d.size = Vector2(44, 44)
	d.position = Vector2(randf_range(20.0, maxf(40.0, size.x - 60.0)), -44.0)
	d.modulate = Palette.STATUS_ENERGY
	d.mouse_filter = Control.MOUSE_FILTER_STOP
	d.gui_input.connect(_on_drop_input.bind(d))
	add_child(d)
	_drops.append(d)


func _on_drop_input(event: InputEvent, d: TextureRect) -> void:
	var hit: bool = (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventMouseButton and event.pressed)
	if hit and _playing:
		_score += 1
		_drops.erase(d)
		d.queue_free()


func _end() -> void:
	_playing = false
	set_process(false)
	for d in _drops:
		d.queue_free()
	_drops.clear()
	var r := rewards_for_score(_score)
	EconomyService.add_coins(r.coins)
	GameManager.grant_xp(r.xp)
	_save_highscore(_score)
	_show_result("%s\n%s: %d\n🪙 +%d    XP +%d" % [tr("MG_DONE"), tr("MG_SCORE"), _score, r.coins, r.xp])


func _save_highscore(score: int) -> void:
	var s := GameManager.current_state()
	if s == null:
		return
	if score > int(s.stats.get("mg_rain_high", 0)):
		s.stats["mg_rain_high"] = score


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
