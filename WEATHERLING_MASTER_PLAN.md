# Weatherling — Master Build Plan

> **Tür:** Cozy virtual-pet / yaşam yoldaşı (Tamagotchi'den ilhamlı, ama kendine özgü)
> **Motor:** Godot 4.7 (stable) · **Dil:** GDScript
> **Hedef:** Önce Android / Google Play → sonra iOS / App Store
> **Konsept:** Senin gerçek hava durumunda, gerçek saatinde ve mevsiminde yaşayan minik bir piksel yaratık.
> **Amaç:** Bu dosya Claude Code (VS Code) ile **faz faz** inşa edilecek tek kaynak doğruluk belgesidir.

Bu döküman bir "yap-bitir" listesi değil; her sistemin *neden* öyle tasarlandığını, *hangi opsiyonların* elendiğini ve *tam olarak ne inşa edileceğini* anlatan bir mühendislik planıdır. Her fazın sonunda net bir "Definition of Done" var.

---

## İçindekiler

1. [Vizyon ve Ürün Felsefesi](#1-vizyon-ve-ürün-felsefesi)
2. [Temel Sütunlar (Design Pillars)](#2-temel-sütunlar)
3. [Teknik Mimari](#3-teknik-mimari)
4. [Klasör Yapısı](#4-klasör-yapısı)
5. [Veri Modelleri](#5-veri-modelleri)
6. [Sistemler — Detaylı](#6-sistemler--detaylı)
7. [Yaşam Evreleri — Her Yaş İçin Kurgu](#7-yaşam-evreleri--her-yaş-için-kurgu)
8. [İnanç / Gelenek Sistemi](#8-inanç--gelenek-sistemi)
9. [Skill Ağacı ve Gelişim](#9-skill-ağacı-ve-gelişim)
10. [UI / UX Tasarımı](#10-ui--ux-tasarımı)
11. [Animasyon ve Görsel Sistem](#11-animasyon-ve-görsel-sistem)
12. [Ses Tasarımı](#12-ses-tasarımı)
13. [Kimlik Doğrulama ve Bulut Kayıt](#13-kimlik-doğrulama-ve-bulut-kayıt)
14. [Bildirimler](#14-bildirimler)
15. [Performans Optimizasyonu](#15-performans-optimizasyonu)
16. [Güvenlik ve Gizlilik](#16-güvenlik-ve-gizlilik)
17. [Play Store Hazırlığı ve Yayın](#17-play-store-hazırlığı-ve-yayın)
18. [iOS Hazırlığı (Gelecek)](#18-ios-hazırlığı-gelecek)
19. [Geliştirme Yol Haritası — Fazlar](#19-geliştirme-yol-haritası--fazlar)
20. [Git / Repo Konvansiyonları](#20-git--repo-konvansiyonları)
21. [Test Stratejisi](#21-test-stratejisi)
22. [Ek Özellik Fikirleri](#22-ek-özellik-fikirleri)
23. [Senin Onayını Bekleyen Açık Kararlar](#23-senin-onayını-bekleyen-açık-kararlar)

---

## 1. Vizyon ve Ürün Felsefesi

Weatherling bir "oyun mu, uygulama mı?" sorusunun cevabı: **ikisi de değil, bir _yoldaş_ (companion).** Sürekli oynanan bir oyun değil; günde birkaç kez bakılan, içine girince huzur veren, "yaşayan" bir cep dünyası. Genre tanımı: **ambient / idle cozy life-sim.**

Temel duygusal kanca: **gerçek hayatınla senkron.** Pencereden dışarı baktığında yağmur yağıyorsa, yaratığın da yağmurun altında. Senin gecende o uyuyor. Senin mevsiminde onun dünyası da o mevsimde. Bu "aynalanma" oyunu sıradan bir Tamagotchi klonundan ayırır.

İkinci kanca: **yaratık senin yaşını yansıtır.** 8 yaşındaki bir çocuk girdiğinde minik, yaramaz, oyuncu bir yaratık; 65 yaşında biri girdiğinde dingin, bilge, çay seven bir yaratık. Her yaş kendi hikâyesini, ihtiyaçlarını ve ritmini getirir. Bu, kullanıcının kendini yaratıkta görmesini sağlar — empati ve bağ kurar.

Üçüncü kanca: **opsiyonel inanç/gelenek katmanı.** Yaratığın kendi nazik manevi hayatı vardır ve bu, kullanıcının seçtiği geleneği yansıtır. Zorlama yok, oyunlaştırma istismarı yok; sadece sıcaklık.

### Ne DEĞİL
- ❌ Pay-to-win, agresif reklam, dark pattern. (Cozy ruhuna aykırı.)
- ❌ Yüksek tempo, stres, "kaybetme" korkusu. Yaratık ihmal edilse bile *ölmez* — sadece üzülür ve geri kazanılabilir. (Tamagotchi'nin ölüm mekaniği modern cozy oyunlarda travmatiktir; biz "hüzünlenir ama affeder" modeli kullanırız.)
- ❌ Claude/AI parmak izi taşıyan kod, commit veya meta veri. Bu **senin** ürünün.

---

## 2. Temel Sütunlar

| # | Sütun | Açıklama | Tasarım sonucu |
|---|-------|----------|----------------|
| 1 | **Gerçeklik aynası** | Hava, saat, mevsim, ay evresi gerçek ve konuma bağlı | WeatherService + TimeService + SeasonService |
| 2 | **Yaşam evresi empatisi** | Yaratık kullanıcının yaşını yansıtır | LifeStageService + data-driven evre konfigleri |
| 3 | **Şefkatli bakım** | Besle, uyut, oyna, temizle — ceza değil, ilişki | NeedsService (ölüm yok, geri kazanılabilir) |
| 4 | **Dinginlik** | Sakin tempo, lo-fi ses, yumuşak animasyon | low_processor_usage_mode, reduced-motion seçeneği |
| 5 | **Süreklilik** | Bağ seviyesi, skill ağacı, koleksiyonlar zamanla büyür | BondSystem + SkillTree + Achievements |
| 6 | **Saygı ve kapsayıcılık** | İnanç opsiyonel, kültürel olarak doğru, yargısız | FaithService + hassasiyet ilkeleri |

Her özellik eklenmeden önce sorulacak soru: *"Bu, altı sütundan hangisine hizmet ediyor? Hiçbirine etmiyorsa neden ekliyoruz?"*

---

## 3. Teknik Mimari

### 3.1 Motor ve render seçimi

- **Godot 4.7 stable** (18 Haziran 2026'da çıktı; en güncel kararlı sürüm). 4.7 çok yeniyse ve erken-sürüm hatası yaşarsan **4.6.x** olgun bir yedektir; proje 4.6 ↔ 4.7 arasında taşınabilir kalmalı (deneysel API'lerden kaçın).
- **Renderer: `Compatibility` (OpenGL ES 3.0 / WebGL2 tabanlı).** Gerekçe: 2D piksel sanatı için fazlasıyla yeterli, **en geniş Android cihaz desteği** ve **en düşük pil/ısı** sağlar. Vulkan tabanlı `Mobile` renderer'ına 2D cozy bir oyun için ihtiyaç yok ve eski/ucuz cihazlarda sorun çıkarabilir.
- `.NET` (C#) sürümü **değil**, standart GDScript sürümü. (Hafiflik + Android export kolaylığı.)

### 3.2 Mimari deseni

**Autoload (singleton) + sinyal tabanlı, data-driven.** Sistemler birbirini doğrudan çağırmaz; sinyallerle haberleşir. Bu, test edilebilirlik ve gevşek bağlılık (loose coupling) sağlar.

```
                    ┌─────────────────────────────────────────┐
                    │              GameManager                  │
                    │  (oyun döngüsü, durum, kaydetme tetikler) │
                    └───────────────┬───────────────────────────┘
                                    │ signals
   ┌──────────────┬─────────────┬──┴───────────┬──────────────┬──────────────┐
   ▼              ▼             ▼               ▼              ▼              ▼
TimeService  WeatherService  NeedsService  LifeStage      FaithService   AudioManager
(saat/gün-   (Open-Meteo,    (açlık,enerji  Service        (vakitler,     (ortam,müzik,
 gece,mevsim, konum,cache)   ,mutluluk...)  (yaş→evre      ritüeller)     SFX)
 ay evresi)                                  konfigi)
   │              │             │               │              │
   └──────────────┴─────────────┴───────────────┴──────────────┘
                                    │
                          ┌─────────┴─────────┐
                          ▼                   ▼
                    SaveService          AuthService
                    (local-first,        (Supabase: guest,
                     şifreli, sync)       email, Google, Apple)
                          │                   │
                          └─────────┬─────────┘
                                    ▼
                              Supabase (Postgres + Auth + Edge Functions + Storage)
```

### 3.3 Autoload listesi (boş iskeletleri Faz 0'da oluşturulacak)

| Singleton | Sorumluluk |
|-----------|------------|
| `GameManager` | Oyun durumu, sahne geçişleri arası kalıcı state, ana döngü tetikleyici |
| `EventBus` | Global sinyal merkezi (sistemler arası gevşek bağlılık) |
| `TimeService` | Gerçek yerel saat, gün-gece fazı, sunrise/sunset, mevsim, ay evresi |
| `WeatherService` | Konum (coarse) + Open-Meteo, hava durumu kodu → oyun durumu eşleme, cache |
| `NeedsService` | Açlık/enerji/hijyen/mutluluk/sağlık/sosyal; zamanla azalma; offline hesaplama |
| `LifeStageService` | Kullanıcı yaşı → yaşam evresi konfigürasyonu (data-driven `.tres`) |
| `FaithService` | İnanç seçimi, namaz vakitleri (Aladhan/yerel hesap), ritüel zamanlayıcıları |
| `SkillService` | Skill ağacı durumu, bond/affinity seviyesi, ilerleme |
| `EconomyService` | Coin, envanter, shop işlemleri |
| `SaveService` | Local-first şifreli kayıt + Supabase senkronizasyon |
| `AuthService` | Oturum yönetimi: guest/email/Google/Apple |
| `NotificationService` | Yerel bildirimler (vakit, ihtiyaç, hava olayı), izin yönetimi |
| `AudioManager` | Ortam sesi, müzik (mood/zamana göre), SFX, ses ayarları |
| `Localization` | TR/EN dil yönetimi (Godot yerleşik çeviri sistemi üstüne ince sarmalayıcı) |
| `Settings` | Kullanıcı tercihleri (ses, bildirim, hareket azaltma, dil, konum modu) |

### 3.4 Harici servisler

| Servis | Seçim | Gerekçe | Anahtar gerekiyor mu? |
|--------|-------|---------|----------------------|
| **Hava durumu** | **Open-Meteo** (`api.open-meteo.com`) | Ücretsiz, **API anahtarı gerektirmez** (güvenlik artısı — sızacak anahtar yok), cömert limit, current + hourly + daily + sunrise/sunset + WMO weather code döner | ❌ Hayır |
| **Namaz vakitleri** | **Aladhan API** (`api.aladhan.com`) veya cihazda yerel hesap | Koordinattan 5 vakti hesaplar; ücretsiz; çevrimdışı için yerel algoritma da gömülebilir | ❌ Hayır |
| **Backend / Auth / DB** | **Supabase** | Postgres + Auth (Google & Apple OAuth dahil) + Storage + Edge Functions; bulut kayıt için ideal; RLS ile güvenli | API URL + anon key (public, RLS ile korunur) |
| **Konum** | Cihaz GPS (**coarse / şehir seviyesi yeterli**) + manuel şehir seçimi fallback | Hava + vakit için şehir seviyesi yeterli; coarse izin gizlilik açısından çok daha iyi | İzin (runtime) |

> **Güvenlik notu:** Open-Meteo ve Aladhan anahtarsız olduğundan client'a gömülecek sır yok. Eğer ileride anahtarlı bir hava sağlayıcısına geçilirse (ör. premium veri), istek **Supabase Edge Function üzerinden proxy'lenir** — anahtar asla APK içine girmez.

### 3.5 Veri akışı (hava → oyun)

```
Cihaz konumu (coarse)  ──►  WeatherService
        │                        │
        │                        ├─► Open-Meteo GET (lat,lon)
        │                        │     └─► current.weather_code, temp, is_day,
        │                        │         daily.sunrise/sunset, wind, precip
        │                        │
        │                        ├─► WMO code → WeatherState enum eşleme
        │                        │     (clear/clouds/rain/snow/thunder/fog/wind)
        │                        │
        │                        ├─► cache (user://weather_cache.dat, TTL ~30dk)
        │                        │     çevrimdışıysa son bilinen veriyle çalış
        │                        │
        │                        └─► EventBus.weather_changed(state, temp, is_day)
        │
        ▼
TimeService (gerçek saat + sunrise/sunset)
        └─► gün-gece fazı: dawn / day / dusk / night
                └─► EventBus.time_phase_changed(phase)

Home sahnesi bu sinyalleri dinler:
   • WeatherVFX  → yağmur/kar/sis partikülleri + shader
   • DayNightLight → renk/ışık geçişi (dawn turuncu, night lacivert)
   • Creature → davranış (yağmurda şemsiye/içeride, gecede uyku)
   • NeedsService → sıcaklık modifiye (soğuk→üşür, sıcak→susar)
```

---

## 4. Klasör Yapısı

```
weatherling/
├── project.godot
├── export_presets.cfg              # Android (ve sonra iOS) export ayarları
├── .gitignore                      # Godot + Android imza/keystore hariç
├── README.md                       # Senin sesinle, sade
├── LICENSE
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DATA_MODELS.md
│   └── RELEASE_CHECKLIST.md
├── addons/                         # 3. parti eklentiler (bildirim, vb.)
├── autoload/                       # Singletonlar (Bölüm 3.3)
│   ├── game_manager.gd
│   ├── event_bus.gd
│   ├── time_service.gd
│   ├── weather_service.gd
│   ├── needs_service.gd
│   ├── life_stage_service.gd
│   ├── faith_service.gd
│   ├── skill_service.gd
│   ├── economy_service.gd
│   ├── save_service.gd
│   ├── auth_service.gd
│   ├── notification_service.gd
│   ├── audio_manager.gd
│   ├── localization.gd
│   └── settings.gd
├── scenes/
│   ├── boot/                       # splash, oturum kontrol, ilk yönlendirme
│   ├── onboarding/                 # isim, yaş, din seçimi, izinler
│   ├── home/                       # ana yaşayan dünya sahnesi
│   ├── creature/                   # yaratık sahnesi + durum makinesi
│   ├── ui/                         # HUD, menüler, paneller
│   │   ├── hud/
│   │   ├── menu_main/
│   │   ├── panel_feed/
│   │   ├── panel_skills/
│   │   ├── panel_shop/
│   │   ├── panel_wardrobe/
│   │   ├── panel_journal/
│   │   ├── panel_settings/
│   │   └── panel_faith/
│   ├── weather_vfx/                # yağmur/kar/sis/şimşek efektleri
│   └── minigames/                  # (faz 2) hava temalı mini oyunlar
├── data/                           # data-driven kaynaklar (.tres)
│   ├── life_stages/                # her yaş evresi konfigi
│   ├── foods/                      # yemek item'ları
│   ├── skills/                     # skill node tanımları
│   ├── items/                      # kozmetik/dekor item'ları
│   ├── faiths/                     # inanç ritüel tanımları
│   └── events/                     # rastgele/sezonsal olay tanımları
├── resources/                      # özel Resource sınıfları (.gd)
│   ├── creature_state.gd
│   ├── life_stage_config.gd
│   ├── food_item.gd
│   ├── skill_node.gd
│   └── faith_profile.gd
├── art/
│   ├── creature/                   # sprite sheet'ler (evreye göre)
│   ├── environment/                # arka plan katmanları (mevsim/hava)
│   ├── ui/                         # 9-patch, ikonlar
│   ├── particles/                  # damla, kar tanesi dokuları
│   └── fonts/
├── audio/
│   ├── music/                      # lo-fi mood/zaman parçaları
│   ├── ambient/                    # yağmur, rüzgâr, gece böcekleri
│   └── sfx/                        # dokunma, yeme, mutluluk sesleri
├── shaders/                        # gün-gece ışık, ıslaklık, sis
├── localization/
│   ├── tr.po
│   └── en.po
└── tests/                          # GUT (Godot Unit Test) senaryoları
```

---

## 5. Veri Modelleri

### 5.1 `CreatureState` (kalıcı yaratık durumu — yerel + bulut)

```gdscript
# resources/creature_state.gd
class_name CreatureState
extends Resource

@export var creature_name: String = ""          # kullanıcının verdiği isim
@export var user_age: int = 0                    # onboarding'de girilen yaş
@export var life_stage: String = ""              # "filiz","tomurcuk",... (Bölüm 7)
@export var faith: String = "none"               # "islam","christianity",... veya "none"
@export var birth_unix: int = 0                  # yaratığın doğuşu (epoch)
@export var bond_level: int = 1                  # ilişki seviyesi
@export var bond_xp: int = 0

# İhtiyaçlar (0–100)
@export var hunger: float = 80.0
@export var energy: float = 80.0
@export var hygiene: float = 80.0
@export var happiness: float = 80.0
@export var health: float = 100.0
@export var social: float = 70.0

@export var coins: int = 0
@export var inventory: Dictionary = {}           # item_id -> adet
@export var unlocked_skills: Array[String] = []
@export var equipped_cosmetics: Dictionary = {}  # slot -> item_id
@export var home_decor: Dictionary = {}

@export var last_seen_unix: int = 0              # offline hesaplama için
@export var stats: Dictionary = {}               # gün sayısı, görülen hava türleri, vb.
@export var settings: Dictionary = {}            # kullanıcı tercihleri
@export var version: int = 1                     # şema migrasyonu için
```

### 5.2 `LifeStageConfig` (her yaş evresi için data-driven — Bölüm 7)

```gdscript
# resources/life_stage_config.gd
class_name LifeStageConfig
extends Resource

@export var id: String                           # "filiz"
@export var display_name_key: String             # i18n anahtarı
@export var min_age: int
@export var max_age: int
@export var sprite_set: String                   # art/creature/<id>/
@export var palette: String                      # renk teması
@export var personality_traits: Array[String]    # ["meraklı","enerjik"]

# İhtiyaç davranışı
@export var hunger_decay_rate: float             # birim/saat
@export var energy_decay_rate: float
@export var sleep_hours: Vector2                  # tipik uyku penceresi (lokal saat)
@export var nap_count: int                        # gündüz şekerleme sayısı

# Yemek
@export var preferred_foods: Array[String]
@export var disliked_foods: Array[String]
@export var eating_style_key: String              # animasyon/diyalog stili

# Aktivite & skill odağı
@export var activity_keys: Array[String]          # "play","study","work","garden"...
@export var skill_branches: Array[String]         # bu evrede açık skill dalları
@export var special_events: Array[String]         # bu evreye özel olay id'leri

@export var idle_dialogue_keys: Array[String]     # ruh hali baloncukları
@export var request_keys: Array[String]           # "ister" diyalogları
```

### 5.3 Supabase tabloları (SQL)

```sql
-- Kullanıcı profili (auth.users ile 1:1)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Yaratık kaydı (bulut yedek/sync)
create table public.creature_saves (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null,            -- CreatureState serileştirilmiş
  schema_version int not null default 1,
  updated_at timestamptz default now()
);

-- RLS: herkes SADECE kendi satırını görür/yazar
alter table public.profiles enable row level security;
alter table public.creature_saves enable row level security;

create policy "own_profile" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "own_save" on public.creature_saves
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
```

> **Local-first ilkesi:** Oyun her zaman önce yerel şifreli kayıttan çalışır; internet varsa ve kullanıcı giriş yaptıysa bulutla senkron olur. Çakışmada **en son `updated_at` kazanır** (last-write-wins), MVP için yeterli. İleride alan-bazlı merge eklenebilir.

---

## 6. Sistemler — Detaylı

### 6.1 Zaman & Gün-Gece (`TimeService`)

- Kaynak: cihaz yerel saati (`Time.get_datetime_dict_from_system()`).
- Sunrise/sunset: Open-Meteo `daily` verisinden (konuma göre gerçek).
- **Fazlar:** `dawn` (sunrise ± ~45dk), `day`, `dusk` (sunset ± ~45dk), `night`.
- Faz değişince `EventBus.time_phase_changed(phase)` yayılır → ışık shader'ı + yaratık davranışı.
- **Uyku:** Yaratık `night` fazında ve kendi evresinin `sleep_hours` penceresinde uyur. Kullanıcı gece açarsa yaratık uyuyor görünür (yumuşak nefes animasyonu, "Zzz"), istenirse nazikçe uyandırılabilir.
- **Ay evresi:** Tarihten hesaplanır (basit astronomik formül); gece gökyüzünde doğru ay evresi çizilir. (Küçük ama "vay be" detayı.)

### 6.2 Mevsim (`SeasonService` — TimeService içinde modül)

- Tarih + **yarımküre** (enlem işareti) → ilkbahar/yaz/sonbahar/kış.
- Güney yarımküre kullanıcısı için mevsimler ters (gerçekçilik!).
- Mevsim arka plan katmanını, palet tonunu ve sezonsal item/olayları etkiler.

### 6.3 Hava Durumu (`WeatherService`)

**WMO weather code → oyun durumu eşlemesi:**

| WMO kod aralığı | WeatherState | Oyundaki görünüm |
|-----------------|--------------|------------------|
| 0–1 | `CLEAR` | Güneşli, parlak; yaratık güneşlenir, neşeli |
| 2–3 | `CLOUDS` | Bulutlu, sakin ışık |
| 45,48 | `FOG` | Sisli atmosfer, yumuşak görüş |
| 51–67, 80–82 | `RAIN` | Yağmur partikülleri, su birikintileri, şemsiye/içeride cozy; bitkiler büyür |
| 71–77, 85–86 | `SNOW` | Kar yağışı + birikme, yaratık atkı/nefes buğusu |
| 95–99 | `THUNDER` | Şimşek flash + gök gürültüsü, yaratık saklanır/sarılır |
| rüzgâr (`wind_speed`) yüksek | `WINDY` (modifiye) | Yapraklar/eşyalar savrulur |

- **Sıcaklık modifiye:** `temp < 5°C` → "üşüyor" durumu (sıcak içecek/atkı ister); `temp > 30°C` → "sıcakladı" (su/gölge ister). Bu modifiye `NeedsService`'e bağlanır.
- **Cache:** `user://weather_cache.dat`, TTL ~30 dk. İnternet yoksa son bilinen veriyle çalış, UI'da küçük "çevrimdışı" rozeti göster.
- **Gizlilik fallback:** Konum izni reddedilirse → manuel şehir seçimi (Open-Meteo geocoding ile şehir arama). Hiç konum vermeden de oyun tam çalışır.

### 6.4 İhtiyaçlar & Bakım (`NeedsService`) — Tamagotchi çekirdeği

Altı ihtiyaç (0–100): **hunger, energy, hygiene, happiness, health, social.**

- Her ihtiyaç zamanla azalır; azalma hızı **yaş evresine göre değişir** (`LifeStageConfig.*_decay_rate`). Çocuk hızlı acıkır, yaşlı yavaş.
- **Offline hesaplama:** Uygulama açıldığında `now - last_seen_unix` farkı kadar ihtiyaçlar geriye dönük hesaplanır (ama yumuşatılmış — 8 saat yoksun kalınca "yarı ölü" bulmasın; bir taban koruması var).
- **Ölüm yok.** İhtiyaçlar 0'a inerse yaratık "küskün/hasta" moduna geçer, mutluluk düşer; bakımla **tamamen geri kazanılır**. Bu, cozy ruhunun ve uzun vadeli bağın korunması için kritik bir tasarım kararı.
- `health`, diğer ihtiyaçlar uzun süre düşük kalırsa yavaşça etkilenir; bakımla iyileşir. Hava da etkiler (uzun soğukta üşütme riski — nazik, tıbbi değil).
- Her bakım eylemi `bond_xp` kazandırır → bond level → yeni içerik/diyalog açar.

**Etkileşimler:** Besle (yemek paneli) · Uyut (ışığı kıs / yatağa götür) · Oyna (mini etkileşim/dokunma) · Temizle (banyo/fırça) · Sev (dokun → kalp efekti) · Konuş (diyalog baloncuğu).

### 6.5 Yemek Sistemi

- Data-driven `FoodItem` (.tres): id, isim, ikon, sprite, doyurma değeri, mutluluk değeri, sağlık etkisi, fiyat, hangi evrelerin sevdiği/sevmediği.
- Yaş evresine göre **tercih ve tepki farklı:** çocuk şekeri sever ama fazlası "şeker krizi"; yaşlı hafif çorbayı sever, ağır yemekte enerjisi düşer.
- Yeme animasyonu evreye göre stilize (`eating_style_key`): çocuk dağıtarak yer, yetişkin düzenli, yaşlı yavaş ve keyifli.
- Envanter + shop ekonomisi (coin) ile bağlı.

### 6.6 Ruh Hali Sistemi (`MoodSystem`)

İhtiyaçların ağırlıklı bileşimi + hava + zaman + son etkileşimler → ruh hali: `joyful / content / sleepy / hungry / lonely / cold / hot / sick / grumpy`. Ruh hali; animasyonu, diyalog baloncuklarını ve istek olaylarını sürer. Yaş evresi diyalog tonunu değiştirir (Bölüm 7).

### 6.7 Olaylar (`EventSystem`)

- **Rastgele küçük olaylar:** "Bir kelebek geldi", "Posta kutusunda mektup var" (bond hediyesi), hava temalı sürprizler.
- **Sezonsal olaylar:** Yılbaşı/Ramazan/ilkbahar çiçeklenmesi/gündönümü → dekor + özel item.
- **Yaşam evresine özel olaylar:** Bölüm 7'deki `special_events` (doğum günü, sınav stresi, terfi, torun ziyareti...).
- **Astronomik:** Dolunay, meteor yağmuru gecesi (tarihten tetiklenir) → gökyüzü gösterisi.

### 6.8 Ekonomi (`EconomyService`)

- Tek para birimi: **coin.** Günlük bakım, görevler, achievements ile kazanılır. Pay-to-win yok.
- Harcama: kozmetik (yaratık aksesuarları), ev dekorasyonu, bazı yemekler.
- MVP'de **gerçek para yok.** İleride yalnızca *kozmetik* IAP veya "destek paketi" düşünülebilir (etik, opsiyonel) — Bölüm 22.

---

## 7. Yaşam Evreleri — Her Yaş İçin Kurgu

Yaratık, kullanıcının onboarding'de girdiği yaşı yansıtır. Evreler **bitki/doğa büyüme metaforu** üzerine kurulu (cozy + hava/mevsim temasıyla uyumlu + Türk kültüründe çınar = uzun ömür/bilgelik sembolü). Her evre ayrı bir `LifeStageConfig.tres` dosyasıdır; tüm sayılar oradan ayarlanır, koda gömülmez.

> **Önemli tasarım kararı (senin onayın için — Bölüm 23):** Yaratık doğduğu evrede mi kalır (kullanıcının aynası), yoksa zamanla yaşlanır/büyür mü? **Önerim:** Yaratık kullanıcının *yaşam evresinde doğar* ve orada kalır (ayna ilkesi korunur); "ilerleme" yaşlanmayla değil **bond seviyesi + skill ağacı + dünya** ile olur. Ayrıca opsiyonel bir "Yaşam Yolculuğu" modu, isteyene yaratığı evreler boyunca büyütme imkânı verebilir (faz 2).

---

### 7.1 🌱 Filiz — Çocukluk (4–12 yaş)

- **Görünüm:** Küçük, yuvarlak, kocaman gözler, parlak doygun renkler. Sürekli zıplayan, kıpır kıpır idle animasyonu.
- **Kişilik:** Meraklı, enerjik, dikkati çabuk dağılan, duyguları uçtan uca (bir an sevinç, bir an surat asma).
- **Yemek:** Atıştırmalık/meyve/şeker ister; sebzeye direnir. Düzensiz öğün. **Şeker fazlası → hiperaktivite sonra ani enerji çöküşü.** Yeme stili: dağıtarak, neşeyle.
- **Aktivite & iş:** Oyun ağırlıklı + "okul/ödev" mini görevleri. Çok oyun = mutluluk ama hızlı yorgunluk.
- **Skill dalları:** Yaratıcılık, Oyun, Temel Öğrenme (harf/sayı), Hayal Gücü.
- **İhtiyaçlar/sorunlar:** Çok uyku + gündüz şekerlemesi; sık acıkır; **kolay hastalanır** (özellikle soğuk/yağmurlu havada üşütme); oyuncak ister; gece korkusu (karanlıkta sarılma ister).
- **Günlük ritim:** Erken yatış, sabah enerjik patlama, öğleden sonra şekerleme.
- **Özel olaylar:** Doğum günü partisi 🎂, diş perisi, yeni oyuncak isteği, kâbus gecesi (sakinleştirme).

### 7.2 🌿 Tomurcuk — Ergenlik (13–17 yaş)

- **Görünüm:** Uzamış, incelmiş; saç/stil değişimi; kulaklık takan, hafif somurtkan duruş.
- **Kişilik:** Değişken ruh hali, biraz asi, sosyal, mahremiyet ister, trend takipçisi.
- **Yemek:** Abur cubur, fast-food, enerji içeceği. Öğün atlama. **Sağlıksız beslenme → cilt/enerji dalgalanması.** Yeme stili: telefonla, dalgın.
- **Aktivite & iş:** Müzik, oyun, "sosyal medya", **sınav çalışması** (stresli dönemler), ilk hobiler.
- **Skill dalları:** Müzik, Spor, Dijital Beceri, Sosyal Beceri, Kimlik Keşfi.
- **İhtiyaçlar/sorunlar:** Uyku düzensiz (geç yatar, geç kalkar); **sosyal onay** ihtiyacı; özgürlük arzusu; can sıkıntısı → mutsuzluk.
- **Günlük ritim:** Gece kuşu; sabah zor uyanma.
- **Özel olaylar:** Sınav stresi haftası 📚, arkadaş buluşması, ilk hobi tutkusu, "ruh hali fırtınası" günü.

### 7.3 🌸 Çiçek — Genç Yetişkin (18–29 yaş)

- **Görünüm:** Olgun, stilize kıyafet; sıkça **kahve fincanı** animasyonu; dinamik, enerjik.
- **Kişilik:** Hırslı, sosyal, enerjik; ara ara gelecek kaygısı.
- **Yemek:** **Kahve bağımlısı**, dışarıda yeme; ara sıra "fitness/sağlıklı" dönemleri. Düzensiz ama telafi eder.
- **Aktivite & iş:** Kariyer/iş kurma, spor salonu, sosyal hayat, öğrenme. Çalışma = coin ama aşırısı stres.
- **Skill dalları:** Kariyer/Meslek, Fitness, Finans, İlişki Becerileri.
- **İhtiyaçlar/sorunlar:** Kahve/enerji; sosyalleşme; başarı hissi. **Aşırı çalışma → tükenmişlik (burnout) durumu** (dinlenmeyle çözülür).
- **Günlük ritim:** Yoğun gündüz, geç saate kadar uyanık, hafta sonu geç kalkma.
- **Özel olaylar:** İş görüşmesi, ilk maaş 💰, fitness hedefi, randevu (date) gecesi, tükenmişlik krizi.

### 7.4 🍎 Meyve — Yetişkin (30–44 yaş)

- **Görünüm:** Dengeli, olgun, rahat-şık; sakin ve güvenli duruş.
- **Kişilik:** Sorumlu, hedef odaklı, dengeli; zaman zaman yorgun.
- **Yemek:** Daha bilinçli beslenme, ev yemeği ağırlıklı; kahve devam. Sağlık-keyif dengesi. Yeme stili: düzenli, huzurlu.
- **Aktivite & iş:** Kariyer zirvesi, hobiler, "bitki/evcil bakımı" metaforu (sorumluluk teması), iş-yaşam dengesi arayışı.
- **Skill dalları:** Uzmanlaşma (meslek ustalığı), Yönetim/Liderlik, Hobi Ustalığı, Sağlık.
- **İhtiyaçlar/sorunlar:** Denge, dinlenme, anlam. **İş-yaşam dengesizliği → stres** durumu.
- **Günlük ritim:** Düzenli; erken kalkma eğilimi; hafta sonu dinlenme.
- **Özel olaylar:** Terfi 📈, büyük hedef tamamlama, "tatil ihtiyacı" uyarısı, denge krizi.

### 7.5 🍂 Hasat — Orta Yaş (45–59 yaş)

- **Görünüm:** Olgun, gözlük detayı; daha sıcak/sakin renk paleti; ağırbaşlı.
- **Kişilik:** Bilge, sabırlı, mentorluk sever, sağlık bilinci yüksek.
- **Yemek:** Hafif ve sağlıklı, bitki çayı, porsiyon kontrolü. **Ağır yemek → sindirim/enerji düşüşü.** Yeme stili: ölçülü, keyifli.
- **Aktivite & iş:** Bahçe, hobi ustalığı, mentorluk, yürüyüş. Sakin tempo.
- **Skill dalları:** Bilgelik, Bahçecilik/Zanaat, Mentorluk, Sağlık Yönetimi.
- **İhtiyaçlar/sorunlar:** Dinlenme; sağlık (uyku/eklem değişimi — nazik, asla tıbbi tavsiye değil); huzur.
- **Günlük ritim:** Erken yat-erken kalk; öğle dinlenmesi.
- **Özel olaylar:** Hobi sergisi 🪴, "mentor olma" anı, sağlıklı yaşam hedefi, sakin keyif günü.

### 7.6 🌳 Kök — Yaşlılık (60–74 yaş)

- **Görünüm:** Kır saç, sıcak yumuşak renkler; yavaş, huzurlu animasyon; battaniye/şal detayı.
- **Kişilik:** Huzurlu, nostaljik, hikâye anlatan, rutin seven.
- **Yemek:** Hafif öğünler, çay ☕, çorba; az ama sık. Yeme stili: yavaş, ritüel gibi (sabah çayı!).
- **Aktivite & iş:** Okuma, bahçe, anılar, "torun ziyareti" metaforu, kısa yürüyüş, şekerleme.
- **Skill dalları:** Bilgelik, Hikâye Anlatıcılığı, Sükûnet, Bahçe.
- **İhtiyaçlar/sorunlar:** Çok dinlenme; **sıcaklık** (soğuk havada üşür, sıcak içecek/şal ister); şefkat; rutin.
- **Günlük ritim:** Erken yatış, sık kısa şekerlemeler, sabah çay ritüeli.
- **Özel olaylar:** Anı paylaşımı 📷, torun ziyareti, sakin kutlama, "nostalji günü".

### 7.7 🌲 Çınar — İhtiyarlık (75+ yaş)

- **Görünüm:** Çok yaşlı ve bilge; çok yumuşak pastel palet; çok yavaş, zarif hareketler; baston/sallanan sandalye.
- **Kişilik:** Derin huzur, bilgelik, minnettarlık, yavaşlık.
- **Yemek:** Çok hafif; çorba/çay; küçük porsiyon. Yeme stili: sabırlı, şükreden.
- **Aktivite & iş:** Çoğunlukla dinlenme, güneşlenme, anılar, kısa sohbet.
- **Skill dalları:** Derin Bilgelik, Miras/Öğüt Verme.
- **İhtiyaçlar/sorunlar:** Çok dinlenme; sıcaklık; sevgi; sakinlik.
- **Günlük ritim:** Gün boyu yumuşak dinlenme döngüleri.
- **Özel olaylar:** Yaşam bilgeliği paylaşımı 🌟, huzurlu anlar, minnettarlık ritüeli.

---

**Yaş → evre eşleme tablosu (kod için):**

| Yaş aralığı | Evre id | İsim |
|-------------|---------|------|
| 4–12 | `filiz` | Filiz |
| 13–17 | `tomurcuk` | Tomurcuk |
| 18–29 | `cicek` | Çiçek |
| 30–44 | `meyve` | Meyve |
| 45–59 | `hasat` | Hasat |
| 60–74 | `kok` | Kök |
| 75+ | `cinar` | Çınar |

> **Yaş kapısı uyarısı (yasal):** Eğer 13/16 yaş altı kullanıcılardan veri toplanacaksa COPPA (ABD) ve GDPR-K / KVKK (çocuk verisi) yükümlülükleri devreye girer. **Öneri:** Uygulamayı "çocuklara yönelik değil, her yaşa uygun" konumla; hesap/bulut özelliklerini yaş kapısıyla yönet (örn. küçük yaş seçilirse yalnızca yerel oyun, bulut kayıt için ebeveyn/yetişkin onayı). Detay Bölüm 16.

---

## 8. İnanç / Gelenek Sistemi

Onboarding'de **opsiyonel** ve **atlanabilir** bir adım: "İnanç / Gelenek". Seçenekler: **İslam, Hristiyanlık, Musevilik, Hinduizm, Budizm, Diğer/Maneviyat, Belirtmek istemiyorum (seküler).**

Yaratığın kendi nazik manevi hayatı, seçilen geleneği yansıtır — atmosferik ve sıcak, asla zorlayıcı değil.

### Tasarım hassasiyeti (zorunlu ilkeler)
> 🕊️ **Saygı her şeyden önce gelir.**
> - İbadet **coin/ödül kasması mekaniğine indirgenmez.** Yaratık ritüelini kendiliğinden yapar; kullanıcı isterse "eşlik eder" (dokunup yanında olur) ve bu **bağı** derinleştirir — ama eşlik etmemenin **cezası yoktur.**
> - Görseller kültürel olarak doğru ve saygılı olmalı; klişe/karikatür değil.
> - Kullanıcı inancını istediği zaman **değiştirebilir veya tamamen kapatabilir** (Ayarlar → İnanç).
> - Hiçbir gelenek "daha doğru" sunulmaz; yargı yok.

### Geleneklere göre ritimler

| Gelenek | Ritim / mekanik | Konum-zaman bağı |
|---------|-----------------|------------------|
| **İslam** | Günde 5 vakit (imsak/sabah, öğle, ikindi, akşam, yatsı). Yaratığın küçük, huzurlu bir dua anı animasyonu; evde "namaz köşesi" dekoru. Opsiyonel nazik vakit bildirimi (kapatılabilir). | **Vakitler konumdan hesaplanır** (Aladhan API veya cihazda yerel hesap) — tıpkı hava gibi gerçek ve yerel. Ramazan'da özel sahur/iftar sahnesi. |
| **Hristiyanlık** | Pazar bir kilise/şapel ziyaret anı; günlük kısa şükür/dua anı; mevsimsel (Noel/Paskalya) cozy dekor. | Haftanın günü + yerel saat. |
| **Musevilik** | Cuma akşamı–Cumartesi **Shabbat** dinlenme/huzur modu; bayramlarda dekor. | Yerel gün batımından gün batımına. |
| **Hinduizm** | Sabah/akşam aarti-benzeri kısa huzur anı; festival ışıkları (Diwali dekoru). | Yerel saat + festival takvimi. |
| **Budizm** | Kısa meditasyon/nefes anı; sakinlik bonusu. | Yerel saat. |
| **Diğer/Maneviyat** | Genel "şükran/farkındalık" anı (evrensel, opt-in). | Yerel saat. |
| **Seküler (belirtmek istemiyorum)** | İbadet mekaniği **yok.** Bunun yerine opsiyonel "minnettarlık/farkındalık" anları (tamamen opt-in, dinden bağımsız). | — |

**`FaithService`** sorumluluğu: seçili gelenek → ilgili ritüel zamanlayıcıları kur; vakit/zaman geldiğinde `EventBus.devotion_time(faith, ritual)` yayıla; Home sahnesi yaratığın ritüel animasyonunu oynatsın; opsiyonel bildirim `NotificationService` üzerinden gönderilsin. Çevrimdışı için namaz vakitleri yerel hesap algoritmasıyla da üretilebilir (Aladhan'a bağımlılık olmadan).

---

## 9. Skill Ağacı ve Gelişim

- **Data-driven `SkillNode` (.tres):** id, isim, açıklama, ikon, maliyet (coin/bond xp), ön koşul node'lar, açtığı içerik/buff, **hangi yaşam evresinde görünür.**
- **Dallar yaşa göre filtrelenir** (Bölüm 7'deki `skill_branches`). Örn. Çiçek evresinde "Kariyer" dalı; Kök evresinde "Bilgelik" dalı.
- **Bond/Affinity seviyesi:** Bakım ve etkileşimle `bond_xp` kazanılır → bond level artar → yeni diyaloglar, animasyonlar, dekor ve skill node'ları açılır. Bu, "süreklilik" sütununun motoru.
- UI: yumuşak, organik düğüm haritası (sert teknolojik ağaç değil; cozy estetik — yapraklar/dallar gibi). Pan + zoom, kilitli node'lar soluk, açılabilir node'lar parıltılı.
- Ödüller asla "zorunlu grind" hissi vermez; oyun ihmal edilse de ilerleme kaybolmaz.

---

## 10. UI / UX Tasarımı

### 10.1 Sanat yönü (art direction)

"Ultra grafik + gerçekçi animasyon" isteğini **premium cozy pixel art** olarak yorumluyoruz: yüksek çözünürlüklü, zengin paletli, **çok cilalı ve karakterli** piksel sanatı; atmosferik ışık ve hava efektleriyle "vay be" hissi. (Fotogerçekçilik Tamagotchi/Godot piksel konseptiyle çelişir; ama "juicy", canlı, yumuşak animasyon = gerçekten etkileyici sonuç.) Referans his: *A Little to the Left*, *Alba*, *Hoa*, *Sky*, klasik Tamagotchi sıcaklığı.

**İlkeler:**
- **Pixel-perfect:** Project Settings → Stretch mode `canvas_items`, integer scaling açık, "Snap 2D Transforms/Vertices to Pixel" açık. Doku import filter = `Nearest`, mipmap kapalı.
- **Palet hava/zamana tepkir:** Aynı sahne sabah pastel-turuncu, gündüz canlı, gün batımı sıcak-altın, gece lacivert-mor. Bu geçişler shader ile (Bölüm 11).
- **Mikro-etkileşim ve "juice":** squash & stretch, dokununca tepki, partikül kalpler, yumuşak easing — her dokunuş tatmin edici olmalı.
- **Tek el kullanım:** Önemli kontroller alt bölgede (başparmak erişimi), büyük dokunma hedefleri (min 48dp).

### 10.2 Ekran haritası

```
Splash → (oturum kontrol)
  ├─ İlk kez → Onboarding (isim → yaş → inanç[opsiyonel] → konum izni[opsiyonel] → giriş[opsiyonel/atlanabilir])
  └─ Dönüş → Home

Home (ana yaşayan dünya)
  ├─ HUD (üst): ruh hali, ihtiyaç barları (sade), coin, hava/saat rozeti
  ├─ Alt bar: [Besle] [Oyna] [Skill] [Mağaza] [Menü]
  └─ Yaratığa dokun → sev/etkileşim

Menü
  ├─ Gardırop (kozmetik/dekor)
  ├─ Günlük (Journal — yaratığın hava/gün notları)
  ├─ Başarımlar & Koleksiyon
  ├─ İnanç (değiştir/kapat)
  ├─ Profil & Hesap (giriş, senkron, hesap sil)
  └─ Ayarlar (ses, bildirim, dil, hareket azaltma, konum modu, gizlilik)
```

### 10.3 Onboarding akışı (kritik — ilk izlenim)

1. Sıcak karşılama animasyonu (yumurtadan/tomurcuktan çıkış).
2. **İsim ver:** yaratığa profil ismi.
3. **Yaş gir:** bu yaratığın evresini belirler. ("Yaşın, yaratığının dünyasını şekillendirir.")
4. **İnanç (opsiyonel, atla butonu belirgin):** gelenek seçimi.
5. **Konum (opsiyonel):** "Gerçek havanı yaşatmak için konum" — coarse izin; reddedilirse manuel şehir.
6. **Giriş (opsiyonel, atlanabilir):** Misafir devam et / Google ile / e-posta ile. (Bulut kayıt için sonra da bağlanabilir.)
7. Home'a yumuşak geçiş; ilk mini rehber (3 dokunuşluk).

### 10.4 Erişilebilirlik (Play Store kalite + etik)
- Hareket azaltma modu (partikül/animasyon kısma).
- Metin boyutu ölçeği; yüksek kontrast seçeneği; renk körlüğü dostu paletler.
- Dokunma hedefleri ≥ 48dp; ses bağımsız (görsel ipuçları da var).
- TR + EN tam lokalizasyon (i18n baştan).

---

## 11. Animasyon ve Görsel Sistem

### 11.1 Yaratık durum makinesi (AnimationTree / AnimationPlayer + state machine)

Durumlar: `idle`, `happy`, `sad`, `sleepy`, `sleep`, `eat`, `play`, `pet_react`, `cold`, `hot`, `sick`, `devotion`. Her yaşam evresinin **kendi sprite set'i** var; aynı state isimleri, farklı çizim/tempo (`LifeStageConfig.sprite_set`).

- Geçişlerde yumuşak blend; idle'da nefes + ara sıra göz kırpma/esneme (procedural "alive" hissi).
- Squash & stretch ve secondary motion (kulak/şal sallanması) ile organiklik.

### 11.2 Gün-gece ışık shader'ı

- Tam ekran `CanvasModulate` veya custom shader; faz (`dawn/day/dusk/night`) ve `is_day` değerine göre renk çarpanı + sıcaklık (color grading) lerp'lenir.
- Gece: yıldız katmanı + doğru **ay evresi** + yumuşak parıltı; gündüz: parlak; gün batımı: altın-turuncu gradyan.

### 11.3 Hava VFX (`weather_vfx/`)

- **Yağmur:** GPUParticles2D damlalar + zemin sıçrama + ekranda hafif ıslaklık shader'ı + su birikintisi yansıması. (Partikül **havuzlanır**, sürekli yaratılıp yok edilmez.)
- **Kar:** yavaş düşen taneler + birikme katmanı + nefes buğusu.
- **Sis:** katmanlı yarı saydam bulut shader'ı, derinlik hissi.
- **Şimşek:** ara sıra ekran flash + gecikmeli gök gürültüsü sesi.
- **Rüzgâr:** yaprak/eşya savrulma, ağaç sallanması (vertex shader veya sprite offset).
- Hepsi `WeatherState`'e bağlı; mevsimle birleşir (sonbaharda rüzgârla yaprak, kışta kar + çıplak ağaç).

### 11.4 Performans-bilinçli görsel kurallar
- Tüm sprite'lar **texture atlas**'ta; draw call minimum.
- Partikül sayıları cihaz seviyesine göre ölçeklenebilir (düşük/orta/yüksek — Ayarlar veya otomatik).
- Arka plan **paralaks katmanları** sınırlı (2–3 katman yeter).

---

## 12. Ses Tasarımı

- **Müzik:** Lo-fi, sakin; **zaman/ruh haline göre** uyarlanır (sabah ferah, gece dingin, yağmurda melankolik-cozy). Yumuşak crossfade.
- **Ortam (ambient):** Gerçek havaya bağlı — yağmur sesi, rüzgâr uğultusu, gece böcekleri/cırcır, kuş cıvıltısı (gündüz/açık hava). Hava değişince ortam katmanı crossfade.
- **SFX:** Dokunma, sevme (kalp), yeme, mutluluk parıltısı, bildirim — hepsi yumuşak ve düşük frekanslı, rahatsız etmeyen.
- **Ses ayarları:** Müzik/ortam/SFX bağımsız sliderlar; sessiz mod; uygulama arka plandayken ses durur.
- Format: `.ogg` (Godot için ideal, küçük boyut).

---

## 13. Kimlik Doğrulama ve Bulut Kayıt

**Backend: Supabase Auth.** Yaklaşım: **kademeli.**

### MVP (Faz 8)
1. **Misafir / Anonim:** Anında oyna, hiçbir hesap gerekmez (yerel kayıt). Supabase anonymous auth veya tamamen yerel — sonra hesaba "yükselt".
2. **E-posta + şifre / sihirli bağlantı (magic link):** En basit, native eklenti gerektirmez.
3. **Google ile giriş:** Supabase OAuth akışı, sistem tarayıcısı + **deep link / Android App Link** ile uygulamaya dönüş. (Godot'ta hazır "Google butonu" yok; OAuth redirect deseni kullanılır. Alternatif: bir Google Sign-In Android eklentisi + token'ı Supabase'e takas.)

### Sonra (iOS fazı)
4. **Apple ile giriş:** Apple, başka sosyal giriş varsa App Store'da **zorunlu** kılar. Supabase Apple OAuth akışı.

### Hesap & kayıt
- **Local-first:** oyun her zaman yerel şifreli kayıttan çalışır; giriş yapılınca bulutla senkron (last-write-wins).
- **Hesap bağlama:** misafir → Google/e-posta yükseltme, ilerleme korunur.
- **Hesap silme:** Ayarlar'dan tek tıkla hesap + bulut verisi silme (Play & yasal gereklilik). Yerel veri de temizlenir.
- **Veri dışa aktarma:** kullanıcı kendi kayıt JSON'unu indirebilir (KVKK/GDPR dostu).

### Deep link kurulumu (Google OAuth için, özet)
- Android `AndroidManifest` (Godot export'ta custom template/plugin ile) bir custom scheme/App Link tanımlar (örn. `weatherling://auth-callback`).
- Supabase Auth redirect URL'sine bu eklenir.
- Akış: uygulama → sistem tarayıcısı (Supabase OAuth) → Google → callback deep link → uygulama oturumu yakalar.
- **Tam adımlar build sırasında doğrulanmalı** (Godot + Supabase OAuth entegrasyonu eklenti/sürüm bağımlı; Faz 8'de güncel dokümana bakılır).

---

## 14. Bildirimler

- **Yerel bildirimler** (Godot Android için bir notification eklentisi ile — `addons/`):
  - 🕌 İnanç ritmi (vakit hatırlatması — opsiyonel, kapatılabilir).
  - 🍎 Yaratık ihtiyaç hatırlatması ("[İsim] acıktı") — nazik, spam değil, frekans sınırlı.
  - 🌧️ Hava olayı ("Senin orada yağmur başladı, [İsim] de ıslanıyor!") — opt-in, eğlenceli.
  - 🌙 Günlük nazik check-in (isteğe bağlı).
- **Android 13+ (`POST_NOTIFICATIONS`)**: runtime izin isteği; reddedilirse sessizce devam.
- Tüm bildirim kategorileri Ayarlar'dan tek tek açılır/kapanır.
- **Push (FCM)**: MVP'de yok; ileride sezonsal etkinlik duyurusu için eklenebilir (Bölüm 22).

---

## 15. Performans Optimizasyonu

Cozy/idle bir uygulama için **pil ve ısı** = en kritik metrik (kullanıcı uygulamayı uzun süre açık tutabilir).

- **`OS.low_processor_usage_mode = true`** (veya project setting): ekran değişmediğinde yeniden render etme → pil dostu. Cozy idle oyunlar için ideal.
- **FPS yönetimi:** aktif sahnede 60 FPS hedef; idle/animasyonsuz anlarda düşür; uygulama arka plandayken render duraklat (`Engine.max_fps`, `process_mode`).
- **Partikül havuzlama** (rain/snow), atlas, draw call minimizasyonu (Bölüm 11.4).
- **Async/threaded yükleme** (`ResourceLoader.load_threaded_*`) — takılma yok.
- **Doku sıkıştırma:** Android için ASTC/ETC2 (piksel sanatı küçük; yine de doğru import ayarı). AAB ile cihaza özel doku dağıtımı.
- **Bellek:** orphan node kontrolü (Godot 4.6+ ObjectDB snapshot/diff ile kolay), sahne geçişlerinde temizlik.
- **Düşük donanım testi:** ucuz/eski Android cihazda hedef akıcılık doğrulanır (min cihaz profili belirle).
- **APK/AAB boyutu:** kullanılmayan asset'ler hariç; export'ta "Export With Debug" kapalı; gereksiz şablon özellikleri kapalı.

---

## 16. Güvenlik ve Gizlilik

### Güvenlik
- **Client'ta sır yok** (Open-Meteo/Aladhan anahtarsız; anahtarlı servis olursa Supabase Edge Function proxy). Supabase **anon key** public'tir ama **RLS** ile korunur — kimse başkasının verisine erişemez.
- **Şifreli yerel kayıt:** `FileAccess.open_encrypted_with_pass()` ile AES; oturum token'ları güvenli saklanır (Android Keystore'a köprü ileride).
- **HTTPS zorunlu**, sertifika doğrulaması açık.
- **İzin minimizasyonu:** sadece `INTERNET`, `ACCESS_COARSE_LOCATION` (şehir seviyesi yeter — fine'a gerek yok), `POST_NOTIFICATIONS`. Konum tamamen opsiyonel (manuel şehir alternatifi var).

### Gizlilik & yasal
- **Gizlilik Politikası URL'si** (Play zorunlu çünkü konum/hesap verisi var). Senin ReBuildReBreak alanında veya basit bir sayfada barındırılabilir.
- **KVKK (Türkiye) + GDPR (AB) uyumu:** açık rıza, **veri minimizasyonu**, hesap silme, veri dışa aktarma. (Yukarıda Bölüm 13'te uygulandı.)
- **Play Data Safety formu:** konum (yalnızca uygulama işlevi için, paylaşılmıyor), hesap bilgisi (e-posta) beyan edilir.
- **Çocuk verisi:** Bölüm 7 sonundaki yaş kapısı uyarısı. Öneri: uygulamayı çocuklara *yönelik değil* konumla; küçük yaşta yalnızca yerel oyun, bulut için yetişkin onayı.
- **Reklam yok** (MVP) → reklam SDK izin/veri yükü yok; gizlilik formu sade kalır.

---

## 17. Play Store Hazırlığı ve Yayın

> **Güncel kurallar (Haziran 2026):**
> - **Hedef API:** Yeni uygulamalar şu an **Android 15 / API 35** hedeflemeli; **31 Ağustos 2026'dan itibaren yeni uygulamalar Android 16 / API 36 hedeflemek zorunda.** Sen muhtemelen o tarih civarı/sonrası yayınlayacağın için **`targetSdk = 36` (Android 16)** hedefle, güvenli ol. `minSdk = 24` (Android 7) önerilir (geniş kapsam + makul modernlik).
> - **AAB zorunlu:** Yeni uygulamalar **Android App Bundle (.aab)** ile yüklenir (tek APK değil). Play, Dynamic Delivery ile cihaza özel APK üretir.
> - **Play App Signing zorunlu:** upload key üretirsin, Google imzalamayı yönetir.
> - **Kapalı test kapısı (kişisel hesaplar için):** 13 Kasım 2023'ten **sonra** açılan **kişisel** geliştirici hesapları, production'a geçmeden önce **en az 12 opt-in test kullanıcısıyla 14 gün kesintisiz kapalı test** yapmak zorunda. **Organizasyon (şirket) hesapları muaf.** → Bu, takvimini etkiler; aşağıda not var.

### 17.1 Godot Android export ön koşulları (Faz 0'da kurulur)
- JDK (Godot 4.7'nin istediği sürüm — genelde JDK 17), Android SDK + Build Tools + Platform Tools, NDK (gerekirse).
- Godot Editor → Android export template'leri indir.
- Debug keystore ile ilk `.apk`/`.aab` build + gerçek cihazda çalıştır (USB debug). **Bu, "boş proje cihazda çalışıyor" doğrulaması Faz 0'ın çıktısıdır.**

### 17.2 Sürümleme & paket
- **Application ID:** ör. `com.rebuildrebreak.weatherling` (kendi alan/markanla; senin ürünün). Bir kez seçilir, değişmez.
- `versionCode` (artan tamsayı) + `versionName` (ör. `1.0.0`).
- 64-bit (arm64-v8a) + 32-bit; Godot AAB ile yönetir.

### 17.3 İmzalama
- Upload keystore üret (`keytool`), **güvenli sakla + yedekle** (kaybolursa güncelleme yükleyemezsin). `.gitignore`'da, repoya **asla** girmez.
- Play App Signing'e kaydol.

### 17.4 Mağaza listesi varlıkları
- **Uygulama ikonu** 512×512 (adaptive icon: foreground + background katmanları, tüm yoğunluklar).
- **Feature graphic** 1024×500.
- **Ekran görüntüleri:** en az 2 telefon (cozy anları gösteren — yağmurlu sahne, gece uyuyan yaratık, besleme); 7" ve 10" tablet opsiyonel ama önerilir.
- **Kısa açıklama** (80 karakter) + **tam açıklama** (≤4000). Tanıtım videosu opsiyonel (cozy fragman büyük artı).
- Uygulama adı, kategori (**Casual / Simulation** ya da "Lifestyle"), iletişim bilgisi.

### 17.5 Politika & uyum formları
- **İçerik derecelendirme** (IARC anketi) → büyük ihtimalle "Herkes/Everyone".
- **Data Safety** formu (Bölüm 16'ya göre doldur).
- **Gizlilik Politikası URL'si.**
- **Hedef kitle & içerik** (yaş grupları).
- **App access:** giriş gerektiren akışlar varsa **incelemeciye test hesabı** ver (yoksa red riski). Misafir mod bunu kısmen çözer.

### 17.6 Yayın yolu (release tracks)
```
Internal testing (kendi cihazların, hızlı)
        ▼
Closed testing  ← KİŞİSEL HESAP İSE: ≥12 test kullanıcısı, 14 gün kesintisiz
        ▼
(Production access başvurusu + 10 soruluk anket)
        ▼
Open testing (herkese açık beta, opsiyonel)
        ▼
Production (yayın)
```

> ⚠️ **Kapalı test kapısı hakkında dürüst tavsiye:** 12 test kullanıcısını **gerçek kişilerden** topla (arkadaş, aile, indie/cozy oyun toplulukları, r/AndroidGaming, Discord toplulukları). **Test kullanıcısı satan servislerden ve emülatör çiftliklerinden uzak dur** — Google bunları tespit ediyor ve **hesap kalıcı kapatma** riski var. Eğer mümkünse ve bunu ciddi bir iş yapacaksan, **organizasyon (şirket) hesabı** bu 12-kişi/14-gün kapısından muaftır; uzun vadede düşünülebilir. Bu 14 günü Faz 11–12 sürerken paralel başlatmak takvimi kısaltır.

### 17.7 Yayın öncesi son kontrol
- Pre-launch report (Play Console otomatik cihaz testi) incele.
- ANR/çökme izleme (Play Console vitals).
- Tüm izin gerekçeleri açık; gizlilik formu tutarlı.
- `RELEASE_CHECKLIST.md` (docs/) ile her sürümde tekrar.

---

## 18. iOS Hazırlığı (Gelecek)

Sen Apple developer hesabı ($99/yıl) aldığında:
- Godot iOS export (macOS + Xcode gerekir).
- **Sign in with Apple zorunlu** (Google girişi varsa). Supabase Apple OAuth.
- App Store varlıkları + **Privacy Nutrition Labels** (Data Safety'nin Apple karşılığı).
- TestFlight ile beta.
- Mimari zaten platform-bağımsız tasarlandığı için (Bölüm 3), iOS'a geçiş çoğunlukla export + auth + mağaza işi olur, kod yeniden yazımı değil.

---

## 19. Geliştirme Yol Haritası — Fazlar

Her faz Claude Code'a verilebilecek bağımsız bir iş paketidir. Format: **Amaç → Görevler (checkbox) → Definition of Done.** Sırayla ilerle; bir faz "Done" olmadan sonrakine geçme.

### Faz 0 — Kurulum & İskelet
**Amaç:** Boş ama doğru yapılandırılmış, Android'de çalışan proje iskeleti.
- [ ] Godot 4.7 stable kur; yeni proje (Compatibility renderer).
- [ ] Pixel-perfect project settings (stretch `canvas_items`, integer scale, snap to pixel).
- [ ] Klasör yapısını oluştur (Bölüm 4).
- [ ] `.gitignore` (Godot + keystore/imza/`.import` doğru kuralları); Git repo init.
- [ ] 15 autoload'un **boş iskeletleri** + `EventBus` sinyal listesi taslağı.
- [ ] `SceneManager` (yumuşak geçişli sahne yükleme) + boş Boot/Home sahneleri.
- [ ] i18n iskeleti (tr.po/en.po + Localization sarmalayıcı).
- [ ] **Android export kurulumu:** JDK/SDK/templates; debug `.aab`/`.apk` üret; **gerçek cihazda çalıştır.**
- **DoD:** Telefonda boş "Home" sahnesi açılıyor; commit'ler atılıyor; export pipeline çalışıyor.

### Faz 1 — Çekirdek Yaratık & Animasyon
**Amaç:** Ekranda yaşayan, dokunulabilen bir yaratık.
- [ ] `Creature` sahnesi + AnimationTree durum makinesi (idle/happy/sad/sleep/eat placeholder).
- [ ] Placeholder pixel sprite seti (tek evre yeter şimdilik).
- [ ] Idle "alive" hissi (nefes, göz kırpma); dokununca `pet_react` + kalp partikülü.
- [ ] Home sahnesine yerleştirme; temel kamera/çerçeve.
- **DoD:** Yaratık idle'da canlı duruyor, dokununca tepki veriyor.

### Faz 2 — Zaman & Gün-Gece
**Amaç:** Gerçek saate bağlı gün-gece + uyku.
- [ ] `TimeService`: yerel saat, faz hesabı (dawn/day/dusk/night), mevsim, ay evresi.
- [ ] Gün-gece ışık shader'ı + yıldız/ay gece katmanı.
- [ ] Yaratık gece uyur (sleep state); gündüz uyanır.
- [ ] `EventBus.time_phase_changed` entegrasyonu.
- **DoD:** Saate göre sahne ışığı değişiyor; gece yaratık uyuyor; ay evresi doğru.

### Faz 3 — Hava Durumu Entegrasyonu
**Amaç:** Gerçek yerel hava oyunda yansıyor.
- [ ] Konum izni (coarse) + manuel şehir fallback (geocoding).
- [ ] `WeatherService`: Open-Meteo GET, WMO→WeatherState eşleme, cache (TTL).
- [ ] Weather VFX (yağmur/kar/sis/şimşek/rüzgâr) + ıslaklık/birikme shader'ları (havuzlanmış partiküller).
- [ ] Sıcaklık modifiye → yaratık `cold`/`hot` davranışı.
- [ ] Çevrimdışı zarif düşüş (son veriyle çalış + rozet).
- **DoD:** Dışarıda yağmur varsa oyunda yağıyor; konum yoksa şehir seçilebiliyor; çevrimdışı çökmüyor.

### Faz 4 — İhtiyaçlar & Bakım (Tamagotchi çekirdeği)
**Amaç:** Besle/uyut/oyna/temizle döngüsü + offline hesap.
- [ ] `NeedsService`: 6 ihtiyaç, zamanla azalma, **offline geriye dönük hesap** (taban korumalı, ölüm yok).
- [ ] Yemek sistemi: `FoodItem` .tres'ler, besleme paneli, yeme animasyonu, envanter.
- [ ] Uyku/oyna/temizle/sev etkileşimleri.
- [ ] `MoodSystem` + diyalog baloncukları.
- [ ] `SaveService` (yerel şifreli kayıt + yükle).
- **DoD:** Tam bir bakım günü oynanabiliyor; uygulama kapatılıp açıldığında durum mantıklı; ihmal edilince küsüyor ama geri kazanılıyor.

### Faz 5 — Profil, Yaş & Yaşam Evreleri
**Amaç:** Onboarding + yaratığın kullanıcı yaşını yansıtması.
- [ ] Onboarding akışı (isim → yaş → [inanç] → [konum] → [giriş]).
- [ ] 7 `LifeStageConfig.tres` (Bölüm 7'deki tüm parametreler).
- [ ] `LifeStageService`: yaş → evre; ihtiyaç hızları, yemek tercihleri, diyalog tonu, skill dalları, özel olaylar evreye göre.
- [ ] Her evre için sprite seti + palet (önce 2-3 evre, sonra tamamı).
- [ ] Evreye özel `idle_dialogue` ve `request` diyalogları (TR/EN).
- **DoD:** Farklı yaş giren kullanıcı farklı yaratık/davranış/diyalog görüyor.

### Faz 6 — İnanç / Gelenek Sistemi
**Amaç:** Opsiyonel, saygılı manevi katman.
- [ ] `FaithService`: gelenek seçimi, namaz vakitleri (Aladhan + yerel hesap yedeği), kilise/Shabbat/aarti/meditasyon ritimleri.
- [ ] Ritüel animasyonu (`devotion` state) + ilgili dekor (ör. namaz köşesi).
- [ ] Opsiyonel nazik bildirim + Ayarlar'dan değiştir/kapat.
- [ ] Hassasiyet ilkelerinin (Bölüm 8) uygulanması (ceza yok, eşlik opsiyonel).
- **DoD:** Seçilen geleneğe göre yaratık ritüelini yapıyor; kullanıcı değiştirip kapatabiliyor; saygılı ve yargısız.

### Faz 7 — Skill Ağacı, Bond & Ekonomi
**Amaç:** Uzun vadeli gelişim ve süreklilik.
- [ ] `SkillNode` .tres'ler (yaşa göre dallar); skill tree UI (organik, pan/zoom).
- [ ] `BondSystem`: bakım/etkileşim → bond xp → level → açılan içerik.
- [ ] `EconomyService`: coin kazanma/harcama; `Shop` paneli (kozmetik/dekor).
- [ ] `Wardrobe` paneli (kozmetik giydirme, ev dekoru).
- **DoD:** Oyuncu skill açıyor, bond büyüyor, mağazadan kozmetik alıp giydiriyor; ilerleme kaydoluyor.

### Faz 8 — Kimlik Doğrulama & Bulut Kayıt
**Amaç:** Hesap + güvenli bulut senkron.
- [ ] Supabase projesi + tablolar + **RLS** (Bölüm 5.3).
- [ ] `AuthService`: misafir/anonim, e-posta+şifre/magic link, **Google (OAuth deep-link)**.
- [ ] Bulut senkron (local-first, last-write-wins); hesap bağlama (misafir→hesap).
- [ ] Hesap silme + veri dışa aktarma (KVKK/GDPR).
- **DoD:** Giriş yapılıyor, ilerleme buluta yedekleniyor, başka cihazda geri yükleniyor, RLS test edildi (başkasının verisi erişilemez).

### Faz 9 — Bildirimler
**Amaç:** Nazik, kontrollü hatırlatmalar.
- [ ] Yerel bildirim eklentisi entegrasyonu; `NotificationService`.
- [ ] `POST_NOTIFICATIONS` izin akışı (Android 13+).
- [ ] Vakit / ihtiyaç / hava olayı bildirimleri; Ayarlar'dan kategori bazlı açma/kapama.
- **DoD:** Bildirimler doğru zamanlanıyor; izin reddi sorunsuz; spam yok; her kategori kontrol edilebiliyor.

### Faz 10 — UI/UX Cilası & Ses
**Amaç:** "Premium cozy" hissi.
- [ ] Tüm menüler/paneller/HUD nihai tasarım; yumuşak geçişler, "juice".
- [ ] Erişilebilirlik (hareket azaltma, metin boyutu, kontrast, renk körlüğü).
- [ ] TR/EN tam lokalizasyon kontrolü.
- [ ] Ses: müzik (zaman/mood), ortam (havaya bağlı), SFX, ses ayarları.
- **DoD:** Uygulama baştan sona cilalı ve tutarlı; sessize alınabiliyor; iki dilde eksiksiz.

### Faz 11 — Performans & Güvenlik Sertleştirme
**Amaç:** Pil dostu, güvenli, akıcı.
- [ ] `low_processor_usage_mode`, FPS/arka plan yönetimi, partikül havuzu/atlas doğrulama.
- [ ] Profiling (CPU/GPU/bellek), orphan node temizliği, düşük cihaz testi.
- [ ] Şifreli kayıt + güvenli token + HTTPS + izin minimizasyonu doğrulaması; RLS testi.
- [ ] Gizlilik kontrol listesi.
- **DoD:** Ucuz cihazda akıcı + düşük ısı; güvenlik kontrolleri geçti; sızıntı yok.

### Faz 12 — Play Store Hazırlığı & Yayın
**Amaç:** Mağazada yayın.
- [ ] Application ID, sürümleme; upload keystore + Play App Signing; release AAB.
- [ ] Mağaza listesi varlıkları (ikon, feature graphic, ekran görüntüleri, açıklamalar, video).
- [ ] İçerik derecelendirme, Data Safety, gizlilik politikası, hedef kitle, test hesabı.
- [ ] Internal → **Closed testing (≥12 kişi / 14 gün, kişisel hesapsa)** → production başvuru/anket → (open) → production.
- [ ] Pre-launch report + vitals incele.
- **DoD:** Uygulama production'da yayında; çökme/ANR temiz; gizlilik tutarlı.

### Faz 13 (Gelecek) — iOS & Genişleme
- [ ] iOS export + Sign in with Apple + App Store.
- [ ] Ana ekran **widget**'ı (Android'de native modül gerekir — Godot tek başına widget çizemez; ayrı RemoteViews bileşeni; Vakti projesindeki widget deneyimin burada işe yarar).
- [ ] Mini oyunlar, sosyal (arkadaş yaratıkları ziyaret), gelişmiş sezonsal etkinlikler, push (FCM).

---

## 20. Git / Repo Konvansiyonları

> Bu senin ürünün. Repo ve kod **tamamen senin sesinle** — jenerik "AI tarafından üretildi" izi, boilerplate yorum veya yapay imza **yok.**

- **Yazarlık:** commit author = sen; README/LICENSE/meta veriler senin markanla.
- **Yorumlar:** doğal, insan-yazımı; sadece *neden*i açıklayan, gerektiği yerde yorum (her satıra değil). TR veya EN tutarlı tek dil.
- **Commit stili:** Conventional Commits ama sade ve insani:
  - `feat: add rain particle pooling`
  - `fix: clamp offline hunger decay`
  - `refactor: extract mood calc from needs service`
  - `chore: bump export target to API 36`
- **Branch:** `main` (stabil) + `dev` + özellik dalları `feat/weather-service`, `feat/life-stages`. Faz başına dal mantıklı.
- **`.gitignore`:** Godot `.import/`, `.godot/`, export çıktıları, **`*.keystore`/`*.jks`/imza dosyaları**, `export_credentials`, Supabase service-role anahtarları (asla repoda).
- **Sırlar:** anon key gibi public değerler config'te olabilir; **service-role / özel anahtarlar asla** repoya girmez (env / Supabase tarafında).
- **README:** kısa, net; ne olduğu, nasıl çalıştırılacağı (Godot sürümü, export ön koşulları). Abartısız, senin tonun.

---

## 21. Test Stratejisi

- **Birim testleri (GUT — Godot Unit Test, `addons/gut`):** `NeedsService` decay/offline hesap, `TimeService` faz/mevsim, `WeatherService` WMO eşleme, `LifeStageService` yaş→evre, ekonomi işlemleri.
- **Manuel oynanış test matrisi:** her yaş evresi, her hava durumu (cihaz saatini/konumu sahteleyerek), her inanç seçeneği, çevrimdışı senaryo, hesap bağlama/silme.
- **Cihaz matrisi:** en az 1 düşük, 1 orta, 1 yüksek Android cihaz; farklı ekran oranları.
- **Edge case'ler:** saat dilimi değişimi, gece yarısı geçişi, mevsim sınırı, yaş sınırı (12↔13, 74↔75), izin reddi, internet kesintisi, uygulama uzun süre kapalı kalması.
- **Play pre-launch report** otomatik cihaz testlerini kullan.

---

## 22. Ek Özellik Fikirleri

Fikrin zaten güçlü; bunlar onu zenginleştiren, sütunlara hizmet eden eklemeler (öncelik sırasıyla):

**Yüksek değer / MVP'ye yakın**
- 📓 **Günlük (Journal):** Yaratık her gün havayı/anı kısa, sevimli notlarla yazar ("Bugün yağmur vardı, pencereden izledim"). Nostalji + bağ.
- 📸 **Fotoğraf modu / paylaşılabilir kare:** Cozy anların ekran görüntüsü (yağmurda uyuyan yaratık). Organik pazarlama döngüsü.
- 🏆 **Başarımlar & koleksiyon:** Görülen hava türleri, mevsimler, kilometre taşları. ("İlk karını gördün", "100 gün birlikte").
- 🔥 **Nazik seri (streak):** Günlük uğrama serisi — ama bozulunca cezalandırmayan, teşvik eden.

**Orta vade (faz 2)**
- 📱 **Ana ekran widget'ı:** Yaratık + gerçek hava, ana ekranda. (Android'de native modül gerekir — Vakti deneyimin avantaj.)
- 🎮 **Hava temalı mini oyunlar:** Yağmur damlası yakalama, kar topu, yıldız birleştirme — coin kazandırır.
- 🌌 **Astronomik olaylar:** Meteor yağmuru, dolunay gecesi özel gösterileri.
- 🎃 **Gelişmiş sezonsal etkinlikler:** Tatiller, gündönümleri, kültürel günler (kullanıcının inancına/konumuna duyarlı).

**Uzun vade**
- 👥 **Sosyal:** Arkadaşın yaratığını ziyaret, hediye gönderme (gizlilik-bilinçli).
- 🌍 **"Dünyada hava" hissi:** Arkadaşının şehrinde kar varsa onun yaratığı karda — paylaşılan gerçeklik.
- 💝 **Etik monetizasyon (opsiyonel):** Sadece kozmetik IAP veya "geliştiriciye destek" paketi (Play Billing eklentisi). **Asla** pay-to-win, asla agresif reklam. Cozy kitlesi bunu cezalandırır.

---

## 23. Senin Onayını Bekleyen Açık Kararlar

Plan eksiksiz ilerleyebilir; ama şu birkaç noktada senin tercihin yönü netleştirir (cevaplamazsan **kalın yazılı önerimle** ilerlerim):

1. **Yaratık yaşlanır mı?** **Öneri: Hayır — kullanıcının evresinde doğar ve kalır (ayna ilkesi); ilerleme bond/skill ile.** İstersen opsiyonel "Yaşam Yolculuğu" modu faz 2'de eklenir.
2. **Backend:** **Öneri: Supabase** (auth + bulut kayıt + RLS). Onaylarsan Faz 8'i ona göre kurarım; istemezsen "yalnızca yerel kayıt" + sonradan eklenebilir mimariyle giderim.
3. **Hava sağlayıcı:** **Öneri: Open-Meteo (anahtarsız, ücretsiz, gizlilik dostu).** Premium veri istersen anahtarlı sağlayıcı + Supabase proxy'ye geçeriz.
4. **Ölüm mekaniği:** **Öneri: Ölüm yok, "küsme + geri kazanma".** Klasik Tamagotchi ölümü istersen ekleyebiliriz ama cozy hedefe aykırı.
5. **Application ID / marka:** `com.rebuildrebreak.weatherling` uygun mu, yoksa Weatherling'e ayrı bir alan/marka mı? (Ürün adı "Weatherling" kalsın mı, alternatif marka ismi ister misin?)
6. **Play hesabı türü:** **Kişisel mi, organizasyon mu?** Kişiselse 12-kişi/14-gün kapalı test kapısı geçerli (takvimi etkiler). Bunu işe dönüştüreceksen organizasyon hesabı muafiyeti düşünülebilir.
7. **Minimum kullanıcı yaşı / çocuk verisi yaklaşımı:** "Her yaşa uygun ama çocuklara yönelik değil; küçük yaşta yalnızca yerel oyun" önerisini onaylıyor musun? (Yasal etkisi var.)
8. **İlk lansman dili:** TR + EN baştan (önerim) mi, yoksa önce sadece TR mi?

---

### Sonraki adım

Bu planı onayladığında, **Faz 0**'dan başlayıp her fazı Claude Code'a ayrı bir iş paketi olarak verebilirsin. İstersen her fazı kendi `docs/phases/FAZ_0X.md` dosyasına bölerek (her birinde detaylı görev listesi + kabul kriteri + ilgili dosya yolları) "Claude Code'a yapıştır-çalıştır" formatına da getirebilirim. Yön senin.
