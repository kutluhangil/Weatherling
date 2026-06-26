# Weatherling — "Pixel-Prime" Görsel & Sistem Revizyonu (Tasarım Spec'i)

Tarih: 2026-06-27
Durum: Onaylandı (kullanıcı), implementasyon planı bekliyor.
Kaynak tasarım: `stitch_retro_digital_soul/` (DESIGN.md + 10 mockup + 13 PNG).

## 1. Amaç ve karar özeti

Mevcut jenerik/sönük UI, DESIGN.md'deki **"Premium Retro Pixel Art / Atmospheric Coziness"**
yönüne taşınır. Mockup'lar görsel hedeftir; gerçek-hava kimliği korunur.

Kullanıcı kararları (brainstorming):
- **Yön:** Statik illüstrasyon. Dinamik weather VFX + gün-gece shader + parallax sky motoru
  emekli edilir; **WeatherService + TimeService verisi KALIR**, hangi illüstrasyonun
  gösterileceğini seçer.
- **Sahne:** Hava (7 durum) × gün-zamanı (4 faz) illüstrasyon seçer.
- **Asset:** Kullanıcı tüm raster sanatı üretir. Kod, dosya yoksa düz-renk **fallback** ile
  çalışır (build asset'i beklemez).
- **Kapsam:** Tüm yeni sistemler dahil (mini-oyun, oda dekor, görsel skill-tree, XP).
- **HUD:** 6 ihtiyacın hepsi gösterilir.
- **Faith:** Tamamen kaldırılır (UI + servis + onboarding adımı). `CreatureState.faith`
  alanı save geri-uyumu için okunur kalır, kullanılmaz.
- **Cooldown:** Yok (cozy; master plan "ceza yok").
- **Nav:** `Home · Oyna · [FAB Etkileşim] · Mağaza · Menü`.
- **Mini-oyun:** 3'ü de (sırayla; önce Hava Avcısı). Enerji harcar, 0'da ceza yok.
- **Oda dekor:** Serbest sürükle-bırak.
- **Skill tree:** Mevcut 6 dal (.tres korunur) → görsel node-graph.
- **Creature sprite:** Evre başına tek idle poz (7 adet). Mood = tint/speech bubble ile;
  per-mood ayrı sprite sonraki opsiyon (kapsamı sınırlamak için).

## 2. Görsel temel

### 2.1 Tema (`theme.tres` yeniden yazılır)
Palet DESIGN.md birebir (kısaltma):
`surface=#1d0c24, deep-plum=#1A0F1F, surface-container=#2b1931, dusk-amber=#E87C3E,
horizon-glow=#FFC078, primary-container=#ff9d5c, on-surface=#f6d9fa, secondary-container=#622f91,
status-hunger=#FF4D6D, status-energy=#4CC9F0, status-love=#F72585, tertiary=#f8ca60`.

### 2.2 Fontlar (`art/fonts/`)
- Space Grotesk (headline/display), Hanken Grotesk (body), JetBrains Mono (label/sayı). OFL.
- Tema font dosyaları yoksa Godot default font'a düşer (build bloke olmaz).

### 2.3 Bileşen stilleri (kod + theme)
- **9-patch panel/buton:** StyleBoxFlat (köşe 4–8px, amber kenar, bevel highlight/lowlight).
  Gerçek 9-patch PNG opsiyonel (asset gelince `StyleBoxTexture`'a geçilebilir).
- **Chunky buton press:** basınca 2px aşağı + highlight kaybı.
- **Status bar:** koyu track + doygun glow fill + üst 1/3 "shine" çizgisi.
- **Carved input, FAB (dairesel), chip/label.**
- **İkonlar:** gerekli ikonlar **SVG olarak repo'da üretilir** (Material Symbols font
  bağımlılığı yok). `art/ui/icons/{name}.svg`.

### 2.4 Juice
Dokununca squash (mevcut), partikül burst, soft glow. Reduced-motion'a saygı (mevcut).

## 3. Asset manifesti (kullanıcı üretir)

```
art/backgrounds/{state}_{phase}.png    28 adet, opak, portre (öneri 1080×1920)
    state ∈ {clear,clouds,fog,rain,snow,thunder,windy}
    phase ∈ {dawn,day,dusk,night}
art/creature/{stage}.png               7 adet, ŞEFFAF (öneri 512×512)
    stage ∈ {filiz,tomurcuk,cicek,meyve,hasat,kok,cinar}
art/items/furniture/{id}.png           şeffaf eşya ikonları (oda dekor)
art/fonts/{SpaceGrotesk,HankenGrotesk,JetBrainsMono}-*.ttf
```
Eksik dosya → fallback: arka plan düz renk (palet), creature mevcut placeholder SVG,
font default. `art/ui/store/png/` gibi `art/backgrounds`, `art/creature` üretilen büyük
PNG'ler için `.gitignore` değerlendirilir (kaynak boyutu).

## 4. Sahne / arka plan sistemi

**SceneBackground** (yeni node, Home + ilgili ekranlarda):
- Girdi: `WeatherService.state` (int) + `TimeService.get_phase()` (dawn/day/dusk/night).
- `art/backgrounds/{state}_{phase}.png` yükle (threaded), yoksa palet düz renk.
- `EventBus.weather_changed` / `time_phase_changed` → çapraz geçiş (fade).
- Creature sprite ayrı katmanda, üstte; evreye göre `art/creature/{stage}.png`.

**Emekli edilen:** `scenes/weather_vfx/*`, `scenes/weather_vfx/sky.*`, `day_night.gd`,
`shaders/fog.gdshader`, `shaders/moon.gdshader`. `WeatherService`/`TimeService` **kalır**
(veri + journal/achievements/needs mood bağımlılıkları).

## 5. Ekranlar

### 5.1 Home
- Z0 SceneBackground (illüstrasyon) · Z1 creature sprite (+gölge/yansıma) · Z2 HUD/paneller.
- Üst HUD: weather badge (ikon + "Rainy 18°C"), coin rozeti, Level+XP rozeti, **6 ihtiyaç barı**.
- Speech bubble (mevcut speech_bubble restyle).
- Alt: bottom-nav + ortada FAB.

### 5.2 Bottom nav + FAB (yeni `bottom_nav` bileşeni)
- Sekmeler: Home, Oyna (mini-oyun ekranı), Mağaza, Menü.
- **FAB (orta) = Etkileşim drawer:** besle/oyna/uyut/temizle bento (NeedsService.apply_care).
  Cooldown yok. Hijyen/Sağlık/Sosyal değerleri burada da görünür.
- Menü = skills(graph), journal, achievements, wardrobe, ayarlar, hesap. (Faith YOK.)

### 5.3 Onboarding
- Yumurta çatlama + filiz, carved isim input, chunky "BAŞLA".
- Adımlar: isim → yaş → konum(opsiyonel) → giriş(opsiyonel). **Faith adımı kaldırılır.**

### 5.4 Paneller
feed, shop, wardrobe, journal, achievements, settings, menu → 9-patch temaya geçer
(içerik mantığı aynı). panel_faith **silinir**.

## 6. Yeni sistemler

### 6.1 Level / XP
- `bond_level` (Level) + `bond_xp` (bara). Bakım + mini-oyun XP verir (mevcut `_gain_bond`).
- HUD rozeti: "LVL n" + ilerleme barı. Yeni servis gerekmez; eşik tablosu eklenir.

### 6.2 Oyna ekranı + mini-oyunlar (`scenes/minigames/`)
- Liste/kart ekranı (3 oyun). Build sırası: **Hava Avcısı → Yıldız Birleştirme → Ritim Ormanı**.
- Ortak çatı: `MiniGame` taban (başlat, skor, bitir, ödül). Enerji düşür (`NeedsService`),
  0'da ceza yok ("dinlenmeli" uyarısı). Coin + high-score `CreatureState.stats` altında.
- **Hava Avcısı:** düşen hava tanesi (mevcut WeatherState temalı) yakala; süre/skor.

### 6.3 Oda dekor (serbest sürükle-bırak)
- Mağaza → mobilya satın al (EconomyService). Yerleştirme: sürükle, bırak, katman sırası.
- Kayıt: `CreatureState.home_decor = { item_id: {x,y,z,...} }`.
- Dokunmatik: drag threshold, snap opsiyonel, çakışma serbest. Reduced-motion'da sade.

### 6.4 Skill tree (görsel node-graph)
- Mevcut `data/skills/*.tres` + `skill_service` korunur.
- `panel_skills` → node-graph görseli: node'lar (kilitli/açık/glow), bağlantı çizgileri,
  evreye göre dal filtresi (mevcut mantık). Satın al = mevcut `SkillService.unlock`.

## 7. Kaldırma / migrasyon

- **Faith:** `project.godot`'tan `FaithService` autoload çıkar; `faith_service.gd`,
  `panel_faith/*`, `data/faiths/*` (opsiyonel sil), onboarding faith adımı, `notify/faith`,
  `creature.gd` devotion handler, `EventBus.devotion_time` kullanımı kaldırılır.
  `CreatureState.faith` PROPS'ta kalır (save geri-uyum), default "none".
- **Weather VFX:** §4'teki node/shader'lar silinir; Home sahne ağacı SceneBackground'a geçer.
- Save şeması değişmez (alanlar korunur) → migrasyon gerekmez; `home_decor` formatı
  {id→pos} olarak netleşir (eski boş dict uyumlu).

## 8. Korunan
Needs (6), SaveService (device-key AES), JournalService, AchievementService, localization
(TR+EN; ACH_/JOURNAL_ anahtarları), low_processor/FPS tiering, hud_safe_area, device_pass.

## 9. Test
- Saf/yeni mantık `tests/run_tests.gd`'ye eklenir: XP eşik fonksiyonu, mini-oyun skor→ödül
  saf hesabı, SceneBackground bg-anahtar seçimi (state×phase → path), oda-dekor
  serialize/deserialize round-trip.
- Mevcut testler (weather/needs/journal/achievements/device_pass) korunur. CI aynı.

## 10. Build sırası (modüller)
- **F0** Tema + font + 9-patch + ikon SVG'leri + fallback altyapısı.
- **F1** Faith kaldırma + SceneBackground (weather VFX emekli), data korunur.
- **F2** HUD restyle (6 bar + weather/coin/XP rozet) + bottom-nav + FAB + etkileşim drawer.
- **F3** Onboarding reskin (yumurta/filiz, faith adımı yok).
- **F4** Mevcut panelleri giydir (feed/shop/wardrobe/journal/achievements/settings/menu).
- **F5** Yeni sistemler: XP wiring → mini-oyunlar (Hava Avcısı→diğerleri) → oda dekor →
  skill graph.
- **F6** Asset slotlama (kullanıcı PNG/font verdikçe) + juice/polish.

Her modül kendi commit/testiyle; F0→F1→F2 sırası bağlayıcı (sonrası gevşek bağlı).

## 11. Riskler / açık uçlar
- 28 bg + 7 sprite + font üretimi kullanıcıda; gecikirse fallback ile yürür.
- Serbest sürükle-bırak dokunmatik hassasiyeti (drag vs tap) dikkat ister.
- Mini-oyunlar 3 ayrı küçük proje; F5 en uzun modül.
- Level eşik eğrisi denge gerektirir (oynanışta ayarlanır).
