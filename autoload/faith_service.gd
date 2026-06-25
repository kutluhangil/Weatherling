## İnanç / gelenek katmanı — opsiyonel, saygılı, yargısız. (Plan §8)
## SAYGI İLKELERİ: ibadet ödül kasması DEĞİL; eşlik opsiyonel, eşlik etmemenin
## cezası YOK; kullanıcı her an değiştirip kapatabilir.
## Faz 0: iskelet. Vakit hesabı (Aladhan + yerel) ve ritüel zamanlayıcı Faz 6.
extends Node

const PROFILE_DIR := "res://data/faiths/"

var current_faith := "none"
var _profile: FaithProfile = null


func _ready() -> void:
	EventBus.state_loaded.connect(func(s): set_faith(s.faith))


func set_faith(faith_id: String) -> void:
	current_faith = faith_id if faith_id != "" else "none"
	_profile = _load_profile(current_faith)
	# TODO(Faz 6): mevcut ritüel zamanlayıcılarını iptal et, yeni geleneğe göre kur.


func profile() -> FaithProfile:
	return _profile


## Faz 6: rhythm_type'a göre bir sonraki ritüel zamanını hesapla, zamanı gelince
## EventBus.devotion_time(current_faith, ritual) yay. İslam için namaz vakitleri
## Aladhan API veya cihazda yerel hesapla (çevrimdışı yedek).
func _schedule_next_ritual() -> void:
	pass


func _load_profile(faith_id: String) -> FaithProfile:
	var path := PROFILE_DIR + faith_id + ".tres"
	if not ResourceLoader.exists(path):
		return null
	return load(path) as FaithProfile
