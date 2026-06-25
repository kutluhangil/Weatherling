## Skill ağacı + bond/affinity. (Plan §9) Süreklilik sütununun motoru.
## Faz 0: bond xp→level eğrisi (saf) + unlock iskeleti. Skill tree UI Faz 7.
extends Node

## Eşik tablosu: level N'e ulaşmak için gereken toplam bond_xp.
const LEVEL_THRESHOLDS := [0, 50, 120, 220, 360, 550, 800, 1120, 1520, 2000]

var _state: CreatureState = null


func _ready() -> void:
	EventBus.state_loaded.connect(_on_state_loaded)
	EventBus.bond_xp_gained.connect(_on_bond_xp_gained)


## Toplam xp → bond level. (Saf — GUT ile test edilir.)
static func level_for_xp(xp: int) -> int:
	var level := 1
	for i in LEVEL_THRESHOLDS.size():
		if xp >= LEVEL_THRESHOLDS[i]:
			level = i + 1
	return level


func is_unlocked(skill_id: String) -> bool:
	return _state != null and _state.unlocked_skills.has(skill_id)


## Faz 7: ön koşul + maliyet kontrolü. İskelet.
func unlock(node: SkillNode) -> bool:
	if _state == null or is_unlocked(node.id):
		return false
	for pre in node.prerequisites:
		if not is_unlocked(pre):
			return false
	if not EconomyService.spend_coins(node.cost_coins):
		return false
	_state.unlocked_skills.append(node.id)
	EventBus.skill_unlocked.emit(node.id)
	return true


func _on_state_loaded(state: Resource) -> void:
	_state = state


func _on_bond_xp_gained(_amount: int) -> void:
	if _state == null:
		return
	var new_level := level_for_xp(_state.bond_xp)
	if new_level > _state.bond_level:
		_state.bond_level = new_level
		EventBus.bond_level_up.emit(new_level)
