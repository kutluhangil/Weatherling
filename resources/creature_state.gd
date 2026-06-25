## Kalıcı yaratık durumu — yerel şifreli kayıt ve bulut sync'in tek kaynağı.
## Plan §5.1. Şema değişince `version` artırılır ve SaveService migrasyon uygular.
class_name CreatureState
extends Resource

# --- Kimlik ---------------------------------------------------------
@export var creature_name: String = ""        # kullanıcının verdiği isim
@export var user_age: int = 0                  # onboarding'de girilen yaş
@export var life_stage: String = ""           # "filiz","tomurcuk",... (Plan §7)
@export var faith: String = "none"            # "islam","christianity",... | "none"
@export var birth_unix: int = 0               # yaratığın doğuşu (epoch)

# --- Bağ / ilerleme -------------------------------------------------
@export var bond_level: int = 1
@export var bond_xp: int = 0

# --- İhtiyaçlar (0–100) --------------------------------------------
@export var hunger: float = 80.0
@export var energy: float = 80.0
@export var hygiene: float = 80.0
@export var happiness: float = 80.0
@export var health: float = 100.0
@export var social: float = 70.0

# --- Ekonomi / koleksiyon ------------------------------------------
@export var coins: int = 0
@export var inventory: Dictionary = {}          # item_id -> adet
@export var unlocked_skills: Array[String] = []
@export var equipped_cosmetics: Dictionary = {} # slot -> item_id
@export var home_decor: Dictionary = {}

# --- Zaman / istatistik / tercih -----------------------------------
@export var last_seen_unix: int = 0             # offline hesaplama için
@export var stats: Dictionary = {}              # gün sayısı, görülen hava türleri...
@export var settings: Dictionary = {}           # kullanıcı tercihleri (Settings ile)
@export var version: int = 1                    # şema migrasyonu


## İhtiyaçları tek tek değil isimle okumak/yazmak için yardımcılar —
## NeedsService döngülerini sadeleştirir.
const NEED_KEYS := ["hunger", "energy", "hygiene", "happiness", "health", "social"]

func get_need(key: String) -> float:
	return get(key)

func set_need(key: String, value: float) -> void:
	set(key, clampf(value, 0.0, 100.0))
