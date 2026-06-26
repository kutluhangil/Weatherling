## Font yükleyici — kullanıcı .ttf'leri art/fonts/ altına atınca otomatik uygula.
## Dosya yoksa Godot default font'a düşer (build/çalışma bloke olmaz). (Pixel-Prime §2.2)
## Beklenen adlar: SpaceGrotesk.ttf (display), HankenGrotesk.ttf (body), JetBrainsMono.ttf (label).
extends Node

const DISPLAY := "res://art/fonts/SpaceGrotesk.ttf"
const BODY := "res://art/fonts/HankenGrotesk.ttf"
const MONO := "res://art/fonts/JetBrainsMono.ttf"


func _ready() -> void:
	# Global varsayılan = gövde fontu (en çok metin). Yoksa display, o da yoksa default.
	var base := _load(BODY)
	if base == null:
		base = _load(DISPLAY)
	if base != null:
		ThemeDB.fallback_font = base


func _load(path: String) -> Font:
	return load(path) if ResourceLoader.exists(path) else null


func display_font() -> Font:
	return _load(DISPLAY)


func body_font() -> Font:
	return _load(BODY)


func mono_font() -> Font:
	return _load(MONO)


func has_fonts() -> bool:
	return ResourceLoader.exists(DISPLAY) or ResourceLoader.exists(BODY)
