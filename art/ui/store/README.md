# Store görselleri — kaynaklar ve export

SVG kaynaklar burada. PNG'ler **commit edilmez** (üret + Console'a yükle / export_presets'e bağla).

## Kaynak SVG'ler
| Dosya | Amaç |
|-------|------|
| `icon_background.svg` (432) | Adaptive icon arka plan katmanı |
| `icon_foreground.svg` (432, şeffaf) | Adaptive icon ön plan katmanı |
| `icon_monochrome.svg` (432) | Android 13+ temalı ikon katmanı |
| `icon_play_512.svg` | Play listeleme ikonu (kompozit) |
| `feature_graphic.svg` (1024×500) | Play feature graphic |

## SVG → PNG (herhangi biri)
```sh
# rsvg-convert (brew install librsvg)
rsvg-convert -w 512  -h 512  icon_play_512.svg     -o icon_512.png
rsvg-convert -w 432  -h 432  icon_foreground.svg   -o ic_fg_432.png
rsvg-convert -w 432  -h 432  icon_background.svg   -o ic_bg_432.png
rsvg-convert -w 432  -h 432  icon_monochrome.svg   -o ic_mono_432.png
rsvg-convert -w 192  -h 192  icon_play_512.svg     -o ic_launcher_192.png
rsvg-convert -w 1024 -h 500  feature_graphic.svg   -o feature_1024x500.png

# veya Inkscape:  inkscape --export-type=png -w 512 icon_play_512.svg
```

## Nereye gider
**Play Console → Store listing:**
- App icon: `icon_512.png` (512×512)
- Feature graphic: `feature_1024x500.png` (1024×500)
- Phone screenshots: ≥2 adet, 1080×1920 portre — uygulamadan yakala
  (önerilen kareler: yağmurlu sahne, gece uyuyan yaratık, besleme, Günlük paneli).

**Godot `export_presets.cfg` (preset.0.options) launcher_icons — PNG'leri `res://` altına koy:**
```
launcher_icons/main_192x192="res://art/ui/store/png/ic_launcher_192.png"
launcher_icons/adaptive_foreground_432x432="res://art/ui/store/png/ic_fg_432.png"
launcher_icons/adaptive_background_432x432="res://art/ui/store/png/ic_bg_432.png"
launcher_icons/adaptive_monochrome_432x432="res://art/ui/store/png/ic_mono_432.png"
```
> Boş bırakılırsa Godot varsayılan ikonu kullanır. Yol verip dosya yoksa export HATA verir —
> önce PNG'leri üret, sonra yolları doldur.

## Notlar
- Adaptive ön plan: anahtar görsel merkezdeki **güvenli bölge** (~264px daire) içinde tutuldu;
  launcher maskeleri (daire/squircle) kırpsa da yaratık görünür kalır.
- Feature graphic'te kritik metin kenarlardan uzak (Play bindirme/karartma yapabilir).
- Renkler `project.godot` default_clear_color (#1b1e2e) ve gün-gece paletiyle uyumlu.
