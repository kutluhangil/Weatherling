## İhtiyaçlar & bakım — Tamagotchi çekirdeği. (Plan §6.4, §6.6 Mood)
## ÖLÜM YOK: ihtiyaçlar 0'a inse de yaratık "küser", bakımla tam geri kazanılır.
## Offline geriye-dönük hesap TABAN korumalı. Saf decay/mood matematiği GUT-testlik.
extends Node

const FLOOR := 15.0                # offline azalma bu tabanın altına itmez
const TICK_SECONDS := 60.0

# LifeStageService gelene kadar (Faz 5) makul varsayılan hızlar (birim/saat).
const DEFAULT_RATES := {
	"hunger": 4.0, "energy": 3.0, "hygiene": 2.0,
	"happiness": 2.0, "social": 2.0,
}

var _state: CreatureState = null
var _timer: Timer
var _last_mood := ""


func _ready() -> void:
	EventBus.state_loaded.connect(_on_state_loaded)
	_timer = Timer.new()
	_timer.wait_time = TICK_SECONDS
	_timer.timeout.connect(_on_tick)
	add_child(_timer)


func start_decay() -> void:
	if _timer.is_stopped():
		_timer.start()


func stop_decay() -> void:
	_timer.stop()


# --- Saf matematik (test edilebilir) -------------------------------

static func decayed(value: float, rate_per_hour: float, elapsed_sec: float, apply_floor: bool) -> float:
	var drop := rate_per_hour * (elapsed_sec / 3600.0)
	var result := value - drop
	if apply_floor:
		result = maxf(result, minf(value, FLOOR))
	return clampf(result, 0.0, 100.0)


func _rates() -> Dictionary:
	var cfg := LifeStageService.current_config()
	if cfg != null:
		return {
			"hunger": cfg.hunger_decay_rate, "energy": cfg.energy_decay_rate,
			"hygiene": cfg.hygiene_decay_rate, "happiness": cfg.happiness_decay_rate,
			"social": cfg.social_decay_rate,
		}
	return DEFAULT_RATES


# --- Offline catch-up ----------------------------------------------

func _on_state_loaded(state: Resource) -> void:
	_state = state
	_apply_offline_catchup()
	start_decay()
	_update_mood()


func _apply_offline_catchup() -> void:
	if _state == null or _state.last_seen_unix <= 0:
		_touch_last_seen()
		return
	var elapsed := float(Time.get_unix_time_from_system() - _state.last_seen_unix)
	if elapsed <= 0:
		return
	var rates := _rates()
	for key in rates:
		_state.set_need(key, decayed(_state.get_need(key), rates[key], elapsed, true))
	_touch_last_seen()
	EventBus.needs_recalculated.emit()


# --- Canlı decay ----------------------------------------------------

func _on_tick() -> void:
	if _state == null:
		return
	var rates := _rates()
	for key in rates:
		var before: float = _state.get_need(key)
		var after := decayed(before, rates[key], TICK_SECONDS, false)
		if after != before:
			_state.set_need(key, after)
			EventBus.need_changed.emit(key, after)
	_touch_last_seen()
	_update_mood()


# --- Bakım eylemleri (Plan §6.4) -----------------------------------

## Mini-oyun enerji harcaması. Yeterli enerji yoksa false (oynatma — ama CEZA yok,
## yalnızca "dinlenmeli"). 0'a inse de ölüm yok. (Plan §6.2, cozy)
func spend_energy(amount: float) -> bool:
	if _state == null:
		return false
	if _state.get_need("energy") < amount:
		return false
	_state.set_need("energy", _state.get_need("energy") - amount)
	EventBus.need_changed.emit("energy", _state.get_need("energy"))
	return true


func apply_care(kind: String, amount: float = 25.0) -> void:
	if _state == null:
		return
	match kind:
		"feed":
			_bump("hunger", amount)
			_bump("happiness", 5.0)
		"sleep":
			_bump("energy", amount)
		"play":
			_bump("happiness", amount)
			_bump("energy", -10.0)
		"clean":
			_bump("hygiene", amount)
		"pet":
			_bump("happiness", amount * 0.5)
			_bump("social", 10.0)
	EventBus.creature_interacted.emit(kind)
	_gain_bond(2)
	_update_mood()


## Bir yemek item'ı ye — yaşam evresi tercihine göre etki ölçeklenir. (Plan §6.5)
func feed(food: FoodItem) -> void:
	if _state == null or food == null:
		return
	var like := 1.0
	var cfg := LifeStageService.current_config()
	if cfg != null:
		if _matches(food, cfg.preferred_foods):
			like = 1.25
		elif _matches(food, cfg.disliked_foods):
			like = 0.6
	_bump("hunger", food.hunger_restore * like)
	_bump("happiness", food.happiness_delta * like)
	_bump("health", food.health_delta)
	_bump("energy", food.energy_delta)
	EventBus.creature_interacted.emit("feed")
	_gain_bond(2)
	_update_mood()


func _matches(food: FoodItem, list: Array) -> bool:
	if food.id in list:
		return true
	for t in food.tags:
		if t in list:
			return true
	return false


func _bump(key: String, delta: float) -> void:
	var v := clampf(_state.get_need(key) + delta, 0.0, 100.0)
	_state.set_need(key, v)
	EventBus.need_changed.emit(key, v)


func _gain_bond(xp: int) -> void:
	_state.bond_xp += xp
	EventBus.bond_xp_gained.emit(xp)


func _touch_last_seen() -> void:
	if _state != null:
		_state.last_seen_unix = int(Time.get_unix_time_from_system())


# --- Ruh hali (Plan §6.6) ------------------------------------------

## İhtiyaç + hava + zaman bileşimi → ruh hali. (Saf — GUT ile test edilir.)
func compute_mood() -> String:
	if _state == null:
		return "content"
	if TimeService.get_phase() == "night":
		return "sleepy"
	match WeatherService.temperature_mood():
		"cold":
			return "cold"
		"hot":
			return "hot"
	if _state.hunger < 25.0:
		return "hungry"
	if _state.energy < 25.0:
		return "sleepy"
	if _state.social < 25.0:
		return "lonely"
	if _state.hygiene < 25.0:
		return "grumpy"
	if _state.happiness >= 70.0 and _state.hunger >= 50.0:
		return "joyful"
	return "content"


func _update_mood() -> void:
	var mood := compute_mood()
	if mood != _last_mood:
		_last_mood = mood
		EventBus.mood_changed.emit(mood)
