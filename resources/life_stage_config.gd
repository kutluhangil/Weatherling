## Bir yaşam evresinin tüm ayarlanabilir parametreleri (data-driven).
## Plan §5.2 + §7. Her evre `data/life_stages/<id>.tres` olarak yaşar;
## hiçbir sayı koda gömülmez — hepsi buradan gelir.
class_name LifeStageConfig
extends Resource

# --- Kimlik ---------------------------------------------------------
@export var id: String = ""                       # "filiz"
@export var display_name_key: String = ""         # i18n anahtarı
@export var min_age: int = 0
@export var max_age: int = 999

# --- Görsel ---------------------------------------------------------
@export var sprite_set: String = ""               # art/creature/<id>/
@export var palette: String = ""                  # renk teması
@export var personality_traits: Array[String] = []

# --- İhtiyaç davranışı (birim/saat) --------------------------------
@export var hunger_decay_rate: float = 4.0
@export var energy_decay_rate: float = 3.0
@export var hygiene_decay_rate: float = 2.0
@export var happiness_decay_rate: float = 2.0
@export var social_decay_rate: float = 2.0
@export var sleep_hours: Vector2 = Vector2(22, 7)  # tipik uyku penceresi (lokal saat)
@export var nap_count: int = 0                     # gündüz şekerleme sayısı

# --- Yemek ----------------------------------------------------------
@export var preferred_foods: Array[String] = []
@export var disliked_foods: Array[String] = []
@export var eating_style_key: String = ""          # animasyon/diyalog stili

# --- Aktivite & skill ----------------------------------------------
@export var activity_keys: Array[String] = []      # "play","study","work","garden"...
@export var skill_branches: Array[String] = []     # bu evrede açık skill dalları
@export var special_events: Array[String] = []     # bu evreye özel olay id'leri

# --- Diyalog --------------------------------------------------------
@export var idle_dialogue_keys: Array[String] = [] # ruh hali baloncukları
@export var request_keys: Array[String] = []       # "ister" diyalogları


## Verilen yaş bu evreye giriyor mu?
func contains_age(age: int) -> bool:
	return age >= min_age and age <= max_age
