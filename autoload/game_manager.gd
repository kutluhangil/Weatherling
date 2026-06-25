## Oyun durumu sahibi + ana orkestratör. (Plan §3.3)
## En son yüklenen autoload — kayıttan durumu yükler/yeni oluşturur ve
## EventBus.state_loaded ile diğer servisleri (daha önce bağlanmış) besler.
extends Node

const AUTOSAVE_SECONDS := 60.0

var state: CreatureState = null

var _autosave: Timer


func _ready() -> void:
	Engine.max_fps = 60  # cozy/idle: 60 hedef, low_processor_mode boşta render durdurur (Plan §15)
	_load_or_new()
	_autosave = Timer.new()
	_autosave.wait_time = AUTOSAVE_SECONDS
	_autosave.timeout.connect(save_now)
	add_child(_autosave)
	_autosave.start()
	EventBus.save_requested.connect(save_now)


func current_state() -> CreatureState:
	return state


## Onboarding (Faz 5) bunu çağırır → durum oluştur, yay VE kaydet.
func new_game(creature_name: String = "Weatherling", age: int = 0, faith: String = "none") -> void:
	state = _build_state(creature_name, age, faith)
	EventBus.state_loaded.emit(state)
	save_now()


func _build_state(creature_name: String, age: int, faith: String) -> CreatureState:
	var s := CreatureState.new()
	s.creature_name = creature_name
	s.user_age = age
	s.faith = faith
	s.life_stage = LifeStageService.stage_for_age(age)
	s.birth_unix = int(Time.get_unix_time_from_system())
	s.last_seen_unix = s.birth_unix
	return s


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
		# Kayıt yok: bellekte geçici default (KAYDETME) → Boot onboarding'e yönlendirir.
		state = _build_state("Weatherling", 0, "none")
		EventBus.state_loaded.emit(state)


# Mobilde arka plana alınınca / kapanınca kaydet + pil tasarrufu (Plan §15).
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_PAUSED:
			save_now()
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			Engine.max_fps = 10   # arka planda/odak dışı: ısı + pil düşür
		NOTIFICATION_APPLICATION_FOCUS_IN:
			Engine.max_fps = 60
