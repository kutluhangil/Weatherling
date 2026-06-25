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

## Sonraki adım

Faz 1 — Çekirdek Yaratık & Animasyon: `scenes/creature/` + AnimationTree state machine,
placeholder sprite, idle "alive" hissi, dokunma → `pet_react`. Home'daki `CreatureAnchor`
düğümü hazır bekliyor.
