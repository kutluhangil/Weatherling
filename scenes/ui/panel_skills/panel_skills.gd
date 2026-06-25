## Skill paneli — aktif yaşam evresinin dallarına göre filtreli. (Plan §9)
## Faz 7: kart listesi (organik pan/zoom haritası Faz 10 cilası).
extends Control

const SKILL_PATHS := [
	"res://data/skills/creativity_1.tres",
	"res://data/skills/play_1.tres",
	"res://data/skills/music_1.tres",
	"res://data/skills/career_1.tres",
	"res://data/skills/fitness_1.tres",
	"res://data/skills/wisdom_1.tres",
]

@onready var _list: VBoxContainer = $Panel/VBox/Scroll/List
@onready var _title: Label = $Panel/VBox/Title
@onready var _coins: Label = $Panel/VBox/Coins
@onready var _close: Button = $Panel/VBox/Close


func _ready() -> void:
	visible = false
	_title.text = tr("ACTION_SKILLS")
	_close.text = tr("CLOSE")
	_close.pressed.connect(close)
	$Dim.gui_input.connect(_on_dim_input)


func open() -> void:
	_rebuild()
	visible = true


func close() -> void:
	visible = false


func _rebuild() -> void:
	for c in _list.get_children():
		c.queue_free()
	_coins.text = "🪙 %d" % EconomyService.balance()
	var cfg := LifeStageService.current_config()
	var branches: Array = cfg.skill_branches if cfg != null else []
	for path in SKILL_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var node := load(path) as SkillNode
		if node == null:
			continue
		if not branches.is_empty() and not branches.has(node.branch):
			continue
		var b := Button.new()
		var unlocked := SkillService.is_unlocked(node.id)
		b.text = "%s — %d 🪙%s" % [tr(node.display_name_key), node.cost_coins, "  ✓" if unlocked else ""]
		b.disabled = unlocked
		b.pressed.connect(_on_skill_pressed.bind(node))
		_list.add_child(b)


func _on_skill_pressed(node: SkillNode) -> void:
	if SkillService.unlock(node):
		GameManager.save_now()
	_rebuild()


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
