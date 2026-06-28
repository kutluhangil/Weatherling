# Weatherling — Görsel Üretim Rehberi (Prompt + Dosya Adı + Klasör)

Kod bu dosyaları otomatik tüketir (fallback → gerçek görsel). Üret → ilgili klasöre at → oyun oturur.
Tüm görseller **aynı stil** olsun diye her promptun başına ŞU ÖN-EKİ koy:

> **STYLE PREFIX (her prompta ekle):**
> `Premium high-fidelity 16-bit pixel art, cozy atmospheric JRPG aesthetic, hand-painted anti-aliasing, rich dusk palette (deep plum #1A0F1F, plum #1d0c24, dusk amber #E87C3E, horizon glow #FFC078, soft purples and golden orange), cinematic atmospheric lighting, no text, no UI, no watermark.`

Araç önerisi: Stitch / Midjourney / SDXL / Nano Banana. Üretimden sonra arka planı şeffaf
gereken dosyalarda PNG-alpha olarak dışa aktar.

---

## 1) ARKA PLANLAR — `art/backgrounds/`  (28 adet, OPAK, portre 1080×1920)

Ortam: önden görünen küçük orman açıklığı; **merkez-alt boş** (yaratık orada duracak); katmanlı
ağaçlar; karakter YOK. Dosya adı: `{hava}_{zaman}.png`.

**Temel sahne (prefix'ten sonra ekle):**
`a small forest clearing seen from the front, empty center-bottom ground for a character to stand, layered parallax trees, portrait 9:16, no characters.`

**ZAMAN ek cümlesi (4):**
- `dawn` → `soft pink-orange dawn light, low sun, gentle morning mist, pastel sky`
- `day` → `bright clear daylight, vivid greens, warm sun rays through the leaves`
- `dusk` → `golden-hour sunset, long warm shadows, amber and purple sky`
- `night` → `deep indigo night, starry sky with a visible moon, cool blue tones, soft bioluminescent glows`

**HAVA ek cümlesi (7):**
- `clear` → `clear calm sky`
- `clouds` → `overcast soft grey clouds, diffuse light`
- `fog` → `thick layered fog, misty depth, low visibility, mysterious`
- `rain` → `heavy rain streaks, wet reflective ground, puddles`
- `snow` → `falling snow, snow-covered ground, bare branches, cold haze`
- `thunder` → `stormy dark sky, dramatic lightning flash, heavy rain`
- `windy` → `strong wind, swaying trees, leaves blowing across, bent grass`

**Prompt formülü:** `STYLE PREFIX + temel sahne + ", " + HAVA + ", " + ZAMAN`

**28 dosya adı (hepsini üret):**
```
clear_dawn.png   clear_day.png   clear_dusk.png   clear_night.png
clouds_dawn.png  clouds_day.png  clouds_dusk.png  clouds_night.png
fog_dawn.png     fog_day.png     fog_dusk.png     fog_night.png
rain_dawn.png    rain_day.png    rain_dusk.png    rain_night.png
snow_dawn.png    snow_day.png    snow_dusk.png    snow_night.png
thunder_dawn.png thunder_day.png thunder_dusk.png thunder_night.png
windy_dawn.png   windy_day.png   windy_dusk.png   windy_night.png
```
> Az başlamak istersen önce `*_dusk.png` (7 adet) üret — saat denk gelince görünür. Sonra diğerleri.

---

## 2) YARATIK EVRELERİ — `art/creature/`  (7 adet, ŞEFFAF PNG, 512×512, tek ön idle poz)

Karakter kimliği SABİT: sevimli, yuvarlak **bitki-ruhu yaratık**, büyük ifadeli parlak gözler,
başında filiz/yaprak; yaşla değişir. Hepsine ortak son cümle:
`single front idle pose, full body centered, transparent background, soft rim light, no baked shadow.`

Dosya adı = evre. Promptlar (STYLE PREFIX + şu + ortak son cümle):

| Dosya | Yaş | Prompt gövdesi |
|---|---|---|
| `filiz.png` | 0–12 | `a tiny baby sprout-spirit creature, a single leaf bud on its head, big curious eyes, chubby and playful, cream-green body` |
| `tomurcuk.png` | 13–17 | `a teenage sprout creature, two leaves on its head, slightly taller and lanky, cool slightly moody expression, wearing small orange retro headphones` |
| `cicek.png` | 18–29 | `a young-adult bloom creature, a small flower blooming on its head, confident bright cheerful look` |
| `meyve.png` | 30–44 | `an adult plant creature, fuller rounded form, a small ripe fruit detail, calm content mature expression` |
| `hasat.png` | 45–59 | `a mature plant creature, warm autumn-tinted leaves, gentle wise yet active look` |
| `kok.png` | 60–74 | `an elder root-spirit creature, sturdy rooted form, soft kind wrinkles, cozy grandparent warmth, optional tiny teacup` |
| `cinar.png` | 75+ | `an ancient sycamore-spirit creature, serene and glowing, mossy details, deeply peaceful expression` |

---

## 3) MOBİLYA — `art/items/furniture/`  (5 adet, ŞEFFAF PNG, 256×256)

Ortak: `single object icon, centered, transparent background, soft shading.`

| Dosya | Prompt gövdesi |
|---|---|
| `plant.png` | `a cozy leafy potted plant` |
| `lamp.png` | `a glowing leaf-shaped table lamp emitting soft cyan light` |
| `rug.png` | `a soft round woven rug with a warm cozy pattern` |
| `poster.png` | `a framed pixel-art forest landscape poster` |
| `record.png` | `a retro vinyl record player with a wooden base` |

---

## 4) ONBOARDING YUMURTASI — `art/ui/onboarding/`  (1 adet, ŞEFFAF PNG, ~512×512)

Dosya: `egg.png`
Prompt (STYLE PREFIX + şu):
`a glowing cracked pixel-art egg with a tiny sprout creature (filiz) emerging from the top, warm golden inner light, floating magical dust motes, centered, transparent background.`

---

## 5) FONTLAR — `art/fonts/`  (3 adet .ttf, AI değil — indir)

Hepsi ücretsiz (OFL). İndir → şu adlarla **yeniden adlandır** → klasöre at:
- Space Grotesk → `SpaceGrotesk.ttf`  (https://fonts.google.com/specimen/Space+Grotesk)
- Hanken Grotesk → `HankenGrotesk.ttf` (https://fonts.google.com/specimen/Hanken+Grotesk)
- JetBrains Mono → `JetBrainsMono.ttf` (https://fonts.google.com/specimen/JetBrains+Mono)
> Variable veya Bold/Regular fark etmez; tek dosya yeter. `font_loader.gd` otomatik algılar.

---

## Klasör özeti (nereye taşıyacaksın)
```
art/backgrounds/        → 28 hava×zaman PNG (opak)
art/creature/           → 7 evre PNG (şeffaf)
art/items/furniture/    → 5 mobilya PNG (şeffaf)
art/ui/onboarding/      → egg.png (şeffaf)
art/fonts/              → 3 .ttf
```

## Import ayarı (Godot Editor, dosyaları ekledikten sonra)
- Arka planlar: Import → **Lossless** ya da VRAM ETC2, Mipmaps **kapalı**, Filter **Linear**.
- Şeffaf sprite/mobilya/yumurta: Filter **Linear**, Mipmaps **kapalı**, Fix Alpha Border **açık**.
- Detay: `docs/PERFORMANCE_MOBILE.md`.
