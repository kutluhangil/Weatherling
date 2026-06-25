## Skill ağacı düğümü (data-driven). Plan §9.
## data/skills/<id>.tres. Dallar yaşam evresine göre filtrelenir.
class_name SkillNode
extends Resource

@export var id: String = ""
@export var display_name_key: String = ""
@export var description_key: String = ""
@export var icon: Texture2D

# Konum / dal --------------------------------------------------------
@export var branch: String = ""               # "creativity","career","wisdom"...
@export var visible_in_stages: Array[String] = []  # boşsa: tüm evreler
@export var prerequisites: Array[String] = []      # önce açılması gereken node id'leri

# Maliyet ------------------------------------------------------------
@export var cost_coins: int = 0
@export var cost_bond_xp: int = 0

# Ödül (açtığı içerik) ----------------------------------------------
@export var unlocks: Dictionary = {}          # {"dialogue":[...],"decor":[...],"buff":{...}}


func is_visible_in(stage_id: String) -> bool:
	return visible_in_stages.is_empty() or visible_in_stages.has(stage_id)
