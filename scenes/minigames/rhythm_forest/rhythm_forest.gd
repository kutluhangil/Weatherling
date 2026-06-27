## Ritim Ormanı — işaretçi merkeze gelince dokun. (Plan §6.2) Enerji harcar, ceza yok.
class_name RhythmForest
extends Control

signal closed

const DURATION := 30.0
const ENERGY_COST := 20.0
const BAR_W := 300.0
const TOL := 30.0

var _score := 0
var _time_left := 0.0
var _playing := false
var _hud: Label
var _pos := 0.0
var _dir := 1.0
var _speed := 0.7
var _flash := 0.0
var _flash_good := true


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Palette.SURFACE_CONTAINER
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_hud = Label.new()
	_hud.position = Vector2(20, 24)
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_theme_font_size_override("font_size", 18)
	_hud.add_theme_color_override("font_color", Palette.ON_SURFACE)
	add_child(_hud)
	var tip := Label.new()
	tip.text = tr("MG_RHYTHM_DESC")
	tip.position = Vector2(20, 52)
	tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tip.add_theme_font_size_override("font_size", 12)
	tip.add_theme_color_override("font_color", Palette.ON_SURFACE_VARIANT)
	add_child(tip)
	set_process(false)


func start() -> bool:
	if not NeedsService.spend_energy(ENERGY_COST):
		_show_result(tr("MG_ENERGY_LOW"))
		return false
	_score = 0
	_time_left = DURATION
	_pos = 0.0
	_dir = 1.0
	_speed = 0.7
	_playing = true
	set_process(true)
	return true


func _process(delta: float) -> void:
	if not _playing:
		return
	GameManager.request_active_frames(0.5)
	_time_left -= delta
	_hud.text = "%s: %d   ⏱ %d" % [tr("MG_SCORE"), _score, ceil(_time_left)]
	_pos += _dir * _speed * delta
	if _pos >= 1.0:
		_pos = 1.0
		_dir = -1.0
	elif _pos <= 0.0:
		_pos = 0.0
		_dir = 1.0
	if _flash > 0.0:
		_flash -= delta
	queue_redraw()
	if _time_left <= 0.0:
		_end()


func _draw() -> void:
	if not _playing:
		return
	var tl := (size.x - BAR_W) / 2.0
	var ty := size.y * 0.55
	draw_rect(Rect2(tl, ty - 4.0, BAR_W, 8.0), Palette.SURFACE_CONTAINER_LOWEST)
	var zone_col := Palette.SURFACE_CONTAINER_HIGH
	if _flash > 0.0:
		zone_col = Color(0.4, 0.85, 0.45) if _flash_good else Palette.STATUS_HUNGER
	var zx := tl + BAR_W / 2.0
	draw_rect(Rect2(zx - TOL, ty - 16.0, TOL * 2.0, 32.0), zone_col)
	var mx := tl + _pos * BAR_W
	draw_rect(Rect2(mx - 3.0, ty - 22.0, 6.0, 44.0), Palette.HORIZON_GLOW)


func _input(event: InputEvent) -> void:
	var hit: bool = (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventMouseButton and event.pressed)
	if hit and _playing:
		_try_hit()
		get_viewport().set_input_as_handled()


func _try_hit() -> void:
	if absf(_pos - 0.5) * BAR_W < TOL:
		_score += 1
		_flash_good = true
		_speed = minf(_speed + 0.04, 1.8)
	else:
		_flash_good = false
	_flash = 0.3


func _end() -> void:
	_playing = false
	set_process(false)
	var r := RainCatcher.rewards_for_score(_score)
	EconomyService.add_coins(r.coins)
	GameManager.grant_xp(r.xp)
	var s := GameManager.current_state()
	if s != null and _score > int(s.stats.get("mg_rhythm_high", 0)):
		s.stats["mg_rhythm_high"] = _score
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
