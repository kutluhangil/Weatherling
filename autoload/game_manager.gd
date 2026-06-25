## Oyun durumu sahibi + ana orkestratör. (Plan §3.3)
## En son yüklenen autoload — kayıttan durumu yükler/yeni oluşturur ve
## EventBus.state_loaded ile diğer servisleri (daha önce bağlanmış) besler.
extends Node

const AUTOSAVE_SECONDS := 60.0

var state: CreatureState = null

var _autosave: Timer


func _ready() -> void:
	_load_or_new()
	_autosave = Timer.new()
	_autosave.wait_time = AUTOSAVE_SECONDS
	_autosave.timeout.connect(save_now)
	add_child(_autosave)
	_autosave.start()
	EventBus.save_requested.connect(save_now)


func current_state() -> CreatureState:
	return state


## Onboarding (Faz 5) bunu çağırır. Faz 0: makul varsayılanlarla yeni durum.
func new_game(creature_name: String = "Weatherling", age: int = 0, faith: String = "none") -> void:
	state = CreatureState.new()
	state.creature_name = creature_name
	state.user_age = age
	state.faith = faith
	state.life_stage = LifeStageService.stage_for_age(age)
	state.birth_unix = int(Time.get_unix_time_from_system())
	state.last_seen_unix = state.birth_unix
	EventBus.state_loaded.emit(state)
	save_now()


func save_now() -> void:
	if state == null:
		return
	state.last_seen_unix = int(Time.get_unix_time_from_system())
	SaveService.save_state(state)


func _load_or_new() -> void:
	var loaded := SaveService.load_state()
	if loaded != null:
		state = loaded
		EventBus.state_loaded.emit(state)
	else:
		new_game()


# Mobilde arka plana alınınca / kapanınca kaydet (Plan §15).
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_PAUSED:
			save_now()
