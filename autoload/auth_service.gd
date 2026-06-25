## Oturum yönetimi: guest / email / Google / Apple. (Plan §13)
## Backend: Supabase (anon key public, RLS ile korunur — istemcide sır yok).
## Faz 0: iskelet + durum makinesi. Gerçek akış Faz 8.
extends Node

# "guest" | "signed_in" | "signed_out"
var status := "guest"
var access_token := ""
var user_id := ""

# TODO(Faz 8): Supabase proje URL + anon key (public). Service-role ASLA istemcide.
const SUPABASE_URL := ""   # ör. https://<proj>.supabase.co
const SUPABASE_ANON := ""  # public anon key


func _ready() -> void:
	# Yerel-öncelik: token yoksa misafir başla.
	_set_status("guest")


func is_signed_in() -> bool:
	return status == "signed_in"


## Anında oyna — hesap yok, yerel kayıt. (Plan §13 MVP)
func sign_in_guest() -> void:
	_set_status("guest")


# --- Faz 8 iskeletleri ---------------------------------------------

func sign_in_email(_email: String, _password: String) -> void:
	pass  # TODO(Faz 8): Supabase auth REST → token → _set_status("signed_in")


func sign_in_google() -> void:
	pass  # TODO(Faz 8): OAuth + deep link (weatherling://auth-callback)


func sign_out() -> void:
	access_token = ""
	user_id = ""
	_set_status("signed_out")


## KVKK/GDPR: hesap + bulut + yerel veri sil.
func delete_account() -> void:
	pass  # TODO(Faz 8): Supabase satır sil + SaveService.delete_save()


func _set_status(s: String) -> void:
	status = s
	EventBus.auth_state_changed.emit(s)
