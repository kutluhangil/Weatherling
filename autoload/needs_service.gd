## İhtiyaçlar & bakım — Tamagotchi çekirdeği. (Plan §6.4)
## ÖLÜM YOK: ihtiyaçlar 0'a inse de yaratık "küser", bakımla tam geri kazanılır.
## Offline geriye-dönük hesap TABAN korumalı (8 saat yoksun → yarı-ölü bulmasın).
## Faz 0: saf decay/offline matematiği hazır (GUT testlik). Canlı döngü Faz 4'te açılır.
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


func _ready() -> void:
	EventBus.state_loaded.connect(_on_state_loaded)
	_timer = Timer.new()
	_timer.wait_time = TICK_SECONDS
	_timer.timeout.connect(_on_tick)
	add_child(_timer)
	# Canlı decay Faz 4'te start_decay() ile açılır.


func start_decay() -> void:
	if not _timer.is_stopped():
		return
	_timer.start()


func stop_decay() -> void:
	_timer.stop()


# --- Saf matematik (test edilebilir) -------------------------------

## Tek bir ihtiyacın belli süre sonraki değeri. Offline'da floor korur,
## aktif decay'de (live=false→floor uygulanır; live=true→0'a kadar düşebilir).
static func decayed(value: float, rate_per_hour: float, elapsed_sec: float, apply_floor: bool) -> float:
	var drop := rate_per_hour * (elapsed_sec / 3600.0)
	var result := value - drop
	if apply_floor:
		result = maxf(result, minf(value, FLOOR))
	return clampf(result, 0.0, 100.0)


func _rates() -> Dictionary:
	# Faz 5: LifeStageService.current_config() hızlarını döndürür.
	var cfg = LifeStageService.current_config()
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


# --- Bakım eylemleri (Plan §6.4) -----------------------------------

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
