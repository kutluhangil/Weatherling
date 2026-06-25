## Kullanıcı yaşı → yaşam evresi konfigürasyonu (data-driven). (Plan §5.2, §7)
## Faz 0: yaş→evre eşlemesi (saf, test edilebilir) hazır.
## .tres konfigleri Faz 5'te data/life_stages/ içine gelir; yoksa null döner (zarif).
extends Node

const CONFIG_DIR := "res://data/life_stages/"

## Plan §7 yaş→evre tablosu. (min_age, id)
const STAGE_TABLE := [
	[75, "cinar"], [60, "kok"], [45, "hasat"], [30, "meyve"],
	[18, "cicek"], [13, "tomurcuk"], [0, "filiz"],
]

var _current_id := ""
var _current_config: LifeStageConfig = null


func _ready() -> void:
	EventBus.state_loaded.connect(_on_state_loaded)


## Yaş → evre id. (Saf — GUT ile test edilir.)
static func stage_for_age(age: int) -> String:
	for row in STAGE_TABLE:
		if age >= row[0]:
			return row[1]
	return "filiz"


func current_id() -> String:
	return _current_id


## Aktif evrenin konfigi. Faz 5'ten önce .tres yoksa null.
func current_config() -> LifeStageConfig:
	return _current_config


func set_stage(stage_id: String) -> void:
	if stage_id == _current_id:
		return
	_current_id = stage_id
	_current_config = _load_config(stage_id)


func _on_state_loaded(state: Resource) -> void:
	var cs := state as CreatureState
	if cs == null:
		return
	var id := cs.life_stage if cs.life_stage != "" else stage_for_age(cs.user_age)
	set_stage(id)


func _load_config(stage_id: String) -> LifeStageConfig:
	var path := CONFIG_DIR + stage_id + ".tres"
	if not ResourceLoader.exists(path):
		return null
	var res := load(path)
	return res as LifeStageConfig
