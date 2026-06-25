# Weatherling

Senin gerçek havanda, gerçek saatinde ve mevsiminde yaşayan minik bir piksel yoldaş.
Cozy, sakin, "yaşayan" bir cep dünyası — Tamagotchi'nin sıcaklığı, modern bir his.

Pencerende yağmur varsa, onun da üstüne yağar. Senin gecende uyur. Yaşını yansıtır.

## Teknik

- **Motor:** Godot 4.7 stable (4.6 ile uyumlu kalır)
- **Renderer:** Compatibility (OpenGL ES 3.0) — en geniş Android desteği, en düşük pil/ısı
- **Dil:** GDScript
- **Hedef:** Android (Google Play) → sonra iOS
- **Mimari:** Autoload singleton + sinyal tabanlı, data-driven (bkz. `docs/ARCHITECTURE.md`)

## Çalıştırma

1. [Godot 4.7 stable](https://godotengine.org) (standart sürüm, .NET değil) indir.
2. Editörde `project.godot`'u aç.
3. F5 ile çalıştır. Açılış sahnesi: `scenes/boot/boot.tscn`.

## Android export (özet)

- JDK 17, Android SDK + Build Tools + Platform Tools kurulu olmalı.
- Editör → **Project → Install Android Build Template**, sonra export template'leri indir.
- Debug keystore ile `.aab`/`.apk` üret, USB hata ayıklamayla gerçek cihazda çalıştır.
- Detay: `docs/RELEASE_CHECKLIST.md`.

## Yol haritası

Faz faz inşa ediliyor (bkz. `WEATHERLING_MASTER_PLAN.md`, Bölüm 19).
Şu an: **Faz 0 — Kurulum & İskelet.**
