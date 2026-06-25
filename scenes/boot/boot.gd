## Açılış: kısa splash → oturum/kayıt durumuna göre yönlendir. (Plan §10.2)
## Faz 0: onboarding sahnesi henüz yok → her zaman Home'a geç.
## Faz 5: kayıt yoksa Onboarding'e, varsa Home'a yönlendirilecek.
extends Control


func _ready() -> void:
	await get_tree().create_timer(0.6).timeout
	if SaveService.has_save():
		SceneManager.change_scene("res://scenes/home/home.tscn")
	else:
		SceneManager.change_scene("res://scenes/onboarding/onboarding.tscn")
