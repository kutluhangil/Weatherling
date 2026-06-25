## Ses: müzik (zaman/mood), ortam (havaya bağlı), SFX. (Plan §12)
## Faz 0: 3 player + Settings'ten ses seviyesi. Mood/hava seçimi & crossfade Faz 10.
extends Node

var music: AudioStreamPlayer
var ambient: AudioStreamPlayer
var sfx: AudioStreamPlayer


func _ready() -> void:
	music = _make_player()
	ambient = _make_player()
	sfx = _make_player()
	_apply_volumes()
	EventBus.settings_changed.connect(_on_settings_changed)


func play_music(stream_path: String, loop := true) -> void:
	_play_on(music, stream_path, loop)


func play_ambient(stream_path: String, loop := true) -> void:
	_play_on(ambient, stream_path, loop)


func play_sfx(stream_path: String) -> void:
	_play_on(sfx, stream_path, false)


func _play_on(player: AudioStreamPlayer, path: String, loop: bool) -> void:
	if not ResourceLoader.exists(path):
		return
	var stream := load(path)
	if stream is AudioStream:
		if "loop" in stream:  # .ogg gibi loop bayrağı olan akışlar
			stream.set("loop", loop)
		player.stream = stream
		player.play()


func _make_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	add_child(p)
	return p


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
