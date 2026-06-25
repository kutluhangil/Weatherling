## Coin ekonomisi. (Plan §6.8) Tek para birimi, pay-to-win yok.
## Faz 0: temel coin işlemleri hazır; shop akışı Faz 7.
extends Node

var _state: CreatureState = null


func _ready() -> void:
	EventBus.state_loaded.connect(func(s): _state = s)
	# Kazanç kaynakları (pay-to-win yok, nazik birikim). (Plan §6.8)
	EventBus.creature_interacted.connect(func(_k): add_coins(1))
	EventBus.bond_level_up.connect(func(lvl): add_coins(lvl * 10))


func balance() -> int:
	return _state.coins if _state != null else 0


func can_afford(amount: int) -> bool:
	return _state != null and _state.coins >= amount


func add_coins(amount: int) -> void:
	if _state == null or amount <= 0:
		return
	_state.coins += amount
	EventBus.coins_changed.emit(_state.coins)


func spend_coins(amount: int) -> bool:
	if not can_afford(amount):
		return false
	_state.coins -= amount
	EventBus.coins_changed.emit(_state.coins)
	return true
