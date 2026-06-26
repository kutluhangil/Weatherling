## Oturum yönetimi: guest / email / magic link / Google. (Plan §13)
## Supabase Auth (GoTrue REST). anon key public, RLS korur — istemcide gizli sır yok.
## SUPABASE_URL boşken: is_configured()=false → tüm bulut işlemleri no-op, oyun saf yerel.
extends Node

const SESSION_PATH := "user://session.dat"

# TODO(Faz 8 provision): Supabase projenden doldur (ikisi de public, RLS korur).
const SUPABASE_URL := ""    # ör. https://xxxx.supabase.co
const SUPABASE_ANON := ""   # public anon key

var status := "guest"       # "guest" | "signed_in" | "signed_out"
var access_token := ""
var refresh_token := ""
var user_id := ""
var email := ""

var _http: HTTPRequest
var _pending: Callable


func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_completed)
	_load_session()


func is_configured() -> bool:
	return SUPABASE_URL != "" and SUPABASE_ANON != ""


func is_signed_in() -> bool:
	return status == "signed_in" and access_token != ""


func rest_base() -> String:
	return SUPABASE_URL + "/rest/v1/"


func auth_headers() -> PackedStringArray:
	return PackedStringArray([
		"apikey: " + SUPABASE_ANON,
		"Authorization: Bearer " + access_token,
		"Content-Type: application/json",
	])


# --- Akışlar ---------------------------------------------------------

func sign_in_guest() -> void:
	_set_status("guest")


func sign_up_email(addr: String, password: String) -> void:
	_auth_post("/auth/v1/signup", {"email": addr, "password": password})


func sign_in_email(addr: String, password: String) -> void:
	_auth_post("/auth/v1/token?grant_type=password", {"email": addr, "password": password})


func send_magic_link(addr: String) -> void:
	_auth_post("/auth/v1/otp", {"email": addr, "create_user": true})


func sign_out() -> void:
	access_token = ""
	refresh_token = ""
	user_id = ""
	email = ""
	_delete_session()
	_set_status("signed_out")


## Google ile giriş: sistem tarayıcısı + deep link (weatherling://auth-callback).
func sign_in_google() -> void:
	if not is_configured():
		EventBus.auth_state_changed.emit("error_unconfigured")
		return
	# TODO(Faz 8): OS.shell_open(authorize_url) → deep link callback → token takası.
	# Deep link Android App Link kurulumu gerekir (docs/SUPABASE.md).


## Hesap silme (KVKK/GDPR): bulut RPC + yerel veri. (Plan §13)
func delete_account() -> void:
	if is_signed_in() and is_configured() and _idle():
		_pending = func(_r, _c, _b): pass
		_http.request(rest_base() + "rpc/delete_me", auth_headers(), HTTPClient.METHOD_POST, "{}")
	SaveService.delete_save()
	sign_out()


# --- İç REST ---------------------------------------------------------

func _auth_post(path: String, body: Dictionary) -> void:
	if not is_configured():
		EventBus.auth_state_changed.emit("error_unconfigured")
		return
	if not _idle():
		return
	var headers := PackedStringArray(["apikey: " + SUPABASE_ANON, "Content-Type: application/json"])
	_pending = _on_auth_response
	EventBus.sync_started.emit()
	var err := _http.request(SUPABASE_URL + path, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		EventBus.auth_state_changed.emit("error_network")


func _on_completed(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	if _pending.is_valid():
		var cb := _pending
		_pending = Callable()
		cb.call(result, code, body)


func _on_auth_response(result: int, code: int, body: PackedByteArray) -> void:
	var json: Variant = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS or code >= 400 or typeof(json) != TYPE_DICTIONARY:
		EventBus.auth_state_changed.emit("error_auth")
		return
	if json.has("access_token"):
		access_token = str(json.access_token)
		refresh_token = str(json.get("refresh_token", ""))
		var u: Variant = json.get("user", {})
		if typeof(u) == TYPE_DICTIONARY:
			user_id = str(u.get("id", ""))
			email = str(u.get("email", ""))
		_save_session()
		_set_status("signed_in")
	else:
		EventBus.auth_state_changed.emit("check_email")  # magic link / doğrulama gönderildi


func _idle() -> bool:
	return _http.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED


func _set_status(s: String) -> void:
	status = s
	EventBus.auth_state_changed.emit(s)


# --- Oturum kalıcılığı ----------------------------------------------
# Token'lar artık cihaz türevli anahtarla ŞİFRELİ saklanır (SaveService.device_pass).
# Eski sürüm düz binary yazdı; _load_session bunu algılayıp şifreliye taşır.
# TODO(Faz 11+): Android Keystore köprüsü ile donanım-destekli saklama.

func _save_session() -> void:
	var f := FileAccess.open_encrypted_with_pass(SESSION_PATH, FileAccess.WRITE, SaveService.device_pass())
	if f != null:
		f.store_var({"at": access_token, "rt": refresh_token, "uid": user_id, "email": email}, false)
		f.close()


func _load_session() -> void:
	if not FileAccess.file_exists(SESSION_PATH):
		return
	# Önce şifreli (cihaz anahtarı); başarısızsa eski düz binary (migrasyon).
	var migrated := false
	var f := FileAccess.open_encrypted_with_pass(SESSION_PATH, FileAccess.READ, SaveService.device_pass())
	if f == null:
		f = FileAccess.open(SESSION_PATH, FileAccess.READ)
		migrated = true
	if f == null:
		return
	var d: Variant = f.get_var(false)
	f.close()
	if typeof(d) == TYPE_DICTIONARY and str(d.get("at", "")) != "":
		access_token = str(d.at)
		refresh_token = str(d.get("rt", ""))
		user_id = str(d.get("uid", ""))
		email = str(d.get("email", ""))
		if migrated:
			_save_session()  # şifreli formata taşı
		_set_status("signed_in")


func _delete_session() -> void:
	if FileAccess.file_exists(SESSION_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SESSION_PATH))
