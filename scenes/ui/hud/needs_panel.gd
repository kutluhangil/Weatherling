## İhtiyaç barları (üst sol). 6 ihtiyaç, canlı güncellenir. (Plan §10.2)
## Satırlar kodda üretilir — sürüm-bağımsız, sade.
extends VBoxContainer

const KEYS := ["hunger", "energy", "hygiene", "happiness", "health", "social"]
const LABEL_KEYS := {
	"hunger": "NEED_HUNGER", "energy": "NEED_ENERGY", "hygiene": "NEED_HYGIENE",
	"happiness": "NEED_HAPPINESS", "health": "NEED_HEALTH", "social": "NEED_SOCIAL",
}
const ICONS := {
	"hunger": "res://art/ui/icons/status/food_icon.png",
	"energy": "res://art/ui/icons/status/energy_icon.png",
	"hygiene": "res://art/ui/icons/status/water_icon.png",
	"happiness": "res://art/ui/icons/status/sun_icon.png",
	"health": "res://art/vfx/creature/heart.png",
	"social": "res://art/ui/icons/status/age_icon.png",
}

var _bars := {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 4)
	for k in KEYS:
		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var tex := TextureRect.new()
		tex.texture = load(ICONS[k]) if ResourceLoader.exists(ICONS[k]) else null
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.custom_minimum_size = Vector2(16, 16)
		row.add_child(tex)
		
		var lbl := Label.new()
		lbl.text = tr(LABEL_KEYS[k])
		lbl.custom_minimum_size = Vector2(52, 0)
		lbl.add_theme_color_override("font_color", Palette.ON_SURFACE_VARIANT)
		lbl.add_theme_font_size_override("font_size", 12)
		var bar := ProgressBar.new()
		bar.min_value = 0.0
		bar.max_value = 100.0
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(96, 12)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Pixel-Prime: ihtiyaca özel renk + koyu track.
		bar.add_theme_stylebox_override("background", UiFactory.bar_track())
		bar.add_theme_stylebox_override("fill", UiFactory.bar_fill(Palette.need_color(k)))
		row.add_child(lbl)
		row.add_child(bar)
		add_child(row)
		_bars[k] = bar
	EventBus.need_changed.connect(_on_need_changed)
	EventBus.needs_recalculated.connect(_refresh_all)
	EventBus.state_loaded.connect(func(_s): _refresh_all())
	_refresh_all()


func _on_need_changed(key: String, value: float) -> void:
	if _bars.has(key):
		_bars[key].value = value


func _refresh_all() -> void:
	var s: CreatureState = GameManager.current_state()
	if s == null:
		return
	for k in KEYS:
		_bars[k].value = s.get_need(k)
