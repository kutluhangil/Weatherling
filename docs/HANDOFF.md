# Faz 0 — Devir / Senin Yapacakların

Kod iskeleti hazır. Aşağıdakiler **senin makinende, etkileşimli** adımlar (Godot kurulu
değil, otomatikleştirilemez). Bunları yapınca Faz 0 DoD tamamlanır.

## 1. Godot 4.7 kur ve projeyi aç

- [godotengine.org](https://godotengine.org) → **Godot 4.7 stable, standart sürüm** (.NET değil).
- Editörde `project.godot`'u aç.
- İlk açılışta Godot `.po` çevirilerini ve `icon.svg`'yi import eder, `.godot/` üretir
  (bu klasör `.gitignore`'da).

## 2. Masaüstünde çalıştır (hızlı doğrulama)

- **F5** ile çalıştır. Beklenen: kısa "Weatherling" splash → fade → Home ekranı,
  yaratık adı / faz / mevsim / ay / hava bilgisini gösteren debug HUD.
- Hata çıkarsa: büyük olasılıkla bir autoload script'inde; **Debugger** panelindeki ilk
  hatayı düzelt (Godot olmadan derleyemediğim için olası bir-iki sözdizimi/ API farkı).

## 3. Android export

- Editor → **Manage Export Templates** → 4.7 şablonlarını indir.
- Project → **Install Android Build Template**.
- ⚠️ **JDK 17 gerekli.** Makinede JDK 25 var; Gradle build 17 ister.
  `JAVA_HOME`'u 17'ye ayarla (veya 17 kur). Editör Settings → Export → Android'de
  SDK/JDK yollarını göster.
- Project → **Export** → Android preset (`export_presets.cfg` hazır) → debug `.apk`/`.aab` üret.
- Telefonu USB hata ayıklama ile bağla → **Run on Android** veya `adb install`.

## 4. Faz 0 DoD ✅

- [ ] Telefonda boş "Home" sahnesi açılıyor.
- [ ] Export pipeline çalışıyor (cihazda APK koşuyor).
- [ ] İlk commit atıldı (öneri aşağıda).

## İlk commit (öneri)

`main` üstündeyiz; istersen önce dal aç:

```
git checkout -b dev
git add -A
git commit -m "chore: scaffold project skeleton (Faz 0)"
```

## Neyin "bonus" geldiği (sonraki fazlar için saf çekirdek hazır)

İskelet ötesinde şu saf, test-edilebilir mantık zaten yazıldı (bkz. ARCHITECTURE.md):
`stage_for_age`, `state_for_wmo`, `phase_for`/`season_for`/ay evresi, offline `decayed`,
`level_for_xp`. Faz 2–5'te bunların üstüne kurulur.

## Faz 1 — Çekirdek Yaratık & Animasyon ✅ (kod hazır)

F5'te Home artık ekranda bir yaratık gösterir:
- **Nefes** (prosedürel squash & stretch) + rastgele **göz kırpma** → "canlı" idle.
- **Dokun/tıkla** → squash tepkisi + kalp partikülleri; mutluluk/sosyal artar, bond xp gelir
  (HUD'da görünür). Manuel hit-test (`touch_radius`), root viewport picking'e bağımlı değil.
- **Gece** (TimeService faz=night) → yaratık uyur (yavaş nefes, göz kırpmaz). Gündüz uyanır.
- Placeholder gövde SVG (`art/creature/placeholder/`); Faz 5'te evreye göre piksel sprite
  seti gelecek — `Creature.set_state()` API'si aynı kalır.

> Not: Godot'ta ilk açılışta `.svg`'ler texture'a import edilir (`.svg.import` üretilir).

## Faz 2 — Zaman & Gün-Gece ✅ (kod hazır)

- **Gün-gece ışığı** — `CanvasModulate` (DayNight) tüm sahneyi faza göre tonlar:
  dawn ılık · day beyaz · dusk altın · night dim mavi (1.5s tween). HUD ayrı layer, okunur.
- **Gece gökyüzü** — `scenes/weather_vfx/sky` : yıldız alanı (tek seferlik çizim, pil dostu)
  + **doğru ay evresi** (`shaders/moon.gdshader`, küresel-normal terminator; yeniay→dolunay→
  son dördün hepsi doğru). Gündüz alpha=0 ile kaybolur.
- Gece yaratık zaten uyuyor (Faz 1). DoD karşılandı.

> F5 testi: cihaz saatini değiştirip (veya gece/gündüz açıp) ışık + gökyüzü + uyku değişimini
> gör. Ay evresi gerçek tarihe göre.

## Faz 3–12 — kod hazır (özet)

- **Faz 3 Hava+VFX:** Open-Meteo geocoding (manuel şehir) + fetch, sunrise/sunset→TimeService,
  yağmur/kar (CPUParticles), sis (shader), şimşek flash, temp→creature cold/hot. GPS coarse = plugin TODO.
- **Faz 4 İhtiyaçlar:** 6 ihtiyaç + offline catch-up + canlı decay, 5 yemek (.tres), besleme paneli,
  bakım barı (besle/oyna/temizle/uyut), mood + ihtiyaç barları + konuşma baloncuğu.
- **Faz 5 Evreler:** onboarding (isim/yaş/inanç/şehir), 7 LifeStageConfig (.tres), yaş→evre,
  evre palet/ölçek, evreye özel diyalog (tr/en). Boot: kayıt yoksa onboarding.
- **Faz 6 İnanç:** FaithService (namaz vakti yerel hesap + ritim zamanlayıcı), 7 profil (.tres),
  devotion state, inanç paneli (değiştir/kapat). Ceza yok.
- **Faz 7 Skill/Ekonomi:** 6 skill + 5 kozmetik (.tres), skill/mağaza/gardırop/menü panelleri,
  coin kazanç (bakım/bond), bond level. Kozmetik görsel uygulaması → Faz 10 (gerçek sprite).
- **Faz 8 Auth/Bulut:** Supabase SQL+RLS (`supabase/migrations/0001_init.sql`), AuthService
  (email/magic link REST), bulut sync (last-write-wins), hesap sil/dışa aktar, hesap paneli.
  **Provision sana kalır** → `docs/SUPABASE.md` (URL+anon key doldur). Google OAuth = TODO.
- **Faz 9 Bildirim:** NotificationService (OS izin + eklenti arayüzü), vakit/günlük zamanlama.
  Android notif **plugin binary üretemem** → arayüz hazır, eklenti `addons/`'a eklenince çalışır.
- **Faz 10 UI/Ses:** cozy theme (`theme.tres`), ayarlar paneli (ses/a11y/bildirim/dil/konum),
  reduced-motion, ses seçim+fade mantığı + SFX wiring. **Ses dosyaları (.ogg) sana kalır** (`audio/`).
- **Faz 11 Perf/Güvenlik:** max_fps + odak-dışı düşürme, partikül ölçek; `docs/SECURITY.md` checklist.
  Token/kayıt anahtarı Keystore'a taşıma = TODO.
- **Faz 12 Play:** `docs/STORE_LISTING.md` (TR+EN metin), `docs/PRIVACY_POLICY.md` taslak,
  `export_presets.cfg` + `RELEASE_CHECKLIST.md`. İmza/yükleme/kapalı test = sen.

## Senin elinle bitecekler (özet)
1. Godot 4.7 kur → `project.godot` aç → **F5** (ilk derlemede olası 1-2 GDScript/API farkını düzelt).
2. Android: JDK17 + SDK + export template → `.aab` → cihazda dene.
3. (Ops.) Supabase provision + `auth_service.gd`'ye URL/anon key.
4. (Ops.) Ses `.ogg` ve gerçek sprite/feature görselleri ekle.
5. Android bildirim eklentisi `addons/`'a ekle (Faz 9 çalışsın).
6. Gizlilik politikasını barındır, keystore üret, mağaza varlıkları, kapalı test (≥12/14g kişisel hesap).

## Faz 13 (gelecek)
iOS export + Sign in with Apple, ana ekran widget'ı (native modül), mini oyunlar, push (FCM).
