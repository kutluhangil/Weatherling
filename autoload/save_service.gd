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


func has_save() -> bool:
	return FileAccess.file_exists(PATH)


func save_state(state: CreatureState) -> bool:
	var data := {}
	for p in PROPS:
		data[p] = state.get(p)
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
