## Local-first şifreli kayıt. (Plan §5 local-first, §16 güvenlik)
## Yerel: AES ile şifreli binary (tip-güvenli). Bulut sync (Supabase, last-write-wins)
## Faz 8'de buraya bağlanır; serileştirme dict olduğu için JSON'a da çevrilebilir.
extends Node

const PATH := "user://creature.save"

## TODO(Faz 11): Bu sabit yerine cihaz/Android Keystore türevli anahtar kullan.
## Yerel dosya şifrelemesi için geçici; istemciye gömülü "sır" değil (RLS'li sunucu sırrı yok).
const _PASS := "weatherling_local_v1"

## CreatureState üzerinde serileştirilecek alanlar (migrasyon-dostu açık liste).
const PROPS := [
	"creature_name", "user_age", "life_stage", "faith", "birth_unix",
	"bond_level", "bond_xp",
	"hunger", "energy", "hygiene", "happiness", "health", "social",
	"coins", "inventory", "unlocked_skills", "equipped_cosmetics", "home_decor",
	"last_seen_unix", "stats", "settings", "version",
]

var _cloud: HTTPRequest
var _cloud_mode := ""


func _ready() -> void:
	_cloud = HTTPRequest.new()
	add_child(_cloud)
	_cloud.request_completed.connect(_on_cloud_completed)
	EventBus.auth_state_changed.connect(_on_auth_changed)


func has_save() -> bool:
	return FileAccess.file_exists(PATH)


func save_state(state: CreatureState) -> bool:
	var data := _to_dict(state)
	var f := FileAccess.open_encrypted_with_pass(PATH, FileAccess.WRITE, _PASS)
	if f == null:
		push_error("SaveService: write açılamadı (%s)" % FileAccess.get_open_error())
		return false
	f.store_var(data, false)
	f.close()
	EventBus.save_completed.emit()
	return true


func load_state() -> CreatureState:
	if not has_save():
		return null
	var f := FileAccess.open_encrypted_with_pass(PATH, FileAccess.READ, _PASS)
	if f == null:
		push_error("SaveService: read açılamadı (%s)" % FileAccess.get_open_error())
		return null
	var data: Variant = f.get_var(false)
	f.close()
	if typeof(data) != TYPE_DICTIONARY:
		return null
	return _from_dict(data)


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


func _from_dict(d: Dictionary) -> CreatureState:
	var state := CreatureState.new()
	for p in PROPS:
		if not d.has(p):
			continue
		if p == "unlocked_skills":
			# typed Array[String]'i elle yeniden kur (binary tip ipucunu kaybeder)
			var skills: Array[String] = []
			for s in d[p]:
				skills.append(str(s))
			state.unlocked_skills = skills
		else:
			state.set(p, d[p])
	# TODO(şema migrasyonu): state.version < CURRENT ise alanları yükselt.
	return state


func _to_dict(state: CreatureState) -> Dictionary:
	var data := {}
	for p in PROPS:
		data[p] = state.get(p)
	return data


# --- Bulut sync (Supabase, local-first, last-write-wins). (Plan §5, §13) ---

func _on_auth_changed(s: String) -> void:
	if s == "signed_in":
		pull_cloud()


func push_cloud() -> void:
	var state := GameManager.current_state()
	if state == null or not AuthService.is_signed_in() or not AuthService.is_configured() or not _cloud_idle():
		return
	var row := {
		"user_id": AuthService.user_id,
		"state": _to_dict(state),
		"schema_version": state.version,
		"updated_at": _now_iso(),
	}
	var headers := AuthService.auth_headers()
	headers.append("Prefer: resolution=merge-duplicates,return=minimal")
	_cloud_mode = "push"
	EventBus.sync_started.emit()
	_cloud.request(AuthService.rest_base() + "creature_saves", headers, HTTPClient.METHOD_POST, JSON.stringify([row]))


func pull_cloud() -> void:
	if not AuthService.is_signed_in() or not AuthService.is_configured() or not _cloud_idle():
		return
	_cloud_mode = "pull"
	EventBus.sync_started.emit()
	var url := AuthService.rest_base() + "creature_saves?user_id=eq." + AuthService.user_id + "&select=state,updated_at,schema_version"
	_cloud.request(url, AuthService.auth_headers(), HTTPClient.METHOD_GET)


func _on_cloud_completed(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	var ok := result == HTTPRequest.RESULT_SUCCESS and code < 300
	if _cloud_mode == "pull":
		_handle_pull(result, code, body)
	_cloud_mode = ""
	EventBus.sync_completed.emit(ok)


func _handle_pull(result: int, code: int, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code >= 300:
		return
	var json: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) != TYPE_ARRAY or json.is_empty():
		push_cloud()  # bulutta yok → yereli yükle
		return
	var row: Dictionary = json[0]
	var cloud_unix := int(Time.get_unix_time_from_datetime_string(str(row.get("updated_at", ""))))
	var local := GameManager.current_state()
	if local != null and cloud_unix > local.last_seen_unix and typeof(row.get("state")) == TYPE_DICTIONARY:
		var cs := _from_dict(row.state)
		GameManager.state = cs
		EventBus.state_loaded.emit(cs)
		save_state(cs)
	else:
		push_cloud()  # yerel daha yeni → buluta it


## Kullanıcı kaydını JSON olarak dışa aktarır (KVKK/GDPR). (Plan §13)
func export_json() -> String:
	var state := GameManager.current_state()
	if state == null:
		return ""
	var path := "user://weatherling_export.json"
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return ""
	f.store_string(JSON.stringify(_to_dict(state), "\t"))
	f.close()
	return ProjectSettings.globalize_path(path)


func _cloud_idle() -> bool:
	return _cloud.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED


func _now_iso() -> String:
	return Time.get_datetime_string_from_system(true)
