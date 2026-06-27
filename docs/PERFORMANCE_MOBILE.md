# Performans · Mobil Uyum · Dokunmatik (Pixel-Prime)

Master Plan §15. Bu sürümde uygulanan optimizasyonlar + Android cihaz doğrulama listesi.

## Performans — uygulanan
- **FPS kademeleri** (`game_manager.gd`): idle **30**, etkileşimde **60** (`request_active_frames`),
  arka planda **10**. Sürekli nefes/partikül low_processor'u boşa düşürmesin diye idle 30.
- **`low_processor_usage_mode`** açık; hareket-azaltmada yaratık nefesi `_process` durur
  (`creature.gd._update_motion`) → boşta render gerçekten kesilir.
- **Mini-oyunlar oynarken 60 FPS** ister (`request_active_frames` her frame), bitince idle 30'a döner.
- **SceneBackground THREADED yükleme** (`scene_background.gd`): hava/zaman değişince büyük
  illüstrasyon PNG arka planda yüklenir → kare düşmesi/takılma yok.
- **Weather-VFX motoru kaldırıldı** → Home'da sürekli partikül yok; sahne tek TextureRect + sprite.
- **Orphan yok**: mini-oyun/draggable örnekleri kapanışta `queue_free`; sahne geçişinde temizlik.
- **Save**: 60 sn autosave + arka plana alınınca; gereksiz yazma yok.

## Mobil / Android uyum
- Renderer **`gl_compatibility`** (eski/ucuz GPU dostu), portre 540×960, `canvas_items`+`expand`
  (çok en-boy oranına uyar).
- `export_presets.cfg`: **minSdk 24** (Android 7+), **targetSdk 36** (Android 16), **AAB**,
  arm64-v8a + armeabi-v7a. İzinler minimal (INTERNET, COARSE_LOCATION, POST_NOTIFICATIONS).
- **Güvenli alan** (`hud_safe_area.gd`): çentik/punch-hole/gesture-nav insetleri HUD'a uygulanır
  (üst rozetler + alt nav gizlenmez). Masaüstü/çentiksizde etkisiz.
- **Öneri**: emülatör/ChromeOS kapsamı için `architectures/x86_64=true` ekle (şu an kapalı).

## Dokunmatik
- Tüm girdi **`InputEventScreenTouch` + fare** ikisini de işler:
  yaratık (`creature._unhandled_input`), mini-oyun taneleri (`gui_input`), ritim (`_input`),
  oda dekor sürükleme (`draggable_item._input`).
- **Dokunma hedefleri ≥ 48dp**: FAB 64, nav butonları ~76, drawer bento 56, skill node 64.
- **Sürükle-bırak** (`draggable_item.gd`): `_input` ile global yakalama → hızlı sürüklemede
  imleç kontrolden çıksa bile takip eder; bırakınca konum `home_decor`'a kıstırılarak kaydedilir.
- Tek-el: birincil aksiyonlar alt bölgede (bottom-nav + FAB).

## Asset import önerileri (kullanıcı PNG/font eklerken)
Godot Editor → ilgili dosya → Import sekmesi:
- `art/backgrounds/*.png` (illüstrasyon): **Lossless** veya **VRAM Compressed (ETC2/ASTC)**,
  Mipmaps **kapalı**, Filter **Linear** (illüstrasyon, pixel değil).
- `art/creature/*.png` (şeffaf sprite): Filter **Linear**, Mipmaps **kapalı**, Fix Alpha Border açık.
- `art/fonts/*.ttf`: otomatik FontFile; `font_loader.gd` algılar.
- Büyük PNG'ler AAB ile cihaza özel dağıtılır; gereksiz boyut için 1080×1920 üstüne çıkma.

## Cihaz doğrulama listesi (yayın öncesi)
- [ ] Düşük donanım: API 24, ~2GB RAM, 720p — akıcılık + ısı (30+ dk açık tut).
- [ ] Uzun ekran 20:9 / 21:9 — HUD taşmıyor, safe-area çalışıyor.
- [ ] Çentik/punch-hole telefon — üst rozet + alt nav gizlenmiyor.
- [ ] Katlanabilir / tablet — merkez kompozisyon bozulmuyor.
- [ ] Gesture navigation — alt nav nav-bar altında kalmıyor.
- [ ] Pil: 15 dk idle + 15 dk mini-oyun → ısı/şarj makul.
- [ ] Bellek: 30 dk oturum boyunca düz RAM (orphan yok).
- [ ] Play Console **Pre-launch report** + **Vitals** (ANR/çökme) temiz.
