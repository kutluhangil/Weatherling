## Ses: müzik (zaman/mood), ortam (havaya bağlı), SFX. (Plan §12)
## Faz 10: zaman/hava'ya göre parça seçimi + yumuşak fade + SFX wiring.
## Ses dosyaları (.ogg) kullanıcı tarafından audio/ altına eklenir; yoksa sessizce no-op.
extends Node

const MUSIC := {
	"dawn": "res://audio/music/dawn.ogg",
	"day": "res://audio/music/day.ogg",
	"dusk": "res://audio/music/dusk.ogg",
	"night": "res://audio/music/night.ogg",
	"rain": "res://audio/music/rain.ogg",
}
const AMBIENT := {
	"rain": "res://audio/ambient/rain.ogg",
	"wind": "res://audio/ambient/wind.ogg",
	"night": "res://audio/ambient/night.ogg",
	"clear": "res://audio/ambient/birds.ogg",
}
const SFX := {
	"feed": "res://audio/sfx/feed.ogg",
	"pet": "res://audio/sfx/pet.ogg",
	"play": "res://audio/sfx/play.ogg",
	"clean": "res://audio/sfx/clean.ogg",
	"sleep": "res://audio/sfx/sleep.ogg",
	"purchase": "res://audio/sfx/purchase.ogg",
}

var music: AudioStreamPlayer
var ambient: AudioStreamPlayer
var sfx: AudioStreamPlayer

var _music_key := ""
var _ambient_key := ""


func _ready() -> void:
	music = _make_player()
	ambient = _make_player()
	sfx = _make_player()
	_apply_volumes()
	EventBus.settings_changed.connect(_on_settings_changed)
	EventBus.time_phase_changed.connect(func(_p): _update_scene_audio())
	EventBus.weather_changed.connect(func(_s, _t, _d): _update_scene_audio())
	EventBus.creature_interacted.connect(func(kind): play_sfx_key(kind))
	EventBus.item_purchased.connect(func(_id): play_sfx_key("purchase"))
	_update_scene_audio()


# --- Zaman/hava'ya göre seçim ---------------------------------------

func _update_scene_audio() -> void:
	var mkey := _pick_music()
	if mkey != _music_key:
		_music_key = mkey
		_play_stream(music, MUSIC.get(mkey, ""), true)
	var akey := _pick_ambient()
	if akey != _ambient_key:
		_ambient_key = akey
		_play_stream(ambient, AMBIENT.get(akey, ""), true)


func _pick_music() -> String:
	var ws := WeatherService.WeatherState
	if WeatherService.state == ws.RAIN or WeatherService.state == ws.THUNDER:
		return "rain"
	return TimeService.get_phase()


func _pick_ambient() -> String:
	var ws := WeatherService.WeatherState
	if WeatherService.state == ws.RAIN or WeatherService.state == ws.THUNDER:
		return "rain"
	if WeatherService.state == ws.WINDY:
		return "wind"
	if TimeService.get_phase() == "night":
		return "night"
	return "clear"


# --- Çalma -----------------------------------------------------------

func play_music(stream_path: String, loop := true) -> void:
	_play_stream(music, stream_path, loop)


func play_ambient(stream_path: String, loop := true) -> void:
	_play_stream(ambient, stream_path, loop)


func play_sfx(stream_path: String) -> void:
	_play_stream(sfx, stream_path, false)


func play_sfx_key(key: String) -> void:
	play_sfx(SFX.get(key, ""))


func _play_stream(player: AudioStreamPlayer, path: String, loop: bool) -> void:
	if path == "" or not ResourceLoader.exists(path):
		return
	var stream := load(path)
	if stream is AudioStream:
		if "loop" in stream:
			stream.set("loop", loop)
		player.stream = stream
		player.play()


func _make_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	add_child(p)
	return p


# --- Ses seviyesi ---------------------------------------------------

func _apply_volumes() -> void:
	var master: float = Settings.get_value("audio/master")
	music.volume_db = _to_db(master * float(Settings.get_value("audio/music")))
	ambient.volume_db = _to_db(master * float(Settings.get_value("audio/ambient")))
	sfx.volume_db = _to_db(master * float(Settings.get_value("audio/sfx")))


func _to_db(linear: float) -> float:
	return -80.0 if linear <= 0.001 else linear_to_db(linear)


func _on_settings_changed(key: String, _value: Variant) -> void:
	if key.begins_with("audio/"):
		_apply_volumes()
