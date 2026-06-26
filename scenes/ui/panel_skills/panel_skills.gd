## Skill paneli — görsel node-graph. (Plan §9) Mevcut .tres verisi + node-graph görseli.
## Kök "Temel Bağ" → evreye uygun skill dalları; kilitli/alınabilir/açık durumları.
extends Control

const SKILL_PATHS := [
	"res://data/skills/creativity_1.tres",
	"res://data/skills/play_1.tres",
	"res://data/skills/music_1.tres",
	"res://data/skills/career_1.tres",
	"res://data/skills/fitness_1.tres",
	"res://data/skills/wisdom_1.tres",
]
const GW := 330.0
const GH := 384.0
const NODE := 64.0

@onready var _graph: Control = $Panel/VBox/Graph
@onready var _title: Label = $Panel/VBox/Title
@onready var _coins: Label = $Panel/VBox/Coins
@onready var _close: Button = $Panel/VBox/Close


func _ready() -> void:
	visible = false
	_title.text = tr("ACTION_SKILLS")
	_close.text = tr("CLOSE")
	_close.pressed.connect(close)
	$Dim.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: close())


func open() -> void:
	_rebuild()
	visible = true


func close() -> void:
	visible = false


func _rebuild() -> void:
	for c in _graph.get_children():
		c.queue_free()
	_graph.clear_links()
	_coins.text = "🪙 %d" % EconomyService.balance()

	var root := Vector2(GW / 2.0, 46.0)
	_make_node(root, tr("SKILL_ROOT"), "unlocked", Callable())

	var cfg := LifeStageService.current_config()
	var branches: Array = cfg.skill_branches if cfg != null else []
	var i := 0
	for path in SKILL_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var node := load(path) as SkillNode
		if node == null:
			continue
		if not branches.is_empty() and not branches.has(node.branch):
			continue
		var col := i % 2
		var rown := i / 2
		var x := 80.0 if col == 0 else GW - 80.0
		var y := 150.0 + rown * 96.0
		var center := Vector2(x, y)
		var state := _state_for(node)
		_graph.add_link(root, center, state == "unlocked")
		_make_node(center, tr(node.display_name_key), state, _on_node.bind(node))
		i += 1


func _state_for(node: SkillNode) -> String:
	if SkillService.is_unlocked(node.id):
		return "unlocked"
	if EconomyService.can_afford(node.cost_coins):
		return "buy"
	return "locked"


func _make_node(center: Vector2, title: String, state: String, cb: Callable) -> void:
	var btn := Button.new()
	btn.size = Vector2(NODE, NODE)
	btn.position = center - Vector2(NODE / 2.0, NODE / 2.0)
	var s := StyleBoxFlat.new()
	s.set_corner_radius_all(999)
	s.set_border_width_all(4)
	match state:
		"unlocked":
			s.bg_color = Palette.PRIMARY_CONTAINER
			s.border_color = Palette.HORIZON_GLOW
			s.shadow_color = Palette.HORIZON_GLOW
			s.shadow_size = 8
		"buy":
			s.bg_color = Palette.SECONDARY_CONTAINER
			s.border_color = Palette.ON_SECONDARY_CONTAINER
		_:
			s.bg_color = Palette.SURFACE_CONTAINER_HIGH
			s.border_color = Palette.OUTLINE_VARIANT
			btn.icon = load("res://art/ui/icons/lock.svg")
			btn.expand_icon = true
			btn.disabled = true
	btn.add_theme_stylebox_override("normal", s)
	btn.add_theme_stylebox_override("hover", s)
	btn.add_theme_stylebox_override("pressed", s)
	btn.add_theme_stylebox_override("disabled", s)
	if cb.is_valid() and state == "buy":
		btn.pressed.connect(cb)
	_graph.add_child(btn)

	var lbl := Label.new()
	lbl.text = title
	lbl.size = Vector2(96, 0)
	lbl.position = center + Vector2(-48.0, NODE / 2.0 + 2.0)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Palette.ON_SURFACE_VARIANT)
	_graph.add_child(lbl)


func _on_node(node: SkillNode) -> void:
	if SkillService.unlock(node):
		GameManager.save_now()
	_rebuild()
